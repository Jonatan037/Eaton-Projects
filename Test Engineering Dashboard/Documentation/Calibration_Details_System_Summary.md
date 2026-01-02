# Calibration Details System - Complete Implementation Summary

## Overview
Created a complete Calibration Details system that mirrors the PM Details implementation. This includes calibration log management, equipment tracking, file attachments, and automatic equipment inventory updates.

**Date Implemented:** October 10, 2025  
**Based On:** PM Details system architecture  
**Theme:** Orange/Blue (Calibration-focused)

---

## Files Created/Modified

### 1. Database Scripts

#### Add_Columns_To_Calibration_Log.sql
**Location:** `Database/Scripts/Add_Columns_To_Calibration_Log.sql`  
**Purpose:** Adds three new columns to Calibration_Log table  
**Columns Added:**
- `AttachmentsPath` (NVARCHAR(MAX)) - Stores comma-separated file paths
- `EquipmentEatonID` (NVARCHAR(50)) - Equipment Eaton identifier
- `EquipmentName` (NVARCHAR(200)) - Equipment name for display

**Migration Logic:**
- IF NOT EXISTS checks prevent duplicate columns
- Automatically populates existing records from equipment inventory tables
- Handles all 4 equipment types: ATE, Asset, Fixture, Harness
- Uses NULL-safe joins and column selection

**Execute:** Run this script first to prepare the Calibration_Log table

---

#### Create_vw_Equipment_RequireCalibration.sql
**Location:** `Database/Scripts/Create_vw_Equipment_RequireCalibration.sql`  
**Purpose:** Creates unified view of all equipment requiring calibration  

**View Structure:**
```sql
SELECT 
    EquipmentType,      -- 'ATE', 'Asset', 'Fixture', 'Harness'
    EquipmentID,        -- Primary key from source table
    EatonID,            -- Equipment Eaton identifier
    EquipmentName,      -- Equipment name (varies by type)
    Location,           -- Physical location
    RequiredCalibration,-- Flag (always 1 in view)
    CalibrationFrequency,
    CalibrationResponsible,
    LastCalibration,
    LastCalibrationBy,  -- Normalized column name
    NextCalibration,
    IsActive            -- Only active equipment shown
FROM [Equipment Tables]
WHERE RequiredCalibration = 1 AND IsActive = 1
```

**Column Name Normalization:**
- ATE uses `LastCalibrationBy`
- Asset/Fixture/Harness use `CalibrationBy`
- View normalizes all to `LastCalibrationBy`

**Execute:** Run after column script to create the equipment view

---

### 2. Frontend - CalibrationDetails.aspx

**Location:** `Test Engineering Dashboard/CalibrationDetails.aspx`  
**Lines:** 647 lines  
**Framework:** ASP.NET WebForms with Master Page

#### Design Features

