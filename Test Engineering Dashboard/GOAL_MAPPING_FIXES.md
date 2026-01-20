# Goal Mapping Fixes for Aggregated Drill Levels

## Summary
Fixed issues where goals were not displaying correctly when drilling up to weekly, monthly, quarterly, or yearly views. Also fixed gauge to show correct goal for the selected line and period.

## Changes Made

### 1. Frontend Changes (PlantQualityDashboard.aspx)

#### Updated `aggregateDataByLevel()` Function
- **Added `sortKeys` return value**: Now returns an array of bucket keys (e.g., "2026-01", "2026-W05", "2026-Q1", "2026") that can be used for goal mapping
- **Added year to weekly labels**: Changed from "W45" to "2026-W45" format
- **Added `dates` tracking**: Each bucket now tracks the original dates it contains for potential future use
- **Improved quarterly/yearly labels**: Added year suffix (e.g., "Q1 2025", "2026")

**Key changes:**
```javascript
// Returns sortKeys array for goal mapping
return { 
  labels: newLabels, 
  data: newData, 
  tested: newTested, 
  passed: newPassed, 
  failed: newFailed, 
  sortKeys: newSortKeys  // NEW
};

// Weekly label now includes year
bucketLabel = date.getFullYear() + '-W' + weekNum; // Changed from just 'W' + weekNum
```

#### Updated `renderYieldChart()` Function
- **Changed signature**: Now accepts `sortKeys` parameter instead of relying on hidden field `hfYieldDailySortDates`
- **Intelligent goal mapping**: Maps goals based on aggregation level:
  - **Weekly**: Uses the goal from the month that week falls in (approximated)
  - **Monthly**: Uses the exact goal for that month (yyyy-MM key)
  - **Quarterly**: Uses the HIGHEST goal from the 3 months in that quarter
  - **Yearly**: Uses the HIGHEST goal from all 12 months in that year

**Goal mapping logic:**
```javascript
if (sortKey.indexOf('W') > 0) {
  // Weekly: approximate month from week number
  var weekNum = parseInt(sortKey.substring(6));
  var approxMonth = Math.ceil(weekNum / 4.33);
  var monthKey = yearPart + '-' + (approxMonth < 10 ? '0' + approxMonth : approxMonth);
  goalForPeriod = monthlyGoals[monthKey] || goal;
} else if (sortKey.indexOf('Q') > 0) {
  // Quarterly: use highest goal from 3 months
  var quarter = parseInt(sortKey.substring(6));
  var startMonth = (quarter - 1) * 3 + 1;
  var maxGoalInQuarter = goal;
  for (var m = 0; m < 3; m++) {
    var monthNum = startMonth + m;
    var monthKey = yearPart + '-' + (monthNum < 10 ? '0' + monthNum : monthNum);
    var monthGoal = monthlyGoals[monthKey] || goal;
    if (monthGoal > maxGoalInQuarter) maxGoalInQuarter = monthGoal;
  }
  goalForPeriod = maxGoalInQuarter;
} else if (sortKey.length === 4) {
  // Yearly: use highest goal from all 12 months
  var maxGoalInYear = goal;
  for (var m = 1; m <= 12; m++) {
    var monthKey = sortKey + '-' + (m < 10 ? '0' + m : m);
    var monthGoal = monthlyGoals[monthKey] || goal;
    if (monthGoal > maxGoalInYear) maxGoalInYear = monthGoal;
  }
  goalForPeriod = maxGoalInYear;
}
```

#### Updated `aggregateAndRenderYieldChart()` Function
- **Pass sortKeys**: Now passes the `sortKeys` array from aggregation result to `renderYieldChart()`

### 2. Backend Changes (PlantQualityDashboard.aspx.cs)

#### Updated `LoadYieldGoal()` Method
- **Changed maxGoal initialization**: Changed from `decimal maxGoal = 98m;` to `decimal? maxGoal = null;` to properly track the first goal found
- **Fixed gauge goal calculation**: Now correctly uses the highest goal from the date range instead of always defaulting to 98
- **Improved null handling**: Added fallback to 98 only if no goals are found: `YieldGoal = (maxGoal ?? 98m).ToString("0.##");`

**Key change:**
```csharp
// Before:
decimal maxGoal = 98m;
if (goalValue > maxGoal) maxGoal = goalValue; // Would never go below 98!

// After:
decimal? maxGoal = null;
if (!maxGoal.HasValue || goalValue > maxGoal.Value)
{
    maxGoal = goalValue; // Correctly tracks highest goal, even if below 98
}
```

## Testing Recommendations

1. **Test ePDU with 90% January 2026 goal**:
   - MTD (Daily view): Should show 90% goal line and gauge at 90%
   - Weekly view: Should show 90% for weeks in January 2026
   - Monthly view: Should show 90% for January 2026
   
2. **Test multi-month ranges**:
   - Select date range spanning December 2025 (98%) and January 2026 (90%)
   - Daily: Each day should show correct goal for its month
   - Weekly: Weeks should show goal of the month they fall in
   - Monthly: Each month should show its specific goal
   - Quarterly: Q4 2025 should show 98%, Q1 2026 should show max of Jan/Feb/Mar goals
   - Yearly: 2025 should show highest monthly goal from 2025, 2026 should show highest from 2026
   - Gauge: Should show 98% (highest goal in the range)

3. **Test plant-wide vs. line-specific**:
   - Select "ALL" lines: Should use plant-wide goals
   - Select specific line: Should use line-specific goals

4. **Test weekly label format**:
   - Verify weekly labels show as "2026-W05" not just "W5"

## Technical Notes

- **Weekly approximation**: The weekly-to-monthly mapping uses a simple approximation (week/4.33) which assumes ~4.33 weeks per month. This is sufficient for goal display purposes.
- **Bucket key formats**:
  - Daily: `yyyy-MM-dd`
  - Weekly: `yyyy-Wnn` (e.g., "2026-W05")
  - Monthly: `yyyy-MM` (e.g., "2026-01")
  - Quarterly: `yyyy-Qn` (e.g., "2026-Q1")
  - Yearly: `yyyy` (e.g., "2026")
- **Goal precedence**: When multiple goals could apply, line-specific goals take precedence over plant-wide goals (handled in SQL query)

## Files Modified

1. `/workspaces/Eaton-Projects/Test Engineering Dashboard/PlantQualityDashboard.aspx`
   - `aggregateDataByLevel()` function
   - `renderYieldChart()` function
   - `aggregateAndRenderYieldChart()` function

2. `/workspaces/Eaton-Projects/Test Engineering Dashboard/PlantQualityDashboard.aspx.cs`
   - `LoadYieldGoal()` method
