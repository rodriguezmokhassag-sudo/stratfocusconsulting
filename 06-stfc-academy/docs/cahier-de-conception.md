# STFC Academy : script de création de la plateforme

> Plateforme SaaS 100 % en ligne de formation aux métiers de la **performance commerciale**, du **marketing** et de l'**innovation**, conçue par StratFocus Consulting (STFC) pour l'**Afrique francophone**.

Ce script fusionne les deux cahiers des charges reçus et décrit la plateforme réellement construite dans [`app/`](../app/). Il suit les 5 étapes demandées :

| Bloc | Contenu |
|---|---|
| 1 | Étude de marché : plateformes, avis, habitudes d'apprentissage, pays prioritaires |
| 2 | Architecture fonctionnelle de la plateforme |
| 3 | Parcours de formation et tarification régionale |
| 4 | Plan de contenu détaillé des 24 modules |
| 5 | Stack technique, déploiement par phases et indicateurs de suivi |

**Positionnement en une phrase :** *la seule plateforme qui fait progresser un professionnel de la vente de Commercial à Directeur commercial, avec des cas africains, sur son téléphone, payable en Mobile Money, et un certificat vérifiable à son nom.*

---

## BLOC 1 : Étude de marché

### 1.1 Comparatif des plateformes payantes

| Plateforme | Modèle économique | Prix indicatif | Public cible | Points forts | Points faibles et avis récurrents |
|---|---|---|---|---|---|
| **Udemy** | Place de marché, achat à l'unité, promotions permanentes ; offre Business par abonnement | 10 à 20 € en promotion par cours | Grand public, autodidactes | Catalogue immense, prix bas | Qualité très inégale selon l'instructeur, contenus parfois obsolètes, notes Trustpilot et BBB faibles |
| **Coursera** | Abonnement (Plus), certificats universitaires, diplômes en ligne | ~50 €/mois, programmes de plusieurs centaines à milliers d'€ | Étudiants, cadres, entreprises | Crédibilité universitaire, certificats reconnus | Facturation et renouvellements surprises, résiliation difficile, catalogue limité sur les compétences spécialisées |
| **LinkedIn Learning** | Abonnement, souvent inclus dans LinkedIn Premium ou les offres entreprise | ~30-40 €/mois | Salariés, cadres | Certificat affiché sur le profil LinkedIn, bon pour l'autoformation | Peu de pratique, vidéos parfois datées |
| **Udacity** | Abonnement « Nanodegree » avec projets et mentorat | ~249 $/mois | Profils tech, reconversion | Projets concrets, relecture par des mentors | Prix très élevé, services de carrière désormais payants en supplément, résiliation des essais compliquée |
| **Simplilearn** | Programmes certifiants, partenariats universitaires | Prix régionalisés, plusieurs centaines à milliers de $ | Cadres, entreprises (marketing digital, gestion de projet) | Cours en direct, certifications | Prix opaques (affichés selon la région), forte pression commerciale |
| **Skillshare** | Abonnement à des cours courts | ~10-15 €/mois | Créatifs | Format court, accessible | Très peu de contenu sur la vente B2B |
| **Kajabi** | Logiciel pour créer sa propre école en ligne (SaaS pour formateurs) | 143 à 399 $/mois | Formateurs, consultants | Tout-en-un : cours, e-mailing, communauté, IA | Très cher pour l'Afrique, pas de Mobile Money, hausse de prix contestée en 2026 |
| **OpenClassrooms** | Parcours diplômants avec mentorat, financements publics en France | Abonnement ou parcours de plusieurs milliers d'€ | Reconversion, étudiants | Logique de parcours métier, diplômes reconnus en France | Mentorat inégal, prix inadaptés à l'Afrique |
| **Cegos / Unow / Coorpacademy** | Licences entreprises | Sur devis | Grandes entreprises | Contenus managériaux solides, gamification (Coorpacademy) | Pensés pour l'Europe, prix en euros |
| **Kajou (Sénégal)** | Contenus hors ligne sur carte microSD | Faible coût | Zones peu connectées | Fonctionne sans internet | Peu axé sur la formation commerciale avancée |
| **Acteurs locaux** (ex. Abidjan) | Formations courtes à l'unité | ~50 000 FCFA pour 10 h | Indépendants, PME | Prix en FCFA, Wave et Orange Money | Catalogues étroits, pas de progression de carrière |

### 1.2 Ce que disent les avis : 10 enseignements traduits en fonctionnalités

| # | Irritant relevé | Réponse STFC Academy (déjà dans la plateforme) |
|---|---|---|
| 1 | Facturation surprise, renouvellement caché | Prix TTC affichés, abonnements **sans renouvellement automatique** |
| 2 | Résiliation difficile | Parcours achetés **à vie**, rien à résilier |
| 3 | Qualité inégale | Un seul éditeur, un gabarit pédagogique unique pour les 24 modules |
| 4 | Contenus datés | Date de mise à jour affichée sur chaque module, édition en ligne par l'équipe |
| 5 | Trop de vidéo, pas assez de pratique | Vidéo résumé courte + leçons, études de cas, exercices « Et vous ? » et un **livrable** par module |
| 6 | Vidéos lourdes, données chères | Vidéo chargée **uniquement à la demande**, cours complet en **PDF**, lecture hors connexion |
| 7 | Isolement, abandon | Tableau de bord, bouton « Reprendre », progression verrouillée étape par étape |
| 8 | Certificat sans valeur | Quiz noté côté serveur, **référence unique vérifiable en ligne**, ajout à LinkedIn |
| 9 | Exemples hors contexte | 24 études de cas situées en Afrique francophone (Abidjan, Dakar, Douala, Kinshasa, Conakry, Bamako…) |
| 10 | Prix inadaptés | **Tarifs régionaux**, Mobile Money, paiement en 3 fois |

### 1.3 Habitudes d'apprentissage des Africains francophones

| Constat | Conséquence pour la plateforme |
|---|---|
| **Le smartphone est le terminal principal.** L'adoption du smartphone en Afrique subsaharienne est estimée à environ 54 % (2024), la plus faible au monde, et la majorité des appareils vendus coûtent moins de 200 $ | Conception *mobile-first*, pages légères, aucune police téléchargée, interface sans framework |
| **Connexions intermittentes** et données parmi les plus chères au monde (1 Go ≈ 2,4 % du revenu mensuel moyen) | Application installable (PWA) qui garde les modules consultés, **PDF du cours** téléchargeable, vidéo à la demande, vidéo compressée en 240p téléchargeable |
| **Préférence pour le contenu court** et l'apprentissage en micro-sessions (transport, pauses, soirées) | Leçons de 10 à 15 minutes, vidéos de 5 à 7 minutes, reprise automatique |
| **Le certificat compte pour l'emploi** et la promotion interne | Certificat PDF soigné, référence vérifiable par un recruteur, partage WhatsApp et LinkedIn |
| **Le Mobile Money domine** : Orange Money, Wave, MTN MoMo, Moov ; en RDC, M-Pesa (~43-47 %), Airtel Money (~36-41 %) et Orange Money (~14-16 %) | Paiement via CinetPay (tous les opérateurs de la zone), paiement en 3 fois |
| **WhatsApp** est le canal de communication et d'apprentissage n°1 | Partage, support et ventes entreprises via WhatsApp |
| **Langues** : le français domine la formation professionnelle, l'anglais progresse (Cameroun, Rwanda), les langues locales (wolof, dioula, lingala, bambara…) dominent à l'oral | V1 en français ; V2 : résumés vidéo sous-titrés ou doublés en langues locales pour les modules gratuits, version anglaise pour le Cameroun anglophone |
| **Méfiance envers les offres en ligne** | 4 modules gratuits complets pour prouver la qualité, cabinet identifié (STFC), garantie de 7 jours |

### 1.4 Pays prioritaires et adaptation

| Vague | Pays | Monnaie / paiement | Adaptation |
|---|---|---|---|
| **1 (lancement)** | Côte d'Ivoire, Sénégal, Cameroun | XOF / XAF, Orange Money, Wave, MTN MoMo | Cas d'Abidjan, Dakar, Douala et Yaoundé ; prix de base |
| **2** | Bénin, Togo, Burkina Faso, Mali, Gabon, Congo, Niger | XOF / XAF | Même grille FCFA, cas de Cotonou, Lomé, Ouagadougou, Bamako, Libreville |
| **3** | RD Congo, Guinée, Madagascar, Burundi, Rwanda, Mauritanie | USD débité (zone « hors FCFA »), M-Pesa, Airtel Money, Orange Money | **−25 %** pour tenir compte du pouvoir d'achat ; cas de Kinshasa et Conakry |
| **4** | Maroc, Tunisie, Algérie | Affichage en MAD, paiement par carte (CMI ou Stripe en V2) | Prix de base, contenus B2B et grands comptes mis en avant |
| **Diaspora** | France, Belgique, Suisse, Canada | Affichage en €, carte | **+30 %** |

