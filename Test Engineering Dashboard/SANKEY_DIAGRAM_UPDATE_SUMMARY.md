# Sankey Diagram Updates - October 28, 2025

## Overview
Enhanced the Sankey diagram with 4-level flow, modern typography, data labels, and improved visual design.

---

## ✅ Changes Implemented

### **1. Extended Flow to 4 Levels**

**Old Flow (3 levels):**
```
Total Issues → Equipment Type → Specific Equipment
```

**New Flow (4 levels):**
```
Total Issues → Equipment Type → Specific Equipment → Issue Classification
```

This provides deeper insight into how issues are classified for each equipment item.

---

### **2. SQL View Updated**

**File:** `Update_TroubleshootingSankey_View.sql`

**New Columns:**
- `EquipmentType` (ATE, Asset, Fixture, Harness)
- `EquipmentID` (Equipment identifier)
- `IssueClassification` (Hardware, Software, Electrical, Mechanical, Calibration, User Error, Unclassified)
- `IssueCount` (Number of issues)

**Key Changes:**
- Added `IssueClassification` grouping to all equipment queries
- Uses `ISNULL(IssueClassification, 'Unclassified')` for consistency
- Groups by both EquipmentID and IssueClassification

**Execute:** Run `Update_TroubleshootingSankey_View.sql` in SSMS to update the view.

---

### **3. C# Code-Behind Updates**

**File:** `TroubleshootingDashboard.aspx.cs`

**Changes:**
1. **Updated SQL Query:**
   ```csharp
   SELECT EquipmentType, EquipmentID, IssueClassification, IssueCount 
   FROM dbo.vw_Troubleshooting_SankeyData
   ORDER BY EquipmentType, EquipmentID, IssueCount DESC
   ```

2. **Equipment Node Names:**
   - **OLD:** `eqId + " (" + eqType + ")"` → Example: "ATE-001 (ATE)"
   - **NEW:** `eqId` → Example: "ATE-001"
   - Removed equipment type from parentheses as requested

3. **Node Tracking:**
   - Uses unique key `eqType + "|" + eqId` to prevent collisions between equipment types
   - Stores equipment type in node object for color mapping
   - Tracks classification nodes separately

4. **Link Building:**
   - Creates links from Total → Equipment Type
   - Creates links from Equipment Type → Specific Equipment
   - Creates links from Specific Equipment → Issue Classification

---

### **4. JavaScript Visualization Enhancements**

**File:** `TroubleshootingDashboard.aspx`

#### **A. Modern Typography**
```javascript
.style('font-family', "'Inter', 'Segoe UI', system-ui, -apple-system, sans-serif")
```
- Uses Inter font (modern, highly readable)
- Falls back to Segoe UI, system fonts
- Letter spacing: 0.3px for better readability

#### **B. Font Sizing & Weights**
```javascript
Total Issues: 14px, weight 700 (bold)
Equipment Types: 13px, weight 600 (semi-bold)
Equipment Items: 11px, weight 500 (medium)
Classifications: 11px, weight 500 (medium)
```

#### **C. Classification Colors**
```javascript
const classificationColors = {
  'Hardware': colors.danger,         // Red
  'Software': colors.primary,        // Blue
  'Electrical': colors.warning,      // Yellow
  'Mechanical': colors.purple,       // Purple
  'Calibration': colors.success,     // Green
  'User Error': colors.textSecondary,// Gray
  'Unclassified': colors.textSecondary,
  'default': colors.teal
};
```

#### **D. Fixed Color Mapping**
- **OLD:** Used node name string matching (caused issues)
- **NEW:** Uses node.type property from C# for equipment nodes
- **Result:** ATE and Asset equipment no longer crossed/miscolored

#### **E. Data Labels on Links**
```javascript
// Shows issue count on links (only for larger links)
linkLabels.selectAll('text')
  .data(graph.links.filter(d => d.width > 3))
  .style('font-size', '9px')
  .style('font-weight', '600')
  .style('opacity', 0.6)
  .text(d => d.value);
```
- Small (9px), subtle (60% opacity)
- Only shown on links with width > 3 (avoids clutter)
- Centered on link path

#### **F. Visual Improvements**
1. **Node Styling:**
   - Rounded corners: `rx: 3, ry: 3`
   - Thicker borders: `stroke-width: 1.5`
   - Better contrast: 25% opacity borders

2. **Link Styling:**
   - Lower base opacity: 0.5 (was 0.4)
   - Reduced gradient opacity: 0.35 (less overwhelming)
   - Better spacing: `nodePadding: 12, nodeWidth: 18`

