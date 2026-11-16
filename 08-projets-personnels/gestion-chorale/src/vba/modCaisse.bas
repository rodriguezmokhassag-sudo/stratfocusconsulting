Option Explicit
' =============================================================================
' modCaisse : journal de caisse (CAISSE), saisie, soldes, recus, annulations,
'             arretes de caisse, rapprochements, pertes et cloture d'exercice
' Une ecriture enregistree n'est jamais modifiee : on l'annule par une
' contre-passation (montant negatif sur la meme rubrique).
' =============================================================================

Public Const CJ_PIECE As Long = 1
Public Const CJ_DATE As Long = 2
Public Const CJ_EXO As Long = 3
Public Const CJ_CAISSE As Long = 4
Public Const CJ_OPER As Long = 5
Public Const CJ_CODE As Long = 6
Public Const CJ_RUB As Long = 7
Public Const CJ_SRUB As Long = 8
Public Const CJ_FONDS As Long = 9
Public Const CJ_LIB As Long = 10
Public Const CJ_MAT As Long = 11
Public Const CJ_TIERS As Long = 12
Public Const CJ_REF As Long = 13
Public Const CJ_REC As Long = 14
Public Const CJ_DEP As Long = 15
Public Const CJ_AUTO As Long = 16
Public Const CJ_RECU As Long = 17
Public Const CJ_STATUT As Long = 18
Public Const CJ_LIEE As Long = 19
Public Const CJ_SAISI As Long = 20
Public Const CJ_PAR As Long = 21
Public Const CJ_COLS As Long = 21

Public Const CAISSE_ESP As String = "Espèces"
Public Const CAISSE_BQ As String = "Banque"
Public Const CODE_VIREMENT As String = "VIR"

Public G_J As Variant          ' journal en memoire : G_J(ligne, colonne CJ_*)
Public G_JN As Long
Public G_LastError As String   ' dernier motif de refus (saisie, tests)

' ============================================================ utilitaires
Public Function NumV(ByVal v As Variant) As Double
    If IsEmpty(v) Then
        NumV = 0
    ElseIf IsNumeric(v) Then
        NumV = CDbl(v)
    Else
        NumV = 0
    End If
End Function

Public Function Fcfa(ByVal v As Double) As String
    Fcfa = Format$(v, "#,##0") & " " & ParamStr("MONNAIE", "FCFA")
End Function

Public Function ChoisirCaisse(Optional ByVal titre_ As String = "") As String
    Dim titre As String: titre = titre_   ' copie locale (compatibilite LibreOffice)
    Dim r As String
    r = Trim$(InputBox(titre & IIf(titre <> "", vbCrLf & vbCrLf, "") & "Caisse : tapez 1 pour Espèces, 2 pour Banque", APP_NAME, "1"))
    If r = "1" Then ChoisirCaisse = CAISSE_ESP
    If r = "2" Then ChoisirCaisse = CAISSE_BQ
End Function

' ============================================================ exercices
Public Function MoisDebutExercice() As Long
    MoisDebutExercice = ParamNum("MOIS_DEBUT_EXERCICE", 1)
    If MoisDebutExercice < 1 Or MoisDebutExercice > 12 Then MoisDebutExercice = 1
End Function

Public Function ExerciceAnnee(ByVal d As Date) As Long
    ExerciceAnnee = Year(d)
    If Month(d) < MoisDebutExercice() Then ExerciceAnnee = ExerciceAnnee - 1
End Function

Public Function ExerciceLabel(ByVal annee As Long) As String
    If MoisDebutExercice() = 1 Then
        ExerciceLabel = CStr(annee)
    Else
        ExerciceLabel = annee & "-" & (annee + 1)
    End If
End Function

Public Function ExerciceDe(ByVal d As Date) As String
    ExerciceDe = ExerciceLabel(ExerciceAnnee(d))
End Function

Public Function ExerciceDebut(ByVal lbl As String) As Date
    ExerciceDebut = DateSerial(CLng(Val(Left$(lbl, 4))), MoisDebutExercice(), 1)
End Function

Public Function ExerciceFin(ByVal lbl As String) As Date
    ExerciceFin = DateSerial(Year(ExerciceDebut(lbl)) + 1, MoisDebutExercice(), 1) - 1
End Function

' Rang du mois dans l'exercice (1 = premier mois)
Public Function MoisIndex(ByVal d As Date) As Long
    MoisIndex = ((Month(d) - MoisDebutExercice() + 12) Mod 12) + 1
End Function

Public Function ExerciceClos(ByVal lbl As String) As Boolean
    ExerciceClos = (InStr(1, ";" & ParamStr("EXERCICES_CLOTURES") & ";", ";" & lbl & ";") > 0)
End Function

' ============================================================ rubriques
Public Function RubRow(ByVal code As String) As Long
    Dim sh As Worksheet, r As Long
    If code = "" Then Exit Function
    Set sh = WS(SH_RUBRIQUES)
    For r = FIRSTROW To LastRow(sh, 1)
        If StrComp(CStr(sh.Cells(r, 1).Value), code, vbTextCompare) = 0 Then
            RubRow = r
            Exit Function
        End If
    Next r
End Function

Public Function RubValeur(ByVal code As String, ByVal entete As String) As Variant
    Dim r As Long, sh As Worksheet
    r = RubRow(code)
    If r = 0 Then
        RubValeur = ""
    Else
        Set sh = WS(SH_RUBRIQUES)
        RubValeur = sh.Cells(r, ColOf(sh, entete)).Value
    End If
End Function

Public Function CodeDeChoix(ByVal choix As String) As String
    Dim p As Long
    choix = Trim$(choix)
    p = InStr(choix, " - ")
    If p > 0 Then CodeDeChoix = Left$(choix, p - 1) Else CodeDeChoix = choix
    CodeDeChoix = UCase$(Trim$(CodeDeChoix))
End Function

