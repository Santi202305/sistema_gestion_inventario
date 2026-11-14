const { Router } = require('express');
const {
  listar,
  obtener,
  crear,
  actualizar,
  eliminar,
} = require('../controllers/producto.controller');
const authMiddleware = require('../middlewares/auth.middleware');

const router = Router();

// Todas las rutas CRUD de productos requieren token JWT válido
router.use(authMiddleware);

router.get('/', listar);
router.get('/:id', obtener);
router.post('/', crear);
router.put('/:id', actualizar);
router.delete('/:id', eliminar);

module.exports = router;
