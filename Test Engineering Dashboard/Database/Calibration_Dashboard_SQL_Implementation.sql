-- =============================================
-- CALIBRATION DASHBOARD - SQL IMPLEMENTATION
-- =============================================
-- Execute these scripts in order to set up the Calibration Dashboard
-- =============================================

USE [TestEngineering];
GO

-- =============================================
-- 1. TABLE MODIFICATIONS (if not already done)
-- =============================================

-- Check if columns exist before adding them
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Calibration_Log') AND name = 'PrevDueDate')
BEGIN
    ALTER TABLE dbo.Calibration_Log ADD PrevDueDate datetime NULL;
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Calibration_Log') AND name = 'StartDate')
BEGIN
    ALTER TABLE dbo.Calibration_Log ADD StartDate datetime NULL;
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Calibration_Log') AND name = 'SentOutDate')
BEGIN
    ALTER TABLE dbo.Calibration_Log ADD SentOutDate datetime NULL;
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Calibration_Log') AND name = 'ReceivedDate')
BEGIN
    ALTER TABLE dbo.Calibration_Log ADD ReceivedDate datetime NULL;
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Calibration_Log') AND name = 'CompletedDate')
BEGIN
    ALTER TABLE dbo.Calibration_Log ADD CompletedDate datetime NULL;
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Calibration_Log') AND name = 'ResultCode')
BEGIN
    ALTER TABLE dbo.Calibration_Log ADD ResultCode nvarchar(20) NULL;
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Calibration_Log') AND name = 'VendorName')
BEGIN
    ALTER TABLE dbo.Calibration_Log ADD VendorName nvarchar(200) NULL;
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Calibration_Log') AND name = 'Method')
BEGIN
    ALTER TABLE dbo.Calibration_Log ADD Method nvarchar(20) NULL;
END

-- Add computed columns if they don't exist
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Calibration_Log') AND name = 'CompletedOn')
BEGIN
    ALTER TABLE dbo.Calibration_Log ADD CompletedOn AS COALESCE(CompletedDate, CalibrationDate);
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Calibration_Log') AND name = 'IsOnTime')
BEGIN
    ALTER TABLE dbo.Calibration_Log ADD IsOnTime AS CASE WHEN CalibrationDate IS NULL OR CompletedOn IS NULL THEN NULL
                                                         WHEN CompletedOn <= CalibrationDate THEN 1 ELSE 0 END;
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Calibration_Log') AND name = 'IsOutOfTolerance')
BEGIN
    ALTER TABLE dbo.Calibration_Log ADD IsOutOfTolerance AS CASE WHEN UPPER(ResultCode) IN ('FAIL','OOT') THEN 1 ELSE 0 END;
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Calibration_Log') AND name = 'TurnaroundDays')
BEGIN
    ALTER TABLE dbo.Calibration_Log ADD TurnaroundDays AS DATEDIFF(day, StartDate, CompletedOn);
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Calibration_Log') AND name = 'VendorLeadDays')
BEGIN
    ALTER TABLE dbo.Calibration_Log ADD VendorLeadDays AS DATEDIFF(day, SentOutDate, ReceivedDate);
END

PRINT 'Table modifications completed.';
GO

-- =============================================
-- 2. KPI VIEWS
-- =============================================

