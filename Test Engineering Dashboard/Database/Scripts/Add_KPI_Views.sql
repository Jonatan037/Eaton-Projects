-- =============================================
-- KPI Views Creation Script
-- Test Engineering Dashboard
-- Database: TestEngineering
-- Created: October 2, 2025
-- Purpose: Create views for efficient KPI calculations across all dashboards
-- =============================================

USE TestEngineering;
GO

PRINT '========================================';
PRINT 'Creating KPI Views';
PRINT 'Database: TestEngineering';
PRINT 'Date: ' + CONVERT(varchar, GETDATE(), 120);
PRINT '========================================';
GO

-- =============================================
-- VIEW 1: CALIBRATION KPIs
-- =============================================
PRINT 'Creating vw_CalibrationKPIs...';
GO

IF OBJECT_ID('dbo.vw_CalibrationKPIs', 'V') IS NOT NULL
    DROP VIEW dbo.vw_CalibrationKPIs;
GO

CREATE VIEW dbo.vw_CalibrationKPIs
AS
WITH InventoryCTE AS (
    -- Union all equipment requiring calibration with NextCalibration date
    SELECT 'ATE' AS EquipmentType, ATEInventoryID AS EquipmentID, EatonID, ATEName AS EquipmentName, 
           NextCalibration, Location, ATEStatus AS CurrentStatus
    FROM ATE_Inventory
    WHERE RequiresCalibration = 1 AND IsActive = 1
    UNION ALL
    SELECT 'Asset', AssetID, EatonID, DeviceName, 
           NextCalibration, Location, CurrentStatus
    FROM Asset_Inventory
    WHERE RequiresCalibration = 1 AND IsActive = 1
    UNION ALL
    SELECT 'Fixture', FixtureID, EatonID, FixtureModelNoName, 
           NextCalibration, Location, CurrentStatus
    FROM Fixture_Inventory
    WHERE RequiresCalibration = 1 AND IsActive = 1
    UNION ALL
    SELECT 'Harness', HarnessID, EatonID, HarnessModelNo, 
           NextCalibration, Location, CurrentStatus
    FROM Harness_Inventory
    WHERE RequiresCalibration = 1 AND IsActive = 1
),
OverdueCTE AS (
    SELECT EquipmentType, COUNT(*) AS OverdueCount
    FROM InventoryCTE
    WHERE NextCalibration < CAST(GETDATE() AS DATE)
    GROUP BY EquipmentType
),
DueSoonCTE AS (
    SELECT EquipmentType, COUNT(*) AS DueNext30Days
    FROM InventoryCTE
    WHERE NextCalibration BETWEEN CAST(GETDATE() AS DATE) AND DATEADD(day, 30, CAST(GETDATE() AS DATE))
    GROUP BY EquipmentType
),
CalLogStatsCTE AS (
    -- Last 12 months calibration statistics
    SELECT 
        COUNT(*) AS TotalCalibrations,
        SUM(CASE WHEN IsOnTime = 1 THEN 1 ELSE 0 END) AS OnTimeCount,
        SUM(CASE WHEN IsOutOfTolerance = 1 THEN 1 ELSE 0 END) AS OOTCount,
        AVG(CAST(TurnaroundDays AS float)) AS AvgTurnaroundDays,
        SUM(ISNULL(Cost, 0)) AS TotalCost
    FROM Calibration_Log
    WHERE CompletedOn >= DATEADD(month, -12, GETDATE())
      AND CompletedOn IS NOT NULL
)
SELECT 
    -- Real-time overdue counts
    ISNULL((SELECT SUM(OverdueCount) FROM OverdueCTE), 0) AS TotalOverdue,
    ISNULL((SELECT OverdueCount FROM OverdueCTE WHERE EquipmentType = 'ATE'), 0) AS OverdueATE,
    ISNULL((SELECT OverdueCount FROM OverdueCTE WHERE EquipmentType = 'Asset'), 0) AS OverdueAsset,
    ISNULL((SELECT OverdueCount FROM OverdueCTE WHERE EquipmentType = 'Fixture'), 0) AS OverdueFixture,
    ISNULL((SELECT OverdueCount FROM OverdueCTE WHERE EquipmentType = 'Harness'), 0) AS OverdueHarness,
    
    -- Due in next 30 days
    ISNULL((SELECT SUM(DueNext30Days) FROM DueSoonCTE), 0) AS TotalDueNext30Days,
    ISNULL((SELECT DueNext30Days FROM DueSoonCTE WHERE EquipmentType = 'ATE'), 0) AS DueNext30ATE,
    ISNULL((SELECT DueNext30Days FROM DueSoonCTE WHERE EquipmentType = 'Asset'), 0) AS DueNext30Asset,
    ISNULL((SELECT DueNext30Days FROM DueSoonCTE WHERE EquipmentType = 'Fixture'), 0) AS DueNext30Fixture,
    ISNULL((SELECT DueNext30Days FROM DueSoonCTE WHERE EquipmentType = 'Harness'), 0) AS DueNext30Harness,
    
    -- Historical metrics (last 12 months)
    s.TotalCalibrations,
    CASE WHEN s.TotalCalibrations > 0 
         THEN CAST(s.OnTimeCount * 100.0 / s.TotalCalibrations AS decimal(5,2))
         ELSE NULL END AS OnTimeRate,
    CASE WHEN s.TotalCalibrations > 0 
         THEN CAST(s.OOTCount * 100.0 / s.TotalCalibrations AS decimal(5,2))
         ELSE NULL END AS OOTRate,
    CAST(s.AvgTurnaroundDays AS decimal(10,2)) AS AvgTurnaroundDays,
    s.TotalCost AS TotalCostLast12Mo,
    CASE WHEN s.TotalCalibrations > 0 
         THEN CAST(s.TotalCost / s.TotalCalibrations AS decimal(10,2))
         ELSE NULL END AS AvgCostPerCalibration
