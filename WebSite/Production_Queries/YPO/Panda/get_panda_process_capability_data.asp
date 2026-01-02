
<%Option Explicit%>
<%Response.Buffer = TRUE%>
<% Response.Clear %>
<html>

<head>
<title>Panda Process Capability Data</title>
</head>

<body>




<%

Dim Conn			'Connection for database.
Dim RS
Dim Ctr
Dim Sql				'The query to be executed.
Dim ConnectionString
Dim QueryStartDate
DIm QueryEndDate



'Get the date from the calling form.
QueryStartDate = CDate(Request("StartMonth") & "/" & Request("StartDay") & "/" & Request("StartYear") )
QueryEndDate   = CDate(Request("EndMonth")   & "/" & Request("EndDay")   & "/" & Request("EndYear") )

QueryEndDate   = QueryEndDate + 1


'Put the dates in the proper format for the query.
QueryStartDate = "#" & QueryStartDate & "#"
QueryEndDate   = "#" & QueryEndDate & "#"



ConnectionString = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=\\Youncsfp01\\DATA\Test-Eng\Panda\Database\Panda.mdb;Persist Security Info=False"


Set Conn = Server.CreateObject("ADODB.Connection")
Conn.Open ConnectionString



'Sql = "SELECT * FROM [get_process_capability_data]"
Sql = "SELECT * FROM [get_process_capability_data_on_battery] WHERE START_DATE_TIME BETWEEN " & QueryStartDate & " AND " & QueryEndDate


response.write sql
'response.end

Set RS = Conn.Execute(Sql)



' Check for error.
If Err.Description <> "" Then
  Response.Write "<B>Error " + Hex(Err) + ": " + Err.Description + "</B><br>"

' Check for no-record case.
ElseIf RS.EOF And RS.BOF Then
  Response.Write "No records were found. <br>"

' Valid data was received from the query.
Else

	'Clear out existing http header info and set mime type to excel spreadsheet.
	Response.Expires = 0
	Response.Clear
	Response.ContentType = "Application/vnd.ms-excel"


	'Create the table header row.
	Response.Write "Serial Number" & chr(9)
	Response.Write "Date" & chr(9)
	Response.Write "Test Step" & chr(9)
	Response.Write "Parameter Name" & chr(9)
	Response.Write "Low Limit" & chr(9)
	Response.Write "Data" & chr(9)
	Response.Write "High Limit" & chr(9)
	Response.Write "Status" & chr(9)
	Response.Write "Method" & chr(9)

	Response.Write vbCrLf

	'Response.Write FormatDateTime(Column.Value)  & chr(9)


	'Fill in the cells with data.
	Do While Not RS.EOF

			If RS("STEP_NAME") = "Output Voltage" Then

				For Ctr = 1 To 3

					Response.Write RS("UUT_SERIAL_NUMBER") & chr(9)
					Response.Write RS("START_DATE_TIME") & chr(9)
					Response.Write RS("PARENT") & chr(9)
					Response.Write RS("STEP_NAME") & " L" & Ctr & chr(9)
					Response.Write RS("LOLIMIT") & chr(9)
					Response.Write RS("DMMVALUE" & Ctr ) & chr(9)
					Response.Write RS("HILIMIT") & chr(9)
					Response.Write RS("STATUS") & chr(9)
					Response.Write RS("COMP_OPERATOR") & chr(9)
					Response.Write vbCrLf

				Next

			Else

				Response.Write RS("UUT_SERIAL_NUMBER") & chr(9)
				Response.Write RS("START_DATE_TIME") & chr(9)
				Response.Write RS("PARENT") & chr(9)
				Response.Write RS("STEP_NAME") & chr(9)
				Response.Write RS("LOLIMIT") & chr(9)
				Response.Write RS("DMMVALUE1") & chr(9)
				Response.Write RS("HILIMIT") & chr(9)
				Response.Write RS("STATUS") & chr(9)
				Response.Write RS("COMP_OPERATOR") & chr(9)
				Response.Write vbCrLf

			End If



		RS.MoveNext

	Loop


	RS.Close
	Set RS = Nothing


	Conn.Close
	Set Conn = Nothing

End If



'Response.End


%>


