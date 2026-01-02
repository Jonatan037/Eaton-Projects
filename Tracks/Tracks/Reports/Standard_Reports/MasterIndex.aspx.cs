using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using System.Data;
using System.Configuration;
using System.Data.SqlClient;


public partial class NCRs_Standard_Reports_MasterIndex : System.Web.UI.Page
{
    string constr = ConfigurationManager.ConnectionStrings["NCRConnectionString"].ConnectionString;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            txtStartDate.Text = DateTime.Now.ToShortDateString();
            txtEndDate.Text = DateTime.Now.ToShortDateString();
        }
    }


    private string GetQueryString()
    {
        string sql;

        string date_range = " CAST(MASTER_INDEX.[FIRST_DATE] AS Date) BETWEEN '" + txtStartDate.Text.ToString() + "' AND '" + txtEndDate.Text.ToString() + "' ";

        sql = "SELECT * FROM MASTER_INDEX WHERE " + date_range + " ORDER BY SERIAL_NUMBER";

        return sql;

    }

    private string SortDirection
    {
        get { return ViewState["SortDirection"] != null ? ViewState["SortDirection"].ToString() : "ASC"; }
        set { ViewState["SortDirection"] = value; }
    }



    private void BindGrid(string sortExpression = null)
    {
        if (!IsValidDate(txtStartDate.Text)) return;
        if (!IsValidDate(txtEndDate.Text)) return;

        string sql = GetQueryString();

        using (SqlConnection con = new SqlConnection(constr))
        {
            using (SqlCommand cmd = new SqlCommand(sql))
            {
                using (SqlDataAdapter sda = new SqlDataAdapter())
                {
                    cmd.Connection = con;
                    sda.SelectCommand = cmd;

                    using (DataTable dt = new DataTable())
                    {
                        sda.Fill(dt);

                        if (sortExpression != null)
                        {
                            DataView dv = dt.AsDataView();

                            this.SortDirection = this.SortDirection == "ASC" ? "DESC" : "ASC";

                            dv.Sort = sortExpression + " " + this.SortDirection;

                            gvMasterIndex.DataSource = dv;
                        }
                        else
                        {
                            gvMasterIndex.DataSource = dt;
                        }

                        gvMasterIndex.DataBind();
                    }
                }
            }
        }
    }




    protected void btnFind_Click(object sender, EventArgs e)
    {
        BindGrid();
    }

    public bool IsValidDate(string date)
    {

        DateTime result;    // Contains the parsed value of the string.
        bool valid_date;    // Validity state.

        // Verify that the string is formatted as a date.
        valid_date = DateTime.TryParse(date, out result);

        // Return false if the string was not a properly formatted date.
        if (!valid_date)
        {
            ClientScript.RegisterStartupScript(this.GetType(), "alert", "alert('Both dates must be in mm/dd/yyyy format.');", true);
            return false;
        }

        // Valid date.
        return true;
    }



    protected void gvMasterIndex_PageIndexChanging1(object sender, GridViewPageEventArgs e)
    {
        gvMasterIndex.PageIndex = e.NewPageIndex;

        BindGrid();
    }

    protected void gvMasterIndex_Sorting(object sender, GridViewSortEventArgs e)
    {
            BindGrid(e.SortExpression);
    }


    protected void btnDownload_Click(object sender, EventArgs e)
    {
        if (!IsValidDate(txtStartDate.Text)) return;
        if (!IsValidDate(txtEndDate.Text)) return;

        SqlConnection conn = new SqlConnection(constr);
        DataTable dt = new DataTable();

        string sql = GetQueryString();

        SqlDataAdapter sda = new SqlDataAdapter(sql, conn);

        sda.Fill(dt);

        string attach = "attachment;filename=master_index.xls";
        Response.ClearContent();
        Response.AddHeader("content-disposition", attach);
        Response.ContentType = "application/ms-excel";

        if (dt != null)
        {
            foreach (DataColumn dc in dt.Columns)
            {
                Response.Write(dc.ColumnName + "\t");
                //sep = ";";
            }
            Response.Write(System.Environment.NewLine);
            foreach (DataRow dr in dt.Rows)
            {
                for (int i = 0; i < dt.Columns.Count; i++)
                {
                    Response.Write(dr[i].ToString() + "\t");
                }
                Response.Write("\n");
            }
            Response.End();
        }
    }
}