Option Explicit
' =============================================================================
' modApp : ouverture, enregistrement, fermeture, sauvegardes
' =============================================================================

Private m_WasLogged As Boolean
Private m_ActiveSheet As String

Public Sub AppOpen()
    Dim sh As Worksheet
    BeginWork
    G_Role = ""
    ProtectWorkbook False
    If ParamStr("UI_VERSION") <> APP_VERSION Then BuildAllUI
    RefreshChecklistHeaders
    For Each sh In ThisWorkbook.Worksheets
        ProtectSheet sh, ""
    Next sh
    HideAll
    BuildHome
    WS(SH_ACCUEIL).Activate
    WS(SH_ACCUEIL).Range("D7").Select
    EndWork
    ThisWorkbook.Saved = True
    If ParamOui("PREMIERE_OUVERTURE", False) Then
        MsgBox "Bienvenue dans " & APP_NAME & " !" & vbCrLf & vbCrLf & _
            "1. Choisissez le rôle « Administrateur » dans la case jaune." & vbCrLf & _
            "2. Cliquez sur « Se connecter ». Mot de passe provisoire : chorale" & vbCrLf & _
            "3. Choisissez votre mot de passe personnel." & vbCrLf & vbCrLf & _
            "Chaque rôle du Bureau a le même mot de passe provisoire (chorale)," & vbCrLf & _
            "à changer à la première connexion.", vbInformation, APP_NAME
    End If
End Sub

Public Sub AppBeforeClose(ByRef Cancel As Boolean)
    Dim wasSaved As Boolean, last As Date, jours As Long
    If IsLogged() Then
        last = AsDate(GetParam("DERNIERE_SAUVEGARDE", 0))
        jours = ParamNum("RAPPEL_SAUVEGARDE_JOURS", 7)
        If jours > 0 And (last = 0 Or Date - last >= jours) Then
            If MsgBox("Aucune copie de sauvegarde depuis " & IIf(last = 0, "la mise en service", Format$(last, "dd/mm/yyyy")) & "." & vbCrLf & _
                      "Voulez-vous en faire une maintenant ?", vbYesNo + vbQuestion, APP_NAME) = vbYes Then Sauvegarder
        End If
        LogAction "Fermeture", "", SH_ACCUEIL
    End If
    wasSaved = ThisWorkbook.Saved
    G_Role = "": G_RoleLabel = "": G_Holder = "": G_Interim = ""
    BeginWork
    HideAll
    BuildHome
    EndWork
    If wasSaved Then ThisWorkbook.Saved = True
End Sub

Public Sub AppBeforeSave()
    m_WasLogged = IsLogged()
    m_ActiveSheet = ActiveSheet.Name
    BeginWork
    HideAll
End Sub

Public Sub AppAfterSave()
    If m_WasLogged Then
        ApplyRights
        On Error Resume Next
        WS(m_ActiveSheet).Activate
        On Error GoTo 0
    End If
    EndWork
    ThisWorkbook.Saved = True
End Sub

Public Sub Sauvegarder()
    Dim dossier As String, baseTxt As String, fichier As String, wasSaved As Boolean
    If Not RequireLogin() Then Exit Sub
    On Error GoTo EH
    dossier = Trim$(ParamStr("DOSSIER_SAUVEGARDE"))
    If dossier = "" Then dossier = ThisWorkbook.Path & Application.PathSeparator & "Sauvegardes"
    If Dir$(dossier, vbDirectory) = "" Then MkDir dossier
    baseTxt = ThisWorkbook.Name
    If InStrRev(baseTxt, ".") > 0 Then baseTxt = Left$(baseTxt, InStrRev(baseTxt, ".") - 1)
    fichier = dossier & Application.PathSeparator & baseTxt & "_" & Format$(Now, "yyyy-mm-dd_hhnn") & ".xlsm"
    wasSaved = ThisWorkbook.Saved
    m_ActiveSheet = ActiveSheet.Name
    BeginWork
    SetParam "DERNIERE_SAUVEGARDE", Now
    HideAll
    ThisWorkbook.SaveCopyAs fichier
    ApplyRights
    WS(m_ActiveSheet).Activate
    EndWork
    LogAction "Sauvegarde", fichier, SH_ACCUEIL
    MsgBox "Copie de sauvegarde enregistrée :" & vbCrLf & fichier, vbInformation, APP_NAME
    Exit Sub
EH:
    ShowError "Sauvegarde"
    ApplyRights
End Sub

