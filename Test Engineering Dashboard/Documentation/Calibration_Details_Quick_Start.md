# Calibration Details System - Quick Implementation Guide

## 🚀 Quick Start (6 Steps)

### Step 1: Execute SQL Scripts (3 minutes)

#### Script 1: Add Calibration Columns to Equipment Tables
**File:** `Database/Scripts/Add_Calibration_Columns_To_Equipment_Tables.sql`

```sql
-- Adds calibration-related columns to all equipment inventory tables
-- Run this FIRST!
```

**Expected Output:**
- 6 columns added to each equipment table (ATE, Asset, Fixture, Harness)
- RequiredCalibration, CalibrationFrequency, CalibrationResponsible, LastCalibration, LastCalibrationBy/CalibrationBy, NextCalibration
- "Calibration columns added successfully!" message

**Important:** ATE uses `LastCalibrationBy` while Asset/Fixture/Harness use `CalibrationBy`

---

#### Script 2: Add Columns to Calibration_Log
**File:** `Database/Scripts/Add_Columns_To_Calibration_Log.sql`

```sql
-- Adds AttachmentsPath, EquipmentEatonID, EquipmentName columns
-- Run this second!
```

**Expected Output:**
- 3 columns added successfully
- Existing records populated with equipment info
- "Columns added successfully!" message

---

#### Script 3: Create Equipment View
**File:** `Database/Scripts/Create_vw_Equipment_RequireCalibration.sql`

```sql
-- Creates vw_Equipment_RequireCalibration view
-- Run this third!
```

**Expected Output:**
- View created successfully
- Test query shows equipment requiring calibration
- "View created successfully!" message

---

### Step 2: Verify Database Changes (2 minutes)

Run these verification queries:

```sql
-- Check equipment tables have calibration columns
SELECT TABLE_NAME, COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME IN ('ATE_Inventory', 'Asset_Inventory', 'Fixture_Inventory', 'Harness_Inventory')
  AND COLUMN_NAME IN ('RequiredCalibration', 'CalibrationFrequency', 'CalibrationResponsible', 
                      'LastCalibration', 'LastCalibrationBy', 'CalibrationBy', 'NextCalibration')
ORDER BY TABLE_NAME, COLUMN_NAME;

-- Check Calibration_Log columns were added
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Calibration_Log'
  AND COLUMN_NAME IN ('AttachmentsPath', 'EquipmentEatonID', 'EquipmentName');

-- Check view exists and has data (if equipment marked for calibration)
SELECT TOP 5 
    EquipmentType,
    EatonID,
    EquipmentName,
    CalibrationFrequency,
    NextCalibration
FROM dbo.vw_Equipment_RequireCalibration
ORDER BY EquipmentType, EatonID;
```

**Expected Results:**
- First query shows calibration columns in all 4 equipment tables
- Second query returns 3 rows (AttachmentsPath, EquipmentEatonID, EquipmentName)
- Third query returns equipment that needs calibration (may be empty if no equipment marked yet)

---

### Step 3: Mark Equipment for Calibration (1 minute)

If the view query returns no results, you need to mark some equipment as requiring calibration:

```sql
-- Example: Mark specific ATE equipment for calibration
UPDATE dbo.ATE_Inventory
SET RequiredCalibration = 1,
    CalibrationFrequency = 'Annually',  -- or 'Monthly', 'Quarterly', 'Semi-Annually'
    CalibrationResponsible = 'Test Engineering',
    NextCalibration = DATEADD(YEAR, 1, GETDATE())  -- Due in 1 year
WHERE ATEInventoryID = 1;  -- Replace with your equipment ID

-- Verify the update
SELECT * FROM dbo.vw_Equipment_RequireCalibration;
```

Repeat for other equipment types (Asset, Fixture, Harness) as needed.

---

### Step 4: Deploy Files (Already Done!)

✅ **CalibrationDetails.aspx** - Frontend page (647 lines)  
✅ **CalibrationDetails.aspx.cs** - Backend code (1,214 lines)  
✅ **Calibration.aspx** - Updated "+ New Calibration Log" button

