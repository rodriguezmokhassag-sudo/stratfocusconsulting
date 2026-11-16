// Famille 0 — Cadre juridique et identité
const L = require('./stfc-lib');
const { W, C, SERVICES, MODULES, OFFRES, t, P, h, art, body, rich, bullets, note, kv, grid, band, box, signatures, checks, table, row, cell, lab, val, spacer, save } = L;
const OUT = __dirname + '/0_Cadre_juridique_et_identite/';
require('fs').mkdirSync(OUT, { recursive: true });
const AVERT = note('Modèle de travail : à faire valider par un juriste ou un conseil inscrit au Congo avant toute utilisation contractuelle.');

// 01 — CGV
async function cgv() {
  const c = [AVERT,
    art(1, 'Objet et champ d’application'),
    body('Les présentes Conditions Générales de Vente (CGV) régissent l’ensemble des prestations de conseil, d’accompagnement, de formation et de transformation digitale réalisées par STRAT FOCUS CONSULTING (ci-après « STFC » ou « le Prestataire ») pour le compte de ses clients professionnels (ci-après « le Client »). Toute commande implique l’acceptation sans réserve des présentes CGV, qui prévalent sur tout autre document du Client, sauf dérogation écrite et signée par STFC.'),
    art(2, 'Identification du Prestataire'),
    body('STRAT FOCUS CONSULTING — STFC Expertise, cabinet de conseil en stratégie, performance commerciale et marketing d’innovation. Siège : Zone OCI, 200 m du Parc Culture, Quartier MPITA, Pointe-Noire, République du Congo. RCCM CG-PNR-01-2025-A11-00010 — NIU : [à compléter]. E-mail : stratfocusconsulting@gmail.com.'),
    art(3, 'Offres de services'),
    body('STFC propose quatre offres, combinables entre elles :'),
    ...bullets(SERVICES.map(([n, d]) => n + ' — ' + d)),
    body('Le contenu, la durée, les livrables et le prix de chaque mission sont précisés dans la proposition commerciale ou le devis accepté par le Client.'),
    art(4, 'Commande et formation du contrat'),
    body('Les devis et propositions commerciales de STFC sont valables trente (30) jours à compter de leur date d’émission. Le contrat est formé à la réception par STFC du devis ou du bon de commande daté, signé et revêtu du cachet du Client, accompagné, le cas échéant, de l’acompte prévu. Les documents contractuels sont, par ordre de priorité : le contrat de prestation, la proposition commerciale ou le devis accepté, le bon de commande, puis les présentes CGV.'),
    art(5, 'Prix'),
    body('Les prix sont exprimés en francs CFA (FCFA), hors taxes. Ils sont majorés de la TVA au taux en vigueur (18 %) et du centime additionnel (5 % du montant de la TVA), ainsi que de toute autre taxe applicable au jour de la facturation. Les frais de déplacement, d’hébergement et de séjour hors de Pointe-Noire, les licences logicielles, abonnements, noms de domaine et frais d’hébergement des outils digitaux sont facturés en sus, sur justificatifs ou selon le devis.'),
    art(6, 'Modalités de paiement'),
    body('Sauf stipulation contraire du devis :'),
    ...bullets(['STFC Audit et STFC Transformation Digitale : acompte de [50] % à la commande, solde à la remise des livrables ;',
      'STFC Croissance : facturation mensuelle, payable à réception ;',
      'STFC Academy : [100] % avant le démarrage de la session de formation.']),
    body('Les factures sont payables dans un délai de [15] jours à compter de leur date d’émission, par virement bancaire, chèque à l’ordre de STRAT FOCUS CONSULTING ou paiement mobile (Mobile Money). Aucun escompte n’est accordé pour paiement anticipé.'),
    art(7, 'Retard de paiement'),
    body('Tout retard de paiement entraîne de plein droit, après mise en demeure restée sans effet pendant huit (8) jours, l’application de pénalités de retard au taux de [……] % par mois de retard, ainsi que la faculté pour STFC de suspendre l’exécution de la mission et l’accès aux outils digitaux livrés jusqu’au complet paiement. Les frais de recouvrement engagés sont à la charge du Client.'),
    art(8, 'Obligations de STFC'),
    body('STFC s’engage à exécuter ses prestations avec diligence et selon les règles de l’art de la profession de conseil. Ses obligations sont des obligations de moyens. Les résultats commerciaux du Client dépendant également de facteurs extérieurs (marché, décisions de la direction, mise en œuvre des recommandations), STFC ne garantit pas l’atteinte d’un niveau de chiffre d’affaires déterminé.'),
    art(9, 'Obligations du Client'),
    body('Le Client s’engage à : désigner un interlocuteur disposant du pouvoir de décision ; fournir dans les délais les informations, données et documents nécessaires, sincères et complets ; assurer l’accès à ses locaux, équipes et outils ; valider les livrables dans un délai de [10] jours ouvrés, faute de quoi ils sont réputés acceptés.'),
    art(10, 'Confidentialité'),
    body('Chacune des parties s’engage à garder strictement confidentielles les informations de toute nature communiquées par l’autre partie à l’occasion de la mission, pendant toute sa durée et deux (2) ans après son terme. STFC peut, sauf refus écrit du Client, citer le nom du Client comme référence commerciale, sans divulguer aucune information confidentielle.'),
    art(11, 'Propriété intellectuelle'),
    body('Les méthodes, outils, grilles d’analyse, supports de formation et savoir-faire de STFC restent sa propriété exclusive. Le Client acquiert, après paiement intégral, le droit d’utiliser les livrables pour ses besoins internes. Pour les outils développés dans le cadre de STFC Transformation Digitale (site, boutique en ligne, portail, paramétrages CRM), les accès administrateur, contenus et éléments spécifiquement créés pour le Client lui sont remis après paiement intégral ; les logiciels et services de tiers restent soumis aux licences de leurs éditeurs.'),
    art(12, 'Données personnelles'),
    body('Les parties s’engagent à respecter la réglementation applicable en République du Congo en matière de protection des données à caractère personnel. STFC ne traite les données des clients et prospects du Client que pour les besoins de la mission et selon ses instructions.'),
    art(13, 'Responsabilité'),
    body('La responsabilité de STFC, toutes causes confondues, est limitée aux dommages directs et prouvés, dans la limite du montant hors taxes effectivement perçu au titre de la mission concernée. STFC ne saurait être tenue responsable des pertes d’exploitation, de chiffre d’affaires ou de clientèle, ni des conséquences des décisions prises par le Client.'),
    art(14, 'Report et annulation'),
    ...bullets(['Mission de conseil : toute annulation après signature donne lieu à la facturation des travaux déjà réalisés et, au minimum, à la conservation de l’acompte versé.',
      'Session de formation STFC Academy : report ou annulation gratuits plus de quinze (15) jours avant la date prévue ; [50] % du prix dus entre quinze (15) et cinq (5) jours ; [100] % dus à moins de cinq (5) jours. Le remplacement d’un participant est possible sans frais.',
      'STFC se réserve le droit de reporter une session en cas d’effectif insuffisant ou d’indisponibilité de l’intervenant, sans indemnité autre que le remboursement des sommes versées pour la session.']),
    art(15, 'Résiliation'),
    body('En cas de manquement grave de l’une des parties à ses obligations, non réparé dans un délai de quinze (15) jours suivant une mise en demeure par écrit, l’autre partie pourra résilier le contrat de plein droit. Les prestations réalisées jusqu’à la date de résiliation restent dues.'),
    art(16, 'Force majeure'),
    body('Aucune des parties ne pourra être tenue responsable de l’inexécution de ses obligations résultant d’un cas de force majeure tel que défini par le droit applicable. L’exécution est suspendue pendant la durée de l’événement ; au-delà de trente (30) jours, chaque partie peut résilier le contrat sans indemnité.'),
    art(17, 'Droit applicable et litiges'),
    body('Les présentes CGV sont soumises au droit de la République du Congo et aux Actes uniformes de l’OHADA. Les parties s’efforceront de régler à l’amiable tout différend. À défaut d’accord dans un délai de trente (30) jours, le litige sera porté devant les juridictions compétentes de Pointe-Noire.'),
    spacer(120),
    signatures('Lu et approuvé — Le Client', 'Pour STRAT FOCUS CONSULTING'),
  ];
  await save(OUT + '01_STFC_Conditions_Generales_de_Vente.docx', 'CONDITIONS GÉNÉRALES DE VENTE', [['Version', '2026-01'], ['Date d’effet', '……/……/2026']], c);
}

