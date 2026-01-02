# Calibration System - Common SQL Errors and Solutions

## Error: "Invalid column name 'RequiredCalibration'" (and related calibration columns)

### Symptoms
When running `Create_vw_Equipment_RequireCalibration.sql`, you see multiple errors like:
```
Msg 207, Level 16, State 1, Procedure vw_Equipment_RequireCalibration, Line XX
Invalid column name 'RequiredCalibration'.
Invalid column name 'CalibrationFrequency'.
Invalid column name 'CalibrationResponsible'.
Invalid column name 'LastCalibration'.
Invalid column name 'LastCalibrationBy'.
Invalid column name 'CalibrationBy'.
Invalid column name 'NextCalibration'.
```

### Root Cause
The equipment inventory tables (ATE_Inventory, Asset_Inventory, Fixture_Inventory, Harness_Inventory) don't have the calibration-related columns yet.

### Solution

**Step 1:** Run the prerequisite script first:
```sql
-- File: Database/Scripts/Add_Calibration_Columns_To_Equipment_Tables.sql
-- This adds all required calibration columns to equipment tables
```

This script adds these columns to all equipment tables:
- `RequiredCalibration` (BIT) - Flag for equipment requiring calibration
- `CalibrationFrequency` (NVARCHAR(50)) - How often (Monthly, Quarterly, Annually, etc.)
- `CalibrationResponsible` (NVARCHAR(100)) - Who is responsible
- `LastCalibration` (DATETIME) - Date of last calibration
- `LastCalibrationBy` or `CalibrationBy` (NVARCHAR(100)) - Who performed calibration
- `NextCalibration` (DATETIME) - When next calibration is due

**Step 2:** Verify columns were added:
```sql
SELECT TABLE_NAME, COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME IN ('ATE_Inventory', 'Asset_Inventory', 'Fixture_Inventory', 'Harness_Inventory')
  AND COLUMN_NAME IN ('RequiredCalibration', 'CalibrationFrequency', 'CalibrationResponsible', 
                      'LastCalibration', 'LastCalibrationBy', 'CalibrationBy', 'NextCalibration')
ORDER BY TABLE_NAME, COLUMN_NAME;
```

Expected: 24 rows total (6 columns × 4 tables, noting that ATE uses LastCalibrationBy while others use CalibrationBy)

**Step 3:** Now run the view creation script:
```sql
-- File: Database/Scripts/Create_vw_Equipment_RequireCalibration.sql
-- This should now succeed without errors
```

---

## Correct Script Execution Order

For a fresh installation, run scripts in this order:

### 1. Equipment Table Columns
```
Database/Scripts/Add_Calibration_Columns_To_Equipment_Tables.sql
```
**Purpose:** Adds calibration tracking columns to equipment inventory tables  
**Time:** ~10 seconds  
**Output:** "Calibration columns added successfully!"

### 2. Calibration_Log Table Columns
```
Database/Scripts/Add_Columns_To_Calibration_Log.sql
```
**Purpose:** Adds AttachmentsPath, EquipmentEatonID, EquipmentName to Calibration_Log  
**Time:** ~10 seconds  
**Output:** "Columns added successfully!"

### 3. Equipment View
```
Database/Scripts/Create_vw_Equipment_RequireCalibration.sql
```
**Purpose:** Creates unified view of all equipment requiring calibration  
**Time:** ~5 seconds  
**Output:** "View vw_Equipment_RequireCalibration created successfully!"

---

## Important Column Name Differences

### ATE_Inventory uses:
- `LastCalibrationBy` (not CalibrationBy)

### Asset_Inventory, Fixture_Inventory, Harness_Inventory use:
- `CalibrationBy` (not LastCalibrationBy)

The view normalizes these to `LastCalibrationBy` for consistency.

---

## After Installation: Mark Equipment for Calibration

Once all scripts are run, no equipment will show in the view until you mark it as requiring calibration:

```sql
-- Example: Mark ATE equipment for calibration
UPDATE dbo.ATE_Inventory
SET RequiredCalibration = 1,
    CalibrationFrequency = 'Annually',
    CalibrationResponsible = 'Test Engineering',
    NextCalibration = DATEADD(YEAR, 1, GETDATE())
WHERE ATEInventoryID = 1;  -- Your equipment ID

-- Example: Mark Asset for calibration
UPDATE dbo.Asset_Inventory
SET RequiredCalibration = 1,
    CalibrationFrequency = 'Quarterly',
    CalibrationResponsible = 'Metrology',
    NextCalibration = DATEADD(QUARTER, 1, GETDATE())
WHERE AssetID = 5;  -- Your asset ID

-- Verify equipment now appears in view
SELECT * FROM dbo.vw_Equipment_RequireCalibration;
```

---

## Validation Queries

### Check All Scripts Completed Successfully

```sql
-- 1. Check equipment tables have calibration columns
SELECT 
    TABLE_NAME,
    COUNT(COLUMN_NAME) as CalibrationColumns
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME IN ('ATE_Inventory', 'Asset_Inventory', 'Fixture_Inventory', 'Harness_Inventory')
  AND COLUMN_NAME IN ('RequiredCalibration', 'CalibrationFrequency', 'CalibrationResponsible', 
                      'LastCalibration', 'LastCalibrationBy', 'CalibrationBy', 'NextCalibration')
GROUP BY TABLE_NAME;
-- Expected: 4 rows, ATE should show 6 columns, others 6 columns each

-- 2. Check Calibration_Log has new columns
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Calibration_Log'
  AND COLUMN_NAME IN ('AttachmentsPath', 'EquipmentEatonID', 'EquipmentName');
-- Expected: 3 rows

-- 3. Check view exists
SELECT TABLE_NAME, TABLE_TYPE
FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_NAME = 'vw_Equipment_RequireCalibration';
-- Expected: 1 row

-- 4. Check view returns data (after marking equipment)
SELECT COUNT(*) as EquipmentRequiringCalibration
FROM dbo.vw_Equipment_RequireCalibration;
-- Expected: Number of equipment items marked with RequiredCalibration = 1
```

