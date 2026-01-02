-- =============================================
-- KPI Enhancement Migration Script
-- Test Engineering Dashboard
-- Database: TestEngineering
-- Created: October 2, 2025
-- Purpose: Add columns and computed fields to support KPI calculations
-- =============================================

USE TestEngineering;
GO

PRINT '========================================';
PRINT 'Starting KPI Enhancement Migration';
PRINT 'Database: TestEngineering';
PRINT 'Date: ' + CONVERT(varchar, GETDATE(), 120);
PRINT '========================================';
GO

-- =============================================
-- 1. CALIBRATION_LOG ENHANCEMENTS
-- =============================================
PRINT '';
PRINT 'Updating Calibration_Log table...';

-- Lifecycle date columns
IF COL_LENGTH('dbo.Calibration_Log','PrevDueDate') IS NULL
BEGIN
    ALTER TABLE dbo.Calibration_Log ADD PrevDueDate datetime NULL;
    PRINT '  + Added PrevDueDate column';
END
GO

IF COL_LENGTH('dbo.Calibration_Log','StartDate') IS NULL
BEGIN
    ALTER TABLE dbo.Calibration_Log ADD StartDate datetime NULL;
    PRINT '  + Added StartDate column';
END
GO

IF COL_LENGTH('dbo.Calibration_Log','SentOutDate') IS NULL
BEGIN
    ALTER TABLE dbo.Calibration_Log ADD SentOutDate datetime NULL;
    PRINT '  + Added SentOutDate column';
END
GO

IF COL_LENGTH('dbo.Calibration_Log','ReceivedDate') IS NULL
BEGIN
    ALTER TABLE dbo.Calibration_Log ADD ReceivedDate datetime NULL;
    PRINT '  + Added ReceivedDate column';
END
GO

IF COL_LENGTH('dbo.Calibration_Log','CompletedDate') IS NULL
BEGIN
    ALTER TABLE dbo.Calibration_Log ADD CompletedDate datetime NULL;
    PRINT '  + Added CompletedDate column';
END
GO

-- Normalized outcome and vendor columns
IF COL_LENGTH('dbo.Calibration_Log','ResultCode') IS NULL
BEGIN
    ALTER TABLE dbo.Calibration_Log ADD ResultCode nvarchar(20) NULL;
    PRINT '  + Added ResultCode column';
END
GO

IF COL_LENGTH('dbo.Calibration_Log','VendorName') IS NULL
BEGIN
    ALTER TABLE dbo.Calibration_Log ADD VendorName nvarchar(200) NULL;
    PRINT '  + Added VendorName column';
END
GO

IF COL_LENGTH('dbo.Calibration_Log','Method') IS NULL
BEGIN
    ALTER TABLE dbo.Calibration_Log ADD Method nvarchar(20) NULL CONSTRAINT DF_CalLog_Method DEFAULT ('Internal');
    PRINT '  + Added Method column with default Internal';
END
GO

-- Add first index (doesn't reference computed columns)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_CalLog_Equipment' AND object_id = OBJECT_ID('dbo.Calibration_Log'))
BEGIN
    CREATE INDEX IX_CalLog_Equipment ON dbo.Calibration_Log(EquipmentType, EquipmentID);
    PRINT '  + Created IX_CalLog_Equipment index';
END
GO

-- Now add computed columns (after base columns exist)
PRINT 'Adding Calibration_Log computed columns...';

IF COL_LENGTH('dbo.Calibration_Log','CompletedOn') IS NULL
BEGIN
    ALTER TABLE dbo.Calibration_Log ADD CompletedOn AS (COALESCE([CompletedDate],[CalibrationDate])) PERSISTED;
    PRINT '  + Added CompletedOn computed column';
END

IF COL_LENGTH('dbo.Calibration_Log','IsOnTime') IS NULL
BEGIN
    ALTER TABLE dbo.Calibration_Log ADD IsOnTime AS (
        CASE WHEN [PrevDueDate] IS NULL OR COALESCE([CompletedDate],[CalibrationDate]) IS NULL THEN NULL
             WHEN COALESCE([CompletedDate],[CalibrationDate]) <= [PrevDueDate] THEN CONVERT(bit,1) 
             ELSE CONVERT(bit,0) END
    ) PERSISTED;
    PRINT '  + Added IsOnTime computed column';
END

