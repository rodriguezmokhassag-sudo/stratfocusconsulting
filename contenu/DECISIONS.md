# Workflow de contenu STFC — décisions validées

Mémoire du projet d'une session à l'autre. À relire avant chaque reprise.

## Contexte
- Cabinet : STRAT FOCUS CONSULTING (STFC), Pointe-Noire, République du Congo.
- Fuseau horaire : Africa/Brazzaville (UTC+1).
- Contact : 066 000 066 / 05 077 25 25 — admin@stratfocus-consulting.com.
- Offre de référence : catalogue STFC Academy, volet Salariés (40 modules, 4 parcours, Grille de positionnement 8 blocs / 210 points).

## Décisions
| Sujet | Décision |
|---|---|
| Contenu | Thématiques de fond utiles aux dirigeants (**pas d'actualité**) |
| Piliers | 6 : CA, force de vente, formation des commerciaux, organisation commerciale, marketing d'innovation, transformation digitale |
| Formats | conseil, méthode, erreur, checklist, question |
| Banque de thèmes | 100 thèmes (`banque_themes.csv`), rédigés par Claude, à valider ; l'IA en proposera de nouveaux quand la banque s'épuise |
| Fréquence | 10 posts / semaine : lundi à vendredi, 8 h 00 et 12 h 30 |
| IA texte | **Google Gemini** (`models/gemini-3.1-flash-lite`, offre gratuite) — DeepSeek abandonné (paiement par carte virtuelle impossible) |
| Images | Générateur à faible coût (Imagen 4 Fast / Nano Banana) + logo et bandeau posés par n8n (Edit Image) |
| Charte (provisoire) | Bleu marine ≈ #0B2468, or ≈ #C5A24A, noir ≈ #181818 — à confirmer avec le document de charte |
| Validation | Obligatoire avant publication : mail envoyé depuis dg@ vers **dg@stratfocus-consulting.com** (changé le 02/10 : les mails vers admin@ n’étaient pas lus) — 1 mail par jour groupant les 2 posts, réponse avant 12 h |
| Facebook | **Branché le 02/10/2026** : Page « Strat focus consulting » (ID `104316208239694`, facebook.com/longohamanofficiel), app Meta « STFC Publications n8n » (ID 1847472296617299), jeton de Page permanent dans l'identifiant n8n « Facebook Graph account ». Après « Valider » : post programmé à 8 h 00 / 12 h 30 (Graph API v25.0, `/feed`, `scheduled_publish_time`), ou publié tout de suite si le créneau est à moins de 15 min / passé. Texte seul pour l'instant. ⚠️ Accès aux données à renouveler tous les ~90 jours (prochaine échéance ≈ 30/12/2026). ⚠️ Jetons apparus sur des captures : nettoyage prévu (supprimer l'intégration puis régénérer sans capture) |
| TikTok | Pas de publication auto (audit TikTok requis) : script envoyé pour tournage manuel |
| LinkedIn | Phase 2 |
| Stockage | Google Sheet (onglets « Banque de thèmes » et « Historique ») — compte rodriguezmokhassag@gmail.com |
| Appel à l'action | Selon le pilier : P2/P3/P4 → Grille de positionnement **gratuite** + WhatsApp ; P1/P5/P6 → « Échangeons sur votre situation de dirigeant » + WhatsApp |
| Mobile Money | Cité seulement quand le sujet touche aux paiements / encaissements |
| Prompt en production | v3 (`contenu/prompt_expert_v3.md`) |
| Cas clients | **Interdiction** de citer les cas d'études (GCF, MBP Business, Ets LA DIFFÉRENCE) ou tout client réel |
| n8n | Version cloud |

## Planning hebdomadaire des piliers
| Jour | 8 h 00 | 12 h 30 |
|---|---|---|
| Lundi | P1 Chiffre d'affaires | P4 Organisation commerciale |
| Mardi | P2 Force de vente | P1 Chiffre d'affaires |
| Mercredi | P3 Formation des commerciaux | P2 Force de vente |
| Jeudi | P4 Organisation commerciale | P3 Formation des commerciaux |
| Vendredi | P5 Marketing d'innovation | P6 Transformation digitale |

Soit, par semaine : P1 à P4 × 2, P5 et P6 × 1 (banque : 20 thèmes pour P1 à P4, 10 pour P5 et P6 = 10 semaines).

## En attente
- [x] Numéro WhatsApp : 066 000 066 (+242)
- [ ] Logo PNG à fond transparent
- [ ] Document de charte graphique (couleurs exactes, police)
- [x] Accès à la Page Facebook (contrôle total)
- [x] ID de la Page STFC (104316208239694) + identifiant n8n « Facebook Graph account » (jeton de Page permanent)
- [x] Nettoyage sécurité : intégration supprimée le 02/10 (anciens jetons annulés), nouveau jeton de Page avec `pages_manage_posts` dans n8n, sans capture
- [ ] Renouveler l'accès aux données Meta avant ≈ 30/12/2026
- [x] Prompt v2 validé
- [x] Banque de thèmes validée
- [x] Google Sheet « STFC_Publications » (ID `1jsCTDFJ0_g-9IUHsxm8zkvw7ml6oXmXx4mXp6od7aug`) relié aux 3 nœuds Google Sheets — lecture testée OK (100 thèmes)
- [x] Clé API Google Gemini connectée (projet Google Cloud « STFC n8n », identifiant « Google Gemini(PaLM) Api account 2 ») — servira aussi aux images
- [x] Fuseau horaire : défaut n8n Africa/Douala = même heure que Brazzaville (UTC+1)
- [x] SMTP LWS connecté avec dg@stratfocus-consulting.com (test OK ; admin@ refusé : erreur 535)

## Workflows n8n
| Workflow | ID | État |
|---|---|---|
| Publications STFC – rédaction et validation quotidienne | `i8ltd8oSAq4FEoQZ` | **1er test complet réussi le 26/09/2026** (exécution n° 44 : T001 + T061 rédigés par Gemini, mail reçu, validés, Sheet mis à jour). **ACTIF depuis le 28/09/2026** (version « 802cd7bf », prompt v3, fuseau Africa/Brazzaville) — 1er envoi automatique : lundi 28/09 à 7 h (T002 + T062) |

Code source : `n8n/workflow_publications_stfc.js`.

## Étapes suivantes
1. Phase 1 (fait) : thèmes → rédaction Gemini → mail de validation → suivi dans Google Sheet.
2. Étape 2 : image (Gemini) + logo et bandeau STFC (Edit Image), jointe au mail.
3. Étape 3 (fait le 02/10/2026) : publication Facebook programmée après validation.
4. Phase 2 : LinkedIn, TikTok.

## Retours du 1er test (26/09/2026) — ajustements appliqués dans le prompt v3
- Offre inventée dans un script TikTok (« audit gratuit ») → interdire toute offre autre que la Grille de positionnement gratuite.
- Format checklist mélangé avec méthode + question → respecter strictement le format demandé.
- Thème « 10 questions » traité en 6 points → respecter les nombres annoncés dans le thème.
- Accroches identiques (« votre CA stagne ») et hashtags identiques → varier.

## Idée en cours d'étude
- Publier le lien vers la Grille de positionnement en **1er commentaire** des posts P2/P3/P4 (API Meta `/{post-id}/comments`, permission `pages_manage_engagement`) — nécessite l'accès à la Page + une version en ligne de la Grille.
- Formulaire Grille (Google Forms) validé : répondants = dirigeants, entrepreneurs, responsables commerciaux, commerciaux ; coordonnées = nom, entreprise, fonction, ville, WhatsApp, e-mail, domaine d'activité, taille de l'équipe commerciale. En attente : critères officiels des 8 blocs (42 critères notés 0-5 = 210 pts).

## Suivi de production
| Date | Exécution | Thèmes | Résultat |
|---|---|---|---|
| lun 28/09 | 46 | T002 + T062 | Mail envoyé, **sans réponse** (thèmes remis « à publier ») |
| mar 29/09 | 47 | P2 / P1 | **Sans réponse** |
| mer 30/09 | 48 | T041 + T021 | **Sans réponse** |
| jeu 01/10 | 49 | T062 + T041 | **Erreur** : Gemini 503 (surcharge) → aucun mail. Correctif : nouvelles tentatives automatiques (5 essais, 5 s) sur « Rédiger la publication », publié (version 6113656e) |
| ven 02/10 | — | — | Nœuds « Préparer la publication Facebook » + « Publier sur Facebook » ajoutés, workflow publié (version 4e9a3390) |
| ven 02/10 | 58 | test | ✅ Post de test programmé sur la Page (id 104316208239694_1542945591182088, lun 05/10 10 h) — à supprimer. Banque remise à zéro : T001/T061 repassés « à publier » (100 thèmes disponibles) |
