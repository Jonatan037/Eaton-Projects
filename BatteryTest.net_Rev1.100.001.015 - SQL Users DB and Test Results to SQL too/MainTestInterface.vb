

Imports vb = Microsoft.VisualBasic
Imports System.IO
Imports Microsoft.Office.Interop
Imports System.Drawing
Imports System.Windows.Forms.VisualStyles.VisualStyleElement.Window


Public Class MainTestInterface

    Dim PassTotal, TestTotal As Integer
    Dim OutFile As String
    Public ProductPartNumber As String
    Dim StartDate, StartTime, EndDate, EndTime As Date
    Dim CopyPath As String
    Public myReport As ReportItem
    Public Myreportwiter As New ReportGeneration
    Public ReportName As String = ""
    Public ReportWriter As StreamWriter
    Public Errmsg As String
    Public TestProcedure As String
    Public ATETestMode As Boolean
    Public PowerRight As Integer
    Private Declare Function GetTickCount Lib "kernel32" () As Long
    Private nTicksLastRefresh As Long = 0
    Public bManualUpdateEnabled As Boolean = True
    Public bRefreshSet As Boolean = False
    Public RefreshDisabled As Boolean = False


    Public Function SetmyReport(ByVal StartTime As String, ByVal EndTime As String, ByVal Result As String,
                                ByVal ItemValue As String, ByVal HiLimit As String, ByVal LoLimit As String) As Boolean

        If StartTime.ToUpper <> "NC" Then
            myReport.StartTime = StartTime
        End If

        If EndTime.ToUpper <> "NC" Then
            myReport.EndTime = EndTime
        End If

        If ItemValue.ToUpper <> "NC" Then
            myReport.ItemValue = ItemValue
        End If

        If HiLimit.ToUpper <> "NC" Then
            myReport.HiLimit = HiLimit
        End If

        If LoLimit.ToUpper <> "NC" Then
            myReport.LoLimit = LoLimit
        End If

        If Result.ToUpper <> "NC" Then
            myReport.Result = Result
        End If

    End Function

    Public Function clearmyReport() As Boolean

        myReport.StartTime = ""
        myReport.EndTime = ""
        myReport.ParameterName = ""
        myReport.TestItem = ""
        myReport.ItemValue = ""
        myReport.HiLimit = ""
        myReport.LoLimit = ""
        myReport.Result = ""

    End Function



    Public Function StartTest() As Boolean

        Dim bSequenceResults As Boolean

        On Error GoTo Error0A
        '---------------------------Set starttime, output file information and initial test information -----------------------------------

        ' Disable button

        bSequenceResults = False

        btn_LoadXMLReport.Enabled = False

        myReport.ATEName = TestSystem.sWorkstationName

        myReport.ATESoftwareVersion = My.Application.Info.Version.ToString

        'Start test data
        ExecuteTest.myTestData = New TestDataset()

        'Clear the data grid view - Needed on second pass
        dgvStepResults.Rows.Clear()
        dgvAteOpData.Rows.Clear()

        ' Update last serial number on login screen
        LogIn.lbl_LastSN.Text = "Last SN Tested: " & UUT.sSerialNumber

        RunningProcess()

        If ExecuteTest.BatteryTestSequence() Then

            bSequenceResults = True

        End If


        'Set Overall Pass/Fail 
        If myTestData.GetFinalStatus_Passed() And myTestData.lstTestDataItem.Count >= 2 And bSequenceResults Then
            myTestData.EndTest(myTestData.PASSED_FAILED.Passed)
            PassProcess()
        Else
            myTestData.EndTest(myTestData.PASSED_FAILED.Failed)
            FailProcess()
        End If

#If Not JeffDebug Then   ' Dont submit data if debugging

        'Create XML file that will be pushed to TDM
        myTestData.WriteToXML(UUT.sSerialNumber & "_" & Now.ToString("MM_dd_yyyy_HHmmsstt"), False)

        'Save test results to SQL database (dual storage: XML/PCAT + SQL)
        myTestData.SaveToSQL()

        'Push all XML file in .../Pending/ to TDM database
        DBProcess.submit_data()

