Option Explicit
' =============================================================================
' modAdhesions : parcours des nouveaux choristes (art. 26 a 28)
' observation -> liste de controle -> decision du Bureau -> reception -> kit
' =============================================================================

Public Const NB_CHECK As Long = 15

Public Function DossierRow(ByVal matricule As String, Optional ByVal ouvertSeulement_ As Boolean = False) As Long
    Dim ouvertSeulement As Boolean: ouvertSeulement = ouvertSeulement_   ' copie locale (compatibilite LibreOffice)
    Dim sh As Worksheet, c As Long, cs As Long, r As Long
    Set sh = WS(SH_ADH)
    c = ColOf(sh, "Matricule")
    cs = ColOf(sh, "Statut du dossier")
    For r = LastRow(sh, 1) To FIRSTROW Step -1
        If StrComp(CStr(sh.Cells(r, c).Value), matricule, vbTextCompare) = 0 Then
            If Not ouvertSeulement Or Left$(CStr(sh.Cells(r, cs).Value), 4) <> "Clos" Then
                DossierRow = r
                Exit Function
            End If
        End If
    Next r
End Function

Private Function NextDossier() As String
    Dim sh As Worksheet, r As Long, v As String, n As Long, mx As Long, pre As String
    Set sh = WS(SH_ADH)
    pre = "ADH-" & Year(Date) & "-"
    For r = FIRSTROW To LastRow(sh, 1)
        v = CStr(sh.Cells(r, 1).Value)
        If Left$(v, Len(pre)) = pre Then
            If IsNumeric(Mid$(v, Len(pre) + 1)) Then
                n = CLng(Mid$(v, Len(pre) + 1))
                If n > mx Then mx = n
            End If
        End If
    Next r
    NextDossier = pre & Format$(mx + 1, "000")
End Function

' Cree le dossier d'adhesion du membre s'il n'en a pas d'ouvert. Renvoie la ligne.
Public Function EnsureDossier(ByVal matricule As String) As Long
    Dim sh As Worksheet, r As Long, arr As Variant
    r = DossierRow(matricule, True)
    If r > 0 Then
        EnsureDossier = r
        Exit Function
    End If
    Set sh = WS(SH_ADH)
    r = LastRow(sh, 1) + 1
    sh.Cells(r, 1).Value = NextDossier()
    sh.Cells(r, ColOf(sh, "Matricule")).Value = matricule
    sh.Cells(r, ColOf(sh, "Nom et prénoms")).Value = NomComplet(MembreValeur(matricule, "Nom"), MembreValeur(matricule, "Prénoms"))
    sh.Cells(r, ColOf(sh, "Catégorie d'entrée")).Value = ListValues("Catégorie d'entrée")(1)
    arr = MembreValeur(matricule, "Date d'arrivée")
    If HasDate(arr) Then
        sh.Cells(r, ColOf(sh, "Début d'observation")).Value = AsDate(arr)
    Else
        sh.Cells(r, ColOf(sh, "Début d'observation")).Value = Date
    End If
    sh.Cells(r, ColOf(sh, "Statut du dossier")).Value = "En cours"
    EnsureDossier = r
End Function

' En-tetes "01 · libelle" a partir de la feuille CONTROLES_ADHESION
Public Sub RefreshChecklistHeaders()
    Dim sh As Worksheet, ctl As Worksheet, n As Long, c As Long, lbl As String, first As Long
    On Error Resume Next
    Set sh = WS(SH_ADH)
    Set ctl = WS(SH_CTRL)
    first = ColOf(sh, "Taux d'assiduité") + 1
    For n = 1 To NB_CHECK
        c = first + n - 1
        lbl = Trim$(CStr(ctl.Cells(FIRSTROW + n - 1, ColOf(ctl, "Élément")).Value))
        If lbl = "" Then
            sh.Cells(HDR, c).Value = Format$(n, "00") & " · (libre)"
            sh.Columns(c).Hidden = True
        Else
            sh.Cells(HDR, c).Value = Format$(n, "00") & " · " & lbl
            sh.Columns(c).Hidden = False
        End If
    Next n
End Sub

Private Function CtrlItem(ByVal n As Long, ByVal entete As String) As String
    Dim ctl As Worksheet
    Set ctl = WS(SH_CTRL)
    CtrlItem = Trim$(CStr(ctl.Cells(FIRSTROW + n - 1, ColOf(ctl, entete)).Value))
End Function

Private Function EstTransfert(ByVal categorie As String) As Boolean
    EstTransfert = (InStr(1, categorie, "transfert", vbTextCompare) > 0)
End Function

Private Function EstCatechumene(ByVal categorie As String) As Boolean
    EstCatechumene = (InStr(1, categorie, "catéchum", vbTextCompare) > 0)
