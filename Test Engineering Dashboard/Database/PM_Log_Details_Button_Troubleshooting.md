# PM Log Details Button - Troubleshooting Guide

## Expected Behavior

When clicking the "PM Log Details" button from the "New PM Log" page:
1. Button should navigate to `PMDetails.aspx?action=viewFirst`
2. Page_Load detects `action=viewFirst` parameter
3. `RedirectToFirstPMLog()` method is called
4. Method queries for most recent PM log (ORDER BY PMLogID DESC)
5. If PM log found → redirects to `PMDetails.aspx?id={PMLogID}`
6. If no PM logs exist → redirects back to `PMDetails.aspx?mode=new`
7. If error occurs → redirects to `PMDetails.aspx?mode=new` (fallback)

## Code Implementation

### Frontend (PMDetails.aspx - Line 366-372)
```html
<%
    string detailsHref = "PMDetails.aspx?action=viewFirst";
    if (!string.IsNullOrEmpty(Request.QueryString["id"]))
    {
        detailsHref = "javascript:void(0);";
    }
%>
<a href="<%= detailsHref %>" ...>
```

**Logic:**
- When in "new" mode (no `id` parameter) → href is `PMDetails.aspx?action=viewFirst`
- When viewing a PM log (has `id` parameter) → href is disabled (`javascript:void(0);`)

### Backend (PMDetails.aspx.cs)

#### Page_Load (Lines 60-66)
```csharp
if (!IsPostBack)
{
    // Handle action=viewFirst - redirect to first available PM log
    if (Request.QueryString["action"] == "viewFirst")
    {
        RedirectToFirstPMLog();
        return;
    }
    // ... rest of page load
}
```

#### RedirectToFirstPMLog() Method (Lines 184-221)
```csharp
private void RedirectToFirstPMLog()
{
    try
    {
        var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
        using (var conn = new SqlConnection(cs))
        using (var cmd = new SqlCommand("SELECT TOP 1 PMLogID FROM dbo.PM_Log ORDER BY PMLogID DESC", conn))
        {
            conn.Open();
            var result = cmd.ExecuteScalar();
            if (result != null)
            {
                int firstPMLogID = Convert.ToInt32(result);
                System.Diagnostics.Debug.WriteLine("RedirectToFirstPMLog: Redirecting to PM Log ID " + firstPMLogID);
                Response.Redirect(string.Format("PMDetails.aspx?id={0}", firstPMLogID));
            }
            else
            {
                // No PM logs exist, redirect to new mode
                System.Diagnostics.Debug.WriteLine("RedirectToFirstPMLog: No PM logs found, redirecting to new mode");
                Response.Redirect("PMDetails.aspx?mode=new");
            }
        }
    }
    catch (Exception ex)
    {
        System.Diagnostics.Debug.WriteLine("RedirectToFirstPMLog error: " + ex.Message);
        System.Diagnostics.Debug.WriteLine("RedirectToFirstPMLog stack trace: " + ex.StackTrace);
        
        // Try to redirect to new mode instead of dashboard if there's an error
        try
        {
            Response.Redirect("PMDetails.aspx?mode=new");
        }
        catch
        {
            // If redirect fails, go to dashboard as last resort
            Response.Redirect("PreventiveMaintenance.aspx");
        }
    }
}
```

## Enhanced Error Handling

The updated code includes:
1. **Debug logging** - Writes to Debug output when redirecting
2. **Better error handling** - Tries to stay on PMDetails.aspx even on error
3. **Fallback logic** - Only goes to dashboard as absolute last resort

## Troubleshooting Steps

### 1. Check if PM Logs Exist
Run this query in your database:
```sql
SELECT TOP 1 PMLogID FROM dbo.PM_Log ORDER BY PMLogID DESC
```

**Expected Results:**
- If PM logs exist → should return a PMLogID number
- If no PM logs → should return no rows (empty result)

### 2. Enable Debug Output
In Visual Studio:
1. Go to **View → Output**
2. Select "Debug" from the "Show output from:" dropdown
3. Run the application
4. Click "PM Log Details" button
5. Check Output window for debug messages:
   - `RedirectToFirstPMLog: Redirecting to PM Log ID X` - Success
   - `RedirectToFirstPMLog: No PM logs found, redirecting to new mode` - No data
   - `RedirectToFirstPMLog error: ...` - Database error

