const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const db = require('../db');

const JWT_SECRET = process.env.JWT_SECRET || 'super_secret_jwt_inventario_dev_key_2026';
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || '2h';

function login(req, res) {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(422).json({
        message: 'Datos inválidos',
        errors: {
          ...(!email ? { email: ['El correo electrónico es obligatorio'] } : {}),
          ...(!password ? { password: ['La contraseña es obligatoria'] } : {}),
        },
      });
    }

    const emailNormalizado = String(email).trim().toLowerCase();
    const usuario = db.prepare('SELECT id, nombre, email, password FROM usuarios WHERE LOWER(email) = ?').get(emailNormalizado);

    if (!usuario) {
      return res.status(401).json({
        message: 'Credenciales incorrectas: correo o contraseña no válidos',
      });
    }

    const passwordValida = bcrypt.compareSync(String(password), usuario.password);
    if (!passwordValida) {
      return res.status(401).json({
        message: 'Credenciales incorrectas: correo o contraseña no válidos',
      });
    }

    // Generar token JWT con información no sensible en payload
    const token = jwt.sign(
      {
        id: usuario.id,
        nombre: usuario.nombre,
        email: usuario.email,
      },
      JWT_SECRET,
      { expiresIn: JWT_EXPIRES_IN }
    );

    return res.status(200).json({
      message: 'Inicio de sesión exitoso',
      token,
      usuario: {
        id: usuario.id,
        nombre: usuario.nombre,
        email: usuario.email,
      },
    });
  } catch (error) {
    console.error('Error en login:', error);
    return res.status(500).json({ message: 'Error interno del servidor al procesar el inicio de sesión' });
  }
}

function perfil(req, res) {
  // req.usuario fue inyectado por authMiddleware
  return res.status(200).json({
    usuario: req.usuario,
  });
}

module.exports = {
  login,
  perfil,
};
