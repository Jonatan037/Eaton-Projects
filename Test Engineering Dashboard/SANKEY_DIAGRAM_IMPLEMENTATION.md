# Sankey Diagram Implementation - Troubleshooting Dashboard

## Overview

A modern **Sankey Diagram** has been added to the Troubleshooting Dashboard to visualize the flow of issues from total count through equipment types to specific equipment items. This provides executive-level insight into where issues are concentrated and how they distribute across the equipment hierarchy.

---

## Implementation Summary

### **1. SQL View Created**

**File**: `Create_TroubleshootingSankey_View.sql`

**View Name**: `vw_Troubleshooting_SankeyData`

**Returns**:
- `EquipmentType` (ATE, Asset, Fixture, Harness)
- `EquipmentID` (Specific equipment identifier)
- `IssueCount` (Number of issues for that equipment)

**Data Logic**:
```sql
WITH EquipmentIssues AS (
    -- Union of ATE, Asset, Fixture, Harness issues
    SELECT 'ATE' AS EquipmentType, AffectedATE AS EquipmentID, COUNT(*) AS IssueCount
    FROM Troubleshooting_Log
    WHERE AffectedATE IS NOT NULL AND AffectedATE <> ''
      AND (ReportedDateTime >= DATEADD(MONTH, -12, GETDATE())
           OR Status NOT IN ('Resolved', 'Closed'))
    GROUP BY AffectedATE
    UNION ALL
    -- Similar for Asset, Fixture, Harness
)
SELECT EquipmentType, EquipmentID, IssueCount
FROM EquipmentIssues WHERE IssueCount > 0
```

**Filter Criteria**:
- Issues from last 12 months OR
- Issues that are still open/active
- Excludes equipment with zero issues

---

### **2. C# Code-Behind Changes**

**File**: `TroubleshootingDashboard.aspx.cs`

#### Added Property:
```csharp
public string SankeyData { get; set; }
```

#### Added Data Loading (in `LoadChartData()` method):
```csharp
// 7. Sankey Diagram Data (Total Issues → Equipment Type → Specific Equipment)
using (var cmd = new SqlCommand(@"
    SELECT EquipmentType, EquipmentID, IssueCount 
    FROM dbo.vw_Troubleshooting_SankeyData
    ORDER BY EquipmentType, IssueCount DESC", conn))
{
    using (var rdr = cmd.ExecuteReader())
    {
        var nodes = new List<object>();
        var links = new List<object>();
        var nodeIndexMap = new Dictionary<string, int>();
        
        // Add root node: "Total Issues"
        nodes.Add(new { name = "Total Issues" });
        nodeIndexMap["Total Issues"] = 0;
        
        // Add equipment type nodes: ATE, Asset, Fixture, Harness
        var equipmentTypes = new[] { "ATE", "Asset", "Fixture", "Harness" };
        for (int i = 0; i < equipmentTypes.Length; i++)
        {
            nodes.Add(new { name = equipmentTypes[i] });
            nodeIndexMap[equipmentTypes[i]] = i + 1;
        }
        
        int nextNodeIndex = equipmentTypes.Length + 1;
        var typeIssueCounts = new Dictionary<string, int>();
        
        // Build equipment nodes and links
        while (rdr.Read())
        {
            string eqType = rdr["EquipmentType"].ToString();
            string eqId = rdr["EquipmentID"].ToString();
            int issueCount = Convert.ToInt32(rdr["IssueCount"]);
            
            // Track total per type
            if (!typeIssueCounts.ContainsKey(eqType))
                typeIssueCounts[eqType] = 0;
            typeIssueCounts[eqType] += issueCount;
            
            // Add equipment node
            string equipmentNodeName = eqId + " (" + eqType + ")";
            if (!nodeIndexMap.ContainsKey(equipmentNodeName))
            {
                nodes.Add(new { name = equipmentNodeName });
                nodeIndexMap[equipmentNodeName] = nextNodeIndex++;
            }
            
            // Create link: Equipment Type → Specific Equipment
            links.Add(new { 
                source = nodeIndexMap[eqType], 
                target = nodeIndexMap[equipmentNodeName], 
                value = issueCount 
            });
        }
        
        // Create links: Total Issues → Equipment Types
        foreach (var typeCount in typeIssueCounts)
        {
            links.Add(new { 
                source = 0, 
                target = nodeIndexMap[typeCount.Key], 
                value = typeCount.Value 
            });
        }
        
        // Serialize to JSON
        var sankeyData = new { nodes = nodes, links = links };
        SankeyData = serializer.Serialize(sankeyData);
    }
}
```

