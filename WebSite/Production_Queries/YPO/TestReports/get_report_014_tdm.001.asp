<%Option Explicit%>
<%Response.Buffer = TRUE%>
<% Response.Clear %>
<html>

<head>
<title>Test Report</title>


<STYLE TYPE="text/css">
<!--
TD{font-family: Arial; font-size: 10pt;}
--->
</STYLE>

</head>

<body>


<!-- #include File=adovbs.inc -->


<%

Dim qdmsConn			'QDMS database connection.
Dim Conn			'database connection
Dim Sql				'The query to be executed.

Dim lIndexID
Dim lResultsID
Dim strConnection
Dim strSerialNumber
Dim fld
Dim rs

Dim summary_report
Dim detailed_report

lIndexID = Request("ID")


On Error Resume Next

'Create connection objects.
Set qdmsConn = Server.CreateObject("ADODB.Connection")
Set Conn = Server.CreateObject("ADODB.Connection")


'Conn.ConnectionTimeout = 90
qdmsConn.Open Application("QDMS")


'Get search infor from the QDMS database.
Set rs = qdmsConn.Execute("SELECT I.ResultsID, I.SerialNumber, D.ConnectionString FROM qdms_master_index AS I INNER JOIN qdms_database_ids as D ON I.DBID = D.DBID WHERE INDEXID = " & lIndexId)


'Assign values from the database to local variables.
lResultsID = rs("ResultsID")
strConnection = rs("ConnectionString")
strSerialNumber = rs("SerialNumber")


'Close the recordset and the QDMS connection.
rs.Close
Set rs = Nothing
qdmsConn.Close


'Show any error that might have occurred up to this point.
If Err.Description <> "" Then 
   Response.Write "Error : " + Err.Description + "<br>"
   Response.End
End If


'response.write strConnection
'Response.end


Conn.Open strConnection



If Err.Description <> "" Then 
   Response.Write "Error : " + Err.Description + "<br>" & Conn.ConnectionString
   Response.End
End If


'sql = "SELECT * FROM TDM_TEST_RESULT_RUN WHERE Id = " & lResultsID

'----------------------------------------------

sql = "SELECT TestResults.Id AS TestResultId, TestRuns.Id AS TestRunId, TestRuns.LineId, Lines.LineName, " & _
      "TestRuns.WorkstationId, Stations.WorkstationName, TestRuns.ParentStationId, ParentStations.WorkstationName AS ParentStationName,  " & _
      "Catalogs.CatalogNumber, SerialNos.SerialNumber, Shifts.ShiftName, Operators.OperatorName, TestRuns.Passed, TestSeq.TestSequenceName,  " & _
      "TestResults.InstructionId, Instructions.InstructionName,  Units.Units, TestResults.SequenceNumber, TestRuns.StartTime,  " & _
      "TestResults.EndTime, TestRuns.TestRunSpan, TestResults.UpperLimit, TestResults.LowerLimit,  " & _
      "TestResults.UpperControlLimit, TestResults.LowerControlLimit, TestResults.Results, TestResults.TestComments,  " & _
      "Status.Status, TestRuns.TestRunType " & _
"FROM dbo.TDM_TEST_RESULT_RUN AS TestRuns INNER JOIN " & _
	  "dbo.TDM_TEST_RESULT_LINES AS Lines ON Lines.Id = TestRuns.LineId INNER JOIN " & _
	  "dbo.TDM_TEST_RESULT_WORKSTATIONS AS Stations ON Stations.Id = TestRuns.WorkstationId INNER JOIN " & _
	  "dbo.TDM_TEST_RESULT_WORKSTATIONS AS ParentStations ON ParentStations.Id = TestRuns.ParentStationId INNER JOIN " & _
	  "dbo.TDM_TEST_RESULT_CATALOGS AS Catalogs ON Catalogs.Id = TestRuns.CatalogNoId INNER JOIN " & _
	  "dbo.TDM_TEST_RESULT_SERIALNUMBERS AS SerialNos ON SerialNos.Id = TestRuns.SerialNoId INNER JOIN " & _
	  "dbo.TDM_TEST_RESULT_SHIFTS AS Shifts ON Shifts.Id = TestRuns.ShiftId INNER JOIN " & _
	  "dbo.TDM_TEST_RESULT_OPERATORS AS Operators ON Operators.Id = TestRuns.OperatorId INNER JOIN " & _
	  "dbo.TDM_TEST_RESULTS AS TestResults ON TestResults.TestRunId = TestRuns.Id INNER JOIN " & _
	  "dbo.TDM_TEST_RESULT_TESTSEQUENCES AS TestSeq ON TestSeq.Id = TestResults.TestSequenceId INNER JOIN " & _
	  "dbo.TDM_TEST_RESULT_INSTRUCTIONS AS Instructions ON Instructions.Id = TestResults.InstructionId INNER JOIN " & _
	  "dbo.TDM_TEST_RESULT_UNITS AS Units ON Units.Id = TestResults.UnitId INNER JOIN " & _
	  "dbo.TDM_TEST_RESULT_STATUS AS Status ON Status.Id = TestResults.StatusId  " & _
