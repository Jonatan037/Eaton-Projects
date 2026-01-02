<%Option Explicit%>
<html>

<head>
<title>Test Logs</title>
</head>

<body>

<h2 align="center">Test Logs</h2>

<hr align="center">

<p><%
	Dim Conn
	Dim RS
	Dim Query1
	Dim Query2	
	Dim QueryStartDate
	Dim QueryEndDate
	Dim DisplayStart
	Dim DisplayEnd
	Dim Ctr
	Dim RowCtr
	Dim rsWorkcell


	On Error Resume Next

	'Format the time for display.
	DisplayStart = Request("StartMonth") & "/" & Request("StartDay") & "/" & Request("StartYear")
	DisplayEnd   = Request("EndMonth")   & "/" & Request("EndDay")   & "/" & Request("EndYear")

	'Show query date.
	if DisplayStart = DisplayEnd then
		Response.Write "<center>" & DisplayStart & "</center><P>"
	else
		Response.Write "<center>" & DisplayStart & "&nbsp;&nbsp;&nbsp;" & "   To   " & "&nbsp;&nbsp;&nbsp;" & DisplayEnd & "</center><P>"
	end if

	'Create time stamp for use in query.
	QueryStartDate = "{ts '" &	Request("StartYear") & "-" 	& Request("StartMonth") & "-" &	Request("StartDay") & " 00:00:00'}"
	QueryEndDate   = "{ts '" & 	Request("EndYear")   & "-" & Request("EndMonth")    & "-" & 	Request("EndDay")   & " 23:59:59'}"



	'--------------------------------------------------------------------------------------------------------
	'Get workcell names.
	Query1 = "SELECT Distinct Workcell " & _
			 "FROM Index " & _
			 "WHERE (StartTime BETWEEN " & QueryStartDate & " AND " & QueryEndDate & ")"


	'Show the query for debug purposes.
	'Response.Write Query1 & "<p><br>"

	'--------------------------------------------------------------------------------------------------------


	Set Conn = Server.CreateObject("ADODB.Connection")

	'Open the database defined in the Global.asa file.
	Conn.Open Application("ProductionDatabase")

	Set rsWorkcell = Conn.Execute(Query1)

	' Check for error.
	If Err.Description <> "" Then
		Response.Write "<B>Error " + Hex(Err) + ": " + Err.Description + "</B><br>"

	' Check for no-record case.
	ElseIf rsWorkcell.EOF And rsWorkcell.BOF Then 
		Response.Write "No records were found. <br>"

	' Valid data was received from the query.
	Else


Do While Not rsWorkcell.EOF


	'Get the test logs.
	Query2 = "SELECT " & _
					"I.StartTime, " & _
					"I.SerialNumber, " & _
					"I.PartNumber, " & _
					"I.Results, " & _
					"I.Badge, " & _
					"I.Seq, " & _
					"(I.StopTime - I.StartTime) * 1440 As TestTime, " & _
					"F.TestFailed, " & _
					"F.FailureDescription " & _

			"FROM Index AS I LEFT JOIN FailureInformation AS F ON " & _
			"( " & _ 
				"I.Workcell = '" & rsWorkCell("Workcell") & "' AND " & _
				"I.ID = F.ID AND " & _
				"(I.StartTime BETWEEN " & QueryStartDate & " AND " & QueryEndDate & ") " & _
			") " & _

			 "ORDER BY I.StartTime"

	'Response.Write Query2 & "<p><br>"


	Set RS = Conn.Execute(Query2)

	RowCtr = 0


	'Show the name of the test station.
	Response.Write "<h2 align='center'> Test Log for " & rsWorkcell("Workcell") & "</h2>"

	Response.Write "<div align='center'><center>"
	Response.Write "<table BORDER = '3.0' cellspacing='0' cellpadding='0'>"

		'Create the table header row.
  		Response.Write "<tr>"
			Response.Write "<th>Count</th>"
			For Ctr = 0 To RS.Fields.Count - 1
				Response.Write "<th>" & RS.Fields(Ctr).Name & "</th>"
			Next
		Response.Write "</tr>"

		'Fill in the cells with data.
		Do While Not RS.EOF
			Response.Write "<tr>"
				RowCtr = RowCtr + 1
				Response.Write "<td>" & RowCtr & "</td>"
		
				For Ctr = 0 To RS.Fields.Count - 1
					If RS.Fields(Ctr).Name = "TestTime" Then
						Response.Write "<td>" & FormatNumber(RS.Fields(Ctr)) & "</td>"

					ElseIf RS.Fields(Ctr).Name = "StartTime" Then
						Response.Write "<td>" & FormatDateTime(RS.Fields(Ctr)) & "</td>"

					Else
						If IsNull(RS.Fields(Ctr)) Then
		 	   				Response.Write "<td>&nbsp;</td>"
						Else
	 	   					Response.Write "<td>" & RS.Fields(Ctr) & "</td>"
						End If
					End if
				Next
				
				Response.Write "</tr>"
		
			RS.MoveNext
		Loop
	
	Response.Write "</table>"
	Response.Write "</center>"	

	Response.Write "<br><br>"


rsWorkcell.MoveNext

Loop


	Response.Write "Results Field:   1 = Passed, 0 = Failed <br>"
	Response.Write "Seq Field:  Number of times that a particular unit has been tested. <br>"
	Response.Write "TestTime Field:   Times are in minutes. <br>"
End If
%> </p>
</body>
</html>
