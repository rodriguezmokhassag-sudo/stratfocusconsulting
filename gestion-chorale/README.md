# Gestion Chorale (Excel + VBA)

Application Excel de gestion d'une chorale, conçue à partir du règlement intérieur de la Chorale Amour du Cœur (EEC, Paroisse de Tchimbambouka) et réutilisable par tout autre groupe.

- Guide utilisateur du lot livré : [GUIDE_LOT1.md](GUIDE_LOT1.md)
- Fichiers à utiliser : `dist/GestionChorale.xlsm` (modèle vierge) et `dist/GestionChorale_DEMO.xlsm` (données fictives)

## Organisation du dépôt

| Dossier | Contenu |
| --- | --- |
| `src/vba/` | Modules VBA standards (`.bas`) : configuration, sécurité, interface, membres, adhésions, séances, pointage, statistiques, journal, application |
| `src/doc/` | Code des événements du classeur et des feuilles (`.cls`) |
| `build/` | Construction des classeurs : `build.py` (feuilles, formats, listes, données), `demo.py` (données fictives), `vbaproject.py` + `cfb.py` (génération du projet VBA `vbaProject.bin`) |
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
python3 tests/run_tests.py /tmp/out/GestionChorale_DEMO.xlsm modTests.T_All     # 47 contrôles
python3 tests/run_tests.py /tmp/out/GestionChorale.xlsm modTests.T_Vierge       # modèle vierge
python3 tests/check_compile.py                                                   # compilation module par module
```

En mode test (`G_TestMode`), la protection des feuilles et la création des boutons sont désactivées : LibreOffice ne gère ni `UserInterfaceOnly` ni `Shapes.AddShape`. Toute la logique métier est exercée.

Pour la compatibilité, le code évite quelques constructions mal gérées par d'autres moteurs VBA :

- les paramètres facultatifs sont recopiés dans des variables locales ;
- une collection de niveau module est lue avec `.Item` ;
- une plage se désigne par une seule adresse, jamais par une plage multiple du type `"C5,E5,G5"`.
