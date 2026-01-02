using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Text;

public partial class TED_TestComputers : Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            // Initialize page size
            if (ddlPageSize != null)
            {
                try { ddlPageSize.SelectedValue = gridComputers.PageSize.ToString(); } catch { }
            }
            LoadKPIs();
            BindComputersGrid();
        }

        // Sync sidebar user info
        try
        {
            string fullName = Session["TED:FullName"] as string ?? "User";
            string role = Session["TED:JobRole"] as string ?? Session["TED:UserCategory"] as string ?? "";
            
            if (userFullName != null) userFullName.InnerText = fullName;
            if (userRole != null) userRole.InnerText = role;
            if (userAvatar != null) userAvatar.InnerText = GetInitials(fullName);

            // Show/hide admin portal link
            if (adminPortalLink != null)
            {
                var cat = (Session["TED:UserCategory"] as string ?? "").ToLowerInvariant();
                var jobRole = (Session["TED:JobRole"] as string ?? "").ToLowerInvariant();
                adminPortalLink.Style["display"] = (cat.Contains("admin") || jobRole.Contains("admin")) ? "" : "none";
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
            using (var cmd = new SqlCommand("SELECT * FROM dbo.vw_ComputerKPIs", conn))
            {
                conn.Open();
                using (var rdr = cmd.ExecuteReader())
                {
                    if (rdr.Read())
                    {
                        // Total Active Computers
                        int totalComputers = GetInt(rdr, "TotalActiveComputers");
                        if (litTotalComputers != null)
                            litTotalComputers.Text = totalComputers.ToString();

                        // In Use Count
                        int inUseCount = GetInt(rdr, "InUseCount");
                        if (litInUse != null)
                            litInUse.Text = inUseCount.ToString();

                        // Available Count
                        int availableCount = GetInt(rdr, "AvailableCount");
                        if (litAvailable != null)
                            litAvailable.Text = availableCount.ToString();
                        
                        // Status: Red if < 5, Amber if < 10, Green if >= 10
                        if (cardAvailable != null)
                            ApplyStatusClass(cardAvailable, availableCount, 5, 10, inverse: true);

                        // Open IT Tasks
                        int openITTasks = GetInt(rdr, "OpenITTasks");
                        int openTestEngTasks = GetInt(rdr, "OpenTestEngTasks");
                        int totalOpenTasks = openITTasks + openTestEngTasks;
                        
                        if (litOpenTasks != null)
                            litOpenTasks.Text = totalOpenTasks.ToString();
                        
                        // Status: Red if > 10, Amber if > 5, Green if <= 5
                        if (cardOpenTasks != null)
                            ApplyStatusClass(cardOpenTasks, totalOpenTasks, 10, 5, inverse: false);

                        // Average Age
                        decimal? avgAge = GetDecimal(rdr, "AvgAgeYears");
                        if (litAvgAge != null)
                            litAvgAge.Text = avgAge.HasValue ? avgAge.Value.ToString("0.0") + " yrs" : "--";
                        
                        // Status: Green if < 3 yrs, Amber if < 5 yrs, Red if >= 5 yrs
                        if (avgAge.HasValue && cardAvgAge != null)
                            ApplyStatusClass(cardAvgAge, avgAge.Value, 5, 3, inverse: false);
                    }
                    else
                    {
                        // No data returned from view - set all to defaults
                        if (litTotalComputers != null) litTotalComputers.Text = "0";
                        if (litInUse != null) litInUse.Text = "0";
                        if (litAvailable != null) litAvailable.Text = "0";
                        if (litOpenTasks != null) litOpenTasks.Text = "0";
                        if (litAvgAge != null) litAvgAge.Text = "--";
                    }
                }
            }
        }
        catch (Exception ex)
        {
            // Log error or show message
            System.Diagnostics.Debug.WriteLine("LoadKPIs error: " + ex.Message);
        }
    }

    private void ApplyStatusClass(HtmlControl card, decimal value, decimal redThreshold, decimal amberThreshold, bool inverse)
    {
        string statusClass = "status-green";
        if (inverse)
        {
            // Higher is better
            if (value >= amberThreshold)
                statusClass = "status-green";
            else if (value >= redThreshold)
                statusClass = "status-amber";
            else
                statusClass = "status-red";
        }
        else
        {
            // Lower is better
            if (value >= redThreshold)
                statusClass = "status-red";
            else if (value >= amberThreshold)
                statusClass = "status-amber";
            else
                statusClass = "status-green";
        }
        card.Attributes["class"] = "kpi-card " + statusClass;
    }

    private void BindComputersGrid()
    {
        try
        {
            var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
            string whereClause = BuildWhereClause();
            string orderByClause = BuildOrderByClause();

            string query = @"
                SELECT 
                    ComputerID,
                    ComputerName,
                    ComputerType,
                    CurrentStatus,
                    TestStationID,
                    Location,
                    HasOpenITTask,
                    HasOpenTestEngTask,
                    ComputerDate,
                    LastMaintenanceDate,
                    OSVersion,
                    PurchaseDate,
                    WarrantyExpiration
                FROM dbo.Computer_Inventory
                WHERE IsActive = 1 " + whereClause + " " + orderByClause;

            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand(query, conn))
            {
                conn.Open();
                using (var adapter = new SqlDataAdapter(cmd))
                {
                    var dt = new DataTable();
                    adapter.Fill(dt);
                    gridComputers.DataSource = dt;
                    gridComputers.DataBind();
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("BindComputersGrid error: " + ex.Message);
            // Set empty data source on error
            gridComputers.DataSource = new DataTable();
            gridComputers.DataBind();
        }
    }

    private string BuildWhereClause()
    {
        if (txtSearch == null || string.IsNullOrWhiteSpace(txtSearch.Text))
            return "";

        string searchTerm = txtSearch.Text.Trim().Replace("'", "''"); // Escape single quotes
        var sb = new StringBuilder();
        sb.Append("AND (");
        sb.AppendFormat("CAST(ComputerID AS nvarchar) LIKE '%{0}%' OR ", searchTerm);
        sb.AppendFormat("ComputerName LIKE '%{0}%' OR ", searchTerm);
        sb.AppendFormat("ComputerType LIKE '%{0}%' OR ", searchTerm);
        sb.AppendFormat("CurrentStatus LIKE '%{0}%' OR ", searchTerm);
        sb.AppendFormat("Location LIKE '%{0}%' OR ", searchTerm);
        sb.AppendFormat("OSVersion LIKE '%{0}%'", searchTerm);
        sb.Append(")");
        return sb.ToString();
    }

    private string BuildOrderByClause()
    {
        if (ddlSort == null || string.IsNullOrWhiteSpace(ddlSort.SelectedValue))
            return "ORDER BY ComputerName ASC";

        switch (ddlSort.SelectedValue.ToLowerInvariant())
        {
            case "name_desc":
                return "ORDER BY ComputerName DESC";
            case "type":
                return "ORDER BY ComputerType, ComputerName ASC";
            case "status":
                return "ORDER BY CurrentStatus, ComputerName ASC";
            case "age_desc":
                return "ORDER BY DATEDIFF(day, ComputerDate, GETDATE()) DESC";
            default:
                return "ORDER BY ComputerName ASC";
        }
    }

    private int GetInt(SqlDataReader rdr, string columnName)
    {
        try
        {
            int ordinal = rdr.GetOrdinal(columnName);
            if (rdr.IsDBNull(ordinal)) return 0;
            return rdr.GetInt32(ordinal);
        }
        catch { return 0; }
    }

    private decimal? GetDecimal(SqlDataReader rdr, string columnName)
    {
        try
        {
            int ordinal = rdr.GetOrdinal(columnName);
            if (rdr.IsDBNull(ordinal)) return null;
            return rdr.GetDecimal(ordinal);
        }
        catch { return null; }
    }

    // Event handlers
    protected void txtSearch_TextChanged(object sender, EventArgs e)
    {
        BindComputersGrid();
    }

    protected void ddlSort_SelectedIndexChanged(object sender, EventArgs e)
    {
        BindComputersGrid();
    }

    protected void ddlPageSize_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (ddlPageSize != null && gridComputers != null)
        {
            int pageSize = 25;
            if (int.TryParse(ddlPageSize.SelectedValue, out pageSize))
            {
                gridComputers.PageSize = pageSize;
                BindComputersGrid();
            }
        }
    }

    protected void gridComputers_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        if (gridComputers != null)
        {
            gridComputers.PageIndex = e.NewPageIndex;
            BindComputersGrid();
        }
    }
}
