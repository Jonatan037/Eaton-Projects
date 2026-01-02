<%Option Explicit%>
<%Response.Buffer = TRUE%>
<html>

<head>
<title>9x55 Test Logs</title>
</head>

<body>


<h2 align="center">9x55 Test Logs</h2>

<%

On Error Resume Next

Dim Conn				'Database connection.
Dim Sql				'The query to be executed.


Dim QueryStartDate
Dim QueryEndDate



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



Sql = "SELECT INDEXID, Plant, Family, Category, PartNumber, SerialNumber, StartTime, Sequence, TestResult, " & _
              "Description, [Record Type], TestStep AS [Test Step That Failed], ResultsData, ProgramName, " & _
              "Info1Item, Info2Item, Info3Item, Info4Item, Info5Item, Info6Item, Info7Item, Info8Item, Info9Item, Info10Item " & _
      "FROM qdms_index_view " & _
      "WHERE (StartTime BETWEEN " & QueryStartDate & " AND " & QueryEndDate & ") AND Family = '9x55' " & _
      "ORDER BY PartNumber,SerialNumber, StartTime, Sequence"




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
