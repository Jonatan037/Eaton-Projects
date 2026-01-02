# Equipment Grid View - Recent Changes Summary

## Date: 2025
## File: EquipmentGridView.aspx / EquipmentGridView.aspx.cs

---

## Summary of All Completed Enhancements

### 1. ✅ Reset Icon Button (COMPLETED)
**Location:** Filter panel header  
**Files Modified:**
- `EquipmentGridView.aspx` (Lines 808-824, 91-155, 1103)

**Changes:**
- Added reset icon button with SVG refresh/rotate icon in filter header
- Button positioned between "Filters" title and collapse toggle
- Styled with 28×28px size, border, background color
- Hover effect: Red color (rgba(239,68,68)) with -180deg rotation animation
- JavaScript function `resetAllFilters()` triggers server-side reset button
- Light/dark theme support

**User Benefit:** Quick one-click filter reset without scrolling

---

### 2. ✅ CalibrationEstimatedTime and PMEstimatedTime Columns (COMPLETED)
**Location:** Grid columns after "Cal By" and "PM By"  
**Files Modified:**
- `EquipmentGridView.aspx.cs` (Multiple locations)

**Backend Changes:**
- **DataTable Definition** (Lines 428-446): Added 2 new columns → Total 32 columns
  - `CalibrationEstimatedTime` after `CalibratedBy`
  - `PMEstimatedTime` after `PMBy`
  
- **SQL Queries** (4 tables updated):
  - Asset_Inventory (Lines 468-493): Added `ISNULL([CalibrationEstimatedTime],'')` and `ISNULL([PMEstimatedTime],'')`
  - Fixture_Inventory (Lines 507-535): Same additions
  - Harness_Inventory (Lines 543-571): Same additions
  - ATE_Inventory (Lines 576-604): Same additions
  
- **LoadTableData()** (Lines 650-653): Populate new columns from database
  ```csharp
  row["CalibrationEstimatedTime"] = GetSafeValue(reader, "CalibrationEstimatedTime");
  row["PMEstimatedTime"] = GetSafeValue(reader, "PMEstimatedTime");
  ```

**Frontend Changes:**
- **BuildGridColumns()** (Lines 983-992, 1041-1050):
  - Added CalibrationEstimatedTime BoundField after CalibratedBy
  - Added PMEstimatedTime BoundField after PMBy
  - Both use CSS class `col-time`
  - Header texts: "Cal Est Time" and "PM Est Time"

- **CSV Export** (Lines 1238-1258):
  - Updated header string to include new columns (30→32 columns)
  - Changed cell array size from 30 to 32
  - CSV now exports: `...,Cal By,Cal Est Time,Next Cal,...,PM By,PM Est Time,Next PM,...`

**User Benefit:** Track estimated time for calibration and PM activities, exportable to CSV for analysis

---

### 3. ✅ Header Styling with Inline Styles (COMPLETED - NEW APPROACH)
**Location:** Table headers  
**Files Modified:**
- `EquipmentGridView.aspx.cs` (Lines 1073-1089)

**Changes:**
Previous CSS approach with !important flags wasn't working due to ASP.NET GridView overrides.  
New approach uses inline styles in `gridEquipment_RowDataBound()`:

```csharp
if (e.Row.RowType == DataControlRowType.Header)
{
    e.Row.Height = System.Web.UI.WebControls.Unit.Pixel(48);
    e.Row.BackColor = System.Drawing.ColorTranslator.FromHtml("#0b63ce");
    e.Row.ForeColor = System.Drawing.Color.White;
    e.Row.Font.Bold = true;
    e.Row.Font.Size = FontUnit.Point(11);
    foreach (TableCell cell in e.Row.Cells)
    {
        cell.Style["padding"] = "12px 8px";
        cell.Style["text-align"] = "left";
        cell.Style["border-bottom"] = "2px solid #0a58b8";
    }
}
```

