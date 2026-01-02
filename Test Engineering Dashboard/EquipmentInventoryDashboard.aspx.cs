using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Collections.Generic;
using System.Linq;
using System.Web.Script.Serialization;

public partial class TED_EquipmentInventoryDashboard : Page
{
    // Chart data properties (exposed to JavaScript)
    public string SankeyData { get; set; }  // For Sankey diagram
    public string TypeLabels { get; set; }
    public string TypeData { get; set; }
    public string LineLabels { get; set; }
    public string LineData { get; set; }
    public string LineDatasets { get; set; }  // For stacked chart
    public string StatusLabels { get; set; }
    public string StatusData { get; set; }
    public string LocationLabels { get; set; }
    public string LocationData { get; set; }
    public string LocationDatasets { get; set; }  // For stacked chart
    public string AssetTypeLabels { get; set; }
    public string AssetTypeData { get; set; }
    public string CalibrationLabels { get; set; }
    public string CalibrationData { get; set; }
    public string PMLabels { get; set; }
    public string PMData { get; set; }
    
    // Additional properties for hybrid KPI charts
    public string UtilizationPercent { get; set; }
    public string OutOfServiceCount { get; set; }
    public string CalibrationOverdue { get; set; }
    public string CalibrationDueSoon { get; set; }
    public string PMOverdue { get; set; }
    public string PMDueSoon { get; set; }
    public string SparesTypeLabels { get; set; }
    public string SparesTypeData { get; set; }

    protected void Page_Load(object sender, EventArgs e)
    {
        // Initialize all chart data properties with defaults to prevent null reference errors
        InitializeDefaultChartData();
        
        if (!IsPostBack)
        {
            LoadSidebarUser();
            LoadKPIs();
            
            System.Diagnostics.Debug.WriteLine("=== Page_Load: About to call LoadChartData ===");
            Response.Write("<script>console.log('Page_Load: Calling LoadChartData...');</script>");
            
            LoadChartData();
            
            System.Diagnostics.Debug.WriteLine("=== Page_Load: LoadChartData completed ===");
            Response.Write("<script>console.log('Page_Load: LoadChartData completed');</script>");
            
            LoadRecentAdditions();
        }
    }

    private void InitializeDefaultChartData()
    {
        var serializer = new JavaScriptSerializer();
        
        // Initialize all properties with safe defaults
        SankeyData = serializer.Serialize(new { nodes = new object[0], links = new object[0] });
        TypeLabels = serializer.Serialize(new[] { "No Data" });
        TypeData = serializer.Serialize(new[] { 1 });
        LineLabels = serializer.Serialize(new[] { "No Data" });
        LineData = serializer.Serialize(new[] { 1 });
        LineDatasets = "[]";
        StatusLabels = serializer.Serialize(new[] { "No Data" });
        StatusData = serializer.Serialize(new[] { 1 });
        LocationLabels = serializer.Serialize(new[] { "No Data" });
        LocationData = serializer.Serialize(new[] { 1 });
        LocationDatasets = "[]";
        AssetTypeLabels = serializer.Serialize(new[] { "No Data" });
        AssetTypeData = serializer.Serialize(new[] { 1 });
        CalibrationLabels = serializer.Serialize(new[] { "No Data" });
        CalibrationData = serializer.Serialize(new[] { 1 });
        PMLabels = serializer.Serialize(new[] { "No Data" });
        PMData = serializer.Serialize(new[] { 1 });
        
        // Initialize hybrid chart properties
        UtilizationPercent = "0";
        OutOfServiceCount = "0";
        CalibrationOverdue = "0";
        CalibrationDueSoon = "0";
        PMOverdue = "0";
        PMDueSoon = "0";
        SparesTypeLabels = serializer.Serialize(new[] { "Asset", "ATE", "Fixture", "Harness" });
        SparesTypeData = serializer.Serialize(new[] { 3, 2, 1, 1 });
    }

    private void LoadSidebarUser()
    {
        try
        {
            string fullName = Session["TED:FullName"] as string;
            if (string.IsNullOrWhiteSpace(fullName))
                fullName = Context != null && Context.User != null ? Context.User.Identity.Name : string.Empty;
            if (string.IsNullOrEmpty(fullName)) fullName = "User";
            string initials = GetInitials(fullName);

            if (litInitials != null) litInitials.Text = initials;
            if (litFullName != null) litFullName.Text = fullName;
            if (litRole != null) litRole.Text = (Session["TED:JobRole"] as string) ?? (Session["TED:UserCategory"] as string) ?? "";

            var profileRel = Session["TED:ProfilePath"] as string;
            bool hasAvatar = !string.IsNullOrWhiteSpace(profileRel);
            if (hasAvatar && imgAvatar != null)
            {
                imgAvatar.ImageUrl = ResolveUrl(profileRel);
                imgAvatar.Visible = true;
                if (avatarFallback != null) avatarFallback.Visible = false;
            }
            else
            {
                if (imgAvatar != null) imgAvatar.Visible = false;
                if (avatarFallback != null) avatarFallback.Visible = true;
            }

            // Admin menu visibility
            if (lnkAdminPortal != null)
            {
                var cat = (Session["TED:UserCategory"] as string ?? string.Empty).ToLowerInvariant();
                var role = (Session["TED:JobRole"] as string ?? string.Empty).ToLowerInvariant();
                bool isAdmin = cat.Contains("admin") || role.Contains("admin");
                
                if (!isAdmin)
                {
                    lnkAdminPortal.CssClass += " disabled";
                    lnkAdminPortal.NavigateUrl = "javascript:void(0)";
                }
            }
        }
        catch { }
    }

    private string GetInitials(string input)
    {
        try
        {
            var parts = input.Split(new[] { ' ', '.', '_' }, StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length == 0) return "U";
            if (parts.Length == 1) return parts[0].Substring(0, Math.Min(2, parts[0].Length)).ToUpperInvariant();
            return (parts[0].Substring(0, 1) + parts[parts.Length - 1].Substring(0, 1)).ToUpperInvariant();
        }
        catch { return "U"; }
    }

