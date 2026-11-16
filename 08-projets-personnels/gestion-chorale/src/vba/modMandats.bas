Option Explicit
' =============================================================================
' modMandats : mandats du Bureau et des commissions (art. 9 a 11), elections
' (art. 21 a 23) : scrutin, candidats, proclamation, mise en place des elus
' (mandats, fonction dans MEMBRES, titulaire du role et mot de passe), PV.
' Mandat de 2 ans renouvelable une fois : un 3e mandat consecutif est signale.
' =============================================================================

Public Const SH_MANDATS As String = "MANDATS"
Public Const SH_SCRUTINS As String = "SCRUTINS"
Public Const SH_CAND As String = "CANDIDATS"
Public Const SH_PV As String = "PV_ELECTION"
Public Const MDP_PROVISOIRE As String = "chorale"

Private Function MC(ByVal entete As String) As Long
    MC = ColOf(WS(SH_MANDATS), entete)
End Function

' Role de connexion correspondant a une fonction du Bureau ("" si aucun)
Public Function RoleDeFonction(ByVal fonction As String) As String
    Select Case Trim$(fonction)
        Case "1er Responsable": RoleDeFonction = "RESP1"
        Case "Vice-Responsable": RoleDeFonction = "VICE"
        Case "Secrétaire Général": RoleDeFonction = "SG"
        Case "Secrétaire Général Adjoint": RoleDeFonction = "SGA"
        Case "Secrétaire aux Finances": RoleDeFonction = "FIN"
        Case "Secrétaire aux Patrimoines": RoleDeFonction = "PAT"
        Case "Directeur de chœur": RoleDeFonction = "DIR"
        Case Else
            If InStr(1, fonction, "vangélisation", vbTextCompare) > 0 Then RoleDeFonction = "EVA"
    End Select
End Function

Public Function ScrutinRow(ByVal num As String) As Long
    Dim sh As Worksheet, r As Long
    If num = "" Then Exit Function
    Set sh = WS(SH_SCRUTINS)
    For r = FIRSTROW To LastRow(sh, 1)
        If StrComp(CStr(sh.Cells(r, 1).Value), num, vbTextCompare) = 0 Then
            ScrutinRow = r
            Exit Function
        End If
    Next r
End Function

Private Function NextNum(ByVal sh As Worksheet, ByVal pre As String, ByVal fmt As String) As String
    Dim r As Long, v As String, n As Long, mx As Long
    For r = FIRSTROW To LastRow(sh, 1)
        v = CStr(sh.Cells(r, 1).Value)
        If Left$(v, Len(pre)) = pre Then
            n = CLng(Val(Mid$(v, Len(pre) + 1)))
            If n > mx Then mx = n
        End If
    Next r
    NextNum = pre & Format$(mx + 1, fmt)
End Function

Private Function ScrutinSelectionne() As String
    If ActiveSheet.Name = SH_SCRUTINS And ActiveCell.Row >= FIRSTROW Then ScrutinSelectionne = CStr(WS(SH_SCRUTINS).Cells(ActiveCell.Row, 1).Value)
    If ActiveSheet.Name = SH_CAND And ActiveCell.Row >= FIRSTROW Then ScrutinSelectionne = CStr(WS(SH_CAND).Cells(ActiveCell.Row, 1).Value)
    If ActiveSheet.Name = SH_PV Then ScrutinSelectionne = Trim$(CStr(WS(SH_PV).Range("H1").Value))
    If ScrutinSelectionne = "" Then ScrutinSelectionne = UCase$(Trim$(InputBox("N° du scrutin (ex. EL-2027-01) :", APP_NAME)))
End Function

