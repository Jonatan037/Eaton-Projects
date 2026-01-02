# Calibration Dashboard - Implementation Guide

## Overview
A modern, professional dashboard for the Test Engineering Calibration system featuring real-time KPIs, interactive charts, and upcoming calibration tracking.

**Created:** October 24, 2025  
**Files Created:**
- `CalibrationDashboard.aspx` - Main dashboard page
- `CalibrationDashboard.aspx.cs` - Code-behind logic
- `Database/Calibration_Dashboard_Enhanced_KPIs.sql` - Enhanced SQL views and indexes

---

## Features

### 📊 **5 Key Performance Indicators (KPIs)**
1. **Overdue Calibrations** - Equipment requiring immediate calibration (Red alert if > 0)
2. **Due Next 30 Days** - Equipment requiring calibration soon (Amber warning if > 5)
3. **On-Time Rate** - Percentage of calibrations completed on schedule (12-month window)
4. **Out of Tolerance** - Percentage of OOT/Fail results (12-month window)
5. **Avg Turnaround** - Average days from start to completion (12-month window)

### 📈 **5 Interactive Charts**
1. **Monthly Calibration Volume** - Line chart showing 12-month trend
2. **Equipment Type Distribution** - Doughnut chart of calibrations by equipment type
3. **Method Distribution** - Pie chart (Internal vs External calibrations)
4. **Vendor Performance** - Horizontal bar chart of vendor turnaround times
5. **Result Distribution** - Bar chart of Pass/Fail/OOT/Adjusted results

### 📅 **Upcoming Calibrations List**
- Shows next 15 calibrations due within 90 days
- Color-coded by urgency:
  - **Red:** Overdue
  - **Amber:** Due within 30 days
  - **Green:** Due 30-90 days
- Displays Equipment ID, Name, Type, and Due Date

---

## Design Principles

### Minimalist & Professional
- **Small fonts** (10-14px) for dense information display
- **Card-based layout** with subtle shadows and glassmorphism effects
- **Status-based coloring** (Red/Amber/Green) for immediate visual feedback
- **Dark/Light mode support** with theme-aware chart colors

### Responsive Grid Layout
- **5-column KPI grid** (responsive to 3 cols → 2 cols on smaller screens)
- **2-column chart grid** with flexible panels
- **Smooth scrolling** content area with custom scrollbars

### Performance Optimized
- SQL views pre-aggregate data for fast page loads
- Indexed columns for quick queries
- Chart.js for hardware-accelerated rendering
- Minimal server round-trips

---

## SQL Requirements

### 1. Run the Enhanced KPI View Script
Execute `Database/Calibration_Dashboard_Enhanced_KPIs.sql` to:
- Create/update `vw_CalibrationKPIs` with all required metrics
- Add performance indexes on `NextDueDate` and `CompletedOn`
- Optimize queries for dashboard performance

### 2. Ensure Computed Columns Exist
From the original `Calibration_Dashboard_SQL_Implementation.sql`, verify these computed columns exist in `Calibration_Log`:
- `CompletedOn` (COALESCE of CompletedDate and CalibrationDate)
- `IsOnTime` (1 if completed by due date, 0 if late)
- `IsOutOfTolerance` (1 if ResultCode is FAIL or OOT)
- `TurnaroundDays` (days from StartDate to CompletedOn)
- `VendorLeadDays` (days from SentOutDate to ReceivedDate)

### 3. Required Table Columns
The dashboard expects these fields in `Calibration_Log`:
```
CalibrationID, EquipmentType, EquipmentID, EquipmentEatonID, EquipmentName
CalibrationDate, NextDueDate, CompletedDate, CompletedOn
Status, ResultCode, Method, VendorName
Cost, TurnaroundDays, VendorLeadDays, IsOnTime, IsOutOfTolerance
CreatedDate, CreatedBy
```

---

## Navigation

