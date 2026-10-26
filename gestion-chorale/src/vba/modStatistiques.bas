Option Explicit
' =============================================================================
' modStatistiques : taux de participation, liste electorale, fiche d'appel,
'                   alertes de la page d'accueil
' =============================================================================

Private m_Codes() As String, m_Poids() As Double, m_Exclu() As Boolean, m_Pen() As Double, m_Motif() As Boolean
Private m_NCodes As Long
Private m_Types() As String, m_TypeCompte() As Boolean, m_NTypes As Long
Private m_P As Variant, m_PN As Long

' ------------------------------------------------------------- caches
Public Sub LoadCodes()
    Dim sh As Worksheet, r As Long, lr As Long, n As Long
    Set sh = WS(SH_CODES)
    lr = LastRow(sh, 1)
    m_NCodes = 0
    ReDim m_Codes(1 To lr): ReDim m_Poids(1 To lr): ReDim m_Exclu(1 To lr): ReDim m_Pen(1 To lr): ReDim m_Motif(1 To lr)
    For r = FIRSTROW To lr
        If Trim$(CStr(sh.Cells(r, 1).Value)) <> "" Then
            n = n + 1
            m_Codes(n) = UCase$(Trim$(CStr(sh.Cells(r, 1).Value)))
            m_Poids(n) = Val(Replace(CStr(Nz(sh.Cells(r, ColOf(sh, "Poids dans le taux")).Value, 0)), ",", "."))
            m_Exclu(n) = (UCase$(CStr(sh.Cells(r, ColOf(sh, "Exclu du calcul")).Value)) = "OUI")
            m_Pen(n) = Val(Replace(CStr(Nz(sh.Cells(r, ColOf(sh, "Pénalité (FCFA)")).Value, 0)), " ", ""))
            m_Motif(n) = (UCase$(CStr(sh.Cells(r, ColOf(sh, "Motif obligatoire")).Value)) = "OUI")
        End If
    Next r
    m_NCodes = n
End Sub

Private Function CodeIdx(ByVal code As String) As Long
    Dim i As Long
    If m_NCodes = 0 Then LoadCodes
    code = UCase$(Trim$(code))
    For i = 1 To m_NCodes
        If m_Codes(i) = code Then
            CodeIdx = i
            Exit Function
        End If
    Next i
End Function

Public Function CodeExiste(ByVal code As String) As Boolean
    CodeExiste = (CodeIdx(code) > 0)
End Function

Public Function CodePoids(ByVal code As String) As Double
    Dim i As Long
    i = CodeIdx(code)
    If i > 0 Then CodePoids = m_Poids(i)
End Function

Public Function CodeExclu(ByVal code As String) As Boolean
    Dim i As Long
    i = CodeIdx(code)
    If i > 0 Then CodeExclu = m_Exclu(i) Else CodeExclu = True
End Function

Public Function CodePenalite(ByVal code As String) As Double
    Dim i As Long
    i = CodeIdx(code)
    If i > 0 Then CodePenalite = m_Pen(i)
End Function

Public Function CodeMotifObligatoire(ByVal code As String) As Boolean
    Dim i As Long
    i = CodeIdx(code)
    If i > 0 Then CodeMotifObligatoire = m_Motif(i)
End Function

Private Sub LoadTypes()
    Dim sh As Worksheet, r As Long, lr As Long, n As Long
    Set sh = WS(SH_TYPES)
    lr = LastRow(sh, 1)
    ReDim m_Types(1 To lr): ReDim m_TypeCompte(1 To lr)
    For r = FIRSTROW To lr
        If Trim$(CStr(sh.Cells(r, 1).Value)) <> "" Then
            n = n + 1
            m_Types(n) = UCase$(Trim$(CStr(sh.Cells(r, 1).Value)))
            m_TypeCompte(n) = (UCase$(CStr(sh.Cells(r, ColOf(sh, "Compte dans le taux")).Value)) <> "NON")
        End If
    Next r
    m_NTypes = n
End Sub

Private Function TypeCompte(ByVal code As String) As Boolean
    Dim i As Long
    code = UCase$(code)
    For i = 1 To m_NTypes
        If m_Types(i) = code Then
            TypeCompte = m_TypeCompte(i)
            Exit Function
        End If
    Next i
End Function

Public Sub LoadPresenceCache()
    LoadCodes
    LoadTypes
    LoadStatuts
    m_P = PresencesArray(m_PN)
End Sub

' La ligne de presence k entre-t-elle dans le calcul (periode + filtre de type) ?
Private Function RowInScope(ByVal k As Long, ByVal d1 As Date, ByVal d2 As Date, ByVal filtre As String) As Boolean
    Dim d As Date, t As String
    d = AsDate(m_P(k, 2))
    If d < d1 Or d > d2 Or d = 0 Then Exit Function
    t = UCase$(CStr(m_P(k, 3)))
    If filtre = "" Or filtre = "TOUS" Then
        RowInScope = TypeCompte(t)
    Else
        RowInScope = (t = filtre)
    End If
