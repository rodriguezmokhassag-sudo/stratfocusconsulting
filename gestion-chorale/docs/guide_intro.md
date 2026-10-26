# Présentation

**Gestion Chorale** est une application Excel (avec macros VBA) pour gérer une chorale ou tout autre groupe d'église. Elle a été conçue à partir du règlement intérieur de la Chorale Amour du Cœur (EEC, Paroisse de Tchimbambouka), et chaque règle reste paramétrable.

| Domaine | Ce que fait l'application |
| --- | --- |
| Secrétariat | Membres, nouveaux choristes (observation et réception), calendrier des séances, pointage, taux de participation mensuels, trimestriels et annuels, liste électorale |
| Finances | Caisse en espèces, banque et fonds social, budget voté en AG et écarts, cotisations et pénalités, caisse sociale, reçus, arrêtés de caisse, pertes, clôture d'exercice |
| Patrimoine | Inventaire valorisé et amorti, prêts, réparations, locations avec caution, inventaire physique, étiquettes |
| Vie du groupe | Discipline et sanctions, planning annuel, mandats et élections, cantiques et apprentissage par pupitre, études bibliques |
| Pilotage | Tableau de bord, rapports PDF (AG, point du mois, livre de caisse, fiche d'un membre, pupitres), alertes de l'accueil |

Deux fichiers sont livrés :

- `GestionChorale.xlsm`, le **modèle vierge** à utiliser ;
- `GestionChorale_DEMO.xlsm`, la même application remplie de **données fictives**, pour la formation.

Ce guide reprend les cinq lots du projet dans l'ordre : démarrage et secrétariat, finances, patrimoine, vie du groupe, puis tableau de bord et rapports.

## Rôles et droits

Chaque membre du Bureau se connecte avec **son rôle et son mot de passe**. Le mot de passe provisoire est `chorale` ; il doit être changé à la première connexion. Une feuille masquée pour un rôle n'apparaît même pas dans le classeur.

Légende : **M** = consulte et modifie, **L** = consulte seulement, **–** = feuille masquée.

<!-- DROITS -->

Pour adapter cette matrice, l'Administrateur modifie la feuille **DROITS**. Pour confier un intérim (art. 16), il remplit les colonnes « Assure l'intérim de » de **UTILISATEURS**.

## L'année de la chorale en un coup d'œil

| Quand | Qui | Quoi |
| --- | --- | --- |
| Début d'exercice | Bureau, Finances | Planning voté en AG, budget voté et réparti par mois, calendrier des séances généré |
| Chaque répétition et chaque culte | Secrétariat | Pointage de la séance |
| Chaque semaine | Directeur de chœur | Programme des chants, suivi de l'apprentissage par pupitre |
| Chaque mois | Finances | Arrêté de caisse, point financier du mois, relance des cotisations |
| Chaque mois | Secrétariat | Taux de participation, membres refroidis |
| Juin et décembre | Patrimoine | Inventaire physique |
| Avant l'AG | Bureau | Dossier complet de l'AG en PDF ; liste électorale et élections tous les 2 ans |
| Fin d'exercice | Finances | Clôture de l'exercice |

## Passer à une nouvelle version

Quand une nouvelle version du fichier est livrée :

1. Ouvrez le nouveau `GestionChorale.xlsm` en **Administrateur**.
2. Cliquez sur **PARAMETRES > Reprendre un ancien fichier**, puis choisissez votre fichier actuel.
3. Toutes les données sont reprises : membres, présences, caisse, patrimoine, discipline, mandats, cantiques, paramètres, mots de passe et logo.
4. Enregistrez le nouveau fichier, puis reconnectez-vous.
