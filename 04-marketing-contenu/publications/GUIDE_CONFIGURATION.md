# Guide de configuration des accès (workflow Publications STFC)

Ordre conseillé, du plus simple au plus long. Le workflow est dans n8n :
https://n8n-academy.konnofuente.com/workflow/i8ltd8oSAq4FEoQZ

Principe dans n8n : ouvrir le nœud concerné > champ **Credential** > **Create new credential** >
remplir > **Save** (n8n teste la connexion et affiche une coche verte si tout va bien).

---

## 1. Boîte mail LWS (SMTP) — 5 min

Nœud : **Demander la validation par mail**

| Champ | Valeur |
|---|---|
| User | `admin@stratfocus-consulting.com` (adresse complète) |
| Password | mot de passe de la boîte mail |
| Host | `mail.stratfocus-consulting.com` |
| Port | `465` |
| SSL/TLS | activé |

Si la connexion échoue : vérifier dans l'espace client LWS (Emails > configuration) le nom exact
du serveur SMTP indiqué pour le domaine, ou essayer le port `587` avec SSL/TLS désactivé (STARTTLS).

## 2. DeepSeek (rédaction des textes) — 10 min

Nœud : **DeepSeek** (sous « Rédiger la publication »)

1. Créer un compte sur https://platform.deepseek.com
2. Recharger un petit crédit : https://platform.deepseek.com/top_up
   (coût estimé : quelques centimes par mois pour ~40 publications).
3. Créer une clé : https://platform.deepseek.com/api_keys > **Create new API key** (nom : `n8n STFC`).
4. **Copier la clé immédiatement** (elle ne sera plus affichée).
5. Dans n8n : coller la clé dans le champ **API Key** > Save.

## 3. Google Sheets — 30 min

Nœuds : **Lire la banque de thèmes**, **Marquer les thèmes utilisés**, **Ajouter à l'historique**
(une seule connexion, réutilisée dans les 3 nœuds).

### 3.1 Préparer le fichier
1. Se connecter à https://sheets.google.com avec le compte Google choisi.
2. Créer un fichier **STFC – Publications**.
3. Onglet 1 renommé **Banque de thèmes** : Fichier > Importer > `banque_themes.csv`
   > « Remplacer la feuille actuelle ».
4. Onglet 2 nommé **Historique**, ligne 1 :
   `date | creneau | id_theme | pilier | theme | format | decision | titre_visuel | facebook_post | tiktok_script | image_prompt`

### 3.2 Connexion dans n8n
Ouvrir le nœud **Lire la banque de thèmes** > Credential > Create new.

- **Cas A — un bouton « Sign in with Google » apparaît directement** : cliquer, choisir le compte,
  accepter. Terminé.
- **Cas B — n8n demande un Client ID et un Client Secret** (instance auto-hébergée) :
  1. Copier l'**OAuth Redirect URL** affichée par n8n
     (normalement `https://n8n-academy.konnofuente.com/rest/oauth2-credential/callback`).
  2. https://console.cloud.google.com > créer un projet **STFC n8n**.
  3. **API et services > Bibliothèque** : activer **Google Sheets API** et **Google Drive API**.
  4. **Écran de consentement OAuth** (ou « Google Auth Platform ») :
     type **Externe**, nom de l'application `STFC n8n`, adresse de contact,
     puis ajouter votre adresse Gmail dans **Utilisateurs test**.
  5. **Identifiants > Créer des identifiants > ID client OAuth** :
     type **Application Web**, dans **URI de redirection autorisés** coller l'URL copiée à l'étape 1.
  6. Copier **Client ID** et **Client Secret** dans n8n > **Sign in with Google** > accepter.
  7. Important : tant que l'application Google est en mode **Test**, la connexion expire au bout
     de 7 jours. Pour l'éviter : écran de consentement > **Publier l'application** (passage
     « En production »). Google affichera un avertissement « application non validée » lors de la
     connexion : cliquer sur **Paramètres avancés > Accéder à STFC n8n**, c'est normal pour un
     usage interne.

### 3.3 Choisir le fichier
Dans chacun des 3 nœuds Google Sheets : **Document** > choisir **STFC – Publications**.

## 4. Fuseau horaire du workflow — 1 min
Workflow > menu **⋯** > **Settings** > **Timezone** = `Africa/Brazzaville` > Save.

## 5. Google Gemini (images) — étape 2, plus tard
https://aistudio.google.com/apikey > **Create API key**. La génération d'images peut nécessiter
d'activer la facturation sur le projet Google Cloud.

---

Sources :
- n8n — Google OAuth2 single service : https://docs.n8n.io/integrations/builtin/credentials/google/oauth-single-service
- n8n — nœud Google Sheets : https://docs.n8n.io/integrations/builtin/app-nodes/n8n-nodes-base.googlesheets
- LWS — ports IMAP/POP/SMTP : https://help.lws.net/en/Which-ports-to-use-to-configure-an-email-address
- LWS — choisir le port SMTP : https://tutoriels.lws.fr/e-mail/port-smtp
- DeepSeek — tarifs : https://api-docs.deepseek.com/quick_start/pricing/
