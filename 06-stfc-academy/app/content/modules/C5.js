// Module C5 — Organisation, tournées et gestion du temps
module.exports = {
  id: 'C5', title: 'Organisation, tournées et gestion du temps', status: 'complet', duration: '50 min',
  summary: 'Sectoriser son territoire, planifier des tournées efficaces malgré les embouteillages, prioriser ses actions et suivre ses indicateurs personnels.',
  objectives: [
    'Sectoriser sa zone et planifier une tournée hebdomadaire',
    'Prioriser ses tâches avec la matrice d’Eisenhower',
    'Calculer et suivre ses indicateurs personnels de performance'
  ],
  skills: ['Planification de tournée', 'Priorisation', 'Indicateurs personnels'],
  video: {
    title: 'Gagner 2 heures par jour sur le terrain', duration: '5 min', src: null,
    script: [
      'Accroche : « Un commercial terrain passe souvent moins de 30 % de son temps face à des clients. »',
      'La tournée en marguerite et la tournée en boucle, sur une carte.',
      'La matrice d’Eisenhower du commercial.',
      'Les 4 chiffres à connaître chaque vendredi.'
    ]
  },
  lessons: [
    {
      title: 'Sectoriser et planifier sa tournée',
      blocks: [
        { t: 'p', x: 'À Abidjan, Dakar ou Kinshasa, les embouteillages peuvent manger la moitié d’une journée. Une tournée mal organisée, c’est moins de visites, plus de carburant et de la fatigue. L’objectif est simple : **maximiser le temps passé face aux clients**.' },
        { t: 'steps', items: [
          { title: 'Cartographier', x: 'Placer tous ses clients et prospects sur Google Maps (liste partagée ou Google My Maps).' },
          { title: 'Découper en secteurs', x: 'Un secteur par jour (ex. lundi Cocody, mardi Plateau, mercredi Yopougon…).' },
          { title: 'Fixer les fréquences', x: 'Gros clients chaque semaine, moyens tous les 15 jours, petits une fois par mois.' },
          { title: 'Éviter les heures de pointe', x: 'Tâches administratives et appels aux heures d’embouteillage, visites en milieu de matinée et d’après-midi.' },
          { title: 'Confirmer les rendez-vous', x: 'Message WhatsApp la veille : moins de visites à vide.' }
        ]},
        { t: 'table', caption: 'Deux formes de tournée', head: ['Forme', 'Principe', 'Idéal pour'], rows: [
          ['En boucle', 'Les visites s’enchaînent en cercle et le retour se fait au point de départ', 'Zones denses (centre-ville, marchés)'],
          ['En marguerite', 'Un « pétale » différent chaque jour au départ du même point', 'Grandes zones, périphéries, régions']
        ]},
        { t: 'tip', x: 'Gardez **20 % de créneaux libres** pour les urgences et les opportunités.' }
      ]
    },
    {
      title: 'Prioriser avec la matrice d’Eisenhower',
      blocks: [
        { t: 'matrix', caption: 'La matrice d’Eisenhower du commercial', x: 'Urgence →', y: 'Importance ↑', q: [
          { title: 'Planifier', x: 'Important, pas urgent : prospection, préparation des grands comptes, formation' },
          { title: 'Faire tout de suite', x: 'Important et urgent : réclamation d’un gros client, devis attendu aujourd’hui' },
          { title: 'Éliminer', x: 'Ni important ni urgent : discussions sans objet, réseaux sociaux personnels' },
          { title: 'Déléguer ou regrouper', x: 'Urgent, peu important : demandes administratives, petites relances' }
        ]},
        { t: 'p', x: 'Le piège du commercial est de vivre dans le quadrant « urgent » et d’oublier la **prospection**, qui n’est jamais urgente… jusqu’au jour où le portefeuille se vide.' },
        { t: 'table', caption: 'Une semaine type équilibrée', head: ['Moment', 'Activité'], rows: [
          ['Lundi 8 h - 9 h', 'Planification de la semaine, mise à jour du CRM'],
          ['Chaque matin, 1 h', 'Prospection (appels, WhatsApp) : bloc protégé'],
          ['Milieu de matinée et d’après-midi', 'Visites clients selon le secteur du jour'],
          ['Fin de journée, 30 min', 'Comptes rendus, relances, préparation du lendemain'],
          ['Vendredi après-midi', 'Bilan des indicateurs et préparation des grands comptes']
        ]},
        { t: 'action', x: 'Listez vos tâches de la semaine et placez-les dans la matrice. Lesquelles éliminer ?' }
      ]
    },
    {
      title: 'Mes indicateurs personnels',
      blocks: [
        { t: 'table', caption: 'Les indicateurs du commercial', head: ['Indicateur', 'Calcul', 'Exemple', 'Ce qu’il révèle'], rows: [
          ['Nombre de visites', 'Visites réalisées par semaine', '22', 'L’activité'],
          ['Taux de transformation', 'Commandes ÷ visites', '6 ÷ 22 = 27 %', 'L’efficacité commerciale'],
          ['Panier moyen', 'CA ÷ nombre de commandes', '3 600 000 ÷ 6 = 600 000 FCFA', 'La capacité à vendre plus'],
          ['Taux d’atteinte de l’objectif', 'Réalisé ÷ objectif', '3,6 M ÷ 4 M = 90 %', 'La performance globale'],
          ['Nouveaux clients', 'Clients signés pour la première fois', '2', 'La conquête']
        ]},
        { t: 'funnel', caption: 'Lire ses chiffres : où perd-on des ventes ? (un mois)', items: [{ label: 'Prospects contactés', value: 120 }, { label: 'Rendez-vous', value: 40 }, { label: 'Devis', value: 20 }, { label: 'Commandes', value: 6 }] },
        { t: 'case', title: 'Étude de cas : Didier, commercial en boissons à Kinshasa',
          context: 'Didier réalise 12 visites par semaine, alors que ses collègues en font 25. Il passe ses matinées au bureau à répondre aux messages, part sur le terrain vers 11 h et traverse plusieurs fois la ville dans la même journée en fonction des appels reçus.',
          questions: ['Quels sont ses 3 problèmes d’organisation ?', 'Proposez une nouvelle organisation.'],
          solution: 'Problèmes : 1) **aucune sectorisation** (traversées multiples de la ville) ; 2) **tâches administratives aux meilleures heures** de visite ; 3) organisation **dictée par l’urgence** des appels. Nouvelle organisation : un **secteur par jour** (ex. Gombe le lundi, Limete le mardi…), départ terrain à 8 h 30 après 30 minutes de messages, rendez-vous confirmés la veille sur WhatsApp, demandes urgentes regroupées dans le secteur du jour ou transférées à l’assistante, administratif entre 16 h 30 et 17 h 30. Objectif réaliste : 22 visites par semaine.' }
      ]
    }
  ],
  takeaways: [
    'Un secteur par jour, des fréquences de visite par type de client, des rendez-vous confirmés la veille.',
    'Protéger un bloc de prospection chaque jour : important mais jamais urgent.',
    'Suivre visites, taux de transformation, panier moyen, atteinte de l’objectif et nouveaux clients.'
  ],
  deliverable: { title: 'Mon planning de tournée sur 4 semaines', x: 'Carte des secteurs, affectation d’un secteur par jour, liste des clients avec leur fréquence de visite, et tableau des 5 indicateurs avec la cible de chacun.' },
  quiz: [
    { q: 'Dans la matrice d’Eisenhower, la prospection est le plus souvent…', options: ['Urgente et importante', 'Importante mais pas urgente', 'Urgente mais pas importante', 'Ni urgente ni importante'], a: 1, why: 'Elle conditionne les ventes futures mais n’est jamais urgente : il faut la planifier.' },
    { q: 'Quel est l’intérêt de la sectorisation ?', options: ['Visiter moins de clients', 'Réduire les déplacements et augmenter le temps face aux clients', 'Travailler seulement le matin', 'Éviter les gros clients'], a: 1, why: 'On regroupe les visites géographiquement.' },
    { q: '8 commandes pour 32 visites donnent un taux de transformation de…', options: ['4 %', '25 %', '32 %', '8 %'], a: 1, why: '8 ÷ 32 = 25 %.' },
    { q: 'Quand faire les tâches administratives ?', options: ['Aux meilleures heures de visite', 'Aux heures de pointe ou en fin de journée', 'Le week-end uniquement', 'Jamais'], a: 1, why: 'Les meilleures heures doivent être réservées aux clients.' },
    { q: 'Quelle part de créneaux garder libre ?', options: ['0 %', 'Environ 20 %', '50 %', '80 %'], a: 1, why: 'Elle absorbe les urgences sans désorganiser la tournée.' },
    { q: 'Quel était le principal problème de Didier ?', options: ['Trop de visites', 'Une organisation dictée par l’urgence, sans sectorisation', 'De mauvais produits', 'Trop de clients'], a: 1, why: 'Il réagissait aux appels au lieu de suivre un plan par secteur.' }
  ]
};
