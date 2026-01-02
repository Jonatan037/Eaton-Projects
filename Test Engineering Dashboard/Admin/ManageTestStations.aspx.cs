using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Linq;

public partial class TED_Admin_ManageTestStations : Page
{
    private int PageIndex
    {
        get { return (int)(ViewState["PageIndex"] ?? 0); }
        set { ViewState["PageIndex"] = value; }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        // Admin-only gate
        var cat = (Session["TED:UserCategory"] as string ?? string.Empty).ToLowerInvariant();
        var role = (Session["TED:JobRole"] as string ?? string.Empty).ToLowerInvariant();
        if (!(cat.Contains("admin") || role.Contains("admin")))
        {
            Response.Redirect("~/UnauthorizedAccess.aspx");
            return;
        }
        if (!IsPostBack)
        {
            PopulateSubLineFilter();
            PopulateTestTypeFilter();
            BindStations();
        }
        var header = FindControl("AdminHeader1");
        if (header != null)
        {
            var prop = header.GetType().GetProperty("Title");
            if (prop != null) prop.SetValue(header, "Test Station / Bay Database", null);
        }
        var sidebar = FindControl("AdminSidebar1");
        if (sidebar != null)
        {
            var prop = sidebar.GetType().GetProperty("Active");
            if (prop != null) prop.SetValue(sidebar, "teststations", null);
        }
    }

    protected void txtSearch_TextChanged(object sender, EventArgs e)
    {
        PageIndex = 0;
        BindStations();
    }

    protected void ddlSort_SelectedIndexChanged(object sender, EventArgs e)
    {
        PageIndex = 0;
        BindStations();
    }

    protected void ddlSubLineFilter_SelectedIndexChanged(object sender, EventArgs e)
    {
        PageIndex = 0;
        BindStations();
    }

    protected void ddlTestTypeFilter_SelectedIndexChanged(object sender, EventArgs e)
    {
        PageIndex = 0;
        BindStations();
    }

    protected void ddlPageSize_SelectedIndexChanged(object sender, EventArgs e)
    {
        PageIndex = 0;
        BindStations();
    }

    protected void btnPrev_Click(object sender, EventArgs e)
    {
        if (PageIndex > 0) PageIndex--;
        BindStations();
    }

    protected void btnNext_Click(object sender, EventArgs e)
    {
        PageIndex++;
        BindStations();
    }

    protected void rptStations_ItemCommand(object source, RepeaterCommandEventArgs e)
    {
        var stationId = e.CommandArgument.ToString();
        
        if (e.CommandName == "Save")
        {
            SaveStation(stationId);
        }
        else if (e.CommandName == "Delete")
        {
            DeleteStation(stationId);
        }
        
        BindStations();
    }

