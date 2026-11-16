/* STFC Academy : utilitaires partagés (API, rendu, routeur). */
(function () {
  'use strict';
  const S = window.STFC = { routes: [], state: { me: null, config: null } };

  S.esc = s => String(s == null ? '' : s).replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
  S.md = s => S.esc(s).replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>');
  S.money = (n, cur) => {
    const v = Number(n || 0).toLocaleString('fr-FR').replace(/ | /g, ' ');
    return cur === 'XOF' || cur === 'XAF' ? v + ' FCFA' : cur === 'EUR' ? v + ' €' : cur === 'USD' ? v + ' $' : v + ' ' + cur;
  };
  S.date = iso => iso ? new Date(iso).toLocaleDateString('fr-FR', { day: 'numeric', month: 'long', year: 'numeric' }) : '';
  S.shuffle = arr => { const a = arr.slice(); for (let i = a.length - 1; i > 0; i--) { const j = Math.floor(Math.random() * (i + 1)); [a[i], a[j]] = [a[j], a[i]]; } return a; };
  S.wa = text => `https://wa.me/${(S.state.config && S.state.config.contact.whatsapp) || ''}?text=${encodeURIComponent(text)}`;
  S.store = {
    get: k => { try { return localStorage.getItem('stfc:' + k); } catch (e) { return null; } },
    set: (k, v) => { try { localStorage.setItem('stfc:' + k, v); } catch (e) { /* stockage indisponible */ } }
  };

  // Appel API JSON. Lève une Error avec .status et le message du serveur.
  S.api = async (path, opts = {}) => {
    const init = { method: opts.method || 'GET', credentials: 'same-origin', headers: {} };
    if (opts.body !== undefined) { init.headers['Content-Type'] = 'application/json'; init.body = JSON.stringify(opts.body); }
    let res;
    try { res = await fetch('/api' + path, init); }
    catch (e) { throw Object.assign(new Error('Connexion impossible. Vérifiez votre réseau.'), { status: 0 }); }
    const data = await res.json().catch(() => ({}));
    if (!res.ok) throw Object.assign(new Error(data.error || 'Erreur ' + res.status), { status: res.status, data });
    return data;
  };

  S.bar = pct => `<div class="bar" role="progressbar" aria-valuenow="${pct}" aria-valuemin="0" aria-valuemax="100"><span style="width:${pct}%"></span></div>`;
  S.notice = (kind, title, body = '', actions = '') => `<div class="notice ${kind}"><h2>${title}</h2>${body ? `<p>${body}</p>` : ''}${actions ? `<div class="actions">${actions}</div>` : ''}</div>`;

  /* ---------- Rendu des blocs de leçon ---------- */
  S.renderBlock = b => {
    const md = S.md, cap = c => c ? `<figcaption>${md(c)}</figcaption>` : '';
    switch (b.t) {
      case 'p': return `<p>${md(b.x)}</p>`;
      case 'h': return `<h3>${md(b.x)}</h3>`;
      case 'list': return `<ul class="list">${b.items.map(i => `<li>${md(i)}</li>`).join('')}</ul>`;
      case 'steps': return `<ol class="steps">${b.items.map(s => `<li><strong>${md(s.title)}</strong><span>${md(s.x)}</span></li>`).join('')}</ol>`;
      case 'table': return `<figure class="table-wrap">${cap(b.caption)}<div class="scroll-x"><table><thead><tr>${b.head.map(h => `<th scope="col">${md(h)}</th>`).join('')}</tr></thead>
        <tbody>${b.rows.map(r => `<tr>${r.map((c, i) => i === 0 ? `<th scope="row">${md(c)}</th>` : `<td>${md(c)}</td>`).join('')}</tr>`).join('')}</tbody></table></div></figure>`;
      case 'matrix': return `<figure class="matrix">${cap(b.caption)}<div class="matrix-body"><div class="axis-y">${md(b.y)}</div>
        <div class="matrix-grid">${b.q.map((q, i) => `<div class="quad q${i}"><strong>${md(q.title)}</strong><span>${md(q.x)}</span></div>`).join('')}</div></div><div class="axis-x">${md(b.x)}</div></figure>`;
      case 'flow': return `<figure class="flow">${cap(b.caption)}<ol>${b.items.map(i => `<li>${md(i)}</li>`).join('')}</ol></figure>`;
      case 'funnel': {
        const max = Math.max(...b.items.map(i => i.value));
        return `<figure class="funnel">${cap(b.caption)}${b.items.map((i, k) => `<div class="funnel-row"><div class="funnel-bar" style="width:${Math.max(28, i.value / max * 100)}%"><b>${S.esc(i.value)}</b></div><span>${md(i.label)}${k ? ` <small>(${Math.round(i.value / b.items[k - 1].value * 100)} %)</small>` : ''}</span></div>`).join('')}</figure>`;
      }
      case 'case': return `<section class="case"><div class="case-tag">Étude de cas</div><h3>${md(b.title.replace(/^Étude de cas\s*:\s*/, ''))}</h3><p>${md(b.context)}</p>
        <p class="case-q"><strong>Questions</strong></p><ol>${b.questions.map(q => `<li>${md(q)}</li>`).join('')}</ol>
        <details><summary>Réfléchissez, puis affichez le corrigé</summary><div class="case-sol">${md(b.solution)}</div></details></section>`;
      case 'tip': return `<aside class="callout tip"><strong>À retenir</strong><p>${md(b.x)}</p></aside>`;
      case 'action': return `<aside class="callout action"><strong>Et vous ?</strong><p>${md(b.x)}</p></aside>`;
      default: return '';
    }
  };

  /* ---------- Routeur ---------- */
  // S.route(/^regex$/, handler(params...) => html | Promise<html>, { auth: true | 'staff' | 'admin' })
  S.route = (re, fn, opts = {}) => S.routes.push({ re, fn, opts });
  const app = () => document.getElementById('app');
  let seq = 0;
  S.render = async () => {
    const hash = location.hash.replace(/^#/, '') || '/';
    const [path] = hash.split('?');
    const id = ++seq;
    const r = S.routes.find(x => x.re.test(path));
    let html;
    try {
      if (!r) html = S.notice('lock', 'Page introuvable', '', '<a class="btn primary" href="#/">Accueil</a>');
      else if (r.opts.auth && !S.state.me) { location.hash = '#/connexion?next=' + encodeURIComponent(hash); return; }
      else if (r.opts.auth === 'staff' && !['admin', 'trainer'].includes(S.state.me.role)) html = S.notice('lock', 'Accès réservé', 'Cette page est réservée à l’équipe pédagogique.');
      else if (r.opts.auth === 'admin' && S.state.me.role !== 'admin') html = S.notice('lock', 'Accès réservé', 'Cette page est réservée aux administrateurs.');
      else {
        app().setAttribute('aria-busy', 'true');
        html = await r.fn(...path.match(r.re).slice(1).map(decodeURIComponent));
      }
    } catch (e) {
      html = e.status === 0 ? S.notice('lock', 'Vous êtes hors connexion', 'Cette page n’est pas encore disponible hors ligne. Les modules déjà ouverts et les PDF téléchargés restent consultables.')
        : S.notice('lock', 'Oups', S.esc(e.message), '<a class="btn" href="#/">Accueil</a>');
    }
    if (id !== seq || html == null) return; // une navigation plus récente a eu lieu
    app().innerHTML = html; app().removeAttribute('aria-busy');
    const h1 = app().querySelector('h1'); document.title = (h1 ? h1.textContent.trim() + ' · ' : '') + 'STFC Academy';
    document.querySelectorAll('.nav a').forEach(a => a.classList.toggle('active', a.getAttribute('href') !== '#/' && location.hash.startsWith(a.getAttribute('href'))));
    if (!S.keepScroll) window.scrollTo(0, 0);
    S.keepScroll = false;
    (S.after || []).splice(0).forEach(fn => fn());
  };
  S.after = [];
  S.onRender = fn => S.after.push(fn);
  S.query = () => new URLSearchParams((location.hash.split('?')[1]) || '');

  S.updateNav = () => {
    const me = S.state.me, nav = document.getElementById('nav-user');
    nav.innerHTML = me
      ? `${['admin', 'trainer'].includes(me.role) ? '<a href="#/admin">Admin</a>' : ''}<a href="#/tableau-de-bord">Mon espace</a>`
      : `<a href="#/connexion">Connexion</a><a class="btn-nav" href="#/inscription">S’inscrire</a>`;
  };
  S.refreshMe = async () => { S.state.me = (await S.api('/me')).user; S.updateNav(); return S.state.me; };
})();
