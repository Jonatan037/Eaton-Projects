<%Option Explicit%>
<html>

<head>
<title>Monthly Yield Report</title>
</head>

<body>

<p><%
	Dim Conn
	Dim Query	
	Dim QueryStartDate
	Dim QueryEndDate

	Dim intTotalDays

	Dim intTotalTested
	Dim intDay
	Dim dblYields

	Dim intWorkmanship
	Dim intOperatorError
	Dim intComponent
	Dim intTestEquipment
	Dim intNotAnalyzed
	Dim intDesign
	
	Dim Ctr
	Dim strProductName

	Dim rsProductModels
	Dim rsDefectInformation
	Dim rsFirstPassYields

	'On Error Resume Next


	'--------------------------------------------------------------------------------------------------------

	'Determine query dates.

	intTotalDays = DaysInMonth(Request("StartMonth"), Request("StartYear"))

	QueryStartDate = CDbl(CDate(Request("StartMonth") & "/01/" & Request("StartYear")))
	QueryEndDate = QueryStartDate + intTotalDays - 1


	Response.Write "<h2 align='center'>Monthly Reports For " & MonthName(Request("StartMonth")) & "  " & Request("StartYear") & _
	"<br>" & CDate(QueryStartDate) & " to " & CDate(QueryEndDate) & "</h2>"



	'-----------------------------------------------
	'Connect to the database

	Set Conn = Server.CreateObject("ADODB.Connection")
	Conn.Open Application("ProductionDatabase")


	'-----------------------------------------------

	Call GetProductModels(rsProductModels)
	'DisplayQueryResults(rsProductModels)

	Call GetDefectInformation (rsDefectInformation)
	'DisplayQueryResults(rsDefectInformation)

	Call GetFirstPassYields(rsFirstPassYields)
	'DisplayQueryResults(rsFirstPassYields)

	'-----------------------------------------------
	Response.Write "<center>"

	'Create separate tables for each product model.
	Do While Not rsProductModels.EOF

		strProductName = rsProductModels.Fields("ProductFamily")

		rsDefectInformation.Filter = "ProductFamily = '" & strProductName & "'"
		rsFirstPassYields.Filter = "ProductFamily = '" & strProductName & "'"

		'Resize variables to hold a months worth of data.
		Redim intDay(intTotalDays)
		Redim intTotalTested(intTotalDays)

		Redim dblYields(intTotalDays)
		Redim intWorkmanship(intTotalDays)
		Redim intOperatorError(intTotalDays)
		Redim intComponent(intTotalDays)
		Redim intTestEquipment(intTotalDays)
		Redim intNotAnalyzed(intTotalDays)
		Redim intDesign(intTotalDays)




		'Clear all of the arrays.
		For Ctr = 0 To intTotalDays - 1
			intDay(Ctr) = Ctr + 1			
			intTotalTested(Ctr) = 0

			dblYields(Ctr) = 0.0
			intWorkmanship(Ctr) = 0
			intOperatorError(Ctr) = 0
			intComponent(Ctr) = 0
			intTestEquipment(Ctr) = 0
			intNotAnalyzed(Ctr) = 0
			intDesign(Ctr) = 0

		Next

			
		'Fill in arrays with yield information.
		Do While Not rsFirstPassYields.EOF
			Ctr = rsFirstPassYields.Fields("Day") - 1

			intTotalTested(Ctr) = rsFirstPassYields.Fields("Total")
			dblYields(Ctr) = rsFirstPassYields.Fields("Yields")

			'Save monthly total information.
			intTotalTested(intTotalDays - 1) = intTotalTested(intTotalDays - 1) + rsFirstPassYields.Fields("Total")
			dblYields(intTotalDays - 1) = dblYields(intTotalDays - 1) + rsFirstPassYields.Fields("Passed")

			rsFirstPassYields.MoveNext
		Loop

		'Calculate monthly first pass yields.
		dblYields(intTotalDays - 1) = dblYields(intTotalDays - 1) / intTotalTested(intTotalDays - 1)

		'Fill in arrays with defect information.
		Do While Not rsDefectInformation.EOF
			Ctr = rsDefectInformation.Fields("Day") - 1
			
			If rsDefectInformation.Fields("DefectCategory") = "Workmanship" Then
				intWorkmanship(Ctr) = rsDefectInformation.Fields("Count")
				intWorkmanship(intTotalDays - 1) = intWorkmanship(intTotalDays - 1) + intWorkmanship(Ctr)

			ElseIf rsDefectInformation.Fields("DefectCategory") = "Operator Error" Then
				intOperatorError(Ctr) = rsDefectInformation.Fields("Count")
				intOperatorError(intTotalDays - 1) = intOperatorError(intTotalDays - 1) + intOperatorError(Ctr)

			ElseIf rsDefectInformation.Fields("DefectCategory") = "Component" Then
				intComponent(Ctr) = rsDefectInformation.Fields("Count")
				intComponent(intTotalDays - 1) = intComponent(intTotalDays - 1) + intComponent(Ctr)

			ElseIf rsDefectInformation.Fields("DefectCategory") = "Test Equipment" Then
				intTestEquipment(Ctr) = rsDefectInformation.Fields("Count")
				intTestEquipment(intTotalDays - 1) = intTestEquipment(intTotalDays - 1) + intTestEquipment(Ctr)

			ElseIf rsDefectInformation.Fields("DefectCategory") = "Not Analyzed" Then
				intNotAnalyzed(Ctr) = rsDefectInformation.Fields("Count")
				intNotAnalyzed(intTotalDays - 1) = intNotAnalyzed(intTotalDays - 1) + intNotAnalyzed(Ctr)

			ElseIf rsDefectInformation.Fields("DefectCategory") = "Design" Then
				intDesign(Ctr) = rsDefectInformation.Fields("Count")
				intDesign(intTotalDays - 1) = intDesign(intTotalDays - 1) + intDesign(Ctr)
			End If

			rsDefectInformation.MoveNext
		Loop


		Response.Write "Report For " & strProductName & "<br>"

		Response.Write "<table BORDER = '3.0' cellspacing='0'>"

		'Create the table header row.
  		Response.Write "<tr>"
			Response.Write "<th> Day </th>"
			Response.Write "<th> Total </th>"
			Response.Write "<th> FPY </th>"

			Response.Write "<th> Workmanship </th>"
			Response.Write "<th> Operator Error </th>"
			Response.Write "<th> Component </th>"
			Response.Write "<th> Test Equipment </th>"
			Response.Write "<th> Not Analyzed </th>"
			Response.Write "<th> Design </th>"




		Response.Write "</tr>"


		For Ctr = 0 To intTotalDays - 2
			Response.Write "<tr>"
	
			Response.Write "<td>" & intDay(Ctr) & "</td>"

			If intTotalTested(Ctr) = 0 Then
				Response.Write "<td bgcolor = '#C0C0C0'> &nbsp; </td>"
				Response.Write "<td bgcolor = '#C0C0C0'> &nbsp; </td>"

				'Start of defect information.
				Response.Write "<td bgcolor = '#C0C0C0'> &nbsp; </td>"
				Response.Write "<td bgcolor = '#C0C0C0'> &nbsp; </td>"
				Response.Write "<td bgcolor = '#C0C0C0'> &nbsp; </td>"
				Response.Write "<td bgcolor = '#C0C0C0'> &nbsp; </td>"
				Response.Write "<td bgcolor = '#C0C0C0'> &nbsp; </td>"
				Response.Write "<td bgcolor = '#C0C0C0'> &nbsp; </td>"


			Else
				Response.Write "<td>" & intTotalTested(Ctr) 				& "</td>"
				Response.Write "<td>" & FormatPercent(dblYields(Ctr)) 	& "</td>"

				'Start of defect information.					       
				Response.Write "<td>" & intWorkmanship(Ctr) 		& "</td>"
				Response.Write "<td>" & intOperatorError(Ctr) 	& "</td>"
				Response.Write "<td>" & intComponent(Ctr) 		& "</td>"
				Response.Write "<td>" & intTestEquipment(Ctr) 	& "</td>"
				Response.Write "<td>" & intNotAnalyzed(Ctr) 		& "</td>"
				Response.Write "<td>" & intDesign(Ctr) 			& "</td>"

			End If

			Response.Write "</tr>"
		Next


		'Show monthly totals row.
		Response.Write "<th>Total</th>"
		Response.Write "<th>" & intTotalTested(intTotalDays - 1) 				& "</th>"
		Response.Write "<th>" & FormatPercent(dblYields(intTotalDays - 1)) 	& "</th>"
		Response.Write "<th>" & intWorkmanship(intTotalDays - 1) 				& "</th>"
		Response.Write "<th>" & intOperatorError(intTotalDays - 1) 			& "</th>"
		Response.Write "<th>" & intComponent(intTotalDays - 1) 				& "</th>"
		Response.Write "<th>" & intTestEquipment(intTotalDays - 1) 			& "</th>"
		Response.Write "<th>" & intNotAnalyzed(intTotalDays - 1) 				& "</th>"
		Response.Write "<th>" & intDesign(intTotalDays - 1) 					& "</th>"

		
		Response.Write "</table>"
		Response.Write "<br><br>"

		rsProductModels.MoveNext
	Loop

	
	Response.Write "</center>"	



