# STFC Academy : guide technique

Plateforme SaaS de formation en performance commerciale, marketing et innovation, construite par StratFocus Consulting pour l'Afrique francophone.

## Démarrer en local

```bash
cd app
npm install
npm start
```

Ouvrez http://localhost:3000. Au premier démarrage, un compte administrateur de développement est créé : `admin@stfc.local` / `ChangeMoi-2026!`. En production, il est créé à partir de `ADMIN_EMAIL` et `ADMIN_PASSWORD`.

Pour lancer les tests (API complète, paiements simulés, génération des 24 PDF) :

```bash
npm test
```

## Architecture

| Élément | Choix | Fichier |
|---|---|---|
| Serveur | Node.js 22 + Express | `server.js` |
| Base de données | SQLite intégré à Node (développement), PostgreSQL / Supabase (production) | `src/db.js`, `db/schema.sql`, `db/schema.postgres.sql` |
| Comptes | E-mail + mot de passe (scrypt), session par cookie httpOnly, rôles apprenant / formateur / admin | `src/auth.js` |
| Contenu | Fichiers `content/` chargés en base au démarrage, puis éditables dans l'admin | `src/content.js` |
| Quiz | Corrigés côté serveur, les réponses ne sont jamais envoyées au navigateur | `src/api.js` |
| Paiement | CinetPay (Mobile Money + carte), mode simulation sans clés | `src/payments.js` |
| Tarifs | 5 zones régionales, affichage en monnaie locale + EUR, paiement en 3 fois | `src/pricing.js` |
| PDF | Certificats (A4 paysage) et cours complets (hors connexion) | `src/pdf.js` |
| Interface | Application web légère sans framework, installable (PWA), lecture hors connexion | `public/` |
| Back-office | Statistiques, utilisateurs, paiements, contenus, codes d'accès, certificats | `src/admin.js`, `public/assets/js/admin.js` |

## Sécurité intégrée

- Mots de passe hachés (scrypt), sessions stockées hachées en base, cookie `HttpOnly` + `SameSite=Lax` (+ `Secure` en production).
- Protection CSRF : toute écriture sur l'API doit être en JSON.
- En-têtes de sécurité (CSP stricte, anti-iframe, nosniff).
- Limitation des tentatives (connexion, inscription, codes, paiements).
- Paiements : la notification CinetPay n'est jamais crue sur parole, le serveur revérifie montant, devise et statut auprès de CinetPay. Le traitement est idempotent.
- Codes d'accès stockés uniquement sous forme d'empreinte SHA-256.

## Mise en production

1. Copier `.env.example` en `.env` et remplir les valeurs (URL publique, administrateur, clés CinetPay, WhatsApp, signataire).
2. Déployer avec Docker, sur un VPS ou sur Render, Railway ou Fly.io :
   ```bash
   docker build -t stfc-academy .
   ```
   ```bash
   docker run -d -p 3000:3000 --env-file .env -v stfc-data:/app/data stfc-academy
   ```
3. Placer le service derrière HTTPS (obligatoire pour le paiement, les cookies sécurisés et le mode hors connexion).
4. Dans l'espace marchand CinetPay, déclarer l'URL de notification : `https://<votre-domaine>/api/payments/notify`.

## Passage à Supabase (avant la mise en ligne publique)

Le code est préparé pour cette bascule :

1. Créer un projet Supabase (région Europe, la plus proche de l'Afrique de l'Ouest), puis exécuter `db/schema.postgres.sql` dans l'éditeur SQL. RLS est activé sans politique publique : seule l'application serveur accède aux données.
2. Réécrire uniquement `src/db.js` avec le pilote `pg` et la chaîne de connexion Supabase (variable `DATABASE_URL`) : remplacer les `?` par `$1, $2…`, rendre `all/get/run/tx` asynchrones et ajouter `await` dans les appelants. `INSERT OR IGNORE` (progression) devient `INSERT … ON CONFLICT DO NOTHING`, et `GROUP_CONCAT` (liste des utilisateurs dans l'admin) devient `string_agg`.
3. Migrer les données SQLite existantes (export CSV ou script) si des apprenants ont déjà été inscrits.
4. Étapes suivantes possibles : Supabase Auth (connexion par OTP SMS ou WhatsApp), Supabase Storage pour les vidéos compressées et les PDF.

## Modifier le contenu

- **Depuis l'admin** (`#/admin/contenus`) : titre, statut, vidéo, objectifs, livrable, leçons et quiz (JSON validé à l'enregistrement).
- **Depuis les fichiers** `content/modules/<ID>.js`, puis `npm run seed -- --force` (écrase les modifications faites dans l'admin).

Types de blocs disponibles dans une leçon :

| Type | Champs | Rendu |
|---|---|---|
| `p` | `x` | Paragraphe (`**gras**` accepté) |
| `h` | `x` | Sous-titre |
| `list` | `items[]` | Liste à puces |
| `steps` | `items[{title, x}]` | Étapes numérotées |
| `table` | `caption, head[], rows[[]]` | Tableau |
| `matrix` | `caption, x, y, q[4]{title, x}` | Matrice 2×2 (haut-gauche, haut-droite, bas-gauche, bas-droite) |
| `flow` | `caption, items[]` | Schéma de flux |
| `funnel` | `caption, items[{label, value}]` | Entonnoir avec taux de passage |
| `case` | `title, context, questions[], solution` | Étude de cas, corrigé masqué |
| `tip` / `action` | `x` | Encadré « À retenir » / « Et vous ? » |

Vidéos : renseigner `video.src` avec une URL d'intégration YouTube nocookie, Vimeo, Bunny Stream ou Cloudflare Stream, et `video.download` avec un MP4 240p compressé pour la lecture hors connexion.
