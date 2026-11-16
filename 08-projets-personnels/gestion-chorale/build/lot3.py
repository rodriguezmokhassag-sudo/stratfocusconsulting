"""Lot 3 : patrimoine (inventaire valorisé, amortissements, prêts, locations,
inventaires physiques, étiquettes, liens avec les finances et les pertes)."""
import datetime as dt

HDR, FIRST, OUT_HDR, MAXROWS, VAL_ROWS = 4, 5, 8, 5000, 3000

CATEGORIES = [  # (catégorie, préfixe, durée d'amortissement en années)
    ("Administration", "ADM", 3), ("Matériel de musique", "MUS", 5), ("Informatique", "INF", 3),
    ("Mobilier", "MOB", 5), ("Cuisine et kit de sortie", "CUI", 3), ("Tenues et textiles", "TEX", 3),
    ("Immobilier", "IMM", 20),
]

PATRIMOINE_COLS = [
    ("Code", 10, "t"), ("Désignation", 28, "t"), ("Catégorie", 20, "t"), ("Marque / modèle", 18, "t"),
    ("N° de série", 14, "t"), ("Quantité", 8, "n"), ("Unité", 8, "t"), ("Date d'acquisition", 11, "d"),
    ("Mode d'acquisition", 16, "t"), ("Origine / Donateur", 22, "t"), ("Pièce de caisse", 12, "t"),
    ("Valeur unitaire (FCFA)", 11, "m"), ("Valeur totale (FCFA)", 12, "m"), ("Durée d'amortissement (ans)", 9, "n"),
    ("Amortissement cumulé (FCFA)", 12, "m"), ("Valeur nette (FCFA)", 12, "m"), ("Valeur de remplacement (FCFA)", 12, "m"),
    ("Louable", 8, "t"), ("Tarif location / jour (FCFA)", 10, "m"), ("État", 11, "t"), ("Localisation", 18, "t"),
    ("Gardien", 18, "t"), ("Quantité sortie", 8, "n"), ("Quantité disponible", 9, "n"), ("Dernier inventaire", 11, "d"),
    ("Observations", 30, "t"),
]

COLS = {
    "PATRIMOINE": PATRIMOINE_COLS,
    "CATEGORIES_PAT": [("Catégorie", 30, "t"), ("Préfixe", 9, "t"), ("Durée d'amortissement (ans)", 12, "n"), ("Actif", 8, "t")],
    "MOUVEMENTS_PAT": [("N°", 13, "t"), ("Date", 11, "d"), ("Type", 18, "t"), ("Code", 10, "t"), ("Désignation", 26, "t"),
                       ("Quantité", 8, "n"), ("Bénéficiaire", 24, "t"), ("Contrat", 13, "t"), ("Retour prévu", 11, "d"),
                       ("Retour effectif", 11, "d"), ("État au départ", 11, "t"), ("État au retour", 11, "t"),
                       ("Montant (FCFA)", 11, "m"), ("Pièce de caisse", 12, "t"), ("Statut", 9, "t"),
                       ("Observations", 30, "t"), ("Saisi le", 16, "dt"), ("Saisi par", 20, "t")],
    "LOCATIONS": [("N° contrat", 13, "t"), ("Date de la demande", 11, "d"), ("Locataire", 26, "t"), ("Contact", 16, "t"),
                  ("Objet", 26, "t"), ("Début", 11, "d"), ("Fin", 11, "d"), ("Jours", 6, "n"),
                  ("Montant location (FCFA)", 12, "m"), ("Caution (FCFA)", 11, "m"), ("Avis commission musicale", 16, "t"),
                  ("Accord du Bureau", 16, "t"), ("Statut", 11, "t"), ("Pièce loyer", 12, "t"), ("Pièce caution", 12, "t"),
                  ("Pièce restitution", 12, "t"), ("Retenue (FCFA)", 10, "m"), ("Observations", 30, "t")],
    "INVENTAIRES": [("Date", 16, "dt"), ("Libellé", 28, "t"), ("Articles comptés", 10, "n"), ("Articles en écart", 10, "n"),
                    ("Valeur des écarts (FCFA)", 13, "m"), ("Pertes enregistrées", 30, "t"), ("Saisi par", 22, "t")],
}

TITLES = {
    "PATRIMOINE": "Patrimoine : inventaire valorisé",
    "CATEGORIES_PAT": "Catégories du patrimoine (préfixe des codes et durée d'amortissement)",
    "MOUVEMENTS_PAT": "Mouvements du patrimoine : prêts, locations, réparations, pertes, sorties",
    "LOCATIONS": "Locations de matériel (art. 30)",
    "CONTRAT": "Contrat de location",
    "ETIQUETTES": "Étiquettes du patrimoine",
    "INVENTAIRE": "Inventaire physique : feuille de comptage",
    "INVENTAIRES": "Historique des inventaires physiques",
    "SYNTHESE_PAT": "Synthèse du patrimoine (rapport patrimonial)",
    "FICHE_BIEN": "Fiche d'un bien",
}

