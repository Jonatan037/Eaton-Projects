using System;
using System.Collections.Generic;
using System.Configuration;
using System.Drawing;
using System.IO;
using System.Windows.Forms;
using HipotTestApp.Communication;
using HipotTestApp.Data;
using HipotTestApp.Models;

namespace HipotTestApp.Forms
{
    /// <summary>
    /// Safety Check form for FailCHEK validation
    /// Two-step process:
    /// 1. Ground Bond FailCHEK (fixture DISCONNECTED)
    /// 2. AC Hipot FailCHEK (fixture CONNECTED)
    /// Required once per shift per operator before running production tests
    /// </summary>
    public partial class SafetyCheckForm : Form
    {
        #region Private Fields

        private User _currentUser;
        private VisaGpibCommunicator _omnia;
        private DatabaseHelper _dbHelper;
        private bool _checkInProgress;
        private int _currentStep; // 0 = not started, 1 = Ground Bond, 2 = AC Hipot, 3 = Complete
        private bool _groundBondPassed;
        private bool _acHipotPassed;
        private string _imagePath;
        
        // Test results storage
        private decimal? _gndResistance;
        private decimal? _acwLeakage;
        private string _gndResistanceDisplay;  // Display value with > or < symbol
        private string _acwLeakageDisplay;     // Display value with > or < symbol

        // UI Controls
        private Label lblStepTitle;
        private Label lblStepInstructions;
        private Label lblShiftInfo;
        private PictureBox picInstruction;
        private Panel pnlGroundBondResult;
        private Panel pnlACHipotResult;
        private Label lblGndStatus;
        private Label lblGndResistance;
        private Label lblAcwStatus;
        private Label lblAcwLeakage;
        private Label lblOverallResult;
        private Button btnStartStep;
        private Button btnCancel;
        private RichTextBox txtLog;
        private ProgressBar progressCheck;
        
        // Testing overlay controls
        private Panel pnlTestingOverlay;
        private Label lblTestingStatus;
        private Label lblTestingAnimation;
        private System.Windows.Forms.Timer animationTimer;
        private int animationFrame;

        #endregion

        #region Properties

        /// <summary>
        /// Gets the completed safety check result
        /// </summary>
        public SafetyCheckResult CompletedCheck { get; private set; }
        
        /// <summary>
        /// Reference to parent form to hide/show
        /// </summary>
        public Form ParentMainForm { get; set; }

        #endregion

        #region Constructor

        public SafetyCheckForm(User currentUser, VisaGpibCommunicator omnia, DatabaseHelper dbHelper)
        {
            _currentUser = currentUser ?? throw new ArgumentNullException(nameof(currentUser));
            _omnia = omnia ?? throw new ArgumentNullException(nameof(omnia));
            _dbHelper = dbHelper ?? throw new ArgumentNullException(nameof(dbHelper));

            // Find the image path - check multiple locations
            _imagePath = FindImagePath();

            InitializeComponent();
            UpdateShiftInfo();
            SetupStep1(); // Start with Ground Bond step
            
            // Hide parent form when this form is shown
            this.Shown += SafetyCheckForm_Shown;
            this.FormClosed += SafetyCheckForm_FormClosed;
        }
        
        private void SafetyCheckForm_Shown(object sender, EventArgs e)
        {
            // Hide the parent/main form when safety check form is shown
            if (ParentMainForm != null)
            {
                ParentMainForm.Hide();
            }
        }
        
        private void SafetyCheckForm_FormClosed(object sender, FormClosedEventArgs e)
        {
            // Show the parent/main form when safety check form is closed
            if (ParentMainForm != null)
            {
                ParentMainForm.Show();
            }
        }

        private string FindImagePath()
        {
            // Try different possible locations for the instruction images
            string[] possiblePaths = new string[]
            {
                Path.Combine(Application.StartupPath, "Omnia FailCheck Instructions"),
                Path.Combine(Application.StartupPath, "Images"),
                Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "Omnia FailCheck Instructions"),
                @"C:\Hipot\net48\Omnia FailCheck Instructions"
            };

            foreach (string path in possiblePaths)
            {
                if (Directory.Exists(path))
                    return path;
            }

            return Application.StartupPath; // Default fallback
        }

        #endregion

        #region Initialization

        private void InitializeComponent()
        {
            this.SuspendLayout();

            // Form properties
            this.Text = "Safety Equipment Check (FailCHEK)";
            this.Size = new Size(850, 820);  // Increased height for more text space
            this.StartPosition = FormStartPosition.CenterParent;
            this.FormBorderStyle = FormBorderStyle.FixedDialog;
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.BackColor = Color.FromArgb(240, 240, 240);

            CreateHeaderPanel();
            CreateStepInstructionsPanel();
            CreateResultsPanel();
            CreateLogPanel();
            CreateButtonPanel();
            CreateTestingOverlay();

            this.ResumeLayout(false);
        }

        private void CreateHeaderPanel()
        {
            Panel headerPanel = new Panel
            {
                Dock = DockStyle.Top,
                Height = 70,
                BackColor = Color.FromArgb(180, 100, 0) // Orange for safety
            };

            Label lblTitle = new Label
            {
                Text = "⚠ SAFETY EQUIPMENT CHECK (FailCHEK)",
                Font = new Font("Segoe UI", 18, FontStyle.Bold),
                ForeColor = Color.White,
                Location = new Point(20, 10),
                AutoSize = true
            };
            headerPanel.Controls.Add(lblTitle);

            lblShiftInfo = new Label
            {
                Text = "Shift: Loading...",
                Font = new Font("Segoe UI", 10),
                ForeColor = Color.White,
                Location = new Point(20, 42),
                AutoSize = true
            };
            headerPanel.Controls.Add(lblShiftInfo);

            this.Controls.Add(headerPanel);
        }

