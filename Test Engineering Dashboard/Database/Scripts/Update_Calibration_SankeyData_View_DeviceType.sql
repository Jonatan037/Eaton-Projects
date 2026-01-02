-- =============================================
-- Update View: vw_Calibration_SankeyData
-- =============================================
-- Purpose: Update Sankey diagram to use Device Type (DeviceName) instead of Equipment Type
-- Change Level 2 from Equipment Type (Asset/ATE/Fixture/Harness) to actual Device Type
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
    -- Get all equipment requiring calibration with their Device Type (EquipmentName)
    SELECT 
        EquipmentType,
        EquipmentName AS DeviceType,  -- Use EquipmentName as Device Type
        EatonID,
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

-- Level 1 -> Level 2: Total Equipment to Device Type (instead of Equipment Type)
SELECT 
    'Total Equipment' AS SourceNode,
    DeviceType AS TargetNode,
    COUNT(*) AS Value
FROM CalibrationEquipment
GROUP BY DeviceType

UNION ALL

-- Level 2 -> Level 3: Device Type to Calibration Status
SELECT 
    DeviceType AS SourceNode,
    CalibrationStatus AS TargetNode,
    COUNT(*) AS Value
FROM CalibrationEquipment
GROUP BY DeviceType, CalibrationStatus

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

PRINT 'View vw_Calibration_SankeyData updated successfully!';
PRINT 'Level 2 now shows Device Type (from EquipmentName) instead of Equipment Type';
GO

-- Test the view
PRINT '';
PRINT '=== Testing vw_Calibration_SankeyData ===';
PRINT 'Flow: Total Equipment → Device Type → Calibration Status → Results';
PRINT '';
SELECT 
    SourceNode,
    TargetNode,
    Value
FROM dbo.vw_Calibration_SankeyData
ORDER BY 
    CASE SourceNode
        WHEN 'Total Equipment' THEN 1
        WHEN 'Pending Calibration' THEN 3
        WHEN 'No Pending Calibration' THEN 3
        ELSE 2  -- All Device Types
    END,
    Value DESC,
    SourceNode,
    TargetNode;
GO
