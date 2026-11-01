// API apprenant et publique.
const express = require('express');
const crypto = require('node:crypto');
const db = require('./db');
const config = require('./config');
const auth = require('./auth');
const content = require('./content');
const pricing = require('./pricing');
const payments = require('./payments');
const pdf = require('./pdf');
const autoeval = require('../content/autoeval');
const { rateLimit, sha256 } = require('./security');

const router = express.Router();
const wrap = fn => (req, res, next) => Promise.resolve(fn(req, res, next)).catch(next);
const fail = (status, message) => Object.assign(new Error(message), { status });

/* ---------- Utilitaires ---------- */
function entitlementsOf(userId) {
  return db.all('SELECT id, scope, source, ref, starts_at, expires_at FROM entitlements WHERE user_id = ? AND (expires_at IS NULL OR expires_at > ?) ORDER BY id', [userId, db.now()]);
}
function publicUser(u) {
  if (!u) return null;
  return { id: u.id, email: u.email, fullName: u.full_name, phone: u.phone, country: u.country, role: u.role, zone: pricing.zoneOfCountry(u.country), entitlements: entitlementsOf(u.id) };
}
function moduleState(user, id, ctx) {
  const m = content.getModule(id);
  const done = user ? content.lessonsDoneList(user.id, id) : [];
  const best = user ? db.get('SELECT MAX(score) AS best, COUNT(*) AS attempts FROM quiz_attempts WHERE user_id=? AND module_id=?', [user.id, id]) : null;
  const passed = ctx.passed.has(id);
  const steps = (m.lessons || []).length + 1;
  const pct = m.status === 'complet' ? Math.round((done.length + (passed ? 1 : 0)) / steps * 100) : 0;
  return { lessonsDone: done, passed, best: best && best.best, attempts: best ? best.attempts : 0, pct, access: content.moduleAccess(user, id, ctx) };
}
function ctxFor(user) { return { passed: content.passedSet(user && user.id), scopes: user ? content.activeScopes(user.id) : new Set() }; }

function issueCertificate(user, kind, id) {
  const existing = db.get('SELECT * FROM certificates WHERE user_id=? AND kind=? AND target_id=?', [user.id, kind, id]);
  if (existing) return existing;
  let title, score = null;
  if (kind === 'module') {
    const m = content.getModule(id); if (!m) throw fail(404, 'Module introuvable.');
    const best = db.get('SELECT MAX(score) AS s FROM quiz_attempts WHERE user_id=? AND module_id=? AND passed=1', [user.id, id]);
    if (!best || best.s == null) throw fail(403, 'Validez le quiz de ce module pour obtenir l’attestation.');
    title = m.title; score = best.s;
  } else if (kind === 'track') {
    const t = content.getTrack(id); if (!t || t.free) throw fail(404, 'Parcours introuvable.');
    const passed = content.passedSet(user.id);
    if (!t.modules.every(x => passed.has(x))) throw fail(403, 'Validez tous les modules du parcours pour obtenir le certificat.');
    title = t.title;
    const avg = db.get(`SELECT AVG(s) AS a FROM (SELECT MAX(score) AS s FROM quiz_attempts WHERE user_id=? AND passed=1 AND module_id IN (${t.modules.map(() => '?').join(',')}) GROUP BY module_id)`, [user.id, ...t.modules]);
    score = avg && avg.a != null ? Math.round(avg.a) : null;
  } else throw fail(400, 'Type de certificat inconnu.');
  const ref = `STFC-${new Date().getFullYear()}-${crypto.randomBytes(4).toString('hex').toUpperCase().slice(0, 6)}`;
  db.run('INSERT INTO certificates (ref, user_id, kind, target_id, full_name, title, score, issued_at) VALUES (?,?,?,?,?,?,?,?)', [ref, user.id, kind, id, user.full_name, title, score, db.now()]);
  return db.get('SELECT * FROM certificates WHERE ref = ?', [ref]);
}
function certMeta(c) {
  if (c.kind === 'module') { const m = content.getModule(c.target_id); const t = content.trackOf(c.target_id); return { subtitle: t.free ? 'Module découverte' : 'Parcours ' + t.title, skills: (m && m.skills) || [] }; }
  const t = content.getTrack(c.target_id);
  return { subtitle: 'Parcours complet', skills: t.modules.flatMap(x => (content.getModule(x).skills || [])).slice(0, 6) };
}

/* ---------- Configuration publique ---------- */
router.get('/config', (req, res) => {
  res.json({
    brand: config.brand, org: config.org, passMark: config.passMark, contact: config.contact, paymentsLive: payments.live(),
    zones: Object.entries(pricing.ZONES).map(([id, z]) => ({ id, label: z.label, countries: z.countries }))
  });
});

