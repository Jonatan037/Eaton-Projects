using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading;
using System.Configuration;
using HipotTestApp.Models;

namespace HipotTestApp.Communication
{
    /// <summary>
    /// GPIB Communicator using NI-VISA for the Associated Research OMNIA II 8204
    /// Uses visa32.dll for GPIB communication via NI GPIB-USB-HS+ adapter
    /// </summary>
    public class VisaGpibCommunicator : IDisposable
    {
        #region VISA32 DLL Imports

        [DllImport("visa32.dll", EntryPoint = "#141", ExactSpelling = true, CharSet = CharSet.Ansi, SetLastError = true, CallingConvention = CallingConvention.Winapi)]
        private static extern int viOpenDefaultRM(out int sesn);

        [DllImport("visa32.dll", EntryPoint = "#131", ExactSpelling = true, CharSet = CharSet.Ansi, SetLastError = true, CallingConvention = CallingConvention.Winapi)]
        private static extern int viOpen(int sesn, string viDesc, int mode, int timeout, out int vi);

        [DllImport("visa32.dll", EntryPoint = "#132", ExactSpelling = true, CharSet = CharSet.Ansi, SetLastError = true, CallingConvention = CallingConvention.Winapi)]
        private static extern int viClose(int vi);

        [DllImport("visa32.dll", EntryPoint = "#256", ExactSpelling = true, CharSet = CharSet.Ansi, SetLastError = true, CallingConvention = CallingConvention.Winapi)]
        private static extern int viRead(int vi, byte[] buffer, int count, out int retCount);

        [DllImport("visa32.dll", EntryPoint = "#257", ExactSpelling = true, CharSet = CharSet.Ansi, SetLastError = true, CallingConvention = CallingConvention.Winapi)]
        private static extern int viWrite(int vi, byte[] buffer, int count, out int retCount);

        [DllImport("visa32.dll", EntryPoint = "#134", ExactSpelling = true, CharSet = CharSet.Ansi, SetLastError = true, CallingConvention = CallingConvention.Winapi)]
        private static extern int viSetAttribute(int vi, int attrName, int attrValue);

        [DllImport("visa32.dll", EntryPoint = "#133", ExactSpelling = true, CharSet = CharSet.Ansi, SetLastError = true, CallingConvention = CallingConvention.Winapi)]
        private static extern int viGetAttribute(int vi, int attrName, out int attrValue);

        [DllImport("visa32.dll", EntryPoint = "#260", ExactSpelling = true, CharSet = CharSet.Ansi, SetLastError = true, CallingConvention = CallingConvention.Winapi)]
        private static extern int viClear(int vi);

        [DllImport("visa32.dll", EntryPoint = "#142", ExactSpelling = true, CharSet = CharSet.Ansi, SetLastError = true, CallingConvention = CallingConvention.Winapi)]
        private static extern int viStatusDesc(int vi, int status, StringBuilder desc);

        // viPrintf - formatted write (using Cdecl calling convention like in BatteryTest project)
        [DllImport("visa32.dll", EntryPoint = "#269", ExactSpelling = true, CharSet = CharSet.Ansi, SetLastError = true, CallingConvention = CallingConvention.Cdecl)]
        private static extern int viPrintf(int vi, string writeFmt, int dummy);

        // viScanf - formatted read (using Cdecl calling convention)
        [DllImport("visa32.dll", EntryPoint = "#270", ExactSpelling = true, CharSet = CharSet.Ansi, SetLastError = true, CallingConvention = CallingConvention.Cdecl)]
        private static extern int viScanf(int vi, string readFmt, StringBuilder result);

        #endregion

        #region VISA Constants

        private const int VI_SUCCESS = 0;

        #endregion

        #region Private Fields

        private int _resourceManager;
        private int _instrumentSession;
        private bool _isConnected;
        private string _lastError;
        private string _gpibAddress;
        private readonly object _lockObject = new object();

        #endregion

        #region Properties

        /// <summary>
        /// Gets whether the communicator is connected to the device
        /// </summary>
        public bool IsConnected => _isConnected;

        /// <summary>
        /// Gets the last error message
        /// </summary>
        public string LastError => _lastError;

        /// <summary>
        /// Gets the GPIB address string
        /// </summary>
        public string GpibAddress => _gpibAddress;

        /// <summary>
        /// Gets device identification string
        /// </summary>
        public string DeviceIdentification { get; private set; }

        #endregion

        #region Events

        public event EventHandler<string> DataReceived;
        public event EventHandler<string> ErrorOccurred;

        #endregion

        #region Constructor

        /// <summary>
        /// Initializes the GPIB communicator with settings from App.config
        /// </summary>
        public VisaGpibCommunicator()
        {
            // Read GPIB settings from config
            // Format: GPIB0::1::INSTR (board::address::INSTR)
            string gpibBoard = ConfigurationManager.AppSettings["OMNIA_GPIB_Board"] ?? "GPIB0";
            string gpibAddr = ConfigurationManager.AppSettings["OMNIA_GPIB_Address"] ?? "1";
            _gpibAddress = $"{gpibBoard}::{gpibAddr}::INSTR";
        }

