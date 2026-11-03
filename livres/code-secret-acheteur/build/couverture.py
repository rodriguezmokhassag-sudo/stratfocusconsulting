#!/usr/bin/env python3
"""Couverture complète pour l'impression (4e de couverture + dos + 1re).

Dimensions calculées selon le nombre de pages, au format 15,24 x 22,86 cm
(6 x 9 pouces), papier blanc, avec 0,125 pouce de fond perdu.
Usage : python3 couverture.py [nombre_de_pages]
"""
import os
import subprocess
import sys

from PIL import Image, ImageDraw, ImageFont

ICI = os.path.dirname(os.path.abspath(__file__))
RACINE = os.path.dirname(ICI)
SORTIE = os.path.join(RACINE, "sortie")
FACE = os.path.join(RACINE, "images", "couverture.jpg")
PDF_INT = os.path.join(SORTIE, "Le-Code-Secret-de-l-Acheteur.pdf")

DPI = 300
LARG, HAUT = 6.0, 9.0          # format fini (pouces)
FOND_PERDU = 0.125
EPAISSEUR_PAGE = 0.002252       # papier blanc (pouce par page)

FONTS = os.path.expanduser("~/.fonts")
SANS_GRAS = "/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf"
SERIF = os.path.join(FONTS, "EBGaramond-Regular.ttf")
SERIF_GRAS = os.path.join(FONTS, "EBGaramond-Bold.ttf")
SERIF_ITAL = os.path.join(FONTS, "EBGaramond-Italic.ttf")

NOIR, BLANC, GRIS = (17, 17, 17), (255, 255, 255), (90, 90, 90)


def px(pouces):
    return round(pouces * DPI)


def nb_pages():
    if len(sys.argv) > 1:
        return int(sys.argv[1])
    out = subprocess.run(["pdfinfo", PDF_INT], capture_output=True, text=True).stdout
    return int([l for l in out.splitlines() if l.startswith("Pages")][0].split()[-1])


def lignes(draw, texte, police, largeur):
    mots, res, cour = texte.split(), [], ""
    for m in mots:
        essai = (cour + " " + m).strip()
        if draw.textlength(essai, font=police) <= largeur:
            cour = essai
        else:
            res.append(cour)
            cour = m
    if cour:
        res.append(cour)
    return res


def paragraphe(draw, x, y, texte, police, largeur, couleur=NOIR, interligne=1.32):
    h = police.size * interligne
    for l in lignes(draw, texte, police, largeur):
        draw.text((x, y), l, font=police, fill=couleur)
        y += h
    return y


