// Tarification régionale : prix de base en FCFA (zone A), ajustés par zone, affichés en monnaie locale + EUR.
const config = require('./config');
const tracks = require('../content/tracks');

const BASE = {
  pass: 249000,       // Pass Carrière : 4 parcours à vie
  'sub-month': 10000,  // Premium mensuel : tout l'accès 30 jours
  'sub-year': 99000   // Premium annuel : tout l'accès 365 jours (2 mois offerts)
};

const ZONES = {
  uemoa:    { label: 'Afrique de l’Ouest (FCFA – UEMOA)', factor: 1,    currency: 'XOF', display: 'XOF', channels: 'ALL',
              countries: { CI: 'Côte d’Ivoire', SN: 'Sénégal', BF: 'Burkina Faso', ML: 'Mali', BJ: 'Bénin', TG: 'Togo', NE: 'Niger', GW: 'Guinée-Bissau' } },
  cemac:    { label: 'Afrique centrale (FCFA – CEMAC)', factor: 1,    currency: 'XAF', display: 'XAF', channels: 'ALL',
              countries: { CM: 'Cameroun', GA: 'Gabon', CG: 'Congo-Brazzaville', TD: 'Tchad', CF: 'Centrafrique', GQ: 'Guinée équatoriale' } },
  b:        { label: 'Afrique hors zone FCFA', factor: 0.75, currency: 'USD', display: 'USD', channels: 'ALL',
              countries: { CD: 'RD Congo', GN: 'Guinée', MG: 'Madagascar', BI: 'Burundi', RW: 'Rwanda', KM: 'Comores', DJ: 'Djibouti', MR: 'Mauritanie' } },
  maghreb:  { label: 'Maghreb', factor: 1,    currency: 'XOF', display: 'MAD', channels: 'CREDIT_CARD',
              countries: { MA: 'Maroc', TN: 'Tunisie', DZ: 'Algérie' } },
  diaspora: { label: 'Diaspora (Europe, Amérique du Nord)', factor: 1.3, currency: 'XOF', display: 'EUR', channels: 'CREDIT_CARD',
              countries: { FR: 'France', BE: 'Belgique', CH: 'Suisse', CA: 'Canada', US: 'États-Unis', OTHER: 'Autre pays' } }
};

function zoneOfCountry(code) {
  for (const [id, z] of Object.entries(ZONES)) if (z.countries[code]) return id;
  return 'diaspora';
}

function baseXof(product) {
  if (BASE[product]) return BASE[product];
  const m = /^track:(.+)$/.exec(product || '');
  const t = m && tracks.find(x => x.id === m[1] && !x.free);
  return t ? t.price : null;
}

function productLabel(product) {
  if (product === 'pass') return 'Pass Carrière (4 parcours)';
  if (product === 'sub-month') return 'Premium mensuel';
  if (product === 'sub-year') return 'Premium annuel';
  const t = tracks.find(x => 'track:' + x.id === product);
  return t ? 'Parcours ' + t.title : product;
}

const round = (n, step) => Math.max(step, Math.round(n / step) * step);

// Renvoie le prix d'un produit pour une zone : montant débité, affichage local et équivalent EUR.
function quote(product, zoneId) {
  const base = baseXof(product);
  const zone = ZONES[zoneId] || ZONES.uemoa;
  if (base == null) return null;
  const xof = round(base * zone.factor, 500);
  const r = config.rates;
  const eur = Math.round(xof / r.EUR);
  let amount = xof, currency = zone.currency;
  if (currency === 'USD') amount = Math.round(xof / r.USD);
  let display = { amount: xof, currency: zone.display === 'XAF' ? 'XAF' : 'XOF' };
  if (zone.display === 'USD') display = { amount, currency: 'USD' };
  if (zone.display === 'MAD') display = { amount: round(xof / r.MAD, 10), currency: 'MAD' };
  if (zone.display === 'EUR') display = { amount: eur, currency: 'EUR' };
  // Paiement en 3 fois (+3 %), exprimé dans la monnaie débitée et dans la monnaie affichée
  let installments = null;
  if (!product.startsWith('sub-')) {
    const ix = round(xof / 3 * 1.03, 500);
    const charge = currency === 'USD' ? Math.round(ix / r.USD) : ix;
    const shown = display.currency === 'USD' ? charge : display.currency === 'MAD' ? round(ix / r.MAD, 10) : display.currency === 'EUR' ? Math.round(ix / r.EUR) : ix;
    installments = { xof: ix, amount: charge, currency, display: { amount: shown, currency: display.currency } };
  }
  return {
    product, label: productLabel(product), zone: zoneId in ZONES ? zoneId : 'uemoa',
    amount, currency, display, eur, xof, installments, channels: zone.channels
  };
}

function catalogPrices(zoneId) {
  const products = [...tracks.filter(t => !t.free).map(t => 'track:' + t.id), 'pass', 'sub-month', 'sub-year'];
  return products.map(p => quote(p, zoneId));
}

// Durée d'accès accordée par un produit (null = à vie)
function grantFor(product) {
  if (product === 'pass') return { scope: 'all', days: null };
  if (product === 'sub-month') return { scope: 'all', days: 30 };
  if (product === 'sub-year') return { scope: 'all', days: 365 };
  const m = /^track:(.+)$/.exec(product);
  return m ? { scope: 'track:' + m[1], days: null } : null;
}

module.exports = { ZONES, BASE, quote, catalogPrices, grantFor, zoneOfCountry, productLabel };
