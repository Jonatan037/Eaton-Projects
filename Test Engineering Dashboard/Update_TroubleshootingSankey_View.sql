/*
==============================================================================
UPDATE: Sankey Diagram View - Add Issue Classification Level
==============================================================================
Purpose: Update the Sankey view to include Issue Classification
Flow: Total Issues → Equipment Type → Specific Equipment → Issue Classification

Author: System
Date: October 28, 2025
==============================================================================
*/

-- Drop existing view if it exists
IF OBJECT_ID('dbo.vw_Troubleshooting_SankeyData', 'V') IS NOT NULL
    DROP VIEW dbo.vw_Troubleshooting_SankeyData;
GO

-- Create updated view with Issue Classification
CREATE VIEW dbo.vw_Troubleshooting_SankeyData
AS
WITH EquipmentIssues AS (
    -- ATE Issues with Classification
    SELECT 
        'ATE' AS EquipmentType,
        AffectedATE AS EquipmentID,
        ISNULL(IssueClassification, 'Unclassified') AS IssueClassification,
        COUNT(*) AS IssueCount
    FROM Troubleshooting_Log
    WHERE AffectedATE IS NOT NULL 
      AND AffectedATE <> ''
      AND (ReportedDateTime >= DATEADD(MONTH, -12, GETDATE())
           OR Status NOT IN ('Resolved', 'Closed'))
    GROUP BY AffectedATE, ISNULL(IssueClassification, 'Unclassified')
    
    UNION ALL
    
    -- Asset Issues with Classification
    SELECT 
        'Asset' AS EquipmentType,
        AffectedEquipment AS EquipmentID,
        ISNULL(IssueClassification, 'Unclassified') AS IssueClassification,
        COUNT(*) AS IssueCount
    FROM Troubleshooting_Log
    WHERE AffectedEquipment IS NOT NULL 
      AND AffectedEquipment <> ''
      AND (ReportedDateTime >= DATEADD(MONTH, -12, GETDATE())
           OR Status NOT IN ('Resolved', 'Closed'))
    GROUP BY AffectedEquipment, ISNULL(IssueClassification, 'Unclassified')
    
    UNION ALL
    
    -- Fixture Issues with Classification
    SELECT 
        'Fixture' AS EquipmentType,
        AffectedFixture AS EquipmentID,
        ISNULL(IssueClassification, 'Unclassified') AS IssueClassification,
        COUNT(*) AS IssueCount
    FROM Troubleshooting_Log
    WHERE AffectedFixture IS NOT NULL 
      AND AffectedFixture <> ''
      AND (ReportedDateTime >= DATEADD(MONTH, -12, GETDATE())
           OR Status NOT IN ('Resolved', 'Closed'))
    GROUP BY AffectedFixture, ISNULL(IssueClassification, 'Unclassified')
    
    UNION ALL
    
    -- Harness Issues with Classification
    SELECT 
        'Harness' AS EquipmentType,
        AffectedHarness AS EquipmentID,
        ISNULL(IssueClassification, 'Unclassified') AS IssueClassification,
        COUNT(*) AS IssueCount
    FROM Troubleshooting_Log
    WHERE AffectedHarness IS NOT NULL 
      AND AffectedHarness <> ''
      AND (ReportedDateTime >= DATEADD(MONTH, -12, GETDATE())
           OR Status NOT IN ('Resolved', 'Closed'))
    GROUP BY AffectedHarness, ISNULL(IssueClassification, 'Unclassified')
)
SELECT 
    EquipmentType,
    EquipmentID,
    IssueClassification,
    IssueCount
FROM EquipmentIssues
WHERE IssueCount > 0;
GO

-- Test Query 1: Summary by Equipment Type
SELECT 
    EquipmentType,
    COUNT(DISTINCT EquipmentID) AS UniqueEquipmentCount,
    COUNT(DISTINCT IssueClassification) AS UniqueClassifications,
    SUM(IssueCount) AS TotalIssues
FROM dbo.vw_Troubleshooting_SankeyData
GROUP BY EquipmentType
ORDER BY TotalIssues DESC;

-- Test Query 2: Top 20 Equipment with Classifications
SELECT TOP 20
    EquipmentType,
    EquipmentID,
    IssueClassification,
    IssueCount
FROM dbo.vw_Troubleshooting_SankeyData
ORDER BY IssueCount DESC;

-- Test Query 3: Classification Distribution
SELECT 
    IssueClassification,
    COUNT(DISTINCT EquipmentID) AS AffectedEquipment,
    SUM(IssueCount) AS TotalIssues
FROM dbo.vw_Troubleshooting_SankeyData
GROUP BY IssueClassification
ORDER BY TotalIssues DESC;

/*
==============================================================================
Expected Results:
- Returns: EquipmentType, EquipmentID, IssueClassification, IssueCount
- Filters: Last 12 months OR open/active issues
- Groups: By Equipment and Classification
==============================================================================
*/
