<%Option Explicit%>
<%Response.Buffer = TRUE%>

<html>

<head>
<title>ePDU Logs</title>
</head>

<body>


<h2 align="center">ePDU Logs</h2>

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


QueryStartDate = "'" & Request("StartMonth") & "/" & Request("StartDay") & "/" & Request("StartYear") & "'"
QueryEndDate   = "'" & Request("EndMonth")   & "/" & Request("EndDay")   & "/" & Request("EndYear")   & "'"


Set Conn = Server.CreateObject("ADODB.Connection")
Conn.Open Application("QDMS")



Sql = "SELECT * FROM epdu_index " & _
      "WHERE RM_Date BETWEEN " & QueryStartDate & " AND " & QueryEndDate  & " " & _
      "AND TestComplete = 0"


GenericTable Conn, Sql, "Units RM'ed without Test Complete Records"




Sql = "SELECT U.Filename, U.DateCreated, U.Tech AS [Tech who created NCR] " & _
      "FROM qdms_ncr_unsubmitted AS U INNER JOIN epdu_index ON left(U.Filename,10) = epdu_index.SerialNumber " & _
      "WHERE epdu_index.RMed = 1 AND U.Unsubmitted = 1"

GenericTable Conn, Sql, "Units RM'ed with open NCRs"


Sql = "SELECT COUNT(Results) AS [Tested], Sum(Results) AS [Passed], ( CAST( Sum(Results) AS DOUBLE PRECISION ) / CAST (COUNT(Results) AS DOUBLE PRECISION ) ) AS [FPY] " & _
      "FROM epdu_index " & _
      "WHERE FirstTestDate BETWEEN " & QueryStartDate & " AND " & QueryEndDate


GenericTable Conn, Sql, "Overall Yields"




Sql = "SELECT LineNumber, COUNT(Results) AS [Tested], Sum(Results) AS [Passed], ( CAST( Sum(Results) AS DOUBLE PRECISION ) / CAST (COUNT(Results) AS DOUBLE PRECISION ) ) AS [FPY] " & _
      "FROM epdu_index " & _
      "WHERE FirstTestDate BETWEEN " & QueryStartDate & " AND " & QueryEndDate & " " & _
      "GROUP BY LineNumber"

GenericTable Conn, Sql, "Yields By Line Number"




Sql = "SELECT Tech, COUNT(Results) AS [Number of Units Tested], ( COUNT(Results) - Sum(Results) ) As [Number of Units Failed] " & _
      "FROM epdu_index " & _
      "WHERE FirstTestDate BETWEEN " & QueryStartDate & " AND " & QueryEndDate & " " & _
      "GROUP BY Tech " & _
      "ORDER BY Tech"

GenericTable Conn, Sql, "Test Tech Info - Totals"


Sql = "SELECT Tech, PartNumber, COUNT(Results) AS [Number of Units Tested], ( COUNT(Results) - Sum(Results) ) As [Number of Units Failed] " & _
      "FROM epdu_index " & _
      "WHERE FirstTestDate BETWEEN " & QueryStartDate & " AND " & QueryEndDate & " " & _
      "GROUP BY Tech, PartNumber " & _
      "ORDER BY Tech, PartNumber"

GenericTable Conn, Sql, "Test Tech Info - By Part Number"




Sql = "SELECT " & _
          "qdms_master_index.PartNumber, qdms_master_index.SerialNumber, qdms_master_index.StartTime, " & _
          "qdms_ct_record_type.Description AS [Record Type], qdms_master_index.Info3Item AS [Tech], qdms_master_index.Info6Item AS [Troubleshooting Hours]" & _
      "FROM (qdms_ct_record_type INNER JOIN qdms_master_index ON qdms_ct_record_type.ID = qdms_master_index.RecordType) INNER JOIN epdu_index ON qdms_master_index.SerialNumber = epdu_index.SerialNumber " & _
      "WHERE qdms_master_index.StartTime BETWEEN " & QueryStartDate & " AND " & QueryEndDate & " " & _
      "ORDER BY qdms_master_index.Info3Item"

GenericTable Conn, Sql, "Test Logs"




Sql = "SELECT * FROM epdu_index " & _
      "WHERE FirstTestDate BETWEEN " & QueryStartDate & " AND " & QueryEndDate


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
