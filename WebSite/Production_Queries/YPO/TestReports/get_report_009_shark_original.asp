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
If PrintHeaderInfo(lResultsID) Then
   PrintStepResults INDEX_ID_GUID
End If


'Values for returning record as a word document.
'Response.ContentType = "application/msword"
'Response.AddHeader "content-disposition", "inline; filename = " & strSerialNumber & ".doc"


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
Function PrintHeaderInfo(lResultsID)


   On Error Resume Next

   Dim sql
   Dim rs
   Dim rs_original_serial_number

   'Default return value.
   PrintHeaderInfo = False

   sql = "Select * From Master WHERE DATADOG_ID = " & lResultsID

   'Get the data from the database.
   Set rs = Conn.Execute(sql)

   If ErrorOccurred(Err, "Error in PrintHeaderInfo routine<br>" & sql) Then Response.End


   'Get the original serial number
   sql = "Select OriginalSerialNum From LPDSerialNumTracker WHERE LPDSerialNum = '" & rs("SerialNumber") & "'"

   'Get the data from the database.
   Set rs_original_serial_number = Conn.Execute(sql)

   If ErrorOccurred(Err, sql) Then Response.End



 
   Response.Write "<table cellspacing=0 cellpadding=2>"


   Response.Write "<tr>"
      Response.Write "<td><b>INDEX_ID:</b></td>"
      Response.Write "<td>" & rs("INDEX_ID") & "</td>"
   Response.Write "</tr>"

   Response.Write "<tr>"
      Response.Write "<td><b>Script Name:</b></td>"
      Response.Write "<td>" & rs("ScriptName") & "</td>"
   Response.Write "</tr>"

   Response.Write "<tr>"
      Response.Write "<td><b>Script Version:</b></td>"
      Response.Write "<td>" & rs("ScriptVersion") & "</td>"
   Response.Write "</tr>"



	Response.Write "<tr>"
		Response.Write "<td><b>LPD Serial Number:</b></td>"
		Response.Write "<td>" & rs("SerialNumber") & "</td>"
	Response.Write "</tr>"


	Response.Write "<tr>"
		Response.Write "<td><b>PQNA Serial Number:</b></td>"
		Response.Write "<td>" & rs_original_serial_number("OriginalSerialNum") & "</td>"
	Response.Write "</tr>"


	Response.Write "<tr>"
		Response.Write "<td><b>Part Number:</b></td>"
		Response.Write "<td>" & rs("PartNumber") & "</td>"
	Response.Write "</tr>"


	Response.Write "<tr>"
		Response.Write "<td><b>Config Number:</b></td>"
		Response.Write "<td>" & rs("ConfigNumber") & "</td>"
	Response.Write "</tr>"


	Response.Write "<tr>"
		Response.Write "<td><b>Test Date:</b></td>"
		Response.Write "<td>" & rs("StartTime") & "</td>"
	Response.Write "</tr>"


	Response.Write "<tr>"
		Response.Write "<td><b>Test Mode:</b></td>"
		Response.Write "<td>" & rs("TestMode") & "</td>"
	Response.Write "</tr>"

	Response.Write "<tr>"
		Response.Write "<td><b>Results:</b></td>"
		If rs("Result") Then
 		   Response.Write "<td>Passed</td>"
		Else
		   Response.Write "<td>Failed</td>"
		End If
	Response.Write "</tr>"

	Response.Write "</table>"

	Response.Write "<br><br>"


   INDEX_ID_GUID = "'" & rs("INDEX_ID") & "'"


   PrintHeaderInfo = True



End Function