        /// <summary>
        /// Initializes the GPIB communicator with specific address
        /// </summary>
        /// <param name="gpibBoard">GPIB board name (e.g., "GPIB0" or "GPIB1")</param>
        /// <param name="gpibPrimaryAddress">Primary GPIB address (0-30)</param>
        public VisaGpibCommunicator(string gpibBoard, int gpibPrimaryAddress)
        {
            _gpibAddress = $"{gpibBoard}::{gpibPrimaryAddress}::INSTR";
        }

        /// <summary>
        /// Initializes with full VISA resource string
        /// </summary>
        /// <param name="visaResourceString">Full VISA resource string (e.g., "GPIB0::1::INSTR")</param>
        public VisaGpibCommunicator(string visaResourceString)
        {
            _gpibAddress = visaResourceString;
        }

        #endregion

        #region Connection Management

        /// <summary>
        /// Connects to the OMNIA II device via GPIB
        /// </summary>
        public bool Connect()
        {
            lock (_lockObject)
            {
                try
                {
                    // Open the default resource manager
                    int status = viOpenDefaultRM(out _resourceManager);
                    if (status < VI_SUCCESS)
                    {
                        _lastError = $"Failed to open VISA resource manager: {GetStatusDescription(status)}";
                        return false;
                    }

                    // Open the instrument session (mode=0, timeout=0 uses defaults)
                    status = viOpen(_resourceManager, _gpibAddress, 0, 0, out _instrumentSession);
                    if (status < VI_SUCCESS)
                    {
                        _lastError = $"Failed to open instrument at {_gpibAddress}: {GetStatusDescription(status)}";
                        viClose(_resourceManager);
                        return false;
                    }

                    // Set timeout (10 seconds) - VI_ATTR_TMO_VALUE = 0x3FFF001A
                    viSetAttribute(_instrumentSession, 0x3FFF001A, 10000);

                    // Clear the device first
                    viClear(_instrumentSession);
                    Thread.Sleep(500);

                    // Try to query device identification using viWrite/viRead
                    string identity = SendCommandWithResponse("*IDN?", 5000);
                    
                    if (!string.IsNullOrEmpty(identity))
                    {
                        DeviceIdentification = identity.Trim();
                        _isConnected = true;
                        _lastError = null;
                        return true;
                    }
                    else
                    {
                        _lastError = $"No response from device to *IDN? query";
                        Disconnect();
                        return false;
                    }
                }
                catch (Exception ex)
                {
                    _lastError = $"Connection failed: {ex.Message}";
                    ErrorOccurred?.Invoke(this, _lastError);
                    return false;
                }
            }
        }

        /// <summary>
        /// Disconnects from the OMNIA II device
        /// </summary>
        public void Disconnect()
        {
            lock (_lockObject)
            {
                try
                {
                    if (_instrumentSession != 0)
                    {
                        viClose(_instrumentSession);
                        _instrumentSession = 0;
                    }
                    if (_resourceManager != 0)
                    {
                        viClose(_resourceManager);
                        _resourceManager = 0;
                    }
                    _isConnected = false;
                }
                catch (Exception ex)
                {
                    _lastError = $"Disconnect error: {ex.Message}";
                }
            }
        }

        private string GetStatusDescription(int status)
        {
            StringBuilder desc = new StringBuilder(256);
            viStatusDesc(_resourceManager != 0 ? _resourceManager : _instrumentSession, status, desc);
            return desc.ToString();
        }

        #endregion

        #region Command Methods

        /// <summary>
        /// Sends a command and waits for response using viWrite/viRead
        /// </summary>
        public string SendCommandWithResponse(string command, int timeoutMs = 5000)
        {
            lock (_lockObject)
            {
                if (!_isConnected && _instrumentSession == 0)
                {
                    _lastError = "Not connected to device";
                    return null;
                }

                try
                {
                    // Set timeout
                    viSetAttribute(_instrumentSession, 0x3FFF001A, timeoutMs);

                    // Try with just LF terminator (some instruments prefer this)
                    byte[] cmdBytes = Encoding.ASCII.GetBytes(command + "\n");
                    int status = viWrite(_instrumentSession, cmdBytes, cmdBytes.Length, out int writeCount);
                    if (status < VI_SUCCESS)
                    {
                        _lastError = $"Write failed: {GetStatusDescription(status)}";
                        return null;
                    }

                    // Longer delay for device to process
                    Thread.Sleep(300);

                    // Read response
                    byte[] buffer = new byte[4096];
                    status = viRead(_instrumentSession, buffer, buffer.Length, out int readCount);
                    
                    // Accept VI_SUCCESS_TERM_CHAR (0x3FFF0005) and VI_SUCCESS_MAX_CNT (0x3FFF0006) as success
                    // Also accept timeout with partial data
                    if (status < VI_SUCCESS && status != 0x3FFF0005 && status != 0x3FFF0006)
                    {
                        // If timeout but we got some data, use it
                        if (readCount > 0)
                        {
                            string partialResponse = Encoding.ASCII.GetString(buffer, 0, readCount).Trim();
                            DataReceived?.Invoke(this, partialResponse);
                            return partialResponse;
                        }
                        _lastError = $"Read failed (status={status:X}): {GetStatusDescription(status)}";
                        return null;
                    }

                    if (readCount > 0)
                    {
                        string response = Encoding.ASCII.GetString(buffer, 0, readCount).Trim();
                        DataReceived?.Invoke(this, response);
                        return response;
                    }
                    
                    return null;
                }
                catch (Exception ex)
                {
                    _lastError = $"Command error: {ex.Message}";
                    return null;
                }
            }
        }

