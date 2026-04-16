import { Router } from 'express';
import axios from 'axios';
import db from '../config/database.js';

const router = Router();
const ok = (data, message = 'success') => ({ code: 200, data, message });
const FLASK_URL = process.env.FLASK_URL || 'http://localhost:5001';

// ─── PSF Dictionary ────────────────────────────────────────────────

// GET /analysis/psf-dict?plant_mode=full_power&task_type=diagnosis
router.get('/psf-dict', (req, res, next) => {
  try {
    let where = '1=1';
    const params = {};
    if (req.query.plant_mode) { where += ' AND plant_mode = @plant_mode'; params.plant_mode = req.query.plant_mode; }
    if (req.query.task_type) { where += ' AND task_type = @task_type'; params.task_type = req.query.task_type; }
    if (req.query.psf_code) { where += ' AND psf_code = @psf_code'; params.psf_code = req.query.psf_code; }
    const list = db.prepare(`SELECT * FROM sparh_psf_dict WHERE ${where} ORDER BY psf_code, id`).all(params);

    const grouped = {};
    for (const row of list) {
      if (!grouped[row.psf_code]) {
        grouped[row.psf_code] = { psf_code: row.psf_code, psf_name: row.psf_name, levels: [] };
      }
      grouped[row.psf_code].levels.push({
        id: row.id, level_code: row.level_code, level_name: row.level_name,
        multiplier: row.multiplier, is_negative: row.is_negative,
        definition_text: row.definition_text, task_type: row.task_type, plant_mode: row.plant_mode,
      });
    }
    res.json(ok(Object.values(grouped)));
  } catch (e) { next(e); }
});

// ─── Analysis Cases CRUD ───────────────────────────────────────────

// GET /analysis/cases?page=1&pageSize=20&review_status=&keyword=
router.get('/cases', (req, res, next) => {
  try {
    const page = Math.max(1, parseInt(req.query.page) || 1);
    const pageSize = Math.min(100, Math.max(1, parseInt(req.query.pageSize) || 20));
    const offset = (page - 1) * pageSize;

    let where = '1=1';
    const params = {};
    if (req.query.review_status) { where += ' AND ac.review_status = @review_status'; params.review_status = req.query.review_status; }
    if (req.query.keyword) {
      where += ' AND (ac.case_name LIKE @kw OR ac.case_code LIKE @kw OR ac.analyst LIKE @kw)';
      params.kw = `%${req.query.keyword}%`;
    }
    if (req.query.method_code) { where += ' AND ac.method_code = @method_code'; params.method_code = req.query.method_code; }

    const total = db.prepare(`SELECT COUNT(*) AS c FROM analysis_case ac WHERE ${where}`).get(params).c;
    const list = db.prepare(`
      SELECT ac.*, em.event_code, em.event_title
      FROM analysis_case ac
      LEFT JOIN event_main em ON ac.source_event_id = em.id
      WHERE ${where}
      ORDER BY ac.updated_at DESC
      LIMIT @limit OFFSET @offset
    `).all({ ...params, limit: pageSize, offset });

    res.json(ok({ list, total, page, pageSize }));
  } catch (e) { next(e); }
});

// GET /analysis/cases/:id
router.get('/cases/:id', (req, res, next) => {
  try {
    const c = db.prepare(`
      SELECT ac.*, em.event_code, em.event_title, em.event_type
      FROM analysis_case ac
      LEFT JOIN event_main em ON ac.source_event_id = em.id
      WHERE ac.id = ?
    `).get(req.params.id);
    if (!c) return res.status(404).json({ code: 404, data: null, message: '分析案例不存在' });

    const tasks = db.prepare('SELECT * FROM case_task WHERE case_id = ? ORDER BY id').all(c.id);
    for (const t of tasks) {
      t.psf_values = db.prepare('SELECT * FROM case_psf_value WHERE case_task_id = ? ORDER BY psf_code').all(t.id);
      t.uncertainty = db.prepare('SELECT * FROM uncertainty_result WHERE case_task_id = ?').get(t.id) || null;
    }

    const dependencies = db.prepare(`
      SELECT da.*,
        ft.task_type AS from_task_type, tt.task_type AS to_task_type
      FROM dependency_assessment da
      LEFT JOIN case_task ft ON da.from_task_id = ft.id
      LEFT JOIN case_task tt ON da.to_task_id = tt.id
      WHERE da.case_id = ?
    `).all(c.id);

    const evidenceIndex = db.prepare('SELECT * FROM evidence_index WHERE case_id = ? ORDER BY trace_step').all(c.id);

    res.json(ok({ ...c, tasks, dependencies, evidenceIndex }));
  } catch (e) { next(e); }
});

