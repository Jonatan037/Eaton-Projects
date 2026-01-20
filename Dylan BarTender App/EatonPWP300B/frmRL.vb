Public Class frmRL
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
    Friend WithEvents Label2 As System.Windows.Forms.Label
    Friend WithEvents Label3 As System.Windows.Forms.Label
    Friend WithEvents Label4 As System.Windows.Forms.Label
    Friend WithEvents Label5 As System.Windows.Forms.Label
    Friend WithEvents Label6 As System.Windows.Forms.Label
    Friend WithEvents Label7 As System.Windows.Forms.Label
    Friend WithEvents Label8 As System.Windows.Forms.Label
    Friend WithEvents txtPLUS As System.Windows.Forms.TextBox
    Friend WithEvents txtMODNUM As System.Windows.Forms.TextBox
    Friend WithEvents txtINVOLT As System.Windows.Forms.TextBox
    Friend WithEvents txtINHZ As System.Windows.Forms.TextBox
    Friend WithEvents txtINPHASE As System.Windows.Forms.TextBox
    Friend WithEvents txtOUTVOLT As System.Windows.Forms.TextBox
    Friend WithEvents txtOUTHZ As System.Windows.Forms.TextBox
    Friend WithEvents txtOUTPHASE As System.Windows.Forms.TextBox
    Friend WithEvents txtBYPVOLT As System.Windows.Forms.TextBox
    Friend WithEvents txtBYPHZ As System.Windows.Forms.TextBox
    Friend WithEvents txtBYPAMP As System.Windows.Forms.TextBox
    Friend WithEvents txtVDCNUM As System.Windows.Forms.TextBox
    Friend WithEvents txtDCAMP As System.Windows.Forms.TextBox
    Friend WithEvents txtOUTAMP As System.Windows.Forms.TextBox
    Friend WithEvents txtOUTKW As System.Windows.Forms.TextBox
    Friend WithEvents txtBYPKVA As System.Windows.Forms.TextBox
    Friend WithEvents txtRLNumber As System.Windows.Forms.TextBox
    Friend WithEvents txtCTO As System.Windows.Forms.TextBox
    Friend WithEvents txtINAMP As System.Windows.Forms.TextBox
    Friend WithEvents txtOUTKVA As System.Windows.Forms.TextBox
    Friend WithEvents Label9 As System.Windows.Forms.Label
    Friend WithEvents Label10 As System.Windows.Forms.Label
    Friend WithEvents Label11 As System.Windows.Forms.Label
    Friend WithEvents Label12 As System.Windows.Forms.Label
    Friend WithEvents Label13 As System.Windows.Forms.Label
    Friend WithEvents Label14 As System.Windows.Forms.Label
    Friend WithEvents Label15 As System.Windows.Forms.Label
    Friend WithEvents Label16 As System.Windows.Forms.Label
    Friend WithEvents Label17 As System.Windows.Forms.Label
    Friend WithEvents Label18 As System.Windows.Forms.Label
    Friend WithEvents Label19 As System.Windows.Forms.Label
    Friend WithEvents Label20 As System.Windows.Forms.Label
    Friend WithEvents Label21 As System.Windows.Forms.Label
    Friend WithEvents Label22 As System.Windows.Forms.Label
    Friend WithEvents Label23 As System.Windows.Forms.Label
    Friend WithEvents Label24 As System.Windows.Forms.Label
    Friend WithEvents Label25 As System.Windows.Forms.Label
    Friend WithEvents Label26 As System.Windows.Forms.Label
    Friend WithEvents Label27 As System.Windows.Forms.Label
    Friend WithEvents Label31 As System.Windows.Forms.Label
    Friend WithEvents txtUPSTYPE As System.Windows.Forms.TextBox
    Friend WithEvents Label28 As System.Windows.Forms.Label
    Friend WithEvents txtPrintQty As System.Windows.Forms.TextBox
    Friend WithEvents cmdCancel As System.Windows.Forms.Button
    Friend WithEvents cmdPrint As System.Windows.Forms.Button
    Friend WithEvents txtSerialStr As System.Windows.Forms.TextBox
    Friend WithEvents txtSerial As System.Windows.Forms.TextBox
    Friend WithEvents Label29 As System.Windows.Forms.Label
    Friend WithEvents Label30 As System.Windows.Forms.Label
    Friend WithEvents Label32 As System.Windows.Forms.Label
    Friend WithEvents lstAgency As System.Windows.Forms.ListBox
    Friend WithEvents cmbAgency1 As System.Windows.Forms.ComboBox
    Friend WithEvents cmbAgency2 As System.Windows.Forms.ComboBox
    Friend WithEvents cmbAgency3 As System.Windows.Forms.ComboBox
    <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()
        Me.Label1 = New System.Windows.Forms.Label
        Me.Label2 = New System.Windows.Forms.Label
        Me.Label3 = New System.Windows.Forms.Label
        Me.Label4 = New System.Windows.Forms.Label
        Me.Label5 = New System.Windows.Forms.Label
        Me.Label6 = New System.Windows.Forms.Label
        Me.Label7 = New System.Windows.Forms.Label
        Me.Label8 = New System.Windows.Forms.Label
        Me.txtUPSTYPE = New System.Windows.Forms.TextBox
        Me.txtPLUS = New System.Windows.Forms.TextBox
        Me.txtMODNUM = New System.Windows.Forms.TextBox
        Me.txtINVOLT = New System.Windows.Forms.TextBox
        Me.txtINHZ = New System.Windows.Forms.TextBox
        Me.txtINPHASE = New System.Windows.Forms.TextBox
        Me.txtOUTVOLT = New System.Windows.Forms.TextBox
        Me.txtOUTHZ = New System.Windows.Forms.TextBox
        Me.txtOUTPHASE = New System.Windows.Forms.TextBox
        Me.txtBYPVOLT = New System.Windows.Forms.TextBox
        Me.txtBYPHZ = New System.Windows.Forms.TextBox
        Me.txtBYPAMP = New System.Windows.Forms.TextBox
        Me.txtVDCNUM = New System.Windows.Forms.TextBox
        Me.txtDCAMP = New System.Windows.Forms.TextBox
        Me.txtRLNumber = New System.Windows.Forms.TextBox
        Me.txtCTO = New System.Windows.Forms.TextBox
        Me.txtINAMP = New System.Windows.Forms.TextBox
        Me.txtOUTAMP = New System.Windows.Forms.TextBox
        Me.txtOUTKW = New System.Windows.Forms.TextBox
        Me.txtOUTKVA = New System.Windows.Forms.TextBox
        Me.txtBYPKVA = New System.Windows.Forms.TextBox
        Me.txtSerialStr = New System.Windows.Forms.TextBox
        Me.Label9 = New System.Windows.Forms.Label
        Me.Label10 = New System.Windows.Forms.Label
        Me.Label11 = New System.Windows.Forms.Label
        Me.Label12 = New System.Windows.Forms.Label
        Me.Label13 = New System.Windows.Forms.Label
        Me.Label14 = New System.Windows.Forms.Label
        Me.Label15 = New System.Windows.Forms.Label
        Me.Label16 = New System.Windows.Forms.Label
        Me.Label17 = New System.Windows.Forms.Label
        Me.Label18 = New System.Windows.Forms.Label
        Me.Label19 = New System.Windows.Forms.Label
        Me.Label20 = New System.Windows.Forms.Label
        Me.Label21 = New System.Windows.Forms.Label
        Me.Label22 = New System.Windows.Forms.Label
        Me.Label23 = New System.Windows.Forms.Label
        Me.Label24 = New System.Windows.Forms.Label
        Me.Label25 = New System.Windows.Forms.Label
        Me.Label26 = New System.Windows.Forms.Label
        Me.Label27 = New System.Windows.Forms.Label
        Me.Label31 = New System.Windows.Forms.Label
        Me.Label28 = New System.Windows.Forms.Label
        Me.txtPrintQty = New System.Windows.Forms.TextBox
        Me.cmdCancel = New System.Windows.Forms.Button
        Me.cmdPrint = New System.Windows.Forms.Button
        Me.txtSerial = New System.Windows.Forms.TextBox
        Me.Label29 = New System.Windows.Forms.Label
        Me.Label30 = New System.Windows.Forms.Label
        Me.Label32 = New System.Windows.Forms.Label
        Me.cmbAgency1 = New System.Windows.Forms.ComboBox
        Me.cmbAgency2 = New System.Windows.Forms.ComboBox
        Me.cmbAgency3 = New System.Windows.Forms.ComboBox
        Me.lstAgency = New System.Windows.Forms.ListBox
        Me.SuspendLayout()
        '
        'Label1
        '
        Me.Label1.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.75!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Label1.Location = New System.Drawing.Point(24, 24)
        Me.Label1.Name = "Label1"
        Me.Label1.Size = New System.Drawing.Size(56, 16)
        Me.Label1.TabIndex = 0
        Me.Label1.Text = "System:"
        '
        'Label2
        '
        Me.Label2.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.75!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Label2.Location = New System.Drawing.Point(24, 72)
        Me.Label2.Name = "Label2"
        Me.Label2.Size = New System.Drawing.Size(48, 16)
        Me.Label2.TabIndex = 1
        Me.Label2.Text = "Model:"
        '
        'Label3
        '
        Me.Label3.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.75!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Label3.Location = New System.Drawing.Point(24, 120)
        Me.Label3.Name = "Label3"
        Me.Label3.Size = New System.Drawing.Size(48, 16)
        Me.Label3.TabIndex = 2
        Me.Label3.Text = "AC In:"
        '
        'Label4
        '
        Me.Label4.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.75!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Label4.Location = New System.Drawing.Point(24, 168)
        Me.Label4.Name = "Label4"
        Me.Label4.Size = New System.Drawing.Size(56, 16)
        Me.Label4.TabIndex = 3
        Me.Label4.Text = "AC Out:"
        '
        'Label5
        '
        Me.Label5.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.75!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Label5.Location = New System.Drawing.Point(24, 216)
        Me.Label5.Name = "Label5"
        Me.Label5.Size = New System.Drawing.Size(56, 16)
        Me.Label5.TabIndex = 4
        Me.Label5.Text = "ByPass:"
        '
        'Label6
        '
        Me.Label6.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.75!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Label6.Location = New System.Drawing.Point(24, 264)
        Me.Label6.Name = "Label6"
        Me.Label6.Size = New System.Drawing.Size(32, 16)
        Me.Label6.TabIndex = 5
        Me.Label6.Text = "DC:"
        '
        'Label7
        '
        Me.Label7.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.75!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Label7.Location = New System.Drawing.Point(24, 312)
        Me.Label7.Name = "Label7"
        Me.Label7.Size = New System.Drawing.Size(80, 16)
        Me.Label7.TabIndex = 6
        Me.Label7.Text = "RL Number:"
        '
        'Label8
        '
        Me.Label8.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.75!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Label8.Location = New System.Drawing.Point(24, 360)
        Me.Label8.Name = "Label8"
        Me.Label8.Size = New System.Drawing.Size(88, 16)
        Me.Label8.TabIndex = 7
        Me.Label8.Text = "CTO Number:"
        '
        'txtUPSTYPE
        '
        Me.txtUPSTYPE.Location = New System.Drawing.Point(168, 24)
        Me.txtUPSTYPE.Name = "txtUPSTYPE"
        Me.txtUPSTYPE.Size = New System.Drawing.Size(48, 20)
        Me.txtUPSTYPE.TabIndex = 1
        Me.txtUPSTYPE.Text = ""
        '
        'txtPLUS
        '
        Me.txtPLUS.Location = New System.Drawing.Point(272, 24)
        Me.txtPLUS.Name = "txtPLUS"
        Me.txtPLUS.Size = New System.Drawing.Size(32, 20)
        Me.txtPLUS.TabIndex = 2
        Me.txtPLUS.Text = ""
        '
        'txtMODNUM
        '
        Me.txtMODNUM.Location = New System.Drawing.Point(168, 72)
        Me.txtMODNUM.Name = "txtMODNUM"
        Me.txtMODNUM.Size = New System.Drawing.Size(40, 20)
        Me.txtMODNUM.TabIndex = 3
        Me.txtMODNUM.Text = ""
        '
        'txtINVOLT
        '
        Me.txtINVOLT.Location = New System.Drawing.Point(152, 120)
        Me.txtINVOLT.Name = "txtINVOLT"
        Me.txtINVOLT.Size = New System.Drawing.Size(40, 20)
        Me.txtINVOLT.TabIndex = 4
        Me.txtINVOLT.Text = ""
        '
        'txtINHZ
        '
        Me.txtINHZ.Location = New System.Drawing.Point(256, 120)
        Me.txtINHZ.Name = "txtINHZ"
        Me.txtINHZ.Size = New System.Drawing.Size(48, 20)
        Me.txtINHZ.TabIndex = 5
        Me.txtINHZ.Text = ""
        '
        'txtINPHASE
        '
        Me.txtINPHASE.Location = New System.Drawing.Point(392, 120)
        Me.txtINPHASE.Name = "txtINPHASE"
        Me.txtINPHASE.Size = New System.Drawing.Size(32, 20)
        Me.txtINPHASE.TabIndex = 6
        Me.txtINPHASE.Text = ""
        '
        'txtOUTVOLT
        '
        Me.txtOUTVOLT.Location = New System.Drawing.Point(168, 168)
        Me.txtOUTVOLT.Name = "txtOUTVOLT"
        Me.txtOUTVOLT.Size = New System.Drawing.Size(40, 20)
        Me.txtOUTVOLT.TabIndex = 8
        Me.txtOUTVOLT.Text = ""
        '
        'txtOUTHZ
        '
        Me.txtOUTHZ.Location = New System.Drawing.Point(288, 168)
        Me.txtOUTHZ.Name = "txtOUTHZ"
        Me.txtOUTHZ.Size = New System.Drawing.Size(48, 20)
        Me.txtOUTHZ.TabIndex = 9
        Me.txtOUTHZ.Text = ""
        '
        'txtOUTPHASE
        '
        Me.txtOUTPHASE.Location = New System.Drawing.Point(440, 168)
        Me.txtOUTPHASE.Name = "txtOUTPHASE"
        Me.txtOUTPHASE.Size = New System.Drawing.Size(32, 20)
        Me.txtOUTPHASE.TabIndex = 10
        Me.txtOUTPHASE.Text = ""
        '
        'txtBYPVOLT
        '
        Me.txtBYPVOLT.Location = New System.Drawing.Point(176, 216)
        Me.txtBYPVOLT.Name = "txtBYPVOLT"
        Me.txtBYPVOLT.Size = New System.Drawing.Size(40, 20)
        Me.txtBYPVOLT.TabIndex = 14
        Me.txtBYPVOLT.Text = ""
        '
        'txtBYPHZ
        '
        Me.txtBYPHZ.Location = New System.Drawing.Point(296, 216)
        Me.txtBYPHZ.Name = "txtBYPHZ"
        Me.txtBYPHZ.Size = New System.Drawing.Size(48, 20)
        Me.txtBYPHZ.TabIndex = 15
        Me.txtBYPHZ.Text = ""
        '
        'txtBYPAMP
        '
        Me.txtBYPAMP.Location = New System.Drawing.Point(432, 216)
        Me.txtBYPAMP.Name = "txtBYPAMP"
        Me.txtBYPAMP.Size = New System.Drawing.Size(32, 20)
        Me.txtBYPAMP.TabIndex = 16
        Me.txtBYPAMP.Text = ""
        '
        'txtVDCNUM
        '
        Me.txtVDCNUM.Location = New System.Drawing.Point(168, 264)
        Me.txtVDCNUM.Name = "txtVDCNUM"
        Me.txtVDCNUM.Size = New System.Drawing.Size(40, 20)
        Me.txtVDCNUM.TabIndex = 18
        Me.txtVDCNUM.Text = ""
        '
        'txtDCAMP
        '
        Me.txtDCAMP.Location = New System.Drawing.Point(288, 264)
        Me.txtDCAMP.Name = "txtDCAMP"
        Me.txtDCAMP.Size = New System.Drawing.Size(56, 20)
        Me.txtDCAMP.TabIndex = 19
        Me.txtDCAMP.Text = ""
        '
        'txtRLNumber
        '
        Me.txtRLNumber.Location = New System.Drawing.Point(128, 312)
        Me.txtRLNumber.MaxLength = 15
        Me.txtRLNumber.Name = "txtRLNumber"
        Me.txtRLNumber.Size = New System.Drawing.Size(136, 20)
        Me.txtRLNumber.TabIndex = 20
        Me.txtRLNumber.Text = ""
        '
        'txtCTO
        '
        Me.txtCTO.Location = New System.Drawing.Point(128, 360)
        Me.txtCTO.MaxLength = 15
        Me.txtCTO.Name = "txtCTO"
        Me.txtCTO.Size = New System.Drawing.Size(136, 20)
        Me.txtCTO.TabIndex = 21
        Me.txtCTO.Text = ""
        '
        'txtINAMP
        '
        Me.txtINAMP.Location = New System.Drawing.Point(496, 120)
        Me.txtINAMP.Name = "txtINAMP"
        Me.txtINAMP.Size = New System.Drawing.Size(32, 20)
        Me.txtINAMP.TabIndex = 7
        Me.txtINAMP.Text = ""
        '
        'txtOUTAMP
        '
        Me.txtOUTAMP.Location = New System.Drawing.Point(560, 168)
        Me.txtOUTAMP.Name = "txtOUTAMP"
        Me.txtOUTAMP.Size = New System.Drawing.Size(32, 20)
        Me.txtOUTAMP.TabIndex = 11
        Me.txtOUTAMP.Text = ""
        '
        'txtOUTKW
        '
        Me.txtOUTKW.Location = New System.Drawing.Point(672, 168)
        Me.txtOUTKW.Name = "txtOUTKW"
        Me.txtOUTKW.Size = New System.Drawing.Size(40, 20)
        Me.txtOUTKW.TabIndex = 12
        Me.txtOUTKW.Text = ""
        '
        'txtOUTKVA
        '
        Me.txtOUTKVA.Location = New System.Drawing.Point(792, 168)
        Me.txtOUTKVA.Name = "txtOUTKVA"
        Me.txtOUTKVA.Size = New System.Drawing.Size(40, 20)
        Me.txtOUTKVA.TabIndex = 13
        Me.txtOUTKVA.Text = ""
        '
        'txtBYPKVA
        '
        Me.txtBYPKVA.Location = New System.Drawing.Point(552, 216)
        Me.txtBYPKVA.Name = "txtBYPKVA"
        Me.txtBYPKVA.Size = New System.Drawing.Size(104, 20)
        Me.txtBYPKVA.TabIndex = 17
        Me.txtBYPKVA.Text = ""
        '
        'txtSerialStr
        '
        Me.txtSerialStr.Location = New System.Drawing.Point(128, 416)
        Me.txtSerialStr.MaxLength = 8
        Me.txtSerialStr.Name = "txtSerialStr"
        Me.txtSerialStr.Size = New System.Drawing.Size(64, 20)
        Me.txtSerialStr.TabIndex = 22
        Me.txtSerialStr.Text = ""
        '
        'Label9
        '
        Me.Label9.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.75!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Label9.Location = New System.Drawing.Point(24, 416)
        Me.Label9.Name = "Label9"
        Me.Label9.Size = New System.Drawing.Size(96, 16)
        Me.Label9.TabIndex = 31
        Me.Label9.Text = "Serial Number:"
        '
        'Label10
        '
        Me.Label10.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.75!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Label10.Location = New System.Drawing.Point(88, 24)
        Me.Label10.Name = "Label10"
        Me.Label10.Size = New System.Drawing.Size(72, 16)
        Me.Label10.TabIndex = 33
        Me.Label10.Text = "UPSTYPE"
        '
        'Label11
        '
        Me.Label11.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.75!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Label11.Location = New System.Drawing.Point(224, 24)
        Me.Label11.Name = "Label11"
        Me.Label11.Size = New System.Drawing.Size(40, 16)
        Me.Label11.TabIndex = 34
        Me.Label11.Text = "PLUS"
        '
        'Label12
        '
        Me.Label12.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.75!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Label12.Location = New System.Drawing.Point(88, 72)
        Me.Label12.Name = "Label12"
        Me.Label12.Size = New System.Drawing.Size(72, 16)
        Me.Label12.TabIndex = 35
        Me.Label12.Text = "MODNUM"
        '
        'Label13
        '
        Me.Label13.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.75!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Label13.Location = New System.Drawing.Point(88, 120)
        Me.Label13.Name = "Label13"
        Me.Label13.Size = New System.Drawing.Size(56, 16)
        Me.Label13.TabIndex = 36
        Me.Label13.Text = "INVOLT"
        '
        'Label14
        '
        Me.Label14.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.75!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Label14.Location = New System.Drawing.Point(208, 120)
        Me.Label14.Name = "Label14"
        Me.Label14.Size = New System.Drawing.Size(40, 16)
        Me.Label14.TabIndex = 37
        Me.Label14.Text = "INHZ"
        '
        'Label15
        '
        Me.Label15.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.75!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Label15.Location = New System.Drawing.Point(320, 120)
        Me.Label15.Name = "Label15"
        Me.Label15.Size = New System.Drawing.Size(64, 16)
        Me.Label15.TabIndex = 38
        Me.Label15.Text = "INPHASE"
        '
        'Label16
        '
        Me.Label16.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.75!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Label16.Location = New System.Drawing.Point(440, 120)
        Me.Label16.Name = "Label16"
        Me.Label16.Size = New System.Drawing.Size(48, 16)
        Me.Label16.TabIndex = 39
        Me.Label16.Text = "INAMP"
        '
        'Label17
        '
        Me.Label17.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.75!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Label17.Location = New System.Drawing.Point(88, 168)
        Me.Label17.Name = "Label17"
        Me.Label17.Size = New System.Drawing.Size(72, 16)
        Me.Label17.TabIndex = 40
        Me.Label17.Text = "OUTVOLT"
        '
        'Label18
        '
        Me.Label18.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.75!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Label18.Location = New System.Drawing.Point(224, 168)
        Me.Label18.Name = "Label18"
        Me.Label18.Size = New System.Drawing.Size(56, 16)
        Me.Label18.TabIndex = 41
        Me.Label18.Text = "OUTHZ"
        '
        'Label19
        '
        Me.Label19.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.75!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Label19.Location = New System.Drawing.Point(352, 168)
        Me.Label19.Name = "Label19"
        Me.Label19.Size = New System.Drawing.Size(80, 16)
        Me.Label19.TabIndex = 42
        Me.Label19.Text = "OUTPHASE"
        '
        'Label20
        '
        Me.Label20.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.75!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Label20.Location = New System.Drawing.Point(488, 168)
        Me.Label20.Name = "Label20"
        Me.Label20.Size = New System.Drawing.Size(64, 16)
        Me.Label20.TabIndex = 43
        Me.Label20.Text = "OUTAMP"
        '
        'Label21
        '
        Me.Label21.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.75!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Label21.Location = New System.Drawing.Point(608, 168)
        Me.Label21.Name = "Label21"
        Me.Label21.Size = New System.Drawing.Size(56, 16)
        Me.Label21.TabIndex = 44
        Me.Label21.Text = "OUTKW"
        '
        'Label22
        '
        Me.Label22.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.75!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Label22.Location = New System.Drawing.Point(96, 216)
        Me.Label22.Name = "Label22"
        Me.Label22.Size = New System.Drawing.Size(72, 16)
        Me.Label22.TabIndex = 45
        Me.Label22.Text = "BYPVOLT"
        '
        'Label23
        '
        Me.Label23.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.75!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Label23.Location = New System.Drawing.Point(232, 216)
        Me.Label23.Name = "Label23"
        Me.Label23.Size = New System.Drawing.Size(56, 16)
        Me.Label23.TabIndex = 46
        Me.Label23.Text = "BYPHZ"
        '
        'Label24
        '
        Me.Label24.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.75!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Label24.Location = New System.Drawing.Point(360, 216)
        Me.Label24.Name = "Label24"
        Me.Label24.Size = New System.Drawing.Size(64, 16)
        Me.Label24.TabIndex = 47
        Me.Label24.Text = "BYPAMP"
        '
        'Label25
        '
        Me.Label25.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.75!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Label25.Location = New System.Drawing.Point(480, 216)
        Me.Label25.Name = "Label25"
        Me.Label25.Size = New System.Drawing.Size(64, 16)
        Me.Label25.TabIndex = 48
        Me.Label25.Text = "BYPKVA"
        '
        'Label26
        '
        Me.Label26.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.75!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Label26.Location = New System.Drawing.Point(96, 264)
        Me.Label26.Name = "Label26"
        Me.Label26.Size = New System.Drawing.Size(64, 16)
        Me.Label26.TabIndex = 49
        Me.Label26.Text = "VDCNUM"
        '
        'Label27
        '
        Me.Label27.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.75!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Label27.Location = New System.Drawing.Point(224, 264)
        Me.Label27.Name = "Label27"
        Me.Label27.Size = New System.Drawing.Size(56, 16)
        Me.Label27.TabIndex = 50
        Me.Label27.Text = "DCAMP"
        '
        'Label31
        '
        Me.Label31.Location = New System.Drawing.Point(728, 168)
        Me.Label31.Name = "Label31"
        Me.Label31.Size = New System.Drawing.Size(56, 16)
        Me.Label31.TabIndex = 54
        Me.Label31.Text = "OUTKVA"
        '
        'Label28
        '
        Me.Label28.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.75!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Label28.Location = New System.Drawing.Point(24, 464)
        Me.Label28.Name = "Label28"
        Me.Label28.Size = New System.Drawing.Size(136, 16)
        Me.Label28.TabIndex = 58
        Me.Label28.Text = "Enter Print Quantity"
        '
        'txtPrintQty
        '
        Me.txtPrintQty.Location = New System.Drawing.Point(184, 464)
        Me.txtPrintQty.Name = "txtPrintQty"
        Me.txtPrintQty.Size = New System.Drawing.Size(56, 20)
        Me.txtPrintQty.TabIndex = 24
        Me.txtPrintQty.Text = "1"
        '
        'cmdCancel
        '
        Me.cmdCancel.Location = New System.Drawing.Point(376, 464)
        Me.cmdCancel.Name = "cmdCancel"
        Me.cmdCancel.Size = New System.Drawing.Size(72, 24)
        Me.cmdCancel.TabIndex = 26
        Me.cmdCancel.Text = "Cancel"
        '
        'cmdPrint
        '
        Me.cmdPrint.Location = New System.Drawing.Point(264, 464)
        Me.cmdPrint.Name = "cmdPrint"
        Me.cmdPrint.Size = New System.Drawing.Size(72, 24)
        Me.cmdPrint.TabIndex = 25
        Me.cmdPrint.Text = "Print"
        '
        'txtSerial
        '
        Me.txtSerial.Location = New System.Drawing.Point(208, 416)
        Me.txtSerial.MaxLength = 2
        Me.txtSerial.Name = "txtSerial"
        Me.txtSerial.Size = New System.Drawing.Size(32, 20)
        Me.txtSerial.TabIndex = 23
        Me.txtSerial.Text = ""
        '
        'Label29
        '
        Me.Label29.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.75!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Label29.Location = New System.Drawing.Point(400, 384)
        Me.Label29.Name = "Label29"
        Me.Label29.Size = New System.Drawing.Size(64, 16)
        Me.Label29.TabIndex = 64
        Me.Label29.Text = "Agency 3"
        '
        'Label30
        '
        Me.Label30.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.75!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Label30.Location = New System.Drawing.Point(400, 336)
        Me.Label30.Name = "Label30"
        Me.Label30.Size = New System.Drawing.Size(64, 16)
        Me.Label30.TabIndex = 63
        Me.Label30.Text = "Agency 2"
        '
        'Label32
        '
        Me.Label32.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.75!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Label32.Location = New System.Drawing.Point(400, 288)
        Me.Label32.Name = "Label32"
        Me.Label32.Size = New System.Drawing.Size(64, 16)
        Me.Label32.TabIndex = 62
        Me.Label32.Text = "Agency 1"
        '
        'cmbAgency1
        '
        Me.cmbAgency1.Location = New System.Drawing.Point(480, 288)
        Me.cmbAgency1.Name = "cmbAgency1"
        Me.cmbAgency1.Size = New System.Drawing.Size(80, 21)
        Me.cmbAgency1.TabIndex = 65
        '
        'cmbAgency2
        '
        Me.cmbAgency2.Location = New System.Drawing.Point(480, 336)
        Me.cmbAgency2.Name = "cmbAgency2"
        Me.cmbAgency2.Size = New System.Drawing.Size(80, 21)
        Me.cmbAgency2.TabIndex = 66
        '
        'cmbAgency3
        '
        Me.cmbAgency3.Location = New System.Drawing.Point(480, 384)
        Me.cmbAgency3.Name = "cmbAgency3"
        Me.cmbAgency3.Size = New System.Drawing.Size(80, 21)
        Me.cmbAgency3.TabIndex = 67
        '
        'lstAgency
        '
        Me.lstAgency.Enabled = False
        Me.lstAgency.Location = New System.Drawing.Point(592, 288)
        Me.lstAgency.Name = "lstAgency"
        Me.lstAgency.Size = New System.Drawing.Size(240, 121)
        Me.lstAgency.TabIndex = 68
        '
        'frmRL
        '
        Me.AutoScaleBaseSize = New System.Drawing.Size(5, 13)
        Me.ClientSize = New System.Drawing.Size(856, 501)
        Me.Controls.Add(Me.lstAgency)
        Me.Controls.Add(Me.cmbAgency3)
        Me.Controls.Add(Me.cmbAgency2)
        Me.Controls.Add(Me.cmbAgency1)
        Me.Controls.Add(Me.Label29)
        Me.Controls.Add(Me.Label30)
        Me.Controls.Add(Me.Label32)
        Me.Controls.Add(Me.txtSerial)
        Me.Controls.Add(Me.Label28)
        Me.Controls.Add(Me.txtPrintQty)
        Me.Controls.Add(Me.cmdCancel)
        Me.Controls.Add(Me.cmdPrint)
        Me.Controls.Add(Me.Label31)
        Me.Controls.Add(Me.Label27)
        Me.Controls.Add(Me.Label26)
        Me.Controls.Add(Me.Label25)
        Me.Controls.Add(Me.Label24)
        Me.Controls.Add(Me.Label23)
        Me.Controls.Add(Me.Label22)
        Me.Controls.Add(Me.Label21)
        Me.Controls.Add(Me.Label20)
        Me.Controls.Add(Me.Label19)
        Me.Controls.Add(Me.Label18)
        Me.Controls.Add(Me.Label17)
        Me.Controls.Add(Me.Label16)
        Me.Controls.Add(Me.Label15)
        Me.Controls.Add(Me.Label14)
        Me.Controls.Add(Me.Label13)
        Me.Controls.Add(Me.Label12)
        Me.Controls.Add(Me.Label11)
        Me.Controls.Add(Me.Label10)
        Me.Controls.Add(Me.txtSerialStr)
        Me.Controls.Add(Me.Label9)
        Me.Controls.Add(Me.txtBYPKVA)
        Me.Controls.Add(Me.txtOUTKVA)
        Me.Controls.Add(Me.txtOUTKW)
        Me.Controls.Add(Me.txtOUTAMP)
        Me.Controls.Add(Me.txtINAMP)
        Me.Controls.Add(Me.txtCTO)
        Me.Controls.Add(Me.txtRLNumber)
        Me.Controls.Add(Me.txtDCAMP)
        Me.Controls.Add(Me.txtVDCNUM)
        Me.Controls.Add(Me.txtBYPAMP)
        Me.Controls.Add(Me.txtBYPHZ)
        Me.Controls.Add(Me.txtBYPVOLT)
        Me.Controls.Add(Me.txtOUTPHASE)
        Me.Controls.Add(Me.txtOUTHZ)
        Me.Controls.Add(Me.txtOUTVOLT)
        Me.Controls.Add(Me.txtINPHASE)
        Me.Controls.Add(Me.txtINHZ)
        Me.Controls.Add(Me.txtINVOLT)
        Me.Controls.Add(Me.txtMODNUM)
        Me.Controls.Add(Me.txtPLUS)
        Me.Controls.Add(Me.txtUPSTYPE)
        Me.Controls.Add(Me.Label8)
        Me.Controls.Add(Me.Label7)
        Me.Controls.Add(Me.Label6)
        Me.Controls.Add(Me.Label5)
        Me.Controls.Add(Me.Label4)
        Me.Controls.Add(Me.Label3)
        Me.Controls.Add(Me.Label2)
        Me.Controls.Add(Me.Label1)
        Me.Name = "frmRL"
        Me.Text = "frmRL"
        Me.ResumeLayout(False)

    End Sub

