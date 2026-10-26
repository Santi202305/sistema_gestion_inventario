const path = require('path');
const Database = require('better-sqlite3');
require('dotenv').config({ path: path.resolve(__dirname, '../.env') });

const dbFileName = process.env.DB_FILE || 'database.sqlite';
const dbPath = path.isAbsolute(dbFileName)
  ? dbFileName
  : path.resolve(__dirname, '..', dbFileName);

const db = new Database(dbPath);

// Habilitar journal_mode WAL para rendimiento y concurrencia
db.pragma('journal_mode = WAL');

// Crear la tabla productos con su restricción UNIQUE en codigo
db.exec(`
  CREATE TABLE IF NOT EXISTS productos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL,
    codigo TEXT NOT NULL UNIQUE,
    descripcion TEXT,
    precio REAL NOT NULL,
    cantidad INTEGER NOT NULL,
    categoria TEXT NOT NULL
  );
`);

module.exports = db;
