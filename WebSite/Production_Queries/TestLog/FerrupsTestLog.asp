<%Option Explicit%>
<html>

<head>
<title>Test Logs</title>
</head>

<body>

<p><%
	Dim Conn
	Dim RS
	Dim Query
	Dim QueryStartDate
	Dim QueryEndDate
	Dim DisplayStart
	Dim DisplayEnd
	Dim Ctr

	'On Error Resume Next

	'Format the time for display.
	DisplayStart = Request("StartMonth") & "/" & Request("StartDay") & "/" & Request("StartYear")
	DisplayEnd   = Request("EndMonth")   & "/" & Request("EndDay")   & "/" & Request("EndYear")

	'Show query date.
	if DisplayStart = DisplayEnd then
		Response.Write "<h2 align='center'>Ferrups Test Log<br>" & DisplayStart & "</h2>"
	else
		Response.Write "<h2 align='center'>Ferrups Test Log<br>" & DisplayStart & " To " & DisplayEnd & "</h2>"
	end if

	'Create time stamp for use in query.
	QueryStartDate = "{ts '" &	Request("StartYear") & "-" 	& Request("StartMonth") & "-" &	Request("StartDay") & " 00:00:00'}"
	QueryEndDate   = "{ts '" & 	Request("EndYear")   & "-" & Request("EndMonth")    & "-" & 	Request("EndDay")   & " 23:59:59'}"


	Set Conn = Server.CreateObject("ADODB.Connection")

	'Open the database defined in the Global.asa file.
	Conn.Open Application("ProductionDatabase")


	Call ShowYields
	Call ShowDetails


'-------------------------------------------------------------------------------------------------
Sub ShowDetails

	Dim strCategory

	'Get the test logs.
	Query = "SELECT " & _
              "Category, " & _
	           "'?' AS [Built By], " & _   
				 "PartNumber AS [Part Number], " & _
     			 "SerialNumber AS [Serial Number], " & _
				 "IIF(Results, 'Passed', 'Failed') AS [Test Results], " & _
               "FailureCategory AS [Failure Category], " & _
               "SubCat1 AS [Failure Details], " & _
               "Remarks " & _
			"FROM [Yield View] " & _
			"WHERE " & _
              "StartTime BETWEEN " & QueryStartDate & " AND " & QueryEndDate & " " & _
              "AND Seq = 1 AND Family = 'Ferrups' AND Results = 0 " & _
			"ORDER BY Category, PartNumber"

	'Response.Write Query & "<p><br>"

	Set RS = Conn.Execute(Query)

	Response.Write "<div align='center'><center>"
	Response.Write "<table BORDER = '3.0' cellspacing='0' cellpadding='3'>"

	Response.Write "<caption><b>Details</b></caption>"

		'Create the table header row.
  		Response.Write "<tr>"
			For Ctr = 0 To RS.Fields.Count - 1
				Response.Write "<th>" & RS.Fields(Ctr).Name & "</th>"
			Next
		Response.Write "</tr>"

		'Fill in the cells with data.
		Do While Not RS.EOF

			'Seperate the categories for easier viewing.
			If strCategory <> RS("Category") Then
				strCategory = RS("Category")
				Response.Write "<tr><td bgcolor='#C0C0C0' colspan='" & RS.Fields.Count & "'>&nbsp;</td></tr>"
			End If

			Response.Write "<tr>"
		
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

End Sub


'-------------------------------------------------------------------------------------------------
Sub ShowYields

	Dim RS
	Dim Ctr

	'Yields by family and category.
	Query = "SELECT Category, " & _
			 "Count(PartNumber) As Tested, " & _
			 "(Sum(Results) + Sum(dcNFF))/ Count(PartNumber) As [%Passed], " & _
			 "1 - ((Sum(Results) + Sum(dcNFF))/ Count(PartNumber) ) As [%Failed], " & _
           "(1 - ((Sum(Results) + Sum(dcNFF))/ Count(PartNumber) )) * 1000000 As [DPM], " & _
           "Sum(dcNFF) AS NFF, " & _
			 "Sum(dcNotAnalyzed) As [Not Analyzed], " & _
			 "Sum(dcComponent) AS Component, " & _
			 "Sum(dcWorkmanship) AS Workmanship " & _
			 "FROM [Yield View] " & _
			 "WHERE (Seq = 1) AND Family = 'Ferrups' AND " & _
			 "(StartTime BETWEEN " & QueryStartDate & " AND " & QueryEndDate & ") " & _
			 "GROUP BY Category"

	Set RS = Conn.Execute(Query)

	' Check for error.
	If Err.Description <> "" Then
		Response.Write "<B>Error " + Hex(Err) + ": " + Err.Description + "</B><br>"

	' Check for no-record case.
	ElseIf RS.EOF And RS.BOF Then 
		Response.Write "No records were found. <br>"

	' Valid data was received from the query.
	Else


	Response.Write "<div align='center'><center>"
	Response.Write "<table BORDER = '3.0' cellspacing='0' cellpadding='1'>"

	Response.Write "<caption><b>Yields By Category</b></caption>"

		'Create the table header row.
  		Response.Write "<tr>"
			For Ctr = 0 To RS.Fields.Count - 1
				Response.Write "<th>" & RS.Fields(Ctr).Name & "</th>"
			Next
		Response.Write "</tr>"

		'Fill in the cells with data.
		Do While Not RS.EOF
			Response.Write "<tr>"
				For Ctr = 0 To RS.Fields.Count - 1
	      			If RS.Fields(Ctr).Name = "%Passed" OR RS.Fields(Ctr).Name = "%Failed" Then
						Response.Write "<td>" & FormatPercent(RS(ctr)) & "&nbsp;</td>"
					
					ElseIf RS.Fields(Ctr).Name = "DPM" Then
						Response.Write "<td>" & CLng(RS(ctr)) & "&nbsp;</td>"
					
					Else
						Response.Write "<td>" & RS.Fields(Ctr) & "&nbsp;</td>"
					End If
				Next
				Response.Write "</tr>"
		
			RS.MoveNext
		Loop
	
	Response.Write "</table>"
	Response.Write "</center>"	

	Response.Write "<br><br>"
End If

	RS.Close
	Set RS = Nothing

End Sub

%> </p>
</body>
</html>