End Function

' Seances attendues et presences ponderees d'un membre sur une periode
Public Sub MemberRate(ByVal mat As String, ByVal d1 As Date, ByVal d2 As Date, ByVal filtre As String, _
                      ByRef attendues As Long, ByRef pondere As Double)
    Dim k As Long, code As String
    attendues = 0
    pondere = 0
    filtre = UCase$(filtre)
    For k = 1 To m_PN
        If CStr(m_P(k, 4)) = mat Then
            If RowInScope(k, d1, d2, filtre) Then
                code = CStr(m_P(k, 6))
                If Not CodeExclu(code) Then
                    attendues = attendues + 1
                    pondere = pondere + CodePoids(code)
                End If
            End If
        End If
    Next k
End Sub

' ------------------------------------------------------------- taux
Private Sub SetPeriode(ByVal d1 As Date, ByVal d2 As Date)
    With WS(SH_TAUX)
        .Range("C5").Value = d1
        .Range("E5").Value = d2
        If Trim$(CStr(.Range("G5").Value)) = "" Then .Range("G5").Value = "TOUS"
    End With
    CalculerTaux
End Sub

Public Sub TauxCeMois()
    SetPeriode DateSerial(Year(Date), Month(Date), 1), DateSerial(Year(Date), Month(Date) + 1, 0)
End Sub

Public Sub TauxMoisPrecedent()
    SetPeriode DateSerial(Year(Date), Month(Date) - 1, 1), DateSerial(Year(Date), Month(Date), 0)
End Sub

Public Sub TauxCeTrimestre()
    Dim q As Long
    q = (Month(Date) - 1) \ 3
    SetPeriode DateSerial(Year(Date), q * 3 + 1, 1), DateSerial(Year(Date), q * 3 + 4, 0)
End Sub

Public Sub TauxCetteAnnee()
    Dim m0 As Long, y As Long
    m0 = ParamNum("MOIS_DEBUT_EXERCICE", 1)
    If m0 < 1 Or m0 > 12 Then m0 = 1
    y = Year(Date)
    If Month(Date) < m0 Then y = y - 1
    SetPeriode DateSerial(y, m0, 1), DateSerial(y + 1, m0, 0)
End Sub

Private Function Appreciation(ByVal taux As Double, ByVal attendues As Long, ByRef couleur As Long, _
                              ByVal seuilVert As Double, ByVal seuilOrange As Double) As String
    If attendues = 0 Then
        Appreciation = "-"
        couleur = RGB(242, 242, 242)
    ElseIf taux >= seuilVert Then
        Appreciation = "Assidu(e)"
        couleur = RGB(198, 239, 206)
    ElseIf taux >= seuilOrange Then
        Appreciation = "Moyen"
        couleur = RGB(255, 235, 156)
    Else
        Appreciation = "Faible"
        couleur = RGB(255, 199, 206)
    End If
End Function

