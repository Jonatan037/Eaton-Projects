# Filter Reset and Default Chart Type Fixes

## Summary
Fixed two issues:
1. Filter persistence issue where filters displayed in UI didn't match the default data after page refresh or navigation
2. Changed Yield Daily chart default view from Column to Line

## Changes Made

### 1. Filter Reset on Page Load

**Problem**: When refreshing the browser or navigating back from goals page, the filter selections (Line, Date Range) stayed visible in the UI, but the backend loaded default data. This caused a mismatch where the displayed filters didn't reflect the actual data being shown.

**Solution**: Clear localStorage filter state on every page load, ensuring filters always start at defaults (ALL lines, MTD date range).

**File Modified**: `PlantQualityDashboard.aspx`

**Changed Code**:
```javascript
// Before: Restored saved filter state from localStorage
(function() {
  var savedLines = localStorage.getItem('pqd_lineSelection');
  var savedPreset = localStorage.getItem('pqd_datePreset');
  // ... restored saved values
})();

// After: Clear filter state to match backend defaults
(function() {
  // Clear any saved filter state
  localStorage.removeItem('pqd_lineSelection');
  localStorage.removeItem('pqd_datePreset');
  localStorage.removeItem('pqd_customStartDate');
  localStorage.removeItem('pqd_customEndDate');
  
  // Reset to defaults
  currentLineSelection = ['ALL'];
  currentDatePreset = 'MTD';
  currentCustomStartDate = '';
  currentCustomEndDate = '';
})();
```

**Behavior**:
- ✅ On page load/refresh: All filters reset to defaults (ALL lines, MTD)
- ✅ During active session: Filters persist when navigating within the filter modal
- ✅ When returning from Goals page: Filters reset to defaults
- ✅ UI now always matches the data being displayed

**Note**: The localStorage save logic in `applyFilters()` is intentionally kept. This allows filters to persist during active use of the modal, but they reset on page refresh.

### 2. Default Chart Type Changed to Line

**Problem**: Yield Daily chart defaulted to Column view, but Line view is preferred.

**Solution**: Changed the default chart type from 'bar' (Column) to 'line'.

**Files Modified**: `PlantQualityDashboard.aspx`

**Changes**:

1. **JavaScript variable initialization** (line ~2063):
```javascript
// Before:
var currentYieldType = 'bar';

// After:
var currentYieldType = 'line';
```

2. **Button active state** (line ~1551):
```html
<!-- Before: -->
<button type="button" class="active" onclick="setYieldChartType('bar')">Column</button>
<button type="button" onclick="setYieldChartType('line')">Line</button>

<!-- After: -->
<button type="button" onclick="setYieldChartType('bar')">Column</button>
<button type="button" class="active" onclick="setYieldChartType('line')">Line</button>
```

**Behavior**:
- ✅ Yield Daily chart now loads in Line view by default
- ✅ Line button is highlighted as active on page load
- ✅ Users can still switch to Column or Table views as needed

## Testing Recommendations

### Test Filter Reset
1. **Initial load**: 
   - Load page → Verify "All Lines" and "MTD" are shown in filter panel
   - Verify gauge shows "Plantwide | Month to date"
   - Verify charts show MTD data for all lines

2. **Apply custom filters**:
   - Select "ePDU" line and "1/1/2025 to 7/1/2026" date range
   - Click Apply → Verify data updates correctly
   - Verify filter panel shows "ePDU" and "Period: 1/1/2025 to 7/1/2026"

3. **Refresh page**:
   - Press F5 or refresh browser
   - ✅ VERIFY: Filter panel resets to "All Lines" and "MTD"
   - ✅ VERIFY: Charts show MTD data for all lines (default)
   - ✅ VERIFY: No mismatch between displayed filters and actual data

4. **Navigate away and back**:
   - With filters applied, click "Goal Settings"
   - Click browser back button
   - ✅ VERIFY: Filters reset to defaults
   - ✅ VERIFY: Charts show default data

### Test Default Chart Type
1. **Load page**:
   - ✅ VERIFY: Yield Daily chart displays as Line (not Column)
   - ✅ VERIFY: "Line" button is highlighted in the toggle
   
2. **Switch views**:
   - Click "Column" → Chart switches to column view
   - Click "Line" → Chart switches back to line view
   - Click "Table" → Shows table view

3. **Refresh after changing view**:
   - Switch to Column view
   - Refresh page
   - ✅ VERIFY: Chart resets to Line view (default)

## Technical Notes

- **localStorage behavior**: 
  - Cleared on every page load via IIFE (immediately invoked function expression)
  - Still set during `applyFilters()` for within-session persistence
  - This allows smooth UX during active filtering while ensuring clean state on reload

- **Chart initialization**:
  - `currentYieldType` determines initial render
  - Button active state must match the `currentYieldType` value
  - Chart renders on page load using this default type

- **Backend independence**:
  - Backend always loads default data (ALL lines, MTD) on non-postback loads
  - Frontend now matches this behavior by resetting filter UI
  - Postback (via Apply button) correctly passes selected filters to backend

## Files Modified

1. `/workspaces/Eaton-Projects/Test Engineering Dashboard/PlantQualityDashboard.aspx`
   - localStorage clear logic (~line 2024-2036)
   - `currentYieldType` default value (~line 2063)
   - Button active state (~line 1552)