%> </p>
</body>
</html>
<%


'--------------------------------------------------------------------------------------------------------
Sub DisplayQueryResults(RS)

	Dim Ctr

	Dim LastProduct
	Dim intColSpan

	' Check for error.
	If Err.Description <> "" Then
		Response.Write "<B>Error " + Hex(Err) + ": " + Err.Description + "</B><br>"

	' Check for no-record case.
	ElseIf RS.EOF And RS.BOF Then 
		Response.Write "No records were found. <br>"

	' Valid data was received from the query.
	Else


	Response.Write "<div align='center'><center>"
	Response.Write "<table BORDER = '3.0'>"

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
	      			If RS.Fields(Ctr).Name = "Yields" Then
						Response.Write "<td>" & FormatPercent(RS("Yields")) & "</td>"
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



'--------------------------------------------------------------------------------------------------------
Function DaysInMonth(intMonth, intYear)

	Select Case intMonth

		Case 2
			If (intYear Mod 4 ) = 0 Then
				DaysInMonth = 29
			Else
				DaysInMonth = 28
			End If

		Case 4, 6, 9, 10
			DaysInMonth = 30

		Case Else
			DaysInMonth = 31

	End Select

	DaysInMonth = DaysInMonth + 1


End Function



'--------------------------------------------------------------------------------------------------------
Sub GetFirstPassYields(RS)

	Dim Query	

	Query = "SELECT " & _
				"PN.ProductFamily, " & _
			 	"Day(I.StartTime) As Day, " & _
				"Count(I.PartNumber) As Total, " & _
			 	"Sum(I.Results) As Passed, " & _
			 	"Sum(I.Results) / Count(I.PartNumber) As Yields " & _

			 "FROM " & _
				"Index AS I, " & _
				"PartNumbers AS PN " & _

			 "WHERE " & _
				"(I.Seq = 1) AND " & _
			 	"(I.PartNumber = PN.PartNumber) AND " & _
				"(I.StartTime BETWEEN " & QueryStartDate & " AND " & QueryEndDate & ") " & _
				
			 "GROUP BY " & _
				"PN.ProductFamily, " & _
				"Day(I.StartTime)"


	Set RS = Conn.Execute(Query)