#End Region
    Private Sub frmRL_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load
        Dim SymSql As String

        SymSql = "SELECT [Symbol Designator], Description FROM [Agency Symbol Library];"

        rsdata6 = New ADODB.Recordset
        rsdata6.Open(SymSql, cnData, ADODB.CursorTypeEnum.adOpenDynamic, ADODB.LockTypeEnum.adLockOptimistic)
        cmbAgency1.Items.Add(" ")
        cmbAgency2.Items.Add(" ")
        cmbAgency3.Items.Add(" ")

        While rsdata6.EOF = False

            If IsDBNull(rsdata6.Fields("Symbol Designator").Value) = False Then
                cmbAgency1.Items.Add(rsdata6.Fields("Symbol Designator").Value)
                cmbAgency2.Items.Add(rsdata6.Fields("Symbol Designator").Value)
                cmbAgency3.Items.Add(rsdata6.Fields("Symbol Designator").Value)
                lstAgency.Items.Add(rsdata6.Fields("Symbol Designator").Value & vbTab & rsdata6.Fields("Description").Value)
            End If
            rsdata6.MoveNext()

        End While

        txtUPSTYPE.Text = UPSTYPE
        If rsdata.Fields.Item("P").Value = "P" Then
            txtINAMP.Text = INA
        Else
            If IsDBNull(rsdata.Fields("INAMP").Value) = False Then txtINAMP.Text = rsdata.Fields("INAMP").Value()
        End If

        If IsDBNull(rsdata.Fields("PLUS").Value) = False Then txtPLUS.Text = rsdata.Fields("PLUS").Value()
        If IsDBNull(rsdata.Fields("MODNUM").Value) = False Then txtMODNUM.Text = rsdata.Fields("MODNUM").Value()
        If IsDBNull(rsdata.Fields("INVOLT").Value) = False Then txtINVOLT.Text = rsdata.Fields("INVOLT").Value()
        If IsDBNull(rsdata.Fields("INHZ").Value) = False Then txtINHZ.Text = rsdata.Fields("INHZ").Value()
        If IsDBNull(rsdata.Fields("INPHASE").Value) = False Then txtINPHASE.Text = rsdata.Fields("INPHASE").Value()
        If IsDBNull(rsdata.Fields("OUTVOLT").Value) = False Then txtOUTVOLT.Text = rsdata.Fields("OUTVOLT").Value()
        If IsDBNull(rsdata.Fields("OUTHZ").Value) = False Then txtOUTHZ.Text = rsdata.Fields("OUTHZ").Value()
        If IsDBNull(rsdata.Fields("OUTPHASE").Value) = False Then txtOUTPHASE.Text = rsdata.Fields("OUTPHASE").Value()
        If IsDBNull(rsdata.Fields("OUTAMP").Value) = False Then txtOUTAMP.Text = rsdata.Fields("OUTAMP").Value()
        If IsDBNull(rsdata.Fields("OUTKW").Value) = False Then txtOUTKW.Text = rsdata.Fields("OUTKW").Value()
        If IsDBNull(rsdata.Fields("OUTKVA").Value) = False Then txtOUTKVA.Text = rsdata.Fields("OUTKVA").Value()
        If IsDBNull(rsdata.Fields("BYPVOLT").Value) = False Then txtBYPVOLT.Text = rsdata.Fields("BYPVOLT").Value()
        If IsDBNull(rsdata.Fields("BYPHZ").Value) = False Then txtBYPHZ.Text = rsdata.Fields("BYPHZ").Value()
        If IsDBNull(rsdata.Fields("BYPAMP").Value) = False Then txtBYPAMP.Text = rsdata.Fields("BYPAMP").Value()
        If IsDBNull(rsdata.Fields("BYPKVA").Value) = False Then txtBYPKVA.Text = rsdata.Fields("BYPKVA").Value()
        If IsDBNull(rsdata.Fields("VDCNUM").Value) = False Then txtVDCNUM.Text = rsdata.Fields("VDCNUM").Value()
        If IsDBNull(rsdata.Fields("DCAMP").Value) = False Then txtDCAMP.Text = rsdata.Fields("DCAMP").Value()
        If IsDBNull(rsdata.Fields("CONFIG").Value) = False Then txtCTO.Text = rsdata.Fields("CONFIG").Value()
        If IsDBNull(rsdata.Fields("AGENCY1").Value) = False Then cmbAgency1.SelectedText = (rsdata.Fields("AGENCY1").Value()) Else cmbAgency1.SelectedText = " "
        If IsDBNull(rsdata.Fields("AGENCY2").Value) = False Then cmbAgency2.SelectedText = (rsdata.Fields("AGENCY2").Value()) Else cmbAgency2.SelectedText = " "
        If IsDBNull(rsdata.Fields("AGENCY3").Value) = False Then cmbAgency3.SelectedText = (rsdata.Fields("AGENCY3").Value()) Else cmbAgency3.SelectedText = " "

        txtSerialStr.Text = SerialStr
        txtSerial.Text = Trim(Serial)
        txtPrintQty.Text = PQty

        If F1.rdoNewRLNum.Checked = True Then
            txtSerial.Enabled = False
        End If

    End Sub
    Private Sub Assign()

        SerialStr = ""
        UPSTYPE = txtUPSTYPE.Text
        INA = txtINAMP.Text
        rsdata.Fields("PLUS").Value = txtPLUS.Text
        rsdata.Fields("MODNUM").Value = txtMODNUM.Text
        rsdata.Fields("INVOLT").Value = txtINVOLT.Text
        rsdata.Fields("INHZ").Value = txtINHZ.Text
        rsdata.Fields("INPHASE").Value = txtINPHASE.Text
        rsdata.Fields("INAMP").Value = txtINAMP.Text
        rsdata.Fields("OUTVOLT").Value = txtOUTVOLT.Text
        rsdata.Fields("OUTHZ").Value = txtOUTHZ.Text
        rsdata.Fields("OUTPHASE").Value = txtOUTPHASE.Text
        rsdata.Fields("OUTAMP").Value = txtOUTAMP.Text
        rsdata.Fields("OUTKW").Value = txtOUTKW.Text
        rsdata.Fields("OUTKVA").Value = txtOUTKVA.Text
        rsdata.Fields("BYPVOLT").Value = txtBYPVOLT.Text
        rsdata.Fields("BYPHZ").Value = txtBYPHZ.Text
        rsdata.Fields("BYPAMP").Value = txtBYPAMP.Text
        rsdata.Fields("BYPKVA").Value = txtBYPKVA.Text
        rsdata.Fields("VDCNUM").Value = txtVDCNUM.Text
        rsdata.Fields("DCAMP").Value = txtDCAMP.Text
        rsdata.Fields("CONFIG").Value = txtRLNumber.Text
        rsdata.Fields("AGENCY1").Value = cmbAgency1.Text
        rsdata.Fields("AGENCY2").Value = cmbAgency2.Text
        rsdata.Fields("AGENCY3").Value = cmbAgency3.Text
        SerialStr = txtSerialStr.Text
        Serial = txtSerial.Text
        PQty = txtPrintQty.Text

    End Sub

    Private Sub cmdCancel_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdCancel.Click

        txtUPSTYPE.Text = ""
        txtPLUS.Text = ""
        txtMODNUM.Text = ""
        txtINVOLT.Text = ""
        txtINHZ.Text = ""
        txtINPHASE.Text = ""
        txtINAMP.Text = ""
        txtOUTVOLT.Text = ""
        txtOUTHZ.Text = ""
        txtOUTPHASE.Text = ""
        txtOUTAMP.Text = ""
        txtOUTKW.Text = ""
        txtOUTKVA.Text = ""
        txtBYPVOLT.Text = ""
        txtBYPHZ.Text = ""
        txtBYPAMP.Text = ""
        txtBYPKVA.Text = ""
        txtVDCNUM.Text = ""
        txtDCAMP.Text = ""
        txtCTO.Text = ""
        txtSerialStr.Text = ""
        txtSerial.Text = ""
        txtPrintQty.Text = ""
        cmbAgency1.Items.Clear()
        cmbAgency2.Items.Clear()
        cmbAgency3.Items.Clear()
        lstAgency.Items.Clear()

        F2.Close()

    End Sub

    Private Sub frmRL_Closed(ByVal sender As Object, ByVal e As System.EventArgs) Handles MyBase.Closed
        Call F1.ClearForm()
        F2.Close()
        F2 = Nothing
    End Sub

