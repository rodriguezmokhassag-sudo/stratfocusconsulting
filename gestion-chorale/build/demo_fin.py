"""Données financières fictives de la démonstration (lot 2), du 01/01/2026 au 10/10/2026."""
import datetime as dt
import random

OUVERTURE = {"SOLDE_OUVERTURE_ESPECES": 350000, "SOLDE_OUVERTURE_BANQUE": 1200000, "SOLDE_OUVERTURE_SOCIAL": 180000}
FIN = dt.date(2026, 10, 10)
COT = 300

BUDGET = {
    "R01.1": 342000, "R02.1": 900000, "R02.2": 400000, "R03.1": 250000, "R04.1": 200000, "R05.1": 100000,
    "R06.1": 30000, "R07.1": 150000, "R09.1": 50000, "S01.1": 300000, "S01.2": 50000,
    "D01.1": 200000, "D01.2": 250000, "D01.3": 60000, "D02.1": 150000, "D02.2": 100000, "D03.1": 250000,
    "D04.1": 300000, "D04.2": 150000, "D04.3": 80000, "D05.1": 120000, "D06.1": 50000, "D07.1": 150000,
    "D08.1": 60000, "D08.2": 40000, "D08.3": 120000, "D09.1": 30000, "D10.1": 50000,
    "T01.1": 200000, "T01.2": 150000, "T01.3": 50000, "T01.4": 50000,
}


