#!/usr/bin/env python3
"""Générateur du site HEMIP (français + anglais).

Tout le contenu est ici, dans les deux langues. Lancer :
    python3 build.py
Les pages sont écrites dans ../site (français à la racine, anglais dans /en).
"""
from pathlib import Path
from html import escape

SITE = Path(__file__).resolve().parent.parent / "site"

# ---------------------------------------------------------------- RÉGLAGES
DOMAINE = "https://www.hemip-congo.com"   # à remplacer par le vrai nom de domaine
TEL1, TEL1_AFF = "+242069149242", "+242 06 914 92 42"
TEL2, TEL2_AFF = "+242053560672", "+242 05 356 06 72"
WA, WA_AFF = "242055865094", "+242 05 586 50 94"
EMAIL = "hemilaperceeinformation@gmail.com"
AGREMENT = "0454 MES-CAB.DGESUP.DAAC"
RENTREE = {"fr": "", "en": ""}           # ex. {"fr": "Octobre 2027", "en": "October 2027"} ; vide = masqué
FACEBOOK = ""                             # lien de la page Facebook ; vide = masqué

# ---------------------------------------------------------------- PAGES
PAGES = [  # clé, fichier FR, fichier EN, libellé FR, libellé EN
    ("accueil", "index.html", "index.html", "Accueil", "Home"),
    ("filieres", "filieres.html", "programs.html", "Filières", "Programs"),
    ("recherche", "recherche.html", "research.html", "Recherche", "Research"),
    ("vie", "vie-etudiante.html", "student-life.html", "Vie étudiante", "Student life"),
    ("partenaires", "partenaires.html", "partners.html", "Partenaires", "Partners"),
    ("admissions", "admissions.html", "admissions.html", "Admissions", "Admissions"),
    ("contact", "contact.html", "contact.html", "Contact", "Contact"),
]
P = {k: {"fr": f, "en": e, "lfr": lf, "len": le} for k, f, e, lf, le in PAGES}
# Sous-menu de l'accueil : une page par rubrique
SOUS_PAGES = [  # clé, fichier FR, fichier EN, libellé FR, libellé EN
    ("vision", "vision.html", "vision.html", "Notre vision", "Our vision"),
    ("mission", "mission.html", "mission.html", "Notre mission", "Our mission"),
    ("valeurs", "valeurs.html", "values.html", "Nos valeurs", "Our values"),
    ("directeur", "mot-du-directeur.html", "director.html", "Le mot du directeur", "A word from the director"),
    ("campus", "campus.html", "campus.html", "Le campus", "The campus"),
]
P.update({k: {"fr": f, "en": e, "lfr": lf, "len": le} for k, f, e, lf, le in SOUS_PAGES})
SOUS_CLES = [k for k, *_ in SOUS_PAGES]


def lien(lang, cle, depuis=None):
    """Lien relatif vers la page `cle` dans la langue `lang`, depuis une page en `depuis`."""
    depuis = depuis or lang
    f = P[cle][lang]
    if lang == depuis:
        return f
    return ("en/" + f) if lang == "en" else ("../" + f)


def T(fr, en):
    return {"fr": fr, "en": en}


# ---------------------------------------------------------------- ICÔNES
def ico(nom):
    d = {
        "chapeau": '<path d="M2 9l10-5 10 5-10 5z"/><path d="M6 11v5c0 1.5 3 3 6 3s6-1.5 6-3v-5"/><path d="M22 9v6"/>',
        "engrenage": '<circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.7 1.7 0 0 0 .3 1.8l.1.1a2 2 0 1 1-2.8 2.8l-.1-.1a1.7 1.7 0 0 0-1.8-.3 1.7 1.7 0 0 0-1 1.5V21a2 2 0 1 1-4 0v-.1a1.7 1.7 0 0 0-1.1-1.5 1.7 1.7 0 0 0-1.8.3l-.1.1a2 2 0 1 1-2.8-2.8l.1-.1a1.7 1.7 0 0 0 .3-1.8 1.7 1.7 0 0 0-1.5-1H3a2 2 0 1 1 0-4h.1a1.7 1.7 0 0 0 1.5-1.1 1.7 1.7 0 0 0-.3-1.8l-.1-.1a2 2 0 1 1 2.8-2.8l.1.1a1.7 1.7 0 0 0 1.8.3H9a1.7 1.7 0 0 0 1-1.5V3a2 2 0 1 1 4 0v.1a1.7 1.7 0 0 0 1 1.5 1.7 1.7 0 0 0 1.8-.3l.1-.1a2 2 0 1 1 2.8 2.8l-.1.1a1.7 1.7 0 0 0-.3 1.8V9a1.7 1.7 0 0 0 1.5 1H21a2 2 0 1 1 0 4h-.1a1.7 1.7 0 0 0-1.5 1z"/>',
        "mallette": '<rect x="2" y="7" width="20" height="14" rx="2"/><path d="M16 7V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v2"/><path d="M2 13h20"/>',
        "fiole": '<path d="M9 3h6"/><path d="M10 3v6L4.5 18.5A1.7 1.7 0 0 0 6 21h12a1.7 1.7 0 0 0 1.5-2.5L14 9V3"/><path d="M7 15h10"/>',
        "monde": '<circle cx="12" cy="12" r="10"/><path d="M2 12h20"/><path d="M12 2a15 15 0 0 1 0 20 15 15 0 0 1 0-20"/>',
        "horloge": '<circle cx="12" cy="12" r="10"/><path d="M12 6v6l4 2"/>',
        "langue": '<path d="M5 8l6 6"/><path d="M4 14l6-6 2-3"/><path d="M2 5h12"/><path d="M7 2h1"/><path d="M22 22l-5-10-5 10"/><path d="M14 18h6"/>',
        "groupe": '<path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.9"/><path d="M16 3.1a4 4 0 0 1 0 7.8"/>',
        "fusee": '<path d="M4.5 16.5c-1.5 1.3-2 5-2 5s3.7-.5 5-2c.7-.8.7-2.1-.1-2.9a2.2 2.2 0 0 0-2.9-.1z"/><path d="M12 15l-3-3a22 22 0 0 1 2-4A13 13 0 0 1 22 2c0 2.7-.8 7.5-6 11a22 22 0 0 1-4 2z"/><path d="M9 12H4s.6-3 2-4c1.6-1.1 5 0 5 0"/><path d="M12 15v5s3-.6 4-2c1.1-1.6 0-5 0-5"/>',
        "ampoule": '<path d="M9 18h6"/><path d="M10 22h4"/><path d="M12 2a7 7 0 0 0-4 12.7V17h8v-2.3A7 7 0 0 0 12 2z"/>',
        "bourse": '<circle cx="12" cy="8" r="6"/><path d="M15.5 13.5L17 22l-5-3-5 3 1.5-8.5"/>',
        "usine": '<path d="M2 20h20"/><path d="M4 20V10l5 3V10l5 3V6l6 4v10"/><path d="M8 17h1M13 17h1M18 17h1"/>',
        "soleil": '<circle cx="12" cy="12" r="4"/><path d="M12 2v2M12 20v2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M2 12h2M20 12h2M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4"/>',
        "goutte": '<path d="M12 2.7l5.7 5.6a8 8 0 1 1-11.4 0z"/>',
        "recyclage": '<path d="M7 19H4.8a1.8 1.8 0 0 1-1.6-2.7L7.2 9.5"/><path d="M11 19h8.2a1.8 1.8 0 0 0 1.6-2.7l-1.2-2.1"/><path d="M14 16l-3 3 3 3"/><path d="M8.3 13.6L7.2 9.5 3.1 10.6"/><path d="M9.3 5.3l1.1-1.9a1.8 1.8 0 0 1 3.1 0l3.9 6.8"/><path d="M13.4 9.1l4.1 1.1 1.1-4.1"/>',
        "eclair": '<path d="M13 2L3 14h9l-1 8 10-12h-9z"/>',
        "code": '<path d="M16 18l6-6-6-6"/><path d="M8 6l-6 6 6 6"/>',
        "pioche": '<path d="M14.5 6.5L3 18l3 3 11.5-11.5"/><path d="M9 3c4 0 9 2.5 12 7-2-1-4-1.5-6-1.5"/><path d="M15 9c0-2-.5-4-1.5-6"/>',
        "presentation": '<path d="M2 3h20"/><path d="M3 3v11a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V3"/><path d="M12 16v5M8 21h8"/><path d="M8 11l3-3 2 2 3-3"/>',
        "bus": '<rect x="3" y="4" width="18" height="13" rx="2"/><path d="M3 11h18"/><circle cx="7.5" cy="19.5" r="1.5"/><circle cx="16.5" cy="19.5" r="1.5"/>',
        "fete": '<path d="M5.8 11.3L2 22l10.7-3.8"/><path d="M4 3h.01M22 8h.01M15 2h.01M22 20h.01"/><path d="M22 2l-2.2.8a2.9 2.9 0 0 0-1.9 3.1v0c.1.9-.6 1.6-1.4 1.6h-.4c-.9 0-1.6.7-1.6 1.6V10"/><path d="M11 13c1.9 1.9 2.4 4.4 1.2 5.6-1.2 1.2-3.7.7-5.6-1.2-1.9-1.9-2.4-4.4-1.2-5.6 1.2-1.2 3.7-.7 5.6 1.2z"/>',
        "batiment": '<path d="M3 21h18"/><path d="M5 21V7l7-4 7 4v14"/><path d="M9 9h1M14 9h1M9 13h1M14 13h1M9 17h1M14 17h1"/>',
        "poignee": '<path d="M11 17l2 2a1 1 0 1 0 3-3"/><path d="M14 14l2.5 2.5a1 1 0 1 0 3-3l-3.9-3.9a3 3 0 0 0-4.2 0l-.9.9a1 1 0 1 1-3-3l2.8-2.8a5.8 5.8 0 0 1 7.1-.9l.5.3a4 4 0 0 0 2.8.5L21 4"/><path d="M21 3l1 11h-2"/><path d="M3 3L2 14l6.5 6.5a1 1 0 1 0 3-3"/><path d="M3 4h8"/>',
        "photo": '<rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="9" cy="9" r="2"/><path d="M21 15l-5-5L5 21"/>',
        "lieu": '<path d="M20 10c0 6-8 12-8 12S4 16 4 10a8 8 0 0 1 16 0z"/><circle cx="12" cy="10" r="3"/>',
        "tel": '<path d="M22 16.9v3a2 2 0 0 1-2.2 2 19.8 19.8 0 0 1-8.6-3.1 19.5 19.5 0 0 1-6-6A19.8 19.8 0 0 1 2.1 4.2 2 2 0 0 1 4.1 2h3a2 2 0 0 1 2 1.7c.1.9.4 1.9.7 2.8a2 2 0 0 1-.5 2.1L8 9.9a16 16 0 0 0 6 6l1.3-1.3a2 2 0 0 1 2.1-.4c.9.3 1.8.6 2.8.7a2 2 0 0 1 1.7 2z"/>',
        "mail": '<rect x="2" y="4" width="20" height="16" rx="2"/><path d="M22 6l-10 7L2 6"/>',
        "fleche": '<path d="M5 12h14"/><path d="M12 5l7 7-7 7"/>',
        "medaille": '<circle cx="12" cy="9" r="6"/><path d="M9 14.5L7 22l5-3 5 3-2-7.5"/><path d="M10 9l1.5 1.5L14.5 7.5"/>',
        "livre": '<path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20V3H6.5A2.5 2.5 0 0 0 4 5.5z"/><path d="M4 19.5A2.5 2.5 0 0 0 6.5 22H20v-5"/>',
    }
    if nom == "whatsapp":
        return ('<svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M17.5 14.4c-.3-.1-1.8-.9-2-1-.3-.1-.5-.1-.7.1-.2.3-.8 1-.9 1.2-.2.2-.3.2-.6.1-.3-.1-1.3-.5-2.4-1.5-.9-.8-1.5-1.8-1.7-2.1-.2-.3 0-.5.1-.6l.4-.5c.2-.2.2-.3.3-.5.1-.2 0-.4 0-.5l-.9-2.2c-.2-.6-.5-.5-.7-.5h-.6c-.2 0-.5.1-.8.4-.3.3-1 1-1 2.5s1.1 2.9 1.2 3.1c.1.2 2.1 3.2 5.1 4.5.7.3 1.3.5 1.7.6.7.2 1.4.2 1.9.1.6-.1 1.8-.7 2-1.4.2-.7.2-1.3.2-1.4-.1-.2-.3-.3-.6-.4zM12 21.8c-1.8 0-3.5-.5-5-1.4l-.4-.2-3.7 1 1-3.6-.2-.4A9.8 9.8 0 0 1 2.2 12 9.8 9.8 0 0 1 12 2.2a9.8 9.8 0 0 1 9.8 9.8 9.8 9.8 0 0 1-9.8 9.8zm8.4-18.2A11.8 11.8 0 0 0 12 .2 11.8 11.8 0 0 0 1.8 17.9L.1 24l6.3-1.7a11.8 11.8 0 0 0 5.6 1.4A11.8 11.8 0 0 0 23.8 12c0-3.2-1.2-6.1-3.4-8.4z"/></svg>')
    return ('<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" '
            'stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">' + d[nom] + "</svg>")


