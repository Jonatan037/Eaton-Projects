-- =====================================================
-- Troubleshooting Dashboard Views Creation Script
-- =====================================================
-- This script creates the database views needed for the Troubleshooting Dashboard
-- Run this script in SQL Server Management Studio
-- Database: TestEngineering
-- =====================================================

USE [TestEngineering]
GO

-- =====================================================
-- Drop existing views if they exist (SQL Server 2016+)
-- =====================================================
DROP VIEW IF EXISTS [dbo].[vw_Troubleshooting_Dashboard_KPIs]
DROP VIEW IF EXISTS [dbo].[vw_Troubleshooting_MonthlyTrend]
DROP VIEW IF EXISTS [dbo].[vw_Troubleshooting_ByPriority]
DROP VIEW IF EXISTS [dbo].[vw_Troubleshooting_ByClassification]
DROP VIEW IF EXISTS [dbo].[vw_Troubleshooting_ResolutionTime]
DROP VIEW IF EXISTS [dbo].[vw_Troubleshooting_ByEquipmentType]
GO

-- =====================================================
-- View 1: Troubleshooting Dashboard KPIs
-- =====================================================
-- Calculates key performance indicators for troubleshooting
-- Including open issues, resolution metrics, and impact analysis
-- =====================================================
CREATE VIEW [dbo].[vw_Troubleshooting_Dashboard_KPIs]
AS
SELECT 
    -- Open Issues (Status not in Resolved/Closed)
    ISNULL(SUM(CASE 
        WHEN Status NOT IN ('Resolved', 'Closed') OR Status IS NULL 
        THEN 1 
        ELSE 0 
    END), 0) AS OpenIssues,
    
    -- Critical Priority Issues (Open only)
    ISNULL(SUM(CASE 
        WHEN Priority = 'Critical' AND (Status NOT IN ('Resolved', 'Closed') OR Status IS NULL)
        THEN 1 
        ELSE 0 
    END), 0) AS CriticalIssues,
    
    -- Average Resolution Time (Hours, last 12 months, resolved issues only)
    CAST(ISNULL(AVG(CASE 
        WHEN Status IN ('Resolved', 'Closed') 
        AND ResolvedDateTime IS NOT NULL 
        AND ReportedDateTime IS NOT NULL
        AND ResolvedDateTime >= DATEADD(MONTH, -12, GETDATE())
        THEN ResolutionTimeHours
        ELSE NULL 
    END), 0) AS DECIMAL(10,2)) AS AvgResolutionTimeHours,
    
    -- Total Downtime Hours (Last 30 days)
    ISNULL(SUM(CASE 
        WHEN ReportedDateTime >= DATEADD(DAY, -30, GETDATE())
        THEN ISNULL(DowntimeHours, 0)
        ELSE 0 
    END), 0) AS TotalDowntimeHours30Days,
    
    -- Repeat Issues Count (All Time) - Changed from last 30 days
    ISNULL(SUM(CASE 
        WHEN IsRepeat = 1
        THEN 1 
        ELSE 0 
    END), 0) AS RepeatIssuesCount,
    
    -- Total Issues Last 30 Days
    ISNULL(SUM(CASE 
        WHEN ReportedDateTime >= DATEADD(DAY, -30, GETDATE())
        THEN 1 
        ELSE 0 
    END), 0) AS TotalIssues30Days,
    
    -- Total Issues (All Time)
    COUNT(*) AS TotalIssuesAllTime,
    
    -- Repeat Issue Rate (%) - Based on all issues, not just last 30 days
    CAST(CASE 
        WHEN COUNT(*) > 0
        THEN (SUM(CASE WHEN IsRepeat = 1 THEN 1 ELSE 0 END) * 100.0) / COUNT(*)
        ELSE 0 
    END AS DECIMAL(5,1)) AS RepeatIssueRate
FROM 
    dbo.Troubleshooting_Log
GO

