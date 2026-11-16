/*
 * STFC Academy — Parcours (ordre des modules, public, durée, prix de base en FCFA)
 * Les prix régionaux sont calculés dans src/pricing.js à partir de price (FCFA, zone A).
 * Le contenu de chaque module se trouve dans content/modules/<ID>.js
 */
module.exports = [
  {
    id: 'decouverte', title: 'Découverte', free: true, price: 0, level: 0,
    audience: 'Tout public : étudiants, demandeurs d’emploi, entrepreneurs, curieux',
    duration: '3 h 15',
    desc: 'Quatre modules gratuits et complets pour découvrir la vente moderne, le marketing digital et l’innovation. Attestation offerte à chaque module validé.',
    objectives: ['Comprendre les bases de la vente conseil', 'Prospecter avec WhatsApp et les réseaux sociaux', 'Maîtriser les fondamentaux du marketing digital', 'Initier une démarche d’innovation'],
    certificate: 'Attestation de réussite par module',
    modules: ['F1', 'F2', 'F4', 'F3']
  },
  {
    id: 'commercial', title: 'Commercial', price: 35000, level: 1,
    audience: 'Débutants, vendeurs terrain, téléconseillers, commerciaux juniors',
    duration: '5 h de cours + 5 livrables (4 à 6 semaines)',
    desc: 'Maîtriser chaque étape de l’entretien de vente : découvrir, argumenter, traiter les objections, conclure, fidéliser et organiser son activité.',
    objectives: ['Conduire un entretien de vente complet', 'Traiter les objections et défendre son prix', 'Conclure et fidéliser', 'Organiser ses tournées et suivre ses clients dans un CRM'],
    certificate: 'Certificat professionnel STFC — Commercial',
    modules: ['C1', 'C2', 'C3', 'C4', 'C5']
  },
  {
    id: 'chef-equipe', title: 'Chef d’équipe commercial', price: 65000, level: 2,
    audience: 'Commerciaux confirmés promus ou en voie de promotion',
    duration: '4 h de cours + 4 livrables (4 semaines)',
    desc: 'Réussir le passage de vendeur à manager : animer, motiver, coacher sur le terrain et piloter les résultats d’une équipe.',
    objectives: ['Adopter la posture de manager', 'Animer et motiver une équipe', 'Coacher sur le terrain', 'Piloter les objectifs et les KPI'],
    certificate: 'Certificat professionnel STFC — Chef d’équipe commercial',
    modules: ['E1', 'E2', 'E3', 'E4']
  },
  {
    id: 'responsable', title: 'Responsable commercial', price: 95000, level: 3,
    audience: 'Responsables de zone, de canal, d’agence ou de grands secteurs',
    duration: '5 h 15 de cours + 5 livrables (5 à 6 semaines)',
    desc: 'Construire et déployer un plan d’action commercial, segmenter un portefeuille (ABC, RFM), piloter les canaux de distribution, le budget des ventes et le recrutement.',
    objectives: ['Bâtir un plan d’action commercial', 'Segmenter et piloter un portefeuille clients', 'Gérer les canaux de distribution', 'Prévoir les ventes et piloter la rentabilité'],
    certificate: 'Certificat professionnel STFC — Responsable commercial',
    modules: ['R1', 'R2', 'R3', 'R4', 'R5']
  },
  {
    id: 'directeur', title: 'Directeur commercial', price: 150000, level: 4,
    audience: 'Directeurs commerciaux, DG de PME, cadres dirigeants',
    duration: '6 h 40 de cours + 6 livrables (6 à 8 semaines)',
    desc: 'Définir la stratégie commerciale et d’innovation, organiser et rémunérer la force de vente, fixer les prix, piloter les grands comptes et conduire la transformation digitale.',
    objectives: ['Définir une stratégie commerciale et d’innovation', 'Organiser et rémunérer la force de vente', 'Fixer une politique de prix', 'Piloter la transformation digitale et la gouvernance commerciale'],
    certificate: 'Certificat professionnel STFC — Directeur commercial',
    modules: ['D1', 'D2', 'D3', 'D4', 'D5', 'D6']
  }
];
