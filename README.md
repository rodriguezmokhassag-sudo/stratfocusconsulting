# G-Clean — site vitrine

Site de G-Clean (marque de SOZACO SARL), fabricant de produits d'entretien professionnels et industriels à Pointe-Noire, Congo.

Domaine : https://www.gclean-congo.com (hébergement LWS)

## Fichiers
- `index.html` : le site complet (une page, sans dépendance)
- `img/` : photos (voir `img/LISEZMOI.md`)
- `robots.txt`, `sitemap.xml` : référencement

## Réglages (en bas de `index.html`)
- `NUM` / `AFFICHE` : numéro WhatsApp (242069740088)
- `HOOK` : webhook n8n du circuit « G-Clean - Devis automatique ».
  Tant que le circuit n'est pas publié, le client est invité à envoyer sa demande par WhatsApp.
- `P` / `DISPO` : produits et formats disponibles. Le formulaire de devis ne propose que les formats existants pour chaque produit.

## Mise en ligne chez LWS
1. Panneau LWS → Gestionnaire de fichiers (ou FTP) → dossier `htdocs`
2. Y déposer `index.html`, `robots.txt`, `sitemap.xml` et le dossier `img`
3. Activer le certificat SSL (Let's Encrypt) du domaine dans le panneau LWS
