<%Option Explicit%>
<html>

<head>
<title>YPO Raw Material Locator</title>
</head>

<body>

<h2 align="center">YPO Raw Material Locator</h2>
<%
	Dim strPartNumber

	'On Error Resume Next

	strPartNumber = UCase(Request("frmPartNumber"))

	If strPartNumber = "" Then

		Response.Write "<center>"

		Response.Write "<form method='POST' action='Locator.Asp'>"

			Response.Write "Please enter part number:<br>"
			Response.Write "<input type='text' name='frmPartNumber' size='20'><br>"
			Response.Write "<input type='submit' value='Submit' name='B1'>"
		Response.Write "</form>"

		Response.Write "</center>"

	Else
		GetRecord
	End If

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


    ConnectionInformation = _
        "DRIVER=Microsoft Access Driver (*.mdb);" & _
		"UID=;" & _
		"PWD=;" & _
		"FIL=MS Access;" & _
		"DBQ=\\youncsfp01\DATA\9170Ferrups\InventoryDatabase\Inventory.mdb"

		'  "DBQ=C:\_TestEngineering\Database\Inventory\Inventory.mdb"



	'--------------------------------------------------------------------------------------------------------
	'Create the desired query.
	Query = "SELECT [Item], [Alt Item], [Description], [Line], [Rack], [Overflow], [Notes], [Plan]  " & _
            "FROM Inventory WHERE Item Like '" & strPartNumber & "%' OR [Alt Item] Like '" & strPartNumber & "%' " & _
		 	 "ORDER BY Item"
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

	Response.Write "<a href='http://bestweb.ch.etn.com/engineer/drawings/partnbr.htm'>BEST Web Part Drawings</a><br><br>"
	Response.Write "<a href='http://atum.ch.etn.com/print/'>EIS+ Part Drawings</a><br>"



	Response.Write "</center>"
End If

End Sub
%>
