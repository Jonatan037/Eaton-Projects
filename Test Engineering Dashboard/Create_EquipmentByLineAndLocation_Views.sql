-- =============================================
-- Equipment Drill-Down Views for 3-Level Chart
-- Level 1: By Line (already exists: vw_EquipmentInventory_ByLine)
-- Level 2: By Line and Location (this view)
-- Level 3: Individual Equipment IDs (queried directly from tables in C#)
-- =============================================

USE [TestEngineering]
GO

-- Drop view if it exists
IF OBJECT_ID('dbo.vw_EquipmentInventory_ByLineAndLocation', 'V') IS NOT NULL
    DROP VIEW dbo.vw_EquipmentInventory_ByLineAndLocation;
GO

-- Create view for Level 2: Locations within a Line
-- Extracts Line from Location field (before first dash) and groups by full Location
CREATE VIEW dbo.vw_EquipmentInventory_ByLineAndLocation
AS
SELECT 
    Line,
    Location,
    EquipmentType,
    COUNT(*) AS EquipmentCount
FROM (
    -- Asset Inventory
    SELECT 
        CASE 
            WHEN Location LIKE '%-%' THEN LTRIM(RTRIM(LEFT(Location, CHARINDEX('-', Location) - 1)))
            ELSE ISNULL(Location, 'Unassigned')
        END AS Line,
        ISNULL(Location, 'Unknown Location') AS Location,
        'Asset' AS EquipmentType
    FROM Asset_Inventory
    WHERE IsActive = 1
    
    UNION ALL
    
    -- ATE Inventory
    SELECT 
        CASE 
            WHEN Location LIKE '%-%' THEN LTRIM(RTRIM(LEFT(Location, CHARINDEX('-', Location) - 1)))
            ELSE ISNULL(Location, 'Unassigned')
        END AS Line,
        ISNULL(Location, 'Unknown Location') AS Location,
        'ATE' AS EquipmentType
    FROM ATE_Inventory
    WHERE IsActive = 1
    
    UNION ALL
    
    -- Fixture Inventory
    SELECT 
        CASE 
            WHEN Location LIKE '%-%' THEN LTRIM(RTRIM(LEFT(Location, CHARINDEX('-', Location) - 1)))
            ELSE ISNULL(Location, 'Unassigned')
        END AS Line,
        ISNULL(Location, 'Unknown Location') AS Location,
        'Fixture' AS EquipmentType
    FROM Fixture_Inventory
    WHERE IsActive = 1
    
    UNION ALL
    
    -- Harness Inventory
    SELECT 
        CASE 
            WHEN Location LIKE '%-%' THEN LTRIM(RTRIM(LEFT(Location, CHARINDEX('-', Location) - 1)))
            ELSE ISNULL(Location, 'Unassigned')
        END AS Line,
        ISNULL(Location, 'Unknown Location') AS Location,
        'Harness' AS EquipmentType
    FROM Harness_Inventory
    WHERE IsActive = 1
) AS AllEquipment
WHERE Line IS NOT NULL AND Line != ''
  AND Location IS NOT NULL AND Location != ''
GROUP BY Line, Location, EquipmentType;
GO

-- Test the view
PRINT 'Testing view with Battery Line data:';
SELECT TOP 20 
    Line,
    Location,
    EquipmentType,
    EquipmentCount
FROM dbo.vw_EquipmentInventory_ByLineAndLocation
WHERE Line = 'Battery Line'
ORDER BY Location, EquipmentType;
GO

PRINT '';
PRINT 'View vw_EquipmentInventory_ByLineAndLocation created successfully!';
PRINT 'This view supports Level 2 drill-down (Line -> Location)';
PRINT 'Level 3 (Location -> Equipment IDs) will be queried directly from inventory tables';
GO
