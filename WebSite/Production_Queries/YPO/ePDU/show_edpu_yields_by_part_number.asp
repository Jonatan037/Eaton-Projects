<%Option Explicit%>
<%Response.Buffer = TRUE%>

<html>

<head>
<title>ePDU Yields By Part Number</title>
</head>

<body>


<h2 align="center">ePDU Yields By Part Number</h2>

<%

On Error Resume Next

Dim Conn			'Database connection.
Dim Sql				'The query to be executed.

Dim DisplayStart
Dim DisplayEnd
Dim QueryStartDate
Dim QueryEndDate



DisplayStart = Request("StartMonth") & "/" & Request("StartDay") & "/" & Request("StartYear")
DisplayEnd   = Request("EndMonth")   & "/" & Request("EndDay")   & "/" & Request("EndYear")

if DisplayStart = DisplayEnd then
	Response.Write "<center>" & DisplayStart & "</center><P>"
else
	Response.Write "<center>" & DisplayStart & "&nbsp;&nbsp;&nbsp;" & "   To   " & "&nbsp;&nbsp;&nbsp;" & DisplayEnd & "</center><P>"
end if


QueryStartDate = "'" & Request("StartMonth") & "/" & Request("StartDay") & "/" & Request("StartYear") & "'"
QueryEndDate   = "'" & Request("EndMonth")   & "/" & Request("EndDay")   & "/" & Request("EndYear")   & "'"


Set Conn = Server.CreateObject("ADODB.Connection")
Conn.Open Application("QDMS")


if err.number <> 0 then 
   response.write sql & "<br><br>" & err.description & "<br>"
   response.end
end if


Sql = "SELECT PartNumber, COUNT(Results) AS [Number of Units Tested], ( COUNT(Results) - Sum(Results) ) As [Number of Units Failed] " & _
      "FROM epdu_index " & _
      "WHERE FirstTestDate BETWEEN " & QueryStartDate & " AND " & QueryEndDate & " " & _
      "GROUP BY PartNumber " & _
      "ORDER BY PartNumber"

Sql = "SELECT PartNumber, COUNT(Results) AS [Tested], ( COUNT(Results) - Sum(Results) ) As [Failed], (Sum(Results) / COUNT(Results)) AS [FPY]   " & _
      "FROM epdu_index " & _
      "WHERE FirstTestDate BETWEEN " & QueryStartDate & " AND " & QueryEndDate & " " & _
      "GROUP BY PartNumber " & _
      "ORDER BY PartNumber"


GenericTable Conn, Sql, "Yields By Part Number"




Conn.Close
set Conn = Nothing




Sub GenericTable(dbConn, strQuery, strCaption)

	Dim RS
	Dim Ctr
	Dim RowCtr
	Dim FPY

	On Error Resume Next

	'Response.Write Query & "<p><br>"

	Set RS = dbConn.Execute(strQuery)

	if err.number <> 0 then 
	   response.write strQuery & "<br><br>" & err.description & "<br>"
	   response.end
	end if


	' Check for error.
	If Err.Description <> "" Then
		Response.Write "<B>Error " + Hex(Err) + ": " + Err.Description + "</B><br><br>" & strQuery & "<br><br>"

	' Check for no-record case.
	ElseIf RS.EOF And RS.BOF Then
		'Response.Write "No records were found. <br>"

	' Valid data was received from the query.
	Else


	Response.Write "<table align='center' BORDER = '3.0' cellspacing='0' cellpadding='3'>"
	Response.Write "<caption>" & strCaption & "</caption>"

		'Create the table header row.
  		Response.Write "<tr>"
			For Ctr = 0 To RS.Fields.Count - 1
				Response.Write "<th>" & RS.Fields(Ctr).Name & "</th>"
			Next
		Response.Write "</tr>"

		'Fill in the cells with data.
		Do While Not RS.EOF
			RowCtr = RowCtr + 1
			Response.Write "<tr>"

			
			
			For Ctr = 0 To RS.Fields.Count - 1

					If IsNull(RS.Fields(Ctr)) Then
						Response.Write "<td>&nbsp;</td>"

					ElseIf RS.Fields(Ctr).Name = "FPY" Then

						FPY =  ( RS("Tested") - RS("Failed") ) / RS("Tested") 

						Response.Write "<td>" & FormatPercent(FPY ) & "</td>"
						'Response.Write "<td>" & FormatPercent(RS.Fields(Ctr) )& "</td>"

					Else
						Response.Write "<td>" & RS.Fields(Ctr) & "</td>"
					End If

				Next
				Response.Write "</tr>"

			RS.MoveNext
		Loop

		Response.Write "</table>"
		Response.Write "</center>"

        Response.Write "<br><br><br>"

	End If

	RS.Close
	Set RS = Nothing

End Sub

%>
</body>
</html>