IF COL_LENGTH('dbo.Calibration_Log','IsOutOfTolerance') IS NULL
BEGIN
    ALTER TABLE dbo.Calibration_Log ADD IsOutOfTolerance AS (
        CASE WHEN UPPER(ISNULL([ResultCode],'')) IN (N'FAIL',N'OOT') THEN CONVERT(bit,1) 
             ELSE CONVERT(bit,0) END
    ) PERSISTED;
    PRINT '  + Added IsOutOfTolerance computed column';
END

IF COL_LENGTH('dbo.Calibration_Log','TurnaroundDays') IS NULL
BEGIN
    ALTER TABLE dbo.Calibration_Log ADD TurnaroundDays AS (
        CASE WHEN [StartDate] IS NULL OR COALESCE([CompletedDate],[CalibrationDate]) IS NULL THEN NULL
             ELSE DATEDIFF(day,[StartDate],COALESCE([CompletedDate],[CalibrationDate])) END
    ) PERSISTED;
    PRINT '  + Added TurnaroundDays computed column';
END

IF COL_LENGTH('dbo.Calibration_Log','VendorLeadDays') IS NULL
BEGIN
    ALTER TABLE dbo.Calibration_Log ADD VendorLeadDays AS (
        CASE WHEN [SentOutDate] IS NULL OR [ReceivedDate] IS NULL THEN NULL
             ELSE DATEDIFF(day,[SentOutDate],[ReceivedDate]) END
    ) PERSISTED;
    PRINT '  + Added VendorLeadDays computed column';
END
GO

-- Add index that references computed column (after computed column exists)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_CalLog_CompletedOn' AND object_id = OBJECT_ID('dbo.Calibration_Log'))
BEGIN
    CREATE INDEX IX_CalLog_CompletedOn ON dbo.Calibration_Log(CompletedOn) 
        INCLUDE (EquipmentType, EquipmentID, ResultCode, IsOutOfTolerance, Cost);
    PRINT '  + Created IX_CalLog_CompletedOn index';
END
GO

-- Add check constraints (after all base columns exist)
PRINT 'Adding Calibration_Log CHECK constraints...';

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_CalLog_Method')
BEGIN
    ALTER TABLE dbo.Calibration_Log WITH NOCHECK
    ADD CONSTRAINT CK_CalLog_Method CHECK ([Method] IN ('Internal','External'));
    PRINT '  + Added Method CHECK constraint';
END

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_CalLog_ResultCode')
BEGIN
    ALTER TABLE dbo.Calibration_Log WITH NOCHECK
    ADD CONSTRAINT CK_CalLog_ResultCode CHECK ([ResultCode] IN ('Pass','Fail','OOT','Adjusted','As Found Pass','As Left Pass'));
    PRINT '  + Added ResultCode CHECK constraint';
END

PRINT 'Calibration_Log updates complete.';
GO

-- =============================================
-- 2. PM_LOG ENHANCEMENTS
-- =============================================
PRINT '';
PRINT 'Updating PM_Log table...';

IF COL_LENGTH('dbo.PM_Log','DueDate') IS NULL
BEGIN
    ALTER TABLE dbo.PM_Log ADD DueDate datetime NULL;
    PRINT '  + Added DueDate column';
END
GO

IF COL_LENGTH('dbo.PM_Log','ScheduledDate') IS NULL
BEGIN
    ALTER TABLE dbo.PM_Log ADD ScheduledDate datetime NULL;
    PRINT '  + Added ScheduledDate column';
END
GO

IF COL_LENGTH('dbo.PM_Log','ActualStartTime') IS NULL
BEGIN
    ALTER TABLE dbo.PM_Log ADD ActualStartTime datetime NULL;
    PRINT '  + Added ActualStartTime column';
END
GO

IF COL_LENGTH('dbo.PM_Log','ActualEndTime') IS NULL
BEGIN
    ALTER TABLE dbo.PM_Log ADD ActualEndTime datetime NULL;
    PRINT '  + Added ActualEndTime column';
END
GO

IF COL_LENGTH('dbo.PM_Log','EstimatedDuration') IS NULL
BEGIN
    ALTER TABLE dbo.PM_Log ADD EstimatedDuration int NULL;
    PRINT '  + Added EstimatedDuration column (minutes)';
END
GO

IF COL_LENGTH('dbo.PM_Log','Downtime') IS NULL
BEGIN
    ALTER TABLE dbo.PM_Log ADD Downtime int NULL;
    PRINT '  + Added Downtime column (minutes)';
