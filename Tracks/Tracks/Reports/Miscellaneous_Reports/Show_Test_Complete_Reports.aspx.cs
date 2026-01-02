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

public partial class Tracks_Reports_Miscellaneous_Reports_Show_Test_Complete_Reports : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            txtStartDate.Text = DateTime.Now.ToShortDateString();
            txtEndDate.Text = DateTime.Now.ToShortDateString();
        }
    }

    private string CreateSql()
    {
        string sql;
        string where = "WHERE ";


        string date_range = " (CAST(TEST_COMPLETE_REPORTS.CREATION_TIMESTAMP AS Date) BETWEEN '" + txtStartDate.Text.ToString() + "' AND '" + txtEndDate.Text.ToString() + "') ";

        where += date_range;



        sql = "SELECT Plant, Family, Category, TEST_COMPLETE_REPORTS.* FROM TEST_COMPLETE_REPORTS INNER JOIN MASTER_INDEX ON TEST_COMPLETE_REPORTS.MASTER_INDEX_ID =  MASTER_INDEX.MASTER_INDEX_ID " + where;


        //lblDebug.Text = sql;

        return sql;

    }
    protected void btnFind_Click(object sender, EventArgs e)
    {
        if (!IsValidDate(txtStartDate.Text)) return;
        if (!IsValidDate(txtEndDate.Text)) return;


        DbAccess db = new DbAccess();
        DataTable dt = new DataTable();
        string sql;

        sql = CreateSql();


        dt = db.GetData(sql);
        GridView1.DataSource = dt;
        GridView1.DataBind();

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
        DataTable dt = new DataTable();
        string sql;

        sql = CreateSql();


        dt = db.GetData(sql);

        Tools t = new Tools();
        t.CreateExcelFile("test_complete_reports.xls", ref dt);

    }
}