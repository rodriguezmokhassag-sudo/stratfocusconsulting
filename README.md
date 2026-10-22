# G-Clean — site vitrine

Site de G-Clean (marque de SOZACO SARL), fabricant de produits d'entretien professionnels et industriels à Pointe-Noire, Congo.

Domaine : https://www.gclean-congo.com

## Fichiers
- `index.html` : le site complet (une page, sans dépendance)
- `img/` : photos (voir `img/LISEZMOI.md`)
- `CNAME` : nom de domaine pour GitHub Pages
- `robots.txt`, `sitemap.xml` : référencement

## À compléter avant le lancement
Dans `index.html`, en bas du fichier :
1. `NUM` et `AFFICHE` : numéro WhatsApp réel
2. `HOOK` : adresse du webhook n8n (facultatif)

## Mise en ligne (GitHub Pages)
1. Settings → Pages → Source : branche `main`, dossier `/ (root)`
2. Chez le registraire du domaine `gclean-congo.com` :
   - `CNAME` pour `www` → `<utilisateur>.github.io`
   - 4 enregistrements `A` pour `@` → 185.199.108.153, 185.199.109.153, 185.199.110.153, 185.199.111.153
3. Une fois le DNS propagé, cocher « Enforce HTTPS »
