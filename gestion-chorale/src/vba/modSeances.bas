Option Explicit
' =============================================================================
' modSeances : calendrier des seances (repetitions, cultes, sorties, ...)
' Identifiant d'une seance : S + date (aaaammjj) + "-" + code du type
' =============================================================================

Public Function TypeRow(ByVal code As String) As Long
    Dim sh As Worksheet, r As Long
    Set sh = WS(SH_TYPES)
    For r = FIRSTROW To LastRow(sh, 1)
        If StrComp(CStr(sh.Cells(r, 1).Value), code, vbTextCompare) = 0 Then
            TypeRow = r
            Exit Function
        End If
    Next r
End Function

Public Function TypeValeur(ByVal code As String, ByVal entete As String) As Variant
    Dim r As Long, sh As Worksheet
    r = TypeRow(code)
    If r = 0 Then
        TypeValeur = Empty
    Else
        Set sh = WS(SH_TYPES)
        TypeValeur = sh.Cells(r, ColOf(sh, entete)).Value
    End If
End Function

Public Function SeanceRow(ByVal id As String) As Long
    Dim sh As Worksheet, r As Long
    If id = "" Then Exit Function
    Set sh = WS(SH_SEANCES)
    For r = FIRSTROW To LastRow(sh, 1)
        If StrComp(CStr(sh.Cells(r, 1).Value), id, vbTextCompare) = 0 Then
            SeanceRow = r
            Exit Function
        End If
    Next r
End Function

Private Function NewSeanceId(ByVal d As Date, ByVal code As String) As String
    Dim baseTxt As String, k As Long
    baseTxt = "S" & Format$(d, "yyyymmdd") & "-" & UCase$(code)
    NewSeanceId = baseTxt
    k = 1
    Do While SeanceRow(NewSeanceId) > 0
        k = k + 1
        NewSeanceId = baseTxt & "-" & k
    Loop
End Function

' Remplit une ligne de seance (ID, jour, libelle, horaires par defaut)
Private Sub FillSeance(ByVal sh As Worksheet, ByVal r As Long, ByVal d As Date, ByVal code As String)
    If CStr(sh.Cells(r, 1).Value) = "" Then sh.Cells(r, 1).Value = NewSeanceId(d, code)
    sh.Cells(r, ColOf(sh, "Date")).Value = d
    sh.Cells(r, ColOf(sh, "Jour")).Value = JourLong(d)
    sh.Cells(r, ColOf(sh, "Type")).Value = UCase$(code)
    sh.Cells(r, ColOf(sh, "Libellé")).Value = TypeValeur(code, "Libellé")
    If CStr(sh.Cells(r, ColOf(sh, "Heure de début")).Value) = "" Then sh.Cells(r, ColOf(sh, "Heure de début")).Value = TypeValeur(code, "Heure de début")
    If CStr(sh.Cells(r, ColOf(sh, "Heure de fin")).Value) = "" Then sh.Cells(r, ColOf(sh, "Heure de fin")).Value = TypeValeur(code, "Heure de fin")
    If CStr(sh.Cells(r, ColOf(sh, "Statut")).Value) = "" Then sh.Cells(r, ColOf(sh, "Statut")).Value = "Prévue"
    If CStr(sh.Cells(r, ColOf(sh, "Pointée")).Value) = "" Then sh.Cells(r, ColOf(sh, "Pointée")).Value = "NON"
End Sub

Public Sub TrierSeances()
    Dim sh As Worksheet, lr As Long, lc As Long
    Set sh = WS(SH_SEANCES)
    lr = LastRow(sh, 1)
    If lr <= FIRSTROW Then Exit Sub
    lc = LastCol(sh)
    sh.Range(sh.Cells(FIRSTROW, 1), sh.Cells(lr, lc)).Sort _
        Key1:=sh.Cells(FIRSTROW, ColOf(sh, "Date")), Order1:=xlAscending, _
        Key2:=sh.Cells(FIRSTROW, ColOf(sh, "Heure de début")), Order2:=xlAscending, Header:=xlNo
End Sub

Public Sub GenererCalendrier()
    Dim rep As String, an As Long, nb As Long
    If Not RequireEdit(SH_SEANCES) Then Exit Sub
    rep = InputBox("Générer les séances régulières de quelle année ?" & vbCrLf & _
                   "(seuls les types actifs ayant des jours définis dans TYPES_ACTIVITE sont générés ;" & vbCrLf & _
                   "les séances déjà présentes ne sont pas dupliquées)", APP_NAME, CStr(Year(Date)))
    If rep = "" Then Exit Sub
    If Not IsNumeric(rep) Then Exit Sub
    an = CLng(rep)
    If an < 2000 Or an > 2100 Then Exit Sub
    nb = GenererCalendrierAnnee(an)
    If nb >= 0 Then MsgBox nb & " séance(s) ajoutée(s) au calendrier " & an & ".", vbInformation, APP_NAME
