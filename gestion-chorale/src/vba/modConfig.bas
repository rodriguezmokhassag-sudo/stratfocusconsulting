Option Explicit
' =============================================================================
' modConfig : constantes, noms de feuilles, parametres et fonctions utilitaires
' =============================================================================

Public Const APP_NAME As String = "Gestion Chorale"
Public Const APP_VERSION As String = "1.0.0 - lot 1"
Public Const SYS_PWD As String = "Ch0rale#Sys2026"

Public Const HDR As Long = 4            ' ligne d'en-tete des tables de donnees
Public Const FIRSTROW As Long = 5       ' premiere ligne de donnees
Public Const OUT_HDR As Long = 8        ' ligne d'en-tete des feuilles de resultats
Public Const OUT_FIRST As Long = 9      ' premiere ligne des feuilles de resultats
Public Const MAXROWS As Long = 5000

Public Const SH_ACCUEIL As String = "ACCUEIL"
Public Const SH_PARAM As String = "PARAMETRES"
Public Const SH_LISTES As String = "LISTES"
Public Const SH_TYPES As String = "TYPES_ACTIVITE"
Public Const SH_CODES As String = "CODES_PRESENCE"
Public Const SH_CTRL As String = "CONTROLES_ADHESION"
Public Const SH_USERS As String = "UTILISATEURS"
Public Const SH_SEC As String = "SECURITE"
Public Const SH_DROITS As String = "DROITS"
Public Const SH_MEMBRES As String = "MEMBRES"
Public Const SH_ADH As String = "ADHESIONS"
Public Const SH_SEANCES As String = "SEANCES"
Public Const SH_POINTAGE As String = "POINTAGE"
Public Const SH_PRES As String = "PRESENCES"
Public Const SH_TAUX As String = "TAUX"
Public Const SH_ELEC As String = "ELECTEURS"
Public Const SH_FICHE As String = "FICHE_APPEL"
Public Const SH_PAT As String = "PATRIMOINE"
Public Const SH_JOURNAL As String = "JOURNAL"

Public Const ST_OBS As String = "En observation"
Public Const ST_CONF As String = "Choriste confirm" & "é"
Public Const ST_REFROIDI As String = "Refroidi"
Public Const ST_NONRETENU As String = "Non retenu"

Public G_Busy As Boolean
Private m_StNames() As String, m_StCodes() As String, m_StN As Long   ' cache des statuts
Public G_TestMode As Boolean   ' tests automatises (LibreOffice) : pas de protection

' ----------------------------------------------------------------- feuilles
Public Function WS(ByVal nom As String) As Worksheet
    Set WS = ThisWorkbook.Worksheets(nom)
End Function

Public Function LastRow(ByVal sh As Worksheet, Optional ByVal col_ As Long = 1, Optional ByVal minRow_ As Long = HDR) As Long
    Dim col As Long: col = col_   ' copie locale (compatibilite LibreOffice)
    Dim minRow As Long: minRow = minRow_   ' copie locale (compatibilite LibreOffice)
    Dim r As Long
    If G_TestMode Then
        ' LibreOffice : End(xlUp) ne fonctionne que sur la feuille active
        r = sh.UsedRange.Row + sh.UsedRange.Rows.Count - 1
        Do While r > 1
            If CStr(sh.Cells(r, col).Value) <> "" Then Exit Do
            r = r - 1
        Loop
    Else
        r = sh.Cells(sh.Rows.Count, col).End(xlUp).Row
    End If
    If r < minRow Then r = minRow
    LastRow = r
End Function

Public Function LastCol(ByVal sh As Worksheet, Optional ByVal hdrRow_ As Long = HDR) As Long
    Dim hdrRow As Long: hdrRow = hdrRow_   ' copie locale (compatibilite LibreOffice)
    Dim c As Long
    If G_TestMode Then
        c = sh.UsedRange.Column + sh.UsedRange.Columns.Count - 1
        Do While c > 1
            If CStr(sh.Cells(hdrRow, c).Value) <> "" Then Exit Do
            c = c - 1
        Loop
        LastCol = c
    Else
        LastCol = sh.Cells(hdrRow, sh.Columns.Count).End(xlToLeft).Column
    End If
End Function

Public Function ColOf(ByVal sh As Worksheet, ByVal entete As String, Optional ByVal mustExist_ As Boolean = True, Optional ByVal hdrRow_ As Long = HDR) As Long
    Dim mustExist As Boolean: mustExist = mustExist_   ' copie locale (compatibilite LibreOffice)
    Dim hdrRow As Long: hdrRow = hdrRow_   ' copie locale (compatibilite LibreOffice)
    Dim c As Long, lc As Long
    lc = LastCol(sh, hdrRow)
    For c = 1 To lc
        If StrComp(Trim$(CStr(sh.Cells(hdrRow, c).Value)), entete, vbTextCompare) = 0 Then
            ColOf = c
            Exit Function
        End If
    Next c
    If mustExist Then Err.Raise vbObjectError + 513, APP_NAME, "Colonne introuvable : " & entete & " (feuille " & sh.Name & ")"
End Function

