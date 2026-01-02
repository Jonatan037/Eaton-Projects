
'ExecuteTest Class
' Created from Shark_ATE_Rev1.16.001.030_Add ini variable to push to TDM
' 1.16.001.001      J. Parker       04/17/2023     original release
' 1.16.001.002      J. Parker       04/18/2023     fixed logic error and cleanup
' 1.16.001.006      J. Parker       05/04/2023     Changed Employee.xml to EmployeeBatteryLine.xml
' 1.16.001.007      J. Parker       05/08/2023     Adjusted for xml without NameSpace
' 1.16.001.008      J. Parker       05/18/2023     TestSpec and Operator tries to copy for network at the beginning of a new day
' 1.16.001.009      J. Parker       06/20/2023     Added retry to harness check per request
' 1.16.001.010      J. Parker       10/03/2023     Clean up - Serial length test did not have a return
' 1.16.001.011      J. Parker       10/12/2023     Fixed retry error message
' 1.16.001.012      J. Parker       10/12/2023     Handle communication loss with meter, Add Upper and lower limits to test report
' 1.100.001.014     J. Arias        10/30/2025     Fixed retry loop bug - operator clicking "No" now properly exits retry loop
' Notes:
'  Certificate password is admin

Imports System
Imports System.IO
Imports System.Text
Imports vb = Microsoft.VisualBasic
Imports System.Net.NetworkInformation
Imports System.IO.IsolatedStorage


