<%Option Explicit%>
<%Response.Buffer = TRUE%>

<html>

<head>
<title>Test Yields For HP</title>
</head>

<body>

<!-- #include File=adovbs.inc -->


<h2 align="center">First Pass Yields For HP Products</h2>

<%

On Error Resume Next

Dim Conn				'Database connection.
Dim Sql				'The query to be executed.

Dim DisplayStart
Dim DisplayEnd
Dim QueryStartDate
Dim QueryEndDate
Dim LinkDateStart	'Use in hyperlink.
Dim LinkDateEnd		'Use in hyperlink.

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


QueryStartDate = "'" & Request("StartMonth") & "/" & Request("StartDay") & "/" & Request("StartYear") & "'"
QueryEndDate   = CDate(Request("EndMonth")   & "/" & Request("EndDay")   & "/" & Request("EndYear") ) + 1

QueryEndDate   = "'" & QueryEndDate & "'"


LinkDateStart = CDate(Request("StartMonth") & "/" & Request("StartDay") & "/" & Request("StartYear") )
LinkDateEnd   = CDate(Request("EndMonth")   & "/" & Request("EndDay")   & "/" & Request("EndYear")   ) + 1



'Increase timeout for people using this query.
Session.Timeout = 3 		'Minutes
Server.ScriptTimeout = 180 	'Seconds


Set Conn = Server.CreateObject("ADODB.Connection")

Conn.ConnectionTimeout = 180	'Seconds

Conn.Open Application("QDMS")


Sql = "SELECT I.IndexID, PN.Family, PN.Category, I.PartNumber, I.SerialNumber, I.Sequence, I.TestResult, StartTime, ResultsID, PN.Plant, PN.Description " & _
	  "FROM " & _
	   		"qdms_master_index AS I INNER JOIN qdms_part_numbers AS PN ON I.PartNumber = PN.PartNumber " & _
      "WHERE (StartTime BETWEEN " & QueryStartDate & " AND " & QueryEndDate & ") AND I.Sequence = 1 AND PN.Subcategory = 'HP' " & _
      "ORDER BY 2,3,4"



'Response.write sql & "<br>&nbsp;"
'response.end


Set rs = Server.CreateObject("ADODB.Recordset")

rs.Open Sql, Conn, adOpenKeyset, adLockOptimistic, adCmdText

if err.number <> 0 then 
   response.write sql & "<br><br>" & err.description & "<br>"
   response.end
end if


'No records for this time period.
if rs.EOF Then

	Response.Write "No test records exist for the specified time period."

else



	rs.Filter = "(TestResult <> NULL) AND (Family <> NULL)"
	show_yields_by_family


	rs.Filter = "(TestResult <> NULL) AND (Family <> NULL)"
	show_yields_by_family_category

end if


if err.number <> 0 then 
   response.write sql & "<br><br>" & err.description & "<br>"
end if


rs.Close
Conn.Close
Set rs = Nothing
set Conn = Nothing



'--------------------------------------------------------------------------------------------------------
Sub show_yields_by_family_category()

	Dim cntPass
	Dim cntFail
	Dim cntTotal
	Dim Family
	Dim Category

	rs.MoveFirst



	Response.Write "<table align='center' BORDER = '3.0' cellspacing='0' cellpadding='1'>"
	Response.Write "<caption>Yields by Family and Category</caption>"

	Response.Write "<tr>"
	Response.Write "<th>Family</th>"
	Response.Write "<th>Category</th>"
	Response.Write "<th>Total</th>"
	Response.Write "<th>Passed</th>"
	Response.Write "<th>Failed</th>"
	Response.Write "<th>Yields</th>"
	Response.Write "</tr>"

	'Get the first family and category name.
	Family = rs("Family")
	Category = rs("Category")

	cntPass = 0
	cntFail = 0
	cntTotal = 0



	Do While Not rs.EOF



		If ( rs("Family") <> Family ) OR ( rs("Category") <> Category ) Then



			Response.Write "<tr>"
			Response.Write "<td><A HREF='show_empower_test_logs.asp?LinkDateStart="& LinkDateStart & "&LinkDateEnd=" & LinkDateEnd & "&Family=" & Family & "'>" & Family & "</A></td>"
			Response.Write "<td><A HREF='show_empower_test_logs.asp?LinkDateStart="& LinkDateStart & "&LinkDateEnd=" & LinkDateEnd & "&Family=" & Family & "&Category=" & Category & "'>" & Category & "</A></td>"
			Response.Write "<td>" & cntTotal & "</td>"
			Response.Write "<td>" & cntPass  & "</td>"
			Response.Write "<td>" & cntFail  & "</td>"
			Response.Write "<td>" &  FormatPercent(cntPass/cntTotal) & "</td>"
			Response.Write "</tr>"

			If ( rs("Family") <> Family ) Then Response.Write "<tr><td colspan=6>&nbsp;</td></tr>"


			Family = rs("Family")
			Category = rs("Category")
			cntPass = 0
			cntFail = 0
			cntTotal = 0


		End If




		cntTotal = cntTotal + 1

		If rs("TestResult") = "Pass" Then
			cntPass = cntPass + 1
		Else
			cntFail = cntFail + 1
		End If


		rs.MoveNext

	Loop




	'Last Family
	Response.Write "<tr>"
	Response.Write "<td><A HREF='show_empower_test_logs.asp?LinkDateStart="& LinkDateStart & "&LinkDateEnd=" & LinkDateEnd & "&Family=" & Family & "'>" & Family & "</A></td>"
	Response.Write "<td><A HREF='show_empower_test_logs.asp?LinkDateStart="& LinkDateStart & "&LinkDateEnd=" & LinkDateEnd & "&Family=" & Family & "&Category=" & Category & "'>" & Category & "</A></td>"
