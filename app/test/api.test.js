// Tests de bout en bout de l'API (base en mémoire, paiements en simulation).
const { test, before, after } = require('node:test');
const assert = require('node:assert/strict');
const { createApp } = require('../server');
const tracks = require('../content/tracks');

let server, base;
before(async () => {
  process.env.CINETPAY_API_KEY = ''; // force le mode simulation
  server = createApp({ dbFile: ':memory:' }).listen(0);
  await new Promise(r => server.once('listening', r));
  base = `http://localhost:${server.address().port}/api`;
});
after(() => server.close());

// Mini-client HTTP qui conserve le cookie de session
function client() {
  let cookie = '';
  const call = async (method, path, body, raw) => {
    const res = await fetch(base + path, { method, headers: { ...(body !== undefined ? { 'Content-Type': 'application/json' } : {}), ...(cookie ? { Cookie: cookie } : {}) }, body: body !== undefined ? JSON.stringify(body) : undefined });
    const set = res.headers.get('set-cookie'); if (set) cookie = set.split(';')[0];
    if (raw) return res;
    return { status: res.status, body: await res.json().catch(() => null) };
  };
  return { get: p => call('GET', p), post: (p, b = {}) => call('POST', p, b), put: (p, b) => call('PUT', p, b), patch: (p, b) => call('PATCH', p, b), raw: (m, p, b) => call(m, p, b, true) };
}
const mod = id => require('../content/modules/' + id);
const correct = id => Object.fromEntries(mod(id).quiz.map((q, i) => [i, q.a]));
async function finishLessons(c, id) { for (let i = 0; i < mod(id).lessons.length; i++) assert.equal((await c.post(`/modules/${id}/lessons/${i}/complete`)).status, 200); }
let n = 0;
async function newLearner(country = 'CI') {
  const c = client();
  const r = await c.post('/auth/register', { fullName: 'Apprenant Test ' + (++n), email: `t${n}@test.ci`, password: 'motdepasse1', country });
  assert.equal(r.status, 201);
  return c;
}

test('inscription, doublon, connexion, déconnexion', async () => {
  const c = client();
  assert.equal((await c.post('/auth/register', { fullName: 'Aïcha Koné', email: 'aicha@test.ci', password: 'court' })).status, 400);
  assert.equal((await c.post('/auth/register', { fullName: 'Aïcha Koné', email: 'aicha@test.ci', password: 'motdepasse1', country: 'SN' })).status, 201);
  assert.equal((await client().post('/auth/register', { fullName: 'Autre', email: 'AICHA@test.ci', password: 'motdepasse1' })).status, 409);
  assert.equal((await c.get('/me')).body.user.zone, 'uemoa');
  await c.post('/auth/logout');
  assert.equal((await c.get('/me')).body.user, null);
  assert.equal((await c.post('/auth/login', { email: 'aicha@test.ci', password: 'mauvais' })).status, 401);
  assert.equal((await c.post('/auth/login', { email: 'aicha@test.ci', password: 'motdepasse1' })).status, 200);
});

