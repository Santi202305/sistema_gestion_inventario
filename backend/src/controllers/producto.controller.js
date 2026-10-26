const db = require('../db');
const { validateProducto } = require('../validators/producto.validator');

/**
 * GET /api/productos
 * Retorna todos los productos registrados.
 */
function listar(req, res) {
  try {
    const productos = db.prepare('SELECT id, nombre, codigo, descripcion, precio, cantidad, categoria FROM productos ORDER BY id ASC').all();
    return res.status(200).json(productos);
  } catch (error) {
    console.error('Error al listar productos:', error);
    return res.status(500).json({ message: 'Error interno del servidor' });
  }
}

/**
 * GET /api/productos/:id
 * Retorna el detalle de un producto por su id.
 */
function obtener(req, res) {
  try {
    const id = parseInt(req.params.id, 10);
    if (isNaN(id)) {
      return res.status(404).json({ message: 'Producto no encontrado' });
    }

    const producto = db.prepare('SELECT id, nombre, codigo, descripcion, precio, cantidad, categoria FROM productos WHERE id = ?').get(id);

    if (!producto) {
      return res.status(404).json({ message: 'Producto no encontrado' });
    }

    return res.status(200).json(producto);
  } catch (error) {
    console.error('Error al obtener producto:', error);
    return res.status(500).json({ message: 'Error interno del servidor' });
  }
}

/**
 * POST /api/productos
 * Registra un nuevo producto.
 */
function crear(req, res) {
  try {
    const { isValid, sanitizedData, errors } = validateProducto(req.body);

    if (!isValid) {
      return res.status(422).json({
        message: 'Datos inválidos',
        errors,
      });
    }

    const stmt = db.prepare(`
      INSERT INTO productos (nombre, codigo, descripcion, precio, cantidad, categoria)
      VALUES (?, ?, ?, ?, ?, ?)
    `);

    const info = stmt.run(
      sanitizedData.nombre,
      sanitizedData.codigo,
      sanitizedData.descripcion,
      sanitizedData.precio,
      sanitizedData.cantidad,
      sanitizedData.categoria
    );

    const nuevoProducto = db.prepare('SELECT id, nombre, codigo, descripcion, precio, cantidad, categoria FROM productos WHERE id = ?').get(info.lastInsertRowid);

    return res.status(201).json(nuevoProducto);
  } catch (error) {
    console.error('Error al crear producto:', error);
    return res.status(500).json({ message: 'Error interno del servidor' });
  }
}

/**
 * PUT /api/productos/:id
 * Actualiza un producto existente.
 */
function actualizar(req, res) {
  try {
    const id = parseInt(req.params.id, 10);
    if (isNaN(id)) {
      return res.status(404).json({ message: 'Producto no encontrado' });
    }

    // Verificar si existe el producto
    const existing = db.prepare('SELECT id FROM productos WHERE id = ?').get(id);
    if (!existing) {
      return res.status(404).json({ message: 'Producto no encontrado' });
    }

    // Validar datos, ignorando el id actual al verificar código único
    const { isValid, sanitizedData, errors } = validateProducto(req.body, id);

    if (!isValid) {
      return res.status(422).json({
        message: 'Datos inválidos',
        errors,
      });
    }

    const stmt = db.prepare(`
      UPDATE productos
      SET nombre = ?, codigo = ?, descripcion = ?, precio = ?, cantidad = ?, categoria = ?
      WHERE id = ?
    `);

    stmt.run(
      sanitizedData.nombre,
      sanitizedData.codigo,
      sanitizedData.descripcion,
      sanitizedData.precio,
      sanitizedData.cantidad,
      sanitizedData.categoria,
      id
    );

    const productoActualizado = db.prepare('SELECT id, nombre, codigo, descripcion, precio, cantidad, categoria FROM productos WHERE id = ?').get(id);

    return res.status(200).json(productoActualizado);
  } catch (error) {
    console.error('Error al actualizar producto:', error);
    return res.status(500).json({ message: 'Error interno del servidor' });
  }
}

/**
 * DELETE /api/productos/:id
 * Elimina un producto por su id.
 */
function eliminar(req, res) {
  try {
    const id = parseInt(req.params.id, 10);
    if (isNaN(id)) {
      return res.status(404).json({ message: 'Producto no encontrado' });
    }

    const existing = db.prepare('SELECT id FROM productos WHERE id = ?').get(id);
    if (!existing) {
      return res.status(404).json({ message: 'Producto no encontrado' });
    }

    db.prepare('DELETE FROM productos WHERE id = ?').run(id);

    return res.status(200).json({ message: 'Producto eliminado correctamente' });
  } catch (error) {
    console.error('Error al eliminar producto:', error);
    return res.status(500).json({ message: 'Error interno del servidor' });
  }
}

module.exports = {
  listar,
  obtener,
  crear,
  actualizar,
  eliminar,
};
