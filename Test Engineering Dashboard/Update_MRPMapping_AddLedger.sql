-- =============================================================================
-- Update MRPControllerLineMapping to add Ledger column and fix line structure
-- =============================================================================
-- Structure:
-- LEDGER          | LINES
-- ----------------|------------------------------------------
-- SPD             | SPD
-- D-IT            | 9PXM/Switch, ePDU, Battery, Shazam, TAA, Ferrups, BladeUPS
-- Energy Transition | Phoenix
-- =============================================================================

USE TestEngineering;
GO

-- Step 1: Add Ledger column if it doesn't exist
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.MRPControllerLineMapping') AND name = 'Ledger')
BEGIN
    ALTER TABLE dbo.MRPControllerLineMapping
    ADD Ledger NVARCHAR(50) NULL;
    
    PRINT 'Added Ledger column to MRPControllerLineMapping.';
END
ELSE
BEGIN
    PRINT 'Ledger column already exists.';
END
GO

-- Step 2: Remove D-IT as a line (it's a ledger, not a line)
DELETE FROM dbo.MRPControllerLineMapping 
WHERE LineName = 'D-IT' AND Plant = 'YPO';

PRINT 'Removed D-IT as a line (it is a ledger, not a line).';
GO

-- Step 3: Update existing lines with their Ledger assignments
-- Also fix line name 9PXM to 9PXM/Switch

-- SPD Ledger - contains SPD line (A and M prefixes)
UPDATE dbo.MRPControllerLineMapping
SET Ledger = 'SPD',
    UpdatedDate = GETDATE(),
    UpdatedBy = 'System'
WHERE LineName = 'SPD' AND Plant = 'YPO';

-- D-IT Ledger - contains multiple lines
-- 9PXM/Switch (D prefix) - rename from 9PXM
UPDATE dbo.MRPControllerLineMapping
SET LineName = '9PXM/Switch',
    Ledger = 'D-IT',
    Description = 'MRP codes starting with D belong to 9PXM/Switch',
    UpdatedDate = GETDATE(),
    UpdatedBy = 'System'
WHERE CodePrefix = 'D' AND Plant = 'YPO';

-- ePDU (B and L prefixes)
UPDATE dbo.MRPControllerLineMapping
SET Ledger = 'D-IT',
    UpdatedDate = GETDATE(),
    UpdatedBy = 'System'
WHERE LineName = 'ePDU' AND Plant = 'YPO';

-- Battery (H prefix)
UPDATE dbo.MRPControllerLineMapping
SET Ledger = 'D-IT',
    UpdatedDate = GETDATE(),
    UpdatedBy = 'System'
WHERE LineName = 'Battery' AND Plant = 'YPO';

-- Shazam (P prefix)
UPDATE dbo.MRPControllerLineMapping
SET Ledger = 'D-IT',
    UpdatedDate = GETDATE(),
    UpdatedBy = 'System'
WHERE LineName = 'Shazam' AND Plant = 'YPO';

-- TAA (G prefix) - not running in 2026 but keep for historical data
UPDATE dbo.MRPControllerLineMapping
SET Ledger = 'D-IT',
    UpdatedDate = GETDATE(),
    UpdatedBy = 'System'
WHERE LineName = 'TAA' AND Plant = 'YPO';

-- Ferrups (C prefix) - not running in 2026 but keep for historical data
UPDATE dbo.MRPControllerLineMapping
SET Ledger = 'D-IT',
    UpdatedDate = GETDATE(),
    UpdatedBy = 'System'
WHERE LineName = 'Ferrups' AND Plant = 'YPO';

-- BladeUPS (F prefix) - not running in 2026 but keep for historical data
UPDATE dbo.MRPControllerLineMapping
SET Ledger = 'D-IT',
    UpdatedDate = GETDATE(),
    UpdatedBy = 'System'
WHERE LineName = 'BladeUPS' AND Plant = 'YPO';

-- Energy Transition Ledger - contains Phoenix line
UPDATE dbo.MRPControllerLineMapping
SET Ledger = 'Energy Transition',
    UpdatedDate = GETDATE(),
    UpdatedBy = 'System'
WHERE LineName = 'Phoenix' AND Plant = 'YPO';

PRINT 'Updated all lines with Ledger assignments.';
GO

-- Step 4: Create index on Ledger column for faster queries
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_MRPControllerLineMapping_Ledger' AND object_id = OBJECT_ID('dbo.MRPControllerLineMapping'))
BEGIN
    CREATE INDEX IX_MRPControllerLineMapping_Ledger 
    ON dbo.MRPControllerLineMapping (Ledger, Plant, IsActive);
    
    PRINT 'Index IX_MRPControllerLineMapping_Ledger created.';
END
GO

-- Step 5: Update the View_ZMMR_ScrapByLine to include Ledger
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
    -- Mapped line and ledger
    ISNULL(m.LineName, 'Unknown') AS LineName,
    ISNULL(m.Ledger, 'Unknown') AS Ledger,
    -- Extract year and month for easier aggregation
    YEAR(z.PostingDate) AS PostingYear,
    MONTH(z.PostingDate) AS PostingMonth
FROM dbo.ZMMR_ScrapData z
LEFT JOIN dbo.MRPControllerLineMapping m 
    ON LEFT(z.MRPControllerCode, 1) = m.CodePrefix 
    AND m.Plant = 'YPO'
    AND m.IsActive = 1;
GO

PRINT 'View View_ZMMR_ScrapByLine updated with Ledger column.';
GO

-- Step 6: Create/Update the summary view to include Ledger
IF OBJECT_ID('dbo.View_ZMMR_ScrapSummaryByLineMonth', 'V') IS NOT NULL
    DROP VIEW dbo.View_ZMMR_ScrapSummaryByLineMonth;
GO

CREATE VIEW dbo.View_ZMMR_ScrapSummaryByLineMonth
AS
SELECT 
    ISNULL(m.LineName, 'Unknown') AS LineName,
    ISNULL(m.Ledger, 'Unknown') AS Ledger,
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
    ISNULL(m.Ledger, 'Unknown'),
    YEAR(z.PostingDate),
    MONTH(z.PostingDate);
GO

PRINT 'View View_ZMMR_ScrapSummaryByLineMonth updated with Ledger column.';
GO

-- Step 7: Create a view for Ledger-level summary
IF OBJECT_ID('dbo.View_ZMMR_ScrapSummaryByLedgerMonth', 'V') IS NOT NULL
    DROP VIEW dbo.View_ZMMR_ScrapSummaryByLedgerMonth;
GO

CREATE VIEW dbo.View_ZMMR_ScrapSummaryByLedgerMonth
AS
SELECT 
    ISNULL(m.Ledger, 'Unknown') AS Ledger,
    YEAR(z.PostingDate) AS PostingYear,
    MONTH(z.PostingDate) AS PostingMonth,
    SUM(z.Amount) AS TotalScrapAmount,
    SUM(z.Quantity) AS TotalScrapQuantity,
    COUNT(*) AS TransactionCount,
    COUNT(DISTINCT m.LineName) AS LineCount
FROM dbo.ZMMR_ScrapData z
LEFT JOIN dbo.MRPControllerLineMapping m 
    ON LEFT(z.MRPControllerCode, 1) = m.CodePrefix 
    AND m.Plant = 'YPO'
    AND m.IsActive = 1
GROUP BY 
    ISNULL(m.Ledger, 'Unknown'),
    YEAR(z.PostingDate),
    MONTH(z.PostingDate);
GO

PRINT 'View View_ZMMR_ScrapSummaryByLedgerMonth created.';
GO

-- Verify the updated mapping
SELECT 
    CodePrefix, 
    LineName, 
    Ledger, 
    Description, 
    IsActive
FROM dbo.MRPControllerLineMapping 
WHERE Plant = 'YPO' 
ORDER BY Ledger, LineName;
GO

PRINT '';
PRINT '=============================================================================';
PRINT 'MRP Controller Line Mapping updated with Ledger structure!';
PRINT '';
PRINT 'LEDGER              | LINES';
PRINT '--------------------|------------------------------------------';
PRINT 'SPD                 | SPD';
PRINT 'D-IT                | 9PXM/Switch, ePDU, Battery, Shazam, TAA, Ferrups, BladeUPS';
PRINT 'Energy Transition   | Phoenix';
PRINT '=============================================================================';
