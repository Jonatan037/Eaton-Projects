<%Option Explicit%>
<%Response.Buffer = TRUE%>
<% Response.Clear %>
<html>

<head>
<title>ePDU Test Report</title>


<STYLE TYPE="text/css">
<!--
TD{font-family: Arial; font-size: 10pt;}
--->
</STYLE>

</head>

<body>


<!-- #include File=..\\..\Tools\adovbs.inc -->


<%

Dim Conn				'Database connection.

Dim YPO_INDEXID			'The INDEXID from the ypo database qdms_master_index table.
Dim EPDU_ResultCount	'The ResultsId field returned from the database qdms_master_index table.
'Dim INDEX_ID			'The INDEX_ID for the ePDU_Results_Master database MasterIndex table.
Dim strConnection		'The connection information for the ePDU_Results_Master database.

Dim rs


'Get the INDEX_ID from the ypo database qdms_master_index table that was passed from the calling page.
YPO_INDEXID = Request("ID")


'Create a connection object.
Set Conn = Server.CreateObject("ADODB.Connection")

'Open a connection to the YPO database.
Conn.Open "ypo"


'Get the connection information for the database that contains the data for the report for the ID that was passed from the calling page.
Set rs = Conn.Execute("SELECT I.ResultsID, I.SerialNumber, D.ConnectionString FROM qdms_master_index AS I INNER JOIN qdms_database_ids as D ON I.DBID = D.DBID WHERE INDEXID = " & YPO_INDEXID)

'Save the connection info.
EPDU_ResultCount = rs("ResultsID")
strConnection = rs("ConnectionString")


'Close the recordset and connection to the YPO database.
rs.Close
Set rs = Nothing
Conn.Close


'Open a connection to the ePDU_Results_Master database.
Conn.Open strConnection



ShowHeader EPDU_ResultCount


Conn.Close
Set Conn = Nothing



'------------------------------------------------------------------------------------------------------------
Sub ShowHeader(ID)

	Dim RS
	Dim Query
	Dim Results
	Dim INDEX_ID


	'The the information from the MasterIndex table for this unit.
	Query = "SELECT * FROM MasterIndex WHERE ResultCount = " & ID

	Set RS = Conn.Execute(Query)


	' Check for error.
	If Err.Description <> "" Then
		Response.Write "<B>Error " + Hex(Err) + ": " + Err.Description + "</B><br>"

	' Check for no-record case.
	ElseIf RS.EOF And RS.BOF Then
		Response.Write "There are not any test steps for record " & ID & "<br>"

	' Valid data was received from the query.
	Else

		'Save the INDEX_ID for use in displaying the test steps.
		INDEX_ID = RS("INDEX_ID")

		'Change boolean to Passed/Failed string.
		If RS("Results") Then
			Results = "Passed"
		Else
			Results = "Failed"
		End If


		Response.Write "<table cellspacing=5 cellpadding=2 border=0>"

		Response.Write "<tr>"
		Response.Write "<td><b>Serial Number</b></td>"
		Response.Write "<td>" & RS("SerialNumber") & "</td>"
		Response.Write "</tr>"

		Response.Write "<tr>"
		Response.Write "<td><b>Part Number</b></td>"
		Response.Write "<td>" & RS("PartNumber") & "</td>"
		Response.Write "</tr>"

		Response.Write "<tr>"
		Response.Write "<td><b>Badge Number</b></td>"
		Response.Write "<td>" & RS("BadgeNumber") & "</td>"
		Response.Write "</tr>"

		Response.Write "<tr>"
		Response.Write "<td><b>Start Time</b></td>"
		Response.Write "<td>" & RS("StartTime") & "</td>"
		Response.Write "</tr>"

		Response.Write "<tr>"
		Response.Write "<td><b>Results</b></td>"
		Response.Write "<td>" & Results & "</td>"
		Response.Write "</tr>"

		Response.Write "<tr>"
		Response.Write "<td><b>Script Name</b></td>"
		Response.Write "<td>" & RS("ScriptName") & "</td>"
		Response.Write "</tr>"

		Response.Write "<tr>"
		Response.Write "<td><b>Script Version</b></td>"
		Response.Write "<td>" & RS("ScriptVersion") & "</td>"
		Response.Write "</tr>"

		Response.Write "<tr>"
		Response.Write "<td><b>Execution Time</b></td>"
		Response.Write "<td>" & RS("ExecutionTime") & "</td>"
		Response.Write "</tr>"

		Response.Write "</table>"

	End If


	RS.Close
	Set RS = Nothing

	Response.Write "<br><br><br>"

	ShowSteps INDEX_ID

