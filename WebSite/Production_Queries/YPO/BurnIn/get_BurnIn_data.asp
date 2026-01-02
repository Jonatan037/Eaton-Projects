<%Option Explicit%>
<%Response.Buffer = TRUE%>
<% Response.Clear %>
<html>

<head>
<title>BurnIn Data</title>

<STYLE TYPE="text/css">
<!--
TD{font-family: Arial; font-size: 8pt;}
--->
</STYLE>


</head>

<body>

<!-- #include File=GenericTable.Inc -->
<!-- #include File=adovbs.inc -->


<%

On Error Resume Next

Dim Conn				'Database connection.
Dim cnYPO				'Is the record removed when the connection is closed?
Dim Sql				'The query to be executed.

Dim lIndexID
Dim lResultsID
Dim strConnection
Dim strSerialNumber
Dim strStatements
Dim strSearchString
Dim strPartNumber
Dim strFamily
Dim strLabel
Dim strMin
Dim strActual
Dim strMax 
Dim strResult
Dim strStartTime

Dim rsSetup			'Connection information from the master_index and computer_ids table.
Dim rsProgram
Dim rsTestRunData
Dim rsTestResults
Dim rsIndex
Dim rsG3BurnIN
Dim QueryEndDate
Dim QueryStartDate

On Error Resume Next

'Get the date from the calling form.
QueryStartDate = CDate(Request("StartMonth") & "/" & Request("StartDay") & "/" & Request("StartYear") )
QueryEndDate   = CDate(Request("EndMonth")   & "/" & Request("EndDay")   & "/" & Request("EndYear") ) + 1

'This is the date on which the DurnIn data collection was started.
If QueryStartDate < CDate("08/01/2014") Then QueryStartDate = CDate("08/01/2014")
If QueryEndDate < QueryStartDate Then QueryEndDate = QueryStartDate + 1	

'Put the dates in the proper format for the query.
QueryStartDate = "'" & QueryStartDate & "'"
QueryEndDate   = "'" & QueryEndDate & "'"
	
'Connect to QDMS database
Set cnYPO = Server.CreateObject("ADODB.Connection")
cnYPO.Open Application("QDMS")

'find connection string to Empower database
strSearchString = "RPO_PRODDATA"

sql = "SELECT [DBID],[Description],[ConnectionString]FROM [QDMS].[dbo].[qdms_database_ids] Where Description = 'RPO_PRODDATA'"

Set rsSetup = cnYPO.Execute(Sql)
strConnection = rsSetup("ConnectionString")

'connect to Empower database
Set Conn = Server.CreateObject("ADODB.Connection")
Conn.Open strConnection

if err.number <> 0 then 
   response.write sql & "<br><br>" & err.description & "<br>"
   response.end
end if

rsSetup.Close
Set rsSetup = Nothing
   
'The timeout is in seconds.
cnYPO.ConnectionTimeout = 90
Server.ScriptTimeout = 180

'If ErrorOccurred(Err) Then Response.End
'strStatements = strStatements & "Connection successful<br>"

'create record set on all CAA for 9395 and 9355 - BurnIn data
Sql = "SELECT I.DBID, I.PartNumber, I.SerialNumber, I.StartTime, I.ComputerName, I.ResultsID, P.Family " & _
      "FROM qdms_master_index AS I INNER JOIN qdms_part_numbers AS P ON I.PartNumber = P.PartNumber " & _
      "WHERE " & _
         "I.RecordType = 4 AND " & _
         "P.Family IN ('9395','9355') AND " & _
         "StartTime BETWEEN " & QueryStartDate & " AND " & QueryEndDate

Set rsIndex = cnYPO.Execute(Sql)

	'Header
	PrintStepHeaderInfo
	
	'Print Empower BurnIn records
 Do While Not rsIndex.EOF
	lResultsID = rsIndex("ResultsID")
	strSerialNumber = rsIndex("SerialNumber")
	strPartNumber = rsIndex("PartNumber")
	strFamily = rsIndex("Family")
	strStartTime = rsIndex("StartTime")
	GetResultsData rsTestResults, lResultsID, "spTestResults"
	'If ErrorOccurred(Err) Then Response.End
	strStatements = strStatements & "Procedure execution successful<br>"
	PrintStepInfo strSerialNumber, strPartNumber, strFamily, strStartTime
	rsIndex.MoveNext
