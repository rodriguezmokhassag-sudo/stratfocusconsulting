// Module C3 — Négociation et closing
module.exports = {
  id: 'C3', title: 'Négociation et closing', status: 'complet', duration: '65 min',
  summary: 'Préparer une négociation, défendre sa marge face aux acheteurs, repérer les signaux d’achat et conclure la vente avec assurance.',
  objectives: [
    'Préparer une négociation avec la grille des concessions (objectif, MESORE, point de rupture)',
    'Défendre son prix face aux tactiques des acheteurs',
    'Repérer les signaux d’achat',
    'Choisir la bonne technique de conclusion'
  ],
  skills: ['Préparation de négociation', 'Gestion des concessions', 'Techniques de closing'],
  video: {
    title: 'Oser demander la commande', duration: '6 min', src: null,
    script: [
      'Accroche : « La plupart des ventes perdues n’ont jamais été demandées. »',
      'La zone d’accord : objectif, point de rupture, MESORE.',
      'Trois tactiques d’acheteurs et la parade à chacune.',
      'Les signaux d’achat, illustrés en jeu de rôle.',
      'Quatre phrases pour conclure.'
    ]
  },
  lessons: [
    {
      title: 'Préparer sa négociation',
      blocks: [
        { t: 'p', x: 'On ne négocie bien que ce que l’on a préparé. Avant chaque rendez-vous important, définissez votre **zone de négociation** et la liste des concessions possibles.' },
        { t: 'table', caption: 'Les repères de préparation', head: ['Repère', 'Définition', 'Exemple (contrat de fourniture de riz, Abidjan)'], rows: [
          ['Objectif idéal', 'Le meilleur résultat réaliste', '20 tonnes/mois à 410 FCFA/kg, paiement à 15 jours'],
          ['Point de rupture', 'En dessous, on ne signe pas', '385 FCFA/kg ou paiement au-delà de 45 jours'],
          ['MESORE', 'Meilleure solution de rechange si pas d’accord', 'Vendre ces volumes à deux grossistes de Bouaké à 395 FCFA/kg'],
          ['Concessions possibles', 'Ce qu’on peut céder, du moins coûteux au plus coûteux', 'Livraison groupée, sacs de 25 kg, délai de paiement, prix']
        ]},
        { t: 'h', x: 'La grille des concessions' },
        { t: 'table', head: ['Je peux donner', 'Coût pour moi', 'Valeur pour le client', 'Contrepartie demandée'], rows: [
          ['Livraison gratuite', 'Faible (tournée existante)', 'Forte', 'Engagement de 6 mois'],
          ['Paiement à 30 jours', 'Moyen (trésorerie)', 'Forte', 'Volume minimum de 20 tonnes'],
          ['Remise de 2 %', 'Élevé (marge)', 'Moyenne', 'Paiement comptant']
        ]},
        { t: 'tip', x: 'Commencez toujours par céder ce qui vous **coûte peu** et vaut **beaucoup** pour le client.' }
      ]
    },
    {
      title: 'Défendre son prix face aux acheteurs',
      blocks: [
        { t: 'table', caption: 'Tactiques fréquentes des acheteurs et parades', head: ['Tactique', 'Ce que dit l’acheteur', 'Parade'], rows: [
          ['Le concurrent fantôme', '« Votre concurrent me fait 10 % de moins »', '« Sur quelle offre exactement ? Comparons à périmètre égal : délais, qualité, SAV. »'],
          ['Le salami', 'Demander une petite concession après l’autre', 'Récapituler l’ensemble : « Si je fais cela, signons-nous aujourd’hui ? »'],
          ['L’ultimatum', '« C’est ce prix ou rien »', 'Rester calme, reformuler, rappeler la valeur, connaître sa MESORE'],
          ['Le grignotage final', '« Ajoutez juste la livraison et je signe »', 'Échanger : « D’accord si la commande passe à 25 tonnes. »'],
          ['Le silence', 'L’acheteur se tait après votre prix', 'Ne pas combler le silence par une remise : attendre']
        ]},
        { t: 'flow', caption: 'Le principe du donnant-donnant', items: ['Demande du client', '« Si… alors… »', 'Contrepartie obtenue', 'Concession accordée'] },
        { t: 'action', x: 'Quelle tactique vos acheteurs utilisent-ils le plus ? Écrivez votre parade.' }
      ]
    },
    {
      title: 'Repérer les signaux d’achat et conclure',
      blocks: [
        { t: 'table', caption: 'Signaux d’achat', head: ['Type', 'Exemples'], rows: [
          ['Verbaux', '« Vous livrez quand ? », « La garantie démarre quand ? », « On peut payer par Orange Money ? »'],
          ['Non verbaux', 'Le client reprend le document, hoche la tête, appelle un collègue pour lui montrer'],
          ['Questions de projection', '« Si on prend 50 unités… », « Comment se passe la formation de mon équipe ? »']
        ]},
        { t: 'table', caption: 'Techniques de conclusion', head: ['Technique', 'Formulation', 'Quand l’utiliser'], rows: [
          ['La conclusion directe', '« On valide la commande ? »', 'Signaux d’achat clairs'],
          ['L’alternative', '« Livraison lundi ou jeudi ? »', 'Client indécis sur les détails'],
          ['Le récapitulatif', '« Nous avons dit : 20 tonnes, livraison incluse, paiement à 30 jours. On signe ? »', 'Négociation longue'],
          ['L’essai', '« Commençons par une commande test de 5 tonnes. »', 'Client prudent, nouveau fournisseur'],
          ['L’urgence réelle', '« Le prix est garanti jusqu’à vendredi, avant la hausse du fret. »', 'Uniquement si c’est vrai']
        ]},
        { t: 'case', title: 'Étude de cas : Eric, commercial en solutions solaires à Douala',
          context: 'Après une heure d’échange, le gérant d’un hôtel demande : « Et l’installation, elle prend combien de jours ? Mon personnel sera formé ? » Eric répond en détail, puis enchaîne sur une nouvelle présentation des panneaux. Le gérant finit par dire : « Envoyez-moi tout ça par e-mail. »',
          questions: ['Quels signaux d’achat Eric a-t-il manqués ?', 'Quelle conclusion aurait-il dû proposer ?'],
          solution: 'Les questions sur **la durée d’installation** et **la formation du personnel** sont des signaux de projection : le gérant s’imaginait déjà client. Eric aurait dû arrêter d’argumenter et conclure, par exemple par l’**alternative** : « L’installation prend 3 jours. Préférez-vous démarrer la semaine prochaine ou celle d’après, pour que la formation de votre équipe ait lieu avant le week-end ? » ou par un **récapitulatif** suivi de « On valide ? ».' }
      ]
    }
  ],
  takeaways: [
    'Préparer : objectif, point de rupture, MESORE, grille des concessions.',
    'Toujours le donnant-donnant : « Si… alors… ».',
    'Écouter les signaux d’achat, puis arrêter d’argumenter.',
    'Oser demander la commande avec la bonne technique.'
  ],
  deliverable: { title: 'Fiche de préparation de négociation', x: 'Pour votre prochain rendez-vous important : objectif idéal, point de rupture, MESORE, grille de 5 concessions avec contreparties, et 2 formulations de conclusion.' },
  quiz: [
    { q: 'Que signifie MESORE ?', options: ['Marge essentielle sur remise', 'Meilleure solution de rechange en l’absence d’accord', 'Méthode de suivi des relances', 'Montant estimé de la remise'], a: 1, why: 'Connaître sa solution de rechange donne de la force dans la négociation.' },
    { q: 'Quelle concession céder en premier ?', options: ['Celle qui coûte cher et vaut peu', 'Celle qui coûte peu et vaut beaucoup pour le client', 'Une remise sur le prix', 'Aucune, jamais'], a: 1, why: 'On maximise la valeur perçue pour un coût minimal.' },
    { q: 'L’acheteur demande une petite concession après l’autre. C’est la tactique…', options: ['Du silence', 'Du salami', 'De l’ultimatum', 'Du concurrent fantôme'], a: 1, why: 'Il découpe ses demandes pour obtenir beaucoup au total.' },
    { q: '« Vous livrez quand ? » est…', options: ['Une objection', 'Un signal d’achat', 'Une question piège', 'Une fin de non-recevoir'], a: 1, why: 'Le client se projette dans l’après-achat.' },
    { q: '« Livraison lundi ou jeudi ? » est une conclusion par…', options: ['L’urgence', 'L’alternative', 'L’essai', 'Le récapitulatif'], a: 1, why: 'On fait choisir entre deux options qui supposent toutes deux l’achat.' },
    { q: 'Que faire quand l’acheteur se tait après l’annonce du prix ?', options: ['Proposer vite une remise', 'Attendre calmement', 'Changer de sujet', 'Partir'], a: 1, why: 'Combler le silence par une remise est une erreur classique.' },
    { q: 'Quelle était l’erreur d’Eric ?', options: ['Il a répondu aux questions', 'Il a continué d’argumenter au lieu de conclure', 'Il a parlé d’installation', 'Il a proposé une formation'], a: 1, why: 'Il a manqué les signaux d’achat et n’a pas demandé la commande.' }
  ]
};
