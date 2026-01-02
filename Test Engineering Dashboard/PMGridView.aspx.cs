using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

// Last Modified: October 23, 2025 - 01:00 UTC - PM Logs Grid View
public partial class TED_PMGridView : Page
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
            // On postback, re-initialize row highlighting
            ScriptManager.RegisterStartupScript(this, GetType(), "initRows", "setTimeout(function() { initializeRowHighlighting(); }, 100);", true);
        }
    }

    private void LoadData()
    {
        try
        {
            LoadStatus();
            LoadPMTypes();
            LoadPerformedBy();
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

                // Get unique statuses from PM table
                string query = @"SELECT DISTINCT [Status] as Status FROM dbo.PM_Log
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

    private void LoadPMTypes()
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
                ddlPMType.Items.Clear();
                ddlPMType.Items.Add(new ListItem("All Types", "ALL"));

                // Get unique PM types from PM table
                string query = @"SELECT DISTINCT [PMType] as PMType FROM dbo.PM_Log
                                WHERE [PMType] IS NOT NULL AND [PMType] <> ''
                                ORDER BY PMType";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    int count = 0;
                    while (reader.Read())
                    {
                        string pmType = reader["PMType"].ToString();
                        if (!string.IsNullOrWhiteSpace(pmType))
                        {
                            ddlPMType.Items.Add(new ListItem(pmType, pmType));
                            count++;
                        }
                    }
                    Response.Write("<script>console.log('Loaded " + count + " PM type values');</script>");
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error loading PM types: " + ex.Message);
            Response.Write("<script>console.error('LoadPMTypes Error: " + ex.Message.Replace("'", "\\'") + "');</script>");
        }
    }

    private void LoadPerformedBy()
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

                // Clear existing items except "All Performers"
                ddlPerformedBy.Items.Clear();
                ddlPerformedBy.Items.Add(new ListItem("All Performers", "ALL"));

                string query = @"SELECT DISTINCT [PerformedBy] FROM dbo.PM_Log
                                WHERE [PerformedBy] IS NOT NULL AND [PerformedBy] <> ''
                                ORDER BY [PerformedBy]";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string performer = reader["PerformedBy"].ToString();
                        if (!string.IsNullOrWhiteSpace(performer))
                        {
                            ddlPerformedBy.Items.Add(new ListItem(performer, performer));
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error loading performers: " + ex.Message);
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

                string query = @"SELECT DISTINCT [EquipmentType] FROM dbo.PM_Log
                                WHERE [EquipmentType] IS NOT NULL AND [EquipmentType] <> ''
                                ORDER BY [EquipmentType]";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string equipType = reader["EquipmentType"].ToString();
                        if (!string.IsNullOrWhiteSpace(equipType))
                        {
                            ddlEquipmentType.Items.Add(new ListItem(equipType, equipType));
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error loading equipment types: " + ex.Message);
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

                string query = @"SELECT DISTINCT [EquipmentName] FROM dbo.PM_Log
                                WHERE [EquipmentName] IS NOT NULL AND [EquipmentName] <> ''
                                ORDER BY [EquipmentName]";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string equipName = reader["EquipmentName"].ToString();
                        if (!string.IsNullOrWhiteSpace(equipName))
                        {
                            ddlEquipmentName.Items.Add(new ListItem(equipName, equipName));
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error loading equipment names: " + ex.Message);
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

                string query = @"SELECT DISTINCT [EquipmentEatonID] FROM dbo.PM_Log
                                WHERE [EquipmentEatonID] IS NOT NULL AND [EquipmentEatonID] <> ''
                                ORDER BY [EquipmentEatonID]";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string eatonId = reader["EquipmentEatonID"].ToString();
                        if (!string.IsNullOrWhiteSpace(eatonId))
                        {
                            ddlEquipmentEatonID.Items.Add(new ListItem(eatonId, eatonId));
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error loading equipment Eaton IDs: " + ex.Message);
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

                dt = GetPMData(conn);
                System.Diagnostics.Debug.WriteLine(string.Format("GetPMData returned {0} rows", dt.Rows.Count));
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

            // Sort by CreatedDate descending (most recent first)
            dv.Sort = "CreatedDate DESC";

            System.Diagnostics.Debug.WriteLine(string.Format("After filtering and sorting: {0} rows", dv.Count));
            Response.Write("<script>console.log('After filtering and sorting: " + dv.Count + " rows');</script>");
            Response.Write("<script>console.info('✓ All records loaded - No pagination or row limits applied');</script>");
            litRecordCount.Text = dv.Count.ToString();

            if (dv.Count == 0)
            {
                System.Diagnostics.Debug.WriteLine("No records found - showing empty state");
                Response.Write("<script>console.warn('No records found - showing empty state');</script>");
                gridPM.Visible = false;
                pnlEmptyState.Visible = true;
            }
            else
            {
                System.Diagnostics.Debug.WriteLine("Building grid with data");
                Response.Write("<script>console.log('Building grid with " + dv.Count + " rows');</script>");
                gridPM.Visible = true;
                pnlEmptyState.Visible = false;

                // Clear and rebuild columns
                gridPM.Columns.Clear();
                BuildGridColumns();

                gridPM.DataSource = dv;
                gridPM.DataBind();
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
            gridPM.Visible = false;
            pnlEmptyState.Visible = true;
        }
    }

    private DataTable GetPMData(SqlConnection conn)
    {
        DataTable dt = new DataTable();

        // Define all columns for comprehensive view
        dt.Columns.Add("PMID", typeof(string));
        dt.Columns.Add("EquipmentName", typeof(string));
        dt.Columns.Add("EquipmentEatonID", typeof(string));
        dt.Columns.Add("ScheduledDate", typeof(DateTime));
        dt.Columns.Add("PMDate", typeof(DateTime));
        dt.Columns.Add("IsOnTime", typeof(bool));
        dt.Columns.Add("NextPMDate", typeof(DateTime));
        dt.Columns.Add("PMType", typeof(string));
        dt.Columns.Add("MaintenancePerformed", typeof(string));
        dt.Columns.Add("PerformedBy", typeof(string));
        dt.Columns.Add("PartsReplaced", typeof(string));
        dt.Columns.Add("Cost", typeof(decimal));
        dt.Columns.Add("Status", typeof(string));
        dt.Columns.Add("CreatedDate", typeof(DateTime));
        dt.Columns.Add("ActualStartTime", typeof(DateTime));
        dt.Columns.Add("ActualEndTime", typeof(DateTime));
        dt.Columns.Add("ActualDuration", typeof(string));
        dt.Columns.Add("Downtime", typeof(decimal));
        dt.Columns.Add("Comments", typeof(string));
        dt.Columns.Add("AttachmentsPath", typeof(string));

        string query = @"SELECT
            ISNULL([PMID],'') as PMID,
            ISNULL([EquipmentName],'') as EquipmentName,
            ISNULL([EquipmentEatonID],'') as EquipmentEatonID,
            [ScheduledDate] as ScheduledDate,
            [PMDate] as PMDate,
            ISNULL(CAST([IsOnTime] AS BIT), 0) as IsOnTime,
            [NextPMDate] as NextPMDate,
            ISNULL([PMType],'') as PMType,
            ISNULL([MaintenancePerformed],'') as MaintenancePerformed,
            ISNULL([PerformedBy],'') as PerformedBy,
            ISNULL([PartsReplaced],'') as PartsReplaced,
            ISNULL(CAST([Cost] AS DECIMAL(10,2)), 0) as Cost,
            ISNULL([Status],'') as Status,
            [CreatedDate] as CreatedDate,
            [ActualStartTime] as ActualStartTime,
            [ActualEndTime] as ActualEndTime,
            CASE
                WHEN [ActualStartTime] IS NOT NULL AND [ActualEndTime] IS NOT NULL
                THEN CAST(DATEDIFF(MINUTE, [ActualStartTime], [ActualEndTime]) AS NVARCHAR(20)) + ' min'
                ELSE ''
            END as ActualDuration,
            ISNULL(CAST([Downtime] AS DECIMAL(10,2)), 0) as Downtime,
            ISNULL([Comments],'') as Comments,
            ISNULL([AttachmentsPath],'') as AttachmentsPath
            FROM dbo.PM_Log";

        try
        {
            System.Diagnostics.Debug.WriteLine("Executing PM query...");
            using (SqlCommand cmd = new SqlCommand(query, conn))
            using (SqlDataReader reader = cmd.ExecuteReader())
            {
                int rowCount = 0;
                while (reader.Read())
                {
                    rowCount++;
                    DataRow row = dt.NewRow();
                    row["PMID"] = GetSafeValue(reader, "PMID");
                    row["EquipmentName"] = GetSafeValue(reader, "EquipmentName");
                    row["EquipmentEatonID"] = GetSafeValue(reader, "EquipmentEatonID");

                    if (!reader.IsDBNull(reader.GetOrdinal("ScheduledDate")))
                        row["ScheduledDate"] = reader.GetDateTime(reader.GetOrdinal("ScheduledDate"));

                    if (!reader.IsDBNull(reader.GetOrdinal("PMDate")))
                        row["PMDate"] = reader.GetDateTime(reader.GetOrdinal("PMDate"));

                    row["IsOnTime"] = reader.GetBoolean(reader.GetOrdinal("IsOnTime"));

                    if (!reader.IsDBNull(reader.GetOrdinal("NextPMDate")))
                        row["NextPMDate"] = reader.GetDateTime(reader.GetOrdinal("NextPMDate"));

                    row["PMType"] = GetSafeValue(reader, "PMType");
                    row["MaintenancePerformed"] = GetSafeValue(reader, "MaintenancePerformed");
                    row["PerformedBy"] = GetSafeValue(reader, "PerformedBy");
                    row["PartsReplaced"] = GetSafeValue(reader, "PartsReplaced");
                    row["Cost"] = reader.GetDecimal(reader.GetOrdinal("Cost"));
                    row["Status"] = GetSafeValue(reader, "Status");

                    if (!reader.IsDBNull(reader.GetOrdinal("CreatedDate")))
                        row["CreatedDate"] = reader.GetDateTime(reader.GetOrdinal("CreatedDate"));

                    if (!reader.IsDBNull(reader.GetOrdinal("ActualStartTime")))
                        row["ActualStartTime"] = reader.GetDateTime(reader.GetOrdinal("ActualStartTime"));

                    if (!reader.IsDBNull(reader.GetOrdinal("ActualEndTime")))
                        row["ActualEndTime"] = reader.GetDateTime(reader.GetOrdinal("ActualEndTime"));

                    row["ActualDuration"] = GetSafeValue(reader, "ActualDuration");
                    row["Downtime"] = reader.GetDecimal(reader.GetOrdinal("Downtime"));
                    row["Comments"] = GetSafeValue(reader, "Comments");
                    row["AttachmentsPath"] = GetSafeValue(reader, "AttachmentsPath");

                    dt.Rows.Add(row);
                }
                System.Diagnostics.Debug.WriteLine(string.Format("Loaded {0} PM rows", rowCount));
                Response.Write("<script>console.log('GetPMData: Loaded " + rowCount + " rows');</script>");
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine(string.Format("ERROR loading PM data: {0}", ex.Message));
            System.Diagnostics.Debug.WriteLine(string.Format("Stack trace: {0}", ex.StackTrace));
            if (ex.InnerException != null)
            {
                System.Diagnostics.Debug.WriteLine(string.Format("Inner exception: {0}", ex.InnerException.Message));
            }
            Response.Write("<script>console.error('GetPMData ERROR: " + ex.Message.Replace("'", "\\'") + "');</script>");
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
            filters.Add(string.Format("(PMID LIKE '%{0}%' OR EquipmentName LIKE '%{0}%' OR EquipmentEatonID LIKE '%{0}%' OR PerformedBy LIKE '%{0}%' OR MaintenancePerformed LIKE '%{0}%' OR PartsReplaced LIKE '%{0}%' OR Comments LIKE '%{0}%')", escapedSearch));
        }

        // Status filter
        if (ddlStatus.SelectedValue != "ALL")
        {
            string status = ddlStatus.SelectedValue.Replace("'", "''");
            filters.Add(string.Format("Status = '{0}'", status));
        }

        // PM Type filter
        if (ddlPMType.SelectedValue != "ALL")
        {
            string pmType = ddlPMType.SelectedValue.Replace("'", "''");
            filters.Add(string.Format("PMType = '{0}'", pmType));
        }

        // Performed By filter
        if (ddlPerformedBy.SelectedValue != "ALL")
        {
            string performer = ddlPerformedBy.SelectedValue.Replace("'", "''");
            filters.Add(string.Format("PerformedBy = '{0}'", performer));
        }

        // Equipment Type filter
        if (ddlEquipmentType.SelectedValue != "ALL")
        {
            string equipType = ddlEquipmentType.SelectedValue.Replace("'", "''");
            filters.Add(string.Format("EquipmentType = '{0}'", equipType));
        }

        // Equipment Name filter
        if (ddlEquipmentName.SelectedValue != "ALL")
        {
            string equipName = ddlEquipmentName.SelectedValue.Replace("'", "''");
            filters.Add(string.Format("EquipmentName = '{0}'", equipName));
        }

        // Equipment Eaton ID filter
        if (ddlEquipmentEatonID.SelectedValue != "ALL")
        {
            string eatonId = ddlEquipmentEatonID.SelectedValue.Replace("'", "''");
            filters.Add(string.Format("EquipmentEatonID = '{0}'", eatonId));
        }

        return string.Join(" AND ", filters);
    }

    private void BuildGridColumns()
    {
        // Clear existing columns
        gridPM.Columns.Clear();

        // 1. PMID
        BoundField pmidField = new BoundField();
        pmidField.DataField = "PMID";
        pmidField.HeaderText = "PM ID";
        pmidField.HeaderStyle.CssClass = "col-pmid";
        pmidField.ItemStyle.CssClass = "col-pmid";
        gridPM.Columns.Add(pmidField);

        // 2. Equipment Name
        BoundField equipmentNameField = new BoundField();
        equipmentNameField.DataField = "EquipmentName";
        equipmentNameField.HeaderText = "Equipment Name";
        equipmentNameField.HeaderStyle.CssClass = "col-equipment-name";
        equipmentNameField.ItemStyle.CssClass = "col-equipment-name";
        gridPM.Columns.Add(equipmentNameField);

        // 3. Equipment Eaton ID
        BoundField equipmentEatonIDField = new BoundField();
        equipmentEatonIDField.DataField = "EquipmentEatonID";
        equipmentEatonIDField.HeaderText = "Eaton ID";
        equipmentEatonIDField.HeaderStyle.CssClass = "col-equipment-eaton-id";
        equipmentEatonIDField.ItemStyle.CssClass = "col-equipment-eaton-id";
        gridPM.Columns.Add(equipmentEatonIDField);

        // 4. Status (MOVED: now next to Equipment Eaton ID)
        BoundField statusField = new BoundField();
        statusField.DataField = "Status";
        statusField.HeaderText = "Status";
        statusField.HeaderStyle.CssClass = "col-status";
        statusField.ItemStyle.CssClass = "col-status";
        gridPM.Columns.Add(statusField);

        // 5. Scheduled Date
        BoundField scheduledDateField = new BoundField();
        scheduledDateField.DataField = "ScheduledDate";
        scheduledDateField.HeaderText = "Scheduled Date";
        scheduledDateField.DataFormatString = "{0:MM/dd/yyyy}";
        scheduledDateField.HeaderStyle.CssClass = "col-scheduled-date";
        scheduledDateField.ItemStyle.CssClass = "col-scheduled-date date-cell";
        gridPM.Columns.Add(scheduledDateField);

        // 6. PM Date
        BoundField pmDateField = new BoundField();
        pmDateField.DataField = "PMDate";
        pmDateField.HeaderText = "PM Date";
        pmDateField.DataFormatString = "{0:MM/dd/yyyy}";
        pmDateField.HeaderStyle.CssClass = "col-pm-date";
        pmDateField.ItemStyle.CssClass = "col-pm-date date-cell";
        gridPM.Columns.Add(pmDateField);

        // 7. Is On Time (NEW: next to PM Date)
        BoundField isOnTimeField = new BoundField();
        isOnTimeField.DataField = "IsOnTime";
        isOnTimeField.HeaderText = "Is On Time";
        isOnTimeField.HeaderStyle.CssClass = "col-is-on-time";
        isOnTimeField.ItemStyle.CssClass = "col-is-on-time";
        gridPM.Columns.Add(isOnTimeField);

        // 8. Next PM Date
        BoundField nextPMDateField = new BoundField();
        nextPMDateField.DataField = "NextPMDate";
        nextPMDateField.HeaderText = "Next PM Date";
        nextPMDateField.DataFormatString = "{0:MM/dd/yyyy}";
        nextPMDateField.HeaderStyle.CssClass = "col-next-pm-date";
        nextPMDateField.ItemStyle.CssClass = "col-next-pm-date date-cell";
        gridPM.Columns.Add(nextPMDateField);

        // 9. PM Type
        BoundField pmTypeField = new BoundField();
        pmTypeField.DataField = "PMType";
        pmTypeField.HeaderText = "PM Type";
        pmTypeField.HeaderStyle.CssClass = "col-pm-type";
        pmTypeField.ItemStyle.CssClass = "col-pm-type";
        gridPM.Columns.Add(pmTypeField);

        // 10. Maintenance Performed
        BoundField maintenanceField = new BoundField();
        maintenanceField.DataField = "MaintenancePerformed";
        maintenanceField.HeaderText = "Maintenance Performed";
        maintenanceField.HeaderStyle.CssClass = "col-maintenance-performed";
        maintenanceField.ItemStyle.CssClass = "col-maintenance-performed";
        gridPM.Columns.Add(maintenanceField);

        // 11. Performed By
        BoundField performedByField = new BoundField();
        performedByField.DataField = "PerformedBy";
        performedByField.HeaderText = "Performed By";
        performedByField.HeaderStyle.CssClass = "col-performed-by";
        performedByField.ItemStyle.CssClass = "col-performed-by";
        gridPM.Columns.Add(performedByField);

        // 12. Parts Replaced
        BoundField partsReplacedField = new BoundField();
        partsReplacedField.DataField = "PartsReplaced";
        partsReplacedField.HeaderText = "Parts Replaced";
        partsReplacedField.HeaderStyle.CssClass = "col-parts-replaced";
        partsReplacedField.ItemStyle.CssClass = "col-parts-replaced";
        gridPM.Columns.Add(partsReplacedField);

        // 13. Cost
        BoundField costField = new BoundField();
        costField.DataField = "Cost";
        costField.HeaderText = "Cost";
        costField.DataFormatString = "{0:C}";
        costField.HeaderStyle.CssClass = "col-cost";
        costField.ItemStyle.CssClass = "col-cost";
        gridPM.Columns.Add(costField);

        // 14. Created Date
        BoundField createdDateField = new BoundField();
        createdDateField.DataField = "CreatedDate";
        createdDateField.HeaderText = "Created Date";
        createdDateField.DataFormatString = "{0:MM/dd/yyyy HH:mm}";
        createdDateField.HeaderStyle.CssClass = "col-created-date";
        createdDateField.ItemStyle.CssClass = "col-created-date date-cell";
        gridPM.Columns.Add(createdDateField);

        // 15. Actual Start Time
        BoundField actualStartTimeField = new BoundField();
        actualStartTimeField.DataField = "ActualStartTime";
        actualStartTimeField.HeaderText = "Actual Start Time";
        actualStartTimeField.DataFormatString = "{0:MM/dd/yyyy HH:mm}";
        actualStartTimeField.HeaderStyle.CssClass = "col-actual-start-time";
        actualStartTimeField.ItemStyle.CssClass = "col-actual-start-time date-cell";
        gridPM.Columns.Add(actualStartTimeField);

        // 16. Actual End Time
        BoundField actualEndTimeField = new BoundField();
        actualEndTimeField.DataField = "ActualEndTime";
        actualEndTimeField.HeaderText = "Actual End Time";
        actualEndTimeField.DataFormatString = "{0:MM/dd/yyyy HH:mm}";
        actualEndTimeField.HeaderStyle.CssClass = "col-actual-end-time";
        actualEndTimeField.ItemStyle.CssClass = "col-actual-end-time date-cell";
        gridPM.Columns.Add(actualEndTimeField);

        // 17. Actual Duration (NEW: next to Actual End Time)
        BoundField actualDurationField = new BoundField();
        actualDurationField.DataField = "ActualDuration";
        actualDurationField.HeaderText = "Actual Duration";
        actualDurationField.HeaderStyle.CssClass = "col-actual-duration";
        actualDurationField.ItemStyle.CssClass = "col-actual-duration";
        gridPM.Columns.Add(actualDurationField);

        // 18. Downtime
        BoundField downtimeField = new BoundField();
        downtimeField.DataField = "Downtime";
        downtimeField.HeaderText = "Downtime";
        downtimeField.DataFormatString = "{0:N2}";
        downtimeField.HeaderStyle.CssClass = "col-downtime";
        downtimeField.ItemStyle.CssClass = "col-downtime";
        gridPM.Columns.Add(downtimeField);

        // 19. Comments (MOVED: now next to Downtime)
        BoundField commentsField = new BoundField();
        commentsField.DataField = "Comments";
        commentsField.HeaderText = "Comments";
        commentsField.HeaderStyle.CssClass = "col-comments";
        commentsField.ItemStyle.CssClass = "col-comments";
        gridPM.Columns.Add(commentsField);

        // 20. AttachmentsPath (clickable)
        BoundField attachmentsPathField = new BoundField();
        attachmentsPathField.DataField = "AttachmentsPath";
        attachmentsPathField.HeaderText = "Attachments";
        attachmentsPathField.HeaderStyle.CssClass = "col-attachments";
        attachmentsPathField.ItemStyle.CssClass = "col-attachments";
        gridPM.Columns.Add(attachmentsPathField);
    }

    protected void gridPM_RowDataBound(object sender, GridViewRowEventArgs e)
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
                // Add hover tooltips for all cells - UPDATED for new column order
                // Map GridView cell index to DataTable column name
                string[] columnMapping = new string[] {
                    "PMID",              // 0: PM ID
                    "EquipmentName",     // 1: Equipment Name
                    "EquipmentEatonID",  // 2: Eaton ID
                    "Status",            // 3: Status
                    "ScheduledDate",     // 4: Scheduled Date
                    "PMDate",            // 5: PM Date
                    "IsOnTime",          // 6: Is On Time
                    "NextPMDate",        // 7: Next PM Date
                    "PMType",            // 8: PM Type
                    "MaintenancePerformed", // 9: Maintenance Performed
                    "PerformedBy",       // 10: Performed By
                    "PartsReplaced",     // 11: Parts Replaced
                    "Cost",              // 12: Cost
                    "CreatedDate",       // 13: Created Date
                    "ActualStartTime",   // 14: Actual Start Time
                    "ActualEndTime",     // 15: Actual End Time
                    "ActualDuration",    // 16: Actual Duration
                    "Downtime",          // 17: Downtime
                    "Comments",          // 18: Comments
                    "AttachmentsPath"    // 19: Attachments
                };

                for (int i = 0; i < e.Row.Cells.Count && i < columnMapping.Length; i++)
                {
                    string columnName = columnMapping[i];
                    string cellText = drv[columnName].ToString();
                    if (!string.IsNullOrEmpty(cellText) && cellText != "01/01/1900 12:00:00 AM")
                    {
                        e.Row.Cells[i].ToolTip = cellText;
                        e.Row.Cells[i].Attributes["title"] = cellText;
                    }
                }

                // Apply styling to Status cell (Column 3 - Status)
                if (e.Row.Cells.Count > 3)
                {
                    string status = drv["Status"].ToString();
                    if (!string.IsNullOrEmpty(status))
                    {
                        // Handle special characters in status
                        string statusClass = "status-" + status.ToLower()
                            .Replace(" ", "-")
                            .Replace("_", "-")
                            .Replace("/", "-")
                            .Replace("(", "")
                            .Replace(")", "");
                        string statusBadge = string.Format("<span class='status-badge {0}' title='{1}'>{1}</span>", statusClass, status);
                        e.Row.Cells[3].Text = statusBadge;
                    }
                }

                // Apply styling to PM Type cell (Column 8 - PM Type)
                if (e.Row.Cells.Count > 8)
                {
                    string pmType = drv["PMType"].ToString();
                    if (!string.IsNullOrEmpty(pmType))
                    {
                        // Handle special characters in PM type
                        string pmTypeClass = "pm-type-" + pmType.ToLower()
                            .Replace(" ", "-")
                            .Replace("_", "-")
                            .Replace("/", "-")
                            .Replace("(", "")
                            .Replace(")", "");
                        string pmTypeBadge = string.Format("<span class='pm-type-badge {0}' title='{1}'>{1}</span>", pmTypeClass, pmType);
                        e.Row.Cells[8].Text = pmTypeBadge;
                    }
                }

                // Apply toggle styling to Is On Time cell (Column 6 - IsOnTime)
                if (e.Row.Cells.Count > 6)
                {
                    bool isOnTime = false;
                    bool.TryParse(drv["IsOnTime"].ToString(), out isOnTime);
                    string toggleClass = isOnTime ? "toggle-on" : "toggle-off";
                    string title = isOnTime ? "Yes" : "No";
                    e.Row.Cells[6].Text = string.Format("<div class='toggle-switch {0}' title='{1}'><div class='toggle-slider'></div></div>", toggleClass, title);
                    e.Row.Cells[6].ToolTip = title;
                    e.Row.Cells[6].Attributes["title"] = title;
                }

                // Make AttachmentsPath clickable (Column 19 - AttachmentsPath)
                if (e.Row.Cells.Count > 19)
                {
                    string attachmentsPath = drv["AttachmentsPath"].ToString();
                    if (!string.IsNullOrEmpty(attachmentsPath))
                    {
                        // Handle multiple files separated by commas - take the first file path
                        string firstFilePath = attachmentsPath.Split(',')[0].Trim();

                        // Extract folder path from the first file path
                        // Format: "Storage/PM/{PMID}_{EquipmentEatonID}/filename.ext"
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
                            // Fallback: construct from PMID and EquipmentEatonID
                            string pmid = drv["PMID"].ToString();
                            string equipmentEatonID = drv["EquipmentEatonID"].ToString();
                            // Clean up equipment Eaton ID string
                            equipmentEatonID = System.Text.RegularExpressions.Regex.Replace(equipmentEatonID, @"\s+", " ");
                            equipmentEatonID = equipmentEatonID.Replace("/", "-").Replace("\\", "-").Replace(":", "-");
                            folderPath = string.Format("Storage/PM/{0}_{1}", pmid, equipmentEatonID);
                        }

                        string appPath = ResolveUrl("~/");
                        string fullUrl = appPath + folderPath;
                        string displayName = folderPath.Replace("Storage/PM/", "");

                        // Count total files for display
                        string[] allFiles = attachmentsPath.Split(',');
                        string linkText = allFiles.Length == 1 ? displayName : string.Format("{0} (+{1} more)", displayName, allFiles.Length - 1);

                        e.Row.Cells[19].Text = string.Format("<a href='{0}' target='_blank' class='attachment-link' title='Open PM folder'>{1}</a>", fullUrl, linkText);
                    }
                }
            }
        }
    }

    protected void ApplyFilters(object sender, EventArgs e)
    {
        BindGrid();
        // Update filter count after page loads
        ScriptManager.RegisterStartupScript(this, GetType(), "updateFilters", "setTimeout(function() { updateFilterCount(); initializeRowHighlighting(); }, 100);", true);
    }

    protected void ResetFilters(object sender, EventArgs e)
    {
        txtSearch.Text = string.Empty;
        ddlStatus.SelectedValue = "ALL";
        ddlPMType.SelectedValue = "ALL";
        ddlPerformedBy.SelectedValue = "ALL";
        ddlEquipmentType.SelectedValue = "ALL";
        ddlEquipmentName.SelectedValue = "ALL";
        ddlEquipmentEatonID.SelectedValue = "ALL";

        // Clear ViewState to allow reloading dropdowns
        ViewState["DropdownsLoaded"] = null;

        LoadData();

        // Set ViewState back after loading
        ViewState["DropdownsLoaded"] = true;

        // Update filter count after reset
        ScriptManager.RegisterStartupScript(this, GetType(), "resetFilters", "setTimeout(function() { updateFilterCount(); initializeRowHighlighting(); }, 100);", true);
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

            // Headers - Updated to match new PM column order
            csv.AppendLine("PM ID,Equipment Name,Eaton ID,Status,Scheduled Date,PM Date,Is On Time,Next PM Date,PM Type,Maintenance Performed,Performed By,Parts Replaced,Cost,Created Date,Actual Start Time,Actual End Time,Actual Duration,Downtime,Comments,Attachments");

            // Data - Updated to match new PM column order
            foreach (GridViewRow row in gridPM.Rows)
            {
                if (row.RowType == DataControlRowType.DataRow)
                {
                    var cells = new string[20]; // Updated count for new columns
                    // Map to the new PM column order
                    cells[0] = GetCellText(row.Cells[0]); // PM ID
                    cells[1] = GetCellText(row.Cells[1]); // Equipment Name
                    cells[2] = GetCellText(row.Cells[2]); // Eaton ID
                    cells[3] = GetCellText(row.Cells[3]); // Status
                    cells[4] = GetCellText(row.Cells[4]); // Scheduled Date
                    cells[5] = GetCellText(row.Cells[5]); // PM Date
                    cells[6] = GetCellText(row.Cells[6]); // Is On Time
                    cells[7] = GetCellText(row.Cells[7]); // Next PM Date
                    cells[8] = GetCellText(row.Cells[8]); // PM Type
                    cells[9] = GetCellText(row.Cells[9]); // Maintenance Performed
                    cells[10] = GetCellText(row.Cells[10]); // Performed By
                    cells[11] = GetCellText(row.Cells[11]); // Parts Replaced
                    cells[12] = GetCellText(row.Cells[12]); // Cost
                    cells[13] = GetCellText(row.Cells[13]); // Created Date
                    cells[14] = GetCellText(row.Cells[14]); // Actual Start Time
                    cells[15] = GetCellText(row.Cells[15]); // Actual End Time
                    cells[16] = GetCellText(row.Cells[16]); // Actual Duration
                    cells[17] = GetCellText(row.Cells[17]); // Downtime
                    cells[18] = GetCellText(row.Cells[18]); // Comments
                    cells[19] = GetCellText(row.Cells[19]); // Attachments

                    csv.AppendLine(string.Join(",", cells));
                }
            }

            // Send to client
            Response.Clear();
            Response.Buffer = true;
            Response.AddHeader("content-disposition", string.Format("attachment;filename=PMLogs_{0}.csv", DateTime.Now.ToString("yyyyMMdd")));
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