// Génération PDF : certificats personnalisés et cours téléchargeables (lecture hors connexion).
const PDFDocument = require('pdfkit');
const config = require('./config');

const NAVY = '#0b2545', GOLD = '#c8892b', INK = '#1d2433', MUTED = '#5b6475', SOFT = '#eef1f6';

// Les polices standard PDF couvrent le jeu Windows-1252 : on remplace ou retire les autres caractères.
const CP1252 = new Set('€‚ƒ„…†‡ˆ‰Š‹ŒŽ‘’“”•–—˜™š›œžŸ');
const REPLACE = { '→': '->', '←': '<-', '↑': '^', '↓': 'v', '➜': '->', '⬇': 'v', '✓': '-', '✔': '-', '−': '-', '≈': '~', 'ᵉ': 'e', ' ': ' ', '≥': '>=', '≤': '<=', '×': 'x' };
function clean(s) {
  return Array.from(String(s == null ? '' : s)).map(ch => {
    if (REPLACE[ch]) return REPLACE[ch];
    const c = ch.codePointAt(0);
    return c < 256 || CP1252.has(ch) ? ch : '';
  }).join('').replace(/ {2,}/g, ' ').trim();
}
const plain = s => clean(s).replace(/\*\*/g, '');
const fmtDate = iso => new Date(iso).toLocaleDateString('fr-FR', { day: 'numeric', month: 'long', year: 'numeric' });

/* ------------------------------------------------------------------ *
 *  Certificat / attestation (A4 paysage)
 * ------------------------------------------------------------------ */
function certificate(cert, { subtitle, skills }) {
  const doc = new PDFDocument({ size: 'A4', layout: 'landscape', margin: 0, info: { Title: `${cert.kind === 'module' ? 'Attestation' : 'Certificat'} ${cert.ref}`, Author: config.brand } });
  const W = doc.page.width, H = doc.page.height, cx = W / 2 + 6;
  doc.rect(0, 0, W, H).fill('#fffdf8');
  doc.lineWidth(10).strokeColor(NAVY).rect(20, 20, W - 40, H - 40).stroke();
  doc.lineWidth(2).strokeColor(GOLD).rect(40, 40, W - 80, H - 80).stroke();
  doc.rect(40, 40, 14, H - 80).fill(NAVY); doc.rect(54, 40, 4, H - 80).fill(GOLD);
  const center = (text, y, opts = {}) => doc.text(clean(text), 70, y, { width: W - 140, align: 'center', ...opts });

  doc.fillColor(NAVY).font('Helvetica-Bold').fontSize(20); center(config.brand.toUpperCase(), 72);
  doc.fillColor(MUTED).font('Helvetica').fontSize(10); center(`par ${config.org} - Performance commerciale, marketing et innovation`, 98);
  doc.fillColor(GOLD).font('Times-Bold').fontSize(36); center(cert.kind === 'module' ? 'ATTESTATION DE RÉUSSITE' : 'CERTIFICAT PROFESSIONNEL', 140);
  doc.fillColor(INK).font('Times-Italic').fontSize(15); center('décerné(e) à', 192);

  let size = 44; doc.font('Times-Bold').fontSize(size);
  while (doc.widthOfString(clean(cert.full_name)) > W - 220 && size > 22) doc.fontSize(--size);
  doc.fillColor(NAVY); center(cert.full_name, 222);
  doc.moveTo(cx - 220, 280).lineTo(cx + 220, 280).lineWidth(1.5).strokeColor(GOLD).stroke();

  doc.fillColor(INK).font('Times-Roman').fontSize(15);
  center(cert.kind === 'module' ? 'pour avoir suivi et validé le module' : 'pour avoir validé l’ensemble des modules du parcours', 300);
  doc.fillColor(NAVY).font('Times-Bold').fontSize(24); center(`« ${cert.title} »`, 326);
  doc.fillColor(MUTED).font('Helvetica').fontSize(11);
  center(subtitle + (cert.score != null ? ` - Score obtenu : ${cert.score} %` : ''), doc.y + 8);
  if (skills && skills.length) { doc.fillColor(INK).font('Helvetica-Bold').fontSize(10); center('Compétences validées : ' + skills.join(' · '), doc.y + 10); }

  // Pied : date + référence, sceau, signature
  doc.fillColor(INK).font('Helvetica').fontSize(10);
  doc.text(clean(`Délivré le ${fmtDate(cert.issued_at)}`), 90, H - 128);
  doc.text(`Référence : ${cert.ref}`, 90, H - 112);
  doc.fillColor(MUTED).fontSize(8).text(clean(`Vérification : ${config.baseUrl}/#/verifier/${cert.ref}`), 90, H - 96, { width: 300 });

  const sx = cx, sy = H - 112;
  doc.save().fillColor(GOLD);
  const pts = []; for (let k = 0; k < 24; k++) { const r = k % 2 ? 38 : 45, a = k / 24 * Math.PI * 2; pts.push([sx + r * Math.cos(a), sy + r * Math.sin(a)]); }
  doc.polygon(...pts).fill(); doc.circle(sx, sy, 32).fill(NAVY); doc.restore();
  doc.fillColor('#ffffff').font('Helvetica-Bold').fontSize(13).text('STFC', sx - 30, sy - 10, { width: 60, align: 'center' });
  doc.fontSize(7).text('ACADEMY', sx - 30, sy + 5, { width: 60, align: 'center' });

  doc.moveTo(W - 300, H - 120).lineTo(W - 90, H - 120).lineWidth(1).strokeColor(INK).stroke();
  doc.fillColor(INK).font('Helvetica-Bold').fontSize(11).text(clean(config.signatory.name), W - 300, H - 112, { width: 210, align: 'right' });
  doc.fillColor(MUTED).font('Helvetica').fontSize(9).text(clean(config.signatory.title), W - 300, H - 97, { width: 210, align: 'right' });
  doc.fontSize(7).text('Certification professionnelle privée - ne constitue pas un diplôme d’État.', 70, H - 52, { width: W - 140, align: 'center' });
  doc.end();
  return doc;
}

