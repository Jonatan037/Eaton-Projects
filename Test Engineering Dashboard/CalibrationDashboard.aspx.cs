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
using System.Web.Services;

public partial class TED_CalibrationDashboard : Page
{
    private string connStr = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
    
    // KPI card properties
    public int CompletedCalsCount { get; set; }
    public string MonthlyCalData { get; set; }
    public string MonthlyCalLabels { get; set; }
    public int DueCals { get; set; }
    public int OverdueCals { get; set; }
    public string OnTimeRate { get; set; }
    public string OOTRate { get; set; }
    public string TurnaroundData { get; set; }
    public string TurnaroundCalIDs { get; set; }
    public decimal AvgTurnaroundValue { get; set; }
    
    // Sankey data
    public string SankeyData { get; set; }
    
    // Latest Calibration ID for View Details button
    public int LatestCalibrationID { get; set; }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadSidebarUser();
            LoadKPIs();
            LoadSankeyData();
            LoadUpcomingCalibrations();
            LoadRecentLogs();
            LoadLatestCalibrationID();
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

    private void LoadKPIs()
    {
        try
        {
            var serializer = new JavaScriptSerializer();
            
            using (var conn = new SqlConnection(connStr))
            {
                conn.Open();
                
                // Get Due/Overdue counts from Equipment_RequireCalibration view
                string dueQuery = @"
                    SELECT 
                        SUM(CASE WHEN NextCalibration < CAST(GETDATE() AS DATE) THEN 1 ELSE 0 END) AS OverdueCount,
                        SUM(CASE WHEN NextCalibration BETWEEN CAST(GETDATE() AS DATE) AND DATEADD(DAY, 30, CAST(GETDATE() AS DATE)) THEN 1 ELSE 0 END) AS DueNext30Days
                    FROM dbo.vw_Equipment_RequireCalibration
                    WHERE IsActive = 1";
                
                using (SqlCommand cmd = new SqlCommand(dueQuery, conn))
                {
                    SqlDataReader rdr = cmd.ExecuteReader();
                    if (rdr.Read())
                    {
                        int overdue = rdr["OverdueCount"] != DBNull.Value ? Convert.ToInt32(rdr["OverdueCount"]) : 0;
                        int dueSoon = rdr["DueNext30Days"] != DBNull.Value ? Convert.ToInt32(rdr["DueNext30Days"]) : 0;
                        
                        OverdueCals = overdue;
                        DueCals = overdue + dueSoon;
                        
                        if (litDueCals != null) litDueCals.Text = DueCals.ToString();
                        
                        // Apply red color and bold to entire footer text when overdue > 0
                        if (litOverdueText != null)
                        {
                            if (overdue > 0)
                                litOverdueText.Text = string.Format("<span style='color: #ef4444; font-weight: bold;'>{0} overdue</span>", overdue);
                            else
                                litOverdueText.Text = "None overdue";
                        }
                    }
                    rdr.Close();
                }
                
                // Get calibration metrics from Calibration_Log (all records for testing)
                string metricsQuery = @"
                    SELECT 
                        COUNT(*) AS TotalCalibrations,
                        SUM(CASE WHEN IsOnTime = 1 THEN 1 ELSE 0 END) AS OnTimeCount,
                        CAST(ISNULL((SUM(CASE WHEN IsOnTime = 1 THEN 1 ELSE 0 END) * 100.0) / NULLIF(COUNT(*), 0), 0) AS DECIMAL(5,1)) AS OnTimeRatePercent,
                        SUM(CASE WHEN IsOutOfTolerance = 1 THEN 1 ELSE 0 END) AS OOTCount,
                        CAST(ISNULL((SUM(CASE WHEN IsOutOfTolerance = 1 THEN 1 ELSE 0 END) * 100.0) / NULLIF(COUNT(*), 0), 0) AS DECIMAL(5,1)) AS OOTRatePercent,
                        ISNULL(AVG(CASE 
                            WHEN Method = 'External'
                                 AND SentOutDate IS NOT NULL AND ReceivedDate IS NOT NULL
                            THEN DATEDIFF(DAY, SentOutDate, ReceivedDate)
                            ELSE NULL 
                        END), 0) AS AvgTurnaroundDays
                    FROM dbo.Calibration_Log
                    WHERE CalibrationDate IS NOT NULL";
                
                using (SqlCommand cmd = new SqlCommand(metricsQuery, conn))
                {
                    SqlDataReader rdr = cmd.ExecuteReader();
                    if (rdr.Read())
                    {
                        int totalCals = Convert.ToInt32(rdr["TotalCalibrations"]);
                        
                        // Only update if we have data
                        if (totalCals > 0)
                        {
                            int onTimeCount = Convert.ToInt32(rdr["OnTimeCount"]);
                            decimal onTimeRate = Convert.ToDecimal(rdr["OnTimeRatePercent"]);
                            int ootCount = Convert.ToInt32(rdr["OOTCount"]);
                            decimal ootRate = Convert.ToDecimal(rdr["OOTRatePercent"]);
                            decimal avgTurnaround = Convert.ToDecimal(rdr["AvgTurnaroundDays"]);
                            
                            // On-Time Rate
                            OnTimeRate = onTimeRate.ToString("0.0");
                            if (litOnTimeRate != null) litOnTimeRate.Text = onTimeRate.ToString("0.0") + "%";
                            if (litOnTimeCount != null) litOnTimeCount.Text = onTimeCount + " of " + totalCals;
                            
                            // Out of Tolerance Rate
                            OOTRate = ootRate.ToString("0.0");
                            if (litOOTRate != null) litOOTRate.Text = ootRate.ToString("0.0") + "%";
                            if (litOOTCount != null) litOOTCount.Text = ootCount + " of " + totalCals;
                            
                            // Average Turnaround
                            AvgTurnaroundValue = avgTurnaround;
                            if (litAvgTurnaround != null)
                            {
                                if (avgTurnaround > 0)
                                    litAvgTurnaround.Text = avgTurnaround.ToString("0.0");
                                else
                                    litAvgTurnaround.Text = "--";
                            }
                        }
                        else
                        {
                            // No data - set defaults
                            OnTimeRate = "0.0";
                            OOTRate = "0.0";
                            AvgTurnaroundValue = 0;
                            if (litOnTimeRate != null) litOnTimeRate.Text = "--";
                            if (litOnTimeCount != null) litOnTimeCount.Text = "0 of 0";
                            if (litOOTRate != null) litOOTRate.Text = "--";
                            if (litOOTCount != null) litOOTCount.Text = "0 of 0";
                            if (litAvgTurnaround != null) litAvgTurnaround.Text = "--";
                        }
                    }
                    else
                    {
                        // No records returned - set defaults
                        OnTimeRate = "0.0";
                        OOTRate = "0.0";
                        AvgTurnaroundValue = 0;
                        if (litOnTimeRate != null) litOnTimeRate.Text = "--";
                        if (litOnTimeCount != null) litOnTimeCount.Text = "0 of 0";
                        if (litOOTRate != null) litOOTRate.Text = "--";
                        if (litOOTCount != null) litOOTCount.Text = "0 of 0";
                        if (litAvgTurnaround != null) litAvgTurnaround.Text = "--";
                    }
                    rdr.Close();
                }
                
                // Load monthly calibration volume data (all records for testing)
                string monthlyQuery = @"
                    SELECT 
                        FORMAT(CalibrationDate, 'MMM yyyy') as MonthLabel,
                        COUNT(*) as CalCount
                    FROM dbo.Calibration_Log
                    WHERE CalibrationDate IS NOT NULL
                    GROUP BY YEAR(CalibrationDate), MONTH(CalibrationDate), FORMAT(CalibrationDate, 'MMM yyyy')
                    ORDER BY YEAR(CalibrationDate), MONTH(CalibrationDate)";
                
                using (SqlCommand cmd = new SqlCommand(monthlyQuery, conn))
                {
                    SqlDataReader rdr = cmd.ExecuteReader();
                    var monthlyLabels = new List<string>();
                    var monthlyData = new List<int>();
                    while (rdr.Read())
                    {
                        monthlyLabels.Add(rdr["MonthLabel"].ToString());
                        monthlyData.Add(Convert.ToInt32(rdr["CalCount"]));
                    }
                    rdr.Close();
                    
                    CompletedCalsCount = monthlyData.Sum();
                    MonthlyCalData = serializer.Serialize(monthlyData);
                    MonthlyCalLabels = serializer.Serialize(monthlyLabels);
                    if (litCompletedCals != null) litCompletedCals.Text = CompletedCalsCount.ToString();
                }
                
                // Load last 10 external calibration turnaround times (SentOutDate to ReceivedDate)
                string turnaroundQuery = @"
                    SELECT TOP 10 
                        CalibrationLogID,
                        DATEDIFF(DAY, SentOutDate, ReceivedDate) as TurnaroundDays
                    FROM dbo.Calibration_Log
                    WHERE Method = 'External'
                          AND SentOutDate IS NOT NULL AND ReceivedDate IS NOT NULL
                    ORDER BY CalibrationDate DESC";
                
                using (SqlCommand cmd = new SqlCommand(turnaroundQuery, conn))
                {
                    SqlDataReader rdr = cmd.ExecuteReader();
                    var turnaroundData = new List<int>();
                    var turnaroundCalIDs = new List<string>();
                    while (rdr.Read())
                    {
                        // Get CalibrationLogID as string (works for int, long, or varchar)
                        string calID = rdr.IsDBNull(0) ? "0" : rdr.GetValue(0).ToString();
                        turnaroundCalIDs.Add(calID);
                        
                        // TurnaroundDays should always be int from DATEDIFF
                        turnaroundData.Add(rdr.IsDBNull(1) ? 0 : rdr.GetInt32(1));
                        
                        System.Diagnostics.Debug.WriteLine("Found CalID: " + calID + ", TurnaroundDays: " + turnaroundData[turnaroundData.Count - 1]);
                    }
                    rdr.Close();
                    
                    System.Diagnostics.Debug.WriteLine("Turnaround Query returned " + turnaroundData.Count + " rows");
                    ClientScript.RegisterStartupScript(this.GetType(), "TurnaroundDebug", 
                        "console.log('C# Turnaround Query Results: " + turnaroundData.Count + " rows');", true);
                    
                    if (turnaroundData.Count == 0) {
                        turnaroundData.Add(0);
                        turnaroundCalIDs.Add("0");
                    }
                    turnaroundData.Reverse();
                    turnaroundCalIDs.Reverse();
                    TurnaroundData = serializer.Serialize(turnaroundData);
                    TurnaroundCalIDs = serializer.Serialize(turnaroundCalIDs);
                }
            }
        }
        catch (Exception ex)
        {
            string errorMsg = ex.Message.Replace("'", "\\'").Replace("\r", " ").Replace("\n", " ");
            System.Diagnostics.Debug.WriteLine("LoadKPIs Error: " + ex.Message);
            System.Diagnostics.Debug.WriteLine("LoadKPIs StackTrace: " + ex.StackTrace);
            
            // Log error to browser console
            ClientScript.RegisterStartupScript(this.GetType(), "LoadKPIsError", 
                "console.error('LoadKPIs Error: " + errorMsg + "');", true);
            
            MonthlyCalData = "[]";
            MonthlyCalLabels = "[]";
            TurnaroundData = "[]";
            
            // Set default values for KPIs
            OnTimeRate = "0.0";
            OOTRate = "0.0";
            AvgTurnaroundValue = 0;
            if (litOnTimeRate != null) litOnTimeRate.Text = "ERR";
            if (litOnTimeCount != null) litOnTimeCount.Text = "Error loading";
            if (litOOTRate != null) litOOTRate.Text = "ERR";
            if (litOOTCount != null) litOOTCount.Text = "ERR";
            if (litAvgTurnaround != null) litAvgTurnaround.Text = "ERR";
            if (litCompletedCals != null) litCompletedCals.Text = "ERR";
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
                var sankeyQuery = "SELECT SourceNode, TargetNode, Value FROM vw_Calibration_SankeyData WHERE Value > 0";
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
    
    private void LoadLatestCalibrationID()
    {
        try
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                
                // Query for the CalibrationID column (integer primary key)
                string query = "SELECT TOP 1 CalibrationID FROM dbo.Calibration_Log ORDER BY CalibrationDate DESC, CalibrationID DESC";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    object result = cmd.ExecuteScalar();
                    
                    if (result != null && result != DBNull.Value)
                    {
                        LatestCalibrationID = Convert.ToInt32(result);
                        System.Diagnostics.Debug.WriteLine("LoadLatestCalibrationID - Found CalibrationID: " + LatestCalibrationID);
                    }
                    else
                    {
                        LatestCalibrationID = 0;
                        System.Diagnostics.Debug.WriteLine("LoadLatestCalibrationID - No records found");
                    }
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("LoadLatestCalibrationID Error: " + ex.Message);
            LatestCalibrationID = 0;
        }
    }

    private void LoadUpcomingCalibrations()
    {
        try
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                
                // Query equipment requiring calibration (next 30 days)
                string query = @"
                    SELECT TOP 20
                        EatonID AS EquipmentEatonID,
                        EquipmentName,
                        Location,
                        LastCalibration,
                        CASE 
                            WHEN NextCalibration < CAST(GETDATE() AS DATE) THEN 'Overdue'
                            WHEN NextCalibration BETWEEN CAST(GETDATE() AS DATE) AND DATEADD(DAY, 7, CAST(GETDATE() AS DATE)) THEN 'Due This Week'
                            WHEN NextCalibration BETWEEN DATEADD(DAY, 8, CAST(GETDATE() AS DATE)) AND DATEADD(DAY, 30, CAST(GETDATE() AS DATE)) THEN 'Due This Month'
                            ELSE 'Due Soon'
                        END AS CalibrationStatus,
                        NextCalibration
                    FROM vw_Equipment_RequireCalibration
                    WHERE IsActive = 1
                    AND NextCalibration <= DATEADD(DAY, 30, CAST(GETDATE() AS DATE))
                    ORDER BY 
                        CASE WHEN NextCalibration < CAST(GETDATE() AS DATE) THEN 0 ELSE 1 END,
                        NextCalibration ASC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    gvUpcomingCals.DataSource = dt;
                    gvUpcomingCals.DataBind();
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("LoadUpcomingCalibrations Error: " + ex.Message);
        }
    }

