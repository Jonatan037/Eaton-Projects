<%Option Explicit%>
<%Response.Buffer = TRUE%>
<% Response.Clear %>
<html>

<head>
<title>FERRUPS Production Test Report</title>


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

	Dim Conn			'Database connection.
	Dim lIndexID		'The index ID passed from the calling form.
	Dim strSerialNumber 'The serial number of the unit.
	Dim rs				'Working recordset.
	Dim sql

	'Get the index id from the calling form.
	lIndexID = Request("ID")


	Set Conn = Server.CreateObject("ADODB.Connection")
	Conn.Open Application("QDMS")


	'Get the serial number associated with this index id.
	sql = "SELECT SerialNumber FROM qdms_master_index WHERE INDEXID = " & lIndexId
	Set rs = Conn.Execute(sql)
	strSerialNumber = rs("SerialNumber")


	 if err.number <> 0 then 
	   response.write sql & "<br><br>" & err.description & "<br>"
	   response.end
	end if


	rs.Close
	Set rs = Nothing
	Conn.Close




	'Open a connection to the global services database on server RDUPSDDB02
	'Conn.Open "BirthCert"
	Conn.Open "Provider=SQLOLEDB;Data Source=rdupsddb02;Database=BirthCert;Trusted_Connection=Yes;"
	'Conn.Open "Provider=SQLOLEDB;Data Source=rdupsddb02;Database=BirthCert;Integrated Security=True;Trusted_Connection=Yes"



	 if err.number <> 0 then 
	   response.write err.description & "<br>"
	   response.end
	end if


	'Get the test records for this serial number
	sql = "SELECT * FROM bcerts WHERE SerialNumber = '" & strSerialNumber & "'"
	Set rs = Conn.Execute(sql)


	 if err.number <> 0 then 
	   response.write sql & "<br><br>" & err.description & "<br>"
	   response.end
	end if


	' Check for error.
	If Err.Description <> "" Then
		Response.Write "<B>Error " + Hex(Err) + ": " + Err.Description + "</B><br>"

	' Check for no-record case.
	ElseIf RS.EOF And RS.BOF Then

		Response.Write "No records were found on the global services database for unit with serial number = " & strSerialNumber

	' Valid data was received from the query.
	Else


		Do While NOT RS.EOF

			GenerateTestReport RS

			RS.MoveNext

		Loop

	End If

	RS.Close
	Set RS = Nothing


	Conn.Close
	Set Conn = Nothing