### Accessing the Dashboard
- **Direct URL:** `/CalibrationDashboard.aspx`
- **From Sidebar:** Click "Calibration" in the sidebar menu
- **Quick Actions:**
  - "Full Calibration View" button → Opens `Calibration.aspx` (table view)
  - "New Calibration" button → Opens `CalibrationDetails.aspx?mode=new`

### Sidebar Menu
The dashboard uses the same sidebar as other Test Engineering pages:
- Active link highlighted with blue accent
- Admin portal link (visible only to admins)
- User profile display with initials/avatar
- Dark/Light theme toggle in top bar

---

## Chart Data Sources

All charts pull from live database queries in `CalibrationDashboard.aspx.cs`:

1. **Monthly Volume** - Groups by YEAR/MONTH of CompletedOn (last 12 months)
2. **Equipment Type** - Groups by EquipmentType (last 12 months, top 10)
3. **Method** - Groups by Method field (Internal/External/Unknown)
4. **Vendor Performance** - Top 5 vendors by AVG(VendorLeadDays) with minimum 3 calibrations
5. **Result Distribution** - Groups by ResultCode (Pass/Fail/OOT/Adjusted)

### Empty Data Handling
If no data exists for a chart, it displays "No Data" placeholder to prevent JavaScript errors.

---

## Customization Guide

### Adjusting KPI Thresholds
In `CalibrationDashboard.aspx.cs`, modify the `LoadKPIs()` method:

```csharp
// Example: Change On-Time Rate thresholds
// Current: Green >= 95%, Amber >= 90%, Red < 90%
if (onTimeRate >= 97) ApplyStatusClass(cardOnTime, 1000, 90, 95); // Green
else if (onTimeRate >= 93) ApplyStatusClass(cardOnTime, 92, 90, 95); // Amber
else ApplyStatusClass(cardOnTime, 85, 90, 95); // Red
```

### Changing Chart Colors
In `CalibrationDashboard.aspx`, edit the `<script>` section:

```javascript
const colors = {
  primary: isDark ? '#93c5fd' : '#3b82f6',  // Blue
  success: isDark ? '#6ee7b7' : '#059669',  // Green
  warning: isDark ? '#fcd34d' : '#d97706',  // Amber
  danger: isDark ? '#fca5a5' : '#dc2626',   // Red
  // Add more colors as needed
};
```

### Adjusting Upcoming Calibrations Count
In `CalibrationDashboard.aspx.cs`, change the `LoadUpcomingCalibrations()` query:

```csharp
// Change TOP 15 to desired number
SELECT TOP 20  -- Show 20 instead of 15
    EquipmentEatonID, EquipmentName, EquipmentType, NextDueDate
FROM dbo.Calibration_Log
WHERE NextDueDate <= DATEADD(day, 90, CAST(GETDATE() AS date))  // Change 90 to 60 for 60-day window
```

### Adding New KPI Cards
1. Add card markup in `CalibrationDashboard.aspx` KPI grid section
2. Add Literal control: `<asp:Literal ID="litNewKPI" runat="server" />`
3. Add HtmlGenericControl: `protected HtmlGenericControl cardNewKPI;` in code-behind
4. Populate in `LoadKPIs()` method
5. Apply status class: `ApplyStatusClass(cardNewKPI, value, amberThreshold, redThreshold);`

---

## Browser Compatibility

### Tested Browsers
- ✅ Chrome 118+ (Recommended)
- ✅ Edge 118+
- ✅ Firefox 119+
- ✅ Safari 17+

### Chart.js Version
- **Chart.js 4.4.0** loaded via CDN
- Supports modern canvas rendering
- Requires ES6+ JavaScript support

---

## Performance Notes

### Page Load Time
- **Target:** < 1 second for full dashboard load
- **Optimizations:**
  - SQL indexes on NextDueDate and CompletedOn
  - Computed columns for IsOnTime, IsOutOfTolerance, TurnaroundDays
  - Pre-aggregated views (vw_CalibrationKPIs)
  - TOP N queries for chart data (limits result sets)

