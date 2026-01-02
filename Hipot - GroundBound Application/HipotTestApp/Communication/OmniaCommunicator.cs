using System;
using System.Configuration;
using System.IO.Ports;
using System.Text;
using System.Threading;
using HipotTestApp.Models;

namespace HipotTestApp.Communication
{
    /// <summary>
    /// Handles communication with the Associated Research OMNIA II 8204
    /// Electrical Safety Compliance Analyzer via USB/RS-232 serial port
    /// </summary>
    public class OmniaCommunicator : IDisposable
    {
        private SerialPort _serialPort;
        private readonly object _lockObject = new object();
        private bool _isConnected;
        private string _lastError;
        private StringBuilder _responseBuffer;

        // Events
        public event EventHandler<string> DataReceived;
        public event EventHandler<string> ErrorOccurred;
        public event EventHandler<TestProgressEventArgs> TestProgressChanged;

        #region Properties

        /// <summary>
        /// Gets whether the communicator is connected to the device
        /// </summary>
        public bool IsConnected => _isConnected && _serialPort?.IsOpen == true;

        /// <summary>
        /// Gets the last error message
        /// </summary>
        public string LastError => _lastError;

        /// <summary>
        /// Gets the current port name
        /// </summary>
        public string PortName => _serialPort?.PortName;

        /// <summary>
        /// Gets device identification string
        /// </summary>
        public string DeviceIdentification { get; private set; }

        #endregion

        #region Initialization and Connection

        /// <summary>
        /// Initializes the communicator with settings from App.config
        /// </summary>
        public OmniaCommunicator()
        {
            _responseBuffer = new StringBuilder();
            InitializeSerialPort();
        }

        /// <summary>
        /// Initializes the communicator with specific port settings
        /// </summary>
        public OmniaCommunicator(string portName, int baudRate = 9600)
        {
            _responseBuffer = new StringBuilder();
            InitializeSerialPort(portName, baudRate);
        }

        private void InitializeSerialPort(string portName = null, int baudRate = 0)
        {
            try
            {
                // Read settings from config or use provided values
                portName = portName ?? ConfigurationManager.AppSettings["OMNIA_PortName"] ?? "COM3";
                baudRate = baudRate > 0 ? baudRate : int.Parse(ConfigurationManager.AppSettings["OMNIA_BaudRate"] ?? "9600");
                int dataBits = int.Parse(ConfigurationManager.AppSettings["OMNIA_DataBits"] ?? "8");
                int readTimeout = int.Parse(ConfigurationManager.AppSettings["OMNIA_ReadTimeout"] ?? "5000");
                int writeTimeout = int.Parse(ConfigurationManager.AppSettings["OMNIA_WriteTimeout"] ?? "5000");

                _serialPort = new SerialPort
                {
                    PortName = portName,
                    BaudRate = baudRate,
                    DataBits = dataBits,
                    Parity = Parity.None,
                    StopBits = StopBits.One,
                    ReadTimeout = readTimeout,
                    WriteTimeout = writeTimeout,
                    Handshake = Handshake.None,
                    NewLine = "\n",
                    Encoding = Encoding.ASCII
                };

                _serialPort.DataReceived += SerialPort_DataReceived;
                _serialPort.ErrorReceived += SerialPort_ErrorReceived;
            }
            catch (Exception ex)
            {
                _lastError = $"Failed to initialize serial port: {ex.Message}";
                throw;
            }
        }

