<%Option Explicit%>
<html>

<head>
<title>Find Part Number</title>
</head>

<body>

<h2 align="center">Search for a part number</h2>

<%


		Response.Write "<center>"

		Response.Write "<form method='POST' action='show_empower_test_logs.asp'>"

			Response.Write "Please enter unit's Part number:<br>"
			Response.Write "<input type='text' name='PartNumber' size='20'><br>"
			Response.Write "<input type='submit' value='Submit' name='B1'>"
		Response.Write "</form>"

		Response.Write "</center>"


%>
</body>
</html>
