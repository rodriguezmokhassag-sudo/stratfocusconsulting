"""Données fictives du lot 4 : discipline, planning, mandats, élections, cantiques, études."""
import datetime as dt

D = dt.date
FICTIF = "DONNÉES FICTIVES"

FONCTIONS = ["1er Responsable", "Vice-Responsable", "Secrétaire Général", "Secrétaire Général Adjoint",
             "Secrétaire aux Finances", "Secrétaire aux Patrimoines", "Secrétaire chargé à l'Évangélisation et Mission"]

CANTIQUES = [
    # titre, recueil, n°, langue, thème, auteur, tonalité, S, A, T, B
    ("À toi la gloire, ô Ressuscité", "Sur les Ailes de la Foi", "250", "Français", "Pâques", "E. Budry / G. F. Haendel", "Ré", "M", "M", "M", "M"),
    ("Grâce infinie", "Sur les Ailes de la Foi", "112", "Français", "Grâce", "J. Newton", "Sol", "M", "M", "M", "M"),
    ("Quel ami fidèle et tendre", "Sur les Ailes de la Foi", "263", "Français", "Prière", "J. Scriven / C. Converse", "Fa", "M", "M", "M", "M"),
    ("Torrents d'amour et de grâce", "Sur les Ailes de la Foi", "173", "Français", "Louange", "W. Rees", "Mi b", "M", "M", "A", "M"),
    ("Mon Dieu, plus près de toi", "Sur les Ailes de la Foi", "325", "Français", "Consécration", "S. Adams / L. Mason", "Sol", "M", "M", "M", "M"),
    ("Ô Jésus, ma joie", "Sur les Ailes de la Foi", "305", "Français", "Adoration", "J. Franck", "Ré", "M", "A", "A", "M"),
    ("Il est né, le divin Enfant", "Chant de victoire", "45", "Français", "Noël", "Traditionnel", "Sol", "M", "M", "M", "M"),
    ("Douce nuit, sainte nuit", "Chant de victoire", "48", "Français", "Noël", "F. Gruber", "Si b", "M", "M", "M", "M"),
    ("Les anges dans nos campagnes", "Chant de victoire", "50", "Français", "Noël", "Traditionnel", "Fa", "A", "A", "N", "A"),
    ("Debout, sainte cohorte", "Chant de victoire", "112", "Français", "Combat de la foi", "Traditionnel", "Do", "M", "M", "M", "A"),
    ("Je louerai l'Éternel", "Chant de victoire", "6", "Français", "Louange", "C. Fraysse", "Mi", "M", "M", "M", "M"),
    ("Agneau de Dieu", "Composition de la chorale", "C-01", "Français", "Sainte cène", "Commission musicale ADC", "Ré", "M", "M", "A", "A"),
    ("Nzambe azali malamu", "Composition de la chorale", "C-02", "Lingala", "Louange", "Commission musicale ADC", "Sol", "M", "M", "M", "M"),
    ("Yesu azali awa", "Composition de la chorale", "C-03", "Lingala", "Adoration", "Commission musicale ADC", "Fa", "M", "M", "M", "M"),
    ("Tata Nzambi", "Nkunga mia Kintwadi", "15", "Kituba", "Prière", "Traditionnel", "Do", "M", "M", "M", "M"),
    ("Mfumu Yesu", "Nkunga mia Kintwadi", "27", "Kituba", "Adoration", "Traditionnel", "Ré", "M", "M", "M", "M"),
    ("Kembelela Nzambi", "Nkunga mia Kintwadi", "33", "Kituba", "Louange", "Traditionnel", "Sol", "M", "M", "A", "M"),
    ("Mpeve ya Nlongo", "Nkunga mia Kintwadi", "58", "Kituba", "Pentecôte", "Traditionnel", "Fa", "A", "A", "A", "N"),
    ("Luzolo lua Nzambi", "Nkunga mia Kintwadi", "71", "Kituba", "Consécration", "Traditionnel", "Mi b", "M", "M", "M", "M"),
    ("Nkembo kwa Nzambi", "Nkunga mia Kintwadi", "84", "Kituba", "Louange", "Traditionnel", "Do", "M", "M", "M", "M"),
    ("Tusambila", "Nkunga mia nsikumusu", "12", "Lari", "Prière", "Traditionnel", "Sol", "M", "M", "M", "M"),
    ("Nzambi wa ngolo", "Nkunga mia nsikumusu", "19", "Lari", "Louange", "Traditionnel", "La", "M", "A", "M", "M"),
    ("Kiese kia Mfumu", "Nkunga mia nsikumusu", "26", "Lari", "Action de grâce", "Traditionnel", "Ré", "M", "M", "M", "A"),
    ("Mbote ya Nzambe", "Composition de la chorale", "C-04", "Lingala", "Action de grâce", "Commission musicale ADC", "Fa", "A", "A", "N", "N"),
    ("Tokumisa Yawe", "Composition de la chorale", "C-05", "Lingala", "Louange", "Commission musicale ADC", "Sol", "M", "M", "M", "M"),
    ("Esprit de Dieu, souffle de vie", "Chant de victoire", "160", "Français", "Pentecôte", "Traditionnel", "Mi", "A", "A", "A", "A"),
    ("Ta fidélité est grande", "Sur les Ailes de la Foi", "350", "Français", "Action de grâce", "T. Chisholm / W. Runyan", "Mi b", "M", "M", "M", "M"),
    ("Seigneur, rassemble-nous", "Chant de victoire", "205", "Français", "Entrée", "Traditionnel", "Do", "M", "M", "M", "M"),
    ("Venez, chrétiens, voyez", "Chant de victoire", "60", "Français", "Noël", "Traditionnel", "Sol", "N", "N", "N", "N"),
    ("Va, mon âme, va", "Composition de la chorale", "C-06", "Français", "Envoi", "Commission musicale ADC", "Ré", "M", "M", "M", "M"),
    ("Amen, alléluia", "Composition de la chorale", "C-07", "Français", "Envoi", "Commission musicale ADC", "Fa", "M", "M", "M", "M"),
    ("Kumama Nzambi", "Nkunga mia Kintwadi", "102", "Kituba", "Offrande", "Traditionnel", "Do", "M", "M", "M", "M"),
    ("Bakristo, telema", "Composition de la chorale", "C-08", "Lingala", "Évangélisation", "Commission musicale ADC", "La", "M", "M", "A", "A"),
    ("Ndako ya Nzambe", "Composition de la chorale", "C-09", "Lingala", "Entrée", "Commission musicale ADC", "Sol", "M", "M", "M", "M"),
    ("Mwana Nzambi", "Nkunga mia Kintwadi", "118", "Kituba", "Noël", "Traditionnel", "Fa", "A", "N", "N", "A"),
    ("Ô Dieu, notre aide aux temps anciens", "Sur les Ailes de la Foi", "40", "Français", "Fin d'année", "I. Watts / W. Croft", "Do", "M", "M", "M", "M"),
    ("Merci, Seigneur", "Chant de victoire", "220", "Français", "Offrande", "Traditionnel", "Ré", "M", "M", "M", "M"),
    ("Bénis, mon âme, le Seigneur", "Sur les Ailes de la Foi", "61", "Français", "Louange", "Traditionnel", "Sol", "M", "M", "M", "M"),
    ("Nsangu ya mbote", "Nkunga mia Kintwadi", "140", "Kituba", "Évangélisation", "Traditionnel", "Mi", "M", "M", "M", "M"),
    ("Grand Dieu, nous te bénissons", "Sur les Ailes de la Foi", "1", "Français", "Entrée", "Traditionnel", "Ré", "M", "M", "M", "M"),
]
NIV = {"M": "Maîtrisé", "A": "En apprentissage", "N": "Non commencé"}

