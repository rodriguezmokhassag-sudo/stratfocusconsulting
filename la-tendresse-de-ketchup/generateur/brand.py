"""Charte graphique : couleurs, polices, logo et briques HTML communes."""
from pathlib import Path

from config import ENTREPRISE as E, DEVISE

FONTS = (Path(__file__).resolve().parent.parent / "assets" / "fonts").as_uri()

ROUGE = "#C8102E"
ROUGE_FONCE = "#7E0A1E"
CREME = "#FFF4E2"
MOUTARDE = "#F2B705"
ENCRE = "#231A17"


def val(key, width="45mm"):
    """Valeur de la config, ou ligne pointillée si elle n'est pas encore connue."""
    v = E.get(key)
    if v:
        return v
    return f'<span class="blank" style="width:{width}"></span>'


def adresse():
    rue = val("rue", "35mm")
    return f"{E['quartier']}, {rue} — {E['ville']}, {E['pays']}"


def mentions():
    return (f"RCCM : {val('rccm', '38mm')} &nbsp;·&nbsp; NIU : {val('niu', '32mm')}"
            f" &nbsp;·&nbsp; Tél. : {val('telephone', '30mm')}")


LOGO_SVG = """
<svg class="logo" viewBox="0 0 120 120" xmlns="http://www.w3.org/2000/svg" aria-label="Logo">
  <circle cx="60" cy="60" r="57" fill="{bg}" stroke="{ring}" stroke-width="4"/>
  <circle cx="60" cy="60" r="49" fill="none" stroke="{ring}" stroke-width="1.2" stroke-dasharray="2 3"/>
  <path d="M60 90 C 26 68, 24 36, 44 34 C 53 33, 59 39, 60 45 C 61 39, 67 33, 76 34 C 96 36, 94 68, 60 90 Z"
        fill="{heart}"/>
  <path d="M38 66 C 38 72, 35 74, 35 78 a3.2 3.2 0 0 0 6.4 0 C 41 74, 38 72, 38 66 Z" fill="{heart}"/>
  <path d="M82 64 C 82 69, 80 71, 80 74 a2.6 2.6 0 0 0 5.2 0 C 85 71, 82 69, 82 64 Z" fill="{heart}"/>
  <ellipse cx="47" cy="45" rx="6" ry="3.6" transform="rotate(-35 47 45)" fill="#fff" opacity=".55"/>
</svg>"""


def logo(bg=CREME, ring=ROUGE, heart=ROUGE):
    return LOGO_SVG.format(bg=bg, ring=ring, heart=heart)


def wordmark(cls=""):
    return f"""<div class="wordmark {cls}">
      <span class="wm-la">La Tendresse</span>
      <span class="wm-de">de</span>
      <span class="wm-ketchup">KETCHUP</span>
    </div>"""


