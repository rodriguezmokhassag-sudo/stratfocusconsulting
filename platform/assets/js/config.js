/*
 * STFC Academy — Paramètres à personnaliser
 */
window.STFC_CONFIG = {
  brand: 'STFC Academy',
  org: 'StratFocus Consulting',
  // Numéro WhatsApp au format international, sans + ni espaces (ex. 2250700000000). À REMPLACER.
  whatsapp: '2250000000000',
  email: 'contact@stratfocusconsulting.com', // À REMPLACER
  currency: 'FCFA',
  signatory: { name: 'Directeur pédagogique', title: 'STFC Academy' }, // À REMPLACER par le nom réel
  launchPromo: { code: 'LANCEMENT30', percent: 30 },

  /*
   * Codes d'accès (vente manuelle par Mobile Money ou virement, licences entreprise).
   * On ne stocke que l'empreinte SHA-256 du code (en majuscules) : le code lui-même n'apparaît pas dans le site.
   * Générer de nouveaux codes avec : node tools/generer-codes.mjs commercial 10
   * Valeurs possibles : 'commercial', 'chef-equipe', 'responsable', 'directeur', 'all'
   *
   * Code de démonstration inclus : STFC-DEMO-2026 (débloque tout). À SUPPRIMER avant la mise en production.
   */
  accessCodes: {
    'a9b92bb67e5b28687490bebc8a257ca5fd82f5c455465a105621e713a6781ecd': ['all']
  }
};
