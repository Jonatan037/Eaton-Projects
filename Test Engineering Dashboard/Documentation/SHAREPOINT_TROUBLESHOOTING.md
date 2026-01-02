# SharePoint Integration Troubleshooting Guide

## Current Issue: Authentication Failure

**Error Message**: "Failed to obtain access token - check credentials"

## Root Cause Analysis

The authentication is failing because of one or more of these issues:

### 1. Multi-Factor Authentication (MFA) Enabled
- **Problem**: ROPC (Resource Owner Password Credentials) flow doesn't support MFA
- **Symptom**: Authentication fails with error code `AADSTS50076`
- **Solution**: Use Client Credentials flow instead (implemented in latest code)

### 2. ROPC Flow Disabled by Policy
- **Problem**: Many organizations disable ROPC for security reasons
- **Symptom**: Error code `AADSTS700016` or similar
- **Solution**: Use Client Credentials flow (app-only authentication)

### 3. Missing Application Permissions
- **Problem**: Azure AD app doesn't have required permissions
- **Symptom**: Authentication succeeds but API calls fail with 403 Forbidden
- **Required Permissions**:
  - `Sites.ReadWrite.All` (Application permission for Client Credentials)
  - `Files.ReadWrite.All` (Application permission)

### 4. Admin Consent Not Granted
- **Problem**: Application permissions require admin approval
- **Symptom**: Error code `AADSTS65001`
- **Solution**: Azure AD admin must grant consent

## Solution Implemented

The code now tries **two authentication methods** in order:

1. **Client Credentials Flow** (Recommended)
   - Uses only ClientId and ClientSecret
   - Works without user credentials
   - Requires `Sites.ReadWrite.All` application permission
   - Not affected by MFA or user account issues

2. **ROPC Flow** (Fallback)
   - Uses username and password
   - Falls back if Client Credentials fails
   - May fail if MFA is enabled

## Steps to Fix Azure AD App Configuration

### Step 1: Add Application Permissions

1. Go to **Azure Portal** → **Azure Active Directory** → **App registrations**
2. Find your app: `Test Engineering Dashboard SharePoint` (ClientId: `d139f7b8-5e93-4fcc-b184-45e579c980f9`)
3. Click **API permissions** → **Add a permission**
4. Select **Microsoft Graph** → **Application permissions**
5. Add these permissions:
   - `Sites.ReadWrite.All`
   - `Files.ReadWrite.All`
6. Click **Grant admin consent for Eaton** (requires Global Admin)

### Step 2: Verify App Registration Settings

**Authentication Tab**:
- Allow public client flows: **Yes** (for ROPC fallback)
- Supported account types: **Accounts in this organizational directory only**

**Certificates & secrets Tab**:
- Ensure Client Secret is valid and matches Web.config value
- Check expiration date

### Step 3: Test Authentication

After deploying the updated code:

1. Deploy `SharePointService.cs` to your IIS server
2. Recycle the Application Pool or restart IIS
3. Try creating a new equipment item
4. Check the error message in the banner

**Expected Results**:
- ✅ **Success**: "Equipment folder created successfully on SharePoint"
- ❌ **Client Credentials Failed**: Message will show specific Azure AD error
- ❌ **ROPC Failed**: Message will show "Azure AD Authentication Failed - Error: [code]"

## Common Azure AD Error Codes

| Error Code | Description | Solution |
|------------|-------------|----------|
| `AADSTS50126` | Invalid username or password | Verify credentials in Web.config |
| `AADSTS50076` | MFA required | Use Client Credentials flow (already implemented) |
| `AADSTS700016` | ROPC not supported | Use Client Credentials flow (already implemented) |
| `AADSTS65001` | Admin consent required | Admin must grant consent in Azure Portal |
| `AADSTS50053` | Account locked | Unlock user account in Azure AD |
| `AADSTS700016` | App not configured for ROPC | Enable public client flows in app registration |

## Log File Location

**Local IIS Server**: `c:\_WebApps\Test Engineering Dashboard\App_Data\SharePointLog.txt`

This file contains detailed authentication attempts and API calls.

## Testing Checklist

- [ ] Updated `SharePointService.cs` deployed to IIS
- [ ] Application Pool recycled
- [ ] Azure AD app has `Sites.ReadWrite.All` permission
- [ ] Admin consent granted for application permissions
- [ ] Client Secret is valid and not expired
- [ ] Created test equipment item
- [ ] Checked banner message for specific error details
- [ ] Reviewed SharePointLog.txt for authentication details

## Alternative: SharePoint App-Only Principal

If Client Credentials still doesn't work, you can use SharePoint App-Only principal:

1. Register app directly in SharePoint (not Azure AD)
2. Generate ClientId and ClientSecret from SharePoint
3. Grant site collection permissions
4. Update Web.config with new credentials

Documentation: https://learn.microsoft.com/en-us/sharepoint/dev/solution-guidance/security-apponly-azureacs

## Contact

For Azure AD configuration help, contact:
- **Global Admin** or **Application Administrator**
- **SharePoint Administrator** for site permissions

---
*Last Updated: October 17, 2025*