    private void BindStations()
    {
        var searchTerm = txtSearch.Text.Trim();
        var sortBy = ddlSort.SelectedValue;
        var subLineFilter = ddlSubLineFilter.SelectedValue;
        var testTypeFilter = ddlTestTypeFilter.SelectedValue;
        var pageSize = int.Parse(ddlPageSize.SelectedValue);

        var connStr = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
        using (var conn = new SqlConnection(connStr))
        {
            var sql = @"SELECT t.TestStationID, t.TestStationName, t.SubLineCellID, s.SubLineCode,
                        t.StationSubLineCode, t.TestType, t.IsActive, t.CreatedDate, t.CreatedBy,
                        t.StationType, t.Capacity, t.CurrentUtilization, t.IsOperational, t.LastDowntime,
                        t.RequiresRedBadge, t.RedBadgeLevel, t.RequiresPreFlight
                        FROM dbo.TestStation_Bay t
                        LEFT JOIN dbo.SubLine_Cell s ON t.SubLineCellID = s.SubLineCellID
                        WHERE (@search = '' OR t.TestStationName LIKE '%' + @search + '%' OR s.SubLineCode LIKE '%' + @search + '%' OR t.TestType LIKE '%' + @search + '%')
                        AND (@subLineFilter = '' OR s.SubLineCode = @subLineFilter)
                        AND (@testTypeFilter = '' OR t.TestType = @testTypeFilter)";

            if (sortBy == "name")
                sql += " ORDER BY t.TestStationName";
            else if (sortBy == "created")
                sql += " ORDER BY t.CreatedDate DESC";
            else if (sortBy == "id_asc")
                sql += " ORDER BY t.TestStationID ASC";
            else if (sortBy == "id_desc")
                sql += " ORDER BY t.TestStationID DESC";
            else
                sql += " ORDER BY t.TestStationID DESC";

            sql += " OFFSET @offset ROWS FETCH NEXT @pageSize ROWS ONLY";

            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@search", searchTerm);
                cmd.Parameters.AddWithValue("@subLineFilter", subLineFilter);
                cmd.Parameters.AddWithValue("@testTypeFilter", testTypeFilter);
                cmd.Parameters.AddWithValue("@offset", PageIndex * pageSize);
                cmd.Parameters.AddWithValue("@pageSize", pageSize);

                conn.Open();
                var dt = new DataTable();
                using (var adapter = new SqlDataAdapter(cmd))
                {
                    adapter.Fill(dt);
                }

                rptStations.DataSource = dt;
                rptStations.DataBind();

                // Update pagination label
                var totalRecords = GetTotalRecords(searchTerm, subLineFilter, testTypeFilter);
                var startRecord = PageIndex * pageSize + 1;
                var endRecord = Math.Min((PageIndex + 1) * pageSize, totalRecords);
                lblPagination.Text = string.Format("Showing {0}-{1} of {2}", startRecord, endRecord, totalRecords);

                btnPrev.Enabled = PageIndex > 0;
                btnPrev.CssClass = PageIndex > 0 ? "pagination-btn" : "pagination-btn disabled";
                
                btnNext.Enabled = endRecord < totalRecords;
                btnNext.CssClass = endRecord < totalRecords ? "pagination-btn" : "pagination-btn disabled";
            }
        }
    }

    private int GetTotalRecords(string searchTerm, string subLineFilter, string testTypeFilter)
    {
        var connStr = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
        using (var conn = new SqlConnection(connStr))
        {
            var sql = @"SELECT COUNT(*) FROM dbo.TestStation_Bay t
                        LEFT JOIN dbo.SubLine_Cell s ON t.SubLineCellID = s.SubLineCellID
                        WHERE (@search = '' OR t.TestStationName LIKE '%' + @search + '%' OR s.SubLineCode LIKE '%' + @search + '%' OR t.TestType LIKE '%' + @search + '%')
                        AND (@subLineFilter = '' OR s.SubLineCode = @subLineFilter)
                        AND (@testTypeFilter = '' OR t.TestType = @testTypeFilter)";
            
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@search", searchTerm);
                cmd.Parameters.AddWithValue("@subLineFilter", subLineFilter);
                cmd.Parameters.AddWithValue("@testTypeFilter", testTypeFilter);
                conn.Open();
                return (int)cmd.ExecuteScalar();
            }
        }
    }

    private void SaveStation(string stationId)
    {
        var stationName = Request.Form["stationName_" + stationId];
        var subLineId = Request.Form["subLine_" + stationId];
        var testType = Request.Form["testType_" + stationId];
        var requiresBadge = Request.Form["requiresBadge_" + stationId] == "on";
        var badgeLevel = Request.Form["badgeLevel_" + stationId];
        var requiresPreFlight = Request.Form["requiresPreFlight_" + stationId] == "on";

        if (string.IsNullOrEmpty(stationName))
        {
            return;
        }

        var connStr = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
        using (var conn = new SqlConnection(connStr))
        {
            var sql = @"UPDATE dbo.TestStation_Bay 
                        SET TestStationName = @name, SubLineCellID = @subLineId, TestType = @testType,
                            RequiresRedBadge = @requiresBadge, RedBadgeLevel = @badgeLevel, RequiresPreFlight = @requiresPreFlight
                        WHERE TestStationID = @id";
            
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@id", stationId);
                cmd.Parameters.AddWithValue("@name", stationName);
                
                if (string.IsNullOrEmpty(subLineId))
                    cmd.Parameters.AddWithValue("@subLineId", DBNull.Value);
                else
                    cmd.Parameters.AddWithValue("@subLineId", int.Parse(subLineId));
                
                cmd.Parameters.AddWithValue("@testType", string.IsNullOrEmpty(testType) ? (object)DBNull.Value : testType);
                cmd.Parameters.AddWithValue("@requiresBadge", requiresBadge);
                cmd.Parameters.AddWithValue("@badgeLevel", string.IsNullOrEmpty(badgeLevel) ? (object)DBNull.Value : badgeLevel);
                cmd.Parameters.AddWithValue("@requiresPreFlight", requiresPreFlight);
                
                conn.Open();
                cmd.ExecuteNonQuery();
            }
        }
    }

    private void DeleteStation(string stationId)
    {
        var connStr = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
        using (var conn = new SqlConnection(connStr))
        {
            var sql = "DELETE FROM dbo.TestStation_Bay WHERE TestStationID = @id";
            
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@id", stationId);
                conn.Open();
                cmd.ExecuteNonQuery();
            }
        }
    }

    protected DataTable GetSubLines()
    {
        var connStr = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
        using (var conn = new SqlConnection(connStr))
        {
            var sql = "SELECT SubLineCellID, SubLineCellName, SubLineCode FROM dbo.SubLine_Cell WHERE IsActive = 1 ORDER BY SubLineCode";
            
            using (var cmd = new SqlCommand(sql, conn))
            {
                conn.Open();
                var dt = new DataTable();
                using (var adapter = new SqlDataAdapter(cmd))
                {
                    adapter.Fill(dt);
                }
                return dt;
            }
        }
    }

    protected DataTable GetStationTypes()
    {
        var connStr = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
        using (var conn = new SqlConnection(connStr))
        {
            var sql = "SELECT ID, StationType, Description FROM dbo.StationType ORDER BY StationType";
            
            using (var cmd = new SqlCommand(sql, conn))
            {
                conn.Open();
                var dt = new DataTable();
                using (var adapter = new SqlDataAdapter(cmd))
                {
                    adapter.Fill(dt);
                }
                return dt;
            }
        }
    }

    private void PopulateSubLineFilter()
    {
        var connStr = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
        using (var conn = new SqlConnection(connStr))
        {
            var sql = "SELECT DISTINCT SubLineCode FROM dbo.SubLine_Cell WHERE IsActive = 1 AND SubLineCode IS NOT NULL ORDER BY SubLineCode";
            
            using (var cmd = new SqlCommand(sql, conn))
            {
                conn.Open();
                var dt = new DataTable();
                using (var adapter = new SqlDataAdapter(cmd))
                {
                    adapter.Fill(dt);
                }
                
                ddlSubLineFilter.Items.Clear();
                ddlSubLineFilter.Items.Add(new ListItem("All Sub Lines", ""));
                foreach (DataRow row in dt.Rows)
                {
                    ddlSubLineFilter.Items.Add(new ListItem(row["SubLineCode"].ToString(), row["SubLineCode"].ToString()));
                }
            }
        }
    }

    private void PopulateTestTypeFilter()
    {
        var connStr = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
        using (var conn = new SqlConnection(connStr))
        {
            var sql = "SELECT DISTINCT StationType FROM dbo.StationType ORDER BY StationType";
            
            using (var cmd = new SqlCommand(sql, conn))
            {
                conn.Open();
                var dt = new DataTable();
                using (var adapter = new SqlDataAdapter(cmd))
                {
                    adapter.Fill(dt);
                }
                
                ddlTestTypeFilter.Items.Clear();
                ddlTestTypeFilter.Items.Add(new ListItem("All Test Types", ""));
                foreach (DataRow row in dt.Rows)
                {
                    ddlTestTypeFilter.Items.Add(new ListItem(row["StationType"].ToString(), row["StationType"].ToString()));
                }
            }
        }
    }
}