> Le XOF et le XAF ont la même parité fixe avec l'euro (1 € = 655,957 FCFA) : une seule grille couvre 14 pays.

---

## BLOC 2 : Architecture fonctionnelle

### 2.1 Vue d'ensemble

```
Visiteur ──► Accueil, catalogue, auto-évaluation, modules gratuits (lecture sans compte)
   │
   └─► Inscription gratuite ──► Quiz + attestations gratuites ──► Achat (Mobile Money / carte / code)
                                                                      │
                     Espace apprenant ◄────────────────────────────────┘
                     tableau de bord · parcours · leçons · quiz · certificats · PDF
                                                                      │
                     Back-office ◄─ formateurs (contenus, statistiques) · administrateurs (tout)
```

### 2.2 Espace apprenant

| Fonction | Détail | Statut |
|---|---|---|
| Inscription et connexion | Nom (utilisé sur les certificats), e-mail, téléphone WhatsApp, pays (qui détermine la zone tarifaire) | ✅ |
| Tableau de bord | Leçons terminées, modules validés, certificats, bouton « Reprendre », progression par parcours, accès actifs, derniers quiz | ✅ |
| Parcours et modules | 5 parcours, 24 modules, progression verrouillée dans les parcours payants | ✅ |
| Lecteur de leçons | Étapes numérotées, barre de progression, navigation précédent / suivant | ✅ |
| Certificats | Attestation par module, certificat par parcours, PDF au nom de l'apprenant, référence unique, page publique de vérification, ajout LinkedIn | ✅ |
| Auto-évaluation | 10 questions, score par dimension, parcours recommandé (sans compte) | ✅ |
| Profil | Modification du nom (certificats futurs), téléphone, pays, mot de passe | ✅ |

### 2.3 Contenus

| Élément | Format |
|---|---|
| **Vidéo résumé** | 5 à 7 minutes, chargée à la demande (YouTube nocookie, Vimeo, Bunny Stream, Cloudflare Stream), version compressée téléchargeable ; déroulé écrit affiché en attendant le tournage |
| **Cours texte** | 3 leçons progressives par module : paragraphes, étapes, **tableaux**, **schémas de flux**, **entonnoirs**, **matrices 2×2** (SWOT, BCG, Ansoff, Eisenhower, management situationnel, valeur / potentiel…), méthodes **RFM**, **ABC**, **SPIN**, **CAP**, **ACRA**, **ERAC** |
| **Étude de cas africaine** | Contexte, questions, corrigé masqué |
| **Encadrés** | « À retenir » et « Et vous ? » (mise en pratique) |
| **Livrable** | Un document professionnel à produire par module (plan, tableau de bord, grille…) |

### 2.4 Évaluation

- Quiz de validation de **5 à 8 questions** par module, questions et réponses **mélangées** à chaque tentative.
- **Seuil de réussite : 70 %** (paramétrable), tentatives illimitées, explication affichée pour chaque question.
- Correction **côté serveur** : les bonnes réponses ne sont jamais envoyées au navigateur avant validation.
- Le quiz n'est accessible qu'après toutes les leçons du module.
- La validation **débloque le module suivant** et l'**attestation**. La validation de tous les modules débloque le **certificat de parcours**.

### 2.5 Espace formateur et administrateur

| Rubrique | Formateur | Admin | Contenu |
|---|---|---|---|
| Tableau de bord | ✅ | ✅ | Apprenants, actifs à 7 et 30 jours, complétion, réussite aux quiz (et du 1er coup), conversion gratuit → payant, rétention à 30 jours, statistiques par module, pays, auto-évaluations |
| Chiffre d'affaires | | ✅ | Total, 30 derniers jours, par mois, par offre, paiements en attente |
| Contenus | ✅ | ✅ | Édition des modules (texte, vidéo, objectifs, livrable, leçons, quiz) avec validation |
| Utilisateurs | | ✅ | Recherche, fiche détaillée, rôle, désactivation, octroi et retrait d'accès |
| Paiements | | ✅ | Liste filtrable, revérification CinetPay |
| Codes d'accès | | ✅ | Génération par lot (parcours, durée, nombre d'utilisations, libellé client) pour les virements, entreprises et partenaires |
| Certificats | | ✅ | Registre complet, téléchargement PDF |

### 2.6 Hors connexion et faible bande passante

- Application installable sur l'écran d'accueil (PWA). Les pages, le catalogue et les modules déjà ouverts restent consultables sans réseau.
- **Cours complet en PDF** pour chaque module (leçons, tableaux, matrices, études de cas avec corrigé, livrable), au nom de l'apprenant.
- Vidéo compressée (MP4 240p) téléchargeable quand elle est fournie.
- Interface sans framework : chargement initial de l'ordre de 100 Ko.

### 2.7 Paiement

| Moyen | Mise en œuvre | Statut |
|---|---|---|
| Mobile Money (Orange Money, Wave, MTN MoMo, Moov, M-Pesa, Airtel Money…) | CinetPay, page de paiement hébergée | ✅ (mode simulation tant que les clés ne sont pas saisies) |
| Carte bancaire | CinetPay (Maghreb et diaspora : carte uniquement) | ✅ |
| Paiement en 3 fois | 1re échéance = accès de 35 jours, prolongé à chaque échéance, accès définitif après la 3e | ✅ |
| Abonnement mensuel / annuel | Accès complet 30 ou 365 jours, cumulable, **sans renouvellement automatique** | ✅ |
| Virement, entreprises, partenaires | Codes d'accès générés dans l'admin | ✅ |
| Maroc en dirhams, euros pour la diaspora | Stripe ou CMI | V2 |

---

## BLOC 3 : Parcours de formation et tarification

### 3.1 Vue d'ensemble des parcours

| Parcours | Public | Modules | Durée | Délivré |
|---|---|---|---|---|
| **Découverte (gratuit)** | Tout public | 4 + auto-évaluation | 3 h 15 | Attestation par module |
| **1. Commercial** | Débutants, vendeurs terrain, téléconseillers | 5 | 5 h de cours + 5 livrables (4 à 6 semaines) | Certificat professionnel STFC — Commercial |
| **2. Chef d'équipe commercial** | Commerciaux confirmés promus | 4 | 4 h de cours + 4 livrables (4 semaines) | Certificat professionnel STFC — Chef d'équipe commercial |
| **3. Responsable commercial** | Responsables de zone, de canal, d'agence | 5 | 5 h 15 de cours + 5 livrables (5 à 6 semaines) | Certificat professionnel STFC — Responsable commercial |
| **4. Directeur commercial** | Directeurs, DG de PME, cadres dirigeants | 6 | 6 h 40 de cours + 6 livrables (6 à 8 semaines) | Certificat professionnel STFC — Directeur commercial |

**Objectifs par parcours :**
- **Commercial** : conduire un entretien de vente complet, traiter les objections et défendre son prix, conclure et fidéliser, organiser ses tournées et suivre ses clients dans un CRM.
- **Chef d'équipe** : adopter la posture de manager, animer et motiver, coacher sur le terrain, piloter les objectifs et les KPI.
- **Responsable commercial** : bâtir un plan d'action commercial, segmenter un portefeuille (ABC, RFM), gérer les canaux de distribution, prévoir les ventes et piloter la rentabilité, recruter.
- **Directeur commercial** : définir la stratégie commerciale et d'innovation, organiser et rémunérer la force de vente, fixer une politique de prix, piloter les grands comptes, la transformation digitale et la gouvernance.

**Modules gratuits d'attraction :** F1 Initiation à la vente · F2 Prospection WhatsApp et réseaux sociaux · F4 Bases du marketing digital · F3 Introduction à l'innovation · Quiz d'auto-évaluation.

### 3.2 Grille tarifaire régionale (TTC)

Repères utilisés : formation en ligne locale de 10 h à environ 50 000 FCFA, formation présentielle de 100 000 à 350 000 FCFA pour 1 à 3 jours, et salaires bruts mensuels de ~75 000 à 450 000 FCFA pour un commercial jusqu'à plusieurs millions pour un directeur. **Règle retenue : un parcours coûte entre 15 et 35 % d'un mois de salaire du métier visé.**

