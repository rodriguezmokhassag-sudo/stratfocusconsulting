"""Guide du menu de chaque role (Word) : pour chacun des 10 roles, son menu, puis pour chaque fonction
ce qu'il peut et ne peut pas faire ; en derniere partie, les fiches completes de docs/guide_menu_admin.md.
Les droits viennent de build.DROITS et des controles des macros (src/vba).
Usage : python3 build/guide_roles.py  ->  dist/Guide_Menus_par_role.docx"""
import glob
import os
import re
import subprocess
import sys
import tempfile
import zipfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "build"))
import build  # noqa: E402

CAP = os.path.join(ROOT, "docs", "captures")
VBA = "".join(open(f, encoding="utf-8").read() for f in glob.glob(os.path.join(ROOT, "src", "vba", "*.bas")))

# (libelle du menu, n° de fiche, module de droits, feuilles dont les boutons sont decrits)
FONCTIONS = [
    ("Tableau de bord", "1.1", "RAPPORTS", ["SH_TB"]),
    ("Rapport pour l'AG", "1.2", "RAPPORTS", ["SH_RAG"]),
    ("Point financier du mois", "1.3", "FINANCES", ["SH_PMOIS"]),
    ("Livre de caisse", "1.4", "FINANCES", ["SH_LIVRE"]),
    ("Membres", "2.1", "MEMBRES", ["SH_MEMBRES"]),
    ("Fiche d'un membre", "2.2", "MEMBRES", ["SH_FMEMBRE"]),
    ("Nouveaux choristes", "2.3", "MEMBRES", ["SH_ADH"]),
    ("Calendrier des séances", "2.4", "PRESENCES", ["SH_SEANCES"]),
    ("Pointage d'une séance", "2.5", "PRESENCES", ["SH_POINTAGE"]),
    ("Historique des présences", "2.6", "PRESENCES", []),
    ("Taux de participation", "2.7", "PRESENCES", ["SH_TAUX"]),
    ("Pupitres et commissions", "2.8", "PRESENCES", ["SH_RPUP"]),
    ("Fiche d'appel", "2.9", "PRESENCES", ["SH_FICHE"]),
    ("Liste électorale", "2.10", "MANDATS", ["SH_ELEC"]),
    ("Patrimoine", "3.1", "PATRIMOINE", ["SH_PAT", "SH_FICHEB"]),
    ("Prêts et mouvements", "3.2", "PATRIMOINE", ["SH_MOUV"]),
    ("Locations de matériel", "3.3", "PATRIMOINE", ["SH_LOCATIONS", "SH_CONTRAT"]),
    ("Inventaire physique", "3.4", "PATRIMOINE", ["SH_INVENT"]),
    ("Synthèse du patrimoine", "3.5", "PATRIMOINE", ["SH_SYNTH"]),
    ("Étiquettes", "3.6", "PATRIMOINE", ["SH_ETIQ"]),
    ("Saisie de caisse", "4.1", "FINANCES", ["SH_SAISIE", "SH_RECU"]),
    ("Journal de caisse", "4.2", "FINANCES", ["SH_CAISSE", "SH_CLOTURES"]),
    ("Cotisations", "4.3", "COTISATIONS", ["SH_COTIS"]),
    ("Cotisations spéciales", "4.4", "COTISATIONS", ["SH_CAMPAGNES", "SH_SUIVI_CAMP"]),
    ("Caisse sociale", "4.5", "SOCIAL", ["SH_SOCIAL"]),
    ("Budget", "4.6", "FINANCES", ["SH_BUDGET"]),
    ("Suivi budgétaire", "4.7", "FINANCES", ["SH_SUIVI_BUDGET"]),
    ("Arrêté de caisse", "4.8", "FINANCES", ["SH_ARRETE"]),
    ("Pertes et remboursements", "4.9", "FINANCES", ["SH_PERTES"]),
    ("Discipline", "5.1", "DISCIPLINE", ["SH_DISC", "SH_NOTIF"]),
    ("Planning des activités", "5.2", "PLANNING", ["SH_PLAN"]),
    ("Programme annuel", "5.3", "PLANNING", ["SH_PROGAN"]),
    ("Mandats", "5.4", "MANDATS", ["SH_MANDATS"]),
    ("Élections", "5.5", "MANDATS", ["SH_SCRUTINS", "SH_CAND", "SH_PV"]),
    ("Répertoire des cantiques", "5.6", "CANTIQUES", ["SH_CANT"]),
    ("Programmes des chants", "5.7", "CANTIQUES", ["SH_PROGS", "SH_PROGCH"]),
    ("Études bibliques", "5.8", "CANTIQUES", ["SH_ETUDES"]),
    ("Paramètres", "6.1", "PARAM", ["SH_PARAM"]),
    ("Listes de choix", "6.2", "PARAM", []),
    ("Types d'activités", "6.3", "PARAM", []),
    ("Codes de présence", "6.4", "PARAM", []),
    ("Contrôles d'adhésion", "6.5", "PARAM", ["SH_CTRL"]),
    ("Rubriques budgétaires", "6.6", "FINANCES", []),
    ("Barème social", "6.7", "SOCIAL", []),
    ("Catégories du patrimoine", "6.8", "PATRIMOINE", []),
    ("Utilisateurs", "6.9", "USERS", ["SH_USERS"]),
    ("Journal des actions", "6.10", "JOURNAL", []),
]
DOMAINES = [("1", "Pilotage et rapports"), ("2", "Secrétariat"), ("3", "Patrimoine"), ("4", "Finances"),
            ("5", "Vie du groupe"), ("6", "Paramétrage et sécurité")]
