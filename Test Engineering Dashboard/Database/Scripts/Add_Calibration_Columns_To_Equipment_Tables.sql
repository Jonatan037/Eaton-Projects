-- =============================================
-- Add Calibration Columns to Equipment Tables
-- =============================================
-- This script adds calibration-related columns to all equipment inventory tables
-- Run this BEFORE creating vw_Equipment_RequireCalibration view
-- =============================================

USE [TestEngineering]
GO

PRINT 'Adding calibration columns to equipment inventory tables...';
GO

-- =============================================
-- ATE_Inventory Table
-- =============================================

PRINT 'Processing ATE_Inventory table...';

-- RequiredCalibration
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = 'ATE_Inventory' 
               AND COLUMN_NAME = 'RequiredCalibration')
BEGIN
    ALTER TABLE dbo.ATE_Inventory
    ADD RequiredCalibration BIT NULL DEFAULT 0;
    PRINT '  - Added RequiredCalibration column to ATE_Inventory';
END
ELSE
    PRINT '  - RequiredCalibration column already exists in ATE_Inventory';

-- CalibrationFrequency
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = 'ATE_Inventory' 
               AND COLUMN_NAME = 'CalibrationFrequency')
BEGIN
    ALTER TABLE dbo.ATE_Inventory
    ADD CalibrationFrequency NVARCHAR(50) NULL;
    PRINT '  - Added CalibrationFrequency column to ATE_Inventory';
END
ELSE
    PRINT '  - CalibrationFrequency column already exists in ATE_Inventory';

-- CalibrationResponsible
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = 'ATE_Inventory' 
               AND COLUMN_NAME = 'CalibrationResponsible')
BEGIN
    ALTER TABLE dbo.ATE_Inventory
    ADD CalibrationResponsible NVARCHAR(100) NULL;
    PRINT '  - Added CalibrationResponsible column to ATE_Inventory';
END
ELSE
    PRINT '  - CalibrationResponsible column already exists in ATE_Inventory';

-- LastCalibration
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = 'ATE_Inventory' 
               AND COLUMN_NAME = 'LastCalibration')
BEGIN
    ALTER TABLE dbo.ATE_Inventory
    ADD LastCalibration DATETIME NULL;
    PRINT '  - Added LastCalibration column to ATE_Inventory';
END
ELSE
    PRINT '  - LastCalibration column already exists in ATE_Inventory';

-- LastCalibrationBy
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = 'ATE_Inventory' 
               AND COLUMN_NAME = 'LastCalibrationBy')
BEGIN
    ALTER TABLE dbo.ATE_Inventory
    ADD LastCalibrationBy NVARCHAR(100) NULL;
    PRINT '  - Added LastCalibrationBy column to ATE_Inventory';
END
ELSE
    PRINT '  - LastCalibrationBy column already exists in ATE_Inventory';

-- NextCalibration
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = 'ATE_Inventory' 
               AND COLUMN_NAME = 'NextCalibration')
BEGIN
    ALTER TABLE dbo.ATE_Inventory
    ADD NextCalibration DATETIME NULL;
    PRINT '  - Added NextCalibration column to ATE_Inventory';
END
ELSE
    PRINT '  - NextCalibration column already exists in ATE_Inventory';

GO

-- =============================================
-- Asset_Inventory Table
-- =============================================

PRINT 'Processing Asset_Inventory table...';

-- RequiredCalibration
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = 'Asset_Inventory' 
               AND COLUMN_NAME = 'RequiredCalibration')
BEGIN
    ALTER TABLE dbo.Asset_Inventory
    ADD RequiredCalibration BIT NULL DEFAULT 0;
    PRINT '  - Added RequiredCalibration column to Asset_Inventory';
END
ELSE
    PRINT '  - RequiredCalibration column already exists in Asset_Inventory';

-- CalibrationFrequency
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = 'Asset_Inventory' 
               AND COLUMN_NAME = 'CalibrationFrequency')
BEGIN
    ALTER TABLE dbo.Asset_Inventory
    ADD CalibrationFrequency NVARCHAR(50) NULL;
    PRINT '  - Added CalibrationFrequency column to Asset_Inventory';
END
ELSE
    PRINT '  - CalibrationFrequency column already exists in Asset_Inventory';

