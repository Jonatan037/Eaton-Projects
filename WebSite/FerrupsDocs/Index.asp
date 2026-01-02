<%Option Explicit%>
<html>

<head>
<title>Ferrups Documents</title>
</head>

<body>

<p><%
	Dim Conn
	Dim RS
	Dim SQL
	Dim Ctr
	Dim txtSchematics
	Dim arrSchematics
	Dim ctrSchematics

	Set Conn = Server.CreateObject("ADODB.Connection")
	Conn.Open Application("ProductionDatabase")

	SQL = "SELECT * FROM FerrupsDocs " & _
         "ORDER BY Type"

	'Response.Write SQL & "<p><br>"

	Set RS = Conn.Execute(SQL)

	' Check for error.
	If Err.Description <> "" Then
		Response.Write "<B>Error " + Hex(Err) + ": " + Err.Description + "</B><br>"

	' Check for no-record case.
	ElseIf RS.EOF And RS.BOF Then
		Response.Write "No records were found. <br>"

	' Valid data was received from the query.
	Else


	Response.Write "<div align='center'><center>"
	Response.Write "<table BORDER = '3.0' cellspacing='0' cellpadding='3'>"

	Response.Write "<caption><b>Ferrups Documents</b></caption>"

		'Create the table header row.
  		Response.Write "<tr>"
			For Ctr = 0 To RS.Fields.Count - 1
				Response.Write "<th>" & RS.Fields(Ctr).Name & "</th>"
			Next
		Response.Write "</tr>"

		'Fill in the cells with data.
		Do While Not RS.EOF
			Response.Write "<tr>"
				For Ctr = 0 To RS.Fields.Count - 1

					If RS.Fields(Ctr).Name = "CTO Chart" Then
						Response.Write "<td><a href='CTOCharts\" & RS.Fields(Ctr) & ".xls'>" & RS.Fields(Ctr) & "</a>&nbsp;</td>"

					ElseIf RS.Fields(Ctr).Name = "Schematic" Then

						'Get the text for the schematic.
						IF IsNull( RS.Fields(Ctr) ) Then

							Response.Write "<td>&nbsp;</td>"

						Else

							txtSchematics = RS.Fields(Ctr)

							'Split the text using the comma character as a delimiter.
							arrSchematics = Split(txtSchematics, ",")

							'Write the schematic links to the table. This allows for multiple schematics for a single model number.
							Response.Write "<td>"
							For ctrSchematics = LBound(arrSchematics) To UBound(arrSchematics)

								arrSchematics(ctrSchematics) = Trim(arrSchematics(ctrSchematics))

								Response.Write "<a href='Schematics\" & arrSchematics(ctrSchematics) & ".pdf'>" & arrSchematics(ctrSchematics) & "</a>&nbsp;"

							Next
							Response.Write "</td>"

						End If

					Else
						Response.Write "<td>" & RS.Fields(Ctr) & "&nbsp;</td>"
					End If

				Next

			Response.Write "</tr>"

			RS.MoveNext
		Loop

	Response.Write "</table>"
	Response.Write "</center>"

	End If
%> </p>
</body>
</html>
