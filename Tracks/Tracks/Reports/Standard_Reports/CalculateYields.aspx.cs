using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;


using System.Data;
using System.Configuration;
using System.Data.SqlClient;

using Tracks.DAL;

public partial class NCRs_Standard_Reports_CalculateYields : System.Web.UI.Page
{
    //string constr = ConfigurationManager.ConnectionStrings["NCRConnectionString"].ConnectionString;

    // GridView cell indexes.
    int Plant_Index = 1;
    int Family_Index = 2;
    int Category_Index = 3;

    string URL = "Support/Support_YieldDetails.aspx";

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            txtStartDate.Text = DateTime.Now.ToShortDateString();
            txtEndDate.Text = DateTime.Now.ToShortDateString();
        }
    }

    private void GetYields()
    {
        DbAccess db = new DbAccess();
        DataTable dt = new DataTable();
        string sql;

        string date_range = " CAST(MASTER_INDEX.[FIRST_TEST_DATE] AS Date) BETWEEN '" + txtStartDate.Text.ToString() + "' AND '" + txtEndDate.Text.ToString() + "' ";

        // --------------------------------------------------------------------------------------------------------------------------
        sql = "SELECT " +
                  "MASTER_INDEX.PLANT, " +
                  "Count(MASTER_INDEX.FAILED) AS Total, " +
                  "Count(MASTER_INDEX.FAILED) - Sum(Abs(MASTER_INDEX.FAILED)) AS Passed, " +
                  "Sum(Abs(MASTER_INDEX.FAILED)) AS Failed, " +
                  "FORMAT( 1 - ( Sum(Abs(MASTER_INDEX.FAILED)) / Count(MASTER_INDEX.FAILED) ), 'P' ) AS Yields " +
               "FROM MASTER_INDEX " +
               "WHERE " + date_range + " " +
               "GROUP BY MASTER_INDEX.PLANT " +
               "ORDER BY PLANT";


        dt = db.GetData(sql);
        gvYieldsPlant.DataSource = dt;
        gvYieldsPlant.DataBind();

        // --------------------------------------------------------------------------------------------------------------------------
        sql = "SELECT " +
                  "MASTER_INDEX.PLANT, " +
                  "MASTER_INDEX.FAMILY, " +
                  "Count(MASTER_INDEX.FAILED) AS Total, " +
                  "Count(MASTER_INDEX.FAILED) - Sum(Abs(MASTER_INDEX.FAILED)) AS Passed, " +
                  "Sum(Abs(MASTER_INDEX.FAILED)) AS Failed, " +
                  "FORMAT( 1 - ( Sum(Abs(MASTER_INDEX.FAILED)) / Count(MASTER_INDEX.FAILED) ), 'P' ) AS Yields " +
               "FROM MASTER_INDEX " +
               "WHERE " + date_range + " " +
               "GROUP BY MASTER_INDEX.PLANT, MASTER_INDEX.FAMILY " +
               "ORDER BY PLANT, FAMILY";


        dt = db.GetData(sql);
        gvYieldsFamily.DataSource = dt;
        gvYieldsFamily.DataBind();

        // --------------------------------------------------------------------------------------------------------------------------
        sql = "SELECT " +
                  "MASTER_INDEX.PLANT, " +
                  "MASTER_INDEX.FAMILY, " +
                  "MASTER_INDEX.CATEGORY, " +
                  "Count(MASTER_INDEX.FAILED) AS Total, " +
                  "Count(MASTER_INDEX.FAILED) - Sum(Abs(MASTER_INDEX.FAILED)) AS Passed, " +
                  "Sum(Abs(MASTER_INDEX.FAILED)) AS Failed, " +
                  "FORMAT( 1 - ( Sum(Abs(MASTER_INDEX.FAILED)) / Count(MASTER_INDEX.FAILED) ), 'P' ) AS Yields " +
               "FROM MASTER_INDEX " +
               "WHERE " + date_range + "  " +
               "GROUP BY MASTER_INDEX.PLANT, MASTER_INDEX.FAMILY, MASTER_INDEX.CATEGORY " +
               "ORDER BY PLANT, FAMILY, CATEGORY";


        dt = db.GetData(sql);
        gvYieldsCategory.DataSource = dt;
        gvYieldsCategory.DataBind();

    }


    protected void btnFind_Click(object sender, EventArgs e)
    {
        if (!IsValidDate(txtStartDate.Text)) return;
        if (!IsValidDate(txtEndDate.Text)) return;

        GetYields();
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


    protected void btnDownload_Click(object sender, EventArgs e)
    {
        if (!IsValidDate(txtStartDate.Text)) return;
        if (!IsValidDate(txtEndDate.Text)) return;

        DbAccess db = new DbAccess();
        DataTable dt;

        string sql;

        string date_range = " CAST(MASTER_INDEX.[FIRST_TEST_DATE] AS Date) BETWEEN '" + txtStartDate.Text.ToString() + "' AND '" + txtEndDate.Text.ToString() + "' ";

        sql = "SELECT * FROM MASTER_INDEX WHERE " + date_range + " ORDER BY SERIAL_NUMBER";

        dt = db.GetData(sql);


        string attach = "attachment;filename=master_index.xls";
        Response.ClearContent();
        Response.AddHeader("content-disposition", attach);
        Response.ContentType = "application/ms-excel";

        if (dt != null)
        {
            foreach (DataColumn dc in dt.Columns)
            {
                Response.Write(dc.ColumnName + "\t");
            }

            Response.Write(System.Environment.NewLine);

            foreach (DataRow dr in dt.Rows)
            {
                for (int i = 0; i < dt.Columns.Count; i++)
                {
                    Response.Write(dr[i].ToString() + "\t");
                }

                Response.Write(System.Environment.NewLine);
            }
            Response.End();
        }
    }

    private string GetDates()
    {
        return URL + "?StartDate='" + txtStartDate.Text + "'&EndDate='" + txtEndDate.Text + "'";
    }

    protected void gvYieldsPlant_SelectedIndexChanged(object sender, EventArgs e)
    {
        string Plant;
        string NewURL;

        // Get the currently selected row using the SelectedRow property.
        GridViewRow row = gvYieldsPlant.SelectedRow;

        // Get the name of the plant.
        Plant = row.Cells[Plant_Index].Text;

        // Create new url with parameters.
        NewURL = GetDates() + "&Plant=" + Plant;

        // Go to page to show results.
        Response.Redirect(NewURL);

    }



    protected void gvYieldsFamily_SelectedIndexChanged(object sender, EventArgs e)
    {
        string Plant;
        string Family;
        string NewURL;

        // Get the currently selected row using the SelectedRow property.
        GridViewRow row = gvYieldsFamily.SelectedRow;

        // Get the name of the plant.
        Plant = row.Cells[Plant_Index].Text;

        // Get the name of the family
        Family = row.Cells[Family_Index].Text;

        // Create new url with parameters.
        NewURL = GetDates() + "&Plant=" + Plant + "&Family=" + Family;

        // Go to page to show results.
        Response.Redirect(NewURL);
    }

    protected void gvYieldsCategory_SelectedIndexChanged(object sender, EventArgs e)
    {
        string Plant;
        string Family;
        string Category;
        string NewURL;

        // Get the currently selected row using the SelectedRow property.
        GridViewRow row = gvYieldsCategory.SelectedRow;

        // Get the name of the plant.
        Plant = row.Cells[Plant_Index].Text;

        // Get the name of the family
        Family = row.Cells[Family_Index].Text;

        // Get the name of the category
        Category = row.Cells[Category_Index].Text;

        // Create new url with parameters.
        NewURL = GetDates() + "&Plant=" + Plant + "&Family=" + Family + "&Category=" + Category;

        // Go to page to show results.
        Response.Redirect(NewURL);
    }


}