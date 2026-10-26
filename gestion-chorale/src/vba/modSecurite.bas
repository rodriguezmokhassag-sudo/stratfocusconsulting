Option Explicit
' =============================================================================
' modSecurite : connexion par role, mots de passe (SHA-256 sale), droits,
'               visibilite et protection des feuilles
' =============================================================================

Public G_Role As String          ' code du role connecte (ADMIN, RESP1, ...)
Public G_RoleLabel As String
Public G_Holder As String        ' titulaire du role
Public G_Interim As String       ' role supplee pendant un interim

Private m_Rights As Collection
Private m_Fails As Long

Private P2(0 To 30) As Long
Private KK(0 To 63) As Long
Private m_ShaInit As Boolean

' ============================================================ SHA-256
Private Sub InitSha()
    Dim i As Long, v As Variant
    P2(0) = 1
    For i = 1 To 30
        P2(i) = P2(i - 1) * 2
    Next i
    v = Array(1116352408, 1899447441, -1245643825, -373957723, 961987163, 1508970993, -1841331548, -1424204075, _
        -670586216, 310598401, 607225278, 1426881987, 1925078388, -2132889090, -1680079193, -1046744716, _
        -459576895, -272742522, 264347078, 604807628, 770255983, 1249150122, 1555081692, 1996064986, _
        -1740746414, -1473132947, -1341970488, -1084653625, -958395405, -710438585, 113926993, 338241895, _
        666307205, 773529912, 1294757372, 1396182291, 1695183700, 1986661051, -2117940946, -1838011259, _
        -1564481375, -1474664885, -1035236496, -949202525, -778901479, -694614492, -200395387, 275423344, _
        430227734, 506948616, 659060556, 883997877, 958139571, 1322822218, 1537002063, 1747873779, _
        1955562222, 2024104815, -2067236844, -1933114872, -1866530822, -1538233109, -1090935817, -965641998)
    For i = 0 To 63
        KK(i) = CLng(v(i))
    Next i
    m_ShaInit = True
End Sub

Private Function AddU(ByVal a As Long, ByVal b As Long) As Long
    Dim lo As Long, hi As Long
    lo = (a And &HFFFF&) + (b And &HFFFF&)
    hi = ((a And &H7FFF0000) \ &H10000) + ((b And &H7FFF0000) \ &H10000) + (lo \ &H10000)
    If a < 0 Then hi = hi + &H8000&
    If b < 0 Then hi = hi + &H8000&
    hi = hi And &HFFFF&
    lo = lo And &HFFFF&
    If hi >= &H8000& Then
        AddU = ((hi - &H8000&) * &H10000) Or lo Or &H80000000
    Else
        AddU = (hi * &H10000) Or lo
    End If
End Function

Private Function ShrU(ByVal x As Long, ByVal n As Long) As Long
    If n = 0 Then
        ShrU = x
    ElseIf x < 0 Then
        ShrU = ((x And &H7FFFFFFF) \ P2(n)) Or P2(31 - n)
    Else
        ShrU = x \ P2(n)
    End If
End Function

Private Function ShlU(ByVal x As Long, ByVal n As Long) As Long
    If n = 0 Then
        ShlU = x
    Else
        ShlU = (x And (P2(31 - n) - 1)) * P2(n)
        If (x And P2(31 - n)) <> 0 Then ShlU = ShlU Or &H80000000
    End If
End Function

Private Function RotR(ByVal x As Long, ByVal n As Long) As Long
    RotR = ShrU(x, n) Or ShlU(x, 32 - n)
End Function

Private Function MakeWord(ByVal b0 As Long, ByVal b1 As Long, ByVal b2 As Long, ByVal b3 As Long) As Long
    If b0 >= 128 Then
        MakeWord = ((b0 - 128) * &H1000000) Or (b1 * &H10000) Or (b2 * &H100&) Or b3 Or &H80000000
    Else
        MakeWord = (b0 * &H1000000) Or (b1 * &H10000) Or (b2 * &H100&) Or b3
    End If