/* ---------- Authentification ---------- */
const authLimit = rateLimit({ windowMs: 15 * 60000, max: 20 });
router.post('/auth/register', authLimit, (req, res) => {
  const u = auth.register(req.body || {});
  auth.createSession(res, u.id);
  res.status(201).json({ user: publicUser(u) });
});
router.post('/auth/login', authLimit, (req, res) => {
  const u = auth.login(req.body || {});
  auth.createSession(res, u.id);
  res.json({ user: publicUser(u) });
});
router.post('/auth/logout', (req, res) => { auth.destroySession(req, res); res.json({ ok: true }); });
router.get('/me', (req, res) => res.json({ user: publicUser(req.user) }));
router.patch('/me', auth.requireUser, (req, res) => {
  const b = req.body || {};
  const fullName = b.fullName != null ? String(b.fullName).trim().replace(/\s+/g, ' ') : req.user.full_name;
  if (fullName.length < 3 || fullName.length > 80) throw fail(400, 'Nom invalide.');
  db.run('UPDATE users SET full_name=?, phone=?, country=? WHERE id=?', [fullName, b.phone != null ? String(b.phone).trim() || null : req.user.phone, b.country != null ? String(b.country).toUpperCase().slice(0, 5) : req.user.country, req.user.id]);
  res.json({ user: publicUser(db.get('SELECT * FROM users WHERE id=?', [req.user.id])) });
});
router.post('/me/password', auth.requireUser, authLimit, (req, res) => {
  const u = db.get('SELECT * FROM users WHERE id=?', [req.user.id]);
  if (!auth.verifyPassword(String(req.body.current || ''), u.password_hash)) throw fail(400, 'Mot de passe actuel incorrect.');
  if (String(req.body.next || '').length < 8) throw fail(400, 'Le nouveau mot de passe doit contenir au moins 8 caractères.');
  db.run('UPDATE users SET password_hash=? WHERE id=?', [auth.hashPassword(req.body.next), u.id]);
  res.json({ ok: true });
});

/* ---------- Catalogue et modules ---------- */
router.get('/catalog', (req, res) => {
  const ctx = ctxFor(req.user);
  const zone = pricing.ZONES[req.query.zone] ? req.query.zone : req.user ? pricing.zoneOfCountry(req.user.country) : 'uemoa';
  const tracks = content.tracks.map(t => ({
    id: t.id, title: t.title, free: !!t.free, level: t.level, audience: t.audience, duration: t.duration, desc: t.desc, objectives: t.objectives, certificate: t.certificate,
    unlocked: content.hasTrackAccess(req.user, t, ctx.scopes),
    price: t.free ? null : pricing.quote('track:' + t.id, zone),
    modules: t.modules.map(id => { const m = content.getModule(id); return { id, title: m.title, status: m.status, duration: m.duration, summary: m.summary, lessonCount: (m.lessons || []).length, quizCount: (m.quiz || []).length, ...moduleState(req.user, id, ctx) }; })
  }));
  res.json({ zone, tracks, prices: pricing.catalogPrices(zone) });
});

router.get('/modules/:id', (req, res) => {
  const m = content.getModule(req.params.id); if (!m) throw fail(404, 'Module introuvable.');
  const ctx = ctxFor(req.user);
  const state = moduleState(req.user, m.id, ctx);
  const t = content.trackOf(m.id);
  res.json({ module: content.publicModule(m, state.access.ok), track: { id: t.id, title: t.title, free: !!t.free, modules: t.modules }, state, passMark: config.passMark });
});

router.post('/modules/:id/lessons/:i/complete', auth.requireUser, (req, res) => {
  const m = content.getModule(req.params.id); if (!m) throw fail(404, 'Module introuvable.');
  if (!content.moduleAccess(req.user, m.id).ok) throw fail(403, 'Accès non autorisé.');
  const i = Number(req.params.i);
  if (!Number.isInteger(i) || i < 0 || i >= m.lessons.length) throw fail(400, 'Leçon invalide.');
  db.run('INSERT OR IGNORE INTO progress (user_id, module_id, lesson_index, completed_at) VALUES (?,?,?,?)', [req.user.id, m.id, i, db.now()]);
  res.json({ lessonsDone: content.lessonsDoneList(req.user.id, m.id) });
});

