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
