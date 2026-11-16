"""Informations de l'établissement.

Remplir les champs laissés à None puis relancer `python3 generateur/build.py` :
tous les documents sont régénérés avec les nouvelles informations.
Un champ à None est imprimé comme une ligne pointillée à compléter à la main.
"""

ENTREPRISE = {
    "nom": "La Tendresse de Ketchup",
    "type": "Restaurant-Bar",
    "signature": "Restaurant-Bar La Tendresse de Ketchup — La Direction",
    "slogan": "On mange bien, on boit bien, on paie bien.",
    "quartier": "Quartier Diata",
    "rue": None,            # ex. "Rue Mbochi, n° 12"
    "ville": "Brazzaville",
    "pays": "République du Congo",
    "telephone": None,      # ex. "+242 06 000 00 00"
    "whatsapp": None,
    "rccm": None,           # ex. "CG-BZV-01-2026-A-00000"
    "niu": None,            # Numéro d'Identification Unique (impôts)
    "gerant": None,
}

DEVISE = "FCFA"

# Billets et pièces en circulation en zone CEMAC (pour le billetage de la caisse)
BILLETS = [10000, 5000, 2000, 1000, 500]
PIECES = [500, 100, 50, 25, 10, 5]

# Nombre de formulaires numérotés générés par carnet
CARNET_TAILLE = 50
CARNET_DEBUT = 1
