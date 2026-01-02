<% Option Explicit %>
<% Response.Buffer = True %>
<%
'------------------------------------------------------------------------------------------------------------
' If frmID = 1 then the list of available units types is being displayed.
' If frmID = 2 then the list of field names is being displayed.
' If frmID = 3 then an error message is being displayed.
'------------------------------------------------------------------------------------------------------------
%>


<html>

<head>
<title>Performance Data Spreadsheet</title>
<% If Request("SelectionMode") = "FIELDS" Then %>
<script>
//-----------------------------------------------------------------------------------------------------------
function LoadLastSelections(form)
{
	var label = "PerformanceDataFields=";
	var labelLen = label.length;
	var cLen = document.cookie.length;
	var i = 0;
	var cEnd;
	var j;
	var cookie = "";

	// Stop here if the list of available fields is not being displayed.
	if (form.frmID.value != "2") return false;

	// Get the list of previous selections from the cookie.
	while (i < cLen)
	{
		j = i + labelLen;

		if (document.cookie.substring(i,j) == label)
		{
			cEnd = document.cookie.indexOf(";",j);
			if (cEnd == -1) cEnd = document.cookie.length;		
			cookie = unescape(document.cookie.substring(j, cEnd));
			break;
		}
		i++;
	}

	if (cookie.length == 0) return;

	// Parse the string.
	var listArray = cookie.split(",")

	var source = form.frmList.options;

	// Highlight all of the previous selected items.
	for (i = 0; i < listArray.length; i++)
		for(j = 0; j < source.options.length; j++)
			if (listArray[i] == source[j].text)
			{
				source[j].selected = true;
				break;				
			}

	// Move all of the selections to the other list box.
	Insert(form);
}

//-----------------------------------------------------------------------------------------------------------
function Insert(form)
{
   var source = form.frmList.options;
   var dest = form.frmSelected.options;

   for (var i = 0; i < source.options.length; i++)
   {
      if (source[i].selected)
      {
          dest[dest.length] = new Option(source[i].text);
          source[i] = null;
          i--;
      }
   }

	if (navigator.appName == "Netscape") history.go(0);
}


//-----------------------------------------------------------------------------------------------------------
function Delete(form)
{
   var source = form.frmSelected.options
   var dest = form.frmList.options

   for (var i = 0; i < source.options.length; i++)
   {
      if (source[i].selected)
      {
          dest[dest.length] = new Option(source[i].text);
          source[i] = null;
          i--;
      }
   }
}


//-----------------------------------------------------------------------------------------------------------
function SelectAll(form)
{
   var source = form.frmSelected.options;
   var len = source.options.length;
   var text = ""

   if (len == 0) 
   {
      alert("You must select at least one field name.");
      return false;
   }

   	// Select everything.
   	for (var i = 0; i <len; i++)
	{   
   		source[i].selected = true;
		if (text == "") text += source[i].text
		else text += "," + source[i].text
	}

	document.cookie = "PerformanceDataFields=" + text;

   return true;
}
//-----------------------------------------------------------------------------------------------------------
</script>
<% End If %>
</head>
<% If Request("SelectionMode") = "FIELDS" Then %>

<body onLoad="LoadLastSelections(document.forms[0])">
<% End If %>
<%
'-------------------------------------------------------------------------------------------------------------

	'Increase timeout for people using this query.
	Session.Timeout = 3 'Minutes
	Server.ScriptTimeout = 180 'Seconds

	
	If Request("TableName") <> "" Then Session("TableName") = Request("TableName")

	'Format the time for display.
	If Request("StartMonth") <> "" Then
		Session("StartDate") = CDbl(CDate(Request("StartYear") & "-" 	& Request("StartMonth") & "-" & Request("StartDay")))	
		Session("EndDate")   = CDbl(CDate(Request("EndYear")   & "-" & Request("EndMonth")    & "-" & 	Request("EndDay")))

		If Session("StartDate") = Session("EndDate") Then
			Session("DateForDisplay") = CDate(Session("StartDate"))
		else
			Session("DateForDisplay")=  CDate(Session("StartDate")) & "&nbsp;&nbsp;&nbsp;" & "   To   " & "&nbsp;&nbsp;&nbsp;" & CDate(Session("EndDate"))
		end if

		Session("EndDate") = Session("EndDate") + 1
	End If


	'Show the list of units.
	If Request("frmID") = "" Then
		Response.Write "<h2 align='center'>Unit Performance Data</h2>"
		Response.Write "<hr align='center'>"
		Response.Write "<center>" & Session("DateForDisplay") & "</center><br>"
		Call ShowUnitTypes()

	'Get all of the information for the unit.
	ElseIf Request("SelectionMode") = "ALL"  AND Request("frmID") = 1 Then
		Call GetInformation()

	
	ElseIf Request("SelectionMode") = "FIELDS" AND Request("frmID") = 1 Then
		Response.Write "<center>" & Session("DateForDisplay") & "</center><br>"
		Response.Write "<center>Data for " & Session("TableName") & "</center><br>"

		CreateOptionsLists Session("TableName")

	ElseIf Request("frmID") = 2 Then
		Call GetInformation()
	End If


