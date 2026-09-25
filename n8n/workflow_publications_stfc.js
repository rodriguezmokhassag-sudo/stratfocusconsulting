import { workflow, node, trigger, sticky, newCredential, languageModel, outputParser, expr } from '@n8n/workflow-sdk';

const declencheur = trigger({
  type: 'n8n-nodes-base.scheduleTrigger',
  version: 1.3,
  config: {
    name: 'Jours ouvrés à 7 h',
    parameters: {
      rule: { interval: [{ field: 'cronExpression', expression: '0 0 7 * * 1-5' }] }
    },
    position: [0, 300]
  },
  output: [{ timestamp: '2026-09-28T07:00:00.000+01:00' }]
});

const lireBanque = node({
  type: 'n8n-nodes-base.googleSheets',
  version: 4.7,
  config: {
    name: 'Lire la banque de thèmes',
    parameters: {
      resource: 'sheet',
      operation: 'read',
      authentication: 'oAuth2',
      documentId: { __rl: true, mode: 'list', value: '' },
      sheetName: { __rl: true, mode: 'name', value: 'Banque de thèmes' }
    },
    credentials: { googleSheetsOAuth2Api: newCredential('Google Sheets STFC') },
    position: [220, 300]
  },
  output: [
    { row_number: 2, id: 'T001', pilier: "P1 - Accroître le chiffre d'affaires", theme: "Les 3 leviers du chiffre d'affaires", format: 'conseil', methode_outil: 'Équation du CA', statut: 'à publier', date_utilisation: '' },
    { row_number: 62, id: 'T061', pilier: "P4 - Organiser le service commercial", theme: 'Diagnostiquer son organisation commerciale en 10 questions', format: 'checklist', methode_outil: 'Diagnostic commercial', statut: 'à publier', date_utilisation: '' }
  ]
});

const choisirThemes = node({
  type: 'n8n-nodes-base.code',
  version: 2,
  config: {
    name: 'Choisir les 2 thèmes du jour',
    parameters: {
      mode: 'runOnceForAllItems',
      language: 'javaScript',
      jsCode: "const PLANNING = {\n  1: ['P1', 'P4'],\n  2: ['P2', 'P1'],\n  3: ['P3', 'P2'],\n  4: ['P4', 'P3'],\n  5: ['P5', 'P6'],\n};\nconst CRENEAUX = ['08h00', '12h30'];\nconst aujourdHui = $now.setZone('Africa/Brazzaville');\nconst plan = PLANNING[aujourdHui.weekday];\nif (!plan) return [];\n\nconst lignes = $input.all().map(i => i.json);\nconst dejaPris = new Set();\nconst resultat = [];\n\nplan.forEach((codePilier, index) => {\n  const ligne = lignes.find(l =>\n    String(l.pilier || '').startsWith(codePilier + ' ') &&\n    String(l.statut || '').trim().toLowerCase() === 'à publier' &&\n    !dejaPris.has(l.id)\n  );\n  if (!ligne) return;\n  dejaPris.add(ligne.id);\n  resultat.push({ json: {\n    id: ligne.id,\n    pilier: ligne.pilier,\n    theme: ligne.theme,\n    format: ligne.format,\n    methode_outil: ligne.methode_outil,\n    creneau: CRENEAUX[index],\n    date: aujourdHui.toFormat('dd/MM/yyyy'),\n  } });\n});\n\nreturn resultat;"
    },
    position: [440, 300]
  },
  output: [
    { id: 'T001', pilier: "P1 - Accroître le chiffre d'affaires", theme: "Les 3 leviers du chiffre d'affaires", format: 'conseil', methode_outil: 'Équation du CA', creneau: '08h00', date: '28/09/2026' },
    { id: 'T061', pilier: "P4 - Organiser le service commercial", theme: 'Diagnostiquer son organisation commerciale en 10 questions', format: 'checklist', methode_outil: 'Diagnostic commercial', creneau: '12h30', date: '28/09/2026' }
  ]
});

const modeleDeepSeek = languageModel({
  type: '@n8n/n8n-nodes-langchain.lmChatDeepSeek',
  version: 1,
  config: {
    name: 'DeepSeek',
    parameters: { model: 'deepseek-flash', options: { temperature: 0.8 } },
    credentials: { deepSeekApi: newCredential('DeepSeek') },
    position: [600, 520]
  }
});

