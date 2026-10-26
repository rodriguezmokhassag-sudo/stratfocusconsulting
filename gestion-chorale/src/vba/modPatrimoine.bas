Option Explicit
' =============================================================================
' modPatrimoine : inventaire valorise (amortissement lineaire), mouvements
' (prets, reparations, pertes, sorties), inventaire physique, etiquettes,
' fiche d'un bien, synthese, lien avec les achats de la caisse.
' =============================================================================

Public Const MV_NUM As Long = 1
Public Const MV_DATE As Long = 2
Public Const MV_TYPE As Long = 3
Public Const MV_CODE As Long = 4
Public Const MV_DES As Long = 5
Public Const MV_QTE As Long = 6
Public Const MV_BENEF As Long = 7
Public Const MV_CONTRAT As Long = 8
Public Const MV_RPREVU As Long = 9
Public Const MV_REFF As Long = 10
Public Const MV_EDEP As Long = 11
Public Const MV_ERET As Long = 12
Public Const MV_MONTANT As Long = 13
Public Const MV_PIECE As Long = 14
Public Const MV_STATUT As Long = 15
Public Const MV_OBS As Long = 16
Public Const MV_SAISI As Long = 17
Public Const MV_PAR As Long = 18

Public Const SH_CATPAT As String = "CATEGORIES_PAT"
Public Const SH_MOUV As String = "MOUVEMENTS_PAT"
Public Const SH_LOCATIONS As String = "LOCATIONS"
Public Const SH_CONTRAT As String = "CONTRAT"
Public Const SH_ETIQ As String = "ETIQUETTES"
Public Const SH_INVENT As String = "INVENTAIRE"
Public Const SH_INVENTS As String = "INVENTAIRES"
Public Const SH_SYNTH As String = "SYNTHESE_PAT"
Public Const SH_FICHEB As String = "FICHE_BIEN"

' ============================================================ categories et codes
Private Function CatRow(ByVal cat As String) As Long
    Dim sh As Worksheet, r As Long
    Set sh = WS(SH_CATPAT)
    For r = FIRSTROW To LastRow(sh, 1)
        If StrComp(CStr(sh.Cells(r, 1).Value), cat, vbTextCompare) = 0 Then
            CatRow = r
            Exit Function
        End If
    Next r
End Function

Public Function CategoriePrefixe(ByVal cat As String) As String
    Dim r As Long, s As String
    r = CatRow(cat)
    If r > 0 Then s = UCase$(Trim$(CStr(WS(SH_CATPAT).Cells(r, 2).Value)))
    If s = "" Then
        s = UCase$(Left$(Replace(Replace(Replace(cat, "é", "e"), "É", "E"), " ", "") & "DIV", 3))
        If Trim$(cat) = "" Then s = "DIV"
    End If
    CategoriePrefixe = s
End Function

Public Function CategorieDuree(ByVal cat As String) As Double
    Dim r As Long
    r = CatRow(cat)
    If r > 0 Then CategorieDuree = NumV(WS(SH_CATPAT).Cells(r, 3).Value)
    If CategorieDuree <= 0 Then CategorieDuree = 5
End Function

Public Function NextCodeBien(ByVal cat As String) As String
    Dim sh As Worksheet, r As Long, pre As String, v As String, n As Long, mx As Long
    Set sh = WS(SH_PAT)
    pre = CategoriePrefixe(cat) & "-"
    For r = FIRSTROW To LastRow(sh, 1)
        v = CStr(sh.Cells(r, 1).Value)
        If Left$(v, Len(pre)) = pre Then
            n = CLng(Val(Mid$(v, Len(pre) + 1)))
            If n > mx Then mx = n
        End If
    Next r
    NextCodeBien = pre & Format$(mx + 1, "0000")
End Function

Public Function BienRow(ByVal code As String) As Long
    Dim sh As Worksheet, r As Long
    If code = "" Then Exit Function
    Set sh = WS(SH_PAT)
    For r = FIRSTROW To LastRow(sh, 1)
        If StrComp(CStr(sh.Cells(r, 1).Value), code, vbTextCompare) = 0 Then
            BienRow = r
            Exit Function
        End If
    Next r
End Function

Public Function BienValeur(ByVal code As String, ByVal entete As String) As Variant
    Dim r As Long
    r = BienRow(code)
    If r = 0 Then
        BienValeur = ""
    Else
        BienValeur = WS(SH_PAT).Cells(r, ColOf(WS(SH_PAT), entete)).Value
    End If
End Function

Private Function BienSelectionne() As String
    If ActiveSheet.Name = SH_PAT And ActiveCell.Row >= FIRSTROW Then
        BienSelectionne = CStr(WS(SH_PAT).Cells(ActiveCell.Row, 1).Value)
    ElseIf ActiveSheet.Name = SH_FICHEB Then
        BienSelectionne = Trim$(CStr(WS(SH_FICHEB).Range("C5").Value))
    End If
    If BienSelectionne = "" Then BienSelectionne = UCase$(Trim$(InputBox("Code du bien (ex. MUS-0001) :", APP_NAME)))
End Function

' ============================================================ valeurs
Public Sub ValeursBien(ByVal valeur As Double, ByVal dAcq As Date, ByVal duree As Double, ByVal asOf As Date, _
                       ByRef cumul As Double, ByRef vnc As Double)
    Dim ans As Double
    cumul = 0
    If duree > 0 And dAcq > 0 And asOf > dAcq Then
        ans = (asOf - dAcq) / 365.25
        cumul = Round(valeur * ans / duree, 0)
        If cumul > valeur Then cumul = valeur
    End If
    vnc = valeur - cumul
End Sub

Public Sub RecalculerPatrimoine()
    If Not RequireLogin() Then Exit Sub
    RecalculerPatrimoineInterne Date
    MsgBox "Valeurs, amortissements et quantités disponibles recalculés au " & Format$(Date, "dd/mm/yyyy") & ".", vbInformation, APP_NAME
End Sub

