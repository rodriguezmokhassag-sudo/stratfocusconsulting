"""Lot 5 : tableau de bord (chiffres et graphiques), rapports imprimables et
exportables en PDF (AG, point financier mensuel, livre de caisse, fiche d'un
membre, rapport par pupitre et par commission)."""

OUT_HDR = 8

TITLES = {
    "TABLEAU_BORD": "Tableau de bord",
    "RAPPORT_AG": "Rapport annuel pour l'Assemblée générale",
    "POINT_MENSUEL": "Point financier du mois",
    "LIVRE_CAISSE": "Livre de caisse",
    "FICHE_MEMBRE": "Fiche individuelle d'un membre",
    "RAPPORT_PUPITRES": "Assiduité et apprentissage par pupitre et par commission",
}
CODENAMES = {
    "TABLEAU_BORD": "shTableau", "RAPPORT_AG": "shRapportAG", "POINT_MENSUEL": "shPointMensuel",
    "LIVRE_CAISSE": "shLivreCaisse", "FICHE_MEMBRE": "shFicheMembre", "RAPPORT_PUPITRES": "shRapportPupitres",
}
ORDER_LOT5 = ["RAPPORT_AG", "POINT_MENSUEL", "LIVRE_CAISSE", "FICHE_MEMBRE", "RAPPORT_PUPITRES"]

PARAMS = [
    ("#", "Tableau de bord et rapports (lot 5)"),
    ("DOSSIER_RAPPORTS", "", "Dossier des PDF (vide : sous-dossier « Rapports » à côté du classeur)"),
    ("LOGO_FICHIER", "", "Dernier logo importé (sert aux couleurs proposées)"),
]

# Lignes fixes lues par les graphiques
TB_MOIS = (9, 20)          # TABLEAU_BORD F9:J20 : 12 mois de l'exercice
TB_PUP = (24, 29)          # TABLEAU_BORD F24:H29 : pupitres
RP_PUP = (9, 14)           # RAPPORT_PUPITRES : pupitres
RP_COM = (19, 30)          # RAPPORT_PUPITRES : commissions
COULEURS = ["#1E7B4A", "#C8102E", "#7F7F7F"]


def register(g):
    COULEURS[0], COULEURS[1] = g["PRINCIPALE"], g["ACCENT"]
    g["TITLES"].update(TITLES)
    g["CODENAMES"].update(CODENAMES)
    order = g["ORDER"]
    order.insert(order.index("ACCUEIL") + 1, "TABLEAU_BORD")
    i = order.index("ETUDES") + 1 if "ETUDES" in order else len(order)
    order[i:i] = ORDER_LOT5
    params = g["PARAMS"]
    k = [n for n, p in enumerate(params) if p[0] == "#" and p[1].startswith("Sécurité")][0]
    params[k:k] = PARAMS
    g["DROITS"][:] = [(m, "Tableau de bord et rapports" if m == "RAPPORTS" else d, v) for m, d, v in g["DROITS"]]


def _base(b, name, widths, landscape=True):
    ws = b.sheet(name)
    b.title(ws, name, max(len(widths), 8), OUT_HDR)
    for i, w in enumerate(widths):
        ws.set_column(i, i, w)
    ws.set_paper(9)
    if landscape:
        ws.set_landscape()
    else:
        ws.set_portrait()
    ws.fit_to_pages(1, 0)
    ws.set_margins(0.4, 0.4, 0.5, 0.5)
    return ws


def _hdr(b, ws, row, col, titres):
    for i, t in enumerate(titres):
        ws.write(row, col + i, t, b.f["hdr"])
    ws.set_row(row, 30)


def _chart(b, kind, title, series, y_fmt=None, subtype=None):
    opts = {"type": kind}
    if subtype:
        opts["subtype"] = subtype
    ch = b.wb.add_chart(opts)
    colors = COULEURS
    for i, s in enumerate(series):
        s = dict(s)
        col = colors[i % 3]
        if kind == "line":
            s.setdefault("line", {"color": col, "width": 2.25})
            s.setdefault("marker", {"type": "circle", "size": 5, "fill": {"color": col}, "border": {"color": col}})
        else:
            s.setdefault("fill", {"color": col})
            s.setdefault("border", {"none": True})
        ch.add_series(s)
    ch.set_title({"name": title, "name_font": {"size": 11, "bold": True}})
    ch.set_legend({"position": "bottom"})
    ch.set_chartarea({"border": {"none": True}})
    if y_fmt:
        ch.set_y_axis({"num_format": y_fmt, "major_gridlines": {"visible": True, "line": {"color": "#D9D9D9"}}})
    return ch


