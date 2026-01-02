<%Option Explicit%>
<%Response.Buffer = TRUE%>
<% Response.Clear %>
<html>

<head>
<title>NCR Test Complete Record</title>


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

Conn.Open Application("QDMS")

'Get the number to use as an index into the ncr database table.
Set rs = Conn.Execute("SELECT ResultsID FROM qdms_master_index WHERE INDEXID = " & lIndexId)


lResultsID = rs("ResultsID")

rs.close
set rs = nothing



sql = " SELECT ncr_log_local_copy.* " & _
      " FROM qdms_part_numbers INNER JOIN ncr_log_local_copy ON qdms_part_numbers.PartNumber = ncr_log_local_copy.TOPBOM " & _
      "WHERE " & _
         "( qdms_part_numbers.Family = '9395' AND qdms_part_numbers.Category = 'UPM' ) " & _
         "AND ncr_log_local_copy.[DATE] Between '8/1/2015' And '8/31/2015' "


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

	Response.Write "NCR Database - Test Complete Record<br><br><hr><br>"

	Response.Write "<table cellspacing=3 cellpadding=2 border=0>"

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