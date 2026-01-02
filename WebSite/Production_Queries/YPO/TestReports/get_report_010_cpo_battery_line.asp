<%Option Explicit%>
<%Response.Buffer = TRUE%>
<% Response.Clear %>
<html>

<head>
<title>CPO Battery Line Production Test Report</title>


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
Dim Conn			'CPO Battery database connection
Dim Sql				'The query to be executed.

Dim lIndexID
Dim lResultsID
Dim strConnection
Dim strSerialNumber
Dim fld
Dim rs


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


'Open connection to the battery database.
Conn.Open strConnection


'Show any error that occurred with opening the battery databae.
If Err.Description <> "" Then 
   Response.Write "Error : " + Err.Description + "<br>" & strConnection
   Response.End
End If


Set rs = Conn.Execute("SELECT * FROM Battery_Cabinet_Test_Log WHERE RECORD_ID = " & lResultsID)


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



End If

RS.Close
Set RS = Nothing


Conn.Close
Set Conn = Nothing




%>