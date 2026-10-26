Option Explicit
' =============================================================================
' Tests executes sous LibreOffice (tests/run_tests.py). Chaque resultat est
' ecrit dans JOURNAL (action "TEST"). MsgBox renvoie 0 et InputBox "" en
' mode sans affichage : les tests appellent les procedures internes.
' =============================================================================

Private Sub Verif(ByVal nom As String, ByVal ok As Boolean, Optional ByVal detail As Variant)
    Dim txt As String
    If ok Then txt = "OK     " Else txt = "ECHEC  "
    txt = txt & nom
    If Not IsMissing(detail) Then txt = txt & "  " & CStr(detail)
    LogAction "TEST", txt, "TESTS"
End Sub

Private Sub LoginAs(ByVal code As String)
    G_Role = code
    G_RoleLabel = RoleLabel(code)
    G_Holder = "test"
    G_Interim = ActiveInterim(code)
    ApplyRights
    BuildHome
End Sub

Private Function CountRows(ByVal sh As String, ByVal col As Long, ByVal valeur As String) As Long
    Dim w As Worksheet, r As Long
    Set w = WS(sh)
    For r = FIRSTROW To LastRow(w, col)
        If CStr(w.Cells(r, col).Value) = valeur Then CountRows = CountRows + 1
    Next r
End Function

Public Sub T_Init()
    Dim sh As Worksheet
    G_TestMode = True
    For Each sh In ThisWorkbook.Worksheets
        sh.Unprotect SYS_PWD
    Next sh
End Sub

Private Sub Etape(ByVal nom As String)
    If Err.Number <> 0 Then Verif nom, False, "Erreur " & Err.Number & " : " & Err.Description
    Err.Clear
End Sub

Public Sub T_All()
    T_Init
    On Error Resume Next
    T_Sha
    Etape "T_Sha"
    T_Open
    Etape "T_Open"
    T_Droits
    Etape "T_Droits"
    T_Refroidis
    Etape "T_Refroidis"
    T_Pointage
    Etape "T_Pointage"
    T_Taux
    Etape "T_Taux"
    T_Adhesions
    Etape "T_Adhesions"
    T_Electeurs
    Etape "T_Electeurs"
    T_Fiche
    Etape "T_Fiche"
    T_Calendrier
    Etape "T_Calendrier"
    T_NouveauMembre
    Etape "T_NouveauMembre"
    T_EnLettres
    Etape "T_EnLettres"
    T_Finances
    Etape "T_Finances"
    T_Patrimoine
    Etape "T_Patrimoine"
    T_Lot4
    Etape "T_Lot4"
    T_Logout
    Etape "T_Logout"
End Sub

Public Sub T_Sha()
    Verif "sha_vide", Sha256Hex("") = "E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855", Sha256Hex("")
    Verif "sha_abc", Sha256Hex("abc") = "BA7816BF8F01CFEA414140DE5DAE2223B00361A396177A9CB410FF61F20015AD"
    Verif "sha_130a", Sha256Hex(String$(130, "a")) = "1E3C4F4750C8C29BBFA9CED317788176B156D342E57F7777F62FD7221A44312F"
    Verif "mdp_initial", CheckPassword("ADMIN", "chorale")
    Verif "mdp_faux", Not CheckPassword("ADMIN", "Chorale")
    StorePassword "EVA", "Secret#2026"
    Verif "mdp_change", CheckPassword("EVA", "Secret#2026") And Not CheckPassword("EVA", "chorale")
End Sub

Public Sub T_Open()
    AppOpen
    Verif "open_masque", WS(SH_MEMBRES).Visible = xlSheetVeryHidden And WS(SH_ACCUEIL).Visible = xlSheetVisible
    Verif "open_ui_version", ParamStr("UI_VERSION") = APP_VERSION, ParamStr("UI_VERSION")
    Verif "open_accueil", CStr(WS(SH_ACCUEIL).Range("D8").Value) = "Non connecté", CStr(WS(SH_ACCUEIL).Range("B2").Value)
End Sub

Public Sub T_Droits()
    LoginAs "FIN"
    Verif "fin_membres_L", RightOf(SH_MEMBRES) = "L", RightOf(SH_MEMBRES)
    Verif "fin_presences_masque", RightOf(SH_PRES) = "" And WS(SH_PRES).Visible = xlSheetVeryHidden
    Verif "fin_patrimoine_L", RightOf(SH_PAT) = "L"
    LoginAs "PAT"
    Verif "pat_patrimoine_M", CanEdit(SH_PAT)
    Verif "pat_membres_masque", WS(SH_MEMBRES).Visible = xlSheetVeryHidden
    ' interim : PAT assure l'interim des Finances
    With WS(SH_USERS)
        .Cells(FIRSTROW + 6, ColOf(WS(SH_USERS), "Assure l'intérim de")).Value = "Secrétaire aux Finances"
        .Cells(FIRSTROW + 6, ColOf(WS(SH_USERS), "Début de l'intérim")).Value = Date - 1
        .Cells(FIRSTROW + 6, ColOf(WS(SH_USERS), "Fin de l'intérim")).Value = Date + 10
    End With
    Verif "role_ligne7_PAT", CStr(WS(SH_USERS).Cells(FIRSTROW + 6, 1).Value) = "PAT"
    LoginAs "SG"
    Verif "sg_membres_M", CanEdit(SH_MEMBRES)
    Verif "sg_param_masque", RightOf(SH_PARAM) = "" And WS(SH_PARAM).Visible = xlSheetVeryHidden
    Verif "sg_session", InStr(CStr(WS(SH_ACCUEIL).Range("D8").Value), "Secrétaire Général") > 0, CStr(WS(SH_ACCUEIL).Range("D8").Value)
End Sub

Public Sub T_Pointage()
    Dim ps As Worksheet, n As Long, avant As Long, r As Long
    LoginAs "SG"
    Set ps = WS(SH_POINTAGE)
    ps.Range("C5").Value = "S20261010-REP"
    ChargerPointage
    n = LastRow(ps, 1, OUT_HDR) - OUT_HDR
    Verif "pointage_charge", n >= 90, n & " membre(s) ; " & ps.Range("C6").Value
    Verif "pointage_defaut_P", CStr(ps.Cells(OUT_FIRST, 4).Value) = "P" Or CStr(ps.Cells(OUT_FIRST, 4).Value) = "NC"
    ps.Cells(OUT_FIRST, 4).Value = "R"
    ps.Cells(OUT_FIRST + 1, 4).Value = "AJ"
    ps.Cells(OUT_FIRST + 1, 5).Value = ""
    ValiderPointage
    Verif "pointage_motif_obligatoire", CountRows(SH_PRES, 1, "S20261010-REP") = 0
    ps.Cells(OUT_FIRST + 1, 5).Value = "Maladie"
    ValiderPointage
    Verif "pointage_enregistre", CountRows(SH_PRES, 1, "S20261010-REP") = n, CountRows(SH_PRES, 1, "S20261010-REP") & " ligne(s)"
    r = SeanceRow("S20261010-REP")
    Verif "seance_pointee", CStr(WS(SH_SEANCES).Cells(r, ColOf(WS(SH_SEANCES), "Pointée")).Value) = "OUI", _
        "présents=" & WS(SH_SEANCES).Cells(r, ColOf(WS(SH_SEANCES), "Présents")).Value & " taux=" & WS(SH_SEANCES).Cells(r, ColOf(WS(SH_SEANCES), "Taux de la séance")).Value
    ' re-pointage : pas de doublons
    ps.Range("C5").Value = "S20261010-REP"
    ChargerPointage
    Verif "repointage_codes_repris", CStr(ps.Cells(OUT_FIRST, 4).Value) = "R"
    ValiderPointage
    Verif "repointage_sans_doublon", CountRows(SH_PRES, 1, "S20261010-REP") = n
    avant = CountRows(SH_PRES, 8, "50")
    Verif "penalite_retard", avant > 0, avant & " pénalité(s) de 50"
