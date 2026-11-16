"""Lot 4 : discipline et sanctions, planning des activités, mandats et
élections, cantiques et vie spirituelle."""

HDR, FIRST, OUT_HDR, MAXROWS = 4, 5, 8, 5000

COLS = {
    "DISCIPLINE": [("N°", 13, "t"), ("Date des faits", 11, "d"), ("Matricule", 11, "t"), ("Nom et prénoms", 24, "t"),
                   ("Faute", 30, "t"), ("Description", 30, "t"), ("Sanction", 22, "t"), ("Prononcée par", 20, "t"),
                   ("Date de la décision", 11, "d"), ("Début", 11, "d"), ("Fin", 11, "d"), ("Statut antérieur", 16, "t"),
                   ("Notifiée le", 11, "d"), ("Mode de notification", 18, "t"), ("Récidives (12 mois)", 9, "n"),
                   ("Statut", 12, "t"), ("Observations", 28, "t"), ("Saisi par", 20, "t")],
    "PLANNING": [("N°", 13, "t"), ("Exercice", 9, "t"), ("Début", 11, "d"), ("Fin", 11, "d"), ("Activité", 30, "t"),
                 ("Type", 8, "t"), ("Lieu", 18, "t"), ("Hors paroisse", 9, "t"), ("Commission responsable", 18, "t"),
                 ("Code budgétaire", 9, "t"), ("Budget prévu (FCFA)", 12, "m"), ("Réalisé (FCFA)", 12, "m"),
                 ("Validation paroissiale", 13, "t"), ("Réf. validation", 16, "t"), ("Statut", 12, "t"),
                 ("Séance", 17, "t"), ("Observations", 28, "t")],
    "MANDATS": [("N°", 13, "t"), ("Organe", 16, "t"), ("Fonction", 30, "t"), ("Matricule", 11, "t"),
                ("Nom et prénoms", 24, "t"), ("Début", 11, "d"), ("Fin", 11, "d"), ("Rang", 7, "n"),
                ("Désignation", 18, "t"), ("Statut", 11, "t"), ("Scrutin", 12, "t"), ("Observations", 28, "t")],
    "SCRUTINS": [("N°", 12, "t"), ("Date", 11, "d"), ("Type", 11, "t"), ("Postes", 40, "t"), ("Électeurs inscrits", 10, "n"),
                 ("Votants", 9, "n"), ("Statut", 12, "t"), ("PV établi le", 11, "d"), ("Observations", 30, "t")],
    "CANDIDATS": [("Scrutin", 12, "t"), ("Poste", 34, "t"), ("Matricule", 11, "t"), ("Nom et prénoms", 26, "t"),
                  ("Voix", 8, "n"), ("Élu", 7, "t"), ("Observations", 30, "t")],
    "CANTIQUES": [("N°", 9, "t"), ("Titre", 32, "t"), ("Recueil", 22, "t"), ("N° dans le recueil", 9, "t"), ("Langue", 10, "t"),
                  ("Thème / temps liturgique", 20, "t"), ("Compositeur / auteur", 18, "t"), ("Tonalité", 8, "t"),
                  ("Soprano", 13, "t"), ("Alto", 13, "t"), ("Ténor", 13, "t"), ("Basse", 13, "t"), ("Niveau", 14, "t"),
                  ("Dernière exécution", 11, "d"), ("Exécutions (12 mois)", 9, "n"), ("Observations", 28, "t")],
    "PROGRAMMES": [("Date", 11, "d"), ("Célébration", 24, "t"), ("Ordre", 6, "n"), ("N° cantique", 9, "t"), ("Titre", 32, "t"),
                   ("Recueil", 22, "t"), ("Moment", 14, "t"), ("Remarques", 30, "t")],
    "ETUDES": [("Date", 11, "d"), ("Type", 18, "t"), ("Thème", 32, "t"), ("Texte biblique", 18, "t"),
               ("Orateur / animateur", 22, "t"), ("Lieu", 16, "t"), ("Séance", 17, "t"), ("Statut", 10, "t"),
               ("Observations", 28, "t")],
}

