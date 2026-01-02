-- Safe version: Update vw_EquipmentInventory_RecentAdditions view
-- This version checks for column existence and handles missing columns gracefully

-- Drop existing view if it exists
IF OBJECT_ID('vw_EquipmentInventory_RecentAdditions', 'V') IS NOT NULL
    DROP VIEW vw_EquipmentInventory_RecentAdditions;
GO

-- Check if RequiredCalibration column exists in tables
DECLARE @HasCalibrationInATE BIT = 0;
DECLARE @HasCalibrationInAsset BIT = 0;
DECLARE @HasCalibrationInFixture BIT = 0;  
DECLARE @HasCalibrationInHarness BIT = 0;

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
           WHERE TABLE_NAME = 'ATE_Inventory' AND COLUMN_NAME = 'RequiredCalibration')
    SET @HasCalibrationInATE = 1;

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
           WHERE TABLE_NAME = 'Asset_Inventory' AND COLUMN_NAME = 'RequiredCalibration')
    SET @HasCalibrationInAsset = 1;

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
           WHERE TABLE_NAME = 'Fixture_Inventory' AND COLUMN_NAME = 'RequiredCalibration')
    SET @HasCalibrationInFixture = 1;

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
           WHERE TABLE_NAME = 'Harness_Inventory' AND COLUMN_NAME = 'RequiredCalibration')
    SET @HasCalibrationInHarness = 1;

-- Create view based on column availability
IF @HasCalibrationInATE = 1 AND @HasCalibrationInAsset = 1 AND @HasCalibrationInFixture = 1 AND @HasCalibrationInHarness = 1
BEGIN
    -- All tables have RequiredCalibration - use it
    EXEC('
    CREATE VIEW vw_EquipmentInventory_RecentAdditions
    AS
    SELECT TOP 100
        ''ATE'' AS EquipmentType,
        ATEInventoryID AS ID,
        EatonID,
        ATEName AS Name,
        ATEDescription AS Description,
        Location,
        ATEStatus AS Status,
        ISNULL(RequiredPM, 0) AS RequiresPM,
        ISNULL(RequiredCalibration, 0) AS RequiresCalibration,
        CreatedDate,
        CreatedBy
    FROM dbo.ATE_Inventory
    WHERE IsActive = 1 AND CreatedDate >= DATEADD(DAY, -30, GETDATE())

    UNION ALL

    SELECT TOP 100
        ''Asset'' AS EquipmentType,
        AssetID AS ID,
        EatonID,
        DeviceName AS Name,
        DeviceDescription AS Description,
        Location,
        CurrentStatus AS Status,
        ISNULL(RequiredPM, 0) AS RequiresPM,
        ISNULL(RequiredCalibration, 0) AS RequiresCalibration,
        CreatedDate,
        CreatedBy
    FROM dbo.Asset_Inventory
    WHERE IsActive = 1 AND CreatedDate >= DATEADD(DAY, -30, GETDATE())

    UNION ALL

    SELECT TOP 100
        ''Fixture'' AS EquipmentType,
        FixtureID AS ID,
        EatonID,
        FixtureModelNoName AS Name,
        FixtureDescription AS Description,
        Location,
        CurrentStatus AS Status,
        ISNULL(RequiredPM, 0) AS RequiresPM,
        ISNULL(RequiredCalibration, 0) AS RequiresCalibration,
        CreatedDate,
        CreatedBy
    FROM dbo.Fixture_Inventory  
    WHERE IsActive = 1 AND CreatedDate >= DATEADD(DAY, -30, GETDATE())

    UNION ALL

    SELECT TOP 100
        ''Harness'' AS EquipmentType,
        HarnessID AS ID,
        EatonID,
        HarnessModelNo AS Name,
        HarnessDescription AS Description,
        Location,
        CurrentStatus AS Status,
        ISNULL(RequiredPM, 0) AS RequiresPM,
        ISNULL(RequiredCalibration, 0) AS RequiresCalibration,
        CreatedDate,
        CreatedBy
    FROM dbo.Harness_Inventory
    WHERE IsActive = 1 AND CreatedDate >= DATEADD(DAY, -30, GETDATE());
    ');
    PRINT 'Created view with RequiredCalibration column';
END
ELSE
BEGIN
    -- Some tables don't have RequiredCalibration - default to 0
    EXEC('
    CREATE VIEW vw_EquipmentInventory_RecentAdditions
    AS
    SELECT TOP 100
        ''ATE'' AS EquipmentType,
        ATEInventoryID AS ID,
        EatonID,
        ATEName AS Name,
        ATEDescription AS Description,
        Location,
        ATEStatus AS Status,
        ISNULL(RequiredPM, 0) AS RequiresPM,
        0 AS RequiresCalibration,
        CreatedDate,
        CreatedBy
    FROM dbo.ATE_Inventory
    WHERE IsActive = 1 AND CreatedDate >= DATEADD(DAY, -30, GETDATE())

    UNION ALL

    SELECT TOP 100
        ''Asset'' AS EquipmentType,
        AssetID AS ID,
        EatonID,
        DeviceName AS Name,
        DeviceDescription AS Description,
        Location,
        CurrentStatus AS Status,
        ISNULL(RequiredPM, 0) AS RequiresPM,
        0 AS RequiresCalibration,
        CreatedDate,
        CreatedBy
    FROM dbo.Asset_Inventory
    WHERE IsActive = 1 AND CreatedDate >= DATEADD(DAY, -30, GETDATE())

    UNION ALL

    SELECT TOP 100
        ''Fixture'' AS EquipmentType,
        FixtureID AS ID,
        EatonID,
        FixtureModelNoName AS Name,
        FixtureDescription AS Description,
        Location,
        CurrentStatus AS Status,
        ISNULL(RequiredPM, 0) AS RequiresPM,
        0 AS RequiresCalibration,
        CreatedDate,
        CreatedBy
    FROM dbo.Fixture_Inventory  
    WHERE IsActive = 1 AND CreatedDate >= DATEADD(DAY, -30, GETDATE())

    UNION ALL

    SELECT TOP 100
        ''Harness'' AS EquipmentType,
        HarnessID AS ID,
        EatonID,
        HarnessModelNo AS Name,
        HarnessDescription AS Description,
        Location,
        CurrentStatus AS Status,
        ISNULL(RequiredPM, 0) AS RequiresPM,
        0 AS RequiresCalibration,
        CreatedDate,
        CreatedBy
    FROM dbo.Harness_Inventory
    WHERE IsActive = 1 AND CreatedDate >= DATEADD(DAY, -30, GETDATE());
    ');
    PRINT 'Created view without RequiredCalibration column (defaulting to 0)';
END
GO

PRINT 'Successfully updated vw_EquipmentInventory_RecentAdditions view';

-- Test the updated view
SELECT TOP 5 
    EquipmentType,
    EatonID,
    Name,
    Location,
    Status,
    RequiresPM,
    RequiresCalibration,
    CreatedDate
FROM vw_EquipmentInventory_RecentAdditions 
ORDER BY CreatedDate DESC;