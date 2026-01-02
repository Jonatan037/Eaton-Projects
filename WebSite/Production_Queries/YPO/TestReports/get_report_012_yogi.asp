<%Option Explicit%>
<%Response.Buffer = TRUE%>
<% Response.Clear %>
<html>

<head>
<title>YOGI Test Report</title>


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
Dim Conn			'CPO Battery database connection
Dim Sql				'The query to be executed.

Dim lIndexID
Dim lResultsID
Dim strConnection
Dim strSerialNumber
Dim fld
Dim rs
Dim ID_UUT_RESULT		'GUID
Dim strStartingStep		'The entry point to use in generating the report.
Dim uut_string_name
Dim uut_string_value


lIndexID = Request("ID")


On Error Resume Next

'Create connection objects.
Set qdmsConn = Server.CreateObject("ADODB.Connection")
Set Conn = Server.CreateObject("ADODB.Connection")


'Conn.ConnectionTimeout = 90
qdmsConn.Open Application("QDMS")


'Get search infor from the QDMS database.
Set rs = qdmsConn.Execute("SELECT I.ResultsID, I.SerialNumber, D.ConnectionString FROM qdms_master_index AS I INNER JOIN qdms_database_ids as D ON I.DBID = D.DBID WHERE INDEXID = " & lIndexId)


'temporary while developing report.
'Set rs = qdmsConn.Execute("SELECT ConnectionString, 12 AS [ResultsID] FROM qdms_database_ids WHERE DBID = 43")



'Assign values from the database to local variables.
lResultsID = rs("ResultsID")
strConnection = rs("ConnectionString")



'Close the recordset and the QDMS connection.
rs.Close
Set rs = Nothing
qdmsConn.Close


'Show any error that might have occurred up to this point.
If Err.Description <> "" Then 
   Response.Write "Error : " + Err.Description + "<br>"
   Response.End
End If




'Open connection to the battery database.
Conn.Open strConnection


Set rs = Conn.Execute("SELECT ID FROM UUT_RESULT WHERE DATADOG_ID = " & lResultsID)

ID_UUT_RESULT = "{guid " & rs("ID") & "}"

rs.Close


'response.write ID_UUT_RESULT & "<br>"

'Show any error that occurred with opening the databae.
If Err.Description <> "" Then 
   Response.Write "Error : " + Err.Description + "<br>" & strConnection
   Response.End
End If

ShowHeader
Response.Write "<hr>"

'Show the UL Prompts
'Show_UL_Prompts ID_UUT_RESULT


DetermineStartingStep strStartingStep

ShowMainSequenceSteps strStartingStep
Response.Write "<hr>"


ShowMainSequenceAndSubSteps strStartingStep


Conn.Close
Set Conn = Nothing



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
		'Response.Write "<tr><td>Station ID:</td><td>" & RS("STATION_ID") & "&nbsp;</td></tr>"
		Response.Write "<tr><td>Serial Number:</td><td>" & RS("UUT_SERIAL_NUMBER") & "&nbsp;</td></tr>"


		Do While Not RS.EOF

			uut_string_name = RS("STRING_NAME")
			uut_string_value = RS("STRING_VALUE")

			'Fix typos
			uut_string_name = Replace(uut_string_name, "Numberr", "Number")

			Response.Write "<tr><td>" & uut_string_name & ":&nbsp;&nbsp;</td><td>" & uut_string_value & "&nbsp;</td></tr>"

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