Public Sub RecalculerPatrimoineInterne(ByVal asOf As Date)
    Dim sh As Worksheet, ms As Worksheet, r As Long, k As Long, code As String, idx As New Collection, sortie() As Double
    Dim cQ As Long, cVU As Long, cVT As Long, cDu As Long, cAm As Long, cVN As Long, cSo As Long, cDi As Long, cCat As Long, cDA As Long
    Dim q As Double, vu As Double, vt As Double, du As Double, cumul As Double, vnc As Double, lr As Long, typ As String
    Set sh = WS(SH_PAT)
    Set ms = WS(SH_MOUV)
    cQ = ColOf(sh, "Quantité"): cVU = ColOf(sh, "Valeur unitaire (FCFA)"): cVT = ColOf(sh, "Valeur totale (FCFA)")
    cDu = ColOf(sh, "Durée d'amortissement (ans)"): cAm = ColOf(sh, "Amortissement cumulé (FCFA)")
    cVN = ColOf(sh, "Valeur nette (FCFA)"): cSo = ColOf(sh, "Quantité sortie"): cDi = ColOf(sh, "Quantité disponible")
    cCat = ColOf(sh, "Catégorie"): cDA = ColOf(sh, "Date d'acquisition")
    lr = LastRow(sh, 1)
    BeginWork
    ReDim sortie(1 To lr + 1)
    For r = FIRSTROW To lr
        code = CStr(sh.Cells(r, 1).Value)
        If code <> "" And Not KeyExists(idx, UCase$(code)) Then idx.Add r, UCase$(code)
    Next r
    For k = FIRSTROW To LastRow(ms, 1)
        If CStr(ms.Cells(k, MV_STATUT).Value) = "En cours" Then
            typ = CStr(ms.Cells(k, MV_TYPE).Value)
            If typ = "Prêt" Or typ = "Location" Or typ = "Réparation" Then
                code = UCase$(CStr(ms.Cells(k, MV_CODE).Value))
                If KeyExists(idx, code) Then
                    r = idx(code)
                    sortie(r) = sortie(r) + NumV(ms.Cells(k, MV_QTE).Value)
                End If
            End If
        End If
    Next k
    For r = FIRSTROW To lr
        If CStr(sh.Cells(r, 1).Value) <> "" Then
            q = NumV(sh.Cells(r, cQ).Value)
            vu = NumV(sh.Cells(r, cVU).Value)
            vt = q * vu
            du = NumV(sh.Cells(r, cDu).Value)
            If du <= 0 Then
                du = CategorieDuree(CStr(sh.Cells(r, cCat).Value))
                sh.Cells(r, cDu).Value = du
            End If
            ValeursBien vt, AsDate(sh.Cells(r, cDA).Value), du, asOf, cumul, vnc
            sh.Cells(r, cVT).Value = vt
            sh.Cells(r, cAm).Value = cumul
            sh.Cells(r, cVN).Value = vnc
            sh.Cells(r, cSo).Value = sortie(r)
            sh.Cells(r, cDi).Value = q - sortie(r)
        End If
    Next r
    EndWork
End Sub

' Appelee par l'evenement Change de PATRIMOINE : code automatique et valeurs de la ligne
Public Sub OnPatrimoineChange(ByVal Target As Range)
    Dim sh As Worksheet, rw As Range, r As Long, n As Long, cDes As Long, cCat As Long, cDu As Long, cVT As Long
    Dim cQ As Long, cVU As Long, cDi As Long, cSo As Long
    On Error GoTo Fin
    Set sh = Target.Worksheet
    cDes = ColOf(sh, "Désignation"): cCat = ColOf(sh, "Catégorie"): cDu = ColOf(sh, "Durée d'amortissement (ans)")
    cVT = ColOf(sh, "Valeur totale (FCFA)"): cQ = ColOf(sh, "Quantité"): cVU = ColOf(sh, "Valeur unitaire (FCFA)")
    cDi = ColOf(sh, "Quantité disponible"): cSo = ColOf(sh, "Quantité sortie")
    Application.EnableEvents = False
    For Each rw In Target.Rows
        n = n + 1
        If n > 500 Then Exit For
        r = rw.Row
        If r >= FIRSTROW Then
            If CStr(sh.Cells(r, 1).Value) = "" And CStr(sh.Cells(r, cDes).Value) <> "" And CStr(sh.Cells(r, cCat).Value) <> "" Then
                sh.Cells(r, 1).Value = NextCodeBien(CStr(sh.Cells(r, cCat).Value))
                If CStr(sh.Cells(r, cQ).Value) = "" Then sh.Cells(r, cQ).Value = 1
                If CStr(sh.Cells(r, ColOf(sh, "État")).Value) = "" Then sh.Cells(r, ColOf(sh, "État")).Value = "Bon"
                If CStr(sh.Cells(r, ColOf(sh, "Louable")).Value) = "" Then sh.Cells(r, ColOf(sh, "Louable")).Value = "NON"
            End If
            If CStr(sh.Cells(r, 1).Value) <> "" Then
                If NumV(sh.Cells(r, cDu).Value) <= 0 And CStr(sh.Cells(r, cCat).Value) <> "" Then sh.Cells(r, cDu).Value = CategorieDuree(CStr(sh.Cells(r, cCat).Value))
                sh.Cells(r, cVT).Value = NumV(sh.Cells(r, cQ).Value) * NumV(sh.Cells(r, cVU).Value)
                sh.Cells(r, cDi).Value = NumV(sh.Cells(r, cQ).Value) - NumV(sh.Cells(r, cSo).Value)
            End If
        End If
    Next rw
Fin:
    Application.EnableEvents = True
End Sub

' ============================================================ creation de fiches
Public Function CreerBienInterne(ByVal des As String, ByVal cat As String, ByVal q As Double, ByVal unite As String, _
        ByVal dAcq As Date, ByVal mode As String, ByVal origine As String, ByVal piece As String, ByVal vu As Double) As String
    Dim sh As Worksheet, r As Long, code As String
    Set sh = WS(SH_PAT)
    code = NextCodeBien(cat)
    r = LastRow(sh, 1) + 1
    sh.Cells(r, 1).Value = code
    sh.Cells(r, ColOf(sh, "Désignation")).Value = des
    sh.Cells(r, ColOf(sh, "Catégorie")).Value = cat
    sh.Cells(r, ColOf(sh, "Quantité")).Value = q
    sh.Cells(r, ColOf(sh, "Unité")).Value = IIf(unite = "", "pièce", unite)
    sh.Cells(r, ColOf(sh, "Date d'acquisition")).Value = dAcq
    sh.Cells(r, ColOf(sh, "Mode d'acquisition")).Value = mode
    sh.Cells(r, ColOf(sh, "Origine / Donateur")).Value = origine
    sh.Cells(r, ColOf(sh, "Pièce de caisse")).Value = piece
    sh.Cells(r, ColOf(sh, "Valeur unitaire (FCFA)")).Value = vu
    sh.Cells(r, ColOf(sh, "Valeur totale (FCFA)")).Value = q * vu
    sh.Cells(r, ColOf(sh, "Durée d'amortissement (ans)")).Value = CategorieDuree(cat)
    sh.Cells(r, ColOf(sh, "Valeur nette (FCFA)")).Value = q * vu
    sh.Cells(r, ColOf(sh, "Louable")).Value = "NON"
    sh.Cells(r, ColOf(sh, "État")).Value = "Neuf"
    sh.Cells(r, ColOf(sh, "Localisation")).Value = "Magasin de la chorale"
    sh.Cells(r, ColOf(sh, "Quantité sortie")).Value = 0
    sh.Cells(r, ColOf(sh, "Quantité disponible")).Value = q
    AjouterMouvement dAcq, "Entrée", code, q, origine, "", 0, "Neuf", q * vu, piece, "Clos", mode
    LogAction "Bien créé", code & " " & des & " (" & q & " x " & Fcfa(vu) & ")", SH_PAT
    CreerBienInterne = code
End Function

Public Sub NouveauBien()
    Dim sh As Worksheet, r As Long
    If Not RequireEdit(SH_PAT) Then Exit Sub
    Set sh = WS(SH_PAT)
    r = LastRow(sh, 1) + 1
    sh.Activate
    sh.Cells(r, ColOf(sh, "Désignation")).Select
    MsgBox "Saisissez la désignation puis la catégorie sur cette ligne : le code est créé automatiquement." & vbCrLf & _
           "Complétez ensuite quantité, date, mode d'acquisition, valeur unitaire, état et localisation.", vbInformation, APP_NAME
End Sub

