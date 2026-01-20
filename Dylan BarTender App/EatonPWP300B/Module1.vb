Option Explicit On

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
    Public SerialStr, LocationCode, ISOCountryCode, SupplierCode, ProdSer, RevCode, DDD, Serial, PQty, SerialBx, PrinterThree, PssWrd, MultiLab As String
    Public LabQty, NewCab As Integer

    Public ProdType As String           'Used as reference value for getting plant code from tblCode table.


    Public cnData As ADODB.Connection

    Public rsdata As ADODB.Recordset    'Recordset for tblMain
    Public rsdata2 As ADODB.Recordset
    Public rsdata3 As ADODB.Recordset
    Public rsdata4 As ADODB.Recordset
    Public rsdata5 As ADODB.Recordset
    Public rsdata6 As ADODB.Recordset
    Public rsdata7 As ADODB.Recordset
    Public rsdata8 As ADODB.Recordset
    Public rsdata9 As ADODB.Recordset   'Recordset for tblPrinter
    Public rsdata10 As ADODB.Recordset

    Public btApp As BarTender.Application
    Public btLab As BarTender.Format

    Public HPCommodityCode As String

    'Public Sub ReadIni(ByRef Gapp As Object, ByRef Gkey As Object, ByRef IniData As Object, ByRef Inifile As Object)
    Public Sub ReadIni(ByRef Gapp As String, ByRef Gkey As String, ByRef IniData As String, ByRef Inifile As String)

        Dim rdata As String = ""
        Dim wrk As String = ""
        Dim cw As String = ""
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

    'Public Sub WriteIni(ByRef Gapp As Object, ByRef Gkey As Object, ByRef IniData As Object, ByRef Inifile As Object)
    Public Sub WriteIni(ByRef Gapp As String, ByRef Gkey As String, ByRef IniData As String, ByRef Inifile As String)

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




    Public Sub WriteBack()

        'Writeback print run info per serial printed
        'Added 8 28 2009
        Dim j, i As Integer
        Dim msg As String


        Try
            'Recordset for tblArchive table.
            rsdata10 = New ADODB.Recordset
            rsdata10.Open(SQLWrite, cnData, ADODB.CursorTypeEnum.adOpenDynamic, ADODB.LockTypeEnum.adLockOptimistic)
            rsdata10.AddNew()

            For i = 0 To rsdata10.Fields.Count - 1
                For j = 0 To rsdata.Fields.Count - 1
                    If rsdata10.Fields(i).Name = rsdata.Fields(j).Name Then
                        rsdata10.Fields(i).Value = rsdata.Fields(j).Value
                    End If
                Next j

                rsdata10.Fields("LineNumber").Value = frmMain.txtLineNumber.Text
            Next i

            rsdata10.Fields("SYSTR").Value = SYSTR
            rsdata10.Fields("UPSTYPE").Value = UPSTYPE
            rsdata10.Fields("INA").Value = INA

            'This statement will handle both the DQP and standard serial numbers.
            'The calling routine will set SerialStr to the DPQ serial number and Serial to "" when a DPQ serial number is used.
            rsdata10.Fields("Serial").Value = SerialStr & Serial

            rsdata10.Fields("HPCommodityCode").Value = HPCommodityCode

            rsdata10.Update()
            rsdata10.Close()

        Catch ex As Exception
            msg = "Error occurred in the Module1.WriteBack routine" & vbCrLf & vbCrLf & ex.Message
            MessageBox.Show(msg, "ERROR")
        End Try


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



    Public Function create_hp_commodity_code(ByVal PartNumber As String) As String

        Dim commodity_code As String = "NONE"   'Default is "NONE"
        Dim temp_code As String = ""
        Dim msg As String
        Dim sql As String
        Dim week_and_count As String = ""


        Try

            Dim rsPN As New ADODB.Recordset

            'Create a recordset containing the commodity code information for this part number.
            sql = "SELECT * FROM HPCommodity_Setup WHERE PartNumber = '" & PartNumber & "'"

            rsPN.Open(sql, cnData, ADODB.CursorTypeEnum.adOpenDynamic, ADODB.LockTypeEnum.adLockOptimistic)

            If Not rsPN.EOF Then

                'Fixed portion of the commodity code.
                temp_code = rsPN("CommodityCode").Value & rsPN("AssemblyCode").Value & rsPN("RevisionLevel").Value & rsPN("Supplier").Value

                'Get the weekly count number from the database.
                If get_hp_week_and_count(week_and_count) Then
                    temp_code = temp_code & week_and_count
                    commodity_code = temp_code
                Else
                    Return commodity_code
                End If

            End If

            rsPN.Close()


        Catch ex As Exception
            msg = "Error occurred in the Module1.create_hp_commodity_code routine" & vbCrLf & vbCrLf & ex.Message
            MessageBox.Show(msg, "ERROR")
            Return commodity_code
        End Try

        'Returns either NONE or the newly generated commodity code for this part number.
        'MessageBox.Show(commodity_code, "HP Commodity Code")
        Return commodity_code

    End Function


    Private Function get_hp_week_and_count(byref WeekAndCount As String) As Boolean

        Dim msg As String
        Dim sql As String
        Dim week_code As String
        Dim week_count As Long

        'Default value
        WeekAndCount = ""

        Try
            Dim rsWeek As New ADODB.Recordset

            'Create a recordset containing the commodity code information for this part number.
            sql = "SELECT * FROM HPCommodity_WeekInformation WHERE #" & Today & "# BETWEEN WeekBeginning AND (WeekBeginning + 6)"

            rsWeek.Open(sql, cnData, ADODB.CursorTypeEnum.adOpenDynamic, ADODB.LockTypeEnum.adLockOptimistic)

            If rsWeek.EOF Then

                msg = "There is not an entry in the HPCommodity_WeekInformation for this week." & vbCrLf & vbCrLf & _
                      "Please notify your supervison."

                MessageBox.Show(msg, "HPCommodity_WeekInformation ERROR")

                rsWeek.Close()

                Return False

            Else
                'Get the week code and count
                week_code = rsWeek("WeekCode").Value
                week_count = rsWeek("WeeklyBuildCount").Value

                'Increment the week count.
                week_count = week_count + 1

                'Update the database
                rsWeek("WeeklyBuildCount").Value = week_count
                rsWeek.Update()
                rsWeek.Close()

                WeekAndCount = week_code & Base36(week_count)

            End If

        Catch ex As Exception
            msg = "Error occurred in the Module1.create_hp_commodity_code routine" & vbCrLf & vbCrLf & ex.Message
            MessageBox.Show(msg, "ERROR")
            Return False
        End Try

        'Success
        Return True

    End Function


    Private Function Base36(ByVal Value As Long) As String

        Dim intNum As Long
        Dim strSum As String
        Dim intCarry As Integer
        Dim intConvertBase As Integer

        Const lookup As String = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"

        intConvertBase = 36

        strSum = ""
        intNum = Value

        Do
            intCarry = intNum Mod intConvertBase

            'Find the character that represents this value.
            strSum = Mid(lookup, intCarry + 1, 1) & strSum

            intNum = Int(intNum / intConvertBase)

        Loop Until intNum = 0

        'Always show three characters.
        Base36 = Right("00" & strSum, 3)

    End Function

End Module
