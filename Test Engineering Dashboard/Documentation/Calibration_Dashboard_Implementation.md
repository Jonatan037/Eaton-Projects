# Calibration Dashboard Implementation Guide

**Created:** October 2, 2025  
**Purpose:** Modern KPI-driven dashboard for Calibration Management  
**Status:** ✅ Complete and Ready for Testing

---

## Overview

The Calibration Dashboard is a modern, data-driven page that displays real-time KPIs for calibration management along with a searchable/filterable table of all calibration log records.

### Key Features
- **5 Modern KPI Cards** with Red/Amber/Green status indicators
- **Real-time data** from `vw_CalibrationKPIs` SQL view
- **Searchable data table** showing all calibration records
- **Sorting & Pagination** controls
- **Light/Dark theme support**
- **Responsive design** matching Equipment Inventory page style

---

## Files Created

### 1. `Calibration.aspx`
**Location:** `/Test Engineering Dashboard/Calibration.aspx`

**Purpose:** Main UI page with KPI cards and data table

**Key Components:**
- **KPI Grid** - 5 cards displaying:
  - Overdue Calibrations (Count)
  - Due Next 30 Days (Count)
  - On-Time Rate (Percentage)
  - Out of Tolerance Rate (Percentage)
  - Average Turnaround (Days)

- **Calibration Table** - GridView showing:
  - CalibrationID, EquipmentType, EquipmentID
  - Calibration dates (CalibrationDate, CompletedDate, StartDate, etc.)
  - Result information (ResultCode, IsOnTime, IsOutOfTolerance)
  - Cost, Method (Internal/External), VendorName
  - Performance metrics (TurnaroundDays, VendorLeadDays)
  - Technician and Notes

- **Filters:**
  - Search box (searches across Equipment ID, Type, Result, Vendor, Technician, Notes)
  - Sort by: Date (Newest/Oldest), Equipment ID, Equipment Type, Status
  - Page size: 10, 25, 50, 100 records

### 2. `Calibration.aspx.cs`
**Location:** `/Test Engineering Dashboard/Calibration.aspx.cs`

**Purpose:** Code-behind logic for data binding and KPI calculation

**Key Methods:**

```csharp
LoadKPIs()
```
- Queries `vw_CalibrationKPIs` view
- Populates 5 KPI cards with real-time data
- Applies Red/Amber/Green status classes based on thresholds

**Thresholds (from KPI Design Spec):**
- **Overdue:** Red if > 0, Green if 0
- **Due Next 30 Days:** Red if > 10, Amber if > 5, Green if ≤ 5
- **On-Time Rate:** Green if ≥ 95%, Amber if ≥ 90%, Red if < 90%
- **OOT Rate:** Green if < 1%, Amber if < 3%, Red if ≥ 3%
- **Avg Turnaround:** Displayed for reference (green card)

```csharp
BindCalibrationGrid()
```
- Loads all calibration records from `Calibration_Log` table
- Applies search filter if provided
- Sorts by user selection
- Binds to GridView with auto-generated columns

```csharp
ApplyStatusClass()
```
- Applies CSS class (`status-red`, `status-amber`, `status-green`) to KPI cards
- Supports both "higher is better" (On-Time Rate) and "lower is better" (Overdue, OOT) metrics

---

## Database Dependencies

### Required Views
This page requires the **`vw_CalibrationKPIs`** view created by `Add_KPI_Views.sql`.

**View Structure:**
```sql
vw_CalibrationKPIs returns:
  - TotalOverdue, OverdueATE, OverdueAsset, OverdueFixture, OverdueHarness
  - TotalDueNext30Days, DueNext30ATE, DueNext30Asset, DueNext30Fixture, DueNext30Harness
  - TotalCalibrations (last 12 months)
  - OnTimeRate (percentage)
  - OOTRate (percentage)
  - AvgTurnaroundDays
  - TotalCostLast12Mo
```

### Required Tables
- **`Calibration_Log`** - Must have new KPI columns from `Add_KPI_Columns.sql`:
  - `PrevDueDate`, `StartDate`, `SentOutDate`, `ReceivedDate`, `CompletedDate`
  - `ResultCode`, `VendorName`, `Method`
  - Computed: `CompletedOn`, `IsOnTime`, `IsOutOfTolerance`, `TurnaroundDays`, `VendorLeadDays`

