using System;
using System.Collections.Generic;
using System.Configuration;
using System.Diagnostics;
using System.IO;
using System.Text;
using System.Xml.Linq;
using HipotTestApp.Models;

namespace HipotTestApp.Data
{
    /// <summary>
    /// Helper class for uploading test results to TDM (Test Data Management) system.
    /// Generates XML file in TDM format and calls UploadXmlTestResults.exe to upload.
    /// Configuration is read from App.config appSettings.
    /// </summary>
    public class TdmHelper
    {
        #region TDM Station Configuration (from App.config)
        
        /// <summary>TDM Line Name (e.g., "Phoenix")</summary>
        public string LineName { get; set; }
        
        /// <summary>TDM Parent Work Station (e.g., "Phoenix Hipot Test")</summary>
        public string ParentWorkStation { get; set; }
        
        /// <summary>TDM Work Station / Child Station (e.g., "Phoenix Hipot Test - 1")</summary>
        public string WorkstationName { get; set; }
        
        /// <summary>Shift Name (e.g., "Shift 1")</summary>
        public string ShiftName { get; set; }
        
        /// <summary>Test Sequence Name (e.g., "Hipot_GND_ACW")</summary>
        public string TestSequenceName { get; set; }
        
        /// <summary>Whether TDM upload is enabled</summary>
        public bool Enabled { get; set; }
        
        #endregion

        #region Paths
        
        private readonly string _applicationPath;
        private readonly string _tdmFolderPath;
        private readonly string _pendingFolderPath;
        private readonly string _uploadExePath;
        
        #endregion

        #region Error Handling
        
        public string LastError { get; private set; }
        public int LastExitCode { get; private set; }
        
        /// <summary>
        /// TDM Upload exit codes
        /// </summary>
        public static class ExitCodes
        {
            public const int Success = 0;
            public const int XmlFilePathRequired = 1;
            public const int XmlFileNotFound = 2;
            public const int XmlFileCannotOpen = 3;
            public const int XmlFileCannotRead = 4;
            public const int ServiceUrlMissing = 5;
            public const int XmlFileEmpty = 6;
            public const int XmlFileCorrupted = 7;
            public const int WebserviceNotAvailable = 8;
            public const int UploadFailed = 9;
            public const int SaveResultsFailed = 10;
            public const int InstructionNameBlank = 11;
            public const int SerialNumberBlank = 12;
            public const int WorkStationBlank = 13;
            public const int ParentWorkStationBlank = 14;
            public const int LineNameBlank = 15;
            public const int StatusBlank = 16;
            public const int TestSequenceNameBlank = 17;
            public const int CatalogNumberBlank = 18;
        }
        
        #endregion

        #region Constructor
        
        public TdmHelper()
        {
            _applicationPath = AppDomain.CurrentDomain.BaseDirectory;
            _tdmFolderPath = Path.Combine(_applicationPath, "TDM");
            _pendingFolderPath = Path.Combine(_applicationPath, "Pending");
            _uploadExePath = Path.Combine(_tdmFolderPath, "UploadXmlTestResults.exe");
            
            // Load TDM configuration from App.config
            LoadConfiguration();
            
            // Ensure Pending folder exists
            if (!Directory.Exists(_pendingFolderPath))
            {
                Directory.CreateDirectory(_pendingFolderPath);
            }
        }
        
        /// <summary>
        /// Loads TDM configuration from App.config appSettings.
        /// </summary>
        private void LoadConfiguration()
        {
            // Read settings from App.config with defaults
            LineName = ConfigurationManager.AppSettings["TDM_LineName"] ?? "Phoenix";
            ParentWorkStation = ConfigurationManager.AppSettings["TDM_ParentWorkStation"] ?? "Phoenix Hipot Test";
            WorkstationName = ConfigurationManager.AppSettings["TDM_WorkstationName"] ?? "Phoenix Hipot Test - 1";
            ShiftName = ConfigurationManager.AppSettings["TDM_ShiftName"] ?? "Shift 1";
            TestSequenceName = ConfigurationManager.AppSettings["TDM_TestSequenceName"] ?? "Hipot_GND_ACW";
            
            // Check if TDM is enabled (default to true)
            string enabledStr = ConfigurationManager.AppSettings["TDM_Enabled"];
            Enabled = string.IsNullOrEmpty(enabledStr) || enabledStr.Equals("true", StringComparison.OrdinalIgnoreCase);
        }
        
        #endregion

        #region Public Methods
        
