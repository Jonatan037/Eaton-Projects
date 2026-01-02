<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class LogIn
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
        Me.TableLayoutPanel1 = New System.Windows.Forms.TableLayoutPanel()
        Me.LblPartNumber = New System.Windows.Forms.Label()
        Me.TxtSerialNumber = New System.Windows.Forms.TextBox()
        Me.txtPN = New System.Windows.Forms.TextBox()
        Me.TxtUserName = New System.Windows.Forms.TextBox()
        Me.LblUserName = New System.Windows.Forms.Label()
        Me.LblUcf = New System.Windows.Forms.Label()
        Me.Label5 = New System.Windows.Forms.Label()
        Me.btn_Accept = New System.Windows.Forms.Button()
        Me.btn_Cancel = New System.Windows.Forms.Button()
        Me.Panel1 = New System.Windows.Forms.Panel()
        Me.XML_Load = New System.Windows.Forms.Button()
        Me.lbl_Issues = New System.Windows.Forms.Label()
        Me.BackUpReport = New System.Windows.Forms.Label()
        Me.lbl_LastSN = New System.Windows.Forms.Label()
        Me.TableLayoutPanel1.SuspendLayout()
        Me.Panel1.SuspendLayout()
        Me.SuspendLayout()
        '
        'TableLayoutPanel1
        '
        Me.TableLayoutPanel1.Anchor = System.Windows.Forms.AnchorStyles.None
        Me.TableLayoutPanel1.BackColor = System.Drawing.Color.LightGray
        Me.TableLayoutPanel1.CellBorderStyle = System.Windows.Forms.TableLayoutPanelCellBorderStyle.OutsetPartial
        Me.TableLayoutPanel1.ColumnCount = 2
        Me.TableLayoutPanel1.ColumnStyles.Add(New System.Windows.Forms.ColumnStyle())
        Me.TableLayoutPanel1.ColumnStyles.Add(New System.Windows.Forms.ColumnStyle())
        Me.TableLayoutPanel1.Controls.Add(Me.LblPartNumber, 0, 0)
        Me.TableLayoutPanel1.Controls.Add(Me.TxtSerialNumber, 1, 1)
        Me.TableLayoutPanel1.Controls.Add(Me.txtPN, 1, 0)
        Me.TableLayoutPanel1.Controls.Add(Me.TxtUserName, 1, 2)
        Me.TableLayoutPanel1.Controls.Add(Me.LblUserName, 0, 2)
        Me.TableLayoutPanel1.Controls.Add(Me.LblUcf, 0, 1)
        Me.TableLayoutPanel1.Location = New System.Drawing.Point(20, 82)
        Me.TableLayoutPanel1.Margin = New System.Windows.Forms.Padding(4, 4, 4, 4)
        Me.TableLayoutPanel1.Name = "TableLayoutPanel1"
        Me.TableLayoutPanel1.RowCount = 3
        Me.TableLayoutPanel1.RowStyles.Add(New System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 35.09615!))
        Me.TableLayoutPanel1.RowStyles.Add(New System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 34.61538!))
        Me.TableLayoutPanel1.RowStyles.Add(New System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 29.32692!))
        Me.TableLayoutPanel1.Size = New System.Drawing.Size(595, 144)
        Me.TableLayoutPanel1.TabIndex = 0
        '
        'LblPartNumber
        '
        Me.LblPartNumber.AutoSize = True
        Me.LblPartNumber.Font = New System.Drawing.Font("Microsoft Sans Serif", 15.75!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.LblPartNumber.ForeColor = System.Drawing.Color.Blue
        Me.LblPartNumber.Location = New System.Drawing.Point(7, 3)
        Me.LblPartNumber.Margin = New System.Windows.Forms.Padding(4, 0, 4, 0)
        Me.LblPartNumber.Name = "LblPartNumber"
        Me.LblPartNumber.Size = New System.Drawing.Size(237, 31)
        Me.LblPartNumber.TabIndex = 0
        Me.LblPartNumber.Text = "Unit Part Number："
        '
        'TxtSerialNumber
        '
        Me.TxtSerialNumber.Anchor = CType((((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Bottom) _
            Or System.Windows.Forms.AnchorStyles.Left) _
            Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.TxtSerialNumber.ForeColor = System.Drawing.Color.Blue
        Me.TxtSerialNumber.Location = New System.Drawing.Point(260, 56)
        Me.TxtSerialNumber.Margin = New System.Windows.Forms.Padding(4, 4, 4, 4)
        Me.TxtSerialNumber.Name = "TxtSerialNumber"
        Me.TxtSerialNumber.Size = New System.Drawing.Size(328, 20)
        Me.TxtSerialNumber.TabIndex = 1
        '
        'txtPN
        '
        Me.txtPN.Anchor = CType((((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Bottom) _
            Or System.Windows.Forms.AnchorStyles.Left) _
            Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.txtPN.ForeColor = System.Drawing.Color.Blue
        Me.txtPN.Location = New System.Drawing.Point(260, 7)
        Me.txtPN.Margin = New System.Windows.Forms.Padding(4, 4, 4, 4)
        Me.txtPN.Name = "txtPN"
        Me.txtPN.Size = New System.Drawing.Size(328, 20)
        Me.txtPN.TabIndex = 1
        '
        'TxtUserName
        '
        Me.TxtUserName.Anchor = CType((((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Bottom) _
            Or System.Windows.Forms.AnchorStyles.Left) _
            Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.TxtUserName.ForeColor = System.Drawing.Color.Blue
        Me.TxtUserName.Location = New System.Drawing.Point(260, 105)
        Me.TxtUserName.Margin = New System.Windows.Forms.Padding(4, 4, 4, 4)
        Me.TxtUserName.Name = "TxtUserName"
        Me.TxtUserName.Size = New System.Drawing.Size(328, 20)
        Me.TxtUserName.TabIndex = 1
        '
        'LblUserName
        '
        Me.LblUserName.AutoSize = True
        Me.LblUserName.Font = New System.Drawing.Font("Microsoft Sans Serif", 15.75!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.LblUserName.ForeColor = System.Drawing.Color.Blue
        Me.LblUserName.Location = New System.Drawing.Point(7, 101)
        Me.LblUserName.Margin = New System.Windows.Forms.Padding(4, 0, 4, 0)
        Me.LblUserName.Name = "LblUserName"
        Me.LblUserName.Size = New System.Drawing.Size(203, 31)
        Me.LblUserName.TabIndex = 0
        Me.LblUserName.Text = "Badge Number:"
        '
        'LblUcf
        '
        Me.LblUcf.AutoSize = True
        Me.LblUcf.Font = New System.Drawing.Font("Microsoft Sans Serif", 15.75!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.LblUcf.ForeColor = System.Drawing.Color.Blue
        Me.LblUcf.Location = New System.Drawing.Point(7, 52)
        Me.LblUcf.Margin = New System.Windows.Forms.Padding(4, 0, 4, 0)
        Me.LblUcf.Name = "LblUcf"
        Me.LblUcf.Size = New System.Drawing.Size(242, 31)
        Me.LblUcf.TabIndex = 0
        Me.LblUcf.Text = "Unit Serial Number"
        '
        'Label5
        '
        Me.Label5.AutoSize = True
        Me.Label5.Font = New System.Drawing.Font("Microsoft Sans Serif", 24.0!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Label5.ForeColor = System.Drawing.Color.Blue
        Me.Label5.Location = New System.Drawing.Point(191, 15)
        Me.Label5.Margin = New System.Windows.Forms.Padding(4, 0, 4, 0)
        Me.Label5.Name = "Label5"
        Me.Label5.Size = New System.Drawing.Size(246, 46)
        Me.Label5.TabIndex = 0
        Me.Label5.Text = "Battery Test"
        '
        'btn_Accept
        '
        Me.btn_Accept.Location = New System.Drawing.Point(296, 234)
        Me.btn_Accept.Margin = New System.Windows.Forms.Padding(4, 4, 4, 4)
        Me.btn_Accept.Name = "btn_Accept"
        Me.btn_Accept.Size = New System.Drawing.Size(67, 31)
        Me.btn_Accept.TabIndex = 1
        Me.btn_Accept.Text = "Accept"
        Me.btn_Accept.UseVisualStyleBackColor = True
        '
        'btn_Cancel
        '
        Me.btn_Cancel.Location = New System.Drawing.Point(548, 234)
        Me.btn_Cancel.Margin = New System.Windows.Forms.Padding(4, 4, 4, 4)
        Me.btn_Cancel.Name = "btn_Cancel"
        Me.btn_Cancel.Size = New System.Drawing.Size(67, 31)
        Me.btn_Cancel.TabIndex = 2
        Me.btn_Cancel.Text = "Cancel"
        Me.btn_Cancel.UseVisualStyleBackColor = True
        '
        'Panel1
        '
        Me.Panel1.BackColor = System.Drawing.Color.LightGray
        Me.Panel1.Controls.Add(Me.XML_Load)
        Me.Panel1.Controls.Add(Me.lbl_Issues)
        Me.Panel1.Controls.Add(Me.BackUpReport)
        Me.Panel1.Controls.Add(Me.btn_Cancel)
        Me.Panel1.Controls.Add(Me.btn_Accept)
        Me.Panel1.Controls.Add(Me.TableLayoutPanel1)
        Me.Panel1.Controls.Add(Me.Label5)
        Me.Panel1.Location = New System.Drawing.Point(45, 26)
        Me.Panel1.Margin = New System.Windows.Forms.Padding(4, 4, 4, 4)
        Me.Panel1.Name = "Panel1"
        Me.Panel1.Size = New System.Drawing.Size(647, 327)
        Me.Panel1.TabIndex = 2
        '
        'XML_Load
        '
        Me.XML_Load.Location = New System.Drawing.Point(591, 295)
        Me.XML_Load.Margin = New System.Windows.Forms.Padding(4, 4, 4, 4)
        Me.XML_Load.Name = "XML_Load"
        Me.XML_Load.Size = New System.Drawing.Size(52, 28)
        Me.XML_Load.TabIndex = 4
        Me.XML_Load.Text = "XML"
        Me.XML_Load.UseVisualStyleBackColor = True
        '
        'lbl_Issues
        '
        Me.lbl_Issues.AutoSize = True
        Me.lbl_Issues.Location = New System.Drawing.Point(31, 268)
        Me.lbl_Issues.Margin = New System.Windows.Forms.Padding(4, 0, 4, 0)
        Me.lbl_Issues.Name = "lbl_Issues"
        Me.lbl_Issues.Size = New System.Drawing.Size(42, 15)
        Me.lbl_Issues.TabIndex = 3
        Me.lbl_Issues.Text = "Issue: "
        '
        'BackUpReport
        '
        Me.BackUpReport.AutoSize = True
        Me.BackUpReport.Font = New System.Drawing.Font("Microsoft Sans Serif", 15.75!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.BackUpReport.ForeColor = System.Drawing.Color.Blue
        Me.BackUpReport.Location = New System.Drawing.Point(35, 299)
        Me.BackUpReport.Margin = New System.Windows.Forms.Padding(4, 0, 4, 0)
        Me.BackUpReport.Name = "BackUpReport"
        Me.BackUpReport.Size = New System.Drawing.Size(0, 31)
        Me.BackUpReport.TabIndex = 3
        '
        'lbl_LastSN
        '
        Me.lbl_LastSN.AutoSize = True
        Me.lbl_LastSN.Font = New System.Drawing.Font("Microsoft Sans Serif", 24.0!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.lbl_LastSN.Location = New System.Drawing.Point(56, 368)
        Me.lbl_LastSN.Margin = New System.Windows.Forms.Padding(4, 0, 4, 0)
        Me.lbl_LastSN.Name = "lbl_LastSN"
        Me.lbl_LastSN.Size = New System.Drawing.Size(488, 46)
        Me.lbl_LastSN.TabIndex = 3
        Me.lbl_LastSN.Text = "Last SN Tested:  First Run"
        '
        'LogIn
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(8.0!, 16.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.BackColor = System.Drawing.Color.Gainsboro
        Me.ClientSize = New System.Drawing.Size(741, 426)
        Me.Controls.Add(Me.lbl_LastSN)
        Me.Controls.Add(Me.Panel1)
        Me.FormBorderStyle = System.Windows.Forms.FormBorderStyle.Fixed3D
        Me.Margin = New System.Windows.Forms.Padding(4, 4, 4, 4)
        Me.Name = "LogIn"
        Me.Text = "Login"
        Me.TableLayoutPanel1.ResumeLayout(False)
        Me.TableLayoutPanel1.PerformLayout()
        Me.Panel1.ResumeLayout(False)
        Me.Panel1.PerformLayout()
        Me.ResumeLayout(False)
        Me.PerformLayout()

    End Sub
    Friend WithEvents TableLayoutPanel1 As System.Windows.Forms.TableLayoutPanel
    Friend WithEvents LblUserName As System.Windows.Forms.Label
    Friend WithEvents LblPartNumber As System.Windows.Forms.Label
    Friend WithEvents LblUcf As System.Windows.Forms.Label
    Friend WithEvents TxtUserName As System.Windows.Forms.TextBox
    Friend WithEvents txtPN As System.Windows.Forms.TextBox
    Friend WithEvents TxtSerialNumber As System.Windows.Forms.TextBox
    Friend WithEvents Label5 As System.Windows.Forms.Label
    Friend WithEvents btn_Accept As System.Windows.Forms.Button
    Friend WithEvents btn_Cancel As System.Windows.Forms.Button
    Friend WithEvents Panel1 As System.Windows.Forms.Panel
    Friend WithEvents BackUpReport As System.Windows.Forms.Label
    Friend WithEvents lbl_Issues As Label
    Friend WithEvents XML_Load As Button
    Friend WithEvents lbl_LastSN As Label
End Class
