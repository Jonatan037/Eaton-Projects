<%Option Explicit%>
<%Response.Buffer = TRUE%>

<html>

<head>
<title>Eagle Logs</title>
</head>

<body>


<h2 align="center">Eagle Logs</h2>

<%

On Error Resume Next

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


QueryStartDate = "'" & Request("StartYear") & "-" & Request("StartMonth") & "-" & Request("StartDay") & " 00:00:00" & "'"
QueryEndDate   = "'" & Request("EndYear")   & "-" & Request("EndMonth")   & "-" & Request("EndDay")  & " 23:59:59" & "'"


Set Conn = Server.CreateObject("ADODB.Connection")
Conn.Open Application("Eagle")

'Calculate Overall Yield	  
Sql = "SELECT COUNT(SerialNumber) AS [Tested], Sum(Cast(Result as decimal)) " & _ 
      "AS [Passed], ( CAST( Sum(Cast(Result as decimal)) " & _ 
	  "AS DOUBLE PRECISION ) / CAST (COUNT(SerialNumber) " & _ 
	  "AS DOUBLE PRECISION ) ) " & _ 
	  "AS [FPY] " & _
      "FROM EagleTestData.dbo.Master " & _
	  "WHERE StartTime BETWEEN " & QueryStartDate & " AND " & QueryEndDate  


GenericTable Conn, Sql, "Overall Yields"



Sql = "SELECT BadgeNumber, COUNT(Cast(Result as decimal)) AS [Number of Units Tested], ( COUNT(Cast(Result as decimal)) - Sum(Cast(Result as decimal)) ) As [Number of Units Failed] " & _
      "FROM EagleTestData.dbo.Master " & _
      "WHERE StartTime BETWEEN " & QueryStartDate & " AND " & QueryEndDate & " " & _
      "GROUP BY BadgeNumber " & _
      "ORDER BY BadgeNumber"

GenericTable Conn, Sql, "Test Tech Info - Totals"



Sql = "SELECT BadgeNumber, PartNumber, Cast(COUNT(SerialNumber) as decimal) AS [Number of Units Tested], ( CAST(COUNT(SerialNumber) as decimal) - Sum(Cast(Result as decimal)) ) As [Number of Units Failed] " & _
      "FROM EagleTestData.dbo.Master " & _
      "WHERE StartTime BETWEEN " & QueryStartDate & " AND " & QueryEndDate & " " & _
      "GROUP BY BadgeNumber, PartNumber " & _
      "ORDER BY BadgeNumber, PartNumber"

GenericTable Conn, Sql, "Test Tech Info - By Part Number"



'Test details
Sql = "SELECT * FROM EagleTestData.dbo.Master " & _
      "WHERE StartTime BETWEEN " & QueryStartDate & " AND " & QueryEndDate


GenericTable Conn, Sql, "Details"






Conn.Close
set Conn = Nothing


Sub GenericTable(dbConn, strQuery, strCaption)

	Dim RS
	Dim Ctr
	Dim RowCtr


	On Error Resume Next

	'Response.Write strQuery & "<br><br>"

	Set RS = dbConn.Execute(strQuery)


	' Check for error.
	If Err.Description <> "" Then
		Response.Write "<B>Error " + Hex(Err) + ": " + Err.Description + "</B><br><br>" & strQuery & "<br><br>"

	' Check for no-record case.
	ElseIf RS.EOF And RS.BOF Then
		'Response.Write "No records were found. <br>"

	' Valid data was received from the query.
	Else


	Response.Write "<table align='center' BORDER = '3.0' cellspacing='0' cellpadding='3'>"
	Response.Write "<caption>" & strCaption & "</caption>"

		'Create the table header row.
  		Response.Write "<tr>"
			For Ctr = 0 To RS.Fields.Count - 1
				Response.Write "<th>" & RS.Fields(Ctr).Name & "</th>"
			Next
		Response.Write "</tr>"

		'Fill in the cells with data.
		Do While Not RS.EOF
			RowCtr = RowCtr + 1
			Response.Write "<tr>"

				For Ctr = 0 To RS.Fields.Count - 1

					If IsNull(RS.Fields(Ctr)) Then
						Response.Write "<td>&nbsp;</td>"

					ElseIf RS.Fields(Ctr).Name = "FPY" Then
						Response.Write "<td>" & FormatPercent(RS.Fields(Ctr) )& "</td>"

					Else
						Response.Write "<td>" & RS.Fields(Ctr) & "</td>"
					End If

				Next
				Response.Write "</tr>"

			RS.MoveNext
		Loop

		Response.Write "</table>"
		Response.Write "</center>"

        Response.Write "<br><br><br>"

	End If

	RS.Close
	Set RS = Nothing

End Sub

%>
</body>
</html>
