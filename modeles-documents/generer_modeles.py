import pathlib
OUT=pathlib.Path(__file__).parent
NAVY='#0B1F3A';GOLD='#C9A227';BLUE='#1B3A6B';LAB='#EEF1F8';LINE='#C9CFDB'
CSS=f"""@page{{size:A4;margin:0}}
body{{margin:0;font-family:'Times New Roman','Liberation Serif',serif;color:#1B2433;font-size:10pt}}
.page{{width:210mm;height:297mm;box-sizing:border-box;padding:12mm 13mm 8mm;display:flex;flex-direction:column;page-break-after:always;background:#fff}}
.head{{background:{NAVY};display:grid;grid-template-columns:1fr 1fr;border-bottom:3px solid {GOLD}}}
.head>div{{padding:5mm}}
.head>div+div{{border-left:1px solid #2E4670}}
.box{{background:#fff;border:1px solid #9AA6BC;padding:3mm 4mm}}
.logo{{height:18mm;display:flex;align-items:center;justify-content:center;gap:3mm}}
.sub{{color:#fff;font-weight:bold;font-size:8.5pt;margin-top:3mm}}
.title{{text-align:right}}
.title h1{{margin:0 0 1.5mm;font-size:17pt;color:{BLUE};letter-spacing:.02em}}
.title div{{font-size:8.5pt;color:#55627A;font-weight:bold;line-height:1.5}}
.title b{{color:#1B2433}}
h2{{font-size:11pt;color:{BLUE};margin:4mm 0 1.5mm}}
h2 span{{color:{GOLD}}}
table{{width:100%;border-collapse:collapse;font-size:8.5pt}}
td,th{{border:1px solid {LINE};padding:0 2mm;height:7mm}}
th{{background:{NAVY};color:#fff;font-weight:bold;height:8mm}}
td.l{{background:{LAB};color:{BLUE};font-weight:bold;width:28%}}
td.n{{text-align:center;color:{BLUE};font-weight:bold;width:7mm}}
td.big{{height:13mm;vertical-align:top;padding-top:2mm}}
td.sig{{background:{LAB};color:{BLUE};font-weight:bold;vertical-align:top;height:18mm;padding-top:2mm;width:50%}}
.r{{text-align:right}}
.tot td{{height:7mm}}
.tot tr:last-child td{{background:{NAVY};color:#fff;font-weight:bold}}
.foot{{margin-top:auto;border-top:1px solid #D5DAE3;padding-top:3mm;text-align:center;font-size:7.5pt;color:#8A93A3;line-height:1.5}}"""
LOGO=f'''<div class="box logo"><div style="font-size:26pt;font-weight:bold;color:{NAVY};letter-spacing:.04em;line-height:1">STFC<div style="height:2.2px;background:{GOLD};margin-top:1mm;border-radius:2px"></div></div><div style="font-style:italic;color:{GOLD};font-size:15pt;font-weight:bold;margin-top:2mm">Expertise</div></div>'''
FOOT='''<div class="foot">STRAT FOCUS CONSULTING — République du Congo — RCCM CG-PNR-01-2025-A11-00010 — NIU [à compléter]<br>Zone OCI, 200 m du Parc Culture, Q. MPITA — Pointe-Noire — Tél : 066 000 066 / 069 740 088 / 050 772 525 — stratfocusconsulting@gmail.com</div>'''
def head(title,lines):
    meta=''.join(f'<div>{a} : <b>{b}</b></div>' for a,b in lines)
    return f'<div class="head"><div>{LOGO}<div class="sub">Cabinet de conseil — Performance commerciale &amp; Stratégie marketing</div></div><div><div class="box title"><h1>{title}</h1>{meta}</div></div></div>'
def h2(n,t): return f'<h2><span>{n}.</span> {t}</h2>'
def kv(rows):  # pairs of 2 per row
    out=''
    for a,b in rows: out+=f'<tr><td class="l">{a}</td><td></td><td class="l" style="width:18%">{b}</td><td></td></tr>'
    return f'<table>{out}</table>'
def grid(cols,n,widths=None):
    th=''.join(f'<th style="{("width:"+widths[i]) if widths and widths[i] else ""}">{c}</th>' for i,c in enumerate(cols))
    rows=''.join('<tr><td class="n">%d</td>'%(i+1)+'<td></td>'*(len(cols)-1)+'</tr>' for i in range(n))
    return f'<table><tr>{th}</tr>{rows}</table>'
