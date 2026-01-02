-- =============================================
-- Add Equipment Information Columns to PM_Log
-- =============================================
-- This script adds EatonID and EquipmentName columns
-- to the PM_Log table for better tracking and display
-- =============================================

USE [TestEngineering]
GO

-- Add EquipmentEatonID column
IF NOT EXISTS (
    SELECT 1 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'PM_Log' 
    AND TABLE_SCHEMA = 'dbo'
    AND COLUMN_NAME = 'EquipmentEatonID'
)
BEGIN
    ALTER TABLE dbo.PM_Log
    ADD EquipmentEatonID NVARCHAR(50) NULL;
    
    PRINT 'Added EquipmentEatonID column to PM_Log table';
END
ELSE
BEGIN
    PRINT 'EquipmentEatonID column already exists in PM_Log table';
END
GO

-- Add EquipmentName column
IF NOT EXISTS (
    SELECT 1 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'PM_Log' 
    AND TABLE_SCHEMA = 'dbo'
    AND COLUMN_NAME = 'EquipmentName'
)
BEGIN
    ALTER TABLE dbo.PM_Log
    ADD EquipmentName NVARCHAR(200) NULL;
    
    PRINT 'Added EquipmentName column to PM_Log table';
END
ELSE
BEGIN
    PRINT 'EquipmentName column already exists in PM_Log table';
END
GO

-- Update existing PM_Log records with Equipment information
-- This will populate the new columns for existing records
PRINT 'Updating existing PM_Log records with Equipment information...';

-- Update from ATE_Inventory
UPDATE pl
SET 
    pl.EquipmentEatonID = ate.EatonID,
    pl.EquipmentName = ate.ATEName
FROM dbo.PM_Log pl
INNER JOIN dbo.ATE_Inventory ate ON pl.EquipmentID = ate.ATEInventoryID
WHERE pl.EquipmentType = 'ATE'
AND pl.EquipmentEatonID IS NULL;

PRINT 'Updated ' + CAST(@@ROWCOUNT AS NVARCHAR) + ' ATE records';

-- Update from Asset_Inventory
UPDATE pl
SET 
    pl.EquipmentEatonID = asset.EatonID,
    pl.EquipmentName = asset.DeviceName
FROM dbo.PM_Log pl
INNER JOIN dbo.Asset_Inventory asset ON pl.EquipmentID = asset.AssetID
WHERE pl.EquipmentType = 'Asset'
AND pl.EquipmentEatonID IS NULL;

PRINT 'Updated ' + CAST(@@ROWCOUNT AS NVARCHAR) + ' Asset records';

-- Update from Fixture_Inventory
UPDATE pl
SET 
    pl.EquipmentEatonID = fixture.EatonID,
    pl.EquipmentName = fixture.FixtureModelNoName
FROM dbo.PM_Log pl
INNER JOIN dbo.Fixture_Inventory fixture ON pl.EquipmentID = fixture.FixtureID
WHERE pl.EquipmentType = 'Fixture'
AND pl.EquipmentEatonID IS NULL;

PRINT 'Updated ' + CAST(@@ROWCOUNT AS NVARCHAR) + ' Fixture records';

-- Update from Harness_Inventory
UPDATE pl
SET 
    pl.EquipmentEatonID = harness.EatonID,
    pl.EquipmentName = harness.HarnessModelNo
FROM dbo.PM_Log pl
INNER JOIN dbo.Harness_Inventory harness ON pl.EquipmentID = harness.HarnessID
WHERE pl.EquipmentType = 'Harness'
AND pl.EquipmentEatonID IS NULL;

PRINT 'Updated ' + CAST(@@ROWCOUNT AS NVARCHAR) + ' Harness records';

PRINT 'Equipment information columns added and populated successfully!';
GO

-- Verify the changes
SELECT 
    PMLogID,
    EquipmentType,
    EquipmentEatonID,
    EquipmentName,
    Status,
    PMDate
FROM dbo.PM_Log
ORDER BY PMLogID DESC;
GO
