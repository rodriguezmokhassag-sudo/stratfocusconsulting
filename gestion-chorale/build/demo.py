"""Donnees du modele vierge et de la version de demonstration (fictives)."""
import datetime as dt
import random

TODAY = dt.date(2026, 10, 13)

NOMS = ["MAKOSSO", "MBEMBA", "NGOMA", "LOEMBA", "TCHICAYA", "MALONGA", "MOUKALA", "BOUITY", "NZOUSSI",
        "MAVOUNGOU", "KOUBEMBA", "PAMBOU", "MASSAMBA", "NKOUKA", "BATCHI", "GOMA", "MIAKASSISSA", "LOUBAKI",
        "NDINGA", "TATY", "MOUANDA", "BAKALA", "KIMBEMBE", "SITA", "MBOUNGOU", "PEMBA", "MOUNDZA", "NKODIA",
        "BIKINDOU", "MABIALA", "SAMBA", "KOUMBA", "NSONDE", "VOUMBO", "POATY", "MAKAYA"]
PRENOMS_F = ["Marie", "Prisca", "Bénédicte", "Merveille", "Divine", "Esther", "Ruth", "Grâce", "Josiane",
             "Chancelvie", "Nadège", "Sarah", "Rebecca", "Clarisse", "Fabiola", "Laetitia", "Gloire", "Deborah"]
PRENOMS_M = ["Jean-Pierre", "Christian", "Fortuné", "Exaucé", "Dieudonné", "Aimé", "Bienvenu", "Rodrigue",
             "Gildas", "Prince", "Destin", "Jonathan", "Samuel", "Daniel", "Josué", "Arnaud", "Hervé", "Gloire"]
QUARTIERS = ["Tchimbambouka", "Mvoumvou", "Loandjili", "Tié-Tié", "Mpita", "Ngoyo", "Mongo-Mpoukou", "Siafoumou"]
PUPITRES = ["Soprano", "Alto", "Ténor", "Basse"]
COMMISSIONS = ["Organisation", "Intercession", "Musicale", "Discipline", "Recettes", "Matériels",
               "Culturelle", "Sociale", "Cuisine", "Réflexion"]
BUREAU = ["1er Responsable", "Vice-Responsable", "Secrétaire Général", "Secrétaire Général Adjoint",
          "Secrétaire aux Finances", "Secrétaire aux Patrimoines", "Secrétaire chargé à l'Évangélisation et Mission"]
ROLE_BY_FONCTION = {"1er Responsable": "RESP1", "Vice-Responsable": "VICE", "Secrétaire Général": "SG",
                    "Secrétaire Général Adjoint": "SGA", "Secrétaire aux Finances": "FIN",
                    "Secrétaire aux Patrimoines": "PAT", "Secrétaire chargé à l'Évangélisation et Mission": "EVA"}

CHECK_SLOTS = 15


def empty_data():
    return {"demo": False, "membres": [], "adhesions": [], "seances": [], "presences": [], "patrimoine": [],
            "journal": [], "titulaires": {}}


def _date(y, m, d):
    return dt.date(y, m, d)


def _rand_date(a, b):
    return a + dt.timedelta(days=random.randint(0, (b - a).days))


