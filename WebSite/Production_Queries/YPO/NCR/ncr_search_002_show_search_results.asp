<%Option Explicit%>
<%Response.Buffer = TRUE%>

<html>

<head>
<title>NCR Problem Descriptions</title>
</head>

<body>
<!-- #include File=adovbs.inc -->

<h2 align="center">NCR Problem Descriptions & Analyses</h2>

<%

Dim Conn			'Database connection.
Dim Sql				'The query to be executed.
Dim Description		'The problem description entered by the user.

Dim rs


Description = Trim(Request("ProblemDescription"))


If Len(Description) = 0 Then
	Response.Write "You must enter some part of a description."
	Response.End
End If


Set Conn = Server.CreateObject("ADODB.Connection")

'The timeout is in seconds.
Conn.ConnectionTimeout = 90
Server.ScriptTimeout = 180


Conn.Open Application("QDMS")



Sql = "SELECT [DATE], UUT_SERIAL, TOPBOM, PARTNUMBER, PROBLEM, ANALYSIS FROM ncr_defects_local_copy WHERE Problem LIKE '%" & Description & "%'"

Sql = "SELECT [DATE], UUT_SERIAL, TOPBOM, PARTNUMBER, PROBLEM, ANALYSIS FROM ncr_defects_local_copy " & _
      "WHERE ( Problem LIKE '%" & Description & "%' ) OR ( PARTNUMBER LIKE '%" & Description & "%' ) OR ( TOPBOM LIKE '%" & Description & "%' )" & _
      "ORDER BY [DATE] DESC"

Sql = "SELECT [DATE], Tech, UUT_SERIAL, TOPBOM, PARTNUMBER, PROBLEM, ANALYSIS FROM ncr_defects_local_copy " & _
      "WHERE ( Problem LIKE '%" & Description & "%' ) OR ( PARTNUMBER LIKE '%" & Description & "%' ) OR ( TOPBOM LIKE '%" & Description & "%' )" & _
      "OR ( Tech LIKE '%" & Description & "%' ) OR ( Serial LIKE '%" & Description & "%' ) " & _
      "ORDER BY [DATE] DESC"


GenericTable Conn, sql
Response.Write "<br><br><br>"




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
		Response.Write "<B>Error " + Hex(Err) + ": " + Err.Description + "</B><br><br>" & strQuery & "<br>"

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

					ElseIf RS.Fields(Ctr).Name = "Problem" or RS.Fields(Ctr).Name = "Analysis" Then

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
