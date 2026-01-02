using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Linq;

public partial class TED_Admin_ManageSubLines : Page
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
            PopulateProductionLineFilter();
            BindSubLines();
        }
        var header = FindControl("AdminHeader1");
        if (header != null)
        {
            var prop = header.GetType().GetProperty("Title");
            if (prop != null) prop.SetValue(header, "Sub-Line / Cell Database", null);
        }
        var sidebar = FindControl("AdminSidebar1");
        if (sidebar != null)
        {
            var prop = sidebar.GetType().GetProperty("Active");
            if (prop != null) prop.SetValue(sidebar, "sublines", null);
        }
    }

    protected void txtSearch_TextChanged(object sender, EventArgs e)
    {
        PageIndex = 0;
        BindSubLines();
    }

    protected void ddlSort_SelectedIndexChanged(object sender, EventArgs e)
    {
        PageIndex = 0;
        BindSubLines();
    }

    protected void ddlProductionLineFilter_SelectedIndexChanged(object sender, EventArgs e)
    {
        PageIndex = 0;
        BindSubLines();
    }

    protected void ddlPageSize_SelectedIndexChanged(object sender, EventArgs e)
    {
        PageIndex = 0;
        BindSubLines();
    }

    protected void btnPrev_Click(object sender, EventArgs e)
    {
        if (PageIndex > 0) PageIndex--;
        BindSubLines();
    }

    protected void btnNext_Click(object sender, EventArgs e)
    {
        PageIndex++;
        BindSubLines();
    }

    protected void rptSubLines_ItemCommand(object source, RepeaterCommandEventArgs e)
    {
        var subLineId = e.CommandArgument.ToString();
        
        if (e.CommandName == "Save")
        {
            SaveSubLine(subLineId);
        }
        else if (e.CommandName == "Delete")
        {
            DeleteSubLine(subLineId);
        }
        
        BindSubLines();
    }

    private void BindSubLines()
    {
        var searchTerm = txtSearch.Text.Trim();
        var sortBy = ddlSort.SelectedValue;
        var productionLineFilter = ddlProductionLineFilter.SelectedValue;
        var pageSize = int.Parse(ddlPageSize.SelectedValue);

        var connStr = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
        using (var conn = new SqlConnection(connStr))
        {
            var sql = @"SELECT s.SubLineCellID, s.SubLineCellName, s.ProductionLineID, p.ProductionLineName,
                        s.Description, s.CreatedDate, s.CreatedBy, s.IsActive, s.SubLineCode 
                        FROM dbo.SubLine_Cell s
                        LEFT JOIN dbo.ProductionLine p ON s.ProductionLineID = p.ProductionLineID
                        WHERE (@search = '' OR s.SubLineCellName LIKE '%' + @search + '%' OR p.ProductionLineName LIKE '%' + @search + '%' OR s.Description LIKE '%' + @search + '%')
                        AND (@productionLineFilter = '' OR p.ProductionLineName = @productionLineFilter)";

            if (sortBy == "name")
                sql += " ORDER BY s.SubLineCellName";
            else if (sortBy == "created")
                sql += " ORDER BY s.CreatedDate DESC";
            else if (sortBy == "id_asc")
                sql += " ORDER BY s.SubLineCellID ASC";
            else if (sortBy == "id_desc")
                sql += " ORDER BY s.SubLineCellID DESC";
            else
                sql += " ORDER BY s.SubLineCellID DESC";

            sql += " OFFSET @offset ROWS FETCH NEXT @pageSize ROWS ONLY";

            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@search", searchTerm);
                cmd.Parameters.AddWithValue("@productionLineFilter", productionLineFilter);
                cmd.Parameters.AddWithValue("@offset", PageIndex * pageSize);
                cmd.Parameters.AddWithValue("@pageSize", pageSize);

                conn.Open();
                var dt = new DataTable();
                using (var adapter = new SqlDataAdapter(cmd))
                {
                    adapter.Fill(dt);
                }

                rptSubLines.DataSource = dt;
                rptSubLines.DataBind();

                // Update pagination label
                var totalRecords = GetTotalRecords(searchTerm, productionLineFilter);
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

    private int GetTotalRecords(string searchTerm, string productionLineFilter)
    {
        var connStr = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
        using (var conn = new SqlConnection(connStr))
        {
            var sql = @"SELECT COUNT(*) FROM dbo.SubLine_Cell s
                        LEFT JOIN dbo.ProductionLine p ON s.ProductionLineID = p.ProductionLineID
                        WHERE (@search = '' OR s.SubLineCellName LIKE '%' + @search + '%' OR p.ProductionLineName LIKE '%' + @search + '%' OR s.Description LIKE '%' + @search + '%')
                        AND (@productionLineFilter = '' OR p.ProductionLineName = @productionLineFilter)";
            
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@search", searchTerm);
                cmd.Parameters.AddWithValue("@productionLineFilter", productionLineFilter);
                conn.Open();
                return (int)cmd.ExecuteScalar();
            }
        }
    }

    private void SaveSubLine(string subLineId)
    {
        var subLineName = Request.Form["subLineName_" + subLineId];
        var prodLineId = Request.Form["prodLine_" + subLineId];
        var subLineCode = Request.Form["subLineCode_" + subLineId];
        var description = Request.Form["description_" + subLineId];

        if (string.IsNullOrEmpty(subLineName))
        {
            return;
        }

        var connStr = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
        using (var conn = new SqlConnection(connStr))
        {
            var sql = @"UPDATE dbo.SubLine_Cell 
                        SET SubLineCellName = @name, ProductionLineID = @prodLineId, SubLineCode = @subLineCode, Description = @desc 
                        WHERE SubLineCellID = @id";
            
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@id", subLineId);
                cmd.Parameters.AddWithValue("@name", subLineName);
                
                if (string.IsNullOrEmpty(prodLineId))
                    cmd.Parameters.AddWithValue("@prodLineId", DBNull.Value);
                else
                    cmd.Parameters.AddWithValue("@prodLineId", int.Parse(prodLineId));
                
                cmd.Parameters.AddWithValue("@subLineCode", string.IsNullOrEmpty(subLineCode) ? (object)DBNull.Value : subLineCode);
                cmd.Parameters.AddWithValue("@desc", string.IsNullOrEmpty(description) ? (object)DBNull.Value : description);
                
                conn.Open();
                cmd.ExecuteNonQuery();
            }
        }
    }

    private void DeleteSubLine(string subLineId)
    {
        var connStr = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
        using (var conn = new SqlConnection(connStr))
        {
            var sql = "DELETE FROM dbo.SubLine_Cell WHERE SubLineCellID = @id";
            
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@id", subLineId);
                conn.Open();
                cmd.ExecuteNonQuery();
            }
        }
    }

    protected DataTable GetProductionLines()
    {
        var connStr = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
        using (var conn = new SqlConnection(connStr))
        {
            var sql = "SELECT ProductionLineID, ProductionLineName FROM dbo.ProductionLine WHERE IsActive = 1 ORDER BY ProductionLineName";
            
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

    private void PopulateProductionLineFilter()
    {
        var connStr = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
        using (var conn = new SqlConnection(connStr))
        {
            var sql = "SELECT DISTINCT ProductionLineName FROM dbo.ProductionLine WHERE IsActive = 1 ORDER BY ProductionLineName";
            
            using (var cmd = new SqlCommand(sql, conn))
            {
                conn.Open();
                var dt = new DataTable();
                using (var adapter = new SqlDataAdapter(cmd))
                {
                    adapter.Fill(dt);
                }
                
                ddlProductionLineFilter.Items.Clear();
                ddlProductionLineFilter.Items.Add(new ListItem("All Production Lines", ""));
                foreach (DataRow row in dt.Rows)
                {
                    ddlProductionLineFilter.Items.Add(new ListItem(row["ProductionLineName"].ToString(), row["ProductionLineName"].ToString()));
                }
            }
        }
    }
}
