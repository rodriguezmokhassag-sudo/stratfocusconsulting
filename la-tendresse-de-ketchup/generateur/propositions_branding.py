"""Planche A4 : 4 propositions de branding et palettes pour La Tendresse de Ketchup.

    python3 generateur/propositions_branding.py
"""
from brand import FONTS
from render import ROOT, BUILD, to_pdf

PISTES = [
    {
        "nom": "Congo Wax",
        "idee": "Chaleureux, fier et populaire. Les couleurs du drapeau et les motifs du pagne wax : un maquis qui célèbre Brazzaville.",
        "titres": "Anton", "texte": "Work Sans",
        "couleurs": [("Vert forêt", "#0B6E4F"), ("Jaune soleil", "#F4C20D"), ("Rouge brique", "#C1272D"),
                     ("Indigo", "#1D2F6F"), ("Sable", "#F6E7C8")],
        "hero_bg": "#1D2F6F", "hero_txt": "#F6E7C8", "accent": "#F4C20D", "pied_bg": "#C1272D",
        "logo": """<svg viewBox="0 0 120 120" class="lg"><rect x="20" y="20" width="80" height="80" rx="8" transform="rotate(45 60 60)" fill="#F4C20D" stroke="#0B6E4F" stroke-width="6"/>
          <path d="M60 84 C 34 66, 34 42, 49 40 C 55 39, 59 44, 60 48 C 61 44, 65 39, 71 40 C 86 42, 86 66, 60 84 Z" fill="#C1272D"/>
          <circle cx="60" cy="96" r="3" fill="#0B6E4F"/></svg>""",
        "wordmark": """<div style="font-family:Anton;line-height:.92;color:#F6E7C8;letter-spacing:.02em">
          <div style="font-size:9pt;color:#F4C20D;letter-spacing:.2em">LA TENDRESSE DE</div><div style="font-size:26pt">KETCHUP</div></div>""",
        "phrase_font": "font-family:Anton;font-size:12.5pt;letter-spacing:.01em;text-transform:uppercase",
        "motif": """<svg class="motif" width="100%" height="100%"><defs><pattern id="wax" width="22" height="22" patternUnits="userSpaceOnUse">
          <circle cx="11" cy="11" r="6" fill="none" stroke="#F4C20D" stroke-width="1.4"/><circle cx="11" cy="11" r="2" fill="#C1272D"/>
          <path d="M0 0 L5 0 L0 5Z M22 22 L17 22 L22 17Z" fill="#0B6E4F"/></pattern></defs>
          <rect width="100%" height="100%" fill="url(#wax)" opacity=".13"/></svg>""",
    },
    {
        "nom": "Maquis Néon",
        "idee": "Festif et nocturne. L'enseigne lumineuse d'un bar où l'on sort le soir : idéal pour les réseaux sociaux et les soirées.",
        "titres": "Monoton + Righteous", "texte": "DM Sans",
        "couleurs": [("Nuit", "#120F1A"), ("Rose néon", "#FF2E88"), ("Cyan", "#19D3DA"),
                     ("Violet", "#7B2FF7"), ("Lavande", "#EDE9FE")],
        "hero_bg": "#120F1A", "hero_txt": "#EDE9FE", "accent": "#19D3DA", "pied_bg": "#7B2FF7",
        "logo": """<svg viewBox="0 0 120 120" class="lg"><defs><filter id="glow" x="-50%" y="-50%" width="200%" height="200%">
          <feGaussianBlur stdDeviation="3" result="b"/><feMerge><feMergeNode in="b"/><feMergeNode in="SourceGraphic"/></feMerge></filter></defs>
          <g filter="url(#glow)" fill="none" stroke-linecap="round" stroke-linejoin="round">
          <path d="M60 92 C 26 70, 24 38, 44 36 C 53 35, 59 41, 60 47 C 61 41, 67 35, 76 36 C 96 38, 94 70, 60 92 Z" stroke="#FF2E88" stroke-width="5"/>
          <path d="M60 100 v8" stroke="#19D3DA" stroke-width="5"/><circle cx="60" cy="60" r="56" stroke="#19D3DA" stroke-width="2.5" stroke-dasharray="1 7"/></g></svg>""",
        "wordmark": """<div style="line-height:1"><div style="font-family:Righteous;font-size:10pt;color:#19D3DA;text-shadow:0 0 6px #19D3DA">la tendresse de</div>
          <div style="font-family:Monoton;font-size:21pt;color:#FF2E88;text-shadow:0 0 8px #FF2E88">KETCHUP</div></div>""",
        "phrase_font": "font-family:Righteous;font-size:12.5pt;color:#EDE9FE;text-shadow:0 0 6px #FF2E88",
        "motif": "",
    },
    {
        "nom": "Bistrot Rétro",
        "idee": "Authentique et rassurant. L'esprit des vieilles plaques émaillées et des bars d'antan : une maison sérieuse, qui dure.",
        "titres": "Abril Fatface", "texte": "Work Sans",
        "couleurs": [("Crème", "#F3E9D2"), ("Vert bouteille", "#1F4D3A"), ("Moutarde", "#D9A21B"),
                     ("Rouge tomate", "#B83A2E"), ("Brun café", "#3B2A20")],
        "hero_bg": "#F3E9D2", "hero_txt": "#3B2A20", "accent": "#B83A2E", "pied_bg": "#1F4D3A",
        "logo": """<svg viewBox="0 0 120 120" class="lg"><defs><path id="arc" d="M60 60 m-40 0 a40 40 0 1 1 80 0 a40 40 0 1 1 -80 0"/></defs>
          <circle cx="60" cy="60" r="57" fill="#1F4D3A"/><circle cx="60" cy="60" r="52" fill="none" stroke="#D9A21B" stroke-width="2.5"/>
          <text font-family="Work" font-weight="700" font-size="11" letter-spacing="3" fill="#D9A21B"><textPath href="#arc">BRAZZAVILLE · DIATA · BAR ·</textPath></text>
          <circle cx="60" cy="60" r="28" fill="#F3E9D2"/>
          <path d="M60 78 C 42 66, 41 49, 51 48 C 56 47.5, 59 51, 60 54 C 61 51, 64 47.5, 69 48 C 79 49, 78 66, 60 78 Z" fill="#B83A2E"/></svg>""",
        "wordmark": """<div style="line-height:1;color:#3B2A20"><div style="font-family:Abril;font-size:11pt;font-style:italic">La Tendresse de</div>
          <div style="font-family:Abril;font-size:24pt;color:#B83A2E">Ketchup</div></div>""",
        "phrase_font": "font-family:Abril;font-size:13pt",
        "motif": """<div style="position:absolute;inset:2.4mm;border:.5mm solid #1F4D3A;border-radius:1.5mm"></div>
          <div style="position:absolute;inset:3.6mm;border:.25mm solid #D9A21B;border-radius:1mm"></div>""",
    },
    {
        "nom": "Tendresse Moderne",
        "idee": "Élégant et apaisé. Des tons terre et poudrés, une typographie raffinée : un restaurant-bar chic qui attire une clientèle exigeante.",
        "titres": "DM Serif Display", "texte": "DM Sans",
        "couleurs": [("Terracotta", "#D2553B"), ("Rose poudré", "#F2C6B4"), ("Olive", "#6B7A3A"),
                     ("Anthracite", "#2B2B2B"), ("Ivoire", "#FAF6F0")],
        "hero_bg": "#FAF6F0", "hero_txt": "#2B2B2B", "accent": "#D2553B", "pied_bg": "#2B2B2B",
        "logo": """<svg viewBox="0 0 120 120" class="lg"><circle cx="60" cy="60" r="56" fill="#F2C6B4"/>
          <text x="58" y="80" text-anchor="middle" font-family="DMSerif" font-style="italic" font-size="62" fill="#2B2B2B">tk</text>
          <path d="M88 34 c0 6 -6 9 -6 14 a6 6 0 0 0 12 0 c0 -5 -6 -8 -6 -14z" fill="#D2553B"/></svg>""",
        "wordmark": """<div style="line-height:1.02;color:#2B2B2B"><div style="font-family:DMSerif;font-style:italic;font-size:12pt">la tendresse de</div>
          <div style="font-family:DMSerif;font-size:24pt;color:#D2553B;letter-spacing:.01em">Ketchup</div></div>""",
        "phrase_font": "font-family:DMSerif;font-style:italic;font-size:13.5pt",
        "motif": """<svg class="motif" width="100%" height="100%" viewBox="0 0 100 60" preserveAspectRatio="xMaxYMax slice">
          <path d="M70 60 V30 a15 15 0 0 1 30 0 V60Z" fill="#F2C6B4" opacity=".7"/><circle cx="92" cy="52" r="3" fill="#6B7A3A" opacity=".8"/></svg>""",
    },
]

