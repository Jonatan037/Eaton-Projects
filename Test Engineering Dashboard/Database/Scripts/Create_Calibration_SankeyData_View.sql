-- =============================================
-- Create View: vw_Calibration_SankeyData
-- =============================================
-- Purpose: Provides Sankey diagram data for calibration flow:
--   Level 1: Total Equipment (requiring calibration)
--   Level 2: Device Type (equipment type)
--   Level 3: Pending Calibration (current year status)
--   Level 4: Result (calibration result distribution)
-- =============================================

USE [TestEngineering]
GO

-- Drop view if exists
IF OBJECT_ID('dbo.vw_Calibration_SankeyData', 'V') IS NOT NULL
    DROP VIEW dbo.vw_Calibration_SankeyData;
GO

CREATE VIEW dbo.vw_Calibration_SankeyData
AS
WITH CalibrationEquipment AS (
    -- Get all equipment requiring calibration
    SELECT 
        EquipmentType,
        EatonID,
        EquipmentName,
        NextCalibration,
        CASE 
            WHEN NextCalibration < CAST(GETDATE() AS DATE) THEN 'Pending Calibration'
            ELSE 'No Pending Calibration'
        END AS CalibrationStatus
    FROM dbo.vw_Equipment_RequireCalibration
    WHERE IsActive = 1
),
CalibrationLogs AS (
    -- Get calibration logs for current year
    SELECT 
        EquipmentEatonID,
        ResultCode,
        CalibrationDate
    FROM dbo.Calibration_Log
    WHERE YEAR(CalibrationDate) = YEAR(GETDATE())
    AND ResultCode IS NOT NULL
)

-- Level 1 -> Level 2: Total Equipment to Equipment Type
SELECT 
    'Total Equipment' AS SourceNode,
    EquipmentType AS TargetNode,
    COUNT(*) AS Value
FROM CalibrationEquipment
GROUP BY EquipmentType

UNION ALL

-- Level 2 -> Level 3: Equipment Type to Calibration Status
SELECT 
    EquipmentType AS SourceNode,
    CalibrationStatus AS TargetNode,
    COUNT(*) AS Value
FROM CalibrationEquipment
GROUP BY EquipmentType, CalibrationStatus

UNION ALL

-- Level 3 -> Level 4: Calibration Status to Result (only for completed calibrations)
SELECT 
    'Pending Calibration' AS SourceNode,
    CASE 
        WHEN cl.ResultCode = 'PASS' THEN 'Pass'
        WHEN cl.ResultCode = 'OOT' THEN 'Out of Tolerance'
        WHEN cl.ResultCode = 'FAIL' THEN 'Fail'
        WHEN cl.ResultCode = 'N/A' THEN 'N/A'
        ELSE 'Other'
    END AS TargetNode,
    COUNT(*) AS Value
FROM CalibrationLogs cl
INNER JOIN CalibrationEquipment ce ON cl.EquipmentEatonID = ce.EatonID
WHERE ce.CalibrationStatus = 'Pending Calibration'
GROUP BY 
    CASE 
        WHEN cl.ResultCode = 'PASS' THEN 'Pass'
        WHEN cl.ResultCode = 'OOT' THEN 'Out of Tolerance'
        WHEN cl.ResultCode = 'FAIL' THEN 'Fail'
        WHEN cl.ResultCode = 'N/A' THEN 'N/A'
        ELSE 'Other'
    END

UNION ALL

-- Level 3 -> Level 4: No Pending Calibration to Result (for completed calibrations)
SELECT 
    'No Pending Calibration' AS SourceNode,
    CASE 
        WHEN cl.ResultCode = 'PASS' THEN 'Pass'
        WHEN cl.ResultCode = 'OOT' THEN 'Out of Tolerance'
        WHEN cl.ResultCode = 'FAIL' THEN 'Fail'
        WHEN cl.ResultCode = 'N/A' THEN 'N/A'
        ELSE 'Other'
    END AS TargetNode,
    COUNT(*) AS Value
FROM CalibrationLogs cl
INNER JOIN CalibrationEquipment ce ON cl.EquipmentEatonID = ce.EatonID
WHERE ce.CalibrationStatus = 'No Pending Calibration'
GROUP BY 
    CASE 
        WHEN cl.ResultCode = 'PASS' THEN 'Pass'
        WHEN cl.ResultCode = 'OOT' THEN 'Out of Tolerance'
        WHEN cl.ResultCode = 'FAIL' THEN 'Fail'
        WHEN cl.ResultCode = 'N/A' THEN 'N/A'
        ELSE 'Other'
    END;

GO

-- Grant permissions
GRANT SELECT ON dbo.vw_Calibration_SankeyData TO PUBLIC;
GO

PRINT 'View vw_Calibration_SankeyData created successfully!';
GO

-- Test the view
PRINT '';
PRINT '=== Testing vw_Calibration_SankeyData ===';
SELECT 
    SourceNode,
    TargetNode,
    Value
FROM dbo.vw_Calibration_SankeyData
ORDER BY 
    CASE SourceNode
        WHEN 'Total Equipment' THEN 1
        WHEN 'ATE' THEN 2
        WHEN 'Asset' THEN 2
        WHEN 'Fixture' THEN 2
        WHEN 'Harness' THEN 2
        WHEN 'Pending Calibration' THEN 3
        WHEN 'No Pending Calibration' THEN 3
        ELSE 4
    END,
    SourceNode,
    TargetNode;
GO