End Function

Public Function Sha256Hex(ByVal s As String) As String
    Dim bt() As Long, n As Long, i As Long, total As Long, bits As Long
    Dim blk As Long, t As Long, p As Long
    Dim WW(0 To 63) As Long, HH(0 To 7) As Long
    Dim va As Long, vb As Long, vc As Long, vd As Long, ve As Long, vf As Long, vg As Long, vh As Long
    Dim sg0 As Long, sg1 As Long, bs0 As Long, bs1 As Long, vch As Long, vmaj As Long, t1 As Long, t2 As Long
    Dim res As String

    If Not m_ShaInit Then InitSha
    n = Len(s)
    total = ((n + 8) \ 64 + 1) * 64
    ReDim bt(0 To total - 1)
    For i = 1 To n
        bt(i - 1) = Asc(Mid$(s, i, 1)) And 255
    Next i
    bt(n) = 128
    bits = n * 8
    bt(total - 1) = bits And 255
    bt(total - 2) = (bits \ 256) And 255
    bt(total - 3) = (bits \ 65536) And 255
    bt(total - 4) = (bits \ 16777216) And 255

    HH(0) = 1779033703: HH(1) = -1150833019: HH(2) = 1013904242: HH(3) = -1521486534
    HH(4) = 1359893119: HH(5) = -1694144372: HH(6) = 528734635: HH(7) = 1541459225

    For blk = 0 To total \ 64 - 1
        For t = 0 To 15
            p = blk * 64 + t * 4
            WW(t) = MakeWord(bt(p), bt(p + 1), bt(p + 2), bt(p + 3))
        Next t
        For t = 16 To 63
            sg0 = RotR(WW(t - 15), 7) Xor RotR(WW(t - 15), 18) Xor ShrU(WW(t - 15), 3)
            sg1 = RotR(WW(t - 2), 17) Xor RotR(WW(t - 2), 19) Xor ShrU(WW(t - 2), 10)
            WW(t) = AddU(AddU(WW(t - 16), sg0), AddU(WW(t - 7), sg1))
        Next t
        va = HH(0): vb = HH(1): vc = HH(2): vd = HH(3)
        ve = HH(4): vf = HH(5): vg = HH(6): vh = HH(7)
        For t = 0 To 63
            bs1 = RotR(ve, 6) Xor RotR(ve, 11) Xor RotR(ve, 25)
            vch = (ve And vf) Xor ((Not ve) And vg)
            t1 = AddU(AddU(AddU(vh, bs1), AddU(vch, KK(t))), WW(t))
            bs0 = RotR(va, 2) Xor RotR(va, 13) Xor RotR(va, 22)
            vmaj = (va And vb) Xor (va And vc) Xor (vb And vc)
            t2 = AddU(bs0, vmaj)
            vh = vg: vg = vf: vf = ve
            ve = AddU(vd, t1)
            vd = vc: vc = vb: vb = va
            va = AddU(t1, t2)
        Next t
        HH(0) = AddU(HH(0), va): HH(1) = AddU(HH(1), vb)
        HH(2) = AddU(HH(2), vc): HH(3) = AddU(HH(3), vd)
        HH(4) = AddU(HH(4), ve): HH(5) = AddU(HH(5), vf)
        HH(6) = AddU(HH(6), vg): HH(7) = AddU(HH(7), vh)
    Next blk

    For i = 0 To 7
        res = res & Right$("0000000" & Hex$(HH(i)), 8)
    Next i
    Sha256Hex = UCase$(res)
End Function

Private Function NewSalt() As String
    Dim i As Long, s As String
    Randomize
    For i = 1 To 16
        s = s & Mid$("0123456789ABCDEF", Int(Rnd() * 16) + 1, 1)
    Next i
    NewSalt = s
End Function