        /// <summary>
        /// Uploads a Hipot test result to TDM.
        /// Generates XML file and calls UploadXmlTestResults.exe.
        /// </summary>
        /// <param name="result">The test result to upload</param>
        /// <returns>True if successful, false otherwise</returns>
        public bool UploadHipotTestResult(HipotTestResult result)
        {
            try
            {
                // Check if TDM is enabled
                if (!Enabled)
                {
                    LastError = "TDM upload is disabled in configuration";
                    return false;
                }
                
                // Validate TDM folder exists
                if (!Directory.Exists(_tdmFolderPath))
                {
                    LastError = $"TDM folder not found: {_tdmFolderPath}";
                    return false;
                }
                
                // Validate upload executable exists
                if (!File.Exists(_uploadExePath))
                {
                    LastError = $"TDM upload executable not found: {_uploadExePath}";
                    return false;
                }
                
                // Generate XML content
                string xmlContent = GenerateTdmXml(result);
                if (string.IsNullOrEmpty(xmlContent))
                {
                    return false; // LastError already set
                }
                
                // Write XML to pending folder
                string fileName = $"{result.SerialNumber}_{DateTime.Now:yyyy_MM_dd_HHmmss}.xml";
                string xmlFilePath = Path.Combine(_pendingFolderPath, fileName);
                
                File.WriteAllText(xmlFilePath, xmlContent, Encoding.UTF8);
                
                // Upload to TDM
                bool uploadSuccess = ExecuteUpload(xmlFilePath);
                
                if (uploadSuccess)
                {
                    // Delete the XML file after successful upload
                    try
                    {
                        File.Delete(xmlFilePath);
                    }
                    catch
                    {
                        // Ignore delete errors - file was uploaded successfully
                    }
                }
                
                return uploadSuccess;
            }
            catch (Exception ex)
            {
                LastError = $"TDM upload error: {ex.Message}";
                return false;
            }
        }
        
        /// <summary>
        /// Uploads any pending XML files that failed to upload previously.
        /// </summary>
        /// <returns>Number of files successfully uploaded</returns>
        public int UploadPendingFiles()
        {
            int successCount = 0;
            
            try
            {
                if (!Directory.Exists(_pendingFolderPath))
                    return 0;
                
                var xmlFiles = Directory.GetFiles(_pendingFolderPath, "*.xml");
                
                foreach (var xmlFile in xmlFiles)
                {
                    if (ExecuteUpload(xmlFile))
                    {
                        try
                        {
                            File.Delete(xmlFile);
                        }
                        catch { }
                        successCount++;
                    }
                }
            }
            catch (Exception ex)
            {
                LastError = $"Error uploading pending files: {ex.Message}";
            }
            
            return successCount;
        }
        
        /// <summary>
        /// Gets the error message for a TDM exit code.
        /// </summary>
        public static string GetExitCodeMessage(int exitCode)
        {
            switch (exitCode)
            {
                case ExitCodes.Success: return "Success - Test results transferred to TDM";
                case ExitCodes.XmlFilePathRequired: return "XML file and path is required";
                case ExitCodes.XmlFileNotFound: return "XML file was not found";
                case ExitCodes.XmlFileCannotOpen: return "XML file cannot be opened";
                case ExitCodes.XmlFileCannotRead: return "XML file cannot be read";
                case ExitCodes.ServiceUrlMissing: return "Service URL is missing from configuration file";
                case ExitCodes.XmlFileEmpty: return "XML file is empty";
                case ExitCodes.XmlFileCorrupted: return "XML file structure is not correct or corrupted";
                case ExitCodes.WebserviceNotAvailable: return "Webservice is not available";
                case ExitCodes.UploadFailed: return "Uploading test results failed - PCaT web service not available";
                case ExitCodes.SaveResultsFailed: return "Error while saving test results - SQL db error or network timeout";
                case ExitCodes.InstructionNameBlank: return "Instruction Name cannot be blank";
                case ExitCodes.SerialNumberBlank: return "Serial Number cannot be blank";
                case ExitCodes.WorkStationBlank: return "Work Station cannot be blank";
                case ExitCodes.ParentWorkStationBlank: return "Parent Work Station cannot be blank";
                case ExitCodes.LineNameBlank: return "Line Name cannot be blank";
                case ExitCodes.StatusBlank: return "Status cannot be blank";
                case ExitCodes.TestSequenceNameBlank: return "Test Sequence Name cannot be blank";
                case ExitCodes.CatalogNumberBlank: return "Catalog Number cannot be blank";
                default: return $"Unknown error code: {exitCode}";
            }
        }
        
        #endregion

        #region Private Methods
        
