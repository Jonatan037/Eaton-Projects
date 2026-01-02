<%Option Explicit%>
<%Response.Buffer = TRUE%>

<html>

<head>
<title>ePDU Line Assignments</title>
</head>

<body>
<!-- #include File=..\..\Tools\GenericTable.Inc -->

<h2 align="center">ePDU Line Assignments</h2>

<%

Dim Conn			'Database connection.
Dim Sql				'The query to be executed.

Dim DisplayStart
Dim DisplayEnd
Dim QueryStartDate
Dim QueryEndDate



DisplayStart = Request("StartMonth") & "/" & Request("StartDay") & "/" & Request("StartYear")
DisplayEnd   = Request("EndMonth")   & "/" & Request("EndDay")   & "/" & Request("EndYear")

if DisplayStart = DisplayEnd then
	Response.Write "<center>" & DisplayStart & "</center><P>"
else
	Response.Write "<center>" & DisplayStart & "&nbsp;&nbsp;&nbsp;" & "   To   " & "&nbsp;&nbsp;&nbsp;" & DisplayEnd & "</center><P>"
end if


QueryStartDate = "#" & Request("StartMonth") & "/" & Request("StartDay") & "/" & Request("StartYear") & "#"
QueryEndDate   = "#" & Request("EndMonth")   & "/" & Request("EndDay")   & "/" & Request("EndYear")   & "#"


Set Conn = Server.CreateObject("ADODB.Connection")
Conn.Open "YPO"


Sql = "SELECT LineDate, LineNumber, PartNumber, Count(PartNumber) AS [Number Assigned] " & _
	  "FROM epdu_index " & _
      "WHERE LineDate BETWEEN " & QueryStartDate & " AND " & QueryEndDate & " "  & _
      "GROUP BY LineDate, LineNumber, PartNumber " & _
      "ORDER BY 1,2,3"


GenericTable Conn, Sql
Response.Write "<br><br><br>"


Sql = "SELECT LineDate, LineNumber, PartNumber, SerialNumber " & _
	  "FROM epdu_index " & _
      "WHERE LineDate BETWEEN " & QueryStartDate & " AND " & QueryEndDate & " "  & _
      "ORDER BY 1,2,3,4"


GenericTable Conn, Sql

Conn.Close
set Conn = Nothing



%>
</body>
</html>
