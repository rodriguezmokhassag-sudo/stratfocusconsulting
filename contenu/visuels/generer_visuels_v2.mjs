// Génère les visuels 1080x1080 STFC selon 4 modèles (A Titre, B Checklist claire, C Symbole, D Méthode).
// Usage : node generer_visuels_v2.mjs [--sortie=dossier] [ID[:MODELE]…]
import { chromium } from '/opt/node22/lib/node_modules/playwright/index.mjs';
import fs from 'fs';
const dir = new URL('.', import.meta.url).pathname;
const items = JSON.parse(fs.readFileSync(dir + 'items.json', 'utf8'));
const logo = fs.readFileSync(dir + 'logo_blanc_inner.svgfrag', 'utf8');
const args = process.argv.slice(2);
const outDir = (args.find(a => a.startsWith('--sortie=')) || '--sortie=' + dir).split('=')[1].replace(/\/?$/, '/');
const picks = args.filter(a => !a.startsWith('--'));
const MODELE_PAR_FORMAT = { 'conseil': 'A', 'checklist': 'B', 'question': 'C', 'erreur': 'C', 'méthode': 'D' };
const esc = s => s.replace(/&/g, '&amp;').replace(/</g, '&lt;');
const NAVY = '#0D2B6E', GOLD = '#C9A84C', CLAIR = '#EDF0F7', DEEP = '#08204F';
const MENTION = "Cabinet spécialisé dans la performance commerciale et Marketing d'Innovation";

function pied(mentionColor) {
  return `<text x="540" y="822" text-anchor="middle" class="tag" font-size="27" fill="${mentionColor}">${esc(MENTION)}</text>
<rect x="0" y="860" width="1080" height="220" fill="${DEEP}"/>
<g transform="translate(40,895) scale(0.40)">${logo}</g>
<text x="1020" y="985" text-anchor="end" class="tag" font-size="32" font-weight="bold" fill="${GOLD}">WhatsApp 066 000 066</text>`;
}
const titre = (lignes, couleurs) => `<g id="titre">${lignes.map((l, i) => `<text class="cond" font-size="120" fill="${couleurs(i, lignes.length)}">${esc(l)}</text>`).join('')}</g>`;

function svgPour(it, m) {
  const head = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1080 1080" width="1080" height="1080">`;
  if (m === 'A') return { x: 80, w: 900, top: 270, svg: head + `
<rect width="1080" height="1080" fill="${NAVY}"/>
<g opacity="0.07" fill="none" stroke="#FFFFFF"><circle cx="900" cy="300" r="260" stroke-width="22"/><circle cx="900" cy="300" r="170" stroke-width="22"/><circle cx="900" cy="300" r="80" stroke-width="22"/></g>
<rect id="pill" x="80" y="150" rx="28" width="400" height="56" fill="${GOLD}"/>
<text id="pilltxt" x="110" y="190" class="tag" font-size="28" font-weight="bold" fill="${NAVY}">${esc(it.pilier)}</text>
${titre(it.titre, (i, n) => i === n - 1 ? GOLD : '#FFFFFF')}
<text id="acc" class="tag" font-size="36" fill="${CLAIR}"></text>
${pied(GOLD)}</svg>` };
  if (m === 'B') {
    const coche = (cy) => `<circle cx="930" cy="${cy}" r="46" fill="${GOLD}"/><path d="M 908 ${cy} l 15 16 l 30 -32" fill="none" stroke="#FFFFFF" stroke-width="11" stroke-linecap="round" stroke-linejoin="round"/>`;
    return { x: 80, w: 740, top: 270, svg: head + `
<rect width="1080" height="1080" fill="${CLAIR}"/>
<g opacity="0.06" fill="none" stroke="${NAVY}"><circle cx="160" cy="760" r="300" stroke-width="22"/><circle cx="160" cy="760" r="200" stroke-width="22"/></g>
<rect x="870" y="250" width="120" height="440" rx="60" fill="${NAVY}" opacity="0.08"/>
${coche(330)}${coche(470)}${coche(610)}
<rect id="pill" x="80" y="150" rx="28" width="400" height="56" fill="${NAVY}"/>
<text id="pilltxt" x="110" y="190" class="tag" font-size="28" font-weight="bold" fill="#FFFFFF">${esc(it.pilier)}</text>
${titre(it.titre, (i, n) => i === n - 1 ? '#B08A2E' : NAVY)}
<text id="acc" class="tag" font-size="36" fill="#262626"></text>
${pied(NAVY)}</svg>` };
  }
  if (m === 'C') {
    const sym = it.format === 'erreur' ? '!' : '?';
    return { x: 80, w: 640, top: 270, svg: head + `
<rect width="1080" height="1080" fill="${DEEP}"/>
<circle cx="860" cy="430" r="300" fill="${NAVY}"/>
<text x="860" y="640" text-anchor="middle" class="cond" font-size="560" fill="${GOLD}">${sym}</text>
<rect id="pill" x="80" y="150" rx="28" width="400" height="56" fill="${GOLD}"/>
<text id="pilltxt" x="110" y="190" class="tag" font-size="28" font-weight="bold" fill="${NAVY}">${esc(it.pilier)}</text>
${titre(it.titre, (i, n) => i === n - 1 ? GOLD : '#FFFFFF')}
<text id="acc" class="tag" font-size="36" fill="${CLAIR}"></text>
${pied(GOLD)}</svg>` };
  }
  // D : méthode, panneau or à gauche avec les étapes 1 2 3
  const etape = (n, cy) => `<circle cx="180" cy="${cy}" r="62" fill="${NAVY}"/><text x="180" y="${cy + 30}" text-anchor="middle" class="cond" font-size="96" fill="${GOLD}">${n}</text>`;
  return { x: 400, w: 620, top: 300, svg: head + `
<rect width="1080" height="1080" fill="${NAVY}"/>
<rect x="0" y="0" width="360" height="770" fill="${GOLD}"/>
<text x="180" y="200" text-anchor="middle" class="cond" font-size="84" fill="${NAVY}">LA MÉTHODE</text>
${etape(1, 330)}${etape(2, 480)}${etape(3, 630)}
<rect id="pill" x="400" y="150" rx="28" width="400" height="56" fill="${GOLD}"/>
<text id="pilltxt" x="430" y="190" class="tag" font-size="28" font-weight="bold" fill="${NAVY}">${esc(it.pilier)}</text>
${titre(it.titre, (i, n) => i === n - 1 ? GOLD : '#FFFFFF')}
<text id="acc" class="tag" font-size="34" fill="${CLAIR}"></text>
${pied(GOLD)}</svg>` };
}

