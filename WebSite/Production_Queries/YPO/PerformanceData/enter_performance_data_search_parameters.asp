<%Option Explicit%>
<html>

<head>
<title>Get Performance Data</title>
</head>

<body>



<%
	Dim QueryStartDate
	Dim QueryEndDate
	Dim sTitle


	'Get the date from the calling form.
	QueryStartDate = CDate(Request("StartMonth") & "/" & Request("StartDay") & "/" & Request("StartYear") )
	QueryEndDate   = CDate(Request("EndMonth")   & "/" & Request("EndDay")   & "/" & Request("EndYear") )


	If QueryStartDate = QueryEndDate Then

		sTitle = "for units tested on " & QueryStartDate
	Else
		sTitle = "for units tested between " & QueryStartDate & " - " & QueryEndDate

	End If

	Response.Write "<h2 align='center'>Get performance data from RPO_PRODDATA</h2>"
	Response.Write "<h2 align='center'>" & sTitle & "</h2><br><br>"


	Response.Write "<center>"

	Response.Write "<form method='POST' action='get_performance_data.asp'>"

		Response.Write "Enter part number:<br>"
		Response.Write "<input type='text' name='PartNumber' size='30'><br><br>"


		Response.Write "Enter test step name:<br>"
		Response.Write "<input type='text' name='TestStep' size='70'><br><br>"

		Response.Write "<input type='submit' value='Submit' name='B1'><br><br>"

		Response.Write "<input type='hidden' name='QueryStartDate' size='30' value='" & QueryStartDate & "'><br>"
		Response.Write "<input type='hidden' name='QueryEndDate' size='30' value='" & QueryEndDate & "'><br>"

	Response.Write "</form>"

	Response.Write "</center>"


%>
</body>
</html>
