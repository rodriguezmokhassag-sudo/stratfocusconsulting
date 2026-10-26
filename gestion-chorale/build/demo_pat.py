"""Patrimoine fictif de la démonstration (lot 3)."""
import datetime as dt

D = dt.date
# (catégorie, désignation, marque, série, qté, unité, date, mode, origine, valeur unitaire, remplacement, louable, tarif/jour, état, localisation)
BIENS = [
    ("MUS", "Clavier arrangeur", "Yamaha PSR-SX700", "YM70011", 1, "unité", D(2021, 3, 12), "Achat", "Fournisseur local", 450000, 520000, "OUI", 15000, "Bon", "Temple - estrade"),
    ("MUS", "Table de mixage 12 voies", "Behringer XENYX 1202", "BX12-8842", 1, "unité", D(2020, 11, 5), "Achat", "Fournisseur local", 320000, 350000, "OUI", 10000, "Bon", "Magasin de la chorale"),
    ("MUS", "Micro sans fil", "Shure BLX24", "", 4, "pièce", D(2022, 6, 20), "Don", "Famille MAKOSSO", 65000, 75000, "OUI", 3000, "Usé", "Magasin de la chorale"),
    ("MUS", "Enceinte amplifiée", "JBL EON 712", "", 2, "pièce", D(2019, 8, 1), "Achat", "Fournisseur local", 280000, 330000, "OUI", 10000, "Bon", "Magasin de la chorale"),
    ("MUS", "Guitare basse", "Ibanez GSR200", "IB2018", 1, "unité", D(2018, 2, 14), "Don", "Paroisse", 150000, 180000, "NON", 0, "Bon", "Magasin de la chorale"),
    ("MUS", "Batterie acoustique", "Pearl Roadshow", "", 1, "unité", D(2017, 9, 9), "Achat", "Fournisseur local", 600000, 650000, "NON", 0, "Usé", "Temple - estrade"),
    ("MUS", "Pupitre de partitions", "", "", 6, "pièce", D(2023, 2, 1), "Achat", "Marché central", 12000, 15000, "NON", 0, "Bon", "Temple - estrade"),
    ("MUS", "Câbles XLR 10 m", "", "", 10, "pièce", D(2024, 5, 10), "Achat", "Fournisseur local", 8000, 9000, "OUI", 500, "Bon", "Magasin de la chorale"),
    ("MUS", "Micro sans fil", "Shure BLX24", "SH-26-901", 1, "pièce", D(2026, 9, 12), "Achat", "Fournisseur local", 85000, 85000, "OUI", 3000, "Neuf", "Magasin de la chorale"),
    ("MOB", "Chaise plastique", "", "", 40, "pièce", D(2023, 1, 15), "Achat", "Marché central", 3000, 3500, "OUI", 100, "Bon", "Magasin de la chorale"),
    ("MOB", "Table pliante", "", "", 5, "pièce", D(2023, 1, 15), "Achat", "Marché central", 25000, 30000, "OUI", 1000, "Bon", "Magasin de la chorale"),
    ("MOB", "Bâche 6 x 4 m", "", "", 2, "pièce", D(2024, 4, 2), "Achat", "Marché central", 45000, 50000, "OUI", 5000, "Bon", "Magasin de la chorale"),
    ("MOB", "Armoire métallique", "", "", 1, "unité", D(2016, 6, 1), "Don", "Paroisse", 90000, 120000, "NON", 0, "Usé", "Salle de répétition"),
    ("ADM", "Registre des membres", "", "", 1, "unité", D(2025, 1, 10), "Achat", "Librairie", 5000, 5000, "NON", 0, "Bon", "Secrétariat"),
    ("ADM", "Cachet de la chorale", "", "", 1, "unité", D(2016, 3, 1), "Achat", "Graveur", 15000, 15000, "NON", 0, "Bon", "Secrétariat"),
    ("ADM", "Classeurs d'archives", "", "", 8, "pièce", D(2024, 1, 20), "Achat", "Librairie", 2500, 3000, "NON", 0, "Bon", "Secrétariat"),
    ("INF", "Ordinateur portable", "HP 250 G8", "5CD123ABC", 1, "unité", D(2024, 9, 1), "Don", "Ancien choriste", 350000, 400000, "NON", 0, "Bon", "Domicile du Secrétaire Général"),
    ("INF", "Vidéoprojecteur", "Epson EB-X06", "EP-77812", 1, "unité", D(2023, 11, 20), "Achat", "Fournisseur local", 280000, 300000, "OUI", 15000, "À réparer", "Magasin de la chorale"),
    ("CUI", "Marmite 50 L", "", "", 2, "pièce", D(2022, 12, 1), "Achat", "Marché central", 35000, 40000, "OUI", 2000, "Bon", "Magasin de la chorale"),
    ("CUI", "Gobelet", "", "", 60, "pièce", D(2023, 1, 15), "Achat", "Marché central", 500, 500, "NON", 0, "Bon", "Magasin de la chorale"),
    ("TEX", "Nappe blanche", "", "", 10, "pièce", D(2024, 3, 15), "Achat", "Atelier de couture", 6000, 7000, "NON", 0, "Bon", "Magasin de la chorale"),
    ("TEX", "Tenue noir-blanc (stock)", "", "", 6, "pièce", D(2026, 3, 12), "Achat", "Atelier de couture", 15000, 15000, "NON", 0, "Neuf", "Magasin de la chorale"),
]
CAT = {"MUS": "Matériel de musique", "MOB": "Mobilier", "ADM": "Administration", "INF": "Informatique",
       "CUI": "Cuisine et kit de sortie", "TEX": "Tenues et textiles", "IMM": "Immobilier"}
