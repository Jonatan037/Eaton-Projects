using System;
using System.Drawing;
using System.Windows.Forms;
using HipotTestApp.Data;
using HipotTestApp.Models;

namespace HipotTestApp.Forms
{
    /// <summary>
    /// Login form for user authentication
    /// </summary>
    public partial class LoginForm : Form
    {
        private DatabaseHelper _dbHelper;
        
        /// <summary>
        /// Gets the authenticated user
        /// </summary>
        public User AuthenticatedUser { get; private set; }

        public LoginForm()
        {
            InitializeComponent();
            _dbHelper = new DatabaseHelper();
        }

        private void InitializeComponent()
        {
            this.SuspendLayout();

            // Form properties
            this.Text = "Hipot Test Application - Login";
            this.Size = new Size(400, 320);
            this.StartPosition = FormStartPosition.CenterScreen;
            this.FormBorderStyle = FormBorderStyle.FixedDialog;
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.BackColor = Color.FromArgb(240, 240, 240);

            // Create a panel for the logo/header area
            Panel headerPanel = new Panel
            {
                Dock = DockStyle.Top,
                Height = 60,
                BackColor = Color.FromArgb(0, 70, 127) // Eaton blue
            };

            Label headerLabel = new Label
            {
                Text = "HIPOT TEST SYSTEM",
                Font = new Font("Segoe UI", 16, FontStyle.Bold),
                ForeColor = Color.White,
                AutoSize = false,
                Size = new Size(380, 40),
                Location = new Point(10, 10),
                TextAlign = ContentAlignment.MiddleCenter
            };
            headerPanel.Controls.Add(headerLabel);
            this.Controls.Add(headerPanel);

            // E-Number Label
            Label lblENumber = new Label
            {
                Text = "Employee Number:",
                Font = new Font("Segoe UI", 10),
                Location = new Point(50, 75),
                Size = new Size(130, 25)
            };
            this.Controls.Add(lblENumber);

            // E-Number TextBox
            TextBox txtENumber = new TextBox
            {
                Name = "txtENumber",
                Font = new Font("Segoe UI", 11),
                Location = new Point(50, 98),
                Size = new Size(280, 30),
                MaxLength = 20
            };
            txtENumber.KeyDown += TxtENumber_KeyDown;
            this.Controls.Add(txtENumber);

            // Password Label
            Label lblPassword = new Label
            {
                Text = "Password:",
                Font = new Font("Segoe UI", 10),
                Location = new Point(50, 135),
                Size = new Size(130, 25)
            };
            this.Controls.Add(lblPassword);

            // Password TextBox
            TextBox txtPassword = new TextBox
            {
                Name = "txtPassword",
                Font = new Font("Segoe UI", 11),
                Location = new Point(50, 158),
                Size = new Size(280, 30),
                PasswordChar = '●',
                MaxLength = 50
            };
            txtPassword.KeyDown += TxtPassword_KeyDown;
            this.Controls.Add(txtPassword);

            // Status Label - ABOVE buttons for visibility
            Label lblStatus = new Label
            {
                Name = "lblStatus",
                Text = "",
                Font = new Font("Segoe UI", 9, FontStyle.Bold),
                ForeColor = Color.Red,
                Location = new Point(50, 198),
                Size = new Size(280, 22),
                TextAlign = ContentAlignment.MiddleCenter
            };
            this.Controls.Add(lblStatus);

            // Login Button
            Button btnLogin = new Button
            {
                Name = "btnLogin",
                Text = "Login",
                Font = new Font("Segoe UI", 10, FontStyle.Bold),
                Location = new Point(50, 225),
                Size = new Size(135, 40),
                BackColor = Color.FromArgb(0, 70, 127),
                ForeColor = Color.White,
                FlatStyle = FlatStyle.Flat,
                Cursor = Cursors.Hand
            };
            btnLogin.FlatAppearance.BorderSize = 0;
            btnLogin.Click += BtnLogin_Click;
            this.Controls.Add(btnLogin);

            // Cancel Button
            Button btnCancel = new Button
            {
                Name = "btnCancel",
                Text = "Cancel",
                Font = new Font("Segoe UI", 10),
                Location = new Point(195, 225),
                Size = new Size(135, 40),
                BackColor = Color.Gray,
                ForeColor = Color.White,
                FlatStyle = FlatStyle.Flat,
                Cursor = Cursors.Hand
            };
            btnCancel.FlatAppearance.BorderSize = 0;
            btnCancel.Click += BtnCancel_Click;
            this.Controls.Add(btnCancel);

            this.ResumeLayout(false);
            this.AcceptButton = btnLogin;
            this.CancelButton = btnCancel;
        }

        private void TxtENumber_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Enter)
            {
                var txtPassword = this.Controls["txtPassword"] as TextBox;
                txtPassword?.Focus();
                e.SuppressKeyPress = true;
            }
        }

        private void TxtPassword_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Enter)
            {
                BtnLogin_Click(sender, e);
                e.SuppressKeyPress = true;
            }
        }

        private void BtnLogin_Click(object sender, EventArgs e)
        {
            var txtENumber = this.Controls["txtENumber"] as TextBox;
            var txtPassword = this.Controls["txtPassword"] as TextBox;
            var lblStatus = this.Controls["lblStatus"] as Label;
            var btnLogin = this.Controls["btnLogin"] as Button;

            // Validate input
            if (string.IsNullOrWhiteSpace(txtENumber?.Text))
            {
                lblStatus.Text = "Please enter your Employee Number";
                txtENumber?.Focus();
                return;
            }

            if (string.IsNullOrWhiteSpace(txtPassword?.Text))
            {
                lblStatus.Text = "Please enter your Password";
                txtPassword?.Focus();
                return;
            }

            // Disable login button while authenticating
            btnLogin.Enabled = false;
            lblStatus.Text = "Authenticating...";
            lblStatus.ForeColor = Color.Blue;
            Application.DoEvents();

            try
            {
                // Attempt to validate user
                var user = _dbHelper.ValidateUser(txtENumber.Text.Trim(), txtPassword.Text);

                if (user != null)
                {
                    AuthenticatedUser = user;
                    this.DialogResult = DialogResult.OK;
                    this.Close();
                }
                else
                {
                    lblStatus.ForeColor = Color.Red;
                    
                    if (!string.IsNullOrEmpty(_dbHelper.LastError))
                    {
                        lblStatus.Text = "Database error. Please contact IT.";
                        MessageBox.Show($"Database Error:\n{_dbHelper.LastError}", 
                            "Login Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    }
                    else
                    {
                        lblStatus.Text = "Invalid Employee Number or Password";
                    }
                    
                    txtPassword.Text = "";
                    txtPassword.Focus();
                }
            }
            catch (Exception ex)
            {
                lblStatus.ForeColor = Color.Red;
                lblStatus.Text = "Login failed. Please contact IT.";
                MessageBox.Show($"Error during login:\n{ex.Message}", 
                    "Login Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            finally
            {
                btnLogin.Enabled = true;
            }
        }

        private void BtnCancel_Click(object sender, EventArgs e)
        {
            this.DialogResult = DialogResult.Cancel;
            this.Close();
        }

        protected override void OnFormClosing(FormClosingEventArgs e)
        {
            base.OnFormClosing(e);
            _dbHelper?.Dispose();
        }
    }
}
