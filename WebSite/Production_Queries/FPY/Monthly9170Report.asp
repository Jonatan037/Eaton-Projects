<%Option Explicit%>
<html>

<head>
<title>Monthly Yield Report</title>
</head>

<body>
<%
	Const Family = "9170"

	Dim Conn
	Dim Query	
	Dim QueryStartDate
	Dim QueryEndDate
	Dim DaysInMonth			

	Dim vt(32, 11)			'A virtual table in which to consolidate all of the information.
	Const colDay = 0			'Column of the virtual table containing the day of the month.
	Const colTested = 1
	Const colPassed = 2
	Const colFailed = 3
	Const colDPM = 4
	Const colNotAnalyzed = 1
	Const colOperatorError = 2
	Const colComponent = 3
	Const colDesign = 4
	Const colTestEquipment = 5
	Const colWorkmanship = 6
	Const colAdjusted = 11		'Yields recalated with the operator and test equipment errors removed.

	Dim intTested				'Total units tested this month.
	Dim intPassed				'Total units that passed this month.

	'On Error Resume Next

	'Determine query dates.
	DaysInMonth = GetDaysInMonth(Request("StartMonth"), Request("StartYear"))
	QueryStartDate = CDbl(CDate(Request("StartMonth") & "/01/" & Request("StartYear")))
	QueryEndDate = QueryStartDate + DaysInMonth


	Response.Write "<h2 align='center'>" & Family & " Monthly Yield Report<br> " & MonthName(Request("StartMonth")) & "  " & Request("StartYear") & " <br></h2>"


	'-----------------------------------------------
	'Connect to the database

	Set Conn = Server.CreateObject("ADODB.Connection")
	Conn.Open Application("ProductionDatabase")

	Call GetFirstPassYields()
	Call GetDefectTotals()
	DisplayResults()



'--------------------------------------------------------------------------------------------------------
Sub DisplayResults()

	Dim ctrDay
	Dim ctrCol


	Response.Write "<div align='center'><center>"
	Response.Write "<table BORDER = '3.0' cellspacing='0' cellpadding='0'>"

	For ctrDay = 0 to DaysInMonth

		Response.Write "<tr>"

			For ctrCol = 0 To 11
				If IsEmpty(vt(ctrDay, ctrCol)) Then vt(ctrDay, ctrCol) = "&nbsp;"
				Response.Write "<td  align='center'>" & vt(ctrDay, ctrCol) & "</td>"
			Next

		Response.Write "</tr>"
	Next

	'Show totals
	Response.Write "<tr>"
		For ctrCol = 0 to 11
			If IsEmpty(vt(32, ctrCol)) Then vt(32, ctrCol) = "&nbsp;"
			Response.Write "<td  align='center'>" & vt(32, ctrCol) & "</td>"
		Next
	Response.Write "</tr>"

	Response.Write "</table>"


	Response.Write "<br>OE = Operator Error<br>TE = Test Equipment<br>"
	Response.Write "Adjusted FPY = First Pass Yields with OE and TE errors removed.<br>"

	Response.Write "</center>"	

	Response.Write "<br><br>"

End Sub



'--------------------------------------------------------------------------------------------------------
Function GetDaysInMonth(intMonth, intYear)

	Select Case intMonth

		Case 2
			If (intYear Mod 4 ) = 0 Then
				GetDaysInMonth = 29
			Else
				GetDaysInMonth = 28
			End If

		Case 4, 6, 9, 11
			GetDaysInMonth = 30

		Case Else
			GetDaysInMonth = 31

	End Select

End Function



