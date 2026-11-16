# Comment lire ce guide

Ce guide décrit, une par une, les **52 fonctions du menu de l'Administrateur** de l'application Excel **Gestion Chorale** (version 1.4.0, lot 5). L'Administrateur est le seul rôle qui voit toutes les fonctions. Les autres rôles voient une partie de ce menu, selon leurs droits.

Chaque fonction fait l'objet d'une fiche, qui présente :

- la **feuille** ouverte par le bouton du menu ;
- la **définition** de la fonction ;
- les **rôles** qui y ont accès : « modifie » signifie consulter et modifier, « consulte » signifie lecture seule ;
- ce que l'on **peut faire** : chaque bouton de la feuille et son effet ;
- la **marche à suivre** pour les opérations courantes ;
- les **contrôles automatiques** et les articles du règlement intérieur appliqués.

**Conventions communes à toutes les feuilles**

- Le bouton **Accueil**, en haut à gauche de chaque feuille, ramène au menu.
- Les **cases jaunes** sont des cases à remplir : date, période, matricule, exercice.
- Les boutons en **couleur d'accent** (rouge dans le thème vert) lancent l'action principale de la feuille ; les autres sont en couleur principale.
- Quand un bouton agit sur une ligne (un membre, une écriture, un bien…), **sélectionnez d'abord une cellule de cette ligne**. Sans sélection, l'application demande le numéro.
- Les colonnes calculées (numéros, totaux, taux) sont **verrouillées** : elles se remplissent seules.
- Chaque modification est inscrite au **Journal des actions**.

## Le menu en un coup d'œil

<!-- MENU -->

Le menu est construit à chaque connexion. Pour un autre rôle, les boutons auxquels il n'a pas droit n'apparaissent pas, et les feuilles correspondantes restent masquées dans le classeur.

# 1. Pilotage et rapports

## 1.1 Tableau de bord

**Feuille** : TABLEAU_BORD.

**Définition** : vue d'ensemble de la chorale à une date donnée, en chiffres et en graphiques. Elle rassemble sur une seule page les indicateurs de tous les domaines.

**Accès** : tous les rôles. Chaque rôle ne voit que les domaines auxquels il a droit : le Directeur de chœur ne voit pas les finances, et le Secrétaire aux Finances ne voit pas la discipline.

**Ce que l'on peut faire**

