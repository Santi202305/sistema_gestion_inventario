const db = require('./db');

const productosSemilla = [
  {
    nombre: 'Mouse Inalámbrico Ergonómico',
    codigo: 'TEC-001',
    descripcion: 'Mouse óptico 2.4GHz con sensor ajustable hasta 1600 DPI y batería recargable',
    precio: 45000.0,
    cantidad: 25,
    categoria: 'Tecnología',
  },
  {
    nombre: 'Teclado Mecánico RGB',
    codigo: 'TEC-002',
    descripcion: 'Teclado mecánico compacto con switches azules y retroiluminación personalizable',
    precio: 185000.0,
    cantidad: 14,
    categoria: 'Tecnología',
  },
  {
    nombre: 'Monitor LED 24 Pulgadas FHD',
    codigo: 'TEC-003',
    descripcion: 'Monitor panel IPS con resolución 1080p, tasa de refresco 75Hz y entradas HDMI/VGA',
    precio: 520000.0,
    cantidad: 8,
    categoria: 'Tecnología',
  },
  {
    nombre: 'Audífonos Bluetooth con Micrófono',
    codigo: 'ACC-001',
    descripcion: 'Diadema inalámbrica con cancelación pasiva de ruido y autonomía de 20 horas',
    precio: 98000.0,
    cantidad: 30,
    categoria: 'Accesorios',
  },
  {
    nombre: 'Cable HDMI 2.0 Trenzado 2m',
    codigo: 'ACC-002',
    descripcion: 'Cable de alta velocidad apantallado compatible con 4K Ultra HD y conectores dorados',
    precio: 22000.0,
    cantidad: 45,
    categoria: 'Accesorios',
  },
  {
    nombre: 'Resma de Papel Carta 75g',
    codigo: 'PAP-001',
    descripcion: 'Paquete de 500 hojas multiusos para impresión láser e inyección de tinta',
    precio: 18500.0,
    cantidad: 60,
    categoria: 'Papelería',
  },
  {
    nombre: 'Cuaderno Argollado 100 Hojas',
    codigo: 'PAP-002',
    descripcion: 'Cuaderno universitario de pasta dura plastificada con hojas cuadriculadas',
    precio: 9500.0,
    cantidad: 50,
    categoria: 'Papelería',
  },
  {
    nombre: 'Caja de Bolígrafos Tinta Negra 12u',
    codigo: 'PAP-003',
    descripcion: 'Bolígrafos punto fino 0.7mm con tinta gel de secado instantáneo',
    precio: 14000.0,
    cantidad: 35,
    categoria: 'Papelería',
  },
  {
    nombre: 'Alcohol Isopropílico 1 Litro',
    codigo: 'LIM-001',
    descripcion: 'Limpiador solvente al 99.8% puro para circuitos, pantallas y equipos electrónicos',
    precio: 28000.0,
    cantidad: 20,
    categoria: 'Limpieza',
  },
  {
    nombre: 'Kit Limpiador de Pantallas y Paño',
    codigo: 'LIM-002',
    descripcion: 'Solución antiestática de 250ml sin alcohol acompañada de toalla de microfibra',
    precio: 16500.0,
    cantidad: 28,
    categoria: 'Limpieza',
  },
  {
    nombre: 'Silla Ergonómica de Oficina',
    codigo: 'MUE-001',
    descripcion: 'Silla giratoria con soporte lumbar regulable, respaldo en malla y pistón clase 4',
    precio: 420000.0,
    cantidad: 6,
    categoria: 'Mobiliario',
  },
  {
    nombre: 'Soporte Elevador para Laptop',
    codigo: 'MUE-002',
    descripcion: 'Estructura en aleación de aluminio plegable con 6 posiciones de ajuste angular',
    precio: 65000.0,
    cantidad: 18,
    categoria: 'Mobiliario',
  },
];

function seed() {
  console.log('Iniciando poblamiento de base de datos (seed)...');

  const upsertStmt = db.prepare(`
    INSERT INTO productos (nombre, codigo, descripcion, precio, cantidad, categoria)
    VALUES (?, ?, ?, ?, ?, ?)
    ON CONFLICT(codigo) DO UPDATE SET
      nombre = excluded.nombre,
      descripcion = excluded.descripcion,
      precio = excluded.precio,
      cantidad = excluded.cantidad,
      categoria = excluded.categoria
  `);

  const runSeed = db.transaction((productos) => {
    for (const p of productos) {
      upsertStmt.run(p.nombre, p.codigo, p.descripcion, p.precio, p.cantidad, p.categoria);
    }
  });

  runSeed(productosSemilla);

  const total = db.prepare('SELECT COUNT(*) as count FROM productos').get().count;
  console.log(`Poblamiento finalizado con éxito. Total de productos en la base de datos: ${total}`);
}

seed();
