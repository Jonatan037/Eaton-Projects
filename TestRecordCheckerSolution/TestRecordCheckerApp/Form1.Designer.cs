using System.Windows.Forms;

namespace TestRecordCheckerApp
{
    partial class mainForm
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(mainForm));
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle1 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle2 = new System.Windows.Forms.DataGridViewCellStyle();
            this.lblScanSerialNumber = new System.Windows.Forms.Label();
            this.txtSerialNumber = new System.Windows.Forms.TextBox();
            this.raleighLogo = new System.Windows.Forms.PictureBox();
            this.btnCheckRecord = new System.Windows.Forms.Button();
            this.btnLogOut = new System.Windows.Forms.Button();
            this.pnlInputArea = new System.Windows.Forms.Panel();
            this.lblHistoryTitle = new System.Windows.Forms.Label();
            this.panel1 = new System.Windows.Forms.Panel();
            this.lblStation = new System.Windows.Forms.Label();
            this.lblSubLine = new System.Windows.Forms.Label();
            this.lblLine = new System.Windows.Forms.Label();
            this.lblPlant = new System.Windows.Forms.Label();
            this.panel2 = new System.Windows.Forms.Panel();
            this.label1 = new System.Windows.Forms.Label();
            this.pictureBox1 = new System.Windows.Forms.PictureBox();
            this.lblECode = new System.Windows.Forms.Label();
            this.lblName = new System.Windows.Forms.Label();
            this.lblMachine = new System.Windows.Forms.Label();
            this.dgvHistory = new System.Windows.Forms.DataGridView();
            ((System.ComponentModel.ISupportInitialize)(this.raleighLogo)).BeginInit();
            this.SuspendLayout();
            // 
            // lblScanSerialNumber
            //
            this.lblScanSerialNumber.AutoSize = true;
            this.lblScanSerialNumber.Font = new System.Drawing.Font("Segoe UI", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblScanSerialNumber.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(46)))), ((int)(((byte)(86)))), ((int)(((byte)(171)))));
            this.lblScanSerialNumber.Location = new System.Drawing.Point(20, 15);
            this.lblScanSerialNumber.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.lblScanSerialNumber.Name = "lblScanSerialNumber";
            this.lblScanSerialNumber.Size = new System.Drawing.Size(291, 32);
            this.lblScanSerialNumber.TabIndex = 2;
            this.lblScanSerialNumber.Text = "Scan the Serial Number: ";
            this.lblScanSerialNumber.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            this.lblScanSerialNumber.Click += new System.EventHandler(this.lblScanSerialNumber_Click);
            // 
            // txtSerialNumber
            //
            this.txtSerialNumber.CharacterCasing = System.Windows.Forms.CharacterCasing.Upper;
            this.txtSerialNumber.Font = new System.Drawing.Font("Segoe UI", 16F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.txtSerialNumber.Location = new System.Drawing.Point(20, 55);
            this.txtSerialNumber.Margin = new System.Windows.Forms.Padding(8, 7, 8, 7);
            this.txtSerialNumber.Name = "txtSerialNumber";
            this.txtSerialNumber.Size = new System.Drawing.Size(450, 36);
            this.txtSerialNumber.TabIndex = 3;
            this.txtSerialNumber.KeyDown += new System.Windows.Forms.KeyEventHandler(this.textBox2_KeyDown);
            // 
            // raleighLogo
            // 
            this.raleighLogo.BackgroundImage = ((System.Drawing.Image)(resources.GetObject("raleighLogo.BackgroundImage")));
            this.raleighLogo.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.raleighLogo.InitialImage = ((System.Drawing.Image)(resources.GetObject("raleighLogo.InitialImage")));
            this.raleighLogo.Location = new System.Drawing.Point(104, 520);
            this.raleighLogo.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.raleighLogo.Name = "raleighLogo";
            this.raleighLogo.Size = new System.Drawing.Size(150, 75);
            this.raleighLogo.TabIndex = 5;
            this.raleighLogo.TabStop = false;
            // 
            // btnCheckRecord
            //
            this.btnCheckRecord.Font = new System.Drawing.Font("Segoe UI", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnCheckRecord.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(46)))), ((int)(((byte)(86)))), ((int)(((byte)(171)))));
            this.btnCheckRecord.Location = new System.Drawing.Point(20, 110);
            this.btnCheckRecord.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.btnCheckRecord.Name = "btnCheckRecord";
            this.btnCheckRecord.Size = new System.Drawing.Size(180, 45);
            this.btnCheckRecord.TabIndex = 4;
            this.btnCheckRecord.Text = "Check Record";
            this.btnCheckRecord.UseVisualStyleBackColor = true;
            this.btnCheckRecord.Click += new System.EventHandler(this.button1_Click_1);
            // 
            // btnLogOut
            //
            this.btnLogOut.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(220)))), ((int)(((byte)(53)))), ((int)(((byte)(69)))));
            this.btnLogOut.Cursor = System.Windows.Forms.Cursors.Hand;
            this.btnLogOut.FlatAppearance.BorderSize = 0;
            this.btnLogOut.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnLogOut.Font = new System.Drawing.Font("Segoe UI", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnLogOut.ForeColor = System.Drawing.Color.White;
            this.btnLogOut.Location = new System.Drawing.Point(54, 800);
            this.btnLogOut.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.btnLogOut.Name = "btnLogOut";
            this.btnLogOut.Size = new System.Drawing.Size(250, 50);
            this.btnLogOut.TabIndex = 10;
            this.btnLogOut.Text = "Log Out";
            this.btnLogOut.UseVisualStyleBackColor = false;
            this.btnLogOut.Click += new System.EventHandler(this.button2_Click);
            this.btnLogOut.MouseEnter += new System.EventHandler(this.btnLogOut_MouseEnter);
            this.btnLogOut.MouseLeave += new System.EventHandler(this.btnLogOut_MouseLeave);
            // 
            // pnlInputArea
            //
            this.pnlInputArea.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(240)))), ((int)(((byte)(248)))), ((int)(((byte)(255)))));
            this.pnlInputArea.Controls.Add(this.btnCheckRecord);
            this.pnlInputArea.Controls.Add(this.txtSerialNumber);
            this.pnlInputArea.Controls.Add(this.lblScanSerialNumber);
            this.pnlInputArea.Location = new System.Drawing.Point(400, 50);
            this.pnlInputArea.Margin = new System.Windows.Forms.Padding(4);
            this.pnlInputArea.Name = "pnlInputArea";
            this.pnlInputArea.Size = new System.Drawing.Size(500, 250);
            this.pnlInputArea.TabIndex = 29;
            // 
            // lblHistoryTitle
            //
            this.lblHistoryTitle.AutoSize = true;
            this.lblHistoryTitle.Font = new System.Drawing.Font("Segoe UI", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblHistoryTitle.ForeColor = System.Drawing.Color.Black;
            this.lblHistoryTitle.Location = new System.Drawing.Point(400, 320);
            this.lblHistoryTitle.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.lblHistoryTitle.Name = "lblHistoryTitle";
            this.lblHistoryTitle.Size = new System.Drawing.Size(200, 25);
            this.lblHistoryTitle.TabIndex = 30;
            this.lblHistoryTitle.Text = "S/N Verification History";
            this.lblHistoryTitle.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            this.panel1.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(46)))), ((int)(((byte)(86)))), ((int)(((byte)(171)))));
            this.panel1.Controls.Add(this.lblMachine);
            this.panel1.Controls.Add(this.lblName);
            this.panel1.Controls.Add(this.btnLogOut);
            this.panel1.Controls.Add(this.lblECode);
            this.panel1.Controls.Add(this.lblStation);
            this.panel1.Controls.Add(this.lblSubLine);
            this.panel1.Controls.Add(this.lblLine);
            this.panel1.Controls.Add(this.lblPlant);
            this.panel1.Controls.Add(this.panel2);
            this.panel1.Controls.Add(this.label1);
            this.panel1.Controls.Add(this.pictureBox1);
            this.panel1.Controls.Add(this.raleighLogo);
            this.panel1.Dock = System.Windows.Forms.DockStyle.Left;
            this.panel1.Location = new System.Drawing.Point(0, 0);
            this.panel1.Margin = new System.Windows.Forms.Padding(8);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(357, 900);
            this.panel1.TabIndex = 14;
            // 
            // lblStation
            // 
            this.lblStation.Font = new System.Drawing.Font("Segoe UI", 10F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblStation.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(224)))), ((int)(((byte)(224)))), ((int)(((byte)(224)))));
            this.lblStation.Location = new System.Drawing.Point(13, 300);
            this.lblStation.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.lblStation.Name = "lblStation";
            this.lblStation.Size = new System.Drawing.Size(336, 29);
            this.lblStation.TabIndex = 22;
            this.lblStation.Text = "Plant";
            this.lblStation.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // lblSubLine
            // 
            this.lblSubLine.Font = new System.Drawing.Font("Segoe UI", 10F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblSubLine.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(224)))), ((int)(((byte)(224)))), ((int)(((byte)(224)))));
            this.lblSubLine.Location = new System.Drawing.Point(13, 251);
            this.lblSubLine.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.lblSubLine.Name = "lblSubLine";
            this.lblSubLine.Size = new System.Drawing.Size(336, 29);
            this.lblSubLine.TabIndex = 21;
            this.lblSubLine.Text = "Plant";
            this.lblSubLine.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // lblLine
            // 
            this.lblLine.Font = new System.Drawing.Font("Segoe UI", 10F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblLine.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(224)))), ((int)(((byte)(224)))), ((int)(((byte)(224)))));
            this.lblLine.Location = new System.Drawing.Point(13, 204);
            this.lblLine.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.lblLine.Name = "lblLine";
            this.lblLine.Size = new System.Drawing.Size(336, 29);
            this.lblLine.TabIndex = 20;
            this.lblLine.Text = "Plant";
            this.lblLine.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // lblPlant
            // 
            this.lblPlant.Font = new System.Drawing.Font("Segoe UI", 10F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblPlant.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(224)))), ((int)(((byte)(224)))), ((int)(((byte)(224)))));
            this.lblPlant.Location = new System.Drawing.Point(13, 154);
            this.lblPlant.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.lblPlant.Name = "lblPlant";
            this.lblPlant.Size = new System.Drawing.Size(336, 29);
            this.lblPlant.TabIndex = 19;
            this.lblPlant.Text = "Plant";
            this.lblPlant.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // panel2
            // 
            this.panel2.AutoSizeMode = System.Windows.Forms.AutoSizeMode.GrowAndShrink;
            this.panel2.BackColor = System.Drawing.Color.Teal;
            this.panel2.Location = new System.Drawing.Point(-19, 133);
            this.panel2.Name = "panel2";
            this.panel2.Size = new System.Drawing.Size(500, 4);
            this.panel2.TabIndex = 18;
            // 
            // label1
            // 
            this.label1.Font = new System.Drawing.Font("Segoe UI", 16F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label1.ForeColor = System.Drawing.Color.White;
            this.label1.Location = new System.Drawing.Point(1, 69);
            this.label1.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(356, 64);
            this.label1.TabIndex = 17;
            this.label1.Text = "TDM RESULTS VERIFIER";
            this.label1.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // pictureBox1
            // 
            this.pictureBox1.BackgroundImage = global::TestRecordCheckerApp.Properties.Resources.Eaton_Logo_2;
            this.pictureBox1.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.pictureBox1.InitialImage = global::TestRecordCheckerApp.Properties.Resources.Eaton_Logo_2;
            this.pictureBox1.Location = new System.Drawing.Point(9, 13);
            this.pictureBox1.Margin = new System.Windows.Forms.Padding(4);
            this.pictureBox1.Name = "pictureBox1";
            this.pictureBox1.Size = new System.Drawing.Size(156, 45);
            this.pictureBox1.SizeMode = System.Windows.Forms.PictureBoxSizeMode.StretchImage;
            this.pictureBox1.TabIndex = 16;
            this.pictureBox1.TabStop = false;
            // 
            // lblECode
            // 
            this.lblECode.Font = new System.Drawing.Font("Segoe UI", 10F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblECode.ForeColor = System.Drawing.Color.Yellow;
            this.lblECode.Location = new System.Drawing.Point(13, 349);
            this.lblECode.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.lblECode.Name = "lblECode";
            this.lblECode.Size = new System.Drawing.Size(336, 29);
            this.lblECode.TabIndex = 23;
            this.lblECode.Text = "Plant";
            this.lblECode.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // lblName
            // 
            this.lblName.Font = new System.Drawing.Font("Segoe UI", 10F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblName.ForeColor = System.Drawing.Color.Yellow;
            this.lblName.Location = new System.Drawing.Point(13, 397);
            this.lblName.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.lblName.Name = "lblName";
            this.lblName.Size = new System.Drawing.Size(336, 29);
            this.lblName.TabIndex = 24;
            this.lblName.Text = "Plant";
            this.lblName.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // lblMachine
            // 
            this.lblMachine.Font = new System.Drawing.Font("Segoe UI", 8F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblMachine.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(224)))), ((int)(((byte)(224)))), ((int)(((byte)(224)))));
            this.lblMachine.Location = new System.Drawing.Point(13, 446);
            this.lblMachine.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.lblMachine.Name = "lblMachine";
            this.lblMachine.Size = new System.Drawing.Size(336, 29);
            this.lblMachine.TabIndex = 25;
            this.lblMachine.Text = "Plant";
            this.lblMachine.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // dgvHistory
            //
            this.dgvHistory.AllowUserToAddRows = false;
            this.dgvHistory.AllowUserToDeleteRows = false;
            this.dgvHistory.AutoSizeColumnsMode = System.Windows.Forms.DataGridViewAutoSizeColumnsMode.Fill;
            this.dgvHistory.BackgroundColor = System.Drawing.Color.WhiteSmoke;
            this.dgvHistory.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.dgvHistory.ColumnHeadersDefaultCellStyle = dataGridViewCellStyle1;
            this.dgvHistory.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dgvHistory.DefaultCellStyle = dataGridViewCellStyle2;
            this.dgvHistory.Location = new System.Drawing.Point(400, 350);
            this.dgvHistory.MultiSelect = false;
            this.dgvHistory.Name = "dgvHistory";
            this.dgvHistory.ReadOnly = true;
            this.dgvHistory.RowHeadersWidth = 51;
            this.dgvHistory.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect;
            this.dgvHistory.Size = new System.Drawing.Size(1000, 500);
            this.dgvHistory.TabIndex = 28;
            // 
            // mainForm
            //
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 16F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.AutoSizeMode = System.Windows.Forms.AutoSizeMode.GrowAndShrink;
            this.ClientSize = new System.Drawing.Size(1450, 900);
            this.Controls.Add(this.panel1);
            this.Controls.Add(this.lblHistoryTitle);
            this.Controls.Add(this.pnlInputArea);
            this.Controls.Add(this.dgvHistory);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.Sizable;
            this.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.MaximizeBox = true;
            this.MinimizeBox = true;
            this.Name = "mainForm";
            this.Text = "TDM Test Results Verifier";
            this.WindowState = System.Windows.Forms.FormWindowState.Normal;
            this.Load += new System.EventHandler(this.mainForm_Load);
            ((System.ComponentModel.ISupportInitialize)(this.raleighLogo)).EndInit();
            this.panel1.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox1)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.dgvHistory)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion
        private System.Windows.Forms.Label lblScanSerialNumber;
        private System.Windows.Forms.TextBox txtSerialNumber;
        private System.Windows.Forms.PictureBox raleighLogo;
        private System.Windows.Forms.Button btnCheckRecord;
        private System.Windows.Forms.Button btnLogOut;
        private System.Windows.Forms.Panel pnlInputArea;
        private System.Windows.Forms.Label lblHistoryTitle;
        private Panel panel1;
        private Label lblStation;
        private Label lblSubLine;
        private Label lblLine;
        private Label lblPlant;
        private Panel panel2;
        private Label label1;
        private PictureBox pictureBox1;
        private Label lblName;
        private Label lblECode;
        private Label lblMachine;
        private System.Windows.Forms.DataGridView dgvHistory;
    }
}