End Function

Public Sub ActualiserDossiers()
    DoActualiserDossiers False
End Sub

Public Sub DoActualiserDossiers(ByVal silencieux As Boolean)
    Dim sh As Worksheet, r As Long, lr As Long, n As Long, c As Long, mat As String, cat As String
    Dim d0 As Date, dFin As Date, dBapt As Date, dNew As Date, attendues As Long, pondere As Double, taux As Double
    Dim manquants As String, prop As String, statut As String, seuil As Double, mois As Long, v As String, appl As String
    Dim nb As Long, cProp As Long
    If Not RequireLogin() Then Exit Sub
    On Error GoTo EH
    BeginWork
    RefreshChecklistHeaders
    LoadPresenceCache
    Set sh = WS(SH_ADH)
    seuil = ParamNum("SEUIL_ASSIDUITE_ADHESION", 0.6)
    mois = ParamNum("DUREE_OBSERVATION_MOIS", 3)
    lr = LastRow(sh, 1)
    cProp = ColOf(sh, "Proposition")
    For r = FIRSTROW To lr
        statut = CStr(sh.Cells(r, ColOf(sh, "Statut du dossier")).Value)
        mat = CStr(sh.Cells(r, ColOf(sh, "Matricule")).Value)
        If mat <> "" And Left$(statut, 4) <> "Clos" Then
            nb = nb + 1
            sh.Cells(r, ColOf(sh, "Nom et prénoms")).Value = NomComplet(MembreValeur(mat, "Nom"), MembreValeur(mat, "Prénoms"))
            cat = CStr(sh.Cells(r, ColOf(sh, "Catégorie d'entrée")).Value)
            d0 = AsDate(sh.Cells(r, ColOf(sh, "Début d'observation")).Value)
            dBapt = AsDate(MembreValeur(mat, "Date de baptême"))
            dNew = AsDate(sh.Cells(r, ColOf(sh, "Nouvelle fin d'observation")).Value)
            prop = ""
            If EstCatechumene(cat) Then
                If dBapt = 0 Then
                    prop = "En attente du baptême"
                ElseIf dBapt > d0 Then
                    d0 = dBapt
                End If
            End If
            If d0 = 0 Then d0 = Date
            If dNew > 0 Then dFin = dNew Else dFin = AjouterMois(d0, mois)
            sh.Cells(r, ColOf(sh, "Fin prévue")).Value = dFin

            MemberRate mat, d0, IIf(dFin < Date, dFin, Date), "", attendues, pondere
            sh.Cells(r, ColOf(sh, "Séances attendues")).Value = attendues
            If attendues > 0 Then
                taux = pondere / attendues
                sh.Cells(r, ColOf(sh, "Taux d'assiduité")).Value = taux
            Else
                taux = 0
                sh.Cells(r, ColOf(sh, "Taux d'assiduité")).Value = ""
            End If

            manquants = ""
            For n = 1 To NB_CHECK
                c = CheckCol(sh, n)
                If c > 0 And CtrlItem(n, "Élément") <> "" Then
                    appl = UCase$(CtrlItem(n, "Applicable à"))
                    If appl = "TRANSFERT" And Not EstTransfert(cat) Then
                        sh.Cells(r, c).Value = "N/A"
                    Else
                        v = UCase$(Trim$(CStr(sh.Cells(r, c).Value)))
                        If v = "N/A" Then sh.Cells(r, c).Value = "": v = ""
                        If v <> "OUI" And UCase$(CtrlItem(n, "Obligatoire")) = "OUI" Then
                            manquants = manquants & IIf(manquants = "", "", ", ") & CtrlItem(n, "Élément")
                        End If
                    End If
                End If
            Next n
            sh.Cells(r, ColOf(sh, "Éléments manquants")).Value = manquants

            If prop = "" Then
                If Date < dFin Then
                    prop = "Observation en cours (encore " & CLng(dFin - Date) & " j)"
                ElseIf manquants <> "" Then
                    prop = "Éléments manquants"
                ElseIf attendues = 0 Then
                    prop = "Aucune présence pointée"
                ElseIf taux < seuil Then
                    prop = "Assiduité insuffisante (" & Format$(taux, "0%") & ")"
                Else
                    prop = "À CONFIRMER par le Bureau"
                End If
            End If
            sh.Cells(r, cProp).Value = prop
            If Left$(prop, 2) = "À " Then
                sh.Cells(r, cProp).Interior.Color = RGB(198, 239, 206)
            ElseIf Left$(prop, 11) = "Observation" Then
                sh.Cells(r, cProp).Interior.Color = RGB(221, 235, 247)
            Else
                sh.Cells(r, cProp).Interior.Color = RGB(255, 235, 156)
            End If
        End If
    Next r
    EndWork
    If Not silencieux Then
        MsgBox nb & " dossier(s) en cours actualisé(s).", vbInformation, APP_NAME
    End If
    Exit Sub