CODENAMES = {
    "CATEGORIES_PAT": "shCategories", "MOUVEMENTS_PAT": "shMouvements", "LOCATIONS": "shLocations",
    "CONTRAT": "shContrat", "ETIQUETTES": "shEtiquettes", "INVENTAIRE": "shInventaire",
    "INVENTAIRES": "shInventaires", "SYNTHESE_PAT": "shSynthesePat", "FICHE_BIEN": "shFicheBien",
}
ORDER_PAT = ["MOUVEMENTS_PAT", "LOCATIONS", "CONTRAT", "INVENTAIRE", "INVENTAIRES", "SYNTHESE_PAT", "FICHE_BIEN", "ETIQUETTES"]
JOURNALED = {"CATEGORIES_PAT", "LOCATIONS"}

PARAMS = [
    ("#", "Patrimoine (lot 3)"),
    ("CAUTION_POURCENT", 0.3, "Caution de location proposée : pourcentage de la valeur de remplacement (ou d'acquisition) des articles loués"),
    ("CAUTION_MINIMUM", 10000, "Caution minimale d'une location (FCFA)"),
    ("MOIS_INVENTAIRE", "6;12", "Mois des inventaires physiques (juin et décembre, avant l'AG)"),
    ("PREFIXE_ACHAT_MATERIEL", "D04", "Rubriques de dépense qui proposent la création d'une fiche de bien"),
    ("CODE_LOCATION", "R05.1", "Rubrique des loyers de location"),
    ("CODE_INDEMNITE", "R05.2", "Rubrique des indemnités pour dégâts (retenues sur caution)"),
    ("CODE_CAUTION_RECUE", "R10.1", "Rubrique des cautions reçues"),
    ("CODE_CAUTION_RENDUE", "D11.1", "Rubrique des cautions restituées"),
    ("CODE_REPARATION", "D05.1", "Rubrique des réparations"),
]

RUBRIQUES_ADD = [
    ("R05.2", "Recette", "Location de matériel", "Indemnités pour dégâts", "GENERAL"),
    ("R10.1", "Recette", "Cautions et dépôts", "Cautions reçues", "GENERAL"),
    ("D11.1", "Dépense", "Cautions et dépôts", "Cautions restituées", "GENERAL"),
]

LISTES_ADD = {
    "Type de mouvement": ["Prêt", "Location", "Réparation", "Perte ou vol", "Détérioration", "Sortie définitive",
                          "Ajustement d'inventaire", "Entrée"],
    "Statut de location": ["Demande", "Approuvée", "Payée", "En cours", "Rendue", "Clôturée", "Refusée"],
}

CONDITIONS = [
    "1. Le matériel est remis en bon état de marche, constaté contradictoirement au départ et au retour.",
    "2. Le locataire en assure la garde, le transport et l'utilisation conformes ; il ne peut le sous-louer.",
    "3. Tout dégât, perte ou vol est à la charge du locataire : le coût de réparation ou de remplacement est retenu sur la caution, le surplus restant dû.",
    "4. Le matériel est restitué à la date de fin convenue ; chaque jour de retard est facturé au tarif journalier.",
    "5. La caution est restituée après contrôle du matériel au retour.",
    "6. Location approuvée par le Bureau de la chorale après avis de la Commission musicale (règlement intérieur, art. 30).",
]


def register(g):
    lot2 = g["lot2"]
    lot2.RUBRIQUES.extend(RUBRIQUES_ADD)
    lot2.RUBRIQUES.sort(key=lambda r: r[0])
    g["COLS"].update(COLS)
    g["TITLES"].update(TITLES)
    g["CODENAMES"].update(CODENAMES)
    order = g["ORDER"]
    i = order.index("PATRIMOINE") + 1
    order[i:i] = ORDER_PAT
    j = order.index("CONTROLES_ADHESION") + 1
    order[j:j] = ["CATEGORIES_PAT"]
    g["JOURNALED"].update(JOURNALED)
    params = g["PARAMS"]
    k = [n for n, p in enumerate(params) if p[0] == "#" and p[1].startswith("Sécurité")][0]
    params[k:k] = PARAMS
    listes = g["LISTES"]
    listes.pop("Catégorie de patrimoine", None)
    listes.update(LISTES_ADD)


def build_sheets(b):
    d = b.data
    f = b.f
    ws = b.ws["PATRIMOINE"]
    b.validation(ws, "PATRIMOINE", "Louable", "=L_OUINON")
    b.table("CATEGORIES_PAT", [[c, p, n, "OUI"] for c, p, n in CATEGORIES], autofilter=False)
    b.validation(b.ws["CATEGORIES_PAT"], "CATEGORIES_PAT", "Actif", "=L_OUINON")
    ws = b.table("MOUVEMENTS_PAT", d.get("mouvements", []), freeze_col=3)
    ws = b.table("LOCATIONS", d.get("locations", []), freeze_col=3)
    b.validation(ws, "LOCATIONS", "Statut", "=L_STATUTS_LOCATION")
    b.table("INVENTAIRES", d.get("inventaires", []), autofilter=False)
    inventaire(b)
    synthese(b)
    fiche(b)
    contrat(b)
    etiquettes(b)


