<%Option Explicit%>
<%Response.Buffer = TRUE%>
<% Response.Clear %>
<html>

<head>
<title>9390PM</title>
</head>

<body>

<!-- #include File=GenericTable.Inc -->
<!-- #include File=adovbs.inc -->


<%

Dim cnYPO			'Database connection for the YPO database.
Dim Conn			'Connection for the rpo_proddata server.

Dim Sql				'The query to be executed.
Dim QueryStartDate
Dim QueryEndDate
Dim lResultsID

Dim rsIndex
Dim rsProgram

Dim rsTestResults

Dim sTestStep
Dim iCtr


Set cnYPO = Server.CreateObject("ADODB.Connection")
Server.ScriptTimeout = 3600
cnYPO.ConnectionTimeout = 90

cnYPO.Open Application("QDMS")


Set Conn = Server.CreateObject("ADODB.Connection")
Conn.Open "Provider=SQLOLEDB;Data Source=rpo-proddata;Database=rpo_proddata;Trusted_Connection=Yes;"



Sql = "SELECT I.DBID, I.PartNumber, I.SerialNumber, I.Sequence, I.StartTime, I.TestResult, I.ResultsID " & _
      "FROM qdms_master_index AS I " & _
      "WHERE I.RecordType = 2 AND I.DBID = 2 AND I.SerialNumber Like '9390PM%' "


Sql = "SELECT I.DBID, I.PartNumber, I.SerialNumber, I.Sequence, I.StartTime, I.TestResult, I.ResultsID " & _
      "FROM qdms_master_index AS I " & _
      "WHERE I.DBID = 2 AND I.SerialNumber Like '9390PM%' " & _
      "ORDER BY I.SerialNumber, I.StartTime"


Sql = "SELECT I.DBID, I.PartNumber, I.SerialNumber, I.Sequence, I.StartTime, I.TestResult, I.ResultsID " & _
      "FROM qdms_master_index AS I " & _
      "WHERE I.DBID = 2 AND (I.PartNumber Like 'T%'OR I.PartNumber Like 'H%' ) AND I.StartTime >= '11/1/2015' " & _
      "ORDER BY I.SerialNumber, I.StartTime"


'response.write sql
'response.end

Set rsIndex = cnYPO.Execute(Sql)


Response.Clear
Response.ContentType = "Application/vnd.ms-excel"

Response.Write "Part Number" & chr(9)
Response.Write "Serial Number" & chr(9)
Response.Write "Start Time" & chr(9)
Response.Write "Test Status" & chr(9)
Response.Write "Step Name" & chr(9)
Response.Write "Value" & chr(9)

Response.Write vbCrLf

On Error Resume Next

Do While Not rsIndex.EOF

	lResultsID = rsIndex("ResultsID")
	GetResultsData rsTestResults, lResultsID, "spTestResults"
	PrintStepInfo sTestStep

	
	rsIndex.MoveNext
Loop






Conn.Close
Set Conn = Nothing

cnYPO.Close
Set cnYPO = Nothing




'----------------------------------------------------------------------------------------------------
Sub GetResultsData(rs, lResultsID, sProcedureName)

	Dim cmd


	Set cmd = Server.CreateObject("ADODB.Command")

	cmd.ActiveConnection = Conn

	cmd.CommandText = sProcedureName
	cmd.CommandType = adCmdStoredProc

	cmd.Parameters.Append cmd.CreateParameter ("[ResultID]",adInteger,adParamInput)
	cmd.Parameters("[ResultID]") = lResultsID

	Set rs = cmd.Execute

	set cmd = nothing


End Sub





'----------------------------------------------------------------------------------------------------
Sub PrintStepInfo(sTestStep)

	Dim tsLabel		'The overall name of the test step.
	Dim rdLabel		'The name of the actual parameter.
	Dim iCtr		'Counter for array indexing
	Dim blnGetData		'Flag to indicate that the data for this row should be retrieved.


	With rsTestResults

		.MoveFirst

		Do Until .EOF

			tsLabel = Trim(UCase(.Fields("TestLabel")))

			'Default value is to ignore this row of data.
			blnGetData = FALSE


			If Instr(tsLabel, "4x0V") Then blnGetData = TRUE


			'Get the data if the criteria was met.
			If blnGetData Then

				rdLabel = Trim(.Fields("rdLabel"))


				Response.Write rsIndex("PartNumber") & chr(9)
				Response.Write rsIndex("SerialNumber") & chr(9)
				Response.Write rsIndex("StartTime") & chr(9)
				Response.Write rsIndex("TestResult") & chr(9)


				Response.Write  Trim(.Fields("TestLabel") ) & " - " & rdLabel & chr(9)

				Response.Write .Fields("ActualStr") & chr(9)


				Response.Write vbCrLf


			End If

      .MoveNext

    Loop


  End With


End Sub



'----------------------------------------------------------------------------------------------------

%>

