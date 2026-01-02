<%Option Explicit%>
<%Response.Buffer = TRUE%>
<% Response.Clear %>
<html>

<head>
<title>NCR Defect Report</title>


<STYLE TYPE="text/css">
<!--
TD{font-family: Arial; font-size: 10pt;}
--->
</STYLE>

</head>

<body>


<!-- #include File=adovbs.inc -->


<%

On Error Resume Next

Dim Conn				'Database connection.
Dim Sql				'The query to be executed.

Dim lIndexID
Dim lResultsID
Dim fld
Dim rs

lIndexID = Request("ID")



Set Conn = Server.CreateObject("ADODB.Connection")
'Conn.ConnectionTimeout = 90
Conn.Open Application("QDMS")



Set rs = Conn.Execute("SELECT ResultsID FROM qdms_master_index WHERE INDEXID = " & lIndexId)

lResultsID = rs("ResultsID")


rs.Close
Set rs = Nothing


sql = "SELECT * FROM ncr_defects_local_copy WHERE [KEY] = " & lResultsID


'Open a recordset that gets memo field data properly.
Set RS = Server.CreateObject("ADODB.RecordSet")
RS.CursorLocation = adUseClient
RS.Open sql, Conn, adOpenKeyset



' Check for error.
If Err.Description <> "" Then
	Response.Write "<B>Error " + Hex(Err) + ": " + Err.Description + "</B><br>" & sql

' Check for no-record case.
ElseIf RS.EOF And RS.BOF Then

	Response.Write "No records were found for this unit."

' Valid data was received from the query.
Else

	Response.Write "NCR Database - Defect Report<br><br><hr><br>"

	Response.Write "<table cellspacing=0 cellpadding=2 border=3>"

	For Each fld In RS.Fields

		 Response.Write "<tr>"
		 Response.Write "<td><b>" & fld.Name & "     </b></td>"

		 If IsNull(fld.Value) Then
		 	Response.Write "<td>&nbsp;</td>"
		 Else
		 	Response.Write "<td>" & fld.Value & "</td>"
		 End If

		 Response.Write "</tr>"

	Next

	Response.Write "</table>"


End If

RS.Close
Set RS = Nothing


Conn.Close
Set Conn = Nothing




%>