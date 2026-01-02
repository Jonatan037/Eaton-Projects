<%Option Explicit%>
<html>

<head>
<title>Search the NCR database for problem descriptions and analysis</title>
</head>

<body>



<%

	Response.Write "<h2 align='center'>Search the NCR database for problem descriptions and analysis</h2>"


	Response.Write "<center>"

	Response.Write "<form method='POST' action='ncr_search_002_show_search_results.asp'>"

		Response.Write "Enter some description of the problem:<br>"
		Response.Write "<input type='text' name='ProblemDescription' size='30'><br><br>"

		Response.Write "<input type='submit' value='Submit' name='B1'><br><br>"


	Response.Write "</form>"

	Response.Write "</center>"


%>
</body>
</html>