**JSON Structure**:
```json
{
  "nodes": [
    { "name": "Total Issues" },
    { "name": "ATE" },
    { "name": "Asset" },
    { "name": "Fixture" },
    { "name": "Harness" },
    { "name": "ATE-001 (ATE)" },
    { "name": "FIX-025 (Fixture)" },
    ...
  ],
  "links": [
    { "source": 0, "target": 1, "value": 45 },  // Total → ATE
    { "source": 0, "target": 2, "value": 32 },  // Total → Asset
    { "source": 1, "target": 5, "value": 12 },  // ATE → ATE-001
    ...
  ]
}
```

---

### **3. ASPX Front-End Changes**

**File**: `TroubleshootingDashboard.aspx`

#### Added D3.js Libraries:
```html
<script src="https://d3js.org/d3.v7.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/d3-sankey@0.12.3/dist/d3-sankey.min.js"></script>
```

#### Added HTML Container (positioned as FIRST chart):
```html
<!-- SANKEY DIAGRAM (Issue Flow) -->
<div class="chart-grid">
  <div class="chart-card chart-full" style="margin-bottom: 20px;">
    <h3 class="chart-title">Issue Flow: Total → Equipment Type → Specific Equipment</h3>
    <div class="chart-container" style="height: 650px;">
      <svg id="sankeyDiagram" style="width: 100%; height: 100%;"></svg>
    </div>
  </div>
</div>
```

**Position**: Immediately after KPIs, before other charts

---

### **4. JavaScript Sankey Visualization**

**Function**: `initializeSankeyDiagram(colors)`

**Key Features**:

#### Color Mapping:
```javascript
const equipmentColors = {
  'Total Issues': colors.primary,     // Blue
  'ATE': colors.orange,                // Orange
  'Asset': colors.success,             // Green
  'Fixture': colors.purple,            // Purple
  'Harness': colors.warning            // Yellow
};
```

#### Sankey Configuration:
```javascript
const sankey = d3.sankey()
  .nodeWidth(20)           // Width of node rectangles
  .nodePadding(15)         // Space between nodes
  .extent([[50, 50], [width - 50, height - 50]])
  .nodeAlign(d3.sankeyLeft)
  .nodeSort(null);
```

#### Link Gradients:
- Each link has a gradient from source node color to target node color
- Opacity: 0.4 (semi-transparent for overlapping flows)
- Hover: Increases opacity to 0.7 and stroke width

#### Interactive Features:

**Link Hover**:
```javascript
.on('mouseover', function(event, d) {
  // Show tooltip with: Source → Target, Issue Count
  // Highlight link (increase opacity and width)
})
.on('mouseout', function() {
  // Hide tooltip, restore original styling
})
```

**Node Hover**:
```javascript
.on('mouseover', function(event, d) {
  // Show tooltip with: Node Name, Total Issues
  // Brighten node color
})
.on('mouseout', function() {
  // Hide tooltip, restore original color
})
```

#### Label Formatting:
- Equipment type nodes: **Bold** (font-weight: 600)
- Equipment item nodes: Normal weight
- Long names (>25 chars): Truncated with "..." + full name on hover
- Left-aligned for left side nodes, right-aligned for right side

#### Theme Support:
- Uses existing `getChartColors()` function
- Automatically updates on theme switch
- Tooltip styling matches theme (backdrop blur, border, text color)

---

## Visual Design

### **Layout**:
```
┌─────────────────────────────────────────────────────────────┐
│  Total Issues  ──────────────► ATE ──────────► ATE-001      │
│      (150)          │              │           (12 issues)   │
│                     │              └─────────► ATE-015       │
│                     │                          (8 issues)    │
│                     │                                        │
│                     ├──────────► Asset ──────► ASSET-042     │
│                     │              │           (15 issues)   │
│                     │              └─────────► ASSET-101     │
│                     │                          (7 issues)    │
│                     │                                        │
│                     ├──────────► Fixture ────► FIX-025       │
│                     │              │           (20 issues)   │
│                     │              └─────────► FIX-037       │
│                     │                          (5 issues)    │
│                     │                                        │
│                     └──────────► Harness ────► HARN-012      │
│                                    │           (10 issues)   │
│                                    └─────────► HARN-089      │
│                                                (3 issues)    │
└─────────────────────────────────────────────────────────────┘
```

### **Color Scheme**:
- **Total Issues**: Blue (Primary)
- **ATE**: Orange
- **Asset**: Green
- **Fixture**: Purple
- **Harness**: Yellow
- **Links**: Gradient from source to target color