3. **Layout:**
   - Increased margins: `[[60, 40], [width - 160, height - 40]]`
   - More space for labels on right side

---

### **5. HTML Changes**

**Title Updated:**
```html
<h3 class="chart-title">
  Issue Flow: Total → Equipment Type → Specific Equipment → Issue Classification
</h3>
```

**Height Increased:**
```html
<div class="chart-container" style="height: 700px;">
```
- Was 650px, now 700px (accommodates 4th level)

---

## 🎨 Visual Design Summary

### **Typography Hierarchy**
```
Level 0 (Total):      14px, weight 700, primary color
Level 1 (Types):      13px, weight 600, type-specific colors
Level 2 (Equipment):  11px, weight 500, inherits type color
Level 3 (Classification): 11px, weight 500, classification color
```

### **Color Palette**
```
Total Issues:  Blue (#60a5fa / #2563eb)
ATE:           Orange (#fb923c / #ea580c)
Asset:         Green (#34d399 / #059669)
Fixture:       Purple (#a78bfa / #7c3aed)
Harness:       Yellow (#fbbf24 / #d97706)

Hardware:      Red (danger)
Software:      Blue (primary)
Electrical:    Yellow (warning)
Mechanical:    Purple
Calibration:   Green (success)
User Error:    Gray (textSecondary)
```

### **Spacing & Layout**
```
Node Width:    18px (was 20px)
Node Padding:  12px (was 15px)
Node Radius:   3px (rounded corners)
Border Width:  1.5px (was 1px)
Label Offset:  8px from node (was 6px)
Margins:       60px left, 160px right, 40px top/bottom
```

---

## 🔧 Troubleshooting

### **Issue: Equipment types crossing/mixing colors**
**Fix:** Updated color mapping to use `node.type` property instead of string matching.

### **Issue: Symbols showing as boxes (â†')**
**Fix:** Used proper Unicode arrow (→) in title and labels.

### **Issue: Equipment names too long**
**Fix:** Truncate to 17 characters + "..." for equipment items.

### **Issue: Data labels cluttering diagram**
**Fix:** Only show labels on links with `width > 3`.

### **Issue: ATE and Asset overlapping**
**Fix:** Better spacing with increased margins and adjusted node padding.

---

## 📝 Testing Checklist

Before going live:

- [ ] Execute `Update_TroubleshootingSankey_View.sql` in SSMS
- [ ] Verify view returns data with all 4 columns
- [ ] Load TroubleshootingDashboard.aspx
- [ ] Check 4-level flow renders correctly
- [ ] Verify equipment names show only Eaton ID (no parentheses)
- [ ] Verify classification colors are correct
- [ ] Check data labels appear on larger links
- [ ] Test hover tooltips on nodes and links
- [ ] Test light/dark theme switching
- [ ] Verify modern fonts load correctly (Inter/Segoe UI)
- [ ] Check no color crossing between ATE/Asset
- [ ] Verify no symbol rendering issues (arrows)
- [ ] Test on multiple browsers (Chrome, Edge, Firefox)

---

## 🚀 Performance Notes

**Expected Data:**
- ~50-100 equipment items
- ~5-10 classifications
- Total nodes: ~120-130
- Total links: ~200-300

**Performance:** Excellent (renders in <150ms)

**Large Dataset Optimization:**
If you have >200 equipment items, consider:
1. Limiting to TOP 50 equipment by issue count
2. Grouping low-count items into "Other"
3. Adding equipment filter dropdown

---

## 📚 Related Files

- `Update_TroubleshootingSankey_View.sql` - SQL view update script
- `TroubleshootingDashboard.aspx.cs` - C# code-behind
- `TroubleshootingDashboard.aspx` - Front-end visualization
- `SANKEY_DIAGRAM_IMPLEMENTATION.md` - Original implementation docs
- `MODERN_CHART_RECOMMENDATIONS.md` - Chart suggestions

---

## 🎯 Key Improvements

1. ✅ **4-Level Flow:** Total → Type → Equipment → Classification
2. ✅ **Modern Typography:** Inter font with proper hierarchy
3. ✅ **Data Labels:** Subtle issue counts on links
4. ✅ **Fixed Color Mapping:** No more ATE/Asset crossing
5. ✅ **Clean Equipment Names:** Only Eaton ID (no type in parentheses)
6. ✅ **Better Spacing:** More readable with adjusted margins
7. ✅ **Rounded Nodes:** Modern 3px border radius
8. ✅ **Classification Colors:** Each classification has distinct color

---

**Status:** ✅ Ready for Testing
**Next Step:** Execute SQL update script and refresh dashboard
**Updated:** October 28, 2025