FROM CalLogStatsCTE s;
GO

PRINT '  + vw_CalibrationKPIs created successfully';
GO

-- =============================================
-- VIEW 2: TEST COMPUTER KPIs
-- =============================================
PRINT 'Creating vw_ComputerKPIs...';
GO

IF OBJECT_ID('dbo.vw_ComputerKPIs', 'V') IS NOT NULL
    DROP VIEW dbo.vw_ComputerKPIs;
GO

CREATE VIEW dbo.vw_ComputerKPIs
AS
WITH StatusCTE AS (
    SELECT 
        CurrentStatus,
        COUNT(*) AS Count
    FROM Computer_Inventory
    WHERE IsActive = 1
    GROUP BY CurrentStatus
),
TasksCTE AS (
    SELECT 
        SUM(CASE WHEN HasOpenITTask = 1 THEN 1 ELSE 0 END) AS OpenITTasks,
        SUM(CASE WHEN HasOpenTestEngTask = 1 THEN 1 ELSE 0 END) AS OpenTestEngTasks
    FROM Computer_Inventory
    WHERE IsActive = 1
),
AgeCTE AS (
    SELECT 
        AVG(CAST(DATEDIFF(day, ComputerDate, GETDATE()) / 365.25 AS float)) AS AvgAgeYears
    FROM Computer_Inventory
    WHERE CurrentStatus = 'In Use' 
      AND ComputerDate IS NOT NULL
      AND IsActive = 1
),
StationCTE AS (
    SELECT TOP 5
        ts.TestStationName,
        COUNT(c.ComputerID) AS ComputerCount
    FROM Computer_Inventory c
    INNER JOIN TestStation_Bay ts ON c.TestStationID = ts.TestStationID
    WHERE c.IsActive = 1
    GROUP BY ts.TestStationName
    ORDER BY COUNT(c.ComputerID) DESC
)
SELECT 
    -- Status distribution
    ISNULL((SELECT Count FROM StatusCTE WHERE CurrentStatus = 'In Use'), 0) AS InUseCount,
    ISNULL((SELECT Count FROM StatusCTE WHERE CurrentStatus = 'Available'), 0) AS AvailableCount,
    ISNULL((SELECT Count FROM StatusCTE WHERE CurrentStatus = 'Maintenance'), 0) AS MaintenanceCount,
    ISNULL((SELECT Count FROM StatusCTE WHERE CurrentStatus = 'Retired'), 0) AS RetiredCount,
    
    -- Task counts
    ISNULL((SELECT OpenITTasks FROM TasksCTE), 0) AS OpenITTasks,
    ISNULL((SELECT OpenTestEngTasks FROM TasksCTE), 0) AS OpenTestEngTasks,
    
    -- Average age
    CAST(ISNULL((SELECT AvgAgeYears FROM AgeCTE), 0) AS decimal(10,2)) AS AvgAgeYears,
    
    -- Total active computers
    (SELECT COUNT(*) FROM Computer_Inventory WHERE IsActive = 1) AS TotalActiveComputers,
    
    -- Station distribution (JSON-like string for top 5)
    (SELECT 
        STUFF((SELECT ',' + TestStationName + ':' + CAST(ComputerCount AS varchar)
               FROM StationCTE
               FOR XML PATH('')), 1, 1, '')
    ) AS TopStationsDistribution;
