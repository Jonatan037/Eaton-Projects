/*************************************************************************************************
 * Create Troubleshooting Issues by Location View
 * Purpose: Return issue count grouped by location from affected equipment
 * Date: October 27, 2025
 *************************************************************************************************/

USE [TestEngineering]
GO

-- Drop and create vw_Troubleshooting_IssuesByLocation
IF OBJECT_ID('vw_Troubleshooting_IssuesByLocation', 'V') IS NOT NULL
    DROP VIEW vw_Troubleshooting_IssuesByLocation;
GO

CREATE VIEW vw_Troubleshooting_IssuesByLocation
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
)
SELECT TOP 15
    Location,
    COUNT(*) AS IssueCount
FROM EquipmentLocations
WHERE Location IS NOT NULL
GROUP BY Location
ORDER BY COUNT(*) DESC;
GO

PRINT 'View vw_Troubleshooting_IssuesByLocation created successfully';
GO

-- Test query
SELECT 'Test Results - Top Locations by Issue Count:' AS Info;
SELECT * FROM vw_Troubleshooting_IssuesByLocation;
GO
