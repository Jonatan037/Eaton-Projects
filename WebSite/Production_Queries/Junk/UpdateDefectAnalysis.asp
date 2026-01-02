<%Option Explicit%>
<html>

<head>
<meta name="GENERATOR" content="Microsoft FrontPage 3.0">
<title>A Query</title>

<meta name="Microsoft Theme" content="indust 101"></head>

<body background="../_themes/indust/indtextb.jpg" bgcolor="#FFFFFF" text="#000000" link="#3366CC" vlink="#666666" alink="#FF3300"><!--mstheme--><font face="trebuchet ms, arial, helvetica">

<h2 align="center"><!--mstheme--><font color="#CC6666">Defect Analysis Entry Form<!--mstheme--></font></h2>
<%
	'Set timeout to 20 minutes.
	Session.Timeout = 20

	Dim strResponseIDs
	
	If Request("frmPassword") <> "" Then Session("Password") = Request("frmPassword")
	If Request("frmBadgeNumber") <> "" Then Session("BadgeNumber") = UCase(Request("frmBadgeNumber"))


	strResponseIDs = Request("frmIDs")

	'Save time information.
	If Request("StartYear") <> "" Then

		'Create time stamp for use in query.
		Session("QueryStartDate") = "{ts '" &	Request("StartYear") & "-" 	& Request("StartMonth") & "-" &	Request("StartDay") & " 00:00:00'}"
		Session("QueryEndDate")   = "{ts '" & 	Request("EndYear")   & "-" & Request("EndMonth")    & "-" & 	Request("EndDay")   & " 23:59:59'}"

		'Format the time for display.
		Session("DisplayStart") = Request("StartMonth") & "/" & Request("StartDay") & "/" & Request("StartYear")
		Session("DisplayEnd")   = Request("EndMonth")   & "/" & Request("EndDay")   & "/" & Request("EndYear")

	End If



	'Ask for user identification.
	If (strResponseIDs = "" ) And (Session("Password") = "") Or (Session("BadgeNumber") = "") Then

		Call ShowUnanalyzedRecords()
		Call GetUserIdentification()

	'Send the updated fields to the database.
	ElseIf strResponseIDs <> "" Then

		Call SubmitDefectInformation()
		Session("BadgeNumber") = ""
		Session("Password") = ""

	'Show defect entry form.
	Else 

		If VerifyUserID Then	
			Call DisplayDefectInformation()
		Else
			Call GetUserIdentification()
		End If

	End If