Module ExecuteTest

    Public UUT As New UUT_Class

    Public myTestData As TestDataset

    Public TestSystem As New TestSystem_Class

    ''' <summary>
    ''' store the Pass or Fail result
    ''' </summary>
    Public TestItem, MeasurementValue, Judgement As String
    ''' <summary>
    ''' store the current row index in the list box of maintestinterface
    ''' </summary>
    Public TestItemIndex As Integer
    ''' <summary>
    ''' Indicate the current test item
    ''' </summary>
    Public MainTestSequence As String
    Public SequencetestResult As Boolean
    Public LastSendCommand As String
    Public LastReadCommand As String


    Private Function GetTickCount() As Double

        GetTickCount = vb.Timer * 1000

    End Function


    Public Sub SlowDown(ByVal MilliSeconds As Long)
        Dim lngTickStore As Long
        Dim i As Integer

        lngTickStore = GetTickCount()

        Do While lngTickStore + MilliSeconds > GetTickCount()
            i = 2   ' do something
        Loop

    End Sub


    Public Sub Delay(ByRef DelayTime As Object, Optional ByVal sDelayDescription As String = "", Optional ByVal bUpdateTestData As Boolean = True)
        'Delay in seconds

        Dim t1 As Double = 0
        Dim dLastTime As Double = 0
        t1 = vb.Timer

        If bUpdateTestData Then
            myTestData.Step_AddCommunication(Communication.TXRX.COMMENT, "Delay: " & DelayTime & " - " & sDelayDescription)
        End If


        Do While vb.Timer - t1 < DelayTime

            'update display every 0.2 second
            If vb.Timer > dLastTime + 0.2 Then

                dLastTime = vb.Timer
                If bUpdateTestData Then
                    MainTestInterface.lblElapseTime.Text = Format(dLastTime - t1, "0.0")
                End If


            End If

            Application.DoEvents()

        Loop

        If bUpdateTestData Then
            MainTestInterface.lblElapseTime.Text = Format(DelayTime, "0.0")
        End If


    End Sub

    Public Function EndOfTestCleanUP() As Boolean

        Dim ReadSuccess As Boolean = False
        Dim str As String
        Dim strMessage As String
        Dim i As Integer
        Dim UpperLimit, LowerLimit, GangVoltage As Double
        Dim ResetCount As Integer
        Dim SNstring As String


        myTestData.StartStep(TestDataset.STEPNAMES.GenericStep)

        myTestData.Step_AddCommunication(Communication.TXRX.COMMENT, "Start of Function: EndOfTestCleanUP")

        strMessage = "1. Add battery prompt here "

        If MsgBox(strMessage, MsgBoxStyle.YesNo) = 6 Then

            EndOfTestCleanUP = True

            myTestData.StopStep_TextResult("Passed - Battery prompt pass message", TestDataset.PASSED_FAILED.Passed)

        Else

            EndOfTestCleanUP = False

            myTestData.StopStep_TextResult("Failed - Battery prompt failure message", TestDataset.PASSED_FAILED.Failed)

        End If

    End Function



    Public Sub InsertStepCommunication(ByVal eTxRx As Communication.TXRX, ByVal strDescription As String)

        If myTestData.GetnTestStepState <> 0 Then

            'Add communication is step is already open

            myTestData.Step_AddCommunication(eTxRx, strDescription)

        Else
            'if step is not open -> Open step insert communication -> close step
            myTestData.StartStep(TestDataset.STEPNAMES.GenericStep)

            myTestData.Step_SetComment("Step added for communication insert")

            myTestData.Step_AddCommunication(eTxRx, strDescription)

            myTestData.StopStep_TextResult("Communication inserted", TestDataset.PASSED_FAILED.Passed)

        End If

    End Sub



    ' Handle error when your not sure if there is an open step or no
    ' TODO: add optional boolean for FailureAllowed
    ' TODO: Add red test to display
    Public Sub TDMGeneralErrorCatch(ByVal ErrorDescription As String)

        If myTestData.GetnTestStepState <> 0 Then

            'Close currently opened test

            myTestData.Step_SetComment("Unknown Error: " & ErrorDescription)

            myTestData.Step_AddCommunication(Communication.TXRX.COMMENT, "Unknown Error: " & ErrorDescription)

            'Add function to close and start test

        End If

        myTestData.StartStep(TestDataset.STEPNAMES.GenericStep)

        myTestData.Step_SetComment("Unknown Error: " & ErrorDescription)

        myTestData.Step_AddCommunication(Communication.TXRX.COMMENT, "Unknown Error: " & ErrorDescription)

        myTestData.StopStep_TextResult("Unknown Error", TestDataset.PASSED_FAILED.Failed)


    End Sub

    Private Function checkAccuracy(ByVal SubtraHend As Double, ByVal Minuend As Double, ByVal Tolerance As Double, ByRef returnPercent As String, ByVal PCBID As Integer, ByVal Channel As Integer, Optional ByVal ActualCurrent As Double = 0.0) As Boolean
        If PCBID = "U501" And Channel < 4 Then
            'for ICM3-1 channel 1-3 need to change the tolerance to 1.5%
            If ActualCurrent > 0.8 And ActualCurrent < 1.6 Then

                If checkLimit(SubtraHend, Minuend, 0.012, returnPercent) Then
                    Return True
                End If
            Else
                If checkLimit(SubtraHend, Minuend, Tolerance, returnPercent) Then
                    Return True
                End If
            End If

        Else

            If checkLimit(SubtraHend, Minuend, Tolerance, returnPercent) Then
                Return True
            End If

        End If

    End Function

    Private Function checkLimit(ByVal SubtraHend As Double, ByVal Minuend As Double, ByVal Tolerance As Double, ByRef returnPercent As String) As Boolean

        If SubtraHend = 0 Then

            Return False
        End If

        returnPercent = (CStr((Math.Abs((SubtraHend - Minuend) / SubtraHend)) * 100)) & "%"

        If Math.Abs((SubtraHend - Minuend) / SubtraHend) <= Tolerance Then

            Return True

        Else

            Return False

        End If

    End Function



    ' reports the two values without any comparison
    Private Function Accuracy_Report(ByVal sHidPath As String, ByVal fActual As Double, ByVal fPduMeas As Double)

        Accuracy_Report = True

    End Function


    ' checks the two values and outputs the deviation, no pass/fail output
    Private Function Accuracy_ReportPassNoFail(ByVal sHidPath As String, ByVal fActual As Double, ByVal fPduMeas As Double, ByVal fTolerance As Double) As Boolean
        Dim f1 As Double

        f1 = (fPduMeas - fActual) / fActual

        If Math.Abs(f1) < fTolerance Then
            MainTestInterface.myReport.Result = "Pass"
            Accuracy_ReportPassNoFail = True
        Else
            Accuracy_ReportPassNoFail = False
        End If

    End Function


    Public Function DeleteAllFiles(FolderPath As String) As Boolean

        ' loop through each file in the target directory
        For Each file_path As String In Directory.GetFiles(FolderPath)

            ' delete the file if possible...otherwise skip it
            Try
                File.Delete(file_path)
            Catch ex As Exception

            End Try

        Next

    End Function

    Public Function CreateFileAndSave(FilePathandName As String, FileContent As String) As Boolean
        Dim filewriter As StreamWriter

        filewriter = New StreamWriter(FilePathandName, False)
        filewriter.WriteLine(FileContent)
        filewriter.Flush()
        filewriter.Close()

    End Function


    Public Function UnixTimeNow() As Long
        Dim _TimeSpan As TimeSpan = DirectCast((DateTime.UtcNow - New DateTime(1970, 1, 1, 0, 0, 0)), TimeSpan)

        Return CLng(_TimeSpan.TotalSeconds)
    End Function

    Public Sub TDMErrorCatch(ByVal ErrorDescription As String, ByVal ex As Exception)

        If myTestData.GetnTestStepState <> 0 Then

            'Close currently opened test

            'This should be a general close function
            If ex.Message.ToString.Length > 1 Then
                myTestData.StopStep_TextResult("Exception Event" & ex.Message.ToString, TestDataset.PASSED_FAILED.Failed)
            Else
                myTestData.StopStep_TextResult("Exception Event", TestDataset.PASSED_FAILED.Failed)
            End If

        End If

        myTestData.StartStep(TestDataset.STEPNAMES.ExceptionOccurred)

        myTestData.Step_SetComment(ErrorDescription & ex.Message.ToString)

        myTestData.StopStep_TextResult("Exception Event", TestDataset.PASSED_FAILED.Failed)

    End Sub


    Public Function VerifyNoDuplicateSerialNumber(ResultName As String, SerialNumber As String) As Boolean

        Dim strMessage As String
        Dim userMsg As String
        Dim sDefaultResponse As String

        VerifyNoDuplicateSerialNumber = False

        myTestData.StartStep(TestDataset.STEPNAMES.VerifyNoDuplicateSN)

        myTestData.Step_AddCommunication(Communication.TXRX.COMMENT, "Start of Function: VerifyNoDuplicateSerialNumber")

        ' Check for serial number variable set in config.ini file
        If TestSystem.CheckDupSerialNumber Then
            ' Duplicate serial number found 
            strMessage = "This Serial number already has a passed test record.  " & vbCrLf &
        "Is there a valid reason for retest/re-using this serial number? " & vbCrLf & vbCrLf &
        "If Yes - You will enter why the serial is being used at the next prompt."

            If TDM_LastTestFailed(UUT.sOverAllResultsName, UUT.sSerialNumber) Then

                'Duplicate serial number not found
                myTestData.StopStep_TextResult("No duplicate serial number", TestDataset.PASSED_FAILED.Passed)

                VerifyNoDuplicateSerialNumber = True

            Else

                ' Display message to continue testing with duplicate serial numbers
                If MsgBox(strMessage, MsgBoxStyle.YesNo) = MsgBoxResult.Yes Then

#If JeffDebug Then
    sDefaultResponse = "I am debugging the test application."
#Else
                    sDefaultResponse = ""
#End If

                    Do
                        userMsg = InputBox("Why is this serial number reused/re-tested (response must be greater than 15 characters)?", "Duplicate Serial", sDefaultResponse)

                        ' Check if user pressed Cancel
                        If userMsg = "" Then
                            UUT.sSerialNumber = UUT.sSerialNumber & "_Dup"
                            myTestData.StopStep_TextResult("Operator cancelled the test during duplicate SN justification.", TestDataset.PASSED_FAILED.Failed)
                            Exit Function
                        End If

                        If userMsg.Length < 15 Then
                            MsgBox("Response must be at least 15 characters. Please try again or press Cancel to abort the test.", MsgBoxStyle.Exclamation)
                        End If

                    Loop While userMsg.Length < 15

                    myTestData.StopStep_TextResult("Reason for retest/re-use of SN: " & userMsg, TestDataset.PASSED_FAILED.Passed)
                    VerifyNoDuplicateSerialNumber = True

                Else
                    'Operator does not want to continue test
                    UUT.sSerialNumber = UUT.sSerialNumber & "_Dup"
                    myTestData.StopStep_TextResult("Duplicate serial number found", TestDataset.PASSED_FAILED.Failed)
                End If

            End If
        Else

            ' CheckDupSerialNumber variable not set true in config.ini so it is not checked here
            myTestData.StopStep_TextResult("Duplicate serial check has been disabled", TestDataset.PASSED_FAILED.Passed)

            VerifyNoDuplicateSerialNumber = True

        End If



    End Function

    Public Function CopyFilesFromTo(sFromLocation As String, sToLocation As String, sFileNameArray() As String) As Boolean


        Try

            CopyFilesFromTo = True

            For Each sFileName In sFileNameArray
                If sFileName.Length > 1 Then


                    My.Computer.FileSystem.CopyFile(
                    sFromLocation & "\" & sFileName,
                    sToLocation & "\" & sFileName,
                     Microsoft.VisualBasic.FileIO.UIOption.OnlyErrorDialogs,
                    Microsoft.VisualBasic.FileIO.UICancelOption.DoNothing)


                End If

            Next

        Catch ex As Exception

            CopyFilesFromTo = False

            MsgBox("Error at CopyFilesFromTo - Unable to update Test specification from the network " & vbCrLf &
                   "  -  The network might be down" & vbCrLf &
                   "  -  Note:  This update is NOT required to continue testing " & ex.Message, MsgBoxStyle.Critical)

        End Try

    End Function

    Public Function VerifyTestHarness(Harness As String, UpperLimit As Double) As Boolean

        Dim strMessage As String
        Dim userResponse As String
        Dim bRetry As Boolean
        Dim sDefaultResponse As String

        VerifyTestHarness = False

        myTestData.StartStep(TestDataset.STEPNAMES.VerifyHarness)

        myTestData.Step_AddCommunication(Communication.TXRX.COMMENT, "Start of Function: VerifyTestHarness")

        ' Set glove and harness prompt based on Voltage upper limit
        If UUT.fUpperLimitVoltage >= 50 Then
            'upper limit >= to 50
            strMessage = "VOLTAGE RATED GLOVES REQUIRED - Pack is over 50Vdc !!!!!!." & vbCrLf &
                "Use Harness: " & UUT.sTestHarness & vbCrLf &
                "Do you have the correct PPE and is the harness in good condition? " & vbCrLf &
                "If the above statement is true - Connect the harness and press YES."
        Else
            'upper limit < 50
            strMessage = "ARC RATED GLOVES REQUIRED - Packs nominal voltage is under 50Vdc." & vbCrLf &
                "Use Harness: " & UUT.sTestHarness & vbCrLf &
                "Do you have the correct PPE and is the harness in good condition? " & vbCrLf &
                "If the above statement is true - Connect the harness and press YES."

        End If

        ' Send prompt to verify gloves and harness
        If MsgBox(strMessage, MsgBoxStyle.YesNo) = 6 Then

            ' Have operator enter the harness number if the part number has changed from the last test
            If UUT.LastPartNumberUsed = UUT.sPartNumber Then

                ' Last part number is the same for this part number - pass test
                myTestData.StopStep_TextResult("Test Prompt", TestDataset.PASSED_FAILED.Passed)

                VerifyTestHarness = True

            Else

                ' Add retry for harness
                Do

                    'Get harness
#If JeffDebug Then  'Jeff Debug stuff  Project -> Compile -> Advance -> Custom Constants

                    sDefaultResponse = "TEST"
#Else
                    sDefaultResponse = ""

#End If
                    userResponse = InputBox("Enter the battery test harness", "Harness Type", sDefaultResponse)

                    If userResponse = UUT.sTestHarness Then

                        UUT.LastPartNumberUsed = UUT.sPartNumber

                        'harness is within limits - No need to retry
                        bRetry = False

                        VerifyTestHarness = True

                    Else

                        If MsgBox("The harness is incorrect - Retry??" & vbCrLf & "Harness Entered: " & userResponse & "  Harness Required: " & UUT.sTestHarness, MsgBoxStyle.YesNo) = MsgBoxResult.Yes Then

                            'Operator choose not to retry
                            bRetry = True

                        End If

                    End If

                Loop While (bRetry = True)

                If VerifyTestHarness Then
                    ' Passed
                    myTestData.StopStep_TextResult("Prompt and harness is good - Harness: " & UUT.sTestHarness, TestDataset.PASSED_FAILED.Passed)

                Else
                    ' Failed
                    myTestData.StopStep_TextResult("Incorrect harness: Required: " & UUT.sTestHarness & ", Entered: " & userResponse, TestDataset.PASSED_FAILED.Failed)

                End If

            End If

        Else

            myTestData.StopStep_TextResult("Operator pressed no at glove prompt", TestDataset.PASSED_FAILED.Failed)

        End If

    End Function


    Public Function VerifyPreflight(DataConnection As String) As Boolean

        Dim strMessage As String
        Dim userResponse As String
        Dim sIssue As String

        VerifyPreflight = False

        ' Test if this is the second run and Preflight checklist flag is set
        If UUT.EnumberRunCount = 2 And TestSystem.bVerifyPreFlightCheckList = True Then
            myTestData.StartStep(TestDataset.STEPNAMES.VerifyPreflight)

            myTestData.Step_AddCommunication(Communication.TXRX.COMMENT, "Start of Function: VerifyPreflight")

            If PullPreflightRecord(TestSystem.sPreFlightDBConnection, UUT.sOperatorEnumber, "YPO Battery Line", sIssue) Then

                ' Test passed
                myTestData.StopStep_TextResult("Preflight checklist has been completed ", TestDataset.PASSED_FAILED.Passed)

                VerifyPreflight = True

            Else

                ' Was unable to verify preflight checklist
                myTestData.StopStep_TextResult("No preflightChecklist: Issue-> " & sIssue, TestDataset.PASSED_FAILED.Failed)

            End If
        Else
            'Test not required - set true
            VerifyPreflight = True
        End If

    End Function

    Public Function SystemSetup() As Boolean

        Dim sErrorResponse As String
        Dim sError As String
        Dim sTestFunction As String
        Dim strMessage As String
        Dim ScriptVersion As String
        Dim sMeterDetails As String


        SystemSetup = True

        '' Record test details, Rev and PC Name
        ScriptVersion = My.Application.Info.Version.ToString

        myTestData.StartStep(myTestData.STEPNAMES.TestSystemDetails)

        myTestData.Step_AddCommunication(Communication.TXRX.COMMENT, "Start of Function: SystemSetup")

        ' Read meter information
        Read8846A_Generic("*IDN?", sMeterDetails)

        ' Populate test step
        If SystemSetup Then

            ' pass test
            myTestData.StopStep_TextResult("PC Name: " & Environment.MachineName & vbCrLf & "Script Version: " & ScriptVersion & vbCrLf &
                   "Meter Details: " & sMeterDetails, myTestData.PASSED_FAILED.Passed)

        Else

            myTestData.StopStep_TextResult("PC Name: " & Environment.MachineName & vbCrLf & "Script Version: " & ScriptVersion & vbCrLf &
                   "Meter Details: " & sMeterDetails, myTestData.PASSED_FAILED.Failed)

        End If

    End Function

    Public Function CheckDCVoltageLevel(LowerLimit As Double, UpperLimit As Double, AllowRetry As Boolean) As Boolean

        Dim strMessage As String
        Dim userResponse As String
        Dim MeasuredValue As Double
        Dim bRetry As Boolean


        CheckDCVoltageLevel = False

        myTestData.StartStep(TestDataset.STEPNAMES.DCVoltageTest)

        myTestData.Step_AddCommunication(Communication.TXRX.COMMENT, "Start of Function: CheckDCVoltageLevel")

        'Retry
        bRetry = False

        'Retry measured 
        strMessage = "Step failed - Would you like to retry? " & vbCrLf & vbCrLf _
            & "Measured value:  " & MeasuredValue & " Limits: " & LowerLimit & " -> " & UpperLimit


        Do

            'Read DC voltage from Fluke 8846A
            MeasuredValue = Read8846A(UUT.fUpperLimitVoltage)

            If ((MeasuredValue >= LowerLimit) And (MeasuredValue <= UpperLimit)) Then

                'measurement is within limits - No need to retry
                bRetry = False

            Else

                'Retry measured 
                strMessage = "Step failed - Would you like to retry? " & vbCrLf & vbCrLf _
                        & "Measured value:  " & MeasuredValue & " Limits: " & LowerLimit & " -> " & UpperLimit

                If MsgBox(strMessage, MsgBoxStyle.YesNo) = MsgBoxResult.Yes Then

                    'Operator choose to retry
                    bRetry = True

                Else

                    'Operator choose not to retry
                    bRetry = False

                End If

            End If

        Loop While (bRetry = True)


        ' Add battery voltage check
        If ((MeasuredValue >= LowerLimit) And (MeasuredValue <= UpperLimit)) Then

            'myTestData.StopStep_TextResult("V(Battery) in limits: Measured: " & MeasuredValue & " LowerLimit: " & LowerLimit & " UpperLimit: " & UpperLimit, TestDataset.PASSED_FAILED.Passed)
            myTestData.StopStep_InLimit(MeasuredValue, TestDataset.PASSED_FAILED.Passed, UUT.fLowerLimitVoltage, UUT.fUpperLimitVoltage, MeasuredValue, "V(DC)")

            CheckDCVoltageLevel = True

        Else

            'myTestData.StopStep_TextResult("V(Battery) out of limits: Measured: " & MeasuredValue & " LowerLimit: " & LowerLimit & " UpperLimit: " & UpperLimit, TestDataset.PASSED_FAILED.Failed)
            myTestData.StopStep_InLimit(MeasuredValue, TestDataset.PASSED_FAILED.Failed, UUT.fLowerLimitVoltage, UUT.fUpperLimitVoltage, MeasuredValue, "V(DC)")

        End If

    End Function

    Public Function BatteryTestSequence() As Boolean

        BatteryTestSequence = True

        Try


            ' Record test system details and Enumber Count
            If Not SystemSetup() Then

                Return False

            End If

            ' Verify this will not cause a duplicate serial number. If it will, Set failure to SN_Dup
            If Not VerifyNoDuplicateSerialNumber(UUT.sOverAllResultsName, UUT.sSerialNumber) Then

                Return False

            End If

            ' On Second test for enumber - verify a prefligt check has been completed if the flag is set
            If Not VerifyPreFlight(UUT.sTestHarness) Then

                Return False

            End If


            ' Verify harness and glove type used for hook up
            If Not VerifyTestHarness(UUT.sTestHarness, UUT.fUpperLimitVoltage) Then

                Return False

            End If

            ' Check voltage LowerLimit, UpperLimit, AllowRetry
            If Not CheckDCVoltageLevel(UUT.fLowerLimitVoltage, UUT.fUpperLimitVoltage, True) Then

                Return False

            End If

            Return True

        Catch ex As Exception

            TDMErrorCatch("BatteryTestSequence_Exception: ", ex)

        Finally

        End Try

    End Function


End Module