#If 1 Then

    Private Sub PrintRoutine()
        Dim j, i, LoopTrk As Integer
        Dim Loop1, Loop3, SysTrack, RLNumber As String

        Loop1 = 1
        LabFor1 = LabFor1 & "RL"
        LoopTrk = 1

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
                                btLab.NamedSubStrings.Item(j).Value = F1.txtSYSTR.Text
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
                            If btLab.NamedSubStrings.Item(j).Name = "FULLCTO" Then
                                btLab.NamedSubStrings.Item(j).Value = txtCTO.Text
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
                                    btLab.NamedSubStrings.Item(j).Value = F1.txtSYSTR.Text
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
                                If btLab.NamedSubStrings.Item(j).Name = "FULLCTO" Then
                                    btLab.NamedSubStrings.Item(j).Value = txtCTO.Text
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
                                    btLab.NamedSubStrings.Item(j).Value = F1.txtSYSTR.Text
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
                                If btLab.NamedSubStrings.Item(j).Name = "FULLCTO" Then
                                    btLab.NamedSubStrings.Item(j).Value = txtCTO.Text
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
                                    btLab.NamedSubStrings.Item(j).Value = F1.txtSYSTR.Text
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
                                If btLab.NamedSubStrings.Item(j).Name = "FULLCTO" Then
                                    btLab.NamedSubStrings.Item(j).Value = txtCTO.Text
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
                                    btLab.NamedSubStrings.Item(j).Value = F1.txtSYSTR.Text
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
                                If btLab.NamedSubStrings.Item(j).Name = "FULLCTO" Then
                                    btLab.NamedSubStrings.Item(j).Value = txtCTO.Text
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
            If F1.rdoOldSerialNum.Checked = False Then WriteBack2()

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

            If F1.rdoNewRLNum.Checked = True Then
                rsdata3.Fields.Item("Serial").Value = Trim(Str(Val(Serial)))
                rsdata3.Update()
                If Loop1 = Val(txtPrintQty.Text) Then
                    rsdata3.Close()
                End If
            End If

            Loop1 = Loop1 + 1
            Loop3 = Loop3 + 1

            Dim chkSysTrack As Integer
            chkSysTrack = 0
            If LoopTrk < Val(txtPrintQty.Text) Then
                If Len(F1.txtSYSTR.Text) > 0 Then '(If the SYSTR sting is empty or null then skip this routine for all labels. If the SYSTR has a value then run this routine)
                    While chkSysTrack = 0
                        SysTrack = InputBox("Please enter the System Tracking Number (without the -)", "System Tracking Number", F1.txtSYSTR.Text)
                        If Len(SysTrack) > 7 Or IsNumeric(SysTrack) = False Then
                            MsgBox("You can only enter 7 numeric only digits for the sytem number")
                            chkSysTrack = 0
                        Else
                            chkSysTrack = 1
                        End If
                    End While
                    F1.txtSYSTR.Text = SysTrack
                    SYSTR = SysTrack
                End If
            End If
            LoopTrk = LoopTrk + 1

        End While

        If F1.rdoNewRLNum.Checked = True Then
            txtSerial.Enabled = True
        End If

        rsdata2.Close()
        rsdata.CancelUpdate()
        rsdata.Close()
        cnData.Close()
        F2.Close()

    End Sub
