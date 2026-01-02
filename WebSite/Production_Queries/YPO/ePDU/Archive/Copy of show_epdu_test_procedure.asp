<%Option Explicit%>
<%Response.Buffer = TRUE%>
<html>

<head>
<title>ePDU Test Procedure</title>
</head>

<body>


<h2 align="center">ePDU Test Procedure</h2>

<%

Const sProcedureLocation = "\\youncsfp01\data\Test-Eng\ePDU\Final_Assembly_Test\Test_Procedures\"
'Const SDatabaseLocation = "\\youncsfp01\data\test-eng\ePDU\Final_Assembly_Test\TestProcedureIndex.mdb"
Const SDatabaseLocation = "\\youncsfp01\data\test-eng\ePDU\Database\ePDU_Setup.mdb"

Dim Conn				'Database connection.
Dim strConn				'Connection string
Dim Sql					'The query to be executed.
Dim PartNumber

PartNumber = UCase(Request("PartNumber"))

If Len(PartNumber) = 0 Then
	Response.Write "You must enter a part number."
	Response.End

End If



'Sql = "SELECT *  FROM qry_index_view WHERE PartNumber LIKE '" & PartNumber & "%' "
Sql = "SELECT *  FROM qry_part_number_view WHERE PartNumber LIKE '" & PartNumber & "%' "

Response.Write "<h2 align='center'> Search for part numbers starting with " & PartNumber & "</h2>"



Set Conn = Server.CreateObject("ADODB.Connection")



strConn = "DRIVER=Microsoft Access Driver (*.mdb);" & _
          "UID=;" & _
          "PWD=;" & _
          "FIL=MS Access;" & _
          "DBQ=" & SDatabaseLocation


Conn.Open strConn

ShowTable Conn, Sql


Conn.Close
Set Conn = Nothing



Sub ShowTable(dbConn, strQuery)

	Dim RS
	Dim Ctr
	Dim RowCtr
	Dim PartNumber
	Dim Assembly
	Dim TestProcedure

	Set RS = dbConn.Execute(strQuery)

	' Check for error.
	If Err.Description <> "" Then
		Response.Write "<B>Error " + Hex(Err) + ": " + Err.Description + "</B><br>"

	' Check for no-record case.
	ElseIf RS.EOF And RS.BOF Then
		Response.Write "No records were found. <br>"

	' Valid data was received from the query.
	Else


		'Response.Write "<table width=1500 align='center' BORDER = '3.0' cellspacing='0' cellpadding='1'>"
		Response.Write "<table align='center' BORDER = '3.0' cellspacing='0' cellpadding='1'>"

		'Create the table header row.
  		Response.Write "<tr>"
			Response.Write "<th>Part Number</th>"
			Response.Write "<th>Test Procedure</th>"
			Response.Write "<th>Assembly Number</th>"
		Response.Write "</tr>"


		'Fill in the cells with data.
		Do While Not RS.EOF

			PartNumber = rs("PartNumber")

			Select Case RS("ProcedureID")

				'Unknown
				Case 1
					TestProcedure = RS("ProcedureName")

				'Same as assembly number
				Case 2
					TestProcedure = RS("ProcedureName")

				'A common procedure exists.
				Case Else
					TestProcedure = "<A HREF='" & sProcedureLocation & "Common\" & RS("ProcedureName") & "'>" & RS("ProcedureName") & "</A>"

			End Select

			Response.Write "<tr>"
				Response.Write "<td>" & PartNumber & "</td>"
				Response.Write "<td>" & TestProcedure & "</td>"
				Response.Write "<td>" & GetAssembyDocs( RS("AssemblyNumber") ) & "</td>"

			Response.Write "</tr>"

			RS.MoveNext
		Loop

		Response.Write "</table>"
		Response.Write "</center>"

	End If

	RS.Close
	Set RS = Nothing

End Sub





Function GetAssembyDocs(sAssembly)

	Dim iAssembly
	Dim sLinks
	Dim subFolder
	Dim rootFolder
	Dim fso
	Dim file


	sAssembly = Trim(sAssembly)

	If Len(sAssembly) > 4 Then sAssembly = Left(sAssembly,4)


	If IsNumeric (sAssembly) Then
		iAssembly = CInt(sAssembly)
	Else
		GetAssembyDocs = "&nbsp;"
		Exit Function
	End If


	'Determine which subfolder to use based on the assembly number.
	subFolder = "0100-1999"
	If iAssembly >= 2000 Then subFolder = "2000-2499"
	If iAssembly >= 2500 Then subFolder = "2500-2999"
	If iAssembly >= 3000 Then subFolder = "3000-3499"
	If iAssembly >= 3500 Then subFolder = "3500--"
	If iAssembly >= 4000 Then subFolder = "4000"
	If iAssembly >= 5000 Then subFolder = "5000"


	subFolder = sProcedureLocation & "Assemblies\" & subFolder


	Set fso = Server.CreateObject("Scripting.FileSystemObject")
	Set rootFolder = fso.GetFolder(subFolder)


	For Each file in rootFolder.Files

		If Instr(File.Name, sAssembly) And Instr(File.Name, "$") < 1 then

			If Len(sLinks) = 0 then
				sLinks =  "<A HREF='" & subFolder & "\" & File.name & "'>"  & File.Name & "</A>"
			Else
				sLinks =  sLinks & "<br><A HREF='" & subFolder & "\" & File.name & "'>"  & File.Name & "</A>"
			End If

		End If

	Next

	GetAssembyDocs = sLinks

	Set file = Nothing
	Set subFolder = Nothing
	Set rootFolder = Nothing
	Set fso = Nothing


End Function




%>
</body>
</html>
