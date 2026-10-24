# Gestion Chorale – Guide du lot 2 (finances)

Le lot 2 ajoute la gestion financière : caisses, journal, reçus, cotisations, pénalités, cotisations spéciales, caisse sociale, budget annuel avec suivi des écarts, arrêtés de caisse, pertes et clôture d'exercice. Tout ce qui existait au lot 1 est conservé ([GUIDE_LOT1.md](GUIDE_LOT1.md)).

## 0. Passer du lot 1 au lot 2 (si vous avez déjà saisi des données)

Chaque lot est livré dans un nouveau fichier. Pour récupérer vos données :

1. Ouvrez le nouveau fichier `GestionChorale.xlsm` et connectez-vous en **Administrateur** (mot de passe provisoire `chorale`).
2. Feuille **PARAMETRES** > bouton **Reprendre un ancien fichier**, puis choisissez votre ancien fichier.
3. La reprise copie les membres, dossiers d'adhésion, séances, présences, patrimoine, journal des actions, listes et paramètres. Elle reprend aussi les rôles avec leurs mots de passe, ainsi que le logo.
4. Enregistrez, fermez, rouvrez et reconnectez-vous avec vos mots de passe habituels.

## 1. Mise en route des finances (une seule fois)

1. **PARAMETRES**, section « Finances » :
   - **Date et soldes d'ouverture** : espèces, banque, et part de ces soldes appartenant à la caisse sociale.
   - **DEBUT_SUIVI_COTISATIONS** : premier mois de cotisation dû.
   - **Seuils** : autorisation du Bureau (10 000 FCFA), écart budgétaire (10 %), alerte d'arriérés (3 mois).
2. **RUBRIQUES** : le plan des rubriques et sous-rubriques du cahier des charges est prérempli. Vous pouvez ajouter des lignes en suivant le même modèle de code (`R…` recettes, `D…` dépenses, `S…`/`T…` caisse sociale). Une ligne peut être désactivée (Actif = NON) mais ne doit pas être supprimée si elle a déjà servi.
3. **BAREME_SOCIAL** : barème de l'art. 20 (montants modifiables, par exemple l'aide en cas d'hospitalisation).
4. **BUDGET** :
   - **Préparer l'exercice** crée une ligne par sous-rubrique (avec la possibilité de reprendre le budget N-1).
   - Saisissez le **budget initial** voté en AG, et plus tard le **budget rectifié**. La version initiale est conservée.
   - **Répartir par mois** découpe chaque montant en 12 mois égaux. Ensuite, ajustez à la main les mois de forte activité.
   - **Contrôler le budget** vérifie que les 12 mois correspondent au total et affiche l'équilibre recettes / dépenses.

## 2. Enregistrer une opération (Secrétaire aux Finances)

Feuille **SAISIE_CAISSE** :

1. Remplissez les cases jaunes :
   - date et caisse (Espèces ou Banque) ;
   - opération (Recette, Dépense ou Virement) et rubrique ;
   - libellé et montant ;
   - membre (matricule) ou tiers.
2. Cliquez sur **Enregistrer**. L'écriture reçoit un numéro de pièce (`P-2026-0001`). Une recette versée par un membre ou un tiers reçoit aussi un **reçu numéroté** (`REC-2026-0001`), imprimable aussitôt, avec le montant en toutes lettres.

| Contrôle automatique | Effet |
| --- | --- |
| Dépense d'au moins 10 000 FCFA | Référence de l'autorisation du Bureau obligatoire (art. 16-5) |
| Rubrique de recette utilisée pour une dépense, ou l'inverse | Refusé |
| Dépense supérieure au solde de la caisse ou de la caisse sociale | Avertissement |
| Exercice clôturé | Refusé |
| Virement | Deux écritures liées (sortie et entrée), sans effet sur le budget |

**Les écritures ne se modifient jamais.** Pour corriger une erreur : feuille **CAISSE**, sélectionnez la ligne, puis **Annuler l'écriture** avec un motif. Une contre-passation (montant négatif) est créée, et l'original est marqué « Annulée ». Un virement annulé l'est des deux côtés.

Les **soldes** (espèces, banque, total, dont caisse sociale) s'affichent à droite de la saisie.

## 3. Cotisations et pénalités

Feuille **COTISATIONS** > **Calculer** donne la situation de chaque membre à la date choisie.

