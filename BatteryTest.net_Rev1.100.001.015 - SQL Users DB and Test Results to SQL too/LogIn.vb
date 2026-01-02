' Revision History:
' ------------------------------------------------------------
' Revision History 
' Author        Date            Notes
' ________________________________________________________________________________
' J. Parker     May 3, 2022     Created


' Revision History:
' ------------------------------------------------------------

Imports vb = Microsoft.VisualBasic
Imports System.IO
Imports System.Text
Imports System.Windows.Forms
Imports System
Imports System.Data
Imports System.Data.OleDb
Imports System.Xml
Imports System.Text.RegularExpressions
Imports System.Data.SqlClient
Imports System.Configuration

Public Class LogIn

    Private dbConn As OleDbConnection
    Private dataCodesForText, dataCodesForParameters As New DataSet
    Private dataAdapterCodesForText, dataAdapterCodesForParameters As OleDbDataAdapter
    Private bindCodesForText, bindCodesForParameters As New BindingSource
    Private dgvstylePass, dgvstyleFail As New DataGridViewCellStyle

    Public sLanguage As String
    Private dtStartTime, dtStopTime As Date
    Private sStepGUID, sTxtData, sTxtDataLimitLow, sTxtDataLimitHigh, sDataUnits, sStatus As String
    Private nStepNameCode, nParameterCode, nDataType As Integer
    Private fNumData, fNumRefData, fNumDataLimitLow, fNumDataLimitHigh As Double
    Private bResult As Boolean
    Private nStepNumber, nStepState As Integer
    Private dtAteOp_StartTime, dtAteOp_StopTime As Date
    Private sAteOp_GUID, sAteOp_Send, sAteOp_Receive As String
    Private nAteOp_State, nAteOp_Number As Integer
    Public bLoginDataVerified As Boolean

    ' SQL User Validation Configuration
    Private config As New AppConfig()


    Private Sub XML_Load_Click(sender As Object, e As EventArgs) Handles XML_Load.Click


        ' Repopulate these values - they get skipped when debugging.
        UUT.sSerialNumber = Me.TxtSerialNumber.Text
        MainTestInterface.txtSerialNumber.Text = UUT.sSerialNumber

        UUT.sOperatorEnumber = Me.TxtUserName.Text
        MainTestInterface.lblEmployeeNumber.Text = UUT.sOperatorEnumber
        MainTestInterface.lblEmployeeName.Text = "EmployeeName"

        UUT.sPartNumber = Me.txtPN.Text
        MainTestInterface.lbl_PartNumber.Text = UUT.sPartNumber

        TestSystem.bXMLReportView = True

        SetupMainTestInterface()



    End Sub

    Dim Line0 As String
    Dim fs As FileIO.FileSystem

    Dim d As FileIO.FileSystem
    Dim fsfile As File
    Dim fsfolder As FileIO.FileSystem
    Dim Byte0, byte1, Byte2, Path, Path01, cn
    Dim EndTest01, EndTest00 As Integer
    Private Declare Function GetSystemMenu Lib "user32" (ByVal hwnd As Long, ByVal bRevert As Long) As Long
    Private Declare Function RemoveMenu Lib "user32" (ByVal hMenu As Long, ByVal nPosition As Long, ByVal wFlags As Long) As Long

    Dim doc As New XmlDocument()

    Dim nodes As XmlNodeList


    Private Sub LogIn_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load


        ' Disable date entry while loading
        SetLogInTest("", "", "", "- Scan Part number ", FocusLocation.NONE)

        bLoginDataVerified = False

        LoadIniVariables()

        ' Clear all inputs, focus on partnumber and enable data entry
        SetLogInTest("", "", "", "- Scan Part number ", FocusLocation.PartNumber)

#If JeffDebug Then  'Jeff Debug stuff  Project -> Compile -> Advance -> Custom Constants

        TxtUserName.Text = "E0089491"
        txtPN.Text = "BATTERYTEST"
        TxtSerialNumber.Text = "BN501Y9999"
        bLoginDataVerified = True
