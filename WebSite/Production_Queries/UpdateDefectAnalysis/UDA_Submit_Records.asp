<%Option Explicit%>
<html>

<head>
<title>Defect Analysis Submission Form</title>
</head>

<body>

<h2 align="center">Defect Analysis Submission</h2>

<hr>
<%

   Dim Conn
   Dim strResponseIDs

   'Do not allow the user past this point without proper login.
   If Session("Password") = "" Then Response.Redirect "UDA_Login.Asp"

   'Get the values from the form.
   strResponseIDs = Request("frmIDs")

   'Connect to the database.
   Set Conn = Server.CreateObject("ADODB.Connection")


   Conn.Open Application("ProductionDatabase")
	


   Call SubmitDefectInformation(strResponseIDs)



'--------------------------------------------------------------------------------------------------------
Sub SubmitDefectInformation(FormData)

   Dim MyArray
   Dim Temp
   Dim intArrayCtr
   Dim strUpdateQuery

   Dim strRemarks
   Dim strDefects
   Dim strSubCat1
   Dim strSubCat2
   Dim strSubCat3
   Dim strStation
   Dim strComponent
   Dim strReference


   intArrayCtr = 0


   MyArray = Split(FormData, ",")

   For Each Temp In MyArray

      intArrayCtr = intArrayCtr + 1

      strRemarks = Request("R" & intArrayCtr)
      strDefects = Request("D" & intArrayCtr)                   'Defect Categories
      strSubCat1 = Request("S1_" & intArrayCtr)                 'Sub Assemblies
      strSubCat2 = Request("S2_" & intArrayCtr)                 'Defect Codes
      strSubCat3 = Request("S3_" & intArrayCtr)                 'Form Completedy By
      strStation = Request("Station" & intArrayCtr)
      strComponent = UCase( Request("CN" & intArrayCtr) )		
      strReference = UCase( Request("RD" & intArrayCtr) )

      'Defaults
      If strRemarks = "" Then strRemarks = "None."
      If strDefects = "" Then strDefects = "1"
      If strComponent = "" Then strComponent = "None."
      If strReference = "" Then strReference = "None."


      'The quote character is not allowed.
      strRemarks  = Replace(strRemarks, "'", "")
      strRemarks  = Replace(strRemarks, """", "")		
      strComponent = Replace(strComponent, "'", "")
      strComponent = Replace(strComponent, """", "")		
      strReference = Replace(strReference, "'", "")
      strReference = Replace(strReference, """", "")		

		
      'Build the query that does the update.
      strUpdateQuery =  "UPDATE FailureInformation " &_
                        "SET " &_
                        "DefectCategory = '" & strDefects & "', " &_
                        "SubCat1 = '" & strSubCat1 & "', " &_
                        "SubCat2 = '" & strSubCat2 & "', " &_
                        "SubCat3 = '" & strSubCat3 & "', " &_
                        "ComponentNumber = '" & strComponent & "', " &_
                        "ReferenceDesignator = '" & strReference & "', " &_
                        "Remarks = '" & strRemarks & "' " &_
                        "WHERE ID = " & Temp




      Response.Write strUpdateQuery & "<br>"

		
      'Update the database with the new values.
      If  (Temp <> "")  Then 
         Conn.Execute(strUpdateQuery)
      End If


      'Check for error.
      If Err.Description <> "" Then
         Response.Write "<B>Error " + Hex(Err) + ": " + Err.Description + "</B><br>"
      End If
		
   Next

   Response.Write "Records were updated.<br>"

End Sub




%>
</body>
</html>
