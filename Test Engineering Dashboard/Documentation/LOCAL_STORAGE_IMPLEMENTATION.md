# Local File System Storage Implementation

## Overview

The Test Engineering Dashboard now uses a **local file system** for document storage instead of SharePoint. This provides:
- ✅ **No authentication issues** - Direct file system access
- ✅ **Better performance** - No network latency
- ✅ **Simpler maintenance** - No cloud service dependencies
- ✅ **Full control** - Complete ownership of data

## Folder Structure

All documents are stored under the base storage path configured in `Web.config`:

```
Storage/
├── Equipment Inventory/
│   ├── ATE/
│   │   ├── YPO-ATE-9PXM-001/
│   │   ├── YPO-ATE-9PXM-002/
│   │   └── ...
│   ├── Asset/
│   │   ├── YPO-AST-DMM-001/
│   │   ├── YPO-AST-OSC-001/
│   │   └── ...
│   ├── Fixture/
│   │   ├── YPO-FIX-SPD-001/
│   │   └── ...
│   └── Harness/
│       ├── YPO-HAR-ABC123/
│       └── ...
├── Calibration Logs/
│   ├── 1_YPO-ATE-9PXM-001/
│   ├── 2_YPO-AST-DMM-001/
│   └── ...
├── PM Logs/
│   ├── 1_YPO-ATE-9PXM-001/
│   ├── 2_YPO-FIX-SPD-001/
│   └── ...
└── Troubleshooting/
    ├── 1_Production Line A/
    ├── 2_Test Lab/
    └── ...
```

## Naming Conventions

### Equipment Inventory Folders
**Format**: `{EquipmentType}/{EatonID}/`

**Examples**:
- `Equipment Inventory/ATE/YPO-ATE-9PXM-001/`
- `Equipment Inventory/Asset/YPO-AST-DMM-003/`
- `Equipment Inventory/Fixture/YPO-FIX-SPD-001/`
- `Equipment Inventory/Harness/YPO-HAR-ABC123/`

### Calibration Folders
**Format**: `Calibration Logs/{CalibrationID}_{EquipmentEatonID}/`

**Examples**:
- `Calibration Logs/1_YPO-ATE-9PXM-001/`
- `Calibration Logs/42_YPO-AST-DMM-003/`

### PM (Preventive Maintenance) Folders
**Format**: `PM Logs/{PMID}_{EquipmentEatonID}/`

**Examples**:
- `PM Logs/1_YPO-ATE-9PXM-001/`
- `PM Logs/15_YPO-FIX-SPD-001/`

### Troubleshooting Folders
**Format**: `Troubleshooting/{TroubleshootingID}_{Location}/`

**Examples**:
- `Troubleshooting/1_Production Line A/`
- `Troubleshooting/8_Test Lab/`
- `Troubleshooting/12_9PXM - Switch Line/`

## Configuration

### Web.config Setting

```xml
<!-- Local File System Storage - Base path for all document folders -->
<!-- Can be app-relative (~/Storage) or absolute path (e.g., D:\TEDStorage) -->
<add key="LocalStorage.BasePath" value="~/Storage" />
```

### Recommended Paths