// 02 — Contrat de prestation
async function contrat() {
  const c = [AVERT,
    h(1, 'Les parties'),
    kv([['Prestataire', 'STRAT FOCUS CONSULTING (STFC Expertise)'], ['Représenté par', 'Rodriguez MOKHASSA, Fondateur'], ['Siège', 'Zone OCI, Q. MPITA — Pointe-Noire'], ['RCCM / NIU', 'CG-PNR-01-2025-A11-00010 / [à compléter]']]),
    spacer(60),
    kv([['Client (raison sociale)', ''], ['Représenté par', '', 'Fonction', ''], ['Siège social', ''], ['RCCM', '', 'NIU', '']]),
    h(2, 'Objet de la mission'),
    body('Le présent contrat a pour objet de définir les conditions dans lesquelles STFC réalise pour le Client la mission décrite ci-dessous.'),
    checks('Offre(s) retenue(s) :', OFFRES),
    kv([['Intitulé de la mission', ''], ['Périmètre (entités, sites, équipes)', ''], ['Objectifs attendus', ''], ['Livrables', '']]),
    h(3, 'Durée et calendrier'),
    kv([['Date de démarrage', '', 'Date de fin prévue', ''], ['Durée totale', '', 'Rythme d’intervention', ''], ['Réunion de lancement', '', 'Restitution finale', '']]),
    h(4, 'Prix et modalités de paiement'),
    grid(['Échéance', 'Événement déclencheur', '% du prix', 'Montant HT (FCFA)', 'Date prévue'], [1000, 3606, 1300, 2300, 2000], 0,
      { rows: [['1', 'Acompte à la signature'], ['2', 'Remise du livrable intermédiaire'], ['3', 'Remise du livrable final'], ['', 'TOTAL HT']] }),
    body('Les montants s’entendent hors taxes : TVA 18 % et centime additionnel (5 % de la TVA) en sus. Frais de déplacement hors Pointe-Noire : ☐ inclus   ☐ refacturés au réel   ☐ forfait de …………… FCFA.', { before: 80 }),
    h(5, 'Obligations des parties'),
    body('STFC exécute la mission selon une obligation de moyens, avec la diligence d’un professionnel du conseil, et désigne un consultant responsable. Le Client désigne un interlocuteur décisionnaire, fournit les informations nécessaires, donne accès à ses équipes et outils et valide les livrables dans un délai de [10] jours ouvrés.'),
    kv([['Consultant STFC responsable', '', 'Téléphone', ''], ['Interlocuteur Client', '', 'Téléphone', '']]),
    h(6, 'Confidentialité et propriété intellectuelle'),
    body('Les parties sont tenues à une stricte confidentialité pendant la mission et deux (2) ans après son terme. Les méthodes et outils de STFC restent sa propriété ; le Client dispose, après paiement intégral, d’un droit d’usage interne des livrables et de la remise des accès aux outils digitaux créés pour lui.'),
    h(7, 'Résiliation et litiges'),
    body('En cas de manquement grave non réparé quinze (15) jours après mise en demeure, le contrat peut être résilié de plein droit ; les prestations réalisées restent dues. Le contrat est régi par le droit congolais et les Actes uniformes OHADA ; à défaut d’accord amiable, les juridictions de Pointe-Noire sont compétentes.'),
    h(8, 'Documents contractuels'),
    body('Le présent contrat, la proposition commerciale ou le devis n° …………… accepté, le bon de commande et les Conditions Générales de Vente de STFC, dont le Client reconnaît avoir pris connaissance.'),
    P([t('Fait à Pointe-Noire, le ……/……/2026, en deux exemplaires originaux.', { size: 19 })], { before: 120, after: 100 }),
    signatures('Pour le Client — « Lu et approuvé »', 'Pour STRAT FOCUS CONSULTING'),
  ];
  await save(OUT + '02_STFC_Contrat_de_prestation.docx', 'CONTRAT DE PRESTATION', [['N°', 'CT-……/2026'], ['Date', '……/……/2026'], ['Offre', 'Audit / Croissance / Digital / Academy']], c);
}

