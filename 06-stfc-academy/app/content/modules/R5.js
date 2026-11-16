// Module R5 — Recruter et intégrer ses commerciaux
module.exports = {
  id: 'R5', title: 'Recruter et intégrer ses commerciaux', status: 'complet', duration: '55 min',
  summary: 'Définir le profil du commercial performant, conduire un entretien avec mise en situation et réussir l’intégration des 30 premiers jours.',
  objectives: [
    'Rédiger une fiche de poste et un profil de compétences',
    'Conduire un entretien structuré avec jeu de rôle',
    'Évaluer les candidats avec une grille objective',
    'Construire un parcours d’intégration de 30 jours'
  ],
  skills: ['Recrutement commercial', 'Entretien structuré', 'Intégration des nouveaux'],
  video: {
    title: 'Recruter un vendeur, pas un beau parleur', duration: '5 min', src: null,
    script: [
      'Accroche : « Une erreur de recrutement coûte plusieurs mois de salaire, et des clients perdus. »',
      'Le profil : savoir, savoir-faire, savoir-être.',
      'Un jeu de rôle d’entretien filmé.',
      'La grille d’évaluation.',
      'Le plan d’intégration des 30 jours.'
    ]
  },
  lessons: [
    {
      title: 'Définir le poste et le profil',
      blocks: [
        { t: 'p', x: 'Recruter commence par une question : **quelle mission précise** ce commercial devra-t-il accomplir ? Vendre du crédit téléphonique à des boutiquiers ou des logiciels à des banques n’exige pas le même profil.' },
        { t: 'table', caption: 'Fiche de poste : commercial terrain B2B (distribution de matériel électrique, Douala)', head: ['Rubrique', 'Contenu'], rows: [
          ['Mission', 'Développer le CA auprès des électriciens, quincailleries et PME du BTP sur Douala Est'],
          ['Activités', '20 visites par semaine, prospection, devis, suivi des livraisons et des encaissements, CRM'],
          ['Objectifs', '45 M FCFA par trimestre, 10 nouveaux clients par trimestre'],
          ['Rémunération', 'Fixe + commission sur la marge + prime trimestrielle'],
          ['Moyens', 'Moto, téléphone, forfait internet, tablette avec catalogue']
        ]},
        { t: 'table', caption: 'Profil de compétences', head: ['Dimension', 'Indispensable', 'Souhaité'], rows: [
          ['Savoir', 'Bases techniques du produit (ou capacité à les apprendre vite)', 'Connaissance du BTP local'],
          ['Savoir-faire', 'Découverte, argumentation, conclusion, organisation', 'Maîtrise d’un CRM, d’Excel'],
          ['Savoir-être', 'Ténacité, écoute, intégrité, résistance au refus', 'Réseau dans le secteur']
        ]},
        { t: 'tip', x: 'Recrutez sur le **savoir-être** et le **savoir-faire**. Le savoir produit s’apprend en quelques semaines, la ténacité beaucoup moins.' }
      ]
    },
    {
      title: 'L’entretien et la mise en situation',
      blocks: [
        { t: 'flow', caption: 'Le processus de recrutement', items: ['Annonce (LinkedIn, sites d’emploi, cooptation)', 'Tri des CV', 'Entretien téléphonique de 15 min', 'Entretien + jeu de rôle', 'Prise de références', 'Décision'] },
        { t: 'table', caption: 'Questions comportementales (méthode STAR : Situation, Tâche, Action, Résultat)', head: ['Compétence', 'Question'], rows: [
          ['Ténacité', '« Racontez-moi une vente que vous avez obtenue après plusieurs refus. Qu’avez-vous fait ? »'],
          ['Organisation', '« Comment organisiez-vous votre semaine dans votre dernier poste ? Montrez-moi. »'],
          ['Résultats', '« Quel était votre objectif l’an dernier et quel pourcentage avez-vous atteint ? »'],
          ['Intégrité', '« Un client vous propose un arrangement personnel pour obtenir une remise. Que faites-vous ? »']
        ]},
        { t: 'steps', items: [
          { title: 'Le jeu de rôle (10 minutes)', x: 'Le recruteur joue un client réel avec une objection prévue (ex. « Je travaille déjà avec un fournisseur moins cher »).' },
          { title: 'Observer', x: 'Pose-t-il des questions ? Écoute-t-il ? Argumente-t-il sur les besoins ? Demande-t-il un engagement ?' },
          { title: 'Débriefer', x: 'Demander au candidat son auto-évaluation : sa lucidité est un excellent indicateur.' }
        ]},
        { t: 'action', x: 'Préparez le scénario de jeu de rôle de votre prochain recrutement, avec 2 objections.' }
      ]
    },
    {
      title: 'Évaluer et intégrer',
      blocks: [
        { t: 'table', caption: 'Grille d’évaluation (note de 1 à 5, pondérée)', head: ['Critère', 'Poids', 'Candidat A', 'Candidat B'], rows: [
          ['Jeu de rôle', '30 %', '4', '2'],
          ['Résultats passés prouvés', '25 %', '3', '5'],
          ['Ténacité et motivation', '20 %', '5', '3'],
          ['Organisation', '15 %', '4', '3'],
          ['Connaissance du secteur', '10 %', '2', '5'],
          ['Score pondéré', '100 %', '**3,75**', '**3,40**']
        ]},
        { t: 'table', caption: 'Parcours d’intégration de 30 jours', head: ['Période', 'Contenu', 'Responsable'], rows: [
          ['Jour 1', 'Accueil, présentation de l’équipe, matériel prêt, objectifs des 30 jours', 'Chef d’équipe'],
          ['Semaine 1', 'Formation produits et outils (CRM, tarifs), 3 jours en binôme avec un commercial expérimenté', 'Tuteur'],
          ['Semaine 2', 'Visites en autonomie le matin, débriefing chaque soir', 'Chef d’équipe'],
          ['Semaines 3-4', 'Portefeuille attribué, objectif progressif (50 % de la cible), 1 accompagnement terrain', 'Chef d’équipe'],
          ['Jour 30', 'Bilan : points forts, axes de progrès, objectifs du 2e mois', 'Responsable commercial']
        ]},
        { t: 'case', title: 'Étude de cas : le « meilleur vendeur » qui a démissionné',
          context: 'Un responsable commercial à Libreville recrute un candidat très brillant en entretien, sans jeu de rôle ni référence. Le jour 1, aucun matériel n’est prêt, et le nouveau commercial reçoit directement l’objectif complet et un secteur difficile. Il démissionne au bout de 7 semaines.',
          questions: ['Identifiez les erreurs de recrutement et d’intégration.', 'Que faut-il mettre en place ?'],
          solution: 'Recrutement : jugement sur **l’aisance orale** seule, **pas de mise en situation**, **pas de références**. Intégration : **matériel absent** (signal de désorganisation), **objectif plein dès le départ**, **aucun tuteur**, secteur difficile sans accompagnement. Correctifs : processus avec jeu de rôle et grille pondérée, prise de 2 références, parcours d’intégration de 30 jours avec tuteur, objectif progressif (50 %, puis 75 %, puis 100 % au 3e mois), bilan à J+30.' }
      ]
    }
  ],
  takeaways: [
    'Partir de la mission pour définir le profil : savoir, savoir-faire, savoir-être.',
    'Entretien structuré (méthode STAR) + jeu de rôle + références.',
    'Décider avec une grille pondérée, pas sur une impression.',
    'Intégrer sur 30 jours : tuteur, objectif progressif, bilan.'
  ],
  deliverable: { title: 'Kit de recrutement', x: 'Une fiche de poste, une grille d’entretien de 8 questions STAR, un scénario de jeu de rôle, une grille d’évaluation pondérée et le planning d’intégration des 30 premiers jours.' },
  quiz: [
    { q: 'Sur quoi recruter en priorité un commercial ?', options: ['Sur le savoir produit uniquement', 'Sur le savoir-être et le savoir-faire', 'Sur le diplôme', 'Sur l’apparence'], a: 1, why: 'Le savoir produit s’apprend rapidement, pas la ténacité.' },
    { q: 'Que signifie STAR dans les questions comportementales ?', options: ['Statut, Talent, Ambition, Résultat', 'Situation, Tâche, Action, Résultat', 'Stratégie, Technique, Analyse, Réflexion', 'Savoir, Tâche, Attitude, Rôle'], a: 1, why: 'On fait raconter une situation réelle et ce que le candidat y a fait.' },
    { q: 'Quel est l’intérêt du jeu de rôle ?', options: ['Faire gagner du temps', 'Observer le candidat en situation de vente réelle', 'Tester sa culture générale', 'Le mettre mal à l’aise'], a: 1, why: 'On évalue des comportements plutôt que des discours.' },
    { q: 'Quel objectif fixer à un nouveau commercial le premier mois ?', options: ['100 % de l’objectif', 'Un objectif progressif (environ 50 %)', 'Aucun objectif', '150 %'], a: 1, why: 'Un objectif progressif permet d’apprendre sans se décourager.' },
    { q: 'Avec la grille de la leçon, pourquoi le candidat A l’emporte-t-il ?', options: ['Il connaît mieux le secteur', 'Il obtient un meilleur score pondéré grâce au jeu de rôle et à la ténacité', 'Il a plus d’expérience', 'Il est moins cher'], a: 1, why: 'La grille pondère davantage les critères clés du poste.' },
    { q: 'Quelle erreur d’intégration a été commise à Libreville ?', options: ['Un tuteur trop présent', 'Pas de matériel, objectif complet immédiat, aucun accompagnement', 'Trop de formation', 'Un bilan à J+30'], a: 1, why: 'Ces erreurs cumulées provoquent un départ rapide.' }
  ]
};