Private Function ChoisirCategorie(ByVal defaut As String) As String
    Dim cs As Worksheet, r As Long, n As Long, txt As String, t As String, def As Long
    Set cs = WS(SH_CATPAT)
    For r = FIRSTROW To LastRow(cs, 1)
        If CStr(cs.Cells(r, 1).Value) <> "" Then
            n = n + 1
            txt = txt & vbCrLf & "  " & n & " - " & cs.Cells(r, 1).Value
            If CStr(cs.Cells(r, 1).Value) = defaut Then def = n
        End If
    Next r
    If def = 0 Then def = 1
    t = InputBox("Catégorie du bien (tapez le numéro) :" & txt, APP_NAME, CStr(def))
    If t = "" Or Not IsNumeric(t) Then Exit Function
    If CLng(t) < 1 Or CLng(t) > n Then Exit Function
    ChoisirCategorie = CStr(cs.Cells(FIRSTROW + CLng(t) - 1, 1).Value)
End Function

' Proposee apres l'enregistrement d'un achat de materiel dans la caisse
Public Sub ProposerFicheDepuisPiece(ByVal piece As String)
    Dim r As Long, cs As Worksheet, des As String, cat As String, s As String, q As Double, montant As Double, code As String
    Set cs = WS(SH_CAISSE)
    r = JournalRow(piece)
    If r = 0 Then Exit Sub
    If MsgBox("Achat de matériel enregistré (" & piece & ")." & vbCrLf & "Créer maintenant la fiche du bien dans le patrimoine ?", vbYesNo + vbQuestion, APP_NAME) <> vbYes Then Exit Sub
    montant = NumV(cs.Cells(r, CJ_DEP).Value)
    des = Trim$(InputBox("Désignation du bien :", APP_NAME, CStr(cs.Cells(r, CJ_LIB).Value)))
    If des = "" Then Exit Sub
    cat = ChoisirCategorie(IIf(CStr(cs.Cells(r, CJ_CODE).Value) = "D04.3", "Mobilier", "Matériel de musique"))
    If cat = "" Then Exit Sub
    s = InputBox("Quantité achetée :", APP_NAME, "1")
    If s = "" Or Not IsNumeric(s) Then Exit Sub
    q = CDbl(s)
    If q <= 0 Then Exit Sub
    BeginWork
    code = CreerBienInterne(des, cat, q, "pièce", AsDate(cs.Cells(r, CJ_DATE).Value), "Achat", CStr(cs.Cells(r, CJ_TIERS).Value), piece, Round(montant / q, 0))
    EndWork
    MsgBox "Fiche " & code & " créée dans PATRIMOINE. Complétez-la (marque, n° de série, localisation, tarif de location).", vbInformation, APP_NAME
End Sub

Public Sub CreerDepuisDepense()
    Dim piece As String
    If Not RequireLogin() Then Exit Sub
    If RightOf(SH_PAT) <> "M" And ModuleRight("FINANCES") <> "M" Then
        MsgBox "Réservé au Secrétaire aux Patrimoines ou aux Finances.", vbExclamation, APP_NAME
        Exit Sub
    End If
    piece = UCase$(Trim$(InputBox("Numéro de la pièce de caisse de l'achat (ex. P-2026-0123) :", APP_NAME, AchatsSansFicheTexte(1))))
    If piece = "" Then Exit Sub
    If JournalRow(piece) = 0 Then
        MsgBox "Pièce introuvable : " & piece, vbExclamation, APP_NAME
        Exit Sub
    End If
    ProposerFicheDepuisPiece piece
End Sub

' Pieces d'achat de materiel sans fiche de bien (renvoie le nombre, ou la premiere si premiere = 1)
Public Function AchatsSansFiche() As Long
    Dim s As String
    s = AchatsSansFicheTexte(0)
    If s <> "" Then AchatsSansFiche = UBound(Split(s, ";")) + 1
End Function

Private Function AchatsSansFicheTexte(ByVal premiere As Long) As String
    Dim ps As Worksheet, i As Long, pre As String, lst As String, pieces As String, r As Long, cP As Long
    Set ps = WS(SH_PAT)
    pre = ParamStr("PREFIXE_ACHAT_MATERIEL", "D04")
    cP = ColOf(ps, "Pièce de caisse")
    For r = FIRSTROW To LastRow(ps, 1)
        pieces = pieces & ";" & CStr(ps.Cells(r, cP).Value)
    Next r
    pieces = pieces & ";"
    LoadJournal
    For i = 1 To G_JN
        If Left$(CStr(G_J(i, CJ_CODE)), Len(pre)) = pre And CStr(G_J(i, CJ_STATUT)) = "Validée" Then
            If InStr(pieces, ";" & CStr(G_J(i, CJ_PIECE)) & ";") = 0 Then
                If premiere = 1 Then
                    AchatsSansFicheTexte = CStr(G_J(i, CJ_PIECE))
                    Exit Function
                End If
                lst = lst & IIf(lst = "", "", ";") & CStr(G_J(i, CJ_PIECE))
            End If
        End If
    Next i
    AchatsSansFicheTexte = lst
End Function

' ============================================================ mouvements
Private Function NextMouvement(ByVal d As Date) As String
    Dim ms As Worksheet, r As Long, pre As String, v As String, n As Long, mx As Long
    Set ms = WS(SH_MOUV)
    pre = "MVT-" & Year(d) & "-"
    For r = FIRSTROW To LastRow(ms, 1)
        v = CStr(ms.Cells(r, 1).Value)
        If Left$(v, Len(pre)) = pre Then
            n = CLng(Val(Mid$(v, Len(pre) + 1)))
            If n > mx Then mx = n
        End If
    Next r
    NextMouvement = pre & Format$(mx + 1, "000")
End Function

Public Function AjouterMouvement(ByVal d As Date, ByVal typ As String, ByVal code As String, ByVal q As Double, _
        ByVal benef As String, ByVal contrat As String, ByVal retourPrevu As Double, ByVal etatDep As String, _
        ByVal montant As Double, ByVal piece As String, ByVal statut As String, ByVal obs As String) As String
    Dim ms As Worksheet, r As Long, num As String
    Set ms = WS(SH_MOUV)
    num = NextMouvement(d)
    r = LastRow(ms, 1) + 1
    ms.Cells(r, MV_NUM).Value = num
    ms.Cells(r, MV_DATE).Value = d
    ms.Cells(r, MV_TYPE).Value = typ
    ms.Cells(r, MV_CODE).Value = code
    ms.Cells(r, MV_DES).Value = BienValeur(code, "Désignation")
    ms.Cells(r, MV_QTE).Value = q
    ms.Cells(r, MV_BENEF).Value = benef
    ms.Cells(r, MV_CONTRAT).Value = contrat
    If retourPrevu > 0 Then ms.Cells(r, MV_RPREVU).Value = CDate(retourPrevu)
    ms.Cells(r, MV_EDEP).Value = etatDep
    If montant <> 0 Then ms.Cells(r, MV_MONTANT).Value = montant
    ms.Cells(r, MV_PIECE).Value = piece
    ms.Cells(r, MV_STATUT).Value = statut
    ms.Cells(r, MV_OBS).Value = obs
    ms.Cells(r, MV_SAISI).Value = Now
    ms.Cells(r, MV_PAR).Value = G_RoleLabel
    AjouterMouvement = num
End Function

