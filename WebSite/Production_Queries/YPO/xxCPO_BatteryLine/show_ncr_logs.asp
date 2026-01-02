<%Option Explicit%>


<html>

<head>
<title>Logs By Badge Number</title>
</head>

<body>
<!-- #include File=adovbs.inc -->

<h2 align="center">UUT LOG Records From NCR Database</h2>

<%

On Error Resume Next


Dim Conn			'Database connection.
Dim Sql				'The query to be executed.

Dim DisplayStart
Dim DisplayEnd
Dim QueryStartDate
Dim QueryEndDate
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
QueryEndDate   = CDate(Request("EndMonth")   & "/" & Request("EndDay")   & "/" & Request("EndYear") )

QueryEndDate   = "'" & QueryEndDate & "'"



Set Conn = Server.CreateObject("ADODB.Connection")

'The timeout is in seconds.
Conn.ConnectionTimeout = 90
Server.ScriptTimeout = 180



Conn.Open Application("QDMS")


'Check for error.
if err.number <> 0 then 
   response.write err.description & "<br>"
   response.end
end if



Sql = "SELECT " & _
         "C.Info4Item AS Family, " & _
         "Count(C.Info4Item) AS [Number of Test Complete Records], " & _
         "Count(D.SerialNumber) AS [Number of Defect Reports], " & _
         "Sum(  CAST(IsNull( D.Info6Item, 0) AS DECIMAL(9,5) ) )  AS [Troubleshooting Hours]  " & _
      "FROM ncr_001_test_complete_records AS C LEFT JOIN ncr_002_defect_report AS D ON C.SerialNumber = D.SerialNumber " & _
      "WHERE C.StartTime BETWEEN " & QueryStartDate & " AND " & QueryEndDate & " " & _
      "GROUP BY C.Info4Item"


Sql = "SELECT TECH, FAMILY, COUNT(TECH) AS [COUNT] FROM ncr_log_local_copy " & _
      "WHERE [Date] BETWEEN " & QueryStartDate & " AND " & QueryEndDate & " " & _
      "GROUP BY TECH, FAMILY " & _
      "ORDER BY 1,2"


GenericTable Conn, sql

Response.Write "<BR><BR>"



Sql = "SELECT * FROM ncr_log_local_copy " & _
      "WHERE [Date] BETWEEN " & QueryStartDate & " AND " & QueryEndDate & " " 



GenericTable Conn, sql

Response.Write "<BR><BR>"



set Conn = Nothing



'--------------------------------------------------------------------------------------------------------
Sub GenericTable(dbConn, strQuery)

	Dim RS
	Dim Ctr
	Dim RowCtr

	On Error Resume Next


	'Set rs = Server.CreateObject("ADODB.Recordset")
	'rs.Open strQuery, dbConn

	Set RS = Server.CreateObject("ADODB.RecordSet")
	RS.CursorLocation = adUseClient
	RS.Open strQuery, dbConn, adOpenKeyset



	' Check for error.
	If Err.Number <> 0 Then
		Response.Write "<B>Error " + Hex(Err) + ": " + Err.Description + "</B><br><br>" & strQuery & "<br><br>"

	' Check for no-record case.
	ElseIf RS.EOF And RS.BOF Then
		Response.Write "No records were found. <br>"

	' Valid data was received from the query.
	Else


	Response.Write "<table align='center' BORDER = '3.0' cellspacing='0' cellpadding='1'>"

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

	RS.Close
	Set RS = Nothing

End Sub



%>
</body>
</html>
