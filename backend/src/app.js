import express from 'express';
import cors from 'cors';
import bodyParser from 'body-parser';
import morgan from 'morgan';

import db from './config/database.js';
import eventsRouter from './routes/events.js';
import tasksRouter from './routes/tasks.js';
import tagsRouter from './routes/tags.js';
import factorsRouter from './routes/factors.js';
import personsRouter from './routes/persons.js';
import evidenceRouter from './routes/evidence.js';
import analysisRouter from './routes/analysis.js';
import usersRouter from './routes/users.js';

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(bodyParser.json({ limit: '10mb' }));
app.use(bodyParser.urlencoded({ extended: true }));
app.use(morgan('dev'));

app.use('/api/events', eventsRouter);
app.use('/api/tasks', tasksRouter);
app.use('/api/tags', tagsRouter);
app.use('/api/factors', factorsRouter);
app.use('/api/persons', personsRouter);
app.use('/api/evidence', evidenceRouter);
app.use('/api/analysis', analysisRouter);
app.use('/api/users', usersRouter);

app.get('/api/health', (_req, res) => {
  res.json({ code: 200, data: { status: 'ok', timestamp: new Date().toISOString() }, message: 'success' });
});

app.use((_req, res) => {
  res.status(404).json({ code: 404, data: null, message: '接口不存在' });
});

app.use((err, _req, res, _next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({ code: 500, data: null, message: err.message || '服务器内部错误' });
});

app.listen(PORT, () => {
  console.log(`核电人因数据库后端服务已启动 → http://localhost:${PORT}`);
  console.log(`数据库已就绪，共 ${db.prepare('SELECT COUNT(*) AS c FROM event_main').get().c} 条事件记录`);
});

export default app;
