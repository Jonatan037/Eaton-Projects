using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

/// <summary>
/// Service for connecting to Power BI Dataflows to retrieve SAP data
/// </summary>
public class PowerBIDataflowService
{
    // Power BI API endpoints
    private const string PowerBIApiBaseUrl = "https://api.powerbi.com/v1.0/myorg";
    private const string AuthorityUrl = "https://login.microsoftonline.com/common";
    private const string PowerBIResourceId = "https://analysis.windows.net/powerbi/api";
    
    // Dataflow information
    private readonly string workspaceId;
    private readonly string dataflowId;
    private readonly string entityName;
    
    // Authentication token
    private string accessToken;
    private DateTime tokenExpiry;
    
    /// <summary>
    /// Initialize the Power BI Dataflow Service
    /// </summary>
    /// <param name="workspaceId">Power BI Workspace GUID</param>
    /// <param name="dataflowId">Dataflow GUID</param>
    /// <param name="entityName">Entity/Table name in the dataflow</param>
    public PowerBIDataflowService(string workspaceId, string dataflowId, string entityName)
    {
        this.workspaceId = workspaceId;
        this.dataflowId = dataflowId;
        this.entityName = entityName;
    }
    
    /// <summary>
    /// Get the OData endpoint URL for the dataflow entity
    /// </summary>
    private string GetDataflowODataUrl()
    {
        // Power BI Dataflows expose OData endpoints
        // Format: https://api.powerbi.com/v1.0/myorg/groups/{workspaceId}/dataflows/{dataflowId}/entities/{entityName}
        return string.Format("{0}/groups/{1}/dataflows/{2}/entities/{3}", 
            PowerBIApiBaseUrl, workspaceId, dataflowId, entityName);
    }
    
    /// <summary>
    /// Authenticate and get access token
    /// NOTE: This is a placeholder - you need to implement proper Azure AD authentication
    /// </summary>
    public void AuthenticateWithServicePrincipal(string clientId, string clientSecret, string tenantId)
    {
        // TODO: Implement Azure AD authentication using MSAL or ADAL
        // This would get an OAuth token to access Power BI
        
        throw new NotImplementedException(
            "Authentication needs to be configured. Please set up Azure AD App Registration and use MSAL library."
        );
    }
    
    /// <summary>
    /// Set access token manually (for testing)
    /// </summary>
    public void SetAccessToken(string token)
    {
        this.accessToken = token;
        this.tokenExpiry = DateTime.UtcNow.AddHours(1); // Tokens typically valid for 1 hour
    }
    
