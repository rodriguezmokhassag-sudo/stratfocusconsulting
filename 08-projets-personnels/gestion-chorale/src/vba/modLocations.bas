Option Explicit
' =============================================================================
' modLocations : location de materiel (art. 30)
' Demande -> articles (tarif/jour) -> avis de la commission musicale et accord
' du Bureau -> encaissement du loyer et de la caution (Finances) -> remise du
' materiel -> retour (etat, retenue) -> restitution de la caution (Finances).
' =============================================================================

Private Function LC(ByVal entete As String) As Long
    LC = ColOf(WS(SH_LOCATIONS), entete)
End Function

Public Function LocationRow(ByVal num As String) As Long
    Dim sh As Worksheet, r As Long
    Set sh = WS(SH_LOCATIONS)
    For r = FIRSTROW To LastRow(sh, 1)
        If CStr(sh.Cells(r, 1).Value) = num Then
            LocationRow = r
            Exit Function
        End If
    Next r
End Function

Private Function LocationSelectionnee() As String
    If ActiveSheet.Name = SH_LOCATIONS And ActiveCell.Row >= FIRSTROW Then LocationSelectionnee = CStr(WS(SH_LOCATIONS).Cells(ActiveCell.Row, 1).Value)
    If LocationSelectionnee = "" Then LocationSelectionnee = UCase$(Trim$(InputBox("Numéro du contrat (ex. LOC-2026-001) :", APP_NAME)))
End Function

Private Function LocStatut(ByVal num As String) As String
    Dim r As Long
    r = LocationRow(num)
    If r > 0 Then LocStatut = CStr(WS(SH_LOCATIONS).Cells(r, LC("Statut")).Value)
End Function

Private Sub SetLocStatut(ByVal num As String, ByVal statut As String)
    WS(SH_LOCATIONS).Cells(LocationRow(num), LC("Statut")).Value = statut
End Sub

' ============================================================ demande
Public Sub NouvelleLocation()
    Dim loc As String, contact As String, objet As String, s1 As String, s2 As String, num As String
    If Not RequireEdit(SH_LOCATIONS) Then Exit Sub
    loc = Trim$(InputBox("Locataire (groupe, chorale ou personne) :", APP_NAME))
    If loc = "" Then Exit Sub
    contact = Trim$(InputBox("Téléphone du locataire :", APP_NAME))
    objet = Trim$(InputBox("Objet de la location (événement) :", APP_NAME))
    s1 = InputBox("Date de début (jj/mm/aaaa) :", APP_NAME, Format$(Date + 7, "dd/mm/yyyy"))
    If Not IsDate(s1) Then Exit Sub
    s2 = InputBox("Date de fin (jj/mm/aaaa) :", APP_NAME, s1)
    If Not IsDate(s2) Then Exit Sub
    num = NouvelleLocationInterne(loc, contact, objet, CDate(s1), CDate(s2))
    If num = "" Then
        MsgBox G_LastError, vbExclamation, APP_NAME
    Else
        MsgBox "Demande " & num & " enregistrée." & vbCrLf & "Ajoutez maintenant les articles (bouton « Ajouter un article »).", vbInformation, APP_NAME
    End If
End Sub

