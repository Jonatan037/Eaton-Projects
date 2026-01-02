<%Option Explicit%>
<html>

<head>
<title>9170 Receptacle Usage</title>
</head>

<body>
<!-- #include File=..\Tools\GenericTable.Inc -->

<h2 align="center">9170 Receptacle Usage</h2>

<hr align="center">
<%
Const cMAX = 24		'The number of receptacle types in the CTO chart.

Dim Conn				'Database connection.
Dim RS					'Recordset
Dim Query				'The query to be executed.
Dim QueryStartDate
Dim QueryEndDate
Dim DisplayStart
Dim DisplayEnd
Dim Ctr				'Temporary counter variable.

Dim CTO()				'Array of CTO characters.
Dim Total()			'Running total of this type of receptacle used.
Dim RCU()				'The RCU number of this receptacle.
Dim Description()		'Description of this receptacle.



'Lower the timeout for people looking at yields to free-up resources.
Session.Timeout = 1


Call Initialize


DisplayStart = Request("StartMonth") & "/" & Request("StartDay") & "/" & Request("StartYear")
DisplayEnd   = Request("EndMonth")   & "/" & Request("EndDay")   & "/" & Request("EndYear")

if DisplayStart = DisplayEnd then
	Response.Write "<center>" & DisplayStart & "</center><P>"
else
	Response.Write "<center>" & DisplayStart & "&nbsp;&nbsp;&nbsp;" & "   To   " & "&nbsp;&nbsp;&nbsp;" & DisplayEnd & "</center><P>"
end if


QueryStartDate = "{ts '" &	Request("StartYear") & "-" 	& Request("StartMonth") & "-" &	Request("StartDay") & " 00:00:00'}"
QueryEndDate   = "{ts '" & 	Request("EndYear")   & "-" & Request("EndMonth")    & "-" & 	Request("EndDay")   & " 23:59:59'}"

Response.Write "<br>"

Set Conn = Server.CreateObject("ADODB.Connection")
Conn.Open Application("ProductionDatabase")
	

Query = "SELECT PartNumber, Count(PartNumber) AS Total FROM Index WHERE " & _
           "(PartNumber Like '660%') AND " & _
           "(StartTime BETWEEN " & QueryStartDate & " AND " & QueryEndDate & ") AND " & _
           "Mid(PartNumber, 9, 6) <> 'AAAAAA' " & _
        "GROUP BY PartNumber"





Set RS = Conn.Execute(Query)

' Check for error.
If Err.Description <> "" Then
	Response.Write "<B>Error " + Hex(Err) + ": " + Err.Description + "</B><br>"

' Check for no-record case.
ElseIf RS.EOF And RS.BOF Then 
	Response.Write "No records were found. <br>"

' Valid data was received from the query.
Else


	'Get the totals.
	Do While Not RS.EOF
		GetCount Mid(RS("PartNumber"),9,1),  Mid(RS("PartNumber"),10,1), RS("Total")
		GetCount Mid(RS("PartNumber"),11,1), Mid(RS("PartNumber"),12,1), RS("Total")
		GetCount Mid(RS("PartNumber"),13,1), Mid(RS("PartNumber"),14,1), RS("Total")
		RS.MoveNext
	Loop
	
	Response.Write "<table align='center' BORDER = '3.0' cellspacing='0' cellpadding='1'>"

	'Create the table header row.
  	Response.Write "<tr>"
		Response.Write "<th>CTO Char</th>"
		Response.Write "<th>Total Used</th>"
		Response.Write "<th>RCU</th>"
		Response.Write "<th>Description</th>"
	Response.Write "</tr>"


	'Display the results
	For Ctr = 2 to cMAX
  		Response.Write "<tr>"
			Response.Write "<td align='center'>" & CTO(Ctr) & "</tr>"
			Response.Write "<td align='center'>" & Total(Ctr) & "</tr>"
			Response.Write "<td>" & RCU(Ctr)& "</tr>"
			Response.Write "<td>" & Description(Ctr)& "</tr>"
		Response.Write "</tr>"		
	Next

	Response.Write "</table>"
	
End If


'Show the part numbers.
Response.Write "<br><br><br>"
GenericTable Conn, Query



