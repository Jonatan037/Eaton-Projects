# SharePoint Integration Setup Guide

## Overview
The Test Engineering Dashboard now integrates with SharePoint Online to automatically create folders for new equipment items in the Equipment Inventory.

## Features
- ✅ Automatically creates folders when new equipment is added
- ✅ Organizes folders by equipment type (ATE, Asset, Fixture, Harness)
- ✅ Folder names match Eaton IDs (e.g., YPO-ATE-SPD-001)
- ✅ Graceful error handling with logging
- ✅ Can be enabled/disabled via configuration

## Setup Instructions

### 1. Install Required NuGet Package

The SharePoint integration requires the `Newtonsoft.Json` library for JSON parsing.

**Option A: Using Visual Studio**
1. Open the solution in Visual Studio
2. Right-click on the "Test Engineering Dashboard" project
3. Select "Manage NuGet Packages"
4. Search for "Newtonsoft.Json"
5. Install version 13.0.3 or later

**Option B: Using Package Manager Console**
```powershell
Install-Package Newtonsoft.Json -Version 13.0.3
```

**Option C: Manual Installation**
1. Download Newtonsoft.Json.dll from NuGet.org
2. Copy to `/bin` folder of the Test Engineering Dashboard
3. Add reference in project

### 2. Configuration (Already Done)

The following settings have been added to `Web.config`:

```xml
<appSettings>
  <!-- SharePoint Integration Settings -->
  <add key="SharePoint.TenantId" value="YOUR_TENANT_ID" />
  <add key="SharePoint.ClientId" value="YOUR_CLIENT_ID" />
  <add key="SharePoint.ClientSecret" value="YOUR_CLIENT_SECRET" />
  <add key="SharePoint.Username" value="YOUR_USERNAME" />
  <add key="SharePoint.Password" value="YOUR_PASSWORD" />
  <add key="SharePoint.SiteUrl" value="https://yourtenant.sharepoint.com/sites/YourSite" />
  <add key="SharePoint.EquipmentInventoryPath" value="Shared Documents/Path/To/Equipment" />
  <add key="SharePoint.Enabled" value="true" />
</appSettings>
```

### 3. Azure AD App Permissions (Pending)

**Current Status**: Waiting for admin consent approval

**Required Permissions**:
- `Sites.ReadWrite.All` (Delegated)
- `Files.ReadWrite.All` (Delegated)

**If admin consent is delayed**, the integration will work with the stored credentials using Resource Owner Password Credentials (ROPC) flow.

### 4. SharePoint Folder Structure

The integration expects this folder structure in SharePoint:

```
Equipment Inventory/
├── ATE/
│   ├── YPO-ATE-SPD-001/
│   ├── YPO-ATE-SPD-002/
│   └── ...
├── Asset/
│   ├── YPO-AST-DMM-001/
│   ├── YPO-AST-OSC-002/
│   └── ...
├── Fixture/
│   ├── YPO-FIX-SPD-001/
│   └── ...
└── Harness/
    ├── YPO-HAR-MOD1-001/
    └── ...
```

## How It Works

1. User creates new equipment in CreateNewItem page
2. Equipment is saved to database with auto-generated Eaton ID
3. SharePointService.CreateEquipmentFolder() is called
4. Service authenticates with Microsoft Graph API
5. Folder is created in appropriate subfolder (ATE, Asset, Fixture, or Harness)
6. Success/failure message is shown to user
7. All actions are logged to `App_Data/SharePointLog.txt`

## Logging

Logs are written to two locations:
- **File**: `App_Data/SharePointLog.txt`
- **Debug**: Visual Studio Debug Output window

Log entries include:
- Timestamp
- Success/failure status
- Folder paths
- Error messages (if any)

## Troubleshooting

### "SharePoint integration is disabled"
- Check that `SharePoint.Enabled` is set to `true` in Web.config

### "Failed to obtain access token"
- Verify credentials in Web.config are correct
- Check that Azure AD app has proper permissions
- Ensure network can reach `login.microsoftonline.com`

### "Failed to get SharePoint site ID"
- Verify `SharePoint.SiteUrl` is correct
- Ensure user has access to the SharePoint site
- Check that site URL doesn't have trailing slash

### "Failed to create SharePoint folder"
- Verify folder path in `SharePoint.EquipmentInventoryPath`
- Ensure parent folders (ATE, Asset, Fixture, Harness) exist
- Check user has write permissions on SharePoint site

### Folder already exists
- This is not an error - the service will log it and return success
- Duplicate folder names are handled gracefully

## Security Considerations

### Password Storage
- Passwords are stored in Web.config (encrypted in production)
- Consider using Azure Key Vault for production deployments
- Token caching reduces authentication requests (50-minute cache)

### Permissions
- Uses delegated permissions (user context)
- Folders created under the authenticated user's identity
- Minimal permissions requested (Sites and Files read/write)

## Disabling SharePoint Integration

To temporarily disable SharePoint integration without removing code:

1. Open `Web.config`
2. Change: `<add key="SharePoint.Enabled" value="false" />`
3. Save and restart application

Equipment can still be created; folders just won't be created in SharePoint.

## Upgrading to App-Only Authentication

Once admin consent is granted for application permissions:

1. Update Azure AD app to use application permissions
2. Remove `SharePoint.Username` and `SharePoint.Password` from Web.config
3. Update `SharePointService.GetAccessTokenAsync()` to use client credentials flow
4. Test thoroughly

## Support

For issues or questions:
- Check logs in `App_Data/SharePointLog.txt`
- Review Azure AD app permissions
- Verify SharePoint site access
- Contact Jonatan D. Arias (JonatanDArias@Eaton.com)

## Files Modified/Created

### New Files
- `App_Code/SharePointService.cs` - SharePoint integration service
- `packages.config` - NuGet package dependencies
- `SHAREPOINT_INTEGRATION_SETUP.md` - This file

### Modified Files
- `Web.config` - Added SharePoint settings
- `CreateNewItem.aspx.cs` - Added folder creation calls in:
  - CreateATEItem()
  - CreateAssetItem()
  - CreateFixtureItem()
  - CreateHarnessItem()

## Version History

- **v1.0** (January 2025) - Initial implementation with ROPC authentication
  - Auto-folder creation for all equipment types
  - Credential-based authentication
  - Comprehensive logging
  - Graceful error handling
