Option Explicit
' =============================================================================
' modMembres : fiches des membres (matricule automatique, statuts)
' =============================================================================

Public Function NextMatricule() As String
    Dim sh As Worksheet, c As Long, r As Long, v As String, n As Long, mx As Long, p As Long
    Set sh = WS(SH_MEMBRES)
    c = ColOf(sh, "Matricule")
    For r = FIRSTROW To LastRow(sh, c)
        v = CStr(sh.Cells(r, c).Value)
        p = InStrRev(v, "-")
        If p > 0 Then
            If IsNumeric(Mid$(v, p + 1)) Then
                n = CLng(Mid$(v, p + 1))
                If n > mx Then mx = n
            End If
        End If
    Next r
    NextMatricule = SigleGroupe() & "-" & Format$(mx + 1, "0000")
End Function

Public Function MembreRow(ByVal matricule As String) As Long
    Dim sh As Worksheet, c As Long, r As Long
    If matricule = "" Then Exit Function
    Set sh = WS(SH_MEMBRES)
    c = ColOf(sh, "Matricule")
    For r = FIRSTROW To LastRow(sh, c)
        If StrComp(CStr(sh.Cells(r, c).Value), matricule, vbTextCompare) = 0 Then
            MembreRow = r
            Exit Function
        End If
    Next r
End Function

Public Function MembreValeur(ByVal matricule As String, ByVal entete As String) As Variant
    Dim r As Long, sh As Worksheet
    r = MembreRow(matricule)
    If r = 0 Then
        MembreValeur = Empty
    Else
        Set sh = WS(SH_MEMBRES)
        MembreValeur = sh.Cells(r, ColOf(sh, entete)).Value
    End If
End Function

Private Function FirstFreeRow(ByVal sh As Worksheet) As Long
    Dim r1 As Long, r2 As Long, r3 As Long
    r1 = LastRow(sh, ColOf(sh, "Matricule"))
    r2 = LastRow(sh, ColOf(sh, "Nom"))
    r3 = LastRow(sh, ColOf(sh, "Prénoms"))
    FirstFreeRow = Application.WorksheetFunction.Max(r1, r2, r3) + 1
End Function

Public Sub NouveauMembre()
    Dim sh As Worksheet, r As Long, mat As String
    If Not RequireEdit(SH_MEMBRES) Then Exit Sub
    On Error GoTo EH
    Set sh = WS(SH_MEMBRES)
    BeginWork
    r = FirstFreeRow(sh)
    mat = NextMatricule()
    sh.Cells(r, ColOf(sh, "Matricule")).Value = mat
    sh.Cells(r, ColOf(sh, "Statut")).Value = ST_OBS
    sh.Cells(r, ColOf(sh, "Date d'arrivée")).Value = Date
    sh.Cells(r, ColOf(sh, "Date du statut")).Value = Date
    EnsureDossier mat
    EndWork
    LogAction "Nouveau membre", mat, SH_MEMBRES
    sh.Activate
    sh.Cells(r, ColOf(sh, "Nom")).Select
    MsgBox "Matricule " & mat & " créé (statut « " & ST_OBS & " »)." & vbCrLf & _
           "Complétez la fiche sur cette ligne. Un dossier d'adhésion a été ouvert.", vbInformation, APP_NAME
    Exit Sub
EH:
    ShowError "Nouveau membre"
End Sub

