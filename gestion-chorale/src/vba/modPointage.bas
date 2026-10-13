Option Explicit
' =============================================================================
' modPointage : pointage d'une seance (feuille POINTAGE) et historique PRESENCES
' PRESENCES : A ID seance | B Date | C Type | D Matricule | E Nom et prenoms |
'             F Code | G Motif | H Penalite (FCFA) | I Saisi le | J Saisi par
' =============================================================================

Public Const PR_COLS As Long = 10

' Membres attendus a une date : renvoie le nombre et remplit les tableaux
Public Function MembresAttendus(ByVal d As Date, ByRef mats() As String, ByRef noms() As String, _
                                ByRef pups() As String, ByRef codes() As String, ByRef stats() As String) As Long
    Dim sh As Worksheet, i As Long, nb As Long, n As Long, st As String, cd As String, arr As Date, v As Variant
    Dim cMat As Long, cNom As Long, cPre As Long, cPup As Long, cSt As Long, cArr As Long
    Set sh = WS(SH_MEMBRES)
    cMat = ColOf(sh, "Matricule"): cNom = ColOf(sh, "Nom"): cPre = ColOf(sh, "Prénoms")
    cPup = ColOf(sh, "Pupitre"): cSt = ColOf(sh, "Statut"): cArr = ColOf(sh, "Date d'arrivée")
    LoadStatuts
    nb = ReadBlock(sh, cMat, v)
    ReDim mats(1 To nb + 1): ReDim noms(1 To nb + 1): ReDim pups(1 To nb + 1): ReDim codes(1 To nb + 1): ReDim stats(1 To nb + 1)
    For i = 1 To nb
        If CStr(v(i, cMat)) <> "" Then
            st = CStr(v(i, cSt))
            cd = StatutCodeDefaut(st)
            arr = AsDate(v(i, cArr))
            If cd <> "" And (arr = 0 Or arr <= d) Then
                n = n + 1
                mats(n) = CStr(v(i, cMat))
                noms(n) = NomComplet(v(i, cNom), v(i, cPre))
                pups(n) = CStr(v(i, cPup))
                codes(n) = cd
                stats(n) = st
            End If
        End If
    Next i
    SortMembres mats, noms, pups, codes, stats, n
    MembresAttendus = n
End Function

Private Function PupitreRang(ByVal p As String, ByVal lst As Collection) As String
    Dim i As Long
    For i = 1 To lst.Count
        If StrComp(lst(i), p, vbTextCompare) = 0 Then
            PupitreRang = Format$(i, "00")
            Exit Function
        End If
    Next i
    PupitreRang = "99"
End Function

Private Sub SortMembres(mats() As String, noms() As String, pups() As String, codes() As String, stats() As String, ByVal n As Long)
    Dim i As Long, j As Long, keys() As String, tk As String, t1 As String, t2 As String, t3 As String, t4 As String, t5 As String
    Dim lst As Collection
    If n < 2 Then Exit Sub
    Set lst = ListValues("Pupitre")
    ReDim keys(1 To n)
    For i = 1 To n
        keys(i) = PupitreRang(pups(i), lst) & "|" & UCase$(noms(i))
    Next i
    For i = 2 To n
        tk = keys(i): t1 = mats(i): t2 = noms(i): t3 = pups(i): t4 = codes(i): t5 = stats(i)
        j = i - 1
        Do While j >= 1
            If keys(j) <= tk Then Exit Do
            keys(j + 1) = keys(j): mats(j + 1) = mats(j): noms(j + 1) = noms(j)
            pups(j + 1) = pups(j): codes(j + 1) = codes(j): stats(j + 1) = stats(j)
            j = j - 1
        Loop
        keys(j + 1) = tk: mats(j + 1) = t1: noms(j + 1) = t2: pups(j + 1) = t3: codes(j + 1) = t4: stats(j + 1) = t5
    Next i
End Sub

Public Sub ProchaineSeance()
    Dim sh As Worksheet, r As Long, lr As Long, d As Date
    If Not RequireLogin() Then Exit Sub
    Set sh = WS(SH_SEANCES)
    lr = LastRow(sh, 1)
    For r = FIRSTROW To lr
        d = AsDate(sh.Cells(r, ColOf(sh, "Date")).Value)
        If d > 0 And d <= Date And CStr(sh.Cells(r, ColOf(sh, "Statut")).Value) <> "Annulée" _
           And UCase$(CStr(sh.Cells(r, ColOf(sh, "Pointée")).Value)) <> "OUI" Then
            WS(SH_POINTAGE).Range("C5").Value = sh.Cells(r, 1).Value
            ChargerPointage
            Exit Sub
        End If
    Next r
    MsgBox "Toutes les séances passées sont pointées.", vbInformation, APP_NAME
End Sub

