# Local File System Storage - Visual Guide

## 📁 Complete Folder Structure

```
C:\WebApps\Test Engineering Dashboard\
│
├── (Your web application files)
│   ├── CreateNewItem.aspx
│   ├── Calibration.aspx
│   ├── PreventiveMaintenance.aspx
│   ├── Troubleshooting.aspx
│   └── ...
│
└── Storage/                                    ← Base storage folder
    │
    ├── Equipment Inventory/                    ← All equipment documents
    │   │
    │   ├── ATE/                                ← Automatic Test Equipment
    │   │   ├── YPO-ATE-9PXM-001/
    │   │   │   └── (Store equipment docs here: manuals, photos, certs)
    │   │   ├── YPO-ATE-9PXM-002/
    │   │   └── YPO-ATE-SPD-001/
    │   │
    │   ├── Asset/                              ← Test equipment assets
    │   │   ├── YPO-AST-DMM-001/
    │   │   │   └── (Store asset docs here: calibration certs, manuals)
    │   │   ├── YPO-AST-DMM-002/
    │   │   ├── YPO-AST-OSC-001/
    │   │   └── YPO-AST-PSU-001/
    │   │
    │   ├── Fixture/                            ← Test fixtures
    │   │   ├── YPO-FIX-SPD-001/
    │   │   │   └── (Store fixture docs here: drawings, specs)
    │   │   ├── YPO-FIX-SPD-002/
    │   │   └── YPO-FIX-9PXM-001/
    │   │
    │   └── Harness/                            ← Cable harnesses
    │       ├── YPO-HAR-ABC123/
    │       │   └── (Store harness docs here: wiring diagrams)
    │       └── YPO-HAR-XYZ789/
    │
    ├── Calibration Logs/                       ← Calibration records
    │   │
    │   ├── 1_YPO-ATE-9PXM-001/
    │   │   └── (Store cal reports, certificates, data sheets)
    │   ├── 2_YPO-AST-DMM-001/
    │   │   └── (Calibration ID 2 for DMM-001)
    │   ├── 3_YPO-AST-DMM-001/
    │   │   └── (Another calibration of same equipment)
    │   └── 42_YPO-AST-OSC-001/
    │
    ├── PM Logs/                                ← Preventive Maintenance
    │   │
    │   ├── 1_YPO-ATE-9PXM-001/
    │   │   └── (Store PM checklists, photos, reports)
    │   ├── 2_YPO-ATE-9PXM-001/
    │   │   └── (Next PM for same equipment)
    │   ├── 15_YPO-FIX-SPD-001/
    │   └── 28_YPO-AST-DMM-003/
    │
    └── Troubleshooting/                        ← Troubleshooting cases
        │
        ├── 1_Production Line A/
        │   └── (Store troubleshooting logs, photos, solutions)
        ├── 2_Test Lab/
        │   └── (Troubleshooting case ID 2 at Test Lab)
        ├── 8_9PXM - Switch Line/
        │   └── (Issue at 9PXM Switch Line)
        └── 12_Quality Lab/
```

---

## 🎯 Folder Naming Examples

### Equipment Folders
Format: `Equipment Inventory/{Type}/{Eaton ID}/`

| Equipment Type | Eaton ID | Folder Path |
|----------------|----------|-------------|
| ATE | YPO-ATE-9PXM-001 | `Equipment Inventory/ATE/YPO-ATE-9PXM-001/` |
| Asset (DMM) | YPO-AST-DMM-003 | `Equipment Inventory/Asset/YPO-AST-DMM-003/` |
| Fixture | YPO-FIX-SPD-001 | `Equipment Inventory/Fixture/YPO-FIX-SPD-001/` |
| Harness | YPO-HAR-ABC123 | `Equipment Inventory/Harness/YPO-HAR-ABC123/` |

### Calibration Folders
Format: `Calibration Logs/{Cal ID}_{Eaton ID}/`

| Calibration ID | Equipment | Folder Name |
|----------------|-----------|-------------|
| 1 | YPO-ATE-9PXM-001 | `1_YPO-ATE-9PXM-001` |
| 42 | YPO-AST-DMM-003 | `42_YPO-AST-DMM-003` |
| 100 | YPO-AST-OSC-001 | `100_YPO-AST-OSC-001` |

**Why this format?**
- Easy to sort by calibration date (ID usually chronological)
- Equipment ID helps identify which equipment without looking up database
- Underscore separator is easy to parse

### PM Folders
Format: `PM Logs/{PM ID}_{Eaton ID}/`

| PM ID | Equipment | Folder Name |
|-------|-----------|-------------|
| 1 | YPO-ATE-9PXM-001 | `1_YPO-ATE-9PXM-001` |
| 15 | YPO-FIX-SPD-001 | `15_YPO-FIX-SPD-001` |
| 28 | YPO-AST-DMM-003 | `28_YPO-AST-DMM-003` |

**Use Cases**:
- Store PM checklists (PDF)
- Before/after photos
- Maintenance reports
- Replacement part documentation

### Troubleshooting Folders
Format: `Troubleshooting/{TS ID}_{Location}/`

| Troubleshooting ID | Location | Folder Name |
|--------------------|----------|-------------|
| 1 | Production Line A | `1_Production Line A` |
| 8 | Test Lab | `8_Test Lab` |
| 12 | 9PXM - Switch Line | `12_9PXM - Switch Line` |

**Why include location?**
- Location context is critical for troubleshooting
- Multiple issues can occur in same location
- Helps identify patterns in specific areas

