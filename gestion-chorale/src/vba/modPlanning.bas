Option Explicit
' =============================================================================
' modPlanning : planning annuel des activites (art. 6, 20, 24). Circuit :
' Projet -> Votee en AG -> Validee (validation paroissiale obligatoire hors
' paroisse) -> seance creee dans SEANCES -> Realisee. Le realise est la somme
' des depenses de caisse dont la Reference est le N° de l'activite.
' =============================================================================

Public Const SH_PLAN As String = "PLANNING"
Public Const SH_PROGAN As String = "PROGRAMME_ANNUEL"

Private Function PC(ByVal entete As String) As Long
    PC = ColOf(WS(SH_PLAN), entete)
End Function

Public Function ActiviteRow(ByVal num As String) As Long
    Dim sh As Worksheet, r As Long
    If num = "" Then Exit Function
    Set sh = WS(SH_PLAN)
    For r = FIRSTROW To LastRow(sh, 1)
        If StrComp(CStr(sh.Cells(r, 1).Value), num, vbTextCompare) = 0 Then
            ActiviteRow = r
            Exit Function
        End If
    Next r
End Function

Private Function NextActivite(ByVal d As Date) As String
    Dim sh As Worksheet, r As Long, pre As String, v As String, n As Long, mx As Long
    Set sh = WS(SH_PLAN)
    pre = "ACT-" & Year(d) & "-"
    For r = FIRSTROW To LastRow(sh, 1)
        v = CStr(sh.Cells(r, 1).Value)
        If Left$(v, Len(pre)) = pre Then
            n = CLng(Val(Mid$(v, Len(pre) + 1)))
            If n > mx Then mx = n
        End If
    Next r
    NextActivite = pre & Format$(mx + 1, "00")
End Function

Private Function ActiviteSelectionnee() As String
    If ActiveSheet.Name = SH_PLAN And ActiveCell.Row >= FIRSTROW Then ActiviteSelectionnee = CStr(WS(SH_PLAN).Cells(ActiveCell.Row, 1).Value)
    If ActiviteSelectionnee = "" Then ActiviteSelectionnee = UCase$(Trim$(InputBox("N° de l'activité (ex. ACT-2026-05) :", APP_NAME)))
End Function

' Complete une ligne saisie a la main (N°, exercice, valeurs par defaut)
Private Sub CompleterActivite(ByVal sh As Worksheet, ByVal r As Long)
    Dim d As Date
    d = AsDate(sh.Cells(r, PC("Début")).Value)
    If d = 0 Or CStr(sh.Cells(r, PC("Activité")).Value) = "" Then Exit Sub
    If CStr(sh.Cells(r, 1).Value) = "" Then sh.Cells(r, 1).Value = NextActivite(d)
    sh.Cells(r, PC("Exercice")).NumberFormat = "@"
    sh.Cells(r, PC("Exercice")).Value = ExerciceDe(d)
    If CStr(sh.Cells(r, PC("Hors paroisse")).Value) = "" Then sh.Cells(r, PC("Hors paroisse")).Value = "NON"
    If CStr(sh.Cells(r, PC("Validation paroissiale")).Value) = "" Then
        sh.Cells(r, PC("Validation paroissiale")).Value = IIf(UCase$(CStr(sh.Cells(r, PC("Hors paroisse")).Value)) = "OUI", "Demandée", "Non requise")
    End If
    If CStr(sh.Cells(r, PC("Statut")).Value) = "" Then sh.Cells(r, PC("Statut")).Value = "Projet"
End Sub

Public Sub OnPlanningChange(ByVal Target As Range)
    Dim sh As Worksheet, rw As Range, n As Long
    On Error GoTo Fin
    Set sh = Target.Worksheet
    Application.EnableEvents = False
    For Each rw In Target.Rows
        n = n + 1
        If n > 500 Then Exit For
        If rw.Row >= FIRSTROW Then CompleterActivite sh, rw.Row
    Next rw