#End If


        'Create XML file for debugging - may create enable button for this
        myTestData.WriteToXML(UUT.sSerialNumber & "_" & Now.ToString("MM_dd_yyyy_HHmmsstt"), True)

        UUT.Clear()

        ' Enable button
        btn_LoadXMLReport.Enabled = True

        'Clear the unit model
        LogIn.txtPN.Text = ""
        LogIn.TxtSerialNumber.Text = ""
        LogIn.TxtUserName.Text = ""

        'Disable Serial Number enter - This will force the operator to close the MainInterface to start the next test
        txtSerialNumber.Enabled = False
        'txtSerialNumber.Hide()

        Me.Update()

        Me.Close()
        'LogIn.Show()

        LogIn.txtPN.Focus()

        Exit Function

Error0A:

        'MsgBox(Err.Description & EquipmentControl.MSG, MsgBoxStyle.Critical)

        Close()

    End Function

    Private Sub MainTestInterface_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load

        ' Added condition - Have some test report with no serial number - Not sure how this happens
        ' Bypass serial number length validation for "Test" or "test"
        If TestSystem.bXMLReportView = False And
           ((UUT.sSerialNumber.Length = 10 And UUT.sPartNumber.Length > 3) Or
            (UUT.sSerialNumber.ToLower() = "test")) Then

            Call StartTest()

        End If

    End Sub
    Public Function SystemInitiate() As Boolean
        Dim I As Integer
        Try

            'Call CheckInstrument(EquipmentControl.GPIBADDRESS_8846A)

            LblStartTestTime.Text = ""
            LblEndTestTime.Text = ""

            Me.Text = "Battery Line Test"

            Return True

        Catch ex As Exception

        End Try

        Exit Function

    End Function


    Public Function UpdateDispaly() As Boolean

        ' Me.Refresh()   ''''' Nov 7, 2018 - this is causing a lot of delay, so use the line below instead - J. Smith
        If nTicksLastRefresh + 200 < GetTickCount Then
            System.Windows.Forms.Application.DoEvents()
            nTicksLastRefresh = GetTickCount
        End If

        Return True

    End Function

    Public Function PassProcess() As Boolean

        txtSerialNumber.Enabled = True
        lblState.BackColor = Color.Green
        lblState.Text = "Pass"
        lblState.Visible = True

        MsgBox("Serial number: " & UUT.sSerialNumber & " - PASSED", MsgBoxStyle.OkOnly)

        Application.DoEvents()

    End Function

    Public Function RunningProcess() As Boolean

        lblState.BackColor = Color.Cyan
        lblState.Text = "Run-g"

        Application.DoEvents()

    End Function

    Public Function FailProcess() As Boolean

        txtSerialNumber.Enabled = True
        lblState.BackColor = Color.Red
        lblState.Text = "Failed"
        lblState.Visible = True

        MsgBox("Serial number: " & UUT.sSerialNumber & " - FAILED", MsgBoxStyle.OkOnly)

        Application.DoEvents()

    End Function

    Sub Text2Display()

        txtSerialNumber.Enabled = True

        txtSerialNumber.SelectionStart = 0
        txtSerialNumber.SelectAll()

        txtSerialNumber.Focus()


    End Sub

    Private Sub MainTestInterface_FormClosed(ByVal sender As System.Object, ByVal e As System.Windows.Forms.FormClosedEventArgs) Handles MyBase.FormClosed
        Try

            Hide()

            LogIn.Show()

            ' Clear all inputs, focus on partnumber and enable data entry
            LogIn.SetLogInTest("", "", "", "Login Form loaded ", LogIn.FocusLocation.PartNumber)

            LogIn.Refresh()

        Catch ex As Exception

        End Try
    End Sub

    Protected Overrides Sub Finalize()
        MyBase.Finalize()
        FileClose()
    End Sub

    'Public Event UpdateGuiStepComm(nStepIdx As Integer, nCommIdx As Integer)


    Public Sub UpdateGuiStepComm(ByVal nStepIdx As Integer, ByVal nCommIdx As Integer)
        Dim n As Integer
        Dim CommType As Integer

        dgvAteOpData.Rows.Add(1)

        n = dgvAteOpData.RowCount - 1

        CommType = myTestData.lstTestDataItem(nStepIdx).lstCommunication(nCommIdx).eTXRX

        dgvAteOpData.Rows(n).Cells("ID").Value = ""
        dgvAteOpData.Rows(n).Cells("StepNumber").Value = nStepIdx & "." & nCommIdx
        dgvAteOpData.Rows(n).Cells("Time").Value = Format(myTestData.lstTestDataItem(nStepIdx).lstCommunication(nCommIdx).dtTime, "HH:mm:ss")

        If CommType = Communication.TXRX.TX Then
            ' the step is starting
            dgvAteOpData.Rows(n).Cells("Send").Value = myTestData.lstTestDataItem(nStepIdx).lstCommunication(nCommIdx).sCommText
        End If

        If CommType = Communication.TXRX.RX Then
            ' the step is completing so display the rest of the data then reset the state to 0
            dgvAteOpData.Rows(n).Cells("Receive").Value = myTestData.lstTestDataItem(nStepIdx).lstCommunication(nCommIdx).sCommText
        End If

        If CommType = Communication.TXRX.COMMENT Then
            ' the step is completing so display the rest of the data then reset the state to 0
            dgvAteOpData.Rows(n).Cells("Comment").Value = myTestData.lstTestDataItem(nStepIdx).lstCommunication(nCommIdx).sCommText
        End If

        dgvAteOpData.AutoResizeRow(n)

        dgvAteOpData.FirstDisplayedScrollingRowIndex = dgvAteOpData.Rows.Count - 1

        'Enable based on fresh
        If bRefreshSet Then

            Me.UpdateDispaly()

            'Clear the bRefreshSet flag is the manual refresh is set
            If bManualUpdateEnabled Then

                bRefreshSet = False

            End If

        End If

    End Sub

    Private Sub btn_SendReportToTDM_Click(sender As Object, e As EventArgs) Handles btn_SendReportToTDM.Click

        'Disable Serial Number enter - This will force the operator to close the MainInterface to start the next test
        txtSerialNumber.Enabled = False

        'Push all XML file in .../Pending/ to TDM database
        DBProcess.submit_data()

        ' Enable button
        btn_LoadXMLReport.Enabled = True
        btn_SendReportToTDM.Enabled = True

        'Clear the unit model
        LogIn.SetLogInTest("", "", "", "", LogIn.FocusLocation.PartNumber)
        UUT.Clear()

        'txtSerialNumber.Hide()
        Me.UpdateDispaly()

    End Sub

    Private Sub btn_UpdateTestSpec_Click(sender As Object, e As EventArgs) Handles btn_UpdateTestSpec.Click
        Dim sFileName() As String = {"EmployeeBatteryLine.xml", "BatteryTestSpecs.xml"}
        Dim sToLocation As String

        'Disable Serial Number enter - This will force the operator to close the MainInterface to start the next test
        txtSerialNumber.Enabled = False

        sToLocation = System.Windows.Forms.Application.StartupPath & "\TestSpec"

        ' Copy Test specs from network to local folder - send Good/bad prompt in copy function
        ExecuteTest.CopyFilesFromTo("\\youncsfp01\DATA\Test-Eng\ProdTestData\TestSpecs\BatteryLine\TestSpec", sToLocation, sFileName)


        ' Enable button
        btn_LoadXMLReport.Enabled = True
        btn_SendReportToTDM.Enabled = True
        btn_UpdateTestSpec.Enabled = True

        'Clear the unit model
        LogIn.SetLogInTest("", "", "", "", LogIn.FocusLocation.PartNumber)
        UUT.Clear()

        'txtSerialNumber.Hide()
        Me.UpdateDispaly()

    End Sub




    'Public Event UpdateGuiStep(ByVal nStepIdx As Integer, ByVal bStepComplete As Boolean)
    Public Sub UpdateGuiStep(ByVal nStepIdx As Integer, ByVal bStepComplete As Boolean)
        Dim n As Integer
        Dim nStepState As Integer
        Dim nDataType As Integer

        Try

            Me.LblDuration.Text = Format(DateDiff(DateInterval.Second, myTestData.dtStartTime, Now) / 60, "##0.00")

            nStepState = myTestData.GetnTestStepState()

            n = dgvStepResults.RowCount - 1

            If nStepState = 0 Then
                ' we are between steps, so we shouldn't be displaying anything
                ' give an error so the developer can troubleshoot why this happened
                MsgBox("Error: Can't update a display when there isn't an active test step.  Start a new test step first.")

            ElseIf nStepState = 1 Then
                ' the step is just starting, so set the basic info
                dgvStepResults.Rows.Add(1)
                n = dgvStepResults.RowCount - 1
                dgvStepResults.Rows(n).Cells("StepNumber").Value = nStepIdx
                dgvStepResults.Rows(n).Cells("StartTime").Value = Format(myTestData.lstTestDataItem(nStepIdx).dtStartTime, "HH:mm:ss.f")
                dgvStepResults.Rows(n).Cells("StepName").Value = myTestData.lstTestDataItem(nStepIdx).sInstructionName
                dgvStepResults.Rows(n).Cells("Units").Value = myTestData.lstTestDataItem(nStepIdx).sTestUnits
                dgvStepResults.Rows(n).Cells("TestComment").Value = myTestData.lstTestDataItem(nStepIdx).sTestComments
                dgvStepResults.Rows(n).Cells("Status").Value = "Testing"
                dgvStepResults.Rows(n).Cells("CallingFunction").Value = myTestData.lstTestDataItem(nStepIdx).strCallingFunction


            ElseIf nStepState = 2 Then
                n = dgvStepResults.RowCount - 1
                ' the step is completing so display the rest of the data
                nDataType = myTestData.lstTestDataItem(nStepIdx).nStepDataType

                ' Start fixing here nDataType
                'nDataType:  0 -> nothing 1-> Results 2 -> Units, Results, 3 -> Units, Results, 4 -> Unit, Results, DataLimit*, Paraeterkey, ParameterValue, ParameteUnits
                Select Case nDataType
                    Case 0
                        ' no data so do nothing

                    Case 1
                        ' text data

                        dgvStepResults.Rows(n).Cells("Results").Value = myTestData.lstTestDataItem(nStepIdx).sResults

                    Case 2
                        ' numeric data with no limits
                        dgvStepResults.Rows(n).Cells("Units").Value = myTestData.lstTestDataItem(nStepIdx).sTestUnits
                        dgvStepResults.Rows(n).Cells("Results").Value = myTestData.lstTestDataItem(nStepIdx).sResults

                    Case 3
                        ' measurement data with limits and no paramters
                        dgvStepResults.Rows(n).Cells("Units").Value = myTestData.lstTestDataItem(nStepIdx).sTestUnits
                        dgvStepResults.Rows(n).Cells("Results").Value = myTestData.lstTestDataItem(nStepIdx).sResults

                    Case 4
                        ' measurement data with limits and parameter values
                        dgvStepResults.Rows(n).Cells("Units").Value = myTestData.lstTestDataItem(nStepIdx).sTestUnits
                        dgvStepResults.Rows(n).Cells("Results").Value = myTestData.lstTestDataItem(nStepIdx).sResults
                        dgvStepResults.Rows(n).Cells("DataLimitLow").Value = myTestData.lstTestDataItem(nStepIdx).fLowerTestLimit.ToString
                        dgvStepResults.Rows(n).Cells("DataLimitHigh").Value = myTestData.lstTestDataItem(nStepIdx).fUpperTestLimit.ToString

                        'TODO fix 
                        If myTestData.lstTestDataItem(nStepIdx).lstTestResultParameters.Count > 0 Then
                            dgvStepResults.Rows(n).Cells("ParameterKey").Value = myTestData.lstTestDataItem(nStepIdx).lstTestResultParameters(0).sParameter_Key
                            dgvStepResults.Rows(n).Cells("ParameterValue").Value = myTestData.lstTestDataItem(nStepIdx).lstTestResultParameters(0).sParameter_Value
                            dgvStepResults.Rows(n).Cells("ParameterUnits").Value = myTestData.lstTestDataItem(nStepIdx).lstTestResultParameters(0).sParameter_Unit
                        End If

                    Case 5
                        ' measurement data with limits and parameter values - Part2 two of two step function (The percentage stuff)

                        ' This is the part2 so the new grid needs to be added and populate
                        dgvStepResults.Rows.Add(1)
                        n = dgvStepResults.RowCount - 1
                        dgvStepResults.Rows(n).Cells("StepNumber").Value = nStepIdx
                        dgvStepResults.Rows(n).Cells("StartTime").Value = Format(myTestData.lstTestDataItem(nStepIdx).dtStartTime, "HH:mm:ss.f")
                        dgvStepResults.Rows(n).Cells("StepName").Value = myTestData.lstTestDataItem(nStepIdx).sInstructionName
                        dgvStepResults.Rows(n).Cells("Units").Value = myTestData.lstTestDataItem(nStepIdx).sTestUnits
                        dgvStepResults.Rows(n).Cells("TestComment").Value = myTestData.lstTestDataItem(nStepIdx).sTestComments
                        dgvStepResults.Rows(n).Cells("Status").Value = "Testing"
                        dgvStepResults.Rows(n).Cells("CallingFunction").Value = myTestData.lstTestDataItem(nStepIdx).strCallingFunction

                        ' measurement data with limits and parameter values - Part2 two of two step function (The percentage stuff)
                        dgvStepResults.Rows(n).Cells("Units").Value = myTestData.lstTestDataItem(nStepIdx).sTestUnits
                        dgvStepResults.Rows(n).Cells("Results").Value = myTestData.lstTestDataItem(nStepIdx).sResults
                        dgvStepResults.Rows(n).Cells("DataLimitLow").Value = myTestData.lstTestDataItem(nStepIdx).fLowerTestLimit.ToString & "%"
                        dgvStepResults.Rows(n).Cells("DataLimitHigh").Value = myTestData.lstTestDataItem(nStepIdx).fUpperTestLimit.ToString & "%"

                        'TODO fix 
                        If myTestData.lstTestDataItem(nStepIdx).lstTestResultParameters.Count > 0 Then
                            dgvStepResults.Rows(n).Cells("ParameterKey").Value = myTestData.lstTestDataItem(nStepIdx).lstTestResultParameters(0).sParameter_Key
                            dgvStepResults.Rows(n).Cells("ParameterValue").Value = myTestData.lstTestDataItem(nStepIdx).lstTestResultParameters(0).sParameter_Value
                            dgvStepResults.Rows(n).Cells("ParameterUnits").Value = myTestData.lstTestDataItem(nStepIdx).lstTestResultParameters(0).sParameter_Unit
                        End If


                    Case Else
                        ' no data so do nothing

                End Select
                If nDataType = 0 Then
                    ' no data so do nothing

                End If

                dgvStepResults.Rows(n).Cells("StopTime").Value = Format(myTestData.lstTestDataItem(nStepIdx).dtEndTime, "HH:mm:ss.f")

                dgvStepResults.Rows(n).Cells("Status").Value = myTestData.lstTestDataItem(nStepIdx).sStatus

                dgvStepResults.Rows(n).Cells("TestComment").Value = myTestData.lstTestDataItem(nStepIdx).sTestComments

                If myTestData.lstTestDataItem(nStepIdx).sStatus = "Passed" Then
                    dgvStepResults.Rows(n).Cells("Status").Style.ForeColor = Color.Blue
                Else
                    dgvStepResults.Rows(n).Cells("Status").Style.ForeColor = Color.Red
                End If

                dgvStepResults.AutoResizeRow(n)

                dgvStepResults.FirstDisplayedScrollingRowIndex = dgvStepResults.Rows.Count - 1

                ' since the step is complete, set the state back to 0 
                nStepState = 0
            End If

            Me.UpdateDispaly()

        Catch ex As Exception

            TDMErrorCatch("Error at UpdateGuiStep: ", ex)

        End Try

    End Sub



    ' Update step comment only
    Public Sub UpdateGuiStep_Comment(ByVal nStepIdx As Integer)
        Dim n As Integer
        Dim nStepState As Integer
        Dim nDataType As Integer

        n = dgvStepResults.RowCount - 1

        dgvStepResults.Rows(n).Cells("TestComment").Value = myTestData.lstTestDataItem(nStepIdx).sTestComments

        'I think this is slowing down the update
        dgvStepResults.AutoResizeRow(n)

        Me.UpdateDispaly()

    End Sub



    Private Sub btn_ManualUpdate_Click(sender As System.Object, e As System.EventArgs) Handles btn_ManualUpdate.Click
        'Toggle Button state
        bManualUpdateEnabled = Not (bManualUpdateEnabled)

        'Enable/Disable Manual Update
        If bManualUpdateEnabled Then
            bRefreshSet = False
            btn_ManualUpdate.Text = "Update at MAIN Step Click_to_change"
        Else
            btn_ManualUpdate.Text = "Update at EVER step Click_to_change"
            bRefreshSet = True
        End If
    End Sub



    Private Sub btn_LoadXMLReport_Click(sender As System.Object, e As System.EventArgs) Handles btn_LoadXMLReport.Click
        Dim XML_Path As String
        Dim nStepIdx As Integer
        Dim n As Integer
        Dim i As Integer
        Dim j As Integer

        ' Load XML report into the data grid

        ' Disable the button
        btn_LoadXMLReport.Enabled = False

        ' Change the button to - in process
        btn_LoadXMLReport.Text = "XML LOAD - IN PROCESS"

        ' Find the file
        Using dialog As New OpenFileDialog

            dialog.Filter = "XML Files|*.xml"

            'dialog.InitialDirectory = Application.StartupPath & "\Debug_xml\"

            dialog.InitialDirectory = "\\youncsfp01\data\Test-Eng\ProdTestData\Data_Logs\BatteryLine\Debug_xml\"

            ' If dialog.ShowDialog() <> DialogResult.OK Then Return

            XML_Path = dialog.FileName

        End Using



        ' Load the test data collection
        If IsNothing(myTestData) Then

            'Create instance of myTestData
            ExecuteTest.myTestData = New TestDataset()


        End If

        myTestData.ReadFromXML(XML_Path)

        ' Clear the data grid
        dgvAteOpData.Rows.Clear()
        dgvStepResults.Rows.Clear()


        'Populate main test info here

        'Outer loop for lstTestDataItem 0 to Count -1
        For Each el1 In myTestData.lstTestDataItem

            'Pull serial number and catalog number from first element
            If el1.uSequenceNumber = 1 Then
                txtSerialNumber.Text = el1.sSerialNumber
                'lblUCF.Text = el1.s
            End If

            dgvStepResults.Rows.Add(1)

            n = dgvStepResults.RowCount - 1
            dgvStepResults.Rows(n).Cells("StepNumber").Value = el1.uSequenceNumber
            dgvStepResults.Rows(n).Cells("StartTime").Value = Format(el1.dtStartTime, "HH:mm:ss.f")
            dgvStepResults.Rows(n).Cells("StopTime").Value = Format(el1.dtEndTime, "HH:mm:ss.f")
            dgvStepResults.Rows(n).Cells("StepName").Value = el1.sInstructionName
            dgvStepResults.Rows(n).Cells("Units").Value = el1.sTestUnits
            dgvStepResults.Rows(n).Cells("TestComment").Value = el1.sTestComments
            dgvStepResults.Rows(n).Cells("Results").Value = el1.sResults


            dgvStepResults.Rows(n).Cells("DataLimitLow").Value = el1.fLowerTestLimit.ToString
            dgvStepResults.Rows(n).Cells("DataLimitHigh").Value = el1.fUpperTestLimit.ToString
            dgvStepResults.Rows(n).Cells("Status").Value = el1.sStatus
            If el1.sStatus = "Passed" Then
                dgvStepResults.Rows(n).Cells("Status").Style.ForeColor = Color.Blue
            Else
                dgvStepResults.Rows(n).Cells("Status").Style.ForeColor = Color.Red
            End If

            dgvStepResults.Rows(n).Cells("CallingFunction").Value = el1.strCallingFunction

            'dgvStepResults.Rows(n).Cells("CallingFunction").Value = el1.strCallingFunction  - NEED TO ADD THIS TO DEBUG XML

            If el1.lstTestResultParameters.Count > 0 Then
                dgvStepResults.Rows(n).Cells("ParameterKey").Value = el1.lstTestResultParameters(0).sParameter_Key
                dgvStepResults.Rows(n).Cells("ParameterValue").Value = el1.lstTestResultParameters(0).sParameter_Value
                dgvStepResults.Rows(n).Cells("ParameterUnits").Value = el1.lstTestResultParameters(0).sParameter_Unit
            End If

            'Inner Loop
            j = 0
            For Each el2 In el1.lstCommunication
                dgvAteOpData.Rows.Add(1)
                i = dgvAteOpData.RowCount - 1
                dgvAteOpData.Rows(i).Cells("Time").Value = Format(el2.dtTime, "HH:mm:ss.f")
                dgvAteOpData.Rows(i).Cells("StepNumber").Value = n & "." & j


                Select Case el2.eTXRX

                    Case 0
                        ' TX
                        dgvAteOpData.Rows(i).Cells("Send").Value = el2.sCommText

                    Case 1
                        ' RX
                        dgvAteOpData.Rows(i).Cells("Receive").Value = el2.sCommText

                    Case 2
                        ' COMMENT
                        dgvAteOpData.Rows(i).Cells("Comment").Value = el2.sCommText

                    Case Else
                        ' no data so do nothing

                End Select

                dgvAteOpData.AutoResizeRow(i)

                dgvAteOpData.FirstDisplayedScrollingRowIndex = dgvAteOpData.Rows.Count - 1

                Me.UpdateDispaly()

                j = j + 1

            Next

            dgvStepResults.AutoResizeRow(n)

            dgvStepResults.FirstDisplayedScrollingRowIndex = dgvStepResults.Rows.Count - 1

            Me.UpdateDispaly()

        Next



        ' Enable the button
        btn_LoadXMLReport.Enabled = True

        ' Change the button to - Load XML test report
        btn_LoadXMLReport.Text = "Load XML test report"



    End Sub

End Class