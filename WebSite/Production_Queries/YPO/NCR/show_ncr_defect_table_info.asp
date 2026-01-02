<%Option Explicit%>
<% Response.Buffer = TRUE %>
<% Response.Clear %>

<html>

<head>
<title>NCR DEFECT TABLE DATA</title>
</head>

<body>
<!-- #include File=adovbs.inc -->


<%


Dim Conn			'Database connection.
Dim cmd
Dim rs
Dim QueryStartDate
Dim QueryEndDate



'Response.Write "The website copy of the NCR data is not currently available.<br>Please use the MS Access master copy that is located on the I-drive.<br>"
'Response.End



'Create time stamp for use in query.
QueryStartDate = "'" & Request("StartMonth") & "/" & Request("StartDay") & "/" & Request("StartYear") & "'"
QueryEndDate   = "'" & Request("EndMonth")   & "/" & Request("EndDay")   & "/" & Request("EndYear") & "'"



Set Conn = Server.CreateObject("ADODB.Connection")

'The timeout is in seconds.
Conn.ConnectionTimeout = 90
Server.ScriptTimeout = 180


Conn.Open Application("QDMS")



Set cmd = Server.CreateObject("ADODB.Command")

cmd.ActiveConnection = Conn

'Text for stored procedure with start and end dates.
cmd.CommandText = "spGetNcrDefects(" & QueryStartDate & "," & QueryEndDate & ")"

cmd.CommandType = adCmdStoredProc

cmd.CommandTimeout = 90

Set rs = cmd.Execute 

'Check for error.
if err.number <> 0 then 
   response.write cmd.CommandText & "<br><br>" & err.description & "<br>"
   response.end
end if




CreateSpreadsheet



'Cleanup
set cmd = Nothing
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


		'Response.ContentType = "application/application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
		'Response.AppendHeader "content-disposition", "attachment; filename=myfile.xlsx"                                        

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
