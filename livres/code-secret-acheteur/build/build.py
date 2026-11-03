#!/usr/bin/env python3
"""Construit le livre (DOCX + PDF) à partir des chapitres Markdown.

Usage : python3 build.py
Sorties : ../sortie/Le-Code-Secret-de-l-Acheteur.docx et .pdf
"""
import glob
import os
import subprocess
import sys

from docx import Document
from docx.enum.style import WD_STYLE_TYPE
from docx.enum.text import WD_ALIGN_PARAGRAPH, WD_BREAK, WD_TAB_ALIGNMENT, WD_TAB_LEADER
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.shared import Inches, Pt, RGBColor

ICI = os.path.dirname(os.path.abspath(__file__))
RACINE = os.path.dirname(ICI)
CHAPITRES = os.path.join(RACINE, "chapitres")
SORTIE = os.path.join(RACINE, "sortie")
REF = os.path.join(ICI, "reference.docx")
VERSION = os.environ.get("VERSION", "lecture")  # "lecture" ou "impression"
NOM = "Le-Code-Secret-de-l-Acheteur" + ("-interieur-impression" if VERSION == "impression" else "")

# Réglages typographiques (ajustables pour viser 127 pages)
TAILLE_CORPS = float(os.environ.get("TAILLE_CORPS", "11"))
INTERLIGNE = float(os.environ.get("INTERLIGNE", "1.1"))
# Garamond : police de référence de l'édition (EB Garamond sert au rendu PDF)
POLICE = "Garamond"
POLICE_TITRES = "Garamond"
# Palette noir et gris, assortie à la couverture
BLEU = RGBColor(0x11, 0x11, 0x11)
OR = RGBColor(0x55, 0x55, 0x55)


def ombrage(par_format_element, couleur):
    shd = OxmlElement("w:shd")
    shd.set(qn("w:val"), "clear")
    shd.set(qn("w:color"), "auto")
    shd.set(qn("w:fill"), couleur)
    par_format_element.append(shd)


def bordure_gauche(ppr, couleur="222222", taille="18"):
    pbdr = OxmlElement("w:pBdr")
    for cote in ("left",):
        b = OxmlElement(f"w:{cote}")
        b.set(qn("w:val"), "single")
        b.set(qn("w:sz"), taille)
        b.set(qn("w:space"), "8")
        b.set(qn("w:color"), couleur)
        pbdr.append(b)
    ppr.append(pbdr)


def style_par(doc, nom, base="Normal"):
    styles = {x.name: x for x in doc.styles}
    if nom in styles:
        st = styles[nom]
    else:
        st = doc.styles.add_style(nom, WD_STYLE_TYPE.PARAGRAPH)
    st.base_style = styles[base]
    return st


def regle(st, taille=None, gras=None, italique=None, couleur=None, police=None,
          align=None, avant=None, apres=None, saut_avant=None, garder=None):
    f = st.font
    if taille:
        f.size = Pt(taille)
    if gras is not None:
        f.bold = gras
    if italique is not None:
        f.italic = italique
    if couleur is not None:
        f.color.rgb = couleur
    if police:
        f.name = police
        rpr = st.element.get_or_add_rPr()
        rfonts = rpr.find(qn("w:rFonts"))
        if rfonts is None:
            rfonts = OxmlElement("w:rFonts")
            rpr.append(rfonts)
        for a in ("w:ascii", "w:hAnsi", "w:cs", "w:eastAsia"):
            rfonts.set(qn(a), police)
        for a in ("w:asciiTheme", "w:hAnsiTheme", "w:cstheme", "w:eastAsiaTheme"):
            if rfonts.get(qn(a)) is not None:
                del rfonts.attrib[qn(a)]
    pf = st.paragraph_format
    if align is not None:
        pf.alignment = align
    if avant is not None:
        pf.space_before = Pt(avant)
    if apres is not None:
        pf.space_after = Pt(apres)
    if saut_avant is not None:
        pf.page_break_before = saut_avant
    if garder is not None:
        pf.keep_with_next = garder