Fin:
    Application.EnableEvents = True
End Sub

' ------------------------------------------------------------ saisie
Public Sub NouvelleActivite()
    Dim sd As String, d1 As Date, d2 As Date, intitule As String, typ As String, lieu As String, hors As String
    Dim com As String, code As String, bud As String, num As String
    If Not RequireEdit(SH_PLAN) Then Exit Sub
    intitule = Trim$(InputBox("Intitulé de l'activité :", APP_NAME))
    If intitule = "" Then Exit Sub
    sd = InputBox("Date de début (jj/mm/aaaa) :", APP_NAME)
    If Not IsDate(sd) Then Exit Sub
    d1 = CDate(sd)
    sd = InputBox("Date de fin (vide si l'activité dure un jour) :", APP_NAME)
    If IsDate(sd) Then d2 = CDate(sd)
    typ = UCase$(Trim$(InputBox("Code du type d'activité (REP, CULTE, EVANG, VEIL, REUN, ETUDE, AUTRE...) :", APP_NAME, "AUTRE")))
    lieu = InputBox("Lieu :", APP_NAME, "Temple")
    hors = IIf(MsgBox("L'activité a-t-elle lieu hors de la paroisse ? (validation paroissiale requise, art. 6)", vbYesNo + vbQuestion, APP_NAME) = vbYes, "OUI", "NON")
    com = InputBox("Commission responsable :", APP_NAME, "Organisation")
    code = UCase$(Trim$(InputBox("Code budgétaire (rubrique de dépense, ex. D02.1 ; vide si aucun) :", APP_NAME)))
    bud = InputBox("Budget prévu (FCFA) :", APP_NAME, "0")
    num = NouvelleActiviteInterne(d1, d2, intitule, typ, lieu, hors, com, code, NumV(bud))
    If num = "" Then
        MsgBox G_LastError, vbExclamation, APP_NAME
    Else
        MsgBox "Activité " & num & " ajoutée au planning (statut « Projet »).", vbInformation, APP_NAME
        WS(SH_PLAN).Cells(ActiviteRow(num), 1).Select
    End If
End Sub

Public Function NouvelleActiviteInterne(ByVal d1 As Date, ByVal d2 As Date, ByVal intitule As String, ByVal typ As String, ByVal lieu As String, _
                                        ByVal hors As String, ByVal com As String, ByVal code As String, ByVal bud As Double) As String
    Dim sh As Worksheet, r As Long
    G_LastError = ""
    If d1 = 0 Or Trim$(intitule) = "" Then
        G_LastError = "Indiquez au moins l'intitulé et la date de début."
        Exit Function
    End If
    If d2 > 0 And d2 < d1 Then
        G_LastError = "La date de fin est antérieure à la date de début."
        Exit Function
    End If
    If typ <> "" And TypeRow(typ) = 0 Then
        G_LastError = "Type d'activité inconnu : " & typ & " (voir TYPES_ACTIVITE)."
        Exit Function
    End If
    If code <> "" And RubRow(code) = 0 Then
        G_LastError = "Code budgétaire inconnu : " & code & " (voir RUBRIQUES)."
        Exit Function
    End If
    Set sh = WS(SH_PLAN)
    BeginWork
    r = LastRow(sh, 1) + 1
    sh.Cells(r, PC("Début")).Value = d1
    If d2 > 0 Then sh.Cells(r, PC("Fin")).Value = d2
    sh.Cells(r, PC("Activité")).Value = intitule
    sh.Cells(r, PC("Type")).Value = typ
    sh.Cells(r, PC("Lieu")).Value = lieu
    sh.Cells(r, PC("Hors paroisse")).Value = IIf(UCase$(hors) = "OUI", "OUI", "NON")
    sh.Cells(r, PC("Commission responsable")).Value = com
    sh.Cells(r, PC("Code budgétaire")).Value = code
    sh.Cells(r, PC("Budget prévu (FCFA)")).Value = bud
    CompleterActivite sh, r
    NouvelleActiviteInterne = CStr(sh.Cells(r, 1).Value)
    EndWork
    LogAction "Activité planifiée", NouvelleActiviteInterne & " " & intitule, SH_PLAN