%>
</body>
</html>
<%



'-------------------------------------------------------------------------------------------------------------
Sub GetInformation()

	Dim Conn
	Dim RS
	Dim Query	

	Dim fsObject
	Dim Column
	Dim strLine
	Dim MyFile
	Dim Filename
	Dim hrefFilename
	Dim pathFilename

	If Session("StartDate") = "" Then
		Response.Clear
		Response.Write "Your session has expired.<br>"
		Response.End
	End If

	'--------------------------------------------------------------------------------------------------------
	'Create the desired query.

	If Request("SelectionMode") = "ALL" Then
		Query = "SELECT " & _
					"I.*, " & _
					"(I.StopTime - I.StartTime) * 1440 AS TestTime, " & _
					"F.*, " & _
					"P.* " & _

				"FROM " & _
				"( " & _
					"(" & _
						"Index AS I LEFT JOIN PartNumbers AS PN ON " & _
	          			"( " & _
							"I.PartNumber = PN.PartNumber AND PN.TableName = '" & Request("TableName") & "' AND " & _
							"I.StartTime BETWEEN " & Session("StartDate") & " AND " & Session("EndDate") & _
						") " & _
					") " & _

					"LEFT JOIN FailureInformation AS F ON I.ID = F.ID " & _
				") " & _
	
				"LEFT JOIN [" & Request("TableName") & "] AS P ON P.ID = I.ID " & _

				"ORDER BY I.StartTime, I.SerialNumber"

	Else
		Query = "SELECT " & Request("frmSelected") & " " & _

				"FROM " & _
				"( " & _
					"(" & _
						"Index AS I LEFT JOIN PartNumbers AS PN ON " & _
	          			"( " & _
							"I.PartNumber = PN.PartNumber AND PN.TableName = '" & Session("TableName") & "' AND " & _
							"I.StartTime BETWEEN " & Session("StartDate") & " AND " & Session("EndDate") & _
						") " & _
					") " & _

					"LEFT JOIN FailureInformation AS F ON I.ID = F.ID " & _
				") " & _
	
				"LEFT JOIN [" & Session("TableName") & "] AS P ON P.ID = I.ID " & _

				"ORDER BY I.StartTime, I.SerialNumber"
	End If


	'--------------------------------------------------------------------------------------------------------
	'Response.CacheControl = "Private"
'	Response.Expires = -1


	Set Conn = Server.CreateObject("ADODB.Connection")
	Conn.Open Application("ProductionDatabase")
	Set RS = Conn.Execute(Query)

	' Check for error.
	If Err.Description <> "" Then
		
		'Keep track of which screen is being displayed.
		Response.Write "<B>Error " + Hex(Err) + ": " + Err.Description + "</B><br>"

	' Check for no-record case.
	ElseIf RS.EOF And RS.BOF Then 

		'Keep track of which screen is being displayed.
		Response.Write "No records were found for product model " & Session("TableName") & " for the specified period of " & Session("DateForDisplay") & ".<br>" & vbCrLf


	' Valid data was received from the query.
	Else
		
		'Determine the name of the temporary file.
		Filename = Session.SessionID & ".xls"
		hrefFilename = Application("SessionFilesDirectory") & "/" & Filename
		pathFilename = Application("SessionFilesPath") & "\" & Filename

		Set fsObject = Server.CreateObject("Scripting.FileSystemObject")
		Set MyFile = fsObject.CreateTextFile(pathFilename, True)

		'Create the table header row.
		strLine = ""
		For Each Column in RS.Fields
			strLine = strLine & chr(34) & Column.Name & chr(34) & chr(9)
		Next

		'Write the field names to the file.
		MyFile.WriteLine strLine

		'Fill in the cells with data.
		Do While Not RS.EOF
			strLine = ""
			For Each Column in RS.Fields
				strLine = strLine & Column.Value & chr(9)
			Next

			MyFile.WriteLine strline
			RS.MoveNext
		Loop
	
		MyFile.Close

		Set MyFile = Nothing
		Set fsObject = Nothing

		Response.Write "<A href='" & hrefFilename & "'>Click here to download " & Session("TableName") & "&nbsp;data file. &nbsp;&nbsp;" & Session("DateForDisplay") & "</a>"

	End If


End Sub




