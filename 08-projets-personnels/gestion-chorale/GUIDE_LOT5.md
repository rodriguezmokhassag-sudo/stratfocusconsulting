# Gestion Chorale – Guide du lot 5 (tableau de bord et rapports)

Le lot 5 ajoute :

- un **tableau de bord** en chiffres et en graphiques ;
- six **rapports** prêts à imprimer ou à exporter en **PDF** en un clic ;
- des **couleurs proposées à partir du logo**.

Les lots 1 à 4 sont conservés ([GUIDE_LOT1.md](GUIDE_LOT1.md) à [GUIDE_LOT4.md](GUIDE_LOT4.md)). Le **guide complet**, qui regroupe les cinq lots avec des captures d'écran, est le fichier `dist/Guide_GestionChorale.pdf`.

## 0. Passer au lot 5

Ouvrez le nouveau `GestionChorale.xlsm` en **Administrateur**, puis cliquez sur **PARAMETRES > Reprendre un ancien fichier** et choisissez votre fichier actuel (lots 1 à 4). Toutes les données et tous les mots de passe sont repris.

Deux nouveaux paramètres :

| Paramètre | Rôle |
| --- | --- |
| Dossier des PDF | Dossier où sont enregistrés les rapports. Vide par défaut : sous-dossier `Rapports` à côté du classeur. |
| Dernier logo importé | Rempli automatiquement ; sert aux couleurs proposées. |

## 1. Tableau de bord (feuille TABLEAU_BORD)

Le tableau de bord est le premier bouton de l'accueil. Il se **recalcule de lui-même** à la première ouverture de la journée, et quand un autre rôle se connecte. Le bouton **Actualiser** le recalcule pour la date de la case jaune.

À gauche, les **indicateurs**, regroupés par domaine :

| Domaine | Indicateurs |
| --- | --- |
| Membres | Membres actifs, arrivées de l'exercice, refroidis et sanctionnés |
| Assiduité | Taux de l'exercice, du mois en cours et du mois précédent |
| Finances | Trésorerie, fonds social, recettes, dépenses, résultat, exécution du budget de dépenses |
| Cotisations | Taux de recouvrement, membres en retard, reste à recouvrer |
| Patrimoine | Valeur nette, biens à réparer, retours en retard |
| Planning | Activités réalisées sur prévues, prochaine activité |
| Mandats | Prochaine fin de mandat, postes vacants |
| Discipline | Sanctions en cours, dossiers à examiner |
| Cantiques | Cantiques maîtrisés par tout le chœur |

À droite et en dessous, **trois graphiques** :

- le taux d'assiduité par mois ;
- les recettes et les dépenses par mois, avec la trésorerie de fin de mois ;
- l'assiduité et la maîtrise des cantiques par pupitre.

**Chaque rôle ne voit que ses domaines.** Par exemple, le Directeur de chœur ne voit ni les finances ni les mandats, et le Secrétaire aux Finances ne voit pas la discipline. Le tableau de bord est vidé à la déconnexion.

## 2. Les rapports

Chaque rapport a un bouton **Calculer**, puis un bouton **Exporter en PDF**. Le PDF est enregistré dans le dossier `Rapports`, nommé avec la date et l'heure (par exemple `RAPPORT_AG_2026-12-13_1030.pdf`), puis ouvert.

| Rapport | Feuille | Réglage (case jaune) | Accessible à |
| --- | --- | --- | --- |
| Rapport annuel pour l'AG | RAPPORT_AG | Exercice | Tous les rôles |
| Point financier du mois | POINT_MENSUEL | Une date du mois | Rôles qui voient les finances |
| Livre de caisse | LIVRE_CAISSE | Période, caisse (Toutes, Espèces, Banque) | Rôles qui voient les finances |
| Fiche d'un membre | FICHE_MEMBRE | Matricule | Rôles qui voient les membres |
| Pupitres et commissions | RAPPORT_PUPITRES | Période | Rôles qui voient les présences |

### Rapport annuel pour l'AG

Le rapport présente :

