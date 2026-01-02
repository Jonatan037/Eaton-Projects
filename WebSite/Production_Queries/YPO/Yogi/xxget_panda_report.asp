<%Option Explicit%>
<%Response.Buffer = TRUE%>
<% Response.Clear %>
<html>

<head>
<title>Panda</title>


<STYLE TYPE="text/css">
<!--
TD{font-family: Arial; font-size: 10pt;}
--->
</STYLE>

</head>

<body>

<!-- #include File=..\\..\Tools\adovbs.inc -->


<%

	Dim Conn			'Database connection.
	Dim ConnectionString
	Dim Query
	Dim ID_UUT_RESULT
	Dim ID_UUT_RESULT_TEMP

	Dim lIndexId			'The INDEXID from the ypo database.
	Dim lResultsID			'The ResultsID from the ypo database.
	Dim rs
	Dim strStartingStep		'The entry point to use in generating the report.


	Set Conn = Server.CreateObject("ADODB.Connection")

	'Path to the Panda database.
	ConnectionString = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=\\Youncsfp01\\DATA\Test-Eng\Panda\Database\Panda.mdb;Persist Security Info=False"

	'If this page was called with an INDEXID from the ypo database, then get the GUID.
	If Left(Request("ID"),1) <> "{" Then

		Conn.Open Application("QDMS")

		lIndexId = Request("ID")

		Set rs = Conn.Execute("SELECT ResultsID FROM qdms_master_index WHERE INDEXID = " & lIndexId)

		lResultsID = rs("ResultsID")

		rs.Close
		Conn.Close

		'If this is a unit that was tested prior to the database crash, then use the old database.
		If lResultsID <= 1292 then
			ConnectionString = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=\\Youncsfp01\\DATA\Test-Eng\Panda\Database\Archive\Panda.006.crashed.mdb;Persist Security Info=False"
		
                ElseIf lResultsID <= 2295 then
			ConnectionString = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=\\Youncsfp01\\DATA\Test-Eng\Panda\Database\Archive\Panda.010.crashed.mdb;Persist Security Info=False"

		Else
			ConnectionString = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=\\Youncsfp01\\DATA\Test-Eng\Panda\Database\Panda.mdb;Persist Security Info=False"
		End If

		'Open a connection to the Panda database.
		Conn.Open ConnectionString

		Set rs = Conn.Execute("SELECT ID FROM UUT_RESULT WHERE DATADOG_ID = " & lResultsID)

		ID_UUT_RESULT = "{guid " & rs("ID") & "}"

		rs.Close
		Conn.Close

	Else
		ID_UUT_RESULT = "{guid " & Request("ID") & "}"
	End If



	'Open a connection to the Panda database.
	Conn.Open ConnectionString


	'Response.Write "Some examples of possible test reports<br><br>"


	ShowHeader
	Response.Write "<hr>"

	'Show the UL Prompts
	Show_UL_Prompts ID_UUT_RESULT


	DetermineStartingStep strStartingStep

	ShowMainSequenceSteps strStartingStep
	'ShowMainSequenceSteps
	Response.Write "<hr>"

	'ShowMainSequenceAndSubSteps
	ShowMainSequenceAndSubSteps strStartingStep

	Conn.Close
	Set Conn = Nothing


'------------------------------------------------------------------------------------------------------------
Sub Show_UL_Prompts (ID_UUT_RESULT)


	Dim rs
	Dim query
	Dim caption
	Dim ul_seq_id


	caption = "UL Documentation<br>&nbsp;<br>"

	'Find the ID of the sequence that contains the UL documentation.
	query = "SELECT ID FROM STEP_RESULT WHERE UUT_RESULT = " & ID_UUT_RESULT & " AND STEP_NAME = 'Show UL Prompts' "
	
	Set rs = Conn.Execute(query)

	' Check for error.
	If Err.Description <> "" Then
		Response.Write "Error in Show_UL_Prompts<br>"

	' Check for no-record case.
	ElseIf rs.EOF And rs.BOF Then
		Response.Write "Unable to locate the UL Prompts section<br>"

	' Valid data was received from the query.
	Else
		ul_seq_id = "{guid " & rs("ID") & "}"

		query = "SELECT * FROM STEP_RESULT WHERE STEP_PARENT = " & ul_seq_id & " ORDER BY ORDER_NUMBER"

		Set rs = Conn.Execute(query)
		
		Response.Write caption
		Response.Write "<table  BORDER = '0.0' cellspacing='0' cellpadding='1'>"


		Do While Not RS.EOF

			Response.Write "<tr>"
				Response.Write "<td>" & RS("STEP_NAME") & "&nbsp;</td>"
				Response.Write "<td>" & RS("STATUS") & "&nbsp;</td>"
			Response.Write "</tr>"


			RS.MoveNext
		Loop

		Response.Write "</table>"



		Response.Write "<br><hr>"

	End If


	'Clean up.
	rs.Close
	Set rs = Nothing