Public Function MouvementRow(ByVal num As String) As Long
    Dim ms As Worksheet, r As Long
    Set ms = WS(SH_MOUV)
    For r = LastRow(ms, 1) To FIRSTROW Step -1
        If CStr(ms.Cells(r, 1).Value) = num Then
            MouvementRow = r
            Exit Function
        End If
    Next r
End Function

Public Function Disponible(ByVal code As String) As Double
    RecalculerPatrimoineInterne Date
    Disponible = NumV(BienValeur(code, "Quantité disponible"))
End Function

Public Sub PreterBien()
    Dim code As String, s As String, benef As String, sd As String, num As String
    If Not RequireEdit(SH_PAT) Then Exit Sub
    code = BienSelectionne()
    If code = "" Then Exit Sub
    If BienRow(code) = 0 Then
        MsgBox "Bien introuvable : " & code, vbExclamation, APP_NAME
        Exit Sub
    End If
    s = InputBox("Quantité prêtée de " & BienValeur(code, "Désignation") & " (disponible : " & Disponible(code) & ") :", APP_NAME, "1")
    If s = "" Or Not IsNumeric(s) Then Exit Sub
    benef = Trim$(InputBox("Bénéficiaire : matricule du membre ou nom de la commission :", APP_NAME))
    If benef = "" Then Exit Sub
    sd = InputBox("Date de retour prévue (jj/mm/aaaa) :", APP_NAME, Format$(Date + 7, "dd/mm/yyyy"))
    If Not IsDate(sd) Then Exit Sub
    num = PreterInterne(code, CDbl(s), benef, CDate(sd), Trim$(InputBox("Motif / observations :", APP_NAME)))
    If num = "" Then
        MsgBox G_LastError, vbExclamation, APP_NAME
    Else
        MsgBox "Prêt enregistré (" & num & ").", vbInformation, APP_NAME
    End If
End Sub

Public Function PreterInterne(ByVal code As String, ByVal q As Double, ByVal benef As String, ByVal retour As Date, ByVal obs As String) As String
    G_LastError = ""
    If BienRow(code) = 0 Then G_LastError = "Bien introuvable : " & code: Exit Function
    If q <= 0 Then G_LastError = "Quantité invalide.": Exit Function
    If q > Disponible(code) Then G_LastError = "Quantité disponible insuffisante (" & Disponible(code) & ").": Exit Function
    If MembreRow(benef) > 0 Then benef = UCase$(benef)
    BeginWork
    PreterInterne = AjouterMouvement(Date, "Prêt", code, q, benef, "", CDbl(retour), CStr(BienValeur(code, "État")), 0, "", "En cours", obs)
    EndWork
    RecalculerPatrimoineInterne Date
    LogAction "Prêt de matériel", PreterInterne & " " & code & " x" & q & " à " & benef, SH_MOUV
End Function

Public Sub EnvoyerReparation()
    Dim code As String, qui As String, sd As String, num As String
    If Not RequireEdit(SH_PAT) Then Exit Sub
    code = BienSelectionne()
    If BienRow(code) = 0 Then Exit Sub
    qui = Trim$(InputBox("Réparateur :", APP_NAME))
    If qui = "" Then Exit Sub
    sd = InputBox("Date de retour prévue (jj/mm/aaaa) :", APP_NAME, Format$(Date + 14, "dd/mm/yyyy"))
    If Not IsDate(sd) Then Exit Sub
    num = ReparationInterne(code, 1, qui, CDate(sd), Trim$(InputBox("Panne constatée :", APP_NAME)))
    If num = "" Then
        MsgBox G_LastError, vbExclamation, APP_NAME
    Else
        MsgBox "Envoi en réparation enregistré (" & num & ").", vbInformation, APP_NAME
    End If
End Sub

Public Function ReparationInterne(ByVal code As String, ByVal q As Double, ByVal qui As String, ByVal retour As Date, ByVal panne As String) As String
    G_LastError = ""
    If BienRow(code) = 0 Then G_LastError = "Bien introuvable : " & code: Exit Function
    If q > Disponible(code) Then G_LastError = "Quantité disponible insuffisante.": Exit Function
    BeginWork
    ReparationInterne = AjouterMouvement(Date, "Réparation", code, q, qui, "", CDbl(retour), "À réparer", 0, "", "En cours", panne)
    WS(SH_PAT).Cells(BienRow(code), ColOf(WS(SH_PAT), "État")).Value = "À réparer"
    EndWork
    RecalculerPatrimoineInterne Date
    LogAction "Envoi en réparation", ReparationInterne & " " & code, SH_MOUV
End Function

Private Function ChoisirEtat(ByVal defaut As String) As String
    Dim lst As Collection, i As Long, txt As String, t As String, def As Long
    Set lst = ListValues("État du bien")
    For i = 1 To lst.Count
        txt = txt & vbCrLf & "  " & i & " - " & lst(i)
        If lst(i) = defaut Then def = i
    Next i
    If def = 0 Then def = 1
    t = InputBox("État du matériel au retour (tapez le numéro) :" & txt, APP_NAME, CStr(def))
    If t = "" Or Not IsNumeric(t) Then Exit Function
    If CLng(t) < 1 Or CLng(t) > lst.Count Then Exit Function
    ChoisirEtat = lst(CLng(t))
End Function

' Retour d'un pret ou d'une reparation (ligne selectionnee dans MOUVEMENTS_PAT)
Public Sub RetourMouvement()
    Dim ms As Worksheet, r As Long, num As String, etat As String, s As String, cout As Double, caisse As String, autor As String
    If Not RequireEdit(SH_PAT) Then Exit Sub
    Set ms = WS(SH_MOUV)
    If ActiveSheet.Name <> SH_MOUV Or ActiveCell.Row < FIRSTROW Then
        MsgBox "Sélectionnez d'abord la ligne du prêt ou de la réparation.", vbInformation, APP_NAME
        Exit Sub
    End If
    r = ActiveCell.Row
    num = CStr(ms.Cells(r, 1).Value)
    If CStr(ms.Cells(r, MV_TYPE).Value) = "Location" Then
        MsgBox "Le retour d'une location se fait depuis la feuille LOCATIONS (bouton « Retour du matériel »).", vbInformation, APP_NAME
        Exit Sub
    End If
    etat = ChoisirEtat(IIf(CStr(ms.Cells(r, MV_TYPE).Value) = "Réparation", "Bon", CStr(ms.Cells(r, MV_EDEP).Value)))
    If etat = "" Then Exit Sub
    If CStr(ms.Cells(r, MV_TYPE).Value) = "Réparation" Then
        s = Replace(InputBox("Coût de la réparation (FCFA, 0 si gratuit ou déjà payé) :", APP_NAME, "0"), " ", "")
        If IsNumeric(s) Then cout = CDbl(s)
        If cout > 0 And ModuleRight("FINANCES") = "M" Then
            caisse = ChoisirCaisse("Paiement de la réparation")
            If cout >= ParamNum("SEUIL_AUTORISATION", 10000) Then autor = Trim$(InputBox("Référence de l'autorisation du Bureau :", APP_NAME))
        End If
    End If
    If RetourInterne(num, etat, cout, caisse, autor) Then
        MsgBox "Retour enregistré." & IIf(cout > 0 And caisse = "", vbCrLf & "Le coût de " & Fcfa(cout) & " reste à enregistrer en caisse par le Secrétaire aux Finances (rubrique réparations, référence " & ms.Cells(r, MV_CODE).Value & ").", ""), vbInformation, APP_NAME
    Else
        MsgBox G_LastError, vbExclamation, APP_NAME
    End If
