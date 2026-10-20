"""Formulaires de gestion : ventes, caisse, achats, stocks, crédits, personnel, pilotage."""
from brand import (doc, entete_formulaire, ENTETE_CSS, montant_lettres, logo, wordmark,
                   adresse, mentions, E, DEVISE)
from config import BILLETS, PIECES

CSS = ENTETE_CSS + """
.page.a4p { width:210mm; height:297mm; }
.page.a4l { width:297mm; height:210mm; }
.full { position:absolute; inset:10mm 12mm 12mm; display:flex; flex-direction:column; }
.full .pied { margin-top:auto; }
.aere table.grid td { height:7.6mm; }
.pied { text-align:center; font-family:'Playfair'; font-style:italic; font-size:7.5pt; color:var(--rouge-f);
  border-top:.5pt solid var(--rouge); padding-top:1.4mm; }
.slot { position:absolute; left:0; right:0; display:flex; border-bottom:.5pt dashed #8a7b76; }
.slot:last-child { border-bottom:none; }
.slot .main { flex:1; padding:6mm 9mm 5mm 7mm; display:flex; flex-direction:column; min-width:0; }
.slot .main .pied { margin-top:auto; }
.talon { width:40mm; flex:none; border-right:.5pt dashed #8a7b76; padding:6mm 4mm 5mm 7mm; position:relative; background:#fdf7ee; }
.talon .t-titre { font-family:'Bebas'; font-size:12pt; color:var(--rouge-f); letter-spacing:.06em; }
.talon .num { font-size:12pt; }
.talon .field { margin-top:2.6mm; } .talon .field label { font-size:7pt; }
.talon .cis { position:absolute; right:-2.2mm; top:4mm; font-size:9pt; color:#8a7b76; background:#fff; line-height:1; }
.talon .t-note { font-size:6pt; color:#6b5d58; position:absolute; bottom:5mm; left:7mm; right:4mm; }
.col2 { position:absolute; top:0; bottom:0; display:flex; flex-direction:column; padding:7mm 7mm 6mm; border-right:.5pt dashed #8a7b76; }
.col2:last-child { border-right:none; }
.compact .ef .logo { width:11mm; height:11mm; }
.compact .ef .wm-la, .compact .ef .wm-de { font-size:9pt; } .compact .ef .wm-ketchup { font-size:14pt; }
.compact .ef-titre h1 { font-size:14pt; } .compact .ef-titre .num { font-size:12pt; }
.compact .ef-addr { font-size:5.6pt; }
.ef-etroit .ef-addr { font-size:7pt; }
.col2 table.grid td { height:6.9mm; }
.compact .field { margin-top:3.4mm; }
.slot .sign { margin-top:9mm; }
.slot .cases { margin-top:3.4mm; }
.box-montant { display:inline-flex; align-items:center; gap:2mm; border:1pt solid var(--rouge); border-radius:1.5mm;
  padding:1.2mm 3mm; font-weight:700; }
.box-montant .b { width:34mm; height:5mm; }
.cases { margin-top:2.6mm; font-size:7.8pt; line-height:1.9; }
.cases b { font-weight:600; margin-right:1mm; }
.opt { white-space:nowrap; }
.sec-t { font-family:'Bebas'; font-size:12pt; letter-spacing:.06em; color:var(--rouge-f); margin-top:4mm; margin-bottom:1.2mm; }
.kpis { display:grid; grid-template-columns:repeat(6,1fr); gap:3mm; margin-top:3mm; }
.kpi { border:1pt solid var(--rouge); border-radius:2mm; padding:2mm 2.5mm; height:20mm; display:flex; flex-direction:column; }
.kpi span { font-size:7pt; font-weight:600; text-transform:uppercase; letter-spacing:.03em; color:var(--rouge-f); }
.kpi i { margin-top:auto; font-style:normal; font-size:7pt; color:#6b5d58; text-align:right; }
.texte-legal { font-size:10pt; line-height:2.1; margin-top:6mm; }
.texte-legal .blank { height:1.1em; }
.ck { columns:2; column-gap:8mm; font-size:9.8pt; line-height:1.5; }
.ck h3 { font-family:'Bebas'; font-weight:400; font-size:15pt; letter-spacing:.06em; color:#fff; background:var(--rouge);
  padding:.6mm 2.5mm 0; border-radius:1mm; margin:5mm 0 2.4mm; break-after:avoid; }
.ck li { list-style:none; padding-left:6mm; position:relative; margin-bottom:2.2mm; break-inside:avoid; }
.ck li::before { content:''; position:absolute; left:0; top:.9mm; width:2.8mm; height:2.8mm; border:.7pt solid var(--encre); }
.ck li em { font-style:normal; color:var(--rouge-f); font-weight:600; }
"""

