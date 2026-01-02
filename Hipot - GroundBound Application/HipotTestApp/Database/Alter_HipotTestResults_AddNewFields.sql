-- =============================================
-- Alter HipotTestResults Table - Add New Fields
-- Database: Phoenix
-- Created: December 2024
-- Description: Adds Cabinet Serial Number, Breaker Panel Serial Number,
--              and GSEC Panel Serial Number fields
--              Also renames SerialNumber to CabinetSerialNumber conceptually
--              (we keep the column name for backward compatibility but add new fields)
-- =============================================

USE [Phoenix]
GO

-- Add BreakerPanelSerialNumber column if it doesn't exist
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.HipotTestResults') AND name = 'BreakerPanelSerialNumber')
BEGIN
    ALTER TABLE [dbo].[HipotTestResults]
    ADD [BreakerPanelSerialNumber] NVARCHAR(50) NULL;
    
    PRINT 'Column BreakerPanelSerialNumber added successfully.'
END
ELSE
BEGIN
    PRINT 'Column BreakerPanelSerialNumber already exists.'
END
GO

-- Add GSECPanelSerialNumber column if it doesn't exist
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.HipotTestResults') AND name = 'GSECPanelSerialNumber')
BEGIN
    ALTER TABLE [dbo].[HipotTestResults]
    ADD [GSECPanelSerialNumber] NVARCHAR(50) NULL;
    
    PRINT 'Column GSECPanelSerialNumber added successfully.'
END
ELSE
BEGIN
    PRINT 'Column GSECPanelSerialNumber already exists.'
END
GO

-- Rename PartNumber to CabinetPartNumber (optional - keeping for clarity)
-- Note: We keep the old column name for backward compatibility
-- The application will use PartNumber as CabinetPartNumber
-- SerialNumber will be used as CabinetSerialNumber

-- Add comments to clarify field usage
EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Cabinet Part Number (formerly just PartNumber)', 
    @level0type = N'SCHEMA', @level0name = N'dbo', 
    @level1type = N'TABLE', @level1name = N'HipotTestResults', 
    @level2type = N'COLUMN', @level2name = N'PartNumber';
GO

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Cabinet Serial Number (primary unit identifier)', 
    @level0type = N'SCHEMA', @level0name = N'dbo', 
    @level1type = N'TABLE', @level1name = N'HipotTestResults', 
    @level2type = N'COLUMN', @level2name = N'SerialNumber';
GO

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Breaker Panel Serial Number', 
    @level0type = N'SCHEMA', @level0name = N'dbo', 
    @level1type = N'TABLE', @level1name = N'HipotTestResults', 
    @level2type = N'COLUMN', @level2name = N'BreakerPanelSerialNumber';
GO

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'GSEC Panel Serial Number', 
    @level0type = N'SCHEMA', @level0name = N'dbo', 
    @level1type = N'TABLE', @level1name = N'HipotTestResults', 
    @level2type = N'COLUMN', @level2name = N'GSECPanelSerialNumber';
GO

-- Create index on new serial number fields for faster lookups
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_HipotTestResults_BreakerPanelSerialNumber')
BEGIN
    CREATE NONCLUSTERED INDEX [IX_HipotTestResults_BreakerPanelSerialNumber]
    ON [dbo].[HipotTestResults] ([BreakerPanelSerialNumber])
    WHERE [BreakerPanelSerialNumber] IS NOT NULL;
    
    PRINT 'Index IX_HipotTestResults_BreakerPanelSerialNumber created.'
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_HipotTestResults_GSECPanelSerialNumber')
BEGIN
    CREATE NONCLUSTERED INDEX [IX_HipotTestResults_GSECPanelSerialNumber]
    ON [dbo].[HipotTestResults] ([GSECPanelSerialNumber])
    WHERE [GSECPanelSerialNumber] IS NOT NULL;
    
    PRINT 'Index IX_HipotTestResults_GSECPanelSerialNumber created.'
END
GO

PRINT 'Schema update completed successfully.'
PRINT ''
PRINT 'Field Mapping:'
PRINT '  - PartNumber       = Cabinet Part Number'
PRINT '  - SerialNumber     = Cabinet Serial Number'  
PRINT '  - BreakerPanelSerialNumber = Breaker Panel Serial Number (NEW)'
PRINT '  - GSECPanelSerialNumber    = GSEC Panel Serial Number (NEW)'
PRINT '  - WorkOrder        = No longer used (kept for backward compatibility)'
GO
