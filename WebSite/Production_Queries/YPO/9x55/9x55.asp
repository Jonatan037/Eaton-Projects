<%Option Explicit%>
<html>

<head>
<title>9x55 Big Screen</title>

</head>

<body>


<!-- #include File=adovbs.inc -->



<%

On Error Resume Next

Const GREEN  = "#00FF00"
Const YELLOW = "#FFFF00"
Const RED    = "#FF0000"
Const BLACK  = "#000000"


Dim Conn					'Database connection.
Dim SQL						'Query to be executed.
Dim refresh_seconds_delay	'Refresh delay in seconds.





'Increment the index value.
Session("Index") = Session("Index") + 1



If Session("Conn") = "" Then
	Response.Write "Creating the initial database connection.<br>"
	Set Session("Conn") = Server.CreateObject("ADODB.Connection")
End If


Session("Conn").Open Application("QDMS")


If Err.Number <> 0 Then
   Response.Write Err.Description
   Response.End
End If


'Default value for the number of seconds to wait between screens.
refresh_seconds_delay = 120



'Select the information to be shown.
Select Case Session("Index")


	'9x55 yields for today
	Case 1

		refresh_seconds_delay = 120
		yields_for_today

	Case 2

		refresh_seconds_delay = 120
		productivity_for_today


	Case 3

		refresh_seconds_delay = 120
		customer_required_ship_date

	'Case 4

		'refresh_seconds_delay = 15
		'Response.Write "<center>"
		'Response.Write "<img src='RAP_SAFETY_NEWS/news_04_07_2011.JPG'>"

	'Invalid index number
	Case Else

		refresh_seconds_delay = 2
		Session("Index") = 0
		Response.Write "<h1 align='center'>WELCOME</h1>"


End Select


'Time to wait before moving to the next screen.
Response.Write "<meta http-equiv='refresh' content='" & refresh_seconds_delay & "'>"



Session("Conn").Close
'Conn.Close
'set Conn = Nothing




'---------------------------------------------------------------------------------------------------------------------------------------------------
Sub customer_required_ship_date()

	Dim font_size
	Dim query					'The query to execute in order to get today's yield data.
	Dim month					'This month
	Dim year					'This year
	Dim units_shipped_mtd		'Units shipped this month.
	Dim units_shipped_today		'Units shipped this today.
	Dim units_missed_mtd		'The number of units that did not ship on time this month.
	Dim actual_crsd_mtd			'The percent of units that shipped on time this month.
	Dim monthly_goal
	Dim bgcolor					'The background color for the CRSD cell.

	monthly_goal = 0.95
	units_missed_mtd = 0


	font_size = 16

	'Get the current month and year
	month = DatePart("m",    Date)
	year  = DatePart("yyyy", Date)

	'Query to get the number of units shipped this month and year.
	query = "SELECT COUNT(PART_NUMBER) AS [RMED]" & _
	        "FROM qdms_rm_sanity_check " & _
            "WHERE FAMILY = '9x55' AND " & _
            "DatePart( month, RM_DATE ) = " & month & " AND  " & _
            "DatePart( year, RM_DATE ) = " & year


	'Get the number of units shipped for the month and year.
	units_shipped_mtd = get_rm_totals(query)


	'Query to get the number of units shipped today.
	query = "SELECT COUNT(PART_NUMBER) AS [RMED]" & _
	        "FROM qdms_rm_sanity_check " & _
	        "WHERE FAMILY = '9x55' AND RM_DATE = '" & Date & "'"

	'Get the number of units shipped today.
	units_shipped_today = get_rm_totals(query)


	'Calculate the percent of CRSD for the month.
	actual_crsd_mtd = (units_shipped_mtd) / (units_shipped_mtd + units_missed_mtd)


	'Determine the background color for the CRSD cell.
	If actual_crsd_mtd = 0 Then
		bgcolor = BLACK
	ElseIf actual_crsd_mtd >= monthly_goal Then
		bgcolor = GREEN
	ElseIf actual_crsd_mtd >= monthly_goal - 0.03 Then
		bgcolor = YELLOW
	Else
		bgcolor = RED
	End If


	'Temporarily set the background color to black unit the crsd is really calculated.
	bgcolor = BLACK

	Response.Write "<center>"
	Response.Write "<FONT SIZE='" & font_size & "'>CRSD for 9x55<br></font>"
	Response.Write "<FONT SIZE='" & font_size & "'>Units Shipped on Time for the Month<br>&nbsp;</font>"


	'Create the table.
	Response.Write "<table BORDER = '3.0' cellspacing='0' cellpadding='1'>"

	Response.Write "<tr>"
	Response.Write "<td><FONT SIZE='" & font_size & "'>Goal&nbsp;</FONT></td>"
	Response.Write "<td><FONT SIZE='" & font_size & "'>" & FormatPercent(monthly_goal) & "&nbsp;</FONT></td>"
	Response.Write "</tr>"

	Response.Write "<tr>"
	Response.Write "<td><FONT SIZE='" & font_size & "'>Units Shipped Today&nbsp;</FONT></td>"
	Response.Write "<td><FONT SIZE='" & font_size & "'>" & units_shipped_today & "&nbsp;</FONT></td>"
	Response.Write "</tr>"

	Response.Write "<tr>"
	Response.Write "<td><FONT SIZE='" & font_size & "'>Units Shipped MTD&nbsp;</FONT></td>"
	Response.Write "<td><FONT SIZE='" & font_size & "'>" & units_shipped_mtd & "&nbsp;</FONT></td>"
	Response.Write "</tr>"


	Response.Write "<tr>"
	Response.Write "<td><FONT SIZE='" & font_size & "'>Units Missed MTD&nbsp;</FONT></td>"
	'Response.Write "<td><FONT SIZE='" & font_size & "'>" & units_missed_mtd & "&nbsp;</FONT></td>"
	Response.Write "<td><FONT SIZE='" & font_size & "'>Unknown</FONT></td>"
	Response.Write "</tr>"


	Response.Write "<tr>"
	Response.Write "<td><FONT SIZE='" & font_size & "'>Actual CRSD % MTD&nbsp;</FONT></td>"
	Response.Write "<td bgcolor='" & bgcolor & "'><FONT SIZE='" & font_size & "'>" & FormatPercent(actual_crsd_mtd) & "&nbsp;</FONT></td>"
	Response.Write "</tr>"



	'Finish the table.
	Response.Write "</table>"


