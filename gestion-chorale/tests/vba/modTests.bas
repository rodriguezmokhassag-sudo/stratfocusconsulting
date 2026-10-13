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
    G_Interim = ""
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
End Sub
