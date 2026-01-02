<%Option Explicit%>
<html>

<head>
<meta name="GENERATOR" content="Microsoft FrontPage 3.0">
<title>A Query</title>

<meta name="Microsoft Theme" content="indust 101"></head>

<body background="../_themes/indust/indtextb.jpg" bgcolor="#FFFFFF" text="#000000" link="#3366CC" vlink="#666666" alink="#FF3300"><!--mstheme--><font face="trebuchet ms, arial, helvetica">

<h2 align="center"><!--mstheme--><font color="#CC6666">Yield Breakdown<!--mstheme--></font></h2>

<!--msthemeseparator--><p align="center"><img src="../_themes/indust/indhorsd.gif" width="300" height="10"></p>

<p><%
	Dim CONN
	Dim QUERY	
	
	Dim START_DATE
	Dim END_DATE


	Dim rsDefectCategoryNames


	'On Error Resume Next

	Call ShowQueryDates

	Call CreateQueryDates (START_DATE, END_DATE)

	Set CONN = Server.CreateObject("ADODB.Connection")
	CONN.Open Application("ProductionDatabase")

	Call GetDefectCategoryNames
'	Call Temp
	Call OverallYields
	Call ProductFamilyYields
'	Call PartNumberYields

%> </p>
<!--mstheme--></font></body>
</html>
<%


'-------------------------------------------------------------------------------------------------------------
Sub OverallYields()

	Dim intTotal
	Dim Ctr
	Dim rsTotal
	Dim rsDefects



	QUERY = "SELECT Count(PartNumber) As Total, " & _
			 "Sum(Results) As Passed, " & _
			 "Sum(Results) / Count(PartNumber) As FPY " & _
			 "FROM Index " & _
			 "WHERE (Seq = 1) AND StartTime BETWEEN " & START_DATE & " AND " & END_DATE

	Set rsTotal = CONN.Execute(QUERY)

	intTotal = rsTotal.Fields("Total")


	QUERY = "SELECT " & _
				"F.DefectCategory, " & _
				"Count(F.DefectCategory) AS Count " & _
			 "FROM " & _
				"FailureInformation As F, " & _
				"Index AS I " & _
			 "WHERE " & _
				"(I.Seq = 1) AND " & _
				"(I.ID = F.ID) AND " & _
				"StartTime BETWEEN " & START_DATE & " AND " & END_DATE & " " & _
			"GROUP BY " & _
				"F.DefectCategory"

	Set rsDefects = CONN.Execute(QUERY)


	Response.Write "<h3 align='center'> Overall Yields  </h3>"
	Response.Write "<div align='center'><center>"

	Response.Write "<table BORDER = '3.0' cellspacing='0'>"


	Call CreateTableHeader(rsTotal)


		Response.Write "<tr>"
			Response.Write "<td>" & intTotal & "</td>"
			Response.Write "<td>" & rsTotal("Passed") & "</td>"
			Response.Write "<td>" & FormatPercent(rsTotal("FPY")) & "</td>"

			Call ShowDefectBreakdown(rsDefects, intTotal)

		Response.Write "</tr>"

	
	Response.Write "</table>"
	Response.Write "</center>"	
	Response.Write "<br> <br> <br>"

End Sub


'-------------------------------------------------------------------------------------------------------------
Sub ProductFamilyYields()

	Dim Ctr
	Dim rsTotal
	Dim rsDefects

	QUERY = "SELECT " & _
				"PN.ProductFamily, " & _
				"F.DefectCategory, " & _
				"Count(F.DefectCategory) AS Count " & _
			 "FROM " & _
				"FailureInformation As F, " & _
				"Index AS I, " & _
				"PartNumbers AS PN " & _
			 "WHERE " & _
				"(I.Seq = 1) AND " & _
	     		"I.PartNumber = PN.PartNumber AND " & _
				"(I.ID = F.ID) AND " & _
				"(I.StartTime BETWEEN " & START_DATE & " AND " & END_DATE & ") " & _
			 "GROUP BY PN.ProductFamily, F.DefectCategory"

	Set rsDefects = CONN.Execute(QUERY)


	QUERY = "SELECT PN.ProductFamily, " & _
			 "Count(I.PartNumber) As Total, " & _
			 "Sum(I.Results) As Passed, " & _
			 "Sum(I.Results) / Count(I.PartNumber) As FPY " & _
			 "FROM Index AS I, PartNumbers AS PN " & _
			 "WHERE (I.Seq = 1) AND " & _
			 "(I.StartTime BETWEEN " & START_DATE & " AND " & END_DATE & ") AND " & _
			 "I.PartNumber = PN.PartNumber " & _
			 "GROUP BY PN.ProductFamily"

	Set rsTotal = CONN.Execute(QUERY)


	Response.Write "<h3 align='center'> By Product Family  </h3>"
	Response.Write "<div align='center'><center>"

	Response.Write "<table BORDER = '3.0' cellspacing='0'>"


	Call CreateTableHeader(rsTotal)


	Do While Not rsTotal.EOF

		Response.Write "<tr>"
			Response.Write "<td>" & rsTotal("ProductFamily") & "</td>"
			Response.Write "<td>" & rsTotal("Total") & "</td>"
			Response.Write "<td>" & rsTotal("Passed") & "</td>"
			Response.Write "<td>" & FormatPercent(rsTotal("FPY")) & "</td>"

		rsDefects.Filter = "ProductFamily = '" & rsTotal("ProductFamily") & "'"

		Call ShowDefectBreakdown(rsDefects, rsTotal("Total"))

		Response.Write "</tr>"
		
		rsTotal.MoveNext

	Loop

	
	Response.Write "</table>"
	Response.Write "</center>"	
	Response.Write "<br> <br> <br>"