End Sub

Public Function RetourInterne(ByVal num As String, ByVal etat As String, ByVal cout As Double, ByVal caisse As String, ByVal autor As String) As Boolean
    Dim ms As Worksheet, r As Long, code As String, piece As String, br As Long
    G_LastError = ""
    Set ms = WS(SH_MOUV)
    r = MouvementRow(num)
    If r = 0 Then G_LastError = "Mouvement introuvable : " & num: Exit Function
    If CStr(ms.Cells(r, MV_STATUT).Value) <> "En cours" Then G_LastError = "Ce mouvement n'est pas en cours.": Exit Function
    code = CStr(ms.Cells(r, MV_CODE).Value)
    On Error GoTo EH
    BeginWork
    If cout > 0 And caisse <> "" Then
        piece = EnregistrerEcriture(Date, caisse, "Dépense", ParamStr("CODE_REPARATION", "D05.1"), "Réparation " & code & " " & CStr(ms.Cells(r, MV_DES).Value), _
                "", CStr(ms.Cells(r, MV_BENEF).Value), code, cout, autor, "Validée", "", False)
        ms.Cells(r, MV_PIECE).Value = piece
    End If
    If cout > 0 Then ms.Cells(r, MV_MONTANT).Value = cout
    ms.Cells(r, MV_REFF).Value = Date
    ms.Cells(r, MV_ERET).Value = etat
    ms.Cells(r, MV_STATUT).Value = "Clos"
    br = BienRow(code)
    If br > 0 Then
        If etat <> "Bon" And etat <> "Neuf" Or CStr(ms.Cells(r, MV_TYPE).Value) = "Réparation" Then WS(SH_PAT).Cells(br, ColOf(WS(SH_PAT), "État")).Value = etat
    End If
    EndWork
    RecalculerPatrimoineInterne Date
    LogAction "Retour de matériel", num & " " & code & " : " & etat, SH_MOUV
    RetourInterne = True
    Exit Function
EH:
    G_LastError = Err.Description
    EndWork
End Function

' Perte, vol, deterioration ou sortie definitive d'un bien
Public Sub DeclarerPerteBien()
    Dim code As String, t As String, typ As String, s As String, qui As String, desc As String, num As String
    If Not RequireEdit(SH_PAT) Then Exit Sub
    code = BienSelectionne()
    If BienRow(code) = 0 Then Exit Sub
    t = InputBox("Que s'est-il passé pour " & code & " - " & BienValeur(code, "Désignation") & " ?" & vbCrLf & _
                 "  1 - Perte ou vol" & vbCrLf & "  2 - Détérioration (réparable ou non)" & vbCrLf & "  3 - Sortie définitive (réforme, cession, don)", APP_NAME, "1")
    Select Case t
        Case "1": typ = "Perte ou vol"
        Case "2": typ = "Détérioration"
        Case "3": typ = "Sortie définitive"
        Case Else: Exit Sub
    End Select
    s = InputBox("Quantité concernée :", APP_NAME, "1")
    If s = "" Or Not IsNumeric(s) Then Exit Sub
    If typ <> "Sortie définitive" Then qui = UCase$(Trim$(InputBox("Matricule du membre responsable (vide si aucun) :", APP_NAME)))
    desc = Trim$(InputBox("Circonstances :", APP_NAME))
    num = PerteBienInterne(code, typ, CDbl(s), qui, desc)
    If num = "" Then
        MsgBox G_LastError, vbExclamation, APP_NAME
    Else
        MsgBox "Enregistré (" & num & ")." & IIf(typ <> "Sortie définitive", vbCrLf & "Le montant figure au registre des PERTES (art. 51).", ""), vbInformation, APP_NAME
    End If
End Sub

Public Function PerteBienInterne(ByVal code As String, ByVal typ As String, ByVal q As Double, ByVal mat As String, ByVal desc As String) As String
    Dim sh As Worksheet, br As Long, qte As Double, vu As Double, vr As Double, montant As Double, num As String, per As String
    G_LastError = ""
    Set sh = WS(SH_PAT)
    br = BienRow(code)
    If br = 0 Then G_LastError = "Bien introuvable : " & code: Exit Function
    If mat <> "" And MembreRow(mat) = 0 Then G_LastError = "Matricule inconnu : " & mat: Exit Function
    qte = NumV(sh.Cells(br, ColOf(sh, "Quantité")).Value)
    If q <= 0 Or q > qte Then G_LastError = "Quantité invalide (en stock : " & qte & ").": Exit Function
    vu = NumV(sh.Cells(br, ColOf(sh, "Valeur unitaire (FCFA)")).Value)
    vr = NumV(sh.Cells(br, ColOf(sh, "Valeur de remplacement (FCFA)")).Value)
    If vr > 0 And qte > 0 Then vr = vr / qte
    If vr > 0 Then montant = vr * q Else montant = vu * q
    BeginWork
    If typ = "Détérioration" Then
        sh.Cells(br, ColOf(sh, "État")).Value = "À réparer"
    Else
        sh.Cells(br, ColOf(sh, "Quantité")).Value = qte - q
        If vr > 0 Then sh.Cells(br, ColOf(sh, "Valeur de remplacement (FCFA)")).Value = vr * (qte - q)
        If qte - q <= 0 Then sh.Cells(br, ColOf(sh, "État")).Value = IIf(typ = "Perte ou vol", "Perdu", "Cédé")
    End If
    If typ <> "Sortie définitive" Then
        per = AjouterPerte("Matériel perdu ou détérioré", mat, "", code & " " & CStr(sh.Cells(br, ColOf(sh, "Désignation")).Value) & _
                           " x" & q & " - " & typ & IIf(desc <> "", " : " & desc, ""), montant, Date)
    End If
    num = AjouterMouvement(Date, typ, code, q, mat, "", 0, CStr(sh.Cells(br, ColOf(sh, "État")).Value), montant, "", "Clos", _
                           Trim$(desc & IIf(per <> "", " - " & per, "")))
    EndWork
    RecalculerPatrimoineInterne Date
    LogAction typ, num & " " & code & " x" & q & IIf(per <> "", " (" & per & ")", ""), SH_MOUV
    PerteBienInterne = num
End Function

' ============================================================ fiche d'un bien
Public Sub AfficherFicheBien()
    Dim code As String
    If Not RequireLogin() Then Exit Sub
    code = BienSelectionne()
    If code = "" Then Exit Sub
    If Not FicheBienInterne(code) Then
        MsgBox "Bien introuvable : " & code, vbExclamation, APP_NAME
        Exit Sub
    End If
    WS(SH_FICHEB).Activate
End Sub

