using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Linq;

public partial class TED_Admin_ManageProductionLines : Page
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
            BindLines();
        }
        var header = FindControl("AdminHeader1");
        if (header != null)
        {
            var prop = header.GetType().GetProperty("Title");
            if (prop != null) prop.SetValue(header, "Production Line Database", null);
        }
        var sidebar = FindControl("AdminSidebar1");
        if (sidebar != null)
        {
            var prop = sidebar.GetType().GetProperty("Active");
            if (prop != null) prop.SetValue(sidebar, "prodlines", null);
        }
    }

    protected void txtSearch_TextChanged(object sender, EventArgs e)
    {
        PageIndex = 0;
        BindLines();
    }

    protected void ddlSort_SelectedIndexChanged(object sender, EventArgs e)
    {
        PageIndex = 0;
        BindLines();
    }

    protected void ddlPlantFilter_SelectedIndexChanged(object sender, EventArgs e)
    {
        PageIndex = 0;
        BindLines();
    }

    protected void ddlPageSize_SelectedIndexChanged(object sender, EventArgs e)
    {
        PageIndex = 0;
        BindLines();
    }

    protected void btnPrev_Click(object sender, EventArgs e)
    {
        if (PageIndex > 0) PageIndex--;
        BindLines();
    }

    protected void btnNext_Click(object sender, EventArgs e)
    {
        PageIndex++;
        BindLines();
    }

    protected void rptLines_ItemCommand(object source, RepeaterCommandEventArgs e)
    {
        var lineId = e.CommandArgument.ToString();
        
        if (e.CommandName == "Save")
        {
            SaveLine(lineId);
        }
        else if (e.CommandName == "Delete")
        {
            DeleteLine(lineId);
        }
        
        BindLines();
    }

    private void BindLines()
    {
        var searchTerm = txtSearch.Text.Trim();
        var sortBy = ddlSort.SelectedValue;
        var plantFilter = ddlPlantFilter.SelectedValue;
        var pageSize = int.Parse(ddlPageSize.SelectedValue);

        var connStr = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
        using (var conn = new SqlConnection(connStr))
        {
            var sql = @"SELECT ProductionLineID, ProductionLineName, Plant, CurrentSupervisor, 
                        CreatedDate, CreatedBy, IsActive 
                        FROM dbo.ProductionLine 
                        WHERE (@search = '' OR ProductionLineName LIKE '%' + @search + '%' OR Plant LIKE '%' + @search + '%' OR CurrentSupervisor LIKE '%' + @search + '%')
                        AND (@plantFilter = '' OR Plant = @plantFilter)";

            if (sortBy == "name")
                sql += " ORDER BY ProductionLineName";
            else if (sortBy == "created")
                sql += " ORDER BY CreatedDate DESC";
            else if (sortBy == "id_asc")
                sql += " ORDER BY ProductionLineID ASC";
            else if (sortBy == "id_desc")
                sql += " ORDER BY ProductionLineID DESC";
            else
                sql += " ORDER BY ProductionLineID DESC";

            sql += " OFFSET @offset ROWS FETCH NEXT @pageSize ROWS ONLY";

            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@search", searchTerm);
                cmd.Parameters.AddWithValue("@plantFilter", plantFilter);
                cmd.Parameters.AddWithValue("@offset", PageIndex * pageSize);
                cmd.Parameters.AddWithValue("@pageSize", pageSize);

                conn.Open();
                var dt = new DataTable();
                using (var adapter = new SqlDataAdapter(cmd))
                {
                    adapter.Fill(dt);
                }

                rptLines.DataSource = dt;
                rptLines.DataBind();

                // Update pagination label
                var totalRecords = GetTotalRecords(searchTerm, plantFilter);
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

    private int GetTotalRecords(string searchTerm, string plantFilter)
    {
        var connStr = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
        using (var conn = new SqlConnection(connStr))
        {
            var sql = @"SELECT COUNT(*) FROM dbo.ProductionLine 
                        WHERE (@search = '' OR ProductionLineName LIKE '%' + @search + '%' OR Plant LIKE '%' + @search + '%' OR CurrentSupervisor LIKE '%' + @search + '%')
                        AND (@plantFilter = '' OR Plant = @plantFilter)";
            
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@search", searchTerm);
                cmd.Parameters.AddWithValue("@plantFilter", plantFilter);
                conn.Open();
                return (int)cmd.ExecuteScalar();
            }
        }
    }

    private void SaveLine(string lineId)
    {
        var lineName = Request.Form["lineName_" + lineId];
        var plant = Request.Form["plant_" + lineId];
        var supervisor = Request.Form["supervisor_" + lineId];

        if (string.IsNullOrEmpty(lineName))
        {
            return;
        }

        var connStr = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
        using (var conn = new SqlConnection(connStr))
        {
            var sql = @"UPDATE dbo.ProductionLine 
                        SET ProductionLineName = @name, Plant = @plant, CurrentSupervisor = @supervisor 
                        WHERE ProductionLineID = @id";
            
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@id", lineId);
                cmd.Parameters.AddWithValue("@name", lineName);
                cmd.Parameters.AddWithValue("@plant", string.IsNullOrEmpty(plant) ? (object)DBNull.Value : plant);
                cmd.Parameters.AddWithValue("@supervisor", string.IsNullOrEmpty(supervisor) ? (object)DBNull.Value : supervisor);
                
                conn.Open();
                cmd.ExecuteNonQuery();
            }
        }
    }

    private void DeleteLine(string lineId)
    {
        var connStr = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
        using (var conn = new SqlConnection(connStr))
        {
            var sql = "DELETE FROM dbo.ProductionLine WHERE ProductionLineID = @id";
            
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@id", lineId);
                conn.Open();
                cmd.ExecuteNonQuery();
            }
        }
    }

    protected DataTable GetSupervisors()
    {
        var connStr = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
        using (var conn = new SqlConnection(connStr))
        {
            var sql = "SELECT DISTINCT Email FROM dbo.Users WHERE IsActive = 1 ORDER BY Email";
            
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

    protected DataTable GetPlants()
    {
        var connStr = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
        using (var conn = new SqlConnection(connStr))
        {
            var sql = "SELECT Plant FROM dbo.Plant WHERE IsActive = 1 ORDER BY Plant";
            
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
}