End Sub






'---------------------------------------------------------------------------------------------------------------------------------------------------
Sub productivity_for_today()

	Dim rs						'Recordset for the yield data.
	Dim background				'The color of the cell which contains todays yields.
	Dim font_size
	Dim query					'The query to execute in order to get today's yield data.
	Dim daily_goal				'The build number entered by the line lead.
	Dim units_rm_ed				'The number of units that have been RM-ed today.
	Dim daily_hours
	Dim start_time
	Dim percent_of_day
	Dim current_target
	Dim build_vs_target
	Dim build_vs_target_background_color

	On Error Resume Next

	start_time = "6:00"		'6:00 AM start of work.
	daily_hours = 8			'Hours in work day
	daily_goal = 20			'Value to be set by the line lead.
	units_rm_ed = 0
	font_size = 16


	'Calculate the percentage of the work day that has passed.
	percent_of_day = ( ( CDbl(Time) - CDbl(TimeValue(start_time)) ) * 24 ) / CDbl(daily_hours)


	'Calculate the current target.
	If percent_of_day > 1 Then
		current_target = daily_goal
	Else
		current_target = CInt( daily_goal * percent_of_day )
	End If



	query = "SELECT COUNT(PART_NUMBER) AS [RMED]" & _
	        "FROM qdms_rm_sanity_check " & _
	        "WHERE FAMILY = '9x55' AND RM_DATE = '" & Date & "'"



	Set RS = Session("Conn").Execute(Query)

	' Check for error.
	If Err.Description <> "" Then

		Response.Write "Error in productivity_for_today() routine.<br>" & Err.Description & "<br>" & query

	' Check for no-record case.
	ElseIf RS.EOF And RS.BOF Then


	' Valid data was received from the query.
	Else

		units_rm_ed = RS("RMED").value

		If current_target = 0 Then
			build_vs_target = 0
		Else
			build_vs_target = units_rm_ed / current_target
		End If

	End If


	'Determine the build_vs_target background color.
	If build_vs_target = 0 Then
		build_vs_target_background_color = BLACK
	ElseIf build_vs_target >= 1 Then
		build_vs_target_background_color = GREEN
	ElseIf build_vs_target >= 0.90 Then
		build_vs_target_background_color = YELLOW
	Else
		build_vs_target_background_color = RED
	End If



	Response.Write "<center>"
	Response.Write "<FONT SIZE='" & font_size & "'>9x55 Productivity For Today<br>&nbsp;</font>"


	'Create the table.
	Response.Write "<table BORDER = '3.0' cellspacing='0' cellpadding='1'>"



	Response.Write "<tr>"
	Response.Write "<td><FONT SIZE='" & font_size & "'>Units to build (RM) today&nbsp;</FONT></td>"
	Response.Write "<td><FONT SIZE='" & font_size & "'>" & daily_goal & "&nbsp;</FONT></td>"
	Response.Write "</tr>"


	Response.Write "<tr>"
	Response.Write "<td><FONT SIZE='" & font_size & "'>Target as of " & time & "&nbsp;</FONT></td>"
	Response.Write "<td><FONT SIZE='" & font_size & "'>" & current_target & "&nbsp;</FONT></td>"
	Response.Write "</tr>"


	Response.Write "<tr>"
	Response.Write "<td><FONT SIZE='" & font_size & "'>Units built (RM'ed) today&nbsp;</FONT></td>"
	Response.Write "<td><FONT SIZE='" & font_size & "'>" & units_rm_ed & "&nbsp;</FONT></td>"
	Response.Write "</tr>"


	Response.Write "<tr>"
	Response.Write "<td><FONT SIZE='" & font_size & "'>Built vs. Target&nbsp;</FONT></td>"
	Response.Write "<td bgcolor='" & build_vs_target_background_color & "'><FONT SIZE='" & font_size & "'>" &  FormatPercent(build_vs_target) & "&nbsp;</FONT></td>"
	Response.Write "</tr>"





	'Finish the table.
	Response.Write "</table>"



	RS.Close
	Set RS = Nothing