MODES = ('<span class="opt"><span class="check"></span>Espèces</span><span class="opt"><span class="check"></span>MTN MoMo</span>'
         '<span class="opt"><span class="check"></span>Airtel Money</span><span class="opt"><span class="check"></span>Autre</span>')


def f(label, width=None):
    w = f' style="flex:none;width:{width}"' if width else ""
    return f'<div class="field"><label>{label}</label><div class="line"{w}></div></div>'


def row(*cells):
    return '<div class="row">' + "".join(cells) + "</div>"


def table(cols, n, widths=None, sections=None, foot=None):
    """Tableau vierge. sections = [(titre, nb_lignes)] remplace n."""
    widths = widths or [""] * len(cols)
    head = "".join(f'<th style="width:{w}">{c}</th>' if w else f"<th>{c}</th>" for c, w in zip(cols, widths))
    empty = "<tr>" + "<td></td>" * len(cols) + "</tr>"
    if sections:
        body = "".join(f'<tr><td class="sec" colspan="{len(cols)}">{t}</td></tr>' + empty * k for t, k in sections)
    else:
        body = empty * n
    tf = ""
    if foot:
        label, span = foot
        tf = (f'<tfoot><tr><td colspan="{span}" style="text-align:right">{label}</td>'
              + "<td></td>" * (len(cols) - span) + "</tr></tfoot>")
    return f'<table class="grid"><thead><tr>{head}</tr></thead><tbody>{body}</tbody>{tf}</table>'


def talon(titre, numero, champs, note=""):
    num = "N° ______" if numero is None else f"N° {numero:04d}"
    return (f'<div class="talon"><span class="cis">✂</span><div class="t-titre">Talon · {titre}</div>'
            f'<div class="num">{num}</div>' + "".join(f(c) for c in champs)
            + (f'<div class="t-note">{note}</div>' if note else "") + "</div>")


def pages_slots(render, numeros, per_page, fmt="a4p"):
    """Répartit des formulaires (1 par numéro) en `per_page` bandes horizontales par page A4."""
    h = 297 / per_page
    out = []
    for i in range(0, len(numeros), per_page):
        lot = numeros[i:i + per_page]
        slots = "".join(f'<div class="slot compact" style="top:{k * h}mm;height:{h}mm">{render(n)}</div>'
                        for k, n in enumerate(lot))
        out.append(f'<section class="page {fmt}">{slots}</section>')
    return "".join(out)


def pages_colonnes(render, numeros):
    out = []
    for i in range(0, len(numeros), 2):
        lot = numeros[i:i + 2]
        cols = "".join(f'<div class="col2 compact" style="left:{k * 105}mm;width:105mm">{render(n)}</div>'
                       for k, n in enumerate(lot))
        out.append(f'<section class="page a4p">{cols}</section>')
    return "".join(out)


def pleine_page(contenu, fmt="a4p", aere=False):
    return f'<section class="page {fmt}"><div class="full{' aere' if aere else ''}">{contenu}<div class="pied">{E["signature"]}</div></div></section>'


# ---------------------------------------------------------------- Ventes
def recu(n):
    return (talon("Reçu", n, ["Date", "Reçu de", "Montant", "Objet"]) +
            f"""<div class="main">{entete_formulaire("Reçu de caisse", n)}
            {row(f("Reçu de M. / Mme :"), f("Tél. :", "30mm"))}
            {montant_lettres()}
            {row(f("Pour (objet) :"), '<div class="field"><label>Montant :</label><span class="box-montant"><span class="b"></span>' + DEVISE + '</span></div>')}
            <div class="cases"><b>Mode :</b>{MODES}</div>
            <div class="sign"><div>Date</div><div>Caissier(ère)</div><div>Cachet</div></div><div class="pied">{E["signature"]}</div></div>""")


def note_table(n):
    num = "N° ______" if n is None else f"N° {n:04d}"
    return (f"""<div class="ef ef-etroit">{logo()}<div class="ef-id">{wordmark()}
        <div class="ef-addr">{E['type']} · {E['quartier']}, {E['ville']}</div></div></div>
      <div style="display:flex;justify-content:space-between;align-items:baseline;margin-top:2mm">
        <h1 class="doc-title" style="font-size:18pt">Addition</h1><span class="num" style="font-size:15pt">{num}</span></div>
      {row(f("Table :"), f("Couverts :"))}{row(f("Serveur :"), f("Date :"))}
      <div style="margin-top:3mm">{table(["Qté", "Désignation", "P.U.", "Montant"], 27, ["10mm", "", "16mm", "18mm"],
                                          foot=("TOTAL " + DEVISE, 3))}</div>
      <div class="cases"><b>Réglé :</b><span class="opt"><span class="check"></span>Espèces</span><span class="opt"><span class="check"></span>MoMo</span><span class="opt"><span class="check"></span>Airtel</span></div>
      <div class="note" style="margin-top:2mm;text-align:center">Merci et à bientôt ! Paiement à la commande — pas de crédit.</div>
      <div class="pied" style="margin-top:auto">{E['signature']}</div>""")


