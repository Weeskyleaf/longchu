import { Router } from 'express';
import db from '../config/database.js';

const router = Router();
const ok = (data, message = 'success') => ({ code: 200, data, message });

// GET /evidence?event_id=X
router.get('/', (req, res, next) => {
  try {
    let where = '1=1';
    const params = {};
    if (req.query.event_id) { where += ' AND event_id = @event_id'; params.event_id = req.query.event_id; }
    if (req.query.evidence_type) { where += ' AND evidence_type = @evidence_type'; params.evidence_type = req.query.evidence_type; }
    const list = db.prepare(`SELECT * FROM evidence_chain WHERE ${where} ORDER BY operate_time DESC, id`).all(params);
    res.json(ok(list));
  } catch (e) { next(e); }
});

// POST /evidence
router.post('/', (req, res, next) => {
  try {
    const b = req.body;
    if (!b.event_id) return res.status(400).json({ code: 400, data: null, message: '缺少 event_id' });
    const r = db.prepare(`INSERT INTO evidence_chain
      (event_id, evidence_type, doc_code, doc_title, source_ref, page_tag, quote_note, version_no, operator_name, operate_time, audit_comment)
      VALUES (@event_id, @evidence_type, @doc_code, @doc_title, @source_ref, @page_tag, @quote_note, @version_no, @operator_name, @operate_time, @audit_comment)`)
      .run({
        event_id: b.event_id, evidence_type: b.evidence_type || null,
        doc_code: b.doc_code || null, doc_title: b.doc_title || null,
        source_ref: b.source_ref || null, page_tag: b.page_tag || null,
        quote_note: b.quote_note || null, version_no: b.version_no || null,
        operator_name: b.operator_name || null, operate_time: b.operate_time || null,
        audit_comment: b.audit_comment || null,
      });
    const row = db.prepare('SELECT * FROM evidence_chain WHERE id = ?').get(r.lastInsertRowid);
    res.status(201).json(ok(row, '证据链创建成功'));
  } catch (e) { next(e); }
});

// PUT /evidence/:id
router.put('/:id', (req, res, next) => {
  try {
    const existing = db.prepare('SELECT id FROM evidence_chain WHERE id = ?').get(req.params.id);
    if (!existing) return res.status(404).json({ code: 404, data: null, message: '证据记录不存在' });
    const b = req.body;
    db.prepare(`UPDATE evidence_chain SET
      evidence_type=@evidence_type, doc_code=@doc_code, doc_title=@doc_title,
      source_ref=@source_ref, page_tag=@page_tag, quote_note=@quote_note,
      version_no=@version_no, operator_name=@operator_name, operate_time=@operate_time,
      audit_comment=@audit_comment WHERE id=@id`)
      .run({
        id: parseInt(req.params.id),
        evidence_type: b.evidence_type ?? null, doc_code: b.doc_code ?? null,
        doc_title: b.doc_title ?? null, source_ref: b.source_ref ?? null,
        page_tag: b.page_tag ?? null, quote_note: b.quote_note ?? null,
        version_no: b.version_no ?? null, operator_name: b.operator_name ?? null,
        operate_time: b.operate_time ?? null, audit_comment: b.audit_comment ?? null,
      });
    const updated = db.prepare('SELECT * FROM evidence_chain WHERE id = ?').get(req.params.id);
    res.json(ok(updated, '证据链更新成功'));
  } catch (e) { next(e); }
});

// DELETE /evidence/:id
router.delete('/:id', (req, res, next) => {
  try {
    const r = db.prepare('DELETE FROM evidence_chain WHERE id = ?').run(req.params.id);
    if (r.changes === 0) return res.status(404).json({ code: 404, data: null, message: '证据记录不存在' });
    res.json(ok(null, '证据链删除成功'));
  } catch (e) { next(e); }
});

export default router;
