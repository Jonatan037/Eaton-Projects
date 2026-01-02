using System;
using System.Collections.Generic;
using System.Configuration;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

/// <summary>
/// Service for interacting with SharePoint Online to create folders and manage files
/// Uses Microsoft Graph API with username/password authentication
/// </summary>
public class SharePointService
{
    private static readonly string TenantId = ConfigurationManager.AppSettings["SharePoint.TenantId"];
    private static readonly string ClientId = ConfigurationManager.AppSettings["SharePoint.ClientId"];
    private static readonly string ClientSecret = ConfigurationManager.AppSettings["SharePoint.ClientSecret"];
    private static readonly string Username = ConfigurationManager.AppSettings["SharePoint.Username"];
    private static readonly string Password = ConfigurationManager.AppSettings["SharePoint.Password"];
    private static readonly string SiteUrl = ConfigurationManager.AppSettings["SharePoint.SiteUrl"];
    private static readonly string EquipmentInventoryPath = ConfigurationManager.AppSettings["SharePoint.EquipmentInventoryPath"];
    private static readonly bool Enabled = ConfigurationManager.AppSettings["SharePoint.Enabled"] == "true";

    private static string _cachedAccessToken = null;
    private static DateTime _tokenExpiration = DateTime.MinValue;
    private static string _lastError = null;

    /// <summary>
    /// Gets the last error message from SharePoint operations
    /// </summary>
    public static string GetLastError()
    {
        return _lastError ?? "No error details available";
    }

    /// <summary>
    /// Creates a folder in SharePoint for a newly created equipment item
    /// </summary>
    /// <param name="equipmentType">Type of equipment: ATE, Asset, Fixture, or Harness</param>
    /// <param name="eatonId">The Eaton ID for the equipment (e.g., YPO-ATE-SPD-001)</param>
    /// <returns>True if successful, false otherwise</returns>
    public static bool CreateEquipmentFolder(string equipmentType, string eatonId)
    {
        _lastError = null; // Clear previous error
        
        if (!Enabled)
        {
            _lastError = "SharePoint integration is disabled in web.config";
            LogMessage(_lastError);
            return false;
        }

        try
        {
            // Validate inputs
            if (string.IsNullOrWhiteSpace(equipmentType) || string.IsNullOrWhiteSpace(eatonId))
            {
                _lastError = "Invalid equipment type or Eaton ID";
                LogMessage(_lastError);
                return false;
            }

            // Map equipment type to folder name
            string parentFolder = GetParentFolderName(equipmentType);
            if (string.IsNullOrEmpty(parentFolder))
            {
                _lastError = "Unknown equipment type: " + equipmentType;
                LogMessage(_lastError);
                return false;
            }

            // Create the folder synchronously (we're in a web forms context)
            // Use ConfigureAwait(false) to avoid deadlocks
            var task = System.Threading.Tasks.Task.Run(async () => await CreateFolderAsync(parentFolder, eatonId).ConfigureAwait(false));
            
            // Add timeout to prevent hanging forever
            if (task.Wait(TimeSpan.FromSeconds(30)))
            {
                return task.Result;
            }
            else
            {
                _lastError = "SharePoint folder creation timed out after 30 seconds";
                LogMessage(_lastError);
                return false;
            }
        }
        catch (AggregateException aex)
        {
            var message = aex.InnerException != null ? aex.InnerException.Message : aex.Message;
            _lastError = "AggregateException: " + message;
            LogMessage("Error creating SharePoint folder (AggregateException): " + message);
            if (aex.InnerException != null)
            {
                LogMessage("Inner exception stack trace: " + aex.InnerException.StackTrace);
            }
            return false;
        }
        catch (Exception ex)
        {
            _lastError = ex.Message;
            LogMessage("Error creating SharePoint folder: " + ex.Message);
            LogMessage("Stack trace: " + ex.StackTrace);
            return false;
        }
    }