%>
<%
Sub DisplayDefectInformation()

	Dim Conn
	Dim RS
	Dim rsDefectCategory

	Dim Query	
	Dim DefectCategoryQuery

	Dim QueryStartDate
	Dim QueryEndDate
	Dim DisplayStart
	Dim DisplayEnd
	Dim Ctr
	Dim RowCtr

	Dim strIDs
	Dim strRSName
	Dim strRSData

	Dim intRowSpanCnt

	On Error Resume Next


	'Show query date.
	if Session("DisplayStart") = Session("DisplayEnd") then
		Response.Write "<center>" & Session("DisplayStart") & "</center><P>"
	else
		Response.Write "<center>" & Session("DisplayStart") & "&nbsp;&nbsp;&nbsp;" & "   To   " & "&nbsp;&nbsp;&nbsp;" & Session("DisplayEnd") & "</center><P>"
	end if


	'--------------------------------------------------------------------------------------------------------
	Set Conn = Server.CreateObject("ADODB.Connection")

	'Open the database defined in the Global.asa file.
	Conn.Open Application("ProductionDatabase")


	'--------------------------------------------------------------------------------------------------------

	'Get a list of the allowable defect categories.
	DefectCategoryQuery = "SELECT DISTINCT DefectCategory FROM FailureInformation ORDER BY DefectCategory"

	'Show the query for debug purposes.
	'Response.Write DefectCategoryQuery & "<p><br>"

	Set rsDefectCategory = Conn.Execute(DefectCategoryQuery)

	'-------------------------------------------
	'Regular users.

	If Session("OverrideSecurity") = False Then

		'Create the desired query.
		Query = "SELECT " & _
					"I.SerialNumber, " &_ 
					"I.StartTime, " &_ 
					"I.PartNumber, " & _
					"I.Seq, " & _
					"I.Workcell, " & _
					"I.Badge, " &_
					"F.ID, " &_ 
					"F.TestFailed, " &_ 
					"F.FailureDescription, " &_ 
					"F.DefectCategory, " &_ 
					"F.SubCat1, " &_ 
					"F.Remarks " & _
			
				"FROM " & _
					"FailureInformation AS F, " & _
					"Index AS I " & _
			
				"WHERE " & _
					"(I.ID = F.ID) AND " &_ 
					"(StartTime BETWEEN " & Session("QueryStartDate") & " AND " & Session("QueryEndDate") & ") AND " & _
					"I.Badge = '" & Session("BadgeNumber") & "' AND " & _
					"F.DefectCategory = 'Not Analyzed' " & _
			
				"ORDER BY " & _
					"I.SerialNumber, " & _
					"I.StartTime"


	'-------------------------------------------
	'Administrators.
	Else
		
		Query = "SELECT " & _
					"I.SerialNumber, " &_ 
					"I.StartTime, " &_ 
					"I.PartNumber, " & _
					"I.Seq, " & _
					"I.Workcell, " & _
					"I.Badge, " &_
					"F.ID, " &_ 
					"F.TestFailed, " &_ 
					"F.FailureDescription, " &_ 
					"F.DefectCategory, " &_ 
					"F.SubCat1, " &_ 
					"F.Remarks " & _
			
				"FROM " & _
					"FailureInformation AS F, " & _
					"Index AS I " & _
			
				"WHERE " & _
					"(I.ID = F.ID) AND " &_ 
					"(StartTime BETWEEN " & Session("QueryStartDate") & " AND " & Session("QueryEndDate") & ") " & _
			
				"ORDER BY " & _
					"I.SerialNumber, " & _
					"I.StartTime"

	End If
	'-------------------------------------------


	'Show the query for debug purposes.
	'Response.Write Query & "<p><br>"

	Set RS = Conn.Execute(Query)

	' Check for error.
	If Err.Description <> "" Then
		Response.Write "<B>Error " + Hex(Err) + ": " + Err.Description + "</B><br>"

	' Check for no-record case.
	ElseIf RS.EOF And RS.BOF Then 
		Response.Write "No records were found. <br>"

	'--------------------------------------------------------------------------------------------------------
	' Valid data was received from the query.
	Else
		Response.Write "<div align='center'><center>"
		Response.Write "<form method='POST' action='UpdateDefectAnalysis.Asp'>"
		Response.Write "<table BORDER = '3.0' cellspacing='0'>"

		'Fill in the cells with data.
		Do While Not RS.EOF
			
			RowCtr = RowCtr + 1

			intRowSpanCnt = RS.Fields.Count	

			For Ctr = 0 To intRowSpanCnt - 1

				strRSData = RS.Fields(Ctr)
				strRSName = RS.Fields(Ctr).Name

				Response.Write "<tr>"
	      			
				If strRSName = "SerialNumber" Then
	 	   			Response.Write "<td rowspan='" & intRowSpanCnt & "'> " & strRSData & "</td>"

				ElseIf strRSName = "ID" Then
					strIDs = strIDs & strRSData & "," 
					Response.Write "<td>" & strRSName & "</td><td>" & strRSData & "</td>"

				ElseIf strRSName = "StartTime" Then
					Response.Write "<td>StartTime</td><td>" & FormatDateTime(strRSData) & "</td>"

				ElseIf strRSName = "DefectCategory" Then
					Response.Write CreateDefectList(RowCtr, strRSData, rsDefectCategory)

				ElseIf strRSName = "SubCat1" Then
					Response.Write CreateSubCat1_List(RowCtr, strRSData, rsDefectCategory)

				ElseIf strRSName = "Remarks" Then
					Response.Write	"<td>Remarks</td>" &_
										"<td>" &_
											"<input type='text' " &_
												"name='R" & RowCtr & "' " &_
												"size = '60' " &_
												"value = '" & strRSData & "'" &_
											 ">" &_
										"</td>"
				Else
 	   				Response.Write "<td>" & strRSName & "</td><td>" & strRSData & "</td>"
				End if

				Response.Write "</tr>"
			Next
			
			RS.MoveNext
		Loop


		Response.Write "</table>"

		'Save the ID numbers in a hidden form field so that can be passed to the next ASP.
		Response.Write "<input type='hidden' name='frmIDs' value = '" & strIDs & "'><br>"

		Response.Write "<input type='submit' value='Submit' name='B1'>"

		Response.Write "</form>"
	
		Response.Write "</center>"	

	End If
	'--------------------------------------------------------------------------------------------------------

	rsDefectCategory.Close
	Set rsDefectCategory = Nothing

	RS.Close
	Set RS = Nothing

	Conn.Close
	Set Conn = Nothing

	
