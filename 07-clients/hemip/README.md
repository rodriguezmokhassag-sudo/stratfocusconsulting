# HEMIP — site internet

Site de la **Haute École de Management et de l'Ingénierie La Percée (HEMIP)**, établissement privé d'enseignement supérieur à Pointe-Noire (agrément n° 0454 MES-CAB.DGESUP.DAAC).

Objectif du cahier des charges : vendre l'école sur internet, augmenter le trafic, attirer de nouveaux partenaires, renforcer la crédibilité et imposer HEMIP comme école de proximité et de référence.

## Contenu du dossier

| Élément | Rôle |
|---|---|
| `site/` | Le site prêt à mettre en ligne (HTML statique, sans base de données) |
| `site/en/` | Version anglaise |
| `site/css/style.css` | Styles. Seules les couleurs du logo sont utilisées : bleu `#0093DD`, rouge `#DA251C`, noir `#212121` et blanc |
| `site/js/main.js` | Menu mobile, filtres des filières, envoi des formulaires sur WhatsApp |
| `site/img/` | Logo, favicon, photos |
| `site/img/partenaires/` | Logos des écoles partenaires (ENGDE, HESTIM, ISTA, IPSAS, ORAGEU) |
| `site/img/entreprises/` | Logos des 10 entreprises (CORAF, SNPC, TotalEnergies, Eni, Perenco, Dangote, Saris Congo, LCDE, E2C, Brasco). Une entreprise sans fichier logo s'affiche avec son nom |
| `source/build.py` | **Tout le contenu FR + EN.** On modifie un texte ici, puis on lance `python3 build.py` |

## Pages (24 au total, 12 par langue)

| Français | Anglais | Contenu |
|---|---|---|
| `index.html` | `en/index.html` | Accueil : héros, accès rapides, chiffres clés, 10 raisons, entreprises |
| `vision.html`, `mission.html`, `valeurs.html`, `mot-du-directeur.html`, `campus.html` | `en/vision.html`, `en/mission.html`, `en/values.html`, `en/director.html`, `en/campus.html` | Sous-menu de l'onglet Accueil : une page par rubrique |
| `filieres.html` | `en/programs.html` | Les 15 licences avec leurs débouchés, un filtre par parcours et la formation continue |
| `recherche.html` | `en/research.html` | 6 axes de recherche et 4 secteurs de services aux entreprises |
| `vie-etudiante.html` | `en/student-life.html` | Soutenances, visites en entreprise, excursions, fêtes scolaires, stages, témoignages |
| `partenaires.html` | `en/partners.html` | ENGDE, HESTIM, ISTA, IPSAS, ORAGEU, entreprises, formulaire « Devenir partenaire » |
| `admissions.html` | `en/admissions.html` | 4 étapes, conditions, bourses, formulaire de pré-inscription |
| `contact.html` | `en/contact.html` | Coordonnées, formulaire, plan Google Maps |

## Bandeau supérieur

La mention d'agrément défile lentement de gauche à droite (pause au survol). Le téléphone et l'e-mail restent dans le pied de page et sur la page Contact.

## Formulaires

Les 3 formulaires (pré-inscription, partenariat, contact) ouvrent un message WhatsApp pré-rempli vers le **+242 05 586 50 94**, sans serveur ni abonnement. Pour changer de numéro, modifier `WHATSAPP` en haut de `site/js/main.js` et `WA` dans `source/build.py`.

Le bouton « Je suis intéressé(e) » d'une filière ouvre la pré-inscription avec cette filière déjà choisie (`admissions.html?filiere=GL`).

## À fournir par l'école (emplacements prévus)

Les emplacements hachurés « Photo à venir » et les cartes « Témoignage à venir » sont à remplacer. Il suffit de chercher `a-remplacer` ou `EMPLACEMENT À REMPLACER` dans `source/build.py`.

- [ ] Photos réelles : campus, laboratoire de génie des procédés, soutenances, visites en entreprise, excursions, fêtes scolaires
- [ ] Portrait, nom et message du directeur général
- [ ] 3 témoignages (alumni, stagiaire, finaliste) avec nom, filière et promotion
- [ ] Date de la prochaine rentrée : réglage `RENTREE` dans `build.py` (elle s'affiche alors au-dessus du titre de l'accueil)
- [ ] Lien de la page Facebook : réglage `FACEBOOK`
- [ ] Nom de domaine définitif : réglage `DOMAINE` (sert à `sitemap.xml`, `robots.txt` et aux balises de partage)
- [ ] Faire valider : conditions d'admission (bac ou équivalent), « Licence · 3 ans » sur chaque filière, liste des entreprises partenaires

## Sources du contenu

Le contenu vient du cahier des charges *PROJET LANCER LE SITE INTERNET DE HEMIP* (docx), du flyer HEMIP (agrément, partenaires, 15 filières et leurs débouchés, coordonnées, slogan) et de la présentation digitale du 24/07/2026 (vision, mission, 10 raisons, recherche, stages). Aucune présence en ligne existante de HEMIP n'a été trouvée lors des recherches (novembre 2026).

Les choix de structure s'inspirent des bonnes pratiques relevées sur les sites d'universités : filières et admissions accessibles dès le haut de page, boutons d'action répétés après chaque section, navigation Formations / Admissions / L'école / Vie étudiante / Contact.

## Mise en ligne

Il s'agit d'un site statique, compatible avec n'importe quel hébergeur (LWS, Hostinger, o2switch, Netlify…) :
1. Déposer **tout le contenu de `site/`** à la racine de l'hébergement (`htdocs` ou `public_html`).
2. Activer le certificat SSL (Let's Encrypt).
3. Déclarer `sitemap.xml` dans Google Search Console et créer la fiche Google Business Profile de l'école.
