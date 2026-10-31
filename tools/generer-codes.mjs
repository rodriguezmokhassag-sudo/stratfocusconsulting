#!/usr/bin/env node
// Génère des codes d'accès STFC Academy et leurs empreintes SHA-256 à coller dans platform/assets/js/config.js
// Usage : node tools/generer-codes.mjs <parcours> <nombre>
//   parcours : commercial | chef-equipe | responsable | directeur | all
import { createHash, randomBytes } from 'node:crypto';

const [track = 'commercial', countArg = '5'] = process.argv.slice(2);
const valid = ['commercial', 'chef-equipe', 'responsable', 'directeur', 'all'];
if (!valid.includes(track)) { console.error(`Parcours inconnu. Valeurs : ${valid.join(', ')}`); process.exit(1); }
const prefix = { commercial: 'COM', 'chef-equipe': 'CEQ', responsable: 'RES', directeur: 'DIR', all: 'PASS' }[track];
const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // sans 0/O/1/I pour éviter les confusions
const block = () => Array.from(randomBytes(4), b => alphabet[b % alphabet.length]).join('');

const count = Math.max(1, Math.min(500, parseInt(countArg, 10) || 5));
const lines = [];
console.log('Codes à remettre aux apprenants :\n');
for (let i = 0; i < count; i++) {
  const code = `${prefix}-${block()}-${block()}`;
  const hash = createHash('sha256').update(code).digest('hex');
  console.log('  ' + code);
  lines.push(`    '${hash}': ['${track}'],`);
}
console.log('\nLignes à ajouter dans accessCodes (config.js) :\n');
console.log(lines.join('\n'));
