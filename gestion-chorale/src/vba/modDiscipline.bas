Option Explicit
' =============================================================================
' modDiscipline : dossiers de discipline (art. 45 a 52), statut du membre
' pendant la sanction puis retour au statut anterieur, recidives, lettre de
' notification (art. 49). Feuille confidentielle (droits du module DISCIPLINE).
' =============================================================================

Public Const SH_DISC As String = "DISCIPLINE"
Public Const SH_NOTIF As String = "NOTIFICATION"
Public Const SANC_VERBAL As String = "Avertissement verbal"
Public Const AUT_DIR As String = "Directeur de chœur"

Private Function DC(ByVal entete As String) As Long
    DC = ColOf(WS(SH_DISC), entete)
End Function

Public Function DisciplineRow(ByVal num As String) As Long
    Dim sh As Worksheet, r As Long
    If num = "" Then Exit Function
    Set sh = WS(SH_DISC)
    For r = FIRSTROW To LastRow(sh, 1)
        If StrComp(CStr(sh.Cells(r, 1).Value), num, vbTextCompare) = 0 Then
            DisciplineRow = r
            Exit Function
        End If
    Next r
End Function

Private Function NextDossier(ByVal d As Date) As String
    Dim sh As Worksheet, r As Long, pre As String, v As String, n As Long, mx As Long
    Set sh = WS(SH_DISC)
    pre = "DIS-" & Year(d) & "-"
    For r = FIRSTROW To LastRow(sh, 1)
        v = CStr(sh.Cells(r, 1).Value)
        If Left$(v, Len(pre)) = pre Then
            n = CLng(Val(Mid$(v, Len(pre) + 1)))
            If n > mx Then mx = n
        End If
    Next r
    NextDossier = pre & Format$(mx + 1, "000")
End Function

Private Function DossierSelectionne() As String
    If ActiveSheet.Name = SH_DISC And ActiveCell.Row >= FIRSTROW Then DossierSelectionne = CStr(WS(SH_DISC).Cells(ActiveCell.Row, 1).Value)
    If DossierSelectionne = "" Then DossierSelectionne = UCase$(Trim$(InputBox("N° du dossier (ex. DIS-2026-001) :", APP_NAME)))
End Function

' Statut donne au membre pendant la sanction ("" : le statut ne change pas)
Public Function StatutSanction(ByVal sanction As String) As String
    Select Case sanction
        Case "Suspension des fonctions": StatutSanction = "Suspendu"
        Case "Exclusion temporaire", "Exclusion indéterminée": StatutSanction = "Exclu temporaire"
        Case "Exclusion définitive": StatutSanction = "Exclu définitif"
        Case Else: StatutSanction = ""
    End Select
End Function

' Controle d'une sanction : "" si elle est conforme, sinon le motif du refus
Public Function ControleSanction(ByVal sanction As String, ByVal autorite As String, ByVal debut As Date, ByVal fin As Date) As String
    Dim lst As Collection, i As Long, ok As Boolean, mx As Long
    If sanction = "" Then Exit Function   ' dossier a examiner
    Set lst = ListValues("Sanction")
    For i = 1 To lst.Count
        If StrComp(lst(i), sanction, vbTextCompare) = 0 Then ok = True
    Next i
    If Not ok Then
        ControleSanction = "Sanction inconnue : " & sanction & " (voir la liste « Sanction » dans LISTES)."
    ElseIf autorite = "" Then
        ControleSanction = "Indiquez l'autorité qui prononce la sanction."
    ElseIf autorite = AUT_DIR And sanction <> SANC_VERBAL Then
        ControleSanction = "Le Directeur de chœur ne prononce que des avertissements verbaux (art. 48). Les autres sanctions sont décidées par le Bureau."
    ElseIf StatutSanction(sanction) <> "" And debut = 0 Then
        ControleSanction = "Indiquez la date de début de la sanction."
    ElseIf fin > 0 And fin < debut Then
        ControleSanction = "La date de fin est antérieure à la date de début."
    ElseIf sanction = "Exclusion temporaire" Then
        mx = ParamNum("EXCLUSION_TEMP_MAX_JOURS", 15)
        If fin = 0 Then
            ControleSanction = "Une exclusion temporaire doit avoir une date de fin."
        ElseIf fin - debut + 1 > mx Then
            ControleSanction = "Une exclusion temporaire ne peut pas dépasser " & mx & " jours (art. 48) : " & (fin - debut + 1) & " jours demandés."
        End If
    ElseIf sanction = "Exclusion définitive" And fin > 0 Then
        ControleSanction = "Une exclusion définitive n'a pas de date de fin."
    End If