const formatPublication = outputParser({
  type: '@n8n/n8n-nodes-langchain.outputParserStructured',
  version: 1.3,
  config: {
    name: 'Format de la publication',
    parameters: {
      schemaType: 'fromJson',
      jsonSchemaExample: "{ \"facebook_post\": \"Texte complet du post Facebook\", \"tiktok_script\": \"Script TikTok de 30 à 45 secondes\", \"image_prompt\": \"Photorealistic image description in English\", \"titre_visuel\": \"Titre de 7 mots maximum\" }"
    },
    position: [780, 520]
  }
});

const rediger = node({
  type: '@n8n/n8n-nodes-langchain.chainLlm',
  version: 1.9,
  config: {
    name: 'Rédiger la publication',
    parameters: {
      promptType: 'define',
      text: expr("PUBLICATION DU JOUR\n- Pilier : {{ $json.pilier }}\n- Thème : {{ $json.theme }}\n- Format : {{ $json.format }}\n- Méthode ou outil à mettre en avant : {{ $json.methode_outil }}\n\nRÈGLES SELON LE FORMAT :\n- conseil : un problème fréquent du dirigeant, puis 3 actions concrètes.\n- méthode : expliquer la méthode en 3 étapes simples + un exemple chiffré « par exemple » en FCFA.\n- erreur : décrire l'erreur, ses conséquences, puis la bonne pratique en 3 points.\n- checklist : 5 à 7 points à cocher (✅), directement applicables cette semaine.\n- question : poser une vraie question aux dirigeants pour faire réagir en commentaire, donner 2 ou 3 pistes de réponse, et inviter à répondre en commentaire.\n\nPRODUIS :\n\n1. facebook_post (150 à 250 mots) :\n- Une accroche percutante sur la 1re ligne, centrée sur un problème de dirigeant.\n- Le corps selon le format ci-dessus.\n- Appel à l'action : {{ $json.creneau === \"08h00\" ? \"« Évaluez gratuitement le niveau de votre équipe commerciale avec la Grille de positionnement STFC (8 blocs de compétences, 210 points) : écrivez-nous sur WhatsApp au 066 000 066 (+242). »\" : \"« Échangeons sur votre situation : écrivez-nous sur WhatsApp au 066 000 066 (+242). »\" }}\n- Terminer par 5 hashtags : #StratFocusConsulting #PerformanceCommerciale #PME + 2 hashtags liés au thème ou au lieu (ex. #ForceDeVente #PointeNoire #Congo).\n\n2. tiktok_script (30 à 45 secondes, à tourner face caméra) :\n- [0-3 s] ACCROCHE : une phrase choc + texte à afficher à l'écran.\n- [3-30 s] CORPS : 2 erreurs fréquentes des PME sur ce thème et la solution rapide.\n- [30-40 s] APPEL À L'ACTION : enregistrer la vidéo, s'abonner, écrire sur WhatsApp.\n- Indique entre crochets les textes à afficher à l'écran.\n\n3. image_prompt (EN ANGLAIS), décrivant une scène ADAPTÉE AU THÈME DU JOUR, avec ces règles :\n- Photorealistic, professional, Central African business setting (Congo), African professionals.\n- Warm, modern and credible atmosphere; subtle navy blue (#0B2468) and gold (#C5A24A) tones.\n- Absolutely NO text, letters, numbers, logos or writing anywhere in the image (no whiteboard writing, no screens with text).\n- Keep the bottom 20% of the image visually simple (space reserved for a branded banner).\n- Square format 1:1, shot on 35mm lens, natural lighting, high detail.\n\n4. titre_visuel : titre de 7 mots maximum, en français, sans emoji, qui sera écrit sur le bandeau de l'image."),
      hasOutputParser: true,
      messages: { messageValues: [{ type: 'SystemMessagePromptTemplate', message: "Tu es l'Expert Senior en Performance Commerciale, Marketing d'Innovation et Transformation Digitale du cabinet STRAT FOCUS CONSULTING (STFC), basé à Pointe-Noire, République du Congo.\nSignature du cabinet : « Parce que votre chiffre d'affaires compte ».\n\nTA CIBLE : les dirigeants de TPE, PE et PME du Congo-Brazzaville et d'Afrique centrale.\n\nTON OBJECTIF : publier du contenu à forte valeur ajoutée qui aide ces dirigeants à :\n1. accroître durablement leur chiffre d'affaires ;\n2. consolider et structurer leur force de vente ;\n3. former et faire monter en compétences leurs commerciaux ;\n4. concevoir ou restructurer une organisation commerciale efficace ;\n5. innover dans leur marketing ;\n6. réussir leur transformation digitale.\n\nTON ET STYLE :\n- Professionnel, pragmatique, orienté résultats, inspirant, ancré dans les réalités du terrain.\n- Vouvoiement du dirigeant, jamais de tutoiement.\n- Exemples concrets adaptés au contexte local : montants en FCFA, commerce de proximité, vente à crédit, Mobile Money, WhatsApp, prospection terrain.\n- Phrases courtes, paragraphes aérés, emojis avec modération (3 à 6 maximum).\n- Pas de mise en forme Markdown (pas d'astérisques ni de dièses de titre) : Facebook ne l'affiche pas.\n\nRÈGLES STRICTES :\n- N'invente AUCUN chiffre, statistique, étude ou citation. Si tu illustres, dis « par exemple ».\n- Ne cite AUCUN client, cas réel ou nom d'entreprise. Pas de faux témoignages.\n- Aucun sujet politique, religieux ou polémique.\n- Reste strictement sur le thème fourni.\n- Quand une méthode est citée (SPIN, SONCAS, BANT, CROC...), explique-la simplement, comme à un dirigeant qui ne la connaît pas." }] },
      batching: { batchSize: 1 }
    },
    subnodes: { model: modeleDeepSeek, outputParser: formatPublication },
    position: [660, 300]
  },
  output: [
    { output: { facebook_post: 'Texte du post 1', tiktok_script: 'Script 1', image_prompt: 'Prompt 1', titre_visuel: 'Titre 1' } },
    { output: { facebook_post: 'Texte du post 2', tiktok_script: 'Script 2', image_prompt: 'Prompt 2', titre_visuel: 'Titre 2' } }
  ]
});

