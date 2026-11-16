Option Explicit
' =============================================================================
' modCouleurs : trois propositions de theme calculees a partir des couleurs
' dominantes du logo. Les pixels sont lus avec WIA (Windows Image Acquisition,
' present sur Windows depuis Vista) ; le calcul de la palette est independant.
' Pixel = entier ARGB (&HAARRGGBB), comme WIA.ImageFile.ARGBData.
' =============================================================================

Private Const PREVIEW_COL As Long = 5   ' apercu dans PARAMETRES, colonnes E a H

Public Function ArgbPixel(ByVal r As Long, ByVal g As Long, ByVal b As Long) As Long
    ArgbPixel = &HFF000000 Or (r * &H10000) Or (g * &H100&) Or b
End Function

Private Sub Decoder(ByVal p As Long, ByRef a As Long, ByRef r As Long, ByRef g As Long, ByRef b As Long)
    If p < 0 Then
        a = 128 + ((p And &H7F000000) \ &H1000000)
    Else
        a = p \ &H1000000
    End If
    r = (p And &HFF0000) \ &H10000
    g = (p And &HFF00&) \ &H100&
    b = p And &HFF&
End Sub

Public Function HexDe(ByVal r As Long, ByVal g As Long, ByVal b As Long) As String
    HexDe = "#" & Right$("0" & Hex$(r), 2) & Right$("0" & Hex$(g), 2) & Right$("0" & Hex$(b), 2)
End Function

Private Function Luminance(ByVal r As Long, ByVal g As Long, ByVal b As Long) As Double
    Luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255
End Function

' Assombrit la couleur jusqu'a la luminance cible (texte blanc lisible sur la couleur)
Private Function Foncer(ByVal r As Long, ByVal g As Long, ByVal b As Long, ByVal cible As Double) As String
    Dim f As Double, l As Double
    l = Luminance(r, g, b)
    If l > cible And l > 0 Then
        f = cible / l
        r = Int(r * f): g = Int(g * f): b = Int(b * f)
    End If
    Foncer = HexDe(r, g, b)
End Function

' Melange avec du blanc (part = proportion de blanc)
Private Function Eclaircir(ByVal r As Long, ByVal g As Long, ByVal b As Long, ByVal part As Double) As String
    Eclaircir = HexDe(Int(r + (255 - r) * part), Int(g + (255 - g) * part), Int(b + (255 - b) * part))
End Function

Private Function Distance(ByVal c1 As Long, ByVal c2 As Long) As Double
    Dim a As Long, r1 As Long, g1 As Long, b1 As Long, r2 As Long, g2 As Long, b2 As Long
    Decoder c1, a, r1, g1, b1
    Decoder c2, a, r2, g2, b2
    Distance = Sqr((r1 - r2) ^ 2 + (g1 - g2) ^ 2 + (b1 - b2) ^ 2)
End Function

' Couleurs dominantes (hors blanc, noir, gris et transparent), par ordre d'importance
Public Function CouleursDominantes(px() As Long, ByVal n As Long, ByRef dom() As Long) As Long
    Dim cnt(0 To 4095) As Long, sr(0 To 4095) As Double, sg(0 To 4095) As Double, sb(0 To 4095) As Double
    Dim i As Long, a As Long, r As Long, g As Long, b As Long, k As Long, best As Long, bestN As Long, nd As Long, j As Long, ok As Boolean
    Dim mx As Long, mn As Long, c As Long
    ReDim dom(1 To 4)
    For i = 1 To n
        Decoder px(i), a, r, g, b
        mx = r
        If g > mx Then mx = g
        If b > mx Then mx = b
        mn = r
        If g < mn Then mn = g
        If b < mn Then mn = b
        If a >= 128 And mn < 235 And mx > 30 And mx - mn >= 35 Then
            k = (r \ 16) * 256 + (g \ 16) * 16 + (b \ 16)
            cnt(k) = cnt(k) + 1
            sr(k) = sr(k) + r: sg(k) = sg(k) + g: sb(k) = sb(k) + b
        End If
    Next i
    Do While nd < 4
        best = -1: bestN = 0
        For k = 0 To 4095
            If cnt(k) > bestN Then
                c = ArgbPixel(Int(sr(k) / cnt(k)), Int(sg(k) / cnt(k)), Int(sb(k) / cnt(k)))
                ok = True
                For j = 1 To nd
                    If Distance(c, dom(j)) < 90 Then ok = False
                Next j
                If ok Then
                    best = k: bestN = cnt(k)
                Else
                    cnt(k) = 0
                End If
            End If
        Next k
        If best < 0 Then Exit Do
        nd = nd + 1
        dom(nd) = ArgbPixel(Int(sr(best) / cnt(best)), Int(sg(best) / cnt(best)), Int(sb(best) / cnt(best)))
        cnt(best) = 0
    Loop
    CouleursDominantes = nd
End Function

