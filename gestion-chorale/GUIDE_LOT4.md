# Gestion Chorale – Guide du lot 4

Le lot 4 ajoute quatre modules :

- discipline et sanctions (art. 45 à 52) ;
- planning annuel des activités (art. 6, 20 et 24) ;
- mandats et élections (art. 9 à 11 et 21 à 23) ;
- cantiques et vie spirituelle (art. 16-7).

Il crée aussi un nouveau rôle, **Directeur de chœur (maître de chants)**. Les lots 1 à 3 sont conservés ([GUIDE_LOT1.md](GUIDE_LOT1.md), [GUIDE_LOT2.md](GUIDE_LOT2.md), [GUIDE_LOT3.md](GUIDE_LOT3.md)).

## 0. Passer au lot 4

1. Ouvrez le nouveau `GestionChorale.xlsm` en **Administrateur**.
2. Cliquez sur **PARAMETRES > Reprendre un ancien fichier** et choisissez votre fichier actuel (lot 1, 2 ou 3). Toutes les données sont reprises, ainsi que les mots de passe.
3. Dans **UTILISATEURS**, indiquez le **titulaire** du rôle Directeur de chœur. Son mot de passe de départ est `chorale` ; il devra le changer à sa première connexion.
4. Saisissez la composition actuelle du Bureau dans **MANDATS** (bouton **Nouveau mandat**), avec la date de début du mandat en cours.

Les nouveaux paramètres se trouvent dans la section « Discipline, planning, mandats, cantiques » de **PARAMETRES** :

| Paramètre | Valeur par défaut |
| --- | --- |
| Durée maximale d'une exclusion temporaire (art. 48) | 15 jours |
| Période de recherche des récidives | 12 mois |
| Alerte pour les activités proches non validées | 30 jours |
| Durée d'un mandat (art. 11) | 2 ans |
| Mandats consécutifs autorisés | 2 (mandat renouvelable une fois) |
| Alerte avant la fin des mandats | 90 jours |
| Délai minimum avant de rechanter un même cantique | 4 semaines |

## 1. Droits

| Rôle | Discipline | Planning | Mandats et élections | Cantiques et études |
| --- | --- | --- | --- | --- |
| Administrateur | Modifie | Modifie | Modifie | Modifie |
| 1er Responsable | Modifie | Modifie | Modifie | Consulte |
| Vice-Responsable | Modifie | Modifie | Consulte | Consulte |
| Secrétaire Général | Consulte | Modifie | Modifie | Consulte |
| Secrétaire Général Adjoint | Consulte | Modifie | Consulte | Consulte |
| Secrétaire à l'Évangélisation | Consulte | Modifie | – | Modifie |
| **Directeur de chœur** | Consulte | Consulte | – | **Modifie** |
| Secrétaire aux Finances | – | Consulte | – | – |
| Secrétaire aux Patrimoines | – | Consulte | – | – |
| Consultation | – | Consulte | Consulte | Consulte |

Les feuilles de discipline sont **confidentielles** : elles sont masquées pour les Finances, les Patrimoines et le rôle Consultation. Vous pouvez ajuster cette matrice dans la feuille **DROITS** (Administrateur).

## 2. Discipline et sanctions (feuille DISCIPLINE)

### Enregistrer un dossier

**Nouveau dossier** demande :