End Function

' ------------------------------------------------------------ circuit
Public Sub VoterPlanning()
    Dim exo As String, ref As String, n As Long
    If Not RequireEdit(SH_PLAN) Then Exit Sub
    exo = Trim$(InputBox("Exercice dont le planning a été voté en AG :", APP_NAME, ExerciceDe(Date)))
    If exo = "" Then Exit Sub
    ref = Trim$(InputBox("Référence du PV de l'Assemblée générale :", APP_NAME, "PV AG " & exo))
    If ref = "" Then Exit Sub
    n = VoterPlanningInterne(exo, ref)
    MsgBox n & " activité(s) de l'exercice " & exo & " passée(s) au statut « Votée en AG ».", vbInformation, APP_NAME
End Sub

Public Function VoterPlanningInterne(ByVal exo As String, ByVal ref As String) As Long
    Dim sh As Worksheet, r As Long, n As Long
    Set sh = WS(SH_PLAN)
    BeginWork
    For r = FIRSTROW To LastRow(sh, 1)
        If CStr(sh.Cells(r, PC("Exercice")).Value) = exo And CStr(sh.Cells(r, PC("Statut")).Value) = "Projet" Then
            sh.Cells(r, PC("Statut")).Value = "Votée en AG"
            sh.Cells(r, PC("Observations")).Value = Trim$("Votée en AG (" & ref & ") " & CStr(sh.Cells(r, PC("Observations")).Value))
            n = n + 1
        End If
    Next r
    EndWork
    LogAction "Planning voté en AG", exo & " : " & n & " activité(s) - " & ref, SH_PLAN
    VoterPlanningInterne = n
End Function

Public Sub ValidationParoissiale()
    Dim num As String, rep As String, etat As String, ref As String
    If Not RequireEdit(SH_PLAN) Then Exit Sub
    num = ActiviteSelectionnee()
    If ActiviteRow(num) = 0 Then Exit Sub
    rep = InputBox("Validation paroissiale ou consistoriale de " & num & " (art. 6) :" & vbCrLf & _
                   "  1 - Demandée" & vbCrLf & "  2 - Obtenue" & vbCrLf & "  3 - Refusée", APP_NAME, "2")
    Select Case rep
        Case "1": etat = "Demandée"
        Case "2": etat = "Obtenue"
        Case "3": etat = "Refusée"
        Case Else: Exit Sub
    End Select
    ref = InputBox("Référence (lettre, PV du bureau paroissial...) :", APP_NAME)
    EnregistrerValidationInterne num, etat, ref
    MsgBox "Validation paroissiale : " & etat & ".", vbInformation, APP_NAME
End Sub

Public Sub EnregistrerValidationInterne(ByVal num As String, ByVal etat As String, ByVal ref As String)
    Dim sh As Worksheet, r As Long
    Set sh = WS(SH_PLAN)
    r = ActiviteRow(num)
    If r = 0 Then Exit Sub
    BeginWork
    sh.Cells(r, PC("Validation paroissiale")).Value = etat
    If ref <> "" Then sh.Cells(r, PC("Réf. validation")).Value = ref
    If etat = "Refusée" And CStr(sh.Cells(r, PC("Statut")).Value) <> "Réalisée" Then sh.Cells(r, PC("Statut")).Value = "Annulée"
    EndWork
    LogAction "Validation paroissiale", num & " : " & etat & " " & ref, SH_PLAN
End Sub

