// Module F3 — Initiation au marketing d’innovation
module.exports = {
  "id": "F3",
  "title": "Initiation au marketing d’innovation",
  "status": "complet",
  "duration": "50 min",
  "summary": "Comprendre l’innovation frugale africaine, construire une proposition de valeur avec le Value Proposition Canvas et tester une idée vite et à moindre coût.",
  "objectives": [
    "Distinguer innovation de rupture, incrémentale et frugale",
    "Remplir un Value Proposition Canvas",
    "Concevoir un test terrain (MVP) en moins de 2 semaines"
  ],
  "skills": [
    "Innovation frugale",
    "Value Proposition Canvas",
    "Test & apprentissage (MVP)"
  ],
  "video": {
    "title": "Innover avec peu de moyens",
    "duration": "6 min",
    "src": null,
    "script": [
      "Accroche : M-Pesa et Wave sont nés de contraintes, pas de gros budgets.",
      "Les 3 types d’innovation, avec un schéma à l’écran.",
      "Le Value Proposition Canvas expliqué sur un exemple de livraison de gaz.",
      "MVP : tester avant d’investir.",
      "Appel à l’action : remplissez votre canvas."
    ]
  },
  "lessons": [
    {
      "title": "Qu’est-ce que le marketing d’innovation ?",
      "blocks": [
        {
          "t": "p",
          "x": "Le marketing d’innovation consiste à **créer de la valeur nouvelle** pour le client : un nouveau produit, un nouveau service, un nouveau modèle de vente ou de paiement. L’Afrique est l’un des laboratoires mondiaux de l’**innovation frugale** : faire mieux avec moins."
        },
        {
          "t": "table",
          "caption": "Trois types d’innovation",
          "head": [
            "Type",
            "Définition",
            "Exemple africain"
          ],
          "rows": [
            [
              "Incrémentale",
              "Améliorer l’existant",
              "Vendre l’huile ou le savon en petits sachets pour les budgets journaliers"
            ],
            [
              "De rupture",
              "Changer les règles du marché",
              "Le Mobile Money (M-Pesa, Orange Money) qui remplace la banque pour des millions de personnes"
            ],
            [
              "Frugale",
              "Solution simple, robuste, abordable",
              "Wave et ses frais de transfert très bas, les kits solaires payables à l’usage (PAYG)"
            ]
          ]
        },
        {
          "t": "matrix",
          "caption": "Matrice d’Ansoff simplifiée : où innover ?",
          "x": "Produit existant → nouveau",
          "y": "Marché nouveau ↑ / existant",
          "q": [
            {
              "title": "Développement de marché",
              "x": "Produit actuel, nouveaux clients ou pays"
            },
            {
              "title": "Diversification",
              "x": "Nouveau produit, nouveau marché (risque élevé)"
            },
            {
              "title": "Pénétration",
              "x": "Vendre plus du même produit aux mêmes clients"
            },
            {
              "title": "Développement de produit",
              "x": "Nouveau produit pour les clients actuels"
            }
          ]
        },
        {
          "t": "tip",
          "x": "Innover, ce n’est pas forcément inventer une technologie. C’est souvent **changer la façon de vendre, d’emballer ou de faire payer**."
        }
      ]
    },
    {
      "title": "Le Value Proposition Canvas",
      "blocks": [
        {
          "t": "p",
          "x": "Le **Value Proposition Canvas** (Strategyzer) vérifie que votre offre répond vraiment à votre client. Il compare deux côtés : le **profil client** et la **carte de valeur**."
        },
        {
          "t": "table",
          "caption": "Les deux côtés du canvas",
          "head": [
            "Profil client",
            "Question",
            "Carte de valeur",
            "Question"
          ],
          "rows": [
            [
              "Tâches",
              "Que cherche-t-il à accomplir ?",
              "Produits et services",
              "Que proposez-vous ?"
            ],
            [
              "Douleurs",
              "Qu’est-ce qui le gêne ou lui fait peur ?",
              "Anti-douleurs",
              "Comment supprimez-vous ces douleurs ?"
            ],
            [
              "Gains",
              "Qu’est-ce qui le rendrait heureux ?",
              "Créateurs de gains",
              "Comment créez-vous ces gains ?"
            ]
          ]
        },
        {
          "t": "case",
          "title": "Étude de cas : GazExpress, livraison de bouteilles de gaz à Douala",
          "context": "Une PME veut lancer la livraison à domicile de bouteilles de gaz. Les ménages se plaignent de ruptures dans les dépôts, de devoir porter la bouteille et de ne pas savoir quand elle sera vide.",
          "questions": [
            "Listez 2 tâches, 3 douleurs et 2 gains du client.",
            "Proposez 3 anti-douleurs ou créateurs de gains."
          ],
          "solution": "**Tâches** : cuisiner tous les jours, remplacer la bouteille vide. **Douleurs** : ruptures en dépôt, transport pénible, panne de gaz en pleine cuisson. **Gains** : ne jamais manquer de gaz, payer en Mobile Money. **Offre** : commande WhatsApp avec livraison en 2 h (anti-douleur transport), **rappel automatique** au bout de 25 jours (anti-douleur rupture), **paiement Mobile Money à la livraison** (créateur de gain), abonnement mensuel avec bouteille de secours."
        },
        {
          "t": "action",
          "x": "Remplissez le canvas pour votre produit principal. Chaque douleur a-t-elle une réponse ?"
        }
      ]
    },
    {
      "title": "Tester vite : le MVP terrain",
      "blocks": [
        {
          "t": "p",
          "x": "Avant d’investir des millions, testez votre idée avec un **MVP** (*Minimum Viable Product*), la version la plus simple qui permet d’apprendre si les clients sont prêts à payer."
        },
        {
          "t": "flow",
          "caption": "La boucle Construire → Mesurer → Apprendre",
          "items": [
            "Hypothèse",
            "MVP simple",
            "Test auprès de 20-50 clients",
            "Mesure",
            "Décision : continuer, ajuster ou arrêter"
          ]
        },
        {
          "t": "table",
          "caption": "Exemples de MVP à faible coût",
          "head": [
            "Idée",
            "MVP",
            "Coût",
            "Indicateur de succès"
          ],
          "rows": [
            [
              "Livraison de gaz",
              "Numéro WhatsApp + 1 moto, sur 1 quartier",
              "< 150 000 FCFA",
              "30 commandes en 2 semaines"
            ],
            [
              "Nouvelle boisson",
              "200 bouteilles dans 10 boutiques",
              "< 300 000 FCFA",
              "Taux de réachat > 30 %"
            ],
            [
              "Formation en ligne",
              "Page de pré-inscription + 1 webinaire",
              "< 50 000 FCFA",
              "100 inscrits, 10 prépaiements"
            ]
          ]
        },
        {
          "t": "tip",
          "x": "Le meilleur test n’est pas « Aimez-vous l’idée ? » mais « **Êtes-vous prêt à payer maintenant ?** »."
        }
      ]
    }
  ],
  "takeaways": [
    "Innovation incrémentale, de rupture ou frugale.",
    "Le Value Proposition Canvas relie douleurs et gains du client à votre offre.",
    "Tester avec un MVP avant d’investir. Le vrai signal, c’est le paiement."
  ],
  "quiz": [
    {
      "q": "Vendre de l’huile en petits sachets est une innovation…",
      "options": [
        "De rupture",
        "Incrémentale",
        "Technologique",
        "Industrielle"
      ],
      "a": 1,
      "why": "On adapte le format d’un produit existant aux budgets des clients."
    },
    {
      "q": "Dans la matrice d’Ansoff, vendre un nouveau produit à un nouveau marché s’appelle…",
      "options": [
        "Pénétration",
        "Diversification",
        "Développement de marché",
        "Fidélisation"
      ],
      "a": 1,
      "why": "La diversification est la stratégie la plus risquée."
    },
    {
      "q": "Dans le Value Proposition Canvas, « la panne de gaz en pleine cuisson » est…",
      "options": [
        "Une tâche",
        "Un gain",
        "Une douleur",
        "Un produit"
      ],
      "a": 2,
      "why": "C’est un problème que le client veut éviter."
    },
    {
      "q": "Que signifie MVP ?",
      "options": [
        "Most Valuable Player",
        "Minimum Viable Product",
        "Marketing Vente Performance",
        "Modèle de Valeur Premium"
      ],
      "a": 1,
      "why": "C’est la version minimale qui permet d’apprendre."
    },
    {
      "q": "Quel est le meilleur signal de validation d’une idée ?",
      "options": [
        "Les likes sur Facebook",
        "Les compliments de la famille",
        "Des clients qui paient",
        "Un beau logo"
      ],
      "a": 2,
      "why": "Seul le paiement prouve la valeur perçue."
    },
    {
      "q": "Le Mobile Money est un exemple d’innovation…",
      "options": [
        "De rupture",
        "Incrémentale",
        "Cosmétique",
        "Sans impact"
      ],
      "a": 0,
      "why": "Il a changé les règles d’accès aux services financiers."
    }
  ],
  "deliverable": {
    "title": "Value Proposition Canvas et plan de test",
    "x": "Le canvas rempli pour une offre réelle ou en projet, et le plan d’un MVP : hypothèse, test, coût, indicateur de succès et date."
  }
};
