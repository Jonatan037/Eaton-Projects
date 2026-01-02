-- Add TestLine column to Users table
-- This script adds a TestLine column to store comma-separated ProductionLineIDs

USE [TestEngineering]
GO

-- Check if TestLine column already exists
IF NOT EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = 'dbo' 
    AND TABLE_NAME = 'Users' 
    AND COLUMN_NAME = 'TestLine'
)
BEGIN
    -- Add TestLine column
    ALTER TABLE dbo.Users
    ADD TestLine NVARCHAR(500) NULL
    
    PRINT 'TestLine column added to Users table successfully'
END
ELSE
BEGIN
    PRINT 'TestLine column already exists in Users table'
END
GO

-- Optional: Update existing users with some default test lines if needed
-- Uncomment and modify the following lines if you want to set default values:

/*
-- Example: Set all active Test Engineering users to have access to Battery Line (assuming ProductionLineID = 1)
UPDATE dbo.Users 
SET TestLine = '1' 
WHERE IsActive = 1 
AND Department = 'Test Engineering' 
AND (TestLine IS NULL OR TestLine = '')
*/

PRINT 'TestLine column setup completed'
GO