Public Sub ChargerPointage()
    Dim ps As Worksheet, ss As Worksheet, id As String, r As Long, d As Date, n As Long, i As Long, k As Long
    Dim mats() As String, noms() As String, pups() As String, codes() As String, stats() As String
    Dim pr As Variant, lrp As Long, out() As Variant, existe As New Collection, deja As Boolean, extra As Long
    If Not RequireLogin() Then Exit Sub
    On Error GoTo EH
    Set ps = WS(SH_POINTAGE)
    Set ss = WS(SH_SEANCES)
    id = Trim$(CStr(ps.Range("C5").Value))
    If id = "" Then
        ProchaineSeance
        Exit Sub
    End If
    r = SeanceRow(id)
    If r = 0 Then
        MsgBox "Séance introuvable : " & id, vbExclamation, APP_NAME
        Exit Sub
    End If
    If CStr(ss.Cells(r, ColOf(ss, "Statut")).Value) = "Annulée" Then
        MsgBox "Cette séance est annulée : elle ne se pointe pas.", vbExclamation, APP_NAME
        Exit Sub
    End If
    BeginWork
    d = AsDate(ss.Cells(r, ColOf(ss, "Date")).Value)
    n = MembresAttendus(d, mats, noms, pups, codes, stats)
    deja = (UCase$(CStr(ss.Cells(r, ColOf(ss, "Pointée")).Value)) = "OUI")

    ' Pointage existant : on reprend les codes saisis
    Dim motifs() As String
    ReDim motifs(1 To n + 1)
    If deja Then
        Dim idx As New Collection
        For i = 1 To n
            idx.Add i, mats(i)
        Next i
        pr = PresencesArray(lrp)
        For k = 1 To lrp
            If CStr(pr(k, 1)) = id Then
                If KeyExists(idx, CStr(pr(k, 4))) Then
                    i = idx(CStr(pr(k, 4)))
                Else
                    n = n + 1
                    ReDim Preserve mats(1 To n): ReDim Preserve noms(1 To n): ReDim Preserve pups(1 To n)
                    ReDim Preserve codes(1 To n): ReDim Preserve stats(1 To n): ReDim Preserve motifs(1 To n)
                    i = n
                    mats(i) = CStr(pr(k, 4)): noms(i) = CStr(pr(k, 5))
                    pups(i) = CStr(MembreValeur(mats(i), "Pupitre")): stats(i) = CStr(MembreValeur(mats(i), "Statut"))
                    idx.Add i, mats(i)
                End If
                codes(i) = CStr(pr(k, 6))
                motifs(i) = CStr(pr(k, 7))
            End If
        Next k
    End If

    ps.Range("A" & OUT_FIRST & ":F" & MAXROWS).ClearContents
    If n > 0 Then
        ReDim out(1 To n, 1 To 6)
        For i = 1 To n
            out(i, 1) = mats(i): out(i, 2) = noms(i): out(i, 3) = pups(i)
            out(i, 4) = codes(i): out(i, 5) = motifs(i): out(i, 6) = stats(i)
        Next i
        ps.Range("A" & OUT_FIRST).Resize(n, 6).Value = out
    End If
    ps.Range("C6").Value = JourLong(d) & " " & Format$(d, "dd/mm/yyyy") & " - " & ss.Cells(r, ColOf(ss, "Libellé")).Value & _
        IIf(deja, "  (déjà pointée : modification)", "") & "  - " & n & " membre(s)"
    ps.Range("H5").Value = id
    EndWork
    ps.Activate
    ps.Range("D" & OUT_FIRST).Select
    Exit Sub
EH:
    ShowError "Chargement du pointage"
End Sub

Public Sub TousPresents()
    Dim ps As Worksheet, lr As Long, r As Long
    If Not RequireEdit(SH_POINTAGE) Then Exit Sub
    Set ps = WS(SH_POINTAGE)
    lr = LastRow(ps, 1, OUT_HDR)
    BeginWork
    For r = OUT_FIRST To lr
        If CStr(ps.Cells(r, 4).Value) <> "NC" Then ps.Cells(r, 4).Value = "P"
        ps.Cells(r, 5).Value = ""
    Next r
    EndWork
End Sub

Public Function PresencesArray(ByRef n As Long) As Variant
    Dim sh As Worksheet, lr As Long, v As Variant
    Set sh = WS(SH_PRES)
    lr = LastRow(sh, 1)
    n = lr - HDR
    If n <= 0 Then
        n = 0
        PresencesArray = Empty
    ElseIf n = 1 Then
        ReDim v(1 To 1, 1 To PR_COLS)
        Dim c As Long
        For c = 1 To PR_COLS
            v(1, c) = sh.Cells(FIRSTROW, c).Value
        Next c
        PresencesArray = v
    Else
        PresencesArray = sh.Range(sh.Cells(FIRSTROW, 1), sh.Cells(lr, PR_COLS)).Value
    End If
End Function

Public Sub SupprimerPresencesSeance(ByVal id As String)
    Dim sh As Worksheet, v As Variant, n As Long, keep() As Variant, i As Long, k As Long, c As Long
    Set sh = WS(SH_PRES)
    v = PresencesArray(n)
    If n = 0 Then Exit Sub
    ReDim keep(1 To n, 1 To PR_COLS)
    For i = 1 To n
        If CStr(v(i, 1)) <> id Then
            k = k + 1
            For c = 1 To PR_COLS
                keep(k, c) = v(i, c)
            Next c
        End If
    Next i
    If k = n Then Exit Sub
    sh.Range(sh.Cells(FIRSTROW, 1), sh.Cells(FIRSTROW + n - 1, PR_COLS)).ClearContents
    If k > 0 Then sh.Range(sh.Cells(FIRSTROW, 1), sh.Cells(FIRSTROW + k - 1, PR_COLS)).Value = keep