' Appelee par l'evenement Change de la feuille MEMBRES
Public Sub OnMembresChange(ByVal Target As Range)
    Dim sh As Worksheet, cMat As Long, cNom As Long, cPre As Long, cSt As Long, cDs As Long, cArr As Long
    Dim rw As Range, r As Long, n As Long, mat As String
    On Error GoTo Fin
    Set sh = Target.Worksheet
    If Target.Row + Target.Rows.Count - 1 < FIRSTROW Then Exit Sub
    cMat = ColOf(sh, "Matricule")
    cNom = ColOf(sh, "Nom")
    cPre = ColOf(sh, "Prénoms")
    cSt = ColOf(sh, "Statut")
    cDs = ColOf(sh, "Date du statut")
    cArr = ColOf(sh, "Date d'arrivée")
    Application.EnableEvents = False
    For Each rw In Target.Rows
        r = rw.Row
        n = n + 1
        If n > 1000 Then Exit For
        If r >= FIRSTROW Then
            If CStr(sh.Cells(r, cMat).Value) = "" And (CStr(sh.Cells(r, cNom).Value) <> "" Or CStr(sh.Cells(r, cPre).Value) <> "") Then
                mat = NextMatricule()
                sh.Cells(r, cMat).Value = mat
                If CStr(sh.Cells(r, cSt).Value) = "" Then sh.Cells(r, cSt).Value = ST_OBS
                If Not HasDate(sh.Cells(r, cArr).Value) Then sh.Cells(r, cArr).Value = Date
                If Not HasDate(sh.Cells(r, cDs).Value) Then sh.Cells(r, cDs).Value = Date
                If CStr(sh.Cells(r, cSt).Value) = ST_OBS Then EnsureDossier mat
            End If
            If Not Intersect(rw, sh.Columns(cSt)) Is Nothing Then
                If CStr(sh.Cells(r, cSt).Value) <> "" Then
                    sh.Cells(r, cDs).Value = Date
                    If CStr(sh.Cells(r, cSt).Value) = ST_OBS And CStr(sh.Cells(r, cMat).Value) <> "" Then EnsureDossier CStr(sh.Cells(r, cMat).Value)
                End If
            End If
        End If
    Next rw
Fin:
    Application.EnableEvents = True
End Sub

Public Sub RechercherMembre()
    Dim txt As String, sh As Worksheet, r As Long, lr As Long, cNom As Long, cPre As Long, cMat As Long, startRow As Long, k As Long
    If Not RequireLogin() Then Exit Sub
    txt = Trim$(InputBox("Nom, prénom ou matricule à rechercher :", APP_NAME))
    If txt = "" Then Exit Sub
    Set sh = WS(SH_MEMBRES)
    cNom = ColOf(sh, "Nom"): cPre = ColOf(sh, "Prénoms"): cMat = ColOf(sh, "Matricule")
    lr = LastRow(sh, cMat)
    startRow = FIRSTROW
    If ActiveSheet.Name = SH_MEMBRES Then
        If ActiveCell.Row >= FIRSTROW Then startRow = ActiveCell.Row + 1
    End If
    For k = 0 To lr - FIRSTROW
        r = startRow + k
        If r > lr Then r = r - (lr - FIRSTROW + 1)
        If InStr(1, sh.Cells(r, cNom).Value & " " & sh.Cells(r, cPre).Value & " " & sh.Cells(r, cMat).Value, txt, vbTextCompare) > 0 Then
            sh.Activate
            sh.Cells(r, cNom).Select
            Exit Sub
        End If
    Next k
    MsgBox "Aucun membre ne correspond à « " & txt & " ».", vbInformation, APP_NAME
End Sub

Public Sub OuvrirDossierMembre()
    Dim sh As Worksheet, mat As String, r As Long
    If Not RequireLogin() Then Exit Sub
    Set sh = WS(SH_MEMBRES)
    If ActiveSheet.Name <> SH_MEMBRES Or ActiveCell.Row < FIRSTROW Then
        MsgBox "Sélectionnez d'abord une ligne de membre.", vbInformation, APP_NAME
        Exit Sub
    End If
    mat = CStr(sh.Cells(ActiveCell.Row, ColOf(sh, "Matricule")).Value)
    If mat = "" Then Exit Sub
    r = DossierRow(mat)
    If r = 0 Then
        If Not CanEdit(SH_ADH) Then
            MsgBox "Aucun dossier d'adhésion pour ce membre.", vbInformation, APP_NAME
            Exit Sub
        End If
        If MsgBox("Aucun dossier d'adhésion pour " & mat & ". En ouvrir un ?", vbYesNo + vbQuestion, APP_NAME) = vbNo Then Exit Sub
        BeginWork
        r = EnsureDossier(mat)
        EndWork
    End If
    WS(SH_ADH).Activate
    WS(SH_ADH).Cells(r, 1).Select
End Sub