' ------------------------------------------------------------ mandats
' Rang du mandat : 1 + rang du mandat precedent de la meme personne a la meme fonction
' s'il s'est termine dans les 90 jours precedant le debut (mandats consecutifs)
Public Function RangMandat(ByVal mat As String, ByVal fonction As String, ByVal debut As Date) As Long
    Dim sh As Worksheet, v As Variant, n As Long, i As Long, df As Date, rg As Long, cM As Long, cF As Long, cFin As Long, cR As Long
    Set sh = WS(SH_MANDATS)
    cM = MC("Matricule"): cF = MC("Fonction"): cFin = MC("Fin"): cR = MC("Rang")
    n = ReadBlock(sh, 1, v)
    RangMandat = 1
    For i = 1 To n
        If StrComp(CStr(v(i, cM)), mat, vbTextCompare) = 0 And StrComp(CStr(v(i, cF)), fonction, vbTextCompare) = 0 Then
            df = AsDate(v(i, cFin))
            If df > 0 And df < debut And df >= debut - 90 Then
                rg = CLng(NumV(v(i, cR)))
                If rg < 1 Then rg = 1
                If rg + 1 > RangMandat Then RangMandat = rg + 1
            End If
        End If
    Next i
End Function

Public Function FinMandat(ByVal debut As Date) As Date
    FinMandat = AjouterMois(debut, 12 * ParamNum("DUREE_MANDAT_ANS", 2)) - 1
End Function

' Mandat en cours a une fonction (ligne de MANDATS, 0 si poste vacant)
Public Function MandatEnCours(ByVal fonction As String) As Long
    Dim sh As Worksheet, r As Long
    Set sh = WS(SH_MANDATS)
    For r = FIRSTROW To LastRow(sh, 1)
        If StrComp(CStr(sh.Cells(r, MC("Fonction")).Value), fonction, vbTextCompare) = 0 And CStr(sh.Cells(r, MC("Statut")).Value) = "En cours" Then
            MandatEnCours = r
            Exit Function
        End If
    Next r
End Function

Public Sub NouveauMandat()
    Dim fonction As String, mat As String, sd As String, d As Date, orga As String, num As String, avert As String
    If Not RequireEdit(SH_MANDATS) Then Exit Sub
    fonction = Trim$(InputBox("Fonction (ex. Secrétaire aux Finances, Président de la commission musicale) :", APP_NAME))
    If fonction = "" Then Exit Sub
    mat = UCase$(Trim$(InputBox("Matricule du titulaire :", APP_NAME)))
    If mat = "" Then Exit Sub
    sd = InputBox("Début du mandat (jj/mm/aaaa) :", APP_NAME, Format$(Date, "dd/mm/yyyy"))
    If Not IsDate(sd) Then Exit Sub
    d = CDate(sd)
    orga = IIf(RoleDeFonction(fonction) <> "" Or InStr(1, fonction, "Conseiller", vbTextCompare) > 0, "Bureau", "Commission")
    num = InstallerMandat(orga, fonction, mat, d, "Désigné par le Bureau", "", avert)
    If num = "" Then
        MsgBox G_LastError, vbExclamation, APP_NAME
    Else
        MsgBox "Mandat " & num & " enregistré jusqu'au " & Format$(FinMandat(d), "dd/mm/yyyy") & "." & IIf(avert <> "", vbCrLf & vbCrLf & avert, ""), _
               IIf(avert <> "", vbExclamation, vbInformation), APP_NAME
    End If
End Sub

