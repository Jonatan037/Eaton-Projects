-- =============================================
-- Equipment Inventory Sankey Diagram Data View
-- Purpose: Provides hierarchical data for Sankey visualization
-- Flow: Total Equipment -> Equipment Status -> Equipment Type -> Line
--       - 4-level hierarchy showing equipment distribution by status, type, and location
-- =============================================

USE TestEngineering;
GO

-- Drop existing view if it exists
IF OBJECT_ID('dbo.vw_EquipmentInventory_SankeyData', 'V') IS NOT NULL
    DROP VIEW dbo.vw_EquipmentInventory_SankeyData;
GO

CREATE VIEW dbo.vw_EquipmentInventory_SankeyData
AS
-- Level 1: Total Equipment -> Equipment Status
-- Level 1: Total Equipment -> Equipment Status (using actual status values)
SELECT 
    'Total Equipment' AS SourceNode,
    ISNULL(NULLIF(ATEStatus, ''), 'Unknown') AS TargetNode,
    COUNT(*) AS Value
FROM ATE_Inventory
WHERE IsActive = 1
GROUP BY ISNULL(NULLIF(ATEStatus, ''), 'Unknown')

UNION ALL

SELECT 
    'Total Equipment' AS SourceNode,
    ISNULL(NULLIF(CurrentStatus, ''), 'Unknown') AS TargetNode,
    COUNT(*) AS Value
FROM Asset_Inventory
WHERE IsActive = 1
GROUP BY ISNULL(NULLIF(CurrentStatus, ''), 'Unknown')

UNION ALL

SELECT 
    'Total Equipment' AS SourceNode,
    ISNULL(NULLIF(CurrentStatus, ''), 'Unknown') AS TargetNode,
    COUNT(*) AS Value
FROM Fixture_Inventory
WHERE IsActive = 1
GROUP BY ISNULL(NULLIF(CurrentStatus, ''), 'Unknown')

UNION ALL

SELECT 
    'Total Equipment' AS SourceNode,
    ISNULL(NULLIF(CurrentStatus, ''), 'Unknown') AS TargetNode,
    COUNT(*) AS Value
FROM Harness_Inventory
WHERE IsActive = 1
GROUP BY ISNULL(NULLIF(CurrentStatus, ''), 'Unknown')

UNION ALL

-- Level 2: Equipment Status -> Equipment Type
-- For each distinct status, create links to equipment types
SELECT 
    ISNULL(NULLIF(ATEStatus, ''), 'Unknown') AS SourceNode,
    'ATE' AS TargetNode,
    COUNT(*) AS Value
FROM ATE_Inventory
WHERE IsActive = 1
GROUP BY ISNULL(NULLIF(ATEStatus, ''), 'Unknown')

UNION ALL

SELECT 
    ISNULL(NULLIF(CurrentStatus, ''), 'Unknown') AS SourceNode,
    'Asset' AS TargetNode,
    COUNT(*) AS Value
FROM Asset_Inventory
WHERE IsActive = 1
GROUP BY ISNULL(NULLIF(CurrentStatus, ''), 'Unknown')

UNION ALL

SELECT 
    ISNULL(NULLIF(CurrentStatus, ''), 'Unknown') AS SourceNode,
    'Fixture' AS TargetNode,
    COUNT(*) AS Value
FROM Fixture_Inventory
WHERE IsActive = 1
GROUP BY ISNULL(NULLIF(CurrentStatus, ''), 'Unknown')

UNION ALL

SELECT 
    ISNULL(NULLIF(CurrentStatus, ''), 'Unknown') AS SourceNode,
    'Harness' AS TargetNode,
    COUNT(*) AS Value
FROM Harness_Inventory
WHERE IsActive = 1
GROUP BY ISNULL(NULLIF(CurrentStatus, ''), 'Unknown')

UNION ALL

-- Level 3: Equipment Type -> Line (extract first part before first dash)
-- ATE -> Line
SELECT 
    'ATE' AS SourceNode,
    CASE 
        WHEN Location LIKE '%-%' THEN 
            LTRIM(RTRIM(LEFT(Location, CHARINDEX('-', Location) - 1)))
        ELSE 
            ISNULL(NULLIF(LTRIM(RTRIM(Location)), ''), 'Unassigned')
    END AS TargetNode,
    COUNT(*) AS Value
FROM ATE_Inventory
WHERE IsActive = 1
GROUP BY CASE 
        WHEN Location LIKE '%-%' THEN 
            LTRIM(RTRIM(LEFT(Location, CHARINDEX('-', Location) - 1)))
        ELSE 
            ISNULL(NULLIF(LTRIM(RTRIM(Location)), ''), 'Unassigned')
    END
HAVING COUNT(*) > 0

UNION ALL

-- Asset -> Line
SELECT 
    'Asset' AS SourceNode,
    CASE 
        WHEN Location LIKE '%-%' THEN 
            LTRIM(RTRIM(LEFT(Location, CHARINDEX('-', Location) - 1)))
        ELSE 
            ISNULL(NULLIF(LTRIM(RTRIM(Location)), ''), 'Unassigned')
    END AS TargetNode,
    COUNT(*) AS Value
FROM Asset_Inventory
WHERE IsActive = 1
GROUP BY CASE 
        WHEN Location LIKE '%-%' THEN 
            LTRIM(RTRIM(LEFT(Location, CHARINDEX('-', Location) - 1)))
        ELSE 
            ISNULL(NULLIF(LTRIM(RTRIM(Location)), ''), 'Unassigned')
    END
HAVING COUNT(*) > 0

UNION ALL

-- Fixture -> Line
SELECT 
    'Fixture' AS SourceNode,
    CASE 
        WHEN Location LIKE '%-%' THEN 
            LTRIM(RTRIM(LEFT(Location, CHARINDEX('-', Location) - 1)))
        ELSE 
            ISNULL(NULLIF(LTRIM(RTRIM(Location)), ''), 'Unassigned')
    END AS TargetNode,
    COUNT(*) AS Value
FROM Fixture_Inventory
WHERE IsActive = 1
GROUP BY CASE 
        WHEN Location LIKE '%-%' THEN 
            LTRIM(RTRIM(LEFT(Location, CHARINDEX('-', Location) - 1)))
        ELSE 
            ISNULL(NULLIF(LTRIM(RTRIM(Location)), ''), 'Unassigned')
    END
HAVING COUNT(*) > 0

UNION ALL

-- Harness -> Line
SELECT 
    'Harness' AS SourceNode,
    CASE 
        WHEN Location LIKE '%-%' THEN 
            LTRIM(RTRIM(LEFT(Location, CHARINDEX('-', Location) - 1)))
        ELSE 
            ISNULL(NULLIF(LTRIM(RTRIM(Location)), ''), 'Unassigned')
    END AS TargetNode,
    COUNT(*) AS Value
FROM Harness_Inventory
WHERE IsActive = 1
GROUP BY CASE 
        WHEN Location LIKE '%-%' THEN 
            LTRIM(RTRIM(LEFT(Location, CHARINDEX('-', Location) - 1)))
        ELSE 
            ISNULL(NULLIF(LTRIM(RTRIM(Location)), ''), 'Unassigned')
    END
HAVING COUNT(*) > 0;

GO

-- Test the view
SELECT * FROM vw_EquipmentInventory_SankeyData
ORDER BY SourceNode, TargetNode;
