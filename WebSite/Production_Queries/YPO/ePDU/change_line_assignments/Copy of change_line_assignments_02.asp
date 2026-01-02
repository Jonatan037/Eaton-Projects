<%Option Explicit%>
<%Response.Buffer = TRUE%>

<html>

<head>
<title>ePDU Line Assignment Changes</title>
</head>

<body>


<h2 align="center">ePDU Line Reassignment</h2>

<%

Dim Conn			'Database connection.
Dim Sql				'The query to be executed.

Dim SerialNumber
Dim LineNumber



SerialNumber = Request("SerialNumber")
LineNumber   = Request("LineNumber")


If SerialNumber = "" OR LineNumber = "" Then
	Response.Write "You must enter a serial number and a line number"
	Response.End
End If

Response.write "SerialNumber = " & SerialNumber & "<br>"
Response.write "LineNumber = " & LineNumber & "<br><br>"



Set Conn = Server.CreateObject("ADODB.Connection")
Conn.Open "YPO"



Sql = "UPDATE epdu_index SET LineNumber = '" & LineNumber & "' WHERE SerialNumber = '" & SerialNumber & "'"


Conn.Execute(sql)

Response.write SerialNumber & " has been assigned to " & LineNumber & "<br>"




%>
</body>
</html>