Sub GenerateTestReport(RS)

	'Define variables to hold the header information.

	Dim hTestCodeVersionNumber	'Not a unit paramater

	Dim hTime					'F2VAL
	Dim hDate					'F3VAL
	Dim hSoftwareVersion		'F4VAL
	Dim hModelNumber			'F5VAL

    Dim hNumberHeaderFields		'F6VAL = The number of fields that make up the header. This number may varry.

	'The possible header fields.
    Dim hSerialNumber		'Stored in database as SerialNumber, not F7VAL field.
    Dim hLogicBoard			'2
    Dim hPowerBoard			'3
    Dim hAuxPwrBoard		'4
    Dim hControlPower		'5
    Dim hHeatSink			'6
    Dim hBattCharger		'7
    Dim hDriverBoard		'8
    Dim hInputVolts			'9
    Dim hOutputVolts		'10
    Dim hBatteryType		'11
    Dim hRetestBy			'12
    Dim hPartNumber			'13

	Dim hNumberParameters	'Field location = 6 + hNumberHeaderFields + 1
	Dim hParameterStart
	Dim hParameterEnd

	Dim ctr
	Dim temp

	'Get the fixed values.
	hTestCodeVersionNumber 	= RS("F1VAL")
	hTime					= RS("F2VAL")
	hDate					= RS("F3VAL")
	hSoftwareVersion		= RS("F4VAL")
	hModelNumber			= RS("F5VAL")
	hNumberHeaderFields		= RS("F6VAL")
	hSerialNumber			= RS("SerialNumber")

	hNumberParameters		= RS("F" & 6 + hNumberHeaderFields + 1  & "VAL")
	hParameterStart			= 6 + hNumberHeaderFields + 2


	'Get the non-fixed header fields, excepting SerialNumber
	For ctr = 2 to hNumberHeaderFields

		temp = RS("F" & ctr + 6 & "VAL")

		Select Case ctr

			Case 2
    			hLogicBoard		= temp
			Case 3
	    		hPowerBoard		= temp
			Case 4
				hAuxPwrBoard	= temp
			Case 5
				hControlPower	= temp
			Case 6
				hHeatSink		= temp
			Case 7
				hBattCharger	= temp
			Case 8
				hDriverBoard	= temp
			Case 9
				hInputVolts		= temp
			Case 10
				hOutputVolts	= temp
			Case 11
				hBatteryType	= temp
			Case 12
				hRetestBy		= temp
			Case 13
				hPartNumber		= temp
			Case Else

		End Select



	Next




	Response.Write "<table width=700 cellspacing=0 cellpadding=0 border=0 align='center'>"
	Response.Write "<caption><big><big><big>EATON</big></big></big><br><big>FERRUPS FINAL TEST PRINTOUT</big></caption>"

	'Starter row
	Response.Write "<tr>"
		Response.Write "<td width=175><b>&nbsp;</b></td>"
		Response.Write "<td width=175><b>&nbsp;</b></td>"
		Response.Write "<td width=175><b>&nbsp;</b></td>"
		Response.Write "<td width=175><b>&nbsp;</b></td>"
	Response.Write "</tr>"

	Response.Write "<tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>Date:   " & hDate & "</td></tr>"
	Response.Write "<tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>Time:   " & hTime& "</td></tr>"

	Response.Write "<tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr>"

	Response.Write "<tr><td>Serial Number:</td><td>" & hSerialNumber & "</td><td>&nbsp;</td><td>&nbsp;</td></tr>"



	Response.Write "<tr>"
		Response.Write "<td>Part Number:</td>"
		Response.Write "<td>" & hPartNumber & "</td>"
		Response.Write "<td>Logic Board:</td>"
		Response.Write "<td>" & hLogicBoard & "</td>"
	Response.Write "</tr>"

	Response.Write "<tr>"
		Response.Write "<td>Software Vers:</td>"
		Response.Write "<td>" & hSoftwareVersion & "</td>"
		Response.Write "<td>Power Board:</td>"
		Response.Write "<td>" & hPowerBoard & "</td>"
	Response.Write "</tr>"

	Response.Write "<tr>"
		Response.Write "<td>Model Number:</td>"
		Response.Write "<td>" & hModelNumber & "</td>"
		Response.Write "<td>Aux Pwr Board:</td>"
		Response.Write "<td>" & hAuxPwrBoard & "</td>"
	Response.Write "</tr>"

	Response.Write "<tr>"
		Response.Write "<td>Input Volts:</td>"
		Response.Write "<td>" & hInputVolts & "</td>"
		Response.Write "<td>Control Power:</td>"
		Response.Write "<td>" & hControlPower & "</td>"
	Response.Write "</tr>"

	Response.Write "<tr>"
		Response.Write "<td>Output Volts:</td>"
		Response.Write "<td>" & hOutputVolts & "</td>"
		Response.Write "<td>Heat Sink:</td>"
		Response.Write "<td>" & hHeatSink & "</td>"
	Response.Write "</tr>"

	Response.Write "<tr>"
		Response.Write "<td>Battery Type:</td>"
		Response.Write "<td>" & hBatteryType & "</td>"
		Response.Write "<td>Batt Charger:</td>"
		Response.Write "<td>" & hBattCharger & "</td>"
	Response.Write "</tr>"

	Response.Write "<tr>"
		Response.Write "<td>Retested By:</td>"
		Response.Write "<td>" & hRetestBy & "</td>"
		Response.Write "<td>Driver Board:</td>"
		Response.Write "<td>" & hDriverBoard & "</td>"
	Response.Write "</tr>"

	Response.Write "<tr>"
		Response.Write "<td>&nbsp;</td>"
		Response.Write "<td>&nbsp;</td>"
		Response.Write "<td>&nbsp;</td>"
		Response.Write "<td>&nbsp;</td>"
	Response.Write "</tr>"


	hParameterEnd = CInt( (hNumberParameters / 4) + 1 )

	On Error Resume Next

	For ctr = 0 to hParameterEnd

		Response.Write "<tr>"

			Response.Write "<td>" & RS("F" & hParameterStart + ctr                       & "VAL") & "</td>"
			Response.Write "<td>" & RS("F" & hParameterStart + ctr + 1 + (hParameterEnd * 1) & "VAL") & "</td>"
			Response.Write "<td>" & RS("F" & hParameterStart + ctr + 2 +  hParameterEnd * 2 & "VAL") & "</td>"
			Response.Write "<td>" & RS("F" & hParameterStart + ctr + 3 +  hParameterEnd * 3 & "VAL") & "</td>"
		Response.Write "</tr>"


	Next


	Response.Write "</table>"


End Sub



%>
</body>
</html>
