<%Option Explicit%>
<html>

<head>
<title>Find Tracking Number</title>
</head>

<body>

<h2 align="center">Search for unit record</h2>

<%


		Response.Write "<center>"

		Response.Write "<form method='POST' action='show_empower_test_logs.asp'>"

			Response.Write "Please enter a serial number, tracking number, part number, etc...<br>"
			Response.Write "<input type='text' name='SearchCriteria' size='20'><br>"
			Response.Write "<input type='submit' value='Submit' name='B1'>"
		Response.Write "</form>"

		Response.Write "</center>"


%>
</body>
</html>