End Function

' Nombre de dossiers du membre dans les MOIS_RECIDIVE mois qui precedent la date (hors dossiers classes)
Public Function Recidives(ByVal mat As String, ByVal d As Date, ByVal sauf As String) As Long
    Dim sh As Worksheet, v As Variant, n As Long, i As Long, d0 As Date, df As Date, cM As Long, cD As Long, cS As Long
    Set sh = WS(SH_DISC)
    cM = DC("Matricule"): cD = DC("Date des faits"): cS = DC("Statut")
    d0 = AjouterMois(d, -ParamNum("MOIS_RECIDIVE", 12))
    n = ReadBlock(sh, 1, v)
    For i = 1 To n
        If StrComp(CStr(v(i, cM)), mat, vbTextCompare) = 0 And CStr(v(i, 1)) <> sauf And CStr(v(i, cS)) <> "Classée" Then
            df = AsDate(v(i, cD))
            If df >= d0 And df <= d Then Recidives = Recidives + 1
        End If
    Next i
End Function

' ------------------------------------------------------------ saisie
Private Function ChoixDansListe(ByVal entete As String, ByVal question As String, ByVal defaut As String) As String
    Dim lst As Collection, i As Long, txt As String, rep As String
    Set lst = ListValues(entete)
    For i = 1 To lst.Count
        txt = txt & vbCrLf & "  " & i & " - " & lst(i)
    Next i
    rep = Trim$(InputBox(question & txt, APP_NAME, defaut))
    If rep = "" Then Exit Function
    If IsNumeric(rep) Then
        If CLng(rep) >= 1 And CLng(rep) <= lst.Count Then ChoixDansListe = lst(CLng(rep))
    Else
        ChoixDansListe = rep
    End If
End Function

Private Function DemanderDate(ByVal question As String, ByVal defaut As String, ByRef d As Date) As Boolean
    Dim rep As String
    rep = Trim$(InputBox(question, APP_NAME, defaut))
    d = 0
    If rep = "" Then
        DemanderDate = True
    ElseIf IsDate(rep) Then
        d = CDate(rep)
        DemanderDate = True
    Else
        MsgBox "Date invalide : " & rep, vbExclamation, APP_NAME
    End If
End Function

