Option Explicit
' =============================================================================
' modInterface : page d'accueil, boutons, navigation, theme, logo
' =============================================================================

Private Const BTN_H As Single = 28
Private Const BTN_GAP As Single = 8

' ------------------------------------------------------------- couleurs
Public Function HexToRGB(ByVal h As String, Optional ByVal defaut_ As Long = 0) As Long
    Dim defaut As Long: defaut = defaut_   ' copie locale (compatibilite LibreOffice)
    h = Replace(Trim$(h), "#", "")
    If Len(h) <> 6 Then
        HexToRGB = defaut
        Exit Function
    End If
    On Error GoTo Bad
    HexToRGB = RGB(CLng(Val("&H" & Mid$(h, 1, 2))), CLng(Val("&H" & Mid$(h, 3, 2))), CLng(Val("&H" & Mid$(h, 5, 2))))
    Exit Function
Bad:
    HexToRGB = defaut
End Function

Public Function RGBToHex(ByVal c As Long) As String
    RGBToHex = "#" & Right$("0" & Hex$(c And 255), 2) & Right$("0" & Hex$((c \ 256) And 255), 2) & Right$("0" & Hex$((c \ 65536) And 255), 2)
End Function

Public Function ColPrincipale() As Long
    ColPrincipale = HexToRGB(ParamStr("COULEUR_PRINCIPALE", "#1E7B4A"), RGB(30, 123, 74))
End Function

Public Function ColSecondaire() As Long
    ColSecondaire = HexToRGB(ParamStr("COULEUR_SECONDAIRE", "#E8F3EC"), RGB(232, 243, 236))
End Function

Public Function ColAccent() As Long
    ColAccent = HexToRGB(ParamStr("COULEUR_ACCENT", "#C8102E"), RGB(200, 16, 46))
End Function

' ------------------------------------------------------------- boutons
Private Sub DeleteButtons(ByVal sh As Worksheet)
    Dim i As Long
    For i = sh.Shapes.Count To 1 Step -1
        If Left$(sh.Shapes(i).Name, 4) = "btn_" Then sh.Shapes(i).Delete
    Next i
End Sub

Private Function AddButton(ByVal sh As Worksheet, ByVal nom As String, ByVal caption As String, ByVal macro As String, _
                           ByVal x As Single, ByVal y As Single, ByVal w As Single, ByVal fillColor As Long, _
                           Optional ByVal enabled_ As Boolean = True) As Shape
    Dim enabled As Boolean: enabled = enabled_   ' copie locale (compatibilite LibreOffice)
    Dim shp As Shape
    If G_TestMode Then Exit Function   ' LibreOffice ne sait pas creer de formes
    Set shp = sh.Shapes.AddShape(5, x, y, w, BTN_H)
    shp.Name = nom
    shp.Fill.ForeColor.RGB = IIf(enabled, fillColor, RGB(200, 200, 200))
    shp.Line.Visible = False
    shp.Shadow.Visible = False
    With shp.TextFrame
        .Characters.Text = caption
        .Characters.Font.Size = 10
        .Characters.Font.Bold = True
        .Characters.Font.Color = IIf(enabled, RGB(255, 255, 255), RGB(110, 110, 110))
        .HorizontalAlignment = xlHAlignCenter
        .VerticalAlignment = xlVAlignCenter
        .MarginLeft = 2
        .MarginRight = 2
    End With
    shp.Placement = xlFreeFloating
    If macro <> "" Then shp.OnAction = macro
    Set AddButton = shp
End Function

Private Function BtnWidth(ByVal caption As String) As Single
    BtnWidth = 24 + Len(caption) * 6.3
    If BtnWidth < 80 Then BtnWidth = 80
End Function