def facture(n):
    c = f"""{entete_formulaire("Facture", n)}
      <div class="row" style="margin-top:5mm">
        <div>{f("Date :")}{f("Mode de règlement :")}{f("Échéance :")}</div>
        <div style="border:1pt solid var(--rouge);border-radius:2mm;padding:1mm 4mm 3mm">
          <div class="sec-t" style="margin-top:1mm">Client</div>{f("Nom / Raison sociale :")}{f("Adresse :")}{f("Tél. :")}{f("NIU client :")}</div>
      </div>
      <div style="margin-top:6mm">{table(["N°", "Désignation", "Qté", "Prix unitaire", "Montant " + DEVISE],
                                          18, ["10mm", "", "18mm", "30mm", "34mm"])}</div>
      <table class="grid" style="width:64mm;margin:3mm 0 0 auto"><tbody>
        <tr><td style="font-weight:600">Sous-total</td><td style="width:34mm"></td></tr>
        <tr><td style="font-weight:600">Remise</td><td></td></tr>
        <tr><td style="font-weight:700;background:var(--creme)">TOTAL À PAYER</td><td style="background:var(--creme)"></td></tr></tbody></table>
      {montant_lettres().replace('Montant en lettres', 'Arrêtée la présente facture à la somme de')}
      <div class="sign" style="margin-top:12mm"><div>Le Client</div><div>La Direction (signature et cachet)</div></div>"""
    return pleine_page(c)


# ---------------------------------------------------------------- Caisse
CAT_ENTREE = ["Ventes du jour", "Remboursement crédit client", "Apport du gérant / propriétaire",
              "Vente d'emballages vides", "Autre entrée"]
CAT_SORTIE = ["Achat boissons", "Achat cuisine / denrées", "Salaire / avance", "Loyer",
              "Électricité / eau", "Transport", "Entretien / réparation", "Taxes / mairie", "Autre dépense"]


def piece_caisse(sens):
    cats = CAT_ENTREE if sens == "entree" else CAT_SORTIE
    titre = "Pièce de caisse — Entrée" if sens == "entree" else "Pièce de caisse — Sortie"
    qui = "Remis par :" if sens == "entree" else "Payé à (bénéficiaire) :"
    signe = "Remettant" if sens == "entree" else "Bénéficiaire"

    def render(n):
        return (talon("Entrée" if sens == "entree" else "Sortie", n,
                      ["Date", "Nom", "Motif", "Montant", "Catégorie"],
                      "À conserver dans le carnet. Reporter au brouillard de caisse.") +
                f"""<div class="main">{entete_formulaire(titre, n)}
                {row(f("Date :"), f("Heure :", "22mm"))}
                {f(qui)}{f("Motif :")}
                <div class="cases"><b>Catégorie :</b>{"".join(f'<span class="opt"><span class="check"></span>{c}</span>' for c in cats)}</div>
                {montant_lettres()}
                {row('<div class="field"><label>Montant :</label><span class="box-montant"><span class="b"></span>' + DEVISE + '</span></div>',
                     '<div class="cases"><b>Mode :</b>' + MODES + '</div>')}
                <div class="cases"><b>Justificatif joint :</b><span class="opt"><span class="check"></span>Oui (n° ________)</span><span class="opt"><span class="check"></span>Non</span></div>
                {f("Observations :")}
                <div class="sign" style="margin-top:12mm"><div>Caissier(ère)</div><div>{signe}</div><div>Visa Direction</div></div><div class="pied">{E["signature"]}</div></div>""")
    return render


def bon_sortie_interne(n):
    return (talon("Sortie int.", n, ["Date", "Bénéficiaire", "Articles", "Valeur"]) +
            f"""<div class="main">{entete_formulaire("Bon de sortie interne", n)}
            {row(f("Date :"), f("Bénéficiaire :"))}
            <div class="cases"><b>Motif :</b><span class="opt"><span class="check"></span>Offert client</span><span class="opt"><span class="check"></span>Consommation personnel
              </span><span class="opt"><span class="check"></span>Dégustation</span><span class="opt"><span class="check"></span>Cuisine</span><span class="opt"><span class="check"></span>Autre</span></div>
            <div style="margin-top:3mm">{table(["Article", "Qté", "Valeur " + DEVISE], 3, ["", "16mm", "30mm"], foot=("TOTAL", 2))}</div>
            <div class="sign" style="margin-top:7mm"><div>Demandeur</div><div>Visa Direction</div></div><div class="pied">{E["signature"]}</div></div>""")


