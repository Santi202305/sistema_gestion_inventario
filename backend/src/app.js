const path = require('path');
const express = require('express');
const cors = require('cors');
require('dotenv').config({ path: path.resolve(__dirname, '../.env') });

const productoRoutes = require('./routes/producto.routes');

const app = express();
const PORT = process.env.PORT || 3000;
const HOST = '0.0.0.0';

// Middlewares
app.use(cors());
app.use(express.json());

// Logging simple para trazabilidad de peticiones
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = Date.now() - start;
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.originalUrl} -> ${res.statusCode} (${duration}ms)`);
  });
  next();
});

// Rutas principales bajo el prefijo /api
app.use('/api/productos', productoRoutes);

// Ruta base para healthcheck
app.get('/api', (req, res) => {
  res.json({
    name: 'Sistema de Gestión de Inventario API',
    version: '1.0.0',
    status: 'online',
    endpoints: {
      productos: '/api/productos'
    }
  });
});

// Manejo de 404 para rutas inexistentes
app.use((req, res) => {
  res.status(404).json({ message: 'Ruta no encontrada' });
});

// Manejo genérico de errores 500
app.use((err, req, res, next) => {
  console.error('Error no controlado:', err);
  res.status(500).json({ message: 'Error interno del servidor' });
});

// Iniciar servidor si se ejecuta directamente
if (require.main === module) {
  app.listen(PORT, HOST, () => {
    console.log(`Servidor API iniciado en http://${HOST}:${PORT}`);
    console.log(`Endpoints disponibles en http://${HOST}:${PORT}/api/productos`);
  });
}

module.exports = app;