# Module de droits de chaque feuille (modSecurite.SheetModule)
MODULE_FEUILLE = {
    "SH_PARAM": "PARAM", "SH_LISTES": "PARAM", "SH_TYPES": "PARAM", "SH_CODES": "PARAM", "SH_CTRL": "PARAM",
    "SH_USERS": "USERS", "SH_MEMBRES": "MEMBRES", "SH_ADH": "MEMBRES", "SH_FMEMBRE": "MEMBRES",
    "SH_SEANCES": "PRESENCES", "SH_POINTAGE": "PRESENCES", "SH_PRES": "PRESENCES", "SH_TAUX": "PRESENCES",
    "SH_FICHE": "PRESENCES", "SH_RPUP": "PRESENCES", "SH_ELEC": "MANDATS", "SH_MANDATS": "MANDATS",
    "SH_SCRUTINS": "MANDATS", "SH_CAND": "MANDATS", "SH_PV": "MANDATS", "SH_DISC": "DISCIPLINE", "SH_NOTIF": "DISCIPLINE",
    "SH_PLAN": "PLANNING", "SH_PROGAN": "PLANNING", "SH_CANT": "CANTIQUES", "SH_PROGS": "CANTIQUES",
    "SH_PROGCH": "CANTIQUES", "SH_ETUDES": "CANTIQUES", "SH_TB": "RAPPORTS", "SH_RAG": "RAPPORTS",
    "SH_PMOIS": "FINANCES", "SH_LIVRE": "FINANCES", "SH_SAISIE": "FINANCES", "SH_CAISSE": "FINANCES",
    "SH_RUBRIQUES": "FINANCES", "SH_BUDGET": "FINANCES", "SH_SUIVI_BUDGET": "FINANCES", "SH_ARRETE": "FINANCES",
    "SH_ARRETES": "FINANCES", "SH_PERTES": "FINANCES", "SH_RECU": "FINANCES", "SH_CLOTURES": "FINANCES",
    "SH_COTIS": "COTISATIONS", "SH_CAMPAGNES": "COTISATIONS", "SH_SUIVI_CAMP": "COTISATIONS",
    "SH_SOCIAL": "SOCIAL", "SH_BAREME": "SOCIAL", "SH_PAT": "PATRIMOINE", "SH_CATPAT": "PATRIMOINE",
    "SH_MOUV": "PATRIMOINE", "SH_LOCATIONS": "PATRIMOINE", "SH_CONTRAT": "PATRIMOINE", "SH_ETIQ": "PATRIMOINE",
    "SH_INVENT": "PATRIMOINE", "SH_INVENTS": "PATRIMOINE", "SH_SYNTH": "PATRIMOINE", "SH_FICHEB": "PATRIMOINE",
}
# Boutons dont la condition ne se lit pas dans un RequireEdit : ("FINM" = droit de modifier les finances)
EXCEPTIONS = {
    "EncaisserCotisation": "FINM", "EncaisserPenalites": "FINM", "EncaisserCampagne": "FINM", "VerserAide": "FINM",
    "EncaisserLocation": "FINM", "RestituerCaution": "FINM", "AnnulerEcriture": "FINM", "RemboursementPerte": "FINM",
    "CreerDepuisDepense": "PATM|FINM", "ReinitialiserMotDePasse": "ADMIN", "ReprendreAncienFichier": "ADMIN",
}
NOTES = {   # actions qui marchent en consultation avec une limite
    "NotifierSanction": "imprime la lettre ; l'enregistrement de la remise demande le droit de modifier la discipline",
    "ControlerProgramme": "affiche les remarques ; elles ne s'écrivent dans la feuille qu'avec le droit de modifier",
    "RetourMouvement": "le coût d'une réparation n'est passé en caisse qu'avec le droit de modifier les finances",
}
ROLES_INFO = {
    "ADMIN": ("Administrateur", "Gère l'application : paramètres, listes, utilisateurs et mots de passe, reprise des anciens fichiers, sauvegardes. Il voit et peut tout faire ; c'est le seul rôle qui consulte le journal des actions."),
    "RESP1": ("1er Responsable", "Dirige la chorale et préside le Bureau. Il décide en matière de discipline et d'élections, signe les notifications, les rapports et les procès-verbaux, et suit tous les domaines en consultation."),
    "VICE": ("Vice-Responsable", "Seconde et remplace le 1er Responsable. Il décide en matière de discipline et déclare les événements de la caisse sociale ; il consulte les autres domaines."),
    "SG": ("Secrétaire Général", "Tient le secrétariat : membres, nouveaux choristes, calendrier, pointage, taux de participation, liste électorale, élections et planning."),
    "SGA": ("Secrétaire Général Adjoint", "Seconde le Secrétaire Général pour le secrétariat courant : membres, nouveaux choristes, séances, pointage et planning."),
    "FIN": ("Secrétaire aux Finances", "Tient la caisse et la banque, le budget, les cotisations, les encaissements et les versements, les arrêtés de caisse, les pertes et la clôture des exercices."),
    "PAT": ("Secrétaire aux Patrimoines", "Tient le patrimoine : inventaire, prêts, réparations, locations, inventaires physiques et étiquettes."),
    "EVA": ("Secrétaire à l'Évangélisation", "Anime l'évangélisation et la vie spirituelle : planning des sorties, répertoire des cantiques, programmes des chants, études bibliques."),
    "CONS": ("Consultation (conseiller paroissial)", "Suit la vie de la chorale pour la paroisse, en lecture seule, sans accès aux finances ni à la discipline."),
    "DIR": ("Directeur de chœur (maître de chants)", "Dirige le chant : répertoire, apprentissage par pupitre, programmes des chants et études. Il consulte les membres, les présences, le patrimoine et le planning."),
}
# Effets des boutons decrits en prose dans les fiches : (feuille, bouton) puis bouton seul
EFFETS = {
    ("SH_FICHEB", "Afficher"): "Affiche la fiche du bien dont le code est dans la case jaune, avec l'historique de ses mouvements.",
    ("SH_FICHEB", "Imprimer"): "Imprime la fiche du bien.",
    ("SH_CONTRAT", "Imprimer"): "Imprime le contrat de location à faire signer.",
    ("SH_CONTRAT", "Autre contrat"): "Prépare le contrat d'une autre location.",
    ("SH_RECU", "Imprimer"): "Imprime le reçu.",
    ("SH_RECU", "Autre reçu"): "Prépare le reçu d'une autre pièce.",
    ("SH_CLOTURES", "Clôturer un exercice"): "Archive les soldes, les totaux et le résultat ; plus aucune écriture ne peut être datée dans l'exercice.",
    ("SH_NOTIF", "Imprimer"): "Imprime la lettre de notification.",
    ("SH_NOTIF", "Autre notification"): "Prépare la notification d'un autre dossier.",
    ("SH_PV", "Imprimer"): "Imprime le procès-verbal d'élection.",
    ("SH_PV", "Autre PV"): "Prépare le procès-verbal d'un autre scrutin.",
    ("SH_PROGCH", "Afficher"): "Remplit le programme des chants de la date indiquée dans la case jaune.",
    ("SH_PROGCH", "Contrôler"): "Signale les chants chantés à moins de 4 semaines d'intervalle ou non maîtrisés.",
    ("SH_PROGCH", "Imprimer"): "Imprime le programme à distribuer.",
    ("SH_SUIVI_CAMP", "Calculer"): "Liste, pour la campagne choisie, qui a payé, combien, et ce qu'il reste à payer.",
    ("SH_SUIVI_CAMP", "Encaisser"): "Enregistre le paiement d'un membre pour la campagne, avec son reçu.",
    ("SH_SUIVI_CAMP", "Imprimer"): "Imprime le suivi de la campagne.",
    ("SH_SYNTH", "Calculer"): "Calcule la synthèse par catégorie à la date de la case jaune.",
    ("SH_ETIQ", "Générer les étiquettes"): "Prépare les étiquettes de tous les biens, d'une catégorie ou d'un code.",
    ("SH_FICHE", "Générer la fiche"): "Prépare la liste des membres attendus à la séance indiquée, par pupitre.",
    ("SH_ELEC", "Générer la liste"): "Retient les choristes confirmés depuis au moins 3 mois avec au moins 60 % d'assiduité.",
    ("SH_PROGAN", "Calculer"): "Établit le programme de l'exercice indiqué, par mois, avec le budget total.",
    ("SH_SUIVI_BUDGET", "Calculer"): "Compare le budget et le réalisé de l'exercice et du mois choisis, avec écarts et variations.",
    ("SH_CTRL", "Mettre à jour les dossiers"): "Reporte les changements de la liste de contrôle dans les dossiers d'adhésion.",
    "Imprimer": "Aperçu avant impression de la feuille.",
    "Ce mois": "Règle la période sur le mois en cours et calcule les taux.",
    "Mois précédent": "Règle la période sur le mois précédent et calcule les taux.",
    "Ce trimestre": "Règle la période sur le trimestre en cours et calcule les taux.",
    "Cette année": "Règle la période sur l'année en cours et calcule les taux.",
}
# Feuilles de resultats : seules les cases jaunes de reglage se modifient (UnlockInputs)
RAPPORTS = {"SH_TB", "SH_RAG", "SH_PMOIS", "SH_LIVRE", "SH_FMEMBRE", "SH_TAUX", "SH_RPUP", "SH_FICHE", "SH_ELEC",
            "SH_SYNTH", "SH_ETIQ", "SH_PROGAN", "SH_SUIVI_BUDGET"}
