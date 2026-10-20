"""Génère toute la documentation dans `sortie/`.

    python3 generateur/build.py            # tout
    python3 generateur/build.py --pdf      # PDF seulement
    python3 generateur/build.py --debut 51 --taille 50   # carnets numérotés 0051 à 0100
"""
import argparse
import shutil
import sys

from pypdf import PdfWriter

import affiches as A
import formulaires as F
from brand import doc
from config import CARNET_DEBUT, CARNET_TAILLE
from render import ROOT, BUILD, HTML_OUT, portable, to_pdf

OUT = ROOT / "sortie"


def page(title, body, size="A4 portrait"):
    return doc(title, body, F.CSS, size)


# (fichier, titre, rendu d'une page vierge, rendu numéroté (numéros) ou None)
FORMULAIRES = [
    ("01_Recu_de_caisse", "Reçu de caisse",
     lambda: F.pages_slots(F.recu, [None] * 3, 3), lambda ns: F.pages_slots(F.recu, ns, 3)),
    ("02_Addition_de_table", "Addition",
     lambda: F.pages_colonnes(F.note_table, [None] * 2), lambda ns: F.pages_colonnes(F.note_table, ns)),
    ("03_Facture", "Facture", lambda: F.facture(None), lambda ns: "".join(F.facture(n) for n in ns)),
    ("04_Piece_de_caisse_ENTREE", "Pièce de caisse entrée",
     lambda: F.pages_slots(F.piece_caisse("entree"), [None] * 2, 2),
     lambda ns: F.pages_slots(F.piece_caisse("entree"), ns, 2)),
    ("05_Piece_de_caisse_SORTIE", "Pièce de caisse sortie",
     lambda: F.pages_slots(F.piece_caisse("sortie"), [None] * 2, 2),
     lambda ns: F.pages_slots(F.piece_caisse("sortie"), ns, 2)),
    ("06_Brouillard_de_caisse", "Brouillard de caisse", F.brouillard, None),
    ("07_Cloture_de_caisse", "Clôture de caisse", F.cloture, None),
    ("08_Bordereau_de_versement", "Bordereau de versement",
     lambda: F.pages_slots(F.bordereau, [None] * 2, 2), lambda ns: F.pages_slots(F.bordereau, ns, 2)),
    ("09_Bon_de_commande", "Bon de commande", lambda: F.bon_commande(None),
     lambda ns: "".join(F.bon_commande(n) for n in ns)),
    ("10_Bon_de_reception", "Bon de réception", lambda: F.bon_reception(None), None),
    ("11_Fiche_de_stock", "Fiche de stock", F.fiche_stock, None),
    ("12_Inventaire_hebdomadaire", "Inventaire", F.inventaire, None),
    ("13_Registre_casses_pertes", "Casses et pertes", F.fiche_casse, None),
    ("14_Bon_de_sortie_interne", "Bon de sortie interne",
     lambda: F.pages_slots(F.bon_sortie_interne, [None] * 3, 3),
     lambda ns: F.pages_slots(F.bon_sortie_interne, ns, 3)),
    ("15_Registre_credits_clients", "Registre des crédits", F.registre_credits, None),
    ("16_Reconnaissance_de_dette", "Reconnaissance de dette", F.reconnaissance_dette, None),
    ("17_Planning_hebdomadaire", "Planning", F.planning, None),
    ("18_Fiche_de_presence", "Présence", F.presence, None),
    ("19_Bon_avance_sur_salaire", "Bon d'avance",
     lambda: F.pages_slots(F.bon_avance, [None] * 2, 2), lambda ns: F.pages_slots(F.bon_avance, ns, 2)),
    ("20_Fiche_de_paiement_salaire", "Fiche de paiement", F.fiche_paie, None),
    ("21_Tableau_de_bord_mensuel", "Tableau de bord", F.tableau_bord, None),
    ("00_Routine_de_gestion", "Routine de gestion", F.routine, None),
]

