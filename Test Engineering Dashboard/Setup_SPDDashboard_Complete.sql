-- ============================================================================= 
-- SPD Label Verification Dashboard - Quick Setup Script
-- =============================================================================
-- This script sets up all necessary database objects for the dashboard.
-- Run this after the SPDLabelValidations table has been created.
-- =============================================================================

USE [YourDatabaseName]; -- Replace with your actual database name
GO

-- =============================================================================
-- STEP 1: Verify the base table exists
-- =============================================================================
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES 
               WHERE TABLE_SCHEMA = 'dbo' 
               AND TABLE_NAME = 'SPDLabelValidations')
BEGIN
    RAISERROR('ERROR: SPDLabelValidations table does not exist. Please create it first using Create_SPDLabelValidations_Table.sql', 16, 1);
    RETURN;
END
GO

PRINT 'SPDLabelValidations table found. Proceeding with view creation...';
GO

-- =============================================================================
-- STEP 2: Drop existing views (if any) to avoid conflicts
-- =============================================================================
IF OBJECT_ID('dbo.SPDDashboard_MonthlyMetrics', 'V') IS NOT NULL
    DROP VIEW dbo.SPDDashboard_MonthlyMetrics;
GO

IF OBJECT_ID('dbo.SPDDashboard_WeeklyMetrics', 'V') IS NOT NULL
    DROP VIEW dbo.SPDDashboard_WeeklyMetrics;
GO

IF OBJECT_ID('dbo.SPDDashboard_DailyMetrics', 'V') IS NOT NULL
    DROP VIEW dbo.SPDDashboard_DailyMetrics;
GO

IF OBJECT_ID('dbo.SPDDashboard_DetailedValidationHistory', 'V') IS NOT NULL
    DROP VIEW dbo.SPDDashboard_DetailedValidationHistory;
GO

IF OBJECT_ID('dbo.SPDDashboard_SerialValidationStatus', 'V') IS NOT NULL
    DROP VIEW dbo.SPDDashboard_SerialValidationStatus;
GO

IF OBJECT_ID('dbo.SPDDashboard_ValidationSummaryByPeriod', 'V') IS NOT NULL
    DROP VIEW dbo.SPDDashboard_ValidationSummaryByPeriod;
GO

PRINT 'Old views dropped (if they existed).';
GO

-- =============================================================================
-- STEP 3: Create all views
-- =============================================================================

-- View 1: Validation Summary By Period
PRINT 'Creating SPDDashboard_ValidationSummaryByPeriod...';
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

PRINT 'SPDDashboard_ValidationSummaryByPeriod created successfully.';
GO

-- View 2: Serial Validation Status
PRINT 'Creating SPDDashboard_SerialValidationStatus...';
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
    CASE 
        WHEN MAX(CASE WHEN IsMatch = 1 THEN ValidationTime ELSE NULL END) IS NOT NULL
             AND (MAX(CASE WHEN IsMatch = 0 THEN ValidationTime ELSE NULL END) IS NULL 
                  OR MAX(CASE WHEN IsMatch = 1 THEN ValidationTime ELSE NULL END) > MAX(CASE WHEN IsMatch = 0 THEN ValidationTime ELSE NULL END))
        THEN 'VALIDATED'
        WHEN MAX(CASE WHEN IsMatch = 0 THEN ValidationTime ELSE NULL END) IS NOT NULL
        THEN 'FAILED'
        ELSE 'PENDING'
    END AS CurrentStatus,
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

PRINT 'SPDDashboard_SerialValidationStatus created successfully.';
GO

-- View 3: Detailed Validation History
PRINT 'Creating SPDDashboard_DetailedValidationHistory...';
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
    ROW_NUMBER() OVER (PARTITION BY V.SerialNumber ORDER BY V.ValidationTime) AS AttemptNumber,
    CASE 
        WHEN ROW_NUMBER() OVER (PARTITION BY V.SerialNumber ORDER BY V.ValidationTime) = 1 
        THEN 1 
        ELSE 0 
    END AS IsFirstAttempt,
    CASE 
        WHEN V.ValidationTime = MAX(V.ValidationTime) OVER (PARTITION BY V.SerialNumber)
        THEN 1 
        ELSE 0 
    END AS IsLatestAttempt,
    DATEDIFF(MINUTE, 
        LAG(V.ValidationTime) OVER (PARTITION BY V.SerialNumber ORDER BY V.ValidationTime),
        V.ValidationTime
    ) AS MinutesSincePrevious
FROM dbo.SPDLabelValidations AS V;
GO

PRINT 'SPDDashboard_DetailedValidationHistory created successfully.';
GO

