' Battery Test Data Management - Data Handling Class
' Written by J. Parker
' 
' Revision History:
' ------------------------------------------------------------
' Revision History 
' Author        Date            Notes
' ________________________________________________________________________________
' J. Parker     Apr 04, 2022    Initial release

Imports System.Xml
Imports System.IO
Imports System.Text
Imports System.Collections
Imports System.Collections.Generic
Imports System.Threading
Imports System.Text.RegularExpressions
Imports Microsoft.Office.Interop
Imports System.Data.SqlClient
Imports System.Configuration


' definition of TestResultParameter which is just a data structure
Public Class TestResultParameter
    Public sParameter_Key As String
    Public sParameter_Value As String
    Public sParameter_Unit As String
End Class

' definition of Communication which is just a data structure
Public Class Communication
    Public Enum TXRX
        TX
        RX
        COMMENT
    End Enum

    Public eTXRX As TXRX
    Public sCommText As String
    Public dtTime As Date
End Class


' definition of TestDataItem which is just a data structure
Public Class TestDataItem
    Public sSerialNumber As String
    Public uSequenceNumber As UInteger
    Public sInstructionName As String
    Public fUpperTestLimit As Double
    Public fLowerTestLimit As Double
    Public fUpperControlLimit As Double
    Public fLowerControlLimit As Double
    Public sTestComments As String
    Public sTestUnits As String
    Public sResults As String
    Public sStatus As String    ' must be Passed or Failed
    Public dtStartTime As Date
    Public dtEndTime As Date
    Public strCallingFunction As String
    Public lstTestResultParameters As List(Of TestResultParameter)
    Public lstCommunication As List(Of Communication)
    Public nStepDataType As Integer  'Used to 

    Public Sub New()
        lstTestResultParameters = New List(Of TestResultParameter)
        lstCommunication = New List(Of Communication)
        sTestUnits = ""
        sTestComments = ""
    End Sub
End Class


