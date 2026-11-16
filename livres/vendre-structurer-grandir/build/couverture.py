#!/usr/bin/env python3
"""Couverture complète pour l'impression (4e de couverture + dos + 1re).

Format fini 6 x 9 pouces (15,24 x 22,86 cm), papier blanc, 0,125 pouce de
fond perdu sur les bords extérieurs (exigé par l'imprimeur), rendu à 600 dpi.
Sources : ../images/couverture.jpg (1re) et ../images/couverture-verso.jpg (4e).
Usage : python3 couverture.py [nombre_de_pages_interieur]
"""
import os
import subprocess
import sys

from PIL import Image, ImageDraw, ImageFont, ImageOps

ICI = os.path.dirname(os.path.abspath(__file__))
RACINE = os.path.dirname(ICI)
SORTIE = os.path.join(RACINE, "sortie")
FACE = os.path.join(RACINE, "images", "couverture.jpg")
VERSO = os.path.join(RACINE, "images", "couverture-verso.jpg")
LOGO = os.path.join(RACINE, "images", "logo-stfc-embleme.png")
PDF_INT = os.path.join(SORTIE, "Vendre-structurer-grandir-interieur-impression.pdf")

DPI = 600
LARG, HAUT = 6.0, 9.0
FOND_PERDU = 0.125
EPAISSEUR_PAGE = 0.002252       # papier blanc (pouce par page)

INTER = "/usr/share/fonts/opentype/inter/"
NAVY, BLANC, OR = (4, 20, 48), (255, 255, 255), (247, 190, 38)

# zone utile de la 4e (la photo source a un liseré et la tranche du livre au bord)
VERSO_CROP = (18, 22, 4930, 7672)
FACE_CROP = (0, 12, 5120, 7660)          # retire les liserés clairs haut et bas


def px(p):
    return round(p * DPI)


def nb_pages():
    if len(sys.argv) > 1:
        return int(sys.argv[1])
    out = subprocess.run(["pdfinfo", PDF_INT], capture_output=True, text=True).stdout
    return int([l for l in out.splitlines() if l.startswith("Pages")][0].split()[-1])


def miroir(img, g, d, h, b):
    """Étend l'image par effet miroir de ses bords (fond perdu, recadrage)."""
    W, H = img.size
    out = Image.new("RGB", (W + g + d, H + h + b))
    out.paste(img, (g, h))
    if g: out.paste(ImageOps.mirror(img.crop((0, 0, g, H))), (0, h))
    if d: out.paste(ImageOps.mirror(img.crop((W - d, 0, W, H))), (g + W, h))
    if h: out.paste(ImageOps.flip(out.crop((0, h, out.width, 2 * h))), (0, 0))
    if b: out.paste(ImageOps.flip(out.crop((0, h + H - b, out.width, h + H))), (0, h + H))
    return out


def main():
    pages = nb_pages()
    pages_imp = pages + (pages % 2)
    dos = pages_imp * EPAISSEUR_PAGE
    fp, pw, ph = px(FOND_PERDU), px(LARG), px(HAUT)
    w_dos = px(dos)
    W, H = fp + pw + w_dos + pw + fp, fp + ph + fp
    img = Image.new("RGB", (W, H), NAVY)
    x_dos = fp + pw
    x_face = x_dos + w_dos

    # --- 4e de couverture (à gauche) ---
    v = Image.open(VERSO).convert("RGB").crop(VERSO_CROP)
    manque = round(v.height * 2 / 3) - v.width          # ramener au ratio 2:3
    v = miroir(v, manque // 2, manque - manque // 2, 0, 0).resize((pw, ph), Image.LANCZOS)
    img.paste(miroir(v, fp, 0, fp, fp), (0, 0))

    # --- 1re de couverture (à droite) ---
    f = Image.open(FACE).convert("RGB").crop(FACE_CROP).resize((pw, ph), Image.LANCZOS)
    img.paste(miroir(f, 0, fp, fp, fp), (x_face, 0))

    # --- Dos : bleu nuit, texte de bas en haut (usage français) ---
    d = ImageDraw.Draw(img)
    d.rectangle([x_dos, 0, x_face - 1, H], fill=NAVY)
    if pages > 79:
        th = int(w_dos * 0.40)
        f1 = ImageFont.truetype(INTER + "Inter-ExtraBold.otf", th)
        f2 = ImageFont.truetype(INTER + "Inter-SemiBold.otf", int(th * 0.85))
        bande = Image.new("RGB", (H, w_dos), NAVY)
        bd = ImageDraw.Draw(bande)
        cy = w_dos / 2
        x = fp + px(0.45)
        for txt, coul in (("VENDRE, STRUCTURER, ", BLANC), ("GRANDIR", OR)):
            bd.text((x, cy), txt, font=f1, fill=coul, anchor="lm")
            x += bd.textlength(txt, font=f1)
        bd.text((x + px(0.35), cy), "Rodriguez MOKHASSA", font=f2, fill=BLANC, anchor="lm")
        # emblème STFC en bas du dos, texte STFC Éditions à côté
        xe = H - fp - px(0.45)
        if os.path.exists(LOGO):
            taille = int(w_dos * 0.78)
            disque = Image.new("L", (taille * 4, taille * 4), 0)
            ImageDraw.Draw(disque).ellipse((0, 0, taille * 4 - 1, taille * 4 - 1), fill=255)
            disque = disque.resize((taille, taille), Image.LANCZOS)
            xe -= taille
            bande.paste(BLANC, (xe, int(cy - taille / 2)), disque)
            emb = Image.open(LOGO).convert("RGBA").rotate(-90, expand=True)
            emb.thumbnail((int(taille * 0.8), int(taille * 0.8)), Image.LANCZOS)
            bande.paste(emb, (xe + (taille - emb.width) // 2, int(cy - emb.height / 2)), emb)
            xe -= px(0.12)
        bd.text((xe, cy), "STFC Éditions", font=f2, fill=OR, anchor="rm")
        img.paste(bande.rotate(90, expand=True), (x_dos, 0))

    os.makedirs(SORTIE, exist_ok=True)
    base = os.path.join(SORTIE, "Couverture-complete-impression")
    img.save(base + ".pdf", resolution=DPI)
    img.save(base + ".png", dpi=(DPI, DPI))
    print(f"Pages : {pages} (impression {pages_imp}) | dos : {dos:.3f} po ({dos*25.4:.1f} mm)"
          f" | couverture : {W/DPI:.3f} x {H/DPI:.3f} po ({W/DPI*2.54:.2f} x {H/DPI*2.54:.2f} cm)"
          f" | {W} x {H} px")


if __name__ == "__main__":
    main()
