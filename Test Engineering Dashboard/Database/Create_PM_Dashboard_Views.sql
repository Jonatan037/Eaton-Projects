-- =============================================
-- Preventive Maintenance Dashboard - SQL Views
-- Created: October 24, 2025
-- Purpose: Create views for PM Dashboard KPIs and Charts
-- =============================================

USE [TestEngineering]; -- Change to your database name
GO

-- =============================================
-- Drop existing views if they exist
-- =============================================
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_PM_Dashboard_KPIs')
    DROP VIEW vw_PM_Dashboard_KPIs;
GO

IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_PM_MonthlyTrend')
    DROP VIEW vw_PM_MonthlyTrend;
GO

IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_PM_ByEquipmentType')
    DROP VIEW vw_PM_ByEquipmentType;
GO

IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_PM_ByPMType')
    DROP VIEW vw_PM_ByPMType;
GO

IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_PM_OnTimePerformance')
    DROP VIEW vw_PM_OnTimePerformance;
GO

-- =============================================
-- VIEW 1: PM Dashboard KPIs
-- Returns all main KPI values
-- =============================================
CREATE VIEW vw_PM_Dashboard_KPIs
AS
SELECT 
    -- Overdue PMs
    (SELECT COUNT(*) 
     FROM PM_Log 
     WHERE NextPMDate < CAST(GETDATE() AS DATE)
       AND Status NOT IN ('Completed', 'Cancelled')) AS OverduePMs,
    
    -- Due in Next 30 Days
    (SELECT COUNT(*) 
     FROM PM_Log 
     WHERE NextPMDate >= CAST(GETDATE() AS DATE)
       AND NextPMDate <= DATEADD(DAY, 30, CAST(GETDATE() AS DATE))
       AND Status NOT IN ('Completed', 'Cancelled')) AS DueNext30Days,
    
    -- Compliance Rate (12 months)
    (SELECT 
        CAST(
            CASE 
                WHEN COUNT(*) = 0 THEN 0
                ELSE (SUM(CASE WHEN IsOnTime = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*))
            END AS DECIMAL(5,2))
     FROM PM_Log
     WHERE PMDate >= DATEADD(MONTH, -12, GETDATE())
       AND PMDate IS NOT NULL
       AND DueDate IS NOT NULL
       AND Status = 'Completed') AS ComplianceRate,
    
    -- On Time Count
    (SELECT SUM(CASE WHEN IsOnTime = 1 THEN 1 ELSE 0 END)
     FROM PM_Log
     WHERE PMDate >= DATEADD(MONTH, -12, GETDATE())
       AND PMDate IS NOT NULL
       AND DueDate IS NOT NULL
       AND Status = 'Completed') AS OnTimePMs,
    
    -- Total Completed Count
    (SELECT COUNT(*)
     FROM PM_Log
     WHERE PMDate >= DATEADD(MONTH, -12, GETDATE())
       AND PMDate IS NOT NULL
       AND DueDate IS NOT NULL
       AND Status = 'Completed') AS TotalCompletedPMs,
    
    -- Average Duration (minutes)
    (SELECT CAST(AVG(CAST(ActualDuration AS FLOAT)) AS DECIMAL(10,2))
     FROM PM_Log
     WHERE PMDate >= DATEADD(MONTH, -12, GETDATE())
       AND ActualDuration IS NOT NULL
       AND ActualDuration > 0
       AND Status = 'Completed') AS AvgDurationMinutes,
    
    -- Average Cost
    (SELECT CAST(AVG(Cost) AS DECIMAL(10,2))
     FROM PM_Log
     WHERE PMDate >= DATEADD(MONTH, -12, GETDATE())
       AND Cost IS NOT NULL
       AND Cost > 0
       AND Status = 'Completed') AS AvgCostPerPM,
    
    -- Total Cost
    (SELECT SUM(Cost)
     FROM PM_Log
     WHERE PMDate >= DATEADD(MONTH, -12, GETDATE())
       AND Cost IS NOT NULL
       AND Cost > 0
       AND Status = 'Completed') AS TotalCost,
    
    -- Count with Cost Data
    (SELECT COUNT(*)
     FROM PM_Log
     WHERE PMDate >= DATEADD(MONTH, -12, GETDATE())
       AND Cost IS NOT NULL
       AND Cost > 0
       AND Status = 'Completed') AS PMsWithCost;