def demo_data(listes, controles, lot2=None):
    random.seed(1988)
    membres = []
    info = []  # dict par membre pour la simulation des presences
    used = set()

    def nom_unique(sexe):
        while True:
            n = random.choice(NOMS)
            p = random.choice(PRENOMS_F if sexe == "F" else PRENOMS_M)
            if (n, p) not in used:
                used.add((n, p))
                return n, p

    plan = (["CONF"] * 92) + ["OBS_A", "OBS_B", "OBS_C", "OBS_D", "SUSP", "SUSP", "DEM", "DEM"]
    refroidis = {10, 37, 64}
    recently_confirmed = 20
    for i, kind in enumerate(plan):
        sexe = "F" if random.random() < 0.58 else "M"
        nom, prenom = nom_unique(sexe)
        mat = "ADC-%04d" % (i + 1)
        if sexe == "F":
            pup = random.choice(["Soprano", "Soprano", "Alto"])
        else:
            pup = random.choice(["Ténor", "Basse", "Basse"])
        if i in (5, 41):
            pup = "Instrumentiste"
        naiss = _rand_date(_date(1960, 1, 1), _date(2006, 12, 31))
        arrivee = _rand_date(_date(1995, 1, 1), _date(2025, 9, 30))
        bapteme = arrivee - dt.timedelta(days=random.randint(200, 4000))
        reception = arrivee + dt.timedelta(days=random.randint(95, 130))
        statut, dstat, fonction = "Choriste confirmé", reception, ""
        if i < 7:
            fonction = BUREAU[i]
        if i == recently_confirmed:
            arrivee = _date(2026, 3, 2)
            reception = _date(2026, 6, 14)
            dstat = reception
        if kind.startswith("OBS"):
            arrivee = {"OBS_A": _date(2026, 6, 10), "OBS_B": _date(2026, 7, 4), "OBS_C": _date(2026, 8, 22),
                       "OBS_D": _date(2026, 9, 12)}[kind]
            reception, statut, dstat = None, "En observation", arrivee
            if kind == "OBS_D":
                bapteme = None
        elif kind == "SUSP":
            statut, dstat = "Suspendu", _date(2026, 9, 1)
        elif kind == "DEM":
            statut, dstat = "Démissionnaire", _date(2026, 3, 1)
        sit = random.choice(["Célibataire", "Célibataire", "Marié(e)", "Marié(e)", "Fiancé(e)", "Veuf(ve)"])
        enfants = random.choice([0, 0, 1, 2, 3, 4]) if sit != "Célibataire" else random.choice([0, 0, 0, 1])
        tel = "06 %03d %02d %02d" % (random.randint(100, 999), random.randint(0, 99), random.randint(0, 99))
        row = [mat, nom, prenom, sexe, naiss, "Pointe-Noire", tel, tel, random.choice(QUARTIERS),
               random.choice(NOMS) + " " + random.choice(PRENOMS_F + PRENOMS_M),
               "05 %03d %02d %02d" % (random.randint(100, 999), random.randint(0, 99), random.randint(0, 99)),
               "Tchimbambouka" if random.random() < 0.7 else "Mvoumvou", bapteme, "", arrivee, reception, pup,
               "Clavier" if pup == "Instrumentiste" else "", random.choice(COMMISSIONS), fonction, sit,
               "", enfants, statut, dstat, "DONNÉES FICTIVES"]
        membres.append(row)
        info.append({"mat": mat, "nom": "%s %s" % (nom, prenom), "kind": kind, "arrivee": arrivee,
                     "statut": statut, "dstat": dstat, "p": random.uniform(0.55, 0.97),
                     "refroidi": i in refroidis})

    # ------------------------------------------------------------ seances
    seances = []
    sessions = []
    d = _date(2026, 1, 1)
    annulees = {(_date(2026, 4, 4), "REP"), (_date(2026, 8, 15), "REP")}
    extra = {_date(2026, 5, 16): ("EVANG", "Sortie d'évangélisation", "Quartier Mpita"),
             _date(2026, 8, 7): ("VEIL", "Veillée de prière", "Temple")}
    while d <= _date(2026, 12, 31):
        wd = d.weekday()
        todo = []
        if wd in (2, 5):
            todo.append(("REP", "Répétition", dt.time(18, 0), dt.time(20, 30), "Temple"))
        if wd == 6:
            todo.append(("CULTE", "Culte", None, None, "Temple"))
        if d in extra:
            c, l, lieu = extra[d]
            todo.append((c, l, dt.time(9, 0), dt.time(17, 0), lieu))
        for code, lib, h1, h2, lieu in todo:
            sid = "S%s-%s" % (d.strftime("%Y%m%d"), code)
            jour = ["Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi", "Samedi", "Dimanche"][wd]
            if (d, code) in annulees:
                st, pointee = "Annulée", "NON"
            elif d <= _date(2026, 10, 7):
                st, pointee = "Tenue", "OUI"
            else:
                st, pointee = "Prévue", "NON"
            seances.append([sid, d, jour, code, lib, h1, h2, lieu, "", st, pointee, None, None])
            if pointee == "OUI":
                sessions.append((len(seances) - 1, sid, d, code))
        d += dt.timedelta(days=1)

    # ------------------------------------------------------------ presences
    presences = []
    motifs = ["Maladie", "Voyage", "Travail", "Deuil familial", "Examen scolaire"]
    poids = {"P": 1, "R": 1, "RX": 0, "DA": 0.5, "ANJ": 0}
    for idx, sid, d, code in sessions:
        n_att = 0
        pond = 0.0
        n_pres = 0
        for m in info:
            if m["arrivee"] > d:
                continue
            if m["statut"] in ("Démissionnaire",) and d >= m["dstat"]:
                continue
            if m["statut"] == "Suspendu" and d >= m["dstat"]:
                c, motif = "NC", ""
            elif m["refroidi"] and d > _date(2026, 7, 20):
                c, motif = "ANJ", ""
            else:
                u = random.random()
                if u < m["p"]:
                    v = random.random()
                    c = "P" if v < 0.88 else ("R" if v < 0.96 else ("DA" if v < 0.99 else "RX"))
                    motif = ""
                elif random.random() < 0.4:
                    c, motif = "AJ", random.choice(motifs)
                else:
                    c, motif = "ANJ", ""
            pen = 50 if c in ("R", "RX") else None
            presences.append([sid, d, code, m["mat"], m["nom"],
                              c, motif, pen, dt.datetime.combine(d, dt.time(21, 15)), "Secrétaire Général"])
            if c in poids:
                n_att += 1
                pond += poids[c]
            if c in ("P", "R", "DA"):
                n_pres += 1
        seances[idx][11] = n_pres
        seances[idx][12] = pond / n_att if n_att else None

    # ------------------------------------------------------------ adhesions
    def checks(missing=()):
        out = []
        for i in range(CHECK_SLOTS):
            if i < len(controles):
                lbl, applic = controles[i][0], controles[i][6]
                if applic == "TRANSFERT":
                    out.append("N/A")
                else:
                    out.append("NON" if lbl in missing else "OUI")
            else:
                out.append("")
        return out

    by_kind = {m["kind"]: m for m in info}
    rc = info[recently_confirmed]
    adhesions = []
    adhesions.append(["ADH-2026-001", rc["mat"], rc["nom"], "Baptisé - nouveau membre", rc["arrivee"],
                      _date(2026, 6, 2), 26, 0.85] + checks() +
                     ["", "À CONFIRMER par le Bureau", "Confirmer", "", None, _date(2026, 6, 14), "1er Responsable",
                      "OUI", "Clos - confirmé le 14/06/2026"])
    specs = [("OBS_A", "ADH-2026-002", "Baptisé - nouveau membre", ()),
             ("OBS_B", "ADH-2026-003", "Baptisé - nouveau membre", ("Chaise plastique", "Tenue blanc-blanc")),
             ("OBS_C", "ADH-2026-004", "Transfert d'une autre chorale EEC", ("Gobelet",)),
             ("OBS_D", "ADH-2026-005", "Catéchumène (après baptême)", ("Bible", "Cahier de chant"))]
    for kind, num, cat, miss in specs:
        m = by_kind[kind]
        ch = checks(miss)
        if cat.startswith("Transfert"):
            ch[2] = "OUI"
        adhesions.append([num, m["mat"], m["nom"], cat, m["arrivee"], None, None, None] + ch +
                         ["", "", "", "", None, None, "", "", "En cours"])

    # ------------------------------------------------------------ patrimoine
    pat = [
        ("Clavier arrangeur", "Matériel de musique", 1, "unité", _date(2021, 3, 12), "Achat", "Fournisseur local", 450000, "Bon"),
        ("Table de mixage 12 voies", "Matériel de musique", 1, "unité", _date(2020, 11, 5), "Achat", "Fournisseur local", 320000, "Bon"),
        ("Micro sans fil", "Matériel de musique", 4, "pièce", _date(2022, 6, 20), "Don", "Famille MAKOSSO", 65000, "Usé"),
        ("Enceinte amplifiée", "Matériel de musique", 2, "pièce", _date(2019, 8, 1), "Achat", "Fournisseur local", 280000, "À réparer"),
        ("Guitare basse", "Matériel de musique", 1, "unité", _date(2018, 2, 14), "Don", "Paroisse", 150000, "Bon"),
        ("Batterie acoustique", "Matériel de musique", 1, "unité", _date(2017, 9, 9), "Achat", "Fournisseur local", 600000, "Usé"),
        ("Chaise plastique", "Mobilier", 40, "pièce", _date(2023, 1, 15), "Achat", "Marché central", 3000, "Bon"),
        ("Bâche 6 x 4 m", "Mobilier", 2, "pièce", _date(2024, 4, 2), "Achat", "Marché central", 45000, "Bon"),
        ("Registre des membres", "Administration", 1, "unité", _date(2025, 1, 10), "Achat", "Librairie", 5000, "Bon"),
        ("Ordinateur portable", "Informatique", 1, "unité", _date(2024, 9, 1), "Don", "Ancien choriste", 350000, "Bon"),
        ("Marmite 50 L", "Cuisine et kit de sortie", 2, "pièce", _date(2022, 12, 1), "Achat", "Marché central", 35000, "Bon"),
    ]
    patrimoine = []
    for k, (des, cat, q, u, da, mode, orig, vu, etat) in enumerate(pat):
        patrimoine.append(["PAT-%04d" % (k + 1), des, cat, q, u, da, mode, orig, vu, q * vu, etat,
                           "Magasin de la chorale", "Secrétaire aux Patrimoines", "DONNÉES FICTIVES"])
    for item, val in [("Chaise plastique", 3000), ("Gobelet", 500), ("Fourchette", 250), ("Cuillère", 250)]:
        patrimoine.append(["PAT-%04d" % (len(patrimoine) + 1), item, "Cuisine et kit de sortie", 1, "pièce",
                           _date(2026, 6, 14), "Kit nouveau choriste", "%s (%s)" % (rc["nom"], rc["mat"]),
                           val, val, "Bon", "Magasin de la chorale", "", "Dossier ADH-2026-001"])

    titulaires = {"ADMIN": "Administrateur (démo)"}
    for k, m in enumerate(info[:7]):
        titulaires[ROLE_BY_FONCTION[BUREAU[k]]] = m["nom"]
    titulaires["CONS"] = "Conseiller paroissial (démo)"

    journal = [[dt.datetime(2026, 1, 2, 10, 0), "Administrateur", "", "ACCUEIL", "Mise en service", "Version de démonstration"]]
    fin = {}
    if lot2 is not None:
        import demo_fin
        fin = demo_fin.build(info, presences, lot2.RUBRIQUES)
    return {**fin, "demo": True, "membres": membres, "adhesions": adhesions, "seances": seances, "presences": presences,
            "patrimoine": patrimoine, "journal": journal, "titulaires": titulaires}
