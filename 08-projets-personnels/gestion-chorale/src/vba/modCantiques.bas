Option Explicit
' =============================================================================
' modCantiques : repertoire des cantiques et apprentissage par pupitre,
' programmes des chants par celebration (alerte si un chant a ete chante il y
' a moins de SEMAINES_REPETITION_CHANT semaines ou n'est pas maitrise),
' programme imprimable, etudes bibliques et affermissement (art. 16-7).
' =============================================================================

Public Const SH_CANT As String = "CANTIQUES"
Public Const SH_PROGS As String = "PROGRAMMES"
Public Const SH_PROGCH As String = "PROGRAMME_CHANTS"
Public Const SH_ETUDES As String = "ETUDES"
Public Const NIV_OK As String = "Maîtrisé"
Public Const NIV_EN_COURS As String = "En apprentissage"
Public Const NIV_ZERO As String = "Non commencé"

Private Function CC(ByVal entete As String) As Long
    CC = ColOf(WS(SH_CANT), entete)
End Function

Private Function GC(ByVal entete As String) As Long
    GC = ColOf(WS(SH_PROGS), entete)
End Function

Public Function CantiqueRow(ByVal num As String) As Long
    Dim sh As Worksheet, r As Long
    If num = "" Then Exit Function
    Set sh = WS(SH_CANT)
    For r = FIRSTROW To LastRow(sh, 1)
        If StrComp(CStr(sh.Cells(r, 1).Value), num, vbTextCompare) = 0 Then
            CantiqueRow = r
            Exit Function
        End If
    Next r
End Function

Private Function CantiqueParTitre(ByVal titre As String) As Long
    Dim sh As Worksheet, r As Long
    Set sh = WS(SH_CANT)
    For r = FIRSTROW To LastRow(sh, 1)
        If StrComp(Trim$(CStr(sh.Cells(r, CC("Titre")).Value)), Trim$(titre), vbTextCompare) = 0 Then
            CantiqueParTitre = r
            Exit Function
        End If
    Next r
End Function

Private Function NextCantique() As String
    Dim sh As Worksheet, r As Long, v As String, n As Long, mx As Long
    Set sh = WS(SH_CANT)
    For r = FIRSTROW To LastRow(sh, 1)
        v = CStr(sh.Cells(r, 1).Value)
        If Left$(v, 4) = "CAN-" Then
            n = CLng(Val(Mid$(v, 5)))
            If n > mx Then mx = n
        End If
    Next r
    NextCantique = "CAN-" & Format$(mx + 1, "000")
End Function

' Niveau du choeur : maitrise si les 4 pupitres le maitrisent, non commence si aucun n'a commence
Public Function NiveauGlobal(ByVal s As String, ByVal a As String, ByVal t As String, ByVal b As String) As String
    Dim nOk As Long, nZero As Long, x As Variant
    For Each x In Array(s, a, t, b)
        If CStr(x) = NIV_OK Then nOk = nOk + 1
        If CStr(x) = NIV_ZERO Or CStr(x) = "" Then nZero = nZero + 1
    Next x
    If nOk = 4 Then
        NiveauGlobal = NIV_OK
    ElseIf nZero = 4 Then
        NiveauGlobal = NIV_ZERO
    Else
        NiveauGlobal = NIV_EN_COURS
    End If
End Function

Private Sub CompleterCantique(ByVal sh As Worksheet, ByVal r As Long)
    Dim p As Variant
    If CStr(sh.Cells(r, CC("Titre")).Value) = "" Then Exit Sub
    If CStr(sh.Cells(r, 1).Value) = "" Then sh.Cells(r, 1).Value = NextCantique()
    For Each p In Array("Soprano", "Alto", "Ténor", "Basse")
        If CStr(sh.Cells(r, CC(CStr(p))).Value) = "" Then sh.Cells(r, CC(CStr(p))).Value = NIV_ZERO
    Next p
    sh.Cells(r, CC("Niveau")).Value = NiveauGlobal(CStr(sh.Cells(r, CC("Soprano")).Value), CStr(sh.Cells(r, CC("Alto")).Value), _
                                                   CStr(sh.Cells(r, CC("Ténor")).Value), CStr(sh.Cells(r, CC("Basse")).Value))
