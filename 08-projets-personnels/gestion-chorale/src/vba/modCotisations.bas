Option Explicit
' =============================================================================
' modCotisations : cotisations mensuelles (art. 39), penalites de retard,
'                  cotisations speciales (campagnes) et encaissements
' Les paiements sont des recettes du journal portant le matricule du membre :
' ils couvrent les mois les plus anciens d'abord.
' =============================================================================

Public G_CotisTaux As Double   ' taux de recouvrement du dernier calcul (paye / du)

Private Function MoisNum(ByVal d As Date) As Long
    MoisNum = Year(d) * 12 + Month(d) - 1
End Function

Private Function MoisTexte(ByVal m As Long) As String
    MoisTexte = MoisLong((m Mod 12) + 1) & " " & (m \ 12)
End Function

' ============================================================ calcul
Public Sub CalculerCotisations()
    Dim cs As Worksheet, asOf As Date
    If Not RequireLogin() Then Exit Sub
    Set cs = WS(SH_COTIS)
    asOf = AsDate(cs.Range("C5").Value)
    If asOf = 0 Then asOf = Date: cs.Range("C5").Value = asOf
    Dim nb As Long, total As Double
    CotisationsInterne asOf, True, nb, total
End Sub

' Calcule la situation de chaque membre ; ecrit la feuille COTISATIONS si ecrire.
' nbRetard / totalReste : membres ayant au moins MOIS_ALERTE_ARRIERES mois de retard, et total restant du.
Public Sub CotisationsInterne(ByVal asOf As Date, ByVal ecrire As Boolean, ByRef nbRetard As Long, ByRef totalReste As Double)
    Dim ms As Worksheet, cs As Worksheet, mv As Variant, nbm As Long, r As Long, i As Long, k As Long, mat As String
    Dim cMat As Long, cNom As Long, cPre As Long, cSt As Long, cDs As Long, cArr As Long, cTel As Long
    Dim cot As Double, mStart As Long, ms0 As Long, mFin As Long, dus As Long, st As String, codeC As String, codeP As String
    Dim idx As New Collection, paye() As Double, penP() As Double, penD() As Double, pv As Variant, pn As Long, d As Date
    Dim out() As Variant, nOut As Long, couv As Long, arr As Long, reste As Double, penR As Double, tot As Double
    Dim couleurs() As Long, seuilMois As Long, totDu As Double, totPaye As Double, msg As String, debut As Date
    On Error GoTo EH
    Set ms = WS(SH_MEMBRES)
    Set cs = WS(SH_COTIS)
    cot = ParamNum("COTISATION_MENSUELLE", 300)
    debut = AsDate(GetParam("DEBUT_SUIVI_COTISATIONS", ""))
    If debut = 0 Then debut = DateSerial(Year(Date), 1, 1)
    mStart = MoisNum(debut)
    codeC = ParamStr("CODE_COTISATION", "R01.1")
    codeP = ParamStr("CODE_PENALITES", "R06.1")
    seuilMois = ParamNum("MOIS_ALERTE_ARRIERES", 3)
    If ecrire Then BeginWork
    LoadStatuts
    cMat = ColOf(ms, "Matricule"): cNom = ColOf(ms, "Nom"): cPre = ColOf(ms, "Prénoms")
    cSt = ColOf(ms, "Statut"): cDs = ColOf(ms, "Date du statut"): cArr = ColOf(ms, "Date d'arrivée")
    cTel = ColOf(ms, "WhatsApp")
    nbm = ReadBlock(ms, cMat, mv)
    ReDim paye(1 To nbm + 1): ReDim penP(1 To nbm + 1): ReDim penD(1 To nbm + 1)
    For r = 1 To nbm
        mat = CStr(mv(r, cMat))
        If mat <> "" And Not KeyExists(idx, mat) Then idx.Add r, mat
    Next r
    ' Paiements (journal)
    LoadJournal
    For i = 1 To G_JN
        mat = CStr(G_J(i, CJ_MAT))
        If mat <> "" Then
            If KeyExists(idx, mat) Then
                d = AsDate(G_J(i, CJ_DATE))
                If d <= asOf Then
                    k = idx(mat)
                    If CStr(G_J(i, CJ_CODE)) = codeC Then paye(k) = paye(k) + NumV(G_J(i, CJ_REC)) - NumV(G_J(i, CJ_DEP))
                    If CStr(G_J(i, CJ_CODE)) = codeP Then penP(k) = penP(k) + NumV(G_J(i, CJ_REC)) - NumV(G_J(i, CJ_DEP))
                End If
            End If
        End If
    Next i
    ' Penalites dues (pointage)
    pv = PresencesArray(pn)
    For i = 1 To pn
        mat = CStr(pv(i, 4))
        If KeyExists(idx, mat) Then
            d = AsDate(pv(i, 2))
            If d >= debut And d <= asOf Then
                k = idx(mat)
                penD(k) = penD(k) + NumV(pv(i, 8))
            End If
        End If
    Next i
    ReDim out(1 To nbm + 1, 1 To 16)
    ReDim couleurs(1 To nbm + 1)
    For r = 1 To nbm
        mat = CStr(mv(r, cMat))
        If mat <> "" Then
            st = CStr(mv(r, cSt))
            ms0 = mStart
            If AsDate(mv(r, cArr)) > 0 Then
                If MoisNum(AsDate(mv(r, cArr))) > ms0 Then ms0 = MoisNum(AsDate(mv(r, cArr)))
            End If
            If StatutCotise(st) Then
                mFin = MoisNum(asOf)
            ElseIf AsDate(mv(r, cDs)) > 0 Then
                mFin = MoisNum(AsDate(mv(r, cDs))) - 1
            Else
                mFin = ms0 - 1
            End If
            dus = mFin - ms0 + 1
            If dus < 0 Then dus = 0
            If dus > 0 Or paye(r) <> 0 Or penD(r) <> 0 Or penP(r) <> 0 Then
                nOut = nOut + 1
                couv = 0
                If cot > 0 Then couv = Int(paye(r) / cot)
                arr = dus - couv
                reste = dus * cot - paye(r)
                penR = penD(r) - penP(r)
                tot = IIf(reste > 0, reste, 0) + IIf(penR > 0, penR, 0)
                out(nOut, 1) = mat
                out(nOut, 2) = NomComplet(mv(r, cNom), mv(r, cPre))
                out(nOut, 3) = st
                out(nOut, 4) = mv(r, cTel)
                out(nOut, 5) = DateSerial(ms0 \ 12, (ms0 Mod 12) + 1, 1)
                out(nOut, 6) = dus
                out(nOut, 7) = dus * cot
                out(nOut, 8) = paye(r)
                out(nOut, 9) = reste
                out(nOut, 10) = arr
                If couv > 0 Then
                    out(nOut, 11) = MoisTexte(ms0 + couv - 1)
                Else
                    out(nOut, 11) = "-"
                End If
                out(nOut, 12) = penD(r)
                out(nOut, 13) = penP(r)
                out(nOut, 14) = penR
                out(nOut, 15) = tot
                If tot > 0 Then
                    msg = "Bonjour " & Trim$(CStr(mv(r, cPre))) & ", sauf erreur, votre situation au " & Format$(asOf, "dd/mm/yyyy") & " : "
                    If arr > 0 Then msg = msg & arr & " mois de cotisation en retard (" & Fcfa(IIf(reste > 0, reste, 0)) & ")"
                    If penR > 0 Then msg = msg & IIf(arr > 0, " et ", "") & Fcfa(penR) & " de pénalités"
                    msg = msg & ". Merci de régulariser auprès du Secrétaire aux Finances. " & ParamStr("NOM_GROUPE")
                    out(nOut, 16) = msg
                End If
                If arr >= seuilMois Then
                    couleurs(nOut) = RGB(255, 199, 206)
                    nbRetard = nbRetard + 1
                ElseIf arr > 0 Or penR > 0 Then
                    couleurs(nOut) = RGB(255, 235, 156)
                Else
                    couleurs(nOut) = RGB(198, 239, 206)
                End If
                totalReste = totalReste + tot
                totDu = totDu + dus * cot
                totPaye = totPaye + paye(r)
            End If
        End If
    Next r
    If totDu > 0 Then G_CotisTaux = totPaye / totDu Else G_CotisTaux = 0
    If ecrire Then
        cs.Range("A" & OUT_FIRST & ":P" & MAXROWS).ClearContents
        cs.Range("A" & OUT_FIRST & ":P" & MAXROWS).Interior.ColorIndex = xlNone
        If nOut > 0 Then
            cs.Range("A" & OUT_FIRST).Resize(nOut, 16).Value = out
            For i = 1 To nOut
                cs.Range("I" & OUT_HDR + i & ":J" & OUT_HDR + i).Interior.Color = couleurs(i)
            Next i
        End If
        If totDu > 0 Then cs.Range("C6").Value = totPaye / totDu Else cs.Range("C6").Value = ""
        cs.Range("E6").Value = "Dû " & Fcfa(totDu) & " - payé " & Fcfa(totPaye) & " - reste à recouvrer (avec pénalités) " & Fcfa(totalReste) & _
                               " - " & nbRetard & " membre(s) avec au moins " & seuilMois & " mois de retard"
        EndWork
    End If
    Exit Sub
