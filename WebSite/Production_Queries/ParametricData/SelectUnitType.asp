<%Option Explicit%>
<html>

<head>
<title>First Pass Yields</title>
</head>

<body>

<h2 align="center">First Pass Yields From NCR Database</h2>

<hr align="center">

<p><%
	Dim Conn
	Dim RS
	Dim Query	
	Dim QueryStartDate
	Dim QueryEndDate
	Dim DisplayStart
	Dim DisplayEnd
	Dim ProductionDatabase

	'Lower the timeout for people looking at yields to free-up resources.
	Session.Timeout = 1


	'--------------------------------------------------------------------------------------------------------
	'Put time in proper format.

	DisplayStart = Request("StartMonth") & "/" & Request("StartDay") & "/" & Request("StartYear")
	DisplayEnd   = Request("EndMonth")   & "/" & Request("EndDay")   & "/" & Request("EndYear")

	if DisplayStart = DisplayEnd then
		Response.Write "<center>" & DisplayStart & "</center><P>"
	else
		Response.Write "<center>" & DisplayStart & "&nbsp;&nbsp;&nbsp;" & "   To   " & "&nbsp;&nbsp;&nbsp;" & DisplayEnd & "</center><P>"
	end if


	QueryStartDate = "#" & Request("StartMonth") & "/" & Request("StartDay") & "/" & Request("StartYear") & "#"
	QueryEndDate   = "#" & Request("EndMonth")   & "/" & Request("EndDay")   & "/" & Request("EndYear") & "#"

	Response.Write "<br>"

	'--------------------------------------------------------------------------------------------------------
	'Connect to the database

	
	Set Conn = Server.CreateObject("ADODB.Connection")
	Conn.Open Application("ProductionDatabase")



	'--------------------------------------------------------------------------------------------------------
	'Make sure that there are some records available.


	'--------------------------------------------------------------------------------------------------------
	'Overall Yields

	Query = "SELECT " & _
			 "Count(PN.PartNumber) As [Tested], " & _
			 "Sum(Results) As [Passed], " & _
			 "Count(PN.PartNumber) - Sum(Results) AS [Failed], " & _
			 "Sum(Results) / Count(PN.PartNumber) AS FPY " & _
			 "FROM [NCR - Yield View] " & _
			 "WHERE ( Tag = 1 OR ISNULL(Tag) ) AND " & _
			 "(Log.Date BETWEEN " & QueryStartDate & " AND " & QueryEndDate & ") "

	Response.Write "<h3 align='center'> Overall Yields</h3>"
	DisplayQueryResults
	Response.Write "<br> <br> <br>"



	'--------------------------------------------------------------------------------------------------------
	'Yields by Family

	Query = "SELECT " & _
           "PN.Family, " & _
			 "Count(PN.PartNumber) As [Tested], " & _
			 "Sum(Results) As [Passed], " & _
			 "Count(PN.PartNumber) - Sum(Results) AS [Failed], " & _
			 "Sum(Results) / Count(PN.PartNumber) AS FPY " & _
			 "FROM [NCR - Yield View] " & _
			 "WHERE ( Tag = 1 OR ISNULL(Tag) ) AND " & _
			 "(Log.Date BETWEEN " & QueryStartDate & " AND " & QueryEndDate & ") " & _
			 "GROUP BY PN.Family"

	Response.Write "<h3 align='center'> Yields By Product Family  </h3>"
	DisplayQueryResults
	Response.Write "<br> <br> <br>"


	'--------------------------------------------------------------------------------------------------------
	'Yields by Family & Category

	Query = "SELECT " & _
           "PN.Family, Category, " & _
			 "Count(PN.PartNumber) As [Tested], " & _
			 "Sum(Results) As [Passed], " & _
			 "Count(PN.PartNumber) - Sum(Results) AS [Failed], " & _
			 "Sum(Results) / Count(PN.PartNumber) AS FPY " & _
			 "FROM [NCR - Yield View] " & _
			 "WHERE ( Tag = 1 OR ISNULL(Tag) ) AND " & _
			 "(Log.Date BETWEEN " & QueryStartDate & " AND " & QueryEndDate & ") " & _
			 "GROUP BY PN.Family, Category"

	Response.Write "<h3 align='center'> Yields By Product Family & Category  </h3>"
	DisplayQueryResults
	Response.Write "<br> <br> <br>"


	'--------------------------------------------------------------------------------------------------------
	'Yields by Family & Category & Model

	Query = "SELECT " & _
           "PN.Family, Category, Model, " & _
			 "Count(PN.PartNumber) As [Tested], " & _
			 "Sum(Results) As [Passed], " & _
			 "Count(PN.PartNumber) - Sum(Results) AS [Failed], " & _
			 "Sum(Results) / Count(PN.PartNumber) AS FPY " & _
			 "FROM [NCR - Yield View] " & _
			 "WHERE ( Tag = 1 OR ISNULL(Tag) ) AND " & _
			 "(Log.Date BETWEEN " & QueryStartDate & " AND " & QueryEndDate & ") " & _
			 "GROUP BY PN.Family, Category, Model"

	Response.Write "<h3 align='center'> Yields By Product Family & Category & Model </h3>"
	DisplayQueryResults
	Response.Write "<br> <br> <br>"



	'--------------------------------------------------------------------------------------------------------
	'Yields by Part Number

	Query = "SELECT " & _
           "PN.PartNumber, " & _
			 "Count(PN.PartNumber) As [Tested], " & _
			 "Sum(Results) As [Passed], " & _
			 "Count(PN.PartNumber) - Sum(Results) AS [Failed], " & _
			 "Sum(Results) / Count(PN.PartNumber) AS FPY " & _
			 "FROM [NCR - Yield View] " & _
			 "WHERE ( Tag = 1 OR ISNULL(Tag) ) AND " & _
			 "(Log.Date BETWEEN " & QueryStartDate & " AND " & QueryEndDate & ") " & _
			 "GROUP BY PN.PartNumber " & _
           "ORDER BY PN.PartNumber"

	Response.Write "<h3 align='center'> Yields By Part Number  </h3>"
	DisplayQueryResults
	Response.Write "<br> <br> <br>"


Sub DisplayQueryResults()

	Dim RS
	Dim Ctr

	'Response.Write Query & "<p><br>"
	'response.end

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
	Response.Write "<table BORDER = '3.0' cellspacing='0' cellpadding='1'>"

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
	      			If RS.Fields(Ctr).Name = "%Passed" OR RS.Fields(Ctr).Name = "%Failed"  OR RS.Fields(Ctr).Name = "FPY" Then
						Response.Write "<td>" & FormatPercent(RS(ctr)) & "&nbsp;</td>"
					
					ElseIf RS.Fields(Ctr).Name = "DPM" Then
						Response.Write "<td>" & CLng(RS(ctr)) & "&nbsp;</td>"
					
					Else
						Response.Write "<td>" & RS.Fields(Ctr) & "&nbsp;</td>"
					End If
				Next
				Response.Write "</tr>"
		
			RS.MoveNext
		Loop
	
	Response.Write "</table>"
	Response.Write "</center>"	
End If

	RS.Close
	Set RS = Nothing

End Sub

%> </p>
</body>
</html>