-- Main KPI View
CREATE OR ALTER VIEW vw_CalibrationKPIs AS
WITH CurrentStats AS (
    SELECT
        -- Overdue calibrations
        COUNT(CASE WHEN NextDueDate < CAST(GETDATE() AS date) AND (Status IS NULL OR Status NOT IN ('Completed', 'Cancelled')) THEN 1 END) as OverdueCount,

        -- Due in next 30 days
        COUNT(CASE WHEN NextDueDate BETWEEN CAST(GETDATE() AS date) AND DATEADD(day, 30, CAST(GETDATE() AS date))
                   AND (Status IS NULL OR Status NOT IN ('Completed', 'Cancelled')) THEN 1 END) as DueNext30Days,

        -- Due in next 7 days
        COUNT(CASE WHEN NextDueDate BETWEEN CAST(GETDATE() AS date) AND DATEADD(day, 7, CAST(GETDATE() AS date))
                   AND (Status IS NULL OR Status NOT IN ('Completed', 'Cancelled')) THEN 1 END) as DueNext7Days,

        -- Total active calibrations
        COUNT(CASE WHEN Status IS NULL OR Status NOT IN ('Completed', 'Cancelled') THEN 1 END) as TotalActive
    FROM dbo.Calibration_Log
),
Last12Months AS (
    SELECT
        COUNT(*) as TotalCalibrations,
        COUNT(CASE WHEN CASE WHEN COALESCE(CompletedDate, CalibrationDate) <= CalibrationDate THEN 1 ELSE 0 END = 1 THEN 1 END) as OnTimeCount,
        COUNT(CASE WHEN CASE WHEN UPPER(ResultCode) IN ('FAIL','OOT') THEN 1 ELSE 0 END = 1 THEN 1 END) as OOTCount,
        AVG(CAST(DATEDIFF(day, StartDate, COALESCE(CompletedDate, CalibrationDate)) AS float)) as AvgTurnaroundDays,
        SUM(CAST(Cost AS decimal(10,2))) as TotalCost
    FROM dbo.Calibration_Log
    WHERE CompletedOn >= DATEADD(month, -12, GETDATE())
      AND CompletedOn IS NOT NULL
)
SELECT
    cs.OverdueCount,
    cs.DueNext30Days,
    cs.DueNext7Days,
    cs.TotalActive,

    -- On-time rate (last 12 months)
    CASE WHEN lm.TotalCalibrations > 0
         THEN CAST((CAST(lm.OnTimeCount AS float) / CAST(lm.TotalCalibrations AS float)) * 100 AS decimal(5,2))
         ELSE 0 END as OnTimeRatePercent,

    -- Out-of-tolerance rate (last 12 months)
    CASE WHEN lm.TotalCalibrations > 0
         THEN CAST((CAST(lm.OOTCount AS float) / CAST(lm.TotalCalibrations AS float)) * 100 AS decimal(5,2))
         ELSE 0 END as OOTRatePercent,

    -- Average turnaround time
    CAST(ISNULL(lm.AvgTurnaroundDays, 0) AS decimal(5,2)) as AvgTurnaroundDays,

    -- Total cost last 12 months
    CAST(ISNULL(lm.TotalCost, 0) AS decimal(10,2)) as TotalCostLast12Months,

    -- Additional metrics
    lm.TotalCalibrations as CalibrationsLast12Months,

    -- Current month metrics
    (SELECT COUNT(*) FROM dbo.Calibration_Log
     WHERE YEAR(CompletedOn) = YEAR(GETDATE())
       AND MONTH(CompletedOn) = MONTH(GETDATE())
       AND CompletedOn IS NOT NULL) as CalibrationsThisMonth,

    -- Current quarter metrics
    (SELECT COUNT(*) FROM dbo.Calibration_Log
     WHERE YEAR(CompletedOn) = YEAR(GETDATE())
       AND DATEPART(quarter, CompletedOn) = DATEPART(quarter, GETDATE())
       AND CompletedOn IS NOT NULL) as CalibrationsThisQuarter

FROM CurrentStats cs
CROSS JOIN Last12Months lm;
GO

