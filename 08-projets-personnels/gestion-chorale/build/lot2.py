"""Lot 2 : finances (caisses, budget, cotisations, caisse sociale, reçus).

Ajoute les feuilles, listes, paramètres et noms définis du lot 2 au classeur
construit par build.py.
"""
import datetime as dt

HDR, FIRST, OUT_HDR, MAXROWS, VAL_ROWS = 4, 5, 8, 5000, 3000

# Plan des rubriques : (code, sens, rubrique, sous-rubrique, fonds)
RUBRIQUES = [
    ("R01.1", "Recette", "Cotisations statutaires", "Cotisations mensuelles", "GENERAL"),
    ("R02.1", "Recette", "Collectes et offrandes", "Collectes ordinaires", "GENERAL"),
    ("R02.2", "Recette", "Collectes et offrandes", "Offrandes", "GENERAL"),
    ("R03.1", "Recette", "Cotisations spéciales", "Campagnes de cotisation", "GENERAL"),
    ("R04.1", "Recette", "Dons et legs", "Dons", "GENERAL"),
    ("R04.2", "Recette", "Dons et legs", "Legs", "GENERAL"),
    ("R05.1", "Recette", "Location de matériel", "Location de matériel de musique", "GENERAL"),
    ("R06.1", "Recette", "Pénalités et amendes", "Pénalités de retard", "GENERAL"),
    ("R06.2", "Recette", "Pénalités et amendes", "Autres amendes", "GENERAL"),
    ("R07.1", "Recette", "Activités productives", "Salu kia zola", "GENERAL"),
    ("R08.1", "Recette", "Subventions", "Subventions", "GENERAL"),
    ("R09.1", "Recette", "Autres recettes", "Recettes diverses", "GENERAL"),
    ("R09.2", "Recette", "Autres recettes", "Excédents de caisse", "GENERAL"),
    ("R09.3", "Recette", "Autres recettes", "Remboursements (art. 51)", "GENERAL"),
    ("S01.1", "Recette", "Caisse sociale - recettes", "Contributions aux événements sociaux", "SOCIAL"),
    ("S01.2", "Recette", "Caisse sociale - recettes", "Quêtes et dons sociaux", "SOCIAL"),
    ("D01.1", "Dépense", "Activités et évangélisation", "Sorties d'évangélisation", "GENERAL"),
    ("D01.2", "Dépense", "Activités et évangélisation", "Retraites spirituelles", "GENERAL"),
    ("D01.3", "Dépense", "Activités et évangélisation", "Études bibliques et formation", "GENERAL"),
    ("D02.1", "Dépense", "Transport", "Transport des sorties", "GENERAL"),
    ("D02.2", "Dépense", "Transport", "Transport des deuils", "GENERAL"),
    ("D03.1", "Dépense", "Tenues et uniformes", "Tenues officielles", "GENERAL"),
    ("D04.1", "Dépense", "Achat de matériel", "Instruments de musique", "GENERAL"),
    ("D04.2", "Dépense", "Achat de matériel", "Sonorisation", "GENERAL"),
    ("D04.3", "Dépense", "Achat de matériel", "Mobilier et divers", "GENERAL"),
    ("D05.1", "Dépense", "Entretien et réparations", "Entretien et réparations", "GENERAL"),
    ("D06.1", "Dépense", "Assistance sociale (budget général)", "Aides exceptionnelles", "GENERAL"),
    ("D07.1", "Dépense", "Cuisine et réceptions", "Cuisine et réceptions", "GENERAL"),
    ("D08.1", "Dépense", "Fournitures et communication", "Fournitures", "GENERAL"),
    ("D08.2", "Dépense", "Fournitures et communication", "Impressions", "GENERAL"),
    ("D08.3", "Dépense", "Fournitures et communication", "Communication (crédit, internet)", "GENERAL"),
    ("D09.1", "Dépense", "Frais bancaires", "Frais bancaires", "GENERAL"),
    ("D10.1", "Dépense", "Imprévus et autres", "Imprévus", "GENERAL"),
    ("D10.2", "Dépense", "Imprévus et autres", "Manquants de caisse", "GENERAL"),
    ("T01.1", "Dépense", "Caisse sociale - dépenses", "Aides versées (barème)", "SOCIAL"),
    ("T01.2", "Dépense", "Caisse sociale - dépenses", "Gerbes, habillement, cadeaux", "SOCIAL"),
    ("T01.3", "Dépense", "Caisse sociale - dépenses", "Transport des deuils de choristes", "SOCIAL"),
    ("T01.4", "Dépense", "Caisse sociale - dépenses", "Pension des orphelins", "SOCIAL"),
]

