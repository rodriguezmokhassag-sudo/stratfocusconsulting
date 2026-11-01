// Module E4 — Piloter les objectifs et les KPI d'équipe
module.exports = {
  id: 'E4', title: 'Piloter les objectifs et les KPI d’équipe', status: 'complet', duration: '60 min',
  summary: 'Répartir un objectif collectif en objectifs individuels SMART, construire un tableau de bord d’équipe et analyser les écarts pour décider vite.',
  objectives: [
    'Répartir un objectif collectif en objectifs individuels équitables',
    'Choisir les 8 KPI d’une équipe commerciale',
    'Construire un tableau de bord simple (Google Sheets)',
    'Analyser un écart et décider d’actions correctives'
  ],
  skills: ['Fixation d’objectifs', 'Tableau de bord commercial', 'Analyse des écarts'],
  video: {
    title: 'Piloter son équipe avec 8 chiffres', duration: '6 min', src: null,
    script: [
      'Accroche : « Ce qui ne se mesure pas ne s’améliore pas. »',
      'Répartir un objectif : la méthode du potentiel.',
      'Les KPI d’activité et les KPI de résultat.',
      'Un tableau de bord en vert, orange, rouge.',
      'Analyser un écart en 3 questions.'
    ]
  },
  lessons: [
    {
      title: 'Répartir l’objectif collectif',
      blocks: [
        { t: 'p', x: 'Votre équipe reçoit un objectif (par exemple 120 M FCFA sur le trimestre). Le répartir **à parts égales** est simple mais injuste : les secteurs n’ont pas le même potentiel. Un objectif mal réparti démotive autant le commercial qui le juge impossible que celui qui le trouve trop facile.' },
        { t: 'table', caption: 'Répartition par le potentiel (équipe de 4, objectif de 120 M FCFA)', head: ['Commercial', 'CA N-1 (M FCFA)', 'Potentiel du secteur', 'Poids retenu', 'Objectif (M FCFA)'], rows: [
          ['Awa (Plateau)', '30', 'Fort', '30 %', '36'],
          ['Ibrahim (Yopougon)', '25', 'Fort, en croissance', '28 %', '33,6'],
          ['Serge (Cocody)', '22', 'Moyen', '22 %', '26,4'],
          ['Nadia (nouvelle, Abobo)', '–', 'Moyen, à conquérir', '20 %', '24']
        ]},
        { t: 'steps', items: [
          { title: 'Base historique', x: 'Partir du réalisé de l’an dernier par secteur.' },
          { title: 'Potentiel', x: 'Ajuster selon les clients, les prospects et la concurrence du secteur.' },
          { title: 'Expérience', x: 'Un objectif progressif pour un nouveau commercial (rampe sur 3 mois).' },
          { title: 'Dialogue', x: 'Présenter, expliquer et écouter en entretien individuel.' },
          { title: 'Formalisation', x: 'Un objectif SMART écrit, avec les moyens associés.' }
        ]},
        { t: 'tip', x: 'Ajoutez toujours un **objectif qualitatif** (nouveaux clients, produit stratégique) au chiffre d’affaires : sinon chacun ne vend que ce qui est facile.' }
      ]
    },
    {
      title: 'Les 8 KPI et le tableau de bord',
      blocks: [
        { t: 'table', caption: 'Les 8 KPI d’une équipe commerciale', head: ['Famille', 'KPI', 'Question'], rows: [
          ['Activité', 'Nombre de visites ou d’appels', 'L’équipe travaille-t-elle assez ?'],
          ['Activité', 'Nombre de nouveaux prospects contactés', 'Prépare-t-on l’avenir ?'],
          ['Efficacité', 'Taux de transformation', 'Vend-on bien ?'],
          ['Efficacité', 'Panier moyen', 'Vend-on assez à chaque client ?'],
          ['Résultat', 'CA réalisé et taux d’atteinte de l’objectif', 'Atteint-on la cible ?'],
          ['Résultat', 'Marge brute', 'Vend-on de façon rentable ?'],
          ['Portefeuille', 'Nouveaux clients', 'Le portefeuille grandit-il ?'],
          ['Portefeuille', 'Créances ou impayés', 'Encaisse-t-on ce qu’on vend ?']
        ]},
        { t: 'table', caption: 'Extrait de tableau de bord hebdomadaire (code couleur)', head: ['Commercial', 'Visites (cible 20)', 'Transfo.', 'CA cumulé / objectif', 'Statut'], rows: [
          ['Awa', '22', '30 %', '78 %', '🟢 En avance'],
          ['Ibrahim', '18', '22 %', '64 %', '🟠 À surveiller'],
          ['Serge', '11', '27 %', '48 %', '🔴 Action requise'],
          ['Nadia', '24', '12 %', '55 %', '🟠 Coaching découverte et conclusion']
        ]},
        { t: 'action', x: 'Construisez votre tableau de bord dans Google Sheets avec une mise en forme conditionnelle vert, orange, rouge.' }
      ]
    },
    {
      title: 'Analyser les écarts et décider',
      blocks: [
        { t: 'p', x: 'Un écart à l’objectif est un **symptôme**. Le rôle du manager est de remonter à la cause, avec les KPI d’activité et d’efficacité.' },
        { t: 'matrix', caption: 'Diagnostic : activité ou efficacité ?', x: 'Efficacité (taux de transformation) →', y: 'Activité (nombre de visites) ↑', q: [
          { title: 'Activité sans résultat', x: 'Beaucoup de visites, peu de ventes : coacher les techniques (découverte, conclusion)' },
          { title: 'Performant', x: 'Reconnaître, confier des responsabilités, partager ses pratiques' },
          { title: 'En décrochage', x: 'Entretien de fond : motivation, difficultés, plan de progrès rapproché' },
          { title: 'Efficace mais peu actif', x: 'Organisation et tournées, temps passé face aux clients' }
        ]},
        { t: 'steps', items: [
          { title: 'Quoi ?', x: 'Mesurer l’écart précisément (montant, %, produit, client).' },
          { title: 'Pourquoi ?', x: 'Identifier la cause : activité, efficacité, marché, prix, stock, livraison ?' },
          { title: 'Que faire ?', x: '1 à 3 actions concrètes, un responsable, une date, un indicateur de suivi.' }
        ]},
        { t: 'case', title: 'Étude de cas : l’équipe de Yaoundé à 70 % de l’objectif',
          context: 'À mi-trimestre, l’équipe de 5 commerciaux d’un distributeur de produits pharmaceutiques est à 70 % de l’objectif attendu à cette date. Le directeur demande un plan. Les chiffres : visites +5 % par rapport à la cible, taux de transformation en baisse de 28 % à 19 %, deux ruptures de stock sur les produits phares, panier moyen stable.',
          questions: ['Quelle est la cause principale de l’écart ?', 'Quelles actions proposez-vous ?'],
          solution: 'L’activité est bonne (+5 %) et le panier stable : le problème est l’**efficacité**, et les **ruptures de stock** l’expliquent en grande partie (les pharmacies ne peuvent pas commander ce qui manque). Actions : 1) alerte immédiate à la logistique et suivi quotidien du stock des produits phares ; 2) argumentaire de **produits de substitution** pendant la rupture ; 3) **précommandes** pour livrer dès le réassort ; 4) relance des clients perdus pendant la rupture. Indicateur de suivi : taux de transformation chaque semaine, avec un objectif de retour à 25 % en 3 semaines.' }
      ]
    }
  ],
  takeaways: [
    'Répartir l’objectif selon le potentiel, avec un dialogue individuel et un objectif qualitatif.',
    '8 KPI : activité, efficacité, résultat, portefeuille.',
    'Tableau de bord hebdomadaire en vert, orange, rouge.',
    'Analyser l’écart : quoi, pourquoi, que faire.'
  ],
  deliverable: { title: 'Tableau de bord d’équipe', x: 'Un tableau de bord Google Sheets avec les 8 KPI pour chaque commercial, les objectifs individuels répartis selon le potentiel, et l’analyse d’un écart réel avec 3 actions correctives.' },
  quiz: [
    { q: 'Pourquoi éviter de répartir l’objectif à parts égales ?', options: ['C’est trop compliqué', 'Les secteurs n’ont pas le même potentiel', 'C’est interdit', 'Les commerciaux préfèrent'], a: 1, why: 'Un objectif juste tient compte du potentiel de chaque secteur.' },
    { q: 'Le nombre de visites est un KPI…', options: ['De résultat', 'D’activité', 'De portefeuille', 'Financier'], a: 1, why: 'Il mesure l’effort fourni.' },
    { q: 'Beaucoup de visites mais peu de ventes : que faire ?', options: ['Augmenter encore les visites', 'Coacher les techniques de vente', 'Baisser les prix', 'Changer l’objectif'], a: 1, why: 'L’activité est là : c’est l’efficacité qu’il faut travailler.' },
    { q: 'Pourquoi suivre les créances ?', options: ['Pour décorer le tableau', 'Parce qu’une vente non encaissée ne rapporte rien', 'Ce n’est pas utile', 'Pour la comptabilité seulement'], a: 1, why: 'Le commercial est aussi responsable de l’encaissement.' },
    { q: 'Quelle est la première question de l’analyse d’écart ?', options: ['Qui punir ?', 'Quoi : mesurer précisément l’écart', 'Combien de primes ?', 'Pourquoi le marché est-il mauvais ?'], a: 1, why: 'On mesure d’abord l’écart avant d’en chercher la cause.' },
    { q: 'Dans le cas de Yaoundé, quelle est la cause principale ?', options: ['Des commerciaux paresseux', 'Les ruptures de stock qui font chuter la transformation', 'Des prix trop bas', 'Trop de visites'], a: 1, why: 'L’activité est bonne : les ventes manquent car les produits manquent.' }
  ]
};
