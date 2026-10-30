// Bibliothèque de mise en page des documents STFC (charte plaquette + format G-Clean)
const fs = require('fs');
const D = require('docx');
const { Document, Packer, Paragraph, TextRun, Table, TableRow, TableCell, WidthType, ShadingType,
  BorderStyle, AlignmentType, VerticalAlign, Header, Footer, PageNumber, HeightRule, LevelFormat,
  PageOrientation } = D;

const C = { navy: '0D2B6E', gold: 'C9A84C', blue2: '6174A0', ink: '1B2433', label: 'EAEEF6',
  line: 'C5CDDC', grey: '7D8698', goldLight: 'F7F1DE' };
const HEAD = 'Cambria', BODY = 'Calibri';
const W = 10206, WL = 15138; // largeur utile portrait / paysage (DXA)

const SERVICES = [
  ['STFC Audit', 'Diagnostic commercial et marketing approfondi (≈ 1 mois) — restitution stratégique et feuille de route à 90 jours.'],
  ['STFC Croissance', 'Accompagnement stratégique et opérationnel (3 à 12 mois) — Plan d’Action Commerciale, CRM, tableaux de bord, suivi mensuel.'],
  ['STFC Transformation Digitale', 'Diagnostic de maturité digitale, feuille de route, conception et déploiement d’outils (site vitrine, e-commerce, portail, CRM, réseaux sociaux), conduite du changement et transfert d’autonomie.'],
  ['STFC Academy', 'Parcours de formation des équipes commerciales et marketing (1 à 3 mois) — 9 modules en ateliers d’immersion et cas pratiques.'],
];
const MODULES = ['Prospection téléphonique stratégique', 'Vente stratégique B2B', 'Dynamique commerciale B2C',
  'L’art du closing et conclusion des ventes', 'Optimisation du coût d’acquisition client', 'Customer Lifetime Value',
  'Amélioration continue de l’expérience client', 'Stratégies de fidélisation et rétention', 'Ambassadeuriat et partenariats clients'];
const SECTEURS = '☐ Industrie   ☐ Services à forte valeur ajoutée   ☐ Technologies (Tech)   ☐ Autre : ……………';
const TAILLES = '☐ 5 – 20   ☐ 21 – 50   ☐ 51 – 250   ☐ 251 – 1 000   ☐ + de 1 000 collaborateurs';
const PHASES = '☐ Structuration   ☐ Croissance   ☐ Relance';
const OFFRES = '☐ Audit   ☐ Croissance   ☐ Transformation Digitale   ☐ Academy';

const t = (text, o = {}) => new TextRun({ text, font: o.font || BODY, size: o.size || 20, bold: o.bold,
  italics: o.italics, color: o.color || C.ink, characterSpacing: o.spacing });
const P = (runs, o = {}) => new Paragraph({ children: (typeof runs === 'string' ? [t(runs, o)] : runs),
  alignment: o.align, spacing: { before: o.before ?? 0, after: o.after ?? 60, line: o.line },
  keepNext: o.keepNext, border: o.border, indent: o.indent, numbering: o.numbering });
const none = { style: BorderStyle.NONE, size: 0, color: 'FFFFFF' };
const ln = (c = C.line, s = 4) => ({ style: BorderStyle.SINGLE, size: s, color: c });
const allB = (b) => ({ top: b, bottom: b, left: b, right: b, insideHorizontal: b, insideVertical: b });
const shade = (fill) => ({ type: ShadingType.CLEAR, fill, color: 'auto' });
const M = { top: 60, bottom: 60, left: 110, right: 110 };

function cell(children, width, o = {}) {
  return new TableCell({ width: { size: width, type: WidthType.DXA }, shading: o.fill ? shade(o.fill) : undefined,
    margins: o.margins || M, verticalAlign: o.valign || VerticalAlign.CENTER, columnSpan: o.span,
    borders: o.borders, children: Array.isArray(children) ? children : [children] });
}
function table(widths, rows, o = {}) {
  const total = widths.reduce((a, b) => a + b, 0);
  return new Table({ width: { size: total, type: WidthType.DXA }, columnWidths: widths, borders: o.borders || allB(ln()),
    rows });
}
const row = (cells, h) => new TableRow({ children: cells, cantSplit: true,
  height: h ? { value: h, rule: HeightRule.ATLEAST } : undefined });
const lab = (s) => P([t(s, { bold: true, color: C.navy, size: 18 })], { after: 0 });
const val = (s = '') => P([t(s, { size: 18 })], { after: 0 });
const spacer = (after = 80) => P('', { after });