def build_sheets(b):
    f = b.f
    # ------------------------------------------------------------ tableau de bord
    ws = _base(b, "TABLEAU_BORD", [14, 36, 16, 46, 2, 14, 12, 14, 14, 16])
    ws.write(4, 1, "Situation au :", f["label"])
    ws.write(4, 2, "", f["input_d"])
    _hdr(b, ws, OUT_HDR - 1, 0, ["Domaine", "Indicateur", "Valeur", "Détail"])
    _hdr(b, ws, OUT_HDR - 1, 5, ["Mois", "Assiduité", "Recettes (FCFA)", "Dépenses (FCFA)", "Trésorerie fin de mois (FCFA)"])
    _hdr(b, ws, TB_PUP[0] - 2, 5, ["Pupitre", "Assiduité", "Cantiques maîtrisés"])
    for r in range(TB_MOIS[0] - 1, TB_MOIS[1]):
        ws.write_blank(r, 6, None, f["p"])
        for c in (7, 8, 9):
            ws.write_blank(r, c, None, f["m"])
    for r in range(TB_PUP[0] - 1, TB_PUP[1]):
        ws.write_blank(r, 6, None, f["p"])
        ws.write_blank(r, 7, None, f["p"])
    m1, m2 = TB_MOIS
    p1, p2 = TB_PUP
    cat = "=TABLEAU_BORD!$F$%d:$F$%d" % (m1, m2)
    ch1 = _chart(b, "line", "Taux d'assiduité par mois",
                 [{"name": ["TABLEAU_BORD", 7, 6], "categories": cat, "values": "=TABLEAU_BORD!$G$%d:$G$%d" % (m1, m2)}], "0%")
    ch1.set_y_axis({"num_format": "0%", "min": 0, "max": 1, "major_gridlines": {"visible": True, "line": {"color": "#D9D9D9"}}})
    ch2 = _chart(b, "column", "Recettes et dépenses par mois (FCFA)",
                 [{"name": ["TABLEAU_BORD", 7, 7], "categories": cat, "values": "=TABLEAU_BORD!$H$%d:$H$%d" % (m1, m2)},
                  {"name": ["TABLEAU_BORD", 7, 8], "categories": cat, "values": "=TABLEAU_BORD!$I$%d:$I$%d" % (m1, m2)}], "#,##0")
    ln = b.wb.add_chart({"type": "line"})
    ln.add_series({"name": ["TABLEAU_BORD", 7, 9], "categories": cat, "values": "=TABLEAU_BORD!$J$%d:$J$%d" % (m1, m2),
                   "line": {"color": "#7F7F7F", "width": 2, "dash_type": "dash"}, "y2_axis": True})
    ch2.combine(ln)
    ln.set_y2_axis({"num_format": "#,##0"})
    ch3 = _chart(b, "bar", "Par pupitre (exercice en cours)",
                 [{"name": ["TABLEAU_BORD", p1 - 2, 6], "categories": "=TABLEAU_BORD!$F$%d:$F$%d" % (p1, p2),
                   "values": "=TABLEAU_BORD!$G$%d:$G$%d" % (p1, p2)},
                  {"name": ["TABLEAU_BORD", p1 - 2, 7], "categories": "=TABLEAU_BORD!$F$%d:$F$%d" % (p1, p2),
                   "values": "=TABLEAU_BORD!$H$%d:$H$%d" % (p1, p2)}])
    ch3.set_x_axis({"num_format": "0%", "min": 0, "max": 1, "major_unit": 0.25, "major_gridlines": {"visible": True, "line": {"color": "#D9D9D9"}}})
    ch3.set_y_axis({"reverse": True})
    for k, ch in enumerate((ch1, ch2, ch3)):
        ch.set_size({"width": 470, "height": 290})
        ws.insert_chart(32, 0, ch, {"x_offset": 5 + k * 480, "y_offset": 5})
    ws.freeze_panes(OUT_HDR, 0)
    ws.print_area(0, 0, 52, 9)

    # ------------------------------------------------------------ rapport AG (texte libre A:F)
    ws = _base(b, "RAPPORT_AG", [38, 16, 16, 16, 16, 26], landscape=False)
    ws.write(4, 1, "Exercice :", f["label"])
    ws.write(4, 2, "", f["input"])

    # ------------------------------------------------------------ point financier du mois
    ws = _base(b, "POINT_MENSUEL", [38, 16, 16, 16, 12, 26], landscape=False)
    ws.write(4, 1, "Mois (une date du mois) :", f["label"])
    ws.write(4, 2, "", f["input_d"])

    # ------------------------------------------------------------ livre de caisse
    ws = _base(b, "LIVRE_CAISSE", [13, 11, 9, 8, 38, 22, 13, 13, 14])
    ws.write(4, 1, "Du :", f["label"])
    ws.write(4, 2, "", f["input_d"])
    ws.write(4, 3, "au :", f["label"])
    ws.write(4, 4, "", f["input_d"])
    ws.write(4, 5, "Caisse :", f["label"])
    ws.write(4, 6, "Toutes", f["input"])
    ws.data_validation(4, 6, 4, 6, {"validate": "list", "source": ["Toutes", "Espèces", "Banque"]})
    _hdr(b, ws, OUT_HDR - 1, 0, ["N° pièce", "Date", "Caisse", "Code", "Libellé", "Tiers / Nom", "Recette (FCFA)",
                                 "Dépense (FCFA)", "Solde (FCFA)"])
    ws.set_column(1, 1, 11, f["d"])
    ws.set_column(6, 8, 13, f["m"])
    ws.freeze_panes(OUT_HDR, 0)
    ws.repeat_rows(OUT_HDR - 1)

    # ------------------------------------------------------------ fiche d'un membre
    ws = _base(b, "FICHE_MEMBRE", [30, 18, 16, 16, 16, 26], landscape=False)
    ws.write(4, 1, "Matricule :", f["label"])
    ws.write(4, 2, "", f["input"])

    # ------------------------------------------------------------ pupitres et commissions
    ws = _base(b, "RAPPORT_PUPITRES", [26, 9, 11, 11, 11, 11, 11, 11, 11])
    ws.write(4, 1, "Du :", f["label"])
    ws.write(4, 2, "", f["input_d"])
    ws.write(4, 3, "au :", f["label"])
    ws.write(4, 4, "", f["input_d"])
    _hdr(b, ws, OUT_HDR - 1, 0, ["Pupitre", "Membres", "Séances attendues", "Présences pondérées", "Assiduité",
                                 "Cantiques maîtrisés", "En apprentissage", "Non commencés", "Taux de maîtrise"])
    ws.write(RP_COM[0] - 3, 0, "PAR COMMISSION", f["section"])
    _hdr(b, ws, RP_COM[0] - 2, 0, ["Commission", "Membres", "Séances attendues", "Présences pondérées", "Assiduité"])
    for r in list(range(RP_PUP[0] - 1, RP_PUP[1] + 1)) + list(range(RP_COM[0] - 1, RP_COM[1])):
        ws.write_blank(r, 4, None, f["p"])
        ws.write_blank(r, 8, None, f["p"])
    a, z = RP_PUP
    ch = _chart(b, "column", "Assiduité et maîtrise des cantiques par pupitre",
                [{"name": ["RAPPORT_PUPITRES", OUT_HDR - 1, 4], "categories": "=RAPPORT_PUPITRES!$A$%d:$A$%d" % (a, z), "values": "=RAPPORT_PUPITRES!$E$%d:$E$%d" % (a, z)},
                 {"name": ["RAPPORT_PUPITRES", OUT_HDR - 1, 8], "categories": "=RAPPORT_PUPITRES!$A$%d:$A$%d" % (a, z), "values": "=RAPPORT_PUPITRES!$I$%d:$I$%d" % (a, z)}], "0%")
    ch.set_y_axis({"num_format": "0%", "min": 0, "max": 1, "major_gridlines": {"visible": True, "line": {"color": "#D9D9D9"}}})
    ch.set_size({"width": 560, "height": 320})
    ch.set_legend({"position": "top"})
    ws.insert_chart(OUT_HDR - 1, 10, ch)
    a, z = RP_COM
    ch = _chart(b, "bar", "Assiduité par commission",
                [{"name": ["RAPPORT_PUPITRES", RP_COM[0] - 2, 4], "categories": "=RAPPORT_PUPITRES!$A$%d:$A$%d" % (a, z), "values": "=RAPPORT_PUPITRES!$E$%d:$E$%d" % (a, z)}])
    ch.set_x_axis({"num_format": "0%", "min": 0, "max": 1, "major_unit": 0.25, "major_gridlines": {"visible": True, "line": {"color": "#D9D9D9"}}})
    ch.set_y_axis({"reverse": True})
    ch.set_legend({"none": True})
    ch.set_size({"width": 520, "height": 300})
    ws.insert_chart(RP_COM[0] - 3, 10, ch)
    ws.print_area(0, 0, 34, 17)
