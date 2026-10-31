"""Guide du menu Administrateur : docs/guide_menu_admin.md -> dist/Guide_Menu_Administrateur.pdf
(pandoc + Chromium, comme build/guide.py)."""
import os
import re
import subprocess
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CAP = os.path.join(ROOT, "docs", "captures")

# Menu de l'Administrateur, dans l'ordre de BuildHome (modInterface.bas) : (libelle, famille)
MENU = [("Tableau de bord", "r"), ("Rapport pour l'AG", "r"), ("Point financier du mois", "r"), ("Livre de caisse", "r"),
        ("Membres", "s"), ("Fiche d'un membre", "s"), ("Nouveaux choristes", "s"), ("Calendrier des séances", "s"),
        ("Pointage d'une séance", "s"), ("Historique des présences", "s"), ("Taux de participation", "s"),
        ("Pupitres et commissions", "s"), ("Fiche d'appel", "s"), ("Liste électorale", "s"),
        ("Patrimoine", "p"), ("Prêts et mouvements", "p"), ("Locations de matériel", "p"), ("Inventaire physique", "p"),
        ("Synthèse du patrimoine", "p"), ("Étiquettes", "p"),
        ("Saisie de caisse", "f"), ("Journal de caisse", "f"), ("Cotisations", "f"), ("Cotisations spéciales", "f"),
        ("Caisse sociale", "f"), ("Budget", "f"), ("Suivi budgétaire", "f"), ("Arrêté de caisse", "f"),
        ("Pertes et remboursements", "f"),
        ("Discipline", "v"), ("Planning des activités", "v"), ("Programme annuel", "v"), ("Mandats", "v"),
        ("Élections", "v"), ("Répertoire des cantiques", "v"), ("Programmes des chants", "v"), ("Études bibliques", "v"),
        ("Paramètres", "c"), ("Listes de choix", "c"), ("Types d'activités", "c"), ("Codes de présence", "c"),
        ("Contrôles d'adhésion", "c"), ("Rubriques budgétaires", "c"), ("Barème social", "c"),
        ("Catégories du patrimoine", "c"), ("Utilisateurs", "c"), ("Journal des actions", "c")]
ACTIONS = ["Actualiser les alertes", "Marquer les refroidis", "Changer mon mot de passe", "Sauvegarder une copie",
           "Se déconnecter"]
FAMILLES = {"r": ("Pilotage et rapports", "#14532d"), "s": ("Secrétariat", "#1E7B4A"), "p": ("Patrimoine", "#2f855a"),
            "f": ("Finances", "#276749"), "v": ("Vie du groupe", "#38a169"), "c": ("Paramétrage et sécurité", "#4a5568")}


def grille():
    cell = ('<td style="background:%s;color:#fff;font-weight:600;font-size:8.5pt;text-align:center;'
            'padding:2.2mm 1mm;border:2px solid #fff;border-radius:4px">%s</td>')
    items = [cell % (FAMILLES[f][1], l) for l, f in MENU]
    while len(items) % 4:
        items.append("<td></td>")
    items += [cell % ("#C8102E" if a == "Se déconnecter" else "#5a5a5a", a) for a in ACTIONS]
    rows = ["<tr>%s</tr>" % "".join(items[i:i + 4]) for i in range(0, len(items), 4)]
    legende = " ".join('<span style="display:inline-block;background:%s;color:#fff;padding:0.6mm 2mm;margin:0.5mm;'
                       'border-radius:3px;font-size:8pt">%s</span>' % (c, n) for n, c in FAMILLES.values())
    legende += (' <span style="display:inline-block;background:#5a5a5a;color:#fff;padding:0.6mm 2mm;margin:0.5mm;'
                'border-radius:3px;font-size:8pt">Actions de l\'accueil</span>')
    return ('<table class="menu" style="table-layout:fixed">%s</table>\n\n<p>%s</p>\n\n'
            '<p><em>52 boutons : 47 fonctions (4 par ligne, dans l\'ordre de l\'accueil) et 5 actions.</em></p>'
            % ("".join(rows), legende))


def main():
    md = open(os.path.join(ROOT, "docs", "guide_menu_admin.md"), encoding="utf-8").read()
    md = md.replace("<!-- MENU -->", grille()).replace("](CAP/", "](%s/" % CAP)
    tmp = tempfile.mkdtemp(prefix="guide_menu_")
    src, html = os.path.join(tmp, "g.md"), os.path.join(tmp, "g.html")
    open(src, "w", encoding="utf-8").write(md)
    version = re.search(r'APP_VERSION As String = "([^"]+)"',
                        open(os.path.join(ROOT, "src", "vba", "modConfig.bas"), encoding="utf-8").read()).group(1)
    subprocess.run(["pandoc", src, "-o", html, "--standalone", "--embed-resources", "--toc", "--toc-depth=2",
                    "--metadata", "title=Gestion Chorale",
                    "--metadata", "subtitle=Le menu de l'Administrateur, fonction par fonction - version %s" % version,
                    "--metadata", "lang=fr", "--metadata", "toc-title=Sommaire",
                    "--css", os.path.join(ROOT, "docs", "guide.css")], check=True)
    pdf = os.path.join(ROOT, "dist", "Guide_Menu_Administrateur.pdf")
    subprocess.run(["node", os.path.join(ROOT, "build", "pdf.js"), html, pdf, "menu de l'Administrateur"], check=True)
    print("OK", pdf)


if __name__ == "__main__":
    main()