    /// <summary>
    /// Maps equipment type to the corresponding SharePoint folder name
    /// </summary>
    private static string GetParentFolderName(string equipmentType)
    {
        switch (equipmentType.ToUpperInvariant())
        {
            case "ATE":
                return "ATE";
            case "ASSET":
            case "DEVICE":
                return "Asset";
            case "FIXTURE":
                return "Fixture";
            case "HARNESS":
                return "Harness";
            default:
                return null;
        }
    }

    /// <summary>
    /// Asynchronously creates a folder in SharePoint using Microsoft Graph API
    /// </summary>
    private static async Task<bool> CreateFolderAsync(string parentFolder, string folderName)
    {
        try
        {
            LogMessage("Starting CreateFolderAsync for: " + parentFolder + "/" + folderName);
            
            // Get access token
            string accessToken = await GetAccessTokenAsync().ConfigureAwait(false);
            if (string.IsNullOrEmpty(accessToken))
            {
                _lastError = "Failed to obtain access token - check credentials";
                LogMessage(_lastError);
                return false;
            }
            LogMessage("Access token obtained successfully");

            // Get the site ID
            string siteId = await GetSiteIdAsync(accessToken).ConfigureAwait(false);
            if (string.IsNullOrEmpty(siteId))
            {
                _lastError = "Failed to get SharePoint site ID - check site URL";
                LogMessage(_lastError);
                return false;
            }
            LogMessage("Site ID obtained: " + siteId);

            // Get the drive ID
            string driveId = await GetDriveIdAsync(accessToken, siteId).ConfigureAwait(false);
            if (string.IsNullOrEmpty(driveId))
            {
                _lastError = "Failed to get SharePoint drive ID";
                LogMessage(_lastError);
                return false;
            }
            LogMessage("Drive ID obtained: " + driveId);

            // Construct the parent folder path
            string parentPath = EquipmentInventoryPath + "/" + parentFolder;
            LogMessage("Creating folder in path: " + parentPath);
            
            // Create the folder
            bool success = await CreateFolderInDriveAsync(accessToken, siteId, driveId, parentPath, folderName).ConfigureAwait(false);
            
            if (success)
            {
                LogMessage("Successfully created SharePoint folder: " + parentPath + "/" + folderName);
            }
            else
            {
                LogMessage("Failed to create SharePoint folder: " + parentPath + "/" + folderName);
            }

            return success;
        }
        catch (Exception ex)
        {
            LogMessage("Error in CreateFolderAsync: " + ex.Message);
            LogMessage("Stack trace: " + ex.StackTrace);
            return false;
        }
    }

    /// <summary>
    /// Gets an access token using Client Credentials flow (recommended for server-to-server)
    /// Falls back to ROPC if Client Credentials fails
    /// </summary>
    private static async Task<string> GetAccessTokenAsync()
    {
        // Check if we have a cached token that's still valid
        if (_cachedAccessToken != null && DateTime.UtcNow < _tokenExpiration)
        {
            return _cachedAccessToken;
        }

        // Try Client Credentials flow first (better for server-to-server)
        var token = await GetAccessTokenClientCredentialsAsync().ConfigureAwait(false);
        if (!string.IsNullOrEmpty(token))
        {
            return token;
        }

        // Fall back to ROPC flow
        LogMessage("Client Credentials failed, trying ROPC flow...");
        return await GetAccessTokenROPCAsync().ConfigureAwait(false);
    }