        /// <summary>
        /// Generates TDM-formatted XML for a Hipot test result.
        /// </summary>
        private string GenerateTdmXml(HipotTestResult result)
        {
            try
            {
                var testResults = new List<XElement>();
                int sequenceNumber = 0;
                
                string startTime = result.TestDateTime.ToString("yyyy-MM-dd\\THH:mm:ss.fff");
                string catalogNumber = result.PartNumber ?? "HIPOT-TEST";
                string serialNumber = result.SerialNumber;
                string operatorName = result.OperatorENumber ?? "Unknown";
                
                // Test Result 1: Ground Bond Test
                if (result.GroundBondTest != null)
                {
                    sequenceNumber++;
                    var gndResult = CreateTestResultElement(
                        instructionName: "Ground_Bond_Test",
                        serialNumber: serialNumber,
                        catalogNumber: catalogNumber,
                        operatorName: operatorName,
                        testSequenceName: TestSequenceName,
                        startTime: startTime,
                        endTime: result.TestDateTime.AddSeconds(3).ToString("yyyy-MM-dd\\THH:mm:ss.fff"),
                        sequenceNumber: sequenceNumber,
                        result: result.GroundBondTest.Resistance_mOhm?.ToString("F2") ?? "0",
                        status: result.GroundBondTest.Result == "PASS" ? "Passed" : "Failed",
                        upperLimit: result.GroundBondTest.HiLimit_mOhm ?? 0,
                        lowerLimit: result.GroundBondTest.LoLimit_mOhm ?? 0,
                        testUnits: "mOhm",
                        testComments: result.GroundBondTest.RawStatus ?? ""
                    );
                    
                    // Add Ground Bond parameters
                    var gndParams = new XElement("Parameters");
                    AddParameter(gndParams, "Current_A", result.GroundBondTest.Current_A?.ToString("F2") ?? "0", "A");
                    AddParameter(gndParams, "Resistance_mOhm", result.GroundBondTest.Resistance_mOhm?.ToString("F2") ?? "0", "mOhm");
                    AddParameter(gndParams, "DwellTime_s", result.GroundBondTest.DwellTime_s?.ToString("F1") ?? "0", "s");
                    AddParameter(gndParams, "HiLimit_mOhm", result.GroundBondTest.HiLimit_mOhm?.ToString("F2") ?? "0", "mOhm");
                    AddParameter(gndParams, "LoLimit_mOhm", result.GroundBondTest.LoLimit_mOhm?.ToString("F2") ?? "0", "mOhm");
                    if (gndParams.HasElements)
                        gndResult.Add(gndParams);
                    
                    testResults.Add(gndResult);
                }
                
                // Test Result 2: AC Withstand Test
                if (result.ACWithstandTest != null)
                {
                    sequenceNumber++;
                    var acwResult = CreateTestResultElement(
                        instructionName: "AC_Withstand_Test",
                        serialNumber: serialNumber,
                        catalogNumber: catalogNumber,
                        operatorName: operatorName,
                        testSequenceName: TestSequenceName,
                        startTime: startTime,
                        endTime: result.TestDateTime.AddSeconds(70).ToString("yyyy-MM-dd\\THH:mm:ss.fff"),
                        sequenceNumber: sequenceNumber,
                        result: result.ACWithstandTest.LeakageCurrent_mA?.ToString("F3") ?? "0",
                        status: result.ACWithstandTest.Result == "PASS" ? "Passed" : "Failed",
                        upperLimit: result.ACWithstandTest.HiLimit_mA ?? 0,
                        lowerLimit: result.ACWithstandTest.LoLimit_mA ?? 0,
                        testUnits: "mA",
                        testComments: result.ACWithstandTest.RawStatus ?? ""
                    );
                    
                    // Add AC Withstand parameters
                    var acwParams = new XElement("Parameters");
                    AddParameter(acwParams, "Voltage_V", result.ACWithstandTest.Voltage_V?.ToString("F0") ?? "0", "V");
                    AddParameter(acwParams, "Leakage_mA", result.ACWithstandTest.LeakageCurrent_mA?.ToString("F3") ?? "0", "mA");
                    AddParameter(acwParams, "HiLimit_mA", result.ACWithstandTest.HiLimit_mA?.ToString("F2") ?? "0", "mA");
                    AddParameter(acwParams, "LoLimit_mA", result.ACWithstandTest.LoLimit_mA?.ToString("F3") ?? "0", "mA");
                    AddParameter(acwParams, "RampUp_s", result.ACWithstandTest.RampUp_s?.ToString("F1") ?? "0", "s");
                    AddParameter(acwParams, "DwellTime_s", result.ACWithstandTest.DwellTime_s?.ToString("F1") ?? "0", "s");
                    AddParameter(acwParams, "RampDown_s", result.ACWithstandTest.RampDown_s?.ToString("F1") ?? "0", "s");
                    if (acwParams.HasElements)
                        acwResult.Add(acwParams);
                    
                    testResults.Add(acwResult);
                }
                
                // Test Result 3: Overall Result (required by TDM)
                sequenceNumber++;
                var overallResult = CreateTestResultElement(
                    instructionName: $"{WorkstationName}_OverallResult",
                    serialNumber: serialNumber,
                    catalogNumber: catalogNumber,
                    operatorName: operatorName,
                    testSequenceName: TestSequenceName,
                    startTime: startTime,
                    endTime: DateTime.Now.ToString("yyyy-MM-dd\\THH:mm:ss.fff"),
                    sequenceNumber: sequenceNumber,
                    result: "",
                    status: result.OverallResult == "PASS" ? "Passed" : "Failed",
                    upperLimit: 0,
                    lowerLimit: 0,
                    testUnits: "",
                    testComments: result.FailureReason ?? ""
                );
                testResults.Add(overallResult);
                
                // Build final XML
                var sb = new StringBuilder();
                sb.AppendLine("<?xml version=\"1.0\" encoding=\"utf-8\"?>");
                sb.AppendLine("<TDM_TestResults xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\">");
                sb.AppendLine("  <TestResults>");
                
                foreach (var testResult in testResults)
                {
                    sb.AppendLine(testResult.ToString());
                }
                
                sb.AppendLine("  </TestResults>");
                sb.AppendLine("</TDM_TestResults>");
                
                return sb.ToString();
            }
            catch (Exception ex)
            {
                LastError = $"Error generating TDM XML: {ex.Message}";
                return null;
            }
        }
        