Public Sub NouveauDossier()
    Dim mat As String, dF As Date, faute As String, desc As String, sanc As String, aut As String
    Dim dDec As Date, d1 As Date, d2 As Date, num As String
    If Not RequireEdit(SH_DISC) Then Exit Sub
    mat = UCase$(Trim$(InputBox("Matricule du membre concerné :", APP_NAME)))
    If mat = "" Then Exit Sub
    If MembreRow(mat) = 0 Then
        MsgBox "Matricule inconnu : " & mat, vbExclamation, APP_NAME
        Exit Sub
    End If
    If Not DemanderDate("Date des faits (jj/mm/aaaa) :", Format$(Date, "dd/mm/yyyy"), dF) Then Exit Sub
    If dF = 0 Then Exit Sub
    faute = ChoixDansListe("Faute", "Faute reprochée (art. 45) : tapez le numéro", "")
    If faute = "" Then Exit Sub
    desc = InputBox("Description des faits :", APP_NAME)
    sanc = ChoixDansListe("Sanction", "Sanction prononcée (laisser vide si le dossier est à examiner par le Bureau) :", "")
    If sanc <> "" Then
        aut = ChoixDansListe("Autorité", "Prononcée par :", "1")
        If aut = "" Then Exit Sub
        If Not DemanderDate("Date de la décision (jj/mm/aaaa) :", Format$(Date, "dd/mm/yyyy"), dDec) Then Exit Sub
        If StatutSanction(sanc) <> "" Then
            If Not DemanderDate("Début de la sanction (jj/mm/aaaa) :", Format$(Date, "dd/mm/yyyy"), d1) Then Exit Sub
            If sanc <> "Exclusion définitive" Then
                If Not DemanderDate("Fin de la sanction (jj/mm/aaaa ; vide si indéterminée) :", "", d2) Then Exit Sub
            End If
        End If
    End If
    num = NouveauDossierInterne(mat, dF, faute, desc, sanc, aut, dDec, d1, d2, "")
    If num = "" Then
        MsgBox G_LastError, vbExclamation, APP_NAME
    Else
        MsgBox "Dossier " & num & " enregistré." & IIf(StatutSanction(sanc) <> "", vbCrLf & "Le statut du membre suivra la sanction (" & StatutSanction(sanc) & ").", ""), vbInformation, APP_NAME
        WS(SH_DISC).Cells(DisciplineRow(num), 1).Select
    End If
End Sub

Public Function NouveauDossierInterne(ByVal mat As String, ByVal dF As Date, ByVal faute As String, ByVal desc As String, _
                                      ByVal sanc As String, ByVal aut As String, ByVal dDec As Date, ByVal d1 As Date, _
                                      ByVal d2 As Date, ByVal obs As String) As String
    Dim sh As Worksheet, r As Long, num As String, msg As String, mr As Long
    G_LastError = ""
    mr = MembreRow(mat)
    If mr = 0 Then
        G_LastError = "Matricule inconnu : " & mat
        Exit Function
    End If
    If Trim$(faute) = "" Then
        G_LastError = "Indiquez la faute reprochée."
        Exit Function
    End If
    msg = ControleSanction(sanc, aut, d1, d2)
    If msg <> "" Then
        G_LastError = msg
        Exit Function
    End If
    Set sh = WS(SH_DISC)
    BeginWork
    num = NextDossier(dF)
    r = LastRow(sh, 1) + 1
    sh.Cells(r, 1).Value = num
    sh.Cells(r, DC("Date des faits")).Value = dF
    sh.Cells(r, DC("Matricule")).Value = mat
    sh.Cells(r, DC("Nom et prénoms")).Value = NomComplet(MembreValeur(mat, "Nom"), MembreValeur(mat, "Prénoms"))
    sh.Cells(r, DC("Faute")).Value = faute
    sh.Cells(r, DC("Description")).Value = desc
    sh.Cells(r, DC("Sanction")).Value = sanc
    sh.Cells(r, DC("Prononcée par")).Value = aut
    If dDec > 0 Then sh.Cells(r, DC("Date de la décision")).Value = dDec
    If d1 > 0 Then sh.Cells(r, DC("Début")).Value = d1
    If d2 > 0 Then sh.Cells(r, DC("Fin")).Value = d2
    sh.Cells(r, DC("Récidives (12 mois)")).Value = Recidives(mat, dF, num)
    If sanc = "" Then
        sh.Cells(r, DC("Statut")).Value = "À examiner"
    ElseIf sanc = SANC_VERBAL Then
        ' donne de vive voix : notifie sur le champ
        sh.Cells(r, DC("Notifiée le")).Value = IIf(dDec > 0, dDec, dF)
        sh.Cells(r, DC("Mode de notification")).Value = "En présence de l'intéressé"
        sh.Cells(r, DC("Statut")).Value = "Terminée"
    Else
        sh.Cells(r, DC("Statut")).Value = "En cours"
    End If
    sh.Cells(r, DC("Observations")).Value = obs
    sh.Cells(r, DC("Saisi par")).Value = G_RoleLabel
    sh.Range(sh.Cells(r, DC("Date des faits")), sh.Cells(r, DC("Date des faits"))).NumberFormat = "dd/mm/yyyy"
    EndWork
    LogAction "Dossier de discipline", num & " " & mat & IIf(sanc <> "", " : " & sanc, " : à examiner"), SH_DISC
    AppliquerSanctionsInterne Date
    NouveauDossierInterne = num