-- =====================================================
-- View 2: Monthly Trend (Last 12 Months)
-- =====================================================
-- Shows issue count trend over the last 12 months
-- =====================================================
CREATE VIEW [dbo].[vw_Troubleshooting_MonthlyTrend]
AS
SELECT 
    FORMAT(ReportedDateTime, 'MMM yyyy') AS MonthLabel,
    YEAR(ReportedDateTime) AS Year,
    MONTH(ReportedDateTime) AS Month,
    COUNT(*) AS IssueCount,
    SUM(CASE WHEN Status IN ('Resolved', 'Closed') THEN 1 ELSE 0 END) AS ResolvedCount,
    SUM(CASE WHEN Priority = 'Critical' THEN 1 ELSE 0 END) AS CriticalCount,
    SUM(ISNULL(DowntimeHours, 0)) AS TotalDowntime
FROM 
    dbo.Troubleshooting_Log
WHERE 
    ReportedDateTime >= DATEADD(MONTH, -12, GETDATE())
    AND ReportedDateTime IS NOT NULL
GROUP BY 
    YEAR(ReportedDateTime),
    MONTH(ReportedDateTime),
    FORMAT(ReportedDateTime, 'MMM yyyy')
GO

-- =====================================================
-- View 3: Issues by Priority
-- =====================================================
-- Distribution of issues by priority level
-- =====================================================
CREATE VIEW [dbo].[vw_Troubleshooting_ByPriority]
AS
SELECT 
    ISNULL(Priority, 'Unassigned') AS Priority,
    COUNT(*) AS IssueCount,
    SUM(CASE WHEN Status NOT IN ('Resolved', 'Closed') OR Status IS NULL THEN 1 ELSE 0 END) AS OpenCount,
    SUM(CASE WHEN Status IN ('Resolved', 'Closed') THEN 1 ELSE 0 END) AS ResolvedCount,
    AVG(CASE 
        WHEN ResolutionTimeHours IS NOT NULL AND Status IN ('Resolved', 'Closed')
        THEN ResolutionTimeHours 
        ELSE NULL 
    END) AS AvgResolutionHours
FROM 
    dbo.Troubleshooting_Log
WHERE 
    ReportedDateTime >= DATEADD(MONTH, -12, GETDATE())
    OR Status NOT IN ('Resolved', 'Closed')
    OR Status IS NULL
GROUP BY 
    Priority
GO

-- =====================================================
-- View 4: Issues by Classification (Top 10)
-- =====================================================
-- Most frequent issue classifications
-- =====================================================
CREATE VIEW [dbo].[vw_Troubleshooting_ByClassification]
AS
SELECT TOP 10
    ISNULL(IssueClassification, 'Unclassified') AS Classification,
    COUNT(*) AS IssueCount,
    SUM(CASE WHEN Status NOT IN ('Resolved', 'Closed') OR Status IS NULL THEN 1 ELSE 0 END) AS OpenCount,
    AVG(CASE 
        WHEN ResolutionTimeHours IS NOT NULL AND Status IN ('Resolved', 'Closed')
        THEN ResolutionTimeHours 
        ELSE NULL 
    END) AS AvgResolutionHours,
    SUM(ISNULL(DowntimeHours, 0)) AS TotalDowntime
FROM 
    dbo.Troubleshooting_Log
WHERE 
    ReportedDateTime >= DATEADD(MONTH, -12, GETDATE())
    OR Status NOT IN ('Resolved', 'Closed')
    OR Status IS NULL
GROUP BY 
    IssueClassification
ORDER BY 
    IssueCount DESC
GO