-- View 4: Daily Metrics
PRINT 'Creating SPDDashboard_DailyMetrics...';
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
    CASE 
        WHEN SUM(TotalValidations) > 0 
        THEN CAST(SUM(PassedValidations) AS FLOAT) / SUM(TotalValidations) * 100
        ELSE 0 
    END AS PassRatePercent,
    CASE 
        WHEN SUM(UniqueSerials) > 0 
        THEN CAST(SUM(TotalValidations) AS FLOAT) / SUM(UniqueSerials)
        ELSE 0 
    END AS AvgValidationsPerSerial,
    MAX(CASE WHEN Workcell = 'Integrated' THEN TotalValidations ELSE 0 END) AS IntegratedCount,
    MAX(CASE WHEN Workcell = 'Sidemount' THEN TotalValidations ELSE 0 END) AS SidemountCount
FROM dbo.SPDDashboard_ValidationSummaryByPeriod
GROUP BY ValidationDate;
GO

PRINT 'SPDDashboard_DailyMetrics created successfully.';
GO

-- View 5: Weekly Metrics
PRINT 'Creating SPDDashboard_WeeklyMetrics...';
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

PRINT 'SPDDashboard_WeeklyMetrics created successfully.';
GO

-- View 6: Monthly Metrics
PRINT 'Creating SPDDashboard_MonthlyMetrics...';
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

PRINT 'SPDDashboard_MonthlyMetrics created successfully.';
GO

-- =============================================================================
-- STEP 4: Add additional indexes for better performance
-- =============================================================================
PRINT 'Adding performance indexes...';
GO

-- Check if indexes already exist before creating
IF NOT EXISTS (SELECT * FROM sys.indexes 
               WHERE name = 'IX_SPDLabelValidations_ValidationTime_Workcell' 
               AND object_id = OBJECT_ID('dbo.SPDLabelValidations'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_SPDLabelValidations_ValidationTime_Workcell
    ON dbo.SPDLabelValidations(ValidationTime, Workcell)
    INCLUDE (SerialNumber, IsMatch, OperatorENumber);
    
    PRINT 'Index IX_SPDLabelValidations_ValidationTime_Workcell created.';
END
ELSE
BEGIN
    PRINT 'Index IX_SPDLabelValidations_ValidationTime_Workcell already exists.';
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes 
               WHERE name = 'IX_SPDLabelValidations_Serial_Time' 
               AND object_id = OBJECT_ID('dbo.SPDLabelValidations'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_SPDLabelValidations_Serial_Time
    ON dbo.SPDLabelValidations(SerialNumber, ValidationTime DESC)
    INCLUDE (IsMatch, CatalogNumber, Workcell);
    
    PRINT 'Index IX_SPDLabelValidations_Serial_Time created.';
END
ELSE
BEGIN
    PRINT 'Index IX_SPDLabelValidations_Serial_Time already exists.';
END
GO

-- =============================================================================
-- STEP 5: Verification
-- =============================================================================
PRINT '';
PRINT '=============================================================================';
PRINT 'VERIFICATION: Checking all views were created successfully...';
PRINT '=============================================================================';

DECLARE @ViewCount INT;
SELECT @ViewCount = COUNT(*) 
FROM INFORMATION_SCHEMA.VIEWS 
WHERE TABLE_NAME LIKE 'SPDDashboard%';

PRINT 'Total SPD Dashboard views found: ' + CAST(@ViewCount AS VARCHAR(10));

IF @ViewCount = 6
BEGIN
    PRINT '';
    PRINT '✓ SUCCESS! All 6 dashboard views were created successfully.';
    PRINT '';
    PRINT 'Created views:';
    PRINT '  1. SPDDashboard_ValidationSummaryByPeriod';
    PRINT '  2. SPDDashboard_SerialValidationStatus';
    PRINT '  3. SPDDashboard_DetailedValidationHistory';
    PRINT '  4. SPDDashboard_DailyMetrics';
    PRINT '  5. SPDDashboard_WeeklyMetrics';
    PRINT '  6. SPDDashboard_MonthlyMetrics';
    PRINT '';
    PRINT 'You can now deploy the dashboard application files.';
END
ELSE
BEGIN
    PRINT '';
    PRINT '⚠ WARNING: Expected 6 views but found ' + CAST(@ViewCount AS VARCHAR(10));
    PRINT 'Please review the error messages above.';
END

PRINT '=============================================================================';
GO

-- =============================================================================
-- STEP 6: Sample test queries (optional - uncomment to run)
-- =============================================================================
/*
PRINT '';
PRINT 'Running sample queries to verify views work correctly...';
PRINT '';

-- Test daily metrics
PRINT 'Testing SPDDashboard_DailyMetrics:';
SELECT TOP 5 * FROM dbo.SPDDashboard_DailyMetrics ORDER BY ValidationDate DESC;

-- Test serial tracking
PRINT '';
PRINT 'Testing SPDDashboard_SerialValidationStatus:';
SELECT TOP 5 * FROM dbo.SPDDashboard_SerialValidationStatus ORDER BY LastValidationTime DESC;

-- Test validation summary
PRINT '';
PRINT 'Testing SPDDashboard_ValidationSummaryByPeriod:';
SELECT TOP 5 * FROM dbo.SPDDashboard_ValidationSummaryByPeriod ORDER BY ValidationDate DESC;

PRINT '';
PRINT 'Test queries completed successfully!';
*/
