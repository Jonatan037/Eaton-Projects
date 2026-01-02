# Issues by Line & Location - Drill-Down Chart Implementation

## 📊 Recommended Approach: **Interactive Drill-Down Bar Chart**

### **Why Drill-Down Instead of Combined Chart?**

| Approach | Pros | Cons | Recommendation |
|----------|------|------|----------------|
| **Grouped/Stacked Bar** | Shows both levels at once | Cluttered, hard to read with many locations | ❌ Not recommended |
| **Treemap** | Space-efficient hierarchy | Less intuitive for counts | ⚠️ Alternative option |
| **Drill-Down Bar** | Clean, progressive disclosure, interactive | Requires 2 clicks to see detail | ✅ **Best choice** |

---

## 🎯 User Experience Flow

### **Initial View: Issues by Line**
```
Chart Title: Issues by Line
[Click a bar to drill down into locations]

rPDU            ████████████████████ 45 issues
9PXM            ██████████████ 32 issues
BTLN            ████████ 18 issues
HPE             ████ 12 issues
```

### **Drill-Down View: Issues by Location (within rPDU)**
```
Chart Title: Issues by Location (rPDU)
[← Back to Lines]

rPDU - Line 4   ██████████ 15 issues
rPDU - Line 2   ████████ 12 issues
rPDU - Line 1   ██████ 10 issues
rPDU - Line 3   ████ 8 issues
```

---

## 🗄️ SQL Views Created

### **View 1: `vw_Troubleshooting_IssuesByLine`**
**Purpose:** Top-level view showing issue count by Line

**Returns:**
- `Line` (e.g., "rPDU", "9PXM", "BTLN")
- `IssueCount` (number of issues)

**Example Data:**
```sql
SELECT * FROM vw_Troubleshooting_IssuesByLine;
-- Returns:
-- Line      | IssueCount
-- ----------|------------
-- rPDU      | 45
-- 9PXM      | 32
-- BTLN      | 18
```

---

### **View 2: `vw_Troubleshooting_IssuesByLineAndLocation`**
**Purpose:** Detailed view for drill-down showing Location within Line

**Returns:**
- `Line` (e.g., "rPDU")
- `Location` (e.g., "rPDU - Line 4")
- `IssueCount`

**Example Query (Drill-Down):**
```sql
-- User clicks "rPDU" bar
SELECT Location, IssueCount 
FROM vw_Troubleshooting_IssuesByLineAndLocation
WHERE Line = 'rPDU'
ORDER BY IssueCount DESC;

-- Returns:
-- Location      | IssueCount
-- --------------|------------
-- rPDU - Line 4 | 15
-- rPDU - Line 2 | 12
-- rPDU - Line 1 | 10
-- rPDU - Line 3 | 8
```

---

## 💻 Implementation Plan

### **Step 1: Execute SQL Script**
Run `Create_TroubleshootingIssuesByLineAndLocation_View.sql` in SSMS to create:
- `vw_Troubleshooting_IssuesByLine`
- `vw_Troubleshooting_IssuesByLineAndLocation`

---

### **Step 2: Update C# Code-Behind**

**Add Properties:**
```csharp
public string LineLabels { get; set; }
public string LineData { get; set; }
public string DrillDownData { get; set; } // Full hierarchy for JavaScript
```

**Add Data Loading Method:**
```csharp
// In LoadChartData() method:

// Load Line data (top level)
var lineLabels = new List<string>();
var lineValues = new List<int>();
using (var cmd = new SqlCommand("SELECT Line, IssueCount FROM dbo.vw_Troubleshooting_IssuesByLine", conn))
using (var rdr = cmd.ExecuteReader())
{
    while (rdr.Read())
    {
        lineLabels.Add(rdr["Line"].ToString());
        lineValues.Add(Convert.ToInt32(rdr["IssueCount"]));
    }
}
LineLabels = serializer.Serialize(lineLabels);
LineData = serializer.Serialize(lineValues);

// Load full drill-down data (Line + Location hierarchy)
var drillDownMap = new Dictionary<string, List<object>>();
using (var cmd = new SqlCommand(@"
    SELECT Line, Location, IssueCount 
    FROM dbo.vw_Troubleshooting_IssuesByLineAndLocation
    ORDER BY Line, IssueCount DESC", conn))
using (var rdr = cmd.ExecuteReader())
{
    while (rdr.Read())
    {
        string line = rdr["Line"].ToString();
        if (!drillDownMap.ContainsKey(line))
            drillDownMap[line] = new List<object>();
        
        drillDownMap[line].Add(new {
            location = rdr["Location"].ToString(),
            count = Convert.ToInt32(rdr["IssueCount"])
        });
    }
}
DrillDownData = serializer.Serialize(drillDownMap);
```

---

### **Step 3: Update ASPX HTML**

**Replace "Issues by Location" chart:**
```html
<div class="chart-card">
  <h3 class="chart-title" id="lineChartTitle">
    <span id="lineChartMainTitle">Issues by Line</span>
    <span id="lineChartBackBtn" style="display:none; float:right; cursor:pointer; color:#60a5fa; font-size:13px; font-weight:500;">
      ← Back to Lines
    </span>
  </h3>
  <div class="chart-container">
    <canvas id="chartLine"></canvas>
  </div>
</div>
```

---

### **Step 4: Update JavaScript**

