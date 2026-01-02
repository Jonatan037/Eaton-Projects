/*************************************************************************************************
 * Create Troubleshooting Issues by Line and Location View
 * Purpose: Return issue count grouped by Line (extracted from Location)
 *          AND detailed Location for drill-down functionality
 * Date: October 28, 2025
 * Note: Line is extracted from Location field (e.g., "rPDU - Line 4" -> Line: "rPDU")
 *************************************************************************************************/

USE [TestEngineering]
GO

-- ============================================================================
-- VIEW 1: Issues by Line (Top Level)
-- ============================================================================
IF OBJECT_ID('vw_Troubleshooting_IssuesByLine', 'V') IS NOT NULL
    DROP VIEW vw_Troubleshooting_IssuesByLine;
GO

CREATE VIEW vw_Troubleshooting_IssuesByLine
AS
WITH EquipmentLocations AS (
    -- Get locations from ATE equipment
    SELECT 
        tl.ID AS IssueID,
        ISNULL(ate.Location, 'Unknown') AS Location
    FROM Troubleshooting_Log tl
    LEFT JOIN ATE_Inventory ate ON tl.AffectedATE = ate.EatonID
    WHERE tl.AffectedATE IS NOT NULL 
        AND tl.AffectedATE <> ''
        AND (tl.ReportedDateTime >= DATEADD(MONTH, -12, GETDATE())
             OR tl.Status NOT IN ('Resolved', 'Closed')
             OR tl.Status IS NULL)
    
    UNION ALL
    
    -- Get locations from Asset equipment
    SELECT 
        tl.ID AS IssueID,
        ISNULL(asset.Location, 'Unknown') AS Location
    FROM Troubleshooting_Log tl
    LEFT JOIN Asset_Inventory asset ON tl.AffectedEquipment = asset.EatonID
    WHERE tl.AffectedEquipment IS NOT NULL 
        AND tl.AffectedEquipment <> ''
        AND (tl.ReportedDateTime >= DATEADD(MONTH, -12, GETDATE())
             OR tl.Status NOT IN ('Resolved', 'Closed')
             OR tl.Status IS NULL)
    
    UNION ALL
    
    -- Get locations from Fixture equipment
    SELECT 
        tl.ID AS IssueID,
        ISNULL(fixture.Location, 'Unknown') AS Location
    FROM Troubleshooting_Log tl
    LEFT JOIN Fixture_Inventory fixture ON tl.AffectedFixture = fixture.EatonID
    WHERE tl.AffectedFixture IS NOT NULL 
        AND tl.AffectedFixture <> ''
        AND (tl.ReportedDateTime >= DATEADD(MONTH, -12, GETDATE())
             OR tl.Status NOT IN ('Resolved', 'Closed')
             OR tl.Status IS NULL)
    
    UNION ALL
    
    -- Get locations from Harness equipment
    SELECT 
        tl.ID AS IssueID,
        ISNULL(harness.Location, 'Unknown') AS Location
    FROM Troubleshooting_Log tl
    LEFT JOIN Harness_Inventory harness ON tl.AffectedHarness = harness.EatonID
    WHERE tl.AffectedHarness IS NOT NULL 
        AND tl.AffectedHarness <> ''
        AND (tl.ReportedDateTime >= DATEADD(MONTH, -12, GETDATE())
             OR tl.Status NOT IN ('Resolved', 'Closed')
             OR tl.Status IS NULL)
),
ExtractedLines AS (
    SELECT 
        IssueID,
        Location,
        CASE 
            WHEN Location LIKE '%-%' THEN LTRIM(RTRIM(LEFT(Location, CHARINDEX('-', Location) - 1)))
            ELSE ISNULL(Location, 'Unknown')
        END AS Line
    FROM EquipmentLocations
)
SELECT TOP 15
    Line,
    COUNT(DISTINCT IssueID) AS IssueCount
FROM ExtractedLines
WHERE Line IS NOT NULL
GROUP BY Line
ORDER BY COUNT(DISTINCT IssueID) DESC;
GO

PRINT 'View vw_Troubleshooting_IssuesByLine created successfully';
GO


-- ============================================================================
-- VIEW 2: Issues by Line AND Location (For Drill-Down)
-- ============================================================================
IF OBJECT_ID('vw_Troubleshooting_IssuesByLineAndLocation', 'V') IS NOT NULL
    DROP VIEW vw_Troubleshooting_IssuesByLineAndLocation;
GO