Public Function NouvelleLocationInterne(ByVal locataire As String, ByVal contact As String, ByVal objet As String, _
                                        ByVal d1 As Date, ByVal d2 As Date) As String
    Dim sh As Worksheet, r As Long, k As Long, pre As String, v As String, n As Long, mx As Long, num As String
    G_LastError = ""
    If d2 < d1 Then G_LastError = "La date de fin est avant la date de début.": Exit Function
    Set sh = WS(SH_LOCATIONS)
    pre = "LOC-" & Year(Date) & "-"
    For k = FIRSTROW To LastRow(sh, 1)
        v = CStr(sh.Cells(k, 1).Value)
        If Left$(v, Len(pre)) = pre Then
            n = CLng(Val(Mid$(v, Len(pre) + 1)))
            If n > mx Then mx = n
        End If
    Next k
    num = pre & Format$(mx + 1, "000")
    BeginWork
    r = LastRow(sh, 1) + 1
    sh.Cells(r, 1).Value = num
    sh.Cells(r, LC("Date de la demande")).Value = Date
    sh.Cells(r, LC("Locataire")).Value = locataire
    sh.Cells(r, LC("Contact")).Value = contact
    sh.Cells(r, LC("Objet")).Value = objet
    sh.Cells(r, LC("Début")).Value = d1
    sh.Cells(r, LC("Fin")).Value = d2
    sh.Cells(r, LC("Jours")).Value = CLng(d2 - d1) + 1
    sh.Cells(r, LC("Montant location (FCFA)")).Value = 0
    sh.Cells(r, LC("Caution (FCFA)")).Value = 0
    sh.Cells(r, LC("Statut")).Value = "Demande"
    EndWork
    LogAction "Demande de location", num & " : " & locataire, SH_LOCATIONS
    NouvelleLocationInterne = num
End Function

Public Sub AjouterArticleLocation()
    Dim num As String, code As String, s As String
    If Not RequireEdit(SH_LOCATIONS) Then Exit Sub
    num = LocationSelectionnee()
    If num = "" Then Exit Sub
    code = UCase$(Trim$(InputBox("Code du bien à louer (biens marqués « Louable = OUI » dans PATRIMOINE) :", APP_NAME)))
    If code = "" Then Exit Sub
    s = InputBox("Quantité :", APP_NAME, "1")
    If s = "" Or Not IsNumeric(s) Then Exit Sub
    If AjouterArticleInterne(num, code, CDbl(s)) Then
        MsgBox "Article ajouté. Loyer : " & Fcfa(NumV(WS(SH_LOCATIONS).Cells(LocationRow(num), LC("Montant location (FCFA)")).Value)) & _
               " - caution proposée : " & Fcfa(NumV(WS(SH_LOCATIONS).Cells(LocationRow(num), LC("Caution (FCFA)")).Value)), vbInformation, APP_NAME
    Else
        MsgBox G_LastError, vbExclamation, APP_NAME
    End If
End Sub

Public Function AjouterArticleInterne(ByVal num As String, ByVal code As String, ByVal q As Double) As Boolean
    Dim sh As Worksheet, r As Long, jours As Long, tarif As Double, st As String
    G_LastError = ""
    Set sh = WS(SH_LOCATIONS)
    r = LocationRow(num)
    If r = 0 Then G_LastError = "Contrat introuvable : " & num: Exit Function
    st = LocStatut(num)
    If st <> "Demande" And st <> "Approuvée" Then G_LastError = "Les articles ne peuvent plus être modifiés (statut " & st & ").": Exit Function
    If BienRow(code) = 0 Then G_LastError = "Bien introuvable : " & code: Exit Function
    If UCase$(CStr(BienValeur(code, "Louable"))) <> "OUI" Then G_LastError = code & " n'est pas marqué comme louable dans PATRIMOINE.": Exit Function
    If q <= 0 Then G_LastError = "Quantité invalide.": Exit Function
    If q > Disponible(code) Then G_LastError = "Quantité disponible insuffisante (" & Disponible(code) & ").": Exit Function
    jours = CLng(NumV(sh.Cells(r, LC("Jours")).Value))
    If jours < 1 Then jours = 1
    tarif = NumV(BienValeur(code, "Tarif location / jour (FCFA)"))
    BeginWork
    AjouterMouvement Date, "Location", code, q, CStr(sh.Cells(r, LC("Locataire")).Value), num, _
        CDbl(AsDate(sh.Cells(r, LC("Fin")).Value)), CStr(BienValeur(code, "État")), tarif * jours * q, "", "Prévu", ""
    EndWork
    RecalculerContrat num
    LogAction "Article loué", num & " : " & code & " x" & q, SH_LOCATIONS
    AjouterArticleInterne = True
End Function