// 03 — Accord de confidentialité
async function nda() {
  const c = [AVERT,
    h(1, 'Les parties'),
    kv([['Partie 1', 'STRAT FOCUS CONSULTING, représentée par Rodriguez MOKHASSA, Fondateur'], ['Partie 2 (raison sociale)', ''], ['Représentée par', '', 'Fonction', ''], ['RCCM / NIU', '']]),
    h(2, 'Contexte'),
    body('Dans le cadre de discussions préalables et/ou de la réalisation d’une mission (diagnostic, audit, accompagnement, formation ou transformation digitale), les parties sont amenées à échanger des informations confidentielles. Le présent accord en fixe les conditions de protection.'),
    kv([['Projet concerné', '']]),
    art(1, 'Informations confidentielles'),
    body('Sont confidentielles toutes les informations, quel qu’en soit le support, communiquées par une partie à l’autre : données financières et commerciales, fichiers clients et prospects, tarifs, marges, stratégies, organisation, données des collaborateurs, accès aux outils informatiques, ainsi que les méthodes et outils de STFC.'),
    art(2, 'Engagements'),
    ...bullets(['utiliser les informations uniquement pour les besoins du projet ;', 'ne les communiquer qu’aux collaborateurs ayant besoin de les connaître, tenus à la même obligation ;', 'prendre toutes mesures raisonnables pour en préserver la sécurité ;', 'ne pas les copier ni les reproduire au-delà du nécessaire.']),
    art(3, 'Exceptions'),
    body('Ne sont pas confidentielles les informations déjà publiques sans faute de la partie qui les reçoit, déjà connues d’elle de manière licite, reçues d’un tiers autorisé, ou dont la divulgation est exigée par la loi ou une autorité judiciaire.'),
    art(4, 'Durée'),
    body('Le présent accord prend effet à sa signature et reste en vigueur pendant toute la durée des échanges et de la mission, puis pendant deux (2) ans après leur terme.'),
    art(5, 'Restitution'),
    body('À la fin du projet ou sur simple demande, chaque partie restitue ou détruit les informations confidentielles reçues et leurs copies, à l’exception de celles qu’elle est légalement tenue de conserver.'),
    art(6, 'Droit applicable'),
    body('Le présent accord est régi par le droit de la République du Congo et les Actes uniformes OHADA. À défaut d’accord amiable, les juridictions de Pointe-Noire sont compétentes.'),
    P([t('Fait à Pointe-Noire, le ……/……/2026, en deux exemplaires originaux.', { size: 19 })], { before: 120, after: 100 }),
    signatures('Pour la Partie 2', 'Pour STRAT FOCUS CONSULTING'),
  ];
  await save(OUT + '03_STFC_Accord_de_confidentialite.docx', 'ACCORD DE CONFIDENTIALITÉ', [['N°', 'NDA-……/2026'], ['Date', '……/……/2026']], c);
}