' ============================================================ utilisateurs
Private Function UserRow(ByVal code As String) As Long
    Dim sh As Worksheet, r As Long, c As Long
    Set sh = WS(SH_USERS)
    c = ColOf(sh, "Code")
    For r = FIRSTROW To LastRow(sh, c)
        If StrComp(CStr(sh.Cells(r, c).Value), code, vbTextCompare) = 0 Then
            UserRow = r
            Exit Function
        End If
    Next r
End Function

Private Function SecRow(ByVal code As String) As Long
    Dim sh As Worksheet, r As Long
    Set sh = WS(SH_SEC)
    For r = FIRSTROW To LastRow(sh, 1)
        If StrComp(CStr(sh.Cells(r, 1).Value), code, vbTextCompare) = 0 Then
            SecRow = r
            Exit Function
        End If
    Next r
    SecRow = LastRow(sh, 1) + 1
    sh.Cells(SecRow, 1).Value = code
End Function

Public Function RoleCodeFromLabel(ByVal lbl As String) As String
    Dim sh As Worksheet, r As Long, cc As Long, cl As Long
    Set sh = WS(SH_USERS)
    cc = ColOf(sh, "Code")
    cl = ColOf(sh, "Rôle")
    For r = FIRSTROW To LastRow(sh, cc)
        If StrComp(CStr(sh.Cells(r, cl).Value), lbl, vbTextCompare) = 0 Or StrComp(CStr(sh.Cells(r, cc).Value), lbl, vbTextCompare) = 0 Then
            RoleCodeFromLabel = CStr(sh.Cells(r, cc).Value)
            Exit Function
        End If
    Next r
End Function

Public Function RoleLabel(ByVal code As String) As String
    Dim r As Long
    r = UserRow(code)
    If r > 0 Then RoleLabel = CStr(WS(SH_USERS).Cells(r, ColOf(WS(SH_USERS), "Rôle")).Value)
End Function

Public Function TitulaireDe(ByVal code As String) As String
    Dim r As Long
    r = UserRow(code)
    If r > 0 Then TitulaireDe = CStr(WS(SH_USERS).Cells(r, ColOf(WS(SH_USERS), "Titulaire")).Value)
End Function

Public Function CheckPassword(ByVal code As String, ByVal pwd As String) As Boolean
    Dim sh As Worksheet, r As Long
    Set sh = WS(SH_SEC)
    r = SecRow(code)
    CheckPassword = (StrComp(Sha256Hex(CStr(sh.Cells(r, 2).Value) & pwd), CStr(sh.Cells(r, 3).Value), vbBinaryCompare) = 0)
End Function

Public Sub StorePassword(ByVal code As String, ByVal pwd As String)
    Dim sh As Worksheet, r As Long, salt As String
    Set sh = WS(SH_SEC)
    r = SecRow(code)
    salt = NewSalt()
    sh.Cells(r, 2).Value = salt
    sh.Cells(r, 3).Value = Sha256Hex(salt & pwd)
End Sub

Public Function ActiveInterim(ByVal code As String) As String
    Dim sh As Worksheet, r As Long, d1 As Date, d2 As Date, cible As String
    Set sh = WS(SH_USERS)
    r = UserRow(code)
    If r = 0 Then Exit Function
    cible = Trim$(CStr(sh.Cells(r, ColOf(sh, "Assure l'intérim de")).Value))
    If cible = "" Then Exit Function
    cible = RoleCodeFromLabel(cible)
    d1 = AsDate(sh.Cells(r, ColOf(sh, "Début de l'intérim")).Value)
    d2 = AsDate(sh.Cells(r, ColOf(sh, "Fin de l'intérim")).Value)
    If d1 > 0 And Date >= d1 And (d2 = 0 Or Date <= d2) Then ActiveInterim = cible
End Function