' ============================================================ journal
Public Sub LoadJournal()
    Dim sh As Worksheet, lr As Long, c As Long
    Set sh = WS(SH_CAISSE)
    lr = LastRow(sh, 1)
    G_JN = lr - HDR
    If G_JN <= 0 Then
        G_JN = 0
        G_J = Empty
    ElseIf G_JN = 1 Then
        Dim v As Variant
        ReDim v(1 To 1, 1 To CJ_COLS)
        For c = 1 To CJ_COLS
            v(1, c) = sh.Cells(FIRSTROW, c).Value
        Next c
        G_J = v
    Else
        G_J = sh.Range(sh.Cells(FIRSTROW, 1), sh.Cells(lr, CJ_COLS)).Value
    End If
End Sub

Public Function JournalRow(ByVal piece As String) As Long
    Dim sh As Worksheet, r As Long
    Set sh = WS(SH_CAISSE)
    For r = LastRow(sh, 1) To FIRSTROW Step -1
        If CStr(sh.Cells(r, CJ_PIECE).Value) = piece Then
            JournalRow = r
            Exit Function
        End If
    Next r
End Function

Private Function NextNumero(ByVal prefixe As String, ByVal col As Long, ByVal annee As Long) As String
    Dim sh As Worksheet, lr As Long, r As Long, s As String, pre As String, n As Long, mx As Long
    pre = prefixe & "-" & annee & "-"
    Set sh = WS(SH_CAISSE)
    lr = LastRow(sh, 1)
    For r = lr To FIRSTROW Step -1
        s = CStr(sh.Cells(r, col).Value)
        If Left$(s, Len(pre)) = pre Then
            If IsNumeric(Mid$(s, Len(pre) + 1)) Then
                n = CLng(Mid$(s, Len(pre) + 1))
                If n > mx Then mx = n
                If lr - r > 400 Then Exit For   ' numeros croissants : les derniers suffisent
            End If
        End If
    Next r
    NextNumero = pre & Format$(mx + 1, "0000")
End Function

' Enregistre une ligne dans le journal et renvoie son numero de piece.
' Montant negatif autorise pour une contre-passation. Leve une erreur si refus.
Public Function EnregistrerEcriture(ByVal d As Date, ByVal caisse As String, ByVal oper As String, ByVal code As String, _
        ByVal libelle As String, ByVal mat As String, ByVal tiers As String, ByVal ref As String, ByVal montant As Double, _
        ByVal autor As String, ByVal statut As String, ByVal liee As String, ByVal avecRecu As Boolean) As String
    Dim sh As Worksheet, r As Long, row() As Variant, lbl As String, piece As String
    lbl = ExerciceDe(d)
    If ExerciceClos(lbl) Then Err.Raise vbObjectError + 600, APP_NAME, "L'exercice " & lbl & " est clôturé : aucune écriture n'est possible à cette date."
    If code <> CODE_VIREMENT And RubRow(code) = 0 Then Err.Raise vbObjectError + 601, APP_NAME, "Rubrique inconnue : " & code
    Set sh = WS(SH_CAISSE)
    piece = NextNumero("P", CJ_PIECE, Year(d))
    ReDim row(1 To 1, 1 To CJ_COLS)
    row(1, CJ_PIECE) = piece
    row(1, CJ_DATE) = d
    row(1, CJ_EXO) = lbl
    row(1, CJ_CAISSE) = caisse
    row(1, CJ_OPER) = oper
    row(1, CJ_CODE) = code
    If code = CODE_VIREMENT Then
        row(1, CJ_RUB) = "Virement interne"
        row(1, CJ_SRUB) = "Virement entre caisses"
        row(1, CJ_FONDS) = "GENERAL"
    Else
        row(1, CJ_RUB) = RubValeur(code, "Rubrique")
        row(1, CJ_SRUB) = RubValeur(code, "Sous-rubrique")
        row(1, CJ_FONDS) = RubValeur(code, "Fonds")
    End If
    row(1, CJ_LIB) = libelle
    row(1, CJ_MAT) = mat
    row(1, CJ_TIERS) = tiers
    row(1, CJ_REF) = ref
    If oper = "Recette" Or oper = "Virement entrant" Then
        row(1, CJ_REC) = montant
    Else
        row(1, CJ_DEP) = montant
    End If
    row(1, CJ_AUTO) = autor
    If avecRecu And montant > 0 Then row(1, CJ_RECU) = NextNumero(ParamStr("PREFIXE_RECU", "REC"), CJ_RECU, Year(d))
    row(1, CJ_STATUT) = statut
    row(1, CJ_LIEE) = liee
    row(1, CJ_SAISI) = Now
    row(1, CJ_PAR) = G_RoleLabel
    r = LastRow(sh, 1) + 1
    sh.Range(sh.Cells(r, 1), sh.Cells(r, CJ_COLS)).Value = row
    sh.Cells(r, CJ_DATE).NumberFormat = "dd/mm/yyyy"
    EnregistrerEcriture = piece
End Function

Public Function RecuDePiece(ByVal piece As String) As String
    Dim r As Long
    r = JournalRow(piece)
    If r > 0 Then RecuDePiece = CStr(WS(SH_CAISSE).Cells(r, CJ_RECU).Value)
End Function

' ============================================================ soldes
Public Sub Soldes(ByVal asOf As Date, ByRef esp As Double, ByRef bq As Double, ByRef soc As Double)
    Dim i As Long, d As Date, d0 As Date, net As Double
    esp = ParamNum("SOLDE_OUVERTURE_ESPECES", 0)
    bq = ParamNum("SOLDE_OUVERTURE_BANQUE", 0)
    soc = ParamNum("SOLDE_OUVERTURE_SOCIAL", 0)
    d0 = AsDate(GetParam("DATE_OUVERTURE_COMPTES", ""))
    LoadJournal
    For i = 1 To G_JN
        d = AsDate(G_J(i, CJ_DATE))
        If d <= asOf And d >= d0 Then
            net = NumV(G_J(i, CJ_REC)) - NumV(G_J(i, CJ_DEP))
            If CStr(G_J(i, CJ_CAISSE)) = CAISSE_ESP Then
                esp = esp + net
            ElseIf CStr(G_J(i, CJ_CAISSE)) = CAISSE_BQ Then
                bq = bq + net
            End If
            If CStr(G_J(i, CJ_FONDS)) = "SOCIAL" Then soc = soc + net
        End If
    Next i
