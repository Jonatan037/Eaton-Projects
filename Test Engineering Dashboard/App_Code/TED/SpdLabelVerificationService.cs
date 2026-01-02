using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.OleDb;
using System.IO;
using System.Linq;
using System.Web;

namespace TED
{
    /// <summary>
    /// Handles reads from the Production.mdb Access database and the master label Excel workbook
    /// to support SPD label verification workflows.
    /// </summary>
    public class SpdLabelVerificationService
    {
        private readonly string _accessDbPath;
        private readonly string _excelPath;
        private readonly string _excelSheet;
        private readonly string _accessProvider;
        private readonly string _accessTable;
        private readonly string _serialField;
        private readonly string _statusField;
        private readonly string _passValue;
        private readonly string _catalogField;
        private readonly string _orderBy;
        private readonly string _excelCatalogField;
        private readonly string _excelMaterialField;
        private readonly string _resultField;
        private readonly string _resultPassValue;
        private readonly string _workcellField;

        public SpdLabelVerificationService()
        {
            var cfg = ConfigurationManager.AppSettings;
            _accessDbPath = cfg["SPD.AccessDbPath"];
            _excelPath = cfg["SPD.ExcelPath"];
            _excelSheet = string.IsNullOrWhiteSpace(cfg["SPD.ExcelSheet"]) ? "SPD$" : cfg["SPD.ExcelSheet"];
            _accessProvider = string.IsNullOrWhiteSpace(cfg["SPD.AccessDb.Provider"]) ? "Microsoft.ACE.OLEDB.12.0" : cfg["SPD.AccessDb.Provider"];
            _accessTable = string.IsNullOrWhiteSpace(cfg["SPD.AccessDb.Table"]) ? "TestResults" : cfg["SPD.AccessDb.Table"];
            _serialField = string.IsNullOrWhiteSpace(cfg["SPD.AccessDb.SerialField"]) ? "SerialNumber" : cfg["SPD.AccessDb.SerialField"];
            _statusField = cfg["SPD.AccessDb.StatusField"] ?? "TestStatus";
            _passValue = cfg["SPD.AccessDb.PassValue"] ?? "PASS";
            _catalogField = string.IsNullOrWhiteSpace(cfg["SPD.AccessDb.CatalogField"]) ? "CatalogNumber" : cfg["SPD.AccessDb.CatalogField"];
            _orderBy = cfg["SPD.AccessDb.OrderBy"] ?? "[StartTime] DESC";
            _excelCatalogField = string.IsNullOrWhiteSpace(cfg["SPD.Excel.CatalogField"]) ? "CatalogNumber" : cfg["SPD.Excel.CatalogField"];
            _excelMaterialField = string.IsNullOrWhiteSpace(cfg["SPD.Excel.MaterialField"]) ? "MaterialNumber" : cfg["SPD.Excel.MaterialField"];
            _resultField = string.IsNullOrWhiteSpace(cfg["SPD.AccessDb.ResultField"]) ? "Result" : cfg["SPD.AccessDb.ResultField"];
            _resultPassValue = string.IsNullOrWhiteSpace(cfg["SPD.AccessDb.ResultPassValue"]) ? "1" : cfg["SPD.AccessDb.ResultPassValue"];
            _workcellField = string.IsNullOrWhiteSpace(cfg["SPD.AccessDb.WorkcellField"]) ? "Workcell" : cfg["SPD.AccessDb.WorkcellField"];
        }