| Offre | Zone FCFA (UEMOA, CEMAC) | Équivalent € | 3 × (FCFA) | Hors zone FCFA (−25 %) | Maghreb | Diaspora (+30 %) |
|---|---|---|---|---|---|---|
| Parcours Commercial | **35 000 FCFA** | 53 € | 12 000 | 44 $ | 570 MAD | 69 € |
| Parcours Chef d’équipe commercial | **65 000 FCFA** | 99 € | 22 500 | 82 $ | 1 070 MAD | 129 € |
| Parcours Responsable commercial | **95 000 FCFA** | 145 € | 32 500 | 119 $ | 1 560 MAD | 188 € |
| Parcours Directeur commercial | **150 000 FCFA** | 229 € | 51 500 | 188 $ | 2 460 MAD | 297 € |
| Pass Carrière (4 parcours) | **249 000 FCFA** | 380 € | 85 500 | 312 $ | 4 080 MAD | 493 € |
| Premium mensuel | **10 000 FCFA** | 15 € | – | 13 $ | 160 MAD | 20 € |
| Premium annuel | **99 000 FCFA** | 151 € | – | 124 $ | 1 620 MAD | 196 € |

*Calculée automatiquement par la plateforme (`app/src/pricing.js`). Le paiement en 3 fois inclut une majoration de 3 %. La zone « hors FCFA » est débitée en dollars, le Maghreb et la diaspora par carte.*

### 3.3 Offre entreprises

| Licences | Remise | Inclus |
|---|---|---|
| 5 à 9 | −15 % | Codes d'accès, suivi de progression |
| 10 à 24 | −25 % | + Rapport mensuel RH |
| 25 à 49 | −35 % | + Classe virtuelle dédiée |
| 50 et plus | Sur devis | + Atelier présentiel StratFocus Consulting |

### 3.4 Intitulé des certificats : pourquoi pas « Diplôme »

Au Sénégal comme en Côte d'Ivoire, l'**agrément** concerne l'établissement et la **reconnaissance** concerne chaque programme. Le mot « diplôme » désigne un titre reconnu par l'État. La plateforme délivre donc une **« Attestation de réussite »** par module et un **« Certificat professionnel STFC »** par parcours, avec la mention « certification professionnelle privée ».

**Levier de crédibilité recommandé :** demander l'agrément comme organisme de formation professionnelle (FDFP en Côte d'Ivoire, 3FPT au Sénégal, FNE au Cameroun). Cela permet aussi aux entreprises de **faire financer** les parcours par leurs fonds de formation.

---

## BLOC 4 : Plan de contenu détaillé

Chaque module suit le même gabarit : vidéo résumé → objectifs → 3 leçons progressives (tableaux, schémas, matrices) → étude de cas africaine avec corrigé → « À retenir » → livrable → quiz de validation (seuil 70 %). Le texte intégral se lit dans la plateforme et dans le PDF de chaque module.

### 4.0 Modules gratuits d’attraction

**Public :** Tout public : étudiants, demandeurs d’emploi, entrepreneurs, curieux · **Durée :** 3 h 15 · **Délivré :** Attestation de réussite par module

#### F1 · Les fondamentaux de la vente (45 min)

**Objectifs pédagogiques :** Expliquer ce qui distingue un commercial « conseil » d’un simple vendeur ; Dérouler les 7 étapes du cycle de vente ; Identifier les motivations d’achat d’un client grâce à la méthode SONCAS.

**Plan du cours :** vidéo résumé « La vente en 5 minutes » (5 min) → L1. Le rôle du commercial aujourd’hui → L2. Le cycle de vente en 7 étapes → L3. Comprendre son client : la méthode SONCAS → quiz.

**Tableaux, schémas et matrices :** Vendeur traditionnel ou commercial conseil · Le cycle de vente · Entonnoir de vente type (exemple d’un distributeur à Abidjan sur un mois) · Les 6 motivations SONCAS.

**Étude de cas africaine :** Awa, gérante d’une boutique de cosmétiques à Dakar.

**Livrable :** Fiche « mes clients et leurs motivations ». Pour 5 clients ou prospects réels : leur étape dans le cycle de vente, leur motivation SONCAS dominante et l’argument que vous allez mettre en avant.

<details><summary><strong>Quiz de validation : 6 questions (seuil 70 %)</strong></summary>

1. Quelle est la principale différence entre un vendeur traditionnel et un commercial conseil ?
2. Quelle répartition du temps de parole vise un bon commercial lors de la découverte ?
3. Quelle étape les débutants sautent-ils le plus souvent ?
4. Un client dit : « Et si ça tombe en panne ? ». Quelle motivation exprime-t-il ?
5. Dans le cas d’Awa, quel argument est le MOINS pertinent ?
6. Quelle est la dernière étape du cycle de vente ?

*Options, réponses et explications : back-office, rubrique Contenus.*

</details>

#### F2 · Prospecter avec WhatsApp et les réseaux sociaux (50 min)

**Objectifs pédagogiques :** Configurer un compte WhatsApp Business professionnel ; Choisir le bon réseau selon sa cible (B2C ou B2B) ; Rédiger des messages de prospection et de relance efficaces.

**Plan du cours :** vidéo résumé « Prospecter sur WhatsApp sans spammer » (5 min) → L1. Le social selling en Afrique francophone → L2. Bien configurer WhatsApp Business → L3. Scripts de prospection et de relance → quiz.

**Tableaux, schémas et matrices :** Quel réseau pour quelle cible ? · Où investir son temps ? · Parcours d’un prospect sur WhatsApp · Structure d’un premier message (méthode A.P.Q.).

**Étude de cas africaine :** Koffi, commercial en assurance à Lomé.

**Livrable :** Mon dispositif de prospection WhatsApp. Captures de votre profil WhatsApp Business configuré (catalogue, étiquettes, réponses rapides), 3 messages de prospection A.P.Q. et votre calendrier de relance.

<details><summary><strong>Quiz de validation : 6 questions (seuil 70 %)</strong></summary>

1. Quel réseau privilégier pour prospecter des directeurs financiers de banques ?
2. Que signifie la règle des 80/20 en social selling ?
3. À quoi servent les étiquettes WhatsApp Business ?
4. Quel est l’objectif d’un premier message de prospection ?
5. Quelle erreur principale Koffi a-t-il commise ?
6. Que faire après la relance de J+15 sans réponse ?

*Options, réponses et explications : back-office, rubrique Contenus.*

</details>

#### F4 · Les bases du marketing digital (50 min)

**Objectifs pédagogiques :** Décrire le parcours client digital (modèle AARRR) ; Choisir ses canaux : réseaux sociaux, WhatsApp, Google, e-mail, SMS ; Lancer une campagne publicitaire Facebook/Instagram à petit budget ; Suivre 5 indicateurs clés (portée, clics, coût par contact, conversion, ROI).

**Plan du cours :** vidéo résumé « Le marketing digital avec 10 000 FCFA » (6 min) → L1. Le parcours client digital → L2. Choisir ses canaux et créer du contenu → L3. Publicité à petit budget et mesure des résultats → quiz.

**Tableaux, schémas et matrices :** Le modèle AARRR (« pirate funnel ») · AARRR appliqué à un traiteur de Cotonou · Les canaux et leur rôle · Les 5 indicateurs à suivre chaque semaine.

**Étude de cas africaine :** Fatou, boutique de wax en ligne à Dakar.

**Livrable :** Plan digital de 30 jours. Un tableau d’une page : objectif, canal principal, 12 publications planifiées (4 types de contenus), budget publicitaire et les 5 indicateurs avec leur cible.

<details><summary><strong>Quiz de validation : 7 questions (seuil 70 %)</strong></summary>

1. Que signifie le premier « A » du modèle AARRR ?
2. Quel canal a le meilleur taux de lecture pour relancer des clients existants ?
3. Pour une publicité destinée à générer des ventes, quel objectif choisir ?
4. Une dépense de 30 000 FCFA génère 100 conversations. Quel est le coût par contact ?
5. Un témoignage client vidéo est un contenu de type…
6. Quelle était l’erreur principale de Fatou ?
7. Le ROI se calcule par…

*Options, réponses et explications : back-office, rubrique Contenus.*

</details>

#### F3 · Initiation au marketing d’innovation (50 min)

**Objectifs pédagogiques :** Distinguer innovation de rupture, incrémentale et frugale ; Remplir un Value Proposition Canvas ; Concevoir un test terrain (MVP) en moins de 2 semaines.

**Plan du cours :** vidéo résumé « Innover avec peu de moyens » (6 min) → L1. Qu’est-ce que le marketing d’innovation ? → L2. Le Value Proposition Canvas → L3. Tester vite : le MVP terrain → quiz.

**Tableaux, schémas et matrices :** Trois types d’innovation · Matrice d’Ansoff simplifiée : où innover ? · Les deux côtés du canvas · La boucle Construire → Mesurer → Apprendre.

**Étude de cas africaine :** GazExpress, livraison de bouteilles de gaz à Douala.

**Livrable :** Value Proposition Canvas et plan de test. Le canvas rempli pour une offre réelle ou en projet, et le plan d’un MVP : hypothèse, test, coût, indicateur de succès et date.

<details><summary><strong>Quiz de validation : 6 questions (seuil 70 %)</strong></summary>

