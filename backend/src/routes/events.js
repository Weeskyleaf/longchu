import { Router } from 'express';
import db from '../config/database.js';

const router = Router();

function ok(data, message = 'success') {
  return { code: 200, data, message };
}

// GET /events/stats/overview  (must precede /:id)
router.get('/stats/overview', (_req, res, next) => {
  try {
    const byType = db.prepare(`SELECT event_type AS name, COUNT(*) AS value FROM event_main GROUP BY event_type`).all();
    const byUnit = db.prepare(`SELECT plant_name || '-' || unit_no AS name, COUNT(*) AS value FROM event_main GROUP BY plant_name, unit_no`).all();
    const byMonth = db.prepare(`SELECT strftime('%Y-%m', occur_time) AS name, COUNT(*) AS value FROM event_main WHERE occur_time IS NOT NULL GROUP BY name ORDER BY name`).all();
    const byConsequence = db.prepare(`SELECT consequence_level AS name, COUNT(*) AS value FROM event_main GROUP BY consequence_level`).all();
    const total = db.prepare(`SELECT COUNT(*) AS c FROM event_main`).get().c;

    res.json(ok({ total, byType, byUnit, byMonth, byConsequence }));
  } catch (e) { next(e); }
});

// GET /events?page=1&pageSize=20&event_type=&unit_no=&keyword=
router.get('/', (req, res, next) => {
  try {
    const page = Math.max(1, parseInt(req.query.page) || 1);
    const pageSize = Math.min(100, Math.max(1, parseInt(req.query.pageSize) || 20));
    const offset = (page - 1) * pageSize;

    let where = '1=1';
    const params = {};
    if (req.query.event_type) { where += ' AND event_type = @event_type'; params.event_type = req.query.event_type; }
    if (req.query.unit_no) { where += ' AND unit_no = @unit_no'; params.unit_no = req.query.unit_no; }
    if (req.query.plant_name) { where += ' AND plant_name = @plant_name'; params.plant_name = req.query.plant_name; }
    if (req.query.keyword) {
      where += ' AND (event_title LIKE @kw OR event_code LIKE @kw OR raw_text LIKE @kw)';
      params.kw = `%${req.query.keyword}%`;
    }

    const total = db.prepare(`SELECT COUNT(*) AS c FROM event_main WHERE ${where}`).get(params).c;
    const list = db.prepare(`SELECT * FROM event_main WHERE ${where} ORDER BY occur_time DESC LIMIT @limit OFFSET @offset`)
      .all({ ...params, limit: pageSize, offset });

    res.json(ok({ list, total, page, pageSize }));
  } catch (e) { next(e); }
});

// GET /events/:id
router.get('/:id', (req, res, next) => {
  try {
    const event = db.prepare('SELECT * FROM event_main WHERE id = ?').get(req.params.id);
    if (!event) return res.status(404).json({ code: 404, data: null, message: '事件不存在' });

    const tasks = db.prepare('SELECT * FROM task_unit WHERE event_id = ?').all(event.id);
    const scenarios = db.prepare('SELECT * FROM scenario_info WHERE event_id = ?').all(event.id);
    const tags = db.prepare(`
      SELECT et.*, td.tag_type, td.tag_code, td.tag_name, td.tag_value
      FROM event_tag et JOIN tag_dict td ON et.tag_id = td.id
      WHERE et.event_id = ?
    `).all(event.id);
    const factors = db.prepare('SELECT * FROM impact_factor WHERE event_id = ?').all(event.id);
    const persons = db.prepare(`
      SELECT ep.*, pi.person_code, pi.person_name, pi.department, pi.role_name
      FROM event_person ep JOIN person_info pi ON ep.person_id = pi.id
      WHERE ep.event_id = ?
    `).all(event.id);
    const evidence = db.prepare('SELECT * FROM evidence_chain WHERE event_id = ?').all(event.id);

    res.json(ok({ ...event, tasks, scenarios, tags, factors, persons, evidence }));
  } catch (e) { next(e); }
});

// POST /events
router.post('/', (req, res, next) => {
  try {
    const b = req.body;
    const r = db.prepare(`INSERT INTO event_main
      (event_code, event_title, event_type, main_category, sub_category, occur_time, plant_name, unit_no, system_name, operation_mode, consequence_level, event_result, source_type, raw_text)
      VALUES (@event_code, @event_title, @event_type, @main_category, @sub_category, @occur_time, @plant_name, @unit_no, @system_name, @operation_mode, @consequence_level, @event_result, @source_type, @raw_text)`)
      .run({
        event_code: b.event_code || null, event_title: b.event_title, event_type: b.event_type || null,
        main_category: b.main_category || null, sub_category: b.sub_category || null,
        occur_time: b.occur_time || null, plant_name: b.plant_name || null, unit_no: b.unit_no || null,
        system_name: b.system_name || null, operation_mode: b.operation_mode || null,
        consequence_level: b.consequence_level || null, event_result: b.event_result || null,
        source_type: b.source_type || null, raw_text: b.raw_text || null,
      });
    const event = db.prepare('SELECT * FROM event_main WHERE id = ?').get(r.lastInsertRowid);
    res.status(201).json(ok(event, '事件创建成功'));
  } catch (e) { next(e); }
});

// PUT /events/:id
router.put('/:id', (req, res, next) => {
  try {
    const existing = db.prepare('SELECT id FROM event_main WHERE id = ?').get(req.params.id);
    if (!existing) return res.status(404).json({ code: 404, data: null, message: '事件不存在' });

    const b = req.body;
    db.prepare(`UPDATE event_main SET
      event_code=@event_code, event_title=@event_title, event_type=@event_type,
      main_category=@main_category, sub_category=@sub_category, occur_time=@occur_time,
      plant_name=@plant_name, unit_no=@unit_no, system_name=@system_name,
      operation_mode=@operation_mode, consequence_level=@consequence_level,
      event_result=@event_result, source_type=@source_type, raw_text=@raw_text,
      updated_at=datetime('now','localtime')
      WHERE id=@id`)
      .run({
        id: parseInt(req.params.id),
        event_code: b.event_code ?? null, event_title: b.event_title, event_type: b.event_type ?? null,
        main_category: b.main_category ?? null, sub_category: b.sub_category ?? null,
        occur_time: b.occur_time ?? null, plant_name: b.plant_name ?? null, unit_no: b.unit_no ?? null,
        system_name: b.system_name ?? null, operation_mode: b.operation_mode ?? null,
        consequence_level: b.consequence_level ?? null, event_result: b.event_result ?? null,
        source_type: b.source_type ?? null, raw_text: b.raw_text ?? null,
      });
    const updated = db.prepare('SELECT * FROM event_main WHERE id = ?').get(req.params.id);
    res.json(ok(updated, '事件更新成功'));
  } catch (e) { next(e); }
});

// DELETE /events/:id
router.delete('/:id', (req, res, next) => {
  try {
    const r = db.prepare('DELETE FROM event_main WHERE id = ?').run(req.params.id);
    if (r.changes === 0) return res.status(404).json({ code: 404, data: null, message: '事件不存在' });
    res.json(ok(null, '事件删除成功'));
  } catch (e) { next(e); }
});

export default router;
