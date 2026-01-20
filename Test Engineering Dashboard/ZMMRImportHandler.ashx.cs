using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.IO;
using System.Web;
using System.Globalization;
using System.Text;

/// <summary>
/// HTTP Handler for automated ZMMR Scrap Data import via Power Automate
/// 
/// Usage from Power Automate:
/// 1. Trigger: "When a file is created" in OneDrive folder
/// 2. Action: HTTP POST to this endpoint with file content
/// 
/// Endpoint: https://your-server/TestEngineeringDashboard/ZMMRImportHandler.ashx
/// Method: POST
/// Headers: 
///   - Content-Type: text/csv  OR  application/octet-stream
///   - X-API-Key: your-secret-key (configured in Web.config)
///   - X-FileName: original-filename.csv (optional)
/// Body: Raw CSV file content
/// 
/// Response: JSON with import results
/// </summary>
public class ZMMRImportHandler : IHttpHandler
{
    private string ConnectionString
    {
        get 
        { 
            var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"];
            return cs != null ? cs.ConnectionString : "";
        }
    }

    // API Key for authentication - set in Web.config appSettings
    private string ApiKey
    {
        get
        {
            return ConfigurationManager.AppSettings["ZMMRImportApiKey"] ?? "ZMMR-Import-2026";
        }
    }

    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "application/json";
        