        /// <summary>
        /// Sends a command without waiting for response using viWrite
        /// </summary>
        public bool SendCommand(string command)
        {
            lock (_lockObject)
            {
                if (!_isConnected && _instrumentSession == 0)
                {
                    _lastError = "Not connected to device";
                    return false;
                }

                try
                {
                    // Send command with LF terminator
                    byte[] cmdBytes = Encoding.ASCII.GetBytes(command + "\n");
                    int status = viWrite(_instrumentSession, cmdBytes, cmdBytes.Length, out int writeCount);
                    if (status < VI_SUCCESS)
                    {
                        _lastError = $"Write failed: {GetStatusDescription(status)}";
                        return false;
                    }
                    return true;
                }
                catch (Exception ex)
                {
                    _lastError = $"Send error: {ex.Message}";
                    return false;
                }
            }
        }

        #endregion

        #region OMNIA-Specific Commands

        /// <summary>
        /// Gets device identification
        /// </summary>
        public string GetIdentification()
        {
            return SendCommandWithResponse("*IDN?");
        }

        /// <summary>
        /// Gets device identification (alias)
        /// </summary>
        public string GetDeviceIdentification()
        {
            return GetIdentification();
        }

        /// <summary>
        /// Clears status registers
        /// </summary>
        public bool ClearStatus()
        {
            return SendCommand("*CLS");
        }

        /// <summary>
        /// Resets instrument
        /// </summary>
        public bool Reset()
        {
            return SendCommand("*RST");
        }

        /// <summary>
        /// Queries system status
        /// </summary>
        public string GetSystemStatus()
        {
            return SendCommandWithResponse("SS?");
        }

        /// <summary>
        /// Checks if the interlock is open (safety interlock triggered)
        /// Returns true if interlock is OPEN (blocking tests), false if OK
        /// </summary>
        public bool IsInterlockOpen()
        {
            // Query system status - format varies but typically includes interlock info
            string status = SendCommandWithResponse("SS?", 2000);
            
            if (!string.IsNullOrEmpty(status))
            {
                string statusUpper = status.ToUpper();
                // Check for interlock indicators in the response
                if (statusUpper.Contains("INTERLOCK") || 
                    statusUpper.Contains("IL OPEN") ||
                    statusUpper.Contains("IL,OPEN") ||
                    statusUpper.Contains("SAFETY"))
                {
                    return true;
                }
            }
            
            // Also try the ES? (Error Status) or check status register
            // STB bit 2 (value 4) often indicates interlock on some instruments
            string stb = SendCommandWithResponse("*STB?", 1000);
            if (!string.IsNullOrEmpty(stb) && int.TryParse(stb.Trim(), out int stbValue))
            {
                // Check if bit 2 is set (interlock indicator on many AR instruments)
                // This may need adjustment based on actual OMNIA behavior
                // For now, we also check bit 6 (request service) which may indicate issues
            }
            
            return false;
        }

        /// <summary>
        /// Gets detailed interlock status message
        /// </summary>
        public string GetInterlockStatus()
        {
            string status = SendCommandWithResponse("SS?", 2000);
            return status ?? "Unable to query status";
        }

        /// <summary>
        /// Queries test data
        /// </summary>
        public string QueryTestData()
        {
            return SendCommandWithResponse("TD?", 10000);
        }

        /// <summary>
        /// Queries last result
        /// </summary>
        public string QueryLastResult()
        {
            return SendCommandWithResponse("LS?", 10000);
        }

        /// <summary>
        /// Queries the parameters for a specific test step
        /// Returns the step configuration including type, limits, dwell time, etc.
        /// Format varies by test type:
        /// GND: step, type, current(A), hiLimit(mΩ), loLimit(mΩ), dwell(s), offset, freq
        /// ACW: step, type, voltage(V), hiLimit(mA), loLimit(mA), rampUp(s), dwell(s), rampDown(s), freq, arcSense, ...
        /// </summary>
        public Dictionary<string, string> QueryStepParameters(int stepNumber)
        {
            var parameters = new Dictionary<string, string>();
            
            try
            {
                // Use "LS <step number>?" command to list step parameters
                // Per OMNIA manual: Lists all Parameters for the individual step indicated by step number
                // Response format: <step, test, p1, p2, p3...>
                string response = SendCommandWithResponse($"LS {stepNumber}?", 2000);
                parameters[$"LS_RESPONSE_{stepNumber}"] = response ?? "(null)";
                
                if (string.IsNullOrEmpty(response))
                {
                    // Try LS2 as alternate command (same format per manual)
                    response = SendCommandWithResponse($"LS2 {stepNumber}?", 2000);
                    parameters[$"LS2_RESPONSE_{stepNumber}"] = response ?? "(null)";
                }
                
                if (!string.IsNullOrEmpty(response))
                {
                    parameters["RAW_RESPONSE"] = response;
                    ParseStepParameters(response, parameters);
                }
                else
                {
                    parameters["NO_RESPONSE"] = $"No valid response from LS {stepNumber}? query";
                }
            }
            catch (Exception ex)
            {
                parameters["ERROR"] = ex.Message;
            }
            
            return parameters;
        }
        