End Sub

'------------------------------------------------------------------------------------------------------------
Sub DetermineStartingStep(strStartingStep)

	Dim RS
	Dim Query

	Query = "SELECT STEP_NAME FROM STEP_RESULT " & _
	        "WHERE " & _
	           "UUT_RESULT = " & ID_UUT_RESULT & " AND " & _
	           "(STEP_NAME = '60kVA Full Test' OR STEP_NAME = '30kVA Full Test') "

	Query = "SELECT STEP_NAME FROM STEP_RESULT " & _
	        "WHERE " & _
	           "UUT_RESULT = " & ID_UUT_RESULT & " AND " & _
	           "(STEP_NAME = '30kVA Full Test' OR STEP_NAME = '60kVA Full Test' ) AND " & _
	           "STATUS <> 'Skipped' "


	Set RS = Conn.Execute(Query)

	' Check for error.
	If Err.Description <> "" Then
		strStartingStep "MainSequence Callback"

	' Check for no-record case.
	ElseIf RS.EOF And RS.BOF Then
		strStartingStep = "MainSequence Callback"

	' Valid data was received from the query.
	Else

		strStartingStep = RS("STEP_NAME")


	End If

	RS.Close
	Set RS = Nothing

	'Response.Write "In DetermineStartingStep: STEP_NAME = " & strStartingStep & "<br>"

End Sub


'------------------------------------------------------------------------------------------------------------
Sub ShowHeader()

	Dim RS
	Dim Query


	Query = "SELECT R.*, I.* " & _
			"FROM UUT_RESULT AS R LEFT JOIN UUT_INFO AS I " & _
	        "ON R.ID = I.UUT_RESULT " & _
	        "WHERE R.ID = " & ID_UUT_RESULT


	'Response.Write Query & "<p><br>"

	Set RS = Conn.Execute(Query)

	' Check for error.
	If Err.Description <> "" Then
		Response.Write "<B>Error " + Hex(Err) + ": " + Err.Description + "</B><br>"

	' Check for no-record case.
	ElseIf RS.EOF And RS.BOF Then
		Response.Write "No records were found. <br>"

	' Valid data was received from the query.
	Else


		Response.Write "<table BORDER = '0.0' cellspacing='3' cellpadding='1'>"


		'Response.Write "<tr><td></td><td></td></tr>"
		Response.Write "<tr><td>Status:</td><td>" & RS("UUT_STATUS") & "&nbsp;</td></tr>"
		Response.Write "<tr><td>Date/Time:</td><td>" & RS("START_DATE_TIME") & "&nbsp;</td></tr>"
		Response.Write "<tr><td>Station ID:</td><td>" & RS("STATION_ID") & "&nbsp;</td></tr>"
		Response.Write "<tr><td>LPD Serial Number:</td><td>" & RS("UUT_SERIAL_NUMBER") & "&nbsp;</td></tr>"


		Do While Not RS.EOF

			Response.Write "<tr><td>" & RS("STRING_NAME") & ":&nbsp;&nbsp;</td><td>" & RS("STRING_VALUE") & "&nbsp;</td></tr>"

			RS.MoveNext
		Loop

		Response.Write "</table>"

	End If

	RS.Close
	Set RS = Nothing


	Response.Write "<br><br>"

End Sub