' Met en place un titulaire : clot le mandat en cours a la fonction, cree le nouveau,
' met a jour la fonction dans MEMBRES et, pour le Bureau, le titulaire du role
' (mot de passe reinitialise si le titulaire change). Renvoie le N° du mandat.
Public Function InstallerMandat(ByVal orga As String, ByVal fonction As String, ByVal mat As String, ByVal debut As Date, _
                                ByVal designation As String, ByVal scrutin As String, ByRef avert As String) As String
    Dim sh As Worksheet, ms As Worksheet, r As Long, old As Long, rg As Long, num As String, nom As String, mr As Long
    Dim oldMat As String, omr As Long, cFo As Long
    G_LastError = ""
    avert = ""
    mr = MembreRow(mat)
    If mr = 0 Then
        G_LastError = "Matricule inconnu : " & mat
        Exit Function
    End If
    Set sh = WS(SH_MANDATS)
    Set ms = WS(SH_MEMBRES)
    nom = NomComplet(MembreValeur(mat, "Nom"), MembreValeur(mat, "Prénoms"))
    rg = RangMandat(mat, fonction, debut)
    If rg > ParamNum("MANDATS_CONSECUTIFS_MAX", 2) Then
        avert = "Attention : " & nom & " commence un " & rg & "e mandat consécutif comme " & fonction & _
                " (art. 11 : mandat renouvelable une seule fois)."
    End If
    BeginWork
    old = MandatEnCours(fonction)
    If old > 0 Then
        oldMat = CStr(sh.Cells(old, MC("Matricule")).Value)
        sh.Cells(old, MC("Statut")).Value = "Terminé"
        If AsDate(sh.Cells(old, MC("Fin")).Value) = 0 Or AsDate(sh.Cells(old, MC("Fin")).Value) >= debut Then sh.Cells(old, MC("Fin")).Value = debut - 1
    End If
    num = NextNum(sh, "MAN-", "000")
    r = LastRow(sh, 1) + 1
    sh.Cells(r, 1).Value = num
    sh.Cells(r, MC("Organe")).Value = orga
    sh.Cells(r, MC("Fonction")).Value = fonction
    sh.Cells(r, MC("Matricule")).Value = mat
    sh.Cells(r, MC("Nom et prénoms")).Value = nom
    sh.Cells(r, MC("Début")).Value = debut
    sh.Cells(r, MC("Fin")).Value = FinMandat(debut)
    sh.Cells(r, MC("Rang")).Value = rg
    sh.Cells(r, MC("Désignation")).Value = designation
    sh.Cells(r, MC("Statut")).Value = "En cours"
    sh.Cells(r, MC("Scrutin")).Value = scrutin
    If avert <> "" Then sh.Cells(r, MC("Observations")).Value = rg & "e mandat consécutif (art. 11)"
    If orga = "Bureau" Then
        cFo = ColOf(ms, "Fonction au Bureau")
        If oldMat <> "" And StrComp(oldMat, mat, vbTextCompare) <> 0 Then
            omr = MembreRow(oldMat)
            If omr > 0 Then
                If CStr(ms.Cells(omr, cFo).Value) = fonction Then ms.Cells(omr, cFo).Value = ""
            End If
        End If
        ms.Cells(mr, cFo).Value = fonction
        ChangerTitulaire RoleDeFonction(fonction), nom
    End If
    EndWork
    LogAction "Mandat", num & " " & fonction & " : " & nom & " (rang " & rg & ")", SH_MANDATS
    InstallerMandat = num
End Function

' Nouveau titulaire d'un role : mot de passe provisoire a changer a la connexion
Public Sub ChangerTitulaire(ByVal code As String, ByVal nom As String)
    Dim us As Worksheet, r As Long
    If code = "" Then Exit Sub
    Set us = WS(SH_USERS)
    For r = FIRSTROW To LastRow(us, 1)
        If CStr(us.Cells(r, 1).Value) = code Then
            If StrComp(Trim$(CStr(us.Cells(r, ColOf(us, "Titulaire")).Value)), nom, vbTextCompare) <> 0 Then
                us.Cells(r, ColOf(us, "Titulaire")).Value = nom
                StorePassword code, MDP_PROVISOIRE
                us.Cells(r, ColOf(us, "Doit changer le mot de passe")).Value = "OUI"
                LogAction "Nouveau titulaire", RoleLabel(code) & " : " & nom & " (mot de passe provisoire)", SH_USERS
            End If
            Exit Sub
        End If
    Next r
End Sub

Public Sub TerminerMandat()
    Dim sh As Worksheet, r As Long, rep As String
    If Not RequireEdit(SH_MANDATS) Then Exit Sub
    Set sh = WS(SH_MANDATS)
    If ActiveSheet.Name <> SH_MANDATS Or ActiveCell.Row < FIRSTROW Then
        MsgBox "Sélectionnez d'abord la ligne du mandat.", vbInformation, APP_NAME
        Exit Sub
    End If
    r = ActiveCell.Row
    If CStr(sh.Cells(r, MC("Statut")).Value) <> "En cours" Then Exit Sub
    rep = InputBox("Fin anticipée du mandat " & sh.Cells(r, 1).Value & " (" & sh.Cells(r, MC("Nom et prénoms")).Value & ") :" & vbCrLf & _
                   "  1 - Démission" & vbCrLf & "  2 - Révoqué" & vbCrLf & "  3 - Terminé", APP_NAME, "1")
    If rep <> "1" And rep <> "2" And rep <> "3" Then Exit Sub
    BeginWork
    sh.Cells(r, MC("Statut")).Value = Choose(CLng(rep), "Démission", "Révoqué", "Terminé")
    sh.Cells(r, MC("Fin")).Value = Date
    EndWork
    LogAction "Fin de mandat", sh.Cells(r, 1).Value & " : " & sh.Cells(r, MC("Statut")).Value, SH_MANDATS
    MsgBox "Poste de " & sh.Cells(r, MC("Fonction")).Value & " vacant : prévoyez une élection partielle (art. 23).", vbInformation, APP_NAME
