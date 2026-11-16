// Module C4 — Fidélisation, suivi client et CRM simple
module.exports = {
  id: 'C4', title: 'Fidélisation, suivi client et CRM simple', status: 'complet', duration: '55 min',
  summary: 'Faire revenir ses clients, mesurer leur satisfaction, obtenir des recommandations et tenir un CRM simple à jour (tableur ou outil gratuit).',
  objectives: [
    'Expliquer pourquoi fidéliser rapporte plus que conquérir',
    'Construire un plan de contact client par segment',
    'Monter un CRM simple en une heure',
    'Obtenir des recommandations de façon systématique'
  ],
  skills: ['Fidélisation client', 'Plan de contact', 'Gestion d’un CRM'],
  video: {
    title: 'Vos clients actuels sont votre meilleur marché', duration: '5 min', src: null,
    script: [
      'Accroche : « Gagner un nouveau client coûte plusieurs fois plus cher que garder un client existant. »',
      'L’échelle de fidélité, du prospect à l’ambassadeur.',
      'Le plan de contact : qui appeler, quand et pourquoi.',
      'Démonstration : un CRM dans Google Sheets en 5 colonnes.',
      'La question qui rapporte des recommandations.'
    ]
  },
  lessons: [
    {
      title: 'Pourquoi fidéliser',
      blocks: [
        { t: 'p', x: 'Un client fidèle achète plus souvent, accepte mieux les hausses de prix, coûte moins cher à servir et **recommande** l’entreprise. Dans des marchés où la confiance et le bouche-à-oreille comptent beaucoup, comme en Afrique francophone, la recommandation est souvent le premier canal d’acquisition.' },
        { t: 'flow', caption: 'L’échelle de fidélité', items: ['Prospect', 'Client occasionnel', 'Client régulier', 'Client fidèle', 'Ambassadeur'] },
        { t: 'table', caption: 'Calculer la valeur d’un client (exemple : cliente d’un salon de coiffure à Abidjan)', head: ['Élément', 'Valeur'], rows: [
          ['Panier moyen', '15 000 FCFA'],
          ['Visites par an', '10'],
          ['Durée de la relation', '4 ans'],
          ['Valeur vie client (CLV)', '15 000 × 10 × 4 = **600 000 FCFA**'],
          ['Clientes recommandées en moyenne', '2, soit 1,2 M FCFA de plus']
        ]},
        { t: 'tip', x: 'Perdre une cliente, ce n’est pas perdre 15 000 FCFA : c’est perdre **jusqu’à 1,8 million de FCFA** de chiffre d’affaires potentiel.' }
      ]
    },
    {
      title: 'Le plan de contact client',
      blocks: [
        { t: 'p', x: 'Un plan de contact définit **qui contacter, à quelle fréquence, par quel canal et avec quel message**. Il évite de ne se souvenir de ses clients que lorsqu’on a un objectif à atteindre.' },
        { t: 'table', caption: 'Exemple de plan de contact (distributeur de produits d’entretien, Lomé)', head: ['Segment', 'Fréquence', 'Canal', 'Contenu'], rows: [
          ['Gros clients (hôtels, cliniques)', 'Visite toutes les 2 semaines', 'Terrain + WhatsApp', 'Suivi des stocks, nouveautés, bilan trimestriel'],
          ['Clients réguliers (restaurants)', 'Appel mensuel', 'Téléphone + WhatsApp', 'Réassort, promotions'],
          ['Petits clients', 'Message mensuel', 'Liste de diffusion WhatsApp', 'Offre du mois, conseils d’utilisation'],
          ['Clients inactifs depuis 3 mois', 'Une fois', 'Appel', '« Qu’est-ce qui a changé ? » et offre de retour']
        ]},
        { t: 'steps', items: [
          { title: 'J+1 après la vente', x: 'Message de remerciement et confirmation de livraison.' },
          { title: 'J+7', x: 'Vérifier la satisfaction : « Tout se passe bien avec le produit ? »' },
          { title: 'J+30', x: 'Conseil d’utilisation ou contenu utile, sans vente.' },
          { title: 'Avant la fin du stock estimé', x: 'Proposer le réassort.' }
        ]},
        { t: 'action', x: 'Classez vos 20 premiers clients dans ces segments et fixez la prochaine date de contact de chacun.' }
      ]
    },
    {
      title: 'Monter un CRM simple et obtenir des recommandations',
      blocks: [
        { t: 'p', x: 'Un **CRM** (gestion de la relation client) est d’abord une habitude, avant d’être un logiciel. Un tableur partagé (Google Sheets) suffit pour démarrer. Des outils gratuits comme HubSpot CRM, Zoho ou Bitrix24 prennent le relais quand l’équipe grandit.' },
        { t: 'table', caption: 'Les colonnes indispensables', head: ['Colonne', 'Exemple', 'Pourquoi'], rows: [
          ['Client et contact', 'Hôtel Lagune · Mme Koné · 07 00 00 00', 'Savoir qui appeler'],
          ['Segment', 'Gros client', 'Adapter la fréquence'],
          ['Étape', 'Devis envoyé', 'Suivre l’avancement'],
          ['Dernier contact', '12/10 : visite, demande de devis', 'Garder l’historique'],
          ['Prochaine action + date', 'Relancer le devis le 19/10', 'Ne rien oublier'],
          ['CA cumulé', '2 400 000 FCFA', 'Prioriser']
        ]},
        { t: 'h', x: 'La technique de la recommandation' },
        { t: 'list', items: [
          '**Le bon moment** : juste après une satisfaction exprimée (« Merci, la livraison était parfaite ! »).',
          '**La bonne question** : « Qui, dans votre entourage, aurait besoin du même service ? » plutôt que « Vous connaissez quelqu’un ? ».',
          '**La facilitation** : proposer un message WhatsApp prêt à transférer.',
          '**Le remerciement** : informer le client du résultat et le remercier (bon d’achat, attention).'
        ]},
        { t: 'case', title: 'Étude de cas : Aïcha, conseillère en assurance à Ouagadougou',
          context: 'Aïcha a 180 clients mais ne les recontacte qu’à l’échéance annuelle. Chaque année, elle perd environ 25 % d’entre eux, souvent au profit d’un concurrent qui les a appelés avant elle. Elle note tout dans un carnet.',
          questions: ['Quelle est la cause principale des pertes ?', 'Proposez un plan d’action en 3 points.'],
          solution: 'Cause : **aucun contact entre deux échéances**, donc pas de relation, et un concurrent qui arrive au bon moment. Plan : 1) **CRM Google Sheets** avec la date d’échéance de chaque contrat et une alerte 60 jours avant ; 2) **plan de contact** : message à J+7 après souscription, vœux et conseil prévention au milieu de l’année, appel de bilan 60 jours avant l’échéance ; 3) **recommandations** demandées après chaque sinistre bien indemnisé, avec un message prêt à transférer. Objectif : passer de 25 % à moins de 10 % de clients perdus.' }
      ]
    }
  ],
  takeaways: [
    'La valeur d’un client se mesure sur toute la relation (CLV), recommandations comprises.',
    'Plan de contact : qui, quand, par quel canal, avec quel message.',
    'Un CRM simple : contact, segment, étape, dernier contact, prochaine action, CA.',
    'Demander les recommandations au bon moment, avec la bonne question.'
  ],
  deliverable: { title: 'Mon CRM et mon plan de contact', x: 'Un tableur avec au moins 20 clients renseignés (6 colonnes), leur segment et la prochaine action datée, plus 3 messages types (remerciement, satisfaction, recommandation).' },
  quiz: [
    { q: 'Une cliente dépense 20 000 FCFA, 6 fois par an, pendant 5 ans. Quelle est sa valeur vie client ?', options: ['120 000 FCFA', '600 000 FCFA', '100 000 FCFA', '2 000 000 FCFA'], a: 1, why: '20 000 × 6 × 5 = 600 000 FCFA.' },
    { q: 'Quel est le dernier échelon de l’échelle de fidélité ?', options: ['Client régulier', 'Ambassadeur', 'Client fidèle', 'Prospect'], a: 1, why: 'L’ambassadeur recommande activement l’entreprise.' },
    { q: 'Quelle colonne de CRM évite d’oublier une relance ?', options: ['Le segment', 'La prochaine action avec sa date', 'Le CA cumulé', 'Le nom de l’entreprise'], a: 1, why: 'Chaque client doit avoir une prochaine action datée.' },
    { q: 'Quel est le meilleur moment pour demander une recommandation ?', options: ['Au premier rendez-vous', 'Juste après une satisfaction exprimée', 'Lors d’une réclamation', 'Jamais'], a: 1, why: 'Le client satisfait est le plus disposé à recommander.' },
    { q: 'Que faire avec un client inactif depuis 3 mois ?', options: ['Le supprimer du fichier', 'L’appeler pour comprendre et proposer une offre de retour', 'Attendre qu’il revienne', 'Lui envoyer tout le catalogue'], a: 1, why: 'Comprendre la raison de l’inactivité permet souvent de le récupérer.' },
    { q: 'Pourquoi Aïcha perdait-elle des clients ?', options: ['Ses prix étaient trop élevés', 'Elle ne les contactait qu’à l’échéance', 'Elle avait trop de clients', 'Ses produits étaient mauvais'], a: 1, why: 'Sans relation entre deux échéances, le concurrent arrive au bon moment.' }
  ]
};