Private Function SheetButtons(ByVal nom As String) As Variant
    Select Case UCase$(nom)
        Case SH_MEMBRES
            SheetButtons = Array("Nouveau membre|NouveauMembre|P", "Rechercher|RechercherMembre|P", "Dossier d'adhésion|OuvrirDossierMembre|P")
        Case SH_ADH
            SheetButtons = Array("Actualiser les dossiers|ActualiserDossiers|P", "Appliquer les décisions|AppliquerDecisions|A")
        Case SH_SEANCES
            SheetButtons = Array("Générer le calendrier|GenererCalendrier|P", "Ajouter une séance|AjouterSeance|P", "Annuler la séance|AnnulerSeance|P", "Pointer cette séance|PointerSeanceSelectionnee|A")
        Case SH_POINTAGE
            SheetButtons = Array("Prochaine séance à pointer|ProchaineSeance|P", "Charger la séance|ChargerPointage|P", "Tous présents|TousPresents|P", "Valider le pointage|ValiderPointage|A")
        Case SH_TAUX
            SheetButtons = Array("Ce mois|TauxCeMois|P", "Mois précédent|TauxMoisPrecedent|P", "Ce trimestre|TauxCeTrimestre|P", "Cette année|TauxCetteAnnee|P", "Calculer|CalculerTaux|A", "Imprimer|ImprimerFeuille|P")
        Case SH_ELEC
            SheetButtons = Array("Générer la liste|GenererElecteurs|A", "Imprimer|ImprimerFeuille|P")
        Case SH_FICHE
            SheetButtons = Array("Générer la fiche|GenererFicheAppel|A", "Imprimer|ImprimerFeuille|P")
        Case SH_PARAM
            SheetButtons = Array("Thème et couleurs|ChoisirTheme|P", "Importer le logo|ImporterLogo|P")
        Case SH_USERS
            SheetButtons = Array("Réinitialiser un mot de passe|ReinitialiserMotDePasse|A")
        Case SH_CTRL
            SheetButtons = Array("Mettre à jour les dossiers|ActualiserDossiers|P")
        Case Else
            SheetButtons = Array()
    End Select
End Function

Public Sub BuildSheetButtons(ByVal sh As Worksheet)
    Dim specs As Variant, i As Long, parts() As String, x As Single, y As Single, w As Single, col As Long
    On Error Resume Next
    sh.Unprotect SYS_PWD
    On Error GoTo 0
    If G_TestMode Then Exit Sub   ' LibreOffice : pas de formes sur les feuilles masquees
    DeleteButtons sh
    If sh.Name = SH_ACCUEIL Then Exit Sub
    y = sh.Rows(2).Top + 3
    x = sh.Cells(2, 1).Left + 4
    AddButton sh, "btn_home", "Accueil", "AllerAccueil", x, y, 80, RGB(90, 90, 90)
    x = x + 80 + BTN_GAP
    specs = SheetButtons(sh.Name)
    For i = LBound(specs) To UBound(specs)
        parts = Split(specs(i), "|")
        w = BtnWidth(parts(0))
        col = IIf(parts(2) = "A", ColAccent(), ColPrincipale())
        AddButton sh, "btn_" & parts(1), parts(0), parts(1), x, y, w, col
        x = x + w + BTN_GAP
    Next i
End Sub

' Reconstruit les boutons de toutes les feuilles et applique le theme
Public Sub BuildAllUI()
    Dim sh As Worksheet
    For Each sh In ThisWorkbook.Worksheets
        If sh.Name <> SH_SEC And sh.Name <> SH_DROITS Then BuildSheetButtons sh
    Next sh
    ApplyThemeColors
    SetParam "UI_VERSION", APP_VERSION
End Sub

' ------------------------------------------------------------- accueil
Private Sub MenuItem(ByVal sh As Worksheet, ByVal caption As String, ByVal cible As String, ByRef idx As Long, _
                     ByVal x0 As Single, ByVal y0 As Single, Optional ByVal macro_ As String = "", Optional ByVal enabled_ As Boolean = True, Optional ByVal fill_ As Long = -1)
    Dim macro As String: macro = macro_   ' copie locale (compatibilite LibreOffice)
    Dim enabled As Boolean: enabled = enabled_   ' copie locale (compatibilite LibreOffice)
    Dim fill As Long: fill = fill_   ' copie locale (compatibilite LibreOffice)
    Dim x As Single, y As Single, w As Single, col As Long
    w = 165
    x = x0 + (idx Mod 4) * (w + BTN_GAP)
    y = y0 + (idx \ 4) * (BTN_H + BTN_GAP)
    If fill = -1 Then col = ColPrincipale() Else col = fill
    If macro = "" Then
        AddButton sh, "btn_nav_" & cible, caption, "GoSheet", x, y, w, col, enabled
    Else
        AddButton sh, "btn_act_" & macro, caption, IIf(enabled, macro, "BientotDisponible"), x, y, w, col, enabled
    End If
    idx = idx + 1
End Sub

Private Sub NavIfAllowed(ByVal sh As Worksheet, ByVal caption As String, ByVal cible As String, ByRef idx As Long, ByVal x0 As Single, ByVal y0 As Single)
    If RightOf(cible) <> "" Then MenuItem sh, caption, cible, idx, x0, y0
End Sub

Private Sub FutureIfAllowed(ByVal sh As Worksheet, ByVal caption As String, ByVal modu As String, ByRef idx As Long, ByVal x0 As Single, ByVal y0 As Single)
    If ModuleRight(modu) <> "" Then MenuItem sh, caption, modu, idx, x0, y0, "Futur_" & modu, False