' Colonnes de la liste de controle d'adhesion : en-tetes "01 · libelle"
Public Function CheckCol(ByVal sh As Worksheet, ByVal n As Long) As Long
    Dim c As Long, lc As Long, pre As String
    pre = Format$(n, "00") & " "
    lc = LastCol(sh)
    For c = 1 To lc
        If Left$(CStr(sh.Cells(HDR, c).Value), 3) = pre Then
            CheckCol = c
            Exit Function
        End If
    Next c
End Function

Public Function IsCheckHeader(ByVal h As String) As Boolean
    IsCheckHeader = (Len(h) >= 4 And IsNumeric(Left$(h, 2)) And Mid$(h, 3, 1) = " ")
End Function

' ----------------------------------------------------------------- parametres
Public Function GetParam(ByVal cle As String, Optional ByVal defaut_ As Variant = "") As Variant
    Dim defaut As Variant: defaut = defaut_   ' copie locale (compatibilite LibreOffice)
    Dim sh As Worksheet, r As Long, lr As Long
    Set sh = WS(SH_PARAM)
    lr = LastRow(sh, 1)
    For r = FIRSTROW To lr
        If StrComp(CStr(sh.Cells(r, 1).Value), cle, vbTextCompare) = 0 Then
            If Trim$(CStr(sh.Cells(r, 2).Value)) = "" Then
                GetParam = defaut
            Else
                GetParam = sh.Cells(r, 2).Value
            End If
            Exit Function
        End If
    Next r
    GetParam = defaut
End Function

Public Function ParamNum(ByVal cle As String, ByVal defaut As Double) As Double
    Dim v As Variant
    v = GetParam(cle, defaut)
    If IsNumeric(v) Then ParamNum = CDbl(v) Else ParamNum = defaut
End Function

Public Function ParamStr(ByVal cle As String, Optional ByVal defaut_ As String = "") As String
    Dim defaut As String: defaut = defaut_   ' copie locale (compatibilite LibreOffice)
    ParamStr = CStr(GetParam(cle, defaut))
End Function

Public Function ParamOui(ByVal cle As String, Optional ByVal defaut_ As Boolean = True) As Boolean
    Dim defaut As Boolean: defaut = defaut_   ' copie locale (compatibilite LibreOffice)
    Dim v As String
    v = UCase$(Trim$(ParamStr(cle, IIf(defaut, "OUI", "NON"))))
    ParamOui = (v = "OUI" Or v = "VRAI" Or v = "1")
End Function

Public Sub SetParam(ByVal cle As String, ByVal valeur As Variant)
    Dim sh As Worksheet, r As Long, lr As Long
    Set sh = WS(SH_PARAM)
    lr = LastRow(sh, 1)
    For r = FIRSTROW To lr
        If StrComp(CStr(sh.Cells(r, 1).Value), cle, vbTextCompare) = 0 Then
            sh.Cells(r, 2).Value = valeur
            Exit Sub
        End If
    Next r
    sh.Cells(lr + 1, 1).Value = cle
    sh.Cells(lr + 1, 2).Value = valeur
End Sub

' ----------------------------------------------------------------- listes
Public Function ListValues(ByVal entete As String) As Collection
    Dim sh As Worksheet, c As Long, r As Long, lr As Long, res As New Collection
    Set sh = WS(SH_LISTES)
    c = ColOf(sh, entete)
    lr = LastRow(sh, c)
    For r = FIRSTROW To lr
        If Trim$(CStr(sh.Cells(r, c).Value)) <> "" Then res.Add CStr(sh.Cells(r, c).Value)
    Next r
    Set ListValues = res
End Function

' Valeur d'une colonne de LISTES sur la ligne ou keyHeader = keyValue
Public Function ListLookup(ByVal keyHeader As String, ByVal keyValue As String, ByVal valHeader As String, Optional ByVal defaut_ As Variant = "") As Variant
    Dim defaut As Variant: defaut = defaut_   ' copie locale (compatibilite LibreOffice)
    Dim sh As Worksheet, ck As Long, cv As Long, r As Long, lr As Long
    Set sh = WS(SH_LISTES)
    ck = ColOf(sh, keyHeader)
    cv = ColOf(sh, valHeader)
    lr = LastRow(sh, ck)
    For r = FIRSTROW To lr
        If StrComp(CStr(sh.Cells(r, ck).Value), keyValue, vbTextCompare) = 0 Then
            ListLookup = sh.Cells(r, cv).Value
            Exit Function
        End If
    Next r
    ListLookup = defaut
End Function

' Statuts : pris en compte au pointage ? code par defaut ? (cache recharge a chaque macro)