def ind(cols,labels):
    th=''.join(f'<th>{c}</th>' for c in cols)
    rows=''.join(f'<tr><td class="l">{l}</td>'+'<td></td>'*(len(cols)-1)+'</tr>' for l in labels)
    return f'<table><tr>{th}</tr>{rows}</table>'
def totals(last):
    rows=[('Total HT',''),('TVA 18 %',''),('Centime additionnel (5 % de la TVA)',''),(last,'')]
    return '<div style="display:flex;justify-content:flex-end;margin-top:2mm"><table class="tot" style="width:55%">'+''.join(f'<tr><td class="l" style="width:60%">{a}</td><td class="r">FCFA</td></tr>' if i<3 else f'<tr><td>{a}</td><td class="r">FCFA</td></tr>' for i,(a,b) in enumerate(rows))+'</table></div>'
def big(): return '<table><tr><td class="big"></td></tr></table>'
def valid(a,b): return f'<table><tr><td class="sig">{a}</td><td class="sig">{b}</td></tr></table>'
PREST=['N°','Désignation de la prestation','Qté','P.U. HT (FCFA)','Montant HT (FCFA)']
W=[None,'48%','9%','17%','19%']
pages=[]
pages.append(head('BON DE COMMANDE',[('N°','BC-……/2026'),('Date','……/……/2026'),('Consultant','…………………………')])+
 h2(1,'Client')+kv([('Raison sociale','NIU'),('Nom du contact','Téléphone'),('Adresse','E-mail')])+
 h2(2,'Prestations commandées')+grid(PREST,5,W)+totals('TOTAL TTC')+
 h2(3,'Modalités')+kv([('Date de démarrage','Durée'),('Mode de paiement','Acompte versé')])+
 h2(4,'Validation')+valid('Signature et cachet du client','Visa Strat Focus Consulting')+FOOT)
pages.append(head('DEVIS',[('N°','DEV-……/2026'),('Date','……/……/2026'),('Validité','30 jours')])+
 h2(1,'Client')+kv([('Raison sociale','NIU'),('Nom du contact','Téléphone'),('Objet de la mission','E-mail')])+
 h2(2,'Proposition financière')+grid(PREST,5,W)+totals('TOTAL TTC')+
 h2(3,'Conditions')+kv([('Délai d’exécution','Acompte'),('Conditions de paiement','Solde')])+
 h2(4,'Bon pour accord')+valid('Date, signature et cachet du client','Visa Strat Focus Consulting')+FOOT)
pages.append(head('FACTURE',[('N°','FAC-……/2026'),('Date','……/……/2026'),('Échéance','……/……/2026')])+
 h2(1,'Client')+kv([('Raison sociale','NIU'),('Adresse','Réf. devis / BC')])+
 h2(2,'Détail des prestations')+grid(PREST,5,W)+totals('NET À PAYER')+
 h2(3,'Règlement')+kv([('Banque','RIB'),('Mobile Money','Référence à rappeler')])+
 h2(4,'Validation')+valid('Arrêtée la présente facture à la somme de :','Cachet et signature Strat Focus Consulting')+FOOT)
pages.append(head('RAPPORT DE MISSION',[('Consultant','…………………………'),('Date','……/……/2026'),('Service','Audit / Croissance / Academy / Digitalisation')])+
 h2(1,'Identification')+kv([('Client','Interlocuteur'),('Mission','Durée (h)')])+
 h2(2,'Activités réalisées')+grid(['N°','Activité','Participants','Durée','Résultat / suite à donner'],4,[None,'34%','20%','10%','30%'])+
 h2(3,'Indicateurs de la mission')+ind(['Indicateur','Objectif','Réalisé','Écart'],['Ateliers / entretiens réalisés','Livrables remis','Actions validées par le client','Satisfaction client (/10)'])+
 h2(4,'Points d’attention')+big()+
 h2(5,'Prochaines étapes')+grid(['N°','Action prévue','Responsable','Échéance'],3,[None,'50%','22%','20%'])+
 h2(6,'Validation')+valid('Signature du consultant','Visa du client')+FOOT)
html=f'<!doctype html><html lang="fr"><head><meta charset="utf-8"><title>STFC – Documents</title><style>{CSS}</style></head><body>'+''.join(f'<div class="page">{p}</div>' for p in pages)+'</body></html>'
(OUT/'STFC_Documents.html').write_text(html)
