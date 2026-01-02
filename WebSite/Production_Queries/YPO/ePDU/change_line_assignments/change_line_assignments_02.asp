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

Dim SerialNumber_Start
Dim SerialNumber_End
Dim LineNumber



SerialNumber_Start = Request("SerialNumber_Start")
SerialNumber_End = Request("SerialNumber_End")
LineNumber   = Request("LineNumber")


If SerialNumber_Start = "" OR SerialNumber_End = "" OR LineNumber = "" Then
	Response.Write "You must enter a starting serial number, ending serial number and a line number"
	Response.End
End If


If ValidateSerialNumber(SerialNumber_Start) = False Then
	Response.write "Starting serial number " & SerialNumber_Start & " is not a valid serial number<b>"
	Response.End
End If


If ValidateSerialNumber(SerialNumber_End) = False Then
	Response.write "Ending serial number " & SerialNumber_End & " is not a valid serial number<b>"
	Response.End
End If

Response.write "Starting Serial Number = " & SerialNumber_Start & "<br>"
Response.write "Ending Serial Number = " & SerialNumber_End & "<br>"
Response.write "LineNumber = " & LineNumber & "<br><br>"



Set Conn = Server.CreateObject("ADODB.Connection")
Conn.Open "YPO"


'Sql = "UPDATE epdu_index SET LineNumber = '" & LineNumber & "' WHERE SerialNumber = '" & SerialNumber & "'"

Sql = "UPDATE epdu_index SET LineNumber = '" & LineNumber & "' WHERE SerialNumber BETWEEN '" & SerialNumber_Start & "' AND '" & SerialNumber_END & "'"

Response.Write Sql & "<br>"
'Response.end

Conn.Execute(sql)

Response.write "All serial numbers between " & SerialNumber_Start & " AND " & SerialNumber_End & " have been assigned to " & LineNumber & "<br>"



Function ValidateSerialNumber(SN)

	'Default return value
	ValidateSerialNumber = false

	'All serial numbers must be ten characters long.
	If Len(SN) <> 10 Then Exit Function

	'Change to upper case.
	SN = UCase(SN)

	'The sixth character must be "E" for an ePDU unit.
	If Mid(SN,6,1) <> "E" Then Exit Function

	ValidateSerialNumber = true

End Function


%>
</body>
</html>