PAYSAGE = {"06", "12", "15", "17", "18", "21"}


def build_pdf(debut, taille):
    produits = []
    d_aff = OUT / "1_Affiches"
    produits.append(to_pdf(A.build(), d_aff / "Affiches_A4_paysage.pdf"))
    produits.append(to_pdf(A.build_coupons(), d_aff / "Coupons_Bon_pour_revenir_demain.pdf"))

    d_mod, d_car = OUT / "2_Modeles_vierges", OUT / "3_Carnets_numerotes"
    numeros = list(range(debut, debut + taille))
    for code, titre, vierge, numerote in sorted(FORMULAIRES):
        size = "A4 landscape" if code[:2] in PAYSAGE else "A4 portrait"
        p = to_pdf(page(titre, vierge(), size), d_mod / f"{code}.pdf")
        produits.append(p)
        if numerote:
            to_pdf(page(titre, numerote(numeros), size),
                   d_car / f"{code}_N{debut:04d}-{debut + taille - 1:04d}.pdf")
        print("  ✓", code)

    w = PdfWriter()
    for p in produits:
        w.append(str(p))
    w.write(str(OUT / "LIASSE_COMPLETE_La_Tendresse_de_Ketchup.pdf"))


SECTIONS = {"0_Propositions_branding": "Propositions de branding", "1_Affiches": "Affiches",
            "2_Modeles_vierges": "Formulaires (modèles vierges)"}


def build_index():
    """Page d'accueil des fichiers HTML, avec un lien vers chaque document."""
    blocs = ""
    for dossier, titre in SECTIONS.items():
        liens = "".join(f'<li><a href="{dossier}/{f.name}">{f.stem.replace("_", " ")}</a></li>'
                        for f in sorted((HTML_OUT / dossier).glob("*.html")))
        blocs += f"<h2>{titre}</h2><ul>{liens}</ul>"
    css = """html,body{background:#FFF4E2!important} body{max-width:760px;margin:0 auto;padding:24px 16px;background:#FFF4E2}
      h1{font-family:'Playfair';font-style:italic;font-size:28pt;color:#231A17}
      h2{font-family:'Bebas';font-weight:400;font-size:20pt;letter-spacing:.06em;color:#7E0A1E;margin-top:18px}
      ul{list-style:none;columns:2;column-gap:24px;font-size:11pt;line-height:2}
      a{color:#C8102E;text-decoration:none;font-weight:600} a:hover{text-decoration:underline}
      p{font-size:10pt;color:#5a4b46}
      @media (max-width:560px){ul{columns:1}}"""
    html = doc("Kit de gestion", f"<h1>La Tendresse de Ketchup — kit de gestion</h1>"
               f"<p>Ouvrir un document, puis Fichier &gt; Imprimer (format A4, marges : aucune, "
               f"graphiques d'arrière-plan activés).</p>{blocs}", css, "A4 portrait")
    (HTML_OUT / "index.html").write_text(portable(html), encoding="utf-8")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--pdf", action="store_true")
    ap.add_argument("--debut", type=int, default=CARNET_DEBUT)
    ap.add_argument("--taille", type=int, default=CARNET_TAILLE)
    a = ap.parse_args()
    if OUT.exists():
        shutil.rmtree(OUT)
    print("PDF + HTML…")
    import propositions_branding
    propositions_branding.build()
    build_pdf(a.debut, a.taille)
    build_index()
    if not a.pdf:
        import excel
        import word
        print("Excel…")
        excel.build(OUT / "4_Excel_pilotage")
        print("Word…")
        word.build(OUT / "5_Word_modifiables")
    from brand import logo
    (ROOT / "assets" / "logo_la_tendresse_de_ketchup.svg").write_text(logo().strip(), encoding="utf-8")
    shutil.rmtree(BUILD, ignore_errors=True)
    print("Terminé :", OUT)


if __name__ == "__main__":
    sys.exit(main())