// 04 — Papier à en-tête / courrier
async function courrier() {
  const nb = { style: 'none', size: 0, color: 'FFFFFF' };
  const two = (a, b) => table([W / 2, W / 2], [row([cell(a, W / 2, { valign: 'top' }), cell(b, W / 2, { valign: 'top' })])],
    { borders: { top: nb, bottom: nb, left: nb, right: nb, insideHorizontal: nb, insideVertical: nb } });
  const c = [
    two([lab('Expéditeur'), val('Rodriguez MOKHASSA'), val('Fondateur — STFC Expertise'), val('stratfocusconsulting@gmail.com')],
      [lab('Destinataire'), val('[Civilité Prénom NOM]'), val('[Fonction]'), val('[Raison sociale]'), val('[Adresse]')]),
    spacer(160),
    P([t('Pointe-Noire, le ……/……/2026', { size: 19 })], { align: 'right', after: 160 }),
    P([t('Objet : ', { size: 19, bold: true, color: C.navy }), t('[objet du courrier]', { size: 19 })], { after: 40 }),
    P([t('Réf. : ', { size: 19, bold: true, color: C.navy }), t('[référence]', { size: 19 })], { after: 240 }),
    body('Madame, Monsieur,'),
    body('[Corps du courrier — premier paragraphe : contexte et objet.]'),
    body('[Deuxième paragraphe : proposition, informations ou demande.]'),
    body('[Troisième paragraphe : suite attendue, disponibilité pour un échange.]'),
    body('Nous vous prions d’agréer, Madame, Monsieur, l’expression de nos salutations distinguées.'),
    spacer(300),
    P([t('Rodriguez MOKHASSA', { font: L.HEAD, size: 21, bold: true, color: C.navy })], { align: 'right', after: 0 }),
    P([t('Fondateur, Consultant Expert en Performance Commerciale & Marketing d’Innovation', { size: 17, color: C.grey })], { align: 'right', after: 0 }),
    P([t('Parce que votre chiffre d’affaires compte', { font: L.HEAD, size: 17, italics: true, color: C.gold })], { align: 'right', after: 0 }),
  ];
  await save(OUT + '04_STFC_Papier_en-tete_Courrier.docx', 'COURRIER', [['Réf.', 'STFC/……/2026'], ['Date', '……/……/2026']], c);
}

