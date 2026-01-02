/*******************************************************************************
 * FIX: ResolutionTimeHours Precision Issue
 * 
 * Problem: The ResolutionTimeHours computed column was using DATEDIFF(hour)
 *          which only returns whole hours (40 minutes = 0 hours)
 * 
 * Solution: Recreate the column using DATEDIFF(MINUTE) / 60.0 to get 
 *          decimal hours (40 minutes = 0.67 hours)
 * 
 * Impact: This will recalculate all historical resolution times with proper
 *         decimal precision
 * 
 * Date: 2025-10-30
 *******************************************************************************/

USE [TestEngineering]
GO

PRINT '========================================';
PRINT 'Fixing ResolutionTimeHours Precision';
PRINT '========================================';
PRINT '';

-- Step 1: Drop the existing computed column
IF COL_LENGTH('dbo.Troubleshooting_Log','ResolutionTimeHours') IS NOT NULL
BEGIN
    PRINT 'Dropping old ResolutionTimeHours column...';
    ALTER TABLE dbo.Troubleshooting_Log DROP COLUMN ResolutionTimeHours;
    PRINT '  ✓ Dropped successfully';
END
ELSE
BEGIN
    PRINT '  ! Column does not exist - nothing to drop';
END

PRINT '';

-- Step 2: Recreate with proper decimal precision
PRINT 'Creating new ResolutionTimeHours column with decimal precision...';
ALTER TABLE dbo.Troubleshooting_Log ADD ResolutionTimeHours AS (
    CAST(DATEDIFF(MINUTE, [ReportedDateTime], [ResolvedDateTime]) AS DECIMAL(10,2)) / 60.0
) PERSISTED;
PRINT '  ✓ Created successfully';

PRINT '';

-- Step 3: Verify the fix with sample data
PRINT 'Verifying fix with sample data:';
PRINT '--------------------------------';

SELECT TOP 5
    ID,
    ReportedDateTime,
    ResolvedDateTime,
    ResolutionTimeHours,
    CASE 
        WHEN ResolutionTimeHours < 1 THEN 
            CAST(CAST(ResolutionTimeHours * 60 AS INT) AS VARCHAR(10)) + ' minutes'
        ELSE 
            CAST(CAST(FLOOR(ResolutionTimeHours) AS INT) AS VARCHAR(10)) + 'h ' + 
            CAST(CAST(ROUND((ResolutionTimeHours - FLOOR(ResolutionTimeHours)) * 60, 0) AS INT) AS VARCHAR(10)) + 'm'
    END AS FormattedTime
FROM dbo.Troubleshooting_Log
WHERE Status IN ('Resolved', 'Closed')
    AND ResolvedDateTime IS NOT NULL
    AND ReportedDateTime IS NOT NULL
ORDER BY ResolvedDateTime DESC;

PRINT '';
PRINT '========================================';
PRINT 'Fix Complete!';
PRINT '========================================';
PRINT '';
PRINT 'Next Steps:';
PRINT '1. Refresh the dashboard to see updated values';
PRINT '2. Average resolution time should now show correct decimals';
PRINT '3. Line chart tooltips will display minutes correctly';
PRINT '';

GO