// POST /analysis/cases
router.post('/cases', (req, res, next) => {
  try {
    const b = req.body;
    if (!b.case_name) return res.status(400).json({ code: 400, data: null, message: '缺少 case_name' });
    const r = db.prepare(`INSERT INTO analysis_case
      (case_code, method_code, source_event_id, source_task_id, source_scene_id, analysis_path, case_name, analyst, review_status, model_version, summary, ext_json)
      VALUES (@case_code, @method_code, @source_event_id, @source_task_id, @source_scene_id, @analysis_path, @case_name, @analyst, @review_status, @model_version, @summary, @ext_json)`)
      .run({
        case_code: b.case_code || null, method_code: b.method_code || 'SPAR-H',
        source_event_id: b.source_event_id || null, source_task_id: b.source_task_id || null,
        source_scene_id: b.source_scene_id || null, analysis_path: b.analysis_path || null,
        case_name: b.case_name, analyst: b.analyst || null,
        review_status: b.review_status || 'draft', model_version: b.model_version || '1.0',
        summary: b.summary || null, ext_json: b.ext_json ? JSON.stringify(b.ext_json) : null,
      });
    const created = db.prepare('SELECT * FROM analysis_case WHERE id = ?').get(r.lastInsertRowid);
    res.status(201).json(ok(created, '分析案例创建成功'));
  } catch (e) { next(e); }
});

// PUT /analysis/cases/:id
router.put('/cases/:id', (req, res, next) => {
  try {
    const existing = db.prepare('SELECT id FROM analysis_case WHERE id = ?').get(req.params.id);
    if (!existing) return res.status(404).json({ code: 404, data: null, message: '分析案例不存在' });
    const b = req.body;
    db.prepare(`UPDATE analysis_case SET
      case_code=@case_code, method_code=@method_code, source_event_id=@source_event_id,
      source_task_id=@source_task_id, source_scene_id=@source_scene_id,
      analysis_path=@analysis_path, case_name=@case_name, analyst=@analyst,
      review_status=@review_status, model_version=@model_version, summary=@summary,
      ext_json=@ext_json, updated_at=datetime('now','localtime')
      WHERE id=@id`)
      .run({
        id: parseInt(req.params.id),
        case_code: b.case_code ?? null, method_code: b.method_code ?? 'SPAR-H',
        source_event_id: b.source_event_id ?? null, source_task_id: b.source_task_id ?? null,
        source_scene_id: b.source_scene_id ?? null, analysis_path: b.analysis_path ?? null,
        case_name: b.case_name, analyst: b.analyst ?? null,
        review_status: b.review_status ?? 'draft', model_version: b.model_version ?? '1.0',
        summary: b.summary ?? null, ext_json: b.ext_json ? JSON.stringify(b.ext_json) : null,
      });
    const updated = db.prepare('SELECT * FROM analysis_case WHERE id = ?').get(req.params.id);
    res.json(ok(updated, '分析案例更新成功'));
  } catch (e) { next(e); }
});

// ─── Case Tasks ────────────────────────────────────────────────────

