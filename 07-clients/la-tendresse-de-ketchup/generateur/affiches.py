"""Affiches A4 paysage à afficher dans le bar."""
from brand import doc, logo, wordmark, E, ROUGE, CREME, MOUTARDE, ROUGE_FONCE, ENCRE

CSS = """
.page.aff { width:297mm; height:210mm; background:var(--creme); }
.aff .cadre { position:absolute; inset:7mm; border:1.4mm solid var(--rouge); border-radius:4mm; }
.aff .cadre::after { content:''; position:absolute; inset:2.2mm; border:.5mm solid var(--rouge); border-radius:2.5mm; opacity:.45; }
.aff .haut { position:absolute; top:13mm; left:16mm; right:16mm; display:flex; align-items:center; gap:4mm; }
.aff .haut .logo { width:19mm; height:19mm; }
.aff .haut .wm-la, .aff .haut .wm-de { font-size:15pt; } .aff .haut .wm-ketchup { font-size:24pt; }
.aff .haut .rb { margin-left:auto; font-family:'Bebas'; font-size:13pt; letter-spacing:.18em; color:var(--rouge-f); }
.aff .centre { position:absolute; top:38mm; bottom:34mm; left:22mm; right:22mm; display:flex; align-items:center; gap:10mm; }
.aff .texte { flex:1; }
.aff .kicker { display:inline-block; font-family:'Bebas'; font-size:20pt; letter-spacing:.14em; color:#fff;
  background:var(--rouge); padding:1mm 4mm .2mm; border-radius:1.5mm; }
.aff .titre { font-family:'Playfair'; font-style:italic; font-weight:700; font-size:52pt; line-height:1.04;
  color:var(--encre); margin-top:5mm; }
.aff .titre em { color:var(--rouge); font-style:italic; }
.aff .sous { font-size:15pt; margin-top:5mm; color:#4a3c37; line-height:1.35; }
.aff .sous b { color:var(--rouge-f); }
.aff .bas { position:absolute; left:7mm; right:7mm; bottom:7mm; height:20mm; background:var(--rouge);
  border-radius:0 0 3mm 3mm; display:flex; align-items:center; justify-content:center; gap:5mm;
  color:#fff; font-family:'Playfair'; font-style:italic; font-size:15pt; }
.aff .bas .sep { width:2.2mm; height:2.2mm; background:var(--moutarde); transform:rotate(45deg); }
.aff .bas b { font-family:'Bebas'; font-style:normal; font-weight:400; letter-spacing:.12em; font-size:17pt; }
.aff .illu { flex:none; }
/* coupons */
.page.coupons { width:210mm; height:297mm; display:grid; grid-template-columns:1fr 1fr; grid-template-rows:repeat(5,1fr); }
.coupon { border:.4pt dashed #9c8d88; padding:4mm; }
.coupon .in { height:100%; background:var(--creme); border:1mm solid var(--rouge); border-radius:3mm; position:relative;
  display:flex; flex-direction:column; align-items:center; justify-content:center; text-align:center; padding:2mm 4mm; }
.coupon .logo { width:12mm; height:12mm; position:absolute; top:2mm; left:2mm; }
.coupon .c-k { font-family:'Bebas'; font-size:15pt; letter-spacing:.2em; color:var(--rouge-f); }
.coupon .c-t { font-family:'Playfair'; font-style:italic; font-weight:700; font-size:27pt; line-height:1; color:var(--rouge); }
.coupon .c-s { font-size:9pt; margin-top:1.5mm; color:#4a3c37; }
.coupon .c-f { font-size:7pt; margin-top:1.5mm; font-weight:600; color:var(--encre); }
/* règlement */
.regles { columns:2; column-gap:12mm; margin-top:4mm; font-size:12pt; line-height:1.3; }
.regles li { list-style:none; break-inside:avoid; margin-bottom:3.2mm; padding-left:10mm; position:relative; }
.regles li span { position:absolute; left:0; top:-.5mm; font-family:'Bebas'; font-size:17pt; color:var(--rouge); }
/* prix */
.prix { display:grid; grid-template-columns:1fr 1fr; column-gap:10mm; width:100%; }
.prix h3 { font-family:'Bebas'; font-weight:400; font-size:17pt; letter-spacing:.1em; color:#fff; background:var(--rouge-f);
  padding:.6mm 3mm 0; margin-top:2.5mm; border-radius:1mm; }
.prix .l { display:flex; align-items:flex-end; gap:2mm; height:7.6mm; font-size:10pt; }
.prix .l .d { flex:1; border-bottom:.6pt dotted #6b5d58; height:100%; }
.prix .l .p { width:26mm; border-bottom:.6pt solid var(--encre); height:100%; text-align:right; font-family:'Bebas'; }
"""