End Sub

Public Sub T_Taux()
    Dim ts As Worksheet
    LoginAs "SG"
    Set ts = WS(SH_TAUX)
    ts.Range("C5").Value = DateSerial(2026, 1, 1)
    ts.Range("E5").Value = DateSerial(2026, 10, 13)
    ts.Range("G5").Value = "TOUS"
    CalculerTaux
    Verif "taux_groupe", IsNumeric(ts.Range("C6").Value) And ts.Range("C6").Value > 0.5 And ts.Range("C6").Value < 1, "groupe=" & ts.Range("C6").Value & " séances=" & ts.Range("E6").Value
    Verif "taux_rang1", ts.Cells(OUT_FIRST, 1).Value = 1 And ts.Cells(OUT_FIRST, 15).Value >= ts.Cells(OUT_FIRST + 1, 15).Value, ts.Cells(OUT_FIRST, 3).Value & " " & ts.Cells(OUT_FIRST, 15).Value
    Verif "taux_pupitres", CStr(ts.Cells(OUT_HDR + 1, 18).Value) <> "", ts.Cells(OUT_HDR + 1, 18).Value & "=" & ts.Cells(OUT_HDR + 1, 20).Value
    ts.Range("G5").Value = "CULTE"
    CalculerTaux
    Verif "taux_filtre_culte", IsNumeric(ts.Range("C6").Value), "culte=" & ts.Range("C6").Value & " séances=" & ts.Range("E6").Value
    TauxCeTrimestre
    Verif "taux_trimestre", ts.Range("C5").Value = DateSerial(2026, 10, 1), CStr(ts.Range("C5").Value) & " - " & CStr(ts.Range("E5").Value)
End Sub

Public Sub T_Adhesions()
    Dim sh As Worksheet, r As Long, lr As Long, s As String, nPat As Long, mat As String, rA As Long
    LoginAs "SG"
    Set sh = WS(SH_ADH)
    DoActualiserDossiers True
    lr = LastRow(sh, 1)
    For r = FIRSTROW To lr
        s = s & " | " & sh.Cells(r, 1).Value & ": " & sh.Cells(r, ColOf(sh, "Proposition")).Value & " (" & Format$(sh.Cells(r, ColOf(sh, "Taux d'assiduité")).Value, "0%") & ")"
    Next r
    Verif "adhesions_propositions", InStr(s, "baptême") > 0 And InStr(s, "manquants") > 0 And InStr(s, "Observation en cours") > 0, s
    Verif "adhesions_lettre_NA", CStr(sh.Cells(FIRSTROW + 1, CheckCol(sh, 3)).Value) = "N/A"
    ' Decision : confirmer le dossier ADH-2026-002 (meme si l'application le signale)
    rA = FIRSTROW + 1
    mat = CStr(sh.Cells(rA, 2).Value)
    nPat = LastRow(WS(SH_PAT), 1)
    sh.Cells(rA, ColOf(sh, "Décision")).Value = "Confirmer"
    sh.Cells(rA, ColOf(sh, "Date de réception")).Value = Date
    sh.Cells(rA, ColOf(sh, "Officiant")).Value = "1er Responsable"
    sh.Cells(rA + 1, ColOf(sh, "Décision")).Value = "Prolonger"
    sh.Cells(rA + 1, ColOf(sh, "Motif")).Value = "Tenue manquante"
    sh.Cells(rA + 1, ColOf(sh, "Nouvelle fin d'observation")).Value = Date + 30
    AppliquerDecisions
    Verif "decision_confirme", CStr(MembreValeur(mat, "Statut")) = ST_CONF, CStr(MembreValeur(mat, "Statut"))
    Verif "decision_kit_patrimoine", LastRow(WS(SH_PAT), 1) - nPat = 4, (LastRow(WS(SH_PAT), 1) - nPat) & " article(s)"
    Verif "kit_code_categorie", Left$(CStr(WS(SH_PAT).Cells(LastRow(WS(SH_PAT), 1), 1).Value), 4) = "CUI-", CStr(WS(SH_PAT).Cells(LastRow(WS(SH_PAT), 1), 1).Value)
    Verif "decision_dossier_clos", Left$(CStr(sh.Cells(rA, ColOf(sh, "Statut du dossier")).Value), 4) = "Clos"
    Verif "decision_prolonge", Left$(CStr(sh.Cells(rA + 1, ColOf(sh, "Statut du dossier")).Value), 8) = "Prolongé", CStr(sh.Cells(rA + 1, ColOf(sh, "Statut du dossier")).Value)
End Sub

Public Sub T_Electeurs()
    LoginAs "SG"
    GenererElecteurs
    Verif "electeurs", LastRow(WS(SH_ELEC), 1, OUT_HDR) - OUT_HDR > 50, WS(SH_ELEC).Range("C6").Value
End Sub

Public Sub T_Fiche()
    LoginAs "SG"
    WS(SH_FICHE).Range("C5").Value = "S20261014-REP"
    GenererFicheAppel
    Verif "fiche_appel", LastRow(WS(SH_FICHE), 2, OUT_HDR) - OUT_HDR > 50, WS(SH_FICHE).Range("C6").Value
End Sub

Public Sub T_Calendrier()
    Dim n As Long, n2 As Long
    LoginAs "SG"
    n = GenererCalendrierAnnee(2027)
    Verif "calendrier_2027", n = 104 + 52, n & " séance(s)"
    n2 = GenererCalendrierAnnee(2027)
    Verif "calendrier_sans_doublon", n2 = 0
    Verif "calendrier_id", SeanceRow("S20270106-REP") > 0 And SeanceRow("S20270103-CULTE") > 0
End Sub

Public Sub T_Refroidis()
    Dim c As Collection, noms As String
    LoginAs "SG"
    LoadPresenceCache
    Set c = CandidatsRefroidis(noms)
    Verif "refroidis", c.Count = 3, c.Count & " : " & noms
    RefreshAlerts
    Verif "alertes_accueil", InStr(CStr(WS(SH_ACCUEIL).Cells(AlertRow(), 2).Value), "Aucune") = 0, WS(SH_ACCUEIL).Cells(AlertRow(), 2).Value & " / " & WS(SH_ACCUEIL).Cells(AlertRow() + 1, 2).Value
    MarquerRefroidis
    Verif "refroidis_marques", CountRows(SH_MEMBRES, ColOf(WS(SH_MEMBRES), "Statut"), ST_REFROIDI) = 3
End Sub

Public Sub T_NouveauMembre()
    Dim n As Long
    LoginAs "SG"
    n = LastRow(WS(SH_ADH), 1)
    NouveauMembre
    Verif "nouveau_membre", MembreRow("ADC-0101") > 0 And LastRow(WS(SH_ADH), 1) = n + 1
End Sub

Public Sub T_Logout()
    Logout True
    Verif "logout_masque", WS(SH_MEMBRES).Visible = xlSheetVeryHidden And Not IsLogged()
End Sub

