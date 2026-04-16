import { Router } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import db from '../config/database.js';
import { JWT_SECRET, authRequired } from '../middleware/auth.js';

const router = Router();
const ok = (data, message = 'success') => ({ code: 200, data, message });

// POST /users/login
router.post('/login', (req, res, next) => {
  try {
    const { username, password } = req.body;
    if (!username || !password) {
      return res.status(400).json({ code: 400, data: null, message: '请提供用户名和密码' });
    }
    const user = db.prepare('SELECT * FROM sys_user WHERE username = ? AND is_active = 1').get(username);
    if (!user || !bcrypt.compareSync(password, user.password_hash)) {
      return res.status(401).json({ code: 401, data: null, message: '用户名或密码错误' });
    }
    const token = jwt.sign(
      { id: user.id, username: user.username, role: user.role, real_name: user.real_name },
      JWT_SECRET,
      { expiresIn: '24h' }
    );
    res.json(ok({
      token,
      user: { id: user.id, username: user.username, real_name: user.real_name, role: user.role },
    }, '登录成功'));
  } catch (e) { next(e); }
});

// GET /users/profile
router.get('/profile', authRequired, (req, res) => {
  const user = db.prepare('SELECT id, username, real_name, role, is_active, created_at FROM sys_user WHERE id = ?').get(req.user.id);
  if (!user) return res.status(404).json({ code: 404, data: null, message: '用户不存在' });
  res.json(ok(user));
});

// POST /users/register
router.post('/register', (req, res, next) => {
  try {
    const { username, password, real_name, role } = req.body;
    if (!username || !password) {
      return res.status(400).json({ code: 400, data: null, message: '请提供用户名和密码' });
    }
    const exists = db.prepare('SELECT id FROM sys_user WHERE username = ?').get(username);
    if (exists) {
      return res.status(409).json({ code: 409, data: null, message: '用户名已存在' });
    }
    const hash = bcrypt.hashSync(password, 10);
    const r = db.prepare(`INSERT INTO sys_user (username, password_hash, real_name, role) VALUES (?,?,?,?)`)
      .run(username, hash, real_name || username, role || 'analyst');
    const user = db.prepare('SELECT id, username, real_name, role, created_at FROM sys_user WHERE id = ?').get(r.lastInsertRowid);
    res.status(201).json(ok(user, '注册成功'));
  } catch (e) { next(e); }
});

export default router;
