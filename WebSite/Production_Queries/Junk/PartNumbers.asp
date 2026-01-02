<%Option Explicit%>
<html>

<head>
<meta name="GENERATOR" content="Microsoft FrontPage 3.0">
<title>A Query</title>

<meta name="Microsoft Theme" content="indust 101"></head>

<body background="../_themes/indust/indtextb.jpg" bgcolor="#FFFFFF" text="#000000" link="#3366CC" vlink="#666666" alink="#FF3300"><!--mstheme--><font face="trebuchet ms, arial, helvetica">

<h2 align="center"><!--mstheme--><font color="#CC6666">Part Numbers, Test Procedures and Software<!--mstheme--></font></h2>

<!--msthemeseparator--><p align="center"><img src="../_themes/indust/indhorsd.gif" width="300" height="10"></p>

<p><%
	Dim Conn
	Dim RS
	Dim Query	
	Dim Ctr
	Dim RowCtr

	On Error Resume Next

	'--------------------------------------------------------------------------------------------------------
	'Create the desired query.
	Query = "SELECT * FROM PartNumbers " & _
			 "ORDER BY PartNumber ASC"
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
	Response.Write "<table BORDER = '3.0'>"

		'Create the table header row.
  		Response.Write "<tr>"
			Response.Write "<th> Count </th>"

			For Ctr = 0 To RS.Fields.Count - 1
				Response.Write "<th>" & RS.Fields(Ctr).Name & "</th>"
			Next
		Response.Write "</tr>"

		RowCtr = 1
		
		'Fill in the cells with data.
		Do While Not RS.EOF
			Response.Write "<tr>"
				Response.Write "<td>" & RowCtr & "</td>"

				For Ctr = 0 To RS.Fields.Count - 1
	      			Response.Write "<td>" & RS.Fields(Ctr) & "</td>"
				Next
				Response.Write "</tr>"
		
			RS.MoveNext
			RowCtr = RowCtr + 1
		Loop
	
	Response.Write "</table>"
	Response.Write "</center>"	
End If
%> </p>
<!--mstheme--></font></body>
</html>
