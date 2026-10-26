"""Construit GestionChorale.xlsm (modele vierge) et GestionChorale_DEMO.xlsm.

Usage : python3 build/build.py
Les modules VBA sont lus dans src/vba (*.bas) et src/doc (*.cls), encodes en
cp1252 puis integres dans un vbaProject.bin genere (voir vbaproject.py).
"""
import datetime as dt
import hashlib
import os
import random
import sys

import xlsxwriter

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, HERE)
from vbaproject import build_vba_project, doc_module_source, std_module_source  # noqa: E402
import demo  # noqa: E402

HDR = 4          # ligne d'en-tete (1-based)
FIRST = 5
OUT_HDR = 8
MAXROWS = 5000
VAL_ROWS = 3000  # lignes couvertes par les listes de choix

PRINCIPALE = "#1E7B4A"
SECONDAIRE = "#E8F3EC"
ACCENT = "#C8102E"
SYS_PWD = "Ch0rale#Sys2026"
MDP_INITIAL = "chorale"

ROLES = [
    ("ADMIN", "Administrateur"),
    ("RESP1", "1er Responsable"),
    ("VICE", "Vice-Responsable"),
    ("SG", "Secrétaire Général"),
    ("SGA", "Secrétaire Général Adjoint"),
    ("FIN", "Secrétaire aux Finances"),
    ("PAT", "Secrétaire aux Patrimoines"),
    ("EVA", "Secrétaire à l'Évangélisation"),
    ("CONS", "Consultation (conseiller paroissial)"),
]

# Matrice des droits validee (cahier des charges, section 3)
DROITS = [
    ("PARAM", "Paramètres et personnalisation", "M L - - - - - - -"),
    ("USERS", "Utilisateurs et mots de passe", "M - - - - - - - -"),
    ("MEMBRES", "Membres et nouveaux choristes", "M L L M M L - L L"),
    ("PRESENCES", "Présences et taux", "M L L M M - - L L"),
    ("FINANCES", "Finances, budget, caisses (lot 2)", "M L L - - M L - -"),
    ("COTISATIONS", "Cotisations et pénalités (lot 2)", "M L L L L M L - -"),
    ("SOCIAL", "Caisse sociale (lot 2)", "M L M L L M L - -"),
    ("PATRIMOINE", "Patrimoine, prêts et locations", "M L L - - L M - L"),
    ("DISCIPLINE", "Discipline et sanctions (lot 4)", "M M M L L - - L -"),
    ("PLANNING", "Planning des activités (lot 4)", "M M M M M L L M L"),
    ("MANDATS", "Mandats, élections, liste électorale", "M M L M L - - - L"),
    ("CANTIQUES", "Cantiques et vie spirituelle (lot 4)", "M L L L L - - M L"),
    ("RAPPORTS", "Tableaux de bord et rapports (lot 5)", "M L L L L L L L L"),
    ("JOURNAL", "Journal des actions", "L - - - - - - - -"),
]

PARAMS = [
    ("#", "Identité du groupe"),
    ("NOM_GROUPE", "Chorale Amour du Cœur", "Nom affiché sur l'accueil et les rapports"),
    ("SIGLE", "ADC", "Préfixe des matricules (ex. ADC-0001)"),
    ("EGLISE", "Église Évangélique du Congo", ""),
    ("CONSISTOIRE", "Consistoire de Pointe-Noire II", ""),
    ("PAROISSE", "Paroisse de Tchimbambouka", ""),
    ("DEVISE", "Unis, pour annoncer la Bonne Nouvelle de Jésus-Christ", ""),
    ("ADRESSE", "Siège : Paroisse de Tchimbambouka", ""),
    ("VILLE", "Pointe-Noire", "Ville (contrats, rapports)"),
    ("DATE_CREATION", dt.date(1988, 4, 13), "Date de création du groupe"),
    ("#", "Exercice"),
    ("MOIS_DEBUT_EXERCICE", 1, "Mois de début de l'exercice (1 = janvier)"),
    ("MONNAIE", "FCFA", ""),
    ("COTISATION_MENSUELLE", 300, "Cotisation statutaire mensuelle (art. 39) - utilisée au lot 2"),
    ("#", "Présences"),
    ("MOIS_REFROIDI", 2, "Absence sans justification (en mois) avant l'alerte « refroidi » (art. 52 : 1 mois)"),
    ("SEUIL_VERT", 0.8, "Taux à partir duquel un membre est « assidu » (vert)"),
    ("SEUIL_ORANGE", 0.5, "Taux à partir duquel un membre est « moyen » (orange) ; en dessous : rouge"),
    ("MOIS_ELECTEUR", 3, "Présence régulière minimale (mois) pour être électeur (art. 21)"),
    ("SEUIL_ELECTEUR", 0.6, "Taux minimal sur cette période pour être électeur"),
    ("#", "Nouveaux choristes"),
    ("DUREE_OBSERVATION_MOIS", 3, "Durée de la période d'observation (art. 26)"),
    ("SEUIL_ASSIDUITE_ADHESION", 0.6, "Taux minimal pendant l'observation pour proposer la confirmation"),
    ("JOURS_ALERTE_OBSERVATION", 15, "Alerte quand une observation se termine dans ce nombre de jours"),
    ("#", "Sécurité et sauvegardes"),
    ("MASQUER_MDP", "OUI", "Masquer la saisie des mots de passe (mettre NON en cas de problème d'affichage)"),
    ("LONGUEUR_MIN_MDP", 6, "Longueur minimale d'un mot de passe"),
    ("RAPPEL_SAUVEGARDE_JOURS", 7, "Rappel de sauvegarde à la fermeture après ce nombre de jours (0 = jamais)"),
    ("DOSSIER_SAUVEGARDE", "", "Dossier des copies (vide = sous-dossier « Sauvegardes » à côté du fichier)"),
    ("DERNIERE_SAUVEGARDE", "", "Mis à jour automatiquement"),
    ("#", "Apparence (bouton « Thème et couleurs »)"),
    ("THEME", "Vert", ""),
    ("COULEUR_PRINCIPALE", PRINCIPALE, "Bandeaux, en-têtes, boutons"),
    ("COULEUR_SECONDAIRE", SECONDAIRE, "Fonds clairs"),
    ("COULEUR_ACCENT", ACCENT, "Actions importantes et alertes"),
    ("#", "Système (ne pas modifier)"),
    ("UI_VERSION", "", "Version de l'interface construite"),
    ("PREMIERE_OUVERTURE", "OUI", "Affiche le message d'accueil à la première ouverture"),
]