// POST /analysis/cases/:id/tasks
router.post('/cases/:id/tasks', (req, res, next) => {
  try {
    const caseId = req.params.id;
    const existing = db.prepare('SELECT id FROM analysis_case WHERE id = ?').get(caseId);
    if (!existing) return res.status(404).json({ code: 404, data: null, message: '分析案例不存在' });

    const b = req.body;
    if (!b.task_type || !['diagnosis', 'action'].includes(b.task_type)) {
      return res.status(400).json({ code: 400, data: null, message: 'task_type 必须为 diagnosis 或 action' });
    }

    const taskResult = db.prepare(`INSERT INTO case_task (case_id, task_type, calc_note) VALUES (?, ?, ?)`)
      .run(caseId, b.task_type, b.calc_note || null);
    const taskId = taskResult.lastInsertRowid;

    if (Array.isArray(b.psf_values)) {
      const insPSF = db.prepare(`INSERT INTO case_psf_value
        (case_task_id, psf_code, psf_name, level_code, level_name, multiplier, is_negative, basis_text)
        VALUES (?,?,?,?,?,?,?,?)`);
      const batch = db.transaction(() => {
        for (const p of b.psf_values) {
          insPSF.run(taskId, p.psf_code, p.psf_name || null, p.level_code, p.level_name || null,
            p.multiplier ?? 1.0, p.is_negative ?? 0, p.basis_text || null);
        }
      });
      batch();
    }

    const task = db.prepare('SELECT * FROM case_task WHERE id = ?').get(taskId);
    task.psf_values = db.prepare('SELECT * FROM case_psf_value WHERE case_task_id = ?').all(taskId);
    res.status(201).json(ok(task, '案例任务创建成功'));
  } catch (e) { next(e); }
});

// PUT /analysis/case-tasks/:id
router.put('/case-tasks/:id', (req, res, next) => {
  try {
    const taskId = req.params.id;
    const existing = db.prepare('SELECT id FROM case_task WHERE id = ?').get(taskId);
    if (!existing) return res.status(404).json({ code: 404, data: null, message: '案例任务不存在' });

    const b = req.body;

    if (b.calc_note !== undefined) {
      db.prepare('UPDATE case_task SET calc_note = ? WHERE id = ?').run(b.calc_note, taskId);
    }

    if (Array.isArray(b.psf_values)) {
      const batch = db.transaction(() => {
        db.prepare('DELETE FROM case_psf_value WHERE case_task_id = ?').run(taskId);
        const insPSF = db.prepare(`INSERT INTO case_psf_value
          (case_task_id, psf_code, psf_name, level_code, level_name, multiplier, is_negative, basis_text)
          VALUES (?,?,?,?,?,?,?,?)`);
        for (const p of b.psf_values) {
          insPSF.run(taskId, p.psf_code, p.psf_name || null, p.level_code, p.level_name || null,
            p.multiplier ?? 1.0, p.is_negative ?? 0, p.basis_text || null);
        }
      });
      batch();
    }

    const task = db.prepare('SELECT * FROM case_task WHERE id = ?').get(taskId);
    task.psf_values = db.prepare('SELECT * FROM case_psf_value WHERE case_task_id = ?').all(taskId);
    res.json(ok(task, '案例任务更新成功'));
  } catch (e) { next(e); }
});

// ─── Dependency Assessment ─────────────────────────────────────────

// POST /analysis/cases/:id/dependency
router.post('/cases/:id/dependency', (req, res, next) => {
  try {
    const caseId = req.params.id;
    const b = req.body;
    if (!b.from_task_id || !b.to_task_id) {
      return res.status(400).json({ code: 400, data: null, message: '缺少 from_task_id 或 to_task_id' });
    }
    const r = db.prepare(`INSERT INTO dependency_assessment
      (case_id, from_task_id, to_task_id, dependency_level, same_crew_flag, close_in_time_flag, same_location_flag, same_cues_flag, correction_value, basis_text)
      VALUES (@case_id, @from_task_id, @to_task_id, @dependency_level, @same_crew_flag, @close_in_time_flag, @same_location_flag, @same_cues_flag, @correction_value, @basis_text)`)
      .run({
        case_id: caseId, from_task_id: b.from_task_id, to_task_id: b.to_task_id,
        dependency_level: b.dependency_level || null,
        same_crew_flag: b.same_crew_flag ?? 0, close_in_time_flag: b.close_in_time_flag ?? 0,
        same_location_flag: b.same_location_flag ?? 0, same_cues_flag: b.same_cues_flag ?? 0,
        correction_value: b.correction_value ?? null, basis_text: b.basis_text || null,
      });
    const row = db.prepare('SELECT * FROM dependency_assessment WHERE id = ?').get(r.lastInsertRowid);
    res.status(201).json(ok(row, '依赖性评估创建成功'));
  } catch (e) { next(e); }
});