    private void LoadKPIs()
    {
        try
        {
            var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
            using (var conn = new SqlConnection(cs))
            {
                conn.Open();
                
                // First, get out of service count
                int outOfService = 0;
                try
                {
                    var outOfServiceQuery = @"
                        SELECT COUNT(*) AS OutOfServiceCount
                        FROM (
                            SELECT ATEStatus AS Status FROM dbo.ATE_Inventory WHERE IsActive = 1
                            UNION ALL
                            SELECT CurrentStatus AS Status FROM dbo.Asset_Inventory WHERE IsActive = 1
                            UNION ALL
                            SELECT CurrentStatus AS Status FROM dbo.Fixture_Inventory WHERE IsActive = 1
                            UNION ALL
                            SELECT CurrentStatus AS Status FROM dbo.Harness_Inventory WHERE IsActive = 1
                        ) AS AllEquipment
                        WHERE Status IN ('Out of Service - Damaged', 'Out of Service - Under Repair', 
                                         'Out of Service - In Calibration', 'Scraped', 'Scraped / Returned to vendor')";
                    
                    using (var outCmd = new SqlCommand(outOfServiceQuery, conn))
                    using (var outRdr = outCmd.ExecuteReader())
                    {
                        if (outRdr.Read())
                        {
                            outOfService = GetInt(outRdr, "OutOfServiceCount");
                        }
                    }
                    Response.Write("<script>console.log('Out of Service Count: " + outOfService + "');</script>");
                }
                catch (Exception outEx)
                {
                    System.Diagnostics.Debug.WriteLine("Out of Service query error: " + outEx.Message);
                    Response.Write("<script>console.error('Out of Service query error: " + outEx.Message.Replace("'", "\\'") + "');</script>");
                }
                
                // Second, get spares count
                int sparesEquipment = 0;
                try
                {
                    var sparesQuery = @"
                        SELECT COUNT(*) AS SpareCount
                        FROM (
                            SELECT ATEStatus AS Status FROM dbo.ATE_Inventory WHERE IsActive = 1
                            UNION ALL
                            SELECT CurrentStatus AS Status FROM dbo.Asset_Inventory WHERE IsActive = 1
                            UNION ALL
                            SELECT CurrentStatus AS Status FROM dbo.Fixture_Inventory WHERE IsActive = 1
                            UNION ALL
                            SELECT CurrentStatus AS Status FROM dbo.Harness_Inventory WHERE IsActive = 1
                        ) AS AllEquipment
                        WHERE Status = 'Spare'";
                    
                    using (var spareCmd = new SqlCommand(sparesQuery, conn))
                    using (var spareRdr = spareCmd.ExecuteReader())
                    {
                        if (spareRdr.Read())
                        {
                            sparesEquipment = GetInt(spareRdr, "SpareCount");
                        }
                    }
                    Response.Write("<script>console.log('Spare Equipment Count: " + sparesEquipment + "');</script>");
                }
                catch (Exception spareEx)
                {
                    System.Diagnostics.Debug.WriteLine("Spares query error: " + spareEx.Message);
                    Response.Write("<script>console.error('Spares query error: " + spareEx.Message.Replace("'", "\\'") + "');</script>");
                }
                
                // Now load main KPIs
                using (var cmd = new SqlCommand("SELECT * FROM dbo.vw_EquipmentInventory_Dashboard_KPIs", conn))
                using (var rdr = cmd.ExecuteReader())
                {
                    if (rdr.Read())
                    {
                        // Total Equipment
                        int totalEquipment = GetInt(rdr, "TotalEquipment");
                        if (litTotalEquipment != null) litTotalEquipment.Text = totalEquipment.ToString();

                        // Active Equipment with Utilization Rate
                        int activeEquipment = GetInt(rdr, "ActiveEquipment");
                        int inactiveEquipment = GetInt(rdr, "InactiveEquipment");
                        decimal utilization = GetDecimal(rdr, "UtilizationRate");
                        if (litActiveEquipment != null) litActiveEquipment.Text = activeEquipment.ToString();
                        
                        // Color code out of service count: orange (1-3), red (>3), bold - apply to whole footer text
                        if (litOutOfService != null)
                        {
                            string color = outOfService >= 1 && outOfService <= 3 ? "#f59e0b" : 
                                          outOfService > 3 ? "#ef4444" : "#6b7280";
                            string fontWeight = outOfService >= 1 ? "bold" : "normal";
                            litOutOfService.Text = string.Format("<span style='color: {0}; font-weight: {1};'>{2} out of service</span>", color, fontWeight, outOfService);
                        }
                        
                        // Store utilization and out of service count for gauge chart
                        UtilizationPercent = utilization.ToString("0");
                        OutOfServiceCount = outOfService.ToString();
                        
                        // Color based on utilization: >80% = red, 60-80% = orange, <60% = green
                        if (utilization > 80) ApplyStatusClass(cardActiveEquipment, 100, 60, 80); // Red
                        else if (utilization >= 60) ApplyStatusClass(cardActiveEquipment, 70, 60, 80); // Orange
                        else ApplyStatusClass(cardActiveEquipment, 0, 60, 80); // Green

                        // Calibration Due
                        int calibrationOverdue = GetInt(rdr, "CalibrationOverdue");
                        int calibrationDueSoon = GetInt(rdr, "CalibrationDueSoon");
                        int totalCalDue = calibrationOverdue + calibrationDueSoon;
                        if (litCalibrationDue != null) litCalibrationDue.Text = totalCalDue.ToString();
                        
                        // Store values for bullet chart
                        CalibrationOverdue = calibrationOverdue.ToString();
                        CalibrationDueSoon = calibrationDueSoon.ToString();
                        
                        if (calibrationOverdue > 0)
                        {
                            if (litCalibrationText != null) 
                                litCalibrationText.Text = string.Format("<span style='color: #ef4444; font-weight: bold;'>{0} overdue</span>", calibrationOverdue);
                            ApplyStatusClass(cardCalibrationDue, 100, 0, 1); // Red
                        }
                        else if (calibrationDueSoon > 0)
                        {
                            if (litCalibrationText != null) litCalibrationText.Text = calibrationDueSoon + " due soon";
                            ApplyStatusClass(cardCalibrationDue, 50, 0, 1); // Amber
                        }
                        else
                        {
                            if (litCalibrationText != null) litCalibrationText.Text = "All current";
                            ApplyStatusClass(cardCalibrationDue, 0, 0, 1); // Green
                        }

                        // PM Due
                        int pmOverdue = GetInt(rdr, "PMOverdue");
                        int pmDueSoon = GetInt(rdr, "PMDueSoon");
                        int totalPMDue = pmOverdue + pmDueSoon;
                        if (litPMDue != null) litPMDue.Text = totalPMDue.ToString();
                        
                        // Store values for bullet chart
                        PMOverdue = pmOverdue.ToString();
                        PMDueSoon = pmDueSoon.ToString();
                        
                        if (pmOverdue > 0)
                        {
                            if (litPMText != null) 
                                litPMText.Text = string.Format("<span style='color: #ef4444; font-weight: bold;'>{0} overdue</span>", pmOverdue);
                            ApplyStatusClass(cardPMDue, 100, 0, 1); // Red
                        }
                        else if (pmDueSoon > 0)
                        {
                            if (litPMText != null) litPMText.Text = pmDueSoon + " due soon";
                            ApplyStatusClass(cardPMDue, 50, 0, 1); // Amber
                        }
                        else
                        {
                            if (litPMText != null) litPMText.Text = "All current";
                            ApplyStatusClass(cardPMDue, 0, 0, 1); // Green
                        }

                        // Spares (use the value calculated earlier)
                        if (litSpares != null) litSpares.Text = sparesEquipment.ToString();
                        if (litSparesText != null) litSparesText.Text = "Available spares";
                    }
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("KPI Load Error: " + ex.Message);
            if (litTotalEquipment != null) litTotalEquipment.Text = "0";
            if (litActiveEquipment != null) litActiveEquipment.Text = "0";
            if (litOutOfService != null) litOutOfService.Text = "0";
            if (litCalibrationDue != null) litCalibrationDue.Text = "0";
            if (litCalibrationText != null) litCalibrationText.Text = "--";
            if (litPMDue != null) litPMDue.Text = "0";
            if (litPMText != null) litPMText.Text = "--";
            if (litSpares != null) litSpares.Text = "0";
            if (litSparesText != null) litSparesText.Text = "--";
            
            // Set default values for hybrid chart properties
            UtilizationPercent = "0";
            OutOfServiceCount = "0";
            CalibrationOverdue = "0";
            CalibrationDueSoon = "0";
            PMOverdue = "0";
            PMDueSoon = "0";
        }
    }

    private void LoadChartData()
    {
        System.Diagnostics.Debug.WriteLine("=== LoadChartData START ===");
        Response.Write("<script>console.log('=== LoadChartData START ===');</script>");
        
        try
        {
            var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
            var serializer = new JavaScriptSerializer();

            System.Diagnostics.Debug.WriteLine("Connection String: " + (string.IsNullOrEmpty(cs) ? "EMPTY" : "OK"));
            Response.Write("<script>console.log('Connection String: " + (string.IsNullOrEmpty(cs) ? "EMPTY" : "OK") + "');</script>");

            using (var conn = new SqlConnection(cs))
            {
                conn.Open();
                System.Diagnostics.Debug.WriteLine("Database connection opened successfully");
                Response.Write("<script>console.log('Database connection opened successfully');</script>");

                // 0. Sankey Diagram Data (Equipment Flow)
                var sankeyNodes = new List<object>();
                var sankeyLinks = new List<object>();
                var nodeIndex = new Dictionary<string, int>();
                int currentIndex = 0;

                // Helper to get or create node index
                Func<string, int> getNodeIndex = (nodeName) =>
                {
                    if (!nodeIndex.ContainsKey(nodeName))
                    {
                        nodeIndex[nodeName] = currentIndex++;
                        sankeyNodes.Add(new { name = nodeName });
                    }
                    return nodeIndex[nodeName];
                };

                var sankeyQuery = "SELECT SourceNode, TargetNode, Value FROM vw_EquipmentInventory_SankeyData WHERE Value > 0";
                using (var cmd = new SqlCommand(sankeyQuery, conn))
                using (var rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        string source = rdr["SourceNode"].ToString();
                        string target = rdr["TargetNode"].ToString();
                        int value = Convert.ToInt32(rdr["Value"]);

                        int sourceIdx = getNodeIndex(source);
                        int targetIdx = getNodeIndex(target);

                        sankeyLinks.Add(new
                        {
                            source = sourceIdx,
                            target = targetIdx,
                            value = value
                        });
                    }
                }

                SankeyData = serializer.Serialize(new { nodes = sankeyNodes, links = sankeyLinks });

                // 1. Equipment by Type (ATE, Asset, Fixture, Harness)
                var typeLabels = new List<string>();
                var typeValues = new List<int>();
                
                // Use custom order: Asset, ATE, Fixture, Harness for consistency
                var typeQuery = @"
                    SELECT EquipmentType, EquipmentCount 
                    FROM dbo.vw_EquipmentInventory_ByType 
                    ORDER BY 
                        CASE EquipmentType
                            WHEN 'Asset' THEN 1
                            WHEN 'ATE' THEN 2
                            WHEN 'Fixture' THEN 3
                            WHEN 'Harness' THEN 4
                            ELSE 5
                        END";
                
                System.Diagnostics.Debug.WriteLine("Executing equipment type query using view...");
                Response.Write("<script>console.log('Executing: " + typeQuery.Replace("'", "\\'").Replace("\r", "").Replace("\n", " ") + "');</script>");
                
                using (var cmd = new SqlCommand(typeQuery, conn))
                using (var rdr = cmd.ExecuteReader())
                {
                    System.Diagnostics.Debug.WriteLine("Query executed, reading results...");
                    Response.Write("<script>console.log('Query executed, reading results...');</script>");
                    
                    while (rdr.Read())
                    {
                        var equipType = rdr["EquipmentType"].ToString();
                        var equipCount = Convert.ToInt32(rdr["EquipmentCount"]);
                        typeLabels.Add(equipType);
                        typeValues.Add(equipCount);
                        System.Diagnostics.Debug.WriteLine("  Row: " + equipType + " = " + equipCount);
                        Response.Write("<script>console.log('  Row: " + equipType + " = " + equipCount + "');</script>");
                    }
                }
                System.Diagnostics.Debug.WriteLine("Equipment Type: " + typeLabels.Count + " rows");
                Response.Write("<script>console.log('Equipment Type query returned: " + typeLabels.Count + " rows');</script>");
                
                if (typeLabels.Count == 0) 
                {
                    System.Diagnostics.Debug.WriteLine("WARNING: No data returned from equipment type query");
                    Response.Write("<script>console.warn('WARNING: No data returned from vw_EquipmentInventory_ByType');</script>");
                    typeLabels.Add("No Data");
                    typeValues.Add(0);
                }
                TypeLabels = serializer.Serialize(typeLabels);
                TypeData = serializer.Serialize(typeValues);
                System.Diagnostics.Debug.WriteLine("TypeLabels JSON: " + TypeLabels);
                System.Diagnostics.Debug.WriteLine("TypeData JSON: " + TypeData);
                Response.Write("<script>console.log('TypeLabels serialized: ' + JSON.stringify(" + TypeLabels + "));</script>");
                Response.Write("<script>console.log('TypeData serialized: ' + JSON.stringify(" + TypeData + "));</script>");

                // 2. Equipment by Line (STACKED BY EQUIPMENT TYPE)
                var lineLabels = new List<string>();
                var lineTotals = new Dictionary<string, int>();
                var lineDataByType = new Dictionary<string, Dictionary<string, int>>();
                
                // Use the updated view - returns Line, EquipmentType, EquipmentCount, TotalForLine
                var lineQuery = "SELECT Line, EquipmentType, EquipmentCount, TotalForLine FROM dbo.vw_EquipmentInventory_ByLine";
                Response.Write("<script>console.log('Executing: " + lineQuery + "');</script>");
                
                using (var cmd = new SqlCommand(lineQuery, conn))
                using (var rdr = cmd.ExecuteReader())
                {
                    Response.Write("<script>console.log('Line query executed, reading results...');</script>");
                    while (rdr.Read())
                    {
                        string line = rdr["Line"].ToString();
                        string equipmentType = rdr["EquipmentType"].ToString();
                        int count = Convert.ToInt32(rdr["EquipmentCount"]);
                        int totalForLine = Convert.ToInt32(rdr["TotalForLine"]);
                        
                        Response.Write("<script>console.log('  Row: " + line + " - " + equipmentType + " = " + count + " (Total: " + totalForLine + ")');</script>");
                        
                        // Track total for this line (for sorting)
                        if (!lineTotals.ContainsKey(line))
                        {
                            lineTotals[line] = totalForLine;
                        }
                        
                        // Initialize line dictionary if needed
                        if (!lineDataByType.ContainsKey(line))
                        {
                            lineDataByType[line] = new Dictionary<string, int>();
                        }
                        
                        // Store count by equipment type for this line
                        lineDataByType[line][equipmentType] = count;
                    }
                }
                
                // Sort lines by total count (descending)
                var sortedLines = lineTotals.OrderByDescending(x => x.Value).Select(x => x.Key).ToList();
                lineLabels = sortedLines;
                
                // Build datasets for Chart.js stacked bar chart
                var lineDatasets = new List<object>();
                var equipmentTypes = new[] { "Asset", "ATE", "Fixture", "Harness" };
                var lineColors = new Dictionary<string, string> {
                    { "ATE", "#3b82f6" },      // Blue (colors.primary)
                    { "Asset", "#10b981" },    // Green (colors.success)
                    { "Fixture", "#8b5cf6" },  // Purple (colors.purple)
                    { "Harness", "#f97316" }   // Orange (colors.warning)
                };
                
                foreach (var equipType in equipmentTypes)
                {
                    var dataForType = new List<int>();
                    
                    // For each line (in sorted order), get the count for this equipment type
                    foreach (var line in sortedLines)
                    {
                        if (lineDataByType.ContainsKey(line) && lineDataByType[line].ContainsKey(equipType))
                        {
                            dataForType.Add(lineDataByType[line][equipType]);
                        }
                        else
                        {
                            dataForType.Add(0);  // No equipment of this type at this line
                        }
                    }
                    
                    // Only add dataset if it has at least one non-zero value
                    if (dataForType.Any(x => x > 0))
                    {
                        lineDatasets.Add(new {
                            label = equipType,
                            data = dataForType,
                            backgroundColor = lineColors[equipType],
                            borderColor = lineColors[equipType],
                            borderWidth = 1
                        });
                    }
                }
                
                if (lineLabels.Count == 0) 
                {
                    lineLabels.Add("No Data");
                    LineData = serializer.Serialize(new[] { 1 });
                    LineDatasets = "[]";
                }
                else
                {
                    LineData = "[]";  // Not used for stacked chart
                    LineDatasets = serializer.Serialize(lineDatasets);
                }
                LineLabels = serializer.Serialize(lineLabels);
                Response.Write("<script>console.log('LineLabels serialized: " + LineLabels + "');</script>");
                Response.Write("<script>console.log('LineDatasets serialized: " + LineDatasets + "');</script>");

                // 3. Equipment by Status
                var statusLabels = new List<string>();
                var statusValues = new List<int>();
                
                // Use the view - column name is EquipmentCount not StatusCount
                var statusQuery = "SELECT Status, EquipmentCount FROM dbo.vw_EquipmentInventory_ByStatus ORDER BY EquipmentCount DESC";
                
                using (var cmd = new SqlCommand(statusQuery, conn))
                using (var rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        statusLabels.Add(rdr["Status"].ToString());
                        statusValues.Add(Convert.ToInt32(rdr["EquipmentCount"]));
                    }
                }
                if (statusLabels.Count == 0) 
                {
                    statusLabels.Add("No Data");
                    statusValues.Add(1);
                }
                StatusLabels = serializer.Serialize(statusLabels);
                StatusData = serializer.Serialize(statusValues);

                // 4. Equipment by Location (ALL) - STACKED BY EQUIPMENT TYPE
                var locationLabels = new List<string>();
                var locationTotals = new Dictionary<string, int>();
                var locationDataByType = new Dictionary<string, Dictionary<string, int>>();
                
                // Use the updated view - returns Location, EquipmentType, EquipmentCount, TotalForLocation
                var locationQuery = "SELECT Location, EquipmentType, EquipmentCount, TotalForLocation FROM dbo.vw_EquipmentInventory_ByLocation";
                Response.Write("<script>console.log('Executing: " + locationQuery + "');</script>");
                
                using (var cmd = new SqlCommand(locationQuery, conn))
                using (var rdr = cmd.ExecuteReader())
                {
                    Response.Write("<script>console.log('Location query executed, reading results...');</script>");
                    while (rdr.Read())
                    {
                        string location = rdr["Location"].ToString();
                        string equipmentType = rdr["EquipmentType"].ToString();
                        int count = Convert.ToInt32(rdr["EquipmentCount"]);
                        int totalForLocation = Convert.ToInt32(rdr["TotalForLocation"]);
                        
                        Response.Write("<script>console.log('  Row: " + location + " - " + equipmentType + " = " + count + " (Total: " + totalForLocation + ")');</script>");
                        
                        // Track total for this location (for sorting)
                        if (!locationTotals.ContainsKey(location))
                        {
                            locationTotals[location] = totalForLocation;
                        }
                        
                        // Initialize location dictionary if needed
                        if (!locationDataByType.ContainsKey(location))
                        {
                            locationDataByType[location] = new Dictionary<string, int>();
                        }
                        
                        // Store count by equipment type for this location
                        locationDataByType[location][equipmentType] = count;
                    }
                }
                
                // Sort locations by total count (descending)
                var sortedLocations = locationTotals.OrderByDescending(x => x.Value).Select(x => x.Key).ToList();
                locationLabels = sortedLocations;
                
                // Build datasets for Chart.js stacked bar chart
                var locationDatasets = new List<object>();
                var locationEquipmentTypes = new[] { "Asset", "ATE", "Fixture", "Harness" };
                var locationColors = new Dictionary<string, string> {
                    { "ATE", "#3b82f6" },      // Blue (colors.primary)
                    { "Asset", "#10b981" },    // Green (colors.success)
                    { "Fixture", "#8b5cf6" },  // Purple (colors.purple)
                    { "Harness", "#f97316" }   // Orange (colors.warning)
                };
                
                foreach (var equipType in locationEquipmentTypes)
                {
                    var dataForType = new List<int>();
                    
                    // For each location (in sorted order), get the count for this equipment type
                    foreach (var location in sortedLocations)
                    {
                        if (locationDataByType.ContainsKey(location) && locationDataByType[location].ContainsKey(equipType))
                        {
                            dataForType.Add(locationDataByType[location][equipType]);
                        }
                        else
                        {
                            dataForType.Add(0);  // No equipment of this type at this location
                        }
                    }
                    
                    // Only add dataset if it has at least one non-zero value
                    if (dataForType.Any(x => x > 0))
                    {
                        locationDatasets.Add(new {
                            label = equipType,
                            data = dataForType,
                            backgroundColor = locationColors[equipType],
                            borderColor = locationColors[equipType],
                            borderWidth = 1
                        });
                    }
                }
                
                if (locationLabels.Count == 0) 
                {
                    locationLabels.Add("No Data");
                    LocationData = serializer.Serialize(new[] { 1 });
                    LocationDatasets = "[]";
                }
                else
                {
                    LocationData = "[]";  // Not used for stacked chart
                    LocationDatasets = serializer.Serialize(locationDatasets);
                }
                LocationLabels = serializer.Serialize(locationLabels);
                Response.Write("<script>console.log('LocationLabels serialized: " + LocationLabels + "');</script>");
                Response.Write("<script>console.log('LocationDatasets serialized: " + LocationDatasets + "');</script>");


                // 5. Assets by Type (DeviceType from Asset_Inventory)
                var assetTypeLabels = new List<string>();
                var assetTypeValues = new List<int>();
                using (var cmd = new SqlCommand(@"
                    SELECT 
                        ISNULL(DeviceType, 'Unspecified') as DeviceType,
                        COUNT(*) as AssetCount
                    FROM Asset_Inventory
                    WHERE ISNULL(IsActive, 1) = 1
                    GROUP BY DeviceType
                    ORDER BY COUNT(*) DESC", conn))
                using (var rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        assetTypeLabels.Add(rdr["DeviceType"].ToString());
                        assetTypeValues.Add(Convert.ToInt32(rdr["AssetCount"]));
                    }
                }
                if (assetTypeLabels.Count == 0) 
                {
                    assetTypeLabels.Add("No Data");
                    assetTypeValues.Add(1);
                }
                AssetTypeLabels = serializer.Serialize(assetTypeLabels);
                AssetTypeData = serializer.Serialize(assetTypeValues);

                // 6. Calibration Status (Exclude "Not Required")
                var calibrationLabels = new List<string>();
                var calibrationValues = new List<int>();
                
                // Query only the columns we need - exclude NotRequired
                var calibrationQuery = "SELECT [Current], DueSoon, Overdue FROM dbo.vw_EquipmentInventory_CalibrationStatus";
                Response.Write("<script>console.log('Executing: " + calibrationQuery + "');</script>");
                
                using (var cmd = new SqlCommand(calibrationQuery, conn))
                using (var rdr = cmd.ExecuteReader())
                {
                    Response.Write("<script>console.log('Calibration Status query executed, reading results...');</script>");
                    if (rdr.Read())
                    {
                        // Add in priority order: Overdue, Due Soon, Current (exclude Not Required)
                        int overdue = rdr["Overdue"] != DBNull.Value ? Convert.ToInt32(rdr["Overdue"]) : 0;
                        int dueSoon = rdr["DueSoon"] != DBNull.Value ? Convert.ToInt32(rdr["DueSoon"]) : 0;
                        int current = rdr["Current"] != DBNull.Value ? Convert.ToInt32(rdr["Current"]) : 0;
                        
                        Response.Write("<script>console.log('  Calibration - Overdue: " + overdue + ", DueSoon: " + dueSoon + ", Current: " + current + "');</script>");
                        
                        if (overdue > 0) { calibrationLabels.Add("Overdue"); calibrationValues.Add(overdue); }
                        if (dueSoon > 0) { calibrationLabels.Add("Due Soon"); calibrationValues.Add(dueSoon); }
                        if (current > 0) { calibrationLabels.Add("Current"); calibrationValues.Add(current); }
                    }
                }
                if (calibrationLabels.Count == 0) 
                {
                    calibrationLabels.Add("No Data");
                    calibrationValues.Add(1);
                }
                CalibrationLabels = serializer.Serialize(calibrationLabels);
                CalibrationData = serializer.Serialize(calibrationValues);
                Response.Write("<script>console.log('CalibrationLabels serialized: " + CalibrationLabels + "');</script>");
                Response.Write("<script>console.log('CalibrationData serialized: " + CalibrationData + "');</script>");

                // 7. PM Status (Exclude "Not Required")
                var pmLabels = new List<string>();
                var pmValues = new List<int>();
                
                // Query only the columns we need - exclude NotRequired
                var pmQuery = "SELECT [Current], DueSoon, Overdue FROM dbo.vw_EquipmentInventory_PMStatus";
                Response.Write("<script>console.log('Executing: " + pmQuery + "');</script>");
                
                using (var cmd = new SqlCommand(pmQuery, conn))
                using (var rdr = cmd.ExecuteReader())
                {
                    Response.Write("<script>console.log('PM Status query executed, reading results...');</script>");
                    if (rdr.Read())
                    {
                        // Add in priority order: Overdue, Due Soon, Current (exclude Not Required)
                        int overdue = rdr["Overdue"] != DBNull.Value ? Convert.ToInt32(rdr["Overdue"]) : 0;
                        int dueSoon = rdr["DueSoon"] != DBNull.Value ? Convert.ToInt32(rdr["DueSoon"]) : 0;
                        int current = rdr["Current"] != DBNull.Value ? Convert.ToInt32(rdr["Current"]) : 0;
                        
                        Response.Write("<script>console.log('  PM - Overdue: " + overdue + ", DueSoon: " + dueSoon + ", Current: " + current + "');</script>");
                        
                        if (overdue > 0) { pmLabels.Add("Overdue"); pmValues.Add(overdue); }
                        if (dueSoon > 0) { pmLabels.Add("Due Soon"); pmValues.Add(dueSoon); }
                        if (current > 0) { pmLabels.Add("Current"); pmValues.Add(current); }
                    }
                }
                if (pmLabels.Count == 0)
                {
                    pmLabels.Add("No Data");
                    pmValues.Add(1);
                }
                PMLabels = serializer.Serialize(pmLabels);
                PMData = serializer.Serialize(pmValues);
                Response.Write("<script>console.log('PMLabels serialized: " + PMLabels + "');</script>");
                Response.Write("<script>console.log('PMData serialized: " + PMData + "');</script>");

                // 8. Spares by Equipment Type (for mini bar chart)
                var sparesTypeLabels = new List<string>();
                var sparesTypeValues = new List<int>();
                
                // Count spare equipment by type from each inventory table
                try
                {
                    var sparesQuery = @"
                        WITH SparesData AS (
                            SELECT 'Asset' AS EquipmentType, COUNT(*) AS SpareCount
                            FROM dbo.Asset_Inventory 
                            WHERE IsActive = 1 AND CurrentStatus = 'Spare'
                            
                            UNION ALL
                            
                            SELECT 'ATE' AS EquipmentType, COUNT(*) AS SpareCount
                            FROM dbo.ATE_Inventory 
                            WHERE IsActive = 1 AND ATEStatus = 'Spare'
                            
                            UNION ALL
                            
                            SELECT 'Fixture' AS EquipmentType, COUNT(*) AS SpareCount
                            FROM dbo.Fixture_Inventory 
                            WHERE IsActive = 1 AND CurrentStatus = 'Spare'
                            
                            UNION ALL
                            
                            SELECT 'Harness' AS EquipmentType, COUNT(*) AS SpareCount
                            FROM dbo.Harness_Inventory 
                            WHERE IsActive = 1 AND CurrentStatus = 'Spare'
                        )
                        SELECT EquipmentType, SUM(SpareCount) AS SpareCount
                        FROM SparesData
                        GROUP BY EquipmentType
                        ORDER BY 
                            CASE EquipmentType
                                WHEN 'Asset' THEN 1
                                WHEN 'ATE' THEN 2
                                WHEN 'Fixture' THEN 3
                                WHEN 'Harness' THEN 4
                                ELSE 5
                            END";
                    
                    using (var cmd = new SqlCommand(sparesQuery, conn))
                    using (var rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            var count = Convert.ToInt32(rdr["SpareCount"]);
                            if (count > 0) // Only include types with spares
                            {
                                sparesTypeLabels.Add(rdr["EquipmentType"].ToString());
                                sparesTypeValues.Add(count);
                            }
                        }
                    }
                }
                catch (Exception sparesEx)
                {
                    Response.Write("<script>console.warn('Spares query failed: " + sparesEx.Message.Replace("'", "\\'") + "');</script>");
                }
                
                // If no spares found, show all equipment types with 0
                if (sparesTypeLabels.Count == 0) 
                {
                    sparesTypeLabels.AddRange(new[] { "Asset", "ATE", "Fixture", "Harness" });
                    sparesTypeValues.AddRange(new[] { 0, 0, 0, 0 });
                }
                SparesTypeLabels = serializer.Serialize(sparesTypeLabels);
                SparesTypeData = serializer.Serialize(sparesTypeValues);
                Response.Write("<script>console.log('SparesTypeLabels serialized: " + SparesTypeLabels + "');</script>");
                Response.Write("<script>console.log('SparesTypeData serialized: " + SparesTypeData + "');</script>");
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("=== CHART DATA LOAD ERROR ===");
            System.Diagnostics.Debug.WriteLine("Error Message: " + ex.Message);
            System.Diagnostics.Debug.WriteLine("Stack Trace: " + ex.StackTrace);
            
            Response.Write("<script>console.error('=== CHART DATA LOAD ERROR ===');</script>");
            Response.Write("<script>console.error('Error: " + ex.Message.Replace("'", "\\'").Replace("\r", "").Replace("\n", " ") + "');</script>");
            Response.Write("<script>console.error('Stack: " + ex.StackTrace.Replace("'", "\\'").Replace("\r", "").Replace("\n", " ") + "');</script>");
            
            if (ex.InnerException != null)
            {
                System.Diagnostics.Debug.WriteLine("Inner Exception: " + ex.InnerException.Message);
                Response.Write("<script>console.error('Inner Exception: " + ex.InnerException.Message.Replace("'", "\\'") + "');</script>");
            }
            
            // Set default empty data
            var serializer = new JavaScriptSerializer();
            TypeLabels = serializer.Serialize(new[] { "No Data" });
            TypeData = serializer.Serialize(new[] { 1 });
            LineLabels = serializer.Serialize(new[] { "No Data" });
            LineData = serializer.Serialize(new[] { 1 });
            StatusLabels = serializer.Serialize(new[] { "No Data" });
            StatusData = serializer.Serialize(new[] { 1 });
            LocationLabels = serializer.Serialize(new[] { "No Data" });
            LocationData = serializer.Serialize(new[] { 1 });
            LocationDatasets = "[]";
            AssetTypeLabels = serializer.Serialize(new[] { "No Data" });
            AssetTypeData = serializer.Serialize(new[] { 1 });
            CalibrationLabels = serializer.Serialize(new[] { "No Data" });
            CalibrationData = serializer.Serialize(new[] { 1 });
            PMLabels = serializer.Serialize(new[] { "No Data" });
            PMData = serializer.Serialize(new[] { 1 });
            
            // Set default values for hybrid chart properties
            UtilizationPercent = "0";
            CalibrationOverdue = "0";
            CalibrationDueSoon = "0";
            PMOverdue = "0";
            PMDueSoon = "0";
            SparesTypeLabels = serializer.Serialize(new[] { "No Data" });
            SparesTypeData = serializer.Serialize(new[] { 0 });
        }
    }

    private void LoadRecentAdditions()
    {
        try
        {
            Response.Write("<script>console.log('=== LoadRecentAdditions START ===');</script>");
            var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
            var dt = new DataTable();
            
            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand(@"
                SELECT TOP 15
                    EquipmentType,
                    EatonID,
                    Name,
                    Location,
                    Status,
                    RequiresPM,
                    RequiresCalibration,
                    CreatedDate
                FROM dbo.vw_EquipmentInventory_RecentAdditions
                ORDER BY CreatedDate DESC", conn))
            using (var adapter = new SqlDataAdapter(cmd))
            {
                conn.Open();
                Response.Write("<script>console.log('Recent Additions: Database connection opened');</script>");
                adapter.Fill(dt);
                Response.Write("<script>console.log('Recent Additions: Query returned " + dt.Rows.Count.ToString() + " rows');</script>");
            }

            if (dt.Rows.Count > 0)
            {
                gvRecentAdditions.DataSource = dt;
                gvRecentAdditions.DataBind();
                Response.Write("<script>console.log('Recent Additions: Data bound to GridView successfully');</script>");
            }
            else
            {
                gvRecentAdditions.DataSource = null;
                gvRecentAdditions.DataBind();
                Response.Write("<script>console.log('Recent Additions: No data found');</script>");
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Recent Additions Load Error: " + ex.Message);
            Response.Write("<script>console.error('=== RECENT ADDITIONS ERROR ===');</script>");
            Response.Write("<script>console.error('Error: " + ex.Message.Replace("'", "\\'") + "');</script>");
            gvRecentAdditions.DataSource = null;
            gvRecentAdditions.DataBind();
        }
    }

    protected void gvRecentAdditions_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            try
            {
                // Apply equipment type badge styling to the Equipment Type column (column 0)
                if (e.Row.Cells.Count > 0)
                {
                    object equipmentTypeObj = DataBinder.Eval(e.Row.DataItem, "EquipmentType");
                    string equipmentType = (equipmentTypeObj != null) ? equipmentTypeObj.ToString() : "";
                    if (!string.IsNullOrEmpty(equipmentType))
                    {
                        string badgeClass = "type-badge type-" + equipmentType.ToLower();
                        string badgeColor = GetEquipmentTypeBadgeColor(equipmentType);
                        
                        e.Row.Cells[0].Text = string.Format(
                            "<span class='{0}' style='{1}'>{2}</span>", 
                            badgeClass, 
                            badgeColor, 
                            equipmentType);
                    }
                }

                // Apply status badge styling to the Status column (column 4)
                if (e.Row.Cells.Count > 4)
                {
                    object statusObj = DataBinder.Eval(e.Row.DataItem, "Status");
                    string status = (statusObj != null) ? statusObj.ToString() : "";
                    if (!string.IsNullOrEmpty(status))
                    {
                        string statusClass = GetStatusClass(status);
                        string badgeColor = GetStatusBadgeColor(statusClass);
                        
                        e.Row.Cells[4].Text = string.Format(
                            "<span class='status-badge status-{0}' style='{1}'>{2}</span>", 
                            statusClass, 
                            badgeColor, 
                            status);
                    }
                }

                // Make the row clickable
                object equipmentIdObj = DataBinder.Eval(e.Row.DataItem, "EatonID");
                object equipmentNameObj = DataBinder.Eval(e.Row.DataItem, "Name");
                
                if (equipmentIdObj != null)
                {
                    string equipmentId = equipmentIdObj.ToString();
                    string equipmentName = (equipmentNameObj != null) ? equipmentNameObj.ToString() : equipmentId;
                    
                    // Add cursor pointer and click handler
                    e.Row.Style.Add("cursor", "pointer");
                    
                    // Add data attributes for JavaScript
                    e.Row.Attributes.Add("data-equipment-id", equipmentId);
                    e.Row.Attributes.Add("data-equipment-name", equipmentName);
                    
                    // Add onclick JavaScript
                    string onClick = string.Format(
                        "showNavigationModal('View Equipment Details', " +
                        "'Open Equipment Grid View filtered by {0}?', " +
                        "'http://usyouwhp6205605/Test%20Engineering%20Dashboard/EquipmentGridView.aspx?equipment={1}&collapse=true')",
                        equipmentName.Replace("'", "\\'"), // Escape single quotes
                        System.Web.HttpUtility.UrlEncode(equipmentId)
                    );
                    
                    e.Row.Attributes.Add("onclick", onClick);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error in gvRecentAdditions_RowDataBound: " + ex.Message);
            }
        }
    }

    protected string GetStatusClass(object statusObj)
    {
        try
        {
            if (statusObj == null || statusObj == DBNull.Value)
                return "active";
            
            string status = statusObj.ToString().ToLower();
            
            if (status.Contains("active") || status.Contains("in use"))
                return "active";
            else if (status.Contains("inactive") || status.Contains("out of service"))
                return "inactive";
            else if (status.Contains("maintenance") || status.Contains("repair"))
                return "maintenance";
            else if (status.Contains("spare"))
                return "spare";
            else
                return "other";
        }
        catch
        {
            return "other";
        }
    }

    private string GetEquipmentTypeBadgeColor(string equipmentType)
    {
        switch (equipmentType.ToLower())
        {
            case "ate":
                return "background: rgba(37,99,235,0.1); color: #2563eb; border: 1px solid rgba(37,99,235,0.25);";
            case "asset":
                return "background: rgba(5,150,105,0.1); color: #059669; border: 1px solid rgba(5,150,105,0.25);";
            case "fixture":
                return "background: rgba(124,58,237,0.1); color: #7c3aed; border: 1px solid rgba(124,58,237,0.25);";
            case "harness":
                return "background: rgba(234,88,12,0.1); color: #ea580c; border: 1px solid rgba(234,88,12,0.25);";
            default:
                return "background: rgba(100,116,139,0.1); color: #64748b; border: 1px solid rgba(100,116,139,0.25);";
        }
    }

    private string GetStatusBadgeColor(string statusClass)
    {
        switch (statusClass)
        {
            case "active":
                return "background: rgba(5,150,105,0.1); color: #059669; border: 1px solid rgba(5,150,105,0.25);";
            case "inactive":
                return "background: rgba(100,116,139,0.1); color: #64748b; border: 1px solid rgba(100,116,139,0.25);";
            case "maintenance":
                return "background: rgba(217,119,6,0.1); color: #d97706; border: 1px solid rgba(217,119,6,0.25);";
            case "spare":
                return "background: rgba(37,99,235,0.1); color: #2563eb; border: 1px solid rgba(37,99,235,0.25);";
            default:
                return "background: rgba(124,58,237,0.1); color: #7c3aed; border: 1px solid rgba(124,58,237,0.25);";
        }
    }

    private void ApplyStatusClass(System.Web.UI.HtmlControls.HtmlGenericControl card, int value, int amberThreshold, int redThreshold)
    {
        if (card == null) return;
        
        // Remove existing status classes
        string currentClass = card.Attributes["class"];
        if (!string.IsNullOrEmpty(currentClass))
        {
            currentClass = currentClass.Replace("status-red", "").Replace("status-amber", "").Replace("status-green", "").Trim();
            card.Attributes["class"] = currentClass;
        }
        
        if (value > redThreshold)
            card.Attributes["class"] += " status-red";
        else if (value > amberThreshold)
            card.Attributes["class"] += " status-amber";
        else
            card.Attributes["class"] += " status-green";
    }

    private int GetInt(SqlDataReader rdr, string columnName)
    {
        try
        {
            var idx = rdr.GetOrdinal(columnName);
            return rdr.IsDBNull(idx) ? 0 : rdr.GetInt32(idx);
        }
        catch
        {
            return 0;
        }
    }

    private decimal GetDecimal(SqlDataReader rdr, string columnName)
    {
        try
        {
            var idx = rdr.GetOrdinal(columnName);
            return rdr.IsDBNull(idx) ? 0m : rdr.GetDecimal(idx);
        }
        catch
        {
            return 0m;
        }
    }

    [System.Web.Services.WebMethod]
    public static string GetEquipmentByLocation(string location)
    {
        var equipmentList = new List<object>();
        var serializer = new System.Web.Script.Serialization.JavaScriptSerializer();

        try
        {
            string connStr = System.Configuration.ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
            
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                
                // Query to get all equipment IDs for the specified location
                string query = @"
                    SELECT 
                        EatonEquipmentID,
                        'Asset' AS EquipmentType
                    FROM Asset_Inventory
                    WHERE IsActive = 1 AND Location LIKE @Location + '%'
                    
                    UNION ALL
                    
                    SELECT 
                        EatonEquipmentID,
                        'ATE' AS EquipmentType
                    FROM ATE_Inventory
                    WHERE IsActive = 1 AND Location LIKE @Location + '%'
                    
                    UNION ALL
                    
                    SELECT 
                        EatonEquipmentID,
                        'Fixture' AS EquipmentType
                    FROM Fixture_Inventory
                    WHERE IsActive = 1 AND Location LIKE @Location + '%'
                    
                    UNION ALL
                    
                    SELECT 
                        EatonEquipmentID,
                        'Harness' AS EquipmentType
                    FROM Harness_Inventory
                    WHERE IsActive = 1 AND Location LIKE @Location + '%'
                    
                    ORDER BY EquipmentType, EatonEquipmentID";
                
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@Location", location);
                    
                    using (SqlDataReader rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            equipmentList.Add(new
                            {
                                equipmentId = rdr["EatonEquipmentID"].ToString(),
                                equipmentType = rdr["EquipmentType"].ToString()
                            });
                        }
                    }
                }
            }
            
            // Build datasets grouped by equipment type
            var labels = equipmentList.Select(e => ((dynamic)e).equipmentId).ToList();
            var typeGroups = equipmentList.GroupBy(e => ((dynamic)e).equipmentType);
            
            var datasets = new List<object>();
            var colors = new Dictionary<string, string>
            {
                { "Asset", "#10b981" },  // Green
                { "ATE", "#3b82f6" },     // Blue
                { "Fixture", "#a855f7" }, // Purple
                { "Harness", "#f59e0b" }  // Orange
            };
            
            foreach (var type in new[] { "Asset", "ATE", "Fixture", "Harness" })
            {
                var typeEquipment = equipmentList.Where(e => ((dynamic)e).equipmentType == type).ToList();
                if (typeEquipment.Count > 0)
                {
                    var data = labels.Select(label => 
                        typeEquipment.Any(e => ((dynamic)e).equipmentId == label) ? 1 : 0
                    ).ToList();
                    
                    datasets.Add(new
                    {
                        label = type,
                        data = data,
                        backgroundColor = colors[type],
                        borderWidth = 0,
                        borderRadius = 12
                    });
                }
            }
            
            var result = new
            {
                labels = labels,
                datasets = datasets
            };
            
            return serializer.Serialize(result);
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error in GetEquipmentByLocation: " + ex.Message);
            return serializer.Serialize(new { labels = new[] { "Error" }, datasets = new object[0] });
        }
    }

    [System.Web.Services.WebMethod]
    public static string GetEquipmentByLine()
    {
        var serializer = new System.Web.Script.Serialization.JavaScriptSerializer();
        
        try
        {
            string connStr = System.Configuration.ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
            var lineData = new Dictionary<string, Dictionary<string, int>>();
            
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                
                // Use existing view for equipment by line
                string query = "SELECT Line, EquipmentType, EquipmentCount FROM dbo.vw_EquipmentInventory_ByLine ORDER BY Line, EquipmentType";
                
                using (SqlCommand cmd = new SqlCommand(query, conn))
                using (SqlDataReader rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        string line = rdr["Line"].ToString();
                        string type = rdr["EquipmentType"].ToString();
                        int count = Convert.ToInt32(rdr["EquipmentCount"]);
                        
                        System.Diagnostics.Debug.WriteLine(string.Format("Line: {0}, Type: {1}, Count: {2}", line, type, count));
                        
                        if (!lineData.ContainsKey(line))
                            lineData[line] = new Dictionary<string, int>();
                        
                        lineData[line][type] = count;
                    }
                }
            }
            
            System.Diagnostics.Debug.WriteLine(string.Format("Total lines found: {0}", lineData.Keys.Count));
            
            // If no data, return empty result
            if (lineData.Keys.Count == 0)
            {
                System.Diagnostics.Debug.WriteLine("No line data found - returning empty result");
                return serializer.Serialize(new { labels = new string[0], datasets = new object[0] });
            }
            
            // Build chart data
            var labels = lineData.Keys.OrderBy(x => x).ToList();
            var types = new[] { "Asset", "ATE", "Fixture", "Harness" };
            var colors = new Dictionary<string, string>
            {
                { "Asset", "#10b981" },
                { "ATE", "#3b82f6" },
                { "Fixture", "#a855f7" },
                { "Harness", "#f59e0b" }
            };
            
            var datasets = types.Select(type => new
            {
                label = type,
                data = labels.Select(line => lineData[line].ContainsKey(type) ? lineData[line][type] : 0).ToArray(),
                backgroundColor = colors[type],
                borderWidth = 0,
                borderRadius = 12
            }).Where(ds => ds.data.Any(d => d > 0)).ToList();  // Only include datasets with data
            
            var result = new { labels = labels, datasets = datasets };
            System.Diagnostics.Debug.WriteLine(string.Format("Returning result with {0} labels and {1} datasets", labels.Count, datasets.Count));
            return serializer.Serialize(result);
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error in GetEquipmentByLine: " + ex.Message);
            System.Diagnostics.Debug.WriteLine("Stack trace: " + ex.StackTrace);
            return serializer.Serialize(new { labels = new string[0], datasets = new object[0], error = ex.Message });
        }
    }

    [System.Web.Services.WebMethod]
    public static string GetLocationsByLine(string line)
    {
        var serializer = new System.Web.Script.Serialization.JavaScriptSerializer();
        
        try
        {
            string connStr = System.Configuration.ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
            var locationData = new Dictionary<string, Dictionary<string, int>>();
            
            System.Diagnostics.Debug.WriteLine(string.Format("GetLocationsByLine called with line: '{0}'", line));
            
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                
                // Use the view for locations within a line
                string query = @"
                    SELECT Location, EquipmentType, EquipmentCount
                    FROM dbo.vw_EquipmentInventory_ByLineAndLocation
                    WHERE Line = @Line
                    ORDER BY Location, EquipmentType";
                
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@Line", line);
                    
                    using (SqlDataReader rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            string location = rdr["Location"].ToString();
                            string type = rdr["EquipmentType"].ToString();
                            int count = Convert.ToInt32(rdr["EquipmentCount"]);
                            
                            System.Diagnostics.Debug.WriteLine(string.Format("  Location: {0}, Type: {1}, Count: {2}", location, type, count));
                            
                            if (!locationData.ContainsKey(location))
                                locationData[location] = new Dictionary<string, int>();
                            
                            locationData[location][type] = count;
                        }
                    }
                }
            }
            
            System.Diagnostics.Debug.WriteLine(string.Format("Total locations found: {0}", locationData.Keys.Count));
            
            // If no data, return empty result
            if (locationData.Keys.Count == 0)
            {
                System.Diagnostics.Debug.WriteLine("No location data found - returning empty result");
                return serializer.Serialize(new { labels = new string[0], datasets = new object[0] });
            }
            
            // Build chart data
            var labels = locationData.Keys.OrderBy(x => x).ToList();
            var types = new[] { "Asset", "ATE", "Fixture", "Harness" };
            var colors = new Dictionary<string, string>
            {
                { "Asset", "#10b981" },
                { "ATE", "#3b82f6" },
                { "Fixture", "#a855f7" },
                { "Harness", "#f59e0b" }
            };
            
            var datasets = types.Select(type => new
            {
                label = type,
                data = labels.Select(location => locationData[location].ContainsKey(type) ? locationData[location][type] : 0).ToArray(),
                backgroundColor = colors[type],
                borderWidth = 0,
                borderRadius = 12
            }).Where(ds => ds.data.Any(d => d > 0)).ToList();
            
            var result = new { labels = labels, datasets = datasets };
            System.Diagnostics.Debug.WriteLine(string.Format("Returning {0} labels and {1} datasets", labels.Count, datasets.Count));
            return serializer.Serialize(result);
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error in GetLocationsByLine: " + ex.Message);
            System.Diagnostics.Debug.WriteLine("Stack trace: " + ex.StackTrace);
            return serializer.Serialize(new { labels = new string[0], datasets = new object[0], error = ex.Message });
        }
    }

    [System.Web.Services.WebMethod]
    public static string GetEquipmentByLineAndLocation(string line, string location)
    {
        var equipmentList = new List<object>();
        var serializer = new System.Web.Script.Serialization.JavaScriptSerializer();

        try
        {
            string connStr = System.Configuration.ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
            
            System.Diagnostics.Debug.WriteLine(string.Format("GetEquipmentByLineAndLocation called with line: '{0}', location: '{1}'", line, location));
            
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                
                // Query to get all equipment IDs for the specified location
                // Note: We only filter by Location since Line is extracted from Location
                string query = @"
                    SELECT 
                        EatonID,
                        'Asset' AS EquipmentType
                    FROM Asset_Inventory
                    WHERE IsActive = 1 AND Location = @Location
                    
                    UNION ALL
                    
                    SELECT 
                        EatonID,
                        'ATE' AS EquipmentType
                    FROM ATE_Inventory
                    WHERE IsActive = 1 AND Location = @Location
                    
                    UNION ALL
                    
                    SELECT 
                        EatonID,
                        'Fixture' AS EquipmentType
                    FROM Fixture_Inventory
                    WHERE IsActive = 1 AND Location = @Location
                    
                    UNION ALL
                    
                    SELECT 
                        EatonID,
                        'Harness' AS EquipmentType
                    FROM Harness_Inventory
                    WHERE IsActive = 1 AND Location = @Location
                    
                    ORDER BY EquipmentType, EatonID";
                
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@Location", location);
                    
                    using (SqlDataReader rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            equipmentList.Add(new
                            {
                                equipmentId = rdr["EatonID"].ToString(),
                                equipmentType = rdr["EquipmentType"].ToString()
                            });
                            
                            System.Diagnostics.Debug.WriteLine(string.Format("  Equipment: {0}, Type: {1}", 
                                rdr["EatonID"].ToString(), 
                                rdr["EquipmentType"].ToString()));
                        }
                    }
                }
            }
            
            System.Diagnostics.Debug.WriteLine(string.Format("Total equipment found: {0}", equipmentList.Count));
            
            if (equipmentList.Count == 0)
            {
                System.Diagnostics.Debug.WriteLine("No equipment found - returning empty result");
                return serializer.Serialize(new { labels = new string[0], datasets = new object[0] });
            }
            
            // Build datasets grouped by equipment type
            var labels = equipmentList.Select(e => ((dynamic)e).equipmentId).ToList();
            var typeGroups = equipmentList.GroupBy(e => ((dynamic)e).equipmentType);
            
            var datasets = new List<object>();
            var colors = new Dictionary<string, string>
            {
                { "Asset", "#10b981" },
                { "ATE", "#3b82f6" },
                { "Fixture", "#a855f7" },
                { "Harness", "#f59e0b" }
            };
            
            foreach (var type in new[] { "Asset", "ATE", "Fixture", "Harness" })
            {
                var typeEquipment = equipmentList.Where(e => ((dynamic)e).equipmentType == type).ToList();
                if (typeEquipment.Count > 0)
                {
                    var data = labels.Select(label => 
                        typeEquipment.Any(e => ((dynamic)e).equipmentId == label) ? 1 : 0
                    ).ToList();
                    
                    datasets.Add(new
                    {
                        label = type,
                        data = data,
                        backgroundColor = colors[type],
                        borderWidth = 0,
                        borderRadius = 12
                    });
                }
            }
            
            var result = new
            {
                labels = labels,
                datasets = datasets
            };
            
            return serializer.Serialize(result);
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error in GetEquipmentByLineAndLocation: " + ex.Message);
            System.Diagnostics.Debug.WriteLine("Stack trace: " + ex.StackTrace);
            return serializer.Serialize(new { labels = new[] { "Error" }, datasets = new object[0], error = ex.Message });
        }
    }
}