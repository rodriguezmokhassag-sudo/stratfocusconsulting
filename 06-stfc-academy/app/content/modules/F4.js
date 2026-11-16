// Module F4 — Les bases du marketing digital (gratuit)
module.exports = {
  id: 'F4', title: 'Les bases du marketing digital', status: 'complet', duration: '50 min',
  summary: 'Comprendre le parcours client en ligne, construire une présence digitale efficace avec un petit budget et mesurer ses résultats.',
  objectives: [
    'Décrire le parcours client digital (modèle AARRR)',
    'Choisir ses canaux : réseaux sociaux, WhatsApp, Google, e-mail, SMS',
    'Lancer une campagne publicitaire Facebook/Instagram à petit budget',
    'Suivre 5 indicateurs clés (portée, clics, coût par contact, conversion, ROI)'
  ],
  skills: ['Parcours client digital', 'Publicité sur les réseaux sociaux', 'Mesure de performance'],
  video: {
    title: 'Le marketing digital avec 10 000 FCFA', duration: '6 min', src: null,
    script: [
      'Accroche : « Votre client vous cherche déjà sur son téléphone. Est-ce qu’il vous trouve ? »',
      'Le parcours AARRR, dessiné à l’écran.',
      'Les canaux qui marchent en Afrique francophone : Facebook, WhatsApp, TikTok, Google Maps.',
      'Démonstration : paramétrer une publicité Facebook à 2 000 FCFA par jour.',
      'Les 5 chiffres à suivre chaque semaine.'
    ]
  },
  lessons: [
    {
      title: 'Le parcours client digital',
      blocks: [
        { t: 'p', x: 'Le **marketing digital** regroupe toutes les actions qui attirent, convainquent et fidélisent des clients grâce à internet et au mobile. En Afrique francophone, la grande majorité des internautes se connectent **par smartphone**. Votre vitrine digitale doit donc d’abord être pensée pour un petit écran et une connexion parfois lente.' },
        { t: 'flow', caption: 'Le modèle AARRR (« pirate funnel »)', items: ['Acquisition', 'Activation', 'Rétention', 'Recommandation', 'Revenu'] },
        { t: 'table', caption: 'AARRR appliqué à un traiteur de Cotonou', head: ['Étape', 'Question', 'Exemple d’action', 'Indicateur'], rows: [
          ['Acquisition', 'Comment me découvre-t-on ?', 'Vidéos TikTok des plats, fiche Google Maps', 'Vues, visites du profil'],
          ['Activation', 'Le prospect fait-il un premier pas ?', 'Message WhatsApp « Menu du jour » en 1 clic', 'Conversations ouvertes'],
          ['Rétention', 'Revient-il ?', 'Liste de diffusion avec le menu chaque matin', 'Taux de réachat'],
          ['Recommandation', 'Parle-t-il de moi ?', '1 repas offert pour 3 amis parrainés', 'Nouveaux clients parrainés'],
          ['Revenu', 'Combien rapporte-t-il ?', 'Formule entreprise à la semaine', 'Panier moyen, CA par client']
        ]},
        { t: 'tip', x: 'Le digital ne remplace pas la vente : il **remplit l’agenda des commerciaux** avec des prospects déjà intéressés.' }
      ]
    },
    {
      title: 'Choisir ses canaux et créer du contenu',
      blocks: [
        { t: 'table', caption: 'Les canaux et leur rôle', head: ['Canal', 'Force', 'Limite', 'Idéal pour'], rows: [
          ['Facebook / Instagram', 'Très large audience, ciblage publicitaire précis', 'Portée organique faible', 'Notoriété, génération de contacts'],
          ['WhatsApp Business', 'Taux de lecture très élevé, relation directe', 'Pas de découverte : il faut déjà le numéro', 'Conversion, fidélisation'],
          ['TikTok', 'Viralité, audience jeune', 'Production vidéo régulière', 'Notoriété, marques grand public'],
          ['Google (Maps, recherche)', 'Capte une demande existante', 'Concurrence sur les mots-clés', 'Commerces locaux, services'],
          ['LinkedIn', 'Décideurs B2B', 'Audience plus restreinte', 'Ventes aux entreprises'],
          ['SMS / e-mail', 'Direct, peu coûteux', 'Risque de spam', 'Relances, promotions aux clients']
        ]},
        { t: 'h', x: 'La règle des 4 contenus' },
        { t: 'list', items: [
          '**Éduquer** : conseils, astuces, tutoriels (« 3 erreurs qui font fondre votre stock »).',
          '**Prouver** : témoignages clients, avant/après, chiffres.',
          '**Humaniser** : coulisses, équipe, valeurs.',
          '**Vendre** : offre claire, prix, appel à l’action (« Écrivez “MENU” sur WhatsApp »).'
        ]},
        { t: 'action', x: 'Planifiez vos publications de la semaine prochaine : 1 contenu de chaque type.' }
      ]
    },
    {
      title: 'Publicité à petit budget et mesure des résultats',
      blocks: [
        { t: 'steps', items: [
          { title: 'Un objectif', x: 'Choisir « Messages » (conversations WhatsApp) plutôt que « J’aime la page ».' },
          { title: 'Une cible', x: 'Ville, âge, centres d’intérêt. Commencer large (ex. Abidjan, 25-45 ans) puis affiner.' },
          { title: 'Un visuel simple', x: 'Photo réelle du produit, texte court, prix ou bénéfice clair.' },
          { title: 'Un budget test', x: '2 000 à 5 000 FCFA par jour pendant 5 à 7 jours.' },
          { title: 'Une analyse', x: 'Garder la publicité qui coûte le moins par conversation, couper les autres.' }
        ]},
        { t: 'table', caption: 'Les 5 indicateurs à suivre chaque semaine', head: ['Indicateur', 'Calcul', 'Exemple'], rows: [
          ['Portée', 'Personnes ayant vu le contenu', '25 000'],
          ['Taux de clic (CTR)', 'Clics ÷ impressions', '1,8 %'],
          ['Coût par contact', 'Dépense ÷ conversations ou contacts', '20 000 FCFA ÷ 80 = 250 FCFA'],
          ['Taux de conversion', 'Ventes ÷ contacts', '12 ÷ 80 = 15 %'],
          ['ROI (retour sur investissement)', '(Marge générée − dépense) ÷ dépense', '(60 000 − 20 000) ÷ 20 000 = 200 %']
        ]},
        { t: 'case', title: 'Étude de cas : Fatou, boutique de wax en ligne à Dakar',
          context: 'Fatou dépense 50 000 FCFA de publicité Facebook par mois pour « booster » ses publications. Sa page a gagné 3 000 abonnés mais ses ventes n’ont pas augmenté. Elle ne sait pas combien de clients viennent de la publicité.',
          questions: ['Quelles erreurs Fatou commet-elle ?', 'Que lui recommandez-vous pour le mois prochain ?'],
          solution: 'Erreurs : objectif « abonnés » au lieu de **messages ou ventes**, **aucune mesure** du coût par contact ni des ventes générées, boost sans ciblage. Recommandations : 1) campagne avec objectif **Messages WhatsApp**, ciblée Dakar, femmes de 22 à 45 ans intéressées par la mode ; 2) 3 visuels testés à 2 000 FCFA par jour ; 3) une **étiquette WhatsApp « Pub »** pour compter les contacts et les ventes qui en viennent ; 4) après 7 jours, garder le visuel au coût par vente le plus bas.' }
      ]
    }
  ],
  takeaways: [
    'AARRR : Acquisition, Activation, Rétention, Recommandation, Revenu.',
    'Chaque canal a un rôle : Facebook et TikTok pour attirer, WhatsApp pour convertir et fidéliser.',
    'Contenus : éduquer, prouver, humaniser, vendre.',
    'Mesurer le coût par contact, la conversion et le ROI plutôt que les « j’aime ».'
  ],
  deliverable: { title: 'Plan digital de 30 jours', x: 'Un tableau d’une page : objectif, canal principal, 12 publications planifiées (4 types de contenus), budget publicitaire et les 5 indicateurs avec leur cible.' },
  quiz: [
    { q: 'Que signifie le premier « A » du modèle AARRR ?', options: ['Achat', 'Acquisition', 'Analyse', 'Abonnement'], a: 1, why: 'L’acquisition, c’est la manière dont un prospect vous découvre.' },
    { q: 'Quel canal a le meilleur taux de lecture pour relancer des clients existants ?', options: ['Une bannière web', 'WhatsApp Business', 'Une affiche', 'Un communiqué de presse'], a: 1, why: 'Les messages WhatsApp sont lus très rapidement par la grande majorité des destinataires.' },
    { q: 'Pour une publicité destinée à générer des ventes, quel objectif choisir ?', options: ['Mentions J’aime', 'Messages ou conversions', 'Vues de la page', 'Abonnés'], a: 1, why: 'L’objectif doit correspondre au résultat recherché : des conversations qui mènent à des ventes.' },
    { q: 'Une dépense de 30 000 FCFA génère 100 conversations. Quel est le coût par contact ?', options: ['3 000 FCFA', '300 FCFA', '30 FCFA', '100 FCFA'], a: 1, why: '30 000 ÷ 100 = 300 FCFA par contact.' },
    { q: 'Un témoignage client vidéo est un contenu de type…', options: ['Éduquer', 'Prouver', 'Vendre', 'Humaniser'], a: 1, why: 'Il apporte une preuve sociale de la valeur de l’offre.' },
    { q: 'Quelle était l’erreur principale de Fatou ?', options: ['Utiliser Facebook', 'Payer de la publicité sans objectif de vente ni mesure', 'Vendre du wax', 'Avoir trop d’abonnés'], a: 1, why: 'Sans objectif adapté ni mesure, on ne sait pas si la dépense rapporte.' },
    { q: 'Le ROI se calcule par…', options: ['Ventes ÷ visiteurs', '(Marge générée − dépense) ÷ dépense', 'Clics ÷ impressions', 'Abonnés ÷ publications'], a: 1, why: 'Le ROI compare le gain net à la dépense engagée.' }
  ]
};
