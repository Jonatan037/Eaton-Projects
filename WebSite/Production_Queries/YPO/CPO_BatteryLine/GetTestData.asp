<%Option Explicit%>
<% Response.Buffer = TRUE %>
<% Response.Clear %>

<html>

<head>
<title>CPO TEST DATA</title>
</head>

<body>
<!-- #include File=adovbs.inc -->


<%


Dim Conn			'Database connection.
Dim sql
Dim rs
Dim QueryStartDate
Dim QueryEndDate





'Create time stamp for use in query.
QueryStartDate = "#" & Request("StartMonth") & "/" & Request("StartDay") & "/" & Request("StartYear") & "#"
QueryEndDate   = "#" & Request("EndMonth")   & "/" & Request("EndDay")   & "/" & Request("EndYear") & "#"


Set Conn = Server.CreateObject("ADODB.Connection")

'The timeout is in seconds.
Conn.ConnectionTimeout = 180
Server.ScriptTimeout = 180


Conn.Open ("DRIVER=Microsoft Access Driver (*.mdb);UID=;PWD=;FIL=MS Access;DBQ=\\ra1ncsfs05\dept\WSG\Repair_Database\Battery_Cabinet_Test_Log.mdb")

sql = "SELECT * FROM Battery_Cabinet_Test_Log WHERE Test_Date BETWEEN " & QueryStartDate & " AND " & QueryEndDate


Set RS = Server.CreateObject("ADODB.RecordSet")
RS.CursorLocation = adUseClient
RS.Open sql, Conn, adOpenKeyset



'Check for error.
if err.number <> 0 then 
   response.write cmd.CommandText & "<br><br>" & err.description & "<br>"
   response.end
end if


CreateSpreadsheet

'Cleanup
rs.Close
Conn.Close
Set rs = Nothing
set Conn = Nothing

Response.End



'--------------------------------------------------------------------------------------------------------
Sub CreateSpreadsheet()


	Dim Ctr
	Dim RowCtr
	Dim Notes
	Dim Column
	Dim strLine

	On Error Resume Next



	' Check for error.
	If Err.Number <> 0 Then

		Response.Write "Error " + Hex(Err) + ": " + Err.Description + "<br>"
		Response.Write cmd.CommandText & "<br><br>"

	' Check for no-record case.
	ElseIf RS.EOF And RS.BOF Then

		Response.Write "No records were found for the specified date range. <br>" & cmd.CommandText & "<br><br>"

	' Valid data was received from the query.
	Else


		'Clear out existing http header info and set mime type to excel spreadsheet.
		Response.Expires = 0
		Response.Clear

		Response.ContentType = "Application/vnd.ms-excel"

		'Create the table header row.
		strLine = ""

		For Each Column in RS.Fields
			strLine = strLine & Column.Name  & chr(9)
		Next


		strLine = strLine & vbCrLf


		'Fill in the cells with data.
		Do While Not RS.EOF

			For Each Column in RS.Fields
	
				strLine = strLine & Column.Value  & chr(9)
				
			Next

			strLine = strLine & vbCrLf

			RS.MoveNext
		Loop

		Response.Write strLine


	End If



End Sub



%>
</body>
</html>