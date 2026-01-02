<%Option Explicit%>
<% Response.Buffer = TRUE %>
<% Response.Clear %>
<html>

<head>
<title>Process Capability</title>
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



'Get the date from the calling form.
QueryStartDate = CDate(Request("StartMonth") & "/" & Request("StartDay") & "/" & Request("StartYear") )
QueryEndDate   = CDate(Request("EndMonth")   & "/" & Request("EndDay")   & "/" & Request("EndYear") )

QueryEndDate   = QueryEndDate + 1


'Put the dates in the proper format for the query.
QueryStartDate = "#" & QueryStartDate & "#"
QueryEndDate   = "#" & QueryEndDate & "#"



Set Conn = Server.CreateObject("ADODB.Connection")

Conn.Open Application("ProductionDatabase")


Query = "SELECT " & _
           "PartNumber, SerialNumber, Seq, StartTime, Category, Model, " & _
           "[Transfer to Inverter - Frequency] AS Frequency, " & _
           "[Transfer to Inverter - RMS] AS Voltage " & _
        "FROM [Parametric Data - Small Pyramid] " & _
        "WHERE Seq =1 AND Results = 1"

Set RS = Conn.Execute(Query)

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

%>
</body>
</html>
