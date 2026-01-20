using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.IO;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Globalization;

public partial class ZMMRDataImport : System.Web.UI.Page
{
    private string ConnectionString
    {
        get 
        { 
            var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"];
            return cs != null ? cs.ConnectionString : "";
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadSummaryStats();
            LoadImportLog();
        }
    }

    private void LoadSummaryStats()
    {
        try
        {
            using (SqlConnection conn = new SqlConnection(ConnectionString))
            {
                conn.Open();

                // Total records
                using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM ZMMR_ScrapData", conn))
                {
                    object result = cmd.ExecuteScalar();
                    lblTotalRecords.Text = result != null ? string.Format("{0:N0}", result) : "0";
                }

                // Last import date
                using (SqlCommand cmd = new SqlCommand("SELECT MAX(ImportedDate) FROM ZMMR_ScrapData", conn))
                {
                    object result = cmd.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                    {
                        lblLastImportDate.Text = ((DateTime)result).ToString("MM/dd/yy");
                    }
                    else
                    {
                        lblLastImportDate.Text = "-";
                    }
                }

                // Date range
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT MIN(PostingDate) AS MinDate, MAX(PostingDate) AS MaxDate FROM ZMMR_ScrapData", conn))
                {
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read() && reader["MinDate"] != DBNull.Value)
                        {
                            DateTime minDate = (DateTime)reader["MinDate"];
                            DateTime maxDate = (DateTime)reader["MaxDate"];
                            lblDateRange.Text = string.Format("{0:MMM yy} - {1:MMM yy}", minDate, maxDate);
                        }
                        else
                        {
                            lblDateRange.Text = "-";
                        }
                    }
                }

                // Files imported
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT COUNT(*) FROM ZMMR_ImportLog WHERE Status = 'Completed'", conn))
                {
                    object result = cmd.ExecuteScalar();
                    lblFilesImported.Text = result != null ? result.ToString() : "0";
                }
            }
        }
        catch (Exception ex)
        {
            // Tables may not exist yet - show defaults
            lblTotalRecords.Text = "0";
            lblLastImportDate.Text = "-";
            lblDateRange.Text = "-";
            lblFilesImported.Text = "0";
        }
    }

    private void LoadImportLog()
    {
        try
        {
            using (SqlConnection conn = new SqlConnection(ConnectionString))
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand(
                    @"SELECT TOP 10 ImportDate, FileName, RecordsImported, RecordsSkipped, Status, ImportedBy 
                      FROM ZMMR_ImportLog 
                      ORDER BY ImportDate DESC", conn))
                {
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        gvImportLog.DataSource = dt;
                        gvImportLog.DataBind();
                    }
                }
            }
        }
        catch
        {
            // Table may not exist yet
        }
    }

    protected void btnPreview_Click(object sender, EventArgs e)
    {
        if (!fileUpload.HasFile)
        {
            ShowError("Please select a CSV file to upload.");
            return;
        }

        if (!fileUpload.FileName.EndsWith(".csv", StringComparison.OrdinalIgnoreCase))
        {
            ShowError("Please upload a CSV file.");
            return;
        }

        try
        {
            // Parse CSV and show preview
            DataTable dt = ParseCSV(fileUpload.FileContent);
            
            // Store in session for import
            Session["ZMMRPreviewData"] = dt;
            Session["ZMMRFileName"] = fileUpload.FileName;

            // Show preview (first 50 rows)
            DataTable previewDt = dt.Clone();
            int maxRows = Math.Min(50, dt.Rows.Count);
            for (int i = 0; i < maxRows; i++)
            {
                previewDt.ImportRow(dt.Rows[i]);
            }

            gvPreview.DataSource = previewDt;
            gvPreview.DataBind();

            lblPreviewCount.Text = dt.Rows.Count.ToString();
            pnlPreview.Visible = true;
            btnImport.Visible = true;
        }
        catch (Exception ex)
        {
            ShowError("Error parsing CSV: " + ex.Message);
        }
    }

    private DataTable ParseCSV(Stream stream)
    {
        DataTable dt = new DataTable();
        dt.Columns.Add("Amount", typeof(decimal));
        dt.Columns.Add("CostCenterCode", typeof(string));
        dt.Columns.Add("MaterialDescription", typeof(string));
        dt.Columns.Add("MaterialNumber", typeof(string));
        dt.Columns.Add("MovementType", typeof(int));
        dt.Columns.Add("MRPControllerCode", typeof(string));
        dt.Columns.Add("MRPControllerDesc", typeof(string));
        dt.Columns.Add("PlantCode", typeof(string));
        dt.Columns.Add("PostingDate", typeof(DateTime));
        dt.Columns.Add("Quantity", typeof(int));
        dt.Columns.Add("ReasonDescription", typeof(string));
        dt.Columns.Add("UserFullName", typeof(string));

        using (StreamReader reader = new StreamReader(stream))
        {
            // Skip header row
            string headerLine = reader.ReadLine();
            
            while (!reader.EndOfStream)
            {
                string line = reader.ReadLine();
                if (string.IsNullOrWhiteSpace(line)) continue;

                string[] values = ParseCSVLine(line);
                if (values.Length < 12) continue;

                try
                {
                    DataRow row = dt.NewRow();
                    
                    // zmmr_amount
                    decimal amount;
                    if (decimal.TryParse(values[0], NumberStyles.Any, CultureInfo.InvariantCulture, out amount))
                    {
                        row["Amount"] = amount;
                    }
                    else
                    {
                        continue; // Skip invalid rows
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

                    // zmmr_mrp_controller_code (NEW)
                    row["MRPControllerCode"] = values[5].Trim();

                    // zmmr_mrp_controller_desc
                    row["MRPControllerDesc"] = values[6].Trim();

                    // zmmr_plant_code
                    row["PlantCode"] = values[7].Trim();

                    // zmmr_posting_date - handle various date formats
                    DateTime postingDate;
                    if (DateTime.TryParse(values[8], out postingDate))
                    {
                        row["PostingDate"] = postingDate;
                    }
                    else
                    {
                        continue;
                    }

                    // zmmr_quantity
                    int quantity;
                    if (int.TryParse(values[9], out quantity))
                    {
                        row["Quantity"] = quantity;
                    }
                    else
                    {
                        continue;
                    }

                    // zmmr_reason_desc
                    row["ReasonDescription"] = values[10].Trim();

                    // zmmr_users_full_name
                    row["UserFullName"] = values[11].Trim();

                    dt.Rows.Add(row);
                }
                catch
                {
                    // Skip problematic rows
                    continue;
                }
            }
        }

        return dt;
    }

    private string[] ParseCSVLine(string line)
    {
        List<string> result = new List<string>();
        bool inQuotes = false;
        string current = "";

        for (int i = 0; i < line.Length; i++)
        {
            char c = line[i];

            if (c == '"')
            {
                inQuotes = !inQuotes;
            }
            else if (c == ',' && !inQuotes)
            {
                result.Add(current);
                current = "";
            }
            else
            {
                current += c;
            }
        }
        result.Add(current);

        return result.ToArray();
    }

    protected void btnImport_Click(object sender, EventArgs e)
    {
        btnConfirmImport_Click(sender, e);
    }

    protected void btnConfirmImport_Click(object sender, EventArgs e)
    {
        DataTable dt = Session["ZMMRPreviewData"] as DataTable;
        string fileName = Session["ZMMRFileName"] as string;

        if (dt == null || dt.Rows.Count == 0)
        {
            ShowError("No data to import. Please upload a file first.");
            return;
        }

        try
        {
            int recordsImported = 0;
            int recordsSkipped = 0;
            Guid batchId = Guid.NewGuid();

            using (SqlConnection conn = new SqlConnection(ConnectionString))
            {
                conn.Open();

                // Create import log entry
                using (SqlCommand logCmd = new SqlCommand(
                    @"INSERT INTO ZMMR_ImportLog (BatchID, FileName, ImportedBy, Status) 
                      VALUES (@BatchID, @FileName, @ImportedBy, 'In Progress')", conn))
                {
                    logCmd.Parameters.AddWithValue("@BatchID", batchId);
                    logCmd.Parameters.AddWithValue("@FileName", fileName ?? "Unknown");
                    logCmd.Parameters.AddWithValue("@ImportedBy", 
                        Page.User.Identity.IsAuthenticated ? Page.User.Identity.Name : "System");
                    logCmd.ExecuteNonQuery();
                }

                // Insert each row, checking for duplicates
                foreach (DataRow sourceRow in dt.Rows)
                {
                    // Check if record already exists
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
                           MovementType, MRPControllerCode, MRPControllerDesc, PlantCode, PostingDate, 
                           Quantity, ReasonDescription, UserFullName, ImportFileName, ImportBatchID)
                          VALUES 
                          (@Amount, @CostCenterCode, @MaterialDescription, @MaterialNumber,
                           @MovementType, @MRPControllerCode, @MRPControllerDesc, @PlantCode, @PostingDate,
                           @Quantity, @ReasonDescription, @UserFullName, @FileName, @BatchID)", conn))
                    {
                        insertCmd.Parameters.AddWithValue("@Amount", sourceRow["Amount"]);
                        insertCmd.Parameters.AddWithValue("@CostCenterCode", sourceRow["CostCenterCode"]);
                        insertCmd.Parameters.AddWithValue("@MaterialDescription", 
                            sourceRow["MaterialDescription"] ?? (object)DBNull.Value);
                        insertCmd.Parameters.AddWithValue("@MaterialNumber", sourceRow["MaterialNumber"]);
                        insertCmd.Parameters.AddWithValue("@MovementType", sourceRow["MovementType"]);
                        insertCmd.Parameters.AddWithValue("@MRPControllerCode", 
                            sourceRow["MRPControllerCode"] ?? (object)DBNull.Value);
                        insertCmd.Parameters.AddWithValue("@MRPControllerDesc", 
                            sourceRow["MRPControllerDesc"] ?? (object)DBNull.Value);
                        insertCmd.Parameters.AddWithValue("@PlantCode", sourceRow["PlantCode"]);
                        insertCmd.Parameters.AddWithValue("@PostingDate", sourceRow["PostingDate"]);
                        insertCmd.Parameters.AddWithValue("@Quantity", sourceRow["Quantity"]);
                        insertCmd.Parameters.AddWithValue("@ReasonDescription", 
                            sourceRow["ReasonDescription"] ?? (object)DBNull.Value);
                        insertCmd.Parameters.AddWithValue("@UserFullName", 
                            sourceRow["UserFullName"] ?? (object)DBNull.Value);
                        insertCmd.Parameters.AddWithValue("@FileName", fileName ?? "Unknown");
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

            // Clear session
            Session.Remove("ZMMRPreviewData");
            Session.Remove("ZMMRFileName");

            // Show success
            ShowSuccess(string.Format("Successfully imported {0:N0} records. {1:N0} duplicates skipped.", 
                recordsImported, recordsSkipped));
            
            // Refresh stats and log
            LoadSummaryStats();
            LoadImportLog();
            pnlPreview.Visible = false;
        }
        catch (Exception ex)
        {
            ShowError("Import failed: " + ex.Message);
        }
    }

    protected void btnReset_Click(object sender, EventArgs e)
    {
        Session.Remove("ZMMRPreviewData");
        Session.Remove("ZMMRFileName");
        
        pnlPreview.Visible = false;
        pnlResults.Visible = false;
        pnlSuccess.Visible = false;
        pnlError.Visible = false;
        btnImport.Visible = false;
        
        LoadSummaryStats();
        LoadImportLog();
    }

    private void ShowSuccess(string message)
    {
        pnlResults.Visible = true;
        pnlSuccess.Visible = true;
        pnlError.Visible = false;
        lblSuccessMessage.Text = message;
        pnlUpload.Visible = false;
    }

    private void ShowError(string message)
    {
        pnlResults.Visible = true;
        pnlError.Visible = true;
        pnlSuccess.Visible = false;
        lblErrorMessage.Text = message;
    }
}