### Database Impact
- All queries use indexed columns
- No table scans on large datasets
- Chart queries limited to last 12 months
- Upcoming calibrations limited to 90 days + TOP 15

---

## Troubleshooting

### Charts Not Displaying
1. **Check browser console** for JavaScript errors
2. Verify Chart.js CDN is loading: `https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js`
3. Ensure data properties are populated in code-behind (check `MonthlyLabels`, `MonthlyData`, etc.)
4. Verify SQL queries return data (check database connection)

### KPIs Show "0" or "--"
1. Verify `vw_CalibrationKPIs` view exists and returns data
2. Check connection string in `Web.config`: `TestEngineeringConnectionString`
3. Ensure `Calibration_Log` table has data with `CompletedOn` dates
4. Run SQL view query manually to test data availability

### Upcoming Calibrations Empty
1. Verify `NextDueDate` column has future dates
2. Check `Status` field is not 'Completed' or 'Cancelled' for active items
3. Ensure dates are within 90-day window

### Theme Colors Wrong
1. Verify `theme.js` is loaded in Site.master
2. Check localStorage for `tedTheme` preference
3. Ensure CSS classes `theme-light` or `data-theme='light'` are applied to `<html>` element

---

## Maintenance

### Regular Updates Needed
- **KPI thresholds** - Review quarterly to ensure they match business goals
- **Chart time windows** - Adjust from 12 months if needed (seasonal data, etc.)
- **Vendor list** - Filter out inactive vendors from performance chart
- **Equipment types** - Update colors if new types are added

### Database Maintenance
- **Rebuild indexes** monthly on `Calibration_Log` if table is large (>10k rows)
- **Archive old data** - Consider moving calibrations older than 2 years to archive table
- **Update statistics** - Run `UPDATE STATISTICS` on `Calibration_Log` weekly

---

## Future Enhancements

### Potential Features
- [ ] Export dashboard to PDF
- [ ] Email alerts for overdue calibrations
- [ ] Drill-down from KPI cards to filtered table view
- [ ] Real-time updates via SignalR
- [ ] Comparison to previous period (month-over-month, year-over-year)
- [ ] Predictive analytics (forecast upcoming workload)
- [ ] Cost analysis dashboard (budget vs. actual)
- [ ] Vendor scorecard with multiple metrics
- [ ] Equipment health score based on calibration history

---

## Support & Documentation

### Related Pages
- **Calibration.aspx** - Full table view with filters and pagination
- **CalibrationGridView.aspx** - Grid-style card view
- **CalibrationDetails.aspx** - View/edit individual calibration records

### SQL Documentation
- **KPI_Design_Specifications.md** - Detailed KPI definitions and thresholds
- **Calibration_Dashboard_SQL_Implementation.sql** - Original table schema and views
- **Calibration_Dashboard_Enhanced_KPIs.sql** - Enhanced KPI view with all metrics

### Key Technologies
- **ASP.NET Web Forms 4.x** - Server-side framework
- **Chart.js 4.4.0** - Client-side charting library
- **SQL Server 2019+** - Database engine
- **JavaScript ES6** - Client-side scripting
- **CSS Grid & Flexbox** - Responsive layout

---

## Design Inspiration

The dashboard design was inspired by modern analytics platforms with a focus on:
- **Apple-like minimalism** - Clean, uncluttered interface
- **Dribbble dashboard designs** - Card-based layouts with subtle shadows
- **Glassmorphism effects** - Frosted glass panels with backdrop blur
- **Status-driven design** - Color-coded for instant decision-making
- **Dense data display** - Maximum information in minimum space

Color palette based on Tailwind CSS default colors with custom dark mode adjustments.

---

## License & Credits

**Created for:** Eaton YPO Test Engineering Team  
**Author:** Test Engineering Dashboard Team  
**Date:** October 24, 2025  
**Version:** 1.0.0

---

**Need Help?**  
Contact the Test Engineering team or check the `Documentation/` folder for additional resources.