End Sub

' ------------------------------------------------------------ scrutins
Public Sub NouveauScrutin()
    Dim sd As String, d As Date, typ As String, postes As String, num As String
    If Not RequireEdit(SH_SCRUTINS) Then Exit Sub
    sd = InputBox("Date de l'élection (jj/mm/aaaa) :", APP_NAME, Format$(Date, "dd/mm/yyyy"))
    If Not IsDate(sd) Then Exit Sub
    d = CDate(sd)
    typ = IIf(MsgBox("Élection de tout le Bureau (Oui) ou élection partielle (Non) ?", vbYesNo + vbQuestion, APP_NAME) = vbYes, "Ordinaire", "Partielle")
    If typ = "Partielle" Then
        postes = InputBox("Postes à pourvoir (séparés par ;) :", APP_NAME, PostesVacants())
        If postes = "" Then Exit Sub
    End If
    num = NouveauScrutinInterne(d, typ, postes)
    MsgBox "Scrutin " & num & " créé. Ajoutez les candidats (feuille CANDIDATS), saisissez les voix puis proclamez les résultats.", vbInformation, APP_NAME
End Sub

Public Function FonctionsBureau() As Collection
    Set FonctionsBureau = ListValues("Fonction au Bureau")
End Function

Public Function PostesVacants() As String
    Dim f As Collection, i As Long
    Set f = FonctionsBureau()
    For i = 1 To f.Count
        If RoleDeFonction(f(i)) <> "" And RoleDeFonction(f(i)) <> "DIR" Then
            If MandatEnCours(f(i)) = 0 Then PostesVacants = PostesVacants & IIf(PostesVacants = "", "", "; ") & f(i)
        End If
    Next i
End Function

Public Function NouveauScrutinInterne(ByVal d As Date, ByVal typ As String, ByVal postes As String) As String
    Dim sh As Worksheet, r As Long, num As String, f As Collection, i As Long, inscrits As Long
    Set sh = WS(SH_SCRUTINS)
    If postes = "" Then
        Set f = FonctionsBureau()
        For i = 1 To f.Count
            If RoleDeFonction(f(i)) <> "" And RoleDeFonction(f(i)) <> "DIR" Then postes = postes & IIf(postes = "", "", "; ") & f(i)
        Next i
    End If
    inscrits = LastRow(WS(SH_ELEC), 2, OUT_HDR) - OUT_HDR
    BeginWork
    num = NextNum(sh, "EL-" & Year(d) & "-", "00")
    r = LastRow(sh, 1) + 1
    sh.Cells(r, 1).Value = num
    sh.Cells(r, 2).Value = d
    sh.Cells(r, 3).Value = typ
    sh.Cells(r, 4).Value = postes
    If inscrits > 0 Then sh.Cells(r, 5).Value = inscrits
    sh.Cells(r, 7).Value = "Préparation"
    EndWork
    LogAction "Scrutin", num & " " & typ & " : " & postes, SH_SCRUTINS
    NouveauScrutinInterne = num
End Function