- **Qui doit la cotisation** : les membres dont le statut est marqué « Cotisation = OUI » dans LISTES. Ce sont, par défaut, les membres en observation, confirmés, refroidis, suspendus et exclus temporairement. 300 FCFA sont dus par mois depuis le début du suivi, ou depuis la date d'arrivée si elle est plus récente.
- **Paiements** : chaque paiement couvre les mois les plus anciens d'abord. La colonne « À jour jusqu'à » montre le dernier mois couvert, et l'avance éventuelle apparaît comme des arriérés négatifs.
- **Pénalités** : les retards pointés génèrent des pénalités (50 FCFA), suivies sur des colonnes séparées.
- **Encaisser une cotisation** / **Encaisser des pénalités** : sélectionnez le membre, saisissez le montant et la caisse. Le reçu est créé.
- **Message de relance** : texte prêt à copier dans WhatsApp pour chaque membre en retard.
- **Couleurs** : rouge à partir de 3 mois d'arriérés, orange en cas de retard ou de pénalités, vert si le membre est à jour. Le taux de recouvrement s'affiche en haut.

**Cotisations spéciales** (feuille **CAMPAGNES**) :

1. **Nouvelle campagne** : objet, montant par membre, date limite.
2. **SUIVI_CAMPAGNE** montre qui a payé et ce qu'il reste à payer.
3. **Encaisser** enregistre un paiement de la campagne.

## 4. Caisse sociale (art. 20)

La caisse sociale est un **fonds séparé** suivi à l'intérieur des deux caisses : les rubriques S… et T… lui appartiennent.

1. Feuille **SOCIAL** > **Déclarer un événement**. Choisissez le type (barème), le membre concerné et la date.
2. L'application crée automatiquement la **campagne de contributions** du barème, par exemple 1 500 FCFA par membre pour une hospitalisation. Les paiements se suivent avec **Suivre les contributions**.
3. **Verser l'aide** enregistre la dépense prévue par le barème, par exemple 50 000 FCFA, avec la référence de l'autorisation du Bureau.
4. Pour chaque événement : collecté, aide versée, autres dépenses (gerbe, transport…), solde, et affectation de la différence selon le règlement.

## 5. Suivi du budget, écarts et variations

Feuille **SUIVI_BUDGET** : choisissez l'exercice et le mois, puis cliquez sur **Calculer**. Pour chaque sous-rubrique, avec sous-totaux par rubrique, totaux et résultat, le tableau donne :

| Colonne | Contenu |
| --- | --- |
| Prévu annuel / Prévu à date | Budget retenu, et somme des mois écoulés |
| Réalisé à date | Total du journal, contre-passations déduites |
| Écart et écart % | Couleur au-delà du seuil : rouge pour une recette en retrait ou une dépense en dépassement, vert dans le cas inverse |
| Exécution annuelle | Réalisé ÷ budget annuel |
| Variation mensuelle | Mois en cours comparé au mois précédent |
| Variation annuelle | Réalisé à date comparé à la même période de l'année précédente |

## 6. Contrôles de caisse et pertes

- **ARRETE_CAISSE** : comptez les billets et pièces puis cliquez sur **Enregistrer l'arrêté**. L'écart avec le livre est archivé dans **ARRETES**. Un manquant peut être passé en dépense et inscrit au registre des pertes ; un excédent, en recette.
- **Rapprochement bancaire** : saisissez le solde du relevé ; l'écart avec le livre est archivé.
- **PERTES** (art. 51) : manquants, cotisations irrécouvrables, matériel perdu, malversations, avec un échéancier de remboursement. **Enregistrer un remboursement** crée la recette et le reçu, puis met à jour le reste dû.
- L'**accueil** alerte si aucun arrêté de caisse n'a été fait depuis 30 jours, si un solde devient négatif, ou si des membres ont 3 mois d'arriérés ou plus.

## 7. Clôture d'exercice

Feuille **CLOTURES** (ou **CAISSE**) > **Clôturer un exercice**. Les soldes de fin, le total des recettes, le total des dépenses et le résultat sont archivés. Aucune écriture ne peut ensuite être datée dans cet exercice. Les soldes continuent automatiquement sur l'exercice suivant.

## 8. Droits du lot 2

| Rôle | Finances (caisse, budget, arrêtés) | Cotisations et campagnes | Caisse sociale |
| --- | --- | --- | --- |
| Secrétaire aux Finances | Modifie | Modifie | Modifie |
| Secrétaire aux Patrimoines | Consulte (modifie pendant un intérim des Finances) | Consulte | Consulte |
| Vice-Responsable | Consulte | Consulte | Déclare les événements |
| 1er Responsable | Consulte | Consulte | Consulte |
| Secrétaire Général et Adjoint | – | Consulte | Consulte |
| Administrateur | Modifie | Modifie | Modifie |

Seul un rôle qui modifie les **Finances** peut encaisser ou verser de l'argent.
