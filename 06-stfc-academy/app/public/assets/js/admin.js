/* STFC Academy : back-office (administrateurs et formateurs). */
(function () {
  'use strict';
  const S = window.STFC, { esc, api, money, route, notice } = S;
  const forms = S.forms;
  const isAdmin = () => S.state.me && S.state.me.role === 'admin';
  const tabs = cur => `<nav class="tabs" aria-label="Administration">${[['', 'Tableau de bord', 0], ['contenus', 'Contenus', 0], ['utilisateurs', 'Utilisateurs', 1], ['paiements', 'Paiements', 1], ['codes', 'Codes d’accès', 1], ['certificats', 'Certificats', 1]]
    .filter(t => !t[2] || isAdmin()).map(([p, l]) => `<a href="#/admin${p ? '/' + p : ''}" class="${p === cur ? 'on' : ''}">${l}</a>`).join('')}</nav>`;
  const pct = v => v == null ? '–' : v + ' %';
  const scopeLabel = s => s === 'all' ? 'Tout l’accès' : (S.state.config && s) ? 'Parcours ' + s.replace('track:', '') : s;
  const SCOPES = [['all', 'Tout l’accès (Pass)'], ['track:commercial', 'Parcours Commercial'], ['track:chef-equipe', 'Parcours Chef d’équipe'], ['track:responsable', 'Parcours Responsable'], ['track:directeur', 'Parcours Directeur']];
  const scopeSelect = `<select name="scope" required>${SCOPES.map(([v, l]) => `<option value="${v}">${l}</option>`).join('')}</select>`;
  const pill = s => `<span class="pill ${esc(s)}">${esc({ accepted: 'payé', pending: 'en attente', refused: 'refusé', complet: 'complet', bientot: 'en rédaction' }[s] || s)}</span>`;

  /* ---------- Tableau de bord ---------- */
  route(/^\/admin$/, async () => {
    const s = await api('/admin/stats');
    const tile = (v, l) => `<div class="tile"><b>${v}</b><span>${l}</span></div>`;
    return `<h1>Administration</h1>${tabs('')}
      <h2>Audience</h2><div class="tiles">${tile(s.users.learners, 'apprenants')}${tile(s.users.new7, 'nouveaux (7 j)')}${tile(s.users.new30, 'nouveaux (30 j)')}${tile(s.users.active7, 'actifs (7 j)')}${tile(s.users.active30, 'actifs (30 j)')}</div>
      <h2>Indicateurs clés</h2><div class="tiles">${tile(pct(s.kpi.completionRate), 'complétion des modules')}${tile(pct(s.kpi.quizPassRate), 'réussite aux quiz')}${tile(pct(s.kpi.firstTryPassRate), 'réussite du 1er coup')}
        ${tile(pct(s.kpi.conversion), 'conversion gratuit → payant')}${tile(pct(s.kpi.retention30), 'rétention à 30 jours')}${tile(s.kpi.certificates, 'certificats délivrés')}</div>
      ${s.revenue ? `<h2>Chiffre d’affaires</h2><div class="tiles">${tile(money(s.revenue.totalXof, 'XOF'), 'total encaissé')}${tile(money(s.revenue.last30Xof, 'XOF'), '30 derniers jours')}${tile(s.kpi.payingLearners, 'apprenants payants')}${tile(s.revenue.pending, 'paiements en attente')}</div>
        <div class="split"><div class="scroll-x"><table><thead><tr><th>Mois</th><th>Ventes</th><th>Montant</th></tr></thead><tbody>${s.revenue.byMonth.map(r => `<tr><th scope="row">${esc(r.month)}</th><td>${r.n}</td><td>${money(r.xof, 'XOF')}</td></tr>`).join('') || '<tr><td colspan="3">Aucune vente</td></tr>'}</tbody></table></div>
        <div class="scroll-x"><table><thead><tr><th>Offre</th><th>Ventes</th><th>Montant</th></tr></thead><tbody>${s.revenue.byProduct.map(r => `<tr><th scope="row">${esc(r.label)}</th><td>${r.n}</td><td>${money(r.xof, 'XOF')}</td></tr>`).join('') || '<tr><td colspan="3">Aucune vente</td></tr>'}</tbody></table></div></div>` : ''}
      <h2>Modules</h2><div class="scroll-x admin"><table><thead><tr><th>Module</th><th>Parcours</th><th>Démarré</th><th>Validé</th><th>Complétion</th><th>Tentatives</th><th>Score moyen</th></tr></thead>
        <tbody>${s.modules.map(m => `<tr><th scope="row">${esc(m.id)} · ${esc(m.title)}</th><td>${esc(m.track)}</td><td>${m.started}</td><td>${m.passed}</td><td>${pct(m.completion)}</td><td>${m.attempts}</td><td>${pct(m.avgScore)}</td></tr>`).join('')}</tbody></table></div>
      <div class="split"><div><h2>Pays</h2><div class="scroll-x"><table><thead><tr><th>Pays</th><th>Apprenants</th></tr></thead><tbody>${s.countries.map(c => `<tr><th scope="row">${esc(c.country)}</th><td>${c.n}</td></tr>`).join('') || '<tr><td colspan="2">–</td></tr>'}</tbody></table></div></div>
        <div><h2>Auto-évaluations</h2><div class="scroll-x"><table><thead><tr><th>Parcours recommandé</th><th>Nombre</th></tr></thead><tbody>${s.assessments.map(a => `<tr><th scope="row">${esc(a.level)}</th><td>${a.n}</td></tr>`).join('') || '<tr><td colspan="2">–</td></tr>'}</tbody></table></div></div></div>`;
  }, { auth: 'staff' });

  /* ---------- Contenus ---------- */
  route(/^\/admin\/contenus$/, async () => {
    const { tracks } = await api('/admin/modules');
    return `<h1>Contenus</h1>${tabs('contenus')}<p class="muted">Modifiez les textes, vidéos, leçons et quiz. Les changements sont visibles immédiatement par les apprenants.</p>
      ${tracks.map(t => `<h2>${esc(t.title)}</h2><div class="scroll-x admin"><table><thead><tr><th>Module</th><th>Statut</th><th>Leçons</th><th>Quiz</th><th>Mis à jour</th><th></th></tr></thead><tbody>
        ${t.modules.map(m => `<tr><th scope="row">${esc(m.id)} · ${esc(m.title)}</th><td>${pill(m.status)}</td><td>${m.lessons}</td><td>${m.quiz}</td><td>${S.date(m.updatedAt)}</td><td><a href="#/admin/contenus/${m.id}">Modifier</a> · <a href="#/module/${m.id}">Voir</a></td></tr>`).join('')}</tbody></table></div>`).join('')}`;
  }, { auth: 'staff' });

  let editing = null;
  route(/^\/admin\/contenus\/(\w+)$/, async id => {
    const { module: m } = await api('/admin/modules/' + id);
    editing = m;
    const v = m.video || {};
    return `<nav class="crumbs"><a href="#/admin/contenus">Contenus</a> › ${esc(m.id)}</nav><h1>Modifier ${esc(m.id)}</h1>
      <form class="form" style="max-width:none" data-form="module" data-id="${esc(m.id)}">
        <div class="split"><label>Titre <input name="title" required value="${esc(m.title)}"></label>
          <label>Statut <select name="status"><option value="complet" ${m.status !== 'bientot' ? 'selected' : ''}>Complet (visible, quiz actif)</option><option value="bientot" ${m.status === 'bientot' ? 'selected' : ''}>En rédaction</option></select></label></div>
        <div class="split"><label>Durée <input name="duration" value="${esc(m.duration || '')}"></label><label>Résumé <input name="summary" value="${esc(m.summary || '')}"></label></div>
        <div class="split"><label>Vidéo : URL d’intégration <input name="videoSrc" value="${esc(v.src || '')}" placeholder="https://www.youtube-nocookie.com/embed/…"><small>YouTube nocookie, Vimeo, Bunny Stream ou Cloudflare Stream.</small></label>
          <label>Vidéo compressée à télécharger (MP4 240p) <input name="videoDownload" value="${esc(v.download || '')}" placeholder="https://…/video-240p.mp4"></label></div>
        <div class="split"><label>Objectifs (un par ligne) <textarea name="objectives" class="field">${esc((m.objectives || []).join('\n'))}</textarea></label>
          <label>Compétences certifiées (une par ligne) <textarea name="skills" class="field">${esc((m.skills || []).join('\n'))}</textarea></label></div>
        <div class="split"><label>À retenir (un par ligne) <textarea name="takeaways" class="field">${esc((m.takeaways || []).join('\n'))}</textarea></label>
          <label>Livrable : titre et consigne (1re ligne = titre) <textarea name="deliverable" class="field">${esc(m.deliverable ? m.deliverable.title + '\n' + m.deliverable.x : '')}</textarea></label></div>
        <label>Déroulé de la vidéo (une étape par ligne) <textarea name="script" class="field">${esc((v.script || []).join('\n'))}</textarea></label>
        <label>Leçons (JSON) <textarea name="lessons" class="field" style="min-height:360px">${esc(JSON.stringify(m.lessons || [], null, 2))}</textarea>
          <small>Types de blocs : p, h, list, steps, table, matrix, flow, funnel, case, tip, action (voir README).</small></label>
        <label>Quiz (JSON) <textarea name="quiz" class="field" style="min-height:260px">${esc(JSON.stringify(m.quiz || [], null, 2))}</textarea><small>« a » = index (à partir de 0) de la bonne réponse ; « why » = explication affichée après correction.</small></label>
        <div class="msg" aria-live="polite"></div><div class="actions"><button class="btn primary">Enregistrer</button><a class="btn" href="#/module/${esc(m.id)}">Voir le module</a></div></form>`;
  }, { auth: 'staff' });
  const lines = s => s.split('\n').map(x => x.trim()).filter(Boolean);
  forms.module = async f => {
    let lessons, quiz;
    try { lessons = JSON.parse(f.lessons.value); } catch (e) { throw new Error('Leçons : JSON invalide (' + e.message + ').'); }
    try { quiz = JSON.parse(f.quiz.value); } catch (e) { throw new Error('Quiz : JSON invalide (' + e.message + ').'); }
    const [dTitle, ...dRest] = f.deliverable.value.split('\n');
    const body = { ...editing, title: f.title.value.trim(), status: f.status.value, duration: f.duration.value.trim(), summary: f.summary.value.trim(),
      objectives: lines(f.objectives.value), skills: lines(f.skills.value), takeaways: lines(f.takeaways.value),
      deliverable: dTitle && dTitle.trim() ? { title: dTitle.trim(), x: dRest.join('\n').trim() } : null,
      video: { ...(editing.video || {}), src: f.videoSrc.value.trim() || null, download: f.videoDownload.value.trim() || null, script: lines(f.script.value) },
      lessons, quiz };
    const r = await api('/admin/modules/' + f.dataset.id, { method: 'PUT', body: { module: body } });
    editing = r.module;
    return 'Module enregistré.';
  };

  /* ---------- Utilisateurs ---------- */
  route(/^\/admin\/utilisateurs$/, async () => {
    const q = S.query().get('q') || '';
    const { users } = await api('/admin/users?q=' + encodeURIComponent(q));
    return `<h1>Utilisateurs</h1>${tabs('utilisateurs')}<form class="inline-form" data-form="usersearch"><input name="q" value="${esc(q)}" placeholder="Nom, e-mail ou téléphone" aria-label="Rechercher"><button class="btn">Rechercher</button></form>
      <div class="scroll-x admin"><table><thead><tr><th>Nom</th><th>E-mail</th><th>Pays</th><th>Rôle</th><th>Accès</th><th>Modules validés</th><th>Inscrit le</th><th>Vu le</th></tr></thead><tbody>
      ${users.map(u => `<tr><th scope="row"><a href="#/admin/utilisateurs/${u.id}">${esc(u.full_name)}</a>${u.disabled ? ' <span class="pill refused">désactivé</span>' : ''}</th><td>${esc(u.email)}</td><td>${esc(u.country || '')}</td><td>${esc(u.role)}</td>
        <td>${u.scopes ? esc(u.scopes.split(',').map(scopeLabel).join(', ')) : '–'}</td><td>${u.modules_passed}</td><td>${S.date(u.created_at)}</td><td>${S.date(u.last_seen_at)}</td></tr>`).join('') || '<tr><td colspan="8">Aucun résultat</td></tr>'}</tbody></table></div>`;
  }, { auth: 'admin' });
  forms.usersearch = f => { location.hash = '#/admin/utilisateurs?q=' + encodeURIComponent(f.q.value); };

  route(/^\/admin\/utilisateurs\/(\d+)$/, async id => {
    const d = await api('/admin/users/' + id), u = d.user;
    return `<nav class="crumbs"><a href="#/admin/utilisateurs">Utilisateurs</a> › ${esc(u.full_name)}</nav><h1>${esc(u.full_name)}</h1>
      <p class="muted">${esc(u.email)} · ${esc(u.phone || 'pas de téléphone')} · ${esc(u.country || '?')} · inscrit le ${S.date(u.created_at)}</p>
      <div class="split"><form class="form form-card" data-form="userrole" data-id="${u.id}"><h2>Rôle et statut</h2>
          <label>Rôle <select name="role">${['learner', 'trainer', 'admin'].map(r => `<option value="${r}" ${r === u.role ? 'selected' : ''}>${{ learner: 'Apprenant', trainer: 'Formateur', admin: 'Administrateur' }[r]}</option>`).join('')}</select></label>
          <label><span><input type="checkbox" name="disabled" ${u.disabled ? 'checked' : ''}> Compte désactivé</span></label><div class="msg"></div><button class="btn primary">Enregistrer</button></form>
        <form class="form form-card" data-form="grant" data-id="${u.id}"><h2>Offrir un accès</h2><label>Accès ${scopeSelect}</label>
          <label>Durée en jours <input name="days" type="number" min="1" placeholder="Vide = à vie"></label><div class="msg"></div><button class="btn primary">Accorder</button></form></div>
      <h2>Accès</h2><div class="scroll-x admin"><table><thead><tr><th>Accès</th><th>Origine</th><th>Réf.</th><th>Début</th><th>Fin</th><th></th></tr></thead><tbody>
        ${d.entitlements.map(e => `<tr><th scope="row">${esc(scopeLabel(e.scope))}</th><td>${esc(e.source)}</td><td>${esc(e.ref || '')}</td><td>${S.date(e.starts_at)}</td><td>${e.expires_at ? S.date(e.expires_at) : 'à vie'}</td><td><button class="btn" data-revoke="${e.id}">Retirer</button></td></tr>`).join('') || '<tr><td colspan="6">Aucun</td></tr>'}</tbody></table></div>
      <h2>Paiements</h2><div class="scroll-x admin"><table><thead><tr><th>Transaction</th><th>Offre</th><th>Montant</th><th>Statut</th><th>Date</th></tr></thead><tbody>
        ${d.payments.map(p => `<tr><th scope="row">${esc(p.transaction_id)}</th><td>${esc(p.product)}${p.plan === 'x3' ? ' (3×)' : ''}</td><td>${money(p.amount, p.currency)}</td><td>${pill(p.status)}</td><td>${S.date(p.created_at)}</td></tr>`).join('') || '<tr><td colspan="5">Aucun</td></tr>'}</tbody></table></div>
      <h2>Certificats et quiz</h2><ul class="list">${d.certificates.map(c => `<li>${esc(c.ref)} · ${esc(c.title)} · ${S.date(c.issued_at)}</li>`).join('') || '<li>Aucun certificat</li>'}</ul>
      <ul class="list">${d.attempts.map(a => `<li>${esc(a.module_id)} : ${a.score} % ${a.passed ? '✅' : '❌'} · ${S.date(a.created_at)}</li>`).join('') || '<li>Aucun quiz</li>'}</ul>`;
  }, { auth: 'admin' });
  forms.userrole = async f => { await api('/admin/users/' + f.dataset.id, { method: 'PATCH', body: { role: f.role.value, disabled: f.disabled.checked } }); return 'Enregistré.'; };
  forms.grant = async f => { await api(`/admin/users/${f.dataset.id}/grant`, { method: 'POST', body: { scope: f.scope.value, days: f.days.value ? Number(f.days.value) : null } }); S.keepScroll = true; S.render(); };

  /* ---------- Paiements ---------- */
  route(/^\/admin\/paiements$/, async () => {
    const st = S.query().get('statut') || '';
    const { payments, live } = await api('/admin/payments' + (st ? '?status=' + st : ''));
    return `<h1>Paiements</h1>${tabs('paiements')}<p class="muted">Passerelle : ${live ? '<strong>CinetPay (réel)</strong>' : '<strong>simulation</strong> (renseignez CINETPAY_API_KEY et CINETPAY_SITE_ID)'}</p>
      <div class="chips">${[['', 'Tous'], ['accepted', 'Payés'], ['pending', 'En attente'], ['refused', 'Refusés']].map(([v, l]) => `<a class="chip ${v === st ? 'on' : ''}" href="#/admin/paiements${v ? '?statut=' + v : ''}">${l}</a>`).join('')}</div><br>
      <div class="scroll-x admin"><table><thead><tr><th>Transaction</th><th>Apprenant</th><th>Offre</th><th>Montant</th><th>Zone</th><th>Moyen</th><th>Statut</th><th>Date</th><th></th></tr></thead><tbody>
      ${payments.map(p => `<tr><th scope="row">${esc(p.transaction_id)}</th><td>${esc(p.full_name)}<br><small>${esc(p.email)}</small></td><td>${esc(p.label)}${p.plan === 'x3' ? ' (3×)' : ''}</td><td>${money(p.amount, p.currency)}</td><td>${esc(p.zone)}</td><td>${esc(p.method || p.provider)}</td><td>${pill(p.status)}</td><td>${S.date(p.created_at)}</td>
        <td>${p.status === 'pending' && p.provider === 'cinetpay' ? `<button class="btn" data-recheck="${esc(p.transaction_id)}">Revérifier</button>` : ''}</td></tr>`).join('') || '<tr><td colspan="9">Aucun paiement</td></tr>'}</tbody></table></div>`;
  }, { auth: 'admin' });

  /* ---------- Codes d'accès ---------- */
  route(/^\/admin\/codes$/, async () => {
    const { codes } = await api('/admin/codes');
    return `<h1>Codes d’accès</h1>${tabs('codes')}<p class="muted">Pour les ventes par virement, les licences entreprises et les partenaires. Les codes ne sont affichés qu’une seule fois : copiez-les avant de quitter la page.</p>
      <form class="form form-card" data-form="codes" style="max-width:none"><div class="split"><label>Accès ${scopeSelect}</label><label>Nombre de codes <input name="count" type="number" min="1" max="500" value="5"></label></div>
        <div class="split"><label>Durée en jours <input name="days" type="number" min="1" placeholder="Vide = à vie"></label><label>Utilisations par code <input name="maxUses" type="number" min="1" value="1"></label></div>
        <label>Libellé (client, entreprise, campagne) <input name="label" maxlength="80" placeholder="Ex. Banque XYZ - équipe Abidjan"></label><div class="msg"></div><button class="btn primary">Générer</button></form><div id="codes-out"></div>
      <h2>Historique</h2><div class="scroll-x admin"><table><thead><tr><th>Empreinte</th><th>Accès</th><th>Libellé</th><th>Utilisations</th><th>Durée</th><th>Créé le</th></tr></thead><tbody>
      ${codes.map(c => `<tr><th scope="row">${esc(c.id)}…</th><td>${esc(scopeLabel(c.scope))}</td><td>${esc(c.label || '')}</td><td>${c.uses}/${c.max_uses}</td><td>${c.days ? c.days + ' j' : 'à vie'}</td><td>${S.date(c.created_at)}</td></tr>`).join('') || '<tr><td colspan="6">Aucun code</td></tr>'}</tbody></table></div>`;
  }, { auth: 'admin' });
  forms.codes = async f => {
    const r = await api('/admin/codes', { method: 'POST', body: { scope: f.scope.value, count: Number(f.count.value), days: f.days.value ? Number(f.days.value) : null, maxUses: Number(f.maxUses.value), label: f.label.value } });
    document.getElementById('codes-out').innerHTML = `<h2>${r.codes.length} code(s) générés</h2><div class="codes-out">${r.codes.map(esc).join('\n')}</div>`;
    return 'Codes générés : copiez-les maintenant.';
  };

  /* ---------- Certificats ---------- */
  route(/^\/admin\/certificats$/, async () => {
    const { certificates } = await api('/admin/certificates');
    return `<h1>Certificats délivrés</h1>${tabs('certificats')}<div class="scroll-x admin"><table><thead><tr><th>Référence</th><th>Titulaire</th><th>Intitulé</th><th>Type</th><th>Score</th><th>Date</th><th></th></tr></thead><tbody>
      ${certificates.map(c => `<tr><th scope="row">${esc(c.ref)}</th><td>${esc(c.full_name)}<br><small>${esc(c.email)}</small></td><td>${esc(c.title)}</td><td>${c.kind === 'module' ? 'Attestation' : 'Certificat'}</td><td>${c.score != null ? c.score + ' %' : '–'}</td><td>${S.date(c.issued_at)}</td><td><a href="/api/certificates/${esc(c.ref)}/pdf">PDF</a></td></tr>`).join('') || '<tr><td colspan="7">Aucun certificat</td></tr>'}</tbody></table></div>`;
  }, { auth: 'admin' });

  document.addEventListener('click', async e => {
    const rv = e.target.closest('[data-revoke]');
    if (rv && confirm('Retirer cet accès ?')) { await api('/admin/entitlements/' + rv.dataset.revoke, { method: 'DELETE', body: {} }); S.keepScroll = true; S.render(); }
    const rc = e.target.closest('[data-recheck]');
    if (rc) { const r = await api(`/admin/payments/${rc.dataset.recheck}/recheck`, { method: 'POST', body: {} }); alert('Statut : ' + (r.status || 'inconnu')); S.render(); }
  });
})();