End Sub

Public Function GenererCalendrierAnnee(ByVal an As Long) As Long
    Dim d As Date, d1 As Date, d2 As Date, sh As Worksheet, ts As Worksheet, v As Variant, nb0 As Long
    Dim r As Long, t As Long, code As String, jours As String, nb As Long, lr As Long, lc As Long
    Dim existants As New Collection, k As String, dl As Long, out() As Variant
    Dim cD As Long, cJ As Long, cT As Long, cL As Long, cH1 As Long, cH2 As Long, cS As Long, cP As Long
    Dim libType As Variant, h1 As Variant, h2 As Variant
    On Error GoTo EH
    BeginWork
    Set sh = WS(SH_SEANCES)
    Set ts = WS(SH_TYPES)
    cD = ColOf(sh, "Date"): cJ = ColOf(sh, "Jour"): cT = ColOf(sh, "Type"): cL = ColOf(sh, "Libellé")
    cH1 = ColOf(sh, "Heure de début"): cH2 = ColOf(sh, "Heure de fin"): cS = ColOf(sh, "Statut"): cP = ColOf(sh, "Pointée")
    lc = LastCol(sh)
    nb0 = ReadBlock(sh, 1, v)
    For r = 1 To nb0
        k = Format$(AsDate(v(r, cD)), "yyyymmdd") & "|" & UCase$(CStr(v(r, cT)))
        If Not KeyExists(existants, k) Then existants.Add True, k
        k = "ID|" & UCase$(CStr(v(r, 1)))
        If Not KeyExists(existants, k) Then existants.Add True, k
    Next r
    d1 = DateSerial(an, 1, 1)
    d2 = DateSerial(an, 12, 31)
    ReDim out(1 To 800, 1 To lc)
    For t = FIRSTROW To LastRow(ts, 1)
        code = UCase$(Trim$(CStr(ts.Cells(t, 1).Value)))
        jours = UCase$(Replace(CStr(ts.Cells(t, ColOf(ts, "Jours")).Value), " ", ""))
        If code <> "" And jours <> "" And UCase$(CStr(ts.Cells(t, ColOf(ts, "Actif")).Value)) <> "NON" Then
            libType = ts.Cells(t, ColOf(ts, "Libellé")).Value
            h1 = ts.Cells(t, ColOf(ts, "Heure de début")).Value
            h2 = ts.Cells(t, ColOf(ts, "Heure de fin")).Value
            For dl = CLng(d1) To CLng(d2)
                d = CDate(dl)
                If InStr(1, ";" & jours & ";", ";" & JourCode(d) & ";") > 0 Then
                    k = Format$(d, "yyyymmdd") & "|" & code
                    If Not KeyExists(existants, k) And Not KeyExists(existants, "ID|S" & Format$(d, "yyyymmdd") & "-" & code) And nb < 800 Then
                        nb = nb + 1
                        out(nb, 1) = "S" & Format$(d, "yyyymmdd") & "-" & code
                        out(nb, cD) = d: out(nb, cJ) = JourLong(d): out(nb, cT) = code: out(nb, cL) = libType
                        out(nb, cH1) = h1: out(nb, cH2) = h2: out(nb, cS) = "Prévue": out(nb, cP) = "NON"
                        existants.Add True, k
                    End If
                End If
            Next dl
        End If
    Next t
    If nb > 0 Then
        lr = LastRow(sh, 1)
        sh.Range(sh.Cells(lr + 1, 1), sh.Cells(lr + 800, lc)).Value = out
        sh.Range(sh.Cells(lr + 1, cD), sh.Cells(lr + nb, cD)).NumberFormat = "dd/mm/yyyy"
        sh.Range(sh.Cells(lr + 1, cH1), sh.Cells(lr + nb, cH2)).NumberFormat = "hh:mm"
        TrierSeances
    End If
    EndWork
    LogAction "Calendrier généré", an & " : " & nb & " séance(s) ajoutée(s)", SH_SEANCES
    GenererCalendrierAnnee = nb
    Exit Function
EH:
    ShowError "Génération du calendrier"
    GenererCalendrierAnnee = -1
End Function

Public Function KeyExists(ByVal col As Collection, ByVal k As String) As Boolean
    Dim v As Variant
    On Error GoTo No
    v = col(k)
    KeyExists = True
    Exit Function
No:
    KeyExists = False
End Function