# ---------------------------------------------------------------- DONNÉES
FILIERES = [
    # code, parcours ("ges" | "ind"), nom, débouchés
    ("MRH", "ges", T("Management des Ressources Humaines", "Human Resources Management"),
     T(["Collaborateur administratif et social en cabinet RH", "Gestionnaire d'emploi", "Assistant de gestion du personnel", "Assistant RH"],
       ["Administrative and HR officer in an HR firm", "Employment officer", "Personnel management assistant", "HR assistant"])),
    ("GFC", "ges", T("Gestion Financière et Comptable", "Finance and Accounting"),
     T(["Collaborateur de cabinet d'expertise comptable", "Collaborateur d'auditeur", "Assistant contrôleur de gestion", "Assistant de direction administrative et financière"],
       ["Associate in a chartered accounting firm", "Audit associate", "Assistant management controller", "Administrative and finance department assistant"])),
    ("BFA", "ges", T("Banque, Finance, Assurances", "Banking, Finance and Insurance"),
     T(["Agent des opérations bancaires", "Chargé de clientèle particuliers et PME", "Chargé d'études actuarielles", "Agent de bureau d'assurances"],
       ["Banking operations officer", "Retail and SME client advisor", "Actuarial analyst", "Insurance office agent"])),
    ("CIT", "ges", T("Commerce International et Transit", "International Trade and Freight Forwarding"),
     T(["Responsable de transit", "Responsable export-import", "Responsable douane", "Responsable du négoce international", "Commissionnaire en douane"],
       ["Freight forwarding manager", "Import-export manager", "Customs manager", "International trade manager", "Customs broker"])),
    ("DAE", "ges", T("Droit des Affaires et des Entreprises", "Business and Corporate Law"),
     T(["Assistant juridique en cabinet", "Conseiller juridique en entreprise", "Conseiller juridique en assurances et établissements de crédit"],
       ["Legal assistant in a law firm", "In-house legal advisor", "Legal advisor for insurers and lenders"])),
    ("LT", "ges", T("Logistique et Transport", "Logistics and Transport"),
     T(["Responsable logistique et transport", "Consultant logistique", "Gestionnaire des stocks et approvisionnements", "Gestionnaire de réseaux d'entrepôts et de plateformes"],
       ["Logistics and transport manager", "Logistics consultant", "Inventory and procurement manager", "Warehouse and hub network manager"])),
    ("MI", "ind", T("Maintenance Industrielle", "Industrial Maintenance"),
     T(["Technicien supérieur en maintenance industrielle"],
       ["Senior industrial maintenance technician"])),
    ("EE", "ind", T("Électrotechnique et Électronique", "Electrical Engineering and Electronics"),
     T(["Technicien supérieur en électrotechnique et électronique", "Technicien de maintenance électronique et instrumentation", "Technicien en production et distribution d'énergie électrique"],
       ["Senior electrical and electronics technician", "Electronics and instrumentation maintenance technician", "Power generation and distribution technician"])),
    ("AII", "ind", T("Automatisation et Informatique Industrielle", "Automation and Industrial Computing"),
     T(["Technicien supérieur en automatisme industriel", "Automaticien", "Technicien en robotique industrielle", "Technicien en réseaux industriels"],
       ["Senior industrial automation technician", "Automation specialist", "Industrial robotics technician", "Industrial networks technician"])),
    ("GL", "ind", T("Génie Logiciel", "Software Engineering"),
     T(["Administrateur de bases de données", "Développeur de sites web", "Gestionnaire des réseaux informatiques", "Architecte des systèmes de communication et d'information", "Infographiste", "Assistant ingénieur en informatique de gestion"],
       ["Database administrator", "Web developer", "IT network manager", "Information and communication systems architect", "Graphic designer", "Assistant engineer in business computing"])),
    ("RT", "ind", T("Réseaux et Télécommunications", "Networks and Telecommunications"),
     T(["Technicien supérieur en réseaux informatiques et télécoms"],
       ["Senior IT networks and telecoms technician"])),
    ("GP", "ind", T("Génie Pétrolier", "Petroleum Engineering"),
     T(["Technicien supérieur de gisement", "Technicien supérieur de forage", "Technicien supérieur de complétion", "Technicien de procédés"],
       ["Senior reservoir technician", "Senior drilling technician", "Senior completion technician", "Process technician"])),
    ("GC", "ind", T("Génie Chimique", "Chemical Engineering"),
     T(["Technicien supérieur pour le contrôle des procédés dans l'industrie chimique : brasserie, savonnerie, cimenterie, production d'eau"],
       ["Senior process control technician in the chemical industry: breweries, soap factories, cement plants, water production"])),
    ("RP", "ind", T("Raffinage et Pétrochimie", "Refining and Petrochemicals"),
     T(["Technicien supérieur pour le contrôle des procédés pétrochimiques en raffinerie et en usine pétrochimique", "Transformation du pétrole et de ses sous-produits"],
       ["Senior petrochemical process control technician in refineries and petrochemical plants", "Processing of crude oil and its by-products"])),
    ("ENR", "ind", T("Énergies Renouvelables", "Renewable Energy"),
     T(["Technicien supérieur dans les compagnies de production d'électricité à partir de sources renouvelables", "Installation de systèmes solaires photovoltaïques"],
       ["Senior technician in renewable power generation companies", "Installation of solar photovoltaic systems"])),
]
PROCEDES = {"GP", "GC", "RP", "ENR"}  # sous-ensemble « Génie des procédés »

RAISONS = [
    T(("Système LMD et enseignants qualifiés", "Des professeurs résidents et invités, et des formateurs titulaires au minimum d'un Master."),
      ("LMD system and qualified lecturers", "Resident and visiting professors, and trainers who hold at least a Master's degree.")),
    T(("Enseignement bilingue", "Cours en français et en anglais, en particulier pour les matières de base et le génie des procédés."),
      ("Bilingual teaching", "Courses in French and English, especially for core subjects and process engineering.")),
    T(("La pratique avant tout", "Laboratoires de chimie, de génie des procédés et d'informatique, ateliers d'électromécanique et d'électronique, en classes réduites."),
      ("Hands-on learning", "Chemistry, process engineering and computer labs, electromechanics and electronics workshops, in small classes.")),
    T(("Horaires flexibles", "Deux vacations au choix : cours du jour ou cours du soir, pour étudier en travaillant."),
      ("Flexible schedules", "Choose day or evening classes, so you can study while working.")),
    T(("Une école de proximité", "Au centre-ville de Pointe-Noire, une institution proche de sa communauté."),
      ("A school close to you", "In downtown Pointe-Noire, an institution close to its community.")),
    T(("Une recherche utile", "Une recherche de pointe avec des impacts réels sur les besoins de nos communautés."),
      ("Research that matters", "Advanced research with real impact on the needs of our communities.")),
    T(("Des stages en entreprise", "Stages facilités grâce à nos partenariats avec CORAF, SNPC, TotalEnergies, Eni Congo, Dangote, Saris, La Congolaise des Eaux…"),
      ("Company internships", "Internships made easier through our partnerships with CORAF, SNPC, TotalEnergies, Eni Congo, Dangote, Saris, La Congolaise des Eaux…")),
    T(("Des stages qui mènent à l'emploi", "Plusieurs de nos stagiaires ont déjà signé des CDD et des CDI."),
      ("Internships that lead to jobs", "Several of our interns have already signed fixed-term and permanent contracts.")),
    T(("Esprit d'entreprendre", "La qualité de l'enseignement prépare nos étudiants à créer leur propre entreprise."),
      ("Entrepreneurial mindset", "The quality of our teaching prepares students to launch their own start-ups.")),
    T(("Des bourses au mérite", "Des bourses d'études sont possibles pour les étudiants les plus méritants."),
      ("Merit scholarships", "Scholarships are available for the most deserving students.")),
]

PART_ACAD = [
    ("ENGDE", T("France", "France"), T("École de Gestion et d'Expertise Comptable", "School of Management and Chartered Accountancy")),
    ("HESTIM", T("Maroc", "Morocco"), T("École des Hautes Études des Sciences et Technologies de l'Ingénierie et du Management", "School of Advanced Studies in Engineering Sciences, Technology and Management")),
    ("ISTA", T("RD Congo", "DR Congo"), T("Institut Supérieur des Techniques Appliquées de Kinshasa", "Higher Institute of Applied Techniques, Kinshasa")),
    ("IPSAS", T("Tunisie", "Tunisia"), T("Institut Polytechnique des Sciences Avancées de Sfax", "Polytechnic Institute of Advanced Sciences, Sfax")),
]
# Logos : site/img/partenaires/<nom>.png (écoles) et site/img/entreprises/<nom>.png (entreprises).
# Une entreprise sans fichier logo s'affiche avec son nom.
LOGOS_ENT = {"CORAF": "coraf", "SNPC": "snpc", "TotalEnergies": "totalenergies", "Eni Congo": "eni", "Perenco": "perenco",
             "Dangote": "dangote", "Saris Congo": "saris", "La Congolaise des Eaux": "lcde", "E2C": "e2c", "Brasco": "brasco"}


