<%Option Explicit%>
<%Response.Buffer = TRUE%>
<% Response.Clear %>
<html>

<head>
<title>Test Report</title>


<STYLE TYPE="text/css">
<!--
TD{font-family: Arial; font-size: 10pt;}
--->
</STYLE>

</head>

<body>


<!-- #include File=adovbs.inc -->


<%

Dim qdmsConn			'QDMS database connection.
Dim Conn			'database connection
Dim Sql				'The query to be executed.

Dim lIndexID
Dim lResultsID
Dim strConnection
Dim strSerialNumber
Dim fld
Dim rs

Dim summary_report
Dim detailed_report
'Dim redirect_string

lIndexID = Request("ID")


On Error Resume Next

'Create connection objects.
Set qdmsConn = Server.CreateObject("ADODB.Connection")
Set Conn = Server.CreateObject("ADODB.Connection")


'Conn.ConnectionTimeout = 90
qdmsConn.Open Application("QDMS")


'Get search infor from the QDMS database.
Set rs = qdmsConn.Execute("SELECT I.ResultsID, I.SerialNumber, D.ConnectionString FROM qdms_master_index AS I INNER JOIN qdms_database_ids as D ON I.DBID = D.DBID WHERE INDEXID = " & lIndexId)


'Assign values from the database to local variables.
lResultsID = rs("ResultsID")
strConnection = rs("ConnectionString")
strSerialNumber = rs("SerialNumber")


'Close the recordset and the QDMS connection.
rs.Close
Set rs = Nothing
qdmsConn.Close


'Show any error that might have occurred up to this point.
If Err.Description <> "" Then 
   Response.Write "Error : " + Err.Description + "<br>"
   Response.End
End If


'response.write strConnection
'Response.end


Conn.Open strConnection



If Err.Description <> "" Then 
   Response.Write "Error : " + Err.Description + "<br>" & Conn.ConnectionString
   Response.End
End If


ShowHeader
ShowDetails

RS.Close
Set RS = Nothing

Conn.Close
Set Conn = Nothing


Sub ShowHeader()

   sql = "SELECT * FROM [vw_PCaT_TestResultRun_DataDog] WHERE TestRunId = " & lResultsID

   Set rs = Conn.Execute(sql)

   'Check for error.
   If Err.Description <> "" Then
      Response.Write "<B>Error " + Hex(Err) + ": " + Err.Description + "</B><br>" & sql & "<br>"

   'Check for no-record case.
   ElseIf RS.EOF And RS.BOF Then

      Response.Write "No records were found for this unit."

   'Valid data was received from the query.
   Else
      Response.Write "<br>"
      Response.Write "<table BORDER = '3.0' cellspacing='0' cellpadding='1'>"

      Response.Write "<tr><td><b>ModelNumber</b></td><td>" & rs("ModelNumber") &  "</td></tr>"
      Response.Write "<tr><td><b>SerialNumber</b></td><td>" & rs("SerialNumber") &  "</td></tr>"	
      Response.Write "<tr><td><b>StartTime</b></td><td>" & rs("StartTime") &  "</td></tr>"
      'Response.Write "<tr><td><b>EndTime</b></td><td>" & rs("EndTime") &  "</td></tr>"
      Response.Write "<tr><td><b>Status</b></td><td>" & rs("Passed") &  "</td></tr>"
      Response.Write "<tr><td><b>TestRunType</b></td><td>" & rs("TestRunType") &  "</td></tr>"
      Response.Write "<tr><td><b>OperatorName</b></td><td>" & rs("OperatorName") &  "</td></tr>"

      Response.Write "</table>"

      Response.Write "<br><br>"
   
   End If

End Sub



Sub ShowDetails()

   sql = "SELECT Instruction, LSL, Results, USL, Status, Units, Comments FROM [tbl_Result_view] where [TestRunId] = " & lResultsID & "  order by [Sequence_Number]"
   
   Set rs = Conn.Execute(sql)

   'Check for error.
   If Err.Description <> "" Then
      Response.Write "<B>Error " + Hex(Err) + ": " + Err.Description + "</B><br>" & sql & "<br>"

   'Check for no-record case.
   ElseIf RS.EOF And RS.BOF Then

      Response.Write "No records were found for this unit."

   'Valid data was received from the query.
   Else
	Dim Ctr
Dim RowCtr

      Response.Write "<table BORDER = '3.0' cellspacing='0' cellpadding='1'>"

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

   End If
 
End Sub

%>