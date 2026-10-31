// STFC Academy : mode hors ligne. Incrémenter VERSION à chaque mise à jour du contenu.
const VERSION = 'stfc-v1';
const ASSETS = [
  './', 'index.html', 'manifest.webmanifest', 'assets/icon.svg',
  'assets/css/style.css', 'assets/js/config.js', 'assets/js/catalogue.js', 'assets/js/app.js'
];

self.addEventListener('install', e => {
  e.waitUntil(caches.open(VERSION).then(c => c.addAll(ASSETS)).then(() => self.skipWaiting()));
});

self.addEventListener('activate', e => {
  e.waitUntil(caches.keys().then(keys => Promise.all(keys.filter(k => k !== VERSION).map(k => caches.delete(k)))).then(() => self.clients.claim()));
});

// Réseau d'abord (contenu à jour), cache en secours (hors ligne). Les vidéos externes ne sont jamais mises en cache.
self.addEventListener('fetch', e => {
  const url = new URL(e.request.url);
  if (e.request.method !== 'GET' || url.origin !== location.origin) return;
  e.respondWith(
    fetch(e.request)
      .then(res => { const copy = res.clone(); caches.open(VERSION).then(c => c.put(e.request, copy)); return res; })
      .catch(() => caches.match(e.request).then(r => r || caches.match('index.html')))
  );
});
