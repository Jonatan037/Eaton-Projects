<%Option Explicit%>
<%Response.Buffer = TRUE%>
<% Response.Clear %>
<html>

<head>
<title>MSA Data</title>
</head>

<body>

<!-- #include File=..\\..\Tools\GenericTable.Inc -->
<!-- #include File=..\\..\Tools\adovbs.inc -->


<%

Dim cnYPO			'Database connection for the YPO database.
Dim Conn			'Connection for the rpo_proddata server.

Dim Sql				'The query to be executed.
Dim QueryStartDate
Dim QueryEndDate
Dim lResultsID

Dim rsIndex
Dim rsProgram
Dim rsTestRunData
Dim rsTestResults


'Get the date from the calling form.
QueryStartDate = CDate(Request("StartMonth") & "/" & Request("StartDay") & "/" & Request("StartYear") )
QueryEndDate   = CDate(Request("EndMonth")   & "/" & Request("EndDay")   & "/" & Request("EndYear") ) + 1


'This is the date on which the MSA data collection was started.
If QueryStartDate < CDate("10/14/2009") Then QueryStartDate = CDate("10/14/2009")
If QueryEndDate < QueryStartDate Then QueryEndDate = QueryStartDate + 1

'Put the dates in the proper format for the query.
QueryStartDate = "#" & QueryStartDate & "#"
QueryEndDate   = "#" & QueryEndDate & "#"




Set cnYPO = Server.CreateObject("ADODB.Connection")
'cnYPO.ConnectionTimeout = 90
cnYPO.Open "ypo"


Set Conn = Server.CreateObject("ADODB.Connection")
Conn.Open "Provider=SQLOLEDB;Data Source=rdupsddb02;Database=rpo_proddata;Trusted_Connection=Yes;"



Sql = "SELECT I.DBID, I.PartNumber, I.SerialNumber, I.StartTime, I.ComputerName, I.ResultsID, P.Family " & _
      "FROM qdms_master_index AS I INNER JOIN qdms_part_numbers AS P ON I.PartNumber = P.PartNumber " & _
      "WHERE " & _
         "I.RecordType = 2 AND " & _
         "P.Family IN ('9x55','9355') AND " & _
         "StartTime BETWEEN " & QueryStartDate & " AND " & QueryEndDate

Set rsIndex = cnYPO.Execute(Sql)


Response.Clear
Response.ContentType = "Application/vnd.ms-excel"

Response.Write "Part Number" & chr(9)
Response.Write "Serial Number" & chr(9)
Response.Write "Start Time" & chr(9)
Response.Write "Computer Name" & chr(9)
Response.Write "Family" & chr(9)

Response.Write "Test Name" & chr(9)
Response.Write "Minimum" & chr(9)
Response.Write "Actual" & chr(9)
Response.Write "Maximum" & chr(9)
Response.Write "Result" & chr(9)

Response.Write vbCrLf

Do While Not rsIndex.EOF
	lResultsID = rsIndex("ResultsID")
	GetResultsData rsTestResults, lResultsID, "spTestResults"
	PrintStepInfo
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
Sub PrintStepInfo

	Dim tsLabel		'The overall name of the test step. Looking for "Collect MSA Data".
	Dim rdLabel		'The name of the actual parameter.


	With rsTestResults

		.MoveFirst

		Do Until .EOF

			tsLabel = Trim(.Fields("TestLabel"))

			If tsLabel = "Collect MSA Data" Then

				rdLabel = .Fields("rdLabel")


				Response.Write rsIndex("PartNumber") & chr(9)
				Response.Write rsIndex("SerialNumber") & chr(9)
				Response.Write rsIndex("StartTime") & chr(9)
				Response.Write rsIndex("ComputerName") & chr(9)
				Response.Write rsIndex("Family") & chr(9)


				Response.Write  tsLabel & " - " & rdLabel & chr(9)
				Response.Write .Fields("Minimum") & chr(9)
				Response.Write .Fields("Actual") & chr(9)
				Response.Write .Fields("Maximum") & chr(9)
				Response.Write .Fields("Result") & chr(9)

				Response.Write vbCrLf


			End If

      .MoveNext

    Loop


  End With


End Sub



'----------------------------------------------------------------------------------------------------

%>

