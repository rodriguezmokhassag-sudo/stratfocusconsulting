# Gestion Chorale – Guide de démarrage (lot 1)

Ce guide couvre le **lot 1 (socle)** : connexion par rôle, paramètres, membres, nouveaux choristes, calendrier des séances, pointage, taux de participation, liste électorale et fiche d'appel.

## Les deux fichiers

| Fichier | Usage |
| --- | --- |
| `dist/GestionChorale.xlsm` | Modèle vierge, prêt à être utilisé par n'importe quelle chorale ou groupe. L'identité et le barème de la Chorale Amour du Cœur sont déjà saisis et restent modifiables. |
| `dist/GestionChorale_DEMO.xlsm` | Même application, avec 100 membres et une année de présences **fictifs**, pour la formation et les tests. |

## 1. Installation (une seule fois)

L'application fonctionne sur Windows avec Excel 2010, 2013, 2016, 2019, 2021 ou Microsoft 365. Elle ne fonctionne pas sur Mac, sur téléphone ni dans Excel en ligne.

1. Copiez le fichier dans un dossier dédié, par exemple `Documents\Chorale\`.
2. Autorisez les macros de ce dossier : **Fichier > Options > Centre de gestion de la confidentialité > Paramètres du Centre de gestion de la confidentialité > Emplacements approuvés > Ajouter un nouvel emplacement**, puis choisissez le dossier.
3. Si Windows a bloqué le fichier téléchargé : clic droit sur le fichier > **Propriétés** > cochez **Débloquer** > OK.
4. Ouvrez le fichier. Seule la page **ACCUEIL** est visible tant que personne n'est connecté.

## 2. Première connexion

1. Dans la case jaune **Rôle**, choisissez **Administrateur**.
2. Cliquez sur **Se connecter**. Le mot de passe provisoire est **chorale**.
3. Choisissez votre mot de passe personnel (6 caractères au minimum).

Chaque rôle du Bureau a le même mot de passe provisoire (`chorale`), à changer à sa première connexion. L'administrateur peut réinitialiser un mot de passe oublié (feuille **UTILISATEURS**).

| Rôle | Voit et modifie | Consulte seulement |
| --- | --- | --- |
| Administrateur | Tout | Journal des actions |
| 1er Responsable | Liste électorale | Membres, présences, paramètres, patrimoine |
| Vice-Responsable | – | Membres, présences, liste électorale, patrimoine |
| Secrétaire Général et Adjoint | Membres, nouveaux choristes, séances, pointage | – |
| Secrétaire aux Finances | – | Membres, patrimoine (les finances arrivent au lot 2) |
| Secrétaire aux Patrimoines | Patrimoine | – |
| Évangélisation | – | Membres, présences |
| Consultation (conseiller paroissial) | – | Membres, présences, liste électorale, patrimoine |

**Intérim (art. 16)** : dans **UTILISATEURS**, la colonne « Assure l'intérim de » donne temporairement à un rôle les droits d'un autre, entre deux dates.

## 3. Mise en route du modèle vierge

1. **PARAMETRES** : vérifiez le nom du groupe, le sigle (préfixe des matricules), les seuils et les durées.
2. **Thème et couleurs** et **Importer le logo** (boutons de la feuille PARAMETRES) : choisissez l'un des 5 thèmes ou vos 3 couleurs.
3. **TYPES_ACTIVITE** : jours et horaires des répétitions (mercredi et samedi de 18h00 à 20h30 par défaut), cultes et autres activités.
4. **MEMBRES** : saisissez ou collez les membres existants avec le statut « Choriste confirmé ». Le matricule se crée automatiquement dès que le nom est saisi.
5. **SEANCES** > **Générer le calendrier** : crée toutes les séances régulières de l'année.

## 4. Utilisation courante

### Pointer une séance (Secrétariat)

1. Ouvrez **POINTAGE** et cliquez sur **Prochaine séance à pointer**. Vous pouvez aussi choisir la séance dans la case jaune, puis cliquer sur **Charger la séance**.
2. Tous les membres attendus sont pré-remplis avec « P ». Corrigez seulement les exceptions :

   | Code | Signification |
   | --- | --- |
   | P | Présent |
   | R | Retard (pénalité de 50 FCFA) |
   | RX | Retard de plus de 15 minutes, non admis (art. 50) |
   | DA | Départ anticipé |
   | AJ | Absent justifié (motif obligatoire) |
   | ANJ | Absent non justifié |
   | NC | Non concerné |

3. Cliquez sur **Valider le pointage**. Une séance déjà pointée peut être rechargée et corrigée sans créer de doublons.

**Fiche d'appel** : imprime la liste des membres attendus, par pupitre, pour pointer sur papier.

### Taux de participation

Dans **TAUX**, utilisez **Ce mois**, **Mois précédent**, **Ce trimestre** ou **Cette année**, ou saisissez deux dates puis cliquez sur **Calculer**.

- Le taux vaut (P + R + DA × 0,5) ÷ séances attendues. Les absences justifiées (AJ) et les membres non concernés (NC) sont exclus du calcul.
- Le classement est coloré : vert à partir de 80 %, orange de 50 à 79 %, rouge en dessous.
- À droite : synthèse par pupitre, par type d'activité et évolution mois par mois.

### Nouveaux choristes (art. 26 à 28)

1. **MEMBRES** > **Nouveau membre** : crée le matricule, met le statut « En observation » et ouvre le dossier d'adhésion.
2. **ADHESIONS** : choisissez la catégorie d'entrée, puis cochez « OUI » pour chaque élément remis. Cela couvre le règlement, la lettre de recommandation en cas de transfert, la Bible, les cantiques, le kit de table et les tenues.
3. **Actualiser les dossiers** calcule la fin d'observation (3 mois), l'assiduité, les éléments manquants et une **proposition**.
4. Le Bureau décide dans la colonne **Décision** :
   - **Confirmer** : date de réception et officiant obligatoires.
   - **Prolonger** : nouvelle date et motif obligatoires.
   - **Refuser** : motif obligatoire.
5. **Appliquer les décisions** met la fiche du membre à jour. Le kit remis (chaise, gobelet, couverts) est alors ajouté automatiquement au **PATRIMOINE**.

### Alertes de l'accueil

Après chaque connexion, l'accueil signale :

- les séances passées non pointées ;
- les membres absents depuis plus de 2 mois sans justification (bouton **Marquer les refroidis**, art. 52) ;
- les dossiers d'adhésion à décider ou incomplets.

### Liste électorale (art. 21)

**ELECTEURS** > **Générer la liste** retient les choristes confirmés présents depuis au moins 3 mois, avec au moins 60 % d'assiduité sur cette période. Ces deux seuils sont réglables.

## 5. Sécurité et sauvegardes

- Quand le fichier est fermé, toutes les feuilles sont masquées. Seuls les rôles connectés voient leurs feuilles.
- Toute modification est tracée dans **JOURNAL**, y compris les erreurs éventuelles.
- **Sauvegarder une copie** (accueil) crée une copie datée dans le sous-dossier `Sauvegardes`. Un rappel apparaît à la fermeture après 7 jours sans sauvegarde.
- La protection par mot de passe d'Excel évite les erreurs et les curieux. Elle ne remplace ni les sauvegardes ni le contrôle des comptes.
- Recommandation : l'administrateur peut aussi verrouiller le code VBA (Alt+F11 > Outils > Propriétés de VBAProject > Protection).

## 6. Ce qui arrive dans les lots suivants

| Lot | Contenu |
| --- | --- |
| 2. Finances | Budget, caisses, journal, cotisations, pénalités, caisse sociale, reçus |
| 3. Patrimoine | Inventaire complet, amortissements, prêts, locations, inventaire physique, pertes |
| 4. Compléments | Discipline, planning, mandats et élections, cantiques |
| 5. Pilotage | Tableau de bord, rapports PDF, suggestion de couleurs à partir du logo, guide complet |