def brouillard():
    c = f"""{entete_formulaire("Brouillard de caisse", False, "Journal quotidien des entrées et sorties")}
      {row(f("Date :"), f("Caissier(ère) :"), f("Solde d'ouverture (fonds de caisse) :"))}
      <div style="margin-top:4mm">{table(["Heure", "N° pièce", "Libellé de l'opération", "Catégorie", "Entrée " + DEVISE,
                                           "Sortie " + DEVISE, "Solde " + DEVISE, "Visa"],
                                          17, ["15mm", "18mm", "", "36mm", "28mm", "28mm", "28mm", "16mm"],
                                          foot=("TOTAUX DE LA JOURNÉE", 4))}</div>
      {row(f("Solde de clôture théorique :"), f("Solde réel compté :"), f("Écart :"))}
      <div class="sign" style="margin-top:7mm"><div>Caissier(ère)</div><div>Gérant(e)</div></div>"""
    return pleine_page(c, "a4l")


def cloture():
    lignes = "".join(f"<tr><td>Billet de {b:,}".replace(",", " ") + "</td><td></td><td></td></tr>" for b in BILLETS)
    lignes += "".join(f"<tr><td>Pièce de {p}</td><td></td><td></td></tr>" for p in PIECES)
    recap = [("Fonds de caisse à l'ouverture", "+"), ("Ventes encaissées en espèces", "+"),
             ("Autres entrées en espèces (pièces d'entrée)", "+"), ("Sorties en espèces (pièces de sortie)", "−"),
             ("Solde théorique en espèces", "="), ("Espèces réellement comptées (A)", ""),
             ("Écart (excédent + / manquant −)", "")]
    rec = "".join(f'<tr><td style="width:8mm;text-align:center;font-weight:700">{s}</td><td>{l}</td><td style="width:40mm"></td></tr>'
                  for l, s in recap)
    c = f"""{entete_formulaire("Clôture de caisse", False, "À remplir chaque soir, après le dernier service")}
      {row(f("Date :"), f("Caissier(ère) :"), f("Heure de clôture :"))}
      <div class="row" style="margin-top:2mm">
        <div><div class="sec-t">A. Comptage des espèces (billetage)</div>
          <table class="grid"><thead><tr><th>Coupure</th><th style="width:22mm">Nombre</th><th style="width:32mm">Montant {DEVISE}</th></tr></thead>
          <tbody>{lignes}</tbody><tfoot><tr><td colspan="2" style="text-align:right">TOTAL ESPÈCES (A)</td><td></td></tr></tfoot></table></div>
        <div><div class="sec-t">B. Paiements électroniques</div>
          <table class="grid"><thead><tr><th>Moyen</th><th style="width:22mm">Nb opér.</th><th style="width:32mm">Montant {DEVISE}</th></tr></thead>
          <tbody><tr><td>MTN Mobile Money</td><td></td><td></td></tr><tr><td>Airtel Money</td><td></td><td></td></tr>
          <tr><td>Carte / autre</td><td></td><td></td></tr></tbody>
          <tfoot><tr><td colspan="2" style="text-align:right">TOTAL (B)</td><td></td></tr></tfoot></table>
          <div class="sec-t">D. Chiffre d'affaires du jour</div>
          <table class="grid"><tbody><tr><td>Ventes espèces + électroniques</td><td style="width:32mm"></td></tr>
          <tr><td>Crédits accordés (exceptionnels)</td><td></td></tr><tr><td>Sorties internes (valeur)</td><td></td></tr></tbody></table>
        </div></div>
      <div class="sec-t">C. Rapprochement</div>
      <table class="grid"><tbody>{rec}</tbody></table>
      {f("Explication de l'écart :")}
      {row(f("Montant versé (banque / coffre / Direction) :"), f("Fonds laissé pour demain :"))}
      <div class="sign" style="margin-top:14mm"><div>Caissier(ère)</div><div>Gérant(e) — contrôle</div></div>"""
    return pleine_page(c, aere=True)


def bordereau(n):
    bl = "".join(f"<tr><td>{b:,}".replace(",", " ") + "</td><td></td><td></td></tr>" for b in BILLETS)
    return (talon("Versement", n, ["Date", "Versé par", "Destination", "Montant"]) +
            f"""<div class="main">{entete_formulaire("Bordereau de versement", n)}
            <div class="row"><div>{row(f("Date :"), f("Heure :", "20mm"))}{f("Versé par :")}{f("Reçu par :")}
              <div class="cases"><b>Destination :</b><span class="opt"><span class="check"></span>Banque</span><span class="opt"><span class="check"></span>Coffre
                </span><span class="opt"><span class="check"></span>Direction</span><span class="opt"><span class="check"></span>MoMo marchand</span></div>
              {f("Référence banque / opération :")}</div>
            <div style="flex:.8"><table class="grid" style="margin-top:3mm"><thead><tr><th>Billets</th><th>Nb</th><th>Montant</th></tr></thead>
              <tbody>{bl}<tr><td>Pièces</td><td></td><td></td></tr></tbody><tfoot><tr><td colspan="2">TOTAL</td><td></td></tr></tfoot></table></div></div>
            {montant_lettres()}
            <div class="sign" style="margin-top:6mm"><div>Déposant</div><div>Réceptionnaire</div><div>Visa Direction</div></div><div class="pied">{E["signature"]}</div></div>""")


