# Equipment Grid View - Clean & Consistent Design

## 🎨 Design Philosophy
Beautiful, minimal grid view that perfectly matches your existing Test Engineering Dashboard design language.

## ✨ Key Features

### **Consistent Design Elements**
- ✅ Same **Poppins font** family as other pages
- ✅ **Glassmorphism panels** with backdrop blur
- ✅ **Modern dark/light theme** support
- ✅ Identical **top bar** (Eaton YPO logo + theme toggle)
- ✅ Same **color scheme** and shadows
- ✅ **Small, modern font** (11.5px for table data, 11px for headers)

### **Top Bar**
- Eaton YPO logo with lightning bolt icon
- "INTERNAL" red badge
- "Test Engineering" subtitle
- Theme toggle button (dark ↔ light)

### **Filter Panel**
Clean, minimal filter section with glassmorphism styling:
- **Search** - Search across ID, Name, Model, Description
- **Equipment Type** - ATE, Asset, Fixture, Harness, All
- **Status** - Operational, Maintenance, Out of Service, All
- **Location** - Dynamically populated from database
- **Calibration** - Current, Due Soon (30 days), Overdue, All
- **Reset Filters** button

### **Data Table**
Comprehensive equipment view with 13 columns:

| Column | Description | Styling |
|--------|-------------|---------|
| Type | Equipment type | Color-coded badge (Purple/Blue/Orange/Green) |
| Eaton ID | Unique identifier | Left-aligned text |
| Name / Model | Equipment name | Bold text |
| Description | Details | Regular text |
| Location | Physical location | Regular text |
| Manufacturer | Manufacturer name | Regular text |
| Status | Current status | Badge with indicator dot |
| Req. Cal | Requires calibration | Yes/No |
| Last Cal | Last calibration date | Date format |
| Next Cal | Next calibration due | Color-coded by urgency |
| Req. PM | Requires PM | Yes/No |
| Last PM | Last PM date | Date format |
| Next PM | Next PM due | Color-coded by urgency |

### **Color Coding**

**Equipment Type Badges:**
- 🟣 **ATE** - Purple/Violet
- 🔵 **Asset** - Blue
- 🟠 **Fixture** - Orange
- 🟢 **Harness** - Green

**Status Badges (with pulsing dot):**
- 🟢 **Operational** - Green with glowing dot
- 🟠 **Maintenance** - Orange/Amber with glowing dot
- 🔴 **Out of Service** - Red with glowing dot

**Date Color Coding:**
- 🔴 **Overdue** - Red, bold (past due date)
- 🟠 **Due Soon** - Orange, bold (within 30 days)
- 🟢 **Current** - Green (30+ days out)
- ⚪ **N/A** - Faded gray (no date)

### **Table Features**
- ✅ **Sticky header** - Stays visible while scrolling
- ✅ **Horizontal scrolling** - Smooth, modern 8px scrollbar
- ✅ **Vertical scrolling** - Max height adapts to viewport
- ✅ **Row hover** - Subtle highlight on mouse over
- ✅ **Zebra striping** - Alternating row colors
- ✅ **Responsive** - Adapts to different screen sizes
- ✅ **Record count** - Shows filtered results
- ✅ **Empty state** - Friendly message when no results

### **Action Buttons**
- **Export CSV** - Downloads current filtered view
- **Refresh** - Reloads page data

## 📊 Data Sources

Combines data from 4 inventory tables:
- `ATE_Inventory` (uses ATEStatus field)
- `Asset_Inventory` (uses Current Status field)
- `Fixture_Inventory` (uses Current Status field)
- `Harness_Inventory` (uses Current Status field)

## 🎯 Access

**From Equipment Inventory Page:**
1. Click the **purple Grid View button** (2×2 grid icon) in the toolbar
2. Opens in **new browser tab**
3. No sidebar navigation - clean, focused view

## 💻 Technical Details

**Files:**
- `EquipmentGridView.aspx` - UI and styling (680 lines)
- `EquipmentGridView.aspx.cs` - Data logic (571 lines)

**Framework:**
- ASP.NET Web Forms 4.0
- .NET Framework 4.0 compatible
- SQL Server backend
- No modern C# features (no string interpolation, no null-conditional operators)

**Styling:**
- Inline CSS (no external stylesheet needed)
- CSS variables for theming
- Modern backdrop-filter blur effects
- Responsive grid layouts
- Flexbox and CSS Grid

**Fonts:**
- **Poppins** (300, 400, 500, 600, 700, 800 weights)
- **SF Mono** / Monaco for dates (monospace)
- Small, readable sizes (11-13px)

**Performance:**
- Server-side filtering with DataView.RowFilter
- Dynamic column generation
- Efficient SQL with ISNULL for NULL handling
- Minimal postbacks

## 🎨 Theme Support

**Dark Mode (Default):**
- Dark blue/gray backgrounds
- White/light text
- Glassmorphism panels with blur
- Subtle shadows and borders
- Color-coded badges pop beautifully

**Light Mode:**
- Clean white backgrounds
- Dark text for readability
- Lighter shadows
- Professional, minimal look
- Same badge colors adjusted for light background

## 🔄 Filtering Logic

**Search:**
- Searches: Eaton ID, Name, Description, Model fields
- Case-insensitive partial match

**Equipment Type:**
- Filters by specific type or shows all

**Status:**
- Exact match on status field

**Location:**
- Exact match, populated from all tables

**Calibration:**
- **Current** - Next cal > 30 days or NULL
- **Due Soon** - Next cal within 30 days
- **Overdue** - Next cal < today

**Filters combine with AND logic**

## 📤 CSV Export

**Features:**
- Exports current filtered view
- Removes HTML formatting
- Comma-separated values
- Filename: `EquipmentInventory_YYYYMMDD.csv`
- Includes all 13 columns

## 🚀 User Experience

**Smooth & Fast:**
- Instant filter updates (AutoPostBack)
- Smooth scrolling
- Responsive hover effects
- Clear visual feedback

**Professional:**
- Clean, minimal design
- Consistent with existing pages
- Easy to read small fonts
- Color-coded for quick scanning

**Accessible:**
- High contrast text
- Clear labels
- Keyboard navigable
- Semantic HTML

## 📱 Responsive Design

- **Desktop** - Full width, all columns visible with scroll
- **Tablet** - Filters stack vertically
- **Mobile** - Single column filter layout

## 🔧 Maintenance

**Easy Updates:**
- All styles in one file
- Clear column definitions
- Modular data loading
- Simple filter logic

**Extensibility:**
- Easy to add new columns
- Simple to add new filters
- Badge system easily extended

## ✅ Testing Checklist

- [ ] Dark mode appearance
- [ ] Light mode appearance
- [ ] Theme toggle works
- [ ] All filters work
- [ ] Search functionality
- [ ] CSV export
- [ ] Scrolling (horizontal & vertical)
- [ ] Row hover effects
- [ ] Date color coding
- [ ] Status badges display
- [ ] Type badges display
- [ ] Empty state shows
- [ ] Record count updates

## 🎉 Result

A beautiful, fast, professional grid view that perfectly matches your existing design language. Small fonts, modern styling, glassmorphism effects, and full theme support. Ready to use! 🚀
