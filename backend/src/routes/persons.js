import { Router } from 'express';
import db from '../config/database.js';

const router = Router();
const ok = (data, message = 'success') => ({ code: 200, data, message });

// ─── Person CRUD ───────────────────────────────────────────────────

// GET /persons?keyword=&department=
router.get('/', (req, res, next) => {
  try {
    let where = '1=1';
    const params = {};
    if (req.query.department) { where += ' AND department = @department'; params.department = req.query.department; }
    if (req.query.keyword) {
      where += ' AND (person_name LIKE @kw OR person_code LIKE @kw OR role_name LIKE @kw)';
      params.kw = `%${req.query.keyword}%`;
    }
    const list = db.prepare(`SELECT * FROM person_info WHERE ${where} ORDER BY id`).all(params);
    res.json(ok(list));
  } catch (e) { next(e); }
});

// GET /persons/:id
router.get('/:id', (req, res, next) => {
  try {
    if (req.params.id === 'event') return next('route');
    const person = db.prepare('SELECT * FROM person_info WHERE id = ?').get(req.params.id);
    if (!person) return res.status(404).json({ code: 404, data: null, message: '人员不存在' });
    const events = db.prepare(`
      SELECT ep.*, em.event_code, em.event_title, em.occur_time
      FROM event_person ep JOIN event_main em ON ep.event_id = em.id
      WHERE ep.person_id = ?
    `).all(person.id);
    res.json(ok({ ...person, events }));
  } catch (e) { next(e); }
});

// POST /persons
router.post('/', (req, res, next) => {
  try {
    const b = req.body;
    if (!b.person_name) return res.status(400).json({ code: 400, data: null, message: '缺少 person_name' });
    const r = db.prepare(`INSERT INTO person_info
      (person_code, person_name, department, role_name, experience_years, qualification_level, contact_info, note)
      VALUES (@person_code, @person_name, @department, @role_name, @experience_years, @qualification_level, @contact_info, @note)`)
      .run({
        person_code: b.person_code || null, person_name: b.person_name,
        department: b.department || null, role_name: b.role_name || null,
        experience_years: b.experience_years ?? null, qualification_level: b.qualification_level || null,
        contact_info: b.contact_info || null, note: b.note || null,
      });
    const person = db.prepare('SELECT * FROM person_info WHERE id = ?').get(r.lastInsertRowid);
    res.status(201).json(ok(person, '人员创建成功'));
  } catch (e) { next(e); }
});

// PUT /persons/:id
router.put('/:id', (req, res, next) => {
  try {
    const existing = db.prepare('SELECT id FROM person_info WHERE id = ?').get(req.params.id);
    if (!existing) return res.status(404).json({ code: 404, data: null, message: '人员不存在' });
    const b = req.body;
    db.prepare(`UPDATE person_info SET
      person_code=@person_code, person_name=@person_name, department=@department,
      role_name=@role_name, experience_years=@experience_years, qualification_level=@qualification_level,
      contact_info=@contact_info, note=@note WHERE id=@id`)
      .run({
        id: parseInt(req.params.id), person_code: b.person_code ?? null,
        person_name: b.person_name, department: b.department ?? null,
        role_name: b.role_name ?? null, experience_years: b.experience_years ?? null,
        qualification_level: b.qualification_level ?? null, contact_info: b.contact_info ?? null,
        note: b.note ?? null,
      });
    const updated = db.prepare('SELECT * FROM person_info WHERE id = ?').get(req.params.id);
    res.json(ok(updated, '人员更新成功'));
  } catch (e) { next(e); }
});

// DELETE /persons/:id
router.delete('/:id', (req, res, next) => {
  try {
    const r = db.prepare('DELETE FROM person_info WHERE id = ?').run(req.params.id);
    if (r.changes === 0) return res.status(404).json({ code: 404, data: null, message: '人员不存在' });
    res.json(ok(null, '人员删除成功'));
  } catch (e) { next(e); }
});

// ─── Event-Person Link ─────────────────────────────────────────────

// POST /persons/link
router.post('/link', (req, res, next) => {
  try {
    const b = req.body;
    if (!b.event_id || !b.person_id) {
      return res.status(400).json({ code: 400, data: null, message: '缺少 event_id 或 person_id' });
    }
    const r = db.prepare(`INSERT INTO event_person (event_id, person_id, involvement_type, responsibility_desc, behavior_note)
      VALUES (@event_id, @person_id, @involvement_type, @responsibility_desc, @behavior_note)`)
      .run({
        event_id: b.event_id, person_id: b.person_id,
        involvement_type: b.involvement_type || null,
        responsibility_desc: b.responsibility_desc || null,
        behavior_note: b.behavior_note || null,
      });
    const record = db.prepare(`
      SELECT ep.*, pi.person_name, pi.person_code, pi.department, pi.role_name
      FROM event_person ep JOIN person_info pi ON ep.person_id = pi.id
      WHERE ep.id = ?
    `).get(r.lastInsertRowid);
    res.status(201).json(ok(record, '人员关联成功'));
  } catch (e) { next(e); }
});

// DELETE /persons/link/:id
router.delete('/link/:id', (req, res, next) => {
  try {
    const r = db.prepare('DELETE FROM event_person WHERE id = ?').run(req.params.id);
    if (r.changes === 0) return res.status(404).json({ code: 404, data: null, message: '关联记录不存在' });
    res.json(ok(null, '人员关联解除成功'));
  } catch (e) { next(e); }
});

// GET /persons/event/:eventId
router.get('/event/:eventId', (req, res, next) => {
  try {
    const list = db.prepare(`
      SELECT ep.*, pi.person_code, pi.person_name, pi.department, pi.role_name, pi.experience_years
      FROM event_person ep JOIN person_info pi ON ep.person_id = pi.id
      WHERE ep.event_id = ? ORDER BY ep.id
    `).all(req.params.eventId);
    res.json(ok(list));
  } catch (e) { next(e); }
});

export default router;