TITLES = {
    "DISCIPLINE": "Discipline et sanctions (art. 45 à 52) - CONFIDENTIEL",
    "NOTIFICATION": "Notification de sanction",
    "PLANNING": "Planning annuel des activités (préparé par le Bureau, voté en AG)",
    "PROGRAMME_ANNUEL": "Programme annuel des activités",
    "MANDATS": "Mandats du Bureau et des commissions (art. 9 à 11)",
    "SCRUTINS": "Élections (art. 21 à 23)",
    "CANDIDATS": "Candidats et résultats des élections",
    "PV_ELECTION": "Procès-verbal d'élection",
    "CANTIQUES": "Répertoire des cantiques et apprentissage par pupitre",
    "PROGRAMMES": "Programmes des chants par célébration",
    "PROGRAMME_CHANTS": "Programme des chants",
    "ETUDES": "Études bibliques, affermissement et formation (art. 16-7)",
}

CODENAMES = {
    "DISCIPLINE": "shDiscipline", "NOTIFICATION": "shNotification", "PLANNING": "shPlanning",
    "PROGRAMME_ANNUEL": "shProgAnnuel", "MANDATS": "shMandats", "SCRUTINS": "shScrutins", "CANDIDATS": "shCandidats",
    "PV_ELECTION": "shPV", "CANTIQUES": "shCantiques", "PROGRAMMES": "shProgrammes",
    "PROGRAMME_CHANTS": "shProgChants", "ETUDES": "shEtudes",
}
ORDER_LOT4 = ["DISCIPLINE", "NOTIFICATION", "PLANNING", "PROGRAMME_ANNUEL", "MANDATS", "SCRUTINS", "CANDIDATS",
              "PV_ELECTION", "CANTIQUES", "PROGRAMMES", "PROGRAMME_CHANTS", "ETUDES"]
JOURNALED = {"DISCIPLINE", "PLANNING", "MANDATS", "CANDIDATS", "CANTIQUES", "PROGRAMMES", "ETUDES"}

PARAMS = [
    ("#", "Discipline, planning, mandats, cantiques (lot 4)"),
    ("EXCLUSION_TEMP_MAX_JOURS", 15, "Durée maximale d'une exclusion temporaire (art. 48)"),
    ("MOIS_RECIDIVE", 12, "Période de recherche des récidives (mois)"),
    ("JOURS_ALERTE_PLANNING", 30, "Alerte pour les activités proches non validées (jours)"),
    ("DUREE_MANDAT_ANS", 2, "Durée d'un mandat (art. 11)"),
    ("MANDATS_CONSECUTIFS_MAX", 2, "Nombre de mandats consécutifs autorisés (mandat renouvelable une fois)"),
    ("JOURS_ALERTE_MANDAT", 90, "Alerte avant la fin des mandats (jours)"),
    ("SEMAINES_REPETITION_CHANT", 4, "Alerte si un chant programmé a été chanté il y a moins de ce nombre de semaines"),
]