-- Equipment Type KPI Breakdown
CREATE OR ALTER VIEW vw_CalibrationKPIs_ByEquipmentType AS
SELECT
    EquipmentType,
    COUNT(*) as TotalCalibrations,

    -- Overdue by type
    COUNT(CASE WHEN NextDueDate < CAST(GETDATE() AS date) AND (Status IS NULL OR Status NOT IN ('Completed', 'Cancelled')) THEN 1 END) as OverdueCount,

    -- Due next 30 days by type
    COUNT(CASE WHEN NextDueDate BETWEEN CAST(GETDATE() AS date) AND DATEADD(day, 30, CAST(GETDATE() AS date))
               AND (Status IS NULL OR Status NOT IN ('Completed', 'Cancelled')) THEN 1 END) as DueNext30Days,

    -- On-time rate by type (last 12 months)
    CASE WHEN COUNT(CASE WHEN CompletedOn >= DATEADD(month, -12, GETDATE()) THEN 1 END) > 0
         THEN CAST(AVG(CASE WHEN CompletedOn >= DATEADD(month, -12, GETDATE()) AND COALESCE(CompletedDate, CalibrationDate) <= CalibrationDate THEN 1.0 ELSE 0.0 END) * 100 AS decimal(5,2))
         ELSE 0 END as OnTimeRatePercent,

    -- Average cost by type
    CAST(AVG(CAST(Cost AS decimal(10,2))) AS decimal(10,2)) as AvgCost,

    -- Last calibration date by type
    MAX(CompletedOn) as LastCalibrationDate

FROM dbo.Calibration_Log
GROUP BY EquipmentType;
GO

-- Vendor Performance View
CREATE OR ALTER VIEW vw_CalibrationVendorPerformance AS
SELECT
    VendorName,
    COUNT(*) as TotalCalibrations,

    -- Average turnaround time
    AVG(CAST(DATEDIFF(day, StartDate, COALESCE(CompletedDate, CalibrationDate)) AS float)) as AvgTurnaroundDays,

    -- Average vendor lead time
    AVG(CAST(DATEDIFF(day, SentOutDate, ReceivedDate) AS float)) as AvgVendorLeadDays,

    -- On-time delivery rate
    CASE WHEN COUNT(CASE WHEN CompletedOn IS NOT NULL THEN 1 END) > 0
         THEN CAST(AVG(CASE WHEN CompletedOn IS NOT NULL AND COALESCE(CompletedDate, CalibrationDate) <= CalibrationDate THEN 1.0 ELSE 0.0 END) * 100 AS decimal(5,2))
         ELSE 0 END as OnTimeRatePercent,

    -- Out-of-tolerance rate
    CASE WHEN COUNT(*) > 0
         THEN CAST(AVG(CASE WHEN UPPER(ResultCode) IN ('FAIL','OOT') THEN 1.0 ELSE 0.0 END) * 100 AS decimal(5,2))
         ELSE 0 END as OOTRatePercent,

    -- Total cost
    SUM(CAST(Cost AS decimal(10,2))) as TotalCost,

    -- Average cost per calibration
    CAST(AVG(CAST(Cost AS decimal(10,2))) AS decimal(10,2)) as AvgCostPerCalibration,

    -- Last calibration date
    MAX(CompletedOn) as LastCalibrationDate

FROM dbo.Calibration_Log
WHERE VendorName IS NOT NULL AND VendorName <> ''
GROUP BY VendorName
HAVING COUNT(*) > 0;
GO

-- =============================================
-- 3. CHART & GRAPH VIEWS
-- =============================================

-- Monthly Calibration Volume Trend (Last 24 months)
CREATE OR ALTER VIEW vw_CalibrationMonthlyVolume AS
SELECT
    YEAR(CompletedOn) as Year,
    MONTH(CompletedOn) as Month,
    DATENAME(month, CompletedOn) as MonthName,
    DATEFROMPARTS(YEAR(CompletedOn), MONTH(CompletedOn), 1) as Period,
    COUNT(*) as TotalCalibrations,

    -- By status
    COUNT(CASE WHEN UPPER(ResultCode) = 'PASS' THEN 1 END) as PassCount,
    COUNT(CASE WHEN UPPER(ResultCode) IN ('FAIL', 'OOT') THEN 1 END) as FailCount,
    COUNT(CASE WHEN UPPER(ResultCode) = 'ADJUSTED' THEN 1 END) as AdjustedCount,

    -- By method
    COUNT(CASE WHEN UPPER(Method) = 'INTERNAL' THEN 1 END) as InternalCount,
    COUNT(CASE WHEN UPPER(Method) = 'EXTERNAL' THEN 1 END) as ExternalCount,

    -- Performance metrics
    COUNT(CASE WHEN CASE WHEN COALESCE(CompletedDate, CalibrationDate) <= CalibrationDate THEN 1 ELSE 0 END = 1 THEN 1 END) as OnTimeCount,
    COUNT(CASE WHEN CASE WHEN UPPER(ResultCode) IN ('FAIL','OOT') THEN 1 ELSE 0 END = 1 THEN 1 END) as OOTCount,

    -- Cost metrics
    SUM(CAST(Cost AS decimal(10,2))) as TotalCost,
    AVG(CAST(DATEDIFF(day, StartDate, COALESCE(CompletedDate, CalibrationDate)) AS float)) as AvgTurnaroundDays

