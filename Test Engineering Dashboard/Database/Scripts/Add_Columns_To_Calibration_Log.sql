-- =============================================
-- Add Required Columns to Calibration_Log Table
-- =============================================
-- This script adds AttachmentsPath, EquipmentEatonID, 
-- and EquipmentName columns to the Calibration_Log table
-- =============================================

USE [TestEngineering]
GO

-- Add AttachmentsPath column
IF NOT EXISTS (
    SELECT 1 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'Calibration_Log' 
    AND TABLE_SCHEMA = 'dbo'
    AND COLUMN_NAME = 'AttachmentsPath'
)
BEGIN
    ALTER TABLE dbo.Calibration_Log
    ADD AttachmentsPath NVARCHAR(MAX) NULL;
    
    PRINT 'Added AttachmentsPath column to Calibration_Log table';
END
ELSE
BEGIN
    PRINT 'AttachmentsPath column already exists in Calibration_Log table';
END
GO

-- Add EquipmentEatonID column
IF NOT EXISTS (
    SELECT 1 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'Calibration_Log' 
    AND TABLE_SCHEMA = 'dbo'
    AND COLUMN_NAME = 'EquipmentEatonID'
)
BEGIN
    ALTER TABLE dbo.Calibration_Log
    ADD EquipmentEatonID NVARCHAR(50) NULL;
    
    PRINT 'Added EquipmentEatonID column to Calibration_Log table';
END
ELSE
BEGIN
    PRINT 'EquipmentEatonID column already exists in Calibration_Log table';
END
GO

-- Add EquipmentName column
IF NOT EXISTS (
    SELECT 1 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'Calibration_Log' 
    AND TABLE_SCHEMA = 'dbo'
    AND COLUMN_NAME = 'EquipmentName'
)
BEGIN
    ALTER TABLE dbo.Calibration_Log
    ADD EquipmentName NVARCHAR(200) NULL;
    
    PRINT 'Added EquipmentName column to Calibration_Log table';
END
ELSE
BEGIN
    PRINT 'EquipmentName column already exists in Calibration_Log table';
END
GO

-- Update existing Calibration_Log records with Equipment information
PRINT 'Updating existing Calibration_Log records with Equipment information...';

-- Update from ATE_Inventory
UPDATE cl
SET 
    cl.EquipmentEatonID = ate.EatonID,
    cl.EquipmentName = ate.ATEName
FROM dbo.Calibration_Log cl
INNER JOIN dbo.ATE_Inventory ate ON cl.EquipmentID = ate.ATEInventoryID
WHERE cl.EquipmentType = 'ATE'
AND cl.EquipmentEatonID IS NULL;

PRINT 'Updated ' + CAST(@@ROWCOUNT AS NVARCHAR) + ' ATE records';

-- Update from Asset_Inventory
UPDATE cl
SET 
    cl.EquipmentEatonID = asset.EatonID,
    cl.EquipmentName = asset.DeviceName
FROM dbo.Calibration_Log cl
INNER JOIN dbo.Asset_Inventory asset ON cl.EquipmentID = asset.AssetID
WHERE cl.EquipmentType = 'Asset'
AND cl.EquipmentEatonID IS NULL;

PRINT 'Updated ' + CAST(@@ROWCOUNT AS NVARCHAR) + ' Asset records';

-- Update from Fixture_Inventory
UPDATE cl
SET 
    cl.EquipmentEatonID = fixture.EatonID,
    cl.EquipmentName = fixture.FixtureModelNoName
FROM dbo.Calibration_Log cl
INNER JOIN dbo.Fixture_Inventory fixture ON cl.EquipmentID = fixture.FixtureID
WHERE cl.EquipmentType = 'Fixture'
AND cl.EquipmentEatonID IS NULL;

PRINT 'Updated ' + CAST(@@ROWCOUNT AS NVARCHAR) + ' Fixture records';

-- Update from Harness_Inventory
UPDATE cl
SET 
    cl.EquipmentEatonID = harness.EatonID,
    cl.EquipmentName = harness.HarnessModelNo
FROM dbo.Calibration_Log cl
INNER JOIN dbo.Harness_Inventory harness ON cl.EquipmentID = harness.HarnessID
WHERE cl.EquipmentType = 'Harness'
AND cl.EquipmentEatonID IS NULL;

PRINT 'Updated ' + CAST(@@ROWCOUNT AS NVARCHAR) + ' Harness records';

PRINT 'Calibration_Log columns added and populated successfully!';
GO

-- Verify the changes
SELECT 
    CalibrationID,
    EquipmentType,
    EquipmentEatonID,
    EquipmentName,
    Status,
    CalibrationDate
FROM dbo.Calibration_Log
ORDER BY CalibrationID DESC;
GO
