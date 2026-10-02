// Génère les visuels 1080x1080 des thèmes STFC (modèle validé le 02/10/2026).
// Usage : node generer_visuels.mjs [ID…]
import { chromium } from '/opt/node22/lib/node_modules/playwright/index.mjs';
import fs from 'fs';
const dir = new URL('.', import.meta.url).pathname;
const items = JSON.parse(fs.readFileSync(dir + 'items.json', 'utf8'));
const logo = fs.readFileSync(dir + 'logo_blanc_inner.svgfrag', 'utf8');
const only = process.argv.slice(2);
const esc = s => s.replace(/&/g, '&amp;').replace(/</g, '&lt;');
const page0 = `<html><head><style>
@font-face{font-family:'Bebas';src:url('file://${dir}BebasNeue.ttf')}
html,body{margin:0;background:#0D2B6E}
.cond{font-family:'Bebas'} .tag{font-family:'Liberation Sans',Arial,sans-serif}
</style></head><body><div id="c"></div></body></html>`;
fs.writeFileSync(dir + '_page.html', page0);
const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium-1194/chrome-linux/chrome' });
const p = await b.newPage({ viewport: { width: 1080, height: 1080 } });
await p.goto('file://' + dir + '_page.html');
for (const it of items) {
  if (only.length && !only.includes(it.id)) continue;
  const n = it.titre.length;
  const svg = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1080 1080" width="1080" height="1080">
<rect width="1080" height="1080" fill="#0D2B6E"/>
<g opacity="0.07" fill="none" stroke="#FFFFFF"><circle cx="900" cy="300" r="260" stroke-width="22"/><circle cx="900" cy="300" r="170" stroke-width="22"/><circle cx="900" cy="300" r="80" stroke-width="22"/></g>
<rect id="pill" x="80" y="150" rx="28" width="400" height="56" fill="#C9A84C"/>
<text id="pilltxt" x="110" y="190" class="tag" font-size="28" font-weight="bold" fill="#0D2B6E">${esc(it.pilier)}</text>
<g id="titre">${it.titre.map((l, i) => `<text class="cond" font-size="120" fill="${i === n - 1 ? '#C9A84C' : '#FFFFFF'}" x="80">${esc(l)}</text>`).join('')}</g>
<text id="acc" x="80" class="tag" font-size="36" fill="#EDF0F7"></text>
<rect x="0" y="860" width="1080" height="220" fill="#08204F"/>
<g transform="translate(40,895) scale(0.40)">${logo}</g>
<text x="1020" y="985" text-anchor="end" class="tag" font-size="32" font-weight="bold" fill="#C9A84C">WhatsApp 066 000 066</text>
</svg>`;
  await p.evaluate(async ({ svg, acc }) => {
    document.getElementById('c').innerHTML = svg;
    await document.fonts.ready;
    const pt = document.getElementById('pilltxt');
    document.getElementById('pill').setAttribute('width', pt.getComputedTextLength() + 60);
    const lines = [...document.querySelectorAll('#titre text')];
    let size = 120;
    const fit = () => Math.max(...lines.map(t => t.getComputedTextLength()));
    while (fit() > 900 && size > 70) { size -= 2; lines.forEach(t => t.setAttribute('font-size', size)); }
    if (lines.length >= 3 && size > 112) { size = 112; lines.forEach(t => t.setAttribute('font-size', size)); }
    const lh = size * 0.95, top = 270;
    lines.forEach((t, i) => t.setAttribute('y', top + size * 0.85 + i * lh));
    // accroche : retour à la ligne automatique (2 lignes max)
    const a = document.getElementById('acc');
    const words = acc.split(' '); const out = []; let cur = '';
    for (const w of words) { a.textContent = (cur ? cur + ' ' : '') + w; if (a.getComputedTextLength() > 900 && cur) { out.push(cur); cur = w; } else cur = a.textContent; }
    out.push(cur); a.textContent = '';
    const y0 = top + size * 0.85 + (lines.length - 1) * lh + 95;
    out.forEach((l, i) => { const ts = document.createElementNS('http://www.w3.org/2000/svg', 'tspan'); ts.setAttribute('x', 80); ts.setAttribute('y', y0 + i * 46); ts.textContent = l; a.appendChild(ts); });
  }, { svg, acc: it.accroche });
  await p.screenshot({ path: dir + it.id + '.png', clip: { x: 0, y: 0, width: 1080, height: 1080 } });
  process.stdout.write(it.id + ' ');
}
await b.close();
fs.unlinkSync(dir + '_page.html');