END
GO

-- Add indexes for KPI queries
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_PMLog_Equipment' AND object_id = OBJECT_ID('dbo.PM_Log'))
BEGIN
    CREATE INDEX IX_PMLog_Equipment ON dbo.PM_Log(EquipmentType, EquipmentID);
    PRINT '  + Created IX_PMLog_Equipment index';
END

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_PMLog_PMDate' AND object_id = OBJECT_ID('dbo.PM_Log'))
BEGIN
    CREATE INDEX IX_PMLog_PMDate ON dbo.PM_Log(PMDate) 
        INCLUDE (EquipmentType, Status, Cost);
    PRINT '  + Created IX_PMLog_PMDate index';
END

-- Add computed columns (after base columns exist)
PRINT 'Adding PM_Log computed columns...';

IF COL_LENGTH('dbo.PM_Log','ActualDuration') IS NULL
BEGIN
    ALTER TABLE dbo.PM_Log ADD ActualDuration AS (
        DATEDIFF(minute, [ActualStartTime], [ActualEndTime])
    ) PERSISTED;
    PRINT '  + Added ActualDuration computed column';
END

IF COL_LENGTH('dbo.PM_Log','IsOnTime') IS NULL
BEGIN
    ALTER TABLE dbo.PM_Log ADD IsOnTime AS (
        CASE WHEN [DueDate] IS NULL OR [PMDate] IS NULL THEN NULL
             WHEN [PMDate] <= [DueDate] THEN CONVERT(bit,1) 
             ELSE CONVERT(bit,0) END
    ) PERSISTED;
    PRINT '  + Added IsOnTime computed column';
END

PRINT 'PM_Log updates complete.';
GO

-- =============================================
-- 3. TROUBLESHOOTING_LOG ENHANCEMENTS
-- =============================================
PRINT '';
PRINT 'Updating Troubleshooting_Log table...';

IF COL_LENGTH('dbo.Troubleshooting_Log','EquipmentType') IS NULL
BEGIN
    ALTER TABLE dbo.Troubleshooting_Log ADD EquipmentType nvarchar(50) NULL;
    PRINT '  + Added EquipmentType column';
END
GO

IF COL_LENGTH('dbo.Troubleshooting_Log','EquipmentEatonID') IS NULL
BEGIN
    ALTER TABLE dbo.Troubleshooting_Log ADD EquipmentEatonID nvarchar(50) NULL;
    PRINT '  + Added EquipmentEatonID column';
END
GO

IF COL_LENGTH('dbo.Troubleshooting_Log','IsRepeat') IS NULL
BEGIN
    ALTER TABLE dbo.Troubleshooting_Log ADD IsRepeat bit DEFAULT 0;
    PRINT '  + Added IsRepeat column';
END
GO

IF COL_LENGTH('dbo.Troubleshooting_Log','DowntimeHours') IS NULL
BEGIN
    ALTER TABLE dbo.Troubleshooting_Log ADD DowntimeHours decimal(10,2) NULL;
    PRINT '  + Added DowntimeHours column';
END
GO

IF COL_LENGTH('dbo.Troubleshooting_Log','ImpactLevel') IS NULL
BEGIN
    ALTER TABLE dbo.Troubleshooting_Log ADD ImpactLevel nvarchar(20) NULL;
    PRINT '  + Added ImpactLevel column';
END
GO

-- Add index
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_TroubleLog_Priority_Status' AND object_id = OBJECT_ID('dbo.Troubleshooting_Log'))
BEGIN
    CREATE INDEX IX_TroubleLog_Priority_Status ON dbo.Troubleshooting_Log(Priority, Status)
        INCLUDE (ReportedDateTime, ResolvedDateTime, IssueClassification);
    PRINT '  + Created IX_TroubleLog_Priority_Status index';
END

-- Add computed columns (after base columns exist)
PRINT 'Adding Troubleshooting_Log computed columns...';

IF COL_LENGTH('dbo.Troubleshooting_Log','ResolutionTimeHours') IS NULL
BEGIN
    ALTER TABLE dbo.Troubleshooting_Log ADD ResolutionTimeHours AS (
        CAST(DATEDIFF(MINUTE, [ReportedDateTime], [ResolvedDateTime]) AS DECIMAL(10,2)) / 60.0
    ) PERSISTED;
    PRINT '  + Added ResolutionTimeHours computed column (with decimal precision)';