---

## Design System

### KPI Card Classes
```css
.kpi-card { /* Base glassmorphic card */ }
.kpi-card.status-red { border-left: 4px solid #ef4444; /* Red indicator */ }
.kpi-card.status-amber { border-left: 4px solid #f59e0b; /* Amber indicator */ }
.kpi-card.status-green { border-left: 4px solid #10b981; /* Green indicator */ }
```

### Theme Support
- **Dark Theme:** Glassmorphic cards with rgba backgrounds, subtle borders, strong shadows
- **Light Theme:** White/light gray gradients, softer shadows, higher contrast text
- **Automatic switching** via `html.theme-light` or `html[data-theme='light']` selectors

### Responsive Layout
- KPI cards use `grid-template-columns: repeat(auto-fit, minmax(240px, 1fr))`
- Wraps to multiple rows on smaller screens
- Sidebar collapses per existing theme behavior

---

## Navigation

The Calibration page is accessible via the **sidebar navigation**:

**Location:** Test Engineering → Calibration

**Active Link:** The Calibration nav link has the `.active` class when on this page.

**Sidebar Code:**
```html
<li><a class="nav-link active" href="Calibration.aspx">
  <svg class="icon"><!-- Calibration sliders icon --></svg>
  <span>Calibration</span>
</a></li>
```

---

## Testing Checklist

### ✅ KPI Card Tests
- [ ] **Overdue Count** displays correctly (0 if none overdue)
- [ ] **Due Next 30 Days** shows equipment due in the next month
- [ ] **On-Time Rate** calculates as percentage (last 12 months)
- [ ] **OOT Rate** shows Out of Tolerance percentage
- [ ] **Avg Turnaround** displays average days to complete calibration
- [ ] **Status Colors** apply correctly:
  - Red for critical values (overdue > 0, on-time < 90%)
  - Amber for warning values (due soon > 5, on-time 90-95%)
  - Green for healthy values

### ✅ Data Table Tests
- [ ] **Empty State** shows friendly message when no calibration records exist
- [ ] **Data Loads** properly when records exist
- [ ] **Search** filters records across multiple columns
- [ ] **Sort** works for all options (Date, ID, Type, Status)
- [ ] **Pagination** navigates between pages correctly
- [ ] **Page Size** changes number of rows displayed

### ✅ Theme Tests
- [ ] **Dark Theme** displays glassmorphic cards with proper contrast
- [ ] **Light Theme** shows white cards with shadows
- [ ] **Theme Toggle** (top-right) switches instantly without page reload
- [ ] **Text Readability** is good in both themes

### ✅ Integration Tests
- [ ] **Sidebar User Info** displays logged-in user's name and role
- [ ] **Admin Portal Link** shows only for admin users
- [ ] **Active Navigation** highlights "Calibration" link
- [ ] **Logout Link** works correctly
- [ ] **Session Persistence** maintains user state across page loads

---

## Next Steps

### 1. Populate Calibration Data
Since this is a new implementation, you likely have **no calibration log records yet**. You need to:

**Option A: Create Calibration Entry Form**
- Build a `LogCalibration.aspx` page to add new calibration records
- Include all new KPI fields (PrevDueDate, StartDate, ResultCode, Method, etc.)
- See TODO list from earlier conversation

**Option B: Manually Insert Test Data**
```sql
-- Example test record
INSERT INTO Calibration_Log 
  (EquipmentType, EquipmentID, CalibrationDate, PrevDueDate, StartDate, 
   CompletedDate, ResultCode, Method, Cost, TechnicianName)
VALUES 
  ('ATE', 1, '2025-10-01', '2025-09-30', '2025-09-28', 
   '2025-10-01', 'Pass', 'Internal', 0, 'John Doe');
```

### 2. Verify KPI View Returns Data
Run this query to test:
```sql
SELECT * FROM vw_CalibrationKPIs;
```
Should return one row with all KPI values.

