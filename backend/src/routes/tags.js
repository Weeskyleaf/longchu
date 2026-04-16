import { Router } from 'express';
import db from '../config/database.js';

const router = Router();
const ok = (data, message = 'success') => ({ code: 200, data, message });

// GET /tags/dict?tag_type=&keyword=
router.get('/dict', (req, res, next) => {
  try {
    let where = 'is_active = 1';
    const params = {};
    if (req.query.tag_type) { where += ' AND tag_type = @tag_type'; params.tag_type = req.query.tag_type; }
    if (req.query.keyword) { where += ' AND (tag_name LIKE @kw OR tag_code LIKE @kw)'; params.kw = `%${req.query.keyword}%`; }
    const list = db.prepare(`SELECT * FROM tag_dict WHERE ${where} ORDER BY tag_type, id`).all(params);
    res.json(ok(list));
  } catch (e) { next(e); }
});

// POST /tags/dict
router.post('/dict', (req, res, next) => {
  try {
    const b = req.body;
    const r = db.prepare(`INSERT INTO tag_dict (tag_type, tag_code, tag_name, tag_value, description, standard_ref, is_active)
      VALUES (@tag_type, @tag_code, @tag_name, @tag_value, @description, @standard_ref, @is_active)`)
      .run({
        tag_type: b.tag_type, tag_code: b.tag_code, tag_name: b.tag_name,
        tag_value: b.tag_value || null, description: b.description || null,
        standard_ref: b.standard_ref || null, is_active: b.is_active ?? 1,
      });
    const tag = db.prepare('SELECT * FROM tag_dict WHERE id = ?').get(r.lastInsertRowid);
    res.status(201).json(ok(tag, '标签创建成功'));
  } catch (e) { next(e); }
});

// GET /tags/event/:eventId
router.get('/event/:eventId', (req, res, next) => {
  try {
    const list = db.prepare(`
      SELECT et.*, td.tag_type, td.tag_code, td.tag_name, td.tag_value, td.description
      FROM event_tag et JOIN tag_dict td ON et.tag_id = td.id
      WHERE et.event_id = ? ORDER BY et.id
    `).all(req.params.eventId);
    res.json(ok(list));
  } catch (e) { next(e); }
});

// POST /tags/bindEvent
router.post('/bindEvent', (req, res, next) => {
  try {
    const b = req.body;
    if (!b.event_id || !b.tag_id) {
      return res.status(400).json({ code: 400, data: null, message: '缺少必要字段 event_id, tag_id' });
    }
    const r = db.prepare(`INSERT INTO event_tag (event_id, task_id, tag_id, label_basis, reviewer, review_status)
      VALUES (@event_id, @task_id, @tag_id, @label_basis, @reviewer, @review_status)`)
      .run({
        event_id: b.event_id, task_id: b.task_id || null, tag_id: b.tag_id,
        label_basis: b.label_basis || null, reviewer: b.reviewer || null,
        review_status: b.review_status || 'pending',
      });
    const record = db.prepare(`
      SELECT et.*, td.tag_type, td.tag_code, td.tag_name, td.tag_value
      FROM event_tag et JOIN tag_dict td ON et.tag_id = td.id
      WHERE et.id = ?
    `).get(r.lastInsertRowid);
    res.status(201).json(ok(record, '标签绑定成功'));
  } catch (e) { next(e); }
});

// DELETE /tags/bindEvent/:id
router.delete('/bindEvent/:id', (req, res, next) => {
  try {
    const r = db.prepare('DELETE FROM event_tag WHERE id = ?').run(req.params.id);
    if (r.changes === 0) return res.status(404).json({ code: 404, data: null, message: '绑定记录不存在' });
    res.json(ok(null, '标签解绑成功'));
  } catch (e) { next(e); }
});

export default router;