1. Vendre de l’huile en petits sachets est une innovation…
2. Dans la matrice d’Ansoff, vendre un nouveau produit à un nouveau marché s’appelle…
3. Dans le Value Proposition Canvas, « la panne de gaz en pleine cuisson » est…
4. Que signifie MVP ?
5. Quel est le meilleur signal de validation d’une idée ?
6. Le Mobile Money est un exemple d’innovation…

*Options, réponses et explications : back-office, rubrique Contenus.*

</details>

### 4.1 Parcours Commercial

**Public :** Débutants, vendeurs terrain, téléconseillers, commerciaux juniors · **Durée :** 5 h de cours + 5 livrables (4 à 6 semaines) · **Délivré :** Certificat professionnel STFC — Commercial

#### C1 · Découverte client et art du questionnement (60 min)

**Objectifs pédagogiques :** Préparer un entretien de découverte ; Utiliser les 4 types de questions SPIN ; Reformuler et valider les besoins du client.

**Plan du cours :** vidéo résumé « Poser les bonnes questions » (6 min) → L1. Préparer son entretien de découverte → L2. La méthode SPIN → L3. Écoute active et reformulation → quiz.

**Tableaux, schémas et matrices :** Fiche de préparation (à remplir avant chaque visite) · Progression SPIN · SPIN appliquée : vente d’un service de livraison à un grossiste de Bouaké.

**Étude de cas africaine :** Ibrahim, commercial en matériel agricole à Bobo-Dioulasso.

**Livrable :** Guide d’entretien de découverte. Votre fiche de préparation de visite et 12 questions SPIN (3 par type) adaptées à votre produit, testées lors d’au moins 2 rendez-vous.

<details><summary><strong>Quiz de validation : 7 questions (seuil 70 %)</strong></summary>

1. Combien de questions de Situation faut-il poser au maximum ?
2. « Combien cela vous coûte-t-il par mois ? » est une question…
3. Quel est le rôle des questions Need-payoff ?
4. « Préférez-vous une livraison lundi ou jeudi ? » est une question…
5. Quelle a été l’erreur d’Ibrahim ?
6. Après une reformulation, que faut-il faire ?
7. Pourquoi fixer un objectif minimal pour une visite ?

*Options, réponses et explications : back-office, rubrique Contenus.*

</details>

#### C2 · Argumentation et traitement des objections (65 min)

**Objectifs pédagogiques :** Transformer une caractéristique produit en bénéfice client (méthode CAP) ; Identifier les familles d’objections (vraies, fausses, prétextes) ; Répondre aux objections avec la méthode ACRA ; Traiter l’objection prix sans brader.

**Plan du cours :** vidéo résumé « Répondre à « c’est trop cher » » (6 min) → L1. Argumenter avec la méthode CAP → L2. Comprendre et classer les objections → L3. La méthode ACRA et l’objection prix → quiz.

**Tableaux, schémas et matrices :** Un argument en trois temps · CAP appliqué : vente d’un groupe électrogène à une boulangerie de Bamako · Les familles d’objections · Où se situe le client ?.

**Étude de cas africaine :** Moussa, quincaillier à Bamako.

**Livrable :** Fiche « 10 objections, 10 réponses ». Listez les 10 objections que vous entendez le plus, classez-les par type et rédigez pour chacune une réponse ACRA avec une preuve.

<details><summary><strong>Quiz de validation : 7 questions (seuil 70 %)</strong></summary>

1. Dans la méthode CAP, que désigne le « A » ?
2. « Je vais réfléchir » est le plus souvent une objection…
3. Quelle est la deuxième étape de la méthode ACRA ?
4. Que signifie « fractionner » le prix ?
5. Quelle est la règle d’or d’une concession ?
6. Quelle était l’erreur de Moussa ?
7. Un client à l’objection floue mais très intéressé est…

*Options, réponses et explications : back-office, rubrique Contenus.*

</details>

#### C3 · Négociation et closing (65 min)

**Objectifs pédagogiques :** Préparer une négociation avec la grille des concessions (objectif, MESORE, point de rupture) ; Défendre son prix face aux tactiques des acheteurs ; Repérer les signaux d’achat ; Choisir la bonne technique de conclusion.

**Plan du cours :** vidéo résumé « Oser demander la commande » (6 min) → L1. Préparer sa négociation → L2. Défendre son prix face aux acheteurs → L3. Repérer les signaux d’achat et conclure → quiz.

**Tableaux, schémas et matrices :** Les repères de préparation · Tactiques fréquentes des acheteurs et parades · Le principe du donnant-donnant · Signaux d’achat.

**Étude de cas africaine :** Eric, commercial en solutions solaires à Douala.

**Livrable :** Fiche de préparation de négociation. Pour votre prochain rendez-vous important : objectif idéal, point de rupture, MESORE, grille de 5 concessions avec contreparties, et 2 formulations de conclusion.

<details><summary><strong>Quiz de validation : 7 questions (seuil 70 %)</strong></summary>

1. Que signifie MESORE ?
2. Quelle concession céder en premier ?
3. L’acheteur demande une petite concession après l’autre. C’est la tactique…
4. « Vous livrez quand ? » est…
5. « Livraison lundi ou jeudi ? » est une conclusion par…
6. Que faire quand l’acheteur se tait après l’annonce du prix ?
7. Quelle était l’erreur d’Eric ?

*Options, réponses et explications : back-office, rubrique Contenus.*

</details>

#### C4 · Fidélisation, suivi client et CRM simple (55 min)

**Objectifs pédagogiques :** Expliquer pourquoi fidéliser rapporte plus que conquérir ; Construire un plan de contact client par segment ; Monter un CRM simple en une heure ; Obtenir des recommandations de façon systématique.

**Plan du cours :** vidéo résumé « Vos clients actuels sont votre meilleur marché » (5 min) → L1. Pourquoi fidéliser → L2. Le plan de contact client → L3. Monter un CRM simple et obtenir des recommandations → quiz.

**Tableaux, schémas et matrices :** L’échelle de fidélité · Calculer la valeur d’un client (exemple : cliente d’un salon de coiffure à Abidjan) · Exemple de plan de contact (distributeur de produits d’entretien, Lomé) · Les colonnes indispensables.

**Étude de cas africaine :** Aïcha, conseillère en assurance à Ouagadougou.

**Livrable :** Mon CRM et mon plan de contact. Un tableur avec au moins 20 clients renseignés (6 colonnes), leur segment et la prochaine action datée, plus 3 messages types (remerciement, satisfaction, recommandation).

<details><summary><strong>Quiz de validation : 6 questions (seuil 70 %)</strong></summary>

1. Une cliente dépense 20 000 FCFA, 6 fois par an, pendant 5 ans. Quelle est sa valeur vie client ?
2. Quel est le dernier échelon de l’échelle de fidélité ?
3. Quelle colonne de CRM évite d’oublier une relance ?
4. Quel est le meilleur moment pour demander une recommandation ?
5. Que faire avec un client inactif depuis 3 mois ?
6. Pourquoi Aïcha perdait-elle des clients ?

*Options, réponses et explications : back-office, rubrique Contenus.*

</details>

#### C5 · Organisation, tournées et gestion du temps (50 min)

**Objectifs pédagogiques :** Sectoriser sa zone et planifier une tournée hebdomadaire ; Prioriser ses tâches avec la matrice d’Eisenhower ; Calculer et suivre ses indicateurs personnels de performance.

**Plan du cours :** vidéo résumé « Gagner 2 heures par jour sur le terrain » (5 min) → L1. Sectoriser et planifier sa tournée → L2. Prioriser avec la matrice d’Eisenhower → L3. Mes indicateurs personnels → quiz.

**Tableaux, schémas et matrices :** Deux formes de tournée · La matrice d’Eisenhower du commercial · Une semaine type équilibrée · Les indicateurs du commercial.

**Étude de cas africaine :** Didier, commercial en boissons à Kinshasa.

**Livrable :** Mon planning de tournée sur 4 semaines. Carte des secteurs, affectation d’un secteur par jour, liste des clients avec leur fréquence de visite, et tableau des 5 indicateurs avec la cible de chacun.

<details><summary><strong>Quiz de validation : 6 questions (seuil 70 %)</strong></summary>

1. Dans la matrice d’Eisenhower, la prospection est le plus souvent…
2. Quel est l’intérêt de la sectorisation ?
3. 8 commandes pour 32 visites donnent un taux de transformation de…
4. Quand faire les tâches administratives ?
5. Quelle part de créneaux garder libre ?
6. Quel était le principal problème de Didier ?

*Options, réponses et explications : back-office, rubrique Contenus.*

</details>

### 4.2 Parcours Chef d’équipe commercial

**Public :** Commerciaux confirmés promus ou en voie de promotion · **Durée :** 4 h de cours + 4 livrables (4 semaines) · **Délivré :** Certificat professionnel STFC — Chef d’équipe commercial