' definition of a full set of data for one test
Public Class TestDataset
    Public Enum LINENAME
        ePDU_G3HD
        ePDU_G3
    End Enum

    Public Enum TESTTYPE
        PDU
        MODULEO
        MODULEI
        PCBA
    End Enum

    Public Enum PASSED_FAILED
        Passed
        Failed
    End Enum

    Public Enum UNITS_MEASURE   ' make all of them five characters
        Watts
        Amps_
        Volts
        Hertz
        Count
    End Enum

    Public Enum STEPNAMES
        TestSystemDetails
        TestVoltage
        MeasurementAccuracy
        GenericStep
        InputHarness
        ScriptVersion
        ScriptName
        ExceptionOccurred
        FunctionException
        PCName
        VerifyNoDuplicateSN
        VerifyHarness
        VerifyPreflight
        DCVoltageTest
    End Enum

    Public Enum STEPDETAIL
        ADDR
        OUTL
        BRCH
        PHAS
        INDX
        GANG
        MODL
    End Enum

    Public Enum MEASACCURACYCLASS
        Class_20A
        Class_10A
        Class_35A
        Class_64A
        Not_Applicable
    End Enum


    Public dtStartTime As Date
    Public dtStopTime As Date
    Public lstTestDataItem As List(Of TestDataItem)
    Public nTestState As Integer      ' 0= Test not started, 1=Test is started, 2=Test is finished
    Public Event UpdateGuiStep(ByVal nStepIdx As Integer, ByVal bStepComplete As Boolean)
    Public Event UpdateGuiStepComm(ByVal nStepIdx As Integer, ByVal nCommIdx As Integer)
    Private nTestStepState As Integer   ' 0=step not started, 1=step is started, 2=step is finished
    Private nDataType As Integer   ' 0=step not started, 1=step is started, 2=step is finished
    Private nAteOp_State As Integer
    Private FinalStatus_Passed As Boolean
    Private FailedTestStep As String


    ' Create a new instance by reading a TDM XML file
    Public Sub New(ByVal sFileName As String)
        lstTestDataItem = New List(Of TestDataItem)
        nTestStepState = 0
        dtStartTime = Now
        ReadFromXML(sFileName)
    End Sub

    ' Create a new instance by defining the basic test items
    Public Sub New()
        lstTestDataItem = New List(Of TestDataItem)
        nTestStepState = 0
        dtStartTime = Now
        nTestState = 1
        MainTestInterface.LblStartTestTime.Text = Format(Me.dtStartTime, "yyyy-MM-dd \ HH:mm:ss.ff")
        FinalStatus_Passed = True
        FailedTestStep = ""

    End Sub

    Public Function GetnDataType() As Integer
        GetnDataType = nDataType
    End Function

    Public Function GetnTestStepState() As Integer
        GetnTestStepState = nTestStepState
    End Function


    Public Sub SetPassedFinalStatus_False(ByVal StepID As String)

        'Keep running history of failed test steps
        If FailedTestStep.Length < 1 Then

            FailedTestStep = StepID

        Else

            FailedTestStep = FailedTestStep & ", " & StepID

        End If

        'PassedFinalStatus is set true when the instance is created
        'PassedFinalStatus can only be set false which is test has failed
        FinalStatus_Passed = False

    End Sub

    Public Function GetFinalStatus_Passed() As Boolean
        GetFinalStatus_Passed = FinalStatus_Passed
    End Function


    Public Function GetString(ByVal eStepName As STEPNAMES) As String
        Dim str As String

        Select Case eStepName
            Case STEPNAMES.TestSystemDetails
                str = "ATE Details"
            Case STEPNAMES.TestVoltage
                str = "ATE Test Voltage"
            Case STEPNAMES.MeasurementAccuracy
                str = "Measurement Accuracy"
            Case STEPNAMES.GenericStep
                str = "Generic Step"
            Case STEPNAMES.InputHarness
                str = "Input Harness verification via harness barcode"
            Case STEPNAMES.ScriptVersion
                str = "ATE Script Version"
            Case STEPNAMES.ScriptName
                str = "ATE Script Name"
            Case STEPNAMES.ExceptionOccurred
                str = "Exception has occurred"
            Case STEPNAMES.FunctionException
                str = "Error event occurred"
            Case STEPNAMES.PCName
                str = "ATE PC Name"
            Case STEPNAMES.VerifyNoDuplicateSN
                str = "Verify no duplicate Serial Number"
            Case STEPNAMES.VerifyHarness
                str = "Verify test harness"
            Case STEPNAMES.VerifyPreflight
                str = "Verify a preflight checklist has been completed"
            Case STEPNAMES.DCVoltageTest
                str = "Battery voltage limit test"
            Case Else
                str = ""
        End Select

        GetString = str

    End Function

    Public Function GetString(ByVal eStepDetail As STEPDETAIL) As String
        Dim str As String

        Select Case eStepDetail
            Case STEPDETAIL.ADDR
                str = "Channel"
            Case STEPDETAIL.BRCH
                str = "Branch"
            Case STEPDETAIL.GANG
                str = "Gang"
            Case STEPDETAIL.INDX
                str = "Index"
            Case STEPDETAIL.OUTL
                str = "Outlet"
            Case STEPDETAIL.PHAS
                str = "Input Phase"
            Case STEPDETAIL.MODL
                str = "Module"
            Case Else
                str = ""
        End Select

        GetString = str
    End Function

    Public Function GetString(ByVal eUnits As UNITS_MEASURE) As String
        Dim str As String

        Select Case eUnits
            Case UNITS_MEASURE.Amps_
                str = "Current"
            Case UNITS_MEASURE.Hertz
                str = "Frequency"
            Case UNITS_MEASURE.Volts
                str = "Voltage"
            Case UNITS_MEASURE.Watts
                str = "Watts"
            Case Else
                str = ""
        End Select

        GetString = str
    End Function

    ' returns: 0=success, -1=failure
    ' ePassedFailed indicates whether the whole test has passed or failed
    Public Function EndTest(ByVal ePassedFailed As PASSED_FAILED) As Integer
        Dim clItem As New TestDataItem

        'Set the overall failure
        'Are we sure we should be using this way to set the last step to failed???
        If ePassedFailed = TestDataset.PASSED_FAILED.Failed Then

            'Set the Final Test step to failed and record line
            SetPassedFinalStatus_False(lstTestDataItem.Count - 1)

        End If

        clItem.uSequenceNumber = lstTestDataItem.Count + 1
        clItem.sInstructionName = "BatteryTest_OverallResult"
        clItem.sSerialNumber = UUT.sSerialNumber
        clItem.sResults = ""
        clItem.sStatus = [Enum].GetName(GetType(PASSED_FAILED), ePassedFailed)
        clItem.dtStartTime = Now
        clItem.dtEndTime = Now

        'set master end time
        dtStopTime = Now
        MainTestInterface.LblEndTestTime.Text = Format(Me.dtStopTime, "yyyy-MM-dd \ HH:mm:ss.ff")
        nTestState = 2

        'Set stepstate = 2 to display the last step
        nTestStepState = 2 ' indicates that testing is finished

        lstTestDataItem.Add(clItem)

        ' update the GUI
        'RaiseEvent UpdateGuiStep(lstTestDataItem.Count - 1, True)
        MainTestInterface.UpdateGuiStep(lstTestDataItem.Count - 1, True)

        nTestStepState = -1 ' indicates that testing is finished

        EndTest = 0

    End Function

    Public Function EndTest() As Integer
        Dim clItem As New TestDataItem

        clItem.uSequenceNumber = lstTestDataItem.Count + 1
        clItem.sInstructionName = UUT.sTestScript & "_OverallResult"
        clItem.sSerialNumber = UUT.sSerialNumber
        clItem.sResults = ""
        If GetFinalStatus_Passed() Then
            clItem.sStatus = [Enum].GetName(GetType(PASSED_FAILED), PASSED_FAILED.Passed)
        Else
            clItem.sStatus = [Enum].GetName(GetType(PASSED_FAILED), PASSED_FAILED.Failed)
        End If

        clItem.dtStartTime = Now
        clItem.dtEndTime = Now

        lstTestDataItem.Add(clItem)

        ' update the GUI
        'RaiseEvent UpdateGuiStep(lstTestDataItem.Count - 1, True)
        MainTestInterface.UpdateGuiStep(lstTestDataItem.Count - 1, True)

        nTestStepState = -1 ' indicates that testing is finished

        EndTest = 0

    End Function

    ' returns: 0=success, -1=failure (step is already started, it must be finished first)
    Public Function StartStep(ByVal eStepName As STEPNAMES) As Integer
        Dim clTestDataItem As New TestDataItem
        Dim strCallFunction As String = ""

        If nTestStepState = 0 Then
            clTestDataItem.uSequenceNumber = lstTestDataItem.Count + 1
            clTestDataItem.sInstructionName = GetString(eStepName)
            clTestDataItem.dtStartTime = Now
            clTestDataItem.sStatus = PASSED_FAILED.Failed.ToString      ' set the default status to Failed, will be updated when the step is ended
            'Only basic data is in step now so set StepDataType to 0
            clTestDataItem.nStepDataType = 0

            ExecuteTest.MainTestSequence = clTestDataItem.sInstructionName

            'Record calling function name - Use for debuggin - Note:  This will only work in the debug release
            clTestDataItem.strCallingFunction = CallingFunctionName()

            lstTestDataItem.Add(clTestDataItem)

            nTestStepState = 1

            'RaiseEvent UpdateGuiStep(lstTestDataItem.Count - 1, False)  'Fix event so reference to external class can be removed
            MainTestInterface.UpdateGuiStep(lstTestDataItem.Count - 1, False)

            StartStep = 0

        Else
            StartStep = -1
        End If

    End Function

    Public Function CallingFunctionName() As String

        Dim strace As New StackTrace
        Dim frame1, frame2, frame3, frame4 As New StackFrame
        Dim method1, method2, method3, method4 As System.Reflection.MethodBase

        frame1 = strace.GetFrame(1) ' Gets the stack frame for the method that called this(one)
        method1 = frame1.GetMethod ' Grab method info

        frame2 = strace.GetFrame(2) 'frame 2
        method2 = frame2.GetMethod

        frame3 = strace.GetFrame(3) 'frame 3
        method3 = frame3.GetMethod

        frame4 = strace.GetFrame(4) 'frame 4
        method4 = frame4.GetMethod


        'strCallFunction = (method.ReflectedType.Namespace & "." & method.ReflectedType.Name & "." & method.Name)
        CallingFunctionName = method4.Name & "->" & method3.Name & "->" & method2.Name

    End Function



    ' returns: 0=success, -1=state failure (step is not started)
    Public Function Step_SetComment(ByVal sComment As String) As Integer
        If lstTestDataItem.Count > 0 Then
            ' set at most 127 characters since the max string length is 128
            lstTestDataItem.Last.sTestComments = Mid(sComment, 1, 127)

            MainTestInterface.UpdateGuiStep_Comment(lstTestDataItem.Count - 1)

            Step_SetComment = 0
        Else
            Step_SetComment = -1
        End If
    End Function

    ' returns: 0=success, -1=state failure(step is not started)
    Public Function Step_AddCommunication(ByVal eTxRx As Communication.TXRX, ByVal sComm As String) As Integer

        'Always add communication step, even if a main step is open - Will add to the last open step
        'If nTestStepState Then

        'Do not add communication details if the test if finished
        If nTestState = 1 Then

            Dim clComm As New Communication

            clComm.eTXRX = eTxRx

            'Remove any invalid xml characters
            sComm = Regex.Replace(sComm, "\x00", "-H00-*")
            sComm = Regex.Replace(sComm, "\x07", "-H07-")
            sComm = Regex.Replace(sComm, "\x09", "-H09-")
            sComm = Regex.Replace(sComm, "\x0A", "-H0A-")
            sComm = Regex.Replace(sComm, "\x0D", "-H0D-")

            If nTestStepState = 0 Then
                'LOS = Last Openned Step
                sComm = sComm & "-LOS"
            End If

            clComm.sCommText = sComm

            clComm.dtTime = Now

            lstTestDataItem.Last.lstCommunication.Add(clComm)

            ' update the GUI
            'RaiseEvent UpdateGuiStepComm(lstTestDataItem.Count - 1, lstTestDataItem.Last.lstCommunication.Count - 1)
            MainTestInterface.UpdateGuiStepComm(lstTestDataItem.Count - 1, lstTestDataItem.Last.lstCommunication.Count - 1)

            Step_AddCommunication = 0
        Else
            Step_AddCommunication = -1
        End If
    End Function




    ' returns: 0=success, -1=failure(step is not started)
    Public Function StopStep_TextResult(ByVal TextResult As String, ByVal ePassedFailed As PASSED_FAILED, Optional ByVal FailureAllowed As Boolean = False) As Integer
        Dim TempStatus As Boolean

        Try

            If nTestStepState Then
                lstTestDataItem.Last.sSerialNumber = UUT.sSerialNumber
                lstTestDataItem.Last.sResults = TextResult
                lstTestDataItem.Last.sStatus = [Enum].GetName(GetType(PASSED_FAILED), ePassedFailed)
                ' If PassFail Then lstTestDataItem.Last.sStatus = "Passed" Else lstTestDataItem.Last.sStatus = "Failed"
                lstTestDataItem.Last.dtEndTime = Now
                lstTestDataItem.Last.nStepDataType = 1

                'Jeff added - Not sure how to handle GUI update if we don't have state 2.  If we have state 2 then we can't use an event handle to the GUI update
                nTestStepState = 2
                nDataType = 1

                If ePassedFailed = TestDataset.PASSED_FAILED.Failed And FailureAllowed = False Then

                    'Set the Final Test step to failed and record line
                    SetPassedFinalStatus_False(lstTestDataItem.Count - 1)

                End If

                'RaiseEvent UpdateGuiStep(lstTestDataItem.Count - 1, True)
                MainTestInterface.UpdateGuiStep(lstTestDataItem.Count - 1, True)

                nTestStepState = 0  ' reset the state machine

                StopStep_TextResult = 0

            Else
                StopStep_TextResult = -1
            End If

        Catch ex As Exception

            'Send error data to test report
            TDMErrorCatch("Error at StopStep_TextResult: ", ex)

            StopStep_TextResult = -1

        End Try

    End Function


    ' returns: 0=success, -1=failure(step is not started)
    Public Function StopStep_InLimit(ByVal TextResult As String, ByVal ePassedFailed As PASSED_FAILED, ByVal fLowerLimit As Double, ByVal fUpperLimit As Double, ByVal fMeasuredValue As Double, ByVal sUnit As String) As Integer
        Dim TempStatus As Boolean
        Dim clParameter As New TestResultParameter

        Try

            If nTestStepState Then
                lstTestDataItem.Last.sSerialNumber = UUT.sSerialNumber
                lstTestDataItem.Last.sResults = TextResult
                lstTestDataItem.Last.sStatus = [Enum].GetName(GetType(PASSED_FAILED), ePassedFailed)
                ' If PassFail Then lstTestDataItem.Last.sStatus = "Passed" Else lstTestDataItem.Last.sStatus = "Failed"
                lstTestDataItem.Last.dtEndTime = Now
                lstTestDataItem.Last.nStepDataType = 4
                lstTestDataItem.Last.fLowerTestLimit = fLowerLimit
                lstTestDataItem.Last.fUpperTestLimit = fUpperLimit
                lstTestDataItem.Last.sTestUnits = sUnit

                clParameter.sParameter_Unit = sUnit
                clParameter.sParameter_Value = RoundNum(fMeasuredValue)
                lstTestDataItem.Last.lstTestResultParameters.Add(clParameter)


                'Jeff added - Not sure how to handle GUI update if we don't have state 2.  If we have state 2 then we can't use an event handle to the GUI update
                nTestStepState = 2
                nDataType = 4

                If ePassedFailed = TestDataset.PASSED_FAILED.Failed Then

                    'Set the Final Test step to failed and record line
                    SetPassedFinalStatus_False(lstTestDataItem.Count - 1)

                End If

                'RaiseEvent UpdateGuiStep(lstTestDataItem.Count - 1, True)
                MainTestInterface.UpdateGuiStep(lstTestDataItem.Count - 1, True)

                nTestStepState = 0  ' reset the state machine

                StopStep_InLimit = 0

            Else
                StopStep_InLimit = -1
            End If

        Catch ex As Exception

            'Send error data to test report
            TDMErrorCatch("Error at StopStep_InLimit: ", ex)

            StopStep_InLimit = -1

        End Try

    End Function


    ' returns: 0=success, -1=failure(step is not started)
    Public Function StopStep_TextResult(ByVal TextResult As String, ByVal ePassedFailed As PASSED_FAILED, ByVal eStepDetail As STEPDETAIL, ByVal nDetailIndex As Integer, Optional ByVal FailureAllowed As Boolean = False) As Integer

        Try

            If nTestStepState Then
                lstTestDataItem.Last.sSerialNumber = UUT.sSerialNumber
                lstTestDataItem.Last.sResults = TextResult
                lstTestDataItem.Last.sStatus = [Enum].GetName(GetType(PASSED_FAILED), ePassedFailed)
                lstTestDataItem.Last.sTestUnits = [Enum].GetName(GetType(UNITS_MEASURE), UNITS_MEASURE.Count) & "_____" & [Enum].GetName(GetType(STEPDETAIL), eStepDetail) & "-" & Format(nDetailIndex, "000")
                lstTestDataItem.Last.dtEndTime = Now

                lstTestDataItem.Last.nStepDataType = 2

                'Jeff added - Not sure how to handle GUI update if we don't have state 2.  If we have state 2 then we can't use an event handle to the GUI update
                nTestStepState = 2

                'Set the Final Test step to failed and record line
                If ePassedFailed = TestDataset.PASSED_FAILED.Failed And FailureAllowed = False Then
                    SetPassedFinalStatus_False(lstTestDataItem.Count - 1)
                End If

                'RaiseEvent UpdateGuiStep(lstTestDataItem.Count - 1, True)
                MainTestInterface.UpdateGuiStep(lstTestDataItem.Count - 1, True)

                nTestStepState = 0  ' reset the state machine

                StopStep_TextResult = 0

            Else
                StopStep_TextResult = -1
            End If

        Catch ex As Exception

            'Send error data to test report
            TDMErrorCatch("Error at StopStep_TextResult: ", ex)

            StopStep_TextResult = -1

        End Try

    End Function


    Private Function RoundNum(ByVal fNumber As Double) As Double
        Dim fResult As Double

        If fNumber < 20 Then     ' primarily current
            fResult = Math.Round(fNumber, 3)
        ElseIf fNumber < 500 Then    ' primarily voltage, and sometimes power
            fResult = Math.Round(fNumber, 2)
        Else
            fResult = Math.Round(fNumber, 1)
        End If

        RoundNum = fResult
    End Function



    ' sFileName is the file to write to, and bIncludeComm indicates whether to include all logged communication in the XML file
    ' Note that XML without communication log should be used for loading to TDM, but a second XML file including the logged
    ' communication data can also be outputted to a file server in case detailed troubleshooting is needed later (it can also be
    ' opened by this class).
    ' Returns a string containing the XML buffer.
    Public Function WriteToXML(ByRef sFileName As String, Optional ByVal bIncludeComm As Boolean = False) As String
        Dim sFullPath As String

        Try
            If bIncludeComm Then
                'Store Debug file: If network drive exist store there - else store localy
                If Directory.Exists(TestSystem.sXMLDebugPath) Then
                    sFullPath = TestSystem.sXMLDebugPath & sFileName & "_Debug.xml"
                Else
                    sFullPath = Environment.CurrentDirectory & "\Debug_xml\" & sFileName & "_Debug.xml"
                End If
            Else
                sFullPath = Environment.CurrentDirectory & "\Pending\" & sFileName & ".xml"
            End If

            Dim file As New StreamWriter(sFullPath)
            Dim sBuf As String

            sBuf = WriteToXMLBuffer(bIncludeComm)
            If sBuf <> "" Then
                file.Write(sBuf)
            End If

            WriteToXML = sBuf
            file.Close()

        Catch ex As Exception
            MsgBox("TestData Class: " & ex.Message, MsgBoxStyle.Exclamation, "Error Outputting XML to File")
            WriteToXML = ""
        End Try

    End Function


    Private Sub releaseObject(ByVal obj As Object)
        Try
            System.Runtime.InteropServices.Marshal.ReleaseComObject(obj)
            obj = Nothing
        Catch ex As Exception
            obj = Nothing
        Finally
            GC.Collect()
        End Try
    End Sub

    Public Function WriteToXMLBuffer(ByVal bIncludeComm As Boolean) As String
        Dim xdoc As XDocument = New XDocument(New XDeclaration("1.0", " utf-8", "yes"))
        ' Dim xmlTree As New XElement("TDM_TestResults", New XAttribute("xmlns:xsi", " http://www.w3.org/2001/XMLSchema-instance"), New XAttribute("xmlns:xsd", "http://www.w3.org/2001/XMLSchema"))
        Dim xmlTree As New XElement("TDM_TestResults")
        Dim elTestResults As New XElement("TestResults")
        Dim el2 As XElement
        Dim el3 As XElement
        Dim el4 As XElement
        Dim clItem As TestDataItem
        Dim clParameter As TestResultParameter
        Dim clComm As Communication
        Dim str As String
        Dim CompleteSequence As Double
        Try

            '    xdoc.Add(xmlTree)
            '    xmlTree.Add(elTestResults)
            xdoc.Add(elTestResults)

            For Each clItem In lstTestDataItem
                el2 = New XElement("TestResult")
                el2.Add(New XElement("LineName", TestSystem.sLineName))
                el2.Add(New XElement("ParentWorkStation", TestSystem.sParentWorkStation))
                el2.Add(New XElement("WorkstationName", TestSystem.sWorkstationName))
                el2.Add(New XElement("ShiftName", UUT.sShiftName))
                el2.Add(New XElement("OperatorName", UUT.sOperatorEnumber))
                el2.Add(New XElement("TestSequenceName", UUT.sTestScript))
                el2.Add(New XElement("CatalogNumber", UUT.sPartNumber))

                el2.Add(New XElement("StartTime", Format(Me.dtStartTime, "yyyy-MM-dd\THH:mm:ss.ff")))
                el2.Add(New XElement("EndTime", Format(clItem.dtEndTime, "yyyy-MM-dd\THH:mm:ss.ff")))

                el2.Add(New XElement("SerialNumber", UUT.sSerialNumber))
                el2.Add(New XElement("SequenceNumber", clItem.uSequenceNumber))
                el2.Add(New XElement("InstructionName", clItem.sInstructionName))

                el2.Add(New XElement("Results", clItem.sResults))
                el2.Add(New XElement("UpperTestLimit", clItem.fUpperTestLimit))
                el2.Add(New XElement("LowerTestLimit", clItem.fLowerTestLimit))
                el2.Add(New XElement("UpperControlLimit", clItem.fUpperControlLimit))
                el2.Add(New XElement("LowerControlLimit", clItem.fLowerControlLimit))
                el2.Add(New XElement("TestUnits", clItem.sTestUnits))
                'Calling function used for debugging
                If bIncludeComm Then
                    el2.Add(New XElement("CallingFunction", clItem.strCallingFunction))
                End If


                el3 = New XElement("Parameters")
                ' take care of any parameters that are a part of the step
                If clItem.lstTestResultParameters.Count > 0 Then
                    For Each clParameter In clItem.lstTestResultParameters
                        el4 = New XElement("TestResultParameter")
                        el4.Add(New XElement("Parameter_Key", clParameter.sParameter_Key))
                        el4.Add(New XElement("Parameter_Value", clParameter.sParameter_Value))
                        el4.Add(New XElement("Parameter_Unit", clParameter.sParameter_Unit))

                        el3.Add(el4)
                    Next
                End If

                ' only add the Parameters element to the structure if it has some content
                If el3.HasElements Then
                    el2.Add(el3)
                End If

                ' only output the communication details if it has been requested
                If bIncludeComm And clItem.lstCommunication.Count > 0 Then
                    el3 = New XElement("StepCommunication")

                    For Each clComm In clItem.lstCommunication
                        el4 = New XElement("Comm")
                        CompleteSequence = clItem.uSequenceNumber + (clItem.lstCommunication.IndexOf(clComm)) / 1000
                        'el4.Add(New XElement("Seq", clItem.lstCommunication.IndexOf(clComm) + 1))
                        el4.Add(New XElement("Seq", CompleteSequence))
                        If clComm.eTXRX = Communication.TXRX.COMMENT Then
                            el4.Add(New XElement("Type", "CM"))
                        Else
                            el4.Add(New XElement("Type", clComm.eTXRX.ToString))
                        End If
                        el4.Add(New XElement("Text", clComm.sCommText))
                        el4.Add(New XElement("Time", Format(clComm.dtTime, "yyyy-MM-dd\THH:mm:ss.ff")))

                        el3.Add(el4)
                    Next

                    el2.Add(el3)
                End If

                el2.Add(New XElement("TestComments", clItem.sTestComments))
                el2.Add(New XElement("Status", clItem.sStatus))

                elTestResults.Add(el2)
            Next

            WriteToXMLBuffer = "<?xml version=" & Chr(34) & "1.0" & Chr(34) & " encoding=" & Chr(34) & "utf-8" & Chr(34) & "?>" & vbCrLf
            WriteToXMLBuffer = WriteToXMLBuffer & "<TDM_TestResults xmlns:xsi=" & Chr(34) & "http://www.w3.org/2001/XMLSchema-instance" & Chr(34) & " xmlns:xsd=" & Chr(34) & "http://www.w3.org/2001/XMLSchema" & Chr(34) & ">" & vbCrLf

            'remove invalid characters - there may be more?
            'WriteToXMLBuffer = WriteToXMLBuffer & xdoc.ToString.Replace("\a", "*")
            WriteToXMLBuffer = WriteToXMLBuffer & xdoc.ToString
            WriteToXMLBuffer = WriteToXMLBuffer & vbCrLf & "</TDM_TestResults>"


        Catch ex As Exception
            MsgBox("TestData Class: " & ex.Message, MsgBoxStyle.Exclamation, "Error Outputting XML")
            WriteToXMLBuffer = ""
        End Try

    End Function

    Public Function ReadFromXML(ByRef sBuffer As String) As Boolean
        Dim elTestResults As XElement
        Dim elTestResult As XElement
        Dim elParameter As XElement
        Dim elComm As XElement
        Dim xmlTree As XElement
        Dim clTestItem As TestDataItem
        Dim clParameter As TestResultParameter
        Dim clComm As Communication
        Dim str As String

        Try
            ' set the return value to false in case an error occurs
            ReadFromXML = False

            ' load the XML.  if less than 500 characters it is read as a file, of more than 500 characters it is read as a buffer.
            If sBuffer.Length < 500 Then
                xmlTree = XElement.Load(sBuffer)
            Else
                xmlTree = XElement.Parse(sBuffer)
            End If

            elTestResults = xmlTree.Element("TestResults")

            ' clear out the list of test items in case this class had already been populated with some data
            lstTestDataItem = New List(Of TestDataItem)

            ' start with the first test result and get the data that doesn't repeat
            elTestResult = elTestResults.Element("TestResult")
            Me.dtStartTime = elTestResult.Element("StartTime").Value

            For Each elTestResult In elTestResults.Elements("TestResult")
                clTestItem = New TestDataItem

                clTestItem.sSerialNumber = elTestResult.Element("SerialNumber").Value
                clTestItem.uSequenceNumber = elTestResult.Element("SequenceNumber").Value
                clTestItem.sInstructionName = elTestResult.Element("InstructionName").Value
                clTestItem.fUpperTestLimit = elTestResult.Element("UpperTestLimit").Value
                clTestItem.fLowerTestLimit = elTestResult.Element("LowerTestLimit").Value
                clTestItem.fUpperControlLimit = elTestResult.Element("UpperControlLimit").Value
                clTestItem.fLowerControlLimit = elTestResult.Element("LowerControlLimit").Value
                clTestItem.sTestComments = elTestResult.Element("TestComments").Value
                clTestItem.sTestUnits = elTestResult.Element("TestUnits").Value
                clTestItem.sResults = elTestResult.Element("Results").Value
                clTestItem.sStatus = elTestResult.Element("Status").Value
                clTestItem.dtStartTime = elTestResult.Element("StartTime").Value
                clTestItem.dtEndTime = elTestResult.Element("EndTime").Value
                'CallingFunction is only in the debug file
                If elTestResult.Elements("CallingFunction").Count > 0 Then
                    clTestItem.strCallingFunction = elTestResult.Element("CallingFunction").Value
                End If

                If elTestResult.Elements("Parameters").Count > 0 Then
                    For Each elParameter In elTestResult.Element("Parameters").Elements("TestResultParameter")
                        clParameter = New TestResultParameter

                        clParameter.sParameter_Key = elParameter.Element("Parameter_Key").Value
                        clParameter.sParameter_Value = elParameter.Element("Parameter_Value").Value
                        clParameter.sParameter_Unit = elParameter.Element("Parameter_Unit").Value

                        ' if this parameter is a communication log item, then put it into the communication log
                        If clParameter.sParameter_Key = "COMMUNICATION_LOG" Then
                            clComm = New Communication

                            clComm.dtTime = Mid(clParameter.sParameter_Value, 5, 22)
                            str = Mid(clParameter.sParameter_Value, 28, 2)
                            Select Case str
                                Case "TX"
                                    clComm.eTXRX = Communication.TXRX.TX
                                Case "RX"
                                    clComm.eTXRX = Communication.TXRX.RX
                                Case Else
                                    clComm.eTXRX = Communication.TXRX.COMMENT
                            End Select
                            clComm.sCommText = Mid(clParameter.sParameter_Value, 33)

                            clTestItem.lstCommunication.Add(clComm)

                            ' otherwise put it into the parameter list
                        Else
                            clTestItem.lstTestResultParameters.Add(clParameter)
                        End If

                    Next
                End If

                ' if communication log items weren't already added through the parameters list, then parse any that we can find here
                If elTestResult.Elements("StepCommunication").Count > 0 Then
                    If clTestItem.lstCommunication.Count = 0 Then
                        For Each elComm In elTestResult.Element("StepCommunication").Elements("Comm")
                            clComm = New Communication

                            clComm.dtTime = elComm.Element("Time").Value
                            clComm.sCommText = elComm.Element("Text").Value
                            Select Case elComm.Element("Type").Value
                                Case "TX"
                                    clComm.eTXRX = Communication.TXRX.TX
                                Case "RX"
                                    clComm.eTXRX = Communication.TXRX.RX
                                Case Else
                                    clComm.eTXRX = Communication.TXRX.COMMENT
                            End Select

                            clTestItem.lstCommunication.Add(clComm)
                        Next
                    End If

                End If

                lstTestDataItem.Add(clTestItem)
            Next

            ReadFromXML = True

        Catch ex As Exception

            '            TDMGeneralErrorCatch( ex.Message.ToString
            If elTestResults Is Nothing Then
                MsgBox("TestData Class: " & ex.Message, MsgBoxStyle.Exclamation, "Error Loading TDM XML File")
            Else
                MsgBox("TestData Class: " & ex.Message, MsgBoxStyle.Exclamation, "Error Loading TDM XML File")
            End If

        End Try

    End Function

    Function SubmitXMLData(ByVal working_folder As String, ByVal pending_folder As String) As Boolean

        Dim PendingFilePath As String
        PendingFilePath = working_folder & "\" & pending_folder

        Dim Directory As New IO.DirectoryInfo(PendingFilePath)

        'Creates the array in reverse so a damaged file is sent last
        Dim allFiles As IO.FileInfo() = Directory.GetFiles("*.xml")
        Dim singleFile As IO.FileInfo

        SubmitXMLData = True

        For Each singleFile In allFiles

            'Console.WriteLine(singleFile.FullName)

            If File.Exists(singleFile.FullName) Then

                ' Setup the call to the utility program.
                Dim myProcess As New Process()

                'Need to enclose file names in quotes.
                myProcess.StartInfo.FileName = Chr(34) & working_folder & "\TDM\UploadXmlTestResults.exe" & Chr(34)
                myProcess.StartInfo.Arguments = Chr(34) & singleFile.FullName & Chr(34)

                myProcess.StartInfo.UseShellExecute = False
                myProcess.StartInfo.CreateNoWindow = True
                myProcess.StartInfo.RedirectStandardInput = True
                myProcess.StartInfo.RedirectStandardOutput = True
                myProcess.StartInfo.RedirectStandardError = True
                myProcess.Start()

                Dim output As String = myProcess.StandardOutput.ReadToEnd()

                myProcess.Close()

                'MsgBox(output, , "XML")

                'If no error delete, if error stop 
                If output = "" Then

                    'TODO - delete file in output is good - may not be about to do this in the for loop
                    My.Computer.FileSystem.DeleteFile(singleFile.FullName)

                Else

                    SubmitXMLData = False

                    Exit For

                End If

            End If

        Next

    End Function

    ' Save test results to SQL database
    ' Returns: 0=success, -1=failure
    Public Function SaveToSQL() As Integer
        Try
            Dim connectionString As String = ConfigurationManager.ConnectionStrings("BatteryConnectionString").ConnectionString

            ' Check if connection string is properly configured
            If String.IsNullOrEmpty(connectionString) OrElse connectionString.Contains("usyouwhp6205605\SQLEXPRESS") = False Then
                ' SQL not configured, skip silently to maintain backward compatibility
                Return 0
            End If

            Using connection As New SqlConnection(connectionString)
                connection.Open()

                ' Calculate overall test results
                Dim overallStatus As String = If(GetFinalStatus_Passed(), "Passed", "Failed")
                Dim testDurationMinutes As Integer = Convert.ToInt32(DateDiff(DateInterval.Minute, Me.dtStartTime, Me.dtStopTime))

                ' First, insert the overall test result to get TestID
                Dim testID As Long
                Using overallCmd As New SqlCommand("INSERT INTO dbo.OverallResults " &
                    "(LineName, ParentWorkStation, WorkstationName, ShiftName, OperatorName, " &
                    "TestSequenceName, CatalogNumber, TestStartTime, TestEndTime, SerialNumber, " &
                    "OverallStatus, TestComments, TestDurationMinutes, CreatedBy) " &
                    "OUTPUT INSERTED.TestID VALUES " &
                    "(@LineName, @ParentWorkStation, @WorkstationName, @ShiftName, @OperatorName, " &
                    "@TestSequenceName, @CatalogNumber, @TestStartTime, @TestEndTime, @SerialNumber, " &
                    "@OverallStatus, @TestComments, @TestDurationMinutes, @CreatedBy)", connection)

                    overallCmd.Parameters.AddWithValue("@LineName", TestSystem.sLineName)
                    overallCmd.Parameters.AddWithValue("@ParentWorkStation", TestSystem.sParentWorkStation)
                    overallCmd.Parameters.AddWithValue("@WorkstationName", TestSystem.sWorkstationName)
                    overallCmd.Parameters.AddWithValue("@ShiftName", UUT.sShiftName)
                    overallCmd.Parameters.AddWithValue("@OperatorName", UUT.sOperatorEnumber)
                    overallCmd.Parameters.AddWithValue("@TestSequenceName", UUT.sTestScript)
                    overallCmd.Parameters.AddWithValue("@CatalogNumber", UUT.sPartNumber)
                    overallCmd.Parameters.AddWithValue("@TestStartTime", Me.dtStartTime)
                    overallCmd.Parameters.AddWithValue("@TestEndTime", Me.dtStopTime)
                    overallCmd.Parameters.AddWithValue("@SerialNumber", UUT.sSerialNumber)
                    overallCmd.Parameters.AddWithValue("@OverallStatus", overallStatus)
                    overallCmd.Parameters.AddWithValue("@TestComments", If(String.IsNullOrEmpty(FailedTestStep), DBNull.Value, FailedTestStep))
                    overallCmd.Parameters.AddWithValue("@TestDurationMinutes", testDurationMinutes)
                    overallCmd.Parameters.AddWithValue("@CreatedBy", "BatteryTestApp")

                    testID = Convert.ToInt64(overallCmd.ExecuteScalar())
                End Using

                ' Now insert each test result with the TestID
                Dim testResultCount As Integer = 0
                For Each clItem As TestDataItem In lstTestDataItem
                    testResultCount += 1
                    Try
                        ' Insert main test result
                    Dim testResultID As Long
                    Using cmd As New SqlCommand("INSERT INTO dbo.TestResults " &
                        "(TestID, SerialNumber, SequenceNumber, InstructionName, Results, Status, " &
                        "TestComments, UpperTestLimit, LowerTestLimit, UpperControlLimit, LowerControlLimit, " &
                        "TestUnits, StepDataType, CallingFunction, TestStartTime, TestEndTime) " &
                        "OUTPUT INSERTED.TestResultID VALUES " &
                        "(@TestID, @SerialNumber, @SequenceNumber, @InstructionName, @Results, @Status, " &
                        "@TestComments, @UpperTestLimit, @LowerTestLimit, @UpperControlLimit, @LowerControlLimit, " &
                        "@TestUnits, @StepDataType, @CallingFunction, @TestStartTime, @TestEndTime)", connection)

                        cmd.Parameters.AddWithValue("@TestID", testID)
                        cmd.Parameters.AddWithValue("@SerialNumber", If(String.IsNullOrEmpty(clItem.sSerialNumber), "UNKNOWN", clItem.sSerialNumber))
                        ' Convert UInteger to Int32 safely
                        Dim seqNum As Integer
                        If clItem.uSequenceNumber > Integer.MaxValue Then
                            seqNum = Integer.MaxValue ' Cap at max int value
                        Else
                            seqNum = Convert.ToInt32(clItem.uSequenceNumber)
                        End If
                        cmd.Parameters.AddWithValue("@SequenceNumber", seqNum)
                        cmd.Parameters.AddWithValue("@InstructionName", If(String.IsNullOrEmpty(clItem.sInstructionName), "Unknown", clItem.sInstructionName))
                        cmd.Parameters.AddWithValue("@Results", If(String.IsNullOrEmpty(clItem.sResults), DBNull.Value, clItem.sResults))
                        ' Ensure Status is valid
                        Dim statusValue As String = clItem.sStatus
                        If statusValue <> "Passed" AndAlso statusValue <> "Failed" Then
                            statusValue = "Failed" ' Default to Failed if invalid
                        End If
                        cmd.Parameters.AddWithValue("@Status", statusValue)
                        cmd.Parameters.AddWithValue("@TestComments", If(String.IsNullOrEmpty(clItem.sTestComments), DBNull.Value, clItem.sTestComments))
                        cmd.Parameters.AddWithValue("@UpperTestLimit", If(clItem.fUpperTestLimit = 0, DBNull.Value, clItem.fUpperTestLimit))
                        cmd.Parameters.AddWithValue("@LowerTestLimit", If(clItem.fLowerTestLimit = 0, DBNull.Value, clItem.fLowerTestLimit))
                        cmd.Parameters.AddWithValue("@UpperControlLimit", If(clItem.fUpperControlLimit = 0, DBNull.Value, clItem.fUpperControlLimit))
                        cmd.Parameters.AddWithValue("@LowerControlLimit", If(clItem.fLowerControlLimit = 0, DBNull.Value, clItem.fLowerControlLimit))
                        cmd.Parameters.AddWithValue("@TestUnits", If(String.IsNullOrEmpty(clItem.sTestUnits), DBNull.Value, clItem.sTestUnits))
                        cmd.Parameters.AddWithValue("@StepDataType", If(clItem.nStepDataType = 0, DBNull.Value, clItem.nStepDataType))
                        cmd.Parameters.AddWithValue("@CallingFunction", If(String.IsNullOrEmpty(clItem.strCallingFunction), DBNull.Value, clItem.strCallingFunction))
                        ' Ensure dates are valid
                        Dim startTime As DateTime = clItem.dtStartTime
                        Dim endTime As DateTime = clItem.dtEndTime
                        If startTime > endTime Then
                            ' Swap if start time is after end time
                            Dim temp As DateTime = startTime
                            startTime = endTime
                            endTime = temp
                        End If
                        cmd.Parameters.AddWithValue("@TestStartTime", startTime)
                        cmd.Parameters.AddWithValue("@TestEndTime", endTime)

                        testResultID = Convert.ToInt64(cmd.ExecuteScalar())
                    End Using

                    ' Insert test result parameters
                    For Each clParameter As TestResultParameter In clItem.lstTestResultParameters
                        Using paramCmd As New SqlCommand("INSERT INTO dbo.TestResultParameters " &
                            "(TestResultID, Parameter_Key, Parameter_Value, Parameter_Unit) VALUES " &
                            "(@TestResultID, @Parameter_Key, @Parameter_Value, @Parameter_Unit)", connection)

                            paramCmd.Parameters.AddWithValue("@TestResultID", testResultID)
                            paramCmd.Parameters.AddWithValue("@Parameter_Key", If(String.IsNullOrEmpty(clParameter.sParameter_Key), "", clParameter.sParameter_Key))
                            paramCmd.Parameters.AddWithValue("@Parameter_Value", If(String.IsNullOrEmpty(clParameter.sParameter_Value), DBNull.Value, clParameter.sParameter_Value))
                            paramCmd.Parameters.AddWithValue("@Parameter_Unit", If(String.IsNullOrEmpty(clParameter.sParameter_Unit), DBNull.Value, clParameter.sParameter_Unit))

                            paramCmd.ExecuteNonQuery()
                        End Using
                    Next

                    ' Insert communication logs
                    For Each clComm As Communication In clItem.lstCommunication
                        Using commCmd As New SqlCommand("INSERT INTO dbo.TestResultCommunications " &
                            "(TestResultID, SequenceNumber, CommunicationType, CommunicationText, CommunicationTime) VALUES " &
                            "(@TestResultID, @SequenceNumber, @CommunicationType, @CommunicationText, @CommunicationTime)", connection)

                            commCmd.Parameters.AddWithValue("@TestResultID", testResultID)
                            commCmd.Parameters.AddWithValue("@SequenceNumber", clItem.uSequenceNumber + (clItem.lstCommunication.IndexOf(clComm)) / 1000.0)
                            commCmd.Parameters.AddWithValue("@CommunicationType",
                                If(clComm.eTXRX = Communication.TXRX.COMMENT, "CM", clComm.eTXRX.ToString()))
                            commCmd.Parameters.AddWithValue("@CommunicationText", clComm.sCommText)
                            commCmd.Parameters.AddWithValue("@CommunicationTime", clComm.dtTime)

                            commCmd.ExecuteNonQuery()
                        End Using
                    Next
                    Catch innerEx As Exception
                        ' Log error but continue with next item
                        TDMErrorCatch("Error inserting test result " & testResultCount & ": " & innerEx.Message, innerEx)
                        ' Continue with next item
                    End Try
                Next
            End Using

            Return 0 ' Success

        Catch sqlEx As SqlException
            ' Log SQL error but don't show message box to avoid interrupting test flow
            TDMErrorCatch("SQL Save Error: " & sqlEx.Message, sqlEx)
            Return -1
        Catch ex As Exception
            ' Log general error
            TDMErrorCatch("TestData SQL Save Error: " & ex.Message, ex)
            Return -1
        End Try
    End Function
End Class
