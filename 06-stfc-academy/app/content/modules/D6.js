// Module D6 — Leadership et gouvernance commerciale
module.exports = {
  id: 'D6', title: 'Leadership et gouvernance commerciale', status: 'complet', duration: '60 min',
  summary: 'Incarner une vision commerciale, installer une gouvernance efficace (comités, rituels, décisions), aligner ventes, marketing et finance, et garantir une éthique commerciale irréprochable.',
  objectives: [
    'Formuler et partager une vision commerciale mobilisatrice',
    'Installer les instances de gouvernance commerciale',
    'Aligner ventes, marketing et finance autour d’objectifs communs',
    'Prévenir les risques éthiques et de conformité'
  ],
  skills: ['Leadership de direction', 'Gouvernance commerciale', 'Éthique et conformité'],
  video: {
    title: 'Le directeur commercial, chef d’orchestre', duration: '6 min', src: null,
    script: [
      'Accroche : « Le directeur commercial ne vend plus : il construit la machine qui vend. »',
      'Une vision en une phrase, avec des exemples.',
      'Le calendrier de gouvernance de l’année.',
      'Ventes et marketing : du conflit à l’alliance (smarketing).',
      'Éthique : les zones de risque et les règles claires.'
    ]
  },
  lessons: [
    {
      title: 'Le leadership du directeur commercial',
      blocks: [
        { t: 'p', x: 'Le directeur commercial ne réussit plus par ses propres ventes mais par sa capacité à **donner un cap**, **développer ses managers** et **construire un système** (organisation, processus, outils, culture) qui produit des résultats durables.' },
        { t: 'table', caption: 'Une vision commerciale utile', head: ['Élément', 'Question', 'Exemple (distributeur de matériel médical, Afrique de l’Ouest)'], rows: [
          ['Ambition', 'Où voulons-nous être dans 3 ans ?', 'Devenir le partenaire de référence de 500 cliniques dans 5 pays'],
          ['Pour qui', 'Quels clients servons-nous en priorité ?', 'Cliniques privées et centres de santé urbains'],
          ['Comment', 'Qu’est-ce qui nous différencie ?', 'Disponibilité en 48 h, maintenance locale, formation des soignants'],
          ['Mesure', 'Comment saurons-nous que nous réussissons ?', 'Part de marché, taux de renouvellement, NPS clients'],
          ['Valeurs', 'Quels comportements attendons-nous ?', 'Intégrité, réactivité, expertise']
        ]},
        { t: 'matrix', caption: 'Les 4 rôles du directeur commercial', x: 'Horizon (court terme → long terme) →', y: 'Orientation (équipes ↓ / marché ↑)', q: [
          { title: 'Développeur de business', x: 'Grands comptes, partenariats, négociations clés' },
          { title: 'Stratège', x: 'Vision, choix des marchés, innovation, pricing' },
          { title: 'Pilote de la performance', x: 'Objectifs, revues, tableaux de bord, décisions rapides' },
          { title: 'Bâtisseur d’équipe', x: 'Recrutement des managers, développement des talents, culture' }
        ]},
        { t: 'tip', x: 'Une vision n’existe que si **chaque commercial** peut l’expliquer avec ses mots et voir comment son travail y contribue.' }
      ]
    },
    {
      title: 'Les instances de gouvernance',
      blocks: [
        { t: 'table', caption: 'Calendrier de gouvernance commerciale', head: ['Instance', 'Fréquence', 'Participants', 'Objet', 'Livrable'], rows: [
          ['Revue hebdomadaire de pipeline', 'Chaque semaine (45 min)', 'Directeur + managers', 'Opportunités clés, prévision du trimestre', 'Prévision mise à jour'],
          ['Comité commercial mensuel', 'Mensuel (2 h)', 'Directeur, managers, marketing, finance, supply', 'Résultats, écarts, actions, stocks', 'Plan d’actions daté'],
          ['Revue trimestrielle d’affaires (QBR)', 'Trimestriel', 'Direction générale + comité commercial', 'Stratégie, budget, ressources', 'Arbitrages et budget révisé'],
          ['Séminaire stratégique', 'Annuel', 'Comité de direction élargi', 'Vision, plan à 3 ans, organisation', 'Plan stratégique et PAC']
        ]},
        { t: 'steps', items: [
          { title: 'Un ordre du jour envoyé 48 h avant', x: 'Avec les chiffres : la réunion sert à décider, pas à découvrir les données.' },
          { title: 'Des décisions écrites', x: 'Qui fait quoi, pour quand : relevé envoyé dans les 24 h.' },
          { title: 'Un suivi des décisions', x: 'Première partie de chaque comité : où en sont les actions décidées ?' }
        ]},
        { t: 'action', x: 'Dessinez le calendrier de gouvernance de votre direction pour les 12 prochains mois.' }
      ]
    },
    {
      title: 'Alignement ventes-marketing-finance et éthique',
      blocks: [
        { t: 'table', caption: 'Du conflit à l’alliance (« smarketing »)', head: ['Sujet de friction', 'Règle commune'], rows: [
          ['« Le marketing n’envoie pas de bons prospects »', 'Définition écrite d’un prospect qualifié et délai de traitement (ex. 48 h)'],
          ['« Les ventes ne rappellent pas les contacts »', 'Suivi dans le CRM, retour au marketing sur la qualité des prospects'],
          ['« La finance bloque les remises »', 'Grille de délégation des remises (commercial, manager, directeur, DG)'],
          ['« Les prévisions sont fausses »', 'Une seule prévision partagée ventes / supply / finance (S&OP)']
        ]},
        { t: 'table', caption: 'Zones de risque éthique et règles', head: ['Risque', 'Règle'], rows: [
          ['Corruption, commissions occultes', 'Tolérance zéro, politique écrite, signalement protégé'],
          ['Cadeaux et invitations', 'Plafond de valeur, déclaration obligatoire au-delà'],
          ['Promesses non tenues', 'Aucun engagement hors de l’offre écrite validée'],
          ['Données personnelles', 'Respect des lois nationales, consentement, sécurité des fichiers'],
          ['Pratiques anticoncurrentielles', 'Pas d’entente sur les prix avec les concurrents']
        ]},
        { t: 'case', title: 'Étude de cas : le grand contrat et la « commission » demandée',
          context: 'Un directeur commercial d’une entreprise de BTP à Abidjan est sur le point de signer un contrat de 2 milliards de FCFA. Un intermédiaire lui fait comprendre qu’une « commission de facilitation » de 5 % versée à une personne du client garantirait la signature. Le trimestre est difficile et le DG attend ce contrat.',
          questions: ['Quels sont les risques pour l’entreprise ?', 'Comment le directeur doit-il réagir, et que mettre en place ?'],
          solution: 'Risques : **pénaux** (corruption), **financiers** (amendes, exclusion des marchés publics et des financements des bailleurs), **réputation**, et **dépendance** à des pratiques illégales. Réaction : refuser clairement, ne rien promettre, **informer immédiatement le DG et le responsable conformité**, documenter l’échange, recentrer la proposition sur la valeur et la conformité. À mettre en place : **politique anticorruption** écrite et signée par tous les commerciaux, procédure de **diligence sur les intermédiaires**, canal de signalement protégé, et objectifs ou primes qui ne poussent pas à franchir la ligne (un contrat unique ne doit pas conditionner toute la prime).' }
      ]
    }
  ],
  takeaways: [
    'Le directeur commercial construit la machine qui vend : vision, managers, système.',
    'Vision : ambition, clients prioritaires, différenciation, mesures, valeurs.',
    'Gouvernance : revue hebdomadaire, comité mensuel, QBR, séminaire annuel, avec des décisions écrites.',
    'Alignement ventes-marketing-finance et tolérance zéro sur la corruption.'
  ],
  deliverable: { title: 'Charte de gouvernance commerciale', x: 'Votre vision commerciale en une page, le calendrier annuel des instances (objet, participants, livrables), la grille de délégation des remises et la charte éthique commerciale.' },
  quiz: [
    { q: 'Qu’est-ce qui mesure le succès d’un directeur commercial ?', options: ['Ses ventes personnelles', 'Sa capacité à construire un système qui produit des résultats durables', 'Le nombre de réunions', 'Son ancienneté'], a: 1, why: 'Il crée les conditions de la performance collective.' },
    { q: 'Quand faut-il envoyer l’ordre du jour et les chiffres d’un comité ?', options: ['Pendant la réunion', 'Environ 48 h avant', 'Après la réunion', 'Jamais'], a: 1, why: 'La réunion sert à décider, pas à découvrir les données.' },
    { q: 'Que signifie QBR ?', options: ['Quick Business Report', 'Revue trimestrielle d’affaires', 'Qualité du bilan régional', 'Quota de base révisé'], a: 1, why: 'C’est la revue trimestrielle avec la direction générale.' },
    { q: 'Comment réduire la friction « la finance bloque les remises » ?', options: ['Supprimer les remises', 'Une grille écrite de délégation des remises par niveau', 'Laisser chacun décider', 'Ne plus parler à la finance'], a: 1, why: 'Les règles sont claires et les décisions rapides.' },
    { q: 'Que faire face à une demande de « commission de facilitation » ?', options: ['Accepter si le contrat est important', 'Refuser, informer la direction et la conformité, documenter', 'Payer en espèces', 'Demander une remise'], a: 1, why: 'C’est de la corruption : tolérance zéro et transparence interne.' },
    { q: 'Quel est le rôle de « stratège » du directeur commercial ?', options: ['Remplir les bons de commande', 'Définir la vision, les marchés, l’innovation et le pricing', 'Livrer les clients', 'Saisir le CRM à la place des équipes'], a: 1, why: 'C’est son rôle orienté marché et long terme.' }
  ]
};