#### E1 · De vendeur à manager : réussir sa prise de poste (60 min)

**Objectifs pédagogiques :** Identifier les pièges du passage de vendeur à manager ; Appliquer le management situationnel ; Construire son plan des 90 premiers jours.

**Plan du cours :** vidéo résumé « Hier collègue, aujourd’hui manager » (6 min) → L1. Le changement de rôle et ses pièges → L2. Le management situationnel → L3. Votre plan des 90 premiers jours → quiz.

**Tableaux, schémas et matrices :** Ce qui change · Les 3 pièges classiques · Les 4 styles de management · Exemple : équipe de 5 commerciaux d’une brasserie à Abidjan.

**Étude de cas africaine :** Mariam, nouvelle chef d’équipe dans une banque à Dakar.

**Livrable :** Plan des 90 premiers jours. Le diagnostic de votre équipe (style S1 à S4 par collaborateur et par tâche clé) et votre plan des 90 jours avec livrables et dates.

<details><summary><strong>Quiz de validation : 7 questions (seuil 70 %)</strong></summary>

1. Comment se mesure la réussite d’un chef d’équipe commercial ?
2. Un manager reprend les gros clients de ses vendeurs pour sauver le mois. C’est le piège…
3. Quel style pour un nouveau commercial enthousiaste mais inexpérimenté ?
4. Quel style pour un expert motivé et autonome ?
5. Le style de management dépend…
6. Que faire en priorité durant les 30 premiers jours ?
7. Quelle était l’erreur principale de Mariam ?

*Options, réponses et explications : back-office, rubrique Contenus.*

</details>

#### E2 · Animer et motiver son équipe (60 min)

**Objectifs pédagogiques :** Animer un brief matinal de 15 minutes et une réunion hebdomadaire utile ; Utiliser les leviers de motivation (Herzberg, reconnaissance) ; Concevoir un challenge commercial motivant et rentable ; Conduire un entretien de remotivation.

**Plan du cours :** vidéo résumé « Le brief de 15 minutes qui change une journée » (6 min) → L1. Les rituels d’équipe → L2. Les leviers de motivation → L3. Challenges commerciaux et remotivation → quiz.

**Tableaux, schémas et matrices :** Les 3 rituels clés · Le brief du matin en 4 temps · Facteurs d’hygiène et facteurs moteurs · Adapter son levier au profil.

**Étude de cas africaine :** le challenge qui a divisé l’équipe.

**Livrable :** Kit d’animation de mon équipe. Le déroulé de votre brief du matin, l’ordre du jour du point hebdomadaire, et le règlement complet d’un challenge de 4 semaines (objectif, paliers, récompenses, coût, règles).

<details><summary><strong>Quiz de validation : 7 questions (seuil 70 %)</strong></summary>

1. Combien de temps doit durer un brief du matin ?
2. Selon Herzberg, des commissions payées en retard sont…
3. Quel est un facteur moteur ?
4. Quelle est la durée idéale d’un challenge commercial ?
5. Pourquoi préférer des paliers individuels à un seul gagnant ?
6. Que faire en premier lors d’un entretien de remotivation ?
7. Un expert désengagé a surtout besoin…

*Options, réponses et explications : back-office, rubrique Contenus.*

</details>

#### E3 · Coaching terrain et accompagnement (60 min)

**Objectifs pédagogiques :** Préparer une journée d’accompagnement terrain ; Observer un entretien de vente avec une grille d’évaluation ; Donner un feedback constructif (méthode DESC) ; Construire un plan de progrès individuel.

**Plan du cours :** vidéo résumé « Coacher sans faire à la place » (6 min) → L1. La journée d’accompagnement → L2. Observer avec une grille objective → L3. Débriefer et construire le plan de progrès → quiz.

**Tableaux, schémas et matrices :** Avant, pendant et après · Grille d’observation de l’entretien de vente (note de 1 à 4) · Le débriefing en 5 temps · La méthode DESC pour un feedback constructif.

**Étude de cas africaine :** Kouamé et le manager « sauveur ».

**Livrable :** Grille d’accompagnement et plan de progrès. Votre grille d’observation adaptée à votre métier, remplie lors d’un accompagnement réel, et le plan de progrès sur 1 mois du commercial accompagné.

<details><summary><strong>Quiz de validation : 6 questions (seuil 70 %)</strong></summary>

1. Combien de compétences travailler au maximum par accompagnement ?
2. Pendant la visite, le manager doit…
3. Que signifie le « D » de DESC ?
4. Quelle est la première étape du débriefing ?
5. « Tu n’écoutes pas les clients » est…
6. Quelle conséquence a eue l’attitude du manager de Kouamé ?

*Options, réponses et explications : back-office, rubrique Contenus.*

</details>

#### E4 · Piloter les objectifs et les KPI d’équipe (60 min)

**Objectifs pédagogiques :** Répartir un objectif collectif en objectifs individuels équitables ; Choisir les 8 KPI d’une équipe commerciale ; Construire un tableau de bord simple (Google Sheets) ; Analyser un écart et décider d’actions correctives.

**Plan du cours :** vidéo résumé « Piloter son équipe avec 8 chiffres » (6 min) → L1. Répartir l’objectif collectif → L2. Les 8 KPI et le tableau de bord → L3. Analyser les écarts et décider → quiz.

**Tableaux, schémas et matrices :** Répartition par le potentiel (équipe de 4, objectif de 120 M FCFA) · Les 8 KPI d’une équipe commerciale · Extrait de tableau de bord hebdomadaire (code couleur) · Diagnostic : activité ou efficacité ?.

**Étude de cas africaine :** l’équipe de Yaoundé à 70 % de l’objectif.

**Livrable :** Tableau de bord d’équipe. Un tableau de bord Google Sheets avec les 8 KPI pour chaque commercial, les objectifs individuels répartis selon le potentiel, et l’analyse d’un écart réel avec 3 actions correctives.

<details><summary><strong>Quiz de validation : 6 questions (seuil 70 %)</strong></summary>

1. Pourquoi éviter de répartir l’objectif à parts égales ?
2. Le nombre de visites est un KPI…
3. Beaucoup de visites mais peu de ventes : que faire ?
4. Pourquoi suivre les créances ?
5. Quelle est la première question de l’analyse d’écart ?
6. Dans le cas de Yaoundé, quelle est la cause principale ?

*Options, réponses et explications : back-office, rubrique Contenus.*

</details>

### 4.3 Parcours Responsable commercial

**Public :** Responsables de zone, de canal, d’agence ou de grands secteurs · **Durée :** 5 h 15 de cours + 5 livrables (5 à 6 semaines) · **Délivré :** Certificat professionnel STFC — Responsable commercial

#### R1 · Construire son plan d’action commercial (PAC) (70 min)

**Objectifs pédagogiques :** Réaliser un diagnostic commercial avec le SWOT ; Fixer des objectifs chiffrés par segment ; Construire un PAC avec actions, responsables, budget et indicateurs.

**Plan du cours :** vidéo résumé « Le PAC en 6 étapes » (6 min) → L1. Diagnostic : d’où partons-nous ? → L2. Objectifs et cibles → L3. Le plan d’actions et son suivi → quiz.

**Tableaux, schémas et matrices :** Les 6 étapes du PAC · SWOT : Cimat Matériaux, PME de matériaux de construction à Yaoundé · Indicateurs du diagnostic · Objectifs SMART du PAC Cimat (12 mois).

**Étude de cas africaine :** le PAC qui dort dans un tiroir.

**Livrable :** Plan d’action commercial en une page. SWOT de votre zone, 4 objectifs SMART, matrice de priorisation des segments et tableau des 5 actions prioritaires (responsable, échéance, budget, indicateur).

<details><summary><strong>Quiz de validation : 8 questions (seuil 70 %)</strong></summary>

1. Dans un SWOT, « l’arrivée d’un concurrent » est…
2. Dans un SWOT, « pas de service de livraison » est…
3. Que signifie le « M » de SMART ?
4. Un segment attractif où l’entreprise est bien placée doit être…
5. Quels éléments chaque action d’un PAC doit-elle comporter ?
6. Pourquoi le PAC de Libreville a-t-il échoué ?
7. À quelle fréquence réviser le PAC avec la direction ?
8. Dépendre de 3 clients pour 45 % du CA représente…

*Options, réponses et explications : back-office, rubrique Contenus.*

</details>

#### R2 · Segmentation et gestion du portefeuille clients (65 min)

**Objectifs pédagogiques :** Réaliser une analyse ABC de son portefeuille ; Segmenter ses clients avec la méthode RFM (Récence, Fréquence, Montant) ; Construire une matrice valeur actuelle / potentiel ; Définir un niveau de service et une fréquence de visite par segment.

**Plan du cours :** vidéo résumé « 20 % de vos clients font 80 % de vos ventes » (6 min) → L1. L’analyse ABC (loi de Pareto) → L2. La segmentation RFM → L3. Valeur, potentiel et politique de service → quiz.

