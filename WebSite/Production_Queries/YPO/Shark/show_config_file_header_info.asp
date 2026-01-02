<%Option Explicit%>


<html>

<head>
<title>Shark Configuration Files</title>
</head>

<body>
<!-- #include File=adovbs.inc -->

<h2 align="center">Shark - Configuration Files</h2>

<%

On Error Resume Next


Dim Conn			'Database connection.
Dim Sql				'The query to be executed.

Dim rs




Set Conn = Server.CreateObject("ADODB.Connection")


Conn.Open Application("Shark")


'Check for error.
if err.number <> 0 then 
   response.write err.description & "<br>"
   response.end
end if




Sql = "SELECT " & _
         "FILE_ID, Configuration, PartNumber, Revision, " & _
         "ReleasedStatus, ReleaseNote, DateCreated, BadgeNumber, " & _
         "DefaultTestMode, FileName, Author, DataSize, DataChecksum " & _
      "FROM UnitConfigFiles " & _
      "ORDER BY Configuration, PartNumber, Revision"
   
GenericTable Conn, sql


set Conn = Nothing



'--------------------------------------------------------------------------------------------------------
Sub GenericTable(dbConn, strQuery)

   Dim RS
   Dim Ctr

   On Error Resume Next


   'Set rs = Server.CreateObject("ADODB.Recordset")
   'rs.Open strQuery, dbConn

   Set RS = Server.CreateObject("ADODB.RecordSet")
   RS.CursorLocation = adUseClient
   RS.Open strQuery, dbConn, adOpenKeyset



   If Err.Number <> 0 Then
      Response.Write "<B>Error " + Hex(Err) + ": " + Err.Description + "</B><br><br>" & strQuery & "<br><br>"


   ElseIf RS.EOF And RS.BOF Then
      Response.Write "No records were found. <br>"

   Else

      Response.Write "<table align='center' BORDER = '3.0' cellspacing='0' cellpadding='1'>"

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

            If IsNull(RS.Fields(Ctr)) Then

               Response.Write "<td>&nbsp;</td>"

            ElseIf RS.Fields(Ctr).Name = "FILE_ID" Then

               Response.Write "<td><A HREF='get_config_file_data.asp?ID=" & RS.Fields(Ctr) & "'>"  & RS.Fields(Ctr) & "</A></td>"


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