GO

PRINT '  + vw_ComputerKPIs created successfully';
GO

-- =============================================
-- VIEW 3: PREVENTIVE MAINTENANCE KPIs
-- =============================================
PRINT 'Creating vw_PMKPIs...';
GO

IF OBJECT_ID('dbo.vw_PMKPIs', 'V') IS NOT NULL
    DROP VIEW dbo.vw_PMKPIs;
GO

CREATE VIEW dbo.vw_PMKPIs
AS
WITH InventoryCTE AS (
    -- Union all equipment requiring PM with NextPM date
    SELECT 'ATE' AS EquipmentType, ATEInventoryID AS EquipmentID, EatonID, ATEName AS EquipmentName, 
           NextPM, ATEStatus AS CurrentStatus
    FROM ATE_Inventory
    WHERE RequiredPM = 1 AND IsActive = 1
    UNION ALL
    SELECT 'Asset', AssetID, EatonID, DeviceName, 
           NextPM, CurrentStatus
    FROM Asset_Inventory
    WHERE RequiredPM = 1 AND IsActive = 1
    UNION ALL
    SELECT 'Computer', ComputerID, NULL, ComputerName,
           NULL, CurrentStatus  -- Computers don't have NextPM in current schema
    FROM Computer_Inventory
    WHERE IsActive = 1
    UNION ALL
    SELECT 'Fixture', FixtureID, EatonID, FixtureModelNoName, 
           NextPM, CurrentStatus
    FROM Fixture_Inventory
    WHERE RequiredPM = 1 AND IsActive = 1
    UNION ALL
    SELECT 'Harness', HarnessID, EatonID, HarnessModelNo, 
           NextPM, CurrentStatus
    FROM Harness_Inventory
    WHERE RequiredPM = 1 AND IsActive = 1
),
OverdueCTE AS (
    SELECT EquipmentType, COUNT(*) AS OverdueCount
    FROM InventoryCTE
    WHERE NextPM < CAST(GETDATE() AS DATE)
    GROUP BY EquipmentType
),
PMLogStatsCTE AS (
    -- Last 12 months PM statistics
    SELECT 
        COUNT(*) AS TotalPMs,
        SUM(CASE WHEN IsOnTime = 1 THEN 1 ELSE 0 END) AS OnTimeCount,
        SUM(CASE WHEN YEAR(PMDate) = YEAR(GETDATE()) THEN 1 ELSE 0 END) AS CompletedYTD,
        AVG(CAST(ActualDuration AS float)) AS AvgDurationMinutes
    FROM PM_Log
    WHERE PMDate >= DATEADD(month, -12, GETDATE())
      AND Status = 'Completed'
),
UnplannedDowntimeCTE AS (
    -- Unplanned downtime events (last 30 days): Major/Critical issues
    SELECT 
        COUNT(*) AS TotalIssues,
        COUNT(CASE WHEN ImpactLevel IN ('Major','Critical') THEN 1 END) AS UnplannedDowntimeEvents
    FROM Troubleshooting_Log
    WHERE ReportedDateTime >= DATEADD(day, -30, GETDATE())
)
SELECT 
    -- Overdue PMs by type
    ISNULL((SELECT SUM(OverdueCount) FROM OverdueCTE), 0) AS TotalOverduePMs,
    ISNULL((SELECT OverdueCount FROM OverdueCTE WHERE EquipmentType = 'ATE'), 0) AS OverdueATE,
    ISNULL((SELECT OverdueCount FROM OverdueCTE WHERE EquipmentType = 'Asset'), 0) AS OverdueAsset,
    ISNULL((SELECT OverdueCount FROM OverdueCTE WHERE EquipmentType = 'Computer'), 0) AS OverdueComputer,
    ISNULL((SELECT OverdueCount FROM OverdueCTE WHERE EquipmentType = 'Fixture'), 0) AS OverdueFixture,
    ISNULL((SELECT OverdueCount FROM OverdueCTE WHERE EquipmentType = 'Harness'), 0) AS OverdueHarness,
    
    -- PM statistics
    s.TotalPMs AS TotalPMsLast12Mo,
    CASE WHEN s.TotalPMs > 0 
         THEN CAST(s.OnTimeCount * 100.0 / s.TotalPMs AS decimal(5,2))
         ELSE NULL END AS ComplianceRate,
    s.CompletedYTD,
    CAST(s.AvgDurationMinutes AS decimal(10,2)) AS AvgPMDurationMinutes,
    
    -- Unplanned downtime rate (last 30 days)
    CASE WHEN udt.TotalIssues > 0
         THEN CAST(udt.UnplannedDowntimeEvents * 100.0 / udt.TotalIssues AS decimal(5,2))
         ELSE 0 END AS UnplannedDowntimeRate