EH:
    ShowError "Actualisation des dossiers"
End Sub

Public Sub AppliquerDecisions()
    Dim sh As Worksheet, ms As Worksheet, r As Long, lr As Long, mat As String, dec As String, statut As String
    Dim dRec As Date, offi As String, motif As String, dNew As Date, mr As Long, prop As String
    Dim nConf As Long, nProl As Long, nRef As Long, erreurs As String, nKit As Long
    If Not RequireEdit(SH_ADH) Then Exit Sub
    If Not CanEdit(SH_MEMBRES) Then
        MsgBox "La mise à jour des fiches membres nécessite le droit de modification sur MEMBRES.", vbExclamation, APP_NAME
        Exit Sub
    End If
    DoActualiserDossiers True
    On Error GoTo EH
    Set sh = WS(SH_ADH)
    Set ms = WS(SH_MEMBRES)
    lr = LastRow(sh, 1)
    For r = FIRSTROW To lr
        statut = CStr(sh.Cells(r, ColOf(sh, "Statut du dossier")).Value)
        dec = Trim$(CStr(sh.Cells(r, ColOf(sh, "Décision")).Value))
        mat = CStr(sh.Cells(r, ColOf(sh, "Matricule")).Value)
        If dec <> "" And mat <> "" And Left$(statut, 4) <> "Clos" Then
            mr = MembreRow(mat)
            motif = Trim$(CStr(sh.Cells(r, ColOf(sh, "Motif")).Value))
            prop = CStr(sh.Cells(r, ColOf(sh, "Proposition")).Value)
            Select Case LCase$(dec)
                Case "confirmer"
                    dRec = AsDate(sh.Cells(r, ColOf(sh, "Date de réception")).Value)
                    offi = Trim$(CStr(sh.Cells(r, ColOf(sh, "Officiant")).Value))
                    If dRec = 0 Or offi = "" Then
                        erreurs = erreurs & vbCrLf & "- " & mat & " : date de réception et officiant obligatoires"
                    ElseIf mr = 0 Then
                        erreurs = erreurs & vbCrLf & "- " & mat & " : membre introuvable"
                    Else
                        If Left$(prop, 2) <> "À " Then
                            If MsgBox(mat & " - " & sh.Cells(r, ColOf(sh, "Nom et prénoms")).Value & vbCrLf & _
                                      "L'application signale : " & prop & vbCrLf & vbCrLf & _
                                      "Le Bureau confirme-t-il quand même ce choriste ?", vbYesNo + vbQuestion, APP_NAME) = vbNo Then GoTo Suivant
                        End If
                        BeginWork
                        ms.Cells(mr, ColOf(ms, "Statut")).Value = ST_CONF
                        ms.Cells(mr, ColOf(ms, "Date du statut")).Value = dRec
                        ms.Cells(mr, ColOf(ms, "Date de réception")).Value = dRec
                        If UCase$(CStr(sh.Cells(r, ColOf(sh, "Kit transféré")).Value)) <> "OUI" Then
                            nKit = nKit + TransfererKit(r)
                            sh.Cells(r, ColOf(sh, "Kit transféré")).Value = "OUI"
                        End If
                        sh.Cells(r, ColOf(sh, "Statut du dossier")).Value = "Clos - confirmé le " & Format$(dRec, "dd/mm/yyyy")
                        EndWork
                        LogAction "Choriste confirmé", mat & " reçu le " & Format$(dRec, "dd/mm/yyyy") & " par " & offi, SH_ADH
                        nConf = nConf + 1
                    End If
                Case "prolonger"
                    dNew = AsDate(sh.Cells(r, ColOf(sh, "Nouvelle fin d'observation")).Value)
                    If dNew = 0 Or motif = "" Then
                        erreurs = erreurs & vbCrLf & "- " & mat & " : nouvelle date de fin et motif obligatoires"
                    ElseIf InStr(statut, Format$(dNew, "dd/mm/yyyy")) = 0 Then
                        BeginWork
                        sh.Cells(r, ColOf(sh, "Statut du dossier")).Value = "Prolongé jusqu'au " & Format$(dNew, "dd/mm/yyyy")
                        EndWork
                        LogAction "Observation prolongée", mat & " jusqu'au " & Format$(dNew, "dd/mm/yyyy") & " : " & motif, SH_ADH
                        nProl = nProl + 1
                    End If
                Case "refuser"
                    If motif = "" Then
                        erreurs = erreurs & vbCrLf & "- " & mat & " : motif obligatoire"
                    Else
                        BeginWork
                        If mr > 0 Then
                            ms.Cells(mr, ColOf(ms, "Statut")).Value = ST_NONRETENU
                            ms.Cells(mr, ColOf(ms, "Date du statut")).Value = Date
                        End If
                        sh.Cells(r, ColOf(sh, "Statut du dossier")).Value = "Clos - refusé le " & Format$(Date, "dd/mm/yyyy")
                        EndWork
                        LogAction "Adhésion refusée", mat & " : " & motif, SH_ADH
                        nRef = nRef + 1
                    End If
            End Select
        End If