' =============================================================================
' Reprise des donnees d'une version precedente du fichier (nouveau lot livre)
' =============================================================================
Public Sub ReprendreAncienFichier()
    Dim f As Variant, rapport As String
    If Not RequireLogin() Then Exit Sub
    If Not IsAdmin() Then
        MsgBox "Seul l'administrateur peut reprendre les données d'un ancien fichier.", vbExclamation, APP_NAME
        Exit Sub
    End If
    If MsgBox("Cette opération remplace les données de ce fichier (membres, présences, séances, caisse, paramètres, " & _
              "mots de passe...) par celles d'un ancien fichier." & vbCrLf & vbCrLf & _
              "À faire une seule fois, sur le nouveau fichier livré. Continuer ?", vbYesNo + vbExclamation, APP_NAME) <> vbYes Then Exit Sub
    f = Application.GetOpenFilename("Classeurs Excel (*.xlsm),*.xlsm", , "Choisir l'ancien fichier")
    If VarType(f) = vbBoolean Then Exit Sub
    If StrComp(CStr(f), ThisWorkbook.FullName, vbTextCompare) = 0 Then
        MsgBox "Choisissez un autre fichier que celui-ci.", vbExclamation, APP_NAME
        Exit Sub
    End If
    rapport = ReprendreDonneesDe(CStr(f))
    MsgBox rapport, vbInformation, APP_NAME
End Sub

Public Function ReprendreDonneesDe(ByVal chemin As String) As String
    Dim src As Workbook, feuilles As Variant, i As Long, nom As String, rapport As String, n As Long
    On Error GoTo EH
    BeginWork
    Application.EnableEvents = False
    Set src = Workbooks.Open(Filename:=chemin, ReadOnly:=True, UpdateLinks:=False)
    feuilles = Array(SH_MEMBRES, SH_ADH, SH_SEANCES, SH_PRES, SH_PAT, SH_JOURNAL, SH_LISTES, SH_TYPES, SH_CODES, SH_CTRL, _
                     SH_CAISSE, SH_BUDGET, SH_CAMPAGNES, SH_SOCIAL, SH_ARRETES, SH_PERTES, SH_CLOTURES, SH_RUBRIQUES, SH_BAREME)
    For i = LBound(feuilles) To UBound(feuilles)
        nom = CStr(feuilles(i))
        If FeuilleExiste(src, nom) Then
            n = CopierTable(src.Worksheets(nom), WS(nom), (nom = SH_LISTES Or nom = SH_TYPES Or nom = SH_CODES Or nom = SH_CTRL Or nom = SH_RUBRIQUES Or nom = SH_BAREME))
            rapport = rapport & vbCrLf & "  " & nom & " : " & n & " ligne(s)"
        End If
    Next i
    If FeuilleExiste(src, SH_PARAM) Then rapport = rapport & vbCrLf & "  PARAMETRES : " & CopierParametres(src.Worksheets(SH_PARAM)) & " valeur(s)"
    If FeuilleExiste(src, SH_USERS) And FeuilleExiste(src, SH_SEC) Then
        CopierUtilisateurs src.Worksheets(SH_USERS), src.Worksheets(SH_SEC)
        rapport = rapport & vbCrLf & "  Utilisateurs et mots de passe repris"
    End If
    CopierLogo src.Worksheets(SH_ACCUEIL)
    src.Close SaveChanges:=False
    Set src = Nothing
    SetParam "PREMIERE_OUVERTURE", "NON"
    RefreshChecklistHeaders
    ApplyThemeColors
    EndWork
    LogAction "Reprise d'un ancien fichier", chemin, SH_PARAM
    ReprendreDonneesDe = "Données reprises de :" & vbCrLf & chemin & vbCrLf & rapport & vbCrLf & vbCrLf & _
                         "Enregistrez ce fichier, puis reconnectez-vous."
    Exit Function
EH:
    ReprendreDonneesDe = "Reprise interrompue : " & Err.Description
    On Error Resume Next
    If Not src Is Nothing Then src.Close SaveChanges:=False
    EndWork
End Function

Private Function FeuilleExiste(ByVal wb As Workbook, ByVal nom As String) As Boolean
    Dim sh As Worksheet
    On Error Resume Next
    Set sh = wb.Worksheets(nom)
    FeuilleExiste = Not sh Is Nothing
End Function