Public Function FicheBienInterne(ByVal code As String) As Boolean
    Dim fs As Worksheet, ps As Worksheet, ms As Worksheet, br As Long, c As Long, lc As Long, r As Long, k As Long, i As Long
    Set fs = WS(SH_FICHEB)
    Set ps = WS(SH_PAT)
    Set ms = WS(SH_MOUV)
    br = BienRow(code)
    If br = 0 Then Exit Function
    RecalculerPatrimoineInterne Date
    BeginWork
    fs.Range("A7:I" & MAXROWS).Clear
    fs.Range("C5").Value = ps.Cells(br, 1).Value
    lc = LastCol(ps)
    r = 7
    For c = 2 To lc
        fs.Cells(r, 2).Value = ps.Cells(HDR, c).Value
        fs.Cells(r, 2).Font.Bold = True
        fs.Cells(r, 3).Value = ps.Cells(br, c).Value
        fs.Cells(r, 3).NumberFormat = ps.Cells(br, c).NumberFormat
        fs.Cells(r, 3).HorizontalAlignment = xlLeft
        r = r + 1
    Next c
    r = r + 1
    fs.Cells(r, 2).Value = "Historique des mouvements"
    fs.Cells(r, 2).Font.Bold = True
    fs.Cells(r, 2).Font.Size = 12
    r = r + 1
    For i = 1 To 8
        fs.Cells(r, 1 + i).Value = Choose(i, "N°", "Date", "Type", "Quantité", "Bénéficiaire", "Retour", "Montant (FCFA)", "Observations")
    Next i
    With fs.Range(fs.Cells(r, 2), fs.Cells(r, 9))
        .Font.Bold = True
        .Font.Color = RGB(255, 255, 255)
        .Interior.Color = ColPrincipale()
    End With
    For k = FIRSTROW To LastRow(ms, 1)
        If StrComp(CStr(ms.Cells(k, MV_CODE).Value), code, vbTextCompare) = 0 Then
            r = r + 1
            fs.Cells(r, 2).Value = ms.Cells(k, MV_NUM).Value
            fs.Cells(r, 3).Value = ms.Cells(k, MV_DATE).Value
            fs.Cells(r, 3).NumberFormat = "dd/mm/yyyy"
            fs.Cells(r, 4).Value = ms.Cells(k, MV_TYPE).Value
            fs.Cells(r, 5).Value = ms.Cells(k, MV_QTE).Value
            fs.Cells(r, 6).Value = ms.Cells(k, MV_BENEF).Value
            fs.Cells(r, 7).Value = ms.Cells(k, MV_REFF).Value
            fs.Cells(r, 7).NumberFormat = "dd/mm/yyyy"
            fs.Cells(r, 8).Value = ms.Cells(k, MV_MONTANT).Value
            fs.Cells(r, 8).NumberFormat = "#,##0"
            fs.Cells(r, 9).Value = Trim$(CStr(ms.Cells(k, MV_STATUT).Value) & " " & CStr(ms.Cells(k, MV_OBS).Value))
            fs.Range(fs.Cells(r, 2), fs.Cells(r, 7)).HorizontalAlignment = xlLeft
        End If
    Next k
    EndWork
    FicheBienInterne = True
End Function

' ============================================================ etiquettes
Public Sub GenererEtiquettes()
    Dim f As String, n As Long
    If Not RequireLogin() Then Exit Sub
    f = Trim$(InputBox("Étiquettes à générer :" & vbCrLf & "  TOUS = tous les biens" & vbCrLf & _
                       "  un préfixe de catégorie (ex. MUS)" & vbCrLf & "  un code précis (ex. MUS-0003)", APP_NAME, "TOUS"))
    If f = "" Then Exit Sub
    n = EtiquettesInterne(f)
    WS(SH_ETIQ).Activate
    MsgBox n & " étiquette(s) générée(s). Imprimez la feuille, puis découpez et collez chaque étiquette sur le bien.", vbInformation, APP_NAME
End Sub

Public Function EtiquettesInterne(ByVal filtre As String) As Long
    Dim es As Worksheet, ps As Worksheet, r As Long, n As Long, col As Long, row0 As Long, code As String, ok As Boolean
    Dim cDes As Long, cCat As Long, cLoc As Long, cEt As Long, groupe As String
    Set es = WS(SH_ETIQ)
    Set ps = WS(SH_PAT)
    cDes = ColOf(ps, "Désignation"): cCat = ColOf(ps, "Catégorie"): cLoc = ColOf(ps, "Localisation"): cEt = ColOf(ps, "État")
    filtre = UCase$(filtre)
    groupe = ParamStr("NOM_GROUPE")
    BeginWork
    es.Range("A7:F" & MAXROWS).Clear
    For r = FIRSTROW To LastRow(ps, 1)
        code = UCase$(CStr(ps.Cells(r, 1).Value))
        If code <> "" Then
            ok = (filtre = "TOUS") Or (code = filtre) Or (InStr(filtre, "-") = 0 And Left$(code, Len(filtre) + 1) = filtre & "-")
            If ok And CStr(ps.Cells(r, cEt).Value) <> "Perdu" And CStr(ps.Cells(r, cEt).Value) <> "Cédé" Then
                col = 2 + (n Mod 3) * 2
                row0 = 7 + (n \ 3) * 5
                es.Cells(row0, col).Value = groupe
                es.Cells(row0, col).Font.Size = 8
                es.Cells(row0, col).Font.Color = ColPrincipale()
                es.Cells(row0 + 1, col).Value = code
                es.Cells(row0 + 1, col).Font.Size = 16
                es.Cells(row0 + 1, col).Font.Bold = True
                es.Cells(row0 + 2, col).Value = ps.Cells(r, cDes).Value
                es.Cells(row0 + 3, col).Value = ps.Cells(r, cCat).Value
                es.Cells(row0 + 3, col).Font.Size = 8
                es.Range(es.Cells(row0, col), es.Cells(row0 + 3, col)).HorizontalAlignment = xlCenter
                es.Range(es.Cells(row0, col), es.Cells(row0 + 3, col)).BorderAround xlContinuous, xlThin
                n = n + 1
            End If
        End If
    Next r
    EndWork
    EtiquettesInterne = n
End Function

' ============================================================ inventaire physique
Public Sub PreparerInventaire()
    Dim lbl As String, n As Long
    If Not RequireEdit(SH_INVENT) Then Exit Sub
    lbl = Trim$(InputBox("Libellé de l'inventaire :", APP_NAME, "Inventaire de " & MoisLong(Month(Date)) & " " & Year(Date)))
    If lbl = "" Then Exit Sub
    n = PreparerInventaireInterne(lbl, Date)
    WS(SH_INVENT).Activate
    MsgBox n & " ligne(s) à compter. Imprimez la feuille de comptage, puis saisissez les quantités comptées et l'état.", vbInformation, APP_NAME
End Sub

