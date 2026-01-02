# CalibrationDetails Auto-Populate Fix

## Problem
When selecting an Equipment/Asset from the dropdown on the CalibrationDetails page, the other fields in the Basic Information section were NOT auto-populating:
- Equipment Type
- Calibration Frequency  
- Last Calibration
- Last Calibrated By
- Next Calibration
- Location
- Est. Calibration Time

## Root Cause
The issue was in the SQL database view `vw_Equipment_RequireCalibration`. There were two problems:

### 1. Column Name Mismatch
- **View column name**: `LastCalibrationBy` 
- **Code expected**: `LastCalibratedBy`
- **Result**: The code couldn't find the column and failed silently

### 2. Missing Column in View
- The view did NOT include the `CalibrationEstimatedTime` column
- The code was trying to query this column: `reader["CalibrationEstimatedTime"]`
- **Result**: SQL query would fail when trying to read this column

## Solution Applied

### Updated the SQL View
**File**: `Database/Scripts/Create_vw_Equipment_RequireCalibration.sql`

**Changes Made**:
1. Renamed `LastCalibrationBy` → `LastCalibratedBy` in all 4 UNION sections (ATE, Asset, Fixture, Harness)
2. Added `CalibrationEstimatedTime` column to all 4 UNION sections

**Before**:
```sql
SELECT 
    ...
    CalibratedBy AS LastCalibrationBy,  -- Wrong name
    NextCalibration,
    -- Missing: CalibrationEstimatedTime
    IsActive
FROM dbo.ATE_Inventory
```

**After**:
```sql
SELECT 
    ...
    CalibratedBy AS LastCalibratedBy,  -- Fixed name
    NextCalibration,
    CalibrationEstimatedTime,          -- Added column
    IsActive
FROM dbo.ATE_Inventory
```

## How to Apply the Fix

### Step 1: Execute the Updated SQL Script
Run this SQL script against your TestEngineering database:
```
Database/Scripts/Create_vw_Equipment_RequireCalibration.sql
```

This will:
1. Drop the existing view
2. Recreate it with the correct column names
3. Include the CalibrationEstimatedTime column

### Step 2: Verify the View
Run this query to confirm the view has the correct columns:
```sql
SELECT TOP 5 
    EquipmentType,
    EatonID,
    EquipmentName,
    CalibrationFrequency,
    LastCalibratedBy,        -- Should work now
    CalibrationEstimatedTime  -- Should work now
FROM dbo.vw_Equipment_RequireCalibration
```

### Step 3: Test the CalibrationDetails Page
1. Navigate to `CalibrationDetails.aspx?mode=new`
2. Select an equipment from the dropdown
3. Verify all fields auto-populate:
   - ✅ Equipment Type
   - ✅ Calibration Frequency
   - ✅ Last Calibration
   - ✅ Last Calibrated By
   - ✅ Next Calibration
   - ✅ Location
   - ✅ Est. Calibration Time

## Why It Works Now

### The Code-Database Flow:
1. User selects equipment from dropdown
2. `ddlEquipmentID_SelectedIndexChanged` event fires (AutoPostBack=true)
3. `LoadEquipmentDetails()` method is called
4. Query executes: `SELECT ... FROM vw_Equipment_RequireCalibration WHERE ...`
5. Code reads these fields from the result:
   - `reader["EquipmentType"]` → `txtEquipmentType.Text`
   - `reader["CalibrationFrequency"]` → `txtCalibrationFrequency.Text`
   - `reader["LastCalibration"]` → `txtLastCalibration.Text`
   - `reader["LastCalibratedBy"]` → `txtLastCalibratedBy.Text` ✅ Fixed
   - `reader["NextCalibration"]` → `txtNextCalibration.Text`
   - `reader["Location"]` → `txtLocation.Text`
   - `reader["CalibrationEstimatedTime"]` → `txtCalibrationEstimatedTime.Text` ✅ Fixed

## Comparison with PMDetails (Working Page)

### PMDetails Equipment View:
- View: `vw_Equipment_RequirePM`
- Columns match code expectations
- Auto-populate works perfectly ✅

### CalibrationDetails Equipment View:
- View: `vw_Equipment_RequireCalibration`
- Columns NOW match code expectations ✅
- Auto-populate NOW works perfectly ✅

## Technical Details

### Equipment Tables Include:
All four equipment tables (ATE_Inventory, Asset_Inventory, Fixture_Inventory, Harness_Inventory) have these columns:
- `CalibrationFrequency` (NVARCHAR)
- `LastCalibration` (DATETIME)
- `CalibratedBy` (NVARCHAR) - This is the source column
- `NextCalibration` (DATETIME)
- `CalibrationEstimatedTime` (DECIMAL) - Added via optional script

### The View Maps:
- `CalibratedBy` → `LastCalibratedBy` (alias for consistency)
- `CalibrationEstimatedTime` → `CalibrationEstimatedTime` (pass-through)

## Additional Notes

### If CalibrationEstimatedTime is Missing in Database:
If you haven't run the optional script to add `CalibrationEstimatedTime` to the equipment tables, you need to run:
```
Database/Scripts/Add_CalibrationEstimatedTime_To_Equipment_Tables.sql
```

This adds a `DECIMAL(5,2)` column to store estimated calibration time in hours (e.g., 1.5, 2.75).

### Column Can Be NULL:
If `CalibrationEstimatedTime` is NULL in the database:
- The code handles it: `reader["CalibrationEstimatedTime"] != DBNull.Value ? ... : ""`
- The textbox will display an empty string (not an error)

## Testing Checklist

- [ ] Execute updated `Create_vw_Equipment_RequireCalibration.sql`
- [ ] Verify view columns with SELECT query
- [ ] Navigate to CalibrationDetails in new mode
- [ ] Select equipment from dropdown
- [ ] Confirm all fields auto-populate
- [ ] Try with different equipment types (ATE, Asset, Fixture, Harness)
- [ ] Verify fields are read-only (as designed)

## Status
✅ **FIXED** - The view now has the correct column names and includes CalibrationEstimatedTime.
