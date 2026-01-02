using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

// Last Modified: October 23, 2025 - 01:00 UTC - Calibration Logs Grid View
public partial class TED_CalibrationGridView : Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadData();
            ViewState["DropdownsLoaded"] = true;
        }
        else
        {
            // On postback, re-initialize row highlighting after a delay
            ScriptManager.RegisterStartupScript(this, GetType(), "initRows", "setTimeout(function() { initializeRowHighlighting(); updateFilterCount(); }, 300);", true);
        }
    }

    private void LoadData()
    {
        try
        {
            LoadStatus();
            LoadResultCodes();
            LoadMethods();
            LoadVendorNames();
            LoadEquipmentTypes();
            LoadEquipmentNames();
            LoadEquipmentEatonIDs();
            BindGrid();
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error loading data: " + ex.Message);
            // Show error in browser
            Response.Write("<script>console.error('LoadData Error: " + ex.Message.Replace("'", "\\'") + "');</script>");
        }
    }

    private void LoadStatus()
    {
        // Skip if already loaded (prevents duplicates on AutoPostBack)
        if (ViewState["DropdownsLoaded"] != null) return;

        var connStrObj = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"];
        string connStr = connStrObj != null ? connStrObj.ConnectionString : null;
        if (string.IsNullOrEmpty(connStr))
        {
            Response.Write("<script>console.error('Connection string is null or empty');</script>");
            return;
        }

        try
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                Response.Write("<script>console.log('Database connected successfully');</script>");

                // Clear existing items except "All Status"
                ddlStatus.Items.Clear();
                ddlStatus.Items.Add(new ListItem("All Status", "ALL"));

                // Get unique statuses from calibration table
                string query = @"SELECT DISTINCT [Status] as Status FROM dbo.Calibration_Log
                                WHERE [Status] IS NOT NULL AND [Status] <> ''
                                ORDER BY Status";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    int count = 0;
                    while (reader.Read())
                    {
                        string status = reader["Status"].ToString();
                        if (!string.IsNullOrWhiteSpace(status))
                        {
                            ddlStatus.Items.Add(new ListItem(status, status));
                            count++;
                        }
                    }
                    Response.Write("<script>console.log('Loaded " + count + " status values');</script>");
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error loading status: " + ex.Message);
            Response.Write("<script>console.error('LoadStatus Error: " + ex.Message.Replace("'", "\\'") + "');</script>");
        }
    }

    private void LoadResultCodes()
    {
        // Skip if already loaded (prevents duplicates on AutoPostBack)
        if (ViewState["DropdownsLoaded"] != null) return;

        var connStrObj = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"];
        string connStr = connStrObj != null ? connStrObj.ConnectionString : null;
        if (string.IsNullOrEmpty(connStr)) return;

        try
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                // Clear existing items except "All Results"
                ddlResultCode.Items.Clear();
                ddlResultCode.Items.Add(new ListItem("All Results", "ALL"));

                // Get unique result codes from calibration table
                string query = @"SELECT DISTINCT [ResultCode] as ResultCode FROM dbo.Calibration_Log
                                WHERE [ResultCode] IS NOT NULL AND [ResultCode] <> ''
                                ORDER BY ResultCode";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    int count = 0;
                    while (reader.Read())
                    {
                        string resultCode = reader["ResultCode"].ToString();
                        if (!string.IsNullOrWhiteSpace(resultCode))
                        {
                            ddlResultCode.Items.Add(new ListItem(resultCode, resultCode));
                            count++;
                        }
                    }
                    Response.Write("<script>console.log('Loaded " + count + " result code values');</script>");
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error loading result codes: " + ex.Message);
            Response.Write("<script>console.error('LoadResultCodes Error: " + ex.Message.Replace("'", "\\'") + "');</script>");
        }
    }

    private void LoadVendorNames()
    {
        // Skip if already loaded (prevents duplicates on AutoPostBack)
        if (ViewState["DropdownsLoaded"] != null) return;

        var connStrObj = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"];
        string connStr = connStrObj != null ? connStrObj.ConnectionString : null;
        if (string.IsNullOrEmpty(connStr)) return;

        try
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                // Clear existing items except "All Vendors"
                ddlVendorName.Items.Clear();
                ddlVendorName.Items.Add(new ListItem("All Vendors", "ALL"));

                // Get unique vendor names from calibration table
                string query = @"SELECT DISTINCT [VendorName] as VendorName FROM dbo.Calibration_Log
                                WHERE [VendorName] IS NOT NULL AND [VendorName] <> ''
                                ORDER BY VendorName";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    int count = 0;
                    while (reader.Read())
                    {
                        string vendorName = reader["VendorName"].ToString();
                        if (!string.IsNullOrWhiteSpace(vendorName))
                        {
                            ddlVendorName.Items.Add(new ListItem(vendorName, vendorName));
                            count++;
                        }
                    }
                    Response.Write("<script>console.log('Loaded " + count + " vendor name values');</script>");
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error loading vendor names: " + ex.Message);
            Response.Write("<script>console.error('LoadVendorNames Error: " + ex.Message.Replace("'", "\\'") + "');</script>");
        }
    }

    private void LoadEquipmentTypes()
    {
        // Skip if already loaded (prevents duplicates on AutoPostBack)
        if (ViewState["DropdownsLoaded"] != null) return;

        var connStrObj = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"];
        string connStr = connStrObj != null ? connStrObj.ConnectionString : null;
        if (string.IsNullOrEmpty(connStr)) return;

        try
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                // Clear existing items except "All Types"
                ddlEquipmentType.Items.Clear();
                ddlEquipmentType.Items.Add(new ListItem("All Types", "ALL"));

                // Get unique equipment types from calibration table
                string query = @"SELECT DISTINCT [EquipmentType] as EquipmentType FROM dbo.Calibration_Log
                                WHERE [EquipmentType] IS NOT NULL AND [EquipmentType] <> ''
                                ORDER BY EquipmentType";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    int count = 0;
                    while (reader.Read())
                    {
                        string equipmentType = reader["EquipmentType"].ToString();
                        if (!string.IsNullOrWhiteSpace(equipmentType))
                        {
                            ddlEquipmentType.Items.Add(new ListItem(equipmentType, equipmentType));
                            count++;
                        }
                    }
                    Response.Write("<script>console.log('Loaded " + count + " equipment type values');</script>");
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error loading equipment types: " + ex.Message);
            Response.Write("<script>console.error('LoadEquipmentTypes Error: " + ex.Message.Replace("'", "\\'") + "');</script>");
        }
    }

    private void LoadEquipmentNames()
    {
        // Skip if already loaded (prevents duplicates on AutoPostBack)
        if (ViewState["DropdownsLoaded"] != null) return;

        var connStrObj = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"];
        string connStr = connStrObj != null ? connStrObj.ConnectionString : null;
        if (string.IsNullOrEmpty(connStr)) return;

        try
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                // Clear existing items except "All Equipment"
                ddlEquipmentName.Items.Clear();
                ddlEquipmentName.Items.Add(new ListItem("All Equipment", "ALL"));

                // Get unique equipment names from calibration table
                string query = @"SELECT DISTINCT [EquipmentName] as EquipmentName FROM dbo.Calibration_Log
                                WHERE [EquipmentName] IS NOT NULL AND [EquipmentName] <> ''
                                ORDER BY EquipmentName";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    int count = 0;
                    while (reader.Read())
                    {
                        string equipmentName = reader["EquipmentName"].ToString();
                        if (!string.IsNullOrWhiteSpace(equipmentName))
                        {
                            ddlEquipmentName.Items.Add(new ListItem(equipmentName, equipmentName));
                            count++;
                        }
                    }
                    Response.Write("<script>console.log('Loaded " + count + " equipment name values');</script>");
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error loading equipment names: " + ex.Message);
            Response.Write("<script>console.error('LoadEquipmentNames Error: " + ex.Message.Replace("'", "\\'") + "');</script>");
        }
    }

    private void LoadEquipmentEatonIDs()
    {
        // Skip if already loaded (prevents duplicates on AutoPostBack)
        if (ViewState["DropdownsLoaded"] != null) return;

        var connStrObj = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"];
        string connStr = connStrObj != null ? connStrObj.ConnectionString : null;
        if (string.IsNullOrEmpty(connStr)) return;

        try
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                // Clear existing items except "All Eaton IDs"
                ddlEquipmentEatonID.Items.Clear();
                ddlEquipmentEatonID.Items.Add(new ListItem("All Eaton IDs", "ALL"));

                // Get unique Eaton IDs from calibration table
                string query = @"SELECT DISTINCT [EquipmentEatonID] as EquipmentEatonID FROM dbo.Calibration_Log
                                WHERE [EquipmentEatonID] IS NOT NULL AND [EquipmentEatonID] <> ''
                                ORDER BY EquipmentEatonID";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    int count = 0;
                    while (reader.Read())
                    {
                        string eatonID = reader["EquipmentEatonID"].ToString();
                        if (!string.IsNullOrWhiteSpace(eatonID))
                        {
                            ddlEquipmentEatonID.Items.Add(new ListItem(eatonID, eatonID));
                            count++;
                        }
                    }
                    Response.Write("<script>console.log('Loaded " + count + " Eaton ID values');</script>");
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error loading Eaton IDs: " + ex.Message);
            Response.Write("<script>console.error('LoadEquipmentEatonIDs Error: " + ex.Message.Replace("'", "\\'") + "');</script>");
        }
    }

    private void LoadMethods()
    {
        // Skip if already loaded (prevents duplicates on AutoPostBack)
        if (ViewState["DropdownsLoaded"] != null) return;

        var connStrObj = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"];
        string connStr = connStrObj != null ? connStrObj.ConnectionString : null;
        if (string.IsNullOrEmpty(connStr)) return;

        try
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                // Clear existing items except "All Methods"
                ddlMethod.Items.Clear();
                ddlMethod.Items.Add(new ListItem("All Methods", "ALL"));

                // Get unique methods from calibration table
                string query = @"SELECT DISTINCT [Method] as Method FROM dbo.Calibration_Log
                                WHERE [Method] IS NOT NULL AND [Method] <> ''
                                ORDER BY Method";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    int count = 0;
                    while (reader.Read())
                    {
                        string method = reader["Method"].ToString();
                        if (!string.IsNullOrWhiteSpace(method))
                        {
                            ddlMethod.Items.Add(new ListItem(method, method));
                            count++;
                        }
                    }
                    Response.Write("<script>console.log('Loaded " + count + " method values');</script>");
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error loading methods: " + ex.Message);
            Response.Write("<script>console.error('LoadMethods Error: " + ex.Message.Replace("'", "\\'") + "');</script>");
        }
    }

    private void BindGrid()
    {
        var connStrObj = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"];
        string connStr = connStrObj != null ? connStrObj.ConnectionString : null;
        if (string.IsNullOrEmpty(connStr))
        {
            System.Diagnostics.Debug.WriteLine("ERROR: Connection string is null or empty");
            Response.Write("<script>console.error('CRITICAL: Connection string is null or empty');</script>");
            return;
        }

        try
        {
            DataTable dt = new DataTable();

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                System.Diagnostics.Debug.WriteLine("Database connection opened successfully");
                Response.Write("<script>console.log('BindGrid: Database connected');</script>");

                dt = GetCalibrationData(conn);
                System.Diagnostics.Debug.WriteLine(string.Format("GetCalibrationData returned {0} rows", dt.Rows.Count));
                Response.Write("<script>console.log('BindGrid: Got " + dt.Rows.Count + " rows from database');</script>");
            }

            // Apply filters
            DataView dv = dt.DefaultView;
            string filter = BuildFilterExpression();
            if (!string.IsNullOrEmpty(filter))
            {
                System.Diagnostics.Debug.WriteLine(string.Format("Applying filter: {0}", filter));
                Response.Write("<script>console.log('Applied filter: " + filter.Replace("'", "\\'") + "');</script>");
                dv.RowFilter = filter;
            }

            // Sort by CreateDate descending (most recent first)
            dv.Sort = "CreateDate DESC";

            System.Diagnostics.Debug.WriteLine(string.Format("After filtering and sorting: {0} rows", dv.Count));
            Response.Write("<script>console.log('After filtering and sorting: " + dv.Count + " rows');</script>");
            Response.Write("<script>console.info('✓ All records loaded - No pagination or row limits applied');</script>");
            litRecordCount.Text = dv.Count.ToString();

            if (dv.Count == 0)
            {
                System.Diagnostics.Debug.WriteLine("No records found - showing empty state");
                Response.Write("<script>console.warn('No records found - showing empty state');</script>");
                gridCalibration.Visible = false;
                pnlEmptyState.Visible = true;
            }
            else
            {
                System.Diagnostics.Debug.WriteLine("Building grid with data");
                Response.Write("<script>console.log('Building grid with " + dv.Count + " rows');</script>");
                gridCalibration.Visible = true;
                pnlEmptyState.Visible = false;

                // Clear and rebuild columns
                gridCalibration.Columns.Clear();
                BuildGridColumns();

                gridCalibration.DataSource = dv;
                gridCalibration.DataBind();
                System.Diagnostics.Debug.WriteLine("Grid data bound successfully");
                Response.Write("<script>console.log('Grid bound successfully!');</script>");
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine(string.Format("ERROR binding grid: {0}", ex.Message));
            System.Diagnostics.Debug.WriteLine(string.Format("Stack trace: {0}", ex.StackTrace));
            Response.Write("<script>console.error('BindGrid ERROR: " + ex.Message.Replace("'", "\\'") + "');</script>");
            Response.Write("<script>console.error('Stack: " + ex.StackTrace.Replace("'", "\\'").Replace("\r", "").Replace("\n", " ") + "');</script>");
            gridCalibration.Visible = false;
            pnlEmptyState.Visible = true;
        }
    }

    private DataTable GetCalibrationData(SqlConnection conn)
    {
        DataTable dt = new DataTable();

        // Define all columns for comprehensive view
        dt.Columns.Add("CalibrationID", typeof(string));
        dt.Columns.Add("CalibrationLogID", typeof(string));
        dt.Columns.Add("EquipmentType", typeof(string));
        dt.Columns.Add("EquipmentEatonID", typeof(string));
        dt.Columns.Add("EquipmentName", typeof(string));
        dt.Columns.Add("Method", typeof(string));
        dt.Columns.Add("PrevDueDate", typeof(DateTime));
        dt.Columns.Add("CalibrationDate", typeof(DateTime));
        dt.Columns.Add("Status", typeof(string));
        dt.Columns.Add("CalibratedBy", typeof(string));
        dt.Columns.Add("VendorName", typeof(string));
        dt.Columns.Add("Certificate", typeof(string));
        dt.Columns.Add("CalibrationStandard", typeof(string));
        dt.Columns.Add("Cost", typeof(decimal));
        dt.Columns.Add("ResultCode", typeof(string));
        dt.Columns.Add("CalibrationResults", typeof(string));
        dt.Columns.Add("StartDate", typeof(DateTime));
        dt.Columns.Add("SentOutDate", typeof(DateTime));
        dt.Columns.Add("ReceivedDate", typeof(DateTime));
        dt.Columns.Add("NextCalibration", typeof(DateTime));
        dt.Columns.Add("IsOnTime", typeof(bool));
        dt.Columns.Add("IsOutOfTolerance", typeof(bool));
        dt.Columns.Add("TurnaroundDays", typeof(int));
        dt.Columns.Add("VendorLeadDays", typeof(int));
        dt.Columns.Add("Comments", typeof(string));
        dt.Columns.Add("AttachmentsPath", typeof(string));
        dt.Columns.Add("CreateDate", typeof(DateTime));

        string query = @"SELECT
            ISNULL(CAST([CalibrationID] AS NVARCHAR),'') as CalibrationID,
            ISNULL([CalibrationLogID],'') as CalibrationLogID,
            ISNULL([EquipmentType],'') as EquipmentType,
            ISNULL([EquipmentEatonID],'') as EquipmentEatonID,
            ISNULL([EquipmentName],'') as EquipmentName,
            ISNULL([Method],'') as Method,
            [PrevDueDate] as PrevDueDate,
            [CalibrationDate] as CalibrationDate,
            ISNULL([Status],'') as Status,
            ISNULL([CalibrationBy],'') as CalibratedBy,
            ISNULL([VendorName],'') as VendorName,
            ISNULL([CalibrationCertificate],'') as Certificate,
            ISNULL([CalibrationStandard],'') as CalibrationStandard,
            ISNULL(CAST([Cost] AS DECIMAL(10,2)), 0) as Cost,
            ISNULL([ResultCode],'') as ResultCode,
            ISNULL([CalibrationResults],'') as CalibrationResults,
            [StartDate] as StartDate,
            [SentOutDate] as SentOutDate,
            [ReceivedDate] as ReceivedDate,
            [NextDueDate] as NextCalibration,
            ISNULL(CAST([IsOnTime] AS BIT), 0) as IsOnTime,
            ISNULL(CAST([IsOutOfTolerance] AS BIT), 0) as IsOutOfTolerance,
            ISNULL(CAST([TurnaroundDays] AS INT), 0) as TurnaroundDays,
            ISNULL(CAST([VendorLeadDays] AS INT), 0) as VendorLeadDays,
            ISNULL([Comments],'') as Comments,
            ISNULL([AttachmentsPath],'') as AttachmentsPath,
            [CreatedDate] as CreateDate
            FROM dbo.Calibration_Log";

        try
        {
            System.Diagnostics.Debug.WriteLine("Executing calibration query...");
            using (SqlCommand cmd = new SqlCommand(query, conn))
            using (SqlDataReader reader = cmd.ExecuteReader())
            {
                int rowCount = 0;
                while (reader.Read())
                {
                    rowCount++;
                    DataRow row = dt.NewRow();
                    row["CalibrationID"] = GetSafeValue(reader, "CalibrationID");
                    row["CalibrationLogID"] = GetSafeValue(reader, "CalibrationLogID");
                    row["EquipmentType"] = GetSafeValue(reader, "EquipmentType");
                    row["EquipmentEatonID"] = GetSafeValue(reader, "EquipmentEatonID");
                    row["EquipmentName"] = GetSafeValue(reader, "EquipmentName");
                    row["Method"] = GetSafeValue(reader, "Method");

                    if (!reader.IsDBNull(reader.GetOrdinal("PrevDueDate")))
                        row["PrevDueDate"] = reader.GetDateTime(reader.GetOrdinal("PrevDueDate"));
                    if (!reader.IsDBNull(reader.GetOrdinal("CalibrationDate")))
                        row["CalibrationDate"] = reader.GetDateTime(reader.GetOrdinal("CalibrationDate"));

                    row["Status"] = GetSafeValue(reader, "Status");
                    row["CalibratedBy"] = GetSafeValue(reader, "CalibratedBy");
                    row["VendorName"] = GetSafeValue(reader, "VendorName");
                    row["Certificate"] = GetSafeValue(reader, "Certificate");
                    row["CalibrationStandard"] = GetSafeValue(reader, "CalibrationStandard");
                    row["Cost"] = reader.GetDecimal(reader.GetOrdinal("Cost"));
                    row["ResultCode"] = GetSafeValue(reader, "ResultCode");
                    row["CalibrationResults"] = GetSafeValue(reader, "CalibrationResults");

                    if (!reader.IsDBNull(reader.GetOrdinal("StartDate")))
                        row["StartDate"] = reader.GetDateTime(reader.GetOrdinal("StartDate"));
                    if (!reader.IsDBNull(reader.GetOrdinal("SentOutDate")))
                        row["SentOutDate"] = reader.GetDateTime(reader.GetOrdinal("SentOutDate"));
                    if (!reader.IsDBNull(reader.GetOrdinal("ReceivedDate")))
                        row["ReceivedDate"] = reader.GetDateTime(reader.GetOrdinal("ReceivedDate"));
                    if (!reader.IsDBNull(reader.GetOrdinal("NextCalibration")))
                        row["NextCalibration"] = reader.GetDateTime(reader.GetOrdinal("NextCalibration"));

                    row["IsOnTime"] = reader.GetBoolean(reader.GetOrdinal("IsOnTime"));
                    row["IsOutOfTolerance"] = reader.GetBoolean(reader.GetOrdinal("IsOutOfTolerance"));
                    row["TurnaroundDays"] = reader.GetInt32(reader.GetOrdinal("TurnaroundDays"));
                    row["VendorLeadDays"] = reader.GetInt32(reader.GetOrdinal("VendorLeadDays"));
                    row["Comments"] = GetSafeValue(reader, "Comments");
                    row["AttachmentsPath"] = GetSafeValue(reader, "AttachmentsPath");

                    if (!reader.IsDBNull(reader.GetOrdinal("CreateDate")))
                        row["CreateDate"] = reader.GetDateTime(reader.GetOrdinal("CreateDate"));

                    dt.Rows.Add(row);
                }
                System.Diagnostics.Debug.WriteLine(string.Format("Loaded {0} calibration rows", rowCount));
                Response.Write("<script>console.log('GetCalibrationData: Loaded " + rowCount + " rows');</script>");
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine(string.Format("ERROR loading calibration data: {0}", ex.Message));
            System.Diagnostics.Debug.WriteLine(string.Format("Stack trace: {0}", ex.StackTrace));
            if (ex.InnerException != null)
            {
                System.Diagnostics.Debug.WriteLine(string.Format("Inner exception: {0}", ex.InnerException.Message));
            }
            Response.Write("<script>console.error('GetCalibrationData ERROR: " + ex.Message.Replace("'", "\\'") + "');</script>");
            Response.Write("<script>console.error('Query failed - check column names match database schema');</script>");
        }

        return dt;
    }

    private string GetSafeValue(SqlDataReader reader, string columnName)
    {
        try
        {
            int ordinal = reader.GetOrdinal(columnName);
            if (reader.IsDBNull(ordinal))
                return string.Empty;

            // Try to get as string first, if that fails, convert the value to string
            try
            {
                return reader.GetString(ordinal);
            }
            catch
            {
                // If it's not a string, get the value and convert it
                return reader.GetValue(ordinal).ToString();
            }
        }
        catch
        {
            return string.Empty;
        }
    }

    private string BuildFilterExpression()
    {
        var filters = new System.Collections.Generic.List<string>();

        // Search filter
        string search = txtSearch.Text.Trim();
        if (!string.IsNullOrEmpty(search))
        {
            string escapedSearch = search.Replace("'", "''");
            filters.Add(string.Format("(CalibrationLogID LIKE '%{0}%' OR EquipmentName LIKE '%{0}%' OR EquipmentEatonID LIKE '%{0}%' OR VendorName LIKE '%{0}%' OR CalibratedBy LIKE '%{0}%' OR Comments LIKE '%{0}%')", escapedSearch));
        }

        // Status filter
        if (ddlStatus.SelectedValue != "ALL")
        {
            string status = ddlStatus.SelectedValue.Replace("'", "''");
            filters.Add(string.Format("Status = '{0}'", status));
        }

        // Result Code filter
        if (ddlResultCode.SelectedValue != "ALL")
        {
            string resultCode = ddlResultCode.SelectedValue.Replace("'", "''");
            filters.Add(string.Format("ResultCode = '{0}'", resultCode));
        }

        // Method filter
        if (ddlMethod.SelectedValue != "ALL")
        {
            string method = ddlMethod.SelectedValue.Replace("'", "''");
            filters.Add(string.Format("Method = '{0}'", method));
        }

        // Vendor Name filter
        if (ddlVendorName.SelectedValue != "ALL")
        {
            string vendorName = ddlVendorName.SelectedValue.Replace("'", "''");
            filters.Add(string.Format("VendorName = '{0}'", vendorName));
        }

        // Equipment Type filter
        if (ddlEquipmentType.SelectedValue != "ALL")
        {
            string equipmentType = ddlEquipmentType.SelectedValue.Replace("'", "''");
            filters.Add(string.Format("EquipmentType = '{0}'", equipmentType));
        }

        // Equipment Name filter
        if (ddlEquipmentName.SelectedValue != "ALL")
        {
            string equipmentName = ddlEquipmentName.SelectedValue.Replace("'", "''");
            filters.Add(string.Format("EquipmentName = '{0}'", equipmentName));
        }

        // Equipment Eaton ID filter
        if (ddlEquipmentEatonID.SelectedValue != "ALL")
        {
            string eatonID = ddlEquipmentEatonID.SelectedValue.Replace("'", "''");
            filters.Add(string.Format("EquipmentEatonID = '{0}'", eatonID));
        }

        return string.Join(" AND ", filters);
    }

    private void BuildGridColumns()
    {
        // Clear existing columns
        gridCalibration.Columns.Clear();

        // 1. CalibrationLogID
        BoundField calibrationLogIDField = new BoundField();
        calibrationLogIDField.DataField = "CalibrationLogID";
        calibrationLogIDField.HeaderText = "CalibrationLogID";
        calibrationLogIDField.HeaderStyle.CssClass = "col-calibration-log-id";
        calibrationLogIDField.ItemStyle.CssClass = "col-calibration-log-id";
        gridCalibration.Columns.Add(calibrationLogIDField);

        // 2. Equipment Type
        BoundField equipmentTypeField = new BoundField();
        equipmentTypeField.DataField = "EquipmentType";
        equipmentTypeField.HeaderText = "Equipment Type";
        equipmentTypeField.HeaderStyle.CssClass = "col-equipment-type";
        equipmentTypeField.ItemStyle.CssClass = "col-equipment-type";
        gridCalibration.Columns.Add(equipmentTypeField);

        // 3. Equipment Eaton ID
        BoundField eatonIDField = new BoundField();
        eatonIDField.DataField = "EquipmentEatonID";
        eatonIDField.HeaderText = "Equipment Eaton ID";
        eatonIDField.HeaderStyle.CssClass = "col-equipment-eaton-id";
        eatonIDField.ItemStyle.CssClass = "col-equipment-eaton-id";
        gridCalibration.Columns.Add(eatonIDField);

        // 4. Equipment Name
        BoundField equipmentNameField = new BoundField();
        equipmentNameField.DataField = "EquipmentName";
        equipmentNameField.HeaderText = "Equipment Name";
        equipmentNameField.HeaderStyle.CssClass = "col-equipment-name";
        equipmentNameField.ItemStyle.CssClass = "col-equipment-name";
        gridCalibration.Columns.Add(equipmentNameField);

        // 5. Method
        BoundField methodField = new BoundField();
        methodField.DataField = "Method";
        methodField.HeaderText = "Method";
        methodField.HeaderStyle.CssClass = "col-method";
        methodField.ItemStyle.CssClass = "col-method";
        gridCalibration.Columns.Add(methodField);

        // 6. Prev Due Date
        BoundField prevDueDateField = new BoundField();
        prevDueDateField.DataField = "PrevDueDate";
        prevDueDateField.HeaderText = "Prev Due Date";
        prevDueDateField.DataFormatString = "{0:MM/dd/yyyy}";
        prevDueDateField.HeaderStyle.CssClass = "col-prev-due-date";
        prevDueDateField.ItemStyle.CssClass = "col-prev-due-date date-cell";
        gridCalibration.Columns.Add(prevDueDateField);

        // 7. Calibration Date
        BoundField calibrationDateField = new BoundField();
        calibrationDateField.DataField = "CalibrationDate";
        calibrationDateField.HeaderText = "Calibration Date";
        calibrationDateField.DataFormatString = "{0:MM/dd/yyyy}";
        calibrationDateField.HeaderStyle.CssClass = "col-calibration-date";
        calibrationDateField.ItemStyle.CssClass = "col-calibration-date date-cell";
        gridCalibration.Columns.Add(calibrationDateField);

        // 8. Status
        BoundField statusField = new BoundField();
        statusField.DataField = "Status";
        statusField.HeaderText = "Status";
        statusField.HeaderStyle.CssClass = "col-status";
        statusField.ItemStyle.CssClass = "col-status";
        gridCalibration.Columns.Add(statusField);

        // 9. Calibrated By
        BoundField calibratedByField = new BoundField();
        calibratedByField.DataField = "CalibratedBy";
        calibratedByField.HeaderText = "Calibrated By";
        calibratedByField.HeaderStyle.CssClass = "col-calibration-by";
        calibratedByField.ItemStyle.CssClass = "col-calibration-by";
        gridCalibration.Columns.Add(calibratedByField);

        // 10. Vendor Name
        BoundField vendorNameField = new BoundField();
        vendorNameField.DataField = "VendorName";
        vendorNameField.HeaderText = "Vendor Name";
        vendorNameField.HeaderStyle.CssClass = "col-vendor-name";
        vendorNameField.ItemStyle.CssClass = "col-vendor-name";
        gridCalibration.Columns.Add(vendorNameField);

        // 11. Certificate #
        BoundField certificateField = new BoundField();
        certificateField.DataField = "Certificate";
        certificateField.HeaderText = "Certificate #";
        certificateField.HeaderStyle.CssClass = "col-calibration-certificate";
        certificateField.ItemStyle.CssClass = "col-calibration-certificate";
        gridCalibration.Columns.Add(certificateField);

        // 12. Calibration Standard
        BoundField calibrationStandardField = new BoundField();
        calibrationStandardField.DataField = "CalibrationStandard";
        calibrationStandardField.HeaderText = "Calibration Standard";
        calibrationStandardField.HeaderStyle.CssClass = "col-calibration-standard";
        calibrationStandardField.ItemStyle.CssClass = "col-calibration-standard";
        gridCalibration.Columns.Add(calibrationStandardField);

        // 13. Cost
        BoundField costField = new BoundField();
        costField.DataField = "Cost";
        costField.HeaderText = "Cost";
        costField.DataFormatString = "{0:C}";
        costField.HeaderStyle.CssClass = "col-cost";
        costField.ItemStyle.CssClass = "col-cost";
        gridCalibration.Columns.Add(costField);

        // 14. Result Code
        BoundField resultCodeField = new BoundField();
        resultCodeField.DataField = "ResultCode";
        resultCodeField.HeaderText = "Result Code";
        resultCodeField.HeaderStyle.CssClass = "col-result-code";
        resultCodeField.ItemStyle.CssClass = "col-result-code";
        gridCalibration.Columns.Add(resultCodeField);

        // 15. Calibration Results
        BoundField calibrationResultsField = new BoundField();
        calibrationResultsField.DataField = "CalibrationResults";
        calibrationResultsField.HeaderText = "Calibration Results";
        calibrationResultsField.HeaderStyle.CssClass = "col-calibration-results";
        calibrationResultsField.ItemStyle.CssClass = "col-calibration-results";
        gridCalibration.Columns.Add(calibrationResultsField);

        // 16. Start Date
        BoundField startDateField = new BoundField();
        startDateField.DataField = "StartDate";
        startDateField.HeaderText = "Start Date";
        startDateField.DataFormatString = "{0:MM/dd/yyyy}";
        startDateField.HeaderStyle.CssClass = "col-start-date";
        startDateField.ItemStyle.CssClass = "col-start-date date-cell";
        gridCalibration.Columns.Add(startDateField);

        // 17. Sent Out Date
        BoundField sentOutDateField = new BoundField();
        sentOutDateField.DataField = "SentOutDate";
        sentOutDateField.HeaderText = "Sent Out Date";
        sentOutDateField.DataFormatString = "{0:MM/dd/yyyy}";
        sentOutDateField.HeaderStyle.CssClass = "col-sent-out-date";
        sentOutDateField.ItemStyle.CssClass = "col-sent-out-date date-cell";
        gridCalibration.Columns.Add(sentOutDateField);

        // 18. Received Date
        BoundField receivedDateField = new BoundField();
        receivedDateField.DataField = "ReceivedDate";
        receivedDateField.HeaderText = "Received Date";
        receivedDateField.DataFormatString = "{0:MM/dd/yyyy}";
        receivedDateField.HeaderStyle.CssClass = "col-received-date";
        receivedDateField.ItemStyle.CssClass = "col-received-date date-cell";
        gridCalibration.Columns.Add(receivedDateField);

        // 19. Next Calibration
        BoundField nextCalibrationField = new BoundField();
        nextCalibrationField.DataField = "NextCalibration";
        nextCalibrationField.HeaderText = "Next Calibration";
        nextCalibrationField.DataFormatString = "{0:MM/dd/yyyy}";
        nextCalibrationField.HeaderStyle.CssClass = "col-next-due-date";
        nextCalibrationField.ItemStyle.CssClass = "col-next-due-date date-cell";
        gridCalibration.Columns.Add(nextCalibrationField);

        // 20. Is On Time
        BoundField isOnTimeField = new BoundField();
        isOnTimeField.DataField = "IsOnTime";
        isOnTimeField.HeaderText = "Is On Time";
        isOnTimeField.HeaderStyle.CssClass = "col-is-on-time";
        isOnTimeField.ItemStyle.CssClass = "col-is-on-time";
        gridCalibration.Columns.Add(isOnTimeField);

        // 21. Is Out Of Tolerance
        BoundField isOutOfToleranceField = new BoundField();
        isOutOfToleranceField.DataField = "IsOutOfTolerance";
        isOutOfToleranceField.HeaderText = "Is Out Of Tolerance";
        isOutOfToleranceField.HeaderStyle.CssClass = "col-is-out-of-tolerance";
        isOutOfToleranceField.ItemStyle.CssClass = "col-is-out-of-tolerance";
        gridCalibration.Columns.Add(isOutOfToleranceField);

        // 22. Turnaround Days
        BoundField turnaroundDaysField = new BoundField();
        turnaroundDaysField.DataField = "TurnaroundDays";
        turnaroundDaysField.HeaderText = "Turnaround Days";
        turnaroundDaysField.HeaderStyle.CssClass = "col-turnaround-days";
        turnaroundDaysField.ItemStyle.CssClass = "col-turnaround-days";
        gridCalibration.Columns.Add(turnaroundDaysField);

        // 23. Vendor Lead Days
        BoundField vendorLeadDaysField = new BoundField();
        vendorLeadDaysField.DataField = "VendorLeadDays";
        vendorLeadDaysField.HeaderText = "Vendor Lead Days";
        vendorLeadDaysField.HeaderStyle.CssClass = "col-vendor-lead-days";
        vendorLeadDaysField.ItemStyle.CssClass = "col-vendor-lead-days";
        gridCalibration.Columns.Add(vendorLeadDaysField);

        // 24. Comments
        BoundField commentsField = new BoundField();
        commentsField.DataField = "Comments";
        commentsField.HeaderText = "Comments";
        commentsField.HeaderStyle.CssClass = "col-comments";
        commentsField.ItemStyle.CssClass = "col-comments";
        gridCalibration.Columns.Add(commentsField);

        // 25. Attachments Path
        BoundField attachmentsPathField = new BoundField();
        attachmentsPathField.DataField = "AttachmentsPath";
        attachmentsPathField.HeaderText = "Attachments Path";
        attachmentsPathField.HeaderStyle.CssClass = "col-attachments-path";
        attachmentsPathField.ItemStyle.CssClass = "col-attachments-path";
        gridCalibration.Columns.Add(attachmentsPathField);
    }

    protected void gridCalibration_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        // Style headers to match table size - FORCE SMALL HEADERS
        if (e.Row.RowType == DataControlRowType.Header)
        {
            e.Row.CssClass = "grid-header-row"; // Add CSS class for targeting
            e.Row.Height = System.Web.UI.WebControls.Unit.Pixel(28);
            e.Row.BackColor = System.Drawing.ColorTranslator.FromHtml("#0b63ce");
            e.Row.ForeColor = System.Drawing.Color.White;
            e.Row.Font.Bold = true;
            e.Row.Font.Size = FontUnit.Point(9); // CHANGED FROM 10 to 9
            e.Row.Style["height"] = "28px !important";
            e.Row.Style["font-size"] = "9px !important";
            e.Row.Style["line-height"] = "1.2 !important";

            for (int i = 0; i < e.Row.Cells.Count; i++)
            {
                TableCell cell = e.Row.Cells[i];
                cell.Style["padding"] = "6px 8px !important";
                cell.Style["text-align"] = "center !important"; // CENTER ALIGN
                cell.Style["border-bottom"] = "2px solid #0a58b8";
                cell.Style["height"] = "28px !important";
                cell.Style["font-size"] = "9px !important";
                cell.Style["line-height"] = "1.2 !important";
                cell.Style["max-height"] = "28px !important";
                cell.Style["min-height"] = "28px !important";
                cell.Style["overflow"] = "hidden !important";
                cell.Style["text-overflow"] = "ellipsis !important";
                cell.Style["white-space"] = "nowrap !important";
                cell.Style["box-shadow"] = "0 2px 8px rgba(0,0,0,.15) !important";
            }
        }

        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            DataRowView drv = e.Row.DataItem as DataRowView;
            if (drv != null)
            {
                // Add hover tooltips for all cells - using correct data field mapping
                // Column 0: CalibrationLogID
                if (e.Row.Cells.Count > 0)
                {
                    string calibrationLogID = drv["CalibrationLogID"].ToString();
                    if (!string.IsNullOrEmpty(calibrationLogID))
                    {
                        e.Row.Cells[0].ToolTip = calibrationLogID;
                        e.Row.Cells[0].Attributes["title"] = calibrationLogID;
                    }
                }

                // Column 1: EquipmentType
                if (e.Row.Cells.Count > 1)
                {
                    string equipmentType = drv["EquipmentType"].ToString();
                    if (!string.IsNullOrEmpty(equipmentType))
                    {
                        e.Row.Cells[1].ToolTip = equipmentType;
                        e.Row.Cells[1].Attributes["title"] = equipmentType;
                    }
                }

                // Column 2: EquipmentEatonID
                if (e.Row.Cells.Count > 2)
                {
                    string equipmentEatonID = drv["EquipmentEatonID"].ToString();
                    if (!string.IsNullOrEmpty(equipmentEatonID))
                    {
                        e.Row.Cells[2].ToolTip = equipmentEatonID;
                        e.Row.Cells[2].Attributes["title"] = equipmentEatonID;
                    }
                }

                // Column 3: EquipmentName
                if (e.Row.Cells.Count > 3)
                {
                    string equipmentName = drv["EquipmentName"].ToString();
                    if (!string.IsNullOrEmpty(equipmentName))
                    {
                        e.Row.Cells[3].ToolTip = equipmentName;
                        e.Row.Cells[3].Attributes["title"] = equipmentName;
                    }
                }

                // Column 4: Method
                if (e.Row.Cells.Count > 4)
                {
                    string method = drv["Method"].ToString();
                    if (!string.IsNullOrEmpty(method))
                    {
                        e.Row.Cells[4].ToolTip = method;
                        e.Row.Cells[4].Attributes["title"] = method;
                    }
                }

                // Column 5: PrevDueDate
                if (e.Row.Cells.Count > 5)
                {
                    string prevDueDate = drv["PrevDueDate"].ToString();
                    if (!string.IsNullOrEmpty(prevDueDate) && prevDueDate != "01/01/1900 12:00:00 AM")
                    {
                        e.Row.Cells[5].ToolTip = prevDueDate;
                        e.Row.Cells[5].Attributes["title"] = prevDueDate;
                    }
                }

                // Column 6: CalibrationDate
                if (e.Row.Cells.Count > 6)
                {
                    string calibrationDate = drv["CalibrationDate"].ToString();
                    if (!string.IsNullOrEmpty(calibrationDate) && calibrationDate != "01/01/1900 12:00:00 AM")
                    {
                        e.Row.Cells[6].ToolTip = calibrationDate;
                        e.Row.Cells[6].Attributes["title"] = calibrationDate;
                    }
                }

                // Column 7: Status
                if (e.Row.Cells.Count > 7)
                {
                    string status = drv["Status"].ToString();
                    if (!string.IsNullOrEmpty(status))
                    {
                        e.Row.Cells[7].ToolTip = status;
                        e.Row.Cells[7].Attributes["title"] = status;
                    }
                }

                // Column 8: CalibratedBy
                if (e.Row.Cells.Count > 8)
                {
                    string calibratedBy = drv["CalibratedBy"].ToString();
                    if (!string.IsNullOrEmpty(calibratedBy))
                    {
                        e.Row.Cells[8].ToolTip = calibratedBy;
                        e.Row.Cells[8].Attributes["title"] = calibratedBy;
                    }
                }

                // Column 9: VendorName
                if (e.Row.Cells.Count > 9)
                {
                    string vendorName = drv["VendorName"].ToString();
                    if (!string.IsNullOrEmpty(vendorName))
                    {
                        e.Row.Cells[9].ToolTip = vendorName;
                        e.Row.Cells[9].Attributes["title"] = vendorName;
                    }
                }

                // Column 10: Certificate
                if (e.Row.Cells.Count > 10)
                {
                    string certificate = drv["Certificate"].ToString();
                    if (!string.IsNullOrEmpty(certificate))
                    {
                        e.Row.Cells[10].ToolTip = certificate;
                        e.Row.Cells[10].Attributes["title"] = certificate;
                    }
                }

                // Column 11: CalibrationStandard
                if (e.Row.Cells.Count > 11)
                {
                    string calibrationStandard = drv["CalibrationStandard"].ToString();
                    if (!string.IsNullOrEmpty(calibrationStandard))
                    {
                        e.Row.Cells[11].ToolTip = calibrationStandard;
                        e.Row.Cells[11].Attributes["title"] = calibrationStandard;
                    }
                }

                // Column 12: Cost
                if (e.Row.Cells.Count > 12)
                {
                    string cost = drv["Cost"].ToString();
                    if (!string.IsNullOrEmpty(cost))
                    {
                        e.Row.Cells[12].ToolTip = cost;
                        e.Row.Cells[12].Attributes["title"] = cost;
                    }
                }

                // Column 13: ResultCode
                if (e.Row.Cells.Count > 13)
                {
                    string resultCode = drv["ResultCode"].ToString();
                    if (!string.IsNullOrEmpty(resultCode))
                    {
                        e.Row.Cells[13].ToolTip = resultCode;
                        e.Row.Cells[13].Attributes["title"] = resultCode;
                    }
                }

                // Column 14: CalibrationResults
                if (e.Row.Cells.Count > 14)
                {
                    string calibrationResults = drv["CalibrationResults"].ToString();
                    if (!string.IsNullOrEmpty(calibrationResults))
                    {
                        e.Row.Cells[14].ToolTip = calibrationResults;
                        e.Row.Cells[14].Attributes["title"] = calibrationResults;
                    }
                }

                // Column 15: StartDate
                if (e.Row.Cells.Count > 15)
                {
                    string startDate = drv["StartDate"].ToString();
                    if (!string.IsNullOrEmpty(startDate) && startDate != "01/01/1900 12:00:00 AM")
                    {
                        e.Row.Cells[15].ToolTip = startDate;
                        e.Row.Cells[15].Attributes["title"] = startDate;
                    }
                }

                // Column 16: SentOutDate
                if (e.Row.Cells.Count > 16)
                {
                    string sentOutDate = drv["SentOutDate"].ToString();
                    if (!string.IsNullOrEmpty(sentOutDate) && sentOutDate != "01/01/1900 12:00:00 AM")
                    {
                        e.Row.Cells[16].ToolTip = sentOutDate;
                        e.Row.Cells[16].Attributes["title"] = sentOutDate;
                    }
                }

                // Column 17: ReceivedDate
                if (e.Row.Cells.Count > 17)
                {
                    string receivedDate = drv["ReceivedDate"].ToString();
                    if (!string.IsNullOrEmpty(receivedDate) && receivedDate != "01/01/1900 12:00:00 AM")
                    {
                        e.Row.Cells[17].ToolTip = receivedDate;
                        e.Row.Cells[17].Attributes["title"] = receivedDate;
                    }
                }

                // Column 18: NextCalibration
                if (e.Row.Cells.Count > 18)
                {
                    string nextCalibration = drv["NextCalibration"].ToString();
                    if (!string.IsNullOrEmpty(nextCalibration) && nextCalibration != "01/01/1900 12:00:00 AM")
                    {
                        e.Row.Cells[18].ToolTip = nextCalibration;
                        e.Row.Cells[18].Attributes["title"] = nextCalibration;
                    }
                }

                // Column 21: TurnaroundDays
                if (e.Row.Cells.Count > 21)
                {
                    string turnaroundDays = drv["TurnaroundDays"].ToString();
                    if (!string.IsNullOrEmpty(turnaroundDays))
                    {
                        e.Row.Cells[21].ToolTip = turnaroundDays;
                        e.Row.Cells[21].Attributes["title"] = turnaroundDays;
                    }
                }

                // Column 22: VendorLeadDays
                if (e.Row.Cells.Count > 22)
                {
                    string vendorLeadDays = drv["VendorLeadDays"].ToString();
                    if (!string.IsNullOrEmpty(vendorLeadDays))
                    {
                        e.Row.Cells[22].ToolTip = vendorLeadDays;
                        e.Row.Cells[22].Attributes["title"] = vendorLeadDays;
                    }
                }

                // Column 23: Comments
                if (e.Row.Cells.Count > 23)
                {
                    string comments = drv["Comments"].ToString();
                    if (!string.IsNullOrEmpty(comments))
                    {
                        e.Row.Cells[23].ToolTip = comments;
                        e.Row.Cells[23].Attributes["title"] = comments;
                    }
                }

                // Apply background colors for specific columns using badge spans instead of cell classes
                // Equipment Type (Column 1)
                if (e.Row.Cells.Count > 1)
                {
                    string equipmentType = drv["EquipmentType"].ToString();
                    if (!string.IsNullOrEmpty(equipmentType))
                    {
                        string equipmentTypeClass = "type-" + equipmentType.ToLower()
                            .Replace(" ", "-")
                            .Replace("_", "-")
                            .Replace("/", "-")
                            .Replace("(", "")
                            .Replace(")", "");
                        string equipmentTypeBadge = string.Format("<span class='{0}' title='{1}'>{1}</span>", equipmentTypeClass, equipmentType);
                        e.Row.Cells[1].Text = equipmentTypeBadge;
                    }
                }

                // Status (Column 7)
                if (e.Row.Cells.Count > 7)
                {
                    string status = drv["Status"].ToString();
                    if (!string.IsNullOrEmpty(status))
                    {
                        string statusClass = "status-" + status.ToLower()
                            .Replace(" ", "-")
                            .Replace("_", "-")
                            .Replace("/", "-")
                            .Replace("(", "")
                            .Replace(")", "");
                        string statusBadge = string.Format("<span class='status-badge {0}' title='{1}'>{1}</span>", statusClass, status);
                        e.Row.Cells[7].Text = statusBadge;
                    }
                }

                // Method (Column 4)
                if (e.Row.Cells.Count > 4)
                {
                    string method = drv["Method"].ToString();
                    if (!string.IsNullOrEmpty(method))
                    {
                        string methodClass = "method-" + method.ToLower()
                            .Replace(" ", "-")
                            .Replace("_", "-")
                            .Replace("/", "-")
                            .Replace("(", "")
                            .Replace(")", "");
                        string methodBadge = string.Format("<span class='{0}' title='{1}'>{1}</span>", methodClass, method);
                        e.Row.Cells[4].Text = methodBadge;
                    }
                }

                // Is On Time toggle (Column 19)
                if (e.Row.Cells.Count > 19)
                {
                    bool isOnTime = false;
                    bool.TryParse(drv["IsOnTime"].ToString(), out isOnTime);
                    string toggleClass = isOnTime ? "toggle-on" : "toggle-off";
                    string title = isOnTime ? "Yes" : "No";
                    e.Row.Cells[19].Text = string.Format("<div class='toggle-switch {0}' title='{1}'><div class='toggle-slider'></div></div>", toggleClass, title);
                    e.Row.Cells[19].ToolTip = title;
                    e.Row.Cells[19].Attributes["title"] = title;
                }

                // Is Out Of Tolerance toggle (Column 20)
                if (e.Row.Cells.Count > 20)
                {
                    bool isOutOfTolerance = false;
                    bool.TryParse(drv["IsOutOfTolerance"].ToString(), out isOutOfTolerance);
                    string toggleClass = isOutOfTolerance ? "toggle-off" : "toggle-on";
                    string title = isOutOfTolerance ? "No" : "Yes";
                    e.Row.Cells[20].Text = string.Format("<div class='toggle-switch {0}' title='{1}'><div class='toggle-slider'></div></div>", toggleClass, title);
                    e.Row.Cells[20].ToolTip = title;
                    e.Row.Cells[20].Attributes["title"] = title;
                }

                // Make Attachments Path clickable (Column 24)
                if (e.Row.Cells.Count > 24)
                {
                    string attachmentsPath = drv["AttachmentsPath"].ToString();
                    if (!string.IsNullOrEmpty(attachmentsPath))
                    {
                        // Handle multiple files separated by commas - take the first file path
                        string firstFilePath = attachmentsPath.Split(',')[0].Trim();

                        // Extract folder path from the first file path
                        // Format: "Storage/Calibration Logs/{ID}_{EatonID}/filename.ext"
                        string folderPath = "";
                        if (firstFilePath.Contains("/"))
                        {
                            // Get the folder part (everything up to the last /)
                            int lastSlashIndex = firstFilePath.LastIndexOf("/");
                            if (lastSlashIndex > 0)
                            {
                                folderPath = firstFilePath.Substring(0, lastSlashIndex);
                            }
                        }

                        if (string.IsNullOrEmpty(folderPath))
                        {
                            // Fallback: construct from CalibrationLogID and EquipmentEatonID
                            string calibrationLogId = drv["CalibrationLogID"].ToString();
                            string eatonID = drv["EquipmentEatonID"].ToString().Trim();
                            // Clean up EatonID string - remove extra spaces and special characters
                            eatonID = System.Text.RegularExpressions.Regex.Replace(eatonID, @"\s+", " ");
                            eatonID = eatonID.Replace("/", "-").Replace("\\", "-").Replace(":", "-");
                            folderPath = string.Format("Storage/Calibration Logs/{0}_{1}", calibrationLogId, eatonID);
                        }

                        string appPath = ResolveUrl("~/");
                        string fullUrl = appPath + folderPath;
                        string displayName = folderPath.Replace("Storage/Calibration Logs/", "");

                        // Count total files for display
                        string[] allFiles = attachmentsPath.Split(',');
                        string linkText = allFiles.Length == 1 ? displayName : string.Format("{0} (+{1} more)", displayName, allFiles.Length - 1);

                        e.Row.Cells[24].Text = string.Format("<a href='{0}' target='_blank' class='attachment-link' title='Open calibration folder'>{1}</a>", fullUrl, linkText);
                    }
                }
            }
        }
    }

    protected void ApplyFilters(object sender, EventArgs e)
    {
        BindGrid();
        // Update filter count and row highlighting after page loads
        ScriptManager.RegisterStartupScript(this, GetType(), "updateFilters", "setTimeout(function() { updateFilterCount(); initializeRowHighlighting(); }, 300);", true);
    }

    protected void ResetFilters(object sender, EventArgs e)
    {
        txtSearch.Text = string.Empty;
        ddlStatus.SelectedValue = "ALL";
        ddlResultCode.SelectedValue = "ALL";
        ddlMethod.SelectedValue = "ALL";
        ddlVendorName.SelectedValue = "ALL";
        ddlEquipmentType.SelectedValue = "ALL";
        ddlEquipmentName.SelectedValue = "ALL";
        ddlEquipmentEatonID.SelectedValue = "ALL";

        // Clear ViewState to allow reloading dropdowns
        ViewState["DropdownsLoaded"] = null;

        LoadData();

        // Set ViewState back after loading
        ViewState["DropdownsLoaded"] = true;

        // Update filter count and row highlighting after reset
        ScriptManager.RegisterStartupScript(this, GetType(), "resetFilters", "setTimeout(function() { updateFilterCount(); initializeRowHighlighting(); }, 300);", true);
    }

    private string GetCellText(TableCell cell)
    {
        string cellText = cell.Text.Replace(",", ";").Replace("&nbsp;", "");
        // Remove HTML tags
        cellText = System.Text.RegularExpressions.Regex.Replace(cellText, "<.*?>", string.Empty);
        return cellText;
    }

    protected void ExportToCSV(object sender, EventArgs e)
    {
        try
        {
            StringBuilder csv = new StringBuilder();

            // Headers - Updated to match new column order
            csv.AppendLine("CalibrationLogID,Equipment Type,Equipment Eaton ID,Equipment Name,Method,Prev Due Date,Calibration Date,Status,Calibrated By,Vendor Name,Certificate #,Calibration Standard,Cost,Result Code,Calibration Results,Start Date,Sent Out Date,Received Date,Next Calibration,Is On Time,Is Out Of Tolerance,Turnaround Days,Vendor Lead Days,Comments,Attachments Path");

            // Data - Updated to match new column order
            foreach (GridViewRow row in gridCalibration.Rows)
            {
                if (row.RowType == DataControlRowType.DataRow)
                {
                    var cells = new string[25]; // Updated count
                    // Map to the new column order
                    cells[0] = GetCellText(row.Cells[0]); // CalibrationLogID
                    cells[1] = GetCellText(row.Cells[1]); // Equipment Type
                    cells[2] = GetCellText(row.Cells[2]); // Equipment Eaton ID
                    cells[3] = GetCellText(row.Cells[3]); // Equipment Name
                    cells[4] = GetCellText(row.Cells[4]); // Method
                    cells[5] = GetCellText(row.Cells[5]); // Prev Due Date
                    cells[6] = GetCellText(row.Cells[6]); // Calibration Date
                    cells[7] = GetCellText(row.Cells[7]); // Status
                    cells[8] = GetCellText(row.Cells[8]); // Calibrated By
                    cells[9] = GetCellText(row.Cells[9]); // Vendor Name
                    cells[10] = GetCellText(row.Cells[10]); // Certificate #
                    cells[11] = GetCellText(row.Cells[11]); // Calibration Standard
                    cells[12] = GetCellText(row.Cells[12]); // Cost
                    cells[13] = GetCellText(row.Cells[13]); // Result Code
                    cells[14] = GetCellText(row.Cells[14]); // Calibration Results
                    cells[15] = GetCellText(row.Cells[15]); // Start Date
                    cells[16] = GetCellText(row.Cells[16]); // Sent Out Date
                    cells[17] = GetCellText(row.Cells[17]); // Received Date
                    cells[18] = GetCellText(row.Cells[18]); // Next Calibration
                    cells[19] = GetCellText(row.Cells[19]); // Is On Time
                    cells[20] = GetCellText(row.Cells[20]); // Is Out Of Tolerance
                    cells[21] = GetCellText(row.Cells[21]); // Turnaround Days
                    cells[22] = GetCellText(row.Cells[22]); // Vendor Lead Days
                    cells[23] = GetCellText(row.Cells[23]); // Comments
                    cells[24] = GetCellText(row.Cells[24]); // Attachments Path

                    csv.AppendLine(string.Join(",", cells));
                }
            }

            // Send to client
            Response.Clear();
            Response.Buffer = true;
            Response.AddHeader("content-disposition", string.Format("attachment;filename=CalibrationLogs_{0}.csv", DateTime.Now.ToString("yyyyMMdd")));
            Response.Charset = "";
            Response.ContentType = "application/text";
            Response.Output.Write(csv.ToString());
            Response.Flush();
            Response.End();
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error exporting CSV: " + ex.Message);
        }
    }
}