# Barème social (art. 20) : (type, nature, contribution/membre, aide, affectation, présence, remarque)
BAREME = [
    ("Décès d'un(e) choriste", "Malheureux", 2500, 0,
     "Moitié transport vers l'inhumation, moitié pension des orphelins", "Chaque jour au lieu du deuil",
     "Habillement et gerbe de fleurs à la charge de la chorale"),
    ("Décès d'un proche (conjoint, enfant, père, mère)", "Malheureux", 1000, 40000, "Caisse sociale", "2 fois", ""),
    ("Décès d'un frère, d'une sœur, d'un oncle sous le même toit", "Malheureux", 0, 0,
     "Quête libre au profit du membre", "1 fois", ""),
    ("Hospitalisation de plus d'une semaine", "Malheureux", 1500, 50000, "Caisse sociale", "", ""),
    ("Naissance (amour en action)", "Heureux", 0, 0, "Contribution libre", "", "Déclaration de naissance au Bureau"),
    ("Mariage d'un membre", "Heureux", 5000, 200000, "Caisse sociale", "", "Cadeau jusqu'à 200 000 FCFA"),
    ("Invitation à un mariage", "Heureux", 1000, 0, "", "", ""),
    ("Invitation à un anniversaire", "Heureux", 500, 0, "", "", ""),
    ("Baptême ou bénédiction d'enfant", "Heureux", 0, 0, "", "", ""),
]

MONTHS = ["M%02d" % i for i in range(1, 13)]