        private void CreateStepInstructionsPanel()
        {
            GroupBox grpStep = new GroupBox
            {
                Text = "Current Step",
                Font = new Font("Segoe UI", 10, FontStyle.Bold),
                Location = new Point(20, 85),
                Size = new Size(795, 340)  // Increased height for more text space
            };

            // Instruction image - positioned to the right (add first so it's behind text)
            picInstruction = new PictureBox
            {
                Location = new Point(420, 25),
                Size = new Size(360, 300),  // Taller to match increased panel
                BackColor = Color.White,
                BorderStyle = BorderStyle.FixedSingle,
                SizeMode = PictureBoxSizeMode.Zoom
            };
            grpStep.Controls.Add(picInstruction);

            // Step title - ensure it's on top of image
            lblStepTitle = new Label
            {
                Text = "Step 1: Ground Bond FailCHEK",
                Font = new Font("Segoe UI", 14, FontStyle.Bold),
                ForeColor = Color.DarkBlue,
                Location = new Point(15, 25),
                Size = new Size(390, 30),
                BackColor = Color.Transparent
            };
            grpStep.Controls.Add(lblStepTitle);
            lblStepTitle.BringToFront();

            // Step instructions - more vertical space for longer text
            lblStepInstructions = new Label
            {
                Text = "Instructions will appear here...",
                Font = new Font("Segoe UI", 10),
                Location = new Point(15, 60),
                Size = new Size(390, 265),  // More height for all instruction text
                BackColor = Color.Transparent
            };
            grpStep.Controls.Add(lblStepInstructions);
            lblStepInstructions.BringToFront();

            this.Controls.Add(grpStep);
        }

        private void CreateResultsPanel()
        {
            GroupBox grpResults = new GroupBox
            {
                Text = "Test Results",
                Font = new Font("Segoe UI", 10, FontStyle.Bold),
                Location = new Point(20, 435),  // Moved down to accommodate taller Current Step panel
                Size = new Size(795, 130)
            };

            // Ground Bond Result Panel
            pnlGroundBondResult = new Panel
            {
                Location = new Point(15, 25),
                Size = new Size(250, 90),
                BackColor = Color.LightGray,
                BorderStyle = BorderStyle.FixedSingle
            };

            Label lblGndTitle = new Label
            {
                Text = "GROUND BOND",
                Font = new Font("Segoe UI", 10, FontStyle.Bold),
                Location = new Point(10, 5),
                AutoSize = true
            };
            pnlGroundBondResult.Controls.Add(lblGndTitle);

            lblGndStatus = new Label
            {
                Text = "Pending",
                Font = new Font("Segoe UI", 14, FontStyle.Bold),
                ForeColor = Color.Gray,
                Location = new Point(140, 5),
                Size = new Size(100, 25),
                TextAlign = ContentAlignment.MiddleRight
            };
            pnlGroundBondResult.Controls.Add(lblGndStatus);

            lblGndResistance = new Label
            {
                Text = "Resistance: --- mΩ",
                Font = new Font("Segoe UI", 9),
                Location = new Point(10, 40),
                AutoSize = true
            };
            pnlGroundBondResult.Controls.Add(lblGndResistance);

            Label lblGndNote = new Label
            {
                Text = "(Fixture Disconnected)",
                Font = new Font("Segoe UI", 8, FontStyle.Italic),
                ForeColor = Color.DarkGray,
                Location = new Point(10, 65),
                AutoSize = true
            };
            pnlGroundBondResult.Controls.Add(lblGndNote);

            grpResults.Controls.Add(pnlGroundBondResult);

            // AC Hipot Result Panel
            pnlACHipotResult = new Panel
            {
                Location = new Point(280, 25),
                Size = new Size(250, 90),
                BackColor = Color.LightGray,
                BorderStyle = BorderStyle.FixedSingle
            };

            Label lblAcwTitle = new Label
            {
                Text = "AC HIPOT",
                Font = new Font("Segoe UI", 10, FontStyle.Bold),
                Location = new Point(10, 5),
                AutoSize = true
            };
            pnlACHipotResult.Controls.Add(lblAcwTitle);

            lblAcwStatus = new Label
            {
                Text = "Pending",
                Font = new Font("Segoe UI", 14, FontStyle.Bold),
                ForeColor = Color.Gray,
                Location = new Point(140, 5),
                Size = new Size(100, 25),
                TextAlign = ContentAlignment.MiddleRight
            };
            pnlACHipotResult.Controls.Add(lblAcwStatus);

            lblAcwLeakage = new Label
            {
                Text = "Leakage: --- mA",
                Font = new Font("Segoe UI", 9),
                Location = new Point(10, 40),
                AutoSize = true
            };
            pnlACHipotResult.Controls.Add(lblAcwLeakage);

            Label lblAcwNote = new Label
            {
                Text = "(Fixture Connected)",
                Font = new Font("Segoe UI", 8, FontStyle.Italic),
                ForeColor = Color.DarkGray,
                Location = new Point(10, 65),
                AutoSize = true
            };
            pnlACHipotResult.Controls.Add(lblAcwNote);

            grpResults.Controls.Add(pnlACHipotResult);

            // Overall Result
            lblOverallResult = new Label
            {
                Text = "WAITING",
                Font = new Font("Segoe UI", 16, FontStyle.Bold),
                ForeColor = Color.Gray,
                Location = new Point(545, 25),
                Size = new Size(235, 90),
                TextAlign = ContentAlignment.MiddleCenter,
                BackColor = Color.White,
                BorderStyle = BorderStyle.FixedSingle
            };
            grpResults.Controls.Add(lblOverallResult);

            this.Controls.Add(grpResults);
        }

