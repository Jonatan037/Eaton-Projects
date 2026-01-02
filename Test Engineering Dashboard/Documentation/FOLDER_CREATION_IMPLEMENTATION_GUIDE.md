# Implementation Checklist - Folder Creation for Calibration, PM, and Troubleshooting

## Overview
This guide shows exactly where to add folder creation calls in the existing pages.

---

## 1. Calibration Folder Creation

### Files to Update
- `CalibrationDetails.aspx.cs`

### Where to Add Code
Look for the database insert operation (usually `INSERT INTO Calibration` or similar).

### Code to Add (After Successful Insert)

```csharp
// After getting the new calibration ID from database
try
{
    // Get the equipment's Eaton ID from the form or database
    string equipmentEatonId = ddlEquipmentID.SelectedValue; // Or however you get it
    string calibrationId = newRecordId.ToString(); // The ID from the insert
    
    bool folderCreated = LocalFileSystemService.CreateCalibrationFolder(calibrationId, equipmentEatonId);
    if (folderCreated)
    {
        ShowMessage("Calibration record created successfully. Document folder created.", "success");
    }
    else
    {
        string error = LocalFileSystemService.GetLastError();
        ShowMessage("Calibration record created successfully. Folder creation failed: " + error, "warning");
    }
}
catch (Exception ex)
{
    ShowMessage("Calibration record created successfully. (Folder error: " + ex.Message + ")", "warning");
}
```

### Search Pattern
Look for code similar to:
```csharp
// Insert calibration record
cmd.CommandText = "INSERT INTO Calibration ...";
int newId = Convert.ToInt32(cmd.ExecuteScalar());
```

Add folder creation right after this.

---

## 2. PM (Preventive Maintenance) Folder Creation

### Files to Update
- `PMDetails.aspx.cs`

### Where to Add Code
Look for the database insert operation for PM records.

### Code to Add (After Successful Insert)

```csharp
// After getting the new PM ID from database
try
{
    // Get the equipment's Eaton ID
    string equipmentEatonId = ddlEquipmentID.SelectedValue; // Or however you get it
    string pmId = newRecordId.ToString(); // The ID from the insert
    
    bool folderCreated = LocalFileSystemService.CreatePMFolder(pmId, equipmentEatonId);
    if (folderCreated)
    {
        ShowMessage("PM record created successfully. Document folder created.", "success");
    }
    else
    {
        string error = LocalFileSystemService.GetLastError();
        ShowMessage("PM record created successfully. Folder creation failed: " + error, "warning");
    }
}
catch (Exception ex)
{
    ShowMessage("PM record created successfully. (Folder error: " + ex.Message + ")", "warning");
}
```

### Search Pattern
Look for code similar to:
```csharp
// Insert PM record
cmd.CommandText = "INSERT INTO PreventiveMaintenance ...";
int newId = Convert.ToInt32(cmd.ExecuteScalar());
```

Add folder creation right after this.

---

## 3. Troubleshooting Folder Creation

### Files to Update
- `TroubleshootingDetails.aspx.cs`

### Where to Add Code
Look for the database insert operation for troubleshooting records.

### Code to Add (After Successful Insert)

```csharp
// After getting the new troubleshooting ID from database
try
{
    // Get the location from the form
    string location = txtLocation.Text; // Or however you get the location
    string troubleshootingId = newRecordId.ToString(); // The ID from the insert
    
    bool folderCreated = LocalFileSystemService.CreateTroubleshootingFolder(troubleshootingId, location);
    if (folderCreated)
    {
        ShowMessage("Troubleshooting record created successfully. Document folder created.", "success");
    }
    else
    {
        string error = LocalFileSystemService.GetLastError();
        ShowMessage("Troubleshooting record created successfully. Folder creation failed: " + error, "warning");
    }
}
catch (Exception ex)
{
    ShowMessage("Troubleshooting record created successfully. (Folder error: " + ex.Message + ")", "warning");
}
```

### Search Pattern
Look for code similar to:
```csharp
// Insert troubleshooting record
cmd.CommandText = "INSERT INTO Troubleshooting ...";
int newId = Convert.ToInt32(cmd.ExecuteScalar());
```

Add folder creation right after this.

---

## General Pattern

For all three types, follow this pattern:

1. **Find the database insert** - Look for `INSERT INTO` SQL commands
2. **Get the new record ID** - Usually returned by `ExecuteScalar()` or `SCOPE_IDENTITY()`
3. **Get required parameters**:
   - Calibration: `calibrationId`, `equipmentEatonId`
   - PM: `pmId`, `equipmentEatonId`
   - Troubleshooting: `troubleshootingId`, `location`
4. **Call the service method** - `LocalFileSystemService.Create...Folder(...)`
5. **Show success/error message** - Use existing `ShowMessage()` method

---

## Testing Checklist

After implementing each folder creation:

### Calibration
- [ ] Create a new calibration record
- [ ] Verify folder created at: `Storage/Calibration Logs/{CalibrationID}_{EatonID}/`
- [ ] Check banner message shows success
- [ ] Review `App_Data/FileSystemLog.txt` for log entry

### PM
- [ ] Create a new PM record
- [ ] Verify folder created at: `Storage/PM Logs/{PMID}_{EatonID}/`
- [ ] Check banner message shows success
- [ ] Review `App_Data/FileSystemLog.txt` for log entry

### Troubleshooting
- [ ] Create a new troubleshooting case
- [ ] Verify folder created at: `Storage/Troubleshooting/{TroubleshootingID}_{Location}/`
- [ ] Check banner message shows success
- [ ] Review `App_Data/FileSystemLog.txt` for log entry

---

## Common Issues

### Issue: "Object reference not set to an instance of an object"
**Cause**: Parameter is null
**Solution**: Add null checks before calling folder creation
```csharp
if (string.IsNullOrWhiteSpace(equipmentEatonId))
{
    // Don't create folder, just log warning
    ShowMessage("Equipment ID not found - folder not created", "warning");
    return;
}
```

### Issue: "Access denied"
**Cause**: IIS Application Pool doesn't have permissions
**Solution**: Grant Full Control to `IIS APPPOOL\[AppPoolName]` on Storage folder

### Issue: Folder not visible in File Explorer
**Cause**: Path might be relative
**Solution**: Check actual path in `FileSystemLog.txt` or use absolute path in Web.config

---

## Quick Reference - All Methods

```csharp
// Equipment (Already implemented in CreateNewItem.aspx.cs)
bool success = LocalFileSystemService.CreateEquipmentFolder(equipmentType, eatonId);

// Calibration (To implement in CalibrationDetails.aspx.cs)
bool success = LocalFileSystemService.CreateCalibrationFolder(calibrationId, equipmentEatonId);

// PM (To implement in PMDetails.aspx.cs)
bool success = LocalFileSystemService.CreatePMFolder(pmId, equipmentEatonId);

// Troubleshooting (To implement in TroubleshootingDetails.aspx.cs)
bool success = LocalFileSystemService.CreateTroubleshootingFolder(troubleshootingId, location);

// Get error if failed
string error = LocalFileSystemService.GetLastError();

// Get folder path (optional - for displaying or opening)
string path = LocalFileSystemService.GetEquipmentFolderPath(equipmentType, eatonId);
```

---

*This guide provides the exact steps to implement folder creation in the remaining pages. Follow the pattern used in CreateNewItem.aspx.cs.*