FROM PMLogStatsCTE s, UnplannedDowntimeCTE udt;
GO

PRINT '  + vw_PMKPIs created successfully';
GO

-- =============================================
-- VIEW 4: TROUBLESHOOTING KPIs
-- =============================================
PRINT 'Creating vw_TroubleshootingKPIs...';
GO

IF OBJECT_ID('dbo.vw_TroubleshootingKPIs', 'V') IS NOT NULL
    DROP VIEW dbo.vw_TroubleshootingKPIs;
GO

CREATE VIEW dbo.vw_TroubleshootingKPIs
AS
WITH OpenByPriorityCTE AS (
    SELECT 
        Priority,
        COUNT(*) AS OpenCount
    FROM Troubleshooting_Log
    WHERE Status IN ('Open', 'In Progress')
    GROUP BY Priority
),
ResolutionStatsCTE AS (
    -- Last 12 months resolution statistics
    SELECT 
        AVG(CAST(ResolutionTimeHours AS float)) AS AvgResolutionHours,
        COUNT(CASE WHEN IsRepeat = 1 THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0) AS RepeatRate
    FROM Troubleshooting_Log
    WHERE ResolvedDateTime >= DATEADD(month, -12, GETDATE())
      AND IsResolved = 1
),
TopClassificationsCTE AS (
    SELECT TOP 5
        IssueClassification,
        COUNT(*) AS IssueCount
    FROM Troubleshooting_Log
    WHERE IssueClassification IS NOT NULL
      AND ReportedDateTime >= DATEADD(month, -12, GETDATE())
    GROUP BY IssueClassification
    ORDER BY COUNT(*) DESC
),
EquipmentTypeCTE AS (
    SELECT 
        EquipmentType,
        COUNT(*) AS IssueCount
    FROM Troubleshooting_Log
    WHERE EquipmentType IS NOT NULL
      AND ReportedDateTime >= DATEADD(month, -12, GETDATE())
    GROUP BY EquipmentType
)
SELECT 
    -- Open issues by priority
    ISNULL((SELECT SUM(OpenCount) FROM OpenByPriorityCTE), 0) AS TotalOpenIssues,
    ISNULL((SELECT OpenCount FROM OpenByPriorityCTE WHERE Priority = 'Critical'), 0) AS OpenCritical,
    ISNULL((SELECT OpenCount FROM OpenByPriorityCTE WHERE Priority = 'High'), 0) AS OpenHigh,
    ISNULL((SELECT OpenCount FROM OpenByPriorityCTE WHERE Priority = 'Medium'), 0) AS OpenMedium,
    ISNULL((SELECT OpenCount FROM OpenByPriorityCTE WHERE Priority = 'Low'), 0) AS OpenLow,
    
    -- Resolution statistics
    CAST(ISNULL((SELECT AvgResolutionHours FROM ResolutionStatsCTE), 0) AS decimal(10,2)) AS AvgResolutionHours,
    CAST(ISNULL((SELECT RepeatRate FROM ResolutionStatsCTE), 0) AS decimal(5,2)) AS RepeatIssueRate,
    
    -- Top issue classifications (comma-separated)
    (SELECT 
        STUFF((SELECT ',' + IssueClassification + ':' + CAST(IssueCount AS varchar)
               FROM TopClassificationsCTE
               FOR XML PATH('')), 1, 1, '')
    ) AS TopClassifications,
    
    -- Issues by equipment type (comma-separated)
    (SELECT 
        STUFF((SELECT ',' + EquipmentType + ':' + CAST(IssueCount AS varchar)
               FROM EquipmentTypeCTE
               FOR XML PATH('')), 1, 1, '')
    ) AS IssuesByEquipmentType;
GO

PRINT '  + vw_TroubleshootingKPIs created successfully';
GO

-- =============================================
-- VIEW 5: TEST STATION KPIs
-- =============================================
PRINT 'Creating vw_TestStationKPIs...';
GO

IF OBJECT_ID('dbo.vw_TestStationKPIs', 'V') IS NOT NULL
    DROP VIEW dbo.vw_TestStationKPIs;
GO

