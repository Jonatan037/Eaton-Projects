using System;
using System.Configuration;
using System.IO;
using System.Web;

/// <summary>
/// Service for managing local file system folders for equipment, calibration, PM, and troubleshooting records
/// Creates organized folder structures for document storage
/// </summary>
public class LocalFileSystemService
{
    private static readonly string BaseStoragePath = ConfigurationManager.AppSettings["LocalStorage.BasePath"] ?? "~/Storage";
    private static string _lastError = null;

    /// <summary>
    /// Gets the last error message from file system operations
    /// </summary>
    public static string GetLastError()
    {
        return _lastError ?? "No error details available";
    }

    /// <summary>
    /// Creates a folder for equipment inventory
    /// Structure: Storage/Equipment Inventory/{EquipmentType}/{EatonID}/
    /// </summary>
    /// <param name="equipmentType">Type of equipment (ATE, Asset, Fixture, Harness)</param>
    /// <param name="eatonId">The Eaton ID of the equipment</param>
    /// <returns>True if folder was created successfully, false otherwise</returns>
    public static bool CreateEquipmentFolder(string equipmentType, string eatonId)
    {
        try
        {
            if (string.IsNullOrWhiteSpace(equipmentType))
            {
                _lastError = "Equipment type cannot be empty";
                return false;
            }

            if (string.IsNullOrWhiteSpace(eatonId))
            {
                _lastError = "Eaton ID cannot be empty";
                return false;
            }

            // Get the physical path
            string basePath = HttpContext.Current.Server.MapPath(BaseStoragePath);
            string equipmentInventoryPath = Path.Combine(basePath, "Equipment Inventory");
            string equipmentTypePath = Path.Combine(equipmentInventoryPath, equipmentType);
            string equipmentFolderPath = Path.Combine(equipmentTypePath, SanitizeFolderName(eatonId));

            // Create the directory structure
            Directory.CreateDirectory(equipmentFolderPath);

            LogMessage(string.Format("Created equipment folder: {0}", equipmentFolderPath));
            _lastError = null;
            return true;
        }
        catch (Exception ex)
        {
            _lastError = string.Format("Error creating equipment folder: {0}", ex.Message);
            LogMessage(_lastError);
            return false;
        }
    }

    /// <summary>
    /// Creates a folder for calibration logs
    /// Structure: Storage/Calibration Logs/{CalibrationID}_{EquipmentEatonID}/
    /// </summary>
    /// <param name="calibrationId">The calibration record ID</param>
    /// <param name="equipmentEatonId">The Eaton ID of the equipment being calibrated</param>
    /// <returns>True if folder was created successfully, false otherwise</returns>
    public static bool CreateCalibrationFolder(string calibrationId, string equipmentEatonId)
    {
        try
        {
            if (string.IsNullOrWhiteSpace(calibrationId))
            {
                _lastError = "Calibration ID cannot be empty";
                return false;
            }

            if (string.IsNullOrWhiteSpace(equipmentEatonId))
            {
                _lastError = "Equipment Eaton ID cannot be empty";
                return false;
            }

            // Get the physical path
            string basePath = HttpContext.Current.Server.MapPath(BaseStoragePath);
            string calibrationLogsPath = Path.Combine(basePath, "Calibration Logs");
            string folderName = string.Format("{0}_{1}", calibrationId, SanitizeFolderName(equipmentEatonId));
            string calibrationFolderPath = Path.Combine(calibrationLogsPath, folderName);

            // Create the directory structure
            Directory.CreateDirectory(calibrationFolderPath);

            LogMessage(string.Format("Created calibration folder: {0}", calibrationFolderPath));
            _lastError = null;
            return true;
        }
        catch (Exception ex)
        {
            _lastError = string.Format("Error creating calibration folder: {0}", ex.Message);
            LogMessage(_lastError);
            return false;
        }
    }

