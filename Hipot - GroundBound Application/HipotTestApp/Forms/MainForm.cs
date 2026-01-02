using System;
using System.Collections.Generic;
using System.Configuration;
using System.Drawing;
using System.Linq;
using System.Windows.Forms;
using HipotTestApp.Communication;
using HipotTestApp.Data;
using HipotTestApp.Models;

namespace HipotTestApp.Forms
{
    /// <summary>
    /// Main test interface for running Hipot tests on production units
    /// 2-Column Layout: Unit Info + Results (top), Activity Log + History (bottom)
    /// </summary>
    public partial class MainForm : Form
    {
        #region Private Fields

        private VisaGpibCommunicator _omnia;
        private DatabaseHelper _dbHelper;
        private TdmHelper _tdmHelper;
        private User _currentUser;
        private Timer _connectionStatusTimer;
        private bool _testInProgress;
        private SafetyCheckResult _currentSafetyCheck;

        // UI Controls - Unit Information
        private TextBox txtCabinetPartNumber;
        private TextBox txtCabinetSerialNumber;
        private TextBox txtBreakerPanelSerialNumber;
        private TextBox txtGSECPanelSerialNumber;
        
        // UI Controls - Buttons and Status
        private Button btnConnect;
        private Button btnStartTest;
        private Button btnSafetyCheck;
        private Button btnViewFullHistory;
        private Label lblConnectionStatus;
        private Label lblEquipmentID;
        private Label lblOperator;
        private Label lblSafetyStatus;
        
        // UI Controls - Results
        private Panel pnlGndResult;
        private Panel pnlAcwResult;
        private Label lblGndStatus;
        private Label lblGndResistance;
        private Label lblAcwStatus;
        private Label lblAcwLeakage;
        private Label lblOverallResult;
        private Label lblUnitSerialResult;  // Shows which unit was tested
        
        // UI Controls - Log and History
        private RichTextBox txtLog;
        private DataGridView dgvHistory;
        private ProgressBar progressTest;

        #endregion

        #region Constructor

        public MainForm(User currentUser)
        {
            _currentUser = currentUser ?? throw new ArgumentNullException(nameof(currentUser));
            _dbHelper = new DatabaseHelper();
            _tdmHelper = new TdmHelper();
            
            InitializeComponent();
            InitializeOmnia();
            CheckSafetyStatus();
            LoadRecentHistory();
            
            // Try to upload any pending TDM files from previous sessions
            int pendingUploaded = _tdmHelper.UploadPendingFiles();
            if (pendingUploaded > 0)
            {
                Log($"Uploaded {pendingUploaded} pending TDM file(s) from previous session", LogLevel.Info);
            }
        }

        #endregion

        #region Initialization

        private void InitializeComponent()
        {
            this.SuspendLayout();

            // Form properties
            this.Text = $"Hipot Test System - OMNIA II 8204 | {_currentUser.FullName}";
            this.Size = new Size(1200, 850);
            this.StartPosition = FormStartPosition.CenterScreen;
            this.BackColor = Color.FromArgb(240, 240, 240);
            this.MinimumSize = new Size(1100, 800);
            this.MaximizeBox = false;  // Disable maximize button

            // Create main layout - 2 columns
            CreateHeaderPanel();
            CreateTopRow();      // Unit Information + Test Results
            CreateBottomRow();   // Activity Log + Test History
            CreateStatusBar();

            this.ResumeLayout(false);
        }

        private void CreateHeaderPanel()
        {
            Panel headerPanel = new Panel
            {
                Dock = DockStyle.Top,
                Height = 80,
                BackColor = Color.FromArgb(0, 70, 127)
            };

            // Title
            Label lblTitle = new Label
            {
                Text = "HIPOT / GROUND BOND TEST SYSTEM",
                Font = new Font("Segoe UI", 20, FontStyle.Bold),
                ForeColor = Color.White,
                Location = new Point(20, 10),
                AutoSize = true
            };
            headerPanel.Controls.Add(lblTitle);

            // Subtitle
            Label lblSubtitle = new Label
            {
                Text = "Associated Research OMNIA II Model 8204",
                Font = new Font("Segoe UI", 10),
                ForeColor = Color.LightGray,
                Location = new Point(20, 50),
                AutoSize = true
            };
            headerPanel.Controls.Add(lblSubtitle);

            // Operator Info
            lblOperator = new Label
            {
                Text = $"Operator: {_currentUser.FullName} ({_currentUser.ENumber})",
                Font = new Font("Segoe UI", 10),
                ForeColor = Color.White,
                Location = new Point(700, 15),
                AutoSize = true
            };
            headerPanel.Controls.Add(lblOperator);

            // Safety Check Status
            lblSafetyStatus = new Label
            {
                Text = "Safety Check: Not Verified",
                Font = new Font("Segoe UI", 10, FontStyle.Bold),
                ForeColor = Color.Yellow,
                Location = new Point(700, 40),
                AutoSize = true
            };
            headerPanel.Controls.Add(lblSafetyStatus);

            // Logout Button
            Button btnLogout = new Button
            {
                Text = "Logout",
                Font = new Font("Segoe UI", 9),
                Size = new Size(80, 30),
                Location = new Point(1090, 25),
                FlatStyle = FlatStyle.Flat,
                BackColor = Color.FromArgb(180, 0, 0),
                ForeColor = Color.White,
                Cursor = Cursors.Hand
            };
            btnLogout.FlatAppearance.BorderSize = 0;
            btnLogout.Click += BtnLogout_Click;
            headerPanel.Controls.Add(btnLogout);

            this.Controls.Add(headerPanel);
        }