# ---------------------------------------------------------------- Achats & stocks
def bon_commande(n):
    c = f"""{entete_formulaire("Bon de commande", n, "Fournisseur")}
      <div class="row" style="margin-top:4mm">
        <div>{f("Date de commande :")}{f("Livraison souhaitée le :")}{f("Commandé par :")}</div>
        <div style="border:1pt solid var(--rouge);border-radius:2mm;padding:1mm 4mm 3mm">
          <div class="sec-t" style="margin-top:1mm">Fournisseur</div>{f("Nom :")}{f("Tél. :")}{f("Adresse :")}</div></div>
      <div style="margin-top:5mm">{table(["N°", "Désignation", "Conditionnement", "Quantité", "Prix unitaire", "Montant " + DEVISE],
                                          18, ["9mm", "", "30mm", "18mm", "26mm", "30mm"], foot=("TOTAL DE LA COMMANDE", 5))}</div>
      <div class="sec-t">Emballages consignés</div>
      {row(f("Casiers vides rendus :"), f("Bouteilles vides rendues :"), f("Consigne à payer :"))}
      <div class="cases"><b>Paiement :</b><span class="opt"><span class="check"></span>Comptant à la livraison</span><span class="opt"><span class="check"></span>MoMo
        </span><span class="opt"><span class="check"></span>À crédit fournisseur — échéance : ____________</span></div>
      {f("Conditions / remarques :")}{f("")}
      <div class="sign" style="margin-top:14mm"><div>Demandeur</div><div>Approbation Direction</div><div>Fournisseur (accusé)</div></div>"""
    return pleine_page(c)


def bon_reception(n):
    c = f"""{entete_formulaire("Bon de réception", n, "Contrôle de la livraison")}
      <div class="row" style="margin-top:3mm"><div>{f("Date / heure de livraison :")}{f("Fournisseur :")}{f("Livreur :")}</div>
        <div>{f("Réf. bon de commande N° :")}{f("Réf. bon de livraison fournisseur :")}{f("Réceptionné par :")}</div></div>
      <div style="margin-top:5mm">{table(["Désignation", "Qté commandée", "Qté reçue", "Écart", "État", "Observations"],
                                          17, ["", "24mm", "20mm", "16mm", "22mm", "40mm"])}</div>
      <div class="note" style="margin-top:1.5mm">État : B = bon · A = abîmé / cassé · P = date proche ou périmée. Refuser ou noter tout produit abîmé AVANT de signer.</div>
      <div class="sec-t">Emballages</div>
      {row(f("Casiers livrés :"), f("Casiers vides repris :"), f("Bouteilles vides reprises :"))}
      <div class="cases"><b>Conclusion :</b><span class="opt"><span class="check"></span>Livraison conforme</span><span class="opt"><span class="check"></span>Livraison avec réserves
        </span><span class="opt"><span class="check"></span>Livraison refusée</span></div>
      <div class="sign" style="margin-top:10mm"><div>Réceptionnaire</div><div>Livreur</div><div>Visa Direction</div></div>"""
    return pleine_page(c)


def fiche_stock():
    c = f"""{entete_formulaire("Fiche de stock", False, "Une fiche par article")}
      {row(f("Article :"), f("Unité :", "28mm"))}{row(f("Stock minimum (alerte) :"), f("Prix d'achat :"), f("Prix de vente :"))}
      <div style="margin-top:4mm">{table(["Date", "Libellé (achat, vente, casse…)", "N° pièce", "Entrées", "Sorties", "Stock", "Visa"],
                                          30, ["18mm", "", "20mm", "18mm", "18mm", "18mm", "15mm"])}</div>"""
    return pleine_page(c)


def inventaire():
    c = f"""{entete_formulaire("Inventaire des stocks", False, "Comptage physique hebdomadaire")}
      {row(f("Date :"), f("Semaine du :"), f("Compté par :"), f("Contrôlé par :"))}
      <div style="margin-top:3mm">{table(["Désignation", "Unité", "Stock théorique", "Stock compté", "Écart", "Prix de vente",
                                           "Valeur de l'écart", "Observations"], 0,
                                          ["", "16mm", "24mm", "24mm", "16mm", "22mm", "26mm", "44mm"],
                                          sections=[("Bières", 5), ("Sucreries & eaux", 4), ("Vins & spiritueux", 3),
                                                    ("Cuisine / denrées", 3), ("Emballages vides (casiers, bouteilles)", 2)],
                                          foot=("TOTAL VALEUR DES ÉCARTS", 6))}</div>"""
    return pleine_page(c, "a4l")


