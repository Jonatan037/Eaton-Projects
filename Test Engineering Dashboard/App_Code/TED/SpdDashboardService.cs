using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;

namespace TED
{
    /// <summary>
    /// Service layer for SPD Label Verification Dashboard data access.
    /// Provides aggregated metrics and tracking information for the validation process.
    /// </summary>
    public class SpdDashboardService
    {
        private readonly string _connectionString;
        private readonly SpdLabelVerificationService _verificationService;

        public SpdDashboardService()
        {
            var settings = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"];
            _connectionString = settings != null ? settings.ConnectionString : null;
            _verificationService = new SpdLabelVerificationService();
        }

        /// <summary>
        /// Gets daily metrics for the specified date range.
        /// </summary>
        public DashboardMetrics GetDailyMetrics(DateTime startDate, DateTime endDate)
        {
            if (string.IsNullOrWhiteSpace(_connectionString))
            {
                return new DashboardMetrics();
            }

            try
            {
                using (var conn = new SqlConnection(_connectionString))
                using (var cmd = new SqlCommand(@"
                    SELECT 
                        ValidationDate,
                        TotalValidations,
                        TotalPassed,
                        TotalFailed,
                        TotalUniqueSerials,
                        TotalUniqueOperators,
                        PassRatePercent,
                        AvgValidationsPerSerial,
                        IntegratedCount,
                        SidemountCount
                    FROM dbo.SPDDashboard_DailyMetrics
                    WHERE ValidationDate >= @StartDate AND ValidationDate <= @EndDate
                    ORDER BY ValidationDate DESC", conn))
                {
                    cmd.Parameters.Add("@StartDate", SqlDbType.Date).Value = startDate;
                    cmd.Parameters.Add("@EndDate", SqlDbType.Date).Value = endDate;

                    conn.Open();
                    using (var reader = cmd.ExecuteReader())
                    {
                        var metrics = new DashboardMetrics
                        {
                            StartDate = startDate,
                            EndDate = endDate,
                            PeriodType = "Daily",
                            DailyData = new List<DailyMetric>()
                        };

                        while (reader.Read())
                        {
                            metrics.DailyData.Add(new DailyMetric
                            {
                                Date = reader.GetDateTime(0),
                                TotalValidations = SafeGetInt(reader, 1),
                                TotalPassed = SafeGetInt(reader, 2),
                                TotalFailed = SafeGetInt(reader, 3),
                                UniqueSerials = SafeGetInt(reader, 4),
                                UniqueOperators = SafeGetInt(reader, 5),
                                PassRatePercent = SafeGetDecimal(reader, 6),
                                AvgValidationsPerSerial = SafeGetDecimal(reader, 7),
                                IntegratedCount = SafeGetInt(reader, 8),
                                SidemountCount = SafeGetInt(reader, 9)
                            });
                        }

                        CalculateAggregates(metrics);
                        return metrics;
                    }
                }
            }
            catch (SqlException ex)
            {
                System.Diagnostics.Trace.WriteLine("[SPD Dashboard] Error loading daily metrics: " + ex.Message);
                return new DashboardMetrics();
            }
        }

        /// <summary>
        /// Gets weekly metrics for the specified date range.
        /// </summary>
        public DashboardMetrics GetWeeklyMetrics(DateTime startDate, DateTime endDate)
        {
            if (string.IsNullOrWhiteSpace(_connectionString))
            {
                return new DashboardMetrics();
            }

            try
            {
                using (var conn = new SqlConnection(_connectionString))
                using (var cmd = new SqlCommand(@"
                    SELECT 
                        [Year],
                        [Week],
                        WeekStart,
                        WeekEnd,
                        TotalValidations,
                        TotalPassed,
                        TotalFailed,
                        TotalUniqueSerials,
                        TotalUniqueOperators,
                        PassRatePercent,
                        AvgValidationsPerSerial
                    FROM dbo.SPDDashboard_WeeklyMetrics
                    WHERE WeekStart >= @StartDate AND WeekEnd <= @EndDate
                    ORDER BY [Year] DESC, [Week] DESC", conn))
                {
                    cmd.Parameters.Add("@StartDate", SqlDbType.Date).Value = startDate;
                    cmd.Parameters.Add("@EndDate", SqlDbType.Date).Value = endDate;

                    conn.Open();
                    using (var reader = cmd.ExecuteReader())
                    {
                        var metrics = new DashboardMetrics
                        {
                            StartDate = startDate,
                            EndDate = endDate,
                            PeriodType = "Weekly",
                            WeeklyData = new List<WeeklyMetric>()
                        };

                        while (reader.Read())
                        {
                            metrics.WeeklyData.Add(new WeeklyMetric
                            {
                                Year = SafeGetInt(reader, 0),
                                Week = SafeGetInt(reader, 1),
                                WeekStart = reader.GetDateTime(2),
                                WeekEnd = reader.GetDateTime(3),
                                TotalValidations = SafeGetInt(reader, 4),
                                TotalPassed = SafeGetInt(reader, 5),
                                TotalFailed = SafeGetInt(reader, 6),
                                UniqueSerials = SafeGetInt(reader, 7),
                                UniqueOperators = SafeGetInt(reader, 8),
                                PassRatePercent = SafeGetDecimal(reader, 9),
                                AvgValidationsPerSerial = SafeGetDecimal(reader, 10)
                            });
                        }

                        CalculateAggregates(metrics);
                        return metrics;
                    }
                }
            }
            catch (SqlException ex)
            {
                System.Diagnostics.Trace.WriteLine("[SPD Dashboard] Error loading weekly metrics: " + ex.Message);
                return new DashboardMetrics();
            }
        }

        /// <summary>
        /// Gets monthly metrics for the specified date range.
        /// </summary>
        public DashboardMetrics GetMonthlyMetrics(DateTime startDate, DateTime endDate)
        {
            if (string.IsNullOrWhiteSpace(_connectionString))
            {
                return new DashboardMetrics();
            }

            try
            {
                using (var conn = new SqlConnection(_connectionString))
                using (var cmd = new SqlCommand(@"
                    SELECT 
                        [Year],
                        [Month],
                        MonthStart,
                        MonthEnd,
                        TotalValidations,
                        TotalPassed,
                        TotalFailed,
                        TotalUniqueSerials,
                        TotalUniqueOperators,
                        PassRatePercent,
                        AvgValidationsPerSerial
                    FROM dbo.SPDDashboard_MonthlyMetrics
                    WHERE MonthStart >= @StartDate AND MonthEnd <= @EndDate
                    ORDER BY [Year] DESC, [Month] DESC", conn))
                {
                    cmd.Parameters.Add("@StartDate", SqlDbType.Date).Value = startDate;
                    cmd.Parameters.Add("@EndDate", SqlDbType.Date).Value = endDate;

                    conn.Open();
                    using (var reader = cmd.ExecuteReader())
                    {
                        var metrics = new DashboardMetrics
                        {
                            StartDate = startDate,
                            EndDate = endDate,
                            PeriodType = "Monthly",
                            MonthlyData = new List<MonthlyMetric>()
                        };

                        while (reader.Read())
                        {
                            metrics.MonthlyData.Add(new MonthlyMetric
                            {
                                Year = SafeGetInt(reader, 0),
                                Month = SafeGetInt(reader, 1),
                                MonthStart = reader.GetDateTime(2),
                                MonthEnd = reader.GetDateTime(3),
                                TotalValidations = SafeGetInt(reader, 4),
                                TotalPassed = SafeGetInt(reader, 5),
                                TotalFailed = SafeGetInt(reader, 6),
                                UniqueSerials = SafeGetInt(reader, 7),
                                UniqueOperators = SafeGetInt(reader, 8),
                                PassRatePercent = SafeGetDecimal(reader, 9),
                                AvgValidationsPerSerial = SafeGetDecimal(reader, 10)
                            });
                        }

                        CalculateAggregates(metrics);
                        return metrics;
                    }
                }
            }
            catch (SqlException ex)
            {
                System.Diagnostics.Trace.WriteLine("[SPD Dashboard] Error loading monthly metrics: " + ex.Message);
                return new DashboardMetrics();
            }
        }

        /// <summary>
        /// Gets detailed serial tracking information for the specified date range.
        /// </summary>
        public List<SerialTrackingItem> GetSerialTracking(DateTime startDate, DateTime endDate)
        {
            var items = new List<SerialTrackingItem>();
            if (string.IsNullOrWhiteSpace(_connectionString))
            {
                return items;
            }

            try
            {
                using (var conn = new SqlConnection(_connectionString))
                using (var cmd = new SqlCommand(@"
                    SELECT 
                        V.SerialNumber,
                        V.CatalogNumber,
                        V.Workcell,
                        S.ValidationCount,
                        S.CurrentStatus,
                        S.LastValidationTime,
                        S.PassCount,
                        S.FailCount,
                        S.Operators
                    FROM dbo.SPDDashboard_SerialValidationStatus AS S
                    INNER JOIN dbo.SPDLabelValidations AS V 
                        ON S.SerialNumber = V.SerialNumber
                    WHERE CAST(V.ValidationTime AS DATE) >= @StartDate 
                        AND CAST(V.ValidationTime AS DATE) <= @EndDate
                    GROUP BY V.SerialNumber, V.CatalogNumber, V.Workcell, 
                             S.ValidationCount, S.CurrentStatus, S.LastValidationTime,
                             S.PassCount, S.FailCount, S.Operators
                    ORDER BY S.LastValidationTime DESC", conn))
                {
                    cmd.Parameters.Add("@StartDate", SqlDbType.Date).Value = startDate;
                    cmd.Parameters.Add("@EndDate", SqlDbType.Date).Value = endDate;

                    conn.Open();
                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            items.Add(new SerialTrackingItem
                            {
                                SerialNumber = SafeGetString(reader, 0),
                                CatalogNumber = SafeGetString(reader, 1),
                                Workcell = SafeGetString(reader, 2),
                                ValidationCount = SafeGetInt(reader, 3),
                                CurrentStatus = SafeGetString(reader, 4),
                                LastValidationTime = SafeGetDateTime(reader, 5),
                                PassCount = SafeGetInt(reader, 6),
                                FailCount = SafeGetInt(reader, 7),
                                Operators = SafeGetString(reader, 8)
                            });
                        }
                    }
                }
            }
            catch (SqlException ex)
            {
                System.Diagnostics.Trace.WriteLine("[SPD Dashboard] Error loading serial tracking: " + ex.Message);
            }

            return items;
        }

        /// <summary>
        /// Gets tested units timeline with validation journey (like package tracking).
        /// </summary>
        public List<TestedUnitTimeline> GetTestedUnitsTimeline(DateTime startDate, DateTime endDate)
        {
            var timeline = new List<TestedUnitTimeline>();

            try
            {
                // Get all tested units from Access DB
                var testedUnits = _verificationService.GetPassedTestsForPeriod(startDate, endDate);

                foreach (var test in testedUnits)
                {
                var item = new TestedUnitTimeline
                {
                    SerialNumber = test.SerialNumber,
                    PartNumber = test.PartNumber,
                    Workcell = test.Workcell,
                    TestDate = test.StartTime ?? DateTime.Now,
                    TestResult = "PASS",
                    ValidationAttempts = new List<ValidationAttempt>()
                };                    // Get validation attempts from SQL
                    var validations = GetSerialHistory(test.SerialNumber);
                    
                    int attemptNum = 1;
                    foreach (var val in validations.OrderBy(v => v.ValidationTime))
                    {
                        item.ValidationAttempts.Add(new ValidationAttempt
                        {
                            AttemptNumber = attemptNum++,
                            ValidationTime = val.ValidationTime,
                            Result = val.IsMatch ? "PASS" : "FAIL",
                            OperatorName = val.OperatorName,
                            ScannedLabel = val.MaterialScanned,
                            IsMatch = val.IsMatch
                        });
                    }
                    
                    // Set last validator name
                    if (item.ValidationAttempts.Any())
                    {
                        item.LastValidatorName = item.ValidationAttempts.Last().OperatorName;
                    }
                    else
                    {
                        item.LastValidatorName = "-";
                    }

                    timeline.Add(item);
                }

                return timeline.OrderByDescending(x => x.TestDate).ToList();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.WriteLine("[SPD Dashboard] Error loading tested units timeline: " + ex.Message);
                return new List<TestedUnitTimeline>();
            }
        }

        /// <summary>
        /// Gets detailed validation history for a specific serial number.
        /// </summary>
        public List<ValidationHistoryItem> GetSerialHistory(string serialNumber)
        {
            var items = new List<ValidationHistoryItem>();
            if (string.IsNullOrWhiteSpace(_connectionString) || string.IsNullOrWhiteSpace(serialNumber))
            {
                return items;
            }

            try
            {
                using (var conn = new SqlConnection(_connectionString))
                using (var cmd = new SqlCommand(@"
                    SELECT 
                        ValidationTime,
                        OperatorName,
                        OperatorENumber,
                        MaterialScanned,
                        MaterialExpected,
                        IsMatch,
                        Workcell,
                        ValidationResult,
                        AttemptNumber,
                        IsFirstAttempt,
                        IsLatestAttempt
                    FROM dbo.SPDDashboard_DetailedValidationHistory
                    WHERE SerialNumber = @SerialNumber
                    ORDER BY ValidationTime DESC", conn))
                {
                    cmd.Parameters.Add("@SerialNumber", SqlDbType.NVarChar, 50).Value = serialNumber;

                    conn.Open();
                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            items.Add(new ValidationHistoryItem
                            {
                                ValidationTime = reader.GetDateTime(0),
                                OperatorName = SafeGetString(reader, 1),
                                OperatorENumber = SafeGetString(reader, 2),
                                MaterialScanned = SafeGetString(reader, 3),
                                MaterialExpected = SafeGetString(reader, 4),
                                IsMatch = SafeGetBool(reader, 5),
                                Workcell = SafeGetString(reader, 6),
                                ValidationResult = SafeGetString(reader, 7),
                                AttemptNumber = SafeGetInt(reader, 8),
                                IsFirstAttempt = SafeGetBool(reader, 9),
                                IsLatestAttempt = SafeGetBool(reader, 10)
                            });
                        }
                    }
                }
            }
            catch (SqlException ex)
            {
                System.Diagnostics.Trace.WriteLine("[SPD Dashboard] Error loading serial history: " + ex.Message);
            }

            return items;
        }

        /// <summary>
        /// Gets tested vs validated comparison for the specified date range.
        /// Uses Access database similar to how Tracks queries QDMS.
        /// </summary>
        public TestedVsValidatedMetrics GetTestedVsValidatedMetrics(DateTime startDate, DateTime endDate)
        {
            var metrics = new TestedVsValidatedMetrics
            {
                StartDate = startDate,
                EndDate = endDate,
                ByWorkcell = new Dictionary<string, WorkcellMetrics>()
            };

            // Get test data from Access DB (similar to how Tracks gets data from QDMS)
            var passedTests = _verificationService.GetPassedTestsForPeriod(startDate, endDate);
            
            // Get validation data from SQL
            var validations = GetValidationsForPeriod(startDate, endDate);

            // Process by workcell
            var workcells = new[] { "Integrated", "Sidemount" };
            
            foreach (var workcell in workcells)
            {
                // Get tested serials from Access DB
                var testedInWorkcell = passedTests.Where(t => 
                    string.Equals(t.Workcell, workcell, StringComparison.OrdinalIgnoreCase)).ToList();
                
                var testedSerials = new HashSet<string>(
                    testedInWorkcell.Select(t => t.SerialNumber != null ? t.SerialNumber.Trim().ToUpperInvariant() : null)
                        .Where(s => !string.IsNullOrEmpty(s)),
                    StringComparer.OrdinalIgnoreCase);
                
                // Get validated serials from SQL
                var validatedInWorkcell = validations.Where(v => 
                    string.Equals(v.Workcell, workcell, StringComparison.OrdinalIgnoreCase) && v.IsMatch).ToList();

                var validatedSerials = new HashSet<string>(
                    validatedInWorkcell.Select(v => v.SerialNumber != null ? v.SerialNumber.Trim().ToUpperInvariant() : null).Where(s => !string.IsNullOrEmpty(s)),
                    StringComparer.OrdinalIgnoreCase);

                var workcellMetrics = new WorkcellMetrics
                {
                    Workcell = workcell,
                    TestedCount = testedSerials.Count,
                    ValidatedCount = validatedSerials.Count,
                    PendingCount = Math.Max(0, testedSerials.Count - validatedSerials.Count),
                    ValidationRate = testedSerials.Count > 0 
                        ? (decimal)validatedSerials.Count / testedSerials.Count * 100 
                        : 0,
                    TestedSerials = testedSerials.ToList(),
                    ValidatedSerials = validatedSerials.ToList()
                };

                metrics.ByWorkcell[workcell] = workcellMetrics;
            }

            // Calculate overall metrics
            metrics.TotalTested = metrics.ByWorkcell.Values.Sum(w => w.TestedCount);
            metrics.TotalValidated = metrics.ByWorkcell.Values.Sum(w => w.ValidatedCount);
            metrics.TotalPending = metrics.ByWorkcell.Values.Sum(w => w.PendingCount);
            metrics.OverallValidationRate = metrics.TotalTested > 0
                ? (decimal)metrics.TotalValidated / metrics.TotalTested * 100
                : 0;

            return metrics;
        }

        private List<ValidationRecord> GetValidationsForPeriod(DateTime startDate, DateTime endDate)
        {
            var records = new List<ValidationRecord>();
            if (string.IsNullOrWhiteSpace(_connectionString))
            {
                return records;
            }

            try
            {
                using (var conn = new SqlConnection(_connectionString))
                using (var cmd = new SqlCommand(@"
                    SELECT SerialNumber, Workcell, IsMatch, ValidationTime
                    FROM dbo.SPDLabelValidations
                    WHERE CAST(ValidationTime AS DATE) >= @StartDate 
                        AND CAST(ValidationTime AS DATE) <= @EndDate", conn))
                {
                    cmd.Parameters.Add("@StartDate", SqlDbType.Date).Value = startDate;
                    cmd.Parameters.Add("@EndDate", SqlDbType.Date).Value = endDate;

                    conn.Open();
                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            records.Add(new ValidationRecord
                            {
                                SerialNumber = SafeGetString(reader, 0),
                                Workcell = SafeGetString(reader, 1),
                                IsMatch = SafeGetBool(reader, 2),
                                ValidationTime = SafeGetDateTime(reader, 3) ?? DateTime.MinValue
                            });
                        }
                    }
                }
            }
            catch (SqlException ex)
            {
                System.Diagnostics.Trace.WriteLine("[SPD Dashboard] Error loading validations: " + ex.Message);
            }

            return records;
        }

        private void CalculateAggregates(DashboardMetrics metrics)
        {
            int totalValidations = 0;
            int totalPassed = 0;
            int totalFailed = 0;

            if (metrics.DailyData != null)
            {
                foreach (var day in metrics.DailyData)
                {
                    totalValidations += day.TotalValidations;
                    totalPassed += day.TotalPassed;
                    totalFailed += day.TotalFailed;
                }
            }
            else if (metrics.WeeklyData != null)
            {
                foreach (var week in metrics.WeeklyData)
                {
                    totalValidations += week.TotalValidations;
                    totalPassed += week.TotalPassed;
                    totalFailed += week.TotalFailed;
                }
            }
            else if (metrics.MonthlyData != null)
            {
                foreach (var month in metrics.MonthlyData)
                {
                    totalValidations += month.TotalValidations;
                    totalPassed += month.TotalPassed;
                    totalFailed += month.TotalFailed;
                }
            }

            metrics.TotalValidations = totalValidations;
            metrics.TotalPassed = totalPassed;
            metrics.TotalFailed = totalFailed;
            metrics.OverallPassRate = totalValidations > 0 
                ? (decimal)totalPassed / totalValidations * 100 
                : 0;
        }

        private static int SafeGetInt(IDataReader reader, int ordinal)
        {
            return reader.IsDBNull(ordinal) ? 0 : Convert.ToInt32(reader.GetValue(ordinal));
        }

        private static decimal SafeGetDecimal(IDataReader reader, int ordinal)
        {
            return reader.IsDBNull(ordinal) ? 0m : Convert.ToDecimal(reader.GetValue(ordinal));
        }

        private static bool SafeGetBool(IDataReader reader, int ordinal)
        {
            return !reader.IsDBNull(ordinal) && Convert.ToBoolean(reader.GetValue(ordinal));
        }

        private static string SafeGetString(IDataReader reader, int ordinal)
        {
            return reader.IsDBNull(ordinal) ? null : Convert.ToString(reader.GetValue(ordinal));
        }

        private static DateTime? SafeGetDateTime(IDataReader reader, int ordinal)
        {
            return reader.IsDBNull(ordinal) ? (DateTime?)null : reader.GetDateTime(ordinal);
        }
    }

    #region Data Transfer Objects

    public class DashboardMetrics
    {
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public string PeriodType { get; set; }
        public int TotalValidations { get; set; }
        public int TotalPassed { get; set; }
        public int TotalFailed { get; set; }
        public decimal OverallPassRate { get; set; }
        public List<DailyMetric> DailyData { get; set; }
        public List<WeeklyMetric> WeeklyData { get; set; }
        public List<MonthlyMetric> MonthlyData { get; set; }
    }

    public class DailyMetric
    {
        public DateTime Date { get; set; }
        public int TotalValidations { get; set; }
        public int TotalPassed { get; set; }
        public int TotalFailed { get; set; }
        public int UniqueSerials { get; set; }
        public int UniqueOperators { get; set; }
        public decimal PassRatePercent { get; set; }
        public decimal AvgValidationsPerSerial { get; set; }
        public int IntegratedCount { get; set; }
        public int SidemountCount { get; set; }
    }

    public class WeeklyMetric
    {
        public int Year { get; set; }
        public int Week { get; set; }
        public DateTime WeekStart { get; set; }
        public DateTime WeekEnd { get; set; }
        public int TotalValidations { get; set; }
        public int TotalPassed { get; set; }
        public int TotalFailed { get; set; }
        public int UniqueSerials { get; set; }
        public int UniqueOperators { get; set; }
        public decimal PassRatePercent { get; set; }
        public decimal AvgValidationsPerSerial { get; set; }
    }

    public class MonthlyMetric
    {
        public int Year { get; set; }
        public int Month { get; set; }
        public DateTime MonthStart { get; set; }
        public DateTime MonthEnd { get; set; }
        public int TotalValidations { get; set; }
        public int TotalPassed { get; set; }
        public int TotalFailed { get; set; }
        public int UniqueSerials { get; set; }
        public int UniqueOperators { get; set; }
        public decimal PassRatePercent { get; set; }
        public decimal AvgValidationsPerSerial { get; set; }
    }

    public class SerialTrackingItem
    {
        public string SerialNumber { get; set; }
        public string CatalogNumber { get; set; }
        public string Workcell { get; set; }
        public int ValidationCount { get; set; }
        public string CurrentStatus { get; set; }
        public DateTime? LastValidationTime { get; set; }
        public int PassCount { get; set; }
        public int FailCount { get; set; }
        public string Operators { get; set; }
    }

    public class ValidationHistoryItem
    {
        public DateTime ValidationTime { get; set; }
        public string OperatorName { get; set; }
        public string OperatorENumber { get; set; }
        public string MaterialScanned { get; set; }
        public string MaterialExpected { get; set; }
        public bool IsMatch { get; set; }
        public string Workcell { get; set; }
        public string ValidationResult { get; set; }
        public int AttemptNumber { get; set; }
        public bool IsFirstAttempt { get; set; }
        public bool IsLatestAttempt { get; set; }
    }

    public class TestedVsValidatedMetrics
    {
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public int TotalTested { get; set; }
        public int TotalValidated { get; set; }
        public int TotalPending { get; set; }
        public decimal OverallValidationRate { get; set; }
        public Dictionary<string, WorkcellMetrics> ByWorkcell { get; set; }
    }

    public class WorkcellMetrics
    {
        public string Workcell { get; set; }
        public int TestedCount { get; set; }
        public int ValidatedCount { get; set; }
        public int PendingCount { get; set; }
        public decimal ValidationRate { get; set; }
        public List<string> TestedSerials { get; set; }
        public List<string> ValidatedSerials { get; set; }
    }

    public class ValidationRecord
    {
        public string SerialNumber { get; set; }
        public string Workcell { get; set; }
        public bool IsMatch { get; set; }
        public DateTime ValidationTime { get; set; }
    }

    public class TestedUnitTimeline
    {
        public string SerialNumber { get; set; }
        public string PartNumber { get; set; }
        public string Workcell { get; set; }
        public DateTime TestDate { get; set; }
        public string TestResult { get; set; }
        public string LastValidatorName { get; set; }
        public List<ValidationAttempt> ValidationAttempts { get; set; }
    }

    /// <summary>
    /// Represents a single validation attempt for a serial number
    /// </summary>
    public class ValidationAttempt
    {
        public int AttemptNumber { get; set; }
        public DateTime ValidationTime { get; set; }
        public string Result { get; set; }
        public string OperatorName { get; set; }
        public string ScannedLabel { get; set; }
        public bool IsMatch { get; set; }
    }

    #endregion
}
