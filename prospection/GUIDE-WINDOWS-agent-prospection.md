# Agent de prospection STFC : guide d'installation pour Windows

Ce guide reprend la démarche de Konno Fuente Academy (guide écrit pour Mac) et l'adapte à un **PC Windows**.
Il ne garde que l'essentiel. Les blocs **« À copier dans Claude »** se collent tels quels : remplacez seulement ce qui est entre crochets `[ ]`.

> Cette version de l'application prospecte **par e-mail** (premier message et 2 relances).
> Elle ne contient pas WhatsApp/Geskap : ignorez la partie 6 du guide Mac.

---

## Où j'en suis

| # | Étape | État |
|---|---|---|
| 1 | Claude Desktop installé (abonnement Pro) | ✅ fait |
| 2 | Node.js v24 installé, puis PC redémarré | ✅ fait |
| 3 | Dossier placé dans `C:\Users\PC\agent-prospection` | ✅ fait |
| 4 | Claude Desktop installe l'application | ⏳ **à faire maintenant** |
| 5 | Connexions : clé Serper et Gmail | ⬜ |
| 6 | Mon entreprise : décrire l'offre STFC | ⬜ |
| 7 | Premier passage test | ⬜ |
| 8 | Relire et valider les e-mails | ⬜ |
| 9 | Passages automatiques (Planificateur Windows) | ⬜ |

⚠️ **Sur Windows : ne double-cliquez jamais sur `setup.command`.** Ce fichier est fait pour Mac.

---

## Étape 4 : faire installer l'application par Claude Desktop

1. Ouvrez **Claude Desktop** : l'application, pas le navigateur.
2. Cliquez sur l'onglet **Code**, puis sur **+ New**.
3. Sous la zone de message, choisissez **Local**, puis le dossier **`C:\Users\PC\agent-prospection`**.
4. Collez :

> **À copier dans Claude**
> ```
> Installe cette application sur mon PC Windows. Elle a été écrite pour Mac : n'exécute pas setup.command.
> Fais à la place, étape par étape, en m'expliquant simplement :
> 1) vérifie que Node.js 24 ou plus est installé ;
> 2) vérifie que la commande « claude » existe, sinon installe Claude Code avec l'installateur officiel Windows ;
> 3) lance « npm install » puis « npx playwright install chromium » ;
> 4) copie .env.example en .env sans y mettre de clé ;
> 5) vérifie qu'aucune variable ANTHROPIC_API_KEY n'existe ;
> 6) démarre l'interface (node src/server.js) en arrière-plan et ouvre http://localhost:4300 dans mon navigateur.
> Ne touche pas encore aux passages automatiques. Respecte le fichier CLAUDE.md.
> ```

5. Lisez chaque demande d'autorisation, puis acceptez-la.
6. **Résultat attendu :** la page **http://localhost:4300** s'ouvre dans le navigateur. Ajoutez-la à vos favoris.

---

## Étape 5 : vos clés (onglet « Connexions »)

Ouvrez **http://localhost:4300**, puis l'onglet **Connexions**.

### Claude
Si la carte Claude indique « Non connecté », cliquez sur **Connecter**. Une fenêtre noire s'ouvre : terminez la connexion dans le navigateur, avec votre compte Claude habituel.

### Serper (indispensable)
1. Créez le compte : **https://serper.dev/signup** (gratuit, 2 500 recherches, sans carte bancaire).
2. Copiez la clé sur **https://serper.dev/api-keys**.
3. Collez-la dans la carte **Serper**, **sans espace**, puis cliquez sur **Enregistrer**.

### E-mail d'envoi (Gmail recommandé)
1. Activez la validation en deux étapes : **https://myaccount.google.com/signinoptions/twosv**
2. Créez un mot de passe d'application : **https://myaccount.google.com/apppasswords**. Nom : `Prospection`, puis **Créer**.
3. Copiez les **16 lettres**.
4. Dans la carte e-mail, renseignez l'adresse Gmail, collez les 16 lettres comme mot de passe et indiquez le nom d'expéditeur, par exemple `[Rodriguez MOKHASSA – STFC]`. Cliquez ensuite sur **Enregistrer**.

### Vérifier
Cliquez sur **Tester les connexions**, ou collez dans Claude Desktop :

> **À copier dans Claude**
> ```
> Vérifie toutes mes connexions et explique-moi ce qui ne va pas.
> ```

🔒 Ne partagez jamais vos clés : pas dans un chat, pas en capture d'écran. Elles restent sur votre PC, dans le fichier `.env`.

---

## Étape 6 : décrire votre offre (onglet « Mon entreprise »)

1. Dans la grande case de texte, collez le modèle ci-dessous, puis **complétez ou corrigez les `[ ]`**.
2. Dans **Pays des prospects**, choisissez **Congo**. Dans **Langue**, choisissez **français**.
3. Cliquez sur **Préparer ma configuration avec Claude**.
4. **Relisez** l'offre et les cibles proposées, corrigez-les, puis cliquez sur **Enregistrer**.

