<%Option Explicit%>
<html>

<head>
<meta name="GENERATOR" content="Microsoft FrontPage 3.0">
<title>A Query</title>

<meta name="Microsoft Theme" content="indust 101"></head>

<body background="../_themes/indust/indtextb.jpg" bgcolor="#FFFFFF" text="#000000" link="#3366CC" vlink="#666666" alink="#FF3300"><!--mstheme--><font face="trebuchet ms, arial, helvetica">

<h2 align="center"><!--mstheme--><font color="#CC6666">CPR Repair<!--mstheme--></font></h2>

<!--msthemeseparator--><p align="center"><img src="../_themes/indust/indhorsd.gif" width="300" height="10"></p>
<%
'------------------------------------------------------------------------------------------------------------
	Response.Write "<center>"


	If Request("frmSerialNumber") <> "" Then Session("SerialNumber") = UCase(Request("frmSerialNumber"))
	If Request("frmBadgeNumber") <> "" Then Session("BadgeNumber") = UCase(Request("frmBadgeNumber"))


	'Ask for user identification.
	If Session("SerialNumber") = "" Then

		Call GetSerialNumber()
		
	ElseIf Request("frmID") = "" Then

		If ValidateSerialNumber = False Then
			Session("SerialNumber") = ""
		End If

	Else
		Response.Write "Submitting data.<br>"
		Session("SerialNumber") = ""

	End If



'------------------------------------------------------------------------------------------------------------

Sub GetSerialNumber()


	Response.Write "<form method='POST' action='UpdateRepairLog.Asp'>"

	Response.Write "Enter serial number:<br>"
  	Response.Write "<input type='text' name='frmSerialNumber' value='GR245A0050' size='20'>"
	Response.Write "<br>"

  	Response.Write "<input type='submit' value='Submit' name='B1'>"
	Response.Write "<input type='reset' value='Reset'  name='B2'>"


	Response.Write "</form>"

End Sub



'------------------------------------------------------------------------------------------------------------

Function ValidateSerialNumber()

	Dim RS
	Dim Query
	Dim Conn

	ValidateSerialNumber = False

	'Create the desired query.
	Query = "SELECT " & _
					"I.SerialNumber, " & _
					"I.PartNumber, " & _
					"I.StartTime, " & _
					"I.ID, " & _
					"I.Seq, " & _
					"F.TestFailed, " & _
					"F.FailureDescription, " & _
					"F.DefectCategory, " & _
					"F.Remarks " & _

			 "FROM " & _
					"Index AS I, " & _
					"FailureInformation AS F " & _

			 "WHERE " & _
					"I.SerialNumber = '" & Session("SerialNumber") & "' AND " & _
					"I.Results = 0 AND " & _
					"I.ID = F.ID"



	'Show the query for debug purposes.
	'Response.Write Query & "<p><br>"

	Set Conn = Server.CreateObject("ADODB.Connection")

	'Open the database defined in the Global.asa file.
	Conn.Open Application("ProductionDatabase")

	Set RS = Conn.Execute(Query)

	' Check for error.
	If Err.Description <> "" Then
		Response.Write "<B>Error " + Hex(Err) + ": " + Err.Description + "</B><br>"

	' Check for no-record case.
	ElseIf RS.EOF And RS.BOF Then 

		Response.Write "There are not any failure records for serial number: " & Session("SerialNumber") & "<br>"
		Session("SerialNumber") = ""
		Call GetSerialNumber()

	' Valid data was received from the query.
	Else
		'TempDisplay(RS)
		ShowFailureInformation(RS)
	
		ValidateSerialNumber = True

	End If


	'Close the open objects.
	If IsObject(RS) Then
		RS.Close
		Set RS = Nothing
		Conn.Close
		Set Conn = Nothing
	End If


End Function


'------------------------------------------------------------------------------------------------------------
Sub TempDisplay(RS)

	Dim Ctr


	Response.Write "<table BORDER = '3.0' cellspacing='0' cellpadding='0'>"

		'Create the table header row.
  		Response.Write "<tr>"
			For Ctr = 0 To RS.Fields.Count - 1
				Response.Write "<th>" & RS.Fields(Ctr).Name & "</th>"
			Next
		Response.Write "</tr>"

		'Fill in the cells with data.
		Do While Not RS.EOF
			Response.Write "<tr>"
				For Ctr = 0 To RS.Fields.Count - 1
	      			Response.Write "<td>" & RS.Fields(Ctr) & "</td>"
				Next
				Response.Write "</tr>"
		
			RS.MoveNext
		Loop
	
	Response.Write "</table>"

