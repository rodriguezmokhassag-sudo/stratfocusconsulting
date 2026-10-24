Option Explicit
' =============================================================================
' modSocial : caisse sociale (art. 20). Un evenement declare applique le bareme :
' campagne de contributions des membres, aide versee, solde de l'evenement.
' La caisse sociale est un fonds suivi a l'interieur des caisses (rubriques
' de fonds SOCIAL).
' =============================================================================

Private Function BaremeRow(ByVal typ As String) As Long
    Dim sh As Worksheet, r As Long
    Set sh = WS(SH_BAREME)
    For r = FIRSTROW To LastRow(sh, 1)
        If StrComp(CStr(sh.Cells(r, 1).Value), typ, vbTextCompare) = 0 Then
            BaremeRow = r
            Exit Function
        End If
    Next r
End Function

Public Function EvenementRow(ByVal num As String) As Long
    Dim sh As Worksheet, r As Long
    Set sh = WS(SH_SOCIAL)
    For r = FIRSTROW To LastRow(sh, 1)
        If CStr(sh.Cells(r, 1).Value) = num Then
            EvenementRow = r
            Exit Function
        End If
    Next r
End Function

Public Sub DeclarerEvenement()
    Dim bs As Worksheet, r As Long, txt As String, n As Long, t As String, typ As String, qui As String, sd As String, d As Date
    Dim desc As String, num As String
    If Not RequireEdit(SH_SOCIAL) Then Exit Sub
    Set bs = WS(SH_BAREME)
    For r = FIRSTROW To LastRow(bs, 1)
        If CStr(bs.Cells(r, 1).Value) <> "" Then
            n = n + 1
            txt = txt & vbCrLf & "  " & n & " - " & bs.Cells(r, 1).Value
        End If
    Next r
    t = InputBox("Type d'événement (tapez le numéro) :" & txt, APP_NAME, "1")
    If t = "" Or Not IsNumeric(t) Then Exit Sub
    If CLng(t) < 1 Or CLng(t) > n Then Exit Sub
    typ = CStr(bs.Cells(FIRSTROW + CLng(t) - 1, 1).Value)
    qui = UCase$(Trim$(InputBox("Matricule du membre concerné :", APP_NAME)))
    If qui = "" Then Exit Sub
    If MembreRow(qui) = 0 Then
        MsgBox "Matricule inconnu : " & qui, vbExclamation, APP_NAME
        Exit Sub
    End If
    sd = InputBox("Date de l'événement (jj/mm/aaaa) :", APP_NAME, Format$(Date, "dd/mm/yyyy"))
    If Not IsDate(sd) Then Exit Sub
    d = CDate(sd)
    desc = Trim$(InputBox("Description (facultatif) :", APP_NAME))
    num = DeclarerEvenementInterne(typ, qui, d, desc)
    If num = "" Then
        MsgBox G_LastError, vbExclamation, APP_NAME
    Else
        MsgBox "Événement " & num & " déclaré." & vbCrLf & _
               IIf(CStr(WS(SH_SOCIAL).Cells(EvenementRow(num), ColOf(WS(SH_SOCIAL), "Campagne")).Value) <> "", _
                   "Les contributions des membres se suivent dans SUIVI_CAMPAGNE (" & WS(SH_SOCIAL).Cells(EvenementRow(num), ColOf(WS(SH_SOCIAL), "Campagne")).Value & ").", _
                   "Pas de contribution fixée par le barème (quête ou contribution libre)."), vbInformation, APP_NAME
    End If
End Sub

Public Function DeclarerEvenementInterne(ByVal typ As String, ByVal mat As String, ByVal d As Date, ByVal desc As String) As String
    Dim ss As Worksheet, bs As Worksheet, br As Long, r As Long, k As Long, v As String, n As Long, mx As Long, pre As String
    Dim num As String, contrib As Double, camp As String, nom As String
    G_LastError = ""
    Set ss = WS(SH_SOCIAL)
    Set bs = WS(SH_BAREME)
    br = BaremeRow(typ)
    If br = 0 Then G_LastError = "Type d'événement inconnu : " & typ: Exit Function
    If MembreRow(mat) = 0 Then G_LastError = "Matricule inconnu : " & mat: Exit Function
    On Error GoTo EH
    BeginWork
    pre = "SOC-" & Year(d) & "-"
    For k = FIRSTROW To LastRow(ss, 1)
        v = CStr(ss.Cells(k, 1).Value)
        If Left$(v, Len(pre)) = pre Then
            n = CLng(Val(Mid$(v, Len(pre) + 1)))
            If n > mx Then mx = n
        End If
    Next k
    num = pre & Format$(mx + 1, "000")
    nom = NomComplet(MembreValeur(mat, "Nom"), MembreValeur(mat, "Prénoms"))
    contrib = NumV(bs.Cells(br, ColOf(bs, "Contribution par membre (FCFA)")).Value)
    If contrib > 0 Then camp = CreerCampagne("Social " & num & " - " & typ & " - " & nom, contrib, d + 30, ParamStr("CODE_CONTRIB_SOCIALE", "S01.1"), num)
    r = LastRow(ss, 1) + 1
    ss.Cells(r, 1).Value = num
    ss.Cells(r, 2).Value = d
    ss.Cells(r, 3).Value = typ
    ss.Cells(r, 4).Value = bs.Cells(br, ColOf(bs, "Nature")).Value
    ss.Cells(r, 5).Value = mat
    ss.Cells(r, 6).Value = nom
    ss.Cells(r, 7).Value = desc
    ss.Cells(r, 8).Value = contrib
    ss.Cells(r, 9).Value = camp
    ss.Cells(r, 10).Value = 0
    ss.Cells(r, 11).Value = NumV(bs.Cells(br, ColOf(bs, "Aide versée par la chorale (FCFA)")).Value)
    ss.Cells(r, 12).Value = 0
    ss.Cells(r, 13).Value = 0
    ss.Cells(r, 14).Value = 0
    ss.Cells(r, 15).Value = bs.Cells(br, ColOf(bs, "Affectation de la différence")).Value
    ss.Cells(r, 16).Value = bs.Cells(br, ColOf(bs, "Présence de la chorale")).Value
    ss.Cells(r, 17).Value = "Ouvert"
    EndWork
    LogAction "Événement social", num & " : " & typ & " - " & nom, SH_SOCIAL
    DeclarerEvenementInterne = num
    Exit Function
EH:
    G_LastError = Err.Description
    EndWork
End Function

Public Sub VerserAide()
    Dim ss As Worksheet, r As Long, num As String, s As String, caisse As String, piece As String, defaut As Double
    If Not RequireLogin() Then Exit Sub
    Set ss = WS(SH_SOCIAL)
    If ActiveSheet.Name <> SH_SOCIAL Or ActiveCell.Row < FIRSTROW Then
        MsgBox "Sélectionnez d'abord la ligne de l'événement.", vbInformation, APP_NAME
        Exit Sub
    End If
    r = ActiveCell.Row
    num = CStr(ss.Cells(r, 1).Value)
    If num = "" Then Exit Sub
    defaut = NumV(ss.Cells(r, 11).Value) - NumV(ss.Cells(r, 12).Value)
    If defaut < 0 Then defaut = 0
    s = Replace(InputBox("Aide versée à " & ss.Cells(r, 6).Value & " pour " & num & " (FCFA) :", APP_NAME, CStr(defaut)), " ", "")
    If s = "" Or Not IsNumeric(s) Then Exit Sub
    caisse = ChoisirCaisse()
    If caisse = "" Then Exit Sub
    piece = VerserAideInterne(num, CDbl(s), caisse, Trim$(InputBox("Référence de l'autorisation du Bureau (si nécessaire) :", APP_NAME)))
    If piece = "" Then
        MsgBox G_LastError, vbExclamation, APP_NAME
    Else
        MsgBox "Aide enregistrée (" & piece & ").", vbInformation, APP_NAME
    End If
End Sub

Public Function VerserAideInterne(ByVal num As String, ByVal montant As Double, ByVal caisse As String, ByVal autor As String) As String
    Dim ss As Worksheet, r As Long
    G_LastError = ""
    If ModuleRight("FINANCES") <> "M" Then G_LastError = "Le versement est réservé au Secrétaire aux Finances (ou à son intérimaire).": Exit Function
    Set ss = WS(SH_SOCIAL)
    r = EvenementRow(num)
    If r = 0 Then G_LastError = "Événement introuvable : " & num: Exit Function
    If montant <= 0 Then G_LastError = "Montant invalide.": Exit Function
    If montant >= ParamNum("SEUIL_AUTORISATION", 10000) And autor = "" Then
        G_LastError = "Au-delà de " & Fcfa(ParamNum("SEUIL_AUTORISATION", 10000)) & ", la référence de l'autorisation du Bureau est obligatoire."
        Exit Function
    End If
    On Error GoTo EH
    BeginWork
    VerserAideInterne = EnregistrerEcriture(Date, caisse, "Dépense", ParamStr("CODE_AIDE_SOCIALE", "T01.1"), _
        "Aide " & CStr(ss.Cells(r, 3).Value), CStr(ss.Cells(r, 5).Value), CStr(ss.Cells(r, 6).Value), num, montant, autor, "Validée", "", False)
    EndWork
    LogAction "Aide sociale versée", num & " : " & Fcfa(montant), SH_SOCIAL
    ActualiserSocialInterne
    Exit Function
EH:
    G_LastError = Err.Description
    EndWork
End Function

Public Sub ActualiserSocial()
    If Not RequireLogin() Then Exit Sub
    ActualiserSocialInterne
End Sub

Public Sub ActualiserSocialInterne()
    Dim ss As Worksheet, r As Long, i As Long, num As String, camp As String, col As Double, aide As Double, autres As Double
    Dim codeAide As String
    Set ss = WS(SH_SOCIAL)
    codeAide = ParamStr("CODE_AIDE_SOCIALE", "T01.1")
    LoadJournal
    BeginWork
    For r = FIRSTROW To LastRow(ss, 1)
        num = CStr(ss.Cells(r, 1).Value)
        If num <> "" Then
            camp = CStr(ss.Cells(r, 9).Value)
            col = 0: aide = 0: autres = 0
            For i = 1 To G_JN
                If camp <> "" And CStr(G_J(i, CJ_REF)) = camp Then col = col + NumV(G_J(i, CJ_REC)) - NumV(G_J(i, CJ_DEP))
                If CStr(G_J(i, CJ_REF)) = num Then
                    If CStr(G_J(i, CJ_CODE)) = codeAide Then
                        aide = aide + NumV(G_J(i, CJ_DEP)) - NumV(G_J(i, CJ_REC))
                    ElseIf CStr(G_J(i, CJ_OPER)) = "Dépense" Then
                        autres = autres + NumV(G_J(i, CJ_DEP))
                    Else
                        col = col + NumV(G_J(i, CJ_REC))
                    End If
                End If
            Next i
            ss.Cells(r, 10).Value = col
            ss.Cells(r, 12).Value = aide
            ss.Cells(r, 13).Value = autres
            ss.Cells(r, 14).Value = col - aide - autres
            If camp <> "" Then
                If CampagneRow(camp) > 0 Then WS(SH_CAMPAGNES).Cells(CampagneRow(camp), 10).Value = col
            End If
        End If
    Next r
    EndWork
End Sub