#End If

#If 1 Then
    Private Sub PrintRoutine2()
        Dim j, i, LoopTrk As Integer
        Dim Loop2, Loop3, SysTrack, RLNumber As String

        LoopTrk = 1
        Loop2 = 1
        LabFor1 = LabFor1 & "RL"

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
                                btLab.NamedSubStrings.Item(j).Value = F1.txtSYSTR.Text
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
                            If btLab.NamedSubStrings.Item(j).Name = "FULLCTO" Then
                                btLab.NamedSubStrings.Item(j).Value = txtCTO.Text
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
                                btLab.NamedSubStrings.Item(j).Value = F1.txtSYSTR.Text
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
                            If btLab.NamedSubStrings.Item(j).Name = "FULLCTO" Then
                                btLab.NamedSubStrings.Item(j).Value = txtCTO.Text
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
                                btLab.NamedSubStrings.Item(j).Value = F1.txtSYSTR.Text
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
                            If btLab.NamedSubStrings.Item(j).Name = "FULLCTO" Then
                                btLab.NamedSubStrings.Item(j).Value = txtCTO.Text
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
                                btLab.NamedSubStrings.Item(j).Value = F1.txtSYSTR.Text
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
                            If btLab.NamedSubStrings.Item(j).Name = "FULLCTO" Then
                                btLab.NamedSubStrings.Item(j).Value = txtCTO.Text
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
                                btLab.NamedSubStrings.Item(j).Value = F1.txtSYSTR.Text
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
                            If btLab.NamedSubStrings.Item(j).Name = "FULLCTO" Then
                                btLab.NamedSubStrings.Item(j).Value = txtCTO.Text
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
            If F1.rdoOldSerialNum.Checked = False Then WriteBack2()

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

            If F1.rdoNewRLNum.Checked = True Then
                rsdata3.Fields.Item("Serial").Value = Trim(Str(Val(Serial)))
                rsdata3.Update()
                If Loop2 = Val(txtPrintQty.Text) Then
                    rsdata3.Close()
                End If

            End If

            Loop2 = Loop2 + 1
            Loop3 = Loop3 + 1

            Dim chkSysTrack As Integer
            chkSysTrack = 0
            If LoopTrk < Val(txtPrintQty.Text) Then
                If Len(F1.txtSYSTR.Text) > 0 Then '(If the SYSTR sting is empty or null then skip this routine for all labels. If the SYSTR has a value then run this routine)
                    While chkSysTrack = 0
                        SysTrack = InputBox("Please enter the System Tracking Number (without the -)", "System Tracking Number", F1.txtSYSTR.Text)
                        If Len(SysTrack) > 7 Or IsNumeric(SysTrack) = False Then
                            MsgBox("You can only enter 7 numeric only digits for the sytem number")
                            chkSysTrack = 0
                        Else
                            chkSysTrack = 1
                        End If
                    End While
                    F1.txtSYSTR.Text = SysTrack
                    SYSTR = SysTrack
                End If
            End If
            LoopTrk = LoopTrk + 1


        End While

        If F1.rdoNewRLNum.Checked = True Then
            txtSerial.Enabled = True
        End If

        rsdata2.Close()
        rsdata.CancelUpdate()
        rsdata.Close()
        cnData.Close()
        F2.Close()

    End Sub
