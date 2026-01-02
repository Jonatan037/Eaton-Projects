<%Option Explicit%>
<%Response.Buffer = TRUE%>
<% Response.Clear %>
<html>

<head>
<title>93PM Process Capability</title>
</head>

<body>

<!-- #include File=GenericTable.Inc -->
<!-- #include File=adovbs.inc -->


<%

Dim cnYPO			'Database connection for the YPO database.
Dim Conn			'Connection for the rpo_proddata server.

Dim Sql				'The query to be executed.
Dim QueryStartDate
Dim QueryEndDate
Dim lResultsID

Dim rsIndex
Dim rsProgram

Dim rsTestResults

Dim sTestStep
Dim sPartNumber
Dim iCtr


'Get the date from the calling form.
QueryStartDate = CDate(Request("StartMonth") & "/" & Request("StartDay") & "/" & Request("StartYear") )
QueryEndDate   = CDate(Request("EndMonth")   & "/" & Request("EndDay")   & "/" & Request("EndYear") )

QueryEndDate   = QueryEndDate + 1


'Put the dates in the proper format for the query.
QueryStartDate = "'" & QueryStartDate & "'"
QueryEndDate   = "'" & QueryEndDate & "'"


'Get all of the test step names
'sTestStep = Split("Verify Output Freq, Verify Voltage Setting", ",")
sTestStep = Split("Online Out Freq, Online Out Vrms Max Load", ",")



'Convert all of the test step names to upper case
For iCtr = LBound(sTestStep) To UBound(sTestStep)
	sTestStep(iCtr) = Trim( UCase( sTestStep(iCtr) ) )
Next


'sPartNumber = Trim(Request("PartNumber"))


'If Len(sPartNumber) = 0 Then
'	Response.Write "You must enter values for the part number and test step fields."
'	Response.End
'End If


'sPartNumber = UCase(sPartNumber)




Set cnYPO = Server.CreateObject("ADODB.Connection")
Server.ScriptTimeout = 3600
cnYPO.ConnectionTimeout = 90
cnYPO.Open Application("QDMS")


Set Conn = Server.CreateObject("ADODB.Connection")
'Conn.Open "Provider=SQLOLEDB;Data Source=rpo-proddata;Database=rpo_proddata;Trusted_Connection=Yes;"
Conn.Open "Provider=SQLOLEDB;Data Source=rpo_tdm;Database=tdm;Trusted_Connection=Yes;"

Sql = "SELECT I.DBID, I.PartNumber, I.SerialNumber, I.Sequence, I.StartTime, I.TestResult, I.ComputerName, I.ResultsID, P.Family, P.Category " & _
      "FROM qdms_master_index AS I INNER JOIN qdms_part_numbers AS P ON I.PartNumber = P.PartNumber " & _
      "WHERE " & _
         "I.RecordType >= 100 AND P.Family = '93PM-L' AND I.Sequence = 1 AND I.TestResult = 'Pass' AND " & _
         "StartTime BETWEEN " & QueryStartDate & " AND " & QueryEndDate




'response.write sql
'response.end

Set rsIndex = cnYPO.Execute(Sql)



Response.Clear
Response.ContentType = "Application/vnd.ms-excel"

Response.Write "Part Number" & chr(9)
Response.Write "Serial Number" & chr(9)
Response.Write "Start Time" & chr(9)
Response.Write "Overall Test Result" & chr(9)
Response.Write "Computer Name" & chr(9)
Response.Write "Family" & chr(9)
Response.Write "Category" & chr(9)

Response.Write "Test Name" & chr(9)
Response.Write "Minimum" & chr(9)
Response.Write "Actual" & chr(9)
Response.Write "Maximum" & chr(9)
Response.Write "Result" & chr(9)
Response.Write "TestComments" & chr(9)

Response.Write vbCrLf

On Error Resume Next

Do While Not rsIndex.EOF

	lResultsID = rsIndex("ResultsID")
	GetResultsData rsTestResults, lResultsID

	PrintStepInfo rsIndex("Family"), rsIndex("Category")

	rsIndex.MoveNext
Loop






Conn.Close
Set Conn = Nothing

cnYPO.Close
Set cnYPO = Nothing




'----------------------------------------------------------------------------------------------------
Sub GetResultsData(rs, lResultsID)

	Dim sql

'----------------------------------------------