        private void CreateLogPanel()
        {
            GroupBox grpLog = new GroupBox
            {
                Text = "Activity Log",
                Font = new Font("Segoe UI", 10, FontStyle.Bold),
                Location = new Point(20, 575),  // Moved down to accommodate taller Current Step panel
                Size = new Size(795, 130)
            };

            txtLog = new RichTextBox
            {
                Location = new Point(10, 22),
                Size = new Size(775, 98),
                ReadOnly = true,
                Font = new Font("Consolas", 9),
                BackColor = Color.FromArgb(40, 40, 40),
                ForeColor = Color.LightGreen
            };
            grpLog.Controls.Add(txtLog);

            this.Controls.Add(grpLog);
        }

        private void CreateButtonPanel()
        {
            Panel buttonPanel = new Panel
            {
                Dock = DockStyle.Bottom,
                Height = 60,
                BackColor = Color.FromArgb(230, 230, 230)
            };

            progressCheck = new ProgressBar
            {
                Location = new Point(20, 15),
                Size = new Size(400, 20),
                Style = ProgressBarStyle.Marquee,
                Visible = false
            };
            buttonPanel.Controls.Add(progressCheck);

            btnStartStep = new Button
            {
                Text = "▶ Start Ground Bond Test",
                Font = new Font("Segoe UI", 11, FontStyle.Bold),
                Size = new Size(250, 40),
                Location = new Point(450, 10),
                BackColor = Color.FromArgb(0, 120, 215),
                ForeColor = Color.White,
                FlatStyle = FlatStyle.Flat,
                Cursor = Cursors.Hand
            };
            btnStartStep.FlatAppearance.BorderSize = 0;
            btnStartStep.Click += BtnStartStep_Click;
            buttonPanel.Controls.Add(btnStartStep);

            btnCancel = new Button
            {
                Text = "Cancel",
                Font = new Font("Segoe UI", 10),
                Size = new Size(100, 40),
                Location = new Point(710, 10),
                FlatStyle = FlatStyle.Flat,
                Cursor = Cursors.Hand
            };
            btnCancel.Click += BtnCancel_Click;
            buttonPanel.Controls.Add(btnCancel);

            this.Controls.Add(buttonPanel);
        }

        private void CreateTestingOverlay()
        {
            // Create semi-transparent overlay panel
            pnlTestingOverlay = new Panel
            {
                Size = new Size(this.ClientSize.Width, this.ClientSize.Height),
                Location = new Point(0, 0),
                BackColor = Color.FromArgb(220, 0, 0, 0), // Semi-transparent black (darker)
                Visible = false
            };

            // Large warning triangle at the top
            Label lblWarningIcon = new Label
            {
                Text = "⚠",
                Font = new Font("Segoe UI", 72, FontStyle.Bold),
                ForeColor = Color.FromArgb(255, 200, 0), // Bright yellow/orange
                TextAlign = ContentAlignment.MiddleCenter,
                Size = new Size(150, 120),
                Location = new Point((pnlTestingOverlay.Width - 150) / 2, 100),
                BackColor = Color.Transparent
            };
            pnlTestingOverlay.Controls.Add(lblWarningIcon);

            // Testing status label
            lblTestingStatus = new Label
            {
                Text = "TESTING IN PROGRESS...",
                Font = new Font("Segoe UI", 24, FontStyle.Bold),
                ForeColor = Color.White,
                TextAlign = ContentAlignment.MiddleCenter,
                Size = new Size(600, 80),
                Location = new Point((pnlTestingOverlay.Width - 600) / 2, lblWarningIcon.Bottom + 20),
                BackColor = Color.Transparent
            };
            pnlTestingOverlay.Controls.Add(lblTestingStatus);

            // Animation label (spinning indicator)
            lblTestingAnimation = new Label
            {
                Text = "◐",
                Font = new Font("Segoe UI", 60, FontStyle.Bold),
                ForeColor = Color.FromArgb(0, 200, 255), // Cyan/blue
                TextAlign = ContentAlignment.MiddleCenter,
                Size = new Size(120, 100),
                Location = new Point((pnlTestingOverlay.Width - 120) / 2, lblTestingStatus.Bottom + 10),
                BackColor = Color.Transparent
            };
            pnlTestingOverlay.Controls.Add(lblTestingAnimation);

            // Warning label
            Label lblWarning = new Label
            {
                Text = "⚠ DO NOT disconnect equipment during test ⚠",
                Font = new Font("Segoe UI", 14, FontStyle.Bold),
                ForeColor = Color.Yellow,
                TextAlign = ContentAlignment.MiddleCenter,
                Size = new Size(400, 30),
                Location = new Point((pnlTestingOverlay.Width - 400) / 2, lblTestingAnimation.Bottom + 20),
                BackColor = Color.Transparent
            };
            pnlTestingOverlay.Controls.Add(lblWarning);

            // Setup animation timer
            animationTimer = new System.Windows.Forms.Timer();
            animationTimer.Interval = 200;
            animationTimer.Tick += AnimationTimer_Tick;

            this.Controls.Add(pnlTestingOverlay);
            pnlTestingOverlay.BringToFront();
        }

        private void AnimationTimer_Tick(object sender, EventArgs e)
        {
            // Rotate through spinner characters
            string[] spinChars = { "◐", "◓", "◑", "◒" };
            animationFrame = (animationFrame + 1) % spinChars.Length;
            lblTestingAnimation.Text = spinChars[animationFrame];
        }

