-- =============================================
-- Add Additional Columns to PM_Log Table
-- Description: Adds ScheduledDate, ActualStartTime, ActualEndTime, and Downtime columns
-- Date: October 2025
-- =============================================

USE [TestEngineering]
GO

-- Add ScheduledDate
IF NOT EXISTS (
    SELECT * FROM sys.columns 
    WHERE object_id = OBJECT_ID(N'dbo.PM_Log') 
    AND name = 'ScheduledDate'
)
BEGIN
    ALTER TABLE dbo.PM_Log
    ADD ScheduledDate DATETIME NULL;
    
    PRINT 'ScheduledDate column added successfully to PM_Log table.';
END
ELSE
BEGIN
    PRINT 'ScheduledDate column already exists in PM_Log table.';
END
GO

-- Add ActualStartTime
IF NOT EXISTS (
    SELECT * FROM sys.columns 
    WHERE object_id = OBJECT_ID(N'dbo.PM_Log') 
    AND name = 'ActualStartTime'
)
BEGIN
    ALTER TABLE dbo.PM_Log
    ADD ActualStartTime DATETIME NULL;
    
    PRINT 'ActualStartTime column added successfully to PM_Log table.';
END
ELSE
BEGIN
    PRINT 'ActualStartTime column already exists in PM_Log table.';
END
GO

-- Add ActualEndTime
IF NOT EXISTS (
    SELECT * FROM sys.columns 
    WHERE object_id = OBJECT_ID(N'dbo.PM_Log') 
    AND name = 'ActualEndTime'
)
BEGIN
    ALTER TABLE dbo.PM_Log
    ADD ActualEndTime DATETIME NULL;
    
    PRINT 'ActualEndTime column added successfully to PM_Log table.';
END
ELSE
BEGIN
    PRINT 'ActualEndTime column already exists in PM_Log table.';
END
GO

-- Add Downtime (in hours)
IF NOT EXISTS (
    SELECT * FROM sys.columns 
    WHERE object_id = OBJECT_ID(N'dbo.PM_Log') 
    AND name = 'Downtime'
)
BEGIN
    ALTER TABLE dbo.PM_Log
    ADD Downtime DECIMAL(10,2) NULL;
    
    PRINT 'Downtime column added successfully to PM_Log table.';
END
ELSE
BEGIN
    PRINT 'Downtime column already exists in PM_Log table.';
END
GO

PRINT 'All additional columns added successfully to PM_Log table.';
GO