**Color Scheme:**
- Primary: Orange gradient (#ff6b35 to #f7931e)
- Secondary: Blue gradient (#1e88e5 to #1565c0)
- Success: Green (#d4edda)
- Error: Red (#f8d7da)

**Layout Sections:**

1. **Sidebar Navigation (Fixed Left)**
   - Calibration Log Details (view existing)
   - New Calibration Log (create new)
   - Back to Dashboard
   - Active state highlighting
   - Responsive collapse on mobile

2. **Header Section**
   - Orange gradient background
   - Dynamic page title (Details vs New)
   - Descriptive subtitle
   - Icon: fa-clipboard-check

3. **Calibration Log Selector**
   - Blue gradient background
   - Dropdown format: "#1 | TE0023 | Test Station Alpha (Completed)"
   - Only visible when viewing existing logs
   - Auto-postback for quick navigation

4. **Equipment Selection Card**
   - Equipment dropdown with calibration-required items
   - Format: "TE0023 - Test Station Alpha (Location: Lab A) [Next Cal: 10/15/2025]"
   - Auto-postback to load equipment details
   - 7-field auto-populated equipment info grid:
     - Equipment Type
     - Calibration Frequency
     - Calibration Responsible
     - Last Calibration
     - Last Calibration By
     - Next Calibration Due
     - Location
   - Blue-themed equipment info cards

5. **Calibration Information Card**
   - Calibration Date (required, date picker)
   - Next Calibration Date (date picker)
   - Calibration Type dropdown:
     - Internal Calibration
     - External Calibration
     - Vendor Calibration
     - In-House Calibration
   - Calibration Results (required):
     - Pass
     - Pass with Adjustment
     - Fail
     - Out of Tolerance
   - Performed By / Technician (required, text)
   - Status (required):
     - Completed
     - In Progress
     - Pending
     - Failed
   - Calibration Details / Adjustments (multiline)
   - Comments / Notes (multiline)

6. **File Attachments Card**
   - Dashed orange border upload section
   - Multi-file upload support
   - Accepted formats: PDF, Images, Excel, Word
   - Existing attachments list with:
     - File name with download icon
     - Delete button with confirmation
     - White cards with file icons

7. **Action Buttons**
   - Save Calibration Log (orange gradient)
   - Cancel (gray gradient)
   - Centered at bottom
   - Hover effects with elevation

#### Responsive Design
- Desktop: Sidebar + main content side-by-side
- Mobile: Stacked layout, full-width cards
- Grid adapts to single column on small screens

#### Validation Indicators
- Red asterisks (*) for required fields
- Success/error alert panels at top
- Client-side confirmation for file deletion

---

### 3. Backend - CalibrationDetails.aspx.cs

**Location:** `Test Engineering Dashboard/CalibrationDetails.aspx.cs`  
**Lines:** 1,214 lines  
**Language:** C# (compatible with .NET 4.0 / C# 5.0)

#### Key Methods

**Page_Load (Lines 7-66)**
- Permission check (Admin or Test Engineering only)
- Handles `action=viewFirst` query parameter
- Determines mode (view, new, or redirect)
- Loads calibration dropdown and equipment dropdown
- Loads existing data if viewing calibration

**RedirectToFirstCalibrationLog() (Lines 184-236)**
- Queries most recent calibration log
- Debug logging for troubleshooting
- Redirects to `CalibrationDetails.aspx?id={CalibrationID}`
- Falls back to new mode if no logs exist
- Safe error handling with multiple fallback levels

**LoadCalibrationDropdown() (Lines 72-140)**
- Loads all calibration logs ordered by ID DESC
- Format: "#1 | TE0023 | Test Station Alpha (Completed)"
- Includes EquipmentEatonID and EquipmentName
- Handles NULL values gracefully

**LoadEquipmentDropdown() (Lines 245-305)**
- Loads from `vw_Equipment_RequireCalibration`
- Format: "TE0023 - Test Station Alpha (Location: Lab A) [Next Cal: 10/15/2025]"
- Composite value: "EquipmentType|EquipmentID"
- Ordered by EquipmentType, EatonID

**LoadEquipmentDetails() (Lines 307-395)**
- Triggered when equipment selected
- Parses composite value
- Queries view for equipment information
- Auto-populates 7 read-only fields
- Auto-fills Next Calibration Date if available

**LoadCalibrationData() (Lines 397-525)**
- Loads existing calibration log
- Populates all form fields
- Restores equipment selection
- Loads equipment details
- Loads file attachments

**LoadAttachments() (Lines 527-560)**
- Parses comma-separated attachment paths
- Creates file list for repeater
- Shows/hides attachment panel

**SaveUploadedFiles() (Lines 600-660)**
- Creates directory: ~/Uploads/Calibration/{CalibrationID}/
- Saves multiple files
- Handles duplicate filenames with timestamps
- Returns comma-separated paths

**DeleteAttachment() (Lines 571-630)**
- Deletes physical file from server
- Updates database AttachmentsPath
- Removes path from comma-separated string
- Error handling and logging

**btnSave_Click() (Lines 715-942)**
- **Validation:**
  - Equipment required
  - Calibration Date required
  - Results required
  - Performed By required
  - Status required

- **INSERT Logic (New Calibration):**
  1. Parse equipment selection
  2. Query `vw_Equipment_RequireCalibration` for EatonID and EquipmentName
  3. Insert calibration log with equipment info
  4. Get new CalibrationID via SCOPE_IDENTITY()
  5. Save uploaded files
  6. Update AttachmentsPath in database
  7. Call `UpdateEquipmentCalibrationFields()`
  8. Redirect to view page

- **UPDATE Logic (Existing Calibration):**
  1. Parse equipment selection
  2. Query view for current EatonID and EquipmentName
  3. Get existing AttachmentsPath
  4. Save new uploaded files
  5. Combine existing and new attachment paths
  6. Update all calibration fields including equipment info
  7. Call `UpdateEquipmentCalibrationFields()`
  8. Redirect to refresh view

**UpdateEquipmentCalibrationFields() (Lines 880-942)**
- Updates equipment inventory tables after calibration save
- Handles column name differences:
  - ATE: `LastCalibrationBy`
  - Asset/Fixture/Harness: `CalibrationBy`
- Updates three fields:
  - `LastCalibration` = Calibration Date
  - `LastCalibrationBy` or `CalibrationBy` = Performed By
  - `NextCalibration` = Next Calibration Date (if provided)
- Uses same SqlConnection for transaction safety
- Non-blocking: doesn't fail main operation if update fails
- Debug logging for troubleshooting

**Helper Methods:**
- `ShowSuccess()` - Displays success message
- `ShowError()` - Displays error message
- `btnCancel_Click()` - Returns to Calibration.aspx

---

### 4. Modified Files

#### Calibration.aspx
**Change:** Updated "+ New Calibration Log" button  
**Line:** 324  
**Old:** `OnClientClick="window.location='LogCalibration.aspx'; return false;"`  
**New:** `OnClientClick="window.location='CalibrationDetails.aspx?mode=new'; return false;"`

**Impact:**
- Creates new calibration using CalibrationDetails.aspx
- Maintains existing LogCalibration.aspx for backward compatibility
- Users get consistent experience with PM system

---

## Technical Implementation Details

### Database Schema

**Calibration_Log Table (Enhanced)**
```sql
CalibrationID INT PRIMARY KEY IDENTITY
EquipmentType NVARCHAR(50)
EquipmentID INT
EquipmentEatonID NVARCHAR(50)      -- NEW
EquipmentName NVARCHAR(200)        -- NEW
CalibrationDate DATETIME
NextCalibrationDate DATETIME
CalibrationType NVARCHAR(100)
Results NVARCHAR(100)
PerformedBy NVARCHAR(100)
Status NVARCHAR(50)
CalibrationDetails NVARCHAR(MAX)
Comments NVARCHAR(MAX)
CreatedBy NVARCHAR(100)
CreatedDate DATETIME
AttachmentsPath NVARCHAR(MAX)      -- NEW
```

**Equipment Tables Structure**
Each table has these calibration-related columns:
- `RequiredCalibration` BIT
- `CalibrationFrequency` NVARCHAR
- `CalibrationResponsible` NVARCHAR
- `LastCalibration` DATETIME
- `LastCalibrationBy` or `CalibrationBy` NVARCHAR
- `NextCalibration` DATETIME

---

### Data Flow

#### Creating New Calibration Log

1. **User Navigation:**
   - Clicks "+ New Calibration Log" on Calibration.aspx
   - Redirects to `CalibrationDetails.aspx?mode=new`

2. **Page Load:**
   - Page_Load detects `mode=new`
   - Sets title to "New Calibration Log"
   - Hides calibration selector dropdown
   - Sets default Calibration Date to today
   - Sets default Status to "Completed"
   - Loads equipment dropdown

3. **Equipment Selection:**
   - User selects equipment from dropdown
   - AutoPostBack triggers
   - `ddlEquipment_SelectedIndexChanged()` fires
   - `LoadEquipmentDetails()` queries view
   - 7 fields auto-populate with equipment info
   - Equipment info panel becomes visible

4. **Form Completion:**
   - User enters calibration date (required)
   - User enters next calibration date (optional)
   - User selects calibration type
   - User selects results (required)
   - User enters technician name (required)
   - User selects status (required)
   - User enters calibration details
   - User enters comments
   - User uploads files (optional)

5. **Save Process:**
   - User clicks "Save Calibration Log"
   - `btnSave_Click()` validates required fields
   - Parses equipment selection
   - Queries view for EatonID and EquipmentName
   - Inserts new record into Calibration_Log
   - Gets new CalibrationID
   - Saves uploaded files to `~/Uploads/Calibration/{CalibrationID}/`
   - Updates AttachmentsPath in database
   - Calls `UpdateEquipmentCalibrationFields()` to update inventory
   - Shows success message
   - Redirects to `CalibrationDetails.aspx?id={CalibrationID}`

#### Viewing/Editing Existing Calibration Log

1. **User Navigation:**
   - Clicks "Calibration Log Details" in sidebar
   - Or changes calibration in dropdown selector
   - Redirects to `CalibrationDetails.aspx?id={CalibrationID}`

2. **Page Load:**
   - Page_Load detects `id` parameter
   - Sets title to "Calibration Log Details"
   - Shows calibration selector dropdown
   - Loads calibration dropdown
   - Calls `LoadCalibrationData()`
   - Populates all fields from database
   - Selects equipment in dropdown
   - Loads equipment details
   - Shows equipment info panel
   - Loads and displays file attachments

3. **Editing:**
   - User modifies any fields
   - User uploads additional files (optional)
   - User deletes existing files (optional)

4. **Save Process:**
   - User clicks "Save Calibration Log"
   - `btnSave_Click()` validates required fields
   - Parses equipment selection
   - Queries view for current EatonID and EquipmentName
   - Gets existing AttachmentsPath
   - Saves new uploaded files
   - Combines existing and new attachment paths
   - Updates record in Calibration_Log
   - Calls `UpdateEquipmentCalibrationFields()` to update inventory
   - Shows success message
   - Redirects to refresh page

#### "Calibration Log Details" Button Navigation

1. **User clicks sidebar button**
2. Navigates to `CalibrationDetails.aspx?action=viewFirst`
3. Page_Load detects `action=viewFirst`
4. Calls `RedirectToFirstCalibrationLog()`
5. Queries for most recent calibration: `SELECT TOP 1 CalibrationID FROM Calibration_Log ORDER BY CalibrationID DESC`
6. **If calibration found:** Redirects to `CalibrationDetails.aspx?id={CalibrationID}`
7. **If no calibrations:** Redirects to `CalibrationDetails.aspx?mode=new`
8. **If error:** Falls back to new mode, or dashboard as last resort

---

### Equipment Inventory Synchronization

**When:** After every calibration log save (INSERT or UPDATE)

**Method:** `UpdateEquipmentCalibrationFields()`

**Process:**
1. Determines equipment table based on EquipmentType
2. Determines correct column name for "Calibration By":
   - ATE: `LastCalibrationBy`
   - Others: `CalibrationBy`
3. Determines ID column name:
   - ATE: `ATEInventoryID`
   - Asset: `AssetID`
   - Fixture: `FixtureID`
   - Harness: `HarnessID`
4. Executes UPDATE statement:
   ```sql
   UPDATE [Table]
   SET LastCalibration = @LastCalibration,
       [CalibrationByColumn] = @CalibrationBy,
       NextCalibration = @NextCalibration
   WHERE [IDColumn] = @EquipmentID
   ```
5. Logs success/failure to Debug output
6. Does NOT throw exception to avoid failing main save

**Result:**
- Equipment inventory always reflects latest calibration
- Users see accurate "Last Calibration" and "Next Calibration" dates
- "Last Calibration By" shows who performed most recent calibration

---

## File Storage Structure

```
~/Uploads/
  └── Calibration/
      ├── 1/                    (CalibrationID)
      │   ├── certificate.pdf
      │   ├── test_results.xlsx
      │   └── photo.jpg
      ├── 2/
      │   ├── calibration_cert.pdf
      │   └── report.docx
      └── 3/
          └── standards.pdf
```

**Features:**
- Each calibration has own folder
- Folder created automatically on first upload
- Multiple files per calibration
- Duplicate filename handling with timestamps
- Comma-separated paths in database: `~/Uploads/Calibration/1/certificate.pdf, ~/Uploads/Calibration/1/test_results.xlsx`

---

## Permission System

**Required Session Variables:**
- `Session["TED:UserCategory"]` - Must be "Admin" or "Test Engineering"
- `Session["TED:UserName"]` - Used for CreatedBy field

**Unauthorized Access:**
- Redirects to `~/UnauthorizedAccess.aspx`
- Prevents viewing or creating calibration logs
- Applied at Page_Load before any processing

---

## Navigation Flow

```
Calibration.aspx (Dashboard)
    │
    ├─── "+ New Calibration Log" button
    │    └─── CalibrationDetails.aspx?mode=new
    │
    └─── View Details button (future implementation)
         └─── CalibrationDetails.aspx?id={CalibrationID}

CalibrationDetails.aspx
    │
    ├─── Sidebar: "Calibration Log Details"
    │    └─── CalibrationDetails.aspx?action=viewFirst
    │         └─── Redirects to most recent log
    │
    ├─── Sidebar: "New Calibration Log"
    │    └─── CalibrationDetails.aspx?mode=new
    │
    ├─── Sidebar: "Back to Dashboard"
    │    └─── Calibration.aspx
    │
    ├─── Calibration Log Dropdown
    │    └─── CalibrationDetails.aspx?id={selected}
    │
    └─── Cancel Button
         └─── Calibration.aspx
```

---

## Testing Checklist

### Database Setup
- [ ] Execute `Add_Columns_To_Calibration_Log.sql`
- [ ] Verify columns added: `SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Calibration_Log'`
- [ ] Execute `Create_vw_Equipment_RequireCalibration.sql`
- [ ] Verify view exists: `SELECT * FROM vw_Equipment_RequireCalibration`
- [ ] Ensure equipment has calibration data in inventory tables

### Navigation Testing
- [ ] Calibration.aspx → "+ New Calibration Log" → CalibrationDetails.aspx?mode=new
- [ ] CalibrationDetails.aspx → Sidebar "Calibration Log Details" → redirects to most recent
- [ ] CalibrationDetails.aspx → Sidebar "New Calibration Log" → CalibrationDetails.aspx?mode=new
- [ ] CalibrationDetails.aspx → Sidebar "Back to Dashboard" → Calibration.aspx
- [ ] CalibrationDetails.aspx → Calibration dropdown → switches to selected log
- [ ] CalibrationDetails.aspx → Cancel button → Calibration.aspx

### Equipment Selection
- [ ] Equipment dropdown loads all calibration-required equipment
- [ ] Equipment dropdown format: "TE0023 - Test Station Alpha (Location: Lab A) [Next Cal: 10/15/2025]"
- [ ] Selecting equipment auto-populates 7 fields
- [ ] Equipment info panel becomes visible
- [ ] Equipment details are accurate (frequency, responsible, dates, location)

### Creating New Calibration
- [ ] Page title shows "New Calibration Log"
- [ ] Calibration selector is hidden
- [ ] Default calibration date is today
- [ ] Default status is "Completed"
- [ ] Required field validation works (equipment, date, results, technician, status)
- [ ] Can select calibration type
- [ ] Can enter calibration details and comments
- [ ] Can upload multiple files
- [ ] Save creates new record
- [ ] Redirects to view page after save
- [ ] Success message displays

### Editing Existing Calibration
- [ ] Page title shows "Calibration Log Details"
- [ ] Calibration selector is visible
- [ ] All fields populate correctly from database
- [ ] Equipment selection and details load
- [ ] Existing attachments display with download links
- [ ] Can upload additional files
- [ ] Can delete existing files with confirmation
- [ ] Save updates record
- [ ] Success message displays
- [ ] Page refreshes with updated data

### Equipment Inventory Update
- [ ] After saving calibration, check equipment table
- [ ] LastCalibration matches calibration date
- [ ] LastCalibrationBy (or CalibrationBy) matches technician name
- [ ] NextCalibration matches next calibration date (if provided)
- [ ] Works for all equipment types: ATE, Asset, Fixture, Harness

### File Management
- [ ] Multiple files can be uploaded at once
- [ ] Files save to correct folder: ~/Uploads/Calibration/{CalibrationID}/
- [ ] Duplicate filenames get timestamp suffix
- [ ] AttachmentsPath stores comma-separated paths
- [ ] Files can be downloaded from attachment list
- [ ] Files can be deleted with confirmation
- [ ] Deleting file updates database and removes from disk

### Calibration Dropdown Display
- [ ] Format: "#1 | TE0023 | Test Station Alpha (Completed)"
- [ ] Shows EquipmentEatonID
- [ ] Shows EquipmentName
- [ ] Shows Status
- [ ] Orders by CalibrationID DESC (most recent first)
- [ ] Current calibration is selected

### Permission System
- [ ] Admin users can access
- [ ] Test Engineering users can access
- [ ] Other users redirect to UnauthorizedAccess.aspx
- [ ] CreatedBy field uses Session["TED:UserName"]

### Error Handling
- [ ] Database connection errors show user-friendly message
- [ ] File upload errors show specific error
- [ ] Missing required fields show validation message
- [ ] Invalid equipment selection handled
- [ ] Non-existent calibration ID redirects to dashboard
- [ ] Debug output logs errors for troubleshooting

### Responsive Design
- [ ] Desktop: sidebar and main content side-by-side
- [ ] Mobile: sidebar stacks on top
- [ ] Equipment info grid adapts to single column on mobile
- [ ] All cards are readable on small screens
- [ ] Buttons remain accessible

---

## Comparison: PM vs Calibration Systems

| Feature | PM Details | Calibration Details |
|---------|-----------|---------------------|
| **Color Theme** | Purple gradient | Orange/Blue gradient |
| **Main Table** | PM_Log | Calibration_Log |
| **Equipment View** | vw_Equipment_RequirePM | vw_Equipment_RequireCalibration |
| **Date Fields** | PMDate, NextPMDate, ScheduledDate, ActualStartTime, ActualEndTime | CalibrationDate, NextCalibrationDate |
| **Type Field** | PMType | CalibrationType |
| **Result Field** | (N/A) | Results (Pass, Fail, etc.) |
| **Performed By** | PerformedBy | PerformedBy (Technician) |
| **Details Field** | MaintenancePerformed | CalibrationDetails |
| **Equipment Update Fields** | LastPM, LastPMBy, NextPM | LastCalibration, LastCalibrationBy/CalibrationBy, NextCalibration |
| **Column Name Difference** | ATE: LastPMBy, Others: PMBy | ATE: LastCalibrationBy, Others: CalibrationBy |
| **File Storage** | ~/Uploads/PM/{PMLogID}/ | ~/Uploads/Calibration/{CalibrationID}/ |
| **Dropdown Format** | #1 \| TE0023 \| Test Station Alpha (Completed) | #1 \| TE0023 \| Test Station Alpha (Completed) |
| **Equipment Info Fields** | 7 fields | 7 fields |
| **Update Method** | UpdateEquipmentPMFields() | UpdateEquipmentCalibrationFields() |

**Similarities:**
- Both use composite equipment value: "EquipmentType\|EquipmentID"
- Both auto-populate equipment details from view
- Both update equipment inventory tables on save
- Both handle file attachments with delete functionality
- Both have sidebar navigation (Details, New, Back)
- Both have log selector dropdown
- Both require Admin or Test Engineering permissions
- Both store EquipmentEatonID and EquipmentName in log table

---

## Future Enhancements

### Short Term
1. **Add "View Details" button in Calibration.aspx GridView**
   - Column with button in each row
   - Links to `CalibrationDetails.aspx?id={CalibrationID}`

2. **Email Notifications**
   - Send email when calibration approaching due date
   - Notify responsible person

3. **Calibration Reports**
   - Generate PDF calibration certificates
   - Export calibration history

### Long Term
1. **Dashboard Widgets**
   - Upcoming calibrations this month
   - Overdue calibrations
   - Calibration completion rate

2. **Calibration Standards Tracking**
   - Track calibration standards/equipment used
   - Link to standards library

3. **Calibration History Timeline**
   - Visual timeline of all calibrations for equipment
   - Trend analysis

4. **Mobile App Integration**
   - Scan equipment barcode
   - Quick calibration logging from mobile device

---

## Troubleshooting

### Calibration Log Details Button Not Working

**Symptoms:**
- Button redirects to dashboard instead of first calibration
- Button does nothing

**Solutions:**
1. Check Debug output in Visual Studio
2. Verify Calibration_Log table has records: `SELECT TOP 1 CalibrationID FROM Calibration_Log ORDER BY CalibrationID DESC`
3. Verify connection string in Web.config
4. Check user has SELECT permission on Calibration_Log
5. Review `RedirectToFirstCalibrationLog()` error logs

### Equipment Not Updating

**Symptoms:**
- Calibration saves but equipment table not updated
- LastCalibration date not changing

**Solutions:**
1. Check Debug output for `UpdateEquipmentCalibrationFields` messages
2. Verify equipment table column names (LastCalibrationBy vs CalibrationBy)
3. Check equipment still has `IsActive = 1`
4. Verify EquipmentID matches in Calibration_Log and inventory table

### File Upload Not Working

**Symptoms:**
- Files not saving
- Error message on save

**Solutions:**
1. Verify `~/Uploads/Calibration/` folder exists and is writable
2. Check IIS application pool has write permissions
3. Verify file size not exceeding limits in Web.config
4. Check available disk space

### Equipment Dropdown Empty

**Symptoms:**
- No equipment showing in dropdown

**Solutions:**
1. Verify `vw_Equipment_RequireCalibration` view exists
2. Check equipment has `RequiredCalibration = 1`
3. Check equipment has `IsActive = 1`
4. Verify view has data: `SELECT * FROM vw_Equipment_RequireCalibration`

---

## Code Maintenance Notes

### C# 5.0 Compatibility
- **DO NOT** use null-conditional operator (`?.`)
- **DO NOT** use string interpolation (`$"{var}"`)
- **DO** use `string.Format()`
- **DO** use ternary operators for null checks
- **DO** use `HasValue` property on nullable types

### Response.Redirect Pattern
Always use this pattern to avoid ThreadAbortException:
```csharp
Response.Redirect(url, false);
Context.ApplicationInstance.CompleteRequest();
```

### SQL Parameter Best Practices
- Always use parameterized queries
- Use `DBNull.Value` for NULL values
- Check `IsDBNull()` before reading values
- Use appropriate data types for parameters

### File Path Handling
- Use `Server.MapPath()` for physical paths
- Store relative paths in database (~/Uploads/...)
- Use `Path.Combine()` for building paths
- Always check file exists before operations

---

## Dependencies

### ASP.NET Framework
- .NET Framework 4.0+
- ASP.NET WebForms
- System.Web.UI
- System.Configuration

### Database
- SQL Server (any version supporting views)
- TestEngineeringConnectionString in Web.config

### JavaScript Libraries
- Font Awesome (for icons)
- Modern browser with CSS3 support

### Required Database Objects
- Calibration_Log table
- Equipment inventory tables (ATE, Asset, Fixture, Harness)
- vw_Equipment_RequireCalibration view

---

## Summary

The Calibration Details system is now fully implemented and matches the PM Details system in functionality and user experience. Users can:

✅ Create new calibration logs with equipment auto-population  
✅ View and edit existing calibration logs  
✅ Upload and manage calibration certificates  
✅ Track calibration history with equipment identification  
✅ Navigate easily between calibration logs  
✅ Have equipment inventory automatically updated  
✅ See calibration information displayed consistently  

The system is ready for production use after executing the SQL scripts and testing the workflow.

---

**Documentation Version:** 1.0  
**Last Updated:** October 10, 2025  
**Author:** Development Team
