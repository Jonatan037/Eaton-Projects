/*************************************************************************************************
 * Create Troubleshooting Sankey Diagram Data View
 * Purpose: Return hierarchical data for Sankey flow diagram
 *          Total Issues -> Equipment Type -> Specific Equipment
 * Date: October 28, 2025
 *************************************************************************************************/

USE [TestEngineering]
GO

-- Drop and create vw_Troubleshooting_SankeyData
IF OBJECT_ID('vw_Troubleshooting_SankeyData', 'V') IS NOT NULL
    DROP VIEW vw_Troubleshooting_SankeyData;
GO

CREATE VIEW vw_Troubleshooting_SankeyData
AS
WITH EquipmentIssues AS (
    -- ATE Issues
    SELECT 
        'ATE' AS EquipmentType,
        AffectedATE AS EquipmentID,
        COUNT(*) AS IssueCount
    FROM Troubleshooting_Log
    WHERE AffectedATE IS NOT NULL 
        AND AffectedATE <> ''
        AND (ReportedDateTime >= DATEADD(MONTH, -12, GETDATE())
             OR Status NOT IN ('Resolved', 'Closed')
             OR Status IS NULL)
    GROUP BY AffectedATE
    
    UNION ALL
    
    -- Asset/Equipment Issues
    SELECT 
        'Asset' AS EquipmentType,
        AffectedEquipment AS EquipmentID,
        COUNT(*) AS IssueCount
    FROM Troubleshooting_Log
    WHERE AffectedEquipment IS NOT NULL 
        AND AffectedEquipment <> ''
        AND (ReportedDateTime >= DATEADD(MONTH, -12, GETDATE())
             OR Status NOT IN ('Resolved', 'Closed')
             OR Status IS NULL)
    GROUP BY AffectedEquipment
    
    UNION ALL
    
    -- Fixture Issues
    SELECT 
        'Fixture' AS EquipmentType,
        AffectedFixture AS EquipmentID,
        COUNT(*) AS IssueCount
    FROM Troubleshooting_Log
    WHERE AffectedFixture IS NOT NULL 
        AND AffectedFixture <> ''
        AND (ReportedDateTime >= DATEADD(MONTH, -12, GETDATE())
             OR Status NOT IN ('Resolved', 'Closed')
             OR Status IS NULL)
    GROUP BY AffectedFixture
    
    UNION ALL
    
    -- Harness Issues
    SELECT 
        'Harness' AS EquipmentType,
        AffectedHarness AS EquipmentID,
        COUNT(*) AS IssueCount
    FROM Troubleshooting_Log
    WHERE AffectedHarness IS NOT NULL 
        AND AffectedHarness <> ''
        AND (ReportedDateTime >= DATEADD(MONTH, -12, GETDATE())
             OR Status NOT IN ('Resolved', 'Closed')
             OR Status IS NULL)
    GROUP BY AffectedHarness
)
SELECT 
    EquipmentType,
    EquipmentID,
    IssueCount
FROM EquipmentIssues
WHERE IssueCount > 0;
GO

PRINT 'View vw_Troubleshooting_SankeyData created successfully';
GO

-- Test query
SELECT 'Test Results - Sankey Data:' AS Info;
SELECT 
    EquipmentType,
    COUNT(*) AS EquipmentCount,
    SUM(IssueCount) AS TotalIssues
FROM vw_Troubleshooting_SankeyData
GROUP BY EquipmentType
ORDER BY SUM(IssueCount) DESC;

SELECT TOP 20 * FROM vw_Troubleshooting_SankeyData ORDER BY IssueCount DESC;
GO
