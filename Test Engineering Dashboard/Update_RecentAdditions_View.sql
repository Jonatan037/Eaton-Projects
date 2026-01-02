-- Update vw_EquipmentInventory_RecentAdditions view to include RequiredPM and RequiredCalibration fields
-- Note: Remove the USE statement - run this in the context of your database

-- Drop existing view if it exists
IF OBJECT_ID('vw_EquipmentInventory_RecentAdditions', 'V') IS NOT NULL
    DROP VIEW vw_EquipmentInventory_RecentAdditions;
GO

-- Create updated view with PM requirement field (Calibration field may not exist yet)
CREATE VIEW vw_EquipmentInventory_RecentAdditions
AS
SELECT TOP 100
    'ATE' AS EquipmentType,
    ATEInventoryID AS ID,
    EatonID,
    ATEName AS Name,
    ATEDescription AS Description,
    Location,
    ATEStatus AS Status,
    ISNULL(RequiredPM, 0) AS RequiresPM,
    0 AS RequiresCalibration,  -- Default to 0 since column may not exist
    CreatedDate,
    CreatedBy
FROM dbo.ATE_Inventory
WHERE IsActive = 1 AND CreatedDate >= DATEADD(DAY, -30, GETDATE())

UNION ALL

SELECT TOP 100
    'Asset' AS EquipmentType,
    AssetID AS ID,
    EatonID,
    DeviceName AS Name,
    DeviceDescription AS Description,
    Location,
    CurrentStatus AS Status,
    ISNULL(RequiredPM, 0) AS RequiresPM,
    0 AS RequiresCalibration,  -- Default to 0 since column may not exist
    CreatedDate,
    CreatedBy
FROM dbo.Asset_Inventory
WHERE IsActive = 1 AND CreatedDate >= DATEADD(DAY, -30, GETDATE())

UNION ALL

SELECT TOP 100
    'Fixture' AS EquipmentType,
    FixtureID AS ID,
    EatonID,
    FixtureModelNoName AS Name,
    FixtureDescription AS Description,
    Location,
    CurrentStatus AS Status,
    ISNULL(RequiredPM, 0) AS RequiresPM,
    0 AS RequiresCalibration,  -- Default to 0 since column may not exist
    CreatedDate,
    CreatedBy
FROM dbo.Fixture_Inventory  
WHERE IsActive = 1 AND CreatedDate >= DATEADD(DAY, -30, GETDATE())

UNION ALL

SELECT TOP 100
    'Harness' AS EquipmentType,
    HarnessID AS ID,
    EatonID,
    HarnessModelNo AS Name,
    HarnessDescription AS Description,
    Location,
    CurrentStatus AS Status,
    ISNULL(RequiredPM, 0) AS RequiresPM,
    0 AS RequiresCalibration,  -- Default to 0 since column may not exist
    CreatedDate,
    CreatedBy
FROM dbo.Harness_Inventory
WHERE IsActive = 1 AND CreatedDate >= DATEADD(DAY, -30, GETDATE());
GO

PRINT 'Updated vw_EquipmentInventory_RecentAdditions view to include RequiresPM field';

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