End Function

' Decision du Bureau sur un dossier "A examiner" (ou modification de la sanction)
Public Sub DeciderDossier()
    Dim num As String, r As Long, sh As Worksheet, sanc As String, aut As String, dDec As Date, d1 As Date, d2 As Date
    If Not RequireEdit(SH_DISC) Then Exit Sub
    num = DossierSelectionne()
    r = DisciplineRow(num)
    If r = 0 Then Exit Sub
    Set sh = WS(SH_DISC)
    If CStr(sh.Cells(r, DC("Statut")).Value) <> "À examiner" Then
        MsgBox "Le dossier " & num & " a déjà une décision (statut : " & sh.Cells(r, DC("Statut")).Value & ").", vbInformation, APP_NAME
        Exit Sub
    End If
    sanc = ChoixDansListe("Sanction", "Décision du Bureau pour " & sh.Cells(r, DC("Nom et prénoms")).Value & " :" & vbCrLf & "(tapez 0 pour classer le dossier sans suite)", "")
    If sanc = "" Then Exit Sub
    If sanc = "0" Then
        If DeciderDossierInterne(num, "", "", Date, 0, 0) Then MsgBox "Dossier classé sans suite.", vbInformation, APP_NAME
        Exit Sub
    End If
    aut = ChoixDansListe("Autorité", "Prononcée par :", "1")
    If aut = "" Then Exit Sub
    If Not DemanderDate("Date de la décision (jj/mm/aaaa) :", Format$(Date, "dd/mm/yyyy"), dDec) Then Exit Sub
    If StatutSanction(sanc) <> "" Then
        If Not DemanderDate("Début de la sanction (jj/mm/aaaa) :", Format$(Date, "dd/mm/yyyy"), d1) Then Exit Sub
        If sanc <> "Exclusion définitive" Then
            If Not DemanderDate("Fin de la sanction (jj/mm/aaaa ; vide si indéterminée) :", "", d2) Then Exit Sub
        End If
    End If
    If DeciderDossierInterne(num, sanc, aut, dDec, d1, d2) Then
        MsgBox "Décision enregistrée. Pensez à imprimer la notification (bouton « Notification »).", vbInformation, APP_NAME
    Else
        MsgBox G_LastError, vbExclamation, APP_NAME
    End If
End Sub

Public Function DeciderDossierInterne(ByVal num As String, ByVal sanc As String, ByVal aut As String, ByVal dDec As Date, _
                                      ByVal d1 As Date, ByVal d2 As Date) As Boolean
    Dim sh As Worksheet, r As Long, msg As String
    G_LastError = ""
    r = DisciplineRow(num)
    If r = 0 Then
        G_LastError = "Dossier introuvable : " & num
        Exit Function
    End If
    Set sh = WS(SH_DISC)
    If sanc = "" Then
        BeginWork
        sh.Cells(r, DC("Statut")).Value = "Classée"
        sh.Cells(r, DC("Date de la décision")).Value = dDec
        EndWork
        LogAction "Dossier classé", num, SH_DISC
        DeciderDossierInterne = True
        Exit Function
    End If
    msg = ControleSanction(sanc, aut, d1, d2)
    If msg <> "" Then
        G_LastError = msg
        Exit Function
    End If
    BeginWork
    sh.Cells(r, DC("Sanction")).Value = sanc
    sh.Cells(r, DC("Prononcée par")).Value = aut
    sh.Cells(r, DC("Date de la décision")).Value = dDec
    If d1 > 0 Then sh.Cells(r, DC("Début")).Value = d1
    If d2 > 0 Then sh.Cells(r, DC("Fin")).Value = d2
    If sanc = SANC_VERBAL Then
        sh.Cells(r, DC("Notifiée le")).Value = dDec
        sh.Cells(r, DC("Mode de notification")).Value = "En présence de l'intéressé"
        sh.Cells(r, DC("Statut")).Value = "Terminée"
    Else
        sh.Cells(r, DC("Statut")).Value = "En cours"
    End If
    EndWork
    LogAction "Décision disciplinaire", num & " : " & sanc, SH_DISC
    AppliquerSanctionsInterne Date
    DeciderDossierInterne = True
