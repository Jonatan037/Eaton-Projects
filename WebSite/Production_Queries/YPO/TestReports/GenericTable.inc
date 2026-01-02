<%
Sub GenericTable(dbConn, strQuery)

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


'-----------------------------------------------------------------------------------------------------------------------------------------------
'Add blank space between RMA numbers.
Sub RMA_Table(dbConn, strQuery)

	Dim RS
	Dim Ctr
	Dim RowCtr
	Dim RMA_NUM

	'Response.Write Query & "<p><br>"

	Set RS = dbConn.Execute(strQuery)

	' Check for error.
	If Err.Description <> "" Then
		Response.Write "<B>Error " + Hex(Err) + ": " + Err.Description + "</B><br>"

	' Check for no-record case.
	ElseIf RS.EOF And RS.BOF Then 
		Response.Write "No records were found. <br>"

	' Valid data was received from the query.
	Else


	Response.Write "<table align='center' BORDER = '3.0' cellspacing='0' cellpadding='1'>"

		'Create the table header row.
  		Response.Write "<tr>"
			'Response.Write "<th>Count</th>"
			For Ctr = 0 To RS.Fields.Count - 1
				Response.Write "<th>" & RS.Fields(Ctr).Name & "</th>"
			Next
		Response.Write "</tr>"

		RMA_NUM = RS("RMA_SEQ")

		'Fill in the cells with data.
		Do While Not RS.EOF
			RowCtr = RowCtr + 1

			If RMA_NUM <> RS("RMA_SEQ") Then
				Response.Write "<tr><td bgcolor='#c0c0c0' colspan='8'>&nbsp;</td></tr>"
				RMA_NUM = RS("RMA_SEQ")
			End If


			Response.Write "<tr>"

				'Response.Write "<td>" & RowCtr & "</td>"
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