Public Function PreparerInventaireInterne(ByVal lbl As String, ByVal d As Date) As Long
    Dim invs As Worksheet, ps As Worksheet, r As Long, n As Long, out() As Variant, et As String, lr As Long
    Dim cDes As Long, cCat As Long, cLoc As Long, cEt As Long, cDi As Long, cQ As Long
    RecalculerPatrimoineInterne d
    Set invs = WS(SH_INVENT)
    Set ps = WS(SH_PAT)
    cDes = ColOf(ps, "Désignation"): cCat = ColOf(ps, "Catégorie"): cLoc = ColOf(ps, "Localisation")
    cEt = ColOf(ps, "État"): cDi = ColOf(ps, "Quantité disponible"): cQ = ColOf(ps, "Quantité")
    lr = LastRow(ps, 1)
    ReDim out(1 To lr + 1, 1 To 9)
    For r = FIRSTROW To lr
        et = CStr(ps.Cells(r, cEt).Value)
        If CStr(ps.Cells(r, 1).Value) <> "" And NumV(ps.Cells(r, cQ).Value) > 0 And et <> "Perdu" And et <> "Volé" And et <> "Cédé" Then
            n = n + 1
            out(n, 1) = ps.Cells(r, 1).Value
            out(n, 2) = ps.Cells(r, cDes).Value
            out(n, 3) = ps.Cells(r, cCat).Value
            out(n, 4) = ps.Cells(r, cLoc).Value
            out(n, 5) = NumV(ps.Cells(r, cDi).Value)
            out(n, 7) = et
        End If
    Next r
    BeginWork
    invs.Range("A" & OUT_FIRST & ":I" & MAXROWS).ClearContents
    invs.Range("A" & OUT_FIRST & ":I" & MAXROWS).Interior.ColorIndex = xlNone
    If n > 0 Then invs.Range("A" & OUT_FIRST).Resize(n, 9).Value = out
    invs.Range("C5").Value = lbl
    invs.Range("E5").Value = d
    EndWork
    PreparerInventaireInterne = n
End Function

Public Sub ValiderInventaire()
    Dim msg As String
    If Not RequireEdit(SH_INVENT) Then Exit Sub
    If MsgBox("Valider l'inventaire ? Les quantités du patrimoine seront corrigées et les manquants inscrits au registre des pertes.", vbYesNo + vbQuestion, APP_NAME) <> vbYes Then Exit Sub
    msg = ValiderInventaireInterne()
    MsgBox msg, vbInformation, APP_NAME
End Sub

Public Function ValiderInventaireInterne() As String
    Dim invs As Worksheet, ps As Worksheet, r As Long, br As Long, code As String, att As Double, cpt As Double, ecart As Double
    Dim n As Long, nEc As Long, valEc As Double, vu As Double, d As Date, lbl As String, per As String, pertes As String, hs As Worksheet, k As Long
    Dim et As String
    Set invs = WS(SH_INVENT)
    Set ps = WS(SH_PAT)
    lbl = CStr(invs.Range("C5").Value)
    d = AsDate(invs.Range("E5").Value, Date)
    BeginWork
    For r = OUT_FIRST To LastRow(invs, 1, OUT_HDR)
        code = CStr(invs.Cells(r, 1).Value)
        br = BienRow(code)
        If br > 0 And CStr(invs.Cells(r, 6).Value) <> "" And IsNumeric(invs.Cells(r, 6).Value) Then
            n = n + 1
            att = NumV(invs.Cells(r, 5).Value)
            cpt = NumV(invs.Cells(r, 6).Value)
            ecart = cpt - att
            invs.Cells(r, 8).Value = ecart
            et = Trim$(CStr(invs.Cells(r, 7).Value))
            If et <> "" Then ps.Cells(br, ColOf(ps, "État")).Value = et
            ps.Cells(br, ColOf(ps, "Dernier inventaire")).Value = d
            If ecart <> 0 Then
                nEc = nEc + 1
                vu = NumV(ps.Cells(br, ColOf(ps, "Valeur unitaire (FCFA)")).Value)
                valEc = valEc + ecart * vu
                ps.Cells(br, ColOf(ps, "Quantité")).Value = NumV(ps.Cells(br, ColOf(ps, "Quantité")).Value) + ecart
                per = ""
                If ecart < 0 Then
                    per = AjouterPerte("Matériel perdu ou détérioré", "", "", lbl & " : " & code & " " & CStr(ps.Cells(br, ColOf(ps, "Désignation")).Value) & _
                                       " - " & -ecart & " manquant(s)", -ecart * vu, d)
                    pertes = pertes & IIf(pertes = "", "", ", ") & per
                    invs.Cells(r, 8).Interior.Color = RGB(255, 199, 206)
                Else
                    invs.Cells(r, 8).Interior.Color = RGB(198, 239, 206)
                End If
                AjouterMouvement d, "Ajustement d'inventaire", code, ecart, "", "", 0, et, ecart * vu, "", "Clos", lbl & IIf(per <> "", " - " & per, "")
            End If
        End If
    Next r
    Set hs = WS(SH_INVENTS)
    k = LastRow(hs, 1) + 1
    hs.Cells(k, 1).Value = Now
    hs.Cells(k, 2).Value = lbl
    hs.Cells(k, 3).Value = n
    hs.Cells(k, 4).Value = nEc
    hs.Cells(k, 5).Value = valEc
    hs.Cells(k, 6).Value = IIf(pertes = "", "Aucune", pertes)
    hs.Cells(k, 7).Value = G_RoleLabel
    EndWork
    RecalculerPatrimoineInterne Date
    LogAction "Inventaire validé", lbl & " : " & n & " article(s), " & nEc & " écart(s), " & Fcfa(valEc), SH_INVENTS
    ValiderInventaireInterne = lbl & " validé : " & n & " article(s) comptés, " & nEc & " écart(s) pour " & Fcfa(valEc) & "." & _
                               IIf(pertes <> "", vbCrLf & "Pertes inscrites : " & pertes, "")
End Function

' Libelle d'alerte si un inventaire est attendu (mois de MOIS_INVENTAIRE sans inventaire, ou plus de 7 mois)
Public Function InventaireAttendu() As String
    Dim hs As Worksheet, r As Long, dl As Date, d As Date, mois As String
    Set hs = WS(SH_INVENTS)
    For r = FIRSTROW To LastRow(hs, 1)
        d = AsDate(hs.Cells(r, 1).Value)
        If d > dl Then dl = d
    Next r
    mois = ";" & Replace(ParamStr("MOIS_INVENTAIRE", "6;12"), " ", "") & ";"
    If InStr(mois, ";" & Month(Date) & ";") > 0 Then
        If dl = 0 Or Month(dl) <> Month(Date) Or Year(dl) <> Year(Date) Then
            InventaireAttendu = "inventaire physique de " & MoisLong(Month(Date)) & " à réaliser"
            Exit Function
        End If
    End If
    If dl > 0 And Date - dl > 213 Then InventaireAttendu = "dernier inventaire le " & Format$(dl, "dd/mm/yyyy") & " (plus de 7 mois)"
End Function

' ============================================================ synthese
Public Sub CalculerSynthesePat()
    Dim d As Date
    If Not RequireLogin() Then Exit Sub
    d = AsDate(WS(SH_SYNTH).Range("C5").Value, Date)
    WS(SH_SYNTH).Range("C5").Value = d
    SynthesePatInterne d
End Sub

