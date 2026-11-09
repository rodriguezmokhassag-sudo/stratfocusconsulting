#!/usr/bin/env python3
"""Dessine la 1re de couverture de « Vendre, structurer, grandir ».

Même famille visuelle que « Le Code Secret de l'Acheteur » : fond blanc,
titre noir massif avec un mot en bandeau noir, illustration centrale,
bandeau noir arrondi avec le nom de l'auteur.
Sortie : ../images/couverture.jpg (2000 x 3000 px, format 2:3).
"""
import os
import random

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ICI = os.path.dirname(os.path.abspath(__file__))
SORTIE = os.path.join(os.path.dirname(ICI), "images", "couverture.jpg")
F = os.path.expanduser("~/.fonts")
ANTON = os.path.join(F, "Anton-Regular.ttf")
MONT = os.path.join(F, "Montserrat[wght].ttf")

W, H = 2000, 3000
NOIR, BLANC = (12, 12, 12), (255, 255, 255)


def montserrat(taille, graisse="Bold"):
    f = ImageFont.truetype(MONT, taille)
    try:
        f.set_variation_by_name(graisse)
    except Exception:
        pass
    return f


def centre(d, y, texte, police, couleur=NOIR):
    l = d.textlength(texte, font=police)
    d.text(((W - l) / 2, y), texte, font=police, fill=couleur)
    return l


def main():
    random.seed(7)
    # Fond : blanc légèrement grisé sur les bords
    fond = Image.new("L", (W, H), 255)
    vign = Image.new("L", (W, H), 0)
    dv = ImageDraw.Draw(vign)
    dv.ellipse([-W * 0.3, -H * 0.15, W * 1.3, H * 1.05], fill=255)
    vign = vign.filter(ImageFilter.GaussianBlur(260))
    fond = Image.composite(fond, Image.new("L", (W, H), 222), vign)
    img = Image.merge("RGB", (fond, fond, fond))
    d = ImageDraw.Draw(img)

    # --- Titre ---
    f_titre = ImageFont.truetype(ANTON, 300)
    y = 120
    centre(d, y, "VENDRE,", f_titre)
    y += 360
    f_bande = ImageFont.truetype(ANTON, 330)
    mot = "STRUCTURER,"
    l = d.textlength(mot, font=f_bande)
    marge = 50
    d.rectangle([(W - l) / 2 - marge, y, (W + l) / 2 + marge, y + 410], fill=NOIR)
    d.text(((W - l) / 2, y - 5), mot, font=f_bande, fill=BLANC)
    y += 450
    # séparateur : traits et trois points
    yc = y + 40
    d.line([180, yc, 860, yc], fill=NOIR, width=9)
    d.line([W - 860, yc, W - 180, yc], fill=NOIR, width=9)
    for k in (-60, 0, 60):
        d.ellipse([W / 2 + k - 14, yc - 14, W / 2 + k + 14, yc + 14], fill=NOIR)
    y += 90
    centre(d, y, "GRANDIR", f_titre)
    y += 390
    f_sous = montserrat(78, "Medium")
    centre(d, y, "Les trois temps de l’entreprise", f_sous)
    centre(d, y + 100, "qui réussit", f_sous)

    # --- Illustration : trois marches ascendantes ---
    base = 2560
    larg = 330
    x0 = 470
    hauteurs = [300, 450, 600]
    f_num = ImageFont.truetype(ANTON, 170)
    f_lab = montserrat(46, "Bold")
    labels = ["VENDRE", "STRUCTURER", "GRANDIR"]
    for i, h in enumerate(hauteurs):
        x = x0 + i * (larg + 30)
        haut = base - h
        bloc = Image.new("L", (larg, h), 0)
        db = ImageDraw.Draw(bloc)
        for yy in range(h):
            v = int(15 + 55 * (yy / h))
            db.line([0, yy, larg, yy], fill=v)
        img.paste(Image.merge("RGB", (bloc, bloc, bloc)), (x, haut))
        n = str(i + 1)
        ln = d.textlength(n, font=f_num)
        d.text((x + (larg - ln) / 2, haut + 25), n, font=f_num, fill=BLANC)
        ll = d.textlength(labels[i], font=f_lab)
        if ll > larg - 20:
            f_l = montserrat(int(46 * (larg - 30) / ll), "Bold")
            ll = d.textlength(labels[i], font=f_l)
        else:
            f_l = f_lab
        d.text((x + (larg - ll) / 2, haut + 215), labels[i], font=f_l, fill=(225, 225, 225))

    # Halo lumineux au-dessus de la dernière marche
    halo = Image.new("L", (W, H), 0)
    dh = ImageDraw.Draw(halo)
    cx, cy = x0 + 2 * (larg + 30) + larg / 2, base - 600 - 200
    dh.ellipse([cx - 210, cy - 210, cx + 210, cy + 210], fill=255)
    halo = halo.filter(ImageFilter.GaussianBlur(90))
    ImageDraw.Draw(halo).rectangle([0, 0, W, 1640], fill=0)
    halo = halo.filter(ImageFilter.GaussianBlur(25))
    img = Image.composite(Image.new("RGB", (W, H), BLANC), img, halo)
    d = ImageDraw.Draw(img)
    # Flèche ascendante
    pts_corps = [(cx - 36, cy + 150), (cx + 36, cy + 150), (cx + 36, cy - 40), (cx - 36, cy - 40)]
    d.polygon(pts_corps, fill=NOIR)
    d.polygon([(cx - 105, cy - 32), (cx + 105, cy - 32), (cx, cy - 165)], fill=NOIR)

    # Carrés en dispersion, à gauche des marches (rappel de la 1re couverture)
    for _ in range(75):
        t = random.random() ** 0.7          # densité croissante vers la marche 1
        x = 70 + t * 380
        yb = random.uniform(2200 - 200 * t, 2540)
        c = int(8 + 38 * t * random.uniform(0.5, 1.0))
        gris = random.choice([12, 12, 12, 45, 80])
        if random.random() < 0.25 + 0.5 * t:
            d.rectangle([x, yb, x + c, yb + c], fill=(gris, gris, gris))

    # --- Bandeau bas arrondi avec le nom de l'auteur ---
    d.ellipse([-W * 0.6, 2620, W * 1.6, 4200], fill=NOIR)
    f_aut = montserrat(110, "Bold")
    nom = "Rodriguez MOKHASSA"
    ln = d.textlength(nom, font=f_aut)
    ya = 2790
    d.text(((W - ln) / 2, ya), nom, font=f_aut, fill=BLANC)
    yl = ya + 70
    d.line([110, yl, (W - ln) / 2 - 50, yl], fill=BLANC, width=8)
    d.line([(W + ln) / 2 + 50, yl, W - 110, yl], fill=BLANC, width=8)

    os.makedirs(os.path.dirname(SORTIE), exist_ok=True)
    img.save(SORTIE, quality=95, dpi=(300, 300))
    print("Couverture :", SORTIE, img.size)


if __name__ == "__main__":
    main()