EH:
    If ecrire Then ShowError "Calcul des cotisations"
End Sub

Public Sub TrierCotisations()
    Dim cs As Worksheet, lr As Long
    If Not RequireLogin() Then Exit Sub
    Set cs = WS(SH_COTIS)
    lr = LastRow(cs, 1, OUT_HDR)
    If lr <= OUT_FIRST Then Exit Sub
    BeginWork
    cs.Range("A" & OUT_FIRST & ":P" & lr).Sort Key1:=cs.Range("O" & OUT_FIRST), Order1:=xlDescending, Header:=xlNo
    EndWork
End Sub

' ============================================================ encaissements
' Enregistre un paiement de membre ; renvoie la piece ("" si refus, motif dans G_LastError)
Public Function EncaisserPour(ByVal mat As String, ByVal montant As Double, ByVal caisse As String, ByVal code As String, _
                              ByVal ref As String, ByVal libelle As String) As String
    G_LastError = ""
    If ModuleRight("FINANCES") <> "M" Then G_LastError = "L'encaissement est réservé au Secrétaire aux Finances (ou à son intérimaire).": Exit Function
    If MembreRow(mat) = 0 Then G_LastError = "Membre introuvable : " & mat: Exit Function
    If montant <= 0 Or montant <> Int(montant) Then G_LastError = "Montant invalide.": Exit Function
    If caisse <> CAISSE_ESP And caisse <> CAISSE_BQ Then G_LastError = "Caisse invalide.": Exit Function
    On Error GoTo EH
    BeginWork
    EncaisserPour = EnregistrerEcriture(Date, caisse, "Recette", code, libelle, mat, _
                    NomComplet(MembreValeur(mat, "Nom"), MembreValeur(mat, "Prénoms")), ref, montant, "", "Validée", "", True)
    EndWork
    LogAction "Encaissement", EncaisserPour & " " & code & " " & mat & " : " & Fcfa(montant), SH_CAISSE
    Exit Function