-- CalibrationResponsible
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = 'Asset_Inventory' 
               AND COLUMN_NAME = 'CalibrationResponsible')
BEGIN
    ALTER TABLE dbo.Asset_Inventory
    ADD CalibrationResponsible NVARCHAR(100) NULL;
    PRINT '  - Added CalibrationResponsible column to Asset_Inventory';
END
ELSE
    PRINT '  - CalibrationResponsible column already exists in Asset_Inventory';

-- LastCalibration
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = 'Asset_Inventory' 
               AND COLUMN_NAME = 'LastCalibration')
BEGIN
    ALTER TABLE dbo.Asset_Inventory
    ADD LastCalibration DATETIME NULL;
    PRINT '  - Added LastCalibration column to Asset_Inventory';
END
ELSE
    PRINT '  - LastCalibration column already exists in Asset_Inventory';

-- CalibrationBy (Note: Asset uses CalibrationBy instead of LastCalibrationBy)
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = 'Asset_Inventory' 
               AND COLUMN_NAME = 'CalibrationBy')
BEGIN
    ALTER TABLE dbo.Asset_Inventory
    ADD CalibrationBy NVARCHAR(100) NULL;
    PRINT '  - Added CalibrationBy column to Asset_Inventory';
END
ELSE
    PRINT '  - CalibrationBy column already exists in Asset_Inventory';

-- NextCalibration
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = 'Asset_Inventory' 
               AND COLUMN_NAME = 'NextCalibration')
BEGIN
    ALTER TABLE dbo.Asset_Inventory
    ADD NextCalibration DATETIME NULL;
    PRINT '  - Added NextCalibration column to Asset_Inventory';
END
ELSE
    PRINT '  - NextCalibration column already exists in Asset_Inventory';

GO

-- =============================================
-- Fixture_Inventory Table
-- =============================================

PRINT 'Processing Fixture_Inventory table...';

-- RequiredCalibration
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = 'Fixture_Inventory' 
               AND COLUMN_NAME = 'RequiredCalibration')
BEGIN
    ALTER TABLE dbo.Fixture_Inventory
    ADD RequiredCalibration BIT NULL DEFAULT 0;
    PRINT '  - Added RequiredCalibration column to Fixture_Inventory';
END
ELSE
    PRINT '  - RequiredCalibration column already exists in Fixture_Inventory';

-- CalibrationFrequency
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = 'Fixture_Inventory' 
               AND COLUMN_NAME = 'CalibrationFrequency')
BEGIN
    ALTER TABLE dbo.Fixture_Inventory
    ADD CalibrationFrequency NVARCHAR(50) NULL;
    PRINT '  - Added CalibrationFrequency column to Fixture_Inventory';
END
ELSE
    PRINT '  - CalibrationFrequency column already exists in Fixture_Inventory';

-- CalibrationResponsible
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = 'Fixture_Inventory' 
               AND COLUMN_NAME = 'CalibrationResponsible')
BEGIN
    ALTER TABLE dbo.Fixture_Inventory
    ADD CalibrationResponsible NVARCHAR(100) NULL;
    PRINT '  - Added CalibrationResponsible column to Fixture_Inventory';
END
ELSE
    PRINT '  - CalibrationResponsible column already exists in Fixture_Inventory';

-- LastCalibration
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = 'Fixture_Inventory' 
               AND COLUMN_NAME = 'LastCalibration')
BEGIN
    ALTER TABLE dbo.Fixture_Inventory
    ADD LastCalibration DATETIME NULL;
    PRINT '  - Added LastCalibration column to Fixture_Inventory';
END
ELSE
    PRINT '  - LastCalibration column already exists in Fixture_Inventory';

-- CalibrationBy (Note: Fixture uses CalibrationBy instead of LastCalibrationBy)
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = 'Fixture_Inventory' 
               AND COLUMN_NAME = 'CalibrationBy')
BEGIN
    ALTER TABLE dbo.Fixture_Inventory
    ADD CalibrationBy NVARCHAR(100) NULL;
    PRINT '  - Added CalibrationBy column to Fixture_Inventory';
END
ELSE
    PRINT '  - CalibrationBy column already exists in Fixture_Inventory';

-- NextCalibration
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = 'Fixture_Inventory' 
               AND COLUMN_NAME = 'NextCalibration')
