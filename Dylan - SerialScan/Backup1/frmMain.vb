'----------------------------------------------------------------------------------------------------
' Revision History:
'
' Date          Revised By      Description
'
' 02/04/2014    R.Hunnings      Modified the get_box_label_name routine.
'
'----------------------------------------------------------------------------------------------------


Public Class frmMain
    Inherits System.Windows.Forms.Form


#Region " Windows Form Designer generated code "

    Public Sub New()
        MyBase.New()

        'This call is required by the Windows Form Designer.
        InitializeComponent()

        'Add any initialization after the InitializeComponent() call

    End Sub

    'Form overrides dispose to clean up the component list.
    Protected Overloads Overrides Sub Dispose(ByVal disposing As Boolean)
        If disposing Then
            If Not (components Is Nothing) Then
                components.Dispose()
            End If
        End If
        MyBase.Dispose(disposing)
    End Sub

    'Required by the Windows Form Designer
    Private components As System.ComponentModel.IContainer

    'NOTE: The following procedure is required by the Windows Form Designer
    'It can be modified using the Windows Form Designer.  
    'Do not modify it using the code editor.
    Friend WithEvents Label1 As System.Windows.Forms.Label
    Friend WithEvents txtSerial As System.Windows.Forms.TextBox
    Friend WithEvents cmdPrint As System.Windows.Forms.Button
    <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()
        Me.cmdPrint = New System.Windows.Forms.Button
        Me.Label1 = New System.Windows.Forms.Label
        Me.txtSerial = New System.Windows.Forms.TextBox
        Me.SuspendLayout()
        '
        'cmdPrint
        '
        Me.cmdPrint.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.75!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.cmdPrint.Location = New System.Drawing.Point(224, 120)
        Me.cmdPrint.Name = "cmdPrint"
        Me.cmdPrint.Size = New System.Drawing.Size(112, 32)
        Me.cmdPrint.TabIndex = 3
        Me.cmdPrint.Text = "&Print"
        '
        'Label1
        '
        Me.Label1.Font = New System.Drawing.Font("Microsoft Sans Serif", 15.75!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Label1.Location = New System.Drawing.Point(64, 48)
        Me.Label1.Name = "Label1"
        Me.Label1.Size = New System.Drawing.Size(208, 32)
        Me.Label1.TabIndex = 1
        Me.Label1.Text = "Scan Serial Number:"
        Me.Label1.TextAlign = System.Drawing.ContentAlignment.MiddleRight
        '
        'txtSerial
        '
        Me.txtSerial.Font = New System.Drawing.Font("Microsoft Sans Serif", 15.75!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.txtSerial.Location = New System.Drawing.Point(288, 48)
        Me.txtSerial.Name = "txtSerial"
        Me.txtSerial.Size = New System.Drawing.Size(224, 31)
        Me.txtSerial.TabIndex = 1
        '
        'frmMain
        '
        Me.AutoScaleBaseSize = New System.Drawing.Size(5, 13)
        Me.ClientSize = New System.Drawing.Size(576, 190)
        Me.Controls.Add(Me.txtSerial)
        Me.Controls.Add(Me.Label1)
        Me.Controls.Add(Me.cmdPrint)
        Me.Name = "frmMain"
        Me.Text = "Serial Scan with test record verification"
        Me.ResumeLayout(False)
        Me.PerformLayout()

    End Sub

#End Region

    Private Sub frmMain_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load

        PrevInstance()
        IniUpdate()
        DataOpen()
        btApp = CreateObject("BarTender.Application")
        btApp.Visible = False
        txtSerial.Focus()

    End Sub

    Public Function PrevInstance() As Boolean

        If Diagnostics.Process.GetProcessesByName(Diagnostics.Process.GetCurrentProcess.ProcessName).Length > 1 Then
            MsgBox("An Instance of this program is already running.", MsgBoxStyle.Critical, "Program Already Running")
            End
        End If

    End Function

    Public Sub DataOpen()

        cnData = New ADODB.Connection
        cnConnStr = ConnectString & DataBasePath & DataBaseName

        'cnConnStr = "ePDULabels"

        cnData.ConnectionString = cnConnStr
        Try
            cnData.Open()
        Catch
            MsgBox("Data Source could not be opened for " & vbCrLf & cnConnStr & vbCrLf & vbCrLf & Err.Description)
            Exit Sub
        End Try

    End Sub


    Public Sub IniUpdate()

        Dim CmdIniFile, fdir As String
        Dim rdata, c1, c2 As String

        If Len(App_Path) > 0 Then
            Path = App_Path()
        End If

        If CmdIniFile = "" Then
            IniFile = Path + "EatonSerialScan.Ini"
        Else
            IniFile = Trim(CmdIniFile)
            If InStr(1, IniFile, ".") = 0 Then
                IniFile = IniFile + ".INI"
            End If
            If InStr(1, IniFile, "\") = 0 Then
                IniFile = Path + "" + IniFile
            End If
        End If

        Call ReadIni("Setup", "DataBasePath", DataBasePath, IniFile)
        If DataBasePath = "" Then
            DataBasePath = Path & "Data\"
            Call WriteIni("Setup", "DataBasePath", DataBasePath, IniFile)
        End If
        Call ReadIni("Setup", "DataBaseName", DataBaseName, IniFile)
        If DataBaseName = "" Then
            DataBaseName = "EatonPWP300B.mdb"
            Call WriteIni("Setup", "DataBaseName", DataBaseName, IniFile)
        End If

        Call ReadIni("Setup", "ConnectString", ConnectString, IniFile)
        If ConnectString = "" Then
            'ConnectString = "Provider=Microsoft.Jet.OLEDB.4.0; Data Source = "
            ConnectString = "Driver={Microsoft Access Driver (*.mdb, *.accdb)};DBQ="
            Call WriteIni("Setup", "ConnectString", ConnectString, IniFile)
        End If

        Call ReadIni("SQL", "SQLString", SQLString, IniFile)
        If SQLString = "" Then
            SQLString = "SELECT [CONFIG], P, PLUS, MODNUM, SERIALREV, N6, N7, INVOLT, N9, INAMP, INHZ, N12, INPHASE, VDCNUM, DCAMP, OUTVOLT, N17, OUTKW, OUTKVA, OUTAMP, OUTPHASE, OUTHZ, CABTOT, [INPUT], TRANS, TRANS2, AGENCY1, AGENCY2, UPSTYPE1, UPSTYPE2, BYPASS, INAMP2, BYPVOLT, BYPAMP, BYPHZ, BYPPHASE, BYPKVA, " & _
            "AGENCY3, LABELSTRING, SERIALTYPE, MULTILABEL, SerialProcess, FULLCTO, SYSTR, UPSTYPE, INA, Serial FROM tblArchive"
            Call WriteIni("SQL", "SQLString", SQLString, IniFile)
        End If
        Call ReadIni("Labels", "LabDir", LabDir, IniFile)
        If LabDir = "" Then
            LabDir = Path & "Labels\"
            Call WriteIni("Labels", "LabDir", LabDir, IniFile)
        End If
        Call ReadIni("Labels", "BoxLabel", BoxLabel, IniFile)
        If BoxLabel = "" Then
            BoxLabel = "BoxLabel.btw"
            Call WriteIni("Labels", "BoxLabel", BoxLabel, IniFile)
        End If

        Call ReadIni("Printer", "Printer", Printer, IniFile)
        If Printer = "" Then
            Printer = "Adobe PDF"
            Call WriteIni("Printer", "Printer", Printer, IniFile)
        End If


    End Sub

    Private Sub txtSerial_KeyPress(ByVal sender As Object, ByVal e As System.Windows.Forms.KeyPressEventArgs) Handles txtSerial.KeyPress
        If e.KeyChar = Chr(13) Then
            If txtSerial.Text <> "" Then
                cmdPrint.PerformClick()
            Else
                Exit Sub
            End If
        End If
    End Sub


    Private Function has_test_record(ByVal serial_number As String) As Boolean

        Dim rs As New ADODB.Recordset
        Dim sql As String
        Dim mss As String

        Try
            'Create a query to determine if this unit has a test record.
            sql = "SELECT * FROM tblArchive WHERE Serial = '" & serial_number & "' AND has_test_record = true"

            rs.Open(sql, cnData, ADODB.CursorTypeEnum.adOpenDynamic, ADODB.LockTypeEnum.adLockOptimistic)

            'If no record exists for this unit then do not allow a label to be printed.
            If rs.EOF = True Then
                mss = MsgBox("The serial number " & serial_number & " does not have a test record.", MsgBoxStyle.Information, "NO TEST RECORD")
                txtSerial.Text = ""
                txtSerial.Focus()
                Return False
            End If

        Catch ex As Exception

        End Try


        'The unit has a test record.
        Return True

    End Function


    Private Function all_defect_reports_are_complete(ByVal serial_number As String) As Boolean

        Dim rs As New ADODB.Recordset
        Dim sql As String
        Dim msg As String

        Try
            'Create a query to determine if this unit has an open defect report.
            sql = "SELECT * FROM tblArchive WHERE Serial = '" & serial_number & "' AND has_open_defect_report = true"

            rs.Open(sql, cnData, ADODB.CursorTypeEnum.adOpenDynamic, ADODB.LockTypeEnum.adLockOptimistic)

            'If a defect report exists for this unit then do not allow a label to be printed.
            If Not rs.EOF Then
                MsgBox("The serial number " & serial_number & " has an open defect report.", MsgBoxStyle.Information, "OPEN DEFECT REPORT")
                txtSerial.Text = ""
                txtSerial.Focus()
                Return False
            End If

        Catch ex As Exception
            msg = "Error in the all_defect_reports_are_complete routine" & vbCrLf & vbCrLf & ex.Message
            MessageBox.Show(msg, "ERROR")
            Return False
        End Try

        Return True

    End Function





    '----------------------------------------------------------------------------------------------------
    ' Routine name: get_box_label_name
    '
    ' Parameters:   PartNumber - the part number of the unit for which the label is to be printed.
    '
    ' Returns:      The name of the label template that is to be used.
    '
    ' Revision History:
    '
    ' Date          Revised By      Description
    '
    ' 02/04/2014    R.Hunnings      Per Lenson Bellamy, changed this routine to use the BoxLabel field
    '                               from tblMain. 
    '----------------------------------------------------------------------------------------------------
    Private Function get_box_label_name(ByVal PartNumber As String) As String


        Dim msg As String
        Dim sql As String
        Dim rs As New ADODB.Recordset

        'Use the default name unless one is listed in the database for this part number.
        Dim label_name As String = BoxLabel

        'Build query to get the label name.
        'sql = "SELECT * FROM tblBoxLabelSetup WHERE PartNumber = '" & PartNumber & "'"
        sql = "SELECT * FROM tblMain WHERE CONFIG = '" & PartNumber & "'"

        Try
            'Get the data from the database
            rs.Open(sql, cnData, ADODB.CursorTypeEnum.adOpenDynamic, ADODB.LockTypeEnum.adLockOptimistic)

            'If a label name is listed for this part number, then use it.
            If Not rs.EOF Then
                'label_name = rs("LabelName").Value
                label_name = rs("BoxLabel").Value
            End If

        Catch ex As Exception
            msg = "Error in the get_box_label_name routine" & vbCrLf & vbCrLf & ex.Message
            MessageBox.Show(msg, "ERROR")
            Return False
        End Try

        Return label_name

    End Function



    Private Sub cmdPrint_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdPrint.Click

        Dim i, j As Integer
        Dim msg As String
        Dim sql As String
        Dim BoxLabelName As String


        Try
            rsdata = New ADODB.Recordset
            sql = SQLString & " WHERE Serial = '" & txtSerial.Text & "';"
            rsdata.Open(sql, cnData, ADODB.CursorTypeEnum.adOpenDynamic, ADODB.LockTypeEnum.adLockOptimistic)

            'Error checks for quantity and data
            'If txtQty.Text = "" Then
            '    mss = MsgBox("You have not entered a print quantity", MsgBoxStyle.Information, "PRINT QUANTITY MISSING")
            '    txtQty.Focus()
            '    sql = ""
            '    Exit Sub
            'End If

            If rsdata.EOF = True Then
                MsgBox("The Serial " & txtSerial.Text & " Can not be found in the tblArchive table, please see your supervisor.", MsgBoxStyle.Information, "SERIAL NOT FOUND")
                txtSerial.Text = ""
                txtSerial.Focus()
                sql = ""
                Exit Sub
            End If

            'Verify that a test record exists for this serial number.
            If has_test_record(txtSerial.Text) = False Then Exit Sub

            'Verify that any defect report has been closed.
            If all_defect_reports_are_complete(txtSerial.Text) = False Then Exit Sub

            'Determine which label template to use.
            BoxLabelName = get_box_label_name(rsdata("CONFIG").Value)

            btLab = btApp.Formats.Open(LabDir & BoxLabelName)
            btLab.Printer = Printer

            For i = 0 To rsdata.Fields.Count - 1
                'MsgBox (drConnect.Recordset.Fields(i).Name)
                If Not IsDBNull(rsdata.Fields(i).Value) Then
                    For j = 1 To btLab.NamedSubStrings.Count
                        'MsgBox (btLab.NamedSubStrings.Item(j).Name)
                        If btLab.NamedSubStrings.Item(j).Name = rsdata.Fields(i).Name Then
                            btLab.NamedSubStrings.Item(j).Value = rsdata.Fields(i).Value
                        End If
                    Next j
                End If
            Next i

            'Print out label
            'btLab.IdenticalCopiesOfLabel = txtQty.Text
            btLab.PrintOut()
            btLab.Close(BarTender.BtSaveOptions.btDoNotSaveChanges)

            'Clear Serial Box for entry
            txtSerial.Text = ""
            txtSerial.Focus()

        Catch ex As Exception
            msg = "Error in the cmdPrint routine" & vbCrLf & vbCrLf & ex.Message
            MessageBox.Show(msg, "ERROR")
            txtSerial.Text = ""
            txtSerial.Focus()
            sql = ""
        End Try


    End Sub

    Private Sub frmMain_Closed(ByVal sender As Object, ByVal e As System.EventArgs) Handles MyBase.Closed

        btApp.Quit(BarTender.BtSaveOptions.btDoNotSaveChanges)

    End Sub

    Private Sub txtQty_KeyPress(ByVal sender As System.Object, ByVal e As System.Windows.Forms.KeyPressEventArgs)

        If Asc(e.KeyChar) > 25 Then
            If Asc(e.KeyChar) < 48 Or Asc(e.KeyChar) > 57 Then
                MessageBox.Show("Number entry only")
                e.Handled = True
            Else
                e.Handled = False
            End If
        End If

        If Asc(e.KeyChar) = 13 Then
            cmdPrint.PerformClick()
        End If

    End Sub
End Class