Public Sub AjouterCandidat()
    Dim num As String, poste As String, mat As String, avert As String, postes() As String, i As Long, txt As String, rep As String, pl As String
    If Not RequireEdit(SH_CAND) Then Exit Sub
    num = ScrutinSelectionne()
    If ScrutinRow(num) = 0 Then Exit Sub
    pl = CStr(WS(SH_SCRUTINS).Cells(ScrutinRow(num), 4).Value)
    postes = Split(pl, ";")
    For i = LBound(postes) To UBound(postes)
        txt = txt & vbCrLf & "  " & (i + 1) & " - " & Trim$(postes(i))
    Next i
    rep = InputBox("Poste :" & txt, APP_NAME, "1")
    If Not IsNumeric(rep) Then Exit Sub
    If CLng(rep) < 1 Or CLng(rep) > UBound(postes) + 1 Then Exit Sub
    poste = Trim$(postes(CLng(rep) - 1))
    mat = UCase$(Trim$(InputBox("Matricule du candidat au poste de " & poste & " :", APP_NAME)))
    If mat = "" Then Exit Sub
    If AjouterCandidatInterne(num, poste, mat, avert) Then
        If avert <> "" Then
            MsgBox "Candidat enregistré." & vbCrLf & vbCrLf & avert, vbExclamation, APP_NAME
        Else
            MsgBox "Candidat enregistré.", vbInformation, APP_NAME
        End If
    Else
        MsgBox G_LastError, vbExclamation, APP_NAME
    End If
End Sub

Public Function AjouterCandidatInterne(ByVal num As String, ByVal poste As String, ByVal mat As String, ByRef avert As String) As Boolean
    Dim cs As Worksheet, r As Long, st As String, sr As Long, rg As Long, k As Long
    G_LastError = ""
    avert = ""
    sr = ScrutinRow(num)
    If sr = 0 Then
        G_LastError = "Scrutin introuvable : " & num
        Exit Function
    End If
    If CStr(WS(SH_SCRUTINS).Cells(sr, 7).Value) = "Proclamé" Then
        G_LastError = "Les résultats de ce scrutin sont déjà proclamés."
        Exit Function
    End If
    If MembreRow(mat) = 0 Then
        G_LastError = "Matricule inconnu : " & mat
        Exit Function
    End If
    st = CStr(MembreValeur(mat, "Statut"))
    If st <> ST_CONF Then
        G_LastError = "Seul un choriste confirmé peut être candidat (statut actuel : " & st & ")."
        Exit Function
    End If
    Set cs = WS(SH_CAND)
    For k = FIRSTROW To LastRow(cs, 1)
        If CStr(cs.Cells(k, 1).Value) = num And CStr(cs.Cells(k, 3).Value) = mat And CStr(cs.Cells(k, 2).Value) = poste Then
            G_LastError = "Ce membre est déjà candidat à ce poste."
            Exit Function
        End If
    Next k
    rg = RangMandat(mat, poste, AsDate(WS(SH_SCRUTINS).Cells(sr, 2).Value) + 1)
    If MandatEnCours(poste) > 0 Then
        If CStr(WS(SH_MANDATS).Cells(MandatEnCours(poste), MC("Matricule")).Value) = mat Then
            rg = CLng(NumV(WS(SH_MANDATS).Cells(MandatEnCours(poste), MC("Rang")).Value)) + 1
        End If
    End If
    BeginWork
    r = LastRow(cs, 1) + 1
    cs.Cells(r, 1).Value = num
    cs.Cells(r, 2).Value = poste
    cs.Cells(r, 3).Value = mat
    cs.Cells(r, 4).Value = NomComplet(MembreValeur(mat, "Nom"), MembreValeur(mat, "Prénoms"))
    cs.Cells(r, 6).Value = ""
    If rg > ParamNum("MANDATS_CONSECUTIFS_MAX", 2) Then
        avert = "Attention : s'il est élu, ce serait son " & rg & "e mandat consécutif à ce poste (art. 11 : mandat renouvelable une seule fois)."
        cs.Cells(r, 7).Value = "Serait un " & rg & "e mandat consécutif"
    End If
    EndWork
    LogAction "Candidat", num & " " & poste & " : " & mat, SH_CAND
    AjouterCandidatInterne = True
End Function