End Sub




'------------------------------------------------------------------------------------------------------------
Sub ShowSteps(ID)

	Dim RS
	Dim Query
	Dim Results

	Query = "SELECT * FROM StepResults WHERE INDEX_ID = '" & ID & "' ORDER BY InsertOrder"

	Set RS = Conn.Execute(Query)


	' Check for error.
	If Err.Description <> "" Then
		Response.Write "<B>Error " + Hex(Err) + ": " + Err.Description + "</B><br>"

	' Check for no-record case.
	ElseIf RS.EOF And RS.BOF Then
		Response.Write "There are not any test steps for record " & ID & "<br>"

	' Valid data was received from the query.
	Else

		Response.Write "<table cellspacing=0 cellpadding=2 border=1>"

		'Create header.
		Response.Write "<tr>"
		Response.Write "<td><b>Step Name / Parameter Name</b></td>"
		Response.Write "<td><b>Lower Limit</b></td>"
		Response.Write "<td><b>Data</b></td>"
		Response.Write "<td><b>Upper Limit</b></td>"
		Response.Write "<td><b>Method</b></td>"
		Response.Write "<td><b>Units</b></td>"
		Response.Write "<td><b>Results</b></td>"
		Response.Write "<td><b>Step Execution Time</b></td>"
		Response.Write "</tr>"

		'Create a blank row.
		Response.Write "<tr>"
		Response.Write "<td colspan = 8>&nbsp;</td>"
		Response.Write "</tr>"

		Do While Not RS.EOF

			'Change boolean to Passed/Failed string.
			If RS("Results") Then
				Results = "Passed"
			Else
				Results = "Failed"
			End If


			Response.Write "<tr>"
			Response.Write "<td>" & RS("StepName") & "</td>"
			Response.Write "<td colspan = 5>&nbsp;</td>"
			Response.Write "<td>" & Results & "</td>"
			Response.Write "<td>" & RS("ExecutionTime") & "</td>"
			Response.Write "</tr>"


			ShowMeasurements RS("STEP_RESULTS_ID")

			'Put a blank row afer any measurements.
			Response.Write "<tr><td colspan = 8>&nbsp;</td></tr>"


			RS.MoveNext
		Loop

		Response.Write "</table>"

	End If


	RS.Close
	Set RS = Nothing


End Sub


'------------------------------------------------------------------------------------------------------------
Sub ShowMeasurements(ID)

	Dim RS
	Dim Query


	Query = "SELECT * FROM NumericResults WHERE STEP_RESULTS_ID = '" & ID & "' ORDER BY InsertOrder"


	Set RS = Conn.Execute(Query)


	' Check for error.
	If Err.Description <> "" Then
		Response.Write "<B>Error " + Hex(Err) + ": " + Err.Description + "</B><br>"

	' Check for no-record case.
	ElseIf RS.EOF And RS.BOF Then
		'Response.Write "No records were found. <br>"
		'Response.Write Query & "<br>&nbsp;<br>"

	' Valid data was received from the query.
	Else

		Do While Not RS.EOF


			Response.Write "<tr>"

			Response.Write "<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" & RS("ParameterName") & "</td>"
			Response.Write "<td>" & RS("LoLimit") & "</td>"
			Response.Write "<td>" & RS("Data") & "</td>"
			Response.Write "<td>" & RS("HiLimit") & "</td>"
			Response.Write "<td>" & RS("Method") & "</td>"
			Response.Write "<td>" & RS("Units") & "</td>"
			Response.Write "<td>" & RS("Results") & "</td>"
			Response.Write "<td>&nbsp;</td>"

			Response.Write "</tr>"


			RS.MoveNext
		Loop


	End If

	RS.Close
	Set RS = Nothing


End Sub



%>