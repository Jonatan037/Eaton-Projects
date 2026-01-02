/*
 * TestRecordCheckerApp - Login Form (Form2.cs)
 * Version: 1.11
 * Author: J. Arias
 * Date: November 2025
 *
 * CHANGE LOG:
 * ===========
 * v1.11 (November 2025) - J. Arias
 * - Added version control and comprehensive documentation
 * - Documented all SQL validation and authorization enhancements
 *
 * v1.8 (November 2025) - J. Arias
 * - Implemented advanced user validation with department and test line authorization
 * - Added BatteryLineID configuration setting integration
 * - Enhanced error messages for authorization failures
 * - Maintained backward compatibility with INI file validation
 *
 * v1.7 (November 2025) - J. Arias
 * - Added SQL-based user validation with FullName retrieval
 * - Implemented optional SQL validation via UserSQLValidation setting
 * - Updated AttemptLogin method to use tuple return from validation
 * - Maintained backward compatibility with INI file validation
 *
 * v1.0 (Original) - Base login functionality with INI file validation
 */

using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.IO;
using TestRecordCheckerApp.Classes;


namespace TestRecordCheckerApp
{
    public partial class logInForm : Form
    {
        public event EventHandler<LoginEventArgs> LoginSuccessful;
        private Dictionary<string, string> employeeDict;
        private AppConfig config;
        private string plant, productionLine, subLine, stationName, machineName;

        public logInForm()
        {
            config = new AppConfig();
            InitializeComponent();
            loadAppInfo();
        }

        private Dictionary<string, string> LoadEmployeesFromConfig()
        {
            string configPath = "appsettings.ini";
            var employeeDict = new Dictionary<string, string>();
            bool inEmployeeSection = false;

            if (File.Exists(configPath))
            {
                var lines = File.ReadAllLines(configPath);
                foreach (var line in lines)
                {
                    if (line.Trim() == "[Employees]")
                    {
                        inEmployeeSection = true;
                        continue;
                    }

                    if (inEmployeeSection)
                    {
                        if (line.StartsWith("[") && line.EndsWith("]"))
                        {
                            break; // End of [Employees] section
                        }

                        if (line.Contains("="))
                        {
                            var parts = line.Split('=');
                            if (parts.Length == 2)
                            {
                                employeeDict[parts[0].Trim()] = parts[1].Trim();
                            }
                        }
                    }
                }
            }

            return employeeDict;
        }


        private void AttemptLogin(string scannedID)
        {
            bool isValidUser = false;
            string employeeName = string.Empty;

            // Check if SQL validation is enabled
            if (config.IsUserSQLValidationEnabled())
            {
                // Validate against SQL database and get user name
                var (isValid, fullName) = config.ValidateUserAgainstSQL(scannedID);
                isValidUser = isValid;
                if (isValidUser)
                {
                    employeeName = fullName;
                }
            }
            else
            {
                // Use INI file validation when SQL validation is disabled
                if (employeeDict.ContainsKey(scannedID))
                {
                    employeeName = employeeDict[scannedID];
                    isValidUser = true;
                }
            }

            if (isValidUser)
            {
                // Show success message
                MessageBox.Show($"Welcome, {employeeName}!", "Login Successful", MessageBoxButtons.OK, MessageBoxIcon.Information);

                LoginSuccessful?.Invoke(this, new LoginEventArgs(employeeName, scannedID));
            }
            else
            {
                MessageBox.Show("Invalid badge number.", "Access Denied", MessageBoxButtons.OK, MessageBoxIcon.Error);
                txtEmployeeNumber.Clear();
                txtEmployeeNumber.Focus();
            }
        }

        public void ResetForm() 
        {
            txtEmployeeNumber.Clear();
            txtEmployeeNumber.Focus();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            AttemptLogin(txtEmployeeNumber.Text.Trim());
        }

        private void logInForm_Load(object sender, EventArgs e)
        {

        }

        private void textBox2_TextChanged(object sender, EventArgs e)
        {
            if (!string.IsNullOrEmpty(txtEmployeeNumber.Text)) 
            {
                btnLogIn.Enabled = true;
            }
        }

        private void textBox2_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Enter || e.KeyCode == Keys.Tab)
            {
                btnLogIn.PerformClick();
            }
        }

        private void loadAppInfo()
        {
            employeeDict = LoadEmployeesFromConfig();
            plant = config.LoadSpecificSetting("Plant");
            productionLine = config.LoadSpecificSetting("ProductionLine");
            subLine = config.LoadSpecificSetting("SubLine");
            stationName = config.LoadSpecificSetting("StationName");
            machineName = Environment.MachineName;

            lblPlant.Text = plant + " Plant";
            lblLine.Text = productionLine;
            lblSubLine.Text = subLine;
            lblStation.Text = stationName + " Station";
            label2.Text = machineName;
        }
    }
}
