using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

// Last Modified: October 16, 2025 - 03:32 UTC - Increased toggle column width to 110px for full label visibility
public partial class TED_EquipmentGridView : Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadData();
            
            // Handle URL parameters for filtering (before setting ViewState)
            HandleUrlParameters();
            
            ViewState["DropdownsLoaded"] = true;
        }
        else
        {
            // On postback, re-initialize row highlighting
            ScriptManager.RegisterStartupScript(this, GetType(), "initRows", "setTimeout(function() { initializeRowHighlighting(); }, 100);", true);
        }
    }

    private void HandleUrlParameters()
    {
        try
        {
            // Handle PM Status filter (pmstatus parameter)
            string pmStatusParam = Request.QueryString["pmstatus"];
            if (!string.IsNullOrEmpty(pmStatusParam))
            {
                // Map parameter values to dropdown values
                string dropdownValue = "";
                switch (pmStatusParam.ToUpper())
                {
                    case "OVERDUE":
                        dropdownValue = "OVERDUE";
                        break;
                    case "DUE_SOON":
                    case "DUESOON":
                        dropdownValue = "DUE_SOON";
                        break;
                    case "CURRENT":
                        dropdownValue = "CURRENT";
                        break;
                }
                
                if (!string.IsNullOrEmpty(dropdownValue) && ddlPMStatus != null)
                {
                    ListItem item = ddlPMStatus.Items.FindByValue(dropdownValue);
                    if (item != null)
                    {
                        ddlPMStatus.SelectedValue = dropdownValue;
                        BindGrid(); // Re-bind grid with filter
                    }
                }
            }
            
            // Handle Calibration Status filter (calibrationstatus parameter)
            string calStatusParam = Request.QueryString["calibrationstatus"];
            if (!string.IsNullOrEmpty(calStatusParam))
            {
                // Map parameter values to dropdown values
                string dropdownValue = "";
                switch (calStatusParam.ToUpper())
                {
                    case "DUE_SOON":
                    case "DUESOON":
                        dropdownValue = "DUE_SOON";
                        break;
                    case "OVERDUE":
                        dropdownValue = "OVERDUE";
                        break;
                    case "CURRENT":
                        dropdownValue = "CURRENT";
                        break;
                }
                
                if (!string.IsNullOrEmpty(dropdownValue) && ddlCalibration != null)
                {
                    ListItem item = ddlCalibration.Items.FindByValue(dropdownValue);
                    if (item != null)
                    {
                        ddlCalibration.SelectedValue = dropdownValue;
                        BindGrid(); // Re-bind grid with filter
                    }
                }
            }
            
            // Handle Equipment ID filter (equipment parameter)
            string equipmentParam = Request.QueryString["equipment"];
            if (!string.IsNullOrEmpty(equipmentParam))
            {
                // Set the global search textbox value
                if (txtSearch != null)
                {
                    txtSearch.Text = equipmentParam;
                    BindGrid(); // Re-bind grid with search filter
                }
            }
            
            // Handle Status filter (status parameter)
            string statusParam = Request.QueryString["status"];
            if (!string.IsNullOrEmpty(statusParam))
            {
                // URL decode the status parameter (handles spaces like "In Use")
                string decodedStatus = HttpUtility.UrlDecode(statusParam);
                
                // Add browser console logging for debugging
                Response.Write("<script>console.log('Status parameter received: " + statusParam + "');</script>");
                Response.Write("<script>console.log('Decoded status: " + decodedStatus + "');</script>");
                
                if (ddlStatus != null)
                {
                    // Log all available statuses for debugging
                    var availableStatuses = string.Join(", ", ddlStatus.Items.Cast<ListItem>().Select(i => "'" + i.Text + "'"));
                    Response.Write("<script>console.log('Available statuses: " + availableStatuses + "');</script>");
                    
                    // Try to find by text first, then by value
                    ListItem item = ddlStatus.Items.FindByText(decodedStatus);
                    if (item == null)
                    {
                        item = ddlStatus.Items.FindByValue(decodedStatus);
                    }
                    
                    if (item != null)
                    {
                        ddlStatus.SelectedValue = item.Value;
                        BindGrid(); // Re-bind grid with filter
                        
                        // Debug info
                        Response.Write("<script>console.log('Status filter applied: " + decodedStatus + " -> " + item.Value + "');</script>");
                        System.Diagnostics.Debug.WriteLine("Status filter applied: " + decodedStatus + " -> " + item.Value);
                    }
                    else
                    {
                        // Debug info for failed matches
                        Response.Write("<script>console.error('Status not found in dropdown: " + decodedStatus + "');</script>");
                        System.Diagnostics.Debug.WriteLine("Status not found in dropdown: " + decodedStatus);
                    }
                }
                else
                {
                    Response.Write("<script>console.error('ddlStatus is null');</script>");
                }
            }
            
            // Handle collapse parameter for filter panel
            string collapseParam = Request.QueryString["collapse"];
            if (!string.IsNullOrEmpty(collapseParam) && collapseParam.ToLower() == "true")
            {
                // Use JavaScript to collapse the filter panel on load
                ScriptManager.RegisterStartupScript(this, GetType(), "collapsePanel", 
                    @"setTimeout(function() { 
                        var panel = document.querySelector('.filters-panel');
                        var toggle = document.querySelector('.toggle-filters');
                        if (panel && toggle) {
                            panel.classList.remove('expanded');
                            panel.classList.add('collapsed');
                            toggle.textContent = 'Show Advanced Filters & Search';
                        }
                    }, 100);", true);
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("HandleUrlParameters Error: " + ex.Message);
        }
    }

    private void LoadData()
    {
        try
        {
            LoadStatus();
            LoadLocations();
            LoadManufacturers();
            LoadDeviceTypes();
            LoadCalibrationData();
            LoadPMData();
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

                // Get unique statuses from all tables (ALL 4 tables)
                string query = @"
                    SELECT DISTINCT [CurrentStatus] as Status FROM dbo.Asset_Inventory WHERE [CurrentStatus] IS NOT NULL AND [CurrentStatus] <> ''
                    UNION
                    SELECT DISTINCT [ATEStatus] as Status FROM dbo.ATE_Inventory WHERE [ATEStatus] IS NOT NULL AND [ATEStatus] <> ''
                    UNION
                    SELECT DISTINCT [CurrentStatus] as Status FROM dbo.Fixture_Inventory WHERE [CurrentStatus] IS NOT NULL AND [CurrentStatus] <> ''
                    UNION
                    SELECT DISTINCT [CurrentStatus] as Status FROM dbo.Harness_Inventory WHERE [CurrentStatus] IS NOT NULL AND [CurrentStatus] <> ''
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
                    Response.Write("<script>console.log('Loaded " + count + " status values from all 4 tables');</script>");
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error loading status: " + ex.Message);
            Response.Write("<script>console.error('LoadStatus Error: " + ex.Message.Replace("'", "\\'") + "');</script>");
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

                // Get unique locations from all tables
                string query = @"
                    SELECT DISTINCT [Location] FROM dbo.ATE_Inventory WHERE [Location] IS NOT NULL AND [Location] <> ''
                    UNION
                    SELECT DISTINCT [Location] FROM dbo.Asset_Inventory WHERE [Location] IS NOT NULL AND [Location] <> ''
                    UNION
                    SELECT DISTINCT [Location] FROM dbo.Fixture_Inventory WHERE [Location] IS NOT NULL AND [Location] <> ''
                    UNION
                    SELECT DISTINCT [Location] FROM dbo.Harness_Inventory WHERE [Location] IS NOT NULL AND [Location] <> ''
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

    private void LoadManufacturers()
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
                
                // Clear existing items except "All Manufacturers"
                ddlManufacturer.Items.Clear();
                ddlManufacturer.Items.Add(new ListItem("All Manufacturers", "ALL"));
                
                string query = @"SELECT DISTINCT [Manufacturer] FROM dbo.Asset_Inventory 
                                WHERE [Manufacturer] IS NOT NULL AND [Manufacturer] <> '' 
                                ORDER BY [Manufacturer]";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string mfg = reader["Manufacturer"].ToString();
                        if (!string.IsNullOrWhiteSpace(mfg))
                        {
                            ddlManufacturer.Items.Add(new ListItem(mfg, mfg));
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error loading manufacturers: " + ex.Message);
        }
    }

    private void LoadDeviceTypes()
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
                
                // Clear existing items except "All Device Types"
                ddlDeviceType.Items.Clear();
                ddlDeviceType.Items.Add(new ListItem("All Device Types", "ALL"));
                
                string query = @"SELECT DISTINCT [DeviceType] FROM dbo.Asset_Inventory 
                                WHERE [DeviceType] IS NOT NULL AND [DeviceType] <> '' 
                                ORDER BY [DeviceType]";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string devType = reader["DeviceType"].ToString();
                        if (!string.IsNullOrWhiteSpace(devType))
                        {
                            ddlDeviceType.Items.Add(new ListItem(devType, devType));
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error loading device types: " + ex.Message);
        }
    }

    private void LoadCalibrationData()
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
                
                // Clear existing items
                ddlCalFrequency.Items.Clear();
                ddlCalFrequency.Items.Add(new ListItem("All Frequencies", "ALL"));
                ddlCalibratedBy.Items.Clear();
                ddlCalibratedBy.Items.Add(new ListItem("All Personnel", "ALL"));
                
                // Load calibration frequencies
                string freqQuery = @"
                    SELECT DISTINCT [CalibrationFrequency] FROM dbo.Asset_Inventory WHERE [CalibrationFrequency] IS NOT NULL AND [CalibrationFrequency] <> ''
                    UNION
                    SELECT DISTINCT [CalibrationFrequency] FROM dbo.Fixture_Inventory WHERE [CalibrationFrequency] IS NOT NULL AND [CalibrationFrequency] <> ''
                    UNION
                    SELECT DISTINCT [CalibrationFrequency] FROM dbo.Harness_Inventory WHERE [CalibrationFrequency] IS NOT NULL AND [CalibrationFrequency] <> ''
                    UNION
                    SELECT DISTINCT [CalibrationFrequency] FROM dbo.ATE_Inventory WHERE [CalibrationFrequency] IS NOT NULL AND [CalibrationFrequency] <> ''
                    ORDER BY [CalibrationFrequency]";

                using (SqlCommand cmd = new SqlCommand(freqQuery, conn))
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string freq = reader["CalibrationFrequency"].ToString();
                        if (!string.IsNullOrWhiteSpace(freq))
                        {
                            ddlCalFrequency.Items.Add(new ListItem(freq, freq));
                        }
                    }
                }

                // Load calibrated by personnel
                string calByQuery = @"
                    SELECT DISTINCT [CalibratedBy] FROM dbo.Asset_Inventory WHERE [CalibratedBy] IS NOT NULL AND [CalibratedBy] <> ''
                    UNION
                    SELECT DISTINCT [CalibratedBy] FROM dbo.Fixture_Inventory WHERE [CalibratedBy] IS NOT NULL AND [CalibratedBy] <> ''
                    UNION
                    SELECT DISTINCT [CalibratedBy] FROM dbo.Harness_Inventory WHERE [CalibratedBy] IS NOT NULL AND [CalibratedBy] <> ''
                    UNION
                    SELECT DISTINCT [CalibratedBy] FROM dbo.ATE_Inventory WHERE [CalibratedBy] IS NOT NULL AND [CalibratedBy] <> ''
                    ORDER BY [CalibratedBy]";

                using (SqlCommand cmd = new SqlCommand(calByQuery, conn))
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string calBy = reader["CalibratedBy"].ToString();
                        if (!string.IsNullOrWhiteSpace(calBy))
                        {
                            ddlCalibratedBy.Items.Add(new ListItem(calBy, calBy));
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error loading calibration data: " + ex.Message);
        }
    }

    private void LoadPMData()
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
                
                // Clear existing items
                ddlPMFrequency.Items.Clear();
                ddlPMFrequency.Items.Add(new ListItem("All Frequencies", "ALL"));
                ddlPMResponsible.Items.Clear();
                ddlPMResponsible.Items.Add(new ListItem("All Personnel", "ALL"));
                
                // Load PM frequencies
                string freqQuery = @"
                    SELECT DISTINCT [PMFrequency] FROM dbo.Asset_Inventory WHERE [PMFrequency] IS NOT NULL AND [PMFrequency] <> ''
                    UNION
                    SELECT DISTINCT [PMFrequency] FROM dbo.Fixture_Inventory WHERE [PMFrequency] IS NOT NULL AND [PMFrequency] <> ''
                    UNION
                    SELECT DISTINCT [PMFrequency] FROM dbo.Harness_Inventory WHERE [PMFrequency] IS NOT NULL AND [PMFrequency] <> ''
                    UNION
                    SELECT DISTINCT [PMFrequency] FROM dbo.ATE_Inventory WHERE [PMFrequency] IS NOT NULL AND [PMFrequency] <> ''
                    ORDER BY [PMFrequency]";

                using (SqlCommand cmd = new SqlCommand(freqQuery, conn))
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string freq = reader["PMFrequency"].ToString();
                        if (!string.IsNullOrWhiteSpace(freq))
                        {
                            ddlPMFrequency.Items.Add(new ListItem(freq, freq));
                        }
                    }
                }

                // Load PM responsible personnel
                string pmRespQuery = @"
                    SELECT DISTINCT [PMResponsible] FROM dbo.Asset_Inventory WHERE [PMResponsible] IS NOT NULL AND [PMResponsible] <> ''
                    UNION
                    SELECT DISTINCT [PMResponsible] FROM dbo.Fixture_Inventory WHERE [PMResponsible] IS NOT NULL AND [PMResponsible] <> ''
                    UNION
                    SELECT DISTINCT [PMResponsible] FROM dbo.Harness_Inventory WHERE [PMResponsible] IS NOT NULL AND [PMResponsible] <> ''
                    UNION
                    SELECT DISTINCT [PMResponsible] FROM dbo.ATE_Inventory WHERE [PMResponsible] IS NOT NULL AND [PMResponsible] <> ''
                    ORDER BY [PMResponsible]";

                using (SqlCommand cmd = new SqlCommand(pmRespQuery, conn))
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string pmResp = reader["PMResponsible"].ToString();
                        if (!string.IsNullOrWhiteSpace(pmResp))
                        {
                            ddlPMResponsible.Items.Add(new ListItem(pmResp, pmResp));
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error loading PM data: " + ex.Message);
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
                
                dt = GetCombinedEquipmentData(conn);
                System.Diagnostics.Debug.WriteLine(string.Format("GetCombinedEquipmentData returned {0} rows", dt.Rows.Count));
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

            System.Diagnostics.Debug.WriteLine(string.Format("After filtering: {0} rows", dv.Count));
            Response.Write("<script>console.log('After filtering: " + dv.Count + " rows');</script>");
            Response.Write("<script>console.info('✓ All records loaded - No pagination or row limits applied');</script>");
            litRecordCount.Text = dv.Count.ToString();

            if (dv.Count == 0)
            {
                System.Diagnostics.Debug.WriteLine("No records found - showing empty state");
                Response.Write("<script>console.warn('No records found - showing empty state');</script>");
                gridEquipment.Visible = false;
                pnlEmptyState.Visible = true;
            }
            else
            {
                System.Diagnostics.Debug.WriteLine("Building grid with data");
                Response.Write("<script>console.log('Building grid with " + dv.Count + " rows');</script>");
                gridEquipment.Visible = true;
                pnlEmptyState.Visible = false;

                // Clear and rebuild columns
                gridEquipment.Columns.Clear();
                BuildGridColumns();

                gridEquipment.DataSource = dv;
                gridEquipment.DataBind();
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
            gridEquipment.Visible = false;
            pnlEmptyState.Visible = true;
        }
    }

    private DataTable GetCombinedEquipmentData(SqlConnection conn)
    {
        DataTable combined = new DataTable();

        // Define ALL columns for comprehensive view
        combined.Columns.Add("EquipmentType", typeof(string));
        combined.Columns.Add("EatonID", typeof(string));
        combined.Columns.Add("Model", typeof(string));
        combined.Columns.Add("Name", typeof(string));
        combined.Columns.Add("Description", typeof(string));
        combined.Columns.Add("ATE", typeof(string));
        combined.Columns.Add("Location", typeof(string));
        combined.Columns.Add("DeviceType", typeof(string));
        combined.Columns.Add("Manufacturer", typeof(string));
        combined.Columns.Add("ManufacturerSite", typeof(string));
        combined.Columns.Add("Folder", typeof(string));
        combined.Columns.Add("Image", typeof(string));
        combined.Columns.Add("Status", typeof(string));
        combined.Columns.Add("RequiresCal", typeof(string));
        combined.Columns.Add("CalibrationID", typeof(string));
        combined.Columns.Add("CalibrationFrequency", typeof(string));
        combined.Columns.Add("LastCalibration", typeof(DateTime));
        combined.Columns.Add("CalibratedBy", typeof(string));
        combined.Columns.Add("CalibrationEstimatedTime", typeof(string));
        combined.Columns.Add("NextCalibration", typeof(DateTime));
        combined.Columns.Add("RequiresPM", typeof(string));
        combined.Columns.Add("PMFrequency", typeof(string));
        combined.Columns.Add("PMResponsible", typeof(string));
        combined.Columns.Add("LastPM", typeof(DateTime));
        combined.Columns.Add("PMBy", typeof(string));
        combined.Columns.Add("PMEstimatedTime", typeof(string));
        combined.Columns.Add("NextPM", typeof(DateTime));
        combined.Columns.Add("SwapCapability", typeof(string));
        combined.Columns.Add("Qty", typeof(string));
        combined.Columns.Add("Comments", typeof(string));

        string selectedType = ddlEquipmentType.SelectedValue;
        System.Diagnostics.Debug.WriteLine(string.Format("Loading equipment data for type: {0}", selectedType));
        Response.Write("<script>console.log('GetCombinedEquipmentData: Loading type = " + selectedType + "');</script>");

        // Load Asset Inventory (Most comprehensive)
        if (selectedType == "ALL" || selectedType == "ASSET")
        {
            Response.Write("<script>console.log('Querying Asset_Inventory table...');</script>");
            string query = @"SELECT 'ASSET' as EquipmentType, 
                            ISNULL([EatonID],'') as EatonID, 
                            ISNULL([ModelNo],'') as Model,
                            ISNULL([DeviceName],'') as Name, 
                            ISNULL([DeviceDescription],'') as Description, 
                            ISNULL([ATE],'') as ATE,
                            ISNULL([Location],'') as Location, 
                            ISNULL([DeviceType],'') as DeviceType,
                            ISNULL([Manufacturer],'') as Manufacturer,
                            ISNULL([ManufacturerSite],'') as ManufacturerSite,
                            ISNULL([DeviceFolder],'') as Folder,
                            ISNULL([DeviceImage],'') as Image,
                            ISNULL([CurrentStatus],'') as Status,
                            ISNULL([RequiresCalibration],'') as RequiresCal, 
                            ISNULL([CalibrationID],'') as CalibrationID,
                            ISNULL([CalibrationFrequency],'') as CalibrationFrequency,
                            [LastCalibration] as LastCalibration, 
                            ISNULL([CalibratedBy],'') as CalibratedBy,
                            ISNULL(CAST([CalibrationEstimatedTime] AS NVARCHAR),'') as CalibrationEstimatedTime,
                            [NextCalibration] as NextCalibration,
                            ISNULL([RequiredPM],'') as RequiresPM, 
                            ISNULL([PMFrequency],'') as PMFrequency,
                            ISNULL([PMResponsible],'') as PMResponsible,
                            [LastPM] as LastPM, 
                            ISNULL([PMBy],'') as PMBy,
                            ISNULL(CAST([PMEstimatedTime] AS NVARCHAR),'') as PMEstimatedTime,
                            [NextPM] as NextPM,
                            ISNULL([SwapCapability],'') as SwapCapability,
                            '' as Qty,
                            ISNULL([Comments],'') as Comments
                            FROM dbo.Asset_Inventory";
            LoadTableData(conn, query, combined);
        }

        // Load Fixture Inventory
        if (selectedType == "ALL" || selectedType == "FIXTURE")
        {
            Response.Write("<script>console.log('Querying Fixture_Inventory table...');</script>");
            string query = @"SELECT 'FIXTURE' as EquipmentType, 
                            ISNULL([EatonID],'') as EatonID, 
                            ISNULL([FixtureModelNoName],'') as Model,
                            ISNULL([FixtureModelNoName],'') as Name, 
                            ISNULL([FixtureDescription],'') as Description, 
                            '' as ATE,
                            ISNULL([Location],'') as Location, 
                            'Fixture' as DeviceType,
                            '' as Manufacturer,
                            '' as ManufacturerSite,
                            ISNULL([FixtureFolder],'') as Folder,
                            ISNULL([FixtureImage],'') as Image,
                            ISNULL([CurrentStatus],'') as Status,
                            ISNULL([RequiresCalibration],'') as RequiresCal, 
                            ISNULL([CalibrationID],'') as CalibrationID,
                            ISNULL([CalibrationFrequency],'') as CalibrationFrequency,
                            [LastCalibration] as LastCalibration, 
                            ISNULL([CalibratedBy],'') as CalibratedBy,
                            ISNULL(CAST([CalibrationEstimatedTime] AS NVARCHAR),'') as CalibrationEstimatedTime,
                            [NextCalibration] as NextCalibration,
                            ISNULL([RequiredPM],'') as RequiresPM, 
                            ISNULL([PMFrequency],'') as PMFrequency,
                            ISNULL([PMResponsible],'') as PMResponsible,
                            [LastPM] as LastPM, 
                            ISNULL([PMBy],'') as PMBy,
                            ISNULL(CAST([PMEstimatedTime] AS NVARCHAR),'') as PMEstimatedTime,
                            [NextPM] as NextPM,
                            '' as SwapCapability,
                            '' as Qty,
                            ISNULL([Comments],'') as Comments
                            FROM dbo.Fixture_Inventory";
            LoadTableData(conn, query, combined);
        }

        // Load Harness Inventory
        if (selectedType == "ALL" || selectedType == "HARNESS")
        {
            Response.Write("<script>console.log('Querying Harness_Inventory table...');</script>");
            string query = @"SELECT 'HARNESS' as EquipmentType, 
                            ISNULL([EatonID],'') as EatonID, 
                            ISNULL([HarnessModelNo],'') as Model,
                            ISNULL([HarnessModelNo],'') as Name, 
                            ISNULL([HarnessDescription],'') as Description, 
                            '' as ATE,
                            ISNULL([Location],'') as Location, 
                            'Harness' as DeviceType,
                            '' as Manufacturer,
                            '' as ManufacturerSite,
                            ISNULL([FixtureFolder],'') as Folder,
                            ISNULL([FixtureImage],'') as Image,
                            ISNULL([CurrentStatus],'') as Status,
                            ISNULL([RequiresCalibration],'') as RequiresCal, 
                            ISNULL([CalibrationID],'') as CalibrationID,
                            ISNULL([CalibrationFrequency],'') as CalibrationFrequency,
                            [LastCalibration] as LastCalibration, 
                            ISNULL([CalibratedBy],'') as CalibratedBy,
                            ISNULL(CAST([CalibrationEstimatedTime] AS NVARCHAR),'') as CalibrationEstimatedTime,
                            [NextCalibration] as NextCalibration,
                            ISNULL([RequiredPM],'') as RequiresPM, 
                            ISNULL([PMFrequency],'') as PMFrequency,
                            ISNULL([PMResponsible],'') as PMResponsible,
                            [LastPM] as LastPM, 
                            ISNULL([PMBy],'') as PMBy,
                            ISNULL(CAST([PMEstimatedTime] AS NVARCHAR),'') as PMEstimatedTime,
                            [NextPM] as NextPM,
                            '' as SwapCapability,
                            ISNULL(CAST([Qty] AS NVARCHAR),'') as Qty,
                            ISNULL([Comments],'') as Comments
                            FROM dbo.Harness_Inventory";
            LoadTableData(conn, query, combined);
        }

        // Load ATE Inventory
        if (selectedType == "ALL" || selectedType == "ATE")
        {
            Response.Write("<script>console.log('Querying ATE_Inventory table...');</script>");
            string query = @"SELECT 'ATE' as EquipmentType, 
                            ISNULL([EatonID],'') as EatonID, 
                            '' as Model,
                            ISNULL([ATEName],'') as Name, 
                            ISNULL([ATEDescription],'') as Description, 
                            '' as ATE,
                            ISNULL([Location],'') as Location, 
                            'ATE' as DeviceType,
                            '' as Manufacturer,
                            '' as ManufacturerSite,
                            ISNULL([ATEFolder],'') as Folder,
                            ISNULL([ATEImage],'') as Image,
                            ISNULL([ATEStatus],'') as Status,
                            ISNULL([RequiresCalibration],'') as RequiresCal, 
                            ISNULL([CalibrationID],'') as CalibrationID,
                            ISNULL([CalibrationFrequency],'') as CalibrationFrequency,
                            [LastCalibration] as LastCalibration, 
                            ISNULL([CalibratedBy],'') as CalibratedBy,
                            ISNULL(CAST([CalibrationEstimatedTime] AS NVARCHAR),'') as CalibrationEstimatedTime,
                            [NextCalibration] as NextCalibration,
                            ISNULL([RequiredPM],'') as RequiresPM, 
                            ISNULL([PMFrequency],'') as PMFrequency,
                            ISNULL([PMResponsible],'') as PMResponsible,
                            [LastPM] as LastPM, 
                            ISNULL([LastPMBy],'') as PMBy,
                            ISNULL(CAST([PMEstimatedTime] AS NVARCHAR),'') as PMEstimatedTime,
                            [NextPM] as NextPM,
                            '' as SwapCapability,
                            '' as Qty,
                            ISNULL([Comments],'') as Comments
                            FROM dbo.ATE_Inventory";
            LoadTableData(conn, query, combined);
        }

        return combined;
    }

    private void LoadTableData(SqlConnection conn, string query, DataTable combined)
    {
        try
        {
            System.Diagnostics.Debug.WriteLine("Executing query...");
            using (SqlCommand cmd = new SqlCommand(query, conn))
            using (SqlDataReader reader = cmd.ExecuteReader())
            {
                int rowCount = 0;
                while (reader.Read())
                {
                    rowCount++;
                    DataRow row = combined.NewRow();
                    row["EquipmentType"] = GetSafeValue(reader, "EquipmentType");
                    row["EatonID"] = GetSafeValue(reader, "EatonID");
                    row["Model"] = GetSafeValue(reader, "Model");
                    row["Name"] = GetSafeValue(reader, "Name");
                    row["Description"] = GetSafeValue(reader, "Description");
                    row["ATE"] = GetSafeValue(reader, "ATE");
                    row["Location"] = GetSafeValue(reader, "Location");
                    row["DeviceType"] = GetSafeValue(reader, "DeviceType");
                    row["Manufacturer"] = GetSafeValue(reader, "Manufacturer");
                    row["ManufacturerSite"] = GetSafeValue(reader, "ManufacturerSite");
                    row["Folder"] = GetSafeValue(reader, "Folder");
                    row["Image"] = GetSafeValue(reader, "Image");
                    row["Status"] = GetSafeValue(reader, "Status");
                    row["RequiresCal"] = GetSafeValue(reader, "RequiresCal");
                    row["CalibrationID"] = GetSafeValue(reader, "CalibrationID");
                    row["CalibrationFrequency"] = GetSafeValue(reader, "CalibrationFrequency");
                    
                    if (!reader.IsDBNull(reader.GetOrdinal("LastCalibration")))
                        row["LastCalibration"] = reader.GetDateTime(reader.GetOrdinal("LastCalibration"));
                    
                    row["CalibratedBy"] = GetSafeValue(reader, "CalibratedBy");
                    row["CalibrationEstimatedTime"] = GetSafeValue(reader, "CalibrationEstimatedTime");
                    
                    if (!reader.IsDBNull(reader.GetOrdinal("NextCalibration")))
                        row["NextCalibration"] = reader.GetDateTime(reader.GetOrdinal("NextCalibration"));
                    
                    row["RequiresPM"] = GetSafeValue(reader, "RequiresPM");
                    row["PMFrequency"] = GetSafeValue(reader, "PMFrequency");
                    row["PMResponsible"] = GetSafeValue(reader, "PMResponsible");
                    
                    if (!reader.IsDBNull(reader.GetOrdinal("LastPM")))
                        row["LastPM"] = reader.GetDateTime(reader.GetOrdinal("LastPM"));
                    
                    row["PMBy"] = GetSafeValue(reader, "PMBy");
                    row["PMEstimatedTime"] = GetSafeValue(reader, "PMEstimatedTime");
                    
                    if (!reader.IsDBNull(reader.GetOrdinal("NextPM")))
                        row["NextPM"] = reader.GetDateTime(reader.GetOrdinal("NextPM"));
                    
                    row["SwapCapability"] = GetSafeValue(reader, "SwapCapability");
                    row["Qty"] = GetSafeValue(reader, "Qty");
                    row["Comments"] = GetSafeValue(reader, "Comments");
                    
                    combined.Rows.Add(row);
                }
                System.Diagnostics.Debug.WriteLine(string.Format("Loaded {0} rows from query", rowCount));
                Response.Write("<script>console.log('LoadTableData: Loaded " + rowCount + " rows');</script>");
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine(string.Format("ERROR loading table data: {0}", ex.Message));
            System.Diagnostics.Debug.WriteLine(string.Format("Stack trace: {0}", ex.StackTrace));
            if (ex.InnerException != null)
            {
                System.Diagnostics.Debug.WriteLine(string.Format("Inner exception: {0}", ex.InnerException.Message));
            }
            Response.Write("<script>console.error('LoadTableData ERROR: " + ex.Message.Replace("'", "\\'") + "');</script>");
            Response.Write("<script>console.error('Query failed - check column names match database schema');</script>");
        }
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

    private string GetSafeValueOptional(SqlDataReader reader, string columnName)
    {
        try
        {
            int ordinal = reader.GetOrdinal(columnName);
            return reader.IsDBNull(ordinal) ? string.Empty : reader.GetString(ordinal);
        }
        catch
        {
            // Column doesn't exist in the database - return empty string silently
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
            filters.Add(string.Format("(EatonID LIKE '%{0}%' OR Name LIKE '%{0}%' OR Description LIKE '%{0}%' OR Model LIKE '%{0}%')", escapedSearch));
        }

        // Status filter
        if (ddlStatus.SelectedValue != "ALL")
        {
            string status = ddlStatus.SelectedValue.Replace("'", "''");
            filters.Add(string.Format("Status = '{0}'", status));
        }

        // Location filter
        if (ddlLocation.SelectedValue != "ALL")
        {
            string location = ddlLocation.SelectedValue.Replace("'", "''");
            filters.Add(string.Format("Location = '{0}'", location));
        }

        // Manufacturer filter
        if (ddlManufacturer.SelectedValue != "ALL")
        {
            string mfg = ddlManufacturer.SelectedValue.Replace("'", "''");
            filters.Add(string.Format("Manufacturer = '{0}'", mfg));
        }

        // Device Type filter
        if (ddlDeviceType.SelectedValue != "ALL")
        {
            string devType = ddlDeviceType.SelectedValue.Replace("'", "''");
            filters.Add(string.Format("DeviceType = '{0}'", devType));
        }

        // Swap Capability filter
        if (ddlSwap.SelectedValue != "ALL")
        {
            string swap = ddlSwap.SelectedValue.Replace("'", "''");
            filters.Add(string.Format("SwapCapability = '{0}'", swap));
        }

        // Requires Calibration filter
        if (ddlRequiresCal.SelectedValue != "ALL")
        {
            string reqCal = ddlRequiresCal.SelectedValue.Replace("'", "''");
            if (reqCal == "Yes")
            {
                // Match various representations of "true" or "yes"
                filters.Add("(RequiresCal = '1' OR RequiresCal = 'True' OR RequiresCal = 'Yes' OR RequiresCal = 'Y')");
            }
            else if (reqCal == "No")
            {
                // Match various representations of "false" or "no"
                filters.Add("(RequiresCal = '0' OR RequiresCal = 'False' OR RequiresCal = 'No' OR RequiresCal = 'N' OR RequiresCal = '')");
            }
        }

        // Calibration Status filter
        if (ddlCalibration.SelectedValue != "ALL")
        {
            DateTime now = DateTime.Now;
            DateTime thirtyDays = now.AddDays(30);

            switch (ddlCalibration.SelectedValue)
            {
                case "CURRENT":
                    filters.Add(string.Format("(NextCalibration IS NULL OR NextCalibration > #{0}#)", thirtyDays.ToString("MM/dd/yyyy")));
                    break;
                case "DUE_SOON":
                    // Include both Due Soon (within 30 days) AND Overdue items
                    filters.Add(string.Format("(NextCalibration IS NOT NULL AND NextCalibration <= #{0}#)", thirtyDays.ToString("MM/dd/yyyy")));
                    break;
                case "OVERDUE":
                    filters.Add(string.Format("(NextCalibration IS NOT NULL AND NextCalibration < #{0}#)", now.ToString("MM/dd/yyyy")));
                    break;
            }
        }

        // Calibration Frequency filter
        if (ddlCalFrequency.SelectedValue != "ALL")
        {
            string calFreq = ddlCalFrequency.SelectedValue.Replace("'", "''");
            filters.Add(string.Format("CalibrationFrequency = '{0}'", calFreq));
        }

        // Calibrated By filter
        if (ddlCalibratedBy.SelectedValue != "ALL")
        {
            string calBy = ddlCalibratedBy.SelectedValue.Replace("'", "''");
            filters.Add(string.Format("CalibratedBy = '{0}'", calBy));
        }

        // Requires PM filter
        if (ddlRequiresPM.SelectedValue != "ALL")
        {
            string reqPM = ddlRequiresPM.SelectedValue.Replace("'", "''");
            if (reqPM == "Yes")
            {
                // Match various representations of "true" or "yes"
                filters.Add("(RequiresPM = '1' OR RequiresPM = 'True' OR RequiresPM = 'Yes' OR RequiresPM = 'Y')");
            }
            else if (reqPM == "No")
            {
                // Match various representations of "false" or "no"
                filters.Add("(RequiresPM = '0' OR RequiresPM = 'False' OR RequiresPM = 'No' OR RequiresPM = 'N' OR RequiresPM = '')");
            }
        }

        // PM Status filter
        if (ddlPMStatus.SelectedValue != "ALL")
        {
            DateTime now = DateTime.Now;
            DateTime thirtyDays = now.AddDays(30);

            switch (ddlPMStatus.SelectedValue)
            {
                case "CURRENT":
                    filters.Add(string.Format("(NextPM IS NULL OR NextPM > #{0}#)", thirtyDays.ToString("MM/dd/yyyy")));
                    break;
                case "DUE_SOON":
                    // Include both Due Soon (within 30 days) AND Overdue items
                    filters.Add(string.Format("(NextPM IS NOT NULL AND NextPM <= #{0}#)", thirtyDays.ToString("MM/dd/yyyy")));
                    break;
                case "OVERDUE":
                    filters.Add(string.Format("(NextPM IS NOT NULL AND NextPM < #{0}#)", now.ToString("MM/dd/yyyy")));
                    break;
            }
        }

        // PM Frequency filter
        if (ddlPMFrequency.SelectedValue != "ALL")
        {
            string pmFreq = ddlPMFrequency.SelectedValue.Replace("'", "''");
            filters.Add(string.Format("PMFrequency = '{0}'", pmFreq));
        }

        // PM Responsible filter
        if (ddlPMResponsible.SelectedValue != "ALL")
        {
            string pmResp = ddlPMResponsible.SelectedValue.Replace("'", "''");
            filters.Add(string.Format("PMResponsible = '{0}'", pmResp));
        }

        return string.Join(" AND ", filters);
    }

    private void BuildGridColumns()
    {
        // Equipment Type
        BoundField typeField = new BoundField();
        typeField.DataField = "EquipmentType";
        typeField.HeaderText = "Type";
        typeField.HeaderStyle.CssClass = "col-type";
        typeField.ItemStyle.CssClass = "col-type";
        gridEquipment.Columns.Add(typeField);

        // Eaton ID
        BoundField idField = new BoundField();
        idField.DataField = "EatonID";
        idField.HeaderText = "Eaton ID";
        idField.HeaderStyle.CssClass = "col-id";
        idField.ItemStyle.CssClass = "col-id";
        gridEquipment.Columns.Add(idField);

        // Model Number
        BoundField modelField = new BoundField();
        modelField.DataField = "Model";
        modelField.HeaderText = "Model No.";
        modelField.HeaderStyle.CssClass = "col-model";
        modelField.ItemStyle.CssClass = "col-model";
        gridEquipment.Columns.Add(modelField);

        // Name
        BoundField nameField = new BoundField();
        nameField.DataField = "Name";
        nameField.HeaderText = "Name";
        nameField.HeaderStyle.CssClass = "col-name";
        nameField.ItemStyle.CssClass = "col-name";
        gridEquipment.Columns.Add(nameField);

        // Description
        BoundField descField = new BoundField();
        descField.DataField = "Description";
        descField.HeaderText = "Description";
        descField.HeaderStyle.CssClass = "col-desc";
        descField.ItemStyle.CssClass = "col-desc";
        gridEquipment.Columns.Add(descField);

        // ATE
        BoundField ateField = new BoundField();
        ateField.DataField = "ATE";
        ateField.HeaderText = "ATE";
        ateField.HeaderStyle.CssClass = "col-ate";
        ateField.ItemStyle.CssClass = "col-ate";
        gridEquipment.Columns.Add(ateField);

        // Location
        BoundField locField = new BoundField();
        locField.DataField = "Location";
        locField.HeaderText = "Location";
        locField.HeaderStyle.CssClass = "col-location";
        locField.ItemStyle.CssClass = "col-location";
        gridEquipment.Columns.Add(locField);

        // Device Type
        BoundField devTypeField = new BoundField();
        devTypeField.DataField = "DeviceType";
        devTypeField.HeaderText = "Device Type";
        devTypeField.HeaderStyle.CssClass = "col-devtype";
        devTypeField.ItemStyle.CssClass = "col-devtype";
        gridEquipment.Columns.Add(devTypeField);

        // Manufacturer
        BoundField mfgField = new BoundField();
        mfgField.DataField = "Manufacturer";
        mfgField.HeaderText = "Manufacturer";
        mfgField.HeaderStyle.CssClass = "col-mfg";
        mfgField.ItemStyle.CssClass = "col-mfg";
        gridEquipment.Columns.Add(mfgField);

        // Manufacturer Site
        BoundField mfgSiteField = new BoundField();
        mfgSiteField.DataField = "ManufacturerSite";
        mfgSiteField.HeaderText = "Mfg Site";
        mfgSiteField.HeaderStyle.CssClass = "col-mfgsite";
        mfgSiteField.ItemStyle.CssClass = "col-mfgsite";
        gridEquipment.Columns.Add(mfgSiteField);

        // Folder (URL)
        BoundField folderField = new BoundField();
        folderField.DataField = "Folder";
        folderField.HeaderText = "Folder";
        folderField.HeaderStyle.CssClass = "col-folder";
        folderField.ItemStyle.CssClass = "col-folder";
        gridEquipment.Columns.Add(folderField);

        // Image (URL)
        BoundField imageField = new BoundField();
        imageField.DataField = "Image";
        imageField.HeaderText = "Image";
        imageField.HeaderStyle.CssClass = "col-image";
        imageField.ItemStyle.CssClass = "col-image";
        gridEquipment.Columns.Add(imageField);

        // Status
        BoundField statusField = new BoundField();
        statusField.DataField = "Status";
        statusField.HeaderText = "Status";
        statusField.HeaderStyle.CssClass = "col-status";
        statusField.ItemStyle.CssClass = "col-status";
        gridEquipment.Columns.Add(statusField);

        // Requires Calibration
        BoundField reqCalField = new BoundField();
        reqCalField.DataField = "RequiresCal";
        reqCalField.HeaderText = "Req. Cal";
        reqCalField.HeaderStyle.CssClass = "col-cal";
        reqCalField.ItemStyle.CssClass = "col-cal";
        gridEquipment.Columns.Add(reqCalField);

        // Calibration ID
        BoundField calIDField = new BoundField();
        calIDField.DataField = "CalibrationID";
        calIDField.HeaderText = "Cal ID";
        calIDField.HeaderStyle.CssClass = "col-calid";
        calIDField.ItemStyle.CssClass = "col-calid";
        gridEquipment.Columns.Add(calIDField);

        // Calibration Frequency
        BoundField calFreqField = new BoundField();
        calFreqField.DataField = "CalibrationFrequency";
        calFreqField.HeaderText = "Cal Freq";
        calFreqField.HeaderStyle.CssClass = "col-freq";
        calFreqField.ItemStyle.CssClass = "col-freq";
        gridEquipment.Columns.Add(calFreqField);

        // Last Calibration
        BoundField lastCalField = new BoundField();
        lastCalField.DataField = "LastCalibration";
        lastCalField.HeaderText = "Last Cal";
        lastCalField.DataFormatString = "{0:MM/dd/yyyy}";
        lastCalField.HeaderStyle.CssClass = "col-date";
        lastCalField.ItemStyle.CssClass = "col-date";
        gridEquipment.Columns.Add(lastCalField);

        // Calibrated By
        BoundField calByField = new BoundField();
        calByField.DataField = "CalibratedBy";
        calByField.HeaderText = "Cal By";
        calByField.HeaderStyle.CssClass = "col-by";
        calByField.ItemStyle.CssClass = "col-by";
        gridEquipment.Columns.Add(calByField);

        // Calibration Estimated Time
        BoundField calEstTimeField = new BoundField();
        calEstTimeField.DataField = "CalibrationEstimatedTime";
        calEstTimeField.HeaderText = "Cal Est Time";
        calEstTimeField.HeaderStyle.CssClass = "col-time";
        calEstTimeField.ItemStyle.CssClass = "col-time";
        gridEquipment.Columns.Add(calEstTimeField);

        // Next Calibration
        BoundField nextCalField = new BoundField();
        nextCalField.DataField = "NextCalibration";
        nextCalField.HeaderText = "Next Cal";
        nextCalField.DataFormatString = "{0:MM/dd/yyyy}";
        nextCalField.HeaderStyle.CssClass = "col-date";
        nextCalField.ItemStyle.CssClass = "col-date";
        gridEquipment.Columns.Add(nextCalField);

        // Requires PM
        BoundField reqPMField = new BoundField();
        reqPMField.DataField = "RequiresPM";
        reqPMField.HeaderText = "Req. PM";
        reqPMField.HeaderStyle.CssClass = "col-pm";
        reqPMField.ItemStyle.CssClass = "col-pm";
        gridEquipment.Columns.Add(reqPMField);

        // PM Frequency
        BoundField pmFreqField = new BoundField();
        pmFreqField.DataField = "PMFrequency";
        pmFreqField.HeaderText = "PM Freq";
        pmFreqField.HeaderStyle.CssClass = "col-freq";
        pmFreqField.ItemStyle.CssClass = "col-freq";
        gridEquipment.Columns.Add(pmFreqField);

        // PM Responsible
        BoundField pmRespField = new BoundField();
        pmRespField.DataField = "PMResponsible";
        pmRespField.HeaderText = "PM Resp";
        pmRespField.HeaderStyle.CssClass = "col-resp";
        pmRespField.ItemStyle.CssClass = "col-resp";
        gridEquipment.Columns.Add(pmRespField);

        // Last PM
        BoundField lastPMField = new BoundField();
        lastPMField.DataField = "LastPM";
        lastPMField.HeaderText = "Last PM";
        lastPMField.DataFormatString = "{0:MM/dd/yyyy}";
        lastPMField.HeaderStyle.CssClass = "col-date";
        lastPMField.ItemStyle.CssClass = "col-date";
        gridEquipment.Columns.Add(lastPMField);

        // PM By
        BoundField pmByField = new BoundField();
        pmByField.DataField = "PMBy";
        pmByField.HeaderText = "PM By";
        pmByField.HeaderStyle.CssClass = "col-by";
        pmByField.ItemStyle.CssClass = "col-by";
        gridEquipment.Columns.Add(pmByField);

        // PM Estimated Time
        BoundField pmEstTimeField = new BoundField();
        pmEstTimeField.DataField = "PMEstimatedTime";
        pmEstTimeField.HeaderText = "PM Est Time";
        pmEstTimeField.HeaderStyle.CssClass = "col-time";
        pmEstTimeField.ItemStyle.CssClass = "col-time";
        gridEquipment.Columns.Add(pmEstTimeField);

        // Next PM
        BoundField nextPMField = new BoundField();
        nextPMField.DataField = "NextPM";
        nextPMField.HeaderText = "Next PM";
        nextPMField.DataFormatString = "{0:MM/dd/yyyy}";
        nextPMField.HeaderStyle.CssClass = "col-date";
        nextPMField.ItemStyle.CssClass = "col-date";
        gridEquipment.Columns.Add(nextPMField);

        // Swap Capability
        BoundField swapField = new BoundField();
        swapField.DataField = "SwapCapability";
        swapField.HeaderText = "Swap";
        swapField.HeaderStyle.CssClass = "col-swap";
        swapField.ItemStyle.CssClass = "col-swap";
        gridEquipment.Columns.Add(swapField);

        // Quantity (for Harness)
        BoundField qtyField = new BoundField();
        qtyField.DataField = "Qty";
        qtyField.HeaderText = "Qty";
        qtyField.HeaderStyle.CssClass = "col-qty";
        qtyField.ItemStyle.CssClass = "col-qty";
        gridEquipment.Columns.Add(qtyField);

        // Comments
        BoundField commentsField = new BoundField();
        commentsField.DataField = "Comments";
        commentsField.HeaderText = "Comments";
        commentsField.HeaderStyle.CssClass = "col-comments";
        commentsField.ItemStyle.CssClass = "col-comments";
        gridEquipment.Columns.Add(commentsField);
    }

    private string GetBaseUrl()
    {
        string serverName = ConfigurationManager.AppSettings["ServerName"] ?? "localhost";
        return string.Format("http://{0}/Test%20Engineering%20Dashboard/", serverName);
    }

    private string GetServerNamePrefix()
    {
        string serverName = ConfigurationManager.AppSettings["ServerName"] ?? "localhost";
        return string.Format("\\\\{0}\\", serverName);
    }

    protected void gridEquipment_RowDataBound(object sender, GridViewRowEventArgs e)
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
                
                // Set width for Req. Cal (column 13) and Req. PM (column 20)
                if (i == 13 || i == 20)
                {
                    cell.Style["min-width"] = "110px";
                    cell.Style["width"] = "110px";
                }
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
                
                // Apply styling to Equipment Type cell (Column 0)
                if (e.Row.Cells.Count > 0)
                {
                    string type = drv["EquipmentType"].ToString().ToLower();
                    string typeBadge = string.Format("<span class='type-badge type-{0}'>{1}</span>", type, drv["EquipmentType"]);
                    e.Row.Cells[0].Text = typeBadge;
                }

                // Make ManufacturerSite URL clickable (Column 9)
                if (e.Row.Cells.Count > 9)
                {
                    string mfgSite = drv["ManufacturerSite"].ToString();
                    if (!string.IsNullOrEmpty(mfgSite) && (mfgSite.StartsWith("http://") || mfgSite.StartsWith("https://")))
                    {
                        e.Row.Cells[9].Text = string.Format("<a href='{0}' target='_blank' style='color:#0066cc; text-decoration:none;' title='{0}'>{0}</a>", mfgSite);
                    }
                }

                // Make Folder URL clickable (Column 10) - Convert network paths to HTTP URLs
                if (e.Row.Cells.Count > 10)
                {
                    string folder = drv["Folder"].ToString();
                    if (!string.IsNullOrEmpty(folder))
                    {
                        string folderUrl = folder;
                        string baseUrl = GetBaseUrl();
                        
                        // If it's a relative path (starts with Storage/), convert to HTTP URL
                        if (folder.StartsWith("Storage/", StringComparison.OrdinalIgnoreCase))
                        {
                            string serverName = ConfigurationManager.AppSettings["ServerName"] ?? "localhost";
                            string relativePath = folder.Substring(8); // Remove "Storage/"
                            folderUrl = string.Format("http://{0}/Test%20Engineering%20Dashboard/Storage/{1}", serverName, relativePath.Replace("\\", "/"));
                        }
                        // If it's a network path (\\servername\...), convert to HTTP URL
                        else
                        {
                            string serverPrefix = GetServerNamePrefix();
                            if (folder.StartsWith(serverPrefix, StringComparison.OrdinalIgnoreCase))
                            {
                                // Remove \\servername\ and convert to HTTP URL
                                string relativePath = folder.Substring(serverPrefix.Length); // Remove "\\servername\"
                                relativePath = relativePath.Replace("\\", "/");
                                folderUrl = baseUrl + System.Uri.EscapeDataString(relativePath).Replace("%2F", "/");
                            }
                            // If it's already an HTTP/HTTPS URL, use as-is
                            else if (folder.StartsWith("http://", StringComparison.OrdinalIgnoreCase) || 
                                     folder.StartsWith("https://", StringComparison.OrdinalIgnoreCase))
                            {
                                folderUrl = folder;
                            }
                            // If it's a relative path starting with Storage/ or similar
                            else if (!folder.StartsWith("\\\\"))
                            {
                                folderUrl = baseUrl + System.Uri.EscapeDataString(folder).Replace("%2F", "/");
                            }
                        }
                        
                        e.Row.Cells[10].Text = string.Format("<a href='{0}' target='_blank' style='color:#0066cc; text-decoration:none;' title='Open folder: {1}'>{1}</a>", 
                            folderUrl,
                            System.Web.HttpUtility.HtmlEncode(folder));
                    }
                }
                
                // Make Image URL clickable (Column 11) - Add server URL if path is relative
                if (e.Row.Cells.Count > 11)
                {
                    string image = drv["Image"].ToString();
                    if (!string.IsNullOrEmpty(image))
                    {
                        string imageUrl = image;
                        string baseUrl = GetBaseUrl();
                        
                        // If it's a relative path (starts with Storage/ or Uploads/), convert to HTTP URL
                        if (image.StartsWith("Storage/", StringComparison.OrdinalIgnoreCase))
                        {
                            string serverName = ConfigurationManager.AppSettings["ServerName"] ?? "localhost";
                            string relativePath = image.Substring(8); // Remove "Storage/"
                            imageUrl = string.Format("http://{0}/Test%20Engineering%20Dashboard/Storage/{1}", serverName, relativePath.Replace("\\", "/"));
                        }
                        else if (image.StartsWith("Uploads/", StringComparison.OrdinalIgnoreCase))
                        {
                            string serverName = ConfigurationManager.AppSettings["ServerName"] ?? "localhost";
                            string relativePath = image.Substring(8); // Remove "Uploads/"
                            imageUrl = string.Format("http://{0}/Test%20Engineering%20Dashboard/Uploads/{1}", serverName, relativePath.Replace("\\", "/"));
                        }
                        // If it's already a full URL, use as-is
                        else if (image.StartsWith("http://") || image.StartsWith("https://"))
                        {
                            imageUrl = image;
                        }
                        // If it's a network path (\\servername\...), convert to HTTP URL
                        else if (image.StartsWith("\\\\"))
                        {
                            string serverPrefix = GetServerNamePrefix();
                            if (image.StartsWith(serverPrefix, StringComparison.OrdinalIgnoreCase))
                            {
                                // Remove \\servername\ and convert to HTTP URL
                                string relativePath = image.Substring(serverPrefix.Length); // Remove "\\servername\"
                                relativePath = relativePath.Replace("\\", "/");
                                imageUrl = baseUrl + System.Uri.EscapeDataString(relativePath).Replace("%2F", "/");
                            }
                        }
                        // If it's a relative path without leading slash
                        else
                        {
                            imageUrl = baseUrl + image;
                        }
                        
                        e.Row.Cells[11].Text = string.Format("<a href='{0}' target='_blank' style='color:#0066cc; text-decoration:none;' title='{0}'>{0}</a>", imageUrl);
                    }
                }

                // Apply styling to Status cell (Column 12 - after Type, ID, Model, Name, Desc, ATE, Location, DevType, Mfg, MfgSite, Folder, Image)
                if (e.Row.Cells.Count > 12)
                {
                    string status = drv["Status"].ToString();
                    if (!string.IsNullOrEmpty(status))
                    {
                        // Handle special characters in status (like slashes)
                        string statusClass = "status-" + status.ToLower()
                            .Replace(" ", "-")
                            .Replace("_", "-")
                            .Replace("/", "-")
                            .Replace("(", "")
                            .Replace(")", "");
                        string statusBadge = string.Format("<span class='status-badge {0}' title='{1}'>{1}</span>", statusClass, status);
                        e.Row.Cells[12].Text = statusBadge;
                    }
                }

                // Apply toggle styling to Req. Cal cell (Column 13)
                if (e.Row.Cells.Count > 13)
                {
                    e.Row.Cells[13].Style["min-width"] = "110px";
                    e.Row.Cells[13].Style["width"] = "110px";
                    string reqCal = drv["RequiresCal"].ToString().ToLower();
                    bool isRequired = reqCal == "true" || reqCal == "yes" || reqCal == "1";
                    string toggleClass = isRequired ? "toggle-on" : "toggle-off";
                    string toggleLabel = isRequired ? "Yes" : "No";
                    e.Row.Cells[13].Text = string.Format("<div class='toggle-switch {0}' title='{1}'><div class='toggle-slider'></div><span class='toggle-label'>{1}</span></div>", toggleClass, toggleLabel);
                }

                // Style Next Calibration cell (Column 19 - after Type[0], ID[1], Model[2], Name[3], Desc[4], ATE[5], Location[6], DevType[7], Mfg[8], MfgSite[9], Folder[10], Image[11], Status[12], ReqCal[13], CalID[14], CalFreq[15], LastCal[16], CalBy[17], CalEstTime[18])
                if (e.Row.Cells.Count > 19)
                {
                    StyleNextDateCell(e.Row.Cells[19], drv["NextCalibration"]);
                }

                // Apply toggle styling to Req. PM cell (Column 20)
                if (e.Row.Cells.Count > 20)
                {
                    e.Row.Cells[20].Style["min-width"] = "110px";
                    e.Row.Cells[20].Style["width"] = "110px";
                    string reqPM = drv["RequiresPM"].ToString().ToLower();
                    bool isRequired = reqPM == "true" || reqPM == "yes" || reqPM == "1";
                    string toggleClass = isRequired ? "toggle-on" : "toggle-off";
                    string toggleLabel = isRequired ? "Yes" : "No";
                    e.Row.Cells[20].Text = string.Format("<div class='toggle-switch {0}' title='{1}'><div class='toggle-slider'></div><span class='toggle-label'>{1}</span></div>", toggleClass, toggleLabel);
                }

                // Style Next PM cell (Column 27 - after NextCal[19], ReqPM[20], PMFreq[21], PMResp[22], LastPM[23], PMBy[24], PMEstTime[25], NextPM[26])
                // Wait, let me recount: after CalEstTime[18], we have NextCal[19], ReqPM[20], PMFreq[21], PMResp[22], LastPM[23], PMBy[24], PMEstTime[25], NextPM[26]
                if (e.Row.Cells.Count > 26)
                {
                    StyleNextDateCell(e.Row.Cells[26], drv["NextPM"]);
                }
            }
        }
    }

    private void StyleNextDateCell(TableCell cell, object dateValue)
    {
        if (dateValue == null || dateValue == DBNull.Value)
        {
            cell.Text = "<span style='color:#888;'>01/01/1900</span>";
            return;
        }

        DateTime date;
        if (DateTime.TryParse(dateValue.ToString(), out date))
        {
            // Check if it's a default/null date
            if (date.Year == 1900)
            {
                cell.Text = "<span style='color:#888;'>01/01/1900</span>";
                return;
            }

            DateTime now = DateTime.Now;
            DateTime thirtyDays = now.AddDays(30);
            string color = "#10b981"; // Green - good
            string bgColor = "rgba(16, 185, 129, 0.1)";

            if (date < now)
            {
                // Overdue - Red
                color = "#ef4444";
                bgColor = "rgba(239, 68, 68, 0.15)";
            }
            else if (date <= thirtyDays)
            {
                // Due soon (within 30 days) - Yellow/Orange
                color = "#f59e0b";
                bgColor = "rgba(245, 158, 11, 0.15)";
            }

            cell.Text = string.Format("<span style='color:{0}; background:{1}; padding:4px 8px; border-radius:4px; font-weight:600; display:inline-block;'>{2:MM/dd/yyyy}</span>", 
                color, bgColor, date);
        }
    }

    private void StyleLastActivityCell(TableCell cell, object dateValue, string activityType)
    {
        if (dateValue == null || dateValue == DBNull.Value || string.IsNullOrEmpty(dateValue.ToString()))
        {
            cell.Text = "<span class='activity-badge activity-none'>N/A</span>";
            return;
        }

        DateTime date;
        if (DateTime.TryParse(dateValue.ToString(), out date))
        {
            TimeSpan diff = DateTime.Now - date;
            int daysSince = (int)diff.TotalDays;
            
            string badgeClass = "activity-badge ";
            if (daysSince > 365)
            {
                badgeClass += "activity-overdue"; // Red - very old
            }
            else if (daysSince > 180)
            {
                badgeClass += "activity-warning"; // Yellow - getting old
            }
            else
            {
                badgeClass += "activity-good"; // Green - recent
            }

            cell.Text = string.Format("<span class='{0}'>{1:MM/dd/yyyy}</span>", badgeClass, date);
        }
    }

    private void StyleDateCell(TableCell cell, object dateValue)
    {
        if (dateValue == null || dateValue == DBNull.Value || string.IsNullOrEmpty(dateValue.ToString()))
        {
            cell.Text = "<span class='date-cell' style='opacity:0.4;'>N/A</span>";
            return;
        }

        DateTime date;
        if (DateTime.TryParse(dateValue.ToString(), out date))
        {
            DateTime now = DateTime.Now;
            DateTime thirtyDays = now.AddDays(30);
            string cssClass = "date-cell";

            if (date < now)
            {
                cssClass += " date-overdue";
            }
            else if (date <= thirtyDays)
            {
                cssClass += " date-due-soon";
            }
            else
            {
                cssClass += " date-good";
            }

            cell.Text = string.Format("<span class='{0}'>{1}</span>", cssClass, date.ToString("MM/dd/yyyy"));
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
        ddlEquipmentType.SelectedValue = "ALL";
        ddlStatus.SelectedValue = "ALL";
        ddlLocation.SelectedValue = "ALL";
        ddlManufacturer.SelectedValue = "ALL";
        ddlDeviceType.SelectedValue = "ALL";
        ddlSwap.SelectedValue = "ALL";
        ddlRequiresCal.SelectedValue = "ALL";
        ddlCalibration.SelectedValue = "ALL";
        ddlCalFrequency.SelectedValue = "ALL";
        ddlCalibratedBy.SelectedValue = "ALL";
        ddlRequiresPM.SelectedValue = "ALL";
        ddlPMFrequency.SelectedValue = "ALL";
        ddlPMResponsible.SelectedValue = "ALL";
        
        // Clear ViewState to allow reloading dropdowns
        ViewState["DropdownsLoaded"] = null;
        
        LoadData();
        
        // Set ViewState back after loading
        ViewState["DropdownsLoaded"] = true;
        
        // Update filter count after reset
        ScriptManager.RegisterStartupScript(this, GetType(), "resetFilters", "setTimeout(function() { updateFilterCount(); initializeRowHighlighting(); }, 100);", true);
    }

    protected void ExportToCSV(object sender, EventArgs e)
    {
        try
        {
            StringBuilder csv = new StringBuilder();

            // Headers - All 32 columns (added Folder, Image, CalEstTime, PMEstTime)
            csv.AppendLine("Equipment Type,Eaton ID,Model No,Name,Description,ATE,Location,Device Type,Manufacturer,Mfg Site,Folder,Image,Status,Req Cal,Cal ID,Cal Freq,Last Cal,Cal By,Cal Est Time,Next Cal,Req PM,PM Freq,PM Resp,Last PM,PM By,PM Est Time,Next PM,Swap,Qty,Comments");

            // Data
            foreach (GridViewRow row in gridEquipment.Rows)
            {
                if (row.RowType == DataControlRowType.DataRow)
                {
                    var cells = new string[32];
                    for (int i = 0; i < Math.Min(32, row.Cells.Count); i++)
                    {
                        string cellText = row.Cells[i].Text.Replace(",", ";").Replace("&nbsp;", "");
                        // Remove HTML tags
                        cellText = System.Text.RegularExpressions.Regex.Replace(cellText, "<.*?>", string.Empty);
                        cells[i] = cellText;
                    }
                    csv.AppendLine(string.Join(",", cells));
                }
            }

            // Send to client
            Response.Clear();
            Response.Buffer = true;
            Response.AddHeader("content-disposition", string.Format("attachment;filename=EquipmentInventory_{0}.csv", DateTime.Now.ToString("yyyyMMdd")));
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
