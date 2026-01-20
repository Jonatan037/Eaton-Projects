Module Module1
    Public Declare Function GetPrivateProfileString Lib "Kernel32" Alias "GetPrivateProfileStringA" (ByVal lpApplicationName As String, ByVal lpKeyName As String, ByVal lpDefault As String, ByVal lpReturnedString As String, ByVal nSize As Integer, ByVal lpFileName As String) As Integer
    Public Declare Function GetPrivateProfileStringNull Lib "Kernel32" Alias "GetPrivateProfileStringA" (ByVal lpApplicationName As String, ByVal lpKeyName As Integer, ByVal lpDefault As String, ByVal lpReturnedString As String, ByVal nSize As Integer, ByVal lpFileName As String) As Integer
    Public Declare Function GetPrivateProfileStringNullNull Lib "Kernel32" Alias "GetPrivateProfileStringA" (ByVal lpApplicationName As Integer, ByVal lpKeyName As Integer, ByVal lpDefault As String, ByVal lpReturnedString As String, ByVal nSize As Integer, ByVal lpFileName As String) As Integer
    Public Declare Function WritePrivateProfileString Lib "Kernel32" Alias "WritePrivateProfileStringA" (ByVal lpApplicationName As String, ByVal lpKeyName As String, ByVal lpString As String, ByVal lpFileName As String) As Integer
    Public IniFile, Path, DataBasePath, DataBaseName, cnConnStr, ConnectString, SQLString, LabDir, BoxLabel, Printer As String
    Public cnData As ADODB.Connection
    Public rsdata As ADODB.Recordset
    Public btApp As BarTender.Application
    Public btLab As BarTender.Format

    Public Sub ReadIni(ByRef Gapp As Object, ByRef Gkey As Object, ByRef IniData As Object, ByRef Inifile As Object)

        Dim rdata, wrk, cw As String
        Dim A As Object
        Dim k As String
        Dim ix, i As Integer

        rdata = Space(1024)
        A = Gapp + Chr(0)
        k = Gkey + Chr(0)

        If Gkey = "" Then
            If Gapp = "" Then
                ix = GetPrivateProfileStringNullNull(0, 0, "", rdata, 1024, Inifile + Chr(0))
            Else
                ix = GetPrivateProfileStringNull(A, 0, "", rdata, 1024, Inifile + Chr(0))
            End If
            For i = 1 To ix
                cw = Mid(rdata, i, 1)
                If Asc(cw) = 0 Then
                    wrk = wrk + ":"
                Else
                    wrk = wrk + cw
                End If
            Next i
            rdata = wrk
            ix = Len(rdata)
        Else
            ix = GetPrivateProfileString(A, k, "", rdata, 512, Inifile + Chr(0))
        End If
        If ix > 0 Then
            IniData = Left(rdata, ix)
        Else
            IniData = ""
        End If

    End Sub
    Public Sub WriteIni(ByRef Gapp As Object, ByRef Gkey As Object, ByRef IniData As Object, ByRef Inifile As Object)

        Dim A, k As Object
        Dim D As String
        Dim ix As Integer

        A = Gapp + Chr(0)
        k = Gkey + Chr(0)
        D = IniData + Chr(0)

        ix = WritePrivateProfileString(A, k, D, Inifile + Chr(0))

    End Sub
    Public Function App_Path() As String
        Return System.AppDomain.CurrentDomain.BaseDirectory()
    End Function
End Module
