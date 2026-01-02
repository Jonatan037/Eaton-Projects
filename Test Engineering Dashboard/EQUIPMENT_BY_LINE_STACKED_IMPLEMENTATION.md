# Equipment by Line - Stacked Chart Implementation

**Date**: October 27, 2025  
**Purpose**: Convert Equipment by Line chart from simple column chart to stacked column chart showing equipment type breakdown

---

## Summary of Changes

The Equipment by Line chart has been updated to display as a **stacked column chart**, showing the breakdown of equipment types (ATE, Asset, Fixture, Harness) for each line, matching the visual style of the Equipment by Location chart.

---

## Files Changed

### 1. SQL View Update

**File**: `Update_EquipmentByLine_Stacked_View.sql` (NEW)

**Changes**:
- Updated `vw_EquipmentInventory_ByLine` view structure
- Now returns 4 columns instead of 2:
  - `Line` - The extracted line name from Location field
  - `EquipmentType` - The type of equipment (ATE, Asset, Fixture, Harness)
  - `EquipmentCount` - Count of equipment for this line/type combination
  - `TotalForLine` - Total equipment count for the line (for sorting)

**Key SQL Logic**:
```sql
-- Extract line from Location (text before first dash)
CASE 
    WHEN Location LIKE '%-%' 
    THEN LTRIM(RTRIM(LEFT(Location, CHARINDEX('-', Location) - 1)))
    ELSE ISNULL(Location, 'Unassigned')
END AS Line

-- Group by Line AND EquipmentType for stacked chart
GROUP BY el.Line, el.EquipmentType, lt.TotalForLine
```

**To Apply**: Run this script in SQL Server Management Studio against the TestEngineering database.

---

### 2. C# Code-Behind Changes

**File**: `EquipmentInventoryDashboard.aspx.cs`

#### Change 1: Added Property for Datasets
**Lines 14-20**: Added `LineDatasets` property

```csharp
public string LineLabels { get; set; }
public string LineData { get; set; }
public string LineDatasets { get; set; }  // For stacked chart - NEW
```

#### Change 2: Updated Data Loading Logic
**Lines 264-360**: Completely rewrote Equipment by Line data loading

**Old Approach** (Simple aggregation):
```csharp
// Old: Single dataset with total counts per line
var lineLabels = new List<string>();
var lineValues = new List<int>();
var lineQuery = "SELECT Line, EquipmentCount FROM dbo.vw_EquipmentInventory_ByLine...";
```

**New Approach** (Stacked by type):
```csharp
// New: Multiple datasets (one per equipment type)
var lineLabels = new List<string>();
var lineTotals = new Dictionary<string, int>();
var lineDataByType = new Dictionary<string, Dictionary<string, int>>();

// Query returns: Line, EquipmentType, EquipmentCount, TotalForLine
var lineQuery = "SELECT Line, EquipmentType, EquipmentCount, TotalForLine FROM dbo.vw_EquipmentInventory_ByLine";

// Build separate dataset for each equipment type
foreach (var equipType in new[] { "ATE", "Asset", "Fixture", "Harness" }) {
    // Create data array matching sorted line order
    // Apply consistent colors: ATE=#4472C4, Asset=#ED7D31, Fixture=#A5A5A5, Harness=#FFC000
}
```

**Key Features**:
- Lines sorted by total equipment count (descending)
- Only includes equipment types with at least one item
- Matches color scheme used in Equipment by Location chart
- Proper handling of missing data (fills with 0)

---

### 3. JavaScript Chart Configuration

**File**: `EquipmentInventoryDashboard.aspx`

**Lines 1382-1479**: Updated Equipment by Line chart configuration

#### Key Changes:

1. **Changed from single dataset to multiple datasets**:
```javascript
// Old:
datasets: [{
    label: 'Equipment Count',
    data: lineData,
    backgroundColor: colors.teal
}]

// New:
datasets: lineDatasets  // Array of datasets (one per equipment type)
```

2. **Enabled stacked mode**:
```javascript
scales: {
    x: { stacked: true },
    y: { stacked: true }
}
```

3. **Updated datalabels plugin**:
```javascript
datalabels: {
    display: function(context) {
        return context.dataset.data[context.dataIndex] > 0;  // Only show if > 0
    },
    anchor: 'center',
    align: 'center',
    color: '#ffffff',  // White text on colored bars
    font: { size: 10, weight: '600' }
}
```

