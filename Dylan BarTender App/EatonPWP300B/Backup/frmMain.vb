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
    Friend WithEvents txtCTO As System.Windows.Forms.TextBox
    Friend WithEvents cmdProcess As System.Windows.Forms.Button
    Friend WithEvents Label2 As System.Windows.Forms.Label
    Friend WithEvents txtSYSTR As System.Windows.Forms.TextBox
    Friend WithEvents frmFour As System.Windows.Forms.GroupBox
    Friend WithEvents cmdPrint As System.Windows.Forms.Button
    Friend WithEvents cmdCancel As System.Windows.Forms.Button
    Friend WithEvents rdoOldSerialRLNum As System.Windows.Forms.RadioButton
    Friend WithEvents rdoNewRLNum As System.Windows.Forms.RadioButton
    Friend WithEvents rdoOldSerialNum As System.Windows.Forms.RadioButton
    Friend WithEvents rdoNewLabel As System.Windows.Forms.RadioButton
    Friend WithEvents txtPrintQty As System.Windows.Forms.TextBox
    Friend WithEvents Label3 As System.Windows.Forms.Label
    <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()
        Dim resources As System.Resources.ResourceManager = New System.Resources.ResourceManager(GetType(frmMain))
        Me.Label1 = New System.Windows.Forms.Label
        Me.txtCTO = New System.Windows.Forms.TextBox
        Me.cmdProcess = New System.Windows.Forms.Button
        Me.Label2 = New System.Windows.Forms.Label
        Me.txtSYSTR = New System.Windows.Forms.TextBox
        Me.frmFour = New System.Windows.Forms.GroupBox
        Me.rdoOldSerialRLNum = New System.Windows.Forms.RadioButton
        Me.rdoNewRLNum = New System.Windows.Forms.RadioButton
        Me.rdoOldSerialNum = New System.Windows.Forms.RadioButton
        Me.rdoNewLabel = New System.Windows.Forms.RadioButton
        Me.cmdPrint = New System.Windows.Forms.Button
        Me.cmdCancel = New System.Windows.Forms.Button
        Me.txtPrintQty = New System.Windows.Forms.TextBox
        Me.Label3 = New System.Windows.Forms.Label
        Me.frmFour.SuspendLayout()
        Me.SuspendLayout()
        '
        'Label1
        '
        Me.Label1.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.75!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Label1.Location = New System.Drawing.Point(8, 16)
        Me.Label1.Name = "Label1"
        Me.Label1.Size = New System.Drawing.Size(216, 16)
        Me.Label1.TabIndex = 0
        Me.Label1.Text = "Please enter the full CTO Number:"
        '
        'txtCTO
        '
        Me.txtCTO.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.75!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.txtCTO.Location = New System.Drawing.Point(232, 16)
        Me.txtCTO.MaxLength = 15
        Me.txtCTO.Name = "txtCTO"
        Me.txtCTO.Size = New System.Drawing.Size(152, 22)
        Me.txtCTO.TabIndex = 1
        Me.txtCTO.Text = ""
        '
        'cmdProcess
        '
        Me.cmdProcess.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.75!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.cmdProcess.Location = New System.Drawing.Point(408, 16)
        Me.cmdProcess.Name = "cmdProcess"
        Me.cmdProcess.Size = New System.Drawing.Size(64, 24)
        Me.cmdProcess.TabIndex = 2
        Me.cmdProcess.Text = "Find"
        '
        'Label2
        '
        Me.Label2.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.75!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Label2.Location = New System.Drawing.Point(8, 64)
        Me.Label2.Name = "Label2"
        Me.Label2.Size = New System.Drawing.Size(384, 16)
        Me.Label2.TabIndex = 3
        Me.Label2.Text = "Please enter the system tracking number (7 digits without the -)"
        Me.Label2.Visible = False
        '
        'txtSYSTR
        '
        Me.txtSYSTR.Location = New System.Drawing.Point(392, 64)
        Me.txtSYSTR.MaxLength = 7
        Me.txtSYSTR.Name = "txtSYSTR"
        Me.txtSYSTR.Size = New System.Drawing.Size(80, 20)
        Me.txtSYSTR.TabIndex = 3
        Me.txtSYSTR.Text = ""
        Me.txtSYSTR.Visible = False
        '
        'frmFour
        '
        Me.frmFour.Controls.Add(Me.rdoOldSerialRLNum)
        Me.frmFour.Controls.Add(Me.rdoNewRLNum)
        Me.frmFour.Controls.Add(Me.rdoOldSerialNum)
        Me.frmFour.Controls.Add(Me.rdoNewLabel)
        Me.frmFour.Location = New System.Drawing.Point(16, 104)
        Me.frmFour.Name = "frmFour"
        Me.frmFour.Size = New System.Drawing.Size(456, 176)
        Me.frmFour.TabIndex = 7
        Me.frmFour.TabStop = False
        Me.frmFour.Text = "Label Print Options"
        Me.frmFour.Visible = False
        '
        'rdoOldSerialRLNum
        '
        Me.rdoOldSerialRLNum.Location = New System.Drawing.Point(16, 136)
        Me.rdoOldSerialRLNum.Name = "rdoOldSerialRLNum"
        Me.rdoOldSerialRLNum.Size = New System.Drawing.Size(416, 24)
        Me.rdoOldSerialRLNum.TabIndex = 3
        Me.rdoOldSerialRLNum.Text = "Reprint a label that already has a serial number and has a custom RL number."
        '
        'rdoNewRLNum
        '
        Me.rdoNewRLNum.Location = New System.Drawing.Point(16, 96)
        Me.rdoNewRLNum.Name = "rdoNewRLNum"
        Me.rdoNewRLNum.Size = New System.Drawing.Size(312, 32)
        Me.rdoNewRLNum.TabIndex = 2
        Me.rdoNewRLNum.Text = "Print a label that has a custom RL number."
        '
        'rdoOldSerialNum
        '
        Me.rdoOldSerialNum.Location = New System.Drawing.Point(16, 56)
        Me.rdoOldSerialNum.Name = "rdoOldSerialNum"
        Me.rdoOldSerialNum.Size = New System.Drawing.Size(312, 32)
        Me.rdoOldSerialNum.TabIndex = 1
        Me.rdoOldSerialNum.Text = "Reprint a label that already has a serial number."
        '
        'rdoNewLabel
        '
        Me.rdoNewLabel.Location = New System.Drawing.Point(16, 24)
        Me.rdoNewLabel.Name = "rdoNewLabel"
        Me.rdoNewLabel.Size = New System.Drawing.Size(312, 24)
        Me.rdoNewLabel.TabIndex = 0
        Me.rdoNewLabel.Text = "Print a new label."
        '
        'cmdPrint
        '
        Me.cmdPrint.Location = New System.Drawing.Point(256, 312)
        Me.cmdPrint.Name = "cmdPrint"
        Me.cmdPrint.Size = New System.Drawing.Size(72, 24)
        Me.cmdPrint.TabIndex = 8
        Me.cmdPrint.Text = "Print"
        Me.cmdPrint.Visible = False
        '
        'cmdCancel
        '
        Me.cmdCancel.Location = New System.Drawing.Point(368, 312)
        Me.cmdCancel.Name = "cmdCancel"
        Me.cmdCancel.Size = New System.Drawing.Size(72, 24)
        Me.cmdCancel.TabIndex = 9
        Me.cmdCancel.Text = "Cancel"
        '
        'txtPrintQty
        '
        Me.txtPrintQty.Location = New System.Drawing.Point(176, 312)
        Me.txtPrintQty.Name = "txtPrintQty"
        Me.txtPrintQty.Size = New System.Drawing.Size(56, 20)
        Me.txtPrintQty.TabIndex = 11
        Me.txtPrintQty.Text = "1"
        Me.txtPrintQty.Visible = False
        '
        'Label3
        '
        Me.Label3.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.75!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Label3.Location = New System.Drawing.Point(16, 312)
        Me.Label3.Name = "Label3"
        Me.Label3.Size = New System.Drawing.Size(136, 16)
        Me.Label3.TabIndex = 12
        Me.Label3.Text = "Enter Print Quantity"
        Me.Label3.Visible = False
        '
        'frmMain
        '
        Me.AutoScaleBaseSize = New System.Drawing.Size(5, 13)
        Me.ClientSize = New System.Drawing.Size(496, 358)
        Me.Controls.Add(Me.Label3)
        Me.Controls.Add(Me.txtPrintQty)
        Me.Controls.Add(Me.txtSYSTR)
        Me.Controls.Add(Me.txtCTO)
        Me.Controls.Add(Me.cmdCancel)
        Me.Controls.Add(Me.cmdPrint)
        Me.Controls.Add(Me.frmFour)
        Me.Controls.Add(Me.Label2)
        Me.Controls.Add(Me.cmdProcess)
        Me.Controls.Add(Me.Label1)
        Me.Icon = CType(resources.GetObject("$this.Icon"), System.Drawing.Icon)
        Me.Name = "frmMain"
        Me.Text = "Three Phase Product Labels"
        Me.frmFour.ResumeLayout(False)
        Me.ResumeLayout(False)

    End Sub

