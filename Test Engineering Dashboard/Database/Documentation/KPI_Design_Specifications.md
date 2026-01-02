# Test Engineering Dashboard - KPI Design Specifications
**Created:** October 2, 2025  
**Purpose:** Define KPIs, required schema changes, and SQL views for all dashboard pages

---

## 1. CALIBRATION DASHBOARD

### Top 5 KPIs
1. **Overdue Calibrations** (Count, by type)
   - Items requiring calibration with NextCalibration < TODAY
   - Red if > 0; provides immediate compliance risk visibility
   
2. **Due in Next 30 Days** (Count, by type)
   - Items with NextCalibration between TODAY and TODAY+30
   - Drives scheduling; amber when > threshold
   
3. **On-Time Calibration Rate** (%, last 12 months)
   - Percentage of calibrations completed on or before due date
   - Thresholds: Red <90%, Amber 90-95%, Green >95%
   
4. **Out-of-Tolerance Rate** (%, last 12 months)
   - Percentage of calibrations resulting in OOT/Fail
   - Thresholds: Red >5%, Amber 1-5%, Green <1%
   
5. **Average Turnaround Time** (Days, last 12 months)
   - Average days from calibration start to completion
   - Compare against internal SLA (e.g., 7 days internal, 21 days vendor)

### Required Table Changes: Calibration_Log
```sql
-- New columns needed
PrevDueDate datetime NULL           -- Due date being satisfied (for on-time calc)
StartDate datetime NULL              -- Work start date
SentOutDate datetime NULL            -- Sent to vendor date
ReceivedDate datetime NULL           -- Back from vendor date
CompletedDate datetime NULL          -- Completion date (CalibrationDate kept for back-compat)
ResultCode nvarchar(20) NULL         -- Pass/Fail/OOT/Adjusted
VendorName nvarchar(200) NULL        -- Vendor performing calibration
Method nvarchar(20) NULL             -- Internal/External

-- Computed columns (persisted)
CompletedOn AS COALESCE(CompletedDate, CalibrationDate)
IsOnTime AS CASE WHEN PrevDueDate IS NULL OR CompletedOn IS NULL THEN NULL
                 WHEN CompletedOn <= PrevDueDate THEN 1 ELSE 0 END
IsOutOfTolerance AS CASE WHEN UPPER(ResultCode) IN ('FAIL','OOT') THEN 1 ELSE 0 END
TurnaroundDays AS DATEDIFF(day, StartDate, CompletedOn)
VendorLeadDays AS DATEDIFF(day, SentOutDate, ReceivedDate)
```

### SQL View: vw_CalibrationKPIs
```sql
-- Real-time overdue and upcoming counts by type
-- On-time rate, OOT rate, avg turnaround (last 12 months)
```

---

## 2. TEST COMPUTERS DASHBOARD

### Top 5 KPIs
1. **Total Computers by Status** (Count)
   - In Use / Available / Maintenance / Retired
   - Quick health snapshot
   
2. **Computers with Open IT Tasks** (Count)
   - Computers with non-null ITTask field
   - Drives IT workload visibility
   
3. **Computers with Open Test Eng Tasks** (Count)
   - Computers with non-null TestEngTask field
   - Drives Test Eng workload visibility
   
4. **Average Age of Computers** (Years, In Use only)
   - AVG(DATEDIFF(year, ComputerDate, GETDATE()))
   - Highlights refresh/EOL planning needs
   
5. **Computers by Test Station** (Count, top 5)
   - Distribution across test stations
   - Identifies capacity and coverage gaps

### Required Table Changes: Computer_Inventory
```sql
-- New columns needed
HasOpenITTask bit DEFAULT 0          -- Flag: computer has open IT tasks
HasOpenTestEngTask bit DEFAULT 0     -- Flag: computer has open Test Eng tasks
LastMaintenanceDate datetime NULL    -- Last maintenance/update
OSVersion nvarchar(100) NULL         -- Detailed OS version (detailed OS info)
PurchaseDate datetime NULL           -- Purchase date (if ComputerDate is deployment)
WarrantyExpiration datetime NULL     -- Warranty end date

-- Note: ITTask and TestEngTask remain as free-text fields (multi-line task lists)
-- Flags are manually set when tasks exist; cleared when all tasks resolved
```

### SQL View: vw_ComputerKPIs
```sql
-- Status distribution, task counts, avg age, station distribution
```

---