End Sub

Public Sub OnCantiquesChange(ByVal Target As Range)
    Dim sh As Worksheet, rw As Range, n As Long
    On Error GoTo Fin
    Set sh = Target.Worksheet
    Application.EnableEvents = False
    For Each rw In Target.Rows
        n = n + 1
        If n > 500 Then Exit For
        If rw.Row >= FIRSTROW Then CompleterCantique sh, rw.Row
    Next rw
Fin:
    Application.EnableEvents = True
End Sub

Public Sub NouveauCantique()
    Dim sh As Worksheet, r As Long, titre As String
    If Not RequireEdit(SH_CANT) Then Exit Sub
    titre = Trim$(InputBox("Titre du cantique :", APP_NAME))
    If titre = "" Then Exit Sub
    If CantiqueParTitre(titre) > 0 Then
        MsgBox "Ce titre est déjà au répertoire (" & WS(SH_CANT).Cells(CantiqueParTitre(titre), 1).Value & ").", vbInformation, APP_NAME
        Exit Sub
    End If
    Set sh = WS(SH_CANT)
    BeginWork
    r = LastRow(sh, 1) + 1
    sh.Cells(r, CC("Titre")).Value = titre
    CompleterCantique sh, r
    EndWork
    LogAction "Cantique ajouté", sh.Cells(r, 1).Value & " " & titre, SH_CANT
    sh.Cells(r, CC("Recueil")).Select
End Sub

' ------------------------------------------------------------ apprentissage et historique
Public Sub ActualiserRepertoire()
    If Not RequireLogin() Then Exit Sub
    ActualiserRepertoireInterne Date
    MsgBox "Répertoire actualisé : niveaux, dernière exécution et nombre d'exécutions sur 12 mois." & vbCrLf & vbCrLf & ResumeApprentissage(), vbInformation, APP_NAME
End Sub

Public Sub ActualiserRepertoireInterne(ByVal asOf As Date)
    Dim sh As Worksheet, gs As Worksheet, v As Variant, n As Long, i As Long, r As Long, idx As New Collection, num As String
    Dim d As Date, d0 As Date, cD As Long, cN As Long, cDe As Long, cEx As Long, lr As Long
    Set sh = WS(SH_CANT)
    Set gs = WS(SH_PROGS)
    cDe = CC("Dernière exécution"): cEx = CC("Exécutions (12 mois)")
    cD = GC("Date"): cN = GC("N° cantique")
    d0 = AjouterMois(asOf, -12)
    BeginWork
    lr = LastRow(sh, 1)
    For r = FIRSTROW To lr
        num = UCase$(CStr(sh.Cells(r, 1).Value))
        If num <> "" Then
            If Not KeyExists(idx, num) Then idx.Add r, num
            CompleterCantique sh, r
            sh.Cells(r, cDe).Value = ""
            sh.Cells(r, cEx).Value = 0
        End If
    Next r
    n = ReadBlock(gs, 1, v)
    For i = 1 To n
        num = UCase$(CStr(v(i, cN)))
        d = AsDate(v(i, cD))
        If num <> "" And d > 0 And d <= asOf Then
            If KeyExists(idx, num) Then
                r = idx(num)
                If d > AsDate(sh.Cells(r, cDe).Value) Then sh.Cells(r, cDe).Value = d
                If d > d0 Then sh.Cells(r, cEx).Value = NumV(sh.Cells(r, cEx).Value) + 1
            End If
        End If
    Next i
    If lr >= FIRSTROW Then sh.Range(sh.Cells(FIRSTROW, cDe), sh.Cells(lr, cDe)).NumberFormat = "dd/mm/yyyy"
    EndWork
End Sub

