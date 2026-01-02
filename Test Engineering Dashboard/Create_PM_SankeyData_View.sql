-- =============================================
-- PM Sankey Diagram Data View
-- Purpose: Provides hierarchical data for PM Sankey visualization
-- Flow: Total Equipment (Requiring PM) -> Equipment Type -> PM Status (Current Year)
--       - 3-level hierarchy showing PM distribution
-- =============================================

USE TestEngineering;
GO

-- Drop existing view if it exists
IF OBJECT_ID('dbo.vw_PM_SankeyData', 'V') IS NOT NULL
    DROP VIEW dbo.vw_PM_SankeyData;
GO

CREATE VIEW dbo.vw_PM_SankeyData
AS
-- Level 1: Total Equipment (Requiring PM) -> Equipment Type
SELECT 
    'Total Equipment' AS SourceNode,
    'ATE' AS TargetNode,
    COUNT(*) AS Value
FROM ATE_Inventory
WHERE RequiredPM = 1 AND IsActive = 1

UNION ALL

SELECT 
    'Total Equipment' AS SourceNode,
    'Asset' AS TargetNode,
    COUNT(*) AS Value
FROM Asset_Inventory
WHERE RequiredPM = 1 AND IsActive = 1

UNION ALL

SELECT 
    'Total Equipment' AS SourceNode,
    'Fixture' AS TargetNode,
    COUNT(*) AS Value
FROM Fixture_Inventory
WHERE RequiredPM = 1 AND IsActive = 1

UNION ALL

SELECT 
    'Total Equipment' AS SourceNode,
    'Harness' AS TargetNode,
    COUNT(*) AS Value
FROM Harness_Inventory
WHERE RequiredPM = 1 AND IsActive = 1

UNION ALL

-- Level 2: Equipment Type -> PM Status (Current Year)
-- ATE -> Pending PM / No Pending PM
SELECT 
    'ATE' AS SourceNode,
    CASE 
        WHEN NextPM IS NOT NULL AND YEAR(NextPM) = YEAR(GETDATE()) 
        THEN 'Pending PM'
        ELSE 'No Pending PM'
    END AS TargetNode,
    COUNT(*) AS Value
FROM ATE_Inventory
WHERE RequiredPM = 1 AND IsActive = 1
GROUP BY CASE 
        WHEN NextPM IS NOT NULL AND YEAR(NextPM) = YEAR(GETDATE()) 
        THEN 'Pending PM'
        ELSE 'No Pending PM'
    END
HAVING COUNT(*) > 0

UNION ALL

-- Asset -> Pending PM / No Pending PM
SELECT 
    'Asset' AS SourceNode,
    CASE 
        WHEN NextPM IS NOT NULL AND YEAR(NextPM) = YEAR(GETDATE()) 
        THEN 'Pending PM'
        ELSE 'No Pending PM'
    END AS TargetNode,
    COUNT(*) AS Value
FROM Asset_Inventory
WHERE RequiredPM = 1 AND IsActive = 1
GROUP BY CASE 
        WHEN NextPM IS NOT NULL AND YEAR(NextPM) = YEAR(GETDATE()) 
        THEN 'Pending PM'
        ELSE 'No Pending PM'
    END
HAVING COUNT(*) > 0

UNION ALL

-- Fixture -> Pending PM / No Pending PM
SELECT 
    'Fixture' AS SourceNode,
    CASE 
        WHEN NextPM IS NOT NULL AND YEAR(NextPM) = YEAR(GETDATE()) 
        THEN 'Pending PM'
        ELSE 'No Pending PM'
    END AS TargetNode,
    COUNT(*) AS Value
FROM Fixture_Inventory
WHERE RequiredPM = 1 AND IsActive = 1
GROUP BY CASE 
        WHEN NextPM IS NOT NULL AND YEAR(NextPM) = YEAR(GETDATE()) 
        THEN 'Pending PM'
        ELSE 'No Pending PM'
    END
HAVING COUNT(*) > 0

UNION ALL

-- Harness -> Pending PM / No Pending PM
SELECT 
    'Harness' AS SourceNode,
    CASE 
        WHEN NextPM IS NOT NULL AND YEAR(NextPM) = YEAR(GETDATE()) 
        THEN 'Pending PM'
        ELSE 'No Pending PM'
    END AS TargetNode,
    COUNT(*) AS Value
FROM Harness_Inventory
WHERE RequiredPM = 1 AND IsActive = 1
GROUP BY CASE 
        WHEN NextPM IS NOT NULL AND YEAR(NextPM) = YEAR(GETDATE()) 
        THEN 'Pending PM'
        ELSE 'No Pending PM'
    END
HAVING COUNT(*) > 0;

GO

-- Test the view
SELECT * FROM vw_PM_SankeyData
ORDER BY SourceNode, TargetNode;
