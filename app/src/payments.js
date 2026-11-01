// Paiements : CinetPay (Mobile Money + carte) ou mode simulation si aucune clé n'est configurée.
// Doc CinetPay : https://docs.cinetpay.com/api/1.0-fr/checkout/initialisation
const crypto = require('node:crypto');
const config = require('./config');
const db = require('./db');
const pricing = require('./pricing');

const live = () => Boolean(config.cinetpay.apiKey && config.cinetpay.siteId);
const provider = () => (live() ? 'cinetpay' : 'simulation');

async function cinetpay(path, body) {
  const res = await fetch(config.cinetpay.apiUrl + path, {
    method: 'POST', headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ apikey: config.cinetpay.apiKey, site_id: config.cinetpay.siteId, ...body }),
    signal: AbortSignal.timeout(20000)
  });
  return res.json();
}

// Crée la transaction et renvoie l'URL de paiement vers laquelle rediriger l'apprenant.
async function initPayment(user, { product, zone, plan, phone, city }) {
  const quote = pricing.quote(product, zone);
  if (!quote) throw Object.assign(new Error('Produit inconnu'), { status: 400 });
  const x3 = plan === 'x3' && quote.installments;
  let amount = quote.amount, amountXof = quote.xof;
  if (x3) { amountXof = quote.installments.xof; amount = quote.installments.amount; }
  const transactionId = 'STFC' + Date.now().toString(36).toUpperCase() + crypto.randomBytes(3).toString('hex').toUpperCase();
  db.run(`INSERT INTO payments (user_id, transaction_id, product, plan, amount, currency, amount_xof, zone, provider, status, created_at, updated_at)
          VALUES (?,?,?,?,?,?,?,?,?, 'pending', ?, ?)`,
    [user.id, transactionId, product, x3 ? 'x3' : 'full', amount, quote.currency, amountXof, quote.zone, provider(), db.now(), db.now()]);

  const returnUrl = `${config.baseUrl}/#/paiement/${transactionId}`;
  if (!live()) return { transactionId, paymentUrl: `${config.baseUrl}/#/paiement-simule/${transactionId}`, simulation: true };

  const [first, ...rest] = user.full_name.split(' ');
  const r = await cinetpay('/payment', {
    transaction_id: transactionId, amount, currency: quote.currency,
    description: `STFC Academy ${quote.label}${x3 ? ' (1/3)' : ''}`.replace(/[^\w\s()/-]/g, ''),
    notify_url: `${config.baseUrl}/api/payments/notify`, return_url: returnUrl,
    channels: quote.channels, lang: 'fr', metadata: String(user.id),
    customer_id: String(user.id), customer_name: first, customer_surname: rest.join(' ') || first,
    customer_email: user.email, customer_phone_number: phone || user.phone || '',
    customer_address: city || 'N/A', customer_city: city || 'N/A',
    customer_country: user.country && user.country !== 'OTHER' ? user.country : 'CI', customer_state: user.country || 'CI', customer_zip_code: '00000'
  });
  if (r.code !== '201' || !r.data || !r.data.payment_url) {
    db.run("UPDATE payments SET status='refused', raw=?, updated_at=? WHERE transaction_id=?", [JSON.stringify(r), db.now(), transactionId]);
    throw Object.assign(new Error('Le service de paiement est indisponible. Réessayez ou contactez-nous.'), { status: 502 });
  }
  return { transactionId, paymentUrl: r.data.payment_url };
}

// Interroge le prestataire (jamais de confiance aveugle dans la notification) puis applique le résultat.
async function confirm(transactionId) {
  const p = db.get('SELECT * FROM payments WHERE transaction_id = ?', [transactionId]);
  if (!p || p.status !== 'pending' || p.provider !== 'cinetpay' || !live()) return p;
  const r = await cinetpay('/payment/check', { transaction_id: transactionId });
  const d = r.data || {};
  if (d.status === 'ACCEPTED' && Number(d.amount) === p.amount && d.currency === p.currency) return applyResult(p, 'accepted', d.payment_method, r);
  if (['REFUSED', 'CANCELED'].includes(d.status)) return applyResult(p, 'refused', d.payment_method, r);
  return p;
}

function simulate(transactionId, userId, accepted) {
  const p = db.get('SELECT * FROM payments WHERE transaction_id = ? AND user_id = ?', [transactionId, userId]);
  if (!p || p.provider !== 'simulation') throw Object.assign(new Error('Transaction introuvable'), { status: 404 });
  return applyResult(p, accepted ? 'accepted' : 'refused', 'SIMULATION', { simulated: true });
}

// Idempotent : un paiement déjà traité n'est jamais appliqué deux fois.
function applyResult(p, status, method, raw) {
  return db.tx(() => {
    const r = db.run("UPDATE payments SET status=?, method=?, raw=?, updated_at=? WHERE id=? AND status='pending'", [status, method || null, JSON.stringify(raw), db.now(), p.id]);
    if (r.changes && status === 'accepted') grantFromPayment(p);
    return db.get('SELECT * FROM payments WHERE id = ?', [p.id]);
  });
}

function grantFromPayment(p) {
  const g = pricing.grantFor(p.product);
  if (!g) return;
  let days = g.days;
  if (p.plan === 'x3') {
    const paid = db.get("SELECT COUNT(*) AS n FROM payments WHERE user_id=? AND product=? AND plan='x3' AND status='accepted'", [p.user_id, p.product]).n;
    days = paid >= 3 ? null : 35; // accès prolongé à chaque échéance, définitif après la 3e
  }
  let start = new Date();
  if (days) { // les abonnements et échéances s'ajoutent à l'accès en cours
    const cur = db.get('SELECT MAX(expires_at) AS e FROM entitlements WHERE user_id=? AND scope=? AND expires_at > ?', [p.user_id, g.scope, db.now()]);
    if (cur && cur.e) start = new Date(cur.e);
  }
  const expires = days ? new Date(start.getTime() + days * 86400000).toISOString() : null;
  db.run('INSERT INTO entitlements (user_id, scope, source, ref, starts_at, expires_at) VALUES (?,?,?,?,?,?)', [p.user_id, g.scope, 'payment', p.transaction_id, db.now(), expires]);
}

module.exports = { initPayment, confirm, simulate, live, provider };