EH:
    G_LastError = Err.Description
    EndWork
End Function

Private Function MembreSelectionne(ByVal feuille As String) As String
    If ActiveSheet.Name <> feuille Or ActiveCell.Row < OUT_FIRST Then Exit Function
    MembreSelectionne = CStr(WS(feuille).Cells(ActiveCell.Row, 1).Value)
End Function

Private Sub EncaisserDialogue(ByVal mat As String, ByVal defaut As Double, ByVal code As String, ByVal ref As String, ByVal quoi As String)
    Dim s As String, caisse As String, piece As String
    s = Replace(InputBox(quoi & " de " & mat & " - montant reçu (FCFA) :", APP_NAME, CStr(defaut)), " ", "")
    If s = "" Or Not IsNumeric(s) Then Exit Sub
    caisse = ChoisirCaisse()
    If caisse = "" Then Exit Sub
    piece = EncaisserPour(mat, CDbl(s), caisse, code, ref, quoi & " - " & NomComplet(MembreValeur(mat, "Nom"), MembreValeur(mat, "Prénoms")))
    If piece = "" Then
        MsgBox G_LastError, vbExclamation, APP_NAME
        Exit Sub
    End If
    If MsgBox("Encaissement enregistré (" & piece & ", reçu " & RecuDePiece(piece) & ")." & vbCrLf & vbCrLf & "Imprimer le reçu ?", vbYesNo + vbQuestion, APP_NAME) = vbYes Then
        If RemplirRecu(RecuDePiece(piece)) Then ApercuRecu
    End If