// 05 — Grille tarifaire
async function tarifs() {
  const w = [3906, 1500, 1600, 1600, 1600];
  const hd = row(['Prestation', 'Unité', 'TPE (5 – 20)', 'PME (21 – 250)', 'Grande (+ 250)'].map((x, i) => cell(P([t(x, { size: 17, bold: true, color: 'FFFFFF' })], { align: 'center', after: 0 }), w[i], { fill: C.navy })), 420);
  const line = (a, u) => row([cell(val(a), w[0]), cell(P([t(u, { size: 17 })], { align: 'center', after: 0 }), w[1]), ...[2, 3, 4].map((i) => cell(P([t('[……]', { size: 17, color: C.grey })], { align: 'center', after: 0 }), w[i]))], 380);
  const rows = [hd,
    band('STFC Audit — Comprendre pour mieux repartir', 5, 10206),
    line('Diagnostic flash (entretien + score de maturité)', 'Forfait'), line('Audit commercial et marketing complet (≈ 1 mois)', 'Forfait'), line('Restitution stratégique + feuille de route 90 jours', 'Inclus'),
    band('STFC Croissance — Transformer le potentiel en résultats', 5, 10206),
    line('Co-construction du Plan d’Action Commerciale (PAC)', 'Forfait'), line('Accompagnement du dirigeant et suivi des indicateurs', 'Mois'), line('Mise en place des tableaux de bord de pilotage', 'Forfait'),
    band('STFC Transformation Digitale — La performance s’outille', 5, 10206),
    line('Diagnostic de maturité digitale + feuille de route', 'Forfait'), line('Site internet vitrine professionnel', 'Forfait'), line('Site e-commerce / boutique en ligne', 'Forfait'),
    line('Portail d’accès en ligne clients / partenaires', 'Forfait'), line('Sélection et paramétrage d’un CRM', 'Forfait'), line('Création et optimisation des réseaux sociaux', 'Forfait'),
    line('Community management et campagnes', 'Mois'), line('Conduite du changement et formation aux outils', 'Jour'), line('Maintenance et hébergement', 'Mois / an'),
    band('STFC Academy — Le moteur du capital humain', 5, 10206),
    ...MODULES.map((m, i) => line(String(i + 1).padStart(2, '0') + ' — ' + m, 'Session')), line('Parcours complet sur mesure (1 à 3 mois)', 'Forfait'),
  ];
  const c = [
    body('Tarifs exprimés en FCFA hors taxes (TVA 18 % et centime additionnel de 5 % de la TVA en sus), selon la taille de l’entreprise cliente. Chaque mission fait l’objet d’un devis personnalisé.'),
    table(w, rows),
    h(1, 'Conditions'),
    ...bullets(['Frais de déplacement hors Pointe-Noire refacturés au réel ou au forfait indiqué sur le devis.', 'Licences, abonnements, noms de domaine et hébergements des outils digitaux en sus.', 'Remise possible pour combinaison de plusieurs offres : [……] %.', 'Grille valable jusqu’au ……/……/2026 ; conditions détaillées dans les CGV STFC.']),
  ];
  await save(OUT + '05_STFC_Grille_tarifaire.docx', 'GRILLE TARIFAIRE', [['Édition', '2026'], ['Validité', '……/……/2026'], ['Usage', 'Interne / Client']], c);
}

(async () => { await cgv(); await contrat(); await nda(); await courrier(); await tarifs(); console.log('famille 0 ok'); })();
