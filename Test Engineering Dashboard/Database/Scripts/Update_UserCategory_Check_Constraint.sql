-- Update CHECK constraint for Users.UserCategory to allow: Admin, Test Engineering, Quality, Tester, Viewer
-- Safe pattern: drop existing constraint (if present) and recreate with desired allowed values
-- Database: TestEngineering
-- Created: 2025-10-01

USE TestEngineering;
GO

PRINT 'Locating existing CHECK constraint on dbo.Users.UserCategory...';

DECLARE @schema sysname = N'dbo';
DECLARE @table  sysname = N'Users';
DECLARE @column sysname = N'UserCategory';
DECLARE @constraintName sysname;

SELECT TOP 1 @constraintName = cc.name
FROM sys.check_constraints cc
JOIN sys.columns c ON cc.parent_object_id = c.object_id AND cc.parent_column_id = c.column_id
JOIN sys.tables t ON t.object_id = cc.parent_object_id
WHERE t.name = @table AND c.name = @column AND SCHEMA_NAME(t.schema_id) = @schema;

IF @constraintName IS NOT NULL
BEGIN
    DECLARE @dropSql nvarchar(max) = N'ALTER TABLE [' + @schema + N'].[' + @table + N'] DROP CONSTRAINT [' + @constraintName + N']';
    PRINT 'Dropping existing constraint: ' + @constraintName;
    EXEC sp_executesql @dropSql;
END
ELSE
BEGIN
    PRINT 'No existing constraint found on dbo.Users.UserCategory.';
END

PRINT 'Creating new CHECK constraint allowing desired categories...';

ALTER TABLE [dbo].[Users]
ADD CONSTRAINT [CK_Users_UserCategory_Allowed]
CHECK ([UserCategory] IN (N'Admin', N'Test Engineering', N'Quality', N'Tester', N'Viewer'));

PRINT 'Constraint updated successfully.';
GO
