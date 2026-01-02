-- =============================================================================
-- SPD Label Verification Dashboard - SQL Views
-- =============================================================================
-- These views aggregate data from the Access DB test results and SQL validations
-- to provide comprehensive tracking and metrics for the SPD label verification process.
-- =============================================================================

-- View: SPDDashboard_PassedTestsByDay
-- Purpose: Aggregates all passed test records from Access DB by day
-- Note: This is a placeholder view structure. Actual implementation requires
--       linked server or OPENROWSET to query the Access database.
-- =============================================================================
IF OBJECT_ID('dbo.SPDDashboard_PassedTestsByDay', 'V') IS NOT NULL
    DROP VIEW dbo.SPDDashboard_PassedTestsByDay;
GO

-- Placeholder - Replace with actual linked server query
-- CREATE VIEW dbo.SPDDashboard_PassedTestsByDay
-- AS
-- SELECT 
--     CAST([CompletedOn] AS DATE) AS TestDate,
--     [SerialNumber],
--     [CatalogNumber],
--     [Workcell],
--     [Operator],
--     [Station],
--     ROW_NUMBER() OVER (PARTITION BY [SerialNumber], CAST([CompletedOn] AS DATE) ORDER BY [CompletedOn] DESC) AS RN
-- FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0', 
--     'C:\Path\To\Production.mdb', 
--     'SELECT * FROM TestResults WHERE Result = ''1'' AND Status = ''PASS''')
-- WHERE [CompletedOn] IS NOT NULL;
-- GO


-- =============================================================================
-- View: SPDDashboard_ValidationSummaryByPeriod
-- Purpose: Summarizes validations by time period with pass/fail counts
-- =============================================================================
IF OBJECT_ID('dbo.SPDDashboard_ValidationSummaryByPeriod', 'V') IS NOT NULL
    DROP VIEW dbo.SPDDashboard_ValidationSummaryByPeriod;
GO

CREATE VIEW dbo.SPDDashboard_ValidationSummaryByPeriod
AS
SELECT 
    CAST(ValidationTime AS DATE) AS ValidationDate,
    DATEPART(YEAR, ValidationTime) AS [Year],
    DATEPART(WEEK, ValidationTime) AS [Week],
    DATEPART(MONTH, ValidationTime) AS [Month],
    Workcell,
    COUNT(*) AS TotalValidations,
    SUM(CASE WHEN IsMatch = 1 THEN 1 ELSE 0 END) AS PassedValidations,
    SUM(CASE WHEN IsMatch = 0 THEN 1 ELSE 0 END) AS FailedValidations,
    COUNT(DISTINCT SerialNumber) AS UniqueSerials,
    COUNT(DISTINCT OperatorENumber) AS UniqueOperators
FROM dbo.SPDLabelValidations
WHERE ValidationTime IS NOT NULL
GROUP BY 
    CAST(ValidationTime AS DATE),
    DATEPART(YEAR, ValidationTime),
    DATEPART(WEEK, ValidationTime),
    DATEPART(MONTH, ValidationTime),
    Workcell;
GO


-- =============================================================================
-- View: SPDDashboard_SerialValidationStatus
-- Purpose: Shows each serial number's validation history and current status
-- =============================================================================
IF OBJECT_ID('dbo.SPDDashboard_SerialValidationStatus', 'V') IS NOT NULL
    DROP VIEW dbo.SPDDashboard_SerialValidationStatus;
GO

CREATE VIEW dbo.SPDDashboard_SerialValidationStatus
AS
SELECT 
    SerialNumber,
    CatalogNumber,
    Workcell,
    COUNT(*) AS ValidationCount,
    MAX(ValidationTime) AS LastValidationTime,
    MIN(ValidationTime) AS FirstValidationTime,
    SUM(CASE WHEN IsMatch = 1 THEN 1 ELSE 0 END) AS PassCount,
    SUM(CASE WHEN IsMatch = 0 THEN 1 ELSE 0 END) AS FailCount,
    MAX(CASE WHEN IsMatch = 1 THEN ValidationTime ELSE NULL END) AS LastPassTime,
    MAX(CASE WHEN IsMatch = 0 THEN ValidationTime ELSE NULL END) AS LastFailTime,
    -- Overall status: Pass if at least one pass and no fails after the last pass
    CASE 
        WHEN MAX(CASE WHEN IsMatch = 1 THEN ValidationTime ELSE NULL END) IS NOT NULL
             AND (MAX(CASE WHEN IsMatch = 0 THEN ValidationTime ELSE NULL END) IS NULL 
                  OR MAX(CASE WHEN IsMatch = 1 THEN ValidationTime ELSE NULL END) > MAX(CASE WHEN IsMatch = 0 THEN ValidationTime ELSE NULL END))
        THEN 'VALIDATED'
        WHEN MAX(CASE WHEN IsMatch = 0 THEN ValidationTime ELSE NULL END) IS NOT NULL
        THEN 'FAILED'
        ELSE 'PENDING'
    END AS CurrentStatus,
    -- Get the operators involved
    STUFF((
        SELECT DISTINCT ', ' + ISNULL(OperatorName, 'Unknown')
        FROM dbo.SPDLabelValidations AS V2
        WHERE V2.SerialNumber = V1.SerialNumber
        FOR XML PATH(''), TYPE
    ).value('.', 'NVARCHAR(MAX)'), 1, 2, '') AS Operators
