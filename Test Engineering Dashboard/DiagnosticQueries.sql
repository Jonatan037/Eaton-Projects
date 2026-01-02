-- SPD Dashboard Data Discrepancy Diagnostic Queries
-- Run these queries to understand the differences between KPIs and Timeline counts

-- =====================================================
-- 1. Check for duplicate serial numbers in test data
-- =====================================================
-- Run this in your Access Database (Production.mdb)
/*
SELECT SerialNumber, Workcell, COUNT(*) as TestCount
FROM TestResults
WHERE CAST(StartTime AS DATE) = DATE()
  AND Result = 'PASS'
  AND Workcell IN ('Integrated', 'Sidemount')
GROUP BY SerialNumber, Workcell
HAVING COUNT(*) > 1
ORDER BY TestCount DESC;
*/

-- =====================================================
-- 2. Check validation attempts per serial (SQL Server)
-- =====================================================
SELECT 
    SerialNumber,
    Workcell,
    COUNT(*) as TotalAttempts,
    SUM(CASE WHEN IsMatch = 1 THEN 1 ELSE 0 END) as PassedAttempts,
    SUM(CASE WHEN IsMatch = 0 THEN 1 ELSE 0 END) as FailedAttempts,
    MAX(CASE WHEN IsMatch = 1 THEN 1 ELSE 0 END) as HasAnyPass
FROM dbo.SPDLabelValidations
WHERE CAST(ValidationTime AS DATE) = CAST(GETDATE() AS DATE)
GROUP BY SerialNumber, Workcell
ORDER BY TotalAttempts DESC;

-- =====================================================
-- 3. Units with multiple validation attempts
-- =====================================================
SELECT 
    SerialNumber,
    Workcell,
    COUNT(*) as AttemptCount,
    STRING_AGG(CAST(IsMatch AS VARCHAR), ',') as Results
FROM dbo.SPDLabelValidations
WHERE CAST(ValidationTime AS DATE) = CAST(GETDATE() AS DATE)
GROUP BY SerialNumber, Workcell
HAVING COUNT(*) > 1
ORDER BY AttemptCount DESC;

-- =====================================================
-- 4. Compare distinct serials vs total validations
-- =====================================================
SELECT 
    'Total Validation Records' as Metric,
    COUNT(*) as Count
FROM dbo.SPDLabelValidations
WHERE CAST(ValidationTime AS DATE) = CAST(GETDATE() AS DATE)

UNION ALL

SELECT 
    'Distinct Serial Numbers',
    COUNT(DISTINCT SerialNumber)
FROM dbo.SPDLabelValidations
WHERE CAST(ValidationTime AS DATE) = CAST(GETDATE() AS DATE)

UNION ALL

SELECT 
    'Distinct Serials - Passed',
    COUNT(DISTINCT SerialNumber)
FROM dbo.SPDLabelValidations
WHERE CAST(ValidationTime AS DATE) = CAST(GETDATE() AS DATE)
  AND IsMatch = 1

UNION ALL

SELECT 
    'Distinct Serials - Has Any Failure',
    COUNT(DISTINCT SerialNumber)
FROM dbo.SPDLabelValidations
WHERE CAST(ValidationTime AS DATE) = CAST(GETDATE() AS DATE)
  AND SerialNumber IN (
    SELECT SerialNumber
    FROM dbo.SPDLabelValidations
    WHERE CAST(ValidationTime AS DATE) = CAST(GETDATE() AS DATE)
      AND IsMatch = 0
  )

UNION ALL

SELECT 
    'Total Passed Attempts',
    COUNT(*)
FROM dbo.SPDLabelValidations
WHERE CAST(ValidationTime AS DATE) = CAST(GETDATE() AS DATE)
  AND IsMatch = 1

UNION ALL

SELECT 
    'Total Failed Attempts',
    COUNT(*)
FROM dbo.SPDLabelValidations
WHERE CAST(ValidationTime AS DATE) = CAST(GETDATE() AS DATE)
  AND IsMatch = 0;

-- =====================================================
-- 5. Units tested but not validated (requires both DBs)
-- =====================================================
-- This shows serials in test data but not in validation data
-- You'll need to export test data and compare

-- =====================================================
-- 6. Check for null/empty workcells
-- =====================================================
SELECT 
    CASE 
        WHEN Workcell IS NULL THEN 'NULL'
        WHEN Workcell = '' THEN 'EMPTY'
        ELSE Workcell
    END as WorkcellValue,
    COUNT(*) as Count
FROM dbo.SPDLabelValidations
WHERE CAST(ValidationTime AS DATE) = CAST(GETDATE() AS DATE)
GROUP BY Workcell
ORDER BY Count DESC;
