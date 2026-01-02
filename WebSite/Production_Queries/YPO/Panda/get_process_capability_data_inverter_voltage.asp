<%Option Explicit%>
<%Response.Buffer = TRUE%>
<% Response.Clear %>
<html>

<head>
<title>Panda Process Capability Data</title>
</head>

<body>

<!-- #include File=..\\..\Tools\GenericTable.Inc -->
<!-- #include File=..\\..\Tools\adovbs.inc -->


<%


Dim Conn			'Connection for database.
Dim RS
Dim Ctr
Dim Sql				'The query to be executed.
Dim ConnectionString



ConnectionString = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=\\Youncsfp01\\DATA\Test-Eng\Panda\Database\Panda.mdb;Persist Security Info=False"


Set Conn = Server.CreateObject("ADODB.Connection")
Conn.Open ConnectionString



Sql = "SELECT * FROM [get_process_capability_data]"

'Serial Number	Date	Test Step	Parameter Name	Low Limit	Data	High Limit	Status	Method

Sql = "SELECT " & _
         "R.UUT_SERIAL_NUMBER, " & _
         "R.START_DATE_TIME, " & _
         "C.NAME, " & _
         "C.LOTOLERANCE, " & _
         "C.CALIBRATEDVALUETO, " & _
         "C.HITOLERANCE, " & _
         "C.STATUS, " & _
         "C.COMP_OPERATOR " & _
      "FROM " & _
         "(UUT_RESULT AS R INNER JOIN STEP_RESULT AS S ON R.ID = S.UUT_RESULT) " & _
         "INNER JOIN STEP_CALIBRATION AS C ON S.ID = C.STEP_RESULT " & _
      "WHERE R.UUT_STATUS = 'Passed' AND C.NAME Like 'Cal Inverter Volt%' " & _
      "ORDER BY R.UUT_SERIAL_NUMBER, R.START_DATE_TIME, C.NAME"


'response.write sql
'response.end

Set RS = Conn.Execute(Sql)



' Check for error.
If Err.Description <> "" Then
  Response.Write "<B>Error " + Hex(Err) + ": " + Err.Description + "</B><br>"

' Check for no-record case.
ElseIf RS.EOF And RS.BOF Then
  Response.Write "No records were found for . <br>"
  Response.Write sql

' Valid data was received from the query.
Else

	'Clear out existing http header info and set mime type to excel spreadsheet.
	Response.Expires = 0
	Response.Clear
	Response.ContentType = "Application/vnd.ms-excel"


	'Create the table header row.
	Response.Write "Serial Number" & chr(9)
	Response.Write "Date" & chr(9)
	Response.Write "Parameter Name" & chr(9)
	Response.Write "Low Limit" & chr(9)
	Response.Write "Data" & chr(9)
	Response.Write "High Limit" & chr(9)
	Response.Write "Status" & chr(9)
	Response.Write "Method" & chr(9)

	Response.Write vbCrLf

'	Response.Write FormatDateTime(Column.Value)  & chr(9)


	'Fill in the cells with data.
	Do While Not RS.EOF


		Response.Write RS("UUT_SERIAL_NUMBER") & chr(9)
		Response.Write RS("START_DATE_TIME") & chr(9)
		Response.Write RS("NAME") & chr(9)
		Response.Write RS("LOTOLERANCE") & chr(9)
		Response.Write RS("CALIBRATEDVALUETO" & Ctr ) & chr(9)
		Response.Write RS("HITOLERANCE") & chr(9)
		Response.Write RS("STATUS") & chr(9)
		Response.Write RS("COMP_OPERATOR") & chr(9)
		Response.Write vbCrLf


		RS.MoveNext

	Loop


	RS.Close
	Set RS = Nothing


	Conn.Close
	Set Conn = Nothing

End If

'Response.End


%>

