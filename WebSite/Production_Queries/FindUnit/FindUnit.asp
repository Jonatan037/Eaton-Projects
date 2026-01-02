<%Option Explicit%>
<html>

<head>

<title>Find Unit Record</title>


<body>

<h2 align="center">Find Unit Record</h2>
<hr>

<%
	Dim strSerialNumber

	On Error Resume Next

	strSerialNumber = UCase(Request("frmSerialNumber"))

	If strSerialNumber = "" Then

		Response.Write "<center>"

		Response.Write "You can search for an unique serial number or use wild cards " & _
							"to search for group of records. (GR163A01% is valid.)<br><br>"

		
		Response.Write "<form method='POST' action='FindUnit.Asp'>"

			Response.Write "Please enter unit's serial number:<br>"
			Response.Write "<input type='text' name='frmSerialNumber' size='20'><br>"
			Response.Write "<input type='submit' value='Submit' name='B1'>"
		Response.Write "</form>"
	
		Response.Write "</center>"
	
	Else
		GetRecord
	End If

%>
<!--mstheme--></font></body>
</html>
<%
Sub GetRecord()

	Dim Conn
	Dim RS
	Dim Query	
	Dim Ctr

	'--------------------------------------------------------------------------------------------------------
	'Create the desired query.
	Query = "SELECT " & _
				"I.ID, " & _
				"I.SerialNumber, " & _
				"I.PartNumber, " & _
				"I.StartTime, " & _
				"I.Seq, " & _
				"I.Results, " & _
				"I.Workcell, " & _
				"I.Badge, " & _
				"F.TestFailed, " & _
				"F.FailureDescription " & _

			 "FROM " & _
				"Index AS I LEFT JOIN FailureInformation AS F ON " & _
			 		"(I.SerialNumber Like '" & strSerialNumber & "%' AND I.ID = F.ID) " & _

		 	 "ORDER BY I.SerialNumber, I.StartTime"
	'--------------------------------------------------------------------------------------------------------

	'Show the query for debug purposes.
	Response.Write Query & "<p><br>"

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
End If

End Sub
%>
