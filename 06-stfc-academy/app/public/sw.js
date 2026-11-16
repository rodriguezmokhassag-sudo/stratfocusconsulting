// STFC Academy : mode hors connexion. Incrémenter VERSION à chaque mise à jour de l'interface.
const VERSION = 'stfc-v2';
const SHELL = ['/', '/index.html', '/manifest.webmanifest', '/assets/icon.svg', '/assets/css/style.css', '/assets/js/core.js', '/assets/js/app.js', '/assets/js/admin.js'];
// Réponses d'API conservées pour la lecture hors connexion (catalogue et modules déjà ouverts)
const API_CACHE = /^\/api\/(config|catalog|modules\/\w+$|autoeval$)/;

self.addEventListener('install', e => e.waitUntil(caches.open(VERSION).then(c => c.addAll(SHELL)).then(() => self.skipWaiting())));
self.addEventListener('activate', e => e.waitUntil(caches.keys().then(ks => Promise.all(ks.filter(k => k !== VERSION).map(k => caches.delete(k)))).then(() => self.clients.claim())));

self.addEventListener('fetch', e => {
  const url = new URL(e.request.url);
  if (e.request.method !== 'GET' || url.origin !== location.origin) return;
  const isApi = url.pathname.startsWith('/api/');
  if (isApi && !API_CACHE.test(url.pathname)) return; // données personnelles et PDF : toujours en ligne
  // Réseau d'abord (contenu à jour), cache en secours.
  e.respondWith(fetch(e.request).then(res => {
    if (res.ok) { const copy = res.clone(); caches.open(VERSION).then(c => c.put(e.request, copy)); }
    return res;
  }).catch(() => caches.match(e.request).then(r => r || (isApi ? new Response('{"error":"Hors connexion"}', { status: 503, headers: { 'Content-Type': 'application/json' } }) : caches.match('/index.html')))));
});
