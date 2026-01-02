<%Option Explicit%>
<%Response.Buffer = TRUE%>

<html>

<head>
<title>Logs By Badge Number</title>
</head>

<body>


<h2 align="center">Logs By Badge Number</h2>

<%

Dim Conn			'Database connection.
Dim Sql				'The query to be executed.

Dim DisplayStart
Dim DisplayEnd
Dim QueryStartDate
Dim QueryEndDate
Dim rs


'--------------------------------------------------------------------------------------------------------
'Put time in proper format.


DisplayStart = Request("StartMonth") & "/" & Request("StartDay") & "/" & Request("StartYear")
DisplayEnd   = Request("EndMonth")   & "/" & Request("EndDay")   & "/" & Request("EndYear")

if DisplayStart = DisplayEnd then
	Response.Write "<center>" & DisplayStart & "</center><P>"
else
	Response.Write "<center>" & DisplayStart & "&nbsp;&nbsp;&nbsp;" & "   To   " & "&nbsp;&nbsp;&nbsp;" & DisplayEnd & "</center><P>"
end if


QueryStartDate = "#" & Request("StartMonth") & "/" & Request("StartDay") & "/" & Request("StartYear") & "#"
QueryEndDate   = CDate(Request("EndMonth")   & "/" & Request("EndDay")   & "/" & Request("EndYear") ) + 1

QueryEndDate   = "#" & QueryEndDate & "#"


Set Conn = Server.CreateObject("ADODB.Connection")
Conn.Open "DRIVER=Microsoft Access Driver (*.mdb);UID=;PWD=;FIL=MS Access;DBQ=\\youncsfp01\data\test-eng\ePDU\Database\ePDU_Production_Master.mdb"




Sql = "SELECT Badge, PartNumber, SerialNumber " & _
	  "FROM Index " & _
      "WHERE StartTime BETWEEN " & QueryStartDate & " AND " & QueryEndDate & " " & _
      "GROUP BY Badge, PartNumber, SerialNumber " & _
      "ORDER BY Badge, PartNumber, SerialNumber "



'Response.write sql & "<br>&nbsp;"
'response.end


Set rs = Server.CreateObject("ADODB.Recordset")

rs.Open Sql, Conn
show_yields_by_badge_number


rs.Close
Conn.Close
Set rs = Nothing
set Conn = Nothing



'--------------------------------------------------------------------------------------------------------
Sub show_yields_by_badge_number()

	Dim Badge
	Dim Count

	Response.Write "<table align='center' BORDER = '3.0' cellspacing='0' cellpadding='1'>"


	Response.Write "<tr>"
	Response.Write "<th>Count</th>"
	Response.Write "<th>Badge</th>"
	Response.Write "<th>Part Number</th>"
	Response.Write "<th>Serial Number</th>"
	Response.Write "</tr>"

	'Get the first badge number.
	Badge = ""
	Count = 1


	Do While Not rs.EOF

		If rs("Badge") <> Badge Then
			Badge = rs("Badge")
			Count = 1
			Response.Write "<tr><td colspan=4>&nbsp;</td></tr>"
		End If

		Response.Write "<tr>"
		Response.Write "<td>" & Count & "</td>"
		Response.Write "<td>" & Badge & "</td>"
		Response.Write "<td>" & rs("PartNumber") & "</td>"
		Response.Write "<td>" & rs("SerialNumber") & "</td>"
		Response.Write "</tr>"

		Count = Count + 1

		rs.MoveNext

	Loop



	Response.Write "</table>"
	Response.Write "<br><br>"

End Sub



%>
</body>
</html>
