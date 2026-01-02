<%Option Explicit%>
<html>

<head>
<title>YPO Raw Material Locator</title>
</head>

<body>

<h2 align="center">YPO Raw Material Locator</h2>
<%

'For calling directly.
'http://youncwhp5013525/Inventory/Locator.Asp?SearchType=ITEM&SearchCriteria=%25


	Dim strPartNumber
	dim search_criteria

	'On Error Resume Next

	search_criteria = UCase(Request("SearchCriteria"))

	If search_criteria = "" Then

		Response.Write "<center>"

		Response.Write "<form method='POST' action='Locator.Asp'>"


		Response.Write "Search for " 

		Response.Write "  <select  NAME='SearchType'>"
		Response.Write "    <option>Item</option>"
		Response.Write "    <option>Rack</option>"
		Response.Write "    <option>Description</option>"
		Response.Write "    <option>Notes</option>"
		Response.Write "  </select>"


		Response.Write " contains "

		Response.Write "<input type='text' name='SearchCriteria' size='20'>  "
		Response.Write "<input type='submit' value='Search' name='B1'> "
		Response.Write "<input type='reset' value='Reset' name='B2'> "


		Response.Write "</form>"

		Response.Write "</center>"

	Else
		GetRecord
	End If










'--------


%>
</body>
</html>
<%
Sub GetRecord()

	Dim Conn
	Dim RS
	Dim Query
	Dim Ctr
	Dim ConnectionInformation
	Dim search_type

	search_type = UCase(Request("SearchType"))


    ConnectionInformation = _
        "DRIVER=Microsoft Access Driver (*.mdb);" & _
		"UID=;" & _
		"PWD=;" & _
		"FIL=MS Access;" & _
		"DBQ=\\youncsfp01\DATA\9170Ferrups\InventoryDatabase\Inventory.mdb"

		'  "DBQ=C:\_TestEngineering\Database\Inventory\Inventory.mdb"



	'--------------------------------------------------------------------------------------------------------

	If search_type = "RACK" Then

		Query = "SELECT [Rack], [Item], [Description], [Line], [Warehouse], [Notes] " & _
                	"FROM Inventory WHERE Rack Like '%" & search_criteria & "%' " & _
			"ORDER BY Rack, Item"

	ElseIf search_type = "DESCRIPTION" Then

		Query = "SELECT [Item], [Description], [Line], [Rack], [Warehouse], [Notes] " & _
                	"FROM Inventory WHERE Description Like '%" & search_criteria & "%' " & _
			"ORDER BY Item"

	ElseIf search_type = "NOTES" Then

		Query = "SELECT [Item], [Description], [Line], [Rack], [Warehouse], [Notes] " & _
                	"FROM Inventory WHERE Notes Like '%" & search_criteria & "%' " & _
			"ORDER BY Item"

	Else

		Query = "SELECT [Item], [Description], [Line], [Rack], [Warehouse], [Notes] " & _
                	"FROM Inventory WHERE Item Like '%" & search_criteria & "%' " & _
			"ORDER BY Item"
	End if

	'--------------------------------------------------------------------------------------------------------

	'Show the query for debug purposes.
	'Response.Write Query & "<p><br>"

	Set Conn = Server.CreateObject("ADODB.Connection")

	'Open the database defined in the Global.asa file.

	Conn.Open (ConnectionInformation)
'	Conn.Open ("InventoryDatabase")


	Set RS = Conn.Execute(Query)

	' Check for error.
	If Err.Description <> "" Then
		Response.Write "<B>Error " + Hex(Err) + ": " + Err.Description + "</B><br>"

	' Check for no-record case.
	ElseIf RS.EOF And RS.BOF Then
		Response.Write "No records were found. <br>"

	' Valid data was received from the query.
	Else


	Response.Write "<div align='center'><center>"
	Response.Write "<table BORDER = '3.0', cellspacing='0' cellpadding='3'>"

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
					If RS.Fields(Ctr).Name = "StartTime" Then
						Response.Write "<td>" & FormatDateTime(RS.Fields(Ctr)) & "</td>"
					Else
						If IsNull(RS.Fields(Ctr)) Then
	      					Response.Write "<td> &nbsp; </td>"
						Else
							Response.Write "<td>" & RS.Fields(Ctr) & "&nbsp;</td>"
						End If
					End If
				Next
				Response.Write "</tr>"

			RS.MoveNext
		Loop

	Response.Write "</table><br><br>"


	Response.Write "</center>"
End If

End Sub
%>
