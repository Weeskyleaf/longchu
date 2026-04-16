import { Router } from 'express';
import db from '../config/database.js';

const router = Router();
const ok = (data, message = 'success') => ({ code: 200, data, message });

// GET /factors?event_id=X&task_id=Y
router.get('/', (req, res, next) => {
  try {
    let where = '1=1';
    const params = {};
    if (req.query.event_id) { where += ' AND event_id = @event_id'; params.event_id = req.query.event_id; }
    if (req.query.task_id) { where += ' AND task_id = @task_id'; params.task_id = req.query.task_id; }
    const list = db.prepare(`SELECT * FROM impact_factor WHERE ${where} ORDER BY id`).all(params);
    res.json(ok(list));
  } catch (e) { next(e); }
});

// POST /factors
router.post('/', (req, res, next) => {
  try {
    const b = req.body;
    if (!b.event_id) return res.status(400).json({ code: 400, data: null, message: '缺少 event_id' });
    const r = db.prepare(`INSERT INTO impact_factor
      (event_id, task_id, factor_category, factor_name, factor_level, factor_value, assessment_basis, data_source, method_mapping, remark)
      VALUES (@event_id, @task_id, @factor_category, @factor_name, @factor_level, @factor_value, @assessment_basis, @data_source, @method_mapping, @remark)`)
      .run({
        event_id: b.event_id, task_id: b.task_id || null,
        factor_category: b.factor_category || null, factor_name: b.factor_name || null,
        factor_level: b.factor_level || null, factor_value: b.factor_value ?? null,
        assessment_basis: b.assessment_basis || null, data_source: b.data_source || null,
        method_mapping: b.method_mapping || null, remark: b.remark || null,
      });
    const row = db.prepare('SELECT * FROM impact_factor WHERE id = ?').get(r.lastInsertRowid);
    res.status(201).json(ok(row, '影响因素创建成功'));
  } catch (e) { next(e); }
});

// PUT /factors/:id
router.put('/:id', (req, res, next) => {
  try {
    const existing = db.prepare('SELECT id FROM impact_factor WHERE id = ?').get(req.params.id);
    if (!existing) return res.status(404).json({ code: 404, data: null, message: '影响因素不存在' });
    const b = req.body;
    db.prepare(`UPDATE impact_factor SET
      factor_category=@factor_category, factor_name=@factor_name, factor_level=@factor_level,
      factor_value=@factor_value, assessment_basis=@assessment_basis, data_source=@data_source,
      method_mapping=@method_mapping, remark=@remark WHERE id=@id`)
      .run({
        id: parseInt(req.params.id),
        factor_category: b.factor_category ?? null, factor_name: b.factor_name ?? null,
        factor_level: b.factor_level ?? null, factor_value: b.factor_value ?? null,
        assessment_basis: b.assessment_basis ?? null, data_source: b.data_source ?? null,
        method_mapping: b.method_mapping ?? null, remark: b.remark ?? null,
      });
    const updated = db.prepare('SELECT * FROM impact_factor WHERE id = ?').get(req.params.id);
    res.json(ok(updated, '影响因素更新成功'));
  } catch (e) { next(e); }
});

// DELETE /factors/:id
router.delete('/:id', (req, res, next) => {
  try {
    const r = db.prepare('DELETE FROM impact_factor WHERE id = ?').run(req.params.id);
    if (r.changes === 0) return res.status(404).json({ code: 404, data: null, message: '影响因素不存在' });
    res.json(ok(null, '影响因素删除成功'));
  } catch (e) { next(e); }
});

export default router;