'-------------------------------------------------------------------------------------------------------------
Sub ShowUnitTypes()

	Response.Write "<br>" & vbCrlf
	Response.Write "<center>" & vbCrlf

	Response.Write "Get the data for the selected unit type and down-load it into an Excel spreadsheet.<br>" & vbCrlf

	Response.Write "Only information collected for the date(s) shown above will be retrieved.<br>" & vbCrlf


	'--------------------------------------------------------------
	'Create the form.
	Response.Write "<form action = 'PerformanceData.asp'>" & vbCrlf
	Response.Write "<table border='3' cellspacing='0'>" & vbCrlf

		Response.Write "</tr>" & vbCrlf
			Response.Write "<th>Product Family</th>" & vbCrlf
			Response.Write "<th>Category</th>"	 & vbCrlf
			Response.Write "<th>Description</th>" & vbCrlf
		Response.Write "</tr>" & vbCrlf

		'Show the ZTT/Plus units.
	  	Response.Write "<tr><td rowspan='10'>ZTT/Plus</td>" & vbCrlf
		  	Response.Write MakeRow(1, 0, "149502007-001", "Input (120 V, 60 Hz), Output (15 Amps @ 60/90 Volts)") & vbCrlf
			Response.Write MakeRow(0, 0, "149502013-001", "Input (230 V, 50 Hz), Output (15 Amps @ 60 Volts)") & vbCrlf
			Response.Write MakeRow(0, 0, "149502016-001", "Input (220 V, 60 Hz), Output (15 Amps @ 60/90 Volts)") & vbCrlf
			Response.Write MakeRow(0, 0, "149502020-001", "Input (120 V, 60 Hz), Output (15 Amps @ 60 Volts)") & vbCrlf
			Response.Write MakeRow(0, 0, "149502021-001", "Input (230 V, 50 Hz), Output (15 Amps @ 60/90 Volts)") & vbCrlf
			Response.Write MakeRow(0, 0, "149502027-001", "Input (120 V, 60 Hz), Output (15 Amps @ 60/75/90 Volts)") & vbCrlf
			Response.Write MakeRow(0, 0, "149502036-001", "Input (120 V, 60 Hz), Output (9 Amps @ 60 Volts)") & vbCrlf
			Response.Write MakeRow(0, 0, "149502039-001", "Input (230 V, 50 Hz), Output (9 Amps @ 48/60 Volts)") & vbCrlf
			Response.Write MakeRow(0, 0, "103000266", "Inverter Module, Input (120 V, 60 Hz)") & vbCrlf

		'Show the ZTT Generation One units.
	  	Response.Write "<tr><td rowspan='2'>ZTT</td>" & vbCrlf
		  	'Response.Write MakeRow(0, 0, "CS2023", "Input (120 V, 60 Hz), Output (15 Amps @ 60/90 Volts)") & vbCrlf
			Response.Write MakeRow(0, 0, "149165884-001", "Input (120 V, 60 Hz), Output (15 Amps @ 60/90 Volts)") & vbCrlf

		'Show the CPR units.
	  	Response.Write "<tr><td rowspan='6'>CPR</td>" & vbCrlf
		  	Response.Write MakeRow(0, 0, "149502040-001", "Input (120 V, 60 Hz), Output (15 Amps @ 60/75/90 Volts)") & vbCrlf
			Response.Write MakeRow(0, 0, "149502052-001", "Input (230 V, 50 Hz), Output (15 Amps @ 48/60 Volts)") & vbCrlf
			Response.Write MakeRow(0, 0, "149502055-001", "Input (240 V, 60 Hz), Output (24 Amps @ 60/75/90 Volts)") & vbCrlf
			Response.Write MakeRow(0, 0, "649000001-001", "Input (230 V, 50 Hz), Output (15 Amps @ 60/75/90 Volts)") & vbCrlf
			Response.Write MakeRow(0, 0, "649000002-001", "Input (220 V, 60 Hz), Output (15 Amps @ 60/75/90 Volts)") & vbCrlf



		'Show the Sentry/Ferro units.
	  	Response.Write "<tr><td rowspan='5'>Sentry/Ferro</td>" & vbCrlf
		  	Response.Write MakeRow(0, 0, "149165877-001", "Input (120 V, 60 Hz), Output (9 Amps @ 60/90 Volts)") & vbCrlf
			Response.Write MakeRow(0, 0, "149502024-001", "Input (120 V, 60 Hz), Output (15 Amps @ 60/90 Volts)") & vbCrlf
			Response.Write MakeRow(0, 0, "149502026-001", "Input (120 V, 60 Hz), Output (15 Amps @ 60/75/90 Volts)") & vbCrlf
		  	Response.Write MakeRow(0, 0, "TT0237", "Input (120 V, 60 Hz), Output (9 Amps @ 60 Volts)") & vbCrlf


	Response.Write "</table>" & vbCrlf

	Response.Write "<br>" & vbCrlf
	Response.Write "<input type='radio' value='ALL' name='SelectionMode'>Get all data." & vbCrlf
	Response.Write "&nbsp;&nbsp;&nbsp;&nbsp;" & vbCrlf
	Response.Write "<input type='radio' value='FIELDS' name='SelectionMode' checked>Select from list." & vbCrlf

	Response.Write "<br><br>" & vbCrlf
	Response.Write "<input type='submit' value='Submit' name='B1'>" & vbCrlf


	'Keep track of which screen is being displayed.
	Response.Write "<input type='hidden' value='1' name='frmID'>" & vbCrlf

	Response.Write "</form>" & vbCrlf
	Response.Write "</center>" & vbCrlf

