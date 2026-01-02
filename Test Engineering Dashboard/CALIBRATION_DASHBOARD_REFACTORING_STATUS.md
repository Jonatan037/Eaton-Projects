# Calibration Dashboard Refactoring Status

## Date: Current Session
## Objective: Transform CalibrationDashboard.aspx to match PM Dashboard styling with GridView tables, Sankey diagram, and updated data sources

---

## ✅ COMPLETED TASKS

### 1. Backend Refactoring (CalibrationDashboard.aspx.cs)
- **✓ Class Properties**: Removed all chart-related properties (MonthlyLabels, MonthlyData, EquipmentTypeLabels, etc.)
- **✓ Class Properties**: Kept only: KPI properties, SankeyData, DueCals, OverdueCals
- **✓ Page_Load**: Updated to call LoadSankeyData() instead of LoadChartData()
- **✓ LoadKPIs Method**: Completely rewritten to use `vw_Equipment_RequireCalibration` view
  - Queries for Due count using 30-day timeframe
  - Queries for Overdue count using current date filter
  - Queries Calibration_Log for metrics (On-Time rate, OOT rate, Average Turnaround, Average Cost)
- **✓ LoadSankeyData Method**: Added - Queries `vw_Calibration_SankeyData` view and serializes to JSON
- **✓ LoadUpcomingCalibrations Method**: Rewritten to query Equipment_RequireCalibration for 30-day window
  - Returns: EatonID, EquipmentName, Location, LastCalibration, CalibrationStatus, NextCalibration
  - Binds data to GridView `gvUpcomingCals`
- **✓ LoadRecentLogs Method**: Rewritten to query Calibration_Log table
  - Returns: CalibrationLogID, EquipmentName, Method, CalibrationDate, CalibratedBy, ResultCode, Cost, IsOnTime, IsOOT
  - Binds data to GridView `gvRecentLogs`
- **✓ Row Data Bound Handlers**: Added empty handlers for `gvUpcomingCals_RowDataBound` and `gvRecentLogs_RowDataBound`
- **✓ GetResultClass/GetStatusClass/GetOnTimeClass**: Kept existing helper methods
- **✓ btnViewDetails_Click**: Updated to redirect to most recent CalibrationLogID
- **✓ LoadChartData Method**: REMOVED completely (was ~130 lines generating 5 charts)
- **✓ Duplicates Removed**: Eliminated duplicate LoadRecentLogs and btnViewDetails_Click methods

### 2. SQL View Creation
- **✓ Created**: `/workspaces/Eaton-Projects/Test Engineering Dashboard/Create_Calibration_SankeyData_View.sql`
- **Structure**: 4-level Sankey hierarchy
  - Level 1: Total Equipment (from vw_Equipment_RequireCalibration)
  - Level 2: Device Type (ATE, Asset, Fixture, Harness)
  - Level 3: Calibration Status (Pending Calibration, Up-to-Date)
  - Level 4: Result (Pass, OOT, Unknown - from recent Calibration_Log records)
- **Status**: File created, SQL script ready, **USER MUST EXECUTE ON DATABASE**

### 3. Frontend Updates (CalibrationDashboard.aspx) - PARTIAL
- **✓ Removed**: Chart sections (Monthly Volume, Equipment Type, Method, Vendor Performance, Results)
- **✓ Removed**: Old Repeater controls (rptUpcoming, rptRecentLogs)
- **✓ Added**: GridView control `gvUpcomingCals` with 6 columns (EatonID, EquipmentName, Location, LastCalibration, Status, NextCalibration)
- **✓ Added**: GridView control `gvRecentLogs` with 9 columns including templated toggle columns for IsOnTime/IsOOT
- **✓ Added**: Sankey diagram section with SVG element `id="sankeyCalibration"`
- **✓ Reordered**: Layout now: KPI Cards → Upcoming Calibrations Table → Sankey Diagram → Recent Logs Table
- **✓ Added D3.js**: Added D3.js v7 and d3-sankey 0.12.3 script references to head section

---

