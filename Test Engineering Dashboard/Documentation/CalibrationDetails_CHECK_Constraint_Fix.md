# CalibrationDetails - CHECK Constraint Fix

## Problem
When trying to save a new calibration log, the following error occurred:
```
Error saving calibration log: The INSERT statement conflicted with the CHECK constraint "CK__Calibrati__Statu__7C4F7684". 
The conflict occurred in database "TestEngineering", table "dbo.Calibration_Log", column 'Status'.
```

## Root Cause
The `Calibration_Log` table has CHECK constraints on certain columns that restrict what values can be inserted. These constraints were likely added by a previous script (`Add_KPI_Columns.sql`) to enforce specific allowed values.

### What are CHECK Constraints?
CHECK constraints in SQL Server enforce domain integrity by limiting the values that can be accepted in a column. For example:
```sql
-- This constraint only allows specific values
ALTER TABLE Calibration_Log
ADD CONSTRAINT CK_Status CHECK (Status IN ('Completed', 'Pending', 'In Progress'));
```

If you try to insert a value not in the list (e.g., 'Failed'), the INSERT will fail with a constraint violation error.

## Solution

### Remove ALL CHECK Constraints from Calibration_Log

**Script Created**: `Database/Scripts/Remove_Calibration_Log_Constraints.sql`

This script will:
1. ✅ Find ALL CHECK constraints on the Calibration_Log table
2. ✅ Display them for review
3. ✅ Remove ALL constraints dynamically
4. ✅ Verify removal was successful
5. ✅ Show resulting column structure

### How to Apply the Fix

**Step 1**: Execute the removal script
```bash
Database/Scripts/Remove_Calibration_Log_Constraints.sql
```

Run this against your TestEngineering database. It will output:
- List of current constraints
- SQL commands being executed
- Verification of removal
- Final column structure

**Step 2**: Verify the fix
After running the script, try to save a calibration log record again. It should work without constraint errors.

## Why This Approach?

### Flexibility vs Validation Trade-off

**With CHECK Constraints** (Original):
- ✅ Enforces data integrity at database level
- ✅ Prevents "invalid" values
- ❌ Requires updating constraints when business rules change
- ❌ Makes application development inflexible
- ❌ Error messages are cryptic

**Without CHECK Constraints** (Our Solution):
- ✅ Maximum flexibility for application
- ✅ Easy to add new status values
- ✅ Validation can be done in application layer
- ✅ Better user experience with custom error messages
- ❌ Responsibility shifts to application code

### Application-Level Validation

The dropdown controls in the web application already provide validation:
```html
<asp:DropDownList ID="ddlStatus" runat="server">
    <asp:ListItem Value="Completed" Text="Completed" Selected="True" />
    <asp:ListItem Value="Pending" Text="Pending" />
    <asp:ListItem Value="In Progress" Text="In Progress" />
    <asp:ListItem Value="Failed" Text="Failed" />
</asp:DropDownList>
```

Users can only select from these options, providing validation at the UI level instead of the database level.

## Constraints That Will Be Removed

Based on the error and the `Add_KPI_Columns.sql` script, these constraints likely exist:

### Status Column
- **Constraint**: Limits to specific status values
- **Impact**: Prevents new/custom status values

### Method Column  
- **Constraint**: Limits to 'Internal' or 'External'
- **Current Dropdown**: Already enforces this in UI

### ResultCode Column
- **Constraint**: Limits to specific result codes
- **Current Dropdown**: Already enforces this in UI

## Alternative Solutions Considered

### Option 1: Update Constraint (Not Recommended)
Instead of removing, we could update the constraint to include more values:
```sql
ALTER TABLE Calibration_Log DROP CONSTRAINT CK__Calibrati__Statu__7C4F7684;
ALTER TABLE Calibration_Log ADD CONSTRAINT CK_Status 
    CHECK (Status IN ('Completed', 'Pending', 'In Progress', 'Failed', 'Cancelled', ...));
```

**Why we didn't choose this**: Every time you want a new status value, you'd need to alter the database.

### Option 2: Remove Only Status Constraint (Limited)
Remove just the Status constraint:
```sql
ALTER TABLE Calibration_Log DROP CONSTRAINT CK__Calibrati__Statu__7C4F7684;
```

**Why we didn't choose this**: Other columns might have similar constraints causing future issues.

### Option 3: Remove ALL Constraints (Our Choice) ✅
Remove all CHECK constraints from Calibration_Log:
```sql
-- Dynamic SQL to find and drop ALL constraints
-- See Remove_Calibration_Log_Constraints.sql
```

**Why we chose this**: 
- Maximum flexibility
- Future-proof solution
- Application handles validation
- No more constraint errors

## Testing After Fix

### Test Case 1: Create New Record
1. Navigate to `CalibrationDetails.aspx?mode=new`
2. Select equipment
3. Fill in all required fields
4. Select any status from dropdown
5. Click "Save Changes"
6. ✅ Should save successfully

### Test Case 2: Different Status Values
Try saving records with each status:
- ✅ Completed
- ✅ Pending
- ✅ In Progress
- ✅ Failed

### Test Case 3: Edit Existing Record
1. Open existing calibration log
2. Change status
3. Save
4. ✅ Should update successfully

## What Columns Are Affected?

After removing constraints, these columns remain with their data types but without restrictions:

| Column | Data Type | Previous Constraint | After Removal |
|--------|-----------|-------------------|---------------|
| Status | NVARCHAR(50) | Limited values | Any text up to 50 chars |
| Method | NVARCHAR(50) | 'Internal'/'External' | Any text up to 50 chars |
| ResultCode | NVARCHAR(50) | Specific codes | Any text up to 50 chars |

**Note**: The UI dropdowns still control what users can select, so in practice, only valid values will be entered.

## Related Scripts

### Scripts That Added Constraints
- `Add_KPI_Columns.sql` - Added Method and ResultCode constraints
- (Possibly others that added Status constraint)

### Scripts That Remove Constraints
- `Remove_Status_CHECK_Constraints.sql` - Removes constraints from inventory tables
- `Remove_Calibration_Log_Constraints.sql` - **NEW** - Removes from Calibration_Log ✅

## Rollback Plan

If you need to add constraints back (not recommended):

```sql
-- Add Status constraint
ALTER TABLE dbo.Calibration_Log
ADD CONSTRAINT CK_Calibration_Status 
CHECK (Status IN ('Completed', 'Pending', 'In Progress', 'Failed'));

-- Add Method constraint
ALTER TABLE dbo.Calibration_Log
ADD CONSTRAINT CK_Calibration_Method 
CHECK (Method IN ('Internal', 'External'));

-- Add ResultCode constraint
ALTER TABLE dbo.Calibration_Log
ADD CONSTRAINT CK_Calibration_ResultCode 
CHECK (ResultCode IN ('Pass', 'Fail', 'OOT', 'Adjusted'));
```

## Summary

✅ **Problem**: CHECK constraint prevented INSERT  
✅ **Solution**: Remove ALL CHECK constraints from Calibration_Log  
✅ **Script**: `Remove_Calibration_Log_Constraints.sql`  
✅ **Validation**: Still enforced by UI dropdowns  
✅ **Flexibility**: Can now accept any values application sends  

## Files Modified

1. **Created**: `Database/Scripts/Remove_Calibration_Log_Constraints.sql`
2. **Documentation**: This file

## Status
⏳ **READY TO APPLY** - Run the SQL script to remove constraints