#End If

#If 1 Then
    Private Sub PrintRoutine3()
        Dim j, i, LoopTrk As Integer
        Dim Loop3, Loopa, SysTrack, RLNumber As String

        LoopTrk = 1
        Loop3 = 1
        LabFor1 = LabFor1 & "RL"

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
                        btLab.NamedSubStrings.Item(j).Value = F1.txtSYSTR.Text
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
                    If btLab.NamedSubStrings.Item(j).Name = "FULLCTO" Then
                        btLab.NamedSubStrings.Item(j).Value = txtCTO.Text
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
            If F1.rdoOldSerialNum.Checked = False Then WriteBack2()

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

            If F1.rdoNewRLNum.Checked = True Then
                rsdata3.Fields.Item("Serial").Value = Trim(Str(Val(Serial)))
                rsdata3.Update()
                If Loop3 = Val(txtPrintQty.Text) Then
                    rsdata3.Close()
                End If
            End If

            Loop3 = Loop3 + 1
            Loopa = Loopa + 1

            Dim chkSysTrack As Integer
            chkSysTrack = 0
            If LoopTrk < Val(txtPrintQty.Text) Then
                If Len(F1.txtSYSTR.Text) > 0 Then '(If the SYSTR sting is empty or null then skip this routine for all labels. If the SYSTR has a value then run this routine)
                    While chkSysTrack = 0
                        SysTrack = InputBox("Please enter the System Tracking Number (without the -)", "System Tracking Number", F1.txtSYSTR.Text)
                        If Len(SysTrack) > 7 Or IsNumeric(SysTrack) = False Then
                            MsgBox("You can only enter 7 numeric only digits for the sytem number")
                            chkSysTrack = 0
                        Else
                            chkSysTrack = 1
                        End If
                    End While
                    F1.txtSYSTR.Text = SysTrack
                    SYSTR = SysTrack
                End If
            End If
            LoopTrk = LoopTrk + 1

        End While

        rsdata2.Close()
        rsdata.CancelUpdate()
        rsdata.Close()
        cnData.Close()
        F2.Close()

    End Sub
#End If

    Private Sub cmdPrint_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdPrint.Click

        Call Assign()
        SYSTR = F1.txtSYSTR.Text
        FULLCTO = txtCTO.Text

        If ProdType = "K" Or ProdType = "P" Then
            If RunType <> "K" Then
                Call PrintRoutine()
            Else
                Call PrintRoutine2()
            End If
        Else
            Call PrintRoutine3()
        End If

    End Sub

    Private Sub txtCTO_TextChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles txtCTO.TextChanged

        txtCTO.Text = UCase(txtCTO.Text)
        txtCTO.SelectionStart = (Len(txtCTO.Text))

    End Sub

    Private Sub txtRLNumber_TextChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles txtRLNumber.TextChanged

        txtRLNumber.Text = UCase(txtRLNumber.Text)
        txtRLNumber.SelectionStart = (Len(txtRLNumber.Text))

    End Sub

    Protected Overrides Sub Finalize()
        MyBase.Finalize()
    End Sub

End Class
