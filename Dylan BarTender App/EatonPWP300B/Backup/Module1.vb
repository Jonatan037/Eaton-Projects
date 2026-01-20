
Friend Module Module1
    Friend F1 As frmMain
    Friend F2 As frmRL
    Friend F3 As frmStatic
    Friend f4 As frmQuestion
    Public Declare Function GetPrivateProfileString Lib "Kernel32" Alias "GetPrivateProfileStringA" (ByVal lpApplicationName As String, ByVal lpKeyName As String, ByVal lpDefault As String, ByVal lpReturnedString As String, ByVal nSize As Integer, ByVal lpFileName As String) As Integer
    Public Declare Function GetPrivateProfileStringNull Lib "Kernel32" Alias "GetPrivateProfileStringA" (ByVal lpApplicationName As String, ByVal lpKeyName As Integer, ByVal lpDefault As String, ByVal lpReturnedString As String, ByVal nSize As Integer, ByVal lpFileName As String) As Integer
    Public Declare Function GetPrivateProfileStringNullNull Lib "Kernel32" Alias "GetPrivateProfileStringA" (ByVal lpApplicationName As Integer, ByVal lpKeyName As Integer, ByVal lpDefault As String, ByVal lpReturnedString As String, ByVal nSize As Integer, ByVal lpFileName As String) As Integer
    Public Declare Function WritePrivateProfileString Lib "Kernel32" Alias "WritePrivateProfileStringA" (ByVal lpApplicationName As String, ByVal lpKeyName As String, ByVal lpString As String, ByVal lpFileName As String) As Integer
    Public IniFile, Path, DataBasePath, DataBaseName, ConnectString, SQLString, SQLString2, SQLString3, SQLWrite, cnConnStr, LabDir As String
    Public ConfigStr, RunType, UPSTYPE, INA, CABTRACK, LabFor1, LabFor2, LabFor3, LabFor4, PrinterOne, PrinterTwo, SYSTR, FULLCTO As String
    Public ProdType, SerialStr, LocationCode, ISOCountryCode, SupplierCode, ProdSer, RevCode, DDD, Serial, PQty, SerialBx, PrinterThree, PssWrd, MultiLab As String
    Public LabQty, NewCab As Integer
    Public cnData As ADODB.Connection
    Public rsdata As ADODB.Recordset
    Public rsdata2 As ADODB.Recordset
    Public rsdata3 As ADODB.Recordset
    Public rsdata4 As ADODB.Recordset
    Public rsdata5 As ADODB.Recordset
    Public rsdata6 As ADODB.Recordset
    Public rsdata7 As ADODB.Recordset
    Public rsdata8 As ADODB.Recordset
    Public rsdata9 As ADODB.Recordset
    Public rsdata10 As ADODB.Recordset
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
    Public Sub FormTst()
        Dim x As frmRL
        x.Close()
        MsgBox("h")

    End Sub
    Public Sub WriteBack()

        'Writeback print run info per serial printed
        'Added 8 28 2009
        Dim j, i As Integer

        rsdata10 = New ADODB.Recordset
        rsdata10.Open(SQLWrite, cnData, ADODB.CursorTypeEnum.adOpenDynamic, ADODB.LockTypeEnum.adLockOptimistic)
        rsdata10.AddNew()

        For i = 0 To rsdata10.Fields.Count - 1
            For j = 0 To rsdata.Fields.Count - 1
                If rsdata10.Fields(i).Name = rsdata.Fields(j).Name Then
                    rsdata10.Fields(i).Value = rsdata.Fields(j).Value
                End If
            Next j
        Next i

        rsdata10.Fields("SYSTR").Value = SYSTR
        rsdata10.Fields("UPSTYPE").Value = UPSTYPE
        rsdata10.Fields("INA").Value = INA
        rsdata10.Fields("Serial").Value = SerialStr & Serial

        rsdata10.Update()
        rsdata10.Close()

    End Sub
    Public Sub WriteBack2()

        'Writeback print run info per serial printed
        'Added 8 28 2009
        Dim j, i As Integer

        rsdata10 = New ADODB.Recordset
        rsdata10.Open(SQLWrite, cnData, ADODB.CursorTypeEnum.adOpenDynamic, ADODB.LockTypeEnum.adLockOptimistic)
        rsdata10.AddNew()

        For i = 0 To rsdata10.Fields.Count - 1
            For j = 0 To rsdata.Fields.Count - 1
                If rsdata10.Fields(i).Name = rsdata.Fields(j).Name Then
                    rsdata10.Fields(i).Value = rsdata.Fields(j).Value
                End If
            Next j
        Next i

        rsdata10.Fields("SYSTR").Value = SYSTR
        rsdata10.Fields("FULLCTO").Value = FULLCTO
        rsdata10.Fields("UPSTYPE").Value = UPSTYPE
        rsdata10.Fields("INA").Value = INA
        rsdata10.Fields("Serial").Value = SerialStr & Serial

        rsdata10.Update()
        rsdata10.Close()

    End Sub
End Module
