// Module R4 — Prévisions et budget des ventes
module.exports = {
  id: 'R4', title: 'Prévisions et budget des ventes', status: 'complet', duration: '60 min',
  summary: 'Prévoir ses ventes avec des méthodes simples, intégrer la saisonnalité africaine, construire un budget commercial et piloter la marge.',
  objectives: [
    'Réaliser une prévision des ventes (historique, tendance, coefficients saisonniers)',
    'Intégrer les saisonnalités locales (Ramadan, Tabaski, fêtes, rentrée, campagnes agricoles)',
    'Construire le budget commercial de sa zone',
    'Mesurer l’impact d’une remise sur la marge'
  ],
  skills: ['Prévision des ventes', 'Budget commercial', 'Pilotage de la marge'],
  video: {
    title: 'Prévoir sans boule de cristal', duration: '6 min', src: null,
    script: [
      'Accroche : « Une prévision fausse coûte deux fois : en ruptures et en invendus. »',
      'La moyenne mobile et la tendance dans un tableur.',
      'Les coefficients saisonniers : l’exemple de la Tabaski.',
      'Le budget commercial en 5 lignes.',
      'Ce qu’une remise de 10 % coûte vraiment.'
    ]
  },
  lessons: [
    {
      title: 'Méthodes de prévision simples',
      blocks: [
        { t: 'p', x: 'Pas besoin de logiciel coûteux : un tableur et 2 à 3 ans d’historique suffisent pour une prévision fiable à 10-15 % près. On combine **chiffres** (historique) et **terrain** (avis des commerciaux, plans des clients).' },
        { t: 'table', caption: 'Trois méthodes complémentaires', head: ['Méthode', 'Principe', 'Usage'], rows: [
          ['Moyenne mobile', 'Moyenne des 3 derniers mois', 'Lisser les variations, court terme'],
          ['Tendance (croissance annuelle)', 'Ventes N-1 × (1 + taux de croissance observé ou visé)', 'Budget annuel'],
          ['Prévision terrain (bottom-up)', 'Somme des prévisions de chaque commercial par client', 'Grands comptes, B2B'],
        ]},
        { t: 'steps', items: [
          { title: 'Collecter', x: 'Ventes mensuelles des 24 à 36 derniers mois, par produit et par zone.' },
          { title: 'Nettoyer', x: 'Retirer les événements exceptionnels (rupture longue, commande unique géante).' },
          { title: 'Calculer la tendance', x: 'Taux de croissance annuel moyen.' },
          { title: 'Appliquer la saisonnalité', x: 'Coefficients mensuels (leçon suivante).' },
          { title: 'Confronter au terrain', x: 'Ajuster avec les commerciaux et les grands clients.' }
        ]}
      ]
    },
    {
      title: 'La saisonnalité en Afrique francophone',
      blocks: [
        { t: 'p', x: 'Le **coefficient saisonnier** d’un mois = ventes moyennes de ce mois ÷ moyenne mensuelle de l’année. Un coefficient de 1,4 signifie que le mois vend 40 % de plus qu’un mois moyen.' },
        { t: 'table', caption: 'Événements qui font varier les ventes', head: ['Période', 'Effet typique', 'Secteurs concernés'], rows: [
          ['Ramadan', 'Hausse des produits alimentaires (sucre, lait, dattes, boissons), baisse d’activité en journée', 'Agroalimentaire, distribution'],
          ['Tabaski / Aïd el-Kébir', 'Forte hausse : moutons, habillement, cosmétiques, transferts d’argent', 'Commerce, mode, Mobile Money'],
          ['Fêtes de fin d’année', 'Hausse des boissons, cadeaux, électronique, voyages', 'Distribution, télécoms'],
          ['Rentrée scolaire (septembre-octobre)', 'Fournitures, uniformes, frais de scolarité : la consommation courante se contracte', 'Papeterie, banque, assurance'],
          ['Campagnes agricoles (cacao, coton, anacarde)', 'Pouvoir d’achat rural en hausse après la commercialisation des récoltes', 'Intrants, motos, téléphonie, matériaux'],
          ['Saison des pluies', 'Ralentissement du BTP et des déplacements', 'Matériaux, logistique']
        ]},
        { t: 'table', caption: 'Exemple : prévision d’un fabricant de boissons à Dakar (base 100 M FCFA / mois)', head: ['Mois', 'Coefficient', 'Prévision (M FCFA)'], rows: [
          ['Mars (Ramadan)', '1,35', '135'],
          ['Juin (Tabaski)', '1,25', '125'],
          ['Août (hivernage)', '0,80', '80'],
          ['Octobre (rentrée)', '0,85', '85'],
          ['Décembre (fêtes)', '1,30', '130']
        ]},
        { t: 'tip', x: 'Les fêtes religieuses suivent le **calendrier lunaire** : elles avancent d’environ 11 jours chaque année. Recalculez les coefficients au bon mois.' }
      ]
    },
    {
      title: 'Budget commercial et pilotage de la marge',
      blocks: [
        { t: 'table', caption: 'Budget commercial annuel d’une zone (en M FCFA)', head: ['Ligne', 'Montant', 'Commentaire'], rows: [
          ['CA prévisionnel', '1 200', 'Prévision par produit × prix'],
          ['Marge brute (32 %)', '384', 'CA − coût des produits vendus'],
          ['Coûts de la force de vente', '96', '8 commerciaux : salaires, commissions, déplacements'],
          ['Actions commerciales et marketing', '36', 'Promotions, PLV, salons, digital'],
          ['Contribution commerciale', '252', 'Marge brute − coûts commerciaux (21 % du CA)']
        ]},
        { t: 'p', x: 'Une remise paraît petite mais elle se prend **intégralement sur la marge**. Il faut vendre beaucoup plus pour la compenser.' },
        { t: 'table', caption: 'Volume supplémentaire nécessaire pour compenser une remise (marge initiale de 30 %)', head: ['Remise accordée', 'Nouvelle marge', 'Hausse de volume nécessaire'], rows: [
          ['5 %', '25 %', '+20 %'],
          ['10 %', '20 %', '+50 %'],
          ['15 %', '15 %', '+100 %']
        ]},
        { t: 'case', title: 'Étude de cas : la promotion qui a fait perdre de l’argent',
          context: 'Un distributeur de riz à Conakry (marge brute 20 %) lance une promotion de −10 % pendant un mois. Les volumes augmentent de 30 % et l’équipe fête « un mois record ». Le directeur financier annonce pourtant une baisse de la marge.',
          questions: ['Calculez la marge avant et pendant la promotion pour 100 M de CA de base.', 'Que fallait-il faire ?'],
          solution: 'Avant : 100 M de CA × 20 % = **20 M** de marge. Pendant : le prix baisse de 10 %, la marge unitaire passe de 20 à 10 % du prix initial (la moitié). CA = 100 × 1,3 × 0,9 = 117 M ; coût d’achat = 80 × 1,3 = 104 M ; marge = **13 M**, soit 7 M de moins malgré le « record ». Il aurait fallu +100 % de volume pour compenser. Alternatives : **promotion en volume** (11 sacs pour 10), remise ciblée sur un produit à forte marge, ou remise conditionnée à une commande minimale ou au paiement comptant.' }
      ]
    }
  ],
  takeaways: [
    'Prévoir = historique nettoyé + tendance + saisonnalité + confrontation terrain.',
    'Coefficient saisonnier = ventes du mois ÷ moyenne mensuelle. Les fêtes lunaires avancent d’environ 11 jours par an.',
    'Budget : CA, marge brute, coûts commerciaux, contribution.',
    'Une remise se prend sur la marge : calculer le volume nécessaire pour la compenser.'
  ],
  deliverable: { title: 'Prévision et budget de ma zone', x: 'Un tableur avec la prévision mensuelle des 12 prochains mois (tendance + coefficients saisonniers), le budget commercial en 5 lignes et la simulation de l’impact d’une remise de 5 % et de 10 %.' },
  quiz: [
    { q: 'Un mois vend 130 quand la moyenne mensuelle est de 100. Son coefficient saisonnier est…', options: ['0,77', '1,3', '130', '30'], a: 1, why: '130 ÷ 100 = 1,3.' },
    { q: 'Pourquoi les dates de Ramadan et de Tabaski changent-elles chaque année ?', options: ['Décision administrative', 'Elles suivent le calendrier lunaire', 'Elles sont aléatoires', 'Elles ne changent pas'], a: 1, why: 'Le calendrier lunaire est plus court d’environ 11 jours.' },
    { q: 'La prévision « bottom-up » consiste à…', options: ['Partir de l’objectif de la direction', 'Additionner les prévisions de chaque commercial par client', 'Copier l’année précédente', 'Utiliser une moyenne mobile'], a: 1, why: 'Elle part du terrain, client par client.' },
    { q: 'Avec 30 % de marge, quelle hausse de volume compense une remise de 10 % ?', options: ['+10 %', '+50 %', '+30 %', '+5 %'], a: 1, why: 'La marge passe de 30 à 20 % : il faut vendre 1,5 fois plus.' },
    { q: 'Contribution commerciale = …', options: ['CA − TVA', 'Marge brute − coûts commerciaux', 'CA × marge', 'Salaires + commissions'], a: 1, why: 'Elle mesure ce que l’activité commerciale rapporte réellement.' },
    { q: 'Pourquoi la promotion de Conakry a-t-elle fait perdre de l’argent ?', options: ['Les volumes ont baissé', 'La hausse de volume (+30 %) ne compensait pas la remise', 'Le riz était périmé', 'Les prix ont augmenté'], a: 1, why: 'Avec 20 % de marge, une remise de 10 % exigeait +100 % de volume.' },
    { q: 'Quelle alternative préserve mieux la marge ?', options: ['Une remise de 20 %', 'Une promotion en volume conditionnée (11 pour 10)', 'Baisser les prix toute l’année', 'Supprimer la marge'], a: 1, why: 'Elle augmente les volumes avec une concession moindre et conditionnée.' }
  ]
};