CREATE VIEW dbo.vw_TestStationKPIs
AS
WITH StationEquipmentCTE AS (
    -- Count all equipment per station
    SELECT 
        ts.TestStationID,
        ts.TestStationName,
        ts.StationSubLineCode,
        ts.IsOperational,
        ISNULL(ate_cnt.ATECount, 0) AS ATECount,
        ISNULL(asset_cnt.AssetCount, 0) AS AssetCount,
        ISNULL(fixture_cnt.FixtureCount, 0) AS FixtureCount,
        ISNULL(harness_cnt.HarnessCount, 0) AS HarnessCount,
        ISNULL(computer_cnt.ComputerCount, 0) AS ComputerCount,
        ISNULL(ate_use.InUse, 0) AS ATEInUse,
        ISNULL(asset_use.InUse, 0) AS AssetInUse,
        ISNULL(fixture_use.InUse, 0) AS FixtureInUse,
        ISNULL(harness_use.InUse, 0) AS HarnessInUse,
        ISNULL(computer_use.InUse, 0) AS ComputerInUse,
        ISNULL(ate_maint.Maintenance, 0) AS ATEMaintenance,
        ISNULL(asset_maint.Maintenance, 0) AS AssetMaintenance,
        ISNULL(fixture_maint.Maintenance, 0) AS FixtureMaintenance,
        ISNULL(harness_maint.Maintenance, 0) AS HarnessMaintenance,
        ISNULL(computer_maint.Maintenance, 0) AS ComputerMaintenance
    FROM TestStation_Bay ts
    LEFT JOIN (SELECT TestStationID, COUNT(*) AS ATECount FROM ATE_Inventory WHERE IsActive=1 GROUP BY TestStationID) ate_cnt ON ts.TestStationID = ate_cnt.TestStationID
    LEFT JOIN (SELECT TestStationID, COUNT(*) AS AssetCount FROM Asset_Inventory WHERE IsActive=1 GROUP BY TestStationID) asset_cnt ON ts.TestStationID = asset_cnt.TestStationID
    LEFT JOIN (SELECT TestStationID, COUNT(*) AS FixtureCount FROM Fixture_Inventory WHERE IsActive=1 GROUP BY TestStationID) fixture_cnt ON ts.TestStationID = fixture_cnt.TestStationID
    LEFT JOIN (SELECT TestStationID, COUNT(*) AS HarnessCount FROM Harness_Inventory WHERE IsActive=1 GROUP BY TestStationID) harness_cnt ON ts.TestStationID = harness_cnt.TestStationID
    LEFT JOIN (SELECT TestStationID, COUNT(*) AS ComputerCount FROM Computer_Inventory WHERE IsActive=1 GROUP BY TestStationID) computer_cnt ON ts.TestStationID = computer_cnt.TestStationID
    LEFT JOIN (SELECT TestStationID, COUNT(*) AS InUse FROM ATE_Inventory WHERE IsActive=1 AND ATEStatus='In Use' GROUP BY TestStationID) ate_use ON ts.TestStationID = ate_use.TestStationID
    LEFT JOIN (SELECT TestStationID, COUNT(*) AS InUse FROM Asset_Inventory WHERE IsActive=1 AND CurrentStatus='In Use' GROUP BY TestStationID) asset_use ON ts.TestStationID = asset_use.TestStationID
    LEFT JOIN (SELECT TestStationID, COUNT(*) AS InUse FROM Fixture_Inventory WHERE IsActive=1 AND CurrentStatus='In Use' GROUP BY TestStationID) fixture_use ON ts.TestStationID = fixture_use.TestStationID
    LEFT JOIN (SELECT TestStationID, COUNT(*) AS InUse FROM Harness_Inventory WHERE IsActive=1 AND CurrentStatus='In Use' GROUP BY TestStationID) harness_use ON ts.TestStationID = harness_use.TestStationID
    LEFT JOIN (SELECT TestStationID, COUNT(*) AS InUse FROM Computer_Inventory WHERE IsActive=1 AND CurrentStatus='In Use' GROUP BY TestStationID) computer_use ON ts.TestStationID = computer_use.TestStationID
    LEFT JOIN (SELECT TestStationID, COUNT(*) AS Maintenance FROM ATE_Inventory WHERE IsActive=1 AND ATEStatus='Maintenance' GROUP BY TestStationID) ate_maint ON ts.TestStationID = ate_maint.TestStationID
    LEFT JOIN (SELECT TestStationID, COUNT(*) AS Maintenance FROM Asset_Inventory WHERE IsActive=1 AND CurrentStatus='Maintenance' GROUP BY TestStationID) asset_maint ON ts.TestStationID = asset_maint.TestStationID
    LEFT JOIN (SELECT TestStationID, COUNT(*) AS Maintenance FROM Fixture_Inventory WHERE IsActive=1 AND CurrentStatus='Maintenance' GROUP BY TestStationID) fixture_maint ON ts.TestStationID = fixture_maint.TestStationID
    LEFT JOIN (SELECT TestStationID, COUNT(*) AS Maintenance FROM Harness_Inventory WHERE IsActive=1 AND CurrentStatus='Maintenance' GROUP BY TestStationID) harness_maint ON ts.TestStationID = harness_maint.TestStationID
    LEFT JOIN (SELECT TestStationID, COUNT(*) AS Maintenance FROM Computer_Inventory WHERE IsActive=1 AND CurrentStatus='Maintenance' GROUP BY TestStationID) computer_maint ON ts.TestStationID = computer_maint.TestStationID
    WHERE ts.IsActive = 1
),
OverdueCalsCTE AS (
    -- Overdue calibrations per station
    SELECT 
        TestStationID,
        COUNT(*) AS OverdueCount
    FROM (
        SELECT TestStationID FROM ATE_Inventory WHERE RequiresCalibration=1 AND NextCalibration < CAST(GETDATE() AS DATE) AND IsActive=1
        UNION ALL
        SELECT TestStationID FROM Asset_Inventory WHERE RequiresCalibration=1 AND NextCalibration < CAST(GETDATE() AS DATE) AND IsActive=1
        UNION ALL
        SELECT TestStationID FROM Fixture_Inventory WHERE RequiresCalibration=1 AND NextCalibration < CAST(GETDATE() AS DATE) AND IsActive=1
        UNION ALL
        SELECT TestStationID FROM Harness_Inventory WHERE RequiresCalibration=1 AND NextCalibration < CAST(GETDATE() AS DATE) AND IsActive=1
    ) Overdue
    WHERE TestStationID IS NOT NULL
    GROUP BY TestStationID
),
DowntimeEventsCTE AS (
    -- Troubleshooting events in last 30 days linked to station equipment
    SELECT 
        TestStationID,
        COUNT(*) AS DowntimeEvents
    FROM (
        SELECT a.TestStationID 
        FROM Troubleshooting_Log t
        INNER JOIN ATE_Inventory a ON t.AffectedATEID = a.ATEInventoryID
        WHERE t.ReportedDateTime >= DATEADD(day, -30, GETDATE())
        UNION ALL
        SELECT a.TestStationID 
        FROM Troubleshooting_Log t
        INNER JOIN Asset_Inventory a ON t.AffectedAssetID = a.AssetID
        WHERE t.ReportedDateTime >= DATEADD(day, -30, GETDATE())
        UNION ALL
        SELECT f.TestStationID 
        FROM Troubleshooting_Log t
        INNER JOIN Fixture_Inventory f ON t.AffectedFixtureID = f.FixtureID
        WHERE t.ReportedDateTime >= DATEADD(day, -30, GETDATE())
        UNION ALL
        SELECT h.TestStationID 
        FROM Troubleshooting_Log t
        INNER JOIN Harness_Inventory h ON t.AffectedHarnessID = h.HarnessID
        WHERE t.ReportedDateTime >= DATEADD(day, -30, GETDATE())
    ) Events
    WHERE TestStationID IS NOT NULL
    GROUP BY TestStationID
)
SELECT 
    se.TestStationID,
    se.TestStationName,
    se.StationSubLineCode,
    se.IsOperational,
    
    -- Equipment counts
    se.ATECount,
    se.AssetCount,
    se.FixtureCount,
    se.HarnessCount,
    se.ComputerCount,
    (se.ATECount + se.AssetCount + se.FixtureCount + se.HarnessCount + se.ComputerCount) AS TotalEquipmentCount,
    
    -- Utilization
    (se.ATEInUse + se.AssetInUse + se.FixtureInUse + se.HarnessInUse + se.ComputerInUse) AS TotalInUse,
    CASE WHEN (se.ATECount + se.AssetCount + se.FixtureCount + se.HarnessCount + se.ComputerCount) > 0
         THEN CAST((se.ATEInUse + se.AssetInUse + se.FixtureInUse + se.HarnessInUse + se.ComputerInUse) * 100.0 / 
                   (se.ATECount + se.AssetCount + se.FixtureCount + se.HarnessCount + se.ComputerCount) AS decimal(5,2))
         ELSE 0 END AS UtilizationRate,
    
    -- Maintenance
    (se.ATEMaintenance + se.AssetMaintenance + se.FixtureMaintenance + se.HarnessMaintenance + se.ComputerMaintenance) AS TotalInMaintenance,
    
    -- Overdue calibrations
    ISNULL(oc.OverdueCount, 0) AS OverdueCalibrations,
    
    -- Downtime events
    ISNULL(de.DowntimeEvents, 0) AS DowntimeEventsLast30Days