Loop
   
   'create query to pull G3 BurnIn records
   Sql = "SELECT [UUTFirstTestDate],[SerialNumber],[UnitType],[Minimum],[Actual],[Maximum],[Results] " & _
	"FROM [ePDU].[dbo].[BurnInData] Where UUTFirstTestDate BETWEEN " & QueryStartDate & " AND " & QueryEndDate 
   
   'pollulate rs via G3 BurnIn table
   Set rsG3BurnIN = cnYPO.Execute(Sql)
   
   'Loop thru rsG3BurnIN and print all records

Do While Not rsG3BurnIN.EOF
	
	If rsG3BurnIN("Results") = True then
		strResult = "Pass"
	Else
		strResult = "Fail"
	End If
	
	'write table
	Response.Write "<table width=700 cellspacing=0 cellpadding=0 border=0>"
	Response.Write "<tr>"
		Response.Write "<td width=150><b>" &  "Burn-In Time"    & "</b></td>"
		Response.Write "<td width=150><b>" &  "G3   "     & "</b></td>"
		Response.Write "<td width=150><b>" &  rsG3BurnIN("SerialNumber")    & "</b></td>"
		Response.Write "<td width=150><b>" &  rsG3BurnIN("UnitType")    & "</b></td>"
		Response.Write "<td width=85><b>" &  rsG3BurnIN("Minimum")   & "</b></td>"
		Response.Write "<td width=85><b>" &  rsG3BurnIN("Actual") & "</b></td>"
		Response.Write "<td width=85><b>" &  rsG3BurnIN("Maximum")   & "</b></td>"
			If rsG3BurnIN("Results") = True then
				Response.Write "<td width=85><b>" &  "Pass"   & "</b></td>"
			Else
				Response.Write "<td width=85><b>" &  "Fail"   & "</b></td>"
			End If
		Response.Write "<td width=100><b>" &  rsG3BurnIN("UUTFirstTestDate")   & "</b></td>"

	Response.Write "</table>"
	
	'move to next record
	rsG3BurnIN.MoveNext
Loop
   
response.end

'close YPO database
cnYPO.Close
Set cnYPO = Nothing

'close Empower database
conn.Close
Set conn = Nothing

'----------------------------------------------------------------------------------------------------
Function ErrorOccurred(Error)


	If Err.Number <> 0 then

		Response.Write strStatements & "<br>"
		Response.Write "ERROR OCCURRED<br>"
		Response.Write "ERROR NUMBER = " & Err.Number & "<br>"
		Response.Write "ERROR DESCRIPTION = " & Err.Description & "<br>"


		If Instr(UCase(strStatements), "RDUPSDDB02") > 0 Then
			Response.Write "This is an issue with the database server at the Forum.<br>"
			Response.Write "PLEASE NOTIFY IT.<br>"

		End If

		ErrorOccurred = True
		Exit Function

	End If


	ErrorOccurred = False

End Function




'----------------------------------------------------------------------------------------------------
Sub GetResultsData(rs, lResultsID, sProcedureName)

	Dim cmd


	Set cmd = Server.CreateObject("ADODB.Command")

	cmd.ActiveConnection = Conn

	cmd.CommandText = sProcedureName
	cmd.CommandType = adCmdStoredProc

    cmd.CommandTimeout = 90

	cmd.Parameters.Append cmd.CreateParameter ("[ResultID]",adInteger,adParamInput)
	cmd.Parameters("[ResultID]") = lResultsID

	Set rs = cmd.Execute



	set cmd = nothing

End Sub



'----------------------------------------------------------------------------------------------------
Function GetStringResults(ByRef sMin, ByRef sActual, ByRef sMax)

	Const FMT_VALUE  = "0.0000"
	Dim sFormat
	Dim sUnits

	GetStringResults = True   ' Indicate that there is a result.


	' Scan the results tuples for Actual, ActualStr, and Label to determine the call type.
	With rsTestResults

		' Got a numeric result.
		If Not IsNull(.Fields("Actual")) Then

			sUnits = .Fields("Units")

			If InStr(sUnits, "%") Then
				sFormat = "0.00"
			Else
				sFormat = FMT_VALUE
			End If

			sMin    = .Fields("Minimum")
			sMax    = .Fields("Maximum")
			sActual = .Fields("Actual" )


