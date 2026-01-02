/*************************************************************************************************
 * Update Equipment by Line View - Stacked by Equipment Type
 * Purpose: Return equipment count grouped by Line AND Equipment Type (for stacked chart)
 * Date: October 27, 2025
 * Note: Similar structure to vw_EquipmentInventory_ByLocation but for Line
 *************************************************************************************************/

USE [TestEngineering]
GO

-- Drop and recreate vw_EquipmentInventory_ByLine
IF OBJECT_ID('vw_EquipmentInventory_ByLine', 'V') IS NOT NULL
    DROP VIEW vw_EquipmentInventory_ByLine;
GO

CREATE VIEW vw_EquipmentInventory_ByLine
AS
WITH AllEquipment AS (
    SELECT 
        Location,
        'ATE' AS EquipmentType
    FROM dbo.ATE_Inventory 
    WHERE IsActive = 1
    
    UNION ALL
    
    SELECT 
        Location,
        'Asset' AS EquipmentType
    FROM dbo.Asset_Inventory 
    WHERE IsActive = 1
    
    UNION ALL
    
    SELECT 
        Location,
        'Fixture' AS EquipmentType
    FROM dbo.Fixture_Inventory 
    WHERE IsActive = 1
    
    UNION ALL
    
    SELECT 
        Location,
        'Harness' AS EquipmentType
    FROM dbo.Harness_Inventory 
    WHERE IsActive = 1
),
ExtractedLines AS (
    SELECT 
        CASE 
            WHEN Location LIKE '%-%' THEN LTRIM(RTRIM(LEFT(Location, CHARINDEX('-', Location) - 1)))
            ELSE ISNULL(Location, 'Unassigned')
        END AS Line,
        EquipmentType
    FROM AllEquipment
),
LineTotals AS (
    SELECT 
        Line,
        COUNT(*) AS TotalForLine
    FROM ExtractedLines
    GROUP BY Line
)
SELECT 
    ISNULL(el.Line, 'Unassigned') AS Line,
    el.EquipmentType,
    COUNT(*) AS EquipmentCount,
    lt.TotalForLine
FROM ExtractedLines el
INNER JOIN LineTotals lt ON el.Line = lt.Line
GROUP BY el.Line, el.EquipmentType, lt.TotalForLine;
GO

PRINT 'View vw_EquipmentInventory_ByLine updated successfully';
GO

-- Test query
SELECT 'Test Results - Line with Equipment Type breakdown:' AS Info;
SELECT * FROM vw_EquipmentInventory_ByLine ORDER BY TotalForLine DESC, Line, EquipmentType;
GO