test('écriture non JSON refusée (protection CSRF)', async () => {
  const res = await fetch(base + '/auth/login', { method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded' }, body: 'email=a&password=b' });
  assert.equal(res.status, 415);
});

test('catalogue : 5 parcours, 24 modules complets, prix par zone', async () => {
  const r = await client().get('/catalog?zone=b');
  assert.equal(r.body.tracks.length, 5);
  const mods = r.body.tracks.flatMap(t => t.modules);
  assert.equal(mods.length, 24);
  assert.ok(mods.every(m => m.status === 'complet'));
  const com = r.body.tracks.find(t => t.id === 'commercial').price;
  assert.equal(com.currency, 'USD');
  assert.equal(com.installments.display.currency, 'USD');
});

test('module gratuit lisible sans compte, quiz réservé aux inscrits, réponses jamais exposées', async () => {
  const anon = client();
  const r = await anon.get('/modules/F1');
  assert.ok(r.body.state.access.ok);
  assert.ok(r.body.module.lessons.length > 0);
  assert.ok(r.body.module.quiz.every(q => !('a' in q) && !('why' in q)));
  assert.equal((await anon.post('/modules/F1/quiz', { answers: {} })).status, 401);
});

test('quiz : leçons obligatoires, échec puis réussite à 70 %, attestation et vérification publique', async () => {
  const c = await newLearner();
  assert.equal((await c.post('/modules/F1/quiz', { answers: correct('F1') })).status, 409);
  await finishLessons(c, 'F1');
  const fail = await c.post('/modules/F1/quiz', { answers: {} });
  assert.equal(fail.body.passed, false);
  assert.equal(fail.body.score, 0);
  assert.equal((await c.post('/certificates', { kind: 'module', id: 'F1' })).status, 403);
  // 70 % exactement : réussite
  const q = mod('F1').quiz, need = Math.ceil(q.length * 0.7);
  const partial = Object.fromEntries(q.slice(0, need).map((x, i) => [i, x.a]));
  const ok = await c.post('/modules/F1/quiz', { answers: partial });
  assert.equal(ok.body.passed, true);
  const cert = (await c.post('/certificates', { kind: 'module', id: 'F1' })).body.certificate;
  assert.match(cert.ref, /^STFC-\d{4}-[0-9A-F]{6}$/);
  assert.equal((await c.post('/certificates', { kind: 'module', id: 'F1' })).body.certificate.ref, cert.ref, 'pas de doublon');
  const v = await client().get('/verify/' + cert.ref);
  assert.equal(v.body.valid, true);
  assert.equal(v.body.certificate.full_name, cert.full_name);
  const pdf = await c.raw('GET', `/certificates/${cert.ref}/pdf`);
  assert.equal(pdf.headers.get('content-type'), 'application/pdf');
  assert.ok((await pdf.arrayBuffer()).byteLength > 1500);
  assert.equal((await (await newLearner()).raw('GET', `/certificates/${cert.ref}/pdf`)).status, 404, 'un autre apprenant ne peut pas télécharger');
});

test('parcours payant : blocage, paiement simulé, progression séquentielle, certificat de parcours', async () => {
  const c = await newLearner('CM');
  assert.equal((await c.get('/modules/C1')).body.state.access.reason, 'paywall');
  assert.equal((await c.post('/modules/C1/lessons/0/complete')).status, 403);
  const init = await c.post('/payments/init', { product: 'track:commercial', zone: 'cemac' });
  assert.ok(init.body.simulation);
  assert.equal((await c.get('/payments/' + init.body.transactionId)).body.payment.currency, 'XAF');
  assert.equal((await c.post(`/payments/${init.body.transactionId}/simulate`, { accepted: true })).body.status, 'accepted');
  assert.equal((await c.post(`/payments/${init.body.transactionId}/simulate`, { accepted: true })).body.status, 'accepted', 'idempotent');
  assert.equal((await c.get('/me')).body.user.entitlements.filter(e => e.scope === 'track:commercial').length, 1);
  assert.equal((await c.get('/modules/C2')).body.state.access.reason, 'sequence');
  const track = tracks.find(t => t.id === 'commercial');
  for (const id of track.modules) {
    assert.ok((await c.get('/modules/' + id)).body.state.access.ok, id + ' accessible');
    await finishLessons(c, id);
    assert.equal((await c.post(`/modules/${id}/quiz`, { answers: correct(id) })).body.passed, true);
  }
  const tc = await c.post('/certificates', { kind: 'track', id: 'commercial' });
  assert.equal(tc.status, 201);
  assert.equal(tc.body.certificate.score, 100);
  const dash = await c.get('/dashboard');
  assert.equal(dash.body.tracks.find(t => t.id === 'commercial').pct, 100);
});

test('paiement en 3 fois : accès temporaire puis définitif à la 3e échéance', async () => {
  const c = await newLearner();
  for (let k = 1; k <= 3; k++) {
    const init = await c.post('/payments/init', { product: 'track:directeur', zone: 'uemoa', plan: 'x3' });
    await c.post(`/payments/${init.body.transactionId}/simulate`, { accepted: true });
    const ents = (await c.get('/me')).body.user.entitlements.filter(e => e.scope === 'track:directeur');
    if (k < 3) assert.ok(ents.every(e => e.expires_at), 'accès temporaire');
    else assert.ok(ents.some(e => e.expires_at === null), 'accès à vie');
  }
});

test('paiement refusé : aucun accès', async () => {
  const c = await newLearner();
  const init = await c.post('/payments/init', { product: 'pass', zone: 'uemoa' });
  await c.post(`/payments/${init.body.transactionId}/simulate`, { accepted: false });
  assert.equal((await c.get('/me')).body.user.entitlements.length, 0);
  assert.equal((await c.post('/payments/init', { product: 'inconnu', zone: 'uemoa' })).status, 400);
});

test('administration : droits, codes d’accès, édition de contenu, statistiques', async () => {
  const learner = await newLearner();
  assert.equal((await learner.get('/admin/stats')).status, 403);
  const admin = client();
  assert.equal((await admin.post('/auth/login', { email: 'admin@stfc.local', password: 'ChangeMoi-2026!' })).status, 200);

  const codes = (await admin.post('/admin/codes', { scope: 'track:responsable', count: 2, label: 'Test entreprise' })).body.codes;
  assert.equal(codes.length, 2);
  assert.equal((await learner.post('/codes/redeem', { code: codes[0].toLowerCase() })).status, 200);
  assert.equal((await learner.post('/codes/redeem', { code: codes[0] })).status, 409);
  assert.equal((await (await newLearner()).post('/codes/redeem', { code: codes[0] })).status, 410);
  assert.ok((await learner.get('/modules/R1')).body.state.access.ok);

  const m = (await admin.get('/admin/modules/F2')).body.module;
  assert.equal((await admin.put('/admin/modules/F2', { module: { ...m, quiz: [{ q: 'x', options: ['a', 'b'], a: 5 }] } })).status, 400);
  assert.equal((await admin.put('/admin/modules/F2', { module: { ...m, video: { src: 'https://evil.example/x' } } })).status, 400);
  assert.equal((await admin.put('/admin/modules/F2', { module: { ...m, title: 'Prospecter avec WhatsApp (v2)' } })).status, 200);
  assert.equal((await client().get('/modules/F2')).body.module.title, 'Prospecter avec WhatsApp (v2)');

  const stats = (await admin.get('/admin/stats')).body;
  assert.ok(stats.users.learners >= 5);
  assert.ok(stats.revenue.totalXof > 0);
  assert.ok(stats.kpi.quizPassRate > 0);
  const users = (await admin.get('/admin/users?q=test')).body.users;
  assert.ok(users.length >= 5);
  assert.equal((await admin.post(`/admin/users/${users[0].id}/grant`, { scope: 'all', days: 30 })).status, 201);
});

test('auto-évaluation : recommandation cohérente', async () => {
  const c = client();
  const q = (await c.get('/autoeval')).body.questions;
  assert.equal(q.length, 10);
  const low = await c.post('/autoeval', { answers: Object.fromEntries(q.map((_, i) => [i, 0])) });
  assert.equal(low.body.track, 'decouverte');
  const high = await c.post('/autoeval', { answers: Object.fromEntries(q.map((_, i) => [i, 3])) });
  assert.equal(high.body.track, 'directeur');
});

test('PDF de cours générés pour les 24 modules', async () => {
  const pdf = require('../src/pdf');
  const content = require('../src/content');
  for (const t of tracks) for (const id of t.modules) {
    const doc = pdf.course(content.getModule(id), t.title, 'Test');
    const chunks = []; doc.on('data', d => chunks.push(d));
    await new Promise((res, rej) => { doc.on('end', res); doc.on('error', rej); });
    assert.ok(Buffer.concat(chunks).length > 5000, id);
  }
});