Public Sub AjouterSeance()
    Dim sd As String, d As Date, code As String, sh As Worksheet, r As Long, liste As String, ts As Worksheet, t As Long
    If Not RequireEdit(SH_SEANCES) Then Exit Sub
    sd = InputBox("Date de la séance (jj/mm/aaaa) :", APP_NAME, Format$(Date, "dd/mm/yyyy"))
    If sd = "" Then Exit Sub
    If Not IsDate(sd) Then
        MsgBox "Date invalide.", vbExclamation, APP_NAME
        Exit Sub
    End If
    d = CDate(sd)
    Set ts = WS(SH_TYPES)
    For t = FIRSTROW To LastRow(ts, 1)
        If CStr(ts.Cells(t, 1).Value) <> "" Then liste = liste & vbCrLf & "  " & ts.Cells(t, 1).Value & " : " & ts.Cells(t, 2).Value
    Next t
    code = UCase$(Trim$(InputBox("Code du type d'activité :" & liste, APP_NAME, "REP")))
    If code = "" Then Exit Sub
    If TypeRow(code) = 0 Then
        MsgBox "Type inconnu : " & code, vbExclamation, APP_NAME
        Exit Sub
    End If
    On Error GoTo EH
    BeginWork
    Set sh = WS(SH_SEANCES)
    r = LastRow(sh, 1) + 1
    FillSeance sh, r, d, code
    TrierSeances
    EndWork
    LogAction "Séance ajoutée", Format$(d, "dd/mm/yyyy") & " " & code, SH_SEANCES
    r = SeanceRow("S" & Format$(d, "yyyymmdd") & "-" & code)
    If r > 0 Then sh.Cells(r, 1).Select
    Exit Sub
EH:
    ShowError "Ajout de séance"
End Sub

Public Sub AnnulerSeance()
    Dim sh As Worksheet, r As Long, id As String
    If Not RequireEdit(SH_SEANCES) Then Exit Sub
    Set sh = WS(SH_SEANCES)
    If ActiveSheet.Name <> SH_SEANCES Or ActiveCell.Row < FIRSTROW Then
        MsgBox "Sélectionnez d'abord la ligne de la séance à annuler.", vbInformation, APP_NAME
        Exit Sub
    End If
    r = ActiveCell.Row
    id = CStr(sh.Cells(r, 1).Value)
    If id = "" Then Exit Sub
    If MsgBox("Annuler la séance " & id & " ?" & vbCrLf & "Elle ne comptera pour personne dans les taux.", vbYesNo + vbQuestion, APP_NAME) = vbNo Then Exit Sub
    BeginWork
    sh.Cells(r, ColOf(sh, "Statut")).Value = "Annulée"
    If UCase$(CStr(sh.Cells(r, ColOf(sh, "Pointée")).Value)) = "OUI" Then
        SupprimerPresencesSeance id
        sh.Cells(r, ColOf(sh, "Pointée")).Value = "NON"
        sh.Cells(r, ColOf(sh, "Présents")).Value = ""
        sh.Cells(r, ColOf(sh, "Taux de la séance")).Value = ""
    End If
    EndWork
    LogAction "Séance annulée", id, SH_SEANCES
End Sub

Public Sub PointerSeanceSelectionnee()
    Dim sh As Worksheet, id As String
    If Not RequireLogin() Then Exit Sub
    Set sh = WS(SH_SEANCES)
    If ActiveSheet.Name <> SH_SEANCES Or ActiveCell.Row < FIRSTROW Then
        MsgBox "Sélectionnez d'abord la ligne de la séance.", vbInformation, APP_NAME
        Exit Sub
    End If
    id = CStr(sh.Cells(ActiveCell.Row, 1).Value)
    If id = "" Then Exit Sub
    WS(SH_POINTAGE).Range("C5").Value = id
    WS(SH_POINTAGE).Activate
    ChargerPointage
End Sub

' Appelee par l'evenement Change de SEANCES : complete une ligne saisie a la main
Public Sub OnSeancesChange(ByVal Target As Range)
    Dim sh As Worksheet, rw As Range, r As Long, cD As Long, cT As Long, d As Date, code As String, n As Long
    On Error GoTo Fin
    Set sh = Target.Worksheet
    cD = ColOf(sh, "Date")
    cT = ColOf(sh, "Type")
    Application.EnableEvents = False
    For Each rw In Target.Rows
        n = n + 1
        If n > 500 Then Exit For
        r = rw.Row
        If r >= FIRSTROW Then
            d = AsDate(sh.Cells(r, cD).Value)
            code = UCase$(Trim$(CStr(sh.Cells(r, cT).Value)))
            If d > 0 And code <> "" And TypeRow(code) > 0 Then
                If CStr(sh.Cells(r, 1).Value) = "" Then
                    FillSeance sh, r, d, code
                Else
                    sh.Cells(r, ColOf(sh, "Jour")).Value = JourLong(d)
                    sh.Cells(r, ColOf(sh, "Libellé")).Value = TypeValeur(code, "Libellé")
                End If
            End If
        End If
    Next rw
Fin:
    Application.EnableEvents = True
End Sub
