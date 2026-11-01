// Module D4 — Grands comptes et vente B2B complexe
module.exports = {
  id: 'D4', title: 'Grands comptes et vente B2B complexe', status: 'complet', duration: '65 min',
  summary: 'Cartographier le centre de décision d’un grand compte, bâtir un plan de compte stratégique et répondre efficacement aux appels d’offres publics et privés.',
  objectives: [
    'Cartographier les acteurs d’une décision d’achat complexe',
    'Construire un plan de compte stratégique',
    'Qualifier une opportunité avant d’y investir du temps',
    'Répondre à un appel d’offres de façon gagnante'
  ],
  skills: ['Gestion des grands comptes (KAM)', 'Cartographie du centre de décision', 'Réponse aux appels d’offres'],
  video: {
    title: 'Vendre à une organisation, pas à une personne', duration: '6 min', src: null,
    script: [
      'Accroche : « Dans une vente complexe, 6 à 10 personnes influencent la décision. Combien en connaissez-vous ? »',
      'La carte du centre de décision.',
      'Le plan de compte en une page.',
      'Qualifier une opportunité : go ou no go.',
      'Les 5 clés d’une réponse gagnante à un appel d’offres.'
    ]
  },
  lessons: [
    {
      title: 'Le centre de décision',
      blocks: [
        { t: 'p', x: 'Dans une grande entreprise, une administration ou une ONG, l’achat est une **décision collective**. Le commercial qui ne parle qu’à un seul interlocuteur s’expose à être bloqué par quelqu’un qu’il n’a jamais rencontré.' },
        { t: 'table', caption: 'Les rôles dans une décision d’achat', head: ['Rôle', 'Qui ?', 'Ce qui compte pour lui'], rows: [
          ['Décideur', 'DG, DAF, comité de direction', 'Retour sur investissement, risque, stratégie'],
          ['Acheteur', 'Direction des achats', 'Prix, conditions, conformité de la procédure'],
          ['Prescripteur', 'Direction technique, DSI, consultant', 'Performance technique, compatibilité'],
          ['Utilisateur', 'Équipes opérationnelles', 'Facilité d’utilisation, formation, support'],
          ['Filtre', 'Assistante, secrétariat, service juridique', 'Accès, conformité'],
          ['Coach (allié interne)', 'Toute personne favorable à votre solution', 'Vous aide à comprendre les enjeux internes']
        ]},
        { t: 'matrix', caption: 'Carte des acteurs : influence et attitude', x: 'Attitude envers notre offre (opposant → favorable) →', y: 'Influence sur la décision ↑', q: [
          { title: 'Opposants influents', x: 'Priorité absolue : comprendre leurs objections, apporter des preuves, rencontrer' },
          { title: 'Alliés influents', x: 'Sponsors : les impliquer, les équiper d’arguments internes' },
          { title: 'Opposants peu influents', x: 'Surveiller, éviter qu’ils ne rallient les influents' },
          { title: 'Alliés peu influents', x: 'Sources d’information, relais auprès des utilisateurs' }
        ]},
        { t: 'tip', x: 'Cherchez toujours un **coach** interne : il vous dira qui décide vraiment, quel budget est prévu et quels sont les vrais critères.' }
      ]
    },
    {
      title: 'Le plan de compte stratégique',
      blocks: [
        { t: 'table', caption: 'Plan de compte en une page : banque régionale (exemple)', head: ['Rubrique', 'Contenu'], rows: [
          ['Situation du compte', 'CA actuel : 180 M FCFA/an (impression et fournitures), 3 agences équipées sur 22'],
          ['Enjeux du client', 'Digitalisation des agences, réduction des coûts, conformité aux règles de la banque centrale'],
          ['Potentiel', '650 M FCFA/an sur 3 ans (équipement des 22 agences + services gérés)'],
          ['Concurrence', '2 concurrents référencés, dont un bien implanté à la DSI'],
          ['Objectifs à 12 mois', 'Référencement en services gérés, 8 agences équipées, CA de 320 M FCFA'],
          ['Plan d’actions', 'Atelier de diagnostic avec la DSI (M1), pilote dans 2 agences (M2-M4), revue de résultats avec le DG (M5)'],
          ['Équipe mobilisée', 'Key account manager, avant-vente technique, direction générale STFC pour la revue annuelle']
        ]},
        { t: 'table', caption: 'Qualifier une opportunité (méthode BANT enrichie)', head: ['Critère', 'Question', 'Oui / Non'], rows: [
          ['Budget', 'Un budget est-il prévu ou finançable ?', ''],
          ['Autorité', 'Avons-nous accès au décideur ?', ''],
          ['Besoin', 'Le besoin est-il réel, urgent et reconnu ?', ''],
          ['Timing', 'Une échéance de décision est-elle fixée ?', ''],
          ['Capacité à gagner', 'Notre offre est-elle différenciante sur ses critères ?', ''],
          ['Rentabilité', 'L’affaire est-elle rentable pour nous ?', '']
        ]},
        { t: 'action', x: 'Rédigez le plan de compte en une page de votre plus gros client.' }
      ]
    },
    {
      title: 'Répondre aux appels d’offres',
      blocks: [
        { t: 'p', x: 'Les marchés publics, les sociétés minières, les opérateurs télécoms et les bailleurs de fonds achètent souvent par **appel d’offres**. Les règles sont strictes : un dossier incomplet est éliminé, quelle que soit la qualité de l’offre.' },
        { t: 'flow', caption: 'Les étapes d’une réponse', items: ['Veille (journaux officiels, plateformes de marchés publics)', 'Go / no go', 'Analyse du dossier (DAO)', 'Questions écrites', 'Offre technique et financière', 'Contrôle de conformité', 'Dépôt dans les délais'] },
        { t: 'table', caption: 'Les 5 clés d’une réponse gagnante', head: ['Clé', 'Pratique'], rows: [
          ['Conformité', 'Check-list de toutes les pièces administratives (attestations fiscales, sociales, cautions) préparée dès le départ'],
          ['Lecture des critères', 'Construire l’offre dans l’ordre et avec les mots de la grille d’évaluation'],
          ['Preuves', 'Références similaires, CV de l’équipe, attestations de bonne exécution'],
          ['Prix', 'Prix cohérent avec le budget estimé, détaillé et sans erreur de calcul'],
          ['Avant l’appel d’offres', 'Être connu du client avant la publication : diagnostic, démonstration, visites']
        ]},
        { t: 'case', title: 'Étude de cas : l’appel d’offres perdu pour une attestation',
          context: 'Une PME de maintenance industrielle de Bamako prépare pendant 3 semaines une excellente offre technique pour une société minière. Elle est éliminée à l’ouverture des plis : l’attestation de régularité fiscale était expirée depuis 10 jours. Le marché représentait 40 % de son CA annuel.',
          questions: ['Quelle erreur de processus a été commise ?', 'Quelles mesures mettre en place ?'],
          solution: 'Erreur : **aucune vérification de conformité administrative** en amont, et tout le temps consacré au technique. Mesures : 1) **check-list de conformité** établie dès la réception du DAO, avec un responsable désigné ; 2) **classeur des pièces permanentes** à jour, avec les dates d’expiration suivies dans un tableur et une alerte 30 jours avant ; 3) **contrôle croisé** 48 h avant le dépôt par une personne qui n’a pas rédigé l’offre ; 4) dépôt au moins 24 h avant la date limite.' }
      ]
    }
  ],
  takeaways: [
    'Une vente complexe implique plusieurs rôles : décideur, acheteur, prescripteur, utilisateur, filtre, coach.',
    'Carte des acteurs selon leur influence et leur attitude.',
    'Plan de compte en une page et qualification de chaque opportunité.',
    'Appels d’offres : conformité d’abord, offre construite sur la grille, présence avant la publication.'
  ],
  deliverable: { title: 'Plan de compte stratégique', x: 'Pour un grand compte réel : carte des acteurs (influence et attitude), plan de compte en une page et grille de qualification de la prochaine opportunité.' },
  quiz: [
    { q: 'Qui est le prescripteur dans une vente B2B ?', options: ['Celui qui signe', 'Celui qui recommande une solution sur des critères techniques', 'L’assistante', 'Le transporteur'], a: 1, why: 'Il influence fortement le choix par son expertise.' },
    { q: 'Quelle priorité pour un opposant influent ?', options: ['L’ignorer', 'Comprendre ses objections et le rencontrer', 'Le contourner', 'Se plaindre de lui'], a: 1, why: 'Un opposant influent peut bloquer la décision.' },
    { q: 'Que signifie le « A » de BANT ?', options: ['Achat', 'Autorité (accès au décideur)', 'Argument', 'Avantage'], a: 1, why: 'Sans accès au décideur, l’opportunité est fragile.' },
    { q: 'Quel est le rôle d’un « coach » interne ?', options: ['Former les commerciaux', 'Vous aider à comprendre les enjeux et le processus internes du client', 'Négocier à votre place', 'Signer le contrat'], a: 1, why: 'Il vous donne des informations précieuses sur la décision.' },
    { q: 'Quelle est la première cause d’élimination dans un appel d’offres ?', options: ['Un prix trop bas', 'Un dossier non conforme', 'Une offre trop détaillée', 'Une police de caractères'], a: 1, why: 'Une pièce manquante ou expirée élimine l’offre quel que soit son contenu.' },
    { q: 'Comment construire l’offre technique ?', options: ['Selon notre plaquette commerciale', 'Dans l’ordre et avec les mots de la grille d’évaluation', 'Le plus court possible', 'En copiant une ancienne offre'], a: 1, why: 'Les évaluateurs notent selon leur grille : facilitez-leur la tâche.' }
  ]
};