' ============================================================ droits
Public Function SheetModule(ByVal nom As String) As String
    Select Case UCase$(nom)
        Case SH_PARAM, SH_LISTES, SH_TYPES, SH_CODES, SH_CTRL: SheetModule = "PARAM"
        Case SH_USERS: SheetModule = "USERS"
        Case SH_MEMBRES, SH_ADH: SheetModule = "MEMBRES"
        Case SH_SEANCES, SH_POINTAGE, SH_PRES, SH_TAUX, SH_FICHE: SheetModule = "PRESENCES"
        Case SH_ELEC, SH_MANDATS, SH_SCRUTINS, SH_CAND, SH_PV: SheetModule = "MANDATS"
        Case SH_DISC, SH_NOTIF: SheetModule = "DISCIPLINE"
        Case SH_PLAN, SH_PROGAN: SheetModule = "PLANNING"
        Case SH_CANT, SH_PROGS, SH_PROGCH, SH_ETUDES: SheetModule = "CANTIQUES"
        Case SH_PAT, SH_CATPAT, SH_MOUV, SH_LOCATIONS, SH_CONTRAT, SH_ETIQ, SH_INVENT, SH_INVENTS, SH_SYNTH, SH_FICHEB
            SheetModule = "PATRIMOINE"
        Case SH_JOURNAL: SheetModule = "JOURNAL"
        Case SH_SAISIE, SH_CAISSE, SH_RUBRIQUES, SH_BUDGET, SH_SUIVI_BUDGET, SH_ARRETE, SH_ARRETES, SH_PERTES, SH_RECU, SH_CLOTURES
            SheetModule = "FINANCES"
        Case SH_COTIS, SH_CAMPAGNES, SH_SUIVI_CAMP: SheetModule = "COTISATIONS"
        Case SH_SOCIAL, SH_BAREME: SheetModule = "SOCIAL"
        Case Else: SheetModule = ""
    End Select
End Function

Private Function MaxRight(ByVal a As String, ByVal b As String) As String
    If a = "M" Or b = "M" Then
        MaxRight = "M"
    ElseIf a = "L" Or b = "L" Then
        MaxRight = "L"
    Else
        MaxRight = ""
    End If
End Function

Private Sub LoadRights()
    Dim sh As Worksheet, r As Long, c As Long, ci As Long, v As String
    Set m_Rights = New Collection
    If G_Role = "" Then Exit Sub
    Set sh = WS(SH_DROITS)
    c = ColOf(sh, G_Role)
    If G_Interim <> "" Then ci = ColOf(sh, G_Interim, False)
    For r = FIRSTROW To LastRow(sh, 1)
        If Trim$(CStr(sh.Cells(r, 1).Value)) <> "" Then
            v = UCase$(Trim$(CStr(sh.Cells(r, c).Value)))
            If ci > 0 Then v = MaxRight(v, UCase$(Trim$(CStr(sh.Cells(r, ci).Value))))
            If v <> "M" And v <> "L" Then v = ""
            m_Rights.Add v, UCase$(CStr(sh.Cells(r, 1).Value))
        End If
    Next r
End Sub

Public Function ModuleRight(ByVal modu As String) As String
    Dim v As Variant
    If G_Role = "" Then Exit Function
    If m_Rights Is Nothing Then LoadRights
    On Error Resume Next
    v = m_Rights.Item(UCase$(modu))
    On Error GoTo 0
    ModuleRight = CStr(v)
End Function

Public Function RightOf(ByVal sheetName As String) As String
    Dim m As String
    m = SheetModule(sheetName)
    If m = "" Then
        RightOf = IIf(UCase$(sheetName) = SH_ACCUEIL, "L", "")
    Else
        RightOf = ModuleRight(m)
    End If
End Function

Public Function IsLogged() As Boolean
    IsLogged = (G_Role <> "")
End Function

Public Function IsAdmin() As Boolean
    IsAdmin = (G_Role = "ADMIN")
End Function

Public Function CanEdit(ByVal sheetName As String) As Boolean
    CanEdit = (RightOf(sheetName) = "M")
End Function