END
ELSE
BEGIN
    -- If column exists but has wrong definition, need to drop and recreate
    -- Check if it's the old integer version
    PRINT '  ! ResolutionTimeHours column already exists - may need manual update';
    PRINT '  ! To fix precision: DROP column, then re-run this script';
    PRINT '  ! Command: ALTER TABLE dbo.Troubleshooting_Log DROP COLUMN ResolutionTimeHours;';
END

IF COL_LENGTH('dbo.Troubleshooting_Log','IsResolved') IS NULL
BEGIN
    ALTER TABLE dbo.Troubleshooting_Log ADD IsResolved AS (
        CASE WHEN [Status] IN ('Resolved','Closed') THEN CONVERT(bit,1) 
             ELSE CONVERT(bit,0) END
    ) PERSISTED;
    PRINT '  + Added IsResolved computed column';
END

-- Add check constraint (after base columns exist)
PRINT 'Adding Troubleshooting_Log CHECK constraint...';

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_TroubleLog_ImpactLevel')
BEGIN
    ALTER TABLE dbo.Troubleshooting_Log WITH NOCHECK
    ADD CONSTRAINT CK_TroubleLog_ImpactLevel CHECK ([ImpactLevel] IN ('None','Minor','Moderate','Major','Critical'));
    PRINT '  + Added ImpactLevel CHECK constraint';
END

PRINT 'Troubleshooting_Log updates complete.';
GO

-- =============================================
-- 4. COMPUTER_INVENTORY ENHANCEMENTS
-- =============================================
PRINT '';
PRINT 'Updating Computer_Inventory table...';

IF COL_LENGTH('dbo.Computer_Inventory','HasOpenITTask') IS NULL
BEGIN
    ALTER TABLE dbo.Computer_Inventory ADD HasOpenITTask bit DEFAULT 0;
    PRINT '  + Added HasOpenITTask column';
END

IF COL_LENGTH('dbo.Computer_Inventory','HasOpenTestEngTask') IS NULL
BEGIN
    ALTER TABLE dbo.Computer_Inventory ADD HasOpenTestEngTask bit DEFAULT 0;
    PRINT '  + Added HasOpenTestEngTask column';
END

IF COL_LENGTH('dbo.Computer_Inventory','LastMaintenanceDate') IS NULL
BEGIN
    ALTER TABLE dbo.Computer_Inventory ADD LastMaintenanceDate datetime NULL;
    PRINT '  + Added LastMaintenanceDate column';
END

IF COL_LENGTH('dbo.Computer_Inventory','OSVersion') IS NULL
BEGIN
    ALTER TABLE dbo.Computer_Inventory ADD OSVersion nvarchar(100) NULL;
    PRINT '  + Added OSVersion column';
END

IF COL_LENGTH('dbo.Computer_Inventory','PurchaseDate') IS NULL
BEGIN
    ALTER TABLE dbo.Computer_Inventory ADD PurchaseDate datetime NULL;
    PRINT '  + Added PurchaseDate column';
END

IF COL_LENGTH('dbo.Computer_Inventory','WarrantyExpiration') IS NULL
BEGIN
    ALTER TABLE dbo.Computer_Inventory ADD WarrantyExpiration datetime NULL;
    PRINT '  + Added WarrantyExpiration column';
END

-- Add indexes
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Computer_TaskFlags' AND object_id = OBJECT_ID('dbo.Computer_Inventory'))
BEGIN
    CREATE INDEX IX_Computer_TaskFlags ON dbo.Computer_Inventory(HasOpenITTask, HasOpenTestEngTask)
        INCLUDE (ComputerName, CurrentStatus);
    PRINT '  + Created IX_Computer_TaskFlags index';
END

PRINT 'Computer_Inventory updates complete.';
GO

-- =============================================
-- 5. TESTSTATION_BAY ENHANCEMENTS
-- =============================================
PRINT '';
PRINT 'Updating TestStation_Bay table...';

IF COL_LENGTH('dbo.TestStation_Bay','StationType') IS NULL
BEGIN
    ALTER TABLE dbo.TestStation_Bay ADD StationType nvarchar(50) NULL;
    PRINT '  + Added StationType column';
END

IF COL_LENGTH('dbo.TestStation_Bay','Capacity') IS NULL
BEGIN
    ALTER TABLE dbo.TestStation_Bay ADD Capacity int NULL;
    PRINT '  + Added Capacity column';
