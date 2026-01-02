-- =====================================================
-- PM Dashboard Views Creation Script
-- =====================================================
-- This script creates the database views needed for the PM Dashboard
-- Run this script in SQL Server Management Studio
-- Database: TestEngineering
-- =====================================================

USE [TestEngineering]
GO

-- =====================================================
-- Drop existing views if they exist (SQL Server 2016+)
-- =====================================================
DROP VIEW IF EXISTS [dbo].[vw_PM_Dashboard_KPIs]
DROP VIEW IF EXISTS [dbo].[vw_PM_MonthlyTrend]
DROP VIEW IF EXISTS [dbo].[vw_PM_ByEquipmentType]
DROP VIEW IF EXISTS [dbo].[vw_PM_ByPMType]
DROP VIEW IF EXISTS [dbo].[vw_PM_OnTimePerformance]
DROP VIEW IF EXISTS [dbo].[vw_PM_CostTrend]
GO

-- =====================================================
-- View 1: PM Dashboard KPIs
-- =====================================================
-- Calculates key performance indicators for preventive maintenance
-- Including overdue PMs, upcoming PMs, compliance rate, and cost metrics
-- =====================================================
CREATE VIEW [dbo].[vw_PM_Dashboard_KPIs]
AS
SELECT 
    -- Overdue PMs (NextPMDate is in the past)
    ISNULL(SUM(CASE WHEN NextPMDate < GETDATE() THEN 1 ELSE 0 END), 0) AS OverduePMs,
    
    -- PMs due in the next 30 days
    ISNULL(SUM(CASE 
        WHEN NextPMDate BETWEEN GETDATE() AND DATEADD(DAY, 30, GETDATE()) 
        THEN 1 
        ELSE 0 
    END), 0) AS DueNext30Days,
    
    -- Compliance rate (percentage of on-time PMs in last 12 months)
    CAST(ISNULL(
        (SUM(CASE WHEN IsOnTime = 1 THEN 1 ELSE 0 END) * 100.0) / NULLIF(COUNT(*), 0), 
        0
    ) AS DECIMAL(5,1)) AS ComplianceRate,
    
    -- Count of on-time PMs
    ISNULL(SUM(CASE WHEN IsOnTime = 1 THEN 1 ELSE 0 END), 0) AS OnTimePMs,
    
    -- Total completed PMs in last 12 months
    COUNT(*) AS TotalCompletedPMs,
    
    -- Average duration in minutes
    ISNULL(AVG(ActualDuration), 0) AS AvgDurationMinutes,
    
    -- Average cost per PM
    ISNULL(AVG(Cost), 0) AS AvgCostPerPM,
    
    -- Total cost of all PMs
    ISNULL(SUM(Cost), 0) AS TotalCost,
    
    -- Number of PMs with cost data
    ISNULL(SUM(CASE WHEN Cost > 0 THEN 1 ELSE 0 END), 0) AS PMsWithCost
FROM PM_Log
WHERE PMDate >= DATEADD(MONTH, -12, GETDATE())
GO

-- =====================================================
-- View 2: PM Monthly Trend
-- =====================================================
-- Shows the number of PMs completed each month for the last 12 months
-- Used for the monthly trend chart
-- =====================================================
CREATE VIEW [dbo].[vw_PM_MonthlyTrend]
AS
SELECT 
    FORMAT(PMDate, 'MMM yyyy') AS MonthLabel,
    YEAR(PMDate) AS Year,
    MONTH(PMDate) AS Month,
    COUNT(*) AS PMCount
FROM PM_Log
WHERE PMDate >= DATEADD(MONTH, -12, GETDATE())
  AND PMDate IS NOT NULL
GROUP BY 
    FORMAT(PMDate, 'MMM yyyy'),
    YEAR(PMDate),
    MONTH(PMDate)
GO

-- =====================================================
-- View 3: PM By Equipment Type
-- =====================================================
-- Aggregates PM counts by equipment type
-- Used for the equipment type breakdown chart
-- =====================================================
CREATE VIEW [dbo].[vw_PM_ByEquipmentType]
AS
SELECT 
    ISNULL(EquipmentType, 'Unknown') AS EquipmentType,
    COUNT(*) AS PMCount