Public Function RequireLogin() As Boolean
    If IsLogged() Then
        RequireLogin = True
    Else
        MsgBox "Votre session n'est pas ouverte (ou a expiré)." & vbCrLf & _
               "Choisissez votre rôle sur la page d'accueil et connectez-vous.", vbInformation, APP_NAME
        Logout False
    End If
End Function

Public Function RequireEdit(ByVal sheetName As String) As Boolean
    If Not RequireLogin() Then Exit Function
    If CanEdit(sheetName) Then
        RequireEdit = True
    Else
        MsgBox "Votre rôle (" & G_RoleLabel & ") ne permet pas de modifier « " & sheetName & " »." & vbCrLf & _
               "Consultation seulement.", vbExclamation, APP_NAME
    End If
End Function

' ============================================================ protection
Public Sub ProtectSheet(ByVal sh As Worksheet, ByVal droit As String)
    On Error Resume Next
    sh.Unprotect SYS_PWD
    On Error GoTo 0
    If G_TestMode Then Exit Sub
    sh.Cells.Locked = True
    If droit = "M" Then UnlockEditable sh
    If sh.Name = SH_ACCUEIL Then sh.Range("D7").MergeArea.Locked = False
    sh.Protect Password:=SYS_PWD, DrawingObjects:=True, Contents:=True, Scenarios:=True, _
        UserInterfaceOnly:=True, AllowFormattingColumns:=True, AllowFormattingRows:=True, AllowFiltering:=True
    sh.EnableSelection = xlNoRestrictions
End Sub

Private Sub UnlockCols(ByVal sh As Worksheet, ByVal liste As String, ByVal sauf As Boolean)
    Dim lc As Long, c As Long, h As String, inList As Boolean
    lc = LastCol(sh)
    For c = 1 To lc
        h = Trim$(CStr(sh.Cells(HDR, c).Value))
        If h <> "" Then
            inList = (InStr(1, "|" & liste & "|", "|" & h & "|", vbTextCompare) > 0)
            If liste <> "" And InStr(1, "|" & liste & "|", "|CHECK|", vbBinaryCompare) > 0 And IsCheckHeader(h) Then inList = True
            If inList Xor sauf Then sh.Range(sh.Cells(FIRSTROW, c), sh.Cells(MAXROWS, c)).Locked = False
        End If
    Next c
End Sub

