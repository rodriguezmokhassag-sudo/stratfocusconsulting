// Génère en Markdown la grille tarifaire (Bloc 3) et le plan de contenu détaillé (Bloc 4) du cahier de conception,
// directement depuis content/ et src/pricing.js, pour que le document reste fidèle à la plateforme.
// Usage : node scripts/plan-contenu.js tarifs | plan
const tracks = require('../content/tracks');
const pricing = require('../src/pricing');
const mod = id => require('../content/modules/' + id);
const fmt = n => Number(n).toLocaleString('fr-FR').replace(/ | /g, ' ');
const strip = s => String(s).replace(/\*\*/g, '');
const money = d => `${fmt(d.amount)} ${{ XOF: 'FCFA', XAF: 'FCFA', EUR: '€', USD: '$', MAD: 'MAD' }[d.currency]}`;

function tarifs() {
  const products = [...tracks.filter(t => !t.free).map(t => 'track:' + t.id), 'pass', 'sub-month', 'sub-year'];
  const out = ['| Offre | Zone FCFA (UEMOA, CEMAC) | Équivalent € | 3 × (FCFA) | Hors zone FCFA (−25 %) | Maghreb | Diaspora (+30 %) |', '|---|---|---|---|---|---|---|'];
  products.forEach(p => {
    const a = pricing.quote(p, 'uemoa'), b = pricing.quote(p, 'b'), m = pricing.quote(p, 'maghreb'), d = pricing.quote(p, 'diaspora');
    out.push(`| ${a.label} | **${money(a.display)}** | ${a.eur} € | ${a.installments ? fmt(a.installments.xof) : '–'} | ${money(b.display)} | ${money(m.display)} | ${money(d.display)} |`);
  });
  return out.join('\n');
}

function plan() {
  const out = [];
  tracks.forEach(t => {
    out.push(`### ${t.free ? '4.0 Modules gratuits d’attraction' : `4.${t.level} Parcours ${t.title}`}`, '');
    out.push(`**Public :** ${t.audience} · **Durée :** ${t.duration} · **Délivré :** ${t.certificate}`, '');
    t.modules.forEach(id => {
      const m = mod(id);
      const cases = m.lessons.flatMap(l => l.blocks.filter(b => b.t === 'case').map(b => strip(b.title.replace(/^Étude de cas\s*:\s*/, ''))));
      const tools = [...new Set(m.lessons.flatMap(l => l.blocks.filter(b => ['matrix', 'table', 'flow', 'funnel'].includes(b.t) && b.caption).map(b => strip(b.caption))))].slice(0, 4);
      out.push(`#### ${id} · ${m.title} (${m.duration})`, '');
      out.push(`**Objectifs pédagogiques :** ${m.objectives.join(' ; ')}.`, '');
      out.push(`**Plan du cours :** vidéo résumé « ${m.video.title} » (${m.video.duration}) → ${m.lessons.map((l, i) => `L${i + 1}. ${l.title}`).join(' → ')} → quiz.`, '');
      if (tools.length) out.push(`**Tableaux, schémas et matrices :** ${tools.join(' · ')}.`, '');
      out.push(`**Étude de cas africaine :** ${cases.join(' ; ')}.`, '');
      out.push(`**Livrable :** ${m.deliverable.title}. ${m.deliverable.x}`, '');
      out.push(`<details><summary><strong>Quiz de validation : ${m.quiz.length} questions (seuil 70 %)</strong></summary>`, '');
      m.quiz.forEach((q, i) => out.push(`${i + 1}. ${strip(q.q)}`));
      out.push('', '*Options, réponses et explications : back-office, rubrique Contenus.*');
      out.push('', '</details>', '');
    });
  });
  return out.join('\n');
}

console.log(process.argv[2] === 'tarifs' ? tarifs() : plan());