**Tableaux, schémas et matrices :** Résultat type (distributeur de produits alimentaires, Cotonou : 400 clients) · Les 3 critères (note de 1 à 5) · Segments RFM et actions · Matrice valeur actuelle / potentiel.

**Étude de cas africaine :** DistriCo, distributeur FMCG à Cotonou.

**Livrable :** Segmentation de mon portefeuille. Analyse ABC et notation RFM de votre portefeuille dans un tableur, matrice valeur / potentiel avec vos 20 premiers clients, et politique de service par segment (fréquence, canal, conditions).

<details><summary><strong>Quiz de validation : 7 questions (seuil 70 %)</strong></summary>

1. Selon la loi de Pareto, environ quelle part des clients fait 80 % du CA ?
2. Dans la méthode RFM, que mesure le « R » ?
3. Un ancien gros client qui n’a pas acheté depuis 3 mois est…
4. Un client qui achète peu aujourd’hui mais a un fort potentiel est…
5. Quel canal privilégier pour les petits clients à faible potentiel ?
6. Combien coûtent par an 100 visites hebdomadaires à 5 000 FCFA ?
7. Quelle est la limite de l’analyse ABC seule ?

*Options, réponses et explications : back-office, rubrique Contenus.*

</details>

#### R3 · Canaux de vente et distribution (65 min)

**Objectifs pédagogiques :** Cartographier les circuits de distribution de son marché ; Calculer la cascade de prix et la rentabilité par canal ; Prévenir et gérer les conflits entre canaux ; Intégrer le e-commerce et le social commerce sans cannibaliser les distributeurs.

**Plan du cours :** vidéo résumé « Du grossiste au client final : qui gagne quoi ? » (6 min) → L1. Les circuits de distribution en Afrique francophone → L2. Cascade de prix et rentabilité par canal → L3. Conflits de canaux et social commerce → quiz.

**Tableaux, schémas et matrices :** Le circuit traditionnel type · Comparaison des canaux · Cascade de prix : carton de 24 boissons (prix final conseillé : 12 000 FCFA) · Rentabilité par canal (pour 100 M FCFA de CA).

**Étude de cas africaine :** la marque de jus qui a fâché ses distributeurs.

**Livrable :** Carte et politique de distribution. La carte de vos circuits de distribution avec les volumes, la cascade de prix de votre produit principal, un tableau de rentabilité par canal et 5 règles écrites pour prévenir les conflits.

<details><summary><strong>Quiz de validation : 6 questions (seuil 70 %)</strong></summary>

1. Quel canal reste souvent dominant pour les produits de grande consommation en Afrique francophone ?
2. À quoi sert la cascade de prix ?
3. Un détaillant achète 9 600 FCFA et vend 12 000 FCFA. Quel est son taux de marge sur le prix d’achat ?
4. Quel élément est souvent oublié dans la rentabilité d’un canal ?
5. Quelle est la règle d’or de l’omnicanal ?
6. Pourquoi les distributeurs de la marque de jus ont-ils réduit leurs commandes ?

*Options, réponses et explications : back-office, rubrique Contenus.*

</details>

#### R4 · Prévisions et budget des ventes (60 min)

**Objectifs pédagogiques :** Réaliser une prévision des ventes (historique, tendance, coefficients saisonniers) ; Intégrer les saisonnalités locales (Ramadan, Tabaski, fêtes, rentrée, campagnes agricoles) ; Construire le budget commercial de sa zone ; Mesurer l’impact d’une remise sur la marge.

**Plan du cours :** vidéo résumé « Prévoir sans boule de cristal » (6 min) → L1. Méthodes de prévision simples → L2. La saisonnalité en Afrique francophone → L3. Budget commercial et pilotage de la marge → quiz.

**Tableaux, schémas et matrices :** Trois méthodes complémentaires · Événements qui font varier les ventes · Exemple : prévision d’un fabricant de boissons à Dakar (base 100 M FCFA / mois) · Budget commercial annuel d’une zone (en M FCFA).

**Étude de cas africaine :** la promotion qui a fait perdre de l’argent.

**Livrable :** Prévision et budget de ma zone. Un tableur avec la prévision mensuelle des 12 prochains mois (tendance + coefficients saisonniers), le budget commercial en 5 lignes et la simulation de l’impact d’une remise de 5 % et de 10 %.

<details><summary><strong>Quiz de validation : 7 questions (seuil 70 %)</strong></summary>

1. Un mois vend 130 quand la moyenne mensuelle est de 100. Son coefficient saisonnier est…
2. Pourquoi les dates de Ramadan et de Tabaski changent-elles chaque année ?
3. La prévision « bottom-up » consiste à…
4. Avec 30 % de marge, quelle hausse de volume compense une remise de 10 % ?
5. Contribution commerciale = …
6. Pourquoi la promotion de Conakry a-t-elle fait perdre de l’argent ?
7. Quelle alternative préserve mieux la marge ?

*Options, réponses et explications : back-office, rubrique Contenus.*

</details>

#### R5 · Recruter et intégrer ses commerciaux (55 min)

**Objectifs pédagogiques :** Rédiger une fiche de poste et un profil de compétences ; Conduire un entretien structuré avec jeu de rôle ; Évaluer les candidats avec une grille objective ; Construire un parcours d’intégration de 30 jours.

**Plan du cours :** vidéo résumé « Recruter un vendeur, pas un beau parleur » (5 min) → L1. Définir le poste et le profil → L2. L’entretien et la mise en situation → L3. Évaluer et intégrer → quiz.

**Tableaux, schémas et matrices :** Fiche de poste : commercial terrain B2B (distribution de matériel électrique, Douala) · Profil de compétences · Le processus de recrutement · Questions comportementales (méthode STAR : Situation, Tâche, Action, Résultat).

**Étude de cas africaine :** le « meilleur vendeur » qui a démissionné.

**Livrable :** Kit de recrutement. Une fiche de poste, une grille d’entretien de 8 questions STAR, un scénario de jeu de rôle, une grille d’évaluation pondérée et le planning d’intégration des 30 premiers jours.

<details><summary><strong>Quiz de validation : 6 questions (seuil 70 %)</strong></summary>

1. Sur quoi recruter en priorité un commercial ?
2. Que signifie STAR dans les questions comportementales ?
3. Quel est l’intérêt du jeu de rôle ?
4. Quel objectif fixer à un nouveau commercial le premier mois ?
5. Avec la grille de la leçon, pourquoi le candidat A l’emporte-t-il ?
6. Quelle erreur d’intégration a été commise à Libreville ?

*Options, réponses et explications : back-office, rubrique Contenus.*

</details>

### 4.4 Parcours Directeur commercial

**Public :** Directeurs commerciaux, DG de PME, cadres dirigeants · **Durée :** 6 h 40 de cours + 6 livrables (6 à 8 semaines) · **Délivré :** Certificat professionnel STFC — Directeur commercial

#### D1 · Stratégie commerciale et marketing d’innovation (75 min)

**Objectifs pédagogiques :** Analyser son marché avec PESTEL et les 5 forces de Porter ; Arbitrer son portefeuille avec la matrice BCG ; Construire une stratégie Océan bleu avec la grille ERAC.

**Plan du cours :** vidéo résumé « Penser la stratégie comme un directeur » (6 min) → L1. Analyser l’environnement : PESTEL et Porter → L2. Arbitrer son portefeuille : la matrice BCG → L3. Innover pour sortir de la concurrence : l’Océan bleu → quiz.

**Tableaux, schémas et matrices :** PESTEL : marché des produits laitiers en Côte d’Ivoire (illustratif) · Les 5 forces de Porter · Matrice BCG : opérateur télécoms (illustratif) · Traduction commerciale.

**Étude de cas africaine :** TransLog, transporteur de marchandises à Ouagadougou.

**Livrable :** Note stratégique. PESTEL et 5 forces de Porter de votre marché, matrice BCG de votre portefeuille et grille ERAC d’une offre « océan bleu ».

<details><summary><strong>Quiz de validation : 8 questions (seuil 70 %)</strong></summary>

1. Dans le PESTEL, le développement du Mobile Money relève du facteur…
2. Le lait en poudre face au lait frais illustre la force de Porter…
3. Dans la matrice BCG, une « vache à lait » a…
4. Quelle politique pour un « dilemme » ?
5. Que signifie ERAC ?
6. Un océan rouge est…
7. Pour TransLog, quelle création de valeur est la plus différenciante ?
8. Selon la leçon, la stratégie consiste avant tout à…

*Options, réponses et explications : back-office, rubrique Contenus.*

</details>

#### D2 · Organisation de la force de vente et rémunération variable (70 min)

