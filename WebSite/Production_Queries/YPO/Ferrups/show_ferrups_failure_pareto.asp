<%Option Explicit%>
<%Response.Buffer = TRUE%>

<html>

<head>
<title>Ferrups Failure Pareto<</title>
</head>

<body>


<h2 align="center">FERRUPS Failure Pareto</h2>

<%

Dim Conn				'Database connection.
Dim Sql				'The query to be executed.

Dim DisplayStart
Dim DisplayEnd
Dim QueryStartDate
Dim QueryEndDate



'--------------------------------------------------------------------------------------------------------
'Put time in proper format.


DisplayStart = Request("StartMonth") & "/" & Request("StartDay") & "/" & Request("StartYear")
DisplayEnd   = Request("EndMonth")   & "/" & Request("EndDay")   & "/" & Request("EndYear")

if DisplayStart = DisplayEnd then
	Response.Write "<center>" & DisplayStart & "</center><P>"
else
	Response.Write "<center>" & DisplayStart & "&nbsp;&nbsp;&nbsp;" & "   To   " & "&nbsp;&nbsp;&nbsp;" & DisplayEnd & "</center><P>"
end if


QueryStartDate = "#" & Request("StartMonth") & "/" & Request("StartDay") & "/" & Request("StartYear") & "#"
QueryEndDate   = CDate(Request("EndMonth")   & "/" & Request("EndDay")   & "/" & Request("EndYear") ) + 1

QueryEndDate   = "#" & QueryEndDate & "#"


Set Conn = Server.CreateObject("ADODB.Connection")


Conn.Open "Ferrups"

Sql = "SELECT Category, TestFailed as [Test Step], Count(TestFailed) AS [Number of Failures]" & _
      "FROM [View - Failure Information] " & _
      "WHERE " & _
         "StartTime BETWEEN " & QueryStartDate & " AND " & QueryEndDate & " AND " & _
         "Seq = 1 AND " & _
         "Family = 'Ferrups' " & _
      "GROUP BY Category, TestFailed " & _
      "ORDER BY 1, 3 DESC"


ShowTable1 Conn, Sql, "Display by UPS Category"
Response.Write "<br><br><br>"


Sql = "SELECT Category, Model, TestFailed as [Test Step], Count(TestFailed) AS [Number of Failures]" & _
      "FROM [View - Failure Information] " & _
      "WHERE " & _
         "StartTime BETWEEN " & QueryStartDate & " AND " & QueryEndDate & " AND " & _
         "Seq = 1 AND " & _
         "Family = 'Ferrups' " & _
      "GROUP BY Category, Model, TestFailed " & _
      "ORDER BY 1, 2, 4 DESC"


ShowTable2 Conn, Sql, "Display by UPS Category and Model"
Response.Write "<br><br><br>"


Conn.Close
Set Conn = Nothing



'--------------------------------------------------------------------------------------------------------
Sub ShowTable1(dbConn, strQuery, strCaption)

	Dim RS
	Dim Ctr
	Dim Category

	'Response.Write strQuery & "<p><br>"
	'Response.end

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
		Response.Write "<caption>" & strCaption & "</caption>"

		'Create the table header row.
  		Response.Write "<tr>"
			For Ctr = 0 To RS.Fields.Count - 1
				Response.Write "<th>" & RS.Fields(Ctr).Name & "</th>"
			Next
		Response.Write "</tr>"

		Category = RS("Category")

		'Fill in the cells with data.
		Do While Not RS.EOF

			If RS("Category") <> Category Then
				Response.Write "<tr><td bgcolor='#C0C0C0' colspan='3'>&nbsp;</td></tr>"
				Category = RS("Category")
			End If

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


'--------------------------------------------------------------------------------------------------------
Sub ShowTable2(dbConn, strQuery, strCaption)

	Dim RS
	Dim Ctr
	Dim Category
	Dim Model

	'Response.Write strQuery & "<p><br>"
	'Response.end

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
		Response.Write "<caption>" & strCaption & "</caption>"

		'Create the table header row.
  		Response.Write "<tr>"
			For Ctr = 0 To RS.Fields.Count - 1
				Response.Write "<th>" & RS.Fields(Ctr).Name & "</th>"
			Next
		Response.Write "</tr>"

		Category = RS("Category")
		Model = RS("Model")

		'Fill in the cells with data.
		Do While Not RS.EOF

			If ( RS("Category") <> Category ) OR ( RS("Model") <> Model ) Then
				Response.Write "<tr><td bgcolor='#C0C0C0' colspan='4'>&nbsp;</td></tr>"
				Category = RS("Category")
				Model = RS("Model")
			End If

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