> **À coller dans « Mon entreprise », puis compléter les [ ]**
> ```
> Mon objectif : proposer mes services.
> Je m'appelle [Rodriguez MOKHASSA], [fondateur / consultant] de Stratfocus Consulting (STFC), cabinet basé à [Pointe-Noire].
> STFC accélère les petites et micro-entreprises (PME/TPE) : performance commerciale et stratégie marketing.
> Je propose aux [commerces, restaurants, hôtels, cliniques, agences, PME de services…] :
> - [STFC Audit : diagnostic commercial et marketing de l'entreprise] ;
> - [STFC Croissance : plan d'action commercial, prospection, suivi des ventes] ;
> - [STFC Digitalisation : présence en ligne, réseaux sociaux, outils de vente].
> Ce que ça leur apporte : [plus de clients, des ventes mieux suivies, une meilleure visibilité].
> Ce qui me distingue : [connaissance du marché local, accompagnement terrain, formations STFC Academy].
> Je peux offrir gratuitement pour ouvrir la conversation : [un mini-audit de 30 minutes / un conseil concret sur leur page Google ou Facebook].
> Villes visées : [Pointe-Noire], pays : Congo.
> Mes contacts publics : [site web], [téléphone], [e-mail].
> Ton : vouvoiement, [chaleureux et professionnel]. Jamais de prix dans le premier message.
> ```

💡 Commencez avec **une seule ville**. Vous en ajouterez d'autres plus tard (Brazzaville, Kinshasa, Libreville…).

---

## Étape 7 : premier passage test

Onglet **Tableau de bord**, puis **Lancer maintenant**. Vous pouvez aussi coller dans Claude Desktop :

> **À copier dans Claude**
> ```
> Lance un passage sur 5 entreprises et dis-moi ce qui a été trouvé.
> ```

Si aucune entreprise n'est trouvée :

> **À copier dans Claude**
> ```
> Aucune entreprise n'a été trouvée. Vérifie mes villes, mon pays (Congo) et le plafond Serper du jour, puis explique-moi simplement.
> ```

---

## Étape 8 : relire et valider

Onglet **À valider** : relisez chaque e-mail, corrigez-le si besoin, puis cliquez sur **Valider**. **Rien ne part sans votre validation.**
Les premiers jours, faites un passage par jour, avec **5 à 10 entreprises** au maximum.

---

## Étape 9 : passages automatiques (Windows)

⚠️ **Sur Windows :** le bouton « Installer le planificateur » de l'onglet Réglages ne fonctionne que sur Mac. Faites-le faire par Claude Desktop **seulement quand les étapes 5 à 8 marchent bien** :

> **À copier dans Claude**
> ```
> Sur mon PC Windows, crée avec le Planificateur de tâches Windows (sans droits administrateur si possible) :
> 1) une tâche qui démarre l'interface (node src/server.js dans ce dossier) à l'ouverture de ma session ;
> 2) une tâche qui lance « node src/cli.js tick » chaque jour à [09:00] et [16:00].
> Utilise le chemin exact de node. Montre-moi comment les voir et comment les supprimer.
> ```

Le PC doit être **allumé** aux heures prévues.

---

## Messages utiles à donner à Claude Desktop

Ouvrez toujours Claude Desktop, puis l'onglet **Code**, une session **Local**, et le dossier **`C:\Users\PC\agent-prospection`**.

| Besoin | À copier dans Claude |
|---|---|
| Voir où j'en suis | `Montre-moi l'état de mon agent de prospection : objectif, cibles, clés configurées et messages à valider.` |
| La page localhost:4300 ne répond plus | `Relance l'interface de prospection et ouvre-la dans mon navigateur.` |
| Ajouter des villes | `Ajoute les villes [ville 1] et [ville 2] à mes cibles.` |
| Changer de cible | `Je veux aussi cibler [type d'entreprises]. Propose-moi les recherches Google Maps adaptées et ajoute-les.` |
| Améliorer mon offre | `Relis mon offre et propose-moi une version plus claire. Ce que je peux offrir gratuitement : [audit, conseil…].` |
| Joindre ma plaquette | `Joins mon [flyer / plaquette] à mes e-mails : c'est le fichier [nom du fichier], dans mes Téléchargements.` |
| Un problème | `Mon application de prospection a un problème : [décrivez ce que vous voyez]. Trouve la cause et répare-la avec moi.` |

---

## Si quelque chose ne marche pas

| Ce que vous voyez | Ce qu'il faut faire |
|---|---|
| `http://localhost:4300` ne répond pas | Message « Relance l'interface… » ci-dessus. |
| Pas d'onglet **Code** dans Claude Desktop | Mettez à jour Claude Desktop depuis https://claude.ai/download. |
| Claude ne trouve pas le dossier | Session **+ New**, puis **Local**, puis `C:\Users\PC\agent-prospection`. |
| Clé Serper refusée | Recopiez-la en entier depuis https://serper.dev/api-keys, sans espace. |
| E-mail : « mot de passe refusé » | Utilisez le **mot de passe d'application** Gmail (16 lettres), pas votre mot de passe habituel. |
| « Infos insuffisantes » partout | Ces entreprises ne publient pas d'e-mail : visez d'autres types d'entreprises ou d'autres villes. |
| Limite Claude atteinte | Votre abonnement a atteint sa limite. Les analyses reprennent seules au passage suivant. |

---

## Règles d'une bonne prospection
- Seules les adresses **publiées par les entreprises** sont contactées. Chaque e-mail contient la mention **STOP**.
- Donnez de la valeur avant de demander quelque chose : mini-audit, conseil concret.
- Soyez précis sur la cible : « restaurants indépendants de Pointe-Noire » marche mieux que « entreprises ».
- Relisez chaque message les premiers jours, et répondez vite aux personnes qui vous écrivent.
- Montez progressivement : 5 à 10 entreprises par jour au début.
