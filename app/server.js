// STFC Academy : serveur web (API + interface).
const path = require('node:path');
const express = require('express');
const config = require('./src/config');
const db = require('./src/db');
const content = require('./src/content');
const auth = require('./src/auth');
const { securityHeaders } = require('./src/security');

function createApp({ dbFile } = {}) {
  db.open(dbFile);
  content.seed();
  const adminEmail = auth.ensureAdmin();
  if (adminEmail) console.log(`Compte administrateur créé : ${adminEmail}${config.isProd ? '' : ' (mot de passe par défaut, à changer)'}`);

  const app = express();
  app.disable('x-powered-by');
  app.set('trust proxy', 1);
  app.use(securityHeaders);
  app.use(express.json({ limit: '1mb' }));

  // Protection CSRF : toute écriture sur l'API doit être envoyée en JSON (impossible depuis un formulaire tiers),
  // sauf la notification de paiement CinetPay.
  app.use('/api', (req, res, next) => {
    if (['POST', 'PUT', 'PATCH', 'DELETE'].includes(req.method) && req.path !== '/payments/notify' && !req.is('application/json')) {
      return res.status(415).json({ error: 'Requête JSON attendue.' });
    }
    next();
  });
  app.use('/api', auth.loadUser);
  app.use('/api/admin', require('./src/admin').router);
  app.use('/api', require('./src/api').router);
  app.use('/api', (req, res) => res.status(404).json({ error: 'Ressource introuvable.' }));

  app.use(express.static(path.join(__dirname, 'public'), {
    setHeaders: (res, file) => { if (/sw\.js$|index\.html$/.test(file)) res.setHeader('Cache-Control', 'no-cache'); else res.setHeader('Cache-Control', 'public, max-age=3600'); }
  }));
  app.get('*', (req, res) => res.sendFile(path.join(__dirname, 'public', 'index.html')));

  // Gestion des erreurs : message clair pour l'utilisateur, détail technique dans les journaux uniquement.
  app.use((err, req, res, next) => { // eslint-disable-line no-unused-vars
    const status = err.status || (err.type === 'entity.parse.failed' ? 400 : 500);
    if (status >= 500) console.error(err);
    res.status(status).json({ error: status >= 500 ? 'Erreur interne. Réessayez dans un instant.' : err.message });
  });
  return app;
}

if (require.main === module) {
  createApp().listen(config.port, () => {
    console.log(`STFC Academy en ligne sur ${config.baseUrl} (port ${config.port})`);
    if (!require('./src/payments').live()) console.log('Paiements : mode SIMULATION (renseignez CINETPAY_API_KEY et CINETPAY_SITE_ID pour activer CinetPay).');
  });
}

module.exports = { createApp };
