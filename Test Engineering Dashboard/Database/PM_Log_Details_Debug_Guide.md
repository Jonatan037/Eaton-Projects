# PM Log Details Button - Debug Instructions

## IMMEDIATE TESTING STEPS

### Step 1: Check Debug Output
1. Open your project in Visual Studio
2. Go to **View → Output** (or press `Ctrl+Alt+O`)
3. In the Output window, select **"Debug"** from the dropdown
4. Run the application (F5)
5. Navigate to `PMDetails.aspx?mode=new`
6. Click the "PM Log Details" button
7. **Look for these messages in the Output window:**

```
RedirectToFirstPMLog: Starting...
RedirectToFirstPMLog: Connection string OK, opening connection...
RedirectToFirstPMLog: Connection opened successfully
RedirectToFirstPMLog: Executing query...
RedirectToFirstPMLog: Query executed, result = <ID>
RedirectToFirstPMLog: Found PM Log ID <ID>, redirecting...
```

### Step 2: Check for Errors
If you see error messages instead, they will look like:
```
=== RedirectToFirstPMLog ERROR ===
Error Type: <TypeName>
Error Message: <Message>
Stack Trace: <Details>
=== END ERROR ===
```

### Step 3: Check Browser URL
After clicking the button, check what URL the browser shows:
- `PreventiveMaintenance.aspx` → Error occurred (check debug output)
- `PreventiveMaintenance.aspx?error=pmload` → Error occurred (check debug output)
- `PMDetails.aspx?id=X` → SUCCESS! Should work
- `PMDetails.aspx?mode=new` → No PM logs found in database

## COMMON ISSUES AND FIXES

### Issue A: "Cannot find table PM_Log"
**Debug Output Shows:**
```
Error Type: SqlException
Error Message: Invalid object name 'dbo.PM_Log'
```

**Fix:** The table doesn't exist or is in a different schema.

**Solution:**
```sql
-- Check if table exists
SELECT * FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_NAME = 'PM_Log'

-- If it exists but in different schema:
SELECT TABLE_SCHEMA, TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_NAME = 'PM_Log'

-- If table doesn't exist, create it or run migration scripts
```

### Issue B: "Connection string is null or empty"
**Debug Output Shows:**
```
RedirectToFirstPMLog: Connection string is null or empty!
```

**Fix:** Web.config is missing connection string or has wrong name.

**Solution:**
Check `Web.config` has:
```xml
<connectionStrings>
    <add name="TestEngineeringConnectionString" 
         connectionString="Data Source=YourServer;Initial Catalog=YourDB;..." 
         providerName="System.Data.SqlClient" />
</connectionStrings>
```

### Issue C: "Query executed, result = NULL"
**Debug Output Shows:**
```
RedirectToFirstPMLog: Query executed, result = NULL
RedirectToFirstPMLog: No PM logs found, redirecting to new mode
```

**Fix:** The PM_Log table is empty.

**Solution:**
```sql
-- Check if PM logs exist
SELECT * FROM dbo.PM_Log

-- If empty, create a test PM log first through the "New PM Log" page
```

### Issue D: ThreadAbortException
**Debug Output Shows:**
```
Error Type: ThreadAbortException
```

**Fix:** This is normal for Response.Redirect - I've already fixed this.

**Solution:** Already fixed in code using `Response.Redirect(url, false)` and `CompleteRequest()`.

## MANUAL DATABASE TEST

Run this query in SQL Server Management Studio or your database tool:

```sql
-- This is the EXACT query the code uses
SELECT TOP 1 PMLogID FROM dbo.PM_Log ORDER BY PMLogID DESC
```

**Expected Results:**
- **If you see a number (e.g., 1, 2, 3):** The code should work!
- **If you see "Invalid object name 'dbo.PM_Log'":** Table doesn't exist - run migration scripts
- **If you see empty result:** Table exists but no data - create a PM log first

## VERIFICATION CHECKLIST

Run through this checklist:

### Database Checks
- [ ] PM_Log table exists in database
- [ ] Table is in `dbo` schema (not a different schema)
- [ ] At least 1 row exists in PM_Log table
- [ ] PMLogID column exists and is an integer
- [ ] Current user has SELECT permission on PM_Log

### Configuration Checks
- [ ] Web.config has TestEngineeringConnectionString
- [ ] Connection string points to correct database
- [ ] Connection string credentials are valid
- [ ] Application pool identity has database access

### Code Checks
- [ ] PMDetails.aspx.cs compiled without errors
- [ ] Latest changes deployed to IIS (if using IIS)
- [ ] Application restarted after code changes
- [ ] No caching issues (try Ctrl+F5 in browser)

## QUICK SQL DIAGNOSTIC

Run all these queries and share the results:

```sql
-- 1. Check if table exists
SELECT 
    TABLE_SCHEMA,
    TABLE_NAME,
    TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_NAME = 'PM_Log'

-- 2. Check table structure
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'PM_Log' AND TABLE_SCHEMA = 'dbo'
ORDER BY ORDINAL_POSITION

-- 3. Check if data exists
SELECT COUNT(*) AS TotalPMLogs FROM dbo.PM_Log

-- 4. Check first PM log
SELECT TOP 1 
    PMLogID,
    EquipmentType,
    PMDate,
    Status
FROM dbo.PM_Log 
ORDER BY PMLogID DESC

-- 5. Check permissions (replace 'YourLoginName' with actual login)
SELECT 
    p.permission_name,
    p.state_desc,
    USER_NAME(p.grantee_principal_id) AS user_name
FROM sys.database_permissions p
WHERE OBJECT_NAME(p.major_id) = 'PM_Log'
```

## NEXT STEPS

1. **Run the application with F5**
2. **Open Output window** (View → Output, select "Debug")
3. **Click "PM Log Details" button**
4. **Copy ALL debug output messages**
5. **Send the debug output** - it will tell us exactly what's wrong

The enhanced logging will show us:
- ✅ If connection opens successfully
- ✅ If query executes
- ✅ What result is returned (ID or NULL)
- ✅ Exact error message if something fails
- ✅ Where in the process it fails

## Expected Success Output

When working correctly, you should see:
```
RedirectToFirstPMLog: Starting...
RedirectToFirstPMLog: Connection string OK, opening connection...
RedirectToFirstPMLog: Connection opened successfully
RedirectToFirstPMLog: Executing query...
RedirectToFirstPMLog: Query executed, result = 1
RedirectToFirstPMLog: Found PM Log ID 1, redirecting...
```

Then the page should navigate to `PMDetails.aspx?id=1` and show your PM log!
