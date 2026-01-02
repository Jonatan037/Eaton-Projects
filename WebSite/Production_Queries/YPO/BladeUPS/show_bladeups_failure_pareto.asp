<%Option Explicit%>
<%Response.Buffer = TRUE%>

<html>

<head>
<title>BladeUPS Failure Pareto<</title>
</head>

<body>


<h2 align="center">BladeUPS Chassis Failure Pareto</h2>

<%

On Error Resume Next

Dim Conn				'Database connection.
Dim Sql				'The query to be executed.

Dim DisplayStart
Dim DisplayEnd
Dim QueryStartDate
Dim QueryEndDate



'--------------------------------------------------------------------------------------------------------
'Put time in proper format.


DisplayStart = Request("StartMonth") & "/" & Request("StartDay") & "/" & Request("StartYear")
DisplayEnd   = Request("EndMonth")   & "/" & Request("EndDay")   & "/" & Request("EndYear")

if DisplayStart = DisplayEnd then
	Response.Write "<center>" & DisplayStart & "</center><P>"
else
	Response.Write "<center>" & DisplayStart & "&nbsp;&nbsp;&nbsp;" & "   To   " & "&nbsp;&nbsp;&nbsp;" & DisplayEnd & "</center><P>"
end if


QueryStartDate = "'" & Request("StartMonth") & "/" & Request("StartDay") & "/" & Request("StartYear") & "'"
QueryEndDate   = CDate(Request("EndMonth")   & "/" & Request("EndDay")   & "/" & Request("EndYear") ) + 1

QueryEndDate   = "'" & QueryEndDate & "'"


Set Conn = Server.CreateObject("ADODB.Connection")


Conn.Open Application("QDMS")


Sql = "SELECT F.TestStep, Count(F.TestStep) AS [Number of Failures] " & _
      "FROM qdms_master_index AS I INNER JOIN qdms_failure_info AS F ON I.INDEXID = F.INDEXID " & _
	  "WHERE " & _
	     "StartTime BETWEEN " & QueryStartDate & " AND " & QueryEndDate & " AND " & _
	     "Left(I.PartNumber,2) = 'ZC' AND " & _
         "I.Sequence = 1 " & _
      "GROUP BY F.TestStep " & _
      "ORDER BY 2 DESC"

GenericTable Conn, Sql, "Failures affecting first pass yields for both low and high voltage units."
Response.Write "<br><br><br>"


Sql = "SELECT F.TestStep, Count(F.TestStep) AS [Number of Failures] " & _
      "FROM qdms_master_index AS I INNER JOIN qdms_failure_info AS F ON I.INDEXID = F.INDEXID " & _
	  "WHERE " & _
	     "StartTime BETWEEN " & QueryStartDate & " AND " & QueryEndDate & " AND " & _
	     "I.PartNumber LIKE 'ZC__1%' AND " & _
         "I.Sequence = 1 " & _
      "GROUP BY F.TestStep " & _
      "ORDER BY 2 DESC"

GenericTable Conn, Sql, "Failures affecting first pass yields for low voltage units"
Response.Write "<br><br><br>"


Sql = "SELECT F.TestStep, Count(F.TestStep) AS [Number of Failures] " & _
      "FROM qdms_master_index AS I INNER JOIN qdms_failure_info AS F ON I.INDEXID = F.INDEXID " & _
	  "WHERE " & _
	     "StartTime BETWEEN " & QueryStartDate & " AND " & QueryEndDate & " AND " & _
	     "I.PartNumber LIKE 'ZC__2%' AND " & _
         "I.Sequence = 1 " & _
      "GROUP BY F.TestStep " & _
      "ORDER BY 2 DESC"

GenericTable Conn, Sql, "Failures affecting first pass yields for high voltage units"
Response.Write "<br><br><br>"




Sql = "SELECT F.TestStep, Count(F.TestStep) AS [Number of Failures] " & _
      "FROM qdms_master_index AS I INNER JOIN qdms_failure_info AS F ON I.INDEXID = F.INDEXID " & _
	  "WHERE " & _
	     "StartTime BETWEEN " & QueryStartDate & " AND " & QueryEndDate & " AND " & _
	     "Left(I.PartNumber,2) = 'ZC' " & _
      "GROUP BY F.TestStep " & _
      "ORDER BY 2 DESC"


GenericTable Conn, Sql, "All failures regardless of yield impact"
Response.Write "<br><br><br>"



Sql = "SELECT F.TestStep, F.ResultsData, Count(F.ResultsData) AS [Number of Failures] " & _
      "FROM qdms_master_index AS I INNER JOIN qdms_failure_info AS F ON I.INDEXID = F.INDEXID " & _
	  "WHERE " & _
	     "StartTime BETWEEN " & QueryStartDate & " AND " & QueryEndDate & " AND " & _
	     "Left(I.PartNumber,2) = 'ZC' AND " & _
         "I.Sequence = 1 " & _
      "GROUP BY F.TestStep, F.ResultsData " & _
      "ORDER BY 1,2 DESC"

GenericTable Conn, Sql, "Test steps and results data."
Response.Write "<br><br><br>"

Conn.Close
Set Conn = Nothing



'--------------------------------------------------------------------------------------------------------
Sub GenericTable(dbConn, strQuery, strCaption)

	Dim RS
	Dim Ctr
	Dim RowCtr

	On Error Resume Next


	Set RS = dbConn.Execute(strQuery)

	' Check for error.
	If Err.Description <> "" Then
		Response.Write "<B>Error " + Hex(Err) + ": " + Err.Description + "</B><br>" & strQuery

	' Check for no-record case.
	ElseIf RS.EOF And RS.BOF Then
		Response.Write "No records were found. <br>"

	' Valid data was received from the query.
	Else


		Response.Write "<table align='center' BORDER = '3.0' cellspacing='0' cellpadding='1'>"
		Response.Write "<caption>" & strCaption & "</caption>"

		'Create the table header row.
  		Response.Write "<tr>"
			Response.Write "<th>Rows</th>"
			For Ctr = 0 To RS.Fields.Count - 1
				Response.Write "<th>" & RS.Fields(Ctr).Name & "</th>"
			Next
		Response.Write "</tr>"

		'Fill in the cells with data.
		Do While Not RS.EOF
			RowCtr = RowCtr + 1
			Response.Write "<tr>"
				Response.Write "<td>" & RowCtr & "</td>"
				For Ctr = 0 To RS.Fields.Count - 1
					If IsNull(RS.Fields(Ctr)) Then
						Response.Write "<td>&nbsp;</td>"

					Else
							Response.Write "<td>" & RS.Fields(Ctr) & "</td>"
					End If
				Next
				Response.Write "</tr>"

			RS.MoveNext
		Loop

		Response.Write "</table>"
		Response.Write "</center>"

	End If

	RS.Close
	Set RS = Nothing

End Sub





%>
</body>
</html>
