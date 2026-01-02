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




Sql = "SELECT I.Badge, I.PartNumber, I.SerialNumber, FIRST(PN.Cost) AS [Standard Cost] " & _
	  "FROM Index AS I LEFT JOIN PartNumbers AS PN ON I.PartNumber = PN.PartNumber " & _
      "WHERE I.StartTime BETWEEN " & QueryStartDate & " AND " & QueryEndDate & " " & _
      "GROUP BY I.Badge, I.PartNumber, I.SerialNumber " & _
      "ORDER BY I.Badge, I.PartNumber, I.SerialNumber "



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
	Dim Cost

	Response.Write "<table align='center' BORDER = '3.0' cellspacing='0' cellpadding='1'>"


	Response.Write "<tr>"
	Response.Write "<th>Count</th>"
	Response.Write "<th>Badge</th>"
	Response.Write "<th>Part Number</th>"
	Response.Write "<th>Serial Number</th>"
	Response.Write "<th>Cost</th>"
	Response.Write "</tr>"

	'Get the first badge number.
	Badge = rs("Badge")
	Count = 1
	Cost = 0

	Do While Not rs.EOF

		If rs("Badge") <> Badge Then
			Badge = rs("Badge")
			Response.Write "<tr> <td>&nbsp;</td> <td>&nbsp;</td> <td>&nbsp;</td> <td><b>Total</b></td> <td><b>" & Cost & "</b></td></tr>"
			Response.Write "<tr><td colspan=5>&nbsp;</td></tr>"
			Count = 1
			Cost = 0
		End If

		Response.Write "<tr>"
		Response.Write "<td>" & Count & "</td>"
		Response.Write "<td>" & Badge & "</td>"
		Response.Write "<td>" & rs("PartNumber") & "</td>"
		Response.Write "<td>" & rs("SerialNumber") & "</td>"
		Response.Write "<td>" & rs("Standard Cost") & "</td>"
		Response.Write "</tr>"

		Count = Count + 1

		Cost = Cost + rs("Standard Cost")

		rs.MoveNext

	Loop

			Response.Write "<tr> <td>&nbsp;</td> <td>&nbsp;</td> <td>&nbsp;</td> <td><b>Total</b></td> <td><b>" & Cost & "</b></td></tr>"
			Response.Write "<tr><td colspan=5>&nbsp;</td></tr>"

	Response.Write "</table>"
	Response.Write "<br><br>"

End Sub



%>
</body>
</html>