Public Sub CalculerTaux()
    Dim ts As Worksheet, ms As Worksheet, d1 As Date, d2 As Date, filtre As String
    Dim lr As Long, r As Long, n As Long, i As Long, j As Long, k As Long, code As String, mat As String
    Dim idx As New Collection, mats() As String, noms() As String, pups() As String, stats() As String
    Dim att() As Long, pond() As Double, cnt() As Long, ord() As Long, tx() As Double
    Dim codesCols As Variant, ci As Long, nOut As Long, out() As Variant, col As Long
    Dim totAtt As Long, totPond As Double, tmp As Long, seances As New Collection, nbSeances As Long
    Dim cMat As Long
    If Not RequireLogin() Then Exit Sub
    On Error GoTo EH
    Set ts = WS(SH_TAUX)
    Set ms = WS(SH_MEMBRES)
    d1 = AsDate(ts.Range("C5").Value)
    d2 = AsDate(ts.Range("E5").Value)
    If d1 = 0 Or d2 = 0 Then
        TauxCeMois
        Exit Sub
    End If
    If d2 < d1 Then
        MsgBox "La date de fin est avant la date de début.", vbExclamation, APP_NAME
        Exit Sub
    End If
    filtre = UCase$(Trim$(CStr(ts.Range("G5").Value)))
    If filtre = "" Then filtre = "TOUS"
    BeginWork
    LoadPresenceCache
    codesCols = Array("P", "R", "RX", "DA", "AJ", "ANJ", "NC")

    Dim mv As Variant, nbm As Long, cNom As Long, cPre As Long, cPup As Long, cSt As Long
    cMat = ColOf(ms, "Matricule"): cNom = ColOf(ms, "Nom"): cPre = ColOf(ms, "Prénoms")
    cPup = ColOf(ms, "Pupitre"): cSt = ColOf(ms, "Statut")
    nbm = ReadBlock(ms, cMat, mv)
    ReDim mats(1 To nbm + 1): ReDim noms(1 To nbm + 1): ReDim pups(1 To nbm + 1): ReDim stats(1 To nbm + 1)
    For r = 1 To nbm
        mat = CStr(mv(r, cMat))
        If mat <> "" And Not KeyExists(idx, mat) Then
            n = n + 1
            mats(n) = mat
            noms(n) = NomComplet(mv(r, cNom), mv(r, cPre))
            pups(n) = CStr(mv(r, cPup))
            stats(n) = CStr(mv(r, cSt))
            idx.Add n, mat
        End If
    Next r
    If n = 0 Then n = 1
    ReDim att(1 To n): ReDim pond(1 To n): ReDim cnt(1 To n, 0 To 7): ReDim tx(1 To n)

    ' Agregats par pupitre, type et mois
    Dim aggK As New Collection, aggKeys() As String, aggA() As Double, aggP() As Double, nAgg As Long, key As String
    ReDim aggKeys(1 To 500): ReDim aggA(1 To 500): ReDim aggP(1 To 500)

    For k = 1 To m_PN
        If RowInScope(k, d1, d2, filtre) Then
            mat = CStr(m_P(k, 4))
            If KeyExists(idx, mat) Then
                i = idx(mat)
                code = UCase$(CStr(m_P(k, 6)))
                ci = 7
                For j = 0 To 6
                    If codesCols(j) = code Then ci = j: Exit For
                Next j
                cnt(i, ci) = cnt(i, ci) + 1
                If Not KeyExists(seances, CStr(m_P(k, 1))) Then seances.Add True, CStr(m_P(k, 1)): nbSeances = nbSeances + 1
                If Not CodeExclu(code) Then
                    att(i) = att(i) + 1
                    pond(i) = pond(i) + CodePoids(code)
                    ' type
                    key = "T|" & UCase$(CStr(m_P(k, 3)))
                    AddAgg aggK, aggKeys, aggA, aggP, nAgg, key, 1, CodePoids(code)
                    key = "M|" & Format$(AsDate(m_P(k, 2)), "yyyy-mm")
                    AddAgg aggK, aggKeys, aggA, aggP, nAgg, key, 1, CodePoids(code)
                End If
            End If
        End If
    Next k

    ' Tri par taux decroissant
    ReDim ord(1 To n)
    For i = 1 To n
        ord(i) = i
        If att(i) > 0 Then tx(i) = pond(i) / att(i) Else tx(i) = -1
    Next i
    For i = 2 To n
        tmp = ord(i)
        j = i - 1
        Do While j >= 1
            If tx(ord(j)) > tx(tmp) Then Exit Do
            If tx(ord(j)) = tx(tmp) And UCase$(noms(ord(j))) <= UCase$(noms(tmp)) Then Exit Do
            ord(j + 1) = ord(j)
            j = j - 1
        Loop
        ord(j + 1) = tmp
    Next i

    ' Sortie principale
    ts.Range("A" & OUT_FIRST & ":P" & MAXROWS).ClearContents
    ts.Range("A" & OUT_FIRST & ":P" & MAXROWS).Interior.ColorIndex = xlNone
    ts.Range("R" & OUT_HDR & ":Z" & MAXROWS).Clear
    ReDim out(1 To n, 1 To 16)
    Dim couleurs() As Long, rang As Long, sVert As Double, sOrange As Double
    ReDim couleurs(1 To n)
    sVert = ParamNum("SEUIL_VERT", 0.8)
    sOrange = ParamNum("SEUIL_ORANGE", 0.5)
    For j = 1 To n
        i = ord(j)
        If att(i) > 0 Or (StatutCodeDefaut(stats(i)) <> "" And mats(i) <> "") Then
            nOut = nOut + 1
            If att(i) > 0 Then rang = rang + 1
            out(nOut, 1) = IIf(att(i) > 0, rang, "")
            out(nOut, 2) = mats(i): out(nOut, 3) = noms(i): out(nOut, 4) = pups(i): out(nOut, 5) = stats(i)
            out(nOut, 6) = att(i)
            For ci = 0 To 7
                out(nOut, 7 + ci) = IIf(cnt(i, ci) > 0, cnt(i, ci), "")
            Next ci
            If att(i) > 0 Then out(nOut, 15) = tx(i) Else out(nOut, 15) = ""
            out(nOut, 16) = Appreciation(IIf(att(i) > 0, tx(i), 0), att(i), couleurs(nOut), sVert, sOrange)
            totAtt = totAtt + att(i)
            totPond = totPond + pond(i)
        End If
    Next j
    If nOut > 0 Then
        ts.Range("A" & OUT_FIRST).Resize(nOut, 16).Value = out
        For j = 1 To nOut
            ts.Range("O" & OUT_HDR + j & ":P" & OUT_HDR + j).Interior.Color = couleurs(j)
        Next j
    End If
    If totAtt > 0 Then ts.Range("C6").Value = totPond / totAtt Else ts.Range("C6").Value = ""
    ts.Range("E6").Value = nbSeances
    ts.Range("G6").Value = "Calculé le " & Format$(Now, "dd/mm/yyyy hh:mm")

    ' Synthese par pupitre
    Dim pupK As New Collection, pN As Long, pNames() As String, pA() As Double, pP() As Double, pM() As Long, pi As Long
    ReDim pNames(1 To 50): ReDim pA(1 To 50): ReDim pP(1 To 50): ReDim pM(1 To 50)
    For i = 1 To n
        If att(i) > 0 Then
            key = IIf(pups(i) = "", "(sans pupitre)", pups(i))
            If Not KeyExists(pupK, key) Then
                pN = pN + 1
                If pN > 50 Then pN = 50
                pNames(pN) = key
                pupK.Add pN, key
            End If
            pi = pupK(key)
            pA(pi) = pA(pi) + att(i): pP(pi) = pP(pi) + pond(i): pM(pi) = pM(pi) + 1
        End If
    Next i
    r = OUT_HDR
    WriteHeader ts, r, 18, Array("Par pupitre", "Membres", "Taux")
    For pi = 1 To pN
        r = r + 1
        ts.Cells(r, 18).Value = pNames(pi)
        ts.Cells(r, 19).Value = pM(pi)
        ts.Cells(r, 20).Value = pP(pi) / pA(pi)
    Next pi
    ts.Range(ts.Cells(OUT_HDR + 1, 20), ts.Cells(r, 20)).NumberFormat = "0%"

    r = r + 2
    WriteHeader ts, r, 18, Array("Par type d'activité", "Pointages", "Taux")
    For k = 1 To nAgg
        If Left$(aggKeys(k), 2) = "T|" Then
            r = r + 1
            ts.Cells(r, 18).Value = Mid$(aggKeys(k), 3) & " - " & TypeValeur(Mid$(aggKeys(k), 3), "Libellé")
            ts.Cells(r, 19).Value = aggA(k)
            ts.Cells(r, 20).Value = aggP(k) / aggA(k)
            ts.Cells(r, 20).NumberFormat = "0%"
        End If
    Next k

    r = r + 2
    WriteHeader ts, r, 18, Array("Évolution mensuelle", "Pointages", "Taux du groupe")
    Dim mk() As String, nm As Long, a As Long, b As Long, t As String
    ReDim mk(1 To nAgg + 1)
    For k = 1 To nAgg
        If Left$(aggKeys(k), 2) = "M|" Then nm = nm + 1: mk(nm) = aggKeys(k)
    Next k
    For a = 2 To nm
        t = mk(a): b = a - 1
        Do While b >= 1
            If mk(b) <= t Then Exit Do
            mk(b + 1) = mk(b): b = b - 1
        Loop
        mk(b + 1) = t
    Next a
    For a = 1 To nm
        k = aggK(mk(a))
        r = r + 1
        ts.Cells(r, 18).Value = MoisLong(CLng(Mid$(mk(a), 8, 2))) & " " & Mid$(mk(a), 3, 4)
        ts.Cells(r, 19).Value = aggA(k)
        ts.Cells(r, 20).Value = aggP(k) / aggA(k)
        ts.Cells(r, 20).NumberFormat = "0%"
    Next a
    ts.Columns("R").ColumnWidth = 30
    ts.Columns("S:T").ColumnWidth = 13
    EndWork
    LogAction "Taux calculés", Format$(d1, "dd/mm/yyyy") & " au " & Format$(d2, "dd/mm/yyyy") & " (" & filtre & ")", SH_TAUX
    Exit Sub
