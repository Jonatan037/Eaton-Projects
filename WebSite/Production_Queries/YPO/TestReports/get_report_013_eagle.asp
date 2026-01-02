<%Option Explicit%>
<%Response.Buffer = TRUE%>
<% Response.Clear %>
<html>

<head>
<title>Production Test Report For SHARK</title>


<STYLE TYPE="text/css">
<!--
TD{font-family: Arial; font-size: 8pt;}
--->
</STYLE>

</head>

<body>

<!-- #include File=GenericTable.Inc -->
<!-- #include File=adovbs.inc -->


<%

On Error Resume Next

Dim Conn			'Database connection.
Dim Sql				'The query to be executed.

Dim lIndexID			'INDEX_ID value for accessing the qdms_master_index table.
Dim lResultsID			'ResultsID from the qdms_master_index table.
Dim strConnection		'The database connection string.


Dim INDEX_ID_GUID		'The GUID from the ePDU database Master table.

Dim rsSetup


lIndexID = Request("ID")




Set Conn = Server.CreateObject("ADODB.Connection")

Conn.Open Application("QDMS")


'Get connection to SQL Server Express.
sql = "SELECT I.ResultsID, D.ConnectionString FROM qdms_master_index AS I INNER JOIN qdms_database_ids as D ON I.DBID = D.DBID WHERE INDEXID = " & lIndexId
'sql = "SELECT ConnectionString FROM qdms_database_ids WHERE DBID = 41"

Set rsSetup = Conn.Execute(sql)


If ErrorOccurred(Err, sql) Then Response.End


'Get the ResultsID (DATADOG_ID ) from the recordset.
lResultsID = rsSetup("ResultsID")


'Get the connection string from the recordset.
strConnection = rsSetup("ConnectionString")

'Append the WebApp credentials instead of using the trusted connection.
strConnection = Replace(strConnection, "Trusted_Connection=Yes;", "UID=WebApp;PWD=FloorUPSTst1")

rsSetup.Close
Set rsSetup = Nothing
Conn.Close

'Increase timeout for connecting to remote databases.
'The timeout is in seconds.
Conn.ConnectionTimeout = 240
Server.ScriptTimeout = 240


Conn.Open strConnection

If ErrorOccurred(Err, "Unable to open connection to the database") Then Response.End

'Print the header information
If OpenExcelFile(lResultsID) Then
   '
End If

Conn.Close
Set Conn = Nothing



'----------------------------------------------------------------------------------------------------
Function ErrorOccurred(Error, Msg)


	If Err.Number <> 0 then

		Response.Write "ERROR OCCURRED<br>"
		Response.Write "ERROR NUMBER = " & Err.Number & "<br>"
		Response.Write "ERROR DESCRIPTION = " & Err.Description & "<br>"
		Response.Write Msg & "<br>"


		ErrorOccurred = True
		Exit Function

	End If


	ErrorOccurred = False

End Function



'----------------------------------------------------------------------------------------------------
Function OpenExcelFile(lResultsID)


   On Error Resume Next

   Dim sql
   Dim rs
   Dim strPath
   Dim strFilePath
   Dim strFile

   'Default return value.
   OpenExcelFile = False

   sql = "Select * From Master WHERE DATADOG_ID = " & lResultsID

   'Get the data from the database.
   Set rs = Conn.Execute(sql)

   If ErrorOccurred(Err, "Error in OpenExcelFile routine<br>" & sql) Then Response.End


   'Get the original serial number
   strFile = rs("ReportFileName") & ".xls"

   
   strFilePath = "\\youncsfp01\data\Test-Eng\ProdTestData\Data_Logs\TAA\Eagle\Reports\10000\" 
   'strFile = "BJ333V0014 2015-08-13 12-35-47 Failed.xls"

   strPath = CStr(strFilePath & strFile)


   '-- do some basic error checking for the QueryString

   If strPath = "" Then
       Response.Clear
       Response.Write("No file specified.")
       Response.End
   ElseIf InStr(strPath, "..") > 0 Then
       Response.Clear
       Response.Write("Illegal folder location.")
       Response.End
   ElseIf Len(strPath) > 1024 Then
       Response.Clear
       Response.Write("Folder path too long.")
       Response.End
   Else

       Call DownloadFile(strPath)
   End If

   OpenExcelFile = True

End Function



'----------------------------------------------------------------------------------------------------
Private Sub DownloadFile(file)
    '--declare variables

    Dim strAbsFile
    Dim strFileExtension
    Dim objFSO
    Dim objFile
    Dim objStream


on error resume next


    '-- set absolute file location
    'strAbsFile = Server.MapPath(file)
    strAbsFile = file
	

    '-- create FSO object to check if file exists and get properties
    Set objFSO = Server.CreateObject("Scripting.FileSystemObject")


    '-- check to see if the file exists
    If objFSO.FileExists(strAbsFile) Then

        Set objFile = objFSO.GetFile(strAbsFile)


        '-- first clear the response, and then set the appropriate headers
        Response.Clear

        '-- the filename you give it will be the one that is shown
        ' to the users by default when they save

        Response.AddHeader "Content-Disposition", "attachment; filename=" & objFile.Name
        Response.AddHeader "Content-Length", objFile.Size
        Response.ContentType = "application/octet-stream"


        Set objStream = Server.CreateObject("ADODB.Stream")
        objStream.Open
        '-- set as binary
        objStream.Type = 1
        Response.CharSet = "UTF-8"


        '-- load into the stream the file
        objStream.LoadFromFile(strAbsFile)


        '-- send the stream in the response
        Response.BinaryWrite(objStream.Read)

        objStream.Close

        Set objStream = Nothing
        Set objFile = Nothing

    Else 'objFSO.FileExists(strAbsFile)

        Response.Clear
        Response.Write("No such file exists: " & strAbsFile)
    End If

    Set objFSO = Nothing

    response.flush 

    resonse.close

    response.end


End Sub


%>
</body>
</html>