# Programmes des cultes : (date, célébration, [(moment, index du cantique)])
PROGRAMMES = [
    (D(2026, 9, 27), "Culte dominical", [("Entrée", 39), ("Louange", 12), ("Adoration", 15), ("Offrande", 31), ("Envoi", 29)]),
    (D(2026, 10, 4), "Culte de sainte cène", [("Entrée", 27), ("Louange", 16), ("Méditation", 2), ("Sainte cène", 11), ("Envoi", 30)]),
    (D(2026, 10, 11), "Culte dominical", [("Entrée", 33), ("Louange", 10), ("Adoration", 5), ("Offrande", 36), ("Envoi", 29)]),
    (D(2026, 10, 18), "Culte d'action de grâce", [("Entrée", 39), ("Louange", 19), ("Adoration", 13), ("Offrande", 22), ("Envoi", 30)]),
    (D(2026, 10, 25), "Culte dominical", [("Entrée", 27), ("Louange", 24), ("Méditation", 4), ("Offrande", 31), ("Envoi", 32)]),
    # Programme à venir : le cantique 19 a été chanté le 18/10 (moins de 4 semaines) et le 23 n'est pas maîtrisé
    (D(2026, 11, 1), "Culte dominical", [("Entrée", 33), ("Louange", 19), ("Adoration", 14), ("Offrande", 23), ("Envoi", 29)]),
]