#End If

        Call CheckInstrument(EquipmentControl.GPIBADDRESS_8846A)

    End Sub



    Private Sub txtPN_KeyPress(ByVal sender As System.Object, ByVal e As System.Windows.Forms.KeyPressEventArgs) Handles txtPN.KeyPress

        If Asc(e.KeyChar) = 13 Then

            'Setup to enter Serial number

            SetLogInTest("NOCHANGE", "", "", "- Scan Serial number ", FocusLocation.SerialNumber)

        End If

        If Asc(e.KeyChar) = 27 Then

            'Clear enter part number and keep focus on part number

            SetLogInTest("", "", "", "ESC pressed at Part number box ", FocusLocation.PartNumber)

        End If


    End Sub

    Private Sub TxtSerialNumber_KeyPress(sender As Object, e As KeyPressEventArgs) Handles TxtSerialNumber.KeyPress

        If Asc(e.KeyChar) = 13 Then

            'Setup to enter Employee number

            SetLogInTest("NOCHANGE", "NOCHANGE", "", "- Scan Enumber ", FocusLocation.Enumber)

        End If

        If Asc(e.KeyChar) = 27 Then

            'ESC pressed - Focus on PartNUmber

            SetLogInTest("NOCHANGE", "", "", "ESC pressed at Serial number box ", FocusLocation.PartNumber)

        End If

    End Sub

    Private Sub TxtUserName_KeyPress(ByVal sender As System.Object, ByVal e As System.Windows.Forms.KeyPressEventArgs) Handles TxtUserName.KeyPress

        If Asc(e.KeyChar) = 13 Then

            'Setup to enter Employee number

            SetLogInTest("NOCHANGE", "NOCHANGE", "NOCHANGE", "Press Accept ", FocusLocation.Accept)

        End If

        If Asc(e.KeyChar) = 27 Then

            'ESC pressed - Focus on Serial number

            SetLogInTest("NOCHANGE", "NOCHANGE", "", "ESC pressed at Enumber box ", FocusLocation.SerialNumber)

        End If

    End Sub

    Private Sub btn_Accept_Click(sender As Object, e As EventArgs) Handles btn_Accept.Click
        Dim sJumpBackLocation As String
        Dim sIssue As String
        Dim sTempIssue As String
        Dim sOperatorName As String
        Dim sActualDate As String

        Dim fLowerLimit As Double
        Dim fUpperLimit As Double
        Dim sTestHarness As String = ""
        Dim sProductNotes As String = ""
        Dim sTestScript As String = ""


        Try

            ' Set daily run count

            ' Load test spec data if this the first run of the day
            sActualDate = DateTime.Now.ToString("yyyy-MM-dd")
            If Not (sActualDate = TestSystem.sLatestDate) Then
                ExecuteTest.CopyFilesFromTo(TestSystem.sLocation_NetworkTestSpecData, TestSystem.sLocation_LocalTestSpecData, TestSystem.sFileNameTestSpecData)
                TestSystem.sLatestDate = sActualDate
            End If


            ' Clear variables
            sJumpBackLocation = ""
            sIssue = ""

            ' Verify the correct data and push back to error entry - Test in reverse order and set jump back location if error found

            ' Test Enumber
            If VerifyENumber(TxtUserName.Text, sTempIssue, sOperatorName) = False Then
                sJumpBackLocation = FocusLocation.Enumber
                If sIssue = "" Then
                    sIssue = sTempIssue
                Else
                    sIssue = sIssue & vbCrLf & sTempIssue
                End If

            End If

            ' Test Serial number
            If VerifySerialNumber(TxtSerialNumber.Text, sTempIssue) = False Then
                sJumpBackLocation = FocusLocation.SerialNumber
                If sIssue = "" Then
                    sIssue = sTempIssue
                Else
                    sIssue = sIssue & vbCrLf & sTempIssue
                End If

            End If

            ' Test Part number
            If VerifyPartNumber(txtPN.Text, sTempIssue, fLowerLimit, fUpperLimit, sTestHarness, sProductNotes, sTestScript) = False Then
                sJumpBackLocation = FocusLocation.PartNumber
                If sIssue = "" Then
                    sIssue = sTempIssue
                Else
                    sIssue = sIssue & vbCrLf & sTempIssue
                End If

            End If

            'Data entered is good - start test
            If sJumpBackLocation = "" Then
                'Go to main if Partnumber, serial number and ENumber have been populated

                If MainTestInterface.SystemInitiate() Then

                    'Update MainTestInterface
                    MainTestInterface.lblEmployeeName.Text = sOperatorName : UUT.sOperatorName = sOperatorName
                    MainTestInterface.lblEmployeeNumber.Text = TxtUserName.Text : UUT.sOperatorEnumber = TxtUserName.Text
                    MainTestInterface.lbl_PartNumber.Text = txtPN.Text : UUT.sPartNumber = txtPN.Text
                    MainTestInterface.txtSerialNumber.Text = TxtSerialNumber.Text : UUT.sSerialNumber = TxtSerialNumber.Text
                    MainTestInterface.lbl_TestName.Text = sTestScript : UUT.sTestScript = sTestScript
                    MainTestInterface.lbl_Harness.Text = sTestHarness : UUT.sTestHarness = sTestHarness
                    MainTestInterface.lbl_Notes.Text = sProductNotes : UUT.sProductNotes = sProductNotes

                    UUT.fLowerLimitVoltage = fLowerLimit
                    UUT.fUpperLimitVoltage = fUpperLimit

                    TestSystem.bXMLReportView = False

                    ' Set date and operator run count here
                    sActualDate = DateTime.Now.ToString("yyyy-MM-dd")

                    ' If currentDate and actual date not equal then
                    If Not (UUT.CurrentDate = sActualDate) Then
                        '   - reset operator count, set currentDate = actual date, LastOperate = CurrentOperate
                        UUT.EnumberRunCount = 1
                        UUT.CurrentDate = sActualDate
                        UUT.sLastOperatorEnumber = UUT.sOperatorEnumber
                    Else
                        '    if LastOperate = CurrentOperator then
                        If UUT.sLastOperatorEnumber = UUT.sOperatorEnumber Then
                            '        - increment count 
                            UUT.EnumberRunCount = UUT.EnumberRunCount + 1
                        Else
                            '        - reset count, LastOperate = CurrentOperate
                            UUT.EnumberRunCount = 1
                            UUT.CurrentDate = sActualDate
                            UUT.sLastOperatorEnumber = UUT.sOperatorEnumber
                        End If

                    End If

                    SetupMainTestInterface()

                Else

                    ' System init failed - Do not move to the main test
                    MsgBox("System is not able to Initialize", MsgBoxStyle.OkOnly)

                    SetLogInTest("NOCHANGE", "NOCHANGE", "NOCHANGE", "System is not able to Initialize", FocusLocation.Accept)

                End If

            Else

                ' Set focus back to jump location
                Select Case sJumpBackLocation

                    Case FocusLocation.PartNumber
                        SetLogInTest("", "", "", sIssue, FocusLocation.PartNumber)

                    Case FocusLocation.SerialNumber
                        SetLogInTest("NOCHANGE", "", "", sIssue, FocusLocation.SerialNumber)

                    Case FocusLocation.Enumber
                        SetLogInTest("NOCHANGE", "NOCHANGE", "", sIssue, FocusLocation.SerialNumber)

                    Case FocusLocation.Accept
                        SetLogInTest("NOCHANGE", "NOCHANGE", "NOCHANGE", sIssue, FocusLocation.Accept)

                    Case Else

                        SetLogInTest("NOCHANGE", "NOCHANGE", "NOCHANGE", "btn_Accept_Click ", FocusLocation.Accept)

                End Select

            End If


        Catch ex As Exception

            MsgBox("Error at btn_Accept_Click Issue:  " & sIssue & vbCrLf & ex.Message, MsgBoxStyle.Critical)

        Finally


        End Try

    End Sub


    Private Sub btn_Cancel_Click(sender As Object, e As EventArgs) Handles btn_Cancel.Click

        ' Clear all inputs and start over
        SetLogInTest("", "", "", "Cancel pressed - cleared all to start over ", FocusLocation.PartNumber)

    End Sub


    Public Function VerifySerialNumber(SN As String, ByRef sIssues As String) As Boolean
        Dim value As Integer
        Dim Data As String
        Dim stemp As String
        Dim iWeek As Integer
        Dim iDay As Integer
        Dim TempString As String

        sIssues = ""

        ' Allow the word "TEST" to be used as a serial number (case-insensitive).
        If (SN.ToUpper() = "TEST") Then Return True

        'Length Is 10 characters for RAP serial numbers.
        If Not (SN.Length = 10) Then
            sIssues = "- Invalid SN: The serial number must contain 10 characters."
            Return False
        End If

        'characters And starting with 5UO = HP serial number
        stemp = Mid(SN, 1, 3)
        If (Mid(SN, 1, 3) = "5UO") Then Return True

        'Character 1 Location.RPO = "E".YPO = "B".
        stemp = Mid(SN, 1, 1)
        If Not (Mid(SN, 1, 1) = "B") Then
            sIssues = "- Invalid SN: First character must equal B."
            Return False
        End If

        ' Check year Digit 2  - Valid Year Code:  ABCDEFGHJKLMNPQRSTUVWXY-  Q = 2021
        If (InStr("ABCDEFGHJKLMNPQRSTUVWXY", Mid(SN, 2, 1)) < 1) Then
            sIssues = "- Invalid SN: digit 2 must have a valid date code:  ABCDEFGHJKLMNPQRSTUVWXY."
            Return False
        End If


        ' Check week 3-4  ( Should be 1 to 53)
        TempString = Mid(SN, 3, 2)
        If Not (IsNumeric(Mid(SN, 3, 2))) Then
            sIssues = "- Invalid SN: digit 3 and 4 must be numeric."
            Return False
        End If

        iWeek = CInt(Mid(SN, 3, 2))

        If (iWeek < 1 Or iWeek > 53) Then
            sIssues = "- Invalid SN: digit 3 and 4 range must be 1 to 53."
            Return False
        End If

        'Character 5 Day.
        If Not (IsNumeric(Mid(SN, 5, 1))) Then
            sIssues = "- Invalid SN: digit 5 must be numeric."
            Return False
        End If

        iDay = CInt(Mid(SN, 5, 1))

        If (iDay < 1 Or iDay > 7) Then
            sIssues = "- Invalid SN: digit 5 range must be 1 to 7."
            Return False
        End If

        ' Character 6 battery  - Valid Year Code:  DEHKSY
        If (InStr("DEHKSY", Mid(SN, 6, 1)) < 1) Then
            sIssues = "- Invalid SN: digit 6 must have a valid date code:  ABCDEFGHJKLMNPQRSTUVWXY."
            Return False
        End If

        'Success
        Return True

    End Function

    Public Function VerifyENumber(ByRef sENumber As String, ByRef sIssues As String, ByRef sOperatorName As String) As Boolean
        Dim sFilePath As String
        Dim sEnumber1 As String
        Dim sEnumber2 As String
        Dim sEnumberTemp As String

        VerifyENumber = False
        sIssues = "Enumber: " & sENumber & " not found "

        ' Check if SQL validation is enabled
        If config.IsUserSQLValidationEnabled() Then
            ' Use ONLY SQL validation - no fallback
            Dim result = config.ValidateUserAgainstSQL(sENumber)
            If result.isValid Then
                sOperatorName = result.fullName
                sIssues = ""
                VerifyENumber = True
            Else
                ' SQL validation failed - do not fall back to XML
                sIssues = "- SQL validation failed for Enumber: " & sENumber
            End If
        Else
            ' Use XML validation (original method)
            sFilePath = System.Windows.Forms.Application.StartupPath & "\TestSpec\EmployeeBatteryLine.xml"

            ' Add Part number check here
            Dim doc As New XmlDocument()

            doc.Load(sFilePath)

            Dim nodes As XmlNodeList = doc.DocumentElement.SelectNodes("/DocumentElement/DataTable1")

            For Each node As XmlNode In nodes

                sEnumber1 = node.SelectSingleNode("Enumber1").InnerText
                sEnumber2 = node.SelectSingleNode("Enumber2").InnerText
                sOperatorName = node.SelectSingleNode("Name").InnerText

                If sENumber = sEnumber1 Or sENumber = sEnumber2 Then

                    sIssues = ""

                    VerifyENumber = True

                    ' Switch enumber to full version
                    sENumber = sEnumber1

                    Exit For

                End If

            Next

            If VerifyENumber = False Then
                sIssues = "- Invalid Enumber:  Enumber entered -> " & sENumber
            End If
        End If

    End Function


    Public Function VerifyPartNumber(sPartNumber As String, ByRef sIssues As String, ByRef fLowerLimit As Double, ByRef fUpperLimit As Double, ByRef sTestHarness As String, ByRef sProductNotes As String, ByRef sTestScript As String) As Boolean
        Dim sFilePath As String
        Dim sTemp As String

        VerifyPartNumber = False

        sFilePath = System.Windows.Forms.Application.StartupPath & "\TestSpec\BatteryTestSpecs.xml"

        ' Add Part number check here
        Dim doc As New XmlDocument()

        doc.Load(sFilePath)

        Dim nodes As XmlNodeList = doc.DocumentElement.SelectNodes("/Store/BatteryData")

        For Each node As XmlNode In nodes

            sTemp = node.SelectSingleNode("PartNumber").InnerText

            If sPartNumber = sTemp And sPartNumber.Length > 3 Then

                fLowerLimit = node.SelectSingleNode("LowerLimit").InnerText
                fUpperLimit = node.SelectSingleNode("UpperLimit").InnerText
                sTestHarness = node.SelectSingleNode("Harness").InnerText
                sProductNotes = "Product Notes: " & node.SelectSingleNode("Notes").InnerText
                sTestScript = node.SelectSingleNode("TestScript").InnerText

                VerifyPartNumber = True

                Exit For

            End If

        Next

        If VerifyPartNumber = False Then
            sIssues = "- Invalid PN:  PN entered -> " & sPartNumber
        End If

    End Function


    Public Function LoadIniVariables() As Boolean

        Try

            '---------------------------------------------------

            Dim Filenumber As Integer
            Dim GetLine As String
            Dim INSTRUCTION00, INSTVALUE00 As String
            Dim AL0 As Integer
            '-------------------------------------------Get config info-------------------------------------------------------------------------
            Filenumber = FreeFile()

            FileOpen(Filenumber, TestSystem.SystemConfig_Path, OpenMode.Input)

            Do While Not EOF(Filenumber)

                'GetLine = UCase(Trim(LineInput(Filenumber)))
                GetLine = Trim(LineInput(Filenumber))

                AL0 = InStr(GetLine, "=") - 1

                If AL0 < 0 Then AL0 = 0

                INSTRUCTION00 = UCase(RTrim(vb.Left(GetLine, AL0)))
                INSTVALUE00 = Trim(Mid(GetLine, AL0 + 2))


                Select Case INSTRUCTION00

                    Case "XMLDEBUGPATH" : TestSystem.sXMLDebugPath = UCase(INSTVALUE00)

                    Case "WORKSTATIONNAME" : TestSystem.sWorkstationName = INSTVALUE00

                    Case "DISABLEHARDWARE"
                        If UCase(INSTVALUE00) = "TRUE" Then
                            TestSystem.DisableHardware = True
                        Else
                            TestSystem.DisableHardware = False
                        End If

                    Case "CHECKDUPSERIALNUMBER"
                        If UCase(INSTVALUE00) = "FALSE" Then
                            TestSystem.CheckDupSerialNumber = False
                        Else
                            TestSystem.CheckDupSerialNumber = True
                        End If

                    Case "VERIFYPREFLIGHTCHECKLIST"
                        If UCase(INSTVALUE00) = "FALSE" Then
                            TestSystem.bVerifyPreFlightCheckList = False
                        Else
                            TestSystem.bVerifyPreFlightCheckList = True
                        End If

                    Case "PREFLIGHT_DB"
                        'TestSystem.sPreFlightDBConnection = "Provider=SQLOLEDB;Data Source=" & INSTVALUE00 & ";Database=TestVerificationChecklists;Trusted_Connection=Yes;"
                        TestSystem.sPreFlightDBConnection = "Provider=SQLOLEDB;Data Source=" & INSTVALUE00 & ";Database=TestVerificationChecklists;Password=eaton;User ID=PreflightChecker;"

                    Case "GPIBADDRESS_8846A"
                        EquipmentControl.GPIBADDRESS_8846A = INSTVALUE00

                    Case "USESQLUSERVALIDATION"
                        ' This setting is read by AppConfig class, no action needed here

                    Case "BATTERYLINEID"
                        ' This setting is read by AppConfig class, no action needed here

                    Case Else

                End Select

            Loop : FileClose(Filenumber)


        Catch ex As Exception

            ErrorPrompt.ErrNote("7:" & "exception occur in LoadIniVariables " & ex.Message.ToString, False)

        End Try

    End Function

    Public Sub SetupMainTestInterface()

        Hide()

        MainTestInterface.dgvStepResults.Columns.Add("StepNumber", "Step")
        MainTestInterface.dgvStepResults.Columns.Add("StartTime", "Start Time")
        MainTestInterface.dgvStepResults.Columns.Add("StopTime", "Stop Time")
        MainTestInterface.dgvStepResults.Columns.Add("StepName", "Step Name")
        MainTestInterface.dgvStepResults.Columns.Add("TestComment", "Comment")
        MainTestInterface.dgvStepResults.Columns.Add("Units", "Units")
        MainTestInterface.dgvStepResults.Columns.Add("DataLimitLow", "Low Limit")
        MainTestInterface.dgvStepResults.Columns.Add("DataLimitHigh", "High Limit")
        MainTestInterface.dgvStepResults.Columns.Add("ParameterKey", "Para Key")
        MainTestInterface.dgvStepResults.Columns.Add("ParameterValue", "Para Value")
        MainTestInterface.dgvStepResults.Columns.Add("ParameterUnits", "Para Units")
        MainTestInterface.dgvStepResults.Columns.Add("Results", "Results")
        MainTestInterface.dgvStepResults.Columns.Add("Status", "Status")
        MainTestInterface.dgvStepResults.Columns.Add("CallingFunction", "Calling Function (Three Deep)")

        MainTestInterface.dgvStepResults.Columns("StepNumber").Width = 30
        MainTestInterface.dgvStepResults.Columns("StartTime").Width = 80
        MainTestInterface.dgvStepResults.Columns("StopTime").Width = 80
        MainTestInterface.dgvStepResults.Columns("StepName").Width = 400
        MainTestInterface.dgvStepResults.Columns("TestComment").Width = 200
        MainTestInterface.dgvStepResults.Columns("Units").Width = 150
        MainTestInterface.dgvStepResults.Columns("DataLimitLow").Width = 60
        MainTestInterface.dgvStepResults.Columns("DataLimitHigh").Width = 60
        MainTestInterface.dgvStepResults.Columns("ParameterKey").Width = 60
        MainTestInterface.dgvStepResults.Columns("ParameterValue").Width = 60
        MainTestInterface.dgvStepResults.Columns("ParameterUnits").Width = 60
        MainTestInterface.dgvStepResults.Columns("Results").Width = 300
        MainTestInterface.dgvStepResults.Columns("Status").Width = 95
        MainTestInterface.dgvStepResults.Columns("CallingFunction").Width = 300

        MainTestInterface.dgvStepResults.SelectionMode = DataGridViewSelectionMode.FullRowSelect
        MainTestInterface.dgvStepResults.RowHeadersVisible = False

        'Set word wrap
        MainTestInterface.dgvStepResults.RowsDefaultCellStyle.WrapMode = DataGridViewTriState.True

        MainTestInterface.dgvAteOpData.Columns.Add("ID", "ID")
        MainTestInterface.dgvAteOpData.Columns.Add("StepNumber", "Step")
        MainTestInterface.dgvAteOpData.Columns.Add("Time", "Time")
        MainTestInterface.dgvAteOpData.Columns.Add("Send", "Send")
        MainTestInterface.dgvAteOpData.Columns.Add("Receive", "Receive")
        MainTestInterface.dgvAteOpData.Columns.Add("Comment", "Comment")

        MainTestInterface.dgvAteOpData.Columns("ID").Width = 40
        MainTestInterface.dgvAteOpData.Columns("StepNumber").Width = 40
        MainTestInterface.dgvAteOpData.Columns("Time").Width = 80
        MainTestInterface.dgvAteOpData.Columns("Send").Width = 400
        MainTestInterface.dgvAteOpData.Columns("Receive").Width = 300
        MainTestInterface.dgvAteOpData.Columns("Comment").Width = 500

        MainTestInterface.dgvAteOpData.SelectionMode = DataGridViewSelectionMode.FullRowSelect

        'Set word wrap
        MainTestInterface.dgvAteOpData.RowsDefaultCellStyle.WrapMode = DataGridViewTriState.True

        MainTestInterface.Show()

    End Sub

    Public Function SetLogInTest(PartNumberStr As String, SerialNumberStr As String, EmployeeNumberStr As String, Issue As String, ByVal focus As FocusLocation)

        'Disable all textboxs before changing
        txtPN.Enabled = False
        TxtSerialNumber.Enabled = False
        TxtUserName.Enabled = False

        Select Case focus

            Case FocusLocation.PartNumber

                txtPN.Enabled = True
                txtPN.Focus()

            Case FocusLocation.SerialNumber

                TxtSerialNumber.Enabled = True
                TxtSerialNumber.Focus()

            Case FocusLocation.Enumber

                TxtUserName.Enabled = True
                TxtUserName.Focus()

            Case FocusLocation.Accept
                btn_Accept.Focus()

            Case FocusLocation.Cancel
                btn_Cancel.Focus()

            Case FocusLocation.XML
                XML_Load.Focus()

            Case FocusLocation.NONE

                ' Disable all
                txtPN.Enabled = False
                TxtSerialNumber.Enabled = False
                TxtUserName.Enabled = False

            Case Else

                lbl_Issues.Text = "Error condition in SetLogInTest "

        End Select

        If PartNumberStr = "NOCHANGE" Then
            ' Do nothing - Keep value unchanged
        Else
            txtPN.Text = PartNumberStr
        End If

        If SerialNumberStr = "NOCHANGE" Then
            ' Do nothing - Keep value unchanged
        Else
            TxtSerialNumber.Text = SerialNumberStr
        End If

        If EmployeeNumberStr = "NOCHANGE" Then
            ' Do nothing - Keep value unchanged
        Else
            TxtUserName.Text = EmployeeNumberStr
        End If

        If Issue = "NOCHANGE" Then
            ' Do nothing - Keep value unchanged
        Else
            lbl_Issues.Text = Issue
        End If

        Refresh()

    End Function


    Enum FocusLocation
        PartNumber
        SerialNumber
        Enumber
        Cancel
        Accept
        XML
        NONE
    End Enum

End Class