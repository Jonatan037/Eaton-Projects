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

   Response.Write "<center>"

   Response.Write "<form method='POST' action='UDA_Login_Validate.Asp'>"

   Response.Write "Password<br><input type='password' name='frmPassword' size='20'><br><br>"

   Response.Write "<input type='submit' value='Submit' name='B1'>"

   Response.Write "</form>"

   Response.Write "</center>"



%>
</body>
</html>