End Sub

Public Function SoldeCaisse(ByVal caisse As String, ByVal asOf As Date) As Double
    Dim esp As Double, bq As Double, soc As Double
    Soldes asOf, esp, bq, soc
    If caisse = CAISSE_ESP Then SoldeCaisse = esp Else SoldeCaisse = bq
End Function

Public Sub AfficherSoldes()
    Dim sh As Worksheet, esp As Double, bq As Double, soc As Double, lr As Long
    If Not RequireLogin() Then Exit Sub
    Set sh = WS(SH_SAISIE)
    Soldes Date + 3650, esp, bq, soc
    sh.Range("G5").Value = esp
    sh.Range("G6").Value = bq
    sh.Range("G7").Value = esp + bq
    sh.Range("G8").Value = soc
    lr = LastRow(WS(SH_CAISSE), 1)
    If lr >= FIRSTROW Then sh.Range("G9").Value = WS(SH_CAISSE).Cells(lr, CJ_PIECE).Value Else sh.Range("G9").Value = ""
    sh.Range("G10").Value = DernierRecu()
    sh.Range("F4").Value = "Soldes au " & Format$(Date, "dd/mm/yyyy")
End Sub

Private Function DernierRecu() As String
    Dim sh As Worksheet, r As Long
    Set sh = WS(SH_CAISSE)
    For r = LastRow(sh, 1) To FIRSTROW Step -1
        If CStr(sh.Cells(r, CJ_RECU).Value) <> "" Then
            DernierRecu = CStr(sh.Cells(r, CJ_RECU).Value)
            Exit Function
        End If
    Next r
End Function

' ============================================================ saisie
Public Sub SaisieEnregistrer()
    Dim piece As String
    If Not RequireEdit(SH_SAISIE) Then Exit Sub
    piece = EnregistrerSaisie(False)
    If piece = "" And G_LastError <> "" Then MsgBox G_LastError, vbExclamation, APP_NAME
End Sub

' Lit le formulaire SAISIE_CAISSE, controle et enregistre. Renvoie la piece ("" si refus).
Public Function EnregistrerSaisie(ByVal silencieux As Boolean) As String
    Dim sh As Worksheet, d As Date, caisse As String, oper As String, code As String, libelle As String
    Dim qui As String, mat As String, tiers As String, montant As Double, ref As String, autor As String
    Dim dest As String, p1 As String, p2 As String, solde As Double, esp As Double, bq As Double, soc As Double
    Dim sens As String, recu As String, r As Long, txt As String
    G_LastError = ""
    On Error GoTo EH
    Set sh = WS(SH_SAISIE)
    d = AsDate(sh.Range("C5").Value)
    caisse = Trim$(CStr(sh.Range("C6").Value))
    oper = Trim$(CStr(sh.Range("C7").Value))
    code = CodeDeChoix(CStr(sh.Range("C8").Value))
    libelle = Trim$(CStr(sh.Range("C9").Value))
    qui = Trim$(CStr(sh.Range("C10").Value))
    txt = Replace(Replace(CStr(sh.Range("C11").Value), " ", ""), Chr$(160), "")
    ref = Trim$(CStr(sh.Range("C12").Value))
    autor = Trim$(CStr(sh.Range("C13").Value))
    dest = Trim$(CStr(sh.Range("C14").Value))

    If d = 0 Then G_LastError = "Date invalide.": Exit Function
    If caisse <> CAISSE_ESP And caisse <> CAISSE_BQ Then G_LastError = "Choisissez la caisse (Espèces ou Banque).": Exit Function
    If oper <> "Recette" And oper <> "Dépense" And oper <> "Virement" Then G_LastError = "Choisissez l'opération (Recette, Dépense ou Virement).": Exit Function
    If Not IsNumeric(txt) Then G_LastError = "Montant invalide.": Exit Function
    montant = CDbl(txt)
    If montant <= 0 Or montant <> Int(montant) Then G_LastError = "Le montant doit être un nombre entier positif.": Exit Function
    If ExerciceClos(ExerciceDe(d)) Then G_LastError = "L'exercice " & ExerciceDe(d) & " est clôturé.": Exit Function
    If libelle = "" Then G_LastError = "Le libellé est obligatoire.": Exit Function

    If qui <> "" Then
        If MembreRow(qui) > 0 Then
            mat = UCase$(qui)
            tiers = NomComplet(MembreValeur(mat, "Nom"), MembreValeur(mat, "Prénoms"))
        Else
            tiers = qui
        End If
    End If

    Soldes Date + 3650, esp, bq, soc
    If caisse = CAISSE_ESP Then solde = esp Else solde = bq

    If oper = "Virement" Then
        If dest <> CAISSE_ESP And dest <> CAISSE_BQ Or dest = caisse Then G_LastError = "Choisissez une caisse de destination différente de la caisse de départ.": Exit Function
        If montant > solde And Not silencieux Then
            If MsgBox("Le virement (" & Fcfa(montant) & ") dépasse le solde de la caisse " & caisse & " (" & Fcfa(solde) & "). Continuer ?", vbYesNo + vbExclamation, APP_NAME) <> vbYes Then Exit Function
        End If
        BeginWork
        p1 = EnregistrerEcriture(d, caisse, "Virement sortant", CODE_VIREMENT, libelle, mat, tiers, ref, montant, autor, "Validée", "", False)
        p2 = EnregistrerEcriture(d, dest, "Virement entrant", CODE_VIREMENT, libelle, mat, tiers, ref, montant, autor, "Validée", p1, False)
        r = JournalRow(p1)
        WS(SH_CAISSE).Cells(r, CJ_LIEE).Value = p2
        EndWork
        LogAction "Virement", p1 & " / " & p2 & " : " & Fcfa(montant) & " de " & caisse & " vers " & dest, SH_CAISSE
        EnregistrerSaisie = p1
    Else
        If code = "" Or RubRow(code) = 0 Then G_LastError = "Choisissez une rubrique valide.": Exit Function
        If UCase$(CStr(RubValeur(code, "Actif"))) = "NON" Then G_LastError = "La rubrique " & code & " est désactivée.": Exit Function
        sens = CStr(RubValeur(code, "Sens"))
        If sens <> oper Then G_LastError = "La rubrique " & code & " est une rubrique de " & LCase$(sens) & " : elle ne convient pas à une " & LCase$(oper) & ".": Exit Function
        If oper = "Dépense" Then
            If montant >= ParamNum("SEUIL_AUTORISATION", 10000) And autor = "" Then
                G_LastError = "Dépense de " & Fcfa(montant) & " : la référence de l'autorisation du Bureau est obligatoire (art. 16-5)."
                Exit Function
            End If
            If Not silencieux Then
                If montant > solde Then
                    If MsgBox("Cette dépense (" & Fcfa(montant) & ") dépasse le solde de la caisse " & caisse & " (" & Fcfa(solde) & "). Continuer ?", vbYesNo + vbExclamation, APP_NAME) <> vbYes Then Exit Function
                End If
                If CStr(RubValeur(code, "Fonds")) = "SOCIAL" And montant > soc Then
                    If MsgBox("Cette dépense dépasse le solde de la caisse sociale (" & Fcfa(soc) & "). Continuer ?", vbYesNo + vbExclamation, APP_NAME) <> vbYes Then Exit Function
                End If
            End If
        End If
        BeginWork
        p1 = EnregistrerEcriture(d, caisse, oper, code, libelle, mat, tiers, ref, montant, autor, "Validée", "", (oper = "Recette" And qui <> ""))
        EndWork
        recu = RecuDePiece(p1)
        LogAction oper, p1 & " " & code & " : " & Fcfa(montant) & " - " & libelle, SH_CAISSE
        EnregistrerSaisie = p1
    End If

    BeginWork
    sh.Range("C8:C14").ClearContents
    EndWork
    If Not silencieux Then
        AfficherSoldes
        If recu <> "" Then
            If MsgBox("Écriture " & p1 & " enregistrée. Reçu " & recu & "." & vbCrLf & vbCrLf & "Imprimer le reçu maintenant ?", vbYesNo + vbQuestion, APP_NAME) = vbYes Then
                If RemplirRecu(recu) Then ApercuRecu
            End If
        Else
            MsgBox "Écriture " & p1 & IIf(p2 <> "", " / " & p2, "") & " enregistrée.", vbInformation, APP_NAME
        End If
        If oper = "Dépense" And Left$(code, Len(ParamStr("PREFIXE_ACHAT_MATERIEL", "D04"))) = ParamStr("PREFIXE_ACHAT_MATERIEL", "D04") Then ProposerFicheDepuisPiece p1
    End If
    Exit Function