Private Sub UnlockEditable(ByVal sh As Worksheet)
    Select Case UCase$(sh.Name)
        Case SH_MEMBRES
            UnlockCols sh, "Matricule", True
        Case SH_ADH
            UnlockCols sh, "Catégorie d'entrée|Début d'observation|Décision|Motif|Nouvelle fin d'observation|Date de réception|Officiant|CHECK", False
        Case SH_SEANCES
            UnlockCols sh, "Date|Type|Heure de début|Heure de fin|Lieu|Thème / Observations|Statut", False
        Case SH_PARAM
            UnlockCols sh, "Valeur", False
        Case SH_LISTES, SH_TYPES, SH_CODES, SH_CTRL
            UnlockCols sh, "", True
        Case SH_USERS
            UnlockCols sh, "Titulaire|Actif|Assure l'intérim de|Début de l'intérim|Fin de l'intérim", False
        Case SH_PAT
            UnlockCols sh, "Code|Valeur totale (FCFA)|Amortissement cumulé (FCFA)|Valeur nette (FCFA)|Quantité sortie|Quantité disponible|Dernier inventaire|Pièce de caisse", True
        Case SH_CATPAT
            UnlockCols sh, "", True
        Case SH_MOUV
            UnlockCols sh, "Observations", False
        Case SH_LOCATIONS
            UnlockCols sh, "Contact|Objet|Caution (FCFA)|Avis commission musicale|Accord du Bureau|Observations", False
        Case SH_INVENT
            sh.Range("C5").Locked = False
            sh.Range("E5").Locked = False
            sh.Range("F" & OUT_FIRST & ":G" & MAXROWS).Locked = False
            sh.Range("I" & OUT_FIRST & ":I" & MAXROWS).Locked = False
        Case SH_SYNTH, SH_FICHEB
            sh.Range("C5").Locked = False
        Case SH_POINTAGE
            sh.Range("C5").Locked = False
            sh.Range("D" & OUT_FIRST & ":E" & MAXROWS).Locked = False
        Case SH_TAUX
            sh.Range("C5").Locked = False
            sh.Range("E5").Locked = False
            sh.Range("G5").Locked = False
        Case SH_FICHE, SH_COTIS, SH_SUIVI_CAMP
            sh.Range("C5").Locked = False
        Case SH_SUIVI_BUDGET
            sh.Range("C5").Locked = False
            sh.Range("E5").Locked = False
        Case SH_SAISIE
            sh.Range("C5:C14").Locked = False
        Case SH_ARRETE
            sh.Range("C5:C17").Locked = False
            sh.Range("C21").Locked = False
        Case SH_RUBRIQUES
            UnlockCols sh, "Choix", True
        Case SH_BUDGET
            UnlockCols sh, "Budget initial|Budget rectifié|M01|M02|M03|M04|M05|M06|M07|M08|M09|M10|M11|M12|Réf. adoption", False
        Case SH_CAMPAGNES
            UnlockCols sh, "Libellé|Montant par membre (FCFA)|Date limite|Code rubrique|Statut", False
        Case SH_SOCIAL
            UnlockCols sh, "Description|Aide prévue (FCFA)|Affectation de la différence|Statut", False
        Case SH_BAREME
            UnlockCols sh, "", True
        Case SH_PERTES
            UnlockCols sh, "Description|Échéancier|Statut", False
        Case SH_DISC
            UnlockCols sh, "Description|Observations", False
        Case SH_PLAN
            UnlockCols sh, "N°|Exercice|Réalisé (FCFA)|Statut|Séance", True
        Case SH_MANDATS
            UnlockCols sh, "Observations", False
        Case SH_SCRUTINS
            UnlockCols sh, "Électeurs inscrits|Observations", False
        Case SH_CAND
            UnlockCols sh, "Voix|Observations", False
        Case SH_CANT
            UnlockCols sh, "N°|Niveau|Dernière exécution|Exécutions (12 mois)", True
        Case SH_PROGS
            UnlockCols sh, "", True
        Case SH_ETUDES
            UnlockCols sh, "Séance", True
        Case SH_PROGAN, SH_PROGCH
            sh.Range("C5").Locked = False
    End Select
End Sub

Public Sub ProtectWorkbook(ByVal etat As Boolean)
    If G_TestMode Then Exit Sub
    On Error Resume Next
    If etat Then
        ThisWorkbook.Protect Password:=SYS_PWD, Structure:=True, Windows:=False
    Else
        ThisWorkbook.Unprotect SYS_PWD
    End If
End Sub

' Rend visibles / masque les feuilles selon le role connecte
Public Sub ApplyRights()
    Dim sh As Worksheet, droit As String
    Dim su As Boolean
    su = Application.ScreenUpdating
    Application.ScreenUpdating = False
    LoadRights
    ProtectWorkbook False
    WS(SH_ACCUEIL).Visible = xlSheetVisible
    For Each sh In ThisWorkbook.Worksheets
        Select Case UCase$(sh.Name)
            Case SH_ACCUEIL: droit = "L"
            Case SH_SEC, SH_DROITS: droit = ""
            Case Else: droit = RightOf(sh.Name)
        End Select
        If droit = "" Then
            If sh.Name <> SH_ACCUEIL Then sh.Visible = xlSheetVeryHidden
        Else
            sh.Visible = xlSheetVisible
        End If
        ProtectSheet sh, droit
    Next sh
    ProtectWorkbook True
    Application.ScreenUpdating = su
End Sub

' Masque tout sauf l'accueil (etat enregistre dans le fichier)
Public Sub HideAll()
    Dim sh As Worksheet
    ProtectWorkbook False
    WS(SH_ACCUEIL).Visible = xlSheetVisible
    WS(SH_ACCUEIL).Activate
    For Each sh In ThisWorkbook.Worksheets
        If sh.Name <> SH_ACCUEIL Then sh.Visible = xlSheetVeryHidden
    Next sh
    ProtectWorkbook True