**Development (IIS Express)**:
```xml
<add key="LocalStorage.BasePath" value="~/Storage" />
```
This creates: `c:\_WebApps\Test Engineering Dashboard\Storage\`

**Production (Dedicated Drive)**:
```xml
<add key="LocalStorage.BasePath" value="D:\TEDStorage" />
```
This creates: `D:\TEDStorage\`

## Implementation Details

### LocalFileSystemService.cs

Located in `App_Code/LocalFileSystemService.cs`, this service provides:

#### Methods

1. **CreateEquipmentFolder(equipmentType, eatonId)**
   - Creates folder for new equipment
   - Returns `true` if successful
   - Called automatically when equipment is created

2. **CreateCalibrationFolder(calibrationId, equipmentEatonId)**
   - Creates folder for new calibration log
   - Returns `true` if successful
   - Should be called when calibration record is created

3. **CreatePMFolder(pmId, equipmentEatonId)**
   - Creates folder for new PM log
   - Returns `true` if successful
   - Should be called when PM record is created

4. **CreateTroubleshootingFolder(troubleshootingId, location)**
   - Creates folder for new troubleshooting case
   - Returns `true` if successful
   - Should be called when troubleshooting record is created

5. **GetEquipmentFolderPath(equipmentType, eatonId)**
   - Returns physical path to equipment folder
   - Returns `null` if folder doesn't exist
   - Useful for displaying folder location in UI

6. **GetLastError()**
   - Returns last error message
   - Used for error display in UI

#### Features

- ✅ **Automatic folder creation** - Creates parent directories as needed
- ✅ **Path sanitization** - Removes invalid characters from folder names
- ✅ **Error handling** - Catches and logs all errors
- ✅ **Logging** - Writes to `App_Data/FileSystemLog.txt`

## Usage Examples

### When Creating Equipment (Already Implemented)

```csharp
// In CreateNewItem.aspx.cs - CreateATEItem(), CreateAssetItem(), etc.
try
{
    bool folderCreated = LocalFileSystemService.CreateEquipmentFolder("ATE", eatonId);
    if (folderCreated)
    {
        ShowMessage("ATE item created successfully. Document folder created.", "success");
    }
    else
    {
        string error = LocalFileSystemService.GetLastError();
        ShowMessage("ATE item created successfully. Folder creation failed: " + error, "warning");
    }
}
catch (Exception ex)
{
    ShowMessage("ATE item created successfully. (Folder error: " + ex.Message + ")", "warning");
}
```

### When Creating Calibration Log (To Be Implemented)

```csharp
// In Calibration.aspx.cs or CalibrationDetails.aspx.cs
// After inserting calibration record into database
try
{
    string calibrationId = newRecordId.ToString();
    string equipmentEatonId = eatonIdFromDatabase;
    
    bool folderCreated = LocalFileSystemService.CreateCalibrationFolder(calibrationId, equipmentEatonId);
    if (folderCreated)
    {
        // Success - folder created
    }
}
catch (Exception ex)
{
    // Handle error
}
```

### When Creating PM Log (To Be Implemented)

```csharp
// In PreventiveMaintenance.aspx.cs or PMDetails.aspx.cs
// After inserting PM record into database
try
{
    string pmId = newRecordId.ToString();
    string equipmentEatonId = eatonIdFromDatabase;
    
    bool folderCreated = LocalFileSystemService.CreatePMFolder(pmId, equipmentEatonId);
    if (folderCreated)
    {
        // Success - folder created
    }
}
catch (Exception ex)
{
    // Handle error
}
```

### When Creating Troubleshooting Case (To Be Implemented)

```csharp
// In Troubleshooting.aspx.cs or TroubleshootingDetails.aspx.cs
// After inserting troubleshooting record into database
try
{
    string troubleshootingId = newRecordId.ToString();
    string location = locationFromForm;
    
    bool folderCreated = LocalFileSystemService.CreateTroubleshootingFolder(troubleshootingId, location);
    if (folderCreated)
    {
        // Success - folder created
    }
}
catch (Exception ex)
{
    // Handle error
}
```

### Getting Folder Path

```csharp
// Get the physical path to display or use in file operations
string folderPath = LocalFileSystemService.GetEquipmentFolderPath("ATE", "YPO-ATE-9PXM-001");
if (folderPath != null)
{
    // Folder exists - you can display path or open it
    lblFolderPath.Text = folderPath;
}
```

## Next Steps

### 1. ✅ Equipment Inventory - COMPLETED
Folders are automatically created when new equipment is added via `CreateNewItem.aspx`

### 2. ⚠️ Calibration Logs - TO IMPLEMENT
Update the calibration creation code to call:
```csharp
LocalFileSystemService.CreateCalibrationFolder(calibrationId, equipmentEatonId);
```

**Files to modify**:
- `Calibration.aspx.cs` - When creating new calibration record
- `CalibrationDetails.aspx.cs` - When saving new calibration

### 3. ⚠️ PM Logs - TO IMPLEMENT
Update the PM creation code to call:
```csharp
LocalFileSystemService.CreatePMFolder(pmId, equipmentEatonId);
```

**Files to modify**:
- `PreventiveMaintenance.aspx.cs` - When creating new PM record
- `PMDetails.aspx.cs` - When saving new PM

### 4. ⚠️ Troubleshooting - TO IMPLEMENT
Update the troubleshooting creation code to call:
```csharp
LocalFileSystemService.CreateTroubleshootingFolder(troubleshootingId, location);
```

**Files to modify**:
- `Troubleshooting.aspx.cs` - When creating new troubleshooting case
- `TroubleshootingDetails.aspx.cs` - When saving new troubleshooting

### 5. Optional Enhancements
- Add "Open Folder" buttons in detail pages
- Display folder path in equipment details
- Add file upload controls to store documents in folders
- Create folder cleanup for deleted records

## Permissions

Ensure the IIS Application Pool identity has:
- ✅ **Read** permissions on the Storage folder
- ✅ **Write** permissions on the Storage folder
- ✅ **Create Folders** permissions on the Storage folder

Default Application Pool identity: `IIS APPPOOL\TestEngineeringDashboard` (or similar)

## Logging

All folder creation operations are logged to:
- **File**: `App_Data/FileSystemLog.txt`
- **Debug Output**: Visual Studio Debug window
- **Trace**: Windows Event Tracing

Log format:
```
2025-10-20 14:35:22 - Created equipment folder: C:\WebApps\Test Engineering Dashboard\Storage\Equipment Inventory\ATE\YPO-ATE-9PXM-001
```

## Troubleshooting

### Folder Not Created
1. Check IIS Application Pool permissions
2. Review `App_Data/FileSystemLog.txt` for errors
3. Verify `LocalStorage.BasePath` in Web.config
4. Ensure drive has sufficient space

### Access Denied Errors
1. Right-click Storage folder → Properties → Security
2. Add `IIS APPPOOL\[YourAppPoolName]` with Full Control
3. Restart IIS Application Pool

### Path Too Long Errors
Windows has a 260-character path limit. Solutions:
1. Use shorter equipment IDs
2. Move storage to root drive (e.g., `D:\TEDStorage`)
3. Enable long path support in Windows 10+

## Migration from SharePoint

The SharePoint integration code has been removed from:
- ✅ `CreateNewItem.aspx.cs` - Updated to use LocalFileSystemService
- ✅ `Web.config` - SharePoint settings removed
- 🗑️ `App_Code/SharePointService.cs` - Can be deleted (optional)

No data migration needed - this only affects future records.

---
*Last Updated: October 20, 2025*
*Implementation Status: Equipment ✅ | Calibration ⚠️ | PM ⚠️ | Troubleshooting ⚠️*
