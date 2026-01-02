
/*
 * TestRecordCheckerApp - Validation Logger (ValidationLogger.cs)
 * Version: 1.11
 * Author: J. Arias
 * Date: November 2025
 *
 * CHANGE LOG:
 * ===========
 * v1.11 (November 2025) - J. Arias
 * - Added version control and comprehensive documentation
 * - Documented SQL Server migration and improvements
 *
 * v1.9 (November 2025) - J. Arias
 * - Replaced Access database logging with SQL Server "Test Validation Records" table
 * - Updated connection strings to use Battery database on usyouwhp6205605 server
 * - Replaced OleDb with SqlClient for better performance and reliability
 * - Updated WriteSqlServerLog method with proper parameterized queries
 * - Added null handling for database parameters using DBNull.Value
 * - Improved error handling and connection management
 *
 * v1.0 (Original) - CSV and Access database logging functionality
 */

using System;
using System.IO;
using System.Windows.Forms;
using System.Data.SqlClient;
using System.Configuration;

namespace TestRecordCheckerApp.Classes
{
    public class ValidationLogger
    {
        private readonly string localPath = "validation_log.csv";
        private readonly string networkPath = @"\\youncsfp01\public\Temp\Battery\ValidationRecords\validation_log_network.csv";
        private readonly string fallbackPath = "network_log_fallback.csv";
        private string batteryConnectionString => ConfigurationManager.ConnectionStrings["BatteryConnectionString"].ConnectionString;


        private string machineName = Environment.MachineName;
        
        public void Log(string plant, string productionLine, string subLine, string stationName, string employeeID, string employeeName, string serialNumber, string checkStatus, string machineName)
        {
            string timestamp = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");
            string logEntry = $"{plant},{productionLine},{subLine},{stationName},{employeeID},{employeeName},{serialNumber},{checkStatus},{timestamp},{machineName}";

            //save in csv files - Local and Network
            try
            {
                WriteCsvLog(localPath, logEntry, true);
                try
                {
                    WriteCsvLog(networkPath, logEntry, true);
                }
                catch (Exception netEx)
                {
                    WriteCsvLog(fallbackPath, logEntry, true);
                    MessageBox.Show("Network log failed. Entry saved locally for retry.\n\n" + netEx.Message,
                                    "Network Logging Error", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error logging validation in csv file: " + ex.Message,
                                "Logging Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }

            //save in SQL Server Battery database
            try
            {
                WriteSqlServerLog(plant, productionLine, subLine, stationName, employeeID, employeeName, serialNumber, checkStatus, machineName);
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error logging validation in SQL Server database: " + ex.Message,
                                "SQL Server DB Logging Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void WriteCsvLog(string path, string entry, bool includeHeader)
        {
            if (!File.Exists(path) && includeHeader)
            {
                File.WriteAllText(path, "Timestamp,EmployeeName,SerialNumber,LineNumber,CheckDataRecord\n");
            }
            File.AppendAllText(path, entry + Environment.NewLine);
        }

        private void WriteSqlServerLog(string plant, string productionLine, string subLine, string stationName, string employeeID, string employeeName, string serialNumber, string checkStatus, string machineName)
        {
            string timestamp = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");

            string query = @"INSERT INTO [Test Validation Records]
        (Plant, ProductionLine, SubLine, StationName, VerifierEmployeeID, VerifierEmployeeName, SerialNumber, CheckStatus, VerificationDateTime, VerificationMachineName)
        VALUES (@Plant, @ProductionLine, @SubLine, @StationName, @VerifierEmployeeID, @VerifierEmployeeName, @SerialNumber, @CheckStatus, @VerificationDateTime, @VerificationMachineName)";

            using (SqlConnection conn = new SqlConnection(batteryConnectionString))
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@Plant", plant ?? (object)DBNull.Value);
                cmd.Parameters.AddWithValue("@ProductionLine", productionLine ?? (object)DBNull.Value);
                cmd.Parameters.AddWithValue("@SubLine", subLine ?? (object)DBNull.Value);
                cmd.Parameters.AddWithValue("@StationName", stationName ?? (object)DBNull.Value);
                cmd.Parameters.AddWithValue("@VerifierEmployeeID", employeeID ?? (object)DBNull.Value);
                cmd.Parameters.AddWithValue("@VerifierEmployeeName", employeeName ?? (object)DBNull.Value);
                cmd.Parameters.AddWithValue("@SerialNumber", serialNumber ?? (object)DBNull.Value);
                cmd.Parameters.AddWithValue("@CheckStatus", checkStatus ?? (object)DBNull.Value);
                cmd.Parameters.AddWithValue("@VerificationDateTime", DateTime.Parse(timestamp));
                cmd.Parameters.AddWithValue("@VerificationMachineName", machineName ?? (object)DBNull.Value);

                conn.Open();
                cmd.ExecuteNonQuery();
            }
        }

    }
}