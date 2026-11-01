// Module C2 — Argumentation et traitement des objections
module.exports = {
  id: 'C2', title: 'Argumentation et traitement des objections', status: 'complet', duration: '65 min',
  summary: 'Construire des arguments CAP qui parlent au client, classer les objections et y répondre avec la méthode ACRA, y compris le fameux « c’est trop cher ».',
  objectives: [
    'Transformer une caractéristique produit en bénéfice client (méthode CAP)',
    'Identifier les familles d’objections (vraies, fausses, prétextes)',
    'Répondre aux objections avec la méthode ACRA',
    'Traiter l’objection prix sans brader'
  ],
  skills: ['Argumentation CAP', 'Traitement des objections (ACRA)', 'Défense du prix'],
  video: {
    title: 'Répondre à « c’est trop cher »', duration: '6 min', src: null,
    script: [
      'Accroche : « Une objection n’est pas un refus, c’est une demande d’information. »',
      'CAP : Caractéristique, Avantage, Preuve, avec un exemple sur un groupe électrogène.',
      'Les 3 familles d’objections.',
      'ACRA en jeu de rôle : Accueillir, Creuser, Répondre, Avancer.',
      'Trois réponses à l’objection prix.'
    ]
  },
  lessons: [
    {
      title: 'Argumenter avec la méthode CAP',
      blocks: [
        { t: 'p', x: 'Un argument efficace ne décrit pas le produit : il explique **ce que le client y gagne**, et le prouve. La méthode **CAP** structure chaque argument en trois temps.' },
        { t: 'flow', caption: 'Un argument en trois temps', items: ['Caractéristique (ce que c’est)', 'Avantage (ce que ça apporte au client)', 'Preuve (pourquoi me croire)'] },
        { t: 'table', caption: 'CAP appliqué : vente d’un groupe électrogène à une boulangerie de Bamako', head: ['Caractéristique', 'Avantage pour le client', 'Preuve'], rows: [
          ['Démarrage automatique en 10 secondes', 'Le four ne s’arrête pas pendant les coupures : pas de fournée perdue', 'Démonstration sur place, vidéo d’un client'],
          ['Consommation de 1,2 L/h', '30 % de carburant en moins, soit environ 90 000 FCFA économisés par mois', 'Fiche technique + calcul sur ses heures de coupure'],
          ['SAV à Bamako en 24 h', 'Pas d’arrêt prolongé en cas de panne', 'Liste de 15 clients locaux joignables']
        ]},
        { t: 'tip', x: 'Reliez chaque argument à un **besoin exprimé** pendant la découverte (module C1) : « Vous m’avez dit que… c’est pourquoi… ».' },
        { t: 'action', x: 'Rédigez 3 arguments CAP pour votre produit principal, chacun relié à une motivation SONCAS.' }
      ]
    },
    {
      title: 'Comprendre et classer les objections',
      blocks: [
        { t: 'p', x: 'Une objection montre que le client **réfléchit** à votre offre. Le silence et l’indifférence sont bien plus inquiétants. Avant de répondre, il faut savoir à quel type d’objection on a affaire.' },
        { t: 'table', caption: 'Les familles d’objections', head: ['Type', 'Exemple', 'Ce qu’elle cache', 'Attitude'], rows: [
          ['Objection vraie', '« Votre délai de 3 semaines est trop long »', 'Un vrai frein à lever', 'Répondre avec une solution ou une compensation'],
          ['Objection d’information', '« Ça marche comment, la garantie ? »', 'Un manque d’information', 'Expliquer, rassurer, prouver'],
          ['Objection prétexte', '« Je vais réfléchir »', 'Une autre raison non dite', 'Creuser : « Qu’est-ce qui vous fait hésiter ? »'],
          ['Objection de principe', '« Je ne travaille pas avec les nouveaux fournisseurs »', 'Une peur du risque', 'Réduire le risque : essai, petite commande, références']
        ]},
        { t: 'matrix', caption: 'Où se situe le client ?', x: 'Intérêt pour l’offre →', y: 'Clarté de l’objection ↑', q: [
          { title: 'Sceptique', x: 'Objection claire, intérêt faible : apporter des preuves fortes' },
          { title: 'Presque convaincu', x: 'Objection claire, intérêt fort : lever le frein et conclure' },
          { title: 'Indifférent', x: 'Objection floue, intérêt faible : revenir à la découverte' },
          { title: 'Hésitant', x: 'Objection floue, intérêt fort : creuser le vrai frein' }
        ]}
      ]
    },
    {
      title: 'La méthode ACRA et l’objection prix',
      blocks: [
        { t: 'steps', items: [
          { title: 'Accueillir', x: 'Montrer qu’on a entendu, sans contredire : « Je comprends que le budget soit important pour vous. »' },
          { title: 'Creuser', x: 'Faire préciser : « Trop cher par rapport à quoi ? À votre budget ? À une autre offre ? »' },
          { title: 'Répondre', x: 'Apporter un argument CAP ciblé sur le vrai frein.' },
          { title: 'Avancer', x: 'Vérifier et relancer : « Cela répond-il à votre question ? On regarde la livraison ? »' }
        ]},
        { t: 'table', caption: 'Trois techniques face à « c’est trop cher »', head: ['Technique', 'Principe', 'Exemple'], rows: [
          ['Le fractionnement', 'Ramener le prix à l’unité d’usage', '« 180 000 FCFA, soit 500 FCFA par jour sur un an, moins qu’une fournée perdue. »'],
          ['La comparaison du coût total', 'Comparer le coût sur la durée, pas le prix d’achat', '« Le modèle moins cher consomme 30 % de plus : vous payez la différence en 6 mois. »'],
          ['L’échange de concession', 'Ne jamais baisser sans contrepartie', '« Je peux faire un effort si vous prenez le contrat d’entretien sur 2 ans. »']
        ]},
        { t: 'case', title: 'Étude de cas : Moussa, quincaillier à Bamako',
          context: 'Moussa présente une peinture premium à 25 000 FCFA le seau à un entrepreneur du bâtiment. Celui-ci répond : « C’est trop cher, au marché je trouve à 15 000. » Moussa propose immédiatement 20 000 FCFA. L’entrepreneur demande alors 17 000.',
          questions: ['Quelle erreur Moussa a-t-il commise ?', 'Comment aurait-il dû répondre avec ACRA ?'],
          solution: 'Moussa a **baissé son prix sans creuser ni contrepartie** : il a montré que son prix n’était pas solide, d’où la nouvelle demande. Avec ACRA : **Accueillir** (« Je comprends, l’écart paraît important. ») ; **Creuser** (« Combien de couches faut-il avec la peinture du marché ? Vos clients se plaignent-ils de reprises ? ») ; **Répondre** par le coût total : la peinture premium couvre en 1 couche au lieu de 2, donc 2 seaux en moins et une journée de main-d’œuvre économisée par chantier ; **Avancer** : « On fait un essai sur votre prochain chantier ? » Si une concession est nécessaire, l’échanger contre un volume (10 seaux).' }
      ]
    }
  ],
  takeaways: [
    'CAP : Caractéristique, Avantage, Preuve, reliés à un besoin exprimé.',
    'Une objection est une demande d’information : vraie, d’information, prétexte ou de principe.',
    'ACRA : Accueillir, Creuser, Répondre, Avancer.',
    'Face au prix : fractionner, comparer le coût total, ne jamais concéder sans contrepartie.'
  ],
  deliverable: { title: 'Fiche « 10 objections, 10 réponses »', x: 'Listez les 10 objections que vous entendez le plus, classez-les par type et rédigez pour chacune une réponse ACRA avec une preuve.' },
  quiz: [
    { q: 'Dans la méthode CAP, que désigne le « A » ?', options: ['L’action', 'L’avantage pour le client', 'L’argument prix', 'L’accroche'], a: 1, why: 'L’avantage traduit la caractéristique en bénéfice concret pour le client.' },
    { q: '« Je vais réfléchir » est le plus souvent une objection…', options: ['Vraie', 'D’information', 'Prétexte', 'Technique'], a: 2, why: 'Elle cache souvent un autre frein qu’il faut faire émerger.' },
    { q: 'Quelle est la deuxième étape de la méthode ACRA ?', options: ['Argumenter', 'Creuser', 'Conclure', 'Comparer'], a: 1, why: 'On fait préciser l’objection avant d’y répondre.' },
    { q: 'Que signifie « fractionner » le prix ?', options: ['Accorder une remise', 'Ramener le prix à l’unité d’usage (par jour, par unité)', 'Payer en plusieurs fois uniquement', 'Diviser la commande'], a: 1, why: 'Un montant ramené à l’usage paraît plus accessible.' },
    { q: 'Quelle est la règle d’or d’une concession ?', options: ['La faire tout de suite', 'Toujours obtenir une contrepartie', 'Ne jamais en faire', 'La proposer avant que le client la demande'], a: 1, why: 'Une concession gratuite affaiblit votre position et appelle d’autres demandes.' },
    { q: 'Quelle était l’erreur de Moussa ?', options: ['Il a présenté un produit premium', 'Il a baissé son prix sans creuser ni contrepartie', 'Il a parlé du nombre de couches', 'Il a proposé un essai'], a: 1, why: 'Baisser immédiatement montre que le prix n’est pas justifié.' },
    { q: 'Un client à l’objection floue mais très intéressé est…', options: ['Indifférent', 'Hésitant : il faut creuser le vrai frein', 'Sceptique', 'Perdu'], a: 1, why: 'Son intérêt est réel : il faut identifier ce qui le retient.' }
  ]
};