def fiche_casse():
    c = f"""{entete_formulaire("Registre casses & pertes", False, "Casse, périmé, vol, erreur de service")}
      {row(f("Mois de :"), f("Responsable :"))}
      <div style="margin-top:4mm">{table(["Date", "Article", "Qté", "Cause", "Constaté par", "À la charge de", "Valeur " + DEVISE, "Visa"],
                                          28, ["16mm", "", "11mm", "24mm", "26mm", "26mm", "20mm", "13mm"],
                                          foot=("TOTAL DU MOIS", 6))}</div>
      <div class="note" style="margin-top:1.5mm">À la charge de : Maison · Employé (nom) · Client (nom). Une casse imputée à un employé est reportée sur sa fiche de paiement.</div>"""
    return pleine_page(c)


# ---------------------------------------------------------------- Crédits
def registre_credits():
    c = f"""{entete_formulaire("Registre des crédits clients", False, "Crédit exceptionnel, accordé par la Direction uniquement")}
      {row(f("Période du :"), f("au :"))}
      <div style="margin-top:3mm">{table(["N°", "Date", "Client", "Téléphone", "Détail", "Montant", "Échéance",
                                           "Remb. 1 (date/montant)", "Remb. 2 (date/montant)", "Reste dû", "Signature client"],
                                          17, ["9mm", "16mm", "", "24mm", "36mm", "20mm", "17mm", "28mm", "28mm", "18mm", "24mm"],
                                          foot=("TOTAUX", 5))}</div>
      <div class="note" style="margin-top:1.5mm">Règle : pas de nouveau crédit tant que le précédent n'est pas soldé. Au-delà de 15 jours, faire signer une reconnaissance de dette.</div>"""
    return pleine_page(c, "a4l")


def reconnaissance_dette():
    b = lambda w: f'<span class="blank" style="width:{w}"></span>'
    c = f"""{entete_formulaire("Reconnaissance de dette", False, "Établie en deux exemplaires originaux")}
      <div class="texte-legal">
      Je soussigné(e) {b("110mm")}<br>
      né(e) le {b("35mm")} à {b("100mm")}<br>
      pièce d'identité : <span class="opt"><span class="check"></span>CNI </span><span class="opt"><span class="check"></span>Passeport </span><span class="opt"><span class="check"></span>Autre</span> — n° {b("60mm")}<br>
      demeurant à {b("80mm")}, téléphone {b("45mm")}<br>
      reconnais devoir au <b>{E['type']} {E['nom']}</b>, sis {adresse()},<br>
      la somme de (en lettres) {b("125mm")}<br>
      {b("100mm")} soit (en chiffres) {b("30mm")} {DEVISE},<br>
      au titre de : <span class="opt"><span class="check"></span>consommations </span><span class="opt"><span class="check"></span>prêt d'argent</span> <span class="opt"><span class="check"></span>autre</span> : {b("62mm")}<br>
      Je m'engage à rembourser cette somme au plus tard le {b("40mm")}, selon l'échéancier ci-dessous :
      </div>
      <div style="margin-top:2mm">{table(["Échéance n°", "Date prévue", "Montant " + DEVISE, "Date payée", "Signature créancier"], 4,
                                          ["24mm", "", "", "", ""])}</div>
      <div class="texte-legal" style="margin-top:4mm">
      En cas de non-paiement à l'échéance, le créancier pourra engager toute procédure de recouvrement prévue par la loi.<br>
      Fait à {E['ville']}, le {b("40mm")}, en deux exemplaires.
      </div>
      <div class="sign" style="margin-top:4mm"><div>Le débiteur<br><span style="font-weight:400">Mention manuscrite : « Lu et approuvé, bon pour la somme de … {DEVISE} » (en lettres et en chiffres)</span></div>
        <div>Pour le créancier — La Direction</div><div>Témoin (nom et signature)</div></div>
      <div style="margin-top:auto;margin-bottom:4mm;height:48mm;border:1pt dashed var(--rouge);border-radius:2mm;display:flex;align-items:center;justify-content:center;color:var(--rouge-f);font-size:9pt">
        Agrafer ici la photocopie de la pièce d'identité du débiteur</div>"""
    return pleine_page(c)


# ---------------------------------------------------------------- Personnel
JOURS = ["Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi", "Samedi", "Dimanche"]