LISTES = {
    "Pupitre": ["Soprano", "Alto", "Ténor", "Basse", "Instrumentiste", "Direction (maître de chant)"],
    "Commission": ["Organisation", "Intercession", "Musicale", "Discipline", "Recettes", "Matériels",
                   "Culturelle", "Sociale", "Cuisine", "Réflexion"],
    "Fonction au Bureau": ["1er Responsable", "Vice-Responsable", "Secrétaire Général", "Secrétaire Général Adjoint",
                           "Secrétaire aux Finances", "Secrétaire aux Patrimoines",
                           "Secrétaire chargé à l'Évangélisation et Mission"],
    "Statut": ["En observation", "Choriste confirmé", "Refroidi", "Suspendu", "Exclu temporaire",
               "Démissionnaire", "Exclu définitif", "Transféré", "Décédé", "Non retenu"],
    "Pointage": ["OUI", "OUI", "OUI", "OUI", "OUI", "NON", "NON", "NON", "NON", "NON"],
    "Code par défaut": ["P", "P", "P", "NC", "NC", "", "", "", "", ""],
    "Sexe": ["F", "M"],
    "Situation matrimoniale": ["Célibataire", "Marié(e)", "Fiancé(e)", "Veuf(ve)", "Divorcé(e)"],
    "Catégorie d'entrée": ["Baptisé - nouveau membre", "Catéchumène (après baptême)", "Transfert d'une autre chorale EEC"],
    "Décision": ["Confirmer", "Prolonger", "Refuser"],
    "Officiant": ["1er Responsable", "Vice-Responsable"],
    "Oui/Non": ["OUI", "NON"],
    "Oui/Non/NA": ["OUI", "NON", "N/A"],
    "Statut de séance": ["Prévue", "Tenue", "Annulée"],
    "Catégorie de patrimoine": ["Administration", "Matériel de musique", "Informatique", "Mobilier",
                                "Cuisine et kit de sortie", "Tenues et textiles", "Immobilier"],
    "État du bien": ["Neuf", "Bon", "Usé", "À réparer", "Hors service", "Perdu", "Volé", "Cédé"],
    "Mode d'acquisition": ["Achat", "Don", "Legs", "Kit nouveau choriste", "Fabrication", "Autre"],
    "Applicable à": ["TOUS", "TRANSFERT"],
}

TYPES = [
    ("REP", "Répétition", "MER;SAM", "18:00", "20:30", "OUI", "OUI"),
    ("CULTE", "Culte", "DIM", "", "", "OUI", "OUI"),
    ("EVANG", "Sortie d'évangélisation", "", "", "", "OUI", "OUI"),
    ("VEIL", "Veillée de prière", "", "", "", "OUI", "OUI"),
    ("REUN", "Réunion / Assemblée générale", "", "", "", "OUI", "OUI"),
    ("ETUDE", "Étude biblique", "", "", "", "NON", "OUI"),
    ("AUTRE", "Autre activité", "", "", "", "NON", "OUI"),
]

CODES = [
    ("P", "Présent", 1, "NON", 0, "NON"),
    ("R", "Retard", 1, "NON", 50, "NON"),
    ("RX", "Retard de plus de 15 min, non admis (art. 50)", 0, "NON", 50, "NON"),
    ("DA", "Départ anticipé", 0.5, "NON", 0, "NON"),
    ("AJ", "Absent justifié", 0, "OUI", 0, "OUI"),
    ("ANJ", "Absent non justifié", 0, "NON", 0, "NON"),
    ("NC", "Non concerné (suspendu, malade de longue durée, voyage)", 0, "OUI", 0, "NON"),
]

CONTROLES = [
    ("Règlement intérieur lu et approuvé", "Administratif", "OUI", "NON", "", "", "TOUS"),
    ("Cotisations à jour", "Administratif", "OUI", "NON", "", "", "TOUS"),
    ("Lettre de recommandation", "Administratif", "OUI", "NON", "", "", "TRANSFERT"),
    ("Bible", "Matériel de travail", "OUI", "NON", "", "", "TOUS"),
    ("Cantiques de l'EEC", "Matériel de travail", "OUI", "NON", "", "", "TOUS"),
    ("Cahier de chant", "Matériel de travail", "OUI", "NON", "", "", "TOUS"),
    ("Guide biblique", "Matériel de travail", "OUI", "NON", "", "", "TOUS"),
    ("Brochure des versets", "Matériel de travail", "OUI", "NON", "", "", "TOUS"),
    ("Chaise plastique", "Kit de table", "OUI", "OUI", 3000, "Cuisine et kit de sortie", "TOUS"),
    ("Gobelet", "Kit de table", "OUI", "OUI", 500, "Cuisine et kit de sortie", "TOUS"),
    ("Fourchette", "Kit de table", "OUI", "OUI", 250, "Cuisine et kit de sortie", "TOUS"),
    ("Cuillère", "Kit de table", "OUI", "OUI", 250, "Cuisine et kit de sortie", "TOUS"),
    ("Tenue noir-blanc", "Tenue officielle", "OUI", "NON", "", "", "TOUS"),
    ("Tenue blanc-blanc", "Tenue officielle", "OUI", "NON", "", "", "TOUS"),
]