### **Typography**:
- Font: Segoe UI (consistent with dashboard)
- Title: 16px, weight 600
- Node Labels: 12px
- Tooltips: 13px

---

## Testing Checklist

Before deploying to production:

- [ ] Execute SQL view creation script in SSMS
- [ ] Verify view returns data: `SELECT * FROM vw_Troubleshooting_SankeyData`
- [ ] Load TroubleshootingDashboard.aspx
- [ ] Verify Sankey diagram renders correctly
- [ ] Test light/dark theme switching
- [ ] Test hover interactions on nodes and links
- [ ] Test tooltip display and positioning
- [ ] Verify no console errors in browser developer tools
- [ ] Test on different browsers (Chrome, Edge, Firefox)
- [ ] Test on mobile/tablet (responsive behavior)
- [ ] Verify performance with large datasets (>100 equipment items)

---

## Troubleshooting

### **Issue**: Sankey diagram shows "No issue data available"
**Solution**: 
1. Verify SQL view exists: Check SSMS Object Explorer
2. Check data: `SELECT * FROM vw_Troubleshooting_SankeyData`
3. Verify date filter (last 12 months) includes data
4. Check Troubleshooting_Log table has valid AffectedATE/Asset/Fixture/Harness values

### **Issue**: Console error "d3 is not defined"
**Solution**: 
1. Verify D3.js CDN loads correctly (check Network tab)
2. Check CSP (Content Security Policy) allows CDN scripts
3. Try loading page with cache cleared (Ctrl+Shift+R)

### **Issue**: Links overlap and are hard to see
**Solution**: 
1. Adjust `nodePadding` parameter (increase spacing)
2. Reduce number of displayed equipment items (e.g., TOP 20 instead of all)
3. Increase SVG height in HTML (currently 650px)

### **Issue**: Labels are cut off or overlap
**Solution**: 
1. Increase left/right margins in `.extent()` parameter
2. Truncate long equipment names more aggressively (<20 chars)
3. Use smaller font size for labels

---

## Performance Optimization

### **Current Dataset**:
- ~50-100 equipment items with issues
- ~4 equipment types
- Total nodes: ~105
- Total links: ~108

**Expected Performance**: Excellent (renders in <100ms)

### **Large Dataset (>200 equipment items)**:
**Optimizations**:
1. Filter to top N equipment by issue count:
   ```sql
   SELECT TOP 50 EquipmentType, EquipmentID, IssueCount
   FROM vw_Troubleshooting_SankeyData
   ORDER BY IssueCount DESC
   ```

2. Add "Other" category for remaining items:
   ```sql
   UNION ALL
   SELECT EquipmentType, 'Other', SUM(IssueCount) AS IssueCount
   FROM (SELECT ... WHERE NOT IN TOP 50) AS Others
   GROUP BY EquipmentType
   ```

3. Use virtual scrolling or pagination if interactive

4. Consider WebGL rendering for very large datasets

---

## Future Enhancements

### **Version 1.1 Ideas**:
1. **Drill-Down**: Click node to filter Recent Issues table
2. **Time Range Filter**: Dropdown to select 1 month/3 months/6 months/1 year
3. **Export**: Button to export Sankey as PNG/SVG
4. **Animation**: Animated transitions when data updates
5. **Equipment Type Filter**: Toggle visibility of specific equipment types
6. **Issue Severity**: Color links by severity (Critical=Red, High=Orange, etc.)
7. **Search**: Highlight specific equipment in the diagram
8. **Mini-Map**: Overview panel for large datasets

### **Version 2.0 Ideas**:
1. **Multi-Level Sankey**: Total → Type → Location → Equipment
2. **Time-Series Sankey**: Animate flow changes over time
3. **Comparison Mode**: Side-by-side Sankey for two time periods
4. **Issue Root Cause Flow**: Show Total → Root Cause → Equipment

---

## Related Documentation

- **SQL Requirements**: `SQL_REQUIREMENTS.md`
- **Chart Recommendations**: `MODERN_CHART_RECOMMENDATIONS.md`
- **Troubleshooting Dashboard**: `TROUBLESHOOTING_DASHBOARD_IMPLEMENTATION_COMPLETE.md`
- **Quick Reference**: `QUICK_REFERENCE.md`

---

## Changelog

| Date | Version | Change |
|------|---------|--------|
| Today | 1.0 | Initial implementation of Sankey diagram |

---

**Status**: ✅ Ready for Testing
**Next Step**: Execute SQL script and test visualization
**Developer**: AI Assistant