EH:
    ShowError "Calcul des taux"
End Sub

Private Sub AddAgg(ByVal keys As Collection, aggKeys() As String, aggA() As Double, aggP() As Double, ByRef nAgg As Long, _
                   ByVal key As String, ByVal a As Double, ByVal p As Double)
    Dim i As Long
    If KeyExists(keys, key) Then
        i = keys(key)
    Else
        nAgg = nAgg + 1
        If nAgg > UBound(aggKeys) Then
            ReDim Preserve aggKeys(1 To nAgg + 100): ReDim Preserve aggA(1 To nAgg + 100): ReDim Preserve aggP(1 To nAgg + 100)
        End If
        i = nAgg
        aggKeys(i) = key
        keys.Add i, key
    End If
    aggA(i) = aggA(i) + a
    aggP(i) = aggP(i) + p
End Sub

Private Sub WriteHeader(ByVal sh As Worksheet, ByVal r As Long, ByVal c As Long, ByVal titres As Variant)
    Dim i As Long
    For i = 0 To UBound(titres)
        With sh.Cells(r, c + i)
            .Value = titres(i)
            .Font.Bold = True
            .Font.Color = RGB(255, 255, 255)
            .Interior.Color = ColPrincipale()
        End With
    Next i
End Sub

' ------------------------------------------------------------- liste electorale (art. 21)
Public Sub GenererElecteurs()
    Dim es As Worksheet, ms As Worksheet, d1 As Date, mois As Long, seuil As Double, r As Long, k As Long, i As Long
    Dim mat As String, n As Long, arr As Date, out() As Variant, nonElig As Long, code As String
    Dim mv As Variant, nbm As Long, cMat As Long, cNom As Long, cPre As Long, cPup As Long, cSt As Long, cArr As Long
    Dim idx As New Collection, att() As Long, pond() As Double
    If Not RequireLogin() Then Exit Sub
    On Error GoTo EH
    Set es = WS(SH_ELEC)
    Set ms = WS(SH_MEMBRES)
    mois = ParamNum("MOIS_ELECTEUR", 3)
    seuil = ParamNum("SEUIL_ELECTEUR", 0.6)
    d1 = AjouterMois(Date, -mois)
    BeginWork
    LoadPresenceCache
    cMat = ColOf(ms, "Matricule"): cNom = ColOf(ms, "Nom"): cPre = ColOf(ms, "Prénoms")
    cPup = ColOf(ms, "Pupitre"): cSt = ColOf(ms, "Statut"): cArr = ColOf(ms, "Date d'arrivée")
    nbm = ReadBlock(ms, cMat, mv)
    ReDim att(1 To nbm + 1): ReDim pond(1 To nbm + 1)
    For r = 1 To nbm
        mat = CStr(mv(r, cMat))
        If mat <> "" And Not KeyExists(idx, mat) Then idx.Add r, mat
    Next r
    For k = 1 To m_PN
        If RowInScope(k, d1, Date, "TOUS") Then
            mat = CStr(m_P(k, 4))
            If KeyExists(idx, mat) Then
                i = idx(mat)
                code = CStr(m_P(k, 6))
                If Not CodeExclu(code) Then
                    att(i) = att(i) + 1
                    pond(i) = pond(i) + CodePoids(code)
                End If
            End If
        End If
    Next k
    ReDim out(1 To nbm + 1, 1 To 7)
    For r = 1 To nbm
        mat = CStr(mv(r, cMat))
        If mat <> "" And CStr(mv(r, cSt)) = ST_CONF Then
            arr = AsDate(mv(r, cArr))
            If (arr = 0 Or arr <= d1) And att(r) > 0 Then
                If pond(r) / att(r) >= seuil Then
                    n = n + 1
                    out(n, 1) = n: out(n, 2) = mat
                    out(n, 3) = NomComplet(mv(r, cNom), mv(r, cPre))
                    out(n, 4) = mv(r, cPup)
                    out(n, 5) = IIf(arr = 0, "", arr)
                    out(n, 6) = pond(r) / att(r)
                    out(n, 7) = ""
                Else
                    nonElig = nonElig + 1
                End If
            Else
                nonElig = nonElig + 1
            End If
        End If
    Next r
    es.Range("A" & OUT_FIRST & ":G" & MAXROWS).ClearContents
    es.Range("A" & OUT_FIRST & ":G" & MAXROWS).Borders.LineStyle = xlNone
    If n > 0 Then
        es.Range("A" & OUT_FIRST).Resize(n, 7).Value = out
        es.Range("A" & OUT_FIRST).Resize(n, 7).Borders.LineStyle = xlContinuous
        es.Range("A" & OUT_FIRST).Resize(n, 7).Borders.Color = RGB(191, 191, 191)
    End If
    es.Range("C5").Value = "Choristes confirmés présents depuis au moins " & mois & " mois avec un taux d'assiduité d'au moins " & Format$(seuil, "0%") & " (art. 21)"
    es.Range("C6").Value = n & " électeur(s) - " & nonElig & " choriste(s) confirmé(s) non éligible(s) - liste établie le " & Format$(Date, "dd/mm/yyyy")
    EndWork
    LogAction "Liste électorale", n & " électeur(s)", SH_ELEC
    Exit Sub