COLS = {
    "CAISSE": [("N° pièce", 13, "t"), ("Date", 11, "d"), ("Exercice", 9, "t"), ("Caisse", 9, "t"),
               ("Opération", 15, "t"), ("Code", 7, "t"), ("Rubrique", 24, "t"), ("Sous-rubrique", 26, "t"),
               ("Fonds", 9, "t"), ("Libellé", 32, "t"), ("Matricule", 11, "t"), ("Tiers / Nom", 24, "t"),
               ("Référence", 15, "t"), ("Recette (FCFA)", 12, "m"), ("Dépense (FCFA)", 12, "m"),
               ("Autorisation", 16, "t"), ("N° reçu", 14, "t"), ("Statut", 14, "t"), ("Pièce liée", 13, "t"),
               ("Saisi le", 16, "dt"), ("Saisi par", 20, "t")],
    "RUBRIQUES": [("Code", 8, "t"), ("Sens", 10, "t"), ("Rubrique", 32, "t"), ("Sous-rubrique", 34, "t"),
                  ("Fonds", 10, "t"), ("Actif", 7, "t"), ("Choix", 44, "t")],
    "BUDGET": [("Exercice", 9, "t"), ("Code", 7, "t"), ("Sens", 9, "t"), ("Rubrique", 26, "t"),
               ("Sous-rubrique", 28, "t"), ("Fonds", 9, "t"), ("Budget initial", 12, "m"),
               ("Budget rectifié", 12, "m"), ("Budget retenu", 12, "m")]
              + [(m, 9, "m") for m in MONTHS] + [("Écart de répartition", 11, "m"), ("Réf. adoption", 20, "t")],
    "CAMPAGNES": [("Code", 13, "t"), ("Libellé", 34, "t"), ("Montant par membre (FCFA)", 12, "m"),
                  ("Date limite", 11, "d"), ("Code rubrique", 9, "t"), ("Événement social", 14, "t"),
                  ("Statut", 10, "t"), ("Membres concernés", 10, "n"), ("Total attendu (FCFA)", 13, "m"),
                  ("Total collecté (FCFA)", 13, "m"), ("Créée le", 11, "d")],
    "SOCIAL": [("N°", 13, "t"), ("Date", 11, "d"), ("Type d'événement", 34, "t"), ("Nature", 10, "t"),
               ("Matricule", 11, "t"), ("Nom et prénoms", 24, "t"), ("Description", 26, "t"),
               ("Contribution par membre (FCFA)", 12, "m"), ("Campagne", 13, "t"), ("Collecté (FCFA)", 12, "m"),
               ("Aide prévue (FCFA)", 12, "m"), ("Aide versée (FCFA)", 12, "m"), ("Autres dépenses (FCFA)", 12, "m"),
               ("Solde de l'événement (FCFA)", 13, "m"), ("Affectation de la différence", 34, "t"),
               ("Présence de la chorale", 20, "t"), ("Statut", 10, "t")],
    "BAREME_SOCIAL": [("Type d'événement", 44, "t"), ("Nature", 11, "t"), ("Contribution par membre (FCFA)", 13, "m"),
                      ("Aide versée par la chorale (FCFA)", 13, "m"), ("Affectation de la différence", 46, "t"),
                      ("Présence de la chorale", 24, "t"), ("Remarques", 40, "t")],
    "ARRETES": [("Date", 16, "dt"), ("Type", 10, "t"), ("Solde théorique (FCFA)", 14, "m"),
                ("Solde constaté (FCFA)", 14, "m"), ("Écart (FCFA)", 12, "m"), ("Pièce d'écart", 13, "t"),
                ("Observations", 40, "t"), ("Saisi par", 22, "t")],
    "PERTES": [("N°", 13, "t"), ("Date", 11, "d"), ("Type", 26, "t"), ("Matricule", 11, "t"),
               ("Nom / Tiers", 24, "t"), ("Description", 34, "t"), ("Montant (FCFA)", 12, "m"),
               ("Remboursé (FCFA)", 12, "m"), ("Reste (FCFA)", 12, "m"), ("Échéancier", 26, "t"), ("Statut", 12, "t")],
    "CLOTURES": [("Exercice", 10, "t"), ("Date de clôture", 16, "dt"), ("Solde espèces (FCFA)", 14, "m"),
                 ("Solde banque (FCFA)", 14, "m"), ("Dont fonds social (FCFA)", 14, "m"),
                 ("Total recettes (FCFA)", 14, "m"), ("Total dépenses (FCFA)", 14, "m"), ("Résultat (FCFA)", 14, "m"),
                 ("Clôturé par", 22, "t")],
}

TITLES = {
    "SAISIE_CAISSE": "Saisie d'une écriture de caisse",
    "CAISSE": "Journal de caisse (non modifiable : corrections par annulation)",
    "RUBRIQUES": "Rubriques et sous-rubriques budgétaires",
    "BUDGET": "Budget annuel voté en Assemblée générale (M01 = premier mois de l'exercice)",
    "SUIVI_BUDGET": "Suivi budgétaire : prévu, réalisé, écarts et variations",
    "COTISATIONS": "Cotisations mensuelles et pénalités par membre",
    "CAMPAGNES": "Cotisations spéciales (campagnes)",
    "SUIVI_CAMPAGNE": "Suivi d'une campagne de cotisation",
    "SOCIAL": "Caisse sociale : événements heureux et malheureux",
    "BAREME_SOCIAL": "Barème de la caisse sociale (art. 20)",
    "ARRETE_CAISSE": "Arrêté de caisse : comptage des espèces",
    "ARRETES": "Historique des arrêtés de caisse et rapprochements bancaires",
    "PERTES": "Registre des pertes et remboursements (art. 51)",
    "RECU": "Reçu",
    "CLOTURES": "Clôtures d'exercice",
}