    private void LoadRecentLogs()
    {
        try
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                
                string query = @"
                    SELECT TOP 20
                        CalibrationID,
                        CalibrationLogID,
                        ISNULL(EquipmentName, 'Unknown') AS EquipmentName,
                        ISNULL(Method, 'N/A') AS Method,
                        ISNULL(CalibrationDate, GETDATE()) AS CalibrationDate,
                        ISNULL(CalibrationBy, 'Unknown') AS CalibrationBy,
                        ISNULL(ResultCode, 'N/A') AS ResultCode,
                        ISNULL(Cost, 0) AS Cost,
                        ISNULL(IsOnTime, 0) AS IsOnTime,
                        ISNULL(IsOutOfTolerance, 0) AS IsOutOfTolerance
                    FROM dbo.Calibration_Log
                    WHERE CalibrationDate IS NOT NULL
                    ORDER BY CalibrationDate DESC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    gvRecentLogs.DataSource = dt;
                    gvRecentLogs.DataBind();
                }
            }
        }
        catch (Exception ex)
        {
            string errorMsg = ex.Message.Replace("'", "\\'").Replace("\r", " ").Replace("\n", " ");
            System.Diagnostics.Debug.WriteLine("LoadRecentLogs Error: " + ex.Message);
            System.Diagnostics.Debug.WriteLine("LoadRecentLogs StackTrace: " + ex.StackTrace);
            
            // Log error to browser console
            ClientScript.RegisterStartupScript(this.GetType(), "LoadRecentLogsError", 
                "console.error('LoadRecentLogs Error: " + errorMsg + "');", true);
            
            // Show empty table with error message
            if (gvRecentLogs != null)
            {
                gvRecentLogs.DataSource = null;
                gvRecentLogs.DataBind();
            }
        }
    }

    protected void gvUpcomingCals_RowDataBound(object sender, GridViewRowEventArgs e)
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

    protected void gvRecentLogs_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            DataRowView rowView = e.Row.DataItem as DataRowView;
            if (rowView != null)
            {
                string calId = rowView["CalibrationID"] != null ? rowView["CalibrationID"].ToString() : "";
                
                e.Row.Attributes["data-cal-id"] = calId;
            }
        }
    }

    protected void btnViewDetails_Click(object sender, EventArgs e)
    {
        try
        {
            // Log to console for debugging
            ClientScript.RegisterStartupScript(this.GetType(), "ViewDetailsLog", 
                "console.log('btnViewDetails_Click triggered in code-behind');", true);
            
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                
                // Try to get the most recent calibration log
                string query = "SELECT TOP 1 CalibrationLogID FROM dbo.Calibration_Log ORDER BY CalibrationDate DESC, CalibrationLogID DESC";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    object result = cmd.ExecuteScalar();

                    if (result != null && result != DBNull.Value)
                    {
                        int calLogID = Convert.ToInt32(result);
                        System.Diagnostics.Debug.WriteLine("Redirecting to CalibrationDetails.aspx?id=" + calLogID);
                        Response.Redirect(string.Format("CalibrationDetails.aspx?id={0}", calLogID), false);
                        Context.ApplicationInstance.CompleteRequest();
                        return;
                    }
                }
                
                // If no calibration logs exist, redirect to new mode
                System.Diagnostics.Debug.WriteLine("No calibration logs found, redirecting to new mode");
                Response.Redirect("CalibrationDetails.aspx?mode=new", false);
                Context.ApplicationInstance.CompleteRequest();
            }
        }
        catch (Exception ex)
        {
            string errorMsg = ex.Message.Replace("'", "\\'").Replace("\r", " ").Replace("\n", " ");
            System.Diagnostics.Debug.WriteLine("btnViewDetails_Click Error: " + ex.Message);
            ClientScript.RegisterStartupScript(this.GetType(), "ViewDetailsError", 
                "console.error('btnViewDetails_Click Error: " + errorMsg + "');", true);
            Response.Redirect("CalibrationDashboard.aspx", false);
            Context.ApplicationInstance.CompleteRequest();
        }
    }

    protected string GetResultClass(object resultObj)
    {
        try
        {
            if (resultObj == null || resultObj == DBNull.Value)
                return "other";
            
            string result = resultObj.ToString().ToUpper();
            
            if (result == "PASS" || result == "PASS/IN TOL")
                return "pass";
            else if (result == "OOT" || result.Contains("OUT OF TOL"))
                return "oot";
            else
                return "other";
        }
        catch
        {
            return "other";
        }
    }

    protected string GetStatusClass(object statusObj)
    {
        try
        {
            if (statusObj == null || statusObj == DBNull.Value)
                return "pending";
            
            string status = statusObj.ToString().ToLower();
            
            if (status == "completed" || status == "complete")
                return "completed";
            else if (status == "cancelled" || status == "canceled")
                return "cancelled";
            else
                return "pending";
        }
        catch
        {
            return "pending";
        }
    }

    protected string GetOnTimeClass(object onTimeObj)
    {
        try
        {
            if (onTimeObj == null || onTimeObj == DBNull.Value)
                return "";
            
            bool isOnTime = Convert.ToBoolean(onTimeObj);
            return isOnTime ? "on" : "";
        }
        catch
        {
            return "";
        }
    }
    
    [WebMethod]
    public static int GetLatestCalibrationID()
    {
        try
        {
            string connStr = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
            
            System.Diagnostics.Debug.WriteLine("GetLatestCalibrationID - Starting query");
            
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                System.Diagnostics.Debug.WriteLine("GetLatestCalibrationID - Connection opened");
                
                string query = "SELECT TOP 1 CalibrationLogID FROM dbo.Calibration_Log ORDER BY CalibrationDate DESC, CalibrationLogID DESC";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    object result = cmd.ExecuteScalar();
                    
                    System.Diagnostics.Debug.WriteLine("GetLatestCalibrationID - Query result: " + (result ?? "NULL"));
                    
                    if (result != null && result != DBNull.Value)
                    {
                        int calId = Convert.ToInt32(result);
                        System.Diagnostics.Debug.WriteLine("GetLatestCalibrationID - Returning ID: " + calId);
                        return calId;
                    }
                }
            }
            
            System.Diagnostics.Debug.WriteLine("GetLatestCalibrationID - No records found, returning 0");
            return 0; // No calibration logs found
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("GetLatestCalibrationID Error: " + ex.Message);
            System.Diagnostics.Debug.WriteLine("GetLatestCalibrationID StackTrace: " + ex.StackTrace);
            return -1; // Return -1 to indicate error vs no records
        }
    }
}
