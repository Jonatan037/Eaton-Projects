# Tooltip Improvements Summary

## Date: November 6, 2025

## Changes Made

### 1. Calibration Dashboard - KPI Card Tooltip Fixes

**Issue:** Tooltips on the gauge charts (On-Time Calibration Rate and Out of Tolerance) were getting cut off at the edge of the viewport.

**Solution:** Replaced the default Chart.js tooltip with an external custom tooltip that:
- Creates a tooltip element appended to `document.body` (not constrained by parent containers)
- Uses `position: absolute` with proper z-index (`10000`)
- Positions dynamically based on the chart canvas position
- Matches the styling from PM Dashboard for consistency

**Files Modified:**
- `CalibrationDashboard.aspx` (lines ~1469-1589)

**Charts Updated:**
- **On-Time Calibration Rate** (`gaugeOnTime`): Now uses external tooltip with proper positioning
- **Out of Tolerance** (`gaugeOOT`): Now uses external tooltip with proper positioning

**Tooltip Features:**
- Clean, modern styling matching the rest of the dashboard
- Theme-aware colors (dark/light mode support)
- Positioned to the right of the gauge to avoid cutoff
- Smooth fade-in/out transitions
- Displays metric name and current value with target

### 2. PM Dashboard - Mini-Line Chart Tooltip Improvements

**Issue:** 
- AVG PM DURATION and AVG COST PER PM tooltips were showing generic labels like "PM 1, PM 2"
- Tooltips included "Average" line information that cluttered the display

**Solution:**
- Updated tooltips to show actual PMLogID values (e.g., "PMID: 12345")
- Removed the "Average" dataset from the tooltip display
- Simplified tooltip to show only the actual data point value

**Files Modified:**
- `PMDashboard.aspx` (lines ~1669-1800)

**Charts Updated:**

#### AVG PM DURATION Chart (`miniLineDuration`):
- **Before:** 
  - Labels: "PM 1, PM 2, PM 3..."
  - Tooltip showed: "Duration: X hours" and "Average (38m): 38 minutes"
- **After:**
  - Labels: "PMID: 12345, PMID: 12346..."
  - Tooltip shows: "PMID: 12345" (title) and "38 minutes" (body)
  - Removed average line from datasets
  - Disabled displayColors for cleaner tooltip

#### AVG COST PER PM Chart (`miniLineCost`):
- **Before:**
  - Labels: "PM 1, PM 2, PM 3..."
  - Tooltip showed: "Cost: $X.XX" and "Average ($4.60): $4.60"
- **After:**
  - Labels: "PMID: 12345, PMID: 12346..."
  - Tooltip shows: "PMID: 12345" (title) and "$4.60" (body)
  - Removed average line from datasets
  - Disabled displayColors for cleaner tooltip

## Technical Details

### External Tooltip Implementation (Calibration Dashboard)

```javascript
tooltip: {
  enabled: false,
  external: function(context) {
    let tooltipEl = document.getElementById('chartjs-tooltip-[unique-id]');
    
    if (!tooltipEl) {
      tooltipEl = document.createElement('div');
      tooltipEl.id = 'chartjs-tooltip-[unique-id]';
      tooltipEl.style.position = 'absolute';
      tooltipEl.style.pointerEvents = 'none';
      tooltipEl.style.transition = 'all .2s ease';
      tooltipEl.style.zIndex = '10000';
      document.body.appendChild(tooltipEl);
    }
    
    const tooltipModel = context.tooltip;
    if (tooltipModel.opacity === 0) {
      tooltipEl.style.opacity = 0;
      return;
    }
    
    // Set tooltip content and position
    const position = context.chart.canvas.getBoundingClientRect();
    tooltipEl.style.left = position.left + window.pageXOffset + 10 + 'px';
    tooltipEl.style.top = position.top + window.pageYOffset + position.height / 2 + 'px';
  }
}
```

### Simplified Tooltip Configuration (PM Dashboard)

```javascript
tooltip: {
  backgroundColor: colors.tooltipBg,
  titleColor: colors.text,
  bodyColor: colors.text,
  borderColor: colors.tooltipBorder,
  borderWidth: 1,
  padding: 8,
  displayColors: false,  // Removed color boxes
  callbacks: {
    title: function(context) { 
      return context[0].label;  // Shows PMID
    },
    label: function(context) { 
      return context.parsed.y.toFixed(0) + ' minutes';  // Just the value
    }
  }
}
```

## Benefits

1. **Improved UX**: Tooltips no longer get cut off at viewport edges
2. **Better Data Identification**: PMLogID provides direct reference to specific PM records
3. **Cleaner Presentation**: Removed redundant "Average" information from tooltips
4. **Consistency**: Both dashboards now use similar tooltip patterns where appropriate
5. **Theme Support**: All tooltips properly support dark/light theme switching

## Testing Notes

Test the following scenarios:
1. Hover over gauge charts in Calibration Dashboard (both dark and light themes)
2. Verify tooltips appear to the right and don't get cut off
3. Hover over mini-line charts in PM Dashboard
4. Verify PMID is displayed in tooltip title
5. Verify only the data point value is shown (no average line info)
6. Test theme switching to ensure tooltip colors update correctly
7. Test on different screen sizes to ensure tooltips are always visible

## Future Enhancements

Consider applying similar external tooltip pattern to other charts that may have clipping issues, particularly:
- Bullet charts
- Charts in narrow containers
- Charts near viewport edges