BASE_CSS = f"""
@font-face {{ font-family:'Bebas'; src:url('{FONTS}/BebasNeue-400.ttf'); }}
@font-face {{ font-family:'Playfair'; font-style:italic; font-weight:400; src:url('{FONTS}/PlayfairDisplay-400i.ttf'); }}
@font-face {{ font-family:'Playfair'; font-style:italic; font-weight:700; src:url('{FONTS}/PlayfairDisplay-700i.ttf'); }}
@font-face {{ font-family:'Playfair'; font-style:normal; font-weight:700; src:url('{FONTS}/PlayfairDisplay-700.ttf'); }}
@font-face {{ font-family:'Work'; font-weight:400; src:url('{FONTS}/WorkSans-400.ttf'); }}
@font-face {{ font-family:'Work'; font-weight:600; src:url('{FONTS}/WorkSans-600.ttf'); }}
@font-face {{ font-family:'Work'; font-weight:700; src:url('{FONTS}/WorkSans-700.ttf'); }}
:root {{ --rouge:{ROUGE}; --rouge-f:{ROUGE_FONCE}; --creme:{CREME}; --moutarde:{MOUTARDE}; --encre:{ENCRE}; }}
* {{ box-sizing:border-box; margin:0; padding:0; }}
html, body {{ background:#fff; color:var(--encre); font-family:'Work',sans-serif; font-size:9pt;
  -webkit-print-color-adjust:exact; print-color-adjust:exact; }}
.page {{ position:relative; overflow:hidden; page-break-after:always; break-after:page; }}
.page:last-child {{ page-break-after:auto; break-after:auto; }}
.logo {{ display:block; }}
.wordmark {{ display:flex; align-items:baseline; gap:1.2mm; line-height:1; white-space:nowrap; }}
.wm-la {{ font-family:'Playfair'; font-style:italic; font-weight:700; color:var(--encre); }}
.wm-de {{ font-family:'Playfair'; font-style:italic; font-weight:400; color:var(--rouge-f); }}
.wm-ketchup {{ font-family:'Bebas'; color:var(--rouge); letter-spacing:.06em; }}
.blank {{ display:inline-block; border-bottom:.6pt dotted #6b5d58; height:1em; vertical-align:baseline; }}
.field {{ display:flex; align-items:flex-end; gap:2mm; margin-top:3.2mm; white-space:nowrap; }}
.field label {{ font-weight:600; font-size:8.5pt; }}
.field .line {{ flex:1; border-bottom:.6pt dotted #6b5d58; height:4.2mm; }}
.row {{ display:flex; gap:5mm; }}
.row > * {{ flex:1; }}
h1.doc-title {{ font-family:'Bebas'; font-weight:400; letter-spacing:.05em; color:var(--rouge-f); line-height:1; }}
.num {{ font-family:'Bebas'; color:var(--rouge); letter-spacing:.06em; }}
table.grid {{ width:100%; border-collapse:collapse; }}
table.grid th {{ background:var(--rouge-f); color:#fff; font-weight:600; font-size:7.6pt; text-transform:uppercase;
  letter-spacing:.03em; padding:1.4mm 1.2mm; border:.5pt solid var(--rouge-f); }}
table.grid td {{ border:.5pt solid #b9aaa4; height:6.4mm; padding:0 1.2mm; font-size:8pt; }}
table.grid tr:nth-child(even) td {{ background:#fdf7ee; }}
table.grid td.sec {{ background:var(--creme)!important; font-weight:700; color:var(--rouge-f); font-size:7.6pt;
  text-transform:uppercase; letter-spacing:.04em; }}
table.grid tfoot td {{ font-weight:700; background:var(--creme)!important; }}
.sign {{ display:flex; gap:8mm; margin-top:4mm; }}
.sign > div {{ flex:1; border-top:.6pt solid var(--encre); padding-top:1mm; font-size:7.5pt; font-weight:600; text-align:center; }}
.note {{ font-size:7pt; color:#6b5d58; }}
.check {{ display:inline-block; width:3mm; height:3mm; border:.7pt solid var(--encre); vertical-align:-.4mm; margin:0 1mm 0 3mm; }}
"""


def doc(title, body, css="", size="A4 portrait"):
    return f"""<!doctype html><html lang="fr"><head><meta charset="utf-8"><title>{title}</title>
<style>@page {{ size:{size}; margin:0; }}{BASE_CSS}{css}</style></head><body>{body}</body></html>"""


def entete_formulaire(titre, numero=None, sous_titre=""):
    """En-tête compacte pour formulaires : logo, nom, coordonnées, titre et numéro.

    numero : entier (formulaire numéroté), None (case N° vierge) ou False (pas de numéro).
    """
    if numero is False:
        num = ""
    elif numero is None:
        num = 'N° <span class="blank" style="width:20mm"></span>'
    else:
        num = f"N° {numero:04d}"
    st = f'<div class="ef-st">{sous_titre}</div>' if sous_titre else ""
    return f"""<div class="ef">
      {logo()}
      <div class="ef-id">{wordmark()}<div class="ef-addr">{E['type']} · {adresse()}</div>
        <div class="ef-addr">{mentions()}</div></div>
      <div class="ef-titre"><h1 class="doc-title">{titre}</h1>{st}{f'<div class="num">{num}</div>' if num else ''}</div>
    </div>"""


ENTETE_CSS = """
.ef { display:flex; align-items:center; gap:3mm; border-bottom:1.6pt solid var(--rouge); padding-bottom:2mm; }
.ef .logo { width:14mm; height:14mm; flex:none; }
.ef-id { flex:1; min-width:0; }
.ef .wm-la, .ef .wm-de { font-size:11pt; } .ef .wm-ketchup { font-size:17pt; }
.ef-addr { font-size:6.4pt; color:#5a4b46; margin-top:.6mm; white-space:nowrap; }
.ef-addr .blank { height:.9em; }
.ef-titre { text-align:right; flex:none; }
.ef-titre h1 { font-size:17pt; }
.ef-st { font-size:7pt; color:#5a4b46; }
.ef-titre .num { font-size:14pt; }
"""


def pied(texte=None):
    texte = texte or E["signature"]
    return f'<div class="pied">{texte}</div>'


def montant_lettres():
    return f'<div class="field"><label>Montant en lettres :</label><div class="line"></div></div><div class="field"><div class="line"></div><label>{DEVISE}</label></div>'