        try
        {
            // Only accept POST requests
            if (context.Request.HttpMethod != "POST")
            {
                SendError(context, 405, "Method not allowed. Use POST.");
                return;
            }

            // Validate API Key
            string providedKey = context.Request.Headers["X-API-Key"];
            if (string.IsNullOrEmpty(providedKey) || providedKey != ApiKey)
            {
                SendError(context, 401, "Unauthorized. Invalid or missing API key.");
                return;
            }

            // Get file name from header (optional)
            string fileName = context.Request.Headers["X-FileName"];
            if (string.IsNullOrEmpty(fileName))
            {
                fileName = string.Format("PowerAutomate_Import_{0:yyyyMMdd_HHmmss}.csv", DateTime.Now);
            }

            // Read CSV content from request body
            string csvContent;
            using (StreamReader reader = new StreamReader(context.Request.InputStream, Encoding.UTF8))
            {
                csvContent = reader.ReadToEnd();
            }

            if (string.IsNullOrEmpty(csvContent))
            {
                SendError(context, 400, "No CSV content provided in request body.");
                return;
            }

            // Parse and import the data
            DataTable dt = ParseCSV(csvContent);
            
            if (dt.Rows.Count == 0)
            {
                SendError(context, 400, "No valid data rows found in CSV.");
                return;
            }

            // Import data with duplicate detection
            int recordsImported = 0;
            int recordsSkipped = 0;
            ImportData(dt, fileName, out recordsImported, out recordsSkipped);

            // Send success response
            string response = string.Format(
                "{{\"success\":true,\"message\":\"Import completed successfully\",\"recordsImported\":{0},\"recordsSkipped\":{1},\"totalRows\":{2},\"fileName\":\"{3}\"}}",
                recordsImported, recordsSkipped, dt.Rows.Count, EscapeJson(fileName));
            
            context.Response.StatusCode = 200;
            context.Response.Write(response);
        }
        catch (Exception ex)
        {
            SendError(context, 500, string.Format("Import failed: {0}", ex.Message));
            LogError(ex);
        }
    }

    private void SendError(HttpContext context, int statusCode, string message)
    {
        context.Response.StatusCode = statusCode;
        context.Response.Write(string.Format("{{\"success\":false,\"error\":\"{0}\"}}", EscapeJson(message)));
    }

    private string EscapeJson(string s)
    {
        if (string.IsNullOrEmpty(s)) return "";
        return s.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\n", "\\n").Replace("\r", "\\r");
    }

    private DataTable ParseCSV(string csvContent)
    {
        DataTable dt = new DataTable();
        dt.Columns.Add("Amount", typeof(decimal));
        dt.Columns.Add("CostCenterCode", typeof(string));
        dt.Columns.Add("MaterialDescription", typeof(string));
        dt.Columns.Add("MaterialNumber", typeof(string));
        dt.Columns.Add("MovementType", typeof(int));
        dt.Columns.Add("MRPControllerDesc", typeof(string));
        dt.Columns.Add("PlantCode", typeof(string));
        dt.Columns.Add("PostingDate", typeof(DateTime));
        dt.Columns.Add("Quantity", typeof(int));
        dt.Columns.Add("ReasonDescription", typeof(string));
        dt.Columns.Add("UserFullName", typeof(string));

        string[] lines = csvContent.Split(new[] { "\r\n", "\r", "\n" }, StringSplitOptions.RemoveEmptyEntries);
        
        // Skip header row
        for (int i = 1; i < lines.Length; i++)
        {
            string line = lines[i].Trim();
            if (string.IsNullOrEmpty(line)) continue;

            try
            {
                string[] values = ParseCSVLine(line);
                
                // Expected columns from Power BI export:
                // zmmr_amount, zmmr_cost_center_code, zmmr_material_desc, zmmr_material_number, 
                // zmmr_movement_type, zmmr_mrp_controller_desc, zmmr_plant_code, zmmr_posting_date, 
                // zmmr_quantity, zmmr_reason_desc, zmmr_users_full_name, Total, Total
                
                if (values.Length < 11) continue;

                DataRow row = dt.NewRow();
                
                // zmmr_amount
                decimal amount;
                if (decimal.TryParse(values[0], NumberStyles.Any, CultureInfo.InvariantCulture, out amount))
                {
                    row["Amount"] = amount;
                }
                else
                {
                    continue;
                }

                // zmmr_cost_center_code
                row["CostCenterCode"] = values[1].Trim();

                // zmmr_material_desc
                row["MaterialDescription"] = values[2].Trim();

                // zmmr_material_number
                row["MaterialNumber"] = values[3].Trim();

                // zmmr_movement_type
                int movementType;
                if (int.TryParse(values[4], out movementType))
                {
                    row["MovementType"] = movementType;
                }
                else
                {
                    continue;
                }

                // zmmr_mrp_controller_desc
                row["MRPControllerDesc"] = values[5].Trim();

                // zmmr_plant_code
                row["PlantCode"] = values[6].Trim();

                // zmmr_posting_date
                DateTime postingDate;
                if (DateTime.TryParse(values[7], out postingDate))
                {
                    row["PostingDate"] = postingDate;
                }
                else
                {
                    continue;
                }

                // zmmr_quantity
                int quantity;
                if (int.TryParse(values[8], out quantity))
                {
                    row["Quantity"] = quantity;
                }
                else
                {
                    continue;
                }

                // zmmr_reason_desc
                row["ReasonDescription"] = values[9].Trim();

                // zmmr_users_full_name
                row["UserFullName"] = values[10].Trim();

                dt.Rows.Add(row);
            }
            catch
            {
                continue;
            }
        }

        return dt;
    }

    private string[] ParseCSVLine(string line)
    {
        List<string> result = new List<string>();
        bool inQuotes = false;
        StringBuilder current = new StringBuilder();

        for (int i = 0; i < line.Length; i++)
        {
            char c = line[i];

            if (c == '"')
            {
                if (inQuotes && i + 1 < line.Length && line[i + 1] == '"')
                {
                    current.Append('"');
                    i++;
                }
                else
                {
                    inQuotes = !inQuotes;
                }
            }
            else if (c == ',' && !inQuotes)
            {
                result.Add(current.ToString().Trim());
                current.Clear();
            }
            else
            {
                current.Append(c);
            }
        }
        
        result.Add(current.ToString().Trim());
        return result.ToArray();
    }

    private void ImportData(DataTable dt, string fileName, out int recordsImported, out int recordsSkipped)
    {
        recordsImported = 0;
        recordsSkipped = 0;
        Guid batchId = Guid.NewGuid();

        using (SqlConnection conn = new SqlConnection(ConnectionString))
        {
            conn.Open();

            // Create import log entry
            using (SqlCommand logCmd = new SqlCommand(
                @"INSERT INTO ZMMR_ImportLog (BatchID, FileName, ImportedBy, Status) 
                  VALUES (@BatchID, @FileName, 'PowerAutomate', 'In Progress')", conn))
            {
                logCmd.Parameters.AddWithValue("@BatchID", batchId);
                logCmd.Parameters.AddWithValue("@FileName", fileName);
                logCmd.ExecuteNonQuery();
            }

            // Insert each row, checking for duplicates
            foreach (DataRow sourceRow in dt.Rows)
            {
                // Check if record already exists using composite key
                using (SqlCommand checkCmd = new SqlCommand(
                    @"SELECT COUNT(*) FROM ZMMR_ScrapData 
                      WHERE Amount = @Amount 
                        AND CostCenterCode = @CostCenterCode 
                        AND MaterialNumber = @MaterialNumber
                        AND MovementType = @MovementType
                        AND PlantCode = @PlantCode
                        AND PostingDate = @PostingDate
                        AND Quantity = @Quantity
                        AND ISNULL(UserFullName, '') = @UserFullName", conn))
                {
                    checkCmd.Parameters.AddWithValue("@Amount", sourceRow["Amount"]);
                    checkCmd.Parameters.AddWithValue("@CostCenterCode", sourceRow["CostCenterCode"]);
                    checkCmd.Parameters.AddWithValue("@MaterialNumber", sourceRow["MaterialNumber"]);
                    checkCmd.Parameters.AddWithValue("@MovementType", sourceRow["MovementType"]);
                    checkCmd.Parameters.AddWithValue("@PlantCode", sourceRow["PlantCode"]);
                    checkCmd.Parameters.AddWithValue("@PostingDate", sourceRow["PostingDate"]);
                    checkCmd.Parameters.AddWithValue("@Quantity", sourceRow["Quantity"]);
                    checkCmd.Parameters.AddWithValue("@UserFullName", 
                        sourceRow["UserFullName"] != DBNull.Value ? sourceRow["UserFullName"].ToString() : "");

                    int exists = (int)checkCmd.ExecuteScalar();
                    if (exists > 0)
                    {
                        recordsSkipped++;
                        continue;
                    }
                }

                // Insert the record
                using (SqlCommand insertCmd = new SqlCommand(
                    @"INSERT INTO ZMMR_ScrapData 
                      (Amount, CostCenterCode, MaterialDescription, MaterialNumber, 
                       MovementType, MRPControllerDesc, PlantCode, PostingDate, 
                       Quantity, ReasonDescription, UserFullName, ImportFileName, ImportBatchID)
                      VALUES 
                      (@Amount, @CostCenterCode, @MaterialDescription, @MaterialNumber,
                       @MovementType, @MRPControllerDesc, @PlantCode, @PostingDate,
                       @Quantity, @ReasonDescription, @UserFullName, @FileName, @BatchID)", conn))
                {
                    insertCmd.Parameters.AddWithValue("@Amount", sourceRow["Amount"]);
                    insertCmd.Parameters.AddWithValue("@CostCenterCode", sourceRow["CostCenterCode"]);
                    insertCmd.Parameters.AddWithValue("@MaterialDescription", 
                        sourceRow["MaterialDescription"] ?? (object)DBNull.Value);
                    insertCmd.Parameters.AddWithValue("@MaterialNumber", sourceRow["MaterialNumber"]);
                    insertCmd.Parameters.AddWithValue("@MovementType", sourceRow["MovementType"]);
                    insertCmd.Parameters.AddWithValue("@MRPControllerDesc", 
                        sourceRow["MRPControllerDesc"] ?? (object)DBNull.Value);
                    insertCmd.Parameters.AddWithValue("@PlantCode", sourceRow["PlantCode"]);
                    insertCmd.Parameters.AddWithValue("@PostingDate", sourceRow["PostingDate"]);
                    insertCmd.Parameters.AddWithValue("@Quantity", sourceRow["Quantity"]);
                    insertCmd.Parameters.AddWithValue("@ReasonDescription", 
                        sourceRow["ReasonDescription"] ?? (object)DBNull.Value);
                    insertCmd.Parameters.AddWithValue("@UserFullName", 
                        sourceRow["UserFullName"] ?? (object)DBNull.Value);
                    insertCmd.Parameters.AddWithValue("@FileName", fileName);
                    insertCmd.Parameters.AddWithValue("@BatchID", batchId);

                    insertCmd.ExecuteNonQuery();
                    recordsImported++;
                }
            }

            // Update import log
            using (SqlCommand updateLogCmd = new SqlCommand(
                @"UPDATE ZMMR_ImportLog 
                  SET Status = 'Completed', RecordsImported = @Imported, RecordsSkipped = @Skipped 
                  WHERE BatchID = @BatchID", conn))
            {
                updateLogCmd.Parameters.AddWithValue("@Imported", recordsImported);
                updateLogCmd.Parameters.AddWithValue("@Skipped", recordsSkipped);
                updateLogCmd.Parameters.AddWithValue("@BatchID", batchId);
                updateLogCmd.ExecuteNonQuery();
            }
        }
    }

    private void LogError(Exception ex)
    {
        try
        {
            using (SqlConnection conn = new SqlConnection(ConnectionString))
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand(
                    @"INSERT INTO ZMMR_ImportLog (BatchID, FileName, ImportedBy, Status, Notes) 
                      VALUES (NEWID(), 'ERROR', 'PowerAutomate', 'Failed', @Error)", conn))
                {
                    cmd.Parameters.AddWithValue("@Error", ex.ToString());
                    cmd.ExecuteNonQuery();
                }
            }
        }
        catch { }
    }

    public bool IsReusable
    {
        get { return false; }
    }
}