' Copie colonne par colonne (en-tetes identiques). Les colonnes absentes de l'ancien
' fichier restent vides ; pour les tables de parametrage elles gardent leurs valeurs.
Private Function CopierTable(ByVal s As Worksheet, ByVal t As Worksheet, ByVal garderAbsentes As Boolean) As Long
    Dim lcS As Long, lcT As Long, cs As Long, ct As Long, h As String, lrS As Long, lrT As Long, v As Variant, c As Long
    lcS = LastColWb(s)
    lcT = LastCol(t)
    lrS = FIRSTROW - 1
    For c = 1 To lcS
        If LastRowWb(s, c) > lrS Then lrS = LastRowWb(s, c)
    Next c
    lrT = FIRSTROW - 1
    For c = 1 To lcT
        If LastRow(t, c, FIRSTROW - 1) > lrT Then lrT = LastRow(t, c, FIRSTROW - 1)
    Next c
    For ct = 1 To lcT
        h = Trim$(CStr(t.Cells(HDR, ct).Value))
        cs = 0
        If h <> "" Then
            For c = 1 To lcS
                If StrComp(Trim$(CStr(s.Cells(HDR, c).Value)), h, vbTextCompare) = 0 Then cs = c: Exit For
            Next c
        End If
        If cs > 0 Then
            If lrT >= FIRSTROW Then t.Range(t.Cells(FIRSTROW, ct), t.Cells(lrT, ct)).ClearContents
            If lrS >= FIRSTROW Then
                If t.Cells(FIRSTROW, ct).HasFormula And garderAbsentes Then
                    ' colonne calculee (ex. Choix des rubriques) : on garde la formule
                Else
                    v = s.Range(s.Cells(FIRSTROW, cs), s.Cells(lrS, cs)).Value
                    t.Range(t.Cells(FIRSTROW, ct), t.Cells(lrS, ct)).Value = v
                End If
            End If
        ElseIf Not garderAbsentes And lrT >= FIRSTROW And h <> "" Then
            t.Range(t.Cells(FIRSTROW, ct), t.Cells(lrT, ct)).ClearContents
        End If
    Next ct
    If lrS >= FIRSTROW Then CopierTable = lrS - FIRSTROW + 1
End Function

Private Function LastRowWb(ByVal sh As Worksheet, ByVal col As Long) As Long
    Dim r As Long
    r = sh.UsedRange.Row + sh.UsedRange.Rows.Count - 1
    Do While r > HDR
        If CStr(sh.Cells(r, col).Value) <> "" Then Exit Do
        r = r - 1
    Loop
    LastRowWb = r
End Function

Private Function LastColWb(ByVal sh As Worksheet) As Long
    Dim c As Long
    c = sh.UsedRange.Column + sh.UsedRange.Columns.Count - 1
    Do While c > 1
        If CStr(sh.Cells(HDR, c).Value) <> "" Then Exit Do
        c = c - 1
    Loop
    LastColWb = c
End Function

Private Function CopierParametres(ByVal s As Worksheet) As Long
    Dim r As Long, cle As String
    For r = FIRSTROW To LastRowWb(s, 1)
        cle = Trim$(CStr(s.Cells(r, 1).Value))
        If cle <> "" And cle <> "UI_VERSION" And cle <> "PREMIERE_OUVERTURE" Then
            If CStr(s.Cells(r, 2).Value) <> "" Then
                SetParam cle, s.Cells(r, 2).Value
                CopierParametres = CopierParametres + 1
            End If
        End If
    Next r
End Function

Private Sub CopierUtilisateurs(ByVal su As Worksheet, ByVal ss As Worksheet)
    Dim tu As Worksheet, tsec As Worksheet, r As Long, k As Long, code As String, c As Long, h As String, cs As Long
    Set tu = WS(SH_USERS)
    Set tsec = WS(SH_SEC)
    For r = FIRSTROW To LastRowWb(su, 1)
        code = CStr(su.Cells(r, 1).Value)
        For k = FIRSTROW To LastRow(tu, 1)
            If CStr(tu.Cells(k, 1).Value) = code And code <> "" Then
                For c = 3 To LastCol(tu)
                    h = CStr(tu.Cells(HDR, c).Value)
                    For cs = 1 To LastColWb(su)
                        If CStr(su.Cells(HDR, cs).Value) = h Then tu.Cells(k, c).Value = su.Cells(r, cs).Value: Exit For
                    Next cs
                Next c
            End If
        Next k
    Next r
    For r = FIRSTROW To LastRowWb(ss, 1)
        code = CStr(ss.Cells(r, 1).Value)
        For k = FIRSTROW To LastRow(tsec, 1)
            If CStr(tsec.Cells(k, 1).Value) = code And code <> "" Then
                tsec.Cells(k, 2).Value = ss.Cells(r, 2).Value
                tsec.Cells(k, 3).Value = ss.Cells(r, 3).Value
            End If
        Next k
    Next r
End Sub

Private Sub CopierLogo(ByVal s As Worksheet)
    Dim shp As Shape, t As Worksheet, i As Long
    On Error GoTo Fin
    If G_TestMode Then Exit Sub
    For Each shp In s.Shapes
        If shp.Name = "logo" Then
            Set t = WS(SH_ACCUEIL)
            t.Unprotect SYS_PWD
            For i = t.Shapes.Count To 1 Step -1
                If t.Shapes(i).Name = "logo" Then t.Shapes(i).Delete
            Next i
            shp.Copy
            t.Paste Destination:=t.Range("J2")
            t.Shapes(t.Shapes.Count).Name = "logo"
            Exit For
        End If
    Next shp
Fin:
End Sub
