<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class MainTestInterface
    Inherits System.Windows.Forms.Form

    'Form overrides dispose to clean up the component list.
    <System.Diagnostics.DebuggerNonUserCode()> _
    Protected Overrides Sub Dispose(ByVal disposing As Boolean)
        Try
            If disposing AndAlso components IsNot Nothing Then
                components.Dispose()
            End If
        Finally
            MyBase.Dispose(disposing)
        End Try
    End Sub

    'Required by the Windows Form Designer
    Private components As System.ComponentModel.IContainer

    'NOTE: The following procedure is required by the Windows Form Designer
    'It can be modified using the Windows Form Designer.  
    'Do not modify it using the code editor.
    <System.Diagnostics.DebuggerStepThrough()> _
    Private Sub InitializeComponent()
        Me.components = New System.ComponentModel.Container()
        Dim resources As System.ComponentModel.ComponentResourceManager = New System.ComponentModel.ComponentResourceManager(GetType(MainTestInterface))
        Dim DataGridViewCellStyle1 As System.Windows.Forms.DataGridViewCellStyle = New System.Windows.Forms.DataGridViewCellStyle()
        Dim DataGridViewCellStyle2 As System.Windows.Forms.DataGridViewCellStyle = New System.Windows.Forms.DataGridViewCellStyle()
        Dim DataGridViewCellStyle3 As System.Windows.Forms.DataGridViewCellStyle = New System.Windows.Forms.DataGridViewCellStyle()
        Dim DataGridViewCellStyle4 As System.Windows.Forms.DataGridViewCellStyle = New System.Windows.Forms.DataGridViewCellStyle()
        Me.MSComm1 = New System.IO.Ports.SerialPort(Me.components)
        Me.lblElapseTime = New System.Windows.Forms.Label()
        Me.lbl_TestName = New System.Windows.Forms.Label()
        Me.lbl_Notes = New System.Windows.Forms.Label()
        Me.lbl_Harness = New System.Windows.Forms.Label()
        Me.Label2 = New System.Windows.Forms.Label()
        Me.Label8 = New System.Windows.Forms.Label()
        Me.label20 = New System.Windows.Forms.Label()
        Me.Label10 = New System.Windows.Forms.Label()
        Me.lblEmployeeNumber = New System.Windows.Forms.Label()
        Me.lblEmployeeName = New System.Windows.Forms.Label()
        Me.PictureBox1 = New System.Windows.Forms.PictureBox()
        Me.lblState = New System.Windows.Forms.Label()
        Me.dgvStepResults = New System.Windows.Forms.DataGridView()
        Me.dgvAteOpData = New System.Windows.Forms.DataGridView()
        Me.lbl_PartNumber = New System.Windows.Forms.Label()
        Me.LblEndTestTime = New System.Windows.Forms.Label()
        Me.Panel_Main = New System.Windows.Forms.TableLayoutPanel()
        Me.TableLayoutPanel1 = New System.Windows.Forms.TableLayoutPanel()
        Me.TableLayoutPanel2 = New System.Windows.Forms.TableLayoutPanel()
        Me.TableLayoutPanel3 = New System.Windows.Forms.TableLayoutPanel()
        Me.TableLayoutPanel4 = New System.Windows.Forms.TableLayoutPanel()
        Me.TableLayoutPanel5 = New System.Windows.Forms.TableLayoutPanel()
        Me.TableLayoutPanel6 = New System.Windows.Forms.TableLayoutPanel()
        Me.TableLayoutPanel7 = New System.Windows.Forms.TableLayoutPanel()
        Me.TableLayoutPanel8 = New System.Windows.Forms.TableLayoutPanel()
        Me.LblDuration = New System.Windows.Forms.Label()
        Me.Lbl_SerialNumber = New System.Windows.Forms.Label()
        Me.txtSerialNumber = New System.Windows.Forms.TextBox()
        Me.LblStartTestTime = New System.Windows.Forms.Label()
        Me.Label5 = New System.Windows.Forms.Label()
        Me.Label4 = New System.Windows.Forms.Label()
        Me.TableLayoutPanel9 = New System.Windows.Forms.TableLayoutPanel()
        Me.Button1 = New System.Windows.Forms.Button()
        Me.btn_ManualUpdate = New System.Windows.Forms.Button()
        Me.btn_LoadXMLReport = New System.Windows.Forms.Button()
        Me.btn_SendReportToTDM = New System.Windows.Forms.Button()
        Me.btn_UpdateTestSpec = New System.Windows.Forms.Button()
        CType(Me.PictureBox1, System.ComponentModel.ISupportInitialize).BeginInit()
        CType(Me.dgvStepResults, System.ComponentModel.ISupportInitialize).BeginInit()
        CType(Me.dgvAteOpData, System.ComponentModel.ISupportInitialize).BeginInit()
        Me.Panel_Main.SuspendLayout()
        Me.TableLayoutPanel1.SuspendLayout()
        Me.TableLayoutPanel2.SuspendLayout()
        Me.TableLayoutPanel3.SuspendLayout()
        Me.TableLayoutPanel4.SuspendLayout()
        Me.TableLayoutPanel5.SuspendLayout()
        Me.TableLayoutPanel6.SuspendLayout()
        Me.TableLayoutPanel7.SuspendLayout()
        Me.TableLayoutPanel8.SuspendLayout()
        Me.TableLayoutPanel9.SuspendLayout()
        Me.SuspendLayout()
        '
        'lblElapseTime
        '
        Me.lblElapseTime.BackColor = System.Drawing.Color.FromArgb(CType(CType(255, Byte), Integer), CType(CType(192, Byte), Integer), CType(CType(192, Byte), Integer))
        Me.lblElapseTime.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D
        Me.lblElapseTime.Dock = System.Windows.Forms.DockStyle.Fill
        Me.lblElapseTime.Font = New System.Drawing.Font("Microsoft Sans Serif", 8.25!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.lblElapseTime.ForeColor = System.Drawing.Color.FromArgb(CType(CType(192, Byte), Integer), CType(CType(0, Byte), Integer), CType(CType(192, Byte), Integer))
        Me.lblElapseTime.Location = New System.Drawing.Point(110, 110)
        Me.lblElapseTime.Margin = New System.Windows.Forms.Padding(4, 0, 4, 0)
        Me.lblElapseTime.Name = "lblElapseTime"
        Me.lblElapseTime.Size = New System.Drawing.Size(98, 26)
        Me.lblElapseTime.TabIndex = 45
        Me.lblElapseTime.Text = "000.0"
        Me.lblElapseTime.TextAlign = System.Drawing.ContentAlignment.MiddleCenter
        '
        'lbl_TestName
        '
        Me.lbl_TestName.BackColor = System.Drawing.Color.FromArgb(CType(CType(255, Byte), Integer), CType(CType(192, Byte), Integer), CType(CType(192, Byte), Integer))
        Me.lbl_TestName.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D
        Me.lbl_TestName.Dock = System.Windows.Forms.DockStyle.Fill
        Me.lbl_TestName.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.75!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.lbl_TestName.ForeColor = System.Drawing.Color.FromArgb(CType(CType(192, Byte), Integer), CType(CType(0, Byte), Integer), CType(CType(192, Byte), Integer))
        Me.lbl_TestName.Location = New System.Drawing.Point(4, 0)
        Me.lbl_TestName.Margin = New System.Windows.Forms.Padding(4, 0, 4, 0)
        Me.lbl_TestName.Name = "lbl_TestName"
        Me.lbl_TestName.Size = New System.Drawing.Size(142, 34)
        Me.lbl_TestName.TabIndex = 37
        Me.lbl_TestName.Text = "TestName"
        Me.lbl_TestName.TextAlign = System.Drawing.ContentAlignment.MiddleLeft
        '
        'lbl_Notes
        '
        Me.lbl_Notes.BackColor = System.Drawing.Color.FromArgb(CType(CType(255, Byte), Integer), CType(CType(192, Byte), Integer), CType(CType(192, Byte), Integer))
        Me.lbl_Notes.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D
        Me.lbl_Notes.Dock = System.Windows.Forms.DockStyle.Fill
        Me.lbl_Notes.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.75!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.lbl_Notes.ForeColor = System.Drawing.Color.FromArgb(CType(CType(192, Byte), Integer), CType(CType(0, Byte), Integer), CType(CType(192, Byte), Integer))
        Me.lbl_Notes.Location = New System.Drawing.Point(4, 68)
        Me.lbl_Notes.Margin = New System.Windows.Forms.Padding(4, 0, 4, 0)
        Me.lbl_Notes.Name = "lbl_Notes"
        Me.lbl_Notes.Size = New System.Drawing.Size(142, 68)
        Me.lbl_Notes.TabIndex = 39
        Me.lbl_Notes.Text = "Notes"
        '
        'lbl_Harness
        '
        Me.lbl_Harness.BackColor = System.Drawing.Color.FromArgb(CType(CType(255, Byte), Integer), CType(CType(192, Byte), Integer), CType(CType(192, Byte), Integer))
        Me.lbl_Harness.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D
        Me.lbl_Harness.Dock = System.Windows.Forms.DockStyle.Fill
        Me.lbl_Harness.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.75!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.lbl_Harness.ForeColor = System.Drawing.Color.FromArgb(CType(CType(192, Byte), Integer), CType(CType(0, Byte), Integer), CType(CType(192, Byte), Integer))
        Me.lbl_Harness.Location = New System.Drawing.Point(4, 34)
        Me.lbl_Harness.Margin = New System.Windows.Forms.Padding(4, 0, 4, 0)
        Me.lbl_Harness.Name = "lbl_Harness"
        Me.lbl_Harness.Size = New System.Drawing.Size(142, 34)
        Me.lbl_Harness.TabIndex = 38
        Me.lbl_Harness.Text = "Harness"
        Me.lbl_Harness.TextAlign = System.Drawing.ContentAlignment.MiddleLeft
        '
        'Label2
        '
        Me.Label2.BackColor = System.Drawing.Color.FromArgb(CType(CType(255, Byte), Integer), CType(CType(192, Byte), Integer), CType(CType(192, Byte), Integer))
        Me.Label2.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D
        Me.Label2.Dock = System.Windows.Forms.DockStyle.Fill
        Me.Label2.Font = New System.Drawing.Font("Microsoft Sans Serif", 8.25!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Label2.ForeColor = System.Drawing.Color.FromArgb(CType(CType(192, Byte), Integer), CType(CType(0, Byte), Integer), CType(CType(192, Byte), Integer))
        Me.Label2.Location = New System.Drawing.Point(4, 44)
        Me.Label2.Margin = New System.Windows.Forms.Padding(4, 0, 4, 0)
        Me.Label2.Name = "Label2"
        Me.Label2.Size = New System.Drawing.Size(98, 22)
        Me.Label2.TabIndex = 48
        Me.Label2.Text = "StartTime"
        Me.Label2.TextAlign = System.Drawing.ContentAlignment.MiddleLeft
        '
        'Label8
        '
        Me.Label8.BackColor = System.Drawing.Color.FromArgb(CType(CType(255, Byte), Integer), CType(CType(192, Byte), Integer), CType(CType(192, Byte), Integer))
        Me.Label8.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D
        Me.Label8.Dock = System.Windows.Forms.DockStyle.Fill
        Me.Label8.Font = New System.Drawing.Font("Microsoft Sans Serif", 8.25!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Label8.ForeColor = System.Drawing.Color.FromArgb(CType(CType(192, Byte), Integer), CType(CType(0, Byte), Integer), CType(CType(192, Byte), Integer))
        Me.Label8.Location = New System.Drawing.Point(4, 66)
        Me.Label8.Margin = New System.Windows.Forms.Padding(4, 0, 4, 0)
        Me.Label8.Name = "Label8"
        Me.Label8.Size = New System.Drawing.Size(98, 22)
        Me.Label8.TabIndex = 48
        Me.Label8.Text = "End Time"
        Me.Label8.TextAlign = System.Drawing.ContentAlignment.MiddleLeft
        '
        'label20
        '
        Me.label20.BackColor = System.Drawing.Color.FromArgb(CType(CType(255, Byte), Integer), CType(CType(192, Byte), Integer), CType(CType(192, Byte), Integer))
        Me.label20.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D
        Me.label20.Dock = System.Windows.Forms.DockStyle.Fill
        Me.label20.Font = New System.Drawing.Font("Microsoft Sans Serif", 8.25!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.label20.ForeColor = System.Drawing.Color.FromArgb(CType(CType(192, Byte), Integer), CType(CType(0, Byte), Integer), CType(CType(192, Byte), Integer))
        Me.label20.Location = New System.Drawing.Point(4, 22)
        Me.label20.Margin = New System.Windows.Forms.Padding(4, 0, 4, 0)
        Me.label20.Name = "label20"
        Me.label20.Size = New System.Drawing.Size(98, 22)
        Me.label20.TabIndex = 50
        Me.label20.Text = "Part Number"
        Me.label20.TextAlign = System.Drawing.ContentAlignment.MiddleLeft
        '
        'Label10
        '
        Me.Label10.AutoSize = True
        Me.Label10.BackColor = System.Drawing.Color.CornflowerBlue
        Me.Label10.Dock = System.Windows.Forms.DockStyle.Fill
        Me.Label10.ForeColor = System.Drawing.SystemColors.HighlightText
        Me.Label10.Location = New System.Drawing.Point(3, 0)
        Me.Label10.Name = "Label10"
        Me.Label10.Size = New System.Drawing.Size(23, 24)
        Me.Label10.TabIndex = 53
        Me.Label10.Text = "User："
        Me.Label10.TextAlign = System.Drawing.ContentAlignment.MiddleCenter
        '
        'lblEmployeeNumber
        '
        Me.lblEmployeeNumber.AutoSize = True
        Me.lblEmployeeNumber.BackColor = System.Drawing.Color.CornflowerBlue
        Me.lblEmployeeNumber.Dock = System.Windows.Forms.DockStyle.Fill
        Me.lblEmployeeNumber.ForeColor = System.Drawing.SystemColors.HighlightText
        Me.lblEmployeeNumber.Location = New System.Drawing.Point(90, 0)
        Me.lblEmployeeNumber.Name = "lblEmployeeNumber"
        Me.lblEmployeeNumber.Size = New System.Drawing.Size(53, 24)
        Me.lblEmployeeNumber.TabIndex = 53
        Me.lblEmployeeNumber.Text = "lblEmployeeNumber"
        Me.lblEmployeeNumber.TextAlign = System.Drawing.ContentAlignment.MiddleCenter
        '
        'lblEmployeeName
        '
        Me.lblEmployeeName.AutoSize = True
        Me.lblEmployeeName.BackColor = System.Drawing.Color.CornflowerBlue
        Me.lblEmployeeName.Dock = System.Windows.Forms.DockStyle.Fill
        Me.lblEmployeeName.ForeColor = System.Drawing.SystemColors.HighlightText
        Me.lblEmployeeName.Location = New System.Drawing.Point(32, 0)
        Me.lblEmployeeName.Name = "lblEmployeeName"
        Me.lblEmployeeName.Size = New System.Drawing.Size(52, 24)
        Me.lblEmployeeName.TabIndex = 53
        Me.lblEmployeeName.Text = "lblEmployeeName"
        Me.lblEmployeeName.TextAlign = System.Drawing.ContentAlignment.MiddleCenter
        '
        'PictureBox1
        '
        Me.PictureBox1.Dock = System.Windows.Forms.DockStyle.Fill
        Me.PictureBox1.ErrorImage = CType(resources.GetObject("PictureBox1.ErrorImage"), System.Drawing.Image)
        Me.PictureBox1.Image = CType(resources.GetObject("PictureBox1.Image"), System.Drawing.Image)
        Me.PictureBox1.Location = New System.Drawing.Point(3, 3)
        Me.PictureBox1.Name = "PictureBox1"
        Me.PictureBox1.Size = New System.Drawing.Size(144, 102)
        Me.PictureBox1.SizeMode = System.Windows.Forms.PictureBoxSizeMode.StretchImage
        Me.PictureBox1.TabIndex = 55
        Me.PictureBox1.TabStop = False
        '
        'lblState
        '
        Me.lblState.AutoSize = True
        Me.lblState.BackColor = System.Drawing.Color.FromArgb(CType(CType(128, Byte), Integer), CType(CType(255, Byte), Integer), CType(CType(128, Byte), Integer))
        Me.lblState.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
        Me.lblState.Dock = System.Windows.Forms.DockStyle.Fill
        Me.lblState.Font = New System.Drawing.Font("NSimSun", 28.2!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(134, Byte))
        Me.lblState.ForeColor = System.Drawing.SystemColors.WindowText
        Me.lblState.Location = New System.Drawing.Point(4, 0)
        Me.lblState.Margin = New System.Windows.Forms.Padding(4, 0, 4, 0)
        Me.lblState.Name = "lblState"
        Me.lblState.Size = New System.Drawing.Size(52, 136)
        Me.lblState.TabIndex = 42
        Me.lblState.Text = "Running"
        Me.lblState.TextAlign = System.Drawing.ContentAlignment.MiddleCenter
        '
        'dgvStepResults
        '
        Me.dgvStepResults.AllowUserToAddRows = False
        Me.dgvStepResults.AllowUserToDeleteRows = False
        DataGridViewCellStyle1.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft
        DataGridViewCellStyle1.BackColor = System.Drawing.SystemColors.Control
        DataGridViewCellStyle1.Font = New System.Drawing.Font("Microsoft Sans Serif", 8.25!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        DataGridViewCellStyle1.ForeColor = System.Drawing.SystemColors.WindowText
        DataGridViewCellStyle1.SelectionBackColor = System.Drawing.SystemColors.Highlight
        DataGridViewCellStyle1.SelectionForeColor = System.Drawing.SystemColors.HighlightText
        DataGridViewCellStyle1.WrapMode = System.Windows.Forms.DataGridViewTriState.[True]
        Me.dgvStepResults.ColumnHeadersDefaultCellStyle = DataGridViewCellStyle1
        Me.dgvStepResults.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize
        DataGridViewCellStyle2.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft
        DataGridViewCellStyle2.BackColor = System.Drawing.SystemColors.Window
        DataGridViewCellStyle2.Font = New System.Drawing.Font("Microsoft Sans Serif", 8.25!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        DataGridViewCellStyle2.ForeColor = System.Drawing.SystemColors.ControlText
        DataGridViewCellStyle2.SelectionBackColor = System.Drawing.SystemColors.Highlight
        DataGridViewCellStyle2.SelectionForeColor = System.Drawing.SystemColors.HighlightText
        DataGridViewCellStyle2.WrapMode = System.Windows.Forms.DataGridViewTriState.[False]
        Me.dgvStepResults.DefaultCellStyle = DataGridViewCellStyle2
        Me.dgvStepResults.Dock = System.Windows.Forms.DockStyle.Fill
        Me.dgvStepResults.Location = New System.Drawing.Point(2, 2)
        Me.dgvStepResults.Margin = New System.Windows.Forms.Padding(2)
        Me.dgvStepResults.Name = "dgvStepResults"
        Me.dgvStepResults.ReadOnly = True
        Me.dgvStepResults.RowTemplate.Height = 24
        Me.dgvStepResults.Size = New System.Drawing.Size(857, 243)
        Me.dgvStepResults.TabIndex = 0
        '
        'dgvAteOpData
        '
        Me.dgvAteOpData.AllowUserToAddRows = False
        Me.dgvAteOpData.AllowUserToDeleteRows = False
        DataGridViewCellStyle3.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft
        DataGridViewCellStyle3.BackColor = System.Drawing.SystemColors.Control
        DataGridViewCellStyle3.Font = New System.Drawing.Font("Microsoft Sans Serif", 8.25!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        DataGridViewCellStyle3.ForeColor = System.Drawing.SystemColors.WindowText
        DataGridViewCellStyle3.SelectionBackColor = System.Drawing.SystemColors.Highlight
        DataGridViewCellStyle3.SelectionForeColor = System.Drawing.SystemColors.HighlightText
        DataGridViewCellStyle3.WrapMode = System.Windows.Forms.DataGridViewTriState.[True]
        Me.dgvAteOpData.ColumnHeadersDefaultCellStyle = DataGridViewCellStyle3
        Me.dgvAteOpData.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize
        DataGridViewCellStyle4.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft
        DataGridViewCellStyle4.BackColor = System.Drawing.SystemColors.Window
        DataGridViewCellStyle4.Font = New System.Drawing.Font("Microsoft Sans Serif", 8.25!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        DataGridViewCellStyle4.ForeColor = System.Drawing.SystemColors.ControlText
        DataGridViewCellStyle4.SelectionBackColor = System.Drawing.SystemColors.Highlight
        DataGridViewCellStyle4.SelectionForeColor = System.Drawing.SystemColors.HighlightText
        DataGridViewCellStyle4.WrapMode = System.Windows.Forms.DataGridViewTriState.[False]
        Me.dgvAteOpData.DefaultCellStyle = DataGridViewCellStyle4
        Me.dgvAteOpData.Dock = System.Windows.Forms.DockStyle.Fill
        Me.dgvAteOpData.Location = New System.Drawing.Point(2, 2)
        Me.dgvAteOpData.Margin = New System.Windows.Forms.Padding(2)
        Me.dgvAteOpData.Name = "dgvAteOpData"
        Me.dgvAteOpData.RowTemplate.Height = 24
        Me.dgvAteOpData.Size = New System.Drawing.Size(588, 212)
        Me.dgvAteOpData.TabIndex = 58
        '
        'lbl_PartNumber
        '
        Me.lbl_PartNumber.AutoSize = True
        Me.lbl_PartNumber.Dock = System.Windows.Forms.DockStyle.Fill
        Me.lbl_PartNumber.Location = New System.Drawing.Point(108, 22)
        Me.lbl_PartNumber.Margin = New System.Windows.Forms.Padding(2, 0, 2, 0)
        Me.lbl_PartNumber.Name = "lbl_PartNumber"
        Me.lbl_PartNumber.Size = New System.Drawing.Size(102, 22)
        Me.lbl_PartNumber.TabIndex = 60
        Me.lbl_PartNumber.Text = "Part Number"
        Me.lbl_PartNumber.TextAlign = System.Drawing.ContentAlignment.MiddleCenter
        '
        'LblEndTestTime
        '
        Me.LblEndTestTime.AutoSize = True
        Me.LblEndTestTime.Dock = System.Windows.Forms.DockStyle.Fill
        Me.LblEndTestTime.Location = New System.Drawing.Point(108, 66)
        Me.LblEndTestTime.Margin = New System.Windows.Forms.Padding(2, 0, 2, 0)
        Me.LblEndTestTime.Name = "LblEndTestTime"
        Me.LblEndTestTime.Size = New System.Drawing.Size(102, 22)
        Me.LblEndTestTime.TabIndex = 62
        Me.LblEndTestTime.Text = "LblEndTestTime"
        Me.LblEndTestTime.TextAlign = System.Drawing.ContentAlignment.MiddleCenter
        '
        'Panel_Main
        '
        Me.Panel_Main.ColumnCount = 1
        Me.Panel_Main.ColumnStyles.Add(New System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 100.0!))
        Me.Panel_Main.Controls.Add(Me.dgvStepResults, 0, 0)
        Me.Panel_Main.Controls.Add(Me.TableLayoutPanel1, 0, 1)
        Me.Panel_Main.Dock = System.Windows.Forms.DockStyle.Fill
        Me.Panel_Main.Location = New System.Drawing.Point(0, 0)
        Me.Panel_Main.Margin = New System.Windows.Forms.Padding(2)
        Me.Panel_Main.Name = "Panel_Main"
        Me.Panel_Main.RowCount = 2
        Me.Panel_Main.RowStyles.Add(New System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 40.0!))
        Me.Panel_Main.RowStyles.Add(New System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 60.0!))
        Me.Panel_Main.Size = New System.Drawing.Size(861, 619)
        Me.Panel_Main.TabIndex = 64
        '
        'TableLayoutPanel1
        '
        Me.TableLayoutPanel1.ColumnCount = 2
        Me.TableLayoutPanel1.ColumnStyles.Add(New System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 70.0!))
        Me.TableLayoutPanel1.ColumnStyles.Add(New System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 30.0!))
        Me.TableLayoutPanel1.Controls.Add(Me.TableLayoutPanel2, 0, 0)
        Me.TableLayoutPanel1.Controls.Add(Me.TableLayoutPanel9, 1, 0)
        Me.TableLayoutPanel1.Dock = System.Windows.Forms.DockStyle.Fill
        Me.TableLayoutPanel1.Location = New System.Drawing.Point(3, 250)
        Me.TableLayoutPanel1.Name = "TableLayoutPanel1"
        Me.TableLayoutPanel1.RowCount = 1
        Me.TableLayoutPanel1.RowStyles.Add(New System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 100.0!))
        Me.TableLayoutPanel1.Size = New System.Drawing.Size(855, 366)
        Me.TableLayoutPanel1.TabIndex = 61
        '
        'TableLayoutPanel2
        '
        Me.TableLayoutPanel2.ColumnCount = 1
        Me.TableLayoutPanel2.ColumnStyles.Add(New System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 100.0!))
        Me.TableLayoutPanel2.Controls.Add(Me.dgvAteOpData, 0, 0)
        Me.TableLayoutPanel2.Controls.Add(Me.TableLayoutPanel3, 0, 1)
        Me.TableLayoutPanel2.Dock = System.Windows.Forms.DockStyle.Fill
        Me.TableLayoutPanel2.Location = New System.Drawing.Point(3, 3)
        Me.TableLayoutPanel2.Name = "TableLayoutPanel2"
        Me.TableLayoutPanel2.RowCount = 2
        Me.TableLayoutPanel2.RowStyles.Add(New System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 60.0!))
        Me.TableLayoutPanel2.RowStyles.Add(New System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 40.0!))
        Me.TableLayoutPanel2.Size = New System.Drawing.Size(592, 360)
        Me.TableLayoutPanel2.TabIndex = 0
        '
        'TableLayoutPanel3
        '
        Me.TableLayoutPanel3.ColumnCount = 4
        Me.TableLayoutPanel3.ColumnStyles.Add(New System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 26.31579!))
        Me.TableLayoutPanel3.ColumnStyles.Add(New System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 36.84211!))
        Me.TableLayoutPanel3.ColumnStyles.Add(New System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 26.31579!))
        Me.TableLayoutPanel3.ColumnStyles.Add(New System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 10.52632!))
        Me.TableLayoutPanel3.Controls.Add(Me.TableLayoutPanel4, 2, 0)
        Me.TableLayoutPanel3.Controls.Add(Me.TableLayoutPanel6, 3, 0)
        Me.TableLayoutPanel3.Controls.Add(Me.TableLayoutPanel7, 0, 0)
        Me.TableLayoutPanel3.Controls.Add(Me.TableLayoutPanel8, 1, 0)
        Me.TableLayoutPanel3.Dock = System.Windows.Forms.DockStyle.Fill
        Me.TableLayoutPanel3.Location = New System.Drawing.Point(2, 218)
        Me.TableLayoutPanel3.Margin = New System.Windows.Forms.Padding(2)
        Me.TableLayoutPanel3.Name = "TableLayoutPanel3"
        Me.TableLayoutPanel3.RowCount = 1
        Me.TableLayoutPanel3.RowStyles.Add(New System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 100.0!))
        Me.TableLayoutPanel3.Size = New System.Drawing.Size(588, 140)
        Me.TableLayoutPanel3.TabIndex = 60
        '
        'TableLayoutPanel4
        '
        Me.TableLayoutPanel4.ColumnCount = 1
        Me.TableLayoutPanel4.ColumnStyles.Add(New System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 100.0!))
        Me.TableLayoutPanel4.Controls.Add(Me.PictureBox1, 0, 0)
        Me.TableLayoutPanel4.Controls.Add(Me.TableLayoutPanel5, 0, 1)
        Me.TableLayoutPanel4.Dock = System.Windows.Forms.DockStyle.Fill
        Me.TableLayoutPanel4.Location = New System.Drawing.Point(372, 2)
        Me.TableLayoutPanel4.Margin = New System.Windows.Forms.Padding(2)
        Me.TableLayoutPanel4.Name = "TableLayoutPanel4"
        Me.TableLayoutPanel4.RowCount = 2
        Me.TableLayoutPanel4.RowStyles.Add(New System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 80.0!))
        Me.TableLayoutPanel4.RowStyles.Add(New System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 20.0!))
        Me.TableLayoutPanel4.Size = New System.Drawing.Size(150, 136)
        Me.TableLayoutPanel4.TabIndex = 43
        '
        'TableLayoutPanel5
        '
        Me.TableLayoutPanel5.ColumnCount = 3
        Me.TableLayoutPanel5.ColumnStyles.Add(New System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 20.0!))
        Me.TableLayoutPanel5.ColumnStyles.Add(New System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 40.0!))
        Me.TableLayoutPanel5.ColumnStyles.Add(New System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 40.0!))
        Me.TableLayoutPanel5.Controls.Add(Me.Label10, 0, 0)
        Me.TableLayoutPanel5.Controls.Add(Me.lblEmployeeName, 1, 0)
        Me.TableLayoutPanel5.Controls.Add(Me.lblEmployeeNumber, 2, 0)
        Me.TableLayoutPanel5.Dock = System.Windows.Forms.DockStyle.Fill
        Me.TableLayoutPanel5.Location = New System.Drawing.Point(2, 110)
        Me.TableLayoutPanel5.Margin = New System.Windows.Forms.Padding(2)
        Me.TableLayoutPanel5.Name = "TableLayoutPanel5"
        Me.TableLayoutPanel5.RowCount = 1
        Me.TableLayoutPanel5.RowStyles.Add(New System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 100.0!))
        Me.TableLayoutPanel5.Size = New System.Drawing.Size(146, 24)
        Me.TableLayoutPanel5.TabIndex = 56
        '
        'TableLayoutPanel6
        '
        Me.TableLayoutPanel6.ColumnCount = 1
        Me.TableLayoutPanel6.ColumnStyles.Add(New System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 33.33333!))
        Me.TableLayoutPanel6.Controls.Add(Me.lblState, 0, 0)
        Me.TableLayoutPanel6.Dock = System.Windows.Forms.DockStyle.Fill
        Me.TableLayoutPanel6.Location = New System.Drawing.Point(526, 2)
        Me.TableLayoutPanel6.Margin = New System.Windows.Forms.Padding(2)
        Me.TableLayoutPanel6.Name = "TableLayoutPanel6"
        Me.TableLayoutPanel6.RowCount = 1
        Me.TableLayoutPanel6.RowStyles.Add(New System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 100.0!))
        Me.TableLayoutPanel6.Size = New System.Drawing.Size(60, 136)
        Me.TableLayoutPanel6.TabIndex = 44
        '
        'TableLayoutPanel7
        '
        Me.TableLayoutPanel7.ColumnCount = 1
        Me.TableLayoutPanel7.ColumnStyles.Add(New System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 100.0!))
        Me.TableLayoutPanel7.Controls.Add(Me.lbl_TestName, 0, 0)
        Me.TableLayoutPanel7.Controls.Add(Me.lbl_Harness, 0, 1)
        Me.TableLayoutPanel7.Controls.Add(Me.lbl_Notes, 0, 2)
        Me.TableLayoutPanel7.Dock = System.Windows.Forms.DockStyle.Fill
        Me.TableLayoutPanel7.Location = New System.Drawing.Point(2, 2)
        Me.TableLayoutPanel7.Margin = New System.Windows.Forms.Padding(2)
        Me.TableLayoutPanel7.Name = "TableLayoutPanel7"
        Me.TableLayoutPanel7.RowCount = 3
        Me.TableLayoutPanel7.RowStyles.Add(New System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 25.0!))
        Me.TableLayoutPanel7.RowStyles.Add(New System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 25.0!))
        Me.TableLayoutPanel7.RowStyles.Add(New System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 50.0!))
        Me.TableLayoutPanel7.Size = New System.Drawing.Size(150, 136)
        Me.TableLayoutPanel7.TabIndex = 45
        '
        'TableLayoutPanel8
        '
        Me.TableLayoutPanel8.ColumnCount = 2
        Me.TableLayoutPanel8.ColumnStyles.Add(New System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 50.0!))
        Me.TableLayoutPanel8.ColumnStyles.Add(New System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 50.0!))
        Me.TableLayoutPanel8.Controls.Add(Me.LblDuration, 1, 4)
        Me.TableLayoutPanel8.Controls.Add(Me.Lbl_SerialNumber, 0, 0)
        Me.TableLayoutPanel8.Controls.Add(Me.txtSerialNumber, 1, 0)
        Me.TableLayoutPanel8.Controls.Add(Me.label20, 0, 1)
        Me.TableLayoutPanel8.Controls.Add(Me.LblStartTestTime, 1, 2)
        Me.TableLayoutPanel8.Controls.Add(Me.LblEndTestTime, 1, 3)
        Me.TableLayoutPanel8.Controls.Add(Me.Label5, 0, 5)
        Me.TableLayoutPanel8.Controls.Add(Me.Label4, 0, 4)
        Me.TableLayoutPanel8.Controls.Add(Me.Label8, 0, 3)
        Me.TableLayoutPanel8.Controls.Add(Me.Label2, 0, 2)
        Me.TableLayoutPanel8.Controls.Add(Me.lblElapseTime, 1, 5)
        Me.TableLayoutPanel8.Controls.Add(Me.lbl_PartNumber, 1, 1)
        Me.TableLayoutPanel8.Dock = System.Windows.Forms.DockStyle.Fill
        Me.TableLayoutPanel8.Location = New System.Drawing.Point(156, 2)
        Me.TableLayoutPanel8.Margin = New System.Windows.Forms.Padding(2)
        Me.TableLayoutPanel8.Name = "TableLayoutPanel8"
        Me.TableLayoutPanel8.RowCount = 6
        Me.TableLayoutPanel8.RowStyles.Add(New System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 16.66667!))
        Me.TableLayoutPanel8.RowStyles.Add(New System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 16.66667!))
        Me.TableLayoutPanel8.RowStyles.Add(New System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 16.66667!))
        Me.TableLayoutPanel8.RowStyles.Add(New System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 16.66667!))
        Me.TableLayoutPanel8.RowStyles.Add(New System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 16.66667!))
        Me.TableLayoutPanel8.RowStyles.Add(New System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 16.66667!))
        Me.TableLayoutPanel8.Size = New System.Drawing.Size(212, 136)
        Me.TableLayoutPanel8.TabIndex = 46
        '
        'LblDuration
        '
        Me.LblDuration.AutoSize = True
        Me.LblDuration.Dock = System.Windows.Forms.DockStyle.Fill
        Me.LblDuration.Location = New System.Drawing.Point(108, 88)
        Me.LblDuration.Margin = New System.Windows.Forms.Padding(2, 0, 2, 0)
        Me.LblDuration.Name = "LblDuration"
        Me.LblDuration.Size = New System.Drawing.Size(102, 22)
        Me.LblDuration.TabIndex = 67
        Me.LblDuration.Text = "LblDuration"
        Me.LblDuration.TextAlign = System.Drawing.ContentAlignment.MiddleCenter
        '
        'Lbl_SerialNumber
        '
        Me.Lbl_SerialNumber.BackColor = System.Drawing.Color.FromArgb(CType(CType(255, Byte), Integer), CType(CType(192, Byte), Integer), CType(CType(192, Byte), Integer))
        Me.Lbl_SerialNumber.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D
        Me.Lbl_SerialNumber.Dock = System.Windows.Forms.DockStyle.Fill
        Me.Lbl_SerialNumber.Font = New System.Drawing.Font("Microsoft Sans Serif", 8.25!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Lbl_SerialNumber.ForeColor = System.Drawing.Color.FromArgb(CType(CType(192, Byte), Integer), CType(CType(0, Byte), Integer), CType(CType(192, Byte), Integer))
        Me.Lbl_SerialNumber.Location = New System.Drawing.Point(4, 0)
        Me.Lbl_SerialNumber.Margin = New System.Windows.Forms.Padding(4, 0, 4, 0)
        Me.Lbl_SerialNumber.Name = "Lbl_SerialNumber"
        Me.Lbl_SerialNumber.Size = New System.Drawing.Size(98, 22)
        Me.Lbl_SerialNumber.TabIndex = 51
        Me.Lbl_SerialNumber.Text = "Serial Number"
        Me.Lbl_SerialNumber.TextAlign = System.Drawing.ContentAlignment.MiddleLeft
        '
        'txtSerialNumber
        '
        Me.txtSerialNumber.CharacterCasing = System.Windows.Forms.CharacterCasing.Upper
        Me.txtSerialNumber.Dock = System.Windows.Forms.DockStyle.Fill
        Me.txtSerialNumber.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.75!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.txtSerialNumber.Location = New System.Drawing.Point(109, 3)
        Me.txtSerialNumber.Name = "txtSerialNumber"
        Me.txtSerialNumber.Size = New System.Drawing.Size(100, 22)
        Me.txtSerialNumber.TabIndex = 65
        Me.txtSerialNumber.TextAlign = System.Windows.Forms.HorizontalAlignment.Center
        Me.txtSerialNumber.WordWrap = False
        '
        'LblStartTestTime
        '
        Me.LblStartTestTime.AutoSize = True
        Me.LblStartTestTime.Dock = System.Windows.Forms.DockStyle.Fill
        Me.LblStartTestTime.Location = New System.Drawing.Point(108, 44)
        Me.LblStartTestTime.Margin = New System.Windows.Forms.Padding(2, 0, 2, 0)
        Me.LblStartTestTime.Name = "LblStartTestTime"
        Me.LblStartTestTime.Size = New System.Drawing.Size(102, 22)
        Me.LblStartTestTime.TabIndex = 61
        Me.LblStartTestTime.Text = "LblStartTestTime"
        Me.LblStartTestTime.TextAlign = System.Drawing.ContentAlignment.MiddleCenter
        '
        'Label5
        '
        Me.Label5.BackColor = System.Drawing.Color.FromArgb(CType(CType(255, Byte), Integer), CType(CType(192, Byte), Integer), CType(CType(192, Byte), Integer))
        Me.Label5.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D
        Me.Label5.Dock = System.Windows.Forms.DockStyle.Fill
        Me.Label5.Font = New System.Drawing.Font("Microsoft Sans Serif", 8.25!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Label5.ForeColor = System.Drawing.Color.FromArgb(CType(CType(192, Byte), Integer), CType(CType(0, Byte), Integer), CType(CType(192, Byte), Integer))
        Me.Label5.Location = New System.Drawing.Point(4, 110)
        Me.Label5.Margin = New System.Windows.Forms.Padding(4, 0, 4, 0)
        Me.Label5.Name = "Label5"
        Me.Label5.Size = New System.Drawing.Size(98, 26)
        Me.Label5.TabIndex = 66
        Me.Label5.Text = "Delay"
        Me.Label5.TextAlign = System.Drawing.ContentAlignment.MiddleLeft
        '
        'Label4
        '
        Me.Label4.BackColor = System.Drawing.Color.FromArgb(CType(CType(255, Byte), Integer), CType(CType(192, Byte), Integer), CType(CType(192, Byte), Integer))
        Me.Label4.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D
        Me.Label4.Dock = System.Windows.Forms.DockStyle.Fill
        Me.Label4.Font = New System.Drawing.Font("Microsoft Sans Serif", 8.25!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Label4.ForeColor = System.Drawing.Color.FromArgb(CType(CType(192, Byte), Integer), CType(CType(0, Byte), Integer), CType(CType(192, Byte), Integer))
        Me.Label4.Location = New System.Drawing.Point(4, 88)
        Me.Label4.Margin = New System.Windows.Forms.Padding(4, 0, 4, 0)
        Me.Label4.Name = "Label4"
        Me.Label4.Size = New System.Drawing.Size(98, 22)
        Me.Label4.TabIndex = 65
        Me.Label4.Text = "Duration (Minutes)"
        Me.Label4.TextAlign = System.Drawing.ContentAlignment.MiddleLeft
        '
        'TableLayoutPanel9
        '
        Me.TableLayoutPanel9.Anchor = CType((((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Bottom) _
            Or System.Windows.Forms.AnchorStyles.Left) _
            Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.TableLayoutPanel9.ColumnCount = 2
        Me.TableLayoutPanel9.ColumnStyles.Add(New System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 50.0!))
        Me.TableLayoutPanel9.ColumnStyles.Add(New System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 50.0!))
        Me.TableLayoutPanel9.Controls.Add(Me.Button1, 0, 6)
        Me.TableLayoutPanel9.Controls.Add(Me.btn_ManualUpdate, 0, 0)
        Me.TableLayoutPanel9.Controls.Add(Me.btn_LoadXMLReport, 0, 2)
        Me.TableLayoutPanel9.Controls.Add(Me.btn_SendReportToTDM, 0, 1)
        Me.TableLayoutPanel9.Controls.Add(Me.btn_UpdateTestSpec, 0, 3)
        Me.TableLayoutPanel9.Location = New System.Drawing.Point(601, 3)
        Me.TableLayoutPanel9.Name = "TableLayoutPanel9"
        Me.TableLayoutPanel9.RowCount = 7
        Me.TableLayoutPanel9.RowStyles.Add(New System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 14.49276!))
        Me.TableLayoutPanel9.RowStyles.Add(New System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 14.49275!))
        Me.TableLayoutPanel9.RowStyles.Add(New System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 14.49275!))
        Me.TableLayoutPanel9.RowStyles.Add(New System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 14.49275!))
        Me.TableLayoutPanel9.RowStyles.Add(New System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 14.49275!))
        Me.TableLayoutPanel9.RowStyles.Add(New System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 14.49275!))
        Me.TableLayoutPanel9.RowStyles.Add(New System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 13.04348!))
        Me.TableLayoutPanel9.Size = New System.Drawing.Size(251, 360)
        Me.TableLayoutPanel9.TabIndex = 1
        '
        'Button1
        '
        Me.Button1.Dock = System.Windows.Forms.DockStyle.Fill
        Me.Button1.Location = New System.Drawing.Point(3, 315)
        Me.Button1.Name = "Button1"
        Me.Button1.Size = New System.Drawing.Size(119, 42)
        Me.Button1.TabIndex = 4
        Me.Button1.Text = "View Test Report"
        Me.Button1.UseVisualStyleBackColor = True
        '
        'btn_ManualUpdate
        '
        Me.btn_ManualUpdate.Anchor = CType((((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Bottom) _
            Or System.Windows.Forms.AnchorStyles.Left) _
            Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.btn_ManualUpdate.Location = New System.Drawing.Point(3, 3)
        Me.btn_ManualUpdate.Name = "btn_ManualUpdate"
        Me.btn_ManualUpdate.Size = New System.Drawing.Size(119, 46)
        Me.btn_ManualUpdate.TabIndex = 0
        Me.btn_ManualUpdate.Text = "Change Refresh Rate"
        Me.btn_ManualUpdate.UseVisualStyleBackColor = True
        '
        'btn_LoadXMLReport
        '
        Me.btn_LoadXMLReport.Dock = System.Windows.Forms.DockStyle.Fill
        Me.btn_LoadXMLReport.Location = New System.Drawing.Point(3, 107)
        Me.btn_LoadXMLReport.Name = "btn_LoadXMLReport"
        Me.btn_LoadXMLReport.Size = New System.Drawing.Size(119, 46)
        Me.btn_LoadXMLReport.TabIndex = 2
        Me.btn_LoadXMLReport.Text = "View Old Report"
        Me.btn_LoadXMLReport.UseVisualStyleBackColor = True
        '
        'btn_SendReportToTDM
        '
        Me.btn_SendReportToTDM.Dock = System.Windows.Forms.DockStyle.Fill
        Me.btn_SendReportToTDM.Location = New System.Drawing.Point(3, 55)
        Me.btn_SendReportToTDM.Name = "btn_SendReportToTDM"
        Me.btn_SendReportToTDM.Size = New System.Drawing.Size(119, 46)
        Me.btn_SendReportToTDM.TabIndex = 3
        Me.btn_SendReportToTDM.Text = "Send Pending Reports"
        Me.btn_SendReportToTDM.UseVisualStyleBackColor = True
        '
        'btn_UpdateTestSpec
        '
        Me.btn_UpdateTestSpec.Dock = System.Windows.Forms.DockStyle.Fill
        Me.btn_UpdateTestSpec.Location = New System.Drawing.Point(3, 159)
        Me.btn_UpdateTestSpec.Name = "btn_UpdateTestSpec"
        Me.btn_UpdateTestSpec.Size = New System.Drawing.Size(119, 46)
        Me.btn_UpdateTestSpec.TabIndex = 5
        Me.btn_UpdateTestSpec.Text = "Update Test Spec"
        Me.btn_UpdateTestSpec.UseVisualStyleBackColor = True
        '
        'MainTestInterface
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(6.0!, 13.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.AutoScroll = True
        Me.BackColor = System.Drawing.Color.FromArgb(CType(CType(255, Byte), Integer), CType(CType(128, Byte), Integer), CType(CType(128, Byte), Integer))
        Me.ClientSize = New System.Drawing.Size(861, 619)
        Me.Controls.Add(Me.Panel_Main)
        Me.Name = "MainTestInterface"
        Me.Text = "MainTestInterface"
        Me.WindowState = System.Windows.Forms.FormWindowState.Maximized
        CType(Me.PictureBox1, System.ComponentModel.ISupportInitialize).EndInit()
        CType(Me.dgvStepResults, System.ComponentModel.ISupportInitialize).EndInit()
        CType(Me.dgvAteOpData, System.ComponentModel.ISupportInitialize).EndInit()
        Me.Panel_Main.ResumeLayout(False)
        Me.TableLayoutPanel1.ResumeLayout(False)
        Me.TableLayoutPanel2.ResumeLayout(False)
        Me.TableLayoutPanel3.ResumeLayout(False)
        Me.TableLayoutPanel4.ResumeLayout(False)
        Me.TableLayoutPanel5.ResumeLayout(False)
        Me.TableLayoutPanel5.PerformLayout()
        Me.TableLayoutPanel6.ResumeLayout(False)
        Me.TableLayoutPanel6.PerformLayout()
        Me.TableLayoutPanel7.ResumeLayout(False)
        Me.TableLayoutPanel8.ResumeLayout(False)
        Me.TableLayoutPanel8.PerformLayout()
        Me.TableLayoutPanel9.ResumeLayout(False)
        Me.ResumeLayout(False)

    End Sub
    Friend WithEvents MSComm1 As System.IO.Ports.SerialPort
    Friend WithEvents lblElapseTime As System.Windows.Forms.Label
    Friend WithEvents lbl_TestName As System.Windows.Forms.Label
    Friend WithEvents lbl_Harness As System.Windows.Forms.Label
    Friend WithEvents Label2 As System.Windows.Forms.Label
    Friend WithEvents Label8 As System.Windows.Forms.Label
    Friend WithEvents label20 As System.Windows.Forms.Label
    Friend WithEvents Label10 As System.Windows.Forms.Label
    Friend WithEvents lblEmployeeNumber As System.Windows.Forms.Label
    Friend WithEvents lblEmployeeName As System.Windows.Forms.Label
    Friend WithEvents PictureBox1 As System.Windows.Forms.PictureBox
    Friend WithEvents lblState As System.Windows.Forms.Label
    Friend WithEvents dgvStepResults As System.Windows.Forms.DataGridView
    Friend WithEvents dgvAteOpData As System.Windows.Forms.DataGridView
    Friend WithEvents lbl_PartNumber As System.Windows.Forms.Label
    Friend WithEvents LblEndTestTime As System.Windows.Forms.Label
    Friend WithEvents Panel_Main As System.Windows.Forms.TableLayoutPanel
    Friend WithEvents TableLayoutPanel3 As System.Windows.Forms.TableLayoutPanel
    Friend WithEvents TableLayoutPanel4 As System.Windows.Forms.TableLayoutPanel
    Friend WithEvents TableLayoutPanel5 As System.Windows.Forms.TableLayoutPanel
    Friend WithEvents TableLayoutPanel6 As System.Windows.Forms.TableLayoutPanel
    Friend WithEvents TableLayoutPanel7 As System.Windows.Forms.TableLayoutPanel
    Friend WithEvents TableLayoutPanel8 As System.Windows.Forms.TableLayoutPanel
    Friend WithEvents Label5 As System.Windows.Forms.Label
    Friend WithEvents Label4 As System.Windows.Forms.Label
    Public WithEvents txtSerialNumber As System.Windows.Forms.TextBox
    Friend WithEvents TableLayoutPanel1 As System.Windows.Forms.TableLayoutPanel
    Friend WithEvents TableLayoutPanel2 As System.Windows.Forms.TableLayoutPanel
    Friend WithEvents LblStartTestTime As System.Windows.Forms.Label
    Friend WithEvents Lbl_SerialNumber As System.Windows.Forms.Label
    Friend WithEvents LblDuration As System.Windows.Forms.Label
    Friend WithEvents TableLayoutPanel9 As System.Windows.Forms.TableLayoutPanel
    Friend WithEvents btn_ManualUpdate As System.Windows.Forms.Button
    Friend WithEvents btn_LoadXMLReport As System.Windows.Forms.Button
    Friend WithEvents lbl_Notes As Label
    Friend WithEvents btn_SendReportToTDM As Button
    Friend WithEvents Button1 As Button
    Friend WithEvents btn_UpdateTestSpec As Button
End Class