CODENAMES = {
    "SAISIE_CAISSE": "shSaisie", "CAISSE": "shCaisse", "RUBRIQUES": "shRubriques", "BUDGET": "shBudget",
    "SUIVI_BUDGET": "shSuiviBudget", "COTISATIONS": "shCotisations", "CAMPAGNES": "shCampagnes",
    "SUIVI_CAMPAGNE": "shSuiviCampagne", "SOCIAL": "shSocial", "BAREME_SOCIAL": "shBareme",
    "ARRETE_CAISSE": "shArrete", "ARRETES": "shArretes", "PERTES": "shPertes", "RECU": "shRecu",
    "CLOTURES": "shClotures",
}

ORDER_FIN = ["SAISIE_CAISSE", "CAISSE", "COTISATIONS", "CAMPAGNES", "SUIVI_CAMPAGNE", "SOCIAL", "BUDGET",
             "SUIVI_BUDGET", "ARRETE_CAISSE", "ARRETES", "PERTES", "RECU", "CLOTURES"]
ORDER_PARAM = ["RUBRIQUES", "BAREME_SOCIAL"]
JOURNALED = {"RUBRIQUES", "BUDGET", "CAMPAGNES", "SOCIAL", "BAREME_SOCIAL", "PERTES"}

PARAMS = [
    ("#", "Finances (lot 2)"),
    ("DATE_OUVERTURE_COMPTES", dt.date(2026, 1, 1), "Date des soldes d'ouverture ci-dessous"),
    ("SOLDE_OUVERTURE_ESPECES", 0, "Solde de la caisse en espèces à la date d'ouverture"),
    ("SOLDE_OUVERTURE_BANQUE", 0, "Solde du compte bancaire à la date d'ouverture"),
    ("SOLDE_OUVERTURE_SOCIAL", 0, "Part de ces soldes appartenant à la caisse sociale"),
    ("DEBUT_SUIVI_COTISATIONS", dt.date(2026, 1, 1), "Les cotisations sont dues à partir de ce mois"),
    ("SEUIL_AUTORISATION", 10000, "Dépense à partir de laquelle l'autorisation du Bureau est obligatoire (art. 16-5)"),
    ("SEUIL_ECART_BUDGET", 0.1, "Écart prévu/réalisé signalé en couleur au-delà de ce pourcentage"),
    ("MOIS_ALERTE_ARRIERES", 3, "Alerte quand un membre a au moins ce nombre de mois d'arriérés"),
    ("JOURS_ALERTE_ARRETE", 30, "Alerte quand le dernier arrêté de caisse date de plus de ce nombre de jours"),
    ("PREFIXE_RECU", "REC", "Reçus numérotés PREFIXE-AAAA-0001"),
    ("CODE_COTISATION", "R01.1", "Rubrique des cotisations mensuelles"),
    ("CODE_PENALITES", "R06.1", "Rubrique des pénalités de retard"),
    ("CODE_CAMPAGNE", "R03.1", "Rubrique par défaut des cotisations spéciales"),
    ("CODE_CONTRIB_SOCIALE", "S01.1", "Rubrique des contributions aux événements sociaux"),
    ("CODE_AIDE_SOCIALE", "T01.1", "Rubrique des aides versées par la caisse sociale"),
    ("CODE_MANQUANT", "D10.2", "Rubrique des manquants de caisse"),
    ("CODE_EXCEDENT", "R09.2", "Rubrique des excédents de caisse"),
    ("CODE_REMBOURSEMENT", "R09.3", "Rubrique des remboursements (art. 51)"),
    ("EXERCICES_CLOTURES", "", "Mis à jour par la clôture d'exercice"),
]

