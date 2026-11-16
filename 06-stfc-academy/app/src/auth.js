// Comptes, sessions (cookie httpOnly) et contrôle des rôles.
const db = require('./db');
const config = require('./config');
const { hashPassword, verifyPassword, randomToken, sha256 } = require('./security');

const COOKIE = 'stfc_session';

function parseCookies(header) {
  const out = {};
  String(header || '').split(';').forEach(p => { const i = p.indexOf('='); if (i > 0) out[p.slice(0, i).trim()] = decodeURIComponent(p.slice(i + 1).trim()); });
  return out;
}

function createSession(res, userId) {
  const token = randomToken();
  const expires = new Date(Date.now() + config.sessionDays * 86400000);
  db.run('INSERT INTO sessions (token_hash, user_id, created_at, expires_at) VALUES (?,?,?,?)', [sha256(token), userId, db.now(), expires.toISOString()]);
  res.setHeader('Set-Cookie', `${COOKIE}=${token}; HttpOnly; Path=/; SameSite=Lax; Expires=${expires.toUTCString()}${config.isProd ? '; Secure' : ''}`);
}

function destroySession(req, res) {
  const token = parseCookies(req.headers.cookie)[COOKIE];
  if (token) db.run('DELETE FROM sessions WHERE token_hash = ?', [sha256(token)]);
  res.setHeader('Set-Cookie', `${COOKIE}=; HttpOnly; Path=/; SameSite=Lax; Max-Age=0`);
}

// Attache req.user si une session valide existe
function loadUser(req, res, next) {
  const token = parseCookies(req.headers.cookie)[COOKIE];
  req.user = null;
  if (token) {
    const row = db.get(`SELECT u.* FROM sessions s JOIN users u ON u.id = s.user_id
                        WHERE s.token_hash = ? AND s.expires_at > ? AND u.disabled = 0`, [sha256(token), db.now()]);
    if (row) {
      delete row.password_hash;
      req.user = row;
      if (!row.last_seen_at || Date.now() - Date.parse(row.last_seen_at) > 3600000) db.run('UPDATE users SET last_seen_at=? WHERE id=?', [db.now(), row.id]);
    }
  }
  next();
}

const requireUser = (req, res, next) => (req.user ? next() : res.status(401).json({ error: 'Connectez-vous pour continuer.' }));
const requireRole = (...roles) => (req, res, next) => {
  if (!req.user) return res.status(401).json({ error: 'Connectez-vous pour continuer.' });
  if (!roles.includes(req.user.role)) return res.status(403).json({ error: 'Accès réservé.' });
  next();
};

const EMAIL = /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/;

function register({ email, password, fullName, phone, country }) {
  email = String(email || '').trim().toLowerCase();
  fullName = String(fullName || '').trim().replace(/\s+/g, ' ');
  if (!EMAIL.test(email)) throw Object.assign(new Error('Adresse e-mail invalide.'), { status: 400 });
  if (String(password || '').length < 8) throw Object.assign(new Error('Le mot de passe doit contenir au moins 8 caractères.'), { status: 400 });
  if (fullName.length < 3 || fullName.length > 80) throw Object.assign(new Error('Indiquez vos prénom et nom (tels qu’ils apparaîtront sur vos certificats).'), { status: 400 });
  if (db.get('SELECT id FROM users WHERE email = ?', [email])) throw Object.assign(new Error('Un compte existe déjà avec cette adresse.'), { status: 409 });
  const r = db.run('INSERT INTO users (email, phone, password_hash, full_name, country, role, created_at) VALUES (?,?,?,?,?,?,?)',
    [email, String(phone || '').trim() || null, hashPassword(password), fullName, String(country || '').toUpperCase().slice(0, 5) || null, 'learner', db.now()]);
  return db.get('SELECT * FROM users WHERE id = ?', [r.lastId]);
}

function login({ email, password }) {
  const u = db.get('SELECT * FROM users WHERE email = ?', [String(email || '').trim().toLowerCase()]);
  if (!u || u.disabled || !verifyPassword(String(password || ''), u.password_hash)) throw Object.assign(new Error('E-mail ou mot de passe incorrect.'), { status: 401 });
  return u;
}

function ensureAdmin() {
  if (db.get("SELECT id FROM users WHERE role = 'admin'")) return null;
  const { email, password } = config.admin;
  if (!email || !password) return null;
  db.run('INSERT INTO users (email, password_hash, full_name, role, created_at) VALUES (?,?,?,?,?)', [email.toLowerCase(), hashPassword(password), 'Administrateur STFC', 'admin', db.now()]);
  return email;
}

module.exports = { loadUser, requireUser, requireRole, register, login, createSession, destroySession, ensureAdmin, hashPassword, verifyPassword };
