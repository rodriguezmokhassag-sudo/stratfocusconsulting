// Quiz d'auto-évaluation gratuit : positionne l'apprenant et recommande un parcours.
// Chaque option rapporte de 0 à 3 points. Le niveau dépend du score et de l'expérience déclarée.
const questions = [
  { dim: 'Expérience', q: 'Depuis combien de temps exercez-vous une activité commerciale ?', options: [
    { x: 'Jamais, je débute', p: 0 }, { x: 'Moins de 2 ans', p: 1 }, { x: '2 à 5 ans', p: 2 }, { x: 'Plus de 5 ans', p: 3 }] },
  { dim: 'Responsabilités', q: 'Combien de personnes encadrez-vous aujourd’hui ?', options: [
    { x: 'Aucune', p: 0 }, { x: '1 à 3 (référent, tuteur)', p: 1 }, { x: '4 à 10 commerciaux', p: 2 }, { x: 'Plusieurs équipes ou managers', p: 3 }] },
  { dim: 'Vente', q: 'Lors d’un premier rendez-vous, que faites-vous en premier ?', options: [
    { x: 'Je présente mon catalogue et mes prix', p: 0 }, { x: 'Je parle de mon entreprise', p: 1 }, { x: 'Je pose des questions sur la situation du client', p: 2 }, { x: 'Je fais mesurer au client les conséquences de ses problèmes avant de proposer', p: 3 }] },
  { dim: 'Vente', q: 'Un client vous dit « C’est trop cher ». Votre réflexe ?', options: [
    { x: 'J’accorde une remise', p: 0 }, { x: 'J’explique que la qualité a un prix', p: 1 }, { x: 'Je lui demande « trop cher par rapport à quoi ? »', p: 2 }, { x: 'Je creuse, je reformule puis je chiffre la valeur sur la durée', p: 3 }] },
  { dim: 'Organisation', q: 'Comment suivez-vous vos clients et prospects ?', options: [
    { x: 'De mémoire', p: 0 }, { x: 'Dans un carnet ou sur WhatsApp', p: 1 }, { x: 'Dans un tableur mis à jour', p: 2 }, { x: 'Dans un CRM avec des indicateurs suivis chaque semaine', p: 3 }] },
  { dim: 'Management', q: 'Un commercial de votre équipe est démotivé. Que faites-vous ?', options: [
    { x: 'Je ne suis pas concerné(e)', p: 0 }, { x: 'Je lui rappelle ses objectifs', p: 1 }, { x: 'Je l’écoute en entretien individuel', p: 2 }, { x: 'Je l’écoute, j’adapte mon style et je fixe un plan de progrès avec accompagnement terrain', p: 3 }] },
  { dim: 'Pilotage', q: 'Que signifie un taux de transformation de 20 % ?', options: [
    { x: 'Je ne sais pas', p: 0 }, { x: '20 % de marge', p: 0 }, { x: '20 % des propositions ou visites aboutissent à une vente', p: 2 }, { x: 'C’est un indicateur à suivre par étape du cycle de vente pour trouver où l’on perd des affaires', p: 3 }] },
  { dim: 'Stratégie', q: 'Avez-vous déjà construit un plan d’action commercial chiffré ?', options: [
    { x: 'Non', p: 0 }, { x: 'J’ai participé à sa mise en œuvre', p: 1 }, { x: 'Oui, pour ma zone ou mon équipe', p: 2 }, { x: 'Oui, pour l’entreprise, avec budget et revues trimestrielles', p: 3 }] },
  { dim: 'Stratégie', q: 'Les matrices SWOT, BCG ou Ansoff vous sont…', options: [
    { x: 'Inconnues', p: 0 }, { x: 'Connues de nom', p: 1 }, { x: 'Familières, je les ai déjà utilisées', p: 2 }, { x: 'Utilisées régulièrement pour décider', p: 3 }] },
  { dim: 'Marketing digital', q: 'Comment utilisez-vous le digital pour vendre ?', options: [
    { x: 'Pas du tout', p: 0 }, { x: 'Je publie de temps en temps sur WhatsApp ou Facebook', p: 1 }, { x: 'J’ai un catalogue WhatsApp Business et je relance mes prospects', p: 2 }, { x: 'J’ai une stratégie mesurée (contenus, publicité, conversions)', p: 3 }] }
];

const TRACKS = {
  decouverte: { title: 'Découverte (gratuit)', why: 'Commencez par les modules gratuits pour acquérir les bases de la vente, du marketing digital et de l’innovation.' },
  commercial: { title: 'Parcours Commercial', why: 'Vous avez les bases : structurez votre entretien de vente, du questionnement à la fidélisation.' },
  'chef-equipe': { title: 'Parcours Chef d’équipe commercial', why: 'Vous maîtrisez la vente : apprenez à faire réussir une équipe.' },
  responsable: { title: 'Parcours Responsable commercial', why: 'Vous encadrez déjà : passez au pilotage d’une zone, d’un portefeuille et d’un budget.' },
  directeur: { title: 'Parcours Directeur commercial', why: 'Vous avez une vision d’ensemble : travaillez la stratégie, l’organisation et la transformation commerciale.' }
};

function evaluate(answers) {
  let total = 0; const max = questions.length * 3; const dims = {};
  questions.forEach((q, i) => {
    const o = q.options[Number(answers[i])];
    const p = o ? o.p : 0; total += p;
    dims[q.dim] = dims[q.dim] || { score: 0, max: 0 }; dims[q.dim].score += p; dims[q.dim].max += 3;
  });
  const score = Math.round(total / max * 100);
  const exp = (questions[0].options[Number(answers[0])] || { p: 0 }).p;
  const team = (questions[1].options[Number(answers[1])] || { p: 0 }).p;
  let track = 'decouverte';
  if (score >= 25 || exp >= 1) track = 'commercial';
  if (score >= 50 && (exp >= 2 || team >= 1)) track = 'chef-equipe';
  if (score >= 65 && team >= 2) track = 'responsable';
  if (score >= 80 && team >= 3) track = 'directeur';
  const strengths = Object.entries(dims).filter(([, d]) => d.score / d.max >= 0.67).map(([k]) => k);
  const gaps = Object.entries(dims).filter(([, d]) => d.score / d.max < 0.5).map(([k]) => k);
  return { score, track, title: TRACKS[track].title, why: TRACKS[track].why, strengths, gaps, dims };
}

module.exports = {
  title: 'Auto-évaluation : quel est votre niveau commercial ?',
  intro: '10 questions, 3 minutes. Découvrez vos points forts et le parcours qui vous correspond.',
  questions, evaluate
};
