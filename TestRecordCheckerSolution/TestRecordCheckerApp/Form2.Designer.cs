namespace TestRecordCheckerApp
{
    partial class logInForm
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(logInForm));
            this.lblScanENumber = new System.Windows.Forms.Label();
            this.txtEmployeeNumber = new System.Windows.Forms.TextBox();
            this.btnLogIn = new System.Windows.Forms.Button();
            this.panel1 = new System.Windows.Forms.Panel();
            this.raleighLogo = new System.Windows.Forms.PictureBox();
            this.pictureBox1 = new System.Windows.Forms.PictureBox();
            this.label1 = new System.Windows.Forms.Label();
            this.panel2 = new System.Windows.Forms.Panel();
            this.lblPlant = new System.Windows.Forms.Label();
            this.lblLine = new System.Windows.Forms.Label();
            this.lblSubLine = new System.Windows.Forms.Label();
            this.lblStation = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.panel1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.raleighLogo)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox1)).BeginInit();
            this.SuspendLayout();
            // 
            // lblScanENumber
            // 
            this.lblScanENumber.Font = new System.Drawing.Font("Segoe UI", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblScanENumber.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(46)))), ((int)(((byte)(86)))), ((int)(((byte)(171)))));
            this.lblScanENumber.Location = new System.Drawing.Point(530, 294);
            this.lblScanENumber.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.lblScanENumber.Name = "lblScanENumber";
            this.lblScanENumber.Size = new System.Drawing.Size(283, 34);
            this.lblScanENumber.TabIndex = 10;
            this.lblScanENumber.Text = "Scan your E-Number";
            this.lblScanENumber.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // txtEmployeeNumber
            // 
            this.txtEmployeeNumber.BackColor = System.Drawing.Color.LightGray;
            this.txtEmployeeNumber.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.txtEmployeeNumber.CharacterCasing = System.Windows.Forms.CharacterCasing.Upper;
            this.txtEmployeeNumber.Font = new System.Drawing.Font("Segoe UI", 14F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.txtEmployeeNumber.Location = new System.Drawing.Point(530, 334);
            this.txtEmployeeNumber.Margin = new System.Windows.Forms.Padding(8, 7, 8, 7);
            this.txtEmployeeNumber.Name = "txtEmployeeNumber";
            this.txtEmployeeNumber.Size = new System.Drawing.Size(300, 45);
            this.txtEmployeeNumber.TabIndex = 11;
            this.txtEmployeeNumber.TextAlign = System.Windows.Forms.HorizontalAlignment.Center;
            this.txtEmployeeNumber.WordWrap = false;
            this.txtEmployeeNumber.TextChanged += new System.EventHandler(this.textBox2_TextChanged);
            this.txtEmployeeNumber.KeyDown += new System.Windows.Forms.KeyEventHandler(this.textBox2_KeyDown);
            // 
            // btnLogIn
            // 
            this.btnLogIn.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(46)))), ((int)(((byte)(86)))), ((int)(((byte)(171)))));
            this.btnLogIn.Enabled = false;
            this.btnLogIn.FlatStyle = System.Windows.Forms.FlatStyle.System;
            this.btnLogIn.Font = new System.Drawing.Font("Segoe UI", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnLogIn.ForeColor = System.Drawing.SystemColors.ButtonHighlight;
            this.btnLogIn.Location = new System.Drawing.Point(606, 389);
            this.btnLogIn.Margin = new System.Windows.Forms.Padding(4);
            this.btnLogIn.Name = "btnLogIn";
            this.btnLogIn.Size = new System.Drawing.Size(147, 47);
            this.btnLogIn.TabIndex = 12;
            this.btnLogIn.Text = "Log In";
            this.btnLogIn.UseVisualStyleBackColor = false;
            this.btnLogIn.Click += new System.EventHandler(this.button1_Click);
            // 
            // panel1
            // 
            this.panel1.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(46)))), ((int)(((byte)(86)))), ((int)(((byte)(171)))));
            this.panel1.Controls.Add(this.label2);
            this.panel1.Controls.Add(this.lblStation);
            this.panel1.Controls.Add(this.lblSubLine);
            this.panel1.Controls.Add(this.lblLine);
            this.panel1.Controls.Add(this.lblPlant);
            this.panel1.Controls.Add(this.panel2);
            this.panel1.Controls.Add(this.label1);
            this.panel1.Controls.Add(this.pictureBox1);
            this.panel1.Location = new System.Drawing.Point(0, 0);
            this.panel1.Margin = new System.Windows.Forms.Padding(8);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(464, 580);
            this.panel1.TabIndex = 13;
            // 
            // raleighLogo
            // 
            this.raleighLogo.BackgroundImage = ((System.Drawing.Image)(resources.GetObject("raleighLogo.BackgroundImage")));
            this.raleighLogo.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.raleighLogo.InitialImage = ((System.Drawing.Image)(resources.GetObject("raleighLogo.InitialImage")));
            this.raleighLogo.Location = new System.Drawing.Point(580, 45);
            this.raleighLogo.Margin = new System.Windows.Forms.Padding(4);
            this.raleighLogo.Name = "raleighLogo";
            this.raleighLogo.Size = new System.Drawing.Size(200, 128);
            this.raleighLogo.TabIndex = 9;
            this.raleighLogo.TabStop = false;
            // 
            // pictureBox1
            // 
            this.pictureBox1.BackgroundImage = global::TestRecordCheckerApp.Properties.Resources.Eaton_Logo_2;
            this.pictureBox1.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.pictureBox1.InitialImage = global::TestRecordCheckerApp.Properties.Resources.Eaton_Logo_2;
            this.pictureBox1.Location = new System.Drawing.Point(13, 34);
            this.pictureBox1.Margin = new System.Windows.Forms.Padding(4);
            this.pictureBox1.Name = "pictureBox1";
            this.pictureBox1.Size = new System.Drawing.Size(179, 58);
            this.pictureBox1.SizeMode = System.Windows.Forms.PictureBoxSizeMode.StretchImage;
            this.pictureBox1.TabIndex = 16;
            this.pictureBox1.TabStop = false;
            // 
            // label1
            // 
            this.label1.Font = new System.Drawing.Font("Segoe UI", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label1.ForeColor = System.Drawing.Color.White;
            this.label1.Location = new System.Drawing.Point(4, 106);
            this.label1.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(456, 98);
            this.label1.TabIndex = 17;
            this.label1.Text = "TDM RESULTS VERIFIER";
            this.label1.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // panel2
            // 
            this.panel2.AutoSizeMode = System.Windows.Forms.AutoSizeMode.GrowAndShrink;
            this.panel2.BackColor = System.Drawing.Color.Teal;
            this.panel2.Location = new System.Drawing.Point(-19, 194);
            this.panel2.Name = "panel2";
            this.panel2.Size = new System.Drawing.Size(500, 4);
            this.panel2.TabIndex = 18;
            // 
            // lblPlant
            // 
            this.lblPlant.Font = new System.Drawing.Font("Segoe UI", 14F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblPlant.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(224)))), ((int)(((byte)(224)))), ((int)(((byte)(224)))));
            this.lblPlant.Location = new System.Drawing.Point(4, 230);
            this.lblPlant.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.lblPlant.Name = "lblPlant";
            this.lblPlant.Size = new System.Drawing.Size(456, 53);
            this.lblPlant.TabIndex = 19;
            this.lblPlant.Text = "Plant";
            this.lblPlant.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblLine
            // 
            this.lblLine.Font = new System.Drawing.Font("Segoe UI", 14F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblLine.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(224)))), ((int)(((byte)(224)))), ((int)(((byte)(224)))));
            this.lblLine.Location = new System.Drawing.Point(4, 292);
            this.lblLine.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.lblLine.Name = "lblLine";
            this.lblLine.Size = new System.Drawing.Size(456, 53);
            this.lblLine.TabIndex = 20;
            this.lblLine.Text = "Plant";
            this.lblLine.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblSubLine
            // 
            this.lblSubLine.Font = new System.Drawing.Font("Segoe UI", 14F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblSubLine.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(224)))), ((int)(((byte)(224)))), ((int)(((byte)(224)))));
            this.lblSubLine.Location = new System.Drawing.Point(4, 355);
            this.lblSubLine.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.lblSubLine.Name = "lblSubLine";
            this.lblSubLine.Size = new System.Drawing.Size(456, 53);
            this.lblSubLine.TabIndex = 21;
            this.lblSubLine.Text = "Plant";
            this.lblSubLine.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblStation
            // 
            this.lblStation.Font = new System.Drawing.Font("Segoe UI", 14F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblStation.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(224)))), ((int)(((byte)(224)))), ((int)(((byte)(224)))));
            this.lblStation.Location = new System.Drawing.Point(4, 421);
            this.lblStation.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.lblStation.Name = "lblStation";
            this.lblStation.Size = new System.Drawing.Size(456, 53);
            this.lblStation.TabIndex = 22;
            this.lblStation.Text = "Plant";
            this.lblStation.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // label2
            // 
            this.label2.Font = new System.Drawing.Font("Segoe UI", 7.8F, System.Drawing.FontStyle.Italic, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label2.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(224)))), ((int)(((byte)(224)))), ((int)(((byte)(224)))));
            this.label2.Location = new System.Drawing.Point(4, 534);
            this.label2.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(456, 39);
            this.label2.TabIndex = 23;
            this.label2.Text = "Plant";
            this.label2.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // logInForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 16F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.AutoSizeMode = System.Windows.Forms.AutoSizeMode.GrowAndShrink;
            this.BackColor = System.Drawing.Color.White;
            this.ClientSize = new System.Drawing.Size(920, 580);
            this.Controls.Add(this.raleighLogo);
            this.Controls.Add(this.panel1);
            this.Controls.Add(this.btnLogIn);
            this.Controls.Add(this.txtEmployeeNumber);
            this.Controls.Add(this.lblScanENumber);
            this.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.MaximizeBox = false;
            this.Name = "logInForm";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "TDM Results Verifier - Log In";
            this.Load += new System.EventHandler(this.logInForm_Load);
            this.panel1.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.raleighLogo)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox1)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion
        private System.Windows.Forms.Label lblScanENumber;
        private System.Windows.Forms.TextBox txtEmployeeNumber;
        private System.Windows.Forms.Button btnLogIn;
        private System.Windows.Forms.Panel panel1;
        private System.Windows.Forms.PictureBox raleighLogo;
        private System.Windows.Forms.PictureBox pictureBox1;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Panel panel2;
        private System.Windows.Forms.Label lblPlant;
        private System.Windows.Forms.Label lblSubLine;
        private System.Windows.Forms.Label lblLine;
        private System.Windows.Forms.Label lblStation;
        private System.Windows.Forms.Label label2;
    }
}