const preparerMail = node({
  type: 'n8n-nodes-base.code',
  version: 2,
  config: {
    name: 'Préparer le mail de validation',
    parameters: {
      mode: 'runOnceForAllItems',
      language: 'javaScript',
      jsCode: "const themes = $('Choisir les 2 thèmes du jour').all().map(i => i.json);\nconst redactions = $input.all().map(i => i.json.output || {});\nconst echapper = t => String(t ?? '').replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');\nconst enHtml = t => echapper(t).replace(/\\n/g, '<br>');\n\nconst publications = themes.map((t, i) => ({ ...t, ...redactions[i] }));\n\nconst blocs = publications.map(p => [\n  '<div style=\"border:1px solid #C5A24A;border-radius:8px;padding:16px;margin:0 0 24px\">',\n  '<h2 style=\"margin:0 0 4px;color:#0B2468\">🕗 Publication de ' + echapper(p.creneau) + '</h2>',\n  '<p style=\"margin:0 0 12px;color:#666\">' + echapper(p.pilier) + ' · ' + echapper(p.format) + ' · ' + echapper(p.id) + '<br><b>Thème :</b> ' + echapper(p.theme) + '</p>',\n  '<p style=\"margin:0 0 4px\"><b>Titre du visuel :</b> ' + echapper(p.titre_visuel) + '</p>',\n  '<h3 style=\"color:#0B2468\">📘 Post Facebook</h3>',\n  '<div style=\"background:#f7f7f7;padding:12px;border-radius:6px\">' + enHtml(p.facebook_post) + '</div>',\n  '<h3 style=\"color:#0B2468\">🎬 Script TikTok</h3>',\n  '<div style=\"background:#f7f7f7;padding:12px;border-radius:6px\">' + enHtml(p.tiktok_script) + '</div>',\n  \"<h3 style=\\\"color:#0B2468\\\">🖼️ Description de l'image</h3>\",\n  '<div style=\"color:#666;font-size:13px\">' + enHtml(p.image_prompt) + '</div>',\n  '</div>'\n].join(''));\n\nconst message = '<div style=\"font-family:Arial,sans-serif;color:#222\">'\n  + '<p>Bonjour, voici les ' + publications.length + \" publications prévues aujourd'hui. Validez-les ou rejetez-les avec les boutons en bas du mail.</p>\"\n  + blocs.join('')\n  + '</div>';\n\nreturn [{ json: {\n  sujet: '📣 ' + publications.length + ' publication(s) STFC à valider – ' + (publications[0]?.date ?? ''),\n  message,\n  publications,\n} }];"
    },
    position: [900, 300]
  },
  output: [{ sujet: '📣 2 publication(s) STFC à valider – 28/09/2026', message: '<div>...</div>', publications: [{ id: 'T001', creneau: '08h00', date: '28/09/2026', pilier: "P1 - Accroître le chiffre d'affaires", theme: 'Thème', format: 'conseil', facebook_post: 'Texte', tiktok_script: 'Script', image_prompt: 'Prompt', titre_visuel: 'Titre' }] }]
});

