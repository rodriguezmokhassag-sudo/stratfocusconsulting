// Convertit le guide HTML en PDF A4 avec Chromium (Playwright pre-installe).
// Usage : node build/pdf.js guide.html sortie.pdf
const { chromium } = require('playwright');
const path = require('path');
(async () => {
  const [src, out, titre = 'guide complet'] = process.argv.slice(2);
  const browser = await chromium.launch();
  const page = await browser.newPage();
  await page.goto('file://' + path.resolve(src), { waitUntil: 'load' });
  await page.pdf({
    path: out, format: 'A4', printBackground: true,
    margin: { top: '16mm', bottom: '18mm', left: '15mm', right: '15mm' },
    displayHeaderFooter: true,
    headerTemplate: '<div></div>',
    footerTemplate: '<div style="width:100%;font-size:8px;color:#777;text-align:center;font-family:sans-serif">' +
      'Gestion Chorale - ' + titre + ' - page <span class="pageNumber"></span> / <span class="totalPages"></span></div>',
  });
  await browser.close();
})();