LISTES_ADD = {
    "Caisse": ["Espèces", "Banque"],
    "Opération": ["Recette", "Dépense", "Virement"],
    "Sens": ["Recette", "Dépense"],
    "Fonds": ["GENERAL", "SOCIAL"],
    "Type de perte": ["Manquant de caisse", "Cotisation irrécouvrable", "Matériel perdu ou détérioré",
                      "Malversation (art. 51)", "Autre"],
    "Nature d'événement": ["Heureux", "Malheureux"],
    "Statut de campagne": ["Ouverte", "Clôturée"],
}
# Statuts qui doivent la cotisation mensuelle (meme ordre que la liste "Statut")
COTISATION_STATUT = ["OUI", "OUI", "OUI", "OUI", "OUI", "NON", "NON", "NON", "NON", "NON"]

COUPURES = [(10000, "Billet"), (5000, "Billet"), (2000, "Billet"), (1000, "Billet"), (500, "Billet"),
            (500, "Pièce"), (100, "Pièce"), (50, "Pièce"), (25, "Pièce"), (10, "Pièce"), (5, "Pièce"),
            (2, "Pièce"), (1, "Pièce")]


def register(g):
    """Complète les constantes de build.py (g = globals() du module build)."""
    g["COLS"].update(COLS)
    g["TITLES"].update(TITLES)
    g["CODENAMES"].update(CODENAMES)
    order = g["ORDER"]
    i = order.index("PATRIMOINE") + 1
    order[i:i] = ORDER_FIN
    j = order.index("CONTROLES_ADHESION") + 1
    order[j:j] = ORDER_PARAM
    g["JOURNALED"].update(JOURNALED)
    params = g["PARAMS"]
    k = [n for n, p in enumerate(params) if p[0] == "#" and p[1].startswith("Sécurité")][0]
    params[k:k] = PARAMS
    listes = g["LISTES"]
    rebuilt = {}
    for key, val in listes.items():
        rebuilt[key] = val
        if key == "Code par défaut":
            rebuilt["Cotisation"] = COTISATION_STATUT
    rebuilt.update(LISTES_ADD)
    listes.clear()
    listes.update(rebuilt)