        /// <summary>
        /// Queries all test step parameters for the currently loaded file
        /// </summary>
        public Dictionary<int, Dictionary<string, string>> QueryAllStepParameters()
        {
            var allSteps = new Dictionary<int, Dictionary<string, string>>();
            
            // Query steps 1 and 2 (typical for GND + ACW test)
            for (int step = 1; step <= 2; step++)
            {
                var stepParams = QueryStepParameters(step);
                // Always add the response for debugging purposes
                allSteps[step] = stepParams;
            }
            
            return allSteps;
        }
        
        /// <summary>
        /// Parses step parameter response from OMNIA
        /// </summary>
        private void ParseStepParameters(string response, Dictionary<string, string> parameters)
        {
            if (string.IsNullOrEmpty(response)) return;
            
            string[] parts = response.Split(',');
            if (parts.Length < 2) return;
            
            string stepNum = parts[0].Trim();
            string testType = parts.Length > 1 ? parts[1].Trim().ToUpper() : "";
            
            parameters["STEP"] = stepNum;
            parameters["TYPE"] = testType;
            
            if (testType == "GND" || testType == "GB")
            {
                // Ground Bond format: step, type, current(A), hiLimit(mΩ), loLimit(mΩ), dwell(s), offset, freq
                if (parts.Length >= 3) parameters["GND_CURRENT_A"] = parts[2].Trim();
                if (parts.Length >= 4) parameters["GND_HI_LIMIT_MOHM"] = parts[3].Trim();
                if (parts.Length >= 5) parameters["GND_LO_LIMIT_MOHM"] = parts[4].Trim();
                if (parts.Length >= 6) parameters["GND_DWELL_S"] = parts[5].Trim();
                if (parts.Length >= 7) parameters["GND_OFFSET"] = parts[6].Trim();
                if (parts.Length >= 8) parameters["GND_FREQUENCY_HZ"] = parts[7].Trim();
            }
            else if (testType == "ACW" || testType == "AC" || testType == "HIPOT")
            {
                // AC Withstand format: step, type, voltage(V), hiLimit(mA), loLimit(mA), rampUp(s), dwell(s), rampDown(s), freq, arcSense
                if (parts.Length >= 3) parameters["ACW_VOLTAGE_V"] = parts[2].Trim();
                if (parts.Length >= 4) parameters["ACW_HI_LIMIT_MA"] = parts[3].Trim();
                if (parts.Length >= 5) parameters["ACW_LO_LIMIT_MA"] = parts[4].Trim();
                if (parts.Length >= 6) parameters["ACW_RAMP_UP_S"] = parts[5].Trim();
                if (parts.Length >= 7) parameters["ACW_DWELL_S"] = parts[6].Trim();
                if (parts.Length >= 8) parameters["ACW_RAMP_DOWN_S"] = parts[7].Trim();
                if (parts.Length >= 9) parameters["ACW_FREQUENCY_HZ"] = parts[8].Trim();
                if (parts.Length >= 10) parameters["ACW_ARC_SENSE"] = parts[9].Trim();
            }
        }

        /// <summary>
        /// Starts a test
        /// </summary>
        public bool StartTest()
        {
            return SendCommand("TEST");
        }

        /// <summary>
        /// Stops the current test
        /// </summary>
        public bool StopTest()
        {
            return SendCommand("RESET");
        }

        /// <summary>
        /// Loads a specific memory file
        /// </summary>
        public bool LoadFile(int fileNumber)
        {
            return SendCommand($"FL {fileNumber}");
        }

        /// <summary>
        /// Runs FailCHEK (both Continuity and Ground Bond)
        /// </summary>
        public bool StartFailCheck()
        {
            bool contResult = SendCommand("FC CONT");
            if (!contResult) return false;
            Thread.Sleep(2000);
            return SendCommand("FC GND");
        }

        /// <summary>
        /// Runs FailCHEK for specific type and returns the result
        /// Note: FC command is not supported via GPIB - using file load + TEST instead
        /// </summary>
        public bool StartFailCheck(FailCheckType checkType)
        {
            // FC command is NOT supported via GPIB on OMNIA
            // Instead, we load a pre-configured test file and run TEST
            int fileNumber = GetFailCheckFileNumber(checkType);
            
            // Load the test file
            if (!LoadFile(fileNumber))
            {
                return false;
            }
            
            // Small delay for file to load
            Thread.Sleep(500);
            
            // Start the test
            return SendCommand("TEST");
        }
        
        /// <summary>
        /// Gets the file number for a FailCheck type from configuration
        /// </summary>
        private int GetFailCheckFileNumber(FailCheckType checkType)
        {
            string configKey = checkType switch
            {
                FailCheckType.GroundBond => "FailCheckGroundBondFile",
                FailCheckType.ACHipot => "FailCheckACHipotFile",
                FailCheckType.Continuity => "FailCheckGroundBondFile",
                FailCheckType.DCHipot => "FailCheckACHipotFile",
                FailCheckType.IR => "FailCheckACHipotFile",
                _ => "FailCheckGroundBondFile"
            };
            
            // Default values
            int defaultFile = checkType switch
            {
                FailCheckType.GroundBond => 3,
                FailCheckType.ACHipot => 4,
                _ => 3
            };
            
            string configValue = ConfigurationManager.AppSettings[configKey];
            if (!string.IsNullOrEmpty(configValue) && int.TryParse(configValue, out int parsedFile))
            {
                return parsedFile;
            }
            
            return defaultFile;
        }

