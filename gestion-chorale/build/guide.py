"""Assemble le guide complet (docs/guide_intro.md + GUIDE_LOT1..5.md + captures
docs/captures/*.png) en HTML avec pandoc, puis en PDF avec Chromium (build/pdf.js).
Usage : python3 build/guide.py  ->  dist/Guide_GestionChorale.pdf"""
import os
import re
import subprocess
import sys
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "build"))
import build  # noqa: E402

CAP = os.path.join(ROOT, "docs", "captures")
# (guide, titre de section apres lequel inserer, image, legende)
FIGURES = [
    (1, "## 3. Mise en route du modèle vierge", "membres.png", "Feuille MEMBRES (version de démonstration)"),
    (1, "### Pointer une séance (Secrétariat)", "pointage.png", "Pointage d'une séance"),
    (1, "### Taux de participation", "taux.png", "Taux de participation par membre"),
    (2, "## 2. Enregistrer une opération (Secrétaire aux Finances)", "saisie_caisse.png", "Saisie d'une opération de caisse"),
    (2, "## 3. Cotisations et pénalités", "cotisations.png", "Situation des cotisations par membre"),
    (2, "## 5. Suivi du budget, écarts et variations", "suivi_budget.png", "Suivi budgétaire : prévu, réalisé, écarts"),
    (3, "## 1. Mise en route", "patrimoine.png", "Inventaire du patrimoine"),
    (3, "## 6. Synthèse pour l'AG", "synthese_pat.png", "Synthèse du patrimoine"),
    (4, "### Notification (art. 49)", "notification.png", "Lettre de notification d'une sanction"),
    (4, "## 3. Planning des activités (feuille PLANNING)", "programme_annuel.png", "Programme annuel des activités"),
    (4, "### Programmes des chants (feuille PROGRAMMES)", "programme_chants.png", "Programme des chants d'une célébration"),
    (5, "## 1. Tableau de bord (feuille TABLEAU_BORD)", "tableau_bord.png", "Tableau de bord (rôle Administrateur)"),
    (5, "### Rapport annuel pour l'AG", "rapport_ag.png", "Début du rapport annuel pour l'AG"),
    (5, "### Point financier du mois", "point_mensuel.png", "Point financier du mois"),
    (5, "### Livre de caisse", "livre_caisse.png", "Livre de caisse"),
    (5, "### Fiche d'un membre", "fiche_membre.png", "Fiche individuelle d'un membre"),
    (5, "### Pupitres et commissions", "rapport_pupitres.png", "Assiduité et maîtrise des cantiques par pupitre et par commission"),
]
TITRES = {1: "Démarrage et secrétariat", 2: "Finances", 3: "Patrimoine", 4: "Vie du groupe", 5: "Tableau de bord et rapports"}


def matrice_droits():
    codes = [c for c, _ in build.ROLES]
    lignes = ["| Module | " + " | ".join(codes) + " |", "| --- |" + " :---: |" * len(codes)]
    for m, desc, v in build.DROITS:
        desc = re.sub(r"\s*\(lot \d\)", "", desc)
        lignes.append("| %s | %s |" % (desc, " | ".join("–" if x == "-" else x for x in v.split())))
    lignes.append("")
    lignes.append("Codes des rôles : " + " ; ".join("**%s** %s" % (c, l) for c, l in build.ROLES) + ".")
    return "\n".join(lignes)


def section_suivante(txt, debut):
    """Supprime la section ## qui commence par `debut` (jusqu'a la section ## suivante)."""
    return re.sub(r"(?ms)^%s.*?(?=^## |\Z)" % re.escape(debut), "", txt)


def lot(n):
    txt = open(os.path.join(ROOT, "GUIDE_LOT%d.md" % n), encoding="utf-8").read()
    txt = re.sub(r"(?m)^# .*$", "# %d. %s" % (n, TITRES[n]), txt, count=1)
    txt = section_suivante(txt, "## 0. Passer")
    txt = re.sub(r"\[([^\]]+)\]\(GUIDE_LOT\d\.md\)", r"\1", txt)
    txt = re.sub(r" ?(?:Tout ce qui existait au lot 1 est conservé|Les lots [^.]*sont conservés) \([^)]*\)\.", "", txt)
    txt = re.sub(r"Le \*\*guide complet\*\*.*?\.pdf`\.", "", txt)
    if n == 1:
        txt = section_suivante(txt, "## 6. Ce qui arrive")
        txt = re.sub(r"(?ms)^\| Rôle \| Voit et modifie.*?\n\n",
                     "Le tableau complet des droits figure dans la présentation, au chapitre « Rôles et droits ».\n\n", txt)
    for g, titre, img, leg in FIGURES:
        p = os.path.join(CAP, img)
        if g == n and os.path.exists(p):
            assert titre in txt, titre
            txt = txt.replace(titre + "\n", "%s\n\n![%s](%s)\n" % (titre, leg, p), 1)
    return txt


def main():
    intro = open(os.path.join(ROOT, "docs", "guide_intro.md"), encoding="utf-8").read()
    intro = intro.replace("<!-- DROITS -->", matrice_droits())
    md = intro + "\n\n" + "\n\n".join(lot(n) for n in range(1, 6))
    tmp = tempfile.mkdtemp(prefix="guide_chorale_")
    src = os.path.join(tmp, "guide.md")
    html = os.path.join(tmp, "guide.html")
    open(src, "w", encoding="utf-8").write(md)
    subprocess.run(["pandoc", src, "-o", html, "--standalone", "--embed-resources", "--toc", "--toc-depth=2",
                    "--metadata", "title=Gestion Chorale",
                    "--metadata", "subtitle=Guide complet de l'utilisateur - version %s" % build_version(),
                    "--metadata", "lang=fr", "--metadata", "toc-title=Sommaire",
                    "--css", os.path.join(ROOT, "docs", "guide.css")], check=True)
    pdf = os.path.join(ROOT, "dist", "Guide_GestionChorale.pdf")
    subprocess.run(["node", os.path.join(ROOT, "build", "pdf.js"), html, pdf], check=True)
    print("OK", pdf)


def build_version():
    src = open(os.path.join(ROOT, "src", "vba", "modConfig.bas"), encoding="utf-8").read()
    return re.search(r'APP_VERSION As String = "([^"]+)"', src).group(1)


if __name__ == "__main__":
    main()