**Objectifs pédagogiques :** Calculer la taille optimale de la force de vente (méthode de la charge de travail) ; Choisir une organisation adaptée à la stratégie ; Concevoir un plan de rémunération fixe + variable aligné sur la marge ; Éviter les effets pervers des systèmes de commission.

**Plan du cours :** vidéo résumé « Combien de commerciaux, organisés comment, payés comment ? » (7 min) → L1. Dimensionner la force de vente → L2. Choisir son organisation → L3. Concevoir la rémunération variable → quiz.

**Tableaux, schémas et matrices :** Calcul : distributeur de produits d’hygiène, Côte d’Ivoire · Les 4 grandes organisations · Quelle organisation choisir ? · Les composantes du plan.

**Étude de cas africaine :** les commissions qui détruisaient la marge.

**Livrable :** Plan d’organisation et de rémunération. Le calcul de dimensionnement de votre force de vente, l’organigramme cible justifié et une grille de rémunération variable simulée sur 3 profils (sous-performant, à l’objectif, en dépassement).

<details><summary><strong>Quiz de validation : 7 questions (seuil 70 %)</strong></summary>

1. 20 000 visites nécessaires, capacité de 800 visites par commercial : combien de commerciaux ?
2. Quelle organisation pour une offre simple et des clients homogènes ?
3. Pourquoi commissionner sur la marge plutôt que sur le CA ?
4. À quoi sert un seuil de déclenchement ?
5. Combien de critères dans une prime sur objectifs ?
6. Quel critère manquait dans le plan de l’assureur ?
7. Que faire avant de déployer un nouveau plan de rémunération ?

*Options, réponses et explications : back-office, rubrique Contenus.*

</details>

#### D3 · Pricing stratégique (65 min)

**Objectifs pédagogiques :** Distinguer prix coût, prix concurrence et prix valeur ; Construire une architecture de prix (gammes, petits formats, prix psychologiques) ; Mettre en place une politique de remises et la cascade de prix nette ; Conduire une hausse de prix en contexte d’inflation.

**Plan du cours :** vidéo résumé « Le prix est le levier de profit le plus puissant » (6 min) → L1. Les trois logiques de prix → L2. Architecture de prix et remises → L3. Augmenter ses prix sans perdre ses clients → quiz.

**Tableaux, schémas et matrices :** Coût, concurrence, valeur · Construire un prix valeur · Outils d’architecture de prix adaptés aux marchés africains · La cascade de prix : du catalogue au prix net (exemple B2B).

**Étude de cas africaine :** la hausse du prix de l’huile en Guinée.

**Livrable :** Politique de prix. Le calcul du prix valeur d’un produit, la cascade de prix de vos 5 principaux clients et un plan de hausse de prix segmenté (produits, clients, calendrier, arguments).

<details><summary><strong>Quiz de validation : 7 questions (seuil 70 %)</strong></summary>

1. Quelle logique de prix maximise la marge d’une offre innovante ?
2. Le prix plancher correspond…
3. Vendre de la lessive en dose de 100 FCFA est un exemple…
4. Le « prix net de poche » est…
5. Avec 5 % de marge nette, une hausse de prix de 1 % à volume constant augmente le résultat de…
6. Que proposer à un client fidèle très sensible au prix lors d’une hausse ?
7. Quelle stratégie convenait à l’industriel guinéen ?

*Options, réponses et explications : back-office, rubrique Contenus.*

</details>

#### D4 · Grands comptes et vente B2B complexe (65 min)

**Objectifs pédagogiques :** Cartographier les acteurs d’une décision d’achat complexe ; Construire un plan de compte stratégique ; Qualifier une opportunité avant d’y investir du temps ; Répondre à un appel d’offres de façon gagnante.

**Plan du cours :** vidéo résumé « Vendre à une organisation, pas à une personne » (6 min) → L1. Le centre de décision → L2. Le plan de compte stratégique → L3. Répondre aux appels d’offres → quiz.

**Tableaux, schémas et matrices :** Les rôles dans une décision d’achat · Carte des acteurs : influence et attitude · Plan de compte en une page : banque régionale (exemple) · Qualifier une opportunité (méthode BANT enrichie).

**Étude de cas africaine :** l’appel d’offres perdu pour une attestation.

**Livrable :** Plan de compte stratégique. Pour un grand compte réel : carte des acteurs (influence et attitude), plan de compte en une page et grille de qualification de la prochaine opportunité.

<details><summary><strong>Quiz de validation : 6 questions (seuil 70 %)</strong></summary>

1. Qui est le prescripteur dans une vente B2B ?
2. Quelle priorité pour un opposant influent ?
3. Que signifie le « A » de BANT ?
4. Quel est le rôle d’un « coach » interne ?
5. Quelle est la première cause d’élimination dans un appel d’offres ?
6. Comment construire l’offre technique ?

*Options, réponses et explications : back-office, rubrique Contenus.*

</details>

#### D5 · Transformation digitale commerciale et données (65 min)

**Objectifs pédagogiques :** Évaluer la maturité digitale de sa fonction commerciale ; Choisir et réussir le déploiement d’un CRM ; Construire un pilotage par la donnée (tableaux de bord, prévisions) ; Utiliser l’IA générative au service des équipes commerciales.

**Plan du cours :** vidéo résumé « Digitaliser sans perdre le terrain » (7 min) → L1. La maturité digitale commerciale → L2. Choisir et réussir son CRM → L3. Piloter par la donnée et utiliser l’IA → quiz.

**Tableaux, schémas et matrices :** Les 4 niveaux de maturité · Feuille de route type sur 18 mois · Critères de choix d’un CRM en Afrique francophone · Facteurs de réussite du déploiement.

**Étude de cas africaine :** le CRM abandonné en 6 mois.

**Livrable :** Feuille de route digitale commerciale. Diagnostic de maturité, processus de vente écrit (étapes et critères), cahier des charges CRM en 10 critères, maquette du tableau de bord de direction et 3 usages d’IA encadrés par des règles.

<details><summary><strong>Quiz de validation : 6 questions (seuil 70 %)</strong></summary>

1. Que faut-il faire avant de déployer un CRM ?
2. Quelle est la première cause d’échec des projets CRM ?
3. Pourquoi le mode hors ligne est-il important ?
4. Que signifie la règle « ce qui n’est pas dans le CRM n’existe pas » ?
5. Quelle précaution prendre avec l’IA générative ?
6. Combien de champs obligatoires au démarrage d’un CRM ?

*Options, réponses et explications : back-office, rubrique Contenus.*

</details>

#### D6 · Leadership et gouvernance commerciale (60 min)

**Objectifs pédagogiques :** Formuler et partager une vision commerciale mobilisatrice ; Installer les instances de gouvernance commerciale ; Aligner ventes, marketing et finance autour d’objectifs communs ; Prévenir les risques éthiques et de conformité.

**Plan du cours :** vidéo résumé « Le directeur commercial, chef d’orchestre » (6 min) → L1. Le leadership du directeur commercial → L2. Les instances de gouvernance → L3. Alignement ventes-marketing-finance et éthique → quiz.

**Tableaux, schémas et matrices :** Une vision commerciale utile · Les 4 rôles du directeur commercial · Calendrier de gouvernance commerciale · Du conflit à l’alliance (« smarketing »).

**Étude de cas africaine :** le grand contrat et la « commission » demandée.

**Livrable :** Charte de gouvernance commerciale. Votre vision commerciale en une page, le calendrier annuel des instances (objet, participants, livrables), la grille de délégation des remises et la charte éthique commerciale.

<details><summary><strong>Quiz de validation : 6 questions (seuil 70 %)</strong></summary>

1. Qu’est-ce qui mesure le succès d’un directeur commercial ?
2. Quand faut-il envoyer l’ordre du jour et les chiffres d’un comité ?
3. Que signifie QBR ?
4. Comment réduire la friction « la finance bloque les remises » ?
5. Que faire face à une demande de « commission de facilitation » ?
6. Quel est le rôle de « stratège » du directeur commercial ?

*Options, réponses et explications : back-office, rubrique Contenus.*

</details>

---

## BLOC 5 : Stack technique, déploiement et indicateurs

### 5.1 Architecture technique