Public Sub ValiderActivite()
    Dim num As String, seance As String
    If Not RequireEdit(SH_PLAN) Then Exit Sub
    num = ActiviteSelectionnee()
    If ActiviteRow(num) = 0 Then Exit Sub
    seance = ValiderActiviteInterne(num)
    If seance = "" And G_LastError <> "" Then
        MsgBox G_LastError, vbExclamation, APP_NAME
    ElseIf seance = "" Then
        MsgBox "Activité validée (aucune séance créée : type d'activité non renseigné).", vbInformation, APP_NAME
    Else
        MsgBox "Activité validée. Séance " & seance & " créée dans le calendrier de pointage.", vbInformation, APP_NAME
    End If
End Sub

' Valide une activite votee : cree sa seance de pointage. Renvoie l'ID de la seance.
Public Function ValiderActiviteInterne(ByVal num As String) As String
    Dim sh As Worksheet, r As Long, st As String, seance As String
    G_LastError = ""
    Set sh = WS(SH_PLAN)
    r = ActiviteRow(num)
    If r = 0 Then
        G_LastError = "Activité introuvable : " & num
        Exit Function
    End If
    st = CStr(sh.Cells(r, PC("Statut")).Value)
    If st = "Projet" Then
        G_LastError = "L'activité " & num & " n'est pas encore votée en AG (bouton « Planning voté en AG »)."
        Exit Function
    End If
    If st <> "Votée en AG" And st <> "Validée" Then
        G_LastError = "Impossible de valider une activité au statut « " & st & " »."
        Exit Function
    End If
    If UCase$(CStr(sh.Cells(r, PC("Hors paroisse")).Value)) = "OUI" And CStr(sh.Cells(r, PC("Validation paroissiale")).Value) <> "Obtenue" Then
        G_LastError = "Sortie hors paroisse : la validation du bureau paroissial ou consistorial doit être « Obtenue » (art. 6)." & vbCrLf & _
                      "État actuel : " & CStr(sh.Cells(r, PC("Validation paroissiale")).Value)
        Exit Function
    End If
    BeginWork
    seance = CStr(sh.Cells(r, PC("Séance")).Value)
    If seance = "" Or SeanceRow(seance) = 0 Then
        seance = CreerSeance(AsDate(sh.Cells(r, PC("Début")).Value), CStr(sh.Cells(r, PC("Type")).Value), _
                             CStr(sh.Cells(r, PC("Lieu")).Value), num & " - " & CStr(sh.Cells(r, PC("Activité")).Value))
        sh.Cells(r, PC("Séance")).Value = seance
    End If
    sh.Cells(r, PC("Statut")).Value = "Validée"
    EndWork
    LogAction "Activité validée", num & IIf(seance <> "", " - séance " & seance, ""), SH_PLAN
    ValiderActiviteInterne = seance
End Function

Public Sub AnnulerActivite()
    Dim num As String, motif As String, r As Long, sh As Worksheet, sr As Long, ss As Worksheet
    If Not RequireEdit(SH_PLAN) Then Exit Sub
    num = ActiviteSelectionnee()
    r = ActiviteRow(num)
    If r = 0 Then Exit Sub
    motif = InputBox("Motif de l'annulation de " & num & " :", APP_NAME)
    If motif = "" Then Exit Sub
    Set sh = WS(SH_PLAN)
    Set ss = WS(SH_SEANCES)
    BeginWork
    sh.Cells(r, PC("Statut")).Value = "Annulée"
    sh.Cells(r, PC("Observations")).Value = Trim$(CStr(sh.Cells(r, PC("Observations")).Value) & " Annulée : " & motif)
    sr = SeanceRow(CStr(sh.Cells(r, PC("Séance")).Value))
    If sr > 0 Then
        If UCase$(CStr(ss.Cells(sr, ColOf(ss, "Pointée")).Value)) <> "OUI" Then ss.Cells(sr, ColOf(ss, "Statut")).Value = "Annulée"
    End If
    EndWork
    LogAction "Activité annulée", num & " : " & motif, SH_PLAN
