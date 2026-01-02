# 🗄️ SQL Requirements for Calibration Dashboard

## Required SQL Script Execution

### **IMPORTANT:** Run this script before accessing the dashboard

Execute the file: `Database/Calibration_Dashboard_Enhanced_KPIs.sql`

This script will:
1. ✅ Create `vw_CalibrationKPIs` view with all required metrics
2. ✅ Create performance indexes for fast queries
3. ✅ Optimize dashboard data retrieval

---

## Pre-Execution Checklist

Before running the SQL script, verify:

### 1. ✅ Table Exists with Required Columns
```sql
-- Check if Calibration_Log table exists
SELECT * FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_NAME = 'Calibration_Log';

-- Check required columns exist
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Calibration_Log'
ORDER BY ORDINAL_POSITION;
```

**Required Columns:**
- `CalibrationID` (int, Primary Key)
- `EquipmentType` (nvarchar)
- `EquipmentID` (nvarchar)
- `EquipmentEatonID` (nvarchar)
- `EquipmentName` (nvarchar)
- `NextDueDate` (datetime)
- `CalibrationDate` (datetime)
- `CompletedDate` (datetime)
- `Status` (nvarchar)
- `Method` (nvarchar)
- `VendorName` (nvarchar)
- `ResultCode` (nvarchar)
- `Cost` (decimal)

### 2. ✅ Computed Columns Exist
These should already exist from the original implementation:
```sql
-- Check computed columns
SELECT name, definition 
FROM sys.computed_columns 
WHERE object_id = OBJECT_ID('dbo.Calibration_Log');
```

**Expected Computed Columns:**
- `CompletedOn` - COALESCE(CompletedDate, CalibrationDate)
- `IsOnTime` - Whether completed by due date (1/0)
- `IsOutOfTolerance` - Whether result is FAIL or OOT (1/0)
- `TurnaroundDays` - Days from start to completion
- `VendorLeadDays` - Days from sent to received

### 3. ✅ Sample Data Exists
```sql
-- Verify data exists for testing
SELECT 
    COUNT(*) as TotalRecords,
    COUNT(CASE WHEN CompletedOn >= DATEADD(month, -12, GETDATE()) THEN 1 END) as Last12Months,
    COUNT(CASE WHEN NextDueDate IS NOT NULL THEN 1 END) as WithDueDate
FROM dbo.Calibration_Log;
```

**Minimum Requirements:**
- At least 10 total records
- At least 5 records in last 12 months
- At least 3 records with NextDueDate

---

## SQL Script Execution Steps

### Step 1: Open SQL Server Management Studio
1. Connect to your Test Engineering database server
2. Select the `TestEngineering` database (or your database name)
3. Open a new query window

### Step 2: Load the SQL Script
```sql
-- File: Database/Calibration_Dashboard_Enhanced_KPIs.sql
-- Location: Test Engineering Dashboard/Database/

-- Copy and paste the entire script, or use:
-- File → Open → Select the .sql file
```

### Step 3: Execute the Script
1. Click "Execute" button (or press F5)
2. Wait for completion (should take < 5 seconds)
3. Check "Messages" tab for success confirmation

### Expected Output:
```
Enhanced vw_CalibrationKPIs view created successfully!
Index IX_Calibration_Log_NextDueDate_Status created.
Index IX_Calibration_Log_CompletedOn created.
All indexes verified/created successfully!
```

---

## Post-Execution Verification

### Test 1: Verify View Returns Data
```sql
-- Should return 1 row with all KPI values
SELECT * FROM dbo.vw_CalibrationKPIs;
```

**Expected Columns:**
- `OverdueCount` (int)
- `DueNext7Days` (int)
- `DueNext30Days` (int)
- `TotalActive` (int)
- `TotalCalibrations` (int)
- `OnTimeCount` (int)
- `OOTCount` (int)
- `OnTimeRatePercent` (decimal)
- `OOTRatePercent` (decimal)
- `AvgTurnaroundDays` (decimal)
- `TotalCost12Mo` (decimal)
- `AvgCost12Mo` (decimal)
- `ThisMonthCalibrations` (int)
- `ThisMonthCost` (decimal)

### Test 2: Verify Indexes Were Created
```sql
-- Should return at least 2 indexes
SELECT 
    i.name as IndexName,
    i.type_desc as IndexType,
    COL_NAME(ic.object_id, ic.column_id) as ColumnName
FROM sys.indexes i
INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
WHERE i.object_id = OBJECT_ID('dbo.Calibration_Log')
  AND i.name LIKE 'IX_Calibration_Log_%'
ORDER BY i.name, ic.key_ordinal;
```

