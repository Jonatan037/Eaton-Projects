using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

// Last Modified: October 23, 2025 - 01:00 UTC - Troubleshooting Logs Grid View
public partial class TED_TroubleshootingGridView : Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadData();
            ViewState["DropdownsLoaded"] = true;
            
            // Handle query string parameters for filtering
            ApplyQueryStringFilters();
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
            LoadPriorities();
            LoadIssueClassifications();
            LoadIssueSubclassifications();
            LoadReporters();
            LoadResolvers();
            LoadImpactLevels();
            LoadLocations();
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

                // Get unique statuses from troubleshooting table
                string query = @"SELECT DISTINCT [Status] as Status FROM dbo.Troubleshooting_Log
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
        }
    }

    private void LoadPriorities()
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

                // Clear existing items except "All Priorities"
                ddlPriority.Items.Clear();
                ddlPriority.Items.Add(new ListItem("All Priorities", "ALL"));

                // Get unique priorities from troubleshooting table
                string query = @"SELECT DISTINCT [Priority] as Priority FROM dbo.Troubleshooting_Log
                                WHERE [Priority] IS NOT NULL AND [Priority] <> ''
                                ORDER BY Priority";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    int count = 0;
                    while (reader.Read())
                    {
                        string priority = reader["Priority"].ToString();
                        if (!string.IsNullOrWhiteSpace(priority))
                        {
                            ddlPriority.Items.Add(new ListItem(priority, priority));
                            count++;
                        }
                    }
                    Response.Write("<script>console.log('Loaded " + count + " priority values');</script>");
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error loading priorities: " + ex.Message);
            Response.Write("<script>console.error('LoadPriorities Error: " + ex.Message.Replace("'", "\\'") + "');</script>");
        }
    }

    private void LoadIssueClassifications()
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

                // Clear existing items except "All Classifications"
                ddlIssueClassification.Items.Clear();
                ddlIssueClassification.Items.Add(new ListItem("All Classifications", "ALL"));

                string query = @"SELECT DISTINCT [IssueClassification] FROM dbo.Troubleshooting_Log
                                WHERE [IssueClassification] IS NOT NULL AND [IssueClassification] <> ''
                                ORDER BY [IssueClassification]";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string classification = reader["IssueClassification"].ToString();
                        if (!string.IsNullOrWhiteSpace(classification))
                        {
                            ddlIssueClassification.Items.Add(new ListItem(classification, classification));
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error loading issue classifications: " + ex.Message);
        }
    }

    private void LoadIssueSubclassifications()
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

                // Clear existing items except "All Subclassifications"
                ddlIssueSubclassification.Items.Clear();
                ddlIssueSubclassification.Items.Add(new ListItem("All Subclassifications", "ALL"));

                string query = @"SELECT DISTINCT [IssueSubclassification] FROM dbo.Troubleshooting_Log
                                WHERE [IssueSubclassification] IS NOT NULL AND [IssueSubclassification] <> ''
                                ORDER BY [IssueSubclassification]";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string subclassification = reader["IssueSubclassification"].ToString();
                        if (!string.IsNullOrWhiteSpace(subclassification))
                        {
                            ddlIssueSubclassification.Items.Add(new ListItem(subclassification, subclassification));
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error loading issue subclassifications: " + ex.Message);
        }
    }

    private void LoadReporters()
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

                // Clear existing items except "All Reporters"
                ddlReportedBy.Items.Clear();
                ddlReportedBy.Items.Add(new ListItem("All Reporters", "ALL"));

                string query = @"SELECT DISTINCT [ReportedBy] FROM dbo.Troubleshooting_Log
                                WHERE [ReportedBy] IS NOT NULL AND [ReportedBy] <> ''
                                ORDER BY [ReportedBy]";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string reporter = reader["ReportedBy"].ToString();
                        if (!string.IsNullOrWhiteSpace(reporter))
                        {
                            ddlReportedBy.Items.Add(new ListItem(reporter, reporter));
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error loading reporters: " + ex.Message);
        }
    }

    private void LoadResolvers()
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

                // Clear existing items except "All Resolvers"
                ddlResolvedBy.Items.Clear();
                ddlResolvedBy.Items.Add(new ListItem("All Resolvers", "ALL"));

                string query = @"SELECT DISTINCT [ResolvedBy] FROM dbo.Troubleshooting_Log
                                WHERE [ResolvedBy] IS NOT NULL AND [ResolvedBy] <> ''
                                ORDER BY [ResolvedBy]";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string resolver = reader["ResolvedBy"].ToString();
                        if (!string.IsNullOrWhiteSpace(resolver))
                        {
                            ddlResolvedBy.Items.Add(new ListItem(resolver, resolver));
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error loading resolvers: " + ex.Message);
        }
    }

    private void LoadImpactLevels()
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

                // Clear existing items except "All Impact Levels"
                ddlImpactLevel.Items.Clear();
                ddlImpactLevel.Items.Add(new ListItem("All Impact Levels", "ALL"));

                string query = @"SELECT DISTINCT [ImpactLevel] FROM dbo.Troubleshooting_Log
                                WHERE [ImpactLevel] IS NOT NULL AND [ImpactLevel] <> ''
                                ORDER BY [ImpactLevel]";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string impact = reader["ImpactLevel"].ToString();
                        if (!string.IsNullOrWhiteSpace(impact))
                        {
                            ddlImpactLevel.Items.Add(new ListItem(impact, impact));
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error loading impact levels: " + ex.Message);
        }
    }

    private void LoadLocations()
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

                // Clear existing items except "All Locations"
                ddlLocation.Items.Clear();
                ddlLocation.Items.Add(new ListItem("All Locations", "ALL"));

                // Get unique locations from troubleshooting table
                string query = @"SELECT DISTINCT [Location] FROM dbo.Troubleshooting_Log
                                WHERE [Location] IS NOT NULL AND [Location] <> ''
                                ORDER BY [Location]";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    int count = 0;
                    while (reader.Read())
                    {
                        string location = reader["Location"].ToString();
                        if (!string.IsNullOrWhiteSpace(location))
                        {
                            ddlLocation.Items.Add(new ListItem(location, location));
                            count++;
                        }
                    }
                    Response.Write("<script>console.log('Loaded " + count + " locations');</script>");
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error loading locations: " + ex.Message);
            Response.Write("<script>console.error('LoadLocations Error: " + ex.Message.Replace("'", "\\'") + "');</script>");
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

                dt = GetTroubleshootingData(conn);
                System.Diagnostics.Debug.WriteLine(string.Format("GetTroubleshootingData returned {0} rows", dt.Rows.Count));
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
                gridTroubleshooting.Visible = false;
                pnlEmptyState.Visible = true;
            }
            else
            {
                System.Diagnostics.Debug.WriteLine("Building grid with data");
                Response.Write("<script>console.log('Building grid with " + dv.Count + " rows');</script>");
                gridTroubleshooting.Visible = true;
                pnlEmptyState.Visible = false;

                // Clear and rebuild columns
                gridTroubleshooting.Columns.Clear();
                BuildGridColumns();

                gridTroubleshooting.DataSource = dv;
                gridTroubleshooting.DataBind();
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
            gridTroubleshooting.Visible = false;
            pnlEmptyState.Visible = true;
        }
    }

    private DataTable GetTroubleshootingData(SqlConnection conn)
    {
        DataTable dt = new DataTable();

        // Define all columns for comprehensive view
        dt.Columns.Add("ID", typeof(string));
        dt.Columns.Add("Symptom", typeof(string));
        dt.Columns.Add("Location", typeof(string));
        dt.Columns.Add("ReportedBy", typeof(string));
        dt.Columns.Add("ReportedDateTime", typeof(DateTime));
        dt.Columns.Add("TroubleshootingStepsDescription", typeof(string));
        dt.Columns.Add("RootCause", typeof(string));
        dt.Columns.Add("SolutionApplied", typeof(string));
        dt.Columns.Add("IssueClassification", typeof(string));
        dt.Columns.Add("IssueSubclassification", typeof(string));
        dt.Columns.Add("ResolvedBy", typeof(string));
        dt.Columns.Add("ResolvedDateTime", typeof(DateTime));
        dt.Columns.Add("PreventiveAction", typeof(string));
        dt.Columns.Add("AdditionalComments", typeof(string));
        dt.Columns.Add("AffectedATE", typeof(string));
        dt.Columns.Add("AffectedEquipment", typeof(string));
        dt.Columns.Add("AffectedFixture", typeof(string));
        dt.Columns.Add("AffectedHarness", typeof(string));
        dt.Columns.Add("Status", typeof(string));
        dt.Columns.Add("Priority", typeof(string));
        dt.Columns.Add("CreatedDate", typeof(DateTime));
        dt.Columns.Add("IsRepeat", typeof(string));
        dt.Columns.Add("DowntimeHours", typeof(decimal));
        dt.Columns.Add("ImpactLevel", typeof(string));
        dt.Columns.Add("ResolutionTimeHours", typeof(decimal));
        dt.Columns.Add("IsResolved", typeof(string));
        dt.Columns.Add("AttachmentsPath", typeof(string));
        dt.Columns.Add("TroubleshootingID", typeof(string));

        string query = @"SELECT
            ISNULL([ID],'') as ID,
            ISNULL([Symptom],'') as Symptom,
            ISNULL([Location],'') as Location,
            ISNULL([ReportedBy],'') as ReportedBy,
            [ReportedDateTime] as ReportedDateTime,
            ISNULL([TroubleshootingStepsDescription],'') as TroubleshootingStepsDescription,
            ISNULL([RootCause],'') as RootCause,
            ISNULL([SolutionApplied],'') as SolutionApplied,
            ISNULL([IssueClassification],'') as IssueClassification,
            ISNULL([IssueSubclassification],'') as IssueSubclassification,
            ISNULL([ResolvedBy],'') as ResolvedBy,
            [ResolvedDateTime] as ResolvedDateTime,
            ISNULL([PreventiveAction],'') as PreventiveAction,
            ISNULL([AdditionalComments],'') as AdditionalComments,
            ISNULL([AffectedATE],'') as AffectedATE,
            ISNULL([AffectedEquipment],'') as AffectedEquipment,
            ISNULL([AffectedFixture],'') as AffectedFixture,
            ISNULL([AffectedHarness],'') as AffectedHarness,
            ISNULL([Status],'') as Status,
            ISNULL([Priority],'') as Priority,
            [CreatedDate] as CreatedDate,
            ISNULL([IsRepeat],'') as IsRepeat,
            ISNULL(CAST([DowntimeHours] AS DECIMAL(10,2)), 0) as DowntimeHours,
            ISNULL([ImpactLevel],'') as ImpactLevel,
            ISNULL(CAST([ResolutionTimeHours] AS DECIMAL(10,2)), 0) as ResolutionTimeHours,
            ISNULL([IsResolved],'') as IsResolved,
            ISNULL([AttachmentsPath],'') as AttachmentsPath,
            ISNULL([TroubleshootingID],'') as TroubleshootingID
            FROM dbo.Troubleshooting_Log";

        try
        {
            System.Diagnostics.Debug.WriteLine("Executing troubleshooting query...");
            using (SqlCommand cmd = new SqlCommand(query, conn))
            using (SqlDataReader reader = cmd.ExecuteReader())
            {
                int rowCount = 0;
                while (reader.Read())
                {
                    rowCount++;
                    DataRow row = dt.NewRow();
                    row["ID"] = GetSafeValue(reader, "ID");
                    row["Symptom"] = GetSafeValue(reader, "Symptom");
                    row["Location"] = GetSafeValue(reader, "Location");
                    row["ReportedBy"] = GetSafeValue(reader, "ReportedBy");

                    if (!reader.IsDBNull(reader.GetOrdinal("ReportedDateTime")))
                        row["ReportedDateTime"] = reader.GetDateTime(reader.GetOrdinal("ReportedDateTime"));

                    row["TroubleshootingStepsDescription"] = GetSafeValue(reader, "TroubleshootingStepsDescription");
                    row["RootCause"] = GetSafeValue(reader, "RootCause");
                    row["SolutionApplied"] = GetSafeValue(reader, "SolutionApplied");
                    row["IssueClassification"] = GetSafeValue(reader, "IssueClassification");
                    row["IssueSubclassification"] = GetSafeValue(reader, "IssueSubclassification");
                    row["ResolvedBy"] = GetSafeValue(reader, "ResolvedBy");

                    if (!reader.IsDBNull(reader.GetOrdinal("ResolvedDateTime")))
                        row["ResolvedDateTime"] = reader.GetDateTime(reader.GetOrdinal("ResolvedDateTime"));

                    row["PreventiveAction"] = GetSafeValue(reader, "PreventiveAction");
                    row["AdditionalComments"] = GetSafeValue(reader, "AdditionalComments");
                    row["AffectedATE"] = GetSafeValue(reader, "AffectedATE");
                    row["AffectedEquipment"] = GetSafeValue(reader, "AffectedEquipment");
                    row["AffectedFixture"] = GetSafeValue(reader, "AffectedFixture");
                    row["AffectedHarness"] = GetSafeValue(reader, "AffectedHarness");
                    row["Status"] = GetSafeValue(reader, "Status");
                    row["Priority"] = GetSafeValue(reader, "Priority");

                    if (!reader.IsDBNull(reader.GetOrdinal("CreatedDate")))
                        row["CreatedDate"] = reader.GetDateTime(reader.GetOrdinal("CreatedDate"));

                    row["IsRepeat"] = GetSafeValue(reader, "IsRepeat");
                    row["DowntimeHours"] = reader.GetDecimal(reader.GetOrdinal("DowntimeHours"));
                    row["ImpactLevel"] = GetSafeValue(reader, "ImpactLevel");
                    row["ResolutionTimeHours"] = reader.GetDecimal(reader.GetOrdinal("ResolutionTimeHours"));
                    row["IsResolved"] = GetSafeValue(reader, "IsResolved");
                    row["AttachmentsPath"] = GetSafeValue(reader, "AttachmentsPath");
                    row["TroubleshootingID"] = GetSafeValue(reader, "TroubleshootingID");

                    dt.Rows.Add(row);
                }
                System.Diagnostics.Debug.WriteLine(string.Format("Loaded {0} troubleshooting rows", rowCount));
                Response.Write("<script>console.log('GetTroubleshootingData: Loaded " + rowCount + " rows');</script>");
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine(string.Format("ERROR loading troubleshooting data: {0}", ex.Message));
            System.Diagnostics.Debug.WriteLine(string.Format("Stack trace: {0}", ex.StackTrace));
            if (ex.InnerException != null)
            {
                System.Diagnostics.Debug.WriteLine(string.Format("Inner exception: {0}", ex.InnerException.Message));
            }
            Response.Write("<script>console.error('GetTroubleshootingData ERROR: " + ex.Message.Replace("'", "\\'") + "');</script>");
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
            filters.Add(string.Format("(ID LIKE '%{0}%' OR Symptom LIKE '%{0}%' OR Location LIKE '%{0}%' OR ReportedBy LIKE '%{0}%' OR TroubleshootingStepsDescription LIKE '%{0}%' OR RootCause LIKE '%{0}%' OR SolutionApplied LIKE '%{0}%')", escapedSearch));
        }

        // Status filter
        if (ddlStatus.SelectedValue != "ALL")
        {
            string status = ddlStatus.SelectedValue.Replace("'", "''");
            filters.Add(string.Format("Status = '{0}'", status));
        }

        // Priority filter - ADDED
        if (ddlPriority.SelectedValue != "ALL")
        {
            string priority = ddlPriority.SelectedValue.Replace("'", "''");
            filters.Add(string.Format("Priority = '{0}'", priority));
        }

        // Equipment Type filter - REMOVED as requested

        // Location filter
        if (ddlIssueClassification.SelectedValue != "ALL")
        {
            string classification = ddlIssueClassification.SelectedValue.Replace("'", "''");
            filters.Add(string.Format("IssueClassification = '{0}'", classification));
        }

        // Issue Subclassification filter
        if (ddlIssueSubclassification.SelectedValue != "ALL")
        {
            string subclassification = ddlIssueSubclassification.SelectedValue.Replace("'", "''");
            filters.Add(string.Format("IssueSubclassification = '{0}'", subclassification));
        }

        // Reported By filter
        if (ddlReportedBy.SelectedValue != "ALL")
        {
            string reporter = ddlReportedBy.SelectedValue.Replace("'", "''");
            filters.Add(string.Format("ReportedBy = '{0}'", reporter));
        }

        // Resolved By filter
        if (ddlResolvedBy.SelectedValue != "ALL")
        {
            string resolver = ddlResolvedBy.SelectedValue.Replace("'", "''");
            filters.Add(string.Format("ResolvedBy = '{0}'", resolver));
        }

        // Is Resolved filter
        if (ddlIsResolved.SelectedValue != "ALL")
        {
            string isResolvedValue = ddlIsResolved.SelectedValue;
            if (isResolvedValue == "Yes")
            {
                filters.Add("(IsResolved = 'True' OR IsResolved = 'Yes' OR IsResolved = '1' OR IsResolved = 'true')");
            }
            else if (isResolvedValue == "No")
            {
                filters.Add("(IsResolved = 'False' OR IsResolved = 'No' OR IsResolved = '0' OR IsResolved = 'false' OR IsResolved = '' OR IsResolved IS NULL)");
            }
        }

        // Is Repeat filter
        if (ddlIsRepeat.SelectedValue != "ALL")
        {
            string isRepeatValue = ddlIsRepeat.SelectedValue;
            if (isRepeatValue == "Yes")
            {
                filters.Add("(IsRepeat = 'True' OR IsRepeat = 'Yes' OR IsRepeat = '1' OR IsRepeat = 'true')");
            }
            else if (isRepeatValue == "No")
            {
                filters.Add("(IsRepeat = 'False' OR IsRepeat = 'No' OR IsRepeat = '0' OR IsRepeat = 'false' OR IsRepeat = '' OR IsRepeat IS NULL)");
            }
        }

        // Impact Level filter
        if (ddlImpactLevel.SelectedValue != "ALL")
        {
            string impact = ddlImpactLevel.SelectedValue.Replace("'", "''");
            filters.Add(string.Format("ImpactLevel = '{0}'", impact));
        }

        // Location filter
        if (ddlLocation.SelectedValue != "ALL")
        {
            string location = ddlLocation.SelectedValue.Replace("'", "''");
            filters.Add(string.Format("Location = '{0}'", location));
        }

        return string.Join(" AND ", filters);
    }

    private void BuildGridColumns()
    {
        // Clear existing columns
        gridTroubleshooting.Columns.Clear();

        // 1. TroubleshootingID
        BoundField troubleshootingIDField = new BoundField();
        troubleshootingIDField.DataField = "TroubleshootingID";
        troubleshootingIDField.HeaderText = "Troubleshooting ID";
        troubleshootingIDField.HeaderStyle.CssClass = "col-troubleshooting-id";
        troubleshootingIDField.ItemStyle.CssClass = "col-troubleshooting-id";
        gridTroubleshooting.Columns.Add(troubleshootingIDField);

        // 2. Location
        BoundField locationField = new BoundField();
        locationField.DataField = "Location";
        locationField.HeaderText = "Location";
        locationField.HeaderStyle.CssClass = "col-location";
        locationField.ItemStyle.CssClass = "col-location";
        gridTroubleshooting.Columns.Add(locationField);

        // 3. Reported Date/time
        BoundField reportedDateField = new BoundField();
        reportedDateField.DataField = "ReportedDateTime";
        reportedDateField.HeaderText = "Reported Date/Time";
        reportedDateField.DataFormatString = "{0:MM/dd/yyyy HH:mm}";
        reportedDateField.HeaderStyle.CssClass = "col-reported-date";
        reportedDateField.ItemStyle.CssClass = "col-reported-date date-cell";
        gridTroubleshooting.Columns.Add(reportedDateField);

        // 4. Reported By
        BoundField reportedByField = new BoundField();
        reportedByField.DataField = "ReportedBy";
        reportedByField.HeaderText = "Reported By";
        reportedByField.HeaderStyle.CssClass = "col-reported-by";
        reportedByField.ItemStyle.CssClass = "col-reported-by";
        gridTroubleshooting.Columns.Add(reportedByField);

        // 5. Status
        BoundField statusField = new BoundField();
        statusField.DataField = "Status";
        statusField.HeaderText = "Status";
        statusField.HeaderStyle.CssClass = "col-status";
        statusField.ItemStyle.CssClass = "col-status";
        gridTroubleshooting.Columns.Add(statusField);

        // 6. Symptom/Issue Description
        BoundField symptomField = new BoundField();
        symptomField.DataField = "Symptom";
        symptomField.HeaderText = "Symptom/Issue Description";
        symptomField.HeaderStyle.CssClass = "col-symptom";
        symptomField.ItemStyle.CssClass = "col-symptom";
        gridTroubleshooting.Columns.Add(symptomField);

        // 7. Troubleshooting Steps / Description
        BoundField stepsField = new BoundField();
        stepsField.DataField = "TroubleshootingStepsDescription";
        stepsField.HeaderText = "Troubleshooting Steps / Description";
        stepsField.HeaderStyle.CssClass = "col-steps";
        stepsField.ItemStyle.CssClass = "col-steps";
        gridTroubleshooting.Columns.Add(stepsField);

        // 8. Solution Applied
        BoundField solutionField = new BoundField();
        solutionField.DataField = "SolutionApplied";
        solutionField.HeaderText = "Solution Applied";
        solutionField.HeaderStyle.CssClass = "col-solution";
        solutionField.ItemStyle.CssClass = "col-solution";
        gridTroubleshooting.Columns.Add(solutionField);

        // 9. Root Cause Analysis
        BoundField rootCauseField = new BoundField();
        rootCauseField.DataField = "RootCause";
        rootCauseField.HeaderText = "Root Cause Analysis";
        rootCauseField.HeaderStyle.CssClass = "col-root-cause";
        rootCauseField.ItemStyle.CssClass = "col-root-cause";
        gridTroubleshooting.Columns.Add(rootCauseField);

        // 10. Preventive Action
        BoundField preventiveField = new BoundField();
        preventiveField.DataField = "PreventiveAction";
        preventiveField.HeaderText = "Preventive Action";
        preventiveField.HeaderStyle.CssClass = "col-preventive";
        preventiveField.ItemStyle.CssClass = "col-preventive";
        gridTroubleshooting.Columns.Add(preventiveField);

        // 11. Issue Classification
        BoundField classificationField = new BoundField();
        classificationField.DataField = "IssueClassification";
        classificationField.HeaderText = "Issue Classification";
        classificationField.HeaderStyle.CssClass = "col-classification";
        classificationField.ItemStyle.CssClass = "col-classification";
        gridTroubleshooting.Columns.Add(classificationField);

        // 12. Issue Subclassification
        BoundField subclassificationField = new BoundField();
        subclassificationField.DataField = "IssueSubclassification";
        subclassificationField.HeaderText = "Issue Subclassification";
        subclassificationField.HeaderStyle.CssClass = "col-subclassification";
        subclassificationField.ItemStyle.CssClass = "col-subclassification";
        gridTroubleshooting.Columns.Add(subclassificationField);

        // 13. Priority
        BoundField priorityField = new BoundField();
        priorityField.DataField = "Priority";
        priorityField.HeaderText = "Priority";
        priorityField.HeaderStyle.CssClass = "col-priority";
        priorityField.ItemStyle.CssClass = "col-priority";
        gridTroubleshooting.Columns.Add(priorityField);

        // 14. Impact Level
        BoundField impactField = new BoundField();
        impactField.DataField = "ImpactLevel";
        impactField.HeaderText = "Impact Level";
        impactField.HeaderStyle.CssClass = "col-impact";
        impactField.ItemStyle.CssClass = "col-impact";
        gridTroubleshooting.Columns.Add(impactField);

        // 15. Downtime
        BoundField downtimeField = new BoundField();
        downtimeField.DataField = "DowntimeHours";
        downtimeField.HeaderText = "Downtime";
        downtimeField.DataFormatString = "{0:N2}";
        downtimeField.HeaderStyle.CssClass = "col-downtime";
        downtimeField.ItemStyle.CssClass = "col-downtime";
        gridTroubleshooting.Columns.Add(downtimeField);

        // 16. Is Repeat
        BoundField isRepeatField = new BoundField();
        isRepeatField.DataField = "IsRepeat";
        isRepeatField.HeaderText = "Is Repeat";
        isRepeatField.HeaderStyle.CssClass = "col-is-repeat";
        isRepeatField.ItemStyle.CssClass = "col-is-repeat";
        gridTroubleshooting.Columns.Add(isRepeatField);

        // 17. Affected ATE
        BoundField affectedATEField = new BoundField();
        affectedATEField.DataField = "AffectedATE";
        affectedATEField.HeaderText = "Affected ATE";
        affectedATEField.HeaderStyle.CssClass = "col-affected-ate";
        affectedATEField.ItemStyle.CssClass = "col-affected-ate";
        gridTroubleshooting.Columns.Add(affectedATEField);

        // 18. Affected Asset (Affected Equipment)
        BoundField affectedEquipmentField = new BoundField();
        affectedEquipmentField.DataField = "AffectedEquipment";
        affectedEquipmentField.HeaderText = "Affected Asset";
        affectedEquipmentField.HeaderStyle.CssClass = "col-affected-equipment";
        affectedEquipmentField.ItemStyle.CssClass = "col-affected-equipment";
        gridTroubleshooting.Columns.Add(affectedEquipmentField);

        // 19. Affected Fixture
        BoundField affectedFixtureField = new BoundField();
        affectedFixtureField.DataField = "AffectedFixture";
        affectedFixtureField.HeaderText = "Affected Fixture";
        affectedFixtureField.HeaderStyle.CssClass = "col-affected-fixture";
        affectedFixtureField.ItemStyle.CssClass = "col-affected-fixture";
        gridTroubleshooting.Columns.Add(affectedFixtureField);

        // 20. Affected Harness
        BoundField affectedHarnessField = new BoundField();
        affectedHarnessField.DataField = "AffectedHarness";
        affectedHarnessField.HeaderText = "Affected Harness";
        affectedHarnessField.HeaderStyle.CssClass = "col-affected-harness";
        affectedHarnessField.ItemStyle.CssClass = "col-affected-harness";
        gridTroubleshooting.Columns.Add(affectedHarnessField);

        // 21. Resolved Date/Time
        BoundField resolvedDateField = new BoundField();
        resolvedDateField.DataField = "ResolvedDateTime";
        resolvedDateField.HeaderText = "Resolved Date/Time";
        resolvedDateField.DataFormatString = "{0:MM/dd/yyyy HH:mm}";
        resolvedDateField.HeaderStyle.CssClass = "col-resolved-date";
        resolvedDateField.ItemStyle.CssClass = "col-resolved-date date-cell";
        gridTroubleshooting.Columns.Add(resolvedDateField);

        // 22. Resolved By
        BoundField resolvedByField = new BoundField();
        resolvedByField.DataField = "ResolvedBy";
        resolvedByField.HeaderText = "Resolved By";
        resolvedByField.HeaderStyle.CssClass = "col-resolved-by";
        resolvedByField.ItemStyle.CssClass = "col-resolved-by";
        gridTroubleshooting.Columns.Add(resolvedByField);

        // 23. Resolution Time
        BoundField resolutionTimeField = new BoundField();
        resolutionTimeField.DataField = "ResolutionTimeHours";
        resolutionTimeField.HeaderText = "Resolution Time";
        resolutionTimeField.DataFormatString = "{0:N2}";
        resolutionTimeField.HeaderStyle.CssClass = "col-resolution-time";
        resolutionTimeField.ItemStyle.CssClass = "col-resolution-time";
        gridTroubleshooting.Columns.Add(resolutionTimeField);

        // 24. Is Resolved
        BoundField isResolvedField = new BoundField();
        isResolvedField.DataField = "IsResolved";
        isResolvedField.HeaderText = "Is Resolved";
        isResolvedField.HeaderStyle.CssClass = "col-is-resolved";
        isResolvedField.ItemStyle.CssClass = "col-is-resolved";
        gridTroubleshooting.Columns.Add(isResolvedField);

        // 25. Additional Comments
        BoundField commentsField = new BoundField();
        commentsField.DataField = "AdditionalComments";
        commentsField.HeaderText = "Additional Comments";
        commentsField.HeaderStyle.CssClass = "col-comments";
        commentsField.ItemStyle.CssClass = "col-comments";
        gridTroubleshooting.Columns.Add(commentsField);

        // 26. AttachmentsPath (clickable)
        BoundField attachmentsPathField = new BoundField();
        attachmentsPathField.DataField = "AttachmentsPath";
        attachmentsPathField.HeaderText = "Attachments";
        attachmentsPathField.HeaderStyle.CssClass = "col-attachments";
        attachmentsPathField.ItemStyle.CssClass = "col-attachments";
        gridTroubleshooting.Columns.Add(attachmentsPathField);
    }

    protected void gridTroubleshooting_RowDataBound(object sender, GridViewRowEventArgs e)
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
                // Add hover tooltips for all cells
                for (int i = 0; i < e.Row.Cells.Count; i++)
                {
                    string cellText = drv[i].ToString();
                    if (!string.IsNullOrEmpty(cellText) && cellText != "01/01/1900 12:00:00 AM")
                    {
                        e.Row.Cells[i].ToolTip = cellText;
                        e.Row.Cells[i].Attributes["title"] = cellText;
                    }
                }

                // Apply styling to Status cell (Column 4 - Status)
                if (e.Row.Cells.Count > 4)
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
                        e.Row.Cells[4].Text = statusBadge;
                    }
                }

                // Apply styling to Priority cell (Column 12 - Priority)
                if (e.Row.Cells.Count > 12)
                {
                    string priority = drv["Priority"].ToString();
                    if (!string.IsNullOrEmpty(priority))
                    {
                        string priorityClass = "priority-" + priority.ToLower()
                            .Replace(" ", "-")
                            .Replace("_", "-")
                            .Replace("/", "-")
                            .Replace("(", "")
                            .Replace(")", "");
                        string priorityBadge = string.Format("<span class='priority-badge {0}' title='{1}'>{1}</span>", priorityClass, priority);
                        e.Row.Cells[12].Text = priorityBadge;
                    }
                }

                // Apply styling to Impact Level cell (Column 13 - ImpactLevel)
                if (e.Row.Cells.Count > 13)
                {
                    string impactLevel = drv["ImpactLevel"].ToString();
                    if (!string.IsNullOrEmpty(impactLevel))
                    {
                        string impactClass = "impact-" + impactLevel.ToLower()
                            .Replace(" ", "-")
                            .Replace("_", "-")
                            .Replace("/", "-")
                            .Replace("(", "")
                            .Replace(")", "");
                        string impactBadge = string.Format("<span class='impact-badge {0}' title='{1}'>{1}</span>", impactClass, impactLevel);
                        e.Row.Cells[13].Text = impactBadge;
                    }
                }

                // Apply toggle styling to Is Repeat cell (Column 15 - IsRepeat)
                if (e.Row.Cells.Count > 15)
                {
                    string isRepeat = drv["IsRepeat"].ToString().ToLower();
                    bool isRepeatIssue = isRepeat == "true" || isRepeat == "yes" || isRepeat == "1" || isRepeat == "yes";
                    string toggleClass = isRepeatIssue ? "toggle-on" : "toggle-off";
                    e.Row.Cells[15].Text = string.Format("<div class='toggle-switch {0}' title='{1}'><div class='toggle-slider'></div></div>", toggleClass, isRepeatIssue ? "Yes" : "No");
                }

                // Apply toggle styling to Is Resolved cell (Column 23 - IsResolved)
                if (e.Row.Cells.Count > 23)
                {
                    string isResolved = drv["IsResolved"].ToString().ToLower();
                    bool isIssueResolved = isResolved == "true" || isResolved == "yes" || isResolved == "1";
                    string toggleClass = isIssueResolved ? "toggle-on" : "toggle-off";
                    e.Row.Cells[23].Text = string.Format("<div class='toggle-switch {0}' title='{1}'><div class='toggle-slider'></div></div>", toggleClass, isIssueResolved ? "Yes" : "No");
                }

                // Make AttachmentsPath clickable (Column 25 - AttachmentsPath)
                if (e.Row.Cells.Count > 25)
                {
                    string attachmentsPath = drv["AttachmentsPath"].ToString();
                    if (!string.IsNullOrEmpty(attachmentsPath))
                    {
                        // Handle multiple files separated by commas - take the first file path
                        string firstFilePath = attachmentsPath.Split(',')[0].Trim();

                        // Extract folder path from the first file path
                        // Format: "Storage/Troubleshooting/{ID}_{Location}/filename.ext"
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
                            // Fallback: construct from ID and Location
                            string troubleshootingId = drv["TroubleshootingID"].ToString();
                            string location = drv["Location"].ToString().Trim();
                            // Clean up location string - remove extra spaces and special characters
                            location = System.Text.RegularExpressions.Regex.Replace(location, @"\s+", " ");
                            location = location.Replace("/", "-").Replace("\\", "-").Replace(":", "-");
                            folderPath = string.Format("Storage/Troubleshooting/{0}_{1}", troubleshootingId, location);
                        }

                        string appPath = ResolveUrl("~/");
                        string fullUrl = appPath + folderPath;
                        string displayName = folderPath.Replace("Storage/Troubleshooting/", "");

                        // Count total files for display
                        string[] allFiles = attachmentsPath.Split(',');
                        string linkText = allFiles.Length == 1 ? displayName : string.Format("{0} (+{1} more)", displayName, allFiles.Length - 1);

                        e.Row.Cells[25].Text = string.Format("<a href='{0}' target='_blank' class='attachment-link' title='Open log folder'>{1}</a>", fullUrl, linkText);
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
        ddlPriority.SelectedValue = "ALL";
        ddlIssueClassification.SelectedValue = "ALL";
        ddlIssueSubclassification.SelectedValue = "ALL";
        ddlReportedBy.SelectedValue = "ALL";
        ddlResolvedBy.SelectedValue = "ALL";
        ddlIsResolved.SelectedValue = "ALL";
        ddlIsRepeat.SelectedValue = "ALL";
        ddlImpactLevel.SelectedValue = "ALL";
        ddlLocation.SelectedValue = "ALL";

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

            // Headers - Updated to match new column order (added attachments back)
            csv.AppendLine("Troubleshooting ID,Location,Reported Date/Time,Reported By,Status,Symptom/Issue Description,Troubleshooting Steps / Description,Solution Applied,Root Cause Analysis,Preventive Action,Issue Classification,Issue Subclassification,Priority,Impact Level,Downtime,Is Repeat,Affected ATE,Affected Asset,Affected Fixture,Affected Harness,Resolved Date/Time,Resolved By,Resolution Time,Is Resolved,Additional Comments,Attachments");

            // Data - Updated to match new column order
            foreach (GridViewRow row in gridTroubleshooting.Rows)
            {
                if (row.RowType == DataControlRowType.DataRow)
                {
                    var cells = new string[26]; // Updated count - added attachments column back
                    // Map to the new column order
                    cells[0] = GetCellText(row.Cells[0]); // Troubleshooting ID
                    cells[1] = GetCellText(row.Cells[1]); // Location
                    cells[2] = GetCellText(row.Cells[2]); // Reported Date/Time
                    cells[3] = GetCellText(row.Cells[3]); // Reported By
                    cells[4] = GetCellText(row.Cells[4]); // Status
                    cells[5] = GetCellText(row.Cells[5]); // Symptom/Issue Description
                    cells[6] = GetCellText(row.Cells[6]); // Troubleshooting Steps / Description
                    cells[7] = GetCellText(row.Cells[7]); // Solution Applied
                    cells[8] = GetCellText(row.Cells[8]); // Root Cause Analysis
                    cells[9] = GetCellText(row.Cells[9]); // Preventive Action
                    cells[10] = GetCellText(row.Cells[10]); // Issue Classification
                    cells[11] = GetCellText(row.Cells[11]); // Issue Subclassification
                    cells[12] = GetCellText(row.Cells[12]); // Priority
                    cells[13] = GetCellText(row.Cells[13]); // Impact Level
                    cells[14] = GetCellText(row.Cells[14]); // Downtime
                    cells[15] = GetCellText(row.Cells[15]); // Is Repeat
                    cells[16] = GetCellText(row.Cells[16]); // Affected ATE
                    cells[17] = GetCellText(row.Cells[17]); // Affected Asset
                    cells[18] = GetCellText(row.Cells[18]); // Affected Fixture
                    cells[19] = GetCellText(row.Cells[19]); // Affected Harness
                    cells[20] = GetCellText(row.Cells[20]); // Resolved Date/Time
                    cells[21] = GetCellText(row.Cells[21]); // Resolved By
                    cells[22] = GetCellText(row.Cells[22]); // Resolution Time
                    cells[23] = GetCellText(row.Cells[23]); // Is Resolved
                    cells[24] = GetCellText(row.Cells[24]); // Additional Comments
                    cells[25] = GetCellText(row.Cells[25]); // Attachments

                    csv.AppendLine(string.Join(",", cells));
                }
            }

            // Send to client
            Response.Clear();
            Response.Buffer = true;
            Response.AddHeader("content-disposition", string.Format("attachment;filename=TroubleshootingLogs_{0}.csv", DateTime.Now.ToString("yyyyMMdd")));
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

    private void ApplyQueryStringFilters()
    {
        try
        {
            // Check for IsResolved filter (Open Issues)
            string isResolvedParam = Request.QueryString["isResolved"];
            if (!string.IsNullOrEmpty(isResolvedParam))
            {
                if (isResolvedParam.Equals("No", StringComparison.OrdinalIgnoreCase))
                {
                    ddlIsResolved.SelectedValue = "No";
                }
                else if (isResolvedParam.Equals("Yes", StringComparison.OrdinalIgnoreCase))
                {
                    ddlIsResolved.SelectedValue = "Yes";
                }
            }

            // Check for IsRepeat filter (Repeat Issues)
            string isRepeatParam = Request.QueryString["isRepeat"];
            if (!string.IsNullOrEmpty(isRepeatParam))
            {
                if (isRepeatParam.Equals("Yes", StringComparison.OrdinalIgnoreCase))
                {
                    ddlIsRepeat.SelectedValue = "Yes";
                }
                else if (isRepeatParam.Equals("No", StringComparison.OrdinalIgnoreCase))
                {
                    ddlIsRepeat.SelectedValue = "No";
                }
            }

            // Re-bind grid with filters applied
            if (!string.IsNullOrEmpty(isResolvedParam) || !string.IsNullOrEmpty(isRepeatParam))
            {
                BindGrid();
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error applying query string filters: " + ex.Message);
        }
    }
}