# ------------------------------------------------------------------ feuilles
def build_sheets(b):
    d = b.data
    f = b.f
    # Journal de caisse (lecture seule)
    b.table("CAISSE", d.get("caisse", []), freeze_col=1)
    # Saisie
    saisie(b)
    # Cotisations (rapport calcule)
    report(b, "COTISATIONS",
           [("Matricule", 11, "t"), ("Nom et prénoms", 26, "t"), ("Statut", 15, "t"), ("Téléphone", 13, "t"),
            ("Début du suivi", 11, "d"), ("Mois dus", 7, "n"), ("Montant dû", 11, "m"), ("Payé", 11, "m"),
            ("Reste", 11, "m"), ("Mois d'arriérés", 9, "n"), ("À jour jusqu'à", 11, "t"),
            ("Pénalités dues", 10, "m"), ("Pénalités payées", 10, "m"), ("Pénalités restantes", 10, "m"),
            ("Total à payer", 11, "m"), ("Message de relance", 70, "t")],
           [("Situation au :", "C5", "date")], freeze_col=2)
    ws = b.ws["COTISATIONS"]
    ws.write(5, 1, "Recouvrement :", f["label"])
    ws.write(5, 2, "", f["big_p"])
    ws = b.table("CAMPAGNES", d.get("campagnes", []), freeze_col=2)
    b.validation(ws, "CAMPAGNES", "Statut", "=L_STATUTS_CAMPAGNE")
    report(b, "SUIVI_CAMPAGNE",
           [("Matricule", 11, "t"), ("Nom et prénoms", 28, "t"), ("Statut", 15, "t"), ("Montant dû", 11, "m"),
            ("Payé", 11, "m"), ("Reste", 11, "m"), ("Dernier paiement", 12, "d")],
           [("Campagne :", "C5", "list:=L_CAMPAGNES")], freeze_col=2)
    ws = b.table("SOCIAL", d.get("social", []), freeze_col=2)
    b.validation(ws, "SOCIAL", "Type d'événement", "=L_EVENEMENTS")
    # Budget
    ws = b.table("BUDGET", d.get("budget", []), freeze_col=2)
    report(b, "SUIVI_BUDGET",
           [("Code", 8, "t"), ("Sens", 9, "t"), ("Rubrique", 26, "t"), ("Sous-rubrique", 28, "t"),
            ("Prévu annuel", 12, "m"), ("Prévu à date", 12, "m"), ("Réalisé à date", 12, "m"), ("Écart", 12, "m"),
            ("Écart %", 8, "p"), ("Exécution annuelle", 10, "p"), ("Réalisé du mois", 12, "m"),
            ("Mois précédent", 12, "m"), ("Variation %", 9, "p"), ("Réalisé N-1 à date", 12, "m"),
            ("Variation N/N-1 %", 10, "p")],
           [("Exercice :", "C5", "text"), ("Jusqu'au mois n° :", "E5", "text")], freeze_col=4)
    ws = b.ws["SUIVI_BUDGET"]
    ws.write(5, 1, "Résultat :", f["label"])
    ws.write(6, 0, "Écart = réalisé - prévu à date. En rouge : recettes en retrait ou dépenses en dépassement "
                   "au-delà du seuil (PARAMETRES).", f["small"])
    arrete(b)
    b.table("ARRETES", d.get("arretes", []), freeze_col=1)
    ws = b.table("PERTES", d.get("pertes", []), freeze_col=2)
    b.validation(ws, "PERTES", "Type", "=L_TYPES_PERTE")
    recu(b)
    b.table("CLOTURES", d.get("clotures", []), autofilter=False)
    # Parametres financiers
    rub = [[c, s, r, sr, fo, "OUI", None] for c, s, r, sr, fo in RUBRIQUES]
    ws = b.table("RUBRIQUES", rub, autofilter=False)
    for j in range(200):
        ws.write_formula(FIRST - 1 + j, 6, '=IF(A%d="","",A%d&" - "&D%d)' % (FIRST + j, FIRST + j, FIRST + j),
                         f["t"], (rub[j][0] + " - " + rub[j][3]) if j < len(rub) else "")
    b.validation(ws, "RUBRIQUES", "Sens", "=L_SENS")
    b.validation(ws, "RUBRIQUES", "Fonds", "=L_FONDS")
    b.validation(ws, "RUBRIQUES", "Actif", "=L_OUINON")
    ws = b.table("BAREME_SOCIAL", [list(x) for x in BAREME], autofilter=False)
    b.validation(ws, "BAREME_SOCIAL", "Nature", "=L_NATURES")


def report(b, name, cols, inputs, freeze_col=1):
    ws = b.sheet(name)
    f = b.f
    b.title(ws, name, len(cols), OUT_HDR)
    for i, (h, w, t) in enumerate(cols):
        ws.set_column(i, i, w, f[t])
        ws.write(OUT_HDR - 1, i, h, f["hdr"])
    ws.set_row(OUT_HDR - 1, 32)
    for lbl, cell, kind in inputs:
        col = ord(cell[0]) - 65
        ws.write(4, col - 1, lbl, f["label"])
        if kind == "date":
            ws.write(4, col, "", f["input_d"])
        else:
            ws.write(4, col, "", f["input"])
        if kind.startswith("list:"):
            ws.data_validation(4, col, 4, col, {"validate": "list", "source": kind[5:], "error_type": "warning"})
    ws.freeze_panes(OUT_HDR, freeze_col)
    ws.set_landscape()
    ws.set_paper(9)
    ws.fit_to_pages(1, 0)
    ws.repeat_rows(0, OUT_HDR - 1)
    return ws