LISTES_ADD = {
    "Faute": ["Agissements contraires au règlement intérieur", "Désobéissance à la volonté de Dieu (Bible)",
              "Querelle, bagarre, médisance, mensonge, écart de langage", "Mauvaise tenue pendant les cultes, répétitions",
              "Manque de respect aux autorités de l'église", "Absences non justifiées aux activités", "Ivresse, tabagisme",
              "Habillement indécent", "Bavardage", "Adultère et fornication", "Non-paiement des cotisations statutaires",
              "Discussions politiques dans la chorale", "Retards abusifs", "Maquillage à outrance", "Adhésion à une secte",
              "Manque de respect dans le groupe"],
    "Sanction": ["Avertissement verbal", "Avertissement", "Blâme", "Suspension des fonctions", "Exclusion temporaire",
                 "Exclusion indéterminée", "Exclusion définitive"],
    "Autorité": ["Bureau de la chorale", "Directeur de chœur", "Responsables de la paroisse"],
    "Notification": ["En présence de l'intéressé", "Par écrit (refus de se présenter)"],
    "Statut de dossier": ["À examiner", "En cours", "Terminée", "Levée", "Classée"],
    "Validation paroissiale": ["Non requise", "Demandée", "Obtenue", "Refusée"],
    "Statut d'activité": ["Projet", "Votée en AG", "Validée", "Réalisée", "Annulée"],
    "Organe": ["Bureau", "Commission"],
    "Désignation": ["Élu en AG", "Élection partielle", "Désigné par le Bureau"],
    "Statut de mandat": ["En cours", "Terminé", "Démission", "Révoqué"],
    "Type de scrutin": ["Ordinaire", "Partielle"],
    "Recueil": ["Nkunga mia Kintwadi", "Sur les Ailes de la Foi", "Chant de victoire", "Nkunga mia nsikumusu",
                "Composition de la chorale", "Autre"],
    "Langue": ["Kituba", "Lingala", "Français", "Lari", "Vili", "Anglais", "Autre"],
    "Niveau d'apprentissage": ["Non commencé", "En apprentissage", "Maîtrisé"],
    "Moment": ["Entrée", "Louange", "Adoration", "Offrande", "Méditation", "Sainte cène", "Envoi", "Autre"],
    "Type d'étude": ["Étude biblique", "Affermissement", "Retraite spirituelle", "Veillée de prière", "Formation musicale"],
    "Statut d'étude": ["Prévue", "Réalisée", "Reportée"],
}

VALIDATIONS = [
    ("DISCIPLINE", "Faute", "L_FAUTES"), ("DISCIPLINE", "Sanction", "L_SANCTIONS"),
    ("DISCIPLINE", "Prononcée par", "L_AUTORITES"), ("DISCIPLINE", "Mode de notification", "L_NOTIFICATIONS"),
    ("DISCIPLINE", "Statut", "L_STATUTS_DOSSIER"),
    ("PLANNING", "Type", "L_TYPES"), ("PLANNING", "Hors paroisse", "L_OUINON"), ("PLANNING", "Commission responsable", "L_COMMISSIONS"),
    ("PLANNING", "Validation paroissiale", "L_VALIDATIONS"), ("PLANNING", "Statut", "L_STATUTS_ACTIVITE"),
    ("MANDATS", "Organe", "L_ORGANES"), ("MANDATS", "Désignation", "L_DESIGNATIONS"), ("MANDATS", "Statut", "L_STATUTS_MANDAT"),
    ("SCRUTINS", "Type", "L_TYPES_SCRUTIN"), ("CANDIDATS", "Élu", "L_OUINON"),
    ("CANTIQUES", "Recueil", "L_RECUEILS"), ("CANTIQUES", "Langue", "L_LANGUES"),
    ("CANTIQUES", "Soprano", "L_NIVEAUX"), ("CANTIQUES", "Alto", "L_NIVEAUX"), ("CANTIQUES", "Ténor", "L_NIVEAUX"),
    ("CANTIQUES", "Basse", "L_NIVEAUX"), ("PROGRAMMES", "Moment", "L_MOMENTS"),
    ("ETUDES", "Type", "L_TYPES_ETUDE"), ("ETUDES", "Statut", "L_STATUTS_ETUDE"),
]


def register(g):
    g["COLS"].update(COLS)
    g["TITLES"].update(TITLES)
    g["CODENAMES"].update(CODENAMES)
    order = g["ORDER"]
    i = order.index("ETIQUETTES") + 1 if "ETIQUETTES" in order else order.index("PATRIMOINE") + 1
    order[i:i] = ORDER_LOT4
    g["JOURNALED"].update(JOURNALED)
    params = g["PARAMS"]
    k = [n for n, p in enumerate(params) if p[0] == "#" and p[1].startswith("Sécurité")][0]
    params[k:k] = PARAMS
    g["LISTES"].update(LISTES_ADD)