FROM dbo.SPDLabelValidations AS V1
WHERE SerialNumber IS NOT NULL
GROUP BY SerialNumber, CatalogNumber, Workcell;
GO


-- =============================================================================
-- View: SPDDashboard_DetailedValidationHistory
-- Purpose: Detailed view of all validations with enhanced information
-- =============================================================================
IF OBJECT_ID('dbo.SPDDashboard_DetailedValidationHistory', 'V') IS NOT NULL
    DROP VIEW dbo.SPDDashboard_DetailedValidationHistory;
GO

CREATE VIEW dbo.SPDDashboard_DetailedValidationHistory
AS
SELECT 
    V.Id,
    V.ValidationTime,
    CAST(V.ValidationTime AS DATE) AS ValidationDate,
    DATEPART(HOUR, V.ValidationTime) AS ValidationHour,
    V.OperatorName,
    V.OperatorENumber,
    V.SerialNumber,
    V.CatalogNumber,
    V.MaterialScanned,
    V.MaterialExpected,
    V.IsMatch,
    V.Workcell,
    CASE V.IsMatch 
        WHEN 1 THEN 'PASS' 
        ELSE 'FAIL' 
    END AS ValidationResult,
    -- Calculate validation attempt number for this serial
    ROW_NUMBER() OVER (PARTITION BY V.SerialNumber ORDER BY V.ValidationTime) AS AttemptNumber,
    -- Is this the first validation for this serial?
    CASE 
        WHEN ROW_NUMBER() OVER (PARTITION BY V.SerialNumber ORDER BY V.ValidationTime) = 1 
        THEN 1 
        ELSE 0 
    END AS IsFirstAttempt,
    -- Is this the latest validation for this serial?
    CASE 
        WHEN V.ValidationTime = MAX(V.ValidationTime) OVER (PARTITION BY V.SerialNumber)
        THEN 1 
        ELSE 0 
    END AS IsLatestAttempt,
    -- Time since previous validation for this serial (in minutes)
    DATEDIFF(MINUTE, 
        LAG(V.ValidationTime) OVER (PARTITION BY V.SerialNumber ORDER BY V.ValidationTime),
        V.ValidationTime
    ) AS MinutesSincePrevious
FROM dbo.SPDLabelValidations AS V;
GO


-- =============================================================================
-- View: SPDDashboard_DailyMetrics
-- Purpose: Daily rollup metrics for dashboard KPIs
-- =============================================================================
IF OBJECT_ID('dbo.SPDDashboard_DailyMetrics', 'V') IS NOT NULL
    DROP VIEW dbo.SPDDashboard_DailyMetrics;
GO

CREATE VIEW dbo.SPDDashboard_DailyMetrics
AS
SELECT 
    ValidationDate,
    SUM(TotalValidations) AS TotalValidations,
    SUM(PassedValidations) AS TotalPassed,
    SUM(FailedValidations) AS TotalFailed,
    SUM(UniqueSerials) AS TotalUniqueSerials,
    SUM(UniqueOperators) AS TotalUniqueOperators,
    -- Pass rate percentage
    CASE 
        WHEN SUM(TotalValidations) > 0 
        THEN CAST(SUM(PassedValidations) AS FLOAT) / SUM(TotalValidations) * 100
        ELSE 0 
    END AS PassRatePercent,
    -- Average validations per serial
    CASE 
        WHEN SUM(UniqueSerials) > 0 
        THEN CAST(SUM(TotalValidations) AS FLOAT) / SUM(UniqueSerials)
        ELSE 0 
    END AS AvgValidationsPerSerial,
    -- Workcell breakdown
    MAX(CASE WHEN Workcell = 'Integrated' THEN TotalValidations ELSE 0 END) AS IntegratedCount,
    MAX(CASE WHEN Workcell = 'Sidemount' THEN TotalValidations ELSE 0 END) AS SidemountCount
