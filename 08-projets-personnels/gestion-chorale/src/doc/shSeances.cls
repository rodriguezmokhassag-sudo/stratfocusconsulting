Option Explicit

Private Sub Worksheet_SelectionChange(ByVal Target As Range)
    RememberOld Target
End Sub

Private Sub Worksheet_Change(ByVal Target As Range)
    On Error Resume Next
    If G_Busy Then Exit Sub
    LogChange Target
    OnSeancesChange Target
End Sub
