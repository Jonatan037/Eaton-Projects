Public Class frmStatic
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
    Friend WithEvents CmdPrint As System.Windows.Forms.Button
    Friend WithEvents txtQty As System.Windows.Forms.TextBox
    Friend WithEvents lstPrinter As System.Windows.Forms.ListBox
    <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()
        Me.Label1 = New System.Windows.Forms.Label
        Me.txtQty = New System.Windows.Forms.TextBox
        Me.CmdPrint = New System.Windows.Forms.Button
        Me.lstPrinter = New System.Windows.Forms.ListBox
        Me.SuspendLayout()
        '
        'Label1
        '
        Me.Label1.Location = New System.Drawing.Point(16, 32)
        Me.Label1.Name = "Label1"
        Me.Label1.Size = New System.Drawing.Size(144, 16)
        Me.Label1.TabIndex = 0
        Me.Label1.Text = "Enter Label Print Quantity"
        '
        'txtQty
        '
        Me.txtQty.Location = New System.Drawing.Point(160, 32)
        Me.txtQty.Name = "txtQty"
        Me.txtQty.Size = New System.Drawing.Size(56, 20)
        Me.txtQty.TabIndex = 1
        Me.txtQty.Text = ""
        '
        'CmdPrint
        '
        Me.CmdPrint.Location = New System.Drawing.Point(232, 32)
        Me.CmdPrint.Name = "CmdPrint"
        Me.CmdPrint.Size = New System.Drawing.Size(72, 24)
        Me.CmdPrint.TabIndex = 2
        Me.CmdPrint.Text = "Print"
        '
        'lstPrinter
        '
        Me.lstPrinter.Location = New System.Drawing.Point(16, 104)
        Me.lstPrinter.Name = "lstPrinter"
        Me.lstPrinter.Size = New System.Drawing.Size(160, 56)
        Me.lstPrinter.TabIndex = 11
        '
        'frmStatic
        '
        Me.AutoScaleBaseSize = New System.Drawing.Size(5, 13)
        Me.ClientSize = New System.Drawing.Size(408, 189)
        Me.Controls.Add(Me.lstPrinter)
        Me.Controls.Add(Me.CmdPrint)
        Me.Controls.Add(Me.txtQty)
        Me.Controls.Add(Me.Label1)
        Me.Name = "frmStatic"
        Me.Text = "frmStatic"
        Me.ResumeLayout(False)

    End Sub

#End Region

    Private Sub CmdPrint_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles CmdPrint.Click

        Dim holder As String
        Dim Pos, Pos2, FormChk As Integer

        If Val(txtQty.Text) = 0 Then
            MsgBox("You have not entered a valid quantity")
            Exit Sub
        End If
        If lstPrinter.SelectedItem = "" Then
            MsgBox("You have not selected your printer")
            Exit Sub
        End If

        rsdata2 = New ADODB.Recordset
        rsdata2.Open("SELECT Labels FROM tblLabelLookUp WHERE LabelString='" & rsdata.Fields.Item("LABELSTRING").Value & "';", cnData)
        holder = rsdata2.Fields.Item("Labels").Value
        PQty = txtQty.Text

        For FormChk = 1 To Len(holder)

            If Mid(holder, FormChk, 1) = "," Then
                Pos2 = Pos2 + 1
            End If

        Next

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
                LabFor2 = holder
            End If
        End If

        If InStr(holder, ",", CompareMethod.Binary) <> 0 Then
            LabFor4 = holder
        Else
            If Pos2 = 3 Then
                LabFor4 = holder
            End If
        End If

        Call StatPrintRoutine()

    End Sub
    Private Sub StatPrintRoutine()

        If LabFor1 <> "" Then
            btLab = btApp.Formats.Open(LabDir & LabFor1)
            btLab.Printer = (lstPrinter.SelectedItem)
            btLab.IdenticalCopiesOfLabel = Val(txtQty.Text)
            btLab.PrintOut()
            btLab.Close(BarTender.BtSaveOptions.btDoNotSaveChanges)
        End If
        If LabFor2 <> "" Then
            btLab = btApp.Formats.Open(LabDir & LabFor2)
            btLab.Printer = (lstPrinter.SelectedItem)
            btLab.IdenticalCopiesOfLabel = Val(txtQty.Text)
            btLab.PrintOut()
            btLab.Close(BarTender.BtSaveOptions.btDoNotSaveChanges)
        End If
        If LabFor3 <> "" Then
            btLab = btApp.Formats.Open(LabDir & LabFor3)
            btLab.Printer = (lstPrinter.SelectedItem)
            btLab.IdenticalCopiesOfLabel = Val(txtQty.Text)
            btLab.PrintOut()
            btLab.Close(BarTender.BtSaveOptions.btDoNotSaveChanges)
        End If
        If LabFor4 <> "" Then
            btLab = btApp.Formats.Open(LabDir & LabFor4)
            btLab.Printer = (lstPrinter.SelectedItem)
            btLab.IdenticalCopiesOfLabel = Val(txtQty.Text)
            btLab.PrintOut()
            btLab.Close(BarTender.BtSaveOptions.btDoNotSaveChanges)
        End If

        F3.Close()

    End Sub
    Private Sub frmStatic_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load

        lstPrinter.Items.Add(PrinterOne)
        lstPrinter.Items.Add(PrinterTwo)
        lstPrinter.Items.Add(PrinterThree)

    End Sub
End Class
