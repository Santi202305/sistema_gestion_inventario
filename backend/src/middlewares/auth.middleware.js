const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET || 'super_secret_jwt_inventario_dev_key_2026';

function authMiddleware(req, res, next) {
  const authHeader = req.headers['authorization'] || req.headers['Authorization'];

  if (!authHeader) {
    return res.status(401).json({
      message: 'Acceso no autorizado: encabezado Authorization no proporcionado',
    });
  }

  const parts = authHeader.split(' ');
  if (parts.length !== 2 || parts[0] !== 'Bearer') {
    return res.status(401).json({
      message: 'Formato de token inválido. Formato esperado: Bearer <token>',
    });
  }

  const token = parts[1];

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    req.usuario = decoded;
    next();
  } catch (err) {
    if (err.name === 'TokenExpiredError') {
      return res.status(401).json({
        message: 'Sesión expirada. Por favor inicie sesión nuevamente.',
        code: 'TOKEN_EXPIRED',
      });
    }

    return res.status(401).json({
      message: 'Token inválido o manipulado',
      code: 'INVALID_TOKEN',
    });
  }
}

module.exports = authMiddleware;
