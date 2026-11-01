// Module E2 — Animer et motiver son équipe
module.exports = {
  id: 'E2', title: 'Animer et motiver son équipe', status: 'complet', duration: '60 min',
  summary: 'Installer des rituels d’équipe efficaces, comprendre les leviers de motivation, concevoir des challenges commerciaux et gérer un collaborateur démotivé.',
  objectives: [
    'Animer un brief matinal de 15 minutes et une réunion hebdomadaire utile',
    'Utiliser les leviers de motivation (Herzberg, reconnaissance)',
    'Concevoir un challenge commercial motivant et rentable',
    'Conduire un entretien de remotivation'
  ],
  skills: ['Animation d’équipe', 'Leviers de motivation', 'Challenges commerciaux'],
  video: {
    title: 'Le brief de 15 minutes qui change une journée', duration: '6 min', src: null,
    script: [
      'Accroche : une équipe qui démarre la journée sans cap se disperse.',
      'Le brief en 4 temps, filmé dans une agence.',
      'Herzberg : ce qui démotive et ce qui motive.',
      'Les règles d’un bon challenge.',
      'L’entretien avec un collaborateur démotivé.'
    ]
  },
  lessons: [
    {
      title: 'Les rituels d’équipe',
      blocks: [
        { t: 'p', x: 'Les rituels donnent un **rythme** et un **cap** à l’équipe. Ils doivent être courts, réguliers et utiles. Une réunion qui n’apporte rien aux commerciaux est vécue comme une perte de temps.' },
        { t: 'table', caption: 'Les 3 rituels clés', head: ['Rituel', 'Durée', 'Contenu', 'Résultat attendu'], rows: [
          ['Brief du matin', '15 min debout', 'Résultats de la veille, objectif du jour, 1 conseil, 1 succès célébré', 'Énergie et focalisation'],
          ['Point hebdomadaire', '45 min', 'Tableau de bord, affaires en cours, partage de bonnes pratiques', 'Ajustements et entraide'],
          ['Revue mensuelle', '1 h 30', 'Bilan du mois, analyse des écarts, plan du mois suivant, formation', 'Pilotage et progrès']
        ]},
        { t: 'flow', caption: 'Le brief du matin en 4 temps', items: ['Hier (chiffres)', 'Aujourd’hui (objectif)', 'Un conseil', 'Un succès à applaudir'] },
        { t: 'tip', x: 'Terminez toujours un brief sur une **note positive**. L’humeur du départ influence toute la journée de terrain.' }
      ]
    },
    {
      title: 'Les leviers de motivation',
      blocks: [
        { t: 'p', x: 'Selon **Herzberg**, certains facteurs ne motivent pas quand ils sont présents mais **démotivent fortement** quand ils manquent : ce sont les facteurs d’hygiène. Les vrais moteurs de la motivation sont ailleurs.' },
        { t: 'table', caption: 'Facteurs d’hygiène et facteurs moteurs', head: ['Facteurs d’hygiène (évitent la démotivation)', 'Facteurs moteurs (créent la motivation)'], rows: [
          ['Salaire payé à temps, commissions justes et calculées sans erreur', 'Reconnaissance des résultats et des efforts'],
          ['Moyens de travail : téléphone, crédit, carburant, échantillons', 'Responsabilités et autonomie'],
          ['Relation correcte avec le manager', 'Progression, formation, perspective d’évolution'],
          ['Conditions de travail', 'Intérêt du travail, défis atteignables']
        ]},
        { t: 'matrix', caption: 'Adapter son levier au profil', x: 'Compétence →', y: 'Motivation ↑', q: [
          { title: 'Enthousiaste débutant', x: 'Former, encadrer, célébrer les premières victoires' },
          { title: 'Pilier', x: 'Confier des responsabilités (tuteur, grands comptes), le valoriser' },
          { title: 'En difficulté', x: 'Comprendre, fixer un plan de progrès court, accompagner' },
          { title: 'Expert désengagé', x: 'Nouveau défi, rôle d’expert, écoute des frustrations' }
        ]},
        { t: 'action', x: 'Placez chacun de vos collaborateurs dans la matrice et notez le levier à utiliser ce mois-ci.' }
      ]
    },
    {
      title: 'Challenges commerciaux et remotivation',
      blocks: [
        { t: 'table', caption: 'Les règles d’un bon challenge', head: ['Règle', 'Explication'], rows: [
          ['Un objectif clair et ciblé', 'Un seul produit ou un seul comportement (ex. nouveaux clients, produit à lancer)'],
          ['Accessible à tous', 'Paliers individuels plutôt qu’un seul gagnant, pour que chacun puisse réussir'],
          ['Court', '2 à 6 semaines : au-delà, l’énergie retombe'],
          ['Visible', 'Classement affiché, mis à jour chaque jour dans le groupe WhatsApp de l’équipe'],
          ['Rentable', 'Coût des récompenses inférieur à 10-20 % de la marge additionnelle générée'],
          ['Récompense valorisante', 'Crédit téléphonique, bon d’achat, journée de congé, dîner, trophée remis devant tous']
        ]},
        { t: 'steps', items: [
          { title: 'Préparer', x: 'Rassembler les faits (chiffres, comportements observés), choisir un lieu calme.' },
          { title: 'Ouvrir le dialogue', x: '« J’ai remarqué que tes résultats ont baissé depuis 2 mois. Comment le vis-tu ? »' },
          { title: 'Écouter', x: 'Laisser parler, creuser les causes : personnelles, matérielles, relationnelles, compétences.' },
          { title: 'Co-construire', x: 'Définir ensemble 2 ou 3 actions et l’aide apportée par le manager.' },
          { title: 'Suivre', x: 'Point à 15 jours, féliciter chaque progrès.' }
        ]},
        { t: 'case', title: 'Étude de cas : le challenge qui a divisé l’équipe',
          context: 'Un chef d’équipe d’un distributeur de téléphones à Cotonou lance un challenge de 3 mois : le meilleur vendeur gagne un smartphone haut de gamme. Au bout de 3 semaines, deux vendeurs très performants se détachent. Les 6 autres arrêtent de faire des efforts et deux d’entre eux se plaignent que les meilleurs « volent » des clients.',
          questions: ['Pourquoi le challenge a-t-il échoué ?', 'Comment le reconstruire ?'],
          solution: 'Échec : **un seul gagnant** (les autres savent vite qu’ils ne gagneront pas), **trop long** (3 mois), et des **règles floues** sur l’attribution des clients. Nouvelle version sur 4 semaines : **paliers individuels** (par exemple +10 % = crédit de 10 000 FCFA, +20 % = bon de 25 000 FCFA, +30 % = journée de congé), un **bonus collectif** si l’équipe atteint 115 % de l’objectif, des **règles d’attribution** des clients écrites, un classement quotidien dans le groupe WhatsApp et une remise des prix en réunion.' }
      ]
    }
  ],
  takeaways: [
    'Trois rituels : brief du matin, point hebdomadaire, revue mensuelle.',
    'Herzberg : sécuriser les facteurs d’hygiène, activer la reconnaissance, l’autonomie et la progression.',
    'Challenge : objectif ciblé, paliers accessibles à tous, court, visible, rentable.',
    'Remotiver : faits, écoute, plan co-construit, suivi.'
  ],
  deliverable: { title: 'Kit d’animation de mon équipe', x: 'Le déroulé de votre brief du matin, l’ordre du jour du point hebdomadaire, et le règlement complet d’un challenge de 4 semaines (objectif, paliers, récompenses, coût, règles).' },
  quiz: [
    { q: 'Combien de temps doit durer un brief du matin ?', options: ['1 heure', 'Environ 15 minutes', '2 minutes', 'Une demi-journée'], a: 1, why: 'Court et énergique, il lance la journée sans retarder le terrain.' },
    { q: 'Selon Herzberg, des commissions payées en retard sont…', options: ['Un facteur moteur', 'Un facteur d’hygiène qui démotive', 'Sans effet', 'Un levier de reconnaissance'], a: 1, why: 'Leur absence ou leur mauvaise gestion démotive fortement.' },
    { q: 'Quel est un facteur moteur ?', options: ['Un bureau climatisé', 'La reconnaissance des résultats', 'Le paiement du salaire à temps', 'Le carburant fourni'], a: 1, why: 'La reconnaissance crée la motivation, au-delà des conditions de base.' },
    { q: 'Quelle est la durée idéale d’un challenge commercial ?', options: ['1 jour', '2 à 6 semaines', '6 mois', '1 an'], a: 1, why: 'Au-delà, l’énergie et l’attention retombent.' },
    { q: 'Pourquoi préférer des paliers individuels à un seul gagnant ?', options: ['C’est moins cher', 'Chacun peut réussir et reste motivé', 'C’est plus simple à calculer', 'Pour éviter de récompenser'], a: 1, why: 'Avec un seul gagnant, la majorité décroche rapidement.' },
    { q: 'Que faire en premier lors d’un entretien de remotivation ?', options: ['Menacer de sanction', 'Préparer les faits puis ouvrir le dialogue et écouter', 'Annoncer un plan imposé', 'Comparer avec les meilleurs'], a: 1, why: 'Comprendre les causes est indispensable avant d’agir.' },
    { q: 'Un expert désengagé a surtout besoin…', options: ['De consignes précises', 'D’un nouveau défi et d’écoute', 'D’être ignoré', 'D’une formation de base'], a: 1, why: 'Il est compétent : c’est sa motivation qu’il faut relancer.' }
  ]
};