End Sub
%>
<%
'--------------------------------------------------------------------------------------------------------
Function CreateDefectList(intPresentRow, strPresentDefectName, rsDefectCategory)

	Dim strRSName
	Dim strTemp


	'Default return value in case of error
	CreateDefectList = "<td>Defect Category</td><td>Error has occured in the Active Server Page code.</td>"

	strTemp  = ""
										
	'Get the first record in the list of defect categories.
	rsDefectCategory.MoveFirst

	'Get all of the items in the defect category list.
	Do While Not rsDefectCategory.EOF

		'Name of a defect category.
		strRSName = rsDefectCategory.Fields("DefectCategory")

		'Start of an entry in the drop-down menu.
		strTemp = strTemp & "<option "
		
		'Highlight this menu item if its name already appears in the database.
		If strPresentDefectName = strRSName Then
			strTemp = strTemp & "selected "
		End If
		
		'End of a drop-down menu item.
		strTemp = strTemp &	"value='" & strRSName & "'>" &	strRSName & "</option>"

		'Get the next defect category name.
		rsDefectCategory.MoveNext

	Loop

	'Put everything in a drop-down menu structure.
	CreateDefectList =	"<td>Defect Category</td>" & _
							"<td>" & _
								"<select name='D" & intPresentRow & "' size='1' maxlength='250'>" & _
								strTemp & _
								"</select>" & _
							"</td>"
End Function

'--------------------------------------------------------------------------------------------------------
Sub SubmitDefectInformation()

	Dim Conn

	Dim MyArray
	Dim Temp
	Dim intArrayCtr
	Dim strUpdateQuery

	Dim strRemarks
	Dim strDefects
	Dim strSubCat1

	intArrayCtr = 0

	Set Conn = Server.CreateObject("ADODB.Connection")

	'Open the database defined in the Global.asa file.
	Conn.Open Application("ProductionDatabase")

	MyArray = Split(strResponseIDs, ",")

	For Each Temp In MyArray
		intArrayCtr = intArrayCtr + 1

		strRemarks = Request("R" & intArrayCtr)
		strDefects = Request("D" & intArrayCtr)
		strSubCat1 = Request("S1_" & intArrayCtr)


		If strRemarks = "" Then strRemarks = "None."
		If strDefects = "" Then strDefects = "Not Analyzed"

		'Only submit subcategory info if the major defect category is "Component".
		If strDefects <> "Component" Then strSubCat1 = "None"

				
		strUpdateQuery = "UPDATE FailureInformation " &_
							"SET " &_
								"DefectCategory = '" & strDefects & "', " &_
								"SubCat1 = '" & strSubCat1 & "', " &_
								"Remarks = '" & strRemarks & "' " &_
							"WHERE ID = " & Temp

		
		If ( (Temp <> "") And (strDefects <> "Not Analyzed") ) Then 
			Response.Write strUpdateQuery & "<br>"
			Conn.Execute(strUpdateQuery)
		End If


		' Check for error.
		If Err.Description <> "" Then
			Response.Write "<B>Error " + Hex(Err) + ": " + Err.Description + "</B><br>"
		End If
		
	Next

	Conn.Close
	Set Conn = Nothing

