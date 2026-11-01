// Module R3 — Canaux de vente et distribution
module.exports = {
  id: 'R3', title: 'Canaux de vente et distribution', status: 'complet', duration: '65 min',
  summary: 'Cartographier les circuits de distribution formels et informels, calculer la rentabilité de chaque canal, gérer les conflits entre canaux et intégrer le social commerce.',
  objectives: [
    'Cartographier les circuits de distribution de son marché',
    'Calculer la cascade de prix et la rentabilité par canal',
    'Prévenir et gérer les conflits entre canaux',
    'Intégrer le e-commerce et le social commerce sans cannibaliser les distributeurs'
  ],
  skills: ['Cartographie des circuits de distribution', 'Rentabilité par canal', 'Stratégie omnicanale'],
  video: {
    title: 'Du grossiste au client final : qui gagne quoi ?', duration: '6 min', src: null,
    script: [
      'Accroche : « Votre produit passe par 3 ou 4 mains avant d’arriver chez le client. Connaissez-vous la marge de chacun ? »',
      'Le circuit type en Afrique de l’Ouest : importateur, grossiste, semi-grossiste, détaillant, boutiquier.',
      'La cascade de prix, calculée à l’écran.',
      'Les conflits de canaux et leurs règles.',
      'Le social commerce : WhatsApp, Facebook, livraison et paiement à la livraison.'
    ]
  },
  lessons: [
    {
      title: 'Les circuits de distribution en Afrique francophone',
      blocks: [
        { t: 'p', x: 'Dans la plupart des marchés de grande consommation d’Afrique francophone, le **commerce traditionnel** (marchés, boutiques de quartier, tabliers) reste dominant face à la grande distribution moderne. Un responsable commercial doit maîtriser les deux.' },
        { t: 'flow', caption: 'Le circuit traditionnel type', items: ['Fabricant / importateur', 'Distributeur agréé', 'Grossiste', 'Semi-grossiste', 'Détaillant / boutiquier', 'Consommateur'] },
        { t: 'table', caption: 'Comparaison des canaux', head: ['Canal', 'Avantages', 'Inconvénients'], rows: [
          ['Grossistes et semi-grossistes', 'Couverture très large, préfinancement, connaissance du terrain', 'Faible contrôle du prix final, dépendance'],
          ['Vente directe aux détaillants', 'Contrôle du merchandising et du prix, relation directe', 'Coût logistique élevé, nombreux petits clients'],
          ['Grande distribution (supermarchés)', 'Image, volumes réguliers', 'Marges arrière, délais de paiement longs, exigences fortes'],
          ['B2B direct (entreprises, administrations)', 'Gros volumes, contrats', 'Appels d’offres, délais de paiement'],
          ['E-commerce et social commerce', 'Données clients, marge, proximité', 'Logistique du dernier kilomètre, paiement à la livraison']
        ]},
        { t: 'action', x: 'Dessinez le circuit de distribution de votre produit principal et indiquez la part du volume passant par chaque canal.' }
      ]
    },
    {
      title: 'Cascade de prix et rentabilité par canal',
      blocks: [
        { t: 'p', x: 'Chaque intermédiaire prend une marge. La **cascade de prix** permet de fixer le prix de cession à chaque niveau tout en gardant un prix final cohérent pour le consommateur.' },
        { t: 'table', caption: 'Cascade de prix : carton de 24 boissons (prix final conseillé : 12 000 FCFA)', head: ['Niveau', 'Prix d’achat (FCFA)', 'Marge', 'Prix de vente (FCFA)'], rows: [
          ['Fabricant', '–', '–', '8 400'],
          ['Grossiste', '8 400', '6 %', '8 900'],
          ['Semi-grossiste', '8 900', '8 %', '9 600'],
          ['Détaillant', '9 600', '25 %', '12 000']
        ]},
        { t: 'table', caption: 'Rentabilité par canal (pour 100 M FCFA de CA)', head: ['Canal', 'Remise moyenne', 'Coût de service', 'Délai de paiement', 'Contribution nette'], rows: [
          ['Grossistes', '12 %', '2 %', 'Comptant', '86 M'],
          ['Détaillants en direct', '4 %', '11 %', '7 jours', '85 M'],
          ['Supermarchés', '8 % + 5 % de marges arrière', '4 %', '60 jours', '83 M avant coût du crédit'],
          ['WhatsApp + livraison', '0 %', '9 %', 'À la livraison', '91 M']
        ]},
        { t: 'tip', x: 'Un canal à fort volume n’est pas forcément le plus rentable. Intégrez toujours le **coût de service** et le **coût du délai de paiement**.' }
      ]
    },
    {
      title: 'Conflits de canaux et social commerce',
      blocks: [
        { t: 'table', caption: 'Conflits fréquents et règles de prévention', head: ['Conflit', 'Exemple', 'Règle'], rows: [
          ['Prix', 'Un grossiste revend sous le prix des semi-grossistes', 'Prix de revente conseillés, remises conditionnées au respect des zones'],
          ['Territoire', 'Un distributeur livre hors de sa zone', 'Zones exclusives écrites, suivi des factures par zone'],
          ['Vente directe', 'L’entreprise vend en direct aux clients de ses distributeurs', 'Liste des comptes réservés (grands comptes en direct, le reste aux distributeurs)'],
          ['En ligne', 'Prix en ligne plus bas que chez les détaillants', 'Même prix public partout, différenciation par le service (livraison, packs)']
        ]},
        { t: 'steps', items: [
          { title: 'Catalogue WhatsApp Business', x: 'Prix publics identiques aux points de vente.' },
          { title: 'Livraison locale', x: 'Par des partenaires (motos, tricycles) ou par les détaillants eux-mêmes, qui reçoivent une commission.' },
          { title: 'Paiement', x: 'Mobile Money ou paiement à la livraison.' },
          { title: 'Redirection', x: 'Les commandes hors zone de livraison sont orientées vers le détaillant le plus proche.' }
        ]},
        { t: 'case', title: 'Étude de cas : la marque de jus qui a fâché ses distributeurs',
          context: 'Une marque de jus de fruits à Abidjan lance la vente sur Facebook avec 15 % de remise et livraison gratuite. En un mois, les ventes en ligne décollent, mais trois grands distributeurs réduisent leurs commandes de 30 % et mettent en avant un concurrent.',
          questions: ['Quelle erreur la marque a-t-elle commise ?', 'Comment reconstruire une stratégie omnicanale ?'],
          solution: 'Erreur : un **prix en ligne inférieur** à celui des distributeurs, qui cannibalise leurs ventes et rompt la confiance. Stratégie : 1) **même prix public** en ligne et en magasin ; 2) le digital comme **service** (packs famille, abonnement hebdomadaire, livraison au bureau) plutôt que comme remise ; 3) livraison assurée **par les distributeurs** de la zone, rémunérés ; 4) communication commune : « disponible chez votre revendeur et en livraison » ; 5) réunion avec les distributeurs pour présenter ces règles par écrit.' }
      ]
    }
  ],
  takeaways: [
    'Maîtriser le commerce traditionnel (grossiste, semi-grossiste, détaillant) et les canaux modernes.',
    'La cascade de prix fixe la marge de chaque niveau à partir du prix final conseillé.',
    'Rentabilité d’un canal = volume − remises − coût de service − coût du délai de paiement.',
    'Omnicanal : même prix public partout, différenciation par le service.'
  ],
  deliverable: { title: 'Carte et politique de distribution', x: 'La carte de vos circuits de distribution avec les volumes, la cascade de prix de votre produit principal, un tableau de rentabilité par canal et 5 règles écrites pour prévenir les conflits.' },
  quiz: [
    { q: 'Quel canal reste souvent dominant pour les produits de grande consommation en Afrique francophone ?', options: ['Les supermarchés', 'Le commerce traditionnel (marchés, boutiques)', 'Le e-commerce', 'La vente par catalogue'], a: 1, why: 'Le commerce traditionnel représente encore une part majeure des volumes.' },
    { q: 'À quoi sert la cascade de prix ?', options: ['À fixer les salaires', 'À fixer le prix de cession à chaque niveau jusqu’au prix final', 'À calculer la TVA', 'À choisir les produits'], a: 1, why: 'Elle garantit une marge à chaque intermédiaire et un prix final cohérent.' },
    { q: 'Un détaillant achète 9 600 FCFA et vend 12 000 FCFA. Quel est son taux de marge sur le prix d’achat ?', options: ['20 %', '25 %', '12 %', '2 400 %'], a: 1, why: '(12 000 − 9 600) ÷ 9 600 = 25 %.' },
    { q: 'Quel élément est souvent oublié dans la rentabilité d’un canal ?', options: ['Le volume', 'Le coût de service et du délai de paiement', 'Le nom du client', 'La couleur de l’emballage'], a: 1, why: 'Un canal à gros volume peut être peu rentable une fois ces coûts intégrés.' },
    { q: 'Quelle est la règle d’or de l’omnicanal ?', options: ['Prix plus bas en ligne', 'Même prix public partout, différenciation par le service', 'Supprimer les distributeurs', 'Vendre uniquement en ligne'], a: 1, why: 'Cela évite la cannibalisation et préserve la confiance des partenaires.' },
    { q: 'Pourquoi les distributeurs de la marque de jus ont-ils réduit leurs commandes ?', options: ['Le jus était mauvais', 'La marque vendait moins cher en ligne qu’eux', 'Ils manquaient de place', 'Le prix avait augmenté'], a: 1, why: 'La vente directe moins chère a cannibalisé leurs ventes.' }
  ]
};