| Couche | Choix | Pourquoi |
|---|---|---|
| Front-end | Application web légère sans framework (HTML, CSS, JavaScript), installable (PWA) | ~100 Ko au chargement, rapide sur un smartphone d'entrée de gamme et en 3G |
| Back-end | Node.js 22 + Express | Simple, rapide, un seul langage, hébergeable partout |
| Base de données | **Phase 1** : SQLite intégré (aucune installation). **Avant la mise en ligne publique** : PostgreSQL sur **Supabase** (`db/schema.postgres.sql` fourni, RLS activé) | Démarrage immédiat, puis base gérée, sauvegardée et extensible |
| Authentification | E-mail + mot de passe (scrypt), sessions sécurisées. V2 : Supabase Auth avec OTP SMS ou WhatsApp | Les apprenants oublient souvent leur mot de passe : l'OTP par téléphone est plus adapté |
| Lecteur vidéo | Intégration à la demande (Bunny Stream recommandé : qualité adaptative 240p-720p, peu coûteux) | Économie de données, compatible connexions lentes |
| PDF | PDFKit côté serveur : certificats A4 paysage et cours complets | Génération instantanée, aucune dépendance externe |
| Paiement | **CinetPay** (Mobile Money + carte, UEMOA, CEMAC, RDC, Guinée) ; V2 : Stripe ou CMI pour le Maroc et l'euro, Wave Business en direct pour réduire les frais au Sénégal et en Côte d'Ivoire | Couverture maximale avec une seule intégration |
| Hébergement | Docker sur VPS, Render, Railway ou Fly.io, derrière HTTPS ; Supabase pour la base | Coût de départ faible, montée en charge progressive |
| Sécurité | CSP stricte, protection CSRF, limitation des tentatives, quiz corrigés côté serveur, revérification de chaque paiement auprès de CinetPay, codes d'accès hachés | Protection des revenus et de la valeur des certificats |
| Tests | 11 scénarios automatisés (inscription, quiz, certificats, paiements, paiement en 3 fois, codes, admin, PDF des 24 modules) | Chaque évolution est vérifiée avant mise en ligne |

Frais de paiement indicatifs (à confirmer par contrat) : agrégateurs multi-pays ~2,5 à 3,5 %, Wave en direct ~1 %, CMI au Maroc 1,5 à 2,5 %.

### 5.2 Calendrier de déploiement

| Phase | Période | Contenu | Critère de passage |
|---|---|---|---|
| **MVP** | ✅ Livré | Plateforme complète, 24 modules rédigés, paiement simulé, back-office | Tests automatisés au vert |
| **Pré-production** | Semaines 1-3 | Tournage des 24 vidéos résumé, logo et charte, nom du signataire, migration Supabase, compte marchand CinetPay, hébergement HTTPS, CGV et politique de confidentialité (ARTCI, CDP…) | Paiement réel de test réussi |
| **Bêta fermée** | Semaines 4-8 | 100 à 200 bêta-testeurs (Côte d'Ivoire, Sénégal, Cameroun) : réseau STFC, 2 entreprises partenaires. Accès offert par codes contre retours | Complétion F1 > 50 %, satisfaction > 8/10 |
| **Lancement vague 1** | Mois 3 | Ouverture publique, code −30 % pour les 500 premiers, ambassadeurs, campagnes Facebook, TikTok et WhatsApp | 1 000 inscrits, 50 ventes |
| **Croissance** | Mois 4-12 | Vagues 2 à 4, offre entreprises, OTP WhatsApp, langues locales, cohortes animées, demande d'agrément | Objectifs KPI ci-dessous |

### 5.3 Indicateurs de suivi

Tous ces indicateurs sont **calculés automatiquement** dans le back-office (`#/admin`).

| Indicateur | Définition | Cible à 6 mois |
|---|---|---|
| Taux de complétion | Modules validés ÷ modules commencés | > 50 % (contre 5 à 15 % pour un MOOC) |
| Taux de réussite aux quiz | Tentatives réussies ÷ tentatives | 60 à 75 % (au-delà, le quiz est trop facile) |
| Réussite du 1er coup | Modules validés à la 1re tentative | 40 à 60 % |
| Conversion gratuit → payant | Apprenants payants ÷ inscrits | 4 à 6 % |
| Rétention à 30 jours | Inscrits depuis plus de 30 jours revenus au cours des 30 derniers jours | > 35 % |
| Actifs à 7 et 30 jours | Apprenants connectés sur la période | Croissance mensuelle > 15 % |
| Chiffre d'affaires | Total, par mois, par offre | Panier moyen ≥ 55 000 FCFA |
| Certificats délivrés | Attestations + certificats de parcours | 2 000 |
| Statistiques par module | Démarrés, validés, score moyen, tentatives | Repérer les modules à améliorer |

---

## Sources et limites

**Limites :** il n'existe pas d'étude publique récente sur l'e-learning commercial en Afrique francophone. Les prix des plateformes, les frais des agrégateurs et les salaires viennent de comparatifs et d'enquêtes aux méthodes hétérogènes : ce sont des ordres de grandeur à **confirmer sur le terrain** (pré-enquête auprès de 50 commerciaux et 10 directions commerciales pendant la bêta).

- Plateformes : [Gartner (Coursera / LinkedIn Learning)](https://www.gartner.com/reviews/market/manager-and-leadership-training/compare/product/linkedin-learning-vs-coursera), [PeerSpot](https://www.peerspot.com/products/comparisons/coursera_vs_linkedin-learning), [DevOpsCube (Udacity)](https://devopscube.com/udacity-review-nanodegree/), [TechRadar (Udacity)](https://www.techradar.com/reviews/udacity), [Class Central (résiliation Udacity)](https://www.classcentral.com/report/?p=71255), [Bitdegree (Udacity vs Simplilearn)](https://www.bitdegree.org/online-learning-platforms/comparison/udacity-vs-simplilearn), [SchoolMaker (prix Kajabi)](https://www.schoolmaker.com/blog/kajabi-pricing), [Group.app (Kajabi 2026)](https://www.group.app/blog/kajabi-review/), [Software Advice (Kajabi)](https://www.softwareadvice.com/lms/kajabi-profile/), [MyEngineeringBuddy (Udemy)](https://www.myengineeringbuddy.com/blog/udemy-reviews-best-alternatives-pricing-offerings-in-2025/), [Formalive (OpenClassrooms)](https://www.formalive.fr/avis-openclassrooms/), [Capterra (Coorpacademy)](https://www.capterra.fr/software/172009/coorpacademy), [WeAreTech Africa (Kajou)](https://www.wearetech.africa/fr/fils/actualites/tech/kajou-leve-1-million-pour-developper-son-offre-de-contenu-numerique-de-formation-en-afrique)
- Usages : [Osiris (coût des données)](https://osiris.sn/en-afrique-subsaharienne-1-go-de-donnees-mobiles-represente-2-4-du-revenu.html), [TechAfricaNews (GSMA, adoption du smartphone)](https://techafricanews.com/?p=73682), [Meta WhatsApp Business Coach](https://cameroun24.net/article/60859-meta-lance-sur-whatsapp-des-formations-gratuites-destinees-aux-entrepreneurs-d-afrique-francophone.html), [étude RDC sur WhatsApp et l'enseignement](https://econpapers.repec.org/RePEc:hal:journl:hal-05103287)
- Mobile Money RDC : [CIO Mag (ARPTC)](https://cio-mag.com/rdc-la-penetration-de-la-telephonie-mobile-evaluee-a-62-au-deuxieme-trimestre-2024-arptc), [Africa Top Sports (marché RDC)](https://africatopsports.com/partenaires/comment-le-mobile-money-transforme-lavenir-des-paiements-numeriques-en-rdc/)
- Paiement : [Documentation CinetPay](https://docs.cinetpay.com/api/1.0-fr/checkout/notification), [Kolonell (agrégateurs)](https://kolonell.com/fr/blog/cinetpay-vs-paydunya-vs-paystack-comparatif-frais-2026), [Kolonell (CMI Maroc)](https://kolonell.com/fr/blog/cout-paiement-carte-cmi-site-pme-rabat-2026), [Medias24 (réforme des paiements au Maroc)](https://medias24.com/2025/05/20/paiement-electronique-les-etablissements-de-paiement-et-filiales-bancaires-autorises-a-operer-des-le-1er-mai-conseil-de-la-concurrence/)
- Prix et salaires : [Kolonell (formation à Abidjan)](https://kolonell.com/fr/blog/formation-negociation-freelance-abidjan-en-ligne-ou-presentiel-2026), [Paylab Côte d'Ivoire](https://www.paylab.com/ci/salaires/commerce/responsable-des-ventes?lang=fr), [Paylab Cameroun](https://www.paylab.com/cm/salaires/commerce/commercial?lang=fr), [Ndarinfo (salaires au Sénégal 2026)](https://www.ndarinfo.com/Remunerations-au-Senegal-cybersecurite-supply-chain-et-finance-dominent-le-palmares-2026_a45534.html)
- Complétion : [Skillademia](https://www.skillademia.com/?p=38908), [Ruzuku](https://www.ruzuku.com/learn/articles/cohort-vs-self-paced)
- Diplôme ou certificat : [SenCampus (agrément, habilitation, accréditation)](https://www.sencampus.com/dossiers/ecoles-privees-diplomes-reconnus/agrement-habilitation-accreditation), [SenCampus (diplôme ou certification)](https://www.sencampus.com/dossiers/etudier-le-numerique-au-senegal/diplome-ou-certification)