End Sub

Public Sub BuildHome()
    Dim sh As Worksheet, idx As Long, x0 As Single, y0 As Single, nRows As Long, logo As Shape
    Set sh = WS(SH_ACCUEIL)
    On Error Resume Next
    sh.Unprotect SYS_PWD
    On Error GoTo 0
    DeleteButtons sh

    sh.Range("B2").Value = ParamStr("NOM_GROUPE", "Nom du groupe")
    sh.Range("B3").Value = ParamStr("EGLISE") & "  ·  " & ParamStr("CONSISTOIRE") & "  ·  " & ParamStr("PAROISSE")
    sh.Range("B4").Value = ParamStr("DEVISE")
    sh.Range("B7").Value = "Rôle :"
    sh.Range("B8").Value = "Session :"
    If IsLogged() Then
        sh.Range("D8").Value = G_RoleLabel & IIf(G_Holder <> "", " - " & G_Holder, "") & IIf(G_Interim <> "", "  (intérim : " & RoleLabel(G_Interim) & ")", "")
    Else
        sh.Range("D8").Value = "Non connecté"
    End If

    x0 = sh.Range("B10").Left
    y0 = sh.Range("B10").Top
    idx = 0
    If Not IsLogged() Then
        MenuItem sh, "Se connecter", "", idx, x0, y0, "Connexion", True, ColAccent()
        sh.Range("B10").Offset(3, 0).Value = "Choisissez votre rôle dans la case jaune, puis cliquez sur « Se connecter »."
        nRows = 1
    Else
        sh.Range("B10").Offset(3, 0).Value = ""
        NavIfAllowed sh, "Membres", SH_MEMBRES, idx, x0, y0
        NavIfAllowed sh, "Nouveaux choristes", SH_ADH, idx, x0, y0
        NavIfAllowed sh, "Calendrier des séances", SH_SEANCES, idx, x0, y0
        NavIfAllowed sh, "Pointage d'une séance", SH_POINTAGE, idx, x0, y0
        NavIfAllowed sh, "Historique des présences", SH_PRES, idx, x0, y0
        NavIfAllowed sh, "Taux de participation", SH_TAUX, idx, x0, y0
        NavIfAllowed sh, "Fiche d'appel", SH_FICHE, idx, x0, y0
        NavIfAllowed sh, "Liste électorale", SH_ELEC, idx, x0, y0
        NavIfAllowed sh, "Patrimoine", SH_PAT, idx, x0, y0
        FutureIfAllowed sh, "Finances (lot 2)", "FINANCES", idx, x0, y0
        FutureIfAllowed sh, "Caisse sociale (lot 2)", "SOCIAL", idx, x0, y0
        FutureIfAllowed sh, "Discipline (lot 4)", "DISCIPLINE", idx, x0, y0
        FutureIfAllowed sh, "Planning (lot 4)", "PLANNING", idx, x0, y0
        FutureIfAllowed sh, "Cantiques (lot 4)", "CANTIQUES", idx, x0, y0
        FutureIfAllowed sh, "Tableau de bord (lot 5)", "RAPPORTS", idx, x0, y0
        NavIfAllowed sh, "Paramètres", SH_PARAM, idx, x0, y0
        NavIfAllowed sh, "Listes de choix", SH_LISTES, idx, x0, y0
        NavIfAllowed sh, "Types d'activités", SH_TYPES, idx, x0, y0
        NavIfAllowed sh, "Codes de présence", SH_CODES, idx, x0, y0
        NavIfAllowed sh, "Contrôles d'adhésion", SH_CTRL, idx, x0, y0
        NavIfAllowed sh, "Utilisateurs", SH_USERS, idx, x0, y0
        NavIfAllowed sh, "Journal des actions", SH_JOURNAL, idx, x0, y0
        If idx Mod 4 <> 0 Then idx = idx + (4 - idx Mod 4)
        MenuItem sh, "Actualiser les alertes", "", idx, x0, y0, "RefreshAlerts", True, RGB(90, 90, 90)
        If CanEdit(SH_MEMBRES) Then MenuItem sh, "Marquer les refroidis", "", idx, x0, y0, "MarquerRefroidis", True, RGB(90, 90, 90)
        MenuItem sh, "Changer mon mot de passe", "", idx, x0, y0, "ChangerMonMotDePasse", True, RGB(90, 90, 90)
        MenuItem sh, "Sauvegarder une copie", "", idx, x0, y0, "Sauvegarder", True, RGB(90, 90, 90)
        MenuItem sh, "Se déconnecter", "", idx, x0, y0, "Deconnexion", True, ColAccent()
        nRows = (idx + 3) \ 4
    End If

    ' Les alertes commencent sous les boutons
    sh.Range("B" & AlertRow() & ":L" & AlertRow() + 60).ClearContents
    If Not IsLogged() Then sh.Range("B" & AlertRow() & ":L" & AlertRow() + 60).ClearFormats
    ApplyHomeColors
    ProtectSheet sh, "L"