-- =====================================================
-- View 5: Resolution Time Analysis
-- =====================================================
-- Resolution time breakdown by priority for last 12 months
-- =====================================================
CREATE VIEW [dbo].[vw_Troubleshooting_ResolutionTime]
AS
SELECT 
    ISNULL(Priority, 'Unassigned') AS Priority,
    COUNT(*) AS ResolvedCount,
    AVG(ResolutionTimeHours) AS AvgResolutionHours,
    MIN(ResolutionTimeHours) AS MinResolutionHours,
    MAX(ResolutionTimeHours) AS MaxResolutionHours,
    -- Time buckets
    SUM(CASE WHEN ResolutionTimeHours <= 24 THEN 1 ELSE 0 END) AS Within24Hours,
    SUM(CASE WHEN ResolutionTimeHours > 24 AND ResolutionTimeHours <= 72 THEN 1 ELSE 0 END) AS Within72Hours,
    SUM(CASE WHEN ResolutionTimeHours > 72 THEN 1 ELSE 0 END) AS Over72Hours
FROM 
    dbo.Troubleshooting_Log
WHERE 
    Status IN ('Resolved', 'Closed')
    AND ResolutionTimeHours IS NOT NULL
    AND ResolvedDateTime >= DATEADD(MONTH, -12, GETDATE())
GROUP BY 
    Priority
GO

-- =====================================================
-- View 6: Issues by Equipment Type
-- =====================================================
-- Distribution across ATE/Equipment/Fixture/Harness
-- =====================================================
CREATE VIEW [dbo].[vw_Troubleshooting_ByEquipmentType]
AS
SELECT 
    EquipmentType,
    COUNT(*) AS IssueCount,
    SUM(CASE WHEN Status NOT IN ('Resolved', 'Closed') OR Status IS NULL THEN 1 ELSE 0 END) AS OpenCount,
    AVG(CASE 
        WHEN ResolutionTimeHours IS NOT NULL AND Status IN ('Resolved', 'Closed')
        THEN ResolutionTimeHours 
        ELSE NULL 
    END) AS AvgResolutionHours
FROM (
    SELECT 
        CASE 
            WHEN AffectedATE IS NOT NULL AND AffectedATE <> '' THEN 'ATE'
            WHEN AffectedEquipment IS NOT NULL AND AffectedEquipment <> '' THEN 'Equipment'
            WHEN AffectedFixture IS NOT NULL AND AffectedFixture <> '' THEN 'Fixture'
            WHEN AffectedHarness IS NOT NULL AND AffectedHarness <> '' THEN 'Harness'
            ELSE 'Other'
        END AS EquipmentType,
        Status,
        ResolutionTimeHours,
        ReportedDateTime
    FROM 
        dbo.Troubleshooting_Log
    WHERE 
        ReportedDateTime >= DATEADD(MONTH, -12, GETDATE())
        OR Status NOT IN ('Resolved', 'Closed')
        OR Status IS NULL
) AS EquipmentData
GROUP BY 
    EquipmentType
GO

-- =====================================================
-- Verification Queries
-- =====================================================
-- Run these to verify the views are working correctly
-- =====================================================

PRINT 'Testing vw_Troubleshooting_Dashboard_KPIs...'
SELECT * FROM dbo.vw_Troubleshooting_Dashboard_KPIs
GO

PRINT 'Testing vw_Troubleshooting_MonthlyTrend...'
SELECT TOP 5 * FROM dbo.vw_Troubleshooting_MonthlyTrend ORDER BY Year DESC, Month DESC
GO

PRINT 'Testing vw_Troubleshooting_ByPriority...'
SELECT * FROM dbo.vw_Troubleshooting_ByPriority ORDER BY IssueCount DESC
GO

PRINT 'Testing vw_Troubleshooting_ByClassification...'
SELECT * FROM dbo.vw_Troubleshooting_ByClassification
GO

PRINT 'Testing vw_Troubleshooting_ResolutionTime...'
SELECT * FROM dbo.vw_Troubleshooting_ResolutionTime ORDER BY AvgResolutionHours DESC
GO

PRINT 'Testing vw_Troubleshooting_ByEquipmentType...'
SELECT * FROM dbo.vw_Troubleshooting_ByEquipmentType ORDER BY IssueCount DESC
GO

PRINT 'All views created successfully!'
GO