"WHERE TestRuns.Id = " & lResultsID & " " & _
"ORDER BY TestResults.SequenceNumber"

'----------------------------------------------



Set rs = Conn.Execute(sql)


' Check for error.
If Err.Description <> "" Then
	Response.Write "<B>Error " + Hex(Err) + ": " + Err.Description + "</B><br>"

' Check for no-record case.
ElseIf RS.EOF And RS.BOF Then

	Response.Write "No records were found for this unit."

' Valid data was received from the query.
Else

	Response.Write "<table cellspacing=0 cellpadding=2 border=0>"

	Response.Write "<tr><td><b>CatalogNumber</b></td><td>" & rs("CatalogNumber") &  "</td></tr>"
	Response.Write "<tr><td><b>SerialNumber</b></td><td>" & rs("SerialNumber") &  "</td></tr>"	
	Response.Write "<tr><td><b>StartTime</b></td><td>" & rs("StartTime") &  "</td></tr>"
	Response.Write "<tr><td><b>EndTime</b></td><td>" & rs("EndTime") &  "</td></tr>"
	Response.Write "<tr><td><b>Status</b></td><td>" & rs("Passed") &  "</td></tr>"
	Response.Write "<tr><td><b>TestRunType</b></td><td>" & rs("TestRunType") &  "</td></tr>"
	Response.Write "<tr><td><b>OperatorName</b></td><td>" & rs("OperatorName") &  "</td></tr>"

	Response.Write "</table>"


	Response.Write "<br>"

	summary_report = ""
	detailed_report = ""
	

	Do While Not rs.eof

		if instr(rs("InstructionName"), "TestListItem") > 0 then
		
			summary_report = summary_report & "<tr>"
			summary_report = summary_report &  "<td>" & Replace(rs("InstructionName"), " - TestListItem", "") & "</td>"
			summary_report = summary_report &  "<td>" & rs("Status") & "</td>"
			summary_report = summary_report &  "</tr>"

		else

			detailed_report = detailed_report & "<tr>"

			detailed_report = detailed_report &  "<td>" & rs("InstructionName") & "</td>"
			detailed_report = detailed_report &  "<td>" & rs("LowerLimit") & "&nbsp;</td>"
			detailed_report = detailed_report &   "<td>" & rs("Results") & "&nbsp;</td>"
			detailed_report = detailed_report &   "<td>" & rs("UpperLimit") & "&nbsp;</td>"
			detailed_report = detailed_report &  "<td>" & rs("Status") & "</td>"
			detailed_report = detailed_report &   "<td>" & rs("TestComments") & "&nbsp;</td>"




			detailed_report = detailed_report &  "</tr>"		

		End if


	  rs.moveNext

	loop


	if summary_report <> "" then

		Response.Write "<table cellspacing=0 cellpadding=2 border=0>"  

		Response.Write summary_report

		Response.Write "</table>"

		Response.Write "<br>"
	end if


	if detailed_report <> "" then

		Response.Write "<table cellspacing=0 cellpadding=2 border=3>" 

		Response.Write "<tr>"
		Response.Write "<td>Instruction Name</td>"
		Response.Write "<td>Lower Limit</td>"
		Response.Write "<td>Actual</td>"
		Response.Write "<td>Upper Limit</td>"
		Response.Write "<td>Status</td>"
		Response.Write "<td>Test Comments</td>"
		Response.Write "</tr>"


		Response.Write detailed_report
		
		Response.Write "</table>"

		Response.Write "<br>"
	end if
	

End If

RS.Close
Set RS = Nothing


Conn.Close
Set Conn = Nothing




%>