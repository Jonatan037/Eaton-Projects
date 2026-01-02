# PM Equipment Table Update Enhancement

## Overview
When a PM log is created or updated, the system now automatically updates the corresponding equipment record in the inventory table with the latest PM information.

## Implementation Details

### New Method: `UpdateEquipmentPMFields()`

**Location:** `PMDetails.aspx.cs`

**Purpose:** Updates the equipment inventory table with the latest PM information after a PM log is saved.

**Parameters:**
- `SqlConnection conn` - Active database connection
- `string equipmentType` - Type of equipment (ATE, Asset, Fixture, Harness)
- `int equipmentId` - ID of the equipment in its respective table
- `DateTime lastPM` - Date/time of the PM that was performed
- `string lastPMBy` - Name of technician who performed the PM
- `DateTime? nextPM` - Next scheduled PM date (nullable)

**Logic:**
1. Determines the correct table name and ID column based on equipment type
2. Identifies the correct LastPMBy column name (varies by table):
   - `ATE_Inventory` → uses `LastPMBy`
   - `Asset_Inventory` → uses `PMBy`
   - `Fixture_Inventory` → uses `PMBy`
   - `Harness_Inventory` → uses `PMBy`
3. Executes UPDATE statement to set:
   - `LastPM` = PM Date from the form
   - `LastPMBy` or `PMBy` = Performed By from the form
   - `NextPM` = Next PM Date from the form (can be NULL)

### Integration Points

#### 1. New PM Log Creation
**Location:** `btnSave_Click()` - After INSERT into PM_Log

```csharp
// After creating new PM log and handling file uploads
UpdateEquipmentPMFields(conn, equipmentType, equipmentId, 
    DateTime.Parse(txtPMDate.Text), 
    ddlPerformedBy.SelectedItem.Text,
    string.IsNullOrEmpty(txtNextPMDate.Text) ? (DateTime?)null : DateTime.Parse(txtNextPMDate.Text));
```

#### 2. Existing PM Log Update
**Location:** `btnSave_Click()` - After UPDATE of PM_Log

```csharp
// After updating PM log
UpdateEquipmentPMFields(conn, equipmentType, equipmentId, 
    DateTime.Parse(txtPMDate.Text), 
    ddlPerformedBy.SelectedItem.Text,
    string.IsNullOrEmpty(txtNextPMDate.Text) ? (DateTime?)null : DateTime.Parse(txtNextPMDate.Text));
```

## Data Flow

### When Creating/Updating a PM Log:

1. **User fills PM form:**
   - Selects equipment (auto-populates current PM info)
   - Enters PM Date (when PM was performed)
   - Enters Next PM Date (when next PM is scheduled)
   - Selects Performed By (technician name)

2. **On Save:**
   - PM_Log record is created/updated with all PM details
   - File attachments are processed
   - **Equipment table is automatically updated with:**
     - `LastPM` = PM Date from form
     - `LastPMBy`/`PMBy` = Performed By from form
     - `NextPM` = Next PM Date from form

3. **Result:**
   - PM Log maintains historical record
   - Equipment inventory reflects latest PM status
   - Next time equipment is selected, form shows updated PM info

## Benefits

### 1. Data Consistency
- Equipment inventory always reflects the most recent PM activity
- No manual updates required to equipment records
- Single source of truth maintained automatically

### 2. Accurate Auto-Population
- When creating a new PM log for the same equipment, the form auto-populates with the last PM info
- Historical tracking is preserved in PM_Log table
- Current status is reflected in equipment table

### 3. Maintenance Tracking
- Equipment's `NextPM` date is automatically updated based on PM schedule
- `LastPM` and `LastPMBy` provide quick reference without querying PM logs
- Supports PM scheduling and overdue equipment identification

## Database Column Mapping

| Equipment Table    | ID Column        | Last PM By Column |
|--------------------|------------------|-------------------|
| ATE_Inventory      | ATEInventoryID   | LastPMBy          |
| Asset_Inventory    | AssetID          | PMBy              |
| Fixture_Inventory  | FixtureID        | PMBy              |
| Harness_Inventory  | HarnessID        | PMBy              |

**Note:** The view `vw_Equipment_RequirePM` normalizes all these to `LastPMBy` for consistency.

## Error Handling

- Method includes try-catch block with debug logging
- Errors are re-thrown to ensure transaction rollback
- If equipment type is unknown, logs warning and returns safely
- SQL injection prevented through parameterized queries

## Testing Checklist

- [ ] Create new PM log and verify equipment table updates `LastPM`
- [ ] Verify correct column updated (`LastPMBy` vs `PMBy`) for each equipment type
- [ ] Update existing PM log and confirm equipment table reflects changes
- [ ] Test with Next PM Date populated
- [ ] Test with Next PM Date empty (NULL handling)
- [ ] Verify ATE equipment updates correctly
- [ ] Verify Asset equipment updates correctly
- [ ] Verify Fixture equipment updates correctly
- [ ] Verify Harness equipment updates correctly
- [ ] Create another PM log for same equipment and verify form auto-populates with updated values
- [ ] Check view `vw_Equipment_RequirePM` returns updated PM information

## Example Workflow

**Initial State:**
```
ATE_Inventory (ATEInventoryID = 5):
- LastPM: 2025-09-15 10:00
- LastPMBy: John Smith
- NextPM: 2025-10-15 10:00
```

**User Creates PM Log:**
- Equipment: ATE #5
- PM Date: 2025-10-09 14:30
- Performed By: Jane Doe
- Next PM Date: 2025-11-09 10:00

**After Save:**
```
PM_Log (new record):
- PMLogID: 42
- EquipmentType: ATE
- EquipmentID: 5
- PMDate: 2025-10-09 14:30
- PerformedBy: Jane Doe
- NextPMDate: 2025-11-09 10:00
- (all other PM details)

ATE_Inventory (ATEInventoryID = 5) - UPDATED:
- LastPM: 2025-10-09 14:30  ← Updated
- LastPMBy: Jane Doe         ← Updated
- NextPM: 2025-11-09 10:00   ← Updated
```

**Next PM Log Creation for Same Equipment:**
Form auto-populates with:
- Last PM Date: 10/09/2025 14:30
- Last PM By: Jane Doe
- Next PM: 11/09/2025 10:00
- Scheduled Date: 11/09/2025 (from NextPM)
