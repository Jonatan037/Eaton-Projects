<%Option Explicit%>
<html>

<head>
<title>Hipot Verification</title>
</head>

<body>

<h2 align="center">Enter Hipot Verification Data:</h2>

<%

Dim Conn

Set Conn = Server.CreateObject("ADODB.Connection")


Conn.Open "Hipot"





		Response.Write "<form method='POST' action='check_and_save.asp'>"

		Response.Write "<table align='center' BORDER = '0.0' cellspacing='2' cellpadding='2'>"


  		Response.Write "<tr>"
  			Response.Write "<td>Line Number: </td>"
			Response.Write "<td>" & getLineNumbers & "</td>"

		Response.Write "</tr>"


  		Response.Write "<tr>"
			Response.Write "<td>Hipot: </td>"
			Response.Write "<td>" & getHipotEquipment & "</td>"
		Response.Write "</tr>"

  		Response.Write "<tr>"
			Response.Write "<td>Badge Number: </td>"
			Response.Write "<td><input type='text' name='BadgeNumber' size='20'></td>"
		Response.Write "</tr>"


		'
  		Response.Write "<tr>"
			Response.Write "<td>Test Results: </td>"
			Response.Write "<td>" & _
			"<input type='radio' name='TestResults' value='Pass'> Pass<br>" & _
			"<input type='radio' name='TestResults' value='Fail'> Fail<br>" & _
			"</td>"
		Response.Write "</tr>"




		'Submit button
  		Response.Write "<tr>"
			Response.Write "<td colspan=2 align='center'>&nbsp;<br><input type='submit' value='Submit' name='B1'></td>"

		Response.Write "</tr>"



		Response.Write "</table>"



		Response.Write "</form>"


Conn.Close


Function getLineNumbers()

	Dim temp
	Dim RS


	Set RS = Conn.Execute("SELECT LINE_NUMBER_ID, DESCRIPTION FROM LINE_NUMBERS")

	' Check for error.
	If Err.Description <> "" Then
		Response.Write "<B>Error " + Hex(Err) + ": " + Err.Description + "</B><br>"
		Response.End

	' Check for no-record case.
	ElseIf RS.EOF And RS.BOF Then
		Response.Write "No records were found. <br>"
		Response.End

	' Valid data was received from the query.
	Else

		temp = "<select SIZE='1' NAME='LineNumber'>"


		Do While Not RS.EOF

			temp = temp + "<option value='" & RS("LINE_NUMBER_ID") & "'>" & RS("DESCRIPTION") & "</option>" & _

			RS.MoveNext
		Loop


		temp = temp + "</select>"

	End If

	RS.Close
	Set RS = NOTHING

	getLineNumbers = temp

End Function



Function getHipotEquipment()

	Dim temp
	Dim RS


	Set RS = Conn.Execute("SELECT EQUIPMENT_ID, MANUFACTURER, SERIAL_NUMBER FROM EQUIPMENT_LIST")

	' Check for error.
	If Err.Description <> "" Then
		Response.Write "<B>Error " + Hex(Err) + ": " + Err.Description + "</B><br>"
		Response.End

	' Check for no-record case.
	ElseIf RS.EOF And RS.BOF Then
		Response.Write "No records were found. <br>"
		Response.End

	' Valid data was received from the query.
	Else

		temp = "<select SIZE='1' NAME='SerialNumber'>"


		Do While Not RS.EOF

			temp = temp + "<option value='" & RS("EQUIPMENT_ID") & "'>" & RS("MANUFACTURER") + ", " + RS("SERIAL_NUMBER") & "</option>" & _

			RS.MoveNext
		Loop


		temp = temp + "</select>"

	End If

	RS.Close
	Set RS = NOTHING

	getHipotEquipment = temp

End Function

%>
</body>
</html>