DROITS = {m: dict(zip([c for c, _ in build.ROLES], v.split())) for m, _, v in build.DROITS}


def boutons_feuille(const):
    src = open(os.path.join(ROOT, "src", "vba", "modInterface.bas"), encoding="utf-8").read()
    m = re.search(r"Case %s\s*\n\s*SheetButtons = Array\((.*?)\)\n" % re.escape(const), src)
    return [tuple(x.split("|")[:2]) for x in re.findall(r'"([^"]+)"', m.group(1))] if m else []


def condition(macro):
    """Droit demande : ('ADMIN'), ('FINM'), ('M', module), ou None si la consultation suffit."""
    if macro in EXCEPTIONS:
        return EXCEPTIONS[macro]
    m = re.search(r"(?ms)^Public Sub %s\(\)(.*?)^End Sub" % macro, VBA)
    req = re.search(r"RequireEdit\((\w+)\)", m.group(1)) if m else None
    return ("M", MODULE_FEUILLE[req.group(1)]) if req else None


def permis(macro, role):
    c = condition(macro)
    if c is None:
        return True
    if c == "ADMIN":
        return role == "ADMIN"
    if isinstance(c, str):
        return any((p == "FINM" and DROITS["FINANCES"][role] == "M") or (p == "PATM" and DROITS["PATRIMOINE"][role] == "M")
                   for p in c.split("|"))
    return DROITS[c[1]][role] == "M"


