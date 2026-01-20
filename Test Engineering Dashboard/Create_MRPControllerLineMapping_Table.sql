-- =============================================================================
-- Create MRP Controller Code to Production Line Mapping Table
-- =============================================================================
-- This table maps MRP Controller Code prefixes to production lines
-- Used to assign ZMMR scrap data to the appropriate production line
-- =============================================================================

USE TestEngineering;
GO

-- Create the mapping table
IF OBJECT_ID('dbo.MRPControllerLineMapping', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.MRPControllerLineMapping (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        CodePrefix NVARCHAR(10) NOT NULL,           -- The starting character(s) of MRP Controller Code
        LineName NVARCHAR(100) NOT NULL,            -- The production line name
        Ledger NVARCHAR(50) NULL,                   -- The ledger this line belongs to (SPD, D-IT, Energy Transition)
        Plant NVARCHAR(10) NOT NULL DEFAULT 'YPO',  -- Plant code
        Description NVARCHAR(255) NULL,             -- Optional description
        IsActive BIT NOT NULL DEFAULT 1,            -- Whether this mapping is active
        CreatedDate DATETIME DEFAULT GETDATE(),
        CreatedBy NVARCHAR(100) NULL,
        UpdatedDate DATETIME NULL,
        UpdatedBy NVARCHAR(100) NULL,
        CONSTRAINT UQ_MRPControllerLineMapping UNIQUE (CodePrefix, Plant)
    );
    
    PRINT 'Table MRPControllerLineMapping created successfully.';
END
ELSE
BEGIN
    PRINT 'Table MRPControllerLineMapping already exists.';
END
GO

-- Create index for faster lookups
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_MRPControllerLineMapping_CodePrefix' AND object_id = OBJECT_ID('dbo.MRPControllerLineMapping'))
BEGIN
    CREATE INDEX IX_MRPControllerLineMapping_CodePrefix 
    ON dbo.MRPControllerLineMapping (CodePrefix, Plant, IsActive);
    
    PRINT 'Index IX_MRPControllerLineMapping_CodePrefix created.';
END
GO

-- Insert initial mapping data
-- Clear existing data first (optional - comment out if you want to preserve existing)
DELETE FROM dbo.MRPControllerLineMapping WHERE Plant = 'YPO';
GO

-- Insert the mappings based on code prefix rules
-- Structure: Ledgers contain Lines
-- SPD Ledger: SPD
-- D-IT Ledger: 9PXM/Switch, ePDU, Battery, Shazam, TAA, Ferrups, BladeUPS  
-- Energy Transition Ledger: Phoenix

INSERT INTO dbo.MRPControllerLineMapping (CodePrefix, LineName, Ledger, Plant, Description, IsActive, CreatedBy)
VALUES 
    ('A', 'SPD', 'SPD', 'YPO', 'MRP codes starting with A belong to SPD', 1, 'System'),
    ('M', 'SPD', 'SPD', 'YPO', 'MRP codes starting with M belong to SPD', 1, 'System'),
    ('B', 'ePDU', 'D-IT', 'YPO', 'MRP codes starting with B belong to ePDU', 1, 'System'),
    ('L', 'ePDU', 'D-IT', 'YPO', 'MRP codes starting with L belong to ePDU', 1, 'System'),
    ('C', 'Ferrups', 'D-IT', 'YPO', 'MRP codes starting with C belong to Ferrups', 1, 'System'),
    ('D', '9PXM/Switch', 'D-IT', 'YPO', 'MRP codes starting with D belong to 9PXM/Switch', 1, 'System'),
    ('F', 'BladeUPS', 'D-IT', 'YPO', 'MRP codes starting with F belong to BladeUPS', 1, 'System'),
    ('G', 'TAA', 'D-IT', 'YPO', 'MRP codes starting with G belong to TAA', 1, 'System'),
    ('H', 'Battery', 'D-IT', 'YPO', 'MRP codes starting with H belong to Battery (Battery Line)', 1, 'System'),
    ('I', 'Phoenix', 'Energy Transition', 'YPO', 'MRP codes starting with I belong to Phoenix', 1, 'System'),
    ('P', 'Shazam', 'D-IT', 'YPO', 'MRP codes starting with P belong to Shazam', 1, 'System');

PRINT 'Initial MRP Controller mappings inserted for YPO plant.';
GO

-- =============================================================================
-- Create a function to get the line name from MRP Controller Code
-- =============================================================================
IF OBJECT_ID('dbo.fn_GetLineFromMRPCode', 'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_GetLineFromMRPCode;
GO

CREATE FUNCTION dbo.fn_GetLineFromMRPCode
(
    @MRPControllerCode NVARCHAR(50),
    @Plant NVARCHAR(10) = 'YPO'
)
RETURNS NVARCHAR(100)
AS
BEGIN
    DECLARE @LineName NVARCHAR(100) = NULL;
    DECLARE @FirstChar NVARCHAR(1);
    
    -- Get the first character of the MRP Controller Code
    SET @FirstChar = LEFT(@MRPControllerCode, 1);
    
    -- Look up the mapping
    SELECT TOP 1 @LineName = LineName
    FROM dbo.MRPControllerLineMapping
    WHERE CodePrefix = @FirstChar
      AND Plant = @Plant
      AND IsActive = 1;
    
    -- Return 'Unknown' if no mapping found
    RETURN ISNULL(@LineName, 'Unknown');
END
GO

PRINT 'Function fn_GetLineFromMRPCode created.';
GO

-- =============================================================================
-- Create a view to show ZMMR scrap data with mapped line names
-- =============================================================================
IF OBJECT_ID('dbo.View_ZMMR_ScrapByLine', 'V') IS NOT NULL
    DROP VIEW dbo.View_ZMMR_ScrapByLine;
GO

CREATE VIEW dbo.View_ZMMR_ScrapByLine
AS
SELECT 
    z.ID,
    z.Amount,
    z.CostCenterCode,
    z.MaterialDescription,
    z.MaterialNumber,
    z.MovementType,
    z.MRPControllerCode,
    z.MRPControllerDesc,
    z.PlantCode,
    z.PostingDate,
    z.Quantity,
    z.ReasonDescription,
    z.UserFullName,
    z.ImportedDate,
    z.ImportFileName,
    -- Mapped line name
    ISNULL(m.LineName, 'Unknown') AS LineName,
    -- Extract year and month for easier aggregation
    YEAR(z.PostingDate) AS PostingYear,
    MONTH(z.PostingDate) AS PostingMonth
FROM dbo.ZMMR_ScrapData z
LEFT JOIN dbo.MRPControllerLineMapping m 
    ON LEFT(z.MRPControllerCode, 1) = m.CodePrefix 
    AND m.Plant = 'YPO'
    AND m.IsActive = 1;
GO

PRINT 'View View_ZMMR_ScrapByLine created.';
GO

-- =============================================================================
-- Create a summary view for scrap totals by line and month
-- =============================================================================
IF OBJECT_ID('dbo.View_ZMMR_ScrapSummaryByLineMonth', 'V') IS NOT NULL
    DROP VIEW dbo.View_ZMMR_ScrapSummaryByLineMonth;
GO

CREATE VIEW dbo.View_ZMMR_ScrapSummaryByLineMonth
AS
SELECT 
    ISNULL(m.LineName, 'Unknown') AS LineName,
    YEAR(z.PostingDate) AS PostingYear,
    MONTH(z.PostingDate) AS PostingMonth,
    SUM(z.Amount) AS TotalScrapAmount,
    SUM(z.Quantity) AS TotalScrapQuantity,
    COUNT(*) AS TransactionCount
FROM dbo.ZMMR_ScrapData z
LEFT JOIN dbo.MRPControllerLineMapping m 
    ON LEFT(z.MRPControllerCode, 1) = m.CodePrefix 
    AND m.Plant = 'YPO'
    AND m.IsActive = 1
GROUP BY 
    ISNULL(m.LineName, 'Unknown'),
    YEAR(z.PostingDate),
    MONTH(z.PostingDate);
GO

PRINT 'View View_ZMMR_ScrapSummaryByLineMonth created.';
GO

-- =============================================================================
-- Verify the setup
-- =============================================================================
SELECT 'MRPControllerLineMapping' AS TableName, COUNT(*) AS RecordCount FROM dbo.MRPControllerLineMapping;
GO

SELECT * FROM dbo.MRPControllerLineMapping ORDER BY CodePrefix;
GO

-- Test the function
SELECT dbo.fn_GetLineFromMRPCode('A01', 'YPO') AS TestResult_A;
SELECT dbo.fn_GetLineFromMRPCode('B23', 'YPO') AS TestResult_B;
SELECT dbo.fn_GetLineFromMRPCode('P99', 'YPO') AS TestResult_P;
GO

PRINT '';
PRINT '=============================================================================';
PRINT 'MRP Controller Line Mapping setup complete!';
PRINT '=============================================================================';
