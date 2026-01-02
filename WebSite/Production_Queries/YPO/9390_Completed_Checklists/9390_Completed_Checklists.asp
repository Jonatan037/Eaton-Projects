<%Option Explicit%>
<%Response.Buffer = TRUE%>
<% Response.Clear %>
<html>

<head>
<title>9390 Checklists</title>

</head>

<body>

<!-- #include File=adovbs.inc -->


<%



Dim Conn
dim rs
Dim cmd
Dim Ctr
Dim RowCtr


Dim DisplayStart
Dim DisplayEnd
Dim QueryStartDate
Dim QueryEndDate

On error resume next


'--------------------------------------------------------------------------------------------------------
'Put time in proper format.


DisplayStart = Request("StartMonth") & "/" & Request("StartDay") & "/" & Request("StartYear")
DisplayEnd   = Request("EndMonth")   & "/" & Request("EndDay")   & "/" & Request("EndYear")

if DisplayStart = DisplayEnd then
	Response.Write "<center>" & DisplayStart & "</center><P>"
else
	Response.Write "<center>" & DisplayStart & "&nbsp;&nbsp;&nbsp;" & "   To   " & "&nbsp;&nbsp;&nbsp;" & DisplayEnd & "</center><P>"
end if


QueryStartDate = "'" & Request("StartMonth") & "/" & Request("StartDay") & "/" & Request("StartYear") & "'"
QueryEndDate   = CDate(Request("EndMonth")   & "/" & Request("EndDay")   & "/" & Request("EndYear") ) + 1

QueryEndDate   = "'" & QueryEndDate & "'"


'--------------------------------------------------------------------------------------------------------


'Increase timeout for people using this query.
Session.Timeout = 3 		'Minutes
Server.ScriptTimeout = 180 	'Seconds


Set Conn = Server.CreateObject("ADODB.Connection")


Conn.ConnectionTimeout = 30	'Seconds 180


Conn.Open Application("QDMS")




Set cmd = Server.CreateObject("ADODB.Command")

cmd.ActiveConnection = Conn

'Text for stored procedure with start and end dates.
cmd.CommandText = "usp_9390_checklists('9390'," & QueryStartDate & "," & QueryEndDate & ")"
cmd.CommandType = adCmdStoredProc

cmd.CommandTimeout = 30 '90


Set rs = cmd.Execute 

'Check for error.
if err.number <> 0 then 
   response.write cmd.CommandText & "<br><br>" & err.description & "<br>"
   response.end
end if




'--------------------------------------------------------------------------------------------------------

	Response.Write "<table align='center' BORDER = '3.0' cellspacing='0' cellpadding='1'>"

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
		Response.Write "</center>"	


'--------------------------------------------------------------------------------------------------------


set cmd = nothing

rs.Close
Conn.Close
Set rs = Nothing
set Conn = Nothing




'----------------------------------------------------------------------------------------------------

%>
</body>
</html>