' Maitrise des cantiques par pupitre (texte pour l'utilisateur)
Public Function ResumeApprentissage() As String
    Dim sh As Worksheet, v As Variant, n As Long, i As Long, p As Variant, c As Long, nOk As Long, nEn As Long, tot As Long
    Set sh = WS(SH_CANT)
    n = ReadBlock(sh, 1, v)
    For i = 1 To n
        If CStr(v(i, 1)) <> "" Then tot = tot + 1
    Next i
    ResumeApprentissage = "Apprentissage par pupitre (" & tot & " cantiques) :"
    For Each p In Array("Soprano", "Alto", "Ténor", "Basse")
        c = CC(CStr(p))
        nOk = 0: nEn = 0
        For i = 1 To n
            If CStr(v(i, 1)) <> "" Then
                If CStr(v(i, c)) = NIV_OK Then nOk = nOk + 1
                If CStr(v(i, c)) = NIV_EN_COURS Then nEn = nEn + 1
            End If
        Next i
        ResumeApprentissage = ResumeApprentissage & vbCrLf & "  " & p & " : " & nOk & " maîtrisé(s), " & nEn & " en apprentissage, " & (tot - nOk - nEn) & " non commencé(s)"
    Next p
End Function

' ------------------------------------------------------------ programmes des chants
' Remarque de controle d'un chant programme a une date ("" si rien a signaler)
Public Function ControleChant(ByVal num As String, ByVal d As Date) As String
    Dim gs As Worksheet, v As Variant, n As Long, i As Long, dd As Date, sem As Long, proche As Date, cr As Long, niv As String
    Dim cD As Long, cN As Long
    Set gs = WS(SH_PROGS)
    sem = ParamNum("SEMAINES_REPETITION_CHANT", 4)
    cD = GC("Date"): cN = GC("N° cantique")
    n = ReadBlock(gs, 1, v)
    For i = 1 To n
        If StrComp(CStr(v(i, cN)), num, vbTextCompare) = 0 Then
            dd = AsDate(v(i, cD))
            If dd > 0 And dd <> d And Abs(dd - d) < sem * 7 Then
                If proche = 0 Or Abs(dd - d) < Abs(proche - d) Then proche = dd
            End If
        End If
    Next i
    If proche > 0 Then ControleChant = IIf(proche < d, "Déjà chanté le ", "Aussi programmé le ") & Format$(proche, "dd/mm/yyyy") & " (moins de " & sem & " semaines)"
    cr = CantiqueRow(num)
    If cr = 0 Then
        ControleChant = Trim$(ControleChant & IIf(ControleChant <> "", " ; ", "") & "Hors répertoire")
    Else
        niv = CStr(WS(SH_CANT).Cells(cr, CC("Niveau")).Value)
        If niv <> NIV_OK Then ControleChant = ControleChant & IIf(ControleChant <> "", " ; ", "") & "Pas encore maîtrisé (" & niv & ")"
    End If
End Function

Public Sub AjouterAuProgramme()
    Dim sd As String, d As Date, celeb As String, num As String, moment As String, avert As String
    If Not RequireEdit(SH_PROGS) Then Exit Sub
    sd = InputBox("Date de la célébration (jj/mm/aaaa) :", APP_NAME, Format$(Date + ((7 - Weekday(Date, vbMonday)) Mod 7), "dd/mm/yyyy"))
    If Not IsDate(sd) Then Exit Sub
    d = CDate(sd)
    celeb = InputBox("Célébration :", APP_NAME, "Culte dominical")
    num = UCase$(Trim$(InputBox("N° du cantique dans le répertoire (ex. CAN-012) :", APP_NAME)))
    If num = "" Then Exit Sub
    moment = InputBox("Moment (Entrée, Louange, Adoration, Offrande, Méditation, Sainte cène, Envoi...) :", APP_NAME, "Louange")
    If AjouterAuProgrammeInterne(d, celeb, num, moment, avert) Then
        If avert <> "" Then
            MsgBox "Chant ajouté au programme du " & Format$(d, "dd/mm/yyyy") & "." & vbCrLf & vbCrLf & "Attention : " & avert, vbExclamation, APP_NAME
        Else
            MsgBox "Chant ajouté au programme du " & Format$(d, "dd/mm/yyyy") & ".", vbInformation, APP_NAME
        End If
    Else
        MsgBox G_LastError, vbExclamation, APP_NAME
    End If