        private void ShowTestingOverlay(string message = "TESTING IN PROGRESS...")
        {
            if (this.InvokeRequired)
            {
                this.Invoke(new Action(() => ShowTestingOverlay(message)));
                return;
            }

            lblTestingStatus.Text = message;
            pnlTestingOverlay.Size = new Size(this.ClientSize.Width, this.ClientSize.Height);
            pnlTestingOverlay.Visible = true;
            pnlTestingOverlay.BringToFront();
            animationTimer.Start();
            Application.DoEvents();
        }

        private void HideTestingOverlay()
        {
            if (this.InvokeRequired)
            {
                this.Invoke(new Action(() => HideTestingOverlay()));
                return;
            }

            animationTimer.Stop();
            pnlTestingOverlay.Visible = false;
            Application.DoEvents();
        }

        private void UpdateTestingStatus(string status)
        {
            if (this.InvokeRequired)
            {
                this.Invoke(new Action(() => UpdateTestingStatus(status)));
                return;
            }

            lblTestingStatus.Text = status;
            Application.DoEvents();
        }

        private void UpdateShiftInfo()
        {
            int currentShift = SafetyCheckResult.GetCurrentShift();
            string shiftName;
            switch (currentShift)
            {
                case 1: shiftName = "1st Shift (6:00 AM - 2:00 PM)"; break;
                case 2: shiftName = "2nd Shift (2:00 PM - 10:00 PM)"; break;
                case 3: shiftName = "3rd Shift (10:00 PM - 6:00 AM)"; break;
                default: shiftName = "Unknown"; break;
            }

            lblShiftInfo.Text = $"Operator: {_currentUser.FullName} | {shiftName}";
            Log($"Safety check for {_currentUser.ENumber} - Shift {currentShift}");
        }

        #endregion

        #region Step Setup Methods

        private void SetupStep1()
        {
            _currentStep = 1;
            lblStepTitle.Text = "Step 1: Ground Bond FailCHEK";
            lblStepTitle.ForeColor = Color.DarkBlue;

            lblStepInstructions.Text = 
                "⚠ DISCONNECT the FailCHEK Fixture\n\n" +
                "Before running the Ground Bond test:\n\n" +
                "1. Ensure the FailCHEK fixture adapter\n" +
                "   is DISCONNECTED from the test leads\n\n" +
                "2. The test leads should be open\n" +
                "   (not connected to anything)\n\n" +
                "3. This verifies the tester can detect\n" +
                "   an open ground connection\n\n" +
                "Click 'Start Ground Bond Test' when ready.";

            // Load Ground Bond configuration image
            LoadStepImage("FailCheck Ground Bond Configuration.jpg");

            btnStartStep.Text = "▶ Start Ground Bond Test";
            btnStartStep.BackColor = Color.FromArgb(0, 120, 215);

            Log("Step 1: Ground Bond FailCHEK - DISCONNECT fixture");
        }

        private void SetupStep2()
        {
            _currentStep = 2;
            lblStepTitle.Text = "Step 2: AC Hipot FailCHEK";
            lblStepTitle.ForeColor = Color.DarkGreen;

            lblStepInstructions.Text = 
                "✓ Ground Bond PASSED!\n\n" +
                "⚠ CONNECT the FailCHEK Fixture\n\n" +
                "Before running the AC Hipot test:\n\n" +
                "1. Connect the FailCHEK fixture adapter\n" +
                "   to the test leads as shown\n\n" +
                "2. Ensure secure connection\n\n" +
                "3. This verifies the tester can detect\n" +
                "   proper high voltage operation\n\n" +
                "Click 'Start AC Hipot Test' when ready.";

            // Load AC Hipot configuration image
            LoadStepImage("FailCheck AC Hipot Configuration.jpg");

            btnStartStep.Text = "▶ Start AC Hipot Test";
            btnStartStep.BackColor = Color.FromArgb(0, 150, 0);

            Log("Step 2: AC Hipot FailCHEK - CONNECT fixture");
        }

        private void SetupComplete()
        {
            _currentStep = 3;
            
            if (_groundBondPassed && _acHipotPassed)
            {
                lblStepTitle.Text = "✓ All Tests PASSED!";
                lblStepTitle.ForeColor = Color.DarkGreen;

                lblStepInstructions.Text = 
                    "SAFETY CHECK COMPLETE!\n\n" +
                    "Both FailCHEK tests have passed:\n\n" +
                    "✓ Ground Bond: PASS\n" +
                    "✓ AC Hipot: PASS\n\n" +
                    "You are now authorized to run\n" +
                    "production tests for this shift.\n\n" +
                    "The result will be saved to the database.";

                lblOverallResult.Text = "PASS";
                lblOverallResult.ForeColor = Color.DarkGreen;
                lblOverallResult.BackColor = Color.LightGreen;

                btnStartStep.Text = "✓ Complete & Save";
                btnStartStep.BackColor = Color.Green;

                // Load fixture image
                LoadStepImage("Omnia FailCheck Fixture.jpg");

                Log("All FailCHEK tests PASSED!");
            }
            else
            {
                lblStepTitle.Text = "✗ Safety Check FAILED";
                lblStepTitle.ForeColor = Color.DarkRed;

                string failedTests = "";
                if (!_groundBondPassed) failedTests += "Ground Bond ";
                if (!_acHipotPassed) failedTests += "AC Hipot ";

                lblStepInstructions.Text = 
                    "SAFETY CHECK FAILED!\n\n" +
                    $"Failed test(s): {failedTests}\n\n" +
                    "Please check:\n" +
                    "1. FailCHEK fixture connections\n" +
                    "2. Test equipment calibration\n" +
                    "3. Contact supervisor if problem persists\n\n" +
                    "You cannot run production tests until\n" +
                    "the safety check passes.";

                lblOverallResult.Text = "FAIL";
                lblOverallResult.ForeColor = Color.White;
                lblOverallResult.BackColor = Color.Red;

                btnStartStep.Text = "Retry";
                btnStartStep.BackColor = Color.Orange;
            }
        }