End Sub



'--------------------------------------------------------------------------------------------------------
Sub GetUserIdentification()

	Response.Write "<center>"
		
	Response.Write "<form method='POST' action='UpdateDefectAnalysis.Asp'>"

		Response.Write "Badge Number<br><input type='text' name='frmBadgeNumber' size='20'><br><br>"

		Response.Write "Password<br><input type='password' name='frmPassword' size='20'><br><br>"

		Response.Write "<input type='submit' value='Submit' name='B1'>"

	Response.Write "</form>"
	
	Response.Write "</center>"

End Sub


'--------------------------------------------------------------------------------------------------------
Function VerifyUserID

	Dim Conn
	Dim RS
	Dim Query

	'Default return value.
	VerifyUserID = False

	'If this is a request by Robert, Nina or Kenny then override standard security.
	If (Session("BadgeNumber") = "1214" Or Session("BadgeNumber") = "2462" Or Session("BadgeNumber") = "1015") And Session("Password") = "123987" Then
		VerifyUserID = True
		Session("OverrideSecurity") = True
		Exit Function
	Else
		Session("OverrideSecurity") = False
	End If



	Query = "SELECT Password FROM BadgeNumbers WHERE BadgeNumber = '" & Session("BadgeNumber") & "'"

	Set Conn = Server.CreateObject("ADODB.Connection")
	Conn.Open Application("ProductionDatabase")

	Set RS = Conn.Execute(Query)

	' Check for error.
	If Err.Description <> "" Then
		Response.Write "<B>Error " + Hex(Err) + ": " + Err.Description + "</B><br>"

	' Check for no-record case.
	ElseIf RS.EOF And RS.BOF Then 
		Response.Write "<center>Unable to locate password for badge number " & Session("BadgeNumber") & ".</center><br><br>"

	'Verify valid password.
	Else
		If Session("Password") = RS.Fields(0) Then 
			VerifyUserID = True
		Else
			Response.Write "<center>Invalid password was entered for " & Session("BadgeNumber") & ".</center><br><br>"
		End If
	End IF


	RS.Close
	Set RS = Nothing	
	
	Conn.Close
	Set Conn = Nothing

End Function