Public Sub SynthesePatInterne(ByVal asOf As Date)
    Dim ss As Worksheet, ps As Worksheet, ms As Worksheet, r As Long, k As Long, n As Long, cat As String, idx As New Collection
    Dim cats() As String, nb() As Long, qte() As Double, va() As Double, am() As Double, vn() As Double, vr() As Double
    Dim cCat As Long, cQ As Long, cVT As Long, cDA As Long, cDu As Long, cVR As Long, cEt As Long, cumul As Double, vnc As Double
    Dim y As Long, ans(0 To 4) As Long, vAn(0 To 4) As Double, nRep As Long, nAmo As Long, nRet As Long, et As String, dA As Date
    Set ss = WS(SH_SYNTH)
    Set ps = WS(SH_PAT)
    Set ms = WS(SH_MOUV)
    RecalculerPatrimoineInterne asOf
    cCat = ColOf(ps, "Catégorie"): cQ = ColOf(ps, "Quantité"): cVT = ColOf(ps, "Valeur totale (FCFA)")
    cDA = ColOf(ps, "Date d'acquisition"): cDu = ColOf(ps, "Durée d'amortissement (ans)")
    cVR = ColOf(ps, "Valeur de remplacement (FCFA)"): cEt = ColOf(ps, "État")
    ReDim cats(1 To 60): ReDim nb(1 To 60): ReDim qte(1 To 60): ReDim va(1 To 60): ReDim am(1 To 60): ReDim vn(1 To 60): ReDim vr(1 To 60)
    For y = 0 To 4
        ans(y) = Year(asOf) - 4 + y
    Next y
    For r = FIRSTROW To LastRow(ps, 1)
        If CStr(ps.Cells(r, 1).Value) <> "" And NumV(ps.Cells(r, cQ).Value) > 0 Then
            cat = CStr(ps.Cells(r, cCat).Value)
            If cat = "" Then cat = "(sans catégorie)"
            If Not KeyExists(idx, cat) Then
                n = n + 1
                If n > 60 Then n = 60
                cats(n) = cat
                idx.Add n, cat
            End If
            k = idx(cat)
            dA = AsDate(ps.Cells(r, cDA).Value)
            ValeursBien NumV(ps.Cells(r, cVT).Value), dA, NumV(ps.Cells(r, cDu).Value), asOf, cumul, vnc
            nb(k) = nb(k) + 1
            qte(k) = qte(k) + NumV(ps.Cells(r, cQ).Value)
            va(k) = va(k) + NumV(ps.Cells(r, cVT).Value)
            am(k) = am(k) + cumul
            vn(k) = vn(k) + vnc
            vr(k) = vr(k) + NumV(ps.Cells(r, cVR).Value)
            For y = 0 To 4
                If dA <= DateSerial(ans(y), 12, 31) Then
                    If ans(y) = Year(asOf) Then
                        vAn(y) = vAn(y) + vnc
                    Else
                        ValeursBien NumV(ps.Cells(r, cVT).Value), dA, NumV(ps.Cells(r, cDu).Value), DateSerial(ans(y), 12, 31), cumul, vnc
                        vAn(y) = vAn(y) + vnc
                    End If
                End If
            Next y
            et = CStr(ps.Cells(r, cEt).Value)
            If et = "À réparer" Or et = "Hors service" Then nRep = nRep + 1
            If NumV(ps.Cells(r, cVT).Value) > 0 And NumV(ps.Cells(r, ColOf(ps, "Valeur nette (FCFA)")).Value) <= 0 Then nAmo = nAmo + 1
        End If
    Next r
    For r = FIRSTROW To LastRow(ms, 1)
        If CStr(ms.Cells(r, MV_STATUT).Value) = "En cours" And AsDate(ms.Cells(r, MV_RPREVU).Value) > 0 And AsDate(ms.Cells(r, MV_RPREVU).Value) < asOf Then nRet = nRet + 1
    Next r
    BeginWork
    ss.Range("A" & OUT_FIRST & ":K" & MAXROWS).Clear
    Dim t(1 To 6) As Double
    For k = 1 To n
        ss.Cells(OUT_HDR + k, 1).Value = cats(k)
        ss.Cells(OUT_HDR + k, 2).Value = nb(k)
        ss.Cells(OUT_HDR + k, 3).Value = qte(k)
        ss.Cells(OUT_HDR + k, 4).Value = va(k)
        ss.Cells(OUT_HDR + k, 5).Value = am(k)
        ss.Cells(OUT_HDR + k, 6).Value = vn(k)
        ss.Cells(OUT_HDR + k, 7).Value = vr(k)
        t(1) = t(1) + nb(k): t(2) = t(2) + qte(k): t(3) = t(3) + va(k): t(4) = t(4) + am(k): t(5) = t(5) + vn(k): t(6) = t(6) + vr(k)
    Next k
    ss.Cells(OUT_HDR + n + 1, 1).Value = "TOTAL"
    For k = 1 To 6
        ss.Cells(OUT_HDR + n + 1, 1 + k).Value = t(k)
    Next k
    ss.Range("A" & OUT_HDR + n + 1 & ":G" & OUT_HDR + n + 1).Font.Bold = True
    ss.Range("A" & OUT_HDR + n + 1 & ":G" & OUT_HDR + n + 1).Interior.Color = ColSecondaire()
    ss.Range("D" & OUT_FIRST & ":G" & OUT_HDR + n + 1).NumberFormat = "#,##0"
    ' Evolution de la valeur nette
    ss.Cells(OUT_HDR, 9).Value = "Valeur nette du patrimoine"
    ss.Cells(OUT_HDR, 10).Value = "FCFA"
    ss.Range("I" & OUT_HDR & ":J" & OUT_HDR).Font.Bold = True
    ss.Range("I" & OUT_HDR & ":J" & OUT_HDR).Font.Color = RGB(255, 255, 255)
    ss.Range("I" & OUT_HDR & ":J" & OUT_HDR).Interior.Color = ColPrincipale()
    For y = 0 To 4
        ss.Cells(OUT_FIRST + y, 9).Value = IIf(ans(y) = Year(asOf), "au " & Format$(asOf, "dd/mm/yyyy"), "au 31/12/" & ans(y))
        ss.Cells(OUT_FIRST + y, 10).Value = vAn(y)
        ss.Cells(OUT_FIRST + y, 10).NumberFormat = "#,##0"
    Next y
    ss.Cells(OUT_FIRST + 6, 9).Value = "Points d'attention"
    ss.Cells(OUT_FIRST + 6, 9).Font.Bold = True
    ss.Cells(OUT_FIRST + 7, 9).Value = "Biens à réparer ou hors service"
    ss.Cells(OUT_FIRST + 7, 10).Value = nRep
    ss.Cells(OUT_FIRST + 8, 9).Value = "Biens totalement amortis"
    ss.Cells(OUT_FIRST + 8, 10).Value = nAmo
    ss.Cells(OUT_FIRST + 9, 9).Value = "Prêts, locations, réparations en retard"
    ss.Cells(OUT_FIRST + 9, 10).Value = nRet
    ss.Cells(OUT_FIRST + 10, 9).Value = "Achats de matériel sans fiche"
    ss.Cells(OUT_FIRST + 10, 10).Value = AchatsSansFiche()
    ss.Range("C6").Value = "Valeur nette totale : " & Fcfa(t(5)) & " - calculé le " & Format$(Now, "dd/mm/yyyy hh:mm")
    EndWork
    LogAction "Synthèse du patrimoine", Fcfa(t(5)), SH_SYNTH
End Sub

' Nombre de prets, locations ou reparations en retard
Public Function RetoursEnRetard() As Long
    Dim ms As Worksheet, r As Long
    Set ms = WS(SH_MOUV)
    For r = FIRSTROW To LastRow(ms, 1)
        If CStr(ms.Cells(r, MV_STATUT).Value) = "En cours" Then
            If AsDate(ms.Cells(r, MV_RPREVU).Value) > 0 And AsDate(ms.Cells(r, MV_RPREVU).Value) < Date Then RetoursEnRetard = RetoursEnRetard + 1
        End If
    Next r
End Function
