// Module D3 — Pricing stratégique
module.exports = {
  id: 'D3', title: 'Pricing stratégique', status: 'complet', duration: '65 min',
  summary: 'Fixer ses prix selon les coûts, la concurrence et surtout la valeur perçue, construire une politique de remises maîtrisée et augmenter ses prix sans perdre ses clients.',
  objectives: [
    'Distinguer prix coût, prix concurrence et prix valeur',
    'Construire une architecture de prix (gammes, petits formats, prix psychologiques)',
    'Mettre en place une politique de remises et la cascade de prix nette',
    'Conduire une hausse de prix en contexte d’inflation'
  ],
  skills: ['Stratégie de prix', 'Politique de remises', 'Gestion des hausses de prix'],
  video: {
    title: 'Le prix est le levier de profit le plus puissant', duration: '6 min', src: null,
    script: [
      'Accroche : « Une hausse de prix de 1 % peut augmenter le résultat bien plus qu’une hausse de volume de 1 %. »',
      'Les 3 logiques de prix sur un exemple de ciment.',
      'Petits formats et prix psychologiques en Afrique.',
      'La cascade de prix : du prix catalogue au prix net.',
      'Annoncer une hausse : méthode en 5 étapes.'
    ]
  },
  lessons: [
    {
      title: 'Les trois logiques de prix',
      blocks: [
        { t: 'table', caption: 'Coût, concurrence, valeur', head: ['Logique', 'Principe', 'Avantage', 'Risque'], rows: [
          ['Prix coût (« cost plus »)', 'Coût de revient + marge visée', 'Simple, couvre les coûts', 'Ignore ce que le client est prêt à payer'],
          ['Prix concurrence', 'Se caler sur les concurrents', 'Prudent sur un marché banalisé', 'Guerre des prix, aucune différenciation'],
          ['Prix valeur', 'Prix fixé selon la valeur perçue et l’économie apportée au client', 'Maximise la marge, valorise l’innovation', 'Demande de bien connaître le client']
        ]},
        { t: 'p', x: 'Le **prix plancher** est le coût. Le **prix plafond** est la valeur perçue par le client. La concurrence indique où vous situer entre les deux.' },
        { t: 'flow', caption: 'Construire un prix valeur', items: ['Prix de l’alternative du client', '+ valeur des bénéfices supplémentaires', '− valeur des inconvénients', '= valeur économique pour le client', 'Prix fixé en partageant cette valeur'] },
        { t: 'tip', x: 'Avec une marge nette de 5 %, une hausse de prix de 1 % à volume constant augmente le résultat de **20 %**. Le prix est le levier le plus puissant et le plus négligé.' }
      ]
    },
    {
      title: 'Architecture de prix et remises',
      blocks: [
        { t: 'table', caption: 'Outils d’architecture de prix adaptés aux marchés africains', head: ['Outil', 'Exemple', 'Objectif'], rows: [
          ['Petits formats (« sachets »)', 'Lessive en dose de 100 FCFA, crédit téléphonique à 200 FCFA', 'Rendre le produit accessible aux budgets journaliers'],
          ['Gamme bon / mieux / meilleur', 'Forfaits data Essentiel / Plus / Premium', 'Capter plusieurs segments, orienter vers l’offre du milieu'],
          ['Prix psychologiques', '4 950 FCFA plutôt que 5 000 FCFA', 'Diminuer la perception du prix'],
          ['Prix d’appel', 'Un produit vendu à faible marge pour attirer', 'Générer du trafic et des ventes associées'],
          ['Offres groupées (bundles)', 'Téléphone + forfait 3 mois', 'Augmenter le panier, rendre la comparaison difficile']
        ]},
        { t: 'table', caption: 'La cascade de prix : du catalogue au prix net (exemple B2B)', head: ['Élément', 'Montant (FCFA)'], rows: [
          ['Prix catalogue', '100 000'],
          ['− Remise quantitative', '− 8 000'],
          ['− Remise de fin d’année (RFA)', '− 3 000'],
          ['− Escompte paiement comptant', '− 2 000'],
          ['− Transport offert', '− 2 500'],
          ['**Prix net de poche**', '**84 500 (−15,5 %)**']
        ]},
        { t: 'action', x: 'Calculez la cascade de prix de vos 5 plus gros clients. L’écart entre prix catalogue et prix net vous surprend-il ?' }
      ]
    },
    {
      title: 'Augmenter ses prix sans perdre ses clients',
      blocks: [
        { t: 'steps', items: [
          { title: 'Analyser', x: 'Mesurer l’effet de la hausse des coûts sur la marge par produit et par client.' },
          { title: 'Segmenter', x: 'Hausse plus forte là où la valeur perçue est élevée, plus faible sur les produits d’appel ou très comparés.' },
          { title: 'Préparer les arguments', x: 'Hausse des matières premières, du fret, du change, avec des faits vérifiables.' },
          { title: 'Annoncer tôt et clairement', x: 'Prévenir 30 à 60 jours avant par écrit, puis rendez-vous avec les grands comptes.' },
          { title: 'Accompagner', x: 'Proposer des alternatives : format différent, engagement de volume, prix garanti 6 mois.' }
        ]},
        { t: 'matrix', caption: 'Où augmenter les prix ?', x: 'Sensibilité au prix du client →', y: 'Valeur perçue / différenciation ↑', q: [
          { title: 'Augmenter franchement', x: 'Forte valeur, faible sensibilité : clients fidèles, produits spécifiques' },
          { title: 'Augmenter avec arguments', x: 'Forte valeur mais client sensible : justifier, proposer des contreparties' },
          { title: 'Augmenter modérément', x: 'Peu différencié mais peu sensible : petites hausses régulières' },
          { title: 'Protéger ou repenser', x: 'Banalisé et très sensible : petits formats, réduction des coûts, nouvelle offre' }
        ]},
        { t: 'case', title: 'Étude de cas : la hausse du prix de l’huile en Guinée',
          context: 'Un industriel guinéen subit +18 % sur le coût de l’huile brute importée. Il hésite entre absorber la hausse (sa marge nette passerait de 6 % à −2 %) et augmenter tous ses prix de 18 % d’un coup. Ses clients sont des grossistes très sensibles au prix et des ménages au budget serré.',
          questions: ['Pourquoi aucune des deux options n’est-elle satisfaisante ?', 'Quelle stratégie de prix proposez-vous ?'],
          solution: 'Absorber met l’entreprise **en perte**. Augmenter de 18 % d’un coup sur un marché très sensible risque un **effondrement des volumes** au profit des concurrents. Stratégie : 1) hausse **progressive** en 2 étapes (+8 % puis +6 % trois mois plus tard), annoncée 45 jours à l’avance avec des arguments chiffrés ; 2) **petits formats** (sachets de 250 ml) pour garder un prix accessible aux ménages, en **réduflation** transparente ; 3) **prix garanti 6 mois** aux grossistes qui s’engagent sur un volume ; 4) baisse des coûts (achats groupés, emballages) pour combler le reste.' }
      ]
    }
  ],
  takeaways: [
    'Coût = plancher, valeur perçue = plafond, concurrence = positionnement.',
    'Petits formats, gammes, prix psychologiques et bundles adaptent le prix au pouvoir d’achat.',
    'Piloter le prix net de poche, pas seulement le prix catalogue.',
    'Hausse de prix : analyser, segmenter, argumenter, annoncer tôt, proposer des alternatives.'
  ],
  deliverable: { title: 'Politique de prix', x: 'Le calcul du prix valeur d’un produit, la cascade de prix de vos 5 principaux clients et un plan de hausse de prix segmenté (produits, clients, calendrier, arguments).' },
  quiz: [
    { q: 'Quelle logique de prix maximise la marge d’une offre innovante ?', options: ['Prix coût', 'Prix valeur', 'Prix concurrence', 'Prix d’appel'], a: 1, why: 'Le prix valeur capte une partie de la valeur créée pour le client.' },
    { q: 'Le prix plancher correspond…', options: ['À la valeur perçue', 'Au coût de revient', 'Au prix du concurrent', 'Au prix psychologique'], a: 1, why: 'En dessous du coût, chaque vente fait perdre de l’argent.' },
    { q: 'Vendre de la lessive en dose de 100 FCFA est un exemple…', options: ['De bundle', 'De petit format adapté au budget journalier', 'De prix d’appel', 'De remise quantitative'], a: 1, why: 'Il rend le produit accessible aux budgets journaliers.' },
    { q: 'Le « prix net de poche » est…', options: ['Le prix catalogue', 'Le prix réellement encaissé après toutes les remises', 'Le prix du concurrent', 'Le coût de revient'], a: 1, why: 'C’est ce que l’entreprise gagne réellement.' },
    { q: 'Avec 5 % de marge nette, une hausse de prix de 1 % à volume constant augmente le résultat de…', options: ['1 %', '20 %', '5 %', '100 %'], a: 1, why: 'Le point de prix gagné représente 1 ÷ 5 = 20 % de résultat en plus.' },
    { q: 'Que proposer à un client fidèle très sensible au prix lors d’une hausse ?', options: ['Rien', 'Des contreparties : prix garanti, engagement de volume, format adapté', 'Une hausse double', 'De changer de fournisseur'], a: 1, why: 'On préserve la relation tout en protégeant la marge.' },
    { q: 'Quelle stratégie convenait à l’industriel guinéen ?', options: ['Absorber toute la hausse', 'Une hausse progressive avec petits formats et engagements de volume', '+18 % immédiatement', 'Arrêter la production'], a: 1, why: 'Elle protège la marge sans faire fuir des clients très sensibles au prix.' }
  ]
};
