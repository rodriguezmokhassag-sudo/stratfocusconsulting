// Back-office : statistiques, utilisateurs, paiements, contenus, codes d'accès, certificats.
// Rôles : admin (tout) ; trainer (contenus + statistiques pédagogiques).
const express = require('express');
const crypto = require('node:crypto');
const db = require('./db');
const content = require('./content');
const pricing = require('./pricing');
const payments = require('./payments');
const { requireRole } = require('./auth');
const { sha256 } = require('./security');

const router = express.Router();
const fail = (status, message) => Object.assign(new Error(message), { status });
const staff = requireRole('admin', 'trainer');
const admin = requireRole('admin');
const VALID_SCOPES = () => ['all', ...content.tracks.filter(t => !t.free).map(t => 'track:' + t.id)];
const daysAgo = d => new Date(Date.now() - d * 86400000).toISOString();

/* ---------- Statistiques ---------- */
router.get('/stats', staff, (req, res) => {
  const n = (sql, p = []) => db.get(sql, p).n || 0;
  const learners = n("SELECT COUNT(*) AS n FROM users WHERE role='learner'");
  const paying = n("SELECT COUNT(DISTINCT e.user_id) AS n FROM entitlements e JOIN users u ON u.id=e.user_id WHERE u.role='learner' AND e.source IN ('payment','code')");
  const attempts = db.get('SELECT COUNT(*) AS n, SUM(passed) AS ok FROM quiz_attempts');
  const firstTry = db.get(`SELECT COUNT(*) AS n, SUM(passed) AS ok FROM quiz_attempts a WHERE a.id = (SELECT MIN(id) FROM quiz_attempts b WHERE b.user_id=a.user_id AND b.module_id=a.module_id)`);
  const started = n('SELECT COUNT(*) AS n FROM (SELECT DISTINCT user_id, module_id FROM progress)');
  const completed = n('SELECT COUNT(*) AS n FROM (SELECT DISTINCT user_id, module_id FROM quiz_attempts WHERE passed=1)');
  const cohort = n("SELECT COUNT(*) AS n FROM users WHERE role='learner' AND created_at <= ?", [daysAgo(30)]);
  const retained = n("SELECT COUNT(*) AS n FROM users WHERE role='learner' AND created_at <= ? AND last_seen_at >= ?", [daysAgo(30), daysAgo(30)]);

  const modules = content.tracks.flatMap(t => t.modules.map(id => {
    const s = n('SELECT COUNT(DISTINCT user_id) AS n FROM progress WHERE module_id=?', [id]);
    const p = n('SELECT COUNT(DISTINCT user_id) AS n FROM quiz_attempts WHERE module_id=? AND passed=1', [id]);
    const a = db.get('SELECT COUNT(*) AS n, AVG(score) AS avg FROM quiz_attempts WHERE module_id=?', [id]);
    return { id, track: t.title, title: content.getModule(id).title, started: s, passed: p, completion: s ? Math.round(p / s * 100) : null, attempts: a.n, avgScore: a.avg == null ? null : Math.round(a.avg) };
  }));

  const out = {
    users: { learners, new7: n("SELECT COUNT(*) AS n FROM users WHERE role='learner' AND created_at >= ?", [daysAgo(7)]), new30: n("SELECT COUNT(*) AS n FROM users WHERE role='learner' AND created_at >= ?", [daysAgo(30)]),
      active7: n("SELECT COUNT(*) AS n FROM users WHERE role='learner' AND last_seen_at >= ?", [daysAgo(7)]), active30: n("SELECT COUNT(*) AS n FROM users WHERE role='learner' AND last_seen_at >= ?", [daysAgo(30)]) },
    kpi: {
      completionRate: started ? Math.round(completed / started * 100) : null,
      quizPassRate: attempts.n ? Math.round((attempts.ok || 0) / attempts.n * 100) : null,
      firstTryPassRate: firstTry.n ? Math.round((firstTry.ok || 0) / firstTry.n * 100) : null,
      conversion: learners ? Math.round(paying / learners * 1000) / 10 : null,
      retention30: cohort ? Math.round(retained / cohort * 100) : null,
      certificates: n('SELECT COUNT(*) AS n FROM certificates'), payingLearners: paying
    },
    assessments: db.all('SELECT level, COUNT(*) AS n FROM assessments GROUP BY level ORDER BY n DESC'),
    countries: db.all("SELECT COALESCE(country,'?') AS country, COUNT(*) AS n FROM users WHERE role='learner' GROUP BY country ORDER BY n DESC LIMIT 12"),
    modules
  };
  if (req.user.role === 'admin') {
    out.revenue = {
      totalXof: n("SELECT COALESCE(SUM(amount_xof),0) AS n FROM payments WHERE status='accepted'"),
      last30Xof: n("SELECT COALESCE(SUM(amount_xof),0) AS n FROM payments WHERE status='accepted' AND updated_at >= ?", [daysAgo(30)]),
      byMonth: db.all("SELECT substr(updated_at,1,7) AS month, SUM(amount_xof) AS xof, COUNT(*) AS n FROM payments WHERE status='accepted' GROUP BY month ORDER BY month DESC LIMIT 12"),
      byProduct: db.all("SELECT product, COUNT(*) AS n, SUM(amount_xof) AS xof FROM payments WHERE status='accepted' GROUP BY product ORDER BY xof DESC").map(r => ({ ...r, label: pricing.productLabel(r.product) })),
      pending: n("SELECT COUNT(*) AS n FROM payments WHERE status='pending'")
    };
  }
  res.json(out);
});

