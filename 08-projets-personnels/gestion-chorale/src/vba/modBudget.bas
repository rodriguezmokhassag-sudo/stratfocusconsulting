Option Explicit
' =============================================================================
' modBudget : budget annuel par sous-rubrique, repartition mensuelle,
'             suivi prevu / realise, ecarts et variations
' =============================================================================

Private Function BudgetRow(ByVal exo As String, ByVal code As String) As Long
    Dim sh As Worksheet, r As Long
    Set sh = WS(SH_BUDGET)
    For r = FIRSTROW To LastRow(sh, 2)
        If CStr(sh.Cells(r, 1).Value) = exo And CStr(sh.Cells(r, 2).Value) = code Then
            BudgetRow = r
            Exit Function
        End If
    Next r
End Function

Private Function Retenu(ByVal sh As Worksheet, ByVal r As Long) As Double
    Dim rect As Double
    rect = NumV(sh.Cells(r, ColOf(sh, "Budget rectifié")).Value)
    If rect > 0 Then Retenu = rect Else Retenu = NumV(sh.Cells(r, ColOf(sh, "Budget initial")).Value)
End Function

Private Function DemanderExercice(ByVal question As String) As String
    DemanderExercice = Trim$(InputBox(question, APP_NAME, ExerciceDe(Date)))
End Function

Public Sub PreparerExercice()
    Dim exo As String, n As Long, copier As Boolean
    If Not RequireEdit(SH_BUDGET) Then Exit Sub
    exo = DemanderExercice("Préparer le budget de quel exercice ?")
    If exo = "" Then Exit Sub
    copier = (MsgBox("Reprendre les montants du budget " & ExerciceLabel(CLng(Val(Left$(exo, 4))) - 1) & " comme budget initial ?", vbYesNo + vbQuestion, APP_NAME) = vbYes)
    n = PreparerExerciceInterne(exo, copier)
    MsgBox n & " ligne(s) ajoutée(s) au budget " & exo & "." & vbCrLf & _
           "Saisissez les montants votés en AG, puis cliquez sur « Répartir par mois ».", vbInformation, APP_NAME
End Sub

Public Function PreparerExerciceInterne(ByVal exo As String, ByVal copier As Boolean) As Long
    Dim sh As Worksheet, rs As Worksheet, r As Long, k As Long, code As String, n As Long, prev As String, pr As Long
    Set sh = WS(SH_BUDGET)
    Set rs = WS(SH_RUBRIQUES)
    prev = ExerciceLabel(CLng(Val(Left$(exo, 4))) - 1)
    BeginWork
    For r = FIRSTROW To LastRow(rs, 1)
        code = CStr(rs.Cells(r, 1).Value)
        If code <> "" And UCase$(CStr(rs.Cells(r, ColOf(rs, "Actif")).Value)) <> "NON" Then
            If BudgetRow(exo, code) = 0 Then
                k = LastRow(sh, 2) + 1
                sh.Cells(k, 1).Value = exo
                sh.Cells(k, 2).Value = code
                sh.Cells(k, 3).Value = rs.Cells(r, ColOf(rs, "Sens")).Value
                sh.Cells(k, 4).Value = rs.Cells(r, ColOf(rs, "Rubrique")).Value
                sh.Cells(k, 5).Value = rs.Cells(r, ColOf(rs, "Sous-rubrique")).Value
                sh.Cells(k, 6).Value = rs.Cells(r, ColOf(rs, "Fonds")).Value
                If copier Then
                    pr = BudgetRow(prev, code)
                    If pr > 0 Then sh.Cells(k, ColOf(sh, "Budget initial")).Value = Retenu(sh, pr)
                End If
                n = n + 1
            End If
        End If
    Next r
    EndWork
    LogAction "Budget préparé", exo & " : " & n & " ligne(s)", SH_BUDGET
    PreparerExerciceInterne = n
End Function