    /// <summary>
    /// Creates a folder for preventive maintenance logs
    /// Structure: Storage/PM Logs/{PMID}_{EquipmentEatonID}/
    /// </summary>
    /// <param name="pmId">The PM record ID</param>
    /// <param name="equipmentEatonId">The Eaton ID of the equipment</param>
    /// <returns>True if folder was created successfully, false otherwise</returns>
    public static bool CreatePMFolder(string pmId, string equipmentEatonId)
    {
        try
        {
            if (string.IsNullOrWhiteSpace(pmId))
            {
                _lastError = "PM ID cannot be empty";
                return false;
            }

            if (string.IsNullOrWhiteSpace(equipmentEatonId))
            {
                _lastError = "Equipment Eaton ID cannot be empty";
                return false;
            }

            // Get the physical path
            string basePath = HttpContext.Current.Server.MapPath(BaseStoragePath);
            string pmLogsPath = Path.Combine(basePath, "PM Logs");
            string folderName = string.Format("{0}_{1}", pmId, SanitizeFolderName(equipmentEatonId));
            string pmFolderPath = Path.Combine(pmLogsPath, folderName);

            // Create the directory structure
            Directory.CreateDirectory(pmFolderPath);

            LogMessage(string.Format("Created PM folder: {0}", pmFolderPath));
            _lastError = null;
            return true;
        }
        catch (Exception ex)
        {
            _lastError = string.Format("Error creating PM folder: {0}", ex.Message);
            LogMessage(_lastError);
            return false;
        }
    }

    /// <summary>
    /// Creates a folder for troubleshooting records
    /// Structure: Storage/Troubleshooting/{TroubleshootingID}_{Location}/
    /// </summary>
    /// <param name="troubleshootingId">The troubleshooting record ID</param>
    /// <param name="location">The location where troubleshooting occurred</param>
    /// <returns>True if folder was created successfully, false otherwise</returns>
    public static bool CreateTroubleshootingFolder(string troubleshootingId, string location)
    {
        try
        {
            if (string.IsNullOrWhiteSpace(troubleshootingId))
            {
                _lastError = "Troubleshooting ID cannot be empty";
                return false;
            }

            if (string.IsNullOrWhiteSpace(location))
            {
                _lastError = "Location cannot be empty";
                return false;
            }

            // Get the physical path
            string basePath = HttpContext.Current.Server.MapPath(BaseStoragePath);
            string troubleshootingPath = Path.Combine(basePath, "Troubleshooting");
            string folderName = string.Format("{0}_{1}", troubleshootingId, SanitizeFolderName(location));
            string troubleshootingFolderPath = Path.Combine(troubleshootingPath, folderName);

            // Create the directory structure
            Directory.CreateDirectory(troubleshootingFolderPath);

            LogMessage(string.Format("Created troubleshooting folder: {0}", troubleshootingFolderPath));
            _lastError = null;
            return true;
        }
        catch (Exception ex)
        {
            _lastError = string.Format("Error creating troubleshooting folder: {0}", ex.Message);
            LogMessage(_lastError);
            return false;
        }
    }

    /// <summary>
    /// Gets the physical path for an equipment folder
    /// </summary>
    /// <param name="equipmentType">Type of equipment</param>
    /// <param name="eatonId">The Eaton ID</param>
    /// <returns>Physical path to the folder, or null if folder doesn't exist</returns>
    public static string GetEquipmentFolderPath(string equipmentType, string eatonId)
    {
        try
        {
            string basePath = HttpContext.Current.Server.MapPath(BaseStoragePath);
            string equipmentInventoryPath = Path.Combine(basePath, "Equipment Inventory");
            string equipmentTypePath = Path.Combine(equipmentInventoryPath, equipmentType);
            string equipmentFolderPath = Path.Combine(equipmentTypePath, SanitizeFolderName(eatonId));

            return Directory.Exists(equipmentFolderPath) ? equipmentFolderPath : null;
        }
        catch
        {
            return null;
        }
    }

    /// <summary>
    /// Gets the physical path for a calibration folder
    /// </summary>
    public static string GetCalibrationFolderPath(string calibrationId, string equipmentEatonId)
    {
        try
        {
            string basePath = HttpContext.Current.Server.MapPath(BaseStoragePath);
            string calibrationLogsPath = Path.Combine(basePath, "Calibration Logs");
            string folderName = string.Format("{0}_{1}", calibrationId, SanitizeFolderName(equipmentEatonId));
            string calibrationFolderPath = Path.Combine(calibrationLogsPath, folderName);

            return Directory.Exists(calibrationFolderPath) ? calibrationFolderPath : null;
        }
        catch
        {
            return null;
        }
    }

