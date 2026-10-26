# Gestion Chorale (Excel + VBA)

Application Excel de gestion d'une chorale, conçue à partir du règlement intérieur de la Chorale Amour du Cœur (EEC, Paroisse de Tchimbambouka) et réutilisable par tout autre groupe.

- Guides utilisateur : [GUIDE_LOT1.md](GUIDE_LOT1.md) (socle), [GUIDE_LOT2.md](GUIDE_LOT2.md) (finances), [GUIDE_LOT3.md](GUIDE_LOT3.md) (patrimoine) et [GUIDE_LOT4.md](GUIDE_LOT4.md) (discipline, planning, mandats, cantiques)
- Fichiers à utiliser : `dist/GestionChorale.xlsm` (modèle vierge) et `dist/GestionChorale_DEMO.xlsm` (données fictives)

## Organisation du dépôt

| Dossier | Contenu |
| --- | --- |
| `src/vba/` | Modules VBA standards (`.bas`) : configuration, sécurité, interface, membres, adhésions, séances, pointage, statistiques, journal, application, caisse, budget, cotisations, caisse sociale, patrimoine, locations, discipline, planning, mandats et élections, cantiques |
| `src/doc/` | Code des événements du classeur et des feuilles (`.cls`) |
| `build/` | Construction des classeurs : `build.py` (feuilles, formats, listes, données), `lot2.py` (feuilles financières), `lot3.py` (patrimoine), `lot4.py` (discipline, planning, mandats, cantiques), `demo.py`, `demo_fin.py`, `demo_pat.py` et `demo_lot4.py` (données fictives), `vbaproject.py` + `cfb.py` (génération du projet VBA `vbaProject.bin`) |
| `tests/` | Tests automatisés exécutés sous LibreOffice |
| `dist/` | Classeurs générés |

## Construire

Il faut Python 3 et `xlsxwriter` :

```bash
python3 build/build.py
```

Le code VBA source est encodé en Windows-1252 et intégré sans p-code : Excel le recompile à l'ouverture, quelle que soit sa version (32 ou 64 bits). Le script refuse tout caractère non représentable en Windows-1252.

## Tester

Les tests pilotent les macros dans LibreOffice. Ils demandent `soffice` et le module Python `uno`.

```bash
CHORALE_TESTS=1 CHORALE_OUT=/tmp/out python3 build/build.py
python3 tests/run_tests.py /tmp/out/GestionChorale_DEMO.xlsm modTests.T_All     # 194 contrôles (lots 1 à 4)
python3 tests/run_tests.py /tmp/out/GestionChorale.xlsm modTests.T_Vierge       # modèle vierge
python3 tests/run_tests.py /tmp/out/GestionChorale.xlsm modTests.T_Reprise      # reprise d'un fichier du lot 3 (démo du lot 3 copiée dans /tmp/claude-0/lot3_demo.xlsm)
python3 tests/check_compile.py                                                   # compilation module par module
```

En mode test (`G_TestMode`), la protection des feuilles et la création des boutons sont désactivées : LibreOffice ne gère ni `UserInterfaceOnly` ni `Shapes.AddShape`. Toute la logique métier est exercée.

Pour la compatibilité, le code évite quelques constructions mal gérées par d'autres moteurs VBA :

- les paramètres facultatifs sont recopiés dans des variables locales ;
- une collection de niveau module est lue avec `.Item` ;
- une plage se désigne par une seule adresse, jamais par une plage multiple du type `"C5,E5,G5"` ;
- pas de `IIf` contenant une division (VBA évalue les deux branches) ;
- pas de noms de variables qui ne diffèrent que par la casse (`srub` et `sRub` sont la même variable) ;
- pas de `If … Then MsgBox … Else MsgBox …` sur une seule ligne : forme en bloc ;
- pas de variables nommées `lib`, `base`, `me`, `res` ou `top`, ni de procédure publique portant le nom d'une procédure d'un autre module.