' Loyer = somme des articles ; caution = pourcentage de la valeur (remplacement sinon acquisition), avec minimum
Public Sub RecalculerContrat(ByVal num As String)
    Dim ms As Worksheet, sh As Worksheet, k As Long, r As Long, loyer As Double, valeur As Double, code As String
    Dim q As Double, vr As Double, qt As Double, caution As Double
    Set ms = WS(SH_MOUV)
    Set sh = WS(SH_LOCATIONS)
    r = LocationRow(num)
    If r = 0 Then Exit Sub
    For k = FIRSTROW To LastRow(ms, 1)
        If CStr(ms.Cells(k, MV_CONTRAT).Value) = num And CStr(ms.Cells(k, MV_STATUT).Value) <> "Annulé" Then
            loyer = loyer + NumV(ms.Cells(k, MV_MONTANT).Value)
            code = CStr(ms.Cells(k, MV_CODE).Value)
            q = NumV(ms.Cells(k, MV_QTE).Value)
            qt = NumV(BienValeur(code, "Quantité"))
            vr = NumV(BienValeur(code, "Valeur de remplacement (FCFA)"))
            If vr > 0 And qt > 0 Then
                valeur = valeur + vr / qt * q
            Else
                valeur = valeur + NumV(BienValeur(code, "Valeur unitaire (FCFA)")) * q
            End If
        End If
    Next k
    caution = Round(valeur * ParamNum("CAUTION_POURCENT", 0.3) / 1000, 0) * 1000
    If caution < ParamNum("CAUTION_MINIMUM", 10000) Then caution = ParamNum("CAUTION_MINIMUM", 10000)
    BeginWork
    sh.Cells(r, LC("Montant location (FCFA)")).Value = loyer
    If LocStatut(num) = "Demande" Or NumV(sh.Cells(r, LC("Caution (FCFA)")).Value) = 0 Then sh.Cells(r, LC("Caution (FCFA)")).Value = caution
    EndWork
End Sub

' ============================================================ approbation
Public Sub ApprouverLocation()
    Dim num As String, r As Long, avis As String, accord As String
    If Not RequireEdit(SH_LOCATIONS) Then Exit Sub
    num = LocationSelectionnee()
    r = LocationRow(num)
    If r = 0 Then Exit Sub
    avis = CStr(WS(SH_LOCATIONS).Cells(r, LC("Avis commission musicale")).Value)
    accord = CStr(WS(SH_LOCATIONS).Cells(r, LC("Accord du Bureau")).Value)
    If avis = "" Then avis = Trim$(InputBox("Avis de la commission musicale (ex. Favorable du 12/06) :", APP_NAME))
    If accord = "" Then accord = Trim$(InputBox("Accord du Bureau (référence du PV) :", APP_NAME))
    If ApprouverInterne(num, avis, accord) Then
        MsgBox "Location " & num & " approuvée. Le Secrétaire aux Finances peut encaisser le loyer et la caution.", vbInformation, APP_NAME
    Else
        MsgBox G_LastError, vbExclamation, APP_NAME
    End If
End Sub

Public Function ApprouverInterne(ByVal num As String, ByVal avis As String, ByVal accord As String) As Boolean
    Dim r As Long, sh As Worksheet
    G_LastError = ""
    Set sh = WS(SH_LOCATIONS)
    r = LocationRow(num)
    If r = 0 Then G_LastError = "Contrat introuvable.": Exit Function
    If LocStatut(num) <> "Demande" Then G_LastError = "Seule une demande peut être approuvée (statut actuel : " & LocStatut(num) & ").": Exit Function
    If NumV(sh.Cells(r, LC("Montant location (FCFA)")).Value) <= 0 Then G_LastError = "Ajoutez d'abord les articles loués.": Exit Function
    If avis = "" Or accord = "" Then G_LastError = "L'avis de la commission musicale et l'accord du Bureau sont obligatoires (art. 30).": Exit Function
    BeginWork
    sh.Cells(r, LC("Avis commission musicale")).Value = avis
    sh.Cells(r, LC("Accord du Bureau")).Value = accord
    SetLocStatut num, "Approuvée"
    EndWork
    LogAction "Location approuvée", num & " - " & accord, SH_LOCATIONS
    ApprouverInterne = True
