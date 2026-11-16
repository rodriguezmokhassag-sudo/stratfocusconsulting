# Spot vidéo Mayonnaise NITA × LCC

Spot de 20 s en motion design, inspiré du découpage d'une pub de référence pour une mayonnaise.

| Fichier | Format |
|---|---|
| `videos/NITA_LCC_16x9_4K.mp4` | 3840×2160, 16:9, 30 fps, H.264 + AAC |
| `videos/NITA_LCC_9x16_4K.mp4` | 2160×3840, 9:16 (TikTok / Reels / Statut WhatsApp) |

## Découpage
1. 0–3 s : gros plan sur le couvercle, qui se dévisse et s'envole. Apparition de « NITA Mayonnaise ».
2. 3–6 s : vue de dessus du pot ouvert, la mayo tourne en spirale. Texte « Crémeuse à souhait ».
3. 6–9 s : le bocal sur une table en bois, travelling latéral. Texte « Onctueuse & savoureuse ».
4. 9–12 s : packshot sur fond bleu Nita avec reflet lumineux. Slogan **« Il suffit de goûter ! »**.
5. 12–20 s : le logo LCC s'anime, puis apparaissent les contacts (+242 04 409 59 32 / 04 444 06 90) et
   « Disponible dans tous nos points de vente en République du Congo et chez nos partenaires ».

Musique : afro-house rythmée à 120 BPM, synthétisée intégralement par `source/music.py` (grosse caisse sur chaque temps, log drum, percussions, montées avant chaque plan). Aucun sample tiers, donc libre de droits.

## Régénérer
Dépendances : `pip install pillow numpy scipy opencv-contrib-python-headless`, plus ffmpeg et les polices Poppins dans `fonts/`.
Lancer `bash build.sh` depuis un dossier qui contient `assets/` et `fonts/`.