End Sub

Public Sub EncaisserCotisation()
    Dim mat As String, r As Long, cs As Worksheet, defaut As Double
    If Not RequireLogin() Then Exit Sub
    mat = MembreSelectionne(SH_COTIS)
    If mat = "" Then mat = UCase$(Trim$(InputBox("Matricule du membre :", APP_NAME)))
    If mat = "" Then Exit Sub
    Set cs = WS(SH_COTIS)
    defaut = ParamNum("COTISATION_MENSUELLE", 300)
    If ActiveSheet.Name = SH_COTIS And ActiveCell.Row >= OUT_FIRST Then
        r = ActiveCell.Row
        If NumV(cs.Cells(r, 9).Value) > 0 Then defaut = NumV(cs.Cells(r, 9).Value)
    End If
    EncaisserDialogue mat, defaut, ParamStr("CODE_COTISATION", "R01.1"), "", "Cotisation"
    CalculerCotisations
End Sub

Public Sub EncaisserPenalites()
    Dim mat As String, r As Long, cs As Worksheet, defaut As Double
    If Not RequireLogin() Then Exit Sub
    mat = MembreSelectionne(SH_COTIS)
    If mat = "" Then mat = UCase$(Trim$(InputBox("Matricule du membre :", APP_NAME)))
    If mat = "" Then Exit Sub
    Set cs = WS(SH_COTIS)
    If ActiveSheet.Name = SH_COTIS And ActiveCell.Row >= OUT_FIRST Then
        r = ActiveCell.Row
        defaut = NumV(cs.Cells(r, 14).Value)
    End If
    EncaisserDialogue mat, defaut, ParamStr("CODE_PENALITES", "R06.1"), "", "Pénalités"
    CalculerCotisations
End Sub

' ============================================================ campagnes
Public Function CampagneRow(ByVal code As String) As Long
    Dim sh As Worksheet, r As Long
    Set sh = WS(SH_CAMPAGNES)
    For r = FIRSTROW To LastRow(sh, 1)
        If CStr(sh.Cells(r, 1).Value) = code Then
            CampagneRow = r
            Exit Function
        End If
    Next r
End Function

Public Function CreerCampagne(ByVal libelle As String, ByVal montant As Double, ByVal dlim As Date, ByVal code As String, ByVal evenement As String) As String
    Dim sh As Worksheet, r As Long, k As Long, v As String, n As Long, mx As Long, pre As String, num As String
    Set sh = WS(SH_CAMPAGNES)
    pre = "CAMP-" & Year(Date) & "-"
    For k = FIRSTROW To LastRow(sh, 1)
        v = CStr(sh.Cells(k, 1).Value)
        If Left$(v, Len(pre)) = pre Then
            n = CLng(Val(Mid$(v, Len(pre) + 1)))
            If n > mx Then mx = n
        End If
    Next k
    num = pre & Format$(mx + 1, "00")
    r = LastRow(sh, 1) + 1
    sh.Cells(r, 1).Value = num
    sh.Cells(r, 2).Value = libelle
    sh.Cells(r, 3).Value = montant
    If dlim > 0 Then sh.Cells(r, 4).Value = dlim
    sh.Cells(r, 5).Value = code
    sh.Cells(r, 6).Value = evenement
    sh.Cells(r, 7).Value = "Ouverte"
    sh.Cells(r, 11).Value = Date
    LogAction "Campagne créée", num & " : " & libelle & " (" & Fcfa(montant) & " par membre)", SH_CAMPAGNES
    CreerCampagne = num
End Function