## 3. PREVENTIVE MAINTENANCE DASHBOARD

### **Preventive Maintenance Dashboard (Top 5)**
1. Overdue PMs (by type) - 🔴 Red if > 0
2. PM Compliance Rate (12mo) - 🔴 Red <85%, 🟢 Green >95%
3. PM Completions YTD
4. Average PM Duration - Target <60 min routine
5. Unplanned Downtime Rate (30 days) - 🔴 Red >5%, 🟢 Green <2%### Required Table Changes: PM_Log
```sql
-- New columns needed
DueDate datetime NULL                -- Original due date (for compliance calc)
ScheduledDate datetime NULL          -- When PM was scheduled
ActualStartTime datetime NULL        -- When work started
ActualEndTime datetime NULL          -- When work completed
EstimatedDuration int NULL           -- Planned duration in minutes
ActualDuration AS DATEDIFF(minute, ActualStartTime, ActualEndTime)
IsOnTime AS CASE WHEN DueDate IS NULL OR PMDate IS NULL THEN NULL
                 WHEN PMDate <= DueDate THEN 1 ELSE 0 END
Downtime int NULL                    -- Equipment downtime in minutes
```

### SQL View: vw_PMKPIs
```sql
-- Overdue count, compliance rate, YTD completions, avg cost, availability
```

---

## 4. TROUBLESHOOTING DASHBOARD

### Top 5 KPIs
1. **Open Issues by Priority** (Count)
   - Critical / High / Medium / Low
   - Immediate action prioritization
   
2. **Average Resolution Time** (Hours, last 12 months)
   - AVG(DATEDIFF(hour, ReportedDateTime, ResolvedDateTime))
   - Target: <24h for Critical, <72h for High
   
3. **Top Issue Classifications** (Count, top 5)
   - Most frequent issue types
   - Identifies systemic problems
   
4. **Repeat Issues Rate** (%)
   - Issues with same root cause within 30 days
   - Quality of solutions metric
   
5. **Issues by Equipment Type** (Count)
   - Distribution across ATE/Asset/Fixture/Harness
   - Identifies problem equipment categories

### Required Table Changes: Troubleshooting_Log
```sql
-- New columns needed
EquipmentType nvarchar(50) NULL      -- Derived: ATE/Asset/Fixture/Harness
EquipmentEatonID nvarchar(50) NULL   -- Link to primary equipment
ResolutionTimeHours AS DATEDIFF(hour, ReportedDateTime, ResolvedDateTime)
IsResolved AS CASE WHEN Status IN ('Resolved','Closed') THEN 1 ELSE 0 END
IsRepeat bit DEFAULT 0               -- Manual flag for repeat issues
DowntimeHours decimal(10,2) NULL     -- Production downtime caused
ImpactLevel nvarchar(20) NULL        -- None/Minor/Moderate/Major/Critical
```

### SQL View: vw_TroubleshootingKPIs
```sql
-- Open by priority, avg resolution time, top classifications, repeat rate
```

---

## 5. TEST STATIONS DASHBOARD

### Top 5 KPIs
1. **Equipment Count by Station** (Count, all types)
   - Total ATE, Assets, Fixtures, Harnesses, Computers per station
   - Capacity and coverage view
   
2. **Station Utilization Rate** (%)
   - Percentage of equipment "In Use" vs "Available"
   - Target: 70-90% (too high = no spares; too low = waste)
   
3. **Equipment in Maintenance** (Count per station)
   - Equipment currently in maintenance status
   - Identifies bottlenecks
   
4. **Overdue Calibrations per Station** (Count)
   - Station-level compliance risk
   - Red if > 0
   
5. **Station Downtime Events** (Count, last 30 days)
   - Troubleshooting logs linked to station equipment
   - Reliability metric

### Required Table Changes: TestStation_Bay
```sql
-- New columns needed
StationType nvarchar(50) NULL        -- Manual/Automated/Semi-Automated
Capacity int NULL                    -- Max throughput or test capacity
CurrentUtilization decimal(5,2) NULL -- Computed: equipment in use / total
IsOperational bit DEFAULT 1          -- Station operational status
LastDowntime datetime NULL           -- Last time station went down
```

### SQL View: vw_TestStationKPIs
```sql
-- Equipment counts, utilization, maintenance, overdue cals, downtime events
```

---

## 6. ADMIN DASHBOARDS

### 6A. ACCOUNT REQUESTS (Admin Portal)