End Sub

' ============================================================ connexion
Public Sub Connexion()
    Dim lbl As String, code As String, pwd As String, r As Long, sh As Worksheet
    On Error GoTo EH
    If m_Fails >= 5 Then
        MsgBox "Trop d'essais infructueux. Fermez et rouvrez le fichier.", vbCritical, APP_NAME
        Exit Sub
    End If
    lbl = Trim$(CStr(WS(SH_ACCUEIL).Range("D7").Value))
    If lbl = "" Then
        MsgBox "Choisissez d'abord votre rôle dans la case jaune « Rôle ».", vbInformation, APP_NAME
        WS(SH_ACCUEIL).Activate
        WS(SH_ACCUEIL).Range("D7").Select
        Exit Sub
    End If
    code = RoleCodeFromLabel(lbl)
    If code = "" Then
        MsgBox "Rôle inconnu : " & lbl, vbExclamation, APP_NAME
        Exit Sub
    End If
    Set sh = WS(SH_USERS)
    r = UserRow(code)
    If UCase$(CStr(sh.Cells(r, ColOf(sh, "Actif")).Value)) = "NON" Then
        MsgBox "Ce rôle est désactivé. Contactez l'administrateur.", vbExclamation, APP_NAME
        Exit Sub
    End If
    pwd = AskPassword("Mot de passe pour le rôle « " & lbl & " » :", "Connexion")
    If pwd = "" Then Exit Sub
    If Not CheckPassword(code, pwd) Then
        m_Fails = m_Fails + 1
        LogAction "Connexion refusée", lbl, SH_ACCUEIL
        MsgBox "Mot de passe incorrect.", vbExclamation, APP_NAME
        Exit Sub
    End If
    m_Fails = 0
    G_Role = code
    G_RoleLabel = CStr(sh.Cells(r, ColOf(sh, "Rôle")).Value)
    G_Holder = CStr(sh.Cells(r, ColOf(sh, "Titulaire")).Value)
    G_Interim = ActiveInterim(code)
    Set m_Rights = Nothing

    If UCase$(CStr(sh.Cells(r, ColOf(sh, "Doit changer le mot de passe")).Value)) <> "NON" Then
        MsgBox "Première connexion ou mot de passe réinitialisé :" & vbCrLf & _
               "vous devez choisir un nouveau mot de passe personnel.", vbInformation, APP_NAME
        If Not ChangePasswordFor(code, False) Then
            G_Role = "": G_RoleLabel = "": G_Holder = "": G_Interim = ""
            MsgBox "Connexion annulée : le mot de passe n'a pas été changé.", vbExclamation, APP_NAME
            Exit Sub
        End If
    End If
    BeginWork
    sh.Cells(r, ColOf(sh, "Dernière connexion")).Value = Now
    ApplyRights
    BuildHome
    RefreshAlerts
    EndWork
    LogAction "Connexion", IIf(G_Interim <> "", "Intérim de " & G_Interim, ""), SH_ACCUEIL
    WS(SH_ACCUEIL).Activate
    Exit Sub
EH:
    ShowError "Connexion"
End Sub

Public Sub Deconnexion()
    Logout True
End Sub

Public Sub Logout(Optional ByVal confirmer_ As Boolean = False)
    Dim confirmer As Boolean: confirmer = confirmer_   ' copie locale (compatibilite LibreOffice)
    If confirmer And IsLogged() Then LogAction "Déconnexion", "", SH_ACCUEIL
    G_Role = "": G_RoleLabel = "": G_Holder = "": G_Interim = ""
    Set m_Rights = Nothing
    BeginWork
    HideAll
    ProtectSheet WS(SH_ACCUEIL), "L"
    BuildHome
    EndWork
End Sub