EH:
    ShowError "Liste électorale"
End Sub

' ------------------------------------------------------------- fiche d'appel
Public Sub GenererFicheAppel()
    Dim fs As Worksheet, ss As Worksheet, id As String, r As Long, lr As Long, d As Date, n As Long, i As Long, row As Long
    Dim mats() As String, noms() As String, pups() As String, codes() As String, stats() As String, cur As String, k As Long
    If Not RequireLogin() Then Exit Sub
    On Error GoTo EH
    Set fs = WS(SH_FICHE)
    Set ss = WS(SH_SEANCES)
    id = Trim$(CStr(fs.Range("C5").Value))
    If id = "" Then
        lr = LastRow(ss, 1)
        For r = FIRSTROW To lr
            If AsDate(ss.Cells(r, ColOf(ss, "Date")).Value) >= Date And CStr(ss.Cells(r, ColOf(ss, "Statut")).Value) <> "Annulée" Then
                id = CStr(ss.Cells(r, 1).Value)
                Exit For
            End If
        Next r
        If id = "" Then
            MsgBox "Indiquez la séance dans la case jaune (ou générez d'abord le calendrier).", vbInformation, APP_NAME
            Exit Sub
        End If
        fs.Range("C5").Value = id
    End If
    r = SeanceRow(id)
    If r = 0 Then
        MsgBox "Séance introuvable : " & id, vbExclamation, APP_NAME
        Exit Sub
    End If
    BeginWork
    d = AsDate(ss.Cells(r, ColOf(ss, "Date")).Value)
    n = MembresAttendus(d, mats, noms, pups, codes, stats)
    fs.Range("A" & OUT_FIRST & ":I" & MAXROWS).Clear
    fs.Range("C6").Value = JourLong(d) & " " & Format$(d, "dd/mm/yyyy") & " - " & ss.Cells(r, ColOf(ss, "Libellé")).Value & _
        "  " & Format$(ss.Cells(r, ColOf(ss, "Heure de début")).Value, "hh:mm") & " - " & n & " membre(s)"
    row = OUT_HDR
    cur = "#"
    For i = 1 To n
        If pups(i) <> cur Then
            cur = pups(i)
            row = row + 1
            fs.Cells(row, 1).Value = IIf(cur = "", "(sans pupitre)", UCase$(cur))
            With fs.Range(fs.Cells(row, 1), fs.Cells(row, 9))
                .Font.Bold = True
                .Interior.Color = ColSecondaire()
            End With
        End If
        row = row + 1
        k = k + 1
        fs.Cells(row, 1).Value = k
        fs.Cells(row, 2).Value = mats(i)
        fs.Cells(row, 3).Value = noms(i)
        fs.Cells(row, 4).Value = pups(i)
        If codes(i) = "NC" Then fs.Cells(row, 9).Value = "Non concerné (" & stats(i) & ")"
    Next i
    If row > OUT_HDR Then
        With fs.Range(fs.Cells(OUT_FIRST, 1), fs.Cells(row, 9)).Borders
            .LineStyle = xlContinuous
            .Color = RGB(160, 160, 160)
        End With
        fs.Range(fs.Cells(OUT_FIRST, 1), fs.Cells(row, 9)).RowHeight = 20
        fs.Range(fs.Cells(OUT_FIRST, 1), fs.Cells(row, 9)).VerticalAlignment = xlCenter
    End If
    EndWork
    Exit Sub
