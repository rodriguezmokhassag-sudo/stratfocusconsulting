// Module D5 — Transformation digitale commerciale et données
module.exports = {
  id: 'D5', title: 'Transformation digitale commerciale et données', status: 'complet', duration: '65 min',
  summary: 'Construire la feuille de route digitale de la fonction commerciale, réussir le déploiement d’un CRM, piloter par la donnée et utiliser l’IA générative de façon responsable.',
  objectives: [
    'Évaluer la maturité digitale de sa fonction commerciale',
    'Choisir et réussir le déploiement d’un CRM',
    'Construire un pilotage par la donnée (tableaux de bord, prévisions)',
    'Utiliser l’IA générative au service des équipes commerciales'
  ],
  skills: ['Feuille de route digitale', 'Déploiement de CRM', 'Pilotage par la donnée et IA'],
  video: {
    title: 'Digitaliser sans perdre le terrain', duration: '7 min', src: null,
    script: [
      'Accroche : « La plupart des projets CRM échouent à cause de l’adoption, pas de la technologie. »',
      'Les 4 niveaux de maturité digitale commerciale.',
      'Choisir un CRM : les critères qui comptent en Afrique.',
      'Le tableau de bord de direction en temps réel.',
      'IA générative : 6 usages concrets et 3 précautions.'
    ]
  },
  lessons: [
    {
      title: 'La maturité digitale commerciale',
      blocks: [
        { t: 'table', caption: 'Les 4 niveaux de maturité', head: ['Niveau', 'Caractéristiques', 'Prochaine étape'], rows: [
          ['1. Artisanal', 'Carnets, mémoire, WhatsApp personnel, Excel individuel', 'Tableur partagé et règles communes'],
          ['2. Outillé', 'Tableur partagé ou CRM simple, peu de discipline de saisie', 'CRM adopté par tous, processus de vente défini'],
          ['3. Piloté', 'CRM utilisé, tableaux de bord hebdomadaires, données fiables', 'Automatisations, intégrations (facturation, WhatsApp, paiement)'],
          ['4. Augmenté', 'Données consolidées, prévisions, scoring des prospects, IA', 'Amélioration continue, nouveaux canaux']
        ]},
        { t: 'flow', caption: 'Feuille de route type sur 18 mois', items: ['Diagnostic (M0)', 'Processus de vente écrit (M1-M2)', 'CRM pilote sur une équipe (M3-M5)', 'Généralisation + formation (M6-M9)', 'Tableaux de bord et automatisations (M10-M14)', 'Données et IA (M15-M18)'] },
        { t: 'tip', x: 'On ne digitalise pas un processus flou. Écrivez d’abord **votre processus de vente** (étapes, critères de passage d’une étape à l’autre), puis outillez-le.' }
      ]
    },
    {
      title: 'Choisir et réussir son CRM',
      blocks: [
        { t: 'table', caption: 'Critères de choix d’un CRM en Afrique francophone', head: ['Critère', 'Pourquoi c’est important'], rows: [
          ['Application mobile performante et mode hors ligne', 'Les commerciaux sont sur le terrain, avec une connexion intermittente'],
          ['Intégration WhatsApp', 'Le canal principal des échanges clients'],
          ['Interface en français', 'Adoption par toutes les équipes'],
          ['Coût par utilisateur', 'Licences en dollars ou en euros : vérifier le coût total sur 3 ans'],
          ['Intégrations', 'Facturation, comptabilité, paiement Mobile Money'],
          ['Partenaire local', 'Support, formation et paramétrage à proximité']
        ]},
        { t: 'table', caption: 'Facteurs de réussite du déploiement', head: ['Facteur', 'Bonne pratique'], rows: [
          ['Sponsor', 'Le directeur commercial utilise lui-même le CRM en réunion'],
          ['Simplicité', 'Démarrer avec 5 à 8 champs obligatoires, pas 40'],
          ['Utilité pour le commercial', 'Le CRM doit lui faire gagner du temps (devis automatiques, rappels), pas seulement servir au contrôle'],
          ['Règle d’or', '« Ce qui n’est pas dans le CRM n’existe pas » : primes et revues calculées à partir du CRM'],
          ['Accompagnement', 'Formation pratique, référents par équipe, support pendant 3 mois']
        ]},
        { t: 'action', x: 'Situez votre organisation sur les 4 niveaux de maturité et listez les 3 prochaines actions.' }
      ]
    },
    {
      title: 'Piloter par la donnée et utiliser l’IA',
      blocks: [
        { t: 'table', caption: 'Le tableau de bord de direction', head: ['Bloc', 'Indicateurs', 'Fréquence'], rows: [
          ['Résultats', 'CA, marge, atteinte de l’objectif par zone et par produit', 'Hebdomadaire'],
          ['Pipeline', 'Valeur des opportunités par étape, taux de conversion, cycle de vente', 'Hebdomadaire'],
          ['Clients', 'Nouveaux clients, clients perdus, segments RFM', 'Mensuelle'],
          ['Force de vente', 'Activité, productivité par commercial, coût commercial / CA', 'Mensuelle'],
          ['Prévision', 'Prévision de clôture du trimestre (pondérée par probabilité)', 'Hebdomadaire']
        ]},
        { t: 'table', caption: 'IA générative : usages concrets', head: ['Usage', 'Exemple'], rows: [
          ['Préparation de rendez-vous', 'Synthèse de l’actualité d’un client et des questions SPIN à poser'],
          ['Rédaction', 'Propositions commerciales, e-mails de relance, messages WhatsApp personnalisés'],
          ['Formation', 'Jeux de rôle simulés avec un « client » difficile'],
          ['Analyse', 'Synthèse des comptes rendus de visite et des réclamations'],
          ['Contenus marketing', 'Posts, scripts vidéo, fiches produits, déclinés en langues locales puis relus'],
          ['Données', 'Aide à la construction de formules et d’analyses dans le tableur']
        ]},
        { t: 'list', items: [
          '**Confidentialité** : ne jamais saisir de données personnelles clients ni de conditions tarifaires confidentielles dans un outil non validé par l’entreprise.',
          '**Vérification** : l’IA peut se tromper. Tout chiffre et toute affirmation sont vérifiés avant envoi.',
          '**Conformité** : respecter les lois de protection des données (par exemple ARTCI en Côte d’Ivoire, CDP au Sénégal).'
        ]},
        { t: 'case', title: 'Étude de cas : le CRM abandonné en 6 mois',
          context: 'Un groupe de distribution à Douala achète un CRM international très complet. Il est paramétré par le service informatique avec 45 champs obligatoires. L’application mobile fonctionne mal sans connexion. Les commerciaux continuent leurs fichiers Excel, et 6 mois plus tard, moins de 20 % des opportunités sont dans le CRM.',
          questions: ['Quelles sont les causes de l’échec ?', 'Quel plan de relance proposez-vous ?'],
          solution: 'Causes : **projet piloté par l’informatique** sans implication commerciale, **trop de champs**, **mauvais fonctionnement hors ligne**, aucun bénéfice visible pour le commercial, **pas de règle d’usage** (Excel toléré). Relance : 1) sponsor = directeur commercial, qui pilote les revues **uniquement depuis le CRM** ; 2) réduction à 8 champs obligatoires ; 3) test et correction du mode hors ligne (ou outil plus adapté) ; 4) fonctions utiles au commercial : devis en 1 clic, rappels, historique WhatsApp ; 5) primes calculées sur les données du CRM ; 6) référents par équipe et formation pratique de 2 heures.' }
      ]
    }
  ],
  takeaways: [
    '4 niveaux de maturité : artisanal, outillé, piloté, augmenté.',
    'Écrire le processus de vente avant de l’outiller.',
    'Le succès d’un CRM dépend de l’adoption : simplicité, utilité, sponsor, règle d’or.',
    'IA générative : gains de temps réels, avec confidentialité et vérification systématiques.'
  ],
  deliverable: { title: 'Feuille de route digitale commerciale', x: 'Diagnostic de maturité, processus de vente écrit (étapes et critères), cahier des charges CRM en 10 critères, maquette du tableau de bord de direction et 3 usages d’IA encadrés par des règles.' },
  quiz: [
    { q: 'Que faut-il faire avant de déployer un CRM ?', options: ['Acheter le plus complet', 'Écrire et clarifier le processus de vente', 'Recruter des informaticiens', 'Supprimer Excel'], a: 1, why: 'On n’outille bien qu’un processus clair.' },
    { q: 'Quelle est la première cause d’échec des projets CRM ?', options: ['Le prix', 'Le manque d’adoption par les équipes', 'La couleur de l’interface', 'Le serveur'], a: 1, why: 'Un CRM non utilisé ne produit aucune donnée.' },
    { q: 'Pourquoi le mode hors ligne est-il important ?', options: ['Pour économiser l’électricité', 'Parce que les commerciaux terrain ont une connexion intermittente', 'Ce n’est pas important', 'Pour la sécurité'], a: 1, why: 'Sans mode hors ligne, la saisie est reportée puis oubliée.' },
    { q: 'Que signifie la règle « ce qui n’est pas dans le CRM n’existe pas » ?', options: ['Supprimer les clients', 'Les revues et les primes se basent uniquement sur le CRM', 'Interdire WhatsApp', 'Saisir tout deux fois'], a: 1, why: 'Elle crée l’incitation à saisir les données.' },
    { q: 'Quelle précaution prendre avec l’IA générative ?', options: ['Lui confier toutes les données clients', 'Ne pas y saisir de données confidentielles et vérifier ses réponses', 'L’utiliser sans relecture', 'L’interdire'], a: 1, why: 'Confidentialité et vérification sont indispensables.' },
    { q: 'Combien de champs obligatoires au démarrage d’un CRM ?', options: ['45', '5 à 8', '100', 'Aucun'], a: 1, why: 'La simplicité favorise l’adoption.' }
  ]
};
