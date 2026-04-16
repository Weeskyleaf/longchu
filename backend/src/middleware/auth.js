import jwt from 'jsonwebtoken';

const JWT_SECRET = process.env.JWT_SECRET || 'nuclear-hf-secret-key-2024';

export function authRequired(req, res, next) {
  const header = req.headers.authorization;
  if (!header || !header.startsWith('Bearer ')) {
    return res.status(401).json({ code: 401, data: null, message: '未提供认证令牌' });
  }
  try {
    req.user = jwt.verify(header.slice(7), JWT_SECRET);
    next();
  } catch {
    return res.status(401).json({ code: 401, data: null, message: '令牌无效或已过期' });
  }
}

export function optionalAuth(req, _res, next) {
  const header = req.headers.authorization;
  if (header?.startsWith('Bearer ')) {
    try { req.user = jwt.verify(header.slice(7), JWT_SECRET); } catch { /* ignore */ }
  }
  next();
}

export { JWT_SECRET };
