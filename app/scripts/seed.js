// Recharge le contenu des fichiers content/ dans la base.
// Usage : npm run seed            (ajoute les modules manquants)
//         npm run seed -- --force (écrase les modules en base par les fichiers : les modifications faites dans l'admin sont perdues)
const db = require('../src/db');
const content = require('../src/content');
db.open();
const n = content.seed({ force: process.argv.includes('--force') });
console.log(`${n} module(s) chargé(s).`);
db.close();
