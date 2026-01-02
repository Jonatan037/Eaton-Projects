<%Option Explicit%>
<%Response.Buffer = TRUE%>
<% Response.Clear %>
<html>

<head>
<title>Production Test Report</title>


</head>

<body>


<%

On Error Resume Next

Dim Conn				'Database connection.
DIM rs

Dim IndexID
Dim RecordType
Dim DataLogPath
Dim Sql


'Get the index number that was passed to this form.
indexID = Request("ID")



Set Conn = Server.CreateObject("ADODB.Connection")
Conn.Open Application("QDMS")

'Get the RecordType value from the master index.
Sql = "SELECT RecordType, ProgramName FROM qdms_master_index WHERE INDEXID = " & IndexId
Set rs = Conn.Execute(Sql)


if err.number <> 0 then 
   response.write sql & "<br><br>" & err.description & "<br>"
   response.end
end if


'Save the RecordType value that was retreived from the master index.
RecordType = rs("RecordType")
DataLogPath = rs("ProgramName")

rs.close
set rs = nothing

conn.close
set conn = nothing



'Determine which report page is to be called for this test record.
Select Case RecordType

	'EMPOWER
	Case 2,3,4,5,6,7,8,9,10,11

		Response.Redirect "get_report_002_empower.asp?ID=" & IndexID

	'ePDU
	Case 12
		Response.Redirect "get_report_004_epdu.asp?ID=" & IndexID

	'FERRUPS
	Case 15
		Response.Redirect "get_report_003_ferrups.asp?ID=" & IndexID

	'NCR Test Complete record
	Case 18
		Response.Redirect "get_report_006_ncr_test_complete.asp?ID=" & IndexID


	'Battery Line
	Case 19
		Response.Redirect "get_report_005_ncr_defect_report.asp?ID=" & IndexID


	'NCR Defect Report
	Case 20
		Response.Redirect "get_report_007_battery_line.asp?ID=" & IndexID


	'Panda
	Case 21
		Response.Redirect "..\Panda\get_panda_report_001.asp?ID=" & IndexID

	Case 22

		Response.Redirect "get_report_008_epdu_via_ate.asp?ID=" & IndexID

	'Raleigh TDM
	'Case 23,24,25,26,27,28,29
	Case 100,101,102,103,104,105,106,107,108,109,110,111
		Response.Redirect "get_report_014_tdm.asp?ID=" & IndexID
		'Response.Redirect "http://ra1ncstdm02/TDM/AdHocReport/ViewAdHocReport.aspx"

	'Shark
	Case 30,50
		Response.Redirect "get_report_009_shark.asp?ID=" & IndexID


	'CPO Battery Line
	Case 31,32,33,34,35,36,37,38,39,40
		Response.Redirect "get_report_010_cpo_battery_line.asp?ID=" & IndexID

	'Link to a data log on the file server.
	Case 41
		Response.Write "<a href='" & DataLogPath & "'>" & DataLogPath & "</a>"

	'Yogi
	Case 42
		Response.Redirect "get_report_012_yogi.asp?ID=" & IndexID
		
	'Eagle
	Case 51,52
		Response.Redirect "get_report_013_eagle.asp?ID=" & IndexID

	Case Else
		Response.Write "No test report is associated with RecordType = " & RecordType

End Select

%>
</body>
</html>
