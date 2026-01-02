-- Create ProductionLine table for Test Engineering Dashboard
-- This table stores the available production/test lines that users can be assigned to

USE [TestEngineering]
GO

-- Check if ProductionLine table already exists
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'ProductionLine')
BEGIN
    -- Create ProductionLine table
    CREATE TABLE dbo.ProductionLine (
        ProductionLineID INT IDENTITY(1,1) PRIMARY KEY,
        ProductionLineName NVARCHAR(100) NOT NULL,
        Description NVARCHAR(500) NULL,
        IsActive BIT NOT NULL DEFAULT 1,
        CreatedDate DATETIME2 NOT NULL DEFAULT GETDATE(),
        ModifiedDate DATETIME2 NULL,
        CreatedBy NVARCHAR(100) NULL,
        ModifiedBy NVARCHAR(100) NULL
    )
    
    PRINT 'ProductionLine table created successfully'
    
    -- Insert sample production lines
    INSERT INTO dbo.ProductionLine (ProductionLineName, Description, IsActive, CreatedBy)
    VALUES 
        ('Battery Line 1', 'Primary battery testing line', 1, 'System'),
        ('Battery Line 2', 'Secondary battery testing line', 1, 'System'),
        ('Breaker Line 1', 'Circuit breaker testing line', 1, 'System'),
        ('Breaker Line 2', 'Secondary breaker testing line', 1, 'System'),
        ('Calibration Lab', 'Equipment calibration and testing', 1, 'System'),
        ('R&D Testing', 'Research and development testing area', 1, 'System'),
        ('Quality Lab', 'Quality control testing line', 1, 'System'),
        ('Production Test', 'Final production testing', 1, 'System')
    
    PRINT 'Sample production lines inserted successfully'
END
ELSE
BEGIN
    PRINT 'ProductionLine table already exists'
END
GO

-- Create an index on ProductionLineName for better performance
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.ProductionLine') AND name = 'IX_ProductionLine_Name')
BEGIN
    CREATE NONCLUSTERED INDEX IX_ProductionLine_Name 
    ON dbo.ProductionLine (ProductionLineName)
    WHERE IsActive = 1
    
    PRINT 'Index on ProductionLineName created successfully'
END
ELSE
BEGIN
    PRINT 'Index on ProductionLineName already exists'
END
GO

PRINT 'ProductionLine table setup completed'
GO