End Function

' ------------------------------------------------------------ statut des membres
Public Sub AppliquerSanctions()
    Dim n As Long
    If Not RequireEdit(SH_DISC) Then Exit Sub
    n = AppliquerSanctionsInterne(Date)
    MsgBox n & " changement(s) de statut appliqué(s).", vbInformation, APP_NAME
End Sub

' Met le statut des membres en accord avec les sanctions : statut de sanction
' pendant la periode, retour au statut anterieur apres la date de fin.
Public Function AppliquerSanctionsInterne(ByVal asOf As Date) As Long
    Dim sh As Worksheet, ms As Worksheet, r As Long, mr As Long, cible As String, cur As String, ant As String
    Dim d1 As Date, d2 As Date, n As Long, cSt As Long, cDs As Long, num As String
    Set sh = WS(SH_DISC)
    Set ms = WS(SH_MEMBRES)
    cSt = ColOf(ms, "Statut"): cDs = ColOf(ms, "Date du statut")
    BeginWork
    For r = FIRSTROW To LastRow(sh, 1)
        num = CStr(sh.Cells(r, 1).Value)
        cible = StatutSanction(CStr(sh.Cells(r, DC("Sanction")).Value))
        If num <> "" And cible <> "" And CStr(sh.Cells(r, DC("Statut")).Value) = "En cours" Then
            mr = MembreRow(CStr(sh.Cells(r, DC("Matricule")).Value))
            d1 = AsDate(sh.Cells(r, DC("Début")).Value)
            d2 = AsDate(sh.Cells(r, DC("Fin")).Value)
            If mr > 0 And d1 > 0 Then
                cur = CStr(ms.Cells(mr, cSt).Value)
                If asOf >= d1 And (d2 = 0 Or asOf <= d2) Then
                    If cur <> cible Then
                        If CStr(sh.Cells(r, DC("Statut antérieur")).Value) = "" Then sh.Cells(r, DC("Statut antérieur")).Value = cur
                        ms.Cells(mr, cSt).Value = cible
                        ms.Cells(mr, cDs).Value = d1
                        LogAction "Statut (sanction)", num & " : " & cur & " -> " & cible, SH_MEMBRES
                        n = n + 1
                    End If
                    If cible = "Exclu définitif" Then sh.Cells(r, DC("Statut")).Value = "Terminée"
                ElseIf d2 > 0 And asOf > d2 Then
                    If cur = cible Then
                        ant = CStr(sh.Cells(r, DC("Statut antérieur")).Value)
                        If ant = "" Then ant = ST_CONF
                        ms.Cells(mr, cSt).Value = ant
                        ms.Cells(mr, cDs).Value = d2 + 1
                        LogAction "Statut (fin de sanction)", num & " : " & cible & " -> " & ant, SH_MEMBRES
                    End If
                    sh.Cells(r, DC("Statut")).Value = "Terminée"
                    n = n + 1
                End If
            End If
        End If
    Next r
    EndWork
    LoadStatuts
    AppliquerSanctionsInterne = n
End Function

Public Sub LeverSanction()
    Dim num As String, motif As String
    If Not RequireEdit(SH_DISC) Then Exit Sub
    num = DossierSelectionne()
    If DisciplineRow(num) = 0 Then Exit Sub
    motif = InputBox("Motif de la levée anticipée de la sanction " & num & " :", APP_NAME)
    If motif = "" Then Exit Sub
    If LeverSanctionInterne(num, motif) Then
        MsgBox "Sanction levée ; le membre retrouve son statut antérieur.", vbInformation, APP_NAME
    Else
        MsgBox G_LastError, vbExclamation, APP_NAME
    End If