const demanderValidation = node({
  type: 'n8n-nodes-base.emailSend',
  version: 2.1,
  config: {
    name: 'Demander la validation par mail',
    parameters: {
      resource: 'email',
      operation: 'sendAndWait',
      fromEmail: 'Publications STFC <dg@stratfocus-consulting.com>',
      toEmail: 'admin@stratfocus-consulting.com',
      subject: expr('{{ $json.sujet }}'),
      message: expr('{{ $json.message }}'),
      responseType: 'approval',
      approvalOptions: {
        values: {
          approvalType: 'double',
          approveLabel: '✅ Valider les publications',
          buttonApprovalStyle: 'primary',
          disapproveLabel: '❌ Rejeter',
          buttonDisapprovalStyle: 'secondary'
        }
      },
      options: {
        appendAttribution: false,
        limitWaitTime: { values: { limitType: 'afterTimeInterval', resumeAmount: 5, resumeUnit: 'hours' } }
      }
    },
    credentials: { smtp: newCredential('SMTP LWS admin') },
    position: [1120, 300]
  },
  output: [{ data: { approved: true } }]
});

const preparerSuivi = node({
  type: 'n8n-nodes-base.code',
  version: 2,
  config: {
    name: 'Préparer le suivi',
    parameters: {
      mode: 'runOnceForAllItems',
      language: 'javaScript',
      jsCode: "const reponse = $input.first().json.data?.approved;\nconst decision = reponse === true ? 'validé' : reponse === false ? 'rejeté' : 'sans réponse';\nconst publications = $('Préparer le mail de validation').first().json.publications;\n\nreturn publications.map(p => ({ json: {\n  ...p,\n  decision,\n  statut_banque: decision === 'sans réponse' ? 'à publier' : decision,\n  date_banque: decision === 'sans réponse' ? '' : p.date,\n} }));"
    },
    position: [1340, 300]
  },
  output: [{ id: 'T001', creneau: '08h00', date: '28/09/2026', pilier: "P1 - Accroître le chiffre d'affaires", theme: 'Thème', format: 'conseil', facebook_post: 'Texte', tiktok_script: 'Script', image_prompt: 'Prompt', titre_visuel: 'Titre', decision: 'validé', statut_banque: 'validé', date_banque: '28/09/2026' }]
});

const majBanque = node({
  type: 'n8n-nodes-base.googleSheets',
  version: 4.7,
  config: {
    name: 'Marquer les thèmes utilisés',
    parameters: {
      resource: 'sheet',
      operation: 'update',
      authentication: 'oAuth2',
      documentId: { __rl: true, mode: 'list', value: '' },
      sheetName: { __rl: true, mode: 'name', value: 'Banque de thèmes' },
      columns: {
        mappingMode: 'defineBelow',
        matchingColumns: ['id'],
        value: {
          id: expr('{{ $json.id }}'),
          statut: expr('{{ $json.statut_banque }}'),
          date_utilisation: expr('{{ $json.date_banque }}')
        },
        schema: [
          { id: "id", displayName: "id", required: false, defaultMatch: false, display: true, type: 'string', canBeUsedToMatch: true },
          { id: "statut", displayName: "statut", required: false, defaultMatch: false, display: true, type: 'string', canBeUsedToMatch: false },
          { id: "date_utilisation", displayName: "date_utilisation", required: false, defaultMatch: false, display: true, type: 'string', canBeUsedToMatch: false }
        ]
      },
      options: {}
    },
    credentials: { googleSheetsOAuth2Api: newCredential('Google Sheets STFC') },
    position: [1560, 200]
  },
  output: [{ id: 'T001', statut: 'validé', date_utilisation: '28/09/2026' }]
});

