using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using HipotTestApp.Models;

namespace HipotTestApp.Data
{
    /// <summary>
    /// Database helper class for SQL Server operations
    /// Following the established patterns from other Eaton applications
    /// Uses Phoenix database for test results and TestEngineering database for users
    /// </summary>
    public class DatabaseHelper : IDisposable
    {
        private readonly string _phoenixConnectionString;
        private readonly string _testEngineeringConnectionString;
        private SqlConnection _connection;
        private string _lastError;

        /// <summary>
        /// Gets the last error message
        /// </summary>
        public string LastError => _lastError;

        /// <summary>
        /// Initializes the database helper with connection strings from App.config
        /// </summary>
        public DatabaseHelper()
        {
            _phoenixConnectionString = ConfigurationManager.ConnectionStrings["PhoenixConnectionString"]?.ConnectionString
                ?? throw new InvalidOperationException("Connection string 'PhoenixConnectionString' not found in config");
            
            _testEngineeringConnectionString = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"]?.ConnectionString
                ?? throw new InvalidOperationException("Connection string 'TestEngineeringConnectionString' not found in config");
        }

        /// <summary>
        /// Initializes the database helper with specific connection strings
        /// </summary>
        public DatabaseHelper(string phoenixConnectionString, string testEngineeringConnectionString = null)
        {
            _phoenixConnectionString = phoenixConnectionString ?? throw new ArgumentNullException(nameof(phoenixConnectionString));
            _testEngineeringConnectionString = testEngineeringConnectionString ?? phoenixConnectionString;
        }

        #region Connection Management

        /// <summary>
        /// Tests the database connection (Phoenix database)
        /// </summary>
        public bool TestConnection()
        {
            try
            {
                using (var conn = new SqlConnection(_phoenixConnectionString))
                {
                    conn.Open();
                    return true;
                }
            }
            catch (Exception ex)
            {
                _lastError = $"Connection test failed: {ex.Message}";
                return false;
            }
        }

        /// <summary>
        /// Gets a new open connection to Phoenix database
        /// </summary>
        private SqlConnection GetPhoenixConnection()
        {
            var conn = new SqlConnection(_phoenixConnectionString);
            conn.Open();
            return conn;
        }

        /// <summary>
        /// Gets a new open connection to TestEngineering database
        /// </summary>
        private SqlConnection GetTestEngineeringConnection()
        {
            var conn = new SqlConnection(_testEngineeringConnectionString);
            conn.Open();
            return conn;
        }

        #endregion

        #region User Operations

        /// <summary>
        /// Validates user credentials and returns user if valid
        /// Uses TestEngineering database where Users table resides
        /// </summary>
        public User ValidateUser(string eNumber, string password)
        {
            try
            {
                using (var conn = GetTestEngineeringConnection())
                {
                    string sql = @"
                        SELECT UserID, ENumber, FullName, Email, Department, JobRole, 
                               TestLine, UserCategory, IsActive, CreatedDate
                        FROM dbo.Users
                        WHERE ENumber = @ENumber AND Password = @Password AND IsActive = 1";

                    using (var cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@ENumber", eNumber);
                        cmd.Parameters.AddWithValue("@Password", password);

                        using (var reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                return new User
                                {
                                    UserID = reader.GetInt32(0),
                                    ENumber = reader.GetString(1),
                                    FullName = reader.GetString(2),
                                    Email = reader.IsDBNull(3) ? null : reader.GetString(3),
                                    Department = reader.IsDBNull(4) ? null : reader.GetString(4),
                                    JobRole = reader.IsDBNull(5) ? null : reader.GetString(5),
                                    TestLine = reader.IsDBNull(6) ? null : reader.GetString(6),
                                    UserCategory = reader.IsDBNull(7) ? null : reader.GetString(7),
                                    IsActive = reader.GetBoolean(8),
                                    CreatedDate = reader.GetDateTime(9)
                                };
                            }
                        }
                    }
                }
                return null;
            }
            catch (Exception ex)
            {
                _lastError = $"User validation failed: {ex.Message}";
                return null;
            }
        }

