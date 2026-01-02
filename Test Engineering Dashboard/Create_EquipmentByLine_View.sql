/*************************************************************************************************
 * Create Equipment by Line View
 * Purpose: Return equipment count grouped by Line (first part of Location before dash)
 * Date: October 27, 2025
 * Note: Extracts Line from Location field (e.g., "rPDU - Line 4" -> "rPDU")
 *************************************************************************************************/

USE [TestEngineering]
GO

-- Drop and create vw_EquipmentInventory_ByLine
IF OBJECT_ID('vw_EquipmentInventory_ByLine', 'V') IS NOT NULL
    DROP VIEW vw_EquipmentInventory_ByLine;
GO

CREATE VIEW vw_EquipmentInventory_ByLine
AS
WITH AllLocations AS (
    SELECT Location FROM dbo.ATE_Inventory WHERE IsActive = 1
    UNION ALL
    SELECT Location FROM dbo.Asset_Inventory WHERE IsActive = 1
    UNION ALL
    SELECT Location FROM dbo.Fixture_Inventory WHERE IsActive = 1
    UNION ALL
    SELECT Location FROM dbo.Harness_Inventory WHERE IsActive = 1
),
ExtractedLines AS (
    SELECT 
        CASE 
            WHEN Location LIKE '%-%' THEN LTRIM(RTRIM(LEFT(Location, CHARINDEX('-', Location) - 1)))
            ELSE ISNULL(Location, 'Unassigned')
        END AS Line
    FROM AllLocations
)
SELECT 
    ISNULL(Line, 'Unassigned') AS Line,
    COUNT(*) AS EquipmentCount
FROM ExtractedLines
GROUP BY Line;
GO

PRINT 'View vw_EquipmentInventory_ByLine created successfully';
GO

-- Test query
SELECT 'Test Results:' AS Info;
SELECT * FROM vw_EquipmentInventory_ByLine ORDER BY EquipmentCount DESC;
GO
