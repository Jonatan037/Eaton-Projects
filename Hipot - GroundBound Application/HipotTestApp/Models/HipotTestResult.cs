using System;

namespace HipotTestApp.Models
{
    /// <summary>
    /// Represents the result of a Ground Bond test step
    /// </summary>
    public class GroundBondResult
    {
        public string Result { get; set; }          // PASS, FAIL, SKIP
        public string RawStatus { get; set; }       // Raw status from device (PASS, HI-LIMIT, LO-LIMIT, etc.)
        public string ResistanceDisplay { get; set; } // Resistance with > or < symbol for display
        public decimal? Current_A { get; set; }     // Applied current in Amps
        public decimal? Voltage_V { get; set; }     // Measured voltage
        public decimal? Resistance_mOhm { get; set; } // Measured resistance (numeric)
        public decimal? HiLimit_mOhm { get; set; }  // HI limit setting
        public decimal? LoLimit_mOhm { get; set; }  // LO limit setting
        public decimal? DwellTime_s { get; set; }   // Dwell time in seconds
        public int? Frequency_Hz { get; set; }      // 50 or 60 Hz
    }

    /// <summary>
    /// Represents the result of an AC Withstand (Hipot) test step
    /// </summary>
    public class ACWithstandResult
    {
        public string Result { get; set; }          // PASS, FAIL, SKIP
        public string RawStatus { get; set; }       // Raw status from device (PASS, SHORT, ARC, HI-LIMIT, etc.)
        public string LeakageDisplay { get; set; } // Leakage with > or < symbol for display
        public decimal? Voltage_V { get; set; }     // Applied voltage
        public decimal? LeakageCurrent_mA { get; set; } // Measured leakage current (numeric)
        public decimal? HiLimit_mA { get; set; }    // HI limit (Total)
        public decimal? LoLimit_mA { get; set; }    // LO limit (Total)
        public decimal? HiLimitReal_mA { get; set; } // HI limit (Real)
        public decimal? LoLimitReal_mA { get; set; } // LO limit (Real)
        public decimal? RampUp_s { get; set; }      // Ramp up time
        public decimal? DwellTime_s { get; set; }   // Dwell time
        public decimal? RampDown_s { get; set; }    // Ramp down time
        public int? Frequency_Hz { get; set; }      // 50 or 60 Hz
        public int? ArcSense { get; set; }          // Arc sense level (1-9)
        public bool? ArcDetected { get; set; }      // Arc detected flag
    }

    /// <summary>
    /// Represents a complete Hipot test result for a unit (GND + ACW)
    /// </summary>
    public class HipotTestResult
    {
        // Primary Key
        public int TestResultID { get; set; }
        
        // Unit Identification
        // SerialNumber = Cabinet Serial Number (primary identifier)
        public string SerialNumber { get; set; }
        // PartNumber = Cabinet Part Number
        public string PartNumber { get; set; }
        // New fields for panel serial numbers
        public string BreakerPanelSerialNumber { get; set; }
        public string GSECPanelSerialNumber { get; set; }
        // WorkOrder is deprecated but kept for backward compatibility
        public string WorkOrder { get; set; }
        
        // Convenience properties with clearer names
        public string CabinetSerialNumber 
        { 
            get => SerialNumber; 
            set => SerialNumber = value; 
        }
        public string CabinetPartNumber 
        { 
            get => PartNumber; 
            set => PartNumber = value; 
        }
        
        // Test Information
        public DateTime TestDateTime { get; set; }
        public string OperatorENumber { get; set; }
        public string EquipmentID { get; set; }
        public string TestFileLoaded { get; set; }
        
        // Overall Result
        public string OverallResult { get; set; }   // PASS or FAIL
        public decimal? TotalTestTime { get; set; } // Total test duration in seconds
        
        // Test Step Results
        public GroundBondResult GroundBondTest { get; set; }
        public ACWithstandResult ACWithstandTest { get; set; }
        
        // Failure Information
        public string FailureReason { get; set; }
        public int? FailureStep { get; set; }       // 1=GND, 2=ACW
        
        // Additional Info
        public string Comments { get; set; }
        public string RawResponse { get; set; }
        
        // Audit Fields
        public DateTime CreatedDate { get; set; }
        public string CreatedBy { get; set; }
        public DateTime? ModifiedDate { get; set; }
        public string ModifiedBy { get; set; }

        public HipotTestResult()
        {
            TestDateTime = DateTime.Now;
            CreatedDate = DateTime.Now;
            GroundBondTest = new GroundBondResult();
            ACWithstandTest = new ACWithstandResult();
        }

        /// <summary>
        /// Determines overall pass/fail based on individual test results
        /// </summary>
        public void CalculateOverallResult()
        {
            // If either test fails, overall result is FAIL
            if (GroundBondTest?.Result == "FAIL")
            {
                OverallResult = "FAIL";
                FailureStep = 1;
            }
            else if (ACWithstandTest?.Result == "FAIL")
            {
                OverallResult = "FAIL";
                FailureStep = 2;
            }
            else if (GroundBondTest?.Result == "PASS" && ACWithstandTest?.Result == "PASS")
            {
                OverallResult = "PASS";
                FailureStep = null;
                FailureReason = null;
            }
            else
            {
                // One or both tests were skipped or incomplete
                OverallResult = "INCOMPLETE";
            }
        }

        /// <summary>
        /// Returns a summary string for display
        /// </summary>
        public string GetSummary()
        {
            return $"SN: {SerialNumber} | Result: {OverallResult} | " +
                   $"GND: {GroundBondTest?.Result ?? "N/A"} ({GroundBondTest?.Resistance_mOhm:F2} mΩ) | " +
                   $"ACW: {ACWithstandTest?.Result ?? "N/A"} ({ACWithstandTest?.LeakageCurrent_mA:F3} mA)";
        }
    }
}
