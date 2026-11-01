// Adaptateur de base de données.
// Toute l'application passe par ces 4 fonctions (all, get, run, tx) avec des paramètres « ? ».
// Pour passer à PostgreSQL / Supabase : réimplémenter ce fichier avec le pilote `pg`
// (remplacer « ? » par $1, $2…) et rendre les fonctions asynchrones. Le reste du code SQL est portable.
const fs = require('node:fs');
const path = require('node:path');
const { DatabaseSync } = require('node:sqlite');
const config = require('./config');

let db;

function open(file = config.dbFile) {
  if (file !== ':memory:') fs.mkdirSync(path.dirname(file), { recursive: true });
  db = new DatabaseSync(file);
  db.exec('PRAGMA journal_mode = WAL; PRAGMA foreign_keys = ON; PRAGMA busy_timeout = 5000;');
  db.exec(fs.readFileSync(path.join(__dirname, '..', 'db', 'schema.sql'), 'utf8'));
  return db;
}

const norm = row => (row ? Object.assign({}, row) : row);
const all = (sql, params = []) => db.prepare(sql).all(...params).map(norm);
const get = (sql, params = []) => norm(db.prepare(sql).get(...params));
const run = (sql, params = []) => {
  const r = db.prepare(sql).run(...params);
  return { changes: Number(r.changes), lastId: Number(r.lastInsertRowid) };
};
function tx(fn) {
  db.exec('BEGIN');
  try { const out = fn(); db.exec('COMMIT'); return out; }
  catch (e) { db.exec('ROLLBACK'); throw e; }
}
const now = () => new Date().toISOString();

module.exports = { open, all, get, run, tx, now, close: () => db && db.close() };
