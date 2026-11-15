const { Router } = require('express');
const { login, perfil } = require('../controllers/auth.controller');
const authMiddleware = require('../middlewares/auth.middleware');

const router = Router();

// Endpoint público para autenticarse
router.post('/login', login);

// Endpoint protegido para verificar el token y obtener datos del usuario autenticado
router.get('/perfil', authMiddleware, perfil);

module.exports = router;
