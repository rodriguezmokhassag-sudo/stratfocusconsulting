// Mots de passe (scrypt), jetons de session, limitation de débit, en-têtes de sécurité.
const crypto = require('node:crypto');

function hashPassword(password) {
  const salt = crypto.randomBytes(16);
  const hash = crypto.scryptSync(password, salt, 64, { N: 16384, r: 8, p: 1 });
  return `scrypt$${salt.toString('base64')}$${hash.toString('base64')}`;
}

function verifyPassword(password, stored) {
  const [alg, salt, hash] = String(stored).split('$');
  if (alg !== 'scrypt' || !salt || !hash) return false;
  const expected = Buffer.from(hash, 'base64');
  const actual = crypto.scryptSync(password, Buffer.from(salt, 'base64'), expected.length, { N: 16384, r: 8, p: 1 });
  return crypto.timingSafeEqual(expected, actual);
}

const randomToken = (bytes = 32) => crypto.randomBytes(bytes).toString('base64url');
const sha256 = text => crypto.createHash('sha256').update(text).digest('hex');

// Limiteur en mémoire : `max` requêtes par fenêtre de `windowMs` et par clé (IP + route).
function rateLimit({ windowMs, max }) {
  const hits = new Map();
  setInterval(() => { const t = Date.now(); for (const [k, v] of hits) if (v.reset < t) hits.delete(k); }, windowMs).unref();
  return (req, res, next) => {
    const key = req.ip + '|' + req.path;
    const t = Date.now();
    const h = hits.get(key) || { n: 0, reset: t + windowMs };
    if (h.reset < t) { h.n = 0; h.reset = t + windowMs; }
    h.n++; hits.set(key, h);
    if (h.n > max) return res.status(429).json({ error: 'Trop de tentatives. Réessayez dans quelques minutes.' });
    next();
  };
}

function securityHeaders(req, res, next) {
  res.setHeader('X-Content-Type-Options', 'nosniff');
  res.setHeader('X-Frame-Options', 'DENY');
  res.setHeader('Referrer-Policy', 'strict-origin-when-cross-origin');
  res.setHeader('Permissions-Policy', 'camera=(), microphone=(), geolocation=()');
  res.setHeader('Content-Security-Policy', [
    "default-src 'self'",
    "img-src 'self' data: blob:",
    "style-src 'self'", "style-src-attr 'unsafe-inline'",
    "script-src 'self'",
    "connect-src 'self'",
    "frame-src https://www.youtube-nocookie.com https://player.vimeo.com https://iframe.mediadelivery.net https://*.cloudflarestream.com",
    "media-src 'self' https:",
    "form-action 'self' https://checkout.cinetpay.com",
    "base-uri 'self'", "object-src 'none'", "frame-ancestors 'none'"
  ].join('; '));
  next();
}

module.exports = { hashPassword, verifyPassword, randomToken, sha256, rateLimit, securityHeaders };