        private void LoadStepImage(string imageName)
        {
            try
            {
                string imagePath = Path.Combine(_imagePath, imageName);
                if (File.Exists(imagePath))
                {
                    // Load image without locking the file
                    using (var stream = new FileStream(imagePath, FileMode.Open, FileAccess.Read))
                    {
                        // Dispose existing image first
                        picInstruction.Image?.Dispose();
                        
                        // Load the image
                        Image loadedImage = Image.FromStream(stream);
                        
                        // Rotate the image 90 degrees clockwise for better display
                        loadedImage.RotateFlip(RotateFlipType.Rotate90FlipNone);
                        
                        picInstruction.Image = loadedImage;
                    }
                }
                else
                {
                    // Create placeholder if image not found
                    picInstruction.Image?.Dispose();
                    picInstruction.Image = CreatePlaceholderImage(imageName);
                    Log($"Image not found: {imagePath}");
                }
            }
            catch (Exception ex)
            {
                Log($"Error loading image: {ex.Message}");
                picInstruction.Image = CreatePlaceholderImage(imageName);
            }
        }

        private Image CreatePlaceholderImage(string text)
        {
            Bitmap bmp = new Bitmap(400, 240);
            using (Graphics g = Graphics.FromImage(bmp))
            {
                g.Clear(Color.LightGray);
                g.DrawRectangle(Pens.Gray, 0, 0, 399, 239);
                
                using (Font font = new Font("Segoe UI", 12))
                using (StringFormat sf = new StringFormat { Alignment = StringAlignment.Center, LineAlignment = StringAlignment.Center })
                {
                    g.DrawString($"Image:\n{text}\n\nPlace images in:\n{_imagePath}", 
                        font, Brushes.DarkGray, new RectangleF(10, 10, 380, 220), sf);
                }
            }
            return bmp;
        }

        #endregion

        #region Event Handlers