EH:
    ShowError "Fiche d'appel"
End Sub

' ------------------------------------------------------------- refroidis (art. 52)
Public Function CandidatsRefroidis(ByRef noms As String) As Collection
    Dim ms As Worksheet, res As New Collection, cutoff As Date, r As Long, k As Long, mat As String
    Dim idx As New Collection, lastA() As Date, recent As Boolean, d As Date, code As String, i As Long
    Dim st As String, arr As Date, nb As Long, mv As Variant, nbm As Long
    Dim cMat As Long, cNom As Long, cPre As Long, cSt As Long, cArr As Long
    Set CandidatsRefroidis = res
    noms = ""
    cutoff = AjouterMois(Date, -ParamNum("MOIS_REFROIDI", 2))
    If m_PN = 0 Then Exit Function
    Set ms = WS(SH_MEMBRES)
    cMat = ColOf(ms, "Matricule"): cNom = ColOf(ms, "Nom"): cPre = ColOf(ms, "Prénoms")
    cSt = ColOf(ms, "Statut"): cArr = ColOf(ms, "Date d'arrivée")
    nbm = ReadBlock(ms, cMat, mv)
    ReDim lastA(1 To nbm + 1)
    For r = 1 To nbm
        mat = CStr(mv(r, cMat))
        If mat <> "" And Not KeyExists(idx, mat) Then idx.Add r, mat
    Next r
    For k = 1 To m_PN
        d = AsDate(m_P(k, 2))
        If d > cutoff Then recent = True
        code = CStr(m_P(k, 6))
        If CodePoids(code) > 0 Or (CodeExclu(code) And UCase$(code) <> "NC") Then
            mat = CStr(m_P(k, 4))
            If KeyExists(idx, mat) Then
                i = idx(mat)
                If d > lastA(i) Then lastA(i) = d
            End If
        End If
    Next k
    If Not recent Then Exit Function
    For r = 1 To nbm
        mat = CStr(mv(r, cMat))
        If mat <> "" Then
            st = CStr(mv(r, cSt))
            arr = AsDate(mv(r, cArr))
            If StatutCodeDefaut(st) = "P" And st <> ST_REFROIDI And st <> ST_OBS And arr < cutoff Then
                If lastA(r) < cutoff Then
                    res.Add mat
                    nb = nb + 1
                    If nb <= 8 Then noms = noms & IIf(noms = "", "", ", ") & NomComplet(mv(r, cNom), mv(r, cPre))
                End If
            End If
        End If
    Next r
    If nb > 8 Then noms = noms & "..."