FROM dbo.Calibration_Log
WHERE CompletedOn >= DATEADD(month, -24, GETDATE())
  AND CompletedOn IS NOT NULL
GROUP BY YEAR(CompletedOn), MONTH(CompletedOn), DATENAME(month, CompletedOn);
GO

-- Equipment Type Distribution
CREATE OR ALTER VIEW vw_CalibrationByEquipmentType AS
SELECT
    EquipmentType,
    COUNT(*) as TotalCalibrations,

    -- Current status breakdown
    COUNT(CASE WHEN Status IS NULL OR Status NOT IN ('Completed', 'Cancelled') THEN 1 END) as ActiveCalibrations,
    COUNT(CASE WHEN NextDueDate < CAST(GETDATE() AS date) AND (Status IS NULL OR Status NOT IN ('Completed', 'Cancelled')) THEN 1 END) as OverdueCount,

    -- Performance by type
    COUNT(CASE WHEN CompletedOn >= DATEADD(month, -12, GETDATE()) THEN 1 END) as CalibrationsLast12Months,
    COUNT(CASE WHEN CompletedOn >= DATEADD(month, -12, GETDATE()) AND CASE WHEN COALESCE(CompletedDate, CalibrationDate) <= CalibrationDate THEN 1 ELSE 0 END = 1 THEN 1 END) as OnTimeLast12Months,
    COUNT(CASE WHEN CompletedOn >= DATEADD(month, -12, GETDATE()) AND CASE WHEN UPPER(ResultCode) IN ('FAIL','OOT') THEN 1 ELSE 0 END = 1 THEN 1 END) as OOTLast12Months,

    -- Cost analysis
    SUM(CAST(Cost AS decimal(10,2))) as TotalCost,
    AVG(CAST(Cost AS decimal(10,2))) as AvgCost,

    -- Most recent activity
    MAX(CompletedOn) as LastCalibrationDate,
    MAX(NextDueDate) as NextDueDate

FROM dbo.Calibration_Log
GROUP BY EquipmentType;
GO

-- Calibration Method Distribution
CREATE OR ALTER VIEW vw_CalibrationByMethod AS
SELECT
    Method,
    COUNT(*) as TotalCalibrations,

    -- Performance metrics
    COUNT(CASE WHEN CASE WHEN CalibrationDate IS NULL OR COALESCE(CompletedDate, CalibrationDate) IS NULL THEN NULL
                        WHEN COALESCE(CompletedDate, CalibrationDate) <= CalibrationDate THEN 1 ELSE 0 END = 1 THEN 1 END) as OnTimeCount,
    COUNT(CASE WHEN CASE WHEN UPPER(ResultCode) IN ('FAIL','OOT') THEN 1 ELSE 0 END = 1 THEN 1 END) as OOTCount,

    -- Time metrics
    AVG(CAST(DATEDIFF(day, StartDate, COALESCE(CompletedDate, CalibrationDate)) AS float)) as AvgTurnaroundDays,
    AVG(CAST(DATEDIFF(day, SentOutDate, ReceivedDate) AS float)) as AvgVendorLeadDays,

    -- Cost metrics
    SUM(CAST(Cost AS decimal(10,2))) as TotalCost,
    AVG(CAST(Cost AS decimal(10,2))) as AvgCost,

    -- Success rates
    CASE WHEN COUNT(*) > 0 THEN CAST(AVG(CASE WHEN COALESCE(CompletedDate, CalibrationDate) <= CalibrationDate THEN 1.0 ELSE 0.0 END) * 100 AS decimal(5,2)) ELSE 0 END as OnTimeRatePercent,
    CASE WHEN COUNT(*) > 0 THEN CAST(AVG(CASE WHEN UPPER(ResultCode) IN ('FAIL','OOT') THEN 1.0 ELSE 0.0 END) * 100 AS decimal(5,2)) ELSE 0 END as OOTRatePercent

