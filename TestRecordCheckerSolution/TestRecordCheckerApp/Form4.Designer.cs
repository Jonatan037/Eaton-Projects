namespace TestRecordCheckerApp
{
    partial class FeedbackForm
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
            this.components = new System.ComponentModel.Container();
            this.lblMessage = new System.Windows.Forms.Label();
            this.pictureBoxEmergency = new System.Windows.Forms.PictureBox();
            this.pictureBoxCheckmark = new System.Windows.Forms.PictureBox();
            this.timerClose = new System.Windows.Forms.Timer(this.components);
            this.timerSound = new System.Windows.Forms.Timer(this.components);
            this.timerGifRefresh = new System.Windows.Forms.Timer(this.components);
            ((System.ComponentModel.ISupportInitialize)(this.pictureBoxEmergency)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBoxCheckmark)).BeginInit();
            this.SuspendLayout();
            //
            // lblMessage
            //
            this.lblMessage.AutoSize = true;
            this.lblMessage.Font = new System.Drawing.Font("Segoe UI", 48F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblMessage.ForeColor = System.Drawing.Color.White;
            this.lblMessage.Location = new System.Drawing.Point(400, 300);
            this.lblMessage.Name = "lblMessage";
            this.lblMessage.Size = new System.Drawing.Size(1120, 87);
            this.lblMessage.TabIndex = 0;
            this.lblMessage.Text = "TEST PASSED - PROCEED WITH PACKAGING";
            this.lblMessage.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            //
            // pictureBoxEmergency
            //
            this.pictureBoxEmergency.Location = new System.Drawing.Point(750, 450);
            this.pictureBoxEmergency.Name = "pictureBoxEmergency";
            this.pictureBoxEmergency.Size = new System.Drawing.Size(400, 300);
            this.pictureBoxEmergency.SizeMode = System.Windows.Forms.PictureBoxSizeMode.StretchImage;
            this.pictureBoxEmergency.TabIndex = 1;
            this.pictureBoxEmergency.TabStop = false;
            this.pictureBoxEmergency.Visible = false;
            //
            // pictureBoxCheckmark
            //
            this.pictureBoxCheckmark.Location = new System.Drawing.Point(750, 450);
            this.pictureBoxCheckmark.Name = "pictureBoxCheckmark";
            this.pictureBoxCheckmark.Size = new System.Drawing.Size(400, 300);
            this.pictureBoxCheckmark.SizeMode = System.Windows.Forms.PictureBoxSizeMode.StretchImage;
            this.pictureBoxCheckmark.TabIndex = 2;
            this.pictureBoxCheckmark.TabStop = false;
            this.pictureBoxCheckmark.Visible = false;
            //
            // timerClose
            //
            this.timerClose.Tick += new System.EventHandler(this.timerClose_Tick);
            //
            // timerSound
            //
            this.timerSound.Interval = 250; // Play sound every 0.25 seconds for siren effect
            this.timerSound.Tick += new System.EventHandler(this.timerSound_Tick);
            //
            // timerGifRefresh
            //
            this.timerGifRefresh.Interval = 1000; // Refresh GIFs every second to keep animation fluent
            this.timerGifRefresh.Tick += new System.EventHandler(this.timerGifRefresh_Tick);
            //
            // FeedbackForm
            //
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 16F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.LimeGreen;
            this.ClientSize = new System.Drawing.Size(1920, 1080);
            this.Controls.Add(this.pictureBoxCheckmark);
            this.Controls.Add(this.pictureBoxEmergency);
            this.Controls.Add(this.lblMessage);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.None;
            this.Name = "FeedbackForm";
            this.StartPosition = System.Windows.Forms.FormStartPosition.Manual;
            this.Text = "Feedback";
            this.TopMost = true;
            this.WindowState = System.Windows.Forms.FormWindowState.Maximized;
            this.Load += new System.EventHandler(this.FeedbackForm_Load);
            ((System.ComponentModel.ISupportInitialize)(this.pictureBoxEmergency)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBoxCheckmark)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();
        }

        #endregion

        private System.Windows.Forms.Label lblMessage;
        private System.Windows.Forms.PictureBox pictureBoxEmergency;
        private System.Windows.Forms.PictureBox pictureBoxCheckmark;
        private System.Windows.Forms.Timer timerClose;
        private System.Windows.Forms.Timer timerSound;
        private System.Windows.Forms.Timer timerGifRefresh;
    }
}