Public Sub ProclamerResultats()
    Dim num As String, rep As String, msg As String
    If Not RequireEdit(SH_SCRUTINS) Then Exit Sub
    num = ScrutinSelectionne()
    If ScrutinRow(num) = 0 Then Exit Sub
    rep = InputBox("Nombre de votants du scrutin " & num & " :", APP_NAME, CStr(WS(SH_SCRUTINS).Cells(ScrutinRow(num), 6).Value))
    If Not IsNumeric(rep) Then Exit Sub
    msg = ProclamerInterne(num, CLng(rep))
    If G_LastError <> "" Then
        MsgBox G_LastError, vbExclamation, APP_NAME
        Exit Sub
    End If
    If MsgBox("Résultats :" & vbCrLf & msg & vbCrLf & vbCrLf & "Mettre en place les élus maintenant ?" & vbCrLf & _
              "(mandats, fonctions des membres, titulaires des rôles ; les nouveaux titulaires recevront le mot de passe provisoire « " & MDP_PROVISOIRE & " »)", _
              vbYesNo + vbQuestion, APP_NAME) = vbYes Then
        rep = InputBox("Date de prise de fonction (jj/mm/aaaa) :", APP_NAME, Format$(AsDate(WS(SH_SCRUTINS).Cells(ScrutinRow(num), 2).Value), "dd/mm/yyyy"))
        If IsDate(rep) Then
            msg = InstallerElusInterne(num, CDate(rep))
            MsgBox msg, vbInformation, APP_NAME
        End If
    End If
End Sub

' Designe l'elu de chaque poste (le plus de voix). Renvoie le resume ; G_LastError si egalite ou voix manquantes.
Public Function ProclamerInterne(ByVal num As String, ByVal votants As Long) As String
    Dim cs As Worksheet, ss As Worksheet, sr As Long, postes() As String, i As Long, k As Long, best As Long, bestV As Double
    Dim egal As Boolean, bilan As String, v As Double, nb As Long, pl As String
    G_LastError = ""
    sr = ScrutinRow(num)
    If sr = 0 Then
        G_LastError = "Scrutin introuvable : " & num
        Exit Function
    End If
    Set cs = WS(SH_CAND)
    Set ss = WS(SH_SCRUTINS)
    pl = CStr(ss.Cells(sr, 4).Value)
    postes = Split(pl, ";")
    For i = LBound(postes) To UBound(postes)
        best = 0: bestV = -1: egal = False: nb = 0
        For k = FIRSTROW To LastRow(cs, 1)
            If CStr(cs.Cells(k, 1).Value) = num And CStr(cs.Cells(k, 2).Value) = Trim$(postes(i)) Then
                nb = nb + 1
                If CStr(cs.Cells(k, 5).Value) = "" Then
                    G_LastError = "Voix non saisies pour " & cs.Cells(k, 4).Value & " (" & Trim$(postes(i)) & ")."
                    Exit Function
                End If
                v = NumV(cs.Cells(k, 5).Value)
                If v > bestV Then
                    best = k: bestV = v: egal = False
                ElseIf v = bestV Then
                    egal = True
                End If
            End If
        Next k
        If nb > 0 And egal Then
            G_LastError = "Égalité de voix au poste de " & Trim$(postes(i)) & " : organisez un second tour (art. 22) puis saisissez les voix."
            Exit Function
        End If
        If nb = 0 Then
            bilan = bilan & vbCrLf & "  " & Trim$(postes(i)) & " : aucun candidat"
        Else
            bilan = bilan & vbCrLf & "  " & Trim$(postes(i)) & " : " & cs.Cells(best, 4).Value & " (" & bestV & " voix)"
        End If
    Next i
    BeginWork
    For k = FIRSTROW To LastRow(cs, 1)
        If CStr(cs.Cells(k, 1).Value) = num Then cs.Cells(k, 6).Value = "NON"
    Next k
    For i = LBound(postes) To UBound(postes)
        best = 0: bestV = -1
        For k = FIRSTROW To LastRow(cs, 1)
            If CStr(cs.Cells(k, 1).Value) = num And CStr(cs.Cells(k, 2).Value) = Trim$(postes(i)) Then
                If NumV(cs.Cells(k, 5).Value) > bestV Then best = k: bestV = NumV(cs.Cells(k, 5).Value)
            End If
        Next k
        If best > 0 Then cs.Cells(best, 6).Value = "OUI"
    Next i
    ss.Cells(sr, 6).Value = votants
    ss.Cells(sr, 7).Value = "Proclamé"
    EndWork
    LogAction "Résultats proclamés", num & " :" & Replace(bilan, vbCrLf, " |"), SH_SCRUTINS
    ProclamerInterne = Mid$(bilan, 3)
