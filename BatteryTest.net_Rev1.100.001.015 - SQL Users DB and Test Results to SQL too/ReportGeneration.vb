Imports System.IO
Imports System.Text

Public Structure ReportItem

    Public ReportId As String
    Public SerialNumber As String
    Public PartNumber As String
    Public ATEName As String
    Public ATESoftwareVersion As String
    Public StartTime As String
    Public EndTime As String
    Public ExecutionTime As String
    Public TestStation As String
    Public ParameterName As String
    Public TestItem As String
    Public HiLimit As String
    Public LoLimit As String
    Public ItemValue As String
    Public Result As String
    Public Comment As String

End Structure
Public Class ReportGeneration

    Public myReportItem As ReportItem

    Public ReportWriter As StreamWriter


    Public Function CreateReport(ByVal ReportPath As String, ByVal ReportName As String, ByRef Errmsg As String) As Boolean

        Try

            ReportWriter = New StreamWriter(ReportPath & ReportName, True)

            ReportWriter.WriteLine("ReportIndex,ATEName,ATEVersion,TestStation,StartTime,EndTime,PartNumber,SerialNumber," & _
            "TestItem,ParameterName,ItemValue,HiLimit,LowLimit,Result(Pass/Fail),Comment")

            ReportWriter.AutoFlush = True
            'ReportWriter.Close()

            Return True

        Catch ex As Exception

            ReportWriter.Close()
            Errmsg = "exception capture when create the report " & ReportPath & ReportName & "Detail is" & ex.Message.ToString

        Finally

            ' ReportWriter.Close()
        End Try




    End Function


    Public Function WriteReport(ByRef Errmsg As String) As Boolean

        MainTestInterface.myReport.StartTime = Format(Date.Now, "HH:mm:ss")
        MainTestInterface.myReport.EndTime = ""
        ReportWriter.WriteLine(MainTestInterface.myReport.ReportId & "," & MainTestInterface.myReport.ATEName & "," & MainTestInterface.myReport.ATESoftwareVersion & "," & _
          MainTestInterface.myReport.TestStation & "," & MainTestInterface.myReport.StartTime & "," & MainTestInterface.myReport.EndTime & "," & MainTestInterface.myReport.PartNumber & "," & MainTestInterface.myReport.SerialNumber & _
        "," & MainTestInterface.myReport.TestItem & "," & MainTestInterface.myReport.ParameterName & "," & MainTestInterface.myReport.ItemValue & "," & MainTestInterface.myReport.HiLimit & "," & MainTestInterface.myReport.LoLimit & "," & MainTestInterface.myReport.Result & "," & MainTestInterface.myReport.Comment)


        MainTestInterface.myReport.StartTime = ""
        MainTestInterface.myReport.HiLimit = 0
        MainTestInterface.myReport.LoLimit = 0
        MainTestInterface.myReport.ParameterName = ""
        MainTestInterface.myReport.ItemValue = ""
        MainTestInterface.myReport.Result = ""
        MainTestInterface.myReport.Comment = ""

    End Function

End Class
