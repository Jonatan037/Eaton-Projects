<%Option Explicit%>
<html>

<head>

<title>TVSS Test Record</title>

<style>
	/* Print-friendly styles */
	@media print {
		.no-print {
			display: none !important;
		}
		body {
			margin: 0;
			padding: 20px;
		}
		table {
			page-break-inside: auto;
		}
		tr {
			page-break-inside: avoid;
			page-break-after: auto;
		}
	}
	
	/* Screen styles */
	.print-button {
		background-color: #003366;
		color: white;
		padding: 10px 20px;
		border: none;
		border-radius: 5px;
		font-family: Segoe UI;
		font-size: 14px;
		cursor: pointer;
		margin-bottom: 20px;
		display: inline-block;
	}
	
	.print-button:hover {
		background-color: #004488;
	}
	
	.button-container {
		margin-bottom: 20px;
	}
</style>

<script type="text/javascript">
	function printReport() {
		window.print();
	}
</script>

</head>

<body>

	<h1 style="font-family: Segoe UI; font-size: 24px; color: #003366; text-align: left; margin-bottom: 10px;">
    SPD - Test Report
	</h1>
	<hr style="border: 1px solid #003366; width: 100%; margin-bottom: 30px;" />


<%
'--------------------------------------------------------------------------------------------------------

	Dim strID
	Dim Conn

	On Error Resume Next


	Set Conn = Server.CreateObject("ADODB.Connection")

	'Open the database defined in the Global.asa file.
	Conn.Open Application("ProductionDatabase")


	strID = UCase(Request("ID"))


	GetHeader Conn, strID


	GetMeasurements Conn, strID


	GetBoolTest Conn, strID


	'Always close the connection, even if errors occurred
	If Not Conn Is Nothing Then
		If Conn.State <> 0 Then
			Conn.Close
		End If
		Set Conn = Nothing
	End If


'--------------------------------------------------------------------------------------------------------
Sub GetHeader(conn, ID)

	Dim RS
	Dim Query


  	Query =	"SELECT I.*, PN.ModelNumber " & _
			"FROM Index AS I LEFT JOIN PartNumbers AS PN ON I.PartNumber = PN.PartNumber " & _
			"WHERE I.ID = " & ID


	Set RS = Conn.Execute(Query)


	' Check for error.
	If Err.Description <> "" Then
		Response.Write "<B>Error " + Hex(Err) + ": " + Err.Description + "</B><br>"

	' Check for no-record case.
	ElseIf RS.EOF And RS.BOF Then
		Response.Write "No records were found. <br>"

	' Valid data was received from the query.
	Else



		Response.Write "<table border='0' cellspacing='5' cellpadding='5' style='border-collapse: collapse; font-family: Segoe UI; font-size: 14px;'>"


		Response.Write "<tr>"
			Response.Write "<td><b>Style Number:</b></td>"
			Response.Write "<td>" & RS("PartNumber") & "</td>"
		Response.Write "</tr>"

		Response.Write "<tr>"
			Response.Write "<td><b>Model Number:</b>&nbsp;&nbsp;&nbsp;</td>"
			Response.Write "<td>" & RS("ModelNumber") & "</td>"
		Response.Write "</tr>"

		Response.Write "<tr>"
			Response.Write "<td><b>Serial Number:</b></td>"
			Response.Write "<td>" & RS("SerialNumber") & "</td>"
		Response.Write "</tr>"

		Response.Write "<tr>"
			Response.Write "<td><b>Test Date:</b></td>"
			Response.Write "<td>" & FormatDateTime(RS("StartTime")) & "</td>"
		Response.Write "</tr>"

		Response.Write "<tr>"
			Response.Write "<td><b>Employee Number:</b></td>"
			Response.Write "<td>" & RS("Badge") & "</td>"
		Response.Write "</tr>"
		
		Response.Write "<tr>"
			Response.Write "<td><b>Workcell:</b></td>"
			Response.Write "<td>" & RS("Workcell") & "</td>"
		Response.Write "</tr>"

		Response.Write "</table>"

		Response.Write "<br><br>"

	End If


	RS.Close


End Sub




