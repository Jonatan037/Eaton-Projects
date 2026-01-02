Imports System
Imports System.Threading
Public Class clsGPIB
    Declare Sub Sleep Lib "kernel32" (ByVal dwMilliseconds As Long)
    Dim DefRM As Integer

    Dim FindResource() As String

    Public N, ViGPIB() As Integer
    Dim _isOpen As Boolean
    Dim _errMsg As String
    Public Config_WT230_GPIB_Addr = "GPIB0::10::INSTR"
    Public Config_34980A_GPIB_Addr = "GPIB0::11::INSTR"
    Public Config_8846A_GPIB_Addr = "GPIB0::12::INSTR"
    Public VI_WT230 As Long = -1
    Public VI_34980A As Long = -1
    Public VI_8846A As Long = -1


    Public Sub New()
        _errMsg = String.Empty
        _isOpen = InitializeDefRM()
    End Sub

    Public ReadOnly Property IsOpen() As Boolean
        Get
            Return _isOpen
        End Get
    End Property

    Public ReadOnly Property GetErrMessage() As String
        Get
            Return _errMsg
        End Get
    End Property

    Public ReadOnly Property FindedResrcCount() As Integer
        Get
            If Not _isOpen Then Return -1
            Return N
        End Get
    End Property

    Public ReadOnly Property Vi(ByVal index As Integer) As Integer
        Get
            If Not _isOpen Then Return -1
            If index < 0 Then
                index = 0
            ElseIf index > N - 1 Then
                index = N - 1
            End If
            Return ViGPIB(index)
        End Get
    End Property

    Public ReadOnly Property ResrcDescAddr(ByVal index As Integer) As String
        Get
            If Not _isOpen Then Return String.Empty
            If index < 0 Then
                index = 0
            ElseIf index > N - 1 Then
                index = N - 1
            End If
            Return FindResource(index)
        End Get
    End Property

    Private Function InitializeDefRM() As Boolean
        Dim Status As Integer
        _errMsg = String.Empty
        N = 0
        Try

            Status = viOpenDefaultRM(DefRM)

            If (Status < VI_SUCCESS) Then
                _errMsg = GetErrMsg(DefRM, Status)

                Return False

            End If

            Dim Detected As Boolean

            Detected = FindResrc()

            If Not Detected Then Call viClose(DefRM) : Return False

            Dim Count As Integer = UBound(FindResource)

            N = Count + 1


            ReDim ViGPIB(Count)

            'Assign Vi for each device
            System.Array.Sort(FindResource)

            For i As Integer = 0 To Count

                Status = viOpen(DefRM, FindResource(i), 0, 0, ViGPIB(i))

                Select Case UCase(FindResource(i))

                    Case UCase(Config_WT230_GPIB_Addr)

                        VI_WT230 = ViGPIB(i)

                    Case UCase(Config_34980A_GPIB_Addr)

                        VI_34980A = ViGPIB(i)

                    Case UCase(Config_8846A_GPIB_Addr)

                        VI_8846A = ViGPIB(i)

                    Case Else
                        ' Add error here notification

                End Select


                If (Status < VI_SUCCESS) Then

                    _errMsg = GetErrMsg(DefRM, Status)

                    Call viClose(DefRM)

                    Return False


                End If
            Next
            ' Initialize device
            For i As Integer = 0 To Count

                Status = viPrintf(ViGPIB(i), "*RST" & Chr(10), 0)
                Status = viPrintf(ViGPIB(i), "*CLS" & Chr(10), 0)

                If (Status < VI_SUCCESS) Then
                    _errMsg = GetErrMsg(ViGPIB(i), Status)
                    Call viClose(DefRM)
                    Return False
                End If

            Next

            _errMsg = "Initiate GPIB Device Success."
            Return True

        Catch ex As Exception

            _errMsg = ex.Message
            _errMsg = "Initiate GPIB device Failure" & _errMsg

            Return False
        End Try
    End Function

    Private Function SubString(ByVal strA As String) As String
        Dim site As Short
        site = InStr(1, strA, Chr(0))
        If site > 0 Then strA = Left(strA, site - 1)
        SubString = strA
    End Function

    Private Function GetErrMsg(ByVal Vi As Integer, ByVal status As Integer) As String
        Dim strVisaErr As New System.Text.StringBuilder(Space(200))
        Call viStatusDesc(Vi, status, strVisaErr)
        GetErrMsg = SubString(strVisaErr.ToString)
    End Function


    Private Function FindResrc(Optional ByVal expr As String = "GPIB[0-15]*::?*INSTR") As Boolean
        Try
            Dim FindList, status, retCount, j As Integer
            Dim Desc As New System.Text.StringBuilder(Space(200))

            status = viFindRsrc(DefRM, expr, FindList, retCount, Desc)

            If (status < VI_SUCCESS) Then

                _errMsg = GetErrMsg(DefRM, status)

                Return False

            End If

            ReDim FindResource(retCount - 1)
            FindResource(0) = SubString(Desc.ToString)

            For j = 1 To retCount - 1
                status = viFindNext(FindList, Desc)

                If (status < VI_SUCCESS) Then
                    _errMsg = GetErrMsg(DefRM, status)

                    Call viClose(FindList)

                    Return False

                End If

                FindResource(j) = SubString(Desc.ToString)

            Next
            _errMsg = "Devices are detected."

            Call viClose(FindList)

            Return True

        Catch ex As Exception
            _errMsg = ex.Message
            Return False
        End Try

    End Function


    Public Function WriteCommand(ByVal Vi As Integer, ByVal strWrite As String) As Boolean
        Dim status As Integer
        Try
            status = viPrintf(Vi, String.Concat(strWrite.Trim, Chr(10).ToString), 0)
            _errMsg = GetErrMsg(Vi, status)

            Return (status = VI_SUCCESS)

        Catch ex As Exception
            _errMsg = ex.Message

            Return False
        End Try
    End Function

    Public Function WriteCommands(ByVal Vi As Integer, ByVal strWrite As String) As Boolean
        If InStr(1, strWrite, ">") = 0 Then Return WriteCommand(Vi, strWrite)

        For Each S As String In strWrite.Split(New Char() {">"c}, System.StringSplitOptions.RemoveEmptyEntries)

            WriteCommands = WriteCommand(Vi, strWrite)

            If Not WriteCommands Then Exit Function
        Next
    End Function

    '''------------------------------------------------
    '''Send and Receive Data from wt230 according to Vi
    '''------------------------------------------------
    Public Function SendReceive(ByVal Vi As Long, ByVal writeData As String, ByRef ReturnData As String) As Boolean

        Call WriteCommand(Vi, writeData)

        ReturnData = ""
        SendReceive = ReadResult(Vi, ReturnData)

    End Function

    Public Function ReadResult(ByVal Vi As Integer, ByRef strReturn As String) As Boolean
        Try
            Dim status As Integer
            Dim strReceive As New System.Text.StringBuilder(Space(1024))

            strReturn = String.Empty
            status = viScanf(Vi, "%t", strReceive)
            _errMsg = GetErrMsg(Vi, status)
            If status < VI_SUCCESS Then Return False
            strReturn = SubString(strReceive.ToString)
            Return True
        Catch ex As Exception

            _errMsg = ex.Message

            Return False

        End Try

    End Function


    Public Function SettingsForWT230(ByRef MSG As String) As Boolean
        Dim SettingsData As String
        Dim writeData() As String
        Dim Item As Object

        SettingsData = "DISP1:FUNC V"
        SettingsData = SettingsData & ">" & "DISP2:FUNC A"
        SettingsData = SettingsData & ">" & "DISP3:FUNC W"
        SettingsData = SettingsData & ">" & "CONF:VOLT:RANG 600V"
        'SettingsData = SettingsData & ">" & "CONF:CURRENT:AUTO ON"     

        SettingsData = SettingsData & ">" & "CONF:CURRENT:RANG 10"

        SettingsData = SettingsData & ">" & "CONF:SCAL:STAT 1"
        SettingsData = SettingsData & ">" & "CONF:SCAL:PT:All 1.000000"
        SettingsData = SettingsData & ">" & "CONF:SCAL:CT:ALL 1.000000"
        SettingsData = SettingsData & ">" & "CONF:SCAL:SFAC:ELEM1 1.000000"
        SettingsData = SettingsData & ">" & "CONF:SCAL:SFAC:ELEM2 1.000000"
        SettingsData = SettingsData & ">" & "CONF:SCAL:SFAC:ELEM3 1.000000"

        SettingsData = SettingsData & ">" & "CONF:MODE RMS"
        SettingsData = SettingsData & ">" & "MEAS:ITEM:PRES CLE;V:ALL ON"
        SettingsData = SettingsData & ">" & "MEAS:NORM:ITEM:A:ALL ON"
        SettingsData = SettingsData & ">" & "MEAS:NORM:ITEM:W:ALL ON"
        SettingsData = SettingsData & ">" & "MEAS:NORM:ITEM:VHZ:ALL ON"
        SettingsData = SettingsData & ">" & "MEAS:NORM:ITEM:PF:ALL ON"
        SettingsData = SettingsData & ">" & "CONF:FILT ON"


        writeData = Split(SettingsData, ">")

        For Each Item In writeData

            Call WriteCommand(VI_WT230, CStr(Item))
        Next Item

        If SendReceive(VI_WT230, "STATUS:ERROR?", MSG) Then

            If Left(MSG, 1) = 0 Then
                Return True

            End If

        End If

        MSG = "Config Wt230 Failure details is  " & MSG & SettingsData

    End Function


    '''----------------------------------------------------
    '''Read Value From WT230
    '''For example:T=ReadWT230("IPV")
    '''Note:If Cmmd is a error command then return -10000.0
    '''----------------------------------------------------
    Public Function ReadWT230(ByVal Cmmd As String) As Double
        '  Dim GetFlag As Short
        'Dim Vi As Integer
        Dim l As Byte
        ' Dim DelayTime As Single
        Dim strResult As String = ""
        Dim strCom As String

        Dim strData() As String
        Dim dblValue As Double

        Cmmd = Trim(Cmmd)
        If Len(Cmmd) = 0 Then
            ReadWT230 = -10000.0# 'If Cmmd is a error command then return -10000.0
            Exit Function
        End If
        Cmmd = UCase(Cmmd)

        Select Case Cmmd
            Case "IPRV" : l = 1
            Case "IPSV" : l = 2
            Case "IPTV" : l = 3
            Case "IPRC" : l = 5
            Case "IPSC" : l = 6
            Case "IPTC" : l = 7
            Case "IPRW" : l = 9
            Case "IPSW" : l = 10
            Case "IPTW" : l = 11
            Case "IPTOTALW" : l = 12
            Case "IPRHZ" : l = 13
            Case "IPSHZ" : l = 14
            Case "IPTHZ" : l = 15
            Case "IPRF" : l = 17
            Case "IPSF" : l = 18
            Case "IPTF" : l = 19
            Case Else

                ReadWT230 = -10000.0# 'If Cmmd is a error command then return -10000.0
                _errMsg = "The ead item" & Cmmd & " can't be identified"

                Exit Function
        End Select
        ' Call Sleep(300)

        strCom = "MEAS:VAL?"
        If SendReceive(VI_WT230, strCom, strResult) Then
            If InStr(1, strResult, ",") = 0 Then
                dblValue = Val(strResult)
            Else
                strData = Split(strResult, ",")
                dblValue = Val(strData(l - 1))
            End If

            ReadWT230 = Val(Format(dblValue, "#####0.###"))

        End If

    End Function


    Public Function Read8846A(ByVal chanelList As String, ByVal ChanelNumber As Short, ByVal str8846AData() As String) As Boolean

        Dim Vi As Integer

        Dim strResult As String = ""
        Dim strCom As String

        'Dim dblValue As Double

        Vi = VI_8846A

        chanelList = Trim(chanelList)
        If Len(chanelList) = 0 Then

            Exit Function

        End If

        strCom = "MEAS:VOLT:DC? 100,1.000000E-4,(@" & chanelList & ")"

        If SendReceive(Vi, strCom, strResult) Then

            str8846AData = Split(strResult, ",")

        End If

    End Function

    Protected Overrides Sub Finalize()
        MyBase.Finalize()
        Call CloseGPIB()
    End Sub
    Private Sub CloseGPIB()
        Try
            _isOpen = False
            Call viClose(DefRM)
        Catch ex As Exception

        End Try
    End Sub
End Class






