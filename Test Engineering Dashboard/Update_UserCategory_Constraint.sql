-- =============================================
-- Remove CHECK Constraint on Users.UserCategory
-- This permanently removes the constraint so you can add
-- new user categories in the future without conflicts
-- =============================================

-- Find and drop the existing CHECK constraint
DECLARE @ConstraintName NVARCHAR(200);
SELECT @ConstraintName = name 
FROM sys.check_constraints 
WHERE parent_object_id = OBJECT_ID('dbo.Users') 
  AND COL_NAME(parent_object_id, parent_column_id) = 'UserCategory';

IF @ConstraintName IS NOT NULL
BEGIN
    DECLARE @SQL NVARCHAR(500);
    SET @SQL = 'ALTER TABLE dbo.Users DROP CONSTRAINT ' + QUOTENAME(@ConstraintName);
    EXEC sp_executesql @SQL;
    PRINT 'Successfully dropped constraint: ' + @ConstraintName;
    PRINT 'UserCategory column is now unrestricted - you can add any categories in the future.';
END
ELSE
BEGIN
    PRINT 'No CHECK constraint found on UserCategory column - no action needed.';
END

GO

-- Verification: Confirm the constraint has been removed
IF NOT EXISTS (
    SELECT 1 
    FROM sys.check_constraints 
    WHERE parent_object_id = OBJECT_ID('dbo.Users') 
      AND COL_NAME(parent_object_id, parent_column_id) = 'UserCategory'
)
BEGIN
    PRINT 'Verified: UserCategory CHECK constraint has been successfully removed.';
END
ELSE
BEGIN
    PRINT 'Warning: CHECK constraint still exists.';
END