# (titre, largeur, type)  type : t texte, d date, h heure, p pourcentage, n nombre, m montant
COLS = {
    "MEMBRES": [("Matricule", 11, "t"), ("Nom", 18, "t"), ("Prénoms", 20, "t"), ("Sexe", 6, "t"),
                ("Date de naissance", 12, "d"), ("Lieu de naissance", 15, "t"), ("Téléphone", 14, "t"),
                ("WhatsApp", 14, "t"), ("Adresse / Quartier", 20, "t"), ("Personne à prévenir", 20, "t"),
                ("Tél. personne à prévenir", 14, "t"), ("Paroisse d'origine", 18, "t"), ("Date de baptême", 12, "d"),
                ("Chorale d'origine", 18, "t"), ("Date d'arrivée", 12, "d"), ("Date de réception", 12, "d"),
                ("Pupitre", 13, "t"), ("Instrument", 13, "t"), ("Commission(s)", 18, "t"), ("Fonction au Bureau", 22, "t"),
                ("Situation matrimoniale", 14, "t"), ("Conjoint", 18, "t"), ("Nombre d'enfants", 9, "n"),
                ("Statut", 17, "t"), ("Date du statut", 12, "d"), ("Observations", 30, "t")],
    "ADHESIONS": [("N° dossier", 13, "t"), ("Matricule", 11, "t"), ("Nom et prénoms", 24, "t"),
                  ("Catégorie d'entrée", 22, "t"), ("Début d'observation", 12, "d"), ("Fin prévue", 12, "d"),
                  ("Séances attendues", 10, "n"), ("Taux d'assiduité", 10, "p")]
                 + [(h, 11, "t") for h in None or []]
                 + [("Éléments manquants", 30, "t"), ("Proposition", 26, "t"), ("Décision", 12, "t"),
                    ("Motif", 24, "t"), ("Nouvelle fin d'observation", 13, "d"), ("Date de réception", 12, "d"),
                    ("Officiant", 16, "t"), ("Kit transféré", 9, "t"), ("Statut du dossier", 26, "t")],
    "SEANCES": [("ID séance", 17, "t"), ("Date", 11, "d"), ("Jour", 10, "t"), ("Type", 8, "t"), ("Libellé", 24, "t"),
                ("Heure de début", 9, "h"), ("Heure de fin", 9, "h"), ("Lieu", 18, "t"),
                ("Thème / Observations", 30, "t"), ("Statut", 10, "t"), ("Pointée", 8, "t"), ("Présents", 9, "n"),
                ("Taux de la séance", 10, "p")],
    "PRESENCES": [("ID séance", 17, "t"), ("Date", 11, "d"), ("Type", 8, "t"), ("Matricule", 11, "t"),
                  ("Nom et prénoms", 26, "t"), ("Code", 7, "t"), ("Motif", 26, "t"), ("Pénalité (FCFA)", 11, "m"),
                  ("Saisi le", 16, "dt"), ("Saisi par", 22, "t")],
    "PATRIMOINE": [("Code", 10, "t"), ("Désignation", 26, "t"), ("Catégorie", 22, "t"), ("Quantité", 9, "n"),
                   ("Unité", 8, "t"), ("Date d'acquisition", 12, "d"), ("Mode d'acquisition", 18, "t"),
                   ("Origine / Donateur", 26, "t"), ("Valeur unitaire (FCFA)", 12, "m"), ("Valeur totale (FCFA)", 12, "m"),
                   ("État", 11, "t"), ("Localisation", 20, "t"), ("Gardien", 18, "t"), ("Observations", 30, "t")],
    "JOURNAL": [("Date et heure", 17, "dt"), ("Rôle", 26, "t"), ("Titulaire", 20, "t"), ("Feuille", 18, "t"),
                ("Action", 24, "t"), ("Détail", 90, "t")],
    "UTILISATEURS": [("Code", 8, "t"), ("Rôle", 34, "t"), ("Titulaire", 24, "t"), ("Actif", 7, "t"),
                     ("Doit changer le mot de passe", 12, "t"), ("Assure l'intérim de", 30, "t"),
                     ("Début de l'intérim", 12, "d"), ("Fin de l'intérim", 12, "d"), ("Dernière connexion", 17, "dt")],
    "TYPES_ACTIVITE": [("Code", 9, "t"), ("Libellé", 30, "t"), ("Jours", 14, "t"), ("Heure de début", 10, "h"),
                       ("Heure de fin", 10, "h"), ("Compte dans le taux", 11, "t"), ("Actif", 8, "t")],
    "CODES_PRESENCE": [("Code", 8, "t"), ("Libellé", 48, "t"), ("Poids dans le taux", 11, "n"),
                       ("Exclu du calcul", 10, "t"), ("Pénalité (FCFA)", 11, "m"), ("Motif obligatoire", 10, "t")],
    "CONTROLES_ADHESION": [("N°", 5, "t"), ("Élément", 32, "t"), ("Groupe", 20, "t"), ("Obligatoire", 11, "t"),
                           ("Va au patrimoine", 11, "t"), ("Valeur unitaire estimée (FCFA)", 13, "m"),
                           ("Catégorie de patrimoine", 24, "t"), ("Applicable à", 12, "t")],
    "PARAMETRES": [("Clé", 28, "t"), ("Valeur", 46, "t"), ("Description", 90, "t")],
    "DROITS": [("Module", 13, "t"), ("Description", 40, "t")] + [(c, 8, "t") for c, _ in ROLES],
    "SECURITE": [("Code", 10, "t"), ("Sel", 20, "t"), ("Empreinte", 70, "t")],
}