        public OperationResult<TestRecordResult> GetLatestPassedTest(string serialNumber)
        {
            if (string.IsNullOrWhiteSpace(serialNumber))
            {
                return OperationResult<TestRecordResult>.Fail("Serial number is required.");
            }

            var dbPath = ResolvePath(_accessDbPath);
            if (string.IsNullOrWhiteSpace(dbPath))
            {
                return OperationResult<TestRecordResult>.Fail("SPD Access database path is not configured.");
            }
            if (!File.Exists(dbPath))
            {
                return OperationResult<TestRecordResult>.Fail(string.Format("Access database not found at {0}", dbPath));
            }

            try
            {
                var connString = string.Format("Provider={0};Data Source={1};Persist Security Info=False;", _accessProvider, dbPath);
                var query = string.Format("SELECT TOP 1 * FROM [{0}] WHERE UCASE([{1}]) = ?", _accessTable, _serialField);
                bool filterStatus = !string.IsNullOrWhiteSpace(_statusField) && !string.IsNullOrWhiteSpace(_passValue);
                if (filterStatus)
                {
                    query += string.Format(" AND UCASE([{0}]) = ?", _statusField);
                }
                // Filter by workcell - only Integrated or Sidemount
                if (!string.IsNullOrWhiteSpace(_workcellField))
                {
                    query += string.Format(" AND ([{0}] = 'Integrated' OR [{0}] = 'Sidemount')", _workcellField);
                }
                if (!string.IsNullOrWhiteSpace(_orderBy))
                {
                    query += " ORDER BY " + _orderBy;
                }

                using (var conn = new OleDbConnection(connString))
                using (var cmd = new OleDbCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@serial", serialNumber.Trim().ToUpperInvariant());
                    if (filterStatus)
                    {
                        cmd.Parameters.AddWithValue("@status", _passValue.Trim().ToUpperInvariant());
                    }

                    conn.Open();
                    using (var reader = cmd.ExecuteReader(CommandBehavior.SingleRow))
                    {
                        if (reader == null || !reader.Read())
                        {
                            return OperationResult<TestRecordResult>.Fail("No passed test record was found for that serial number.");
                        }

                        var catalog = SafeGetString(reader, _catalogField);
                        if (string.IsNullOrWhiteSpace(catalog))
                        {
                            return OperationResult<TestRecordResult>.Fail("Catalog number is missing in the test record.");
                        }

                        string normalizedResult = null;
                        if (!string.IsNullOrWhiteSpace(_resultField))
                        {
                            var resultFlag = SafeGetString(reader, _resultField);
                            if (!string.IsNullOrWhiteSpace(resultFlag))
                            {
                                normalizedResult = resultFlag.Trim();
                            }
                        }

                        if (string.IsNullOrEmpty(normalizedResult))
                        {
                            bool statusIndicatesPass = false;
                            if (!string.IsNullOrWhiteSpace(_statusField) && !string.IsNullOrWhiteSpace(_passValue))
                            {
                                var statusValue = SafeGetString(reader, _statusField);
                                statusIndicatesPass = !string.IsNullOrWhiteSpace(statusValue) &&
                                    string.Equals(statusValue.Trim(), _passValue, StringComparison.OrdinalIgnoreCase);
                            }

                            if (!statusIndicatesPass)
                            {
                                return OperationResult<TestRecordResult>.Fail("Latest record is missing a Result flag.");
                            }
                        }
                        else if (!string.IsNullOrWhiteSpace(_resultPassValue) &&
                                 !string.Equals(normalizedResult, _resultPassValue, StringComparison.OrdinalIgnoreCase))
                        {
                            return OperationResult<TestRecordResult>.Fail("Latest test record for this serial is not a passing result.");
                        }

                        var result = new TestRecordResult
                        {
                            SerialNumber = SafeGetString(reader, _serialField) ?? serialNumber,
                            CatalogNumber = catalog.Trim(),
                            CompletedOn = SafeGetDate(reader, "CompletedOn") ?? SafeGetDate(reader, "TestDate") ?? SafeGetDate(reader, "DateTested"),
                            Operator = SafeGetString(reader, "Operator") ?? SafeGetString(reader, "TestedBy"),
                            Station = SafeGetString(reader, "Station") ?? SafeGetString(reader, "TestStation"),
                            Workcell = SafeGetString(reader, _workcellField)
                        };

                        return OperationResult<TestRecordResult>.Ok(result);
                    }
                }
            }
            catch (OleDbException ex)
            {
                var message = string.Format(
                    "Unable to read the Access database: {0} | Table={1}, SerialField={2}, StatusField={3}, CatalogField={4}",
                    ex.Message,
                    _accessTable,
                    _serialField,
                    _statusField,
                    _catalogField);
                System.Diagnostics.Trace.WriteLine("[SPD] " + message);
                return OperationResult<TestRecordResult>.Fail(message);
            }
            catch (Exception ex)
            {
                var message = "Unexpected error while reading the Access database: " + ex.Message;
                System.Diagnostics.Trace.WriteLine("[SPD] " + message);
                return OperationResult<TestRecordResult>.Fail(message);
            }
        }