        private void BtnStartStep_Click(object sender, EventArgs e)
        {
            if (_checkInProgress)
            {
                MessageBox.Show("A test is already in progress.", "Test In Progress",
                    MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            if (!_omnia.IsConnected)
            {
                MessageBox.Show("OMNIA is not connected. Please connect first from the main screen.",
                    "Not Connected", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            switch (_currentStep)
            {
                case 1:
                    // Show Interlock Safety Warning before first test
                    if (!InterlockWarningForm.ShowWarning(this))
                    {
                        Log("FailCHEK cancelled - Safety verification not completed");
                        return;
                    }
                    RunGroundBondTest();
                    break;
                case 2:
                    // Show Interlock Safety Warning before AC Hipot test
                    if (!InterlockWarningForm.ShowWarning(this))
                    {
                        Log("FailCHEK cancelled - Safety verification not completed");
                        return;
                    }
                    RunACHipotTest();
                    break;
                case 3:
                    if (_groundBondPassed && _acHipotPassed)
                    {
                        SaveAndClose();
                    }
                    else
                    {
                        // Retry - reset and start over
                        ResetTests();
                        SetupStep1();
                    }
                    break;
            }
        }

        private void BtnCancel_Click(object sender, EventArgs e)
        {
            if (_checkInProgress)
            {
                var result = MessageBox.Show("A test is in progress. Are you sure you want to cancel?",
                    "Confirm Cancel", MessageBoxButtons.YesNo, MessageBoxIcon.Question);

                if (result != DialogResult.Yes)
                    return;
            }

            this.DialogResult = DialogResult.Cancel;
            this.Close();
        }

        #endregion

        #region Test Execution

        private void RunGroundBondTest()
        {
            _checkInProgress = true;

            try
            {
                // Show the testing overlay
                ShowTestingOverlay("GROUND BOND FailCHEK\n\nTesting in progress...");
                Log("Starting Ground Bond FailCHEK test...");
                Log("Sending FC GND command to OMNIA...");

                // Use the combined method that runs test and waits for result
                // Pass a callback to update progress
                var testData = _omnia.RunFailCheckAndGetResult(
                    FailCheckType.GroundBond, 
                    12000,  // 12 second timeout
                    (status) => {
                        UpdateTestingStatus($"GROUND BOND FailCHEK\n\n{status}");
                        Log(status);
                    }
                );

                // Hide overlay before showing results
                HideTestingOverlay();

                if (testData != null && testData.Count > 0)
                {
                    // Log ALL responses for debugging
                    foreach (var kvp in testData)
                    {
                        Log($"  {kvp.Key}: {kvp.Value}");
                    }

                    // Check for interlock error first
                    if (testData.ContainsKey("INTERLOCK") && testData["INTERLOCK"] == "OPEN")
                    {
                        string errorMsg = testData.ContainsKey("ERROR") ? testData["ERROR"] : "Safety interlock is open";
                        Log($"INTERLOCK OPEN - {errorMsg}");
                        var retryResult = MessageBox.Show(
                            "INTERLOCK OPEN - Cannot run test!\\n\\n" +
                            "The safety interlock is triggered. Please check:\\n" +
                            "• Light curtain is not blocked\\n" +
                            "• Safety doors are closed\\n" +
                            "• All safety covers are in place\\n\\n" +
                            "Would you like to RETRY after fixing the issue?",
                            "Safety Interlock Open", MessageBoxButtons.RetryCancel, MessageBoxIcon.Warning);
                        
                        if (retryResult == DialogResult.Retry)
                        {
                            return; // Stay on current step to retry
                        }
                        else
                        {
                            // Cancel the whole check
                            BtnCancel_Click(this, EventArgs.Empty);
                            return;
                        }
                    }

                    // Parse Ground Bond result
                    string overall = testData.ContainsKey("OVERALL") ? testData["OVERALL"] : "UNKNOWN";
                    string failReason = testData.ContainsKey("FAIL_REASON") ? testData["FAIL_REASON"] : "";
                    
                    // Check result
                    _groundBondPassed = overall.Equals("PASS", StringComparison.OrdinalIgnoreCase);
                    
                    // Get display value (with > symbol) and numeric value
                    if (testData.ContainsKey("GND_RESISTANCE"))
                    {
                        _gndResistanceDisplay = testData["GND_RESISTANCE"];  // Keep > symbol
                    }
                    if (testData.ContainsKey("GND_RESISTANCE_VALUE"))
                    {
                        decimal.TryParse(testData["GND_RESISTANCE_VALUE"], out decimal resistance);
                        _gndResistance = resistance;
                    }

                    DisplayGroundBondResult(_groundBondPassed, _gndResistanceDisplay);

                    if (_groundBondPassed)
                    {
                        Log($"Ground Bond FailCHEK PASSED - High resistance detected (expected when disconnected)");
                        MessageBox.Show(
                            "Ground Bond FailCHEK PASSED!\n\n" +
                            "The tester correctly detected an open ground connection.\n\n" +
                            "Now CONNECT the FailCHEK fixture for the AC Hipot test.",
                            "Step 1 Complete", MessageBoxButtons.OK, MessageBoxIcon.Information);
                        SetupStep2();
                    }
                    else if (overall.Equals("UNKNOWN", StringComparison.OrdinalIgnoreCase))
                    {
                        // Unknown result - could not parse response
                        string rawResp = testData.ContainsKey("RAW_RESPONSE") ? testData["RAW_RESPONSE"] : "none";
                        Log($"Ground Bond FailCHEK - Could not determine result");
                        MessageBox.Show(
                            $"Ground Bond FailCHEK - UNKNOWN RESULT\n\n" +
                            $"Could not parse device response.\n\n" +
                            $"Raw response:\n{rawResp}\n\n" +
                            "Please check the OMNIA display and try again.",
                            "Unknown Result", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    }
                    else
                    {
                        // FAIL - this means the tester detected LOW resistance when it should be open
                        Log($"Ground Bond FailCHEK FAILED - {failReason}");
                        MessageBox.Show(
                            $"Ground Bond FailCHEK FAILED!\n\n" +
                            $"{(string.IsNullOrEmpty(failReason) ? "Low resistance detected when fixture should be disconnected." : failReason)}\n\n" +
                            "Make sure the FailCHEK fixture is DISCONNECTED.\n" +
                            "(The test leads should be OPEN, not connected to anything.)\n\n" +
                            "Try again when ready.",
                            "Test Failed", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    }
                }
                else
                {
                    throw new Exception("No response received from OMNIA");
                }
            }
            catch (Exception ex)
            {
                HideTestingOverlay();
                Log($"Error: {ex.Message}");
                MessageBox.Show($"Ground Bond test error:\n{ex.Message}",
                    "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                DisplayGroundBondResult(false, null);
            }
            finally
            {
                HideTestingOverlay();
                SetCheckingState(false, "");
                _checkInProgress = false;
            }
        }

        private void RunACHipotTest()
        {
            _checkInProgress = true;

            try
            {
                // Show the testing overlay
                ShowTestingOverlay("AC HIPOT FailCHEK\n\nTesting in progress...");
                Log("Starting AC Hipot FailCHEK test...");
                Log("Sending FC ACW command to OMNIA...");

                // Use the combined method that runs test and waits for result
                // AC Hipot test typically takes longer
                var testData = _omnia.RunFailCheckAndGetResult(
                    FailCheckType.ACHipot, 
                    15000,  // 15 second timeout
                    (status) => {
                        UpdateTestingStatus($"AC HIPOT FailCHEK\n\n{status}");
                        Log(status);
                    }
                );

                // Hide overlay before showing results
                HideTestingOverlay();

                if (testData != null && testData.Count > 0)
                {
                    // Log ALL responses for debugging
                    foreach (var kvp in testData)
                    {
                        Log($"  {kvp.Key}: {kvp.Value}");
                    }

                    // Check for interlock error first
                    if (testData.ContainsKey("INTERLOCK") && testData["INTERLOCK"] == "OPEN")
                    {
                        string errorMsg = testData.ContainsKey("ERROR") ? testData["ERROR"] : "Safety interlock is open";
                        Log($"INTERLOCK OPEN - {errorMsg}");
                        var retryResult = MessageBox.Show(
                            "INTERLOCK OPEN - Cannot run test!\\n\\n" +
                            "The safety interlock is triggered. Please check:\\n" +
                            "• Light curtain is not blocked\\n" +
                            "• Safety doors are closed\\n" +
                            "• All safety covers are in place\\n\\n" +
                            "Would you like to RETRY after fixing the issue?",
                            "Safety Interlock Open", MessageBoxButtons.RetryCancel, MessageBoxIcon.Warning);
                        
                        if (retryResult == DialogResult.Retry)
                        {
                            // Reset AC Hipot result and retry
                            _acHipotPassed = false;
                            _acwLeakage = null;
                            _acwLeakageDisplay = null;
                            DisplayACHipotResult(false, null);
                            lblAcwStatus.Text = "Pending";
                            lblAcwStatus.ForeColor = Color.Orange;
                            return; // Stay on Step 2 to retry
                        }
                        else
                        {
                            SetupComplete();
                            return;
                        }
                    }

                    // Parse AC Hipot result  
                    string overall = testData.ContainsKey("OVERALL") ? testData["OVERALL"] : "UNKNOWN";
                    string failReason = testData.ContainsKey("FAIL_REASON") ? testData["FAIL_REASON"] : "";

                    // Check result
                    _acHipotPassed = overall.Equals("PASS", StringComparison.OrdinalIgnoreCase);

                    // Get display value (with > symbol) and numeric value
                    if (testData.ContainsKey("ACW_LEAKAGE"))
                    {
                        _acwLeakageDisplay = testData["ACW_LEAKAGE"];  // Keep > symbol
                    }
                    if (testData.ContainsKey("ACW_LEAKAGE_VALUE"))
                    {
                        decimal.TryParse(testData["ACW_LEAKAGE_VALUE"], out decimal leakage);
                        _acwLeakage = leakage;
                    }

                    DisplayACHipotResult(_acHipotPassed, _acwLeakageDisplay);

                    if (_acHipotPassed)
                    {
                        Log($"AC Hipot FailCHEK PASSED - Breakdown detected (expected when fixture connected)");
                        MessageBox.Show(
                            "AC Hipot FailCHEK PASSED!\n\n" +
                            "The tester correctly detected a breakdown/short condition.\n\n" +
                            "Both safety checks completed successfully!",
                            "Step 2 Complete", MessageBoxButtons.OK, MessageBoxIcon.Information);
                        // Move to completion step
                        SetupComplete();
                    }
                    else if (overall.Equals("UNKNOWN", StringComparison.OrdinalIgnoreCase))
                    {
                        string rawResp = testData.ContainsKey("RAW_RESPONSE") ? testData["RAW_RESPONSE"] : "none";
                        Log($"AC Hipot FailCHEK - Could not determine result");
                        var dialogResult = MessageBox.Show(
                            $"AC Hipot FailCHEK - UNKNOWN RESULT\n\n" +
                            $"Could not parse device response.\n\n" +
                            $"Raw response:\n{rawResp}\n\n" +
                            "Would you like to RETRY the AC Hipot test?",
                            "Unknown Result", MessageBoxButtons.RetryCancel, MessageBoxIcon.Warning);
                        
                        if (dialogResult == DialogResult.Retry)
                        {
                            // Reset AC Hipot result and retry
                            _acHipotPassed = false;
                            _acwLeakage = null;
                            _acwLeakageDisplay = null;
                            DisplayACHipotResult(false, null);
                            lblAcwStatus.Text = "Pending";
                            lblAcwStatus.ForeColor = Color.Orange;
                            return; // Stay on Step 2 to retry
                        }
                        else
                        {
                            SetupComplete();
                        }
                    }
                    else
                    {
                        // FAIL - this means the tester did NOT detect a failure when it should have
                        Log($"AC Hipot FailCHEK FAILED - {failReason}");
                        var dialogResult = MessageBox.Show(
                            $"AC Hipot FailCHEK FAILED!\n\n" +
                            $"{(string.IsNullOrEmpty(failReason) ? "No breakdown detected when fixture should cause failure." : failReason)}\n\n" +
                            "Make sure the FailCHEK fixture is CONNECTED properly.\n" +
                            "(The fixture should create a short/breakdown condition.)\n\n" +
                            "Would you like to RETRY the AC Hipot test?",
                            "Test Failed", MessageBoxButtons.RetryCancel, MessageBoxIcon.Error);
                        
                        if (dialogResult == DialogResult.Retry)
                        {
                            // Reset AC Hipot result and retry
                            _acHipotPassed = false;
                            _acwLeakage = null;
                            _acwLeakageDisplay = null;
                            DisplayACHipotResult(false, null);
                            lblAcwStatus.Text = "Pending";
                            lblAcwStatus.ForeColor = Color.Orange;
                            return; // Stay on Step 2 to retry
                        }
                        else
                        {
                            SetupComplete();
                        }
                    }
                }
                else
                {
                    throw new Exception("No response received from OMNIA");
                }
            }
            catch (Exception ex)
            {
                HideTestingOverlay();
                Log($"Error: {ex.Message}");
                MessageBox.Show($"AC Hipot test error:\n{ex.Message}",
                    "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                DisplayACHipotResult(false, null);
                SetupComplete();
            }
            finally
            {
                HideTestingOverlay();
                SetCheckingState(false, "");
                _checkInProgress = false;
            }
        }

        private Dictionary<string, string> WaitForTestCompletion()
        {
            int maxWaitSeconds = 30;
            int pollInterval = 500;
            int elapsed = 0;

            while (elapsed < maxWaitSeconds * 1000)
            {
                Application.DoEvents();
                System.Threading.Thread.Sleep(pollInterval);
                elapsed += pollInterval;

                // Check system status
                string status = _omnia.GetSystemStatus();
                
                // Get test data regardless of status - OMNIA may have results
                var testData = _omnia.GetTestData();
                if (testData != null && testData.Count > 0)
                {
                    return testData;
                }

                // Also try GetFailCheckData
                var failCheckData = _omnia.GetFailCheckData();
                if (failCheckData != null && failCheckData.Count > 0)
                {
                    return failCheckData;
                }
            }

            // If we timeout, still try to get any available data
            return _omnia.GetTestData() ?? _omnia.GetFailCheckData();
        }

        private void ResetTests()
        {
            _groundBondPassed = false;
            _acHipotPassed = false;
            _gndResistance = null;
            _acwLeakage = null;
            _gndResistanceDisplay = null;
            _acwLeakageDisplay = null;

            pnlGroundBondResult.BackColor = Color.LightGray;
            lblGndStatus.Text = "Pending";
            lblGndStatus.ForeColor = Color.Gray;
            lblGndResistance.Text = "Resistance: --- mΩ";

            pnlACHipotResult.BackColor = Color.LightGray;
            lblAcwStatus.Text = "Pending";
            lblAcwStatus.ForeColor = Color.Gray;
            lblAcwLeakage.Text = "Leakage: --- mA";

            lblOverallResult.Text = "WAITING";
            lblOverallResult.ForeColor = Color.Gray;
            lblOverallResult.BackColor = Color.White;

            Log("Tests reset - starting over");
        }

        #endregion

        #region UI Updates

        private void SetCheckingState(bool checking, string message)
        {
            progressCheck.Visible = checking;
            btnStartStep.Enabled = !checking;
            btnCancel.Enabled = !checking;

            if (checking && !string.IsNullOrEmpty(message))
            {
                lblStepInstructions.Text = message + "\n\nPlease wait...";
            }
        }

        private void DisplayGroundBondResult(bool passed, string resistanceDisplay)
        {
            pnlGroundBondResult.BackColor = passed ? Color.LightGreen : Color.LightCoral;
            lblGndStatus.Text = passed ? "PASS" : "FAIL";
            lblGndStatus.ForeColor = passed ? Color.DarkGreen : Color.DarkRed;
            lblGndResistance.Text = $"Resistance: {(string.IsNullOrEmpty(resistanceDisplay) ? "---" : resistanceDisplay)} mΩ";
        }

        private void DisplayACHipotResult(bool passed, string leakageDisplay)
        {
            pnlACHipotResult.BackColor = passed ? Color.LightGreen : Color.LightCoral;
            lblAcwStatus.Text = passed ? "PASS" : "FAIL";
            lblAcwStatus.ForeColor = passed ? Color.DarkGreen : Color.DarkRed;
            lblAcwLeakage.Text = $"Leakage: {(string.IsNullOrEmpty(leakageDisplay) ? "---" : leakageDisplay)} mA";
        }

        private void Log(string message)
        {
            if (txtLog.InvokeRequired)
            {
                txtLog.Invoke(new Action(() => Log(message)));
                return;
            }

            string timestamp = DateTime.Now.ToString("HH:mm:ss");
            txtLog.SelectionStart = txtLog.TextLength;
            txtLog.SelectionColor = Color.Gray;
            txtLog.AppendText($"[{timestamp}] ");
            txtLog.SelectionStart = txtLog.TextLength;
            txtLog.SelectionColor = Color.LightGreen;
            txtLog.AppendText($"{message}\n");
            txtLog.ScrollToCaret();
        }

        #endregion

        #region Save and Close

        private void SaveAndClose()
        {
            try
            {
                // Build result object
                var result = new SafetyCheckResult
                {
                    CheckDateTime = DateTime.Now,
                    OperatorENumber = _currentUser.ENumber,
                    ShiftNumber = SafetyCheckResult.GetCurrentShift(),
                    EquipmentID = _omnia.DeviceIdentification ?? "OMNIA II 8204",
                    OverallResult = "PASS",
                    IsValidForShift = true,
                    ExpirationDateTime = GetShiftEndTime(),
                    CreatedDate = DateTime.Now,
                    CreatedBy = _currentUser.ENumber,
                    
                    // Ground Bond results
                    GroundBondCheck = new GroundBondCheckResult
                    {
                        Result = _groundBondPassed ? "PASS" : "FAIL",
                        Resistance_mOhm = _gndResistance
                    },
                    
                    // AC Hipot results (stored in ContinuityCheck for now - we may want to add ACHipotCheck later)
                    ContinuityCheck = new ContinuityCheckResult
                    {
                        Result = _acHipotPassed ? "PASS" : "FAIL",
                        Resistance_mOhm = _acwLeakage // Note: This is actually leakage in mA
                    }
                };

                if (_dbHelper.SaveSafetyCheckResult(result))
                {
                    Log($"Safety check saved (ID: {result.SafetyCheckID})");
                    CompletedCheck = result;

                    MessageBox.Show("Safety check PASSED and saved!\n\nYou are now authorized to run production tests for this shift.",
                        "Safety Check Complete", MessageBoxButtons.OK, MessageBoxIcon.Information);

                    this.DialogResult = DialogResult.OK;
                    this.Close();
                }
                else
                {
                    Log($"Failed to save: {_dbHelper.LastError}");
                    MessageBox.Show($"Safety check passed but failed to save to database.\n{_dbHelper.LastError}",
                        "Database Error", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                }
            }
            catch (Exception ex)
            {
                Log($"Save error: {ex.Message}");
                MessageBox.Show($"Error saving results:\n{ex.Message}",
                    "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private DateTime GetShiftEndTime()
        {
            int shift = SafetyCheckResult.GetCurrentShift();
            DateTime today = DateTime.Today;

            switch (shift)
            {
                case 1: return today.AddHours(14); // 2 PM
                case 2: return today.AddHours(22); // 10 PM
                case 3: return today.AddDays(1).AddHours(6); // 6 AM next day
                default: return today.AddHours(8); // Default 8 hours
            }
        }

        #endregion

        #region Cleanup

        protected override void OnFormClosing(FormClosingEventArgs e)
        {
            if (_checkInProgress)
            {
                e.Cancel = true;
                MessageBox.Show("Cannot close while a test is in progress.",
                    "Test In Progress", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            // Clean up images
            picInstruction.Image?.Dispose();

            base.OnFormClosing(e);
        }

        #endregion
    }
}
