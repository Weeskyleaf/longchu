import { Router } from 'express';
import db from '../config/database.js';

const router = Router();
const ok = (data, message = 'success') => ({ code: 200, data, message });

// GET /tasks?event_id=X
router.get('/', (req, res, next) => {
  try {
    const { event_id } = req.query;
    if (!event_id) return res.status(400).json({ code: 400, data: null, message: '缺少 event_id 参数' });
    const list = db.prepare('SELECT * FROM task_unit WHERE event_id = ? ORDER BY id').all(event_id);
    res.json(ok(list));
  } catch (e) { next(e); }
});

// POST /tasks
router.post('/', (req, res, next) => {
  try {
    const b = req.body;
    if (!b.event_id || !b.task_name) {
      return res.status(400).json({ code: 400, data: null, message: '缺少必要字段 event_id, task_name' });
    }
    const r = db.prepare(`INSERT INTO task_unit
      (event_id, task_code, task_name, task_type, task_stage, operation_object, procedure_ref, available_time, start_condition, end_condition, task_desc)
      VALUES (@event_id, @task_code, @task_name, @task_type, @task_stage, @operation_object, @procedure_ref, @available_time, @start_condition, @end_condition, @task_desc)`)
      .run({
        event_id: b.event_id, task_code: b.task_code || null, task_name: b.task_name,
        task_type: b.task_type || null, task_stage: b.task_stage || null,
        operation_object: b.operation_object || null, procedure_ref: b.procedure_ref || null,
        available_time: b.available_time || null, start_condition: b.start_condition || null,
        end_condition: b.end_condition || null, task_desc: b.task_desc || null,
      });
    const task = db.prepare('SELECT * FROM task_unit WHERE id = ?').get(r.lastInsertRowid);
    res.status(201).json(ok(task, '任务创建成功'));
  } catch (e) { next(e); }
});

// PUT /tasks/:id
router.put('/:id', (req, res, next) => {
  try {
    const existing = db.prepare('SELECT id FROM task_unit WHERE id = ?').get(req.params.id);
    if (!existing) return res.status(404).json({ code: 404, data: null, message: '任务不存在' });

    const b = req.body;
    db.prepare(`UPDATE task_unit SET
      task_code=@task_code, task_name=@task_name, task_type=@task_type, task_stage=@task_stage,
      operation_object=@operation_object, procedure_ref=@procedure_ref, available_time=@available_time,
      start_condition=@start_condition, end_condition=@end_condition, task_desc=@task_desc
      WHERE id=@id`)
      .run({
        id: parseInt(req.params.id), task_code: b.task_code ?? null, task_name: b.task_name,
        task_type: b.task_type ?? null, task_stage: b.task_stage ?? null,
        operation_object: b.operation_object ?? null, procedure_ref: b.procedure_ref ?? null,
        available_time: b.available_time ?? null, start_condition: b.start_condition ?? null,
        end_condition: b.end_condition ?? null, task_desc: b.task_desc ?? null,
      });
    const updated = db.prepare('SELECT * FROM task_unit WHERE id = ?').get(req.params.id);
    res.json(ok(updated, '任务更新成功'));
  } catch (e) { next(e); }
});

// DELETE /tasks/:id
router.delete('/:id', (req, res, next) => {
  try {
    const r = db.prepare('DELETE FROM task_unit WHERE id = ?').run(req.params.id);
    if (r.changes === 0) return res.status(404).json({ code: 404, data: null, message: '任务不存在' });
    res.json(ok(null, '任务删除成功'));
  } catch (e) { next(e); }
});

export default router;