def build(info, presences, rubriques, rnd=None):
    rnd = rnd or random.Random(2026)
    rub = {c: (s, r, sr, f) for c, s, r, sr, f in rubriques}
    E = []  # écritures avant numérotation

    def add(d, caisse, oper, code, lib, mat="", tiers="", ref="", montant=0, autor="", recu=False, key=None):
        E.append(dict(d=d, caisse=caisse, oper=oper, code=code, lib=lib, mat=mat, tiers=tiers, ref=ref,
                      montant=montant, autor=autor, recu=recu, statut="Validée", liee="", key=key))

    actifs = [m for m in info if m["statut"] in ("Choriste confirmé", "En observation", "Refroidi", "Suspendu")
              or m["statut"] == "Démissionnaire"]
    # --- Cotisations mensuelles
    for m in actifs:
        start = max(dt.date(2026, 1, 1), m["arrivee"].replace(day=1))
        end = FIN
        if m["statut"] == "Démissionnaire":
            end = dt.date(2026, 2, 28)
        if m["refroidi"]:
            end = dt.date(2026, 6, 30)
        profil = rnd.random()
        months = []
        d = start
        while d <= end:
            months.append(d)
            d = (d.replace(day=28) + dt.timedelta(days=5)).replace(day=1)
        if profil < 0.65:      # paie chaque mois
            for mo in months:
                pay = mo + dt.timedelta(days=rnd.randint(3, 20))
                if pay <= FIN:
                    add(pay, "Espèces", "Recette", "R01.1", "Cotisation", m["mat"], m["nom"], montant=COT, recu=True)
        elif profil < 0.88:    # paie par trimestre
            for i in range(0, len(months), 3):
                pay = months[min(i + 2, len(months) - 1)] + dt.timedelta(days=rnd.randint(5, 25))
                n = len(months[i:i + 3])
                if pay <= FIN:
                    add(pay, "Espèces", "Recette", "R01.1", "Cotisation (%d mois)" % n, m["mat"], m["nom"], montant=COT * n, recu=True)
        else:                  # irrégulier : arriérés
            k = rnd.randint(1, 4)
            pay = dt.date(2026, 3, rnd.randint(1, 28))
            add(pay, "Espèces", "Recette", "R01.1", "Cotisation (%d mois)" % k, m["mat"], m["nom"], montant=COT * k, recu=True)
    # --- Pénalités payées (une partie)
    pen = {}
    for p in presences:
        if p[7]:
            pen[p[3]] = pen.get(p[3], 0) + p[7]
    for m in info:
        due = pen.get(m["mat"], 0)
        if due and rnd.random() < 0.6:
            paid = (int(due * rnd.uniform(0.3, 1.0)) // 50) * 50
            if paid > 0:
                add(dt.date(2026, rnd.randint(4, 9), rnd.randint(1, 28)), "Espèces", "Recette", "R06.1",
                    "Pénalités de retard", m["mat"], m["nom"], montant=paid, recu=True)
    # --- Collectes et offrandes
    d = dt.date(2026, 1, 4)
    while d <= FIN:
        add(d, "Espèces", "Recette", "R02.1", "Collecte du culte", montant=rnd.randrange(15000, 35000, 50))
        d += dt.timedelta(days=7)
    for mo in range(1, 10):
        add(dt.date(2026, mo, 25), "Espèces", "Recette", "R02.2", "Offrandes du mois", montant=rnd.randrange(20000, 50000, 500))
    add(dt.date(2026, 2, 14), "Banque", "Recette", "R04.1", "Don pour les instruments", tiers="Famille BOUITY (ancien choriste)", montant=100000, recu=True)
    add(dt.date(2026, 7, 5), "Espèces", "Recette", "R04.1", "Don", tiers="Paroissien anonyme", montant=50000, recu=True)
    add(dt.date(2026, 6, 13), "Espèces", "Recette", "R05.1", "Loyer LOC-2026-001", tiers="Groupe Gloire Éternelle", ref="LOC-2026-001", montant=50000, recu=True, key="loyer")
    add(dt.date(2026, 6, 13), "Espèces", "Recette", "R10.1", "Caution LOC-2026-001", tiers="Groupe Gloire Éternelle", ref="LOC-2026-001", montant=60000, recu=True, key="caution")
    add(dt.date(2026, 6, 16), "Espèces", "Dépense", "D11.1", "Restitution caution LOC-2026-001", tiers="Groupe Gloire Éternelle", ref="LOC-2026-001", montant=60000, autor="Contrat LOC-2026-001", key="restit")
    add(dt.date(2026, 3, 21), "Espèces", "Recette", "R07.1", "Salu kia zola - vente de repas", montant=120000)
    # --- Dépenses
    for mo in range(1, 10):
        add(dt.date(2026, mo, 5), "Espèces", "Dépense", "D08.3", "Crédit téléphonique et internet", montant=10000, autor="PV 2026-01")
        add(dt.date(2026, mo, 28), "Banque", "Dépense", "D09.1", "Frais de tenue de compte", tiers="Banque", montant=2500)
    for mo in (1, 4, 7):
        add(dt.date(2026, mo, 10), "Espèces", "Dépense", "D08.1", "Fournitures (cahiers, stylos, craie)", tiers="Librairie", montant=25000, autor="PV 2026-01")
    add(dt.date(2026, 3, 12), "Banque", "Dépense", "D03.1", "Confection de 20 tenues noir-blanc", tiers="Atelier de couture", montant=300000, autor="PV 2026-02")
    add(dt.date(2026, 5, 16), "Espèces", "Dépense", "D02.1", "Transport sortie d'évangélisation Mpita", tiers="Transporteur", montant=80000, autor="PV 2026-04")
    add(dt.date(2026, 5, 16), "Espèces", "Dépense", "D07.1", "Repas sortie d'évangélisation", montant=60000, autor="PV 2026-04")
    add(dt.date(2026, 7, 18), "Espèces", "Dépense", "D05.1", "Réparation de l'enceinte amplifiée", tiers="Électronicien", ref="MUS-0004", montant=45000, autor="PV 2026-07", key="repar")
    add(dt.date(2026, 8, 7), "Espèces", "Dépense", "D01.2", "Retraite spirituelle (hébergement)", tiers="Centre d'accueil", montant=150000, autor="PV 2026-07")
    add(dt.date(2026, 9, 12), "Banque", "Dépense", "D04.2", "Achat d'un micro sans fil", tiers="Fournisseur local", montant=85000, autor="PV 2026-09", key="micro")
    add(dt.date(2026, 4, 9), "Espèces", "Dépense", "D08.2", "Impression des programmes de cantiques", tiers="Imprimerie", montant=18000, autor="PV 2026-04", key="err")
    # --- Virements espèces -> banque
    for i, d in enumerate([dt.date(2026, 3, 31), dt.date(2026, 6, 30), dt.date(2026, 9, 30)]):
        add(d, "Espèces", "Virement sortant", "VIR", "Versement à la banque", montant=[300000, 400000, 300000][i], key="vs%d" % i)
        add(d, "Banque", "Virement entrant", "VIR", "Versement à la banque", montant=[300000, 400000, 300000][i], key="ve%d" % i)
    # --- Caisse sociale : hospitalisation et mariage
    by_mat = {m["mat"]: m for m in info}
    social, campagnes = [], []
    cotisants = [m for m in info if m["statut"] in ("Choriste confirmé", "En observation", "Refroidi", "Suspendu")]
    events = [("SOC-2026-001", dt.date(2026, 6, 8), "Hospitalisation de plus d'une semaine", "Malheureux", "ADC-0030", 1500, 50000,
               "T01.1", "Caisse sociale", "", "CAMP-2026-01"),
              ("SOC-2026-002", dt.date(2026, 8, 22), "Mariage d'un membre", "Heureux", "ADC-0015", 5000, 200000,
               "T01.2", "Caisse sociale", "", "CAMP-2026-02")]
    for num, d, typ, nat, mat, contrib, aide, code_aide, aff, pres, camp in events:
        m = by_mat[mat]
        payeurs = [x for x in cotisants if rnd.random() < 0.75]
        col = 0
        for x in payeurs:
            pd = d + dt.timedelta(days=rnd.randint(1, 20))
            if pd <= FIN:
                add(pd, "Espèces", "Recette", "S01.1", "Contribution " + typ.lower(), x["mat"], x["nom"], ref=camp, montant=contrib, recu=True)
                col += contrib
        add(d + dt.timedelta(days=12), "Espèces", "Dépense", code_aide, ("Aide " if code_aide == "T01.1" else "Cadeau ") + typ.lower(),
            mat, m["nom"], ref=num, montant=aide, autor="PV %s" % d.strftime("%Y-%m"))
        social.append([num, d, typ, nat, mat, m["nom"], "", contrib, camp, col, aide, aide, 0, col - aide, aff, pres, "Clos"])
        campagnes.append([camp, "Social %s - %s - %s" % (num, typ, m["nom"]), contrib, d + dt.timedelta(days=30), "S01.1", num,
                          "Clôturée", len(cotisants), len(cotisants) * contrib, col, d])
    # Campagne tenues
    col = 0
    for x in cotisants:
        if rnd.random() < 0.45:
            add(dt.date(2026, rnd.randint(4, 6), rnd.randint(1, 28)), "Espèces", "Recette", "R03.1", "Tenues blanc-blanc 2026",
                x["mat"], x["nom"], ref="CAMP-2026-03", montant=5000, recu=True)
            col += 5000
    campagnes.append(["CAMP-2026-03", "Tenues blanc-blanc 2026", 5000, dt.date(2026, 6, 30), "R03.1", "", "Ouverte",
                      len(cotisants), len(cotisants) * 5000, col, dt.date(2026, 4, 1)])
    # --- Pertes et arrêtés
    add(dt.date(2026, 7, 31), "Espèces", "Dépense", "D10.2", "Manquant constaté à l'arrêté de caisse du 31/07/2026", montant=1500,
        autor="Arrêté de caisse", key="manq")
    add(dt.date(2026, 9, 5), "Espèces", "Recette", "R09.3", "Remboursement PER-2026-002", "ADC-0044", by_mat["ADC-0044"]["nom"],
        ref="PER-2026-002", montant=20000, recu=True)
    # Numérotation chronologique
    E.sort(key=lambda e: (e["d"], 0 if e["oper"] != "Virement entrant" else 1))
    rows, keys = [], {}
    np_, nr = 0, 0
    for e in E:
        np_ += 1
        piece = "P-2026-%04d" % np_
        recu = ""
        if e["recu"] and e["oper"] == "Recette":
            nr += 1
            recu = "REC-2026-%04d" % nr
        if e["key"]:
            keys[e["key"]] = piece
        if e["code"] == "VIR":
            r, sr, f = "Virement interne", "Virement entre caisses", "GENERAL"
        else:
            _, r, sr, f = rub[e["code"]]
        rec = e["montant"] if e["oper"] in ("Recette", "Virement entrant") else None
        dep = e["montant"] if rec is None else None
        rows.append([piece, e["d"], "2026", e["caisse"], e["oper"], e["code"], r, sr, f, e["lib"], e["mat"], e["tiers"],
                     e["ref"], rec, dep, e["autor"], recu, e["statut"], "", dt.datetime.combine(e["d"], dt.time(19, 30)),
                     "Secrétaire aux Finances"])
    idx = {r[0]: r for r in rows}
    for i in range(3):
        idx[keys["vs%d" % i]][18] = keys["ve%d" % i]
        idx[keys["ve%d" % i]][18] = keys["vs%d" % i]
    # Annulation d'une écriture erronée (saisie en double)
    err = idx[keys["err"]]
    np_ += 1
    cp = "P-2026-%04d" % np_
    err[17] = "Annulée"
    err[18] = cp
    rows.append([cp, err[1], "2026", err[3], err[4], err[5], err[6], err[7], err[8],
                 "Annulation de %s : facture saisie deux fois" % err[0], "", err[11], "", None, -err[14], "", "",
                 "Contre-passation", err[0], dt.datetime(2026, 4, 12, 10, 0), "Secrétaire aux Finances"])
    arretes = [[dt.datetime(2026, 7, 31, 18, 0), "Espèces", None, None, -1500, keys["manq"], "Billet de 500 et pièces manquants", "Secrétaire aux Finances"],
               [dt.datetime(2026, 9, 30, 12, 0), "Banque", None, None, 0, "", "Rapprochement bancaire", "Secrétaire aux Finances"]]
    pertes = [["PER-2026-001", dt.date(2026, 7, 31), "Manquant de caisse", "", "", "Arrêté de caisse du 31/07/2026 (%s)" % keys["manq"],
               1500, 0, 1500, "", "En cours"],
              ["PER-2026-002", dt.date(2026, 8, 20), "Matériel perdu ou détérioré", "ADC-0044", by_mat["ADC-0044"]["nom"],
               "Micro sans fil perdu lors d'une sortie", 65000, 20000, 45000, "20 000 FCFA par mois de septembre à novembre", "En cours"]]
    # Soldes théoriques des arrêtés
    def solde(caisse, jusqu):
        s = OUVERTURE["SOLDE_OUVERTURE_ESPECES" if caisse == "Espèces" else "SOLDE_OUVERTURE_BANQUE"]
        for r in rows:
            if r[3] == caisse and r[1] <= jusqu:
                s += (r[13] or 0) - (r[14] or 0)
        return s
    th = solde("Espèces", dt.date(2026, 7, 31)) + 1500  # avant l'écriture du manquant
    arretes[0][2], arretes[0][3] = th, th - 1500
    bq = solde("Banque", dt.date(2026, 9, 30))
    arretes[1][2], arretes[1][3] = bq, bq
    budget = []
    for c, s, r, sr, f in rubriques:
        tot = BUDGET.get(c, 0)
        part = tot // 12
        budget.append(["2026", c, s, r, sr, f, tot or None, None, tot or None] +
                      ([part] * 11 + [tot - 11 * part] if tot else [None] * 12) + [0 if tot else None, "AG du 18/01/2026"])
    return {"pieces": keys, "caisse": rows, "budget": budget, "campagnes": campagnes, "social": social, "arretes": arretes,
            "pertes": pertes, "clotures": [], "params": dict(OUVERTURE)}
