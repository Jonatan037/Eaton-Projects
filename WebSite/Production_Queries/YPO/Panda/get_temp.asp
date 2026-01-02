<%Option Explicit%>
<%Response.Buffer = TRUE%>
<% Response.Clear %>
<html>

<head>
<title>Panda Production Test Report</title>


</head>

<body>


<!-- #include File=..\\..\Tools\GenericTable.inc -->
<!-- #include File=..\\..\Tools\adovbs.inc -->


<%

	Dim Conn			'Database connection.
	Dim ConnectionString
	Dim Query


	ConnectionString = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=\\Youncsfp01\\DATA\Test-Eng\Panda\Database\Panda.mdb;Persist Security Info=False"

	Set Conn = Server.CreateObject("ADODB.Connection")

	'Open a connection to the global services database on server RDUPSDDB02
	Conn.Open ConnectionString



	Query = "SELECT UUT_SERIAL_NUMBER AS [LPD_SERIAL_NUMBER], ID FROM UUT_RESULT " & _
	        "ORDER BY 1"

	Query = "SELECT UUT_SERIAL_NUMBER AS [LPD_SERIAL_NUMBER], START_DATE_TIME, UUT_STATUS, ID FROM UUT_RESULT " & _
	        "ORDER BY 1,2"

	Query = "SELECT UUT_RESULT.UUT_SERIAL_NUMBER AS [LPD_SERIAL_NUMBER], UUT_INFO.STRING_VALUE AS [PQNA_SERIAL_NUMBER], UUT_RESULT.START_DATE_TIME, UUT_RESULT.UUT_STATUS, UUT_RESULT.ID " & _
	        "FROM UUT_RESULT INNER JOIN UUT_INFO ON UUT_RESULT.ID=UUT_INFO.UUT_RESULT " & _
	        "GROUP BY UUT_RESULT.UUT_SERIAL_NUMBER, UUT_INFO.STRING_VALUE, UUT_RESULT.START_DATE_TIME, UUT_RESULT.UUT_STATUS, UUT_RESULT.ID, UUT_INFO.STRING_NAME " & _
	        "HAVING (((UUT_INFO.STRING_NAME)='PQNA Serial Number')) " & _
            "ORDER BY 1, 2;"

	ShowTable Conn, Query
	Response.Write "<br><br><br>"



	'Process capability
	Query = "SELECT * FROM [get_process_capability_data]"


	'GenericTable Conn, Query


	'ShowProcessCapabilityData Conn


	Response.Write "<td><A HREF='get_process_capability_data.asp'>Get Process Capability Data</A></td>"

	Response.Write "<br>"

	Response.Write "<td><A HREF='get_process_capability_data_inverter_voltage.asp'>Inverter Voltage Capability Data</A></td>"

	Conn.Close
	Set Conn = Nothing


'------------------------------------------------------------------------------------------------------------------
Sub ShowProcessCapabilityData(dbConn)

	Dim RS
	Dim Query
	Dim Ctr

	Query = "SELECT * FROM [get_process_capability_data]"

	'Response.Write Query & "<p><br>"

	Set RS = dbConn.Execute(Query)

	' Check for error.
	If Err.Description <> "" Then
		Response.Write "<B>Error " + Hex(Err) + ": " + Err.Description + "</B><br>"

	' Check for no-record case.
	ElseIf RS.EOF And RS.BOF Then
		Response.Write "No records were found. <br>"

	' Valid data was received from the query.
	Else


		Response.Write "<table align='center' BORDER = '3.0' cellspacing='0' cellpadding='1'>"
		Response.Write "<caption>Process Capability Data</caption>"

		'Create the table header row.
  		Response.Write "<tr>"
			Response.Write "<th>Serial Number</th>"
			Response.Write "<th>Date</th>"
			Response.Write "<th>Test Step</th>"
			Response.Write "<th>Parameter Name</th>"
			Response.Write "<th>Low Limit</th>"
			Response.Write "<th>Data</th>"
			Response.Write "<th>High Limit</th>"
			Response.Write "<th>Status</th>"
			Response.Write "<th>Method</th>"
		Response.Write "</tr>"

		'Fill in the cells with data.
		Do While Not RS.EOF


			If RS("STEP_NAME") = "Out Vrms" Then

				For Ctr = 1 To 3

					Response.Write "<tr>"
					Response.Write "<td>" & RS("UUT_SERIAL_NUMBER") & "</td>"
					Response.Write "<td>" & RS("START_DATE_TIME") & "</td>"
					Response.Write "<td>" & RS("PARENT") & "</td>"
					Response.Write "<td>" & RS("STEP_NAME") & " L" & Ctr & "</td>"
					Response.Write "<td>" & RS("LOLIMIT") & "</td>"
					Response.Write "<td>" & RS("DMMVALUE" & Ctr ) & "</td>"
					Response.Write "<td>" & RS("HILIMIT") & "</td>"
					Response.Write "<td>" & RS("STATUS") & "</td>"
					Response.Write "<td>" & RS("COMP_OPERATOR") & "</td>"
					Response.Write "</tr>"

				Next

			Else

				Response.Write "<tr>"
				Response.Write "<td>" & RS("UUT_SERIAL_NUMBER") & "</td>"
				Response.Write "<td>" & RS("START_DATE_TIME") & "</td>"
				Response.Write "<td>" & RS("PARENT") & "</td>"
				Response.Write "<td>" & RS("STEP_NAME") & "</td>"
				Response.Write "<td>" & RS("LOLIMIT") & "</td>"
				Response.Write "<td>" & RS("DMMVALUE1") & "</td>"
				Response.Write "<td>" & RS("HILIMIT") & "</td>"
				Response.Write "<td>" & RS("STATUS") & "</td>"
				Response.Write "<td>" & RS("COMP_OPERATOR") & "</td>"
				Response.Write "</tr>"

			End If

			RS.MoveNext
		Loop

		Response.Write "</table>"


	End If

	RS.Close
	Set RS = Nothing

End Sub




'------------------------------------------------------------------------------------------------------------------
Sub ShowTable(dbConn, strQuery)

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

					ElseIf RS.Fields(Ctr).Name = "LPD_SERIAL_NUMBER" Then
						'Response.Write "<td><A HREF='get_temp_001.asp?ID=" & RS.Fields(Ctr) & "'>"  & RS.Fields(Ctr) & "</A></td>"
						Response.Write "<td><A HREF='get_panda_report_001.asp?ID=" & RS("ID") & "'>"  & RS.Fields(Ctr) & "</A></td>"
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