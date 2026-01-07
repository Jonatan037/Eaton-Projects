-- =============================================
-- Plant Quality Performance Dashboard Views
-- Created: January 2026
-- Purpose: Provide data for Plant Quality Performance Dashboard
-- =============================================

-- =============================================
-- Quality Goals Table for storing targets
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Quality_Goals]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[Quality_Goals] (
        [GoalID] INT IDENTITY(1,1) PRIMARY KEY,
        [Plant] NVARCHAR(50) NOT NULL,
        [ProductionLine] NVARCHAR(100) NULL,  -- NULL means plant-wide
        [MetricType] NVARCHAR(50) NOT NULL,   -- 'Yield', 'Scrap', 'NCM'
        [GoalValue] DECIMAL(10,4) NOT NULL,
        [EffectiveDate] DATE NOT NULL,
        [EndDate] DATE NULL,
        [CreatedBy] NVARCHAR(100) NULL,
        [CreatedDate] DATETIME DEFAULT GETDATE(),
        [ModifiedBy] NVARCHAR(100) NULL,
        [ModifiedDate] DATETIME NULL,
        CONSTRAINT [UQ_Quality_Goals] UNIQUE ([Plant], [ProductionLine], [MetricType], [EffectiveDate])
    );
    
    -- Insert default goals
    INSERT INTO [dbo].[Quality_Goals] ([Plant], [ProductionLine], [MetricType], [GoalValue], [EffectiveDate])
    VALUES 
        ('YPO', NULL, 'Yield', 0.98, '2025-01-01'),
        ('YPO', NULL, 'Scrap', 500.00, '2025-01-01'),
        ('YPO', NULL, 'NCM', 1000.00, '2025-01-01'),
        ('CPO', NULL, 'Yield', 0.98, '2025-01-01'),
        ('CPO', NULL, 'Scrap', 500.00, '2025-01-01'),
        ('CPO', NULL, 'NCM', 1000.00, '2025-01-01');
    
    PRINT 'Created Quality_Goals table with default goals';
END
GO

-- =============================================
-- Note: The main yield data will be pulled from TRACKS database
-- using the same methodology as Yields.aspx.cs:
-- - View_PowerBI_MASTER_INDEX for tested/passed/failed
-- - View_PowerBI_MASTER_INDEX_AND_ISSUE_REPORTS_COMBINED for issue categories
-- =============================================

PRINT 'Plant Quality Dashboard Views script completed';
GO
