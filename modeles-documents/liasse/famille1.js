// Famille 1 — Prospection et qualification
const L = require('./stfc-lib');
const { W, WL, C, SECTEURS, TAILLES, PHASES, OFFRES, t, P, h, body, bullets, note, kv, grid, band, box, signatures, checks, table, row, cell, lab, val, spacer, save } = L;
const OUT = __dirname + '/1_Prospection_et_qualification/';
require('fs').mkdirSync(OUT, { recursive: true });
const ctr = (s, o = {}) => P([t(s, { size: 17, ...o })], { align: 'center', after: 0 });

// 06 — Fiche de qualification prospect
async function qualification() {
  const w = [3200, 4006, 1000, 2000];
  const crit = (a, b) => row([cell(lab(a), w[0], { fill: C.label }), cell(P([t(b, { size: 16, color: C.grey })], { after: 0 }), w[1]), cell(ctr('/ 3', { color: C.grey }), w[2]), cell(val(''), w[3])], 440);
  const c = [
    h(1, 'Identification du prospect'),
    kv([['Raison sociale', '', 'Ville', ''], ['Activité principale', '', 'Année de création', ''], ['Chiffre d’affaires (tranche)', '', 'Site / réseaux', '']]),
    spacer(40), checks('Secteur :', SECTEURS), checks('Effectif :', TAILLES), checks('Phase :', PHASES),
    h(2, 'Décideur et contacts'),
    kv([['Décideur (nom)', '', 'Fonction', ''], ['Téléphone', '', 'E-mail', ''], ['Autre contact', '', 'Fonction', '']]),
    h(3, 'Origine du contact'),
    checks('Source :', '☐ Recommandation   ☐ Réseaux sociaux   ☐ Site web   ☐ Salon / événement   ☐ Prospection directe   ☐ Autre : ……………'),
    h(4, 'Besoins exprimés'),
    checks('Offre(s) pressentie(s) :', OFFRES),
    box('Enjeux, irritants et objectifs du dirigeant (verbatim)', 1300),
    h(5, 'Score de qualification'),
    table(w, [row(['Critère', 'Question clé', 'Note', 'Commentaire'].map((x, i) => cell(ctr(x, { bold: true, color: 'FFFFFF' }), w[i], { fill: C.navy })), 420),
      crit('Besoin', 'Le problème est-il identifié et reconnu par la direction ?'), crit('Budget', 'Un budget est-il disponible ou mobilisable ?'),
      crit('Décision', 'Parle-t-on au décideur final ?'), crit('Délai', 'Le projet doit-il démarrer dans les 3 mois ?'),
      row([cell(lab('TOTAL'), w[0] + w[1], { fill: C.label, span: 2 }), cell(ctr('/ 12', { bold: true }), w[2]), cell(val(''), w[3])], 440)]),
    note('Barème : 0 = non / inconnu · 1 = faible · 2 = moyen · 3 = fort.   Statut : 9 – 12 chaud · 5 – 8 tiède · 0 – 4 froid.'),
    checks('Statut :', '☐ Chaud   ☐ Tiède   ☐ Froid'),
    h(6, 'Prochaine action'),
    kv([['Action', '', 'Échéance', ''], ['Responsable STFC', '', 'Diagnostic flash proposé', '☐ Oui   ☐ Non']]),
  ];
  await save(OUT + '06_STFC_Fiche_qualification_prospect.docx', 'FICHE PROSPECT', [['N°', 'PR-……/2026'], ['Date', '……/……/2026'], ['Consultant', '……………………']], c);
}