**No additional action needed** - files are already created!

---

### Step 5: Create Upload Folder (30 seconds)

Ensure the Uploads folder structure exists:

**In IIS/File System:**
```
/Test Engineering Dashboard/
  └── Uploads/
      └── Calibration/     ← Create this folder if it doesn't exist
```

**Permissions Required:**
- IIS Application Pool user needs WRITE permission
- Network Service or ApplicationPoolIdentity (depending on your IIS setup)

**PowerShell command to create folder:**
```powershell
New-Item -Path ".\Uploads\Calibration" -ItemType Directory -Force
```

---

### Step 6: Test the System (5 minutes)

#### Test 1: Navigate to New Calibration Log
1. Open browser to Test Engineering Dashboard
2. Go to **Calibration** page
3. Click **"+ New Calibration Log"** button
4. ✅ Should navigate to `CalibrationDetails.aspx?mode=new`
5. ✅ Page title should show "New Calibration Log"
6. ✅ Equipment dropdown should show equipment requiring calibration

---

#### Test 2: Create a Calibration Log
1. Select equipment from dropdown
2. ✅ Equipment info panel should appear with 7 fields
3. Enter required fields:
   - **Calibration Date:** Today's date (auto-filled)
   - **Calibration Results:** Select "Pass"
   - **Performed By:** Enter your name
   - **Status:** "Completed" (pre-selected)
4. (Optional) Upload a test file (PDF or image)
5. Click **"Save Calibration Log"**
6. ✅ Should show success message
7. ✅ Should redirect to view page
8. ✅ Calibration dropdown should show new log

---

#### Test 3: Verify Equipment Update
Run this query to verify equipment was updated:

```sql
-- Check equipment inventory was updated
-- Replace 'ATE' and 1 with your equipment type and ID
SELECT 
    EatonID,
    LastCalibration,
    LastCalibrationBy,  -- or CalibrationBy for Asset/Fixture/Harness
    NextCalibration
FROM dbo.ATE_Inventory  -- or Asset_Inventory, Fixture_Inventory, Harness_Inventory
WHERE ATEInventoryID = 1;  -- use AssetID, FixtureID, or HarnessID accordingly
```

✅ LastCalibration should match your calibration date  
✅ LastCalibrationBy should match the technician name  
✅ NextCalibration should match if you entered it

---

#### Test 4: View Existing Calibration
1. Click **"Calibration Log Details"** in sidebar
2. ✅ Should navigate to most recent calibration log
3. ✅ All fields should be populated
4. ✅ Equipment info should display
5. ✅ Attachments should show (if you uploaded files)

---

#### Test 5: Edit and File Management
1. While viewing calibration, change the **Comments** field
2. Upload another file
3. Click **"Save Calibration Log"**
4. ✅ Success message should appear
5. ✅ Both files should now be listed
6. Click **"Delete"** on one file
7. Confirm deletion
8. ✅ File should be removed from list

---

## ⚡ Quick Reference

### Navigation Paths

```
New Calibration:
Calibration.aspx → "+ New Calibration Log" → CalibrationDetails.aspx?mode=new

View Latest:
CalibrationDetails.aspx → Sidebar "Calibration Log Details" → CalibrationDetails.aspx?id={newest}

View Specific:
Calibration Log Dropdown → Select log → CalibrationDetails.aspx?id={selected}
```

### File Paths

```
Frontend:  /Test Engineering Dashboard/CalibrationDetails.aspx
Backend:   /Test Engineering Dashboard/CalibrationDetails.aspx.cs
Uploads:   /Test Engineering Dashboard/Uploads/Calibration/{CalibrationID}/
```

### Required Permissions

```
Session["TED:UserCategory"] = "Admin" OR "Test Engineering"
```

### Color Theme

```
Primary:   Orange gradient (#ff6b35 to #f7931e)
Secondary: Blue gradient (#1e88e5 to #1565c0)
```