FROM dbo.Calibration_Log
WHERE Method IS NOT NULL AND Method <> ''
GROUP BY Method;
GO

-- Result Code Distribution
CREATE OR ALTER VIEW vw_CalibrationByResult AS
SELECT
    ResultCode,
    COUNT(*) as Count,

    -- Percentage of total
    CAST((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM dbo.Calibration_Log WHERE ResultCode IS NOT NULL)) AS decimal(5,2)) as Percentage,

    -- Average cost by result
    AVG(CAST(Cost AS decimal(10,2))) as AvgCost,

    -- Average turnaround by result
    AVG(CAST(DATEDIFF(day, StartDate, COALESCE(CompletedDate, CalibrationDate)) AS float)) as AvgTurnaroundDays

FROM dbo.Calibration_Log
WHERE ResultCode IS NOT NULL AND ResultCode <> ''
GROUP BY ResultCode;
GO

-- Vendor Performance Chart Data
CREATE OR ALTER VIEW vw_CalibrationVendorChart AS
SELECT
    VendorName,
    COUNT(*) as CalibrationCount,

    -- Performance metrics
    AVG(CAST(DATEDIFF(day, StartDate, COALESCE(CompletedDate, CalibrationDate)) AS float)) as AvgTurnaroundDays,
    AVG(CAST(DATEDIFF(day, SentOutDate, ReceivedDate) AS float)) as AvgVendorLeadDays,

    -- Quality metrics
    CASE WHEN COUNT(*) > 0 THEN CAST(AVG(CASE WHEN COALESCE(CompletedDate, CalibrationDate) <= CalibrationDate THEN 1.0 ELSE 0.0 END) * 100 AS decimal(5,2)) ELSE 0 END as OnTimeRatePercent,
    CASE WHEN COUNT(*) > 0 THEN CAST(AVG(CASE WHEN UPPER(ResultCode) IN ('FAIL','OOT') THEN 1.0 ELSE 0.0 END) * 100 AS decimal(5,2)) ELSE 0 END as OOTRatePercent,

    -- Cost efficiency
    SUM(CAST(Cost AS decimal(10,2))) as TotalCost,
    CAST(AVG(CAST(Cost AS decimal(10,2))) AS decimal(10,2)) as AvgCostPerCalibration

FROM dbo.Calibration_Log
WHERE VendorName IS NOT NULL AND VendorName <> ''
  AND CompletedOn >= DATEADD(month, -12, GETDATE())
GROUP BY VendorName
HAVING COUNT(*) >= 3;  -- Only show vendors with meaningful data
GO

-- =============================================
-- 4. UPCOMING CALIBRATIONS VIEW
-- =============================================