End Sub


'-------------------------------------------------------------------------------------------------------------
Function MakeRow(Checked, Disabled, ProductName, Description)

	Dim strDisabled
	Dim strChecked
	Dim strValue	

	'Default values.
	strChecked = "name='TableName' "
	strDisabled = ""
	strValue = "value='" & ProductName & "' "	


	If Checked Then strChecked = "Checked Name='TableName' "
	If Disabled Then strDisabled = "Disabled "



	MakeRow = "<tr>" & _
					"<td><input type='radio' " & strValue & strChecked & strDisabled & ">" & ProductName & "</td>" & _
					"<td>" & Description & "</td>" & _	
				"</tr>"
End Function

'-------------------------------------------------------------------------------------------------------------
Sub CreateOptionsLists(TableName)

	Dim List
	Dim Conn

	Set Conn = Server.CreateObject("ADODB.Connection")
	Conn.Open Application("ProductionDatabase")

	'Get all of the field names.
	List = ""
	GetFieldNames Conn, "Index", "I", List
	GetFieldNames Conn, "FailureInformation", "F", List
	GetFieldNames Conn, "[" & TableName & "]", "P", List


	Response.Write "<form action = 'PerformanceData.asp'>" & vbCrlf
  	Response.Write "<table border='0' align='center' cellpadding='1' cellspacing='0'>"

		Response.Write "<tr>"
      		Response.Write "<td colspan='3' align='center'>"
				Response.Write "Select the desired fields.<br>"
      			Response.Write "Fields are available from three tables.<br>"
      			Response.Write "<b><big>I</big></b>ndex, <b><big>F</big></b>ailure Information "
				Response.Write "and <b><big>P</big></b>erformance Data<br>&nbsp;"
			Response.Write "</td>"
    	Response.Write "</tr>"

    	Response.Write "<tr>"
      		Response.Write "<th>Available Fields</th>"
      		Response.Write "<th>&nbsp;</th>"
      		Response.Write "<th>Selected Fields</th>"
    	Response.Write "</tr>"

    	Response.Write "<tr>"
      		Response.Write "<td align='center'>"
				Response.Write "<select name='frmList' multiple size='20'>"
    				Response.Write List
		  		Response.Write "</select>"
			Response.Write "</td>"

      		Response.Write "<td align='center'>"
				Response.Write "<input type='button' name='frmInsert' value='  >>  ' OnClick='Insert(this.form)'>"
				Response.Write "<br>&nbsp;<br>"
      			Response.Write "<input type='button' name='frmDelete' value='  <<  ' OnClick='Delete(this.form)'>"
			Response.Write "</td>"

	      	Response.Write "<td align='center'>"
				Response.Write "<select name='frmSelected' multiple size='20'>"
      			Response.Write "</select>"
			Response.Write "</td>"
    
		Response.Write "</tr>"

    	Response.Write "<tr>"
      		Response.Write "<td>&nbsp;</td>"
      		Response.Write "<td>"
				Response.Write "&nbsp;<br>"
				Response.Write "<input type='Submit' value='Submit' OnClick='return SelectAll(this.form)'>"
			Response.Write "</td>"

      		Response.Write "<td>&nbsp;</td>"
    	Response.Write "</tr>"
  
	Response.Write "</table>"

	'Keep track of which screen is being displayed.
	Response.Write "<input type='hidden' value='2' name='frmID'>"

	Response.Write "</form>"

End Sub


'-------------------------------------------------------------------------------------------------------------
Sub GetFieldNames(Conn, TableName, Label, List)

	Dim RS
	Dim Ctr

	Set RS = Conn.Execute(TableName)

	For Ctr = 0 To RS.Fields.Count - 1
		List = List & "<option>" & Label & ".[" & RS.Fields(Ctr).Name & "]</option>" & vbCrLf
	Next

End Sub



%>