CSS = f"""
@font-face {{ font-family:Anton; src:url('{FONTS}/Anton-400.ttf'); }}
@font-face {{ font-family:Righteous; src:url('{FONTS}/Righteous-400.ttf'); }}
@font-face {{ font-family:Monoton; src:url('{FONTS}/Monoton-400.ttf'); }}
@font-face {{ font-family:Abril; src:url('{FONTS}/AbrilFatface-400.ttf'); }}
@font-face {{ font-family:DMSerif; src:url('{FONTS}/DMSerifDisplay-400.ttf'); }}
@font-face {{ font-family:DMSerif; font-style:italic; src:url('{FONTS}/DMSerifDisplay-400i.ttf'); }}
@font-face {{ font-family:DMSans; font-weight:400; src:url('{FONTS}/DMSans-400.ttf'); }}
@font-face {{ font-family:DMSans; font-weight:700; src:url('{FONTS}/DMSans-700.ttf'); }}
@font-face {{ font-family:Work; font-weight:400; src:url('{FONTS}/WorkSans-400.ttf'); }}
@font-face {{ font-family:Work; font-weight:700; src:url('{FONTS}/WorkSans-700.ttf'); }}
@page {{ size:A4 portrait; margin:0; }}
* {{ box-sizing:border-box; margin:0; padding:0; }}
html,body {{ background:#fff; color:#1d1a19; font-family:DMSans,sans-serif; -webkit-print-color-adjust:exact; print-color-adjust:exact; }}
.page {{ width:210mm; height:297mm; padding:10mm 10mm 8mm; display:flex; flex-direction:column; }}
header {{ display:flex; justify-content:space-between; align-items:flex-end; border-bottom:.4mm solid #1d1a19; padding-bottom:2.5mm; }}
header h1 {{ font-family:DMSerif; font-weight:400; font-size:21pt; line-height:1; }}
header h1 em {{ font-style:italic; }}
header p {{ font-size:7.5pt; color:#6b6461; text-align:right; line-height:1.4; }}
.grid {{ flex:1; display:grid; grid-template-columns:1fr 1fr; grid-template-rows:1fr 1fr; gap:6mm; margin-top:5mm; }}
.card {{ border:.3mm solid #d9d3cf; border-radius:2.5mm; overflow:hidden; display:flex; flex-direction:column; }}
.hero {{ position:relative; height:62mm; padding:5mm 5mm 0; overflow:hidden; display:flex; flex-direction:column; }}
.motif {{ position:absolute; inset:0; }}
.brandline {{ position:relative; display:flex; align-items:center; gap:3mm; }}
.lg {{ width:17mm; height:17mm; flex:none; }}
.phrase {{ position:relative; margin-top:4.5mm; line-height:1.12; }}
.pied {{ position:absolute; left:0; right:0; bottom:0; height:7mm; display:flex; align-items:center; justify-content:center;
  font-size:6.2pt; letter-spacing:.06em; color:#fff; font-weight:700; }}
.info {{ padding:3.5mm 5mm 4mm; display:flex; flex-direction:column; flex:1; }}
.info .n {{ font-size:6.5pt; font-weight:700; letter-spacing:.18em; text-transform:uppercase; color:#8a817d; }}
.info h2 {{ font-family:DMSerif; font-weight:400; font-size:15pt; line-height:1.1; }}
.info p {{ font-size:7.4pt; line-height:1.4; color:#4a4441; margin-top:1mm; }}
.sw {{ display:flex; gap:1.6mm; margin-top:auto; }}
.sw div {{ flex:1; }}
.sw i {{ display:block; height:11mm; border-radius:1.2mm; border:.25mm solid rgba(0,0,0,.12); }}
.sw b {{ display:block; font-size:6pt; margin-top:1mm; line-height:1.15; }}
.sw span {{ font-size:5.8pt; color:#6b6461; font-family:monospace; }}
.ty {{ font-size:6.6pt; color:#4a4441; margin-top:2.4mm; border-top:.25mm solid #e6e1de; padding-top:1.6mm; }}
footer {{ margin-top:4mm; font-size:7.5pt; color:#4a4441; text-align:center; }}
"""