def saisie(b):
    ws = b.sheet("SAISIE_CAISSE")
    f = b.f
    b.title(ws, "SAISIE_CAISSE", 8, HDR)
    ws.set_column(0, 0, 2)
    ws.set_column(1, 1, 30)
    ws.set_column(2, 2, 46)
    ws.set_column(3, 3, 3)
    ws.set_column(4, 4, 50)
    ws.set_column(5, 5, 22)
    ws.set_column(6, 6, 16)
    ws.merge_range(HDR - 1, 1, HDR - 1, 2, "Nouvelle écriture", f["hdr"])
    ws.merge_range(HDR - 1, 5, HDR - 1, 6, "Soldes", f["hdr"])
    rows = [
        ("Date", "input_d", "Date de l'opération (jj/mm/aaaa)"),
        ("Caisse", "input", "Espèces ou Banque"),
        ("Opération", "input", "Recette, Dépense ou Virement (entre caisses)"),
        ("Rubrique", "input", "Sous-rubrique budgétaire (inutile pour un virement)"),
        ("Libellé", "input", "Objet de l'opération"),
        ("Membre (matricule) ou tiers", "input", "Matricule (ex. ADC-0012) ou nom du tiers ; figure sur le reçu"),
        ("Montant (FCFA)", "input", "Nombre entier positif"),
        ("Référence", "input", "Campagne, événement social ou perte concernés (facultatif)"),
        ("Autorisation du Bureau", "input", "N° ou date du PV : obligatoire pour une dépense au-delà du seuil"),
        ("Caisse de destination", "input", "Pour un virement seulement"),
    ]
    for i, (lbl, fmt, hlp) in enumerate(rows):
        r = FIRST - 1 + i
        ws.set_row(r, 20)
        ws.write(r, 1, lbl, f["label"])
        ws.write(r, 2, "", f[fmt])
        ws.write(r, 4, hlp, f["info"])
    soldes = ["Espèces", "Banque", "Total", "Dont fonds social", "Dernière pièce", "Dernier reçu"]
    for i, s in enumerate(soldes):
        ws.write(FIRST - 1 + i, 5, s, f["label"])
        ws.write(FIRST - 1 + i, 6, "", f["m"])
    ws.data_validation(5, 2, 5, 2, {"validate": "list", "source": "=L_CAISSES"})
    ws.data_validation(6, 2, 6, 2, {"validate": "list", "source": "=L_OPERATIONS"})
    ws.data_validation(7, 2, 7, 2, {"validate": "list", "source": "=L_RUBRIQUES", "error_type": "warning"})
    ws.data_validation(13, 2, 13, 2, {"validate": "list", "source": "=L_CAISSES"})
    ws.write(16, 1, "Après « Enregistrer », l'écriture est numérotée et ne peut plus être modifiée : "
                    "une erreur se corrige par « Annuler l'écriture » dans le journal.", f["small"])


