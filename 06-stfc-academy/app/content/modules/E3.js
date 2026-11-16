// Module E3 — Coaching terrain et accompagnement
module.exports = {
  id: 'E3', title: 'Coaching terrain et accompagnement', status: 'complet', duration: '60 min',
  summary: 'Préparer et conduire une journée d’accompagnement, observer avec une grille objective, débriefer avec un feedback constructif et bâtir un plan de progrès individuel.',
  objectives: [
    'Préparer une journée d’accompagnement terrain',
    'Observer un entretien de vente avec une grille d’évaluation',
    'Donner un feedback constructif (méthode DESC)',
    'Construire un plan de progrès individuel'
  ],
  skills: ['Accompagnement terrain', 'Feedback constructif (DESC)', 'Plan de progrès individuel'],
  video: {
    title: 'Coacher sans faire à la place', duration: '6 min', src: null,
    script: [
      'Accroche : « Le manager qui reprend la main devant le client tue l’apprentissage de son commercial. »',
      'Avant, pendant et après la visite : le rôle du coach.',
      'La grille d’observation en 6 étapes.',
      'Un débriefing filmé avec la méthode DESC.',
      'Le plan de progrès sur un mois.'
    ]
  },
  lessons: [
    {
      title: 'La journée d’accompagnement',
      blocks: [
        { t: 'p', x: 'L’accompagnement terrain est l’outil n°1 du chef d’équipe pour faire progresser ses commerciaux. Le principe : **observer en situation réelle**, puis aider le commercial à trouver lui-même ses axes de progrès.' },
        { t: 'table', caption: 'Avant, pendant et après', head: ['Moment', 'Rôle du manager', 'À éviter'], rows: [
          ['Avant (la veille)', 'Fixer avec le commercial 1 ou 2 points à travailler, choisir les visites, préparer la grille', 'Arriver sans objectif'],
          ['Avant chaque visite', 'Demander : « Quel est ton objectif ? Comment vas-tu t’y prendre ? »', 'Donner toutes les réponses'],
          ['Pendant la visite', 'Observer en silence, prendre des notes factuelles, être présenté comme « un collègue »', 'Reprendre la main devant le client (sauf risque grave)'],
          ['Après chaque visite', 'Débriefing de 10 minutes dans la voiture ou au café', 'Attendre la fin de la journée'],
          ['En fin de journée', 'Synthèse et plan de progrès', 'Une liste de 10 reproches']
        ]},
        { t: 'tip', x: 'Règle des **2 points** : travaillez au maximum deux compétences par accompagnement. Au-delà, rien n’est retenu.' }
      ]
    },
    {
      title: 'Observer avec une grille objective',
      blocks: [
        { t: 'table', caption: 'Grille d’observation de l’entretien de vente (note de 1 à 4)', head: ['Étape', 'Critères observables', 'Note'], rows: [
          ['Préparation', 'Objectif fixé, connaissance du client, supports prêts', '1 2 3 4'],
          ['Prise de contact', 'Présentation, accroche, annonce de l’objectif de la visite', '1 2 3 4'],
          ['Découverte', 'Questions ouvertes, SPIN, reformulation validée', '1 2 3 4'],
          ['Argumentation', 'Arguments CAP reliés aux besoins, preuves', '1 2 3 4'],
          ['Objections', 'ACRA, calme, pas de remise sans contrepartie', '1 2 3 4'],
          ['Conclusion', 'Demande de la commande ou d’un engagement, prochaine étape fixée', '1 2 3 4']
        ]},
        { t: 'list', items: [
          '**Fait** : « Tu as posé 2 questions ouvertes puis présenté le catalogue. »',
          '**Pas une opinion** : « Tu n’écoutes pas les clients. »',
          'Notez les **phrases exactes** du commercial et du client : elles rendent le débriefing incontestable.'
        ]},
        { t: 'action', x: 'Adaptez la grille à votre métier et testez-la lors de votre prochain accompagnement.' }
      ]
    },
    {
      title: 'Débriefer et construire le plan de progrès',
      blocks: [
        { t: 'flow', caption: 'Le débriefing en 5 temps', items: ['Auto-évaluation du commercial', 'Points forts (faits)', 'Un axe de progrès (DESC)', 'Solution trouvée par le commercial', 'Engagement'] },
        { t: 'table', caption: 'La méthode DESC pour un feedback constructif', head: ['Étape', 'Principe', 'Exemple'], rows: [
          ['**D**écrire', 'Les faits observés, sans jugement', '« Quand le client a dit que c’était cher, tu as proposé 10 % tout de suite. »'],
          ['**E**xprimer', 'L’effet produit ou le ressenti', '« Ça m’a inquiété, car il a ensuite demandé encore plus. »'],
          ['**S**olutions', 'Faire chercher l’alternative', '« Qu’aurais-tu pu faire autrement ? »'],
          ['**C**onséquences', 'Les bénéfices positifs du changement', '« En creusant d’abord, tu protèges ta marge et ta commission. »']
        ]},
        { t: 'table', caption: 'Plan de progrès individuel (exemple sur 1 mois)', head: ['Axe', 'Action', 'Soutien du manager', 'Indicateur', 'Échéance'], rows: [
          ['Traitement de l’objection prix', 'Appliquer ACRA à chaque objection prix', 'Jeu de rôle de 20 minutes chaque lundi', 'Remise moyenne accordée : de 8 % à 4 %', '4 semaines'],
          ['Conclusion', 'Demander la commande à chaque visite qualifiée', 'Accompagnement à J+15', 'Taux de transformation : de 18 % à 25 %', '4 semaines']
        ]},
        { t: 'case', title: 'Étude de cas : Kouamé et le manager « sauveur »',
          context: 'Lors d’un accompagnement chez un grossiste à Yamoussoukro, le chef d’équipe voit Kouamé hésiter face à une objection. Il prend la parole, négocie et obtient la commande. Dans la voiture, il dit : « Tu vois, c’est comme ça qu’on fait. » Les semaines suivantes, Kouamé appelle son manager à chaque négociation difficile.',
          questions: ['Quelles erreurs le manager a-t-il commises ?', 'Comment aurait-il dû conduire l’accompagnement ?'],
          solution: 'Erreurs : 1) **reprise de la main** devant le client, qui décrédibilise Kouamé ; 2) **débriefing descendant** (« c’est comme ça qu’on fait ») sans auto-évaluation ; 3) création d’une **dépendance**. Il aurait dû laisser Kouamé terminer (même au prix d’une affaire reportée), puis débriefer : auto-évaluation (« Comment l’as-tu vécu ? »), points forts, puis **DESC** sur l’objection, faire trouver la solution par Kouamé, l’entraîner en jeu de rôle et fixer un plan de progrès avec un nouvel accompagnement à J+15.' }
      ]
    }
  ],
  takeaways: [
    '2 points à travailler maximum par accompagnement, fixés la veille.',
    'Observer en silence avec une grille factuelle, ne pas faire à la place.',
    'Débriefer à chaud : auto-évaluation, points forts, DESC, engagement.',
    'Plan de progrès : axe, action, soutien, indicateur, échéance.'
  ],
  deliverable: { title: 'Grille d’accompagnement et plan de progrès', x: 'Votre grille d’observation adaptée à votre métier, remplie lors d’un accompagnement réel, et le plan de progrès sur 1 mois du commercial accompagné.' },
  quiz: [
    { q: 'Combien de compétences travailler au maximum par accompagnement ?', options: ['Une dizaine', 'Deux', 'Toutes', 'Aucune'], a: 1, why: 'Au-delà de deux, le commercial ne retient rien.' },
    { q: 'Pendant la visite, le manager doit…', options: ['Mener l’entretien', 'Observer en silence et noter des faits', 'Corriger le commercial devant le client', 'Téléphoner'], a: 1, why: 'Il observe pour pouvoir débriefer de façon factuelle.' },
    { q: 'Que signifie le « D » de DESC ?', options: ['Décider', 'Décrire les faits', 'Déléguer', 'Diagnostiquer'], a: 1, why: 'Le feedback commence par des faits observés, sans jugement.' },
    { q: 'Quelle est la première étape du débriefing ?', options: ['Les reproches', 'L’auto-évaluation du commercial', 'La note finale', 'Le plan de progrès'], a: 1, why: 'Le commercial analyse d’abord sa propre prestation.' },
    { q: '« Tu n’écoutes pas les clients » est…', options: ['Un fait', 'Une opinion à éviter', 'Un bon feedback', 'Un indicateur'], a: 1, why: 'Un jugement général braque. Il faut décrire des faits précis.' },
    { q: 'Quelle conséquence a eue l’attitude du manager de Kouamé ?', options: ['Kouamé est devenu autonome', 'Kouamé est devenu dépendant de son manager', 'Les ventes ont doublé', 'Aucune'], a: 1, why: 'Faire à la place empêche l’apprentissage et crée de la dépendance.' }
  ]
};
