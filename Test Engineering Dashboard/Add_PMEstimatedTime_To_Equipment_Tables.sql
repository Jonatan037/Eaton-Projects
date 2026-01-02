-- =============================================
-- Add PMEstimatedTime Column to Equipment Tables
-- Description: Adds PMEstimatedTime (in hours) to all equipment inventory tables
-- Date: October 2025
-- =============================================

USE [TestEngineering]
GO

-- Add PMEstimatedTime to ATE_Inventory
IF NOT EXISTS (
    SELECT * FROM sys.columns 
    WHERE object_id = OBJECT_ID(N'dbo.ATE_Inventory') 
    AND name = 'PMEstimatedTime'
)
BEGIN
    ALTER TABLE dbo.ATE_Inventory
    ADD PMEstimatedTime DECIMAL(5,2) NULL;
    
    PRINT 'PMEstimatedTime column added successfully to ATE_Inventory table.';
END
ELSE
BEGIN
    PRINT 'PMEstimatedTime column already exists in ATE_Inventory table.';
END
GO

-- Add PMEstimatedTime to Asset_Inventory
IF NOT EXISTS (
    SELECT * FROM sys.columns 
    WHERE object_id = OBJECT_ID(N'dbo.Asset_Inventory') 
    AND name = 'PMEstimatedTime'
)
BEGIN
    ALTER TABLE dbo.Asset_Inventory
    ADD PMEstimatedTime DECIMAL(5,2) NULL;
    
    PRINT 'PMEstimatedTime column added successfully to Asset_Inventory table.';
END
ELSE
BEGIN
    PRINT 'PMEstimatedTime column already exists in Asset_Inventory table.';
END
GO

-- Add PMEstimatedTime to Fixture_Inventory
IF NOT EXISTS (
    SELECT * FROM sys.columns 
    WHERE object_id = OBJECT_ID(N'dbo.Fixture_Inventory') 
    AND name = 'PMEstimatedTime'
)
BEGIN
    ALTER TABLE dbo.Fixture_Inventory
    ADD PMEstimatedTime DECIMAL(5,2) NULL;
    
    PRINT 'PMEstimatedTime column added successfully to Fixture_Inventory table.';
END
ELSE
BEGIN
    PRINT 'PMEstimatedTime column already exists in Fixture_Inventory table.';
END
GO

-- Add PMEstimatedTime to Harness_Inventory
IF NOT EXISTS (
    SELECT * FROM sys.columns 
    WHERE object_id = OBJECT_ID(N'dbo.Harness_Inventory') 
    AND name = 'PMEstimatedTime'
)
BEGIN
    ALTER TABLE dbo.Harness_Inventory
    ADD PMEstimatedTime DECIMAL(5,2) NULL;
    
    PRINT 'PMEstimatedTime column added successfully to Harness_Inventory table.';
END
ELSE
BEGIN
    PRINT 'PMEstimatedTime column already exists in Harness_Inventory table.';
END
GO

PRINT 'PMEstimatedTime column addition completed for all equipment tables.';
GO