End Sub



'--------------------------------------------------------------------------------------------------------
Sub GetProductModels(RS)

	Dim Query

	Query = "SELECT " & _
				"DISTINCT PN.ProductFamily " & _

			 "FROM " & _
				"PartNumbers AS PN, " & _
				"Index AS I " & _
				
			 "WHERE " & _
				"(I.Seq = 1) AND " & _
			 	"(I.PartNumber = PN.PartNumber) AND " & _
				"(I.StartTime BETWEEN " & QueryStartDate & " AND " & QueryEndDate & ") " & _

			"ORDER BY PN.ProductFamily"


	Set RS = Conn.Execute(Query)

End Sub




'--------------------------------------------------------------------------------------------------------
Sub GetDefectInformation(RS)

	Dim Query

	Query = "SELECT " & _
				"PN.ProductFamily, " & _
				"Day(I.StartTime) AS Day, " & _
				"F.DefectCategory, " & _
				"Count(F.DefectCategory) AS Count " & _

			 "FROM " & _
				"PartNumbers AS PN, " & _
				"FailureInformation As F, " & _
				"Index AS I " & _
				
			 "WHERE " & _
				"(I.Seq = 1) AND " & _
			 	"(I.PartNumber = PN.PartNumber) AND " & _
				"(I.ID = F.ID) AND " & _
				"(I.StartTime BETWEEN " & QueryStartDate & " AND " & QueryEndDate & ") " & _

			"GROUP BY " & _
				"PN.ProductFamily, " & _
				"Day(I.StartTime), " & _
				"F.DefectCategory"


	Set RS = Conn.Execute(Query)

End Sub



%>