End Sub

Public Function AjouterAuProgrammeInterne(ByVal d As Date, ByVal celeb As String, ByVal num As String, ByVal moment As String, ByRef avert As String) As Boolean
    Dim gs As Worksheet, cs As Worksheet, r As Long, k As Long, cr As Long, ordre As Long
    G_LastError = ""
    cr = CantiqueRow(num)
    If cr = 0 Then
        G_LastError = "Cantique inconnu : " & num & " (ajoutez-le d'abord au répertoire)."
        Exit Function
    End If
    Set gs = WS(SH_PROGS)
    Set cs = WS(SH_CANT)
    For k = FIRSTROW To LastRow(gs, 1)
        If AsDate(gs.Cells(k, GC("Date")).Value) = d Then
            If StrComp(CStr(gs.Cells(k, GC("N° cantique")).Value), num, vbTextCompare) = 0 Then
                G_LastError = "Ce cantique est déjà au programme du " & Format$(d, "dd/mm/yyyy") & "."
                Exit Function
            End If
            If NumV(gs.Cells(k, GC("Ordre")).Value) > ordre Then ordre = NumV(gs.Cells(k, GC("Ordre")).Value)
        End If
    Next k
    avert = ControleChant(num, d)
    BeginWork
    r = LastRow(gs, 1) + 1
    gs.Cells(r, GC("Date")).Value = d
    gs.Cells(r, GC("Date")).NumberFormat = "dd/mm/yyyy"
    gs.Cells(r, GC("Célébration")).Value = celeb
    gs.Cells(r, GC("Ordre")).Value = ordre + 1
    gs.Cells(r, GC("N° cantique")).Value = cs.Cells(cr, 1).Value
    gs.Cells(r, GC("Titre")).Value = cs.Cells(cr, CC("Titre")).Value
    gs.Cells(r, GC("Recueil")).Value = Trim$(CStr(cs.Cells(cr, CC("Recueil")).Value) & IIf(CStr(cs.Cells(cr, CC("N° dans le recueil")).Value) <> "", " n° " & CStr(cs.Cells(cr, CC("N° dans le recueil")).Value), ""))
    gs.Cells(r, GC("Moment")).Value = moment
    gs.Cells(r, GC("Remarques")).Value = avert
    EndWork
    LogAction "Programme des chants", Format$(d, "dd/mm/yyyy") & " : " & num, SH_PROGS
    AjouterAuProgrammeInterne = True
End Function

' Saisie directe dans PROGRAMMES : titre et recueil repris du repertoire
Public Sub OnProgrammesChange(ByVal Target As Range)
    Dim sh As Worksheet, cs As Worksheet, rw As Range, n As Long, r As Long, cr As Long, num As String
    On Error GoTo Fin
    Set sh = Target.Worksheet
    Set cs = WS(SH_CANT)
    Application.EnableEvents = False
    For Each rw In Target.Rows
        n = n + 1
        If n > 500 Then Exit For
        r = rw.Row
        If r >= FIRSTROW Then
            num = UCase$(Trim$(CStr(sh.Cells(r, GC("N° cantique")).Value)))
            cr = CantiqueRow(num)
            If cr = 0 And num = "" And CStr(sh.Cells(r, GC("Titre")).Value) <> "" Then cr = CantiqueParTitre(CStr(sh.Cells(r, GC("Titre")).Value))
            If cr > 0 Then
                sh.Cells(r, GC("N° cantique")).Value = cs.Cells(cr, 1).Value
                sh.Cells(r, GC("Titre")).Value = cs.Cells(cr, CC("Titre")).Value
                If CStr(sh.Cells(r, GC("Recueil")).Value) = "" Then sh.Cells(r, GC("Recueil")).Value = cs.Cells(cr, CC("Recueil")).Value
            End If
        End If
    Next rw
Fin:
    Application.EnableEvents = True
End Sub

