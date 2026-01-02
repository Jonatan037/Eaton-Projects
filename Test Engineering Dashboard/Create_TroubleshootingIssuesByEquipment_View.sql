/*************************************************************************************************
 * Create Troubleshooting Issues by Equipment View
 * Purpose: Return issue count grouped by specific equipment ID (ATE, Asset, Fixture, Harness)
 * Date: October 27, 2025
 *************************************************************************************************/

USE [TestEngineering]
GO

-- Drop and create vw_Troubleshooting_IssuesByEquipment
IF OBJECT_ID('vw_Troubleshooting_IssuesByEquipment', 'V') IS NOT NULL
    DROP VIEW vw_Troubleshooting_IssuesByEquipment;
GO

CREATE VIEW vw_Troubleshooting_IssuesByEquipment
AS
WITH AllEquipment AS (
    -- ATE Issues
    SELECT 
        AffectedATE AS EquipmentID,
        'ATE' AS EquipmentType
    FROM Troubleshooting_Log
    WHERE AffectedATE IS NOT NULL 
        AND AffectedATE <> ''
        AND (ReportedDateTime >= DATEADD(MONTH, -12, GETDATE())
             OR Status NOT IN ('Resolved', 'Closed')
             OR Status IS NULL)
    
    UNION ALL
    
    -- Asset/Equipment Issues
    SELECT 
        AffectedEquipment AS EquipmentID,
        'Asset' AS EquipmentType
    FROM Troubleshooting_Log
    WHERE AffectedEquipment IS NOT NULL 
        AND AffectedEquipment <> ''
        AND (ReportedDateTime >= DATEADD(MONTH, -12, GETDATE())
             OR Status NOT IN ('Resolved', 'Closed')
             OR Status IS NULL)
    
    UNION ALL
    
    -- Fixture Issues
    SELECT 
        AffectedFixture AS EquipmentID,
        'Fixture' AS EquipmentType
    FROM Troubleshooting_Log
    WHERE AffectedFixture IS NOT NULL 
        AND AffectedFixture <> ''
        AND (ReportedDateTime >= DATEADD(MONTH, -12, GETDATE())
             OR Status NOT IN ('Resolved', 'Closed')
             OR Status IS NULL)
    
    UNION ALL
    
    -- Harness Issues
    SELECT 
        AffectedHarness AS EquipmentID,
        'Harness' AS EquipmentType
    FROM Troubleshooting_Log
    WHERE AffectedHarness IS NOT NULL 
        AND AffectedHarness <> ''
        AND (ReportedDateTime >= DATEADD(MONTH, -12, GETDATE())
             OR Status NOT IN ('Resolved', 'Closed')
             OR Status IS NULL)
)
SELECT TOP 15
    EquipmentID,
    EquipmentType,
    COUNT(*) AS IssueCount
FROM AllEquipment
GROUP BY EquipmentID, EquipmentType
ORDER BY COUNT(*) DESC;
GO

PRINT 'View vw_Troubleshooting_IssuesByEquipment created successfully';
GO

-- Test query
SELECT 'Test Results - Top Equipment by Issue Count:' AS Info;
SELECT * FROM vw_Troubleshooting_IssuesByEquipment;
GO