End Sub



'-------------------------------------------------------------------------------------------------------------
Sub PartNumberYields()

	Dim Ctr
	Dim rsTotal
	Dim rsDefects

	QUERY = "SELECT " & _
				"I.PartNumber, " & _
				"F.DefectCategory, " & _
				"Count(F.DefectCategory) AS Count " & _
			 "FROM " & _
				"FailureInformation As F, " & _
				"Index AS I " & _
			 "WHERE " & _
				"(I.Seq = 1) AND " & _
				"(I.ID = F.ID) AND " & _
				"(I.StartTime BETWEEN " & START_DATE & " AND " & END_DATE & ") " & _
			 "GROUP BY I.PartNumber, F.DefectCategory"

	Set rsDefects = CONN.Execute(QUERY)


	QUERY = "SELECT I.PartNumber, " & _
			 "Count(I.PartNumber) As Total, " & _
			 "Sum(I.Results) As Passed, " & _
			 "Sum(I.Results) / Count(I.PartNumber) As FPY " & _
			 "FROM Index AS I " & _
			 "WHERE (I.Seq = 1) AND " & _
			 "(I.StartTime BETWEEN " & START_DATE & " AND " & END_DATE & ") " & _
			 "GROUP BY I.PartNumber"

	Set rsTotal = CONN.Execute(QUERY)


	Response.Write "<h3 align='center'> By Part Number  </h3>"
	Response.Write "<div align='center'><center>"

	Response.Write "<table BORDER = '3.0' cellspacing='0'>"


	Call CreateTableHeader(rsTotal)


	Do While Not rsTotal.EOF

		Response.Write "<tr>"
			Response.Write "<td>" & rsTotal("PartNumber") & "</td>"
			Response.Write "<td>" & rsTotal("Total") & "</td>"
			Response.Write "<td>" & rsTotal("Passed") & "</td>"
			Response.Write "<td>" & FormatPercent(rsTotal("FPY")) & "</td>"

		rsDefects.Filter = "PartNumber = '" & rsTotal("PartNumber") & "'"

		Call ShowDefectBreakdown(rsDefects, rsTotal("Total"))

		Response.Write "</tr>"
		
		rsTotal.MoveNext

	Loop

	
	Response.Write "</table>"
	Response.Write "</center>"	
	Response.Write "<br> <br> <br>"

End Sub




'-------------------------------------------------------------------------------------------------------------
Sub GetDefectCategoryNames()

	QUERY = "SELECT " & _
				"DISTINCT F.DefectCategory " & _
			 "FROM " & _
				"Index AS I, " & _
				"FailureInformation AS F " & _
			 "WHERE " & _
				"(I.ID = F.ID) AND " & _
				"I.Seq = 1 AND " & _
				"StartTime BETWEEN " & START_DATE & " AND " & END_DATE & " " & _
			"ORDER BY F.DefectCategory"	

	Set rsDefectCategoryNames = CONN.Execute(QUERY)

End Sub


'-------------------------------------------------------------------------------------------------------------
Sub CreateTableHeader(rsRecord)

	Dim Ctr

	'Reset the defect name record set.
	rsDefectCategoryNames.MoveFirst

	Response.Write "<tr>"

	For Ctr = 0 To rsRecord.Fields.Count - 1
		Response.Write "<th>" & rsRecord.Fields(Ctr).Name & "</th>"
	Next

	Do While Not rsDefectCategoryNames.EOF
		Response.Write "<th>" & rsDefectCategoryNames(0) & "</th>"
		rsDefectCategoryNames.MoveNext
	Loop

	Response.Write "</tr>"

End Sub