' Modele vierge : aucune operation ne doit echouer sur des feuilles vides
Public Sub T_Vierge()
    Dim n As Long
    Dim t0 As Double
    T_Init
    On Error Resume Next
    AppOpen
    Etape "v_open"
    LoginAs "SG"
    Etape "v_login"
    RefreshAlerts
    Etape "v_alertes"
    Verif "v_alerte_calendrier", InStr(CStr(WS(SH_ACCUEIL).Cells(AlertRow(), 2).Value), "Calendrier") > 0, CStr(WS(SH_ACCUEIL).Cells(AlertRow(), 2).Value)
    WS(SH_TAUX).Range("C5").Value = DateSerial(2026, 1, 1)
    WS(SH_TAUX).Range("E5").Value = DateSerial(2026, 12, 31)
    CalculerTaux
    Etape "v_taux_vide"
    GenererElecteurs
    Etape "v_electeurs_vide"
    DoActualiserDossiers True
    Etape "v_dossiers_vide"
    n = GenererCalendrierAnnee(2026)
    Etape "v_calendrier"
    Verif "v_calendrier_2026", n = 104 + 52, CStr(n)
    NouveauMembre
    Etape "v_nouveau_membre"
    Verif "v_matricule", MembreRow("ADC-0001") > 0
    WS(SH_MEMBRES).Cells(FIRSTROW, ColOf(WS(SH_MEMBRES), "Nom")).Value = "TEST"
    WS(SH_POINTAGE).Range("C5").Value = "S20260103-REP"
    ChargerPointage
    Etape "v_charger"
    Verif "v_pointage_1", LastRow(WS(SH_POINTAGE), 1, OUT_HDR) - OUT_HDR = 0, "membre arrivé après la séance : non attendu"
    WS(SH_MEMBRES).Cells(FIRSTROW, ColOf(WS(SH_MEMBRES), "Date d'arrivée")).Value = DateSerial(2026, 1, 1)
    ChargerPointage
    ValiderPointage
    Etape "v_valider"
    Verif "v_presences", CountRows(SH_PRES, 1, "S20260103-REP") = 1
    GenererFicheAppel
    Etape "v_fiche"
    ' Finances sur le modele vierge
    Dim e As Double, b As Double, so As Double, p As String, nb As Long, tot As Double
    LoginAs "FIN"
    Soldes Date, e, b, so
    Verif "v_soldes_zero", e = 0 And b = 0 And so = 0
    CotisationsInterne Date, True, nb, tot
    Etape "v_cotisations"
    SuiviBudgetInterne "2026", 10
    Etape "v_suivi_budget_vide"
    Saisir Date, CAISSE_ESP, "Recette", "R02.1 - Collectes ordinaires", "Première collecte", "", 25000, "", "", ""
    p = EnregistrerSaisie(True)
    Verif "v_premiere_ecriture", p = "P-" & Year(Date) & "-0001", p & " " & G_LastError
    Verif "v_premier_recu_absent", RecuDePiece(p) = ""
    Saisir Date, CAISSE_ESP, "Recette", "R04.1", "Don", "M. X", 5000, "", "", ""
    p = EnregistrerSaisie(True)
    Verif "v_premier_recu", RecuDePiece(p) = "REC-" & Year(Date) & "-0001", RecuDePiece(p)
    AfficherSoldes
    Verif "v_affichage_soldes", NumV(WS(SH_SAISIE).Range("G5").Value) = 30000
    RefreshAlerts
    Etape "v_alertes_fin"
    ' Patrimoine sur le modele vierge
    LoginAs "PAT"
    SynthesePatInterne Date
    Etape "v_synthese_vide"
    Verif "v_inventaire_vide", PreparerInventaireInterne("Vide", Date) = 0
    Verif "v_premier_bien", CreerBienInterne("Clavier", "Matériel de musique", 1, "unité", Date, "Don", "Paroisse", "", 100000) = "MUS-0001"
    Verif "v_kit_code", NextCodeBien("Cuisine et kit de sortie") = "CUI-0001"
    Verif "v_pret", PreterInterne("MUS-0001", 1, "ADC-0001", Date + 2, "") <> "", G_LastError
    Verif "v_location_non_louable", NouvelleLocationInterne("X", "", "", Date, Date) <> "" And Not AjouterArticleInterne("LOC-" & Year(Date) & "-001", "MUS-0001", 1)
    RefreshAlerts
    Etape "v_alertes_pat"
    ' Lot 4 sur le modele vierge
    Dim av As String
    LoginAs "RESP1"
    Verif "v_dossier", NouveauDossierInterne("ADC-0001", Date, "Bavardage", "", SANC_VERBAL, AUT_DIR, Date, 0, 0, "") = "DIS-" & Year(Date) & "-001", G_LastError
    AppliquerSanctionsInterne Date
    Etape "v_sanctions"
    Verif "v_activite", NouvelleActiviteInterne(Date + 5, 0, "Activité", "REP", "", "NON", "", "", 0) = "ACT-" & Year(Date + 5) & "-01", G_LastError
    ActualiserPlanningInterne
    Etape "v_planning"
    Verif "v_programme_annuel", ProgrammeAnnuelInterne(ExerciceDe(Date + 5)) = 1
    Verif "v_postes_vacants", InStr(PostesVacants(), "1er Responsable") > 0, PostesVacants()
    Verif "v_scrutin", NouveauScrutinInterne(Date, "Ordinaire", "") = "EL-" & Year(Date) & "-01"
    LoginAs "DIR"
    ActualiserRepertoireInterne Date
    Etape "v_repertoire_vide"
    WS(SH_CANT).Cells(FIRSTROW, 2).Value = "Premier cantique"
    OnCantiquesChange WS(SH_CANT).Rows(FIRSTROW)
    Verif "v_cantique", CantiqueRow("CAN-001") = FIRSTROW And CStr(WS(SH_CANT).Cells(FIRSTROW, ColOf(WS(SH_CANT), "Niveau")).Value) = NIV_ZERO
    Verif "v_programme", AjouterAuProgrammeInterne(Date, "Culte", "CAN-001", "Entrée", av) And RemplirProgrammeChants(Date) = 1, G_LastError
    Verif "v_etude", NouvelleEtudeInterne(Date, "Étude biblique", "Thème", "", "", "") = FIRSTROW
    RefreshAlerts
    Etape "v_alertes_lot4"
    Verif "v_fin", True
End Sub

' Prepare un apercu visuel (feuilles visibles et calculees) pour export PDF
Public Sub T_Visu()
    T_Init
    LoginAs "ADMIN"
    WS(SH_TAUX).Range("C5").Value = DateSerial(2026, 1, 1)
    WS(SH_TAUX).Range("E5").Value = DateSerial(2026, 10, 13)
    WS(SH_TAUX).Range("G5").Value = "TOUS"
    CalculerTaux
    WS(SH_POINTAGE).Range("C5").Value = "S20261010-REP"
    ChargerPointage
    GenererElecteurs
    WS(SH_FICHE).Range("C5").Value = "S20261014-REP"
    GenererFicheAppel
    DoActualiserDossiers True
    RefreshAlerts
    Dim nb As Long, tot As Double
    AllerSaisie
    CotisationsInterne Date, True, nb, tot
    SuiviBudgetInterne "2026", 10
    SuiviCampagneInterne "CAMP-2026-01", True
    RemplirRecu "REC-2026-0010"
    WS(SH_COTIS).Range("C5").Value = Date
    RecalculerPatrimoineInterne Date
    RemplirContrat "LOC-2026-001"
    EtiquettesInterne "MUS"
    SynthesePatInterne Date
    PreparerInventaireInterne "Inventaire de décembre 2026", Date
    FicheBienInterne "MUS-0004"
End Sub

' ============================================================ lot 2
Public Sub T_EnLettres()
    Dim cas As Variant, i As Long
    cas = Array(0, "zéro", 21, "vingt et un", 71, "soixante et onze", 80, "quatre-vingts", 81, "quatre-vingt-un", _
                91, "quatre-vingt-onze", 200, "deux cents", 250, "deux cent cinquante", 1250, "mille deux cent cinquante", _
                80000, "quatre-vingt mille", 200000, "deux cent mille", 2500300, "deux millions cinq cent mille trois cents", _
                1000000, "un million", 99, "quatre-vingt-dix-neuf", 300, "trois cents")
    For i = 0 To UBound(cas) Step 2
        Verif "lettres_" & cas(i), EnLettres(CDbl(cas(i))) = cas(i + 1), EnLettres(CDbl(cas(i)))
    Next i
End Sub

Private Sub Saisir(ByVal d As Date, ByVal caisse As String, ByVal oper As String, ByVal code As String, ByVal libelle As String, _
                   ByVal qui As String, ByVal montant As Variant, ByVal ref As String, ByVal autor As String, ByVal dest As String)
    With WS(SH_SAISIE)
        .Range("C5").Value = d
        .Range("C6").Value = caisse
        .Range("C7").Value = oper
        .Range("C8").Value = code
        .Range("C9").Value = libelle
        .Range("C10").Value = qui
        .Range("C11").Value = montant
        .Range("C12").Value = ref
        .Range("C13").Value = autor
        .Range("C14").Value = dest
    End With