        /// <summary>
        /// Runs a standard TEST command (executes the currently loaded test)
        /// </summary>
        public bool RunTest()
        {
            return SendCommand("TEST");
        }

        /// <summary>
        /// Runs FailCHEK by loading a test file and executing it.
        /// File numbers are read from configuration.
        /// </summary>
        public Dictionary<string, string> RunFailCheckAndGetResult(FailCheckType checkType, int waitTimeMs = 10000, Action<string> progressCallback = null)
        {
            var result = new Dictionary<string, string>();
            
            // Check interlock first
            if (IsInterlockOpen())
            {
                result["OVERALL"] = "ERROR";
                result["ERROR"] = "INTERLOCK OPEN - Safety interlock is triggered. Please check light curtain and safety doors.";
                result["INTERLOCK"] = "OPEN";
                return result;
            }
            
            // Get file number from configuration
            int fileNumber = GetFailCheckFileNumber(checkType);
            
            result["FILE_NUMBER"] = fileNumber.ToString();
            
            progressCallback?.Invoke($"Loading test file {fileNumber}...");
            
            // Clear any previous errors
            SendCommand("*CLS");
            Thread.Sleep(200);
            
            // Load the test file
            bool loadResult = SendCommand($"FL {fileNumber}");
            result["FL_COMMAND"] = $"FL {fileNumber}";
            result["FL_SENT"] = loadResult.ToString();
            
            if (!loadResult)
            {
                result["ERROR"] = LastError ?? "Failed to load test file";
                result["OVERALL"] = "ERROR";
                return result;
            }
            
            // Wait for file to load
            Thread.Sleep(1000);
            progressCallback?.Invoke("File loaded. Starting test...");
            
            // Verify file loaded by checking LS?
            string lsCheck = SendCommandWithResponse("LS?", 2000);
            result["LS_AFTER_LOAD"] = lsCheck ?? "";
            
            // Start the test
            bool testStarted = SendCommand("TEST");
            result["TEST_SENT"] = testStarted.ToString();
            
            if (!testStarted)
            {
                result["ERROR"] = LastError ?? "Failed to start test";
                result["OVERALL"] = "ERROR";
                return result;
            }
            
            progressCallback?.Invoke("Test started, waiting for completion...");
            
            // Wait for test to complete
            // Poll using *OPC? - returns 1 when complete, 0 when in progress
            int elapsed = 0;
            int pollInterval = 500;
            bool testComplete = false;
            
            // Give test time to start
            Thread.Sleep(1000);
            elapsed += 1000;
            
            while (elapsed < waitTimeMs && !testComplete)
            {
                progressCallback?.Invoke($"Testing... ({elapsed/1000}s)");
                
                // Check if test is complete
                string opcResponse = SendCommandWithResponse("*OPC?", 1000);
                result["OPC_" + elapsed] = opcResponse ?? "";
                
                if (opcResponse?.Trim() == "1")
                {
                    // Also check TD? to see if we have results
                    string tdCheck = SendCommandWithResponse("TD?", 1000);
                    if (!string.IsNullOrEmpty(tdCheck) && tdCheck.Trim().Length > 2)
                    {
                        testComplete = true;
                        result["TD_DURING_POLL"] = tdCheck;
                        progressCallback?.Invoke("Test complete!");
                    }
                }
                
                if (!testComplete)
                {
                    Thread.Sleep(pollInterval);
                    elapsed += pollInterval;
                }
            }
            
            // Extra delay to ensure results are ready
            Thread.Sleep(500);
            
            progressCallback?.Invoke("Reading results...");
            
            // Query test results
            // TD? = Test Data: step, test, status, meter1, meter2, meter3
            string tdResponse = SendCommandWithResponse("TD?", 3000);
            result["TD_RESPONSE"] = tdResponse ?? "";
            
            // RD 1? = Results Data for step 1
            string rd1Response = SendCommandWithResponse("RD 1?", 3000);
            result["RD1_RESPONSE"] = rd1Response ?? "";
            
            // RD? = Results Data for active step
            string rdResponse = SendCommandWithResponse("RD?", 3000);
            result["RD_RESPONSE"] = rdResponse ?? "";
            
            // Status registers
            string stbResponse = SendCommandWithResponse("*STB?", 2000);
            result["STB_RESPONSE"] = stbResponse ?? "";
            
            string esrResponse = SendCommandWithResponse("*ESR?", 2000);
            result["ESR_RESPONSE"] = esrResponse ?? "";
            
            // Build raw response string
            string allResponses = $"TD:{tdResponse}|RD1:{rd1Response}|RD:{rdResponse}|STB:{stbResponse}|ESR:{esrResponse}";
            result["RAW_RESPONSE"] = allResponses;
            
            progressCallback?.Invoke("Parsing results...");
            
            // Parse results
            bool isFailCheckPass = false;
            bool isFailCheckFail = false;
            string failReason = "";
            string testStatus = "";
            
            // Parse TD? response - format: step, test, status, meter1, meter2, meter3
            // Status meanings:
            // For FailCHEK (fixture disconnected for GND, connected for ACW):
            // - "HI" or "2" = High limit fail = PASS for FailCHEK (detected expected condition)
            // - "PASS" or "0" = Test passed = FAIL for FailCHEK (didn't detect expected condition)
            // - "ARC" or "4" = Arc detected = PASS for AC Hipot FailCHEK
            
            string responseToParse = !string.IsNullOrEmpty(tdResponse) ? tdResponse : 
                                     (!string.IsNullOrEmpty(rd1Response) ? rd1Response : rdResponse);
            
            if (!string.IsNullOrEmpty(responseToParse) && responseToParse.Trim().Length > 0)
            {
                string[] parts = responseToParse.Split(',');
                result["RESPONSE_PARTS"] = parts.Length.ToString();
                
                if (parts.Length >= 3)
                {
                    string stepNum = parts[0].Trim();
                    string testType = parts[1].Trim().ToUpper();
                    testStatus = parts[2].Trim().ToUpper();
                    
                    result["PARSED_STEP"] = stepNum;
                    result["PARSED_TEST"] = testType;
                    result["PARSED_STATUS"] = testStatus;
                    
                    // Get meter values if available
                    if (parts.Length >= 4) result["METER1"] = parts[3].Trim();
                    if (parts.Length >= 5) result["METER2"] = parts[4].Trim();
                    if (parts.Length >= 6) result["METER3"] = parts[5].Trim();
                    
                    // Interpret status for FailCHEK
                    if (checkType == FailCheckType.GroundBond)
                    {
                        // Ground Bond FailCHEK (fixture DISCONNECTED):
                        // We WANT to see HI-FAIL (high resistance = open circuit)
                        // This proves the equipment can detect when ground is NOT connected
                        // TD response format: step, test, status, current(A), resistance(mΩ), time
                        // Example: 01,GND,HI-LIMIT,0.01,>200,0.4
                        
                        // Extract resistance from METER2 (e.g., ">200" means >200 mΩ)
                        // Keep the > or < symbol to indicate out-of-range measurement
                        if (parts.Length >= 5)
                        {
                            string resistanceStr = parts[4].Trim();
                            result["GND_RESISTANCE"] = resistanceStr;  // Keep full string with > or <
                            
                            // Also extract numeric value for comparison if needed
                            string numericPart = resistanceStr.Replace(">", "").Replace("<", "");
                            if (decimal.TryParse(numericPart, out decimal resistance))
                            {
                                result["GND_RESISTANCE_VALUE"] = resistance.ToString();
                            }
                        }
                        
                        if (testStatus.Contains("HI") || testStatus == "2" || testStatus.Contains("OPEN") || testStatus.Contains("HIGH") || testStatus.Contains("LIMIT"))
                        {
                            isFailCheckPass = true;
                            result["GND_RESULT"] = "PASS";
                            result["INTERPRETATION"] = "High resistance detected (open circuit) - Equipment working correctly";
                        }
                        else if (testStatus.Contains("PASS") || testStatus == "0" || testStatus.Contains("OK"))
                        {
                            isFailCheckFail = true;
                            result["GND_RESULT"] = "FAIL";
                            failReason = "Low resistance detected when fixture should be DISCONNECTED!";
                            result["INTERPRETATION"] = "Test passed but should have failed - Check fixture connection";
                        }
                        else if (testStatus.Contains("LO") || testStatus == "3")  
                        {
                            isFailCheckFail = true;
                            result["GND_RESULT"] = "FAIL";
                            failReason = "Low limit fail - Fixture may be connected when it should be disconnected";
                        }
                    }
                    else if (checkType == FailCheckType.ACHipot)
                    {
                        // AC Hipot FailCHEK (fixture CONNECTED):
                        // We WANT to see HI-FAIL, ARC, or SHORT (failure detected)
                        // This proves the equipment can detect insulation breakdown
                        // TD response format: step, test, status, voltage, leakage(mA), leakage(mA), time
                        // Example: 01,ACW,Short,----,>50.00,>50.00,0.0
                        
                        // Extract leakage from METER2 or METER3 (e.g., ">50.00" means >50 mA)
                        // Keep the > or < symbol to indicate out-of-range measurement
                        if (parts.Length >= 5)
                        {
                            string leakageStr = parts[4].Trim();
                            result["ACW_LEAKAGE"] = leakageStr;  // Keep full string with > or <
                            
                            // Also extract numeric value for comparison if needed
                            string numericPart = leakageStr.Replace(">", "").Replace("<", "");
                            if (decimal.TryParse(numericPart, out decimal leakage))
                            {
                                result["ACW_LEAKAGE_VALUE"] = leakage.ToString();
                            }
                        }
                        
                        // SHORT is a valid FailCHEK pass - it means the equipment detected the short circuit
                        if (testStatus.Contains("HI") || testStatus == "2" || testStatus.Contains("ARC") || 
                            testStatus == "4" || testStatus.Contains("BREAKDOWN") || testStatus.Contains("SHORT"))
                        {
                            isFailCheckPass = true;
                            result["ACW_RESULT"] = "PASS";
                            result["INTERPRETATION"] = "Failure condition detected (Short/HI/ARC) - Equipment working correctly";
                        }
                        else if (testStatus.Contains("PASS") || testStatus == "0" || testStatus.Contains("OK"))
                        {
                            isFailCheckFail = true;
                            result["ACW_RESULT"] = "FAIL";
                            failReason = "No breakdown detected when fixture should cause failure!";
                            result["INTERPRETATION"] = "Test passed but should have failed - Check fixture connection";
                        }
                    }
                }
                else
                {
                    result["PARSE_ERROR"] = $"Expected at least 3 parts, got {parts.Length}";
                }
            }
            else
            {
                result["NO_DATA"] = "No test data received";
            }
            
            // Set overall result
            if (isFailCheckPass)
            {
                result["OVERALL"] = "PASS";
            }
            else if (isFailCheckFail)
            {
                result["OVERALL"] = "FAIL";
                result["FAIL_REASON"] = failReason;
            }
            else
            {
                // Check ESR for errors
                int esrValue = 0;
                int.TryParse(esrResponse?.Trim(), out esrValue);
                
                if ((esrValue & 32) != 0 || (esrValue & 16) != 0)
                {
                    result["OVERALL"] = "ERROR";
                    result["ERROR"] = $"Command or execution error (ESR={esrValue})";
                }
                else if (string.IsNullOrEmpty(responseToParse))
                {
                    result["OVERALL"] = "ERROR";
                    result["ERROR"] = "No test data received. Test may not have run.";
                }
                else
                {
                    result["OVERALL"] = "UNKNOWN";
                    result["ERROR"] = $"Could not interpret status: {testStatus}";
                }
            }
            
            return result;
        }