End Sub

Public Sub ValiderPointage()
    Dim ps As Worksheet, ss As Worksheet, pr As Worksheet, id As String, r As Long, lr As Long, i As Long, n As Long
    Dim d As Date, typ As String, code As String, erreurs As String, out() As Variant, ligneBase As Long
    Dim nbPres As Long, pond As Double, att As Long, info As Variant, pen As Double, totPen As Double
    If Not RequireEdit(SH_POINTAGE) Then Exit Sub
    On Error GoTo EH
    Set ps = WS(SH_POINTAGE)
    Set ss = WS(SH_SEANCES)
    Set pr = WS(SH_PRES)
    id = Trim$(CStr(ps.Range("C5").Value))
    If id = "" Or id <> CStr(ps.Range("H5").Value) Then
        MsgBox "Chargez d'abord la séance (bouton « Charger la séance ») avant de valider.", vbExclamation, APP_NAME
        Exit Sub
    End If
    r = SeanceRow(id)
    If r = 0 Then Exit Sub
    d = AsDate(ss.Cells(r, ColOf(ss, "Date")).Value)
    typ = CStr(ss.Cells(r, ColOf(ss, "Type")).Value)
    LoadCodes
    lr = LastRow(ps, 1, OUT_HDR)
    n = lr - OUT_HDR
    If n <= 0 Then
        MsgBox "Aucun membre à pointer.", vbExclamation, APP_NAME
        Exit Sub
    End If
    ' Controles
    For i = OUT_FIRST To lr
        code = UCase$(Trim$(CStr(ps.Cells(i, 4).Value)))
        If Not CodeExiste(code) Then
            erreurs = erreurs & vbCrLf & "- " & ps.Cells(i, 2).Value & " : code « " & code & " » inconnu"
        ElseIf CodeMotifObligatoire(code) And Trim$(CStr(ps.Cells(i, 5).Value)) = "" Then
            erreurs = erreurs & vbCrLf & "- " & ps.Cells(i, 2).Value & " : motif obligatoire pour " & code
        End If
        If Len(erreurs) > 900 Then Exit For
    Next i
    If erreurs <> "" Then
        MsgBox "Pointage non enregistré. À corriger :" & erreurs, vbExclamation, APP_NAME
        Exit Sub
    End If
    BeginWork
    SupprimerPresencesSeance id
    ReDim out(1 To n, 1 To PR_COLS)
    For i = 1 To n
        code = UCase$(Trim$(CStr(ps.Cells(OUT_HDR + i, 4).Value)))
        pen = CodePenalite(code)
        out(i, 1) = id: out(i, 2) = d: out(i, 3) = typ
        out(i, 4) = ps.Cells(OUT_HDR + i, 1).Value: out(i, 5) = ps.Cells(OUT_HDR + i, 2).Value
        out(i, 6) = code: out(i, 7) = ps.Cells(OUT_HDR + i, 5).Value
        out(i, 8) = IIf(pen > 0, pen, Empty)
        out(i, 9) = Now: out(i, 10) = G_RoleLabel
        totPen = totPen + pen
        If Not CodeExclu(code) Then
            att = att + 1
            pond = pond + CodePoids(code)
        End If
        If CodePoids(code) > 0 Then nbPres = nbPres + 1
    Next i
    ligneBase = LastRow(pr, 1) + 1
    pr.Range(pr.Cells(ligneBase, 1), pr.Cells(ligneBase + n - 1, PR_COLS)).Value = out
    ss.Cells(r, ColOf(ss, "Pointée")).Value = "OUI"
    ss.Cells(r, ColOf(ss, "Statut")).Value = "Tenue"
    ss.Cells(r, ColOf(ss, "Présents")).Value = nbPres
    If att > 0 Then ss.Cells(r, ColOf(ss, "Taux de la séance")).Value = pond / att
    ps.Range("H5").Value = ""
    ps.Range("C6").Value = ps.Range("C6").Value & "  >> ENREGISTRÉ"
    EndWork
    LogAction "Pointage validé", id & " : " & nbPres & " présent(s) sur " & n & IIf(totPen > 0, ", pénalités " & totPen & " " & ParamStr("MONNAIE", "FCFA"), ""), SH_PRES
    If MsgBox("Pointage enregistré : " & nbPres & " présent(s) sur " & n & "." & _
              IIf(totPen > 0, vbCrLf & "Pénalités générées : " & Format$(totPen, "#,##0") & " " & ParamStr("MONNAIE", "FCFA"), "") & vbCrLf & vbCrLf & _
              "Passer à la prochaine séance à pointer ?", vbYesNo + vbInformation, APP_NAME) = vbYes Then
        ps.Range("C5").Value = ""
        ProchaineSeance
    End If
    Exit Sub
EH:
    ShowError "Validation du pointage"
End Sub
