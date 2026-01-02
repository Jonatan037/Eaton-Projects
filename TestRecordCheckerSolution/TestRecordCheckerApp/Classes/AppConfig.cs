
/*
 * TestRecordCheckerApp - Application Configuration (AppConfig.cs)
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
 * - Added BatteryLineID configuration reading from appsettings.ini
 * - Enhanced ValidateUserAgainstSQL method with department and test line logic
 * - Added specific authorization error messages
 * - Improved SQL query to include Department and TestLine columns
 *
 * v1.7 (November 2025) - J. Arias
 * - Added SQL-based user validation with FullName retrieval
 * - Implemented ValidateUserAgainstSQL method with tuple return
 * - Added connection timeout handling (30 seconds) to prevent hanging
 * - Improved error handling with user-friendly messages
 * - Added IsUserSQLValidationEnabled method for configuration checking
 *
 * v1.0 (Original) - Basic INI file configuration reading functionality
 */

using System;
using System.Collections.Generic;
using System.IO;
using System.Data.SqlClient;
using System.Configuration;

namespace TestRecordCheckerApp.Classes
{
    public class AppConfig
    {
        private readonly string configPath = "appsettings.ini";

        //LoadSpecificSetting go to the .INI File, under [Settings] and look for the specific setting value passed as string
        public string LoadSpecificSetting(string setting)
        {
            string output = string.Empty;

            if (File.Exists(configPath))
            {
                var lines = File.ReadAllLines(configPath);
                bool inSettingsSection = false;

                foreach (var line in lines)
                {
                    if (line.Trim() == "[Settings]")
                    {
                        inSettingsSection = true;
                        continue;
                    }

                    if (inSettingsSection)
                    {
                        if (line.StartsWith("[") && line.EndsWith("]"))
                            break;

                        if (line.StartsWith($"{setting}="))
                        {
                            output = line.Split('=')[1].Trim();
                            break;
                        }
                    }
                }
            }

            return output;
        }

        // Check if UserSQLValidation is enabled
        public bool IsUserSQLValidationEnabled()
        {
            string setting = LoadSpecificSetting("UserSQLValidation");
            return setting.ToLower() == "true" || setting == "1";
        }

        // Validate user against SQL database with department and test line authorization
        public (bool isValid, string fullName) ValidateUserAgainstSQL(string eNumber)
        {
            try
            {
                string connectionString = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;

                // Check if connection string is properly configured
                if (string.IsNullOrEmpty(connectionString) || connectionString.Contains("YOUR_SQL_SERVER_NAME"))
                {
                    System.Windows.Forms.MessageBox.Show(
                        "SQL validation is enabled but the database connection is not configured.\n\nPlease update the connection string in App.config:\n- Replace 'YOUR_SQL_SERVER_NAME' with your actual SQL Server name\n- Ensure the TestEngineering database is accessible\n- Verify dbo.Users table exists with ENumber, FullName, Department, and TestLine columns",
                        "Database Not Configured",
                        System.Windows.Forms.MessageBoxButtons.OK,
                        System.Windows.Forms.MessageBoxIcon.Warning);
                    return (false, string.Empty);
                }

                // Get battery line ID from config
                string batteryLineIDStr = LoadSpecificSetting("BatteryLineID");
                if (string.IsNullOrEmpty(batteryLineIDStr) || !int.TryParse(batteryLineIDStr, out int batteryLineID))
                {
                    batteryLineID = 2; // Default to 2 if not configured
                }

                // Add connection timeout to prevent hanging (30 seconds)
                if (!connectionString.Contains("Connection Timeout"))
                {
                    connectionString += ";Connection Timeout=30";
                }

                using (SqlConnection connection = new SqlConnection(connectionString))
                {
                    // Query to get user info including department and test lines
                    using (SqlCommand command = new SqlCommand("SELECT FullName, Department, TestLine FROM dbo.Users WHERE ENumber = @ENumber", connection))
                    {
                        command.Parameters.AddWithValue("@ENumber", eNumber);
                        command.CommandTimeout = 30; // 30 second timeout

                        connection.Open();
                        using (SqlDataReader reader = command.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                // User exists, get their information
                                string fullName = reader["FullName"] != DBNull.Value ? reader["FullName"].ToString().Trim() : eNumber;
                                string department = reader["Department"] != DBNull.Value ? reader["Department"].ToString().Trim() : "";
                                string testLine = reader["TestLine"] != DBNull.Value ? reader["TestLine"].ToString().Trim() : "";

                                // Check department authorization
                                if (!string.IsNullOrEmpty(department) && department.Equals("Test Engineering", StringComparison.OrdinalIgnoreCase))
                                {
                                    // Test Engineering department has access to all
                                    return (true, fullName);
                                }

                                // Check test line authorization
                                if (!string.IsNullOrEmpty(testLine))
                                {
                                    // Parse comma-separated test line IDs
                                    string[] assignedLines = testLine.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
                                    foreach (string line in assignedLines)
                                    {
                                        if (int.TryParse(line.Trim(), out int lineID) && lineID == batteryLineID)
                                        {
                                            // User has battery line access
                                            return (true, fullName);
                                        }
                                    }
                                }

                                // User exists but doesn't have required department or test line access
                                System.Windows.Forms.MessageBox.Show(
                                    $"Access denied. User {fullName} does not have authorization for this station.\n\nRequired: Department='Test Engineering' OR TestLine contains '{batteryLineID}'",
                                    "Authorization Failed",
                                    System.Windows.Forms.MessageBoxButtons.OK,
                                    System.Windows.Forms.MessageBoxIcon.Warning);
                                return (false, string.Empty);
                            }
                            else
                            {
                                // User not found
                                return (false, string.Empty);
                            }
                        }
                    }
                }
            }
            catch (SqlException sqlEx)
            {
                // Show specific SQL error information
                System.Windows.Forms.MessageBox.Show(
                    $"Database connection error: {sqlEx.Message}\n\nPlease check:\n1. Database server is accessible\n2. Connection string is configured correctly\n3. dbo.Users table exists\n4. Required columns exist: ENumber, FullName, Department, TestLine",
                    "SQL Validation Error",
                    System.Windows.Forms.MessageBoxButtons.OK,
                    System.Windows.Forms.MessageBoxIcon.Error);
                return (false, string.Empty);
            }
            catch (Exception ex)
            {
                // Show general error information
                System.Windows.Forms.MessageBox.Show(
                    $"Unexpected error during SQL validation: {ex.Message}",
                    "Validation Error",
                    System.Windows.Forms.MessageBoxButtons.OK,
                    System.Windows.Forms.MessageBoxIcon.Error);
                return (false, string.Empty);
            }
        }
    }
}