def construire_reference():
    with open(REF, "wb") as f:
        subprocess.run(["pandoc", "--print-default-data-file",
                        "reference.docx"], stdout=f, check=True)
    doc = Document(REF)

    # Format de page 15,24 x 22,86 cm (6 x 9 pouces), marges miroir
    for s in doc.sections:
        s.page_width = Inches(6)
        s.page_height = Inches(9)
        s.top_margin = Inches(0.7)
        s.bottom_margin = Inches(0.7)
        s.left_margin = Inches(0.75)   # intérieur
        s.right_margin = Inches(0.55)  # extérieur
        s.gutter = Inches(0)
        s.header_distance = Inches(0.35)
        s.footer_distance = Inches(0.35)
        # pied de page : numéro centré
        footer = s.footer
        p = footer.paragraphs[0] if footer.paragraphs else footer.add_paragraph()
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        run = p.add_run()
        for typ, txt in (("begin", None), (None, "PAGE"), ("end", None)):
            if typ:
                fc = OxmlElement("w:fldChar")
                fc.set(qn("w:fldCharType"), typ)
                run._r.append(fc)
            else:
                it = OxmlElement("w:instrText")
                it.set(qn("xml:space"), "preserve")
                it.text = txt
                run._r.append(it)
        run.font.size = Pt(9)
    settings = doc.settings.element
    mm = OxmlElement("w:mirrorMargins")
    settings.insert(0, mm)

    st = {x.name: x for x in doc.styles}
    # Corps de texte
    for nom in ("Normal", "Body Text", "First Paragraph", "Compact"):
        if nom in st:
            regle(st[nom], taille=TAILLE_CORPS, police=POLICE,
                  align=WD_ALIGN_PARAGRAPH.JUSTIFY, avant=0, apres=5)
            st[nom].paragraph_format.line_spacing = INTERLIGNE
            st[nom].font.color.rgb = RGBColor(0x1A, 0x1A, 0x1A)
    if "Compact" in st:
        regle(st["Compact"], apres=2, align=WD_ALIGN_PARAGRAPH.LEFT)

    regle(st["Heading 1"], taille=19, gras=True, couleur=BLEU,
          police=POLICE_TITRES, align=WD_ALIGN_PARAGRAPH.LEFT, avant=36,
          apres=18, saut_avant=True, garder=True)
    regle(st["Heading 2"], taille=13, gras=True, couleur=BLEU,
          police=POLICE_TITRES, avant=12, apres=5, garder=True)
    regle(st["Heading 3"], taille=11, gras=True, couleur=OR,
          police=POLICE_TITRES, avant=8, apres=3, garder=True)
    for h in ("Heading 1", "Heading 2", "Heading 3"):
        st[h].font.italic = False

    # Citation
    if "Block Text" in st:
        regle(st["Block Text"], taille=TAILLE_CORPS, italique=True,
              police=POLICE, avant=4, apres=8)
        st["Block Text"].paragraph_format.left_indent = Inches(0.3)
        st["Block Text"].paragraph_format.right_indent = Inches(0.2)
        bordure_gauche(st["Block Text"].element.get_or_add_pPr(), "555555", "12")

    # Styles personnalisés
    s = style_par(doc, "TitreLivre")
    regle(s, taille=28, gras=True, couleur=BLEU, police=POLICE_TITRES,
          align=WD_ALIGN_PARAGRAPH.CENTER, avant=120, apres=24)
    s = style_par(doc, "SousTitreLivre")
    regle(s, taille=14, italique=True, couleur=OR, police=POLICE_TITRES,
          align=WD_ALIGN_PARAGRAPH.CENTER, avant=0, apres=10)
    s = style_par(doc, "AuteurLivre")
    regle(s, taille=16, gras=True, couleur=BLEU, police=POLICE_TITRES,
          align=WD_ALIGN_PARAGRAPH.CENTER, avant=90, apres=6)
    s = style_par(doc, "EditeurLivre")
    regle(s, taille=11, couleur=OR, police=POLICE_TITRES,
          align=WD_ALIGN_PARAGRAPH.CENTER, avant=6, apres=6)
    s = style_par(doc, "Mentions")
    regle(s, taille=8.5, police=POLICE, align=WD_ALIGN_PARAGRAPH.LEFT,
          avant=0, apres=6)
    s = style_par(doc, "Epigraphe")
    regle(s, taille=13, italique=True, couleur=BLEU, police=POLICE,
          align=WD_ALIGN_PARAGRAPH.CENTER, avant=150, apres=18)
    s = style_par(doc, "EpigrapheSource")
    regle(s, taille=10, couleur=OR, police=POLICE,
          align=WD_ALIGN_PARAGRAPH.CENTER, avant=0, apres=0)
    s = style_par(doc, "TitreSommaire")
    regle(s, taille=19, gras=True, couleur=BLEU, police=POLICE_TITRES,
          align=WD_ALIGN_PARAGRAPH.LEFT, avant=18, apres=12)
    s = style_par(doc, "Sommaire")
    regle(s, taille=10.5, police=POLICE, align=WD_ALIGN_PARAGRAPH.LEFT,
          avant=0, apres=float(os.environ.get("SOMMAIRE_APRES", "9")))
    s = style_par(doc, "Signature")
    regle(s, taille=TAILLE_CORPS, italique=True, couleur=BLEU, police=POLICE,
          align=WD_ALIGN_PARAGRAPH.RIGHT, avant=10, apres=2)
    s = style_par(doc, "IntroPartie")
    regle(s, taille=12, italique=True, couleur=BLEU, police=POLICE,
          align=WD_ALIGN_PARAGRAPH.JUSTIFY, avant=60, apres=8)
    s.paragraph_format.line_spacing = 1.3
    s = style_par(doc, "Encadre")
    regle(s, taille=TAILLE_CORPS - 0.5, police=POLICE,
          align=WD_ALIGN_PARAGRAPH.LEFT, avant=3, apres=3)
    # Encadré sobre : simple cadre fin sur les quatre côtés, sans fond
    s.paragraph_format.left_indent = Inches(0.1)
    s.paragraph_format.right_indent = Inches(0.1)
    ppr = s.element.get_or_add_pPr()
    cadre = OxmlElement("w:pBdr")
    for cote in ("top", "left", "bottom", "right"):
        b = OxmlElement(f"w:{cote}")
        b.set(qn("w:val"), "single")
        b.set(qn("w:sz"), "6")
        b.set(qn("w:space"), "6")
        b.set(qn("w:color"), "333333")
        cadre.append(b)
    ppr.append(cadre)

    # Tableaux : police un peu plus petite
    s = style_par(doc, "Table")  # pandoc applique ce nom au tableau
    doc.save(REF)