' Trois themes "principale;secondaire;accent" (codes #RRGGBB) a partir des pixels du logo
Public Function PropositionsCouleurs(px() As Long, ByVal n As Long) As Variant
    Dim dom() As Long, nd As Long, a As Long, r1 As Long, g1 As Long, b1 As Long, r2 As Long, g2 As Long, b2 As Long
    Dim r3 As Long, g3 As Long, b3 As Long, p(1 To 3) As String
    nd = CouleursDominantes(px, n, dom)
    If nd = 0 Then dom(1) = ArgbPixel(30, 123, 74)
    Decoder dom(1), a, r1, g1, b1
    If nd >= 2 Then
        Decoder dom(2), a, r2, g2, b2
    Else
        r2 = 255 - r1: g2 = 255 - g1: b2 = 255 - b1   ' complementaire
    End If
    If nd >= 3 Then
        Decoder dom(3), a, r3, g3, b3
    Else
        r3 = r2: g3 = g2: b3 = b2
    End If
    p(1) = Foncer(r1, g1, b1, 0.42) & ";" & Eclaircir(r1, g1, b1, 0.88) & ";" & Foncer(r2, g2, b2, 0.5)
    p(2) = Foncer(r2, g2, b2, 0.42) & ";" & Eclaircir(r2, g2, b2, 0.88) & ";" & Foncer(r1, g1, b1, 0.5)
    p(3) = Foncer(r1, g1, b1, 0.25) & ";" & Eclaircir(r1, g1, b1, 0.93) & ";" & Foncer(r3, g3, b3, 0.55)
    PropositionsCouleurs = Array(p(1), p(2), p(3))
End Function

' Pixels du logo reduit a 80 x 80 au plus (0 si WIA est indisponible ou le fichier illisible)
Public Function LirePixelsLogo(ByVal f As String, px() As Long) As Long
    Dim img As Object, ip As Object, v As Object, i As Long, n As Long
    On Error GoTo Echec
    Set img = CreateObject("WIA.ImageFile")
    img.LoadFile f
    Set ip = CreateObject("WIA.ImageProcess")
    ip.Filters.Add ip.FilterInfos("Scale").FilterID
    ip.Filters(1).Properties("MaximumWidth") = 80
    ip.Filters(1).Properties("MaximumHeight") = 80
    Set img = ip.Apply(img)
    Set v = img.ARGBData
    n = v.Count
    ReDim px(1 To n)
    For i = 1 To n
        px(i) = v(i)
    Next i
    LirePixelsLogo = n
    Exit Function
Echec:
    LirePixelsLogo = 0
End Function

' Apercu des propositions dans PARAMETRES (colonnes E a H)
Public Sub ApercuPropositions(ByVal props As Variant)
    Dim sh As Worksheet, i As Long, j As Long, c() As String
    Set sh = WS(SH_PARAM)
    EffacerApercu
    sh.Cells(HDR, PREVIEW_COL).Value = "Proposition"
    sh.Cells(HDR, PREVIEW_COL + 1).Value = "Principale"
    sh.Cells(HDR, PREVIEW_COL + 2).Value = "Secondaire"
    sh.Cells(HDR, PREVIEW_COL + 3).Value = "Accent"
    For i = 0 To UBound(props)
        c = Split(CStr(props(i)), ";")
        sh.Cells(FIRSTROW + i, PREVIEW_COL).Value = i + 1
        For j = 0 To 2
            sh.Cells(FIRSTROW + i, PREVIEW_COL + 1 + j).Interior.Color = HexToRGB(c(j))
            sh.Cells(FIRSTROW + i, PREVIEW_COL + 1 + j).Value = c(j)
            If j <> 1 Then sh.Cells(FIRSTROW + i, PREVIEW_COL + 1 + j).Font.Color = RGB(255, 255, 255)
        Next j
    Next i
End Sub

Public Sub EffacerApercu()
    Dim sh As Worksheet
    Set sh = WS(SH_PARAM)
    With sh.Range(sh.Cells(HDR, PREVIEW_COL), sh.Cells(FIRSTROW + 3, PREVIEW_COL + 3))
        .ClearContents
        .Interior.ColorIndex = xlNone
        .Font.Color = RGB(0, 0, 0)
    End With
End Sub

Public Sub CouleursDepuisLogo()
    Dim f As Variant, px() As Long, n As Long, props As Variant, rep As String, c() As String, choix As String
    If Not RequireEdit(SH_PARAM) Then Exit Sub
    f = ParamStr("LOGO_FICHIER")
    If CStr(f) = "" Or Dir(CStr(f)) = "" Then
        f = Application.GetOpenFilename("Images (*.png;*.jpg;*.jpeg;*.gif;*.bmp),*.png;*.jpg;*.jpeg;*.gif;*.bmp", , "Choisir le logo du groupe")
        If VarType(f) = vbBoolean Then Exit Sub
    End If
    n = LirePixelsLogo(CStr(f), px)
    If n = 0 Then
        MsgBox "Les couleurs du logo ne peuvent pas être lues sur cet ordinateur (composant Windows WIA absent)." & vbCrLf & _
               "Choisissez un thème dans la liste.", vbExclamation, APP_NAME
        ChoisirTheme
        Exit Sub
    End If
    props = PropositionsCouleurs(px, n)
    WS(SH_PARAM).Activate
    ApercuPropositions props
    Application.ScreenUpdating = True
    rep = Trim$(InputBox("Trois propositions tirées du logo sont affichées dans PARAMETRES (colonnes E à H)." & vbCrLf & vbCrLf & _
                         "Tapez 1, 2 ou 3 pour appliquer une proposition," & vbCrLf & "ou 4 pour choisir vous-même les couleurs.", APP_NAME & " - Couleurs du logo", "1"))
    EffacerApercu
    Select Case rep
        Case "1", "2", "3"
            choix = CStr(props(CLng(rep) - 1))
            c = Split(choix, ";")
            SetTheme "Logo " & rep, c(0), c(1), c(2)
        Case "4"
            ChoisirTheme
    End Select
End Sub