router.post('/modules/:id/quiz', auth.requireUser, (req, res) => {
  const m = content.getModule(req.params.id); if (!m) throw fail(404, 'Module introuvable.');
  if (!content.moduleAccess(req.user, m.id).ok) throw fail(403, 'Accès non autorisé.');
  if (content.lessonsDoneList(req.user.id, m.id).length < m.lessons.length) throw fail(409, 'Terminez toutes les leçons avant de passer le quiz.');
  const answers = (req.body && req.body.answers) || {};
  const results = m.quiz.map((q, i) => ({ i, chosen: answers[i] == null ? null : Number(answers[i]), correct: q.a, ok: Number(answers[i]) === q.a, why: q.why, answer: q.options[q.a] }));
  const score = Math.round(results.filter(r => r.ok).length / m.quiz.length * 100);
  const passed = score >= config.passMark;
  db.run('INSERT INTO quiz_attempts (user_id, module_id, score, passed, answers, created_at) VALUES (?,?,?,?,?,?)', [req.user.id, m.id, score, passed ? 1 : 0, JSON.stringify(answers), db.now()]);
  const t = content.trackOf(m.id);
  const nextId = t.modules.slice(t.modules.indexOf(m.id) + 1).find(x => content.getModule(x).status === 'complet') || null;
  const passedAll = content.passedSet(req.user.id);
  res.json({ score, passed, passMark: config.passMark, results, nextModule: nextId, trackComplete: !t.free && t.modules.every(x => passedAll.has(x)) });
});

router.get('/modules/:id/pdf', (req, res) => {
  const m = content.getModule(req.params.id); if (!m) throw fail(404, 'Module introuvable.');
  if (!content.moduleAccess(req.user, m.id).ok) throw fail(403, 'Accès non autorisé.');
  res.setHeader('Content-Type', 'application/pdf');
  res.setHeader('Content-Disposition', `attachment; filename="STFC-${m.id}-cours.pdf"`);
  pdf.course(m, content.trackOf(m.id).title, req.user && req.user.full_name).pipe(res);
});

/* ---------- Tableau de bord ---------- */
router.get('/dashboard', auth.requireUser, (req, res) => {
  const ctx = ctxFor(req.user);
  const tracks = content.tracks.map(t => {
    const mods = t.modules.map(id => ({ id, title: content.getModule(id).title, ...moduleState(req.user, id, ctx) }));
    const passed = mods.filter(x => x.passed).length;
    const next = mods.find(x => x.access.ok && !x.passed);
    return { id: t.id, title: t.title, free: !!t.free, level: t.level, unlocked: content.hasTrackAccess(req.user, t, ctx.scopes), total: mods.length, passed, pct: Math.round(passed / mods.length * 100), next: next ? { id: next.id, title: next.title, pct: next.pct } : null, started: mods.some(x => x.pct > 0) };
  });
  const certificates = db.all('SELECT ref, kind, target_id, full_name, title, score, issued_at FROM certificates WHERE user_id=? ORDER BY issued_at DESC', [req.user.id]);
  const eligible = [];
  content.tracks.forEach(t => {
    t.modules.forEach(id => { if (ctx.passed.has(id) && !certificates.find(c => c.kind === 'module' && c.target_id === id)) eligible.push({ kind: 'module', id, title: content.getModule(id).title }); });
    if (!t.free && t.modules.every(id => ctx.passed.has(id)) && !certificates.find(c => c.kind === 'track' && c.target_id === t.id)) eligible.push({ kind: 'track', id: t.id, title: 'Parcours ' + t.title });
  });
  const attempts = db.all('SELECT module_id, score, passed, created_at FROM quiz_attempts WHERE user_id=? ORDER BY id DESC LIMIT 8', [req.user.id]);
  const assessment = db.get('SELECT score, level, created_at FROM assessments WHERE user_id=? ORDER BY id DESC LIMIT 1', [req.user.id]);
  const lessons = db.get('SELECT COUNT(*) AS n FROM progress WHERE user_id=?', [req.user.id]).n;
  res.json({ user: publicUser(req.user), tracks, certificates, eligible, attempts, assessment, stats: { lessons, modulesPassed: ctx.passed.size, certificates: certificates.length } });
});

/* ---------- Certificats ---------- */
router.post('/certificates', auth.requireUser, (req, res) => {
  const { kind, id } = req.body || {};
  res.status(201).json({ certificate: issueCertificate(req.user, kind, String(id || '')) });
});
router.get('/certificates/:ref/pdf', auth.requireUser, (req, res) => {
  const c = db.get('SELECT * FROM certificates WHERE ref = ?', [req.params.ref]);
  if (!c || (c.user_id !== req.user.id && req.user.role !== 'admin')) throw fail(404, 'Certificat introuvable.');
  res.setHeader('Content-Type', 'application/pdf');
  res.setHeader('Content-Disposition', `${req.query.inline ? 'inline' : 'attachment'}; filename="${c.ref}.pdf"`);
  pdf.certificate(c, certMeta(c)).pipe(res);
});
router.get('/verify/:ref', rateLimit({ windowMs: 60000, max: 30 }), (req, res) => {
  const c = db.get('SELECT ref, kind, target_id, full_name, title, score, issued_at FROM certificates WHERE ref = ?', [String(req.params.ref).toUpperCase()]);
  if (!c) return res.status(404).json({ valid: false });
  res.json({ valid: true, certificate: { ...c, ...certMeta(c) } });
});

