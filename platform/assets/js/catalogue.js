/*
 * STFC Academy — Catalogue des parcours et modules
 * ------------------------------------------------
 * Ce fichier contient TOUT le contenu pédagogique. Il peut être édité sans toucher au code.
 *
 * Types de blocs disponibles dans une leçon :
 *  { t:'p', x }                         paragraphe
 *  { t:'h', x }                         sous-titre
 *  { t:'list', items:[] }               liste à puces
 *  { t:'steps', items:[{title,x}] }     étapes numérotées
 *  { t:'table', caption, head:[], rows:[[]] }
 *  { t:'matrix', caption, x, y, q:[{title,x} x4] }   matrice 2x2 (haut-gauche, haut-droite, bas-gauche, bas-droite)
 *  { t:'flow', caption, items:[] }      schéma de flux (étapes reliées par des flèches)
 *  { t:'funnel', caption, items:[{label,value}] }    entonnoir
 *  { t:'case', title, context, questions:[], solution }   étude de cas (corrigé masqué)
 *  { t:'tip', x }                       encadré « À retenir »
 *  { t:'action', x }                    encadré « Et vous ? » (mise en pratique)
 *
 * status : 'complet' (module rédigé, quiz actif) | 'bientot' (structure prête, contenu en rédaction)
 * video.src : URL d'intégration (YouTube nocookie, Bunny, Vimeo…). null = emplacement en attente du tournage.
 */

