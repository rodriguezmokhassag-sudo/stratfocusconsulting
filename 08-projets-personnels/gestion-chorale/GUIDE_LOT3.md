# Gestion Chorale – Guide du lot 3 (patrimoine)

Le lot 3 gère tout le patrimoine de la chorale :

- inventaire valorisé avec amortissements ;
- prêts, réparations, pertes et sorties ;
- locations conformes à l'article 30, avec contrat et caution ;
- inventaires physiques et étiquettes ;
- synthèse pour le rapport patrimonial de l'AG.

Les lots 1 et 2 sont conservés ([GUIDE_LOT1.md](GUIDE_LOT1.md), [GUIDE_LOT2.md](GUIDE_LOT2.md)).

## 0. Passer au lot 3

Ouvrez le nouveau `GestionChorale.xlsm` en **Administrateur**, puis cliquez sur **PARAMETRES > Reprendre un ancien fichier** et choisissez votre fichier actuel (lot 1 ou lot 2).

- Le patrimoine existant est repris, et ses anciens codes `PAT-…` sont conservés.
- La durée d'amortissement est complétée selon la catégorie.
- Les nouvelles rubriques de caution sont ajoutées.

## 1. Mise en route

1. **CATEGORIES_PAT** : catégorie, **préfixe des codes** et **durée d'amortissement**. Vous pouvez ajouter des catégories (par exemple « Décoration » avec le préfixe DEC).

   | Catégorie | Préfixe | Durée d'amortissement |
   | --- | --- | --- |
   | Administration | ADM | 3 ans |
   | Matériel de musique | MUS | 5 ans |
   | Informatique | INF | 3 ans |
   | Mobilier | MOB | 5 ans |
   | Cuisine et kit de sortie | CUI | 3 ans |
   | Tenues et textiles | TEX | 3 ans |
   | Immobilier | IMM | 20 ans |

2. **PARAMETRES**, section « Patrimoine » :
   - caution de location : 30 % de la valeur des articles loués, avec un minimum de 10 000 FCFA ;
   - mois d'inventaire : juin et décembre (`6;12`) ;
   - ville utilisée sur les contrats.
3. **PATRIMOINE** : saisissez vos biens.
   - Tapez la **désignation** puis la **catégorie** : le **code** est créé automatiquement (`MUS-0012`).
   - Complétez :
     - marque et numéro de série ;
     - **quantité**, avec une seule fiche pour un lot (par exemple 40 chaises) ;
     - date et mode d'acquisition, et **valeur unitaire** (estimée pour un don) ;
     - **valeur de remplacement** (facultative) ;
     - état, localisation et gardien.
   - Pour un bien que l'on peut louer, mettez **Louable = OUI** et indiquez le **tarif par jour**.
4. **ETIQUETTES** > **Générer les étiquettes** (tous les biens, une catégorie ou un code), puis imprimez et collez une étiquette sur chaque bien.

**Actualiser les valeurs** recalcule :

- la valeur totale ;
- l'amortissement linéaire à date et la valeur nette ;
- les quantités sorties et disponibles.

## 2. Achats de matériel (lien avec la caisse)

Quand le Secrétaire aux Finances enregistre une **dépense d'achat de matériel** (rubriques `D04…`), l'application propose de **créer aussitôt la fiche du bien**. La valeur et la pièce de caisse sont reprises automatiquement.

Si ce n'est pas fait sur le moment, l'accueil signale les « achats de matériel sans fiche ». Le bouton **Créer depuis un achat** (feuille PATRIMOINE) rattrape l'oubli.

## 3. Prêts, réparations, pertes et sorties

Ces actions se lancent depuis la feuille **PATRIMOINE**, en sélectionnant la ligne du bien :

| Bouton | Effet |
| --- | --- |
| **Prêter** | Prêt à un membre (matricule) ou à une commission, avec une date de retour prévue. Validé par le seul Secrétaire aux Patrimoines. |
| **Réparation** | Le bien part chez le réparateur et son état passe à « À réparer ». |
| **Perte / sortie** | Perte ou vol, détérioration, ou sortie définitive (réforme, cession). |
| **Fiche du bien** | Toutes les informations du bien et l'historique de ses mouvements. |

**Les retours** se font sur **MOUVEMENTS_PAT** : sélectionnez la ligne, puis **Retour du matériel**. Vous indiquez l'état au retour. Pour une réparation, vous saisissez aussi son coût ; si vous avez les droits Finances, la dépense est enregistrée directement en caisse.

**Les pertes et détériorations** (art. 51) vont automatiquement au **registre des PERTES**, au nom du membre responsable s'il est indiqué. Le montant est la valeur de remplacement, ou la valeur d'achat à défaut. Le remboursement se suit comme au lot 2.

## 4. Locations de matériel (art. 30)

Les locations se gèrent sur la feuille **LOCATIONS**, en sélectionnant le contrat :

1. **Nouvelle demande** : locataire, contact, objet, dates.
2. **Ajouter un article** : seulement les biens « Louable = OUI ». Le **loyer** (tarif × jours × quantité) et la **caution** proposée se calculent automatiquement ; la caution reste modifiable.
3. **Approuver** : l'**avis de la commission musicale** et l'**accord du Bureau** (référence du PV) sont obligatoires.
4. **Encaisser (Finances)** : le Secrétaire aux Finances encaisse le loyer et la caution, et deux reçus sont émis.
5. **Remettre le matériel** : les articles sortent du stock disponible. Imprimez le **contrat** à faire signer.
6. **Retour du matériel** : vous indiquez l'état au retour et, en cas de dégâts, une **retenue sur la caution**.
7. **Restituer la caution (Finances)** :
   - la caution moins la retenue est rendue ;
   - la retenue devient une recette « Indemnités pour dégâts » ;
   - le contrat est clôturé.

**Refuser** annule une demande. Une étape faite dans le désordre est bloquée, avec un message qui explique pourquoi.

## 5. Inventaire physique (juin et décembre)

Sur la feuille **INVENTAIRE** :

1. **Préparer l'inventaire** liste les biens avec la **quantité attendue** : la quantité en stock, moins les articles prêtés, loués ou en réparation.
2. **Imprimer la feuille de comptage**, puis comptez sur place.
3. Saisissez la **quantité comptée** et l'**état constaté**.
4. **Valider l'inventaire** :
   - les quantités sont corrigées ;
   - les manquants sont inscrits au registre des **PERTES** ;
   - le résultat est archivé dans **INVENTAIRES**.

L'accueil rappelle l'inventaire en juin et en décembre, ou s'il date de plus de 7 mois.

## 6. Synthèse pour l'AG

**SYNTHESE_PAT** > **Calculer** donne, pour chaque catégorie et au total :

- le nombre de fiches et les quantités ;
- la valeur d'acquisition, l'amortissement cumulé et la valeur nette ;
- la valeur de remplacement.

À droite figurent l'**évolution de la valeur nette** sur 5 ans et les points d'attention :

- biens à réparer ;
- biens totalement amortis ;
- retours en retard ;
- achats sans fiche.

## 7. Droits

| Rôle | Patrimoine, prêts, inventaire | Locations | Encaissement et restitution des cautions |
| --- | --- | --- | --- |
| Secrétaire aux Patrimoines | Modifie | Demande, approuve, remet, reprend | – (sauf en intérim des Finances) |
| Secrétaire aux Finances | Consulte | Consulte | Oui |
| Administrateur | Modifie | Toutes les étapes | Oui |
| 1er Responsable, Vice-Responsable, Consultation | Consultent | Consultent | – |