END

IF COL_LENGTH('dbo.TestStation_Bay','CurrentUtilization') IS NULL
BEGIN
    ALTER TABLE dbo.TestStation_Bay ADD CurrentUtilization decimal(5,2) NULL;
    PRINT '  + Added CurrentUtilization column';
END

IF COL_LENGTH('dbo.TestStation_Bay','IsOperational') IS NULL
BEGIN
    ALTER TABLE dbo.TestStation_Bay ADD IsOperational bit DEFAULT 1;
    PRINT '  + Added IsOperational column';
END

IF COL_LENGTH('dbo.TestStation_Bay','LastDowntime') IS NULL
BEGIN
    ALTER TABLE dbo.TestStation_Bay ADD LastDowntime datetime NULL;
    PRINT '  + Added LastDowntime column';
END

PRINT 'TestStation_Bay updates complete.';
GO

-- =============================================
-- 6. ACCOUNTREQUESTS ENHANCEMENTS (if table exists)
-- =============================================
IF OBJECT_ID('dbo.AccountRequests', 'U') IS NOT NULL
BEGIN
    PRINT '';
    PRINT 'Updating AccountRequests table...';
    PRINT '  Note: Table already has SubmittedAt, ReviewedAt, ReviewedBy columns';

    IF COL_LENGTH('dbo.AccountRequests','ReviewTimeHours') IS NULL
    BEGIN
        ALTER TABLE dbo.AccountRequests ADD ReviewTimeHours AS (
            DATEDIFF(hour, [SubmittedAt], [ReviewedAt])
        ) PERSISTED;
        PRINT '  + Added ReviewTimeHours computed column';
    END

    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_AccountReq_Status' AND object_id = OBJECT_ID('dbo.AccountRequests'))
    BEGIN
        CREATE INDEX IX_AccountReq_Status ON dbo.AccountRequests(Status)
            INCLUDE (SubmittedAt, ReviewedAt);
        PRINT '  + Created IX_AccountReq_Status index';
    END

    PRINT 'AccountRequests updates complete.';
END
ELSE
BEGIN
    PRINT '';
    PRINT 'AccountRequests table not found - skipping.';
END
GO

-- =============================================
-- 7. USERS TABLE ENHANCEMENTS
-- =============================================
PRINT '';
PRINT 'Checking Users table...';
PRINT '  Note: Users table already has Department, JobRole, ModifiedDate, ModifiedBy columns';
PRINT '  No changes needed - table is already complete for KPIs.';

-- Add index if missing
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Users_IsActive_Category' AND object_id = OBJECT_ID('dbo.Users'))
BEGIN
    CREATE INDEX IX_Users_IsActive_Category ON dbo.Users(IsActive, UserCategory)
        INCLUDE (CreatedDate, LastLoginDate);
    PRINT '  + Created IX_Users_IsActive_Category index';
END
ELSE
BEGIN
    PRINT '  Index IX_Users_IsActive_Category already exists.';
END

PRINT 'Users table check complete.';
GO

-- =============================================
-- 8. ADD CHECK CONSTRAINTS (AFTER ALL COLUMNS EXIST)
-- =============================================
PRINT '';
PRINT '========================================';
PRINT 'Adding CHECK Constraints...';
PRINT '========================================';

-- TestStation_Bay CHECK constraint
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_TestStation_StationType')
BEGIN
    ALTER TABLE dbo.TestStation_Bay WITH NOCHECK
    ADD CONSTRAINT CK_TestStation_StationType CHECK ([StationType] IN ('Manual','Automated','Semi-Automated'));
    PRINT '  + Added TestStation_Bay.StationType CHECK constraint';
END
ELSE
BEGIN
    PRINT '  TestStation_Bay.StationType CHECK constraint already exists.';
END

PRINT 'All CHECK constraints added.';

-- =============================================
-- MIGRATION COMPLETE
-- =============================================
PRINT '';
PRINT '========================================';
PRINT 'KPI Enhancement Migration Complete!';
PRINT 'Date: ' + CONVERT(varchar, GETDATE(), 120);
PRINT '========================================';
PRINT '';
PRINT 'Next steps:';
PRINT '1. Run Add_KPI_Views.sql to create KPI calculation views';
PRINT '2. Update application code to populate new columns';
PRINT '3. Build dashboard pages to display KPI cards';
GO