End Sub

Public Function LeverSanctionInterne(ByVal num As String, ByVal motif As String) As Boolean
    Dim sh As Worksheet, ms As Worksheet, r As Long, mr As Long, cible As String, ant As String
    G_LastError = ""
    r = DisciplineRow(num)
    Set sh = WS(SH_DISC)
    If r = 0 Then
        G_LastError = "Dossier introuvable : " & num
        Exit Function
    End If
    If CStr(sh.Cells(r, DC("Statut")).Value) <> "En cours" Then
        G_LastError = "Seule une sanction en cours peut être levée."
        Exit Function
    End If
    Set ms = WS(SH_MEMBRES)
    BeginWork
    cible = StatutSanction(CStr(sh.Cells(r, DC("Sanction")).Value))
    mr = MembreRow(CStr(sh.Cells(r, DC("Matricule")).Value))
    If mr > 0 And cible <> "" Then
        If CStr(ms.Cells(mr, ColOf(ms, "Statut")).Value) = cible Then
            ant = CStr(sh.Cells(r, DC("Statut antérieur")).Value)
            If ant = "" Then ant = ST_CONF
            ms.Cells(mr, ColOf(ms, "Statut")).Value = ant
            ms.Cells(mr, ColOf(ms, "Date du statut")).Value = Date
        End If
    End If
    sh.Cells(r, DC("Statut")).Value = "Levée"
    sh.Cells(r, DC("Observations")).Value = Trim$(CStr(sh.Cells(r, DC("Observations")).Value) & " Levée le " & Format$(Date, "dd/mm/yyyy") & " : " & motif)
    EndWork
    LoadStatuts
    LogAction "Sanction levée", num & " : " & motif, SH_DISC
    LeverSanctionInterne = True
End Function

' ------------------------------------------------------------ notification (art. 49)
Public Sub NotifierSanction()
    Dim num As String, r As Long, rep As String, mode As String
    If Not RequireLogin() Then Exit Sub
    num = DossierSelectionne()
    r = DisciplineRow(num)
    If r = 0 Then Exit Sub
    If CStr(WS(SH_DISC).Cells(r, DC("Sanction")).Value) = "" Then
        MsgBox "Le dossier " & num & " n'a pas encore de sanction.", vbInformation, APP_NAME
        Exit Sub
    End If
    If CanEdit(SH_DISC) And Not HasDate(WS(SH_DISC).Cells(r, DC("Notifiée le")).Value) Then
        rep = InputBox("Enregistrer la notification d'aujourd'hui ?" & vbCrLf & "  1 - En présence de l'intéressé" & vbCrLf & _
                       "  2 - Par écrit (refus de se présenter)" & vbCrLf & "(laisser vide pour imprimer seulement)", APP_NAME, "1")
        If rep = "1" Then mode = "En présence de l'intéressé"
        If rep = "2" Then mode = "Par écrit (refus de se présenter)"
        If mode <> "" Then EnregistrerNotification num, Date, mode
    End If
    If RemplirNotification(num) Then
        WS(SH_NOTIF).Activate
        ImprimerFeuille
    End If
End Sub

Public Sub EnregistrerNotification(ByVal num As String, ByVal d As Date, ByVal mode As String)
    Dim sh As Worksheet, r As Long
    Set sh = WS(SH_DISC)
    r = DisciplineRow(num)
    If r = 0 Then Exit Sub
    BeginWork
    sh.Cells(r, DC("Notifiée le")).Value = d
    sh.Cells(r, DC("Mode de notification")).Value = mode
    ' sanction sans duree : terminee une fois notifiee
    If StatutSanction(CStr(sh.Cells(r, DC("Sanction")).Value)) = "" And CStr(sh.Cells(r, DC("Statut")).Value) = "En cours" Then sh.Cells(r, DC("Statut")).Value = "Terminée"
    EndWork
    LogAction "Sanction notifiée", num & " : " & mode, SH_DISC
End Sub