End Sub

Public Sub T_Finances()
    Dim e0 As Double, b0 As Double, s0 As Double, e1 As Double, b1 As Double, s1 As Double, p As String, pv As String, pd As String
    Dim r As Long, sh As Worksheet, n As Long, camp As String, num As String, ecart As Double, mat As String
    Dim nbR As Long, totR As Double, cs As Worksheet, payeAvant As Double, i As Long
    T_Init
    LoginAs "FIN"
    Verif "fin_droit_finances", ModuleRight("FINANCES") = "M"
    Verif "exercice", ExerciceDe(DateSerial(2026, 10, 13)) = "2026" And MoisIndex(DateSerial(2026, 10, 13)) = 10
    Soldes Date, e0, b0, s0
    Verif "soldes_demo", e0 > 0 And b0 > 0 And s0 > 0, "espèces " & e0 & " banque " & b0 & " social " & s0

    ' Recette simple
    Saisir Date, CAISSE_ESP, "Recette", "R02.1 - Collectes ordinaires", "Collecte test", "", 1000, "", "", ""
    p = EnregistrerSaisie(True)
    Soldes Date, e1, b1, s1
    Verif "recette_collecte", p <> "" And e1 = e0 + 1000 And RecuDePiece(p) = "", p & " " & G_LastError
    ' Depense sans autorisation refusee, puis acceptee
    Saisir Date, CAISSE_ESP, "Dépense", "D04.1", "Achat tambour", "Fournisseur", 15000, "", "", ""
    p = EnregistrerSaisie(True)
    Verif "depense_sans_autorisation", p = "" And InStr(G_LastError, "autorisation") > 0, G_LastError
    Saisir Date, CAISSE_ESP, "Dépense", "D04.1", "Achat tambour", "Fournisseur", 15000, "", "PV test", ""
    pd = EnregistrerSaisie(True)
    Soldes Date, e1, b1, s1
    Verif "depense_ok", pd <> "" And e1 = e0 + 1000 - 15000, pd & " " & G_LastError
    ' Rubrique incoherente
    Saisir Date, CAISSE_ESP, "Recette", "D04.1", "Erreur", "", 100, "", "", ""
    Verif "sens_incoherent", EnregistrerSaisie(True) = "", G_LastError
    Saisir Date, CAISSE_ESP, "Recette", "R02.1", "Erreur", "", "12,5x", "", "", ""
    Verif "montant_invalide", EnregistrerSaisie(True) = "", G_LastError
    ' Virement
    Saisir Date, CAISSE_ESP, "Virement", "", "Versement banque test", "", 5000, "", "", CAISSE_BQ
    pv = EnregistrerSaisie(True)
    Soldes Date, e1, b1, s1
    Verif "virement", pv <> "" And e1 = e0 + 1000 - 15000 - 5000 And b1 = b0 + 5000, pv & " " & G_LastError
    r = JournalRow(pv)
    Verif "virement_lie", CStr(WS(SH_CAISSE).Cells(r, CJ_LIEE).Value) <> ""
    ' Recette d'un membre : recu
    Saisir Date, CAISSE_BQ, "Recette", "R04.1", "Don test", "ADC-0001", 2000, "", "", ""
    p = EnregistrerSaisie(True)
    Verif "recu_membre", Left$(RecuDePiece(p), 4) = "REC-", RecuDePiece(p)
    Verif "recu_rempli", RemplirRecu(RecuDePiece(p)) And InStr(CStr(WS(SH_RECU).Range("C10").Value), "deux mille") > 0, CStr(WS(SH_RECU).Range("C10").Value)
    ' Annulations
    Verif "annulation_depense", AnnulerPiece(pd, "test") <> "", G_LastError
    Verif "annulation_virement", AnnulerPiece(pv, "test") <> "", G_LastError
    Soldes Date, e1, b1, s1
    Verif "soldes_apres_annulations", e1 = e0 + 1000 And b1 = b0 + 2000, e1 - e0 & " / " & b1 - b0
    Verif "double_annulation_refusee", AnnulerPiece(pd, "test") = ""

    ' Cotisations
    mat = "ADC-0003"
    CotisationsInterne Date, True, nbR, totR
    Set cs = WS(SH_COTIS)
    For i = OUT_FIRST To LastRow(cs, 1, OUT_HDR)
        If CStr(cs.Cells(i, 1).Value) = mat Then payeAvant = NumV(cs.Cells(i, 8).Value): Exit For
    Next i
    Verif "cotisations_calcul", LastRow(cs, 1, OUT_HDR) - OUT_HDR > 80, (LastRow(cs, 1, OUT_HDR) - OUT_HDR) & " membres ; " & nbR & " en retard ; " & CStr(cs.Range("E6").Value)
    p = EncaisserPour(mat, 600, CAISSE_ESP, "R01.1", "", "Cotisation test")
    CotisationsInterne Date, True, nbR, totR
    For i = OUT_FIRST To LastRow(cs, 1, OUT_HDR)
        If CStr(cs.Cells(i, 1).Value) = mat Then Exit For
    Next i
    Verif "cotisation_encaissee", NumV(cs.Cells(i, 8).Value) = payeAvant + 600, payeAvant & " -> " & cs.Cells(i, 8).Value & " ; " & cs.Cells(i, 11).Value
    ' Campagne
    camp = CreerCampagne("Campagne test", 1000, 0, "R03.1", "")
    p = EncaisserPour("ADC-0004", 1000, CAISSE_ESP, "R03.1", camp, "Campagne test")
    Verif "campagne", SuiviCampagneInterne(camp, True) = 1000, camp & " " & CStr(WS(SH_SUIVI_CAMP).Range("E6").Value)
    ' Caisse sociale
    num = DeclarerEvenementInterne("Hospitalisation de plus d'une semaine", "ADC-0002", Date, "test")
    r = EvenementRow(num)
    Verif "social_declare", r > 0 And CStr(WS(SH_SOCIAL).Cells(r, 9).Value) <> "", num & " campagne " & CStr(WS(SH_SOCIAL).Cells(r, 9).Value)
    Verif "social_autorisation", VerserAideInterne(num, 50000, CAISSE_ESP, "") = "", G_LastError
    Soldes Date, e0, b0, s0
    p = VerserAideInterne(num, 50000, CAISSE_ESP, "PV test")
    Soldes Date, e1, b1, s1
    Verif "social_aide", p <> "" And s1 = s0 - 50000 And NumV(WS(SH_SOCIAL).Cells(r, 12).Value) = 50000, p & " " & G_LastError
    ' Budget
    n = PreparerExerciceInterne("2027", True)
    Verif "budget_prepare", n >= 30, n & " ligne(s)"
    n = RepartirBudgetInterne("2027", True)
    Set sh = WS(SH_BUDGET)
    For i = FIRSTROW To LastRow(sh, 2)
        If CStr(sh.Cells(i, 1).Value) = "2027" And CStr(sh.Cells(i, 2).Value) = "R02.1" Then Exit For
    Next i
    Verif "budget_repartition", NumV(sh.Cells(i, ColOf(sh, "M01")).Value) = 75000 And NumV(sh.Cells(i, ColOf(sh, "Budget initial")).Value) = 900000, CStr(sh.Cells(i, ColOf(sh, "M01")).Value)
    Verif "budget_controle", InStr(ControlerBudgetInterne("2027"), "cohérente") > 0
    SuiviBudgetInterne "2026", 10
    Verif "suivi_budget", InStr(CStr(WS(SH_SUIVI_BUDGET).Cells(LastRow(WS(SH_SUIVI_BUDGET), 3, OUT_HDR), 3).Value), "RÉSULTAT") > 0, _
        "résultat " & WS(SH_SUIVI_BUDGET).Range("C6").Value
    ' Arrete de caisse avec manquant
    Soldes Date, e0, b0, s0
    ecart = EnregistrerArreteInterne(e0 - 500, "test", True)
    Soldes Date, e1, b1, s1
    Verif "arrete_manquant", ecart = -500 And e1 = e0 - 500 And CStr(WS(SH_PERTES).Cells(LastRow(WS(SH_PERTES), 1), 3).Value) = "Manquant de caisse", "écart " & ecart
    Verif "rapprochement", RapprochementInterne(Date, b1, "") = 0
    ' Pertes : remboursement
    num = AjouterPerte("Malversation (art. 51)", "ADC-0005", "", "test", 10000, Date)
    p = EncaisserPour("ADC-0005", 4000, CAISSE_ESP, "R09.3", num, "Remboursement " & num)
    ActualiserPertes
    r = LastRow(WS(SH_PERTES), 1)
    Verif "perte_remboursement", NumV(WS(SH_PERTES).Cells(r, 9).Value) = 6000, CStr(WS(SH_PERTES).Cells(r, 9).Value)
    ' Cloture
    Verif "cloture_2025", CloturerExerciceInterne("2025"), G_LastError
    Saisir DateSerial(2025, 12, 31), CAISSE_ESP, "Recette", "R02.1", "Après clôture", "", 100, "", "", ""
    Verif "ecriture_exercice_clos", EnregistrerSaisie(True) = "" And InStr(G_LastError, "clôturé") > 0, G_LastError
    Verif "cloture_double", Not CloturerExerciceInterne("2025")
    ' Droits
    LoginAs "SG"
    Verif "sg_encaissement_refuse", EncaisserPour("ADC-0006", 300, CAISSE_ESP, "R01.1", "", "x") = "", G_LastError
    LoginAs "PAT"
    Verif "pat_interim_finances", ModuleRight("FINANCES") = "M", ModuleRight("FINANCES")
    LoginAs "FIN"
    RefreshAlerts
    Verif "alertes_finances", True, CStr(WS(SH_ACCUEIL).Cells(AlertRow(), 2).Value) & " | " & CStr(WS(SH_ACCUEIL).Cells(AlertRow() + 1, 2).Value) & " | " & CStr(WS(SH_ACCUEIL).Cells(AlertRow() + 2, 2).Value)
