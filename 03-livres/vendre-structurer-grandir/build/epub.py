#!/usr/bin/env python3
"""Construit l'EPUB du livre à partir des chapitres Markdown.

Couverture : ../images/couverture.jpg ; 4e de couverture en dernière page.
Sortie : ../sortie/Vendre-structurer-grandir.epub
Polices EB Garamond intégrées si présentes dans ~/.fonts.
"""
import glob
import os
import subprocess
import tempfile

from PIL import Image

ICI = os.path.dirname(os.path.abspath(__file__))
RACINE = os.path.dirname(ICI)
SORTIE = os.path.join(RACINE, "sortie", "Vendre-structurer-grandir.epub")
FONTS = os.path.expanduser("~/.fonts")


def main():
    tmp = tempfile.mkdtemp()
    # images allégées pour liseuse (1600 x 2400 px)
    couv = os.path.join(tmp, "couverture.jpg")
    verso = os.path.join(tmp, "verso.jpg")
    for src, dst in (("couverture.jpg", couv), ("couverture-verso.jpg", verso)):
        Image.open(os.path.join(RACINE, "images", src)).convert("RGB") \
            .resize((1600, 2400), Image.LANCZOS).save(dst, quality=88, optimize=True)
    fin = os.path.join(tmp, "zz-verso.md")
    with open(fin, "w") as f:
        f.write('\n\n# Quatrième de couverture {.unlisted .unnumbered}\n\n'
                f'::: verso\n![Quatrième de couverture]({verso})\\ \n:::\n')
    meta = os.path.join(tmp, "meta.yaml")
    with open(meta, "w") as f:
        import json
        champs = {
            "title": "Vendre, structurer, grandir",
            "subtitle": "Les trois temps de l'entreprise qui réussit",
            "author": "Rodriguez MOKHASSA",
            "publisher": "STFC Éditions",
            "lang": "fr-FR",
            "rights": "© 2026 Rodriguez MOKHASSA et STFC Éditions. Tous droits réservés.",
            "subject": "Performance commerciale, gestion d'entreprise, PME",
            "description": "Les trois temps de l'entreprise qui réussit : vendre pour générer du cash, "
                           "structurer pour bâtir des fondations solides, grandir pour se développer durablement.",
            "toc-title": "Table des matières",
        }
        f.write("---\n" + "".join(f"{k}: {json.dumps(v, ensure_ascii=False)}\n" for k, v in champs.items()) + "---\n")
    polices = []
    for n in ("Regular", "Italic", "Bold", "BoldItalic"):
        p = os.path.join(FONTS, f"EBGaramond-{n}.ttf")
        if os.path.exists(p):
            polices += ["--epub-embed-font", p]
    chapitres = sorted(glob.glob(os.path.join(RACINE, "chapitres", "*.md")))
    subprocess.run(["pandoc", meta, *chapitres, fin,
                    "-f", "markdown+task_lists+pipe_tables+fenced_divs+raw_attribute",
                    "-t", "epub3", "-o", SORTIE,
                    "--lua-filter", os.path.join(ICI, "epub_filtre.lua"),
                    "--css", os.path.join(ICI, "epub.css"),
                    "--epub-cover-image", couv,
                    "--toc", "--toc-depth", "1", "--split-level", "1",
                    *polices], check=True)
    print("EPUB :", SORTIE, f"{os.path.getsize(SORTIE)/1e6:.1f} Mo")


if __name__ == "__main__":
    main()