Public Sub ControlerProgramme()
    Dim sd As String, d As Date, txt As String
    If Not RequireLogin() Then Exit Sub
    If ActiveSheet.Name = SH_PROGS And ActiveCell.Row >= FIRSTROW Then d = AsDate(WS(SH_PROGS).Cells(ActiveCell.Row, GC("Date")).Value)
    If ActiveSheet.Name = SH_PROGCH Then d = AsDate(WS(SH_PROGCH).Range("C5").Value)
    If d = 0 Then
        sd = InputBox("Date du programme à contrôler (jj/mm/aaaa) :", APP_NAME)
        If Not IsDate(sd) Then Exit Sub
        d = CDate(sd)
    End If
    txt = ControlerProgrammeInterne(d, CanEdit(SH_PROGS))
    If txt = "" Then
        MsgBox "Programme du " & Format$(d, "dd/mm/yyyy") & " : aucune remarque.", vbInformation, APP_NAME
    Else
        MsgBox "Programme du " & Format$(d, "dd/mm/yyyy") & " :" & txt, vbExclamation, APP_NAME
    End If
End Sub

' Controle tous les chants d'une date ; ecrit les remarques si ecrire = True
Public Function ControlerProgrammeInterne(ByVal d As Date, ByVal ecrire As Boolean) As String
    Dim gs As Worksheet, k As Long, remarque As String
    Set gs = WS(SH_PROGS)
    If ecrire Then BeginWork
    For k = FIRSTROW To LastRow(gs, 1)
        If AsDate(gs.Cells(k, GC("Date")).Value) = d And CStr(gs.Cells(k, GC("N° cantique")).Value) <> "" Then
            remarque = ControleChant(CStr(gs.Cells(k, GC("N° cantique")).Value), d)
            If ecrire Then gs.Cells(k, GC("Remarques")).Value = remarque
            If remarque <> "" Then ControlerProgrammeInterne = ControlerProgrammeInterne & vbCrLf & "  " & gs.Cells(k, GC("Titre")).Value & " : " & remarque
        End If
    Next k
    If ecrire Then EndWork
End Function

Public Sub AfficherProgrammeChants()
    Dim d As Date, sd As String, n As Long
    If Not RequireLogin() Then Exit Sub
    If ActiveSheet.Name = SH_PROGS And ActiveCell.Row >= FIRSTROW Then
        d = AsDate(WS(SH_PROGS).Cells(ActiveCell.Row, GC("Date")).Value)
    Else
        d = AsDate(WS(SH_PROGCH).Range("C5").Value)
    End If
    If d = 0 Then
        sd = InputBox("Date de la célébration (jj/mm/aaaa) :", APP_NAME)
        If Not IsDate(sd) Then Exit Sub
        d = CDate(sd)
    End If
    n = RemplirProgrammeChants(d)
    WS(SH_PROGCH).Activate
    If n = 0 Then MsgBox "Aucun chant programmé le " & Format$(d, "dd/mm/yyyy") & ".", vbInformation, APP_NAME
End Sub