End Sub

' Realise (caisse) et passage a "Realisee" des activites dont la seance est pointee
Public Sub ActualiserPlanning()
    If Not RequireLogin() Then Exit Sub
    ActualiserPlanningInterne
    MsgBox "Planning actualisé (réalisé d'après le journal de caisse, activités réalisées).", vbInformation, APP_NAME
End Sub

Public Sub ActualiserPlanningInterne()
    Dim sh As Worksheet, ss As Worksheet, r As Long, k As Long, num As String, tot As Double, sr As Long, idx As New Collection
    Dim cRe As Long, cSt As Long, cSe As Long, d As Date, df As Date, n As Long
    Set sh = WS(SH_PLAN)
    Set ss = WS(SH_SEANCES)
    cRe = PC("Réalisé (FCFA)"): cSt = PC("Statut"): cSe = PC("Séance")
    LoadJournal
    BeginWork
    For r = FIRSTROW To LastRow(sh, 1)
        num = UCase$(CStr(sh.Cells(r, 1).Value))
        If num <> "" And Not KeyExists(idx, num) Then idx.Add r, num
        sh.Cells(r, cRe).Value = 0
    Next r
    For k = 1 To G_JN
        num = UCase$(CStr(G_J(k, CJ_REF)))
        If num <> "" Then
            If KeyExists(idx, num) Then
                r = idx(num)
                sh.Cells(r, cRe).Value = NumV(sh.Cells(r, cRe).Value) + NumV(G_J(k, CJ_DEP))
            End If
        End If
    Next k
    For r = FIRSTROW To LastRow(sh, 1)
        If CStr(sh.Cells(r, cSt).Value) = "Validée" Then
            sr = SeanceRow(CStr(sh.Cells(r, cSe).Value))
            If sr > 0 Then
                If UCase$(CStr(ss.Cells(sr, ColOf(ss, "Pointée")).Value)) = "OUI" Then sh.Cells(r, cSt).Value = "Réalisée"
            End If
        End If
    Next r
    EndWork
End Sub

' ------------------------------------------------------------ programme annuel
Public Sub CalculerProgrammeAnnuel()
    Dim exo As String
    If Not RequireLogin() Then Exit Sub
    exo = Trim$(CStr(WS(SH_PROGAN).Range("C5").Value))
    If exo = "" Then
        exo = ExerciceDe(Date)
        WS(SH_PROGAN).Range("C5").Value = exo
    End If
    ProgrammeAnnuelInterne exo
    WS(SH_PROGAN).Activate
End Sub

