<%Option Explicit%>
<html>

<head>
<title>Defect Analysis Login</title>
</head>

<body>

<h2 align="center">Defect Analysis User Login</h2>

<hr>
<%

   'Reset the password to null.
   Session("Password") = ""

   'Create time stamp for use in query.
   Session("QueryStartDate") = "{ts '" & Request("StartYear") & "-" 	& Request("StartMonth") & "-" &	Request("StartDay") & " 00:00:00'}"
   Session("QueryEndDate")   = "{ts '" & Request("EndYear")   & "-" & Request("EndMonth")    & "-" & Request("EndDay")   & " 23:59:59'}"

   'Format the time for display.
   Session("DisplayStart") = Request("StartMonth") & "/" & Request("StartDay") & "/" & Request("StartYear")
   Session("DisplayEnd")   = Request("EndMonth")   & "/" & Request("EndDay")   & "/" & Request("EndYear")



   Response.Write "<center>"

   Response.Write "<form method='POST' action='UDA_Login_Validate.Asp'>"

   Response.Write "Password<br><input type='password' name='frmPassword' size='20'><br><br>"

   Response.Write "<input type='submit' value='Submit' name='B1'>"

   Response.Write "</form>"
	
   Response.Write "</center>"



%>
</body>
</html>