### 3. Test with Real Users
- Have Test Engineering users navigate to the page
- Verify permissions work correctly
- Collect feedback on UI/UX

### 4. Add Drill-Down Links (Optional)
The KPI cards have placeholder "View all →" links. You can enhance these to:
- Filter the table to show only overdue items
- Filter to show only items due in next 30 days
- Navigate to filtered views or separate detail pages

**Example JavaScript for drill-down:**
```javascript
document.getElementById('cardOverdue').addEventListener('click', function() {
  // Set search filter to show only overdue items
  document.getElementById('txtSearch').value = 'overdue';
  __doPostBack('txtSearch', '');
});
```

---

## Troubleshooting

### Issue: KPIs show "0" or "--"
**Cause:** No data in Calibration_Log table  
**Fix:** Add test calibration records or wait for real data entry

### Issue: View not found error
**Cause:** `vw_CalibrationKPIs` view not created  
**Fix:** Run `Add_KPI_Views.sql` script in SQL Server

### Issue: Column not found errors
**Cause:** New KPI columns not added to Calibration_Log table  
**Fix:** Run `Add_KPI_Columns.sql` script in SQL Server

### Issue: Theme not switching
**Cause:** Theme toggle script not running  
**Fix:** Check Site.master has theme toggle JavaScript, verify console for errors

### Issue: Sidebar navigation not working
**Cause:** Session variables not set  
**Fix:** Ensure user is logged in via Login.aspx, check Session["TED:FullName"] exists

---

## Performance Notes

### SQL View Execution
The `vw_CalibrationKPIs` view is **NOT cached** - it runs every time the page loads. This ensures real-time data but can be slow with large datasets.

**Current Performance:**
- View uses indexed columns (`CompletedOn`, `NextCalibration`)
- Aggregations limited to last 12 months
- Expected execution time: < 200ms with 10,000+ calibration records

**If Performance Becomes an Issue:**
- Add application-level caching (5-minute cache)
- Create indexed view (materialized view)
- Add summary tables updated nightly

### Page Load Time
**Target:** < 2 seconds  
**Actual:** Depends on database size and network latency

**Optimization Tips:**
- Reduce `PageSize` default (currently 25)
- Defer loading data table until user searches
- Add lazy loading for KPI cards

---

## Known Limitations

1. **No Edit Functionality** - Table is read-only; users cannot edit calibration records from this page
2. **No Export** - No CSV/Excel export button (can be added later)
3. **No Charts** - KPIs are numeric only; could add trend charts
4. **No Notifications** - No email alerts for overdue calibrations (future enhancement)
5. **Equipment Links** - Clicking Equipment ID doesn't navigate to equipment details page

---

## Future Enhancements

### Short-Term (Next Sprint)
- [ ] Add "Log Calibration" button to create new records
- [ ] Make Equipment ID clickable (navigate to ItemDetails.aspx)
- [ ] Add equipment type filter dropdown
- [ ] Add date range filter

### Medium-Term (Next Quarter)
- [ ] Build `LogCalibration.aspx` entry form
- [ ] Add calibration reminders (email alerts for overdue items)
- [ ] Create calibration certificate upload feature
- [ ] Add trend charts (on-time rate over time, OOT rate trends)

### Long-Term (Future)
- [ ] Automated calibration scheduling
- [ ] Vendor performance dashboard
- [ ] Calibration cost tracking and budgeting
- [ ] Mobile app for calibration technicians

---

## Reference Documentation

- **KPI Design Spec:** `/Documentation/KPI_Design_Specifications.md`
- **Migration Script:** `/Database/Scripts/Add_KPI_Columns.sql`
- **Views Script:** `/Database/Scripts/Add_KPI_Views.sql`
- **Equipment Inventory (Pattern):** `EquipmentInventory.aspx` (used as design template)

---

## Support

**Questions?** Contact the development team or refer to:
- SQL Server documentation for view/column issues
- ASP.NET WebForms GridView documentation for table customization
- Test Engineering team for KPI threshold validation

**Last Updated:** October 2, 2025  
**Version:** 1.0.0  
**Author:** GitHub Copilot + User Collaboration