'--------------------------------------------------------------------------------------------------------
Sub GetMeasurements(Conn, ID)

	Dim RS
	Dim Query
	Dim ctr
	Dim Status			'Indication of PASS or FAIL for this test parameter.


	Query = "SELECT * FROM [Measurements View] WHERE ID = " & ID & " AND Status <> 2 ORDER BY [Parameter Name]"


	Set RS = Conn.Execute(Query)


	' Check for error.
	If Err.Description <> "" Then
		Response.Write "<B>Error " + Hex(Err) + ": " + Err.Description + "</B><br>"

	' Check for no-record case.
	ElseIf RS.EOF And RS.BOF Then
		Response.Write "No records were found. <br>"

	' Valid data was received from the query.
	Else

		
		Response.Write "<table border='1' cellspacing='5' cellpadding='5' style='border-collapse: collapse; font-family: Segoe UI; font-size: 14px;'>"


		'Create the table header row.
  		
		Response.Write "<tr style='background-color:#003366; color:white; font-family: Segoe UI; font-size: 14px;'>"
			Response.Write "<td><b>Test Parameter</b></td>"
			Response.Write "<td align='center'><b>Minimum</b></td>"
			Response.Write "<td align='center''><b>Actual</b></td>"
			Response.Write "<td align='center'><b>Maximum</b></td>"
			Response.Write "<td align='center'><b>Results</b></td>"
		Response.Write "</tr>"


		Do While Not RS.EOF

				Response.Write "<tr>"

					'Supress measurement value for the ground continuity test.
					If Left(RS("Parameter Name").Value, 17) = "Ground Continuity" Then

						Response.Write "<td><b>Ground Continuity</b></td>"
						Response.Write "<td align='center'>&nbsp;</td>"
						Response.Write "<td align='center'>&nbsp;</td>"
						Response.Write "<td align='center'>&nbsp;</td>"

					Else

						Response.Write "<td><b>" & RS("Parameter Name").Value & "</b></td>"
						Response.Write "<td align='center'>" & RS("Low Limit").Value & "</td>"
						Response.Write "<td align='center'>" & RS("Data").Value & "</td>"
						Response.Write "<td align='center'>" & RS("High Limit").Value & "</td>"

					End If

					
					If RS("Status").Value = 1 Then
						Status = "<td align='center' style='background-color:lightgreen;'>PASS</td>"
					Else
						Status = "<td align='center' style='background-color:red; color:white;'>FAIL</td>"
					End If

					Response.Write Status


				Response.Write "</tr>"

		   RS.MoveNext
		Loop


		Response.Write "</table>"
		Response.Write "</center>"
		Response.Write "<br><br>"

	End If


	RS.Close

	ReDim arrTestNames(0)

End Sub



'--------------------------------------------------------------------------------------------------------


Sub GetBoolTest(Conn, ID)

	Dim RS
	Dim Query
	Dim ctr
	Dim Status			'Indication of PASS or FAIL for this test parameter.


	Query = "SELECT * FROM [BoolTest] WHERE UUT_ID = " & ID & " AND Status <> 2 ORDER BY [Parameter]"


	Set RS = Conn.Execute(Query)


	' Check for error.
	If Err.Description <> "" Then
		Response.Write "<B>Error " + Hex(Err) + ": " + Err.Description + "</B><br>"

	' Check for no-record case.
	ElseIf RS.EOF And RS.BOF Then
		Response.Write "No more test records were found. <br>"

	' Valid data was received from the query.
	Else
			
		Response.Write "<table border='1' cellspacing='5' cellpadding='5' style='border-collapse: collapse; font-family: Segoe UI; font-size: 14px;'>"

		'Create the table header row.
  		Response.Write "<tr style='background-color:#003366; color:white; font-family: Segoe UI; font-size: 14px;'>"
			Response.Write "<td align='center''><b>Test Parameter</b></td>"
			Response.Write "<td align='center'><b>Data</b></td>"
			Response.Write "<td align='center'><b>Result</b></td>"
		Response.Write "</tr>"


		Do While Not RS.EOF

				Response.Write "<tr>"					

					Response.Write "<td><b>" & RS("Parameter").Value & "</b></td>"
					Response.Write "<td>" & RS("Data").Value & "</td>"				

					
					If RS("Status").Value = 1 Then
						Status = "<td align='center' style='background-color:lightgreen;'>PASS</td>"
					Else
						Status = "<td align='center' style='background-color:red; color:white;'>FAIL</td>"
					End If

					Response.Write Status

				Response.Write "</tr>"

		   RS.MoveNext
		Loop


		Response.Write "</table>"
		Response.Write "</center>"

	End If


	RS.Close

	ReDim arrTestNames(0)

End Sub

%>

	<br><br>

	<div class="button-container no-print">
		<button class="print-button" onclick="printReport()">Print / Save as PDF</button>
	</div>

</body>
</html>