FROM dbo.SPDDashboard_ValidationSummaryByPeriod
GROUP BY ValidationDate;
GO


-- =============================================================================
-- View: SPDDashboard_WeeklyMetrics
-- Purpose: Weekly rollup metrics for dashboard KPIs
-- =============================================================================
IF OBJECT_ID('dbo.SPDDashboard_WeeklyMetrics', 'V') IS NOT NULL
    DROP VIEW dbo.SPDDashboard_WeeklyMetrics;
GO

CREATE VIEW dbo.SPDDashboard_WeeklyMetrics
AS
SELECT 
    [Year],
    [Week],
    MIN(ValidationDate) AS WeekStart,
    MAX(ValidationDate) AS WeekEnd,
    SUM(TotalValidations) AS TotalValidations,
    SUM(PassedValidations) AS TotalPassed,
    SUM(FailedValidations) AS TotalFailed,
    SUM(UniqueSerials) AS TotalUniqueSerials,
    SUM(UniqueOperators) AS TotalUniqueOperators,
    CASE 
        WHEN SUM(TotalValidations) > 0 
        THEN CAST(SUM(PassedValidations) AS FLOAT) / SUM(TotalValidations) * 100
        ELSE 0 
    END AS PassRatePercent,
    CASE 
        WHEN SUM(UniqueSerials) > 0 
        THEN CAST(SUM(TotalValidations) AS FLOAT) / SUM(UniqueSerials)
        ELSE 0 
    END AS AvgValidationsPerSerial
FROM dbo.SPDDashboard_ValidationSummaryByPeriod
GROUP BY [Year], [Week];
GO


-- =============================================================================
-- View: SPDDashboard_MonthlyMetrics
-- Purpose: Monthly rollup metrics for dashboard KPIs
-- =============================================================================
IF OBJECT_ID('dbo.SPDDashboard_MonthlyMetrics', 'V') IS NOT NULL
    DROP VIEW dbo.SPDDashboard_MonthlyMetrics;
GO

CREATE VIEW dbo.SPDDashboard_MonthlyMetrics
AS
SELECT 
    [Year],
    [Month],
    MIN(ValidationDate) AS MonthStart,
    MAX(ValidationDate) AS MonthEnd,
    SUM(TotalValidations) AS TotalValidations,
    SUM(PassedValidations) AS TotalPassed,
    SUM(FailedValidations) AS TotalFailed,
    SUM(UniqueSerials) AS TotalUniqueSerials,
    SUM(UniqueOperators) AS TotalUniqueOperators,
    CASE 
        WHEN SUM(TotalValidations) > 0 
        THEN CAST(SUM(PassedValidations) AS FLOAT) / SUM(TotalValidations) * 100
        ELSE 0 
    END AS PassRatePercent,
    CASE 
        WHEN SUM(UniqueSerials) > 0 
        THEN CAST(SUM(TotalValidations) AS FLOAT) / SUM(UniqueSerials)
        ELSE 0 
    END AS AvgValidationsPerSerial
FROM dbo.SPDDashboard_ValidationSummaryByPeriod
GROUP BY [Year], [Month];
GO


-- =============================================================================
-- TESTING QUERIES
-- =============================================================================
-- Uncomment to test the views:
/*
SELECT * FROM dbo.SPDDashboard_ValidationSummaryByPeriod ORDER BY ValidationDate DESC;
SELECT * FROM dbo.SPDDashboard_SerialValidationStatus ORDER BY LastValidationTime DESC;
SELECT * FROM dbo.SPDDashboard_DetailedValidationHistory ORDER BY ValidationTime DESC;
SELECT * FROM dbo.SPDDashboard_DailyMetrics ORDER BY ValidationDate DESC;
SELECT * FROM dbo.SPDDashboard_WeeklyMetrics ORDER BY [Year] DESC, [Week] DESC;
SELECT * FROM dbo.SPDDashboard_MonthlyMetrics ORDER BY [Year] DESC, [Month] DESC;
*/
