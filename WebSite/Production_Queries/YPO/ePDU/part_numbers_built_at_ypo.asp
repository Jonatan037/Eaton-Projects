<%Option Explicit%>
<% Response.Buffer = TRUE %>
<% Response.Clear %>
<html>

<head>
<title>ePDU Part Number That Have Been Built At YPO</title>
</head>

<body>
<%
   Dim Conn
   Dim RS
   Dim Ctr
   Dim Column


   Set Conn = Server.CreateObject("ADODB.Connection")

   Conn.Open "DRIVER=Microsoft Access Driver (*.mdb);UID=;PWD=;FIL=MS Access;DBQ=\\youncsfp01\data\test-eng\ePDU\Database\ePDU_Production_Master.mdb"


   'Get the list of part numbers
   Set RS = Conn.Execute("SELECT DISTINCT PartNumber FROM Index")

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


      Response.Write "The ePDU part numbers listed below have been built at least one time at YPO as of " & now & chr(9)
      Response.Write vbCrLf
	  Response.Write vbCrLf

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