BEGIN
    ALTER TABLE dbo.Fixture_Inventory
    ADD NextCalibration DATETIME NULL;
    PRINT '  - Added NextCalibration column to Fixture_Inventory';
END
ELSE
    PRINT '  - NextCalibration column already exists in Fixture_Inventory';

GO

-- =============================================
-- Harness_Inventory Table
-- =============================================

PRINT 'Processing Harness_Inventory table...';

-- RequiredCalibration
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = 'Harness_Inventory' 
               AND COLUMN_NAME = 'RequiredCalibration')
BEGIN
    ALTER TABLE dbo.Harness_Inventory
    ADD RequiredCalibration BIT NULL DEFAULT 0;
    PRINT '  - Added RequiredCalibration column to Harness_Inventory';
END
ELSE
    PRINT '  - RequiredCalibration column already exists in Harness_Inventory';

-- CalibrationFrequency
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = 'Harness_Inventory' 
               AND COLUMN_NAME = 'CalibrationFrequency')
BEGIN
    ALTER TABLE dbo.Harness_Inventory
    ADD CalibrationFrequency NVARCHAR(50) NULL;
    PRINT '  - Added CalibrationFrequency column to Harness_Inventory';
END
ELSE
    PRINT '  - CalibrationFrequency column already exists in Harness_Inventory';

-- CalibrationResponsible
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = 'Harness_Inventory' 
               AND COLUMN_NAME = 'CalibrationResponsible')
BEGIN
    ALTER TABLE dbo.Harness_Inventory
    ADD CalibrationResponsible NVARCHAR(100) NULL;
    PRINT '  - Added CalibrationResponsible column to Harness_Inventory';
END
ELSE
    PRINT '  - CalibrationResponsible column already exists in Harness_Inventory';

-- LastCalibration
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = 'Harness_Inventory' 
               AND COLUMN_NAME = 'LastCalibration')
BEGIN
    ALTER TABLE dbo.Harness_Inventory
    ADD LastCalibration DATETIME NULL;
    PRINT '  - Added LastCalibration column to Harness_Inventory';
END
ELSE
    PRINT '  - LastCalibration column already exists in Harness_Inventory';

-- CalibrationBy (Note: Harness uses CalibrationBy instead of LastCalibrationBy)
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = 'Harness_Inventory' 
               AND COLUMN_NAME = 'CalibrationBy')
BEGIN
    ALTER TABLE dbo.Harness_Inventory
    ADD CalibrationBy NVARCHAR(100) NULL;
    PRINT '  - Added CalibrationBy column to Harness_Inventory';
END
ELSE
    PRINT '  - CalibrationBy column already exists in Harness_Inventory';

-- NextCalibration
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = 'Harness_Inventory' 
               AND COLUMN_NAME = 'NextCalibration')
BEGIN
    ALTER TABLE dbo.Harness_Inventory
    ADD NextCalibration DATETIME NULL;
    PRINT '  - Added NextCalibration column to Harness_Inventory';
END
ELSE
    PRINT '  - NextCalibration column already exists in Harness_Inventory';

GO

PRINT '';
PRINT '==============================================';
PRINT 'Calibration columns added successfully!';
PRINT '==============================================';
PRINT '';
PRINT 'Summary:';
PRINT '- ATE_Inventory: RequiredCalibration, CalibrationFrequency, CalibrationResponsible, LastCalibration, LastCalibrationBy, NextCalibration';
PRINT '- Asset_Inventory: RequiredCalibration, CalibrationFrequency, CalibrationResponsible, LastCalibration, CalibrationBy, NextCalibration';
PRINT '- Fixture_Inventory: RequiredCalibration, CalibrationFrequency, CalibrationResponsible, LastCalibration, CalibrationBy, NextCalibration';
PRINT '- Harness_Inventory: RequiredCalibration, CalibrationFrequency, CalibrationResponsible, LastCalibration, CalibrationBy, NextCalibration';
PRINT '';
PRINT 'Note: ATE uses "LastCalibrationBy" while Asset/Fixture/Harness use "CalibrationBy"';
PRINT '';
PRINT 'Next steps:';
PRINT '1. Update equipment records to set RequiredCalibration = 1 for equipment that needs calibration';
PRINT '2. Run Create_vw_Equipment_RequireCalibration.sql to create the view';
PRINT '3. Use CalibrationDetails.aspx to manage calibration logs';
GO