Public Sub RepartirBudget()
    Dim exo As String, n As Long, tout As Boolean
    If Not RequireEdit(SH_BUDGET) Then Exit Sub
    exo = DemanderExercice("Répartir par mois le budget de quel exercice ?")
    If exo = "" Then Exit Sub
    tout = (MsgBox("Remplacer aussi les répartitions déjà saisies ?" & vbCrLf & _
                   "(Non = ne répartir que les lignes dont les mois sont vides)", vbYesNo + vbQuestion, APP_NAME) = vbYes)
    n = RepartirBudgetInterne(exo, tout)
    MsgBox n & " ligne(s) réparties en 12 mois égaux.", vbInformation, APP_NAME
End Sub

' Repartit le budget retenu en 12 mois egaux (le reste d'arrondi sur le dernier mois)
Public Function RepartirBudgetInterne(ByVal exo As String, ByVal remplacer As Boolean) As Long
    Dim sh As Worksheet, r As Long, m As Long, c1 As Long, total As Double, part As Double, vide As Boolean, n As Long
    Set sh = WS(SH_BUDGET)
    c1 = ColOf(sh, "M01")
    BeginWork
    For r = FIRSTROW To LastRow(sh, 2)
        If CStr(sh.Cells(r, 1).Value) = exo Then
            total = Retenu(sh, r)
            sh.Cells(r, ColOf(sh, "Budget retenu")).Value = total
            vide = True
            For m = 0 To 11
                If CStr(sh.Cells(r, c1 + m).Value) <> "" Then vide = False
            Next m
            If total > 0 And (vide Or remplacer) Then
                part = Int(total / 12)
                For m = 0 To 10
                    sh.Cells(r, c1 + m).Value = part
                Next m
                sh.Cells(r, c1 + 11).Value = total - 11 * part
                n = n + 1
            End If
        End If
    Next r
    EndWork
    ControlerBudgetInterne exo
    LogAction "Budget réparti", exo & " : " & n & " ligne(s)", SH_BUDGET
    RepartirBudgetInterne = n
End Function

Public Sub ControlerBudget()
    Dim exo As String, msg As String
    If Not RequireLogin() Then Exit Sub
    exo = DemanderExercice("Contrôler le budget de quel exercice ?")
    If exo = "" Then Exit Sub
    msg = ControlerBudgetInterne(exo)
    MsgBox msg, vbInformation, APP_NAME
End Sub

' Recalcule le budget retenu et l'ecart de repartition ; renvoie une synthese
Public Function ControlerBudgetInterne(ByVal exo As String) As String
    Dim sh As Worksheet, r As Long, m As Long, c1 As Long, total As Double, somme As Double, ec As Double
    Dim rec As Double, dep As Double, nErr As Long, cEc As Long
    Set sh = WS(SH_BUDGET)
    c1 = ColOf(sh, "M01")
    cEc = ColOf(sh, "Écart de répartition")
    BeginWork
    For r = FIRSTROW To LastRow(sh, 2)
        If CStr(sh.Cells(r, 1).Value) = exo Then
            total = Retenu(sh, r)
            sh.Cells(r, ColOf(sh, "Budget retenu")).Value = total
            somme = 0
            For m = 0 To 11
                somme = somme + NumV(sh.Cells(r, c1 + m).Value)
            Next m
            ec = total - somme
            sh.Cells(r, cEc).Value = ec
            If ec <> 0 Then
                sh.Cells(r, cEc).Interior.Color = RGB(255, 199, 206)
                nErr = nErr + 1
            Else
                sh.Cells(r, cEc).Interior.ColorIndex = xlNone
            End If
            If CStr(sh.Cells(r, 3).Value) = "Recette" Then rec = rec + total Else dep = dep + total
        End If
    Next r
    EndWork
    ControlerBudgetInterne = "Budget " & exo & " :" & vbCrLf & _
        "  recettes prévues : " & Fcfa(rec) & vbCrLf & "  dépenses prévues : " & Fcfa(dep) & vbCrLf & _
        "  solde prévu : " & Fcfa(rec - dep) & vbCrLf & _
        IIf(nErr > 0, nErr & " ligne(s) dont la répartition mensuelle ne correspond pas au budget (en rouge).", "Répartition mensuelle cohérente.")
End Function