EH:
    G_LastError = Err.Description
    EndWork
    LogAction "Erreur", "Saisie de caisse : " & Err.Description, SH_SAISIE
End Function

Public Sub SaisieEffacer()
    If Not RequireEdit(SH_SAISIE) Then Exit Sub
    With WS(SH_SAISIE)
        .Range("C5:C14").ClearContents
        .Range("C5").Value = Date
        .Range("C6").Value = CAISSE_ESP
        .Range("C7").Value = "Recette"
    End With
End Sub

Public Sub AllerSaisie()
    If Not RequireLogin() Then Exit Sub
    WS(SH_SAISIE).Activate
    If CStr(WS(SH_SAISIE).Range("C5").Value) = "" And CanEdit(SH_SAISIE) Then SaisieEffacer
    AfficherSoldes
End Sub

' ============================================================ annulation
Public Sub AnnulerEcriture()
    Dim sh As Worksheet, piece As String, motif As String, p As String
    If ModuleRight("FINANCES") <> "M" Then
        MsgBox "Seul le Secrétaire aux Finances (ou son intérimaire) peut annuler une écriture.", vbExclamation, APP_NAME
        Exit Sub
    End If
    Set sh = WS(SH_CAISSE)
    If ActiveSheet.Name <> SH_CAISSE Or ActiveCell.Row < FIRSTROW Then
        MsgBox "Sélectionnez d'abord la ligne de l'écriture à annuler.", vbInformation, APP_NAME
        Exit Sub
    End If
    piece = CStr(sh.Cells(ActiveCell.Row, CJ_PIECE).Value)
    If piece = "" Then Exit Sub
    motif = Trim$(InputBox("Motif de l'annulation de " & piece & " :", APP_NAME))
    If motif = "" Then Exit Sub
    p = AnnulerPiece(piece, motif)
    If p = "" Then
        MsgBox G_LastError, vbExclamation, APP_NAME
    Else
        MsgBox "Écriture " & piece & " annulée par " & p & ".", vbInformation, APP_NAME
    End If
End Sub