sql = "SELECT TestResults.Id AS TestResultId, TestRuns.Id AS TestRunId, TestRuns.LineId, Lines.LineName, " & _
      "TestRuns.WorkstationId, Stations.WorkstationName, TestRuns.ParentStationId, ParentStations.WorkstationName AS ParentStationName,  " & _
      "Catalogs.CatalogNumber, SerialNos.SerialNumber, Shifts.ShiftName, Operators.OperatorName, TestRuns.Passed, TestSeq.TestSequenceName,  " & _
      "TestResults.InstructionId, Instructions.InstructionName,  Units.Units, TestResults.SequenceNumber, TestRuns.StartTime,  " & _
      "TestResults.EndTime, TestRuns.TestRunSpan, TestResults.UpperLimit, TestResults.LowerLimit,  " & _
      "TestResults.UpperControlLimit, TestResults.LowerControlLimit, TestResults.Results, TestResults.TestComments,  " & _
      "Status.Status, TestRuns.TestRunType " & _
"FROM dbo.TDM_TEST_RESULT_RUN AS TestRuns INNER JOIN " & _
	  "dbo.TDM_TEST_RESULT_LINES AS Lines ON Lines.Id = TestRuns.LineId INNER JOIN " & _
	  "dbo.TDM_TEST_RESULT_WORKSTATIONS AS Stations ON Stations.Id = TestRuns.WorkstationId INNER JOIN " & _
	  "dbo.TDM_TEST_RESULT_WORKSTATIONS AS ParentStations ON ParentStations.Id = TestRuns.ParentStationId INNER JOIN " & _
	  "dbo.TDM_TEST_RESULT_CATALOGS AS Catalogs ON Catalogs.Id = TestRuns.CatalogNoId INNER JOIN " & _
	  "dbo.TDM_TEST_RESULT_SERIALNUMBERS AS SerialNos ON SerialNos.Id = TestRuns.SerialNoId INNER JOIN " & _
	  "dbo.TDM_TEST_RESULT_SHIFTS AS Shifts ON Shifts.Id = TestRuns.ShiftId INNER JOIN " & _
	  "dbo.TDM_TEST_RESULT_OPERATORS AS Operators ON Operators.Id = TestRuns.OperatorId INNER JOIN " & _
	  "dbo.TDM_TEST_RESULTS AS TestResults ON TestResults.TestRunId = TestRuns.Id INNER JOIN " & _
	  "dbo.TDM_TEST_RESULT_TESTSEQUENCES AS TestSeq ON TestSeq.Id = TestResults.TestSequenceId INNER JOIN " & _
	  "dbo.TDM_TEST_RESULT_INSTRUCTIONS AS Instructions ON Instructions.Id = TestResults.InstructionId INNER JOIN " & _
	  "dbo.TDM_TEST_RESULT_UNITS AS Units ON Units.Id = TestResults.UnitId INNER JOIN " & _
	  "dbo.TDM_TEST_RESULT_STATUS AS Status ON Status.Id = TestResults.StatusId  " & _
"WHERE TestRuns.Id = " & lResultsID & " " & _
"ORDER BY TestResults.SequenceNumber"

'----------------------------------------------


	Set rs = Conn.Execute(sql)


End Sub