        /// <summary>
        /// Connects to the OMNIA II device
        /// </summary>
        public bool Connect()
        {
            lock (_lockObject)
            {
                try
                {
                    if (_serialPort.IsOpen)
                    {
                        _serialPort.Close();
                    }

                    _serialPort.Open();
                    Thread.Sleep(500); // Allow device to initialize

                    // Query device identification
                    string response = SendCommandWithResponse("*IDN?");
                    
                    if (!string.IsNullOrEmpty(response))
                    {
                        DeviceIdentification = response.Trim();
                        _isConnected = true;
                        _lastError = null;
                        return true;
                    }
                    else
                    {
                        _lastError = "No response from device";
                        _serialPort.Close();
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
                    if (_serialPort?.IsOpen == true)
                    {
                        _serialPort.Close();
                    }
                    _isConnected = false;
                }
                catch (Exception ex)
                {
                    _lastError = $"Disconnect error: {ex.Message}";
                }
            }
        }

        /// <summary>
        /// Gets available COM ports
        /// </summary>
        public static string[] GetAvailablePorts()
        {
            return SerialPort.GetPortNames();
        }

        #endregion

        #region Command Methods

        /// <summary>
        /// Sends a command and waits for response
        /// </summary>
        public string SendCommandWithResponse(string command, int timeoutMs = 5000)
        {
            lock (_lockObject)
            {
                if (!IsConnected && !_serialPort.IsOpen)
                {
                    _lastError = "Not connected to device";
                    return null;
                }

                try
                {
                    // Clear any existing data
                    _serialPort.DiscardInBuffer();
                    _serialPort.DiscardOutBuffer();
                    _responseBuffer.Clear();

                    // Send command
                    _serialPort.WriteLine(command);

                    // Wait for response
                    DateTime startTime = DateTime.Now;
                    while ((DateTime.Now - startTime).TotalMilliseconds < timeoutMs)
                    {
                        if (_serialPort.BytesToRead > 0)
                        {
                            string data = _serialPort.ReadLine();
                            return data.Trim();
                        }
                        Thread.Sleep(50);
                    }

                    _lastError = "Response timeout";
                    return null;
                }
                catch (TimeoutException)
                {
                    _lastError = "Response timeout";
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
        /// Sends a command without waiting for response
        /// </summary>
        public bool SendCommand(string command)
        {
            lock (_lockObject)
            {
                if (!IsConnected && !_serialPort.IsOpen)
                {
                    _lastError = "Not connected to device";
                    return false;
                }

                try
                {
                    _serialPort.WriteLine(command);
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
        /// Queries device identification (*IDN?)
        /// </summary>
        public string GetDeviceIdentification()
        {
            return SendCommandWithResponse("*IDN?");
        }

        /// <summary>
        /// Clears status registers (*CLS)
        /// </summary>
        public bool ClearStatus()
        {
            return SendCommand("*CLS");
        }

        /// <summary>
        /// Resets instrument (*RST)
        /// </summary>
        public bool Reset()
        {
            return SendCommand("*RST");
        }

        /// <summary>
        /// Queries test data for current test (TD?)
        /// Returns test results after test completion
        /// </summary>
        public string QueryTestData()
        {
            return SendCommandWithResponse("TD?", 10000);
        }

        /// <summary>
        /// Queries file data (FD?)
        /// Returns information about loaded test file
        /// </summary>
        public string QueryFileData()
        {
            return SendCommandWithResponse("FD?");
        }

        /// <summary>
        /// Queries sequence data (SD?)
        /// Returns current test sequence settings
        /// </summary>
        public string QuerySequenceData()
        {
            return SendCommandWithResponse("SD?");
        }

        /// <summary>
        /// Queries system status (SS?)
        /// </summary>
        public string QuerySystemStatus()
        {
            return SendCommandWithResponse("SS?");
        }

        /// <summary>
        /// Queries last result (LS?)
        /// </summary>
        public string QueryLastResult()
        {
            return SendCommandWithResponse("LS?", 10000);
        }

        /// <summary>
        /// Starts a test (TEST)
        /// </summary>
        public bool StartTest()
        {
            return SendCommand("TEST");
        }

        /// <summary>
        /// Stops the current test (STOP or RESET)
        /// </summary>
        public bool StopTest()
        {
            return SendCommand("RESET");
        }

        /// <summary>
        /// Loads a specific memory file (FL n)
        /// </summary>
        public bool LoadFile(int fileNumber)
        {
            return SendCommand($"FL {fileNumber}");
        }

        /// <summary>
        /// Gets device identification (alias for GetDeviceIdentification)
        /// </summary>
        public string GetIdentification()
        {
            return GetDeviceIdentification();
        }

        /// <summary>
        /// Gets system status (alias for QuerySystemStatus)
        /// </summary>
        public string GetSystemStatus()
        {
            return QuerySystemStatus();
        }

        /// <summary>
        /// Gets test data and parses it (wrapper for QueryTestData with parsing)
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
        /// Gets FailCHEK data and parses it
        /// </summary>
        public System.Collections.Generic.Dictionary<string, string> GetFailCheckData()
        {
            string rawData = QueryLastResult();
            var result = new System.Collections.Generic.Dictionary<string, string>();
            
            if (string.IsNullOrEmpty(rawData))
                return result;

            // Parse into dictionary format
            // Try to detect which type of FailCHEK was run
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

        /// <summary>
        /// Starts FailCHEK sequence (runs both Continuity and Ground Bond)
        /// </summary>
        public bool StartFailCheck()
        {
            // Run Continuity first, then Ground Bond
            bool contResult = StartFailCheck(FailCheckType.Continuity);
            if (!contResult) return false;
            
            System.Threading.Thread.Sleep(2000); // Wait for first check
            
            return StartFailCheck(FailCheckType.GroundBond);
        }

        /// <summary>
        /// Runs FailCHEK for specified test type
        /// </summary>
        public bool StartFailCheck(FailCheckType checkType)
        {
            string typeCode = checkType switch
            {
                FailCheckType.Continuity => "CONT",
                FailCheckType.GroundBond => "GND",
                FailCheckType.ACHipot => "ACW",
                FailCheckType.DCHipot => "DCW",
                FailCheckType.IR => "IR",
                _ => throw new ArgumentException("Invalid FailCHEK type")
            };

            return SendCommand($"FC {typeCode}");
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
                // Parse the response based on OMNIA format
                // Format varies by test type and step
                // Example: "PASS,GND,25.00A,45.2mOhm,1.0s" or "FAIL,ACW,1960V,36.5mA,ARC"
                
                string[] lines = rawData.Split(new[] { '\r', '\n' }, StringSplitOptions.RemoveEmptyEntries);
                
                foreach (string line in lines)
                {
                    string[] parts = line.Split(',');
                    if (parts.Length < 2) continue;

                    string stepResult = parts[0].Trim().ToUpper();
                    string testType = parts.Length > 1 ? parts[1].Trim().ToUpper() : "";

                    if (testType.Contains("GND") || testType.Contains("GROUND"))
                    {
                        result.GroundBondTest = new GroundBondResult
                        {
                            Result = stepResult
                        };

                        // Parse additional GND parameters
                        for (int i = 2; i < parts.Length; i++)
                        {
                            ParseGroundBondValue(result.GroundBondTest, parts[i].Trim());
                        }
                    }
                    else if (testType.Contains("ACW") || testType.Contains("HIPOT") || testType.Contains("WITHSTAND"))
                    {
                        result.ACWithstandTest = new ACWithstandResult
                        {
                            Result = stepResult
                        };

                        // Parse additional ACW parameters
                        for (int i = 2; i < parts.Length; i++)
                        {
                            ParseACWithstandValue(result.ACWithstandTest, parts[i].Trim());
                        }
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
            else if (value.EndsWith("S"))
            {
                if (decimal.TryParse(value.TrimEnd('S'), out decimal dwell))
                    gnd.DwellTime_s = dwell;
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
            else if (value.EndsWith("S"))
            {
                if (decimal.TryParse(value.TrimEnd('S'), out decimal dwell))
                    acw.DwellTime_s = dwell;
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
                // Parse based on FailCHEK type
                string[] parts = rawData.Split(',');
                string stepResult = parts[0].Trim().ToUpper();

                if (checkType == FailCheckType.Continuity)
                {
                    result.ContinuityCheck = new ContinuityCheckResult
                    {
                        Result = stepResult
                    };

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
                    result.GroundBondCheck = new GroundBondCheckResult
                    {
                        Result = stepResult
                    };

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

        #region Event Handlers

        private void SerialPort_DataReceived(object sender, SerialDataReceivedEventArgs e)
        {
            try
            {
                string data = _serialPort.ReadExisting();
                _responseBuffer.Append(data);
                DataReceived?.Invoke(this, data);
            }
            catch (Exception ex)
            {
                _lastError = $"Data receive error: {ex.Message}";
            }
        }

        private void SerialPort_ErrorReceived(object sender, SerialErrorReceivedEventArgs e)
        {
            _lastError = $"Serial error: {e.EventType}";
            ErrorOccurred?.Invoke(this, _lastError);
        }

        #endregion

        #region IDisposable

        public void Dispose()
        {
            Disconnect();
            if (_serialPort != null)
            {
                _serialPort.DataReceived -= SerialPort_DataReceived;
                _serialPort.ErrorReceived -= SerialPort_ErrorReceived;
                _serialPort.Dispose();
                _serialPort = null;
            }
        }

        #endregion
    }

    /// <summary>
    /// FailCHEK test types
    /// </summary>
    public enum FailCheckType
    {
        Continuity,
        GroundBond,
        ACHipot,
        DCHipot,
        IR
    }

    /// <summary>
    /// Test progress event arguments
    /// </summary>
    public class TestProgressEventArgs : EventArgs
    {
        public string CurrentStep { get; set; }
        public int StepNumber { get; set; }
        public int TotalSteps { get; set; }
        public string Status { get; set; }
        public decimal? MeasuredValue { get; set; }
        public string Unit { get; set; }
    }
}
