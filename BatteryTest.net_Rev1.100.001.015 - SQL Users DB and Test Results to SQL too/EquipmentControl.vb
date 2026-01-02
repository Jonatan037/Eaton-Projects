' Revision History 
' Author        Date            Notes
' ________________________________________________________________________________
' J. Parker     May 3, 2022     Original

Option Explicit On
Imports vb = Microsoft.VisualBasic
Imports System.Math
Module EquipmentControl

    ''' <summary>
    ''' store WT210_1 GPIB address
    ''' </summary>
    Public WT230GPIBADDRESS As String
    ''' <summary>
    ''' store Agilent34970A GPIB address
    ''' </summary>
    Public GPIBADDRESS_8846A As String
    ''' <summary>
    ''' Store Session for WT230
    ''' </summary>
    Public ViWT230 As Long
    ''' <summary>
    ''' Store Session for 34970A
    ''' </summary>
    Public Vi8846A As Long
    ''' <summary>
    ''' Stroe  message for showing on the screen
    ''' </summary>
    Public MSG As String

    ''' <summary>
    ''' Store Instruments checking result
    ''' </summary>
    Dim checkSuccess As Boolean


    ''' <summary>
    ''' Byte convert to binary
    ''' </summary>
    ''' -------------------------------------------------------------------------------------------------redefine
    Public Function ByteToBin(ByVal m As Byte) As String
        Dim c$
        Dim r As Integer

        c$ = ""
        Do While m <> 0
            r = m Mod 2
            m = m \ 2
            c$ = r & c$
        Loop
        c$ = Right("00000000" & c$, 8)
        c$ = Mid(c$, 2, 7) & "0"
        ByteToBin = c$
    End Function

    ''' <summary>
    ''' Binary convert to Byte
    ''' </summary>
    Public Function BinToByte(ByVal m As String) As Byte
        Dim X As String

        Dim Y, z As Integer
        Dim i As Integer
        z = 0
        For i = 1 To 8
            X = Mid(m, i, 1)
            Y = X * 2 ^ (8 - i)
            z = z + Y
        Next i
        BinToByte = z
    End Function

    ''' <summary>
    ''' Check Fluke8846A can communication with ATE software
    ''' </summary>
    Public Function CheckInstrument(ByVal Fluke8846AGPIBAddress As String) As Boolean

        If TestSystem.DisableHardware = True Then

            MsgBox("Hardware has been disabled - Contact Test Engineering", MsgBoxStyle.OkOnly)
            CheckInstrument = True

        Else

            CheckInstrument = Init8846A(Fluke8846AGPIBAddress, Vi8846A, MSG)

        End If

    End Function

    ''' <summary>
    ''' initializtion for WT230
    ''' </summary>
    Public Function InitWT230(ByVal Addr As String, ByRef Vi As Long, ByRef Message As String) As Boolean
        Dim sesn As Long, r As Long
        r = viOpenDefaultRM(sesn)
        r = viOpen(sesn, "GPIB0::" & Addr & "::INSTR", 0, 0, Vi)

        If (Vi = 0) Or (r <> 0) Then
            Message = "WT230(Addr='" & Addr & "')Communication Fail"
            InitWT230 = False

        Else
            Call WriteCommand(Vi, "*CLS")
            Message = "WT230(Addr='" & Addr & "')Communication OK"
            InitWT230 = True
        End If
    End Function

    ''' <summary>
    ''' initializtion for Fluke 8846A
    ''' </summary>
    Public Function Init8846A(ByVal Addr As String, ByRef Vi As Long, ByRef Message As String) As Boolean
        Dim sesn As Long, r As Long

        'close any opened resources
        If Vi > 0 Then
            CloseVi(Vi)
        End If

        ' Create a new resource link
        r = viOpenDefaultRM(sesn)
        r = viOpen(sesn, "GPIB0::" & Addr & "::INSTR", 0, 0, Vi)
        Vi8846A = Vi
        If Vi = 0 Or r <> 0 Then
            Message = "8846A(Addr='" & Addr & "')Communication Fail"
            Init8846A = False
        Else
            Call WriteCommand(Vi, "*RST")
            Call WriteCommand(Vi, "*CLS")

            ' Set emulation mode L1-> 8846, L2-> Fluke 45, L3 -> 8842
            Call WriteCommand(Vi, "L1")

            ' Set Range and accuracy  
            Call WriteCommand(Vi, "VOLT:DC:RANG:AUTO OFF")
            Call WriteCommand(Vi, "VOLT:DC:RANG 1000")
            Call WriteCommand(Vi, "VOLT:NPLC 10")   ' About 1 second integration  6.5 Digit of accuracy
            ' error: (+/- (% measurement + % or Range)) 1 year:(.0041 + 0.0010), Temperature:(0.0005 + 0.0001)

            Message = "8846A(Addr='" & Addr & "')Communication Ok"
            Init8846A = True
        End If

        Delay(0.2, "Delay for meter in initialize", False)

    End Function
    ''' <summary>
    ''' Close a session talk to a instrument
    ''' </summary>
    Public Sub CloseVi(ByVal Vi As Long)
        Dim r As Long
        If Vi > 0 Then r = viClose(Vi)
    End Sub
    ''' <summary>
    ''' Send individual  command to instrument
    ''' </summary>
    ''' ------------------------------------------
    ''' Transmission Data to wt230 according to Vi
    ''' Note:Transmission one command
    ''' ------------------------------------------
    Public Sub WriteCommand(ByVal Vi As Long, ByVal writeData As String)
        Dim r As Long, p As Long
        Dim t1 As Long

        If Not (TestSystem.DisableHardware) Then

            t1 = vb.Timer

            '  r = viPrintf(Vi, String.Concat(writeData.Trim, Chr(10).ToString), 0)
            r = viPrintf(Vi, writeData & vbCrLf)

            Do

                Application.DoEvents()

            Loop Until vb.Timer > t1 + 0.1


        End If

    End Sub

    ''' <summary>
    ''' Send mutiple commands to instrument
    ''' </summary>
    ''' -----------------------------------------------------------------------------------
    ''' Transmission a command string that separated by a char ">" to wt230 according to Vi
    ''' Note:Transmission one command or multi commands
    ''' -----------------------------------------------------------------------------------
    Public Sub WriteCommands(ByVal Vi As Long, ByVal writeData As String)
        Dim SendData() As String
        Dim Item As Object
        If InStr(1, writeData, ">") = 0 Then
            Call WriteCommand(Vi, writeData)
            Exit Sub
        End If
        SendData = Split(writeData, ">")
        For Each Item In SendData
            Call WriteCommand(Vi, CStr(Item))
        Next
    End Sub
    ''' <summary>
    ''' Read back reaponse from instrument via call GPIB driver
    ''' </summary>
    ''' -------------------------------------
    ''' Read Data From wt230 according to Vi
    ''' -------------------------------------
    Public Function ReadResult(ByVal Vi As Long) As String
        Dim r As Integer
        Dim strReceive As New System.Text.StringBuilder(Space(1024))
        Dim t1 As Long
        t1 = vb.Timer
        Do
            Application.DoEvents()
        Loop Until vb.Timer > t1 + 0.1

        r = viScanf(Vi, "%t", strReceive)

        ReadResult = Trim(strReceive.ToString)
    End Function
    ''' <summary>
    ''' Send command to instrument and receive Response from instrument
    ''' </summary>
    ''' ------------------------------------------------
    ''' Send and Receive Data from wt230 according to Vi
    ''' ------------------------------------------------
    Public Function SendReceive(ByVal Vi As Long, ByVal writeData As String) As String
        Dim count As Integer

        count = 0

        SendReceive = ""

        If Not (TestSystem.DisableHardware) Then

            Call WriteCommand(Vi, writeData)

            SendReceive = ReadResult(Vi)

        End If

    End Function

    ''' <summary>
    ''' Do some configurations to WT230
    ''' </summary>
    Public Function SettingsForWT230(ByVal Vi As Long, ByRef MSG As String) As Boolean
        Dim SettingsData As String
        Dim writeData() As String
        Dim Item As Object
        Vi = ViWT230


        SettingsData = "MEAS:ITEM:PRES CLE;V:ALL ON"

        SettingsData = SettingsData & ">" & "DISP1:FUNC V"

        SettingsData = SettingsData & ">" & "DISP2:FUNC A"
        SettingsData = SettingsData & ">" & "DISP3:FUNC W"

        SettingsData = SettingsData & ">" & ":VOLT:AUTO ON"
        SettingsData = SettingsData & ">" & ":CURRENT:RANG 10"

        SettingsData = SettingsData & ">" & ":SCAL:STAT 1"
        SettingsData = SettingsData & ">" & ":SCAL:PT:All 1.000000"
        SettingsData = SettingsData & ">" & ":SCAL:CT:ALL 1.000000"
        SettingsData = SettingsData & ">" & ":SCAL:SFAC:ELEM1 1.000000"
        SettingsData = SettingsData & ">" & ":SCAL:SFAC:ELEM2 1.000000"
        SettingsData = SettingsData & ">" & ":SCAL:SFAC:ELEM3 1.000000"

        SettingsData = SettingsData & ">" & ":MODE RMS"

        SettingsData = SettingsData & ">" & "MEAS:NORM:ITEM:A:ALL ON"
        SettingsData = SettingsData & ">" & "MEAS:NORM:ITEM:W:ALL ON"
        SettingsData = SettingsData & ">" & "MEAS:NORM:ITEM:VHZ:ALL ON"
        SettingsData = SettingsData & ">" & "MEAS:NORM:ITEM:VHZ:ELEM1 ON"
        SettingsData = SettingsData & ">" & "MEAS:NORM:ITEM:PF:ALL ON"
        SettingsData = SettingsData & ">" & "MEAS:NORM:ITEM:DEGR:ALL ON"

        SettingsData = SettingsData & ">" & "MEAS:NORM:ITEM:VA:ALL ON"

        SettingsData = SettingsData & ">" & ":FILT ON"

        writeData = Split(SettingsData, ">")
        For Each Item In writeData
            Call WriteCommand(Vi, CStr(Item))
        Next

        MSG = Trim((SendReceive(Vi, "STATUS:ERROR?")))
        If Left(MSG, 1) = 0 Then
            SettingsForWT230 = True
        Else
            SettingsForWT230 = False
        End If
        ''

    End Function

    ''' <summary>
    ''' Read measurement value from WT230 according with measurement type
    ''' </summary>
    ''' ----------------------------------------------------
    Public Function ReadWT230(ByVal Cmmd As String) As Double
        Dim Vi As Long, l As Byte
        Dim strCom As String, strResult As String, strData() As String
        Dim dblValue As Double
        Dim sMyMessage As String
        Dim sParameterDescription As String

        Vi = ViWT230
        Cmmd = Trim(Cmmd)
        If Len(Cmmd) = 0 Then
            ReadWT230 = -10000.0#
            Exit Function
        End If
        Cmmd = UCase(Cmmd)

        Select Case Cmmd
            Case "IPRV"
                l = 1
                sParameterDescription = "Input Voltage (Phase R)"
            Case "IPSV"
                l = 2
                sParameterDescription = "Input Voltage (Phase S)"
            Case "IPTV"
                l = 3
                sParameterDescription = "Input Voltage (Phase T)"
            Case "IPRC"
                l = 5
                sParameterDescription = "Input Current (Phase R)"
            Case "IPSC"
                l = 6
                sParameterDescription = "Input Current (Phase S)"
            Case "IPTC"
                l = 7
                sParameterDescription = "Input Current (Phase T)"
            Case "IPRW"
                l = 9
                sParameterDescription = "Input Power (Phase R)"
            Case "IPSW"
                l = 10
                sParameterDescription = "Input Power (Phase S)"
            Case "IPTW"
                l = 11
                sParameterDescription = "Input Power (Phase T)"
            Case "IPTOTALW"
                l = 12
                sParameterDescription = "Input Total Power"
            Case "IPRVA"
                l = 13
                sParameterDescription = "Input Apparent Power (Phase R)"
            Case "IPSVA"
                l = 14
                sParameterDescription = "Input Apparent Power (Phase S)"
            Case "IPTVA"
                l = 15
                sParameterDescription = "Input Apparent Power (Phase T)"
            Case "IPTOTALVA"
                l = 16
                sParameterDescription = "Input Total Apparent Power"
            Case "IPRPF"
                l = 17
                sParameterDescription = "Input Power Factor (Phase R)"
            Case "IPSPF"
                l = 18
                sParameterDescription = "Input Power Factor (Phase S)"
            Case "IPTPF"
                l = 19
                sParameterDescription = "Input Power Factor (Phase T)"
            Case "IPTOTOALPF"
                l = 20
                sParameterDescription = "Input Total Power Factor"
            Case "IPRDG"
                l = 21
                sParameterDescription = "Input Phase Angle (Phase R)"
            Case "IPSDG"
                l = 22
                sParameterDescription = "Input Phase Angle (Phase S)"
            Case "IPTDG"
                l = 23
                sParameterDescription = "Input Phase Angle (Phase T)"
            Case "IPRF"
                l = 25
                sParameterDescription = "Input Frequency (Phase R)"
            Case "IPRPF"
                sParameterDescription = "Not Used"
            Case "IPSPF"
                sParameterDescription = "Not Used"
            Case "IPTPF"
                sParameterDescription = "Not Used"
            Case "IPRD"
                sParameterDescription = "Not Used"
            Case "IPSD"
                sParameterDescription = "Not Used"
            Case "IPTD"
                sParameterDescription = "Not Used"

            Case Else
                ReadWT230 = -10000.0#
                Exit Function
        End Select

        '  Request value be entered manually if hardware has been disable
        If TestSystem.DisableHardware = True Then

            'Hardware is disabled - Manually enter value
            sMyMessage = "The system hardware is disable - Manual date entry is required" & vbCrLf _
                & "Entry the " & sParameterDescription & " measured at the unit's power cord"
            ReadWT230 = Convert.ToDouble(InputBox("", "Manual Data Entry", ""))

        Else

            'Hardware is NOT disabled
            Delay(0.3, "Delay before Power meter read: MEAS:VAL?")

            strCom = "MEAS:VAL?"
            strResult = SendReceive(Vi, strCom)

            If InStr(1, strResult, ",") = 0 Then
                dblValue = Val(strResult)
            Else
                strData = Split(strResult, ",")
                dblValue = Val(strData(l - 1))
            End If

            ReadWT230 = Val(Format(dblValue, "#####0.###"))

        End If

    End Function
    ''' <summary>
    ''' Read Fluke 8846A measurement value
    ''' </summary>
    Public Function Read8846A(upperlimit As Double) As Double
        Dim Vi As Long
        Dim RetryCount As Integer
        Dim strCom As String, strResult As String, strMessage As String, strResult2 As String
        Dim sCleanedResponse As String
        Dim sRange As String
        Dim LimitPlusOffset As Double

        Try
            RetryCount = 0

            LimitPlusOffset = upperlimit * 1.2
            ' Select Range (0.1, 1, 10, 100, 1000)
            If LimitPlusOffset <= 0.1 Then
                sRange = "0.1"
            ElseIf LimitPlusOffset <= 1 Then
                sRange = "1"
            ElseIf LimitPlusOffset <= 10 Then
                sRange = "10"
            ElseIf LimitPlusOffset <= 100 Then
                sRange = "100"
            Else
                sRange = "1000"
            End If

            Vi = Vi8846A

            ' May need to set range
            strCom = "MEAS:VOLT:DC? " & sRange
            strResult = SendReceive(Vi, strCom)

            ' IF null response retry
            If strResult = "" Then
                strResult = SendReceive(Vi, strCom)
            End If

            ' If still null then stay possible solution
            Do While strResult = "" And RetryCount < 11

                'Init8846A(EquipmentControl.GPIBADDRESS_8846A, Vi8846A, MSG)
                Call CheckInstrument(EquipmentControl.GPIBADDRESS_8846A)

                Vi = Vi8846A

                strResult = SendReceive(Vi, strCom)


                If strResult = "" Then

                    ' List possible reason for null value
                    strMessage = "The Meter is not sending data to the PC " & vbCrLf &
                        "Check/fix the possible reasons listed below: " & vbCrLf &
                          "  - Meter is not turned on (Power Cycle meter or Turn it ON)" & vbCrLf &
                          "  - GPIB USB connector is loose (Reconnect GPIB USB connector)" & vbCrLf &
                          "  - The GPIB cable is loose - Contact Test Engineering" & vbCrLf &
                          "  - If error continues - Contact Test Engineering" & vbCrLf & vbCrLf &
                          "* The test will fail on the 10th retry.  The current retry count is  " & RetryCount

                    MsgBox(strMessage, MsgBoxStyle.OkOnly)

                End If

                RetryCount = RetryCount + 1

            Loop


            ' Some of the meter have ";" in the response - not sure why
            sCleanedResponse = Replace(strResult, ";", "")

            sCleanedResponse = Replace(sCleanedResponse, vbCrLf, "")

            sCleanedResponse = Replace(sCleanedResponse, vbLf, "")

            Read8846A = Double.Parse(sCleanedResponse)

        Catch ex As Exception

            MsgBox(ex.Message, MsgBoxStyle.Critical)

            Read8846A = 9.9999999999999E+300

        End Try

    End Function

    ''' <summary>
    ''' Read Fluke 8846A measurement value
    ''' </summary>
    Public Function Read8846A_VDC_Range(UpperLimit As Double) As Double
        Dim Vi As Long
        Dim writeData As String
        Dim Range As String
        Dim LimitPlusOffset As Double

        LimitPlusOffset = UpperLimit * 1.2

        ' Select Range (0.1, 1, 10, 100, 1000)
        If LimitPlusOffset <= 0.1 Then
            Range = "0.1"
        ElseIf LimitPlusOffset <= 1 Then
            Range = "1"
        ElseIf LimitPlusOffset <= 10 Then
            Range = "10"
        ElseIf LimitPlusOffset <= 100 Then
            Range = "100"
        Else
            Range = "1000"
        End If

        Vi = Vi8846A

        writeData = "VOLT:DC:RANG " & Range
        Call WriteCommand(Vi, writeData)

        Delay(0.1, "Delay for range set")

    End Function


    ''' <summary>
    ''' Read Fluke 8846A measurement value
    ''' </summary>
    Public Function Read8846A_Generic(sReadCmd As String, ByRef sResult As String) As Boolean
        Dim Vi As Long

        Try
            Read8846A_Generic = False

            Vi = Vi8846A

            sResult = SendReceive(Vi, sReadCmd)

            sResult = sResult.TrimEnd(vbLf)

            Read8846A_Generic = True

        Catch ex As Exception

            MsgBox(ex.Message, MsgBoxStyle.Critical)

            sResult = "Error Reading meter"

        End Try

    End Function

End Module