const page0 = `<html><head><style>
@font-face{font-family:'Bebas';src:url('file://${dir}BebasNeue.ttf')}
html,body{margin:0}
.cond{font-family:'Bebas'} .tag{font-family:'Liberation Sans',Arial,sans-serif}
</style></head><body><div id="c"></div></body></html>`;
fs.writeFileSync(dir + '_page.html', page0);
const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium-1194/chrome-linux/chrome' });
const p = await b.newPage({ viewport: { width: 1080, height: 1080 } });
await p.goto('file://' + dir + '_page.html');
const liste = picks.length ? picks.map(s => { const [id, m] = s.split(':'); return { it: items.find(i => i.id === id), m }; }) : items.map(it => ({ it }));
for (const { it, m: forced } of liste) {
  const m = forced || MODELE_PAR_FORMAT[it.format] || 'A';
  const L = svgPour(it, m);
  await p.evaluate(async ({ svg, acc, x, w, top }) => {
    document.getElementById('c').innerHTML = svg;
    await document.fonts.ready;
    const pt = document.getElementById('pilltxt');
    document.getElementById('pill').setAttribute('width', pt.getComputedTextLength() + 60);
    const lines = [...document.querySelectorAll('#titre text')];
    lines.forEach(t => t.setAttribute('x', x));
    let size = 120;
    const fit = () => Math.max(...lines.map(t => t.getComputedTextLength()));
    while (fit() > w && size > 60) { size -= 2; lines.forEach(t => t.setAttribute('font-size', size)); }
    if (lines.length >= 3 && size > 112) { size = 112; lines.forEach(t => t.setAttribute('font-size', size)); }
    const lh = size * 0.95;
    lines.forEach((t, i) => t.setAttribute('y', top + size * 0.85 + i * lh));
    const a = document.getElementById('acc');
    const words = acc.split(' '); const out = []; let cur = '';
    for (const wd of words) { a.textContent = (cur ? cur + ' ' : '') + wd; if (a.getComputedTextLength() > w && cur) { out.push(cur); cur = wd; } else cur = a.textContent; }
    out.push(cur); a.textContent = '';
    const y0 = top + size * 0.85 + (lines.length - 1) * lh + 95;
    out.forEach((l, i) => { const ts = document.createElementNS('http://www.w3.org/2000/svg', 'tspan'); ts.setAttribute('x', x); ts.setAttribute('y', y0 + i * 46); ts.textContent = l; a.appendChild(ts); });
  }, { svg: L.svg, acc: it.accroche, x: L.x, w: L.w, top: L.top });
  await p.screenshot({ path: outDir + it.id + (forced ? '_' + m : '') + '.png', clip: { x: 0, y: 0, width: 1080, height: 1080 } });
  process.stdout.write(it.id + ':' + m + ' ');
}
await b.close();
fs.unlinkSync(dir + '_page.html');