def logo_entreprise(nom):
    f = LOGOS_ENT.get(nom)
    return f"img/entreprises/{f}.png" if f and (SITE / "img" / "entreprises" / f"{f}.png").exists() else None


ENTREPRISES = [
    ("CORAF", T("Raffinage", "Refining")), ("SNPC", T("Pétrole", "Oil")), ("TotalEnergies", T("Énergie", "Energy")),
    ("Eni Congo", T("Énergie", "Energy")), ("Perenco", T("Pétrole", "Oil")), ("Dangote", T("Ciment", "Cement")),
    ("Saris Congo", T("Agro-industrie", "Agro-industry")), ("La Congolaise des Eaux", T("Eau", "Water")),
    ("E2C", T("Électricité", "Electricity")), ("Brasco", T("Brasseries du Congo", "Brasseries du Congo")),
    (T("Banques", "Banks"), T("Publiques et privées", "Public and private")),
]


# ---------------------------------------------------------------- GABARIT
def page(lang, cle, titre, description, contenu, jsonld=""):
    pre = "" if lang == "fr" else "../"
    autre = "en" if lang == "fr" else "fr"
    nom_page = P[cle]["l" + lang]
    titre_complet = (f"HEMIP — {titre}" if cle != "accueil" else titre)
    url = DOMAINE + "/" + ("" if lang == "fr" else "en/") + (P[cle][lang] if P[cle][lang] != "index.html" else "")
    url_fr = DOMAINE + "/" + (P[cle]["fr"] if P[cle]["fr"] != "index.html" else "")
    url_en = DOMAINE + "/en/" + (P[cle]["en"] if P[cle]["en"] != "index.html" else "")

    nav = []
    for k, *_ in PAGES:
        if k in ("admissions",):
            continue
        cur = ' aria-current="page"' if (k == cle or (k == "accueil" and cle in SOUS_CLES)) else ""
        if k == "accueil":
            sous = "".join(f'<a href="{lien(lang, s)}"{" aria-current=page" if s == cle else ""}>{P[s]["l" + lang]}</a>' for s in SOUS_CLES)
            nav.append(f'<div class="menu-parent"><a href="{lien(lang, k)}"{cur} aria-haspopup="true">{P[k]["l" + lang]}'
                       f'<svg class="chevron" viewBox="0 0 24 24" aria-hidden="true"><path d="M6 9l6 6 6-6"/></svg></a>'
                       f'<div class="sous-menu">{sous}</div></div>')
            continue
        nav.append(f'<a href="{lien(lang, k)}"{cur}>{P[k]["l" + lang]}</a>')
    nav.append(f'<a class="btn btn-rouge" href="{lien(lang, "admissions")}"'
               f'{" aria-current=page" if cle == "admissions" else ""}>'
               f'{"Pré-inscription" if lang == "fr" else "Apply now"}</a>')

    lang_switch = (f'<span>FR</span><a href="{lien("en", cle, "fr")}" hreflang="en" lang="en">EN</a>' if lang == "fr"
                   else f'<a href="{lien("fr", cle, "en")}" hreflang="fr" lang="fr">FR</a><span>EN</span>')

    L = (lambda fr, en: fr if lang == "fr" else en)
    fb = f'<li><a href="{FACEBOOK}" rel="noopener" target="_blank">Facebook</a></li>' if FACEBOOK else ""

    return f"""<!doctype html>
<html lang="{lang}">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{escape(titre_complet)}</title>
<meta name="description" content="{escape(description)}">
<link rel="canonical" href="{url}">
<link rel="alternate" hreflang="fr" href="{url_fr}">
<link rel="alternate" hreflang="en" href="{url_en}">
<link rel="alternate" hreflang="x-default" href="{url_fr}">
<meta name="theme-color" content="#0093DD">
<meta property="og:type" content="website">
<meta property="og:site_name" content="HEMIP — La Percée">
<meta property="og:title" content="{escape(titre_complet)}">
<meta property="og:description" content="{escape(description)}">
<meta property="og:url" content="{url}">
<meta property="og:image" content="{DOMAINE}/img/og-hemip.jpg">
<meta property="og:locale" content="{L('fr_FR', 'en_GB')}">
<link rel="icon" type="image/png" href="{pre}img/favicon.png">
<link rel="apple-touch-icon" href="{pre}img/apple-touch-icon.png">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Oswald:wght@500;600;700&family=Source+Sans+3:ital,wght@0,400;0,600;0,700;1,400&display=swap" rel="stylesheet">
<link rel="stylesheet" href="{pre}css/style.css">
{jsonld}
</head>
<body>
<a class="skip" href="#contenu">{L('Aller au contenu', 'Skip to content')}</a>
<div class="topbar">
  <div class="wrap">
    <div class="agr-defile"><p class="agr">{L('Établissement privé d’enseignement supérieur agréé définitivement par l’État', 'Private higher education institution with full State accreditation')} · <b>N° {AGREMENT}</b></p></div>
    <span class="langue" aria-label="{L('Langue', 'Language')}">{lang_switch}</span>
  </div>
</div>
<header class="entete">
  <div class="wrap">
    <a class="marque" href="{lien(lang, 'accueil')}" aria-label="HEMIP — {L('accueil', 'home')}">
      <img src="{pre}img/monogramme.png" alt="" width="59" height="50">
      <span class="nom">HEMIP<small>{L('Management &amp; Ingénierie', 'Management &amp; Engineering')} · <b>LA PERCÉE</b></small></span>
    </a>
    <button class="burger" aria-expanded="false" aria-controls="nav" aria-label="{L('Ouvrir le menu', 'Open menu')}"><span></span><span></span><span></span></button>
    <nav class="nav" id="nav" aria-label="{L('Navigation principale', 'Main navigation')}">
      {''.join(nav)}
    </nav>
  </div>
</header>
<main id="contenu">
{contenu}
</main>
<footer class="pied">
  <div class="wrap">
    <div class="grille">
      <div>
        <span class="logo-blanc"><img src="{pre}img/logo-hemip-360.png" alt="HEMIP — Haute École de Management et de l'Ingénierie La Percée" width="310" height="360"></span>
        <p class="slogan">« {L('Nous formons des professionnels qualifiés et chevronnés.', 'We train qualified and seasoned professionals.')} »</p>
        <p>{L('Établissement privé d’enseignement supérieur agréé définitivement par l’État sous le numéro', 'Private higher education institution with full State accreditation, number')} {AGREMENT}.</p>
      </div>
      <div>
        <h4>{L('Navigation', 'Navigation')}</h4>
        <ul>{''.join(f'<li><a href="{lien(lang, k)}">{P[k]["l" + lang]}</a></li>' for k, *_ in PAGES)}</ul>
      </div>
      <div>
        <h4>{L('L’école', 'About')}</h4>
        <ul>{''.join(f'<li><a href="{lien(lang, s)}">{P[s]["l" + lang]}</a></li>' for s in SOUS_CLES)}</ul>
        <h4 style="margin-top:26px">{L('Formations', 'Programs')}</h4>
        <ul>
          <li><a href="{lien(lang, 'filieres')}#gestion">{L('Gestion et administration', 'Management and administration')}</a></li>
          <li><a href="{lien(lang, 'filieres')}#industrie">{L('Industriel et technologique', 'Industrial and technological')}</a></li>
          <li><a href="{lien(lang, 'filieres')}#continue">{L('Formation continue', 'Continuing education')}</a></li>
          <li><a href="{lien(lang, 'recherche')}">{L('Unité de recherche', 'Research unit')}</a></li>
          {fb}
        </ul>
      </div>
      <div>
        <h4>{L('Nous joindre', 'Get in touch')}</h4>
        <ul>
          <li>{L('Pointe-Noire, centre-ville, derrière la Tour Mayombe', 'Downtown Pointe-Noire, behind the Mayombe Tower')}</li>
          <li><a href="tel:{TEL1}">{TEL1_AFF}</a> / <a href="tel:{TEL2}">{TEL2_AFF}</a></li>
          <li>WhatsApp : <a href="https://wa.me/{WA}" rel="noopener" target="_blank">{WA_AFF}</a></li>
          <li><a href="mailto:{EMAIL}">{EMAIL}</a></li>
        </ul>
      </div>
    </div>
    <div class="bas">
      <span>© <span id="annee">2026</span> HEMIP — {L('Haute École de Management et de l’Ingénierie La Percée. Tous droits réservés.', 'Haute École de Management et de l’Ingénierie La Percée. All rights reserved.')}</span>
      <span>{L('Membre de l’ORAGEU', 'Member of ORAGEU')}</span>
    </div>
  </div>
</footer>
<a class="wa-flottant" href="https://wa.me/{WA}" target="_blank" rel="noopener" aria-label="{L('Écrire à HEMIP sur WhatsApp', 'Message HEMIP on WhatsApp')}">{ico('whatsapp')}</a>
<script src="{pre}js/main.js" defer></script>
</body>
</html>
"""


def entete_page(lang, cle, titre, intro):
    L = (lambda fr, en: fr if lang == "fr" else en)
    return f"""<section class="page-titre">
  <div class="wrap">
    <p class="fil"><a href="{lien(lang, 'accueil')}">{L('Accueil', 'Home')}</a> / {P[cle]['l' + lang]}</p>
    <h1>{titre}</h1>
    <p>{intro}</p>
  </div>
</section>"""


def titre_section(surtitre, titre, texte="", centre=False):
    p = f"<p>{texte}</p>" if texte else ""
    c = " centre" if centre else ""
    return f'<div class="titre-section{c} apparait"><span class="surtitre">{surtitre}</span><h2>{titre}</h2>{p}</div>'


def bandeau_appel(lang, titre=None, texte=None):
    L = (lambda fr, en: fr if lang == "fr" else en)
    titre = titre or L("Prêt(e) à faire la percée ?", "Ready to make your breakthrough?")
    texte = texte or L("Pré-inscrivez-vous en ligne en deux minutes : notre service des admissions vous répond sur WhatsApp.",
                       "Pre-register online in two minutes: our admissions office will reply on WhatsApp.")
    return f"""<section class="bloc serre"><div class="wrap">
  <div class="appel apparait">
    <div><h2>{titre}</h2><p>{texte}</p></div>
    <div class="btns">
      <a class="btn btn-blanc" href="{lien(lang, 'admissions')}">{L('Pré-inscription', 'Apply now')} {ico('fleche')}</a>
      <a class="btn btn-rouge" href="https://wa.me/{WA}" target="_blank" rel="noopener">{ico('whatsapp')} WhatsApp</a>
    </div>
  </div>
</div></section>"""


def emplacement(lang, quoi, hauteur=""):
    L = (lambda fr, en: fr if lang == "fr" else en)
    style = f' style="min-height:{hauteur}"' if hauteur else ""
    # EMPLACEMENT À REMPLACER : remplacer ce bloc par <img src="img/..." alt="...">
    return (f'<div class="ph a-remplacer"{style}>{ico("photo")}<span>{quoi}</span>'
            f'<small>{L("Photo à venir", "Photo coming soon")}</small></div>')