'--------------------------------------------------------------------------------------------------------
Sub GetFirstPassYields()

	Dim Query	
	Dim RS
	Dim Ctr
	Dim FPY

	Query = "SELECT " & _
			 	"Day(I.StartTime) As Day, " & _
				"Count(I.PartNumber) As Tested, " & _
			 	"Sum(I.Results) As [Passed] " & _

			 "FROM " & _
				"Index AS I, " & _
				"PartNumbers AS PN " & _

			 "WHERE " & _
				"(I.Seq = 1) AND " & _
			 	"(I.PartNumber = PN.PartNumber) AND " & _
				"(I.StartTime BETWEEN " & QueryStartDate & " AND " & QueryEndDate & ") AND " & _
              "PN.Family = '" & Family & "' "  & _            

				
			 "GROUP BY " & _
				"Day(I.StartTime)"

	'Response.Write Query & "<br>"


	Set RS = Conn.Execute(Query)

	'Fill in the day of the month.
	For ctr = 1 to 31
		vt(ctr,colDay) = ctr
		vt(ctr,colTested) = 0
	Next

	'Column headers.
	vt(0, colDay)    = "Day"	
	vt(0, colTested) = "Tested"
	vt(0, colPassed) = "% Passed"
	vt(0, colFailed) = "% Failed"
	vt(0, colDPM)    = "DPM" 

	vt(0, colDPM + 1)    = "Not Analyzed" 
	vt(0, colDPM + 2)    = "Operator Error" 
	vt(0, colDPM + 3)    = "Component" 
	vt(0, colDPM + 4)    = "Design" 
	vt(0, colDPM + 5)    = "Test Equipment" 
	vt(0, colDPM + 6)    = "Workmanship" 



	vt(32,colTested) = 0
	vt(32,colDay) = "Total"

	If RS.EOF And RS.BOF Then Exit Sub

	'Fill in the cells with the statistical data.
	Do While Not RS.EOF	
	      	
		'Daily values.
		vt(RS("Day"), colTested) = RS("Tested")
		FPY = RS("Passed") / RS("Tested")
		vt(RS("Day"), colPassed) = FormatPercent(FPY)
		vt(RS("Day"), colFailed) = FormatPercent(1 - FPY)
		vt(RS("Day"), colDPM) = CLng((1 - FPY) * 1000000)
		
		'Save the starting point for the adjusted yields.
		vt(RS("Day"), colAdjusted) = CDbl(RS("Passed"))

		'Monthly totals.
		vt(32,colTested) = vt(32,colTested) + RS("Tested")
		vt(32,colPassed) = vt(32,colPassed) + RS("Passed")

		vt(32,colAdjusted) = vt(32,colAdjusted) + RS("Passed")

		RS.MoveNext
	Loop
	
	FPY = vt(32,colPassed) / vt(32,colTested)
	vt(32,colPassed) = FormatPercent(FPY)
	vt(32,colFailed) = FormatPercent(1 - FPY)
	vt(32,colDPM)    = CLng((1 - FPY) * 1000000)
	'vt(32,colPassed) = FormatPercent(vt(32,colPassed))


End Sub


'--------------------------------------------------------------------------------------------------------
Sub GetDefectTotals()

	Dim Query	
	Dim RS
	Dim Ctr

	Query = "SELECT " & _
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
				"(I.StartTime BETWEEN " & QueryStartDate & " AND " & QueryEndDate & ") AND " & _
              "PN.Family = '" & Family & "' "  & _       

			"GROUP BY " & _
				"Day(I.StartTime), " & _
				"F.DefectCategory"

	Set RS = Conn.Execute(Query)

	'Column headers.
	vt(0, colDPM + 1)    = "Not Analyzed" 
	vt(0, colDPM + 2)    = "OE" 
	vt(0, colDPM + 3)    = "Component" 
	vt(0, colDPM + 4)    = "Design" 
	vt(0, colDPM + 5)    = "TE" 
	vt(0, colDPM + 6)    = "Workmanship" 
	vt(0, colDPM + 7)    = "Adjusted FPY" 


	If RS.EOF And RS.BOF Then Exit Sub

	'Fill in the cells with the statistical data.
	Do While Not RS.EOF	
	      	
		'Daily values.
		vt(RS("Day"), RS("DefectCategory") + colDPM) = RS("Count")

		'Add OE and TE errors back into passed unit total.
		If (RS("DefectCategory") = colOperatorError Or RS("DefectCategory")  = colTestEquipment) Then
			vt(RS("Day"), colAdjusted) = vt(RS("Day"), colAdjusted) + RS("Count")
			vt(32, colAdjusted) = vt(32, colAdjusted) + RS("Count")
	
		End If


		'Monthly totals		
		vt(32, RS("DefectCategory") + colDPM) = vt(32, RS("DefectCategory") + colDPM) + RS("Count")

		RS.MoveNext
	Loop
	

	'Calculate adjusted daily yields.
	For Ctr = 1 To 31
		If vt(ctr, colTested) <> 0 Then
			vt(ctr, colAdjusted) = vt(ctr, colAdjusted)  / vt(ctr, colTested)  
			vt(ctr, colAdjusted) = FormatPercent(vt(ctr, colAdjusted))
		End If	
	Next
	
	'Calculate adjusted monthly yields.
	vt(32, colAdjusted) = vt(32, colAdjusted)  / vt(32, colTested)  
	vt(32, colAdjusted) = FormatPercent(vt(32, colAdjusted))

End Sub


%>
</body>
</html>