End Sub




'------------------------------------------------------------------------------------------------------------
Sub ShowFailureInformation(RS)

	Dim RowCtr
	Dim intRowSpanCnt	
	Dim Ctr
	Dim strRSData
	Dim strRSName

	Response.Write "Repair record for " & Session("SerialNumber") & "<br><br>"


	Response.Write "<br><br><br>"
	Response.Write "Please describe the symptoms of the problem.<br>"
	Response.Write "<textarea rows='5' name='frmSympotms' cols='70'></textarea>"
	Response.Write "<br><br><br>"


	'------------------------------------------------------------------
	Response.Write "Choose a subassembly.<br>"
	Response.Write "<table border='3' cellspacing='0' cellpadding='1'>"

		Response.Write "<tr>"
			Response.Write "<th>.</th>"
			Response.Write "<th>Description</th>"
			Response.Write "<th>Part Number</th>"
		Response.Write "</tr>"

		Response.Write "<tr>"
			Response.Write "<td><input type='radio' name='frmFailure' value='05145831-3069'></td>"
			Response.Write "<td>Main circuit board</td>"
			Response.Write "<td>05145831-3069</td>"
		Response.Write "</tr>"

		Response.Write "<tr>"
			Response.Write "<td><input type='radio' name='frmFailure' value='149502040-001'></td>"
			Response.Write "<td>Ferro</td>"
			Response.Write "<td>149502040-001</td>"
		Response.Write "</tr>"

		Response.Write "<tr>"
			Response.Write "<td><input type='radio' name='frmFailure' value='one'></td>"
			Response.Write "<td>Auxillary Transformer</td>"
			Response.Write "<td>?</td>"
		Response.Write "</tr>"

		Response.Write "<tr>"
			Response.Write "<td><input type='radio' name='frmFailure' value='two'></td>"
			Response.Write "<td>Status Monitor Board</td>"
			Response.Write "<td>?</td>"
		Response.Write "</tr>"


	Response.Write "</table>"
	'------------------------------------------------------------------

	Response.Write "<br><br><br>"
	Response.Write "What was done to fix the problem?<br>"
	Response.Write "<textarea rows='5' name='frmComments' cols='70'></textarea>"
	Response.Write "<br><br><br>"


	Response.Write "<form method='POST' action='UpdateRepairLog.Asp'>"

	
	'------------------------------------------------------------------
	Response.Write "The repair record must be associated with one of the following failure records.<br>"
	Response.Write "<table border='3' cellspacing='0' cellpadding='1'>"

	'Fill in the cells with data.
	Do While Not RS.EOF
			
		RowCtr = RowCtr + 1

		intRowSpanCnt = RS.Fields.Count	

		For Ctr = 0 To intRowSpanCnt - 1

			strRSData = RS.Fields(Ctr)
			strRSName = RS.Fields(Ctr).Name

			Response.Write "<tr>"
	      			
			If strRSName = "SerialNumber" Then
	 	   		Response.Write "<td rowspan='" & intRowSpanCnt & "'> " & _
					"<input type='radio' name='frmID' value='" & RS.Fields("ID") & "'></td>"

			ElseIf strRSName = "ID" Then
				Response.Write "<td>" & strRSName & "</td><td>" & strRSData & "</td>"

			ElseIf strRSName = "StartTime" Then
				Response.Write "<td>StartTime</td><td>" & FormatDateTime(strRSData) & "</td>"

			Else
   				Response.Write "<td>" & strRSName & "</td><td>" & strRSData & "</td>"
			End if

			Response.Write "</tr>"
		Next
			
		RS.MoveNext
	Loop
	Response.Write "</table>"
	'------------------------------------------------------------------

	Response.Write "<br>"

	'Submit and reset buttons.
  	Response.Write "<input type='submit' value='Submit' ONCLICK='return IdSelected(this.form);' name='B1'>"
	Response.Write "<input type='reset' value='Reset'  name='B2'>"


		


	Response.Write "</form>"


End Sub

%>
<!--mstheme--></font></body>
</html>
<script language="JavaScript"><!--

// ----------------------------------------------------------------------------------------------------------
function IdSelected(form)
{
	// See if a record has been selected.
	for (var i = 0; i < form.frmID.length; i++)
	{
		if (form.frmID[i].checked) return true;
	}
	
	// Tell user that a record must be selected.
	alert("You must choose a failure record.");
	return false;

}


// --></script>
