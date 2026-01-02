<%Option Explicit%>
<%Response.Buffer=true%>

<html>

<head>
<title>Raw emPower Data</title>
</head>

<body>


<h2 align="center">Raw emPower Data</h2>

<%
'On error resume next

Dim Conn			'Database connection.
Dim Sql				'The query to be executed.
Dim rs
Dim ctr


Dim DisplayStart
Dim DisplayEnd
Dim QueryStartDate
Dim QueryEndDate



'--------------------------------------------------------------------------------------------------------
'Put time in proper format.


DisplayStart = Request("StartMonth") & "/" & Request("StartDay") & "/" & Request("StartYear")
DisplayEnd   = Request("EndMonth")   & "/" & Request("EndDay")   & "/" & Request("EndYear")

if DisplayStart = DisplayEnd then
	Response.Write "<center>" & DisplayStart & "</center><P>"
else
	Response.Write "<center>" & DisplayStart & "&nbsp;&nbsp;&nbsp;" & "   To   " & "&nbsp;&nbsp;&nbsp;" & DisplayEnd & "</center><P>"
end if


QueryStartDate = "'" & CDate( Request("StartMonth") & "/" & Request("StartDay") & "/" & Request("StartYear") ) & "'"
QueryEndDate   = CDate(Request("EndMonth")   & "/" & Request("EndDay")   & "/" & Request("EndYear") ) + 1

QueryEndDate   = "'" & QueryEndDate & "'"


'Increase timeout for people using this query.
Session.Timeout = 3 		'Minutes
Server.ScriptTimeout = 180 	'Seconds



Sql = "SELECT " & _
         "ProgramID, ProgramName, " & _
         "ResultsID, StartTime, TotalErrors, TestResult, TestType, " & _
         "Info1Item, Info2Item, Info3Item, Info4Item, Info5Item, Info6Item, Info7Item, Info8Item, Info9Item, Info10Item " & _
      "FROM qdms_master_index " & _
      "WHERE StartTime BETWEEN " & QueryStartDate  & " AND " & QueryEndDate & " AND DBID IN (2,26) " & _
      "ORDER BY TestResult, DBID"



Set Conn = Server.CreateObject("ADODB.Connection")


Conn.ConnectionTimeout = 180	'Seconds


Conn.Open Application("QDMS")


Set rs = Conn.Execute (Sql) 



'No records for this time period.
if rs.EOF Then
   Response.Write "No test records exist for the specified time period."
else


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
               Else
                  Response.Write "<td>" & RS.Fields(Ctr) & "</td>"
               End If

            Next

      Response.Write "</tr>"

      RS.MoveNext

   Loop

   Response.Write "</table>"

end if



rs.Close
Conn.Close
Set rs = Nothing
set Conn = Nothing



%>
</body>
</html>
