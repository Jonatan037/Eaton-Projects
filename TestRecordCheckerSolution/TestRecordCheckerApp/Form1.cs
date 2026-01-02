
/*
 * TestRecordCheckerApp - Main Form (Form1.cs)
 * Version: 1.11
 * Author: J. Arias
 * Date: November 2025
 *
 * CHANGE LOG:
 * ===========
 * v1.11 (November 2025) - J. Arias
 * - Added auto-focus functionality to serial number textbox for barcode scanning workflow
 * - Focus automatically returns to textbox after feedback forms close
 * - Enhanced user experience for continuous scanning operations
 *
 * v1.10 (November 2025) - J. Arias
 * - Implemented full-screen UI with professional styling
 * - Added rounded corners to logout button with hover effects
 * - Improved panel positioning and layout for better user experience
 * - Enhanced DataGridView with color-coded pass/fail indicators
 * - Added minimize functionality while maintaining full-screen behavior
 *
 * v1.9 (November 2025) - J. Arias
 * - Replaced Access database logging with SQL Server "Test Validation Records" table
 * - Updated connection strings for Battery database on usyouwhp6205605 server
 * - Improved error handling and database connection management
 * - Added proper null handling for database parameters
 *
 * v1.8 (November 2025) - J. Arias
 * - Implemented advanced user validation with department and test line authorization
 * - Added BatteryLineID configuration setting (default: 2)
 * - Users in "Test Engineering" department get full access
 * - Other users need specific test line assignment (comma-separated values)
 * - Enhanced error messages for authorization failures
 *
 * v1.7 (November 2025) - J. Arias
 * - Added SQL-based user validation with FullName retrieval
 * - Implemented optional SQL validation via UserSQLValidation setting
 * - Maintained backward compatibility with INI file validation
 * - Added connection timeout handling (30 seconds) to prevent hanging
 * - Improved error handling with user-friendly messages
 *
 * v1.6 (November 2025) - J. Arias
 * - Implemented comprehensive feedback system with animated GIFs and sound effects
 * - Added FeedbackForm (Form4) with siren sounds and visual indicators
 * - Continuous siren playback with alternating frequencies for fail notifications
 * - GIF animation refresh timers to maintain smooth animations
 * - Modal feedback dialogs with professional styling
 *
 * v1.5 (November 2025) - J. Arias
 * - Initial UI modernization and professional styling
 * - Enhanced form layouts and visual design
 * - Improved user experience with better controls and feedback
 */

using System;
using System.IO;
using System.Reflection.Emit;
using System.Windows.Forms;
using System.Media;
using System.Data;
using System.Drawing;
using System.Drawing.Drawing2D;
using TestRecordCheckerApp.Classes;

namespace TestRecordCheckerApp
{
    public partial class mainForm : Form
    {
        private string employeeName, employeeId, plant, productionLine, subLine, stationName, machineName;
        private ValidationLogger logger;
        private AppConfig config;

        public event EventHandler LogoutRequested;

        public mainForm(string employeeName, string employeeID)
        {
            InitializeComponent();
            logger = new ValidationLogger();
            config = new AppConfig();

            this.employeeName = employeeName;
            this.employeeId = employeeID;
            
            loadAppInfo();
            // DataGridView initialization moved to Load event
        }
                
        private void button1_Click_1(object sender, EventArgs e)
        {
            string SerialNumber = txtSerialNumber.Text;
            string Result = "BatteryTest_OverallResult";
            bool hasTestRecord = TDMResults.TDM_HasPassTestRecord(Result, SerialNumber);
            string passMsg = $"{SerialNumber} HAS A PASSED TEST RECORD \n \n PROCEED TO PACKAGING";
            string failMsg = $"NO TEST RECORD FOR {SerialNumber}! \n \n PLEASE RETEST!";

            VerifyTestRecord(hasTestRecord, SerialNumber, passMsg, failMsg);
            RefreshHistory();
            txtSerialNumber.Text = string.Empty;
            txtSerialNumber.Focus();
        }

        private void lblScanSerialNumber_Click(object sender, EventArgs e)
        {

        }

