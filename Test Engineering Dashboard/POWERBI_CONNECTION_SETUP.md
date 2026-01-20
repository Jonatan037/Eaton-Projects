# Power BI Dataflow Connection Setup Guide

## Overview
This guide explains how to connect to Power BI dataflows from the Test Engineering Dashboard to retrieve SAP data (Scrap and NCM).

## What We're Connecting To

### ZMMR Dataflow (SAP Scrap Data)
- **Workspace**: CPDI-Business Intelligence and Analytics
- **Workspace ID**: `ce0ff094-0f63-43e9-909a-c5bc60e3be4f`
- **Dataflow ID**: `c4631e90-aeed-400f-bba3-25b5f8b5ba2e`
- **Entity Name**: `zmmr`
- **Power BI URL**: https://app.powerbi.com/groups/ce0ff094-0f63-43e9-909a-c5bc60e3be4f/dataflows/f1d3b983-2f97-40db-9101-e1e979979639

## Files Created

### 1. PowerBIDataflowService.cs
**Location**: `/App_Code/PowerBIDataflowService.cs`

**Purpose**: Core service class for connecting to Power BI dataflows via REST API

**Key Features**:
- Connects to Power BI dataflows using OAuth tokens
- Executes OData queries to filter and retrieve data
- Converts JSON responses to DataTable for easy consumption
- Factory pattern for creating service instances

**Usage Example**:
```csharp
// Create service for ZMMR (Scrap) data
var service = PowerBIDataflowFactory.CreateScrapDataService();

// Set authentication token
service.SetAccessToken(yourToken);

// Query data from 2024 onwards
DataTable scrapData = await service.GetScrapDataFrom2024Async();
```

### 2. TestPowerBIConnection.aspx
**Location**: `/TestPowerBIConnection.aspx`

**Purpose**: Test page to verify Power BI connection works

**Access**: Navigate to `http://your-server/TestEngineering/TestPowerBIConnection.aspx`

## Authentication Methods

### Method 1: Manual Token (For Initial Testing) ✅ **USE THIS FIRST**

This is the quickest way to test if the connection works.

**Steps to get a token**:

1. **Open Power BI Service**:
   - Go to https://app.powerbi.com
   - Sign in with your credentials (JonatanDArias@eaton.com)

2. **Open Browser Developer Tools**:
   - Press F12 in your browser
   - Go to the **Network** tab

3. **Trigger an API call**:
   - Navigate to any report or dataflow
   - The Network tab will show API calls to `api.powerbi.com`

4. **Copy the token**:
   - Click on any request to `api.powerbi.com`
   - Look in **Request Headers**
   - Find the `Authorization` header
   - Copy the token value (everything after `Bearer `)
   - It will look like: `eyJ0eXAiOiJKV1QiLCJhbGc...` (very long string)

5. **Test the connection**:
   - Go to TestPowerBIConnection.aspx
   - Paste the token in the text box
   - Click "Test Connection with Token"

**Note**: Tokens expire after ~1 hour, so you'll need to get a fresh one for testing.

### Method 2: Azure AD App Registration (For Production) 🚧 **NOT YET IMPLEMENTED**

For production use, you should create an Azure AD app registration. This requires:

1. **Create Azure AD App**:
   - Go to https://portal.azure.com
   - Navigate to Azure Active Directory → App registrations
   - Click "New registration"
   - Name it: "Test Engineering Dashboard - Power BI Integration"

2. **Configure API Permissions**:
   - Add permissions for "Power BI Service"
   - Required permissions:
     - Dataset.Read.All
     - Dataflow.Read.All

3. **Create Client Secret**:
   - Go to "Certificates & secrets"
   - Create a new client secret
   - Save the secret value (shown only once!)

4. **Add to Web.config**:
```xml
<appSettings>
  <add key="PowerBI.ClientId" value="your-client-id" />
  <add key="PowerBI.ClientSecret" value="your-client-secret" />
  <add key="PowerBI.TenantId" value="eaton.onmicrosoft.com" />
</appSettings>
```

**Note**: This method requires installing the MSAL library, which we haven't done yet.

## Testing the Connection

### Step 1: Get a Test Token
Follow Method 1 above to get a token from Power BI.

### Step 2: Test the Connection
1. Navigate to `TestPowerBIConnection.aspx`
2. Paste your token
3. Click "Test Connection with Token"

### Step 3: Verify Results
You should see:
- ✅ Success message with record count
- A preview of the data (first 100 rows)
- Column information

**Expected Columns in ZMMR**:
- plant_code
- profit_center
- cost_center_code
- material_document_number
- material_document_item_number
- movement_type
- gl_account_number
- special_stock_indicator
- material_type_code
- material_desc
- item_text
- transfer_requirement_number
- product_hierarchy
- posting_date
- time_of_entry
- (and more...)

## Troubleshooting

### Error: "401 Unauthorized"
- Your token has expired - get a fresh one
- Make sure you copied the entire token
- Verify you have access to the Power BI workspace

### Error: "403 Forbidden"
- Your account doesn't have permission to access the dataflow
- Contact the workspace admin to grant you access

### Error: "404 Not Found"
- Check the Workspace ID, Dataflow ID, or Entity Name
- Verify the dataflow still exists in Power BI

### Error: "Network error" or timeout
- Check your network connection
- Verify firewall isn't blocking api.powerbi.com
- Check if you're behind a proxy

## Next Steps

Once the connection is working:

1. ✅ **Verify data structure** - Understand the columns and data types
2. 🔄 **Implement proper auth** - Set up Azure AD app registration
3. 📊 **Build Scrap dashboard** - Create visualizations for scrap metrics
4. 🔄 **Repeat for NCM data** - Set up second dataflow for NCM
5. 🎨 **Create combined views** - Link scrap and NCM data with quality metrics

## Data Flow Architecture

```
Power BI Dataflow (SAP Data)
         ↓
    OData API
         ↓
  OAuth 2.0 Token
         ↓
PowerBIDataflowService.cs
         ↓
    DataTable
         ↓
  ASP.NET Dashboard
```

## Security Considerations

⚠️ **IMPORTANT**: Never hardcode passwords or tokens in your code!

- Use Azure Key Vault for production secrets
- Store tokens securely (encrypted in database or config)
- Implement token refresh logic
- Use service principal authentication (not user credentials)
- Enable logging to track API usage

## Additional Resources

- **Power BI REST API Docs**: https://docs.microsoft.com/en-us/rest/api/power-bi/
- **Dataflows OData**: https://docs.microsoft.com/en-us/power-bi/transform-model/dataflows/dataflows-configure-consume
- **Azure AD Authentication**: https://docs.microsoft.com/en-us/azure/active-directory/develop/

## Support

If you encounter issues:
1. Check the test page error messages
2. Review browser console (F12) for JavaScript errors
3. Check IIS logs for server errors
4. Verify Power BI access in the portal
