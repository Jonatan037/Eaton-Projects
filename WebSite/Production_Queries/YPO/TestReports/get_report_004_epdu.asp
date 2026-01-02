<%Option Explicit%>
<%Response.Buffer = TRUE%>
<% Response.Clear %>
<html>

<head>
<title>ePDU Production Test Report</title>


<STYLE TYPE="text/css">
<!--
TD{font-family: Arial; font-size: 10pt;}
--->
</STYLE>

</head>

<body>


<!-- #include File=adovbs.inc -->


<%

Dim Conn				'Database connection.
Dim Sql				'The query to be executed.

Dim lIndexID
Dim lResultsID
Dim strConnection
Dim strSerialNumber
Dim fld
Dim rs
Dim rsFailureInfo

lIndexID = Request("ID")



Set Conn = Server.CreateObject("ADODB.Connection")
'Conn.ConnectionTimeout = 90
Conn.Open Application("QDMS")




Set rs = Conn.Execute("SELECT I.ResultsID, I.SerialNumber, D.ConnectionString FROM qdms_master_index AS I INNER JOIN qdms_database_ids as D ON I.DBID = D.DBID WHERE INDEXID = " & lIndexId)

lResultsID = rs("ResultsID")
strConnection = rs("ConnectionString")
strSerialNumber = rs("SerialNumber")


rs.Close
Set rs = Nothing
Conn.Close



Conn.Open strConnection

Set rs = Conn.Execute("SELECT * FROM Index WHERE ID = " & lResultsID)

Set rsFailureInfo = Conn.Execute("SELECT * FROM [View - Failure Information] WHERE ID = " & lResultsID)

' Check for error.
If Err.Description <> "" Then
	Response.Write "<B>Error " + Hex(Err) + ": " + Err.Description + "</B><br>"

' Check for no-record case.
ElseIf RS.EOF And RS.BOF Then

	Response.Write "No records were found for this unit."

' Valid data was received from the query.
Else

	Response.Write "<table cellspacing=0 cellpadding=2 border=0>"

	For Each fld In RS.Fields

		 Response.Write "<tr>"
		 Response.Write "<td><b>" & fld.Name & "     </b></td>"
		 Response.Write "<td>" & fld.Value & "</td>"
		 Response.Write "</tr>"

	Next

	Response.Write "</table>"


	Response.Write "<BR><BR>"

	If NOT rsFailureInfo.BOF Then

		Response.Write "<table cellspacing=0 cellpadding=2 border=0>"
		Response.Write "<caption>Failure Information</caption>"

		For Each fld In rsFailureInfo.Fields

			 Response.Write "<tr>"
			 Response.Write "<td><b>" & fld.Name & "     </b></td>"
			 Response.Write "<td>" & fld.Value & "</td>"
			 Response.Write "</tr>"

		Next

		Response.Write "</table>"

	End If


End If

RS.Close
Set RS = Nothing

rsFailureInfo.Close
Set rsFailureInfo = Nothing

Conn.Close
Set Conn = Nothing




%>