def build_sheets(b):
    d = b.data
    for name, fz in [("DISCIPLINE", 4), ("PLANNING", 5), ("MANDATS", 3), ("SCRUTINS", 1), ("CANDIDATS", 2),
                     ("CANTIQUES", 2), ("PROGRAMMES", 2), ("ETUDES", 3)]:
        b.table(name, d.get(name.lower(), []), freeze_col=fz)
    for sheet, header, src in VALIDATIONS:
        b.validation(b.ws[sheet], sheet, header, "=" + src)
    for c in ("Date des faits", "Date de la décision", "Début", "Fin", "Notifiée le"):
        b.validation(b.ws["DISCIPLINE"], "DISCIPLINE", c, None, "date")
    printable(b, "NOTIFICATION", portrait=True)
    printable(b, "PV_ELECTION", portrait=True)
    rep = report(b, "PROGRAMME_ANNUEL", [("Mois", 14, "t"), ("Dates", 20, "t"), ("Activité", 34, "t"), ("Type", 10, "t"),
                                         ("Lieu", 20, "t"), ("Commission", 18, "t"), ("Budget prévu (FCFA)", 13, "m"),
                                         ("Statut", 12, "t")])
    rep.write(4, 1, "Exercice :", b.f["label"])
    rep.write(4, 2, "", b.f["input"])
    pc = report(b, "PROGRAMME_CHANTS", [("Ordre", 7, "n"), ("Moment", 16, "t"), ("N°", 9, "t"), ("Titre", 38, "t"),
                                        ("Recueil", 24, "t"), ("Remarques", 34, "t")])
    pc.write(4, 1, "Date :", b.f["label"])
    pc.write(4, 2, "", b.f["input_d"])
    pc.set_portrait()


def report(b, name, cols):
    ws = b.sheet(name)
    b.title(ws, name, len(cols), OUT_HDR)
    for i, (h, w, t) in enumerate(cols):
        ws.set_column(i, i, w, b.f[t])
        ws.write(OUT_HDR - 1, i, h, b.f["hdr"])
    ws.set_row(OUT_HDR - 1, 30)
    ws.freeze_panes(OUT_HDR, 0)
    ws.set_landscape()
    ws.set_paper(9)
    ws.fit_to_pages(1, 0)
    ws.repeat_rows(0, OUT_HDR - 1)
    return ws


def printable(b, name, portrait=True):
    ws = b.sheet(name)
    ws.set_column(0, 0, 2)
    ws.set_column(1, 1, 24)
    ws.set_column(2, 2, 30)
    ws.set_column(3, 5, 14)
    ws.set_row(0, 30)
    ws.merge_range(0, 0, 0, 5, "", b.f["title"])
    ws.set_paper(9)
    if portrait:
        ws.set_portrait()
    ws.fit_to_pages(1, 1)
    ws.print_area(0, 0, 50, 5)


def names(b):
    wb = b.wb
    lc = b.listes_cols

    def dyn(key):
        c = lc[key]
        return "=OFFSET(LISTES!$%s$%d,0,0,MAX(1,COUNTA(LISTES!$%s$%d:$%s$300)),1)" % (c, FIRST, c, FIRST, c)

    for nm, key in [("L_FAUTES", "Faute"), ("L_SANCTIONS", "Sanction"), ("L_AUTORITES", "Autorité"),
                    ("L_NOTIFICATIONS", "Notification"), ("L_STATUTS_DOSSIER", "Statut de dossier"),
                    ("L_VALIDATIONS", "Validation paroissiale"), ("L_STATUTS_ACTIVITE", "Statut d'activité"),
                    ("L_ORGANES", "Organe"), ("L_DESIGNATIONS", "Désignation"), ("L_STATUTS_MANDAT", "Statut de mandat"),
                    ("L_TYPES_SCRUTIN", "Type de scrutin"), ("L_RECUEILS", "Recueil"), ("L_LANGUES", "Langue"),
                    ("L_NIVEAUX", "Niveau d'apprentissage"), ("L_MOMENTS", "Moment"), ("L_TYPES_ETUDE", "Type d'étude"),
                    ("L_STATUTS_ETUDE", "Statut d'étude")]:
        wb.define_name(nm, dyn(key))