/* ---------- Tarifs et paiements ---------- */
router.get('/prices', (req, res) => {
  const zone = pricing.ZONES[req.query.zone] ? req.query.zone : 'uemoa';
  res.json({ zone, prices: pricing.catalogPrices(zone) });
});
router.post('/payments/init', auth.requireUser, rateLimit({ windowMs: 60000, max: 10 }), wrap(async (req, res) => {
  const { product, zone, plan, phone, city } = req.body || {};
  if (!pricing.quote(product, zone)) throw fail(400, 'Offre inconnue.');
  res.json(await payments.initPayment(req.user, { product, zone: pricing.ZONES[zone] ? zone : pricing.zoneOfCountry(req.user.country), plan, phone, city }));
}));
router.get('/payments/:tx', auth.requireUser, wrap(async (req, res) => {
  let p = db.get('SELECT * FROM payments WHERE transaction_id=? AND user_id=?', [req.params.tx, req.user.id]);
  if (!p) throw fail(404, 'Transaction introuvable.');
  if (p.status === 'pending') p = await payments.confirm(p.transaction_id);
  res.json({ payment: { transactionId: p.transaction_id, product: p.product, label: pricing.productLabel(p.product), plan: p.plan, amount: p.amount, currency: p.currency, status: p.status, provider: p.provider, createdAt: p.created_at } });
}));
router.post('/payments/:tx/simulate', auth.requireUser, (req, res) => {
  if (payments.live()) throw fail(403, 'Simulation désactivée en production.');
  const p = payments.simulate(req.params.tx, req.user.id, !!(req.body && req.body.accepted));
  res.json({ status: p.status });
});
// Notification CinetPay (GET ou POST, formulaire). On revérifie toujours auprès de CinetPay.
router.all('/payments/notify', express.urlencoded({ extended: false }), wrap(async (req, res) => {
  const tx = (req.body && req.body.cpm_trans_id) || req.query.cpm_trans_id;
  if (tx) await payments.confirm(String(tx)).catch(e => console.error('Vérification CinetPay :', e.message));
  res.status(200).send('OK');
}));

/* ---------- Codes d'accès ---------- */
router.post('/codes/redeem', auth.requireUser, rateLimit({ windowMs: 15 * 60000, max: 10 }), (req, res) => {
  const code = String((req.body && req.body.code) || '').trim().toUpperCase().replace(/\s+/g, '');
  const h = sha256(code);
  const result = db.tx(() => {
    const c = db.get('SELECT * FROM access_codes WHERE code_hash = ?', [h]);
    if (!c) throw fail(404, 'Code invalide. Vérifiez la saisie (tirets compris).');
    if (db.get('SELECT 1 AS x FROM code_redemptions WHERE code_hash=? AND user_id=?', [h, req.user.id])) throw fail(409, 'Vous avez déjà utilisé ce code.');
    if (c.uses >= c.max_uses) throw fail(410, 'Ce code a déjà été utilisé.');
    db.run('UPDATE access_codes SET uses = uses + 1 WHERE code_hash = ?', [h]);
    db.run('INSERT INTO code_redemptions (code_hash, user_id, redeemed_at) VALUES (?,?,?)', [h, req.user.id, db.now()]);
    const expires = c.days ? new Date(Date.now() + c.days * 86400000).toISOString() : null;
    db.run('INSERT INTO entitlements (user_id, scope, source, ref, starts_at, expires_at) VALUES (?,?,?,?,?,?)', [req.user.id, c.scope, 'code', c.label || code.slice(0, 4), db.now(), expires]);
    return { scope: c.scope, expires };
  });
  res.json(result);
});

/* ---------- Auto-évaluation (gratuite, sans compte) ---------- */
router.get('/autoeval', (req, res) => res.json({ title: autoeval.title, intro: autoeval.intro, questions: autoeval.questions.map(q => ({ q: q.q, dim: q.dim, options: q.options.map(o => o.x) })) }));
router.post('/autoeval', (req, res) => {
  const answers = (req.body && req.body.answers) || {};
  const result = autoeval.evaluate(answers);
  db.run('INSERT INTO assessments (user_id, score, level, created_at) VALUES (?,?,?,?)', [req.user ? req.user.id : null, result.score, result.track, db.now()]);
  res.json(result);
});

module.exports = { router, issueCertificate };
