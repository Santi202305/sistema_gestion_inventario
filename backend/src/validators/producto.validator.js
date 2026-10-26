const db = require('../db');

/**
 * Validador de producto para creación (POST) y actualización (PUT).
 * @param {Object} data - Datos recibidos en req.body
 * @param {number|null} currentId - ID actual del producto en caso de PUT para ignorar su propio código
 * @returns {{ isValid: boolean, sanitizedData: Object, errors: Object }}
 */
function validateProducto(data, currentId = null) {
  const errors = {};
  const sanitized = {};

  // Validar nombre
  if (data.nombre === undefined || data.nombre === null || typeof data.nombre !== 'string' || data.nombre.trim() === '') {
    errors.nombre = ['El nombre es obligatorio'];
  } else {
    sanitized.nombre = data.nombre.trim();
  }

  // Validar codigo
  if (data.codigo === undefined || data.codigo === null || typeof data.codigo !== 'string' || data.codigo.trim() === '') {
    errors.codigo = ['El código es obligatorio'];
  } else {
    const trimmedCodigo = data.codigo.trim();
    sanitized.codigo = trimmedCodigo;

    // Verificar unicidad en base de datos
    let checkSql = 'SELECT id FROM productos WHERE codigo = ?';
    const params = [trimmedCodigo];

    if (currentId !== null) {
      checkSql += ' AND id != ?';
      params.push(currentId);
    }

    const existing = db.prepare(checkSql).get(...params);
    if (existing) {
      errors.codigo = ['El código ya está registrado'];
    }
  }

  // Validar descripcion (opcional, null si está vacío)
  if (data.descripcion === undefined || data.descripcion === null) {
    sanitized.descripcion = null;
  } else if (typeof data.descripcion === 'string') {
    const trimmed = data.descripcion.trim();
    sanitized.descripcion = trimmed.length > 0 ? trimmed : null;
  } else {
    sanitized.descripcion = String(data.descripcion).trim();
  }

  // Validar precio (numérico y > 0)
  if (data.precio === undefined || data.precio === null || data.precio === '') {
    errors.precio = ['El precio es obligatorio'];
  } else {
    const parsedPrecio = Number(data.precio);
    if (isNaN(parsedPrecio) || typeof data.precio === 'boolean') {
      errors.precio = ['El precio debe ser un número válido'];
    } else if (parsedPrecio <= 0) {
      errors.precio = ['El precio debe ser mayor que 0'];
    } else {
      sanitized.precio = parsedPrecio;
    }
  }

  // Validar cantidad (entero y >= 0)
  if (data.cantidad === undefined || data.cantidad === null || data.cantidad === '') {
    errors.cantidad = ['La cantidad es obligatoria'];
  } else {
    const numCantidad = Number(data.cantidad);
    if (isNaN(numCantidad) || !Number.isInteger(numCantidad) || typeof data.cantidad === 'boolean') {
      errors.cantidad = ['La cantidad debe ser un número entero'];
    } else if (numCantidad < 0) {
      errors.cantidad = ['La cantidad debe ser mayor o igual a 0'];
    } else {
      sanitized.cantidad = numCantidad;
    }
  }

  // Validar categoria
  if (data.categoria === undefined || data.categoria === null || typeof data.categoria !== 'string' || data.categoria.trim() === '') {
    errors.categoria = ['La categoría es obligatoria'];
  } else {
    sanitized.categoria = data.categoria.trim();
  }

  return {
    isValid: Object.keys(errors).length === 0,
    sanitizedData: sanitized,
    errors,
  };
}

module.exports = {
  validateProducto,
};
