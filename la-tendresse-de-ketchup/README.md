# Restaurant-Bar La Tendresse de Ketchup — Kit de gestion

Documentation complète pour piloter le restaurant-bar **La Tendresse de Ketchup**
(Quartier Diata, Brazzaville, République du Congo) : affiches, formulaires de caisse,
d'achats, de stocks, de crédits et de personnel, classeur Excel de pilotage et modèles Word.

Monnaie : **FCFA**. Paiements prévus : espèces, MTN Mobile Money, Airtel Money.

## Contenu de `sortie/`

| Dossier | Contenu | Usage |
|---|---|---|
| `LIASSE_COMPLETE_…pdf` | Tous les modèles et affiches en un seul PDF | Présentation au client, archive |
| `1_Affiches/` | 9 affiches A4 paysage + planche de 10 coupons « Bon pour revenir demain » | Impression couleur, plastification |
| `2_Modeles_vierges/` | 22 formulaires, N° à remplir à la main | **Maquettes pour l'imprimeur** (carnets à souches) et photocopies |
| `3_Carnets_numerotes/` | 9 formulaires pré-numérotés de 0001 à 0050 | Impression maison, prêts à agrafer en carnets |
| `4_Excel_pilotage/` | Classeur : caisse, clôtures, stocks, crédits, avances, tableau de bord + graphique | Saisie chaque soir et synthèse mensuelle automatique |
| `0_Propositions_branding/` | Planche A4 des 4 pistes de branding | Choix de l'identité visuelle |
| `6_HTML/` | Version HTML autonome (polices intégrées) des affiches, formulaires et propositions ; `index.html` pour tout parcourir | Ouvrir dans un navigateur, imprimer en A4 sans marges, arrière-plans activés |
| `5_Word_modifiables/` | Reconnaissance de dette, règlement clients, règles du personnel, facture, lettre de relance | Textes à adapter librement |

### Affiches (A4 paysage, pied de page « Restaurant-Bar La Tendresse de Ketchup — La Direction »)
1. Ne profitez pas de nos relations pour me faire tomber
2. Le crédit ? Bon pour revenir demain
3. Il faisait crédit à ses clients… (Retour au village)
4. Pas d'alcool aux moins de 18 ans
5. Ici, on paie à la commande
6. Surveillez vos affaires (objets oubliés)
7. Règlement intérieur
8. Carte des prix (à remplir)
9. Horaires d'ouverture (à remplir)

### Formulaires
| N° | Document | Format | Numéroté |
|---|---|---|---|
| 00 | Routine de gestion (qui fait quoi, quand) | A4 | — |
| 01 | Reçu de caisse avec talon | 3 par A4 | ✓ |
| 02 | Addition de table | 2 par A4 (bandes verticales) | ✓ |
| 03 | Facture | A4 | ✓ |
| 04 | Pièce de caisse — Entrée, avec talon | 2 par A4 | ✓ |
| 05 | Pièce de caisse — Sortie, avec talon | 2 par A4 | ✓ |
| 06 | Brouillard de caisse journalier | A4 paysage | — |
| 07 | Clôture de caisse (billetage FCFA, MoMo, rapprochement) | A4 | — |
| 08 | Bordereau de versement (banque / coffre) | 2 par A4 | ✓ |
| 09 | Bon de commande fournisseur (avec emballages consignés) | A4 | ✓ |
| 10 | Bon de réception | A4 | — |
| 11 | Fiche de stock par article | A4 | — |
| 12 | Inventaire hebdomadaire | A4 paysage | — |
| 13 | Registre des casses et pertes | A4 | — |
| 14 | Bon de sortie interne (offerts, consommation du personnel) | 3 par A4 | ✓ |
| 15 | Registre des crédits clients | A4 paysage | — |
| 16 | Reconnaissance de dette | A4 | — |
| 17 | Planning hebdomadaire | A4 paysage | — |
| 18 | Fiche de présence mensuelle | A4 paysage | — |
| 19 | Bon d'avance sur salaire | 2 par A4 | ✓ |
| 20 | Fiche de paiement de salaire | A4 | — |
| 21 | Tableau de bord mensuel | A4 paysage | — |

## Compléter les informations et régénérer

Les coordonnées encore inconnues (rue, téléphone, RCCM, NIU…) apparaissent en pointillés.
Pour les intégrer partout d'un coup :

1. Ouvrir `generateur/config.py` et remplir les champs à `None`.
2. Lancer :

```bash
pip install openpyxl python-docx pypdf pypdfium2   # une seule fois
python3 generateur/build.py                        # tout régénérer
python3 generateur/build.py --pdf --debut 51 --taille 50   # carnets suivants : N° 0051 à 0100
```

La génération des PDF utilise Chromium (variable `CHROMIUM` si le chemin n'est pas trouvé).

## Charte graphique

- Rouge ketchup `#C8102E`, bordeaux `#7E0A1E`, crème `#FFF4E2`, moutarde `#F2B705`, encre `#231A17`
- Polices : Playfair Display (italique), Bebas Neue, Work Sans (licence SIL OFL, dans `assets/fonts/`)
- Logo : cœur-goutte de ketchup dans un badge, `assets/logo_la_tendresse_de_ketchup.svg` / `.png`

## Points à faire valider

- Coordonnées, RCCM et NIU : à insérer dès réception.
- Âge minimum pour l'alcool (18 ans retenu) : à confirmer selon la réglementation congolaise en vigueur.
- Si un employé est déclaré à la CNSS, la fiche de paiement interne ne remplace pas le bulletin de paie réglementaire.
- Si l'établissement est assujetti à la TVA, ajouter les lignes de taxe sur la facture.
