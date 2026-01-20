-- =============================================
-- Add MRPControllerCode column to ZMMR_ScrapData table
-- Run this script on TestEngineering database
-- =============================================

USE TestEngineering;
GO

-- Step 1: Add the new column
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('ZMMR_ScrapData') AND name = 'MRPControllerCode')
BEGIN
    ALTER TABLE ZMMR_ScrapData ADD MRPControllerCode VARCHAR(20) NULL;
    PRINT 'Column MRPControllerCode added successfully.';
END
ELSE
BEGIN
    PRINT 'Column MRPControllerCode already exists.';
END
GO

-- Step 2: Create index on the new column (useful for filtering by controller)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID('ZMMR_ScrapData') AND name = 'IX_ZMMR_MRPControllerCode')
BEGIN
    CREATE INDEX IX_ZMMR_MRPControllerCode ON ZMMR_ScrapData (MRPControllerCode);
    PRINT 'Index IX_ZMMR_MRPControllerCode created.';
END
GO

-- Step 3: Clear existing data (since new file has complete data with new column)
-- This also clears the import log
TRUNCATE TABLE ZMMR_ScrapData;
DELETE FROM ZMMR_ImportLog;
PRINT 'Existing data cleared. Ready for fresh import with new column structure.';
GO

-- Verify the table structure
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'ZMMR_ScrapData'
ORDER BY ORDINAL_POSITION;
GO
