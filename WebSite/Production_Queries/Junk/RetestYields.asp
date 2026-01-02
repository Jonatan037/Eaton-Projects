<%Option Explicit%>
<html>

<head>
<meta name="GENERATOR" content="Microsoft FrontPage 3.0">
<title>A Query</title>

<meta name="Microsoft Theme" content="indust 101"></head>

<body background="../_themes/indust/indtextb.jpg" bgcolor="#FFFFFF" text="#000000" link="#3366CC" vlink="#666666" alink="#FF3300"><!--mstheme--><font face="trebuchet ms, arial, helvetica">

<h2 align="center"><!--mstheme--><font color="#CC6666">Retest and Rework Yields<!--mstheme--></font></h2>

<!--msthemeseparator--><p align="center"><img src="../_themes/indust/indhorsd.gif" width="300" height="10"></p>
<%
	Dim Conn
	Dim Query	
	Dim QueryStartDate
	Dim QueryEndDate
	Dim DisplayStart
	Dim DisplayEnd
	Dim RS
	Dim Ctr
	Dim strPartNumber


	'On Error Resume Next

	Response.Write "<center>"

	'--------------------------------------------------------------------------------------------------------
	'Put time in proper format.

	DisplayStart = Request("StartMonth") & "/" & Request("StartDay") & "/" & Request("StartYear")
	DisplayEnd   = Request("EndMonth")   & "/" & Request("EndDay")   & "/" & Request("EndYear")

	if DisplayStart = DisplayEnd then
		Response.Write "<center>" & DisplayStart & "<P>"
	else
		Response.Write "<center>" & DisplayStart & "&nbsp;&nbsp;&nbsp;" & "   To   " & "&nbsp;&nbsp;&nbsp;" & DisplayEnd & "<P>"
	end if

	QueryStartDate = "{ts '" &	Request("StartYear") & "-" 	& Request("StartMonth") & "-" &	Request("StartDay") & " 00:00:00'}"
	QueryEndDate   = "{ts '" & 	Request("EndYear")   & "-" & Request("EndMonth")    & "-" & 	Request("EndDay")   & " 23:59:59'}"

	'--------------------------------------------------------------------------------------------------------
	'Connect to the database

	Set Conn = Server.CreateObject("ADODB.Connection")
	Conn.Open Application("ProductionDatabase")
	

	'--------------------------------------------------------------------------------------------------------
	Query = "SELECT " & _
				"PartNumber, " & _
				"Seq, " & _
				"Count(PartNumber) AS Total, " & _
				"Sum(Results) AS Passed, " & _
				"Sum(Results) / Count(PartNumber) AS Yields " & _
				
			"FROM Index " & _

			"WHERE " & _
			 	"(StartTime BETWEEN " & QueryStartDate & " AND " & QueryEndDate & ") " & _

			"GROUP BY PartNumber, Seq " & _
			"ORDER BY PartNumber, Seq"


	Set RS = Conn.Execute(Query)

	' Check for error.
	If Err.Description <> "" Then
		Response.Write "<B>Error " + Hex(Err) + ": " + Err.Description + "</B><br>"

	' Check for no-record case.
	ElseIf RS.EOF And RS.BOF Then 
		Response.Write "No records were found. <br>"

	' Valid data was received from the query.
	Else

		Response.Write "Seq indicates the number of times that a unit has been tested.<br>"
		Response.Write "So we have 1st pass, 2nd pass, 3rd pass, etc, yields.<br>"

		Response.Write "<div align='center'>"
		Response.Write "<table BORDER = '3.0' cellspacing='0' cellpadding='1'>"

			'Create the table header row.
  			Response.Write "<tr>"
				For Ctr = 0 To RS.Fields.Count - 1
					Response.Write "<th>" & RS.Fields(Ctr).Name & "</th>"
				Next
			Response.Write "</tr>"

			strPartNumber = RS("PartNumber")


			'Fill in the cells with data.
			Do While Not RS.EOF

				'Separate different partnumbers for easier viewing.
				If strPartNumber <> RS("PartNumber") Then
					Response.Write "<tr><td bgcolor='#C0C0C0' colspan='5'>&nbsp;</td></tr>"
		  			Response.Write "<tr>"
						For Ctr = 0 To RS.Fields.Count - 1
							Response.Write "<th>" & RS.Fields(Ctr).Name & "</th>"
						Next
					Response.Write "</tr>"
				End If

				strPartNumber = RS("PartNumber")

				Response.Write "<tr>"
					For Ctr = 0 To RS.Fields.Count - 1
	      				If RS.Fields(Ctr).Name = "Yields" Then
							Response.Write "<td>" & FormatPercent(RS("Yields")) & "</td>"
						Else
							Response.Write "<td>" & RS.Fields(Ctr) & "</td>"
						End If
					Next
				Response.Write "</tr>"
			RS.MoveNext
		Loop
	
		Response.Write "</table>"

		RS.Close
		Set RS = Nothing



	End If

%>
<!--mstheme--></font></body>
</html>