Public Function RemplirProgrammeChants(ByVal d As Date) As Long
    Dim ps As Worksheet, gs As Worksheet, v As Variant, n As Long, i As Long, j As Long, nb As Long, ord() As Long, cle() As Double
    Dim tmp As Variant, row As Long, celeb As String
    Set ps = WS(SH_PROGCH)
    Set gs = WS(SH_PROGS)
    BeginWork
    ps.Range("C5").Value = d
    ps.Range("C5").NumberFormat = "dd/mm/yyyy"
    ps.Range(ps.Cells(OUT_FIRST, 1), ps.Cells(OUT_FIRST + 100, 6)).ClearContents
    n = ReadBlock(gs, 1, v)
    ReDim ord(1 To n + 1): ReDim cle(1 To n + 1)
    For i = 1 To n
        If AsDate(v(i, GC("Date"))) = d Then
            nb = nb + 1
            ord(nb) = i
            cle(nb) = NumV(v(i, GC("Ordre")))
            If celeb = "" Then celeb = CStr(v(i, GC("Célébration")))
        End If
    Next i
    For i = 2 To nb
        j = i
        Do While j > 1
            If cle(j - 1) <= cle(j) Then Exit Do
            tmp = cle(j): cle(j) = cle(j - 1): cle(j - 1) = tmp
            tmp = ord(j): ord(j) = ord(j - 1): ord(j - 1) = tmp
            j = j - 1
        Loop
    Next i
    row = OUT_FIRST
    For j = 1 To nb
        i = ord(j)
        ps.Cells(row, 1).Value = j
        ps.Cells(row, 2).Value = v(i, GC("Moment"))
        ps.Cells(row, 3).Value = v(i, GC("N° cantique"))
        ps.Cells(row, 4).Value = v(i, GC("Titre"))
        ps.Cells(row, 5).Value = v(i, GC("Recueil"))
        ps.Cells(row, 6).Value = v(i, GC("Remarques"))
        row = row + 1
    Next j
    ps.Range("D5").Value = celeb & IIf(celeb <> "", " - " & JourLong(d) & " " & Format$(d, "dd/mm/yyyy"), "")
    ps.Range("B6").Value = ParamStr("NOM_GROUPE") & IIf(TitulaireDe("DIR") <> "", "  -  Direction : " & TitulaireDe("DIR"), "")
    EndWork
    RemplirProgrammeChants = nb
End Function

' ------------------------------------------------------------ etudes bibliques
Private Function TypeSeanceEtude(ByVal typ As String) As String
    Select Case typ
        Case "Retraite spirituelle", "Veillée de prière": TypeSeanceEtude = "VEIL"
        Case Else: TypeSeanceEtude = "ETUDE"
    End Select
End Function

Public Sub NouvelleEtude()
    Dim sd As String, d As Date, typ As String, theme As String, texte As String, orateur As String, lieu As String, r As Long
    If Not RequireEdit(SH_ETUDES) Then Exit Sub
    sd = InputBox("Date (jj/mm/aaaa) :", APP_NAME, Format$(Date, "dd/mm/yyyy"))
    If Not IsDate(sd) Then Exit Sub
    d = CDate(sd)
    typ = InputBox("Type : Étude biblique, Affermissement, Retraite spirituelle, Veillée de prière, Formation musicale", APP_NAME, "Étude biblique")
    If typ = "" Then Exit Sub
    theme = InputBox("Thème :", APP_NAME)
    If theme = "" Then Exit Sub
    texte = InputBox("Texte biblique (ex. Psaume 150) :", APP_NAME)
    orateur = InputBox("Orateur / animateur :", APP_NAME)
    lieu = InputBox("Lieu :", APP_NAME, "Salle de répétition")
    r = NouvelleEtudeInterne(d, typ, theme, texte, orateur, lieu)
    MsgBox "Étude enregistrée" & IIf(CStr(WS(SH_ETUDES).Cells(r, ColOf(WS(SH_ETUDES), "Séance")).Value) <> "", _
           " ; séance " & WS(SH_ETUDES).Cells(r, ColOf(WS(SH_ETUDES), "Séance")).Value & " créée pour le pointage.", "."), vbInformation, APP_NAME
End Sub

Public Function NouvelleEtudeInterne(ByVal d As Date, ByVal typ As String, ByVal theme As String, ByVal texte As String, _
                                     ByVal orateur As String, ByVal lieu As String) As Long
    Dim es As Worksheet, r As Long
    Set es = WS(SH_ETUDES)
    BeginWork
    r = LastRow(es, 1) + 1
    es.Cells(r, 1).Value = d
    es.Cells(r, 1).NumberFormat = "dd/mm/yyyy"
    es.Cells(r, 2).Value = typ
    es.Cells(r, 3).Value = theme
    es.Cells(r, 4).Value = texte
    es.Cells(r, 5).Value = orateur
    es.Cells(r, 6).Value = lieu
    es.Cells(r, ColOf(es, "Statut")).Value = "Prévue"
    es.Cells(r, ColOf(es, "Séance")).Value = CreerSeance(d, TypeSeanceEtude(typ), lieu, typ & " : " & theme)
    EndWork
    LogAction "Étude planifiée", Format$(d, "dd/mm/yyyy") & " " & typ & " : " & theme, SH_ETUDES
    NouvelleEtudeInterne = r