End Sub

Public Function AlertRow() As Long
    AlertRow = 34
End Function

Public Sub GoSheet()
    Dim nom As String
    nom = Mid$(CStr(Application.Caller), 9)
    If Not RequireLogin() Then Exit Sub
    If RightOf(nom) = "" Then
        MsgBox "Accès non autorisé pour votre rôle.", vbExclamation, APP_NAME
        Exit Sub
    End If
    WS(nom).Activate
    ActiveWindow.ScrollRow = 1
End Sub

Public Sub AllerAccueil()
    WS(SH_ACCUEIL).Activate
End Sub

Public Sub BientotDisponible()
    MsgBox "Ce module sera livré dans un prochain lot du projet.", vbInformation, APP_NAME
End Sub

Public Sub ImprimerFeuille()
    On Error Resume Next
    ActiveSheet.PrintPreview
End Sub

' ------------------------------------------------------------- theme
Private Function HeaderRowOf(ByVal nom As String) As Long
    Select Case UCase$(nom)
        Case SH_POINTAGE, SH_TAUX, SH_ELEC, SH_FICHE: HeaderRowOf = OUT_HDR
        Case SH_ACCUEIL: HeaderRowOf = 0
        Case Else: HeaderRowOf = HDR
    End Select
End Function

Public Sub ApplyHomeColors()
    Dim sh As Worksheet
    Set sh = WS(SH_ACCUEIL)
    sh.Range("A1:M1").Interior.Color = ColPrincipale()
    sh.Range("B2").Font.Color = ColPrincipale()
    sh.Range("D7:F7").Interior.Color = RGB(255, 242, 153)
    sh.Range("B6:L6").Borders(xlEdgeBottom).Color = ColPrincipale()
    sh.Range("B" & AlertRow() - 1 & ":L" & AlertRow() - 1).Borders(xlEdgeBottom).Color = ColAccent()
    sh.Range("B" & AlertRow() - 1).Font.Color = ColAccent()
End Sub

Public Sub ApplyThemeColors()
    Dim sh As Worksheet, hr As Long, lc As Long, i As Long, shp As Shape
    For Each sh In ThisWorkbook.Worksheets
        If sh.Name <> SH_SEC And sh.Name <> SH_DROITS And sh.Name <> SH_ACCUEIL Then
            On Error Resume Next
            sh.Unprotect SYS_PWD
            On Error GoTo 0
            hr = HeaderRowOf(sh.Name)
            lc = LastCol(sh, hr)
            If lc < 8 Then lc = 8
            With sh.Range(sh.Cells(1, 1), sh.Cells(1, lc))
                .Interior.Color = ColPrincipale()
                .Font.Color = RGB(255, 255, 255)
            End With
            With sh.Range(sh.Cells(hr, 1), sh.Cells(hr, lc))
                .Interior.Color = ColPrincipale()
                .Font.Color = RGB(255, 255, 255)
                .Font.Bold = True
            End With
            Select Case UCase$(sh.Name)
                Case SH_POINTAGE, SH_FICHE: sh.Range("C5").Interior.Color = RGB(255, 242, 153)
                Case SH_TAUX
                    sh.Range("C5").Interior.Color = RGB(255, 242, 153)
                    sh.Range("E5").Interior.Color = RGB(255, 242, 153)
                    sh.Range("G5").Interior.Color = RGB(255, 242, 153)
            End Select
            On Error Resume Next   ' formes ajoutees par l'utilisateur : ignorees
            If Not G_TestMode Then
            For Each shp In sh.Shapes
                If Left$(shp.Name, 4) = "btn_" And shp.Name <> "btn_home" Then
                    If shp.Fill.ForeColor.RGB <> RGB(200, 200, 200) Then
                        If InStr(1, "|ValiderPointage|AppliquerDecisions|CalculerTaux|GenererElecteurs|GenererFicheAppel|PointerSeanceSelectionnee|ReinitialiserMotDePasse|", "|" & Mid$(shp.Name, 5) & "|") > 0 Then
                            shp.Fill.ForeColor.RGB = ColAccent()
                        Else
                            shp.Fill.ForeColor.RGB = ColPrincipale()
                        End If
                    End If
                End If
            Next shp
            End If
            Err.Clear
            On Error GoTo 0
        End If
    Next sh
    ApplyHomeColors