1. **Effectif** : membres par statut, arrivées, réceptions et départs de l'exercice.
2. **Assiduité** : taux par trimestre et par pupitre, avec les cantiques maîtrisés, ainsi que les séances tenues et annulées.
3. **Activités** du planning voté en AG : budget prévu, réalisé et statut.
4. **Situation financière** :
   - soldes d'ouverture et de clôture ;
   - recettes et dépenses par rubrique comparées au budget voté, avec le taux d'exécution ;
   - résultat ;
   - recouvrement des cotisations ;
   - caisse sociale.
5. **Patrimoine** : valeur d'acquisition et valeur nette, acquisitions, pertes de l'exercice.
6. **Discipline** : nombre de dossiers par sanction, **sans aucun nom**.
7. **Bureau et mandats** : titulaires, fins de mandat, postes vacants.
8. **Vie spirituelle** : répertoire, célébrations, études réalisées.

Les signatures du Secrétaire Général, du Secrétaire aux Finances et du 1er Responsable terminent le rapport.

Le bouton **Dossier complet de l'AG (PDF)** produit **un seul PDF** qui réunit :

- le rapport annuel ;
- le suivi budgétaire ;
- le programme annuel des activités ;
- le rapport par pupitre et par commission ;
- la synthèse du patrimoine.

Seules les parties autorisées au rôle connecté sont incluses.

### Point financier du mois

Ce rapport comporte cinq parties, suivies des signatures du Secrétaire aux Finances et du 1er Responsable :

1. **Trésorerie** : soldes de début et de fin de mois, recettes, dépenses et virements, pour les espèces, la banque et le fonds social.
2. **Recettes par rubrique** : prévu du mois (répartition mensuelle du budget), réalisé, écart, et cumul de l'exercice.
3. **Dépenses par rubrique**, sur le même modèle.
4. **Cotisations** : montant encaissé dans le mois, taux de recouvrement, membres en retard.
5. **Points d'attention** : dépassements du budget du mois, dépenses non prévues, solde négatif.

### Livre de caisse

Toutes les écritures de la période, par date, avec le **solde progressif**. Le solde d'ouverture et le solde final sont repris en tête et en fin de liste. Une écriture annulée apparaît avec la mention « (annulée) », suivie de sa contre-passation.

### Fiche d'un membre

Le bouton **Fiche du membre** est aussi disponible sur la feuille MEMBRES : sélectionnez la ligne du membre. La fiche réunit :

- l'identité et la situation du membre ;
- son assiduité mois par mois sur 12 mois ;
- ses cotisations et pénalités ;
- la caisse sociale (contributions et aides reçues) ;
- le matériel en sa possession et ses pertes ;
- ses mandats.

La partie **discipline** n'apparaît que pour les rôles autorisés.

### Pupitres et commissions

Pour chaque pupitre :

- le nombre de membres actifs ;
- les séances attendues et le **taux d'assiduité** ;
- les cantiques maîtrisés, en apprentissage et non commencés, et le **taux de maîtrise**.

Pour chaque commission : les membres et le taux d'assiduité. Deux graphiques accompagnent ces tableaux.

## 3. Couleurs proposées à partir du logo

1. **PARAMETRES > Importer le logo**. L'application propose aussitôt des couleurs tirées du logo. Vous pouvez aussi les redemander plus tard avec le bouton **Couleurs du logo**.
2. **Trois propositions** s'affichent en couleur dans PARAMETRES (colonnes E à H) :
   - la couleur dominante en principale et la deuxième couleur en accent ;
   - l'inverse ;
   - une version plus foncée de la couleur dominante.
3. Tapez **1**, **2** ou **3** pour appliquer une proposition, ou **4** pour choisir vous-même les couleurs.

Les couleurs principales sont assombries si nécessaire, pour que le texte blanc des bandeaux et des boutons reste lisible. Les graphiques prennent aussi les couleurs du thème.

La lecture du logo utilise le composant Windows WIA, présent depuis Windows Vista. S'il manque, l'application propose les thèmes habituels.

## 4. Conseils

- Avant l'AG, enregistrez l'inventaire de décembre (lot 3) et pointez toutes les séances, puis produisez le **dossier complet de l'AG**.
- Le Secrétaire aux Finances peut produire le **point du mois** à chaque réunion du Bureau.
- Les PDF sont des copies figées : recalculez le rapport avant chaque export.