End Function

Public Sub RefuserLocation()
    Dim num As String, ms As Worksheet, k As Long, motif As String
    If Not RequireEdit(SH_LOCATIONS) Then Exit Sub
    num = LocationSelectionnee()
    If LocationRow(num) = 0 Then Exit Sub
    If LocStatut(num) <> "Demande" And LocStatut(num) <> "Approuvée" Then
        MsgBox "Cette location ne peut plus être refusée.", vbExclamation, APP_NAME
        Exit Sub
    End If
    motif = Trim$(InputBox("Motif du refus :", APP_NAME))
    If motif = "" Then Exit Sub
    Set ms = WS(SH_MOUV)
    BeginWork
    For k = FIRSTROW To LastRow(ms, 1)
        If CStr(ms.Cells(k, MV_CONTRAT).Value) = num Then ms.Cells(k, MV_STATUT).Value = "Annulé"
    Next k
    SetLocStatut num, "Refusée"
    WS(SH_LOCATIONS).Cells(LocationRow(num), LC("Observations")).Value = "Refus : " & motif
    EndWork
    LogAction "Location refusée", num & " : " & motif, SH_LOCATIONS
End Sub

' ============================================================ encaissement (Finances)
Public Sub EncaisserLocation()
    Dim num As String, caisse As String
    If Not RequireLogin() Then Exit Sub
    num = LocationSelectionnee()
    If LocationRow(num) = 0 Then Exit Sub
    caisse = ChoisirCaisse("Encaissement du loyer et de la caution")
    If caisse = "" Then Exit Sub
    If EncaisserLocationInterne(num, caisse) Then
        MsgBox "Loyer et caution encaissés (reçus " & RecuDePiece(CStr(WS(SH_LOCATIONS).Cells(LocationRow(num), LC("Pièce loyer")).Value)) & _
               " et " & RecuDePiece(CStr(WS(SH_LOCATIONS).Cells(LocationRow(num), LC("Pièce caution")).Value)) & ").", vbInformation, APP_NAME
    Else
        MsgBox G_LastError, vbExclamation, APP_NAME
    End If
End Sub

Public Function EncaisserLocationInterne(ByVal num As String, ByVal caisse As String) As Boolean
    Dim sh As Worksheet, r As Long, loc As String, p1 As String, p2 As String, loyer As Double, caution As Double
    G_LastError = ""
    If ModuleRight("FINANCES") <> "M" Then G_LastError = "L'encaissement est réservé au Secrétaire aux Finances (ou à son intérimaire).": Exit Function
    Set sh = WS(SH_LOCATIONS)
    r = LocationRow(num)
    If r = 0 Then G_LastError = "Contrat introuvable.": Exit Function
    If LocStatut(num) <> "Approuvée" Then G_LastError = "La location doit d'abord être approuvée (statut actuel : " & LocStatut(num) & ").": Exit Function
    loc = CStr(sh.Cells(r, LC("Locataire")).Value)
    loyer = NumV(sh.Cells(r, LC("Montant location (FCFA)")).Value)
    caution = NumV(sh.Cells(r, LC("Caution (FCFA)")).Value)
    On Error GoTo EH
    BeginWork
    If loyer > 0 Then p1 = EnregistrerEcriture(Date, caisse, "Recette", ParamStr("CODE_LOCATION", "R05.1"), "Loyer " & num, "", loc, num, loyer, "", "Validée", "", True)
    If caution > 0 Then p2 = EnregistrerEcriture(Date, caisse, "Recette", ParamStr("CODE_CAUTION_RECUE", "R10.1"), "Caution " & num, "", loc, num, caution, "", "Validée", "", True)
    sh.Cells(r, LC("Pièce loyer")).Value = p1
    sh.Cells(r, LC("Pièce caution")).Value = p2
    SetLocStatut num, "Payée"
    EndWork
    LogAction "Location encaissée", num & " : loyer " & Fcfa(loyer) & ", caution " & Fcfa(caution), SH_LOCATIONS
    EncaisserLocationInterne = True
    Exit Function