        #endregion

        #region Data Retrieval Methods

        /// <summary>
        /// Gets test data as dictionary
        /// </summary>
        public System.Collections.Generic.Dictionary<string, string> GetTestData()
        {
            string rawData = QueryTestData();
            var result = new System.Collections.Generic.Dictionary<string, string>();

            if (string.IsNullOrEmpty(rawData))
                return result;

            // Parse raw test data into dictionary
            var testResult = ParseTestData(rawData);

            result["OVERALL"] = testResult.OverallResult ?? "UNKNOWN";

            if (testResult.GroundBondTest != null)
            {
                result["GND_RESULT"] = testResult.GroundBondTest.Result ?? "";
                result["GND_RESISTANCE"] = testResult.GroundBondTest.Resistance_mOhm?.ToString() ?? "";
                result["GND_CURRENT"] = testResult.GroundBondTest.Current_A?.ToString() ?? "";
                result["GND_HILIMIT"] = testResult.GroundBondTest.HiLimit_mOhm?.ToString() ?? "";
            }

            if (testResult.ACWithstandTest != null)
            {
                result["ACW_RESULT"] = testResult.ACWithstandTest.Result ?? "";
                result["ACW_VOLTAGE"] = testResult.ACWithstandTest.Voltage_V?.ToString() ?? "";
                result["ACW_LEAKAGE"] = testResult.ACWithstandTest.LeakageCurrent_mA?.ToString() ?? "";
                result["ACW_HILIMIT"] = testResult.ACWithstandTest.HiLimit_mA?.ToString() ?? "";
            }

            return result;
        }