// ---------- En-tête première page (format G-Clean, couleurs plaquette) ----------
function headerBlock(title, meta, w = W) {
  const inner = (children) => new Table({ width: { size: 4700, type: WidthType.DXA }, columnWidths: [4700],
    borders: allB(ln('9AA6BC', 4)), rows: [row([cell(children, 4700, { fill: 'FFFFFF', margins: { top: 120, bottom: 120, left: 160, right: 160 } })], 1150)] });
  const logo = inner([P([t('STFC', { font: HEAD, size: 52, bold: true, color: C.navy }), t('  Expertise', { font: HEAD, size: 30, bold: true, italics: true, color: C.gold })], { align: AlignmentType.CENTER, after: 0 }),
    P([t('S T R A T   F O C U S   C O N S U L T I N G', { size: 14, bold: true, color: C.blue2 })], { align: AlignmentType.CENTER, after: 0 })]);
  const right = inner([P([t(title, { font: HEAD, size: title.length > 24 ? 26 : 32, bold: true, color: C.navy })], { align: AlignmentType.RIGHT, after: 40 }),
    ...meta.map(([k, v]) => P([t(k + ' : ', { size: 16, bold: true, color: C.grey }), t(v, { size: 16, bold: true })], { align: AlignmentType.RIGHT, after: 0 }))]);
  const navy = { margins: { top: 160, bottom: 140, left: 200, right: 200 }, fill: C.navy, valign: VerticalAlign.TOP };
  return [new Table({ width: { size: w, type: WidthType.DXA }, columnWidths: [w / 2, w / 2],
    borders: { top: ln(C.navy), left: ln(C.navy), right: ln(C.navy), bottom: ln(C.gold, 24), insideHorizontal: none, insideVertical: ln('2E4A86') },
    rows: [row([cell([logo, P([t('Stratégie · Performance Commerciale · Marketing d’Innovation', { size: 16, bold: true, color: 'FFFFFF' })], { before: 100, after: 0 }),
      P([t('Parce que votre chiffre d’affaires compte', { font: HEAD, size: 16, italics: true, color: C.gold })], { after: 0 })], w / 2, navy),
    cell([right], w / 2, navy)])] }), spacer(60)];
}

// ---------- Titres et blocs ----------
const h = (n, title) => P([t(n + '. ', { font: HEAD, size: 24, bold: true, color: C.gold }), t(title, { font: HEAD, size: 24, bold: true, color: C.navy })], { before: 200, after: 80, keepNext: true });
const art = (n, title) => P([t('Article ' + n + ' — ', { font: HEAD, size: 21, bold: true, color: C.gold }), t(title, { font: HEAD, size: 21, bold: true, color: C.navy })], { before: 160, after: 60, keepNext: true });
const body = (s, o = {}) => P([t(s, { size: 19 })], { align: AlignmentType.JUSTIFIED, after: 80, ...o });
const rich = (parts, o = {}) => P(parts.map((x) => typeof x === 'string' ? t(x, { size: 19 }) : t(x[0], { size: 19, bold: true, color: x[1] || C.ink })), { align: AlignmentType.JUSTIFIED, after: 80, ...o });
const bullets = (items) => items.map((s) => P([t(s, { size: 19 })], { numbering: { reference: 'bul', level: 0 }, after: 40 }));
const note = (s) => P([t(s, { size: 16, italics: true, color: C.grey })], { after: 60 });