End Function

' Met en place les elus d'un scrutin proclame
Public Function InstallerElusInterne(ByVal num As String, ByVal debut As Date) As String
    Dim cs As Worksheet, k As Long, n As Long, avert As String, bilan As String, desig As String, m As String
    Set cs = WS(SH_CAND)
    desig = IIf(CStr(WS(SH_SCRUTINS).Cells(ScrutinRow(num), 3).Value) = "Partielle", "Élection partielle", "Élu en AG")
    For k = FIRSTROW To LastRow(cs, 1)
        If CStr(cs.Cells(k, 1).Value) = num And CStr(cs.Cells(k, 6).Value) = "OUI" Then
            m = InstallerMandat("Bureau", CStr(cs.Cells(k, 2).Value), CStr(cs.Cells(k, 3).Value), debut, desig, num, avert)
            If m <> "" Then n = n + 1
            If avert <> "" Then bilan = bilan & vbCrLf & avert
        End If
    Next k
    LogAction "Élus installés", num & " : " & n & " mandat(s)", SH_MANDATS
    InstallerElusInterne = n & " élu(s) mis en place à compter du " & Format$(debut, "dd/mm/yyyy") & "." & vbCrLf & _
        "Les nouveaux titulaires se connectent avec le mot de passe provisoire « " & MDP_PROVISOIRE & " » et doivent le changer." & bilan
End Function

' ------------------------------------------------------------ PV
Public Sub ImprimerPV()
    Dim num As String
    If Not RequireLogin() Then Exit Sub
    num = ScrutinSelectionne()
    If ScrutinRow(num) = 0 Then Exit Sub
    If RemplirPV(num) Then
        WS(SH_PV).Activate
        ImprimerFeuille
    End If
End Sub

Public Function RemplirPV(ByVal num As String) As Boolean
    Dim ps As Worksheet, ss As Worksheet, cs As Worksheet, sr As Long, k As Long, row As Long, ins As Double, vot As Double, r0 As Long
    Set ps = WS(SH_PV)
    Set ss = WS(SH_SCRUTINS)
    Set cs = WS(SH_CAND)
    sr = ScrutinRow(num)
    If sr = 0 Then Exit Function
    ins = NumV(ss.Cells(sr, 5).Value)
    vot = NumV(ss.Cells(sr, 6).Value)
    BeginWork
    ps.Range("A2:F60").ClearContents
    ps.Range("A2:F60").Font.Bold = False
    ps.Range("A2:F60").Borders.LineStyle = xlNone
    ps.Range("A1").Value = "  " & ParamStr("NOM_GROUPE")
    ps.Range("H1").Value = num
    ps.Range("H1").NumberFormat = ";;;"
    ps.Range("B2").Value = ParamStr("EGLISE") & "  ·  " & ParamStr("PAROISSE")
    ps.Range("B4").Value = "PROCÈS-VERBAL D'ÉLECTION  N° " & num
    ps.Range("B4").Font.Bold = True
    ps.Range("B6").Value = "Date :"
    ps.Range("C6").Value = Format$(AsDate(ss.Cells(sr, 2).Value), "dd/mm/yyyy") & " - élection " & LCase$(CStr(ss.Cells(sr, 3).Value)) & IIf(CStr(ss.Cells(sr, 3).Value) = "Partielle", " (art. 23)", " (art. 21 et 22)")
    ps.Range("B7").Value = "Électeurs inscrits :"
    ps.Range("C7").Value = ins
    ps.Range("B8").Value = "Votants :"
    ps.Range("C8").Value = vot
    ps.Range("B9").Value = "Participation :"
    If ins > 0 Then ps.Range("C9").Value = Format$(vot / ins, "0.0%")
    ps.Range("B6:B9").Font.Bold = True
    ps.Range("C7:C9").HorizontalAlignment = xlLeft
    row = 11
    r0 = row
    ps.Cells(row, 2).Value = "Poste"
    ps.Cells(row, 3).Value = "Candidat"
    ps.Cells(row, 4).Value = "Voix"
    ps.Cells(row, 5).Value = "% des votants"
    ps.Cells(row, 6).Value = "Élu"
    ps.Range(ps.Cells(row, 2), ps.Cells(row, 6)).Font.Bold = True
    For k = FIRSTROW To LastRow(cs, 1)
        If CStr(cs.Cells(k, 1).Value) = num Then
            row = row + 1
            ps.Cells(row, 2).Value = cs.Cells(k, 2).Value
            ps.Cells(row, 3).Value = cs.Cells(k, 4).Value
            ps.Cells(row, 4).Value = cs.Cells(k, 5).Value
            If vot > 0 Then ps.Cells(row, 5).Value = Format$(NumV(cs.Cells(k, 5).Value) / vot, "0.0%")
            ps.Cells(row, 6).Value = cs.Cells(k, 6).Value
            If CStr(cs.Cells(k, 6).Value) = "OUI" Then ps.Range(ps.Cells(row, 2), ps.Cells(row, 6)).Font.Bold = True
        End If
    Next k
    ps.Range(ps.Cells(r0, 2), ps.Cells(row, 6)).Borders.LineStyle = xlContinuous
    row = row + 2
    ps.Cells(row, 2).Value = "Les candidats ayant obtenu le plus de voix sont déclarés élus pour un mandat de " & ParamNum("DUREE_MANDAT_ANS", 2) & " ans (art. 11)."
    row = row + 2
    ps.Cells(row, 2).Value = "Fait à " & ParamStr("VILLE", "Pointe-Noire") & ", le " & Format$(Date, "dd/mm/yyyy")
    row = row + 2
    ps.Cells(row, 2).Value = "Le président de séance"
    ps.Cells(row, 5).Value = "Le secrétaire de séance"
    ps.Range(ps.Cells(row, 2), ps.Cells(row, 5)).Font.Bold = True
    ps.Cells(row + 5, 2).Value = "Le conseiller paroissial"
    ps.Cells(row + 5, 2).Font.Bold = True
    ss.Cells(sr, 8).Value = Date
    EndWork
    RemplirPV = True
