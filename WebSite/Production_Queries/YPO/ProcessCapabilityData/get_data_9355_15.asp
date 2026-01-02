<%Option Explicit%>
<%Response.Buffer = TRUE%>
<% Response.Clear %>
<html>

<head>
<title>Process Capability</title>
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
sTestStep = Split("Check On Batt Output V", ",")


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
Conn.Open "Provider=SQLOLEDB;Data Source=rpo-proddata;Database=rpo_proddata;Trusted_Connection=Yes;"



Sql = "SELECT I.DBID, I.PartNumber, I.SerialNumber, I.Sequence, I.StartTime, I.TestResult, I.ComputerName, I.ResultsID, P.Family, P.Category " & _
      "FROM qdms_master_index AS I INNER JOIN qdms_part_numbers AS P ON I.PartNumber = P.PartNumber " & _
      "WHERE " & _
         "I.RecordType = 2 AND I.DBID = 2 AND P.Family = '9x55' AND P.PartNumber LIKE 'KA%' AND I.Sequence = 1 AND I.TestResult = 'Pass' AND " & _
         "StartTime BETWEEN " & QueryStartDate & " AND " & QueryEndDate


'response.write sql
'response.end

Set rsIndex = cnYPO.Execute(Sql)


Response.Clear
Response.ContentType = "Application/vnd.ms-excel"

Response.Write "Part Number" & chr(9)
Response.Write "Serial Number" & chr(9)
Response.Write "Sequence" & chr(9)
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


Response.Write vbCrLf

On Error Resume Next

Do While Not rsIndex.EOF
	lResultsID = rsIndex("ResultsID")
	GetResultsData rsTestResults, lResultsID, "spTestResults"
	PrintStepInfo sTestStep
	rsIndex.MoveNext
Loop






Conn.Close
Set Conn = Nothing

cnYPO.Close
Set cnYPO = Nothing




'----------------------------------------------------------------------------------------------------
Sub GetResultsData(rs, lResultsID, sProcedureName)

	Dim cmd


	Set cmd = Server.CreateObject("ADODB.Command")

	cmd.ActiveConnection = Conn

	cmd.CommandText = sProcedureName
	cmd.CommandType = adCmdStoredProc

	cmd.Parameters.Append cmd.CreateParameter ("[ResultID]",adInteger,adParamInput)
	cmd.Parameters("[ResultID]") = lResultsID

	Set rs = cmd.Execute

	set cmd = nothing


End Sub





'----------------------------------------------------------------------------------------------------
Sub PrintStepInfo(sTestStep)

	Dim tsLabel		'The overall name of the test step.
	Dim rdLabel		'The name of the actual parameter.
	Dim iCtr		'Counter for array indexing
	Dim blnGetData	'Flag to indicate that the data for this row should be retrieved.


	With rsTestResults

		.MoveFirst

		Do Until .EOF

			tsLabel = Trim(UCase(.Fields("TestLabel")))

			'Default value is to ignore this row of data.
			blnGetData = FALSE

			'Determine if the row of data meets the test step search criteria.
			For iCtr = LBound(sTestStep) To UBound(sTestStep)

				If sTestStep(iCtr) = "SHOW ALL" Then blnGetData = TRUE

				If sTestStep(iCtr) <> "" Then
					If Instr(tsLabel, sTestStep(iCtr)) Then blnGetData = TRUE
				End If

			Next

			'Get the data if the criteria was met.
			If blnGetData Then

				rdLabel = Trim(.Fields("rdLabel"))

				'Limit the results to the ones specified by the quality engineers.
				'If  Left(rdLabel,8) = "Out Freq" OR Right(rdLabel,7) = "UUT Out" Then

					Response.Write rsIndex("PartNumber") & chr(9)
					Response.Write rsIndex("SerialNumber") & chr(9)
					Response.Write rsIndex("Sequence") & chr(9)
					Response.Write rsIndex("StartTime") & chr(9)
					Response.Write rsIndex("TestResult") & chr(9)
					Response.Write rsIndex("ComputerName") & chr(9)
					Response.Write rsIndex("Family") & chr(9)
					Response.Write rsIndex("Category") & chr(9)

					Response.Write  Trim(.Fields("TestLabel") ) & " - " & rdLabel & chr(9)

					If IsNull(.Fields("Actual")) Then

						Response.Write .Fields("MinimumStr") & chr(9)
						Response.Write .Fields("ActualStr") & chr(9)
						Response.Write .Fields("MaximumStr") & chr(9)
						Response.Write .Fields("Result") & chr(9)

					Else

						Response.Write .Fields("Minimum") & chr(9)
						Response.Write .Fields("Actual") & chr(9)
						Response.Write .Fields("Maximum") & chr(9)
						Response.Write .Fields("Result") & chr(9)

					End If


					Response.Write vbCrLf

				'End If

			End If

      .MoveNext

    Loop


  End With


End Sub



'----------------------------------------------------------------------------------------------------

%>