End Sub

Private Function PickColor(ByVal titre As String, ByVal actuelle As Long) As Long
    Dim ok As Boolean, old As Long
    PickColor = -1
    MsgBox "Choisissez la " & titre & " dans la fenêtre suivante.", vbInformation, APP_NAME
    old = ThisWorkbook.Colors(56)
    ok = Application.Dialogs(xlDialogEditColor).Show(56, actuelle And 255, (actuelle \ 256) And 255, (actuelle \ 65536) And 255)
    If ok Then PickColor = ThisWorkbook.Colors(56)
    ThisWorkbook.Colors(56) = old
End Function

Public Sub ChoisirTheme()
    Dim rep As String, p As Long, s As Long, a As Long
    If Not RequireEdit(SH_PARAM) Then Exit Sub
    rep = InputBox("Choisissez un thème (tapez le numéro) :" & vbCrLf & vbCrLf & _
        "  1 - Vert (logo ADC)" & vbCrLf & "  2 - Bleu" & vbCrLf & "  3 - Bordeaux" & vbCrLf & _
        "  4 - Violet" & vbCrLf & "  5 - Anthracite" & vbCrLf & "  6 - Personnalisé (choisir les 3 couleurs)", APP_NAME & " - Thème", "1")
    Select Case Trim$(rep)
        Case "1": SetTheme "Vert", "#1E7B4A", "#E8F3EC", "#C8102E"
        Case "2": SetTheme "Bleu", "#1F4E79", "#DEEAF6", "#C55A11"
        Case "3": SetTheme "Bordeaux", "#7B1E3A", "#F6E3E9", "#B8860B"
        Case "4": SetTheme "Violet", "#5B2C83", "#EEE6F5", "#2E8B57"
        Case "5": SetTheme "Anthracite", "#3A3A3A", "#EDEDED", "#D97706"
        Case "6"
            p = PickColor("couleur principale (bandeaux, boutons)", ColPrincipale())
            If p = -1 Then Exit Sub
            s = PickColor("couleur secondaire (fonds clairs)", ColSecondaire())
            If s = -1 Then Exit Sub
            a = PickColor("couleur d'accent (actions importantes, alertes)", ColAccent())
            If a = -1 Then Exit Sub
            SetTheme "Personnalisé", RGBToHex(p), RGBToHex(s), RGBToHex(a)
        Case Else
            Exit Sub
    End Select
End Sub

Private Sub SetTheme(ByVal nom As String, ByVal p As String, ByVal s As String, ByVal a As String)
    BeginWork
    SetParam "THEME", nom
    SetParam "COULEUR_PRINCIPALE", p
    SetParam "COULEUR_SECONDAIRE", s
    SetParam "COULEUR_ACCENT", a
    ApplyThemeColors
    ApplyRights
    BuildHome
    RefreshAlerts
    EndWork
    LogAction "Thème modifié", nom & " " & p & " " & s & " " & a, SH_PARAM
    MsgBox "Thème « " & nom & " » appliqué.", vbInformation, APP_NAME
End Sub

Public Sub ImporterLogo()
    Dim f As Variant, sh As Worksheet, shp As Shape, i As Long
    If Not RequireEdit(SH_PARAM) Then Exit Sub
    f = Application.GetOpenFilename("Images (*.png;*.jpg;*.jpeg;*.gif;*.bmp),*.png;*.jpg;*.jpeg;*.gif;*.bmp", , "Choisir le logo du groupe")
    If VarType(f) = vbBoolean Then Exit Sub
    Set sh = WS(SH_ACCUEIL)
    BeginWork
    On Error Resume Next
    sh.Unprotect SYS_PWD
    For i = sh.Shapes.Count To 1 Step -1
        If sh.Shapes(i).Name = "logo" Then sh.Shapes(i).Delete
    Next i
    On Error GoTo EH
    Set shp = sh.Shapes.AddPicture(CStr(f), False, True, sh.Range("J2").Left, sh.Range("J2").Top, -1, -1)
    shp.Name = "logo"
    shp.LockAspectRatio = True
    shp.Height = 80
    shp.Placement = xlMove
    ProtectSheet sh, "L"
    EndWork
    LogAction "Logo importé", CStr(f), SH_ACCUEIL
    If MsgBox("Logo importé. Voulez-vous maintenant choisir les couleurs du thème ?", vbYesNo + vbQuestion, APP_NAME) = vbYes Then ChoisirTheme
    Exit Sub
EH:
    ShowError "Import du logo"
    ProtectSheet sh, "L"
End Sub