End Function

' ------------------------------------------------------------ alertes
Public Sub AlertesMandats(ByVal lignes As Collection)
    Dim sh As Worksheet, v As Variant, n As Long, i As Long, df As Date, jours As Long, nFin As Long, nEchu As Long, n3 As Long
    Dim first As Date, vac As String, cS As Long, cF As Long, cR As Long
    Set sh = WS(SH_MANDATS)
    jours = ParamNum("JOURS_ALERTE_MANDAT", 90)
    cS = MC("Statut"): cF = MC("Fin"): cR = MC("Rang")
    n = ReadBlock(sh, 1, v)
    For i = 1 To n
        If CStr(v(i, cS)) = "En cours" Then
            df = AsDate(v(i, cF))
            If df > 0 And df < Date Then
                nEchu = nEchu + 1
            ElseIf df > 0 And df <= Date + jours Then
                nFin = nFin + 1
                If first = 0 Or df < first Then first = df
            End If
            If NumV(v(i, cR)) > ParamNum("MANDATS_CONSECUTIFS_MAX", 2) Then n3 = n3 + 1
        End If
    Next i
    If nFin > 0 Then lignes.Add "Mandats : " & nFin & " mandat(s) se terminent d'ici le " & Format$(Date + jours, "dd/mm/yyyy") & " (premier le " & Format$(first, "dd/mm/yyyy") & ") : préparez l'AG élective et la liste électorale."
    If nEchu > 0 Then lignes.Add "Mandats : " & nEchu & " mandat(s) échu(s) toujours « En cours » : organisez l'élection (feuille SCRUTINS)."
    If n3 > 0 Then lignes.Add "Mandats : " & n3 & " titulaire(s) au-delà de " & ParamNum("MANDATS_CONSECUTIFS_MAX", 2) & " mandats consécutifs (art. 11)."
    If n > 0 Then
        vac = PostesVacants()
        If vac <> "" Then lignes.Add "Mandats : poste(s) vacant(s) au Bureau : " & vac & " (élection partielle, art. 23)."
    End If
End Sub