'-------------------------------------------------------------------------------------------------------------
Sub ShowDefectBreakdown(rsRecord, intTotal)

	Dim Ctr
	Dim MyData()
	Dim DataCtr
	

	'On Error Resume Next

	'Don't try to do anything if no defect information exists.
	If rsRecord.EOF Then
		rsDefectCategoryNames.MoveFirst
		
		Do While Not rsDefectCategoryNames.EOF
			Response.Write "<td>.</td>"
			rsDefectCategoryNames.MoveNext
		Loop
	
		Exit Sub
	End If


	'Consolidate information into one variable.
	rsDefectCategoryNames.MoveFirst
	Do While Not rsDefectCategoryNames.EOF

		'Add more elements to the array.
		DataCtr = DataCtr + 1
		Redim Preserve MyData(DataCtr)
		MyData(DataCtr - 1) = 0


		rsRecord.MoveFirst

		'Copy all of the defect information into the array.
		Do While Not rsRecord.EOF
			If rsDefectCategoryNames(0) = rsRecord.Fields("DefectCategory") Then
				MyData(DataCtr - 1) = rsRecord.Fields("Count")
				Exit Do
			End If
			rsRecord.MoveNext
		Loop
	
		rsDefectCategoryNames.MoveNext
	Loop


	'Display the information.
	For Ctr = 0 To DataCtr - 1
		If MyData(Ctr) = 0 Then
			Response.Write "<td>&nbsp;</td>"
		Else
			Response.Write "<td>" & FormatPercent(MyData(Ctr)/intTotal) & "</td>"
		End If
	Next

	
End Sub


'-------------------------------------------------------------------------------------------------------------
Sub CreateQueryDates(StartDate, EndDate)

	StartDate = CDbl(CDate(Request("StartYear") & "-" 	& Request("StartMonth") & "-" &	Request("StartDay")))
	EndDate   = CDbl(CDate(Request("EndYear")   & "-" & Request("EndMonth")    & "-" & 	Request("EndDay"))) + 1 

End Sub


'-------------------------------------------------------------------------------------------------------------
Sub ShowQueryDates()

	Dim StartDate
	Dim EndDate
	
	StartDate = Request("StartMonth") & "/" & Request("StartDay") & "/" & Request("StartYear")
	EndDate   = Request("EndMonth")   & "/" & Request("EndDay")   & "/" & Request("EndYear")

	if StartDate = EndDate Then
		Response.Write "<center>" & StartDate & "</center><P>"
	else
		Response.Write "<center>" & StartDate & "&nbsp;&nbsp;&nbsp;" & "   To   " & "&nbsp;&nbsp;&nbsp;" & EndDate & "</center><P>"
	end if

End Sub


'-------------------------------------------------------------------------------------------------------------
Sub GenericQueryResultsDisplay(ByVal RS)

	Dim Ctr

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
 					Response.Write "<td>" & RS.Fields(Ctr) & "</td>"
				Next
			Response.Write "</tr>"
		
			RS.MoveNext
		Loop
	
		Response.Write "</table>"
		Response.Write "</center>"	
	
	End If

End Sub




'-------------------------------------------------------------------------------------------------------------
Sub Temp

	Dim RS

	QUERY = "SELECT " & _
				"F.DefectCategory, " & _
				"Count(F.DefectCategory) AS DefectCount, " & _
				"Count(I.Results) AS Total " & _
			
			"FROM Index AS I LEFT JOIN FailureInformation AS F ON " & _
      		"(" & _
				"I.ID = F.ID AND " & _
	      		"I.Seq = 1 AND " & _
				"I.StartTime BETWEEN " & START_DATE & " AND " & END_DATE & _ 
			") " & _
   			
			"GROUP BY F.DefectCategory"


	Set RS = CONN.Execute(QUERY)



	Dim DEFECT_LIST

	Set DEFECT_LIST = CreateObject("Scripting.Dictionary")


	Do While Not rsDefectCategoryNames.EOF
		DEFECT_LIST.Add rsDefectCategoryNames(0), 0.0
		rsDefectCategoryNames.MoveNext
	Loop

		DEFECT_LIST.Add "Me", 123

	Dim Ctr
	DIM LIST_KEY

	LIST_KEY = DEFECT_LIST.Keys




	For Ctr = 0 To DEFECT_LIST.Count - 1
		Response.Write LIST_KEY(Ctr) & " <BR>"
	Next


	DEFECT_LIST.RemoveAll

	Set DEFECT_LIST = Nothing


'	Call TempDisplay(RS, "Overall", "")
'	GenericQueryResultsDisplay(RS)

