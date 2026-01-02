<%Option Explicit%>
<html>

<head>
<title>Defect Analysis Entry Form</title>
</head>

<body>

<h2 align="center">Records For Analysis</h2>

<hr>
<%
   Dim UserSelection
   Dim Conn

   'Do not allow the user past this point without proper login.
   If Session("Password") = "" Then Response.Redirect "UDA_Login.Asp"


   'Set timeout to 20 minutes.
   Session.Timeout = 20

   'Connect to the database.
   Set Conn = Server.CreateObject("ADODB.Connection")


   Conn.Open "DRIVER=Microsoft Access Driver (*.mdb);UID=;PWD=;FIL=MS Access;DBQ=\\youncsfp01\data\test-eng\ePDU\Database\ePDU_Production_Master.mdb"


   'Get the value of the radio button selected by the user.
   UserSelection = Request("R1")


   DisplayDefectInformation UserSelection

   Conn.Close




'--------------------------------------------------------------------------------------------------------
Sub DisplayDefectInformation(UserSelection)

   Dim RS
   Dim Query
   Dim Ctr
   Dim RowCtr

   Dim strIDs
   Dim strRSName
   Dim strRSData

   Dim intRowSpanCnt


   On Error Resume Next


   'Create a query that incorporates the user's cirteria.
   Query = BuildQuery(UserSelection)


   'Show the query for debug purposes.
   Response.Write Query & "<p><br>"

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

      Response.Write "<form method='POST' action='UDA_Submit_Records.Asp'>"

      Response.Write "<table BORDER = '3.0' cellspacing='0'>"

      'Fill in the cells with data.
      Do While Not RS.EOF

         RowCtr = RowCtr + 1

         'Determine how many rows this record will take when put into the table.
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
                  Response.Write CreateDefectList(RowCtr, strRSData)

               'Sub Assemblies
               ElseIf strRSName = "SubCat1" Then
                  Response.Write CreateSubCat1_List(RowCtr, strRSData)

               'Defect Codes
               ElseIf strRSName = "SubCat2" Then
                  Response.Write CreateSubCat2_List(RowCtr, strRSData)

               'Form Completed By
               ElseIf strRSName = "SubCat3" Then
                  Response.Write CreateSubCat3_List(RowCtr, strRSData)

               ElseIf strRSName = "ComponentNumber" Then

                  Response.Write "<td>Eaton Component P/N</td>"
                  Response.Write "<td>"
                  Response.Write "<input type='text' name='CN" & RowCtr & "' value = '" & strRSData & "'> &nbsp;"
                  Response.Write "Reference Designator <input type='text' name='RD" & RowCtr & "' value = '" & RS.Fields(Ctr + 1) & "'>"
                  Response.Write "</td>"


	       'The reference designator is on the same row as the component number.
               ElseIf strRSName = "ReferenceDesignator" Then


               ElseIf strRSName = "Remarks" Then
                  Response.Write "<td>Remarks</td>"
                  Response.Write "<td> <input type='text' name='R" & RowCtr & "' size = '60' value = '" & strRSData & "'> </td>"



               Else
                  Response.Write "<td>" & strRSName & "</td><td>" & strRSData & "</td>"
               End if

               Response.Write "</tr>"


            Next

            'Put in an extra row to allow more visual separation between units.
            Response.Write "<tr><td colspan=3 bgcolor='#C0C0C0'>&nbsp;</td></tr>"

            RS.MoveNext

         Loop


         Response.Write "</table>"

         'Save the ID numbers in a hidden form field so that can be passed to the next ASP.
         Response.Write "<input type='hidden' name='frmIDs' value = '" & strIDs & "'><br>"

         Response.Write "<input type='submit' value='Submit' name='B1'>"

         Response.Write "</form>"

         Response.Write "</center>"

	End If

End Sub




'--------------------------------------------------------------------------------------------------------
Function CreateDefectList(intPresentRow, strPresentDefectName)

   Dim strTemp
   Dim RS

   On Error Resume Next

   strTemp  = ""

   Set RS = Conn.Execute("Select * FROM drop_DefectCategories ORDER BY SortOrder")


   'Get all of the items in the defect category list.
   Do While Not RS.EOF

      'Start of an entry in the drop-down menu.
      strTemp = strTemp & "<option "

      'Highlight this menu item if its name already appears in the database.
      If strPresentDefectName = RS(0) Then
         strTemp = strTemp & "selected "
      End If

      'End of a drop-down menu item.
      strTemp = strTemp &	"value='" & RS(0) & "'>" &	RS(1) & "</option>"

      'Get the next defect category name.
      RS.MoveNext

   Loop

   'Put everything in a drop-down menu structure.
   CreateDefectList = "<td>Defect Category</td>" & _
                      "<td> <select name='D" & intPresentRow & "' size='1' maxlength='250'>" & strTemp & "</select> </td>"


End Function