End Sub

Public Sub T_PerfFin()
    Dim t As Double, nb As Long, tot As Double
    T_Init
    LoginAs "ADMIN"
    t = Timer
    RefreshAlerts
    Verif "perf_alertes", True, Format$(Timer - t, "0.0") & " s"
    t = Timer
    CotisationsInterne Date, True, nb, tot
    Verif "perf_cotisations", True, Format$(Timer - t, "0.0") & " s"
    t = Timer
    SuiviBudgetInterne "2026", 10
    Verif "perf_suivi_budget", True, Format$(Timer - t, "0.0") & " s"
End Sub

' Reprise du fichier de demonstration du lot 3 dans le modele vierge du lot 4
Public Sub T_Reprise()
    Dim rapport As String
    T_Init
    LoginAs "ADMIN"
    rapport = ReprendreDonneesDe("/tmp/claude-0/lot3_demo.xlsm")
    Verif "reprise_rapport", InStr(rapport, "MEMBRES : 100") > 0, Replace(rapport, vbCrLf, " ")
    Verif "reprise_membre", MembreRow("ADC-0100") > 0
    Verif "reprise_presences", LastRow(WS(SH_PRES), 1) - HDR > 10000, CStr(LastRow(WS(SH_PRES), 1) - HDR)
    Verif "reprise_mdp", CheckPassword("ADMIN", "chorale")
    Verif "reprise_listes_cotisation", StatutCotise("Choriste confirmé")
    Verif "reprise_rubriques_conservees", RubRow("R01.1") > 0
    Verif "reprise_param", ParamStr("SIGLE") = "ADC"
    Verif "reprise_caisse", LastRow(WS(SH_CAISSE), 1) - HDR > 900, CStr(LastRow(WS(SH_CAISSE), 1) - HDR)
    Verif "reprise_patrimoine", BienRow("MUS-0001") > 0 And NumV(BienValeur("MUS-0001", "Durée d'amortissement (ans)")) > 0, CStr(BienValeur("MUS-0001", "Durée d'amortissement (ans)"))
    Verif "reprise_rubriques_lot3", RubRow("R10.1") > 0 And RubRow("D11.1") > 0
    Verif "reprise_mouvements", LastRow(WS(SH_MOUV), 1) > FIRSTROW And LastRow(WS(SH_LOCATIONS), 1) >= FIRSTROW
    Verif "reprise_titulaires", TitulaireDe("RESP1") <> "" And TitulaireDe("DIR") = "", TitulaireDe("RESP1")
    Verif "reprise_role_dir", CheckPassword("DIR", "chorale")
    Verif "reprise_listes_lot4", ListValues("Sanction").Count = 7 And ListValues("Recueil").Count > 0
    Verif "reprise_param_lot4", ParamNum("EXCLUSION_TEMP_MAX_JOURS", 0) = 15
    LoginAs "DIR"
    Verif "reprise_droits_dir", CanEdit(SH_CANT) And RightOf(SH_CAISSE) = ""
    RefreshAlerts
    Etape "reprise_alertes"
End Sub

' ============================================================ lot 3
Private Function Dispo(ByVal code As String) As Double
    RecalculerPatrimoineInterne Date
    Dispo = NumV(BienValeur(code, "Quantité disponible"))
End Function