'			sMin    = Format$(.Fields("Minimum"), sFormat)
'			sMax    = Format$(.Fields("Maximum"), sFormat)
'			sActual = Format$(.Fields("Actual" ), sFormat)

			' Append any units descriptor.
			If Len(sUnits) Then
				sMin = sMin & " " & sUnits
				sMax = sMax & " " & sUnits
				sActual = sActual & " " & sUnits
			End If

		' String result.
		ElseIf Not IsNull(.Fields("ActualStr")) Then

			sMin    = rsTestResults("MinimumStr")
			sMax    = rsTestResults("MaximumStr")
			sActual = rsTestResults("ActualStr")


		' Some people put stuff here!
		ElseIf Not IsNull(.Fields("MinimumStr")) Then

			sMin = rsTestResults("MinimumStr")
			sMax = rsTestResults("MaximumStr")

		' Some people put stuff here!
		ElseIf Not IsNull(.Fields("MaximumStr")) Then

			sMax = rsTestResults("MaximumStr")


		'Simple pass/fail.
		ElseIf Not IsNull(.Fields("Result")) Then

			sMin = ""
			sMax = ""
			sActual = ""

		' Message of some kind.  Return no result.
		Else

			sMin = ""
			sMax = ""
			sActual = ""
			GetStringResults = False

		End If

	End With


End Function


'----------------------------------------------------------------------------------------------------
Sub PrintStepInfo (UnitSerialNumber, UnitPartNumber, UnitFamily, UnitStartTime)


    Const ALL_RESULT = 0
    Const PASS_RESULT = 1
    Const FAIL_RESULT = 2
    Const ABORTED_RESULT = 3
    Const UNTESTED_RESULT = 4


	Dim bLine
	Dim lStep
	Dim lID
	Dim sMeasure
	Dim sLastLabel
    Dim dElapsed
    Dim lColor
	Dim sResult
	Dim sMin
	Dim sActual
	Dim sMax
	Dim tsLabel


	'Response.Write "<table width=750 cellspacing=0 cellpadding=2 border=0>"
	Response.Write "<table width=700 cellspacing=0 cellpadding=2 border=0>"

	With rsTestResults

		.MoveFirst

		Do Until .EOF
		
		tsLabel = Trim(.Fields("TestLabel"))
		
		If tsLabel = "Burn-In Time" Then

		bLine = False      ' Default is to print a line.

		' Print a test label line whenever the test step changes or
		' when the test that is run changes.  The last criteria occurs
		' when in debug mode and all results are processed.


			If lStep <> .Fields("StepNumber") Or (lStep = .Fields("StepNumber") And lID <> .Fields("IDNumber") ) Then

			'	If g_stScreen.TRTime Then
			'		If lStep Then ' If this is not the first entry...
			'			PrtText "Test Routine Elapsed Time: " & Format$(dElapsed, "0.000") & vbCrLf
			'		End If
			'	End If


			'	lStep = .Fields("StepNumber")
			'	lID = .Fields("IDNumber")

			'	Response.Write "<td>&nbsp;</td>"

			'	Response.Write "<tr>"
			'		Response.Write "<td><b>" &  lStep & "</b></td>"
			'		Response.Write "<td><b>" &  .Fields("IDNumber") & "</b></td>"
			'		Response.Write "<td><b>" &  .Fields("TestLabel") & "</b></td>"

			'		Response.Write "<td>&nbsp;</td>"
			'		Response.Write "<td>&nbsp;</td>"
			'		Response.Write "<td>&nbsp;</td>"
			'		Response.Write "<td>&nbsp;</td>"

			'	Response.Write "</tr>"

			End If

			If IsNull(.Fields("Sequence")) Then
				sMeasure = ""
				sLastLabel = sMeasure
				dElapsed = 0

			ElseIf .Fields("ResultType") = UNTESTED_RESULT  Then
				' Don't log untested stuff.
				sMeasure = ""
				sLastLabel = sMeasure

			Else
				sMeasure = .Fields("rdLabel")
				sResult = .Fields("Result")

				If .Fields("ResultType") = FAIL_RESULT Then
					lColor = vbRed
				Else
					lColor = vbBlack
				End If


				' Get the results values.
				bLine = GetStringResults(sMin, sActual, sMax)



				If bLine Then

	Response.Write "<tr>"



				'Response.Write "<td>&nbsp;</td><td>&nbsp;</td><td valign='top'>" & sMeasure & "</td>"
				
					Response.Write "<td width=150><b>" &  tsLabel    & "</b></td>"
					Response.Write "<td width=150><b>" &  UnitFamily    & "</b></td>"
					Response.Write "<td width=150><b>" &  UnitSerialNumber    & "</b></td>"
					Response.Write "<td width=150><b>" &  UnitPartNumber    & "</b></td>"
					Response.Write "<td width=85><b>" &  sMin    & "</b></td>"
					Response.Write "<td width=85><b>" &  sActual & "</b></td>"
					Response.Write "<td width=85><b>" &  sMax    & "</b></td>"
					

					If lColor = vbRed then
						Response.Write "<td width=85><font color='#FF0000'><b>" &  sResult & "</b></td>"
					Else
						Response.Write "<td width=85><b>" &  sResult & "</b></td>"
					End If
					Response.Write "<td width=100><b>" &  UnitStartTime    & "</b></td>"

	Response.Write "</tr>"

				End If

			End If

		End IF	
			
      .MoveNext

    Loop


  End With

	Response.Write "</table>"


