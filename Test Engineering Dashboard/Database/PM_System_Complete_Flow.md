# PM System - Complete Data Flow

## System Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                          PM Details Form                             │
│                                                                       │
│  1. User selects Equipment → ddlEquipmentID_SelectedIndexChanged()  │
│     ↓                                                                 │
│  2. LoadEquipmentDetails() queries vw_Equipment_RequirePM            │
│     ↓                                                                 │
│  3. Auto-populates 7 fields:                                         │
│     - Equipment Type (locked)                                        │
│     - PM Frequency                                                   │
│     - PM Responsible                                                 │
│     - Last PM Date                                                   │
│     - Last PM By                                                     │
│     - Next PM                                                        │
│     - PM Estimated Time                                              │
│     - Scheduled Date (from NextPM)                                   │
│                                                                       │
│  4. User fills remaining fields and clicks Save                      │
└─────────────────────────────────────────────────────────────────────┘
                                    ↓
┌─────────────────────────────────────────────────────────────────────┐
│                        btnSave_Click() Logic                         │
│                                                                       │
│  Step 1: Parse equipment selection (EquipmentType|EquipmentID)      │
│  Step 2: Validate required fields                                   │
│  Step 3: Get ScheduledDate from equipment's NextPM (new mode only)  │
│  Step 4: INSERT/UPDATE PM_Log table                                 │
│  Step 5: Handle file uploads                                        │
│  Step 6: ⭐ UpdateEquipmentPMFields() ⭐                             │
│          Updates inventory table with:                               │
│          - LastPM = PM Date                                          │
│          - LastPMBy/PMBy = Performed By                              │
│          - NextPM = Next PM Date                                     │
└─────────────────────────────────────────────────────────────────────┘
                                    ↓
┌─────────────────────────────────────────────────────────────────────┐
│                       Database Updates                               │
│                                                                       │
│  PM_Log Table:                                                       │
│  ┌──────────────────────────────────────────────────────┐           │
│  │ PMLogID (PK)                                         │           │
│  │ EquipmentType                                        │           │
│  │ EquipmentID                                          │           │
│  │ ScheduledDate ← From equipment's NextPM             │           │
│  │ PMDate, NextPMDate, PMType                          │           │
│  │ MaintenancePerformed, PerformedBy                   │           │
│  │ ActualStartTime, ActualEndTime, Downtime            │           │
│  │ PartsReplaced, Cost, Status, Comments               │           │
│  │ AttachmentsPath, CreatedBy, CreatedDate             │           │
│  └──────────────────────────────────────────────────────┘           │
│                          ↓                                           │
│  Equipment Inventory Tables (Auto-Updated):                         │
│  ┌──────────────────────────────────────────────────────┐           │
│  │ ATE_Inventory / Asset_Inventory /                   │           │
│  │ Fixture_Inventory / Harness_Inventory               │           │
│  │                                                      │           │
│  │ LastPM ← Updated with PM Date                       │           │
│  │ LastPMBy/PMBy ← Updated with Performed By           │           │
│  │ NextPM ← Updated with Next PM Date                  │           │
│  │ PMFrequency, PMResponsible (unchanged)              │           │
│  │ PMEstimatedTime (unchanged)                         │           │
│  └──────────────────────────────────────────────────────┘           │
└─────────────────────────────────────────────────────────────────────┘
                                    ↓
┌─────────────────────────────────────────────────────────────────────┐
│                    vw_Equipment_RequirePM View                       │
│                    (Always returns current data)                     │
│                                                                       │
│  SELECT EquipmentType, EquipmentID, EatonID, EquipmentName,         │
│         Location, PMFrequency, PMResponsible,                        │
│         LastPM, LastPMBy, NextPM, PMEstimatedTime                   │
│  FROM (ATE_Inventory UNION Asset_Inventory UNION                    │
│        Fixture_Inventory UNION Harness_Inventory)                   │
│  WHERE RequiredPM = 1 AND IsActive = 1                              │
│                                                                       │
│  → Next PM log creation will show updated LastPM, LastPMBy, NextPM  │
└─────────────────────────────────────────────────────────────────────┘
```

## Key Features

### 1. Bidirectional Data Sync
- **Equipment → PM Form:** Auto-populates PM history when equipment selected
- **PM Form → Equipment:** Updates equipment record when PM log saved

### 2. Data Integrity
- Equipment tables always reflect latest PM activity
- PM_Log preserves complete historical record
- View provides unified access to current PM status

### 3. Workflow Efficiency
- Technicians see current PM status automatically
- No manual updates to equipment records needed
- Scheduled Date auto-set from equipment's NextPM

### 4. Column Name Normalization
```
Database Reality:
  ATE_Inventory.LastPMBy
  Asset_Inventory.PMBy
  Fixture_Inventory.PMBy
  Harness_Inventory.PMBy

View Abstraction:
  vw_Equipment_RequirePM.LastPMBy (all normalized)

Code Handling:
  UpdateEquipmentPMFields() uses correct column per table
```

## Complete CRUD Operations

### CREATE (New PM Log)
1. Select equipment → auto-populate current PM info
2. Fill form fields
3. Save → Creates PM_Log record
4. **Auto-updates equipment table with new PM info**

### READ (View PM Log)
1. LoadPMData() retrieves PM_Log record
2. LoadEquipmentDropdown() populates equipment list
3. LoadEquipmentDetails() shows equipment PM history

### UPDATE (Edit PM Log)
1. Load existing PM_Log data
2. Modify fields
3. Save → Updates PM_Log record
4. **Auto-updates equipment table with revised PM info**

### DELETE (Remove PM Log)
1. btnDelete_Click() removes PM_Log record
2. Equipment table retains PM info
3. *Note: Consider adding logic to revert equipment to previous PM if needed*

## Transaction Safety

Both operations use the same SqlConnection:
```csharp
using (var conn = new SqlConnection(cs))
{
    conn.Open();
    
    // Operation 1: Save PM Log
    cmd.ExecuteNonQuery();
    
    // Operation 2: Update Equipment Table
    UpdateEquipmentPMFields(conn, ...);
    
    // If either fails, both rollback (implicit transaction)
}
```

## Testing Scenarios

### Scenario 1: First PM for New Equipment
- Equipment has no LastPM data
- Create PM log
- Verify equipment table gets populated

### Scenario 2: Regular PM
- Equipment has existing PM data
- Form auto-populates with existing PM info
- Create new PM log
- Verify equipment table updates to new PM info

### Scenario 3: Correcting PM Date
- Edit existing PM log, change PM Date
- Save
- Verify equipment table reflects corrected date

### Scenario 4: Multiple Equipment Types
- Test ATE equipment (uses LastPMBy)
- Test Asset equipment (uses PMBy)
- Test Fixture equipment (uses PMBy)
- Test Harness equipment (uses PMBy)
- Verify all update correctly

### Scenario 5: NextPM Management
- Save PM with Next PM Date populated
- Save PM with Next PM Date empty (NULL)
- Verify both cases handled correctly