---

## Rollback Instructions

If you need to remove the calibration system:

```sql
-- WARNING: This removes all calibration data!

-- Drop the view
IF OBJECT_ID('dbo.vw_Equipment_RequireCalibration', 'V') IS NOT NULL
    DROP VIEW dbo.vw_Equipment_RequireCalibration;

-- Remove columns from Calibration_Log
ALTER TABLE dbo.Calibration_Log DROP COLUMN IF EXISTS AttachmentsPath;
ALTER TABLE dbo.Calibration_Log DROP COLUMN IF EXISTS EquipmentEatonID;
ALTER TABLE dbo.Calibration_Log DROP COLUMN IF EXISTS EquipmentName;

-- Remove columns from equipment tables
-- ATE
ALTER TABLE dbo.ATE_Inventory DROP COLUMN IF EXISTS RequiredCalibration;
ALTER TABLE dbo.ATE_Inventory DROP COLUMN IF EXISTS CalibrationFrequency;
ALTER TABLE dbo.ATE_Inventory DROP COLUMN IF EXISTS CalibrationResponsible;
ALTER TABLE dbo.ATE_Inventory DROP COLUMN IF EXISTS LastCalibration;
ALTER TABLE dbo.ATE_Inventory DROP COLUMN IF EXISTS LastCalibrationBy;
ALTER TABLE dbo.ATE_Inventory DROP COLUMN IF EXISTS NextCalibration;

-- Asset
ALTER TABLE dbo.Asset_Inventory DROP COLUMN IF EXISTS RequiredCalibration;
ALTER TABLE dbo.Asset_Inventory DROP COLUMN IF EXISTS CalibrationFrequency;
ALTER TABLE dbo.Asset_Inventory DROP COLUMN IF EXISTS CalibrationResponsible;
ALTER TABLE dbo.Asset_Inventory DROP COLUMN IF EXISTS LastCalibration;
ALTER TABLE dbo.Asset_Inventory DROP COLUMN IF EXISTS CalibrationBy;
ALTER TABLE dbo.Asset_Inventory DROP COLUMN IF EXISTS NextCalibration;

-- Fixture
ALTER TABLE dbo.Fixture_Inventory DROP COLUMN IF EXISTS RequiredCalibration;
ALTER TABLE dbo.Fixture_Inventory DROP COLUMN IF EXISTS CalibrationFrequency;
ALTER TABLE dbo.Fixture_Inventory DROP COLUMN IF EXISTS CalibrationResponsible;
ALTER TABLE dbo.Fixture_Inventory DROP COLUMN IF EXISTS LastCalibration;
ALTER TABLE dbo.Fixture_Inventory DROP COLUMN IF EXISTS CalibrationBy;
ALTER TABLE dbo.Fixture_Inventory DROP COLUMN IF EXISTS NextCalibration;

-- Harness
ALTER TABLE dbo.Harness_Inventory DROP COLUMN IF EXISTS RequiredCalibration;
ALTER TABLE dbo.Harness_Inventory DROP COLUMN IF EXISTS CalibrationFrequency;
ALTER TABLE dbo.Harness_Inventory DROP COLUMN IF EXISTS CalibrationResponsible;
ALTER TABLE dbo.Harness_Inventory DROP COLUMN IF EXISTS LastCalibration;
ALTER TABLE dbo.Harness_Inventory DROP COLUMN IF EXISTS CalibrationBy;
ALTER TABLE dbo.Harness_Inventory DROP COLUMN IF EXISTS NextCalibration;
```

---

## Quick Fix: Just Run the Missing Script

If you already ran scripts 2 and 3 but got errors, simply run script 1:

```sql
-- Run this script
Database/Scripts/Add_Calibration_Columns_To_Equipment_Tables.sql

-- Then re-run the view creation
Database/Scripts/Create_vw_Equipment_RequireCalibration.sql
```

The scripts use `IF NOT EXISTS` checks, so they're safe to run multiple times.

---

## Support

If you still encounter issues:

1. **Check SQL Server Version**
   ```sql
   SELECT @@VERSION;
   ```
   Should work on SQL Server 2012+

2. **Check Database Name**
   Ensure you're connected to the `TestEngineering` database

3. **Check Permissions**
   Your database user needs:
   - ALTER TABLE permission
   - CREATE VIEW permission
   - SELECT permission on all tables

4. **Check for Typos in Table Names**
   ```sql
   SELECT TABLE_NAME 
   FROM INFORMATION_SCHEMA.TABLES 
   WHERE TABLE_NAME LIKE '%Inventory%'
   ORDER BY TABLE_NAME;
   ```
   Should return: ATE_Inventory, Asset_Inventory, Fixture_Inventory, Harness_Inventory

---

**Document Version:** 1.0  
**Last Updated:** October 10, 2025  
**Related:** Calibration_Details_Quick_Start.md