EH:
    G_LastError = Err.Description
    EndWork
End Function

' ============================================================ remise et retour
Public Sub RemettreMateriel()
    Dim num As String
    If Not RequireEdit(SH_LOCATIONS) Then Exit Sub
    num = LocationSelectionnee()
    If LocationRow(num) = 0 Then Exit Sub
    If RemettreInterne(num) Then
        If MsgBox("Matériel remis. Imprimer le contrat de location à faire signer ?", vbYesNo + vbQuestion, APP_NAME) = vbYes Then
            If RemplirContrat(num) Then ApercuFeuille SH_CONTRAT
        End If
    Else
        MsgBox G_LastError, vbExclamation, APP_NAME
    End If
End Sub

Public Function RemettreInterne(ByVal num As String) As Boolean
    Dim ms As Worksheet, k As Long, code As String, q As Double
    G_LastError = ""
    If LocStatut(num) <> "Payée" Then G_LastError = "Le loyer et la caution doivent d'abord être encaissés (statut actuel : " & LocStatut(num) & ").": Exit Function
    Set ms = WS(SH_MOUV)
    For k = FIRSTROW To LastRow(ms, 1)
        If CStr(ms.Cells(k, MV_CONTRAT).Value) = num And CStr(ms.Cells(k, MV_STATUT).Value) = "Prévu" Then
            code = CStr(ms.Cells(k, MV_CODE).Value)
            q = NumV(ms.Cells(k, MV_QTE).Value)
            If q > Disponible(code) Then G_LastError = code & " : quantité disponible insuffisante (" & Disponible(code) & ").": Exit Function
        End If
    Next k
    BeginWork
    For k = FIRSTROW To LastRow(ms, 1)
        If CStr(ms.Cells(k, MV_CONTRAT).Value) = num And CStr(ms.Cells(k, MV_STATUT).Value) = "Prévu" Then
            ms.Cells(k, MV_STATUT).Value = "En cours"
            ms.Cells(k, MV_DATE).Value = Date
            ms.Cells(k, MV_EDEP).Value = BienValeur(CStr(ms.Cells(k, MV_CODE).Value), "État")
            ms.Cells(k, MV_PIECE).Value = WS(SH_LOCATIONS).Cells(LocationRow(num), LC("Pièce loyer")).Value
        End If
    Next k
    SetLocStatut num, "En cours"
    EndWork
    RecalculerPatrimoineInterne Date
    LogAction "Matériel remis", num, SH_LOCATIONS
    RemettreInterne = True
End Function

Public Sub RetourLocation()
    Dim num As String, etat As String, s As String, retenue As Double, t As String
    If Not RequireEdit(SH_LOCATIONS) Then Exit Sub
    num = LocationSelectionnee()
    If LocationRow(num) = 0 Then Exit Sub
    t = InputBox("État du matériel au retour :" & vbCrLf & "  1 - Bon (aucun dégât)" & vbCrLf & "  2 - À réparer" & vbCrLf & "  3 - Hors service", APP_NAME, "1")
    Select Case t
        Case "1": etat = "Bon"
        Case "2": etat = "À réparer"
        Case "3": etat = "Hors service"
        Case Else: Exit Sub
    End Select
    If etat <> "Bon" Then
        s = Replace(InputBox("Montant retenu sur la caution pour les dégâts (FCFA) :", APP_NAME, "0"), " ", "")
        If IsNumeric(s) Then retenue = CDbl(s)
    End If
    If RetourLocationInterne(num, etat, retenue, Trim$(InputBox("Observations au retour :", APP_NAME))) Then
        MsgBox "Retour enregistré. Le Secrétaire aux Finances peut restituer la caution" & IIf(retenue > 0, " (moins la retenue de " & Fcfa(retenue) & ")", "") & ".", vbInformation, APP_NAME
    Else
        MsgBox G_LastError, vbExclamation, APP_NAME
    End If