    /// <summary>
    /// Gets the physical path for a PM folder
    /// </summary>
    public static string GetPMFolderPath(string pmId, string equipmentEatonId)
    {
        try
        {
            string basePath = HttpContext.Current.Server.MapPath(BaseStoragePath);
            string pmLogsPath = Path.Combine(basePath, "PM Logs");
            string folderName = string.Format("{0}_{1}", pmId, SanitizeFolderName(equipmentEatonId));
            string pmFolderPath = Path.Combine(pmLogsPath, folderName);

            return Directory.Exists(pmFolderPath) ? pmFolderPath : null;
        }
        catch
        {
            return null;
        }
    }

    /// <summary>
    /// Gets the physical path for a troubleshooting folder
    /// </summary>
    public static string GetTroubleshootingFolderPath(string troubleshootingId, string location)
    {
        try
        {
            string basePath = HttpContext.Current.Server.MapPath(BaseStoragePath);
            string troubleshootingPath = Path.Combine(basePath, "Troubleshooting");
            string folderName = string.Format("{0}_{1}", troubleshootingId, SanitizeFolderName(location));
            string troubleshootingFolderPath = Path.Combine(troubleshootingPath, folderName);

            return Directory.Exists(troubleshootingFolderPath) ? troubleshootingFolderPath : null;
        }
        catch
        {
            return null;
        }
    }

    /// <summary>
    /// Sanitizes a folder name by removing invalid characters
    /// </summary>
    public static string SanitizeFolderName(string folderName)
    {
        if (string.IsNullOrWhiteSpace(folderName))
            return "Unknown";

        // Remove or replace invalid path characters
        char[] invalidChars = Path.GetInvalidFileNameChars();
        string sanitized = folderName;

        foreach (char c in invalidChars)
        {
            sanitized = sanitized.Replace(c, '_');
        }

        // Also replace some common problematic characters
        sanitized = sanitized.Replace(':', '-');
        sanitized = sanitized.Replace('/', '-');
        sanitized = sanitized.Replace('\\', '-');

        return sanitized.Trim();
    }

    /// <summary>
    /// Logs a message to the application event log or trace
    /// </summary>
    private static void LogMessage(string message)
    {
        try
        {
            // Log to trace/debug output
            System.Diagnostics.Trace.WriteLine("[LocalFileSystem] " + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") + " - " + message);

            // Also log to a file
            var logPath = HttpContext.Current.Server.MapPath("~/App_Data/FileSystemLog.txt");
            var logDir = Path.GetDirectoryName(logPath);
            if (!Directory.Exists(logDir))
            {
                Directory.CreateDirectory(logDir);
            }
            File.AppendAllText(logPath,
                DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") + " - " + message + Environment.NewLine);
        }
        catch
        {
            // Silently fail if logging fails
        }
    }

    /// <summary>
    /// Gets the base storage path from configuration
    /// </summary>
    public static string GetBaseStoragePath()
    {
        return BaseStoragePath;
    }

    /// <summary>
    /// Gets the server/computer name from configuration
    /// </summary>
    public static string GetServerName()
    {
        return ConfigurationManager.AppSettings["ServerName"] ?? "localhost";
    }

    /// <summary>
    /// Converts a local file system path to a network/UNC path for display
    /// Uses LocalStorage.NetworkPath from Web.config if configured, otherwise builds from ServerName
    /// </summary>
    public static string ConvertToNetworkPath(string localPath)
    {
        if (string.IsNullOrEmpty(localPath))
            return localPath;

        try
        {
            string networkPath = ConfigurationManager.AppSettings["LocalStorage.NetworkPath"];
            
            // If no network path configured, build it from ServerName
            if (string.IsNullOrWhiteSpace(networkPath))
            {
                string serverName = GetServerName();
                networkPath = string.Format("\\\\{0}\\Test Engineering Dashboard\\Storage", serverName);
            }

            // Get the physical base path
            string basePath = HttpContext.Current.Server.MapPath(BaseStoragePath);
            
            // If the local path starts with the base path, replace it with the network path
            if (localPath.StartsWith(basePath, StringComparison.OrdinalIgnoreCase))
            {
                string relativePath = localPath.Substring(basePath.Length).TrimStart('\\', '/');
                return Path.Combine(networkPath, relativePath);
            }

            return localPath;
        }
        catch
        {
            return localPath;
        }
    }
}