def options_filieres(lang):
    L = (lambda fr, en: fr if lang == "fr" else en)
    g = [f'<option value="">{L("Choisir une filière", "Choose a program")}</option>']
    for nom_p, code_p in ((L("Parcours Gestion et Administration", "Management and Administration track"), "ges"),
                          (L("Parcours Industriel et Technologique", "Industrial and Technological track"), "ind")):
        g.append(f'<optgroup label="{nom_p}">')
        for code, p, nom, _ in FILIERES:
            if p == code_p:
                g.append(f'<option value="{code}">{nom[lang]} ({code})</option>')
        g.append("</optgroup>")
    g.append(f'<option value="FC">{L("Formation continue / séminaire", "Continuing education / seminar")}</option>')
    g.append(f'<option value="?">{L("Je ne sais pas encore", "Not sure yet")}</option>')
    return "".join(g)


# ---------------------------------------------------------------- ACCUEIL
def p_accueil(lang):
    L = (lambda fr, en: fr if lang == "fr" else en)
    pre = "" if lang == "fr" else "../"
    rentree = (f'{L("Rentrée", "Intake")} {RENTREE[lang]} · ' if RENTREE[lang] else "")
    raisons = "".join(f'<div class="raison apparait"><div><h3>{r[lang][0]}</h3><p>{r[lang][1]}</p></div></div>' for r in RAISONS)
    noms = [n if isinstance(n, str) else n[lang] for n, _ in ENTREPRISES]
    def item(n):
        lg = logo_entreprise(n)
        return f'<li class="avec-logo"><img src="{pre}{lg}" alt="{n}"></li>' if lg else f"<li>{n}</li>"
    defile = "".join(item(n) for n in noms * 2)

    contenu = f"""
<section class="hero">
  <div class="wrap">
    <div class="texte apparait">
      {f'<p class="rentree">{rentree.rstrip(" · ")}</p>' if rentree else ''}
      <h1>{L('Formez-vous au <span>management</span> et à l’<em>ingénierie</em> à Pointe-Noire', 'Study <span>management</span> and <em>engineering</em> in Pointe-Noire')}</h1>
      <p class="accroche">{L('HEMIP La Percée forme des cadres et techniciens supérieurs prêts pour les entreprises du pétrole, de l’énergie, de l’industrie, de la banque et du commerce. Licences LMD, cours du jour et du soir.', 'HEMIP La Percée trains managers and senior technicians ready for companies in oil, energy, industry, banking and trade. LMD Bachelor’s degrees, day and evening classes.')}</p>
      <div class="btns">
        <a class="btn btn-contour" href="{lien(lang, 'filieres')}">{L('Voir les 15 filières', 'See the 15 programs')}</a>
      </div>
    </div>
    <div class="visuel">
      <div class="cercle"></div>
      <svg class="orbite" viewBox="0 0 600 600" aria-hidden="true"><path d="M540 70C420 20 250 90 140 230 40 360 60 500 170 520c120 22 260-90 340-220" fill="none" stroke="#0093DD" stroke-width="10" stroke-linecap="round"/></svg>
      <div class="arche"><img src="{pre}img/etudiante-hero.webp" alt="{L('Étudiante de HEMIP souriante, livres à la main', 'Smiling HEMIP student holding books')}" width="768" height="1376" fetchpriority="high"></div>
      <div class="carte-flottante cf1"><div><b>15</b>{L('filières de licence', 'Bachelor programs')}</div></div>
      <div class="carte-flottante cf2"><div><b>{L('Jour', 'Day')} &amp; {L('Soir', 'Evening')}</b>{L('horaires flexibles', 'flexible schedules')}</div></div>
    </div>
  </div>
</section>

<nav class="acces" aria-label="{L('Accès rapide', 'Quick links')}">
  <div class="wrap grille">
    <a href="{lien(lang, 'filieres')}#gestion">{ico('mallette')}<span><b>{L('Gestion', 'Management')}</b><small>{L('6 filières', '6 programs')}</small></span></a>
    <a href="{lien(lang, 'filieres')}#industrie">{ico('engrenage')}<span><b>{L('Ingénierie', 'Engineering')}</b><small>{L('9 filières', '9 programs')}</small></span></a>
    <a href="{lien(lang, 'admissions')}">{ico('chapeau')}<span><b>Admissions</b><small>{L('Pré-inscription en ligne', 'Apply online')}</small></span></a>
    <a href="{lien(lang, 'partenaires')}#devenir">{ico('poignee')}<span><b>{L('Entreprises', 'Companies')}</b><small>{L('Devenir partenaire', 'Become a partner')}</small></span></a>
  </div>
</nav>

<section class="bloc fond-bleu">
  <div class="wrap">
    <div class="chiffres">
      <div class="chiffre apparait"><b>15</b><span>{L('filières de licence en gestion et en ingénierie', 'Bachelor programs in management and engineering')}</span></div>
      <div class="chiffre apparait"><b>LMD</b><span>{L('diplômes reconnus, établissement agréé définitivement par l’État', 'recognised degrees, fully State-accredited institution')}</span></div>
      <div class="chiffre apparait"><b>4</b><span>{L('écoles partenaires en France, au Maroc, en RD Congo et en Tunisie', 'partner schools in France, Morocco, DR Congo and Tunisia')}</span></div>
      <div class="chiffre apparait"><b>FR / EN</b><span>{L('enseignement bilingue français et anglais', 'bilingual teaching in French and English')}</span></div>
    </div>
  </div>
</section>

<section class="bloc fond-noir">
  <div class="wrap">
    {titre_section(L('Pourquoi HEMIP', 'Why HEMIP'), L('10 raisons de nous choisir', '10 reasons to choose us'), L('Une école à taille humaine, ancrée dans le tissu industriel congolais.', 'A human-scale school rooted in Congo’s industrial landscape.'))}
    <div class="raisons">{raisons}</div>
  </div>
</section>

<section class="bloc serre fond-bleu">
  <div class="wrap">
    {titre_section(L('Stages et emplois', 'Internships and jobs'), L('Ils accueillent nos étudiants', 'Where our students train'), L('Visites guidées, stages professionnels et premiers emplois chez les acteurs majeurs de l’économie congolaise.', 'Guided visits, internships and first jobs with major players in Congo’s economy.'), centre=True)}
    <div class="defile" aria-label="{L('Entreprises partenaires', 'Partner companies')}"><ul>{defile}</ul></div>
  </div>
</section>

{bandeau_appel(lang)}
"""
    jsonld = f"""<script type="application/ld+json">{{
"@context":"https://schema.org","@type":"CollegeOrUniversity",
"name":"HEMIP — Haute École de Management et de l'Ingénierie La Percée","alternateName":"HEMIP",
"url":"{DOMAINE}/","logo":"{DOMAINE}/img/logo-hemip.png","email":"{EMAIL}",
"telephone":["{TEL1_AFF}","{TEL2_AFF}"],
"address":{{"@type":"PostalAddress","streetAddress":"Centre-ville, derrière la Tour Mayombe","addressLocality":"Pointe-Noire","addressCountry":"CG"}},
"slogan":"Nous formons des professionnels qualifiés et chevronnés.",
"memberOf":{{"@type":"Organization","name":"Ordre Africain des Grandes Écoles et Universités (ORAGEU)"}}
}}</script>"""
    return page(lang, "accueil",
                L("HEMIP La Percée — École de management et d’ingénierie à Pointe-Noire", "HEMIP La Percée — School of management and engineering in Pointe-Noire"),
                L("HEMIP, Haute École de Management et de l’Ingénierie La Percée : 15 licences LMD en gestion et en ingénierie (pétrole, énergie, informatique), cours du jour et du soir, à Pointe-Noire, Congo.",
                  "HEMIP, Haute École de Management et de l’Ingénierie La Percée: 15 LMD Bachelor’s programs in management and engineering (oil, energy, IT), day and evening classes, in Pointe-Noire, Congo."),
                contenu, jsonld)


# ---------------------------------------------------------------- L'ÉCOLE (sections de l'accueil)
def sections_ecole(lang):
    L = (lambda fr, en: fr if lang == "fr" else en)
    pre = "" if lang == "fr" else "../"
    valeurs = [
        ("medaille", L("Excellence", "Excellence"), L("Des enseignants qualifiés, professionnels et innovateurs.", "Qualified, professional and innovative lecturers.")),
        ("usine", L("Pratique", "Practice"), L("Laboratoires, ateliers et terrain : on apprend en faisant.", "Labs, workshops and fieldwork: learning by doing.")),
        ("groupe", L("Proximité", "Proximity"), L("Des classes réduites et une attention particulière à chaque étudiant.", "Small classes and close attention to every student.")),
        ("ampoule", L("Innovation", "Innovation"), L("Une recherche orientée vers les besoins réels de nos communautés.", "Research focused on the real needs of our communities.")),
    ]
    vals = "".join(f'<div class="carte apparait"><div class="ico">{ico(i)}</div><h3>{t}</h3><p>{d}</p></div>' for i, t, d in valeurs)
    return {"vision": f"""<section class="bloc">
  <div class="wrap deux-col">
    <div class="apparait">
      {titre_section(L('Notre vision', 'Our vision'), L('Viser l’excellence africaine', 'Aiming for African excellence'))}
      <p class="citation">{L('Devenir une des meilleures institutions supérieures en Afrique.', 'To become one of the best higher education institutions in Africa.')}</p>
      <div class="agrement" style="margin-top:34px">{ico('medaille')}<div><b>{L('Agréé définitivement par l’État', 'Fully accredited by the State')}</b><br><span>{L('Arrêté n°', 'Accreditation no.')} {AGREMENT}</span></div></div>
    </div>
    <div class="photo-cadre apparait"><img src="{pre}img/etudiante-admissions.webp" alt="{L('Étudiante de HEMIP', 'HEMIP student')}" width="900" height="1350" loading="lazy" style="max-height:560px"></div>
  </div>
</section>""",
        "mission": f"""<section class="bloc">
  <div class="wrap">
    {titre_section(L('Notre mission', 'Our mission'), L('Former, chercher, insérer', 'Teach, research, employ'))}
    <div class="grille-3">
      <div class="carte apparait"><div class="ico">{ico('chapeau')}</div><h3>{L('Former des cadres', 'Train professionals')}</h3><p>{L('Assurer une formation de qualité des cadres en ingénierie (techniciens supérieurs) et en management (licenciés), avec des enseignants qualifiés, professionnels et innovateurs.', 'Provide high-quality training in engineering (senior technicians) and management (Bachelor’s graduates), with qualified, professional and innovative lecturers.')}</p></div>
      <div class="carte rouge apparait"><div class="ico">{ico('fiole')}</div><h3>{L('Chercher utile', 'Useful research')}</h3><p>{L('Organiser une recherche scientifique orientée, au sein d’une unité de recherche, pour des solutions adaptées aux problèmes de la société.', 'Conduct applied scientific research, within a dedicated unit, to deliver solutions suited to society’s problems.')}</p></div>
      <div class="carte apparait"><div class="ico">{ico('mallette')}</div><h3>{L('Préparer à l’emploi', 'Prepare for work')}</h3><p>{L('Préparer les étudiants à la vie professionnelle dans les secteurs primaire (Perenco, TotalEnergies…), secondaire (CORAF, Dangote, Saris…) et tertiaire (E2C, La Congolaise des Eaux…), ou à créer leur start-up.', 'Prepare students for careers in the primary (Perenco, TotalEnergies…), secondary (CORAF, Dangote, Saris…) and tertiary sectors (E2C, La Congolaise des Eaux…), or to launch their own start-up.')}</p></div>
    </div>
  </div>
</section>""",
        "valeurs": f"""<section class="bloc">
  <div class="wrap">
    {titre_section(L('Nos valeurs', 'Our values'), L('Ce qui nous guide', 'What guides us'))}
    <div class="grille-4">{vals}</div>
  </div>
</section>""",
        "directeur": f"""<section class="bloc">
  <div class="wrap deux-col">
    <div class="apparait">
      {titre_section(L('Le mot du directeur', 'A word from the director'), L('Faire la percée', 'Making the breakthrough'))}
      <!-- EMPLACEMENT À REMPLACER : texte, nom et fonction du directeur général -->
      <div class="temoin a-venir"><p>{L('Le message du directeur général sera publié ici prochainement.', 'The Director General’s message will be published here soon.')}</p>
      <div class="qui"><span class="av">DG</span><span><b>{L('Directeur général', 'Director General')}</b><small>HEMIP La Percée</small></span></div></div>
    </div>
    <div class="apparait">{emplacement(lang, L('Portrait du directeur', 'Director’s portrait'), '360px')}</div>
  </div>
</section>""",
        "campus": f"""<section class="bloc">
  <div class="wrap deux-col">
    <div class="apparait">{emplacement(lang, L('Campus de Pointe-Noire', 'Pointe-Noire campus'), '380px')}</div>
    <div class="apparait">
      {titre_section(L('Le campus', 'The campus'), L('Au centre-ville de Pointe-Noire', 'In downtown Pointe-Noire'))}
      <p>{L('Le campus est situé au centre-ville, derrière la Tour Mayombe, facilement accessible en transport en commun. Il réunit les salles de cours, les laboratoires de chimie, de génie des procédés et d’informatique, ainsi que les ateliers d’électromécanique et d’électronique.', 'The campus is located downtown, behind the Mayombe Tower, and easy to reach by public transport. It houses classrooms, chemistry, process engineering and computer labs, as well as electromechanics and electronics workshops.')}</p>
      <ul class="liste-check" style="margin-top:20px">
        <li>{L('Enseignement selon le système LMD', 'Teaching under the LMD system')}</li>
        <li>{L('Vacation du jour et vacation du soir', 'Day and evening sessions')}</li>
        <li>{L('Membre de l’Ordre Africain des Grandes Écoles et Universités (ORAGEU)', 'Member of the African Order of Grandes Écoles and Universities (ORAGEU)')}</li>
      </ul>
      <div class="btns" style="margin-top:24px"><a class="btn btn-bleu" href="{lien(lang, 'contact')}">{L('Nous rendre visite', 'Visit us')} {ico('fleche')}</a></div>
    </div>
  </div>
</section>"""}