const ajouterHistorique = node({
  type: 'n8n-nodes-base.googleSheets',
  version: 4.7,
  config: {
    name: "Ajouter à l'historique",
    parameters: {
      resource: 'sheet',
      operation: 'append',
      authentication: 'oAuth2',
      documentId: { __rl: true, mode: 'list', value: '' },
      sheetName: { __rl: true, mode: 'name', value: 'Historique' },
      columns: {
        mappingMode: 'defineBelow',
        value: {
          date: expr("{{ $json.date }}"),
          creneau: expr("{{ $json.creneau }}"),
          id_theme: expr("{{ $json.id }}"),
          pilier: expr("{{ $json.pilier }}"),
          theme: expr("{{ $json.theme }}"),
          format: expr("{{ $json.format }}"),
          decision: expr("{{ $json.decision }}"),
          titre_visuel: expr("{{ $json.titre_visuel }}"),
          facebook_post: expr("{{ $json.facebook_post }}"),
          tiktok_script: expr("{{ $json.tiktok_script }}"),
          image_prompt: expr("{{ $json.image_prompt }}")
        },
        schema: [
          { id: "date", displayName: "date", required: false, defaultMatch: false, display: true, type: 'string', canBeUsedToMatch: false },
          { id: "creneau", displayName: "creneau", required: false, defaultMatch: false, display: true, type: 'string', canBeUsedToMatch: false },
          { id: "id_theme", displayName: "id_theme", required: false, defaultMatch: false, display: true, type: 'string', canBeUsedToMatch: false },
          { id: "pilier", displayName: "pilier", required: false, defaultMatch: false, display: true, type: 'string', canBeUsedToMatch: false },
          { id: "theme", displayName: "theme", required: false, defaultMatch: false, display: true, type: 'string', canBeUsedToMatch: false },
          { id: "format", displayName: "format", required: false, defaultMatch: false, display: true, type: 'string', canBeUsedToMatch: false },
          { id: "decision", displayName: "decision", required: false, defaultMatch: false, display: true, type: 'string', canBeUsedToMatch: false },
          { id: "titre_visuel", displayName: "titre_visuel", required: false, defaultMatch: false, display: true, type: 'string', canBeUsedToMatch: false },
          { id: "facebook_post", displayName: "facebook_post", required: false, defaultMatch: false, display: true, type: 'string', canBeUsedToMatch: false },
          { id: "tiktok_script", displayName: "tiktok_script", required: false, defaultMatch: false, display: true, type: 'string', canBeUsedToMatch: false },
          { id: "image_prompt", displayName: "image_prompt", required: false, defaultMatch: false, display: true, type: 'string', canBeUsedToMatch: false }
        ]
      },
      options: {}
    },
    credentials: { googleSheetsOAuth2Api: newCredential('Google Sheets STFC') },
    position: [1560, 400]
  },
  output: [{ date: '28/09/2026', creneau: '08h00', id_theme: 'T001' }]
});

const noteFonctionnement = sticky("## 📣 Publications STFC – fonctionnement\nDu lundi au vendredi à **7 h** (heure de Brazzaville) :\n1. Lecture de la banque de thèmes (Google Sheet).\n2. Choix des 2 thèmes du jour selon le planning (8 h 00 et 12 h 30).\n3. Rédaction par DeepSeek avec le prompt Expert v2 (post Facebook, script TikTok, image, titre).\n4. **Un seul mail** à admin@stratfocus-consulting.com avec les boutons Valider / Rejeter (attente max 5 h).\n5. Mise à jour de la banque (validé / rejeté) et ajout à l'onglet Historique. Sans réponse, les thèmes restent « à publier ».\n\nPlanning : lun P1/P4 · mar P2/P1 · mer P3/P2 · jeu P4/P3 · ven P5/P6", [declencheur, lireBanque, choisirThemes, rediger, preparerMail, demanderValidation, preparerSuivi, majBanque, ajouterHistorique], { color: 4 });

const noteConfiguration = sticky("## ⚙️ À configurer avant d'activer\n1. **Fuseau horaire** : menu ⋯ > Settings > Timezone = **Africa/Brazzaville**.\n2. **Google Sheet** : importer `banque_themes.csv` dans un onglet nommé **Banque de thèmes** ; créer un onglet **Historique** avec en ligne 1 : date | creneau | id_theme | pilier | theme | format | decision | titre_visuel | facebook_post | tiktok_script | image_prompt. Puis connecter le compte Google et choisir le fichier dans les 3 nœuds Google Sheets.\n3. **DeepSeek** : clé API (platform.deepseek.com > API keys).\n4. **SMTP LWS** : admin@stratfocus-consulting.com, hôte SMTP indiqué dans l'espace LWS, port 465, SSL activé.\n5. Tester avec **Execute workflow**, puis activer.", [], { color: 3, position: [0, 700], width: 900, height: 320 });

export default workflow('stfc-publications', 'Publications STFC – rédaction et validation quotidienne')
  .add(declencheur)
  .to(lireBanque)
  .to(choisirThemes)
  .to(rediger)
  .to(preparerMail)
  .to(demanderValidation)
  .to(preparerSuivi)
  .add(preparerSuivi)
  .to(majBanque)
  .add(preparerSuivi)
  .to(ajouterHistorique)
  .add(noteFonctionnement)
  .add(noteConfiguration);