-- Upcoming Calibrations (Next 90 days)
CREATE OR ALTER VIEW vw_UpcomingCalibrations AS
SELECT
    EquipmentID,
    EquipmentName,
    EquipmentEatonID,
    EquipmentType,
    NextDueDate,

    -- Days until due
    DATEDIFF(day, CAST(GETDATE() AS date), NextDueDate) as DaysUntilDue,

    -- Urgency categories
    CASE
        WHEN NextDueDate < CAST(GETDATE() AS date) THEN 'Overdue'
        WHEN NextDueDate <= DATEADD(day, 7, CAST(GETDATE() AS date)) THEN 'Due This Week'
        WHEN NextDueDate <= DATEADD(day, 30, CAST(GETDATE() AS date)) THEN 'Due This Month'
        ELSE 'Due Later'
    END as UrgencyCategory,

    -- Last calibration info
    (SELECT TOP 1 CompletedOn
     FROM dbo.Calibration_Log cl2
     WHERE cl2.EquipmentID = cl1.EquipmentID
       AND cl2.CompletedOn IS NOT NULL
     ORDER BY cl2.CompletedOn DESC) as LastCalibrationDate,

    -- Calibration history
    (SELECT COUNT(*)
     FROM dbo.Calibration_Log cl2
     WHERE cl2.EquipmentID = cl1.EquipmentID
       AND cl2.CompletedOn IS NOT NULL) as TotalCalibrations,

    -- Average calibration interval (days)
    (SELECT AVG(DATEDIFF(day, cl2.CompletedOn, cl3.NextDueDate))
     FROM dbo.Calibration_Log cl2
     INNER JOIN dbo.Calibration_Log cl3 ON cl2.EquipmentID = cl3.EquipmentID
       AND cl3.CompletedOn > cl2.CompletedOn
     WHERE cl2.EquipmentID = cl1.EquipmentID
       AND cl2.CompletedOn IS NOT NULL
       AND cl3.NextDueDate IS NOT NULL) as AvgCalibrationIntervalDays,

    -- Vendor preference
    (SELECT TOP 1 VendorName
     FROM dbo.Calibration_Log cl2
     WHERE cl2.EquipmentID = cl1.EquipmentID
       AND cl2.VendorName IS NOT NULL
     ORDER BY cl2.CompletedOn DESC) as PreferredVendor,

    -- Method preference
    (SELECT TOP 1 Method
     FROM dbo.Calibration_Log cl2
     WHERE cl2.EquipmentID = cl1.EquipmentID
       AND cl2.Method IS NOT NULL
     ORDER BY cl2.CompletedOn DESC) as PreferredMethod

FROM dbo.Calibration_Log cl1
WHERE NextDueDate IS NOT NULL
  AND (Status IS NULL OR Status NOT IN ('Completed', 'Cancelled'))
  AND NextDueDate <= DATEADD(day, 90, CAST(GETDATE() AS date))  -- Next 90 days
GROUP BY EquipmentID, EquipmentName, EquipmentEatonID, EquipmentType, NextDueDate;
GO

-- Critical Upcoming Calibrations (Next 30 days with priority)
CREATE OR ALTER VIEW vw_CriticalUpcomingCalibrations AS
SELECT TOP 50
    EquipmentID,
    EquipmentName,
    EquipmentEatonID,
    EquipmentType,
    NextDueDate,
    DATEDIFF(day, CAST(GETDATE() AS date), NextDueDate) as DaysUntilDue,

    CASE
        WHEN NextDueDate < CAST(GETDATE() AS date) THEN 'OVERDUE - IMMEDIATE ACTION REQUIRED'
        WHEN NextDueDate <= DATEADD(day, 3, CAST(GETDATE() AS date)) THEN 'CRITICAL - DUE WITHIN 3 DAYS'
        WHEN NextDueDate <= DATEADD(day, 7, CAST(GETDATE() AS date)) THEN 'HIGH PRIORITY - DUE THIS WEEK'
        WHEN NextDueDate <= DATEADD(day, 14, CAST(GETDATE() AS date)) THEN 'MEDIUM PRIORITY - DUE SOON'
        ELSE 'PLANNING - DUE THIS MONTH'
    END as PriorityLevel,

    -- Equipment criticality (you may want to add a criticality field to your equipment table)
    CASE
        WHEN EquipmentType IN ('ATE', 'Test Station') THEN 'HIGH'
        WHEN EquipmentType IN ('Measurement Equipment', 'Calibration Standard') THEN 'HIGH'
        ELSE 'MEDIUM'
    END as EquipmentCriticality