Public Sub T_Patrimoine()
    Dim code As String, num As String, d0 As Double, r As Long, loc As String, e0 As Double, b0 As Double, s0 As Double
    Dim e1 As Double, b1 As Double, s1 As Double, q0 As Double, n As Long, msg As String, invs As Worksheet, i As Long, per As Long
    T_Init
    WS(SH_USERS).Cells(FIRSTROW + 6, ColOf(WS(SH_USERS), "Assure l'intérim de")).Value = ""
    LoginAs "PAT"
    Verif "pat_droit", CanEdit(SH_PAT) And CanEdit(SH_LOCATIONS) And ModuleRight("FINANCES") = "L"
    RecalculerPatrimoineInterne Date
    Verif "amorti_total", NumV(BienValeur("MUS-0001", "Valeur nette (FCFA)")) = 0, CStr(BienValeur("MUS-0001", "Amortissement cumulé (FCFA)"))
    Verif "amorti_partiel", NumV(BienValeur("MOB-0001", "Valeur nette (FCFA)")) > 0 And NumV(BienValeur("MOB-0001", "Valeur nette (FCFA)")) < 120000, CStr(BienValeur("MOB-0001", "Valeur nette (FCFA)"))
    Verif "code_suivant", NextCodeBien("Matériel de musique") = "MUS-0010", NextCodeBien("Matériel de musique")
    code = CreerBienInterne("Tambour", "Matériel de musique", 2, "pièce", Date, "Achat", "Fournisseur", "", 25000)
    Verif "creation_bien", code = "MUS-0010" And NumV(BienValeur(code, "Valeur totale (FCFA)")) = 50000 And NumV(BienValeur(code, "Durée d'amortissement (ans)")) = 5
    ' Pret et retour
    d0 = Dispo("MOB-0001")
    num = PreterInterne("MOB-0001", 10, "Commission cuisine", Date + 3, "test")
    Verif "pret", num <> "" And Dispo("MOB-0001") = d0 - 10, num & " dispo " & d0 & " -> " & Dispo("MOB-0001")
    Verif "pret_trop", PreterInterne("MOB-0001", 1000, "x", Date, "") = "", G_LastError
    Verif "retour_pret", RetourInterne(num, "Bon", 0, "", "") And Dispo("MOB-0001") = d0
    ' Reparation avec cout (role disposant des finances)
    LoginAs "ADMIN"
    num = ReparationInterne("MOB-0002", 1, "Électronicien", Date + 5, "test")
    Verif "reparation_envoi", num <> "" And CStr(BienValeur("MOB-0002", "État")) = "À réparer", G_LastError
    Verif "reparation_retour", RetourInterne(num, "Bon", 8000, CAISSE_ESP, ""), G_LastError
    r = MouvementRow(num)
    Verif "reparation_caisse", CStr(WS(SH_MOUV).Cells(r, MV_PIECE).Value) <> "" And CStr(BienValeur("MOB-0002", "État")) = "Bon", CStr(WS(SH_MOUV).Cells(r, MV_PIECE).Value)
    ' Perte avec responsable
    q0 = NumV(BienValeur("MUS-0003", "Quantité"))
    per = LastRow(WS(SH_PERTES), 1)
    num = PerteBienInterne("MUS-0003", "Perte ou vol", 1, "ADC-0010", "test")
    Verif "perte_bien", num <> "" And NumV(BienValeur("MUS-0003", "Quantité")) = q0 - 1 And LastRow(WS(SH_PERTES), 1) = per + 1 And _
        CStr(WS(SH_PERTES).Cells(per + 1, 4).Value) = "ADC-0010", G_LastError & " montant " & CStr(WS(SH_PERTES).Cells(per + 1, 7).Value)
    ' Location complete
    LoginAs "PAT"
    loc = NouvelleLocationInterne("Groupe test", "06 000 00 00", "Concert", Date + 5, Date + 6)
    Verif "loc_article_non_louable", Not AjouterArticleInterne(loc, "MUS-0005", 1), G_LastError
    Verif "loc_article", AjouterArticleInterne(loc, "MUS-0004", 1), G_LastError
    r = LocationRow(loc)
    Verif "loc_montants", NumV(WS(SH_LOCATIONS).Cells(r, 9).Value) = 20000 And NumV(WS(SH_LOCATIONS).Cells(r, 10).Value) = 99000, _
        WS(SH_LOCATIONS).Cells(r, 9).Value & " / " & WS(SH_LOCATIONS).Cells(r, 10).Value
    Verif "loc_approbation_incomplete", Not ApprouverInterne(loc, "", "")
    Verif "loc_approuvee", ApprouverInterne(loc, "Favorable", "PV test"), G_LastError
    Verif "loc_encaissement_refuse_pat", Not EncaisserLocationInterne(loc, CAISSE_ESP), G_LastError
    Verif "loc_remise_avant_paiement", Not RemettreInterne(loc)
    LoginAs "FIN"
    Soldes Date, e0, b0, s0
    Verif "loc_encaissee", EncaisserLocationInterne(loc, CAISSE_ESP), G_LastError
    LoginAs "PAT"
    d0 = Dispo("MUS-0004")
    Verif "loc_remise", RemettreInterne(loc) And Dispo("MUS-0004") = d0 - 1, G_LastError
    Verif "loc_retour", RetourLocationInterne(loc, "À réparer", 15000, "Grille abîmée") And CStr(BienValeur("MUS-0004", "État")) = "À réparer", G_LastError
    LoginAs "FIN"
    Verif "loc_caution", RestituerCautionInterne(loc, CAISSE_ESP), G_LastError
    Soldes Date, e1, b1, s1
    Verif "loc_solde_net", e1 - e0 = 20000 + 15000, CStr(e1 - e0)
    Verif "loc_cloturee", CStr(WS(SH_LOCATIONS).Cells(r, 13).Value) = "Clôturée"
    Verif "loc_contrat", RemplirContrat(loc) And InStr(CStr(WS(SH_CONTRAT).Range("B3").Value), loc) > 0
    ' Achat de materiel sans fiche
    n = AchatsSansFiche()
    Saisir Date, CAISSE_ESP, "Dépense", "D04.1", "Achat flûte", "Fournisseur", 9000, "", "", ""
    num = EnregistrerSaisie(True)
    Verif "achat_sans_fiche", AchatsSansFiche() = n + 1, n & " -> " & AchatsSansFiche()
    LoginAs "PAT"
    code = CreerBienInterne("Flûte", "Matériel de musique", 1, "pièce", Date, "Achat", "Fournisseur", num, 9000)
    Verif "achat_fiche_creee", AchatsSansFiche() = n
    ' Inventaire avec ecart
    n = PreparerInventaireInterne("Inventaire test", Date)
    Set invs = WS(SH_INVENT)
    Verif "inventaire_prepare", n > 20, CStr(n)
    q0 = NumV(BienValeur("MOB-0001", "Quantité"))
    For i = OUT_FIRST To LastRow(invs, 1, OUT_HDR)
        If CStr(invs.Cells(i, 1).Value) = "MOB-0001" Then
            invs.Cells(i, 6).Value = NumV(invs.Cells(i, 5).Value) - 2
        Else
            invs.Cells(i, 6).Value = invs.Cells(i, 5).Value
        End If
    Next i
    per = LastRow(WS(SH_PERTES), 1)
    msg = ValiderInventaireInterne()
    Verif "inventaire_valide", InStr(msg, "1 écart") > 0 And NumV(BienValeur("MOB-0001", "Quantité")) = q0 - 2 And LastRow(WS(SH_PERTES), 1) = per + 1, Replace(msg, vbCrLf, " ")
    ' Etiquettes, synthese, fiche, alertes
    Verif "etiquettes", EtiquettesInterne("MUS") >= 10, CStr(EtiquettesInterne("MUS"))
    SynthesePatInterne Date
    Verif "synthese", InStr(CStr(WS(SH_SYNTH).Range("C6").Value), "Valeur nette totale") > 0, CStr(WS(SH_SYNTH).Range("C6").Value)
    Verif "fiche_bien", FicheBienInterne("MUS-0004") And CStr(WS(SH_FICHEB).Range("C5").Value) = "MUS-0004"
    RefreshAlerts
    msg = ""
    For i = 0 To 8
        msg = msg & CStr(WS(SH_ACCUEIL).Cells(AlertRow() + i, 2).Value) & " | "
    Next i
    Verif "alertes_patrimoine", InStr(msg, "non rendu") > 0 And InStr(msg, "réparer") > 0, msg
End Sub

' ============================================================ lot 4
Private Function MStatut(ByVal mat As String) As String
    MStatut = CStr(MembreValeur(mat, "Statut"))
End Function

Private Function DVal(ByVal num As String, ByVal entete As String) As String
    Dim r As Long
    r = DisciplineRow(num)
    If r > 0 Then DVal = CStr(WS(SH_DISC).Cells(r, ColOf(WS(SH_DISC), entete)).Value)
End Function

Private Function PVal(ByVal num As String, ByVal entete As String) As String
    Dim r As Long
    r = ActiviteRow(num)
    If r > 0 Then PVal = CStr(WS(SH_PLAN).Cells(r, ColOf(WS(SH_PLAN), entete)).Value)
End Function

Private Sub SetVoix(ByVal num As String, ByVal mat As String, ByVal voix As Long)
    Dim cs As Worksheet, k As Long
    Set cs = WS(SH_CAND)
    For k = FIRSTROW To LastRow(cs, 1)
        If CStr(cs.Cells(k, 1).Value) = num And CStr(cs.Cells(k, 3).Value) = mat Then cs.Cells(k, 5).Value = voix
    Next k
End Sub

Private Function Contient(ByVal c As Collection, ByVal txt As String) As Boolean
    Dim i As Long
    For i = 1 To c.Count
        If InStr(1, CStr(c.Item(i)), txt) > 0 Then Contient = True
    Next i
End Function