Public Function RemplirNotification(ByVal num As String) As Boolean
    Dim ns As Worksheet, sh As Worksheet, r As Long, sanc As String, d1 As Date, d2 As Date, row As Long, per As String
    Set ns = WS(SH_NOTIF)
    Set sh = WS(SH_DISC)
    r = DisciplineRow(num)
    If r = 0 Then Exit Function
    sanc = CStr(sh.Cells(r, DC("Sanction")).Value)
    d1 = AsDate(sh.Cells(r, DC("Début")).Value)
    d2 = AsDate(sh.Cells(r, DC("Fin")).Value)
    BeginWork
    ns.Range("A2:F50").ClearContents
    ns.Range("A2:F50").Font.Bold = False
    ns.Range("A2:F50").Borders.LineStyle = xlNone
    ns.Range("A1").Value = "  " & ParamStr("NOM_GROUPE")
    ns.Range("B2").Value = ParamStr("EGLISE") & "  ·  " & ParamStr("PAROISSE")
    ns.Range("E4").Value = ParamStr("VILLE", "Pointe-Noire") & ", le " & Format$(Date, "dd/mm/yyyy")
    ns.Range("B5").Value = "Réf. : " & num
    ns.Range("C7").Value = "À l'attention de " & CStr(sh.Cells(r, DC("Nom et prénoms")).Value) & " (" & CStr(sh.Cells(r, DC("Matricule")).Value) & ")"
    ns.Range("C7").Font.Bold = True
    ns.Range("B9").Value = "Objet : NOTIFICATION DE SANCTION (article 49 du règlement intérieur)"
    ns.Range("B9").Font.Bold = True
    ns.Range("B11").Value = "Nous vous notifions la décision suivante, prise à la suite des faits rappelés ci-dessous :"
    row = 13
    LigneNotif ns, row, "Date des faits", Format$(AsDate(sh.Cells(r, DC("Date des faits")).Value), "dd/mm/yyyy")
    LigneNotif ns, row, "Faute reprochée", CStr(sh.Cells(r, DC("Faute")).Value)
    LigneNotif ns, row, "Description", CStr(sh.Cells(r, DC("Description")).Value)
    LigneNotif ns, row, "Sanction", UCase$(sanc)
    LigneNotif ns, row, "Prononcée par", CStr(sh.Cells(r, DC("Prononcée par")).Value) & IIf(HasDate(sh.Cells(r, DC("Date de la décision")).Value), _
                        " le " & Format$(AsDate(sh.Cells(r, DC("Date de la décision")).Value), "dd/mm/yyyy"), "")
    If d1 > 0 Then
        If d2 > 0 Then
            per = "du " & Format$(d1, "dd/mm/yyyy") & " au " & Format$(d2, "dd/mm/yyyy") & " inclus (" & (d2 - d1 + 1) & " jours)"
        Else
            per = "à compter du " & Format$(d1, "dd/mm/yyyy") & IIf(sanc = "Exclusion définitive", "", ", jusqu'à décision contraire du Bureau")
        End If
        LigneNotif ns, row, "Période", per
    End If
    If NumV(sh.Cells(r, DC("Récidives (12 mois)")).Value) > 0 Then LigneNotif ns, row, "Antécédents", sh.Cells(r, DC("Récidives (12 mois)")).Value & " dossier(s) au cours des " & ParamNum("MOIS_RECIDIVE", 12) & " derniers mois"
    ns.Range(ns.Cells(13, 2), ns.Cells(row - 1, 5)).Borders(xlEdgeBottom).LineStyle = xlContinuous
    row = row + 1
    If StatutSanction(sanc) <> "" And sanc <> "Exclusion définitive" Then
        ns.Cells(row, 2).Value = "Pendant cette période, vous n'êtes pas admis(e) aux prestations de la chorale et vous êtes noté(e)"
        ns.Cells(row + 1, 2).Value = "« non concerné » au pointage des présences. Votre statut sera rétabli à la fin de la sanction."
        row = row + 3
    End If
    ns.Cells(row, 2).Value = "Nous comptons sur votre esprit fraternel pour un retour rapide à la discipline du groupe."
    row = row + 3
    ns.Cells(row, 2).Value = "Le 1er Responsable"
    ns.Cells(row, 5).Value = "Le Secrétaire Général"
    ns.Range(ns.Cells(row, 2), ns.Cells(row, 5)).Font.Bold = True
    ns.Cells(row + 4, 2).Value = TitulaireDe("RESP1")
    ns.Cells(row + 4, 5).Value = TitulaireDe("SG")
    row = row + 7
    ns.Cells(row, 2).Value = "Reçu par l'intéressé(e) le : ....../....../............        Signature : ................................"
    If CStr(sh.Cells(r, DC("Mode de notification")).Value) <> "" Then
        ns.Cells(row + 2, 2).Value = "Notification : " & CStr(sh.Cells(r, DC("Mode de notification")).Value) & _
                                     IIf(HasDate(sh.Cells(r, DC("Notifiée le")).Value), " le " & Format$(AsDate(sh.Cells(r, DC("Notifiée le")).Value), "dd/mm/yyyy"), "")
    End If
    ns.Cells(row + 4, 2).Value = "CONFIDENTIEL"
    ns.Cells(row + 4, 2).Font.Bold = True
    EndWork
    RemplirNotification = True
