# Calibration Dashboard - Quick Setup Guide

## 🚀 Quick Start (5 Minutes)

### Step 1: Run SQL Script
Execute the enhanced KPI view script in your SQL Server Management Studio:

```sql
-- File: Database/Calibration_Dashboard_Enhanced_KPIs.sql
-- This creates the vw_CalibrationKPIs view and performance indexes
-- Run time: ~5 seconds
```

**Expected output:**
```
Enhanced vw_CalibrationKPIs view created successfully!
Index IX_Calibration_Log_NextDueDate_Status created.
Index IX_Calibration_Log_CompletedOn created.
All indexes verified/created successfully!
```

### Step 2: Verify Files Are in Place
Ensure these files exist in your Test Engineering Dashboard folder:
- ✅ `CalibrationDashboard.aspx`
- ✅ `CalibrationDashboard.aspx.cs`
- ✅ `Database/Calibration_Dashboard_Enhanced_KPIs.sql`

### Step 3: Test the Dashboard
1. Open browser and navigate to: `http://your-server/CalibrationDashboard.aspx`
2. You should see:
   - 5 KPI cards at the top
   - 5 interactive charts in the middle
   - Upcoming calibrations list at the bottom
3. Verify charts load and KPIs show real data (not "0" or "--")

### Step 4: Add to Navigation (Optional)
Update your main navigation to link directly to the dashboard:

**In your Site.master or menu file:**
```html
<!-- Replace the Calibration link -->
<li><a class="nav-link" href="CalibrationDashboard.aspx">
  <svg class="icon">...</svg>
  <span>Calibration</span>
</a></li>
```

---

## 🔍 Verification Checklist

### Database Verification
Run these queries to verify your setup:

```sql
-- 1. Check if view exists and returns data
SELECT * FROM dbo.vw_CalibrationKPIs;
-- Expected: 1 row with all KPI values

-- 2. Check if indexes exist
SELECT name, type_desc 
FROM sys.indexes 
WHERE object_id = OBJECT_ID('dbo.Calibration_Log')
  AND name LIKE 'IX_Calibration_Log_%';
-- Expected: At least 2 indexes

-- 3. Check if computed columns exist
SELECT name, is_computed 
FROM sys.columns 
WHERE object_id = OBJECT_ID('dbo.Calibration_Log')
  AND is_computed = 1;
-- Expected: CompletedOn, IsOnTime, IsOutOfTolerance, TurnaroundDays, VendorLeadDays
```

### Application Verification
1. **KPIs Load:** All 5 cards show numeric values (not "--")
2. **Charts Render:** All 5 charts display without errors
3. **Upcoming List:** Shows equipment due within 90 days
4. **Theme Toggle:** Dark/Light mode switch works
5. **Responsive:** Dashboard adapts to smaller screens

---

## 🛠️ Troubleshooting Common Issues

### Issue: "Object reference not set to an instance of an object"
**Cause:** Missing controls in ASPX or code-behind mismatch  
**Fix:**
```csharp
// Add this to CalibrationDashboard.aspx.cs (top section)
protected System.Web.UI.WebControls.Literal litOverdue;
protected System.Web.UI.WebControls.Literal litDueSoon;
// ... etc for all KPI literals
protected System.Web.UI.HtmlControls.HtmlGenericControl cardOverdue;
protected System.Web.UI.HtmlControls.HtmlGenericControl cardDueSoon;
// ... etc for all KPI cards
```

### Issue: "Invalid object name 'dbo.vw_CalibrationKPIs'"
**Cause:** SQL view not created  
**Fix:** Run `Database/Calibration_Dashboard_Enhanced_KPIs.sql`

### Issue: Charts show "No Data"
**Cause:** No calibration records in last 12 months  
**Fix:** Either add test data or adjust date filter in code:
```csharp
// In CalibrationDashboard.aspx.cs, change:
WHERE CompletedOn >= DATEADD(month, -12, GETDATE())
// To:
WHERE CompletedOn >= DATEADD(month, -24, GETDATE())  -- Last 24 months
```

### Issue: Charts don't load at all (blank space)
**Cause:** Chart.js CDN blocked or JavaScript error  
**Fix:**
1. Open browser Developer Tools (F12)
2. Check Console tab for errors
3. Verify Chart.js loads: Look for `https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js` in Network tab
4. If CDN blocked, download Chart.js locally and update reference

### Issue: KPIs show "0" but data exists
**Cause:** View column name mismatch  
**Fix:** Verify view column names match code:
```csharp
// In LoadKPIs() method:
int overdue = GetInt(rdr, "OverdueCount");  // Must match view column name
```

---

## 📊 Sample Test Data

If you need to test the dashboard with sample data, run this script:

```sql
-- Insert sample calibration records for testing
-- WARNING: This adds test data to your Calibration_Log table

USE [TestEngineering];
GO

DECLARE @i INT = 1;
DECLARE @today DATE = CAST(GETDATE() AS DATE);

-- Insert 50 sample calibrations over last 12 months
WHILE @i <= 50
BEGIN
    INSERT INTO dbo.Calibration_Log (
        EquipmentType, EquipmentID, EquipmentEatonID, EquipmentName,
        CalibrationDate, CompletedDate, NextDueDate, Status,
        Method, VendorName, ResultCode, Cost,
        CalibrationBy, CreatedDate, CreatedBy
    )
    VALUES (
        CASE @i % 5 
            WHEN 0 THEN 'Oscilloscope'
            WHEN 1 THEN 'Multimeter'
            WHEN 2 THEN 'Power Supply'
            WHEN 3 THEN 'Function Generator'
            ELSE 'Spectrum Analyzer'
        END,
        'EQ-' + RIGHT('00000' + CAST(@i AS VARCHAR), 5),
        'EATON-' + RIGHT('00000' + CAST(@i AS VARCHAR), 5),
        'Test Equipment ' + CAST(@i AS VARCHAR),
        DATEADD(day, -RAND() * 365, @today),  -- Random date in last year
        DATEADD(day, -RAND() * 365, @today),
        DATEADD(day, RAND() * 365, @today),   -- Random future date
        CASE WHEN @i % 10 = 0 THEN 'Pending' ELSE 'Completed' END,
        CASE WHEN @i % 3 = 0 THEN 'External' ELSE 'Internal' END,
        CASE WHEN @i % 3 = 0 THEN 'Vendor ' + CAST((@i % 5) + 1 AS VARCHAR) ELSE NULL END,
        CASE 
            WHEN @i % 20 = 0 THEN 'Fail'
            WHEN @i % 15 = 0 THEN 'OOT'
            WHEN @i % 10 = 0 THEN 'Adjusted'
            ELSE 'Pass'
        END,
        RAND() * 500 + 50,  -- Cost between $50-$550
        'Test Engineer',
        GETDATE(),
        'System'
    );
    
    SET @i = @i + 1;
END

PRINT '50 sample calibration records inserted successfully!';
GO

-- Verify data
SELECT COUNT(*) as TotalRecords FROM dbo.Calibration_Log;
SELECT * FROM dbo.vw_CalibrationKPIs;
```

---

## 🎨 Customization Quick Reference

### Change KPI Card Order
Edit the KPI grid section in `CalibrationDashboard.aspx` - reorder the `<div class="kpi-card">` blocks.

### Change Chart Types
In the Chart.js configuration (JavaScript section):
```javascript
// Change line chart to bar chart:
type: 'bar',  // Was: 'line'

// Change doughnut to pie:
type: 'pie',  // Was: 'doughnut'
```

### Adjust Colors for Status
In CSS section:
```css
.kpi-card.status-red { border-left:3px solid #ef4444; }  /* Red */
.kpi-card.status-amber { border-left:3px solid #f59e0b; } /* Amber */
.kpi-card.status-green { border-left:3px solid #10b981; } /* Green */
```

### Change Time Windows
In code-behind queries:
```csharp
// Change from 12 months to 6 months:
WHERE CompletedOn >= DATEADD(month, -6, GETDATE())  // Was: -12

// Change upcoming window from 90 to 60 days:
WHERE NextDueDate <= DATEADD(day, 60, CAST(GETDATE() AS date))  // Was: 90
```

---

## 📱 Mobile Responsiveness

The dashboard is responsive but optimized for desktop viewing. For best mobile experience:
- Rotate device to landscape
- KPI grid collapses to 2 columns on tablets
- Charts stack vertically on mobile
- Sidebar auto-collapses on small screens (if implemented)

**Breakpoints:**
- Desktop: 1440px+ (5 KPI columns, 2 chart columns)
- Laptop: 1024-1439px (3 KPI columns, 2 chart columns)
- Tablet: 768-1023px (2 KPI columns, 1 chart column)
- Mobile: <768px (2 KPI columns, 1 chart column)

---

## 🔐 Security Notes

### Required Permissions
Users accessing the dashboard need:
- **Database:** SELECT permission on `Calibration_Log` table and `vw_CalibrationKPIs` view
- **Application:** Valid TED session (authenticated user)

### Data Privacy
- Dashboard displays aggregated metrics only (no PII)
- Equipment IDs are business identifiers, not personal data
- Costs are aggregated, not individual line items

### Admin Access
Admin-only features are controlled via session variables:
```csharp
var cat = (Session["TED:UserCategory"] as string ?? "").ToLowerInvariant();
bool isAdmin = cat.Contains("admin");
```

---

## 📈 Performance Benchmarks

**Target Performance (50,000 calibration records):**
- Page load: < 1 second
- Chart render: < 200ms
- KPI calculation: < 100ms
- Upcoming list: < 50ms

**Optimization Tips:**
1. Run SQL index maintenance monthly
2. Archive records older than 2 years
3. Consider caching KPI view results (5-minute cache)
4. Implement lazy loading for charts (load on scroll)

---

## ✅ Deployment Checklist

Before deploying to production:

- [ ] SQL script executed successfully
- [ ] Indexes created and verified
- [ ] Dashboard loads without errors in test environment
- [ ] All 5 KPIs display real data
- [ ] All 5 charts render correctly
- [ ] Upcoming calibrations list populates
- [ ] Dark/Light theme toggle works
- [ ] Responsive layout tested on tablet
- [ ] Connection string points to production database
- [ ] User permissions configured
- [ ] Navigation links updated
- [ ] Documentation reviewed by team
- [ ] Performance tested with production data volume
- [ ] Browser compatibility verified (Chrome, Edge, Firefox, Safari)
- [ ] Backup of database taken before deployment

---

## 📞 Support

**Questions or Issues?**
1. Check `CALIBRATION_DASHBOARD_README.md` for detailed documentation
2. Review `KPI_Design_Specifications.md` for KPI definitions
3. Contact Test Engineering Dashboard team

**Quick Links:**
- Main Documentation: `CALIBRATION_DASHBOARD_README.md`
- SQL Schema: `Database/Calibration_Dashboard_SQL_Implementation.sql`
- Enhanced KPIs: `Database/Calibration_Dashboard_Enhanced_KPIs.sql`
- KPI Specs: `Database/Documentation/KPI_Design_Specifications.md`

---

**Dashboard Version:** 1.0.0  
**Last Updated:** October 24, 2025  
**Next Review:** January 2026