**Expected Indexes:**
1. `IX_Calibration_Log_NextDueDate_Status`
   - Columns: NextDueDate, Status
   - Includes: EquipmentEatonID, EquipmentName, EquipmentType
2. `IX_Calibration_Log_CompletedOn`
   - Columns: CompletedOn
   - Includes: EquipmentType, Method, VendorName, etc.

### Test 3: Performance Check
```sql
-- Each query should complete in < 50ms
SET STATISTICS TIME ON;

-- Test KPI view
SELECT * FROM dbo.vw_CalibrationKPIs;

-- Test upcoming calibrations query
SELECT TOP 15
    EquipmentEatonID, EquipmentName, EquipmentType, NextDueDate
FROM dbo.Calibration_Log
WHERE NextDueDate <= DATEADD(day, 90, CAST(GETDATE() AS date))
  AND (Status IS NULL OR Status NOT IN ('Completed', 'Cancelled'))
ORDER BY NextDueDate ASC;

-- Test monthly volume query
SELECT TOP 12 
    DATENAME(month, CompletedOn) + ' ' + CAST(YEAR(CompletedOn) AS VARCHAR) as MonthYear,
    COUNT(*) as Total
FROM dbo.Calibration_Log
WHERE CompletedOn >= DATEADD(month, -12, GETDATE())
  AND CompletedOn IS NOT NULL
GROUP BY YEAR(CompletedOn), MONTH(CompletedOn), DATENAME(month, CompletedOn)
ORDER BY YEAR(CompletedOn), MONTH(CompletedOn);

SET STATISTICS TIME OFF;
```

---

## Troubleshooting

### Error: "Invalid object name 'dbo.Calibration_Log'"
**Cause:** Table doesn't exist or wrong database selected  
**Fix:**
```sql
-- Check current database
SELECT DB_NAME();

-- Switch to correct database
USE TestEngineering;
GO
```

### Error: "Invalid column name 'CompletedOn'"
**Cause:** Computed columns not created yet  
**Fix:** Run the original `Calibration_Dashboard_SQL_Implementation.sql` first, then run the enhanced script.

### Error: "There is already an object named 'vw_CalibrationKPIs'"
**Cause:** View already exists (not an error - script uses CREATE OR ALTER)  
**Fix:** No action needed - script will update the existing view.

### Warning: Index already exists
**Cause:** Indexes were created previously  
**Fix:** No action needed - script checks for existence before creating.

### Performance: Queries taking > 1 second
**Cause:** Missing indexes or large data volume  
**Fix:**
```sql
-- Rebuild indexes
ALTER INDEX IX_Calibration_Log_NextDueDate_Status ON dbo.Calibration_Log REBUILD;
ALTER INDEX IX_Calibration_Log_CompletedOn ON dbo.Calibration_Log REBUILD;

-- Update statistics
UPDATE STATISTICS dbo.Calibration_Log;
```

---

## Alternative: Manual View Creation

If you prefer to create the view manually without running the script:

```sql
USE [TestEngineering];
GO

CREATE OR ALTER VIEW vw_CalibrationKPIs AS
WITH CurrentStats AS (
    SELECT
        COUNT(CASE WHEN NextDueDate < CAST(GETDATE() AS date) 
                       AND (Status IS NULL OR Status NOT IN ('Completed', 'Cancelled')) 
                  THEN 1 END) as OverdueCount,
        COUNT(CASE WHEN NextDueDate >= CAST(GETDATE() AS date)
                       AND NextDueDate <= DATEADD(day, 7, CAST(GETDATE() AS date))
                       AND (Status IS NULL OR Status NOT IN ('Completed', 'Cancelled'))
                  THEN 1 END) as DueNext7Days,
        COUNT(CASE WHEN NextDueDate >= CAST(GETDATE() AS date)
                       AND NextDueDate <= DATEADD(day, 30, CAST(GETDATE() AS date))
                       AND (Status IS NULL OR Status NOT IN ('Completed', 'Cancelled'))
                  THEN 1 END) as DueNext30Days,
        COUNT(CASE WHEN Status IS NULL OR Status NOT IN ('Completed', 'Cancelled') 
                  THEN 1 END) as TotalActive
    FROM dbo.Calibration_Log
),
Last12Months AS (
    SELECT
        COUNT(*) as TotalCalibrations,
        SUM(CASE WHEN IsOnTime = 1 THEN 1 ELSE 0 END) as OnTimeCount,
        SUM(CASE WHEN IsOutOfTolerance = 1 THEN 1 ELSE 0 END) as OOTCount,
        AVG(CAST(TurnaroundDays AS float)) as AvgTurnaroundDays,
        SUM(CAST(ISNULL(Cost, 0) AS decimal(10,2))) as TotalCost,
        AVG(CAST(ISNULL(Cost, 0) AS decimal(10,2))) as AvgCost
    FROM dbo.Calibration_Log
    WHERE CompletedOn >= DATEADD(month, -12, GETDATE())
      AND CompletedOn IS NOT NULL
),
ThisMonth AS (
    SELECT
        COUNT(*) as ThisMonthCalibrations,
        SUM(CAST(ISNULL(Cost, 0) AS decimal(10,2))) as ThisMonthCost
    FROM dbo.Calibration_Log
    WHERE CompletedOn >= DATEADD(day, -DAY(GETDATE())+1, CAST(GETDATE() AS date))
      AND CompletedOn < DATEADD(month, 1, DATEADD(day, -DAY(GETDATE())+1, CAST(GETDATE() AS date)))
)
SELECT
    cs.OverdueCount,
    cs.DueNext7Days,
    cs.DueNext30Days,
    cs.TotalActive,
    lm.TotalCalibrations,
    lm.OnTimeCount,
    lm.OOTCount,
    CASE WHEN lm.TotalCalibrations > 0
         THEN CAST((CAST(lm.OnTimeCount AS float) / CAST(lm.TotalCalibrations AS float)) * 100 AS decimal(5,2))
         ELSE 0 END as OnTimeRatePercent,
    CASE WHEN lm.TotalCalibrations > 0
         THEN CAST((CAST(lm.OOTCount AS float) / CAST(lm.TotalCalibrations AS float)) * 100 AS decimal(5,2))
         ELSE 0 END as OOTRatePercent,
    CAST(ISNULL(lm.AvgTurnaroundDays, 0) AS decimal(5,1)) as AvgTurnaroundDays,
    CAST(ISNULL(lm.TotalCost, 0) AS decimal(12,2)) as TotalCost12Mo,
    CAST(ISNULL(lm.AvgCost, 0) AS decimal(10,2)) as AvgCost12Mo,
    tm.ThisMonthCalibrations,
    CAST(ISNULL(tm.ThisMonthCost, 0) AS decimal(12,2)) as ThisMonthCost
FROM CurrentStats cs
CROSS JOIN Last12Months lm
CROSS JOIN ThisMonth tm;
GO
```

---

## Maintenance Schedule

### Daily (Automatic)
- SQL Server query cache optimization
- Automatic statistics updates

### Weekly
```sql
-- Update table statistics for better query plans
UPDATE STATISTICS dbo.Calibration_Log WITH FULLSCAN;
```

### Monthly
```sql
-- Rebuild indexes to remove fragmentation
ALTER INDEX IX_Calibration_Log_NextDueDate_Status 
ON dbo.Calibration_Log REBUILD WITH (ONLINE = ON);

ALTER INDEX IX_Calibration_Log_CompletedOn 
ON dbo.Calibration_Log REBUILD WITH (ONLINE = ON);
```

### Quarterly
- Review view definition for new requirements
- Analyze query performance and adjust indexes
- Archive old data (optional, if table > 50k rows)

---

## Data Archiving (Optional)

If your Calibration_Log table grows very large (>100k rows), consider archiving:

```sql
-- Create archive table (one-time)
SELECT TOP 0 * INTO dbo.Calibration_Log_Archive FROM dbo.Calibration_Log;

-- Move records older than 2 years to archive (run annually)
INSERT INTO dbo.Calibration_Log_Archive
SELECT * FROM dbo.Calibration_Log
WHERE CompletedOn < DATEADD(year, -2, GETDATE());

DELETE FROM dbo.Calibration_Log
WHERE CompletedOn < DATEADD(year, -2, GETDATE());

-- Rebuild indexes after archiving
ALTER INDEX ALL ON dbo.Calibration_Log REBUILD;
```

---

## Summary Checklist

Before using the dashboard:

- [ ] SQL script executed successfully
- [ ] `vw_CalibrationKPIs` view created
- [ ] Indexes created on NextDueDate and CompletedOn
- [ ] View returns 1 row with data
- [ ] Test queries complete in < 100ms
- [ ] No SQL errors in Messages pane

After SQL setup:

- [ ] Navigate to CalibrationDashboard.aspx
- [ ] Verify all 5 KPIs display values
- [ ] Verify all 5 charts render
- [ ] Verify upcoming calibrations list populates
- [ ] Dashboard loads in < 2 seconds

---

**Script Location:** `Test Engineering Dashboard/Database/Calibration_Dashboard_Enhanced_KPIs.sql`  
**Execution Time:** ~5 seconds  
**Database:** TestEngineering  
**Required Permissions:** CREATE VIEW, CREATE INDEX
