using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Security;
using System.Collections.Generic;
using System.Linq;
using System.Web.Script.Serialization;

public partial class TED_PMDashboard : System.Web.UI.Page
{
    private string connStr = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;

    protected string MonthlyLabels = "[]";
    protected string MonthlyData = "[]";
    protected string EquipmentTypeLabels = "[]";
    protected string EquipmentTypeData = "[]";
    protected string PMTypeLabels = "[]";
    protected string PMTypeData = "[]";
    protected string OnTimeLabels = "[]";
    protected string OnTimeData = "[]";
    protected string CostTrendLabels = "[]";
    protected string CostTrendData = "[]";
    
    // New properties for mini-line charts
    protected string MiniLineTotalPMsData = "[]";
    protected string MiniLineDurationData = "[]";
    protected string MiniLineCostData = "[]";
    protected string PMIDs = "[]";  // For duration and cost per-PM charts
    protected decimal AvgDuration = 0;  // Average duration for dotted line
    protected decimal AvgCost = 0;      // Average cost for dotted line
    
    // New properties for KPI cards
    protected int TotalPMs = 0;
    protected int DuePMs = 0;
    protected int OverduePMs = 0;
    protected decimal ComplianceRate = 0;
    
    // Sankey diagram data
    protected string SankeyData = "{\"nodes\":[],\"links\":[]}";

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!User.Identity.IsAuthenticated)
        {
            Response.Redirect("~/Account/Login.aspx");
            return;
        }

        if (!IsPostBack)
        {
            LoadUserInfo();
            LoadKPIs();
            LoadChartData();
            LoadMiniLineCharts();
            LoadSankeyData();
            LoadUpcomingPMs();
            LoadRecentCompletions();
        }
    }

    private void LoadUserInfo()
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
            var parts = input.Split(new char[] { ' ', '.', '_' }, StringSplitOptions.RemoveEmptyEntries);
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
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                
                // Get Due/Overdue counts from PM Status view
                string pmStatusQuery = "SELECT DueSoon, Overdue FROM vw_EquipmentInventory_PMStatus";
                
                int overdue = 0;
                int dueSoon = 0;
                
                using (SqlCommand pmCmd = new SqlCommand(pmStatusQuery, conn))
                {
                    SqlDataReader pmReader = pmCmd.ExecuteReader();
                    if (pmReader.Read())
                    {
                        overdue = pmReader["Overdue"] != DBNull.Value ? Convert.ToInt32(pmReader["Overdue"]) : 0;
                        dueSoon = pmReader["DueSoon"] != DBNull.Value ? Convert.ToInt32(pmReader["DueSoon"]) : 0;
                    }
                    pmReader.Close();
                }
                
                // Due PMs should include both overdue and due soon
                int totalDue = overdue + dueSoon;
                
                // Get all other metrics from PM_Log table (completed PMs)
                string query = @"
                    SELECT 
                        COUNT(*) AS TotalCompletedPMs,
                        CAST(ISNULL((SUM(CASE WHEN IsOnTime = 1 THEN 1 ELSE 0 END) * 100.0) / NULLIF(COUNT(*), 0), 0) AS DECIMAL(5,1)) AS ComplianceRate,
                        ISNULL(SUM(CASE WHEN IsOnTime = 1 THEN 1 ELSE 0 END), 0) AS OnTimePMs,
                        ISNULL(AVG(ActualDuration), 0) AS AvgDurationMinutes,
                        ISNULL(AVG(Cost), 0) AS AvgCostPerPM
                    FROM PM_Log
                    WHERE PMDate >= DATEADD(MONTH, -12, GETDATE())
                    AND PMDate IS NOT NULL";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    SqlDataReader reader = cmd.ExecuteReader();

                    if (reader.Read())
                    {
                        decimal complianceRate = Convert.ToDecimal(reader["ComplianceRate"]);
                        int onTimePMs = Convert.ToInt32(reader["OnTimePMs"]);
                        int totalPMs = Convert.ToInt32(reader["TotalCompletedPMs"]);
                        decimal avgDuration = Convert.ToDecimal(reader["AvgDurationMinutes"]);
                        decimal avgCost = Convert.ToDecimal(reader["AvgCostPerPM"]);
                        
                        // Store values for JavaScript access
                        OverduePMs = overdue;
                        DuePMs = totalDue;
                        ComplianceRate = complianceRate;
                        TotalPMs = totalPMs;

                        // Set new KPI card values
                        litTotalPMs.Text = totalPMs.ToString();
                        litDuePMs.Text = totalDue.ToString();
                        litOverdueText.Text = overdue > 0 ? overdue.ToString() + " overdue" : "None overdue";
                        litComplianceRate.Text = complianceRate.ToString("0.0") + "%";
                        litComplianceCount.Text = string.Format("{0} of {1}", onTimePMs, totalPMs);

                        // Format average duration
                        if (avgDuration > 0)
                        {
                            if (avgDuration >= 60)
                            {
                                double hours = Convert.ToDouble(avgDuration) / 60.0;
                                litAvgDuration.Text = hours.ToString("0.0") + "h";
                            }
                            else
                            {
                                litAvgDuration.Text = Math.Round(avgDuration, 0).ToString() + "m";
                            }
                            litAvgDurationText.Text = "Last 12 months";
                        }
                        else
                        {
                            litAvgDuration.Text = "--";
                            litAvgDurationText.Text = "No data";
                        }

                        // Format average cost
                        if (avgCost > 0)
                        {
                            litAvgCost.Text = "$" + avgCost.ToString("N2");
                            litCostText.Text = "Last 12 months";
                        }
                        else
                        {
                            litAvgCost.Text = "$--";
                            litCostText.Text = "No cost data";
                        }

                        // Set card status colors
                        // Due PMs card: Red if overdue > 0, Orange if any due, Green only when 0
                        if (overdue > 0)
                        {
                            cardDuePMs.Attributes["class"] = "kpi-card status-red";
                        }
                        else if (dueSoon > 0)
                        {
                            cardDuePMs.Attributes["class"] = "kpi-card status-orange";
                        }
                        else
                        {
                            cardDuePMs.Attributes["class"] = "kpi-card status-green";
                        }

                        // Compliance card colors
                        if (complianceRate >= 90)
                        {
                            cardCompliance.Attributes["class"] = "kpi-card status-green";
                        }
                        else if (complianceRate >= 75)
                        {
                            cardCompliance.Attributes["class"] = "kpi-card status-amber";
                        }
                        else
                        {
                            cardCompliance.Attributes["class"] = "kpi-card status-red";
                        }
                        
                        // Set overdue text color
                        if (overdue > 0)
                        {
                            // Will be styled red via CSS
                        }
                    }
                    reader.Close();
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("LoadKPIs Error: " + ex.Message);
            litTotalPMs.Text = "0";
            litDuePMs.Text = "0";
            litOverdueText.Text = "None overdue";
            litComplianceRate.Text = "--";
            litComplianceCount.Text = "0 of 0";
            litAvgDuration.Text = "--";
            litAvgCost.Text = "$--";
        }
    }

    private void LoadChartData()
    {
        try
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                // Monthly Trend
                string monthlyQuery = @"
                    IF EXISTS (SELECT 1 FROM sys.views WHERE name = 'vw_PM_MonthlyTrend')
                    BEGIN
                        SELECT TOP 12 MonthLabel, PMCount FROM vw_PM_MonthlyTrend ORDER BY Year, Month
                    END
                    ELSE
                    BEGIN
                        SELECT 
                            FORMAT(PMDate, 'MMM yyyy') AS MonthLabel,
                            COUNT(*) AS PMCount
                        FROM PM_Log
                        WHERE PMDate >= DATEADD(MONTH, -12, GETDATE())
                        GROUP BY FORMAT(PMDate, 'MMM yyyy'), YEAR(PMDate), MONTH(PMDate)
                        ORDER BY YEAR(PMDate), MONTH(PMDate)
                    END";

                using (SqlCommand cmd = new SqlCommand(monthlyQuery, conn))
                {
                    SqlDataReader reader = cmd.ExecuteReader();
                    List<string> labels = new List<string>();
                    List<int> data = new List<int>();

                    while (reader.Read())
                    {
                        labels.Add(reader["MonthLabel"].ToString());
                        data.Add(Convert.ToInt32(reader["PMCount"]));
                    }
                    reader.Close();

                    JavaScriptSerializer js = new JavaScriptSerializer();
                    MonthlyLabels = js.Serialize(labels);
                    MonthlyData = js.Serialize(data);
                }

                // Equipment Type
                string equipmentQuery = @"
                    IF EXISTS (SELECT 1 FROM sys.views WHERE name = 'vw_PM_ByEquipmentType')
                    BEGIN
                        SELECT EquipmentType, PMCount FROM vw_PM_ByEquipmentType
                    END
                    ELSE
                    BEGIN
                        SELECT 
                            ISNULL(EquipmentType, 'Unknown') AS EquipmentType,
                            COUNT(*) AS PMCount
                        FROM PM_Log
                        WHERE PMDate >= DATEADD(MONTH, -12, GETDATE())
                        GROUP BY EquipmentType
                    END";

                using (SqlCommand cmd = new SqlCommand(equipmentQuery, conn))
                {
                    SqlDataReader reader = cmd.ExecuteReader();
                    List<string> labels = new List<string>();
                    List<int> data = new List<int>();

                    while (reader.Read())
                    {
                        labels.Add(reader["EquipmentType"].ToString());
                        data.Add(Convert.ToInt32(reader["PMCount"]));
                    }
                    reader.Close();

                    JavaScriptSerializer js = new JavaScriptSerializer();
                    EquipmentTypeLabels = js.Serialize(labels);
                    EquipmentTypeData = js.Serialize(data);
                }

                // PM Type
                string pmTypeQuery = @"
                    IF EXISTS (SELECT 1 FROM sys.views WHERE name = 'vw_PM_ByPMType')
                    BEGIN
                        SELECT PMType, PMCount FROM vw_PM_ByPMType
                    END
                    ELSE
                    BEGIN
                        SELECT 
                            ISNULL(PMType, 'Unknown') AS PMType,
                            COUNT(*) AS PMCount
                        FROM PM_Log
                        WHERE PMDate >= DATEADD(MONTH, -12, GETDATE())
                        GROUP BY PMType
                    END";

                using (SqlCommand cmd = new SqlCommand(pmTypeQuery, conn))
                {
                    SqlDataReader reader = cmd.ExecuteReader();
                    List<string> labels = new List<string>();
                    List<int> data = new List<int>();

                    while (reader.Read())
                    {
                        labels.Add(reader["PMType"].ToString());
                        data.Add(Convert.ToInt32(reader["PMCount"]));
                    }
                    reader.Close();

                    JavaScriptSerializer js = new JavaScriptSerializer();
                    PMTypeLabels = js.Serialize(labels);
                    PMTypeData = js.Serialize(data);
                }

                // On-Time Performance
                string onTimeQuery = @"
                    IF EXISTS (SELECT 1 FROM sys.views WHERE name = 'vw_PM_OnTimePerformance')
                    BEGIN
                        SELECT PerformanceStatus, PMCount FROM vw_PM_OnTimePerformance
                    END
                    ELSE
                    BEGIN
                        SELECT 
                            CASE WHEN IsOnTime = 1 THEN 'On Time' ELSE 'Late' END AS PerformanceStatus,
                            COUNT(*) AS PMCount
                        FROM PM_Log
                        WHERE PMDate >= DATEADD(MONTH, -12, GETDATE())
                        GROUP BY IsOnTime
                    END";

                using (SqlCommand cmd = new SqlCommand(onTimeQuery, conn))
                {
                    SqlDataReader reader = cmd.ExecuteReader();
                    List<string> labels = new List<string>();
                    List<int> data = new List<int>();

                    while (reader.Read())
                    {
                        labels.Add(reader["PerformanceStatus"].ToString());
                        data.Add(Convert.ToInt32(reader["PMCount"]));
                    }
                    reader.Close();

                    JavaScriptSerializer js = new JavaScriptSerializer();
                    OnTimeLabels = js.Serialize(labels);
                    OnTimeData = js.Serialize(data);
                }

                // Cost Trend
                string costTrendQuery = @"
                    IF EXISTS (SELECT 1 FROM sys.views WHERE name = 'vw_PM_CostTrend')
                    BEGIN
                        SELECT TOP 12 MonthLabel, TotalCost FROM vw_PM_CostTrend ORDER BY Year, Month
                    END
                    ELSE
                    BEGIN
                        SELECT 
                            FORMAT(PMDate, 'MMM yyyy') AS MonthLabel,
                            ISNULL(SUM(Cost), 0) AS TotalCost
                        FROM PM_Log
                        WHERE PMDate >= DATEADD(MONTH, -12, GETDATE())
                        GROUP BY FORMAT(PMDate, 'MMM yyyy'), YEAR(PMDate), MONTH(PMDate)
                        ORDER BY YEAR(PMDate), MONTH(PMDate)
                    END";

                using (SqlCommand cmd = new SqlCommand(costTrendQuery, conn))
                {
                    SqlDataReader reader = cmd.ExecuteReader();
                    List<string> labels = new List<string>();
                    List<decimal> data = new List<decimal>();

                    while (reader.Read())
                    {
                        labels.Add(reader["MonthLabel"].ToString());
                        data.Add(Convert.ToDecimal(reader["TotalCost"]));
                    }
                    reader.Close();

                    JavaScriptSerializer js = new JavaScriptSerializer();
                    CostTrendLabels = js.Serialize(labels);
                    CostTrendData = js.Serialize(data);
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("LoadChartData Error: " + ex.Message);
            MonthlyLabels = "[]";
            MonthlyData = "[]";
            EquipmentTypeLabels = "[]";
            EquipmentTypeData = "[]";
            PMTypeLabels = "[]";
            PMTypeData = "[]";
            OnTimeLabels = "[]";
            OnTimeData = "[]";
            CostTrendLabels = "[]";
            CostTrendData = "[]";
            
            MiniLineTotalPMsData = "[]";
            MiniLineDurationData = "[]";
            MiniLineCostData = "[]";
            PMIDs = "[]";
        }
    }
    
    private void LoadMiniLineCharts()
    {
        try
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                
                // Mini-line chart for Total PMs (last 12 months)
                string totalPMsQuery = @"
                    SELECT 
                        COUNT(*) AS PMCount
                    FROM PM_Log
                    WHERE PMDate >= DATEADD(MONTH, -12, GETDATE())
                    GROUP BY YEAR(PMDate), MONTH(PMDate)
                    ORDER BY YEAR(PMDate), MONTH(PMDate)";
                    
                using (SqlCommand cmd = new SqlCommand(totalPMsQuery, conn))
                {
                    SqlDataReader reader = cmd.ExecuteReader();
                    List<int> data = new List<int>();
                    
                    while (reader.Read())
                    {
                        data.Add(Convert.ToInt32(reader["PMCount"]));
                    }
                    reader.Close();
                    
                    JavaScriptSerializer js = new JavaScriptSerializer();
                    MiniLineTotalPMsData = js.Serialize(data);
                }
                
                // Mini-line chart for Duration (last 10 PMs)
                string durationQuery = @"
                    SELECT TOP 10
                        PMLogID,
                        ISNULL(ActualDuration, 0) AS Duration
                    FROM PM_Log
                    WHERE PMDate IS NOT NULL
                    ORDER BY PMDate DESC";
                    
                using (SqlCommand cmd = new SqlCommand(durationQuery, conn))
                {
                    SqlDataReader reader = cmd.ExecuteReader();
                    List<int> ids = new List<int>();
                    List<decimal> durations = new List<decimal>();
                    
                    while (reader.Read())
                    {
                        ids.Add(Convert.ToInt32(reader["PMLogID"]));
                        durations.Add(Convert.ToDecimal(reader["Duration"]));
                    }
                    reader.Close();
                    
                    // Reverse to show chronological order
                    ids.Reverse();
                    durations.Reverse();
                    
                    // Calculate average duration
                    if (durations.Count > 0)
                    {
                        AvgDuration = durations.Average();
                    }
                    
                    JavaScriptSerializer js = new JavaScriptSerializer();
                    PMIDs = js.Serialize(ids);
                    MiniLineDurationData = js.Serialize(durations);
                }
                
                // Mini-line chart for Cost (last 10 PMs)
                string costQuery = @"
                    SELECT TOP 10
                        ISNULL(Cost, 0) AS Cost
                    FROM PM_Log
                    WHERE PMDate IS NOT NULL
                    ORDER BY PMDate DESC";
                    
                using (SqlCommand cmd = new SqlCommand(costQuery, conn))
                {
                    SqlDataReader reader = cmd.ExecuteReader();
                    List<decimal> costs = new List<decimal>();
                    
                    while (reader.Read())
                    {
                        costs.Add(Convert.ToDecimal(reader["Cost"]));
                    }
                    reader.Close();
                    
                    // Reverse to show chronological order
                    costs.Reverse();
                    
                    // Calculate average cost
                    if (costs.Count > 0)
                    {
                        AvgCost = costs.Average();
                    }
                    
                    JavaScriptSerializer js = new JavaScriptSerializer();
                    MiniLineCostData = js.Serialize(costs);
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("LoadMiniLineCharts Error: " + ex.Message);
            MiniLineTotalPMsData = "[]";
            MiniLineDurationData = "[]";
            MiniLineCostData = "[]";
            PMIDs = "[]";
            AvgDuration = 0;
            AvgCost = 0;
        }
    }

    private void LoadSankeyData()
    {
        try
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                
                JavaScriptSerializer serializer = new JavaScriptSerializer();
                var sankeyNodes = new List<object>();
                var sankeyLinks = new List<object>();
                var nodeIndex = new Dictionary<string, int>();

                // Helper function to add nodes and get their index
                Func<string, int> getNodeIndex = (nodeName) =>
                {
                    if (!nodeIndex.ContainsKey(nodeName))
                    {
                        nodeIndex[nodeName] = sankeyNodes.Count;
                        sankeyNodes.Add(new { name = nodeName });
                    }
                    return nodeIndex[nodeName];
                };

                // Query the view for Sankey data
                var sankeyQuery = "SELECT SourceNode, TargetNode, Value FROM vw_PM_SankeyData WHERE Value > 0";
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
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("LoadSankeyData Error: " + ex.Message);
            SankeyData = "{\"nodes\":[],\"links\":[]}";
        }
    }

    private void LoadUpcomingPMs()
    {
        try
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                
                // Query equipment requiring PM from all inventory tables
                string query = @"
                    SELECT TOP 20 * FROM (
                        SELECT 
                            EatonID AS EquipmentEatonID,
                            ATEName AS EquipmentName,
                            Location,
                            CASE 
                                WHEN NextPM < CAST(GETDATE() AS DATE) THEN 'Overdue'
                                WHEN NextPM BETWEEN CAST(GETDATE() AS DATE) AND DATEADD(DAY, 7, CAST(GETDATE() AS DATE)) THEN 'Due This Week'
                                WHEN NextPM BETWEEN DATEADD(DAY, 8, CAST(GETDATE() AS DATE)) AND DATEADD(DAY, 30, CAST(GETDATE() AS DATE)) THEN 'Due This Month'
                                ELSE 'Due Soon'
                            END AS PMStatus,
                            NextPM AS NextPMDate,
                            ISNULL(PMResponsible, 'Unassigned') AS PMResponsible
                        FROM ATE_Inventory
                        WHERE IsActive = 1 
                        AND RequiredPM = 1
                        AND NextPM <= DATEADD(DAY, 30, CAST(GETDATE() AS DATE))
                        
                        UNION ALL
                        
                        SELECT 
                            EatonID AS EquipmentEatonID,
                            DeviceName AS EquipmentName,
                            Location,
                            CASE 
                                WHEN NextPM < CAST(GETDATE() AS DATE) THEN 'Overdue'
                                WHEN NextPM BETWEEN CAST(GETDATE() AS DATE) AND DATEADD(DAY, 7, CAST(GETDATE() AS DATE)) THEN 'Due This Week'
                                WHEN NextPM BETWEEN DATEADD(DAY, 8, CAST(GETDATE() AS DATE)) AND DATEADD(DAY, 30, CAST(GETDATE() AS DATE)) THEN 'Due This Month'
                                ELSE 'Due Soon'
                            END AS PMStatus,
                            NextPM AS NextPMDate,
                            ISNULL(PMResponsible, 'Unassigned') AS PMResponsible
                        FROM Asset_Inventory
                        WHERE IsActive = 1 
                        AND RequiredPM = 1
                        AND NextPM <= DATEADD(DAY, 30, CAST(GETDATE() AS DATE))
                        
                        UNION ALL
                        
                        SELECT 
                            EatonID AS EquipmentEatonID,
                            FixtureModelNoName AS EquipmentName,
                            Location,
                            CASE 
                                WHEN NextPM < CAST(GETDATE() AS DATE) THEN 'Overdue'
                                WHEN NextPM BETWEEN CAST(GETDATE() AS DATE) AND DATEADD(DAY, 7, CAST(GETDATE() AS DATE)) THEN 'Due This Week'
                                WHEN NextPM BETWEEN DATEADD(DAY, 8, CAST(GETDATE() AS DATE)) AND DATEADD(DAY, 30, CAST(GETDATE() AS DATE)) THEN 'Due This Month'
                                ELSE 'Due Soon'
                            END AS PMStatus,
                            NextPM AS NextPMDate,
                            ISNULL(PMResponsible, 'Unassigned') AS PMResponsible
                        FROM Fixture_Inventory
                        WHERE IsActive = 1 
                        AND RequiredPM = 1
                        AND NextPM <= DATEADD(DAY, 30, CAST(GETDATE() AS DATE))
                        
                        UNION ALL
                        
                        SELECT 
                            EatonID AS EquipmentEatonID,
                            HarnessModelNo AS EquipmentName,
                            Location,
                            CASE 
                                WHEN NextPM < CAST(GETDATE() AS DATE) THEN 'Overdue'
                                WHEN NextPM BETWEEN CAST(GETDATE() AS DATE) AND DATEADD(DAY, 7, CAST(GETDATE() AS DATE)) THEN 'Due This Week'
                                WHEN NextPM BETWEEN DATEADD(DAY, 8, CAST(GETDATE() AS DATE)) AND DATEADD(DAY, 30, CAST(GETDATE() AS DATE)) THEN 'Due This Month'
                                ELSE 'Due Soon'
                            END AS PMStatus,
                            NextPM AS NextPMDate,
                            ISNULL(PMResponsible, 'Unassigned') AS PMResponsible
                        FROM Harness_Inventory
                        WHERE IsActive = 1 
                        AND RequiredPM = 1
                        AND NextPM <= DATEADD(DAY, 30, CAST(GETDATE() AS DATE))
                    ) AS AllEquipment
                    ORDER BY 
                        CASE WHEN NextPMDate < CAST(GETDATE() AS DATE) THEN 0 ELSE 1 END,
                        NextPMDate ASC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    gvUpcomingPMs.DataSource = dt;
                    gvUpcomingPMs.DataBind();
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("LoadUpcomingPMs Error: " + ex.Message);
        }
    }

    private void LoadRecentCompletions()
    {
        try
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                
                string query = @"
                    SELECT TOP 20
                        PMLogID,
                        ISNULL(EquipmentEatonID, 'N/A') AS EquipmentEatonID,
                        ISNULL(EquipmentName, 'Unknown') AS EquipmentName,
                        'N/A' AS Location,
                        ISNULL(PMDate, GETDATE()) AS PMDate,
                        ISNULL(ActualDuration, 0) AS ActualDuration,
                        ISNULL(Cost, 0) AS Cost,
                        ISNULL(IsOnTime, 0) AS IsOnTime,
                        ISNULL(PerformedBy, 'Unknown') AS PMBy,
                        NextPMDate
                    FROM PM_Log
                    WHERE PMDate IS NOT NULL
                    ORDER BY PMDate DESC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    gvRecentPMs.DataSource = dt;
                    gvRecentPMs.DataBind();
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("LoadRecentCompletions Error: " + ex.Message);
        }
    }

    protected void btnViewDetails_Click(object sender, EventArgs e)
    {
        try
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                
                // Try to get the most recent PM log (prioritizing completed PMs with dates, then by ID)
                string query = "SELECT TOP 1 PMLogID FROM dbo.PM_Log ORDER BY PMDate DESC, PMLogID DESC";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    object result = cmd.ExecuteScalar();

                    if (result != null && result != DBNull.Value)
                    {
                        int pmLogID = Convert.ToInt32(result);
                        System.Diagnostics.Debug.WriteLine("PMDashboard - View Details: Redirecting to PMLogID = " + pmLogID);
                        Response.Redirect(string.Format("PMDetails.aspx?id={0}", pmLogID), false);
                        Context.ApplicationInstance.CompleteRequest();
                        return;
                    }
                }
                
                // If no PM logs exist at all, redirect to new mode
                System.Diagnostics.Debug.WriteLine("PMDashboard - View Details: No PM logs found, redirecting to new mode");
                Response.Redirect("PMDetails.aspx?mode=new", false);
                Context.ApplicationInstance.CompleteRequest();
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("PMDashboard - btnViewDetails_Click Error: " + ex.Message);
            System.Diagnostics.Debug.WriteLine("Stack Trace: " + ex.StackTrace);
            
            // On error, redirect to PM Dashboard page without crashing
            Response.Redirect("PMDashboard.aspx", false);
            Context.ApplicationInstance.CompleteRequest();
        }
    }

    // Helper methods for repeater formatting
    protected string GetDateClass(object nextPMDate)
    {
        if (nextPMDate == null || nextPMDate == DBNull.Value)
            return "future";

        DateTime date = Convert.ToDateTime(nextPMDate);
        int daysUntil = (date - DateTime.Now).Days;

        if (daysUntil < 0)
            return "soon"; // overdue
        else if (daysUntil <= 14)
            return "soon"; // due very soon
        else if (daysUntil <= 30)
            return "upcoming"; // due within a month
        else
            return "future"; // due later
    }

    protected string GetOnTimeClass(object isOnTime)
    {
        if (isOnTime == null || isOnTime == DBNull.Value)
            return "";

        bool onTime = Convert.ToBoolean(isOnTime);
        return onTime ? "on" : "";
    }

    protected string FormatDuration(object duration)
    {
        if (duration == null || duration == DBNull.Value)
            return "--";

        decimal minutes = Convert.ToDecimal(duration);
        if (minutes >= 60)
        {
            double hours = Convert.ToDouble(minutes) / 60.0;
            return hours.ToString("0.0") + "h";
        }
        else
        {
            return Math.Round(minutes, 0).ToString() + "m";
        }
    }

    protected string FormatCost(object cost)
    {
        if (cost == null || cost == DBNull.Value)
            return "$--";

        decimal amount = Convert.ToDecimal(cost);
        if (amount == 0)
            return "$--";

        return "$" + amount.ToString("N2");
    }

    protected void gvUpcomingPMs_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            DataRowView rowView = e.Row.DataItem as DataRowView;
            if (rowView != null)
            {
                string equipmentId = rowView["EquipmentEatonID"] != null ? rowView["EquipmentEatonID"].ToString() : "";
                string equipmentName = rowView["EquipmentName"] != null ? rowView["EquipmentName"].ToString() : "";
                
                e.Row.Attributes["data-equipment-id"] = equipmentId;
                e.Row.Attributes["data-equipment-name"] = equipmentName;
            }
        }
    }

    protected void gvRecentPMs_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            DataRowView rowView = e.Row.DataItem as DataRowView;
            if (rowView != null)
            {
                string pmLogId = rowView["PMLogID"] != null ? rowView["PMLogID"].ToString() : "";
                
                e.Row.Attributes["data-pmlog-id"] = pmLogId;
            }
        }
    }
}
