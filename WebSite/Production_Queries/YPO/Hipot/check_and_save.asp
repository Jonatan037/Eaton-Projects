<%Option Explicit%>
<html>

<head>
<title>Check and Save</title>
</head>

<body>

<h2 align="center">Hipot Verification Data</h2>

<%

	Dim SerialNumber
	Dim BadgeNumber
	Dim TestResults
	Dim Conn
	Dim rsEquipment

	'Get the log data sent by the calling form.
	SerialNumber = Request("SerialNumber")
	BadgeNumber  = Request("BadgeNumber")
	TestResults = Request("TestResults")


	If SerialNumber = "" Then
		Response.Write "You must enter a serial number."
		Response.End
	End If

	If BadgeNumber = "" Then
		Response.Write "You must enter a badge number."
		Response.End
	End If

	If TestResults = "" Then
		Response.Write "You must choose a Pass/Fail status."
		Response.End
	End If

	Response.Write "Serial number = " & SerialNumber & "<br>"
	Response.Write "Badge number = " & BadgeNumber & "<br>"
	Response.Write "Test result = " & TestResults & "<br>"


	'Verify that the SerialNumber is listed in the EQUIPMENT_LIST table.

	'Verify that the BadgeNumber is listed in the BADGE_NUMBERS table.

	'Save the log entry data to the VERIFICATION_LOG table.

	'Display a submissions status back to the user.


Set Conn = Server.CreateObject("ADODB.Connection")

Conn.ConnectionTimeout = 180	'Seconds

Conn.Open "Hipot"


get_equipment_data rsEquipment, "Select * From EQUIPMENT_LIST WHERE SERIAL_NUMBER = '" & SerialNumber & "'"


'GenericTable Conn, "Select * From EQUIPMENT_LIST WHERE SERIAL_NUMBER = '" & SerialNumber & "'"


rsEquipment.Close
Set rsEquipment = Nothing

Conn.Close
Set Conn = Nothing



Sub get_equipment_data(RS, strQuery)

	Set RS = Conn.Execute(strQuery)

	' Check for error.
	If Err.Description <> "" Then
		Response.Write "<B>Error " + Hex(Err) + ": " + Err.Description + "</B><br>"
		Response.End

	' Check for no-record case.
	ElseIf RS.EOF And RS.BOF Then
		Response.Write "No records were found. <br>"

	' Valid data was received from the query.
	Else

	End If

End Sub




Sub GenericTable(dbConn, strQuery)

	Dim RS
	Dim Ctr
	Dim RowCtr


	'Response.Write Query & "<p><br>"

	Set rs = dbConn.Execute(strQuery)

	' Check for error.
	If Err.Description <> "" Then
		Response.Write "<B>Error " + Hex(Err) + ": " + Err.Description + "</B><br>"

	' Check for no-record case.
	ElseIf RS.EOF And RS.BOF Then
		Response.Write "No records were found. <br>"

	' Valid data was received from the query.
	Else


	Response.Write "<table align='center' BORDER = '3.0' cellspacing='0' cellpadding='1'>"

		'Create the table header row.
  		Response.Write "<tr>"
			Response.Write "<th>Rows</th>"
			For Ctr = 0 To RS.Fields.Count - 1
				Response.Write "<th>" & RS.Fields(Ctr).Name & "</th>"
			Next
		Response.Write "</tr>"

		'Fill in the cells with data.
		Do While Not RS.EOF
			RowCtr = RowCtr + 1
			Response.Write "<tr>"
				Response.Write "<td>" & RowCtr & "</td>"
				For Ctr = 0 To RS.Fields.Count - 1

					If IsNull(RS.Fields(Ctr)) Then
						Response.Write "<td>&nbsp;</td>"

					ElseIf RS.Fields(Ctr).Name = "INDEXID" Then
						'Response.Write "<td><A HREF='get_empower_report.asp?ID=" & RS.Fields(Ctr) & "'>"  & RS.Fields(Ctr) & "</A></td>"
						Response.Write "<td><A HREF='TestReports\get_report_001_main.asp?ID=" & RS.Fields(Ctr) & "'>"  & RS.Fields(Ctr) & "</A></td>"
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