def fiches_admin():
    """n° de fiche -> (definition, {bouton: effet}, texte complet de la fiche)"""
    md = open(os.path.join(ROOT, "docs", "guide_menu_admin.md"), encoding="utf-8").read()
    res = {}
    for m in re.finditer(r"(?ms)^## (\d+\.\d+) (.*?)\n(.*?)(?=^## |^# |\Z)", md):
        num, corps = m.group(1), m.group(3)
        d = re.search(r"\*\*Définition\*\* : (.*)", corps)
        effets = {}
        for b, e in re.findall(r"^\| \*\*(.+?)\*\* \| (.+?) \|$", corps, re.M):
            effets[b] = e
        res[num] = (d.group(1) if d else "", effets, corps.strip())
    return md, res


def droit_txt(d):
    return {"M": "modifie", "L": "consulte"}.get(d, "–")


def chapitre_role(code, n, fiches):
    lbl, mission = ROLES_INFO[code]
    vis = [f for f in FONCTIONS if DROITS[f[2]][code] != "-"]
    nm = sum(1 for f in vis if DROITS[f[2]][code] == "M")
    out = ["# %d. %s" % (n, lbl), "",
           "**Mission dans l'application** : " + mission, "",
           "**Son menu** : %d fonctions, dont %d en modification et %d en consultation, plus les actions de l'accueil."
           % (len(vis), nm, len(vis) - nm), "",
           "## %d.1 Le menu du rôle" % n, "",
           "| Domaine | Fonctions modifiables | Fonctions en consultation |", "| %s | %s | %s |" % ("-" * 18, "-" * 41, "-" * 41)]
    for k, dom in DOMAINES:
        fs = [f for f in vis if f[1].split(".")[0] == k]
        if fs:
            mm = ", ".join(f[0] for f in fs if DROITS[f[2]][code] == "M") or "–"
            ll = ", ".join(f[0] for f in fs if DROITS[f[2]][code] == "L") or "–"
            out.append("| %s | %s | %s |" % (dom, mm, ll))
    absents = [f[0] for f in FONCTIONS if DROITS[f[2]][code] == "-"]
    if absents:
        out += ["", "**Absent de son menu** (feuilles masquées) : " + ", ".join(absents) + "."]
    out += ["", "## %d.2 Ce que le rôle peut faire, fonction par fonction" % n, ""]
    for f in vis:
        label, num, module, feuilles = f
        d = DROITS[module][code]
        definition, effets, _ = fiches[num]
        out += ["### %s" % label, "",
                "**Définition** : %s" % definition, "",
                "**Droit** : %s. Fiche complète : %s." % (droit_txt(d), num), ""]
        oui, non = [], []
        for c in feuilles:
            for b, macro in boutons_feuille(c):
                eff = effets.get(b) or EFFETS.get((c, b)) or EFFETS.get(b, "")
                if permis(macro, code):
                    note = NOTES.get(macro)
                    if note and not (DROITS[module][code] == "M" and (macro != "RetourMouvement" or DROITS["FINANCES"][code] == "M")):
                        eff = (eff + " " if eff else "") + "Limite : %s." % note
                    oui.append("**%s**%s" % (b, " : " + eff if eff else ""))
                else:
                    non.append(b)
        if feuilles and feuilles[0] in RAPPORTS:
            oui.append("Modifier les cases jaunes de réglage (date, période, exercice, matricule…) puis recalculer ; le reste de la feuille est calculé et verrouillé.")
        elif d == "M":
            oui.append("Saisir et corriger directement les cellules non verrouillées de la feuille (les colonnes calculées restent protégées).")
        else:
            oui.append("Consulter, filtrer et trier la feuille ; aucune cellule n'est modifiable.")
        # doublons (bouton present sur deux feuilles)
        vus, oui2 = set(), []
        for o in oui:
            if o not in vus:
                vus.add(o)
                oui2.append(o)
        out += ["**Vous pouvez** :", ""] + ["- " + o for o in oui2] + [""]
        if non:
            out += ["**Réservé à d'autres rôles** : " + ", ".join(dict.fromkeys(non)) + ".", ""]
    acts = ["**Actualiser les alertes** : recalcule les alertes du jour, limitées aux domaines du rôle."]
    if DROITS["MEMBRES"][code] == "M":
        acts.append("**Marquer les refroidis** : passe au statut « Refroidi » les membres absents depuis plus de 2 mois sans justification et ouvre leur dossier de discipline (art. 52).")
    acts += ["**Changer mon mot de passe** : remplace le mot de passe du rôle (l'ancien est demandé).",
             "**Sauvegarder une copie** : copie datée du fichier dans le sous-dossier « Sauvegardes ».",
             "**Se déconnecter** : masque toutes les feuilles et vide le tableau de bord."]
    out += ["## %d.3 Actions de l'accueil" % n, ""] + ["- " + a for a in acts] + [""]
    if code != "ADMIN":
        out += ["**Intérim** : pendant un intérim inscrit par l'Administrateur dans UTILISATEURS (art. 16), le rôle reçoit en plus les droits du rôle remplacé, entre les deux dates.", ""]
    return out


