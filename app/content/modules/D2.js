// Module D2 — Organisation de la force de vente et rémunération variable
module.exports = {
  id: 'D2', title: 'Organisation de la force de vente et rémunération variable', status: 'complet', duration: '70 min',
  summary: 'Dimensionner la force de vente, choisir une structure (géographique, produit, client, hybride) et concevoir un plan de rémunération variable motivant et rentable.',
  objectives: [
    'Calculer la taille optimale de la force de vente (méthode de la charge de travail)',
    'Choisir une organisation adaptée à la stratégie',
    'Concevoir un plan de rémunération fixe + variable aligné sur la marge',
    'Éviter les effets pervers des systèmes de commission'
  ],
  skills: ['Dimensionnement de la force de vente', 'Organisation commerciale', 'Conception de la rémunération variable'],
  video: {
    title: 'Combien de commerciaux, organisés comment, payés comment ?', duration: '7 min', src: null,
    script: [
      'Accroche : « Une force de vente mal dimensionnée coûte cher dans les deux sens. »',
      'La méthode de la charge de travail, calculée à l’écran.',
      'Les 4 organisations possibles et leurs arbitrages.',
      'Construire un variable : assiette, seuils, accélérateurs, plafonds.',
      'Trois effets pervers et comment les éviter.'
    ]
  },
  lessons: [
    {
      title: 'Dimensionner la force de vente',
      blocks: [
        { t: 'p', x: 'La **méthode de la charge de travail** part des clients à servir pour calculer le nombre de commerciaux nécessaires. C’est la plus utilisée car elle est simple et objective.' },
        { t: 'table', caption: 'Calcul : distributeur de produits d’hygiène, Côte d’Ivoire', head: ['Segment', 'Nombre de clients', 'Visites par an', 'Total des visites'], rows: [
          ['A (grands comptes)', '120', '48 (hebdomadaire)', '5 760'],
          ['B (moyens)', '400', '24 (tous les 15 jours)', '9 600'],
          ['C (petits, à distance)', '900', '6 (visite tous les 2 mois)', '5 400'],
          ['Prospection', '–', '–', '3 000'],
          ['**Total**', '', '', '**23 760 visites**']
        ]},
        { t: 'steps', items: [
          { title: 'Capacité d’un commercial', x: '5 visites par jour × 4 jours terrain × 44 semaines = 880 visites par an.' },
          { title: 'Effectif nécessaire', x: '23 760 ÷ 880 = 27 commerciaux.' },
          { title: 'Encadrement', x: '1 chef d’équipe pour 6 à 8 commerciaux, soit 4 chefs d’équipe.' },
          { title: 'Contrôle de rentabilité', x: 'Coût complet d’un commercial comparé à la marge qu’il génère (objectif : au moins 3 à 4 fois son coût).' }
        ]},
        { t: 'tip', x: 'Remplacer une partie des visites des clients C par du **télévente ou du WhatsApp** peut réduire fortement l’effectif nécessaire sans perte de chiffre d’affaires.' }
      ]
    },
    {
      title: 'Choisir son organisation',
      blocks: [
        { t: 'table', caption: 'Les 4 grandes organisations', head: ['Organisation', 'Principe', 'Avantages', 'Limites', 'Adaptée quand…'], rows: [
          ['Géographique', 'Chaque commercial couvre une zone', 'Simple, peu de déplacements, responsabilité claire', 'Généraliste : expertise limitée', 'Offre homogène, clients nombreux'],
          ['Par produit', 'Équipes spécialisées par gamme', 'Expertise technique', 'Plusieurs commerciaux chez le même client', 'Gammes techniques très différentes'],
          ['Par client / marché', 'Équipes par type de client (grands comptes, PME, distributeurs)', 'Connaissance fine des besoins', 'Coût, chevauchements géographiques', 'Clients aux besoins très différents'],
          ['Hybride', 'Grands comptes en direct + zones géographiques pour le reste', 'Combine expertise et couverture', 'Règles d’attribution à écrire', 'Entreprise en croissance, plusieurs pays']
        ]},
        { t: 'matrix', caption: 'Quelle organisation choisir ?', x: 'Diversité des clients →', y: 'Complexité technique de l’offre ↑', q: [
          { title: 'Par produit', x: 'Offre complexe, clients homogènes' },
          { title: 'Hybride / matricielle', x: 'Offre complexe, clients variés : grands comptes + spécialistes' },
          { title: 'Géographique', x: 'Offre simple, clients homogènes' },
          { title: 'Par client', x: 'Offre simple, clients très variés' }
        ]},
        { t: 'action', x: 'Votre organisation actuelle correspond-elle à la case de la matrice où vous vous situez ?' }
      ]
    },
    {
      title: 'Concevoir la rémunération variable',
      blocks: [
        { t: 'table', caption: 'Les composantes du plan', head: ['Composante', 'Rôle', 'Repère'], rows: [
          ['Fixe', 'Sécurité, attractivité, fidélité', '50 à 80 % de la rémunération cible selon le métier'],
          ['Commission', 'Récompenser le résultat', 'Calculée sur la **marge** plutôt que sur le CA'],
          ['Prime sur objectifs', 'Orienter les priorités', '2 à 4 critères maximum (CA, nouveaux clients, produit stratégique, encaissement)'],
          ['Accélérateur', 'Récompenser le dépassement', 'Taux majoré au-delà de 100 % de l’objectif'],
          ['Seuil de déclenchement', 'Éviter de payer la sous-performance', 'Par exemple, rien en dessous de 80 % de l’objectif']
        ]},
        { t: 'table', caption: 'Exemple de grille de prime trimestrielle (cible : 300 000 FCFA)', head: ['Atteinte de l’objectif', 'Prime versée'], rows: [
          ['Moins de 80 %', '0'],
          ['80 à 99 %', 'Proportionnelle (80 % = 150 000 FCFA, puis progression linéaire)'],
          ['100 %', '300 000 FCFA'],
          ['Au-delà de 100 %', '+20 000 FCFA par point (accélérateur), plafonné à 150 %']
        ]},
        { t: 'case', title: 'Étude de cas : les commissions qui détruisaient la marge',
          context: 'Une compagnie d’assurance à Dakar commissionne ses commerciaux à 8 % du chiffre d’affaires encaissé, sans autre critère. Résultat : beaucoup de contrats à fortes remises, une sinistralité élevée sur certains clients et peu de renouvellements, car les commerciaux préfèrent chasser de nouveaux contrats.',
          questions: ['Quels effets pervers le système produit-il ?', 'Proposez un nouveau plan.'],
          solution: 'Effets pervers : commission sur le **CA** (donc incitation aux remises), **aucun critère de qualité** (sinistralité) ni de **fidélisation** (renouvellements). Nouveau plan : fixe renforcé (60 % de la cible) ; commission sur la **marge technique** (primes − sinistres estimés) ; prime trimestrielle sur 3 critères : nouveaux contrats (40 %), **taux de renouvellement** (40 %), **encaissement à 30 jours** (20 %) ; seuil de déclenchement à 80 %, accélérateur au-delà de 100 %, plafond à 150 %. Simulation sur l’historique avant déploiement, puis présentation transparente aux équipes.' }
      ]
    }
  ],
  takeaways: [
    'Dimensionner par la charge de travail : visites nécessaires ÷ capacité d’un commercial.',
    'Organisation géographique, par produit, par client ou hybride selon la complexité et la diversité.',
    'Variable sur la marge, 2 à 4 critères, seuil, accélérateur, plafond.',
    'Toujours simuler un plan de rémunération sur l’historique avant de le déployer.'
  ],
  deliverable: { title: 'Plan d’organisation et de rémunération', x: 'Le calcul de dimensionnement de votre force de vente, l’organigramme cible justifié et une grille de rémunération variable simulée sur 3 profils (sous-performant, à l’objectif, en dépassement).' },
  quiz: [
    { q: '20 000 visites nécessaires, capacité de 800 visites par commercial : combien de commerciaux ?', options: ['20', '25', '16', '80'], a: 1, why: '20 000 ÷ 800 = 25.' },
    { q: 'Quelle organisation pour une offre simple et des clients homogènes ?', options: ['Par produit', 'Géographique', 'Matricielle', 'Par client'], a: 1, why: 'Elle est simple, économique et réduit les déplacements.' },
    { q: 'Pourquoi commissionner sur la marge plutôt que sur le CA ?', options: ['C’est plus simple', 'Pour ne pas inciter aux remises qui détruisent la rentabilité', 'C’est obligatoire', 'Pour payer moins'], a: 1, why: 'Le commercial devient attentif à la rentabilité de ses ventes.' },
    { q: 'À quoi sert un seuil de déclenchement ?', options: ['À payer plus', 'À ne pas rémunérer la sous-performance', 'À plafonner la prime', 'À calculer le fixe'], a: 1, why: 'En dessous du seuil, aucune prime n’est versée.' },
    { q: 'Combien de critères dans une prime sur objectifs ?', options: ['Un seul', '2 à 4', '10', 'Aucun'], a: 1, why: 'Trop de critères diluent l’attention et rendent le système illisible.' },
    { q: 'Quel critère manquait dans le plan de l’assureur ?', options: ['Le nombre de visites', 'Le renouvellement et la qualité des contrats', 'L’ancienneté', 'Le nombre d’appels'], a: 1, why: 'Sans eux, les commerciaux privilégiaient le volume au détriment de la rentabilité.' },
    { q: 'Que faire avant de déployer un nouveau plan de rémunération ?', options: ['L’imposer immédiatement', 'Le simuler sur l’historique et l’expliquer aux équipes', 'Le garder secret', 'Supprimer le fixe'], a: 1, why: 'La simulation évite les surprises et la transparence crée l’adhésion.' }
  ]
};
