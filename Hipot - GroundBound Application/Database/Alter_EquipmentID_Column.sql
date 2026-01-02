-- =============================================
-- Alter EquipmentID column to allow longer values
-- Run this on Phoenix database to fix truncation error
-- =============================================

USE [Phoenix]
GO

-- Alter HipotTestResults table
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'HipotTestResults')
BEGIN
    IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('HipotTestResults') AND name = 'EquipmentID')
    BEGIN
        ALTER TABLE [dbo].[HipotTestResults]
        ALTER COLUMN [EquipmentID] NVARCHAR(200) NULL
        
        PRINT 'HipotTestResults.EquipmentID column altered to NVARCHAR(200)'
    END
END
GO

-- Alter SafetyCheckResults table
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'SafetyCheckResults')
BEGIN
    IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('SafetyCheckResults') AND name = 'EquipmentID')
    BEGIN
        ALTER TABLE [dbo].[SafetyCheckResults]
        ALTER COLUMN [EquipmentID] NVARCHAR(200) NULL
        
        PRINT 'SafetyCheckResults.EquipmentID column altered to NVARCHAR(200)'
    END
END
GO

PRINT 'Column alterations complete.'
