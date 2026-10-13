Option Explicit

Private Sub Workbook_Open()
    On Error Resume Next
    AppOpen
End Sub

Private Sub Workbook_BeforeClose(Cancel As Boolean)
    On Error Resume Next
    AppBeforeClose Cancel
End Sub

Private Sub Workbook_BeforeSave(ByVal SaveAsUI As Boolean, Cancel As Boolean)
    On Error Resume Next
    AppBeforeSave
End Sub

Private Sub Workbook_AfterSave(ByVal Success As Boolean)
    On Error Resume Next
    AppAfterSave
End Sub
