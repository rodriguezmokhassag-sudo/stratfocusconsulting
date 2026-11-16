// Module R2 — Segmentation et gestion du portefeuille clients (ABC, RFM)
module.exports = {
  id: 'R2', title: 'Segmentation et gestion du portefeuille clients', status: 'complet', duration: '65 min',
  summary: 'Classer ses clients avec l’analyse ABC (Pareto) et la méthode RFM, croiser valeur et potentiel, et définir une politique de service par segment.',
  objectives: [
    'Réaliser une analyse ABC de son portefeuille',
    'Segmenter ses clients avec la méthode RFM (Récence, Fréquence, Montant)',
    'Construire une matrice valeur actuelle / potentiel',
    'Définir un niveau de service et une fréquence de visite par segment'
  ],
  skills: ['Analyse ABC / Pareto', 'Segmentation RFM', 'Politique de service par segment'],
  video: {
    title: '20 % de vos clients font 80 % de vos ventes', duration: '6 min', src: null,
    script: [
      'Accroche : « Traitez-vous tous vos clients de la même façon ? C’est une erreur coûteuse. »',
      'La loi de Pareto, avec un graphique à l’écran.',
      'La méthode RFM pas à pas dans un tableur.',
      'La matrice valeur / potentiel.',
      'Une politique de service par segment.'
    ]
  },
  lessons: [
    {
      title: 'L’analyse ABC (loi de Pareto)',
      blocks: [
        { t: 'p', x: 'La **loi de Pareto** observe que, souvent, environ **20 % des clients réalisent 80 % du chiffre d’affaires**. L’analyse ABC classe les clients par CA décroissant pour identifier ceux qui comptent le plus.' },
        { t: 'steps', items: [
          { title: 'Extraire', x: 'Le CA des 12 derniers mois par client (logiciel de facturation, ERP, cahier de ventes).' },
          { title: 'Trier', x: 'Du plus gros au plus petit.' },
          { title: 'Cumuler', x: 'Calculer le CA cumulé et le pourcentage cumulé.' },
          { title: 'Classer', x: 'A = jusqu’à 80 % du CA cumulé ; B = de 80 à 95 % ; C = les 5 % restants.' }
        ]},
        { t: 'table', caption: 'Résultat type (distributeur de produits alimentaires, Cotonou : 400 clients)', head: ['Classe', 'Nombre de clients', '% des clients', '% du CA'], rows: [
          ['A', '72', '18 %', '80 %'],
          ['B', '108', '27 %', '15 %'],
          ['C', '220', '55 %', '5 %']
        ]},
        { t: 'tip', x: 'L’analyse ABC dit **qui compte aujourd’hui**, pas qui comptera demain. Un petit client C peut être un futur A : d’où la matrice valeur / potentiel.' }
      ]
    },
    {
      title: 'La segmentation RFM',
      blocks: [
        { t: 'p', x: 'La méthode **RFM** note chaque client selon trois critères comportementaux. Elle est très utile pour le commerce de détail, la distribution et le e-commerce, et pour cibler les relances.' },
        { t: 'table', caption: 'Les 3 critères (note de 1 à 5)', head: ['Critère', 'Question', 'Note 5', 'Note 1'], rows: [
          ['**R**écence', 'Quand a-t-il acheté pour la dernière fois ?', 'Moins de 15 jours', 'Plus de 6 mois'],
          ['**F**réquence', 'Combien de fois a-t-il acheté sur 12 mois ?', 'Plus de 24 fois', '1 fois'],
          ['**M**ontant', 'Combien a-t-il dépensé sur 12 mois ?', 'Plus de 10 M FCFA', 'Moins de 200 000 FCFA']
        ]},
        { t: 'table', caption: 'Segments RFM et actions', head: ['Segment', 'Profil RFM', 'Action recommandée'], rows: [
          ['Champions', 'R5 F5 M5', 'Programme VIP, accès en avant-première, demande de recommandations'],
          ['Fidèles', 'R4-5, F4-5', 'Montée en gamme, vente croisée'],
          ['Nouveaux prometteurs', 'R5, F1-2', 'Accueil soigné, 2e achat encouragé rapidement'],
          ['À risque', 'R2-3, anciens F et M élevés', 'Appel personnel du responsable, offre de reconquête'],
          ['Perdus', 'R1, F1-2', 'Campagne de réactivation peu coûteuse, sinon abandon']
        ]},
        { t: 'action', x: 'Dans un tableur, calculez R, F et M pour vos clients et listez vos 10 clients « à risque ».' }
      ]
    },
    {
      title: 'Valeur, potentiel et politique de service',
      blocks: [
        { t: 'matrix', caption: 'Matrice valeur actuelle / potentiel', x: 'Valeur actuelle (CA) →', y: 'Potentiel de croissance ↑', q: [
          { title: 'À développer', x: 'Petit aujourd’hui, gros potentiel : plan de conquête, visites fréquentes' },
          { title: 'Stratégiques', x: 'Gros et à fort potentiel : responsable dédié, plan de compte' },
          { title: 'À rentabiliser', x: 'Petit et faible potentiel : vente à distance, WhatsApp, commandes groupées' },
          { title: 'À fidéliser', x: 'Gros mais mature : sécuriser, service irréprochable, défendre la marge' }
        ]},
        { t: 'table', caption: 'Politique de service par segment', head: ['Segment', 'Fréquence de contact', 'Canal', 'Conditions'], rows: [
          ['Stratégiques', 'Hebdomadaire', 'Visite + revue trimestrielle avec la direction', 'Conditions négociées, livraison prioritaire'],
          ['À fidéliser', 'Tous les 15 jours', 'Visite + WhatsApp', 'Programme de fidélité'],
          ['À développer', 'Tous les 15 jours', 'Visite ciblée', 'Offres de lancement, essais'],
          ['À rentabiliser', 'Mensuelle', 'Téléphone, WhatsApp, commande en ligne', 'Tarif standard, minimum de commande']
        ]},
        { t: 'case', title: 'Étude de cas : DistriCo, distributeur FMCG à Cotonou',
          context: 'DistriCo a 400 clients et 6 commerciaux qui visitent tout le monde chaque semaine. Les commerciaux sont débordés, les gros clients se plaignent d’un service insuffisant et 220 petits clients ne représentent que 5 % du CA. Le coût moyen d’une visite est estimé à 6 000 FCFA.',
          questions: ['Combien coûtent par an les visites hebdomadaires aux 220 clients C ?', 'Quelle organisation proposez-vous ?'],
          solution: 'Coût : 220 clients × 52 semaines × 6 000 FCFA = **68,6 M FCFA par an** pour 5 % du CA. Organisation : 1) clients **C à faible potentiel** : commande par WhatsApp ou téléphone, visite mensuelle, minimum de commande et livraison groupée ; 2) clients **C à fort potentiel** repérés avec la matrice : visites tous les 15 jours avec un plan de développement ; 3) clients **A** : visite hebdomadaire, revue trimestrielle, livraison prioritaire. Le temps libéré (plus de 60 % des visites) est réinvesti sur les A et la conquête.' }
      ]
    }
  ],
  takeaways: [
    'ABC : environ 20 % des clients font 80 % du CA.',
    'RFM : Récence, Fréquence, Montant, pour cibler les actions (champions, à risque, perdus).',
    'Matrice valeur / potentiel : stratégiques, à développer, à fidéliser, à rentabiliser.',
    'Un niveau de service et un canal par segment.'
  ],
  deliverable: { title: 'Segmentation de mon portefeuille', x: 'Analyse ABC et notation RFM de votre portefeuille dans un tableur, matrice valeur / potentiel avec vos 20 premiers clients, et politique de service par segment (fréquence, canal, conditions).' },
  quiz: [
    { q: 'Selon la loi de Pareto, environ quelle part des clients fait 80 % du CA ?', options: ['80 %', '20 %', '50 %', '5 %'], a: 1, why: 'C’est la règle des 80/20.' },
    { q: 'Dans la méthode RFM, que mesure le « R » ?', options: ['Le revenu', 'La récence du dernier achat', 'La rentabilité', 'La remise'], a: 1, why: 'Plus le dernier achat est récent, plus le client est actif.' },
    { q: 'Un ancien gros client qui n’a pas acheté depuis 3 mois est…', options: ['Un champion', 'À risque', 'Un nouveau prometteur', 'Sans importance'], a: 1, why: 'Ses anciens montants sont élevés mais sa récence baisse : il faut agir vite.' },
    { q: 'Un client qui achète peu aujourd’hui mais a un fort potentiel est…', options: ['À rentabiliser', 'À développer', 'Stratégique', 'À abandonner'], a: 1, why: 'Il mérite un plan de conquête.' },
    { q: 'Quel canal privilégier pour les petits clients à faible potentiel ?', options: ['Une visite hebdomadaire', 'La vente à distance (WhatsApp, téléphone)', 'Un responsable dédié', 'Aucun contact'], a: 1, why: 'Un canal moins coûteux préserve la rentabilité.' },
    { q: 'Combien coûtent par an 100 visites hebdomadaires à 5 000 FCFA ?', options: ['500 000 FCFA', '26 M FCFA', '5 M FCFA', '52 000 FCFA'], a: 1, why: '100 × 52 × 5 000 = 26 000 000 FCFA.' },
    { q: 'Quelle est la limite de l’analyse ABC seule ?', options: ['Elle est trop complexe', 'Elle ne dit rien du potentiel futur', 'Elle ne fonctionne pas en Afrique', 'Elle ignore les gros clients'], a: 1, why: 'Elle photographie le présent : il faut la croiser avec le potentiel.' }
  ]
};