FROM StationEquipmentCTE se
LEFT JOIN OverdueCalsCTE oc ON se.TestStationID = oc.TestStationID
LEFT JOIN DowntimeEventsCTE de ON se.TestStationID = de.TestStationID;
GO

PRINT '  + vw_TestStationKPIs created successfully';
GO

-- =============================================
-- VIEW 6: ADMIN - ACCOUNT REQUEST KPIs
-- =============================================
PRINT 'Creating vw_AccountRequestKPIs...';
GO

IF OBJECT_ID('dbo.vw_AccountRequestKPIs', 'V') IS NOT NULL
    DROP VIEW dbo.vw_AccountRequestKPIs;
GO

CREATE VIEW dbo.vw_AccountRequestKPIs
AS
WITH RequestStatsCTE AS (
    SELECT 
        COUNT(CASE WHEN Status = 'Pending' THEN 1 END) AS PendingRequests,
        AVG(CASE WHEN ReviewedAt IS NOT NULL 
                 THEN CAST(ReviewTimeHours AS float) 
                 ELSE NULL END) AS AvgReviewHours,
        COUNT(CASE WHEN Status = 'Approved' AND ReviewedAt >= DATEADD(day, -90, GETDATE()) THEN 1 END) AS ApprovedLast90,
        COUNT(CASE WHEN Status = 'Rejected' AND ReviewedAt >= DATEADD(day, -90, GETDATE()) THEN 1 END) AS RejectedLast90
    FROM AccountRequests
),
CategoryDistributionCTE AS (
    SELECT 
        AssignedAppRole AS UserCategory,
        COUNT(*) AS RequestCount
    FROM AccountRequests
    WHERE Status = 'Pending' OR SubmittedAt >= DATEADD(day, -90, GETDATE())
    GROUP BY AssignedAppRole
)
SELECT 
    -- Pending requests
    s.PendingRequests,
    
    -- Average approval time (hours)
    CAST(ISNULL(s.AvgReviewHours, 0) AS decimal(10,2)) AS AvgReviewHours,
    
    -- Approval rate (last 90 days)
    CASE WHEN (s.ApprovedLast90 + s.RejectedLast90) > 0
         THEN CAST(s.ApprovedLast90 * 100.0 / (s.ApprovedLast90 + s.RejectedLast90) AS decimal(5,2))
         ELSE NULL END AS ApprovalRate,
    
    -- Category distribution (comma-separated)
    (SELECT 
        STUFF((SELECT ',' + UserCategory + ':' + CAST(RequestCount AS varchar)
               FROM CategoryDistributionCTE
               FOR XML PATH('')), 1, 1, '')
    ) AS CategoryDistribution