TITLES = {
    "MEMBRES": "Membres de la chorale",
    "ADHESIONS": "Nouveaux choristes : dossiers d'adhésion (art. 26 à 28)",
    "SEANCES": "Calendrier des séances",
    "PRESENCES": "Historique des présences (alimenté par le pointage)",
    "PATRIMOINE": "Patrimoine",
    "JOURNAL": "Journal des actions",
    "UTILISATEURS": "Utilisateurs et rôles",
    "TYPES_ACTIVITE": "Types d'activités (jours : LUN MAR MER JEU VEN SAM DIM, séparés par ;)",
    "CODES_PRESENCE": "Codes de pointage",
    "CONTROLES_ADHESION": "Liste de contrôle avant la réception officielle (15 éléments maximum)",
    "PARAMETRES": "Paramètres",
    "LISTES": "Listes de choix",
    "DROITS": "Droits par rôle (M = modifier, L = consulter, - = masqué)",
    "SECURITE": "Sécurité",
    "POINTAGE": "Pointage d'une séance",
    "TAUX": "Taux de participation",
    "ELECTEURS": "Liste électorale",
    "FICHE_APPEL": "Fiche d'appel",
}

CHECK_HDRS = ["%02d · %s" % (i + 1, CONTROLES[i][0] if i < len(CONTROLES) else "(libre)") for i in range(15)]
COLS["ADHESIONS"][8:8] = [(h, 11, "t") for h in CHECK_HDRS]

CODENAMES = {
    "ACCUEIL": "shAccueil", "MEMBRES": "shMembres", "ADHESIONS": "shAdhesions", "SEANCES": "shSeances",
    "POINTAGE": "shPointage", "PRESENCES": "shPresences", "TAUX": "shTaux", "FICHE_APPEL": "shFicheAppel",
    "ELECTEURS": "shElecteurs", "PATRIMOINE": "shPatrimoine", "PARAMETRES": "shParametres", "LISTES": "shListes",
    "TYPES_ACTIVITE": "shTypes", "CODES_PRESENCE": "shCodes", "CONTROLES_ADHESION": "shControles",
    "UTILISATEURS": "shUtilisateurs", "JOURNAL": "shJournal", "DROITS": "shDroits", "SECURITE": "shSecurite",
}
ORDER = ["ACCUEIL", "MEMBRES", "ADHESIONS", "SEANCES", "POINTAGE", "PRESENCES", "TAUX", "FICHE_APPEL",
         "ELECTEURS", "PATRIMOINE", "PARAMETRES", "LISTES", "TYPES_ACTIVITE", "CODES_PRESENCE",
         "CONTROLES_ADHESION", "UTILISATEURS", "JOURNAL", "DROITS", "SECURITE"]
JOURNALED = {"ADHESIONS", "PARAMETRES", "LISTES", "TYPES_ACTIVITE", "CODES_PRESENCE",
             "CONTROLES_ADHESION", "UTILISATEURS", "PATRIMOINE"}

import lot2  # noqa: E402
lot2.register(globals())
import lot3  # noqa: E402
lot3.register(globals())


def col_letter(i):  # 0-based
    s = ""
    i += 1
    while i:
        i, r = divmod(i - 1, 26)
        s = chr(65 + r) + s
    return s


def hash_pwd(pwd):
    salt = "".join(random.choice("0123456789ABCDEF") for _ in range(16))
    return salt, hashlib.sha256((salt + pwd).encode("cp1252")).hexdigest().upper()


# --------------------------------------------------------------------- VBA
def read_src(path):
    with open(path, encoding="utf-8") as f:
        txt = f.read()
    try:
        txt.encode("cp1252")
    except UnicodeEncodeError as e:
        line = txt[:e.start].count("\n") + 1
        raise SystemExit("Caractère non cp1252 dans %s ligne %d : %r" % (path, line, txt[e.start:e.end]))
    return txt


def vba_modules():
    mods = []
    docdir = os.path.join(ROOT, "src", "doc")
    mods.append(("ThisWorkbook", "doc", doc_module_source("ThisWorkbook", "workbook",
                                                          read_src(os.path.join(docdir, "ThisWorkbook.cls")))))
    journal = read_src(os.path.join(docdir, "_journal.cls"))
    for name in ORDER:
        cn = CODENAMES[name]
        p = os.path.join(docdir, cn + ".cls")
        if os.environ.get("CHORALE_NODOC"):
            code = "Option Explicit\r\n"
        elif os.path.exists(p):
            code = read_src(p)
        elif name in JOURNALED:
            code = journal
        else:
            code = "Option Explicit\r\n"
        mods.append((cn, "doc", doc_module_source(cn, "sheet", code)))
    dirs = [os.path.join(ROOT, "src", "vba")]
    if os.environ.get("CHORALE_TESTS"):
        dirs.append(os.path.join(ROOT, "tests", "vba"))
    for vdir in dirs:
        for f in sorted(os.listdir(vdir)):
            if f.endswith(".bas"):
                name = f[:-4]
                if os.environ.get("CHORALE_TESTS") and name == "modMdpMasque":
                    continue  # API Windows : non executable sous LibreOffice
                mods.append((name, "std", std_module_source(name, read_src(os.path.join(vdir, f)))))
    return mods


