<%Option Explicit%>
<% Response.Buffer = TRUE %>
<% Response.Clear %>
<html>

<head>
<title>Failure Information Spreadsheet</title>
</head>

<body>
<%
	Dim Conn
	Dim RS
	Dim Query	
	Dim QueryStartDate
	Dim QueryEndDate
	Dim Ctr
	Dim Column
	Dim strLine



	'Create time stamp for use in query.
QueryStartDate = "#" & Request("StartMonth") & "/" & Request("StartDay") & "/" & Request("StartYear") & "#"
QueryEndDate   = "#" & Request("EndMonth")   & "/" & Request("EndDay")   & "/" & Request("EndYear") & "#"

	'--------------------------------------------------------------------------------------------------------
	'Create the desired query.
	Query = "SELECT * FROM [NCR - Defects] WHERE [Date] BETWEEN " & QueryStartDate & " AND " & QueryEndDate



'Response.Write query
'RESPONSE.END

	Set Conn = Server.CreateObject("ADODB.Connection")

	Conn.Open Application("ProductionDatabase")

	Set RS = Conn.Execute(Query)

	' Check for error.
	If Err.Description <> "" Then
		Response.Write "<B>Error " + Hex(Err) + ": " + Err.Description + "</B><br>"

	' Check for no-record case.
	ElseIf RS.EOF And RS.BOF Then 
		Response.Write "No records were found. <br>"

	Else
	' Valid data was received from the query.
	
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

	Response.End

	End If
%>
</body>
</html>