FROM dbo.Calibration_Log
WHERE NextDueDate IS NOT NULL
  AND (Status IS NULL OR Status NOT IN ('Completed', 'Cancelled'))
  AND NextDueDate <= DATEADD(day, 30, CAST(GETDATE() AS date));
GO

-- =============================================
-- 5. DASHBOARD SUMMARY VIEW (All KPIs in one place)
-- =============================================

CREATE OR ALTER VIEW vw_CalibrationDashboardSummary AS
SELECT
    'OVERDUE_CALIBRATIONS' as MetricName,
    CAST(COUNT(CASE WHEN NextDueDate < CAST(GETDATE() AS date) AND (Status IS NULL OR Status NOT IN ('Completed', 'Cancelled')) THEN 1 END) AS varchar(50)) as MetricValue,
    'Count' as MetricType,
    CASE WHEN COUNT(CASE WHEN NextDueDate < CAST(GETDATE() AS date) AND (Status IS NULL OR Status NOT IN ('Completed', 'Cancelled')) THEN 1 END) > 0 THEN 'RED' ELSE 'GREEN' END as StatusColor,
    'Equipment requiring immediate calibration' as Description

FROM dbo.Calibration_Log

UNION ALL

SELECT
    'DUE_NEXT_30_DAYS' as MetricName,
    CAST(COUNT(CASE WHEN NextDueDate BETWEEN CAST(GETDATE() AS date) AND DATEADD(day, 30, CAST(GETDATE() AS date))
                   AND (Status IS NULL OR Status NOT IN ('Completed', 'Cancelled')) THEN 1 END) AS varchar(50)) as MetricValue,
    'Count' as MetricType,
    CASE WHEN COUNT(CASE WHEN NextDueDate BETWEEN CAST(GETDATE() AS date) AND DATEADD(day, 30, CAST(GETDATE() AS date))
                        AND (Status IS NULL OR Status NOT IN ('Completed', 'Cancelled')) THEN 1 END) > 10 THEN 'AMBER' ELSE 'GREEN' END as StatusColor,
    'Equipment due for calibration in the next 30 days' as Description

FROM dbo.Calibration_Log

UNION ALL

SELECT
    'ON_TIME_RATE_12MO' as MetricName,
    CAST(CASE WHEN COUNT(CASE WHEN CompletedOn >= DATEADD(month, -12, GETDATE()) THEN 1 END) > 0
         THEN CAST(AVG(CASE WHEN CompletedOn >= DATEADD(month, -12, GETDATE()) AND COALESCE(CompletedDate, CalibrationDate) <= CalibrationDate THEN 1.0 ELSE 0.0 END) * 100 AS decimal(5,2))
         ELSE 0 END AS varchar(50)) + '%' as MetricValue,
    'Percentage' as MetricType,
    CASE WHEN AVG(CASE WHEN CompletedOn >= DATEADD(month, -12, GETDATE()) AND COALESCE(CompletedDate, CalibrationDate) <= CalibrationDate THEN 1.0 ELSE 0.0 END) * 100 < 90 THEN 'RED'
         WHEN AVG(CASE WHEN CompletedOn >= DATEADD(month, -12, GETDATE()) AND COALESCE(CompletedDate, CalibrationDate) <= CalibrationDate THEN 1.0 ELSE 0.0 END) * 100 < 95 THEN 'AMBER'
         ELSE 'GREEN' END as StatusColor,
    'Percentage of calibrations completed on or before due date (last 12 months)' as Description

FROM dbo.Calibration_Log

UNION ALL