'------------------------------------------------------------------------------------------------------------
Sub ShowMainSequenceSteps(strStartingStep)

	Dim RS
	Dim Query
	Dim strCaption
	Dim ID_STEP_RESULT

	strCaption = "Summary<br>&nbsp;<br>"


	Query = "SELECT " & _
	           "T1.STEP_NAME, " & _
	           "T1.STATUS " & _
	        "FROM STEP_RESULT AS T1 INNER JOIN STEP_RESULT AS T2 ON T1.STEP_PARENT = T2.ID " & _
	        "WHERE " & _
	           "T1.UUT_RESULT = " & ID_UUT_RESULT & " AND " & _
	           "T2.STEP_NAME = 'MainSequence Callback' AND " & _
	           "T1.STEP_GROUP = 'Main' AND " & _
	           "T1.STEP_TYPE = 'PW_SequenceCall' AND " & _
	           "T1.STATUS <> 'Skipped' " & _
	        "ORDER BY T1.ORDER_NUMBER"



	Query = "SELECT " & _
	           "T1.STEP_NAME, " & _
	           "T1.STATUS " & _
	        "FROM STEP_RESULT AS T1 INNER JOIN STEP_RESULT AS T2 ON T1.STEP_PARENT = T2.ID " & _
	        "WHERE " & _
	           "T1.UUT_RESULT = " & ID_UUT_RESULT & " AND " & _
	           "T2.STEP_NAME = 'MainSequence Callback' AND " & _
	           "T1.STEP_GROUP = 'Main' AND " & _
	           "T1.STEP_TYPE = 'PW_SequenceCall' AND " & _
	           "INSTR('Skipped Done', T1.STATUS) <= 0 " & _
	        "ORDER BY T1.ORDER_NUMBER"


	Query = "SELECT " & _
	           "T1.STEP_NAME, " & _
	           "T1.STATUS " & _
	        "FROM STEP_RESULT AS T1 INNER JOIN STEP_RESULT AS T2 ON T1.STEP_PARENT = T2.ID " & _
	        "WHERE " & _
	           "T1.UUT_RESULT = " & ID_UUT_RESULT & " AND " & _
	           "T2.STEP_NAME = '" & strStartingStep & "' AND " & _
	           "T1.STEP_GROUP = 'Main' AND " & _
	           "INSTR('Skipped Done', T1.STATUS) <= 0 " & _
	        "ORDER BY T1.ORDER_NUMBER"




	Set RS = Conn.Execute(Query)


	' Check for error.
	If Err.Description <> "" Then
		Response.Write "<B>Error " + Hex(Err) + ": " + Err.Description + "</B><br>"

	' Check for no-record case.
	ElseIf RS.EOF And RS.BOF Then
		Response.Write "No records were found. <br>"


	' Valid data was received from the query.
	Else

		Response.Write strCaption
		Response.Write "<table  BORDER = '0.0' cellspacing='0' cellpadding='1'>"
		'Response.Write "<caption>" & strCaption & "</caption>"


		Do While Not RS.EOF

			Response.Write "<tr>"
				Response.Write "<td>" & RS("STEP_NAME") & "&nbsp;</td>"
				Response.Write "<td>" & RS("STATUS") & "&nbsp;</td>"
			Response.Write "</tr>"


			RS.MoveNext
		Loop

		Response.Write "</table>"

	End If

	RS.Close
	Set RS = Nothing


	Response.Write "<br><br>"



End Sub



'------------------------------------------------------------------------------------------------------------
Sub ShowMainSequenceAndSubSteps(strStartingStep)

	Dim RS
	Dim Query
	Dim strCaption
	Dim ID_STEP_RESULT

	strCaption = "Details<br>&nbsp;<br>"



	Query = "SELECT " & _
	           "T1.STEP_NAME, " & _
	           "T1.STATUS, " & _
	           "T1.ID " & _
	        "FROM STEP_RESULT AS T1 INNER JOIN STEP_RESULT AS T2 ON T1.STEP_PARENT = T2.ID " & _
	        "WHERE " & _
	           "T1.UUT_RESULT = " & ID_UUT_RESULT & " AND " & _
	           "T2.STEP_NAME = 'MainSequence Callback' AND " & _
	           "T1.STEP_GROUP = 'Main' AND " & _
	           "T1.STEP_TYPE = 'PW_SequenceCall' AND " & _
	           "T1.STATUS <> 'Skipped' " & _
	        "ORDER BY T1.ORDER_NUMBER"

	Query = "SELECT " & _
	           "T1.STEP_NAME, " & _
	           "T1.STATUS, " & _
	           "T1.ID " & _
	        "FROM STEP_RESULT AS T1 INNER JOIN STEP_RESULT AS T2 ON T1.STEP_PARENT = T2.ID " & _
	        "WHERE " & _
	           "T1.UUT_RESULT = " & ID_UUT_RESULT & " AND " & _
	           "T2.STEP_NAME = 'MainSequence Callback' AND " & _
	           "T1.STEP_GROUP = 'Main' AND " & _
	           "T1.STEP_TYPE = 'PW_SequenceCall' AND " & _
	           "INSTR('Skipped Done', T1.STATUS) <= 0 " & _
	        "ORDER BY T1.ORDER_NUMBER"


	Query = "SELECT " & _
	           "T1.STEP_NAME, " & _
	           "T1.STATUS, " & _
	           "T1.ID " & _
	        "FROM STEP_RESULT AS T1 INNER JOIN STEP_RESULT AS T2 ON T1.STEP_PARENT = T2.ID " & _
	        "WHERE " & _
	           "T1.UUT_RESULT = " & ID_UUT_RESULT & " AND " & _
	           "T2.STEP_NAME = '" & strStartingStep & "' AND " & _
	           "T1.STEP_GROUP = 'Main' AND " & _
	           "INSTR('Skipped Done', T1.STATUS) <= 0 " & _
	        "ORDER BY T1.ORDER_NUMBER"




	Set RS = Conn.Execute(Query)


	' Check for error.
	If Err.Description <> "" Then
		Response.Write "<B>Error " + Hex(Err) + ": " + Err.Description + "</B><br>"

	' Check for no-record case.
	ElseIf RS.EOF And RS.BOF Then
		Response.Write "No records were found. <br>"


	' Valid data was received from the query.
	Else

		Response.Write strCaption
		Response.Write "<table  BORDER = '0.0' cellspacing='0' cellpadding='1'>"
		'Response.Write "<caption>" & strCaption & "</caption>"


		Do While Not RS.EOF

			ID_STEP_RESULT = "{guid " & RS("ID") & "}"


			Response.Write "<tr>"
				Response.Write "<td colspan = 4>" & RS("STEP_NAME") & "</td>"
			Response.Write "</tr>"

			IF RS("STEP_NAME") = "Initialize EEPROM Values" Then

			Else

				ShowSubSteps ID_STEP_RESULT
			End If

			Response.Write "<tr>"
				Response.Write "<td colspan = 4>&nbsp;</td>"
			Response.Write "</tr>"

			RS.MoveNext
		Loop

		Response.Write "</table>"

	End If

	RS.Close
	Set RS = Nothing


	Response.Write "<br><br>"



