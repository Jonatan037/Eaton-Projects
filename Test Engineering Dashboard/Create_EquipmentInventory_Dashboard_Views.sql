/*************************************************************************************************
 * Equipment Inventory Dashboard - SQL Views Script
 * 
 * Purpose: Create database views to support the Equipment Inventory Dashboard
 * 
 * Views Created:
 *   1. vw_EquipmentInventory_Dashboard_KPIs - Main KPI metrics
 *   2. vw_EquipmentInventory_ByType - Equipment count by type (ATE/Asset/Fixture/Harness)
 *   3. vw_EquipmentInventory_ByStatus - Equipment count by status
 *   4. vw_EquipmentInventory_ByLocation - Equipment count by location
 *   5. vw_EquipmentInventory_CalibrationStatus - Calibration status breakdown
 *   6. vw_EquipmentInventory_PMStatus - PM status breakdown
 *   7. vw_EquipmentInventory_RecentAdditions - Recently added equipment (last 30 days)
 *
 * Date: October 24, 2025
 *************************************************************************************************/

USE [TestEngineering]
GO

-- Drop existing views if they exist
IF OBJECT_ID('vw_EquipmentInventory_Dashboard_KPIs', 'V') IS NOT NULL
    DROP VIEW vw_EquipmentInventory_Dashboard_KPIs;
IF OBJECT_ID('vw_EquipmentInventory_ByType', 'V') IS NOT NULL
    DROP VIEW vw_EquipmentInventory_ByType;
IF OBJECT_ID('vw_EquipmentInventory_ByStatus', 'V') IS NOT NULL
    DROP VIEW vw_EquipmentInventory_ByStatus;
IF OBJECT_ID('vw_EquipmentInventory_ByLocation', 'V') IS NOT NULL
    DROP VIEW vw_EquipmentInventory_ByLocation;
IF OBJECT_ID('vw_EquipmentInventory_CalibrationStatus', 'V') IS NOT NULL
    DROP VIEW vw_EquipmentInventory_CalibrationStatus;
IF OBJECT_ID('vw_EquipmentInventory_PMStatus', 'V') IS NOT NULL
    DROP VIEW vw_EquipmentInventory_PMStatus;
IF OBJECT_ID('vw_EquipmentInventory_RecentAdditions', 'V') IS NOT NULL
    DROP VIEW vw_EquipmentInventory_RecentAdditions;
GO

/*************************************************************************************************
 * View 1: vw_EquipmentInventory_Dashboard_KPIs
 * Purpose: Calculate main KPI metrics for the dashboard
 *************************************************************************************************/
CREATE VIEW vw_EquipmentInventory_Dashboard_KPIs
AS
WITH AllEquipment AS (
    -- ATE Inventory
    SELECT 
        'ATE' AS EquipmentType,
        ATEStatus AS Status,
        RequiresCalibration,
        NextCalibration,
        RequiredPM,
        NextPM,
        IsActive
    FROM dbo.ATE_Inventory
    WHERE IsActive = 1
    
    UNION ALL
    
    -- Asset Inventory
    SELECT 
        'Asset' AS EquipmentType,
        CurrentStatus AS Status,
        RequiresCalibration,
        NextCalibration,
        RequiredPM,
        NextPM,
        IsActive
    FROM dbo.Asset_Inventory
    WHERE IsActive = 1
    
    UNION ALL
    
    -- Fixture Inventory
    SELECT 
        'Fixture' AS EquipmentType,
        CurrentStatus AS Status,
        RequiresCalibration,
        NextCalibration,
        RequiredPM,
        NextPM,
        IsActive
    FROM dbo.Fixture_Inventory
    WHERE IsActive = 1
    
    UNION ALL
    
    -- Harness Inventory
    SELECT 
        'Harness' AS EquipmentType,
        CurrentStatus AS Status,
        RequiresCalibration,
        NextCalibration,
        RequiredPM,
        NextPM,
        IsActive
    FROM dbo.Harness_Inventory
    WHERE IsActive = 1
)
SELECT
    -- Total Equipment Count
    (SELECT COUNT(*) FROM AllEquipment) AS TotalEquipment,
    
    -- Active Equipment Count
    (SELECT COUNT(*) FROM AllEquipment WHERE Status IN ('Active', 'In Use', 'Available')) AS ActiveEquipment,
    
    -- Equipment Requiring Calibration
    (SELECT COUNT(*) FROM AllEquipment WHERE RequiresCalibration = 1) AS RequiresCalibrationCount,
    
    -- Calibration Overdue (past NextCalibration date)
    (SELECT COUNT(*) 
     FROM AllEquipment 
     WHERE RequiresCalibration = 1 
       AND NextCalibration IS NOT NULL 
       AND NextCalibration < CAST(GETDATE() AS DATE)) AS CalibrationOverdue,
    
    -- Calibration Due Soon (within 30 days)
    (SELECT COUNT(*) 
     FROM AllEquipment 
     WHERE RequiresCalibration = 1 
       AND NextCalibration IS NOT NULL 
       AND NextCalibration >= CAST(GETDATE() AS DATE)
       AND NextCalibration <= DATEADD(DAY, 30, CAST(GETDATE() AS DATE))) AS CalibrationDueSoon,
    
    -- Equipment Requiring PM
    (SELECT COUNT(*) FROM AllEquipment WHERE RequiredPM = 1) AS RequiresPMCount,
    
    -- PM Overdue (past NextPM date)
    (SELECT COUNT(*) 
     FROM AllEquipment 
     WHERE RequiredPM = 1 
       AND NextPM IS NOT NULL 
       AND NextPM < CAST(GETDATE() AS DATE)) AS PMOverdue,
    
    -- PM Due Soon (within 30 days)
    (SELECT COUNT(*) 
     FROM AllEquipment 
     WHERE RequiredPM = 1 
       AND NextPM IS NOT NULL 
       AND NextPM >= CAST(GETDATE() AS DATE)
       AND NextPM <= DATEADD(DAY, 30, CAST(GETDATE() AS DATE))) AS PMDueSoon,
    
    -- Inactive Equipment Count
    (SELECT COUNT(*) FROM AllEquipment WHERE Status IN ('Inactive', 'Out of Service', 'Retired')) AS InactiveEquipment,
    
    -- Utilization Rate (Active / Total) as percentage
    CAST(
        CASE 
            WHEN (SELECT COUNT(*) FROM AllEquipment) > 0 
            THEN (SELECT COUNT(*) * 100.0 FROM AllEquipment WHERE Status IN ('Active', 'In Use', 'Available')) / 
                 (SELECT COUNT(*) FROM AllEquipment)
            ELSE 0 
        END AS DECIMAL(5,1)
    ) AS UtilizationRate;