End Function

Public Sub MarquerRefroidis()
    Dim c As Collection, noms As String, i As Long, r As Long, ms As Worksheet
    If Not RequireEdit(SH_MEMBRES) Then Exit Sub
    LoadPresenceCache
    Set c = CandidatsRefroidis(noms)
    If c.Count = 0 Then
        MsgBox "Aucun membre à marquer comme « refroidi ».", vbInformation, APP_NAME
        Exit Sub
    End If
    If MsgBox(c.Count & " membre(s) absent(s) depuis plus de " & ParamNum("MOIS_REFROIDI", 2) & " mois sans justification :" & vbCrLf & noms & vbCrLf & vbCrLf & _
              "Leur donner le statut « " & ST_REFROIDI & " » ? (art. 52 : passage devant le conseil de discipline)", vbYesNo + vbQuestion, APP_NAME) = vbNo Then Exit Sub
    Set ms = WS(SH_MEMBRES)
    BeginWork
    For i = 1 To c.Count
        r = MembreRow(c(i))
        If r > 0 Then
            ms.Cells(r, ColOf(ms, "Statut")).Value = ST_REFROIDI
            ms.Cells(r, ColOf(ms, "Date du statut")).Value = Date
        End If
    Next i
    EndWork
    LogAction "Membres refroidis", c.Count & " : " & noms, SH_MEMBRES
    RefreshAlerts
End Sub