---

## 📝 What to Store in Each Folder

### Equipment Inventory Folders
```
Storage/Equipment Inventory/ATE/YPO-ATE-9PXM-001/
├── Equipment_Manual.pdf
├── Calibration_Certificate.pdf
├── Purchase_Order.pdf
├── Equipment_Photo.jpg
├── Specifications.xlsx
└── Maintenance_History.docx
```

### Calibration Folders
```
Storage/Calibration Logs/42_YPO-AST-DMM-003/
├── Calibration_Report.pdf
├── Certificate_of_Calibration.pdf
├── Raw_Data.csv
├── Before_Readings.xlsx
├── After_Readings.xlsx
└── Technician_Notes.txt
```

### PM Folders
```
Storage/PM Logs/15_YPO-FIX-SPD-001/
├── PM_Checklist_Completed.pdf
├── Before_Inspection_Photos/
│   ├── IMG001.jpg
│   ├── IMG002.jpg
│   └── IMG003.jpg
├── After_Cleaning_Photos/
│   └── IMG004.jpg
├── Parts_Replaced.xlsx
└── PM_Report.docx
```

### Troubleshooting Folders
```
Storage/Troubleshooting/8_Test Lab/
├── Issue_Description.docx
├── Error_Logs.txt
├── Problem_Photos/
│   ├── Defect001.jpg
│   └── Defect002.jpg
├── Solution_Documentation.pdf
├── Root_Cause_Analysis.xlsx
└── Corrective_Actions.docx
```

---

## 🔄 Workflow Example

### Creating New Equipment

```
User Actions:                          System Actions:
─────────────────────                  ──────────────────────────

1. Go to "Create New Item"

2. Select "ATE"

3. Fill in fields:
   - Location: 9PXM - Switch Line
   - Model: TestSystem3000
   - Serial: TS3K-12345
   
4. Click "Submit"                      → Generate Eaton ID: YPO-ATE-9PXM-001
                                       
                                       → Insert into database
                                       
                                       → Call LocalFileSystemService
                                         .CreateEquipmentFolder("ATE", 
                                         "YPO-ATE-9PXM-001")
                                       
                                       → Create folder:
                                         Storage/
                                           Equipment Inventory/
                                             ATE/
                                               YPO-ATE-9PXM-001/
                                       
5. See banner:                         → Log to FileSystemLog.txt
   "ATE item created successfully.
    Document folder created."

6. Navigate to details page            → Optional: Show "Open Folder" button
                                          with link to folder path
```

### Creating Calibration Record

```
User Actions:                          System Actions:
─────────────────────                  ──────────────────────────

1. Go to "Calibration"

2. Click "New Calibration"

3. Select Equipment:
   YPO-AST-DMM-003

4. Enter calibration data

5. Click "Save"                        → Insert into Calibration table
                                       
                                       → Get new ID: 42
                                       
                                       → Call LocalFileSystemService
                                         .CreateCalibrationFolder("42",
                                         "YPO-AST-DMM-003")
                                       
                                       → Create folder:
                                         Storage/
                                           Calibration Logs/
                                             42_YPO-AST-DMM-003/
                                       
6. See success message                 → Ready to upload calibration docs
```

---

## 🎨 UI Enhancement Ideas (Future)

### 1. "Open Folder" Button
Add button to detail pages to open folder in File Explorer:
```csharp
protected void btnOpenFolder_Click(object sender, EventArgs e)
{
    string path = LocalFileSystemService.GetEquipmentFolderPath("ATE", eatonId);
    if (path != null)
    {
        // Open in File Explorer
        System.Diagnostics.Process.Start("explorer.exe", path);
    }
}
```

### 2. Show Folder Path
Display folder location in equipment details:
```
Document Storage Location:
C:\WebApps\Test Engineering Dashboard\Storage\Equipment Inventory\ATE\YPO-ATE-9PXM-001\
[Open Folder] [Copy Path]
```

### 3. File Upload Control
Add file upload directly to folder:
```html
<asp:FileUpload ID="fileUpload" runat="server" AllowMultiple="true" />
<asp:Button ID="btnUpload" runat="server" Text="Upload Documents" 
            OnClick="btnUpload_Click" />
```

### 4. Document List
Show files in folder with preview/download:
```
Documents (3):
- Equipment_Manual.pdf (2.5 MB) [Download] [Delete]
- Calibration_Certificate.pdf (156 KB) [Download] [Delete]
- Photo.jpg (800 KB) [Download] [Delete]
[+ Upload New Document]
```

---

## ⚙️ Configuration Options

### Default Configuration (Relative Path)
```xml
<add key="LocalStorage.BasePath" value="~/Storage" />
```
**Result**: `C:\WebApps\Test Engineering Dashboard\Storage\`

**Pros**: Simple, contained within application
**Cons**: Large files in web folder, included in backups

### Production Configuration (Separate Drive)
```xml
<add key="LocalStorage.BasePath" value="D:\TEDStorage" />
```
**Result**: `D:\TEDStorage\`

**Pros**: Separate from web app, better performance, easier backup
**Cons**: Need to set permissions on separate drive

### Network Share Configuration
```xml
<add key="LocalStorage.BasePath" value="\\SERVER\TEDStorage" />
```
**Result**: `\\SERVER\TEDStorage\`

**Pros**: Centralized storage, accessible from multiple servers
**Cons**: Network dependency, permissions complexity

---

*This visual guide shows the complete folder structure and naming conventions for the local storage system.*