        private void textBox2_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Enter || e.KeyCode == Keys.Tab)
            {
                btnCheckRecord.PerformClick();
            }
        }

        private void button2_Click(object sender, EventArgs e)
        {
            LogoutRequested?.Invoke(this, EventArgs.Empty);
        }

        private void mainForm_Load(object sender, EventArgs e)
        {
            // Position the input panel on the left side (after sidebar)
            pnlInputArea.Left = 400; // Left side of the main area
            pnlInputArea.Top = 50;
            pnlInputArea.Width = 500; // Made smaller
            pnlInputArea.Height = 250; // Made smaller
            
            // Position the history title below the input panel
            lblHistoryTitle.Left = 400;
            lblHistoryTitle.Top = 320; // Below input panel
            
            // Position the history grid below the history title
            dgvHistory.Left = 400;
            dgvHistory.Top = 350; // Below history title
            dgvHistory.Width = 1000; // Fixed width for resizable form
            dgvHistory.Height = 500; // Fixed height for resizable form

            // Initialize DataGridView
            ConfigureHistoryGrid();
            LoadTodaysVerifications();
            dgvHistory.RowPrePaint += dgvHistory_RowPrePaint;

            // Apply rounded corners to logout button
            ApplyRoundedCorners(btnLogOut, 15);

            // Set auto-focus to serial number textbox for barcode scanning
            txtSerialNumber.Focus();
        }

        private void btnLogOut_MouseLeave(object sender, EventArgs e)
        {
            btnLogOut.BackColor = System.Drawing.Color.FromArgb(220, 53, 69); // Original red
        }

        private void btnLogOut_MouseEnter(object sender, EventArgs e)
        {
            btnLogOut.BackColor = System.Drawing.Color.FromArgb(255, 100, 100); // Lighter red
        }

        private void ConfigureHistoryGrid()
        {
            dgvHistory.AutoGenerateColumns = true;
            dgvHistory.ReadOnly = true;
            dgvHistory.AllowUserToAddRows = false;
            dgvHistory.AllowUserToDeleteRows = false;
            dgvHistory.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
            dgvHistory.MultiSelect = false;
            dgvHistory.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill;
        }

        private void LoadTodaysVerifications()
        {
            var reader = new ValidationLogReader();
            dgvHistory.DataSource = reader.GetTodaysValidations();
        }

        private void RefreshHistory()
        {
            var reader = new ValidationLogReader();
            dgvHistory.DataSource = reader.GetTodaysValidations();
        }

        private void dgvHistory_RowPrePaint(object sender, DataGridViewRowPrePaintEventArgs e)
        {
            var grid = sender as DataGridView;
            if (grid?.Rows[e.RowIndex].DataBoundItem is DataRowView rowView)
            {
                string result = rowView["Check Status"]?.ToString()?.ToLower();

                if (result == "pass")
                {
                    grid.Rows[e.RowIndex].DefaultCellStyle.BackColor = System.Drawing.Color.FromArgb(255, 144, 238, 144); // LightGreen
                }
                else if (result == "fail")
                {
                    grid.Rows[e.RowIndex].DefaultCellStyle.BackColor = System.Drawing.Color.FromArgb(255, 240, 128, 128); // LightCoral
                }
            }
        }

        private void VerifyTestRecord(bool hasTestRecord, string SerialNumber, string passMsg, string failMsg) 
        {
            if (hasTestRecord)
            {
                logger.Log(plant, productionLine, subLine, stationName, employeeId, employeeName, SerialNumber, "Pass", machineName);
                
                // Show success feedback form
                FeedbackForm feedback = new FeedbackForm(true);
                feedback.ShowDialog();
            }
            else
            {
                logger.Log(plant, productionLine, subLine, stationName, employeeId, employeeName, SerialNumber, "Fail", machineName);
                
                // Show fail feedback form
                FeedbackForm feedback = new FeedbackForm(false);
                feedback.ShowDialog();
            }

            // Restore focus to serial number textbox after feedback for continuous scanning
            txtSerialNumber.Focus();
        }

        private void loadAppInfo()
        {            
            plant = config.LoadSpecificSetting("Plant");
            productionLine = config.LoadSpecificSetting("ProductionLine");
            subLine = config.LoadSpecificSetting("SubLine");
            stationName = config.LoadSpecificSetting("StationName");
            machineName = Environment.MachineName;

            lblPlant.Text = plant + " Plant";
            lblLine.Text = productionLine;
            lblSubLine.Text = subLine;
            lblStation.Text = stationName + " Station";
            lblMachine.Text = machineName;
            lblECode.Text = employeeId;
            lblName.Text = employeeName;
        }

        private void ApplyRoundedCorners(Button button, int cornerRadius)
        {
            GraphicsPath path = new GraphicsPath();
            path.AddArc(0, 0, cornerRadius, cornerRadius, 180, 90);
            path.AddArc(button.Width - cornerRadius, 0, cornerRadius, cornerRadius, 270, 90);
            path.AddArc(button.Width - cornerRadius, button.Height - cornerRadius, cornerRadius, cornerRadius, 0, 90);
            path.AddArc(0, button.Height - cornerRadius, cornerRadius, cornerRadius, 90, 90);
            path.CloseFigure();
            button.Region = new Region(path);
        }
    }
}