Public Sub NouvelleCampagne()
    Dim libCamp As String, s As String, sd As String, dlim As Date, num As String
    If Not RequireEdit(SH_CAMPAGNES) Then Exit Sub
    libCamp = Trim$(InputBox("Objet de la cotisation spéciale (ex. Tenues 2027) :", APP_NAME))
    If libCamp = "" Then Exit Sub
    s = Replace(InputBox("Montant demandé à chaque membre (FCFA) :", APP_NAME), " ", "")
    If s = "" Or Not IsNumeric(s) Then Exit Sub
    sd = InputBox("Date limite de paiement (jj/mm/aaaa, facultatif) :", APP_NAME)
    If IsDate(sd) Then dlim = CDate(sd)
    BeginWork
    num = CreerCampagne(libCamp, CDbl(s), dlim, ParamStr("CODE_CAMPAGNE", "R03.1"), "")
    EndWork
    WS(SH_SUIVI_CAMP).Range("C5").Value = num
    MsgBox "Campagne " & num & " créée. Le suivi des paiements se fait dans SUIVI_CAMPAGNE.", vbInformation, APP_NAME
End Sub

Public Sub SuivreCampagne()
    Dim sh As Worksheet
    If Not RequireLogin() Then Exit Sub
    Set sh = WS(SH_CAMPAGNES)
    If ActiveSheet.Name = SH_CAMPAGNES And ActiveCell.Row >= FIRSTROW Then
        If CStr(sh.Cells(ActiveCell.Row, 1).Value) <> "" Then WS(SH_SUIVI_CAMP).Range("C5").Value = sh.Cells(ActiveCell.Row, 1).Value
    End If
    WS(SH_SUIVI_CAMP).Activate
    CalculerSuiviCampagne
End Sub

Public Sub CalculerSuiviCampagne()
    Dim code As String
    If Not RequireLogin() Then Exit Sub
    code = Trim$(CStr(WS(SH_SUIVI_CAMP).Range("C5").Value))
    If code = "" Or CampagneRow(code) = 0 Then
        MsgBox "Choisissez une campagne dans la case jaune.", vbInformation, APP_NAME
        Exit Sub
    End If
    SuiviCampagneInterne code, True
End Sub

