'-------------------------------------------------------------------------------------------
' Module:   DPQ
'
' Purpose:  Handles all of the details necessary for creating a serial number
'           based on the DPQ scheme.
'
'
' Notes:
'
'               ------------------ Revision History ------------------
'
'    Date       Modified By     Changes Made
' ----------    -----------     ------------
' 01/11/2014    R.Hunnings      Original writing.
'
' 03/11/2014    R.Hunnings      Modified the determine_shark_technology_type routine.
'
'-------------------------------------------------------------------------------------------
Option Explicit On

Module DPQ


    '----------------------------------------------------------------------------------------------------------------
    ' Routine: create_dpq_serial_number 
    '
    ' Purpose: Create a formatted serial number based on the DPQ serial number scheme.
    '
    ' Parameters: rs_main - a recordset that contains the data from the tblMain table.
    '
    ' Returns: the serial number if no errors occurred, otherwise and empty string is returned.
    '
    '
    '               ------------------ Revision History ------------------
    '
    '    Date       Modified By     Changes Made
    ' ----------    -----------     ------------
    ' 01/11/2014    R.Hunnings      Original writing.
    '
    '----------------------------------------------------------------------------------------------------------------
    Public Function create_dpq_serial_number(ByRef rs_main As ADODB.Recordset) As String

        Dim year_code As String
        Dim work_week As Integer
        Dim week_count As Integer
        Dim week_count_formatted As String
        Dim location_code As String
        Dim product_id As String
        Dim product_type As String
        Dim msg As String


        Try

            'Default values.
            create_dpq_serial_number = ""
            year_code = ""
            week_count_formatted = ""
            location_code = ""

            'Get the product type from the recordset for the tblMain table.
            product_type = rs_main("P").Value

            'Get the product identification from the recordset for the tblMain table.
            product_id = rs_main("ProductID").Value

            'get the manufacturing location.
            If Not get_location_code(product_type, location_code) Then Return ""

            'Get the week info. Return an empty string if an error occurred
            If Not get_week_info(year_code, work_week, week_count) Then Return ""

            'Get the formatted week count.
            If Not get_formatted_week_count(week_count, week_count_formatted) Then Return ""

            'Determine the text to be shown in the technology type field.
            determine_shark_technology_type(rs_main)

            'Create the formatted serial number
            Return location_code & product_id & year_code & Format(work_week, "00") & week_count_formatted

        Catch ex As Exception
            msg = "Error occurred in the DPQ.create_dpq_serial_number() routine" & vbCrLf & vbCrLf & ex.Message
            MessageBox.Show(msg, "ERROR")
            Return ""
        End Try

    End Function



    '----------------------------------------------------------------------------------------------------------------
    ' Routine: get_week_info 
    '
    ' Purpose: Get the work week information from the DPQ_WeekInformation table.
    '          
    '
    ' Parameters:   year_code  - this value will be returned to the calling routine.
    '               work_week  - this value will be returned to the calling routine.
    '               week_count - this value will be returned to the calling routine.
    '
    ' Returns:      True if the information was retreived from the table, false otherwise.
    '
    '
    '               ------------------ Revision History ------------------
    '
    '    Date       Modified By     Changes Made
    ' ----------    -----------     ------------
    ' 01/11/2014    R.Hunnings      Original writing.
    '
    '----------------------------------------------------------------------------------------------------------------
    Private Function get_week_info(ByRef year_code As String, ByRef work_week As Integer, ByRef week_count As Integer) As Boolean

        Dim msg As String
        Dim sql As String

        'Default value
        get_week_info = False

        Try

            Dim rsWeek As New ADODB.Recordset

            'Get the information from the table for today's date.
            sql = "SELECT * FROM DPQ_WeekInformation WHERE #" & Today & "# BETWEEN WeekBeginning AND (WeekBeginning + 6)"

            rsWeek.Open(sql, cnData, ADODB.CursorTypeEnum.adOpenDynamic, ADODB.LockTypeEnum.adLockOptimistic)

            If rsWeek.EOF Then

                msg = "There is not an entry in the DPQ_WeekInformation table for this week." & vbCrLf & vbCrLf & _
                      "Please notify your supervisor."

                MessageBox.Show(msg, "DPQ_WeekInformation ERROR")

                rsWeek.Close()

                Return False

            Else
                'Get the week values
                work_week = rsWeek("WorkWeek").Value
                week_count = rsWeek("WeeklyBuildCount").Value
                year_code = rsWeek("YearCode").Value

                'Increment the week count.
                week_count = week_count + 1

                'Update the database
                rsWeek("WeeklyBuildCount").Value = week_count
                rsWeek.Update()
                rsWeek.Close()

            End If

        Catch ex As Exception
            msg = "Error occurred in the DPQ.get_week_info() routine" & vbCrLf & vbCrLf & ex.Message
            MessageBox.Show(msg, "ERROR")
            Return False
        End Try

        'Success
        Return True

    End Function


    '----------------------------------------------------------------------------------------------------------------
    ' Routine:  get_formatted_week_count
    '
    ' Purpose:  Get the special formatted value for the week count from the DPQ_UnitCountFormats table.
    '
    ' Parameters: week_count -  the value to be formatted.
    '             week_count_formatted - the formatted value to be returned to the calling routine.
    '
    ' Returns:  True if the week_count value was formatted properly, false otherwise.
    '
    '
    '               ------------------ Revision History ------------------
    '
    '    Date       Modified By     Changes Made
    ' ----------    -----------     ------------
    ' 01/11/2014    R.Hunnings      Original writing.
    '
    '----------------------------------------------------------------------------------------------------------------
    Private Function get_formatted_week_count(ByRef week_count As Integer, ByRef week_count_formatted As String) As Boolean

        Dim msg As String
        Dim sql As String

        'Default return value
        get_formatted_week_count = False

        Try
            Dim rs As New ADODB.Recordset

            'Create a recordset containing the commodity code information for this part number.
            sql = "SELECT CountFormat FROM DPQ_UnitCountFormats WHERE UnitCount = " & week_count

            rs.Open(sql, cnData, ADODB.CursorTypeEnum.adOpenDynamic, ADODB.LockTypeEnum.adLockOptimistic)

            If rs.EOF Then

                msg = "There is not an entry in the DPQ_UnitCountFormats table for count = " & week_count & vbCrLf & vbCrLf & _
                      "Please notify your supervisor."

                MessageBox.Show(msg, "DPQ_get_formatted_week_count ERROR")

                rs.Close()

                Return False

            Else
                'Get the formatted count value.
                week_count_formatted = rs("CountFormat").Value

                rs.Close()

            End If

        Catch ex As Exception
            msg = "Error occurred in the DPQ.get_formatted_week_count() routine" & vbCrLf & vbCrLf & ex.Message
            MessageBox.Show(msg, "ERROR")
            Return False
        End Try

        'Success
        Return True

    End Function


    '----------------------------------------------------------------------------------------------------------------
    ' Routine:  get_location_code
    '
    ' Purpose:  Get the location code for this product from the tblCode table.
    '
    ' Parameters: product_type - the value to be used as a selection criteria.
    '             location_code - the value to be returned to the calling routine.
    '
    ' Returns:  True if the location code was retreived from the table, false otherwise.
    '
    '
    '               ------------------ Revision History ------------------
    '
    '    Date       Modified By     Changes Made
    ' ----------    -----------     ------------
    ' 01/11/2014    R.Hunnings      Original writing.
    '
    '----------------------------------------------------------------------------------------------------------------
    Private Function get_location_code(ByVal product_type As String, ByRef location_code As String) As Boolean

        Dim msg As String
        Dim sql As String

        'Query to get the location code from the tblCode table.
        sql = "SELECT LocationCode FROM tblCode WHERE ProductCode = '" & product_type & "'"

        Try

            Dim rs As New ADODB.Recordset

            rs.Open(sql, cnData, ADODB.CursorTypeEnum.adOpenDynamic, ADODB.LockTypeEnum.adLockOptimistic)

            If rs.EOF Then

                msg = "There is not an entry in the tblCode table for ProductCode = " & product_type & vbCrLf & vbCrLf & sql & vbCrLf & vbCrLf & _
                      "Please notify your supervisor."

                MessageBox.Show(msg, "Error occurred in the DPQ.get_plant_code() routine")

                rs.Close()

                Return False

            Else
                'Get the plant code.
                location_code = rs("LocationCode").Value

                rs.Close()

            End If

        Catch ex As Exception
            msg = "Error occurred in the DPQ.get_plant_code() routine" & vbCrLf & vbCrLf & sql & vbCrLf & vbCrLf & ex.Message
            MessageBox.Show(msg, "ERROR")
            Return False
        End Try

        'Success
        Return True

    End Function


    '----------------------------------------------------------------------------------------------------------------
    ' Routine:  determine_shark_technology_type
    '
    ' Purpose:  Determine the technology type for a SHARK unit based on character 2 and 3 of
    '           the CONFIG number. 
    '
    ' Parameters: rs_main - a recordset that contains the data from the tblMain table.
    '
    ' Returns:  If a new tecnology type is defined for this unit then it will be inserted into the
    '           rs_main("TechnologyType")field.
    '
    '
    '               ------------------ Revision History ------------------
    '
    '    Date       Modified By     Changes Made
    ' ----------    -----------     ------------
    ' 01/11/2014    R.Hunnings      Original writing.
    '
    ' 03/11/2014    R.Hunnings      For config_number and product_type, trim and cast to upper case before using
    '                               in comparision statements.
    '
    '----------------------------------------------------------------------------------------------------------------
    Sub determine_shark_technology_type(ByRef rs_main As ADODB.Recordset)

        Dim technology_type As String
        Dim config_number As String
        Dim product_type As String


        Dim msg As String


        Try

            technology_type = rs_main("TechnologyType").Value

            'Stop here if a value is already defined for the technology type.
            If technology_type <> "NONE" Then Exit Sub

            'Get the config number, trimmed and cast to upper case.
            config_number = UCase(Trim(rs_main("CONFIG").Value))

            'Get the product type, trimmed and cast to upper case.
            product_type = UCase(Trim(rs_main("P").Value))


            'Must have a "SHARK" product type and a CONFIG number with 15 characters to be a SHARK unit.
            If product_type <> "SHARK" Or Len(config_number) <> 15 Then Exit Sub

            Select Case Mid(config_number, 2, 2)

                Case "BA"
                    technology_type = "Basic"

                Case "MI"
                    technology_type = "Metered Input"

                Case "IL"
                    technology_type = "In-Line Metered"

                Case "MO"
                    technology_type = "Metered Outlets"

                Case "SW"
                    technology_type = "Switched"

                Case "MA"
                    technology_type = "Managed"

                Case Else
                    Exit Sub
            End Select

            'Assign the new technology type back to the recordset.
            rs_main("TechnologyType").Value = technology_type

        Catch ex As Exception
            msg = "Error occurred in the DPQ.determine_shark_technology_type() routine" & vbCrLf & vbCrLf & ex.Message
            MessageBox.Show(msg, "ERROR")
            Exit Sub
        End Try


    End Sub


End Module
