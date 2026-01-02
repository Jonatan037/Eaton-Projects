<%Option Explicit%>
<% Response.Buffer = TRUE %>
<% Response.Clear %>
<html>

<head>
<title>SPD Failure Information Spreadsheet</title>
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



	QueryStartDate = "#" & Request("QueryStartDate") & "#"
	QueryEndDate   = "#" & Request("QueryEndDate")   & "#"


   Set Conn = Server.CreateObject("ADODB.Connection")

   Conn.Open "DRIVER=Microsoft Access Driver (*.mdb);UID=;PWD=;FIL=MS Access;DBQ=\\ra1ncwcpotest06\_TestEngineering\Database\production.mdb"


   'Build the query to get the failure info for the specified time period.
   Query = "SELECT * FROM [View - Failure Information] " & _
           "WHERE StartTime BETWEEN " & QueryStartDate & " AND " & QueryEndDate

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