GO

/*************************************************************************************************
 * View 2: vw_EquipmentInventory_ByType
 * Purpose: Equipment count by type (ATE, Asset, Fixture, Harness)
 *************************************************************************************************/
CREATE VIEW vw_EquipmentInventory_ByType
AS
SELECT 
    'ATE' AS EquipmentType,
    COUNT(*) AS EquipmentCount,
    SUM(CASE WHEN RequiresCalibration = 1 THEN 1 ELSE 0 END) AS RequiresCalibration,
    SUM(CASE WHEN RequiredPM = 1 THEN 1 ELSE 0 END) AS RequiresPM
FROM dbo.ATE_Inventory
WHERE IsActive = 1

UNION ALL

SELECT 
    'Asset' AS EquipmentType,
    COUNT(*) AS EquipmentCount,
    SUM(CASE WHEN RequiresCalibration = 1 THEN 1 ELSE 0 END) AS RequiresCalibration,
    SUM(CASE WHEN RequiredPM = 1 THEN 1 ELSE 0 END) AS RequiresPM
FROM dbo.Asset_Inventory
WHERE IsActive = 1

UNION ALL

SELECT 
    'Fixture' AS EquipmentType,
    COUNT(*) AS EquipmentCount,
    SUM(CASE WHEN RequiresCalibration = 1 THEN 1 ELSE 0 END) AS RequiresCalibration,
    SUM(CASE WHEN RequiredPM = 1 THEN 1 ELSE 0 END) AS RequiresPM
FROM dbo.Fixture_Inventory
WHERE IsActive = 1

UNION ALL

SELECT 
    'Harness' AS EquipmentType,
    COUNT(*) AS EquipmentCount,
    SUM(CASE WHEN RequiresCalibration = 1 THEN 1 ELSE 0 END) AS RequiresCalibration,
    SUM(CASE WHEN RequiredPM = 1 THEN 1 ELSE 0 END) AS RequiresPM
FROM dbo.Harness_Inventory
WHERE IsActive = 1;
GO

/*************************************************************************************************
 * View 3: vw_EquipmentInventory_ByStatus
 * Purpose: Equipment count by status
 *************************************************************************************************/
CREATE VIEW vw_EquipmentInventory_ByStatus
AS
WITH AllStatuses AS (
    SELECT ATEStatus AS Status FROM dbo.ATE_Inventory WHERE IsActive = 1
    UNION ALL
    SELECT CurrentStatus FROM dbo.Asset_Inventory WHERE IsActive = 1
    UNION ALL
    SELECT CurrentStatus FROM dbo.Fixture_Inventory WHERE IsActive = 1
    UNION ALL
    SELECT CurrentStatus FROM dbo.Harness_Inventory WHERE IsActive = 1
)
SELECT 
    ISNULL(Status, 'Unassigned') AS Status,
    COUNT(*) AS EquipmentCount
FROM AllStatuses
GROUP BY Status;
GO

/*************************************************************************************************
 * View 4: vw_EquipmentInventory_ByLocation
 * Purpose: Equipment count by location (TOP 10)
 *************************************************************************************************/
CREATE VIEW vw_EquipmentInventory_ByLocation
AS
WITH AllLocations AS (
    SELECT Location FROM dbo.ATE_Inventory WHERE IsActive = 1
    UNION ALL
    SELECT Location FROM dbo.Asset_Inventory WHERE IsActive = 1
    UNION ALL
    SELECT Location FROM dbo.Fixture_Inventory WHERE IsActive = 1
    UNION ALL
    SELECT Location FROM dbo.Harness_Inventory WHERE IsActive = 1
)
SELECT TOP 10
    ISNULL(Location, 'Unassigned') AS Location,
    COUNT(*) AS EquipmentCount