#End Region

    Private Sub Form1_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load

        F1 = Me
        PrevInstance()
        IniUpdate()
        btApp = CreateObject("BarTender.Application")
        btApp.Visible = False

    End Sub
    Public Sub IniUpdate()

        Dim CmdIniFile, fdir As String
        Dim rdata, c1, c2 As String

        If Len(App_Path) > 0 Then
            Path = App_Path()
        End If

        If CmdIniFile = "" Then
            IniFile = Path + "EatonLabels.Ini"
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
        Call ReadIni("Setup", "PssWrd", PssWrd, IniFile)
        If PssWrd = "" Then
            PssWrd = "Raleigh"
            Call WriteIni("Setup", "PssWrd", PssWrd, IniFile)
        End If
        Call ReadIni("SQL", "SQLString", SQLString, IniFile)
        If SQLString = "" Then
            SQLString = "SELECT [CONFIG], P, PLUS, MODNUM, SERIALREV, N6, N7, INVOLT, N9, INAMP, INHZ, N12, INPHASE, VDCNUM, DCAMP, OUTVOLT, N17, OUTKW, OUTKVA, OUTAMP, OUTPHASE, OUTHZ, CABTOT, [INPUT], TRANS, TRANS2, AGENCY1, AGENCY2, UPSTYPE1, UPSTYPE2, BYPASS, INAMP2, BYPVOLT, BYPAMP, BYPHZ, BYPPHASE, BYPKVA, " & _
            "AGENCY3, LABELSTRING, SERIALTYPE, MULTILABEL, SerialProcess FROM tblMain"
            Call WriteIni("SQL", "SQLString", SQLString, IniFile)
        End If
        Call ReadIni("SQL", "SQLWrite", SQLWrite, IniFile)
        If SQLWrite = "" Then
            SQLWrite = "SELECT [CONFIG], P, PLUS, MODNUM, SERIALREV, N6, N7, INVOLT, N9, INAMP, INHZ, N12, INPHASE, VDCNUM, DCAMP, OUTVOLT, N17, OUTKW, OUTKVA, OUTAMP, OUTPHASE, OUTHZ, CABTOT, [INPUT], TRANS, TRANS2, AGENCY1, AGENCY2, UPSTYPE1, UPSTYPE2, BYPASS, INAMP2, BYPVOLT, BYPAMP, BYPHZ, BYPPHASE, BYPKVA, " & _
            "AGENCY3, LABELSTRING, SERIALTYPE, MULTILABEL, SerialProcess, FULLCTO, SYSTR, UPSTYPE, INA, Serial FROM tblArchive"
            Call WriteIni("SQL", "SQLWrite", SQLWrite, IniFile)
        End If
        Call ReadIni("Labels", "LabDir", LabDir, IniFile)
        If LabDir = "" Then
            LabDir = Path & "Labels\"
            Call WriteIni("Labels", "LabDir", LabDir, IniFile)
        End If

    End Sub
    Public Sub SerialStats()
        Dim YrSql, YrStr1, WkStr, YrCode, DyStr, CodeSql, DaySql, SerSql, chkDDD, Mbox, dayChk, nxtYr, nxtDy, dayYr, curYr As String
        Dim newYr, Holder As Date
        Dim x As Integer

        cnData = New ADODB.Connection
        cnConnStr = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" & DataBasePath & DataBaseName
        cnData.ConnectionString = cnConnStr
        Try
            cnData.Open()
        Catch
            MsgBox("Data Source could not be opened.")
            Exit Sub
        End Try

        curYr = Format(Today.AddYears(1), "yyyy")
        Holder = "#12/31/" & curYr & "#"
        'Check for first day of year using week to advance or not advance year, first day other than Monday
        If DatePart(DateInterval.WeekOfYear, Today, FirstDayOfWeek.Monday, FirstWeekOfYear.Jan1) = DatePart(DateInterval.WeekOfYear, Holder, FirstDayOfWeek.Monday, FirstWeekOfYear.Jan1) Then
            'nxtYr = Format(Today.AddYears(1), "yyyy")
            'newYr = "1/01/" & nxtYr
            For x = 1 To 7

                nxtDy = Format(Today.AddDays(-x), "MM/dd/yyyy")
                Holder = nxtDy
                DyStr = DatePart(DateInterval.Weekday, Holder, FirstDayOfWeek.Monday, FirstWeekOfYear.Jan1)
                If DyStr = 1 Then
                    dayYr = Format(Today.AddDays(-x), "MM/dd/yyyy")
                    If dayYr = Format(Today, "MM/dd/yyyy") Then
                        YrStr1 = DatePart(DateInterval.Year, Today, FirstDayOfWeek.Monday, FirstWeekOfYear.Jan1)
                    Else
                        YrStr1 = Format(Today.AddYears(1), "yyyy")
                    End If
                End If

            Next x
        Else
            YrStr1 = DatePart(DateInterval.Year, Today, FirstDayOfWeek.Monday, FirstWeekOfYear.Jan1)
        End If

        YrSql = "SELECT [Code] FROM tblYearCode WHERE [Year]='" & YrStr1 & "';"
        rsdata4 = New ADODB.Recordset
        rsdata4.Open(YrSql, cnData, ADODB.CursorTypeEnum.adOpenDynamic, ADODB.LockTypeEnum.adLockOptimistic)
        YrCode = rsdata4.Fields.Item("Code").Value
        WkStr = DatePart(DateInterval.WeekOfYear, Today, FirstDayOfWeek.Monday, FirstWeekOfYear.System)
        If Val(Trim(WkStr)) > 52 Then WkStr = "1"
        If Len(WkStr) = 1 Then WkStr = "0" & Trim(WkStr)
        DyStr = DatePart(DateInterval.Weekday, Today, FirstDayOfWeek.Monday, FirstWeekOfYear.Jan1)

        CodeSql = "SELECT ProductCode, [Label Quantity], LocationCode, ProdSer, RevCode, RevCode1, RevCode2, Question, [Serial Code] FROM tblCode WHERE ProductCode='" & ProdType & "';"

        rsdata5 = New ADODB.Recordset
        rsdata5.Open(CodeSql, cnData, ADODB.CursorTypeEnum.adOpenDynamic, ADODB.LockTypeEnum.adLockOptimistic)

        If Not IsDBNull(rsdata.Fields.Item("SERIALREV").Value) And rsdata.Fields.Item("SERIALREV").Value = "Yes" Then

            If f4 Is Nothing Then
                f4 = New frmQuestion
                f4.ShowDialog()
                f4 = Nothing
            End If

        Else

            RevCode = rsdata5.Fields.Item("RevCode").Value

        End If

        LocationCode = rsdata5.Fields.Item("LocationCode").Value
        ProdSer = rsdata5.Fields.Item("ProdSer").Value
        LabQty = rsdata5.Fields.Item("Label Quantity").Value
        rsdata5.Close()

        chkDDD = DatePart(DateInterval.DayOfYear, Today, FirstDayOfWeek.Monday, FirstWeekOfYear.Jan1)

        'Moved Day Check from Ini to Data file 6/1/07
        DaySql = "SELECT Day FROM tblDay;"

        rsdata8 = New ADODB.Recordset
        rsdata8.Open(DaySql, cnData, ADODB.CursorTypeEnum.adOpenDynamic, ADODB.LockTypeEnum.adLockOptimistic)

        DDD = rsdata8.Fields.Item("Day").Value()

        If Val(chkDDD) <> Val(DDD) Then

            rsdata8.Fields.Item("Day").Value = chkDDD
            rsdata8.Update()

            SerSql = "SELECT Serial FROM tblMain INNER JOIN tblSerial ON tblMain.SERIALTYPE = tblSerial.App WHERE InStr(1,[tblMain]![SerialProcess],'RG')>0;"
            rsdata5 = New ADODB.Recordset
            rsdata5.Open(SerSql, cnData, ADODB.CursorTypeEnum.adOpenDynamic, ADODB.LockTypeEnum.adLockOptimistic)

            While rsdata5.EOF = False
                rsdata5.Fields.Item("Serial").Value = "1"
                rsdata5.Update()
                rsdata5.MoveNext()
            End While
            rsdata5.Close()

        End If

        rsdata8.Close()
        SerialStr = Trim(LocationCode) & Trim(YrCode) & Trim(WkStr) & Trim(DyStr) & Trim(ProdSer) & Trim(RevCode)

    End Sub
    Public Sub SerialStats2()
        Dim YrSql, YrStr1, WkStr, YrDigit, DyStr, CodeSql, DaySql, SerSql, chkDDD, Mbox, dayChk, nxtYr, nxtDy, dayYr, curYr As String
        Dim newYr, Holder As Date
        Dim x As Integer

        cnData = New ADODB.Connection
        cnConnStr = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" & DataBasePath & DataBaseName
        cnData.ConnectionString = cnConnStr
        Try
            cnData.Open()
        Catch
            MsgBox("Data Source could not be opened.")
            Exit Sub
        End Try

        YrStr1 = DatePart(DateInterval.Year, Today, FirstDayOfWeek.Monday, FirstWeekOfYear.Jan1)
        YrDigit = Mid(YrStr1, 4, 1)

        WkStr = DatePart(DateInterval.WeekOfYear, Today, FirstDayOfWeek.Monday, FirstWeekOfYear.Jan1)
        CodeSql = "SELECT ProductCode, [Label Quantity], LocationCode, ISOCountryCode, SupplierCode, ProdSer, RevCode, RevCode1, RevCode2, Question, [Serial Code] FROM tblCode WHERE ProductCode='" & ProdType & "';"
        rsdata5 = New ADODB.Recordset
        rsdata5.Open(CodeSql, cnData, ADODB.CursorTypeEnum.adOpenDynamic, ADODB.LockTypeEnum.adLockOptimistic)

        If Not IsDBNull(rsdata.Fields.Item("SERIALREV").Value) And rsdata.Fields.Item("SERIALREV").Value = "Yes" Then

            If f4 Is Nothing Then
                f4 = New frmQuestion
                f4.ShowDialog()
                f4 = Nothing
            End If

        Else

            RevCode = rsdata5.Fields.Item("RevCode").Value

        End If

        ISOCountryCode = rsdata5.Fields.Item("ISOCountryCode").Value
        SupplierCode = rsdata5.Fields.Item("SupplierCode").Value
        LabQty = rsdata5.Fields.Item("Label Quantity").Value
        rsdata5.Close()

        DaySql = "SELECT Day2 FROM tblDay;"
        rsdata8 = New ADODB.Recordset
        rsdata8.Open(DaySql, cnData, ADODB.CursorTypeEnum.adOpenDynamic, ADODB.LockTypeEnum.adLockOptimistic)
        DDD = rsdata8.Fields.Item("Day2").Value()

        chkDDD = DatePart(DateInterval.Weekday, Today, FirstDayOfWeek.Monday, FirstWeekOfYear.Jan1)

        If Val(chkDDD) = 1 And DDD <> DatePart(DateInterval.DayOfYear, Today, FirstDayOfWeek.Monday, FirstWeekOfYear.Jan1) Then

            SerSql = "SELECT Serial FROM tblMain INNER JOIN tblSerial ON tblMain.SERIALTYPE = tblSerial.App WHERE InStr(1,[tblMain]![SerialProcess],'HP')>0;"
            rsdata5 = New ADODB.Recordset
            rsdata5.Open(SerSql, cnData, ADODB.CursorTypeEnum.adOpenDynamic, ADODB.LockTypeEnum.adLockOptimistic)

            While rsdata5.EOF = False
                rsdata5.Fields.Item("Serial").Value = "1"
                rsdata5.Update()
                rsdata5.MoveNext()
            End While
            rsdata5.Close()

        End If

        'Reset Day for Serial String
        If Val(chkDDD) = 1 Then
            rsdata8.Fields.Item("Day2").Value = DatePart(DateInterval.DayOfYear, Today, FirstDayOfWeek.Monday, FirstWeekOfYear.Jan1)
            rsdata8.Update()
        End If

        rsdata8.Close()
        SerialStr = Trim(ISOCountryCode) & Trim(SupplierCode) & Trim(YrDigit) & Trim(WkStr)

    End Sub
    Public Sub SerialStats3()
        Dim YrSql, YrStr1, WkStr, YrCode, DyStr, CodeSql, DaySql, SerSql, chkDDD, Mbox, dayChk, nxtYr, nxtDy, dayYr, curYr As String
        Dim newYr, Holder As Date
        Dim x As Integer

        cnData = New ADODB.Connection
        cnConnStr = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" & DataBasePath & DataBaseName
        cnData.ConnectionString = cnConnStr
        Try
            cnData.Open()
        Catch
            MsgBox("Data Source could not be opened.")
            Exit Sub
        End Try

        curYr = Format(Today.AddYears(1), "yyyy")
        Holder = "#12/31/" & curYr & "#"
        'Check for first day of year using week to advance or not advance year, first day other than Monday
        If DatePart(DateInterval.WeekOfYear, Today, FirstDayOfWeek.Monday, FirstWeekOfYear.Jan1) = DatePart(DateInterval.WeekOfYear, Holder, FirstDayOfWeek.Monday, FirstWeekOfYear.Jan1) Then
            'nxtYr = Format(Today.AddYears(1), "yyyy")
            'newYr = "1/01/" & nxtYr
            For x = 1 To 7

                nxtDy = Format(Today.AddDays(-x), "MM/dd/yyyy")
                Holder = nxtDy
                DyStr = DatePart(DateInterval.Weekday, Holder, FirstDayOfWeek.Monday, FirstWeekOfYear.Jan1)
                If DyStr = 1 Then
                    dayYr = Format(Today.AddDays(-x), "MM/dd/yyyy")
                    If dayYr = Format(Today, "MM/dd/yyyy") Then
                        YrStr1 = DatePart(DateInterval.Year, Today, FirstDayOfWeek.Monday, FirstWeekOfYear.Jan1)
                    Else
                        YrStr1 = Format(Today.AddYears(1), "yyyy")
                    End If
                End If

            Next x
        Else
            YrStr1 = DatePart(DateInterval.Year, Today, FirstDayOfWeek.Monday, FirstWeekOfYear.Jan1)
        End If

        YrSql = "SELECT [Code] FROM tblYearCode WHERE [Year]='" & YrStr1 & "';"
        rsdata4 = New ADODB.Recordset
        rsdata4.Open(YrSql, cnData, ADODB.CursorTypeEnum.adOpenDynamic, ADODB.LockTypeEnum.adLockOptimistic)
        YrCode = rsdata4.Fields.Item("Code").Value
        WkStr = DatePart(DateInterval.WeekOfYear, Today, FirstDayOfWeek.Monday, FirstWeekOfYear.System)
        If Val(Trim(WkStr)) > 52 Then WkStr = "1"
        If Len(WkStr) = 1 Then WkStr = "0" & Trim(WkStr)
        DyStr = DatePart(DateInterval.Weekday, Today, FirstDayOfWeek.Monday, FirstWeekOfYear.Jan1)

        CodeSql = "SELECT ProductCode, [Label Quantity], LocationCode, ProdSer, RevCode, RevCode1, RevCode2, Question, [Serial Code] FROM tblCode WHERE ProductCode='" & ProdType & "';"

        rsdata5 = New ADODB.Recordset
        rsdata5.Open(CodeSql, cnData, ADODB.CursorTypeEnum.adOpenDynamic, ADODB.LockTypeEnum.adLockOptimistic)

        If Not IsDBNull(rsdata.Fields.Item("SERIALREV").Value) And rsdata.Fields.Item("SERIALREV").Value = "Yes" Then

            If f4 Is Nothing Then
                f4 = New frmQuestion
                f4.ShowDialog()
                f4 = Nothing
            End If

        Else

            RevCode = rsdata5.Fields.Item("RevCode").Value

        End If

        LocationCode = rsdata5.Fields.Item("LocationCode").Value
        ProdSer = rsdata5.Fields.Item("ProdSer").Value
        LabQty = rsdata5.Fields.Item("Label Quantity").Value
        rsdata5.Close()

        chkDDD = DatePart(DateInterval.DayOfYear, Today, FirstDayOfWeek.Monday, FirstWeekOfYear.Jan1)

        'Moved Day Check from Ini to Data file 6/1/07
        DaySql = "SELECT Day FROM tblDay;"

        rsdata8 = New ADODB.Recordset
        rsdata8.Open(DaySql, cnData, ADODB.CursorTypeEnum.adOpenDynamic, ADODB.LockTypeEnum.adLockOptimistic)

        DDD = rsdata8.Fields.Item("Day").Value()

        If Val(chkDDD) <> Val(DDD) Then

            rsdata8.Fields.Item("Day").Value = chkDDD
            rsdata8.Update()

            SerSql = "SELECT Serial FROM tblMain INNER JOIN tblSerial ON tblMain.SERIALTYPE = tblSerial.App WHERE InStr(1,[tblMain]![SerialProcess],'RG')>0;"
            rsdata5 = New ADODB.Recordset
            rsdata5.Open(SerSql, cnData, ADODB.CursorTypeEnum.adOpenDynamic, ADODB.LockTypeEnum.adLockOptimistic)

            While rsdata5.EOF = False
                rsdata5.Fields.Item("Serial").Value = "1"
                rsdata5.Update()
                rsdata5.MoveNext()
            End While
            rsdata5.Close()

        End If

        SerialStr = Trim(LocationCode) & Trim(YrCode) & Trim(WkStr) & Trim(DyStr) & Trim(ProdSer)

    End Sub
    Public Function PrevInstance() As Boolean

        If Diagnostics.Process.GetProcessesByName(Diagnostics.Process.GetCurrentProcess.ProcessName).Length > 1 Then
            MsgBox("An Instance of this program is already running.", MsgBoxStyle.Critical, "Program Already Running")
            End
        End If

    End Function

    Private Sub txtCTO_KeyPress(ByVal sender As Object, ByVal e As System.Windows.Forms.KeyPressEventArgs) Handles txtCTO.KeyPress

        If e.KeyChar = Chr(13) Then
            cmdProcess.PerformClick()
        End If

    End Sub

    Private Sub txtSYSTR_KeyPress(ByVal sender As Object, ByVal e As System.Windows.Forms.KeyPressEventArgs) Handles txtSYSTR.KeyPress
        'Added to handle issue of user entering non numeric values 7/1/07

        If Asc(e.KeyChar) > 25 Then
            If Asc(e.KeyChar) < 48 Or Asc(e.KeyChar) > 57 Then
                MessageBox.Show("Number entry only")
                e.Handled = True
            Else
                e.Handled = False
            End If

        End If

        If Asc(e.KeyChar) = 13 Then
            txtPrintQty.Focus()
        End If

    End Sub

    Private Sub txtCTO_TextChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles txtCTO.TextChanged

        txtCTO.Text = UCase(txtCTO.Text)
        txtCTO.SelectionStart = (Len(txtCTO.Text))

    End Sub

    Private Sub cmdProcess_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdProcess.Click
        Dim ctopos, ctoloop, ctocheck As Integer

        cnData = New ADODB.Connection
        cnConnStr = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" & DataBasePath & DataBaseName
        cnData.ConnectionString = cnConnStr
        Try
            cnData.Open()
        Catch
            MsgBox("Data Source could not be opened.")
            Exit Sub
        End Try

        'Added for dynamic CTO numbers 4/25/07
        ' **********************************************************************
        ctoloop = 0
        ctopos = Len(txtCTO.Text)

        While ctoloop = 0
            If ctopos < 1 Then
                MsgBox("Your entry can not be found, please check your entry and try again")
                Exit Sub
            End If
            SQLString2 = SQLString & " WHERE [CONFIG] = '" & Mid(txtCTO.Text, 1, ctopos) & "'"
            rsdata = New ADODB.Recordset
            rsdata.Open(SQLString2, cnData, ADODB.CursorTypeEnum.adOpenDynamic, ADODB.LockTypeEnum.adLockOptimistic)

            If rsdata.EOF = True Then
                rsdata.Close()
                ctopos = ctopos - 1
                If ctopos > Len(txtCTO.Text) Then
                    MsgBox("CTO Number not found.")
                    frmFour.Visible = False
                    Label2.Visible = False
                    txtSYSTR.Visible = False
                    Exit Sub

                End If
            Else
                SQLString3 = "SELECT ProductCode, [Total Length], [Search Length] FROM SearchL WHERE ProductCode='" & rsdata.Fields.Item("P").Value & "';"
                rsdata6 = New ADODB.Recordset
                rsdata6.Open(SQLString3, cnData, ADODB.CursorTypeEnum.adOpenDynamic, ADODB.LockTypeEnum.adLockOptimistic)

                If IsDBNull(rsdata6.Fields.Item("Search Length").Value) = False Then

                    If Val(rsdata6.Fields.Item("Search Length").Value) = ctopos Then
                        ctoloop = 1
                        ctocheck = Val(rsdata6.Fields.Item("Total Length").Value)
                    Else
                        ctoloop = 0
                    End If
                Else
                    ctoloop = 1
                    ctocheck = Len(txtCTO.Text)
                End If
                ctopos = ctopos - 1
            End If
        End While
        ctoloop = 0

        If Len(txtCTO.Text) <> ctocheck Then
            MsgBox("You have not entered a " & ctocheck & " digit CTO number")
            Exit Sub
        End If
        ' **********************************************************************

        'Set up variable for MultiLab condition
        If Not IsDBNull(rsdata.Fields.Item("MULTILABEL").Value) Then
            MultiLab = rsdata.Fields.Item("MULTILABEL").Value
        End If

        'Added to handle Static Label
        ' **********************************************************************
        If rsdata.Fields.Item("P").Value = "STATIC" Then

            rsdata2 = New ADODB.Recordset
            rsdata2.Open("SELECT Labels FROM tblLabelLookUp WHERE LabelString='" & rsdata.Fields.Item("LABELSTRING").Value & "';", cnData)
            LabFor1 = rsdata2.Fields.Item("Labels").Value

            F3 = New frmStatic
            F3.ShowDialog()
            Call ClearForm()
            Exit Sub

        End If
        ' **********************************************************************

        If rsdata.EOF = True Then
            MsgBox("CTO Number not found.")
            frmFour.Visible = False
            Label2.Visible = False
            txtSYSTR.Visible = False
            Exit Sub
        Else
            frmFour.Visible = True
            Label2.Visible = True
            txtSYSTR.Visible = True
            txtSYSTR.Focus()
        End If

        'Added to handle other labels 4/25/07
        ' **********************************************************************
        If rsdata.Fields.Item("P").Value = "K" Or rsdata.Fields.Item("P").Value = "P" Then
            If Mid(txtCTO.Text, 11, 1) > 0 Then
                If IsDBNull(rsdata.Fields.Item("INAMP2").Value) = False Then
                    INA = rsdata.Fields.Item("INAMP2").Value
                Else
                    INA = ""
                End If
            Else
                If IsDBNull(rsdata.Fields.Item("INAMP").Value) = False Then
                    INA = rsdata.Fields.Item("INAMP").Value
                Else
                    INA = ""
                End If
            End If
        Else
            If IsDBNull(rsdata.Fields.Item("INAMP").Value) = False Then
                INA = rsdata.Fields.Item("INAMP").Value
            Else
                INA = ""
            End If
        End If

        If rsdata.Fields.Item("P").Value = "K" Then
            RunType = "K"
            If Not IsDBNull(rsdata.Fields.Item("TRANS").Value) Then
                If rsdata.Fields.Item("TRANS").Value <> "MBC" Then
                    rsdata.Fields.Item("BYPVOLT").Value = ""
                    rsdata.Fields.Item("BYPHZ").Value = ""
                    rsdata.Fields.Item("BYPAMP").Value = ""
                    rsdata.Fields.Item("BYPKVA").Value = "'"
                End If
            End If
        Else
            RunType = "P"
        End If

        'Added to handle other labels 4/25/07
        ' **********************************************************************
        If rsdata.Fields.Item("P").Value = "K" Or rsdata.Fields.Item("P").Value = "P" Then
            If Not IsDBNull(rsdata.Fields.Item("UPSTYPE1").Value) Then
                UPSTYPE = rsdata.Fields.Item("UPSTYPE1").Value
            Else
                UPSTYPE = "    "
            End If

            If Mid(txtCTO.Text, 13, 1) = 7 Then
                If RunType = "K" Then
                    UPSTYPE = "Unisys 750"
                Else
                    UPSTYPE = "Unisys"
                End If
            End If
        End If
        ' **********************************************************************

        ProdType = Trim(rsdata.Fields.Item("P").Value)

        '*****************************************************************************************************************
        '************************************** Serial Selection Changed 3/30/2009 ***************************************
        '*****************************************************************************************************************
        Select Case Mid(rsdata.Fields.Item("SerialProcess").Value, 1, 3)
            Case "RG1"
                SerialStats()

            Case "HP1"
                SerialStats2()

            Case "RG2"
                SerialStats3()

        End Select

        rsdata.Fields.Item("CONFIG").Value = txtCTO.Text

        'Added to handle Default value population 5/30/07
        txtSYSTR.Focus()
        cmdPrint.Visible = True
        rdoNewLabel.Checked = True

    End Sub

    Private Sub rdoNewLabel_CheckedChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles rdoNewLabel.CheckedChanged

        If rdoNewLabel.Checked = True Or rdoOldSerialNum.Checked = True Or rdoNewRLNum.Checked = True Or rdoOldSerialRLNum.Checked = True Then
            txtPrintQty.Visible = True
            Label3.Visible = True
        End If

    End Sub

    Private Sub rdoOldSerialNum_CheckedChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles rdoOldSerialNum.CheckedChanged

        If rdoNewLabel.Checked = True Or rdoOldSerialNum.Checked = True Or rdoNewRLNum.Checked = True Or rdoOldSerialRLNum.Checked = True Then
            txtPrintQty.Visible = True
            Label3.Visible = True
        End If

    End Sub

    Private Sub rdoNewRLNum_CheckedChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles rdoNewRLNum.CheckedChanged

        If rdoNewLabel.Checked = True Or rdoOldSerialNum.Checked = True Or rdoNewRLNum.Checked = True Or rdoOldSerialRLNum.Checked = True Then
            txtPrintQty.Visible = True
            Label3.Visible = True
        End If

    End Sub

    Private Sub rdoOldSerialRLNum_CheckedChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles rdoOldSerialRLNum.CheckedChanged

        If rdoNewLabel.Checked = True Or rdoOldSerialNum.Checked = True Or rdoNewRLNum.Checked = True Or rdoOldSerialRLNum.Checked = True Then
            txtPrintQty.Visible = True
            Label3.Visible = True
        End If

    End Sub

    Private Sub cmdCancel_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdCancel.Click

        Call ClearForm()

    End Sub
    Public Sub ClearForm()

        txtCTO.Text = ""
        txtSYSTR.Text = ""
        LabFor1 = ""
        LabFor2 = ""
        LabFor3 = ""
        LabFor4 = ""
        rdoNewLabel.Checked = False
        rdoOldSerialNum.Checked = False
        rdoNewRLNum.Checked = False
        rdoOldSerialRLNum.Checked = False
        Label2.Visible = False
        txtSYSTR.Visible = False
        frmFour.Visible = False
        txtPrintQty.Visible = False
        Label3.Visible = False
        txtPrintQty.Text = "1"
        txtCTO.Focus()
        cmdPrint.Visible = False
        SYSTR = ""
        FULLCTO = ""

    End Sub
    Private Sub cmdPrint_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdPrint.Click
        Dim holder, PsWd As String
        Dim Pos, Pos2, FormChk As Integer

        If txtPrintQty.Text = "" Then
            MsgBox("You have not entered a print qty")
            txtPrintQty.Focus()
            Exit Sub
        End If

        If rdoOldSerialNum.Checked = True Or rdoNewRLNum.Checked = True Or rdoOldSerialRLNum.Checked = True Then

            PsWd = InputBox("Enter Password to continue", "PASSWORD NEEDED")
            If Trim(PsWd) <> Trim(PssWrd) Then
                MsgBox("You have not entered the correct password.")
                Exit Sub
            End If

        End If

        rsdata2 = New ADODB.Recordset
        rsdata2.Open("SELECT Labels FROM tblLabelLookUp WHERE LabelString='" & rsdata.Fields.Item("LABELSTRING").Value & "';", cnData)
        holder = rsdata2.Fields.Item("Labels").Value
        PQty = txtPrintQty.Text
        SYSTR = txtSYSTR.Text

        'Added to handle other labels 4/25/07
        ' **********************************************************************
        If rsdata.Fields.Item("P").Value = "K" Or rsdata.Fields.Item("P").Value = "P" Then
            If RunType <> "K" Then
                Pos = 1
                LabFor1 = Mid(holder, Pos, InStr(holder, ",", CompareMethod.Binary) - 1)
                holder = Mid(holder, InStr(holder, ",", CompareMethod.Binary) + 1)
                LabFor2 = Mid(holder, Pos, InStr(holder, ",", CompareMethod.Binary) - 1)
                holder = Mid(holder, InStr(holder, ",", CompareMethod.Binary) + 1)
                LabFor3 = holder
                Call PrintRoutine1()
            Else
                Pos = 1
                LabFor1 = Mid(holder, Pos, InStr(holder, ",", CompareMethod.Binary) - 1)
                holder = Mid(holder, InStr(holder, ",", CompareMethod.Binary) + 1)
                LabFor2 = Mid(holder, Pos, InStr(holder, ",", CompareMethod.Binary) - 1)
                holder = Mid(holder, InStr(holder, ",", CompareMethod.Binary) + 1)
                LabFor3 = Mid(holder, Pos, InStr(holder, ",", CompareMethod.Binary) - 1)
                holder = Mid(holder, InStr(holder, ",", CompareMethod.Binary) + 1)
                LabFor4 = holder
                Call PrintRoutine2()
            End If
        Else

            For FormChk = 1 To Len(holder)

                If Mid(holder, FormChk, 1) = "," Then
                    Pos2 = Pos2 + 1
                End If

            Next
            NewCab = Pos2

            Pos = 1
            If InStr(holder, ",", CompareMethod.Binary) <> 0 Then
                LabFor1 = Mid(holder, Pos, InStr(holder, ",", CompareMethod.Binary) - 1)
                holder = Mid(holder, InStr(holder, ",", CompareMethod.Binary) + 1)
            Else
                LabFor1 = holder
            End If

            If InStr(holder, ",", CompareMethod.Binary) <> 0 Then
                LabFor2 = Mid(holder, Pos, InStr(holder, ",", CompareMethod.Binary) - 1)
                holder = Mid(holder, InStr(holder, ",", CompareMethod.Binary) + 1)
            Else
                If Pos2 = 1 Then
                    LabFor2 = holder
                End If
            End If

            If InStr(holder, ",", CompareMethod.Binary) <> 0 Then
                LabFor3 = Mid(holder, Pos, InStr(holder, ",", CompareMethod.Binary) - 1)
                holder = Mid(holder, InStr(holder, ",", CompareMethod.Binary) + 1)
            Else
                If Pos2 = 2 Then
                    LabFor3 = holder
                End If
            End If

            If InStr(holder, ",", CompareMethod.Binary) <> 0 Then
                LabFor4 = holder
            Else
                If Pos2 = 3 Then
                    LabFor4 = holder
                End If
            End If

            If Pos2 = 0 Then
                LabFor1 = holder
                Call PrintRoutine3()
            Else
                Call PrintRoutine4()
            End If

        End If

    End Sub

    Private Sub frmMain_Closed(ByVal sender As Object, ByVal e As System.EventArgs) Handles MyBase.Closed

        btApp.Quit(BarTender.BtSaveOptions.btDoNotSaveChanges)

    End Sub

    Private Sub lstPrinter_SelectedIndexChanged(ByVal sender As System.Object, ByVal e As System.EventArgs)

        cmdPrint.Visible = True

    End Sub

    Private Sub PrintRoutine1()
        Dim j, i, LoopTrk As Integer
        Dim Loop1, Loop3, SysTrack, RLNumber As String

        LoopTrk = 1
        RLNumber = ""
        Serial = ""

        If rdoNewLabel.Checked = True Then
            rsdata3 = New ADODB.Recordset
            rsdata3.Open("SELECT Serial FROM tblSerial WHERE App='" & rsdata.Fields.Item("SERIALTYPE").Value & "';", cnData, ADODB.CursorTypeEnum.adOpenDynamic, ADODB.LockTypeEnum.adLockOptimistic)
            Serial = rsdata3.Fields.Item("Serial").Value
        End If
        If rdoOldSerialNum.Checked = True Then
            SerialBx = InputBox("Please enter the complete old serial number for the nameplate", "Old Serial Entry")
            SerialBx = UCase(SerialBx)
            If SerialBx = "" Then
                MsgBox("You must supply the old serial number to continue")
                Exit Sub
            End If
            SerialStr = Mid(SerialBx, 1, 6)
            Serial = Mid(SerialBx, 7, 4)
        End If
        If rdoNewRLNum.Checked = True Then
            rsdata3 = New ADODB.Recordset
            rsdata3.Open("SELECT Serial FROM tblSerial WHERE App='" & rsdata.Fields.Item("SERIALTYPE").Value & "';", cnData, ADODB.CursorTypeEnum.adOpenDynamic, ADODB.LockTypeEnum.adLockOptimistic)
            Serial = rsdata3.Fields.Item("Serial").Value
            If Serial = "100" Then Serial = "1"
            If F2 Is Nothing Then
                F2 = New frmRL
                F2.ShowDialog()
                Call ClearForm()
            End If
            Exit Sub
        End If
        If rdoOldSerialRLNum.Checked = True Then
            If F2 Is Nothing Then
                F2 = New frmRL
                F2.ShowDialog()
                Call ClearForm()
            End If
            Exit Sub
        End If

        Loop1 = 1

        While Loop1 <= Val(txtPrintQty.Text)

            '*****************************************************************************************************************
            '***********************************Serial Selection Changed to data 3/30/2009************************************
            '*****************************************************************************************************************
            Select Case Mid(rsdata.Fields.Item("SerialProcess").Value, 1, 3)
                Case "RG1"
                    If Trim(Serial) = "100" Then Serial = "1"
                    Serial = Serial.PadLeft(2, "0")

                Case "RG2"
                    If Trim(Serial) = "10000" Then Serial = "1"
                    Serial = Serial.PadLeft(4, "0")

                Case "HP1"
                    If Trim(Serial) = "10000" Then Serial = "1"
                    Serial = Serial.PadLeft(4, "0")
            End Select

            CABTRACK = 1
            While CABTRACK <= rsdata.Fields.Item("CABTOT").Value

                Select Case CABTRACK
                    Case 1

                        btLab = btApp.Formats.Open(LabDir & LabFor1)

                        '*****************************************************************************************************************
                        '***********************************Printer Selection Changed to data 3/30/2009***********************************
                        '*****************************************************************************************************************
                        rsdata9 = New ADODB.Recordset
                        rsdata9.Open("SELECT Printer FROM tblPrinter WHERE Labels='" & LabFor1 & "';", cnData)
                        btLab.Printer = rsdata9.Fields.Item("Printer").Value

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
                        For j = 1 To btLab.NamedSubStrings.Count
                            '****** Assign User Input to Label Sub Strings ******
                            If btLab.NamedSubStrings.Item(j).Name = "SYSTR" Then
                                btLab.NamedSubStrings.Item(j).Value = txtSYSTR.Text
                            End If
                            If btLab.NamedSubStrings.Item(j).Name = "UPSTYPE" Then
                                btLab.NamedSubStrings.Item(j).Value = UPSTYPE
                            End If
                            If btLab.NamedSubStrings.Item(j).Name = "INA" Then
                                btLab.NamedSubStrings.Item(j).Value = INA
                            End If
                            If btLab.NamedSubStrings.Item(j).Name = "Serial" Then
                                btLab.NamedSubStrings.Item(j).Value = SerialStr & Serial
                            End If
                            If btLab.NamedSubStrings.Item(j).Name = "CABTRACK" Then
                                btLab.NamedSubStrings.Item(j).Value = CABTRACK
                            End If
                            'Set up which pictures will print out
                            If btLab.NamedSubStrings.Item(j).Name = "AGENCY1" Then
                                If IsDBNull(rsdata.Fields.Item("AGENCY1").Value) = True Then
                                    btLab.NamedSubStrings.Item(j).Value = ""
                                End If
                            End If
                            If btLab.NamedSubStrings.Item(j).Name = "AGENCY2" Then
                                If IsDBNull(rsdata.Fields.Item("AGENCY2").Value) = True Then
                                    btLab.NamedSubStrings.Item(j).Value = ""
                                End If
                            End If
                            If btLab.NamedSubStrings.Item(j).Name = "AGENCY3" Then
                                If IsDBNull(rsdata.Fields.Item("AGENCY3").Value) = True Then
                                    btLab.NamedSubStrings.Item(j).Value = ""
                                End If
                            End If

                        Next j
                        'btLab.IdenticalCopiesOfLabel = LabQty
                        btLab.PrintOut()
                        btLab.Close(BarTender.BtSaveOptions.btDoNotSaveChanges)

                    Case 2
                        If rsdata.Fields.Item("TRANS").Value = "ISO" Then

                            btLab = btApp.Formats.Open(LabDir & LabFor2)

                            '*****************************************************************************************************************
                            '***********************************Printer Selection Changed to data 3/30/2009***********************************
                            '*****************************************************************************************************************
                            rsdata9 = New ADODB.Recordset
                            rsdata9.Open("SELECT Printer FROM tblPrinter WHERE Labels='" & LabFor1 & "';", cnData)
                            btLab.Printer = rsdata9.Fields.Item("Printer").Value

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
                            For j = 1 To btLab.NamedSubStrings.Count
                                '****** Assign User Input to Label Sub Strings ******
                                If btLab.NamedSubStrings.Item(j).Name = "SYSTR" Then
                                    btLab.NamedSubStrings.Item(j).Value = txtSYSTR.Text
                                End If
                                If btLab.NamedSubStrings.Item(j).Name = "UPSTYPE" Then
                                    btLab.NamedSubStrings.Item(j).Value = UPSTYPE
                                End If
                                If btLab.NamedSubStrings.Item(j).Name = "INA" Then
                                    btLab.NamedSubStrings.Item(j).Value = INA
                                End If
                                If btLab.NamedSubStrings.Item(j).Name = "Serial" Then
                                    btLab.NamedSubStrings.Item(j).Value = SerialStr & Serial
                                End If
                                If btLab.NamedSubStrings.Item(j).Name = "CABTRACK" Then
                                    btLab.NamedSubStrings.Item(j).Value = CABTRACK
                                End If
                                'Set up which pictures will print out
                                If btLab.NamedSubStrings.Item(j).Name = "AGENCY1" Then
                                    If IsDBNull(rsdata.Fields.Item("AGENCY1").Value) = True Then
                                        btLab.NamedSubStrings.Item(j).Value = ""
                                    End If
                                End If
                                If btLab.NamedSubStrings.Item(j).Name = "AGENCY2" Then
                                    If IsDBNull(rsdata.Fields.Item("AGENCY2").Value) = True Then
                                        btLab.NamedSubStrings.Item(j).Value = ""
                                    End If
                                End If
                                If btLab.NamedSubStrings.Item(j).Name = "AGENCY3" Then
                                    If IsDBNull(rsdata.Fields.Item("AGENCY3").Value) = True Then
                                        btLab.NamedSubStrings.Item(j).Value = ""
                                    End If
                                End If
                            Next j

                            'btLab.IdenticalCopiesOfLabel = LabQty
                            btLab.PrintOut()
                            btLab.Close(BarTender.BtSaveOptions.btDoNotSaveChanges)

                        Else

                            btLab = btApp.Formats.Open(LabDir & LabFor3)

                            '*****************************************************************************************************************
                            '***********************************Printer Selection Changed to data 3/30/2009***********************************
                            '*****************************************************************************************************************
                            rsdata9 = New ADODB.Recordset
                            rsdata9.Open("SELECT Printer FROM tblPrinter WHERE Labels='" & LabFor1 & "';", cnData)
                            btLab.Printer = rsdata9.Fields.Item("Printer").Value

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
                            For j = 1 To btLab.NamedSubStrings.Count
                                '****** Assign User Input to Label Sub Strings ******
                                If btLab.NamedSubStrings.Item(j).Name = "SYSTR" Then
                                    btLab.NamedSubStrings.Item(j).Value = txtSYSTR.Text
                                End If
                                If btLab.NamedSubStrings.Item(j).Name = "UPSTYPE" Then
                                    btLab.NamedSubStrings.Item(j).Value = UPSTYPE
                                End If
                                If btLab.NamedSubStrings.Item(j).Name = "INA" Then
                                    btLab.NamedSubStrings.Item(j).Value = INA
                                End If
                                If btLab.NamedSubStrings.Item(j).Name = "Serial" Then
                                    btLab.NamedSubStrings.Item(j).Value = SerialStr & Serial
                                End If
                                If btLab.NamedSubStrings.Item(j).Name = "CABTRACK" Then
                                    btLab.NamedSubStrings.Item(j).Value = CABTRACK
                                End If
                                'Set up which pictures will print out
                                If btLab.NamedSubStrings.Item(j).Name = "AGENCY1" Then
                                    If IsDBNull(rsdata.Fields.Item("AGENCY1").Value) = True Then
                                        btLab.NamedSubStrings.Item(j).Value = ""
                                    End If
                                End If
                                If btLab.NamedSubStrings.Item(j).Name = "AGENCY2" Then
                                    If IsDBNull(rsdata.Fields.Item("AGENCY2").Value) = True Then
                                        btLab.NamedSubStrings.Item(j).Value = ""
                                    End If
                                End If
                                If btLab.NamedSubStrings.Item(j).Name = "AGENCY3" Then
                                    If IsDBNull(rsdata.Fields.Item("AGENCY3").Value) = True Then
                                        btLab.NamedSubStrings.Item(j).Value = ""
                                    End If
                                End If
                            Next j

                            'btLab.IdenticalCopiesOfLabel = LabQty
                            btLab.PrintOut()
                            btLab.Close(BarTender.BtSaveOptions.btDoNotSaveChanges)

                        End If

                    Case 3

                        If IsDBNull(rsdata.Fields.Item("TRANS2").Value) = True Then rsdata.Fields.Item("TRANS2").Value = " "
                        If rsdata.Fields.Item("TRANS2").Value = "AUTO" Then

                            btLab = btApp.Formats.Open(LabDir & LabFor3)

                            '*****************************************************************************************************************
                            '***********************************Printer Selection Changed to data 3/30/2009***********************************
                            '*****************************************************************************************************************
                            rsdata9 = New ADODB.Recordset
                            rsdata9.Open("SELECT Printer FROM tblPrinter WHERE Labels='" & LabFor1 & "';", cnData)
                            btLab.Printer = rsdata9.Fields.Item("Printer").Value

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
                            For j = 1 To btLab.NamedSubStrings.Count
                                '****** Assign User Input to Label Sub Strings ******
                                If btLab.NamedSubStrings.Item(j).Name = "SYSTR" Then
                                    btLab.NamedSubStrings.Item(j).Value = txtSYSTR.Text
                                End If
                                If btLab.NamedSubStrings.Item(j).Name = "UPSTYPE" Then
                                    btLab.NamedSubStrings.Item(j).Value = UPSTYPE
                                End If
                                If btLab.NamedSubStrings.Item(j).Name = "INA" Then
                                    btLab.NamedSubStrings.Item(j).Value = INA
                                End If
                                If btLab.NamedSubStrings.Item(j).Name = "Serial" Then
                                    btLab.NamedSubStrings.Item(j).Value = SerialStr & Serial
                                End If
                                If btLab.NamedSubStrings.Item(j).Name = "CABTRACK" Then
                                    btLab.NamedSubStrings.Item(j).Value = CABTRACK
                                End If
                                'Set up which pictures will print out
                                If btLab.NamedSubStrings.Item(j).Name = "AGENCY1" Then
                                    If IsDBNull(rsdata.Fields.Item("AGENCY1").Value) = True Then
                                        btLab.NamedSubStrings.Item(j).Value = ""
                                    End If
                                End If
                                If btLab.NamedSubStrings.Item(j).Name = "AGENCY2" Then
                                    If IsDBNull(rsdata.Fields.Item("AGENCY2").Value) = True Then
                                        btLab.NamedSubStrings.Item(j).Value = ""
                                    End If
                                End If
                                If btLab.NamedSubStrings.Item(j).Name = "AGENCY3" Then
                                    If IsDBNull(rsdata.Fields.Item("AGENCY3").Value) = True Then
                                        btLab.NamedSubStrings.Item(j).Value = ""
                                    End If
                                End If
                            Next j

                            'btLab.IdenticalCopiesOfLabel = LabQty
                            btLab.PrintOut()
                            btLab.Close(BarTender.BtSaveOptions.btDoNotSaveChanges)

                        Else

                            btLab = btApp.Formats.Open(LabDir & LabFor2)

                            '*****************************************************************************************************************
                            '***********************************Printer Selection Changed to data 3/30/2009***********************************
                            '*****************************************************************************************************************
                            rsdata9 = New ADODB.Recordset
                            rsdata9.Open("SELECT Printer FROM tblPrinter WHERE Labels='" & LabFor1 & "';", cnData)
                            btLab.Printer = rsdata9.Fields.Item("Printer").Value

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
                            For j = 1 To btLab.NamedSubStrings.Count
                                '****** Assign User Input to Label Sub Strings ******
                                If btLab.NamedSubStrings.Item(j).Name = "SYSTR" Then
                                    btLab.NamedSubStrings.Item(j).Value = txtSYSTR.Text
                                End If
                                If btLab.NamedSubStrings.Item(j).Name = "UPSTYPE" Then
                                    btLab.NamedSubStrings.Item(j).Value = UPSTYPE
                                End If
                                If btLab.NamedSubStrings.Item(j).Name = "INA" Then
                                    btLab.NamedSubStrings.Item(j).Value = INA
                                End If
                                If btLab.NamedSubStrings.Item(j).Name = "Serial" Then
                                    btLab.NamedSubStrings.Item(j).Value = SerialStr & Serial
                                End If
                                If btLab.NamedSubStrings.Item(j).Name = "CABTRACK" Then
                                    btLab.NamedSubStrings.Item(j).Value = CABTRACK
                                End If
                                'Set up which pictures will print out
                                If btLab.NamedSubStrings.Item(j).Name = "AGENCY1" Then
                                    If IsDBNull(rsdata.Fields.Item("AGENCY1").Value) = True Then
                                        btLab.NamedSubStrings.Item(j).Value = ""
                                    End If
                                End If
                                If btLab.NamedSubStrings.Item(j).Name = "AGENCY2" Then
                                    If IsDBNull(rsdata.Fields.Item("AGENCY2").Value) = True Then
                                        btLab.NamedSubStrings.Item(j).Value = ""
                                    End If
                                End If
                                If btLab.NamedSubStrings.Item(j).Name = "AGENCY3" Then
                                    If IsDBNull(rsdata.Fields.Item("AGENCY3").Value) = True Then
                                        btLab.NamedSubStrings.Item(j).Value = ""
                                    End If
                                End If
                            Next j

                            'btLab.IdenticalCopiesOfLabel = LabQty
                            btLab.PrintOut()
                            btLab.Close(BarTender.BtSaveOptions.btDoNotSaveChanges)

                        End If
                End Select

                CABTRACK = CABTRACK + 1

                Select Case Mid(rsdata.Fields.Item("SerialProcess").Value, 4, 1)
                    Case "R"
                        'Do nothing serial does not increment

                    Case "I"
                        If Loop1 <= Val(txtPrintQty.Text) Then
                            Select Case Mid(rsdata.Fields.Item("SerialProcess").Value, 1, 3)
                                Case "RG1"
                                    If Trim(Serial) = "100" Then Serial = "1"
                                    Serial = Serial.PadLeft(2, "0")

                                Case "RG2"
                                    If Trim(Serial) = "10000" Then Serial = "1"
                                    Serial = Serial.PadLeft(4, "0")

                                Case "HP1"
                                    If Trim(Serial) = "10000" Then Serial = "1"
                                    Serial = Serial.PadLeft(4, "0")
                            End Select
                        End If

                End Select

            End While

            'Call Writeback
            If rdoOldSerialNum.Checked = False Then WriteBack()

            If Mid(rsdata.Fields.Item("SerialProcess").Value, 4, 1) = "R" Then
                Serial = Trim(Str(Val(Serial) + 1))
            End If
            Select Case Mid(rsdata.Fields.Item("SerialProcess").Value, 1, 3)
                Case "RG1"
                    If Trim(Serial) = "100" Then Serial = "1"
                    Serial = Serial.PadLeft(2, "0")

                Case "RG2"
                    If Trim(Serial) = "10000" Then Serial = "1"
                    Serial = Serial.PadLeft(4, "0")

                Case "HP1"
                    If Trim(Serial) = "10000" Then Serial = "1"
                    Serial = Serial.PadLeft(4, "0")
            End Select

            If rdoNewLabel.Checked = True Then
                rsdata3.Fields.Item("Serial").Value = Trim(Str(Val(Serial)))
                rsdata3.Update()
                If Loop1 = Val(txtPrintQty.Text) Then
                    rsdata3.Close()
                End If
            End If

            Loop1 = Loop1 + 1
            Loop3 = Loop3 + 1

            If ProdType <> "ePDUa" Then
                Dim chkSysTrack As Integer
                chkSysTrack = 0
                If LoopTrk < Val(txtPrintQty.Text) Then
                    If Len(txtSYSTR.Text) > 0 Then '(If the SYSTR sting is empty or null then skip this routine for all labels. If the SYSTR has a value then run this routine)
                        While chkSysTrack = 0
                            SysTrack = InputBox("Please enter the System Tracking Number (without the -)", "System Tracking Number", txtSYSTR.Text)
                            If Len(SysTrack) > 7 Or IsNumeric(SysTrack) = False Then
                                MsgBox("You can only enter 7 numeric only digits for the sytem number")
                                chkSysTrack = 0
                            Else
                                chkSysTrack = 1
                            End If
                        End While
                        txtSYSTR.Text = SysTrack
                        SYSTR = SysTrack
                    End If
                End If
                LoopTrk = LoopTrk + 1
            End If
        End While

        rsdata2.Close()
        rsdata.CancelUpdate()
        rsdata.Close()
        cnData.Close()
        Call ClearForm()

    End Sub
    Private Sub PrintRoutine2()
        Dim j, i, LoopTrk As Integer
        Dim Loop2, Loop3, SysTrack, RLNumber As String

        LoopTrk = 1
        RLNumber = ""
        Serial = ""

        If rdoNewLabel.Checked = True Then
            rsdata3 = New ADODB.Recordset
            rsdata3.Open("SELECT Serial FROM tblSerial WHERE App='" & rsdata.Fields.Item("SERIALTYPE").Value & "';", cnData, ADODB.CursorTypeEnum.adOpenDynamic, ADODB.LockTypeEnum.adLockOptimistic)
            Serial = rsdata3.Fields.Item("Serial").Value
        End If
        If rdoOldSerialNum.Checked = True Then
            SerialBx = InputBox("Please enter the complete old serial number for the nameplate", "Old Serial Entry")
            SerialBx = UCase(SerialBx)
            If SerialBx = "" Then
                MsgBox("You must supply the old serial number to continue")
                Exit Sub
            End If
            SerialStr = Mid(SerialBx, 1, 6)
            Serial = Mid(SerialBx, 7, 4)
        End If
        If rdoNewRLNum.Checked = True Then
            rsdata3 = New ADODB.Recordset
            rsdata3.Open("SELECT Serial FROM tblSerial WHERE App='" & rsdata.Fields.Item("SERIALTYPE").Value & "';", cnData, ADODB.CursorTypeEnum.adOpenDynamic, ADODB.LockTypeEnum.adLockOptimistic)
            Serial = rsdata3.Fields.Item("Serial").Value
            If Serial = "100" Then Serial = "1"
            If F2 Is Nothing Then
                F2 = New frmRL
                F2.ShowDialog()
                Call ClearForm()
            End If
            Exit Sub
        End If
        If rdoOldSerialRLNum.Checked = True Then
            If F2 Is Nothing Then
                F2 = New frmRL
                F2.ShowDialog()
                Call ClearForm()
            End If
            Exit Sub
        End If

        Loop2 = 1

        While Loop2 <= Val(txtPrintQty.Text)

            '*****************************************************************************************************************
            '***********************************Serial Selection Changed to data 3/30/2009************************************
            '*****************************************************************************************************************
            Select Case Mid(rsdata.Fields.Item("SerialProcess").Value, 1, 3)
                Case "RG1"
                    If Trim(Serial) = "100" Then Serial = "1"
                    Serial = Serial.PadLeft(2, "0")

                Case "RG2"
                    If Trim(Serial) = "10000" Then Serial = "1"
                    Serial = Serial.PadLeft(4, "0")

                Case "HP1"
                    If Trim(Serial) = "10000" Then Serial = "1"
                    Serial = Serial.PadLeft(4, "0")
            End Select

            CABTRACK = 2
            While CABTRACK <= rsdata.Fields.Item("CABTOT").Value

                Select Case CABTRACK
                    Case 1
                        btLab = btApp.Formats.Open(LabDir & LabFor1)

                        '*****************************************************************************************************************
                        '***********************************Printer Selection Changed to data 3/30/2009***********************************
                        '*****************************************************************************************************************
                        rsdata9 = New ADODB.Recordset
                        rsdata9.Open("SELECT Printer FROM tblPrinter WHERE Labels='" & LabFor1 & "';", cnData)
                        btLab.Printer = rsdata9.Fields.Item("Printer").Value

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
                        For j = 1 To btLab.NamedSubStrings.Count
                            '****** Assign User Input to Label Sub Strings ******
                            If btLab.NamedSubStrings.Item(j).Name = "SYSTR" Then
                                btLab.NamedSubStrings.Item(j).Value = txtSYSTR.Text
                            End If
                            If btLab.NamedSubStrings.Item(j).Name = "UPSTYPE" Then
                                btLab.NamedSubStrings.Item(j).Value = UPSTYPE
                            End If
                            If btLab.NamedSubStrings.Item(j).Name = "INA" Then
                                btLab.NamedSubStrings.Item(j).Value = INA
                            End If
                            If btLab.NamedSubStrings.Item(j).Name = "Serial" Then
                                btLab.NamedSubStrings.Item(j).Value = SerialStr & Serial
                            End If
                            If btLab.NamedSubStrings.Item(j).Name = "CABTRACK" Then
                                btLab.NamedSubStrings.Item(j).Value = CABTRACK
                            End If
                            'Set up which pictures will print out
                            If btLab.NamedSubStrings.Item(j).Name = "AGENCY1" Then
                                If IsDBNull(rsdata.Fields.Item("AGENCY1").Value) = True Then
                                    btLab.NamedSubStrings.Item(j).Value = ""
                                End If
                            End If
                            If btLab.NamedSubStrings.Item(j).Name = "AGENCY2" Then
                                If IsDBNull(rsdata.Fields.Item("AGENCY2").Value) = True Then
                                    btLab.NamedSubStrings.Item(j).Value = ""
                                End If
                            End If
                            If btLab.NamedSubStrings.Item(j).Name = "AGENCY3" Then
                                If IsDBNull(rsdata.Fields.Item("AGENCY3").Value) = True Then
                                    btLab.NamedSubStrings.Item(j).Value = ""
                                End If
                            End If

                        Next j

                        'btLab.IdenticalCopiesOfLabel = LabQty
                        btLab.PrintOut()
                        btLab.Close(BarTender.BtSaveOptions.btDoNotSaveChanges)

                    Case 2

                        btLab = btApp.Formats.Open(LabDir & LabFor1)

                        '*****************************************************************************************************************
                        '***********************************Printer Selection Changed to data 3/30/2009***********************************
                        '*****************************************************************************************************************
                        rsdata9 = New ADODB.Recordset
                        rsdata9.Open("SELECT Printer FROM tblPrinter WHERE Labels='" & LabFor1 & "';", cnData)
                        btLab.Printer = rsdata9.Fields.Item("Printer").Value

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
                        For j = 1 To btLab.NamedSubStrings.Count
                            '****** Assign User Input to Label Sub Strings ******
                            If btLab.NamedSubStrings.Item(j).Name = "SYSTR" Then
                                btLab.NamedSubStrings.Item(j).Value = txtSYSTR.Text
                            End If
                            If btLab.NamedSubStrings.Item(j).Name = "UPSTYPE" Then
                                btLab.NamedSubStrings.Item(j).Value = UPSTYPE
                            End If
                            If btLab.NamedSubStrings.Item(j).Name = "INA" Then
                                btLab.NamedSubStrings.Item(j).Value = INA
                            End If
                            If btLab.NamedSubStrings.Item(j).Name = "Serial" Then
                                btLab.NamedSubStrings.Item(j).Value = SerialStr & Serial
                            End If
                            If btLab.NamedSubStrings.Item(j).Name = "CABTRACK" Then
                                btLab.NamedSubStrings.Item(j).Value = CABTRACK - 1
                            End If
                            'Set up which pictures will print out
                            If btLab.NamedSubStrings.Item(j).Name = "AGENCY1" Then
                                If IsDBNull(rsdata.Fields.Item("AGENCY1").Value) = True Then
                                    btLab.NamedSubStrings.Item(j).Value = ""
                                End If
                            End If
                            If btLab.NamedSubStrings.Item(j).Name = "AGENCY2" Then
                                If IsDBNull(rsdata.Fields.Item("AGENCY2").Value) = True Then
                                    btLab.NamedSubStrings.Item(j).Value = ""
                                End If
                            End If
                            If btLab.NamedSubStrings.Item(j).Name = "AGENCY3" Then
                                If IsDBNull(rsdata.Fields.Item("AGENCY3").Value) = True Then
                                    btLab.NamedSubStrings.Item(j).Value = ""
                                End If
                            End If
                        Next j

                        'btLab.IdenticalCopiesOfLabel = LabQty
                        btLab.PrintOut()
                        btLab.Close(BarTender.BtSaveOptions.btDoNotSaveChanges)


                        btLab = btApp.Formats.Open(LabDir & LabFor2)

                        '*****************************************************************************************************************
                        '***********************************Printer Selection Changed to data 3/30/2009***********************************
                        '*****************************************************************************************************************
                        rsdata9 = New ADODB.Recordset
                        rsdata9.Open("SELECT Printer FROM tblPrinter WHERE Labels='" & LabFor1 & "';", cnData)
                        btLab.Printer = rsdata9.Fields.Item("Printer").Value

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
                        For j = 1 To btLab.NamedSubStrings.Count
                            '****** Assign User Input to Label Sub Strings ******
                            If btLab.NamedSubStrings.Item(j).Name = "SYSTR" Then
                                btLab.NamedSubStrings.Item(j).Value = txtSYSTR.Text
                            End If
                            If btLab.NamedSubStrings.Item(j).Name = "UPSTYPE" Then
                                btLab.NamedSubStrings.Item(j).Value = UPSTYPE
                            End If
                            If btLab.NamedSubStrings.Item(j).Name = "INA" Then
                                btLab.NamedSubStrings.Item(j).Value = INA
                            End If
                            If btLab.NamedSubStrings.Item(j).Name = "Serial" Then
                                btLab.NamedSubStrings.Item(j).Value = SerialStr & Serial
                            End If
                            If btLab.NamedSubStrings.Item(j).Name = "CABTRACK" Then
                                btLab.NamedSubStrings.Item(j).Value = CABTRACK - 1
                            End If
                            'Set up which pictures will print out
                            If btLab.NamedSubStrings.Item(j).Name = "AGENCY1" Then
                                If IsDBNull(rsdata.Fields.Item("AGENCY1").Value) = True Then
                                    btLab.NamedSubStrings.Item(j).Value = ""
                                End If
                            End If
                            If btLab.NamedSubStrings.Item(j).Name = "AGENCY2" Then
                                If IsDBNull(rsdata.Fields.Item("AGENCY2").Value) = True Then
                                    btLab.NamedSubStrings.Item(j).Value = ""
                                End If
                            End If
                            If btLab.NamedSubStrings.Item(j).Name = "AGENCY3" Then
                                If IsDBNull(rsdata.Fields.Item("AGENCY3").Value) = True Then
                                    btLab.NamedSubStrings.Item(j).Value = ""
                                End If
                            End If
                        Next j

                        'btLab.IdenticalCopiesOfLabel = LabQty
                        btLab.PrintOut()
                        btLab.Close(BarTender.BtSaveOptions.btDoNotSaveChanges)

                        btLab = btApp.Formats.Open(LabDir & LabFor3)

                        '*****************************************************************************************************************
                        '***********************************Printer Selection Changed to data 3/30/2009***********************************
                        '*****************************************************************************************************************
                        rsdata9 = New ADODB.Recordset
                        rsdata9.Open("SELECT Printer FROM tblPrinter WHERE Labels='" & LabFor1 & "';", cnData)
                        btLab.Printer = rsdata9.Fields.Item("Printer").Value

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
                        For j = 1 To btLab.NamedSubStrings.Count
                            '****** Assign User Input to Label Sub Strings ******
                            If btLab.NamedSubStrings.Item(j).Name = "SYSTR" Then
                                btLab.NamedSubStrings.Item(j).Value = txtSYSTR.Text
                            End If
                            If btLab.NamedSubStrings.Item(j).Name = "UPSTYPE" Then
                                btLab.NamedSubStrings.Item(j).Value = UPSTYPE
                            End If
                            If btLab.NamedSubStrings.Item(j).Name = "INA" Then
                                btLab.NamedSubStrings.Item(j).Value = INA
                            End If
                            If btLab.NamedSubStrings.Item(j).Name = "Serial" Then
                                btLab.NamedSubStrings.Item(j).Value = SerialStr & Serial
                            End If
                            If btLab.NamedSubStrings.Item(j).Name = "CABTRACK" Then
                                btLab.NamedSubStrings.Item(j).Value = CABTRACK
                            End If
                            'Set up which pictures will print out
                            If btLab.NamedSubStrings.Item(j).Name = "AGENCY1" Then
                                If IsDBNull(rsdata.Fields.Item("AGENCY1").Value) = True Then
                                    btLab.NamedSubStrings.Item(j).Value = ""
                                End If
                            End If
                            If btLab.NamedSubStrings.Item(j).Name = "AGENCY2" Then
                                If IsDBNull(rsdata.Fields.Item("AGENCY2").Value) = True Then
                                    btLab.NamedSubStrings.Item(j).Value = ""
                                End If
                            End If
                            If btLab.NamedSubStrings.Item(j).Name = "AGENCY3" Then
                                If IsDBNull(rsdata.Fields.Item("AGENCY3").Value) = True Then
                                    btLab.NamedSubStrings.Item(j).Value = ""
                                End If
                            End If
                        Next j

                        'btLab.IdenticalCopiesOfLabel = LabQty
                        btLab.PrintOut()
                        btLab.Close(BarTender.BtSaveOptions.btDoNotSaveChanges)

                    Case 3


                        btLab = btApp.Formats.Open(LabDir & LabFor4)

                        '*****************************************************************************************************************
                        '***********************************Printer Selection Changed to data 3/30/2009***********************************
                        '*****************************************************************************************************************
                        rsdata9 = New ADODB.Recordset
                        rsdata9.Open("SELECT Printer FROM tblPrinter WHERE Labels='" & LabFor1 & "';", cnData)
                        btLab.Printer = rsdata9.Fields.Item("Printer").Value

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
                        For j = 1 To btLab.NamedSubStrings.Count
                            '****** Assign User Input to Label Sub Strings ******
                            If btLab.NamedSubStrings.Item(j).Name = "SYSTR" Then
                                btLab.NamedSubStrings.Item(j).Value = txtSYSTR.Text
                            End If
                            If btLab.NamedSubStrings.Item(j).Name = "UPSTYPE" Then
                                btLab.NamedSubStrings.Item(j).Value = UPSTYPE
                            End If
                            If btLab.NamedSubStrings.Item(j).Name = "INA" Then
                                btLab.NamedSubStrings.Item(j).Value = INA
                            End If
                            If btLab.NamedSubStrings.Item(j).Name = "Serial" Then
                                btLab.NamedSubStrings.Item(j).Value = SerialStr & Serial
                            End If
                            If btLab.NamedSubStrings.Item(j).Name = "CABTRACK" Then
                                btLab.NamedSubStrings.Item(j).Value = CABTRACK
                            End If
                            'Set up which pictures will print out
                            If btLab.NamedSubStrings.Item(j).Name = "AGENCY1" Then
                                If IsDBNull(rsdata.Fields.Item("AGENCY1").Value) = True Then
                                    btLab.NamedSubStrings.Item(j).Value = ""
                                End If
                            End If
                            If btLab.NamedSubStrings.Item(j).Name = "AGENCY2" Then
                                If IsDBNull(rsdata.Fields.Item("AGENCY2").Value) = True Then
                                    btLab.NamedSubStrings.Item(j).Value = ""
                                End If
                            End If
                            If btLab.NamedSubStrings.Item(j).Name = "AGENCY3" Then
                                If IsDBNull(rsdata.Fields.Item("AGENCY3").Value) = True Then
                                    btLab.NamedSubStrings.Item(j).Value = ""
                                End If
                            End If
                        Next j

                        'btLab.IdenticalCopiesOfLabel = LabQty
                        btLab.PrintOut()
                        btLab.Close(BarTender.BtSaveOptions.btDoNotSaveChanges)

                End Select

                CABTRACK = CABTRACK + 1

                Select Case Mid(rsdata.Fields.Item("SerialProcess").Value, 4, 1)
                    Case "R"
                        'Do nothing serial does not increment

                    Case "I"
                        If Loop2 <= Val(txtPrintQty.Text) Then
                            Select Case Mid(rsdata.Fields.Item("SerialProcess").Value, 1, 3)
                                Case "RG1"
                                    If Trim(Serial) = "100" Then Serial = "1"
                                    Serial = Serial.PadLeft(2, "0")

                                Case "RG2"
                                    If Trim(Serial) = "10000" Then Serial = "1"
                                    Serial = Serial.PadLeft(4, "0")

                                Case "HP1"
                                    If Trim(Serial) = "10000" Then Serial = "1"
                                    Serial = Serial.PadLeft(4, "0")
                            End Select
                        End If

                End Select

            End While

            'Call Writeback
            If rdoOldSerialNum.Checked = False Then WriteBack()

            If Mid(rsdata.Fields.Item("SerialProcess").Value, 4, 1) = "R" Then
                Serial = Trim(Str(Val(Serial) + 1))
            End If
            Select Case Mid(rsdata.Fields.Item("SerialProcess").Value, 1, 3)
                Case "RG1"
                    If Trim(Serial) = "100" Then Serial = "1"
                    Serial = Serial.PadLeft(2, "0")

                Case "RG2"
                    If Trim(Serial) = "10000" Then Serial = "1"
                    Serial = Serial.PadLeft(4, "0")

                Case "HP1"
                    If Trim(Serial) = "10000" Then Serial = "1"
                    Serial = Serial.PadLeft(4, "0")
            End Select

            If rdoNewLabel.Checked = True Then
                rsdata3.Fields.Item("Serial").Value = Trim(Str(Val(Serial)))
                rsdata3.Update()
                If Loop2 = Val(txtPrintQty.Text) Then
                    rsdata3.Close()
                End If

            End If

            Loop2 = Loop2 + 1
            Loop3 = Loop3 + 1

            If ProdType <> "ePDUa" Then
                Dim chkSysTrack As Integer
                chkSysTrack = 0
                If LoopTrk < Val(txtPrintQty.Text) Then
                    If Len(txtSYSTR.Text) > 0 Then '(If the SYSTR sting is empty or null then skip this routine for all labels. If the SYSTR has a value then run this routine)
                        While chkSysTrack = 0
                            SysTrack = InputBox("Please enter the System Tracking Number (without the -)", "System Tracking Number", txtSYSTR.Text)
                            If Len(SysTrack) > 7 Or IsNumeric(SysTrack) = False Then
                                MsgBox("You can only enter 7 numeric only digits for the sytem number")
                                chkSysTrack = 0
                            Else
                                chkSysTrack = 1
                            End If
                        End While
                        txtSYSTR.Text = SysTrack
                        SYSTR = SysTrack
                    End If
                End If
                LoopTrk = LoopTrk + 1
            End If

        End While

        rsdata2.Close()
        rsdata.CancelUpdate()
        rsdata.Close()
        cnData.Close()
        Call ClearForm()

    End Sub

    Private Sub PrintRoutine3()
        Dim j, i, newBatQty, LoopTrk As Integer
        Dim Loop3, RLNumber, SysTrack As String
        LoopTrk = 1
        RLNumber = ""
        Serial = ""

        If rdoNewLabel.Checked = True Then
            rsdata3 = New ADODB.Recordset
            rsdata3.Open("SELECT Serial FROM tblSerial WHERE App='" & rsdata.Fields.Item("SERIALTYPE").Value & "';", cnData, ADODB.CursorTypeEnum.adOpenDynamic, ADODB.LockTypeEnum.adLockOptimistic)
            Serial = rsdata3.Fields.Item("Serial").Value
        End If
        If rdoOldSerialNum.Checked = True Then
            SerialBx = InputBox("Please enter the complete old serial number for the nameplate", "Old Serial Entry")
            SerialBx = UCase(SerialBx)
            If SerialBx = "" Then
                MsgBox("You must supply the old serial number to continue")
                Exit Sub
            End If
            SerialStr = Mid(SerialBx, 1, 6)
            Serial = Mid(SerialBx, 7, 4)
        End If
        If rdoNewRLNum.Checked = True Then
            rsdata3 = New ADODB.Recordset
            rsdata3.Open("SELECT Serial FROM tblSerial WHERE App='" & rsdata.Fields.Item("SERIALTYPE").Value & "';", cnData, ADODB.CursorTypeEnum.adOpenDynamic, ADODB.LockTypeEnum.adLockOptimistic)
            Serial = rsdata3.Fields.Item("Serial").Value
            If Serial = "100" Then Serial = "1"
            If F2 Is Nothing Then
                F2 = New frmRL
                F2.ShowDialog()
            End If
            Exit Sub
        End If
        If rdoOldSerialRLNum.Checked = True Then
            If F2 Is Nothing Then
                F2 = New frmRL
                F2.ShowDialog()
            End If
            Exit Sub
        End If

        Loop3 = 1

        If LabFor1 = "9315BAT" Then
            newBatQty = Mid(txtCTO.Text, 9, 1)
            rsdata.Fields.Item("CABTOT").Value = newBatQty
        End If
        If LabFor1 = "9390BAT" Then
            newBatQty = Mid(txtCTO.Text, 10, 1)
            rsdata.Fields.Item("CABTOT").Value = newBatQty
        End If

        While Loop3 <= Val(txtPrintQty.Text)

            '*****************************************************************************************************************
            '***********************************Serial Selection Changed to data 3/30/2009************************************
            '*****************************************************************************************************************
            Select Case Mid(rsdata.Fields.Item("SerialProcess").Value, 1, 3)
                Case "RG1"
                    If Trim(Serial) = "100" Then Serial = "1"
                    Serial = Serial.PadLeft(2, "0")

                Case "RG2"
                    If Trim(Serial) = "10000" Then Serial = "1"
                    Serial = Serial.PadLeft(4, "0")

                Case "HP1"
                    If Trim(Serial) = "10000" Then Serial = "1"
                    Serial = Serial.PadLeft(4, "0")
            End Select

            CABTRACK = 1
            While CABTRACK <= rsdata.Fields.Item("CABTOT").Value

                btLab = btApp.Formats.Open(LabDir & LabFor1)

                '*****************************************************************************************************************
                '***********************************Printer Selection Changed to data 3/30/2009***********************************
                '*****************************************************************************************************************
                rsdata9 = New ADODB.Recordset
                rsdata9.Open("SELECT Printer FROM tblPrinter WHERE Labels='" & LabFor1 & "';", cnData)
                btLab.Printer = rsdata9.Fields.Item("Printer").Value


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
                For j = 1 To btLab.NamedSubStrings.Count
                    '****** Assign User Input to Label Sub Strings ******
                    If btLab.NamedSubStrings.Item(j).Name = "SYSTR" Then
                        btLab.NamedSubStrings.Item(j).Value = txtSYSTR.Text
                    End If
                    If btLab.NamedSubStrings.Item(j).Name = "UPSTYPE" Then
                        btLab.NamedSubStrings.Item(j).Value = UPSTYPE
                    End If
                    If btLab.NamedSubStrings.Item(j).Name = "INA" Then
                        btLab.NamedSubStrings.Item(j).Value = INA
                    End If
                    If btLab.NamedSubStrings.Item(j).Name = "Serial" Then
                        btLab.NamedSubStrings.Item(j).Value = SerialStr & Serial
                    End If
                    If btLab.NamedSubStrings.Item(j).Name = "CABTRACK" Then
                        btLab.NamedSubStrings.Item(j).Value = CABTRACK
                    End If
                    'Set up which pictures will print out
                    If btLab.NamedSubStrings.Item(j).Name = "AGENCY1" Then
                        If IsDBNull(rsdata.Fields.Item("AGENCY1").Value) = True Then
                            btLab.NamedSubStrings.Item(j).Value = ""
                        End If
                    End If
                    If btLab.NamedSubStrings.Item(j).Name = "AGENCY2" Then
                        If IsDBNull(rsdata.Fields.Item("AGENCY2").Value) = True Then
                            btLab.NamedSubStrings.Item(j).Value = ""
                        End If
                    End If
                    If btLab.NamedSubStrings.Item(j).Name = "AGENCY3" Then
                        If IsDBNull(rsdata.Fields.Item("AGENCY3").Value) = True Then
                            btLab.NamedSubStrings.Item(j).Value = ""
                        End If
                    End If

                Next j

                'btLab.IdenticalCopiesOfLabel = LabQty
                btLab.PrintOut()
                btLab.Close(BarTender.BtSaveOptions.btDoNotSaveChanges)

                CABTRACK = CABTRACK + 1

                Select Case Mid(rsdata.Fields.Item("SerialProcess").Value, 4, 1)
                    Case "R"
                        'Do nothing serial does not increment

                    Case "I"
                        If Loop3 <= Val(txtPrintQty.Text) Then
                            Select Case Mid(rsdata.Fields.Item("SerialProcess").Value, 1, 3)
                                Case "RG1"
                                    If Trim(Serial) = "100" Then Serial = "1"
                                    Serial = Serial.PadLeft(2, "0")

                                Case "RG2"
                                    If Trim(Serial) = "10000" Then Serial = "1"
                                    Serial = Serial.PadLeft(4, "0")

                                Case "HP1"
                                    If Trim(Serial) = "10000" Then Serial = "1"
                                    Serial = Serial.PadLeft(4, "0")
                            End Select
                        End If

                End Select

            End While

            'Call Writeback
            If rdoOldSerialNum.Checked = False Then WriteBack()

            If Mid(rsdata.Fields.Item("SerialProcess").Value, 4, 1) = "R" Then
                Serial = Trim(Str(Val(Serial) + 1))
            End If
            Select Case Mid(rsdata.Fields.Item("SerialProcess").Value, 1, 3)
                Case "RG1"
                    If Trim(Serial) = "100" Then Serial = "1"
                    Serial = Serial.PadLeft(2, "0")

                Case "RG2"
                    If Trim(Serial) = "10000" Then Serial = "1"
                    Serial = Serial.PadLeft(4, "0")

                Case "HP1"
                    If Trim(Serial) = "10000" Then Serial = "1"
                    Serial = Serial.PadLeft(4, "0")
            End Select

            If rdoNewLabel.Checked = True Then
                rsdata3.Fields.Item("Serial").Value = Trim(Str(Val(Serial)))
                rsdata3.Update()
                If Loop3 = Val(txtPrintQty.Text) Then
                    rsdata3.Close()
                End If
            End If

            Loop3 = Loop3 + 1

            If UCase(ProdType) <> "EPDUA" Then
                Dim chkSysTrack As Integer
                chkSysTrack = 0
                If LoopTrk < Val(txtPrintQty.Text) Then
                    If Len(txtSYSTR.Text) > 0 Then '(If the SYSTR sting is empty or null then skip this routine for all labels. If the SYSTR has a value then run this routine)
                        While chkSysTrack = 0
                            SysTrack = InputBox("Please enter the System Tracking Number (without the -)", "System Tracking Number", txtSYSTR.Text)
                            If Len(SysTrack) > 7 Or IsNumeric(SysTrack) = False Then
                                MsgBox("You can only enter 7 numeric only digits for the sytem number")
                                chkSysTrack = 0
                            Else
                                chkSysTrack = 1
                            End If
                        End While
                        txtSYSTR.Text = SysTrack
                        SYSTR = SysTrack
                    End If
                End If
                LoopTrk = LoopTrk + 1
            End If

        End While

        rsdata2.Close()
        rsdata.CancelUpdate()
        rsdata.Close()
        rsdata9.Close()
        cnData.Close()
        Call ClearForm()

    End Sub
    Private Sub PrintRoutine4()
        Dim j, i, LoopTrk As Integer
        Dim Loop3, Loop4, RLNumber, SysTrack As String

        LoopTrk = 1
        RLNumber = ""
        Serial = ""

        If rdoNewLabel.Checked = True Then
            rsdata3 = New ADODB.Recordset
            rsdata3.Open("SELECT Serial FROM tblSerial WHERE App='" & rsdata.Fields.Item("SERIALTYPE").Value & "';", cnData, ADODB.CursorTypeEnum.adOpenDynamic, ADODB.LockTypeEnum.adLockOptimistic)
            Serial = rsdata3.Fields.Item("Serial").Value
            If Serial = "100" Then Serial = "1"
        End If
        If rdoOldSerialNum.Checked = True Then
            SerialBx = InputBox("Please enter the complete old serial number for the nameplate", "Old Serial Entry")
            SerialBx = UCase(SerialBx)
            If SerialBx = "" Then
                MsgBox("You must supply the old serial number to continue")
                Exit Sub
            End If
            SerialStr = Mid(SerialBx, 1, 6)
            Serial = Mid(SerialBx, 7, 4)
        End If
        If rdoNewRLNum.Checked = True Then
            rsdata3 = New ADODB.Recordset
            rsdata3.Open("SELECT Serial FROM tblSerial WHERE App='" & rsdata.Fields.Item("SERIALTYPE").Value & "';", cnData, ADODB.CursorTypeEnum.adOpenDynamic, ADODB.LockTypeEnum.adLockOptimistic)
            Serial = rsdata3.Fields.Item("Serial").Value
            If Serial = "100" Then Serial = "1"
            If F2 Is Nothing Then
                F2 = New frmRL
                F2.ShowDialog()
                Call ClearForm()
            End If
            Exit Sub
        End If
        If rdoOldSerialRLNum.Checked = True Then
            If F2 Is Nothing Then
                F2 = New frmRL
                F2.ShowDialog()
                Call ClearForm()
            End If
            Exit Sub
        End If

        Loop4 = 1

        While Loop4 <= Val(txtPrintQty.Text)

            '*****************************************************************************************************************
            '***********************************Serial Selection Changed to data 3/30/2009************************************
            '*****************************************************************************************************************
            Select Case Mid(rsdata.Fields.Item("SerialProcess").Value, 1, 3)
                Case "RG1"
                    If Trim(Serial) = "100" Then Serial = "1"
                    Serial = Serial.PadLeft(2, "0")

                Case "RG2"
                    If Trim(Serial) = "10000" Then Serial = "1"
                    Serial = Serial.PadLeft(4, "0")

                Case "HP1"
                    If Trim(Serial) = "10000" Then Serial = "1"
                    Serial = Serial.PadLeft(4, "0")
            End Select

            CABTRACK = 1

            While CABTRACK <= NewCab + 1

                Select Case CABTRACK
                    Case 1
                        btLab = btApp.Formats.Open(LabDir & LabFor1)

                        '*****************************************************************************************************************
                        '***********************************Printer Selection Changed to data 3/30/2009***********************************
                        '*****************************************************************************************************************
                        rsdata9 = New ADODB.Recordset
                        rsdata9.Open("SELECT Printer FROM tblPrinter WHERE Labels='" & LabFor1 & "';", cnData)
                        btLab.Printer = rsdata9.Fields.Item("Printer").Value

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
                        For j = 1 To btLab.NamedSubStrings.Count
                            '****** Assign User Input to Label Sub Strings ******
                            If btLab.NamedSubStrings.Item(j).Name = "SYSTR" Then
                                btLab.NamedSubStrings.Item(j).Value = txtSYSTR.Text
                            End If
                            If btLab.NamedSubStrings.Item(j).Name = "UPSTYPE" Then
                                btLab.NamedSubStrings.Item(j).Value = UPSTYPE
                            End If
                            If btLab.NamedSubStrings.Item(j).Name = "INA" Then
                                btLab.NamedSubStrings.Item(j).Value = INA
                            End If
                            If btLab.NamedSubStrings.Item(j).Name = "Serial" Then
                                btLab.NamedSubStrings.Item(j).Value = SerialStr & Serial
                            End If
                            If btLab.NamedSubStrings.Item(j).Name = "CABTRACK" Then
                                btLab.NamedSubStrings.Item(j).Value = CABTRACK
                            End If
                            'Set up which pictures will print out
                            If btLab.NamedSubStrings.Item(j).Name = "AGENCY1" Then
                                If IsDBNull(rsdata.Fields.Item("AGENCY1").Value) = True Then
                                    btLab.NamedSubStrings.Item(j).Value = ""
                                End If
                            End If
                            If btLab.NamedSubStrings.Item(j).Name = "AGENCY2" Then
                                If IsDBNull(rsdata.Fields.Item("AGENCY2").Value) = True Then
                                    btLab.NamedSubStrings.Item(j).Value = ""
                                End If
                            End If
                            If btLab.NamedSubStrings.Item(j).Name = "AGENCY3" Then
                                If IsDBNull(rsdata.Fields.Item("AGENCY3").Value) = True Then
                                    btLab.NamedSubStrings.Item(j).Value = ""
                                End If
                            End If

                        Next j

                        'btLab.IdenticalCopiesOfLabel = LabQty
                        btLab.PrintOut()
                        btLab.Close(BarTender.BtSaveOptions.btDoNotSaveChanges)

                    Case 2

                        btLab = btApp.Formats.Open(LabDir & LabFor2)

                        '*****************************************************************************************************************
                        '***********************************Printer Selection Changed to data 3/30/2009***********************************
                        '*****************************************************************************************************************
                        rsdata9 = New ADODB.Recordset
                        rsdata9.Open("SELECT Printer FROM tblPrinter WHERE Labels='" & LabFor1 & "';", cnData)
                        btLab.Printer = rsdata9.Fields.Item("Printer").Value

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
                        For j = 1 To btLab.NamedSubStrings.Count
                            '****** Assign User Input to Label Sub Strings ******
                            If btLab.NamedSubStrings.Item(j).Name = "SYSTR" Then
                                btLab.NamedSubStrings.Item(j).Value = txtSYSTR.Text
                            End If
                            If btLab.NamedSubStrings.Item(j).Name = "UPSTYPE" Then
                                btLab.NamedSubStrings.Item(j).Value = UPSTYPE
                            End If
                            If btLab.NamedSubStrings.Item(j).Name = "INA" Then
                                btLab.NamedSubStrings.Item(j).Value = INA
                            End If
                            If btLab.NamedSubStrings.Item(j).Name = "Serial" Then
                                btLab.NamedSubStrings.Item(j).Value = SerialStr & Serial
                            End If
                            If btLab.NamedSubStrings.Item(j).Name = "CABTRACK" Then
                                btLab.NamedSubStrings.Item(j).Value = CABTRACK - 1
                            End If
                            'Set up which pictures will print out
                            If btLab.NamedSubStrings.Item(j).Name = "AGENCY1" Then
                                If IsDBNull(rsdata.Fields.Item("AGENCY1").Value) = True Then
                                    btLab.NamedSubStrings.Item(j).Value = ""
                                End If
                            End If
                            If btLab.NamedSubStrings.Item(j).Name = "AGENCY2" Then
                                If IsDBNull(rsdata.Fields.Item("AGENCY2").Value) = True Then
                                    btLab.NamedSubStrings.Item(j).Value = ""
                                End If
                            End If
                            If btLab.NamedSubStrings.Item(j).Name = "AGENCY3" Then
                                If IsDBNull(rsdata.Fields.Item("AGENCY3").Value) = True Then
                                    btLab.NamedSubStrings.Item(j).Value = ""
                                End If
                            End If
                        Next j

                        'btLab.IdenticalCopiesOfLabel = LabQty
                        btLab.PrintOut()
                        btLab.Close(BarTender.BtSaveOptions.btDoNotSaveChanges)

                    Case 3


                        btLab = btApp.Formats.Open(LabDir & LabFor3)

                        '*****************************************************************************************************************
                        '***********************************Printer Selection Changed to data 3/30/2009***********************************
                        '*****************************************************************************************************************
                        rsdata9 = New ADODB.Recordset
                        rsdata9.Open("SELECT Printer FROM tblPrinter WHERE Labels='" & LabFor1 & "';", cnData)
                        btLab.Printer = rsdata9.Fields.Item("Printer").Value

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
                        For j = 1 To btLab.NamedSubStrings.Count
                            '****** Assign User Input to Label Sub Strings ******
                            If btLab.NamedSubStrings.Item(j).Name = "SYSTR" Then
                                btLab.NamedSubStrings.Item(j).Value = txtSYSTR.Text
                            End If
                            If btLab.NamedSubStrings.Item(j).Name = "UPSTYPE" Then
                                btLab.NamedSubStrings.Item(j).Value = UPSTYPE
                            End If
                            If btLab.NamedSubStrings.Item(j).Name = "INA" Then
                                btLab.NamedSubStrings.Item(j).Value = INA
                            End If
                            If btLab.NamedSubStrings.Item(j).Name = "Serial" Then
                                btLab.NamedSubStrings.Item(j).Value = SerialStr & Serial
                            End If
                            If btLab.NamedSubStrings.Item(j).Name = "CABTRACK" Then
                                btLab.NamedSubStrings.Item(j).Value = CABTRACK
                            End If
                            'Set up which pictures will print out
                            If btLab.NamedSubStrings.Item(j).Name = "AGENCY1" Then
                                If IsDBNull(rsdata.Fields.Item("AGENCY1").Value) = True Then
                                    btLab.NamedSubStrings.Item(j).Value = ""
                                End If
                            End If
                            If btLab.NamedSubStrings.Item(j).Name = "AGENCY2" Then
                                If IsDBNull(rsdata.Fields.Item("AGENCY2").Value) = True Then
                                    btLab.NamedSubStrings.Item(j).Value = ""
                                End If
                            End If
                            If btLab.NamedSubStrings.Item(j).Name = "AGENCY3" Then
                                If IsDBNull(rsdata.Fields.Item("AGENCY3").Value) = True Then
                                    btLab.NamedSubStrings.Item(j).Value = ""
                                End If
                            End If
                        Next j

                        'btLab.IdenticalCopiesOfLabel = LabQty
                        btLab.PrintOut()
                        btLab.Close(BarTender.BtSaveOptions.btDoNotSaveChanges)

                    Case 4

                        btLab = btApp.Formats.Open(LabDir & LabFor4)

                        '*****************************************************************************************************************
                        '***********************************Printer Selection Changed to data 3/30/2009***********************************
                        '*****************************************************************************************************************
                        rsdata9 = New ADODB.Recordset
                        rsdata9.Open("SELECT Printer FROM tblPrinter WHERE Labels='" & LabFor1 & "';", cnData)
                        btLab.Printer = rsdata9.Fields.Item("Printer").Value

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
                        For j = 1 To btLab.NamedSubStrings.Count
                            '****** Assign User Input to Label Sub Strings ******
                            If btLab.NamedSubStrings.Item(j).Name = "SYSTR" Then
                                btLab.NamedSubStrings.Item(j).Value = txtSYSTR.Text
                            End If
                            If btLab.NamedSubStrings.Item(j).Name = "UPSTYPE" Then
                                btLab.NamedSubStrings.Item(j).Value = UPSTYPE
                            End If
                            If btLab.NamedSubStrings.Item(j).Name = "INA" Then
                                btLab.NamedSubStrings.Item(j).Value = INA
                            End If
                            If btLab.NamedSubStrings.Item(j).Name = "Serial" Then
                                btLab.NamedSubStrings.Item(j).Value = SerialStr & Serial
                            End If
                            If btLab.NamedSubStrings.Item(j).Name = "CABTRACK" Then
                                btLab.NamedSubStrings.Item(j).Value = CABTRACK
                            End If
                            'Set up which pictures will print out
                            If btLab.NamedSubStrings.Item(j).Name = "AGENCY1" Then
                                If IsDBNull(rsdata.Fields.Item("AGENCY1").Value) = True Then
                                    btLab.NamedSubStrings.Item(j).Value = ""
                                End If
                            End If
                            If btLab.NamedSubStrings.Item(j).Name = "AGENCY2" Then
                                If IsDBNull(rsdata.Fields.Item("AGENCY2").Value) = True Then
                                    btLab.NamedSubStrings.Item(j).Value = ""
                                End If
                            End If
                            If btLab.NamedSubStrings.Item(j).Name = "AGENCY3" Then
                                If IsDBNull(rsdata.Fields.Item("AGENCY3").Value) = True Then
                                    btLab.NamedSubStrings.Item(j).Value = ""
                                End If
                            End If
                        Next j

                        'btLab.IdenticalCopiesOfLabel = LabQty
                        btLab.PrintOut()
                        btLab.Close(BarTender.BtSaveOptions.btDoNotSaveChanges)

                End Select

                CABTRACK = CABTRACK + 1

                Select Case Mid(rsdata.Fields.Item("SerialProcess").Value, 4, 1)
                    Case "R"
                        'Do nothing serial does not increment

                    Case "I"
                        If Loop4 <= Val(txtPrintQty.Text) Then
                            Serial = Trim(Str(Val(Serial) + 1))
                            Select Case Mid(rsdata.Fields.Item("SerialProcess").Value, 1, 3)
                                Case "RG1"
                                    If Trim(Serial) = "100" Then Serial = "1"
                                    Serial = Serial.PadLeft(2, "0")

                                Case "RG2"
                                    If Trim(Serial) = "10000" Then Serial = "1"
                                    Serial = Serial.PadLeft(4, "0")

                                Case "HP1"
                                    If Trim(Serial) = "10000" Then Serial = "1"
                                    Serial = Serial.PadLeft(4, "0")
                            End Select
                        End If

                End Select

            End While

            'Call Writeback
            If rdoOldSerialNum.Checked = False Then WriteBack()

            If Mid(rsdata.Fields.Item("SerialProcess").Value, 4, 1) = "R" Then
                Serial = Trim(Str(Val(Serial) + 1))
            End If
            Select Case Mid(rsdata.Fields.Item("SerialProcess").Value, 1, 3)
                Case "RG1"
                    If Trim(Serial) = "100" Then Serial = "1"
                    Serial = Serial.PadLeft(2, "0")

                Case "RG2"
                    If Trim(Serial) = "10000" Then Serial = "1"
                    Serial = Serial.PadLeft(4, "0")

                Case "HP1"
                    If Trim(Serial) = "10000" Then Serial = "1"
                    Serial = Serial.PadLeft(4, "0")
            End Select

            If rdoNewLabel.Checked = True Then
                rsdata3.Fields.Item("Serial").Value = Trim(Str(Val(Serial)))
                rsdata3.Update()
                If Loop4 = Val(txtPrintQty.Text) Then
                    rsdata3.Close()
                End If

            End If

            Loop4 = Loop4 + 1
            Loop3 = Loop3 + 1

            If ProdType <> "ePDUa" Then
                Dim chkSysTrack As Integer
                chkSysTrack = 0
                If LoopTrk < Val(txtPrintQty.Text) Then
                    If Len(txtSYSTR.Text) > 0 Then '(If the SYSTR sting is empty or null then skip this routine for all labels. If the SYSTR has a value then run this routine)
                        While chkSysTrack = 0
                            SysTrack = InputBox("Please enter the System Tracking Number (without the -)", "System Tracking Number", txtSYSTR.Text)
                            If Len(SysTrack) > 7 Or IsNumeric(SysTrack) = False Then
                                MsgBox("You can only enter 7 numeric only digits for the sytem number")
                                chkSysTrack = 0
                            Else
                                chkSysTrack = 1
                            End If
                        End While
                        txtSYSTR.Text = SysTrack
                        SYSTR = SysTrack
                    End If
                End If
                LoopTrk = LoopTrk + 1
            End If

        End While

        rsdata2.Close()
        rsdata.CancelUpdate()
        rsdata.Close()
        cnData.Close()
        Call ClearForm()

    End Sub


End Class