Sub GetCount(ctoCount, ctoType, ctoTotal)
	
	Dim Count
	Dim Ctr 

	If Instr("ABCDEFGHIJKLMNOPQ", ctoCount)  < 1 Then
		'Response.Write ctoCount & " is an invalid character for receptacle number.<br>"
		Exit Sub
	End If


	Count = Asc(ctoCount) - Asc("A")
	Count = Count * CInt(ctoTotal)

	'Find the location of this character in the array.
	For Ctr = 1 To cMAX
		If CTO(Ctr) = ctoType Then
			Total(Ctr) = Total(Ctr) + Count
			Exit Sub
		End If		
	Next

	'Response.Write "ERROR ctoNumber = " & ctoNumber & "  ctoType = " & ctoType & "  ctoTotal = " & ctoTotal & "<br>"

End Sub



Sub Initialize()
	
	ReDim CTO(cMAX)
	ReDim Total(cMAX)
	ReDim RCU(cMAX)
	ReDim Description(cMAX)

	'Use array starting at 1.
	CTO(1)  = "A":	Total(1)  = 0:	RCU(0)  = "NONE":			Description(1)  = "NONE"
	CTO(2)  = "B":	Total(2)  = 0:	RCU(2)  = "RCU-0207":	Description(2)  = "UK"
	CTO(3)  = "C":	Total(3)  = 0:	RCU(3)  = "RCU-0188":	Description(3)  = "HV IEC320 10A"
	CTO(4)  = "D":	Total(4)  = 0:	RCU(4)  = "RCU-0195":	Description(4)  = "5-15 DUP"
	CTO(5)  = "E":	Total(5)  = 0:	RCU(5)  = "RCU-0196":	Description(5)  = "5-10 DUP"
	CTO(6)  = "F":	Total(6)  = 0:	RCU(6)  = "RCU-0201":	Description(6)  = "6-15 DUP"
	CTO(7)  = "G":	Total(7)  = 0:	RCU(7)  = "RCU-0202":	Description(7)  = "6-20 DUP"
	CTO(8)  = "H":	Total(8)  = 0:	RCU(8)  = "RCU-0208":	Description(8)  = "Australian"
	CTO(9)  = "I":	Total(9)  = 0:	RCU(9)  = "RCU-0322":	Description(9)  = "LV IEC320 10A"
	CTO(10) = "J":	Total(10) = 0:	RCU(10) = "RCU-0198":	Description(10) = "L5-15"


	CTO(11) = "K":	Total(11) = 0:	RCU(11) = "RCU-0199":	Description(11) = "L5-20"
	CTO(12) = "L":	Total(12) = 0:	RCU(12) = "RCU-0200":	Description(12) = "L5-30"
	CTO(13) = "M":	Total(13) = 0:	RCU(13) = "RCU-0203":	Description(13) = "L6-15 DUP"
	CTO(14) = "N":	Total(14) = 0:	RCU(14) = "RCU-0191":	Description(14) = "L6-20"
	CTO(15) = "O":	Total(15) = 0:	RCU(15) = "RCU-0190":	Description(15) = "L6-30"

	CTO(16) = "P":	Total(16) = 0:	RCU(16) = "RCU-0189":	Description(16) = "Shuko"
	CTO(17) = "Q":	Total(17) = 0:	RCU(17) = "RCU-0204":	Description(17) = "L14-20"
	CTO(18) = "R":	Total(18) = 0:	RCU(18) = "RCU-0205":	Description(18) = "L14-30"
	CTO(19) = "S":	Total(19) = 0:	RCU(19) = "RCU-0206":	Description(19) = "French Shuko"
	CTO(20) = "T":	Total(20) = 0:	RCU(20) = "RCU-0213":	Description(20) = "IEC309 32A"

	CTO(21) = "U":	Total(21) = 0:	RCU(21) = "RCU-0212":	Description(21) = "C19/C13"
	CTO(22) = "W":	Total(22) = 0:	RCU(22) = "RCU-0193":	Description(22) = "3 x 5-15 DUP"
	CTO(23) = "X":	Total(23) = 0:	RCU(23) = "RCU-0192":	Description(23) = "3 x 5-20 DUP"
	CTO(24) = "1":	Total(24) = 0:	RCU(24) = "RCU-????":	Description(24) = "(1) L6-30, (1) L5-20 & (1) L5-30"



End Sub

%>
</body>
</html>
