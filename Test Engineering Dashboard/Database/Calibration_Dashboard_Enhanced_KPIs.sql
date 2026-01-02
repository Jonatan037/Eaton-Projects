-- =============================================
-- CALIBRATION DASHBOARD - ADDITIONAL KPI VIEW
-- =============================================
-- This script adds helper columns to vw_CalibrationKPIs
-- for better dashboard performance
-- =============================================

USE [TestEngineering];
GO

-- =============================================
-- Enhanced KPI View with more granular data
-- =============================================

CREATE OR ALTER VIEW vw_CalibrationKPIs AS
WITH CurrentStats AS (
    SELECT
        -- Overdue calibrations
        COUNT(CASE 
            WHEN NextDueDate < CAST(GETDATE() AS date) 
                AND (Status IS NULL OR Status NOT IN ('Completed', 'Cancelled')) 
            THEN 1 
        END) as OverdueCount,
        
        -- Due in next 7 days
        COUNT(CASE 
            WHEN NextDueDate >= CAST(GETDATE() AS date)
                AND NextDueDate <= DATEADD(day, 7, CAST(GETDATE() AS date))
                AND (Status IS NULL OR Status NOT IN ('Completed', 'Cancelled'))
            THEN 1 
        END) as DueNext7Days,
        
        -- Due in next 30 days
        COUNT(CASE 
            WHEN NextDueDate >= CAST(GETDATE() AS date)
                AND NextDueDate <= DATEADD(day, 30, CAST(GETDATE() AS date))
                AND (Status IS NULL OR Status NOT IN ('Completed', 'Cancelled'))
            THEN 1 
        END) as DueNext30Days,
        
        -- Total active calibrations
        COUNT(CASE 
            WHEN Status IS NULL OR Status NOT IN ('Completed', 'Cancelled') 
            THEN 1 
        END) as TotalActive
    FROM dbo.Calibration_Log
),
Last12Months AS (
    SELECT
        COUNT(*) as TotalCalibrations,
        SUM(CASE WHEN IsOnTime = 1 THEN 1 ELSE 0 END) as OnTimeCount,
        SUM(CASE WHEN IsOutOfTolerance = 1 THEN 1 ELSE 0 END) as OOTCount,
        AVG(CAST(TurnaroundDays AS float)) as AvgTurnaroundDays,
        SUM(CAST(ISNULL(Cost, 0) AS decimal(10,2))) as TotalCost,
        AVG(CAST(ISNULL(Cost, 0) AS decimal(10,2))) as AvgCost
    FROM dbo.Calibration_Log
    WHERE CompletedOn >= DATEADD(month, -12, GETDATE())
      AND CompletedOn IS NOT NULL
),
ThisMonth AS (
    SELECT
        COUNT(*) as ThisMonthCalibrations,
        SUM(CAST(ISNULL(Cost, 0) AS decimal(10,2))) as ThisMonthCost
    FROM dbo.Calibration_Log
    WHERE CompletedOn >= DATEADD(day, -DAY(GETDATE())+1, CAST(GETDATE() AS date))
      AND CompletedOn < DATEADD(month, 1, DATEADD(day, -DAY(GETDATE())+1, CAST(GETDATE() AS date)))
)
SELECT
    -- Current status counts
    cs.OverdueCount,
    cs.DueNext7Days,
    cs.DueNext30Days,
    cs.TotalActive,

    -- 12-month performance metrics
    lm.TotalCalibrations,
    lm.OnTimeCount,
    lm.OOTCount,
    
    -- On-time rate percentage (last 12 months)
    CASE WHEN lm.TotalCalibrations > 0
         THEN CAST((CAST(lm.OnTimeCount AS float) / CAST(lm.TotalCalibrations AS float)) * 100 AS decimal(5,2))
         ELSE 0 
    END as OnTimeRatePercent,

    -- Out-of-tolerance rate percentage (last 12 months)
    CASE WHEN lm.TotalCalibrations > 0
         THEN CAST((CAST(lm.OOTCount AS float) / CAST(lm.TotalCalibrations AS float)) * 100 AS decimal(5,2))
         ELSE 0 
    END as OOTRatePercent,

    -- Average turnaround time (last 12 months)
    CAST(ISNULL(lm.AvgTurnaroundDays, 0) AS decimal(5,1)) as AvgTurnaroundDays,
    
    -- Cost metrics (last 12 months)
    CAST(ISNULL(lm.TotalCost, 0) AS decimal(12,2)) as TotalCost12Mo,
    CAST(ISNULL(lm.AvgCost, 0) AS decimal(10,2)) as AvgCost12Mo,
    
    -- This month metrics
    tm.ThisMonthCalibrations,
    CAST(ISNULL(tm.ThisMonthCost, 0) AS decimal(12,2)) as ThisMonthCost

FROM CurrentStats cs
CROSS JOIN Last12Months lm
CROSS JOIN ThisMonth tm;
GO

PRINT 'Enhanced vw_CalibrationKPIs view created successfully!';
GO

-- =============================================
-- INDEX OPTIMIZATION FOR DASHBOARD QUERIES
-- =============================================

-- Ensure indexes exist for fast dashboard queries
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Calibration_Log_NextDueDate_Status' AND object_id = OBJECT_ID('dbo.Calibration_Log'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Calibration_Log_NextDueDate_Status
    ON dbo.Calibration_Log (NextDueDate, Status)
    INCLUDE (EquipmentEatonID, EquipmentName, EquipmentType)
    WHERE NextDueDate IS NOT NULL;
    PRINT 'Index IX_Calibration_Log_NextDueDate_Status created.';
END

-- Index on CalibrationDate and CompletedDate (base columns, not computed)
-- This supports queries filtering by CompletedOn (which is COALESCE of these two)
-- Note: No WHERE clause to avoid OR limitation in filtered indexes
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Calibration_Log_CalibrationDate' AND object_id = OBJECT_ID('dbo.Calibration_Log'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Calibration_Log_CalibrationDate
    ON dbo.Calibration_Log (CalibrationDate, CompletedDate)
    INCLUDE (EquipmentType, Method, VendorName, ResultCode, Cost);
    PRINT 'Index IX_Calibration_Log_CalibrationDate created.';
END

PRINT 'All indexes verified/created successfully!';
GO