    /// <summary>
    /// Query the dataflow using OData queries
    /// </summary>
    /// <param name="filter">OData filter expression (e.g., "posting_date ge 2024-01-01")</param>
    /// <param name="top">Number of records to return (optional)</param>
    /// <returns>DataTable with results</returns>
    public async Task<DataTable> QueryDataflowAsync(string filter = null, int? top = null)
    {
        if (string.IsNullOrEmpty(accessToken))
        {
            throw new InvalidOperationException("Not authenticated. Call SetAccessToken or AuthenticateWithServicePrincipal first.");
        }
        
        try
        {
            // Force TLS 1.2 for Power BI API
            ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;
            
            // Build OData query URL
            var queryUrl = GetDataflowODataUrl();
            var queryParams = new List<string>();
            
            if (!string.IsNullOrEmpty(filter))
            {
                queryParams.Add("$filter=" + Uri.EscapeDataString(filter));
            }
            
            if (top.HasValue)
            {
                queryParams.Add("$top=" + top.Value.ToString());
            }
            
            if (queryParams.Any())
            {
                queryUrl += "?" + string.Join("&", queryParams);
            }
            
            // Configure HttpClientHandler for TLS 1.2
            var handler = new HttpClientHandler
            {
                SslProtocols = System.Security.Authentication.SslProtocols.Tls12,
                UseDefaultCredentials = true, // Use Windows credentials for proxy authentication
                UseProxy = true,
                Proxy = WebRequest.GetSystemWebProxy() // Use system proxy settings
            };
            
            using (var client = new HttpClient(handler))
            {
                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);
                client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
                client.Timeout = TimeSpan.FromMinutes(2); // Increase timeout
                
                var response = await client.GetAsync(queryUrl);
                
                if (!response.IsSuccessStatusCode)
                {
                    var errorContent = await response.Content.ReadAsStringAsync();
                    throw new Exception(string.Format("Failed to query dataflow: {0} - {1}", 
                        response.StatusCode, errorContent));
                }
                
                var jsonContent = await response.Content.ReadAsStringAsync();
                var result = JObject.Parse(jsonContent);
                
                // Convert JSON to DataTable
                return JsonToDataTable(result);
            }
        }
        catch (HttpRequestException ex)
        {
            // Provide more helpful error message
            throw new Exception("Failed to connect to Power BI API. Check network connection, firewall, and proxy settings. Error: " + ex.Message, ex);
        }
        catch (TaskCanceledException ex)
        {
            throw new Exception("Request timed out connecting to Power BI API. This may be a network or firewall issue.", ex);
        }
    }
    
    /// <summary>
    /// Convert OData JSON response to DataTable
    /// </summary>
    private DataTable JsonToDataTable(JObject jsonResult)
    {
        var dt = new DataTable();
        
        // OData responses have a "value" array with the data
        var values = jsonResult["value"] as JArray;
        
        if (values == null || !values.Any())
        {
            return dt;
        }
        
        // Create columns from first row
        var firstRow = values[0] as JObject;
        if (firstRow != null)
        {
            foreach (var prop in firstRow.Properties())
            {
                // Skip metadata properties
                if (prop.Name.StartsWith("@"))
                    continue;
                    
                dt.Columns.Add(prop.Name, GetColumnType(prop.Value));
            }
        }
        
        // Add rows
        foreach (JObject row in values)
        {
            var dataRow = dt.NewRow();
            foreach (var prop in row.Properties())
            {
                if (prop.Name.StartsWith("@"))
                    continue;
                    
                if (dt.Columns.Contains(prop.Name))
                {
                    dataRow[prop.Name] = GetValue(prop.Value);
                }
            }
            dt.Rows.Add(dataRow);
        }
        
        return dt;
    }
    
    private Type GetColumnType(JToken token)
    {
        switch (token.Type)
        {
            case JTokenType.Integer:
                return typeof(long);
            case JTokenType.Float:
                return typeof(decimal);
            case JTokenType.Boolean:
                return typeof(bool);
            case JTokenType.Date:
                return typeof(DateTime);
            default:
                return typeof(string);
        }
    }
    
    private object GetValue(JToken token)
    {
        if (token.Type == JTokenType.Null)
            return DBNull.Value;
            
        return token.ToObject<object>();
    }
    
    /// <summary>
    /// Get SAP Scrap data (zmmr table) filtered from 2024 onwards
    /// </summary>
    public async Task<DataTable> GetScrapDataFrom2024Async()
    {
        // OData filter for dates >= 2024-01-01
        var filter = "posting_date ge 2024-01-01T00:00:00Z";
        return await QueryDataflowAsync(filter);
    }
}

/// <summary>
/// Factory for creating Power BI Dataflow Service instances
/// </summary>
public static class PowerBIDataflowFactory
{
    // ZMMR Dataflow (SAP Scrap Data)
    private const string CPDI_WorkspaceId = "ce0ff094-0f63-43e9-909a-c5bc60e3be4f";
    private const string ZMMR_DataflowId = "c4631e90-aeed-400f-bba3-25b5f8b5ba2e";
    private const string ZMMR_EntityName = "zmmr";
    
    /// <summary>
    /// Create service for SAP Scrap data (ZMMR)
    /// </summary>
    public static PowerBIDataflowService CreateScrapDataService()
    {
        return new PowerBIDataflowService(CPDI_WorkspaceId, ZMMR_DataflowId, ZMMR_EntityName);
    }
}