INTRO_SOUS = {
    "vision": T("L’ambition qui guide HEMIP La Percée depuis sa création.", "The ambition that has guided HEMIP La Percée since its creation."),
    "mission": T("Former des cadres, mener une recherche utile et préparer nos étudiants à l’emploi.", "Training professionals, conducting useful research and preparing our students for work."),
    "valeurs": T("Les principes qui guident notre enseignement au quotidien.", "The principles that guide our teaching every day."),
    "directeur": T("Le message du directeur général aux étudiants, aux familles et aux partenaires.", "The Director General’s message to students, families and partners."),
    "campus": T("Un campus au centre-ville de Pointe-Noire, derrière la Tour Mayombe.", "A campus in downtown Pointe-Noire, behind the Mayombe Tower."),
}


def p_sous(cle):
    def gen(lang):
        titre = P[cle]["l" + lang]
        contenu = entete_page(lang, cle, titre, INTRO_SOUS[cle][lang]) + "\n" + sections_ecole(lang)[cle] + "\n" + bandeau_appel(lang)
        return page(lang, cle, titre, f"HEMIP La Percée — {titre}. {INTRO_SOUS[cle][lang]}", contenu)
    return gen


# ---------------------------------------------------------------- FILIÈRES
def carte_filiere(lang, code, parcours, nom, debouches):
    L = (lambda fr, en: fr if lang == "fr" else en)
    sous = (L("Génie des procédés", "Process engineering") if code in PROCEDES else
            (L("Gestion et administration", "Management and administration") if parcours == "ges" else L("Industriel et technologique", "Industrial and technological")))
    lis = "".join(f"<li>{d}</li>" for d in debouches[lang])
    return f"""<article class="filiere {parcours} apparait" id="{code.lower()}" data-parcours="{parcours}">
  <div class="tete"><span class="code">{code}</span><h3>{nom[lang]}</h3><p class="sous">{sous}</p></div>
  <div class="corps"><h4>{L('Débouchés', 'Career paths')}</h4><ul>{lis}</ul></div>
  <div class="bas-carte"><span>{L('Licence · 3 ans', 'Bachelor · 3 years')}</span><a href="{lien(lang, 'admissions')}?filiere={code}#form">{L('Je suis intéressé(e)', 'I’m interested')} →</a></div>
</article>"""


def p_filieres(lang):
    L = (lambda fr, en: fr if lang == "fr" else en)
    ges = "".join(carte_filiere(lang, *f) for f in FILIERES if f[1] == "ges")
    ind = "".join(carte_filiere(lang, *f) for f in FILIERES if f[1] == "ind" and f[0] not in PROCEDES)
    proc = "".join(carte_filiere(lang, *f) for f in FILIERES if f[0] in PROCEDES)
    contenu = f"""
{entete_page(lang, 'filieres', L('Nos filières', 'Our programs'), L('Quinze licences professionnalisantes réparties en deux parcours, avec des débouchés concrets dans les entreprises congolaises.', 'Fifteen career-focused Bachelor’s programs across two tracks, with concrete career paths in Congolese companies.'))}

<section class="bloc serre fond-bleu">
  <div class="wrap">
    <div class="infos-lmd">
      <div class="apparait"><b>LMD</b><span>{L('Licence en 6 semestres (3 ans)', 'Bachelor’s degree in 6 semesters (3 years)')}</span></div>
      <div class="apparait"><b>{L('Jour / Soir', 'Day / Evening')}</b><span>{L('Deux vacations au choix', 'Choice of two sessions')}</span></div>
      <div class="apparait"><b>FR / EN</b><span>{L('Cours bilingues', 'Bilingual courses')}</span></div>
      <div class="apparait"><b>{L('Stages', 'Internships')}</b><span>{L('En entreprise partenaire', 'In partner companies')}</span></div>
    </div>
  </div>
</section>

<section class="bloc">
  <div class="wrap">
    <div class="filtres" role="group" aria-label="{L('Filtrer les filières', 'Filter programs')}">
      <button type="button" data-filtre="tous" aria-pressed="true">{L('Toutes les filières', 'All programs')} (15)</button>
      <button type="button" data-filtre="ges" aria-pressed="false">{L('Gestion et administration', 'Management and administration')} (6)</button>
      <button type="button" data-filtre="ind" aria-pressed="false">{L('Industriel et technologique', 'Industrial and technological')} (9)</button>
    </div>

    <div data-parcours="ges" id="gestion">
      <h2 class="groupe-titre"><i></i>{L('Parcours Gestion et Administration', 'Management and Administration track')}</h2>
      <div class="grille-3">{ges}</div>
    </div>

    <div data-parcours="ind" id="industrie">
      <h2 class="groupe-titre bleu"><i></i>{L('Parcours Industriel et Technologique', 'Industrial and Technological track')}</h2>
      <div class="grille-3">{ind}</div>
      <h2 class="groupe-titre bleu" style="font-size:1.15rem"><i></i>{L('Génie des procédés', 'Process engineering')}</h2>
      <div class="grille-2">{proc}</div>
    </div>
  </div>
</section>

<section class="bloc fond-noir" id="continue">
  <div class="wrap deux-col">
    <div class="apparait">
      {titre_section(L('Professionnels et entreprises', 'Professionals and companies'), L('Formations continues et séminaires spécialisés', 'Continuing education and specialised seminars'), L('HEMIP accompagne aussi les salariés et les entreprises : formations de courte durée, renforcement des capacités et séminaires sur mesure, dans nos domaines d’expertise en gestion et en ingénierie.', 'HEMIP also supports employees and companies: short courses, capacity building and tailor-made seminars in our management and engineering fields.'))}
      <div class="btns"><a class="btn btn-rouge" href="{lien(lang, 'contact')}?objet=formation#form">{L('Demander un programme', 'Request a program')} {ico('fleche')}</a></div>
    </div>
    <ul class="liste-check apparait" style="color:#fff">
      <li style="color:rgba(255,255,255,.8)"><b style="color:#fff">{L('Formations de courte durée', 'Short courses')}</b> — {L('pour mettre à jour des compétences précises', 'to update specific skills')}</li>
      <li style="color:rgba(255,255,255,.8)"><b style="color:#fff">{L('Renforcement des capacités', 'Capacity building')}</b> — {L('pour les équipes d’entreprise', 'for company teams')}</li>
      <li style="color:rgba(255,255,255,.8)"><b style="color:#fff">{L('Séminaires spécialisés', 'Specialised seminars')}</b> — {L('pétrole, énergie, procédés, gestion, finance', 'oil, energy, processes, management, finance')}</li>
      <li style="color:rgba(255,255,255,.8)"><b style="color:#fff">{L('Cours du soir', 'Evening classes')}</b> — {L('pour se former sans quitter son emploi', 'to study without leaving your job')}</li>
    </ul>
  </div>
</section>

{bandeau_appel(lang, L('Vous avez trouvé votre filière ?', 'Found your program?'))}
"""
    return page(lang, "filieres", L("Nos filières", "Programs"),
                L("15 licences LMD à Pointe-Noire : RH, finance, banque, commerce international, droit, logistique, maintenance, électrotechnique, automatisme, génie logiciel, télécoms, génie pétrolier, chimique, raffinage, énergies renouvelables.",
                  "15 LMD Bachelor’s programs in Pointe-Noire: HR, finance, banking, international trade, law, logistics, maintenance, electrical engineering, automation, software, telecoms, petroleum, chemical, refining and renewable energy engineering."), contenu)