### 3. Check Database Connection
Verify connection string in `Web.config`:
```xml
<connectionStrings>
    <add name="TestEngineeringConnectionString" 
         connectionString="..." 
         providerName="System.Data.SqlClient" />
</connectionStrings>
```

### 4. Verify Table Exists
```sql
SELECT * FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_NAME = 'PM_Log' AND TABLE_SCHEMA = 'dbo'
```

Should return one row if table exists.

### 5. Check Permissions
Verify the database user has SELECT permission on PM_Log:
```sql
SELECT permission_name, state_desc
FROM sys.database_permissions dp
JOIN sys.database_principals u ON dp.grantee_principal_id = u.principal_id
WHERE u.name = 'YourDatabaseUser' AND OBJECT_NAME(dp.major_id) = 'PM_Log'
```

## Common Issues and Solutions

### Issue 1: "Still redirects to dashboard"
**Possible Causes:**
- PM_Log table doesn't exist yet
- Connection string is incorrect
- Database permissions issue

**Solution:**
- Execute the SQL scripts first:
  1. `Add_PMEstimatedTime_To_Equipment_Tables.sql`
  2. `Add_PM_Log_Additional_Columns.sql`
  3. `Create_vw_Equipment_RequirePM.sql`
- Verify PM_Log table exists
- Create at least one test PM log

### Issue 2: "Button doesn't do anything"
**Possible Causes:**
- JavaScript error on page
- Link is disabled

**Solution:**
- Open browser Developer Tools (F12)
- Check Console for JavaScript errors
- Verify the link href is `PMDetails.aspx?action=viewFirst` (not `javascript:void(0);`)

### Issue 3: "Gets error on page"
**Possible Causes:**
- Column doesn't exist in PM_Log table
- SQL syntax error

**Solution:**
- Run all migration scripts
- Verify PM_Log table has all required columns:
  ```sql
  SELECT COLUMN_NAME, DATA_TYPE 
  FROM INFORMATION_SCHEMA.COLUMNS 
  WHERE TABLE_NAME = 'PM_Log' AND TABLE_SCHEMA = 'dbo'
  ORDER BY ORDINAL_POSITION
  ```

## Expected Database Schema

PM_Log table should have these columns after running migration scripts:
- PMLogID (int, PK, Identity)
- EquipmentType (nvarchar)
- EquipmentID (int)
- ScheduledDate (datetime) ← NEW
- PMDate (datetime)
- NextPMDate (datetime)
- PMType (nvarchar)
- MaintenancePerformed (nvarchar(max))
- PerformedBy (nvarchar)
- PartsReplaced (nvarchar(max))
- Cost (decimal)
- Status (nvarchar)
- Comments (nvarchar(max))
- CreatedBy (nvarchar)
- CreatedDate (datetime)
- AttachmentsPath (nvarchar(max))
- ActualStartTime (datetime) ← NEW
- ActualEndTime (datetime) ← NEW
- Downtime (decimal) ← NEW

## Testing Procedure

1. **Navigate to New PM Log page:**
   - URL: `PMDetails.aspx?mode=new`
   - Verify you see "New PM Log" title

2. **Click "PM Log Details" button in sidebar**

3. **Expected Result:**
   - If PM logs exist: Should navigate to most recent PM log (e.g., `PMDetails.aspx?id=5`)
   - If no PM logs: Should stay on `PMDetails.aspx?mode=new`
   - Should NOT redirect to `PreventiveMaintenance.aspx`

4. **Verify Debug Output:**
   - Check Visual Studio Output window for debug messages
   - Should see redirect confirmation or error details

## Quick Fix Checklist

- [ ] SQL migration scripts executed?
- [ ] PM_Log table exists in database?
- [ ] At least one PM log record exists for testing?
- [ ] Connection string is correct in Web.config?
- [ ] User has SELECT permission on PM_Log?
- [ ] Page compiles without errors?
- [ ] Browser console shows no JavaScript errors?
- [ ] Debug output shows redirect message?

## If Still Not Working

Check the browser URL after clicking the button:
- If URL changes to `PMDetails.aspx?action=viewFirst` → Backend redirect is working
- If URL stays at `PMDetails.aspx?mode=new` → Link not navigating (JavaScript issue)
- If URL changes to `PreventiveMaintenance.aspx` → Exception in RedirectToFirstPMLog()

Contact developer with:
1. URL after clicking button
2. Debug output messages
3. Any error messages shown on page
4. Result of `SELECT TOP 1 PMLogID FROM dbo.PM_Log ORDER BY PMLogID DESC`
