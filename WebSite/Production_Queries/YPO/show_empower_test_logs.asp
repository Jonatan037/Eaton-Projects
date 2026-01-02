<%Option Explicit%>
<%Response.Buffer = TRUE%>
<html>

<head>
<title>Empower Test Log</title>
</head>

<body>


<h2 align="center">TEST DATA</h2>

<%

On Error Resume Next

Dim Conn				'Database connection.
Dim Sql				'The query to be executed.


Dim QueryStartDate
Dim QueryEndDate
Dim Family
Dim Category
Dim Criteria
Dim PartNumber
Dim SerialNumber
Dim TrackingNumber
Dim Plant



'Date range from form.
If Request("StartMonth") <> "" Then
	QueryStartDate = "'" & Request("StartMonth") & "/" & Request("StartDay") & "/" & Request("StartYear") & "'"
	QueryEndDate   = CDate(Request("EndMonth")   & "/" & Request("EndDay")   & "/" & Request("EndYear") ) + 1
	QueryEndDate   = "'" & QueryEndDate & "'"
End If


'Date range from a hyperline.
If Request("LinkDateStart") <> "" Then
	QueryStartDate = "'" & Request("LinkDateStart") & "'"
	QueryEndDate   = "'" & Request("LinkDateEnd")   & "'"
End If

Family = Request("Family")
Category = Request("Category")
Plant = Request("Plant")

If Family = "" Then
	Criteria = ""
Else
	If Category = "" Then
		Criteria = " AND (Family = '" & Family & "') "
	Else
		Criteria = " AND (Family = '" & Family & "') AND (Category = '" & Category & "') "
	End If
End If

If Plant <> "" Then
	Criteria = " AND (Plant = '" & Plant & "') "
End If


'Time based query.
Sql = "SELECT INDEXID, Plant, Family, Category, PartNumber, SerialNumber, StartTime, Sequence, TestResult, Description, [Record Type], TestStep AS [Test Step That Failed], ResultsData, ProgramName, Info2Item, Info3Item, EmployeeID " & _
	  "FROM qdms_index_view " & _
      "WHERE (StartTime BETWEEN " & QueryStartDate & " AND " & QueryEndDate & ")" & Criteria & " " & _
      "ORDER BY PartNumber,SerialNumber, StartTime, Sequence"

'Response.Write sql & "<br>"

'Search by serial number, tracking number, part number, etc...
If Request("SearchCriteria") <> "" Then

	TrackingNumber = UCase(Request("SearchCriteria"))

	Sql = "SELECT INDEXID, Family, Category, PartNumber, SerialNumber, StartTime, Sequence, TestResult, Description, [Record Type], TestStep AS [Test Step That Failed], ResultsData, ProgramName, EmployeeID " & _
		  "FROM qdms_index_view " & _
		  "WHERE SerialNumber  LIKE '" & TrackingNumber & "%'  OR " & _
		  		"PartNumber    LIKE '" & TrackingNumber & "%'  OR " & _
		        "Info1Item     LIKE '" & TrackingNumber & "%'  OR " & _
		        "Info2Item     LIKE '" & TrackingNumber & "%'  OR " & _
		        "Info3Item     LIKE '" & TrackingNumber & "%'  OR " & _
		  		"Info4Item     LIKE '" & TrackingNumber & "%'  OR " & _
		  		"Info5Item     LIKE '" & TrackingNumber & "%'  OR " & _
		  		"Info6Item     LIKE '" & TrackingNumber & "%'  OR " & _
		  		"Info7Item     LIKE '" & TrackingNumber & "%'  OR " & _
		  		"Info8Item     LIKE '" & TrackingNumber & "%'  OR " & _
		  		"Info9Item     LIKE '" & TrackingNumber & "%'  OR " & _
		  		"Info10Item    LIKE '" & TrackingNumber & "%'    " & _
		  "ORDER BY PartNumber,SerialNumber, StartTime, Sequence"

	Response.Write "<h2 align='center'> Search for test records starting with " & TrackingNumber & "</h2>"

End If



'Increase timeout for people using this query.
Session.Timeout = 3 		'Minutes
Server.ScriptTimeout = 180 	'Seconds


Set Conn = Server.CreateObject("ADODB.Connection")

Conn.ConnectionTimeout = 180	'Seconds

Conn.Open Application("QDMS")



if err.number <> 0 then 
   response.write sql & "<br><br>" & err.description & "<br>"
   response.end
end if


GenericTable Conn, Sql


Conn.Close
Set Conn = Nothing


'------------------------------------------------------------------------------------------------
Sub GenericTable(dbConn, strQuery)

	Dim RS
	Dim Ctr
	Dim RowCtr

	On Error Resume Next

	'Response.Write strQuery & "<br>"

	Set RS = dbConn.Execute(strQuery)



if err.number <> 0 then 
   response.write strQuery & "<br><br>" & err.description & "<br>"
   response.end
end if


	' Check for error.
	If Err.Description <> "" Then
		Response.Write "<B>Error " + Hex(Err) + ": " + Err.Description + "</B><br>"

	' Check for no-record case.
	ElseIf RS.EOF And RS.BOF Then
		Response.Write "No records were found. <br>"

	' Valid data was received from the query.
	Else


	Response.Write "<table align='center' BORDER = '3.0' cellspacing='0' cellpadding='1'>"

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

					ElseIf RS.Fields(Ctr).Name = "INDEXID" Then
						'Response.Write "<td><A HREF='get_empower_report.asp?ID=" & RS.Fields(Ctr) & "'>"  & RS.Fields(Ctr) & "</A></td>"
						Response.Write "<td><A HREF='TestReports\get_report_001_main.asp?ID=" & RS.Fields(Ctr) & "'>"  & RS.Fields(Ctr) & "</A></td>"
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
