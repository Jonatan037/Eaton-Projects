-- =============================================
-- Create View: vw_Equipment_RequireCalibration
-- =============================================
-- This view provides a unified list of all equipment
-- that requires calibration from all inventory tables
-- Uses existing calibration columns in equipment tables
-- =============================================

USE [TestEngineering]
GO

-- Drop view if it exists
IF OBJECT_ID('dbo.vw_Equipment_RequireCalibration', 'V') IS NOT NULL
    DROP VIEW dbo.vw_Equipment_RequireCalibration;
GO

CREATE VIEW dbo.vw_Equipment_RequireCalibration
AS
-- ATE Inventory
SELECT 
    'ATE' AS EquipmentType,
    ATEInventoryID AS EquipmentID,
    EatonID,
    ATEName AS EquipmentName,
    Location,
    RequiresCalibration AS RequiredCalibration,
    CalibrationFrequency,
    CAST(NULL AS NVARCHAR(100)) AS CalibrationResponsible, -- Not in ATE table
    LastCalibration,
    CalibratedBy AS LastCalibratedBy,
    NextCalibration,
    CalibrationEstimatedTime,
    IsActive
FROM dbo.ATE_Inventory
WHERE RequiresCalibration = 1 AND IsActive = 1

UNION ALL

-- Asset Inventory
SELECT 
    'Asset' AS EquipmentType,
    AssetID AS EquipmentID,
    EatonID,
    DeviceName AS EquipmentName,
    Location,
    RequiresCalibration AS RequiredCalibration,
    CalibrationFrequency,
    CAST(NULL AS NVARCHAR(100)) AS CalibrationResponsible, -- Not in Asset table
    LastCalibration,
    CalibratedBy AS LastCalibratedBy,
    NextCalibration,
    CalibrationEstimatedTime,
    IsActive
FROM dbo.Asset_Inventory
WHERE RequiresCalibration = 1 AND IsActive = 1

UNION ALL

-- Fixture Inventory
SELECT 
    'Fixture' AS EquipmentType,
    FixtureID AS EquipmentID,
    EatonID,
    FixtureModelNoName AS EquipmentName,
    Location,
    RequiresCalibration AS RequiredCalibration,
    CalibrationFrequency,
    CAST(NULL AS NVARCHAR(100)) AS CalibrationResponsible, -- Not in Fixture table
    LastCalibration,
    CalibratedBy AS LastCalibratedBy,
    NextCalibration,
    CalibrationEstimatedTime,
    IsActive
FROM dbo.Fixture_Inventory
WHERE RequiresCalibration = 1 AND IsActive = 1

UNION ALL

-- Harness Inventory
SELECT 
    'Harness' AS EquipmentType,
    HarnessID AS EquipmentID,
    EatonID,
    HarnessModelNo AS EquipmentName,
    Location,
    RequiresCalibration AS RequiredCalibration,
    CalibrationFrequency,
    CAST(NULL AS NVARCHAR(100)) AS CalibrationResponsible, -- Not in Harness table
    LastCalibration,
    CalibratedBy AS LastCalibratedBy,
    NextCalibration,
    CalibrationEstimatedTime,
    IsActive
FROM dbo.Harness_Inventory
WHERE RequiresCalibration = 1 AND IsActive = 1;
GO

-- Grant permissions (adjust as needed)
GRANT SELECT ON dbo.vw_Equipment_RequireCalibration TO PUBLIC;
GO

PRINT 'View vw_Equipment_RequireCalibration created successfully!';
GO

-- Test the view
SELECT 
    EquipmentType,
    EatonID,
    EquipmentName,
    Location,
    CalibrationFrequency,
    CalibrationResponsible,
    LastCalibration,
    NextCalibration
FROM dbo.vw_Equipment_RequireCalibration
ORDER BY EquipmentType, EatonID;
GO