/* ---------- Utilisateurs ---------- */
router.get('/users', admin, (req, res) => {
  const q = '%' + String(req.query.q || '').trim().toLowerCase() + '%';
  const page = Math.max(0, Number(req.query.page) || 0);
  const rows = db.all(`SELECT u.id, u.email, u.full_name, u.phone, u.country, u.role, u.disabled, u.created_at, u.last_seen_at,
      (SELECT COUNT(DISTINCT module_id) FROM quiz_attempts a WHERE a.user_id=u.id AND a.passed=1) AS modules_passed,
      (SELECT GROUP_CONCAT(scope) FROM entitlements e WHERE e.user_id=u.id AND (e.expires_at IS NULL OR e.expires_at > ?)) AS scopes
    FROM users u WHERE lower(u.email) LIKE ? OR lower(u.full_name) LIKE ? OR COALESCE(u.phone,'') LIKE ? ORDER BY u.id DESC LIMIT 50 OFFSET ?`, [db.now(), q, q, q, page * 50]);
  res.json({ users: rows, page });
});
router.get('/users/:id', admin, (req, res) => {
  const u = db.get('SELECT id, email, full_name, phone, country, role, disabled, created_at, last_seen_at FROM users WHERE id=?', [req.params.id]);
  if (!u) throw fail(404, 'Utilisateur introuvable.');
  res.json({ user: u,
    entitlements: db.all('SELECT * FROM entitlements WHERE user_id=? ORDER BY id DESC', [u.id]),
    payments: db.all('SELECT transaction_id, product, plan, amount, currency, status, provider, method, created_at FROM payments WHERE user_id=? ORDER BY id DESC', [u.id]),
    certificates: db.all('SELECT ref, kind, target_id, title, score, issued_at FROM certificates WHERE user_id=? ORDER BY issued_at DESC', [u.id]),
    attempts: db.all('SELECT module_id, score, passed, created_at FROM quiz_attempts WHERE user_id=? ORDER BY id DESC LIMIT 30', [u.id]) });
});
router.patch('/users/:id', admin, (req, res) => {
  const u = db.get('SELECT * FROM users WHERE id=?', [req.params.id]); if (!u) throw fail(404, 'Utilisateur introuvable.');
  const { role, disabled } = req.body || {};
  if (role && !['learner', 'trainer', 'admin'].includes(role)) throw fail(400, 'Rôle invalide.');
  if (u.id === req.user.id && (role && role !== 'admin' || disabled)) throw fail(400, 'Vous ne pouvez pas retirer vos propres droits.');
  db.run('UPDATE users SET role=?, disabled=? WHERE id=?', [role || u.role, disabled == null ? u.disabled : disabled ? 1 : 0, u.id]);
  if (disabled) db.run('DELETE FROM sessions WHERE user_id=?', [u.id]);
  res.json({ ok: true });
});
router.post('/users/:id/grant', admin, (req, res) => {
  const { scope, days } = req.body || {};
  if (!VALID_SCOPES().includes(scope)) throw fail(400, 'Accès invalide.');
  if (!db.get('SELECT id FROM users WHERE id=?', [req.params.id])) throw fail(404, 'Utilisateur introuvable.');
  const expires = days ? new Date(Date.now() + Number(days) * 86400000).toISOString() : null;
  db.run('INSERT INTO entitlements (user_id, scope, source, ref, starts_at, expires_at) VALUES (?,?,?,?,?,?)', [req.params.id, scope, 'admin', 'par ' + req.user.email, db.now(), expires]);
  res.status(201).json({ ok: true });
});
router.delete('/entitlements/:id', admin, (req, res) => {
  db.run('DELETE FROM entitlements WHERE id=?', [req.params.id]);
  res.json({ ok: true });
});

/* ---------- Paiements ---------- */
router.get('/payments', admin, (req, res) => {
  const status = ['pending', 'accepted', 'refused'].includes(req.query.status) ? req.query.status : null;
  const rows = db.all(`SELECT p.transaction_id, p.product, p.plan, p.amount, p.currency, p.amount_xof, p.zone, p.provider, p.status, p.method, p.created_at, p.updated_at, u.email, u.full_name
    FROM payments p JOIN users u ON u.id=p.user_id ${status ? 'WHERE p.status=?' : ''} ORDER BY p.id DESC LIMIT 200`, status ? [status] : []);
  res.json({ payments: rows.map(r => ({ ...r, label: pricing.productLabel(r.product) })), live: payments.live() });
});
router.post('/payments/:tx/recheck', admin, async (req, res, next) => {
  try { const p = await payments.confirm(req.params.tx); res.json({ status: p && p.status }); } catch (e) { next(e); }
});