        private void CreateTopRow()
        {
            // Left column: Unit Information
            GroupBox grpInput = new GroupBox
            {
                Text = "Unit Information",
                Font = new Font("Segoe UI", 10, FontStyle.Bold),
                Location = new Point(20, 95),
                Size = new Size(560, 280)
            };

            int yPos = 30;
            int labelWidth = 170;
            int inputWidth = 340;
            int inputX = 200;  // Increased gap from labels

            // Cabinet Part Number (Required)
            Label lblCabinetPart = new Label
            {
                Text = "Cabinet Part Number *",
                Font = new Font("Segoe UI", 10),
                Location = new Point(15, yPos + 5),
                Size = new Size(labelWidth, 25)
            };
            grpInput.Controls.Add(lblCabinetPart);

            txtCabinetPartNumber = new TextBox
            {
                Font = new Font("Segoe UI", 11),
                Location = new Point(inputX, yPos),
                Size = new Size(inputWidth, 28),
                MaxLength = 50
            };
            txtCabinetPartNumber.TextChanged += InputField_TextChanged;
            grpInput.Controls.Add(txtCabinetPartNumber);

            yPos += 40;

            // Cabinet Serial Number (Required)
            Label lblCabinetSerial = new Label
            {
                Text = "Cabinet Serial Number *",
                Font = new Font("Segoe UI", 10),
                Location = new Point(15, yPos + 5),
                Size = new Size(labelWidth, 25)
            };
            grpInput.Controls.Add(lblCabinetSerial);

            txtCabinetSerialNumber = new TextBox
            {
                Font = new Font("Segoe UI", 11),
                Location = new Point(inputX, yPos),
                Size = new Size(inputWidth, 28),
                MaxLength = 50
            };
            txtCabinetSerialNumber.TextChanged += InputField_TextChanged;
            txtCabinetSerialNumber.KeyDown += TxtSerialNumber_KeyDown;
            grpInput.Controls.Add(txtCabinetSerialNumber);

            yPos += 40;

            // Breaker Panel Serial Number (Required)
            Label lblBreakerPanel = new Label
            {
                Text = "Breaker Panel S/N *",
                Font = new Font("Segoe UI", 10),
                Location = new Point(15, yPos + 5),
                Size = new Size(labelWidth, 25)
            };
            grpInput.Controls.Add(lblBreakerPanel);

            txtBreakerPanelSerialNumber = new TextBox
            {
                Font = new Font("Segoe UI", 11),
                Location = new Point(inputX, yPos),
                Size = new Size(inputWidth, 28),
                MaxLength = 50
            };
            txtBreakerPanelSerialNumber.TextChanged += InputField_TextChanged;
            grpInput.Controls.Add(txtBreakerPanelSerialNumber);

            yPos += 40;

            // GSEC Panel Serial Number (Required)
            Label lblGSECPanel = new Label
            {
                Text = "GSEC Panel S/N *",
                Font = new Font("Segoe UI", 10),
                Location = new Point(15, yPos + 5),
                Size = new Size(labelWidth, 25)
            };
            grpInput.Controls.Add(lblGSECPanel);

            txtGSECPanelSerialNumber = new TextBox
            {
                Font = new Font("Segoe UI", 11),
                Location = new Point(inputX, yPos),
                Size = new Size(inputWidth, 28),
                MaxLength = 50
            };
            txtGSECPanelSerialNumber.TextChanged += InputField_TextChanged;
            grpInput.Controls.Add(txtGSECPanelSerialNumber);

            yPos += 50;

            // Start Test Button
            btnStartTest = new Button
            {
                Text = "▶ START TEST",
                Font = new Font("Segoe UI", 14, FontStyle.Bold),
                Size = new Size(350, 50),
                Location = new Point(inputX, yPos),
                BackColor = Color.Gray,
                ForeColor = Color.White,
                FlatStyle = FlatStyle.Flat,
                Cursor = Cursors.Hand,
                Enabled = false
            };
            btnStartTest.FlatAppearance.BorderSize = 0;
            btnStartTest.Click += BtnStartTest_Click;
            grpInput.Controls.Add(btnStartTest);

            // Progress bar
            progressTest = new ProgressBar
            {
                Location = new Point(inputX, yPos + 55),
                Size = new Size(350, 10),
                Style = ProgressBarStyle.Marquee,
                Visible = false
            };
            grpInput.Controls.Add(progressTest);

            this.Controls.Add(grpInput);

            // Right column: Test Results
            CreateResultsPanel();
        }

        private void CreateResultsPanel()
        {
            GroupBox grpResults = new GroupBox
            {
                Text = "Test Results",
                Font = new Font("Segoe UI", 10, FontStyle.Bold),
                Location = new Point(600, 95),
                Size = new Size(575, 280)
            };

            // Ground Bond Result Panel
            pnlGndResult = new Panel
            {
                Location = new Point(15, 30),
                Size = new Size(260, 90),
                BackColor = Color.LightGray,
                BorderStyle = BorderStyle.FixedSingle
            };

            Label lblGndTitle = new Label
            {
                Text = "GROUND BOND (GND)",
                Font = new Font("Segoe UI", 10, FontStyle.Bold),
                Location = new Point(5, 5),
                AutoSize = true
            };
            pnlGndResult.Controls.Add(lblGndTitle);

            lblGndStatus = new Label
            {
                Text = "---",
                Font = new Font("Segoe UI", 16, FontStyle.Bold),
                Location = new Point(150, 5),
                Size = new Size(100, 30),
                TextAlign = ContentAlignment.MiddleRight
            };
            pnlGndResult.Controls.Add(lblGndStatus);

            lblGndResistance = new Label
            {
                Text = "Resistance: --- mΩ",
                Font = new Font("Segoe UI", 11),
                Location = new Point(5, 55),
                AutoSize = true
            };
            pnlGndResult.Controls.Add(lblGndResistance);

            grpResults.Controls.Add(pnlGndResult);

            // AC Withstand Result Panel
            pnlAcwResult = new Panel
            {
                Location = new Point(290, 30),
                Size = new Size(260, 90),
                BackColor = Color.LightGray,
                BorderStyle = BorderStyle.FixedSingle
            };

            Label lblAcwTitle = new Label
            {
                Text = "AC WITHSTAND (ACW)",
                Font = new Font("Segoe UI", 10, FontStyle.Bold),
                Location = new Point(5, 5),
                AutoSize = true
            };
            pnlAcwResult.Controls.Add(lblAcwTitle);

            lblAcwStatus = new Label
            {
                Text = "---",
                Font = new Font("Segoe UI", 16, FontStyle.Bold),
                Location = new Point(150, 5),
                Size = new Size(100, 30),
                TextAlign = ContentAlignment.MiddleRight
            };
            pnlAcwResult.Controls.Add(lblAcwStatus);

            lblAcwLeakage = new Label
            {
                Text = "Leakage: --- mA",
                Font = new Font("Segoe UI", 11),
                Location = new Point(5, 55),
                AutoSize = true
            };
            pnlAcwResult.Controls.Add(lblAcwLeakage);

            grpResults.Controls.Add(pnlAcwResult);

            // Unit Serial Number display (shows which unit was tested)
            lblUnitSerialResult = new Label
            {
                Text = "",
                Font = new Font("Segoe UI", 9, FontStyle.Italic),
                ForeColor = Color.DarkGray,
                Location = new Point(15, 125),
                Size = new Size(535, 20),
                TextAlign = ContentAlignment.MiddleCenter,
                BackColor = Color.Transparent
            };
            grpResults.Controls.Add(lblUnitSerialResult);

            // Overall Result
            lblOverallResult = new Label
            {
                Text = "WAITING",
                Font = new Font("Segoe UI", 28, FontStyle.Bold),
                ForeColor = Color.Gray,
                Location = new Point(15, 145),
                Size = new Size(535, 120),
                TextAlign = ContentAlignment.MiddleCenter,
                BackColor = Color.White,
                BorderStyle = BorderStyle.FixedSingle
            };
            grpResults.Controls.Add(lblOverallResult);

            this.Controls.Add(grpResults);
        }