def planning():
    c = f"""{entete_formulaire("Planning hebdomadaire", False, "Horaires et postes du personnel")}
      {row(f("Semaine du :"), f("au :"), f("Établi par :"))}
      <div style="margin-top:4mm">{table(["Employé(e)", "Poste"] + JOURS + ["Total h"], 12,
                                          ["40mm", "24mm"] + ["24mm"] * 7 + ["15mm"])}</div>
      <div class="note" style="margin-top:2mm">Indiquer l'horaire (ex. 16h–00h) ou R = repos. Postes : Caisse · Service · Bar · Cuisine · Sécurité · Entretien.</div>
      <div class="sign" style="margin-top:8mm"><div>Gérant(e)</div><div>Direction</div></div>"""
    return pleine_page(c, "a4l")


def presence():
    jours = [str(d) for d in range(1, 32)]
    c = f"""{entete_formulaire("Fiche de présence mensuelle", False)}
      {row(f("Mois de :"), f("Année :"), f("Contrôlée par :"))}
      <div style="margin-top:4mm">{table(["Employé(e)"] + jours + ["Prés.", "Abs.", "Ret."], 16,
                                          ["38mm"] + ["5.6mm"] * 31 + ["10mm", "10mm", "10mm"])}</div>
      <div class="note" style="margin-top:2mm">Codes : P = présent · A = absent · R = retard · C = congé · M = malade (justificatif) · X = repos.</div>
      <div class="sign" style="margin-top:8mm"><div>Gérant(e)</div><div>Direction</div></div>"""
    return pleine_page(c, "a4l", aere=True)


def bon_avance(n):
    return (talon("Avance", n, ["Date", "Employé", "Montant", "Retenue sur"]) +
            f"""<div class="main">{entete_formulaire("Bon d'avance sur salaire", n)}
            {row(f("Date :"), f("Employé(e) :"))}{row(f("Poste :"), f("Salaire mensuel :"))}
            {montant_lettres()}
            {row('<div class="field"><label>Montant :</label><span class="box-montant"><span class="b"></span>' + DEVISE + '</span></div>',
                 f("Motif :"))}
            {row(f("Retenue sur le salaire de :"), f("En (nombre) mensualités de :"))}
            <div class="note" style="margin-top:2mm">Le total des avances du mois ne doit pas dépasser la moitié du salaire. Une seule avance en cours par employé.</div>
            <div class="sign" style="margin-top:6mm"><div>Employé(e) — « reçu la somme »</div><div>Caissier(ère)</div><div>Accord Direction</div></div><div class="pied">{E["signature"]}</div></div>""")


def fiche_paie():
    lg = lambda items: "".join(f'<tr><td>{x}</td><td style="width:22mm"></td><td style="width:34mm"></td></tr>' for x in items)
    c = f"""{entete_formulaire("Fiche de paiement de salaire", False, "Document interne")}
      <div class="row" style="margin-top:3mm"><div>{f("Employé(e) :")}{f("Poste :")}{f("Date d'embauche :")}</div>
        <div>{f("Période (mois) :")}{f("Jours travaillés :")}{f("N° CNSS (si déclaré) :")}</div></div>
      <div class="sec-t">Gains</div>
      <table class="grid"><thead><tr><th>Libellé</th><th>Base / nb</th><th>Montant {DEVISE}</th></tr></thead>
      <tbody>{lg(["Salaire de base", "Heures / jours supplémentaires", "Prime (assiduité, objectif…)", "Autre gain"])}</tbody>
      <tfoot><tr><td colspan="2" style="text-align:right">TOTAL BRUT</td><td></td></tr></tfoot></table>
      <div class="sec-t">Retenues</div>
      <table class="grid"><thead><tr><th>Libellé</th><th>Base / nb</th><th>Montant {DEVISE}</th></tr></thead>
      <tbody>{lg(["Avances sur salaire (bons n° …)", "Absences non justifiées", "Casses / manquants de caisse imputés", "Cotisation CNSS part salariale (si déclaré)", "Autre retenue"])}</tbody>
      <tfoot><tr><td colspan="2" style="text-align:right">TOTAL RETENUES</td><td></td></tr></tfoot></table>
      <table class="grid" style="margin-top:4mm"><tbody><tr><td style="font-weight:700;font-size:10pt;background:var(--creme)">NET À PAYER</td>
        <td style="width:56mm;background:var(--creme)"></td></tr></tbody></table>
      {montant_lettres()}
      <div class="cases"><b>Payé le</b> ____________ <b>par :</b>{MODES}</div>
      <div class="sign" style="margin-top:10mm"><div>Employé(e) — « reçu le net à payer »</div><div>La Direction</div></div>
      <div class="note" style="margin-top:8mm">Ce document interne ne remplace pas le bulletin de paie réglementaire lorsque l'employé est déclaré à la CNSS.</div>"""
    return pleine_page(c)


