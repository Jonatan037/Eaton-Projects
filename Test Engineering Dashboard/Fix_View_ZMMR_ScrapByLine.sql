-- =============================================================================
-- Fix View_ZMMR_ScrapByLine - Correct column name from ImportDate to ImportedDate
-- =============================================================================

USE TestEngineering;
GO

-- Drop and recreate the view with correct column name
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
    z.ImportedDate,          -- Fixed: was ImportDate
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

PRINT 'View View_ZMMR_ScrapByLine fixed successfully.';
GO

-- Verify the view works
SELECT TOP 5 * FROM dbo.View_ZMMR_ScrapByLine;
GO