GO

-- =============================================
-- VIEW 2: PM Monthly Trend (Last 12 Months)
-- =============================================
CREATE VIEW vw_PM_MonthlyTrend
AS
SELECT 
    FORMAT(PMDate, 'MMM yyyy') AS MonthLabel,
    YEAR(PMDate) AS Year,
    MONTH(PMDate) AS Month,
    COUNT(*) AS PMCount
FROM PM_Log
WHERE PMDate >= DATEADD(MONTH, -12, GETDATE())
    AND PMDate IS NOT NULL
    AND Status = 'Completed'
GROUP BY YEAR(PMDate), MONTH(PMDate), FORMAT(PMDate, 'MMM yyyy');
GO

-- =============================================
-- VIEW 3: PMs by Equipment Type (Last 12 Months)
-- =============================================
CREATE VIEW vw_PM_ByEquipmentType
AS
SELECT 
    ISNULL(EquipmentType, 'Unknown') AS EquipmentType,
    COUNT(*) AS PMCount
FROM PM_Log
WHERE PMDate >= DATEADD(MONTH, -12, GETDATE())
    AND PMDate IS NOT NULL
    AND Status = 'Completed'
GROUP BY EquipmentType;
GO

-- =============================================
-- VIEW 4: PMs by PM Type (Last 12 Months)
-- =============================================
CREATE VIEW vw_PM_ByPMType
AS
SELECT 
    ISNULL(PMType, 'Not Specified') AS PMType,
    COUNT(*) AS PMCount
FROM PM_Log
WHERE PMDate >= DATEADD(MONTH, -12, GETDATE())
    AND PMDate IS NOT NULL
    AND Status = 'Completed'
GROUP BY PMType;
GO

-- =============================================
-- VIEW 5: On-Time Performance (Last 12 Months)
-- =============================================
CREATE VIEW vw_PM_OnTimePerformance
AS
SELECT 
    CASE 
        WHEN IsOnTime = 1 THEN 'On Time'
        WHEN IsOnTime = 0 THEN 'Late'
        ELSE 'Unknown'
    END AS Status,
    COUNT(*) AS PMCount
FROM PM_Log
WHERE PMDate >= DATEADD(MONTH, -12, GETDATE())
    AND PMDate IS NOT NULL
    AND DueDate IS NOT NULL
    AND Status = 'Completed'
GROUP BY IsOnTime;
GO

-- =============================================
-- Verify views were created
-- =============================================
SELECT 'Views created successfully:' AS Message;
SELECT name AS ViewName, create_date AS CreatedDate
FROM sys.views
WHERE name LIKE 'vw_PM%'
ORDER BY name;
GO

-- =============================================
-- Test the views
-- =============================================
PRINT 'Testing vw_PM_Dashboard_KPIs...';
SELECT * FROM vw_PM_Dashboard_KPIs;

PRINT 'Testing vw_PM_MonthlyTrend...';
SELECT * FROM vw_PM_MonthlyTrend ORDER BY Year, Month;

PRINT 'Testing vw_PM_ByEquipmentType...';
SELECT * FROM vw_PM_ByEquipmentType ORDER BY PMCount DESC;

PRINT 'Testing vw_PM_ByPMType...';
SELECT * FROM vw_PM_ByPMType ORDER BY PMCount DESC;

PRINT 'Testing vw_PM_OnTimePerformance...';
SELECT * FROM vw_PM_OnTimePerformance ORDER BY Status;
GO

PRINT 'All views created and tested successfully!';
GO
