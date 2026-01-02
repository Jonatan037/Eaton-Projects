<%Option Explicit%>


<html>

<head>
<title>Unclosed NCRs</title>
</head>

<body>
<!-- #include File=adovbs.inc -->

<h2 align="center">Unclosed NCRs located at YPO</h2>

<%

Dim Conn			'Database connection.
Dim Sql				'The query to be executed.

Dim rs


Set Conn = Server.CreateObject("ADODB.Connection")

'The timeout is in seconds.
'Conn.ConnectionTimeout = 90
'Server.ScriptTimeout = 180


Conn.Open Application("QDMS")



Sql = "SELECT Tech, Count(Tech) AS [Number of Unclosed NCRs] FROM qdms_ncr_unsubmitted " & _
      "WHERE Unsubmitted = 1 " & _
      "GROUP BY Tech "

GenericTable Conn, sql
Response.Write "<br><br><br>"


Sql = "SELECT Filename, DateCreated,Tech, qdms_rm_sanity_check.RM_DATE " & _
	  "FROM qdms_ncr_unsubmitted LEFT JOIN qdms_rm_sanity_check " & _
	  "ON Left(qdms_ncr_unsubmitted.Filename,10) = qdms_rm_sanity_check.SERIAL_NUMBER " & _
      "WHERE Unsubmitted = 1 ORDER BY Filename"


GenericTable Conn, sql
Response.Write "<br><br><br>"



Sql = "SELECT * FROM qdms_ncr_unsubmitted WHERE Unsubmitted = 1  ORDER BY Tech, Filename"

GenericTable Conn, sql



set Conn = Nothing



'--------------------------------------------------------------------------------------------------------


Sub GenericTable(dbConn, strQuery)

	Dim RS
	Dim Ctr
	Dim RowCtr
	Dim Notes

	On Error Resume Next

	'Set rs = Server.CreateObject("ADODB.Recordset")
	'rs.Open strQuery, dbConn

	Set RS = Server.CreateObject("ADODB.RecordSet")
	RS.CursorLocation = adUseClient
	RS.Open strQuery, dbConn, adOpenKeyset


	' Check for error.
	If Err.Description <> "" Then
		Response.Write "<B>Error " + Hex(Err) + ": " + Err.Description + "</B><br>" & strQuery & "<br>"

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

					ElseIf RS.Fields(Ctr).Name = "Notes" Then

						Notes = RS.Fields(Ctr)
						Notes = Replace(Notes, vbcrlf, "<br>")
						Response.Write "<td>" & notes & "</td>"

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