End Sub






'---------------------------------------------------------------------------------------------------------------------------------------------------
Sub yields_for_today()

	Dim rs				'Recordset for the yield data.
	Dim background		'The color of the cell which contains todays yields.
	Dim font_size
	Dim query			'The query to execute in order to get today's yield data.
	Dim yield_target	'The yield value for which the background color should be green.
	Dim todays_yield	'The value of todays yield.
	Dim tested			'The number of units tested today.
	Dim passed			'The number of units that passed test today on the first try.
	Dim failed			'The number of units that failed test today on the first try.


	On Error Resume Next


	'The yield value for which the background color should be green.
	yield_target = 0.96

	'Defaults
	tested = 0
	passed = 0
	failed = 0

	font_size = 16


	query = "SELECT PN.Family, " & _
				 "Count(I.PartNumber) As Total, " & _
				 "Sum(I.Results) As Passed, " & _
				 "Count(I.PartNumber) - Sum(I.Results) As Failed, " & _
				 "Sum(I.Results) / Count(I.PartNumber) As Yields " & _
				 "FROM qdms_master_index AS I, qdms_part_numbers AS PN " & _
			  "WHERE I.Sequence = 1 AND " & _
				 "(I.StartTime BETWEEN '" & Date & "' AND '" & Date + 1 & "') AND " & _
				 "I.RecordType IN (2) AND " & _
				 "I.PartNumber = PN.PartNumber AND " & _
				 "PN.Family = '9x55' " & _
			  "GROUP BY Family"


	'Response.Write Query & "<p><br>"
	'Response.End

	Set RS = Session("Conn").Execute(Query)

	' Check for error.
	If Err.Description <> "" Then

		Response.Write "Error in yields_for_today() routine.<br>" & Err.Description & "<br>" & query

	' Check for no-record case.
	ElseIf RS.EOF And RS.BOF Then


	' Valid data was received from the query.
	Else

		todays_yield = RS("Yields").value
		tested = RS("Total").value
		passed = RS("Passed").value
		failed = RS("Failed").value

	End If



	'Determine the background color based on yield percent.
	If todays_yield >= yield_target Then

		'Background color = green
		Background = GREEN

	ElseIf todays_yield >= yield_target - 0.03 Then

		'Background color = yellow
		Background = YELLOW

	Else

		'Background color = red
		Background = RED

	End If


	'If no units have been tested today, set the background color to black.
	If tested = 0 then Background = BLACK


	Response.Write "<center>"
	Response.Write "<FONT SIZE='" & font_size & "'>9x55 First Pass Yields For Today<br>&nbsp;</font>"


	'Create the table.
	Response.Write "<table BORDER = '3.0' cellspacing='0' cellpadding='1'>"



	'Create the column headers.
	Response.Write "<tr>"
	Response.Write "<td><FONT SIZE='" & font_size & "'>Tested&nbsp;</FONT></td>"
	Response.Write "<td><FONT SIZE='" & font_size & "'>Passed&nbsp;</FONT></td>"
	Response.Write "<td><FONT SIZE='" & font_size & "'>Failed&nbsp;</FONT></td>"
	Response.Write "<td><FONT SIZE='" & font_size & "'>Yield Goal&nbsp;</FONT></td>"
	Response.Write "<td><FONT SIZE='" & font_size & "'>Yields&nbsp;</FONT></td>"
	Response.Write "</tr>"

	'Data
	Response.Write "<tr>"
	Response.Write "<td><FONT SIZE='" & font_size & "'>" & tested & "&nbsp;</FONT></td>"
	Response.Write "<td><FONT SIZE='" & font_size & "'>" & passed & "&nbsp;</FONT></td>"
	Response.Write "<td><FONT SIZE='" & font_size & "'>" & failed & "&nbsp;</FONT></td>"
	Response.Write "<td><FONT SIZE='" & font_size & "'>" & FormatPercent(yield_target) & "&nbsp;</FONT></td>"
	Response.Write "<td bgcolor='" & Background & "'><FONT SIZE='" & font_size & "'>" & FormatPercent(todays_yield) & "&nbsp;</FONT></td>"
	Response.Write "</tr>"


	'Finish the table.
	Response.Write "</table>"


	RS.Close
	Set RS = Nothing