    /// <summary>
    /// Gets an access token using Client Credentials flow (app-only authentication)
    /// This requires Sites.ReadWrite.All application permission in Azure AD
    /// </summary>
    private static async Task<string> GetAccessTokenClientCredentialsAsync()
    {
        try
        {
            using (var client = new HttpClient())
            {
                var tokenEndpoint = string.Format("https://login.microsoftonline.com/{0}/oauth2/v2.0/token", TenantId);
                
                var content = new FormUrlEncodedContent(new[]
                {
                    new KeyValuePair<string, string>("client_id", ClientId),
                    new KeyValuePair<string, string>("client_secret", ClientSecret),
                    new KeyValuePair<string, string>("scope", "https://graph.microsoft.com/.default"),
                    new KeyValuePair<string, string>("grant_type", "client_credentials")
                });

                var response = await client.PostAsync(tokenEndpoint, content).ConfigureAwait(false);
                var responseContent = await response.Content.ReadAsStringAsync().ConfigureAwait(false);

                if (!response.IsSuccessStatusCode)
                {
                    try
                    {
                        var errorJson = JObject.Parse(responseContent);
                        var errorCode = errorJson["error"] != null ? errorJson["error"].ToString() : "unknown";
                        var errorDescription = errorJson["error_description"] != null ? errorJson["error_description"].ToString() : responseContent;
                        LogMessage(string.Format("Client Credentials auth failed - Error: {0}, Description: {1}", errorCode, errorDescription));
                    }
                    catch
                    {
                        LogMessage("Client Credentials token request failed: " + responseContent);
                    }
                    return null;
                }

                var json = JObject.Parse(responseContent);
                _cachedAccessToken = json["access_token"].ToString();
                
                // Token typically expires in 1 hour, cache for 50 minutes to be safe
                _tokenExpiration = DateTime.UtcNow.AddMinutes(50);
                
                LogMessage("Successfully obtained access token via Client Credentials");
                return _cachedAccessToken;
            }
        }
        catch (Exception ex)
        {
            LogMessage("Error in Client Credentials auth: " + ex.Message);
            return null;
        }
    }

    /// <summary>
    /// Gets an access token using Resource Owner Password Credentials (ROPC) flow
    /// This requires username/password and may fail if MFA is enabled
    /// </summary>
    private static async Task<string> GetAccessTokenROPCAsync()
    {
        try
        {
            using (var client = new HttpClient())
            {
                var tokenEndpoint = string.Format("https://login.microsoftonline.com/{0}/oauth2/v2.0/token", TenantId);
                
                var content = new FormUrlEncodedContent(new[]
                {
                    new KeyValuePair<string, string>("client_id", ClientId),
                    new KeyValuePair<string, string>("client_secret", ClientSecret),
                    new KeyValuePair<string, string>("scope", "https://graph.microsoft.com/.default"),
                    new KeyValuePair<string, string>("username", Username),
                    new KeyValuePair<string, string>("password", Password),
                    new KeyValuePair<string, string>("grant_type", "password")
                });

                var response = await client.PostAsync(tokenEndpoint, content).ConfigureAwait(false);
                var responseContent = await response.Content.ReadAsStringAsync().ConfigureAwait(false);

                if (!response.IsSuccessStatusCode)
                {
                    // Try to parse the Azure AD error response
                    try
                    {
                        var errorJson = JObject.Parse(responseContent);
                        var errorCode = errorJson["error"] != null ? errorJson["error"].ToString() : "unknown";
                        var errorDescription = errorJson["error_description"] != null ? errorJson["error_description"].ToString() : responseContent;
                        _lastError = string.Format("Azure AD Authentication Failed - Error: {0}, Description: {1}", errorCode, errorDescription);
                    }
                    catch
                    {
                        _lastError = "Token request failed: " + responseContent;
                    }
                    LogMessage(_lastError);
                    return null;
                }

                var json = JObject.Parse(responseContent);
                _cachedAccessToken = json["access_token"].ToString();
                
                // Token typically expires in 1 hour, cache for 50 minutes to be safe
                _tokenExpiration = DateTime.UtcNow.AddMinutes(50);
                
                LogMessage("Successfully obtained access token via ROPC");
                return _cachedAccessToken;
            }
        }
        catch (Exception ex)
        {
            _lastError = "Error getting access token: " + ex.Message;
            LogMessage(_lastError);
            return null;
        }
    }