Public Function AnnulerPiece(ByVal piece As String, ByVal motif As String) As String
    Dim sh As Worksheet, r As Long, pieces As Variant, i As Long, np As String, first As String
    Dim twin As String, lst As String
    G_LastError = ""
    On Error GoTo EH
    Set sh = WS(SH_CAISSE)
    r = JournalRow(piece)
    If r = 0 Then G_LastError = "Pièce introuvable : " & piece: Exit Function
    If CStr(sh.Cells(r, CJ_STATUT).Value) <> "Validée" Then G_LastError = "Seule une écriture « Validée » peut être annulée.": Exit Function
    If ExerciceClos(CStr(sh.Cells(r, CJ_EXO).Value)) Then G_LastError = "L'exercice de cette écriture est clôturé.": Exit Function
    lst = piece
    If CStr(sh.Cells(r, CJ_CODE).Value) = CODE_VIREMENT Then
        twin = CStr(sh.Cells(r, CJ_LIEE).Value)
        If twin <> "" Then lst = lst & ";" & twin
    End If
    pieces = Split(lst, ";")
    BeginWork
    For i = LBound(pieces) To UBound(pieces)
        r = JournalRow(CStr(pieces(i)))
        If r > 0 Then
            np = EnregistrerEcriture(AsDate(sh.Cells(r, CJ_DATE).Value), CStr(sh.Cells(r, CJ_CAISSE).Value), CStr(sh.Cells(r, CJ_OPER).Value), _
                    CStr(sh.Cells(r, CJ_CODE).Value), "Annulation de " & pieces(i) & " : " & motif, CStr(sh.Cells(r, CJ_MAT).Value), _
                    CStr(sh.Cells(r, CJ_TIERS).Value), CStr(sh.Cells(r, CJ_REF).Value), _
                    -(NumV(sh.Cells(r, CJ_REC).Value) + NumV(sh.Cells(r, CJ_DEP).Value)), "", "Contre-passation", CStr(pieces(i)), False)
            sh.Cells(r, CJ_STATUT).Value = "Annulée"
            sh.Cells(r, CJ_LIEE).Value = Trim$(CStr(sh.Cells(r, CJ_LIEE).Value) & IIf(CStr(sh.Cells(r, CJ_LIEE).Value) <> "", " ; ", "") & np)
            If first = "" Then first = np
        End If
    Next i
    EndWork
    LogAction "Écriture annulée", piece & " par " & first & " : " & motif, SH_CAISSE
    AnnulerPiece = first
    Exit Function
EH:
    G_LastError = Err.Description
    EndWork
End Function

' ============================================================ recus
Public Sub ImprimerRecu()
    Dim num As String, sh As Worksheet
    If Not RequireLogin() Then Exit Sub
    Set sh = WS(SH_CAISSE)
    If ActiveSheet.Name = SH_CAISSE And ActiveCell.Row >= FIRSTROW Then num = CStr(sh.Cells(ActiveCell.Row, CJ_RECU).Value)
    If num = "" Then num = DernierRecu()
    num = Trim$(InputBox("Numéro du reçu à imprimer :", APP_NAME, num))
    If num = "" Then Exit Sub
    If RemplirRecu(num) Then
        ApercuRecu
    Else
        MsgBox "Reçu introuvable : " & num, vbExclamation, APP_NAME
    End If
End Sub

Public Function RemplirRecu(ByVal num As String) As Boolean
    Dim sh As Worksheet, rs As Worksheet, r As Long, montant As Double, objet As String
    Set sh = WS(SH_CAISSE)
    For r = LastRow(sh, 1) To FIRSTROW Step -1
        If CStr(sh.Cells(r, CJ_RECU).Value) = num Then Exit For
    Next r
    If r < FIRSTROW Then Exit Function
    Set rs = WS(SH_RECU)
    montant = NumV(sh.Cells(r, CJ_REC).Value)
    objet = CStr(sh.Cells(r, CJ_SRUB).Value) & " - " & CStr(sh.Cells(r, CJ_LIB).Value)
    BeginWork
    rs.Range("A1").Value = "  " & ParamStr("NOM_GROUPE")
    rs.Range("B3").Value = "REÇU DE CAISSE"
    rs.Range("B4").Value = ParamStr("EGLISE") & "  ·  " & ParamStr("PAROISSE")
    rs.Range("C6").Value = num & IIf(CStr(sh.Cells(r, CJ_STATUT).Value) = "Annulée", "   (ANNULÉ)", "")
    rs.Range("C7").NumberFormat = "dd/mm/yyyy"
    rs.Range("C7").HorizontalAlignment = xlLeft
    rs.Range("C7").Value = AsDate(sh.Cells(r, CJ_DATE).Value)
    rs.Range("C8").Value = Trim$(CStr(sh.Cells(r, CJ_TIERS).Value) & IIf(CStr(sh.Cells(r, CJ_MAT).Value) <> "", " (" & sh.Cells(r, CJ_MAT).Value & ")", ""))
    rs.Range("C9").Value = Fcfa(montant)
    rs.Range("C10").Value = EnLettres(montant) & " francs CFA"
    rs.Range("C11").Value = objet
    rs.Range("C12").Value = CStr(sh.Cells(r, CJ_CAISSE).Value)
    rs.Range("C13").Value = CStr(sh.Cells(r, CJ_PIECE).Value)
    EndWork
    RemplirRecu = True
End Function

Public Sub ApercuRecu()
    On Error Resume Next
    If G_TestMode Then Exit Sub
    WS(SH_RECU).Activate
    WS(SH_RECU).PrintPreview
End Sub