FROM RequestStatsCTE s;
GO

PRINT '  + vw_AccountRequestKPIs created successfully';
GO

-- =============================================
-- VIEW 7: ADMIN - USER KPIs
-- =============================================
PRINT 'Creating vw_UserKPIs...';
GO

IF OBJECT_ID('dbo.vw_UserKPIs', 'V') IS NOT NULL
    DROP VIEW dbo.vw_UserKPIs;
GO

CREATE VIEW dbo.vw_UserKPIs
AS
WITH UserStatsCTE AS (
    SELECT 
        COUNT(CASE WHEN IsActive = 1 THEN 1 END) AS ActiveUsers,
        COUNT(CASE WHEN IsActive = 0 THEN 1 END) AS InactiveUsers,
        COUNT(CASE WHEN IsActive = 1 AND (LastLoginDate IS NULL OR LastLoginDate < DATEADD(day, -90, GETDATE())) THEN 1 END) AS NoRecentLogin,
        COUNT(CASE WHEN YEAR(CreatedDate) = YEAR(GETDATE()) AND MONTH(CreatedDate) = MONTH(GETDATE()) THEN 1 END) AS NewUsersThisMonth
    FROM Users
),
CategoryDistributionCTE AS (
    SELECT 
        UserCategory,
        COUNT(*) AS UserCount
    FROM Users
    WHERE IsActive = 1
    GROUP BY UserCategory
)
SELECT 
    s.ActiveUsers,
    s.InactiveUsers,
    s.NoRecentLogin,
    s.NewUsersThisMonth,
    
    -- Category distribution (comma-separated)
    (SELECT 
        STUFF((SELECT ',' + UserCategory + ':' + CAST(UserCount AS varchar)
               FROM CategoryDistributionCTE
               FOR XML PATH('')), 1, 1, '')
    ) AS ActiveUsersByCategory
