<%Option Explicit%>
<% Response.Buffer = TRUE %>
<% Response.Clear %>

<html>

<head>
<title>NCR Data Entry Validation</title>
</head>

<body>
<!-- #include File=adovbs.inc -->


<%

Dim Conn			'Database connection.
Dim Sql				'The query to be executed.
Dim QueryStartDate
Dim QueryEndDate



'Create time stamp for use in query.
QueryStartDate = "#" & Request("StartMonth") & "/" & Request("StartDay") & "/" & Request("StartYear") & "#"
QueryEndDate   = "#" & Request("EndMonth")   & "/" & Request("EndDay")   & "/" & Request("EndYear") & "#"



Set Conn = Server.CreateObject("ADODB.Connection")

'The timeout is in seconds.
Conn.ConnectionTimeout = 90
Server.ScriptTimeout = 180


Conn.Open Application("QDMS")


'--------------------------------------------------------------------------------------------------------
Sql = "SELECT ncr_defects_local_copy.* " & _
      "FROM ncr_defects_local_copy " & _
      "WHERE " & _
         "( UUT_SERIAL LIKE '%VAA%' AND STATION  NOT LIKE 'D%' )  OR " & _
         "( UUT_SERIAL NOT LIKE '%VAA%' AND STATION  LIKE 'D%' )"


GenericTable Conn, sql, "Possible Serial Number and Station Combination Problems for TAA in the Defect table."
Response.Write "<br><br>"

'--------------------------------------------------------------------------------------------------------
Sql = "SELECT ncr_log_local_copy.* " & _
      "FROM ncr_log_local_copy " & _
	  "WHERE " & _
	     "( SERIAL Like '%VAA%' AND FAMILY  Not Like 'TAA%' ) OR " & _
	     "( SERIAL NOT Like '%VAA%' AND FAMILY   Like 'TAA%' )"

GenericTable Conn, sql, "Possible Serial Number and Family Combination Problems for TAA in the UUTLog table."
Response.Write "<br><br>"



'--------------------------------------------------------------------------------------------------------
Sql = "SELECT ncr_log_local_copy.* " & _
      "FROM ncr_log_local_copy " & _
	  "WHERE " & _
	     "( TOPBOM Like '9E%' AND FAMILY  Not Like 'G%' ) OR " & _
	     "( TOPBOM NOT Like '9E%' AND FAMILY   Like 'G%' )"


GenericTable Conn, sql, "Possible Serial Number and Family Combination Problems for Panda in the UUTLog table."
Response.Write "<br><br>"


'--------------------------------------------------------------------------------------------------------
set Conn = Nothing
Response.End

'--------------------------------------------------------------------------------------------------------


Sub GenericTable(dbConn, strQuery, strCaption)

	Dim RS
	Dim Ctr
	Dim RowCtr


	'Response.Write Query & "<p><br>"

	Set RS = dbConn.Execute(strQuery)

	' Check for error.
	If Err.Description <> "" Then
		Response.Write "<B>Error " + Hex(Err) + ": " + Err.Description + "</B><br>"

	' Check for no-record case.
	ElseIf RS.EOF And RS.BOF Then
		'Response.Write "No records were found for: <br>" & strQuery & "<br><hr><br>"

	' Valid data was received from the query.
	Else

		'Response.Write strQuery & "<br><br>"

		Response.Write "<table align='center' BORDER = '3.0' cellspacing='0' cellpadding='1'>"
		Response.Write "<caption>" & strCaption & "</caption>"

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