FROM PM_Log
WHERE PMDate >= DATEADD(MONTH, -12, GETDATE())
GROUP BY EquipmentType
GO

-- =====================================================
-- View 4: PM By PM Type
-- =====================================================
-- Aggregates PM counts by PM type (Annual, Semi-Annual, etc.)
-- Used for the PM type distribution chart
-- =====================================================
CREATE VIEW [dbo].[vw_PM_ByPMType]
AS
SELECT 
    ISNULL(PMType, 'Unknown') AS PMType,
    COUNT(*) AS PMCount
FROM PM_Log
WHERE PMDate >= DATEADD(MONTH, -12, GETDATE())
GROUP BY PMType
GO

-- =====================================================
-- View 5: PM On-Time Performance
-- =====================================================
-- Breaks down PMs by on-time vs late status
-- Used for the on-time performance doughnut chart
-- =====================================================
CREATE VIEW [dbo].[vw_PM_OnTimePerformance]
AS
SELECT 
    CASE 
        WHEN IsOnTime = 1 THEN 'On Time'
        ELSE 'Late'
    END AS PerformanceStatus,
    COUNT(*) AS PMCount
FROM PM_Log
WHERE PMDate >= DATEADD(MONTH, -12, GETDATE())
  AND PMDate IS NOT NULL
GROUP BY IsOnTime
GO

-- =====================================================
-- View 6: PM Cost Trend
-- =====================================================
-- Shows total PM costs by month for the last 12 months
-- Used for the cost trend line chart
-- =====================================================
CREATE VIEW [dbo].[vw_PM_CostTrend]
AS
SELECT 
    FORMAT(PMDate, 'MMM yyyy') AS MonthLabel,
    YEAR(PMDate) AS Year,
    MONTH(PMDate) AS Month,
    ISNULL(SUM(Cost), 0) AS TotalCost,
    COUNT(*) AS PMCount,
    ISNULL(AVG(Cost), 0) AS AvgCost
FROM PM_Log
WHERE PMDate >= DATEADD(MONTH, -12, GETDATE())
  AND PMDate IS NOT NULL
GROUP BY 
    FORMAT(PMDate, 'MMM yyyy'),
    YEAR(PMDate),
    MONTH(PMDate)
GO

-- =====================================================
-- Verification: Check if views were created successfully
-- =====================================================
PRINT '===== PM Dashboard Views Created Successfully ====='
PRINT ''
SELECT 
    name AS ViewName,
    create_date AS CreatedDate,
    modify_date AS ModifiedDate
FROM sys.views
WHERE name LIKE 'vw_PM_%'
ORDER BY name
GO

-- =====================================================
-- Test Queries: Verify data in each view
-- =====================================================
PRINT ''
PRINT '===== Testing View: vw_PM_Dashboard_KPIs ====='
SELECT * FROM vw_PM_Dashboard_KPIs
GO

PRINT ''
PRINT '===== Testing View: vw_PM_MonthlyTrend ====='
SELECT * FROM vw_PM_MonthlyTrend ORDER BY Year, Month
GO

PRINT ''
PRINT '===== Testing View: vw_PM_ByEquipmentType ====='
SELECT * FROM vw_PM_ByEquipmentType ORDER BY PMCount DESC
GO

PRINT ''
PRINT '===== Testing View: vw_PM_ByPMType ====='
SELECT * FROM vw_PM_ByPMType ORDER BY PMCount DESC
GO

PRINT ''
PRINT '===== Testing View: vw_PM_OnTimePerformance ====='
SELECT * FROM vw_PM_OnTimePerformance ORDER BY PerformanceStatus
GO

PRINT ''
PRINT '===== Testing View: vw_PM_CostTrend ====='
SELECT * FROM vw_PM_CostTrend ORDER BY Year, Month
GO

PRINT ''
PRINT '===== PM Dashboard Views Setup Complete ====='
PRINT 'All 6 views have been created and tested.'
PRINT 'You can now use these views in the PM Dashboard application.'
GO
