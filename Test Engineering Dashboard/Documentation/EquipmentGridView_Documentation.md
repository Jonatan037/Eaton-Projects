# Equipment Grid View - Feature Documentation

## Overview
A comprehensive, read-only grid view for viewing all equipment inventory data across all equipment types (ATE, Asset, Fixture, Harness) in a single, filterable table.

## Page Location
`/Test Engineering Dashboard/EquipmentGridView.aspx`

## Access
- Opens in a new browser tab from Equipment Inventory page
- Click the purple "Grid View" icon button (2×2 grid icon) in the toolbar

## Key Features

### 1. **Standalone Layout**
- No sidebar navigation
- Clean top bar with Eaton YPO branding
- Theme toggle (dark/light mode)
- Responsive design

### 2. **KPI Dashboard**
- **Total Equipment**: Count of all equipment across all types
- **Operational**: Count and percentage of operational equipment
- **Cal/PM Due**: Equipment with calibration or PM due in next 30 days
- **Equipment Types**: Summary of 4 equipment categories

### 3. **Visual Charts**
- **Equipment by Type**: Horizontal bar chart showing distribution
  - ATE (Purple)
  - Asset (Blue)
  - Fixture (Orange)
  - Harness (Green)
  
- **Equipment Status**: Horizontal bar chart showing status distribution
  - Operational (Green)
  - Maintenance (Orange)
  - Out of Service (Blue)

### 4. **Advanced Filters**
- **Search**: Text search across ID, Name, Model, Description
- **Equipment Type**: Filter by ATE, Asset, Fixture, Harness, or All
- **Status**: Filter by Operational, Maintenance, Out of Service, or All
- **Location**: Filter by specific location (dynamically populated)
- **Calibration Status**: Filter by Current, Due Soon (30 days), Overdue, or All
- **Reset Filters**: Button to clear all filters

### 5. **Data Table**
Displays all equipment fields with color-coded badges:

**Columns:**
- Equipment Type (colored badge)
- Eaton ID
- Name / Model
- Description
- Location
- Manufacturer
- Status (colored badge with indicator dot)
- Requires Calibration
- Last Calibration Date
- Next Calibration Date (color-coded by due date)
- Requires PM
- Last PM Date
- Next PM Date (color-coded by due date)

**Color Coding:**
- **Equipment Types**:
  - ATE: Purple
  - Asset: Blue
  - Fixture: Orange
  - Harness: Green

- **Status Badges**:
  - Operational/Good/Active: Green with dot
  - Maintenance/Warning/Due: Orange with dot
  - Out of Service/Overdue/Error: Red with dot

- **Date Cells**:
  - Overdue (past due): Red, bold
  - Due Soon (within 30 days): Orange, bold
  - Current (more than 30 days): Green

### 6. **Table Features**
- Sticky header (stays visible while scrolling)
- Horizontal and vertical scrolling
- Modern 8px scrollbar
- Hover highlighting on rows
- Record count display
- Empty state message when no results

### 7. **Export Functionality**
- **CSV Export**: Downloads current filtered view to CSV file
- Includes all visible columns
- Filename includes timestamp: `EquipmentInventory_YYYYMMDD.csv`

## Technical Details

### Database Tables
Combines data from:
- `ATE_Inventory`
- `Asset_Inventory`
- `Fixture_Inventory`
- `Harness_Inventory`

### Data Normalization
The page normalizes field names across different table structures:
- Status fields: `ATEStatus`, `Current Status` → unified as `Status`
- ID fields: All use `EatonID`
- Name fields: Various model/name fields → unified as `Name`

### Performance
- Data filtered server-side using DataView.RowFilter
- Dynamic column generation
- Efficient SQL queries with proper NULL handling
- Minimal postbacks (filters trigger immediate update)

### Styling
- Modern Inter font family
- CSS variables for theme support
- Glassmorphism design elements
- Smooth transitions and hover effects
- Responsive grid layouts

## Usage Scenarios

1. **Quick Overview**: Get instant visibility into all equipment
2. **Status Monitoring**: Identify equipment needing attention
3. **Maintenance Planning**: Filter by calibration/PM due dates
4. **Location Management**: View equipment by location
5. **Reporting**: Export filtered data for external analysis
6. **Type Comparison**: View distribution across equipment types

## Browser Compatibility
- Chrome, Edge (full support)
- Firefox (full support)
- Safari (full support)
- Mobile responsive design

## Future Enhancements (Potential)
- Column sorting (click headers)
- Column show/hide toggles
- Saved filter presets
- PDF export option
- Print-friendly view
- Direct links to item details
- Bulk operations
- Advanced search (date ranges, etc.)

## Related Files
- `EquipmentGridView.aspx` - Front-end markup and styles
- `EquipmentGridView.aspx.cs` - Backend code and data logic
- `EquipmentInventory.aspx` - Parent page with Grid View button
