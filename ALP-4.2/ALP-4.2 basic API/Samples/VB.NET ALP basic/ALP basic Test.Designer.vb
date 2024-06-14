<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class ALP_basic_Test
    Inherits System.Windows.Forms.Form

    'Form overrides dispose to clean up the component list.
    <System.Diagnostics.DebuggerNonUserCode()> _
    Protected Overrides Sub Dispose(ByVal disposing As Boolean)
        If disposing AndAlso components IsNot Nothing Then
            components.Dispose()
        End If
        MyBase.Dispose(disposing)
    End Sub

    'Required by the Windows Form Designer
    Private components As System.ComponentModel.IContainer

    'NOTE: The following procedure is required by the Windows Form Designer
    'It can be modified using the Windows Form Designer.  
    'Do not modify it using the code editor.
    <System.Diagnostics.DebuggerStepThrough()> _
    Private Sub InitializeComponent()
        Me.Alloc = New System.Windows.Forms.Button
        Me.Pattern1 = New System.Windows.Forms.Button
        Me.Pattern2 = New System.Windows.Forms.Button
        Me.Free = New System.Windows.Forms.Button
        Me.Clear = New System.Windows.Forms.Button
        Me.Label1 = New System.Windows.Forms.Label
        Me.Label2 = New System.Windows.Forms.Label
        Me.Label3 = New System.Windows.Forms.Label
        Me.SuspendLayout()
        '
        'Alloc
        '
        Me.Alloc.Location = New System.Drawing.Point(12, 12)
        Me.Alloc.Name = "Alloc"
        Me.Alloc.Size = New System.Drawing.Size(102, 23)
        Me.Alloc.TabIndex = 0
        Me.Alloc.Text = "&Alloc"
        Me.Alloc.UseVisualStyleBackColor = True
        '
        'Pattern1
        '
        Me.Pattern1.Location = New System.Drawing.Point(12, 41)
        Me.Pattern1.Name = "Pattern1"
        Me.Pattern1.Size = New System.Drawing.Size(102, 23)
        Me.Pattern1.TabIndex = 1
        Me.Pattern1.Text = "Pattern &1"
        Me.Pattern1.UseVisualStyleBackColor = True
        '
        'Pattern2
        '
        Me.Pattern2.Location = New System.Drawing.Point(12, 70)
        Me.Pattern2.Name = "Pattern2"
        Me.Pattern2.Size = New System.Drawing.Size(102, 23)
        Me.Pattern2.TabIndex = 2
        Me.Pattern2.Text = "Pattern &2"
        Me.Pattern2.UseVisualStyleBackColor = True
        '
        'Free
        '
        Me.Free.Location = New System.Drawing.Point(12, 128)
        Me.Free.Name = "Free"
        Me.Free.Size = New System.Drawing.Size(102, 23)
        Me.Free.TabIndex = 4
        Me.Free.Text = "&Free"
        Me.Free.UseVisualStyleBackColor = True
        '
        'Clear
        '
        Me.Clear.Location = New System.Drawing.Point(12, 99)
        Me.Clear.Name = "Clear"
        Me.Clear.Size = New System.Drawing.Size(102, 23)
        Me.Clear.TabIndex = 3
        Me.Clear.Text = "&Clear"
        Me.Clear.UseVisualStyleBackColor = True
        '
        'Label1
        '
        Me.Label1.AutoSize = True
        Me.Label1.Location = New System.Drawing.Point(120, 46)
        Me.Label1.Name = "Label1"
        Me.Label1.Size = New System.Drawing.Size(229, 13)
        Me.Label1.TabIndex = 5
        Me.Label1.Text = "Checkered Pattern 64x64: load and reset DMD"
        '
        'Label2
        '
        Me.Label2.AutoSize = True
        Me.Label2.Location = New System.Drawing.Point(120, 75)
        Me.Label2.Name = "Label2"
        Me.Label2.Size = New System.Drawing.Size(241, 13)
        Me.Label2.TabIndex = 6
        Me.Label2.Text = "Checkered Pattern 128x128: load and reset DMD"
        '
        'Label3
        '
        Me.Label3.AutoSize = True
        Me.Label3.Location = New System.Drawing.Point(120, 104)
        Me.Label3.Name = "Label3"
        Me.Label3.Size = New System.Drawing.Size(146, 13)
        Me.Label3.TabIndex = 7
        Me.Label3.Text = "clear and reset DMD to black"
        '
        'ALP_basic_Test
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(6.0!, 13.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.ClientSize = New System.Drawing.Size(362, 165)
        Me.Controls.Add(Me.Label3)
        Me.Controls.Add(Me.Label2)
        Me.Controls.Add(Me.Label1)
        Me.Controls.Add(Me.Clear)
        Me.Controls.Add(Me.Free)
        Me.Controls.Add(Me.Pattern2)
        Me.Controls.Add(Me.Pattern1)
        Me.Controls.Add(Me.Alloc)
        Me.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog
        Me.MaximizeBox = False
        Me.Name = "ALP_basic_Test"
        Me.Text = "ALP basic Test"
        Me.ResumeLayout(False)
        Me.PerformLayout()

    End Sub
    Friend WithEvents Alloc As System.Windows.Forms.Button
    Friend WithEvents Pattern1 As System.Windows.Forms.Button
    Friend WithEvents Pattern2 As System.Windows.Forms.Button
    Friend WithEvents Free As System.Windows.Forms.Button
    Friend WithEvents Clear As System.Windows.Forms.Button
    Friend WithEvents Label1 As System.Windows.Forms.Label
    Friend WithEvents Label2 As System.Windows.Forms.Label
    Friend WithEvents Label3 As System.Windows.Forms.Label

End Class