        /// <summary>
        /// Gets user by ENumber
        /// Uses TestEngineering database where Users table resides
        /// </summary>
        public User GetUserByENumber(string eNumber)
        {
            try
            {
                using (var conn = GetTestEngineeringConnection())
                {
                    string sql = @"
                        SELECT UserID, ENumber, FullName, Email, Department, JobRole, 
                               TestLine, UserCategory, IsActive, CreatedDate
                        FROM dbo.Users
                        WHERE ENumber = @ENumber";

                    using (var cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@ENumber", eNumber);

                        using (var reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                return new User
                                {
                                    UserID = reader.GetInt32(0),
                                    ENumber = reader.GetString(1),
                                    FullName = reader.GetString(2),
                                    Email = reader.IsDBNull(3) ? null : reader.GetString(3),
                                    Department = reader.IsDBNull(4) ? null : reader.GetString(4),
                                    JobRole = reader.IsDBNull(5) ? null : reader.GetString(5),
                                    TestLine = reader.IsDBNull(6) ? null : reader.GetString(6),
                                    UserCategory = reader.IsDBNull(7) ? null : reader.GetString(7),
                                    IsActive = reader.GetBoolean(8),
                                    CreatedDate = reader.GetDateTime(9)
                                };
                            }
                        }
                    }
                }
                return null;
            }
            catch (Exception ex)
            {
                _lastError = $"Get user failed: {ex.Message}";
                return null;
            }
        }

        #endregion

        #region Hipot Test Results

        /// <summary>
        /// Saves a Hipot test result to the database
        /// Uses Phoenix database where HipotTestResults table resides
        /// </summary>
        public bool SaveHipotTestResult(HipotTestResult result)
        {
            try
            {
                using (var conn = GetPhoenixConnection())
                {
                    string sql = @"
                        INSERT INTO dbo.HipotTestResults (
                            SerialNumber, PartNumber, BreakerPanelSerialNumber, GSECPanelSerialNumber,
                            WorkOrder, TestDateTime, OperatorENumber,
                            EquipmentID, TestFileLoaded, OverallResult, TotalTestTime,
                            GND_Result, GND_Current_A, GND_Voltage_V, GND_Resistance_mOhm,
                            GND_HiLimit_mOhm, GND_LoLimit_mOhm, GND_DwellTime_s, GND_Frequency_Hz,
                            ACW_Result, ACW_Voltage_V, ACW_LeakageCurrent_mA, ACW_HiLimit_mA,
                            ACW_LoLimit_mA, ACW_HiLimitReal_mA, ACW_LoLimitReal_mA, ACW_RampUp_s,
                            ACW_DwellTime_s, ACW_RampDown_s, ACW_Frequency_Hz, ACW_ArcSense,
                            ACW_ArcDetected, FailureReason, FailureStep, Comments, RawResponse,
                            CreatedDate, CreatedBy
                        ) VALUES (
                            @SerialNumber, @PartNumber, @BreakerPanelSerialNumber, @GSECPanelSerialNumber,
                            @WorkOrder, @TestDateTime, @OperatorENumber,
                            @EquipmentID, @TestFileLoaded, @OverallResult, @TotalTestTime,
                            @GND_Result, @GND_Current_A, @GND_Voltage_V, @GND_Resistance_mOhm,
                            @GND_HiLimit_mOhm, @GND_LoLimit_mOhm, @GND_DwellTime_s, @GND_Frequency_Hz,
                            @ACW_Result, @ACW_Voltage_V, @ACW_LeakageCurrent_mA, @ACW_HiLimit_mA,
                            @ACW_LoLimit_mA, @ACW_HiLimitReal_mA, @ACW_LoLimitReal_mA, @ACW_RampUp_s,
                            @ACW_DwellTime_s, @ACW_RampDown_s, @ACW_Frequency_Hz, @ACW_ArcSense,
                            @ACW_ArcDetected, @FailureReason, @FailureStep, @Comments, @RawResponse,
                            @CreatedDate, @CreatedBy
                        );
                        SELECT SCOPE_IDENTITY();";

                    using (var cmd = new SqlCommand(sql, conn))
                    {
                        // Unit Identification
                        cmd.Parameters.AddWithValue("@SerialNumber", result.SerialNumber);
                        cmd.Parameters.AddWithValue("@PartNumber", (object)result.PartNumber ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@BreakerPanelSerialNumber", (object)result.BreakerPanelSerialNumber ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@GSECPanelSerialNumber", (object)result.GSECPanelSerialNumber ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@WorkOrder", (object)result.WorkOrder ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@TestDateTime", result.TestDateTime);
                        cmd.Parameters.AddWithValue("@OperatorENumber", result.OperatorENumber);
                        cmd.Parameters.AddWithValue("@EquipmentID", (object)result.EquipmentID ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@TestFileLoaded", (object)result.TestFileLoaded ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@OverallResult", result.OverallResult);
                        cmd.Parameters.AddWithValue("@TotalTestTime", (object)result.TotalTestTime ?? DBNull.Value);

                        // Ground Bond Test Results
                        cmd.Parameters.AddWithValue("@GND_Result", (object)result.GroundBondTest?.Result ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@GND_Current_A", (object)result.GroundBondTest?.Current_A ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@GND_Voltage_V", (object)result.GroundBondTest?.Voltage_V ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@GND_Resistance_mOhm", (object)result.GroundBondTest?.Resistance_mOhm ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@GND_HiLimit_mOhm", (object)result.GroundBondTest?.HiLimit_mOhm ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@GND_LoLimit_mOhm", (object)result.GroundBondTest?.LoLimit_mOhm ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@GND_DwellTime_s", (object)result.GroundBondTest?.DwellTime_s ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@GND_Frequency_Hz", (object)result.GroundBondTest?.Frequency_Hz ?? DBNull.Value);

                        // AC Withstand Test Results
                        cmd.Parameters.AddWithValue("@ACW_Result", (object)result.ACWithstandTest?.Result ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@ACW_Voltage_V", (object)result.ACWithstandTest?.Voltage_V ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@ACW_LeakageCurrent_mA", (object)result.ACWithstandTest?.LeakageCurrent_mA ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@ACW_HiLimit_mA", (object)result.ACWithstandTest?.HiLimit_mA ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@ACW_LoLimit_mA", (object)result.ACWithstandTest?.LoLimit_mA ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@ACW_HiLimitReal_mA", (object)result.ACWithstandTest?.HiLimitReal_mA ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@ACW_LoLimitReal_mA", (object)result.ACWithstandTest?.LoLimitReal_mA ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@ACW_RampUp_s", (object)result.ACWithstandTest?.RampUp_s ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@ACW_DwellTime_s", (object)result.ACWithstandTest?.DwellTime_s ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@ACW_RampDown_s", (object)result.ACWithstandTest?.RampDown_s ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@ACW_Frequency_Hz", (object)result.ACWithstandTest?.Frequency_Hz ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@ACW_ArcSense", (object)result.ACWithstandTest?.ArcSense ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@ACW_ArcDetected", (object)result.ACWithstandTest?.ArcDetected ?? DBNull.Value);

                        // Failure Information
                        cmd.Parameters.AddWithValue("@FailureReason", (object)result.FailureReason ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@FailureStep", (object)result.FailureStep ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@Comments", (object)result.Comments ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@RawResponse", (object)result.RawResponse ?? DBNull.Value);

                        // Audit Fields
                        cmd.Parameters.AddWithValue("@CreatedDate", result.CreatedDate);
                        cmd.Parameters.AddWithValue("@CreatedBy", (object)result.CreatedBy ?? DBNull.Value);

                        object id = cmd.ExecuteScalar();
                        result.TestResultID = Convert.ToInt32(id);
                        return true;
                    }
                }
            }
            catch (Exception ex)
            {
                _lastError = $"Save Hipot test result failed: {ex.Message}";
                return false;
            }
        }

        /// <summary>
        /// Gets test history for a serial number
        /// Uses Phoenix database where HipotTestResults table resides
        /// </summary>
        public List<HipotTestResult> GetTestHistory(string serialNumber)
        {
            var results = new List<HipotTestResult>();
            try
            {
                using (var conn = GetPhoenixConnection())
                {
                    string sql = @"
                        SELECT TestResultID, SerialNumber, PartNumber, WorkOrder, TestDateTime,
                               OperatorENumber, EquipmentID, OverallResult, TotalTestTime,
                               GND_Result, GND_Resistance_mOhm, GND_HiLimit_mOhm,
                               ACW_Result, ACW_Voltage_V, ACW_LeakageCurrent_mA, ACW_HiLimit_mA,
                               FailureReason, Comments
                        FROM dbo.HipotTestResults
                        WHERE SerialNumber = @SerialNumber
                        ORDER BY TestDateTime DESC";

                    using (var cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@SerialNumber", serialNumber);

                        using (var reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                var result = new HipotTestResult
                                {
                                    TestResultID = reader.GetInt32(0),
                                    SerialNumber = reader.GetString(1),
                                    PartNumber = reader.IsDBNull(2) ? null : reader.GetString(2),
                                    WorkOrder = reader.IsDBNull(3) ? null : reader.GetString(3),
                                    TestDateTime = reader.GetDateTime(4),
                                    OperatorENumber = reader.GetString(5),
                                    EquipmentID = reader.IsDBNull(6) ? null : reader.GetString(6),
                                    OverallResult = reader.GetString(7),
                                    TotalTestTime = reader.IsDBNull(8) ? null : (decimal?)reader.GetDecimal(8),
                                    GroundBondTest = new GroundBondResult
                                    {
                                        Result = reader.IsDBNull(9) ? null : reader.GetString(9),
                                        Resistance_mOhm = reader.IsDBNull(10) ? null : (decimal?)reader.GetDecimal(10),
                                        HiLimit_mOhm = reader.IsDBNull(11) ? null : (decimal?)reader.GetDecimal(11)
                                    },
                                    ACWithstandTest = new ACWithstandResult
                                    {
                                        Result = reader.IsDBNull(12) ? null : reader.GetString(12),
                                        Voltage_V = reader.IsDBNull(13) ? null : (decimal?)reader.GetDecimal(13),
                                        LeakageCurrent_mA = reader.IsDBNull(14) ? null : (decimal?)reader.GetDecimal(14),
                                        HiLimit_mA = reader.IsDBNull(15) ? null : (decimal?)reader.GetDecimal(15)
                                    },
                                    FailureReason = reader.IsDBNull(16) ? null : reader.GetString(16),
                                    Comments = reader.IsDBNull(17) ? null : reader.GetString(17)
                                };
                                results.Add(result);
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                _lastError = $"Get test history failed: {ex.Message}";
            }
            return results;
        }

        /// <summary>
        /// Gets the most recent test results (last N tests across all units)
        /// Uses Phoenix database where HipotTestResults table resides
        /// </summary>
        public List<HipotTestResult> GetRecentTestHistory(int count = 10)
        {
            var results = new List<HipotTestResult>();
            try
            {
                using (var conn = GetPhoenixConnection())
                {
                    string sql = $@"
                        SELECT TOP {count} 
                               TestResultID, SerialNumber, PartNumber, 
                               BreakerPanelSerialNumber, GSECPanelSerialNumber,
                               TestDateTime, OperatorENumber, EquipmentID, OverallResult, 
                               TotalTestTime, GND_Result, GND_Resistance_mOhm, GND_HiLimit_mOhm,
                               ACW_Result, ACW_Voltage_V, ACW_LeakageCurrent_mA, ACW_HiLimit_mA,
                               FailureReason, Comments
                        FROM dbo.HipotTestResults
                        ORDER BY TestDateTime DESC";

                    using (var cmd = new SqlCommand(sql, conn))
                    {
                        using (var reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                var result = new HipotTestResult
                                {
                                    TestResultID = reader.GetInt32(0),
                                    SerialNumber = reader.GetString(1),
                                    PartNumber = reader.IsDBNull(2) ? null : reader.GetString(2),
                                    BreakerPanelSerialNumber = reader.IsDBNull(3) ? null : reader.GetString(3),
                                    GSECPanelSerialNumber = reader.IsDBNull(4) ? null : reader.GetString(4),
                                    TestDateTime = reader.GetDateTime(5),
                                    OperatorENumber = reader.GetString(6),
                                    EquipmentID = reader.IsDBNull(7) ? null : reader.GetString(7),
                                    OverallResult = reader.GetString(8),
                                    TotalTestTime = reader.IsDBNull(9) ? null : (decimal?)reader.GetDecimal(9),
                                    GroundBondTest = new GroundBondResult
                                    {
                                        Result = reader.IsDBNull(10) ? null : reader.GetString(10),
                                        Resistance_mOhm = reader.IsDBNull(11) ? null : (decimal?)reader.GetDecimal(11),
                                        HiLimit_mOhm = reader.IsDBNull(12) ? null : (decimal?)reader.GetDecimal(12)
                                    },
                                    ACWithstandTest = new ACWithstandResult
                                    {
                                        Result = reader.IsDBNull(13) ? null : reader.GetString(13),
                                        Voltage_V = reader.IsDBNull(14) ? null : (decimal?)reader.GetDecimal(14),
                                        LeakageCurrent_mA = reader.IsDBNull(15) ? null : (decimal?)reader.GetDecimal(15),
                                        HiLimit_mA = reader.IsDBNull(16) ? null : (decimal?)reader.GetDecimal(16)
                                    },
                                    FailureReason = reader.IsDBNull(17) ? null : reader.GetString(17),
                                    Comments = reader.IsDBNull(18) ? null : reader.GetString(18)
                                };
                                results.Add(result);
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                _lastError = $"Get recent test history failed: {ex.Message}";
            }
            return results;
        }

        /// <summary>
        /// Gets all test results (for full history view)
        /// Uses Phoenix database where HipotTestResults table resides
        /// </summary>
        public List<HipotTestResult> GetAllTestHistory()
        {
            var results = new List<HipotTestResult>();
            try
            {
                using (var conn = GetPhoenixConnection())
                {
                    string sql = @"
                        SELECT TestResultID, SerialNumber, PartNumber, 
                               BreakerPanelSerialNumber, GSECPanelSerialNumber,
                               TestDateTime, OperatorENumber, EquipmentID, OverallResult, 
                               TotalTestTime, GND_Result, GND_Resistance_mOhm, GND_HiLimit_mOhm,
                               ACW_Result, ACW_Voltage_V, ACW_LeakageCurrent_mA, ACW_HiLimit_mA,
                               FailureReason, Comments
                        FROM dbo.HipotTestResults
                        ORDER BY TestDateTime DESC";

                    using (var cmd = new SqlCommand(sql, conn))
                    {
                        using (var reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                var result = new HipotTestResult
                                {
                                    TestResultID = reader.GetInt32(0),
                                    SerialNumber = reader.GetString(1),
                                    PartNumber = reader.IsDBNull(2) ? null : reader.GetString(2),
                                    BreakerPanelSerialNumber = reader.IsDBNull(3) ? null : reader.GetString(3),
                                    GSECPanelSerialNumber = reader.IsDBNull(4) ? null : reader.GetString(4),
                                    TestDateTime = reader.GetDateTime(5),
                                    OperatorENumber = reader.GetString(6),
                                    EquipmentID = reader.IsDBNull(7) ? null : reader.GetString(7),
                                    OverallResult = reader.GetString(8),
                                    TotalTestTime = reader.IsDBNull(9) ? null : (decimal?)reader.GetDecimal(9),
                                    GroundBondTest = new GroundBondResult
                                    {
                                        Result = reader.IsDBNull(10) ? null : reader.GetString(10),
                                        Resistance_mOhm = reader.IsDBNull(11) ? null : (decimal?)reader.GetDecimal(11),
                                        HiLimit_mOhm = reader.IsDBNull(12) ? null : (decimal?)reader.GetDecimal(12)
                                    },
                                    ACWithstandTest = new ACWithstandResult
                                    {
                                        Result = reader.IsDBNull(13) ? null : reader.GetString(13),
                                        Voltage_V = reader.IsDBNull(14) ? null : (decimal?)reader.GetDecimal(14),
                                        LeakageCurrent_mA = reader.IsDBNull(15) ? null : (decimal?)reader.GetDecimal(15),
                                        HiLimit_mA = reader.IsDBNull(16) ? null : (decimal?)reader.GetDecimal(16)
                                    },
                                    FailureReason = reader.IsDBNull(17) ? null : reader.GetString(17),
                                    Comments = reader.IsDBNull(18) ? null : reader.GetString(18)
                                };
                                results.Add(result);
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                _lastError = $"Get all test history failed: {ex.Message}";
            }
            return results;
        }

        /// <summary>
        /// Checks if a serial number has a passing test
        /// Uses Phoenix database where HipotTestResults table resides
        /// </summary>
        public bool HasPassingTest(string serialNumber)
        {
            try
            {
                using (var conn = GetPhoenixConnection())
                {
                    string sql = @"
                        SELECT COUNT(1)
                        FROM dbo.HipotTestResults
                        WHERE SerialNumber = @SerialNumber AND OverallResult = 'PASS'";

                    using (var cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@SerialNumber", serialNumber);
                        return Convert.ToInt32(cmd.ExecuteScalar()) > 0;
                    }
                }
            }
            catch (Exception ex)
            {
                _lastError = $"Check passing test failed: {ex.Message}";
                return false;
            }
        }

        #endregion

        #region Safety Check Results

        /// <summary>
        /// Saves a safety check result to the database
        /// Uses Phoenix database where SafetyCheckResults table resides
        /// </summary>
        public bool SaveSafetyCheckResult(SafetyCheckResult result)
        {
            try
            {
                using (var conn = GetPhoenixConnection())
                {
                    string sql = @"
                        INSERT INTO dbo.SafetyCheckResults (
                            CheckDateTime, OperatorENumber, ShiftNumber, EquipmentID,
                            OverallResult, Continuity_Result, Continuity_Resistance_mOhm,
                            Continuity_HiLimit_mOhm, Continuity_LoLimit_mOhm,
                            GND_Result, GND_Current_A, GND_Resistance_mOhm,
                            GND_HiLimit_mOhm, GND_LoLimit_mOhm,
                            Comments, RawResponse, IsValidForShift, ExpirationDateTime,
                            CreatedDate, CreatedBy
                        ) VALUES (
                            @CheckDateTime, @OperatorENumber, @ShiftNumber, @EquipmentID,
                            @OverallResult, @Continuity_Result, @Continuity_Resistance_mOhm,
                            @Continuity_HiLimit_mOhm, @Continuity_LoLimit_mOhm,
                            @GND_Result, @GND_Current_A, @GND_Resistance_mOhm,
                            @GND_HiLimit_mOhm, @GND_LoLimit_mOhm,
                            @Comments, @RawResponse, @IsValidForShift, @ExpirationDateTime,
                            @CreatedDate, @CreatedBy
                        );
                        SELECT SCOPE_IDENTITY();";

                    using (var cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@CheckDateTime", result.CheckDateTime);
                        cmd.Parameters.AddWithValue("@OperatorENumber", result.OperatorENumber);
                        cmd.Parameters.AddWithValue("@ShiftNumber", (object)result.ShiftNumber ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@EquipmentID", (object)result.EquipmentID ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@OverallResult", result.OverallResult);

                        // Continuity Check
                        cmd.Parameters.AddWithValue("@Continuity_Result", (object)result.ContinuityCheck?.Result ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@Continuity_Resistance_mOhm", (object)result.ContinuityCheck?.Resistance_mOhm ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@Continuity_HiLimit_mOhm", (object)result.ContinuityCheck?.HiLimit_mOhm ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@Continuity_LoLimit_mOhm", (object)result.ContinuityCheck?.LoLimit_mOhm ?? DBNull.Value);

                        // Ground Bond Check
                        cmd.Parameters.AddWithValue("@GND_Result", (object)result.GroundBondCheck?.Result ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@GND_Current_A", (object)result.GroundBondCheck?.Current_A ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@GND_Resistance_mOhm", (object)result.GroundBondCheck?.Resistance_mOhm ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@GND_HiLimit_mOhm", (object)result.GroundBondCheck?.HiLimit_mOhm ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@GND_LoLimit_mOhm", (object)result.GroundBondCheck?.LoLimit_mOhm ?? DBNull.Value);

                        cmd.Parameters.AddWithValue("@Comments", (object)result.Comments ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@RawResponse", (object)result.RawResponse ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@IsValidForShift", result.IsValidForShift);
                        cmd.Parameters.AddWithValue("@ExpirationDateTime", (object)result.ExpirationDateTime ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@CreatedDate", result.CreatedDate);
                        cmd.Parameters.AddWithValue("@CreatedBy", (object)result.CreatedBy ?? DBNull.Value);

                        object id = cmd.ExecuteScalar();
                        result.SafetyCheckID = Convert.ToInt32(id);
                        return true;
                    }
                }
            }
            catch (Exception ex)
            {
                _lastError = $"Save safety check result failed: {ex.Message}";
                return false;
            }
        }

        /// <summary>
        /// Checks if operator has a valid safety check for current shift
        /// Uses Phoenix database where SafetyCheckResults table resides
        /// </summary>
        public bool HasValidSafetyCheck(string operatorENumber, out SafetyCheckResult lastCheck)
        {
            lastCheck = null;
            try
            {
                using (var conn = GetPhoenixConnection())
                {
                    string sql = @"
                        SELECT TOP 1 
                            SafetyCheckID, CheckDateTime, OperatorENumber, ShiftNumber,
                            EquipmentID, OverallResult, IsValidForShift, ExpirationDateTime
                        FROM dbo.SafetyCheckResults
                        WHERE OperatorENumber = @OperatorENumber
                            AND CAST(CheckDateTime AS DATE) = CAST(GETDATE() AS DATE)
                            AND OverallResult = 'PASS'
                            AND IsValidForShift = 1
                        ORDER BY CheckDateTime DESC";

                    using (var cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@OperatorENumber", operatorENumber);

                        using (var reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                lastCheck = new SafetyCheckResult
                                {
                                    SafetyCheckID = reader.GetInt32(0),
                                    CheckDateTime = reader.GetDateTime(1),
                                    OperatorENumber = reader.GetString(2),
                                    ShiftNumber = reader.IsDBNull(3) ? null : (int?)reader.GetInt32(3),
                                    EquipmentID = reader.IsDBNull(4) ? null : reader.GetString(4),
                                    OverallResult = reader.GetString(5),
                                    IsValidForShift = reader.GetBoolean(6),
                                    ExpirationDateTime = reader.IsDBNull(7) ? null : (DateTime?)reader.GetDateTime(7)
                                };

                                // Verify it's still valid (same shift, not expired)
                                return lastCheck.IsStillValid();
                            }
                        }
                    }
                }
                return false;
            }
            catch (Exception ex)
            {
                _lastError = $"Check safety status failed: {ex.Message}";
                return false;
            }
        }

        /// <summary>
        /// Gets today's safety checks for all operators
        /// Uses Phoenix database where SafetyCheckResults table resides
        /// </summary>
        public List<SafetyCheckResult> GetTodaySafetyChecks()
        {
            var results = new List<SafetyCheckResult>();
            try
            {
                using (var conn = GetPhoenixConnection())
                {
                    string sql = @"
                        SELECT SafetyCheckID, CheckDateTime, OperatorENumber, ShiftNumber,
                               EquipmentID, OverallResult, Continuity_Result, GND_Result,
                               IsValidForShift
                        FROM dbo.SafetyCheckResults
                        WHERE CAST(CheckDateTime AS DATE) = CAST(GETDATE() AS DATE)
                        ORDER BY CheckDateTime DESC";

                    using (var cmd = new SqlCommand(sql, conn))
                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            var result = new SafetyCheckResult
                            {
                                SafetyCheckID = reader.GetInt32(0),
                                CheckDateTime = reader.GetDateTime(1),
                                OperatorENumber = reader.GetString(2),
                                ShiftNumber = reader.IsDBNull(3) ? null : (int?)reader.GetInt32(3),
                                EquipmentID = reader.IsDBNull(4) ? null : reader.GetString(4),
                                OverallResult = reader.GetString(5),
                                ContinuityCheck = new ContinuityCheckResult
                                {
                                    Result = reader.IsDBNull(6) ? null : reader.GetString(6)
                                },
                                GroundBondCheck = new GroundBondCheckResult
                                {
                                    Result = reader.IsDBNull(7) ? null : reader.GetString(7)
                                },
                                IsValidForShift = reader.GetBoolean(8)
                            };
                            results.Add(result);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                _lastError = $"Get today's safety checks failed: {ex.Message}";
            }
            return results;
        }

        #endregion

        #region IDisposable

        public void Dispose()
        {
            if (_connection != null)
            {
                if (_connection.State == ConnectionState.Open)
                {
                    _connection.Close();
                }
                _connection.Dispose();
                _connection = null;
            }
        }

        #endregion
    }
}