def arrete(b):
    ws = b.sheet("ARRETE_CAISSE")
    f = b.f
    b.title(ws, "ARRETE_CAISSE", 8, HDR)
    ws.set_column(0, 0, 2)
    ws.set_column(1, 1, 22)
    ws.set_column(2, 3, 14)
    ws.set_column(4, 4, 60)
    for i, h in enumerate(["Coupure (FCFA)", "Nombre", "Montant (FCFA)"]):
        ws.write(HDR - 1, 1 + i, h, f["hdr"])
    for i, (v, kind) in enumerate(COUPURES):
        r = FIRST - 1 + i
        ws.write(r, 1, "%s de %s" % (kind, "{:,}".format(v).replace(",", " ")), f["t"])
        ws.write(r, 2, "", f["input"])
        ws.write_formula(r, 3, "=%d*N(C%d)" % (v, r + 1), f["m"], 0)
    last = FIRST - 1 + len(COUPURES)
    ws.write(last, 1, "Total compté", f["label"])
    ws.write_formula(last, 3, "=SUM(D%d:D%d)" % (FIRST, last), f["m"], 0)
    ws.write(last + 1, 1, "Solde théorique (livre)", f["label"])
    ws.write(last + 1, 3, 0, f["m"])
    ws.write(last + 2, 1, "Écart (compté - livre)", f["label"])
    ws.write_formula(last + 2, 3, "=D%d-D%d" % (last + 1, last + 2), f["m"], 0)
    ws.write(last + 3, 1, "Observations", f["label"])
    ws.write(last + 3, 2, "", f["input"])
    ws.write(4, 4, "1. Comptez les billets et pièces, saisissez les nombres (cases jaunes).", f["info"])
    ws.write(5, 4, "2. « Calculer le solde théorique » reprend le solde espèces du journal.", f["info"])
    ws.write(6, 4, "3. « Enregistrer l'arrêté » archive le résultat et traite l'écart éventuel.", f["info"])


def recu(b):
    ws = b.sheet("RECU")
    f = b.f
    wb = b.wb
    ws.set_column(0, 0, 2)
    ws.set_column(1, 1, 24)
    ws.set_column(2, 2, 60)
    big = wb.add_format({"bold": True, "font_size": 16, "font_color": "#1E7B4A"})
    lab = wb.add_format({"bold": True, "align": "right", "valign": "vcenter"})
    val = wb.add_format({"font_size": 11, "bottom": 1, "valign": "vcenter", "text_wrap": True})
    ws.set_row(0, 30)
    ws.merge_range(0, 0, 0, 2, "", f["title"])
    ws.write(2, 1, "", big)
    ws.write(3, 1, "", f["home_sub"])
    labels = ["Reçu N°", "Date", "Reçu de", "Montant (FCFA)", "Montant en lettres", "Objet", "Mode de paiement",
              "Pièce de caisse"]
    for i, l in enumerate(labels):
        ws.set_row(5 + i, 24)
        ws.write(5 + i, 1, l + " :", lab)
        ws.write(5 + i, 2, "", val)
    ws.write(15, 1, "Le Secrétaire aux Finances", lab)
    ws.write(18, 1, "Signature :", lab)
    ws.set_paper(9)
    ws.set_portrait()
    ws.print_area(0, 0, 20, 2)
    ws.fit_to_pages(1, 1)


def names(b):
    wb = b.wb
    lc = b.listes_cols

    def dyn(key):
        c = lc[key]
        return "=OFFSET(LISTES!$%s$%d,0,0,MAX(1,COUNTA(LISTES!$%s$%d:$%s$300)),1)" % (c, FIRST, c, FIRST, c)

    for nm, key in [("L_CAISSES", "Caisse"), ("L_OPERATIONS", "Opération"), ("L_SENS", "Sens"),
                    ("L_FONDS", "Fonds"), ("L_TYPES_PERTE", "Type de perte"), ("L_NATURES", "Nature d'événement"),
                    ("L_STATUTS_CAMPAGNE", "Statut de campagne")]:
        wb.define_name(nm, dyn(key))
    wb.define_name("L_RUBRIQUES", '=OFFSET(RUBRIQUES!$G$%d,0,0,MAX(1,COUNTIF(RUBRIQUES!$G$%d:$G$300,"?*")),1)' % (FIRST, FIRST))
    wb.define_name("L_CAMPAGNES", "=OFFSET(CAMPAGNES!$A$%d,0,0,MAX(1,COUNTA(CAMPAGNES!$A$%d:$A$%d)),1)" % (FIRST, FIRST, MAXROWS))
    wb.define_name("L_EVENEMENTS", "=OFFSET(BAREME_SOCIAL!$A$%d,0,0,MAX(1,COUNTA(BAREME_SOCIAL!$A$%d:$A$300)),1)" % (FIRST, FIRST))