# ---------------------------------------------------------------- Pilotage
def tableau_bord():
    k = ["Chiffre d'affaires", "Dépenses totales", "Résultat du mois", "Crédits clients en cours",
         "Écarts de caisse cumulés", "Valeur du stock fin de mois"]
    kpis = "".join(f'<div class="kpi"><span>{x}</span><i>{DEVISE}</i></div>' for x in k)
    c = f"""{entete_formulaire("Tableau de bord mensuel", False, "Synthèse de pilotage — à remplir le 1er du mois suivant")}
      {row(f("Mois de :"), f("Établi par :"), f("Date :"))}
      <div class="kpis">{kpis}</div>
      <div class="row" style="margin-top:1mm"><div style="flex:1.5"><div class="sec-t">Activité par semaine</div>
        {table(["Semaine", "CA espèces", "CA MoMo / Airtel", "Achats", "Charges", "Résultat", "Écart caisse"], 5,
               ["18mm", "", "", "", "", "", ""], foot=("TOTAL", 1)).replace("<tr><td></td>", "<tr><td>S{}</td>", 5).format(1, 2, 3, 4, 5)}</div>
        <div><div class="sec-t">Dépenses par catégorie</div>
        {table(["Catégorie", "Montant", "% du CA"], 0, ["", "24mm", "16mm"],
               sections=[("Charges", 0)]).replace('<tr><td class="sec" colspan="3">Charges</td></tr>',
               "".join(f"<tr><td>{x}</td><td></td><td></td></tr>" for x in CAT_SORTIE))}</div></div>
      <div class="row"><div><div class="sec-t">5 produits les plus vendus</div>{table(["Produit", "Qté", "CA"], 5, ["", "16mm", "26mm"])}</div>
        <div><div class="sec-t">Points forts / problèmes / actions du mois prochain</div>
        {f("")}{f("")}{f("")}{f("")}{f("")}</div></div>"""
    return pleine_page(c, "a4l", aere=True)


def routine():
    sections = {
        "Ouverture (avant le service)": [
            "Compter le <em>fonds de caisse</em> et l'inscrire au <em>brouillard de caisse</em>.",
            "Vérifier les frigos, la glace et les stocks du jour (<em>fiche de stock</em>).",
            "Contrôler la présence du personnel (<em>fiche de présence</em>).",
            "S'assurer que les affiches sont en place et lisibles."],
        "Pendant le service": [
            "Chaque consommation est payée à la commande : utiliser l'<em>addition</em> par table.",
            "Remettre un <em>reçu de caisse</em> dès qu'un client le demande.",
            "Toute dépense = une <em>pièce de caisse sortie</em> signée + justificatif.",
            "Tout offert ou consommation du personnel = un <em>bon de sortie interne</em>.",
            "Toute casse = une ligne dans le <em>registre casses & pertes</em>.",
            "Aucun crédit sans accord de la Direction (<em>registre des crédits</em>)."],
        "Réception d'une livraison": [
            "Comparer avec le <em>bon de commande</em>, compter et vérifier l'état.",
            "Remplir le <em>bon de réception</em> avant de signer le bon du livreur.",
            "Reporter les entrées sur les <em>fiches de stock</em>.",
            "Payer avec une <em>pièce de caisse sortie</em>."],
        "Fermeture (chaque soir)": [
            "Compter les espèces : remplir la <em>fiche de clôture de caisse</em>.",
            "Expliquer tout écart et le faire signer par le gérant.",
            "Verser l'excédent (<em>bordereau de versement</em>), laisser le fonds pour demain.",
            "Ranger les carnets, pièces et justificatifs dans la chemise du jour."],
        "Chaque semaine": [
            "Faire l'<em>inventaire</em> physique des boissons et emballages.",
            "Comparer stock compté et stock théorique : expliquer les écarts.",
            "Préparer les <em>bons de commande</em> fournisseurs.",
            "Établir le <em>planning</em> de la semaine suivante.",
            "Relancer les crédits clients arrivés à échéance."],
        "Chaque mois": [
            "Saisir les chiffres dans le classeur Excel de pilotage.",
            "Remplir le <em>tableau de bord mensuel</em> et le présenter à la Direction.",
            "Calculer les salaires : <em>fiche de paiement</em> (avances, absences, casses).",
            "Archiver les carnets terminés (talons) par mois."],
    }
    body = "".join(f"<h3>{t}</h3><ul>" + "".join(f"<li>{x}</li>" for x in items) + "</ul>" for t, items in sections.items())
    c = f"""{entete_formulaire("Routine de gestion", False, "Qui fait quoi, quand, avec quel document")}
      <div class="ck" style="margin-top:3mm">{body}</div>
      <div style="margin-top:auto;margin-bottom:4mm;border:1.2pt solid var(--rouge);border-radius:2mm;padding:3mm 5mm;font-size:11pt;text-align:center;background:var(--creme)">
        Règle d'or : <b>pas d'argent qui entre ou qui sort sans papier.</b> Un papier = une signature.</div>"""
    return pleine_page(c)