/* ------------------------------------------------------------------ *
 *  Cours complet d'un module (A4 portrait)
 * ------------------------------------------------------------------ */
function course(m, trackTitle, learnerName) {
  const doc = new PDFDocument({ size: 'A4', margins: { top: 56, bottom: 56, left: 50, right: 50 }, bufferPages: true, info: { Title: `${m.id} - ${plain(m.title)}`, Author: config.brand } });
  const L = doc.page.margins.left, CW = doc.page.width - L - doc.page.margins.right;
  const bottom = () => doc.page.height - doc.page.margins.bottom;
  const ensure = h => { if (doc.y + h > bottom()) doc.addPage(); };

  // Texte avec **gras** en ligne
  function rich(text, opts = {}, size = 10.5, x = L, width = CW) {
    const parts = clean(text).split('**');
    doc.fontSize(size).fillColor(opts.color || INK);
    const startY = doc.y;
    parts.forEach((p, i) => {
      doc.font(i % 2 ? 'Helvetica-Bold' : (opts.font || 'Helvetica'));
      const last = i === parts.length - 1;
      if (i === 0) doc.text(p, x, startY, { width, continued: !last, lineGap: 2 });
      else doc.text(p, { continued: !last, lineGap: 2 });
    });
    if (!parts.length) doc.text('');
  }
  const h = (text, size, color = NAVY, gap = 8) => { ensure(size * 3); doc.moveDown(0.6); doc.font('Helvetica-Bold').fontSize(size).fillColor(color).text(plain(text), L, doc.y, { width: CW }); doc.moveDown(gap / 20); };
  const para = text => { ensure(30); rich(text); doc.moveDown(0.5); };
  const bullets = (items, numbered) => items.forEach((it, i) => {
    ensure(24); const y = doc.y;
    doc.font('Helvetica-Bold').fontSize(10.5).fillColor(GOLD).text(numbered ? `${i + 1}.` : '•', L, y, { width: 18 });
    doc.y = y; rich(it, {}, 10.5, L + 20, CW - 20); doc.moveDown(0.25);
  });

  function table(head, rows, caption) {
    if (caption) { ensure(40); doc.font('Helvetica-Bold').fontSize(10).fillColor(INK).text(plain(caption), L, doc.y, { width: CW }); doc.moveDown(0.3); }
    const n = head.length, colW = CW / n, pad = 4;
    const rowH = cells => Math.max(...cells.map(c => doc.font('Helvetica').fontSize(8.5).heightOfString(plain(c), { width: colW - pad * 2 }))) + pad * 2;
    const drawRow = (cells, header) => {
      const hgt = rowH(cells); if (doc.y + hgt > bottom()) doc.addPage();
      const y = doc.y;
      cells.forEach((c, i) => {
        const x = L + i * colW;
        doc.rect(x, y, colW, hgt).fillAndStroke(header ? NAVY : i === 0 ? SOFT : '#ffffff', '#d5dbe5');
        doc.fillColor(header ? '#ffffff' : INK).font(header || i === 0 ? 'Helvetica-Bold' : 'Helvetica').fontSize(8.5).text(plain(c), x + pad, y + pad, { width: colW - pad * 2 });
      });
      doc.y = y + hgt; doc.x = L;
    };
    drawRow(head, true); rows.forEach(r => drawRow(r, false)); doc.moveDown(0.8);
  }

  function block(b) {
    switch (b.t) {
      case 'p': return para(b.x);
      case 'h': return h(b.x, 12, INK);
      case 'list': bullets(b.items); return doc.moveDown(0.3);
      case 'steps': bullets(b.items.map(s => `**${s.title}** : ${s.x}`), true); return doc.moveDown(0.3);
      case 'table': return table(b.head, b.rows, b.caption);
      case 'matrix': {
        ensure(230); if (b.caption) { doc.font('Helvetica-Bold').fontSize(10).fillColor(INK).text(plain(b.caption), L, doc.y, { width: CW }); doc.moveDown(0.3); }
        const y0 = doc.y, bw = (CW - 30) / 2, bh = 92, colors = ['#e3eefb', '#e5f4ec', '#f3eefa', '#fdf0e1'];
        b.q.forEach((q, i) => {
          const x = L + 24 + (i % 2) * (bw + 6), y = y0 + Math.floor(i / 2) * (bh + 6);
          doc.rect(x, y, bw, bh).fill(colors[i]);
          doc.fillColor(NAVY).font('Helvetica-Bold').fontSize(9.5).text(plain(q.title), x + 6, y + 6, { width: bw - 12 });
          doc.fillColor(INK).font('Helvetica').fontSize(8.5).text(plain(q.x), x + 6, doc.y + 2, { width: bw - 12, height: bh - 26, ellipsis: true });
        });
        doc.save().rotate(-90, { origin: [L + 8, y0 + bh] }).fillColor(MUTED).font('Helvetica-Bold').fontSize(8).text(plain(b.y), L + 8 - bh, y0 + bh - 4, { width: bh * 2, align: 'center' }).restore();
        doc.fillColor(MUTED).font('Helvetica-Bold').fontSize(8).text(plain(b.x), L + 24, y0 + 2 * bh + 10, { width: CW - 24, align: 'center' });
        doc.x = L; return doc.moveDown(1);
      }
      case 'flow': {
        ensure(50); if (b.caption) { doc.font('Helvetica-Bold').fontSize(10).fillColor(INK).text(plain(b.caption), L, doc.y, { width: CW }); doc.moveDown(0.2); }
        doc.font('Helvetica-Bold').fontSize(9.5).fillColor(NAVY).text(b.items.map(plain).join('  ->  '), L, doc.y, { width: CW }); return doc.moveDown(0.8);
      }
      case 'funnel': {
        ensure(30 + b.items.length * 24); if (b.caption) { doc.font('Helvetica-Bold').fontSize(10).fillColor(INK).text(plain(b.caption), L, doc.y, { width: CW }); doc.moveDown(0.3); }
        const max = Math.max(...b.items.map(i => i.value));
        b.items.forEach(i => { const y = doc.y, w = Math.max(40, i.value / max * CW * 0.55);
          doc.rect(L, y, w, 18).fill(GOLD); doc.fillColor('#1d1405').font('Helvetica-Bold').fontSize(9).text(String(i.value), L, y + 5, { width: w, align: 'center' });
          doc.fillColor(INK).font('Helvetica').text(plain(i.label), L + w + 8, y + 5, { width: CW - w - 8 }); doc.y = y + 22; });
        doc.x = L; return doc.moveDown(0.6);
      }
      case 'case':
        h('Étude de cas : ' + b.title.replace(/^Étude de cas\s*:\s*/, ''), 12, GOLD);
        para(b.context); doc.font('Helvetica-Bold').fontSize(10.5).fillColor(INK).text('Questions', L, doc.y); bullets(b.questions, true);
        doc.moveDown(0.3); doc.font('Helvetica-Bold').fontSize(10.5).fillColor('#1f7a4d').text('Corrigé', L, doc.y); return para(b.solution);
      case 'tip': case 'action': {
        ensure(50); doc.font('Helvetica-Bold').fontSize(10).fillColor(b.t === 'tip' ? GOLD : NAVY).text(b.t === 'tip' ? 'À RETENIR' : 'ET VOUS ?', L + 10, doc.y);
        rich(b.x, {}, 10.5, L + 10, CW - 10); return doc.moveDown(0.6);
      }
      default: return null;
    }
  }

  // Couverture
  doc.rect(0, 0, doc.page.width, 170).fill(NAVY);
  doc.fillColor(GOLD).font('Helvetica-Bold').fontSize(11).text(clean(`${config.brand.toUpperCase()} - ${trackTitle}`), L, 50, { width: CW });
  doc.fillColor('#ffffff').fontSize(24).text(plain(`${m.id} - ${m.title}`), L, 72, { width: CW });
  doc.fillColor(INK).font('Helvetica').fontSize(11).text(plain(m.summary), L, 195, { width: CW });
  doc.fillColor(MUTED).fontSize(9).text(clean(`Durée : ${m.duration || '-'} - Mise à jour : ${fmtDate(m.updatedAt || Date.now())}${learnerName ? ' - Exemplaire de ' + learnerName : ''}`), L, doc.y + 6, { width: CW });
  h('Objectifs', 14); bullets(m.objectives || []);
  if (m.video && m.video.script && m.video.script.length) { h('Résumé de la vidéo', 14); bullets(m.video.script); }

  (m.lessons || []).forEach((l, i) => { doc.addPage(); h(`Leçon ${i + 1} - ${l.title}`, 16); (l.blocks || []).forEach(block); });
  if (m.takeaways && m.takeaways.length) { h('À retenir du module', 14); bullets(m.takeaways); }
  if (m.deliverable) { h('Livrable à produire', 14); para(`**${m.deliverable.title}** : ${m.deliverable.x}`); }
  doc.moveDown(1); doc.font('Helvetica-Oblique').fontSize(9).fillColor(MUTED).text('Le quiz de validation et l’attestation sont disponibles en ligne sur votre espace STFC Academy.', L, doc.y, { width: CW });

  const range = doc.bufferedPageRange();
  for (let i = range.start; i < range.start + range.count; i++) {
    doc.switchToPage(i);
    const y = doc.page.height - 36; const mb = doc.page.margins.bottom; doc.page.margins.bottom = 0;
    doc.font('Helvetica').fontSize(8).fillColor(MUTED).text(clean(`${config.brand} - ${m.id} - page ${i + 1}/${range.count} - Usage personnel, reproduction interdite`), L, y, { width: CW, align: 'center' });
    doc.page.margins.bottom = mb;
  }
  doc.end();
  return doc;
}

module.exports = { certificate, course, clean };