- le matricule du membre et la date des faits ;
- la faute (liste de l'art. 45, modifiable dans LISTES) et la description ;
- la sanction, l'autorité qui la prononce et, si besoin, les dates de début et de fin.

Laissez la sanction vide si le dossier doit d'abord passer devant le Bureau : il est alors classé « À examiner ». Le bouton **Décision du Bureau** enregistre ensuite la sanction, ou classe le dossier sans suite (tapez 0).

### Contrôles automatiques

- Le **Directeur de chœur** ne prononce que des **avertissements verbaux** (art. 48). Ces avertissements sont enregistrés comme notifiés le jour même.
- Une **exclusion temporaire** doit avoir une date de fin, et ne peut pas dépasser **15 jours**.
- Le nombre de **récidives** sur les 12 derniers mois est calculé à chaque dossier.

### Statut du membre pendant la sanction

| Sanction | Statut pendant la sanction | Au pointage |
| --- | --- | --- |
| Suspension des fonctions | Suspendu | NC |
| Exclusion temporaire ou indéterminée | Exclu temporaire | NC |
| Exclusion définitive | Exclu définitif | Non pointé |

Le statut antérieur est mémorisé. Il est **rétabli automatiquement** le lendemain de la date de fin, à l'actualisation des alertes de l'accueil. **Lever la sanction** rétablit le statut avant la date prévue.

### Notification (art. 49)

**Notification** prépare la lettre à remettre au membre : faute, sanction, période, antécédents, signatures du 1er Responsable et du Secrétaire Général. Indiquez le mode de remise :

- en présence de l'intéressé ;
- par écrit, s'il refuse de se présenter.

Une sanction sans durée (avertissement, blâme) est close une fois notifiée.

### Membres refroidis (art. 52)

Le bouton **Marquer les refroidis** de l'accueil ouvre aussi un dossier « À examiner » pour chaque membre concerné. Il n'y a pas de doublon si le dossier existe déjà.

## 3. Planning des activités (feuille PLANNING)

Le circuit d'une activité est le suivant :

1. **Nouvelle activité** (statut « Projet ») : dates, type d'activité, lieu, sortie hors paroisse ou non, commission responsable, **code budgétaire** (rubrique de dépense) et budget prévu.
2. **Planning voté en AG** fait passer toutes les activités « Projet » de l'exercice au statut « Votée en AG », avec la référence du PV.
3. **Validation paroissiale** enregistre la réponse du bureau paroissial ou consistorial : demandée, obtenue ou refusée. Une validation refusée annule l'activité.
4. **Valider l'activité** :
   - une sortie **hors paroisse** n'est validée qu'avec une validation paroissiale « Obtenue » (art. 6) ;
   - la **séance de pointage est créée** automatiquement dans SEANCES.
5. **Actualiser le réalisé** :
   - le **réalisé** est la somme des dépenses de caisse dont la **Référence** est le N° de l'activité (par exemple `ACT-2026-05`, saisi dans la case Référence de SAISIE_CAISSE) ;
   - une activité dont la séance est pointée passe à « Réalisée ».

**Programme annuel** imprime la liste des activités de l'exercice par mois, avec le budget total, pour l'AG. **Annuler** annule l'activité et sa séance si elle n'a pas été pointée.

## 4. Mandats et élections

### Mandats (feuille MANDATS)

Chaque ligne est un mandat : organe, fonction, titulaire, début, fin et **rang**. Le rang vaut 2 pour un mandat renouvelé.

- **Nouveau mandat** : la fin est calculée (2 ans) et le mandat précédent à la même fonction est clos.
- **Fin anticipée** : démission, révocation ou fin de mandat. Le poste devient vacant, ce qui appelle une élection partielle (art. 23).

### Élections (feuilles SCRUTINS et CANDIDATS)

1. Générez la **liste électorale** (feuille ELECTEURS, lot 1).
2. **Nouveau scrutin** : élection de tout le Bureau, ou élection partielle des postes vacants.
3. **Ajouter un candidat** : seul un choriste confirmé peut être candidat. Si le candidat était élu, et que ce serait son **3e mandat consécutif** au même poste, un avertissement s'affiche ; la candidature est enregistrée quand même.
4. Saisissez les **voix** dans la feuille CANDIDATS.
5. **Proclamer les résultats** : le candidat qui a le plus de voix est élu. En cas d'égalité, l'application demande un second tour (art. 22).
6. Acceptez la **mise en place des élus**. Pour chaque poste :
   - le nouveau mandat est créé ;
   - la « Fonction au Bureau » est mise à jour dans MEMBRES ;
   - le titulaire du rôle change dans UTILISATEURS. Si c'est une nouvelle personne, son mot de passe est réinitialisé à `chorale` et devra être changé à la première connexion.
7. **Procès-verbal** prépare le PV à signer : inscrits, votants, participation, voix et pourcentage de chaque candidat, élus.

## 5. Cantiques et vie spirituelle

### Répertoire (feuille CANTIQUES)

Saisissez les cantiques au fur et à mesure. Le **N°** (`CAN-001`) est créé automatiquement.

Pour chaque pupitre (soprano, alto, ténor, basse), indiquez le niveau : non commencé, en apprentissage ou maîtrisé. Le **niveau du chœur** est « Maîtrisé » quand les quatre pupitres le maîtrisent.

**Actualiser le répertoire** recalcule :

- la dernière exécution ;
- le nombre d'exécutions sur 12 mois ;
- le résumé de l'apprentissage par pupitre.

### Programmes des chants (feuille PROGRAMMES)

**Ajouter un chant** demande la date, la célébration, le N° du cantique et le moment (entrée, louange, offrande…). Une alerte s'affiche dans deux cas, sans bloquer :

- le chant a été chanté, ou est programmé, **à moins de 4 semaines** de cette date ;
- le chant n'est **pas encore maîtrisé** par tous les pupitres.

**Contrôler le programme** revoit tous les chants d'une date. **Programme à imprimer** remplit la feuille PROGRAMME_CHANTS, avec le nom du Directeur de chœur, à distribuer aux choristes.

### Études bibliques (feuille ETUDES)

**Nouvelle étude** enregistre :

- l'étude biblique, l'affermissement, la retraite, la veillée ou la formation musicale ;
- le thème, le texte biblique, l'orateur et le lieu.

La **séance de pointage** est créée automatiquement. **Actualiser** passe à « Réalisée » les études dont la séance est pointée.

## 6. Alertes de l'accueil

| Module | Alerte |
| --- | --- |
| Discipline | Dossiers à examiner, sanctions non notifiées, sanctions qui se terminent dans les 7 jours |
| Planning | Activités des 30 prochains jours non validées, sorties hors paroisse sans validation obtenue |
| Mandats | Mandats qui finissent dans les 90 jours, mandats échus, postes vacants, 3e mandat consécutif |
| Cantiques | Chants à revoir dans le programme des 14 prochains jours, études prévues dans les 7 jours |

Les alertes s'affichent désormais **sous le dernier bouton du menu**, quel que soit le nombre de boutons du rôle connecté.
