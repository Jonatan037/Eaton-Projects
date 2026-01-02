<%Option Explicit%>
<html>

<head>
<title>Find Part Number</title>
</head>

<body>

<h2 align="center">Part Numbers That Have Been Tested</h2>

<p><br>
<%
	Dim strPartNumber

	On Error Resume Next

	strPartNumber = UCase(Request("frmPartNumber"))

	If strPartNumber = "" Then

		Response.Write "<center>"

		Response.Write "You can search for an unique Part number or use wild cards " & _
							"to search for group of records. (FA00AA% is valid.)<br><br>"

		
		Response.Write "<form method='POST' action='FindPartnumber.Asp'>"

			Response.Write "Please enter unit's Part number:<br>"
			Response.Write "<input type='text' name='frmPartNumber' size='20'><br>"
			Response.Write "<input type='submit' value='Submit' name='B1'>"
		Response.Write "</form>"
	
		Response.Write "</center>"
	
	Else
		GetRecord_1
		GetRecord_2
		GetRecord_3
	End If

%></p>
</body>
</html>
<%
Sub GetRecord_1()

	Dim Conn
	Dim RS
	Dim Query	
	Dim Ctr

	'--------------------------------------------------------------------------------------------------------
	'Create the desired query.
	Query = "SELECT * FROM Index WHERE PartNumber Like '" & strPartNumber & "%' ORDER BY PartNumber"
	'--------------------------------------------------------------------------------------------------------

	'Show the query for debug purposes.
	'Response.Write Query & "<p><br>"

	Set Conn = Server.CreateObject("ADODB.Connection")

	'Open the database defined in the Global.asa file.
	Conn.Open Application("ProductionDatabase")

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
	Response.Write "<table BORDER = '3.0', cellspacing='0' cellpadding='0'>"
	Response.Write "<caption>Ordered by part number</caption>"

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
					If RS.Fields(Ctr).Name = "StartTime" Then
						Response.Write "<td>" & FormatDateTime(RS.Fields(Ctr)) & "</td>"
					Else
						If IsNull(RS.Fields(Ctr)) Then
	      					Response.Write "<td> &nbsp; </td>"
						Else
							Response.Write "<td>" & RS.Fields(Ctr) & "</td>"
						End If
					End If
				Next
				Response.Write "</tr>"
		
			RS.MoveNext
		Loop
	
	Response.Write "</table>"
	Response.Write "</center>"	
	Response.Write "<br><br>"
End If

End Sub



Sub GetRecord_2()

	Dim Conn
	Dim RS
	Dim Query	
	Dim Ctr

	'--------------------------------------------------------------------------------------------------------
	'Create the desired query.
	Query = "SELECT * FROM Index WHERE PartNumber Like '" & strPartNumber & "%' ORDER BY SerialNumber, Seq"
	'--------------------------------------------------------------------------------------------------------

	'Show the query for debug purposes.
	'Response.Write Query & "<p><br>"

	Set Conn = Server.CreateObject("ADODB.Connection")

	'Open the database defined in the Global.asa file.
	Conn.Open Application("ProductionDatabase")

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
	Response.Write "<table BORDER = '3.0', cellspacing='0' cellpadding='0'>"
	Response.Write "<caption>Ordered by serial number</caption>"

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
					If RS.Fields(Ctr).Name = "StartTime" Then
						Response.Write "<td>" & FormatDateTime(RS.Fields(Ctr)) & "</td>"
					Else
						If IsNull(RS.Fields(Ctr)) Then
	      					Response.Write "<td> &nbsp; </td>"
						Else
							Response.Write "<td>" & RS.Fields(Ctr) & "</td>"
						End If
					End If
				Next
				Response.Write "</tr>"
		
			RS.MoveNext
		Loop
	
	Response.Write "</table>"
	Response.Write "</center>"	
	Response.Write "<br><br>"
End If

End Sub


Sub GetRecord_3()

	Dim Conn
	Dim RS
	Dim Query	
	Dim Ctr

	'--------------------------------------------------------------------------------------------------------
	'Create the desired query.
	Query = "SELECT * FROM Index WHERE PartNumber Like '" & strPartNumber & "%' ORDER BY StartTime"
	'--------------------------------------------------------------------------------------------------------

	'Show the query for debug purposes.
	'Response.Write Query & "<p><br>"

	Set Conn = Server.CreateObject("ADODB.Connection")

	'Open the database defined in the Global.asa file.
	Conn.Open Application("ProductionDatabase")

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
	Response.Write "<table BORDER = '3.0', cellspacing='0' cellpadding='0'>"
	Response.Write "<caption>Ordered by start time</caption>"

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
					If RS.Fields(Ctr).Name = "StartTime" Then
						Response.Write "<td>" & FormatDateTime(RS.Fields(Ctr)) & "</td>"
					Else
						If IsNull(RS.Fields(Ctr)) Then
	      					Response.Write "<td> &nbsp; </td>"
						Else
							Response.Write "<td>" & RS.Fields(Ctr) & "</td>"
						End If
					End If
				Next
				Response.Write "</tr>"
		
			RS.MoveNext
		Loop
	
	Response.Write "</table>"
	Response.Write "</center>"	
	Response.Write "<br><br>"
End If

End Sub



%>