Public Function ProgrammeAnnuelInterne(ByVal exo As String) As Long
    Dim sh As Worksheet, ps As Worksheet, v As Variant, n As Long, i As Long, j As Long, nb As Long, tmp As Variant
    Dim ord() As Long, dts() As Double, row As Long, d1 As Date, d2 As Date, tot As Double, mois As String, prev As String
    Set sh = WS(SH_PLAN)
    Set ps = WS(SH_PROGAN)
    BeginWork
    ps.Range(ps.Cells(OUT_FIRST, 1), ps.Cells(OUT_FIRST + 400, 8)).ClearContents
    ps.Range(ps.Cells(OUT_FIRST, 1), ps.Cells(OUT_FIRST + 400, 8)).Font.Bold = False
    ps.Range("B6").Value = ParamStr("NOM_GROUPE") & " - programme des activités de l'exercice " & exo
    n = ReadBlock(sh, 1, v)
    ReDim ord(1 To n + 1): ReDim dts(1 To n + 1)
    For i = 1 To n
        If CStr(v(i, PC("Exercice"))) = exo And CStr(v(i, 1)) <> "" And CStr(v(i, PC("Statut"))) <> "Annulée" Then
            nb = nb + 1
            ord(nb) = i
            dts(nb) = CDbl(AsDate(v(i, PC("Début"))))
        End If
    Next i
    For i = 2 To nb   ' tri par date (insertion)
        j = i
        Do While j > 1
            If dts(j - 1) <= dts(j) Then Exit Do
            tmp = dts(j): dts(j) = dts(j - 1): dts(j - 1) = tmp
            tmp = ord(j): ord(j) = ord(j - 1): ord(j - 1) = tmp
            j = j - 1
        Loop
    Next i
    row = OUT_FIRST
    For j = 1 To nb
        i = ord(j)
        d1 = AsDate(v(i, PC("Début")))
        d2 = AsDate(v(i, PC("Fin")))
        mois = UCase$(Left$(MoisLong(Month(d1)), 1)) & Mid$(MoisLong(Month(d1)), 2) & " " & Year(d1)
        If mois <> prev Then ps.Cells(row, 1).Value = mois
        prev = mois
        If d2 > d1 Then
            ps.Cells(row, 2).Value = JourLong(d1) & " " & Format$(d1, "dd/mm") & " au " & Format$(d2, "dd/mm")
        Else
            ps.Cells(row, 2).Value = JourLong(d1) & " " & Format$(d1, "dd/mm/yyyy")
        End If
        ps.Cells(row, 3).Value = v(i, PC("Activité"))
        ps.Cells(row, 4).Value = v(i, PC("Type"))
        ps.Cells(row, 5).Value = v(i, PC("Lieu"))
        ps.Cells(row, 6).Value = v(i, PC("Commission responsable"))
        ps.Cells(row, 7).Value = NumV(v(i, PC("Budget prévu (FCFA)")))
        ps.Cells(row, 8).Value = v(i, PC("Statut"))
        tot = tot + NumV(v(i, PC("Budget prévu (FCFA)")))
        row = row + 1
    Next j
    ps.Cells(row, 3).Value = "TOTAL (" & nb & " activité(s))"
    ps.Cells(row, 7).Value = tot
    ps.Range(ps.Cells(row, 1), ps.Cells(row, 8)).Font.Bold = True
    ps.Range(ps.Cells(OUT_FIRST, 7), ps.Cells(row, 7)).NumberFormat = "#,##0"
    EndWork
    ProgrammeAnnuelInterne = nb
End Function

' ------------------------------------------------------------ alertes
Public Sub AlertesPlanning(ByVal lignes As Collection)
    Dim sh As Worksheet, v As Variant, n As Long, i As Long, d As Date, st As String, jours As Long
    Dim nProche As Long, nHors As Long, txt As String, cD As Long, cS As Long, cH As Long, cV As Long, cA As Long
    Set sh = WS(SH_PLAN)
    jours = ParamNum("JOURS_ALERTE_PLANNING", 30)
    cD = PC("Début"): cS = PC("Statut"): cH = PC("Hors paroisse"): cV = PC("Validation paroissiale"): cA = PC("Activité")
    n = ReadBlock(sh, 1, v)
    For i = 1 To n
        d = AsDate(v(i, cD))
        st = CStr(v(i, cS))
        If d >= Date And d <= Date + jours And (st = "Projet" Or st = "Votée en AG") Then
            nProche = nProche + 1
            If nProche <= 3 Then txt = txt & IIf(txt = "", "", ", ") & CStr(v(i, cA)) & " (" & Format$(d, "dd/mm") & ")"
            If UCase$(CStr(v(i, cH))) = "OUI" And CStr(v(i, cV)) <> "Obtenue" Then nHors = nHors + 1
        End If
    Next i
    If nProche > 0 Then lignes.Add "Planning : " & nProche & " activité(s) dans les " & jours & " jours ne sont pas encore validées : " & txt & IIf(nProche > 3, "...", "") & "."
    If nHors > 0 Then lignes.Add "Planning : " & nHors & " sortie(s) hors paroisse proche(s) sans validation paroissiale obtenue (art. 6)."
End Sub