End Function

Private Sub LigneNotif(ByVal ns As Worksheet, ByRef row As Long, ByVal lbl As String, ByVal txt As String)
    ns.Cells(row, 2).Value = lbl & " :"
    ns.Cells(row, 2).Font.Bold = True
    ns.Cells(row, 3).Value = txt
    row = row + 1
End Sub

' ------------------------------------------------------------ refroidis (art. 52) et alertes
' Ouvre un dossier "A examiner" pour un membre refroidi s'il n'en a pas deja un ouvert
Public Function DossierRefroidi(ByVal mat As String) As String
    Dim sh As Worksheet, r As Long, st As String
    Set sh = WS(SH_DISC)
    For r = FIRSTROW To LastRow(sh, 1)
        If StrComp(CStr(sh.Cells(r, DC("Matricule")).Value), mat, vbTextCompare) = 0 Then
            st = CStr(sh.Cells(r, DC("Statut")).Value)
            If st = "À examiner" And CStr(sh.Cells(r, DC("Faute")).Value) = "Absences non justifiées aux activités" Then Exit Function
        End If
    Next r
    DossierRefroidi = NouveauDossierInterne(mat, Date, "Absences non justifiées aux activités", _
        "Membre refroidi : absent depuis plus de " & ParamNum("MOIS_REFROIDI", 2) & " mois sans justification (art. 52)", "", "", 0, 0, 0, "Ouvert automatiquement")
End Function

' Texte d'alerte pour l'accueil ("" si rien a signaler)
Public Sub AlertesDiscipline(ByVal lignes As Collection)
    Dim sh As Worksheet, v As Variant, n As Long, i As Long, nEx As Long, nNot As Long, nFin As Long, st As String, d2 As Date
    Set sh = WS(SH_DISC)
    n = ReadBlock(sh, 1, v)
    For i = 1 To n
        st = CStr(v(i, DC("Statut")))
        If st = "À examiner" Then nEx = nEx + 1
        If st = "En cours" Then
            If Not HasDate(v(i, DC("Notifiée le"))) Then nNot = nNot + 1
            d2 = AsDate(v(i, DC("Fin")))
            If d2 > 0 And d2 >= Date And d2 <= Date + 7 Then nFin = nFin + 1
        End If
    Next i
    If nEx > 0 Then lignes.Add "Discipline : " & nEx & " dossier(s) à examiner par le Bureau (feuille DISCIPLINE)."
    If nNot > 0 Then lignes.Add "Discipline : " & nNot & " sanction(s) prononcée(s) mais non notifiée(s) (art. 49)."
    If nFin > 0 Then lignes.Add "Discipline : " & nFin & " sanction(s) se terminent dans les 7 jours (statut rétabli automatiquement)."
End Sub
