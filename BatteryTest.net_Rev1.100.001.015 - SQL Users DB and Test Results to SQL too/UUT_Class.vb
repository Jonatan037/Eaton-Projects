' UUT Class

Imports System.Xml
Imports System.IO
Imports System.Text

Public Class UUT_Class

    Public sPartNumber As String
    Public sSerialNumber As String
    Public sTestHarness As String
    Public sProductNotes As String
    Public fLowerLimitVoltage As Double
    Public fUpperLimitVoltage As Double
    Public sOperatorEnumber As String
    Public sOperatorName As String
    Public sOverAllResultsName As String
    Public sTestScript As String
    Public sTestApplication As String
    Public sShiftName As String
    Public LastPartNumberUsed As String
    Public sLastOperatorEnumber As String
    Public EnumberRunCount As Integer
    Public CurrentDate As String


    Public Sub New()

        ' Clear all main variables

        sPartNumber = ""

        sTestHarness = ""

        sProductNotes = ""

        fLowerLimitVoltage = 0

        fUpperLimitVoltage = 0

        sOperatorEnumber = ""

        sOperatorName = ""

        sOverAllResultsName = "BatteryTest_OverallResult"

        sTestScript = ""

        sTestApplication = "Application: " & My.Application.Info.Version.ToString

        sShiftName = "1"

        sLastOperatorEnumber = ""

        EnumberRunCount = 0

        CurrentDate = ""

    End Sub

    Public Sub Clear()

        ' Clear all main variables
        sPartNumber = ""
        sTestHarness = ""
        sProductNotes = ""
        fLowerLimitVoltage = 0
        fUpperLimitVoltage = 0
        sOperatorEnumber = ""
        sOperatorName = ""
        sTestScript = ""

    End Sub

End Class