using System;

namespace HipotTestApp.Models
{
    /// <summary>
    /// Represents a continuity check result (part of FailCHEK)
    /// </summary>
    public class ContinuityCheckResult
    {
        public string Result { get; set; }          // PASS or FAIL
        public decimal? Resistance_mOhm { get; set; } // Measured resistance
        public decimal? HiLimit_mOhm { get; set; }  // HI limit used
        public decimal? LoLimit_mOhm { get; set; }  // LO limit used
    }

    /// <summary>
    /// Represents a Ground Bond check result (part of FailCHEK)
    /// </summary>
    public class GroundBondCheckResult
    {
        public string Result { get; set; }          // PASS or FAIL
        public decimal? Current_A { get; set; }     // Applied current
        public decimal? Resistance_mOhm { get; set; } // Measured resistance
        public decimal? HiLimit_mOhm { get; set; }  // HI limit used
        public decimal? LoLimit_mOhm { get; set; }  // LO limit used
    }

    /// <summary>
    /// Represents a complete safety check (FailCHEK) result
    /// Operators must pass this check each shift before testing units
    /// </summary>
    public class SafetyCheckResult
    {
        // Primary Key
        public int SafetyCheckID { get; set; }
        
        // Check Information
        public DateTime CheckDateTime { get; set; }
        public string OperatorENumber { get; set; }
        public int? ShiftNumber { get; set; }       // 1, 2, or 3
        public string EquipmentID { get; set; }
        
        // Overall Result
        public string OverallResult { get; set; }   // PASS or FAIL
        
        // Individual Check Results
        public ContinuityCheckResult ContinuityCheck { get; set; }
        public GroundBondCheckResult GroundBondCheck { get; set; }
        
        // Additional Info
        public string Comments { get; set; }
        public string RawResponse { get; set; }
        
        // Validation
        public bool IsValidForShift { get; set; }
        public DateTime? ExpirationDateTime { get; set; }
        
        // Audit Fields
        public DateTime CreatedDate { get; set; }
        public string CreatedBy { get; set; }

        public SafetyCheckResult()
        {
            CheckDateTime = DateTime.Now;
            CreatedDate = DateTime.Now;
            IsValidForShift = true;
            ContinuityCheck = new ContinuityCheckResult();
            GroundBondCheck = new GroundBondCheckResult();
        }

        /// <summary>
        /// Determines overall pass/fail based on individual check results
        /// </summary>
        public void CalculateOverallResult()
        {
            // Both checks must pass for overall pass
            if (ContinuityCheck?.Result == "PASS" && GroundBondCheck?.Result == "PASS")
            {
                OverallResult = "PASS";
            }
            else
            {
                OverallResult = "FAIL";
            }
        }

        /// <summary>
        /// Determines the current shift based on time
        /// </summary>
        public static int GetCurrentShift()
        {
            var now = DateTime.Now.TimeOfDay;
            
            // Shift 1: 6:00 AM - 2:00 PM
            if (now >= TimeSpan.FromHours(6) && now < TimeSpan.FromHours(14))
                return 1;
            
            // Shift 2: 2:00 PM - 10:00 PM
            if (now >= TimeSpan.FromHours(14) && now < TimeSpan.FromHours(22))
                return 2;
            
            // Shift 3: 10:00 PM - 6:00 AM
            return 3;
        }

        /// <summary>
        /// Checks if this safety check is still valid
        /// </summary>
        public bool IsStillValid()
        {
            if (!IsValidForShift)
                return false;
            
            if (OverallResult != "PASS")
                return false;
            
            if (ExpirationDateTime.HasValue && DateTime.Now > ExpirationDateTime.Value)
                return false;
            
            // Check if still same shift
            if (ShiftNumber.HasValue && ShiftNumber.Value != GetCurrentShift())
                return false;
            
            return true;
        }

        /// <summary>
        /// Returns a summary string for display
        /// </summary>
        public string GetSummary()
        {
            return $"Shift {ShiftNumber} | {CheckDateTime:HH:mm:ss} | Result: {OverallResult} | " +
                   $"Continuity: {ContinuityCheck?.Result ?? "N/A"} | " +
                   $"Ground Bond: {GroundBondCheck?.Result ?? "N/A"}";
        }
    }
}