def build(info, today):
    """info : liste des membres de demo.py (les 7 premiers forment le Bureau)."""
    by_mat = {m["mat"]: m for m in info}
    out = {}

    # ------------------------------------------------------------ discipline
    def dos(n, faits, mat, faute, desc, sanction, par, decision, debut, fin, ant, notif, mode, statut, obs, recid=0):
        m = by_mat[mat]
        return ["DIS-%s-%03d" % (faits.year, n), faits, mat, m["nom"], faute, desc, sanction, par, decision, debut, fin, ant,
                notif, mode, recid, statut, obs, "1er Responsable"]

    susp = [m for m in info if m["kind"] == "SUSP"]
    out["discipline"] = [
        dos(1, D(2026, 2, 7), "ADC-0023", "Bavardage", "Bavardages répétés pendant la répétition", "Avertissement verbal",
            "Directeur de chœur", D(2026, 2, 7), None, None, "", D(2026, 2, 7), "En présence de l'intéressé", "Terminée", FICTIF),
        dos(2, D(2026, 3, 14), "ADC-0023", "Retards abusifs", "Cinq retards en un mois", "Avertissement",
            "Bureau de la chorale", D(2026, 3, 18), None, None, "", D(2026, 3, 21), "En présence de l'intéressé", "Terminée", FICTIF, 1),
        dos(3, D(2026, 4, 26), "ADC-0051", "Querelle, bagarre, médisance, mensonge, écart de langage",
            "Dispute avec un choriste après le culte", "Exclusion temporaire", "Bureau de la chorale", D(2026, 5, 2),
            D(2026, 5, 4), D(2026, 5, 18), "Choriste confirmé", D(2026, 5, 3), "En présence de l'intéressé", "Terminée", FICTIF),
        dos(4, D(2026, 6, 20), "ADC-0044", "Habillement indécent", "Tenue non conforme lors d'une sortie", "Avertissement verbal",
            "Directeur de chœur", D(2026, 6, 20), None, None, "", D(2026, 6, 20), "En présence de l'intéressé", "Terminée", FICTIF),
        dos(5, D(2026, 8, 22), susp[0]["mat"], "Absences non justifiées aux activités", "Absences répétées sans justification (juillet-août)",
            "Suspension des fonctions", "Bureau de la chorale", D(2026, 8, 29), D(2026, 9, 1), D(2026, 11, 30),
            "Choriste confirmé", D(2026, 8, 30), "En présence de l'intéressé", "En cours", FICTIF),
        dos(6, D(2026, 8, 22), susp[1]["mat"], "Manque de respect aux autorités de l'église", "Propos déplacés envers un responsable",
            "Suspension des fonctions", "Bureau de la chorale", D(2026, 8, 29), D(2026, 9, 1), D(2026, 10, 31),
            "Choriste confirmé", D(2026, 9, 2), "Par écrit (refus de se présenter)", "En cours", FICTIF),
        dos(7, D(2026, 10, 7), "ADC-0062", "Retards abusifs", "Retards répétés aux répétitions du samedi", "Blâme",
            "Bureau de la chorale", D(2026, 10, 10), None, None, "", None, "", "En cours", "Notification à faire - " + FICTIF),
    ]

    # ------------------------------------------------------------ planning 2026
    def act(n, debut, fin, lib, typ, lieu, hors, com, code, budget, valid, ref, statut, seance="", obs=""):
        return ["ACT-2026-%02d" % n, "2026", debut, fin, lib, typ, lieu, hors, com, code, budget, None, valid, ref,
                statut, seance, obs or FICTIF]

    out["planning"] = [
        act(1, D(2026, 1, 25), None, "Assemblée générale ordinaire (vote du budget)", "REUN", "Temple", "NON", "Organisation",
            "", 0, "Non requise", "", "Réalisée"),
        act(2, D(2026, 4, 5), None, "Culte de Pâques animé par la chorale", "CULTE", "Temple", "NON", "Musicale",
            "D03.1", 0, "Non requise", "", "Réalisée"),
        act(3, D(2026, 5, 16), None, "Sortie d'évangélisation au quartier Mpita", "EVANG", "Quartier Mpita", "OUI", "Organisation",
            "D02.1", 150000, "Obtenue", "Lettre paroisse 2026-14", "Réalisée", "S20260516-EVANG"),
        act(4, D(2026, 8, 7), D(2026, 8, 9), "Retraite spirituelle de la chorale", "VEIL", "Centre d'accueil de Loango", "OUI",
            "Intercession", "D01.2", 180000, "Obtenue", "Lettre consistoire 2026-31", "Réalisée", "S20260807-VEIL"),
        act(5, D(2026, 11, 14), None, "Sortie d'évangélisation à Tié-Tié", "EVANG", "Paroisse de Tié-Tié", "OUI", "Organisation",
            "D02.1", 120000, "Demandée", "", "Votée en AG"),
        act(6, D(2026, 11, 28), None, "Journée d'affermissement des nouveaux choristes", "ETUDE", "Salle de répétition", "NON",
            "Réflexion", "", 15000, "Non requise", "", "Validée"),
        act(7, D(2026, 12, 13), None, "Assemblée générale de fin d'année (rapports, inventaire)", "REUN", "Temple", "NON",
            "Organisation", "", 0, "Non requise", "", "Votée en AG"),
        act(8, D(2026, 12, 20), None, "Concert de Noël", "AUTRE", "Temple", "NON", "Culturelle", "D07.1", 250000,
            "Non requise", "", "Votée en AG"),
        act(9, D(2026, 12, 31), None, "Veillée de fin d'année", "VEIL", "Temple", "NON", "Intercession", "", 30000,
            "Non requise", "", "Projet"),
    ]

    # ------------------------------------------------------------ mandats et élections
    bureau = info[:7]
    debut, fin = D(2025, 1, 19), D(2027, 1, 17)
    rang2 = {0, 2, 4}   # 2e mandat : un nouveau renouvellement serait un 3e mandat
    mandats, n = [], 0
    for k, m in enumerate(bureau):
        if k in rang2:
            n += 1
            mandats.append(["MAN-%03d" % n, "Bureau", FONCTIONS[k], m["mat"], m["nom"], D(2023, 1, 22), D(2025, 1, 18), 1,
                            "Élu en AG", "Terminé", "", FICTIF])
    for k, m in enumerate(bureau):
        n += 1
        mandats.append(["MAN-%03d" % n, "Bureau", FONCTIONS[k], m["mat"], m["nom"], debut, fin, 2 if k in rang2 else 1,
                        "Élu en AG", "En cours", "EL-2025-01", FICTIF])
    for com, mat in [("Président de la commission musicale", "ADC-0013"), ("Président de la commission discipline", "ADC-0018"),
                     ("Président de la commission sociale", "ADC-0027")]:
        n += 1
        mandats.append(["MAN-%03d" % n, "Commission", com, mat, by_mat[mat]["nom"], D(2025, 2, 2), D(2027, 2, 1), 1,
                        "Désigné par le Bureau", "En cours", "", FICTIF])
    out["mandats"] = mandats
    out["scrutins"] = [["EL-2025-01", D(2025, 1, 19), "Ordinaire", "; ".join(FONCTIONS), 86, 71, "Proclamé", D(2025, 1, 19),
                        "Assemblée générale élective - " + FICTIF]]
    rivals = ["ADC-0031", "ADC-0035", "ADC-0040", "ADC-0046", "ADC-0053", "ADC-0058", "ADC-0066"]
    cands = []
    for k, m in enumerate(bureau):
        v = [52, 44, 61, 38, 49, 57, 40][k]
        cands.append(["EL-2025-01", FONCTIONS[k], m["mat"], m["nom"], v, "OUI", ""])
        r = by_mat[rivals[k]]
        cands.append(["EL-2025-01", FONCTIONS[k], r["mat"], r["nom"], 71 - v - [2, 1, 0, 3, 1, 2, 4][k], "NON", ""])
    out["candidats"] = cands

    # ------------------------------------------------------------ cantiques et programmes
    last, nb12 = {}, {}
    for d, _, items in PROGRAMMES:
        if d <= today:
            for _, i in items:
                last[i] = max(last.get(i, d), d)
                nb12[i] = nb12.get(i, 0) + 1
    cant = []
    for i, (titre, rec, num, langue, theme, auteur, ton, s, a, t, b) in enumerate(CANTIQUES):
        niv = [NIV[x] for x in (s, a, t, b)]
        glob = "Maîtrisé" if all(x == "Maîtrisé" for x in niv) else (
            "Non commencé" if all(x == "Non commencé" for x in niv) else "En apprentissage")
        cant.append(["CAN-%03d" % (i + 1), titre, rec, num, langue, theme, auteur, ton] + niv +
                    [glob, last.get(i), nb12.get(i, 0), FICTIF if i == 0 else ""])
    out["cantiques"] = cant
    progs = []
    for d, celeb, items in PROGRAMMES:
        for o, (moment, i) in enumerate(items, 1):
            c = CANTIQUES[i]
            progs.append([d, celeb, o, "CAN-%03d" % (i + 1), c[0], c[1], moment, ""])
    out["programmes"] = progs

    # ------------------------------------------------------------ études bibliques
    etudes = []
    themes = [("Étude biblique", "La louange dans les Psaumes", "Psaume 150"),
              ("Étude biblique", "Le service des Lévites chantres", "1 Chroniques 25"),
              ("Affermissement", "Le baptême et la vie nouvelle", "Romains 6.1-11"),
              ("Étude biblique", "La prière persévérante", "Luc 18.1-8"),
              ("Formation musicale", "Lecture du solfège et justesse", ""),
              ("Étude biblique", "Les fruits de l'Esprit", "Galates 5.22-26"),
              ("Étude biblique", "La discipline dans l'Église", "Matthieu 18.15-20"),
              ("Affermissement", "Accueil des nouveaux choristes", "Romains 12.1-8"),
              ("Étude biblique", "Le chant nouveau", "Apocalypse 5.9-14")]
    for k, (typ, theme, texte) in enumerate(themes):
        d = D(2026, 2 + k, 1)
        while d.weekday() != 4:   # vendredi
            d += dt.timedelta(days=1)
        if k == 7:
            d = D(2026, 11, 28)
        st = "Réalisée" if d <= today else "Prévue"
        etudes.append([d, typ, theme, texte, "Pasteur de la paroisse" if k % 3 == 0 else bureau[6]["nom"],
                       "Salle de répétition", "", st, FICTIF if k == 0 else ""])
    out["etudes"] = etudes
    out["dir_titulaire"] = by_mat["ADC-0013"]["nom"]
    return out
