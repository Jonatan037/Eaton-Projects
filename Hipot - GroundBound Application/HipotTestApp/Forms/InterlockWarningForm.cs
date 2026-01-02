using System;
using System.Drawing;
using System.IO;
using System.Windows.Forms;

namespace HipotTestApp.Forms
{
    /// <summary>
    /// Warning dialog shown before running any test to ensure interlock is properly set up
    /// and the test area is safe.
    /// </summary>
    public class InterlockWarningForm : Form
    {
        private PictureBox picInterlockSwitch;
        private PictureBox picReadyLight;
        private CheckBox chkInterlockOn;
        private CheckBox chkReadyLight;
        private CheckBox chkAreaClear;
        private Button btnProceed;
        private Button btnCancel;

        public InterlockWarningForm()
        {
            InitializeComponent();
            LoadImages();
        }

        private void InitializeComponent()
        {
            this.Text = "⚠ SAFETY CHECK - Verify Interlock Before Testing";
            this.Size = new Size(800, 650);
            this.StartPosition = FormStartPosition.CenterParent;
            this.FormBorderStyle = FormBorderStyle.FixedDialog;
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.BackColor = Color.FromArgb(45, 45, 48);
            this.ForeColor = Color.White;

            // Warning Header
            var lblHeader = new Label
            {
                Text = "⚠ SAFETY VERIFICATION REQUIRED",
                Font = new Font("Segoe UI", 18, FontStyle.Bold),
                ForeColor = Color.Yellow,
                TextAlign = ContentAlignment.MiddleCenter,
                Dock = DockStyle.Top,
                Height = 50,
                BackColor = Color.FromArgb(180, 0, 0)
            };
            this.Controls.Add(lblHeader);

            // Main panel
            var mainPanel = new Panel
            {
                Dock = DockStyle.Fill,
                Padding = new Padding(20)
            };
            this.Controls.Add(mainPanel);
            mainPanel.BringToFront();

            // Instructions label
            var lblInstructions = new Label
            {
                Text = "Before starting the test, please verify the following safety conditions:",
                Font = new Font("Segoe UI", 11),
                Location = new Point(20, 20),
                Size = new Size(740, 30),
                ForeColor = Color.White
            };
            mainPanel.Controls.Add(lblInstructions);

            // Create image and checkbox panels
            var imagesPanel = new Panel
            {
                Location = new Point(20, 60),
                Size = new Size(740, 280)
            };
            mainPanel.Controls.Add(imagesPanel);

            // Left panel - Interlock Switch
            var leftPanel = new Panel
            {
                Location = new Point(0, 0),
                Size = new Size(360, 280),
                BackColor = Color.FromArgb(60, 60, 60),
                BorderStyle = BorderStyle.FixedSingle
            };
            imagesPanel.Controls.Add(leftPanel);

            var lblInterlockTitle = new Label
            {
                Text = "1. INTERLOCK SWITCH",
                Font = new Font("Segoe UI", 12, FontStyle.Bold),
                Location = new Point(10, 10),
                Size = new Size(340, 25),
                ForeColor = Color.White,
                TextAlign = ContentAlignment.MiddleCenter
            };
            leftPanel.Controls.Add(lblInterlockTitle);

            picInterlockSwitch = new PictureBox
            {
                Location = new Point(30, 40),
                Size = new Size(300, 200),
                SizeMode = PictureBoxSizeMode.Zoom,
                BackColor = Color.FromArgb(40, 40, 40)
            };
            leftPanel.Controls.Add(picInterlockSwitch);

            var lblInterlockDesc = new Label
            {
                Text = "Verify switch is in the ON position",
                Font = new Font("Segoe UI", 9),
                Location = new Point(10, 245),
                Size = new Size(340, 25),
                ForeColor = Color.LightGray,
                TextAlign = ContentAlignment.MiddleCenter
            };
            leftPanel.Controls.Add(lblInterlockDesc);

            // Right panel - Ready Light
            var rightPanel = new Panel
            {
                Location = new Point(380, 0),
                Size = new Size(360, 280),
                BackColor = Color.FromArgb(60, 60, 60),
                BorderStyle = BorderStyle.FixedSingle
            };
            imagesPanel.Controls.Add(rightPanel);

            var lblReadyTitle = new Label
            {
                Text = "2. READY LIGHT STATUS",
                Font = new Font("Segoe UI", 12, FontStyle.Bold),
                Location = new Point(10, 10),
                Size = new Size(340, 25),
                ForeColor = Color.White,
                TextAlign = ContentAlignment.MiddleCenter
            };
            rightPanel.Controls.Add(lblReadyTitle);

            picReadyLight = new PictureBox
            {
                Location = new Point(30, 40),
                Size = new Size(300, 200),
                SizeMode = PictureBoxSizeMode.Zoom,
                BackColor = Color.FromArgb(40, 40, 40)
            };
            rightPanel.Controls.Add(picReadyLight);

            var lblReadyDesc = new Label
            {
                Text = "GREEN light = Ready, RED = Interlock Open",
                Font = new Font("Segoe UI", 9),
                Location = new Point(10, 245),
                Size = new Size(340, 25),
                ForeColor = Color.LightGray,
                TextAlign = ContentAlignment.MiddleCenter
            };
            rightPanel.Controls.Add(lblReadyDesc);

            // Checkboxes panel
            var checkPanel = new Panel
            {
                Location = new Point(20, 350),
                Size = new Size(740, 130),
                BackColor = Color.FromArgb(60, 60, 60),
                BorderStyle = BorderStyle.FixedSingle
            };
            mainPanel.Controls.Add(checkPanel);

            var lblVerify = new Label
            {
                Text = "Please confirm the following before proceeding:",
                Font = new Font("Segoe UI", 10, FontStyle.Bold),
                Location = new Point(15, 10),
                Size = new Size(710, 25),
                ForeColor = Color.Yellow
            };
            checkPanel.Controls.Add(lblVerify);

            chkInterlockOn = new CheckBox
            {
                Text = "The INTERLOCK SWITCH is in the ON position (as shown in image above)",
                Font = new Font("Segoe UI", 10),
                Location = new Point(20, 40),
                Size = new Size(700, 25),
                ForeColor = Color.White
            };
            chkInterlockOn.CheckedChanged += Checkbox_CheckedChanged;
            checkPanel.Controls.Add(chkInterlockOn);

            chkReadyLight = new CheckBox
            {
                Text = "The GREEN READY light is ON (not the red Interlock Open light)",
                Font = new Font("Segoe UI", 10),
                Location = new Point(20, 65),
                Size = new Size(700, 25),
                ForeColor = Color.White
            };
            chkReadyLight.CheckedChanged += Checkbox_CheckedChanged;
            checkPanel.Controls.Add(chkReadyLight);

            chkAreaClear = new CheckBox
            {
                Text = "The TEST CAGE IS CLEAR - No personnel inside the testing area",
                Font = new Font("Segoe UI", 10, FontStyle.Bold),
                Location = new Point(20, 90),
                Size = new Size(700, 25),
                ForeColor = Color.OrangeRed
            };
            chkAreaClear.CheckedChanged += Checkbox_CheckedChanged;
            checkPanel.Controls.Add(chkAreaClear);

            // Buttons panel
            var buttonPanel = new Panel
            {
                Dock = DockStyle.Bottom,
                Height = 60,
                BackColor = Color.FromArgb(30, 30, 30)
            };
            this.Controls.Add(buttonPanel);
            buttonPanel.BringToFront();

            btnCancel = new Button
            {
                Text = "Cancel",
                Size = new Size(120, 40),
                Location = new Point(this.Width / 2 - 140, 10),
                FlatStyle = FlatStyle.Flat,
                BackColor = Color.FromArgb(100, 100, 100),
                ForeColor = Color.White,
                Font = new Font("Segoe UI", 11),
                Cursor = Cursors.Hand
            };
            btnCancel.FlatAppearance.BorderColor = Color.Gray;
            btnCancel.Click += BtnCancel_Click;
            buttonPanel.Controls.Add(btnCancel);

            btnProceed = new Button
            {
                Text = "✓ Proceed with Test",
                Size = new Size(180, 40),
                Location = new Point(this.Width / 2 + 20, 10),
                FlatStyle = FlatStyle.Flat,
                BackColor = Color.Gray,
                ForeColor = Color.White,
                Font = new Font("Segoe UI", 11, FontStyle.Bold),
                Enabled = false,
                Cursor = Cursors.Hand
            };
            btnProceed.FlatAppearance.BorderColor = Color.Gray;
            btnProceed.Click += BtnProceed_Click;
            buttonPanel.Controls.Add(btnProceed);
        }