## ⚠️ INCOMPLETE TASKS

### 1. JavaScript Refactoring (CalibrationDashboard.aspx)
**Location**: Lines ~1926-2290 in CalibrationDashboard.aspx

**REMOVE THIS CODE**:
```javascript
// Monthly Volume Chart (Line/Area) - Lines ~1926-1998
const ctxMonthly = document.getElementById('chartMonthlyVolume');
if (ctxMonthly) {
  chartInstances.monthly = new Chart(ctxMonthly, {
    // ... ~70 lines of chart config
  });
}

// Equipment Type Distribution (Doughnut) - Lines ~1998-2093
const ctxEquipment = document.getElementById('chartEquipmentType');
// ... ~95 lines

// Method Distribution (Pie) - Lines ~2093-2141
const ctxMethod = document.getElementById('chartMethod');
// ... ~48 lines

// Vendor Performance (Horizontal Bar) - Lines ~2141-2234
const ctxVendor = document.getElementById('chartVendor');
// ... ~93 lines

// Results Distribution (Doughnut) - Lines ~2234-2290
const ctxResults = document.getElementById('chartResults');
// ... ~56 lines
```

**REPLACE WITH THIS CODE**:
```javascript
      // === Sankey Diagram Initialization ===
      const sankeyData = <%= SankeyData ?? "{\"nodes\":[],\"links\":[]}" %>;
      
      function initializeSankey() {
        const isDark = !document.documentElement.classList.contains('theme-light') && 
                       document.documentElement.getAttribute('data-theme') !== 'light';
        
        const svg = d3.select("#sankeyCalibration");
        svg.selectAll("*").remove();  // Clear previous
        
        const containerWidth = document.querySelector(".sankey-container").clientWidth - 40;
        const width = containerWidth;
        const height = 400;
        
        svg.attr("viewBox", [0, 0, width, height]);
        
        const sankey = d3.sankey()
          .nodeWidth(15)
          .nodePadding(10)
          .extent([[1, 1], [width - 1, height - 5]]);
        
        const {nodes, links} = sankey({
          nodes: sankeyData.nodes.map(d => Object.assign({}, d)),
          links: sankeyData.links.map(d => Object.assign({}, d))
        });
        
        // Define color scale
        const colorScale = d3.scaleOrdinal()
          .domain(nodes.map(d => d.name))
          .range(isDark ? 
            ['#60a5fa', '#34d399', '#fbbf24', '#f87171', '#a78bfa', '#fb923c', '#ec4899'] :
            ['#2563eb', '#10b981', '#f59e0b', '#ef4444', '#8b5cf6', '#f97316', '#db2777']);
        
        // Draw links
        svg.append("g")
          .attr("fill", "none")
          .selectAll("path")
          .data(links)
          .join("path")
            .attr("d", d3.sankeyLinkHorizontal())
            .attr("stroke", d => colorScale(d.source.name))
            .attr("stroke-opacity", isDark ? 0.3 : 0.2)
            .attr("stroke-width", d => Math.max(1, d.width))
            .on("mouseover", function(event, d) {
              d3.select(this).attr("stroke-opacity", isDark ? 0.6 : 0.5);
            })
            .on("mouseout", function(event, d) {
              d3.select(this).attr("stroke-opacity", isDark ? 0.3 : 0.2);
            })
          .append("title")
            .text(d => `${d.source.name} → ${d.target.name}\n${d.value} equipment`);
        
        // Draw nodes
        svg.append("g")
          .selectAll("rect")
          .data(nodes)
          .join("rect")
            .attr("x", d => d.x0)
            .attr("y", d => d.y0)
            .attr("height", d => d.y1 - d.y0)
            .attr("width", d => d.x1 - d.x0)
            .attr("fill", d => colorScale(d.name))
            .attr("opacity", isDark ? 0.8 : 0.85)
            .attr("stroke", isDark ? "#1e293b" : "#e2e8f0")
            .attr("stroke-width", 1)
            .on("mouseover", function(event, d) {
              d3.select(this).attr("opacity", 1);
            })
            .on("mouseout", function(event, d) {
              d3.select(this).attr("opacity", isDark ? 0.8 : 0.85);
            })
          .append("title")
            .text(d => `${d.name}\n${d.value} equipment`);
        
        // Draw labels
        svg.append("g")
          .style("font", "10px Segoe UI, sans-serif")
          .style("fill", isDark ? "#e2e8f0" : "#334155")
          .selectAll("text")
          .data(nodes)
          .join("text")
            .attr("x", d => d.x0 < width / 2 ? d.x1 + 6 : d.x0 - 6)
            .attr("y", d => (d.y1 + d.y0) / 2)
            .attr("dy", "0.35em")
            .attr("text-anchor", d => d.x0 < width / 2 ? "start" : "end")
            .text(d => d.name)
            .style("font-weight", "600");
      }

      if (sankeyData && sankeyData.nodes && sankeyData.nodes.length > 0) {
        initializeSankey();
      }
    }
```

