<%Option Explicit%>
<html>

<head>
<meta name="GENERATOR" content="Microsoft FrontPage 3.0">
<title>A Query</title>

<meta name="Microsoft Theme" content="indust 101">
</head>

<body background="../_themes/indust/indtextb.jpg" bgcolor="#FFFFFF" text="#000000" link="#3366CC" vlink="#666666" alink="#FF3300"><!--mstheme--><font face="Trebuchet MS, Arial, Helvetica">

<h2 align="center"><!--mstheme--><font color="#CC6666">Defect Analysis<!--mstheme--></font></h2>

<!--msthemeseparator--><p align="center"><img src="../_themes/indust/indhorsd.gif" width="300" height="10"></p>

<p><%
	Dim Conn
	Dim Query	
	Dim QueryStartDate
	Dim QueryEndDate
	Dim DisplayStart
	Dim DisplayEnd

	'On Error Resume Next


	'--------------------------------------------------------------------------------------------------------
	'Put time in proper format.

	DisplayStart = Request("StartMonth") & "/" & Request("StartDay") & "/" & Request("StartYear")
	DisplayEnd   = Request("EndMonth")   & "/" & Request("EndDay")   & "/" & Request("EndYear")

	if DisplayStart = DisplayEnd then
		Response.Write "<center>" & DisplayStart & "</center><P>"
	else
		Response.Write "<center>" & DisplayStart & "&nbsp;&nbsp;&nbsp;" & "   To   " & "&nbsp;&nbsp;&nbsp;" & DisplayEnd & "</center><P>"
	end if


	QueryStartDate = "{ts '" &	Request("StartYear") & "-" 	& Request("StartMonth") & "-" &	Request("StartDay") & " 00:00:00'}"
	QueryEndDate   = "{ts '" & 	Request("EndYear")   & "-" & Request("EndMonth")    & "-" & 	Request("EndDay")   & " 23:59:59'}"

	Response.Write "<br>"

	'--------------------------------------------------------------------------------------------------------
	'Connect to the database

	Set Conn = Server.CreateObject("ADODB.Connection")
	Conn.Open Application("ProductionDatabase")
	

	'--------------------------------------------------------------------------------------------------------
	'Overall

	Query = "SELECT  F.DefectCategory, Count(I.PartNumber) As Total " & _
			 "FROM Index AS I, FailureInformation AS F " & _
			 "WHERE (I.Results = 0) AND " & _
			 "(I.StartTime BETWEEN " & QueryStartDate & " AND " & QueryEndDate & ") AND " & _
			 "I.ID = F.ID " & _
			 "Group By F.DefectCategory"

	Response.Write "<h3 align='center'> Overall </h3>"
	DisplayQueryResults
	Response.Write "<br> <br> <br>"


	'--------------------------------------------------------------------------------------------------------
	'By Partnumber

	Query = "SELECT " & _
					"I.PartNumber, " & _
					"F.DefectCategory, " & _
					"Count(I.PartNumber) As Total " & _

			 "FROM  " & _
					"Index AS I, " & _
					"FailureInformation AS F " & _

			 "WHERE " & _
					 "(I.Results = 0) AND " & _
					 "(I.StartTime BETWEEN " & QueryStartDate & " AND " & QueryEndDate & ") AND " & _
					 "I.ID = F.ID " & _
					 "Group By I.PartNumber, F.DefectCategory"

	Response.Write "<h3 align='center'> By Partnumber </h3>"
	DisplayQueryResults
	Response.Write "<br> <br> <br>"

	'--------------------------------------------------------------------------------------------------------
	'By Test Station

	Query = "SELECT I.Workcell, F.DefectCategory, Count(I.PartNumber) As Total " & _
			 "FROM Index AS I, FailureInformation AS F " & _
			 "WHERE (I.Results = 0) AND " & _
			 "(I.StartTime BETWEEN " & QueryStartDate & " AND " & QueryEndDate & ") AND " & _
			 "I.ID = F.ID " & _
			 "Group By I.Workcell, F.DefectCategory"

	Response.Write "<h3 align='center'> By Test Station </h3>"
	DisplayQueryResults
	Response.Write "<br> <br> <br>"

	'--------------------------------------------------------------------------------------------------------
	'Data

	Query = "SELECT  " & _
					"I.ID, " & _
					"I.SerialNumber, " & _
					"I.Seq, " & _
					"I.PartNumber, " & _
					"F.TestFailed, " & _
					"F.FailureDescription, " & _
					"F.DefectCategory, " & _
					"F.Remarks " & _

			 "FROM Index AS I, FailureInformation AS F " & _
			 "WHERE " & _
					"(I.Results = 0) AND " & _
					"(I.StartTime BETWEEN " & QueryStartDate & " AND " & QueryEndDate & ") AND " & _
					"I.ID = F.ID " & _

			"ORDER BY I.PartNumber, I.SerialNumber, I.Seq"

	Response.Write "<h3 align='center'> Data </h3>"
	DisplayQueryResults
	Response.Write "<br> <br> <br>"



%> </p>
<%
Sub DisplayQueryResults()

	Dim RS
	Dim Ctr

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
	Response.Write "<table BORDER = '3.0' cellspacing='1' cellpadding='0'>"

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
	Response.Write "</center>"	
End If

End Sub
%>
<!--mstheme--></font></body>
</html>