# ---------------------------------------------------------------- RECHERCHE
def p_recherche(lang):
    L = (lambda fr, en: fr if lang == "fr" else en)
    axes = [
        (L("Énergies renouvelables : solaire", "Renewable energy: solar"), L("Conception et installation de systèmes solaires photovoltaïques (SSPV) pour l’électrification des habitations et des sites isolés.", "Design and installation of solar photovoltaic systems for homes and off-grid sites."), [L("Photovoltaïque", "Photovoltaics"), L("Électrification", "Electrification")]),
        (L("Biocarburants et biomasse", "Biofuels and biomass"), L("Chaîne de production pilote puis semi-industrielle de biodiesel et d’éthanol, et production d’électricité à partir de la biomasse.", "Pilot then semi-industrial production chain for biodiesel and ethanol, and power generation from biomass."), ["Biodiesel", L("Bioéthanol", "Bioethanol"), L("Glycérine", "Glycerin"), L("Gel hydroalcoolique", "Hand sanitiser"), L("Biokérosène", "Bio-kerosene")]),
        (L("Hydroélectricité et réseaux électriques", "Hydropower and power grids"), L("Micro-centrales hydroélectriques sur les cours d’eau du bassin du Congo, et simulation d’isolateurs électriques pour réduire le coût des lignes à haute tension.", "Micro hydropower plants on Congo Basin rivers, and simulation of electrical insulators to cut the cost of high-voltage lines."), [L("Génie électrique", "Electrical engineering"), L("Génie civil", "Civil engineering"), L("Hydro-météorologie", "Hydro-meteorology")]),
        (L("Recyclage des déchets plastiques", "Plastic waste recycling"), L("Chaîne de valeur complète : collecte, broyage, transformation en GPL, essence, diesel et bitume, puis fabrication de pavés.", "A full value chain: collection, shredding, conversion into LPG, petrol, diesel and bitumen, then paving block production."), ["GPL", L("Essence", "Petrol"), "Diesel", L("Pavés", "Paving blocks")]),
        (L("Traitement de l’eau", "Water treatment"), L("Procédé de traitement industriel des eaux de surface et souterraines : coagulation, floculation, décantation, ajustement du pH, désinfection, jusqu’à l’eau potable.", "Industrial treatment process for surface and groundwater: coagulation, flocculation, settling, pH adjustment and disinfection, through to drinking water."), [L("Eau potable", "Drinking water"), L("Génie chimique", "Chemical engineering")]),
        (L("Génie logiciel", "Software engineering"), L("Développement d’un simulateur et logiciel de gestion de système énergétique hybride.", "Development of a simulator and management software for hybrid energy systems."), [L("Simulation", "Simulation"), L("Systèmes hybrides", "Hybrid systems")]),
    ]
    axes_html = "".join(
        f'<div class="axe apparait"><span class="num">{i+1:02d}</span><div><h3>{t}</h3><p>{d}</p><div class="puces">{"".join(f"<span>{p}</span>" for p in pp)}</div></div></div>'
        for i, (t, d, pp) in enumerate(axes))

    secteurs = [
        ("eclair", "", L("Énergies et hydrocarbures", "Energy and hydrocarbons"),
         [L("Production semi-industrielle : catalyseurs, essence, kérosène, GPL, biogaz", "Semi-industrial production: catalysts, petrol, kerosene, LPG, biogas"), L("Biocarburants : biodiesel, bioéthanol", "Biofuels: biodiesel, bioethanol"), L("Électricité thermique, solaire, hydraulique", "Thermal, solar and hydro power")],
         "CORAF, Eni, AOGC, Perenco, Trident, SNPC, TotalEnergies, E2C"),
        ("pioche", "rouge", L("Mines et minéralurgie", "Mining and mineral processing"),
         [L("Plans d’affaires miniers", "Mining business plans"), L("Projets d’exploitation optimale : or, coltan, cuivre, cobalt, palladium, platine", "Optimal extraction projects: gold, coltan, copper, cobalt, palladium, platinum"), L("Exploitation des calcaires pour les ciments et les craies", "Limestone processing for cement and chalk")],
         "Anglogold, GCM, CILU, Dangote"),
        ("usine", "rouge", L("Génie industriel", "Industrial engineering"),
         [L("Production semi-industrielle : eau potable, craies, peintures, ciments, détergents, biofertilisants", "Semi-industrial production: drinking water, chalk, paints, cement, detergents, bio-fertilisers"), L("Développement de logiciels", "Software development"), L("Forage d’eau et installation solaire photovoltaïque", "Water drilling and solar PV installation")],
         L("Saris Congo, Dangote, La Congolaise des Eaux, agriculteurs, constructeurs", "Saris Congo, Dangote, La Congolaise des Eaux, farmers, builders")),
        ("presentation", "", L("Consultance et formation", "Consulting and training"),
         [L("Formations de courte durée et renforcement des capacités", "Short courses and capacity building"), L("Études techniques et projets d’ingénierie pour les entreprises", "Technical studies and engineering projects for companies"), L("Études environnementales (EIE, PGES)", "Environmental studies (ESIA, ESMP)")],
         L("Entreprises pétrolières, chimiques, agroalimentaires, universités", "Oil, chemical and food companies, universities")),
    ]
    sect = "".join(
        f'<div class="carte secteur {c} apparait"><div class="ico">{ico(i)}</div><h3>{t}</h3><ul>{"".join(f"<li>{x}</li>" for x in li)}</ul>'
        f'<p class="clients"><b>{L("Clients potentiels", "Potential clients")} :</b> {cl}</p></div>'
        for i, c, t, li, cl in secteurs)

    contenu = f"""
{entete_page(lang, 'recherche', L('Recherche, innovation et développement', 'Research, innovation and development'), L('L’unité de recherche en génie des procédés de HEMIP développe des solutions concrètes, adaptées aux besoins du Congo et de l’Afrique centrale.', 'HEMIP’s process engineering research unit develops practical solutions tailored to the needs of Congo and Central Africa.'))}

<section class="bloc">
  <div class="wrap deux-col" style="align-items:start">
    <div class="apparait" style="position:sticky;top:120px">
      {titre_section(L('Nos axes de recherche', 'Our research areas'), L('Une recherche orientée vers la société', 'Research that serves society'), L('Nos étudiants participent à ces projets, du laboratoire au pilote semi-industriel : c’est la meilleure école de la pratique.', 'Our students take part in these projects, from the lab to semi-industrial pilots: the best way to learn by doing.'))}
      {emplacement(lang, L('Laboratoire de génie des procédés', 'Process engineering lab'), '260px')}
    </div>
    <div>{axes_html}</div>
  </div>
</section>

<section class="bloc fond-bleu">
  <div class="wrap">
    {titre_section(L('Services aux entreprises', 'Services for companies'), L('Nos secteurs d’intervention', 'Our areas of work'), L('Entreprises, administrations et porteurs de projets : HEMIP met son expertise à votre service.', 'Companies, public bodies and project owners: HEMIP puts its expertise at your service.'))}
    <div class="grille-2">{sect}</div>
    <div class="btns" style="margin-top:34px"><a class="btn btn-rouge" href="{lien(lang, 'partenaires')}#devenir">{L('Proposer un projet', 'Propose a project')} {ico('fleche')}</a></div>
  </div>
</section>

{bandeau_appel(lang, L('Envie d’innover avec nous ?', 'Want to innovate with us?'), L('Rejoignez nos filières en génie des procédés et participez aux projets de l’unité de recherche.', 'Join our process engineering programs and take part in the research unit’s projects.'))}
"""
    return page(lang, "recherche", L("Recherche", "Research"),
                L("Unité de recherche en génie des procédés de HEMIP : énergies renouvelables, biocarburants, recyclage des plastiques, traitement de l’eau, et services aux entreprises.",
                  "HEMIP’s process engineering research unit: renewable energy, biofuels, plastic recycling, water treatment and services for companies."), contenu)


# ---------------------------------------------------------------- VIE ÉTUDIANTE
def p_vie(lang):
    L = (lambda fr, en: fr if lang == "fr" else en)
    activites = [
        (L("Soutenances", "Thesis defenses"), L("Chaque année, nos finalistes présentent leurs mémoires et projets de fin d’études devant un jury d’enseignants et de professionnels. Un moment fort qui couronne trois ans de travail.", "Each year, our final-year students present their dissertations and capstone projects to a panel of lecturers and professionals: a highlight that crowns three years of work.")),
        (L("Visites en entreprise", "Company visits"), L("Pour bien lier la théorie à la pratique, la Direction des Affaires Académiques organise des visites guidées chez nos partenaires : raffinerie, usines, banques, sites de production d’énergie.", "To connect theory and practice, the Academic Affairs Department organises guided visits to our partners: refinery, plants, banks, power generation sites.")),
        (L("Excursions", "Field trips"), L("Sorties pédagogiques et découvertes de terrain : sites industriels, barrages, cours d’eau du bassin du Congo… pour voir en vrai ce que l’on étudie en classe.", "Educational outings and field discoveries: industrial sites, dams, Congo Basin rivers… to see for real what we study in class.")),
        (L("Fêtes scolaires", "School celebrations"), L("Journée d’intégration, fêtes de fin d’année, remises de diplômes : la vie à HEMIP, c’est aussi des moments de partage entre étudiants, enseignants et familles.", "Welcome day, end-of-year parties, graduation ceremonies: life at HEMIP is also about moments shared by students, lecturers and families.")),
    ]
    act = "".join(f'<div class="activite apparait">{emplacement(lang, t)}<div class="txt"><h3>{t}</h3><p>{d}</p></div></div>' for t, d in activites)
    temoins = "".join(
        f'<div class="temoin a-venir apparait"><!-- EMPLACEMENT À REMPLACER : témoignage, nom, filière et promotion -->'
        f'<p>{L("Témoignage à venir.", "Testimonial coming soon.")}</p><div class="qui"><span class="av">{ini}</span>'
        f'<span><b>{qui}</b><small>{L("Filière, promotion", "Program, class of")}</small></span></div></div>'
        for ini, qui in (("A", L("Alumni", "Alumni")), ("S", L("Étudiant(e) stagiaire", "Intern student")), ("F", L("Finaliste", "Final-year student"))))
    contenu = f"""
{entete_page(lang, 'vie', L('Vie étudiante', 'Student life'), L('Soutenances, visites en entreprise, excursions, fêtes : à HEMIP, on apprend aussi hors de la salle de classe.', 'Thesis defenses, company visits, field trips, celebrations: at HEMIP, learning also happens outside the classroom.'))}

<section class="bloc">
  <div class="wrap pile">{act}</div>
</section>

<section class="bloc fond-noir">
  <div class="wrap deux-col">
    <div class="apparait">
      {titre_section(L('Stages et insertion', 'Internships and careers'), L('Du stage à l’emploi', 'From internship to job'))}
      <p style="color:rgba(255,255,255,.8)">{L('HEMIP est en contact partenarial avec de nombreuses entreprises de Pointe-Noire et de Brazzaville où nos étudiants effectuent visites guidées et stages professionnels. Selon les compétences dont il fait preuve, un stage peut déboucher sur un emploi : plusieurs de nos stagiaires ont déjà signé des CDD et des CDI.', 'HEMIP partners with many companies in Pointe-Noire and Brazzaville where our students go on guided visits and internships. Depending on the skills shown, an internship can lead to a job: several of our interns have already signed fixed-term and permanent contracts.')}</p>
    </div>
    <div class="grille-2 apparait">
      <div class="carte"><div class="ico">{ico('mallette')}</div><h3>{L('Stages', 'Internships')}</h3><p>{L('Facilités par nos partenariats', 'Made easier by our partnerships')}</p></div>
      <div class="carte rouge"><div class="ico">{ico('poignee')}</div><h3>{L('CDD et CDI', 'Job contracts')}</h3><p>{L('Déjà signés par nos stagiaires', 'Already signed by our interns')}</p></div>
      <div class="carte rouge"><div class="ico">{ico('fusee')}</div><h3>Start-ups</h3><p>{L('Encouragement à entreprendre', 'Support for entrepreneurship')}</p></div>
      <div class="carte"><div class="ico">{ico('groupe')}</div><h3>Alumni</h3><p>{L('Un réseau d’anciens qui grandit', 'A growing alumni network')}</p></div>
    </div>
  </div>
</section>

<section class="bloc fond-bleu">
  <div class="wrap">
    {titre_section(L('Témoignages', 'Testimonials'), L('Ils racontent HEMIP', 'In their own words'), L('Finalistes, étudiants stagiaires et alumni partagent leur expérience.', 'Final-year students, interns and alumni share their experience.'))}
    <div class="grille-3">{temoins}</div>
  </div>
</section>

{bandeau_appel(lang)}
"""
    return page(lang, "vie", L("Vie étudiante", "Student life"),
                L("Soutenances, visites en entreprise, excursions, fêtes scolaires, stages et emplois : découvrez la vie étudiante à HEMIP, Pointe-Noire.",
                  "Thesis defenses, company visits, field trips, celebrations, internships and jobs: discover student life at HEMIP, Pointe-Noire."), contenu)