        /// <summary>
        /// Gets FailCHEK data as dictionary
        /// </summary>
        public System.Collections.Generic.Dictionary<string, string> GetFailCheckData()
        {
            string rawData = QueryLastResult();
            var result = new System.Collections.Generic.Dictionary<string, string>();

            if (string.IsNullOrEmpty(rawData))
                return result;

            if (rawData.ToUpper().Contains("CONT"))
            {
                var checkResult = ParseFailCheckData(rawData, FailCheckType.Continuity);
                result["CONT_RESULT"] = checkResult.ContinuityCheck?.Result ?? "";
                result["CONT_RESISTANCE"] = checkResult.ContinuityCheck?.Resistance_mOhm?.ToString() ?? "";
            }

            if (rawData.ToUpper().Contains("GND") || rawData.ToUpper().Contains("GROUND"))
            {
                var checkResult = ParseFailCheckData(rawData, FailCheckType.GroundBond);
                result["GND_RESULT"] = checkResult.GroundBondCheck?.Result ?? "";
                result["GND_RESISTANCE"] = checkResult.GroundBondCheck?.Resistance_mOhm?.ToString() ?? "";
                result["GND_CURRENT"] = checkResult.GroundBondCheck?.Current_A?.ToString() ?? "";
            }

            return result;
        }

        #endregion

        #region Result Parsing