DUREE = {"MUS": 5, "MOB": 5, "ADM": 3, "INF": 3, "CUI": 3, "TEX": 3, "IMM": 20}
ASOF = D(2026, 10, 13)


def build(pieces, kit_owner):
    rows, compteur, by = [], {}, {}
    for cat, des, marque, serie, q, u, da, mode, orig, vu, vr, louable, tarif, etat, loc in BIENS:
        compteur[cat] = compteur.get(cat, 0) + 1
        code = "%s-%04d" % (cat, compteur[cat])
        tot = q * vu
        cumul = min(tot, round(tot * ((ASOF - da).days / 365.25) / DUREE[cat]))
        piece = pieces.get("micro", "") if des == "Micro sans fil" and da.year == 2026 else ""
        rows.append([code, des, CAT[cat], marque, serie, q, u, da, mode, orig, piece, vu, tot, DUREE[cat], cumul,
                     tot - cumul, vr * q, louable, tarif or None, etat, loc, "Secrétaire aux Patrimoines",
                     0, q, D(2026, 6, 30), "DONNÉES FICTIVES"])
        by[(des, da.year)] = rows[-1]
    # Kit du choriste confirmé en juin (dossier ADH-2026-001)
    for item, val in [("Chaise plastique", 3000), ("Gobelet", 500), ("Fourchette", 250), ("Cuillère", 250)]:
        compteur["CUI"] += 1
        rows.append(["CUI-%04d" % compteur["CUI"], item, CAT["CUI"], "", "", 1, "pièce", D(2026, 6, 14), "Kit nouveau choriste",
                     kit_owner, "", val, val, 3, round(val * (ASOF - D(2026, 6, 14)).days / 365.25 / 3), None, None, "NON", None,
                     "Bon", "Magasin de la chorale", "", 0, 1, None, "Dossier ADH-2026-001"])
        rows[-1][15] = rows[-1][12] - rows[-1][14]
    code = {r[1] + str(r[7].year): r[0] for r in rows}
    micro = code["Micro sans fil2022"]
    enceinte = code["Enceinte amplifiée2019"]
    table = code["Table de mixage 12 voies2020"]
    chaise = code["Chaise plastique2023"]
    projo = code["Vidéoprojecteur2023"]
    mouvements = [
        ["MVT-2026-001", D(2026, 6, 10), "Location", table, "Table de mixage 12 voies", 1, "Groupe Gloire Éternelle", "LOC-2026-001",
         D(2026, 6, 15), D(2026, 6, 16), "Bon", "Bon", 20000, pieces.get("loyer", ""), "Clos", "", None, "Secrétaire aux Patrimoines"],
        ["MVT-2026-002", D(2026, 6, 10), "Location", enceinte, "Enceinte amplifiée", 2, "Groupe Gloire Éternelle", "LOC-2026-001",
         D(2026, 6, 15), D(2026, 6, 16), "Bon", "Bon", 30000, pieces.get("loyer", ""), "Clos", "", None, "Secrétaire aux Patrimoines"],
        ["MVT-2026-003", D(2026, 7, 10), "Réparation", enceinte, "Enceinte amplifiée", 1, "Électronicien", "",
         D(2026, 7, 18), D(2026, 7, 18), "À réparer", "Bon", 45000, pieces.get("repar", ""), "Clos", "Haut-parleur remplacé", None, "Secrétaire aux Patrimoines"],
        ["MVT-2026-004", D(2026, 8, 20), "Perte ou vol", micro, "Micro sans fil", 1, "ADC-0044", "",
         None, None, "Usé", "", 65000, "", "Clos", "Perdu lors d'une sortie - PER-2026-002", None, "Secrétaire aux Patrimoines"],
        ["MVT-2026-005", D(2026, 9, 26), "Prêt", chaise, "Chaise plastique", 15, "Commission cuisine", "",
         D(2026, 10, 4), None, "Bon", "", None, "", "En cours", "Repas de la fête des récoltes", None, "Secrétaire aux Patrimoines"],
        ["MVT-2026-006", D(2026, 10, 3), "Prêt", micro, "Micro sans fil", 1, "ADC-0012", "",
         D(2026, 10, 20), None, "Usé", "", None, "", "En cours", "Répétition à domicile du pupitre ténor", None, "Secrétaire aux Patrimoines"],
        ["MVT-2026-007", D(2026, 10, 1), "Réparation", projo, "Vidéoprojecteur", 1, "Électronicien", "",
         D(2026, 10, 30), None, "À réparer", "", None, "", "En cours", "Lampe à changer (devis attendu)", None, "Secrétaire aux Patrimoines"],
    ]
    for m in mouvements:
        m[16] = dt.datetime.combine(m[1], dt.time(18, 0))
    # Quantités sorties et perte du micro (4 -> 3)
    for r in rows:
        if r[0] == micro:
            r[5] = 3
            r[12] = 3 * r[11]
            r[14] = min(r[12], round(r[12] * ((ASOF - r[7]).days / 365.25) / 5))
            r[15] = r[12] - r[14]
            r[16] = 3 * 75000
        out = sum(m[5] for m in mouvements if m[3] == r[0] and m[14] == "En cours")
        r[22] = out
        r[23] = r[5] - out
    locations = [
        ["LOC-2026-001", D(2026, 6, 5), "Groupe Gloire Éternelle", "06 555 12 34", "Concert de louange du 14/06",
         D(2026, 6, 13), D(2026, 6, 15), 3, 50000, 60000, "Favorable (08/06/2026)", "PV 2026-06",
         "Clôturée", pieces.get("loyer", ""), pieces.get("caution", ""), pieces.get("restit", ""), 0, "Matériel rendu en bon état"],
        ["LOC-2026-002", D(2026, 10, 20), "Chorale Saint-Esprit (paroisse voisine)", "05 444 98 76", "Mariage du 07/11",
         D(2026, 11, 6), D(2026, 11, 8), 3, 36000, 105000, "", "", "Demande", "", "", "", None, "Enceintes et table de mixage"],
    ]
    inventaires = [[dt.datetime(2026, 6, 30, 17, 0), "Inventaire de juin 2026", len(rows) - 4, 1, 0, "Aucun écart de valeur", "Secrétaire aux Patrimoines"]]
    return {"patrimoine": rows, "mouvements": mouvements, "locations": locations, "inventaires": inventaires}