/* ---------- Contenus ---------- */
router.get('/modules', staff, (req, res) => {
  res.json({ tracks: content.tracks.map(t => ({ id: t.id, title: t.title, modules: t.modules.map(id => { const m = content.getModule(id); return { id, title: m.title, status: m.status, lessons: (m.lessons || []).length, quiz: (m.quiz || []).length, updatedAt: m.updatedAt }; }) })) });
});
router.get('/modules/:id', staff, (req, res) => {
  const m = content.getModule(req.params.id); if (!m) throw fail(404, 'Module introuvable.');
  const { trackId, updatedAt, ...data } = m;
  res.json({ module: data, trackId, updatedAt });
});
const BLOCK_TYPES = ['p', 'h', 'list', 'steps', 'table', 'matrix', 'flow', 'funnel', 'case', 'tip', 'action'];
function validateModule(d) {
  const errs = [];
  if (!d || typeof d !== 'object') return ['Format invalide.'];
  if (!d.title || String(d.title).length < 3) errs.push('Titre obligatoire.');
  if (!Array.isArray(d.lessons)) errs.push('« lessons » doit être une liste.');
  if (!Array.isArray(d.quiz)) errs.push('« quiz » doit être une liste.');
  (d.lessons || []).forEach((l, i) => {
    if (!l.title) errs.push(`Leçon ${i + 1} : titre manquant.`);
    (l.blocks || []).forEach((b, k) => { if (!BLOCK_TYPES.includes(b.t)) errs.push(`Leçon ${i + 1}, bloc ${k + 1} : type « ${b.t} » inconnu.`); });
  });
  (d.quiz || []).forEach((q, i) => {
    if (!q.q || !Array.isArray(q.options) || q.options.length < 2) errs.push(`Question ${i + 1} : énoncé ou options manquants.`);
    else if (!Number.isInteger(q.a) || q.a < 0 || q.a >= q.options.length) errs.push(`Question ${i + 1} : index de bonne réponse « a » invalide.`);
  });
  if (d.status === 'complet' && (!(d.lessons || []).length || (d.quiz || []).length < 5)) errs.push('Un module « complet » doit avoir au moins une leçon et 5 questions de quiz.');
  if (d.video && d.video.src && !/^https:\/\/(www\.youtube-nocookie\.com|player\.vimeo\.com|iframe\.mediadelivery\.net|customer-[\w-]+\.cloudflarestream\.com)\//.test(d.video.src)) errs.push('URL vidéo non autorisée (YouTube nocookie, Vimeo, Bunny Stream ou Cloudflare Stream).');
  return errs;
}
router.put('/modules/:id', staff, (req, res) => {
  if (!content.getModule(req.params.id)) throw fail(404, 'Module introuvable.');
  const data = { ...(req.body && req.body.module), id: req.params.id };
  const errs = validateModule(data);
  if (errs.length) return res.status(400).json({ error: errs.join(' '), errors: errs });
  res.json({ module: content.saveModule(req.params.id, data, req.user.id) });
});

/* ---------- Codes d'accès ---------- */
const ALPHA = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
const block = () => Array.from(crypto.randomBytes(4), b => ALPHA[b % ALPHA.length]).join('');
router.get('/codes', admin, (req, res) => {
  res.json({ codes: db.all('SELECT substr(code_hash,1,10) AS id, scope, label, max_uses, uses, days, created_at FROM access_codes ORDER BY created_at DESC LIMIT 300') });
});
router.post('/codes', admin, (req, res) => {
  const { scope, count = 1, days = null, maxUses = 1, label = '' } = req.body || {};
  if (!VALID_SCOPES().includes(scope)) throw fail(400, 'Accès invalide.');
  const total = Math.min(500, Math.max(1, Number(count) || 1));
  const prefix = scope === 'all' ? 'PASS' : { 'track:commercial': 'COM', 'track:chef-equipe': 'CEQ', 'track:responsable': 'RES', 'track:directeur': 'DIR' }[scope];
  const codes = db.tx(() => Array.from({ length: total }, () => {
    const code = `${prefix}-${block()}-${block()}`;
    db.run('INSERT INTO access_codes (code_hash, scope, label, max_uses, uses, days, created_by, created_at) VALUES (?,?,?,?,0,?,?,?)', [sha256(code), scope, String(label).slice(0, 80) || null, Math.max(1, Number(maxUses) || 1), days ? Number(days) : null, req.user.id, db.now()]);
    return code;
  }));
  res.status(201).json({ codes }); // les codes en clair ne sont montrés qu'une seule fois
});

/* ---------- Certificats ---------- */
router.get('/certificates', admin, (req, res) => {
  res.json({ certificates: db.all('SELECT c.ref, c.kind, c.target_id, c.full_name, c.title, c.score, c.issued_at, u.email FROM certificates c JOIN users u ON u.id=c.user_id ORDER BY c.issued_at DESC LIMIT 300') });
});

module.exports = { router, validateModule };