' ------------------------------------------------------------- alertes
Public Sub RefreshAlerts()
    Dim hs As Worksheet, ss As Worksheet, ads As Worksheet, r As Long, lr As Long, nb As Long, first As Date, d As Date
    Dim lignes As New Collection, noms As String, c As Collection, nConf As Long, nFin As Long, nManq As Long
    Dim prop As String, fin As Date, jours As Long, i As Long, row As Long
    On Error GoTo EH
    Set hs = WS(SH_ACCUEIL)
    row = AlertRow()
    BeginWork
    hs.Range("B" & row & ":L" & row + 60).ClearContents
    If Not IsLogged() Then
        EndWork
        Exit Sub
    End If
    LoadPresenceCache
    If RightOf(SH_SEANCES) <> "" Then
        Set ss = WS(SH_SEANCES)
        Dim sv As Variant, ns As Long, cD As Long, cS As Long, cP As Long
        cD = ColOf(ss, "Date"): cS = ColOf(ss, "Statut"): cP = ColOf(ss, "Pointée")
        ns = ReadBlock(ss, 1, sv)
        lr = FIRSTROW + ns - 1
        For r = 1 To ns
            d = AsDate(sv(r, cD))
            If d > 0 And d < Date And CStr(sv(r, cS)) <> "Annulée" And UCase$(CStr(sv(r, cP))) <> "OUI" Then
                nb = nb + 1
                If first = 0 Or d < first Then first = d
            End If
        Next r
        If nb > 0 Then lignes.Add "Pointage : " & nb & " séance(s) passée(s) non pointée(s) (la plus ancienne : " & Format$(first, "dd/mm/yyyy") & ")."
        If lr < FIRSTROW Then lignes.Add "Calendrier : aucune séance. Générez le calendrier de l'année (feuille SEANCES)."
    End If
    If RightOf(SH_MEMBRES) <> "" Then
        Set c = CandidatsRefroidis(noms)
        If c.Count > 0 Then lignes.Add "Refroidis : " & c.Count & " membre(s) absent(s) depuis plus de " & ParamNum("MOIS_REFROIDI", 2) & " mois sans justification : " & noms & _
            IIf(CanEdit(SH_MEMBRES), "  -> bouton « Marquer les refroidis ».", "")
        DoActualiserDossiers True
        Set ads = WS(SH_ADH)
        jours = ParamNum("JOURS_ALERTE_OBSERVATION", 15)
        Dim av As Variant, na As Long, cSd As Long, cPr As Long, cFp As Long, cEm As Long
        cSd = ColOf(ads, "Statut du dossier"): cPr = ColOf(ads, "Proposition")
        cFp = ColOf(ads, "Fin prévue"): cEm = ColOf(ads, "Éléments manquants")
        na = ReadBlock(ads, 1, av)
        For r = 1 To na
            If Left$(CStr(av(r, cSd)), 4) <> "Clos" And CStr(av(r, 2)) <> "" Then
                prop = CStr(av(r, cPr))
                fin = AsDate(av(r, cFp))
                If Left$(prop, 2) = "À " Then
                    nConf = nConf + 1
                ElseIf fin > 0 And fin <= Date + jours And fin >= Date Then
                    nFin = nFin + 1
                End If
                If CStr(av(r, cEm)) <> "" Then nManq = nManq + 1
            End If
        Next r
        If nConf > 0 Then lignes.Add "Nouveaux choristes : " & nConf & " dossier(s) prêt(s) pour la décision du Bureau."
        If nFin > 0 Then lignes.Add "Nouveaux choristes : " & nFin & " observation(s) se terminent dans les " & jours & " prochains jours."
        If nManq > 0 Then lignes.Add "Nouveaux choristes : " & nManq & " dossier(s) avec des éléments manquants."
    End If
    If ModuleRight("COTISATIONS") <> "" Then
        Dim nbRet As Long, totRes As Double
        CotisationsInterne Date, False, nbRet, totRes
        If nbRet > 0 Then lignes.Add "Cotisations : " & nbRet & " membre(s) avec au moins " & ParamNum("MOIS_ALERTE_ARRIERES", 3) & _
            " mois d'arriérés ; reste à recouvrer " & Fcfa(totRes) & " (feuille COTISATIONS)."
    End If
    If ModuleRight("FINANCES") <> "" Then
        Dim esp As Double, bq As Double, soc As Double, ar As Worksheet, dA As Date, rr As Long
        Soldes Date, esp, bq, soc
        If esp < 0 Then lignes.Add "Caisse : le solde en espèces est négatif (" & Fcfa(esp) & ") : vérifiez les écritures."
        If soc < 0 Then lignes.Add "Caisse sociale : solde négatif (" & Fcfa(soc) & ")."
        Set ar = WS(SH_ARRETES)
        For rr = FIRSTROW To LastRow(ar, 1)
            If CStr(ar.Cells(rr, 2).Value) = CAISSE_ESP Then
                If AsDate(ar.Cells(rr, 1).Value) > dA Then dA = AsDate(ar.Cells(rr, 1).Value)
            End If
        Next rr
        If G_JN > 0 And (dA = 0 Or Date - dA > ParamNum("JOURS_ALERTE_ARRETE", 30)) Then
            lignes.Add "Arrêté de caisse : " & IIf(dA = 0, "aucun arrêté enregistré", "dernier arrêté le " & Format$(dA, "dd/mm/yyyy")) & " - comptez la caisse."
        End If
    End If
    If RightOf(SH_PAT) <> "" Then
        Dim nRetard As Long, nAch As Long, nLoc As Long, inv As String, nRep As Long
        nRetard = RetoursEnRetard()
        If nRetard > 0 Then lignes.Add "Patrimoine : " & nRetard & " prêt(s), location(s) ou réparation(s) non rendu(s) à la date prévue (feuille MOUVEMENTS_PAT)."
        nLoc = LocationsEnAttente()
        If nLoc > 0 Then lignes.Add "Locations : " & nLoc & " contrat(s) en attente d'une étape (approbation, encaissement, remise ou caution)."
        inv = InventaireAttendu()
        If inv <> "" Then lignes.Add "Patrimoine : " & inv & " (feuille INVENTAIRE)."
        nAch = AchatsSansFiche()
        If nAch > 0 Then lignes.Add "Patrimoine : " & nAch & " achat(s) de matériel sans fiche de bien (bouton « Créer depuis un achat »)."
        Dim pr As Worksheet, rr2 As Long
        Set pr = WS(SH_PAT)
        For rr2 = FIRSTROW To LastRow(pr, 1)
            If CStr(pr.Cells(rr2, ColOf(pr, "État")).Value) = "À réparer" Or CStr(pr.Cells(rr2, ColOf(pr, "État")).Value) = "Hors service" Then nRep = nRep + 1
        Next rr2
        If nRep > 0 Then lignes.Add "Patrimoine : " & nRep & " bien(s) à réparer ou hors service."
    End If
    If lignes.Count = 0 Then lignes.Add "Aucune alerte."
    For i = 1 To lignes.Count
        hs.Cells(row + i - 1, 2).Value = ChrW(8226) & " " & lignes(i)
    Next i
    EndWork
    Exit Sub
EH:
    ShowError "Alertes"
End Sub