Suivant:
    Next r
    MsgBox "Décisions appliquées :" & vbCrLf & _
           "  - choristes confirmés : " & nConf & IIf(nKit > 0, " (" & nKit & " article(s) ajouté(s) au patrimoine)", "") & vbCrLf & _
           "  - observations prolongées : " & nProl & vbCrLf & _
           "  - adhésions refusées : " & nRef & _
           IIf(erreurs <> "", vbCrLf & vbCrLf & "À compléter :" & erreurs, ""), _
           IIf(erreurs <> "", vbExclamation, vbInformation), APP_NAME
    Exit Sub
EH:
    ShowError "Application des décisions"
End Sub

' Ajoute au PATRIMOINE les articles du kit remis (Va au patrimoine = OUI)
Private Function TransfererKit(ByVal r As Long) As Long
    Dim sh As Worksheet, ps As Worksheet, n As Long, c As Long, pr As Long, nom As String, mat As String
    Dim dRec As Date, dos As String, valeur As Double
    Set sh = WS(SH_ADH)
    Set ps = WS(SH_PAT)
    mat = CStr(sh.Cells(r, ColOf(sh, "Matricule")).Value)
    nom = CStr(sh.Cells(r, ColOf(sh, "Nom et prénoms")).Value)
    dos = CStr(sh.Cells(r, 1).Value)
    dRec = AsDate(sh.Cells(r, ColOf(sh, "Date de réception")).Value, Date)
    For n = 1 To NB_CHECK
        c = CheckCol(sh, n)
        If c > 0 Then
            If UCase$(CStr(sh.Cells(r, c).Value)) = "OUI" And UCase$(CtrlItem(n, "Va au patrimoine")) = "OUI" Then
                pr = LastRow(ps, 1) + 1
                valeur = Val(Replace(CtrlItem(n, "Valeur unitaire estimée (FCFA)"), " ", ""))
                ps.Cells(pr, ColOf(ps, "Code")).Value = NextPatrimoineCode()
                ps.Cells(pr, ColOf(ps, "Désignation")).Value = CtrlItem(n, "Élément")
                ps.Cells(pr, ColOf(ps, "Catégorie")).Value = CtrlItem(n, "Catégorie de patrimoine")
                ps.Cells(pr, ColOf(ps, "Quantité")).Value = 1
                ps.Cells(pr, ColOf(ps, "Unité")).Value = "pièce"
                ps.Cells(pr, ColOf(ps, "Date d'acquisition")).Value = dRec
                ps.Cells(pr, ColOf(ps, "Mode d'acquisition")).Value = "Kit nouveau choriste"
                ps.Cells(pr, ColOf(ps, "Origine / Donateur")).Value = nom & " (" & mat & ")"
                ps.Cells(pr, ColOf(ps, "Valeur unitaire (FCFA)")).Value = valeur
                ps.Cells(pr, ColOf(ps, "Valeur totale (FCFA)")).Value = valeur
                ps.Cells(pr, ColOf(ps, "État")).Value = "Bon"
                ps.Cells(pr, ColOf(ps, "Localisation")).Value = "Magasin de la chorale"
                ps.Cells(pr, ColOf(ps, "Observations")).Value = "Dossier " & dos
                TransfererKit = TransfererKit + 1
            End If
        End If
    Next n
    If TransfererKit > 0 Then LogAction "Kit ajouté au patrimoine", TransfererKit & " article(s) - " & mat, SH_PAT
End Function

Public Function NextPatrimoineCode() As String
    Dim ps As Worksheet, r As Long, v As String, n As Long, mx As Long
    Set ps = WS(SH_PAT)
    For r = FIRSTROW To LastRow(ps, 1)
        v = CStr(ps.Cells(r, 1).Value)
        If Left$(v, 4) = "PAT-" And IsNumeric(Mid$(v, 5)) Then
            n = CLng(Mid$(v, 5))
            If n > mx Then mx = n
        End If
    Next r
    NextPatrimoineCode = "PAT-" & Format$(mx + 1, "0000")
End Function