# --------------------------------------------------------------------- classeur
class Builder:
    def __init__(self, path, data):
        self.wb = xlsxwriter.Workbook(path)
        self.wb.set_vba_name("ThisWorkbook")
        self.data = data
        self.f = {}
        self._formats()
        self.ws = {}

    def _formats(self):
        wb = self.wb
        base = {"font_name": "Calibri", "font_size": 10, "valign": "vcenter"}
        F = lambda **k: wb.add_format({**base, **k})  # noqa: E731
        self.f["title"] = F(bold=True, font_size=15, font_color="#FFFFFF", bg_color=PRINCIPALE, valign="vcenter")
        self.f["band"] = F(bg_color=PRINCIPALE)
        self.f["hdr"] = F(bold=True, font_color="#FFFFFF", bg_color=PRINCIPALE, text_wrap=True, align="center",
                          border=1, border_color="#FFFFFF")
        self.f["t"] = F()
        self.f["d"] = F(num_format="dd/mm/yyyy", align="center")
        self.f["dt"] = F(num_format="dd/mm/yyyy hh:mm")
        self.f["h"] = F(num_format="hh:mm", align="center")
        self.f["p"] = F(num_format="0%", align="center")
        self.f["n"] = F(align="center")
        self.f["m"] = F(num_format="#,##0")
        self.f["section"] = F(bold=True, bg_color=SECONDAIRE, font_color=PRINCIPALE)
        self.f["label"] = F(bold=True, align="right")
        self.f["input"] = F(bg_color="#FFF299", border=1, border_color="#BFBF00")
        self.f["input_d"] = F(bg_color="#FFF299", border=1, border_color="#BFBF00", num_format="dd/mm/yyyy", align="center")
        self.f["info"] = F(italic=True, font_color="#595959")
        self.f["big_p"] = F(bold=True, font_size=14, num_format="0%", font_color=PRINCIPALE)
        self.f["home_name"] = F(bold=True, font_size=22, font_color=PRINCIPALE)
        self.f["home_sub"] = F(font_size=11, font_color="#595959")
        self.f["home_motto"] = F(italic=True, font_size=11, font_color="#7F7F7F")
        self.f["home_sec"] = F(bold=True, font_size=9, font_color="#7F7F7F")
        self.f["home_alert"] = F(bold=True, font_size=11, font_color=ACCENT)
        self.f["role"] = F(bold=True, font_size=12, bg_color="#FFF299", border=1, border_color="#BFBF00")
        self.f["small"] = F(font_size=9, font_color="#7F7F7F", italic=True)
        self.f["demo"] = F(bold=True, font_color="#FFFFFF", bg_color=ACCENT, align="center")

    def sheet(self, name):
        ws = self.wb.add_worksheet(name)
        ws.set_vba_name(CODENAMES[name])
        ws.hide_gridlines(2)
        self.ws[name] = ws
        return ws

    def title(self, ws, name, ncols, hdr_row):
        ws.set_row(0, 30)
        ws.set_row(1, 22)
        ws.set_row(2, 12)
        ws.merge_range(0, 0, 0, max(ncols - 1, 7), "  " + TITLES.get(name, name), self.f["title"])
        if self.data.get("demo") and name not in ("SECURITE", "DROITS"):
            ws.merge_range(2, 1, 2, 3, "DONNÉES FICTIVES", self.f["demo"])

    def table(self, name, rows=None, autofilter=True, freeze_col=1):
        ws = self.sheet(name)
        cols = COLS[name]
        self.title(ws, name, len(cols), HDR)
        ws.set_row(HDR - 1, 34)
        for i, (h, w, t) in enumerate(cols):
            ws.set_column(i, i, w, self.f[t])
            ws.write(HDR - 1, i, h, self.f["hdr"])
        for r, row in enumerate(rows or []):
            for c, v in enumerate(row):
                if v is None or v == "":
                    continue
                t = cols[c][2] if c < len(cols) else "t"
                ws.write(FIRST - 1 + r, c, v, self.f[t])
        if autofilter:
            ws.autofilter(HDR - 1, 0, HDR - 1 + max(1, len(rows or [])), len(cols) - 1)
        ws.freeze_panes(HDR, freeze_col)
        return ws

    def validation(self, ws, name, header, source, kind="list"):
        cols = [c[0] for c in COLS[name]]
        c = cols.index(header)
        if kind == "list":
            ws.data_validation(FIRST - 1, c, VAL_ROWS, c, {"validate": "list", "source": source,
                                                          "error_type": "warning",
                                                          "error_message": "Valeur hors liste : vérifiez la saisie."})
        elif kind == "date":
            ws.data_validation(FIRST - 1, c, VAL_ROWS, c, {"validate": "date", "criteria": ">=",
                                                          "value": dt.date(1900, 1, 1),
                                                          "error_message": "Saisissez une date (jj/mm/aaaa)."})

    # ----------------------------------------------------------------- feuilles
    def build(self):
        d = self.data
        self.accueil()
        ws = self.table("MEMBRES", d["membres"], freeze_col=3)
        for h, src in [("Sexe", "=L_SEXE"), ("Pupitre", "=L_PUPITRES"), ("Fonction au Bureau", "=L_FONCTIONS"),
                       ("Situation matrimoniale", "=L_SITUATIONS"), ("Statut", "=L_STATUTS")]:
            self.validation(ws, "MEMBRES", h, src)
        for h in ("Date de naissance", "Date de baptême", "Date d'arrivée", "Date de réception", "Date du statut"):
            self.validation(ws, "MEMBRES", h, None, "date")

        ws = self.table("ADHESIONS", d["adhesions"], freeze_col=3)
        self.validation(ws, "ADHESIONS", "Catégorie d'entrée", "=L_CATEGORIES")
        self.validation(ws, "ADHESIONS", "Décision", "=L_DECISIONS")
        self.validation(ws, "ADHESIONS", "Officiant", "=L_OFFICIANTS")
        for h in CHECK_HDRS:
            self.validation(ws, "ADHESIONS", h, "=L_OUINONNA")
        ws.set_column(8 + len(CONTROLES), 8 + 14, None, None, {"hidden": True})
        for h in ("Début d'observation", "Nouvelle fin d'observation", "Date de réception"):
            self.validation(ws, "ADHESIONS", h, None, "date")

        ws = self.table("SEANCES", d["seances"], freeze_col=2)
        self.validation(ws, "SEANCES", "Type", "=L_TYPES")
        self.validation(ws, "SEANCES", "Statut", "=L_STATUTS_SEANCE")
        self.validation(ws, "SEANCES", "Date", None, "date")

        self.pointage()
        self.table("PRESENCES", d["presences"], freeze_col=1)
        self.taux()
        self.fiche()
        self.electeurs()

        ws = self.table("PATRIMOINE", d["patrimoine"], freeze_col=2)
        self.validation(ws, "PATRIMOINE", "Catégorie", "=L_CAT_PAT")
        self.validation(ws, "PATRIMOINE", "État", "=L_ETATS")
        self.validation(ws, "PATRIMOINE", "Mode d'acquisition", "=L_MODES")

        self.parametres()
        self.listes()
        ws = self.table("TYPES_ACTIVITE", [list(t) for t in TYPES], autofilter=False)
        self._times(ws, "TYPES_ACTIVITE", TYPES, (3, 4))
        self.validation(ws, "TYPES_ACTIVITE", "Compte dans le taux", "=L_OUINON")
        self.validation(ws, "TYPES_ACTIVITE", "Actif", "=L_OUINON")
        ws = self.table("CODES_PRESENCE", [list(c) for c in CODES], autofilter=False)
        self.validation(ws, "CODES_PRESENCE", "Exclu du calcul", "=L_OUINON")
        self.validation(ws, "CODES_PRESENCE", "Motif obligatoire", "=L_OUINON")
        ctrl = [[i + 1] + list(c) for i, c in enumerate(CONTROLES)]
        ws = self.table("CONTROLES_ADHESION", ctrl, autofilter=False)
        for h in ("Obligatoire", "Va au patrimoine"):
            self.validation(ws, "CONTROLES_ADHESION", h, "=L_OUINON")
        self.validation(ws, "CONTROLES_ADHESION", "Catégorie de patrimoine", "=L_CAT_PAT")
        self.validation(ws, "CONTROLES_ADHESION", "Applicable à", "=L_APPLICABLE")

        users = [[c, l, d["titulaires"].get(c, ""), "OUI", "OUI", "", None, None, None] for c, l in ROLES]
        ws = self.table("UTILISATEURS", users, autofilter=False)
        self.validation(ws, "UTILISATEURS", "Actif", "=L_OUINON")
        self.validation(ws, "UTILISATEURS", "Assure l'intérim de", "=L_ROLES")
        self.table("JOURNAL", d["journal"], freeze_col=1)
        self.table("DROITS", [[m, desc] + v.split() for m, desc, v in DROITS], autofilter=False)
        sec = []
        for c, _ in ROLES:
            s, h = hash_pwd(MDP_INITIAL)
            sec.append([c, s, h])
        self.table("SECURITE", sec, autofilter=False)
        lot2.build_sheets(self)
        lot3.build_sheets(self)
        self.names()
        lot2.names(self)
        lot3.names(self)
        for name, ws in self.ws.items():
            if name != "ACCUEIL":
                ws.very_hidden()
            ws.protect(SYS_PWD, {"autofilter": True, "format_columns": True, "format_rows": True,
                                 "select_locked_cells": True, "select_unlocked_cells": True})
        self.ws["ACCUEIL"].activate()

    def _times(self, ws, name, rows, idxs):
        for r, row in enumerate(rows):
            for i in idxs:
                if row[i]:
                    h, m = map(int, row[i].split(":"))
                    ws.write_number(FIRST - 1 + r, i, (h * 60 + m) / 1440.0, self.f["h"])

    def accueil(self):
        ws = self.sheet("ACCUEIL")
        ws.set_column(0, 0, 2)
        ws.set_column(1, 12, 13)
        ws.set_row(0, 8)
        ws.merge_range(0, 0, 0, 12, "", self.f["band"])
        ws.set_row(1, 34)
        ws.write(1, 1, "Chorale", self.f["home_name"])
        ws.write(2, 1, "", self.f["home_sub"])
        ws.write(3, 1, "", self.f["home_motto"])
        ws.write(4, 1, "Si les boutons ne répondent pas, activez les macros (voir la notice d'installation).",
                 self.f["small"])
        ws.write(5, 1, "SESSION", self.f["home_sec"])
        ws.write(6, 1, "Rôle :", self.f["label"])
        ws.merge_range(6, 3, 6, 5, "", self.f["role"])
        ws.write(7, 1, "Session :", self.f["label"])
        ws.write(7, 3, "Non connecté", self.f["t"])
        ws.write(8, 1, "MENU", self.f["home_sec"])
        ws.write(32, 1, "ALERTES DU JOUR", self.f["home_alert"])
        if self.data.get("demo"):
            ws.write(4, 9, "VERSION DE DÉMONSTRATION - DONNÉES FICTIVES", self.f["demo"])
        ws.data_validation(6, 3, 6, 3, {"validate": "list", "source": "=L_ROLES",
                                        "input_title": "Votre rôle", "input_message": "Choisissez votre rôle puis cliquez sur « Se connecter »."})

    def pointage(self):
        ws = self.sheet("POINTAGE")
        cols = [("Matricule", 11, "t"), ("Nom et prénoms", 30, "t"), ("Pupitre", 14, "t"), ("Code", 8, "n"),
                ("Motif", 34, "t"), ("Statut du membre", 18, "t")]
        self.title(ws, "POINTAGE", 8, OUT_HDR)
        for i, (h, w, t) in enumerate(cols):
            ws.set_column(i, i, w, self.f[t])
            ws.write(OUT_HDR - 1, i, h, self.f["hdr"])
        ws.set_column(7, 7, 20, self.f["small"])
        ws.write(4, 1, "Séance :", self.f["label"])
        ws.write(4, 2, "", self.f["input"])
        ws.write(5, 1, "", self.f["t"])
        ws.write(5, 2, "Choisissez une séance (ou « Prochaine séance à pointer »), chargez-la, corrigez les codes puis validez.", self.f["info"])
        ws.write(6, 0, "Codes : P présent · R retard · RX retard > 15 min · DA départ anticipé · AJ absent justifié (motif) · ANJ absent non justifié · NC non concerné", self.f["small"])
        ws.data_validation(4, 2, 4, 2, {"validate": "list", "source": "=L_SEANCES", "error_type": "warning"})
        ws.data_validation(OUT_HDR, 3, MAXROWS, 3, {"validate": "list", "source": "=L_CODES"})
        ws.freeze_panes(OUT_HDR, 2)

    def taux(self):
        ws = self.sheet("TAUX")
        cols = [("Rang", 6, "n"), ("Matricule", 11, "t"), ("Nom et prénoms", 28, "t"), ("Pupitre", 13, "t"),
                ("Statut", 16, "t"), ("Séances attendues", 10, "n"), ("P", 5, "n"), ("R", 5, "n"), ("RX", 5, "n"),
                ("DA", 5, "n"), ("AJ", 5, "n"), ("ANJ", 5, "n"), ("NC", 5, "n"), ("Autres", 6, "n"),
                ("Taux", 8, "p"), ("Appréciation", 12, "t")]
        self.title(ws, "TAUX", 16, OUT_HDR)
        for i, (h, w, t) in enumerate(cols):
            ws.set_column(i, i, w, self.f[t])
            ws.write(OUT_HDR - 1, i, h, self.f["hdr"])
        ws.set_column(16, 16, 3)
        ws.write(4, 1, "Du :", self.f["label"])
        ws.write(4, 2, "", self.f["input_d"])
        ws.write(4, 3, "au :", self.f["label"])
        ws.write(4, 4, "", self.f["input_d"])
        ws.write(4, 5, "Type :", self.f["label"])
        ws.write(4, 6, "TOUS", self.f["input"])
        ws.write(5, 1, "Groupe :", self.f["label"])
        ws.write(5, 2, "", self.f["big_p"])
        ws.write(5, 3, "Séances :", self.f["label"])
        ws.write(6, 0, "Taux = (P + R + DA × poids) ÷ séances attendues, hors AJ et NC. TOUS = types qui comptent dans le taux.", self.f["small"])
        ws.data_validation(4, 6, 4, 6, {"validate": "list", "source": "=L_FILTRE_TYPES"})
        ws.freeze_panes(OUT_HDR, 3)

    def fiche(self):
        ws = self.sheet("FICHE_APPEL")
        cols = [("N°", 5, "n"), ("Matricule", 11, "t"), ("Nom et prénoms", 32, "t"), ("Pupitre", 13, "t"),
                ("P", 6, "n"), ("R", 6, "n"), ("AJ", 6, "n"), ("ANJ", 6, "n"), ("Observations / signature", 30, "t")]
        self.title(ws, "FICHE_APPEL", 9, OUT_HDR)
        for i, (h, w, t) in enumerate(cols):
            ws.set_column(i, i, w, self.f[t])
            ws.write(OUT_HDR - 1, i, h, self.f["hdr"])
        ws.write(4, 1, "Séance :", self.f["label"])
        ws.write(4, 2, "", self.f["input"])
        ws.data_validation(4, 2, 4, 2, {"validate": "list", "source": "=L_SEANCES", "error_type": "warning"})
        ws.set_paper(9)
        ws.fit_to_pages(1, 0)
        ws.repeat_rows(0, OUT_HDR - 1)
        ws.set_margins(0.4, 0.4, 0.5, 0.5)

    def electeurs(self):
        ws = self.sheet("ELECTEURS")
        cols = [("N°", 5, "n"), ("Matricule", 11, "t"), ("Nom et prénoms", 32, "t"), ("Pupitre", 13, "t"),
                ("Date d'arrivée", 12, "d"), ("Taux", 8, "p"), ("Émargement", 24, "t")]
        self.title(ws, "ELECTEURS", 8, OUT_HDR)
        for i, (h, w, t) in enumerate(cols):
            ws.set_column(i, i, w, self.f[t])
            ws.write(OUT_HDR - 1, i, h, self.f["hdr"])
        ws.write(4, 2, "", self.f["info"])
        ws.write(5, 2, "", self.f["info"])
        ws.set_paper(9)
        ws.fit_to_pages(1, 0)
        ws.repeat_rows(0, OUT_HDR - 1)

    def parametres(self):
        ws = self.sheet("PARAMETRES")
        cols = COLS["PARAMETRES"]
        self.title(ws, "PARAMETRES", 3, HDR)
        ws.set_row(HDR - 1, 22)
        for i, (h, w, t) in enumerate(cols):
            ws.set_column(i, i, w, self.f["t"])
            ws.write(HDR - 1, i, h, self.f["hdr"])
        r = FIRST - 1
        for p in PARAMS:
            if p[0] == "#":
                ws.write(r, 0, "", self.f["section"])
                ws.write(r, 1, "", self.f["section"])
                ws.write(r, 2, p[1], self.f["section"])
            else:
                key, val, desc = p
                val = self.data.get("params", {}).get(key, val)
                ws.write(r, 0, key, self.f["t"])
                if isinstance(val, dt.date):
                    ws.write_datetime(r, 1, dt.datetime.combine(val, dt.time()), self.f["d"])
                elif isinstance(val, float) and val < 1:
                    ws.write_number(r, 1, val, self.f["p"])
                elif val == "":
                    ws.write_blank(r, 1, None, self.f["t"])
                else:
                    ws.write(r, 1, val, self.f["t"])
                ws.write(r, 2, desc, self.f["info"])
            r += 1
        ws.freeze_panes(HDR, 1)

    def listes(self):
        ws = self.sheet("LISTES")
        keys = list(LISTES.keys()) + ["Filtre de type"]
        self.title(ws, "LISTES", len(keys), HDR)
        ws.set_row(HDR - 1, 34)
        for i, k in enumerate(keys):
            ws.set_column(i, i, 18, self.f["t"])
            ws.write(HDR - 1, i, k, self.f["hdr"])
            if k in LISTES:
                for j, v in enumerate(LISTES[k]):
                    if v != "":
                        ws.write(FIRST - 1 + j, i, v, self.f["t"])
        fc = len(keys) - 1
        ws.write(FIRST - 1, fc, "TOUS", self.f["t"])
        for j in range(40):
            ws.write_formula(FIRST + j, fc, '=IF(TYPES_ACTIVITE!A%d="","",TYPES_ACTIVITE!A%d)' % (FIRST + j, FIRST + j),
                             self.f["t"], "")
        self.listes_cols = {k: col_letter(i) for i, k in enumerate(keys)}
        ws.freeze_panes(HDR, 0)

    def names(self):
        wb = self.wb
        lc = self.listes_cols

        def dyn(key):
            c = lc[key]
            return "=OFFSET(LISTES!$%s$%d,0,0,MAX(1,COUNTA(LISTES!$%s$%d:$%s$300)),1)" % (c, FIRST, c, FIRST, c)

        for nm, key in [("L_PUPITRES", "Pupitre"), ("L_COMMISSIONS", "Commission"), ("L_FONCTIONS", "Fonction au Bureau"),
                        ("L_STATUTS", "Statut"), ("L_SEXE", "Sexe"), ("L_SITUATIONS", "Situation matrimoniale"),
                        ("L_CATEGORIES", "Catégorie d'entrée"), ("L_DECISIONS", "Décision"), ("L_OFFICIANTS", "Officiant"),
                        ("L_OUINON", "Oui/Non"), ("L_OUINONNA", "Oui/Non/NA"), ("L_STATUTS_SEANCE", "Statut de séance"),
                        ("L_CAT_PAT", "Catégorie de patrimoine"), ("L_ETATS", "État du bien"),
                        ("L_MODES", "Mode d'acquisition"), ("L_APPLICABLE", "Applicable à")]:
            if key in lc:
                wb.define_name(nm, dyn(key))
        fc = lc["Filtre de type"]
        wb.define_name("L_FILTRE_TYPES", "=OFFSET(LISTES!$%s$%d,0,0,1+COUNTIF(TYPES_ACTIVITE!$A$%d:$A$300,\"?*\"),1)" % (fc, FIRST, FIRST))
        wb.define_name("L_ROLES", "=UTILISATEURS!$B$%d:$B$%d" % (FIRST, FIRST + len(ROLES) - 1))
        wb.define_name("L_TYPES", "=OFFSET(TYPES_ACTIVITE!$A$%d,0,0,MAX(1,COUNTA(TYPES_ACTIVITE!$A$%d:$A$300)),1)" % (FIRST, FIRST))
        wb.define_name("L_CODES", "=OFFSET(CODES_PRESENCE!$A$%d,0,0,MAX(1,COUNTA(CODES_PRESENCE!$A$%d:$A$300)),1)" % (FIRST, FIRST))
        wb.define_name("L_SEANCES", "=OFFSET(SEANCES!$A$%d,0,0,MAX(1,COUNTA(SEANCES!$A$%d:$A$%d)),1)" % (FIRST, FIRST, MAXROWS))

    def close(self, vba_bin):
        self.wb.add_vba_project(vba_bin)
        self.wb.close()


def main():
    dist = os.environ.get("CHORALE_OUT") or os.path.join(ROOT, "dist")
    os.makedirs(dist, exist_ok=True)
    tmp = os.path.join(HERE, "_vbaProject.bin")
    with open(tmp, "wb") as f:
        f.write(build_vba_project(vba_modules()))
    for fname, data in [("GestionChorale.xlsm", demo.empty_data()),
                        ("GestionChorale_DEMO.xlsm", demo.demo_data(LISTES, CONTROLES, lot2, lot3))]:
        b = Builder(os.path.join(dist, fname), data)
        b.build()
        b.close(tmp)
        print("OK", fname)
    os.remove(tmp)


if __name__ == "__main__":
    random.seed(20261013)
    main()