// ─── Evidence Index ────────────────────────────────────────────────

// GET /analysis/cases/:id/evidence
router.get('/cases/:id/evidence', (req, res, next) => {
  try {
    const list = db.prepare('SELECT * FROM evidence_index WHERE case_id = ? ORDER BY trace_step').all(req.params.id);
    res.json(ok(list));
  } catch (e) { next(e); }
});

// ─── SPAR-H Calculation (calls Flask) ──────────────────────────────

// POST /analysis/cases/:id/calculate
router.post('/cases/:id/calculate', async (req, res, next) => {
  try {
    const caseId = req.params.id;
    const caseRow = db.prepare('SELECT * FROM analysis_case WHERE id = ?').get(caseId);
    if (!caseRow) return res.status(404).json({ code: 404, data: null, message: '分析案例不存在' });

    const caseTasks = db.prepare('SELECT * FROM case_task WHERE case_id = ? ORDER BY id').all(caseId);
    if (caseTasks.length === 0) {
      return res.status(400).json({ code: 400, data: null, message: '案例无任务，请先添加诊断/操作任务' });
    }

    const tasksPayload = caseTasks.map(t => {
      const psfValues = db.prepare('SELECT * FROM case_psf_value WHERE case_task_id = ?').all(t.id);
      return {
        task_id: t.id,
        task_type: t.task_type,
        psf_values: psfValues.map(p => ({
          psf_code: p.psf_code,
          level_code: p.level_code,
          multiplier: p.multiplier,
          is_negative: p.is_negative,
        })),
      };
    });

    const depRows = db.prepare('SELECT * FROM dependency_assessment WHERE case_id = ?').all(caseId);
    const dependencies = depRows.map(d => ({
      from_task_id: d.from_task_id,
      to_task_id: d.to_task_id,
      same_crew: d.same_crew_flag,
      close_in_time: d.close_in_time_flag,
      same_location: d.same_location_flag,
      same_cues: d.same_cues_flag,
    }));

    let calcResult;
    try {
      const resp = await axios.post(`${FLASK_URL}/api/spar-h/calculate`, {
        case_id: caseId,
        tasks: tasksPayload,
        dependencies,
      }, { timeout: 30000 });
      calcResult = resp.data;
    } catch (flaskErr) {
      // Flask not available — perform a simplified local calculation
      calcResult = localCalculation(tasksPayload, dependencies);
    }

    // Persist results
    const persist = db.transaction(() => {
      if (calcResult.tasks) {
        for (const tr of calcResult.tasks) {
          db.prepare(`UPDATE case_task SET
            nominal_hep=?, composite_psf=?, raw_hep=?, adjusted_hep=?,
            negative_count=?, final_hep=?, calc_note=?
            WHERE id=?`)
            .run(tr.nominal_hep, tr.composite_psf, tr.raw_hep, tr.adjusted_hep,
              tr.negative_count ?? 0, tr.final_hep, tr.calc_note || null, tr.task_id);

          if (tr.uncertainty) {
            db.prepare('DELETE FROM uncertainty_result WHERE case_task_id = ?').run(tr.task_id);
            const u = tr.uncertainty;
            db.prepare(`INSERT INTO uncertainty_result
              (case_task_id, dist_type, alpha_param, beta_param, error_factor, mean_hep, median_hep, p05, p50, p95, param_json, calc_note)
              VALUES (?,?,?,?,?,?,?,?,?,?,?,?)`)
              .run(tr.task_id, u.dist_type || 'beta', u.alpha_param ?? null, u.beta_param ?? null,
                u.error_factor ?? null, u.mean_hep ?? null, u.median_hep ?? null,
                u.p05 ?? null, u.p50 ?? null, u.p95 ?? null,
                u.param_json ? JSON.stringify(u.param_json) : null, u.calc_note || null);
          }
        }
      }

      if (calcResult.dependencies) {
        for (const dr of calcResult.dependencies) {
          if (dr.id) {
            db.prepare(`UPDATE dependency_assessment SET dependency_level=?, correction_value=? WHERE id=?`)
              .run(dr.dependency_level, dr.correction_value, dr.id);
          }
        }
      }

      db.prepare(`UPDATE analysis_case SET review_status='calculated', updated_at=datetime('now','localtime') WHERE id=?`).run(caseId);
    });
    persist();

    // Return full updated case
    const updatedCase = db.prepare('SELECT * FROM analysis_case WHERE id = ?').get(caseId);
    const tasks = db.prepare('SELECT * FROM case_task WHERE case_id = ? ORDER BY id').all(caseId);
    for (const t of tasks) {
      t.psf_values = db.prepare('SELECT * FROM case_psf_value WHERE case_task_id = ?').all(t.id);
      t.uncertainty = db.prepare('SELECT * FROM uncertainty_result WHERE case_task_id = ?').get(t.id) || null;
    }
    const updatedDeps = db.prepare('SELECT * FROM dependency_assessment WHERE case_id = ?').all(caseId);

    res.json(ok({ ...updatedCase, tasks, dependencies: updatedDeps }, 'SPAR-H 计算完成'));
  } catch (e) { next(e); }
});

