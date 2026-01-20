-- =============================================================================
-- Update MRP Controller Line Mapping
-- 1. Change "Wire" to "Shazam" (P prefix)
-- 2. Add "D-IT" as a new line
-- =============================================================================

USE TestEngineering;
GO

-- Update Wire to Shazam
UPDATE dbo.MRPControllerLineMapping
SET LineName = 'Shazam',
    Description = 'MRP codes starting with P belong to Shazam',
    UpdatedDate = GETDATE(),
    UpdatedBy = 'System'
WHERE CodePrefix = 'P' AND Plant = 'YPO';

PRINT 'Updated P prefix mapping from Wire to Shazam.';
GO

-- Add D-IT as a new line (we'll use a special prefix or add it manually)
-- Since D-IT doesn't have a specific MRP code prefix, we add it as a standalone line
-- that can have scrap goals set manually

-- First check if it already exists
IF NOT EXISTS (SELECT 1 FROM dbo.MRPControllerLineMapping WHERE LineName = 'D-IT' AND Plant = 'YPO')
BEGIN
    -- We'll use a placeholder prefix that won't match any real MRP codes
    -- This allows D-IT to appear in the goals settings
    INSERT INTO dbo.MRPControllerLineMapping (CodePrefix, LineName, Plant, Description, IsActive, CreatedBy)
    VALUES ('Z', 'D-IT', 'YPO', 'D-IT line for manual scrap goal tracking', 1, 'System');
    
    PRINT 'Added D-IT line mapping.';
END
ELSE
BEGIN
    PRINT 'D-IT already exists in mapping.';
END
GO

-- Verify the changes
SELECT * FROM dbo.MRPControllerLineMapping WHERE Plant = 'YPO' ORDER BY LineName;
GO

PRINT '';
PRINT 'MRP Controller Line Mapping updated successfully!';
