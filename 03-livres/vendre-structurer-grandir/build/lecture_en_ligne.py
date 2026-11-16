#!/usr/bin/env python3
"""Versions PDF de lecture en ligne, paginées en A5 et en A4.

Chaque format est composé à partir d'une copie des chapitres, pour que le
recalcul du sommaire n'écrase pas les numéros de page de l'édition 6 x 9.
Sorties : ../sortie/Vendre-structurer-grandir-lecture-en-ligne-A5.pdf et -A4.pdf
"""
import os
import shutil
import subprocess
import sys
import tempfile

ICI = os.path.dirname(os.path.abspath(__file__))
RACINE = os.path.dirname(ICI)

for fmt in sys.argv[1:] or ["A5", "A4"]:
    tmp = os.path.join(tempfile.mkdtemp(), "chapitres")
    shutil.copytree(os.path.join(RACINE, "chapitres"), tmp)
    print(f"== {fmt}")
    subprocess.run([sys.executable, os.path.join(ICI, "build.py")],
                   env={**os.environ, "FORMAT": fmt, "CHAPITRES": tmp,
                        # A5 : interligne du sommaire resserré pour qu'il tienne sur une page
                        **({"SOMMAIRE_APRES": "4"} if fmt == "A5" else {})}, check=True)
    docx = os.path.join(RACINE, "sortie", f"Vendre-structurer-grandir-lecture-en-ligne-{fmt}.docx")
    if os.path.exists(docx):
        os.remove(docx)   # seul le PDF est livré pour la lecture en ligne
    # Ouverture avec le panneau des signets (chapitres cliquables) affiché
    from pypdf import PdfReader, PdfWriter
    pdf = docx[:-5] + ".pdf"
    w = PdfWriter(clone_from=PdfReader(pdf))
    w.page_mode = "/UseOutlines"
    w.add_metadata({"/Title": "Vendre, structurer, grandir", "/Author": "Rodriguez MOKHASSA",
                    "/Subject": "Les trois temps de l'entreprise qui réussit"})
    w.write(pdf)