        private void LoadImages()
        {
            try
            {
                // Get the application directory
                string appDir = AppDomain.CurrentDomain.BaseDirectory;
                string imageDir = Path.Combine(appDir, "Interlock Check Instructions");

                // Load interlock switch image (shows the ON position)
                string switchImagePath = Path.Combine(imageDir, "Interlock On Position.jpg");
                if (File.Exists(switchImagePath))
                {
                    picInterlockSwitch.Image = Image.FromFile(switchImagePath);
                }
                else
                {
                    // Try alternate names
                    string[] alternateNames = { "Interlock_Switch.jpg", "interlock_switch.jpg", "Interlock Switch.jpg" };
                    foreach (var name in alternateNames)
                    {
                        var path = Path.Combine(imageDir, name);
                        if (File.Exists(path))
                        {
                            picInterlockSwitch.Image = Image.FromFile(path);
                            break;
                        }
                    }
                }

                // Load ready light image (shows the green light)
                string readyImagePath = Path.Combine(imageDir, "Interlock Green Light.jpg");
                if (File.Exists(readyImagePath))
                {
                    picReadyLight.Image = Image.FromFile(readyImagePath);
                }
                else
                {
                    // Try alternate names
                    string[] alternateNames = { "Ready_Light.jpg", "ready_light.jpg", "Ready Light.jpg" };
                    foreach (var name in alternateNames)
                    {
                        var path = Path.Combine(imageDir, name);
                        if (File.Exists(path))
                        {
                            picReadyLight.Image = Image.FromFile(path);
                            break;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                // If images fail to load, just show placeholder text
                System.Diagnostics.Debug.WriteLine($"Failed to load interlock images: {ex.Message}");
            }
        }

        private void Checkbox_CheckedChanged(object sender, EventArgs e)
        {
            // Enable proceed button only when all checkboxes are checked
            bool allChecked = chkInterlockOn.Checked && chkReadyLight.Checked && chkAreaClear.Checked;
            btnProceed.Enabled = allChecked;
            btnProceed.BackColor = allChecked ? Color.FromArgb(0, 150, 0) : Color.Gray;
        }

        private void BtnProceed_Click(object sender, EventArgs e)
        {
            this.DialogResult = DialogResult.OK;
            this.Close();
        }

        private void BtnCancel_Click(object sender, EventArgs e)
        {
            this.DialogResult = DialogResult.Cancel;
            this.Close();
        }

        /// <summary>
        /// Shows the interlock warning dialog and returns true if user confirms safety checks
        /// </summary>
        public static bool ShowWarning(IWin32Window owner)
        {
            using (var form = new InterlockWarningForm())
            {
                return form.ShowDialog(owner) == DialogResult.OK;
            }
        }
    }
}
