# stratfocusconsulting
stratfocusconsulting (stfc) est un cabinet spécialisé dans l'accélération des pme ( petite et micro-entreprise ) et dans la performance commerciale et stratégie marketing 

## Vidéos (Remotion)

Ce dépôt contient un projet [Remotion](https://www.remotion.dev) (modèle Hello World TypeScript) pour produire les vidéos du cabinet : réseaux sociaux, présentation de STFC, études de cas et vidéos personnalisées.

```bash
npm i            # installer les dépendances
npm run dev      # ouvrir Remotion Studio (prévisualisation)
npx remotion render HelloWorld out/video.mp4   # rendre une vidéo
npm run lint     # ESLint + TypeScript
```

- Compositions : `src/Root.tsx`
- Fichiers statiques (logos, musiques) : `public/`
- Les rendus vont dans `out/` (ignoré par git).

> Licence : Remotion est gratuit pour les équipes jusqu'à 3 personnes ; au-delà, une licence entreprise est requise ([détails](https://www.remotion.dev/docs/license/pricing)).