' ============================================================ suivi budgetaire
Public Sub CalculerSuiviBudget()
    Dim ss As Worksheet, exo As String, m As Long
    If Not RequireLogin() Then Exit Sub
    Set ss = WS(SH_SUIVI_BUDGET)
    exo = Trim$(CStr(ss.Range("C5").Value))
    If exo = "" Then exo = ExerciceDe(Date): ss.Range("C5").Value = exo
    If IsNumeric(ss.Range("E5").Value) And CStr(ss.Range("E5").Value) <> "" Then
        m = CLng(ss.Range("E5").Value)
    Else
        If ExerciceAnnee(Date) = CLng(Val(Left$(exo, 4))) Then m = MoisIndex(Date) Else m = 12
        ss.Range("E5").Value = m
    End If
    If m < 1 Or m > 12 Then
        MsgBox "Le mois doit être compris entre 1 et 12 (1 = premier mois de l'exercice).", vbExclamation, APP_NAME
        Exit Sub
    End If
    SuiviBudgetInterne exo, m
End Sub

Public Sub SuiviBudgetInterne(ByVal exo As String, ByVal m As Long)
    Dim ss As Worksheet, bs As Worksheet, i As Long, r As Long, k As Long, n As Long, code As String, mi As Long
    Dim codes() As String, sens() As String, rub() As String, srub() As String, prevA() As Double, prevD() As Double
    Dim realD() As Double, realM() As Double, realP() As Double, realN1() As Double
    Dim idx As New Collection, c1 As Long, prev As String, net As Double, d As Date, lbl As String, ex As String
    Dim out() As Variant, nOut As Long, seuil As Double, curRub As String, curNom As String, curSens As String, j As Long, nLignes As Long
    Dim tRec(1 To 7) As Double, tDep(1 To 7) As Double, totRub(1 To 7) As Double, couleur() As Long, gras() As Boolean
    On Error GoTo EH
    BeginWork
    Set ss = WS(SH_SUIVI_BUDGET)
    Set bs = WS(SH_BUDGET)
    seuil = ParamNum("SEUIL_ECART_BUDGET", 0.1)
    prev = ExerciceLabel(CLng(Val(Left$(exo, 4))) - 1)
    c1 = ColOf(bs, "M01")
    ReDim codes(1 To 400): ReDim sens(1 To 400): ReDim rub(1 To 400): ReDim srub(1 To 400)
    ReDim prevA(1 To 400): ReDim prevD(1 To 400): ReDim realD(1 To 400): ReDim realM(1 To 400): ReDim realP(1 To 400): ReDim realN1(1 To 400)
    ' Lignes budgetaires de l'exercice
    For r = FIRSTROW To LastRow(bs, 2)
        If CStr(bs.Cells(r, 1).Value) = exo And n < 400 Then
            n = n + 1
            codes(n) = CStr(bs.Cells(r, 2).Value)
            sens(n) = CStr(bs.Cells(r, 3).Value)
            rub(n) = CStr(bs.Cells(r, 4).Value)
            srub(n) = CStr(bs.Cells(r, 5).Value)
            prevA(n) = Retenu(bs, r)
            For mi = 1 To m
                prevD(n) = prevD(n) + NumV(bs.Cells(r, c1 + mi - 1).Value)
            Next mi
            If Not KeyExists(idx, codes(n)) Then idx.Add n, codes(n)
        End If
    Next r
    ' Realise
    LoadJournal
    For i = 1 To G_JN
        code = CStr(G_J(i, CJ_CODE))
        ex = CStr(G_J(i, CJ_EXO))
        If code <> CODE_VIREMENT And code <> "" And (ex = exo Or ex = prev) Then
            If Not KeyExists(idx, code) And n < 400 Then
                n = n + 1
                codes(n) = code
                sens(n) = CStr(RubValeur(code, "Sens"))
                rub(n) = CStr(G_J(i, CJ_RUB))
                srub(n) = CStr(G_J(i, CJ_SRUB)) & " (hors budget)"
                idx.Add n, code
            End If
            k = idx(code)
            If sens(k) = "Recette" Then
                net = NumV(G_J(i, CJ_REC)) - NumV(G_J(i, CJ_DEP))
            Else
                net = NumV(G_J(i, CJ_DEP)) - NumV(G_J(i, CJ_REC))
            End If
            d = AsDate(G_J(i, CJ_DATE))
            mi = MoisIndex(d)
            If ex = exo Then
                If mi <= m Then realD(k) = realD(k) + net
                If mi = m Then realM(k) = realM(k) + net
                If mi = m - 1 Then realP(k) = realP(k) + net
            ElseIf mi <= m Then
                realN1(k) = realN1(k) + net
            End If
        End If
    Next i
    ' Tri par code (recettes R/S puis depenses D/T grace a l'ordre du sens)
    Dim ord() As Long, t As Long, a As String, b As String
    ReDim ord(1 To n + 1)
    For i = 1 To n
        ord(i) = i
    Next i
    For i = 2 To n
        t = ord(i)
        j = i - 1
        Do While j >= 1
            a = IIf(sens(ord(j)) = "Recette", "1", "2") & codes(ord(j))
            b = IIf(sens(t) = "Recette", "1", "2") & codes(t)
            If a <= b Then Exit Do
            ord(j + 1) = ord(j)
            j = j - 1
        Loop
        ord(j + 1) = t
    Next i
    ' Sortie avec sous-totaux par rubrique
    ss.Range("A" & OUT_FIRST & ":O" & MAXROWS).Clear
    ReDim out(1 To n * 2 + 20, 1 To 15)
    ReDim couleur(1 To n * 2 + 20)
    ReDim gras(1 To n * 2 + 20)
    curRub = ""
    For j = 1 To n
        k = ord(j)
        If rub(k) & "|" & sens(k) <> curRub Then
            If curRub <> "" And nLignes > 1 Then AddTotalRow out, nOut, couleur, gras, "Total " & curNom, totRub, seuil, curSens
            nLignes = 0
            curRub = rub(k) & "|" & sens(k)
            curNom = rub(k)
            curSens = sens(k)
            Erase totRub
        End If
        nOut = nOut + 1
        nLignes = nLignes + 1
        out(nOut, 1) = codes(k): out(nOut, 2) = sens(k): out(nOut, 3) = rub(k): out(nOut, 4) = srub(k)
        FillMetrics out, nOut, prevA(k), prevD(k), realD(k), realM(k), realP(k), realN1(k)
        couleur(nOut) = EcartCouleur(sens(k), prevD(k), realD(k), seuil)
        totRub(1) = totRub(1) + prevA(k): totRub(2) = totRub(2) + prevD(k): totRub(3) = totRub(3) + realD(k)
        totRub(4) = totRub(4) + realM(k): totRub(5) = totRub(5) + realP(k): totRub(6) = totRub(6) + realN1(k)
        If sens(k) = "Recette" Then
            tRec(1) = tRec(1) + prevA(k): tRec(2) = tRec(2) + prevD(k): tRec(3) = tRec(3) + realD(k)
            tRec(4) = tRec(4) + realM(k): tRec(5) = tRec(5) + realP(k): tRec(6) = tRec(6) + realN1(k)
        Else
            tDep(1) = tDep(1) + prevA(k): tDep(2) = tDep(2) + prevD(k): tDep(3) = tDep(3) + realD(k)
            tDep(4) = tDep(4) + realM(k): tDep(5) = tDep(5) + realP(k): tDep(6) = tDep(6) + realN1(k)
        End If
    Next j
    If curRub <> "" And nLignes > 1 Then AddTotalRow out, nOut, couleur, gras, "Total " & curNom, totRub, seuil, curSens
    nOut = nOut + 1
    AddTotalRow out, nOut, couleur, gras, "TOTAL DES RECETTES", tRec, seuil, "Recette"
    AddTotalRow out, nOut, couleur, gras, "TOTAL DES DÉPENSES", tDep, seuil, "Dépense"
    For i = 1 To 6
        totRub(i) = tRec(i) - tDep(i)
    Next i
    AddTotalRow out, nOut, couleur, gras, "RÉSULTAT (recettes - dépenses)", totRub, seuil, "Résultat"
    If nOut > 0 Then
        ss.Range("A" & OUT_FIRST).Resize(nOut, 15).Value = out
        ss.Range("E" & OUT_FIRST & ":H" & OUT_HDR + nOut).NumberFormat = "#,##0"
        ss.Range("K" & OUT_FIRST & ":L" & OUT_HDR + nOut).NumberFormat = "#,##0"
        ss.Range("N" & OUT_FIRST & ":N" & OUT_HDR + nOut).NumberFormat = "#,##0"
        ss.Range("I" & OUT_FIRST & ":J" & OUT_HDR + nOut).NumberFormat = "0%"
        ss.Range("M" & OUT_FIRST & ":M" & OUT_HDR + nOut).NumberFormat = "0%"
        ss.Range("O" & OUT_FIRST & ":O" & OUT_HDR + nOut).NumberFormat = "0%"
        For i = 1 To nOut
            If couleur(i) <> 0 Then ss.Range("H" & OUT_HDR + i & ":I" & OUT_HDR + i).Interior.Color = couleur(i)
            If gras(i) Then
                ss.Range("A" & OUT_HDR + i & ":O" & OUT_HDR + i).Font.Bold = True
                ss.Range("A" & OUT_HDR + i & ":G" & OUT_HDR + i).Interior.Color = ColSecondaire()
            End If
        Next i
    End If
    ss.Range("C6").Value = tRec(3) - tDep(3)
    ss.Range("C6").NumberFormat = "#,##0"
    ss.Range("E6").Value = "Réalisé à fin du mois " & m & " de l'exercice " & exo & " - calculé le " & Format$(Now, "dd/mm/yyyy hh:mm")
    EndWork
    LogAction "Suivi budgétaire", exo & " mois " & m, SH_SUIVI_BUDGET
    Exit Sub
