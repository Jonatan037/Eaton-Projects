
' Revision History:
' ------------------------------------------------------------
' Revision History 
' Author        Date            Notes
' ________________________________________________________________________________
' J. Parker     Apr 015, 2023   'Modified for battery test.
'                                                    

Imports System
Imports System.IO
Imports System.Data
Imports System.Data.OleDb
Imports VB = Microsoft.VisualBasic
Imports System.Collections.Generic
Imports MES
'

'To store the test result in DB to be done

Module DBProcess

    Function submit_data() As Boolean
        Dim sWorkingFolder As String
        Dim sPendingFilePath As String
        Dim sArchiveFullName As String
        Dim TempCount As Integer

        ' Get the current working directory: 
        sWorkingFolder = System.IO.Directory.GetCurrentDirectory

        sPendingFilePath = sWorkingFolder & "\Pending\"

        Dim Directory As New IO.DirectoryInfo(sPendingFilePath)

        'Creates the array in reverse so a damaged file is sent last
        Dim allFiles As IO.FileInfo() = Directory.GetFiles("*.xml")
        Dim singleFile As IO.FileInfo

        submit_data = True

        TempCount = 0

        For Each singleFile In allFiles

            TempCount = TempCount + 1

            'Console.WriteLine(singleFile.FullName)
            MainTestInterface.btn_SendReportToTDM.Text = "Sending report " & TempCount & " of " & allFiles.Count

            MainTestInterface.Refresh()

            If File.Exists(singleFile.FullName) Then

                ' Setup the call to the utility program.
                Dim myProcess As New Process()

                'Need to enclose file names in quotes.
                myProcess.StartInfo.FileName = Chr(34) & sWorkingFolder & "\TDM\UploadXmlTestResults.exe" & Chr(34)
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

                    sArchiveFullName = Replace(singleFile.FullName, "Pending", "Archive")

                    My.Computer.FileSystem.CopyFile(singleFile.FullName, sArchiveFullName)

                    'delete file if output is good - may not be about to do this in the for loop
                    My.Computer.FileSystem.DeleteFile(singleFile.FullName)

                Else

                    submit_data = False

                    Exit For

                End If

            End If

        Next

    End Function

    ' Returns true if TDM has a passed 

    Function TDM_LastTestFailed(ResultsName As String, SN As String) As Boolean
        Dim sWorkingFolder As String
        Dim sWebServicePath As String

        ' Get the current working directory: 
        sWorkingFolder = System.IO.Directory.GetCurrentDirectory

        'Need to enclose file names in quotes.
        sWebServicePath = Chr(34) & sWorkingFolder & "\TDM_RecordCheck\IES_TDM.exe" & Chr(34)

        TDM_LastTestFailed = False

        ' Setup the call to the utility program.
        Dim myProcess As New Process()

        'Need to enclose file names in quotes.
        myProcess.StartInfo.FileName = sWebServicePath
        myProcess.StartInfo.Arguments = Chr(34) & ResultsName & Chr(34) & " " & Chr(34) & SN & Chr(34)

        myProcess.StartInfo.UseShellExecute = False
        myProcess.StartInfo.CreateNoWindow = True
        myProcess.StartInfo.RedirectStandardInput = True
        myProcess.StartInfo.RedirectStandardOutput = True
        myProcess.StartInfo.RedirectStandardError = True
        myProcess.Start()

        Dim output As String = myProcess.StandardOutput.ReadToEnd()

        myProcess.Close()

        ' Check output for Status and results
        If InStr(output, "Status = Passed") > 25 And InStr(output, "Result = Passed") Then

            ' Last record has a passed condition
            TDM_LastTestFailed = False

        Else

            ' Last record does not exist or has a failed status
            TDM_LastTestFailed = True

        End If

    End Function

    Public Function mySimpleDBRead(sDBaddress As String) As Boolean
        Dim sTemp As String
        Dim conn As OleDbConnection
        Dim da As OleDbDataAdapter
        Dim ds As DataSet
        Dim ReadFailure As Boolean
        Dim sSQL As String
        Dim ErrorMessage As String


        'Check if able to connect to the database
        'Return false if row count incorrect in exception thrown

        Try

            'Try to pull one data point from table
            sSQL = "Select * from TestHarness where txtCode = " & "'" & "PD" & "'" & "ORDER BY txtCode DESC"

            conn = New OleDbConnection(sDBaddress)
            ' conn = New OleDbConnection("Bad address")

            conn.Open()

            da = New OleDbDataAdapter(sSQL, conn)
            ds = New DataSet()
            da.Fill(ds, "HarnessLocation")
            conn.Close()

            If ds.Tables(0).Rows.Count >= 1 Then
                Return True
            Else
                Return False
            End If

        Catch ex As Exception
            If IsNothing(conn) = False Then
                If conn.State = ConnectionState.Open Then
                    conn.Close()
                End If
            End If

            MsgBox(ex.Message, MsgBoxStyle.Critical)

            Return False

        End Try

    End Function

    Public Function PullPreflightRecord(sDBConnection As String, sEnumber As String, sLineName As String, sIssue As String) As Boolean
        Dim sTemp As String
        Dim conn As OleDbConnection
        Dim da As OleDbDataAdapter
        Dim ds As DataSet
        Dim ReadFailure As Boolean
        Dim sSQL As String
        Dim ErrorMessage As String
        Dim sTodayDate As String


        'Check if able to connect to the database
        'Return false if row count incorrect in exception thrown



        Try
            sIssue = ""

            sTodayDate = DateTime.Now.ToString(“yyyy-MM-dd")

            ' Verify eNumber is full length
            If Not (sEnumber.Length = 8) Then
                sIssue = "Enumber must be 10 charactor long"
                Return False
            End If

            'Try to pull one data point from table
            sSQL = "Select * from Results_Summary where Enumber = " & "'" & sEnumber & "' and LineName = '" & sLineName & "' and TimeStamp_Start > '" & sTodayDate & "'"

            conn = New OleDbConnection(sDBConnection)

            conn.Open()

            da = New OleDbDataAdapter(sSQL, conn)
            ds = New DataSet()
            da.Fill(ds, "PreflightChecklist")
            conn.Close()

            If ds.Tables(0).Rows.Count >= 1 Then
                Return True
            Else
                sIssue = "Could not find Preflight check list for: " & sEnumber & "for date: " & sTodayDate
                Return False
            End If

        Catch ex As Exception
            If IsNothing(conn) = False Then
                If conn.State = ConnectionState.Open Then
                    conn.Close()
                End If
            End If

            MsgBox(ex.Message, MsgBoxStyle.Critical)

            Return False

        End Try

    End Function


End Module