' ============================================================ mots de passe
Public Function AskPassword(ByVal prompt As String, ByVal titre As String) As String
    If ParamOui("MASQUER_MDP", True) Then
        AskPassword = PasswordBox(prompt, APP_NAME & " - " & titre)
    Else
        AskPassword = InputBox(prompt, APP_NAME & " - " & titre)
    End If
End Function

Private Function ChangePasswordFor(ByVal code As String, ByVal askOld As Boolean) As Boolean
    Dim p1 As String, p2 As String, minLen As Long, sh As Worksheet
    minLen = ParamNum("LONGUEUR_MIN_MDP", 6)
    If askOld Then
        p1 = AskPassword("Mot de passe actuel :", "Changer le mot de passe")
        If p1 = "" Then Exit Function
        If Not CheckPassword(code, p1) Then
            MsgBox "Mot de passe actuel incorrect.", vbExclamation, APP_NAME
            Exit Function
        End If
    End If
    Do
        p1 = AskPassword("Nouveau mot de passe (au moins " & minLen & " caractères) :", "Nouveau mot de passe")
        If p1 = "" Then Exit Function
        If Len(p1) < minLen Then
            MsgBox "Le mot de passe doit contenir au moins " & minLen & " caractères.", vbExclamation, APP_NAME
        Else
            p2 = AskPassword("Retapez le nouveau mot de passe :", "Confirmation")
            If p2 = "" Then Exit Function
            If p1 = p2 Then Exit Do
            MsgBox "Les deux saisies ne correspondent pas.", vbExclamation, APP_NAME
        End If
    Loop
    Set sh = WS(SH_USERS)
    G_Busy = True
    Application.EnableEvents = False
    StorePassword code, p1
    sh.Cells(UserRow(code), ColOf(sh, "Doit changer le mot de passe")).Value = "NON"
    Application.EnableEvents = True
    G_Busy = False
    LogAction "Mot de passe changé", RoleLabel(code), SH_USERS
    ChangePasswordFor = True
End Function

Public Sub ChangerMonMotDePasse()
    If Not RequireLogin() Then Exit Sub
    If ChangePasswordFor(G_Role, True) Then MsgBox "Mot de passe modifié.", vbInformation, APP_NAME
End Sub

Public Sub ReinitialiserMotDePasse()
    Dim lbl As String, code As String, pwd As String, sh As Worksheet, r As Long, liste As String
    If Not RequireLogin() Then Exit Sub
    If Not IsAdmin() Then
        MsgBox "Seul l'administrateur peut réinitialiser un mot de passe.", vbExclamation, APP_NAME
        Exit Sub
    End If
    Set sh = WS(SH_USERS)
    For r = FIRSTROW To LastRow(sh, 1)
        liste = liste & vbCrLf & "  " & sh.Cells(r, 1).Value & " : " & sh.Cells(r, ColOf(sh, "Rôle")).Value
    Next r
    lbl = InputBox("Code du rôle à réinitialiser :" & liste, APP_NAME)
    If lbl = "" Then Exit Sub
    code = RoleCodeFromLabel(lbl)
    If code = "" Then
        MsgBox "Rôle inconnu.", vbExclamation, APP_NAME
        Exit Sub
    End If
    pwd = AskPassword("Mot de passe provisoire pour « " & RoleLabel(code) & " » :" & vbCrLf & _
                      "(le titulaire devra le changer à sa prochaine connexion)", "Réinitialisation")
    If pwd = "" Then Exit Sub
    G_Busy = True
    Application.EnableEvents = False
    StorePassword code, pwd
    sh.Cells(UserRow(code), ColOf(sh, "Doit changer le mot de passe")).Value = "OUI"
    Application.EnableEvents = True
    G_Busy = False
    LogAction "Mot de passe réinitialisé", RoleLabel(code), SH_USERS
    MsgBox "Mot de passe provisoire enregistré pour « " & RoleLabel(code) & " ».", vbInformation, APP_NAME
End Sub
