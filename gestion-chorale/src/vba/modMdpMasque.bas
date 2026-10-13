Option Explicit
' =============================================================================
' modMdpMasque : boite de saisie dont le texte est masque par des asterisques
' (InputBox standard + crochet Windows). Compatible Excel 32 et 64 bits.
' Si le parametre MASQUER_MDP vaut NON, une InputBox normale est utilisee.
' =============================================================================

#If VBA7 Then
    Private Declare PtrSafe Function SetWindowsHookEx Lib "user32" Alias "SetWindowsHookExA" (ByVal idHook As Long, ByVal lpfn As LongPtr, ByVal hmod As LongPtr, ByVal dwThreadId As Long) As LongPtr
    Private Declare PtrSafe Function UnhookWindowsHookEx Lib "user32" (ByVal hHook As LongPtr) As Long
    Private Declare PtrSafe Function CallNextHookEx Lib "user32" (ByVal hHook As LongPtr, ByVal nCode As Long, ByVal wParam As LongPtr, ByVal lParam As LongPtr) As LongPtr
    Private Declare PtrSafe Function GetCurrentThreadId Lib "kernel32" () As Long
    Private Declare PtrSafe Function SendDlgItemMessage Lib "user32" Alias "SendDlgItemMessageA" (ByVal hDlg As LongPtr, ByVal nIDDlgItem As Long, ByVal wMsg As Long, ByVal wParam As LongPtr, ByVal lParam As LongPtr) As LongPtr
    Private Declare PtrSafe Function GetClassName Lib "user32" Alias "GetClassNameA" (ByVal hWnd As LongPtr, ByVal lpClassName As String, ByVal nMaxCount As Long) As Long
    Private m_Hook As LongPtr
#Else
    Private Declare Function SetWindowsHookEx Lib "user32" Alias "SetWindowsHookExA" (ByVal idHook As Long, ByVal lpfn As Long, ByVal hmod As Long, ByVal dwThreadId As Long) As Long
    Private Declare Function UnhookWindowsHookEx Lib "user32" (ByVal hHook As Long) As Long
    Private Declare Function CallNextHookEx Lib "user32" (ByVal hHook As Long, ByVal nCode As Long, ByVal wParam As Long, ByVal lParam As Long) As Long
    Private Declare Function GetCurrentThreadId Lib "kernel32" () As Long
    Private Declare Function SendDlgItemMessage Lib "user32" Alias "SendDlgItemMessageA" (ByVal hDlg As Long, ByVal nIDDlgItem As Long, ByVal wMsg As Long, ByVal wParam As Long, ByVal lParam As Long) As Long
    Private Declare Function GetClassName Lib "user32" Alias "GetClassNameA" (ByVal hWnd As Long, ByVal lpClassName As String, ByVal nMaxCount As Long) As Long
    Private m_Hook As Long
#End If

Private Const WH_CBT As Long = 5
Private Const HCBT_ACTIVATE As Long = 5
Private Const EM_SETPASSWORDCHAR As Long = &HCC
Private Const INPUTBOX_EDIT_ID As Long = &H1324

#If VBA7 Then
Private Function HookProc(ByVal nCode As Long, ByVal wParam As LongPtr, ByVal lParam As LongPtr) As LongPtr
#Else
Private Function HookProc(ByVal nCode As Long, ByVal wParam As Long, ByVal lParam As Long) As Long
#End If
    Dim cls As String, n As Long
    If nCode = HCBT_ACTIVATE Then
        cls = String$(64, vbNullChar)
        n = GetClassName(wParam, cls, 64)
        If Left$(cls, n) = "#32770" Then
            SendDlgItemMessage wParam, INPUTBOX_EDIT_ID, EM_SETPASSWORDCHAR, 42, 0
        End If
    End If
    HookProc = CallNextHookEx(m_Hook, nCode, wParam, lParam)
End Function

Public Function PasswordBox(ByVal prompt As String, ByVal titre As String) As String
    On Error GoTo Fallback
    m_Hook = SetWindowsHookEx(WH_CBT, AddressOf HookProc, 0, GetCurrentThreadId())
    PasswordBox = InputBox(prompt, titre)
    If m_Hook <> 0 Then UnhookWindowsHookEx m_Hook
    m_Hook = 0
    Exit Function
Fallback:
    On Error Resume Next
    If m_Hook <> 0 Then UnhookWindowsHookEx m_Hook
    m_Hook = 0
    PasswordBox = InputBox(prompt, titre)
End Function
