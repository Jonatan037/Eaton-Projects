' UUT Class

Imports System.Xml
Imports System.IO
Imports System.Text

Public Class TestSystem_Class

    Public sTestApplication As String
    Public sLineName As String
    Public sParentWorkStation As String
    Public sWorkstationName As String
    Public bVerifyPreFlightCheckList As Boolean
    Public sPreFlightDBConnection As String
    Public SystemConfig_Path As String
    Public sXMLDebugPath As String
    Public DisableHardware As Boolean
    Public GPIBADDRESS_8846A As String
    Public CheckDupSerialNumber As Boolean
    Public sFileNameTestSpecData() As String
    Public sLocation_LocalTestSpecData As String
    Public sLocation_NetworkTestSpecData As String
    Public sLatestDate As String
    Public bXMLReportView As Boolean



    Public Sub New()

        ' Clear all main variables

        sLineName = "BatteryLine"

        sParentWorkStation = "BatteryLine"

        sTestApplication = "Application: " & My.Application.Info.Version.ToString

        sFileNameTestSpecData = {"EmployeeBatteryLine.xml", "BatteryTestSpecs.xml"}

        sLocation_LocalTestSpecData = System.Windows.Forms.Application.StartupPath & "\TestSpec"

        sLocation_NetworkTestSpecData = "\\youncsfp01\DATA\Test-Eng\ProdTestData\TestSpecs\BatteryLine\TestSpec"

        sPreFlightDBConnection = False

        SystemConfig_Path = System.Windows.Forms.Application.StartupPath & "\SystemConfig.ini"

        DisableHardware = True

        CheckDupSerialNumber = True

        bVerifyPreFlightCheckList = True

        bXMLReportView = False

        sLatestDate = DateTime.Now.ToString(“yyyy-MM-dd")

        ExecuteTest.CopyFilesFromTo(sLocation_NetworkTestSpecData, sLocation_LocalTestSpecData, sFileNameTestSpecData)

    End Sub

    Public Sub Clear()

        ' Clear all main variables

        DisableHardware = True


    End Sub

End Class


