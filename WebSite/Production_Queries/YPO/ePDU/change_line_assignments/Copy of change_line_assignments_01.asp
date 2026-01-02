<%Option Explicit%>
<html>

<head>
<title>Change ePDU Line Assignments</title>
</head>

<h2 align="center">Change ePDU Line Assignment</h2>


<body>

<%


		Response.Write "<center>"

		Response.Write "<form method='POST' action='change_line_assignments_02.asp'>"

			Response.Write "Enter serial number:<br>"
			Response.Write "<input type='text' name='SerialNumber' size='20'><br><br>"

			Response.Write "Enter new line number:<br>"
			Response.Write "<input type='text' name='LineNumber' size='20'><br><br>"

			Response.Write "<input type='submit' value='Submit' name='B1'>"
		Response.Write "</form>"

		Response.Write "</center>"


%>
</body>
</html>
