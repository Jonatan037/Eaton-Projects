-- =============================================
-- Add CalibrationEstimatedTime to Equipment Tables
-- =============================================
-- This script adds CalibrationEstimatedTime column to equipment tables
-- Similar to PMEstimatedTime that was added for PM tracking
-- OPTIONAL: Only run if you want to track estimated calibration time
-- =============================================

USE [TestEngineering]
GO

PRINT 'Adding CalibrationEstimatedTime column to equipment inventory tables...';
PRINT '';
GO

-- =============================================
-- ATE_Inventory Table
-- =============================================

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = 'ATE_Inventory' 
               AND COLUMN_NAME = 'CalibrationEstimatedTime')
BEGIN
    ALTER TABLE dbo.ATE_Inventory
    ADD CalibrationEstimatedTime DECIMAL(5,2) NULL;
    PRINT '✓ Added CalibrationEstimatedTime to ATE_Inventory';
END
ELSE
    PRINT '- CalibrationEstimatedTime already exists in ATE_Inventory';
GO

-- =============================================
-- Asset_Inventory Table
-- =============================================

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = 'Asset_Inventory' 
               AND COLUMN_NAME = 'CalibrationEstimatedTime')
BEGIN
    ALTER TABLE dbo.Asset_Inventory
    ADD CalibrationEstimatedTime DECIMAL(5,2) NULL;
    PRINT '✓ Added CalibrationEstimatedTime to Asset_Inventory';
END
ELSE
    PRINT '- CalibrationEstimatedTime already exists in Asset_Inventory';
GO

-- =============================================
-- Fixture_Inventory Table
-- =============================================

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = 'Fixture_Inventory' 
               AND COLUMN_NAME = 'CalibrationEstimatedTime')
BEGIN
    ALTER TABLE dbo.Fixture_Inventory
    ADD CalibrationEstimatedTime DECIMAL(5,2) NULL;
    PRINT '✓ Added CalibrationEstimatedTime to Fixture_Inventory';
END
ELSE
    PRINT '- CalibrationEstimatedTime already exists in Fixture_Inventory';
GO

-- =============================================
-- Harness_Inventory Table
-- =============================================

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = 'Harness_Inventory' 
               AND COLUMN_NAME = 'CalibrationEstimatedTime')
BEGIN
    ALTER TABLE dbo.Harness_Inventory
    ADD CalibrationEstimatedTime DECIMAL(5,2) NULL;
    PRINT '✓ Added CalibrationEstimatedTime to Harness_Inventory';
END
ELSE
    PRINT '- CalibrationEstimatedTime already exists in Harness_Inventory';
GO

PRINT '';
PRINT '==============================================';
PRINT 'CalibrationEstimatedTime column added successfully!';
PRINT '==============================================';
PRINT '';
PRINT 'Column Type: DECIMAL(5,2) - Stores hours with 2 decimal places';
PRINT 'Example values: 0.5 (30 min), 1.0 (1 hour), 2.5 (2.5 hours)';
PRINT '';
PRINT 'To set estimated time for equipment:';
PRINT '  UPDATE ATE_Inventory SET CalibrationEstimatedTime = 1.5 WHERE ATEInventoryID = 1;';
PRINT '';
GO
