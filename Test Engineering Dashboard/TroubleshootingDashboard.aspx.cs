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

public partial class TED_TroubleshootingDashboard : Page
{
    // Chart data properties (exposed to JavaScript)
    public string SankeyData { get; set; }
    public string WaterfallLabels { get; set; }
    public string WaterfallData { get; set; }
    public string WaterfallColors { get; set; }
    public string AvgResolutionTime { get; set; }  // For mini-line chart average
    public string ResolutionTimesData { get; set; }  // For mini-line chart (last 10 resolutions)
    public string TroubleshootingIDs { get; set; }  // For mini-line chart tooltips
    public string RepeatIssueRate { get; set; }  // For gauge chart
    public string RepeatIssuesStatusClass { get; set; }  // For repeat issues card color
    public string TotalDowntimeHours { get; set; }  // For downtime gauge chart
    public string OpenIssuesCount { get; set; }  // For critical ratio gauge
    public string CriticalCount { get; set; }  // For critical ratio gauge
    public string MonthlyLabels { get; set; }  // For mini-chart only
    public string MonthlyData { get; set; }    // For mini-chart only
    public string ClassificationLabels { get; set; }
    public string ClassificationData { get; set; }
    public string ResolutionTimeLabels { get; set; }
    public string ResolutionTimeData { get; set; }
    public string EquipmentTypeLabels { get; set; }
    public string EquipmentTypeData { get; set; }
    public string EquipmentLabels { get; set; }
    public string EquipmentData { get; set; }
    public string LineLabels { get; set; }
    public string LineData { get; set; }
    public string DrillDownData { get; set; }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadSidebarUser();
            LoadOpenIssuesTable();
            LoadRecentAdditions();
            LoadKPIs();
            LoadMiniChartData();
            LoadChartData();
        }
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

    private void LoadOpenIssuesTable()
    {
        // Force section visible for debugging
        if (openIssuesTableSection != null)
        {
            openIssuesTableSection.Visible = true;
        }
        
        try
        {
            var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
            using (var conn = new SqlConnection(cs))
            {
                conn.Open();
                
                // Test with a working query format similar to other working queries
                var cmd = new SqlCommand(@"
                    SELECT TOP 15
                        ID,
                        Priority,
                        ReportedDateTime,
                        Location,
                        ReportedBy,
                        Symptom,
                        Status
                    FROM Troubleshooting_Log
                    WHERE (UPPER(ISNULL(Status,'')) NOT IN ('RESOLVED', 'CLOSED'))
                    ORDER BY 
                        CASE UPPER(ISNULL(Priority, 'LOW'))
                            WHEN 'CRITICAL' THEN 1
                            WHEN 'HIGH' THEN 2
                            WHEN 'MEDIUM' THEN 3
                            WHEN 'LOW' THEN 4
                            ELSE 5
                        END,
                        ReportedDateTime DESC", conn);
                
                var dt = new DataTable();
                dt.Load(cmd.ExecuteReader());
                
                // Debug output
                System.Diagnostics.Debug.WriteLine("LoadOpenIssuesTable: Found " + dt.Rows.Count + " total issues");
                
                // Transform the data for display
                var displayTable = new DataTable();
                displayTable.Columns.Add("RawID", typeof(int));  // Store raw ID for navigation
                displayTable.Columns.Add("TroubleshootingID", typeof(string));
                displayTable.Columns.Add("Priority", typeof(string));
                displayTable.Columns.Add("ReportedDateTime", typeof(DateTime));
                displayTable.Columns.Add("Location", typeof(string));
                displayTable.Columns.Add("ReportedBy", typeof(string));
                displayTable.Columns.Add("SymptomDescription", typeof(string));
                displayTable.Columns.Add("Status", typeof(string));
                
                foreach (DataRow row in dt.Rows)
                {
                    var newRow = displayTable.NewRow();
                    newRow["RawID"] = row["ID"];
                    newRow["TroubleshootingID"] = "TS-" + row["ID"].ToString();
                    newRow["Priority"] = row["Priority"] != DBNull.Value ? row["Priority"].ToString() : "LOW";
                    newRow["ReportedDateTime"] = row["ReportedDateTime"];
                    newRow["Location"] = row["Location"] != DBNull.Value ? row["Location"].ToString() : "N/A";
                    newRow["ReportedBy"] = row["ReportedBy"] != DBNull.Value ? row["ReportedBy"].ToString() : "N/A";
                    newRow["SymptomDescription"] = row["Symptom"] != DBNull.Value ? row["Symptom"].ToString() : "No description";
                    newRow["Status"] = row["Status"] != DBNull.Value ? row["Status"].ToString() : "No Status";
                    displayTable.Rows.Add(newRow);
                }
                
                System.Diagnostics.Debug.WriteLine("Transformed " + displayTable.Rows.Count + " rows");
                
                if (gvOpenIssues != null)
                {
                    System.Diagnostics.Debug.WriteLine("Binding GridView...");
                    gvOpenIssues.DataSource = displayTable;
                    gvOpenIssues.DataBind();
                    System.Diagnostics.Debug.WriteLine("GridView bound successfully");
                }
                else
                {
                    System.Diagnostics.Debug.WriteLine("ERROR: gvOpenIssues is NULL!");
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("LoadOpenIssuesTable ERROR: " + ex.Message);
            System.Diagnostics.Debug.WriteLine("Stack: " + ex.StackTrace);
            
            // Show error in the UI
            if (gvOpenIssues != null && gvOpenIssues.Parent != null)
            {
                var errorLabel = new System.Web.UI.WebControls.Label();
                errorLabel.Text = "Error loading issues: " + ex.Message;
                errorLabel.ForeColor = System.Drawing.Color.Red;
                gvOpenIssues.Parent.Controls.Add(errorLabel);
            }
        }
    }

    private void LoadRecentAdditions()
    {
        // Force section visible for debugging
        if (recentAdditionsTableSection != null)
        {
            recentAdditionsTableSection.Visible = true;
        }
        
        try
        {
            var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
            using (var conn = new SqlConnection(cs))
            {
                conn.Open();
                
                // Query for recent additions (last 30 days), ordered by Reported Date/Time
                var cmd = new SqlCommand(@"
                    SELECT TOP 50
                        ID,
                        Priority,
                        ReportedDateTime,
                        Location,
                        ReportedBy,
                        Symptom,
                        Status
                    FROM Troubleshooting_Log
                    WHERE ReportedDateTime >= DATEADD(DAY, -30, GETDATE())
                    ORDER BY ReportedDateTime DESC", conn);
                
                var dt = new DataTable();
                dt.Load(cmd.ExecuteReader());
                
                // Debug output
                System.Diagnostics.Debug.WriteLine("LoadRecentAdditions: Found " + dt.Rows.Count + " recent issues");
                
                // Transform the data for display
                var displayTable = new DataTable();
                displayTable.Columns.Add("RawID", typeof(int));  // Store raw ID for navigation
                displayTable.Columns.Add("TroubleshootingID", typeof(string));
                displayTable.Columns.Add("Priority", typeof(string));
                displayTable.Columns.Add("ReportedDateTime", typeof(DateTime));
                displayTable.Columns.Add("Location", typeof(string));
                displayTable.Columns.Add("ReportedBy", typeof(string));
                displayTable.Columns.Add("SymptomDescription", typeof(string));
                displayTable.Columns.Add("Status", typeof(string));
                
                foreach (DataRow row in dt.Rows)
                {
                    var newRow = displayTable.NewRow();
                    newRow["RawID"] = row["ID"];
                    newRow["TroubleshootingID"] = "TS-" + row["ID"].ToString();
                    newRow["Priority"] = row["Priority"] != DBNull.Value ? row["Priority"].ToString() : "LOW";
                    newRow["ReportedDateTime"] = row["ReportedDateTime"];
                    newRow["Location"] = row["Location"] != DBNull.Value ? row["Location"].ToString() : "N/A";
                    newRow["ReportedBy"] = row["ReportedBy"] != DBNull.Value ? row["ReportedBy"].ToString() : "N/A";
                    newRow["SymptomDescription"] = row["Symptom"] != DBNull.Value ? row["Symptom"].ToString() : "No description";
                    newRow["Status"] = row["Status"] != DBNull.Value ? row["Status"].ToString() : "No Status";
                    displayTable.Rows.Add(newRow);
                }
                
                System.Diagnostics.Debug.WriteLine("Transformed " + displayTable.Rows.Count + " recent addition rows");
                
                if (gvRecentAdditions != null)
                {
                    System.Diagnostics.Debug.WriteLine("Binding Recent Additions GridView...");
                    gvRecentAdditions.DataSource = displayTable;
                    gvRecentAdditions.DataBind();
                    System.Diagnostics.Debug.WriteLine("Recent Additions GridView bound successfully");
                }
                else
                {
                    System.Diagnostics.Debug.WriteLine("ERROR: gvRecentAdditions is NULL!");
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("LoadRecentAdditions ERROR: " + ex.Message);
            System.Diagnostics.Debug.WriteLine("Stack: " + ex.StackTrace);
            
            // Show error in the UI
            if (gvRecentAdditions != null && gvRecentAdditions.Parent != null)
            {
                var errorLabel = new System.Web.UI.WebControls.Label();
                errorLabel.Text = "Error loading recent additions: " + ex.Message;
                errorLabel.ForeColor = System.Drawing.Color.Red;
                gvRecentAdditions.Parent.Controls.Add(errorLabel);
            }
        }
    }

    private void LoadKPIs()
    {
        try
        {
            var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
            using (var conn = new SqlConnection(cs))
            {
                conn.Open();
                
                // Get KPI data
                using (var cmd = new SqlCommand("SELECT * FROM dbo.vw_Troubleshooting_Dashboard_KPIs", conn))
                using (var rdr = cmd.ExecuteReader())
                {
                    if (rdr.Read())
                    {
                        // Total Issues (all time)
                        int totalIssues = GetInt(rdr, "TotalIssuesAllTime");
                        if (litTotalIssues != null) litTotalIssues.Text = totalIssues.ToString();
                        
                        // Open Issues
                        int openIssues = GetInt(rdr, "OpenIssues");
                        OpenIssuesCount = openIssues.ToString();  // Expose for gauge
                        if (litOpenIssues != null) litOpenIssues.Text = openIssues.ToString();
                        
                        // Critical Issues
                        int criticalIssues = GetInt(rdr, "CriticalIssues");
                        CriticalCount = criticalIssues.ToString();  // Expose for gauge
                        
                        // Update critical text with color
                        if (litCriticalText != null)
                        {
                            if (criticalIssues == 0)
                            {
                                litCriticalText.Text = "<span style='color:#6b7280;'>0 critical priority</span>";
                            }
                            else
                            {
                                litCriticalText.Text = "<span style='color:#ef4444;font-weight:600;'>" + criticalIssues + " critical priority</span>";
                            }
                        }
                        
                        // Apply status color to Open Issues card: Green if 0, Amber if 1-4, Red if >= 5
                        if (openIssues == 0) ApplyStatusClass(cardOpenIssues, 0, 1, 5);
                        else if (openIssues < 5) ApplyStatusClass(cardOpenIssues, 3, 1, 5);
                        else ApplyStatusClass(cardOpenIssues, 100, 1, 5);

                        // Average Resolution Time
                        decimal avgResTime = GetDecimal(rdr, "AvgResolutionTimeHours");
                        AvgResolutionTime = avgResTime.ToString("0.00");  // Expose with 2 decimals for mini-line chart
                        
                        // Display in hours and minutes for better readability
                        if (litResolutionTime != null)
                        {
                            if (avgResTime < 1)
                            {
                                // Less than 1 hour - show in minutes
                                int minutes = (int)Math.Round(avgResTime * 60);
                                litResolutionTime.Text = minutes + "m";
                            }
                            else
                            {
                                // 1 hour or more - show hours and minutes
                                int hours = (int)Math.Floor(avgResTime);
                                int minutes = (int)Math.Round((avgResTime - hours) * 60);
                                if (minutes > 0)
                                    litResolutionTime.Text = hours + "h " + minutes + "m";
                                else
                                    litResolutionTime.Text = hours + "h";
                            }
                        }
                        
                        // Green if < 10h, Amber if < 24h, Red if >= 24h (updated threshold)
                        if (avgResTime < 10) ApplyStatusClass(cardResolutionTime, 8, 10, 24);
                        else if (avgResTime < 24) ApplyStatusClass(cardResolutionTime, 18, 10, 24);
                        else ApplyStatusClass(cardResolutionTime, 100, 10, 24);

                        // Total Downtime (30 days) - Target: <30h
                        decimal downtime = GetDecimal(rdr, "TotalDowntimeHours30Days");
                        TotalDowntimeHours = downtime.ToString("0.0");  // Expose for gauge chart
                        if (litDowntime != null) litDowntime.Text = downtime.ToString("0.0") + "h";
                        
                        // Apply color based on new threshold: Green (<15h), Amber (15-30h), Red (>30h)
                        if (downtime < 15) ApplyStatusClass(cardDowntime, 10, 15, 30);
                        else if (downtime < 30) ApplyStatusClass(cardDowntime, 22, 15, 30);
                        else ApplyStatusClass(cardDowntime, 100, 15, 30);

                        // Repeat Issue Rate
                        decimal repeatRate = GetDecimal(rdr, "RepeatIssueRate");
                        RepeatIssueRate = repeatRate.ToString("0.0");  // Expose for chart calculations
                        
                        // Get actual repeat issues count from database (not calculated)
                        int repeatCount = GetInt(rdr, "RepeatIssuesCount");
                        decimal repeatRateValue = RepeatIssueRate != null ? decimal.Parse(RepeatIssueRate) : 0m;
                        if (litRepeatCount != null) litRepeatCount.Text = repeatCount.ToString();
                        
                        // Update footer with rate information
                        if (litRepeatText != null) litRepeatText.Text = "All time | Rate: " + repeatRateValue.ToString("0.0") + "%";
                        
                        // No color classes - keep white card
                        RepeatIssuesStatusClass = "";
                    }
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("KPI Load Error: " + ex.Message);
            if (litTotalIssues != null) litTotalIssues.Text = "0";
            if (litOpenIssues != null) litOpenIssues.Text = "0";
            if (litCriticalText != null) litCriticalText.Text = "0 critical priority";
            if (litResolutionTime != null) litResolutionTime.Text = "--h";
            if (litDowntime != null) litDowntime.Text = "--h";
            if (litRepeatCount != null) litRepeatCount.Text = "--";
            AvgResolutionTime = "0";
            TotalDowntimeHours = "0";
            RepeatIssueRate = "0";
            OpenIssuesCount = "0";
            CriticalCount = "0";
        }
    }

    private void LoadMiniChartData()
    {
        try
        {
            var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
            var serializer = new JavaScriptSerializer();

            using (var conn = new SqlConnection(cs))
            {
                conn.Open();

                // Monthly Trend (Last 12 months) - for mini-chart only
                var monthlyLabels = new List<string>();
                var monthlyValues = new List<int>();
                using (var cmd = new SqlCommand(@"
                    SELECT 
                        FORMAT(ReportedDateTime, 'MMM yyyy') as MonthLabel,
                        COUNT(*) as IssueCount
                    FROM Troubleshooting_Log
                    WHERE ReportedDateTime >= DATEADD(MONTH, -12, GETDATE())
                    GROUP BY YEAR(ReportedDateTime), MONTH(ReportedDateTime), FORMAT(ReportedDateTime, 'MMM yyyy')
                    ORDER BY YEAR(ReportedDateTime), MONTH(ReportedDateTime)", conn))
                using (var rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        monthlyLabels.Add(rdr["MonthLabel"].ToString());
                        monthlyValues.Add(Convert.ToInt32(rdr["IssueCount"]));
                    }
                }
                if (monthlyLabels.Count == 0) 
                {
                    monthlyLabels.Add("No Data");
                    monthlyValues.Add(0);
                }
                MonthlyLabels = serializer.Serialize(monthlyLabels);
                MonthlyData = serializer.Serialize(monthlyValues);
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Mini Chart Data Load Error: " + ex.Message);
            // Set default empty data
            var serializer = new JavaScriptSerializer();
            MonthlyLabels = serializer.Serialize(new[] { "No Data" });
            MonthlyData = serializer.Serialize(new[] { 0 });
        }
    }

    private void LoadChartData()
    {
        try
        {
            var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
            var serializer = new JavaScriptSerializer();

            using (var conn = new SqlConnection(cs))
            {
                conn.Open();



                // Resolution Times (Last 10 resolved issues for mini-line chart)
                var resolutionTimes = new List<decimal>();
                var troubleshootingIDs = new List<string>();
                using (var cmd = new SqlCommand(@"
                    SELECT TOP 10 
                        ID,
                        ResolutionTimeHours
                    FROM Troubleshooting_Log
                    WHERE Status IN ('Resolved', 'Closed')
                        AND ResolutionTimeHours IS NOT NULL
                        AND ResolvedDateTime IS NOT NULL
                    ORDER BY ResolvedDateTime DESC", conn))
                using (var rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        var id = rdr["ID"].ToString();
                        troubleshootingIDs.Add("TS-" + id);
                        resolutionTimes.Add(Convert.ToDecimal(rdr["ResolutionTimeHours"]));
                    }
                }
                // Reverse to show oldest to newest (left to right)
                troubleshootingIDs.Reverse();
                resolutionTimes.Reverse();
                
                // If less than 10, pad with zeros or use what we have
                if (resolutionTimes.Count == 0)
                {
                    troubleshootingIDs.Add("N/A");
                    resolutionTimes.Add(0);
                }
                ResolutionTimesData = serializer.Serialize(resolutionTimes.Select(v => Math.Round(v, 2)).ToList());
                TroubleshootingIDs = serializer.Serialize(troubleshootingIDs);

                // Waterfall Chart Data (30-day issue movement)
                var waterfallLabels = new List<string> { "Start (30 days ago)", "New Issues", "Resolved", "Closed", "Current Open" };
                var waterfallValues = new List<int>();
                
                int startingOpen = 0, newIssues = 0, resolved = 0, closed = 0, currentOpen = 0;
                
                using (var cmd = new SqlCommand(@"
                    -- Starting open issues (31 days ago)
                    SELECT COUNT(*) as StartingOpen
                    FROM Troubleshooting_Log
                    WHERE ReportedDateTime < DATEADD(DAY, -30, GETDATE())
                        AND (ResolvedDateTime IS NULL OR ResolvedDateTime >= DATEADD(DAY, -30, GETDATE()))
                        AND (Status NOT IN ('Resolved', 'Closed') OR Status IS NULL)", conn))
                {
                    var result = cmd.ExecuteScalar();
                    startingOpen = result != null ? Convert.ToInt32(result) : 0;
                }
                
                using (var cmd = new SqlCommand(@"
                    -- New issues reported in last 30 days
                    SELECT COUNT(*) as NewIssues
                    FROM Troubleshooting_Log
                    WHERE ReportedDateTime >= DATEADD(DAY, -30, GETDATE())", conn))
                {
                    var result = cmd.ExecuteScalar();
                    newIssues = result != null ? Convert.ToInt32(result) : 0;
                }
                
                using (var cmd = new SqlCommand(@"
                    -- Issues resolved in last 30 days
                    SELECT COUNT(*) as Resolved
                    FROM Troubleshooting_Log
                    WHERE ResolvedDateTime >= DATEADD(DAY, -30, GETDATE())
                        AND ResolvedDateTime < GETDATE()
                        AND Status = 'Resolved'", conn))
                {
                    var result = cmd.ExecuteScalar();
                    resolved = result != null ? Convert.ToInt32(result) : 0;
                }
                
                using (var cmd = new SqlCommand(@"
                    -- Issues closed in last 30 days (separate from resolved)
                    SELECT COUNT(*) as Closed
                    FROM Troubleshooting_Log
                    WHERE ResolvedDateTime >= DATEADD(DAY, -30, GETDATE())
                        AND ResolvedDateTime < GETDATE()
                        AND Status = 'Closed'", conn))
                {
                    var result = cmd.ExecuteScalar();
                    closed = result != null ? Convert.ToInt32(result) : 0;
                }
                
                using (var cmd = new SqlCommand(@"
                    -- Current open issues
                    SELECT COUNT(*) as CurrentOpen
                    FROM Troubleshooting_Log
                    WHERE (Status NOT IN ('Resolved', 'Closed') OR Status IS NULL)
                        AND (ResolvedDateTime IS NULL OR ResolvedDateTime > GETDATE())", conn))
                {
                    var result = cmd.ExecuteScalar();
                    currentOpen = result != null ? Convert.ToInt32(result) : 0;
                }
                
                // Build waterfall data: cumulative values for waterfall effect
                // The waterfall should show the flow: Start -> +New -> -Resolved -> -Closed -> Current
                int calculatedCurrent = startingOpen + newIssues - resolved - closed;
                
                waterfallValues.Add(startingOpen);                              // Start (30 days ago)
                waterfallValues.Add(startingOpen + newIssues);                  // After adding new issues
                waterfallValues.Add(startingOpen + newIssues - resolved);       // After resolving issues
                waterfallValues.Add(startingOpen + newIssues - resolved - closed); // After closing issues
                waterfallValues.Add(calculatedCurrent);                         // Current (calculated from flow)
                
                // Build color array based on values
                // Green (0), Amber (1-5), Red (>5)
                var waterfallColorArray = new List<string>();
                waterfallColorArray.Add("neutral");  // Start - always neutral
                waterfallColorArray.Add("increase"); // New Issues - always red (increase)
                waterfallColorArray.Add("decrease"); // Resolved - always green (decrease)
                waterfallColorArray.Add("decrease"); // Closed - always green (decrease)
                
                // Current Open - dynamic color based on value
                if (calculatedCurrent == 0)
                    waterfallColorArray.Add("success");  // Green when 0
                else if (calculatedCurrent <= 5)
                    waterfallColorArray.Add("warning");  // Orange when 1-5
                else
                    waterfallColorArray.Add("danger");   // Red when >5
                
                WaterfallLabels = serializer.Serialize(waterfallLabels);
                WaterfallData = serializer.Serialize(waterfallValues);
                WaterfallColors = serializer.Serialize(waterfallColorArray);

                // 1. Classification Distribution (Top 10)
                var classLabels = new List<string>();
                var classValues = new List<int>();
                using (var cmd = new SqlCommand(@"
                    SELECT TOP 10
                        ISNULL(IssueClassification, 'Unclassified') as Classification,
                        COUNT(*) as IssueCount
                    FROM Troubleshooting_Log
                    WHERE ReportedDateTime >= DATEADD(MONTH, -12, GETDATE())
                        OR Status NOT IN ('Resolved', 'Closed')
                        OR Status IS NULL
                    GROUP BY IssueClassification
                    ORDER BY COUNT(*) DESC", conn))
                using (var rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        classLabels.Add(rdr["Classification"].ToString());
                        classValues.Add(Convert.ToInt32(rdr["IssueCount"]));
                    }
                }
                if (classLabels.Count == 0) 
                {
                    classLabels.Add("No Data");
                    classValues.Add(1);
                }
                ClassificationLabels = serializer.Serialize(classLabels);
                ClassificationData = serializer.Serialize(classValues);

                // 4. Resolution Time by Priority
                var resTimeLabels = new List<string>();
                var resTimeValues = new List<decimal>();
                using (var cmd = new SqlCommand(@"
                    SELECT 
                        ISNULL(Priority, 'Unassigned') as Priority,
                        AVG(ResolutionTimeHours) as AvgResolutionHours
                    FROM Troubleshooting_Log
                    WHERE Status IN ('Resolved', 'Closed')
                        AND ResolutionTimeHours IS NOT NULL
                        AND ResolvedDateTime >= DATEADD(MONTH, -12, GETDATE())
                    GROUP BY Priority
                    ORDER BY AVG(ResolutionTimeHours) DESC", conn))
                using (var rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        resTimeLabels.Add(rdr["Priority"].ToString());
                        resTimeValues.Add(Convert.ToDecimal(rdr["AvgResolutionHours"]));
                    }
                }
                if (resTimeLabels.Count == 0) 
                {
                    resTimeLabels.Add("No Data");
                    resTimeValues.Add(0);
                }
                ResolutionTimeLabels = serializer.Serialize(resTimeLabels);
                ResolutionTimeData = serializer.Serialize(resTimeValues.Select(v => Math.Round(v, 1)).ToList());

                // 5. Equipment Type Distribution
                var eqTypeLabels = new List<string>();
                var eqTypeValues = new List<int>();
                using (var cmd = new SqlCommand(@"
                    SELECT 
                        EquipmentType,
                        COUNT(*) as IssueCount
                    FROM (
                        SELECT 
                            CASE 
                                WHEN AffectedATE IS NOT NULL AND AffectedATE <> '' THEN 'ATE'
                                WHEN AffectedEquipment IS NOT NULL AND AffectedEquipment <> '' THEN 'Equipment'
                                WHEN AffectedFixture IS NOT NULL AND AffectedFixture <> '' THEN 'Fixture'
                                WHEN AffectedHarness IS NOT NULL AND AffectedHarness <> '' THEN 'Harness'
                                ELSE 'Other'
                            END AS EquipmentType
                        FROM Troubleshooting_Log
                        WHERE ReportedDateTime >= DATEADD(MONTH, -12, GETDATE())
                            OR Status NOT IN ('Resolved', 'Closed')
                            OR Status IS NULL
                    ) AS EquipmentData
                    GROUP BY EquipmentType
                    ORDER BY COUNT(*) DESC", conn))
                using (var rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        eqTypeLabels.Add(rdr["EquipmentType"].ToString());
                        eqTypeValues.Add(Convert.ToInt32(rdr["IssueCount"]));
                    }
                }
                if (eqTypeLabels.Count == 0) 
                {
                    eqTypeLabels.Add("No Data");
                    eqTypeValues.Add(1);
                }
                EquipmentTypeLabels = serializer.Serialize(eqTypeLabels);
                EquipmentTypeData = serializer.Serialize(eqTypeValues);

                // 6. Issues by Equipment (Top 15)
                var equipmentLabels = new List<string>();
                var equipmentValues = new List<int>();
                using (var cmd = new SqlCommand("SELECT EquipmentID, EquipmentType, IssueCount FROM dbo.vw_Troubleshooting_IssuesByEquipment", conn))
                using (var rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        string eqId = rdr["EquipmentID"].ToString();
                        string eqType = rdr["EquipmentType"].ToString();
                        equipmentLabels.Add(eqId + " (" + eqType + ")");
                        equipmentValues.Add(Convert.ToInt32(rdr["IssueCount"]));
                    }
                }
                if (equipmentLabels.Count == 0) 
                {
                    equipmentLabels.Add("No Data");
                    equipmentValues.Add(1);
                }
                EquipmentLabels = serializer.Serialize(equipmentLabels);
                EquipmentData = serializer.Serialize(equipmentValues);

                // 7. Issues by Line (Top Level for Drill-Down)
                var lineLabels = new List<string>();
                var lineValues = new List<int>();
                using (var cmd = new SqlCommand("SELECT Line, IssueCount FROM dbo.vw_Troubleshooting_IssuesByLine", conn))
                using (var rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        lineLabels.Add(rdr["Line"].ToString());
                        lineValues.Add(Convert.ToInt32(rdr["IssueCount"]));
                    }
                }
                if (lineLabels.Count == 0) 
                {
                    lineLabels.Add("No Data");
                    lineValues.Add(1);
                }
                LineLabels = serializer.Serialize(lineLabels);
                LineData = serializer.Serialize(lineValues);

                // 8. Issues by Line AND Location (Full hierarchy for drill-down)
                var drillDownMap = new Dictionary<string, List<object>>();
                using (var cmd = new SqlCommand(@"
                    SELECT Line, Location, IssueCount 
                    FROM dbo.vw_Troubleshooting_IssuesByLineAndLocation
                    ORDER BY Line, IssueCount DESC", conn))
                using (var rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        string line = rdr["Line"].ToString();
                        if (!drillDownMap.ContainsKey(line))
                            drillDownMap[line] = new List<object>();
                        
                        drillDownMap[line].Add(new {
                            location = rdr["Location"].ToString(),
                            count = Convert.ToInt32(rdr["IssueCount"])
                        });
                    }
                }
                DrillDownData = serializer.Serialize(drillDownMap);

                // 9. Sankey Diagram Data (Total Issues → Equipment Type → Specific Equipment → Issue Classification)
                using (var cmd = new SqlCommand(@"
                    SELECT EquipmentType, EquipmentID, IssueClassification, IssueCount 
                    FROM dbo.vw_Troubleshooting_SankeyData
                    ORDER BY EquipmentType, EquipmentID, IssueCount DESC", conn))
            {
                using (var rdr = cmd.ExecuteReader())
                {
                    var nodes = new List<object>();
                    var links = new List<object>();
                    var nodeIndexMap = new Dictionary<string, int>();
                    
                    // Add root node
                    nodes.Add(new { name = "Total Issues" });
                    nodeIndexMap["Total Issues"] = 0;
                    
                    // Add equipment type nodes (Level 1) - Ordered to avoid flow crossing
                    // Asset at top, ATE below to prevent visual entanglement
                    var equipmentTypes = new[] { "Asset", "ATE", "Fixture", "Harness" };
                    for (int i = 0; i < equipmentTypes.Length; i++)
                    {
                        nodes.Add(new { name = equipmentTypes[i] });
                        nodeIndexMap[equipmentTypes[i]] = i + 1;
                    }
                    
                    int nextNodeIndex = equipmentTypes.Length + 1;
                    var typeIssueCounts = new Dictionary<string, int>();
                    var equipmentIssueCounts = new Dictionary<string, int>(); // Track issues per equipment
                    var classificationNodes = new HashSet<string>(); // Track unique classifications
                    
                    // Process equipment items and classifications, build links
                    while (rdr.Read())
                    {
                        string eqType = rdr["EquipmentType"].ToString();
                        string eqId = rdr["EquipmentID"].ToString();
                        string classification = rdr["IssueClassification"].ToString();
                        int issueCount = Convert.ToInt32(rdr["IssueCount"]);
                        
                        // Track total issues per type
                        if (!typeIssueCounts.ContainsKey(eqType))
                            typeIssueCounts[eqType] = 0;
                        typeIssueCounts[eqType] += issueCount;
                        
                        // Add equipment node (Level 2) - Only Eaton ID, no equipment type in parentheses
                        string equipmentNodeName = eqId;
                        string equipmentKey = eqType + "|" + eqId; // Unique key per type
                        
                        if (!nodeIndexMap.ContainsKey(equipmentKey))
                        {
                            nodes.Add(new { name = equipmentNodeName, type = eqType }); // Store type for color mapping
                            nodeIndexMap[equipmentKey] = nextNodeIndex++;
                        }
                        
                        // Track issues per equipment
                        if (!equipmentIssueCounts.ContainsKey(equipmentKey))
                            equipmentIssueCounts[equipmentKey] = 0;
                        equipmentIssueCounts[equipmentKey] += issueCount;
                        
                        // Add classification node (Level 3)
                        string classificationNodeName = classification;
                        if (!nodeIndexMap.ContainsKey(classificationNodeName))
                        {
                            nodes.Add(new { name = classificationNodeName });
                            nodeIndexMap[classificationNodeName] = nextNodeIndex++;
                            classificationNodes.Add(classificationNodeName);
                        }
                        
                        // Create link from specific equipment to classification
                        links.Add(new { 
                            source = nodeIndexMap[equipmentKey], 
                            target = nodeIndexMap[classificationNodeName], 
                            value = issueCount 
                        });
                    }
                    
                    // Create links from equipment type to specific equipment
                    foreach (var eqCount in equipmentIssueCounts)
                    {
                        string[] parts = eqCount.Key.Split('|');
                        string eqType = parts[0];
                        
                        links.Add(new { 
                            source = nodeIndexMap[eqType], 
                            target = nodeIndexMap[eqCount.Key], 
                            value = eqCount.Value 
                        });
                    }
                    
                    // Create links from Total Issues to Equipment Types
                    foreach (var typeCount in typeIssueCounts)
                    {
                        links.Add(new { 
                            source = 0, 
                            target = nodeIndexMap[typeCount.Key], 
                            value = typeCount.Value 
                        });
                    }
                    
                    // Serialize Sankey data
                    var sankeyData = new { nodes = nodes, links = links };
                    SankeyData = serializer.Serialize(sankeyData);
                }
            }
            } // Close connection
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Chart Data Load Error: " + ex.Message);
            // Set default empty data
            var serializer = new JavaScriptSerializer();
            ResolutionTimesData = serializer.Serialize(new[] { 0.0 });
            ClassificationLabels = serializer.Serialize(new[] { "No Data" });
            ClassificationData = serializer.Serialize(new[] { 1 });
            ResolutionTimeLabels = serializer.Serialize(new[] { "No Data" });
            ResolutionTimeData = serializer.Serialize(new[] { 0 });
            EquipmentTypeLabels = serializer.Serialize(new[] { "No Data" });
            EquipmentTypeData = serializer.Serialize(new[] { 1 });
            LineLabels = serializer.Serialize(new[] { "No Data" });
            LineData = serializer.Serialize(new[] { 1 });
            DrillDownData = serializer.Serialize(new Dictionary<string, object>());
            SankeyData = serializer.Serialize(new { nodes = new object[0], links = new object[0] });
        }
    }

    protected void btnViewDetails_Click(object sender, EventArgs e)
    {
        try
        {
            var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
            
            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand(@"
                SELECT TOP 1 ID
                FROM dbo.Troubleshooting_Log
                ORDER BY ReportedDateTime DESC", conn))
            {
                conn.Open();
                var id = cmd.ExecuteScalar();
                if (id != null)
                {
                    Response.Redirect("TroubleshootingDetails.aspx?id=" + id);
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("View Details Error: " + ex.Message);
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

    protected void gvOpenIssues_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            // Get the raw ID from the data
            var rawID = DataBinder.Eval(e.Row.DataItem, "RawID");
            if (rawID != null)
            {
                // Add data attribute and styling for clickable rows
                e.Row.Attributes["data-issue-id"] = rawID.ToString();
                e.Row.Attributes["style"] = "cursor: pointer;";
                e.Row.Attributes["onclick"] = "showIssueDetailsModal('" + rawID.ToString() + "', '" + 
                    DataBinder.Eval(e.Row.DataItem, "TroubleshootingID") + "');";
            }
        }
    }

    protected void gvRecentAdditions_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            // Get the raw ID from the data
            var rawID = DataBinder.Eval(e.Row.DataItem, "RawID");
            if (rawID != null)
            {
                // Add data attribute and styling for clickable rows
                e.Row.Attributes["data-issue-id"] = rawID.ToString();
                e.Row.Attributes["style"] = "cursor: pointer;";
                e.Row.Attributes["onclick"] = "showIssueDetailsModal('" + rawID.ToString() + "', '" + 
                    DataBinder.Eval(e.Row.DataItem, "TroubleshootingID") + "');";
            }
        }
    }
}