#### Top 4 KPIs
1. **Pending Requests** (Count)
   - Requests with Status = 'Pending'
   - Immediate action needed
   
2. **Average Approval Time** (Hours, last 90 days)
   - Time from request to approval/rejection
   - Target: <24 hours
   
3. **Approval Rate** (%, last 90 days)
   - Approved / (Approved + Rejected)
   - Quality of screening process
   
4. **Requests by Category** (Count)
   - Distribution of requested user categories
   - Staffing trends

### Required Table Changes: AccountRequests
```sql
-- Column to add
ReviewTimeHours AS DATEDIFF(hour, SubmittedAt, ReviewedAt)  -- Computed column

-- Note: Your table already has:
-- SubmittedAt (request submission date)
-- ReviewedAt (admin review date)
-- ReviewedBy (admin who reviewed)
-- Status, Decision, AssignedAppRole, etc.
```

### 6B. USERS (Admin Portal)

#### Top 4 KPIs
1. **Active Users by Category** (Count)
   - Admin / Test Engineering / Quality / Tester / Viewer
   - Staffing distribution
   
2. **Inactive Users** (Count)
   - IsActive = 0
   - Cleanup candidates
   
3. **Users Without Recent Login** (Count, >90 days)
   - LastLoginDate < TODAY-90 or NULL
   - Security risk / license waste
   
4. **New Users This Month** (Count)
   - CreatedDate within current month
   - Growth tracking

### Required Table Changes: Users
```sql
-- No changes needed! Your table already has:
-- Department nvarchar(100)
-- JobRole nvarchar(100)
-- ModifiedDate datetime
-- ModifiedBy nvarchar(100)
-- Plus all other required fields for KPIs
```

### 6C. CHANGE LOG (Admin Portal)

#### Top 4 KPIs
1. **Changes by Table** (Count, last 30 days)
   - Activity heatmap per table
   - Audit trail overview
   
2. **Most Active Users** (Count, top 5, last 30 days)
   - Users making most changes
   - Training or oversight needs
   
3. **Change Type Distribution** (Count)
   - Created / Modified / Deleted
   - Activity pattern insights
   
4. **Busiest Tables** (Count, last 7 days)
   - Tables with most change activity
   - Identifies focus areas

### Required Table Changes: Change_Log
```sql
-- No changes needed; current schema is sufficient
-- Existing indexes support all queries
```

### SQL View: vw_AdminKPIs
```sql
-- Pending requests, avg approval time, active users, change activity
```

---

## SUMMARY OF REQUIRED MIGRATIONS

### Priority 1 (Critical for KPIs)
- **Calibration_Log:** 11 new columns + 5 computed columns
- **PM_Log:** 7 new columns + 2 computed columns
- **Troubleshooting_Log:** 5 new columns + 2 computed columns

### Priority 2 (Nice to have)
- **Computer_Inventory:** 4 new columns (flags + metadata)
- **TestStation_Bay:** 5 new columns
- **AccountRequests:** 1 computed column only (table already has needed fields)
- **Users:** No changes needed (table already complete)

### Views to Create (8 total)
1. vw_CalibrationKPIs
2. vw_ComputerKPIs
3. vw_PMKPIs
4. vw_TroubleshootingKPIs
5. vw_TestStationKPIs
6. vw_AccountRequestKPIs
7. vw_UserKPIs
8. vw_ChangeLogKPIs

---

## IMPLEMENTATION NOTES

### KPI Calculation Strategy
- **Real-time queries:** Overdue counts, pending requests (low row counts)
- **Cached views:** Historical metrics, aggregations (refresh daily/hourly)
- **Application-side:** Complex business logic, multi-source joins

### Performance Considerations
- All date-based filters use indexed columns
- Computed columns persisted for instant access
- Views use NOEXPAND hint on indexed views where applicable

### Thresholds and Alerts
- All thresholds configurable per facility requirements
- Red/Amber/Green bands defined in application config
- Future: Alert_Distribution_List integration for automated notifications

### Data Quality
- Nullable new columns for backward compatibility
- Default values where sensible (Method='Internal', Status='Open')
- CHECK constraints on enums for data integrity

---

## NEXT STEPS
1. Review and approve KPI selections per dashboard
2. Execute migration scripts (provided separately)
3. Create SQL views (provided separately)
4. Build dashboard UI pages with KPI cards
5. Implement data collection processes for new columns