    /// <summary>
    /// Gets the SharePoint site ID from the site URL
    /// </summary>
    private static async Task<string> GetSiteIdAsync(string accessToken)
    {
        try
        {
            using (var client = new HttpClient())
            {
                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);
                
                // Extract site parts from URL
                var siteUri = new Uri(SiteUrl);
                var hostname = siteUri.Host;
                var sitePath = siteUri.AbsolutePath;
                
                var apiUrl = string.Format("https://graph.microsoft.com/v1.0/sites/{0}:{1}", hostname, sitePath);
                
                var response = await client.GetAsync(apiUrl).ConfigureAwait(false);
                var responseContent = await response.Content.ReadAsStringAsync().ConfigureAwait(false);

                if (!response.IsSuccessStatusCode)
                {
                    _lastError = "Get site ID failed: " + responseContent;
                    LogMessage(_lastError);
                    return null;
                }

                var json = JObject.Parse(responseContent);
                return json["id"].ToString();
            }
        }
        catch (Exception ex)
        {
            _lastError = "Error getting site ID: " + ex.Message;
            LogMessage(_lastError);
            return null;
        }
    }

    /// <summary>
    /// Gets the default document library drive ID for the site
    /// </summary>
    private static async Task<string> GetDriveIdAsync(string accessToken, string siteId)
    {
        try
        {
            using (var client = new HttpClient())
            {
                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);
                
                var apiUrl = string.Format("https://graph.microsoft.com/v1.0/sites/{0}/drive", siteId);
                
                var response = await client.GetAsync(apiUrl).ConfigureAwait(false);
                var responseContent = await response.Content.ReadAsStringAsync().ConfigureAwait(false);

                if (!response.IsSuccessStatusCode)
                {
                    _lastError = "Get drive ID failed: " + responseContent;
                    LogMessage(_lastError);
                    return null;
                }

                var json = JObject.Parse(responseContent);
                return json["id"].ToString();
            }
        }
        catch (Exception ex)
        {
            _lastError = "Error getting drive ID: " + ex.Message;
            LogMessage(_lastError);
            return null;
        }
    }

    /// <summary>
    /// Creates a folder in the specified drive and path
    /// </summary>
    private static async Task<bool> CreateFolderInDriveAsync(string accessToken, string siteId, string driveId, string parentPath, string folderName)
    {
        try
        {
            using (var client = new HttpClient())
            {
                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);
                
                // URL encode the parent path
                var encodedPath = Uri.EscapeDataString(parentPath);
                var apiUrl = string.Format("https://graph.microsoft.com/v1.0/sites/{0}/drives/{1}/root:/{2}:/children", 
                    siteId, driveId, encodedPath);
                
                // Create the folder metadata
                var folderData = new
                {
                    name = folderName,
                    folder = new { },
                    conflictBehavior = "rename"
                };

                var jsonContent = JsonConvert.SerializeObject(folderData);
                var content = new StringContent(jsonContent, Encoding.UTF8, "application/json");

                var response = await client.PostAsync(apiUrl, content).ConfigureAwait(false);
                var responseContent = await response.Content.ReadAsStringAsync().ConfigureAwait(false);

                if (response.IsSuccessStatusCode)
                {
                    return true;
                }
                else if (response.StatusCode == HttpStatusCode.Conflict)
                {
                    // Folder already exists, consider this a success
                    LogMessage("Folder already exists: " + folderName);
                    return true;
                }
                else
                {
                    _lastError = "Create folder failed: " + responseContent;
                    LogMessage(_lastError);
                    return false;
                }
            }
        }
        catch (Exception ex)
        {
            _lastError = "Error creating folder in drive: " + ex.Message;
            LogMessage(_lastError);
            return false;
        }
    }

    /// <summary>
    /// Logs a message to the application event log or trace
    /// </summary>
    private static void LogMessage(string message)
    {
        try
        {
            // Log to trace/debug output
            System.Diagnostics.Trace.WriteLine("[SharePoint] " + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") + " - " + message);
            
            // Also log to a file if needed
            var logPath = HttpContext.Current.Server.MapPath("~/App_Data/SharePointLog.txt");
            var logDir = System.IO.Path.GetDirectoryName(logPath);
            if (!System.IO.Directory.Exists(logDir))
            {
                System.IO.Directory.CreateDirectory(logDir);
            }
            System.IO.File.AppendAllText(logPath, 
                DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") + " - " + message + Environment.NewLine);
        }
        catch
        {
            // Silently fail if logging fails
        }
    }
}