// 07 — Fiche de diagnostic flash
const AXES = [
  ['Stratégie et offre', ['Les cibles de clients prioritaires sont clairement définies.', 'L’offre est différenciée des concurrents et formulée en une phrase.', 'La politique de prix est maîtrisée (marges connues, remises encadrées).', 'Des objectifs de chiffre d’affaires annuels chiffrés existent.']],
  ['Organisation commerciale', ['Le processus de vente est formalisé, de la prospection à l’encaissement.', 'Les rôles commerciaux (vente, relance, recouvrement) sont clairement répartis.', 'Un suivi hebdomadaire de l’activité commerciale est réalisé.', 'Le portefeuille clients est segmenté (Pareto, clients clés).']],
  ['Force de vente', ['Chaque commercial a des objectifs individuels mesurables.', 'Les commerciaux ont été formés aux techniques de vente au cours des 2 dernières années.', 'Un système de rémunération variable motive la performance.', 'Les compétences de l’équipe sont évaluées régulièrement.']],
  ['Marketing et acquisition', ['L’entreprise prospecte de nouveaux clients de façon régulière.', 'Le coût d’acquisition d’un client est connu.', 'Des actions de fidélisation des clients existants sont en place.', 'La satisfaction client est mesurée.']],
  ['Digital et outils', ['L’entreprise dispose d’un site internet à jour.', 'Les réseaux sociaux professionnels sont animés régulièrement.', 'Un CRM ou fichier centralisé des clients et prospects est utilisé.', 'Des tableaux de bord commerciaux permettent un pilotage en temps réel.']],
];
async function diagFlash() {
  const w = [600, 6406, 800, 800, 800, 800];
  const hd = row(['N°', 'Affirmation (cocher la note)', '0', '1', '2', '3'].map((x, i) => cell(ctr(x, { bold: true, color: 'FFFFFF' }), w[i], { fill: C.navy })), 420);
  const rows = [hd]; let n = 0;
  AXES.forEach(([axe, qs], a) => { rows.push(band(`Axe ${a + 1} — ${axe}`, 6, W)); qs.forEach((q) => { n++; rows.push(row([cell(ctr(String(n), { bold: true, color: C.navy }), w[0]), cell(val(q), w[1]), ...[2, 3, 4, 5].map((i) => cell(ctr('☐'), w[i]))], 400)); }); });
  const ws = [4206, 1500, 1500, 3000];
  const synth = table(ws, [row(['Axe', 'Score', 'Sur', 'Niveau'].map((x, i) => cell(ctr(x, { bold: true, color: 'FFFFFF' }), ws[i], { fill: C.navy })), 400),
    ...AXES.map(([axe]) => row([cell(lab(axe), ws[0], { fill: C.label }), cell(val(''), ws[1]), cell(ctr('12'), ws[2]), cell(ctr('☐ Faible  ☐ Moyen  ☐ Bon', { size: 15 }), ws[3])], 380)),
    row([cell(lab('SCORE GLOBAL'), ws[0], { fill: C.label }), cell(val(''), ws[1]), cell(ctr('60', { bold: true }), ws[2]), cell(val(''), ws[3])], 400)]);
  const wi = [2000, 3206, 5000];
  const interp = table(wi, [row(['Score', 'Maturité', 'Offre STFC recommandée'].map((x, i) => cell(ctr(x, { bold: true, color: 'FFFFFF' }), wi[i], { fill: C.navy })), 400),
    row([cell(ctr('0 – 20'), wi[0]), cell(val('Fragile — fondations à poser'), wi[1]), cell(val('STFC Audit, puis STFC Croissance'), wi[2])], 380),
    row([cell(ctr('21 – 40'), wi[0]), cell(val('En structuration'), wi[1]), cell(val('STFC Croissance + STFC Academy'), wi[2])], 380),
    row([cell(ctr('41 – 60'), wi[0]), cell(val('Mature — à accélérer'), wi[1]), cell(val('STFC Transformation Digitale + optimisation'), wi[2])], 380)]);
  const c = [
    note('Entretien de 30 à 45 minutes avec le dirigeant. Barème : 0 = inexistant · 1 = partiel · 2 = en place · 3 = maîtrisé et suivi.'),
    h(1, 'Entreprise'),
    kv([['Raison sociale', '', 'Interlocuteur', ''], ['Fonction', '', 'Téléphone', '']]),
    spacer(40), checks('Secteur :', SECTEURS), checks('Effectif :', TAILLES), checks('Phase :', PHASES),
    h(2, 'Grille d’évaluation — 20 affirmations'),
    table(w, rows),
    h(3, 'Synthèse des scores'), synth,
    h(4, 'Lecture du score'), interp,
    h(5, 'Recommandation du consultant'),
    box('3 priorités identifiées et offre proposée', 1300),
    spacer(80),
    signatures('Le dirigeant', 'Le consultant STFC', 1000),
  ];
  await save(OUT + '07_STFC_Fiche_diagnostic_flash.docx', 'DIAGNOSTIC FLASH', [['Entreprise', '……………………'], ['Date', '……/……/2026'], ['Consultant', '……………………']], c);
}

// 08 — Compte-rendu du premier rendez-vous
async function crRdv() {
  const c = [
    h(1, 'Informations générales'),
    kv([['Entreprise', '', 'Date', ''], ['Lieu / format', '☐ Sur site   ☐ Bureau STFC   ☐ Visio / téléphone'], ['Durée', '', 'Consultant STFC', '']]),
    h(2, 'Participants'),
    grid(['N°', 'Nom et prénom', 'Fonction', 'Téléphone / e-mail', 'Rôle dans la décision'], [600, 2700, 2200, 2706, 2000], 4),
    h(3, 'Contexte de l’entreprise'),
    box('Activité, historique, marché, chiffres clés communiqués', 1200),
    h(4, 'Besoins et enjeux exprimés'),
    box('Problèmes rencontrés, objectifs du dirigeant, priorités', 1300),
    checks('Offre(s) pressentie(s) :', OFFRES),
    h(5, 'Freins, objections et attentes'),
    box('', 900),
    h(6, 'Budget et calendrier'),
    kv([['Budget évoqué', '', 'Date de décision', ''], ['Démarrage souhaité', '', 'Autres décideurs', '']]),
    h(7, 'Prochaines étapes'),
    grid(['N°', 'Action', 'Responsable', 'Échéance'], [600, 5606, 2000, 2000], 3),
    checks('Suite :', '☐ Envoi de proposition   ☐ Diagnostic flash   ☐ Second rendez-vous   ☐ Sans suite'),
  ];
  await save(OUT + '08_STFC_Compte-rendu_premier_rendez-vous.docx', 'COMPTE-RENDU RDV', [['N°', 'CR-……/2026'], ['Date', '……/……/2026'], ['Consultant', '……………………']], c);
}