# ---------------------------------------------------------------- PARTENAIRES
def p_partenaires(lang):
    L = (lambda fr, en: fr if lang == "fr" else en)
    pre = "" if lang == "fr" else "../"
    acad = "".join(
        f'<div class="carte logo-carte apparait"><div class="logo-zone"><img src="{pre}img/partenaires/{sigle.lower()}.png" alt="{L("Logo", "Logo")} {sigle}" loading="lazy"></div>'
        f'<h3>{sigle} <small>· {pays[lang]}</small></h3><p>{nom[lang]}</p></div>'
        for sigle, pays, nom in PART_ACAD)
    ent = ""
    avec_logo = sorted(ENTREPRISES, key=lambda e: not (isinstance(e[0], str) and logo_entreprise(e[0])))
    for n, s in avec_logo:
        nom = n if isinstance(n, str) else n[lang]
        lg = logo_entreprise(nom) if isinstance(n, str) else None
        if lg:
            ent += f'<div class="ent-logo" title="{nom}"><img src="{pre}{lg}" alt="{nom}" loading="lazy"></div>'
        else:
            ent += f'<div class="ent-logo ent-texte"><b>{nom}</b><small>{s[lang]}</small></div>'

    contenu = f"""
{entete_page(lang, 'partenaires', L('Nos partenaires', 'Our partners'), L('Des écoles partenaires sur trois continents et un réseau d’entreprises qui accueillent nos étudiants en stage.', 'Partner schools across Africa and Europe, and a network of companies that host our students as interns.'))}

<section class="bloc">
  <div class="wrap">
    {titre_section(L('Partenaires académiques', 'Academic partners'), L('Un réseau international', 'An international network'))}
    <div class="grille-3">{acad}
      <div class="carte logo-carte apparait"><div class="logo-zone"><img src="{pre}img/partenaires/orageu.png" alt="{L('Logo', 'Logo')} ORAGEU" loading="lazy"></div><h3>ORAGEU <small>· {L('Afrique', 'Africa')}</small></h3><p>{L('HEMIP est membre de l’Ordre Africain des Grandes Écoles et Universités.', 'HEMIP is a member of the African Order of Grandes Écoles and Universities.')}</p></div>
    </div>
  </div>
</section>

<section class="bloc fond-bleu">
  <div class="wrap">
    {titre_section(L('Entreprises', 'Companies'), L('Ils accueillent nos étudiants', 'Where our students train'), L('Visites guidées, stages professionnels et opportunités d’emploi, à Pointe-Noire et à Brazzaville (liste non exhaustive).', 'Guided visits, internships and job opportunities in Pointe-Noire and Brazzaville (non-exhaustive list).'))}
    <div class="entreprises apparait">{ent}</div>
  </div>
</section>

<section class="bloc" id="devenir">
  <div class="wrap deux-col" style="align-items:start">
    <div class="apparait">
      {titre_section(L('Entreprises et institutions', 'Companies and institutions'), L('Devenez partenaire de HEMIP', 'Become a HEMIP partner'))}
      <ul class="liste-check">
        <li><b>{L('Accueillir des stagiaires', 'Host interns')}</b> — {L('des profils formés à vos métiers', 'students trained for your trades')}</li>
        <li><b>{L('Recruter nos diplômés', 'Recruit our graduates')}</b> — {L('techniciens supérieurs et licenciés opérationnels', 'job-ready senior technicians and graduates')}</li>
        <li><b>{L('Mener un projet de recherche', 'Run a research project')}</b> — {L('avec notre unité de génie des procédés', 'with our process engineering unit')}</li>
        <li><b>{L('Former vos équipes', 'Train your teams')}</b> — {L('formations continues et séminaires', 'continuing education and seminars')}</li>
        <li><b>{L('Soutenir des bourses', 'Fund scholarships')}</b> — {L('pour les étudiants les plus méritants', 'for the most deserving students')}</li>
      </ul>
    </div>
    <form class="form-carte apparait" id="form" data-whatsapp="{L('Demande de partenariat — site HEMIP', 'Partnership request — HEMIP website')}" novalidate>
      <h3>{L('Parlons de votre projet', 'Tell us about your project')}</h3>
      <p class="note">{L('Votre demande est envoyée à HEMIP par WhatsApp.', 'Your request is sent to HEMIP via WhatsApp.')}</p>
      <div class="champs">
        <div class="plein"><label for="p-org">{L('Entreprise ou institution', 'Company or institution')}</label><input id="p-org" name="org" data-libelle="{L('Organisation', 'Organisation')}" required autocomplete="organization"></div>
        <div><label for="p-nom">{L('Nom et prénom', 'Full name')}</label><input id="p-nom" name="nom" data-libelle="{L('Nom', 'Name')}" required autocomplete="name"></div>
        <div><label for="p-fct">{L('Fonction', 'Position')} <span class="opt">({L('facultatif', 'optional')})</span></label><input id="p-fct" name="fonction" data-libelle="{L('Fonction', 'Position')}" autocomplete="organization-title"></div>
        <div><label for="p-tel">{L('Téléphone', 'Phone')}</label><input id="p-tel" name="tel" type="tel" data-libelle="{L('Téléphone', 'Phone')}" required autocomplete="tel"></div>
        <div><label for="p-mail">E-mail <span class="opt">({L('facultatif', 'optional')})</span></label><input id="p-mail" name="email" type="email" data-libelle="E-mail" autocomplete="email"></div>
        <div class="plein"><label for="p-type">{L('Type de partenariat', 'Type of partnership')}</label>
          <select id="p-type" name="type" data-libelle="{L('Partenariat', 'Partnership')}" required>
            <option value="">{L('Choisir', 'Choose')}</option>
            <option value="stages">{L('Accueil de stagiaires', 'Hosting interns')}</option>
            <option value="recrutement">{L('Recrutement de diplômés', 'Recruiting graduates')}</option>
            <option value="recherche">{L('Projet de recherche ou étude technique', 'Research project or technical study')}</option>
            <option value="formation">{L('Formation de nos équipes', 'Training our teams')}</option>
            <option value="academique">{L('Partenariat académique', 'Academic partnership')}</option>
            <option value="bourses">{L('Bourses et mécénat', 'Scholarships and sponsorship')}</option>
          </select></div>
        <div class="plein"><label for="p-msg">{L('Votre message', 'Your message')}</label><textarea id="p-msg" name="message" data-libelle="Message" required></textarea></div>
      </div>
      <p class="erreur" role="alert">{L('Merci de remplir les champs obligatoires.', 'Please fill in the required fields.')}</p>
      <div class="form-pied"><small>{L('Une fenêtre WhatsApp s’ouvre avec votre message prêt à envoyer.', 'A WhatsApp window opens with your message ready to send.')}</small>
      <button class="btn btn-rouge" type="submit">{ico('whatsapp')} {L('Envoyer', 'Send')}</button></div>
    </form>
  </div>
</section>
"""
    return page(lang, "partenaires", L("Partenaires", "Partners"),
                L("Partenaires académiques de HEMIP (ENGDE, HESTIM, ISTA, IPSAS, ORAGEU) et entreprises qui accueillent nos étudiants. Devenez partenaire.",
                  "HEMIP’s academic partners (ENGDE, HESTIM, ISTA, IPSAS, ORAGEU) and companies that host our students. Become a partner."), contenu)