' Montant en toutes lettres (orthographe traditionnelle)
Public Function EnLettres(ByVal n As Double) As String
    Dim mil As Double, mio As Double, k As Long, reste As Long, s As String
    n = Int(Abs(n))
    If n = 0 Then
        EnLettres = "zéro"
        Exit Function
    End If
    mil = Int(n / 1000000000#)
    n = n - mil * 1000000000#
    mio = Int(n / 1000000#)
    n = n - mio * 1000000#
    k = CLng(Int(n / 1000))
    reste = CLng(n - k * 1000#)
    If mil > 0 Then s = s & IIf(mil = 1, "un milliard", Moins1000(CLng(mil), True) & " milliards") & " "
    If mio > 0 Then s = s & IIf(mio = 1, "un million", Moins1000(CLng(mio), True) & " millions") & " "
    If k > 0 Then s = s & IIf(k = 1, "mille", Moins1000(k, False) & " mille") & " "
    If reste > 0 Then s = s & Moins1000(reste, True)
    EnLettres = Trim$(s)
End Function

Private Function Unite(ByVal n As Long) As String
    Unite = Choose(n + 1, "zéro", "un", "deux", "trois", "quatre", "cinq", "six", "sept", "huit", "neuf", "dix", _
                   "onze", "douze", "treize", "quatorze", "quinze", "seize")
End Function

Private Function Moins100(ByVal n As Long) As String
    Dim t As Long, u As Long, radical As String
    If n < 17 Then
        Moins100 = Unite(n)
        Exit Function
    End If
    If n < 20 Then
        Moins100 = "dix-" & Unite(n - 10)
        Exit Function
    End If
    t = n \ 10
    u = n Mod 10
    If t = 7 Or t = 9 Then
        radical = IIf(t = 7, "soixante", "quatre-vingt")
        If t = 7 And u = 1 Then
            Moins100 = "soixante et onze"
        Else
            Moins100 = radical & "-" & Moins100(10 + u)
        End If
        Exit Function
    End If
    radical = Choose(t - 1, "vingt", "trente", "quarante", "cinquante", "soixante", "", "quatre-vingt")
    If u = 0 Then
        Moins100 = radical & IIf(t = 8, "s", "")
    ElseIf u = 1 And t < 8 Then
        Moins100 = radical & " et un"
    Else
        Moins100 = radical & "-" & Unite(u)
    End If
End Function

Private Function Moins1000(ByVal n As Long, ByVal finale As Boolean) As String
    Dim h As Long, r As Long, s As String
    h = n \ 100
    r = n Mod 100
    If h = 1 Then
        s = "cent"
    ElseIf h > 1 Then
        s = Unite(h) & " cent"
        If r = 0 And finale Then s = s & "s"
    End If
    If r > 0 Then s = Trim$(s & " " & Moins100(r))
    If Not finale And Right$(s, 13) = "quatre-vingts" Then s = Left$(s, Len(s) - 1)
    Moins1000 = s
End Function

' ============================================================ arrete de caisse
Public Sub CalculerTheorique()
    If Not RequireLogin() Then Exit Sub
    WS(SH_ARRETE).Range("D19").Value = SoldeCaisse(CAISSE_ESP, Date)
    WS(SH_ARRETE).Range("E8").Value = "Solde théorique calculé le " & Format$(Now, "dd/mm/yyyy hh:mm")
End Sub

Public Sub EnregistrerArrete()
    Dim sh As Worksheet, compte As Double, ecart As Double, traiter As Boolean
    If Not RequireEdit(SH_ARRETE) Then Exit Sub
    Set sh = WS(SH_ARRETE)
    CalculerTheorique
    compte = NumV(sh.Range("D18").Value)
    ecart = compte - NumV(sh.Range("D19").Value)
    If MsgBox("Total compté : " & Fcfa(compte) & vbCrLf & "Solde du livre : " & Fcfa(NumV(sh.Range("D19").Value)) & vbCrLf & _
              "Écart : " & Fcfa(ecart) & vbCrLf & vbCrLf & "Enregistrer cet arrêté de caisse ?", vbYesNo + vbQuestion, APP_NAME) <> vbYes Then Exit Sub
    If ecart <> 0 Then
        traiter = (MsgBox("Enregistrer l'écart dans le journal ?" & vbCrLf & _
            IIf(ecart < 0, "Un manquant de " & Fcfa(-ecart) & " sera passé en dépense et inscrit au registre des pertes.", _
                           "Un excédent de " & Fcfa(ecart) & " sera passé en recette."), vbYesNo + vbQuestion, APP_NAME) = vbYes)
    End If
    EnregistrerArreteInterne compte, CStr(sh.Range("C21").Value), traiter
    MsgBox "Arrêté de caisse enregistré (feuille ARRETES).", vbInformation, APP_NAME
End Sub

Public Function EnregistrerArreteInterne(ByVal compte As Double, ByVal obs As String, ByVal traiterEcart As Boolean) As Double
    Dim theo As Double, ecart As Double, piece As String, ar As Worksheet, r As Long
    theo = SoldeCaisse(CAISSE_ESP, Date)
    ecart = compte - theo
    If ecart <> 0 And traiterEcart Then
        If ecart < 0 Then
            piece = EnregistrerEcriture(Date, CAISSE_ESP, "Dépense", ParamStr("CODE_MANQUANT", "D10.2"), "Manquant constaté à l'arrêté de caisse du " & Format$(Date, "dd/mm/yyyy"), _
                    "", "", "", -ecart, "Arrêté de caisse", "Validée", "", False)
            AjouterPerte "Manquant de caisse", "", "", "Arrêté de caisse du " & Format$(Date, "dd/mm/yyyy") & " (" & piece & ")", -ecart, Date
        Else
            piece = EnregistrerEcriture(Date, CAISSE_ESP, "Recette", ParamStr("CODE_EXCEDENT", "R09.2"), "Excédent constaté à l'arrêté de caisse du " & Format$(Date, "dd/mm/yyyy"), _
                    "", "", "", ecart, "", "Validée", "", False)
        End If
    End If
    Set ar = WS(SH_ARRETES)
    r = LastRow(ar, 1) + 1
    ar.Cells(r, 1).Value = Now
    ar.Cells(r, 2).Value = CAISSE_ESP
    ar.Cells(r, 3).Value = theo
    ar.Cells(r, 4).Value = compte
    ar.Cells(r, 5).Value = ecart
    ar.Cells(r, 6).Value = piece
    ar.Cells(r, 7).Value = obs
    ar.Cells(r, 8).Value = G_RoleLabel
    LogAction "Arrêté de caisse", "Compté " & Fcfa(compte) & ", livre " & Fcfa(theo) & ", écart " & Fcfa(ecart), SH_ARRETES
    EnregistrerArreteInterne = ecart
End Function

Public Sub RemettreAZeroComptage()
    If Not RequireEdit(SH_ARRETE) Then Exit Sub
    WS(SH_ARRETE).Range("C5:C17").ClearContents
    WS(SH_ARRETE).Range("C21").ClearContents
    WS(SH_ARRETE).Range("D19").Value = 0
End Sub

Public Sub RapprochementBancaire()
    Dim sd As String, d As Date, s As String, ecart As Double
    If Not RequireEdit(SH_ARRETE) Then Exit Sub
    sd = InputBox("Date du relevé bancaire (jj/mm/aaaa) :", APP_NAME, Format$(Date, "dd/mm/yyyy"))
    If sd = "" Or Not IsDate(sd) Then Exit Sub
    d = CDate(sd)
    s = Replace(InputBox("Solde figurant sur le relevé au " & Format$(d, "dd/mm/yyyy") & " (FCFA) :", APP_NAME), " ", "")
    If s = "" Or Not IsNumeric(s) Then Exit Sub
    ecart = RapprochementInterne(d, CDbl(s), "")
    MsgBox "Rapprochement enregistré." & vbCrLf & "Écart relevé - livre : " & Fcfa(ecart) & _
           IIf(ecart <> 0, vbCrLf & "Expliquez l'écart (frais bancaires, opérations non encore passées...) et enregistrez les écritures manquantes.", ""), _
           IIf(ecart = 0, vbInformation, vbExclamation), APP_NAME
End Sub

Public Function RapprochementInterne(ByVal d As Date, ByVal releve As Double, ByVal obs As String) As Double
    Dim theo As Double, ar As Worksheet, r As Long
    theo = SoldeCaisse(CAISSE_BQ, d)
    Set ar = WS(SH_ARRETES)
    r = LastRow(ar, 1) + 1
    ar.Cells(r, 1).Value = d
    ar.Cells(r, 2).Value = CAISSE_BQ
    ar.Cells(r, 3).Value = theo
    ar.Cells(r, 4).Value = releve
    ar.Cells(r, 5).Value = releve - theo
    ar.Cells(r, 7).Value = IIf(obs = "", "Rapprochement bancaire", obs)
    ar.Cells(r, 8).Value = G_RoleLabel
    LogAction "Rapprochement bancaire", "Relevé " & Fcfa(releve) & ", livre " & Fcfa(theo), SH_ARRETES
    RapprochementInterne = releve - theo
End Function

' ============================================================ pertes (art. 51)
Public Function AjouterPerte(ByVal typ As String, ByVal mat As String, ByVal tiers As String, ByVal desc As String, _
                             ByVal montant As Double, ByVal d As Date) As String
    Dim ps As Worksheet, r As Long, num As String, k As Long, n As Long, mx As Long, v As String, pre As String
    Set ps = WS(SH_PERTES)
    pre = "PER-" & Year(d) & "-"
    For k = FIRSTROW To LastRow(ps, 1)
        v = CStr(ps.Cells(k, 1).Value)
        If Left$(v, Len(pre)) = pre Then
            n = CLng(Val(Mid$(v, Len(pre) + 1)))
            If n > mx Then mx = n
        End If
    Next k
    num = pre & Format$(mx + 1, "000")
    r = LastRow(ps, 1) + 1
    ps.Cells(r, 1).Value = num
    ps.Cells(r, 2).Value = d
    ps.Cells(r, 3).Value = typ
    ps.Cells(r, 4).Value = mat
    If mat <> "" And tiers = "" Then tiers = NomComplet(MembreValeur(mat, "Nom"), MembreValeur(mat, "Prénoms"))
    ps.Cells(r, 5).Value = tiers
    ps.Cells(r, 6).Value = desc
    ps.Cells(r, 7).Value = montant
    ps.Cells(r, 8).Value = 0
    ps.Cells(r, 9).Value = montant
    ps.Cells(r, 11).Value = "En cours"
    LogAction "Perte enregistrée", num & " " & typ & " : " & Fcfa(montant), SH_PERTES
    AjouterPerte = num
End Function

Public Sub NouvellePerte()
    Dim t As String, typ As String, s As String, qui As String, desc As String, mat As String, tiers As String, lst As Collection, i As Long, txt As String
    If Not RequireEdit(SH_PERTES) Then Exit Sub
    Set lst = ListValues("Type de perte")
    For i = 1 To lst.Count
        txt = txt & vbCrLf & "  " & i & " - " & lst(i)
    Next i
    t = InputBox("Type de perte (tapez le numéro) :" & txt, APP_NAME, "1")
    If t = "" Or Not IsNumeric(t) Then Exit Sub
    If CLng(t) < 1 Or CLng(t) > lst.Count Then Exit Sub
    typ = lst(CLng(t))
    s = Replace(InputBox("Montant de la perte (FCFA) :", APP_NAME), " ", "")
    If s = "" Or Not IsNumeric(s) Then Exit Sub
    qui = Trim$(InputBox("Matricule du membre responsable, ou nom du tiers (facultatif) :", APP_NAME))
    desc = Trim$(InputBox("Description :", APP_NAME))
    If qui <> "" Then
        If MembreRow(qui) > 0 Then mat = UCase$(qui) Else tiers = qui
    End If
    BeginWork
    AjouterPerte typ, mat, tiers, desc, CDbl(s), Date
    EndWork
End Sub

Public Sub ActualiserPertes()
    Dim ps As Worksheet, r As Long, num As String, i As Long, remb As Double, code As String, montant As Double
    If Not RequireLogin() Then Exit Sub
    Set ps = WS(SH_PERTES)
    code = ParamStr("CODE_REMBOURSEMENT", "R09.3")
    LoadJournal
    BeginWork
    For r = FIRSTROW To LastRow(ps, 1)
        num = CStr(ps.Cells(r, 1).Value)
        If num <> "" Then
            remb = 0
            For i = 1 To G_JN
                If CStr(G_J(i, CJ_REF)) = num And CStr(G_J(i, CJ_CODE)) = code Then remb = remb + NumV(G_J(i, CJ_REC)) - NumV(G_J(i, CJ_DEP))
            Next i
            montant = NumV(ps.Cells(r, 7).Value)
            ps.Cells(r, 8).Value = remb
            ps.Cells(r, 9).Value = montant - remb
            If montant - remb <= 0 Then
                ps.Cells(r, 11).Value = "Soldée"
            ElseIf CStr(ps.Cells(r, 11).Value) = "Soldée" Or CStr(ps.Cells(r, 11).Value) = "" Then
                ps.Cells(r, 11).Value = "En cours"
            End If
        End If
    Next r
    EndWork
End Sub

Public Sub RemboursementPerte()
    Dim ps As Worksheet, r As Long, num As String, s As String, caisse As String, piece As String
    If Not RequireLogin() Then Exit Sub
    If ModuleRight("FINANCES") <> "M" Then
        MsgBox "L'encaissement est réservé au Secrétaire aux Finances.", vbExclamation, APP_NAME
        Exit Sub
    End If
    Set ps = WS(SH_PERTES)
    If ActiveSheet.Name <> SH_PERTES Or ActiveCell.Row < FIRSTROW Then
        MsgBox "Sélectionnez d'abord la ligne de la perte.", vbInformation, APP_NAME
        Exit Sub
    End If
    r = ActiveCell.Row
    num = CStr(ps.Cells(r, 1).Value)
    If num = "" Then Exit Sub
    s = Replace(InputBox("Montant remboursé pour " & num & " (FCFA) :", APP_NAME, CStr(NumV(ps.Cells(r, 9).Value))), " ", "")
    If s = "" Or Not IsNumeric(s) Then Exit Sub
    If CDbl(s) <= 0 Then Exit Sub
    caisse = ChoisirCaisse()
    If caisse = "" Then Exit Sub
    On Error GoTo EH
    BeginWork
    piece = EnregistrerEcriture(Date, caisse, "Recette", ParamStr("CODE_REMBOURSEMENT", "R09.3"), "Remboursement " & num, _
            CStr(ps.Cells(r, 4).Value), CStr(ps.Cells(r, 5).Value), num, CDbl(s), "", "Validée", "", True)
    EndWork
    ActualiserPertes
    LogAction "Remboursement", num & " : " & Fcfa(CDbl(s)) & " (" & piece & ")", SH_PERTES
    If MsgBox("Remboursement enregistré (" & piece & ", reçu " & RecuDePiece(piece) & "). Imprimer le reçu ?", vbYesNo + vbQuestion, APP_NAME) = vbYes Then
        If RemplirRecu(RecuDePiece(piece)) Then ApercuRecu
    End If
    Exit Sub
EH:
    ShowError "Remboursement"
End Sub

' ============================================================ cloture d'exercice
Public Sub CloturerExercice()
    Dim lbl As String
    If Not RequireEdit(SH_CLOTURES) Then Exit Sub
    lbl = Trim$(InputBox("Exercice à clôturer :" & vbCrLf & "(après clôture, plus aucune écriture n'est possible sur cet exercice)", _
                         APP_NAME, ExerciceLabel(ExerciceAnnee(Date) - 1)))
    If lbl = "" Then Exit Sub
    If MsgBox("Clôturer définitivement l'exercice " & lbl & " ?", vbYesNo + vbExclamation, APP_NAME) <> vbYes Then Exit Sub
    If CloturerExerciceInterne(lbl) Then
        MsgBox "Exercice " & lbl & " clôturé. Les soldes de fin sont repris automatiquement sur l'exercice suivant.", vbInformation, APP_NAME
    Else
        MsgBox G_LastError, vbExclamation, APP_NAME
    End If
End Sub

Public Function CloturerExerciceInterne(ByVal lbl As String) As Boolean
    Dim fin As Date, esp As Double, bq As Double, soc As Double, i As Long, rec As Double, dep As Double, cs As Worksheet, r As Long, cur As String
    G_LastError = ""
    If ExerciceClos(lbl) Then G_LastError = "L'exercice " & lbl & " est déjà clôturé.": Exit Function
    If ExerciceDebut(lbl) > Date Then G_LastError = "L'exercice " & lbl & " n'a pas commencé.": Exit Function
    fin = ExerciceFin(lbl)
    Soldes fin, esp, bq, soc
    For i = 1 To G_JN
        If CStr(G_J(i, CJ_EXO)) = lbl And CStr(G_J(i, CJ_CODE)) <> CODE_VIREMENT Then
            rec = rec + NumV(G_J(i, CJ_REC))
            dep = dep + NumV(G_J(i, CJ_DEP))
        End If
    Next i
    BeginWork
    Set cs = WS(SH_CLOTURES)
    r = LastRow(cs, 1) + 1
    cs.Cells(r, 1).Value = lbl
    cs.Cells(r, 2).Value = Now
    cs.Cells(r, 3).Value = esp
    cs.Cells(r, 4).Value = bq
    cs.Cells(r, 5).Value = soc
    cs.Cells(r, 6).Value = rec
    cs.Cells(r, 7).Value = dep
    cs.Cells(r, 8).Value = rec - dep
    cs.Cells(r, 9).Value = G_RoleLabel
    cur = ParamStr("EXERCICES_CLOTURES")
    SetParam "EXERCICES_CLOTURES", IIf(cur = "", lbl, cur & ";" & lbl)
    EndWork
    LogAction "Clôture d'exercice", lbl & " : résultat " & Fcfa(rec - dep), SH_CLOTURES
    CloturerExerciceInterne = True
End Function