EH:
    ShowError "Suivi budgétaire"
End Sub

Private Sub FillMetrics(out() As Variant, ByVal i As Long, ByVal pa As Double, ByVal pd As Double, ByVal rd As Double, _
                        ByVal rm As Double, ByVal rp As Double, ByVal rn1 As Double)
    out(i, 5) = pa: out(i, 6) = pd: out(i, 7) = rd: out(i, 8) = rd - pd
    If pd <> 0 Then out(i, 9) = (rd - pd) / pd Else out(i, 9) = ""
    If pa <> 0 Then out(i, 10) = rd / pa Else out(i, 10) = ""
    out(i, 11) = rm: out(i, 12) = rp
    If rp <> 0 Then out(i, 13) = (rm - rp) / rp Else out(i, 13) = ""
    out(i, 14) = rn1
    If rn1 <> 0 Then out(i, 15) = (rd - rn1) / rn1 Else out(i, 15) = ""
End Sub

Private Function EcartCouleur(ByVal sens As String, ByVal prevu As Double, ByVal realise As Double, ByVal seuil As Double) As Long
    Dim e As Double
    If prevu = 0 Then
        If realise <> 0 And sens = "Dépense" Then EcartCouleur = RGB(255, 199, 206)
        Exit Function
    End If
    e = (realise - prevu) / prevu
    If sens = "Dépense" Then e = -e
    If sens = "Recette" Or sens = "Dépense" Then
        If e < -seuil Then
            EcartCouleur = RGB(255, 199, 206)
        ElseIf e > seuil Then
            EcartCouleur = RGB(198, 239, 206)
        End If
    End If
End Function

Private Sub AddTotalRow(out() As Variant, ByRef nOut As Long, couleur() As Long, gras() As Boolean, ByVal titre As String, _
                        t() As Double, ByVal seuil As Double, ByVal sens As String)
    nOut = nOut + 1
    out(nOut, 3) = titre
    FillMetrics out, nOut, t(1), t(2), t(3), t(4), t(5), t(6)
    couleur(nOut) = EcartCouleur(sens, t(2), t(3), seuil)
    gras(nOut) = True
End Sub
