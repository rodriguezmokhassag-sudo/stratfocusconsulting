/* STFC Academy : espace apprenant (vues publiques, apprentissage, paiement, certificats). */
(function () {
  'use strict';
  const S = window.STFC, { esc, md, api, bar, notice, money, route } = S;
  const forms = S.forms = {};
  let catalog = null;

  const zone = () => S.store.get('zone') || (S.state.me && S.state.me.zone) || 'uemoa';
  async function getCatalog(force) {
    if (!catalog || force || catalog.zone !== zone()) catalog = await api('/catalog?zone=' + zone());
    return catalog;
  }
  const priceLine = q => {
    if (!q) return '';
    const d = q.display;
    const parts = [];
    if (d.currency !== 'EUR') parts.push('≈ ' + money(q.eur, 'EUR'));
    if (d.currency !== q.currency && !(['XOF', 'XAF'].includes(d.currency) && ['XOF', 'XAF'].includes(q.currency))) parts.push('débité ' + money(q.amount, q.currency) + ' par carte');
    if (q.installments) parts.push('ou 3 × ' + money(q.installments.display.amount, q.installments.display.currency));
    return `<span class="price">${money(d.amount, d.currency)}</span><span class="price-sub">${parts.join(' · ')}</span>`;
  };

  function moduleBadge(m) {
    if (m.passed) return '<span class="badge ok">Validé ✓</span>';
    if (m.status !== 'complet') return '<span class="badge soon">Bientôt</span>';
    if (m.access.reason === 'paywall') return '<span class="badge lock">🔒 Parcours payant</span>';
    if (m.access.reason === 'sequence') return '<span class="badge lock">🔒 Module précédent à valider</span>';
    return m.pct ? `<span class="badge free">${m.pct} %</span>` : '';
  }
  const moduleCard = (m, free) => `<a class="card module-card" href="#/module/${m.id}"><div class="card-top"><span class="code">${m.id}</span>${free && !m.passed && !m.pct ? '<span class="badge free">Gratuit</span>' : moduleBadge(m)}</div>
    <h3>${esc(m.title)}</h3><p>${esc(m.summary)}</p><div class="meta">⏱ ${esc(m.duration)} · ${m.lessonCount} leçons${m.quizCount ? ` · quiz ${m.quizCount} questions` : ''}</div>${m.pct ? bar(m.pct) : ''}</a>`;
  const trackCard = t => `<a class="card track-card lvl${t.level}" href="#/parcours/${t.id}"><div class="card-top"><span class="level">${t.free ? 'Accès libre' : 'Niveau ' + t.level}</span>${t.unlocked && !t.free ? '<span class="badge ok">Débloqué</span>' : ''}</div>
    <h3>${esc(t.title)}</h3><p>${esc(t.desc)}</p><div class="meta">${t.modules.length} modules · ${esc(t.duration)}</div><div class="card-foot">${t.free ? '<span class="price free">Gratuit</span>' : `<div>${priceLine(t.price)}</div>`}</div></a>`;

  /* ================= Accueil ================= */
  route(/^\/$/, async () => {
    const c = await getCatalog();
    const free = c.tracks.find(t => t.free), paid = c.tracks.filter(t => !t.free);
    return `<section class="hero"><p class="eyebrow">Performance commerciale · Marketing · Innovation</p>
      <h1>Devenez le commercial, le manager ou le directeur dont l’Afrique a besoin.</h1>
      <p class="lead">Des formations 100 % en ligne, pensées pour le mobile et les petits forfaits : vidéo résumé courte, leçons en étapes avec tableaux, matrices et études de cas africaines, quiz de validation, puis un <strong>certificat à votre nom</strong>.</p>
      <div class="actions"><a class="btn primary" href="#/module/F1">Commencer gratuitement</a><a class="btn" href="#/auto-evaluation">Tester mon niveau (3 min)</a></div>
      <ul class="proof"><li>📱 Mobile d’abord</li><li>📶 Léger, PDF hors connexion</li><li>🌍 Cas d’Afrique francophone</li><li>💳 Mobile Money et carte</li><li>🎓 Certificat vérifiable</li></ul></section>
      <section class="how"><h2>Comment ça marche</h2><ol class="flow big"><li>Vidéo résumé</li><li>Leçons en étapes</li><li>Étude de cas</li><li>Quiz (${S.state.config.passMark} % requis)</li><li>Certificat à votre nom</li></ol></section>
      <section><div class="section-head"><h2>Modules gratuits</h2><a href="#/parcours/${free.id}">Tout voir →</a></div><div class="grid">${free.modules.map(m => moduleCard(m, true)).join('')}
        <a class="card module-card" href="#/auto-evaluation"><div class="card-top"><span class="code">QUIZ</span><span class="badge free">Gratuit</span></div><h3>Auto-évaluation</h3><p>10 questions pour connaître votre niveau et le parcours qui vous correspond.</p><div class="meta">⏱ 3 min</div></a></div></section>
      <section><div class="section-head"><h2>4 parcours métier, une carrière</h2><a href="#/tarifs">Tarifs →</a></div>
        <ol class="career">${paid.map(t => `<li><a href="#/parcours/${t.id}"><span>Niveau ${t.level}</span><strong>${esc(t.title)}</strong></a></li>`).join('')}</ol>
        <div class="grid">${paid.map(trackCard).join('')}</div></section>
      <section class="band"><div><h2>Vous formez une équipe ?</h2><p>Licences entreprises dès 5 apprenants (jusqu’à −35 %), tableau de suivi, atelier présentiel avec StratFocus Consulting.</p></div>
        <a class="btn primary" target="_blank" rel="noopener" href="${S.wa('Bonjour STFC Academy, je souhaite un devis entreprise.')}">Demander un devis</a></section>`;
  });

  /* ================= Catalogue et parcours ================= */
  route(/^\/parcours$/, async () => {
    const c = await getCatalog();
    return `<h1>Catalogue des parcours</h1><p class="lead">Commencez par les modules gratuits, puis progressez de Commercial à Directeur commercial.</p>
      ${zonePicker()}<div class="grid">${c.tracks.map(trackCard).join('')}</div>`;
  });

  route(/^\/parcours\/([\w-]+)$/, async id => {
    const c = await getCatalog(true);
    const t = c.tracks.find(x => x.id === id); if (!t) return null;
    const passed = t.modules.filter(m => m.passed).length;
    const certDone = !t.free && passed === t.modules.length;
    return `<nav class="crumbs"><a href="#/parcours">Parcours</a> › ${esc(t.title)}</nav>
      <header class="page-head lvl${t.level}"><p class="eyebrow">${t.free ? 'Accès libre' : 'Parcours niveau ' + t.level}</p><h1>${esc(t.title)}</h1><p class="lead">${esc(t.desc)}</p>
        <div class="split"><div><strong>Objectifs</strong><ul class="list check">${t.objectives.map(o => `<li>${esc(o)}</li>`).join('')}</ul></div>
        <div><p class="muted">Pour qui : ${esc(t.audience)}<br>Durée : ${esc(t.duration)} · ${t.modules.length} modules<br>Délivré : ${esc(t.certificate)}</p></div></div>
        ${t.free ? '' : t.unlocked ? '<p class="badge ok">Parcours débloqué</p>' : `<div class="buy"><div>${priceLine(t.price)}<span class="price-sub">Accès à vie · garantie 7 jours</span></div>
          <div class="actions"><a class="btn primary" href="#/acheter/track:${t.id}">Acheter ce parcours</a><a class="btn" href="#/activer">J’ai un code</a></div></div>`}
        ${!t.free && S.state.me ? `<div class="track-progress">${bar(Math.round(passed / t.modules.length * 100))}<small>${passed}/${t.modules.length} modules validés</small></div>` : ''}
        ${certDone ? '<button class="btn primary" data-cert="track" data-id="' + t.id + '">🎓 Obtenir mon certificat de parcours</button>' : ''}</header>
      <div class="grid">${t.modules.map(m => moduleCard(m, t.free)).join('')}</div>`;
  });

  function zonePicker() {
    const zones = S.state.config.zones;
    return `<div class="chips" role="group" aria-label="Votre région (prix)">${zones.map(z => `<button class="chip" data-zone="${z.id}" aria-pressed="${z.id === zone()}">${esc(z.label)}</button>`).join('')}</div><br>`;
  }

  /* ================= Module ================= */
  async function loadModule(id) { return api('/modules/' + encodeURIComponent(id)); }

  function videoBlock(v) {
    if (!v) return '';
    if (v.src) return `<div class="video" data-src="${esc(v.src)}"><button class="video-load" type="button"><span class="play" aria-hidden="true">▶</span><span><strong>${esc(v.title)}</strong><br><small>${esc(v.duration)} · se charge uniquement si vous appuyez</small></span></button></div>
      ${v.download ? `<p><a href="${esc(v.download)}" download>⬇ Télécharger la vidéo compressée (lecture hors connexion)</a></p>` : ''}`;
    return `<div class="video video-pending"><div class="play" aria-hidden="true">▶</div><div><strong>${esc(v.title)}</strong> <small>(${esc(v.duration)})</small><br><small>Vidéo en cours de tournage. Le déroulé ci-dessous et le résumé écrit couvrent l’essentiel.</small></div></div>
      ${v.script && v.script.length ? `<details class="script"><summary>Déroulé de la vidéo</summary><ol>${v.script.map(s => `<li>${md(s)}</li>`).join('')}</ol></details>` : ''}`;
  }

  route(/^\/module\/(\w+)$/, async id => {
    const { module: m, track: t, state: st } = await loadModule(id);
    const head = `<nav class="crumbs"><a href="#/parcours/${t.id}">${esc(t.title)}</a> › ${m.id}</nav>
      <header class="page-head"><p class="eyebrow">Module ${m.id} · ⏱ ${esc(m.duration)}${m.updatedAt ? ' · mis à jour le ' + S.date(m.updatedAt) : ''}</p><h1>${esc(m.title)}</h1><p class="lead">${esc(m.summary)}</p></header>`;
    const objectives = `<section class="objectives"><h2>Objectifs</h2><ul class="list check">${m.objectives.map(o => `<li>${esc(o)}</li>`).join('')}</ul>
      ${m.deliverable ? `<p><strong>Livrable :</strong> ${md(m.deliverable.title)}</p>` : ''}</section>`;
    if (!st.access.ok) {
      const r = st.access.reason;
      const box = r === 'paywall' ? notice('lock', '🔒 Module du parcours « ' + esc(t.title) + ' »', 'Débloquez le parcours pour accéder aux leçons, au quiz, au PDF et au certificat.', `<a class="btn primary" href="#/parcours/${t.id}">Voir l’offre</a><a class="btn" href="#/activer">J’ai un code</a>`)
        : r === 'sequence' ? notice('lock', '🔒 Progression étape par étape', `Validez d’abord le module <a href="#/module/${st.access.blocker}">${st.access.blocker}</a>.`)
        : notice('soon', '✍️ Module en cours de rédaction', 'Le programme est prêt, les leçons arrivent bientôt.');
      return head + box + objectives + `<section><h2>Programme</h2><ol class="lesson-list">${m.lessonTitles.map(l => `<li><span>${esc(l)}</span></li>`).join('')}</ol></section>`;
    }
    const done = new Set(st.lessonsDone);
    const first = m.lessons.findIndex((_, i) => !done.has(i));
    const allDone = first === -1;
    const login = !S.state.me ? notice('soon', 'Créez votre compte gratuit', 'Vous pouvez lire ce module librement. Pour enregistrer votre progression, passer le quiz et obtenir votre attestation, créez un compte (1 minute).', `<a class="btn primary" href="#/inscription?next=${encodeURIComponent('/module/' + m.id)}">Créer mon compte</a><a class="btn" href="#/connexion?next=${encodeURIComponent('/module/' + m.id)}">Se connecter</a>`) : '';
    return head + login + `<section class="video-zone"><h2>Vidéo résumé</h2>${videoBlock(m.video)}</section>${objectives}
      <section><h2>Programme</h2>${bar(st.pct)}<ol class="lesson-list">${m.lessons.map((l, i) => `<li class="${done.has(i) ? 'done' : ''}"><a href="#/module/${m.id}/lecon/${i + 1}"><span>${esc(l.title)}</span>${done.has(i) ? '<b>✓</b>' : ''}</a></li>`).join('')}
        <li class="${st.passed ? 'done' : ''}"><a href="#/module/${m.id}/quiz"><span>Quiz de validation (${m.quizCount} questions, ${S.state.config.passMark} % requis)</span>${st.passed ? '<b>✓</b>' : ''}</a></li></ol>
        <div class="actions">${st.passed ? `<button class="btn primary" data-cert="module" data-id="${m.id}">🎓 Mon attestation</button>` : `<a class="btn primary" href="#/module/${m.id}/lecon/${allDone ? 1 : first + 1}">${allDone ? 'Revoir le cours' : first > 0 ? 'Reprendre' : 'Commencer'}</a>${allDone ? `<a class="btn" href="#/module/${m.id}/quiz">Passer le quiz</a>` : ''}`}
        <a class="btn" href="/api/modules/${m.id}/pdf" download>⬇ Cours en PDF (hors connexion)</a></div></section>
      <section class="takeaways"><h2>Résumé écrit</h2><ul class="list">${m.takeaways.map(x => `<li>${md(x)}</li>`).join('')}</ul></section>`;
  });

  route(/^\/module\/(\w+)\/lecon\/(\d+)$/, async (id, n) => {
    const { module: m, state: st } = await loadModule(id);
    if (!st.access.ok) { location.hash = '#/module/' + id; return null; }
    const i = Math.min(Math.max(1, Number(n)), m.lessons.length) - 1, l = m.lessons[i], last = i === m.lessons.length - 1;
    const done = new Set(st.lessonsDone);
    return `<nav class="crumbs"><a href="#/module/${m.id}">${m.id} · ${esc(m.title)}</a> › Leçon ${i + 1}/${m.lessons.length}</nav>
      <div class="stepper">${m.lessons.map((_, k) => `<a href="#/module/${m.id}/lecon/${k + 1}" class="${k === i ? 'current' : done.has(k) ? 'done' : ''}" aria-label="Leçon ${k + 1}">${k + 1}</a>`).join('<span></span>')}<span></span><a href="#/module/${m.id}/quiz" class="${st.passed ? 'done' : ''}" aria-label="Quiz">✓</a></div>
      <article class="lesson"><p class="eyebrow">Leçon ${i + 1}</p><h1>${esc(l.title)}</h1>${l.blocks.map(S.renderBlock).join('')}</article>
      ${last ? `<section class="takeaways"><h2>À retenir du module</h2><ul class="list">${m.takeaways.map(x => `<li>${md(x)}</li>`).join('')}</ul>
        ${m.deliverable ? `<p><strong>Livrable à produire : ${md(m.deliverable.title)}</strong><br>${md(m.deliverable.x)}</p>` : ''}</section>` : ''}
      <div class="lesson-nav">${i > 0 ? `<a class="btn" href="#/module/${m.id}/lecon/${i}">← Précédent</a>` : '<span></span>'}
        <button class="btn primary" data-complete="${m.id}:${i}" data-next="${last ? `#/module/${m.id}/quiz` : `#/module/${m.id}/lecon/${i + 2}`}">${last ? 'Terminer et passer le quiz →' : 'J’ai compris, suivant →'}</button></div>`;
  });

  let quiz = null;
  route(/^\/module\/(\w+)\/quiz$/, async id => {
    const { module: m, state: st, passMark } = await loadModule(id);
    if (!st.access.ok) { location.hash = '#/module/' + id; return null; }
    const crumbs = `<nav class="crumbs"><a href="#/module/${m.id}">${m.id} · ${esc(m.title)}</a> › Quiz</nav>`;
    if (!S.state.me) return crumbs + notice('soon', 'Connectez-vous pour passer le quiz', 'Le quiz et l’attestation sont gratuits : il suffit d’un compte.', `<a class="btn primary" href="#/inscription?next=${encodeURIComponent('/module/' + m.id + '/quiz')}">Créer mon compte</a><a class="btn" href="#/connexion?next=${encodeURIComponent('/module/' + m.id + '/quiz')}">Se connecter</a>`);
    if (st.lessonsDone.length < m.lessons.length) return crumbs + notice('lock', 'Terminez d’abord les leçons', 'Le quiz se débloque une fois toutes les leçons parcourues.', `<a class="btn primary" href="#/module/${m.id}">Retour au module</a>`);
    quiz = { id: m.id, items: S.shuffle(m.quiz).map(q => ({ ...q, order: S.shuffle(q.options.map((_, k) => k)) })) };
    return crumbs + `<header class="page-head"><p class="eyebrow">Quiz de validation</p><h1>${esc(m.title)}</h1>
      <p class="lead">${m.quiz.length} questions · Score requis : <strong>${passMark} %</strong> · Tentatives illimitées${st.best != null ? ` · Meilleur score : ${st.best} %` : ''}</p></header>
      <form class="quiz" data-form="quiz">${quiz.items.map((q, k) => `<fieldset class="q" data-i="${q.i}"><legend><span>${k + 1}.</span> ${md(q.q)}</legend>
        ${q.order.map(o => `<label><input type="radio" name="q${q.i}" value="${o}" required> <span>${md(q.options[o])}</span></label>`).join('')}<p class="why" hidden></p></fieldset>`).join('')}
        <div class="actions"><button class="btn primary" type="submit">Valider mes réponses</button></div></form><div id="quiz-result" aria-live="polite"></div>`;
  });

  forms.quiz = async form => {
    const answers = {};
    quiz.items.forEach(q => { const c = form.querySelector(`input[name="q${q.i}"]:checked`); if (c) answers[q.i] = Number(c.value); });
    const r = await api(`/modules/${quiz.id}/quiz`, { method: 'POST', body: { answers } });
    r.results.forEach(x => {
      const fs = form.querySelector(`fieldset[data-i="${x.i}"]`);
      fs.classList.add(x.ok ? 'right' : 'wrong');
      fs.querySelectorAll('input').forEach(inp => { inp.disabled = true; if (Number(inp.value) === x.correct) inp.parentElement.classList.add('answer'); });
      const why = fs.querySelector('.why'); why.hidden = false;
      why.innerHTML = (x.ok ? '✅ Bonne réponse. ' : `❌ Réponse attendue : <strong>${md(x.answer)}</strong>. `) + md(x.why);
    });
    form.querySelector('button[type=submit]').remove();
    const res = document.getElementById('quiz-result');
    res.innerHTML = r.passed
      ? notice('ok', `🎉 Bravo ! ${r.score} %`, 'Module validé. Votre attestation est prête' + (r.trackComplete ? ', ainsi que votre <strong>certificat de parcours</strong> !' : '.'),
        `<button class="btn primary" data-cert="module" data-id="${quiz.id}">🎓 Obtenir mon attestation</button>${r.nextModule ? `<a class="btn" href="#/module/${r.nextModule}">Module suivant →</a>` : ''}`)
      : notice('lock', `${r.score} %, encore un effort`, `Il faut ${r.passMark} % pour valider. Relisez les explications, puis réessayez : les questions seront mélangées.`,
        `<a class="btn primary" href="#/module/${quiz.id}/quiz" data-reload>Recommencer</a><a class="btn" href="#/module/${quiz.id}/lecon/1">Revoir les leçons</a>`);
    catalog = null;
    res.scrollIntoView({ behavior: 'smooth', block: 'start' });
  };

  /* ================= Certificats ================= */
  async function claimCertificate(kind, id) {
    const me = S.state.me;
    if (!confirm(`Le certificat sera établi au nom de :\n\n${me.fullName}\n\nCe nom ne pourra plus être modifié sur ce certificat. Continuer ?\n(Annulez pour corriger votre nom dans votre profil.)`)) { location.hash = '#/profil'; return; }
    const { certificate } = await api('/certificates', { method: 'POST', body: { kind, id } });
    location.hash = '#/certificat/' + certificate.ref;
  }
  route(/^\/certificat\/([\w-]+)$/, async ref => {
    const { certificate: c } = await api('/verify/' + ref);
    return `<nav class="crumbs"><a href="#/tableau-de-bord">Mon espace</a> › Certificat</nav>
      <header class="page-head"><h1>🎓 Félicitations, ${esc(c.full_name)} !</h1><p class="lead">Téléchargez votre ${c.kind === 'module' ? 'attestation' : 'certificat'} en PDF et partagez-le sur LinkedIn et WhatsApp.</p></header>
      <div class="cert-preview"><div class="c-brand">STFC ACADEMY</div><div class="c-title">${c.kind === 'module' ? 'ATTESTATION DE RÉUSSITE' : 'CERTIFICAT PROFESSIONNEL'}</div>
        <div class="c-name">${esc(c.full_name)}</div><div class="c-what">${c.kind === 'module' ? 'a suivi et validé le module' : 'a validé l’ensemble du parcours'}</div><div class="c-mod">« ${esc(c.title)} »</div>
        <div class="c-what">${esc(c.subtitle)}${c.score != null ? ' · ' + c.score + ' %' : ''}</div><div class="c-foot"><span>Délivré le ${S.date(c.issued_at)}<br>Réf. ${esc(c.ref)}</span><span>Vérifiable sur<br>STFC Academy</span></div></div>
      <div class="actions"><a class="btn primary" href="/api/certificates/${esc(c.ref)}/pdf" download>⬇ Télécharger le PDF</a>
        <a class="btn" target="_blank" rel="noopener" href="${S.wa(`J’ai obtenu mon ${c.kind === 'module' ? 'attestation' : 'certificat'} « ${c.title} » sur STFC Academy ! Vérification : ${location.origin}/#/verifier/${c.ref}`)}">Partager sur WhatsApp</a>
        <a class="btn" target="_blank" rel="noopener" href="https://www.linkedin.com/profile/add?startTask=CERTIFICATION_NAME&name=${encodeURIComponent(c.title)}&organizationName=${encodeURIComponent('STFC Academy')}&issueYear=${new Date(c.issued_at).getFullYear()}&issueMonth=${new Date(c.issued_at).getMonth() + 1}&certId=${encodeURIComponent(c.ref)}&certUrl=${encodeURIComponent(location.origin + '/#/verifier/' + c.ref)}">Ajouter à LinkedIn</a></div>`;
  }, { auth: true });

  route(/^\/verifier(?:\/([\w-]+))?$/, async ref => {
    let result = '';
    if (ref) {
      try {
        const { certificate: c } = await api('/verify/' + ref);
        result = notice('ok', '✅ Certificat authentique', `<strong>${esc(c.full_name)}</strong> · ${c.kind === 'module' ? 'Attestation' : 'Certificat professionnel'} « ${esc(c.title)} » · ${esc(c.subtitle)}${c.score != null ? ' · score ' + c.score + ' %' : ''} · délivré le ${S.date(c.issued_at)} · réf. ${esc(c.ref)}`);
      } catch (e) { result = notice('lock', '❌ Aucun certificat ne correspond', 'Vérifiez la référence (format STFC-AAAA-XXXXXX).'); }
    }
    return `<header class="page-head"><h1>Vérifier un certificat</h1><p class="lead">Employeurs et recruteurs : saisissez la référence imprimée sur le certificat.</p></header>
      <form class="inline-form" data-form="verify"><label class="sr-only" for="ref">Référence</label><input id="ref" name="ref" required placeholder="STFC-2026-XXXXXX" value="${esc(ref || '')}" autocomplete="off"><button class="btn primary">Vérifier</button></form>${result}`;
  });
  forms.verify = form => { location.hash = '#/verifier/' + form.ref.value.trim().toUpperCase(); };

  /* ================= Comptes ================= */
  const countrySelect = (sel = '') => `<select name="country" required><option value="">Choisissez…</option>${S.state.config.zones.map(z => `<optgroup label="${esc(z.label)}">${Object.entries(z.countries).map(([k, v]) => `<option value="${k}" ${k === sel ? 'selected' : ''}>${esc(v)}</option>`).join('')}</optgroup>`).join('')}</select>`;
  const nextParam = () => S.query().get('next') || '/tableau-de-bord';

  route(/^\/inscription$/, () => `<div class="form-card"><h1>Créer mon compte</h1><p class="muted">Gratuit, sans carte bancaire. Accès immédiat aux modules découverte.</p>
    <form class="form" data-form="register"><label>Prénom et nom <input name="fullName" required minlength="3" maxlength="80" autocomplete="name"><small>Tels qu’ils apparaîtront sur vos certificats.</small></label>
      <label>E-mail <input name="email" type="email" required autocomplete="email"></label>
      <label>Téléphone (WhatsApp) <input name="phone" type="tel" autocomplete="tel" placeholder="+225 07 00 00 00 00"></label>
      <label>Pays ${countrySelect()}</label>
      <label>Mot de passe <input name="password" type="password" required minlength="8" autocomplete="new-password"><small>8 caractères minimum.</small></label>
      <div class="msg" aria-live="polite"></div><button class="btn primary">Créer mon compte</button>
      <p class="muted">Déjà inscrit ? <a href="#/connexion?next=${encodeURIComponent(nextParam())}">Se connecter</a></p></form></div>`);
  route(/^\/connexion$/, () => `<div class="form-card"><h1>Connexion</h1>
    <form class="form" data-form="login"><label>E-mail <input name="email" type="email" required autocomplete="email"></label>
      <label>Mot de passe <input name="password" type="password" required autocomplete="current-password"></label>
      <div class="msg" aria-live="polite"></div><button class="btn primary">Se connecter</button>
      <p class="muted">Pas encore de compte ? <a href="#/inscription?next=${encodeURIComponent(nextParam())}">S’inscrire gratuitement</a><br>Mot de passe oublié ? Écrivez-nous sur <a target="_blank" rel="noopener" href="${S.wa('Bonjour, j’ai oublié mon mot de passe STFC Academy.')}">WhatsApp</a>.</p></form></div>`);
  forms.register = async f => {
    await api('/auth/register', { method: 'POST', body: { fullName: f.fullName.value, email: f.email.value, phone: f.phone.value, country: f.country.value, password: f.password.value } });
    await S.refreshMe(); catalog = null; location.hash = '#' + nextParam();
  };
  forms.login = async f => {
    await api('/auth/login', { method: 'POST', body: { email: f.email.value, password: f.password.value } });
    await S.refreshMe(); catalog = null; location.hash = '#' + nextParam();
  };

  route(/^\/profil$/, () => {
    const me = S.state.me;
    return `<nav class="crumbs"><a href="#/tableau-de-bord">Mon espace</a> › Profil</nav><div class="split">
      <div class="form-card"><h1>Mon profil</h1><form class="form" data-form="profile">
        <label>Prénom et nom <input name="fullName" required minlength="3" maxlength="80" value="${esc(me.fullName)}"><small>Utilisé pour les prochains certificats. Les certificats déjà délivrés ne changent pas.</small></label>
        <label>Téléphone <input name="phone" type="tel" value="${esc(me.phone || '')}"></label><label>Pays ${countrySelect(me.country)}</label>
        <div class="msg" aria-live="polite"></div><button class="btn primary">Enregistrer</button></form></div>
      <div class="form-card"><h2>Mot de passe</h2><form class="form" data-form="password"><label>Mot de passe actuel <input name="current" type="password" required autocomplete="current-password"></label>
        <label>Nouveau mot de passe <input name="next" type="password" minlength="8" required autocomplete="new-password"></label><div class="msg" aria-live="polite"></div><button class="btn">Changer</button></form>
        <hr><button class="btn" data-logout>Se déconnecter</button></div></div>`;
  }, { auth: true });
  forms.profile = async f => { await api('/me', { method: 'PATCH', body: { fullName: f.fullName.value, phone: f.phone.value, country: f.country.value } }); await S.refreshMe(); return 'Profil enregistré.'; };
  forms.password = async f => { await api('/me/password', { method: 'POST', body: { current: f.current.value, next: f.next.value } }); f.reset(); return 'Mot de passe modifié.'; };

  /* ================= Tableau de bord ================= */
  route(/^\/tableau-de-bord$/, async () => {
    const d = await api('/dashboard');
    const active = d.tracks.filter(t => t.unlocked && (t.started || !t.free));
    const cont = d.tracks.map(t => t.next).find(n => n && n.pct > 0) || d.tracks.map(t => t.next).find(Boolean);
    const ents = d.user.entitlements.filter(e => e.scope);
    return `<header class="page-head"><p class="eyebrow">Mon espace</p><h1>Bonjour ${esc(d.user.fullName.split(' ')[0])} 👋</h1>
        <div class="tiles"><div class="tile"><b>${d.stats.lessons}</b><span>leçons terminées</span></div><div class="tile"><b>${d.stats.modulesPassed}</b><span>modules validés</span></div><div class="tile"><b>${d.stats.certificates}</b><span>certificats</span></div>
        <div class="tile"><b>${d.assessment ? d.assessment.score + ' %' : '-'}</b><span>${d.assessment ? 'auto-évaluation' : '<a href="#/auto-evaluation">faire l’auto-évaluation</a>'}</span></div></div>
        ${cont ? `<a class="btn primary" href="#/module/${cont.id}">${cont.pct ? 'Reprendre' : 'Commencer'} : ${esc(cont.id)} · ${esc(cont.title)} →</a>` : ''}</header>
      ${d.eligible.length ? `<section>${notice('ok', '🎓 Certificats à récupérer', '', d.eligible.map(e => `<button class="btn primary" data-cert="${e.kind}" data-id="${e.id}">${esc(e.title)}</button>`).join(''))}</section>` : ''}
      <section><h2>Mes parcours</h2><div class="grid">${(active.length ? active : d.tracks.filter(t => t.free)).map(t => `<a class="card dash-track" href="#/parcours/${t.id}"><div class="row"><h3>${esc(t.title)}</h3><span class="muted">${t.passed}/${t.total} modules</span></div>${bar(t.pct)}
        <span class="muted">${t.next ? 'Prochain : ' + esc(t.next.id) + ' · ' + esc(t.next.title) : t.pct === 100 ? 'Parcours terminé ✓' : ''}</span></a>`).join('')}</div>
        <p><a href="#/parcours">Découvrir les autres parcours →</a></p></section>
      <section><h2>Mes certificats</h2>${d.certificates.length ? `<ul class="cert-list">${d.certificates.map(c => `<li><a href="#/certificat/${c.ref}">🎓 ${esc(c.title)}</a><small>${c.kind === 'module' ? 'Attestation' : 'Certificat de parcours'} · ${S.date(c.issued_at)} · ${c.ref}</small></li>`).join('')}</ul>` : '<p class="muted">Validez un quiz pour obtenir votre premier certificat.</p>'}</section>
      <section><h2>Mes accès</h2>${ents.length ? `<ul class="list">${ents.map(e => `<li>${e.scope === 'all' ? 'Tous les parcours' : 'Parcours ' + esc(e.scope.replace('track:', ''))} · ${e.expires_at ? 'jusqu’au ' + S.date(e.expires_at) : 'à vie'}</li>`).join('')}</ul>` : '<p class="muted">Modules découverte uniquement.</p>'}
        <div class="actions"><a class="btn" href="#/tarifs">Voir les offres</a><a class="btn" href="#/activer">Activer un code</a><a class="btn" href="#/profil">Mon profil</a></div></section>
      ${d.attempts.length ? `<section><h2>Derniers quiz</h2><div class="scroll-x"><table><thead><tr><th>Module</th><th>Score</th><th>Résultat</th><th>Date</th></tr></thead><tbody>${d.attempts.map(a => `<tr><th scope="row">${esc(a.module_id)}</th><td>${a.score} %</td><td>${a.passed ? '✅ Validé' : '❌ À repasser'}</td><td>${S.date(a.created_at)}</td></tr>`).join('')}</tbody></table></div></section>` : ''}`;
  }, { auth: true });

  /* ================= Tarifs et achat ================= */
  route(/^\/tarifs$/, async () => {
    const c = await getCatalog();
    const p = id => c.prices.find(x => x.product === id);
    const paid = c.tracks.filter(t => !t.free);
    const plan = (title, product, items, featured) => `<div class="card plan ${featured ? 'featured' : ''}">${featured ? '<span class="ribbon">Meilleure offre</span>' : ''}<h3>${title}</h3><div>${priceLine(p(product))}</div>
      <ul class="list check">${items.map(i => `<li>${i}</li>`).join('')}</ul><a class="btn primary" href="#/acheter/${product}">Choisir</a></div>`;
    return `<header class="page-head"><p class="eyebrow">Tarifs</p><h1>Investissez dans votre carrière, à votre rythme</h1>
      <p class="lead">Prix adaptés à votre région, affichés en monnaie locale et en euros. Parcours achetés <strong>à vie</strong>, sans renouvellement caché. Paiement Mobile Money (Orange Money, Wave, MTN MoMo, Moov, M-Pesa…) ou carte bancaire, en 1 fois ou en 3 fois.</p></header>
      ${zonePicker()}
      <div class="grid pricing"><div class="card plan"><h3>Découverte</h3><p class="price free">Gratuit</p><ul class="list check"><li>4 modules complets + auto-évaluation</li><li>Quiz et attestations</li><li>Cours en PDF</li></ul><a class="btn" href="#/parcours/decouverte">Commencer</a></div>
        ${paid.map(t => plan(esc(t.title), 'track:' + t.id, [`${t.modules.length} modules progressifs`, 'Vidéos, études de cas, PDF', 'Attestations + certificat de parcours'])).join('')}
        ${plan('Pass Carrière', 'pass', ['Les 4 parcours, à vie', 'Tous les futurs modules', '4 certificats professionnels'], true)}
        ${plan('Premium mensuel', 'sub-month', ['Tout l’accès pendant 30 jours', 'Idéal pour un sprint de formation', 'Sans renouvellement automatique'])}
        ${plan('Premium annuel', 'sub-year', ['Tout l’accès pendant 12 mois', '2 mois offerts', 'Sans renouvellement automatique'])}</div>
      <section><h2>Entreprises</h2><div class="scroll-x"><table><thead><tr><th>Licences</th><th>Remise</th><th>Inclus</th></tr></thead><tbody>
        <tr><th scope="row">5 à 9</th><td>−15 %</td><td>Codes d’accès + suivi de progression</td></tr><tr><th scope="row">10 à 24</th><td>−25 %</td><td>+ Rapport mensuel RH</td></tr>
        <tr><th scope="row">25 à 49</th><td>−35 %</td><td>+ Classe virtuelle dédiée</td></tr><tr><th scope="row">50 et plus</th><td>Sur devis</td><td>+ Atelier présentiel StratFocus Consulting</td></tr></tbody></table></div>
        <a class="btn primary" target="_blank" rel="noopener" href="${S.wa('Bonjour, je souhaite un devis entreprise STFC Academy.')}">Demander un devis</a></section>
      <p class="muted">Garantie satisfait ou remboursé de 7 jours si moins de 30 % du parcours a été suivi. Le paiement en 3 fois ouvre l’accès dès la 1re échéance (accès prolongé à chaque échéance, définitif après la 3e).</p>`;
  });

  route(/^\/acheter\/([\w:-]+)$/, async product => {
    const c = await getCatalog();
    const q = c.prices.find(x => x.product === product);
    if (!q) return notice('lock', 'Offre introuvable', '', '<a class="btn" href="#/tarifs">Tarifs</a>');
    const me = S.state.me, live = S.state.config.paymentsLive;
    return `<nav class="crumbs"><a href="#/tarifs">Tarifs</a> › Paiement</nav><div class="form-card"><p class="eyebrow">Paiement sécurisé</p><h1>${esc(q.label)}</h1>
      ${zonePicker()}<div>${priceLine(q)}</div>
      <form class="form" data-form="buy" data-product="${esc(product)}">
        ${q.installments ? `<fieldset class="chips" style="border:0;padding:0"><legend class="sr-only">Formule</legend><label class="chip"><input type="radio" name="plan" value="full" checked> En 1 fois : ${money(q.display.amount, q.display.currency)}</label><label class="chip"><input type="radio" name="plan" value="x3"> En 3 fois : 3 × ${money(q.installments.display.amount, q.installments.display.currency)}</label></fieldset>` : ''}
        <label>Numéro Mobile Money (facultatif) <input name="phone" type="tel" value="${esc(me.phone || '')}" placeholder="+225 07 00 00 00 00"></label>
        <p class="hint">${q.channels === 'CREDIT_CARD' ? 'Paiement par carte bancaire (Visa, Mastercard), débité en FCFA.' : 'Vous choisirez sur la page suivante : Orange Money, Wave, MTN MoMo, Moov, M-Pesa, Airtel Money ou carte bancaire selon votre pays.'}</p>
        ${live ? '' : '<p class="success">Mode test : aucun débit réel, le paiement est simulé.</p>'}
        <div class="msg" aria-live="polite"></div><button class="btn primary">Payer maintenant</button>
        <p class="muted">Vous préférez un virement ou un dépôt ? <a target="_blank" rel="noopener" href="${S.wa(`Bonjour, je souhaite acheter « ${q.label} » par virement.`)}">Contactez-nous</a>, vous recevrez un code d’accès.</p></form></div>`;
  }, { auth: true });
  forms.buy = async f => {
    const plan = f.plan ? (f.querySelector('input[name=plan]:checked') || {}).value : 'full';
    const r = await api('/payments/init', { method: 'POST', body: { product: f.dataset.product, zone: zone(), plan, phone: f.phone.value } });
    if (r.simulation) location.hash = r.paymentUrl.split('#')[1];
    else location.href = r.paymentUrl;
  };

  route(/^\/paiement-simule\/(\w+)$/, async tx => {
    const { payment: p } = await api('/payments/' + tx);
    return `<div class="form-card"><p class="eyebrow">Simulation de paiement (mode test)</p><h1>${esc(p.label)}</h1><p class="price">${money(p.amount, p.currency)}</p>
      <p class="muted">En production, cette étape est remplacée par la page sécurisée CinetPay (Mobile Money ou carte).</p>
      <div class="actions"><button class="btn primary" data-simulate="${esc(tx)}" data-ok="1">✅ Simuler un paiement réussi</button><button class="btn" data-simulate="${esc(tx)}" data-ok="">❌ Simuler un refus</button></div></div>`;
  }, { auth: true });

  route(/^\/paiement\/(\w+)$/, async tx => {
    const { payment: p } = await api('/payments/' + tx);
    if (p.status === 'pending') setTimeout(() => { if (location.hash === '#/paiement/' + tx) { S.keepScroll = true; S.render(); } }, 4000);
    catalog = null; await S.refreshMe();
    return p.status === 'accepted' ? notice('ok', '✅ Paiement confirmé', `Merci ! « ${esc(p.label)} » est activé sur votre compte.`, '<a class="btn primary" href="#/tableau-de-bord">Commencer à apprendre</a>')
      : p.status === 'refused' ? notice('lock', 'Paiement non abouti', 'Aucun montant n’a été débité. Vous pouvez réessayer ou choisir un autre moyen de paiement.', `<a class="btn primary" href="#/acheter/${esc(p.product)}">Réessayer</a><a class="btn" target="_blank" rel="noopener" href="${S.wa('Bonjour, mon paiement ' + tx + ' n’a pas abouti.')}">Aide WhatsApp</a>`)
      : notice('soon', '⏳ Paiement en cours de confirmation', 'Validez l’opération sur votre téléphone si ce n’est pas fait. Cette page se met à jour automatiquement.', `<span class="muted">Référence ${esc(tx)}</span>`);
  }, { auth: true });

  route(/^\/activer$/, () => `<div class="form-card"><h1>Activer un code d’accès</h1><p class="muted">Code reçu après un virement, un achat entreprise ou une offre partenaire (ex. COM-ABCD-EFGH).</p>
    <form class="form" data-form="redeem"><label>Code <input name="code" required autocomplete="off" autocapitalize="characters" spellcheck="false" placeholder="XXX-XXXX-XXXX"></label><div class="msg" aria-live="polite"></div><button class="btn primary">Activer</button></form></div>`, { auth: true });
  forms.redeem = async f => {
    const r = await api('/codes/redeem', { method: 'POST', body: { code: f.code.value } });
    catalog = null; await S.refreshMe();
    location.hash = r.scope === 'all' ? '#/parcours' : '#/parcours/' + r.scope.replace('track:', '');
  };

  /* ================= Auto-évaluation ================= */
  let evalQ = null;
  route(/^\/auto-evaluation$/, async () => {
    evalQ = await api('/autoeval');
    return `<header class="page-head"><p class="eyebrow">Gratuit · 3 minutes</p><h1>${esc(evalQ.title)}</h1><p class="lead">${esc(evalQ.intro)}</p></header>
      <form class="quiz" data-form="autoeval">${evalQ.questions.map((q, i) => `<fieldset><legend><span>${i + 1}.</span> ${esc(q.q)} <small class="muted">(${esc(q.dim)})</small></legend>${q.options.map((o, k) => `<label><input type="radio" name="a${i}" value="${k}" required> <span>${esc(o)}</span></label>`).join('')}</fieldset>`).join('')}
        <div class="actions"><button class="btn primary">Voir mon résultat</button></div></form><div id="eval-result" aria-live="polite"></div>`;
  });
  forms.autoeval = async f => {
    const answers = {}; evalQ.questions.forEach((_, i) => { answers[i] = Number(f.querySelector(`input[name=a${i}]:checked`).value); });
    const r = await api('/autoeval', { method: 'POST', body: { answers } });
    const out = document.getElementById('eval-result');
    out.innerHTML = `<div class="result-reco"><p class="eyebrow">Votre résultat : ${r.score} %</p><h2>Parcours recommandé : ${esc(r.title)}</h2><p>${esc(r.why)}</p>
      ${r.strengths.length ? `<p><strong>Points forts :</strong> ${r.strengths.map(esc).join(', ')}</p>` : ''}${r.gaps.length ? `<p><strong>À travailler :</strong> ${r.gaps.map(esc).join(', ')}</p>` : ''}
      <div class="actions"><a class="btn primary" href="#/parcours/${r.track}">Voir le parcours</a><a class="btn" href="#/module/F1">Commencer gratuitement</a></div></div>`;
    out.scrollIntoView({ behavior: 'smooth' });
  };

  /* ================= Événements globaux ================= */
  document.addEventListener('submit', async e => {
    const f = e.target.closest('form[data-form]'); if (!f || !forms[f.dataset.form]) return;
    e.preventDefault();
    const btn = f.querySelector('button[type=submit], button:not([type])'), msg = f.querySelector('.msg');
    if (btn) btn.disabled = true; if (msg) msg.innerHTML = '';
    try { const ok = await forms[f.dataset.form](f); if (ok && msg) msg.innerHTML = `<p class="success">${esc(ok)}</p>`; }
    catch (err) { if (msg) msg.innerHTML = `<p class="error">${esc(err.message)}</p>`; else alert(err.message); }
    finally { if (btn && document.body.contains(btn)) btn.disabled = false; }
  });

  document.addEventListener('click', async e => {
    const t = e.target;
    const done = t.closest('[data-complete]');
    if (done) {
      const [id, i] = done.dataset.complete.split(':');
      if (S.state.me) { done.disabled = true; try { await api(`/modules/${id}/lessons/${i}/complete`, { method: 'POST', body: {} }); } catch (err) { done.disabled = false; return alert(err.message); } }
      location.hash = done.dataset.next; return;
    }
    const z = t.closest('[data-zone]');
    if (z) { S.store.set('zone', z.dataset.zone); S.keepScroll = true; S.render(); return; }
    const cert = t.closest('[data-cert]');
    if (cert) { try { await claimCertificate(cert.dataset.cert, cert.dataset.id); } catch (err) { alert(err.message); } return; }
    const sim = t.closest('[data-simulate]');
    if (sim) { await api(`/payments/${sim.dataset.simulate}/simulate`, { method: 'POST', body: { accepted: !!sim.dataset.ok } }); location.hash = '#/paiement/' + sim.dataset.simulate; return; }
    if (t.closest('[data-logout]')) { await api('/auth/logout', { method: 'POST', body: {} }); S.state.me = null; S.updateNav(); catalog = null; location.hash = '#/'; return; }
    const reload = t.closest('[data-reload]');
    if (reload && reload.getAttribute('href') === location.hash) { e.preventDefault(); S.render(); return; }
    const vid = t.closest('.video-load');
    if (vid) { const w = vid.parentElement; w.innerHTML = `<iframe src="${esc(w.dataset.src)}" title="Vidéo résumé" allow="autoplay; encrypted-media; picture-in-picture" allowfullscreen></iframe>`; }
  });

  /* ================= Démarrage ================= */
  window.addEventListener('hashchange', S.render);
  window.addEventListener('offline', () => { const b = document.createElement('div'); b.className = 'offline-banner'; b.id = 'offline'; b.textContent = 'Hors connexion : contenus déjà consultés disponibles'; document.body.appendChild(b); });
  window.addEventListener('online', () => { const b = document.getElementById('offline'); if (b) b.remove(); });
  (async () => {
    try { S.state.config = await api('/config'); await S.refreshMe(); }
    catch (e) { document.getElementById('app').innerHTML = notice('lock', 'Connexion impossible', 'Vérifiez votre réseau puis rechargez la page.'); return; }
    S.render();
  })();
  if ('serviceWorker' in navigator && (location.protocol === 'https:' || location.hostname === 'localhost')) navigator.serviceWorker.register('/sw.js').catch(() => {});
})();
