# Guide d'auto-édition STFC : « Le Code Secret de l'Acheteur »

Éditeur : **STFC Éditions**, marque éditoriale de Stratfocus Consulting (Brazzaville, République du Congo).
Auteur : Rodriguez MOKHASSA.

## 1. Fichiers prêts à l'emploi

| Fichier | Usage |
|---|---|
| `sortie/Le-Code-Secret-de-l-Acheteur.pdf` | Version de lecture : 127 pages, 15,24 × 22,86 cm, Garamond 11 pt, polices incorporées, couverture en page 1 (écran, envoi par WhatsApp ou courriel, version numérique). |
| `sortie/Le-Code-Secret-de-l-Acheteur-interieur-impression.pdf` | Intérieur pour l'imprimeur : mêmes 127 pages, avec une page de titre sobre à la place de la couverture. |
| `sortie/Le-Code-Secret-de-l-Acheteur.docx` | Version modifiable (Word) pour les dernières corrections. |
| `sortie/Couverture-complete-impression.pdf` | Couverture complète pour l'imprimeur : 4e de couverture, dos de 7,3 mm et 1re de couverture, avec 3,2 mm de fond perdu. Format total 31,84 × 23,50 cm. |
| `sortie/Couverture-complete-impression.png` | Même couverture en image (300 dpi). |

## 2. Étapes avant publication

1. **Relecture humaine finale.** Faire relire le PDF par une personne extérieure (orthographe, noms, chiffres). La relecture automatique est faite, elle ne remplace pas un œil humain.
2. **Compléter les éléments manquants** : biographie détaillée de l'auteur (annexe D), coordonnées de STFC, mentions légales.
3. **Couverture en haute définition.** L'image actuelle (1 024 × 1 536 pixels) donne environ 170 dpi à l'impression ; les imprimeurs demandent 300 dpi. Demander au graphiste le fichier source en 1 838 × 2 775 pixels minimum.
4. **ISBN.** Un ISBN distinct est nécessaire pour la version imprimée et pour la version numérique.
   - Se renseigner d'abord auprès de la **Bibliothèque nationale du Congo** (Brazzaville) sur l'attribution d'ISBN aux éditeurs congolais. Aucune source publique consultée ne confirme l'existence d'une agence ISBN nationale au Congo-Brazzaville.
   - À défaut, Amazon KDP fournit un ISBN gratuit, mais il n'est valable que sur Amazon et l'éditeur affiché sera alors « Independently published » au lieu de STFC Éditions.
5. **Dépôt légal.** Déposer les exemplaires requis à la Bibliothèque nationale du Congo, à Brazzaville, dès la parution, puis compléter la mention « Dépôt légal » page 2.

## 3. Impression à la demande (Amazon KDP)

| Paramètre | Valeur à choisir |
|---|---|
| Format | 6 × 9 pouces (15,24 × 22,86 cm) |
| Papier | Blanc, intérieur noir et blanc |
| Fond perdu de l'intérieur | Non |
| Finition de couverture | Mate (cohérente avec le style noir et blanc) |
| Fichier intérieur | `Le-Code-Secret-de-l-Acheteur-interieur-impression.pdf` |
| Fichier couverture | `Couverture-complete-impression.pdf` |

Le dos a été calculé pour 128 pages imprimées (127 pages + 1 page blanche ajoutée par l'imprimeur), à 0,002252 pouce par page sur papier blanc. Si le nombre de pages change, relancer `python3 build/couverture.py`, qui recalcule automatiquement la largeur du dos. Vérifier avec le gabarit officiel de KDP (« Cover Calculator ») avant le téléversement.

## 4. Impression locale (Brazzaville, Pointe-Noire)

Demander au moins deux devis en précisant :

- format fini 15,24 × 22,86 cm, 128 pages, reliure dos carré collé ;
- intérieur noir sur papier offset 80 ou 90 g ;
- couverture 300 g, une face en quadrichromie (le visuel est en noir et blanc), pelliculage mat ;
- fichiers fournis en PDF : `Le-Code-Secret-de-l-Acheteur-interieur-impression.pdf` et `Couverture-complete-impression.pdf` ;
- quantité de départ raisonnable (par exemple 100 à 300 exemplaires) pour tester le marché, selon le principe de la perte acceptable présenté au chapitre 3.

Demander un **bon à tirer** (un exemplaire d'essai) avant le tirage complet.

## 5. Version numérique

Le fichier Word peut être converti en livre numérique (EPUB) pour Amazon Kindle et les autres librairies en ligne. La couverture seule (1re de couverture) sert alors d'image de couverture.

## 6. Lancement commercial

Appliquer au livre les méthodes du livre lui-même :

- **Preuve sociale** : faire lire le livre à 10 ou 15 dirigeants et commerçants avant la sortie, et recueillir leurs avis.
- **Réciprocité** : offrir un extrait gratuit (chapitre 1 et fiches de l'annexe A) sur WhatsApp et LinkedIn.
- **Rareté réelle** : séance de dédicace ou atelier de lancement à places limitées à Brazzaville et Pointe-Noire.
- **Paiement simple** : vente directe avec paiement MTN MoMo ou Airtel Money et livraison.
- **Prescripteurs** : chambres de commerce, associations de commerçants, écoles de commerce, réseaux de femmes entrepreneures.
- **Offre STFC** : proposer le livre comme support des formations et ateliers du cabinet.