'----------------------------------------------------------------------------------------------------
Sub PrintStepResults(INDEX_ID_GUID)

	Dim sql
	Dim rs
	Dim ctr


	On Error Resume Next
	
	sql = "SELECT * FROM StepResults WHERE INDEX_ID = " & INDEX_ID_GUID & " ORDER BY InsertOrder"

	Set rs = Conn.Execute(sql)
		
	If ErrorOccurred(Err, "Error in PrintStepResults routine<br>" & sql) Then Response.End


	Response.Write "<table cellspacing=0 cellpadding=2 border=3>"

	'Create column names.
	Response.Write "<tr>"
	   Response.Write "<td><b>InsertOrder</b></td>"
           Response.Write "<td><b>StepName</b></td>"
           Response.Write "<td><b>ParameterName</b></td>"
	   Response.Write "<td><b>DataType</b></b></td>"
	   Response.Write "<td><b>TxtData</b></td>"
	   Response.Write "<td><b>TxtLimitLow</b></td>"
	   Response.Write "<td><b>TxtLimitHigh</b></td>"
	   Response.Write "<td><b>NumData</b></td>"
	   Response.Write "<td><b>NumReference</b></td>"
	   Response.Write "<td><b>NumLimitLow</b></td>"
	   Response.Write "<td><b>NumLimitHigh</b></td>"
	   Response.Write "<td><b>NumUnits</b></td>"
	   Response.Write "<td><b>Result</b></td>"
	   Response.Write "<td><b>CommLog</b></td>"
	Response.Write "</tr>"


	Do While Not rs.Eof

		Response.Write "<tr>"

		Response.Write "<td>" & rs("InsertOrder") & "</td>"
		Response.Write "<td>" & rs("StepName") & "</td>"
		Response.Write "<td>" & rs("ParameterName") & "&nbsp;</td>"
		Response.Write "<td>" & rs("DataType") & "&nbsp;</td>"		
		Response.Write "<td>" & rs("TxtData") & "&nbsp;</td>"		
		Response.Write "<td>" & rs("TxtLimitLow") & "&nbsp;</td>"
		Response.Write "<td>" & rs("TxtLimitHigh") & "&nbsp;</td>"
		Response.Write "<td>" & rs("NumData") & "&nbsp;</td>"
		Response.Write "<td>" & rs("NumReference") & "&nbsp;</td>"
		Response.Write "<td>" & rs("NumLimitLow") & "&nbsp;</td>"
		Response.Write "<td>" & rs("NumLimitHigh") & "&nbsp;</td>"
		Response.Write "<td>" & rs("NumUnits") & "&nbsp;</td>"

		'Show results as either Passed or Failed.
		If rs("Result") Then
		   Response.Write "<td>Passed</td>"
		Else
		   Response.Write "<td>Failed</td>"
		End If

		Response.Write "<td>" & CommLog("'" & rs("STEP_RESULTS_ID") & "'") & "</td>"


		Response.Write "</tr>"


		rs.MoveNext

	Loop

	Response.Write "</table>"

	Response.Write "<br><br>"

End Sub


'----------------------------------------------------------------------------------------------------
Function CommLog(STEP_RESULTS_ID_GUID)

	Dim sql
	Dim rs
	Dim ctr


	On Error Resume Next
	
	CommLog = ""


	sql = "SELECT * FROM CommLog WHERE STEP_RESULTS_ID = " & STEP_RESULTS_ID_GUID & " ORDER BY InsertOrder"


	Set rs = Conn.Execute(sql)
		
	If ErrorOccurred(Err, "Error in CommLog routine<br>" & sql) Then Response.End

	'Stop if there are not any records in the comm log table for this step.
	If rs.Eof Then 
	   CommLog = "&nbsp;"
	   Exit Function
	End If

	CommLog =  "<table cellspacing=0 cellpadding=2 border=3>"

	'Create column names.
	CommLog = CommLog & "<tr>"
           CommLog = CommLog & "<td><b>TimeStamp</b></td>"
           CommLog = CommLog & "<td><b>Direction</b></td>"
	   CommLog = CommLog & "<td><b>Data</b></td>"
	CommLog = CommLog & "</tr>"


	Do While Not rs.Eof

		CommLog = CommLog & "<tr>"

		CommLog = CommLog & "<td>" & rs("TimeStamp") & "</td>"
		CommLog = CommLog & "<td>" & rs("Direction") & "</td>"
		CommLog = CommLog & "<td>" & rs("Data") & "</td>"		


		CommLog = CommLog & "</tr>"


		rs.MoveNext

	Loop

	CommLog = CommLog & "</table>"

	CommLog = CommLog & "<br><br>"

End Function


%>
</body>
</html>
