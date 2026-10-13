Option Explicit
' =============================================================================
' modJournal : tracabilite des actions (feuille JOURNAL, non modifiable)
' =============================================================================

Private m_OldAddr As String
Private m_OldSheet As String
Private m_OldVals As Variant

Public Sub LogAction(ByVal action As String, ByVal detail As String, ByVal feuille As String)
    Dim sh As Worksheet, r As Long
    On Error Resume Next
    Set sh = WS(SH_JOURNAL)
    r = LastRow(sh, 1) + 1
    sh.Cells(r, 1).Value = Now
    sh.Cells(r, 2).Value = IIf(G_RoleLabel = "", "(non connecté)", G_RoleLabel)
    sh.Cells(r, 3).Value = G_Holder
    sh.Cells(r, 4).Value = feuille
    sh.Cells(r, 5).Value = action
    sh.Cells(r, 6).Value = Left$(detail, 250)
End Sub

Public Sub RememberOld(ByVal Target As Range)
    On Error Resume Next
    If Target.Cells.Count > 500 Then
        m_OldAddr = ""
        Exit Sub
    End If
    m_OldSheet = Target.Worksheet.Name
    m_OldAddr = Target.Address
    m_OldVals = Target.Value
End Sub

Private Function OldValueOf(ByVal c As Range) As String
    Dim zone As Range, r As Long, k As Long
    On Error GoTo Fin
    If m_OldAddr = "" Or m_OldSheet <> c.Worksheet.Name Then Exit Function
    Set zone = c.Worksheet.Range(m_OldAddr)
    If Intersect(zone, c) Is Nothing Then Exit Function
    If zone.Cells.Count = 1 Then
        OldValueOf = CStr(m_OldVals)
    Else
        r = c.Row - zone.Row + 1
        k = c.Column - zone.Column + 1
        OldValueOf = CStr(m_OldVals(r, k))
    End If
Fin:
End Function

Public Sub LogChange(ByVal Target As Range)
    Dim sh As Worksheet, c As Range, hdrRow As Long, h As String
    On Error Resume Next
    If G_Busy Then Exit Sub
    Set sh = Target.Worksheet
    hdrRow = HDR
    If Target.Cells.Count = 1 Then
        Set c = Target
        If c.Row > hdrRow Then h = CStr(sh.Cells(hdrRow, c.Column).Value)
        LogAction "Modification", h & " [" & c.Address(False, False) & "] : « " & OldValueOf(c) & " » -> « " & CStr(c.Value) & " »", sh.Name
    Else
        LogAction "Modification multiple", Target.Cells.Count & " cellules (" & Target.Address(False, False) & ")", sh.Name
    End If
    RememberOld Target
End Sub