        private void CreateBottomRow()
        {
            // Left: Activity Log
            GroupBox grpLog = new GroupBox
            {
                Text = "Activity Log",
                Font = new Font("Segoe UI", 10, FontStyle.Bold),
                Location = new Point(20, 385),
                Size = new Size(560, 360)
            };

            txtLog = new RichTextBox
            {
                Location = new Point(10, 25),
                Size = new Size(540, 325),
                ReadOnly = true,
                Font = new Font("Consolas", 10),
                BackColor = Color.FromArgb(30, 30, 30),
                ForeColor = Color.LightGreen
            };
            grpLog.Controls.Add(txtLog);

            this.Controls.Add(grpLog);

            // Right: Test History (last 10)
            GroupBox grpHistory = new GroupBox
            {
                Text = "Test History (Recent)",
                Font = new Font("Segoe UI", 10, FontStyle.Bold),
                Location = new Point(600, 385),
                Size = new Size(575, 360)
            };

            dgvHistory = new DataGridView
            {
                Location = new Point(10, 25),
                Size = new Size(555, 285),
                ReadOnly = true,
                AllowUserToAddRows = false,
                AllowUserToDeleteRows = false,
                SelectionMode = DataGridViewSelectionMode.FullRowSelect,
                AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill,
                RowHeadersVisible = false,
                Font = new Font("Segoe UI", 9),
                BackgroundColor = Color.White
            };
            
            // Add columns for test history
            dgvHistory.Columns.Add("DateTime", "Date/Time");
            dgvHistory.Columns.Add("CabinetSerial", "Cabinet S/N");
            dgvHistory.Columns.Add("Result", "Result");
            dgvHistory.Columns.Add("GND", "GND");
            dgvHistory.Columns.Add("ACW", "ACW");
            dgvHistory.Columns.Add("Operator", "Operator");
            
            // Set column widths
            dgvHistory.Columns["DateTime"].Width = 110;
            dgvHistory.Columns["CabinetSerial"].Width = 120;
            dgvHistory.Columns["Result"].Width = 60;
            dgvHistory.Columns["GND"].Width = 50;
            dgvHistory.Columns["ACW"].Width = 50;
            dgvHistory.Columns["Operator"].Width = 80;
            
            grpHistory.Controls.Add(dgvHistory);

            btnViewFullHistory = new Button
            {
                Text = "View Full History",
                Font = new Font("Segoe UI", 9),
                Size = new Size(140, 30),
                Location = new Point(10, 320),
                FlatStyle = FlatStyle.Flat,
                Cursor = Cursors.Hand,
                BackColor = Color.FromArgb(0, 120, 215),
                ForeColor = Color.White
            };
            btnViewFullHistory.FlatAppearance.BorderSize = 0;
            btnViewFullHistory.Click += BtnViewFullHistory_Click;
            grpHistory.Controls.Add(btnViewFullHistory);

            this.Controls.Add(grpHistory);
        }

        private void CreateStatusBar()
        {
            Panel statusPanel = new Panel
            {
                Dock = DockStyle.Bottom,
                Height = 50,
                BackColor = Color.FromArgb(50, 50, 50)
            };

            // Connection controls
            lblConnectionStatus = new Label
            {
                Text = "● Disconnected",
                Font = new Font("Segoe UI", 10),
                ForeColor = Color.Red,
                Location = new Point(20, 15),
                AutoSize = true
            };
            statusPanel.Controls.Add(lblConnectionStatus);

            lblEquipmentID = new Label
            {
                Text = "",
                Font = new Font("Segoe UI", 9),
                ForeColor = Color.LightGray,
                Location = new Point(150, 17),
                AutoSize = true
            };
            statusPanel.Controls.Add(lblEquipmentID);

            btnConnect = new Button
            {
                Text = "Connect",
                Font = new Font("Segoe UI", 9),
                Size = new Size(90, 30),
                Location = new Point(550, 10),
                FlatStyle = FlatStyle.Flat,
                BackColor = Color.FromArgb(0, 120, 215),
                ForeColor = Color.White,
                Cursor = Cursors.Hand
            };
            btnConnect.FlatAppearance.BorderSize = 0;
            btnConnect.Click += BtnConnect_Click;
            statusPanel.Controls.Add(btnConnect);

            btnSafetyCheck = new Button
            {
                Text = "Safety Check",
                Font = new Font("Segoe UI", 9),
                Size = new Size(110, 30),
                Location = new Point(650, 10),
                FlatStyle = FlatStyle.Flat,
                BackColor = Color.Orange,
                ForeColor = Color.White,
                Cursor = Cursors.Hand
            };
            btnSafetyCheck.FlatAppearance.BorderSize = 0;
            btnSafetyCheck.Click += BtnSafetyCheck_Click;
            statusPanel.Controls.Add(btnSafetyCheck);

            // Required fields note
            Label lblRequired = new Label
            {
                Text = "* Required fields",
                Font = new Font("Segoe UI", 9, FontStyle.Italic),
                ForeColor = Color.LightGray,
                Location = new Point(800, 17),
                AutoSize = true
            };
            statusPanel.Controls.Add(lblRequired);

            this.Controls.Add(statusPanel);

            // Setup connection status timer
            _connectionStatusTimer = new Timer { Interval = 5000 };
            _connectionStatusTimer.Tick += ConnectionStatusTimer_Tick;
        }

        private void InitializeOmnia()
        {
            // Use GPIB-based communicator for NI GPIB-USB-HS+ adapter
            _omnia = new VisaGpibCommunicator();
            
            Log("Application started", LogLevel.Info);
            Log($"GPIB address configured: {_omnia.GpibAddress}", LogLevel.Info);
        }

        private void CheckSafetyStatus()
        {
            if (_dbHelper.HasValidSafetyCheck(_currentUser.ENumber, out _currentSafetyCheck))
            {
                lblSafetyStatus.Text = $"✓ Safety Check: Valid (Shift {_currentSafetyCheck.ShiftNumber})";
                lblSafetyStatus.ForeColor = Color.LightGreen;
                btnSafetyCheck.BackColor = Color.Green;
                Log("Valid safety check found for current shift", LogLevel.Info);
            }
            else
            {
                lblSafetyStatus.Text = "⚠ Safety Check: Required";
                lblSafetyStatus.ForeColor = Color.Yellow;
                btnSafetyCheck.BackColor = Color.Orange;
                Log("Safety check required - no valid check for current shift", LogLevel.Warning);
            }
            UpdateStartButtonState();
        }

        #endregion

        #region Event Handlers

        private void InputField_TextChanged(object sender, EventArgs e)
        {
            UpdateStartButtonState();
        }

