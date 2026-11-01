// Contenu pédagogique : chargement depuis content/, stockage en base (éditable par l'admin), règles d'accès.
const fs = require('node:fs');
const path = require('node:path');
const db = require('./db');
const config = require('./config');
const tracks = require('../content/tracks');

const MODULES_DIR = path.join(__dirname, '..', 'content', 'modules');

function readModuleFile(id) {
  const file = path.join(MODULES_DIR, id + '.js');
  if (!fs.existsSync(file)) return null;
  delete require.cache[require.resolve(file)];
  return require(file);
}

// Insère en base les modules absents (ou tous si force = true).
function seed({ force = false } = {}) {
  let count = 0;
  db.tx(() => {
    tracks.forEach(t => t.modules.forEach((id, position) => {
      const exists = db.get('SELECT id FROM modules WHERE id = ?', [id]);
      if (exists && !force) return;
      const m = readModuleFile(id) || { id, title: id, status: 'bientot', summary: '', objectives: [], lessons: [], quiz: [] };
      const { title, status = 'complet' } = m;
      const data = JSON.stringify(m);
      if (exists) db.run('UPDATE modules SET track_id=?, position=?, title=?, status=?, data=?, updated_at=? WHERE id=?', [t.id, position, title, status, data, db.now(), id]);
      else db.run('INSERT INTO modules (id, track_id, position, title, status, data, updated_at) VALUES (?,?,?,?,?,?,?)', [id, t.id, position, title, status, data, db.now()]);
      count++;
    }));
  });
  return count;
}

const cache = new Map();
function getModule(id) {
  if (cache.has(id)) return cache.get(id);
  const row = db.get('SELECT * FROM modules WHERE id = ?', [id]);
  if (!row) return null;
  const m = Object.assign(JSON.parse(row.data), { id: row.id, title: row.title, status: row.status, trackId: row.track_id, updatedAt: row.updated_at });
  cache.set(id, m);
  return m;
}
function saveModule(id, data, userId) {
  const status = data.status === 'bientot' ? 'bientot' : 'complet';
  db.run('UPDATE modules SET title=?, status=?, data=?, updated_at=?, updated_by=? WHERE id=?', [data.title, status, JSON.stringify(data), db.now(), userId, id]);
  cache.delete(id);
  return getModule(id);
}

const trackOf = modId => tracks.find(t => t.modules.includes(modId));
const getTrack = id => tracks.find(t => t.id === id);

/* ---------- Droits d'accès ---------- */
function activeScopes(userId) {
  if (!userId) return new Set();
  const rows = db.all('SELECT scope FROM entitlements WHERE user_id = ? AND (expires_at IS NULL OR expires_at > ?)', [userId, db.now()]);
  return new Set(rows.map(r => r.scope));
}
function hasTrackAccess(user, track, scopes) {
  if (track.free) return true;
  if (!user) return false;
  if (user.role === 'admin' || user.role === 'trainer') return true;
  scopes = scopes || activeScopes(user.id);
  return scopes.has('all') || scopes.has('track:' + track.id);
}
function passedSet(userId) {
  if (!userId) return new Set();
  return new Set(db.all('SELECT DISTINCT module_id FROM quiz_attempts WHERE user_id = ? AND passed = 1', [userId]).map(r => r.module_id));
}
function lessonsDoneList(userId, modId) {
  if (!userId) return [];
  return db.all('SELECT lesson_index FROM progress WHERE user_id = ? AND module_id = ?', [userId, modId]).map(r => r.lesson_index);
}

// { ok } ou { ok:false, reason: 'paywall' | 'bientot' | 'sequence', blocker }
function moduleAccess(user, modId, ctx = {}) {
  const m = getModule(modId), t = trackOf(modId);
  if (!m || !t) return { ok: false, reason: 'introuvable' };
  if (!hasTrackAccess(user, t, ctx.scopes)) return { ok: false, reason: 'paywall' };
  if (m.status !== 'complet') return { ok: false, reason: 'bientot' };
  if (!t.free && user && user.role === 'learner') {
    const passed = ctx.passed || passedSet(user.id);
    const idx = t.modules.indexOf(modId);
    const blocker = t.modules.slice(0, idx).find(id => getModule(id).status === 'complet' && !passed.has(id));
    if (blocker) return { ok: false, reason: 'sequence', blocker };
  }
  return { ok: true };
}

// Version publique d'un module (sans les réponses du quiz ; leçons uniquement si accès)
function publicModule(m, withLessons) {
  const out = {
    id: m.id, trackId: m.trackId, title: m.title, status: m.status, duration: m.duration, summary: m.summary,
    objectives: m.objectives || [], skills: m.skills || [], deliverable: m.deliverable || null, updatedAt: m.updatedAt,
    video: m.video ? { title: m.video.title, duration: m.video.duration, src: withLessons ? m.video.src || null : null, download: withLessons ? m.video.download || null : null, script: m.video.script || [] } : null,
    lessonTitles: (m.lessons || []).map(l => l.title),
    quizCount: (m.quiz || []).length,
    takeaways: withLessons ? m.takeaways || [] : []
  };
  if (withLessons) {
    out.lessons = m.lessons;
    out.quiz = (m.quiz || []).map((q, i) => ({ i, q: q.q, options: q.options }));
  }
  return out;
}

module.exports = { seed, getModule, saveModule, tracks, trackOf, getTrack, activeScopes, hasTrackAccess, passedSet, lessonsDoneList, moduleAccess, publicModule, passMark: config.passMark };
