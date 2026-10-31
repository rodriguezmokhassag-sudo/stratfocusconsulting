# stratfocusconsulting
stratfocusconsulting (stfc) est un cabinet spécialisé dans l'accélération des pme ( petite et micro-entreprise ) et dans la performance commerciale et stratégie marketing

## STFC Academy : plateforme d'apprentissage en ligne

Plateforme 100 % en ligne de formation aux métiers de la performance commerciale et du marketing d'innovation, ciblant l'Afrique francophone.

| Dossier | Contenu |
|---|---|
| [`docs/cahier-de-conception.md`](docs/cahier-de-conception.md) | Conception complète en 13 blocs : benchmark, avis, cible africaine, pédagogie, parcours, tarifs, UX, cadre juridique, technique, croissance, KPI, sources |
| [`platform/`](platform/) | Plateforme fonctionnelle (MVP) : parcours, leçons, quiz, certificats personnalisés |
| [`tools/generer-codes.mjs`](tools/generer-codes.mjs) | Générateur de codes d'accès pour les parcours payants |

### Lancer la plateforme en local

```bash
cd platform && python3 -m http.server 8000
```

Ouvrez ensuite http://localhost:8000. Code de démonstration (débloque tout) : `STFC-DEMO-2026`, à retirer de `platform/assets/js/config.js` avant la mise en production.

### Mettre en ligne (gratuit)

Publiez le dossier `platform/` sur GitHub Pages, Netlify ou Cloudflare Pages. Le HTTPS est requis pour l'activation des codes et le mode hors ligne.

### Personnaliser

- **Numéro WhatsApp, e-mail, signataire du certificat** : `platform/assets/js/config.js`
- **Contenu des cours, quiz, prix** : `platform/assets/js/catalogue.js` (format documenté en tête du fichier)
- **Vidéos résumé** : renseigner `video.src` de chaque module avec l'URL d'intégration (YouTube nocookie, Bunny Stream, Vimeo…)
- **Vendre un parcours** : `node tools/generer-codes.mjs commercial 10`, puis coller les empreintes dans `config.js` et remettre les codes aux acheteurs