def affiche(kicker, titre, sous="", illu=""):
    return f"""<section class="page aff"><div class="cadre"></div>
      <div class="haut">{logo()}{wordmark()}<div class="rb">Restaurant · Bar — {E['ville']}</div></div>
      <div class="centre"><div class="texte"><div class="kicker">{kicker}</div>
        <div class="titre">{titre}</div><div class="sous">{sous}</div></div>
        {f'<div class="illu">{illu}</div>' if illu else ''}</div>
      <div class="bas"><span>Restaurant-Bar <b>La Tendresse de Ketchup</b></span><span class="sep"></span><span>La Direction</span></div>
    </section>"""


def page_libre(kicker, titre, contenu):
    return f"""<section class="page aff"><div class="cadre"></div>
      <div class="haut">{logo()}{wordmark()}<div class="rb">Restaurant · Bar — {E['ville']}</div></div>
      <div class="centre" style="top:36mm;align-items:flex-start;flex-direction:column;gap:0">
        <div><span class="kicker">{kicker}</span>
        <span style="font-family:'Playfair';font-style:italic;font-weight:700;font-size:26pt;margin-left:4mm">{titre}</span></div>
        {contenu}</div>
      <div class="bas"><span>Restaurant-Bar <b>La Tendresse de Ketchup</b></span><span class="sep"></span><span>La Direction</span></div>
    </section>"""


ILLU_POIGNEE = f"""<svg width="78mm" height="78mm" viewBox="0 0 200 200">
  <circle cx="100" cy="100" r="92" fill="#fff" stroke="{ROUGE}" stroke-width="5"/>
  <text x="100" y="112" text-anchor="middle" font-family="Playfair" font-style="italic" font-weight="700"
        font-size="96" fill="{ROUGE}">«»</text>
  <text x="100" y="146" text-anchor="middle" font-family="Bebas" font-size="21" letter-spacing="2" fill="{ROUGE_FONCE}">AMI OUI</text>
  <text x="100" y="168" text-anchor="middle" font-family="Bebas" font-size="21" letter-spacing="2" fill="{ROUGE_FONCE}">CRÉDIT NON</text>
</svg>"""

ILLU_TICKET = f"""<svg width="92mm" height="60mm" viewBox="0 0 230 150">
  <path d="M10 10 H220 V60 a15 15 0 0 0 0 30 V140 H10 V90 a15 15 0 0 0 0 -30 Z" fill="#fff" stroke="{ROUGE}" stroke-width="4"/>
  <line x1="62" y1="16" x2="62" y2="134" stroke="{ROUGE}" stroke-width="2" stroke-dasharray="5 5"/>
  <text x="36" y="80" text-anchor="middle" font-family="Bebas" font-size="18" fill="{ROUGE_FONCE}"
        transform="rotate(-90 36 75)">N° DEMAIN</text>
  <text x="142" y="50" text-anchor="middle" font-family="Bebas" font-size="20" letter-spacing="3" fill="{ROUGE_FONCE}">BON POUR</text>
  <text x="142" y="88" text-anchor="middle" font-family="Playfair" font-style="italic" font-weight="700" font-size="30" fill="{ROUGE}">revenir</text>
  <text x="142" y="118" text-anchor="middle" font-family="Playfair" font-style="italic" font-weight="700" font-size="30" fill="{ROUGE}">demain</text>
</svg>"""

ILLU_VILLAGE = f"""<svg width="88mm" height="98mm" viewBox="0 0 200 222">
  <rect x="92" y="40" width="14" height="178" rx="3" fill="{ENCRE}"/>
  <path d="M30 52 H160 L188 76 L160 100 H30 Z" fill="{ROUGE}" stroke="{ROUGE_FONCE}" stroke-width="3"/>
  <text x="100" y="86" text-anchor="middle" font-family="Bebas" font-size="34" letter-spacing="4" fill="#fff">VILLAGE</text>
  <path d="M170 112 H40 L14 134 L40 156 H170 Z" fill="{MOUTARDE}" stroke="{ENCRE}" stroke-width="2"/>
  <text x="102" y="142" text-anchor="middle" font-family="Bebas" font-size="21" letter-spacing="2" fill="{ENCRE}">ALLER SIMPLE</text>
  <ellipse cx="99" cy="218" rx="50" ry="4" fill="{ENCRE}" opacity=".15"/>
</svg>"""

