Option Explicit
' =============================================================================
' modRapports : tableau de bord (chiffres + graphiques), rapport par pupitre et
' par commission, livre de caisse, point financier du mois, fiche d'un membre,
' rapport annuel pour l'AG, export PDF (un rapport ou le dossier complet de l'AG).
' Chaque rapport ne montre que les domaines autorises au role connecte.
' =============================================================================

Public Const SH_TB As String = "TABLEAU_BORD"
Public Const SH_RAG As String = "RAPPORT_AG"
Public Const SH_PMOIS As String = "POINT_MENSUEL"
Public Const SH_LIVRE As String = "LIVRE_CAISSE"
Public Const SH_FMEMBRE As String = "FICHE_MEMBRE"
Public Const SH_RPUP As String = "RAPPORT_PUPITRES"

Private Const TB_M1 As Long = 9      ' TABLEAU_BORD F9:J20 (graphiques par mois)
Private Const TB_P1 As Long = 24     ' TABLEAU_BORD F24:H29 (graphique par pupitre)
Private Const RP_P1 As Long = 9      ' RAPPORT_PUPITRES lignes 9 a 14 (+ total 15)
Private Const RP_C1 As Long = 19     ' RAPPORT_PUPITRES lignes 19 a 30

Private m_Dom As String

' ============================================================ utilitaires
Public Function TauxDe(ByVal att As Double, ByVal pond As Double) As Variant
    If att > 0 Then TauxDe = pond / att Else TauxDe = ""
End Function

Public Function MoisCourt(ByVal d As Date) As String
    MoisCourt = Choose(Month(d), "janv.", "févr.", "mars", "avr.", "mai", "juin", "juil.", "août", "sept.", "oct.", "nov.", "déc.") & " " & Right$(CStr(Year(d)), 2)
End Function

Private Function DateEntree(ByVal sh As Worksheet, ByVal adr As String, ByVal defaut As Date) As Date
    DateEntree = AsDate(sh.Range(adr).Value)
    If DateEntree = 0 Then
        DateEntree = defaut
        sh.Range(adr).Value = defaut
    End If
End Function

Private Function BudgetRetenu(ByVal bs As Worksheet, ByVal r As Long) As Double
    BudgetRetenu = NumV(bs.Cells(r, ColOf(bs, "Budget rectifié")).Value)
    If BudgetRetenu <= 0 Then BudgetRetenu = NumV(bs.Cells(r, ColOf(bs, "Budget initial")).Value)
End Function

Private Sub ViderLibre(ByVal sh As Worksheet, ByVal r1 As Long, ByVal nCols As Long)
    With sh.Range(sh.Cells(r1, 1), sh.Cells(r1 + 700, nCols))
        .ClearContents
        .Font.Bold = False
        .Font.Italic = False
        .Font.Color = RGB(0, 0, 0)
        .Interior.ColorIndex = xlNone
        .Borders.LineStyle = xlNone
        .NumberFormat = "General"
        .HorizontalAlignment = xlGeneral
        .IndentLevel = 0
    End With
End Sub

Private Sub RSection(ByVal sh As Worksheet, ByRef row As Long, ByVal titre As String, ByVal nCols As Long)
    row = row + 1
    sh.Cells(row, 1).Value = titre
    With sh.Range(sh.Cells(row, 1), sh.Cells(row, nCols))
        .Font.Bold = True
        .Font.Color = ColPrincipale()
        .Interior.Color = ColSecondaire()
    End With
    row = row + 1
End Sub

Private Function FmtCode(ByVal c As String) As String
    Select Case c
        Case "m": FmtCode = "#,##0"
        Case "p": FmtCode = "0%"
        Case "d": FmtCode = "dd/mm/yyyy"
        Case "n": FmtCode = "0"
        Case Else: FmtCode = ""
    End Select
End Function

' Ecrit une ligne de valeurs ; fmts : un code par colonne (t texte, m montant, p %, d date, n nombre), separes par "|"
Private Sub RLigne(ByVal sh As Worksheet, ByRef row As Long, ByVal vals As Variant, ByVal fmts As String)
    Dim i As Long, f() As String, fm As String
    f = Split(fmts, "|")
    For i = 0 To UBound(vals)
        sh.Cells(row, i + 1).Value = vals(i)
        fm = ""
        If i <= UBound(f) Then fm = FmtCode(f(i))
        If fm <> "" Then
            sh.Cells(row, i + 1).NumberFormat = fm
            If i > 0 Then sh.Cells(row, i + 1).HorizontalAlignment = xlRight
        ElseIf i > 0 Then
            sh.Cells(row, i + 1).HorizontalAlignment = xlLeft
            sh.Cells(row, i + 1).IndentLevel = 1
        End If
    Next i
    row = row + 1
End Sub

Private Sub REntete(ByVal sh As Worksheet, ByRef row As Long, ByVal titres As Variant)
    Dim i As Long
    For i = 0 To UBound(titres)
        sh.Cells(row, i + 1).Value = titres(i)
        If i > 0 Then sh.Cells(row, i + 1).HorizontalAlignment = xlCenter
    Next i
    With sh.Range(sh.Cells(row, 1), sh.Cells(row, UBound(titres) + 1))
        .Font.Bold = True
        .Borders(xlEdgeBottom).LineStyle = xlContinuous
    End With
    row = row + 1
End Sub

Private Sub RGras(ByVal sh As Worksheet, ByVal row As Long, ByVal nCols As Long)
    With sh.Range(sh.Cells(row, 1), sh.Cells(row, nCols))
        .Font.Bold = True
        .Borders(xlEdgeTop).LineStyle = xlContinuous
    End With
End Sub

Private Sub ZoneImpression(ByVal sh As Worksheet, ByVal lastRow As Long, ByVal nCols As Long)
    If G_TestMode Then Exit Sub
    On Error Resume Next
    sh.PageSetup.PrintArea = sh.Range(sh.Cells(1, 1), sh.Cells(lastRow, nCols)).Address
End Sub

' Groupes de chaque membre actif : pupitre (parPupitre) ou commissions, separes par "|".
' Ajoute le groupe "TOUS". nb(groupe) = nombre de membres actifs.
Private Function GroupesMembres(ByVal parPupitre As Boolean, ByVal nb As Collection) As Collection
    Dim ms As Worksheet, v As Variant, n As Long, i As Long, groupes As New Collection, mat As String, g As String
    Dim cM As Long, cG As Long, cS As Long, lst As Collection, parts() As String, j As Long, k As Long, s As String, nm As String
    Set ms = WS(SH_MEMBRES)
    cM = ColOf(ms, "Matricule"): cS = ColOf(ms, "Statut")
    If parPupitre Then
        cG = ColOf(ms, "Pupitre")
    Else
        cG = ColOf(ms, "Commission(s)")
        Set lst = ListValues("Commission")
    End If
    LoadStatuts
    n = ReadBlock(ms, cM, v)
    For i = 1 To n
        mat = CStr(v(i, cM))
        If mat <> "" And StatutCodeDefaut(CStr(v(i, cS))) <> "" And Not KeyExists(groupes, mat) Then
            If parPupitre Then
                g = Trim$(CStr(v(i, cG)))
            Else
                g = ""
                s = Replace(Replace(Replace(CStr(v(i, cG)), ",", ";"), "/", ";"), "|", ";")
                parts = Split(s, ";")
                For j = LBound(parts) To UBound(parts)
                    For k = 1 To lst.Count
                        If StrComp(Trim$(parts(j)), CStr(lst.Item(k)), vbTextCompare) = 0 Then g = g & "|" & CStr(lst.Item(k))
                    Next k
                Next j
                If g <> "" Then g = Mid$(g, 2)
            End If
            If g = "" Then g = "TOUS" Else g = g & "|TOUS"
            groupes.Add g, mat
            parts = Split(g, "|")
            For j = LBound(parts) To UBound(parts)
                nm = parts(j)
                If KeyExists(nb, nm) Then
                    k = nb.Item(nm)
                    nb.Remove nm
                    nb.Add k + 1, nm
                Else
                    nb.Add 1, nm
                End If
            Next j
        End If
    Next i
    Set GroupesMembres = groupes
End Function

Private Function IndexDe(noms() As String, ByVal n As Long, ByVal nom As String) As Long
    Dim i As Long
    For i = 1 To n
        If StrComp(noms(i), nom, vbTextCompare) = 0 Then
            IndexDe = i
            Exit Function
        End If
    Next i
End Function

' Cantiques maitrises / en apprentissage / non commences pour un pupitre vocal (False si pas de colonne)
Private Function MaitrisePupitre(ByVal pupitre As String, ByRef nOk As Long, ByRef nEn As Long, ByRef nZero As Long) As Boolean
    Dim cs As Worksheet, c As Long, v As Variant, n As Long, i As Long
    nOk = 0: nEn = 0: nZero = 0
    Set cs = WS(SH_CANT)
    c = ColOf(cs, pupitre, False)
    If c = 0 Then Exit Function
    n = ReadBlock(cs, 1, v)
    For i = 1 To n
        If CStr(v(i, 1)) <> "" Then
            If CStr(v(i, c)) = NIV_OK Then
                nOk = nOk + 1
            ElseIf CStr(v(i, c)) = NIV_EN_COURS Then
                nEn = nEn + 1
            Else
                nZero = nZero + 1
            End If
        End If
    Next i
    MaitrisePupitre = True
End Function

' ============================================================ export PDF
Public Function DossierRapports() As String
    Dim d As String
    d = Trim$(ParamStr("DOSSIER_RAPPORTS"))
    If d = "" Then d = ThisWorkbook.Path & Application.PathSeparator & "Rapports"
    On Error Resume Next
    If Dir(d, vbDirectory) = "" Then MkDir d
    On Error GoTo 0
    DossierRapports = d
End Function

Public Function NomPDF(ByVal nom As String) As String
    NomPDF = DossierRapports() & Application.PathSeparator & nom & "_" & Format$(Now, "yyyy-mm-dd_hhnn") & ".pdf"
End Function

Public Sub ExporterPDF()
    Dim f As String
    If Not RequireLogin() Then Exit Sub
    f = NomPDF(ActiveSheet.Name)
    If ExporterFeuillesPDF(Array(ActiveSheet.Name), f) Then MsgBox "PDF enregistré :" & vbCrLf & f, vbInformation, APP_NAME
End Sub

Public Function ExporterFeuillesPDF(ByVal noms As Variant, ByVal f As String) As Boolean
    Dim actif As Worksheet, premier As String, arr() As Variant, i As Long
    On Error GoTo EH
    Set actif = ActiveSheet
    premier = CStr(noms(LBound(noms)))
    ReDim arr(0 To UBound(noms) - LBound(noms))
    For i = 0 To UBound(arr)
        arr(i) = CStr(noms(LBound(noms) + i))
    Next i
    If UBound(arr) = 0 Then
        ThisWorkbook.Worksheets(premier).ExportAsFixedFormat Type:=xlTypePDF, Filename:=f, Quality:=xlQualityStandard, _
            IncludeDocProperties:=True, IgnorePrintAreas:=False, OpenAfterPublish:=True
    Else
        ThisWorkbook.Worksheets(arr).Select
        ActiveSheet.ExportAsFixedFormat Type:=xlTypePDF, Filename:=f, Quality:=xlQualityStandard, _
            IncludeDocProperties:=True, IgnorePrintAreas:=False, OpenAfterPublish:=True
        actif.Select
    End If
    LogAction "Export PDF", f, actif.Name
    ExporterFeuillesPDF = True
    Exit Function
EH:
    MsgBox "Export PDF impossible : " & Err.Description & vbCrLf & _
           "(Excel 2010 ou plus récent est nécessaire ; vérifiez aussi le dossier " & DossierRapports() & ")", vbExclamation, APP_NAME
    On Error Resume Next
    actif.Select
End Function

' ============================================================ tableau de bord
Public Sub ActualiserTableauBord()
    If Not RequireLogin() Then Exit Sub
    TableauBordInterne DateEntree(WS(SH_TB), "C5", Date)
    WS(SH_TB).Activate
End Sub

' Recalcul a l'ouverture de la feuille si le role ou le jour a change
Public Sub TableauBordSiBesoin()
    If G_Busy Or Not IsLogged() Then Exit Sub
    If CStr(WS(SH_TB).Range("L1").Value) <> G_Role & "|" & Format$(Date, "yyyymmdd") Then
        WS(SH_TB).Range("C5").Value = Date
        TableauBordInterne Date
    End If
End Sub

Public Sub ViderTableauBord()
    Dim sh As Worksheet
    Set sh = WS(SH_TB)
    sh.Range("A" & OUT_FIRST & ":D60").ClearContents
    sh.Range("F" & TB_M1 & ":J" & TB_M1 + 11).ClearContents
    sh.Range("F" & TB_P1 & ":H" & TB_P1 + 5).ClearContents
    sh.Range("B6").Value = ""
    sh.Range("L1").Value = ""
End Sub

Private Sub TbLigne(ByVal sh As Worksheet, ByRef row As Long, ByVal dom As String, ByVal indic As String, ByVal v As Variant, _
                    ByVal fmt As String, ByVal detail As String)
    If dom <> m_Dom Then
        sh.Cells(row, 1).Value = dom
        sh.Cells(row, 1).Font.Bold = True
        sh.Range(sh.Cells(row, 1), sh.Cells(row, 4)).Borders(xlEdgeTop).LineStyle = xlContinuous
        m_Dom = dom
    End If
    sh.Cells(row, 2).Value = indic
    sh.Cells(row, 3).Value = v
    If FmtCode(fmt) <> "" Then sh.Cells(row, 3).NumberFormat = FmtCode(fmt) Else sh.Cells(row, 3).NumberFormat = "General"
    sh.Cells(row, 3).HorizontalAlignment = xlRight
    sh.Cells(row, 4).Value = detail
    sh.Cells(row, 4).IndentLevel = 1
    row = row + 1
End Sub

Public Sub TableauBordInterne(ByVal asOf As Date)
    Dim sh As Worksheet, row As Long, exo As String, d1 As Date, m As Long, dm As Date, dfin As Date, i As Long, k As Long
    Dim v As Variant, n As Long, st As String, nAct As Long, nConf As Long, nObs As Long, nRef As Long, nSanc As Long, nArr As Long
    Dim noms() As String, att() As Double, pond() As Double, ng As Long, vide As New Collection, totA As Double, totP As Double
    Dim esp As Double, bq As Double, soc As Double, rec As Double, dep As Double, recM(1 To 12) As Double, depM(1 To 12) As Double
    Dim tresM(1 To 12) As Double, tres As Double
    Dim code As String, d As Date, budDep As Double, bs As Worksheet, nbRet As Long, totRes As Double, nbG As New Collection
    Dim ms As Worksheet, cM As Long, cS As Long, cA As Long, lst As Collection, grp As Collection, nOk As Long, nEn As Long, nZ As Long
    Dim ps As Worksheet, vnet As Double, nBiens As Long, nRep As Long, txt As String, prochain As Date, nReal As Long, nPlan As Long
    On Error GoTo EH
    m_Dom = ""
    exo = ExerciceDe(asOf)
    d1 = ExerciceDebut(exo)
    Set sh = WS(SH_TB)
    BeginWork
    ViderTableauBord
    sh.Range("C5").Value = asOf
    sh.Range("B6").Value = ParamStr("NOM_GROUPE") & " - exercice " & exo & " - calculé le " & Format$(Now, "dd/mm/yyyy hh:mm") & " (" & G_RoleLabel & ")"
    sh.Range("L1").Value = G_Role & "|" & Format$(Date, "yyyymmdd")
    sh.Range("L1").NumberFormat = ";;;"
    row = OUT_FIRST
    sh.Range("F" & TB_M1 & ":F" & TB_M1 + 11).NumberFormat = "@"
    For m = 1 To 12
        sh.Cells(TB_M1 + m - 1, 6).Value = MoisCourt(DateSerial(Year(d1), Month(d1) + m - 1, 1))
    Next m
    ' --- membres
    If RightOf(SH_MEMBRES) <> "" Then
        Set ms = WS(SH_MEMBRES)
        cM = ColOf(ms, "Matricule"): cS = ColOf(ms, "Statut"): cA = ColOf(ms, "Date d'arrivée")
        LoadStatuts
        n = ReadBlock(ms, cM, v)
        For i = 1 To n
            If CStr(v(i, cM)) <> "" Then
                st = CStr(v(i, cS))
                If StatutCodeDefaut(st) <> "" Then nAct = nAct + 1
                If st = ST_CONF Then nConf = nConf + 1
                If st = ST_OBS Then nObs = nObs + 1
                If st = ST_REFROIDI Then nRef = nRef + 1
                If st = "Suspendu" Or st = "Exclu temporaire" Then nSanc = nSanc + 1
                d = AsDate(v(i, cA))
                If d >= d1 And d <= asOf Then nArr = nArr + 1
            End If
        Next i
        TbLigne sh, row, "Membres", "Membres actifs", nAct, "n", nConf & " confirmé(s), " & nObs & " en observation"
        TbLigne sh, row, "Membres", "Arrivées depuis le début de l'exercice", nArr, "n", ""
        TbLigne sh, row, "Membres", "Refroidis / sanctionnés", nRef & " / " & nSanc, "t", "Art. 52 / sanctions en cours"
    End If
    ' --- assiduite
    If RightOf(SH_PRES) <> "" Then
        LoadPresenceCache
        ng = AgregerPresences(d1, asOf, vide, True, noms, att, pond)
        For m = 1 To 12
            dm = DateSerial(Year(d1), Month(d1) + m - 1, 1)
            k = IndexDe(noms, ng, Format$(dm, "yyyy-mm"))
            If k > 0 Then
                sh.Cells(TB_M1 + m - 1, 7).Value = TauxDe(att(k), pond(k))
                totA = totA + att(k): totP = totP + pond(k)
            End If
        Next m
        TbLigne sh, row, "Assiduité", "Taux de l'exercice", TauxDe(totA, totP), "p", Format$(totA, "0") & " présences attendues"
        k = IndexDe(noms, ng, Format$(asOf, "yyyy-mm"))
        If k > 0 Then TbLigne sh, row, "Assiduité", "Taux du mois en cours", TauxDe(att(k), pond(k)), "p", MoisLong(Month(asOf)) & " " & Year(asOf)
        k = IndexDe(noms, ng, Format$(DateSerial(Year(asOf), Month(asOf) - 1, 1), "yyyy-mm"))
        If k > 0 Then TbLigne sh, row, "Assiduité", "Taux du mois précédent", TauxDe(att(k), pond(k)), "p", ""
        ' par pupitre
        Set grp = GroupesMembres(True, nbG)
        ng = AgregerPresences(d1, asOf, grp, False, noms, att, pond)
        Set lst = ListValues("Pupitre")
        For i = 1 To lst.Count
            If i > 6 Then Exit For
            sh.Cells(TB_P1 + i - 1, 6).Value = CStr(lst.Item(i))
            k = IndexDe(noms, ng, CStr(lst.Item(i)))
            If k > 0 Then sh.Cells(TB_P1 + i - 1, 7).Value = TauxDe(att(k), pond(k))
            If RightOf(SH_CANT) <> "" Then
                If MaitrisePupitre(CStr(lst.Item(i)), nOk, nEn, nZ) Then
                    If nOk + nEn + nZ > 0 Then sh.Cells(TB_P1 + i - 1, 8).Value = nOk / (nOk + nEn + nZ)
                End If
            End If
        Next i
    End If
    ' --- finances
    If ModuleRight("FINANCES") <> "" Then
        Soldes asOf, esp, bq, soc
        For i = 1 To G_JN
            code = CStr(G_J(i, CJ_CODE))
            d = AsDate(G_J(i, CJ_DATE))
            If code <> CODE_VIREMENT And CStr(G_J(i, CJ_EXO)) = exo And d <= asOf Then
                rec = rec + NumV(G_J(i, CJ_REC))
                dep = dep + NumV(G_J(i, CJ_DEP))
                k = ((Month(d) - Month(d1) + 12) Mod 12) + 1
                recM(k) = recM(k) + NumV(G_J(i, CJ_REC))
                depM(k) = depM(k) + NumV(G_J(i, CJ_DEP))
            End If
        Next i
        Set bs = WS(SH_BUDGET)
        For i = FIRSTROW To LastRow(bs, 2)
            If CStr(bs.Cells(i, 1).Value) = exo And CStr(bs.Cells(i, 3).Value) = "Dépense" Then budDep = budDep + BudgetRetenu(bs, i)
        Next i
        TbLigne sh, row, "Finances", "Trésorerie (espèces + banque)", esp + bq, "m", "Espèces " & Fcfa(esp) & " - banque " & Fcfa(bq)
        TbLigne sh, row, "Finances", "Fonds de la caisse sociale", soc, "m", ""
        TbLigne sh, row, "Finances", "Recettes de l'exercice", rec, "m", ""
        TbLigne sh, row, "Finances", "Dépenses de l'exercice", dep, "m", IIf(budDep > 0, "Budget de dépenses retenu : " & Fcfa(budDep), "Pas de budget saisi")
        TbLigne sh, row, "Finances", "Résultat (recettes - dépenses)", rec - dep, "m", ""
        If budDep > 0 Then TbLigne sh, row, "Finances", "Exécution du budget de dépenses", dep / budDep, "p", "Part du budget annuel déjà dépensée"
        ' tresorerie de fin de mois : solde d'ouverture de l'exercice + mouvements cumules
        Soldes d1 - 1, esp, bq, soc
        dfin = AsDate(GetParam("DATE_OUVERTURE_COMPTES", ""))
        For i = 1 To G_JN
            d = AsDate(G_J(i, CJ_DATE))
            If d >= d1 And d <= asOf And d >= dfin Then
                If CStr(G_J(i, CJ_CAISSE)) = CAISSE_ESP Or CStr(G_J(i, CJ_CAISSE)) = CAISSE_BQ Then
                    k = ((Month(d) - Month(d1) + 12) Mod 12) + 1
                    tresM(k) = tresM(k) + NumV(G_J(i, CJ_REC)) - NumV(G_J(i, CJ_DEP))
                End If
            End If
        Next i
        tres = esp + bq
        For m = 1 To 12
            dm = DateSerial(Year(d1), Month(d1) + m - 1, 1)
            If dm <= asOf Then
                sh.Cells(TB_M1 + m - 1, 8).Value = recM(m)
                sh.Cells(TB_M1 + m - 1, 9).Value = depM(m)
                tres = tres + tresM(m)
                sh.Cells(TB_M1 + m - 1, 10).Value = tres
            End If
        Next m
    End If
    If ModuleRight("COTISATIONS") <> "" Then
        CotisationsInterne asOf, False, nbRet, totRes
        TbLigne sh, row, "Cotisations", "Taux de recouvrement", G_CotisTaux, "p", nbRet & " membre(s) avec au moins " & ParamNum("MOIS_ALERTE_ARRIERES", 3) & " mois de retard ; reste " & Fcfa(totRes)
    End If
    ' --- patrimoine
    If RightOf(SH_PAT) <> "" Then
        RecalculerPatrimoineInterne asOf
        BeginWork
        Set ps = WS(SH_PAT)
        For i = FIRSTROW To LastRow(ps, 1)
            If CStr(ps.Cells(i, 1).Value) <> "" Then
                nBiens = nBiens + 1
                vnet = vnet + NumV(ps.Cells(i, ColOf(ps, "Valeur nette (FCFA)")).Value)
                If CStr(ps.Cells(i, ColOf(ps, "État")).Value) = "À réparer" Or CStr(ps.Cells(i, ColOf(ps, "État")).Value) = "Hors service" Then nRep = nRep + 1
            End If
        Next i
        TbLigne sh, row, "Patrimoine", "Valeur nette du patrimoine", vnet, "m", nBiens & " fiche(s) de biens"
        TbLigne sh, row, "Patrimoine", "Biens à réparer ou hors service", nRep, "n", RetoursEnRetard() & " retour(s) en retard"
    End If
    ' --- planning
    If RightOf(SH_PLAN) <> "" Then
        Set ps = WS(SH_PLAN)
        For i = FIRSTROW To LastRow(ps, 1)
            st = CStr(ps.Cells(i, ColOf(ps, "Statut")).Value)
            If CStr(ps.Cells(i, ColOf(ps, "Exercice")).Value) = exo And st <> "Annulée" And st <> "" Then
                nPlan = nPlan + 1
                If st = "Réalisée" Then nReal = nReal + 1
            End If
            d = AsDate(ps.Cells(i, ColOf(ps, "Début")).Value)
            If d >= asOf And st <> "Annulée" And st <> "Réalisée" And (prochain = 0 Or d < prochain) Then
                prochain = d
                txt = CStr(ps.Cells(i, ColOf(ps, "Activité")).Value) & " le " & Format$(d, "dd/mm/yyyy") & " (" & st & ")"
            End If
        Next i
        TbLigne sh, row, "Planning", "Activités réalisées / prévues", nReal & " / " & nPlan, "t", IIf(txt <> "", "Prochaine : " & txt, "")
    End If
    ' --- mandats
    If RightOf(SH_MANDATS) <> "" Then
        Set ps = WS(SH_MANDATS)
        prochain = 0
        For i = FIRSTROW To LastRow(ps, 1)
            If CStr(ps.Cells(i, ColOf(ps, "Statut")).Value) = "En cours" Then
                d = AsDate(ps.Cells(i, ColOf(ps, "Fin")).Value)
                If d > 0 And (prochain = 0 Or d < prochain) Then prochain = d
            End If
        Next i
        txt = PostesVacants()
        TbLigne sh, row, "Mandats", "Prochaine fin de mandat", IIf(prochain > 0, Format$(prochain, "dd/mm/yyyy"), "-"), "t", IIf(txt <> "", "Postes vacants : " & txt, "Bureau au complet")
    End If
    ' --- discipline
    If RightOf(SH_DISC) <> "" Then
        Set ps = WS(SH_DISC)
        nPlan = 0: nReal = 0
        For i = FIRSTROW To LastRow(ps, 1)
            st = CStr(ps.Cells(i, ColOf(ps, "Statut")).Value)
            If st = "En cours" Then nPlan = nPlan + 1
            If st = "À examiner" Then nReal = nReal + 1
        Next i
        TbLigne sh, row, "Discipline", "Sanctions en cours", nPlan, "n", nReal & " dossier(s) à examiner"
    End If
    ' --- cantiques
    If RightOf(SH_CANT) <> "" Then
        Set ps = WS(SH_CANT)
        nPlan = 0: nReal = 0
        For i = FIRSTROW To LastRow(ps, 1)
            If CStr(ps.Cells(i, 1).Value) <> "" Then
                nPlan = nPlan + 1
                If CStr(ps.Cells(i, ColOf(ps, "Niveau")).Value) = NIV_OK Then nReal = nReal + 1
            End If
        Next i
        TbLigne sh, row, "Cantiques", "Cantiques maîtrisés par le chœur", nReal & " / " & nPlan, "t", ""
    End If
    If row = OUT_FIRST Then sh.Cells(row, 2).Value = "Aucun indicateur disponible pour votre rôle."
    EndWork
    Exit Sub
EH:
    ShowError "Tableau de bord"
End Sub

' ============================================================ pupitres et commissions
Public Sub CalculerRapportPupitres()
    Dim sh As Worksheet, d1 As Date, d2 As Date
    If Not RequireLogin() Then Exit Sub
    Set sh = WS(SH_RPUP)
    d1 = DateEntree(sh, "C5", ExerciceDebut(ExerciceDe(Date)))
    d2 = DateEntree(sh, "E5", Date)
    RapportPupitresInterne d1, d2
    sh.Activate
End Sub

Public Function RapportPupitresInterne(ByVal d1 As Date, ByVal d2 As Date) As Long
    Dim sh As Worksheet, grp As Collection, nb As New Collection, noms() As String, att() As Double, pond() As Double, ng As Long
    Dim lst As Collection, i As Long, k As Long, r As Long, nOk As Long, nEn As Long, nZ As Long, nm As String
    Dim nb2 As New Collection
    On Error GoTo EH
    Set sh = WS(SH_RPUP)
    BeginWork
    sh.Range("A" & RP_P1 & ":I" & RP_P1 + 6).ClearContents
    sh.Range("A" & RP_P1 & ":I" & RP_P1 + 6).Font.Bold = False
    sh.Range("A" & RP_C1 & ":I" & RP_C1 + 11).ClearContents
    sh.Range("C5").Value = d1
    sh.Range("E5").Value = d2
    sh.Range("B6").Value = "Membres actifs ; assiduité = présences pondérées ÷ séances attendues, du " & Format$(d1, "dd/mm/yyyy") & " au " & Format$(d2, "dd/mm/yyyy")
    LoadPresenceCache
    ' pupitres
    Set grp = GroupesMembres(True, nb)
    ng = AgregerPresences(d1, d2, grp, False, noms, att, pond)
    Set lst = ListValues("Pupitre")
    For i = 1 To lst.Count
        If i > 6 Then Exit For
        LignePupitre sh, RP_P1 + i - 1, CStr(lst.Item(i)), CStr(lst.Item(i)), nb, noms, ng, att, pond
    Next i
    LignePupitre sh, RP_P1 + 6, "TOUS", "Ensemble de la chorale", nb, noms, ng, att, pond
    sh.Range("A" & RP_P1 + 6 & ":I" & RP_P1 + 6).Font.Bold = True
    sh.Range("E" & RP_P1 & ":E" & RP_P1 + 6).NumberFormat = "0%"
    sh.Range("I" & RP_P1 & ":I" & RP_P1 + 6).NumberFormat = "0%"
    ' commissions
    Set grp = GroupesMembres(False, nb2)
    ng = AgregerPresences(d1, d2, grp, False, noms, att, pond)
    Set lst = ListValues("Commission")
    For i = 1 To lst.Count
        If i > 12 Then Exit For
        r = RP_C1 + i - 1
        nm = CStr(lst.Item(i))
        sh.Cells(r, 1).Value = nm
        If KeyExists(nb2, nm) Then sh.Cells(r, 2).Value = nb2.Item(nm) Else sh.Cells(r, 2).Value = 0
        k = IndexDe(noms, ng, nm)
        If k > 0 Then
            sh.Cells(r, 3).Value = att(k)
            sh.Cells(r, 4).Value = pond(k)
            sh.Cells(r, 5).Value = TauxDe(att(k), pond(k))
        End If
    Next i
    sh.Range("E" & RP_C1 & ":E" & RP_C1 + 11).NumberFormat = "0%"
    EndWork
    RapportPupitresInterne = lst.Count
    Exit Function
EH:
    ShowError "Rapport par pupitre"
End Function

Private Sub LignePupitre(ByVal sh As Worksheet, ByVal r As Long, ByVal nm As String, ByVal titre As String, ByVal nb As Collection, _
                         noms() As String, ByVal ng As Long, att() As Double, pond() As Double)
    Dim k As Long, nOk As Long, nEn As Long, nZ As Long
    sh.Cells(r, 1).Value = titre
    If KeyExists(nb, nm) Then sh.Cells(r, 2).Value = nb.Item(nm) Else sh.Cells(r, 2).Value = 0
    k = IndexDe(noms, ng, nm)
    If k > 0 Then
        sh.Cells(r, 3).Value = att(k)
        sh.Cells(r, 4).Value = pond(k)
        sh.Cells(r, 5).Value = TauxDe(att(k), pond(k))
    End If
    If MaitrisePupitre(nm, nOk, nEn, nZ) Then
        sh.Cells(r, 6).Value = nOk
        sh.Cells(r, 7).Value = nEn
        sh.Cells(r, 8).Value = nZ
        If nOk + nEn + nZ > 0 Then sh.Cells(r, 9).Value = nOk / (nOk + nEn + nZ)
    End If
End Sub

' ============================================================ livre de caisse
Public Sub CalculerLivreCaisse()
    Dim sh As Worksheet, d1 As Date, d2 As Date, n As Long
    If Not RequireLogin() Then Exit Sub
    If ModuleRight("FINANCES") = "" Then Exit Sub
    Set sh = WS(SH_LIVRE)
    d1 = DateEntree(sh, "C5", DateSerial(Year(Date), Month(Date), 1))
    d2 = DateEntree(sh, "E5", Date)
    n = LivreCaisseInterne(d1, d2, CStr(sh.Range("G5").Value))
    sh.Activate
End Sub

Public Function LivreCaisseInterne(ByVal d1 As Date, ByVal d2 As Date, ByVal caisse As String) As Long
    Dim sh As Worksheet, i As Long, j As Long, n As Long, ord() As Long, cle() As Double, tmp As Variant, out() As Variant
    Dim esp As Double, bq As Double, soc As Double, solde As Double, tRec As Double, tDep As Double, d As Date, k As Long, libelle As String
    On Error GoTo EH
    If caisse <> CAISSE_ESP And caisse <> CAISSE_BQ Then caisse = "Toutes"
    Set sh = WS(SH_LIVRE)
    BeginWork
    sh.Range("A" & OUT_FIRST & ":I" & MAXROWS).ClearContents
    sh.Range("A" & OUT_FIRST & ":I" & MAXROWS).Font.Bold = False
    sh.Range("A6").Value = ""
    sh.Range("C5").Value = d1
    sh.Range("E5").Value = d2
    sh.Range("G5").Value = caisse
    Soldes d1 - 1, esp, bq, soc
    If caisse = CAISSE_ESP Then
        solde = esp
    ElseIf caisse = CAISSE_BQ Then
        solde = bq
    Else
        solde = esp + bq
    End If
    ReDim ord(1 To G_JN + 1): ReDim cle(1 To G_JN + 1)
    For i = 1 To G_JN
        d = AsDate(G_J(i, CJ_DATE))
        If d >= d1 And d <= d2 And (caisse = "Toutes" Or CStr(G_J(i, CJ_CAISSE)) = caisse) Then
            n = n + 1
            ord(n) = i
            cle(n) = CDbl(d) + i / 1000000
        End If
    Next i
    For i = 2 To n
        j = i
        Do While j > 1
            If cle(j - 1) <= cle(j) Then Exit Do
            tmp = cle(j): cle(j) = cle(j - 1): cle(j - 1) = tmp
            tmp = ord(j): ord(j) = ord(j - 1): ord(j - 1) = tmp
            j = j - 1
        Loop
    Next i
    ReDim out(1 To n + 2, 1 To 9)
    out(1, 2) = d1
    out(1, 5) = "Solde au " & Format$(d1 - 1, "dd/mm/yyyy") & " (" & LCase$(caisse) & ")"
    out(1, 9) = solde
    For j = 1 To n
        k = ord(j)
        libelle = CStr(G_J(k, CJ_LIB))
        If CStr(G_J(k, CJ_STATUT)) = "Annulée" Then libelle = libelle & " (annulée)"
        out(j + 1, 1) = G_J(k, CJ_PIECE)
        out(j + 1, 2) = G_J(k, CJ_DATE)
        out(j + 1, 3) = G_J(k, CJ_CAISSE)
        out(j + 1, 4) = G_J(k, CJ_CODE)
        out(j + 1, 5) = libelle
        out(j + 1, 6) = G_J(k, CJ_TIERS)
        If NumV(G_J(k, CJ_REC)) <> 0 Then out(j + 1, 7) = NumV(G_J(k, CJ_REC))
        If NumV(G_J(k, CJ_DEP)) <> 0 Then out(j + 1, 8) = NumV(G_J(k, CJ_DEP))
        tRec = tRec + NumV(G_J(k, CJ_REC))
        tDep = tDep + NumV(G_J(k, CJ_DEP))
        solde = solde + NumV(G_J(k, CJ_REC)) - NumV(G_J(k, CJ_DEP))
        out(j + 1, 9) = solde
    Next j
    out(n + 2, 5) = "TOTAUX ET SOLDE AU " & Format$(d2, "dd/mm/yyyy")
    out(n + 2, 7) = tRec
    out(n + 2, 8) = tDep
    out(n + 2, 9) = solde
    sh.Range("A" & OUT_FIRST).Resize(n + 2, 9).Value = out
    sh.Range("A" & OUT_FIRST + n + 1 & ":I" & OUT_FIRST + n + 1).Font.Bold = True
    sh.Range("A" & OUT_FIRST & ":I" & OUT_FIRST).Font.Bold = True
    sh.Range("A6").Value = n & " écriture(s) - " & IIf(caisse = "Toutes", "espèces et banque (les virements internes s'annulent)", caisse)
    ZoneImpression sh, OUT_FIRST + n + 1, 9
    EndWork
    LivreCaisseInterne = n
    Exit Function
EH:
    ShowError "Livre de caisse"
End Function

' ============================================================ point financier du mois
Public Sub CalculerPointMensuel()
    Dim sh As Worksheet
    If Not RequireLogin() Then Exit Sub
    If ModuleRight("FINANCES") = "" Then Exit Sub
    Set sh = WS(SH_PMOIS)
    PointMensuelInterne DateEntree(sh, "C5", Date)
    sh.Activate
End Sub

' Totaux par rubrique : cles "sens|rubrique" -> index dans noms/valeurs
Private Sub AjouterRub(ByVal idx As Collection, noms() As String, sens() As String, ByRef n As Long, ByVal s As String, ByVal rub As String, _
                       vals() As Double, ByVal col As Long, ByVal montant As Double)
    Dim k As Long, cle As String
    cle = s & "|" & rub
    If KeyExists(idx, cle) Then
        k = idx.Item(cle)
    Else
        n = n + 1
        k = n
        noms(n) = rub
        sens(n) = s
        idx.Add n, cle
    End If
    vals(k, col) = vals(k, col) + montant
End Sub

Public Sub PointMensuelInterne(ByVal dRef As Date)
    Dim sh As Worksheet, m1 As Date, m2 As Date, exo As String, row As Long, i As Long, k As Long, n As Long, mi As Long
    Dim e0 As Double, b0 As Double, s0 As Double, e1 As Double, b1 As Double, s1 As Double
    Dim recE As Double, recB As Double, depE As Double, depB As Double, virE As Double, virB As Double
    Dim idx As New Collection, noms(1 To 300) As String, sens(1 To 300) As String, vals(1 To 300, 1 To 3) As Double
    Dim code As String, d As Date, s As String, net As Double, bs As Worksheet, cM As Long, sec As Variant, tot(1 To 3) As Double
    Dim totR(1 To 3) As Double, nbRet As Long, totRes As Double, cotis As Double, payeurs As New Collection, mat As String, attention As String
    On Error GoTo EH
    m1 = DateSerial(Year(dRef), Month(dRef), 1)
    m2 = DateSerial(Year(dRef), Month(dRef) + 1, 0)
    exo = ExerciceDe(m1)
    mi = MoisIndex(m1)
    Set sh = WS(SH_PMOIS)
    BeginWork
    ViderLibre sh, 6, 6
    sh.Range("C5").Value = dRef
    sh.Cells(6, 2).Value = "Mois de " & MoisLong(Month(m1)) & " " & Year(m1) & " (exercice " & exo & ") - établi le " & Format$(Date, "dd/mm/yyyy")
    row = 7
    ' 1. tresorerie
    Soldes m1 - 1, e0, b0, s0
    Soldes m2, e1, b1, s1
    For i = 1 To G_JN
        d = AsDate(G_J(i, CJ_DATE))
        code = CStr(G_J(i, CJ_CODE))
        If d >= m1 And d <= m2 Then
            net = NumV(G_J(i, CJ_REC)) - NumV(G_J(i, CJ_DEP))
            If code = CODE_VIREMENT Then
                If CStr(G_J(i, CJ_CAISSE)) = CAISSE_ESP Then virE = virE + net Else virB = virB + net
            ElseIf CStr(G_J(i, CJ_CAISSE)) = CAISSE_ESP Then
                recE = recE + NumV(G_J(i, CJ_REC)): depE = depE + NumV(G_J(i, CJ_DEP))
            Else
                recB = recB + NumV(G_J(i, CJ_REC)): depB = depB + NumV(G_J(i, CJ_DEP))
            End If
            If code = ParamStr("CODE_COTISATION", "R01.1") Then
                cotis = cotis + net
                mat = CStr(G_J(i, CJ_MAT))
                If mat <> "" And Not KeyExists(payeurs, mat) Then payeurs.Add mat, mat
            End If
        End If
        ' realise par rubrique : mois (col 2) et cumul de l'exercice (col 3)
        If code <> CODE_VIREMENT And code <> "" And CStr(G_J(i, CJ_EXO)) = exo And d <= m2 Then
            s = CStr(RubValeur(code, "Sens"))
            If s = "Recette" Then net = NumV(G_J(i, CJ_REC)) - NumV(G_J(i, CJ_DEP)) Else net = NumV(G_J(i, CJ_DEP)) - NumV(G_J(i, CJ_REC))
            If d >= m1 Then AjouterRub idx, noms, sens, n, s, CStr(G_J(i, CJ_RUB)), vals, 2, net
            AjouterRub idx, noms, sens, n, s, CStr(G_J(i, CJ_RUB)), vals, 3, net
        End If
    Next i
    RSection sh, row, "1. Trésorerie", 6
    REntete sh, row, Array("", "Espèces", "Banque", "Total", "", "Fonds social")
    RLigne sh, row, Array("Solde au début du mois", e0, b0, e0 + b0, "", s0), "t|m|m|m|t|m"
    RLigne sh, row, Array("Recettes du mois", recE, recB, recE + recB), "t|m|m|m"
    RLigne sh, row, Array("Dépenses du mois", depE, depB, depE + depB), "t|m|m|m"
    RLigne sh, row, Array("Virements internes (net)", virE, virB, virE + virB), "t|m|m|m"
    RLigne sh, row, Array("Solde à la fin du mois", e1, b1, e1 + b1, "", s1), "t|m|m|m|t|m"
    RGras sh, row - 1, 6
    ' budget du mois
    Set bs = WS(SH_BUDGET)
    cM = ColOf(bs, "M" & Format$(mi, "00"))
    For i = FIRSTROW To LastRow(bs, 2)
        If CStr(bs.Cells(i, 1).Value) = exo Then AjouterRub idx, noms, sens, n, CStr(bs.Cells(i, 3).Value), CStr(bs.Cells(i, 4).Value), vals, 1, NumV(bs.Cells(i, cM).Value)
    Next i
    For Each sec In Array("Recette", "Dépense")
        RSection sh, row, IIf(sec = "Recette", "2. Recettes par rubrique", "3. Dépenses par rubrique"), 6
        REntete sh, row, Array("Rubrique", "Prévu du mois", "Réalisé du mois", "Écart", "Écart %", "Cumul de l'exercice")
        Erase tot
        For k = 1 To n
            If sens(k) = sec And (vals(k, 1) <> 0 Or vals(k, 2) <> 0 Or vals(k, 3) <> 0) Then
                RLigne sh, row, Array(noms(k), vals(k, 1), vals(k, 2), vals(k, 2) - vals(k, 1), TauxEcart(vals(k, 1), vals(k, 2)), vals(k, 3)), "t|m|m|m|p|m"
                tot(1) = tot(1) + vals(k, 1): tot(2) = tot(2) + vals(k, 2): tot(3) = tot(3) + vals(k, 3)
                If sec = "Dépense" And vals(k, 1) > 0 And vals(k, 2) > vals(k, 1) * (1 + ParamNum("SEUIL_ECART_BUDGET", 0.1)) Then
                    attention = attention & "|Dépassement du budget du mois : " & noms(k) & " (" & Fcfa(vals(k, 2)) & " pour " & Fcfa(vals(k, 1)) & " prévus)"
                End If
                If sec = "Dépense" And vals(k, 1) = 0 And vals(k, 2) > 0 Then attention = attention & "|Dépense non prévue au budget du mois : " & noms(k) & " (" & Fcfa(vals(k, 2)) & ")"
            End If
        Next k
        RLigne sh, row, Array("TOTAL", tot(1), tot(2), tot(2) - tot(1), TauxEcart(tot(1), tot(2)), tot(3)), "t|m|m|m|p|m"
        RGras sh, row - 1, 6
        If sec = "Recette" Then
            totR(1) = tot(1): totR(2) = tot(2): totR(3) = tot(3)
        End If
    Next sec
    RLigne sh, row, Array("RÉSULTAT (recettes - dépenses)", totR(1) - tot(1), totR(2) - tot(2), "", "", totR(3) - tot(3)), "t|m|m|t|t|m"
    RGras sh, row - 1, 6
    ' 4. cotisations
    CotisationsInterne m2, False, nbRet, totRes
    RSection sh, row, "4. Cotisations mensuelles", 6
    RLigne sh, row, Array("Cotisations encaissées dans le mois", cotis, payeurs.Count & " membre(s)"), "t|m|t"
    RLigne sh, row, Array("Taux de recouvrement depuis le début du suivi", G_CotisTaux), "t|p"
    RLigne sh, row, Array("Membres avec au moins " & ParamNum("MOIS_ALERTE_ARRIERES", 3) & " mois de retard", nbRet, "Reste à recouvrer : " & Fcfa(totRes)), "t|n|t"
    ' 5. points d'attention
    If e1 < 0 Then attention = attention & "|Solde des espèces négatif en fin de mois : vérifiez les écritures."
    If s1 < 0 Then attention = attention & "|Fonds social négatif."
    RSection sh, row, "5. Points d'attention", 6
    If attention = "" Then
        sh.Cells(row, 1).Value = "Aucun point particulier."
        row = row + 1
    Else
        For Each sec In Split(Mid$(attention, 2), "|")
            sh.Cells(row, 1).Value = ChrW(8226) & " " & sec
            row = row + 1
        Next sec
    End If
    row = row + 2
    sh.Cells(row, 1).Value = "Le Secrétaire aux Finances"
    sh.Cells(row, 4).Value = "Le 1er Responsable"
    sh.Range(sh.Cells(row, 1), sh.Cells(row, 4)).Font.Bold = True
    sh.Cells(row + 4, 1).Value = TitulaireDe("FIN")
    sh.Cells(row + 4, 4).Value = TitulaireDe("RESP1")
    ZoneImpression sh, row + 5, 6
    EndWork
    Exit Sub
EH:
    ShowError "Point financier du mois"
End Sub

Private Function TauxEcart(ByVal prevu As Double, ByVal realise As Double) As Variant
    If prevu <> 0 Then TauxEcart = (realise - prevu) / prevu Else TauxEcart = ""
End Function

' ============================================================ fiche d'un membre
Public Sub AfficherFicheMembre()
    Dim mat As String
    If Not RequireLogin() Then Exit Sub
    If ActiveSheet.Name = SH_MEMBRES And ActiveCell.Row >= FIRSTROW Then mat = CStr(WS(SH_MEMBRES).Cells(ActiveCell.Row, ColOf(WS(SH_MEMBRES), "Matricule")).Value)
    If mat = "" Then mat = UCase$(Trim$(CStr(WS(SH_FMEMBRE).Range("C5").Value)))
    If mat = "" Then mat = UCase$(Trim$(InputBox("Matricule du membre :", APP_NAME)))
    If mat = "" Then Exit Sub
    If Not FicheMembreInterne(mat, Date) Then
        MsgBox "Matricule inconnu : " & mat, vbExclamation, APP_NAME
        Exit Sub
    End If
    WS(SH_FMEMBRE).Activate
End Sub

Public Function FicheMembreInterne(ByVal mat As String, ByVal asOf As Date) As Boolean
    Dim sh As Worksheet, ms As Worksheet, mr As Long, row As Long, i As Long, k As Long, att As Long, pond As Double, h As Variant
    Dim d1 As Date, d2 As Date, exo As String, totA As Double, totP As Double, cs As Worksheet, x As Worksheet, n As Long, nbRet As Long, totRes As Double
    Dim contrib As Double, nContrib As Long
    On Error GoTo EH
    mr = MembreRow(mat)
    If mr = 0 Then Exit Function
    Set sh = WS(SH_FMEMBRE)
    Set ms = WS(SH_MEMBRES)
    exo = ExerciceDe(asOf)
    BeginWork
    ViderLibre sh, 6, 6
    sh.Range("C5").Value = mat
    sh.Cells(6, 2).Value = NomComplet(ms.Cells(mr, ColOf(ms, "Nom")).Value, ms.Cells(mr, ColOf(ms, "Prénoms")).Value) & " - fiche établie le " & Format$(asOf, "dd/mm/yyyy")
    sh.Cells(6, 2).Font.Bold = True
    row = 7
    RSection sh, row, "Identité et situation", 6
    For Each h In Array("Matricule", "Sexe", "Date de naissance", "Téléphone", "WhatsApp", "Adresse / Quartier", "Personne à prévenir", _
                        "Tél. personne à prévenir", "Date de baptême", "Date d'arrivée", "Date de réception", "Pupitre", "Instrument", _
                        "Commission(s)", "Fonction au Bureau", "Situation matrimoniale", "Statut", "Date du statut")
        RLigne sh, row, Array(CStr(h), ms.Cells(mr, ColOf(ms, CStr(h))).Value), IIf(Left$(CStr(h), 5) = "Date ", "t|d", "t|t")
    Next h
    ' assiduite
    If RightOf(SH_PRES) <> "" Then
        LoadPresenceCache
        RSection sh, row, "Assiduité (12 derniers mois)", 6
        REntete sh, row, Array("Mois", "Attendues", "Pondérées", "Taux")
        For i = 11 To 0 Step -1
            d1 = DateSerial(Year(asOf), Month(asOf) - i, 1)
            d2 = DateSerial(Year(d1), Month(d1) + 1, 0)
            MemberRate mat, d1, d2, "TOUS", att, pond
            If att > 0 Then RLigne sh, row, Array(MoisLong(Month(d1)) & " " & Year(d1), att, pond, TauxDe(att, pond)), "t|n|t|p"
            totA = totA + att: totP = totP + pond
        Next i
        RLigne sh, row, Array("Total sur 12 mois", totA, totP, TauxDe(totA, totP)), "t|n|t|p"
        RGras sh, row - 1, 4
    End If
    ' cotisations
    If ModuleRight("COTISATIONS") <> "" Then
        CotisationsInterne asOf, True, nbRet, totRes
        BeginWork
        Set cs = WS(SH_COTIS)
        RSection sh, row, "Cotisations et pénalités au " & Format$(asOf, "dd/mm/yyyy"), 6
        For k = OUT_FIRST To LastRow(cs, 1, OUT_HDR)
            If CStr(cs.Cells(k, 1).Value) = mat Then
                RLigne sh, row, Array("Mois dus depuis le " & Format$(AsDate(cs.Cells(k, 5).Value), "dd/mm/yyyy"), cs.Cells(k, 6).Value, "Montant dû", cs.Cells(k, 7).Value), "t|n|t|m"
                RLigne sh, row, Array("Cotisations payées", cs.Cells(k, 8).Value, "Couvert jusqu'à", cs.Cells(k, 11).Value), "t|m|t|t"
                RLigne sh, row, Array("Mois de retard", cs.Cells(k, 10).Value, "Reste dû", cs.Cells(k, 9).Value), "t|n|t|m"
                RLigne sh, row, Array("Pénalités dues", cs.Cells(k, 12).Value, "Pénalités payées", cs.Cells(k, 13).Value), "t|m|t|m"
                RLigne sh, row, Array("TOTAL À RÉGULARISER", cs.Cells(k, 15).Value), "t|m"
                RGras sh, row - 1, 2
            End If
        Next k
    End If
    ' caisse sociale
    If ModuleRight("SOCIAL") <> "" Then
        RSection sh, row, "Caisse sociale", 6
        LoadJournal
        For i = 1 To G_JN
            If CStr(G_J(i, CJ_MAT)) = mat And CStr(G_J(i, CJ_FONDS)) = "SOCIAL" Then
                contrib = contrib + NumV(G_J(i, CJ_REC))
                If NumV(G_J(i, CJ_REC)) > 0 Then nContrib = nContrib + 1
            End If
        Next i
        RLigne sh, row, Array("Contributions versées", contrib, nContrib & " versement(s)"), "t|m|t"
        Set x = WS(SH_SOCIAL)
        For k = FIRSTROW To LastRow(x, 1)
            If CStr(x.Cells(k, ColOf(x, "Matricule")).Value) = mat Then
                RLigne sh, row, Array("Événement " & x.Cells(k, 1).Value, x.Cells(k, ColOf(x, "Aide versée (FCFA)")).Value, _
                    Format$(AsDate(x.Cells(k, 2).Value), "dd/mm/yyyy") & " - " & x.Cells(k, ColOf(x, "Type d'événement")).Value), "t|m|t"
            End If
        Next k
    End If
    ' patrimoine
    If RightOf(SH_PAT) <> "" Then
        Set x = WS(SH_MOUV)
        n = 0
        For k = FIRSTROW To LastRow(x, 1)
            If InStr(1, CStr(x.Cells(k, MV_BENEF).Value), mat, vbTextCompare) > 0 And CStr(x.Cells(k, MV_STATUT).Value) = "En cours" Then
                If n = 0 Then RSection sh, row, "Matériel en sa possession", 6
                n = n + 1
                RLigne sh, row, Array(CStr(x.Cells(k, MV_TYPE).Value) & " " & x.Cells(k, MV_NUM).Value, x.Cells(k, MV_QTE).Value, _
                    CStr(x.Cells(k, MV_DES).Value) & " (" & x.Cells(k, MV_CODE).Value & ")", "retour prévu", x.Cells(k, MV_RPREVU).Value), "t|n|t|t|d"
            End If
        Next k
    End If
    If ModuleRight("FINANCES") <> "" Or RightOf(SH_PAT) <> "" Then
        Set x = WS(SH_PERTES)
        n = 0
        For k = FIRSTROW To LastRow(x, 1)
            If CStr(x.Cells(k, 4).Value) = mat Then
                If n = 0 Then RSection sh, row, "Pertes et remboursements (art. 51)", 6
                n = n + 1
                RLigne sh, row, Array(CStr(x.Cells(k, 1).Value) & " - " & x.Cells(k, 3).Value, x.Cells(k, 7).Value, "Reste", x.Cells(k, 9).Value, x.Cells(k, 11).Value), "t|m|t|m|t"
            End If
        Next k
    End If
    ' mandats
    Set x = WS(SH_MANDATS)
    n = 0
    For k = FIRSTROW To LastRow(x, 1)
        If CStr(x.Cells(k, 4).Value) = mat Then
            If n = 0 Then RSection sh, row, "Mandats", 6
            n = n + 1
            RLigne sh, row, Array(CStr(x.Cells(k, 3).Value), x.Cells(k, 6).Value, x.Cells(k, 7).Value, "Rang " & x.Cells(k, 8).Value, x.Cells(k, 10).Value), "t|d|d|t|t"
        End If
    Next k
    ' discipline (confidentiel)
    If RightOf(SH_DISC) <> "" Then
        Set x = WS(SH_DISC)
        RSection sh, row, "Discipline (confidentiel)", 6
        n = 0
        For k = FIRSTROW To LastRow(x, 1)
            If CStr(x.Cells(k, 3).Value) = mat Then
                n = n + 1
                RLigne sh, row, Array(Format$(AsDate(x.Cells(k, 2).Value), "dd/mm/yyyy") & " - " & x.Cells(k, 5).Value, x.Cells(k, 7).Value, x.Cells(k, ColOf(x, "Statut")).Value), "t|t|t"
            End If
        Next k
        If n = 0 Then
            sh.Cells(row, 1).Value = "Aucun dossier."
            row = row + 1
        End If
    End If
    ZoneImpression sh, row, 6
    EndWork
    FicheMembreInterne = True
    Exit Function
EH:
    ShowError "Fiche d'un membre"
End Function

' ============================================================ rapport annuel pour l'AG
Public Sub CalculerRapportAG()
    Dim exo As String
    If Not RequireLogin() Then Exit Sub
    exo = Trim$(CStr(WS(SH_RAG).Range("C5").Value))
    If exo = "" Then
        exo = ExerciceDe(Date)
        WS(SH_RAG).Range("C5").Value = exo
    End If
    RapportAGInterne exo
    WS(SH_RAG).Activate
End Sub

Public Sub RapportAGInterne(ByVal exo As String)
    Dim sh As Worksheet, row As Long, d1 As Date, d2 As Date, asOf As Date, x As Worksheet, v As Variant, n As Long, i As Long, k As Long
    Dim st As String, d As Date, cnt As New Collection, lst As Collection, nArr As Long, nRec As Long, nDep As Long, c As Long
    Dim noms() As String, att() As Double, pond() As Double, ng As Long, vide As New Collection, nb As New Collection, grp As Collection
    Dim q As Long, tA As Double, tP As Double, t As Long, nTen As Long, nAnn As Long, e0 As Double, b0 As Double, s0 As Double
    Dim e1 As Double, b1 As Double, s1 As Double, idx As New Collection, rn(1 To 300) As String, rs(1 To 300) As String
    Dim vals(1 To 300, 1 To 3) As Double, nr As Long, code As String, s As String, net As Double, sec As Variant, tot(1 To 3) As Double
    Dim totR(1 To 3) As Double, nbRet As Long, totRes As Double, vnet As Double, vTotAcq As Double, nAcq As Long, vAcq As Double
    Dim nPer As Long, mPer As Double, nOk As Long, nEn As Long, nZ As Long, nProg As Long, nEtudes As Long, dates As New Collection
    On Error GoTo EH
    d1 = ExerciceDebut(exo)
    d2 = ExerciceFin(exo)
    asOf = d2
    If asOf > Date Then asOf = Date
    Set sh = WS(SH_RAG)
    BeginWork
    ViderLibre sh, 6, 6
    sh.Range("C5").NumberFormat = "@"
    sh.Range("C5").Value = exo
    sh.Cells(6, 1).Value = ParamStr("NOM_GROUPE") & " - " & ParamStr("PAROISSE")
    sh.Cells(7, 1).Value = "Rapport de l'exercice " & exo & " (du " & Format$(d1, "dd/mm/yyyy") & " au " & Format$(asOf, "dd/mm/yyyy") & ")"
    sh.Range("A6:A7").Font.Bold = True
    row = 8
    ' 1. effectif
    RSection sh, row, "1. Effectif", 6
    Set x = WS(SH_MEMBRES)
    n = ReadBlock(x, 1, v)
    For i = 1 To n
        If CStr(v(i, ColOf(x, "Matricule"))) <> "" Then
            st = CStr(v(i, ColOf(x, "Statut")))
            If KeyExists(cnt, st) Then
                k = cnt.Item(st): cnt.Remove st: cnt.Add k + 1, st
            Else
                cnt.Add 1, st
            End If
            d = AsDate(v(i, ColOf(x, "Date d'arrivée")))
            If d >= d1 And d <= asOf Then nArr = nArr + 1
            d = AsDate(v(i, ColOf(x, "Date de réception")))
            If d >= d1 And d <= asOf Then nRec = nRec + 1
            d = AsDate(v(i, ColOf(x, "Date du statut")))
            If d >= d1 And d <= asOf And StatutCodeDefaut(st) = "" And st <> "Exclu définitif" And st <> ST_NONRETENU Then nDep = nDep + 1
        End If
    Next i
    REntete sh, row, Array("Statut", "Nombre")
    Set lst = ListValues("Statut")
    For i = 1 To lst.Count
        If KeyExists(cnt, CStr(lst.Item(i))) Then RLigne sh, row, Array(CStr(lst.Item(i)), cnt.Item(CStr(lst.Item(i)))), "t|n"
    Next i
    RLigne sh, row, Array("Arrivées dans l'exercice", nArr), "t|n"
    RLigne sh, row, Array("Réceptions officielles (art. 28)", nRec), "t|n"
    RLigne sh, row, Array("Départs (démission, transfert, décès)", nDep), "t|n"
    ' 2. assiduite
    LoadPresenceCache
    RSection sh, row, "2. Assiduité", 6
    ng = AgregerPresences(d1, asOf, vide, True, noms, att, pond)
    REntete sh, row, Array("Trimestre", "Attendues", "Taux")
    For q = 1 To 4
        tA = 0: tP = 0
        For t = 1 To 3
            k = IndexDe(noms, ng, Format$(DateSerial(Year(d1), Month(d1) + (q - 1) * 3 + t - 1, 1), "yyyy-mm"))
            If k > 0 Then
                tA = tA + att(k): tP = tP + pond(k)
            End If
        Next t
        If tA > 0 Then RLigne sh, row, Array("Trimestre " & q, tA, TauxDe(tA, tP)), "t|n|p"
    Next q
    tA = 0: tP = 0
    For k = 1 To ng
        tA = tA + att(k): tP = tP + pond(k)
    Next k
    RLigne sh, row, Array("Ensemble de l'exercice", tA, TauxDe(tA, tP)), "t|n|p"
    RGras sh, row - 1, 3
    Set grp = GroupesMembres(True, nb)
    ng = AgregerPresences(d1, asOf, grp, False, noms, att, pond)
    row = row + 1
    REntete sh, row, Array("Pupitre", "Membres actifs", "Taux", "Cantiques maîtrisés")
    Set lst = ListValues("Pupitre")
    For i = 1 To lst.Count
        k = IndexDe(noms, ng, CStr(lst.Item(i)))
        If k > 0 Then
            If MaitrisePupitre(CStr(lst.Item(i)), nOk, nEn, nZ) Then
                RLigne sh, row, Array(CStr(lst.Item(i)), nb.Item(CStr(lst.Item(i))), TauxDe(att(k), pond(k)), nOk & " / " & (nOk + nEn + nZ)), "t|n|p|t"
            Else
                RLigne sh, row, Array(CStr(lst.Item(i)), nb.Item(CStr(lst.Item(i))), TauxDe(att(k), pond(k)), "-"), "t|n|p|t"
            End If
        End If
    Next i
    Set x = WS(SH_SEANCES)
    For i = FIRSTROW To LastRow(x, 1)
        d = AsDate(x.Cells(i, 2).Value)
        If d >= d1 And d <= asOf Then
            If UCase$(CStr(x.Cells(i, ColOf(x, "Pointée")).Value)) = "OUI" Then nTen = nTen + 1
            If CStr(x.Cells(i, ColOf(x, "Statut")).Value) = "Annulée" Then nAnn = nAnn + 1
        End If
    Next i
    RLigne sh, row, Array("Séances tenues et pointées", nTen, "Séances annulées : " & nAnn), "t|n|t"
    ' 3. activites
    RSection sh, row, "3. Activités (planning voté en AG)", 6
    Set x = WS(SH_PLAN)
    REntete sh, row, Array("Activité", "Date", "Budget prévu", "Réalisé", "Statut")
    ActualiserPlanningInterne
    BeginWork
    For i = FIRSTROW To LastRow(x, 1)
        If CStr(x.Cells(i, 2).Value) = exo Then
            RLigne sh, row, Array(CStr(x.Cells(i, 5).Value), x.Cells(i, 3).Value, x.Cells(i, 11).Value, x.Cells(i, 12).Value, x.Cells(i, 15).Value), "t|d|m|m|t"
        End If
    Next i
    ' 4. finances
    RSection sh, row, "4. Situation financière", 6
    Soldes d1 - 1, e0, b0, s0
    Soldes asOf, e1, b1, s1
    REntete sh, row, Array("", "Espèces", "Banque", "Total", "", "Fonds social")
    RLigne sh, row, Array("Solde au " & Format$(d1 - 1, "dd/mm/yyyy"), e0, b0, e0 + b0, "", s0), "t|m|m|m|t|m"
    RLigne sh, row, Array("Solde au " & Format$(asOf, "dd/mm/yyyy"), e1, b1, e1 + b1, "", s1), "t|m|m|m|t|m"
    For i = 1 To G_JN
        code = CStr(G_J(i, CJ_CODE))
        If code <> CODE_VIREMENT And code <> "" And CStr(G_J(i, CJ_EXO)) = exo And AsDate(G_J(i, CJ_DATE)) <= asOf Then
            s = CStr(RubValeur(code, "Sens"))
            If s = "Recette" Then net = NumV(G_J(i, CJ_REC)) - NumV(G_J(i, CJ_DEP)) Else net = NumV(G_J(i, CJ_DEP)) - NumV(G_J(i, CJ_REC))
            AjouterRub idx, rn, rs, nr, s, CStr(G_J(i, CJ_RUB)), vals, 2, net
        End If
    Next i
    Set x = WS(SH_BUDGET)
    For i = FIRSTROW To LastRow(x, 2)
        If CStr(x.Cells(i, 1).Value) = exo Then AjouterRub idx, rn, rs, nr, CStr(x.Cells(i, 3).Value), CStr(x.Cells(i, 4).Value), vals, 1, BudgetRetenu(x, i)
    Next i
    For Each sec In Array("Recette", "Dépense")
        row = row + 1
        REntete sh, row, Array(IIf(sec = "Recette", "Recettes", "Dépenses"), "Budget voté", "Réalisé", "Écart", "Exécution")
        Erase tot
        For k = 1 To nr
            If rs(k) = sec And (vals(k, 1) <> 0 Or vals(k, 2) <> 0) Then
                RLigne sh, row, Array(rn(k), vals(k, 1), vals(k, 2), vals(k, 2) - vals(k, 1), Execution(vals(k, 1), vals(k, 2))), "t|m|m|m|p"
                tot(1) = tot(1) + vals(k, 1): tot(2) = tot(2) + vals(k, 2)
            End If
        Next k
        RLigne sh, row, Array("TOTAL", tot(1), tot(2), tot(2) - tot(1), Execution(tot(1), tot(2))), "t|m|m|m|p"
        RGras sh, row - 1, 5
        If sec = "Recette" Then
            totR(1) = tot(1): totR(2) = tot(2)
        End If
    Next sec
    RLigne sh, row, Array("RÉSULTAT DE L'EXERCICE", totR(1) - tot(1), totR(2) - tot(2)), "t|m|m"
    RGras sh, row - 1, 5
    CotisationsInterne asOf, False, nbRet, totRes
    RLigne sh, row, Array("Recouvrement des cotisations", G_CotisTaux, nbRet & " membre(s) en retard ; reste " & Fcfa(totRes)), "t|p|t"
    Set x = WS(SH_SOCIAL)
    n = 0: net = 0
    For i = FIRSTROW To LastRow(x, 1)
        d = AsDate(x.Cells(i, 2).Value)
        If d >= d1 And d <= asOf Then
            n = n + 1
            net = net + NumV(x.Cells(i, ColOf(x, "Aide versée (FCFA)")).Value)
        End If
    Next i
    RLigne sh, row, Array("Caisse sociale : événements soutenus", n, "Aides versées : " & Fcfa(net)), "t|n|t"
    ' 5. patrimoine
    RSection sh, row, "5. Patrimoine", 6
    RecalculerPatrimoineInterne asOf
    BeginWork
    Set x = WS(SH_PAT)
    n = 0
    For i = FIRSTROW To LastRow(x, 1)
        If CStr(x.Cells(i, 1).Value) <> "" Then
            n = n + 1
            vTotAcq = vTotAcq + NumV(x.Cells(i, ColOf(x, "Valeur totale (FCFA)")).Value)
            vnet = vnet + NumV(x.Cells(i, ColOf(x, "Valeur nette (FCFA)")).Value)
            d = AsDate(x.Cells(i, ColOf(x, "Date d'acquisition")).Value)
            If d >= d1 And d <= asOf Then
                nAcq = nAcq + 1
                vAcq = vAcq + NumV(x.Cells(i, ColOf(x, "Valeur totale (FCFA)")).Value)
            End If
        End If
    Next i
    RLigne sh, row, Array("Fiches de biens", n, "Valeur d'acquisition : " & Fcfa(vTotAcq)), "t|n|t"
    RLigne sh, row, Array("Valeur nette (après amortissement)", vnet), "t|m"
    RLigne sh, row, Array("Acquisitions de l'exercice", nAcq, Fcfa(vAcq)), "t|n|t"
    Set x = WS(SH_PERTES)
    For i = FIRSTROW To LastRow(x, 1)
        d = AsDate(x.Cells(i, 2).Value)
        If d >= d1 And d <= asOf Then
            nPer = nPer + 1
            mPer = mPer + NumV(x.Cells(i, 7).Value)
        End If
    Next i
    RLigne sh, row, Array("Pertes, vols et manquants (art. 51)", nPer, Fcfa(mPer)), "t|n|t"
    ' 6. discipline (anonyme)
    RSection sh, row, "6. Discipline (nombre de dossiers, sans nom)", 6
    Set x = WS(SH_DISC)
    Set cnt = New Collection
    n = 0
    For i = FIRSTROW To LastRow(x, 1)
        d = AsDate(x.Cells(i, 2).Value)
        If d >= d1 And d <= asOf And CStr(x.Cells(i, 1).Value) <> "" Then
            n = n + 1
            st = CStr(x.Cells(i, ColOf(x, "Sanction")).Value)
            If st = "" Then st = "Sans sanction (à examiner ou classé)"
            If KeyExists(cnt, st) Then
                k = cnt.Item(st): cnt.Remove st: cnt.Add k + 1, st
            Else
                cnt.Add 1, st
            End If
        End If
    Next i
    Set lst = ListValues("Sanction")
    For i = 1 To lst.Count
        If KeyExists(cnt, CStr(lst.Item(i))) Then RLigne sh, row, Array(CStr(lst.Item(i)), cnt.Item(CStr(lst.Item(i)))), "t|n"
    Next i
    If KeyExists(cnt, "Sans sanction (à examiner ou classé)") Then RLigne sh, row, Array("Sans sanction (à examiner ou classé)", cnt.Item("Sans sanction (à examiner ou classé)")), "t|n"
    RLigne sh, row, Array("Total des dossiers", n), "t|n"
    RGras sh, row - 1, 2
    ' 7. mandats
    RSection sh, row, "7. Bureau et mandats", 6
    Set x = WS(SH_MANDATS)
    REntete sh, row, Array("Fonction", "Titulaire", "Fin du mandat", "Rang")
    For i = FIRSTROW To LastRow(x, 1)
        If CStr(x.Cells(i, 10).Value) = "En cours" And CStr(x.Cells(i, 2).Value) = "Bureau" Then
            RLigne sh, row, Array(CStr(x.Cells(i, 3).Value), x.Cells(i, 5).Value, x.Cells(i, 7).Value, x.Cells(i, 8).Value), "t|t|d|n"
        End If
    Next i
    s = PostesVacants()
    If s <> "" Then RLigne sh, row, Array("Postes vacants : " & s), "t"
    ' 8. vie spirituelle
    RSection sh, row, "8. Vie spirituelle et répertoire", 6
    Set x = WS(SH_CANT)
    n = 0: k = 0
    For i = FIRSTROW To LastRow(x, 1)
        If CStr(x.Cells(i, 1).Value) <> "" Then
            n = n + 1
            If CStr(x.Cells(i, ColOf(x, "Niveau")).Value) = NIV_OK Then k = k + 1
        End If
    Next i
    RLigne sh, row, Array("Cantiques au répertoire", n, k & " maîtrisé(s) par tout le chœur"), "t|n|t"
    Set x = WS(SH_PROGS)
    For i = FIRSTROW To LastRow(x, 1)
        d = AsDate(x.Cells(i, 1).Value)
        If d >= d1 And d <= asOf Then
            If Not KeyExists(dates, CStr(CLng(d))) Then dates.Add 1, CStr(CLng(d))
        End If
    Next i
    RLigne sh, row, Array("Célébrations avec programme des chants", dates.Count), "t|n"
    Set x = WS(SH_ETUDES)
    For i = FIRSTROW To LastRow(x, 1)
        d = AsDate(x.Cells(i, 1).Value)
        If d >= d1 And d <= asOf And CStr(x.Cells(i, ColOf(x, "Statut")).Value) = "Réalisée" Then nEtudes = nEtudes + 1
    Next i
    RLigne sh, row, Array("Études bibliques et activités spirituelles réalisées", nEtudes), "t|n"
    ' signatures
    row = row + 2
    sh.Cells(row, 1).Value = "Fait à " & ParamStr("VILLE", "Pointe-Noire") & ", le " & Format$(Date, "dd/mm/yyyy")
    row = row + 2
    sh.Cells(row, 1).Value = "Le Secrétaire Général"
    sh.Cells(row, 3).Value = "Le Secrétaire aux Finances"
    sh.Cells(row, 5).Value = "Le 1er Responsable"
    sh.Range(sh.Cells(row, 1), sh.Cells(row, 6)).Font.Bold = True
    sh.Cells(row + 4, 1).Value = TitulaireDe("SG")
    sh.Cells(row + 4, 3).Value = TitulaireDe("FIN")
    sh.Cells(row + 4, 5).Value = TitulaireDe("RESP1")
    ZoneImpression sh, row + 5, 6
    EndWork
    LogAction "Rapport AG", exo, SH_RAG
    Exit Sub
EH:
    ShowError "Rapport pour l'AG"
End Sub

Private Function Execution(ByVal prevu As Double, ByVal realise As Double) As Variant
    If prevu <> 0 Then Execution = realise / prevu Else Execution = ""
End Function

' Dossier complet de l'AG en un seul PDF : rapport, suivi budgetaire, programme, pupitres, patrimoine
Public Sub DossierAGPDF()
    Dim exo As String, noms As String, f As String, m As Long, d2 As Date
    If Not RequireLogin() Then Exit Sub
    exo = Trim$(CStr(WS(SH_RAG).Range("C5").Value))
    If exo = "" Then exo = ExerciceDe(Date)
    noms = PreparerDossierAG(exo)
    f = NomPDF("Dossier_AG_" & exo)
    If ExporterFeuillesPDF(Split(noms, "|"), f) Then MsgBox "Dossier de l'AG enregistré :" & vbCrLf & f, vbInformation, APP_NAME
End Sub

' Calcule les feuilles du dossier de l'AG autorisees au role ; renvoie leurs noms separes par "|"
Public Function PreparerDossierAG(ByVal exo As String) As String
    Dim d2 As Date, m As Long, noms As String
    d2 = ExerciceFin(exo)
    If d2 > Date Then d2 = Date
    RapportAGInterne exo
    noms = SH_RAG
    If RightOf(SH_SUIVI_BUDGET) <> "" Then
        m = MoisIndex(d2)
        SuiviBudgetInterne exo, m
        noms = noms & "|" & SH_SUIVI_BUDGET
    End If
    If RightOf(SH_PROGAN) <> "" Then
        ProgrammeAnnuelInterne exo
        WS(SH_PROGAN).Range("C5").Value = exo
        noms = noms & "|" & SH_PROGAN
    End If
    If RightOf(SH_RPUP) <> "" Then
        RapportPupitresInterne ExerciceDebut(exo), d2
        noms = noms & "|" & SH_RPUP
    End If
    If RightOf(SH_SYNTH) <> "" Then
        SynthesePatInterne d2
        noms = noms & "|" & SH_SYNTH
    End If
    PreparerDossierAG = noms
End Function
