<%Option Explicit%>
<%Response.Buffer = TRUE%>
<% Response.Clear %>
<html>

<head>
<title>Battery Line Data</title>
</head>

<body>

<!-- #include File=..\\..\Tools\GenericTable.Inc -->
<!-- #include File=..\\..\Tools\adovbs.inc -->


<%


Dim Conn			'Connection for database.
Dim RS
Dim Column
Dim Sql				'The query to be executed.
Dim QueryStartDate
Dim QueryEndDate




'Get the date from the calling form.
QueryStartDate = CDate(Request("StartMonth") & "/" & Request("StartDay") & "/" & Request("StartYear") )
QueryEndDate   = CDate(Request("EndMonth")   & "/" & Request("EndDay")   & "/" & Request("EndYear") ) + 1



'Put the dates in the proper format for the query.
QueryStartDate = "#" & QueryStartDate & "#"
QueryEndDate   = "#" & QueryEndDate & "#"


Set Conn = Server.CreateObject("ADODB.Connection")
Conn.Open "DRIVER=Microsoft Access Driver (*.mdb);UID=;PWD=;FIL=MS Access;DBQ=\\Youncsfp01\DATA\Test-Eng\BatteryLine\Database\BatteryTest_Results_Master.mdb"

'Query to get index and measurement data.

Sql = "SELECT * FROM [Measurements View] " & _
      "WHERE StartTime BETWEEN " & QueryStartDate & " AND " & QueryEndDate

'response.write sql
'response.end

Set RS = Conn.Execute(Sql)



' Check for error.
If Err.Description <> "" Then
  Response.Write "<B>Error " + Hex(Err) + ": " + Err.Description + "</B><br>"

' Check for no-record case.
ElseIf RS.EOF And RS.BOF Then
  Response.Write "No records were found. <br>"

' Valid data was received from the query.
Else

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

Response.End



Conn.Close
Set Conn = Nothing


%>