        private void TxtSerialNumber_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Enter && btnStartTest.Enabled)
            {
                BtnStartTest_Click(sender, e);
                e.SuppressKeyPress = true;
            }
        }

        private void BtnConnect_Click(object sender, EventArgs e)
        {
            if (_omnia.IsConnected)
            {
                _omnia.Disconnect();
                UpdateConnectionStatus(false, null);
                _connectionStatusTimer.Stop();
            }
            else
            {
                btnConnect.Enabled = false;
                btnConnect.Text = "Connecting...";
                
                Log("Attempting to connect to OMNIA...", LogLevel.Info);
                
                if (_omnia.Connect())
                {
                    UpdateConnectionStatus(true, _omnia.DeviceIdentification);
                    _connectionStatusTimer.Start();
                }
                else
                {
                    UpdateConnectionStatus(false, null);
                    Log($"Connection failed: {_omnia.LastError}", LogLevel.Error);
                    MessageBox.Show(
                        $"Failed to connect to OMNIA.\n\n{_omnia.LastError}\n\n" +
                        "Please check:\n" +
                        "• GPIB cable is connected\n" +
                        "• OMNIA is powered on\n" +
                        "• GPIB address matches configuration",
                        "Connection Failed", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
                
                btnConnect.Enabled = true;
                btnConnect.Text = _omnia.IsConnected ? "Disconnect" : "Connect";
            }
        }

        private void BtnStartTest_Click(object sender, EventArgs e)
        {
            if (_testInProgress)
            {
                MessageBox.Show("A test is already in progress.", "Test In Progress", 
                    MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            // All required fields validated by UpdateStartButtonState, but double-check
            if (!AreAllFieldsFilled())
            {
                MessageBox.Show("Please fill in all required fields.", "Validation Error",
                    MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            // Show Interlock Safety Warning dialog
            if (!InterlockWarningForm.ShowWarning(this))
            {
                Log("Test cancelled - Safety verification not completed", LogLevel.Warning);
                return;
            }

            // Check for interlock status before starting test
            if (_omnia != null && _omnia.IsConnected)
            {
                if (_omnia.IsInterlockOpen())
                {
                    string interlockStatus = _omnia.GetInterlockStatus();
                    MessageBox.Show(
                        "INTERLOCK OPEN - Cannot run test!\n\n" +
                        "The safety interlock is triggered. Please check:\n" +
                        "• Light curtain is not blocked\n" +
                        "• Safety doors are closed\n" +
                        "• All safety covers are in place\n\n" +
                        $"Status: {interlockStatus}",
                        "Safety Interlock Open", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }
            }

            // Check for existing passing test
            if (_dbHelper.HasPassingTest(txtCabinetSerialNumber.Text.Trim()))
            {
                var confirmResult = MessageBox.Show(
                    $"Cabinet serial number '{txtCabinetSerialNumber.Text.Trim()}' already has a PASSING test.\n\nDo you want to test again?",
                    "Existing Test Found", MessageBoxButtons.YesNo, MessageBoxIcon.Question);
                
                if (confirmResult != DialogResult.Yes)
                    return;
            }

            RunTest();
        }

        private void BtnSafetyCheck_Click(object sender, EventArgs e)
        {
            using (var safetyForm = new SafetyCheckForm(_currentUser, _omnia, _dbHelper))
            {
                // Pass this form reference so SafetyCheckForm can hide/show it
                safetyForm.ParentMainForm = this;
                
                if (safetyForm.ShowDialog() == DialogResult.OK)
                {
                    _currentSafetyCheck = safetyForm.CompletedCheck;
                    CheckSafetyStatus();
                }
            }
        }

        private void BtnViewFullHistory_Click(object sender, EventArgs e)
        {
            // Show a dialog with full history
            using (var historyForm = new Form())
            {
                historyForm.Text = "Full Test History";
                historyForm.Size = new Size(1000, 600);
                historyForm.StartPosition = FormStartPosition.CenterParent;
                historyForm.MaximizeBox = false;

                var fullHistoryGrid = new DataGridView
                {
                    Dock = DockStyle.Fill,
                    ReadOnly = true,
                    AllowUserToAddRows = false,
                    AllowUserToDeleteRows = false,
                    SelectionMode = DataGridViewSelectionMode.FullRowSelect,
                    AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill,
                    RowHeadersVisible = false,
                    Font = new Font("Segoe UI", 9),
                    BackgroundColor = Color.White
                };

                fullHistoryGrid.Columns.Add("DateTime", "Date/Time");
                fullHistoryGrid.Columns.Add("CabinetSerial", "Cabinet S/N");
                fullHistoryGrid.Columns.Add("CabinetPart", "Cabinet P/N");
                fullHistoryGrid.Columns.Add("BreakerSerial", "Breaker S/N");
                fullHistoryGrid.Columns.Add("GSECSerial", "GSEC S/N");
                fullHistoryGrid.Columns.Add("Result", "Result");
                fullHistoryGrid.Columns.Add("GND", "GND");
                fullHistoryGrid.Columns.Add("ACW", "ACW");
                fullHistoryGrid.Columns.Add("Operator", "Operator");

                // Load all history
                var allHistory = _dbHelper.GetAllTestHistory();
                foreach (var test in allHistory)
                {
                    int rowIndex = fullHistoryGrid.Rows.Add();
                    fullHistoryGrid.Rows[rowIndex].Cells["DateTime"].Value = test.TestDateTime.ToString("MM/dd/yyyy HH:mm:ss");
                    fullHistoryGrid.Rows[rowIndex].Cells["CabinetSerial"].Value = test.SerialNumber;
                    fullHistoryGrid.Rows[rowIndex].Cells["CabinetPart"].Value = test.PartNumber;
                    fullHistoryGrid.Rows[rowIndex].Cells["BreakerSerial"].Value = test.BreakerPanelSerialNumber;
                    fullHistoryGrid.Rows[rowIndex].Cells["GSECSerial"].Value = test.GSECPanelSerialNumber;
                    fullHistoryGrid.Rows[rowIndex].Cells["Result"].Value = test.OverallResult;
                    fullHistoryGrid.Rows[rowIndex].Cells["GND"].Value = test.GroundBondTest?.Result ?? "---";
                    fullHistoryGrid.Rows[rowIndex].Cells["ACW"].Value = test.ACWithstandTest?.Result ?? "---";
                    fullHistoryGrid.Rows[rowIndex].Cells["Operator"].Value = test.OperatorENumber;

                    // Color code results
                    if (test.OverallResult == "PASS")
                        fullHistoryGrid.Rows[rowIndex].DefaultCellStyle.BackColor = Color.LightGreen;
                    else if (test.OverallResult == "FAIL")
                        fullHistoryGrid.Rows[rowIndex].DefaultCellStyle.BackColor = Color.LightCoral;
                }

                historyForm.Controls.Add(fullHistoryGrid);
                historyForm.ShowDialog(this);
            }
        }

        private void BtnLogout_Click(object sender, EventArgs e)
        {
            if (_testInProgress)
            {
                MessageBox.Show("Cannot logout while a test is in progress.", 
                    "Test In Progress", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            var result = MessageBox.Show("Are you sure you want to logout?", 
                "Confirm Logout", MessageBoxButtons.YesNo, MessageBoxIcon.Question);
            
            if (result == DialogResult.Yes)
            {
                _omnia?.Disconnect();
                this.DialogResult = DialogResult.Retry;  // Retry tells Program.cs to show login form again
                this.Close();
            }
        }

        private void ConnectionStatusTimer_Tick(object sender, EventArgs e)
        {
            // Periodic check to verify OMNIA is still connected
            if (_omnia?.IsConnected == true && !_testInProgress)
            {
                try
                {
                    string status = _omnia.GetSystemStatus();
                    if (string.IsNullOrEmpty(status))
                    {
                        UpdateConnectionStatus(false, null);
                        _connectionStatusTimer.Stop();
                        Log("Connection lost to OMNIA", LogLevel.Error);
                    }
                }
                catch
                {
                    UpdateConnectionStatus(false, null);
                    _connectionStatusTimer.Stop();
                }
            }
        }

        #endregion

        #region Test Execution

        private void RunTest()
        {
            _testInProgress = true;
            string cabinetSerial = txtCabinetSerialNumber.Text.Trim();
            int retryCount = 0;
            const int maxRetries = 2;
            
            try
            {
                SetTestingState(true);
                
                // IMMEDIATELY show "TESTING" status
                lblOverallResult.Text = "TESTING";
                lblOverallResult.ForeColor = Color.White;
                lblOverallResult.BackColor = Color.FromArgb(0, 100, 180);  // Blue for testing
                lblUnitSerialResult.Text = $"Testing: {cabinetSerial}";
                lblUnitSerialResult.ForeColor = Color.Blue;
                Application.DoEvents();  // Force UI update
                
                ResetResultDisplay();  // This will set panels to gray but keep overall as TESTING
                // Restore TESTING status after reset
                lblOverallResult.Text = "TESTING";
                lblOverallResult.ForeColor = Color.White;
                lblOverallResult.BackColor = Color.FromArgb(0, 100, 180);
                
                Log($"Starting test for cabinet: {cabinetSerial}", LogLevel.Info);
                Log($"Starting test for cabinet: {cabinetSerial}", LogLevel.Info);

                // Check interlock before starting
                if (_omnia.IsInterlockOpen())
                {
                    string interlockStatus = _omnia.GetInterlockStatus();
                    throw new Exception($"INTERLOCK OPEN - Safety interlock is triggered.\nStatus: {interlockStatus}");
                }

                // Load the main Hipot test file from configuration
                int mainTestFile = 1; // Default to file 1
                string configValue = ConfigurationManager.AppSettings["MainHipotTestFile"];
                if (!string.IsNullOrEmpty(configValue) && int.TryParse(configValue, out int parsedFile))
                {
                    mainTestFile = parsedFile;
                }
                
                Log($"Loading test file {mainTestFile}...", LogLevel.Info);
                
                // Load the test file first
                if (!_omnia.LoadFile(mainTestFile))
                {
                    throw new Exception($"Failed to load test file {mainTestFile}: {_omnia.LastError}");
                }
                
                System.Threading.Thread.Sleep(500); // Wait for file to load
                
                // Query test parameters from the loaded file (for saving to database)
                Log("Querying test parameters...", LogLevel.Debug);
                var testParameters = _omnia.QueryAllStepParameters();
                
                // Log what we got from parameter queries for debugging
                if (testParameters != null && testParameters.Count > 0)
                {
                    foreach (var step in testParameters)
                    {
                        Log($"Step {step.Key} parameters: {string.Join(", ", step.Value.Select(kv => $"{kv.Key}={kv.Value}"))}", LogLevel.Debug);
                    }
                }
                else
                {
                    Log("No test parameters returned from OMNIA (this is normal for some firmware versions)", LogLevel.Info);
                }

                bool testSuccessful = false;
                HipotTestResult result = null;
                string lastError = null;

                while (!testSuccessful && retryCount <= maxRetries)
                {
                    if (retryCount > 0)
                    {
                        Log($"Retry attempt {retryCount} of {maxRetries}...", LogLevel.Warning);
                    }

                    // Start the test on the OMNIA
                    if (!_omnia.StartTest())
                    {
                        // Check if interlock caused the failure
                        if (_omnia.IsInterlockOpen())
                        {
                            var interlockResult = MessageBox.Show(
                                "INTERLOCK OPEN - Test aborted.\n\n" +
                                "Please check safety interlock and click Retry to try again.",
                                "Safety Interlock Open", MessageBoxButtons.RetryCancel, MessageBoxIcon.Warning);
                            
                            if (interlockResult == DialogResult.Retry)
                            {
                                retryCount++;
                                continue;
                            }
                            throw new Exception("Test cancelled by user.");
                        }
                        throw new Exception($"Failed to start test: {_omnia.LastError}");
                    }

                    Log("Test sequence initiated on OMNIA", LogLevel.Info);

                    // Wait for test to complete (poll for results)
                    System.Threading.Thread.Sleep(2000); // Initial delay

                    // Poll for test completion using the same approach as SafetyCheckForm
                    var testData = WaitForTestCompletionWithRetry();
                    if (testData == null)
                    {
                        throw new Exception("Failed to get test results from OMNIA");
                    }

                    // Build result object with test parameters included
                    result = BuildTestResult(cabinetSerial, testData, testParameters);
                    
                    // Check if test failed
                    if (result.OverallResult == "FAIL")
                    {
                        // Display current result
                        DisplayTestResult(result);
                        lastError = result.FailureReason ?? "Test failed";
                        
                        if (retryCount < maxRetries)
                        {
                            var retryResult = MessageBox.Show(
                                $"Test FAILED!\n\n" +
                                $"Reason: {lastError}\n\n" +
                                $"Would you like to retry? ({maxRetries - retryCount} retries remaining)",
                                "Test Failed - Retry?", MessageBoxButtons.YesNo, MessageBoxIcon.Warning);
                            
                            if (retryResult == DialogResult.Yes)
                            {
                                retryCount++;
                                ResetResultDisplay();
                                Log("Retrying test...", LogLevel.Warning);
                                continue;
                            }
                        }
                    }
                    
                    testSuccessful = true;
                }

                if (result != null)
                {
                    // Display final results
                    DisplayTestResult(result);

                    // Save to SQL database
                    if (_dbHelper.SaveHipotTestResult(result))
                    {
                        Log($"Test result saved to database (ID: {result.TestResultID})", LogLevel.Info);
                        LoadRecentHistory();
                    }
                    else
                    {
                        Log($"Failed to save result to database: {_dbHelper.LastError}", LogLevel.Error);
                        MessageBox.Show($"Warning: Test completed but failed to save to database.\n{_dbHelper.LastError}",
                            "Database Error", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    }
                    
                    // Upload to TDM
                    if (_tdmHelper.UploadHipotTestResult(result))
                    {
                        Log("Test result uploaded to TDM successfully", LogLevel.Info);
                    }
                    else
                    {
                        Log($"Failed to upload to TDM: {_tdmHelper.LastError}", LogLevel.Warning);
                        // Don't show message box for TDM failures - just log it
                        // The result is still saved to the local database
                    }

                    // Show final result message
                    if (result.OverallResult == "PASS")
                    {
                        MessageBox.Show(
                            $"Test PASSED!\n\n" +
                            $"Cabinet S/N: {cabinetSerial}\n" +
                            $"Ground Bond: {result.GroundBondTest?.Result ?? "---"}\n" +
                            $"AC Withstand: {result.ACWithstandTest?.Result ?? "---"}",
                            "Test Passed", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    }
                    else
                    {
                        MessageBox.Show(
                            $"Test FAILED!\n\n" +
                            $"Cabinet S/N: {cabinetSerial}\n" +
                            $"Reason: {result.FailureReason ?? "Unknown"}\n\n" +
                            "Result has been saved to database.",
                            "Test Failed", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    }

                    // Clear fields for next test
                    ClearInputFields();
                    txtCabinetPartNumber.Focus();
                }
            }
            catch (Exception ex)
            {
                Log($"Test error: {ex.Message}", LogLevel.Error);
                MessageBox.Show($"Test failed:\n{ex.Message}", "Test Error", 
                    MessageBoxButtons.OK, MessageBoxIcon.Error);
                
                DisplayTestFailure(ex.Message);
            }
            finally
            {
                SetTestingState(false);
                _testInProgress = false;
            }
        }

        private Dictionary<string, string> WaitForTestCompletionWithRetry()
        {
            int maxWaitMs = 120000; // Maximum 2 minutes for test
            int pollInterval = 500; // Poll every 500ms
            int elapsed = 0;

            // Give test time to start
            System.Threading.Thread.Sleep(1000);
            elapsed += 1000;

            while (elapsed < maxWaitMs)
            {
                Application.DoEvents();
                
                // Check if test is complete using *OPC?
                string opcResponse = _omnia.SendCommandWithResponse("*OPC?", 1000);
                
                if (opcResponse?.Trim() == "1")
                {
                    // Also check TD? to see if we have results
                    string tdCheck = _omnia.SendCommandWithResponse("TD?", 1000);
                    if (!string.IsNullOrEmpty(tdCheck) && tdCheck.Trim().Length > 2)
                    {
                        Log("Test complete!", LogLevel.Info);
                        
                        // Get the full test data - query EACH step individually
                        var testData = new Dictionary<string, string>();
                        
                        // TD? only returns the LAST step result, so we need to query each step
                        // RD n? returns results for step n
                        
                        // Query Step 1 (Ground Bond)
                        string rd1Response = _omnia.SendCommandWithResponse("RD 1?", 2000);
                        testData["RD1_RESPONSE"] = rd1Response ?? "";
                        Log($"RD 1? Response: {rd1Response}", LogLevel.Debug);
                        ParseStepResult(rd1Response, testData, 1);
                        
                        // Query Step 2 (AC Withstand)
                        string rd2Response = _omnia.SendCommandWithResponse("RD 2?", 2000);
                        testData["RD2_RESPONSE"] = rd2Response ?? "";
                        Log($"RD 2? Response: {rd2Response}", LogLevel.Debug);
                        ParseStepResult(rd2Response, testData, 2);
                        
                        // Also store TD response for reference
                        testData["TD_RESPONSE"] = tdCheck;
                        
                        // Determine overall result
                        DetermineOverallResult(testData);
                        
                        return testData;
                    }
                }
                
                System.Threading.Thread.Sleep(pollInterval);
                elapsed += pollInterval;
                
                // Update progress every second
                if (elapsed % 1000 == 0)
                {
                    Log($"Testing... ({elapsed/1000}s)", LogLevel.Info);
                }
            }

            return null;
        }

        private void ParseStepResult(string response, Dictionary<string, string> testData, int stepNumber)
        {
            if (string.IsNullOrEmpty(response)) return;
            
            // RD n? response format: step, test, status, meter1, meter2, meter3
            // Example GND: 01,GND,PASS,25.01,2,1.0 (current, resistance, time)
            // Example GND FAIL: 01,GND,HI-LIMIT,25.01,>200,1.0
            // Example ACW: 02,ACW,PASS,1960,0.5,60.0 (voltage, leakage, time)
            // Example ACW FAIL: 02,ACW,SHORT,0,50.00,0.2
            
            string[] parts = response.Split(',');
            if (parts.Length >= 3)
            {
                string testType = parts[1].Trim().ToUpper();
                string status = parts[2].Trim().ToUpper();
                
                Log($"Parsing Step {stepNumber}: Type={testType}, Status={status}", LogLevel.Debug);
                
                if (testType == "GND")
                {
                    // PASS means ground bond passed, anything else (HI-LIMIT, LO-LIMIT, etc.) is a fail
                    testData["GND_RESULT"] = status == "PASS" ? "PASS" : "FAIL";
                    testData["GND_RAW_STATUS"] = status;
                    
                    if (parts.Length >= 5)
                    {
                        testData["GND_CURRENT"] = parts[3].Trim();
                        // Keep the raw value with > or < for display
                        string resistanceRaw = parts[4].Trim();
                        testData["GND_RESISTANCE_DISPLAY"] = resistanceRaw;
                        // Strip > or < for numeric parsing
                        testData["GND_RESISTANCE"] = resistanceRaw.Replace(">", "").Replace("<", "");
                    }
                    if (parts.Length >= 6)
                    {
                        testData["GND_TIME"] = parts[5].Trim();
                    }
                }
                else if (testType == "ACW")
                {
                    // PASS means AC withstand passed
                    // SHORT, ARC, HI-LIMIT, LO-LIMIT all indicate failures
                    testData["ACW_RESULT"] = status == "PASS" ? "PASS" : "FAIL";
                    testData["ACW_RAW_STATUS"] = status;
                    
                    if (parts.Length >= 5)
                    {
                        testData["ACW_VOLTAGE"] = parts[3].Trim();
                        // Keep raw value with > or < for display
                        string leakageRaw = parts[4].Trim();
                        testData["ACW_LEAKAGE_DISPLAY"] = leakageRaw;
                        // Strip > or < for numeric parsing
                        testData["ACW_LEAKAGE"] = leakageRaw.Replace(">", "").Replace("<", "");
                    }
                    if (parts.Length >= 6)
                    {
                        testData["ACW_TIME"] = parts[5].Trim();
                    }
                }
            }
        }

        private void DetermineOverallResult(Dictionary<string, string> testData)
        {
            string gndResult = testData.ContainsKey("GND_RESULT") ? testData["GND_RESULT"] : null;
            string acwResult = testData.ContainsKey("ACW_RESULT") ? testData["ACW_RESULT"] : null;
            
            // Both tests must pass for overall pass
            if (gndResult == "PASS" && acwResult == "PASS")
            {
                testData["OVERALL"] = "PASS";
            }
            else
            {
                testData["OVERALL"] = "FAIL";
                
                // Build failure reason
                var failReasons = new List<string>();
                if (gndResult != "PASS" && gndResult != null)
                {
                    string gndRawStatus = testData.ContainsKey("GND_RAW_STATUS") ? testData["GND_RAW_STATUS"] : "FAIL";
                    failReasons.Add($"Ground Bond {gndRawStatus}");
                }
                if (acwResult != "PASS" && acwResult != null)
                {
                    string acwRawStatus = testData.ContainsKey("ACW_RAW_STATUS") ? testData["ACW_RAW_STATUS"] : "FAIL";
                    failReasons.Add($"AC Withstand {acwRawStatus}");
                }
                
                testData["FAIL_REASON"] = string.Join(", ", failReasons);
            }
            
            Log($"Overall result: {testData["OVERALL"]} (GND={gndResult}, ACW={acwResult})", LogLevel.Info);
        }

        private HipotTestResult BuildTestResult(string cabinetSerial, Dictionary<string, string> testData, 
            Dictionary<int, Dictionary<string, string>> testParameters = null)
        {
            var result = new HipotTestResult
            {
                SerialNumber = cabinetSerial,
                PartNumber = txtCabinetPartNumber.Text.Trim(),
                BreakerPanelSerialNumber = txtBreakerPanelSerialNumber.Text.Trim(),
                GSECPanelSerialNumber = txtGSECPanelSerialNumber.Text.Trim(),
                TestDateTime = DateTime.Now,
                OperatorENumber = _currentUser.ENumber,
                EquipmentID = lblEquipmentID.Text,
                OverallResult = testData.ContainsKey("OVERALL") ? testData["OVERALL"] : "UNKNOWN",
                FailureReason = testData.ContainsKey("FAIL_REASON") ? testData["FAIL_REASON"] : null,
                CreatedDate = DateTime.Now,
                CreatedBy = _currentUser.ENumber,
                RawResponse = string.Join("; ", testData)
            };

            // Parse Ground Bond results
            result.GroundBondTest = new GroundBondResult
            {
                Result = testData.ContainsKey("GND_RESULT") ? testData["GND_RESULT"] : null,
                RawStatus = testData.ContainsKey("GND_RAW_STATUS") ? testData["GND_RAW_STATUS"] : null,
                ResistanceDisplay = testData.ContainsKey("GND_RESISTANCE_DISPLAY") ? testData["GND_RESISTANCE_DISPLAY"] : null,
                Resistance_mOhm = ParseDecimal(testData, "GND_RESISTANCE"),
                Current_A = ParseDecimal(testData, "GND_CURRENT")
            };
            
            // Add Ground Bond test parameters if available
            if (testParameters != null && testParameters.ContainsKey(1))
            {
                var gndParams = testParameters[1];
                result.GroundBondTest.HiLimit_mOhm = ParseDecimalFromDict(gndParams, "GND_HI_LIMIT_MOHM");
                result.GroundBondTest.LoLimit_mOhm = ParseDecimalFromDict(gndParams, "GND_LO_LIMIT_MOHM");
                result.GroundBondTest.DwellTime_s = ParseDecimalFromDict(gndParams, "GND_DWELL_S");
                
                // Parse frequency if available
                if (gndParams.ContainsKey("GND_FREQUENCY_HZ"))
                {
                    if (int.TryParse(gndParams["GND_FREQUENCY_HZ"], out int freq))
                        result.GroundBondTest.Frequency_Hz = freq;
                }
                
                // If current wasn't in test results, try from parameters
                if (result.GroundBondTest.Current_A == null)
                    result.GroundBondTest.Current_A = ParseDecimalFromDict(gndParams, "GND_CURRENT_A");
            }

            // Parse AC Withstand results
            result.ACWithstandTest = new ACWithstandResult
            {
                Result = testData.ContainsKey("ACW_RESULT") ? testData["ACW_RESULT"] : null,
                RawStatus = testData.ContainsKey("ACW_RAW_STATUS") ? testData["ACW_RAW_STATUS"] : null,
                LeakageDisplay = testData.ContainsKey("ACW_LEAKAGE_DISPLAY") ? testData["ACW_LEAKAGE_DISPLAY"] : null,
                Voltage_V = ParseDecimal(testData, "ACW_VOLTAGE"),
                LeakageCurrent_mA = ParseDecimal(testData, "ACW_LEAKAGE")
            };
            
            // Add AC Withstand test parameters if available
            if (testParameters != null && testParameters.ContainsKey(2))
            {
                var acwParams = testParameters[2];
                result.ACWithstandTest.HiLimit_mA = ParseDecimalFromDict(acwParams, "ACW_HI_LIMIT_MA");
                result.ACWithstandTest.LoLimit_mA = ParseDecimalFromDict(acwParams, "ACW_LO_LIMIT_MA");
                result.ACWithstandTest.RampUp_s = ParseDecimalFromDict(acwParams, "ACW_RAMP_UP_S");
                result.ACWithstandTest.DwellTime_s = ParseDecimalFromDict(acwParams, "ACW_DWELL_S");
                result.ACWithstandTest.RampDown_s = ParseDecimalFromDict(acwParams, "ACW_RAMP_DOWN_S");
                
                // Parse frequency if available
                if (acwParams.ContainsKey("ACW_FREQUENCY_HZ"))
                {
                    if (int.TryParse(acwParams["ACW_FREQUENCY_HZ"], out int freq))
                        result.ACWithstandTest.Frequency_Hz = freq;
                }
                
                // Parse arc sense if available
                if (acwParams.ContainsKey("ACW_ARC_SENSE"))
                {
                    if (int.TryParse(acwParams["ACW_ARC_SENSE"], out int arcSense))
                        result.ACWithstandTest.ArcSense = arcSense;
                }
                
                // If voltage wasn't in test results, try from parameters
                if (result.ACWithstandTest.Voltage_V == null)
                    result.ACWithstandTest.Voltage_V = ParseDecimalFromDict(acwParams, "ACW_VOLTAGE_V");
            }

            // Set failure step if applicable
            if (result.OverallResult == "FAIL")
            {
                if (result.GroundBondTest?.Result != "PASS")
                    result.FailureStep = 1;
                else if (result.ACWithstandTest?.Result != "PASS")
                    result.FailureStep = 2;
            }

            return result;
        }

        private decimal? ParseDecimal(Dictionary<string, string> data, string key)
        {
            if (data.ContainsKey(key))
            {
                string value = data[key].Replace(">", "").Replace("<", "");
                if (decimal.TryParse(value, out decimal result))
                    return result;
            }
            return null;
        }
        
        private decimal? ParseDecimalFromDict(Dictionary<string, string> data, string key)
        {
            if (data != null && data.ContainsKey(key))
            {
                string value = data[key].Replace(">", "").Replace("<", "");
                if (decimal.TryParse(value, out decimal result))
                    return result;
            }
            return null;
        }

        #endregion

        #region UI Updates

        private bool AreAllFieldsFilled()
        {
            return !string.IsNullOrWhiteSpace(txtCabinetPartNumber.Text) &&
                   !string.IsNullOrWhiteSpace(txtCabinetSerialNumber.Text) &&
                   !string.IsNullOrWhiteSpace(txtBreakerPanelSerialNumber.Text) &&
                   !string.IsNullOrWhiteSpace(txtGSECPanelSerialNumber.Text);
        }

        private void UpdateConnectionStatus(bool connected, string identity)
        {
            if (connected)
            {
                lblConnectionStatus.Text = "● Connected";
                lblConnectionStatus.ForeColor = Color.LightGreen;
                lblEquipmentID.Text = identity ?? "OMNIA II";
                btnConnect.Text = "Disconnect";
                btnConnect.BackColor = Color.FromArgb(180, 0, 0);
                Log($"Connected to OMNIA: {identity}", LogLevel.Info);
            }
            else
            {
                lblConnectionStatus.Text = "● Disconnected";
                lblConnectionStatus.ForeColor = Color.Red;
                lblEquipmentID.Text = "";
                btnConnect.Text = "Connect";
                btnConnect.BackColor = Color.FromArgb(0, 120, 215);
                Log("Disconnected from OMNIA", LogLevel.Info);
            }
            UpdateStartButtonState();
        }

        private void UpdateStartButtonState()
        {
            bool allFieldsFilled = AreAllFieldsFilled();
            bool isConnected = _omnia != null && _omnia.IsConnected;
            bool hasSafetyCheck = _currentSafetyCheck != null && _currentSafetyCheck.IsStillValid();
            
            bool canTest = allFieldsFilled && isConnected && hasSafetyCheck;
            
            btnStartTest.Enabled = canTest;
            
            if (!isConnected)
            {
                btnStartTest.Text = "⚠ CONNECT OMNIA FIRST";
                btnStartTest.BackColor = Color.Gray;
            }
            else if (!hasSafetyCheck)
            {
                btnStartTest.Text = "⚠ SAFETY CHECK REQUIRED";
                btnStartTest.BackColor = Color.Orange;
            }
            else if (!allFieldsFilled)
            {
                btnStartTest.Text = "⚠ FILL ALL FIELDS";
                btnStartTest.BackColor = Color.Gray;
            }
            else
            {
                btnStartTest.Text = "▶ START TEST";
                btnStartTest.BackColor = Color.FromArgb(0, 150, 0);
            }
        }

        private void SetTestingState(bool testing)
        {
            progressTest.Visible = testing;
            btnStartTest.Enabled = !testing;
            btnConnect.Enabled = !testing;
            btnSafetyCheck.Enabled = !testing;
            txtCabinetPartNumber.Enabled = !testing;
            txtCabinetSerialNumber.Enabled = !testing;
            txtBreakerPanelSerialNumber.Enabled = !testing;
            txtGSECPanelSerialNumber.Enabled = !testing;
        }

        private void ClearInputFields()
        {
            txtCabinetPartNumber.Text = "";
            txtCabinetSerialNumber.Text = "";
            txtBreakerPanelSerialNumber.Text = "";
            txtGSECPanelSerialNumber.Text = "";
        }

        private void ResetResultDisplay()
        {
            pnlGndResult.BackColor = Color.LightGray;
            pnlAcwResult.BackColor = Color.LightGray;
            lblGndStatus.Text = "Testing...";
            lblGndStatus.ForeColor = Color.Black;
            lblGndResistance.Text = "Resistance: --- mΩ";
            lblAcwStatus.Text = "Testing...";
            lblAcwStatus.ForeColor = Color.Black;
            lblAcwLeakage.Text = "Leakage: --- mA";
            lblOverallResult.Text = "TESTING";
            lblOverallResult.ForeColor = Color.Blue;
            lblOverallResult.BackColor = Color.LightBlue;
            // Note: Don't clear lblUnitSerialResult here - it gets set when test starts
        }

        private void DisplayTestResult(HipotTestResult result)
        {
            // Show the unit serial number that was tested
            lblUnitSerialResult.Text = $"Cabinet S/N: {result.SerialNumber}";
            lblUnitSerialResult.ForeColor = Color.FromArgb(50, 50, 50);
            
            // Ground Bond
            if (result.GroundBondTest != null)
            {
                bool gndPass = result.GroundBondTest.Result?.ToUpper() == "PASS";
                pnlGndResult.BackColor = gndPass ? Color.LightGreen : Color.LightCoral;
                
                // Show raw status (like PASS, HI-LIMIT, etc.) for more detail
                string gndDisplayStatus = result.GroundBondTest.RawStatus ?? result.GroundBondTest.Result ?? "---";
                lblGndStatus.Text = gndDisplayStatus;
                lblGndStatus.ForeColor = gndPass ? Color.DarkGreen : Color.DarkRed;
                
                // Use display value (with > symbol) if available, otherwise format the numeric value
                string resistanceText = result.GroundBondTest.ResistanceDisplay ?? 
                                       result.GroundBondTest.Resistance_mOhm?.ToString("F2") ?? "---";
                lblGndResistance.Text = $"Resistance: {resistanceText} mΩ";
            }

            // AC Withstand
            if (result.ACWithstandTest != null)
            {
                bool acwPass = result.ACWithstandTest.Result?.ToUpper() == "PASS";
                pnlAcwResult.BackColor = acwPass ? Color.LightGreen : Color.LightCoral;
                
                // Show raw status (like PASS, SHORT, ARC, etc.) for more detail
                string acwDisplayStatus = result.ACWithstandTest.RawStatus ?? result.ACWithstandTest.Result ?? "---";
                lblAcwStatus.Text = acwDisplayStatus;
                lblAcwStatus.ForeColor = acwPass ? Color.DarkGreen : Color.DarkRed;
                
                // Use display value (with > symbol) if available, otherwise format the numeric value
                string leakageText = result.ACWithstandTest.LeakageDisplay ?? 
                                    result.ACWithstandTest.LeakageCurrent_mA?.ToString("F3") ?? "---";
                lblAcwLeakage.Text = $"Leakage: {leakageText} mA";
            }

            // Overall
            bool overallPass = result.OverallResult?.ToUpper() == "PASS";
            lblOverallResult.Text = result.OverallResult ?? "UNKNOWN";
            lblOverallResult.ForeColor = overallPass ? Color.DarkGreen : Color.White;
            lblOverallResult.BackColor = overallPass ? Color.LightGreen : Color.Red;

            Log($"Test complete: {result.OverallResult}", overallPass ? LogLevel.Info : LogLevel.Error);
        }

        private void DisplayTestFailure(string reason)
        {
            pnlGndResult.BackColor = Color.LightGray;
            pnlAcwResult.BackColor = Color.LightGray;
            lblGndStatus.Text = "ERROR";
            lblAcwStatus.Text = "ERROR";
            lblOverallResult.Text = "ERROR";
            lblOverallResult.ForeColor = Color.White;
            lblOverallResult.BackColor = Color.Red;
        }

        private void LoadRecentHistory()
        {
            dgvHistory.Rows.Clear();
            var history = _dbHelper.GetRecentTestHistory(10);
            
            foreach (var test in history)
            {
                int rowIndex = dgvHistory.Rows.Add();
                dgvHistory.Rows[rowIndex].Cells["DateTime"].Value = test.TestDateTime.ToString("MM/dd HH:mm");
                dgvHistory.Rows[rowIndex].Cells["CabinetSerial"].Value = test.SerialNumber;
                dgvHistory.Rows[rowIndex].Cells["Result"].Value = test.OverallResult;
                dgvHistory.Rows[rowIndex].Cells["GND"].Value = test.GroundBondTest?.Result ?? "---";
                dgvHistory.Rows[rowIndex].Cells["ACW"].Value = test.ACWithstandTest?.Result ?? "---";
                dgvHistory.Rows[rowIndex].Cells["Operator"].Value = test.OperatorENumber;

                // Color code results
                if (test.OverallResult == "PASS")
                    dgvHistory.Rows[rowIndex].DefaultCellStyle.BackColor = Color.LightGreen;
                else if (test.OverallResult == "FAIL")
                    dgvHistory.Rows[rowIndex].DefaultCellStyle.BackColor = Color.LightCoral;
            }
        }

        #endregion

        #region Logging

        private enum LogLevel { Debug, Info, Warning, Error }

        private void Log(string message, LogLevel level)
        {
            if (txtLog.InvokeRequired)
            {
                txtLog.Invoke(new Action(() => Log(message, level)));
                return;
            }

            // Skip debug messages in normal operation (uncomment next line to hide debug logs)
            // if (level == LogLevel.Debug) return;

            Color color;
            switch (level)
            {
                case LogLevel.Debug:
                    color = Color.Cyan;
                    break;
                case LogLevel.Warning:
                    color = Color.Yellow;
                    break;
                case LogLevel.Error:
                    color = Color.Red;
                    break;
                default:
                    color = Color.LightGreen;
                    break;
            }

            string timestamp = DateTime.Now.ToString("HH:mm:ss");
            txtLog.SelectionStart = txtLog.TextLength;
            txtLog.SelectionColor = Color.Gray;
            txtLog.AppendText($"[{timestamp}] ");
            txtLog.SelectionStart = txtLog.TextLength;
            txtLog.SelectionColor = color;
            txtLog.AppendText($"{message}\n");
            txtLog.ScrollToCaret();
        }

        #endregion

        #region Cleanup

        protected override void OnFormClosing(FormClosingEventArgs e)
        {
            if (_testInProgress)
            {
                e.Cancel = true;
                MessageBox.Show("Cannot close while a test is in progress.", 
                    "Test In Progress", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            _connectionStatusTimer?.Stop();
            _connectionStatusTimer?.Dispose();
            _omnia?.Disconnect();
            _omnia?.Dispose();
            _dbHelper?.Dispose();
            
            base.OnFormClosing(e);
        }

        #endregion
    }
}