def main():
    pages = nb_pages()
    pages_imp = pages + (pages % 2)          # l'imprimeur ajoute une page blanche si impair
    dos = pages_imp * EPAISSEUR_PAGE
    W = px(FOND_PERDU + LARG + dos + LARG + FOND_PERDU)
    H = px(FOND_PERDU + HAUT + FOND_PERDU)
    img = Image.new("RGB", (W, H), BLANC)
    d = ImageDraw.Draw(img)

    x_dos = px(FOND_PERDU + LARG)
    w_dos = px(dos)
    x_face = x_dos + w_dos

    # --- 1re de couverture : image fournie, recadrée au centre ---
    face = Image.open(FACE).convert("RGB")
    cible_w, cible_h = W - x_face, H
    ech = max(cible_w / face.width, cible_h / face.height)
    face = face.resize((round(face.width * ech), round(face.height * ech)), Image.LANCZOS)
    gx = (face.width - cible_w) // 2
    gy = (face.height - cible_h) // 2
    img.paste(face.crop((gx, gy, gx + cible_w, gy + cible_h)), (x_face, 0))

    # --- Dos : bande noire, texte de bas en haut (usage français) ---
    d.rectangle([x_dos, 0, x_face - 1, H], fill=NOIR)
    if pages > 79:
        hauteur_txt = int(w_dos * 0.52)
        f_dos = ImageFont.truetype(SANS_GRAS, hauteur_txt)
        f_dos2 = ImageFont.truetype(SERIF, int(hauteur_txt * 0.95))
        bande = Image.new("RGB", (H, w_dos), NOIR)
        bd = ImageDraw.Draw(bande)
        t1, t2, t3 = "LE CODE SECRET DE L’ACHETEUR", "Rodriguez MOKHASSA", "STFC Éditions"
        y = (w_dos - hauteur_txt) // 2 - int(hauteur_txt * 0.12)
        marge = px(0.6)
        bd.text((marge, y), t1, font=f_dos, fill=BLANC)
        l2 = bd.textlength(t2, font=f_dos2)
        bd.text((H // 2 + px(0.6), y), t2, font=f_dos2, fill=BLANC)
        l3 = bd.textlength(t3, font=f_dos2)
        bd.text((H - marge - l3, y), t3, font=f_dos2, fill=(200, 200, 200))
        img.paste(bande.rotate(90, expand=True), (x_dos, 0))

    # --- 4e de couverture ---
    m = px(FOND_PERDU + 0.55)
    x0, larg = m, px(LARG) - px(0.55) * 2 - px(0.0)
    y = px(FOND_PERDU + 0.65)

    f_bandeau = ImageFont.truetype(SANS_GRAS, 58)
    accroche = "POURQUOI VOS CLIENTS N’ACHÈTENT PAS ?"
    lt = lignes(d, accroche, f_bandeau, larg - 40)
    for l in lt:
        tw = d.textlength(l, font=f_bandeau)
        d.rectangle([x0, y, x0 + tw + 40, y + 86], fill=NOIR)
        d.text((x0 + 20, y + 10), l, font=f_bandeau, fill=BLANC)
        y += 98
    y += 30

    f_corps = ImageFont.truetype(SERIF, 48)
    f_gras = ImageFont.truetype(SERIF_GRAS, 48)
    f_ital = ImageFont.truetype(SERIF_ITAL, 48)
    y = paragraphe(d, x0, y, "Votre produit est bon, vos prix sont justes, et pourtant vos clients hésitent, comparent, puis repartent sans acheter. La raison est simple : ils ne décident pas comme vous le croyez. Ils décident d’abord avec leurs émotions, leurs habitudes, la peur de se tromper et le regard de leurs proches.", f_corps, larg)
    y += 22
    y = paragraphe(d, x0, y, "Rodriguez MOKHASSA traduit les découvertes de la psychologie comportementale en outils concrets, pensés pour le terrain congolais, du marché Total de Brazzaville aux PME de Pointe-Noire.", f_corps, larg)
    y += 30
    d.text((x0, y), "Vous apprendrez à :", font=f_gras, fill=NOIR)
    y += 68
    puces = [
        "parler au cœur de l’acheteur avant de parler à sa raison ;",
        "reconnaître les quatre profils d’acheteurs et adapter votre discours ;",
        "faire émerger les vrais besoins avec la méthode SPIN ;",
        "activer avec éthique les sept leviers d’influence ;",
        "vendre sur WhatsApp et encaisser par mobile money sans perdre de clients ;",
        "répondre aux objections et faire de chaque client un ambassadeur.",
    ]
    for p in puces:
        d.ellipse([x0 + 4, y + 22, x0 + 18, y + 36], fill=NOIR)
        y = paragraphe(d, x0 + 36, y, p, f_corps, larg - 36)
        y += 6
    y += 22
    y = paragraphe(d, x0, y, "Avec huit fiches pratiques à photocopier et un plan d’action sur 30 jours.", f_ital, larg)
    y += 40
    d.line([x0, y, x0 + larg, y], fill=GRIS, width=3)
    y += 30
    f_petit = ImageFont.truetype(SERIF, 42)
    y = paragraphe(d, x0, y, "Rodriguez MOKHASSA est le fondateur de Stratfocus Consulting (STFC), cabinet spécialisé dans l’accélération des TPE et PME, la performance commerciale et la stratégie marketing.", f_petit, larg, GRIS)

    # Bas de la 4e : éditeur à gauche, zone code-barres réservée à droite
    # bande noire basse, en écho à la 1re de couverture
    yb = H - px(FOND_PERDU + 1.15)
    d.rectangle([0, yb, x_dos, H], fill=NOIR)
    d.line([x0, yb + 40, x0 + px(0.6), yb + 40], fill=BLANC, width=4)
    f_edit = ImageFont.truetype(SANS_GRAS, 56)
    d.text((x0, yb + 75), "STFC ÉDITIONS", font=f_edit, fill=BLANC)
    d.text((x0, yb + 150), "Brazzaville, République du Congo", font=f_petit, fill=(210, 210, 210))
    # zone blanche de 2 x 1,2 pouce pour le code-barres ISBN (laissée vide)

    os.makedirs(SORTIE, exist_ok=True)
    base = os.path.join(SORTIE, "Couverture-complete-impression")
    img.save(base + ".pdf", resolution=DPI)
    img.save(base + ".png", dpi=(DPI, DPI))
    print(f"Pages : {pages} (impression {pages_imp}) | dos : {dos:.3f} po ({dos*25.4:.1f} mm)"
          f" | couverture : {W/DPI:.3f} x {H/DPI:.3f} po ({W/DPI*2.54:.2f} x {H/DPI*2.54:.2f} cm)")


if __name__ == "__main__":
    main()
