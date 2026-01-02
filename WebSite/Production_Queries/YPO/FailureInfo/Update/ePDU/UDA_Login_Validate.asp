<%Option Explicit%>
<html>

<head>
<title>Defect Analysis Selection Options</title>
</head>

<body>

<h2 align="center">Defect Analysis Selection Options</h2>

<hr>
<%


   'Reset the password to null.
   Session("Password") = ""

   'Verify that a valid password was entered.
   If UCase(Request("frmPassword"))<> "WXYZ" Then
      Response.Redirect "UDA_Login.ASP"

   End If

   'Save the new password.
   Session("Password") = Request("frmPassword")



   Response.Write "<center>"
   Response.Write "<form method='POST' action='UDA_Display_Records.Asp'>"

   Response.Write "<table align='center' cellspacing=10>"


   Response.Write "<tr>"
   Response.Write "<td><INPUT TYPE='radio' NAME='R1' VALUE='0' CHECKED></td>"
   Response.Write "<td>Display All Unanalyzed Records</td>"
   Response.Write "</tr>"


   Response.Write "<tr>"
   Response.Write "<td><INPUT TYPE='radio' NAME='R1' VALUE='1'></td>"
   Response.Write "<td>Display Records For " & Session("QueryStartDate") & " to " &  Session("QueryEndDate") & "</td>"
   Response.Write "</tr>"


   Response.Write "<tr>"
   Response.Write "<td><INPUT TYPE='radio' NAME='R1' VALUE='2'></td>"
   Response.Write "<td>Display Records For Serial Number = <input type='text' name='frmSerialNumber' size='10'></td>"
   Response.Write "</tr>"

   Response.Write "<tr>"
   Response.Write "<td><INPUT TYPE='radio' NAME='R1' VALUE='3'></td>"
   Response.Write "<td>"
   Response.Write "Display records for unit with serial number = <input type='text' name='frmSerialNumber2' size='10'>"
   Response.Write " and style number = <input type='text' name='frmPartNumber' size='10'></td>"
   Response.Write "</td>"


   Response.Write "</tr>"

   Response.Write "</table>"

   Response.Write "<br><br>"


   Response.Write "<input type='submit' value='Submit' name='B1'>"

   Response.Write "</form>"

   Response.Write "</center>"


%>
</body>
</html>