// 09 — Suivi du pipeline STFC (paysage)
async function pipeline() {
  const w = [500, 2000, 1300, 1900, 1500, 1400, 1600, 900, 2638, 1400];
  const c = [
    note('Étapes : 1 Contact · 2 Rendez-vous · 3 Diagnostic flash · 4 Proposition envoyée · 5 Négociation · 6 Gagné · 7 Perdu.   Probabilité indicative : 10 % · 20 % · 30 % · 50 % · 70 % · 100 % · 0 %.'),
    grid(['N°', 'Prospect', 'Secteur', 'Contact / tél.', 'Offre visée', 'Étape', 'Montant estimé (FCFA)', 'Proba.', 'Prochaine action', 'Échéance'], w, 13, { h: 420 }),
    spacer(80),
    kv([['Montant total du pipeline', '', 'Montant pondéré (× proba.)', ''], ['Affaires gagnées ce mois', '', 'Taux de transformation', '']], WL),
  ];
  await save(OUT + '09_STFC_Suivi_pipeline_commercial.docx', 'SUIVI DU PIPELINE', [['Période', '……/2026'], ['Consultant', '……………………'], ['Mise à jour', 'Hebdomadaire']], c, { landscape: true });
}

// 10 — Questionnaire de pré-diagnostic
const QUEST = [
  ['Votre entreprise', ['Présentez en quelques lignes votre activité et vos produits ou services.', 'Quel a été votre chiffre d’affaires sur les 3 dernières années (tendance) ?', 'Combien de collaborateurs, dont combien dans la vente et le marketing ?']],
  ['Votre offre et votre marché', ['Quels sont vos 3 produits ou services les plus rentables ?', 'Qui sont vos principaux concurrents et en quoi êtes-vous différent ?', 'Comment fixez-vous vos prix ?']],
  ['Vos clients', ['Qui sont vos clients types (secteurs, tailles, zones) ?', 'Quelle part de votre chiffre d’affaires réalisent vos 10 premiers clients ?', 'Pourquoi vos clients vous choisissent-ils ? Pourquoi certains partent-ils ?']],
  ['Votre organisation commerciale', ['Comment trouvez-vous de nouveaux clients aujourd’hui ?', 'Comment suivez-vous l’activité de vos commerciaux (rapports, objectifs, réunions) ?', 'Quels sont vos délais moyens de paiement et vos difficultés de recouvrement ?']],
  ['Marketing et digital', ['Quels outils utilisez-vous (site web, réseaux sociaux, WhatsApp Business, CRM, Excel) ?', 'Quelles actions marketing avez-vous menées l’an dernier, et avec quels résultats ?']],
  ['Vos attentes', ['Quels sont vos 3 objectifs prioritaires pour les 12 prochains mois ?', 'Qu’attendez-vous concrètement de l’accompagnement de STFC ?']],
];
async function preDiag() {
  const c = [note('À remplir par le dirigeant avant la première séance de travail et à retourner à STFC. Les informations communiquées restent strictement confidentielles.'),
    kv([['Entreprise', '', 'Rempli par', ''], ['Fonction', '', 'Date', '']]),
    spacer(40), checks('Secteur :', SECTEURS), checks('Effectif :', TAILLES)];
  let n = 0;
  QUEST.forEach(([sec, qs], i) => {
    c.push(h(i + 1, sec));
    qs.forEach((q) => { n++; c.push(P([t(n + '. ', { size: 19, bold: true, color: C.gold }), t(q, { size: 19, bold: true, color: C.navy })], { after: 40, keepNext: true }), box('', 800), spacer(40)); });
  });
  c.push(h(QUEST.length + 1, 'Documents à joindre si possible'), ...bullets(['Organigramme', 'Catalogue ou plaquette commerciale', 'Chiffre d’affaires mensuel des 12 derniers mois', 'Liste des principaux clients (anonymisée si besoin)']));
  await save(OUT + '10_STFC_Questionnaire_pre-diagnostic.docx', 'QUESTIONNAIRE PRÉ-DIAGNOSTIC', [['Entreprise', '……………………'], ['Retour souhaité', '……/……/2026']], c);
}

(async () => { await qualification(); await diagFlash(); await crRdv(); await pipeline(); await preDiag(); console.log('famille 1 ok'); })();