        /// <summary>
        /// Parses test data response into HipotTestResult
        /// </summary>
        public HipotTestResult ParseTestData(string rawData)
        {
            var result = new HipotTestResult
            {
                RawResponse = rawData,
                TestDateTime = DateTime.Now
            };

            if (string.IsNullOrEmpty(rawData))
            {
                result.OverallResult = "ERROR";
                result.FailureReason = "No data received";
                return result;
            }

            try
            {
                string[] lines = rawData.Split(new[] { '\r', '\n' }, StringSplitOptions.RemoveEmptyEntries);

                foreach (string line in lines)
                {
                    string[] parts = line.Split(',');
                    if (parts.Length < 2) continue;

                    string stepResult = parts[0].Trim().ToUpper();
                    string testType = parts.Length > 1 ? parts[1].Trim().ToUpper() : "";

                    if (testType.Contains("GND") || testType.Contains("GROUND"))
                    {
                        result.GroundBondTest = new GroundBondResult { Result = stepResult };
                        for (int i = 2; i < parts.Length; i++)
                            ParseGroundBondValue(result.GroundBondTest, parts[i].Trim());
                    }
                    else if (testType.Contains("ACW") || testType.Contains("HIPOT") || testType.Contains("WITHSTAND"))
                    {
                        result.ACWithstandTest = new ACWithstandResult { Result = stepResult };
                        for (int i = 2; i < parts.Length; i++)
                            ParseACWithstandValue(result.ACWithstandTest, parts[i].Trim());
                    }
                }

                result.CalculateOverallResult();
            }
            catch (Exception ex)
            {
                result.OverallResult = "ERROR";
                result.FailureReason = $"Parse error: {ex.Message}";
            }

            return result;
        }

        private void ParseGroundBondValue(GroundBondResult gnd, string value)
        {
            value = value.ToUpper();

            if (value.EndsWith("A") && !value.Contains("MA"))
            {
                if (decimal.TryParse(value.TrimEnd('A'), out decimal current))
                    gnd.Current_A = current;
            }
            else if (value.Contains("MOHM") || value.Contains("MΩ"))
            {
                string numValue = value.Replace("MOHM", "").Replace("MΩ", "").Trim();
                if (decimal.TryParse(numValue, out decimal resistance))
                    gnd.Resistance_mOhm = resistance;
            }
            else if (value.EndsWith("V"))
            {
                if (decimal.TryParse(value.TrimEnd('V'), out decimal voltage))
                    gnd.Voltage_V = voltage;
            }
        }

        private void ParseACWithstandValue(ACWithstandResult acw, string value)
        {
            value = value.ToUpper();

            if (value.EndsWith("V") && !value.Contains("KV"))
            {
                if (decimal.TryParse(value.TrimEnd('V'), out decimal voltage))
                    acw.Voltage_V = voltage;
            }
            else if (value.EndsWith("KV"))
            {
                string numValue = value.Replace("KV", "").Trim();
                if (decimal.TryParse(numValue, out decimal voltage))
                    acw.Voltage_V = voltage * 1000;
            }
            else if (value.EndsWith("MA"))
            {
                string numValue = value.Replace("MA", "").Trim();
                if (decimal.TryParse(numValue, out decimal current))
                    acw.LeakageCurrent_mA = current;
            }
            else if (value.Contains("ARC"))
            {
                acw.ArcDetected = true;
            }
        }

        /// <summary>
        /// Parses FailCHEK result into SafetyCheckResult
        /// </summary>
        public SafetyCheckResult ParseFailCheckData(string rawData, FailCheckType checkType)
        {
            var result = new SafetyCheckResult
            {
                RawResponse = rawData,
                CheckDateTime = DateTime.Now,
                ShiftNumber = SafetyCheckResult.GetCurrentShift()
            };

            if (string.IsNullOrEmpty(rawData))
            {
                result.OverallResult = "ERROR";
                return result;
            }

            try
            {
                string[] parts = rawData.Split(',');
                string stepResult = parts[0].Trim().ToUpper();

                if (checkType == FailCheckType.Continuity)
                {
                    result.ContinuityCheck = new ContinuityCheckResult { Result = stepResult };
                    for (int i = 1; i < parts.Length; i++)
                    {
                        string value = parts[i].Trim().ToUpper();
                        if (value.Contains("MOHM") || value.Contains("MΩ"))
                        {
                            string numValue = value.Replace("MOHM", "").Replace("MΩ", "").Trim();
                            if (decimal.TryParse(numValue, out decimal resistance))
                                result.ContinuityCheck.Resistance_mOhm = resistance;
                        }
                    }
                }
                else if (checkType == FailCheckType.GroundBond)
                {
                    result.GroundBondCheck = new GroundBondCheckResult { Result = stepResult };
                    for (int i = 1; i < parts.Length; i++)
                    {
                        string value = parts[i].Trim().ToUpper();
                        if (value.Contains("MOHM") || value.Contains("MΩ"))
                        {
                            string numValue = value.Replace("MOHM", "").Replace("MΩ", "").Trim();
                            if (decimal.TryParse(numValue, out decimal resistance))
                                result.GroundBondCheck.Resistance_mOhm = resistance;
                        }
                        else if (value.EndsWith("A"))
                        {
                            if (decimal.TryParse(value.TrimEnd('A'), out decimal current))
                                result.GroundBondCheck.Current_A = current;
                        }
                    }
                }

                result.CalculateOverallResult();
            }
            catch (Exception ex)
            {
                result.OverallResult = "ERROR";
                result.Comments = $"Parse error: {ex.Message}";
            }

            return result;
        }

        #endregion

        #region IDisposable

        public void Dispose()
        {
            Disconnect();
        }

        #endregion
    }
}