'--------------------------------------------------------------------------------------------------------
Function CreateSubCat1_List(intPresentRow, strPresentDefectName)

   Dim strTemp
   Dim RS

   strTemp  = ""

   On Error Resume Next

   Set RS = Conn.Execute("Select * FROM drop_SubCat1 ORDER BY SortOrder")


   'Get all of the items in the defect category list.
   Do While Not RS.EOF

      'Start of an entry in the drop-down menu.
      strTemp = strTemp & "<option "

      'Highlight this menu item if its name already appears in the database.
      If strPresentDefectName = RS(0) Then
         strTemp = strTemp & "selected "
      End If

      'End of a drop-down menu item.
      strTemp = strTemp &	"value='" & RS(0) & "'>" &	RS(1) & "</option>"

      'Get the next defect category name.
      RS.MoveNext

   Loop

   'Put everything in a drop-down menu structure.
   CreateSubCat1_List =	"<td>Sub-Assy</td>" & _
                        "<td> <select name='S1_" & intPresentRow & "' size='1' maxlength='250'>" & strTemp & "</select> </td>"


End Function




'--------------------------------------------------------------------------------------------------------
Function CreateSubCat2_List(intPresentRow, strPresentDefectName)

   Dim strTemp
   Dim RS

   strTemp  = ""

   On Error Resume Next

   Set RS = Conn.Execute("Select * FROM drop_SubCat2 ORDER BY SortOrder")


   'Get all of the items in the defect category list.
   Do While Not RS.EOF

      'Start of an entry in the drop-down menu.
      strTemp = strTemp & "<option "

      'Highlight this menu item if its name already appears in the database.
      If strPresentDefectName = RS(0) Then
         strTemp = strTemp & "selected "
      End If

      'End of a drop-down menu item.
      strTemp = strTemp &	"value='" & RS(0) & "'>" & RS(1) & " - " & RS(2) & "</option>"

      'Get the next defect category name.
      RS.MoveNext

   Loop

   'Put everything in a drop-down menu structure.
   CreateSubCat2_List =	"<td>Defect Code</td>" & _
                        "<td> <select name='S2_" & intPresentRow & "' size='1' maxlength='250'>" & strTemp & "</select> </td>"


End Function



'--------------------------------------------------------------------------------------------------------
Function CreateSubCat3_List(intPresentRow, strPresentDefectName)

   Dim strTemp
   Dim RS

   strTemp  = ""

   On Error Resume Next

   Set RS = Conn.Execute("Select * FROM drop_SubCat3 ORDER BY SortOrder")


   'Get all of the items in the defect category list.
   Do While Not RS.EOF

      'Start of an entry in the drop-down menu.
      strTemp = strTemp & "<option "

      'Highlight this menu item if its name already appears in the database.
      If strPresentDefectName = RS(0) Then
         strTemp = strTemp & "selected "
      End If

      'End of a drop-down menu item.
      strTemp = strTemp &	"value='" & RS(0) & "'>" & RS(1) & "</option>"

      'Get the next defect category name.
      RS.MoveNext

   Loop

   'Put everything in a drop-down menu structure.
   CreateSubCat3_List =	"<td>Form Completed By</td>" & _
                        "<td> <select name='S3_" & intPresentRow & "' size='1' maxlength='250'>" & strTemp & "</select> </td>"


End Function



'--------------------------------------------------------------------------------------------------------
Function BuildQuery(UserSelection)

   Dim Query
   Dim UsersCriteria


   'Determine the user's critera for finding the records.
   Select Case UserSelection

      'Get all unanalyzed records.
      Case 0
         UsersCriteria = "AND (F.DefectCategory = 1) "

      'Get records for the specified time period
      Case 1

         UsersCriteria = "AND (F.DefectCategory = 1) AND (StartTime BETWEEN #" & Session("QueryStartDate") & "# AND #" & Session("QueryEndDate") & "#) "

      'Get records for a specific serial number.
      Case 2
         UsersCriteria = " AND I.SerialNumber = '" &  Request("frmSerialNumber") & "' "

      'Get records for a specific serial number and style number.
      Case 3
         UsersCriteria = " AND I.SerialNumber = '" & Request("frmSerialNumber2") & "' " & _
                         " AND I.PartNumber   = '" & Request("frmPartNumber") & "' "

      Case Else

         Response.Redirect "UDA_Login.Asp"

   End Select


   'Create the desired query.
   Query = "SELECT " & _
              "I.SerialNumber, " &_
              "P.Family, " & _
              "I.PartNumber, " & _
              "P.ModelNumber, " & _
              "I.StartTime, " &_
              "I.Seq, " & _
              "I.Workcell, " & _
              "I.Badge, " &_
              "F.ID, " &_
              "F.TestFailed, " &_
              "F.FailureDescription, " &_
              "F.DefectCategory, " &_
              "F.SubCat2, " &_
              "F.SubCat1, " &_
              "F.ComponentNumber, " &_
              "F.ReferenceDesignator, " &_
              "F.Remarks, " & _
              "F.SubCat3 " & _
           "FROM FailureInformation AS F, Index AS I, PartNumbers AS P " & _
           "WHERE (I.ID = F.ID) AND (I.PartNumber = P.PartNumber )" & UsersCriteria & _
	   "ORDER BY I.SerialNumber, I.StartTime"


   'Return the new query to the calling routine.
   BuildQuery = Query


End Function

%>
</body>
</html>