        /// <summary>
        /// Creates a single TestResult XML element.
        /// </summary>
        private XElement CreateTestResultElement(
            string instructionName,
            string serialNumber,
            string catalogNumber,
            string operatorName,
            string testSequenceName,
            string startTime,
            string endTime,
            int sequenceNumber,
            string result,
            string status,
            decimal upperLimit,
            decimal lowerLimit,
            string testUnits,
            string testComments)
        {
            var element = new XElement("TestResult",
                new XElement("UpperTestLimit", upperLimit.ToString("F3")),
                new XElement("LowerTestLimit", lowerLimit.ToString("F3")),
                new XElement("UpperControlLimit", "0.000"),
                new XElement("LowerControlLimit", "0.000"),
                new XElement("TestComments", testComments ?? ""),
                new XElement("TestUnits", testUnits ?? ""),
                new XElement("InstructionName", instructionName),
                new XElement("SerialNumber", serialNumber),
                new XElement("WorkstationName", WorkstationName),
                new XElement("ParentWorkStation", ParentWorkStation),
                new XElement("Results", result ?? ""),
                new XElement("ResultType", "1"),
                new XElement("ShiftName", ShiftName),
                new XElement("OperatorName", operatorName),
                new XElement("LineName", LineName),
                new XElement("Status", status),
                new XElement("TestSequenceName", testSequenceName),
                new XElement("CatalogNumber", catalogNumber),
                new XElement("SequenceNumber", sequenceNumber.ToString()),
                new XElement("StartTime", startTime),
                new XElement("EndTime", endTime)
            );
            
            return element;
        }
        
        /// <summary>
        /// Adds a parameter to the Parameters element.
        /// </summary>
        private void AddParameter(XElement parametersElement, string key, string value, string unit)
        {
            var param = new XElement("TestResultParameter",
                new XElement("Parameter_Key", key),
                new XElement("Parameter_Value", value),
                new XElement("Parameter_Unit", unit)
            );
            parametersElement.Add(param);
        }
        
        /// <summary>
        /// Executes the TDM upload executable.
        /// </summary>
        private bool ExecuteUpload(string xmlFilePath)
        {
            try
            {
                using (var process = new Process())
                {
                    process.StartInfo.FileName = _uploadExePath;
                    process.StartInfo.Arguments = $"\"{xmlFilePath}\"";
                    process.StartInfo.UseShellExecute = false;
                    process.StartInfo.CreateNoWindow = true;
                    process.StartInfo.RedirectStandardOutput = true;
                    process.StartInfo.RedirectStandardError = true;
                    process.StartInfo.WorkingDirectory = _tdmFolderPath;
                    
                    process.Start();
                    
                    string output = process.StandardOutput.ReadToEnd();
                    string error = process.StandardError.ReadToEnd();
                    
                    process.WaitForExit(30000); // 30 second timeout
                    
                    LastExitCode = process.ExitCode;
                    
                    if (process.ExitCode == ExitCodes.Success)
                    {
                        LastError = null;
                        return true;
                    }
                    else
                    {
                        LastError = $"TDM upload failed (code {process.ExitCode}): {GetExitCodeMessage(process.ExitCode)}";
                        if (!string.IsNullOrEmpty(error))
                            LastError += $" - {error}";
                        return false;
                    }
                }
            }
            catch (Exception ex)
            {
                LastError = $"Error executing TDM upload: {ex.Message}";
                LastExitCode = -1;
                return false;
            }
        }
        
        #endregion
    }
}