        /// <summary>
        /// Gets aggregated test data using DataTable approach similar to Tracks Yields report.
        /// This is more efficient than reading individual records.
        /// </summary>
        public DataTable GetPassedTestsDataTable(DateTime startDate, DateTime endDate)
        {
            var dt = new DataTable();
            var dbPath = ResolvePath(_accessDbPath);
            
            if (string.IsNullOrWhiteSpace(dbPath))
            {
                System.Diagnostics.Trace.WriteLine("[SPD] Access database path is not configured");
                return dt;
            }
            
            if (!File.Exists(dbPath))
            {
                System.Diagnostics.Trace.WriteLine("[SPD] Access database not found at: " + dbPath);
                return dt;
            }

            try
            {
                var connString = string.Format("Provider={0};Data Source={1};Persist Security Info=False;", _accessProvider, dbPath);
                
                // Build aggregated query - filter by Result field (not Status which is empty)
                var query = string.Format(
                    "SELECT [{0}] AS Workcell, COUNT(*) AS TestedCount, COUNT(DISTINCT [{1}]) AS UniqueSerials " +
                    "FROM [{2}] " +
                    "WHERE [{3}] = {4} " +
                    "AND ([{0}] = 'Integrated' OR [{0}] = 'Sidemount') " +
                    "AND [StartTime] >= #{5:MM/dd/yyyy}# AND [StartTime] < #{6:MM/dd/yyyy}# " +
                    "GROUP BY [{0}]",
                    _workcellField,          // 0: Workcell
                    _serialField,            // 1: SerialNumber
                    _accessTable,            // 2: Index
                    _resultField,            // 3: Results
                    _resultPassValue,        // 4: 1
                    startDate,               // 5
                    endDate.AddDays(1)       // 6
                );

                System.Diagnostics.Trace.WriteLine("[SPD] Executing query: " + query);

                using (var conn = new OleDbConnection(connString))
                using (var adapter = new OleDbDataAdapter(query, conn))
                {
                    conn.Open();
                    adapter.Fill(dt);
                    System.Diagnostics.Trace.WriteLine(string.Format("[SPD] Query returned {0} rows", dt.Rows.Count));
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.WriteLine("[SPD] Error getting test data table: " + ex.Message);
                System.Diagnostics.Trace.WriteLine("[SPD] Stack trace: " + ex.StackTrace);
            }

            return dt;
        }

        /// <summary>
        /// Gets detailed list of unique serials that passed tests in the date range.
        /// Used for validation rate calculation.
        /// </summary>
        public List<TestRecordResult> GetPassedTestsForPeriod(DateTime startDate, DateTime endDate)
        {
            var results = new List<TestRecordResult>();
            var dbPath = ResolvePath(_accessDbPath);
            if (string.IsNullOrWhiteSpace(dbPath) || !File.Exists(dbPath))
            {
                System.Diagnostics.Trace.WriteLine("[SPD] GetPassedTestsForPeriod: Database not accessible");
                return results;
            }

            try
            {
                var connString = string.Format("Provider={0};Data Source={1};Persist Security Info=False;", _accessProvider, dbPath);
                
                // Simplified query - just get unique serials with Results=1 in the date range
                var query = string.Format(
                    "SELECT [{0}], [{1}], [{2}], [StartTime] " +
                    "FROM [{3}] " +
                    "WHERE [{4}] = {5} " +
                    "AND ([{2}] = 'Integrated' OR [{2}] = 'Sidemount') " +
                    "AND [StartTime] >= #{6:MM/dd/yyyy}# AND [StartTime] < #{7:MM/dd/yyyy}#",
                    _serialField,        // 0: SerialNumber
                    _catalogField,       // 1: PartNumber
                    _workcellField,      // 2: Workcell
                    _accessTable,        // 3: Index
                    _resultField,        // 4: Results
                    _resultPassValue,    // 5: 1
                    startDate,           // 6
                    endDate.AddDays(1)   // 7
                );

                System.Diagnostics.Trace.WriteLine("[SPD] GetPassedTestsForPeriod query: " + query);

                using (var conn = new OleDbConnection(connString))
                using (var cmd = new OleDbCommand(query, conn))
                {
                    conn.Open();
                    using (var reader = cmd.ExecuteReader())
                    {
                        int count = 0;
                        while (reader.Read())
                        {
                            var serial = SafeGetString(reader, _serialField);
                            var catalog = SafeGetString(reader, _catalogField);
                            var workcell = SafeGetString(reader, _workcellField);
                            var startTime = SafeGetDate(reader, "StartTime");

                            if (!string.IsNullOrWhiteSpace(serial) && 
                                !string.IsNullOrWhiteSpace(catalog) &&
                                (workcell == "Integrated" || workcell == "Sidemount"))
                            {
                                results.Add(new TestRecordResult
                                {
                                    SerialNumber = serial,
                                    CatalogNumber = catalog,
                                    Workcell = workcell,
                                    StartTime = startTime
                                });
                                count++;
                            }
                        }
                        System.Diagnostics.Trace.WriteLine(string.Format("[SPD] GetPassedTestsForPeriod returned {0} records", count));
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.WriteLine("[SPD] Error getting passed tests: " + ex.Message);
                System.Diagnostics.Trace.WriteLine("[SPD] Stack: " + ex.StackTrace);
            }

            return results;
        }

        public OperationResult<MaterialLookupResult> LookupMaterialNumber(string catalogNumber)
        {
            if (string.IsNullOrWhiteSpace(catalogNumber))
            {
                return OperationResult<MaterialLookupResult>.Fail("Catalog number is required before looking up the label file.");
            }

            var excelPath = ResolvePath(_excelPath);
            if (string.IsNullOrWhiteSpace(excelPath))
            {
                return OperationResult<MaterialLookupResult>.Fail("SPD label Excel path is not configured.");
            }
            if (!File.Exists(excelPath))
            {
                return OperationResult<MaterialLookupResult>.Fail(string.Format("Label Excel workbook not found at {0}", excelPath));
            }

            try
            {
                var sheetName = NormalizeSheetName(_excelSheet);
                var connString = string.Format(
                    "Provider=Microsoft.ACE.OLEDB.12.0;Data Source={0};Extended Properties=\"Excel 12.0 Xml;HDR=YES;IMEX=1\";",
                    excelPath);

                var query = string.Format("SELECT [{0}], [{1}] FROM [{2}] WHERE [{0}] = ?",
                    _excelCatalogField, _excelMaterialField, sheetName);

                using (var conn = new OleDbConnection(connString))
                using (var cmd = new OleDbCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@catalog", catalogNumber.Trim());
                    conn.Open();
                    using (var reader = cmd.ExecuteReader(CommandBehavior.SingleRow))
                    {
                        if (reader == null || !reader.Read())
                        {
                            return OperationResult<MaterialLookupResult>.Fail("Catalog number was not found in the label Excel workbook.");
                        }

                        var material = SafeGetString(reader, _excelMaterialField);
                        if (string.IsNullOrWhiteSpace(material))
                        {
                            return OperationResult<MaterialLookupResult>.Fail("Material number is blank in the label Excel workbook.");
                        }

                        var data = new MaterialLookupResult
                        {
                            CatalogNumber = SafeGetString(reader, _excelCatalogField) ?? catalogNumber,
                            MaterialNumber = material.Trim(),
                            SheetName = sheetName
                        };
                        return OperationResult<MaterialLookupResult>.Ok(data);
                    }
                }
            }
            catch (OleDbException ex)
            {
                return OperationResult<MaterialLookupResult>.Fail("Unable to read the Excel workbook: " + ex.Message);
            }
            catch (Exception ex)
            {
                return OperationResult<MaterialLookupResult>.Fail("Unexpected error while reading the Excel workbook: " + ex.Message);
            }
        }

        private static string ResolvePath(string path)
        {
            if (string.IsNullOrWhiteSpace(path)) return null;
            if (path.StartsWith("~/", StringComparison.Ordinal))
            {
                return HttpContext.Current != null ? HttpContext.Current.Server.MapPath(path) : null;
            }
            return path;
        }

        private static string NormalizeSheetName(string sheet)
        {
            if (string.IsNullOrWhiteSpace(sheet))
            {
                return "Sheet1$";
            }

            sheet = sheet.Trim();
            if (!sheet.EndsWith("$", StringComparison.Ordinal))
            {
                sheet += "$";
            }
            return sheet;
        }

        private static string SafeGetString(IDataRecord record, string fieldName)
        {
            if (record == null || string.IsNullOrWhiteSpace(fieldName)) return null;
            try
            {
                int ordinal = record.GetOrdinal(fieldName);
                if (record.IsDBNull(ordinal)) return null;
                return Convert.ToString(record.GetValue(ordinal));
            }
            catch (IndexOutOfRangeException)
            {
                return null;
            }
        }

        private static DateTime? SafeGetDate(IDataRecord record, string fieldName)
        {
            if (record == null || string.IsNullOrWhiteSpace(fieldName)) return null;
            try
            {
                int ordinal = record.GetOrdinal(fieldName);
                if (record.IsDBNull(ordinal)) return null;
                return Convert.ToDateTime(record.GetValue(ordinal));
            }
            catch (IndexOutOfRangeException)
            {
                return null;
            }
            catch (FormatException)
            {
                return null;
            }
        }

        public class OperationResult<T>
        {
            public bool Success { get; private set; }
            public string Error { get; private set; }
            public T Data { get; private set; }

            private OperationResult() { }

            public static OperationResult<T> Ok(T data)
            {
                return new OperationResult<T> { Success = true, Data = data };
            }

            public static OperationResult<T> Fail(string error)
            {
                return new OperationResult<T> { Success = false, Error = error };
            }
        }

        public class TestRecordResult
        {
            public string SerialNumber { get; set; }
            public string CatalogNumber { get; set; }
            public string PartNumber { get { return CatalogNumber; } set { CatalogNumber = value; } }
            public DateTime? CompletedOn { get; set; }
            public DateTime? StartTime { get; set; }
            public DateTime TestDate 
            { 
                get { return StartTime ?? CompletedOn ?? DateTime.MinValue; } 
            }
            public string Operator { get; set; }
            public string Station { get; set; }
            public string Workcell { get; set; }
        }

        public class MaterialLookupResult
        {
            public string CatalogNumber { get; set; }
            public string MaterialNumber { get; set; }
            public string SheetName { get; set; }
        }
    }
}