### 2. Update DOMContentLoaded Event Listener
**Location**: End of script section, lines ~2292-2307

**CURRENT CODE**:
```javascript
    // Initialize charts on page load
    document.addEventListener('DOMContentLoaded', function() {
      initializeCharts();
      
      // Listen for theme changes
      const observer = new MutationObserver(function(mutations) {
        mutations.forEach(function(mutation) {
          if (mutation.type === 'attributes' && 
              (mutation.attributeName === 'class' || mutation.attributeName === 'data-theme')) {
            console.log('Theme changed, reinitializing charts...');
            initializeCharts();
          }
        });
      });
```

**SHOULD BE UPDATED TO ALSO CALL** `initializeSankey()` **on theme changes:**
```javascript
    // Initialize charts on page load
    document.addEventListener('DOMContentLoaded', function() {
      initializeCharts();
      
      // Listen for theme changes
      const observer = new MutationObserver(function(mutations) {
        mutations.forEach(function(mutation) {
          if (mutation.type === 'attributes' && 
              (mutation.attributeName === 'class' || mutation.attributeName === 'data-theme')) {
            console.log('Theme changed, reinitializing charts and Sankey...');
            initializeCharts();
            initializeSankey(); // ADD THIS LINE
          }
        });
      });
```

### 3. CSS Styling for GridView Tables
**Location**: Head section `<style>` tag

**ADD THIS CSS** (after existing chart styles):
```css
/* GridView Table Styling */
.modern-table {
  width: 100%;
  border-collapse: collapse;
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
  background: rgba(255, 255, 255, 0.05);
  border-radius: 8px;
  overflow: hidden;
}

.modern-table th {
  background-color: #2563eb !important;
  color: white !important;
  font-weight: bold;
  font-size: 11px;
  padding: 12px 10px;
  text-align: left;
}

.modern-table td {
  padding: 10px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.08);
}

html.theme-light .modern-table td,
html[data-theme='light'] .modern-table td {
  border-bottom: 1px solid rgba(0, 0, 0, 0.08);
}

.modern-table tr:hover {
  background: rgba(37, 99, 235, 0.1);
}

.toggle-indicator {
  display: inline-block;
  padding: 3px 8px;
  border-radius: 4px;
  font-size: 10px;
  font-weight: bold;
}

.toggle-on {
  background: rgba(16, 185, 129, 0.2);
  color: #10b981;
}

.toggle-off {
  background: rgba(239, 68, 68, 0.2);
  color: #ef4444;
}

/* Table Section Headers */
.table-section {
  margin-bottom: 20px;
}

.table-header {
  margin-bottom: 12px;
}

.table-title {
  font-size: 16px;
  font-weight: 600;
  color: #e2e8f0;
  margin: 0;
}

html.theme-light .table-title,
html[data-theme='light'] .table-title {
  color: #1b222b;
}

/* Sankey Section */
.sankey-section {
  margin-bottom: 20px;
}

.sankey-header {
  margin-bottom: 12px;
}

.sankey-title {
  font-size: 16px;
  font-weight: 600;
  color: #e2e8f0;
  margin: 0 0 4px 0;
}

.sankey-subtitle {
  font-size: 12px;
  color: rgba(255, 255, 255, 0.6);
  margin: 0;
}

html.theme-light .sankey-title,
html[data-theme='light'] .sankey-title {
  color: #1b222b;
}

html.theme-light .sankey-subtitle,
html[data-theme='light'] .sankey-subtitle {
  color: rgba(0, 0, 0, 0.6);
}

.sankey-container {
  background: rgba(25, 29, 37, 0.4);
  border: 1px solid rgba(255, 255, 255, 0.08);
  border-radius: 12px;
  padding: 20px;
  min-height: 400px;
}

html.theme-light .sankey-container,
html[data-theme='light'] .sankey-container {
  background: rgba(255, 255, 255, 0.7);
  border: 1px solid rgba(0, 0, 0, 0.08);
}
```

