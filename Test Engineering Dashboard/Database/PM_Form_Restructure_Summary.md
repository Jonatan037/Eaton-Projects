# PM Details Form Restructure - Implementation Summary

## Overview
The PM Details form has been completely restructured to automatically populate equipment details from inventory and track PM scheduling with actual execution times.

## Database Changes

### 1. Equipment Tables Enhancement
**File:** `Add_PMEstimatedTime_To_Equipment_Tables.sql`

Added `PMEstimatedTime DECIMAL(5,2)` column to all equipment tables:
- ATE_Inventory
- Asset_Inventory
- Fixture_Inventory
- Harness_Inventory

**Purpose:** Store estimated time (in hours) for preventive maintenance activities.

### 2. PM_Log Table Enhancement
**File:** `Add_PM_Log_Additional_Columns.sql`

Added new columns to PM_Log table:
- `ScheduledDate DATETIME` - Auto-populated from equipment's NextPM date
- `ActualStartTime DATETIME` - When PM work actually started
- `ActualEndTime DATETIME` - When PM work actually ended
- `Downtime DECIMAL(10,2)` - Equipment downtime in hours

**Purpose:** Track PM scheduling versus actual execution for better maintenance planning.

### 3. Equipment View Creation
**File:** `Create_vw_Equipment_RequirePM.sql`

Created unified view `vw_Equipment_RequirePM` that:
- Combines all 4 equipment inventory tables using UNION ALL
- Filters for `RequiredPM = 1` AND `IsActive = 1`
- Normalizes column name differences (PMBy vs LastPMBy)
- Returns: EquipmentType, EquipmentID, EatonID, EquipmentName, Location, PMFrequency, PMResponsible, LastPM, LastPMBy, NextPM, PMEstimatedTime

**Purpose:** Single source of truth for all equipment requiring preventive maintenance.

## Frontend Changes

### Form Layout Restructure (`PMDetails.aspx`)

#### Basic Information Section
1. **Equipment / Asset Dropdown** - Moved to top, span-8
   - Shows only equipment with RequiredPM=1 from all inventory tables
   - AutoPostBack enabled to trigger equipment detail loading
   - Format: "Type - EatonID | Name (Location)"

2. **Equipment Type** - Changed from dropdown to locked textbox
   - Auto-populated when equipment selected
   - Read-only (Enabled=false)

3. **Six New Auto-Populated Fields** (all read-only):
   - PM Frequency
   - PM Responsible
   - Last PM Date
   - Last PM By
   - Next PM
   - PM Estimated Time

#### Maintenance Details Section
1. **Scheduled Date** (NEW)
   - Auto-populated from equipment's Next PM date
   - Read-only
   - Shows "Auto-populated from equipment's Next PM" hint

2. **Actual Start Time** (NEW)
   - DateTimeLocal input for recording actual start

3. **Actual End Time** (NEW)
   - DateTimeLocal input for recording actual end

4. **Downtime** (NEW)
   - Number input (hours) with 0.01 step

5. **Existing fields maintained:**
   - PM Date, Next PM Date, PM Type
   - Maintenance Performed, Performed By, Status
   - Parts Replaced, Cost, Comments

## Backend Changes

### Code-Behind Enhancements (`PMDetails.aspx.cs`)

#### New Methods

1. **`LoadEquipmentDropdown()`**
   - Queries `vw_Equipment_RequirePM` view
   - Loads all equipment with RequiredPM=1
   - Stores composite value: "EquipmentType|EquipmentID"
   - Displays: "Type - EatonID | Name (Location)"

2. **`ddlEquipmentID_SelectedIndexChanged()`**
   - Triggered when equipment selection changes
   - Calls LoadEquipmentDetails()

3. **`LoadEquipmentDetails()`**
   - Parses composite equipment value
   - Queries view for selected equipment's PM details
   - Auto-populates 7 read-only fields
   - Sets ScheduledDate from NextPM in new mode

4. **`ClearEquipmentFields()`**
   - Clears all auto-populated fields when equipment deselected

#### Updated Methods

1. **`LoadPMData(int id)`**
   - Added support for ScheduledDate, ActualStartTime, ActualEndTime, Downtime
   - Loads equipment dropdown first
   - Sets composite value for equipment selection
   - Triggers LoadEquipmentDetails() to populate read-only fields

2. **`btnSave_Click()`**
   - Validates equipment selection (composite value)
   - Parses EquipmentType and EquipmentID from composite value
   - Auto-retrieves ScheduledDate from equipment's NextPM for new records
   - Includes new time fields in INSERT/UPDATE

3. **`AddPMParameters()`**
   - Removed EquipmentType and EquipmentID (handled in btnSave_Click)
   - Added ActualStartTime, ActualEndTime, Downtime parameters

4. **`SetupNewMode()`**
   - Calls LoadEquipmentDropdown() to populate equipment list

5. **`ApplyPermissions()`**
   - Removed ddlEquipmentType references
   - Added new time field permissions

## SQL Scripts Execution Order

Execute in this order:
1. `Add_PMEstimatedTime_To_Equipment_Tables.sql`
2. `Add_PM_Log_Additional_Columns.sql`
3. `Create_vw_Equipment_RequirePM.sql`

## Key Features

### Equipment Auto-Population
- Select any equipment requiring PM from unified dropdown
- Equipment Type, PM Frequency, PM Responsible automatically filled
- Last PM Date/By, Next PM, Estimated Time displayed
- Scheduled Date set from equipment's Next PM date

### Time Tracking
- Record actual start and end times of PM work
- Track equipment downtime separately
- Compare scheduled vs actual for better planning

### Simplified Workflow
1. User selects equipment from dropdown
2. All equipment details auto-populate
3. Scheduled Date automatically set
4. User records actual times and performs maintenance
5. System tracks variance for improvement

## Validation
- Equipment selection is required
- PM Date, PM Type, Maintenance Performed, Performed By are required
- All new time fields are optional
- Cost and Downtime validated as decimal numbers

## Permission System
- Maintained existing permission checks
- Only Admin and Test Engineering can create/edit/delete PM logs
- Non-editable fields properly disabled for view-only users

## Benefits
1. **Reduced Data Entry Errors** - Equipment details auto-populated from master data
2. **Better PM Tracking** - Scheduled vs actual time comparison
3. **Improved Planning** - Downtime and duration tracking for future estimates
4. **Single Equipment Source** - View ensures consistency across all equipment types
5. **Simplified Interface** - Removed Equipment Type dropdown, made selection more intuitive