'----------------------------------------------------------------------------------------------------
Sub PrintStepInfo(Family, Category)

	Dim minimum
	Dim actual
	Dim maximum
	Dim instruction_name
	Dim test_comments

	Dim L1	'Output voltage L1
	Dim L2	'Output voltage L2
	Dim L3	'Output voltage L3

	'On Error Resume Next

	With rsTestResults

		.MoveFirst

		Do Until .EOF

			instruction_name = Trim( .Fields("InstructionName") )

			test_comments = Trim(.Fields("TestComments") )

			'Get the data for UPM #1 only.
			If Left(instruction_name, 23) = "Verify Output Frequency" OR instruction_name = "Verify Output Voltage" Then

				'Parse the TestComments for the desired data.
				If instruction_name = "Verify Output Voltage" Then

					get_output_voltage test_comments, minimum, maximum, L1, L2, L3

					'L1 output voltage
					response.write Trim( .Fields("CatalogNumber") ) & chr(9)
					response.write Trim( .Fields("SerialNumber") ) & chr(9)
					response.write Trim( .Fields("StartTime") ) & chr(9)
					response.write Trim( .Fields("Passed") ) & chr(9)
					response.write Trim( .Fields("WorkstationName") ) & chr(9)
					response.write Family & chr(9)
					response.write Category & chr(9)
					response.write instruction_name & " L1" & chr(9)
					response.write minimum & chr(9)
					response.write L1 & chr(9)
					response.write maximum & chr(9)				
					response.write Trim( .Fields("Status") ) & chr(9)
					response.write test_comments & chr(9)
					response.write vbcrlf


					'L2 output voltage
					response.write Trim( .Fields("CatalogNumber") ) & chr(9)
					response.write Trim( .Fields("SerialNumber") ) & chr(9)
					response.write Trim( .Fields("StartTime") ) & chr(9)
					response.write Trim( .Fields("Passed") ) & chr(9)
					response.write Trim( .Fields("WorkstationName") ) & chr(9)
					response.write Family & chr(9)
					response.write Category & chr(9)
					response.write instruction_name & " L2" & chr(9)
					response.write minimum & chr(9)
					response.write L2 & chr(9)
					response.write maximum & chr(9)				
					response.write Trim( .Fields("Status") ) & chr(9)
					response.write test_comments & chr(9)
					response.write vbcrlf


					'L3 output voltage
					response.write Trim( .Fields("CatalogNumber") ) & chr(9)
					response.write Trim( .Fields("SerialNumber") ) & chr(9)
					response.write Trim( .Fields("StartTime") ) & chr(9)
					response.write Trim( .Fields("Passed") ) & chr(9)
					response.write Trim( .Fields("WorkstationName") ) & chr(9)
					response.write Family & chr(9)
					response.write Category & chr(9)
					response.write instruction_name & " L3" & chr(9)
					response.write minimum & chr(9)
					response.write L3 & chr(9)
					response.write maximum & chr(9)				
					response.write Trim( .Fields("Status") ) & chr(9)
					response.write test_comments & chr(9)
					response.write vbcrlf


				Else
					get_frequency test_comments, minimum, actual, maximum

					response.write Trim( .Fields("CatalogNumber") ) & chr(9)
					response.write Trim( .Fields("SerialNumber") ) & chr(9)
					response.write Trim( .Fields("StartTime") ) & chr(9)
					response.write Trim( .Fields("Passed") ) & chr(9)
					response.write Trim( .Fields("WorkstationName") ) & chr(9)
					response.write Family & chr(9)
					response.write Category & chr(9)

					response.write instruction_name & chr(9)
					response.write minimum & chr(9)
					response.write actual & chr(9)
					response.write maximum & chr(9)
					response.write Trim( .Fields("Status") ) & chr(9)
					response.write test_comments& chr(9)	
					response.write vbcrlf

				End If	
	

			End If

			'Stop once the output voltage has been located.
			If instruction_name = "Verify Output Voltage" Then Exit Do

      			.MoveNext

    		Loop


  	End With

End Sub


Sub get_frequency(TestComments, Minimum, Actual, Maximum)

	dim limits
	Dim temp

	Minimum = 0
	Actual = 0
	Maximum = 0

	'Example line of data.
	'(00105)  (TotalTime: 2.3372549)  (PW_DMM_Read_NumericLimitTest)  Limits: 59.90-60.10; value: 60.00


	'Get the data starting at "Limits:"
	temp = Trim( Mid( TestComments, InStr(TestComments, "Limits:") + 7 ) )	 
	
	'Get the actual value.
	Actual = Trim( Mid( temp, Instr(temp, "value:") + 6 ) )	

	'Get just the limits.
	limits = Trim( Left( temp, Instr(temp, ";") - 1 ) )	

	'Get the lower limit.
	Minimum = Trim( Left( limits, Instr(limits, "-") - 1 ) )

	'Get the upper limit
	Maximum = Trim( Mid( limits, Instr(limits, "-") + 1 ) )


End Sub


Sub get_output_voltage(TestComments, Minimum, Maximum, L1, L2, L3)

	Dim temp
	Dim nominal_voltage

	nominal_voltage = 120

	Minimum = nominal_voltage * 0.99
	Maximum = nominal_voltage * 1.01
	
	'Defaults
	L1 = 0
	L2 = 0
	L3 = 0

	'Example line of data
	'(00237) (TotalTime: 3.090263) (PW_DMMReadMultipleNumericLimitTest) Elem1 479.52;Elem2 480.36;Elem3 479.49 
	
	'Get the section containing the measurements and remove the tag for Elem1
	temp = Trim( Mid(TestComments, Instr(TestComments, "Elem1") + 5) )
	
	'Get the Elem1 measurement
	L1 = Trim( Left( temp, Instr(temp, ";") -1 ) )

	'Remove the Elem1 measurement from the string along with the tag for Elem2
	temp = Trim( Mid(temp, Instr(temp, ";") + 6) )
	
	'Get the Elem2 measurement
	L2 = Trim( Left( temp, Instr(temp, ";") -1 ) )

	'Remove the Elem2 measurement from the string along with the tag for Elem3
	temp = Trim( Mid(temp, Instr(temp, ";") + 6) )

	'Get the Elem3 measurement
	L3 = temp

End Sub
'----------------------------------------------------------------------------------------------------

%>