---

## 🔄 TESTING REQUIREMENTS

### Before Testing:
1. **Execute SQL Script**: Run `Create_Calibration_SankeyData_View.sql` in SQL Server Management Studio against TestEngineering database
2. **Verify View Exists**: Check that `vw_Calibration_SankeyData` view is created
3. **Complete JavaScript Replacement**: Follow instructions in "INCOMPLETE TASKS" section above

### Test Scenarios:
1. **KPI Cards**: Verify DUE CALIBRATIONS shows correct count from Equipment_RequireCalibration
2. **Upcoming Calibrations Table**: Should show equipment due in next 30 days with proper columns
3. **Sankey Diagram**: Should display 4-level flow: Equipment → Device Type → Status → Result
4. **Recent Logs Table**: Should show last 20 calibration logs with toggle indicators
5. **Theme Switching**: Test dark/light theme compatibility for all elements
6. **Responsive Layout**: Verify tables and Sankey diagram render properly at different viewport sizes

---

## 📋 FINAL CHECKLIST

- [x] Backend C# code refactored
- [x] SQL view script created
- [ ] Execute SQL view script on database **← USER ACTION REQUIRED**
- [x] Frontend markup updated (GridViews, Sankey SVG)
- [ ] JavaScript refactored (remove charts, add Sankey) **← INCOMPLETE**
- [ ] CSS styling added for GridView and Sankey **← INCOMPLETE**
- [ ] DOMContentLoaded listener updated **← INCOMPLETE**
- [ ] Test DUE CALIBRATIONS KPI accuracy
- [ ] Test GridView table data binding
- [ ] Test Sankey diagram rendering
- [ ] Test theme switching
- [ ] Verify no console errors

---

## 🚀 NEXT STEPS (IN ORDER)

1. **Complete JavaScript Replacement** (see section above with exact code to find/replace)
2. **Add CSS Styling** (copy CSS block from section above into `<style>` tag)
3. **Execute SQL Script**: `Create_Calibration_SankeyData_View.sql`
4. **Test Dashboard**: Load CalibrationDashboard.aspx and verify all elements
5. **Debug Issues**: Check browser console for JavaScript errors, check SQL for view query errors
6. **Document Results**: Create CALIBRATION_DASHBOARD_COMPLETE.md when all tests pass

---

## 📝 NOTES

- All backend changes compile successfully (0 errors after cleanup)
- GridView controls use proper ASP.NET data binding with `OnRowDataBound` events
- Sankey diagram follows PM Dashboard pattern with D3.js v7 and d3-sankey 0.12.3
- Toggle indicators in Recent Logs table use conditional rendering: `Convert.ToBoolean(Eval("IsOnTime"))`
- CalibrationStatus column calculates: "Overdue", "Due This Week", "Due This Month", "Due Soon"
- Cost column formatted as currency: `DataFormatString="${0:N2}"`
- Date columns formatted: `DataFormatString="{0:MMM dd, yyyy}"`

---

**Document Created**: Current Session  
**Last Updated**: Current Session  
**Status**: 70% Complete - JavaScript and CSS updates remaining