// ─── Local fallback SPAR-H calculation ─────────────────────────────

function localCalculation(tasksPayload, dependencies) {
  const results = { tasks: [], dependencies: [] };

  for (const t of tasksPayload) {
    const nominalHep = t.task_type === 'diagnosis' ? 0.01 : 0.001;

    let compositePsf = 1.0;
    let negativeCount = 0;
    for (const p of t.psf_values) {
      compositePsf *= p.multiplier;
      if (p.is_negative) negativeCount++;
    }

    let rawHep = nominalHep * compositePsf;

    // SPAR-H adjustment: if composite PSF pushes HEP above practical limit
    let adjustedHep;
    if (rawHep >= 1.0) {
      adjustedHep = 1.0;
    } else {
      adjustedHep = rawHep / (rawHep + (1 - rawHep));
    }

    // Negative-PSF adjustment per SPAR-H: if >= 3 negative PSFs and adjusted > 0.001
    let finalHep = adjustedHep;
    if (negativeCount >= 3 && adjustedHep < 1.0) {
      finalHep = Math.min(1.0, adjustedHep);
    }

    const errorFactor = t.task_type === 'diagnosis' ? 10 : 5;
    const meanHep = finalHep;
    const medianHep = finalHep / Math.sqrt(errorFactor);

    results.tasks.push({
      task_id: t.task_id,
      task_type: t.task_type,
      nominal_hep: nominalHep,
      composite_psf: compositePsf,
      raw_hep: rawHep,
      adjusted_hep: adjustedHep,
      negative_count: negativeCount,
      final_hep: finalHep,
      calc_note: 'Node.js本地计算（Flask服务不可用）',
      uncertainty: {
        dist_type: 'lognormal',
        error_factor: errorFactor,
        mean_hep: meanHep,
        median_hep: medianHep,
        p05: medianHep / errorFactor,
        p50: medianHep,
        p95: medianHep * errorFactor,
        calc_note: `对数正态分布，误差因子=${errorFactor}`,
      },
    });
  }

  // Dependency: simplified SPAR-H dependency model
  const depLevels = { zero: 0, low: 0.05, moderate: 0.15, high: 0.5, complete: 1.0 };
  for (const d of dependencies) {
    const flags = (d.same_crew ? 1 : 0) + (d.close_in_time ? 1 : 0) + (d.same_location ? 1 : 0) + (d.same_cues ? 1 : 0);
    let level;
    if (flags >= 4) level = 'complete';
    else if (flags >= 3) level = 'high';
    else if (flags >= 2) level = 'moderate';
    else if (flags >= 1) level = 'low';
    else level = 'zero';

    results.dependencies.push({
      from_task_id: d.from_task_id,
      to_task_id: d.to_task_id,
      dependency_level: level,
      correction_value: depLevels[level],
    });
  }

  return results;
}

export default router;