def carte(i, p):
    sw = "".join(f'<div><i style="background:{h}"></i><b>{n}</b><span>{h}</span></div>' for n, h in p["couleurs"])
    return f"""<div class="card">
      <div class="hero" style="background:{p['hero_bg']};color:{p['hero_txt']}">{p['motif']}
        <div class="brandline">{p['logo']}{p['wordmark']}</div>
        <div class="phrase" style="{p['phrase_font']}">Ne profitez pas de nos relations<br>pour <span style="color:{p['accent']}">me faire tomber.</span></div>
        <div class="pied" style="background:{p['pied_bg']}">RESTAURANT-BAR LA TENDRESSE DE KETCHUP — LA DIRECTION</div>
      </div>
      <div class="info"><div class="n">Piste {i}</div><h2>{p['nom']}</h2><p>{p['idee']}</p>
        <div class="sw">{sw}</div>
        <div class="ty"><b>Titres :</b> {p['titres']} &nbsp;·&nbsp; <b>Texte :</b> {p['texte']}</div></div>
    </div>"""


def build():
    cartes = "".join(carte(i, p) for i, p in enumerate(PISTES, 1))
    html = f"""<!doctype html><html lang="fr"><head><meta charset="utf-8"><title>Propositions de branding</title>
<style>{CSS}</style></head><body><section class="page">
  <header><h1>La Tendresse de Ketchup<br><em>4 propositions de branding</em></h1>
    <p>Restaurant-Bar · Quartier Diata, Brazzaville<br>Chaque piste : logo, typographies, palette de 5 couleurs<br>et aperçu sur l'affiche « Ne profitez pas… »</p></header>
  <div class="grid">{cartes}</div>
  <footer>Choisissez une piste (ou combinez-en deux) : elle sera appliquée à toute la liasse — affiches, formulaires, Excel et Word.</footer>
</section></body></html>"""
    return to_pdf(html, ROOT / "sortie" / "0_Propositions_branding" / "Propositions_branding_A4.pdf")


if __name__ == "__main__":
    print(build())