SELECT
    'OOT_RATE_12MO' as MetricName,
    CAST(CASE WHEN COUNT(CASE WHEN CompletedOn >= DATEADD(month, -12, GETDATE()) THEN 1 END) > 0
         THEN CAST(AVG(CASE WHEN CompletedOn >= DATEADD(month, -12, GETDATE()) AND UPPER(ResultCode) IN ('FAIL','OOT') THEN 1.0 ELSE 0.0 END) * 100 AS decimal(5,2))
         ELSE 0 END AS varchar(50)) + '%' as MetricValue,
    'Percentage' as MetricType,
    CASE WHEN AVG(CASE WHEN CompletedOn >= DATEADD(month, -12, GETDATE()) AND UPPER(ResultCode) IN ('FAIL','OOT') THEN 1.0 ELSE 0.0 END) * 100 > 5 THEN 'RED'
         WHEN AVG(CASE WHEN CompletedOn >= DATEADD(month, -12, GETDATE()) AND UPPER(ResultCode) IN ('FAIL','OOT') THEN 1.0 ELSE 0.0 END) * 100 > 1 THEN 'AMBER'
         ELSE 'GREEN' END as StatusColor,
    'Percentage of calibrations resulting in out-of-tolerance/fail (last 12 months)' as Description

FROM dbo.Calibration_Log

UNION ALL

SELECT
    'AVG_TURNAROUND_12MO' as MetricName,
    CAST(AVG(CASE WHEN CompletedOn >= DATEADD(month, -12, GETDATE()) THEN CAST(DATEDIFF(day, StartDate, COALESCE(CompletedDate, CalibrationDate)) AS float) END) AS decimal(5,1)) as MetricValue,
    'Days' as MetricType,
    'BLUE' as StatusColor,
    'Average days from calibration start to completion (last 12 months)' as Description

FROM dbo.Calibration_Log

UNION ALL

SELECT
    'TOTAL_CALIBRATIONS_THIS_MONTH' as MetricName,
    CAST(COUNT(CASE WHEN YEAR(CompletedOn) = YEAR(GETDATE()) AND MONTH(CompletedOn) = MONTH(GETDATE()) THEN 1 END) AS varchar(50)) as MetricValue,
    'Count' as MetricType,
    'BLUE' as StatusColor,
    'Total calibrations completed this month' as Description

FROM dbo.Calibration_Log

UNION ALL

SELECT
    'TOTAL_COST_LAST_12MO' as MetricName,
    '$' + CAST(SUM(CASE WHEN CompletedOn >= DATEADD(month, -12, GETDATE()) THEN CAST(Cost AS decimal(10,2)) END) AS varchar(50)) as MetricValue,
    'Currency' as MetricType,
    'BLUE' as StatusColor,
    'Total calibration costs for the last 12 months' as Description

FROM dbo.Calibration_Log;
GO

-- =============================================
-- 6. INDEXES FOR PERFORMANCE
-- =============================================

-- Drop existing indexes if they exist
DROP INDEX IF EXISTS IX_Calibration_Log_NextDueDate_Status ON dbo.Calibration_Log;
DROP INDEX IF EXISTS IX_Calibration_Log_CompletedOn_IsOnTime ON dbo.Calibration_Log;
DROP INDEX IF EXISTS IX_Calibration_Log_EquipmentType_CompletedOn ON dbo.Calibration_Log;
DROP INDEX IF EXISTS IX_Calibration_Log_VendorName_CompletedOn ON dbo.Calibration_Log;

-- Create indexes to support the dashboard queries
CREATE NONCLUSTERED INDEX IX_Calibration_Log_NextDueDate_Status
ON dbo.Calibration_Log (NextDueDate, Status)
WHERE NextDueDate IS NOT NULL;

CREATE NONCLUSTERED INDEX IX_Calibration_Log_CompletedOn_IsOnTime
ON dbo.Calibration_Log (CalibrationDate, IsOnTime)
WHERE CalibrationDate IS NOT NULL;

CREATE NONCLUSTERED INDEX IX_Calibration_Log_EquipmentType_CompletedOn
ON dbo.Calibration_Log (EquipmentType, CalibrationDate);

CREATE NONCLUSTERED INDEX IX_Calibration_Log_VendorName_CompletedOn
ON dbo.Calibration_Log (VendorName, CalibrationDate)
WHERE VendorName IS NOT NULL;

PRINT 'All Calibration Dashboard views and indexes created successfully!';
GO