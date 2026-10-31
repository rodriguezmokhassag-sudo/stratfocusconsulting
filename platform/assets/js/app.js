/*
 * STFC Academy — Moteur de la plateforme (sans dépendance)
 * Routage par hash, rendu des leçons, quiz, certificats, progression locale.
 */
(function () {
  'use strict';

  const CAT = window.CATALOGUE;
  const CFG = window.STFC_CONFIG;
  const STORE_KEY = 'stfc-academy-v1';
  const app = document.getElementById('app');

  /* ------------------------------------------------------------------ *
   *  État (enregistré sur l'appareil)
   * ------------------------------------------------------------------ */
  const defaultState = () => ({ name: '', unlocked: [], progress: {}, certs: {} });
  let state = load();

  function load() {
    try { return Object.assign(defaultState(), JSON.parse(localStorage.getItem(STORE_KEY) || '{}')); }
    catch (e) { return defaultState(); }
  }
  function save() {
    try { localStorage.setItem(STORE_KEY, JSON.stringify(state)); } catch (e) { /* stockage indisponible */ }
  }
  function prog(id) {
    if (!state.progress[id]) state.progress[id] = { lessons: [], quiz: null };
    return state.progress[id];
  }

  /* ------------------------------------------------------------------ *
   *  Utilitaires
   * ------------------------------------------------------------------ */
  const esc = s => String(s == null ? '' : s).replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
  const md = s => esc(s).replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>');
  const fcfa = n => n.toLocaleString('fr-FR').replace(/\u202f|\u00a0/g, ' ') + ' ' + CFG.currency;
  const waLink = text => `https://wa.me/${CFG.whatsapp}?text=${encodeURIComponent(text)}`;
  const fmtDate = iso => new Date(iso).toLocaleDateString('fr-FR', { day: 'numeric', month: 'long', year: 'numeric' });

  function shuffle(arr) {
    const a = arr.slice();
    for (let i = a.length - 1; i > 0; i--) { const j = Math.floor(Math.random() * (i + 1)); [a[i], a[j]] = [a[j], a[i]]; }
    return a;
  }
  function hash36(str) { // FNV-1a 32 bits, base 36
    let h = 0x811c9dc5;
    for (let i = 0; i < str.length; i++) { h ^= str.charCodeAt(i); h = Math.imul(h, 0x01000193) >>> 0; }
    return h.toString(36).toUpperCase().padStart(7, '0');
  }
  async function sha256(text) {
    const buf = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(text));
    return Array.from(new Uint8Array(buf), b => b.toString(16).padStart(2, '0')).join('');
  }

  /* ------------------------------------------------------------------ *
   *  Règles d'accès
   * ------------------------------------------------------------------ */
  const trackOf = modId => CAT.tracks.find(t => t.modules.includes(modId));
  const isUnlocked = track => track.free || state.unlocked.includes('all') || state.unlocked.includes(track.id);
  const isPassed = modId => !!(state.progress[modId] && state.progress[modId].quiz && state.progress[modId].quiz.passed);

  function moduleAccess(modId) {
    const m = CAT.modules[modId], t = trackOf(modId);
    if (!isUnlocked(t)) return { ok: false, reason: 'paywall' };
    if (m.status !== 'complet') return { ok: false, reason: 'bientot' };
    if (!t.free) { // progression verrouillée : les modules complets précédents doivent être validés
      const idx = t.modules.indexOf(modId);
      const blocker = t.modules.slice(0, idx).find(id => CAT.modules[id].status === 'complet' && !isPassed(id));
      if (blocker) return { ok: false, reason: 'sequence', blocker };
    }
    return { ok: true };
  }
  function lessonsDone(modId) {
    const m = CAT.modules[modId], p = state.progress[modId];
    return !!p && m.lessons.every((_, i) => p.lessons[i]);
  }
  function moduleProgressPct(modId) {
    const m = CAT.modules[modId]; const p = state.progress[modId];
    if (!p || !m.lessons.length) return 0;
    const steps = m.lessons.length + 1; // leçons + quiz
    const done = m.lessons.filter((_, i) => p.lessons[i]).length + (isPassed(modId) ? 1 : 0);
    return Math.round(done / steps * 100);
  }
  function trackStats(t) {
    const total = t.modules.length;
    const passed = t.modules.filter(isPassed).length;
    const ready = t.modules.filter(id => CAT.modules[id].status === 'complet').length;
    return { total, passed, ready, complete: passed === total };
  }

  /* ------------------------------------------------------------------ *
   *  Rendu des blocs de contenu
   * ------------------------------------------------------------------ */
  function renderBlock(b) {
    switch (b.t) {
      case 'p': return `<p>${md(b.x)}</p>`;
      case 'h': return `<h3>${md(b.x)}</h3>`;
      case 'list': return `<ul class="list">${b.items.map(i => `<li>${md(i)}</li>`).join('')}</ul>`;
      case 'steps': return `<ol class="steps">${b.items.map(s => `<li><strong>${md(s.title)}</strong><span>${md(s.x)}</span></li>`).join('')}</ol>`;
      case 'table': return `<figure class="table-wrap">${b.caption ? `<figcaption>${md(b.caption)}</figcaption>` : ''}
          <div class="scroll-x"><table><thead><tr>${b.head.map(h => `<th scope="col">${md(h)}</th>`).join('')}</tr></thead>
          <tbody>${b.rows.map(r => `<tr>${r.map((c, i) => i === 0 ? `<th scope="row">${md(c)}</th>` : `<td>${md(c)}</td>`).join('')}</tr>`).join('')}</tbody></table></div></figure>`;
      case 'matrix': return `<figure class="matrix">${b.caption ? `<figcaption>${md(b.caption)}</figcaption>` : ''}
          <div class="matrix-body"><div class="axis-y">${md(b.y)}</div>
          <div class="matrix-grid">${b.q.map((q, i) => `<div class="quad q${i}"><strong>${md(q.title)}</strong><span>${md(q.x)}</span></div>`).join('')}</div></div>
          <div class="axis-x">${md(b.x)}</div></figure>`;
      case 'flow': return `<figure class="flow">${b.caption ? `<figcaption>${md(b.caption)}</figcaption>` : ''}
          <ol>${b.items.map(i => `<li>${md(i)}</li>`).join('')}</ol></figure>`;
      case 'funnel': {
        const max = Math.max(...b.items.map(i => i.value));
        return `<figure class="funnel">${b.caption ? `<figcaption>${md(b.caption)}</figcaption>` : ''}
          ${b.items.map((i, k) => {
            const rate = k ? ` <small>(${Math.round(i.value / b.items[k - 1].value * 100)} %)</small>` : '';
            return `<div class="funnel-row"><div class="funnel-bar" style="width:${Math.max(28, i.value / max * 100)}%"><b>${i.value}</b></div><span>${md(i.label)}${rate}</span></div>`;
          }).join('')}</figure>`;
      }
      case 'case': return `<section class="case"><div class="case-tag">Étude de cas</div><h3>${md(b.title.replace(/^Étude de cas\s*:\s*/, ''))}</h3>
          <p>${md(b.context)}</p><p class="case-q"><strong>Questions</strong></p><ol>${b.questions.map(q => `<li>${md(q)}</li>`).join('')}</ol>
          <details><summary>Réfléchissez, puis affichez le corrigé</summary><div class="case-sol">${md(b.solution)}</div></details></section>`;
      case 'tip': return `<aside class="callout tip"><strong>À retenir</strong><p>${md(b.x)}</p></aside>`;
      case 'action': return `<aside class="callout action"><strong>Et vous ?</strong><p>${md(b.x)}</p></aside>`;
      default: return '';
    }
  }

  function videoBlock(m) {
    const v = m.video || {};
    if (v.src) {
      return `<div class="video" data-src="${esc(v.src)}"><button class="video-load" type="button">
        <span class="play" aria-hidden="true">▶</span><span><strong>${esc(v.title)}</strong><br><small>${esc(v.duration)} · se charge uniquement si vous appuyez</small></span></button></div>`;
    }
    return `<div class="video video-pending"><div class="play" aria-hidden="true">▶</div>
      <div><strong>${esc(v.title || 'Vidéo résumé')}</strong> <small>(${esc(v.duration || '5 min')})</small><br>
      <small>La vidéo résumé est en cours de tournage. Le résumé écrit ci-dessous couvre l’essentiel.</small></div></div>
      ${v.script ? `<details class="script"><summary>Déroulé de la vidéo</summary><ol>${v.script.map(s => `<li>${md(s)}</li>`).join('')}</ol></details>` : ''}`;
  }

  /* ------------------------------------------------------------------ *
   *  Composants
   * ------------------------------------------------------------------ */
  const bar = pct => `<div class="bar" role="progressbar" aria-valuenow="${pct}" aria-valuemin="0" aria-valuemax="100"><span style="width:${pct}%"></span></div>`;

  function moduleCard(id) {
    const m = CAT.modules[id], t = trackOf(id), acc = moduleAccess(id), pct = moduleProgressPct(id);
    let badge = '';
    if (isPassed(id)) badge = '<span class="badge ok">Validé ✓</span>';
    else if (m.status !== 'complet') badge = '<span class="badge soon">Bientôt</span>';
    else if (acc.reason === 'paywall') badge = '<span class="badge lock">🔒 Parcours payant</span>';
    else if (acc.reason === 'sequence') badge = '<span class="badge lock">🔒 Validez le module précédent</span>';
    else if (t.free) badge = '<span class="badge free">Gratuit</span>';
    return `<a class="card module-card" href="#/module/${id}">
      <div class="card-top"><span class="code">${id}</span>${badge}</div>
      <h3>${esc(m.title)}</h3><p>${esc(m.summary)}</p>
      <div class="meta">⏱ ${esc(m.duration)} · ${m.lessons.length} leçons${m.status === 'complet' ? ` · ${m.quiz.length} questions` : ''}</div>
      ${pct ? bar(pct) : ''}</a>`;
  }

  function trackCard(t) {
    const s = trackStats(t);
    const price = t.free ? '<span class="price free">Gratuit</span>' : `<span class="price">${fcfa(t.price)}</span>`;
    return `<a class="card track-card lvl${t.level}" href="#/parcours/${t.id}">
      <div class="card-top"><span class="level">${t.free ? 'Accès libre' : 'Niveau ' + t.level}</span>${isUnlocked(t) && !t.free ? '<span class="badge ok">Débloqué</span>' : ''}</div>
      <h3>${esc(t.title)}</h3><p>${esc(t.desc)}</p>
      <div class="meta">${t.modules.length} modules · ${esc(t.audience)}</div>
      <div class="card-foot">${price}${s.passed ? `<span class="muted">${s.passed}/${s.total} validés</span>` : ''}</div></a>`;
  }

  /* ------------------------------------------------------------------ *
   *  Vues
   * ------------------------------------------------------------------ */
  function viewHome() {
    const free = CAT.tracks.find(t => t.free);
    const paid = CAT.tracks.filter(t => !t.free);
    return `
    <section class="hero">
      <p class="eyebrow">Performance commerciale et marketing d’innovation</p>
      <h1>Devenez le commercial, le manager ou le directeur dont l’Afrique a besoin.</h1>
      <p class="lead">Des cours 100 % en ligne, pensés pour le mobile et les petits forfaits : une vidéo résumé courte, des leçons claires avec tableaux, matrices et études de cas africaines, un quiz de validation, puis un <strong>certificat à votre nom</strong>.</p>
      <div class="actions"><a class="btn primary" href="#/module/F1">Commencer gratuitement</a><a class="btn" href="#/tarifs">Voir les parcours et tarifs</a></div>
      <ul class="proof"><li>📱 Pensé pour le mobile</li><li>📶 Léger en données, disponible hors ligne</li><li>🌍 Études de cas d’Afrique francophone</li><li>💳 Mobile Money</li></ul>
    </section>

    <section class="how">
      <h2>Comment ça marche</h2>
      <ol class="flow big"><li>Vidéo résumé</li><li>Leçons en étapes</li><li>Étude de cas</li><li>Quiz (80 % requis)</li><li>Certificat à votre nom</li></ol>
    </section>

    <section><div class="section-head"><h2>Modules gratuits</h2><a href="#/parcours/${free.id}">Tout voir →</a></div>
      <div class="grid">${free.modules.map(moduleCard).join('')}</div></section>

    <section><div class="section-head"><h2>4 parcours métier, une carrière</h2><a href="#/parcours">Catalogue →</a></div>
      <ol class="career">${paid.map(t => `<li><a href="#/parcours/${t.id}"><span>Niveau ${t.level}</span><strong>${esc(t.title)}</strong></a></li>`).join('')}</ol>
      <div class="grid">${paid.map(trackCard).join('')}</div></section>

    <section class="band"><div><h2>Vous formez une équipe ?</h2><p>Licences entreprises dès 5 apprenants, jusqu’à −35 %, suivi de progression et atelier en présentiel avec StratFocus Consulting.</p></div>
      <a class="btn primary" href="${waLink('Bonjour STFC Academy, je souhaite un devis entreprise pour former mon équipe commerciale.')}" target="_blank" rel="noopener">Demander un devis</a></section>`;
  }

  function viewCatalogue() {
    return `<h1>Catalogue des parcours</h1>
      <p class="lead">Commencez par les modules gratuits, puis progressez de Commercial à Directeur commercial.</p>
      <div class="grid">${CAT.tracks.map(trackCard).join('')}</div>`;
  }

  function viewTrack(id) {
    const t = CAT.tracks.find(x => x.id === id);
    if (!t) return viewNotFound();
    const s = trackStats(t);
    const unlocked = isUnlocked(t);
    const certReady = !t.free && s.complete;
    return `<nav class="crumbs"><a href="#/parcours">Parcours</a> › ${esc(t.title)}</nav>
      <header class="page-head lvl${t.level}">
        <p class="eyebrow">${t.free ? 'Accès libre' : 'Parcours niveau ' + t.level}</p>
        <h1>${esc(t.title)}</h1><p class="lead">${esc(t.desc)}</p>
        <p class="muted">Pour qui : ${esc(t.audience)}</p>
        ${t.free ? '' : unlocked
          ? `<p class="badge ok">Parcours débloqué</p>`
          : `<div class="buy"><div><span class="price">${fcfa(t.price)}</span><small>ou 3 × ${fcfa(t.installments)} en Mobile Money · accès à vie</small></div>
              <div class="actions"><a class="btn primary" href="${waLink(`Bonjour, je souhaite acheter le parcours « ${t.title} » (${fcfa(t.price)}).`)}" target="_blank" rel="noopener">Acheter via WhatsApp</a><a class="btn" href="#/activer">J’ai un code d’accès</a></div></div>`}
        ${!t.free ? `<div class="track-progress">${bar(Math.round(s.passed / s.total * 100))}<small>${s.passed}/${s.total} modules validés${s.ready < s.total ? ` · ${s.total - s.ready} module(s) en cours de rédaction` : ''}</small></div>` : ''}
        ${certReady ? `<a class="btn primary" href="#/certificat/parcours/${t.id}">🎓 Télécharger mon certificat de parcours</a>` : ''}
      </header>
      <div class="grid">${t.modules.map(moduleCard).join('')}</div>`;
  }

  function viewModule(id) {
    const m = CAT.modules[id];
    if (!m) return viewNotFound();
    const t = trackOf(id), acc = moduleAccess(id), p = state.progress[id];
    const head = `<nav class="crumbs"><a href="#/parcours/${t.id}">${esc(t.title)}</a> › ${id}</nav>
      <header class="page-head"><p class="eyebrow">Module ${id} · ⏱ ${esc(m.duration)}</p><h1>${esc(m.title)}</h1><p class="lead">${esc(m.summary)}</p></header>`;
    const objectives = `<section class="objectives"><h2>Objectifs</h2><p>À la fin de ce module, vous saurez :</p><ul class="list check">${m.objectives.map(o => `<li>${esc(o)}</li>`).join('')}</ul></section>`;

    if (!acc.ok) {
      let box = '';
      if (acc.reason === 'paywall') box = `<div class="notice lock"><h2>🔒 Module du parcours « ${esc(t.title)} »</h2><p>Débloquez le parcours complet pour accéder aux leçons, au quiz et au certificat.</p>
        <div class="actions"><a class="btn primary" href="#/parcours/${t.id}">Voir l’offre (${fcfa(t.price)})</a><a class="btn" href="#/activer">J’ai un code d’accès</a></div></div>`;
      if (acc.reason === 'sequence') box = `<div class="notice lock"><h2>🔒 Progression étape par étape</h2><p>Validez d’abord le module <a href="#/module/${acc.blocker}">${acc.blocker} — ${esc(CAT.modules[acc.blocker].title)}</a>.</p></div>`;
      if (acc.reason === 'bientot') box = `<div class="notice soon"><h2>✍️ Module en cours de rédaction</h2><p>Le programme est prêt. Les leçons, la vidéo et le quiz arrivent bientôt.</p></div>`;
      return head + box + objectives + `<section><h2>Programme</h2><ol class="lesson-list">${m.lessons.map(l => `<li><span>${esc(l.title)}</span></li>`).join('')}</ol></section>`;
    }

    const firstTodo = m.lessons.findIndex((_, i) => !(p && p.lessons[i]));
    const startIdx = firstTodo === -1 ? 0 : firstTodo;
    const passed = isPassed(id);
    return head + `
      <section class="video-zone"><h2>Vidéo résumé</h2>${videoBlock(m)}</section>
      ${objectives}
      <section><h2>Programme</h2>${bar(moduleProgressPct(id))}
        <ol class="lesson-list">${m.lessons.map((l, i) => `<li class="${p && p.lessons[i] ? 'done' : ''}"><a href="#/module/${id}/lecon/${i + 1}"><span>${esc(l.title)}</span>${p && p.lessons[i] ? '<b>✓</b>' : ''}</a></li>`).join('')}
          <li class="${passed ? 'done' : ''}"><a href="#/module/${id}/quiz"><span>Quiz de validation (${m.quiz.length} questions, ${CAT.passMark} % requis)</span>${passed ? '<b>✓</b>' : ''}</a></li></ol>
        <div class="actions">${passed
          ? `<a class="btn primary" href="#/certificat/module/${id}">🎓 Mon attestation</a><a class="btn" href="#/module/${id}/lecon/1">Revoir le cours</a>`
          : `<a class="btn primary" href="#/module/${id}/lecon/${startIdx + 1}">${firstTodo > 0 ? 'Reprendre' : firstTodo === -1 ? 'Revoir le cours' : 'Commencer'}</a>${lessonsDone(id) ? `<a class="btn" href="#/module/${id}/quiz">Passer le quiz</a>` : ''}`}</div>
      </section>
      <section class="takeaways"><h2>Résumé écrit (à retenir)</h2><ul class="list">${m.takeaways.map(x => `<li>${md(x)}</li>`).join('')}</ul></section>`;
  }

  function viewLesson(id, n) {
    const m = CAT.modules[id];
    if (!m) return viewNotFound();
    const acc = moduleAccess(id);
    if (!acc.ok) { location.hash = `#/module/${id}`; return ''; }
    const i = Math.min(Math.max(1, n), m.lessons.length) - 1;
    const l = m.lessons[i], last = i === m.lessons.length - 1;
    const p = prog(id);
    return `<nav class="crumbs"><a href="#/module/${id}">${id} · ${esc(m.title)}</a> › Leçon ${i + 1}/${m.lessons.length}</nav>
      <div class="stepper">${m.lessons.map((_, k) => `<a href="#/module/${id}/lecon/${k + 1}" class="${k === i ? 'current' : p.lessons[k] ? 'done' : ''}" aria-label="Leçon ${k + 1}">${k + 1}</a>`).join('<span></span>')}<span></span><a href="#/module/${id}/quiz" class="${isPassed(id) ? 'done' : ''}" aria-label="Quiz">✓</a></div>
      <article class="lesson"><p class="eyebrow">Leçon ${i + 1}</p><h1>${esc(l.title)}</h1>${l.blocks.map(renderBlock).join('')}</article>
      ${last ? `<section class="takeaways"><h2>À retenir du module</h2><ul class="list">${m.takeaways.map(x => `<li>${md(x)}</li>`).join('')}</ul></section>` : ''}
      <div class="lesson-nav">${i > 0 ? `<a class="btn" href="#/module/${id}/lecon/${i}">← Précédent</a>` : '<span></span>'}
        <button class="btn primary" data-complete="${id}:${i}" data-next="${last ? `#/module/${id}/quiz` : `#/module/${id}/lecon/${i + 2}`}">${last ? 'Terminer et passer le quiz →' : 'J’ai compris, suivant →'}</button></div>`;
  }

  let quizSession = null;
  function viewQuiz(id) {
    const m = CAT.modules[id];
    if (!m) return viewNotFound();
    if (!moduleAccess(id).ok) { location.hash = `#/module/${id}`; return ''; }
    if (!lessonsDone(id)) {
      return `<nav class="crumbs"><a href="#/module/${id}">${id} · ${esc(m.title)}</a> › Quiz</nav>
        <div class="notice lock"><h2>Terminez d’abord les leçons</h2><p>Le quiz se débloque une fois toutes les leçons parcourues.</p><a class="btn primary" href="#/module/${id}">Retour au module</a></div>`;
    }
    quizSession = { id, questions: shuffle(m.quiz.map((q, qi) => ({ ...q, qi, order: shuffle(q.options.map((_, oi) => oi)) }))) };
    const best = state.progress[id] && state.progress[id].quiz;
    return `<nav class="crumbs"><a href="#/module/${id}">${id} · ${esc(m.title)}</a> › Quiz de validation</nav>
      <header class="page-head"><p class="eyebrow">Quiz de validation</p><h1>${esc(m.title)}</h1>
      <p class="lead">${m.quiz.length} questions · Score requis : <strong>${CAT.passMark} %</strong> · Tentatives illimitées${best ? ` · Meilleur score : ${best.best} %` : ''}</p></header>
      <form id="quiz" class="quiz">${quizSession.questions.map((q, k) => `
        <fieldset class="q" data-k="${k}"><legend><span>${k + 1}.</span> ${md(q.q)}</legend>
        ${q.order.map(oi => `<label><input type="radio" name="q${k}" value="${oi}" required> <span>${md(q.options[oi])}</span></label>`).join('')}
        <p class="why" hidden></p></fieldset>`).join('')}
        <div class="actions"><button class="btn primary" type="submit">Valider mes réponses</button></div>
      </form><div id="quiz-result" aria-live="polite"></div>`;
  }

  function gradeQuiz(form) {
    const s = quizSession; if (!s) return;
    const m = CAT.modules[s.id];
    let good = 0;
    s.questions.forEach((q, k) => {
      const fs = form.querySelector(`fieldset[data-k="${k}"]`);
      const chosen = fs.querySelector('input:checked');
      const ok = chosen && Number(chosen.value) === q.a;
      if (ok) good++;
      fs.classList.add(ok ? 'right' : 'wrong');
      fs.querySelectorAll('input').forEach(inp => { inp.disabled = true; if (Number(inp.value) === q.a) inp.parentElement.classList.add('answer'); });
      const why = fs.querySelector('.why'); why.hidden = false; why.innerHTML = `${ok ? '✅ Bonne réponse.' : '❌ Réponse attendue : <strong>' + md(q.options[q.a]) + '</strong>.'} ${md(q.why)}`;
    });
    const score = Math.round(good / s.questions.length * 100);
    const passed = score >= CAT.passMark;
    const p = prog(s.id);
    const prev = p.quiz || { best: 0, passed: false, attempts: 0 };
    p.quiz = { best: Math.max(prev.best, score), passed: prev.passed || passed, attempts: (prev.attempts || 0) + 1, date: prev.passed ? prev.date : (passed ? new Date().toISOString() : null) };
    save();
    form.querySelector('button[type="submit"]').remove();
    const res = document.getElementById('quiz-result');
    res.innerHTML = passed
      ? `<div class="notice ok"><h2>🎉 Bravo ! ${score} %</h2><p>Vous avez validé le module <strong>${esc(m.title)}</strong>. Votre attestation est disponible.</p>
          <div class="actions"><a class="btn primary" href="#/certificat/module/${s.id}">🎓 Obtenir mon attestation</a>${nextModuleLink(s.id)}</div></div>`
      : `<div class="notice lock"><h2>${score} %, encore un effort</h2><p>Il faut ${CAT.passMark} % pour valider. Relisez les explications ci-dessus, puis réessayez : les questions seront mélangées.</p>
          <div class="actions"><a class="btn primary" href="#/module/${s.id}/quiz" data-reload>Recommencer le quiz</a><a class="btn" href="#/module/${s.id}/lecon/1">Revoir les leçons</a></div></div>`;
    res.scrollIntoView({ behavior: 'smooth', block: 'start' });
  }

  function nextModuleLink(id) {
    const t = trackOf(id), idx = t.modules.indexOf(id);
    const next = t.modules.slice(idx + 1).find(x => CAT.modules[x].status === 'complet');
    return next ? `<a class="btn" href="#/module/${next}">Module suivant : ${next} →</a>` : `<a class="btn" href="#/parcours/${t.id}">Retour au parcours</a>`;
  }

  /* ---------- Certificats ---------- */
  function certKey(kind, id) { return kind + ':' + id; }
  function issueCert(kind, id) {
    const key = certKey(kind, id);
    if (state.certs[key]) return state.certs[key];
    const date = kind === 'module' ? (state.progress[id].quiz.date || new Date().toISOString()) : new Date().toISOString();
    const year = new Date(date).getFullYear();
    const cert = { kind, id, name: state.name.trim(), date, score: kind === 'module' ? state.progress[id].quiz.best : null,
      ref: `STFC-${year}-${hash36(state.name + '|' + key + '|' + date).slice(-6)}` };
    state.certs[key] = cert; save();
    return cert;
  }

  function viewCertificate(kind, id) {
    let title, eligible, back, skills, subtitle;
    if (kind === 'module') {
      const m = CAT.modules[id]; if (!m) return viewNotFound();
      eligible = isPassed(id); title = m.title; skills = m.skills || []; back = `#/module/${id}`;
      subtitle = trackOf(id).free ? 'Module découverte' : 'Parcours ' + trackOf(id).title;
    } else {
      const t = CAT.tracks.find(x => x.id === id); if (!t) return viewNotFound();
      eligible = !t.free && trackStats(t).complete; title = t.title; back = `#/parcours/${id}`;
      skills = t.modules.flatMap(x => CAT.modules[x].skills || []).slice(0, 6); subtitle = 'Parcours complet';
    }
    if (!eligible) return `<div class="notice lock"><h2>Certificat non disponible</h2><p>Validez ${kind === 'module' ? 'le quiz de ce module' : 'tous les modules du parcours'} pour l’obtenir.</p><a class="btn primary" href="${back}">Retour</a></div>`;

    const existing = state.certs[certKey(kind, id)];
    if (!existing && !state.name.trim()) {
      return `<nav class="crumbs"><a href="${back}">Retour</a> › Certificat</nav>
        <div class="notice ok"><h2>Votre nom sur le certificat</h2><p>Saisissez vos prénom et nom <strong>tels qu’ils doivent apparaître</strong>. Vérifiez l’orthographe : le nom ne pourra plus être modifié sur ce certificat.</p>
        <form id="name-form" class="inline-form"><label for="fullname" class="sr-only">Prénom et nom</label>
        <input id="fullname" name="fullname" required minlength="3" maxlength="60" autocomplete="name" placeholder="Ex. Aminata Diallo">
        <button class="btn primary" type="submit">Générer mon certificat</button></form></div>`;
    }
    const cert = existing || issueCert(kind, id);
    return `<nav class="crumbs"><a href="${back}">Retour</a> › Certificat</nav>
      <header class="page-head no-print"><h1>🎓 Félicitations, ${esc(cert.name)} !</h1><p class="lead">Téléchargez votre ${kind === 'module' ? 'attestation' : 'certificat'} et partagez-le sur LinkedIn et WhatsApp.</p></header>
      <div class="cert-wrap"><canvas id="cert" width="1754" height="1240" aria-label="Certificat de ${esc(cert.name)}"></canvas><img id="cert-img" alt="Certificat de ${esc(cert.name)}"></div>
      <div class="actions no-print"><button class="btn primary" id="dl-png">⬇ Télécharger (image PNG)</button><button class="btn" id="dl-pdf">🖨 Imprimer ou enregistrer en PDF</button>
        <a class="btn" target="_blank" rel="noopener" href="${waLink(`J’ai obtenu mon ${kind === 'module' ? 'attestation' : 'certificat'} « ${title} » sur STFC Academy ! Référence ${cert.ref}`)}">Partager sur WhatsApp</a></div>
      <p class="muted no-print">Référence : <strong>${cert.ref}</strong>. Conservez-la : elle permet de vérifier l’authenticité du certificat.</p>
      <script type="application/json" id="cert-data">${JSON.stringify({ cert, title, subtitle, skills }).replace(/</g, '\\u003c')}</script>`;
  }

  function drawCertificate() {
    const canvas = document.getElementById('cert'); if (!canvas) return;
    const { cert, title, subtitle, skills } = JSON.parse(document.getElementById('cert-data').textContent);
    const c = canvas.getContext('2d'), W = canvas.width, H = canvas.height;
    const navy = '#0b2545', gold = '#c8892b', ink = '#1d2433';
    const font = (w, s, fam) => `${w} ${s}px ${fam || 'Georgia, "Times New Roman", serif'}`;
    const sans = 'system-ui, -apple-system, "Segoe UI", Roboto, Arial, sans-serif';

    c.fillStyle = '#fffdf8'; c.fillRect(0, 0, W, H);
    // Cadres
    c.strokeStyle = navy; c.lineWidth = 18; c.strokeRect(40, 40, W - 80, H - 80);
    c.strokeStyle = gold; c.lineWidth = 4; c.strokeRect(78, 78, W - 156, H - 156);
    // Bandeau latéral décoratif
    c.fillStyle = navy; c.fillRect(78, 78, 26, H - 156); c.fillStyle = gold; c.fillRect(104, 78, 8, H - 156);
    // Coins
    c.fillStyle = gold; [[100, 100], [W - 100, 100], [100, H - 100], [W - 100, H - 100]].forEach(([x, y]) => { c.beginPath(); c.arc(x, y, 10, 0, Math.PI * 2); c.fill(); });

    c.textAlign = 'center';
    const cx = W / 2 + 20;
    c.fillStyle = navy; c.font = font('700', 40, sans); c.fillText(CFG.brand.toUpperCase(), cx, 190);
    c.fillStyle = '#5b6475'; c.font = font('400', 24, sans); c.fillText('by ' + CFG.org + ' · Performance commerciale et marketing d’innovation', cx, 232);

    c.fillStyle = gold; c.font = font('700', 76); c.fillText(cert.kind === 'module' ? 'ATTESTATION DE RÉUSSITE' : 'CERTIFICAT PROFESSIONNEL', cx, 360);
    c.fillStyle = ink; c.font = font('italic 400', 32); c.fillText('décerné(e) à', cx, 440);

    // Nom (ajusté à la largeur)
    let size = 104; c.font = font('700', size);
    while (c.measureText(cert.name).width > W - 420 && size > 50) { size -= 4; c.font = font('700', size); }
    c.fillStyle = navy; c.fillText(cert.name, cx, 560);
    c.strokeStyle = gold; c.lineWidth = 3; c.beginPath(); c.moveTo(cx - 450, 600); c.lineTo(cx + 450, 600); c.stroke();

    c.fillStyle = ink; c.font = font('400', 32);
    c.fillText(cert.kind === 'module' ? 'pour avoir suivi et validé le module' : 'pour avoir validé l’ensemble des modules du parcours', cx, 670);
    let tsize = 54; c.font = font('700', tsize);
    while (c.measureText('« ' + title + ' »').width > W - 400 && tsize > 30) { tsize -= 2; c.font = font('700', tsize); }
    c.fillStyle = navy; c.fillText('« ' + title + ' »', cx, 750);
    c.fillStyle = '#5b6475'; c.font = font('400', 28, sans);
    c.fillText(subtitle + (cert.score != null ? ` · Score obtenu : ${cert.score} %` : ''), cx, 805);

    if (skills.length) {
      c.font = font('600', 24, sans); c.fillStyle = ink;
      const line = 'Compétences validées : ' + skills.join(' · ');
      let ss = 24; while (c.measureText(line).width > W - 360 && ss > 16) { ss -= 1; c.font = font('600', ss, sans); }
      c.fillText(line, cx, 870);
    }

    // Pied : date, sceau, signature
    c.textAlign = 'left'; c.fillStyle = ink; c.font = font('400', 26, sans);
    c.fillText('Délivré le ' + fmtDate(cert.date), 220, 1040);
    c.fillText('Référence : ' + cert.ref, 220, 1080);

    // Sceau
    const sx = cx, sy = 1010;
    c.fillStyle = gold; c.beginPath(); for (let k = 0; k < 24; k++) { const r = k % 2 ? 78 : 92, a = k / 24 * Math.PI * 2; c.lineTo(sx + r * Math.cos(a), sy + r * Math.sin(a)); } c.closePath(); c.fill();
    c.fillStyle = navy; c.beginPath(); c.arc(sx, sy, 66, 0, Math.PI * 2); c.fill();
    c.textAlign = 'center'; c.fillStyle = '#fff'; c.font = font('700', 30, sans); c.fillText('STFC', sx, sy + 2); c.font = font('600', 16, sans); c.fillText('ACADEMY', sx, sy + 28);

    c.textAlign = 'right'; c.fillStyle = ink;
    c.strokeStyle = ink; c.lineWidth = 2; c.beginPath(); c.moveTo(W - 560, 1030); c.lineTo(W - 220, 1030); c.stroke();
    c.font = font('600', 26, sans); c.fillText(CFG.signatory.name, W - 220, 1068);
    c.font = font('400', 22, sans); c.fillStyle = '#5b6475'; c.fillText(CFG.signatory.title, W - 220, 1100);

    const img = document.getElementById('cert-img'); img.src = canvas.toDataURL('image/png');
    const fname = `STFC-${cert.kind === 'module' ? 'Attestation' : 'Certificat'}-${cert.id}-${cert.name.replace(/[^\p{L}\p{N}]+/gu, '_')}.png`;
    document.getElementById('dl-png').onclick = () => canvas.toBlob(b => { const a = document.createElement('a'); a.href = URL.createObjectURL(b); a.download = fname; a.click(); setTimeout(() => URL.revokeObjectURL(a.href), 2000); });
    document.getElementById('dl-pdf').onclick = () => window.print();
  }

  /* ---------- Tarifs ---------- */
  function viewPricing() {
    const paid = CAT.tracks.filter(t => !t.free);
    return `<header class="page-head"><p class="eyebrow">Tarifs</p><h1>Investissez dans votre carrière, à votre rythme</h1>
      <p class="lead">Prix TTC en FCFA (zone UEMOA et CEMAC). Achat <strong>à vie</strong>, sans abonnement caché ni renouvellement automatique. Paiement en 1 ou 3 fois par Mobile Money.</p></header>
      <div class="grid pricing">
        <div class="card plan"><h3>Découverte</h3><p class="price free">Gratuit</p><ul class="list check"><li>3 modules complets</li><li>Quiz et attestations</li><li>Sans inscription</li></ul><a class="btn" href="#/parcours/decouverte">Commencer</a></div>
        ${paid.map(t => `<div class="card plan lvl${t.level}"><h3>${esc(t.title)}</h3><p class="price">${fcfa(t.price)}</p><p class="muted">ou 3 × ${fcfa(t.installments)}</p>
          <ul class="list check"><li>${t.modules.length} modules progressifs</li><li>Vidéos, études de cas, quiz</li><li>Attestation par module + certificat de parcours</li></ul>
          <a class="btn primary" target="_blank" rel="noopener" href="${waLink(`Bonjour, je souhaite acheter le parcours « ${t.title} » (${fcfa(t.price)}).`)}">Acheter</a></div>`).join('')}
        <div class="card plan featured"><span class="ribbon">Meilleure offre</span><h3>Pass Carrière</h3><p class="price">${fcfa(CAT.passCarriere.price)}</p><p class="muted">ou 3 × ${fcfa(CAT.passCarriere.installments)} · −27 %</p>
          <ul class="list check"><li>Les 4 parcours, de Commercial à Directeur</li><li>Tous les futurs modules inclus</li><li>4 certificats professionnels</li></ul>
          <a class="btn primary" target="_blank" rel="noopener" href="${waLink(`Bonjour, je souhaite acheter le Pass Carrière (${fcfa(CAT.passCarriere.price)}).`)}">Acheter</a></div>
      </div>
      <section><h2>Entreprises</h2><div class="scroll-x"><table><thead><tr><th>Licences</th><th>Remise</th><th>Inclus</th></tr></thead><tbody>
        <tr><th scope="row">5 à 9</th><td>−15 %</td><td>Suivi de progression</td></tr>
        <tr><th scope="row">10 à 24</th><td>−25 %</td><td>+ Rapport mensuel RH</td></tr>
        <tr><th scope="row">25 à 49</th><td>−35 %</td><td>+ Classe virtuelle dédiée</td></tr>
        <tr><th scope="row">50 et plus</th><td>Sur devis</td><td>+ Atelier présentiel StratFocus Consulting</td></tr></tbody></table></div>
        <a class="btn primary" target="_blank" rel="noopener" href="${waLink('Bonjour, je souhaite un devis entreprise STFC Academy.')}">Demander un devis</a></section>
      <section><h2>Comment acheter ?</h2><ol class="flow big"><li>Choisissez votre offre</li><li>Payez par Orange Money, Wave, MTN MoMo, Moov ou virement</li><li>Recevez votre code par WhatsApp</li><li>Activez-le dans « J’ai un code »</li></ol>
        <p class="muted">Garantie satisfait ou remboursé de 7 jours si moins de 30 % du parcours a été suivi. Code de lancement : <strong>${esc(CFG.launchPromo.code)}</strong> (−${CFG.launchPromo.percent} % pour les premiers inscrits).</p>
        <p class="muted">Pays hors zone FCFA (RDC, Guinée, Madagascar…) : tarifs adaptés sur demande.</p></section>`;
  }

  /* ---------- Activation par code ---------- */
  function viewActivate() {
    const list = state.unlocked.length
      ? `<p>Accès débloqués : <strong>${state.unlocked.map(u => u === 'all' ? 'Tous les parcours' : (CAT.tracks.find(t => t.id === u) || {}).title).join(', ')}</strong></p>` : '';
    return `<header class="page-head"><h1>Activer un code d’accès</h1><p class="lead">Saisissez le code reçu après votre paiement (ex. COM-ABCD-EFGH).</p></header>
      <form id="code-form" class="inline-form"><label for="code" class="sr-only">Code d’accès</label>
        <input id="code" name="code" required autocomplete="off" autocapitalize="characters" spellcheck="false" placeholder="XXX-XXXX-XXXX">
        <button class="btn primary" type="submit">Activer</button></form>
      <div id="code-msg" aria-live="polite"></div>${list}
      <p class="muted">Pas encore de code ? <a href="#/tarifs">Voir les offres</a>, ou écrivez-nous sur <a target="_blank" rel="noopener" href="${waLink('Bonjour, j’ai une question sur mon code d’accès STFC Academy.')}">WhatsApp</a>.</p>`;
  }

  async function activateCode(raw) {
    const msg = document.getElementById('code-msg');
    const code = raw.trim().toUpperCase().replace(/\s+/g, '');
    if (!window.crypto || !crypto.subtle) { msg.innerHTML = '<p class="notice lock">Activation impossible sur une connexion non sécurisée (http). Utilisez l’adresse https du site.</p>'; return; }
    const tracks = CFG.accessCodes[await sha256(code)];
    if (!tracks) { msg.innerHTML = '<p class="notice lock">Code invalide. Vérifiez la saisie (tirets compris) ou contactez-nous.</p>'; return; }
    tracks.forEach(t => { if (!state.unlocked.includes(t)) state.unlocked.push(t); });
    save();
    const target = tracks[0] === 'all' ? '#/parcours' : `#/parcours/${tracks[0]}`;
    msg.innerHTML = `<div class="notice ok"><h2>✅ Code activé</h2><p>${tracks[0] === 'all' ? 'Tous les parcours sont débloqués.' : `Le parcours « ${esc(CAT.tracks.find(t => t.id === tracks[0]).title)} » est débloqué.`}</p><a class="btn primary" href="${target}">Commencer</a></div>`;
  }

  /* ---------- Mon espace ---------- */
  function viewSpace() {
    const certs = Object.values(state.certs);
    const started = Object.keys(state.progress).filter(id => CAT.modules[id] && moduleProgressPct(id) > 0);
    return `<header class="page-head"><h1>Mon espace</h1><p class="lead">Votre progression est enregistrée sur cet appareil.</p></header>
      <section><h2>Mon nom (pour les certificats)</h2>
        <form id="profile-form" class="inline-form"><label for="pname" class="sr-only">Prénom et nom</label><input id="pname" name="pname" maxlength="60" value="${esc(state.name)}" placeholder="Prénom et nom" autocomplete="name"><button class="btn" type="submit">Enregistrer</button></form>
        <p class="muted">Les certificats déjà délivrés conservent le nom utilisé lors de leur émission.</p></section>
      <section><h2>Mes modules en cours</h2>${started.length ? `<div class="grid">${started.map(moduleCard).join('')}</div>` : '<p>Aucun module commencé. <a href="#/module/F1">Commencez par F1, c’est gratuit.</a></p>'}</section>
      <section><h2>Mes certificats</h2>${certs.length ? `<ul class="cert-list">${certs.map(c => {
        const label = c.kind === 'module' ? `${c.id} · ${CAT.modules[c.id].title}` : `Parcours ${CAT.tracks.find(t => t.id === c.id).title}`;
        return `<li><a href="#/certificat/${c.kind}/${c.id}">🎓 ${esc(label)}</a><small>${fmtDate(c.date)} · ${c.ref}</small></li>`; }).join('')}</ul>` : '<p>Pas encore de certificat. Validez un quiz pour obtenir le premier !</p>'}</section>
      <section><h2>Accès</h2><p>${state.unlocked.length ? 'Parcours débloqués : ' + state.unlocked.map(u => u === 'all' ? 'tous' : (CAT.tracks.find(t => t.id === u) || {}).title).join(', ') : 'Aucun parcours payant débloqué.'} <a href="#/activer">Activer un code</a></p></section>
      <section><h2>Changer d’appareil</h2><p class="muted">Sauvegardez votre progression dans un fichier, puis importez-le sur votre autre téléphone ou ordinateur.</p>
        <div class="actions"><button class="btn" id="export">Exporter ma progression</button><label class="btn">Importer<input type="file" id="import" accept="application/json" hidden></label></div></section>`;
  }

  function viewVerify() {
    return `<header class="page-head"><h1>Vérifier un certificat</h1><p class="lead">Saisissez la référence (ex. STFC-2026-AB12CD).</p></header>
      <form id="verify-form" class="inline-form"><label for="ref" class="sr-only">Référence</label><input id="ref" name="ref" required placeholder="STFC-AAAA-XXXXXX" autocomplete="off"><button class="btn primary" type="submit">Vérifier</button></form>
      <div id="verify-msg" aria-live="polite"></div>
      <p class="muted">Pour une vérification officielle par un employeur, contactez STFC Academy par <a href="mailto:${esc(CFG.email)}">e-mail</a> ou <a target="_blank" rel="noopener" href="${waLink('Bonjour, je souhaite vérifier un certificat STFC Academy.')}">WhatsApp</a> avec la référence. La vérification publique en ligne arrivera avec la version 2.</p>`;
  }

  function viewNotFound() { return `<div class="notice lock"><h2>Page introuvable</h2><a class="btn primary" href="#/">Accueil</a></div>`; }

  /* ------------------------------------------------------------------ *
   *  Routeur
   * ------------------------------------------------------------------ */
  function route() {
    const parts = (location.hash.replace(/^#\/?/, '') || '').split('/').filter(Boolean);
    let html;
    const [a, b, c, d] = parts;
    if (!a) html = viewHome();
    else if (a === 'parcours' && !b) html = viewCatalogue();
    else if (a === 'parcours') html = viewTrack(b);
    else if (a === 'module' && c === 'lecon') html = viewLesson(b, parseInt(d, 10) || 1);
    else if (a === 'module' && c === 'quiz') html = viewQuiz(b);
    else if (a === 'module') html = viewModule(b);
    else if (a === 'certificat') html = viewCertificate(b, c);
    else if (a === 'tarifs') html = viewPricing();
    else if (a === 'activer') html = viewActivate();
    else if (a === 'mon-espace') html = viewSpace();
    else if (a === 'verifier') html = viewVerify();
    else html = viewNotFound();
    if (html === '') return; // redirection en cours
    app.innerHTML = html;
    document.querySelectorAll('.nav a').forEach(l => l.classList.toggle('active', location.hash.startsWith(l.getAttribute('href')) && l.getAttribute('href') !== '#/'));
    const h1 = app.querySelector('h1'); document.title = (h1 ? h1.textContent + ' · ' : '') + CFG.brand;
    window.scrollTo(0, 0);
    if (a === 'certificat') drawCertificate();
  }

  /* ------------------------------------------------------------------ *
   *  Événements
   * ------------------------------------------------------------------ */
  app.addEventListener('click', e => {
    const done = e.target.closest('[data-complete]');
    if (done) {
      const [id, i] = done.dataset.complete.split(':');
      prog(id).lessons[Number(i)] = true; save();
      location.hash = done.dataset.next;
      return;
    }
    const reload = e.target.closest('[data-reload]');
    if (reload && reload.getAttribute('href') === location.hash) { e.preventDefault(); route(); return; }
    const vid = e.target.closest('.video-load');
    if (vid) {
      const wrap = vid.parentElement;
      wrap.innerHTML = `<iframe src="${esc(wrap.dataset.src)}" title="Vidéo résumé" allow="autoplay; encrypted-media; picture-in-picture" allowfullscreen loading="lazy"></iframe>`;
      return;
    }
    if (e.target.id === 'export') {
      const blob = new Blob([JSON.stringify(state, null, 2)], { type: 'application/json' });
      const l = document.createElement('a'); l.href = URL.createObjectURL(blob); l.download = 'stfc-academy-progression.json'; l.click();
    }
  });

  app.addEventListener('change', e => {
    if (e.target.id !== 'import' || !e.target.files[0]) return;
    const reader = new FileReader();
    reader.onload = () => {
      try {
        const data = JSON.parse(reader.result);
        if (typeof data !== 'object' || !data.progress) throw new Error('format');
        state = Object.assign(defaultState(), data); save(); route(); alert('Progression importée.');
      } catch (err) { alert('Fichier invalide.'); }
    };
    reader.readAsText(e.target.files[0]);
  });

  app.addEventListener('submit', e => {
    e.preventDefault();
    const f = e.target;
    if (f.id === 'quiz') gradeQuiz(f);
    else if (f.id === 'name-form') { state.name = f.fullname.value.trim().replace(/\s+/g, ' '); save(); route(); }
    else if (f.id === 'profile-form') { state.name = f.pname.value.trim().replace(/\s+/g, ' '); save(); route(); }
    else if (f.id === 'code-form') activateCode(f.code.value);
    else if (f.id === 'verify-form') {
      const ref = f.ref.value.trim().toUpperCase();
      const found = Object.values(state.certs).find(c => c.ref === ref);
      const ok = /^STFC-\d{4}-[0-9A-Z]{6}$/.test(ref);
      document.getElementById('verify-msg').innerHTML = found
        ? `<div class="notice ok"><h2>✅ Certificat trouvé sur cet appareil</h2><p>${esc(found.name)} · ${esc(found.kind === 'module' ? CAT.modules[found.id].title : 'Parcours ' + CAT.tracks.find(t => t.id === found.id).title)} · ${fmtDate(found.date)}</p></div>`
        : `<div class="notice ${ok ? 'soon' : 'lock'}"><p>${ok ? 'Format valide. Contactez STFC Academy pour une vérification officielle.' : 'Format de référence invalide.'}</p></div>`;
    }
  });

  window.addEventListener('hashchange', route);
  route();

  // Mode hors ligne (PWA)
  if ('serviceWorker' in navigator && location.protocol === 'https:') {
    window.addEventListener('load', () => navigator.serviceWorker.register('sw.js').catch(() => {}));
  }
})();
