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
| IA texte | DeepSeek (déjà utilisé dans n8n) |
| Images | Générateur à faible coût (Imagen 4 Fast / Nano Banana) + logo et bandeau posés par n8n (Edit Image) |
| Charte (provisoire) | Bleu marine ≈ #0B2468, or ≈ #C5A24A, noir ≈ #181818 — à confirmer avec le document de charte |
| Validation | Obligatoire avant publication : mail envoyé depuis dg@stratfocus-consulting.com (SMTP) vers admin@stratfocus-consulting.com (1 mail par jour groupant les 2 posts) |
| Facebook | Publication auto après validation — **bloqué** : l'utilisateur n'est pas administrateur de la Page |
| TikTok | Pas de publication auto (audit TikTok requis) : script envoyé pour tournage manuel |
| LinkedIn | Phase 2 |
| Stockage | Google Sheet (onglets « Banque de thèmes » et « Historique ») — compte rodriguezmokhassag@gmail.com |
| Appel à l'action | Grille de positionnement **gratuite** + WhatsApp |
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
- [ ] Accès à la Page Facebook (contrôle total ou création de contenu via Meta Business Suite)
- [x] Prompt v2 validé
- [x] Banque de thèmes validée
- [x] Google Sheet « STFC_Publications » (ID `1jsCTDFJ0_g-9IUHsxm8zkvw7ml6oXmXx4mXp6od7aug`) relié aux 3 nœuds Google Sheets — lecture testée OK (100 thèmes)
- [ ] Clé API DeepSeek dans n8n
- [ ] Identifiants SMTP LWS dans n8n : utiliser dg@stratfocus-consulting.com (admin@ refusé : erreur 535)
- [ ] Clé API Google Gemini (images, étape 2)

## Workflows n8n
| Workflow | ID | État |
|---|---|---|
| Publications STFC – rédaction et validation quotidienne | `i8ltd8oSAq4FEoQZ` | Créé, inactif — en attente des identifiants (Google Sheets, DeepSeek, SMTP) |

Code source : `n8n/workflow_publications_stfc.js`.

## Étapes suivantes
1. Phase 1 (fait) : thèmes → rédaction DeepSeek → mail de validation → suivi dans Google Sheet.
2. Étape 2 : image (Gemini) + logo et bandeau STFC (Edit Image), jointe au mail.
3. Étape 3 : publication Facebook automatique après validation (dès l'accès à la Page).
4. Phase 2 : LinkedIn, TikTok.
