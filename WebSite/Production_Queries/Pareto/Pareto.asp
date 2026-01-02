<%Option Explicit%>
<html>

<head>
<title>Pareto</title>
</head>

<body>

<h2 align="center">Pareto-type Information</h2>

<hr>

<p><%
	Dim Conn
	Dim RS
	Dim Query	
	Dim QueryStartDate
	Dim QueryEndDate
	Dim DisplayStart
	Dim DisplayEnd
	Dim Ctr
	Dim strPartNumber

	On Error Resume Next

	DisplayStart = Request("StartMonth") & "/" & Request("StartDay") & "/" & Request("StartYear")
	DisplayEnd   = Request("EndMonth")   & "/" & Request("EndDay")   & "/" & Request("EndYear")

	if DisplayStart = DisplayEnd then
		Response.Write "<center>" & DisplayStart & "</center><P>"
	else
		Response.Write "<center>" & DisplayStart & "&nbsp;&nbsp;&nbsp;" & "   To   " & "&nbsp;&nbsp;&nbsp;" & DisplayEnd & "</center><P>"
	end if

	QueryStartDate = "{ts '" &	Request("StartYear") & "-" 	& Request("StartMonth") & "-" &	Request("StartDay") & " 00:00:00'}"
	QueryEndDate   = "{ts '" & 	Request("EndYear")   & "-" & Request("EndMonth")    & "-" & 	Request("EndDay")   & " 23:59:59'}"


	Set Conn = Server.CreateObject("ADODB.Connection")

	Conn.Open Application("ProductionDatabase")

	Call Table_3

	Response.Write "<br><br><br><br>"
	
	Call Table_2

	Response.Write "<br><br><br><br>"
	Call Table_1


'------------------------------------------------------------------------------------------------------------------------
Sub Table_1

	Query = "SELECT Family, Category, Model, TestFailed, Count(TestFailed) As Count " & _
			 "FROM [Yield View] " & _
			 "WHERE (Seq = 1) AND " & _
			 "(Results = 0) AND " & _
			 "(StartTime BETWEEN " & QueryStartDate & " AND " & QueryEndDate & ") AND " & _
           "dcNFF = 0 " & _
			 "GROUP BY Family, Category, Model, TestFailed " & _
			 "ORDER BY Family, Category, Model, Count(TestFailed) DESC"

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

		Response.Write "<div align='center'><center>"

		Response.Write "<table BORDER='3.0' cellpadding='0' cellspacing='0'>"

		Response.Write "<tr>"
		For Ctr = 0 To RS.Fields.Count - 1
			Response.Write "<th>" & RS.Fields(Ctr).Name & "</th>"
		Next
		Response.Write "</tr>"
	
		strPartNumber = RS("Family") & RS("Category")	& RS("Model")	

		Do While Not RS.EOF

			'Separate different partnumbers for easier viewing.
			If strPartNumber <> RS("Family") & RS("Category")	& RS("Model") Then
				Response.Write "<tr><td bgcolor='#C0C0C0' colspan='5'>&nbsp;</td></tr>"
		 		Response.Write "<tr>"
				For Ctr = 0 To RS.Fields.Count - 1
					Response.Write "<th>" & RS.Fields(Ctr).Name & "</th>"
				Next
				Response.Write "</tr>"
			End If

			strPartNumber = RS("Family") & RS("Category")	& RS("Model")
		
		 
		Response.Write "<tr>"
				For Ctr = 0 To RS.Fields.Count - 1
					Response.Write "<td>" & RS.Fields(Ctr) & "</td>"
				Next
		Response.Write "</tr>"
		
		RS.MoveNext
	Loop
	
	Response.Write "</table>"
	Response.Write "</center>"	
End If

End Sub


'------------------------------------------------------------------------------------------------------------------------
Sub Table_2

	Query = "SELECT Family, Category, TestFailed, Count(TestFailed) As Count " & _
			 "FROM [Yield View] " & _
			 "WHERE (Seq = 1) AND " & _
			 "(Results = 0) AND " & _
			 "(StartTime BETWEEN " & QueryStartDate & " AND " & QueryEndDate & ") AND " & _
           "dcNFF = 0 " & _
			 "GROUP BY Family, Category, TestFailed " & _
			 "ORDER BY Family, Category, Count(TestFailed) DESC"



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

		Response.Write "<div align='center'><center>"

		Response.Write "<table BORDER='3.0' cellpadding='0' cellspacing='0'>"

		Response.Write "<tr>"
		For Ctr = 0 To RS.Fields.Count - 1
			Response.Write "<th>" & RS.Fields(Ctr).Name & "</th>"
		Next
		Response.Write "</tr>"
	
		strPartNumber = RS("Family") & RS("Category")

		Do While Not RS.EOF

			'Separate different partnumbers for easier viewing.
			If strPartNumber <> RS("Family") & RS("Category") Then
				Response.Write "<tr><td bgcolor='#C0C0C0' colspan='4'>&nbsp;</td></tr>"
		 		Response.Write "<tr>"
				For Ctr = 0 To RS.Fields.Count - 1
					Response.Write "<th>" & RS.Fields(Ctr).Name & "</th>"
				Next
				Response.Write "</tr>"
			End If

			strPartNumber = RS("Family") & RS("Category")
		
		 
		Response.Write "<tr>"
				For Ctr = 0 To RS.Fields.Count - 1
					Response.Write "<td>" & RS.Fields(Ctr) & "</td>"
				Next
		Response.Write "</tr>"
		
		RS.MoveNext
	Loop
	
	Response.Write "</table>"
	Response.Write "</center>"	
End If

End Sub


'------------------------------------------------------------------------------------------------------------------------
Sub Table_3

	Query = "SELECT Family, TestFailed, Count(TestFailed) As Count " & _
			 "FROM [Yield View] " & _
			 "WHERE (Seq = 1) AND " & _
			 "(Results = 0) AND " & _
			 "(StartTime BETWEEN " & QueryStartDate & " AND " & QueryEndDate & ") AND " & _
           "dcNFF = 0 " & _
			 "GROUP BY Family, TestFailed " & _
			 "ORDER BY Family, Count(TestFailed) DESC"


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

		Response.Write "<div align='center'><center>"

		Response.Write "<table BORDER='3.0' cellpadding='0' cellspacing='0'>"

		Response.Write "<tr>"
		For Ctr = 0 To RS.Fields.Count - 1
			Response.Write "<th>" & RS.Fields(Ctr).Name & "</th>"
		Next
		Response.Write "</tr>"
	
		strPartNumber = RS("Family") 	

		Do While Not RS.EOF

			'Separate different partnumbers for easier viewing.
			If strPartNumber <> RS("Family")  Then
				Response.Write "<tr><td bgcolor='#C0C0C0' colspan='3'>&nbsp;</td></tr>"
		 		Response.Write "<tr>"
				For Ctr = 0 To RS.Fields.Count - 1
					Response.Write "<th>" & RS.Fields(Ctr).Name & "</th>"
				Next
				Response.Write "</tr>"
			End If

			strPartNumber = RS("Family")
		
		 
		Response.Write "<tr>"
				For Ctr = 0 To RS.Fields.Count - 1
					Response.Write "<td>" & RS.Fields(Ctr) & "</td>"
				Next
		Response.Write "</tr>"
		
		RS.MoveNext
	Loop
	
	Response.Write "</table>"
	Response.Write "</center>"	
End If

End Sub
'------------------------------------------------------------------------------------------------------------------------



%> </p>
</body>
</html>