CREATE VIEW vw_Troubleshooting_IssuesByLineAndLocation
AS
WITH EquipmentLocations AS (
    -- Get locations from ATE equipment
    SELECT 
        tl.ID AS IssueID,
        ISNULL(ate.Location, 'Unknown') AS Location
    FROM Troubleshooting_Log tl
    LEFT JOIN ATE_Inventory ate ON tl.AffectedATE = ate.EatonID
    WHERE tl.AffectedATE IS NOT NULL 
        AND tl.AffectedATE <> ''
        AND (tl.ReportedDateTime >= DATEADD(MONTH, -12, GETDATE())
             OR tl.Status NOT IN ('Resolved', 'Closed')
             OR tl.Status IS NULL)
    
    UNION ALL
    
    -- Get locations from Asset equipment
    SELECT 
        tl.ID AS IssueID,
        ISNULL(asset.Location, 'Unknown') AS Location
    FROM Troubleshooting_Log tl
    LEFT JOIN Asset_Inventory asset ON tl.AffectedEquipment = asset.EatonID
    WHERE tl.AffectedEquipment IS NOT NULL 
        AND tl.AffectedEquipment <> ''
        AND (tl.ReportedDateTime >= DATEADD(MONTH, -12, GETDATE())
             OR tl.Status NOT IN ('Resolved', 'Closed')
             OR tl.Status IS NULL)
    
    UNION ALL
    
    -- Get locations from Fixture equipment
    SELECT 
        tl.ID AS IssueID,
        ISNULL(fixture.Location, 'Unknown') AS Location
    FROM Troubleshooting_Log tl
    LEFT JOIN Fixture_Inventory fixture ON tl.AffectedFixture = fixture.EatonID
    WHERE tl.AffectedFixture IS NOT NULL 
        AND tl.AffectedFixture <> ''
        AND (tl.ReportedDateTime >= DATEADD(MONTH, -12, GETDATE())
             OR tl.Status NOT IN ('Resolved', 'Closed')
             OR tl.Status IS NULL)
    
    UNION ALL
    
    -- Get locations from Harness equipment
    SELECT 
        tl.ID AS IssueID,
        ISNULL(harness.Location, 'Unknown') AS Location
    FROM Troubleshooting_Log tl
    LEFT JOIN Harness_Inventory harness ON tl.AffectedHarness = harness.EatonID
    WHERE tl.AffectedHarness IS NOT NULL 
        AND tl.AffectedHarness <> ''
        AND (tl.ReportedDateTime >= DATEADD(MONTH, -12, GETDATE())
             OR tl.Status NOT IN ('Resolved', 'Closed')
             OR tl.Status IS NULL)
),
ExtractedLines AS (
    SELECT 
        IssueID,
        Location,
        CASE 
            WHEN Location LIKE '%-%' THEN LTRIM(RTRIM(LEFT(Location, CHARINDEX('-', Location) - 1)))
            ELSE ISNULL(Location, 'Unknown')
        END AS Line
    FROM EquipmentLocations
)
SELECT 
    Line,
    Location,
    COUNT(DISTINCT IssueID) AS IssueCount
FROM ExtractedLines
WHERE Line IS NOT NULL AND Location IS NOT NULL
GROUP BY Line, Location;
GO

PRINT 'View vw_Troubleshooting_IssuesByLineAndLocation created successfully';
GO


-- ============================================================================
-- TEST QUERIES
-- ============================================================================

-- Test 1: Issues by Line (Top Level View)
PRINT '';
PRINT '=== TEST 1: Issues by Line (Top Level) ===';
SELECT * FROM vw_Troubleshooting_IssuesByLine;

-- Test 2: Issues by Line AND Location (Drill-Down Data)
PRINT '';
PRINT '=== TEST 2: Issues by Line and Location (Full Hierarchy) ===';
SELECT 
    Line,
    Location,
    IssueCount
FROM vw_Troubleshooting_IssuesByLineAndLocation
ORDER BY Line, IssueCount DESC;

-- Test 3: Sample Drill-Down - Show locations for a specific line
PRINT '';
PRINT '=== TEST 3: Sample Drill-Down (Locations within first line) ===';
DECLARE @SampleLine NVARCHAR(255);
SELECT TOP 1 @SampleLine = Line FROM vw_Troubleshooting_IssuesByLine ORDER BY IssueCount DESC;

PRINT 'Drilling into Line: ' + @SampleLine;
SELECT 
    Location,
    IssueCount
FROM vw_Troubleshooting_IssuesByLineAndLocation
WHERE Line = @SampleLine
ORDER BY IssueCount DESC;

PRINT '';
PRINT 'Views created successfully!';
GO

/*************************************************************************************************
 * USAGE NOTES:
 * 
 * 1. For main chart (Issues by Line):
 *    SELECT * FROM vw_Troubleshooting_IssuesByLine
 *    Returns: Line, IssueCount (Top 15)
 * 
 * 2. For drill-down (Issues within a specific Line):
 *    SELECT Location, IssueCount 
 *    FROM vw_Troubleshooting_IssuesByLineAndLocation
 *    WHERE Line = @SelectedLine
 *    ORDER BY IssueCount DESC
 * 
 * 3. Chart Implementation:
 *    - Display bar chart with data from vw_Troubleshooting_IssuesByLine
 *    - On bar click, query vw_Troubleshooting_IssuesByLineAndLocation filtered by Line
 *    - Show drill-down chart with locations within that line
 *    - Add "Back" button to return to line-level view
 * 
 *************************************************************************************************/