**Styling Details:**
- Height: 48px (larger for better visibility)
- Background: Blue gradient (#0b63ce)
- Text: White, bold, 11pt font
- Padding: 12px vertical, 8px horizontal
- Border: 2px solid bottom border (#0a58b8)

**User Benefit:** Headers now clearly visible and styled consistently with theme

---

### 4. ✅ Status, Last Cal, Last PM Bubble Badges (COMPLETED)
**Location:** Status, Last Calibration, Last PM columns  
**Files Modified:**
- `EquipmentGridView.aspx.cs` (Lines 1091-1162)
- `EquipmentGridView.aspx` (Lines 653-737)

**Backend Logic - RowDataBound Event:**

**Status Column (Column 12):**
- Wraps status text in colored badge: `<span class='status-badge status-{value}'>`
- Classes: `status-operational`, `status-maintenance`, `status-out-of-service`, etc.
- Handles spaces and underscores in status names

**Last Calibration Column (Column 17):**
- Calls `StyleLastActivityCell()` with "calibration" type
- Color logic based on days since last calibration:
  - **Green** (activity-good): Less than 180 days (recent)
  - **Yellow** (activity-warning): 180-365 days (getting old)
  - **Red** (activity-overdue): More than 365 days (very old)
  - **Gray** (activity-none): N/A or null

**Last PM Column (Column 25):**
- Same color logic as Last Calibration
- Helps identify equipment needing PM attention

**Frontend CSS:**
```css
.activity-badge {
    display:inline-flex;
    align-items:center;
    gap:4px;
    padding:3px 7px;
    border-radius:5px;
    font-size:8.5px;
    font-weight:700;
    letter-spacing:.3px;
    white-space:nowrap;
}
.activity-badge::before {
    content:'';
    width:4px;
    height:4px;
    border-radius:50%;
    flex-shrink:0;
}
```

**Color Schemes:**
- **activity-good**: Green background (rgba(16,185,129,.15)), glowing dot
- **activity-warning**: Yellow background (rgba(245,158,11,.15)), glowing dot
- **activity-overdue**: Red background (rgba(239,68,68,.15)), glowing dot
- **activity-none**: Gray background (rgba(100,116,139,.15)), dim

**Light Mode Support:**
- Darker backgrounds, darker text colors for better contrast
- `.theme-light` and `[data-theme='light']` selectors

**User Benefit:** Instant visual identification of equipment status and maintenance urgency

---

## Column Order Reference (32 Total Columns)

1. **EquipmentType** - Badge styled (Asset/ATE/Fixture/Harness)
2. **EatonID** - Unique identifier
3. **Model** - Model number
4. **Name** - Equipment name
5. **Description** - Full description
6. **ATE** - Associated ATE
7. **Location** - Physical location
8. **DeviceType** - Type classification
9. **Manufacturer** - Manufacturer name
10. **ManufacturerSite** - Manufacturer website
11. **Folder** - File folder path
12. **Image** - Image path
13. **Status** - 🎯 **BUBBLE BADGE** (Operational/Maintenance/Out-of-Service)
14. **RequiresCal** - Requires calibration flag
15. **CalibrationID** - Calibration ID
16. **CalibrationFrequency** - Frequency in days
17. **LastCalibration** - 🎯 **BUBBLE BADGE** with date-based colors (Green/Yellow/Red)
18. **CalibratedBy** - Person who calibrated
19. **CalibrationEstimatedTime** - ⭐ **NEW** - Estimated time for calibration
20. **NextCalibration** - Next due date
21. **RequiresPM** - Requires PM flag
22. **PMFrequency** - PM frequency
23. **PMResponsible** - Person responsible
24. **LastPM** - 🎯 **BUBBLE BADGE** with date-based colors (Green/Yellow/Red)
25. **PMBy** - Person who performed PM
26. **PMEstimatedTime** - ⭐ **NEW** - Estimated time for PM
27. **NextPM** - Next PM due date
28. **SwapCapability** - Can be swapped
29. **Qty** - Quantity (for Harness)
30. **Comments** - Additional notes

---

## Data Flow

### Database → DataTable → GridView → CSV

1. **SQL Query** (4 tables):
   ```sql
   SELECT 
       'Asset' as EquipmentType,
       ISNULL([EatonID],'') as EatonID,
       ...
       ISNULL([CalibratedBy],'') as CalibratedBy,
       ISNULL([CalibrationEstimatedTime],'') as CalibrationEstimatedTime,  -- NEW
       [NextCalibration] as NextCalibration,
       ...
       ISNULL([PMBy],'') as PMBy,
       ISNULL([PMEstimatedTime],'') as PMEstimatedTime,  -- NEW
       [NextPM] as NextPM,
       ...
   FROM [TestEngineering].[dbo].[Asset_Inventory]
   ```

2. **DataTable Definition**:
   - 32 total columns (30 display + 2 DateTime)
   - Type: All `typeof(string)` except NextCalibration/NextPM `typeof(DateTime)`

3. **LoadTableData()**:
   - Reads SQL results
   - Populates DataTable with `GetSafeValue(reader, columnName)`
   - Handles null values gracefully

4. **BuildGridColumns()**:
   - Creates 30 BoundFields (32 columns, but NextCal/NextPM formatted)
   - Sets HeaderText, DataField, CssClass for each
   - BoundFields automatically bound to DataTable columns

5. **gridEquipment_RowDataBound()**:
   - Renders after binding
   - Adds inline header styles (height, colors, borders)
   - Wraps Status/LastCal/LastPM in colored badge spans
   - Applies date-based color logic

6. **ExportToCSV()**:
   - Loops through GridView rows
   - Extracts text from 32 cells
   - Strips HTML tags (badges)
   - Creates CSV with headers

---

## Testing Checklist

### Visual Verification:
- [ ] Filter panel header shows reset icon between title and toggle
- [ ] Reset icon rotates -180deg on hover with red color
- [ ] Table headers are 48px tall with blue background and white text
- [ ] Status column shows colored badges (green/yellow/red)
- [ ] Last Calibration column shows colored badges based on date
- [ ] Last PM column shows colored badges based on date
- [ ] Cal Est Time column displays after Cal By
- [ ] PM Est Time column displays after PM By
- [ ] All badges have glowing dots before text

### Functional Testing:
- [ ] Clicking reset icon clears all 15 filters
- [ ] Filter count badge updates correctly
- [ ] Row selection still works (blue tint, left border)
- [ ] Export to CSV includes all 32 columns
- [ ] CSV headers match: "...,Cal By,Cal Est Time,Next Cal,...,PM By,PM Est Time,Next PM,..."
- [ ] Light/dark theme toggle works for all badges
- [ ] Date badges correctly identify overdue (>365 days), warning (180-365), good (<180)

### Browser Testing:
- [ ] Chrome: All styles render correctly
- [ ] Firefox: Vendor prefixes work
- [ ] Edge: No rendering issues
- [ ] Safari: Webkit prefixes applied

---

## Known Issues / Future Enhancements

### ❌ Pending: Make Manufacturer, Folder, Image Clickable URLs
**Status:** NOT YET IMPLEMENTED  
**Reason:** Need to convert BoundField to HyperLinkField in BuildGridColumns()  
**Implementation Plan:**
```csharp
// Replace Manufacturer BoundField with:
HyperLinkField mfgField = new HyperLinkField();
mfgField.DataNavigateUrlFields = new string[] { "Manufacturer" };
mfgField.DataTextField = "Manufacturer";
mfgField.HeaderText = "Manufacturer";
mfgField.Target = "_blank";
mfgField.HeaderStyle.CssClass = "col-mfg";
mfgField.ItemStyle.CssClass = "col-mfg";
gridEquipment.Columns.Add(mfgField);

// Similar for Folder and Image columns
// Image may need base URL prepending if paths are relative
```

### ⚠️ CSS vs Inline Styles Trade-off
**Issue:** CSS with !important wasn't working for headers  
**Solution:** Switched to inline styles in RowDataBound event  
**Trade-off:** Less maintainable (styles in C# code), but guaranteed to work  
**Alternative:** Could use HeaderStyle property on each BoundField, but inline approach is most reliable

### 💡 Potential Optimizations
1. **Pagination**: Currently loads all 64 records - consider paging for larger datasets
2. **Column Visibility Toggle**: Let users show/hide specific columns
3. **Column Reordering**: Drag-and-drop column reordering
4. **Advanced Filtering**: Date range pickers for calibration/PM dates
5. **Bulk Actions**: Select multiple rows for batch operations
6. **Export Options**: Excel format, PDF report generation
7. **Sorting Indicators**: Visual arrows on sortable column headers

---

## File Locations

```
/workspaces/Eaton-Projects/Tracks Website Application/Test Engineering Dashboard/
├── EquipmentGridView.aspx           (1215 lines - UI, CSS, JavaScript)
├── EquipmentGridView.aspx.cs        (1281 lines - Backend logic)
├── EQUIPMENT_GRID_CHANGELOG.md      (This file)
└── Web.config                       (Connection string: TestEngineeringConnectionString)
```

---

## Database Schema

**Connection String:** `TestEngineeringConnectionString`  
**Database:** `TestEngineering`  
**Tables:**
1. `Asset_Inventory` - General test equipment
2. `ATE_Inventory` - Automated Test Equipment
3. `Fixture_Inventory` - Test fixtures
4. `Harness_Inventory` - Test harnesses

**Key Columns:**
- All use PascalCase (EatonID, ModelNo, DeviceName, etc.)
- `CalibrationEstimatedTime` - varchar/nvarchar - time estimate for calibration
- `PMEstimatedTime` - varchar/nvarchar - time estimate for preventive maintenance
- `CurrentStatus` / `ATEStatus` - dynamically loaded into Status dropdown
- `NextCalibration` / `NextPM` - DateTime fields for due dates

---

## Support Notes

**User Issue History:**
1. ✅ Empty table → Fixed connection string
2. ✅ Wrong column names → Updated to PascalCase
3. ✅ Dropdown corruption → Added vendor prefixes
4. ✅ Folder showing status → Added cache-busting
5. ✅ Header not visible → Switched to inline styles
6. ✅ Dark mode text → Explicit color declarations

**Common User Questions:**
- Q: Why aren't headers styled?  
  A: CSS was overridden by ASP.NET - now using inline styles in RowDataBound

- Q: How do badge colors work?  
  A: Status uses status names (operational=green, maintenance=yellow, out-of-service=red)  
     Last Cal/PM uses date age (<180 days=green, 180-365=yellow, >365=red)

- Q: Can I add more filters?  
  A: Yes, add to filter panel HTML and add FilterExpression logic in ApplyFilters()

- Q: How to change column order?  
  A: Reorder BoundField definitions in BuildGridColumns() method

---

## Version History

**v1.0** - Initial release with 28 columns  
**v1.1** - Added Folder and Image columns (30 total)  
**v1.2** - Added dynamic Status loading  
**v1.3** - Added filter count badge  
**v1.4** - Fixed dropdown rendering issues  
**v1.5** - Added cache-busting meta tags  
**v1.6** - Enhanced table header CSS  
**v1.7** - Added row click highlighting  
**v2.0** - 🎉 **CURRENT VERSION**
- Reset icon button with animation
- CalibrationEstimatedTime and PMEstimatedTime columns (32 total)
- Inline header styling (48px, blue background)
- Status/LastCal/LastPM bubble badges with color coding
- Updated CSV export to 32 columns
- Activity badge CSS with theme support

---

## Credits

**Developer:** GitHub Copilot + User  
**Framework:** ASP.NET Web Forms 4.0  
**Database:** SQL Server (TestEngineering)  
**UI Library:** Custom CSS with theme system  
**Icons:** SVG inline (refresh/rotate icon)

---

*Last Updated: 2025*
*Document Version: 2.0*