**Replace Location chart initialization with drill-down chart:**
```javascript
// State management for drill-down
let currentView = 'line'; // 'line' or 'location'
let currentLine = null;
let lineChartInstance = null;

function initializeLineChart(colors) {
  const ctx = document.getElementById('chartLine');
  if (!ctx) return;
  
  // Destroy existing chart
  if (lineChartInstance) {
    lineChartInstance.destroy();
  }
  
  // Get data based on current view
  let labels, data, titleText;
  
  if (currentView === 'line') {
    labels = <%= LineLabels %>;
    data = <%= LineData %>;
    titleText = 'Issues by Line';
    document.getElementById('lineChartMainTitle').textContent = titleText;
    document.getElementById('lineChartBackBtn').style.display = 'none';
  } else {
    // Drill-down view
    const drillDownData = <%= DrillDownData %>;
    const locationData = drillDownData[currentLine] || [];
    labels = locationData.map(d => d.location);
    data = locationData.map(d => d.count);
    titleText = 'Issues by Location (' + currentLine + ')';
    document.getElementById('lineChartMainTitle').textContent = titleText;
    document.getElementById('lineChartBackBtn').style.display = 'inline';
  }
  
  lineChartInstance = new Chart(ctx, {
    type: 'bar',
    data: {
      labels: labels,
      datasets: [{
        label: 'Issues',
        data: data,
        backgroundColor: currentView === 'line' ? colors.primary : colors.orange,
        borderColor: currentView === 'line' ? colors.primary : colors.orange,
        borderWidth: 1,
        borderRadius: 6,
        barThickness: 'flex',
        maxBarThickness: 50
      }]
    },
    options: {
      indexAxis: 'y', // Horizontal bars
      responsive: true,
      maintainAspectRatio: false,
      onClick: (event, activeElements) => {
        if (currentView === 'line' && activeElements.length > 0) {
          // Drill down into line
          const index = activeElements[0].index;
          currentLine = labels[index];
          currentView = 'location';
          initializeLineChart(colors);
        }
      },
      plugins: {
        legend: { display: false },
        tooltip: {
          backgroundColor: colors.tooltipBg,
          titleColor: colors.text,
          bodyColor: colors.text,
          borderColor: colors.tooltipBorder,
          borderWidth: 1,
          padding: 12,
          boxPadding: 6,
          titleFont: { size: 12, weight: '600', family: "'Inter', 'Segoe UI', sans-serif" },
          bodyFont: { size: 11, family: "'Inter', 'Segoe UI', sans-serif" },
          callbacks: {
            label: function(context) {
              return 'Issues: ' + context.parsed.x;
            }
          }
        },
        datalabels: {
          anchor: 'end',
          align: 'end',
          color: colors.text,
          font: { size: 11, weight: '600', family: "'Inter', 'Segoe UI', sans-serif" },
          formatter: (value) => value
        }
      },
      scales: {
        x: {
          beginAtZero: true,
          ticks: { 
            precision: 0, 
            color: colors.textSecondary,
            font: { size: 11, family: "'Inter', 'Segoe UI', sans-serif" }
          },
          grid: { color: colors.grid }
        },
        y: {
          ticks: { 
            color: colors.textSecondary,
            font: { size: 11, family: "'Inter', 'Segoe UI', sans-serif" }
          },
          grid: { display: false }
        }
      }
    }
  });
}

// Back button handler
document.getElementById('lineChartBackBtn').addEventListener('click', function() {
  currentView = 'line';
  currentLine = null;
  const colors = getChartColors();
  initializeLineChart(colors);
});

// Call in initializeCharts()
initializeLineChart(colors);
```

---

## 🎨 Visual Design

### **Chart Appearance:**
- **Horizontal bars** (easier to read long location names)
- **Interactive hover** (cursor changes, subtle highlight)
- **Data labels** at end of each bar
- **Click indication** (cursor: pointer on line bars)
- **Back button** (blue, top-right, visible only in drill-down)

### **Color Scheme:**
- **Line view:** Blue (primary)
- **Location view:** Orange (indicates drill-down)

---

## ✅ Benefits of This Approach

1. **Clean & Uncluttered**
   - Shows one level at a time
   - Easy to read and understand

2. **Progressive Disclosure**
   - Users see overview first
   - Can explore details on demand

3. **Scalable**
   - Works with any number of lines/locations
   - No visual clutter

4. **Interactive & Engaging**
   - Click to explore
   - Visual feedback (color change, back button)

5. **Mobile-Friendly**
   - Large touch targets
   - Clear navigation

---

## 🔄 Alternative: Treemap (If You Want Both Levels Visible)

If you prefer seeing both levels simultaneously, a **Treemap** is a good alternative:

### **Treemap Appearance:**
```
┌─────────────────────────────────────────┐
│ rPDU (45)                               │
│ ┌──────────┬──────────┬────────┬──────┐│
│ │Line 4(15)│Line 2(12)│Line 1  │Line 3││
│ │          │          │ (10)   │ (8)  ││
│ └──────────┴──────────┴────────┴──────┘│
├─────────────────────────────────────────┤
│ 9PXM (32)                               │
│ ┌───────────────┬──────────────────────┐│
│ │ Station 1 (18)│ Station 2 (14)      ││
│ └───────────────┴──────────────────────┘│
└─────────────────────────────────────────┘
```

**Pros:**
- See entire hierarchy at once
- Space-efficient

**Cons:**
- Harder to compare exact values
- Requires D3.js library
- More complex implementation

---

## 📝 Next Steps

1. **Execute SQL:** Run `Create_TroubleshootingIssuesByLineAndLocation_View.sql`
2. **Choose Approach:** Drill-Down (recommended) or Treemap (alternative)
3. **Implement C# & JavaScript:** I can provide complete code for either approach

**Which approach would you prefer?**
- ✅ **Drill-Down Bar Chart** (recommended - interactive, clean, mobile-friendly)
- 🔄 **Treemap** (alternative - shows both levels simultaneously)

Let me know and I'll implement it completely!