def matrice():
    codes = [c for c, _ in build.ROLES]
    out = ["| Fonction | " + " | ".join(codes) + " |", "| " + "-" * 22 + " |" + (" :" + "-" * 5 + ": |") * len(codes)]
    for label, num, module, _ in FONCTIONS:
        out.append("| %s %s | %s |" % (num, label, " | ".join(DROITS[module][c].replace("-", "–") for c in codes)))
    return out


def reference_docx(path):
    """Modele Word de pandoc, titres en vert de l'application."""
    data = subprocess.run(["pandoc", "--print-default-data-file", "reference.docx"], capture_output=True, check=True).stdout
    src = path + ".src"
    open(src, "wb").write(data)
    zin, zout = zipfile.ZipFile(src), zipfile.ZipFile(path, "w", zipfile.ZIP_DEFLATED)
    for it in zin.infolist():
        b = zin.read(it.filename)
        if it.filename == "word/styles.xml":
            s = b.decode("utf-8")
            s = re.sub(r'w:color w:val="[0-9A-Fa-f]{6}"', 'w:color w:val="1E7B4A"', s)
            s = re.sub(r"<w:rFonts [^>]*/>", '<w:rFonts w:ascii="Calibri" w:hAnsi="Calibri" w:eastAsia="Calibri" w:cs="Calibri"/>', s)
            b = s.encode("utf-8")
        zout.writestr(it, b)
    zout.close()
    os.remove(src)