// Tableau libellé / valeur (2 ou 4 colonnes)
function kv(rows, wTot = W) {
  const w4 = [Math.round(wTot * 0.22), Math.round(wTot * 0.28), Math.round(wTot * 0.2)];
  w4.push(wTot - w4[0] - w4[1] - w4[2]);
  return table(w4, rows.map((r) => r.length <= 2
    ? row([cell(lab(r[0]), w4[0], { fill: C.label }), cell(val(r[1]), wTot - w4[0], { span: 3 })], 400)
    : row([cell(lab(r[0]), w4[0], { fill: C.label }), cell(val(r[1]), w4[1]), cell(lab(r[2]), w4[2], { fill: C.label }), cell(val(r[3]), w4[3])], 400)));
}
// Tableau à en-tête marine et lignes vides numérotées
function grid(headers, widths, n, o = {}) {
  const hd = row(headers.map((x, i) => cell(P([t(x, { size: 17, bold: true, color: 'FFFFFF' })], { align: AlignmentType.CENTER, after: 0 }), widths[i], { fill: C.navy })), 420);
  const body = (o.rows || Array.from({ length: n }, (_, i) => [String(i + 1)])).map((r) =>
    row(widths.map((w, i) => cell(i === 0 && !o.labelFirst ? P([t(r[0] || '', { size: 17, bold: true, color: C.navy })], { align: AlignmentType.CENTER, after: 0 })
      : (i === 0 ? lab(r[0]) : val(r[i] || '')), w, { fill: i === 0 && o.labelFirst ? C.label : undefined })), o.h || 400));
  return table(widths, [hd, ...body]);
}
// Bandeau intermédiaire (ligne de regroupement)
const band = (s, span, w) => row([cell(P([t(s, { font: HEAD, size: 19, bold: true, color: C.navy })], { after: 0 }), w, { span, fill: C.goldLight })], 380);
function box(label, hgt = 1100) {
  return table([W], [row([cell(label ? P([t(label, { size: 16, italics: true, color: C.grey })], { after: 0 }) : val(''), W, { valign: VerticalAlign.TOP })], hgt)]);
}
function signatures(a, b, hgt = 1300) {
  const s = (x) => cell([lab(x), P([t('Nom, date, signature et cachet', { size: 15, italics: true, color: C.grey })], { after: 0 })], W / 2, { fill: C.label, valign: VerticalAlign.TOP });
  return table([W / 2, W / 2], [row([s(a), s(b)], hgt)]);
}
const checks = (label, opts) => P([t(label + '  ', { size: 18, bold: true, color: C.navy }), t(opts, { size: 18 })], { after: 80 });

// ---------- Pied de page et document ----------
function footer() {
  return new Footer({ children: [
    P([t('STRAT FOCUS CONSULTING — STFC Expertise — République du Congo — RCCM CG-PNR-01-2025-A11-00010 — NIU : [à compléter]', { size: 14, color: C.grey })], { align: AlignmentType.CENTER, after: 0, border: { top: { style: BorderStyle.SINGLE, size: 4, color: 'D5DAE3', space: 4 } } }),
    P([t('Zone OCI, 200 m du Parc Culture, Q. MPITA — Pointe-Noire — Tél : 066 000 066 · 06 974 00 88 · 05 077 25 25 — stratfocusconsulting@gmail.com', { size: 14, color: C.grey })], { align: AlignmentType.CENTER, after: 0 }),
    new Paragraph({ alignment: AlignmentType.RIGHT, children: [new TextRun({ font: BODY, size: 14, color: C.grey, children: ['Page ', PageNumber.CURRENT, ' / ', PageNumber.TOTAL_PAGES] })] })] });
}
function runningHeader(title) {
  return new Header({ children: [P([t('STFC Expertise', { font: HEAD, size: 16, bold: true, color: C.navy }), t('  ·  ' + title, { size: 16, color: C.grey })],
    { align: AlignmentType.RIGHT, after: 0, border: { bottom: { style: BorderStyle.SINGLE, size: 8, color: C.gold, space: 4 } } })] });
}
async function save(file, title, meta, children, o = {}) {
  const page = o.landscape
    ? { size: { width: 11906, height: 16838, orientation: PageOrientation.LANDSCAPE }, margin: { top: 720, bottom: 900, left: 850, right: 850, header: 360, footer: 360 } }
    : { size: { width: 11906, height: 16838 }, margin: { top: 720, bottom: 1000, left: 850, right: 850, header: 360, footer: 360 } };
  const head = headerBlock(title, meta, o.landscape ? WL : W);
  const doc = new Document({
    creator: 'Strat Focus Consulting', title: 'STFC — ' + title,
    styles: { default: { document: { run: { font: BODY, size: 19, color: C.ink } } } },
    numbering: { config: [{ reference: 'bul', levels: [{ level: 0, format: LevelFormat.BULLET, text: '▸', alignment: AlignmentType.LEFT,
      style: { run: { color: C.gold }, paragraph: { indent: { left: 360, hanging: 260 } } } }] }] },
    sections: [{ properties: { titlePage: true, page }, headers: { first: new Header({ children: [P('')] }), default: runningHeader(title) },
      footers: { first: footer(), default: footer() }, children: [...head, ...children] }] });
  fs.writeFileSync(file, await Packer.toBuffer(doc));
}

module.exports = { C, W, WL, HEAD, BODY, SERVICES, MODULES, SECTEURS, TAILLES, PHASES, OFFRES,
  t, P, h, art, body, rich, bullets, note, kv, grid, band, box, signatures, checks, table, row, cell, lab, val, spacer, save };