FROM UserStatsCTE s;
GO

PRINT '  + vw_UserKPIs created successfully';
GO

-- =============================================
-- VIEW 8: ADMIN - CHANGE LOG KPIs
-- =============================================
PRINT 'Creating vw_ChangeLogKPIs...';
GO

IF OBJECT_ID('dbo.vw_ChangeLogKPIs', 'V') IS NOT NULL
    DROP VIEW dbo.vw_ChangeLogKPIs;
GO

CREATE VIEW dbo.vw_ChangeLogKPIs
AS
WITH ChangesByTableCTE AS (
    SELECT 
        TableName,
        COUNT(*) AS ChangeCount
    FROM Change_Log
    WHERE ChangeDate >= DATEADD(day, -30, GETDATE())
    GROUP BY TableName
),
MostActiveUsersCTE AS (
    SELECT TOP 5
        ChangedBy,
        COUNT(*) AS ChangeCount
    FROM Change_Log
    WHERE ChangeDate >= DATEADD(day, -30, GETDATE())
    GROUP BY ChangedBy
    ORDER BY COUNT(*) DESC
),
ChangeTypeDistributionCTE AS (
    SELECT 
        ChangeType,
        COUNT(*) AS ChangeCount
    FROM Change_Log
    WHERE ChangeDate >= DATEADD(day, -30, GETDATE())
    GROUP BY ChangeType
),
BusiestTablesLast7DaysCTE AS (
    SELECT TOP 5
        TableName,
        COUNT(*) AS ChangeCount
    FROM Change_Log
    WHERE ChangeDate >= DATEADD(day, -7, GETDATE())
    GROUP BY TableName
    ORDER BY COUNT(*) DESC
)
SELECT 
    -- Total changes last 30 days
    (SELECT COUNT(*) FROM Change_Log WHERE ChangeDate >= DATEADD(day, -30, GETDATE())) AS TotalChangesLast30Days,
    
    -- Changes by table (comma-separated top 5)
    (SELECT 
        STUFF((SELECT TOP 5 ',' + TableName + ':' + CAST(ChangeCount AS varchar)
               FROM ChangesByTableCTE
               ORDER BY ChangeCount DESC
               FOR XML PATH('')), 1, 1, '')
    ) AS ChangesByTable,
    
    -- Most active users (comma-separated)
    (SELECT 
        STUFF((SELECT ',' + ChangedBy + ':' + CAST(ChangeCount AS varchar)
               FROM MostActiveUsersCTE
               FOR XML PATH('')), 1, 1, '')
    ) AS MostActiveUsers,
    
    -- Change type distribution (comma-separated)
    (SELECT 
        STUFF((SELECT ',' + ChangeType + ':' + CAST(ChangeCount AS varchar)
               FROM ChangeTypeDistributionCTE
               FOR XML PATH('')), 1, 1, '')
    ) AS ChangeTypeDistribution,
    
    -- Busiest tables last 7 days (comma-separated)
    (SELECT 
        STUFF((SELECT ',' + TableName + ':' + CAST(ChangeCount AS varchar)
               FROM BusiestTablesLast7DaysCTE
               FOR XML PATH('')), 1, 1, '')
    ) AS BusiestTablesLast7Days;
GO

PRINT '  + vw_ChangeLogKPIs created successfully';
GO

-- =============================================
-- VIEWS CREATION COMPLETE
-- =============================================
PRINT '';
PRINT '========================================';
PRINT 'All KPI Views Created Successfully!';
PRINT 'Date: ' + CONVERT(varchar, GETDATE(), 120);
PRINT '========================================';
PRINT '';
PRINT 'Views created:';
PRINT '  1. vw_CalibrationKPIs';
PRINT '  2. vw_ComputerKPIs';
PRINT '  3. vw_PMKPIs';
PRINT '  4. vw_TroubleshootingKPIs';
PRINT '  5. vw_TestStationKPIs';
PRINT '  6. vw_AccountRequestKPIs';
PRINT '  7. vw_UserKPIs';
PRINT '  8. vw_ChangeLogKPIs';
PRINT '';
PRINT 'Usage example:';
PRINT '  SELECT * FROM vw_CalibrationKPIs;';
PRINT '';
PRINT 'Next steps:';
PRINT '1. Test each view to verify data accuracy';
PRINT '2. Update application code to query views for dashboard KPIs';
PRINT '3. Create UI cards to display KPI values';
PRINT '4. Set up refresh schedules if needed (views are real-time)';
GO