End Function

Public Sub CreerSeanceEtude()
    Dim es As Worksheet, r As Long, id As String
    If Not RequireEdit(SH_ETUDES) Then Exit Sub
    Set es = WS(SH_ETUDES)
    If ActiveSheet.Name <> SH_ETUDES Or ActiveCell.Row < FIRSTROW Then
        MsgBox "Sélectionnez d'abord la ligne de l'étude.", vbInformation, APP_NAME
        Exit Sub
    End If
    r = ActiveCell.Row
    If Not HasDate(es.Cells(r, 1).Value) Then Exit Sub
    BeginWork
    id = CreerSeance(AsDate(es.Cells(r, 1).Value), TypeSeanceEtude(CStr(es.Cells(r, 2).Value)), CStr(es.Cells(r, 6).Value), _
                     CStr(es.Cells(r, 2).Value) & " : " & CStr(es.Cells(r, 3).Value))
    es.Cells(r, ColOf(es, "Séance")).Value = id
    EndWork
    MsgBox "Séance " & id & " prête pour le pointage.", vbInformation, APP_NAME
End Sub

' Les etudes dont la seance est pointee passent a "Realisee"
Public Sub ActualiserEtudesInterne()
    Dim es As Worksheet, ss As Worksheet, r As Long, sr As Long, cS As Long, cSe As Long
    Set es = WS(SH_ETUDES)
    Set ss = WS(SH_SEANCES)
    cS = ColOf(es, "Statut"): cSe = ColOf(es, "Séance")
    For r = FIRSTROW To LastRow(es, 1)
        If CStr(es.Cells(r, cS).Value) = "Prévue" Then
            sr = SeanceRow(CStr(es.Cells(r, cSe).Value))
            If sr > 0 Then
                If UCase$(CStr(ss.Cells(sr, ColOf(ss, "Pointée")).Value)) = "OUI" Then es.Cells(r, cS).Value = "Réalisée"
            End If
        End If
    Next r
End Sub

Public Sub ActualiserEtudes()
    If Not RequireLogin() Then Exit Sub
    BeginWork
    ActualiserEtudesInterne
    EndWork
    MsgBox "Études actualisées (réalisées d'après le pointage).", vbInformation, APP_NAME
End Sub

' ------------------------------------------------------------ alertes
Public Sub AlertesCantiques(ByVal lignes As Collection)
    Dim gs As Worksheet, v As Variant, n As Long, i As Long, d As Date, prochain As Date, txt As String, es As Worksheet, nEt As Long
    Dim parts() As String
    Set gs = WS(SH_PROGS)
    n = ReadBlock(gs, 1, v)
    For i = 1 To n
        d = AsDate(v(i, GC("Date")))
        If d >= Date And d <= Date + 14 Then
            If prochain = 0 Or d < prochain Then prochain = d
        End If
    Next i
    If prochain > 0 Then
        txt = ControlerProgrammeInterne(prochain, False)
        parts = Split(txt, vbCrLf)
        If txt <> "" Then lignes.Add "Cantiques : le programme du " & Format$(prochain, "dd/mm/yyyy") & " contient " & UBound(parts) & _
                                     " chant(s) à revoir (répétition à moins de " & ParamNum("SEMAINES_REPETITION_CHANT", 4) & " semaines ou chant non maîtrisé)."
    End If
    Set es = WS(SH_ETUDES)
    For i = FIRSTROW To LastRow(es, 1)
        d = AsDate(es.Cells(i, 1).Value)
        If d >= Date And d <= Date + 7 And CStr(es.Cells(i, ColOf(es, "Statut")).Value) = "Prévue" Then nEt = nEt + 1
    Next i
    If nEt > 0 Then lignes.Add "Vie spirituelle : " & nEt & " étude(s) ou activité(s) spirituelle(s) prévue(s) dans les 7 jours (feuille ETUDES)."
End Sub