def assembler():
    fichiers = sorted(glob.glob(os.path.join(CHAPITRES, "*.md")))
    os.makedirs(SORTIE, exist_ok=True)
    docx_out = os.path.join(SORTIE, NOM + ".docx")
    subprocess.run(["pandoc", *fichiers, "-f",
                    "markdown+task_lists+pipe_tables+fenced_divs+raw_attribute",
                    "-t", "docx", "--reference-doc", REF, "-o", docx_out,
                    "--metadata", "lang=fr-FR",
                    "--metadata", "title=Le Code Secret de l'Acheteur"],
                   check=True)
    post_traiter(docx_out)
    subprocess.run(["soffice", "--headless", "--convert-to", "pdf",
                    "--outdir", SORTIE, docx_out], check=True,
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    pdf = os.path.join(SORTIE, NOM + ".pdf")
    r = subprocess.run(["pdfinfo", pdf], capture_output=True, text=True)
    pages = [l for l in r.stdout.splitlines() if l.startswith("Pages")]
    print(pages[0] if pages else r.stdout)
    return pdf


def norm(x):
    import unicodedata
    x = x.replace("’", "'").replace("*", "")
    return "".join(c for c in unicodedata.normalize("NFKD", x) if c.isalnum()).lower()


def maj_sommaire(pdf):
    """Recalcule les numéros de page du sommaire. Renvoie True si modifié."""
    n = int([l for l in subprocess.run(["pdfinfo", pdf], capture_output=True, text=True)
             .stdout.splitlines() if l.startswith("Pages")][0].split()[-1])
    debuts = {}
    for p in range(6, n + 1):
        txt = subprocess.run(["pdftotext", "-f", str(p), "-l", str(p), pdf, "-"],
                             capture_output=True, text=True).stdout
        debuts[p] = norm(" ".join(txt.split("\n")[:4]))
    f = os.path.join(CHAPITRES, "00-liminaires.md")
    lignes = open(f).read().split("\n")
    modifie = False
    for k, l in enumerate(lignes):
        if "¤" not in l:
            continue
        titre, ancien = l.rsplit("¤", 1)
        cle = norm(titre)[:30]
        trouve = [p for p, d in debuts.items() if d.startswith(cle)]
        if trouve and str(trouve[0]) != ancien:
            lignes[k] = f"{titre}¤{trouve[0]}"
            modifie = True
    if modifie:
        open(f, "w").write("\n".join(lignes))
    return modifie


def inserer_couverture(doc):
    """Place la couverture en pleine page (page 1), dans sa propre section."""
    from copy import deepcopy
    couv = os.path.join(RACINE, "images", "couverture.jpg")
    body = doc.element.body
    if VERSION == "impression":
        inserer_page_titre(doc)
        return
    if not os.path.exists(couv):
        return
    p = doc.add_paragraph()
    p.add_run().add_picture(couv, width=Inches(6), height=Inches(9))
    pf = p.paragraph_format
    pf.space_before = Pt(0)
    pf.space_after = Pt(0)
    pf.line_spacing = 1.0
    pf.alignment = WD_ALIGN_PARAGRAPH.LEFT
    body.remove(p._p)
    body.insert(0, p._p)
    sect = deepcopy(body.sectPr)
    for enfant in list(sect):
        if enfant.tag in (qn("w:headerReference"), qn("w:footerReference"),
                          qn("w:titlePg")):
            sect.remove(enfant)
    marges = sect.find(qn("w:pgMar"))
    for attr in ("w:top", "w:bottom", "w:left", "w:right", "w:header",
                 "w:footer", "w:gutter"):
        marges.set(qn(attr), "0")
    p._p.get_or_add_pPr().append(sect)


def inserer_page_titre(doc):
    """Version imprimeur : page de titre sobre à la place de la couverture."""
    body = doc.element.body
    elements = [
        ("TitreLivre", "Le Code Secret de l’Acheteur"),
        ("SousTitreLivre", "Mieux vendre grâce à la psychologie comportementale"),
        ("AuteurLivre", "Rodriguez MOKHASSA"),
        ("EditeurLivre", "STFC Éditions"),
    ]
    paras = []
    for style, texte in elements:
        p = doc.add_paragraph(texte, style=style)
        paras.append(p._p)
    saut = doc.add_paragraph()
    saut.add_run().add_break(WD_BREAK.PAGE)
    paras.append(saut._p)
    for i, el in enumerate(paras):
        body.remove(el)
        body.insert(i, el)


def post_traiter(chemin):
    """Ajuste les tableaux (taille, bordures) et retire le titre pandoc."""
    doc = Document(chemin)
    body = doc.element.body
    # supprimer le bloc titre ajouté par pandoc (style Title)
    for p in list(doc.paragraphs):
        if p.style.name in ("Title",):
            p._element.getparent().remove(p._element)
    for p in doc.paragraphs:
        if "¤" in p.text:
            p.paragraph_format.tab_stops.add_tab_stop(
                Inches(4.7), WD_TAB_ALIGNMENT.RIGHT, WD_TAB_LEADER.DOTS)
            for r in p.runs:
                if "¤" in r.text:
                    r.text = r.text.replace("¤", "\t")
        if "……" in p.text:
            p.paragraph_format.alignment = WD_ALIGN_PARAGRAPH.LEFT
    for t in doc.tables:
        precedent = t._tbl.getprevious()
        if precedent is not None and precedent.tag == qn("w:p"):
            from docx.text.paragraph import Paragraph
            pp = Paragraph(precedent, doc._body)
            if len(pp.text) < 160:
                pp.paragraph_format.keep_with_next = True
        suivant = t._tbl.getnext()
        if suivant is not None and suivant.tag == qn("w:p"):
            from docx.text.paragraph import Paragraph
            Paragraph(suivant, doc._body).paragraph_format.space_before = Pt(8)
        tblpr = t._tbl.tblPr
        borders = OxmlElement("w:tblBorders")
        for cote in ("top", "left", "bottom", "right", "insideH", "insideV"):
            b = OxmlElement(f"w:{cote}")
            b.set(qn("w:val"), "single")
            b.set(qn("w:sz"), "4")
            b.set(qn("w:color"), "8C8C8C")
            borders.append(b)
        tblpr.append(borders)
        tblw = tblpr.find(qn("w:tblW"))
        if tblw is None:
            tblw = OxmlElement("w:tblW")
            tblpr.append(tblw)
        tblw.set(qn("w:type"), "pct")
        tblw.set(qn("w:w"), "5000")
        # Ne jamais couper un tableau sur deux pages
        nb = len(t.rows)
        for i, row in enumerate(t.rows):
            trpr = row._tr.get_or_add_trPr()
            trpr.append(OxmlElement("w:cantSplit"))
            for cell in row.cells:
                for p in cell.paragraphs:
                    p.paragraph_format.keep_together = True
                    if i < nb - 1:
                        p.paragraph_format.keep_with_next = True
                if i == 0:
                    tcpr = cell._tc.get_or_add_tcPr()
                    ombrage(tcpr, "1A1A1A")
                for p in cell.paragraphs:
                    p.paragraph_format.alignment = WD_ALIGN_PARAGRAPH.LEFT
                    p.paragraph_format.space_after = Pt(1)
                    p.paragraph_format.line_spacing = 1.0
                    for r in p.runs:
                        r.font.size = Pt(TAILLE_CORPS - 2)
                        if i == 0:
                            r.font.bold = True
                            r.font.color.rgb = RGBColor(0xFF, 0xFF, 0xFF)
    inserer_couverture(doc)
    doc.save(chemin)


if __name__ == "__main__":
    construire_reference()
    pdf = assembler()
    if VERSION == "lecture":
        if maj_sommaire(pdf):
            print("Sommaire mis à jour, seconde passe")
            assembler()
        # Version imprimeur (page de titre au lieu de la couverture)
        subprocess.run([sys.executable, __file__], env={**os.environ, "VERSION": "impression"}, check=True)