Public Sub LoadStatuts()
    Dim sh As Worksheet, cS As Long, cP As Long, cC As Long, r As Long, lr As Long
    Set sh = WS(SH_LISTES)
    cS = ColOf(sh, "Statut"): cP = ColOf(sh, "Pointage"): cC = ColOf(sh, "Code par défaut")
    lr = LastRow(sh, cS)
    m_StN = 0
    ReDim m_StNames(1 To lr): ReDim m_StCodes(1 To lr)
    For r = FIRSTROW To lr
        If Trim$(CStr(sh.Cells(r, cS).Value)) <> "" Then
            m_StN = m_StN + 1
            m_StNames(m_StN) = UCase$(Trim$(CStr(sh.Cells(r, cS).Value)))
            If UCase$(Trim$(CStr(sh.Cells(r, cP).Value))) = "OUI" Then
                m_StCodes(m_StN) = UCase$(Trim$(CStr(sh.Cells(r, cC).Value)))
                If m_StCodes(m_StN) = "" Then m_StCodes(m_StN) = "P"
            Else
                m_StCodes(m_StN) = ""
            End If
        End If
    Next r
End Sub

' Code de pointage par defaut d'un statut ("" = membre non pointe)
Public Function StatutCodeDefaut(ByVal statut As String) As String
    Dim i As Long, s As String
    If m_StN = 0 Then LoadStatuts
    s = UCase$(Trim$(statut))
    For i = 1 To m_StN
        If m_StNames(i) = s Then
            StatutCodeDefaut = m_StCodes(i)
            Exit Function
        End If
    Next i
End Function

' Lit en une fois le bloc de donnees d'une feuille (lignes FIRSTROW..derniere).
' Renvoie le nombre de lignes lues (0 si aucune) ; data(i, colonne).
Public Function ReadBlock(ByVal sh As Worksheet, ByVal keyCol As Long, ByRef data As Variant) As Long
    Dim lr As Long, lc As Long
    lr = LastRow(sh, keyCol)
    lc = LastCol(sh)
    If lc < 2 Then lc = 2
    If lr < FIRSTROW Then
        ReadBlock = 0
    Else
        data = sh.Range(sh.Cells(FIRSTROW, 1), sh.Cells(lr, lc)).Value
        ReadBlock = lr - FIRSTROW + 1
    End If
End Function

' ----------------------------------------------------------------- divers
Public Function NomComplet(ByVal nom As Variant, ByVal prenoms As Variant) As String
    NomComplet = Trim$(UCase$(CStr(nom)) & " " & CStr(prenoms))
End Function

Public Function JourCode(ByVal d As Date) As String
    JourCode = Choose(Weekday(d, vbMonday), "LUN", "MAR", "MER", "JEU", "VEN", "SAM", "DIM")
End Function

Public Function JourLong(ByVal d As Date) As String
    JourLong = Choose(Weekday(d, vbMonday), "Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi", "Samedi", "Dimanche")
End Function

Public Function MoisLong(ByVal m As Long) As String
    MoisLong = Choose(m, "janvier", "février", "mars", "avril", "mai", "juin", "juillet", "août", "septembre", "octobre", "novembre", "décembre")
End Function

Public Function AjouterMois(ByVal d As Date, ByVal n As Long) As Date
    AjouterMois = DateSerial(Year(d), Month(d) + n, Day(d))
    If Day(AjouterMois) <> Day(d) Then AjouterMois = DateSerial(Year(d), Month(d) + n + 1, 0)
End Function

Public Function AsDate(ByVal v As Variant, Optional ByVal defaut As Variant) As Date
    Dim dft As Date
    If Not IsMissing(defaut) Then
        If IsDate(defaut) Or IsNumeric(defaut) Then dft = CDate(defaut)
    End If
    If IsDate(v) Then
        AsDate = CDate(v)
    ElseIf IsNumeric(v) And Not IsEmpty(v) Then
        If CDbl(v) > 0 Then AsDate = CDate(CDbl(v)) Else AsDate = dft
    Else
        AsDate = dft
    End If
End Function

Public Function HasDate(ByVal v As Variant) As Boolean
    HasDate = (AsDate(v) > 0)
End Function

Public Function Nz(ByVal v As Variant, Optional ByVal defaut_ As Variant = 0) As Variant
    Dim defaut As Variant: defaut = defaut_   ' copie locale (compatibilite LibreOffice)
    If IsEmpty(v) Or IsNull(v) Then
        Nz = defaut
    ElseIf CStr(v) = "" Then
        Nz = defaut
    Else
        Nz = v
    End If
End Function

Public Function SigleGroupe() As String
    Dim s As String
    s = UCase$(Trim$(ParamStr("SIGLE", "CH")))
    If s = "" Then s = "CH"
    SigleGroupe = s
End Function

Public Sub BeginWork()
    G_Busy = True
    Application.ScreenUpdating = False
    Application.EnableEvents = False
    Application.Cursor = xlWait
End Sub

Public Sub EndWork()
    Application.Cursor = xlDefault
    Application.EnableEvents = True
    Application.ScreenUpdating = True
    G_Busy = False
End Sub

Public Sub ShowError(ByVal ou As String)
    Dim n As Long, d As String
    n = Err.Number: d = Err.Description
    EndWork
    LogAction "Erreur", ou & " : " & n & " " & d, ActiveSheet.Name
    Err.Number = n: Err.Description = d
    MsgBox "Une erreur est survenue (" & ou & ") :" & vbCrLf & Err.Description, vbExclamation, APP_NAME
End Sub
