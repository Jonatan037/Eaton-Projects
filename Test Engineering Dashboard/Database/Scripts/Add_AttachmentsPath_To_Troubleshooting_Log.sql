-- =============================================
-- Script: Add AttachmentsPath Column to Troubleshooting_Log
-- Description: Adds a column to store comma-separated file paths for attachments
-- Date: October 9, 2025
-- =============================================

USE [TestEngineering_Database]
GO

-- Add AttachmentsPath column to Troubleshooting_Log table
IF NOT EXISTS (
    SELECT 1 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'Troubleshooting_Log' 
    AND COLUMN_NAME = 'AttachmentsPath'
)
BEGIN
    ALTER TABLE dbo.Troubleshooting_Log
    ADD AttachmentsPath NVARCHAR(MAX) NULL;
    
    PRINT 'AttachmentsPath column added successfully to Troubleshooting_Log table.';
END
ELSE
BEGIN
    PRINT 'AttachmentsPath column already exists in Troubleshooting_Log table.';
END
GO
