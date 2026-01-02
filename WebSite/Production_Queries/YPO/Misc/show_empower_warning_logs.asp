<%Option Explicit%>


<html>

<head>
<title>Logs By Badge Number</title>
</head>

<body>
<!-- #include File=adovbs.inc -->

<h2 align="center">Empower Warnings Log</h2>

<%

On Error Resume Next


Dim Conn			'Database connection.
Dim Sql				'The query to be executed.


Dim rs


Set Conn = Server.CreateObject("ADODB.Connection")



Conn.Open Application("QDMS")


'Check for error.
if err.number <> 0 then 
   response.write err.description & "<br>"
   response.end
end if


Sql = "SELECT * FROM empower_warnings_log ORDER BY time_stamp DESC"

GenericTable Conn, sql





set Conn = Nothing



'--------------------------------------------------------------------------------------------------------
Sub GenericTable(dbConn, strQuery)

	Dim RS
	Dim Ctr
	Dim RowCtr
	dim uut_info
	dim uut_ctr

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

					ElseIf RS.Fields(Ctr).Name = "uut_info" then

						Response.Write "<td>"
						uut_info = Split(RS.Fields(Ctr), ",")
						
						for uut_ctr = Lbound(uut_info) to Ubound(uut_info) step 3
							Response.Write uut_info(uut_ctr + 1) & " = " & uut_info(uut_ctr + 2) &  "<br>"
						next
						Response.Write "</td>"

					Else
							
							Response.Write "<td>" & Replace(RS.Fields(Ctr),vbCrLf, "<br>")  & "</td>"
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
