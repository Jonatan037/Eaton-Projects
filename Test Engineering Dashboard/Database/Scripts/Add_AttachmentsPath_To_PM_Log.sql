-- =============================================
-- Add AttachmentsPath Column to PM_Log Table
-- Description: Adds a column to store file attachment paths (comma-separated)
-- Date: October 2025
-- =============================================

USE [TestEngineering]
GO

-- Check if column already exists before adding
IF NOT EXISTS (
    SELECT * FROM sys.columns 
    WHERE object_id = OBJECT_ID(N'dbo.PM_Log') 
    AND name = 'AttachmentsPath'
)
BEGIN
    ALTER TABLE dbo.PM_Log
    ADD AttachmentsPath NVARCHAR(MAX) NULL;
    
    PRINT 'AttachmentsPath column added successfully to PM_Log table.';
END
ELSE
BEGIN
    PRINT 'AttachmentsPath column already exists in PM_Log table.';
END
GO