'--------------------------------------------------------------------------------------------------------
Sub ShowUnanalyzedRecords()

	Dim Conn
	Dim RS
	Dim rsDefectCategory

	Dim Query	
	Dim DefectCategoryQuery

	Dim QueryStartDate
	Dim QueryEndDate
	Dim DisplayStart
	Dim DisplayEnd
	Dim Ctr
	Dim RowCtr

	Dim strIDs
	Dim strRSName
	Dim strRSData

	Dim intRowSpanCnt

	On Error Resume Next


	'Show query date.
	if Session("DisplayStart") = Session("DisplayEnd") then
		Response.Write "<center>" & Session("DisplayStart") & "</center><P>"
	else
		Response.Write "<center>" & Session("DisplayStart") & "&nbsp;&nbsp;&nbsp;" & "   To   " & "&nbsp;&nbsp;&nbsp;" & Session("DisplayEnd") & "</center><P>"
	end if


	'--------------------------------------------------------------------------------------------------------
	Set Conn = Server.CreateObject("ADODB.Connection")

	'Open the database defined in the Global.asa file.
	Conn.Open Application("ProductionDatabase")


	'--------------------------------------------------------------------------------------------------------

	'Get a list of the allowable defect categories.
	DefectCategoryQuery = "SELECT DISTINCT DefectCategory FROM FailureInformation ORDER BY DefectCategory"

	'Show the query for debug purposes.
	'Response.Write DefectCategoryQuery & "<p><br>"

	Set rsDefectCategory = Conn.Execute(DefectCategoryQuery)

	
	'Create the desired query.
	Query = "SELECT " & _
					"I.Badge, " &_
					"Count(I.Badge) AS Total " & _
			
				"FROM " & _
					"FailureInformation AS F, " & _
					"Index AS I " & _
			
				"WHERE " & _
					"(I.ID = F.ID) AND " &_ 
					"(StartTime BETWEEN " & Session("QueryStartDate") & " AND " & Session("QueryEndDate") & ") AND " & _
					"F.DefectCategory = 'Not Analyzed' " & _
			
				"GROUP BY I.Badge"


	'Show the query for debug purposes.
	'Response.Write Query & "<p><br>"

	Set RS = Conn.Execute(Query)

	' Check for error.
	If Err.Description <> "" Then
		Response.Write "<B>Error " + Hex(Err) + ": " + Err.Description + "</B><br>"

	' Check for no-record case.
	ElseIf RS.EOF And RS.BOF Then 
		Response.Write "No records were found for the specified time period. <br>"

	'--------------------------------------------------------------------------------------------------------
	' Valid data was received from the query.
	Else

	Response.Write "<div align='center'><center>"
	Response.Write "The following badge numbers have unanalyzed records associated with them.<br>"

	Response.Write "<table BORDER = '3.0'>"

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

	Response.Write "<br>"
	Response.Write "</center>"	

	End If
	'--------------------------------------------------------------------------------------------------------

	rsDefectCategory.Close
	Set rsDefectCategory = Nothing

	RS.Close
	Set RS = Nothing

	Conn.Close
	Set Conn = Nothing

	
End Sub


'--------------------------------------------------------------------------------------------------------
Function CreateSubCat1_List(intPresentRow, strPresentSubCatName, rsDefectCategory)

	Dim strRSName
	Dim strTemp

	'Default return value in case of error
	CreateSubCat1_List = "<td>Sub-Category #1</td><td>Error has occured in the Active Server Page code.</td>"

	strTemp  = ""


	CreateSubCat1_List =	"" & _
		"<td>Sub-Category #1</td>" & _
		"<td>" & _
			"<select name='S1_" & intPresentRow & "' size='1' maxlength='250'>" & _
				"<option>Unknown</option>" & _
				"<option>Power Board</option>" & _
				"<option>Logic Board</option>" & _
				"<option>Ribbon Cable</option>" & _
				"<option>Inductor</option>" & _
				"<option>Sheet Metal</option>" & _
				"<option>Ferro</option>" & _
				"<option>Inverter Module</option>" & _
				"<option>SSR</option>" & _
				"<option>SSR Board</option>" & _
				"<option>Other</option>" & _
			"</select>" & _
		"</td>"



	Exit Function


										
	'Get the first record in the list of defect categories.
	rsDefectCategory.MoveFirst

	'Get all of the items in the defect category list.
	Do While Not rsDefectCategory.EOF

		'Name of a defect category.
		strRSName = rsDefectCategory.Fields("DefectCategory")

		'Start of an entry in the drop-down menu.
		strTemp = strTemp & "<option "
		
		'Highlight this menu item if its name already appears in the database.
		If strPresentDefectName = strRSName Then
			strTemp = strTemp & "selected "
		End If
		
		'End of a drop-down menu item.
		strTemp = strTemp &	"value='" & strRSName & "'>" &	strRSName & "</option>"

		'Get the next defect category name.
		rsDefectCategory.MoveNext

	Loop

	'Put everything in a drop-down menu structure.
	CreateDefectList =	"<td>Defect Category</td>" & _
							"<td>" & _
								"<select name='D" & intPresentRow & "' size='1' maxlength='250'>" & _
								strTemp & _
								"</select>" & _
							"</td>"
End Function



%>
<!--mstheme--></font></body>
</html>