exit sub



	'--------------------------------------------------------------------------------------
	'By Product Family

	QUERY = "SELECT " & _
				"P.ProductFamily, " & _
				"F.DefectCategory, " & _
				"Count(F.DefectCategory) AS DefectCount, " & _
				"Count(I.Results) AS Total " & _

			"FROM  " & _
				"(INDEX AS I LEFT JOIN PartNumbers AS P ON P.PartNumber = I.PartNumber) " & _
			 	"LEFT JOIN FailureInformation AS F ON " & _
				"(" & _
					"I.ID = F.ID AND " & _
					"I.Seq = 1 AND  " & _
					"I.StartTime BETWEEN " & START_DATE & " AND " & END_DATE & " " & _
				") " & _

			"GROUP BY P.ProductFamily, F.DefectCategory"


	Set RS = CONN.Execute(QUERY)
	Call TempDisplay(RS, "By Product Model", "ProductFamily")
'	GenericQueryResultsDisplay(RS)


exit sub

	'--------------------------------------------------------------------------------------
	'By Part Number

	QUERY = "SELECT " & _
				"I.PartNumber, " & _
				"F.DefectCategory, " & _
				"Count(F.DefectCategory) AS DefectCount, " & _
				"Count(I.Results) AS Total " & _

			"FROM INDEX AS I LEFT JOIN FailureInformation AS F ON " & _
			"(" & _
				"I.ID = F.ID AND " & _
				"I.Seq = 1 AND  " & _
				"I.StartTime BETWEEN " & START_DATE & " AND " & END_DATE & " " & _
			") " & _

			"GROUP BY I.PartNumber, F.DefectCategory"


	Response.write Query & "<BR><BR>By Part Number<BR><BR>"
	Set RS = CONN.Execute(QUERY)
	GenericQueryResultsDisplay(RS)



End Sub



'-------------------------------------------------------------------------------------------------------------
Sub TempDisplay(rsRecord, TableDescription, ExtraField)

	Dim Ctr
	Dim MyData()
	Dim DataCtr
	
	Dim intTotal
	Dim intPassed
	Dim dblFPY

	Response.Write "<h3 align='center'>" & TableDescription & "</h3>"

	Response.Write "<table BORDER = '3.0'>"

	'----------------------- Create Header -----------------------
	'Reset the defect name record set.
	rsDefectCategoryNames.MoveFirst

	Response.Write "<tr>"

	If ExtraField <> "" Then
		Response.Write "<th>" & ExtraField & "</th>"
	End If

	'Standard field names.
	Response.Write "<th>Total</th>"
	Response.Write "<th>Passed</th>"
	Response.Write "<th>FPY</th>"

	Do While Not rsDefectCategoryNames.EOF
		Response.Write "<th>" & rsDefectCategoryNames(0) & "</th>"
		rsDefectCategoryNames.MoveNext
	Loop

	Response.Write "</tr>"



	'----------------------- Create Table Body -----------------------

	'Consolidate information into more convenient variable.
	intTotal = 0
	intPassed = 0
	dblFPY = 0.0

	rsDefectCategoryNames.MoveFirst
	Do While Not rsDefectCategoryNames.EOF

		'Add more elements to the array.
		DataCtr = DataCtr + 1
		Redim Preserve MyData(DataCtr)
		MyData(DataCtr - 1) = 0


		rsRecord.MoveFirst

		'Copy all of the defect information into the array.
		Do While Not rsRecord.EOF

			If IsNull (rsRecord.Fields("DefectCategory")) Then
				intPassed = rsRecord.Fields("Total")

			ElseIf rsDefectCategoryNames(0) = rsRecord.Fields("DefectCategory") Then
				MyData(DataCtr - 1) = rsRecord.Fields("DefectCount")
				Exit Do
			End If

			rsRecord.MoveNext
		Loop
	
		rsDefectCategoryNames.MoveNext
	Loop


		'Get total and passed information.
		rsRecord.MoveFirst
		Do While Not rsRecord.EOF

			intTotal = intTotal + rsRecord.Fields("Total")

			If IsNull (rsRecord.Fields("DefectCategory")) Then
				intPassed = rsRecord.Fields("Total")
			End If

			rsRecord.MoveNext
		Loop


	'Calculate first pass fields.
	If intTotal <> 0 then dblFPY = intPassed/intTotal

	'Display the row of information.

	If ExtraField <> "" Then
		Response.Write "<td>" & rsRecord.Field(0) & "</td>"
	End If

	'Standard field names.
	Response.Write "<td>" & intTotal & "</td>"
	Response.Write "<td>" & intPassed & "</td>"
	Response.Write "<td>" & FormatPercent(dblFPY) & "</td>"

	
	For Ctr = 0 To DataCtr - 1
		If MyData(Ctr) = 0 Then
			Response.Write "<td>.</td>"
		Else
			Response.Write "<td>" & FormatPercent(MyData(Ctr)/intTotal) & "</td>"
		End If
	Next


	'End of table.	
	Response.Write "</table>"


End Sub


%>