'	Response.Write "<td>" & Category & "</td>"
	Response.Write "<td>" & cntTotal & "</td>"
	Response.Write "<td>" & cntPass  & "</td>"
	Response.Write "<td>" & cntFail  & "</td>"
	Response.Write "<td>" &  FormatPercent(cntPass/cntTotal) & "</td>"
	Response.Write "</tr>"


	Response.Write "</table>"
	Response.Write "<br><br>"

End Sub







'--------------------------------------------------------------------------------------------------------
Sub show_yields_by_family()

	Dim cntPass
	Dim cntFail
	Dim cntTotal
	Dim Family

	rs.MoveFirst



	Response.Write "<table align='center' BORDER = '3.0' cellspacing='0' cellpadding='1'>"
	Response.Write "<caption>Yields by Family</caption>"

	Response.Write "<tr>"
	Response.Write "<th>Family</th>"
	Response.Write "<th>Total</th>"
	Response.Write "<th>Passed</th>"
	Response.Write "<th>Failed</th>"
	Response.Write "<th>Yields</th>"
	Response.Write "</tr>"

	'Get the first family name.
	Family = rs("Family")

	cntPass = 0
	cntFail = 0
	cntTotal = 0


	Do While Not rs.EOF

		If rs("Family") <> Family Then

			Response.Write "<tr>"
			Response.Write "<td><A HREF='show_empower_test_logs.asp?LinkDateStart="& LinkDateStart & "&LinkDateEnd=" & LinkDateEnd & "&Family=" & Family & "'>" & Family & "</A></td>"
			Response.Write "<td>" & cntTotal & "</td>"
			Response.Write "<td>" & cntPass  & "</td>"
			Response.Write "<td>" & cntFail  & "</td>"
			Response.Write "<td>" &  FormatPercent(cntPass/cntTotal) & "</td>"
			Response.Write "</tr>"

			Family = rs("Family")

			cntPass = 0
			cntFail = 0
			cntTotal = 0


		End If

		cntTotal = cntTotal + 1

		If rs("TestResult") = "Pass" Then
			cntPass = cntPass + 1
		Else
			cntFail = cntFail + 1
		End If


		rs.MoveNext

	Loop



	'Last Family
	Response.Write "<tr>"
	Response.Write "<td><A HREF='show_empower_test_logs.asp?LinkDateStart="& LinkDateStart & "&LinkDateEnd=" & LinkDateEnd & "&Family=" & Family & "'>" & Family & "</A></td>"
	Response.Write "<td>" & cntTotal & "</td>"
	Response.Write "<td>" & cntPass  & "</td>"
	Response.Write "<td>" & cntFail  & "</td>"
	Response.Write "<td>" &  FormatPercent(cntPass/cntTotal) & "</td>"
	Response.Write "</tr>"


	Response.Write "</table>"
	Response.Write "<br><br>"

End Sub




'--------------------------------------------------------------------------------------------------------
Sub show_yields_overall()

	Dim cntPass
	Dim cntFail
	dim cntTotal


	rs.MoveFirst


	Do While Not rs.EOF

		cntTotal = cntTotal + 1

		If rs("TestResult") = "Pass" Then

			cntPass = cntPass + 1
		Else
			cntFail = cntFail + 1

		End If

		rs.MoveNext
	Loop



	Response.Write "<table align='center' BORDER = '3.0' cellspacing='0' cellpadding='1'>"
	Response.Write "<caption>Overall Yields (Including Invalid PRMS Parts)</caption>"

	Response.Write "<tr>"
	Response.Write "<th>Total</th>"
	Response.Write "<th>Passed</th>"
	Response.Write "<th>Failed</th>"
	Response.Write "<th>Yields</th>"
	Response.Write "</tr>"

	Response.Write "<tr>"
	Response.Write "<td>" & cntTotal & "</td>"
	Response.Write "<td>" & cntPass  & "</td>"
	Response.Write "<td>" & cntFail  & "</td>"

	Response.Write "<td>" &  FormatPercent(cntPass/cntTotal) & "</td>"
	Response.Write "</tr>"


	Response.Write "</table>"
	Response.Write "<br><br>"

End Sub




'--------------------------------------------------------------------------------------------------------
Sub GenericTable(Caption)

	Dim Ctr
	Dim RowCtr



	' Check for error.
	If Err.Description <> "" Then
		Response.Write "<B>Error " + Hex(Err) + ": " + Err.Description + "</B><br>"

	' Check for no-record case.
	ElseIf RS.EOF And RS.BOF Then
		'Response.Write "No records were found. <br>"

	' Valid data was received from the query.
	Else


	Response.Write "<table align='center' BORDER = '3.0' cellspacing='0' cellpadding='1'>"

		Response.Write "<caption>" & caption & "</caption>"

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

					ElseIf RS.Fields(Ctr).Name = "IndexID" Then
						Response.Write "<td><A HREF='get_empower_report.asp?ID=" & RS.Fields(Ctr) & "'>"  & RS.Fields(Ctr) & "</A></td>"
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

	Response.Write "<br><br>"

End Sub


%>
</body>
</html>