# ---------------------------------------------------------------- ADMISSIONS
def p_admissions(lang):
    L = (lambda fr, en: fr if lang == "fr" else en)
    pre = "" if lang == "fr" else "../"
    etapes = [
        (L("Pré-inscription en ligne", "Online pre-registration"), L("Remplissez le formulaire ci-dessous : votre demande arrive directement sur notre WhatsApp.", "Fill in the form below: your request reaches our WhatsApp directly.")),
        (L("Échange avec les admissions", "Talk to admissions"), L("Nous vous rappelons pour vous orienter et vous indiquer les pièces du dossier.", "We call you back to advise you and list the documents needed.")),
        (L("Dépôt du dossier", "Submit your file"), L("Vous déposez votre dossier complet au campus, derrière la Tour Mayombe.", "You bring your complete file to the campus, behind the Mayombe Tower.")),
        (L("Inscription définitive", "Final enrolment"), L("Après validation, vous choisissez votre vacation (jour ou soir) et faites votre rentrée.", "Once approved, choose your session (day or evening) and start classes.")),
    ]
    et = "".join(f'<div class="etape apparait"><h3>{t}</h3><p>{d}</p></div>' for t, d in etapes)
    contenu = f"""
{entete_page(lang, 'admissions', L('Admissions', 'Admissions'), L('Rejoignez HEMIP La Percée : pré-inscrivez-vous en ligne, notre service des admissions vous accompagne à chaque étape.', 'Join HEMIP La Percée: pre-register online and our admissions office will guide you at every step.'))}

<section class="bloc">
  <div class="wrap">
    {titre_section(L('Comment s’inscrire', 'How to apply'), L('Quatre étapes simples', 'Four simple steps'))}
    <div class="etapes">{et}</div>
  </div>
</section>

<section class="bloc fond-bleu">
  <div class="wrap grille-3">
    <div class="carte apparait"><div class="ico">{ico('chapeau')}</div><h3>{L('Qui peut postuler ?', 'Who can apply?')}</h3><p>{L('Les titulaires du baccalauréat ou d’un diplôme équivalent pour l’entrée en licence. Les salariés peuvent suivre la vacation du soir.', 'Holders of the baccalauréat or an equivalent diploma, for entry into the Bachelor’s programs. Working students can attend evening classes.')}</p></div>
    <div class="carte rouge apparait"><div class="ico">{ico('bourse')}</div><h3>{L('Bourses d’études', 'Scholarships')}</h3><p>{L('Des bourses sont possibles pour les étudiants les plus méritants. Renseignez-vous lors de votre pré-inscription.', 'Scholarships are available for the most deserving students. Ask about them when you pre-register.')}</p></div>
    <div class="carte apparait"><div class="ico">{ico('livre')}</div><h3>{L('Frais de scolarité', 'Tuition fees')}</h3><p>{L('Les frais d’inscription et de scolarité vous sont communiqués par notre service des admissions, sur simple demande.', 'Registration and tuition fees are provided by our admissions office on request.')}</p></div>
  </div>
</section>

<section class="bloc">
  <div class="wrap deux-col" style="align-items:start">
    <div class="apparait" style="position:sticky;top:120px">
      {titre_section(L('Pré-inscription', 'Pre-registration'), L('Faites le premier pas', 'Take the first step'), L('Deux minutes suffisent. Une fenêtre WhatsApp s’ouvre avec votre demande prête à envoyer à HEMIP.', 'It only takes two minutes. A WhatsApp window opens with your request ready to send to HEMIP.'))}
      <div class="photo-cadre"><img src="{pre}img/etudiante-admissions.webp" alt="{L('Étudiante de HEMIP', 'HEMIP student')}" width="900" height="1350" loading="lazy" style="max-height:440px;object-position:top"></div>
    </div>
    <form class="form-carte apparait" id="form" data-whatsapp="{L('Pré-inscription — site HEMIP', 'Pre-registration — HEMIP website')}" novalidate>
      <h3>{L('Formulaire de pré-inscription', 'Pre-registration form')}</h3>
      <p class="note">{L('Les champs sans mention « facultatif » sont obligatoires.', 'Fields not marked “optional” are required.')}</p>
      <div class="champs">
        <div><label for="f-nom">{L('Nom', 'Last name')}</label><input id="f-nom" name="nom" data-libelle="{L('Nom', 'Last name')}" required autocomplete="family-name"></div>
        <div><label for="f-prenom">{L('Prénom', 'First name')}</label><input id="f-prenom" name="prenom" data-libelle="{L('Prénom', 'First name')}" required autocomplete="given-name"></div>
        <div><label for="f-tel">{L('Téléphone / WhatsApp', 'Phone / WhatsApp')}</label><input id="f-tel" name="tel" type="tel" data-libelle="{L('Téléphone', 'Phone')}" required autocomplete="tel" placeholder="+242 06 …"></div>
        <div><label for="f-mail">E-mail <span class="opt">({L('facultatif', 'optional')})</span></label><input id="f-mail" name="email" type="email" data-libelle="E-mail" autocomplete="email"></div>
        <div><label for="f-ville">{L('Ville', 'City')}</label><input id="f-ville" name="ville" data-libelle="{L('Ville', 'City')}" required autocomplete="address-level2"></div>
        <div><label for="f-dip">{L('Dernier diplôme obtenu', 'Highest diploma')}</label>
          <select id="f-dip" name="diplome" data-libelle="{L('Diplôme', 'Diploma')}" required>
            <option value="">{L('Choisir', 'Choose')}</option>
            <option>{L('Baccalauréat (en cours)', 'Baccalauréat (in progress)')}</option>
            <option>{L('Baccalauréat', 'Baccalauréat')}</option>
            <option>{L('BTS / DUT / Bac+2', 'BTS / DUT / 2-year degree')}</option>
            <option>{L('Licence / Bac+3', 'Bachelor’s / 3-year degree')}</option>
            <option>{L('Autre', 'Other')}</option>
          </select></div>
        <div class="plein"><label for="f-serie">{L('Série du bac et année', 'Baccalauréat series and year')} <span class="opt">({L('facultatif', 'optional')})</span></label><input id="f-serie" name="serie" data-libelle="{L('Série / année', 'Series / year')}" placeholder="{L('ex. C, 2026', 'e.g. C, 2026')}"></div>
        <div class="plein"><label for="f-filiere">{L('Filière souhaitée', 'Preferred program')}</label><select id="f-filiere" name="filiere" data-libelle="{L('Filière', 'Program')}" required>{options_filieres(lang)}</select></div>
        <div class="plein"><span style="display:block;font-weight:600;font-size:.92rem;margin-bottom:6px">{L('Vacation souhaitée', 'Preferred session')}</span>
          <div class="choix">
            <label><input type="radio" name="vacation" value="{L('Cours du jour', 'Day classes')}" data-libelle="{L('Vacation', 'Session')}" checked> {L('Cours du jour', 'Day classes')}</label>
            <label><input type="radio" name="vacation" value="{L('Cours du soir', 'Evening classes')}" data-libelle="{L('Vacation', 'Session')}"> {L('Cours du soir', 'Evening classes')}</label>
          </div></div>
        <div class="plein"><label for="f-msg">{L('Question ou précision', 'Question or comment')} <span class="opt">({L('facultatif', 'optional')})</span></label><textarea id="f-msg" name="message" data-libelle="Message"></textarea></div>
      </div>
      <p class="erreur" role="alert">{L('Merci de remplir les champs obligatoires.', 'Please fill in the required fields.')}</p>
      <div class="form-pied"><small>{L('Vos informations servent uniquement à traiter votre demande d’inscription.', 'Your details are used only to process your application.')}</small>
      <button class="btn btn-rouge" type="submit">{ico('whatsapp')} {L('Envoyer ma pré-inscription', 'Send my application')}</button></div>
    </form>
  </div>
</section>
"""
    return page(lang, "admissions", L("Admissions", "Admissions"),
                L("Pré-inscription en ligne à HEMIP La Percée, Pointe-Noire : conditions d’admission, étapes, bourses d’études et formulaire envoyé sur WhatsApp.",
                  "Apply online to HEMIP La Percée, Pointe-Noire: admission requirements, steps, scholarships and a form sent via WhatsApp."), contenu)


# ---------------------------------------------------------------- CONTACT
def p_contact(lang):
    L = (lambda fr, en: fr if lang == "fr" else en)
    contenu = f"""
{entete_page(lang, 'contact', L('Nous contacter', 'Contact us'), L('Une question sur nos filières, les inscriptions ou un partenariat ? Écrivez-nous, appelez-nous ou passez nous voir au campus.', 'A question about our programs, admissions or a partnership? Write, call or visit us on campus.'))}

<section class="bloc">
  <div class="wrap deux-col" style="align-items:start">
    <div class="apparait">
      <div class="coord"><span class="ico">{ico('lieu')}</span><div><h3>{L('Adresse', 'Address')}</h3><p>{L('Campus de Pointe-Noire<br>Centre-ville, derrière la Tour Mayombe<br>République du Congo', 'Pointe-Noire campus<br>Downtown, behind the Mayombe Tower<br>Republic of the Congo')}</p></div></div>
      <div class="coord"><span class="ico">{ico('tel')}</span><div><h3>{L('Téléphone', 'Phone')}</h3><p><a href="tel:{TEL1}">{TEL1_AFF}</a><br><a href="tel:{TEL2}">{TEL2_AFF}</a></p></div></div>
      <div class="coord"><span class="ico">{ico('whatsapp')}</span><div><h3>WhatsApp</h3><p><a href="https://wa.me/{WA}" target="_blank" rel="noopener">{WA_AFF}</a></p></div></div>
      <div class="coord"><span class="ico">{ico('mail')}</span><div><h3>E-mail</h3><p><a href="mailto:{EMAIL}">{EMAIL}</a></p></div></div>
    </div>
    <form class="form-carte apparait" id="form" data-whatsapp="{L('Message — site HEMIP', 'Message — HEMIP website')}" novalidate>
      <h3>{L('Écrivez-nous', 'Write to us')}</h3>
      <p class="note">{L('Votre message est envoyé à HEMIP par WhatsApp.', 'Your message is sent to HEMIP via WhatsApp.')}</p>
      <div class="champs">
        <div><label for="c-nom">{L('Nom et prénom', 'Full name')}</label><input id="c-nom" name="nom" data-libelle="{L('Nom', 'Name')}" required autocomplete="name"></div>
        <div><label for="c-tel">{L('Téléphone', 'Phone')}</label><input id="c-tel" name="tel" type="tel" data-libelle="{L('Téléphone', 'Phone')}" required autocomplete="tel"></div>
        <div class="plein"><label for="c-objet">{L('Objet', 'Subject')}</label>
          <select id="c-objet" name="objet" data-libelle="{L('Objet', 'Subject')}" required>
            <option value="">{L('Choisir', 'Choose')}</option>
            <option value="info">{L('Information sur les filières', 'Information about programs')}</option>
            <option value="inscription">{L('Inscription', 'Admissions')}</option>
            <option value="formation">{L('Formation continue / séminaire', 'Continuing education / seminar')}</option>
            <option value="partenariat">{L('Partenariat', 'Partnership')}</option>
            <option value="autre">{L('Autre', 'Other')}</option>
          </select></div>
        <div class="plein"><label for="c-msg">Message</label><textarea id="c-msg" name="message" data-libelle="Message" required></textarea></div>
      </div>
      <p class="erreur" role="alert">{L('Merci de remplir les champs obligatoires.', 'Please fill in the required fields.')}</p>
      <div class="form-pied"><small>{L('Une fenêtre WhatsApp s’ouvre avec votre message prêt à envoyer.', 'A WhatsApp window opens with your message ready to send.')}</small>
      <button class="btn btn-rouge" type="submit">{ico('whatsapp')} {L('Envoyer', 'Send')}</button></div>
    </form>
  </div>
</section>

<section class="bloc serre fond-bleu">
  <div class="wrap">
    {titre_section(L('Plan d’accès', 'How to find us'), L('Derrière la Tour Mayombe', 'Behind the Mayombe Tower'))}
    <div class="carte-plan apparait">
      <iframe title="{L('Plan : Tour Mayombe, Pointe-Noire', 'Map: Mayombe Tower, Pointe-Noire')}" loading="lazy" referrerpolicy="no-referrer-when-downgrade"
        src="https://maps.google.com/maps?q=Tour%20Mayombe%2C%20Pointe-Noire%2C%20Congo&amp;z=16&amp;output=embed&amp;hl={lang}"></iframe>
    </div>
  </div>
</section>
"""
    return page(lang, "contact", L("Contact", "Contact"),
                L("Contactez HEMIP La Percée : campus au centre-ville de Pointe-Noire derrière la Tour Mayombe, téléphone, WhatsApp et e-mail.",
                  "Contact HEMIP La Percée: campus in downtown Pointe-Noire behind the Mayombe Tower, phone, WhatsApp and e-mail."), contenu)


# ---------------------------------------------------------------- ÉCRITURE
GENERATEURS = {"accueil": p_accueil, **{k: p_sous(k) for k in SOUS_CLES}, "filieres": p_filieres, "recherche": p_recherche,
               "vie": p_vie, "partenaires": p_partenaires, "admissions": p_admissions, "contact": p_contact}


def main():
    (SITE / "en").mkdir(parents=True, exist_ok=True)
    urls = []
    for cle, gen in GENERATEURS.items():
        for lang in ("fr", "en"):
            dossier = SITE if lang == "fr" else SITE / "en"
            (dossier / P[cle][lang]).write_text(gen(lang), encoding="utf-8")
            f = P[cle][lang]
            urls.append(DOMAINE + "/" + ("" if lang == "fr" else "en/") + ("" if f == "index.html" else f))
    sm = ['<?xml version="1.0" encoding="UTF-8"?>', '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">']
    sm += [f"  <url><loc>{u}</loc></url>" for u in urls]
    sm.append("</urlset>")
    (SITE / "sitemap.xml").write_text("\n".join(sm) + "\n", encoding="utf-8")
    (SITE / "robots.txt").write_text(f"User-agent: *\nAllow: /\nSitemap: {DOMAINE}/sitemap.xml\n", encoding="utf-8")
    print(f"{len(urls)} pages générées dans {SITE}")


if __name__ == "__main__":
    main()
