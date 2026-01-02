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

public partial class Tracks_Reports_Standard_Reports_ShowMasterIndexEntriesByDateRange : System.Web.UI.Page
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

        string date_range = " CAST(FIRST_TEST_DATE AS Date) BETWEEN '" + txtStartDate.Text.ToString() + "' AND '" + txtEndDate.Text.ToString() + "' ";


        sql = "SELECT *  " +

              "FROM " +
                  "MASTER_INDEX " +
              "WHERE " + date_range + " ORDER BY SERIAL_NUMBER";


        //lblDebug.Text = sql;

        return sql;

    }

    private void GetIssues()
    {
        DbAccess db = new DbAccess();
        DataTable dt = new DataTable();
        string sql;

        sql = CreateSql();
        //return;

        dt = db.GetData(sql);
        gvMasterIndex.DataSource = dt;
        gvMasterIndex.DataBind();

    }


    protected void btnFind_Click(object sender, EventArgs e)
    {
        if (!IsValidDate(txtStartDate.Text)) return;
        if (!IsValidDate(txtEndDate.Text)) return;

        GetIssues();
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

        t.CreateExcelFile("master_index_entries", ref dt);

    }
    protected void gvMasterIndex_SelectedIndexChanged(object sender, EventArgs e)
    {

        if (gvMasterIndex.SelectedDataKey.Value == null) return;

        Session[DbAccess.SessionVariableName.SERIAL_NUMBER.ToString()] = gvMasterIndex.SelectedDataKey.Value.ToString();

        Response.Redirect("Search");

    }
}