ILLU_18 = f"""<svg width="78mm" height="78mm" viewBox="0 0 200 200">
  <circle cx="100" cy="100" r="90" fill="#fff" stroke="{ROUGE}" stroke-width="14"/>
  <text x="100" y="134" text-anchor="middle" font-family="Bebas" font-size="104" fill="{ENCRE}">-18</text>
</svg>"""


def build():
    pages = [
        affiche("Avis à la clientèle",
                "Ne profitez pas<br>de nos relations<br>pour <em>me faire tomber.</em>",
                "Ici, l'amitié est gratuite… <b>la boisson, non.</b><br>Merci de votre compréhension.",
                ILLU_POIGNEE),
        affiche("Le crédit ?",
                "Bon pour<br><em>revenir demain.</em>",
                "Aujourd'hui, on paie comptant.<br>Demain ? <b>On verra demain.</b>",
                ILLU_TICKET),
        affiche("Petite histoire vraie",
                "Il faisait crédit<br>à ses clients…",
                "<b style='font-size:24pt;font-family:Playfair;font-style:italic'>(Retour au village)</b><br>"
                "Nous, on aime Brazzaville. Merci de payer comptant.",
                ILLU_VILLAGE),
        affiche("Respect de la loi",
                "Pas d'alcool<br>aux <em>moins de 18 ans.</em>",
                "La maison ne sert pas de boissons alcoolisées aux mineurs.<br>"
                "<b>Une pièce d'identité peut être demandée.</b>",
                ILLU_18),
        affiche("Règle de la maison",
                "Ici, on paie<br><em>à la commande.</em>",
                "Chaque consommation est réglée dès qu'elle est servie.<br>"
                "<b>C'est bon pour vous, c'est bon pour nous.</b>"),
        affiche("Attention",
                "Surveillez<br><em>vos affaires.</em>",
                "La maison décline toute responsabilité en cas de perte<br>"
                "ou de vol d'objets personnels (téléphones, sacs, clés…)."),
        page_libre("Règlement", "intérieur de la maison", """<ol class="regles">
          <li><span>01</span>Toute consommation est payée à la commande. Pas de crédit.</li>
          <li><span>02</span>Pas d'alcool aux mineurs de moins de 18 ans.</li>
          <li><span>03</span>Respect du personnel et des autres clients en toutes circonstances.</li>
          <li><span>04</span>Les bagarres, insultes et menaces entraînent l'exclusion immédiate.</li>
          <li><span>05</span>Aucune boisson ni nourriture extérieure n'est acceptée.</li>
          <li><span>06</span>La casse de verres ou de bouteilles est à la charge du client.</li>
          <li><span>07</span>Les armes et produits illicites sont strictement interdits.</li>
          <li><span>08</span>La maison n'est pas responsable des objets oubliés ou perdus.</li>
          <li><span>09</span>Merci de demander un reçu pour chaque paiement.</li>
          <li><span>10</span>Toute réclamation est adressée à la Direction, avec calme.</li>
        </ol>"""),
        page_libre("Carte", "des prix (en FCFA)", '<div class="prix">' + "".join(
            f'<div><h3>{cat}</h3>' + '<div class="l"><div class="d"></div><div class="p"></div></div>' * n + '</div>'
            for cat, n in (("Bières", 7), ("Sucreries & eaux", 7), ("Vins & spiritueux", 5), ("Cuisine", 5))) + "</div>"),
        page_libre("Horaires", "d'ouverture", '<div class="prix" style="margin-top:4mm">' + "".join(
            f'<div class="l" style="height:12mm;font-size:16pt"><b style="width:40mm;font-family:Bebas;letter-spacing:.08em;color:{ROUGE_FONCE}">{j}</b>'
            f'<div class="d"></div><span>à</span><div class="d"></div></div>'
            for j in ("Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi", "Samedi", "Dimanche", "Jours fériés")) + "</div>"),
    ]
    return doc("Affiches", "".join(pages), CSS, "A4 landscape")


def build_coupons():
    c = f"""<div class="coupon"><div class="in">{logo()}
      <div class="c-k">Bon pour</div><div class="c-t">revenir demain</div>
      <div class="c-s">Valable tous les jours… sauf aujourd'hui.</div>
      <div class="c-f">Restaurant-Bar La Tendresse de Ketchup — La Direction</div></div></div>"""
    return doc("Bons pour revenir demain", f'<section class="page coupons">{c * 10}</section>', CSS)