FROM AllLocations
GROUP BY Location
ORDER BY COUNT(*) DESC;
GO

/*************************************************************************************************
 * View 5: vw_EquipmentInventory_CalibrationStatus
 * Purpose: Calibration status breakdown
 *************************************************************************************************/
CREATE VIEW vw_EquipmentInventory_CalibrationStatus
AS
WITH AllEquipment AS (
    SELECT RequiresCalibration, NextCalibration FROM dbo.ATE_Inventory WHERE IsActive = 1
    UNION ALL
    SELECT RequiresCalibration, NextCalibration FROM dbo.Asset_Inventory WHERE IsActive = 1
    UNION ALL
    SELECT RequiresCalibration, NextCalibration FROM dbo.Fixture_Inventory WHERE IsActive = 1
    UNION ALL
    SELECT RequiresCalibration, NextCalibration FROM dbo.Harness_Inventory WHERE IsActive = 1
)
SELECT
    SUM(CASE WHEN RequiresCalibration = 0 THEN 1 ELSE 0 END) AS NotRequired,
    SUM(CASE 
        WHEN RequiresCalibration = 1 AND NextCalibration > DATEADD(DAY, 30, CAST(GETDATE() AS DATE)) 
        THEN 1 ELSE 0 
    END) AS [Current],
    SUM(CASE 
        WHEN RequiresCalibration = 1 
             AND NextCalibration >= CAST(GETDATE() AS DATE) 
             AND NextCalibration <= DATEADD(DAY, 30, CAST(GETDATE() AS DATE)) 
        THEN 1 ELSE 0 
    END) AS DueSoon,
    SUM(CASE 
        WHEN RequiresCalibration = 1 AND NextCalibration < CAST(GETDATE() AS DATE) 
        THEN 1 ELSE 0 
    END) AS Overdue
FROM AllEquipment;
GO

/*************************************************************************************************
 * View 6: vw_EquipmentInventory_PMStatus
 * Purpose: PM status breakdown
 *************************************************************************************************/
CREATE VIEW vw_EquipmentInventory_PMStatus
AS
WITH AllEquipment AS (
    SELECT RequiredPM, NextPM FROM dbo.ATE_Inventory WHERE IsActive = 1
    UNION ALL
    SELECT RequiredPM, NextPM FROM dbo.Asset_Inventory WHERE IsActive = 1
    UNION ALL
    SELECT RequiredPM, NextPM FROM dbo.Fixture_Inventory WHERE IsActive = 1
    UNION ALL
    SELECT RequiredPM, NextPM FROM dbo.Harness_Inventory WHERE IsActive = 1
)
SELECT
    SUM(CASE WHEN RequiredPM = 0 THEN 1 ELSE 0 END) AS NotRequired,
    SUM(CASE 
        WHEN RequiredPM = 1 AND NextPM > DATEADD(DAY, 30, CAST(GETDATE() AS DATE)) 
        THEN 1 ELSE 0 
    END) AS [Current],
    SUM(CASE 
        WHEN RequiredPM = 1 
             AND NextPM >= CAST(GETDATE() AS DATE) 
             AND NextPM <= DATEADD(DAY, 30, CAST(GETDATE() AS DATE)) 
        THEN 1 ELSE 0 
    END) AS DueSoon,
    SUM(CASE 
        WHEN RequiredPM = 1 AND NextPM < CAST(GETDATE() AS DATE) 
        THEN 1 ELSE 0 
    END) AS Overdue
FROM AllEquipment;
GO

/*************************************************************************************************
 * View 7: vw_EquipmentInventory_RecentAdditions
 * Purpose: Recently added equipment (last 30 days)
 *************************************************************************************************/
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
    CreatedDate,
    CreatedBy
FROM dbo.Harness_Inventory
WHERE IsActive = 1 AND CreatedDate >= DATEADD(DAY, -30, GETDATE());
GO

/*************************************************************************************************
 * Verification Queries (Optional - Run to test views)
 *************************************************************************************************/
-- Test KPIs
-- SELECT * FROM vw_EquipmentInventory_Dashboard_KPIs;

-- Test Equipment by Type
-- SELECT * FROM vw_EquipmentInventory_ByType ORDER BY EquipmentCount DESC;

-- Test Equipment by Status
-- SELECT * FROM vw_EquipmentInventory_ByStatus ORDER BY EquipmentCount DESC;

-- Test Equipment by Location
-- SELECT * FROM vw_EquipmentInventory_ByLocation;

-- Test Calibration Status
-- SELECT * FROM vw_EquipmentInventory_CalibrationStatus;

-- Test PM Status
-- SELECT * FROM vw_EquipmentInventory_PMStatus;

-- Test Recent Additions
-- SELECT TOP 10 * FROM vw_EquipmentInventory_RecentAdditions ORDER BY CreatedDate DESC;

PRINT 'Equipment Inventory Dashboard views created successfully!';
GO