End Sub

'----------------------------------------------------------------------------------------------------
Sub PrintHeaderInfo()

	Dim nIndex
	Dim sName
	Dim sItem
	Dim sInfo
	Dim sCaption
	Dim sResult
	Dim lErrors

	'Get test status info
	sResult = rsTestRunData("TestResult")
	lErrors = rsTestRunData("TotalErrors")


	Response.Write "<table cellspacing=0 cellpadding=2>"


	'Determine the caption text.
	If IsNull(sResult) Then
		sCaption = "TEST NOT COMPLETE OR LOGGING UNFINISHED."
	ElseIf sResult = "Pass" Then
		sCaption =  "TEST PASSED"
	ElseIf sResult = "Fail" Then
		sCaption =  "TEST FAILED.  Errors: " & lErrors
	ElseIf sResult = "Aborted" Then
		sCaption =  "TEST ABORTED.  Errors: " & lErrors
	Else
		sCaption =  "TEST COMPLETED.  Errors: " & rlErrors
	End If


	'Response.Write "<caption><b>" & sCaption & "</b><br>&nbsp;</caption>"

	Response.Write "<tr>"
		Response.Write "<td><b>" & sCaption & "</b><br>&nbsp</td>"
	Response.Write "</tr>"


	Response.Write "<tr>"
		Response.Write "<td><b>Program Name:&nbsp;&nbsp;&nbsp;</b></td>"
		Response.Write "<td>" & rsProgram("ProgramName") & "</td>"
	Response.Write "</tr>"






	Response.Write "<tr>"
		Response.Write "<td><b>Version:</b></td>"
		Response.Write "<td>" & rsProgram("ProgramVersion") & "</td>"
	Response.Write "</tr>"


	Response.Write "<tr>"
		Response.Write "<td><b>Report Ran On:</b></td>"
		Response.Write "<td>" & Now & "</td>"
	Response.Write "</tr>"


	Response.Write "<tr>"
		Response.Write "<td><b>Date Test Ran:</b></td>"
		Response.Write "<td>" & rsTestRunData("StartTime") & "</td>"
	Response.Write "</tr>"


'might need more stuff in here


	'Show the ItemInfo fields.
	For nIndex = 1 To 10

		sName = "Info" & nIndex
		sItem = sName & "Item"
		sName = sName & "Name"

		If Not IsNull(rsProgram(sName)) Then

			Response.Write "<tr>"
			Response.Write "<td><b>" & rsProgram(sName) & ":&nbsp;&nbsp;&nbsp;&nbsp;</b></td>"


			If rsTestRunData(sItem & "ID") Then
				sInfo = rsTestRunData(sItem & "ID")
			Else
				sInfo = rsTestRunData(sItem)
			End If


			Response.Write "<td>" & sInfo & "</td>"

			Response.Write "</tr>"


		End If

	Next

	Response.Write "</table>"

	Response.Write "<br><br>"

End Sub

'---------------------------------------------------------------------------------------------------

Sub PrintStepHeaderInfo

	'Response.Write "<table width=750 cellspacing=0 cellpadding=2 border=0>"
	Response.Write "<table width=700 cellspacing=0 cellpadding=2 border=0>"

	Response.Write "<tr>"
		Response.Write "<td width=150><b>Step Name</b></td>"
		Response.Write "<td width=150><b>Family</b></td>"
		Response.Write "<td width=150><b>Serial Number</b></td>"
		Response.Write "<td width=150><b>Part Number</b></td>"
		Response.Write "<td width=85><b>Minimum</b></td>"
		Response.Write "<td width=85><b>Actual</b></td>"
		Response.Write "<td width=85><b>Maximum</b></td>"
		Response.Write "<td width=85><b>Result</b></td>"
		Response.Write "<td width=100><b>StartTime</b></td>"
	Response.Write "</tr>"

	Response.Write "</table>"


End Sub



'----------------------------------------------------------------------------------------------------

%>
</body>
</html>