def _report(b, name, cols, freeze_col=1):
    ws = b.sheet(name)
    b.title(ws, name, len(cols), OUT_HDR)
    for i, (h, w, t) in enumerate(cols):
        ws.set_column(i, i, w, b.f[t])
        ws.write(OUT_HDR - 1, i, h, b.f["hdr"])
    ws.set_row(OUT_HDR - 1, 32)
    ws.freeze_panes(OUT_HDR, freeze_col)
    ws.set_landscape()
    ws.set_paper(9)
    ws.fit_to_pages(1, 0)
    ws.repeat_rows(0, OUT_HDR - 1)
    return ws


def inventaire(b):
    f = b.f
    ws = _report(b, "INVENTAIRE", [("Code", 10, "t"), ("Désignation", 30, "t"), ("Catégorie", 20, "t"),
                                   ("Localisation", 18, "t"), ("Quantité attendue", 10, "n"), ("Quantité comptée", 10, "n"),
                                   ("État constaté", 13, "t"), ("Écart", 8, "n"), ("Observations", 34, "t")], 2)
    ws.write(4, 1, "Inventaire :", f["label"])
    ws.write(4, 2, "", f["input"])
    ws.write(4, 3, "Date :", f["label"])
    ws.write(4, 4, "", f["input_d"])
    ws.write(6, 0, "Quantité attendue = quantité en stock moins les articles prêtés, loués ou en réparation. "
                   "Saisissez les quantités comptées et l'état (cases jaunes), puis validez.", f["small"])
    ws.data_validation(OUT_HDR, 6, MAXROWS, 6, {"validate": "list", "source": "=L_ETATS"})


def synthese(b):
    f = b.f
    ws = _report(b, "SYNTHESE_PAT", [("Catégorie", 26, "t"), ("Fiches", 8, "n"), ("Quantité", 9, "n"),
                                     ("Valeur d'acquisition (FCFA)", 14, "m"), ("Amortissement cumulé (FCFA)", 14, "m"),
                                     ("Valeur nette (FCFA)", 14, "m"), ("Valeur de remplacement (FCFA)", 14, "m")])
    ws.set_column(7, 7, 3)
    ws.set_column(8, 8, 30)
    ws.set_column(9, 10, 14)
    ws.write(4, 1, "Au :", f["label"])
    ws.write(4, 2, "", f["input_d"])


def fiche(b):
    f = b.f
    ws = b.sheet("FICHE_BIEN")
    b.title(ws, "FICHE_BIEN", 8, HDR)
    ws.set_column(0, 0, 2)
    ws.set_column(1, 1, 28)
    ws.set_column(2, 2, 34)
    ws.set_column(3, 8, 14)
    ws.write(4, 1, "Code du bien :", f["label"])
    ws.write(4, 2, "", f["input"])


def contrat(b):
    ws = b.sheet("CONTRAT")
    f = b.f
    wb = b.wb
    ws.set_column(0, 0, 2)
    ws.set_column(1, 1, 14)
    ws.set_column(2, 2, 34)
    ws.set_column(3, 5, 13)
    ws.set_row(0, 30)
    ws.merge_range(0, 0, 0, 5, "", f["title"])
    big = wb.add_format({"bold": True, "font_size": 15, "font_color": "#1E7B4A"})
    ws.write(2, 1, "CONTRAT DE LOCATION DE MATÉRIEL", big)
    ws.write(3, 1, "", f["home_sub"])
    ws.set_paper(9)
    ws.set_portrait()
    ws.fit_to_pages(1, 1)
    ws.print_area(0, 0, 45, 5)


def etiquettes(b):
    ws = b.sheet("ETIQUETTES")
    b.title(ws, "ETIQUETTES", 6, HDR)
    ws.set_column(0, 0, 1)
    for c in (1, 3, 5):
        ws.set_column(c, c, 34)
    for c in (2, 4):
        ws.set_column(c, c, 2)
    ws.write(4, 1, "Bouton « Générer les étiquettes » : tous les biens, une catégorie ou un code.", b.f["info"])
    ws.set_paper(9)
    ws.set_portrait()
    ws.fit_to_pages(1, 0)
    ws.set_margins(0.3, 0.3, 0.4, 0.4)


def names(b):
    wb = b.wb
    lc = b.listes_cols

    def dyn(key):
        c = lc[key]
        return "=OFFSET(LISTES!$%s$%d,0,0,MAX(1,COUNTA(LISTES!$%s$%d:$%s$300)),1)" % (c, FIRST, c, FIRST, c)

    wb.define_name("L_TYPES_MOUVEMENT", dyn("Type de mouvement"))
    wb.define_name("L_STATUTS_LOCATION", dyn("Statut de location"))
    wb.define_name("L_CAT_PAT", "=OFFSET(CATEGORIES_PAT!$A$%d,0,0,MAX(1,COUNTA(CATEGORIES_PAT!$A$%d:$A$300)),1)" % (FIRST, FIRST))