End Sub

Public Function RetourLocationInterne(ByVal num As String, ByVal etat As String, ByVal retenue As Double, ByVal obs As String) As Boolean
    Dim ms As Worksheet, sh As Worksheet, k As Long, r As Long, br As Long
    G_LastError = ""
    If LocStatut(num) <> "En cours" Then G_LastError = "Le matériel de cette location n'est pas sorti (statut : " & LocStatut(num) & ").": Exit Function
    Set ms = WS(SH_MOUV)
    Set sh = WS(SH_LOCATIONS)
    r = LocationRow(num)
    If retenue < 0 Or retenue > NumV(sh.Cells(r, LC("Caution (FCFA)")).Value) Then G_LastError = "La retenue ne peut pas dépasser la caution.": Exit Function
    BeginWork
    For k = FIRSTROW To LastRow(ms, 1)
        If CStr(ms.Cells(k, MV_CONTRAT).Value) = num And CStr(ms.Cells(k, MV_STATUT).Value) = "En cours" Then
            ms.Cells(k, MV_STATUT).Value = "Clos"
            ms.Cells(k, MV_REFF).Value = Date
            ms.Cells(k, MV_ERET).Value = etat
            If etat <> "Bon" Then
                br = BienRow(CStr(ms.Cells(k, MV_CODE).Value))
                If br > 0 Then WS(SH_PAT).Cells(br, ColOf(WS(SH_PAT), "État")).Value = etat
            End If
        End If
    Next k
    sh.Cells(r, LC("Retenue (FCFA)")).Value = retenue
    If obs <> "" Then sh.Cells(r, LC("Observations")).Value = obs
    SetLocStatut num, "Rendue"
    EndWork
    RecalculerPatrimoineInterne Date
    LogAction "Retour de location", num & " : " & etat & IIf(retenue > 0, ", retenue " & Fcfa(retenue), ""), SH_LOCATIONS
    RetourLocationInterne = True
End Function

Public Sub RestituerCaution()
    Dim num As String, caisse As String
    If Not RequireLogin() Then Exit Sub
    num = LocationSelectionnee()
    If LocationRow(num) = 0 Then Exit Sub
    caisse = ChoisirCaisse("Restitution de la caution")
    If caisse = "" Then Exit Sub
    If RestituerCautionInterne(num, caisse) Then
        MsgBox "Caution restituée ; location " & num & " clôturée.", vbInformation, APP_NAME
    Else
        MsgBox G_LastError, vbExclamation, APP_NAME
    End If
End Sub

' Restitue la caution moins la retenue ; la retenue devient une indemnite (recette)
Public Function RestituerCautionInterne(ByVal num As String, ByVal caisse As String) As Boolean
    Dim sh As Worksheet, r As Long, caution As Double, retenue As Double, loc As String, p As String
    G_LastError = ""
    If ModuleRight("FINANCES") <> "M" Then G_LastError = "La restitution est réservée au Secrétaire aux Finances (ou à son intérimaire).": Exit Function
    If LocStatut(num) <> "Rendue" Then G_LastError = "Le matériel doit d'abord être rendu (statut : " & LocStatut(num) & ").": Exit Function
    Set sh = WS(SH_LOCATIONS)
    r = LocationRow(num)
    caution = NumV(sh.Cells(r, LC("Caution (FCFA)")).Value)
    retenue = NumV(sh.Cells(r, LC("Retenue (FCFA)")).Value)
    loc = CStr(sh.Cells(r, LC("Locataire")).Value)
    On Error GoTo EH
    BeginWork
    If caution - retenue > 0 Then
        p = EnregistrerEcriture(Date, caisse, "Dépense", ParamStr("CODE_CAUTION_RENDUE", "D11.1"), "Restitution caution " & num, "", loc, num, _
                                caution - retenue, "Contrat " & num, "Validée", "", False)
    End If
    If retenue > 0 Then
        EnregistrerEcriture Date, caisse, "Dépense", ParamStr("CODE_CAUTION_RENDUE", "D11.1"), "Retenue sur caution " & num & " (dégâts)", "", loc, num, _
                            retenue, "Contrat " & num, "Validée", "", False
        EnregistrerEcriture Date, caisse, "Recette", ParamStr("CODE_INDEMNITE", "R05.2"), "Indemnité pour dégâts " & num, "", loc, num, _
                            retenue, "", "Validée", "", False
    End If
    sh.Cells(r, LC("Pièce restitution")).Value = p
    SetLocStatut num, "Clôturée"
    EndWork
    LogAction "Caution restituée", num & " : " & Fcfa(caution - retenue) & IIf(retenue > 0, ", retenue " & Fcfa(retenue), ""), SH_LOCATIONS
    RestituerCautionInterne = True
    Exit Function