def main():
    admin_md, fiches = fiches_admin()
    somm = ["**Sommaire**", "", "- Comment lire ce guide", "- Partie A : les rôles et leurs droits",
            "- Partie B : le menu de chaque rôle"]
    somm += ["    - %d\\. %s" % (i, ROLES_INFO[c][0]) for i, (c, _) in enumerate(build.ROLES, 1)]
    somm += ["- Partie C : les fiches complètes des fonctions",
             "    - C.1 Pilotage et rapports (1.1 à 1.4)", "    - C.2 Secrétariat (2.1 à 2.10)",
             "    - C.3 Patrimoine (3.1 à 3.6)", "    - C.4 Finances (4.1 à 4.9)", "    - C.5 Vie du groupe (5.1 à 5.8)",
             "    - C.6 Paramétrage et sécurité (6.1 à 6.10)", "    - C.7 Actions de l'accueil (7.1 à 7.5)", ""]
    lignes = somm + ["# Comment lire ce guide", "",
              "Ce guide décrit le menu de **chacun des 10 rôles** de l'application Excel **Gestion Chorale** (version 1.4.0, lot 5) et, pour chaque fonction de ce menu, ce que le rôle peut et ne peut pas faire.", "",
              "Il comprend trois parties :", "",
              "- **Partie A** : la vue d'ensemble des rôles et le tableau des droits ;",
              "- **Partie B** : un chapitre par rôle, avec son menu, puis chaque fonction : définition, droit, boutons utilisables avec leur effet, boutons réservés à d'autres rôles ;",
              "- **Partie C** : les **fiches complètes** des 52 fonctions (définition, boutons, marche à suivre, contrôles automatiques, règlement). Les chapitres des rôles y renvoient par leur numéro.", "",
              "Les droits décrits sont ceux de la feuille DROITS livrée ; l'Administrateur peut les adapter. Les actions permises ont été relevées dans le code de chaque bouton.", "",
              "# Partie A : les rôles et leurs droits", "",
              "## Les 10 rôles", "",
              "| Code | Rôle | Mission dans l'application | Fonctions du menu |", "| %s | %s | %s | %s |" % ("-" * 8, "-" * 18, "-" * 56, "-" * 18)]
    for code, _ in build.ROLES:
        lbl, mission = ROLES_INFO[code]
        vis = [f for f in FONCTIONS if DROITS[f[2]][code] != "-"]
        nm = sum(1 for f in vis if DROITS[f[2]][code] == "M")
        lignes.append("| %s | %s | %s | %d (%d en modification) |" % (code, lbl, mission, len(vis), nm))
    lignes += ["", "## Tableau des droits par fonction", "",
               "M = consulte et modifie ; L = consulte seulement ; – = absent du menu, feuille masquée.", ""] + matrice()
    lignes += ["", "**Règles communes** :", "",
               "- Chaque rôle se connecte avec son propre mot de passe (provisoire : `chorale`, à changer à la première connexion).",
               "- Un bouton réservé reste visible sur une feuille consultée, mais affiche « Consultation seulement » s'il est utilisé.",
               "- Les encaissements et les versements d'argent demandent toujours le droit de modifier les finances.",
               "- Toute action est inscrite au journal des actions.", "",
               "# Partie B : le menu de chaque rôle", ""]
    for n, (code, _) in enumerate(build.ROLES, 1):
        lignes += chapitre_role(code, n, fiches)
    # Partie C : fiches completes (sans l'introduction ni le menu de l'administrateur)
    c = admin_md[admin_md.index("# 1. Pilotage et rapports"):admin_md.index("# Annexe")]
    c = c.replace("](CAP/", "](%s/" % CAP)
    c = re.sub(r"(?m)^# (\d)\. ", r"# C.\1 ", c)
    c = c.replace("| --- | --- | --- |\n", "| %s | %s | %s |\n" % ("-" * 24, "-" * 38, "-" * 38))
    c = c.replace("| --- | --- |\n", "| %s | %s |\n" % ("-" * 30, "-" * 70))
    lignes += ["# Partie C : les fiches complètes des fonctions", "",
               "Les fiches sont numérotées comme dans les chapitres des rôles (1.1 à 7.5). L'« Accès » de chaque fiche rappelle les rôles concernés.", "", c]
    md = "\n".join(lignes)
    tmp = tempfile.mkdtemp(prefix="guide_roles_")
    src = os.path.join(tmp, "g.md")
    open(src, "w", encoding="utf-8").write(md)
    ref = os.path.join(tmp, "ref.docx")
    reference_docx(ref)
    out = os.path.join(ROOT, "dist", "Guide_Menus_par_role.docx")
    subprocess.run(["pandoc", src, "-o", out, "--reference-doc", ref,
                    "--metadata", "title=Gestion Chorale - Le menu de chaque rôle",
                    "--metadata", "subtitle=Définition et possibilités de chaque fonction, rôle par rôle",
                    "--metadata", "lang=fr-FR"], check=True)
    print("OK", out)


if __name__ == "__main__":
    main()