---

## 🐛 Common Issues & Quick Fixes

### Issue: Equipment Dropdown is Empty

**Fix:**
```sql
-- Ensure equipment has RequiredCalibration flag set
UPDATE dbo.ATE_Inventory 
SET RequiredCalibration = 1, IsActive = 1 
WHERE ATEInventoryID = 1;  -- Replace with your equipment ID

-- Verify view has data
SELECT * FROM dbo.vw_Equipment_RequireCalibration;
```

---

### Issue: "Calibration Log Details" Button Goes to Dashboard

**Fix:**
```sql
-- Verify calibration logs exist
SELECT TOP 1 CalibrationID FROM dbo.Calibration_Log ORDER BY CalibrationID DESC;
```

If no results, create a test calibration first using the New Calibration Log page.

---

### Issue: File Upload Error

**Fix:**
1. Check folder exists: `/Test Engineering Dashboard/Uploads/Calibration/`
2. Check permissions: IIS Application Pool user needs WRITE access
3. Check Web.config for file size limits:
```xml
<httpRuntime maxRequestLength="10240" />  <!-- 10 MB -->
```

---

### Issue: Equipment Not Updating

**Fix:**
Check Debug output in Visual Studio (View → Output → Debug):
- Should see: "UpdateEquipmentCalibrationFields: Updated X rows in [Table] for ID Y"
- If error, check column names match equipment type

---

### Issue: Permission Denied

**Fix:**
Ensure session variables are set:
```csharp
Session["TED:UserCategory"] = "Admin";  // or "Test Engineering"
Session["TED:UserName"] = "YourName";
```

---

## ✅ Success Checklist

After implementation, verify these items:

- [ ] SQL scripts executed without errors
- [ ] View `vw_Equipment_RequireCalibration` returns data
- [ ] Uploads folder exists with WRITE permission
- [ ] Can navigate to "New Calibration Log" page
- [ ] Equipment dropdown shows equipment
- [ ] Equipment selection auto-populates 7 fields
- [ ] Can save new calibration log
- [ ] Success message appears after save
- [ ] Equipment inventory updated correctly
- [ ] Can view existing calibration logs
- [ ] Calibration dropdown shows proper format
- [ ] File upload works
- [ ] File download works
- [ ] File delete works
- [ ] "Calibration Log Details" button works
- [ ] Cancel button returns to dashboard
- [ ] Permission system blocks unauthorized users

---

## 📞 Need Help?

### Enable Debug Logging

In Visual Studio:
1. Go to **View → Output**
2. Select **"Debug"** from dropdown
3. Run application
4. Perform action
5. Check output for detailed logs

### Check Application Logs

Common log locations:
- Visual Studio Debug Output
- Event Viewer → Windows Logs → Application
- IIS Logs (if deployed)

### Database Verification Queries

```sql
-- Check calibration log structure
EXEC sp_help 'Calibration_Log';

-- Check recent calibrations
SELECT TOP 5 * FROM Calibration_Log ORDER BY CalibrationID DESC;

-- Check equipment calibration status
SELECT 
    EquipmentType,
    EatonID,
    EquipmentName,
    LastCalibration,
    NextCalibration
FROM vw_Equipment_RequireCalibration
WHERE NextCalibration < GETDATE() + 30;  -- Due in next 30 days
```

---

## 🎉 Congratulations!

Your Calibration Details system is now fully operational and matches the PM Details system functionality!

**Features Enabled:**
✅ Create and edit calibration logs  
✅ Auto-populate equipment details  
✅ Upload calibration certificates  
✅ Track calibration history  
✅ Auto-update equipment inventory  
✅ Intuitive navigation and design  

**Next Steps:**
- Train users on the new system
- Create calibration logs for equipment due for calibration
- Monitor equipment calibration status on dashboard
- Consider adding "View Details" button to Calibration.aspx GridView

---

**Documentation Version:** 1.0  
**Implementation Time:** ~10 minutes  
**Last Updated:** October 10, 2025
