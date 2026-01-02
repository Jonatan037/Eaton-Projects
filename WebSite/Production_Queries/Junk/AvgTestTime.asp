<%Option Explicit%>
<html>

<head>
<meta name="GENERATOR" content="Microsoft FrontPage 3.0">
<title>A Query</title>

<meta name="Microsoft Theme" content="indust 101"></head>

<body background="../_themes/indust/indtextb.jpg" bgcolor="#FFFFFF" text="#000000" link="#3366CC" vlink="#666666" alink="#FF3300"><!--mstheme--><font face="trebuchet ms, arial, helvetica">

<h2 align="center"><!--mstheme--><font color="#CC6666">Average Test Times<!--mstheme--></font></h2>

<!--msthemeseparator--><p align="center"><img src="../_themes/indust/indhorsd.gif" width="300" height="10"></p>

<p><%
	Dim Conn
	Dim RS
	Dim Query	
	Dim QueryStartDate
	Dim QueryEndDate
	Dim DisplayStart
	Dim DisplayEnd
	Dim Ctr

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
	
	Query = "SELECT " & _
				"PartNumber, " & _
				"Avg(StopTime - StartTime) * 1440 AS Average, " & _
				"Min(StopTime - StartTime) * 1440 AS Minimum, " & _
				"Max(StopTime - StartTime) * 1440 AS Maximum, " & _
				"Count(PartNumber) AS Count " & _
			 "FROM Index " & _
			 "WHERE " & _
				"(Seq = 1) AND " & _
			 	"(Results = 1) AND " & _
			 	"(StartTime BETWEEN " & QueryStartDate & " AND " & QueryEndDate & ") " & _
			 "GROUP BY PartNumber"
	

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

	Response.Write "<table BORDER = '3.0'>"
	
	'Create the table header row.
  	Response.Write "<tr>"
		For Ctr = 0 To RS.Fields.Count - 1
			Response.Write "<th>" & RS.Fields(Ctr).Name & "</th>"
		Next
	Response.Write "</tr>"
	
	Do While Not RS.EOF
		
		Response.Write "<tr>"

		For Ctr = 0 To RS.Fields.Count - 1
			
			If RS.Fields(Ctr).Name = "Average" Then
				Response.Write "<td>" & FormatNumber(RS.Fields(Ctr)) & "</td>"

			ElseIf RS.Fields(Ctr).Name = "Maximum" Then
				Response.Write "<td>" & FormatNumber(RS.Fields(Ctr)) & "</td>"

			ElseIf RS.Fields(Ctr).Name = "Minimum" Then
				Response.Write "<td>" & FormatNumber(RS.Fields(Ctr)) & "</td>"

			Else
				Response.Write "<td>" & RS.Fields(Ctr) & "</td>"

			End If
		Next

		Response.Write "</tr>"

		RS.MoveNext
	Loop
	
	Response.Write "</table>"

	Response.Write "<br>Test times are expressed in minutes."
	Response.Write "</center>"	
End If
%> </p>
<!--mstheme--></font></body>
</html>
