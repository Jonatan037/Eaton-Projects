<%Option Explicit%>
<html>

<head>
<meta name="GENERATOR" content="Microsoft FrontPage 3.0">
<title>A Query</title>

<meta name="Microsoft Theme" content="indust 101">
</head>

<body background="../_themes/indust/indtextb.jpg" bgcolor="#FFFFFF" text="#000000" link="#3366CC" vlink="#666666" alink="#FF3300"><!--mstheme--><font face="Trebuchet MS, Arial, Helvetica">

<h2 align="center"><!--mstheme--><font color="#CC6666">Find All Unit Data<!--mstheme--></font></h2>

<!--msthemeseparator--><p align="center"><img src="../_themes/indust/indhorsd.gif" width="300" height="10"></p>
<%
'---------------------------------------------------------------------------------------------------------------------------------------------
	Dim Conn
	Dim strSerialNumber
	Dim strTableName


	On Error Resume Next

	strSerialNumber = UCase(Request("frmSerialNumber"))

	If strSerialNumber = "" Then

		Response.Write "<center>"

		Response.Write "You can search for an unique serial number only. Wild cards are NOT allowed.<br>"
		Response.Write "This query will return all of the data for a unit.<br><br>"

		
		Response.Write "<form method='POST' action='FindAllUnitData.Asp'>"

			Response.Write "Please enter unit's serial number:<br>"
			Response.Write "<input type='text' name='frmSerialNumber' size='20'><br>"
			Response.Write "<input type='submit' value='Submit' name='B1'>"
		Response.Write "</form>"
	
		Response.Write "</center>"
	
	Else

		Set Conn = Server.CreateObject("ADODB.Connection")
		Conn.Open Application("ProductionDatabase")

		GetTableName strSerialNumber, strTableName
		GetRecord strTableName
	End If

%>
<!--mstheme--></font></body>
</html>
<%
'---------------------------------------------------------------------------------------------------------------------------------------------
Sub GetRecord(TableName)

	Dim RS
	Dim Query	
	Dim Ctr

	'--------------------------------------------------------------------------------------------------------
	'Create the desired query.
	Query = "SELECT I.*, F.*, P.* " & _

			 "FROM " & _
				"(Index AS I LEFT JOIN FailureInformation AS F " & _
			 		"ON (I.SerialNumber = '" & strSerialNumber & "' AND I.ID = F.ID) ) " & _
					"LEFT JOIN " & TableName & " AS P ON I.ID = P.ID " & _
					"ORDER BY I.Seq"

	'--------------------------------------------------------------------------------------------------------

	'Show the query for debug purposes.
	Response.Write Query & "<p><br>"

	On Error Resume Next

	Set RS = Conn.Execute(Query)

	' Check for error.
	If Err.Description <> "" Then
		Response.Write "<B>Error " + Hex(Err) + ": " + Err.Description + "</B><br>"

	' Check for no-record case.
	ElseIf RS.EOF And RS.BOF Then 
		Response.Write "No records were found. <br>"

	' Valid data was received from the query.
	Else


		Response.Write "<center>"
		Response.Write "Test data for " & strSerialNumber & "<br>"
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
					ElseIf RS.Fields(Ctr).Name = "StopTime" Then
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



'---------------------------------------------------------------------------------------------------------------------------------------------
Sub GetTableName(SerialNumber, TableName)

	Dim RS
	Dim Query	
	

	'--------------------------------------------------------------------------------------------------------
	'Create the desired query.
	Query = "SELECT PN.TableName " & _
			 "FROM Index AS I, PartNumbers AS PN " & _
           "WHERE I.PartNumber = PN.PartNumber AND I.SerialNumber = '" & SerialNumber &"'"

	'--------------------------------------------------------------------------------------------------------

	On Error Resume Next

	'Show the query for debug purposes.
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
		TableName = "[" & RS("TableName") & "]"
	End If

End Sub

%>
