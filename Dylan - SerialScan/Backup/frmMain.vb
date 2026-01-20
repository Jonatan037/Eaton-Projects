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
        Me.txtSerial.Text = ""
        '
        'frmMain
        '
        Me.AutoScaleBaseSize = New System.Drawing.Size(5, 13)
        Me.ClientSize = New System.Drawing.Size(576, 190)
        Me.Controls.Add(Me.txtSerial)
        Me.Controls.Add(Me.Label1)
        Me.Controls.Add(Me.cmdPrint)
        Me.Name = "frmMain"
        Me.Text = "Serial Scan"
        Me.ResumeLayout(False)

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
        cnData.ConnectionString = cnConnStr
        Try
            cnData.Open()
        Catch
            MsgBox("Data Source could not be opened.")
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
            ConnectString = "Provider=Microsoft.Jet.OLEDB.4.0; Data Source = "
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

    Private Sub cmdPrint_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdPrint.Click
        Dim i, j As Integer
        Dim mss, sql As String

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
            mss = MsgBox("The Serial " & txtSerial.Text & " Can not be found in the tblArchive table, please see your supervisor.", MsgBoxStyle.Information, "SERIAL NOT FOUND")
            txtSerial.Text = ""
            txtSerial.Focus()
            sql = ""
            Exit Sub
        End If

        btLab = btApp.Formats.Open(LabDir & BoxLabel)
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
