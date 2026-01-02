<%Option Explicit%>
<% Response.Buffer = TRUE %>
<% Response.Clear %>
<html>

<head>
<title>SPD</title>
</head>


<%
	Dim Conn
	Dim RS
	Dim Query
	Dim QueryStartDate
	Dim QueryEndDate
	Dim Ctr
	Dim Column

	'On Error Resume Next


	'Increase timeout for people using this query.
	Session.Timeout = 5 'Minutes
	Server.ScriptTimeout = 300 'Seconds


	'Create time stamp for use in query.
	QueryStartDate = "{ts '" &	Request("StartYear") & "-" 	& Request("StartMonth") & "-" &	Request("StartDay") & " 00:00:00'}"
	QueryEndDate   = "{ts '" & 	Request("EndYear")   & "-" & Request("EndMonth")    & "-" & 	Request("EndDay")   & " 23:59:59'}"


	'Create the desired query.
	Query = "SELECT * FROM [Measurements View] " & _
           	"WHERE (StartTime BETWEEN " & QueryStartDate & " AND " & QueryEndDate & ") " & _
                "ORDER BY [PartNumber], [SerialNumber], [Seq], [Parameter Name]"


	Set Conn = Server.CreateObject("ADODB.Connection")


	Conn.Open "DRIVER=Microsoft Access Driver (*.mdb);UID=;PWD=;FIL=MS Access;DBQ=\\YOUNCWHP5013522\Database\production.mdb"


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

		For Each Column in RS.Fields
			Response.Write Column.Name  & chr(9)
		Next


		Response.Write vbCrLf


		'Fill in the cells with data.
		Do While Not RS.EOF

			For Each Column in RS.Fields
				If Column.Name = "StartTime" Then
					Response.Write FormatDateTime(Column.Value)  & chr(9)
				Else
					Response.Write Column.Value  & chr(9)
				End If

			Next

			Response.Write vbCrLf

			RS.MoveNext
		Loop



	End If

	RS.Close
	Conn.Close

%>