EH:
    G_LastError = Err.Description
    EndWork
End Function

' ============================================================ contrat imprimable
Public Sub ImprimerContrat()
    Dim num As String
    If Not RequireLogin() Then Exit Sub
    num = LocationSelectionnee()
    If num = "" Then Exit Sub
    If RemplirContrat(num) Then
        ApercuFeuille SH_CONTRAT
    Else
        MsgBox "Contrat introuvable : " & num, vbExclamation, APP_NAME
    End If
End Sub

Public Sub ApercuFeuille(ByVal nom As String)
    On Error Resume Next
    If G_TestMode Then Exit Sub
    WS(nom).Activate
    WS(nom).PrintPreview
End Sub

Public Function RemplirContrat(ByVal num As String) As Boolean
    Dim cs As Worksheet, sh As Worksheet, ms As Worksheet, r As Long, k As Long, row As Long, cond As Variant, i As Long
    Set cs = WS(SH_CONTRAT)
    Set sh = WS(SH_LOCATIONS)
    Set ms = WS(SH_MOUV)
    r = LocationRow(num)
    If r = 0 Then Exit Function
    BeginWork
    cs.Range("A2:F60").ClearContents
    cs.Range("A6:F60").Borders.LineStyle = xlNone
    cs.Range("A6:F60").Font.Bold = False
    cs.Range("A1").Value = "  " & ParamStr("NOM_GROUPE")
    cs.Range("B3").Value = "CONTRAT DE LOCATION DE MATÉRIEL  N° " & num
    cs.Range("B4").Value = ParamStr("EGLISE") & "  ·  " & ParamStr("PAROISSE")
    cs.Range("B6").Value = "Entre :"
    cs.Range("C6").Value = ParamStr("NOM_GROUPE") & ", représentée par son Bureau (le bailleur)"
    cs.Range("B7").Value = "Et :"
    cs.Range("C7").Value = CStr(sh.Cells(r, LC("Locataire")).Value) & "  -  tél. " & CStr(sh.Cells(r, LC("Contact")).Value) & " (le locataire)"
    cs.Range("B8").Value = "Objet :"
    cs.Range("C8").Value = sh.Cells(r, LC("Objet")).Value
    cs.Range("B9").Value = "Période :"
    cs.Range("C9").Value = "du " & Format$(AsDate(sh.Cells(r, LC("Début")).Value), "dd/mm/yyyy") & " au " & Format$(AsDate(sh.Cells(r, LC("Fin")).Value), "dd/mm/yyyy") & _
                           " (" & sh.Cells(r, LC("Jours")).Value & " jour(s))"
    cs.Range("B6:B9").Font.Bold = True
    row = 11
    cs.Cells(row, 2).Value = "Code"
    cs.Cells(row, 3).Value = "Désignation"
    cs.Cells(row, 4).Value = "Quantité"
    cs.Cells(row, 5).Value = "État au départ"
    cs.Cells(row, 6).Value = "Montant (FCFA)"
    cs.Range(cs.Cells(row, 2), cs.Cells(row, 6)).Font.Bold = True
    For k = FIRSTROW To LastRow(ms, 1)
        If CStr(ms.Cells(k, MV_CONTRAT).Value) = num And CStr(ms.Cells(k, MV_STATUT).Value) <> "Annulé" Then
            row = row + 1
            cs.Cells(row, 2).Value = ms.Cells(k, MV_CODE).Value
            cs.Cells(row, 3).Value = ms.Cells(k, MV_DES).Value
            cs.Cells(row, 4).Value = ms.Cells(k, MV_QTE).Value
            cs.Cells(row, 5).Value = ms.Cells(k, MV_EDEP).Value
            cs.Cells(row, 6).Value = ms.Cells(k, MV_MONTANT).Value
            cs.Cells(row, 6).NumberFormat = "#,##0"
        End If
    Next k
    cs.Range(cs.Cells(11, 2), cs.Cells(row, 6)).Borders.LineStyle = xlContinuous
    row = row + 2
    cs.Cells(row, 2).Value = "Loyer total :"
    cs.Cells(row, 3).Value = Fcfa(NumV(sh.Cells(r, LC("Montant location (FCFA)")).Value)) & "  (" & EnLettres(NumV(sh.Cells(r, LC("Montant location (FCFA)")).Value)) & " francs CFA)"
    cs.Cells(row + 1, 2).Value = "Caution :"
    cs.Cells(row + 1, 3).Value = Fcfa(NumV(sh.Cells(r, LC("Caution (FCFA)")).Value)) & "  (" & EnLettres(NumV(sh.Cells(r, LC("Caution (FCFA)")).Value)) & " francs CFA)"
    cs.Cells(row + 2, 2).Value = "Avis :"
    cs.Cells(row + 2, 3).Value = "Commission musicale : " & CStr(sh.Cells(r, LC("Avis commission musicale")).Value) & "   -   Bureau : " & CStr(sh.Cells(r, LC("Accord du Bureau")).Value)
    cs.Range(cs.Cells(row, 2), cs.Cells(row + 2, 2)).Font.Bold = True
    row = row + 4
    cs.Cells(row, 2).Value = "Conditions"
    cs.Cells(row, 2).Font.Bold = True
    cond = Array("1. Le matériel est remis en bon état de marche, constaté contradictoirement au départ et au retour.", _
                 "2. Le locataire en assure la garde, le transport et l'utilisation conforme ; il ne peut pas le sous-louer.", _
                 "3. Tout dégât, perte ou vol est à la charge du locataire : le coût est retenu sur la caution, le surplus restant dû.", _
                 "4. Le matériel est rendu à la date de fin convenue ; chaque jour de retard est facturé au tarif journalier.", _
                 "5. La caution est restituée après contrôle du matériel au retour.", _
                 "6. Location approuvée par le Bureau après avis de la Commission musicale (règlement intérieur, art. 30).")
    For i = 0 To UBound(cond)
        cs.Cells(row + 1 + i, 2).Value = cond(i)
    Next i
    row = row + UBound(cond) + 3
    cs.Cells(row, 2).Value = "Fait à " & ParamStr("VILLE", "Pointe-Noire") & ", le " & Format$(Date, "dd/mm/yyyy")
    cs.Cells(row + 2, 2).Value = "Pour la chorale (Secrétaire aux Patrimoines)"
    cs.Cells(row + 2, 5).Value = "Le locataire"
    cs.Range(cs.Cells(row + 2, 2), cs.Cells(row + 2, 5)).Font.Bold = True
    EndWork
    RemplirContrat = True
End Function

' Locations en attente d'une action (demande, approuvee, payee) ou materiel non rendu a temps
Public Function LocationsEnAttente() As Long
    Dim sh As Worksheet, r As Long, st As String
    Set sh = WS(SH_LOCATIONS)
    For r = FIRSTROW To LastRow(sh, 1)
        st = CStr(sh.Cells(r, LC("Statut")).Value)
        If st = "Demande" Or st = "Approuvée" Or st = "Payée" Or st = "Rendue" Then LocationsEnAttente = LocationsEnAttente + 1
    Next r
End Function
