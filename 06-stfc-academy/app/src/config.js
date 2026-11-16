// Configuration lue depuis les variables d'environnement (voir .env.example)
const path = require('node:path');

const env = process.env;
const isProd = env.NODE_ENV === 'production';

module.exports = {
  isProd,
  port: Number(env.PORT || 3000),
  // URL publique du site (sert aux liens de retour de paiement et de vérification des certificats)
  baseUrl: (env.BASE_URL || `http://localhost:${env.PORT || 3000}`).replace(/\/$/, ''),
  dbFile: env.DB_FILE || path.join(__dirname, '..', 'data', 'stfc.sqlite'),

  brand: 'STFC Academy',
  org: 'StratFocus Consulting',
  passMark: Number(env.PASS_MARK || 70),
  sessionDays: 30,

  contact: {
    whatsapp: env.CONTACT_WHATSAPP || '2250000000000',
    email: env.CONTACT_EMAIL || 'contact@stratfocusconsulting.com'
  },
  signatory: {
    name: env.CERT_SIGNATORY_NAME || 'Directeur pédagogique',
    title: env.CERT_SIGNATORY_TITLE || 'STFC Academy'
  },

  // Premier administrateur créé au démarrage s'il n'en existe aucun
  admin: {
    email: env.ADMIN_EMAIL || (isProd ? '' : 'admin@stfc.local'),
    password: env.ADMIN_PASSWORD || (isProd ? '' : 'ChangeMoi-2026!')
  },

  cinetpay: {
    apiKey: env.CINETPAY_API_KEY || '',
    siteId: env.CINETPAY_SITE_ID || '',
    apiUrl: env.CINETPAY_API_URL || 'https://api-checkout.cinetpay.com/v2'
  },

  // Taux indicatifs (1 unité = X FCFA). L'EUR est fixe (parité du franc CFA).
  rates: {
    EUR: 655.957,
    USD: Number(env.RATE_USD_XOF || 600),
    MAD: Number(env.RATE_MAD_XOF || 61)
  }
};
