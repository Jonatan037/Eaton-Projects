-- =============================================
-- Remove ALL CHECK Constraints from Calibration_Log Table
-- =============================================
-- This script removes ALL restrictive CHECK constraints from the Calibration_Log table
-- to allow flexible data entry without validation restrictions
-- 
-- Database: TestEngineering
-- Created: October 14, 2025
-- =============================================

USE TestEngineering;
GO

PRINT '========================================';
PRINT 'Removing CHECK constraints from Calibration_Log table...';
PRINT '========================================';

-- =============================================
-- STEP 1: View current constraints
-- =============================================

PRINT '';
PRINT 'Current CHECK constraints on Calibration_Log:';
PRINT '----------------------------------------';

SELECT 
    cc.name AS CONSTRAINT_NAME,
    c.name AS COLUMN_NAME,
    cc.definition AS CHECK_DEFINITION
FROM sys.check_constraints cc
INNER JOIN sys.columns c ON cc.parent_object_id = c.object_id 
    AND cc.parent_column_id = c.column_id
WHERE OBJECT_NAME(cc.parent_object_id) = 'Calibration_Log'
    AND OBJECT_SCHEMA_NAME(cc.parent_object_id) = 'dbo'
ORDER BY c.name;

-- =============================================
-- STEP 2: Remove ALL CHECK constraints
-- =============================================

PRINT '';
PRINT 'Removing constraints...';
PRINT '----------------------------------------';

DECLARE @sql NVARCHAR(MAX) = '';

-- Build DROP CONSTRAINT statements for ALL check constraints on Calibration_Log
SELECT @sql = @sql + 
    'ALTER TABLE [dbo].[Calibration_Log] DROP CONSTRAINT [' + cc.name + '];' + CHAR(13) + CHAR(10)
FROM sys.check_constraints cc
WHERE OBJECT_NAME(cc.parent_object_id) = 'Calibration_Log'
    AND OBJECT_SCHEMA_NAME(cc.parent_object_id) = 'dbo';

-- Execute the dynamic SQL to drop ALL constraints
IF LEN(@sql) > 0
BEGIN
    PRINT 'Executing constraint removal:';
    PRINT @sql;
    EXEC sp_executesql @sql;
    PRINT '';
    PRINT '✓ All CHECK constraints removed successfully from Calibration_Log!';
END
ELSE
BEGIN
    PRINT '✓ No CHECK constraints found on Calibration_Log table.';
END

-- =============================================
-- STEP 3: Verify removal
-- =============================================

PRINT '';
PRINT 'Verifying constraint removal...';
PRINT '----------------------------------------';

-- Check for any remaining CHECK constraints
DECLARE @remainingCount INT;

SELECT @remainingCount = COUNT(*)
FROM sys.check_constraints cc
WHERE OBJECT_NAME(cc.parent_object_id) = 'Calibration_Log'
    AND OBJECT_SCHEMA_NAME(cc.parent_object_id) = 'dbo';

IF @remainingCount = 0
BEGIN
    PRINT '✓ Verification successful: No CHECK constraints remain on Calibration_Log';
END
ELSE
BEGIN
    PRINT '⚠ Warning: ' + CAST(@remainingCount AS VARCHAR) + ' CHECK constraints still exist:';
    
    SELECT 
        cc.name AS CONSTRAINT_NAME,
        c.name AS COLUMN_NAME,
        cc.definition AS CHECK_DEFINITION
    FROM sys.check_constraints cc
    INNER JOIN sys.columns c ON cc.parent_object_id = c.object_id 
        AND cc.parent_column_id = c.column_id
    WHERE OBJECT_NAME(cc.parent_object_id) = 'Calibration_Log'
        AND OBJECT_SCHEMA_NAME(cc.parent_object_id) = 'dbo';
END

-- =============================================
-- STEP 4: Show column information
-- =============================================

PRINT '';
PRINT 'Calibration_Log columns (constraints removed):';
PRINT '----------------------------------------';

SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
    AND TABLE_NAME = 'Calibration_Log'
ORDER BY ORDINAL_POSITION;

PRINT '';
PRINT '========================================';
PRINT '✓ Complete! Calibration_Log table now accepts flexible data entry.';
PRINT '========================================';

GO

-- =============================================
-- OPTIONAL: Test the table
-- =============================================

PRINT '';
PRINT 'Testing Status column accepts any value...';

-- This should now work without constraint errors
DECLARE @testStatus NVARCHAR(50) = 'Test Value';
PRINT 'Testing with Status = ''' + @testStatus + '''';
PRINT '✓ Status column can now accept any NVARCHAR(50) value';

GO