Public Sub T_Lot4()
    Dim num As String, r As Long, avert As String, n As Long, txt As String, seance As String, sr As Long, lst As Collection
    Dim mats() As String, noms() As String, pups() As String, codes() As String, stats() As String, i As Long, ok As Boolean
    Dim el As String, us As Worksheet, mr As Long
    T_Init
    ' --- droits et confidentialite
    LoginAs "FIN"
    Verif "l4_fin_discipline_masquee", RightOf(SH_DISC) = "" And WS(SH_DISC).Visible = xlSheetVeryHidden
    LoginAs "CONS"
    Verif "l4_cons_discipline_masquee", RightOf(SH_DISC) = "" And RightOf(SH_NOTIF) = ""
    LoginAs "SG"
    Verif "l4_sg_discipline_L", RightOf(SH_DISC) = "L" And CanEdit(SH_PLAN) And CanEdit(SH_MANDATS) And Not CanEdit(SH_CANT)
    LoginAs "DIR"
    Verif "l4_dir_droits", CanEdit(SH_CANT) And CanEdit(SH_PROGS) And CanEdit(SH_ETUDES) And RightOf(SH_DISC) = "L" And RightOf(SH_CAISSE) = "" And RightOf(SH_MANDATS) = ""
    Verif "l4_dir_titulaire", TitulaireDe("DIR") <> "", TitulaireDe("DIR")
    ' --- discipline
    LoginAs "RESP1"
    Verif "l4_dir_verbal_seulement", ControleSanction("Blâme", AUT_DIR, 0, 0) <> "" And ControleSanction(SANC_VERBAL, AUT_DIR, 0, 0) = ""
    Verif "l4_exclusion_15j", ControleSanction("Exclusion temporaire", "Bureau de la chorale", Date, Date + 15) <> "" And _
        ControleSanction("Exclusion temporaire", "Bureau de la chorale", Date, Date + 14) = "", ControleSanction("Exclusion temporaire", "Bureau de la chorale", Date, Date + 15)
    Verif "l4_exclusion_sans_fin", ControleSanction("Exclusion temporaire", "Bureau de la chorale", Date, 0) <> ""
    num = NouveauDossierInterne("ADC-0030", Date, "Bavardage", "Test", SANC_VERBAL, AUT_DIR, Date, 0, 0, "")
    Verif "l4_verbal", num <> "" And DVal(num, "Statut") = "Terminée" And DVal(num, "Notifiée le") <> "", num & " " & G_LastError
    Verif "l4_refus_dir", NouveauDossierInterne("ADC-0030", Date, "Bavardage", "", "Blâme", AUT_DIR, Date, 0, 0, "") = "", G_LastError
    num = NouveauDossierInterne("ADC-0023", Date, "Retards abusifs", "Test", "Blâme", "Bureau de la chorale", Date, 0, 0, "")
    Verif "l4_recidives", DVal(num, "Récidives (12 mois)") = "2", DVal(num, "Récidives (12 mois)")
    Verif "l4_notification", RemplirNotification(num) And InStr(CStr(WS(SH_NOTIF).Range("C7").Value), "ADC-0023") > 0, CStr(WS(SH_NOTIF).Range("C7").Value)
    EnregistrerNotification num, Date, "En présence de l'intéressé"
    Verif "l4_notifiee_terminee", DVal(num, "Statut") = "Terminée"
    num = NouveauDossierInterne("ADC-0040", Date, "Querelle, bagarre, médisance, mensonge, écart de langage", "Test", "Exclusion temporaire", "Bureau de la chorale", Date, Date, Date + 9, "")
    Verif "l4_exclusion_statut", MStatut("ADC-0040") = "Exclu temporaire" And DVal(num, "Statut antérieur") = ST_CONF, MStatut("ADC-0040") & " / " & G_LastError
    n = MembresAttendus(Date, mats, noms, pups, codes, stats)
    ok = False
    For i = 1 To n
        If mats(i) = "ADC-0040" And codes(i) = "NC" Then ok = True
    Next i
    Verif "l4_exclusion_nc", ok
    Verif "l4_notification_periode", RemplirNotification(num) And InStr(CStr(WS(SH_NOTIF).Range("C17").Value) & CStr(WS(SH_NOTIF).Range("C18").Value) & CStr(WS(SH_NOTIF).Range("C19").Value), "10 jours") > 0
    Verif "l4_demo_suspendu", MStatut("ADC-0098") = "Suspendu" And DVal("DIS-2026-006", "Statut") = "En cours"
    AppliquerSanctionsInterne Date + 10
    Verif "l4_fin_exclusion", MStatut("ADC-0040") = ST_CONF And DVal(num, "Statut") = "Terminée", MStatut("ADC-0040") & " " & DVal(num, "Statut")
    Verif "l4_demo_fin_suspension", MStatut("ADC-0098") = ST_CONF And DVal("DIS-2026-006", "Statut") = "Terminée" And MStatut("ADC-0097") = "Suspendu", MStatut("ADC-0098")
    Verif "l4_lever", LeverSanctionInterne("DIS-2026-005", "Test") And MStatut("ADC-0097") = ST_CONF And DVal("DIS-2026-005", "Statut") = "Levée", G_LastError
    ' refroidis marques par T_Refroidis : dossier a examiner, sans doublon
    n = 0
    For r = FIRSTROW To LastRow(WS(SH_DISC), 1)
        If CStr(WS(SH_DISC).Cells(r, 3).Value) = "ADC-0011" And CStr(WS(SH_DISC).Cells(r, ColOf(WS(SH_DISC), "Statut")).Value) = "À examiner" Then n = n + 1: num = CStr(WS(SH_DISC).Cells(r, 1).Value)
    Next r
    Verif "l4_refroidi_dossier", n = 1 And DossierRefroidi("ADC-0011") = "", CStr(n)
    Verif "l4_decision", DeciderDossierInterne(num, "Avertissement", "Bureau de la chorale", Date, 0, 0) And DVal(num, "Statut") = "En cours", G_LastError
    Set lst = New Collection
    AlertesDiscipline lst
    Verif "l4_alerte_discipline", Contient(lst, "non notifiée"), CStr(lst.Count)
    ' --- planning
    LoginAs "SG"
    Verif "l4_code_budget_inconnu", NouvelleActiviteInterne(Date + 20, 0, "X", "EVANG", "", "NON", "", "X99.9", 0) = ""
    num = NouvelleActiviteInterne(Date + 20, 0, "Sortie test", "EVANG", "Loango", "OUI", "Organisation", "D02.1", 50000)
    Verif "l4_activite", num <> "" And PVal(num, "Statut") = "Projet" And PVal(num, "Validation paroissiale") = "Demandée", num & " " & G_LastError
    Verif "l4_valider_non_votee", ValiderActiviteInterne(num) = "" And InStr(G_LastError, "votée") > 0, G_LastError
    n = VoterPlanningInterne(ExerciceDe(Date + 20), "PV AG test")
    Verif "l4_vote_ag", n >= 1 And PVal(num, "Statut") = "Votée en AG", CStr(n)
    Verif "l4_hors_paroisse", ValiderActiviteInterne(num) = "" And InStr(G_LastError, "art. 6") > 0, G_LastError
    EnregistrerValidationInterne num, "Obtenue", "Lettre test"
    seance = ValiderActiviteInterne(num)
    Verif "l4_seance_creee", seance = "S" & Format$(Date + 20, "yyyymmdd") & "-EVANG" And SeanceRow(seance) > 0 And PVal(num, "Statut") = "Validée", seance & " " & G_LastError
    ActualiserPlanningInterne
    Verif "l4_realise_caisse", NumV(PVal("ACT-2026-03", "Réalisé (FCFA)")) = 140000 And NumV(PVal("ACT-2026-04", "Réalisé (FCFA)")) = 150000, PVal("ACT-2026-03", "Réalisé (FCFA)") & " / " & PVal("ACT-2026-04", "Réalisé (FCFA)")
    sr = SeanceRow(seance)
    WS(SH_SEANCES).Cells(sr, ColOf(WS(SH_SEANCES), "Pointée")).Value = "OUI"
    ActualiserPlanningInterne
    Verif "l4_realisee", PVal(num, "Statut") = "Réalisée"
    WS(SH_SEANCES).Cells(sr, ColOf(WS(SH_SEANCES), "Pointée")).Value = "NON"
    n = ProgrammeAnnuelInterne("2026")
    Verif "l4_programme_annuel", n = 10 And NumV(WS(SH_PROGAN).Cells(OUT_FIRST + n, 7).Value) > 0, CStr(n)
    Set lst = New Collection
    AlertesPlanning lst
    Verif "l4_alerte_planning", Contient(lst, "Planning"), CStr(lst.Count)
    ' --- mandats et elections
    Set lst = New Collection
    AlertesMandats lst
    Verif "l4_alerte_fin_mandat", Contient(lst, "se terminent"), CStr(lst.Count)
    Verif "l4_rang", RangMandat("ADC-0001", "1er Responsable", DateSerial(2027, 1, 18)) = 3 And RangMandat("ADC-0002", "Vice-Responsable", DateSerial(2027, 1, 18)) = 2
    el = NouveauScrutinInterne(DateSerial(2027, 1, 17), "Ordinaire", "")
    Verif "l4_scrutin", el = "EL-2027-01" And InStr(CStr(WS(SH_SCRUTINS).Cells(ScrutinRow(el), 4).Value), "Évangélisation") > 0, el
    Verif "l4_candidat_3e_mandat", AjouterCandidatInterne(el, "1er Responsable", "ADC-0001", avert) And avert <> "", avert & G_LastError
    Verif "l4_candidat_non_confirme", Not AjouterCandidatInterne(el, "1er Responsable", "ADC-0099", avert), G_LastError
    Verif "l4_candidat", AjouterCandidatInterne(el, "1er Responsable", "ADC-0031", avert) And AjouterCandidatInterne(el, "Secrétaire aux Finances", "ADC-0035", avert), G_LastError
    Verif "l4_candidat_doublon", Not AjouterCandidatInterne(el, "1er Responsable", "ADC-0031", avert)
    SetVoix el, "ADC-0001", 30
    SetVoix el, "ADC-0031", 30
    SetVoix el, "ADC-0035", 55
    txt = ProclamerInterne(el, 75)
    Verif "l4_egalite", InStr(G_LastError, "galité") > 0, G_LastError
    SetVoix el, "ADC-0031", 40
    txt = ProclamerInterne(el, 75)
    Verif "l4_proclame", G_LastError = "" And InStr(txt, "40 voix") > 0, G_LastError & Replace(txt, vbCrLf, " | ")
    StorePassword "FIN", "Ancien#2026"
    txt = InstallerElusInterne(el, DateSerial(2027, 1, 18))
    r = MandatEnCours("1er Responsable")
    Verif "l4_nouveau_mandat", CStr(WS(SH_MANDATS).Cells(r, 4).Value) = "ADC-0031" And AsDate(WS(SH_MANDATS).Cells(r, 7).Value) = DateSerial(2029, 1, 17), txt
    Verif "l4_fonction_membres", CStr(MembreValeur("ADC-0031", "Fonction au Bureau")) = "1er Responsable" And CStr(MembreValeur("ADC-0001", "Fonction au Bureau")) = ""
    Set us = WS(SH_USERS)
    Verif "l4_titulaire_role", TitulaireDe("RESP1") = NomComplet(MembreValeur("ADC-0031", "Nom"), MembreValeur("ADC-0031", "Prénoms")) And _
        CheckPassword("FIN", MDP_PROVISOIRE) And CStr(us.Cells(FIRSTROW + 5, ColOf(us, "Doit changer le mot de passe")).Value) = "OUI", TitulaireDe("RESP1")
    Verif "l4_postes_pourvus", PostesVacants() = "", PostesVacants()
    Verif "l4_pv", RemplirPV(el) And InStr(CStr(WS(SH_PV).Range("B4").Value), el) > 0 And HasDate(WS(SH_SCRUTINS).Cells(ScrutinRow(el), 8).Value)
    ' --- cantiques
    LoginAs "DIR"
    Verif "l4_niveau", NiveauGlobal(NIV_OK, NIV_OK, NIV_OK, NIV_OK) = NIV_OK And NiveauGlobal(NIV_OK, NIV_ZERO, NIV_OK, NIV_OK) = NIV_EN_COURS And NiveauGlobal("", "", "", "") = NIV_ZERO
    ActualiserRepertoireInterne DateSerial(2026, 10, 26)
    r = CantiqueRow("CAN-040")
    Verif "l4_derniere_execution", AsDate(WS(SH_CANT).Cells(r, ColOf(WS(SH_CANT), "Dernière exécution")).Value) = DateSerial(2026, 10, 18) And _
        NumV(WS(SH_CANT).Cells(r, ColOf(WS(SH_CANT), "Exécutions (12 mois)")).Value) = 2, CStr(WS(SH_CANT).Cells(r, ColOf(WS(SH_CANT), "Dernière exécution")).Value)
    Verif "l4_repetition", InStr(ControleChant("CAN-020", DateSerial(2026, 11, 1)), "chanté le 18/10/2026") > 0, ControleChant("CAN-020", DateSerial(2026, 11, 1))
    Verif "l4_non_maitrise", InStr(ControleChant("CAN-024", DateSerial(2026, 11, 1)), "maîtrisé") > 0, ControleChant("CAN-024", DateSerial(2026, 11, 1))
    Verif "l4_programme_ok", AjouterAuProgrammeInterne(DateSerial(2026, 11, 8), "Culte dominical", "CAN-001", "Entrée", avert) And avert = "", avert & G_LastError
    Verif "l4_programme_doublon", Not AjouterAuProgrammeInterne(DateSerial(2026, 11, 8), "Culte dominical", "CAN-001", "Entrée", avert)
    Verif "l4_programme_alerte", AjouterAuProgrammeInterne(DateSerial(2026, 11, 8), "Culte dominical", "CAN-040", "Envoi", avert) And InStr(avert, "18/10/2026") > 0, avert
    Verif "l4_programme_imprime", RemplirProgrammeChants(DateSerial(2026, 11, 8)) = 2 And CStr(WS(SH_PROGCH).Cells(OUT_FIRST, 3).Value) = "CAN-001" And _
        CStr(WS(SH_PROGCH).Cells(OUT_FIRST + 1, 2).Value) = "Envoi"
    txt = ControlerProgrammeInterne(DateSerial(2026, 11, 1), True)
    Verif "l4_controle_programme", UBound(Split(txt, vbCrLf)) >= 2, Replace(txt, vbCrLf, " | ")
    Set lst = New Collection
    AlertesCantiques lst
    Verif "l4_alerte_cantiques", Contient(lst, "Cantiques"), CStr(lst.Count)
    Verif "l4_resume_pupitres", InStr(ResumeApprentissage(), "Ténor") > 0
    r = NouvelleEtudeInterne(DateSerial(2026, 11, 6), "Étude biblique", "Test", "Jean 3.16", "Pasteur", "Temple")
    seance = CStr(WS(SH_ETUDES).Cells(r, ColOf(WS(SH_ETUDES), "Séance")).Value)
    Verif "l4_etude_seance", seance = "S20261106-ETUDE" And SeanceRow(seance) > 0, seance
    WS(SH_SEANCES).Cells(SeanceRow(seance), ColOf(WS(SH_SEANCES), "Pointée")).Value = "OUI"
    ActualiserEtudesInterne
    Verif "l4_etude_realisee", CStr(WS(SH_ETUDES).Cells(r, ColOf(WS(SH_ETUDES), "Statut")).Value) = "Réalisée"
    ' --- accueil
    LoginAs "ADMIN"
    RefreshAlerts
    txt = ""
    For i = 0 To 25
        txt = txt & CStr(WS(SH_ACCUEIL).Cells(AlertRow() + i, 2).Value) & " | "
    Next i
    Verif "l4_alertes_accueil", InStr(txt, "Discipline") > 0 And InStr(txt, "Mandats") > 0 And InStr(txt, "Cantiques") > 0, txt
    Verif "l4_alertes_sous_menu", AlertRow() > 34, CStr(AlertRow())
End Sub
