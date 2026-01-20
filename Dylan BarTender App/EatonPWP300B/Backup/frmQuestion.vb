Public Class frmQuestion
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
    Friend WithEvents lblQuestion As System.Windows.Forms.Label
    Friend WithEvents cmdA As System.Windows.Forms.Button
    Friend WithEvents cmdB As System.Windows.Forms.Button
    Friend WithEvents cmdC As System.Windows.Forms.Button
    <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()
        Me.lblQuestion = New System.Windows.Forms.Label
        Me.cmdA = New System.Windows.Forms.Button
        Me.cmdB = New System.Windows.Forms.Button
        Me.cmdC = New System.Windows.Forms.Button
        Me.SuspendLayout()
        '
        'lblQuestion
        '
        Me.lblQuestion.Font = New System.Drawing.Font("Arial", 9.0!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.lblQuestion.Location = New System.Drawing.Point(24, 24)
        Me.lblQuestion.Name = "lblQuestion"
        Me.lblQuestion.Size = New System.Drawing.Size(368, 96)
        Me.lblQuestion.TabIndex = 0
        Me.lblQuestion.TextAlign = System.Drawing.ContentAlignment.MiddleCenter
        '
        'cmdA
        '
        Me.cmdA.Location = New System.Drawing.Point(80, 136)
        Me.cmdA.Name = "cmdA"
        Me.cmdA.Size = New System.Drawing.Size(64, 32)
        Me.cmdA.TabIndex = 1
        Me.cmdA.Text = "A"
        '
        'cmdB
        '
        Me.cmdB.Location = New System.Drawing.Point(180, 136)
        Me.cmdB.Name = "cmdB"
        Me.cmdB.Size = New System.Drawing.Size(64, 32)
        Me.cmdB.TabIndex = 2
        Me.cmdB.Text = "B"
        '
        'cmdC
        '
        Me.cmdC.Location = New System.Drawing.Point(280, 136)
        Me.cmdC.Name = "cmdC"
        Me.cmdC.Size = New System.Drawing.Size(64, 32)
        Me.cmdC.TabIndex = 3
        Me.cmdC.Text = "C"
        '
        'frmQuestion
        '
        Me.AutoScaleBaseSize = New System.Drawing.Size(5, 13)
        Me.ClientSize = New System.Drawing.Size(424, 197)
        Me.Controls.Add(Me.cmdC)
        Me.Controls.Add(Me.cmdB)
        Me.Controls.Add(Me.cmdA)
        Me.Controls.Add(Me.lblQuestion)
        Me.Name = "frmQuestion"
        Me.Text = "frmQuestion"
        Me.ResumeLayout(False)

    End Sub

#End Region

    Private Sub frmQuestion_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load

        If IsDBNull(rsdata5.Fields.Item("Question").Value) Then
            MsgBox("There is a data error for this record, related to the question field being blank")
            f4.Close()
            Exit Sub
        End If

        If Mid(rsdata5.Fields.Item("Question").Value, 1, 1) <> "3" Then
            cmdC.Visible = False
            lblQuestion.Text = rsdata5.Fields.Item("Question").Value
        Else
            cmdC.Visible = True
            lblQuestion.Text = Mid(rsdata5.Fields.Item("Question").Value, 3)
        End If


    End Sub

    Private Sub cmdA_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdA.Click

        If Not IsDBNull(rsdata5.Fields.Item("RevCode").Value) Then
            RevCode = rsdata5.Fields.Item("RevCode").Value
        End If
        f4.Close()

    End Sub

    Private Sub cmdB_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdB.Click

        If Not IsDBNull(rsdata5.Fields.Item("RevCode1").Value) Then
            RevCode = rsdata5.Fields.Item("RevCode1").Value
        End If
        f4.Close()

    End Sub

    Private Sub cmdC_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdC.Click

        If Not IsDBNull(rsdata5.Fields.Item("RevCode2").Value) Then
            RevCode = rsdata5.Fields.Item("RevCode2").Value
        End If
        f4.Close()

    End Sub

End Class