' Calcule le suivi d'une campagne ; met a jour ses totaux dans CAMPAGNES. Renvoie le total collecte.
Public Function SuiviCampagneInterne(ByVal code As String, ByVal ecrire As Boolean) As Double
    Dim cs As Worksheet, ss As Worksheet, ms As Worksheet, cr As Long, montant As Double, mv As Variant, nbm As Long
    Dim r As Long, i As Long, k As Long, mat As String, idx As New Collection, paye() As Double, dern() As Date
    Dim out() As Variant, nOut As Long, nConc As Long, tot As Double, horsMembre As Double, d As Date, concerne As Boolean
    Dim cMat As Long, cNom As Long, cPre As Long, cSt As Long
    Set cs = WS(SH_CAMPAGNES)
    Set ss = WS(SH_SUIVI_CAMP)
    Set ms = WS(SH_MEMBRES)
    cr = CampagneRow(code)
    If cr = 0 Then Exit Function
    montant = NumV(cs.Cells(cr, 3).Value)
    If ecrire Then BeginWork
    LoadStatuts
    cMat = ColOf(ms, "Matricule"): cNom = ColOf(ms, "Nom"): cPre = ColOf(ms, "Prénoms"): cSt = ColOf(ms, "Statut")
    nbm = ReadBlock(ms, cMat, mv)
    ReDim paye(1 To nbm + 1): ReDim dern(1 To nbm + 1)
    For r = 1 To nbm
        mat = CStr(mv(r, cMat))
        If mat <> "" And Not KeyExists(idx, mat) Then idx.Add r, mat
    Next r
    LoadJournal
    For i = 1 To G_JN
        If CStr(G_J(i, CJ_REF)) = code Then
            mat = CStr(G_J(i, CJ_MAT))
            If mat <> "" And KeyExists(idx, mat) Then
                k = idx(mat)
                paye(k) = paye(k) + NumV(G_J(i, CJ_REC)) - NumV(G_J(i, CJ_DEP))
                d = AsDate(G_J(i, CJ_DATE))
                If d > dern(k) Then dern(k) = d
            Else
                horsMembre = horsMembre + NumV(G_J(i, CJ_REC)) - NumV(G_J(i, CJ_DEP))
            End If
        End If
    Next i
    ReDim out(1 To nbm + 1, 1 To 7)
    For r = 1 To nbm
        mat = CStr(mv(r, cMat))
        concerne = StatutCotise(CStr(mv(r, cSt)))
        If mat <> "" And (concerne Or paye(r) <> 0) Then
            nOut = nOut + 1
            If concerne Then nConc = nConc + 1
            out(nOut, 1) = mat
            out(nOut, 2) = NomComplet(mv(r, cNom), mv(r, cPre))
            out(nOut, 3) = mv(r, cSt)
            out(nOut, 4) = IIf(concerne, montant, 0)
            out(nOut, 5) = paye(r)
            out(nOut, 6) = IIf(concerne, montant, 0) - paye(r)
            If dern(r) > 0 Then out(nOut, 7) = dern(r) Else out(nOut, 7) = ""
            tot = tot + paye(r)
        End If
    Next r
    tot = tot + horsMembre
    cs.Cells(cr, 8).Value = nConc
    cs.Cells(cr, 9).Value = nConc * montant
    cs.Cells(cr, 10).Value = tot
    If ecrire Then
        ss.Range("A" & OUT_FIRST & ":G" & MAXROWS).ClearContents
        ss.Range("A" & OUT_FIRST & ":G" & MAXROWS).Interior.ColorIndex = xlNone
        If nOut > 0 Then
            ss.Range("A" & OUT_FIRST).Resize(nOut, 7).Value = out
            For i = 1 To nOut
                If NumV(out(i, 6)) <= 0 Then
                    ss.Range("F" & OUT_HDR + i).Interior.Color = RGB(198, 239, 206)
                Else
                    ss.Range("F" & OUT_HDR + i).Interior.Color = RGB(255, 235, 156)
                End If
            Next i
        End If
        ss.Range("C6").Value = cs.Cells(cr, 2).Value & " - " & Fcfa(montant) & " par membre"
        ss.Range("E6").Value = "Attendu " & Fcfa(nConc * montant) & " - collecté " & Fcfa(tot) & IIf(horsMembre <> 0, " (dont " & Fcfa(horsMembre) & " hors membres)", "")
        EndWork
    End If
    SuiviCampagneInterne = tot
End Function

Public Sub EncaisserCampagne()
    Dim mat As String, code As String, cr As Long, defaut As Double
    If Not RequireLogin() Then Exit Sub
    code = Trim$(CStr(WS(SH_SUIVI_CAMP).Range("C5").Value))
    cr = CampagneRow(code)
    If cr = 0 Then
        MsgBox "Choisissez d'abord la campagne dans la case jaune.", vbInformation, APP_NAME
        Exit Sub
    End If
    mat = MembreSelectionne(SH_SUIVI_CAMP)
    If mat = "" Then mat = UCase$(Trim$(InputBox("Matricule du membre :", APP_NAME)))
    If mat = "" Then Exit Sub
    If ActiveSheet.Name = SH_SUIVI_CAMP And ActiveCell.Row >= OUT_FIRST Then defaut = NumV(WS(SH_SUIVI_CAMP).Cells(ActiveCell.Row, 6).Value)
    If defaut <= 0 Then defaut = NumV(WS(SH_CAMPAGNES).Cells(cr, 3).Value)
    EncaisserDialogue mat, defaut, CStr(WS(SH_CAMPAGNES).Cells(cr, 5).Value), code, CStr(WS(SH_CAMPAGNES).Cells(cr, 2).Value)
    SuiviCampagneInterne code, True
End Sub

Public Sub ActualiserCampagnes()
    Dim sh As Worksheet, r As Long
    If Not RequireLogin() Then Exit Sub
    Set sh = WS(SH_CAMPAGNES)
    BeginWork
    For r = FIRSTROW To LastRow(sh, 1)
        If CStr(sh.Cells(r, 1).Value) <> "" Then SuiviCampagneInterne CStr(sh.Cells(r, 1).Value), False
    Next r
    EndWork
End Sub