End Sub


'------------------------------------------------------------------------------------------------------------
Sub ShowSubSteps(ID)

	Dim RS
	Dim Query


	Query = "SELECT " & _
	           "T1.STEP_NAME, " & _
	           "T1.STATUS, " & _
	           "T1.REPORT_TEXT " & _
	        "FROM STEP_RESULT AS T1 " & _
	        "WHERE " & _
	           "T1.STEP_PARENT = " & ID & " AND " & _
	           "INSTR('Skipped Done', T1.STATUS) <= 0 " & _
	        "ORDER BY T1.ORDER_NUMBER"


	Set RS = Conn.Execute(Query)


	' Check for error.
	If Err.Description <> "" Then
		Response.Write "<B>Error " + Hex(Err) + ": " + Err.Description + "</B><br>"

	' Check for no-record case.
	ElseIf RS.EOF And RS.BOF Then
		'Response.Write "No records were found. <br>"
		'Response.Write Query & "<br>&nbsp;<br>"

	' Valid data was received from the query.
	Else

		Do While Not RS.EOF


			Response.Write "<tr>"
				Response.Write "<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>"
				Response.Write "<td>" & RS("STEP_NAME") & "&nbsp;&nbsp;&nbsp;</td>"
				Response.Write "<td>" & RS("STATUS") & "&nbsp;&nbsp;&nbsp;</td>"
				Response.Write "<td>" & RS("REPORT_TEXT") & "&nbsp;</td>"
			Response.Write "</tr>"


			RS.MoveNext
		Loop


	End If

	RS.Close
	Set RS = Nothing


End Sub



'------------------------------------------------------------------------------------------------------------
Sub GenericTable(dbConn, strQuery, strCaption)

	Dim RS
	Dim Ctr
	Dim RowCtr


	'Response.Write Query & "<p><br>"

	Set RS = dbConn.Execute(strQuery)

	' Check for error.
	If Err.Description <> "" Then
		Response.Write "<B>Error " + Hex(Err) + ": " + Err.Description + "</B><br>"

	' Check for no-record case.
	ElseIf RS.EOF And RS.BOF Then
		Response.Write "No records were found. <br>"

	' Valid data was received from the query.
	Else


		Response.Write "<table  BORDER = '0.0' cellspacing='0' cellpadding='1'>"
		Response.Write "<caption>" & strCaption & "</caption>"

		'Create the table header row.
  		Response.Write "<tr>"
			For Ctr = 0 To RS.Fields.Count - 1
				Response.Write "<th>" & RS.Fields(Ctr).Name & "</th>"
			Next
		Response.Write "</tr>"

		'Fill in the cells with data.
		Do While Not RS.EOF
			Response.Write "<tr>"
				For Ctr = 0 To RS.Fields.Count - 1
					If IsNull(RS.Fields(Ctr)) Then
						Response.Write "<td>&nbsp;</td>"

					Else
							Response.Write "<td>" & RS.Fields(Ctr) & "</td>"
					End If
				Next
				Response.Write "</tr>"

			RS.MoveNext
		Loop

		Response.Write "</table>"
		Response.Write "</center>"

	End If

	RS.Close
	Set RS = Nothing

End Sub



%>
</body>
</html>