| Bouton ou case | Effet |
| --- | --- |
| Case jaune **Situation au** | Date à laquelle les indicateurs sont calculés (aujourd'hui par défaut). |
| **Actualiser** | Recalcule tous les indicateurs et les graphiques pour la date choisie. |
| **Exporter en PDF** | Enregistre la page dans le dossier `Rapports` et l'ouvre. |

**Contenu**

| Domaine | Indicateurs |
| --- | --- |
| Membres | Membres actifs (tous les statuts pointés), arrivées depuis le début de l'exercice, refroidis et sanctionnés |
| Assiduité | Taux de l'exercice, du mois en cours, du mois précédent |
| Finances | Trésorerie (espèces et banque), fonds de la caisse sociale, recettes, dépenses, résultat, part du budget de dépenses déjà consommée |
| Cotisations | Taux de recouvrement, membres en retard d'au moins 3 mois, reste à recouvrer |
| Patrimoine | Valeur nette, biens à réparer ou hors service, retours en retard |
| Planning | Activités réalisées sur prévues, prochaine activité |
| Mandats | Prochaine fin de mandat, postes vacants |
| Discipline | Sanctions en cours, dossiers à examiner |
| Cantiques | Cantiques maîtrisés par tout le chœur |

Trois graphiques complètent la page : le taux d'assiduité par mois, les recettes et les dépenses par mois avec la trésorerie de fin de mois, et l'assiduité et la maîtrise des cantiques par pupitre.

**Bon à savoir**

- Le tableau se recalcule tout seul à la première ouverture de la journée, et quand un autre rôle se connecte.
- Il est vidé à la déconnexion, pour qu'aucun chiffre ne reste visible du rôle suivant.

![Tableau de bord, rôle Administrateur](CAP/tableau_bord.png)

## 1.2 Rapport pour l'AG

**Feuille** : RAPPORT_AG.

**Définition** : rapport annuel présenté à l'Assemblée générale. Il reprend en huit parties toute l'activité d'un exercice, prêt à signer.

**Accès** : tous les rôles peuvent le calculer et l'imprimer.

**Ce que l'on peut faire**

| Bouton ou case | Effet |
| --- | --- |
| Case jaune **Exercice** | Exercice à présenter, par exemple 2026. |
| **Calculer** | Établit le rapport, du début de l'exercice jusqu'à sa fin (ou jusqu'à aujourd'hui s'il est en cours). |
| **Exporter en PDF** | Enregistre le rapport en PDF. |
| **Dossier complet de l'AG (PDF)** | Produit **un seul PDF** qui réunit le rapport, le suivi budgétaire, le programme annuel, le rapport par pupitre et la synthèse du patrimoine. |

**Les huit parties du rapport**

1. **Effectif** : membres par statut, arrivées, réceptions officielles (art. 28) et départs de l'exercice.
2. **Assiduité** : taux par trimestre et pour l'exercice entier, taux et cantiques maîtrisés par pupitre, séances tenues et annulées.
3. **Activités** : chaque activité du planning, avec sa date, son budget prévu, son réalisé et son statut.
4. **Situation financière** :
   - soldes d'ouverture et de clôture (espèces, banque, fonds social) ;
   - recettes et dépenses par rubrique comparées au budget voté, avec le taux d'exécution ;
   - résultat de l'exercice ;
   - recouvrement des cotisations ;
   - caisse sociale.
5. **Patrimoine** : nombre de biens, valeur d'acquisition et valeur nette, acquisitions et pertes de l'exercice.
6. **Discipline** : nombre de dossiers par sanction, **sans aucun nom**.
7. **Bureau et mandats** : titulaires, fins de mandat, postes vacants.
8. **Vie spirituelle** : cantiques au répertoire et maîtrisés, célébrations avec programme, études réalisées.

Le rapport se termine par les signatures du Secrétaire Général, du Secrétaire aux Finances et du 1er Responsable.

**Bon à savoir** : le dossier complet de l'AG n'inclut que les parties autorisées au rôle connecté. Produit par l'Administrateur, il est complet.

## 1.3 Point financier du mois

**Feuille** : POINT_MENSUEL.

**Définition** : bilan financier d'un mois, à présenter en réunion du Bureau.

**Accès** : modifie : Administrateur, Secrétaire aux Finances. Consulte : 1er Responsable, Vice-Responsable, Secrétaire aux Patrimoines.

**Ce que l'on peut faire**

| Bouton ou case | Effet |
| --- | --- |
| Case jaune **Mois** | N'importe quelle date du mois voulu. |
| **Calculer** | Établit le point du mois. |
| **Exporter en PDF** | Enregistre le point en PDF. |

**Contenu**

1. **Trésorerie** : soldes de début et de fin de mois, recettes, dépenses et virements internes, pour les espèces, la banque et le fonds social.
2. **Recettes par rubrique** : prévu du mois (répartition mensuelle du budget), réalisé, écart, écart en pourcentage, cumul de l'exercice.
3. **Dépenses par rubrique** : même présentation, suivie du résultat du mois.
4. **Cotisations** : montant encaissé dans le mois et nombre de payeurs, taux de recouvrement, membres en retard.
5. **Points d'attention** : dépassements du budget du mois, dépenses non prévues au budget, solde des espèces ou fonds social négatif.

Signatures : le Secrétaire aux Finances et le 1er Responsable.

## 1.4 Livre de caisse

**Feuille** : LIVRE_CAISSE.

**Définition** : liste chronologique de toutes les écritures d'une période, avec le solde après chaque opération. C'est la version imprimable du journal de caisse.

**Accès** : comme le point financier du mois.

**Ce que l'on peut faire**

| Bouton ou case | Effet |
| --- | --- |
| Cases jaunes **Du** et **au** | Période voulue. |
| Case jaune **Caisse** | Toutes, Espèces ou Banque. |
| **Calculer** | Liste les écritures par date avec le solde progressif. La première ligne donne le solde d'ouverture, la dernière les totaux et le solde final. |
| **Exporter en PDF** | Enregistre le livre en PDF. |

**Bon à savoir**

- Une écriture annulée apparaît avec la mention « (annulée) », suivie de sa contre-passation : le solde reste juste.
- Avec « Toutes », les virements entre espèces et banque s'annulent.

# 2. Secrétariat

## 2.1 Membres

**Feuille** : MEMBRES.

**Définition** : registre de tous les membres de la chorale, actuels et anciens, avec leur fiche complète.

**Accès** : modifie : Administrateur, Secrétaire Général, Secrétaire Général Adjoint. Consulte : 1er Responsable, Vice-Responsable, Finances, Évangélisation, Consultation, Directeur de chœur.

**Ce que l'on peut faire**

| Bouton | Effet |
| --- | --- |
| **Nouveau membre** | Ajoute une ligne, crée le matricule (sigle du groupe et numéro, par exemple ADC-0101), met le statut « En observation » et ouvre le dossier d'adhésion. |
| **Rechercher** | Trouve un membre par une partie de son nom, de ses prénoms ou de son matricule. |
| **Dossier d'adhésion** | Ouvre le dossier d'adhésion du membre sélectionné. |
| **Fiche du membre** | Prépare la fiche individuelle du membre sélectionné (voir 2.2). |

**Colonnes de la fiche** : matricule, nom, prénoms, sexe, date et lieu de naissance, téléphone, WhatsApp, adresse, personne à prévenir et son téléphone, paroisse et chorale d'origine, dates de baptême, d'arrivée et de réception, pupitre, instrument, commissions, fonction au Bureau, situation matrimoniale, conjoint, nombre d'enfants, statut, date du statut, observations.

**Marche à suivre**

- Pour un membre existant, saisissez directement la ligne : le matricule se crée dès que le nom est tapé.
- Pour un départ (démission, transfert, décès), changez le **statut** et la **date du statut**. Ne supprimez jamais la ligne : l'historique des présences et des paiements en dépend.

**Bon à savoir** : le statut décide si le membre est pointé (code par défaut P ou NC) et s'il doit la cotisation. Ces deux réglages se trouvent dans **Listes de choix**.

## 2.2 Fiche d'un membre

**Feuille** : FICHE_MEMBRE.

**Définition** : dossier individuel d'un membre, sur une page imprimable.

**Accès** : tous les rôles qui voient les membres. Chaque partie de la fiche n'apparaît que si le rôle a droit au domaine.

**Ce que l'on peut faire**

| Bouton ou case | Effet |
| --- | --- |
| Case jaune **Matricule** | Membre à afficher. |
| **Afficher** | Remplit la fiche. |
| **Exporter en PDF** | Enregistre la fiche en PDF. |

**Contenu**

- identité et situation ;
- assiduité mois par mois sur les 12 derniers mois ;
- cotisations et pénalités : mois dus, payés, retard, reste à régulariser ;
- caisse sociale : contributions versées et aides reçues ;
- matériel en sa possession, pertes et remboursements ;
- mandats exercés ;
- discipline, pour les rôles autorisés seulement.

## 2.3 Nouveaux choristes

**Feuille** : ADHESIONS.

**Définition** : suivi des dossiers d'adhésion pendant la période d'observation, jusqu'à la décision du Bureau et la réception officielle (art. 26 à 28).

**Accès** : comme les membres.

**Ce que l'on peut faire**

| Bouton ou colonne | Effet |
| --- | --- |
| Colonne **Catégorie d'entrée** | Baptisé (nouveau membre), transfert d'une autre chorale, catéchumène. |
| Colonnes de contrôle (OUI / NON / N/A) | Éléments remis : règlement lu, cotisations, lettre de recommandation pour un transfert, Bible, cantiques, cahier de chant, kit de table, tenues… |
| **Actualiser les dossiers** | Calcule la fin d'observation (3 mois), les séances attendues, le taux d'assiduité, les éléments manquants et une **proposition** : à confirmer, à prolonger ou à refuser. |
| Colonne **Décision** | Confirmer (date de réception et officiant obligatoires), Prolonger (nouvelle date et motif obligatoires), Refuser (motif obligatoire). |
| **Appliquer les décisions** | Met à jour la fiche du membre (statut, date de réception) et clôt le dossier. Le kit remis (chaise, gobelet, couverts) entre automatiquement au patrimoine. |

**Bon à savoir** : l'accueil signale les dossiers prêts pour la décision, les observations qui se terminent dans les 15 jours et les dossiers incomplets.

## 2.4 Calendrier des séances

**Feuille** : SEANCES.

**Définition** : liste de toutes les séances de l'année (répétitions, cultes, sorties, veillées, réunions, études), qui sert de base au pointage.

**Accès** : modifie : Administrateur, Secrétaire Général, Adjoint. Consulte : 1er Responsable, Vice-Responsable, Évangélisation, Consultation, Directeur de chœur.

**Ce que l'on peut faire**

| Bouton | Effet |
| --- | --- |
| **Générer le calendrier** | Crée toutes les séances régulières d'une année selon les **Types d'activités** (par défaut, répétitions le mercredi et le samedi de 18h00 à 20h30, culte le dimanche). Les séances déjà présentes ne sont pas dupliquées. |
| **Ajouter une séance** | Ajoute une séance ponctuelle : date et code du type. |
| **Annuler la séance** | Passe la séance sélectionnée à « Annulée » ; elle ne compte plus dans les taux, et un pointage déjà fait est effacé. |
| **Pointer cette séance** | Ouvre le pointage de la séance sélectionnée. |

**Bon à savoir** : chaque séance a un identifiant du type `S20261010-REP` (date et type). Les activités validées du planning et les études bibliques créent leur séance automatiquement.

## 2.5 Pointage d'une séance

**Feuille** : POINTAGE.

**Définition** : enregistrement des présences et des absences de chaque membre attendu à une séance.

**Accès** : modifie : Administrateur, Secrétaire Général, Adjoint.

**Ce que l'on peut faire**

| Bouton | Effet |
| --- | --- |
| **Prochaine séance à pointer** | Charge la plus ancienne séance passée non pointée. |
| **Charger la séance** | Charge la séance indiquée dans la case jaune. |
| **Tous présents** | Remet « P » pour tous les membres attendus. |
| **Valider le pointage** | Enregistre les présences, calcule les présents et le taux de la séance, et la marque « pointée ». |

**Les codes de présence**

| Code | Signification | Effet |
| --- | --- | --- |
| P | Présent | Compte 1 |
| R | Retard | Compte 1, pénalité de 50 FCFA |
| RX | Retard de plus de 15 minutes, non admis (art. 50) | Compte 0, pénalité de 50 FCFA |
| DA | Départ anticipé | Compte 0,5 |
| AJ | Absent justifié | Exclu du calcul, motif obligatoire |
| ANJ | Absent non justifié | Compte 0 |
| NC | Non concerné (suspendu, malade de longue durée, voyage) | Exclu du calcul |

**Marche à suivre**

1. Chargez la séance : la liste des membres attendus apparaît, triée par pupitre et pré-remplie (P, ou NC pour un membre sanctionné).
2. Corrigez seulement les exceptions ; ajoutez le motif d'un AJ.
3. Cliquez sur **Valider le pointage**.

**Bon à savoir** : une séance déjà pointée peut être rechargée et corrigée sans créer de doublons. Un pointage refusé (motif manquant, code inconnu) n'enregistre rien.

![Pointage d'une séance](CAP/pointage.png)

## 2.6 Historique des présences

**Feuille** : PRESENCES.

**Définition** : registre de toutes les présences enregistrées par le pointage, une ligne par membre et par séance.

**Accès** : comme le calendrier des séances (consultation).

**Ce que l'on peut faire** : consulter, filtrer et trier (flèches de filtre des en-têtes), par exemple toutes les absences d'un membre ou toutes les pénalités d'un mois. Les colonnes sont : séance, date, type, matricule, nom, code, motif, pénalité, saisi le, saisi par.

**Bon à savoir** : cette feuille ne se modifie pas à la main. Pour corriger, rechargez la séance dans **Pointage d'une séance** et validez de nouveau.

## 2.7 Taux de participation

**Feuille** : TAUX.

**Définition** : calcul du taux d'assiduité de chaque membre sur une période (mois, trimestre, année ou période libre).

**Accès** : comme le calendrier des séances.

**Ce que l'on peut faire**

| Bouton ou case | Effet |
| --- | --- |
| **Ce mois**, **Mois précédent**, **Ce trimestre**, **Cette année** | Remplissent la période et calculent. |
| Cases jaunes **Du**, **au**, **Type** | Période libre et filtre par type d'activité (TOUS = les types qui comptent dans le taux). |
| **Calculer** | Établit le classement. |
| **Imprimer** | Aperçu avant impression. |

**Mode de calcul** : taux = (P + R + 0,5 × DA) ÷ séances attendues. Les absences justifiées (AJ) et les non concernés (NC) sont exclus. Le classement est coloré : vert à partir de 80 %, orange de 50 à 79 %, rouge en dessous. À droite figurent la synthèse par pupitre, par type d'activité et l'évolution mois par mois.

## 2.8 Pupitres et commissions

**Feuille** : RAPPORT_PUPITRES.

**Définition** : assiduité et apprentissage des cantiques regroupés par pupitre, puis assiduité par commission.

**Accès** : comme le calendrier des séances.

**Ce que l'on peut faire**

| Bouton ou case | Effet |
| --- | --- |
| Cases jaunes **Du** et **au** | Période (début d'exercice et aujourd'hui par défaut). |
| **Calculer** | Remplit les deux tableaux et les deux graphiques. |
| **Exporter en PDF** | Enregistre le rapport en PDF. |

**Contenu** : pour chaque pupitre, les membres actifs, les séances attendues, les présences pondérées, le taux d'assiduité, les cantiques maîtrisés, en apprentissage et non commencés, et le taux de maîtrise. Une ligne « Ensemble de la chorale » totalise. Pour chaque commission : les membres, les séances attendues et le taux.

## 2.9 Fiche d'appel

**Feuille** : FICHE_APPEL.

**Définition** : liste papier des membres attendus à une séance, par pupitre, pour pointer à la main pendant la répétition.

**Accès** : comme le calendrier des séances.

**Ce que l'on peut faire** : saisir la séance dans la case jaune, cliquer sur **Générer la fiche**, puis **Imprimer**. Les codes cochés sur papier sont ensuite saisis dans **Pointage d'une séance**.

## 2.10 Liste électorale

**Feuille** : ELECTEURS.

**Définition** : liste des membres qui peuvent voter à l'Assemblée générale élective (art. 21).

**Accès** : modifie : Administrateur, 1er Responsable, Secrétaire Général. Consulte : Vice-Responsable, Adjoint, Consultation.

**Ce que l'on peut faire** : **Générer la liste**, puis **Imprimer**. Sont retenus les choristes confirmés présents depuis au moins 3 mois avec au moins 60 % d'assiduité sur cette période ; les deux seuils se règlent dans **Paramètres**. Le nombre d'électeurs reporte automatiquement le nombre d'inscrits d'un nouveau scrutin.

# 3. Patrimoine

## 3.1 Patrimoine

**Feuille** : PATRIMOINE.

**Définition** : inventaire valorisé de tous les biens de la chorale (matériel de musique, mobilier, informatique, administration, cuisine, tenues, immobilier), avec leur amortissement.

**Accès** : modifie : Administrateur, Secrétaire aux Patrimoines. Consulte : 1er Responsable, Vice-Responsable, Finances, Consultation, Directeur de chœur.

**Ce que l'on peut faire**

| Bouton | Effet |
| --- | --- |
| **Nouveau bien** | Saisie guidée : désignation, catégorie, quantité, date et mode d'acquisition, valeur. Le code est créé par catégorie (MUS-0012). |
| **Créer depuis un achat** | Crée la fiche d'un bien à partir d'une dépense d'achat de matériel déjà enregistrée en caisse (rubriques D04). |
| **Prêter** | Prête le bien sélectionné à un membre ou à une commission, avec une date de retour prévue. |
| **Réparation** | Envoie le bien en réparation ; son état passe à « À réparer ». |
| **Perte / sortie** | Perte ou vol, détérioration, ou sortie définitive (réforme, cession). Une perte va au registre des pertes. |
| **Fiche du bien** | Ouvre la fiche détaillée et l'historique des mouvements du bien. |
| **Actualiser les valeurs** | Recalcule la valeur totale, l'amortissement linéaire, la valeur nette et les quantités sorties et disponibles. |

**Bon à savoir** : un bien louable (« Louable = OUI ») a un tarif par jour et peut être loué. L'accueil signale les achats de matériel sans fiche et les biens à réparer.

![Inventaire du patrimoine](CAP/patrimoine.png)

## 3.2 Prêts et mouvements

**Feuille** : MOUVEMENTS_PAT.

**Définition** : registre de toutes les sorties de matériel (prêts, réparations, locations, pertes, sorties définitives) et de leurs retours.

**Accès** : comme le patrimoine.

**Ce que l'on peut faire**

| Bouton | Effet |
| --- | --- |
| **Retour du matériel** | Enregistre le retour du mouvement sélectionné et l'état au retour. Pour une réparation, le coût est saisi et, si le rôle a les droits Finances, la dépense est enregistrée en caisse. |
| **Patrimoine** | Revient à l'inventaire. |

**Bon à savoir** : une perte ou une détérioration (art. 51) est inscrite au registre des pertes, au nom du membre responsable, pour la valeur de remplacement. L'accueil signale les retours en retard.

## 3.3 Locations de matériel

**Feuille** : LOCATIONS.

**Définition** : gestion des contrats de location du matériel à des tiers, de la demande à la restitution de la caution (art. 30).

**Accès** : modifie : Administrateur, Secrétaire aux Patrimoines. L'encaissement et la restitution de la caution sont réservés aux rôles qui modifient les finances.

**Ce que l'on peut faire** (dans l'ordre du circuit)

| Bouton | Effet |
| --- | --- |
| **Nouvelle demande** | Locataire, contact, objet, dates. |
| **Ajouter un article** | Ajoute un bien louable ; le loyer (tarif × jours × quantité) et la caution (30 % de la valeur, au moins 10 000 FCFA) se calculent. |
| **Approuver** | Avis de la commission musicale et accord du Bureau (référence du PV) obligatoires. |
| **Encaisser (Finances)** | Encaisse le loyer et la caution ; deux reçus sont émis. |
| **Remettre le matériel** | Les articles sortent du stock disponible. |
| **Retour du matériel** | État au retour et, en cas de dégâts, retenue sur la caution. |
| **Restituer la caution (Finances)** | Rend la caution moins la retenue ; la retenue devient une recette ; le contrat est clôturé. |
| **Refuser** | Annule une demande. |
| **Contrat** | Prépare le contrat de location à faire signer (feuille CONTRAT). |

**Bon à savoir** : une étape faite dans le désordre est bloquée avec un message qui explique pourquoi.

## 3.4 Inventaire physique

**Feuille** : INVENTAIRE.

**Définition** : comptage réel des biens, en juin et en décembre, comparé aux quantités attendues.

**Accès** : comme le patrimoine.

**Ce que l'on peut faire**

| Bouton | Effet |
| --- | --- |
| **Préparer l'inventaire** | Liste les biens avec la quantité attendue : stock moins les articles prêtés, loués ou en réparation. |
| **Imprimer la feuille de comptage** | Feuille à remplir sur place. |
| **Valider l'inventaire** | Corrige les quantités, inscrit les manquants au registre des pertes et archive le résultat dans INVENTAIRES. |

**Bon à savoir** : l'accueil rappelle l'inventaire en juin et en décembre, ou s'il date de plus de 7 mois.

## 3.5 Synthèse du patrimoine

**Feuille** : SYNTHESE_PAT.

**Définition** : tableau récapitulatif du patrimoine par catégorie, pour le rapport patrimonial de l'AG.

**Ce que l'on peut faire** : **Calculer** (à la date de la case jaune), puis **Imprimer**. Pour chaque catégorie et au total : nombre de fiches, quantités, valeur d'acquisition, amortissement cumulé, valeur nette et valeur de remplacement. À droite : l'évolution de la valeur nette sur 5 ans et les points d'attention (biens à réparer, totalement amortis, retours en retard, achats sans fiche).

## 3.6 Étiquettes

**Feuille** : ETIQUETTES.

**Définition** : étiquettes à coller sur chaque bien, avec son code, sa désignation et le nom du groupe.

**Ce que l'on peut faire** : **Générer les étiquettes** (tous les biens, une catégorie ou un code), puis **Imprimer**.

# 4. Finances

## 4.1 Saisie de caisse

**Feuille** : SAISIE_CAISSE.

**Définition** : formulaire d'enregistrement de toute opération d'argent : recette, dépense ou virement entre la caisse en espèces et la banque.

**Accès** : modifie : Administrateur, Secrétaire aux Finances. Consulte : 1er Responsable, Vice-Responsable, Secrétaire aux Patrimoines.

**Ce que l'on peut faire**

| Bouton | Effet |
| --- | --- |
| **Enregistrer** | Crée l'écriture : numéro de pièce (P-2026-0001) et, pour une recette d'un membre ou d'un tiers, reçu numéroté (REC-2026-0001). |
| **Effacer** | Vide le formulaire. |
| **Actualiser les soldes** | Affiche à droite les soldes espèces, banque, total et fonds social. |
| **Imprimer un reçu** | Prépare le reçu d'une pièce, avec le montant en toutes lettres. |
| **Journal de caisse** | Ouvre le journal. |

**Cases à remplir** : date, caisse, opération, rubrique, libellé, membre (matricule) ou tiers, montant, référence (campagne, événement, activité, perte), autorisation du Bureau, caisse de destination pour un virement.

**Contrôles automatiques**

| Situation | Effet |
| --- | --- |
| Dépense d'au moins 10 000 FCFA | Référence de l'autorisation du Bureau obligatoire (art. 16-5) |
| Rubrique de recette utilisée pour une dépense, ou l'inverse | Refusé |
| Dépense supérieure au solde de la caisse ou du fonds social | Avertissement |
| Exercice clôturé | Refusé |
| Virement | Deux écritures liées (sortie et entrée), sans effet sur le budget |

**Bon à savoir** : une dépense d'achat de matériel propose aussitôt de créer la fiche du bien.

![Saisie d'une opération de caisse](CAP/saisie_caisse.png)

## 4.2 Journal de caisse

**Feuille** : CAISSE.

**Définition** : registre de toutes les écritures, dans l'ordre de saisie. Une écriture n'y est jamais modifiée.

**Ce que l'on peut faire**

| Bouton | Effet |
| --- | --- |
| **Nouvelle écriture** | Ouvre la saisie de caisse. |
| **Annuler l'écriture** | Annule l'écriture sélectionnée avec un motif : une contre-passation (montant négatif) est créée et l'original est marqué « Annulée ». Un virement est annulé des deux côtés. |
| **Imprimer le reçu** | Reçu de l'écriture sélectionnée (feuille RECU). |
| **Clôturer un exercice** | Archive les soldes, les totaux et le résultat dans CLOTURES ; plus aucune écriture ne peut être datée dans cet exercice. |

## 4.3 Cotisations

**Feuille** : COTISATIONS.

**Définition** : situation de chaque membre pour la cotisation mensuelle (art. 39) et les pénalités de retard.

**Accès** : modifie : Administrateur, Secrétaire aux Finances. Consulte : 1er Responsable, Vice-Responsable, Secrétaire Général, Adjoint, Secrétaire aux Patrimoines.

**Ce que l'on peut faire**

| Bouton | Effet |
| --- | --- |
| **Calculer** | Situation de chaque membre à la date de la case jaune : mois dus, montant dû, payé, reste, mois de retard, dernier mois couvert, pénalités dues, payées et restantes, total à régulariser. |
| **Encaisser une cotisation** | Paiement du membre sélectionné ; le reçu est créé. |
| **Encaisser des pénalités** | Paiement des pénalités du membre sélectionné. |
| **Trier par montant dû** | Met en tête les membres qui doivent le plus. |
| **Imprimer** | Aperçu avant impression. |

**Règles** : 300 FCFA par mois, dus par les statuts marqués « Cotisation = OUI » (en observation, confirmé, refroidi, suspendu, exclu temporaire), depuis le début du suivi ou l'arrivée. Chaque paiement couvre d'abord les mois les plus anciens. Couleurs : rouge à partir de 3 mois de retard, orange en cas de retard ou de pénalités, vert à jour. Un **message de relance** prêt à copier dans WhatsApp est proposé pour chaque membre en retard.

## 4.4 Cotisations spéciales

**Feuille** : CAMPAGNES.

**Définition** : collectes exceptionnelles d'un montant fixé par membre (tenues, sortie, événement social).

**Ce que l'on peut faire**

| Bouton | Effet |
| --- | --- |
| **Nouvelle campagne** | Objet, montant par membre, date limite, rubrique. |
| **Suivre la campagne** | Ouvre SUIVI_CAMPAGNE pour la campagne sélectionnée : qui a payé, combien, ce qu'il reste. |
| **Actualiser les totaux** | Recalcule les membres concernés, l'attendu et le collecté de chaque campagne. |

Dans **SUIVI_CAMPAGNE** : **Calculer**, **Encaisser** (paiement d'un membre, avec reçu) et **Imprimer**.

## 4.5 Caisse sociale

**Feuille** : SOCIAL.

**Définition** : gestion des événements heureux et malheureux des membres (art. 20), financés par un fonds séparé.

**Accès** : modifie : Administrateur, Vice-Responsable, Secrétaire aux Finances. Consulte : 1er Responsable, Secrétaire Général, Adjoint, Secrétaire aux Patrimoines.

**Ce que l'on peut faire**

| Bouton | Effet |
| --- | --- |
| **Déclarer un événement** | Type (selon le barème), membre concerné, date. La campagne de contributions du barème est créée automatiquement (par exemple 1 500 FCFA par membre pour une hospitalisation). |
| **Verser l'aide** | Enregistre la dépense prévue par le barème (par exemple 50 000 FCFA), avec la référence de l'autorisation du Bureau. Réservé aux rôles qui modifient les finances. |
| **Actualiser** | Recalcule pour chaque événement : collecté, aide versée, autres dépenses et solde. |
| **Suivre les contributions** | Ouvre le suivi de la campagne liée à l'événement sélectionné. |

## 4.6 Budget

**Feuille** : BUDGET.

**Définition** : budget annuel voté en AG, par sous-rubrique, réparti sur les 12 mois de l'exercice.

**Accès** : comme la saisie de caisse.

**Ce que l'on peut faire**

| Bouton | Effet |
| --- | --- |
| **Préparer l'exercice** | Crée une ligne par sous-rubrique, en reprenant au besoin le budget de l'année précédente. |
| **Répartir par mois** | Découpe chaque montant en 12 mois égaux, à ajuster ensuite pour les mois de forte activité. |
| **Contrôler le budget** | Vérifie que les 12 mois correspondent au total et affiche l'équilibre recettes et dépenses. |

**Bon à savoir** : saisissez le **budget initial** voté en AG, puis plus tard le **budget rectifié** ; la version initiale est conservée. La référence d'adoption (PV de l'AG) se note sur chaque ligne.

## 4.7 Suivi budgétaire

**Feuille** : SUIVI_BUDGET.

**Définition** : comparaison du budget et du réalisé, avec les écarts et les variations.

**Ce que l'on peut faire** : choisir l'exercice et le mois, puis **Calculer** et **Imprimer**. Pour chaque sous-rubrique, avec sous-totaux, totaux et résultat :

| Colonne | Contenu |
| --- | --- |
| Prévu annuel, prévu à date | Budget retenu et somme des mois écoulés |
| Réalisé à date | Total du journal, contre-passations déduites |
| Écart et écart % | En couleur au-delà de 10 % : rouge pour une recette en retrait ou une dépense en dépassement, vert dans le cas inverse |
| Exécution annuelle | Réalisé ÷ budget annuel |
| Variation mensuelle | Mois en cours comparé au mois précédent |
| Variation annuelle | Réalisé à date comparé à la même période de l'année précédente |

## 4.8 Arrêté de caisse

**Feuille** : ARRETE_CAISSE.

**Définition** : contrôle physique de la caisse en espèces par comptage des billets et des pièces, et rapprochement du compte bancaire.

**Ce que l'on peut faire**

| Bouton | Effet |
| --- | --- |
| **Calculer le solde théorique** | Affiche le solde du livre à la date du comptage. |
| **Enregistrer l'arrêté** | Archive le comptage et l'écart dans ARRETES. Un manquant peut être passé en dépense et inscrit au registre des pertes ; un excédent, en recette. |
| **Rapprochement bancaire** | Saisie du solde du relevé ; l'écart avec le livre est archivé. |
| **Remettre à zéro** | Vide le comptage. |

**Bon à savoir** : l'accueil alerte si aucun arrêté n'a été fait depuis 30 jours.

## 4.9 Pertes et remboursements

**Feuille** : PERTES.

**Définition** : registre des pertes subies par la chorale (manquants de caisse, cotisations irrécouvrables, matériel perdu ou détérioré, malversations) et de leur remboursement (art. 51).

**Ce que l'on peut faire**

| Bouton | Effet |
| --- | --- |
| **Nouvelle perte** | Type, membre ou tiers responsable, description, montant. |
| **Enregistrer un remboursement** | Crée la recette et le reçu, puis met à jour le reste dû. |
| **Actualiser** | Recalcule les montants remboursés, les restes et les statuts. |

La colonne **Échéancier** permet de noter le plan de remboursement convenu.

# 5. Vie du groupe

## 5.1 Discipline

**Feuille** : DISCIPLINE (confidentielle).

**Définition** : registre des fautes et des sanctions (art. 45 à 52), avec leurs effets sur le statut des membres.

**Accès** : modifie : Administrateur, 1er Responsable, Vice-Responsable. Consulte : Secrétaire Général, Adjoint, Évangélisation, Directeur de chœur. Invisible pour les Finances, les Patrimoines et le rôle Consultation.

**Ce que l'on peut faire**

| Bouton | Effet |
| --- | --- |
| **Nouveau dossier** | Membre, date des faits, faute (liste de l'art. 45), description, sanction, autorité, dates. Sans sanction, le dossier est « À examiner ». |
| **Décision du Bureau** | Enregistre la sanction d'un dossier à examiner, ou le classe sans suite (taper 0). |
| **Notification** | Prépare la lettre de notification (art. 49) et enregistre son mode de remise : en présence de l'intéressé ou par écrit. |
| **Lever la sanction** | Fin anticipée, avec un motif ; le membre retrouve son statut antérieur. |
| **Appliquer les statuts** | Met les statuts des membres en accord avec les sanctions en cours ou terminées. |

**Contrôles automatiques**

- Le Directeur de chœur ne prononce que des avertissements verbaux (art. 48).
- Une exclusion temporaire a une date de fin et dure 15 jours au plus.
- Les récidives des 12 derniers mois sont comptées à chaque dossier.

**Effet sur le statut du membre**

| Sanction | Statut pendant la sanction | Au pointage |
| --- | --- | --- |
| Suspension des fonctions | Suspendu | NC |
| Exclusion temporaire ou indéterminée | Exclu temporaire | NC |
| Exclusion définitive | Exclu définitif | Non pointé |

Le statut antérieur est rétabli automatiquement le lendemain de la date de fin. Le bouton **Marquer les refroidis** de l'accueil ouvre aussi un dossier « À examiner » (art. 52).

## 5.2 Planning des activités

**Feuille** : PLANNING.

**Définition** : programme annuel des activités, préparé par le Bureau et voté en AG, avec sa ligne budgétaire et sa validation paroissiale (art. 6, 20 et 24).

**Accès** : modifie : Administrateur, 1er Responsable, Vice-Responsable, Secrétaire Général, Adjoint, Évangélisation. Consulte : Finances, Patrimoines, Consultation, Directeur de chœur.

**Ce que l'on peut faire** (dans l'ordre du circuit)

| Bouton | Effet |
| --- | --- |
| **Nouvelle activité** | Intitulé, dates, type, lieu, sortie hors paroisse ou non, commission responsable, code budgétaire, budget prévu. Statut « Projet ». |
| **Planning voté en AG** | Passe toutes les activités « Projet » d'un exercice à « Votée en AG », avec la référence du PV. |
| **Validation paroissiale** | Demandée, obtenue ou refusée, avec sa référence. Un refus annule l'activité. |
| **Valider l'activité** | Valide une activité votée et crée sa séance de pointage. Une sortie hors paroisse exige la validation « Obtenue » (art. 6). |
| **Annuler** | Annule l'activité, et sa séance si elle n'est pas pointée. |
| **Actualiser le réalisé** | Additionne les dépenses de caisse dont la référence est le numéro de l'activité ; une activité dont la séance est pointée passe à « Réalisée ». |
| **Programme annuel** | Ouvre le programme imprimable (voir 5.3). |

## 5.3 Programme annuel

**Feuille** : PROGRAMME_ANNUEL.

**Définition** : version imprimable du planning d'un exercice, classée par mois, avec le budget total.

**Ce que l'on peut faire** : saisir l'exercice dans la case jaune, **Calculer**, puis **Imprimer**. Les activités annulées n'y figurent pas.

## 5.4 Mandats

**Feuille** : MANDATS.

**Définition** : registre des mandats du Bureau et des présidents de commission (art. 9 à 11) : titulaire, dates, rang (1 pour un premier mandat, 2 pour un renouvellement).

**Accès** : modifie : Administrateur, 1er Responsable, Secrétaire Général. Consulte : Vice-Responsable, Adjoint, Consultation.

**Ce que l'on peut faire**

| Bouton | Effet |
| --- | --- |
| **Nouveau mandat** | Fonction, titulaire, date de début ; la fin (2 ans) et le rang sont calculés ; le mandat précédent à la même fonction est clos. |
| **Fin anticipée** | Démission, révocation ou fin de mandat ; le poste devient vacant (élection partielle, art. 23). |
| **Élections** | Ouvre la feuille des scrutins. |

**Bon à savoir** : un 3e mandat consécutif à la même fonction est signalé, sans être bloqué. Pour une fonction du Bureau, la fonction est mise à jour dans MEMBRES et le titulaire du rôle change dans UTILISATEURS, avec un mot de passe provisoire `chorale`.

## 5.5 Élections

**Feuilles** : SCRUTINS et CANDIDATS ; procès-verbal dans PV_ELECTION.

**Définition** : organisation d'une élection du Bureau, ordinaire ou partielle (art. 21 à 23), jusqu'à la mise en place des élus.

**Accès** : comme les mandats.

**Ce que l'on peut faire**

| Bouton | Effet |
| --- | --- |
| **Nouveau scrutin** | Date, élection de tout le Bureau ou partielle (postes vacants proposés). Le nombre d'inscrits vient de la liste électorale. |
| **Ajouter un candidat** | Poste et matricule. Seul un choriste confirmé peut être candidat ; un 3e mandat consécutif est signalé. |
| **Proclamer les résultats** | Nombre de votants, puis désignation de l'élu de chaque poste (le plus de voix). Une égalité demande un second tour (art. 22). Propose ensuite de mettre en place les élus. |
| **Procès-verbal** | Prépare le PV à signer : inscrits, votants, participation, voix et pourcentage de chaque candidat, élus. |

**Marche à suivre** : générez la liste électorale, créez le scrutin, ajoutez les candidats, saisissez les voix dans CANDIDATS, proclamez, mettez en place les élus, imprimez le PV.

## 5.6 Répertoire des cantiques

**Feuille** : CANTIQUES.

**Définition** : répertoire de tous les cantiques de la chorale, avec le niveau d'apprentissage de chaque pupitre.

**Accès** : modifie : Administrateur, Évangélisation, Directeur de chœur. Consulte : 1er Responsable, Vice-Responsable, Secrétaire Général, Adjoint, Consultation.

**Ce que l'on peut faire**

| Bouton | Effet |
| --- | --- |
| **Nouveau cantique** | Ajoute un titre ; le numéro (CAN-001) est créé. |
| **Actualiser le répertoire** | Recalcule le niveau du chœur, la dernière exécution, le nombre d'exécutions sur 12 mois, et affiche le résumé de l'apprentissage par pupitre. |

**Colonnes** : titre, recueil, numéro dans le recueil, langue, thème ou temps liturgique, auteur, tonalité, niveau des pupitres soprano, alto, ténor et basse (non commencé, en apprentissage, maîtrisé), niveau du chœur (maîtrisé quand les quatre pupitres le maîtrisent).

## 5.7 Programmes des chants

**Feuilles** : PROGRAMMES ; version imprimable dans PROGRAMME_CHANTS.

**Définition** : liste des cantiques prévus pour chaque célébration, dans l'ordre et par moment (entrée, louange, offrande…).

**Accès** : comme le répertoire.

**Ce que l'on peut faire**

| Bouton | Effet |
| --- | --- |
| **Ajouter un chant** | Date, célébration, numéro du cantique, moment. L'ordre est donné automatiquement. |
| **Contrôler le programme** | Revoit tous les chants d'une date et écrit les remarques. |
| **Programme à imprimer** | Prépare la feuille à distribuer, avec le nom du Directeur de chœur. |

**Contrôles automatiques** (alerte sans blocage) : le cantique a été chanté, ou est programmé, à moins de 4 semaines de cette date ; ou il n'est pas encore maîtrisé par tous les pupitres. Un même cantique ne peut pas figurer deux fois dans le même programme.

## 5.8 Études bibliques

**Feuille** : ETUDES.

**Définition** : programme des études bibliques, de l'affermissement, des retraites, des veillées et de la formation musicale (art. 16-7).

**Accès** : comme le répertoire.

**Ce que l'on peut faire**

| Bouton | Effet |
| --- | --- |
| **Nouvelle étude** | Date, type, thème, texte biblique, orateur, lieu ; la séance de pointage est créée. |
| **Créer la séance** | Crée la séance d'une étude saisie directement dans la feuille. |
| **Actualiser** | Passe à « Réalisée » les études dont la séance est pointée. |

# 6. Paramétrage et sécurité

## 6.1 Paramètres

**Feuille** : PARAMETRES.

**Définition** : réglages généraux de l'application : identité du groupe, seuils, durées, montants et apparence.

**Accès** : modifie : Administrateur. Consulte : 1er Responsable.

**Ce que l'on peut faire**

| Bouton ou colonne | Effet |
| --- | --- |
| Colonne **Valeur** | Seule colonne modifiable ; la description de chaque clé explique son rôle. |
| **Thème et couleurs** | Cinq thèmes prédéfinis ou trois couleurs au choix. |
| **Importer le logo** | Place le logo sur l'accueil et propose des couleurs tirées du logo. |
| **Couleurs du logo** | Trois propositions de thème calculées à partir du logo, affichées en couleur dans les colonnes E à H. |
| **Reprendre un ancien fichier** | Copie toutes les données d'une version précédente du fichier : membres, présences, caisse, patrimoine, discipline, mandats, cantiques, paramètres, mots de passe, logo. |

**Principaux réglages** : nom du groupe, sigle des matricules, église, paroisse, ville ; durée d'observation ; seuil du refroidi ; seuils électoraux ; cotisation mensuelle ; soldes d'ouverture ; seuil d'autorisation des dépenses ; écart budgétaire ; caution de location ; mois d'inventaire ; durée maximale d'exclusion ; durée des mandats ; délai de répétition d'un cantique ; dossier des PDF ; masquage des mots de passe.

## 6.2 Listes de choix

**Feuille** : LISTES.

**Définition** : toutes les listes déroulantes de l'application.

**Ce que l'on peut faire** : ajouter, renommer ou désactiver des valeurs dans chaque colonne : statuts (avec, pour chacun, s'il est pointé, son code par défaut et s'il doit la cotisation), pupitres, commissions, fonctions du Bureau, situations, fautes, sanctions, autorités, recueils, langues, moments, types d'étude, statuts de dossier…

**Bon à savoir** : ne renommez pas une valeur déjà utilisée sans corriger les lignes qui l'emploient.

## 6.3 Types d'activités

**Feuille** : TYPES_ACTIVITE.

**Définition** : catalogue des types de séances : code, libellé, jours (LUN à DIM séparés par « ; »), heures de début et de fin, prise en compte dans le taux, actif.

**Ce que l'on peut faire** : modifier les jours et horaires des répétitions, ajouter un type (par exemple une répétition de pupitre), exclure un type du taux.

## 6.4 Codes de présence

**Feuille** : CODES_PRESENCE.

**Définition** : codes utilisés au pointage, avec leur poids dans le taux, leur exclusion éventuelle du calcul, leur pénalité et l'obligation d'un motif.

**Ce que l'on peut faire** : modifier le poids d'un départ anticipé, le montant d'une pénalité, ou ajouter un code.

## 6.5 Contrôles d'adhésion

**Feuille** : CONTROLES_ADHESION.

**Définition** : liste des éléments à vérifier avant la réception d'un nouveau choriste (15 au plus).

**Ce que l'on peut faire** : pour chaque élément, indiquer le groupe, s'il est obligatoire, s'il va au patrimoine (avec sa valeur et sa catégorie) et à qui il s'applique. **Mettre à jour les dossiers** reporte les changements dans les dossiers d'adhésion.

## 6.6 Rubriques budgétaires

**Feuille** : RUBRIQUES.

**Définition** : plan des rubriques et sous-rubriques de recettes et de dépenses : codes `R…` (recettes), `D…` (dépenses), `S…` et `T…` (caisse sociale).

**Ce que l'on peut faire** : ajouter une sous-rubrique en suivant le même modèle de code, ou en désactiver une (Actif = NON). Ne supprimez jamais une rubrique qui a déjà servi.

## 6.7 Barème social

**Feuille** : BAREME_SOCIAL.

**Définition** : barème de la caisse sociale (art. 20) : pour chaque type d'événement, la contribution par membre, l'aide versée, l'affectation et la présence de la chorale.

**Ce que l'on peut faire** : modifier les montants, ou ajouter un type d'événement.

## 6.8 Catégories du patrimoine

**Feuille** : CATEGORIES_PAT.

**Définition** : catégories de biens, avec leur préfixe de code et leur durée d'amortissement.

**Valeurs par défaut** : Administration ADM 3 ans, Matériel de musique MUS 5 ans, Informatique INF 3 ans, Mobilier MOB 5 ans, Cuisine et kit de sortie CUI 3 ans, Tenues et textiles TEX 3 ans, Immobilier IMM 20 ans.

**Ce que l'on peut faire** : ajouter une catégorie (par exemple « Décoration », préfixe DEC) ou modifier une durée.

## 6.9 Utilisateurs

**Feuille** : UTILISATEURS.

**Définition** : liste des rôles de connexion et de leurs titulaires.

**Accès** : Administrateur seulement.

**Ce que l'on peut faire**

| Bouton ou colonne | Effet |
| --- | --- |
| Colonne **Titulaire** | Nom de la personne qui tient le rôle. |
| Colonne **Actif** | NON empêche la connexion avec ce rôle. |
| Colonnes **Assure l'intérim de**, **Début**, **Fin** | Donnent temporairement à un rôle les droits d'un autre (art. 16). |
| **Réinitialiser un mot de passe** | Donne un mot de passe provisoire à un rôle ; son titulaire devra le changer à la connexion suivante. |

La colonne **Dernière connexion** se remplit seule.

## 6.10 Journal des actions

**Feuille** : JOURNAL.

**Définition** : trace de toutes les actions : connexions, modifications de cellules, enregistrements, annulations, erreurs.

**Accès** : Administrateur, en consultation.

**Ce que l'on peut faire** : filtrer par date, rôle, feuille ou action pour retrouver qui a fait quoi et quand. Le journal ne se modifie pas.

# 7. Actions de l'accueil

## 7.1 Actualiser les alertes

**Définition** : recalcule la liste « Alertes du jour » affichée sous le menu.

**Alertes possibles** :

- séances passées non pointées ;
- membres à marquer comme refroidis ;
- dossiers d'adhésion à décider, qui se terminent bientôt, ou incomplets ;
- membres avec 3 mois d'arriérés ou plus ;
- solde négatif ;
- arrêté de caisse de plus de 30 jours ;
- retours de matériel en retard ;
- locations en attente d'une étape ;
- inventaire attendu ;
- achats de matériel sans fiche ;
- biens à réparer ;
- dossiers de discipline à examiner, non notifiés, ou qui se terminent ;
- activités proches non validées, sorties hors paroisse sans validation ;
- fins de mandat, mandats échus, postes vacants ;
- chants à revoir dans le prochain programme, études prévues dans les 7 jours.

**Bon à savoir** : les alertes se recalculent aussi à chaque connexion. Le rétablissement des statuts en fin de sanction se fait à ce moment.

## 7.2 Marquer les refroidis

**Définition** : application de l'art. 52 aux membres absents sans justification depuis plus de 2 mois.

**Ce que l'on peut faire** : après confirmation, les membres listés passent au statut « Refroidi » et un dossier de discipline « À examiner » est ouvert pour chacun.

## 7.3 Changer mon mot de passe

**Définition** : remplacement du mot de passe du rôle connecté (6 caractères au minimum). L'ancien mot de passe est demandé.

## 7.4 Sauvegarder une copie

**Définition** : copie datée du fichier dans le sous-dossier `Sauvegardes`, à côté du classeur. Un rappel apparaît à la fermeture après 7 jours sans sauvegarde.

## 7.5 Se déconnecter

**Définition** : fin de session. Toutes les feuilles sont masquées, le tableau de bord est vidé, et l'accueil revient à l'écran de connexion (case jaune **Rôle** et bouton **Se connecter**).

# Annexe : droits par fonction

| Domaine | Modifie | Consulte |
| --- | --- | --- |
| Tableau de bord, rapport pour l'AG | Administrateur | Tous les autres rôles |
| Point financier, livre de caisse, saisie, journal, budget, suivi, arrêté, pertes, rubriques | Administrateur, Finances | 1er Responsable, Vice-Responsable, Patrimoines |
| Membres, fiche d'un membre, nouveaux choristes | Administrateur, Secrétaire Général, Adjoint | 1er Responsable, Vice-Responsable, Finances, Évangélisation, Consultation, Directeur de chœur |
| Séances, pointage, présences, taux, pupitres, fiche d'appel | Administrateur, Secrétaire Général, Adjoint | 1er Responsable, Vice-Responsable, Évangélisation, Consultation, Directeur de chœur |
| Liste électorale, mandats, élections | Administrateur, 1er Responsable, Secrétaire Général | Vice-Responsable, Adjoint, Consultation |
| Patrimoine, mouvements, locations, inventaire, synthèse, étiquettes, catégories | Administrateur, Patrimoines | 1er Responsable, Vice-Responsable, Finances, Consultation, Directeur de chœur |
| Cotisations, cotisations spéciales | Administrateur, Finances | 1er Responsable, Vice-Responsable, Secrétaire Général, Adjoint, Patrimoines |
| Caisse sociale, barème | Administrateur, Vice-Responsable, Finances | 1er Responsable, Secrétaire Général, Adjoint, Patrimoines |
| Discipline | Administrateur, 1er Responsable, Vice-Responsable | Secrétaire Général, Adjoint, Évangélisation, Directeur de chœur |
| Planning, programme annuel | Administrateur, 1er Responsable, Vice-Responsable, Secrétaire Général, Adjoint, Évangélisation | Finances, Patrimoines, Consultation, Directeur de chœur |
| Cantiques, programmes des chants, études | Administrateur, Évangélisation, Directeur de chœur | 1er Responsable, Vice-Responsable, Secrétaire Général, Adjoint, Consultation |
| Paramètres, listes, types, codes, contrôles d'adhésion | Administrateur | 1er Responsable |
| Utilisateurs | Administrateur | – |
| Journal des actions | – | Administrateur |