window.CATALOGUE = {
  updated: '2026-10-31',
  passMark: 80,

  tracks: [
    {
      id: 'decouverte', title: 'Découverte', free: true, price: 0, level: 0,
      audience: 'Tout public, étudiants, entrepreneurs, curieux',
      desc: 'Trois modules gratuits et complets pour découvrir la vente moderne et le marketing d’innovation. Attestation offerte à chaque module validé.',
      modules: ['F1', 'F2', 'F3']
    },
    {
      id: 'commercial', title: 'Commercial', price: 35000, installments: 12500, level: 1,
      audience: 'Débutants, vendeurs terrain, téléconseillers, commerciaux juniors',
      desc: 'Maîtriser chaque étape de l’entretien de vente : découvrir, argumenter, traiter les objections, conclure et fidéliser.',
      modules: ['C1', 'C2', 'C3', 'C4', 'C5']
    },
    {
      id: 'chef-equipe', title: 'Chef d’équipe commercial', price: 65000, installments: 22500, level: 2,
      audience: 'Commerciaux confirmés promus ou en voie de promotion',
      desc: 'Réussir le passage de vendeur à manager : animer, motiver, coacher sur le terrain et piloter les résultats d’une équipe.',
      modules: ['E1', 'E2', 'E3', 'E4']
    },
    {
      id: 'responsable', title: 'Responsable commercial', price: 95000, installments: 33000, level: 3,
      audience: 'Responsables de zone, de canal, d’agence ou de grands secteurs',
      desc: 'Construire et déployer un plan d’action commercial, segmenter un portefeuille, piloter les canaux de distribution et le budget des ventes.',
      modules: ['R1', 'R2', 'R3', 'R4', 'R5']
    },
    {
      id: 'directeur', title: 'Directeur commercial', price: 150000, installments: 52000, level: 4,
      audience: 'Directeurs commerciaux, DG de PME, cadres dirigeants',
      desc: 'Définir la stratégie commerciale et d’innovation, organiser et rémunérer la force de vente, fixer les prix et conduire la transformation digitale.',
      modules: ['D1', 'D2', 'D3', 'D4', 'D5', 'D6']
    }
  ],

  passCarriere: { price: 249000, installments: 85000 },

  modules: {

    /* =====================================================================
     *  MODULES GRATUITS
     * ===================================================================*/

    F1: {
      title: 'Les fondamentaux de la vente', status: 'complet', duration: '45 min',
      summary: 'Comprendre le rôle du commercial moderne, le cycle de vente en 7 étapes et les motivations profondes des clients.',
      objectives: [
        'Expliquer ce qui distingue un commercial « conseil » d’un simple vendeur',
        'Dérouler les 7 étapes du cycle de vente',
        'Identifier les motivations d’achat d’un client grâce à la méthode SONCAS'
      ],
      skills: ['Cycle de vente', 'Posture conseil', 'Motivations d’achat (SONCAS)'],
      video: {
        title: 'La vente en 5 minutes', duration: '5 min', src: null,
        script: [
          'Accroche : « Vendre, ce n’est pas convaincre, c’est aider quelqu’un à décider. »',
          'Le marché a changé : le client compare sur WhatsApp et Facebook avant même de vous voir.',
          'Les 7 étapes du cycle de vente, avec un schéma à l’écran.',
          'SONCAS : 6 raisons pour lesquelles les gens achètent.',
          'Appel à l’action : lisez les leçons et validez le quiz pour obtenir votre attestation.'
        ]
      },
      lessons: [
        {
          title: 'Le rôle du commercial aujourd’hui',
          blocks: [
            { t: 'p', x: 'En Afrique francophone, le client a changé. Il compare les prix sur WhatsApp, lit les avis sur Facebook et demande conseil à son réseau avant d’acheter. Le commercial qui se contente de « pousser » un produit est remplacé par un catalogue en ligne. Celui qui **comprend le problème du client et propose une solution** devient indispensable.' },
            { t: 'table', caption: 'Vendeur traditionnel ou commercial conseil', head: ['Critère', 'Vendeur traditionnel', 'Commercial conseil'], rows: [
              ['Point de départ', 'Son produit', 'Le besoin du client'],
              ['Temps de parole', '80 % lui, 20 % le client', '30 % lui, 70 % le client'],
              ['Objectif', 'Vendre aujourd’hui', 'Créer une relation durable'],
              ['Arme principale', 'Le prix, la remise', 'La valeur, la preuve'],
              ['Après la vente', 'Disparaît', 'Suit, fidélise, obtient des recommandations']
            ]},
            { t: 'h', x: 'Les 4 compétences clés' },
            { t: 'list', items: [
              '**Écouter** : poser des questions et reformuler.',
              '**Comprendre** : relier les besoins du client à ses enjeux (gagner de l’argent, du temps, de la sécurité).',
              '**Convaincre** : argumenter avec des preuves adaptées.',
              '**Organiser** : planifier ses visites, suivre ses relances, mesurer ses résultats.'
            ]},
            { t: 'tip', x: 'Un bon commercial ne vend pas un produit, il vend un **résultat** : une boutique mieux achalandée, un temps gagné, un risque évité.' },
            { t: 'action', x: 'Pensez à votre dernier achat important. Le vendeur a-t-il parlé de son produit ou de votre besoin ?' }
          ]
        },
        {
          title: 'Le cycle de vente en 7 étapes',
          blocks: [
            { t: 'p', x: 'Toute vente, d’un sac de ciment à un logiciel bancaire, suit le même cycle. Le maîtriser permet de savoir **où l’on en est avec chaque client** et quoi faire ensuite.' },
            { t: 'flow', caption: 'Le cycle de vente', items: ['1. Préparer', '2. Prospecter', '3. Découvrir', '4. Argumenter', '5. Traiter les objections', '6. Conclure', '7. Fidéliser'] },
            { t: 'steps', items: [
              { title: 'Préparer', x: 'Connaître son offre, ses prix, ses concurrents, et se renseigner sur le client (activité, taille, décideur).' },
              { title: 'Prospecter', x: 'Trouver de nouveaux clients : visites terrain, appels, WhatsApp, recommandations, salons.' },
              { title: 'Découvrir', x: 'Poser des questions pour comprendre la situation, les problèmes et les attentes du client.' },
              { title: 'Argumenter', x: 'Présenter les bénéfices de la solution qui répondent exactement à ce que le client a dit.' },
              { title: 'Traiter les objections', x: 'Accueillir les doutes (« c’est cher », « je vais réfléchir ») et y répondre sans se braquer.' },
              { title: 'Conclure', x: 'Demander la commande, fixer les modalités (quantité, livraison, paiement).' },
              { title: 'Fidéliser', x: 'Livrer, suivre, rappeler, proposer et obtenir des recommandations.' }
            ]},
            { t: 'funnel', caption: 'Entonnoir de vente type (exemple d’un distributeur à Abidjan sur un mois)', items: [
              { label: 'Contacts prospectés', value: 200 }, { label: 'Rendez-vous obtenus', value: 60 }, { label: 'Propositions envoyées', value: 25 }, { label: 'Commandes signées', value: 10 }
            ]},
            { t: 'tip', x: 'Sauter l’étape **Découvrir** est l’erreur n°1 des débutants : sans elle, l’argumentation tombe à côté.' }
          ]
        },
        {
          title: 'Comprendre son client : la méthode SONCAS',
          blocks: [
            { t: 'p', x: 'Un client n’achète jamais seulement un produit. Il achète une réponse à une **motivation**. La méthode SONCAS en distingue six.' },
            { t: 'table', caption: 'Les 6 motivations SONCAS', head: ['Motivation', 'Ce que le client cherche', 'Phrase qui le révèle', 'Argument adapté'], rows: [
              ['**S**écurité', 'Éviter les risques', '« Et si ça tombe en panne ? »', 'Garantie, SAV, références clients'],
              ['**O**rgueil', 'Être valorisé', '« Je veux ce qu’il y a de mieux »', 'Exclusivité, image, statut'],
              ['**N**ouveauté', 'Être à la pointe', '« Qu’est-ce qu’il y a de nouveau ? »', 'Innovation, dernière version'],
              ['**C**onfort', 'Se simplifier la vie', '« Je n’ai pas le temps »', 'Livraison, simplicité, service'],
              ['**A**rgent', 'Gagner ou économiser', '« C’est combien ? »', 'Rentabilité, marge, économies'],
              ['**S**ympathie', 'Une bonne relation', '« On se connaît depuis longtemps »', 'Relation, proximité, confiance']
            ]},
            { t: 'case', title: 'Étude de cas : Awa, gérante d’une boutique de cosmétiques à Dakar',
              context: 'Un commercial présente une nouvelle gamme de crèmes à Awa. Elle dit : « J’ai déjà eu des produits qui ne partaient pas, ça m’a coûté cher. Et mes clientes me demandent toujours si c’est sûr pour la peau. »',
              questions: ['Quelles motivations SONCAS dominent chez Awa ?', 'Quels arguments le commercial doit-il mettre en avant ?'],
              solution: 'Deux motivations dominent : **Sécurité** (peur des invendus et de la qualité) et **Argent** (perte passée). Le commercial doit proposer un **dépôt-test** ou une reprise des invendus, montrer les **certifications** du produit, citer des **boutiques voisines** qui le vendent bien, et chiffrer la **marge par pot**. Mettre en avant la nouveauté seule aurait été une erreur.' },
            { t: 'action', x: 'Pour vos 3 principaux clients, notez leur motivation SONCAS dominante.' }
          ]
        }
      ],
      takeaways: ['Le commercial moderne part du besoin, pas du produit.', '7 étapes : préparer, prospecter, découvrir, argumenter, traiter les objections, conclure, fidéliser.', 'SONCAS : Sécurité, Orgueil, Nouveauté, Confort, Argent, Sympathie.'],
      quiz: [
        { q: 'Quelle est la principale différence entre un vendeur traditionnel et un commercial conseil ?', options: ['Le commercial conseil accorde plus de remises', 'Le commercial conseil part du besoin du client', 'Le commercial conseil parle davantage', 'Il n’y a pas de différence'], a: 1, why: 'Le commercial conseil part du besoin du client pour proposer une solution adaptée.' },
        { q: 'Quelle répartition du temps de parole vise un bon commercial lors de la découverte ?', options: ['80 % lui, 20 % le client', '50 / 50', '30 % lui, 70 % le client', '100 % le client'], a: 2, why: 'Le client doit parler le plus : c’est là que l’on apprend ses besoins.' },
        { q: 'Quelle étape les débutants sautent-ils le plus souvent ?', options: ['La conclusion', 'La découverte', 'La prospection', 'La préparation des prix'], a: 1, why: 'Sans découverte, l’argumentation n’est pas ciblée.' },
        { q: 'Un client dit : « Et si ça tombe en panne ? ». Quelle motivation exprime-t-il ?', options: ['Orgueil', 'Nouveauté', 'Sécurité', 'Sympathie'], a: 2, why: 'La peur du risque relève de la Sécurité.' },
        { q: 'Dans le cas d’Awa, quel argument est le MOINS pertinent ?', options: ['Un dépôt-test avec reprise des invendus', 'La marge par pot', 'Les certifications du produit', 'C’est la toute dernière nouveauté du marché'], a: 3, why: 'Awa est motivée par la Sécurité et l’Argent, pas par la Nouveauté.' },
        { q: 'Quelle est la dernière étape du cycle de vente ?', options: ['Conclure', 'Fidéliser', 'Facturer', 'Argumenter'], a: 1, why: 'La vente ne s’arrête pas à la commande : fidéliser crée le réachat et les recommandations.' }
      ]
    },

    F2: {
      title: 'Prospecter avec WhatsApp et les réseaux sociaux', status: 'complet', duration: '50 min',
      summary: 'Utiliser WhatsApp Business, Facebook et LinkedIn pour trouver des clients, sans spammer et avec des scripts qui fonctionnent.',
      objectives: [
        'Configurer un compte WhatsApp Business professionnel',
        'Choisir le bon réseau selon sa cible (B2C ou B2B)',
        'Rédiger des messages de prospection et de relance efficaces'
      ],
      skills: ['Social selling', 'WhatsApp Business', 'Scripts de prospection'],
      video: {
        title: 'Prospecter sur WhatsApp sans spammer', duration: '5 min', src: null,
        script: [
          'Constat : vos clients passent des heures par jour sur WhatsApp.',
          'Démonstration : le profil, le catalogue et les étiquettes dans WhatsApp Business.',
          'La règle 80/20 : 80 % de valeur, 20 % de vente.',
          'Lecture d’un script de premier message et d’une relance.',
          'Appel à l’action : créez votre catalogue aujourd’hui.'
        ]
      },
      lessons: [
        {
          title: 'Le social selling en Afrique francophone',
          blocks: [
            { t: 'p', x: 'Le **social selling** consiste à utiliser les réseaux sociaux pour se faire connaître, créer la confiance et générer des opportunités. En Afrique francophone, WhatsApp et Facebook dominent pour les particuliers et les commerçants, tandis que LinkedIn monte fortement en B2B (banques, télécoms, industrie, ONG).' },
            { t: 'table', caption: 'Quel réseau pour quelle cible ?', head: ['Réseau', 'Cible principale', 'Usage commercial', 'Fréquence conseillée'], rows: [
              ['WhatsApp Business', 'Commerçants, particuliers, PME', 'Catalogue, commandes, suivi, statuts', 'Statuts : 1 par jour'],
              ['Facebook', 'Grand public, commerçants', 'Page, groupes locaux, Marketplace', '3-4 publications par semaine'],
              ['LinkedIn', 'Cadres, décideurs B2B', 'Profil expert, messages ciblés', '2 publications par semaine'],
              ['TikTok', 'Jeunes, 18-30 ans', 'Démonstrations courtes, notoriété', '3-5 vidéos par semaine']
            ]},
            { t: 'matrix', caption: 'Où investir son temps ?', x: 'Effort de mise en place →', y: 'Potentiel de ventes ↑', q: [
              { title: 'Priorité', x: 'WhatsApp Business : très fort potentiel, mise en place rapide' },
              { title: 'Investir', x: 'LinkedIn (B2B) : fort potentiel, demande du temps' },
              { title: 'Entretenir', x: 'Groupes Facebook locaux : potentiel moyen, rapides' },
              { title: 'Tester', x: 'TikTok : potentiel variable, production vidéo exigeante' }
            ]},
            { t: 'tip', x: 'Règle des **80/20** : 80 % de contenus utiles (conseils, témoignages, coulisses) et 20 % d’offres commerciales.' }
          ]
        },
        {
          title: 'Bien configurer WhatsApp Business',
          blocks: [
            { t: 'steps', items: [
              { title: 'Profil professionnel', x: 'Logo, description claire (« Distributeur de matériel électrique à Cotonou, livraison en 24 h »), horaires, adresse, lien.' },
              { title: 'Catalogue', x: 'Une fiche par produit : photo nette, prix, description courte. Le client commande sans appeler.' },
              { title: 'Messages automatiques', x: 'Message d’accueil, message d’absence, réponses rapides (« /prix », « /livraison »).' },
              { title: 'Étiquettes', x: 'Classer les contacts : Nouveau prospect, Devis envoyé, Client, À relancer, VIP.' },
              { title: 'Statuts', x: 'Un statut par jour : produit, témoignage, conseil, coulisses.' },
              { title: 'Listes de diffusion', x: 'N’envoyer qu’aux personnes qui vous ont enregistré, avec un contenu ciblé par étiquette.' }
            ]},
            { t: 'flow', caption: 'Parcours d’un prospect sur WhatsApp', items: ['Statut vu', 'Question du prospect', 'Réponse rapide + catalogue', 'Devis', 'Commande', 'Étiquette Client'] },
            { t: 'action', x: 'Créez aujourd’hui vos 5 étiquettes et 3 réponses rapides.' }
          ]
        },
        {
          title: 'Scripts de prospection et de relance',
          blocks: [
            { t: 'p', x: 'Un bon message de prospection est **court, personnalisé et orienté sur le client**. Il ne cherche pas à vendre tout de suite, il cherche à obtenir **une réponse**.' },
            { t: 'table', caption: 'Structure d’un premier message (méthode A.P.Q.)', head: ['Étape', 'Rôle', 'Exemple'], rows: [
              ['**A**ccroche personnalisée', 'Montrer qu’on connaît le prospect', '« Bonjour M. Kouassi, j’ai vu l’ouverture de votre 2ᵉ pharmacie à Yopougon, félicitations ! »'],
              ['**P**roposition de valeur', 'Un bénéfice concret, chiffré si possible', '« Nous aidons les pharmacies à réduire leurs ruptures de stock de 30 % grâce à une livraison en 24 h. »'],
              ['**Q**uestion ouverte', 'Inviter à répondre', '« Comment gérez-vous vos réapprovisionnements aujourd’hui ? »']
            ]},
            { t: 'table', caption: 'Calendrier de relance', head: ['Jour', 'Action', 'Message type'], rows: [
              ['J0', 'Premier message', 'Méthode A.P.Q.'],
              ['J+3', 'Relance utile', 'Partager un conseil ou un témoignage lié à son activité'],
              ['J+7', 'Relance directe', '« Seriez-vous disponible 10 minutes jeudi ou vendredi ? »'],
              ['J+15', 'Dernière relance', '« Je ne veux pas vous déranger. Dois-je revenir vers vous dans 3 mois ? »']
            ]},
            { t: 'case', title: 'Étude de cas : Koffi, commercial en assurance à Lomé',
              context: 'Koffi envoie à 300 contacts le message : « Bonjour, nous avons la meilleure assurance auto du Togo, contactez-moi ! ». Il obtient 2 réponses, dont une demande de retrait de la liste.',
              questions: ['Quelles sont ses 3 erreurs ?', 'Réécrivez son message.'],
              solution: 'Erreurs : 1) message **non personnalisé** envoyé en masse ; 2) **aucun bénéfice concret** (« la meilleure » ne prouve rien) ; 3) **aucune question** qui invite à répondre. Exemple de réécriture : « Bonjour Mme Mensah, en tant que gérante d’une flotte de taxis-motos, vous savez combien un sinistre coûte cher. Nos clients transporteurs ont réduit leurs primes de 15 % avec notre formule flotte. Combien de véhicules assurez-vous actuellement ? » Et l’envoyer à 30 prospects bien ciblés plutôt qu’à 300.' }
          ]
        }
      ],
      takeaways: ['WhatsApp Business est l’outil de prospection n°1 en Afrique francophone.', 'Règle 80/20 : 80 % de valeur, 20 % de vente.', 'Premier message = Accroche personnalisée + Proposition de valeur + Question.', 'Relancer à J+3, J+7 et J+15, puis s’arrêter poliment.'],
      quiz: [
        { q: 'Quel réseau privilégier pour prospecter des directeurs financiers de banques ?', options: ['TikTok', 'LinkedIn', 'Facebook Marketplace', 'Les statuts WhatsApp'], a: 1, why: 'LinkedIn est le réseau des décideurs B2B.' },
        { q: 'Que signifie la règle des 80/20 en social selling ?', options: ['80 % de remises, 20 % de prix plein', '80 % de contenus utiles, 20 % d’offres', '80 % de messages privés, 20 % publics', '80 % de prospects, 20 % de clients'], a: 1, why: 'On crée la confiance avec de la valeur avant de vendre.' },
        { q: 'À quoi servent les étiquettes WhatsApp Business ?', options: ['À décorer le profil', 'À classer les contacts selon leur avancement', 'À bloquer les concurrents', 'À envoyer des messages anonymes'], a: 1, why: 'Elles permettent de suivre chaque prospect dans le cycle de vente.' },
        { q: 'Quel est l’objectif d’un premier message de prospection ?', options: ['Vendre immédiatement', 'Obtenir une réponse', 'Envoyer le catalogue complet', 'Donner tous les prix'], a: 1, why: 'Le premier message ouvre la conversation, il ne cherche pas à conclure.' },
        { q: 'Quelle erreur principale Koffi a-t-il commise ?', options: ['Écrire trop poliment', 'Envoyer un message générique en masse', 'Se présenter', 'Utiliser WhatsApp'], a: 1, why: 'Un message non personnalisé et sans bénéfice concret est perçu comme du spam.' },
        { q: 'Que faire après la relance de J+15 sans réponse ?', options: ['Relancer tous les jours', 'Appeler 10 fois', 'Proposer de revenir dans quelques mois et s’arrêter', 'Insulter le prospect'], a: 2, why: 'Rester respectueux préserve l’image et laisse la porte ouverte.' }
      ]
    },

    F3: {
      title: 'Initiation au marketing d’innovation', status: 'complet', duration: '50 min',
      summary: 'Comprendre l’innovation frugale africaine, construire une proposition de valeur avec le Value Proposition Canvas et tester une idée vite et à moindre coût.',
      objectives: [
        'Distinguer innovation de rupture, incrémentale et frugale',
        'Remplir un Value Proposition Canvas',
        'Concevoir un test terrain (MVP) en moins de 2 semaines'
      ],
      skills: ['Innovation frugale', 'Value Proposition Canvas', 'Test & apprentissage (MVP)'],
      video: {
        title: 'Innover avec peu de moyens', duration: '6 min', src: null,
        script: [
          'Accroche : M-Pesa et Wave sont nés de contraintes, pas de gros budgets.',
          'Les 3 types d’innovation, avec un schéma à l’écran.',
          'Le Value Proposition Canvas expliqué sur un exemple de livraison de gaz.',
          'MVP : tester avant d’investir.',
          'Appel à l’action : remplissez votre canvas.'
        ]
      },
      lessons: [
        {
          title: 'Qu’est-ce que le marketing d’innovation ?',
          blocks: [
            { t: 'p', x: 'Le marketing d’innovation consiste à **créer de la valeur nouvelle** pour le client : un nouveau produit, un nouveau service, un nouveau modèle de vente ou de paiement. L’Afrique est l’un des laboratoires mondiaux de l’**innovation frugale** : faire mieux avec moins.' },
            { t: 'table', caption: 'Trois types d’innovation', head: ['Type', 'Définition', 'Exemple africain'], rows: [
              ['Incrémentale', 'Améliorer l’existant', 'Vendre l’huile ou le savon en petits sachets pour les budgets journaliers'],
              ['De rupture', 'Changer les règles du marché', 'Le Mobile Money (M-Pesa, Orange Money) qui remplace la banque pour des millions de personnes'],
              ['Frugale', 'Solution simple, robuste, abordable', 'Wave et ses frais de transfert très bas, les kits solaires payables à l’usage (PAYG)']
            ]},
            { t: 'matrix', caption: 'Matrice d’Ansoff simplifiée : où innover ?', x: 'Produit existant → nouveau', y: 'Marché nouveau ↑ / existant', q: [
              { title: 'Développement de marché', x: 'Produit actuel, nouveaux clients ou pays' },
              { title: 'Diversification', x: 'Nouveau produit, nouveau marché (risque élevé)' },
              { title: 'Pénétration', x: 'Vendre plus du même produit aux mêmes clients' },
              { title: 'Développement de produit', x: 'Nouveau produit pour les clients actuels' }
            ]},
            { t: 'tip', x: 'Innover, ce n’est pas forcément inventer une technologie. C’est souvent **changer la façon de vendre, d’emballer ou de faire payer**.' }
          ]
        },
        {
          title: 'Le Value Proposition Canvas',
          blocks: [
            { t: 'p', x: 'Le **Value Proposition Canvas** (Strategyzer) vérifie que votre offre répond vraiment à votre client. Il compare deux côtés : le **profil client** et la **carte de valeur**.' },
            { t: 'table', caption: 'Les deux côtés du canvas', head: ['Profil client', 'Question', 'Carte de valeur', 'Question'], rows: [
              ['Tâches', 'Que cherche-t-il à accomplir ?', 'Produits et services', 'Que proposez-vous ?'],
              ['Douleurs', 'Qu’est-ce qui le gêne ou lui fait peur ?', 'Anti-douleurs', 'Comment supprimez-vous ces douleurs ?'],
              ['Gains', 'Qu’est-ce qui le rendrait heureux ?', 'Créateurs de gains', 'Comment créez-vous ces gains ?']
            ]},
            { t: 'case', title: 'Étude de cas : GazExpress, livraison de bouteilles de gaz à Douala',
              context: 'Une PME veut lancer la livraison à domicile de bouteilles de gaz. Les ménages se plaignent de ruptures dans les dépôts, de devoir porter la bouteille et de ne pas savoir quand elle sera vide.',
              questions: ['Listez 2 tâches, 3 douleurs et 2 gains du client.', 'Proposez 3 anti-douleurs ou créateurs de gains.'],
              solution: '**Tâches** : cuisiner tous les jours, remplacer la bouteille vide. **Douleurs** : ruptures en dépôt, transport pénible, panne de gaz en pleine cuisson. **Gains** : ne jamais manquer de gaz, payer en Mobile Money. **Offre** : commande WhatsApp avec livraison en 2 h (anti-douleur transport), **rappel automatique** au bout de 25 jours (anti-douleur rupture), **paiement Mobile Money à la livraison** (créateur de gain), abonnement mensuel avec bouteille de secours.' },
            { t: 'action', x: 'Remplissez le canvas pour votre produit principal. Chaque douleur a-t-elle une réponse ?' }
          ]
        },
        {
          title: 'Tester vite : le MVP terrain',
          blocks: [
            { t: 'p', x: 'Avant d’investir des millions, testez votre idée avec un **MVP** (*Minimum Viable Product*), la version la plus simple qui permet d’apprendre si les clients sont prêts à payer.' },
            { t: 'flow', caption: 'La boucle Construire → Mesurer → Apprendre', items: ['Hypothèse', 'MVP simple', 'Test auprès de 20-50 clients', 'Mesure', 'Décision : continuer, ajuster ou arrêter'] },
            { t: 'table', caption: 'Exemples de MVP à faible coût', head: ['Idée', 'MVP', 'Coût', 'Indicateur de succès'], rows: [
              ['Livraison de gaz', 'Numéro WhatsApp + 1 moto, sur 1 quartier', '< 150 000 FCFA', '30 commandes en 2 semaines'],
              ['Nouvelle boisson', '200 bouteilles dans 10 boutiques', '< 300 000 FCFA', 'Taux de réachat > 30 %'],
              ['Formation en ligne', 'Page de pré-inscription + 1 webinaire', '< 50 000 FCFA', '100 inscrits, 10 prépaiements']
            ]},
            { t: 'tip', x: 'Le meilleur test n’est pas « Aimez-vous l’idée ? » mais « **Êtes-vous prêt à payer maintenant ?** ».' }
          ]
        }
      ],
      takeaways: ['Innovation incrémentale, de rupture ou frugale.', 'Le Value Proposition Canvas relie douleurs et gains du client à votre offre.', 'Tester avec un MVP avant d’investir. Le vrai signal, c’est le paiement.'],
      quiz: [
        { q: 'Vendre de l’huile en petits sachets est une innovation…', options: ['De rupture', 'Incrémentale', 'Technologique', 'Industrielle'], a: 1, why: 'On adapte le format d’un produit existant aux budgets des clients.' },
        { q: 'Dans la matrice d’Ansoff, vendre un nouveau produit à un nouveau marché s’appelle…', options: ['Pénétration', 'Diversification', 'Développement de marché', 'Fidélisation'], a: 1, why: 'La diversification est la stratégie la plus risquée.' },
        { q: 'Dans le Value Proposition Canvas, « la panne de gaz en pleine cuisson » est…', options: ['Une tâche', 'Un gain', 'Une douleur', 'Un produit'], a: 2, why: 'C’est un problème que le client veut éviter.' },
        { q: 'Que signifie MVP ?', options: ['Most Valuable Player', 'Minimum Viable Product', 'Marketing Vente Performance', 'Modèle de Valeur Premium'], a: 1, why: 'C’est la version minimale qui permet d’apprendre.' },
        { q: 'Quel est le meilleur signal de validation d’une idée ?', options: ['Les likes sur Facebook', 'Les compliments de la famille', 'Des clients qui paient', 'Un beau logo'], a: 2, why: 'Seul le paiement prouve la valeur perçue.' },
        { q: 'Le Mobile Money est un exemple d’innovation…', options: ['De rupture', 'Incrémentale', 'Cosmétique', 'Sans impact'], a: 0, why: 'Il a changé les règles d’accès aux services financiers.' }
      ]
    },

    /* =====================================================================
     *  PARCOURS 1 — COMMERCIAL
     * ===================================================================*/

    C1: {
      title: 'Découverte client et art du questionnement', status: 'complet', duration: '60 min',
      summary: 'Conduire un entretien de découverte structuré avec la méthode SPIN, l’écoute active et la reformulation.',
      objectives: [
        'Préparer un entretien de découverte',
        'Utiliser les 4 types de questions SPIN',
        'Reformuler et valider les besoins du client'
      ],
      skills: ['Méthode SPIN', 'Écoute active', 'Reformulation'],
      video: {
        title: 'Poser les bonnes questions', duration: '6 min', src: null,
        script: [
          'Accroche : « Celui qui pose les questions dirige l’entretien. »',
          'Les questions ouvertes, fermées et de contrôle.',
          'SPIN : Situation, Problème, Implication, Besoin, avec un exemple chez un grossiste.',
          'Jeu de rôle filmé : une reformulation réussie.',
          'Appel à l’action : préparez 8 questions pour votre prochain rendez-vous.'
        ]
      },
      lessons: [
        {
          title: 'Préparer son entretien de découverte',
          blocks: [
            { t: 'p', x: 'Un entretien réussi se gagne **avant** le rendez-vous. Dix minutes de préparation évitent une heure perdue.' },
            { t: 'table', caption: 'Fiche de préparation (à remplir avant chaque visite)', head: ['Rubrique', 'Questions à se poser'], rows: [
              ['Le client', 'Activité, taille, nombre de points de vente, actualité récente ?'],
              ['L’interlocuteur', 'Décideur, prescripteur ou utilisateur ? Ancienneté ?'],
              ['L’historique', 'Déjà client ? Commandes passées ? Litiges ?'],
              ['L’objectif de la visite', 'Que voulez-vous obtenir à la fin (commande, rendez-vous avec le décideur, test) ?'],
              ['Les questions clés', '5 à 8 questions préparées'],
              ['Les supports', 'Catalogue, échantillons, témoignages, tablette']
            ]},
            { t: 'h', x: 'Les types de questions' },
            { t: 'table', head: ['Type', 'Usage', 'Exemple'], rows: [
              ['Ouverte', 'Faire parler, explorer', '« Comment organisez-vous vos achats ? »'],
              ['Fermée', 'Obtenir une précision', '« Commandez-vous chaque semaine ? »'],
              ['Alternative', 'Faire choisir', '« Préférez-vous une livraison le lundi ou le jeudi ? »'],
              ['De contrôle', 'Vérifier la compréhension', '« Si je comprends bien, votre priorité est… ? »']
            ]},
            { t: 'tip', x: 'Fixez toujours un **objectif minimal** et un **objectif idéal** pour chaque visite.' }
          ]
        },
        {
          title: 'La méthode SPIN',
          blocks: [
            { t: 'p', x: 'Développée par Neil Rackham à partir de l’observation de milliers d’entretiens, la méthode **SPIN** est particulièrement efficace pour les ventes de valeur. Elle amène le client à **prendre lui-même conscience** de son besoin.' },
            { t: 'flow', caption: 'Progression SPIN', items: ['Situation', 'Problème', 'Implication', 'Need-payoff (Bénéfice)'] },
            { t: 'table', caption: 'SPIN appliquée : vente d’un service de livraison à un grossiste de Bouaké', head: ['Étape', 'But', 'Exemple de question'], rows: [
              ['**S**ituation', 'Comprendre le contexte (2-3 questions max)', '« Combien de détaillants livrez-vous chaque semaine ? »'],
              ['**P**roblème', 'Faire émerger les difficultés', '« Vous arrive-t-il de rater des livraisons ? »'],
              ['**I**mplication', 'Faire mesurer les conséquences', '« Que se passe-t-il quand un détaillant n’est pas livré à temps ? Combien cela vous coûte-t-il par mois ? »'],
              ['**N**eed-payoff', 'Faire exprimer le bénéfice de la solution', '« Si toutes vos livraisons arrivaient en 24 h, qu’est-ce que cela changerait pour votre chiffre d’affaires ? »']
            ]},
            { t: 'tip', x: 'Ce sont les questions d’**Implication** qui font la différence : le client passe de « c’est un petit souci » à « c’est un vrai problème qui me coûte cher ».' },
            { t: 'action', x: 'Écrivez une question S, P, I et N pour votre produit principal.' }
          ]
        },
        {
          title: 'Écoute active et reformulation',
          blocks: [
            { t: 'steps', items: [
              { title: 'Se taire', x: 'Laisser le client finir, accepter les silences de 2-3 secondes.' },
              { title: 'Montrer qu’on écoute', x: 'Regard, hochements de tête, « je vois », prise de notes.' },
              { title: 'Creuser', x: '« C’est-à-dire ? », « Pouvez-vous me donner un exemple ? »' },
              { title: 'Reformuler', x: 'Redire avec ses mots l’essentiel : « Si je comprends bien, vous… »' },
              { title: 'Faire valider', x: '« C’est bien cela ? Ai-je oublié quelque chose ? »' }
            ]},
            { t: 'case', title: 'Étude de cas : Ibrahim, commercial en matériel agricole à Bobo-Dioulasso',
              context: 'Un producteur de coton dit : « Mes tracteurs tombent souvent en panne pendant la saison, et le mécanicien met une semaine à venir. Cette année, j’ai semé en retard sur 20 hectares. » Ibrahim répond aussitôt : « Notre tracteur est le plus robuste du marché ! »',
              questions: ['Qu’aurait dû faire Ibrahim avant d’argumenter ?', 'Proposez une reformulation et une question d’implication.'],
              solution: 'Ibrahim a argumenté **trop tôt**. Il aurait dû creuser puis reformuler : « Si je comprends bien, le vrai problème n’est pas seulement la panne, c’est **le délai d’intervention**, qui vous a fait semer en retard sur 20 hectares. C’est bien cela ? ». Question d’implication : « Combien ce retard vous a-t-il coûté en rendement ? ». Il aurait découvert que le client a surtout besoin d’un **contrat de maintenance avec intervention en 48 h**, une offre plus rentable que le tracteur seul.' }
          ]
        }
      ],
      takeaways: ['Préparer chaque visite avec un objectif minimal et un objectif idéal.', 'SPIN : Situation, Problème, Implication, Bénéfice.', 'Reformuler et faire valider avant d’argumenter.'],
      quiz: [
        { q: 'Combien de questions de Situation faut-il poser au maximum ?', options: ['Le plus possible', '2 à 3', 'Aucune', '15'], a: 1, why: 'Trop de questions de situation ennuient le client. Préparez-vous en amont.' },
        { q: '« Combien cela vous coûte-t-il par mois ? » est une question…', options: ['De situation', 'De problème', 'D’implication', 'Fermée de conclusion'], a: 2, why: 'Elle fait mesurer les conséquences du problème.' },
        { q: 'Quel est le rôle des questions Need-payoff ?', options: ['Faire exprimer au client le bénéfice de la solution', 'Annoncer le prix', 'Clore l’entretien', 'Parler des concurrents'], a: 0, why: 'Le client verbalise lui-même la valeur.' },
        { q: '« Préférez-vous une livraison lundi ou jeudi ? » est une question…', options: ['Ouverte', 'Alternative', 'D’implication', 'De contrôle'], a: 1, why: 'Elle propose un choix entre deux options.' },
        { q: 'Quelle a été l’erreur d’Ibrahim ?', options: ['Il a posé trop de questions', 'Il a argumenté avant de comprendre le vrai besoin', 'Il a reformulé', 'Il a parlé de maintenance'], a: 1, why: 'Il fallait d’abord creuser et reformuler.' },
        { q: 'Après une reformulation, que faut-il faire ?', options: ['Annoncer le prix', 'Faire valider par le client', 'Partir', 'Changer de sujet'], a: 1, why: 'La validation confirme que l’on a bien compris.' },
        { q: 'Pourquoi fixer un objectif minimal pour une visite ?', options: ['Pour avoir une avancée même sans commande', 'Pour vendre moins', 'Pour raccourcir la visite', 'Ce n’est pas utile'], a: 0, why: 'Chaque visite doit faire avancer le cycle de vente.' }
      ]
    },

    C2: { title: 'Argumentation et traitement des objections', status: 'bientot', duration: '60 min',
      summary: 'Construire des arguments CAP (Caractéristique, Avantage, Preuve) et répondre aux objections avec la méthode ACRA.',
      objectives: ['Transformer une caractéristique en bénéfice client', 'Classer les objections (vraies, fausses, prétextes)', 'Appliquer la méthode ACRA'],
      lessons: [{ title: 'L’argumentation CAP/BAC' }, { title: 'Les familles d’objections' }, { title: 'La méthode ACRA : Accueillir, Creuser, Répondre, Avancer' }, { title: 'Étude de cas : « C’est trop cher » chez un quincaillier de Bamako' }] },
    C3: { title: 'Négociation et closing', status: 'bientot', duration: '60 min',
      summary: 'Défendre son prix, faire des concessions intelligentes et conclure la vente.',
      objectives: ['Préparer une négociation (marge de manœuvre, point de rupture)', 'Échanger des concessions plutôt que les donner', 'Repérer les signaux d’achat et conclure'],
      lessons: [{ title: 'Préparer sa négociation : la grille des concessions' }, { title: 'Défendre son prix face aux acheteurs' }, { title: 'Les 7 techniques de conclusion' }, { title: 'Étude de cas : appel d’offres d’une société minière' }] },
    C4: { title: 'Fidélisation, suivi client et CRM simple', status: 'bientot', duration: '50 min',
      summary: 'Faire revenir ses clients, obtenir des recommandations et suivre son portefeuille avec un CRM simple (Excel, Google Sheets, HubSpot gratuit).',
      objectives: ['Mettre en place un plan de suivi après-vente', 'Mesurer la satisfaction', 'Tenir un CRM à jour'],
      lessons: [{ title: 'Pourquoi fidéliser coûte moins cher que conquérir' }, { title: 'Le plan de contact client' }, { title: 'Monter son CRM en 1 heure' }, { title: 'Obtenir des recommandations' }] },
    C5: { title: 'Organisation, tournées et gestion du temps', status: 'bientot', duration: '45 min',
      summary: 'Optimiser ses tournées terrain, prioriser ses clients et atteindre ses objectifs.',
      objectives: ['Planifier une tournée par zone', 'Prioriser avec la matrice d’Eisenhower', 'Suivre ses indicateurs personnels'],
      lessons: [{ title: 'Sectoriser et planifier sa tournée' }, { title: 'Matrice d’Eisenhower du commercial' }, { title: 'Mes indicateurs : visites, taux de transformation, panier moyen' }] },

    /* =====================================================================
     *  PARCOURS 2 — CHEF D’ÉQUIPE COMMERCIAL
     * ===================================================================*/

    E1: {
      title: 'De vendeur à manager : réussir sa prise de poste', status: 'complet', duration: '60 min',
      summary: 'Comprendre le changement de rôle, adapter son style de management à chaque collaborateur et réussir ses 90 premiers jours.',
      objectives: [
        'Identifier les pièges du passage de vendeur à manager',
        'Appliquer le management situationnel',
        'Construire son plan des 90 premiers jours'
      ],
      skills: ['Posture managériale', 'Management situationnel', 'Plan 90 jours'],
      video: {
        title: 'Hier collègue, aujourd’hui manager', duration: '6 min', src: null,
        script: [
          'Accroche : « Le meilleur vendeur ne fait pas toujours le meilleur manager. Pourquoi ? »',
          'Les 3 pièges : le super-vendeur, le copain, le petit chef.',
          'Le management situationnel en 4 styles, avec la matrice à l’écran.',
          'Le plan des 90 jours : écouter, décider, accélérer.',
          'Appel à l’action : faites le diagnostic de votre équipe.'
        ]
      },
      lessons: [
        {
          title: 'Le changement de rôle et ses pièges',
          blocks: [
            { t: 'p', x: 'Devenir chef d’équipe, c’est passer de « **je fais** » à « **je fais faire** ». Votre réussite ne se mesure plus à vos ventes, mais à celles de votre équipe.' },
            { t: 'table', caption: 'Ce qui change', head: ['', 'Commercial', 'Chef d’équipe'], rows: [
              ['Mission', 'Atteindre son objectif', 'Faire atteindre l’objectif collectif'],
              ['Temps', 'Chez les clients', '50 % terrain avec l’équipe, 30 % animation, 20 % pilotage'],
              ['Source de satisfaction', 'Signer un contrat', 'Voir un collaborateur progresser'],
              ['Relation aux collègues', 'Pairs', 'Responsable de leur performance']
            ]},
            { t: 'table', caption: 'Les 3 pièges classiques', head: ['Piège', 'Symptôme', 'Antidote'], rows: [
              ['Le super-vendeur', 'Il reprend les clients de ses vendeurs pour « sauver » les ventes', 'Accompagner sans faire à la place'],
              ['Le copain', 'Il n’ose pas recadrer ses anciens collègues', 'Poser des règles claires dès le 1er jour'],
              ['Le petit chef', 'Il contrôle tout et donne des ordres', 'Expliquer le pourquoi, déléguer']
            ]},
            { t: 'action', x: 'Lequel de ces 3 pièges vous guette le plus ? Pourquoi ?' }
          ]
        },
        {
          title: 'Le management situationnel',
          blocks: [
            { t: 'p', x: 'Selon le modèle de Hersey et Blanchard, il n’existe pas de « bon » style de management universel. Le bon style dépend de **l’autonomie** du collaborateur, c’est-à-dire de sa **compétence** et de sa **motivation** sur une tâche donnée.' },
            { t: 'matrix', caption: 'Les 4 styles de management', x: 'Comportement relationnel (soutien) →', y: 'Comportement directif (consignes) ↑', q: [
              { title: 'S1 — Diriger', x: 'Débutant motivé : consignes précises, contrôle fréquent' },
              { title: 'S2 — Persuader', x: 'Débutant découragé : expliquer, encourager, former' },
              { title: 'S4 — Déléguer', x: 'Expert motivé : fixer l’objectif, laisser faire' },
              { title: 'S3 — Participer', x: 'Compétent mais hésitant : écouter, impliquer, valoriser' }
            ]},
            { t: 'table', caption: 'Exemple : équipe de 5 commerciaux d’une brasserie à Abidjan', head: ['Commercial', 'Situation', 'Style adapté'], rows: [
              ['Aya, 2 mois', 'Enthousiaste, ne connaît pas encore les points de vente', 'S1 — Diriger'],
              ['Serge, 8 mois', 'Résultats en baisse, se décourage', 'S2 — Persuader'],
              ['Fatou, 3 ans', 'Très bonne, mais doute sur les grands comptes', 'S3 — Participer'],
              ['Yao, 7 ans', 'Meilleur vendeur, autonome', 'S4 — Déléguer']
            ]},
            { t: 'tip', x: 'Le style s’adapte **à la tâche** : Yao peut être en S4 sur la vente, mais en S1 sur le nouveau CRM.' }
          ]
        },
        {
          title: 'Votre plan des 90 premiers jours',
          blocks: [
            { t: 'flow', caption: 'Les 3 phases', items: ['J1-J30 : Écouter et comprendre', 'J31-J60 : Décider et organiser', 'J61-J90 : Accélérer et mesurer'] },
            { t: 'table', head: ['Phase', 'Actions clés', 'Livrable'], rows: [
              ['J1-J30', 'Entretien individuel avec chaque vendeur, accompagnement terrain d’une journée chacun, analyse des chiffres', 'Diagnostic de l’équipe (forces, faiblesses, style requis)'],
              ['J31-J60', 'Réunion de lancement, règles de fonctionnement, objectifs individuels, rituels (brief, point hebdo)', 'Charte d’équipe + objectifs signés'],
              ['J61-J90', 'Coaching ciblé, premiers succès célébrés, ajustements', 'Tableau de bord + bilan des 90 jours avec la hiérarchie']
            ]},
            { t: 'case', title: 'Étude de cas : Mariam, nouvelle chef d’équipe dans une banque à Dakar',
              context: 'Mariam est promue cheffe d’une équipe de 6 conseillers, dont deux anciens collègues plus âgés qu’elle. Dès la première semaine, elle change les horaires et impose un nouveau reporting. L’un des anciens dit en réunion : « Elle se croit tout permis maintenant. »',
              questions: ['Quelle phase Mariam a-t-elle sautée ?', 'Que lui conseillez-vous pour rétablir la situation ?'],
              solution: 'Mariam a sauté la phase **Écouter et comprendre** et imposé des changements sans les expliquer, ce qui active le piège du **petit chef**. Conseils : 1) rencontrer en **entretien individuel** chaque conseiller, à commencer par les deux anciens, en leur demandant leur avis ; 2) **expliquer le pourquoi** du reporting ; 3) leur confier un rôle valorisant (référent, tuteur d’un nouveau), soit un style **S3/S4** adapté à leur expertise ; 4) co-construire la charte d’équipe.' }
          ]
        }
      ],
      takeaways: ['Passer de « je fais » à « je fais faire ».', 'Éviter les pièges du super-vendeur, du copain et du petit chef.', 'Adapter son style (S1 à S4) à l’autonomie de chacun, tâche par tâche.', '90 jours : écouter, décider, accélérer.'],
      quiz: [
        { q: 'Comment se mesure la réussite d’un chef d’équipe commercial ?', options: ['À ses ventes personnelles', 'Aux résultats et à la progression de son équipe', 'Au nombre de réunions', 'À son ancienneté'], a: 1, why: 'Son rôle est de faire réussir les autres.' },
        { q: 'Un manager reprend les gros clients de ses vendeurs pour sauver le mois. C’est le piège…', options: ['Du copain', 'Du petit chef', 'Du super-vendeur', 'Du délégateur'], a: 2, why: 'Il fait à la place au lieu d’accompagner.' },
        { q: 'Quel style pour un nouveau commercial enthousiaste mais inexpérimenté ?', options: ['S1 — Diriger', 'S3 — Participer', 'S4 — Déléguer', 'Aucun suivi'], a: 0, why: 'Il a besoin de consignes claires et de contrôle.' },
        { q: 'Quel style pour un expert motivé et autonome ?', options: ['S1 — Diriger', 'S2 — Persuader', 'S4 — Déléguer', 'Contrôle quotidien'], a: 2, why: 'On fixe l’objectif et on fait confiance.' },
        { q: 'Le style de management dépend…', options: ['Uniquement de la personnalité du manager', 'De l’autonomie du collaborateur sur une tâche donnée', 'Du salaire', 'De l’âge du collaborateur'], a: 1, why: 'Compétence et motivation varient selon les tâches.' },
        { q: 'Que faire en priorité durant les 30 premiers jours ?', options: ['Changer toutes les règles', 'Écouter, rencontrer chacun, analyser', 'Licencier les moins bons', 'Ne rien faire'], a: 1, why: 'Comprendre avant de décider.' },
        { q: 'Quelle était l’erreur principale de Mariam ?', options: ['Organiser des entretiens individuels', 'Imposer des changements sans écouter ni expliquer', 'Valoriser les anciens', 'Créer une charte d’équipe'], a: 1, why: 'Elle a sauté la phase d’écoute.' }
      ]
    },

    E2: { title: 'Animer et motiver son équipe', status: 'bientot', duration: '55 min',
      summary: 'Conduire des briefs efficaces, lancer des challenges commerciaux et maintenir la motivation durablement.',
      objectives: ['Animer un brief matinal de 15 minutes', 'Concevoir un challenge commercial', 'Comprendre les leviers de motivation'],
      lessons: [{ title: 'Les rituels d’équipe : brief, point hebdo, revue mensuelle' }, { title: 'Les leviers de motivation (Herzberg, reconnaissance)' }, { title: 'Concevoir un challenge qui fonctionne' }, { title: 'Gérer un collaborateur démotivé' }] },
    E3: { title: 'Coaching terrain et accompagnement', status: 'bientot', duration: '60 min',
      summary: 'Accompagner ses commerciaux en clientèle, débriefer et faire progresser chacun.',
      objectives: ['Préparer une journée d’accompagnement', 'Observer avec une grille d’évaluation', 'Débriefer avec la méthode du feedback constructif'],
      lessons: [{ title: 'La journée d’accompagnement terrain' }, { title: 'Grille d’observation de l’entretien de vente' }, { title: 'Le feedback : méthode DESC' }, { title: 'Le plan de progrès individuel' }] },
    E4: { title: 'Piloter les objectifs et les KPI d’équipe', status: 'bientot', duration: '55 min',
      summary: 'Fixer des objectifs SMART, suivre les indicateurs clés et réagir vite aux écarts.',
      objectives: ['Décliner un objectif collectif en objectifs individuels', 'Construire un tableau de bord d’équipe', 'Analyser les écarts et décider'],
      lessons: [{ title: 'Objectifs SMART et répartition' }, { title: 'Les 8 KPI d’une équipe commerciale' }, { title: 'Tableau de bord sur Google Sheets' }, { title: 'Revue de performance mensuelle' }] },

    /* =====================================================================
     *  PARCOURS 3 — RESPONSABLE COMMERCIAL
     * ===================================================================*/

    R1: {
      title: 'Construire son plan d’action commercial (PAC)', status: 'complet', duration: '70 min',
      summary: 'Partir du diagnostic (SWOT), fixer des objectifs, choisir ses cibles et bâtir un plan d’actions chiffré et suivi.',
      objectives: [
        'Réaliser un diagnostic commercial avec le SWOT',
        'Fixer des objectifs chiffrés par segment',
        'Construire un PAC avec actions, responsables, budget et indicateurs'
      ],
      skills: ['Diagnostic SWOT', 'Plan d’action commercial', 'Pilotage par objectifs'],
      video: {
        title: 'Le PAC en 6 étapes', duration: '6 min', src: null,
        script: [
          'Accroche : « Sans plan, un objectif n’est qu’un souhait. »',
          'Les 6 étapes du PAC, avec un schéma à l’écran.',
          'Un SWOT rempli en direct pour une PME de matériaux à Yaoundé.',
          'Le tableau du PAC : qui, quoi, quand, combien.',
          'Appel à l’action : téléchargez le gabarit et remplissez-le.'
        ]
      },
      lessons: [
        {
          title: 'Diagnostic : d’où partons-nous ?',
          blocks: [
            { t: 'p', x: 'Le **plan d’action commercial (PAC)** traduit la stratégie de l’entreprise en actions concrètes sur 6 à 12 mois. Il commence toujours par un diagnostic honnête.' },
            { t: 'flow', caption: 'Les 6 étapes du PAC', items: ['1. Diagnostic', '2. Objectifs', '3. Cibles', '4. Actions', '5. Budget & moyens', '6. Suivi'] },
            { t: 'matrix', caption: 'SWOT : Cimat Matériaux, PME de matériaux de construction à Yaoundé', x: 'Interne ← → Externe', y: 'Positif ↑ / Négatif ↓', q: [
              { title: 'Forces', x: 'Stock large, relation ancienne avec les maçons, emplacement central' },
              { title: 'Opportunités', x: 'Boom des constructions en périphérie, programmes de logements sociaux, Mobile Money' },
              { title: 'Faiblesses', x: 'Pas de livraison, aucune présence digitale, dépendance à 3 gros clients (45 % du CA)' },
              { title: 'Menaces', x: 'Arrivée d’un concurrent avec livraison gratuite, hausse du prix du ciment importé' }
            ]},
            { t: 'table', caption: 'Indicateurs du diagnostic', head: ['Indicateur', 'Question', 'Exemple Cimat'], rows: [
              ['CA par segment', 'Qui achète quoi ?', 'Entreprises BTP 55 %, maçons 30 %, particuliers 15 %'],
              ['Évolution', 'Croissance ou recul ?', '−8 % sur les particuliers'],
              ['Concentration', 'Dépendance aux gros clients ?', '3 clients = 45 % du CA (risque)'],
              ['Taux de transformation', 'Devis → commandes ?', '22 %']
            ]},
            { t: 'action', x: 'Réalisez le SWOT de votre zone ou de votre entreprise (3 éléments par case au minimum).' }
          ]
        },
        {
          title: 'Objectifs et cibles',
          blocks: [
            { t: 'p', x: 'Le diagnostic permet de fixer des **objectifs SMART** (Spécifiques, Mesurables, Atteignables, Réalistes, Temporels) et de choisir où concentrer les efforts.' },
            { t: 'table', caption: 'Objectifs SMART du PAC Cimat (12 mois)', head: ['Axe', 'Objectif', 'Indicateur'], rows: [
              ['Croissance', 'Passer de 900 M à 1,08 Md FCFA de CA (+20 %)', 'CA mensuel cumulé'],
              ['Diversification', 'Ramener la part des 3 premiers clients de 45 % à 30 %', 'Part des 3 premiers dans le CA'],
              ['Conquête', 'Gagner 150 nouveaux maçons et petits entrepreneurs', 'Nombre de comptes actifs'],
              ['Digital', 'Réaliser 10 % du CA via WhatsApp et la livraison', 'CA commandé à distance']
            ]},
            { t: 'matrix', caption: 'Matrice attractivité / position : quels segments prioriser ?', x: 'Notre position concurrentielle →', y: 'Attractivité du segment ↑', q: [
              { title: 'Développer sélectivement', x: 'Promoteurs immobiliers : marché attractif, nous sommes faibles' },
              { title: 'Investir en priorité', x: 'Maçons et petits entrepreneurs de périphérie' },
              { title: 'Abandonner ou minimiser', x: 'Ventes ponctuelles très éloignées' },
              { title: 'Maintenir et rentabiliser', x: 'Grandes entreprises BTP actuelles' }
            ]}
          ]
        },
        {
          title: 'Le plan d’actions et son suivi',
          blocks: [
            { t: 'table', caption: 'Extrait du PAC Cimat', head: ['Action', 'Cible', 'Responsable', 'Échéance', 'Budget (FCFA)', 'Indicateur'], rows: [
              ['Lancer un service de livraison (2 tricycles)', 'Maçons de périphérie', 'Resp. logistique', 'M2', '4 500 000', 'Commandes livrées/mois'],
              ['Programme de fidélité maçons (points → outils)', 'Maçons', 'Resp. commercial', 'M1', '1 200 000', 'Comptes actifs'],
              ['Catalogue WhatsApp + 1 statut par jour', 'Tous', 'Assistante commerciale', 'M1', '150 000', 'CA WhatsApp'],
              ['Prospection de 40 promoteurs immobiliers', 'Promoteurs', '2 commerciaux', 'M3-M6', '800 000', 'Devis / signatures'],
              ['Journée portes ouvertes « Bâtir malin »', 'Particuliers', 'Marketing', 'M4', '1 000 000', 'Participants / ventes du jour']
            ]},
            { t: 'steps', items: [
              { title: 'Hebdomadaire', x: 'Point d’équipe : actions réalisées, résultats et blocages.' },
              { title: 'Mensuel', x: 'Revue du tableau de bord : réalisé et objectif, écarts, actions correctives.' },
              { title: 'Trimestriel', x: 'Révision du PAC avec la direction : maintenir, ajuster ou arrêter certaines actions.' }
            ]},
            { t: 'case', title: 'Étude de cas : le PAC qui dort dans un tiroir',
              context: 'Un responsable commercial d’un distributeur pharmaceutique à Libreville a présenté un PAC de 40 pages très apprécié. Six mois plus tard, seule 1 action sur 12 a été lancée et les ventes stagnent.',
              questions: ['Quelles sont les causes probables ?', 'Quelles 3 mesures recommandez-vous ?'],
              solution: 'Causes probables : **aucun responsable nommé** par action, **pas d’échéances** claires, **pas de rituel de suivi**, un plan trop long et **trop d’actions à la fois**. Mesures : 1) réduire à **5 actions prioritaires** sur une page ; 2) un **responsable et une date** pour chacune ; 3) une **revue mensuelle de 30 minutes** avec un tableau de bord rouge, orange ou vert.' },
            { t: 'tip', x: 'Un bon PAC tient sur **une page** et chaque action a **un nom, une date et un chiffre**.' }
          ]
        }
      ],
      takeaways: ['PAC = Diagnostic, Objectifs, Cibles, Actions, Budget, Suivi.', 'SWOT : interne (forces, faiblesses), externe (opportunités, menaces).', 'Objectifs SMART, segments priorisés avec la matrice attractivité / position.', 'Chaque action a un responsable, une échéance, un budget et un indicateur.'],
      quiz: [
        { q: 'Dans un SWOT, « l’arrivée d’un concurrent » est…', options: ['Une faiblesse', 'Une menace', 'Une force', 'Une opportunité'], a: 1, why: 'C’est un facteur externe négatif.' },
        { q: 'Dans un SWOT, « pas de service de livraison » est…', options: ['Une menace', 'Une faiblesse', 'Une opportunité', 'Une force'], a: 1, why: 'C’est un facteur interne négatif.' },
        { q: 'Que signifie le « M » de SMART ?', options: ['Motivant', 'Mesurable', 'Marketing', 'Mensuel'], a: 1, why: 'Un objectif doit pouvoir être mesuré.' },
        { q: 'Un segment attractif où l’entreprise est bien placée doit être…', options: ['Abandonné', 'Investi en priorité', 'Ignoré', 'Maintenu sans effort'], a: 1, why: 'C’est là que le retour sur investissement est le plus fort.' },
        { q: 'Quels éléments chaque action d’un PAC doit-elle comporter ?', options: ['Un slogan', 'Un responsable, une échéance, un budget, un indicateur', 'Une photo', 'Uniquement un budget'], a: 1, why: 'Sans eux, l’action n’est pas pilotable.' },
        { q: 'Pourquoi le PAC de Libreville a-t-il échoué ?', options: ['Trop court', 'Pas de responsables, pas d’échéances, pas de suivi', 'Trop peu d’actions', 'Trop de budget'], a: 1, why: 'Un plan sans pilotage reste théorique.' },
        { q: 'À quelle fréquence réviser le PAC avec la direction ?', options: ['Jamais', 'Chaque trimestre', 'Tous les 5 ans', 'Chaque jour'], a: 1, why: 'Le trimestre laisse le temps de mesurer tout en restant réactif.' },
        { q: 'Dépendre de 3 clients pour 45 % du CA représente…', options: ['Une force', 'Un risque de concentration', 'Une opportunité', 'Une situation idéale'], a: 1, why: 'La perte d’un seul client fragiliserait l’entreprise.' }
      ]
    },

    R2: { title: 'Segmentation et gestion du portefeuille clients', status: 'bientot', duration: '60 min',
      summary: 'Classer ses clients (ABC/Pareto), définir un niveau de service par segment et augmenter la valeur du portefeuille.',
      objectives: ['Réaliser une analyse ABC', 'Construire une matrice valeur / potentiel', 'Définir la fréquence de visite par segment'],
      lessons: [{ title: 'La loi de Pareto et l’analyse ABC' }, { title: 'Matrice valeur actuelle / potentiel' }, { title: 'Politique de service par segment' }, { title: 'Étude de cas : distributeur FMCG à Cotonou' }] },
    R3: { title: 'Canaux de vente et distribution', status: 'bientot', duration: '60 min',
      summary: 'Piloter grossistes, semi-grossistes, détaillants et canaux digitaux, et éviter les conflits de canaux.',
      objectives: ['Cartographier ses canaux de distribution', 'Calculer la rentabilité par canal', 'Définir une politique tarifaire par canal'],
      lessons: [{ title: 'Les circuits de distribution en Afrique (formel et informel)' }, { title: 'Rentabilité et coût par canal' }, { title: 'Gérer les conflits de canaux' }, { title: 'Intégrer le e-commerce et le social commerce' }] },
    R4: { title: 'Prévisions et budget des ventes', status: 'bientot', duration: '55 min',
      summary: 'Prévoir ses ventes, construire un budget commercial et suivre la rentabilité de sa zone.',
      objectives: ['Réaliser une prévision des ventes (historique, saisonnalité)', 'Construire un budget commercial', 'Suivre marge et rentabilité'],
      lessons: [{ title: 'Méthodes de prévision simples' }, { title: 'Saisonnalité : Ramadan, Tabaski, fêtes, rentrée' }, { title: 'Le budget commercial' }, { title: 'Marge, remise et rentabilité' }] },
    R5: { title: 'Recruter et intégrer ses commerciaux', status: 'bientot', duration: '50 min',
      summary: 'Définir le profil, mener un entretien de recrutement commercial et réussir l’intégration.',
      objectives: ['Rédiger une fiche de poste et un profil', 'Conduire un entretien avec mise en situation', 'Construire un parcours d’intégration de 30 jours'],
      lessons: [{ title: 'Le profil du commercial performant' }, { title: 'L’entretien et le jeu de rôle' }, { title: 'Le parcours d’intégration' }] },

    /* =====================================================================
     *  PARCOURS 4 — DIRECTEUR COMMERCIAL
     * ===================================================================*/

    D1: {
      title: 'Stratégie commerciale et marketing d’innovation', status: 'complet', duration: '75 min',
      summary: 'Analyser son environnement, choisir ses axes de croissance (Ansoff, BCG, Océan bleu) et piloter l’innovation au service de la croissance.',
      objectives: [
        'Analyser son marché avec PESTEL et les 5 forces de Porter',
        'Arbitrer son portefeuille avec la matrice BCG',
        'Construire une stratégie Océan bleu avec la grille ERAC'
      ],
      skills: ['Analyse stratégique (PESTEL, Porter)', 'Matrice BCG', 'Stratégie Océan bleu'],
      video: {
        title: 'Penser la stratégie comme un directeur', duration: '6 min', src: null,
        script: [
          'Accroche : « La stratégie, c’est choisir ce que l’on ne fera pas. »',
          'PESTEL et Porter, appliqués à la téléphonie mobile en Afrique de l’Ouest.',
          'La matrice BCG : où investir, où récolter.',
          'L’Océan bleu et la grille ERAC, avec l’exemple de Wave.',
          'Appel à l’action : faites la grille ERAC de votre entreprise.'
        ]
      },
      lessons: [
        {
          title: 'Analyser l’environnement : PESTEL et Porter',
          blocks: [
            { t: 'p', x: 'Le directeur commercial doit voir **plus loin que les ventes du mois**. Deux outils structurent l’analyse : le **PESTEL** pour le macro-environnement et les **5 forces de Porter** pour l’intensité concurrentielle.' },
            { t: 'table', caption: 'PESTEL : marché des produits laitiers en Côte d’Ivoire (illustratif)', head: ['Facteur', 'Exemple', 'Impact commercial'], rows: [
              ['**P**olitique', 'Politiques de soutien à la production locale', 'Avantage aux marques produisant localement'],
              ['**É**conomique', 'Inflation sur les produits importés, pouvoir d’achat sous pression', 'Petits formats, prix psychologiques'],
              ['**S**ocioculturel', 'Urbanisation, jeunesse, montée de la classe moyenne', 'Produits pratiques, marketing digital'],
              ['**T**echnologique', 'Mobile Money, e-commerce, chaîne du froid', 'Ventes à distance, nouveaux canaux'],
              ['**E**nvironnemental', 'Interdiction de certains plastiques', 'Repenser les emballages'],
              ['**L**égal', 'Normes d’étiquetage, réglementation des prix', 'Conformité des emballages et de la communication']
            ]},
            { t: 'table', caption: 'Les 5 forces de Porter', head: ['Force', 'Question clé', 'Signal d’alerte'], rows: [
              ['Rivalité entre concurrents', 'Combien d’acteurs, quelle guerre des prix ?', 'Baisse continue des marges'],
              ['Nouveaux entrants', 'Est-il facile d’entrer sur le marché ?', 'Arrivée de marques importées à bas prix'],
              ['Produits de substitution', 'Quoi d’autre répond au même besoin ?', 'Lait en poudre au lieu de lait frais'],
              ['Pouvoir des clients', 'Les distributeurs imposent-ils leurs conditions ?', 'Exigences de délais de paiement'],
              ['Pouvoir des fournisseurs', 'Dépend-on de quelques fournisseurs ?', 'Hausse des intrants imposée']
            ]}
          ]
        },
        {
          title: 'Arbitrer son portefeuille : la matrice BCG',
          blocks: [
            { t: 'p', x: 'La matrice du **Boston Consulting Group** classe les produits selon la **croissance du marché** et la **part de marché relative**. Elle guide l’allocation des ressources commerciales.' },
            { t: 'matrix', caption: 'Matrice BCG : opérateur télécoms (illustratif)', x: 'Part de marché relative : forte ← → faible', y: 'Croissance du marché ↑', q: [
              { title: '⭐ Vedettes', x: 'Data mobile 4G/5G : investir pour garder le leadership' },
              { title: '❓ Dilemmes', x: 'Fibre résidentielle : investir massivement ou abandonner' },
              { title: '🐄 Vaches à lait', x: 'Voix et SMS : rentabiliser, financer les autres activités' },
              { title: '🐕 Poids morts', x: 'Cartes de recharge papier : réduire, migrer vers le digital' }
            ]},
            { t: 'table', caption: 'Traduction commerciale', head: ['Case', 'Priorité de la force de vente', 'Politique de prix'], rows: [
              ['Vedettes', 'Ressources maximales, conquête', 'Prix de marché, valeur'],
              ['Dilemmes', 'Équipe dédiée, tests ciblés', 'Prix de pénétration'],
              ['Vaches à lait', 'Fidélisation, productivité', 'Maintien des marges'],
              ['Poids morts', 'Effort minimal', 'Prix de sortie, déstockage']
            ]},
            { t: 'action', x: 'Placez vos 5 principaux produits ou services dans la matrice BCG.' }
          ]
        },
        {
          title: 'Innover pour sortir de la concurrence : l’Océan bleu',
          blocks: [
            { t: 'p', x: 'Plutôt que de se battre sur un marché saturé (**océan rouge**), la stratégie **Océan bleu** (Kim et Mauborgne) crée un espace de marché nouveau en redéfinissant la proposition de valeur.' },
            { t: 'table', caption: 'La grille ERAC appliquée à Wave (transfert d’argent mobile)', head: ['Action', 'Question', 'Wave'], rows: [
              ['**É**liminer', 'Quels éléments, jugés indispensables par le secteur, supprimer ?', 'Les frais de dépôt et de retrait'],
              ['**R**éduire', 'Que réduire bien en dessous des standards ?', 'Les frais de transfert (environ 1 %)'],
              ['**A**ugmenter', 'Que porter bien au-dessus des standards ?', 'La simplicité de l’application, la densité du réseau d’agents'],
              ['**C**réer', 'Qu’offrir que le secteur n’a jamais proposé ?', 'Une carte QR pour les personnes sans smartphone']
            ]},
            { t: 'case', title: 'Étude de cas : TransLog, transporteur de marchandises à Ouagadougou',
              context: 'TransLog est en guerre des prix avec 30 transporteurs sur l’axe Ouagadougou-Abidjan. Les clients (commerçants) se plaignent surtout de ne jamais savoir où est leur marchandise, des retards non annoncés et des pertes. Les marges ont baissé de 40 % en 3 ans.',
              questions: ['Remplissez une grille ERAC pour TransLog.', 'Quel nouveau segment de clients pourrait-il viser ?'],
              solution: '**Éliminer** : la négociation au cas par cas, remplacée par des tarifs publiés. **Réduire** : les petits envois non rentables, regroupés via des partenaires. **Augmenter** : la fiabilité, avec une garantie de délai et une assurance incluse. **Créer** : le **suivi en temps réel par WhatsApp** (GPS + message automatique à chaque étape) et le **paiement Mobile Money à la livraison**. Nouveau segment : les **e-commerçants et PME importatrices** qui paient pour la fiabilité, pas seulement pour le prix. TransLog sort de la guerre des prix et peut facturer une **prime de 15 à 20 %**.' },
            { t: 'tip', x: 'L’innovation la plus rentable n’est souvent pas technologique : c’est **une nouvelle façon de créer de la valeur** pour un client oublié par le marché.' }
          ]
        }
      ],
      takeaways: ['PESTEL pour le macro-environnement, Porter pour la concurrence.', 'BCG : investir dans les vedettes, rentabiliser les vaches à lait, trancher sur les dilemmes.', 'Océan bleu et grille ERAC : Éliminer, Réduire, Augmenter, Créer.'],
      quiz: [
        { q: 'Dans le PESTEL, le développement du Mobile Money relève du facteur…', options: ['Politique', 'Technologique', 'Légal', 'Environnemental'], a: 1, why: 'C’est une évolution technologique.' },
        { q: 'Le lait en poudre face au lait frais illustre la force de Porter…', options: ['Nouveaux entrants', 'Produits de substitution', 'Pouvoir des fournisseurs', 'Rivalité'], a: 1, why: 'Il répond au même besoin par un autre produit.' },
        { q: 'Dans la matrice BCG, une « vache à lait » a…', options: ['Une forte croissance et une faible part', 'Une faible croissance et une forte part', 'Une forte croissance et une forte part', 'Une faible croissance et une faible part'], a: 1, why: 'Elle génère des liquidités sur un marché mature.' },
        { q: 'Quelle politique pour un « dilemme » ?', options: ['L’ignorer', 'Investir massivement ou abandonner', 'Augmenter fortement ses prix', 'Le transformer en vache à lait immédiatement'], a: 1, why: 'Il faut trancher : il deviendra vedette ou poids mort.' },
        { q: 'Que signifie ERAC ?', options: ['Évaluer, Rentabiliser, Acheter, Contrôler', 'Éliminer, Réduire, Augmenter, Créer', 'Étudier, Rédiger, Animer, Conclure', 'Engager, Recruter, Accompagner, Coacher'], a: 1, why: 'C’est la grille des 4 actions de l’Océan bleu.' },
        { q: 'Un océan rouge est…', options: ['Un marché saturé de concurrents', 'Un marché inexistant', 'Un marché public', 'Un marché en croissance sans concurrents'], a: 0, why: 'La concurrence y fait baisser les marges.' },
        { q: 'Pour TransLog, quelle création de valeur est la plus différenciante ?', options: ['Baisser encore les prix', 'Le suivi en temps réel par WhatsApp et la garantie de délai', 'Plus de camions', 'Changer de logo'], a: 1, why: 'Elle répond à la douleur principale des clients : l’incertitude.' },
        { q: 'Selon la leçon, la stratégie consiste avant tout à…', options: ['Tout faire en même temps', 'Choisir ce que l’on ne fera pas', 'Copier le leader', 'Baisser les prix'], a: 1, why: 'Choisir, c’est renoncer pour concentrer ses ressources.' }
      ]
    },

    D2: { title: 'Organisation de la force de vente et rémunération variable', status: 'bientot', duration: '65 min',
      summary: 'Dimensionner la force de vente, choisir une organisation (géographique, produit, client) et concevoir un plan de rémunération variable motivant et rentable.',
      objectives: ['Calculer la taille optimale de la force de vente', 'Choisir une structure organisationnelle', 'Concevoir un plan de commissionnement'],
      lessons: [{ title: 'Dimensionner la force de vente (méthode de la charge de travail)' }, { title: 'Organisation géographique, produit ou client' }, { title: 'Fixe, variable, primes : construire le plan' }, { title: 'Étude de cas : refonte des commissions dans un groupe d’assurance' }] },
    D3: { title: 'Pricing stratégique', status: 'bientot', duration: '60 min',
      summary: 'Fixer ses prix selon la valeur, gérer les remises et protéger ses marges dans un contexte d’inflation.',
      objectives: ['Distinguer prix coût, prix concurrence et prix valeur', 'Construire une politique de remises', 'Mesurer l’impact d’une remise sur la marge'],
      lessons: [{ title: 'Les 3 logiques de prix' }, { title: 'La politique de remises et la cascade de prix' }, { title: 'Prix psychologiques et petits formats' }, { title: 'Augmenter ses prix sans perdre ses clients' }] },
    D4: { title: 'Grands comptes et vente B2B complexe', status: 'bientot', duration: '60 min',
      summary: 'Piloter les grands comptes, cartographier les décideurs et répondre aux appels d’offres.',
      objectives: ['Cartographier le centre de décision d’un compte', 'Construire un plan de compte', 'Répondre à un appel d’offres public ou privé'],
      lessons: [{ title: 'Le centre de décision : décideurs, prescripteurs, utilisateurs' }, { title: 'Le plan de compte stratégique' }, { title: 'Répondre aux appels d’offres' }, { title: 'Étude de cas : contrat cadre avec une compagnie minière' }] },
    D5: { title: 'Transformation digitale commerciale et données', status: 'bientot', duration: '60 min',
      summary: 'Digitaliser le processus commercial, déployer un CRM, utiliser la donnée et l’IA pour mieux vendre.',
      objectives: ['Construire une feuille de route digitale commerciale', 'Choisir et déployer un CRM', 'Piloter par la donnée'],
      lessons: [{ title: 'Les étapes de la digitalisation commerciale' }, { title: 'Choisir et réussir son CRM' }, { title: 'Données, tableaux de bord et IA générative' }, { title: 'Conduire le changement auprès des équipes terrain' }] },
    D6: { title: 'Leadership et gouvernance commerciale', status: 'bientot', duration: '55 min',
      summary: 'Incarner la vision, piloter le comité commercial et aligner ventes, marketing et finance.',
      objectives: ['Formuler et partager une vision commerciale', 'Animer un comité de direction commerciale', 'Aligner ventes, marketing et finance'],
      lessons: [{ title: 'Le leadership du directeur commercial' }, { title: 'Comité commercial et rituels de gouvernance' }, { title: 'Alignement ventes-marketing (smarketing)' }, { title: 'Éthique commerciale et conformité' }] }
  }
};
