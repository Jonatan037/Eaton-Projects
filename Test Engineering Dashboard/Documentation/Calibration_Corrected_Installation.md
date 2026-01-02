# Calibration Details System - Corrected Installation Guide

## 📋 Your Database Structure (Already Exists!)

Your equipment tables already have these calibration columns:
- ✅ `RequiresCalibration` (BIT) - Already exists!
- ✅ `CalibrationID` (NVARCHAR) - External calibration reference
- ✅ `CalibrationFrequency` (NVARCHAR) - Monthly, Quarterly, Annually, etc.
- ✅ `LastCalibration` (DATETIME) - Last calibration date
- ✅ `CalibratedBy` (NVARCHAR) - Who performed calibration
- ✅ `NextCalibration` (DATETIME) - Next due date

**Note:** All tables use `CalibratedBy` (NOT CalibrationBy or LastCalibrationBy)

---

## 🚀 Correct Installation (Only 3 Scripts!)

Since your equipment tables already have calibration columns, you only need to run these scripts:

### Script 1: Add Columns to Calibration_Log ✅ (You already ran this)
**File:** `Database/Scripts/Add_Columns_To_Calibration_Log.sql`

Adds:
- AttachmentsPath
- EquipmentEatonID  
- EquipmentName

**Status:** ✅ Already completed!

---

### Script 2: Create Equipment View (Run Now!)
**File:** `Database/Scripts/Create_vw_Equipment_RequireCalibration.sql` **(UPDATED VERSION)**

This view now correctly uses your existing columns:
- `RequiresCalibration` (your column name)
- `CalibratedBy` (your column name)
- Maps to `LastCalibrationBy` in view for consistency

**Execute this script now** - it should work without errors!

---

### Script 3 (OPTIONAL): Add CalibrationEstimatedTime
**File:** `Database/Scripts/Add_CalibrationEstimatedTime_To_Equipment_Tables.sql`

This is **optional** - only run if you want to track estimated calibration time (like PMEstimatedTime).

---

## ✅ What Got Fixed

### Before (Incorrect Assumptions):
- ❌ Assumed equipment tables didn't have calibration columns
- ❌ Assumed column name was `RequiredCalibration`
- ❌ Assumed different column names: `CalibrationBy` vs `LastCalibrationBy`
- ❌ Assumed `CalibrationResponsible` column existed

### After (Correct Reality):
- ✅ Your tables already have calibration columns!
- ✅ Column name is `RequiresCalibration` (not Required)
- ✅ All tables use same column name: `CalibratedBy`
- ✅ `CalibrationResponsible` doesn't exist (returns NULL in view)

---

## 🔧 Updated Files

I've corrected these files to match your actual database:

1. **Create_vw_Equipment_RequireCalibration.sql**
   - Uses `RequiresCalibration` (your column name)
   - Uses `CalibratedBy` for all tables
   - Returns NULL for `CalibrationResponsible` (column doesn't exist)

2. **CalibrationDetails.aspx.cs**
   - Updates `CalibratedBy` column (not CalibrationBy or LastCalibrationBy)
   - Simplified logic since all tables use same column name

3. **Deleted (Not Needed):**
   - ~~Add_Calibration_Columns_To_Equipment_Tables.sql~~ - **NOT NEEDED!**

---

## 📝 Next Steps

### Step 1: Run the View Script
Execute the **updated** `Create_vw_Equipment_RequireCalibration.sql`

This should now complete successfully!

### Step 2: Mark Equipment for Calibration
Your equipment probably has `RequiresCalibration = 0` by default. Set it to 1:

```sql
-- Example: Mark ATE equipment for calibration
UPDATE dbo.ATE_Inventory
SET RequiresCalibration = 1,
    CalibrationFrequency = 'Annually',
    NextCalibration = DATEADD(YEAR, 1, GETDATE())
WHERE ATEInventoryID = 1;  -- Your equipment ID

-- Verify it appears in the view
SELECT * FROM dbo.vw_Equipment_RequireCalibration;
```

### Step 3: (Optional) Add CalibrationEstimatedTime
If you want to track estimated calibration time:

```sql
-- Run the optional script
Database/Scripts/Add_CalibrationEstimatedTime_To_Equipment_Tables.sql

-- Then set estimated times
UPDATE dbo.ATE_Inventory 
SET CalibrationEstimatedTime = 1.5  -- 1.5 hours
WHERE ATEInventoryID = 1;
```

### Step 4: Test the System
1. Navigate to Calibration.aspx
2. Click "+ New Calibration Log"
3. Equipment dropdown should now show equipment where `RequiresCalibration = 1`
4. Create a calibration log
5. Check that `CalibratedBy`, `LastCalibration`, and `NextCalibration` get updated

---

## 🔍 Verification Queries

### Check View Works
```sql
-- Should return equipment marked for calibration
SELECT 
    EquipmentType,
    EatonID,
    EquipmentName,
    CalibrationFrequency,
    LastCalibration,
    LastCalibrationBy,
    NextCalibration
FROM dbo.vw_Equipment_RequireCalibration
ORDER BY EquipmentType, EatonID;
```

### Check Equipment Table Columns
```sql
-- Verify your existing calibration columns
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'ATE_Inventory'
  AND COLUMN_NAME LIKE '%Calibr%'
ORDER BY ORDINAL_POSITION;
```

Expected columns:
- RequiresCalibration (bit)
- CalibrationID (nvarchar)
- CalibrationFrequency (nvarchar)
- LastCalibration (datetime)
- CalibratedBy (nvarchar)
- NextCalibration (datetime)
- CalibrationEstimatedTime (decimal) ← Only if you run optional script

---

## 📊 Column Name Reference

| Purpose | Your Column Name | View Column Name |
|---------|------------------|------------------|
| Flag | `RequiresCalibration` | `RequiredCalibration` |
| Frequency | `CalibrationFrequency` | `CalibrationFrequency` |
| Last Date | `LastCalibration` | `LastCalibration` |
| Performed By | `CalibratedBy` | `LastCalibrationBy` |
| Next Date | `NextCalibration` | `NextCalibration` |
| Responsible | *(doesn't exist)* | `CalibrationResponsible` (NULL) |

The view normalizes column names for consistency with the PM system.

---

## 🎉 Summary

**What You Need to Do:**
1. ✅ Calibration_Log columns - Already done!
2. ⏳ Run updated view script - **Do this now!**
3. ⏳ Mark equipment for calibration - Set `RequiresCalibration = 1`
4. ⏳ Test the system
5. ⭐ (Optional) Add CalibrationEstimatedTime column

**What You DON'T Need:**
- ❌ Don't run `Add_Calibration_Columns_To_Equipment_Tables.sql` - **NOT NEEDED!**
- ❌ Don't worry about missing columns - **They already exist!**

Your database structure is already perfect for the calibration system! 🎯

---

**Document Version:** 2.0 (Corrected)  
**Last Updated:** October 10, 2025  
**Status:** Ready to install with correct scripts
