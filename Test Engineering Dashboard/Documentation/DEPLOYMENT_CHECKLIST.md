# Deployment Checklist - Local File System Storage

## 📋 Pre-Deployment Checklist

### 1. Files to Deploy
Copy these files from Codespace to IIS server (`c:\_WebApps\Test Engineering Dashboard\`):

- [ ] `App_Code/LocalFileSystemService.cs` (NEW FILE)
- [ ] `CreateNewItem.aspx.cs` (MODIFIED)
- [ ] `Web.config` (MODIFIED)

### 2. Optional Documentation Files
Copy to `Documentation/` folder:

- [ ] `Documentation/LOCAL_STORAGE_SUMMARY.md`
- [ ] `Documentation/LOCAL_STORAGE_IMPLEMENTATION.md`
- [ ] `Documentation/LOCAL_STORAGE_VISUAL_GUIDE.md`
- [ ] `Documentation/FOLDER_CREATION_IMPLEMENTATION_GUIDE.md`

### 3. Files to Delete (Optional)
These SharePoint files are no longer needed:

- [ ] `App_Code/SharePointService.cs` (Not used anymore)
- [ ] `Documentation/SHAREPOINT_TROUBLESHOOTING.md` (Not relevant)

---

## 🚀 Deployment Steps

### Step 1: Backup Current Files
```cmd
cd c:\_WebApps\Test Engineering Dashboard

REM Create backup folder with timestamp
mkdir Backup_%date:~-4%%date:~-10,2%%date:~-7,2%

REM Backup files you're about to replace
copy CreateNewItem.aspx.cs Backup_%date:~-4%%date:~-10,2%%date:~-7,2%\
copy Web.config Backup_%date:~-4%%date:~-10,2%%date:~-7,2%\
```

### Step 2: Deploy New Files
1. **Copy** `LocalFileSystemService.cs` to `App_Code/` folder
2. **Replace** `CreateNewItem.aspx.cs` with new version
3. **Replace** `Web.config` with new version

### Step 3: Verify Web.config
Open `Web.config` and verify this setting exists:
```xml
<appSettings>
  <add key="LocalStorage.BasePath" value="~/Storage" />
  <!-- Other settings -->
</appSettings>
```

**Optional**: Change to absolute path if preferred:
```xml
<add key="LocalStorage.BasePath" value="D:\TEDStorage" />
```

### Step 4: Set Folder Permissions
1. Determine your Application Pool name:
   - Open **IIS Manager**
   - Find "Test Engineering Dashboard" site
   - Note the Application Pool (e.g., "TestEngineeringDashboard")

2. Create Storage folder (if using `~/Storage`):
   ```cmd
   cd c:\_WebApps\Test Engineering Dashboard
   mkdir Storage
   ```

3. Set permissions:
   - Right-click **Storage** folder
   - Properties → Security → Edit
   - Add → Enter: `IIS APPPOOL\TestEngineeringDashboard` (use your pool name)
   - Check **Full Control**
   - Click OK

### Step 5: Restart Application
Choose one method:

**Method A: Recycle Application Pool**
1. Open IIS Manager
2. Application Pools
3. Find your pool → Right-click → Recycle

**Method B: Touch Web.config**
```cmd
cd c:\_WebApps\Test Engineering Dashboard
echo. >> Web.config
```

**Method C: Restart IIS (if needed)**
```cmd
iisreset
```

---

## ✅ Post-Deployment Testing

### Test 1: Create ATE Equipment
1. Navigate to **Create New Item**
2. Select **ATE** from dropdown
3. Fill in required fields:
   - Location: `9PXM - Switch Line - Cable Scan`
   - Model Number: `TestSystem3000`
   - Serial Number: `TEST-001`
   - Status: `Active`
4. Click **Submit**
5. **Expected Result**: Green banner saying "ATE item created successfully. Document folder created."
6. **Verify Folder**:
   - Navigate to: `C:\WebApps\Test Engineering Dashboard\Storage\Equipment Inventory\ATE\`
   - Should see folder: `YPO-ATE-9PXM-001/` (or next available number)

### Test 2: Create Asset Equipment
1. Navigate to **Create New Item**
2. Select **Asset** from dropdown
3. Fill in required fields:
   - Device Type: `Digital Multimeter`
   - Model Number: `Fluke 87V`
   - Serial Number: `DMM-12345`
   - Location: `Test Lab`
4. Click **Submit**
5. **Expected Result**: Green banner saying "Asset item created successfully. Document folder created."
6. **Verify Folder**:
   - Navigate to: `C:\WebApps\Test Engineering Dashboard\Storage\Equipment Inventory\Asset\`
   - Should see folder: `YPO-AST-DMM-001/` (or next available number)

### Test 3: Create Fixture Equipment
1. Navigate to **Create New Item**
2. Select **Fixture** from dropdown
3. Fill in required fields
4. Click **Submit**
5. **Expected Result**: Green banner saying "Fixture item created successfully. Document folder created."
6. **Verify Folder** created under `Equipment Inventory/Fixture/`

### Test 4: Create Harness Equipment
1. Navigate to **Create New Item**
2. Select **Harness** from dropdown
3. Fill in required fields
4. Click **Submit**
5. **Expected Result**: Green banner saying "Harness item created successfully. Document folder created."
6. **Verify Folder** created under `Equipment Inventory/Harness/`

### Test 5: Check Logs
1. Open: `C:\WebApps\Test Engineering Dashboard\App_Data\FileSystemLog.txt`
2. Should see entries like:
   ```
   2025-10-20 15:30:45 - Created equipment folder: C:\WebApps\Test Engineering Dashboard\Storage\Equipment Inventory\ATE\YPO-ATE-9PXM-001
   ```

---

## ❌ Troubleshooting

### Issue: Banner shows "Folder creation failed: Access denied"
**Cause**: IIS Application Pool doesn't have permissions on Storage folder

**Solution**:
1. Check Application Pool identity:
   ```cmd
   %windir%\system32\inetsrv\appcmd list apppool "TestEngineeringDashboard" /text:processModel.identityType
   ```
2. Grant Full Control to `IIS APPPOOL\[PoolName]` on Storage folder
3. Recycle Application Pool

### Issue: Banner shows "Folder creation failed: Could not find a part of the path"
**Cause**: Base path in Web.config is incorrect

**Solution**:
1. Check `Web.config`: `<add key="LocalStorage.BasePath" value="~/Storage" />`
2. Verify path exists:
   ```cmd
   cd c:\_WebApps\Test Engineering Dashboard
   dir Storage
   ```
3. If doesn't exist, create it:
   ```cmd
   mkdir Storage
   ```

### Issue: No banner appears
**Cause**: JavaScript error or page didn't reload properly

**Solution**:
1. Press F12 → Console tab
2. Check for JavaScript errors
3. Clear browser cache (Ctrl+F5)
4. Try different browser

### Issue: Compilation error on page load
**Cause**: `LocalFileSystemService.cs` not copied to App_Code

**Solution**:
1. Verify file exists: `App_Code\LocalFileSystemService.cs`
2. Check file isn't marked as Read-Only
3. Recycle Application Pool
4. Check IIS logs: `C:\inetpub\logs\LogFiles\`

### Issue: Folder created but banner shows warning
**Cause**: Success but couldn't log or minor issue

**Solution**:
1. Check if folder actually exists
2. If yes, this is just a logging issue - folder creation worked
3. Check `FileSystemLog.txt` for more details

---

## 🔍 Verification Commands

### Check if Storage folder exists
```cmd
dir "c:\_WebApps\Test Engineering Dashboard\Storage" /s
```

### Check folder permissions
```cmd
icacls "c:\_WebApps\Test Engineering Dashboard\Storage"
```
Should show `IIS APPPOOL\TestEngineeringDashboard:(OI)(CI)(F)` (Full Control)

### Check Application Pool
```cmd
%windir%\system32\inetsrv\appcmd list apppool
```

### View recent logs
```cmd
type "c:\_WebApps\Test Engineering Dashboard\App_Data\FileSystemLog.txt"
```

### Count folders created
```cmd
dir "c:\_WebApps\Test Engineering Dashboard\Storage\Equipment Inventory" /s /b | find /c "\"
```

---

## 📊 Success Criteria

Deployment is successful when:

- [x] No compilation errors when browsing any page
- [x] Creating ATE equipment shows green "Document folder created" banner
- [x] Creating Asset equipment shows green "Document folder created" banner
- [x] Creating Fixture equipment shows green "Document folder created" banner
- [x] Creating Harness equipment shows green "Document folder created" banner
- [x] Folder structure created correctly under `Storage/Equipment Inventory/`
- [x] `FileSystemLog.txt` contains folder creation entries
- [x] No errors in IIS logs
- [x] No JavaScript errors in browser console

---

## 📅 Rollback Procedure (If Needed)

If something goes wrong and you need to roll back:

1. **Stop making new equipment records** (to avoid data inconsistency)

2. **Restore backup files**:
   ```cmd
   cd c:\_WebApps\Test Engineering Dashboard
   copy Backup_%date:~-4%%date:~-10,2%%date:~-7,2%\CreateNewItem.aspx.cs CreateNewItem.aspx.cs /Y
   copy Backup_%date:~-4%%date:~-10,2%%date:~-7,2%\Web.config Web.config /Y
   del App_Code\LocalFileSystemService.cs
   ```

3. **Recycle Application Pool**

4. **Test** - Create equipment should work without folder creation

5. **Review logs** - Check what went wrong before re-attempting deployment

---

## 📞 Support Resources

**Log Files**:
- Application logs: `App_Data\FileSystemLog.txt`
- IIS logs: `C:\inetpub\logs\LogFiles\W3SVC1\`
- Event Viewer: Windows Logs → Application

**Documentation**:
- `Documentation\LOCAL_STORAGE_SUMMARY.md` - Quick overview
- `Documentation\LOCAL_STORAGE_IMPLEMENTATION.md` - Full technical docs
- `Documentation\LOCAL_STORAGE_VISUAL_GUIDE.md` - Folder structure diagrams

**Common IIS Commands**:
```cmd
REM List all sites
%windir%\system32\inetsrv\appcmd list site

REM List all app pools
%windir%\system32\inetsrv\appcmd list apppool

REM Recycle specific app pool
%windir%\system32\inetsrv\appcmd recycle apppool "TestEngineeringDashboard"

REM Restart IIS (requires admin)
iisreset
```

---

## ✨ Next Phase

After successful deployment and testing of Equipment folders, proceed to implement:

1. **Calibration folder creation** - See `FOLDER_CREATION_IMPLEMENTATION_GUIDE.md`
2. **PM folder creation** - See `FOLDER_CREATION_IMPLEMENTATION_GUIDE.md`
3. **Troubleshooting folder creation** - See `FOLDER_CREATION_IMPLEMENTATION_GUIDE.md`

Each can be implemented and tested independently.

---

*Deployment checklist created: October 20, 2025*
*Target: Test Engineering Dashboard on IIS*