4. **Added custom plugin to show totals above bars**:
```javascript
plugins: [{
    afterDatasetsDraw: function(chart) {
        // Calculate total for each stacked bar
        // Draw total value above the top segment
        ctx.fillText(total, element.x, element.y - 5);
    }
}]
```

5. **Hid legend** (consistent with Equipment by Location):
```javascript
legend: { display: false }
```

6. **Rotated x-axis labels** for better readability:
```javascript
x: {
    ticks: { 
        maxRotation: 45,
        minRotation: 45
    }
}
```

---

## Visual Features

### Chart Appearance:
- **Type**: Stacked vertical bar chart
- **Colors**: 
  - ATE: Blue (#4472C4)
  - Asset: Orange (#ED7D31)
  - Fixture: Gray (#A5A5A5)
  - Harness: Yellow (#FFC000)
- **Labels**: 
  - Individual counts inside each colored segment (white text)
  - Total count displayed above each bar (top)
- **Sorting**: Lines ordered by total equipment count (highest first)
- **No Legend**: Clean appearance like Equipment by Location chart

### Interactivity:
- **Hover**: Tooltip shows line name and equipment type breakdown
- **Responsive**: Adjusts to container size
- **Data Labels**: Only shown when count > 0 (avoids clutter)

---

## Data Flow

1. **SQL View** (`vw_EquipmentInventory_ByLine`):
   - Unions all 4 equipment tables
   - Extracts line from Location field
   - Groups by Line + EquipmentType
   - Returns breakdown data

2. **C# Code-Behind** (Page_Load):
   - Queries view for Line/Type breakdown
   - Organizes data into dictionary structure
   - Sorts lines by total count
   - Builds Chart.js dataset format
   - Serializes to JSON

3. **JavaScript** (Chart initialization):
   - Receives LineLabels and LineDatasets
   - Creates stacked bar chart
   - Applies colors, labels, and formatting
   - Renders with totals displayed

---

## Testing

### Before Running:
1. Execute `Update_EquipmentByLine_Stacked_View.sql` in SSMS
2. Verify view returns data:
```sql
SELECT * FROM vw_EquipmentInventory_ByLine 
ORDER BY TotalForLine DESC, Line, EquipmentType;
```

### After Deployment:
1. Refresh Equipment Inventory Dashboard page
2. Check console for diagnostic messages:
   - "Line query executed, reading results..."
   - "Row: [Line] - [Type] = [Count]"
   - "LineLabels serialized: [...]"
   - "LineDatasets serialized: [...]"
3. Verify chart displays stacked bars with:
   - Multiple colors per line (if mixed equipment types)
   - Total count above each bar
   - Proper sorting (highest total first)

---

## Comparison: Before vs After

### Before (Simple Column Chart):
```
Chart showed:
- Single color (teal) bars
- One value per line (total equipment)
- No breakdown by equipment type
- Label on top of each bar
```

### After (Stacked Column Chart):
```
Chart shows:
- Multi-color stacked bars
- Breakdown by equipment type within each line
- Same visual style as Equipment by Location
- Individual counts inside segments + total on top
- Consistent color coding across dashboard
```

---

## Notes

- **Color Consistency**: Uses same colors as Equipment by Location and Equipment by Type charts
- **Performance**: View includes TotalForLine column to avoid calculating totals in C#
- **Scalability**: Chart handles any number of lines (no TOP limit)
- **Diagnostic Logging**: Console.log statements help debug data issues
- **Null Handling**: Unassigned locations handled gracefully
- **Empty Datasets**: Types with zero equipment are excluded from display

---

## Related Files

- **Equipment by Location**: Uses identical stacking approach (reference for consistency)
- **Other Dashboards**: CalibrationDashboard and PMDashboard use similar patterns
- **SQL Views Directory**: `/Database/Views/` (if organizing views separately)

---

## Future Enhancements (Optional)

1. Add legend toggle (show/hide if users request)
2. Click-to-filter: Click a line to drill down to equipment details
3. Export chart data to Excel
4. Add animation on chart load
5. Responsive legend position (bottom on mobile, side on desktop)
