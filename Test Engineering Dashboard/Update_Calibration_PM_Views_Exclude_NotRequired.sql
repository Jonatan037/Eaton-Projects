/*************************************************************************************************
 * Update Equipment Inventory Dashboard Views
 * Purpose: Modify Calibration and PM Status views to exclude "Not Required" values
 * Date: October 27, 2025
 *************************************************************************************************/

USE [TestEngineering]
GO

-- Drop and recreate vw_EquipmentInventory_CalibrationStatus
IF OBJECT_ID('vw_EquipmentInventory_CalibrationStatus', 'V') IS NOT NULL
    DROP VIEW vw_EquipmentInventory_CalibrationStatus;
GO

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
    -- Only include equipment that requires calibration
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
FROM AllEquipment
WHERE RequiresCalibration = 1;  -- Filter to only include equipment requiring calibration
GO

-- Drop and recreate vw_EquipmentInventory_PMStatus
IF OBJECT_ID('vw_EquipmentInventory_PMStatus', 'V') IS NOT NULL
    DROP VIEW vw_EquipmentInventory_PMStatus;
GO

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
    -- Only include equipment that requires PM
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
FROM AllEquipment
WHERE RequiredPM = 1;  -- Filter to only include equipment requiring PM
GO

PRINT 'Views updated successfully - "Not Required" values are now excluded from Calibration and PM Status charts';
GO