End Sub












'---------------------------------------------------------------------------------------------------------------------------------------------------
Sub DisplayQueryResults(query, title)

	Dim RS
	Dim Ctr
	Dim Background
	Dim font_size

	font_size = 6


	'Response.Write Query & "<p><br>"
	'Response.End

	Set RS = Session("Conn").Execute(Query)

	' Check for error.
	If Err.Description <> "" Then
		Response.Write "<B>Error " + Hex(Err) + ": " + Err.Description + "</B><br>"

	' Check for no-record case.
	ElseIf RS.EOF And RS.BOF Then
		Response.Write "No records were found. <br>"
		Response.Write Query & "<br>"

	' Valid data was received from the query.
	Else


	Response.Write "<div align='center'><center>"
	Response.Write "<table BORDER = '3.0' cellspacing='0' cellpadding='1'>"
	Response.Write "<caption><font size='" & font_size & "'>" & title & "</font></caption>"

		'Create the table header row.
  		Response.Write "<tr>"
			For Ctr = 0 To RS.Fields.Count - 1
				Response.Write "<th><FONT SIZE='" & font_size & "'>" & RS.Fields(Ctr).Name & "</FONT></th>"
			Next
		Response.Write "</tr>"

		'Fill in the cells with data.
		Do While Not RS.EOF


			'Determine the background color based on yield percent.
			If RS("Yields").value = 1 Then
				Background = "#00FF00"				'Background color = green
			ElseIf RS("Yields").value > 0.985 Then
				Background = "#FFFF00"				'Background color = yellow
			Else
				Background = "#FF0000"				'Background color = red
			End If


			'Response.Write "<tr  bgcolor='" & Background & "'>"
			Response.Write "<tr>"

				For Ctr = 0 To RS.Fields.Count - 1
	      			If RS.Fields(Ctr).Name = "Yields" Then
						Response.Write "<td><FONT SIZE='" & font_size & "'>" & FormatPercent(RS("Yields")) & "&nbsp;</FONT></td>"
					Else
						Response.Write "<td><FONT SIZE='" & font_size & "'>" & RS.Fields(Ctr) & "&nbsp;</FONT></td>"
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






'---------------------------------------------------------------------------------------------------------------------------------------------------
Function get_rm_totals(query)

	Dim RS

	On Error Resume Next

	'Default return value of zero
	get_rm_totals = 0

	'Response.Write Query & "<p><br>"
	'Response.End

	Set RS = Session("Conn").Execute(Query)

	' Check for error.
	If Err.Description <> "" Then
		
		Response.Write "Error in get_rm_totals(query) routine.<br>" & Err.Description & "<br>" & query

	' Check for no-record case.
	ElseIf RS.EOF And RS.BOF Then


	' Valid data was received from the query.
	Else

		'Get the first field.
		get_rm_totals = RS(0).value

	End If

	RS.Close
	Set RS = Nothing


End Function


%>



</body>
</html>
