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

public partial class Tracks_Reports_Standard_Reports_CONC_CONC : System.Web.UI.Page
{
    DbAccess DB = new DbAccess();
    
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            txtStartDate.Text = DateTime.Now.ToShortDateString();
            txtEndDate.Text = DateTime.Now.ToShortDateString();
        }
    }

    private string GetDateRange()
    {
        string date_range = " CAST(ISSUE_REPORTS.CREATION_TIMESTAMP AS Date) BETWEEN '" + txtStartDate.Text.ToString() + "' AND '" + txtEndDate.Text.ToString() + "' ";

        return date_range;

    }

    private void DataByPlant()
    {

        string sql = "SELECT MASTER_INDEX.PLANT, Sum(COMPONENTS.COST) AS [TOTAL_COST] " +
                     "FROM(MASTER_INDEX INNER JOIN ISSUE_REPORTS ON MASTER_INDEX.MASTER_INDEX_ID = ISSUE_REPORTS.MASTER_INDEX_ID) " +
                     "INNER JOIN COMPONENTS ON ISSUE_REPORTS.ISSUE_REPORTS_ID = COMPONENTS.ISSUE_REPORTS_ID " +
                     "WHERE " + GetDateRange() + " " +
                     "GROUP BY MASTER_INDEX.PLANT " +
                     "ORDER BY PLANT";

        gvPlant.DataSource = DB.GetData(sql);
        gvPlant.DataBind();
    }

    private void DataByFamily()
    {

        string sql = "SELECT MASTER_INDEX.PLANT, MASTER_INDEX.FAMILY, Sum(COMPONENTS.COST) AS [TOTAL_COST] " +
                     "FROM(MASTER_INDEX INNER JOIN ISSUE_REPORTS ON MASTER_INDEX.MASTER_INDEX_ID = ISSUE_REPORTS.MASTER_INDEX_ID) " +
                     "INNER JOIN COMPONENTS ON ISSUE_REPORTS.ISSUE_REPORTS_ID = COMPONENTS.ISSUE_REPORTS_ID " +
                     "WHERE " + GetDateRange() + " " +
                     "GROUP BY MASTER_INDEX.PLANT, MASTER_INDEX.FAMILY " +
                     "ORDER BY PLANT, FAMILY";

        gvFamily.DataSource = DB.GetData(sql);
        gvFamily.DataBind();
    }

    private void DataByCategory()
    {

        string sql = "SELECT MASTER_INDEX.PLANT, MASTER_INDEX.FAMILY, MASTER_INDEX.CATEGORY, Sum(COMPONENTS.COST) AS [TOTAL_COST] " +
                     "FROM(MASTER_INDEX INNER JOIN ISSUE_REPORTS ON MASTER_INDEX.MASTER_INDEX_ID = ISSUE_REPORTS.MASTER_INDEX_ID) " +
                     "INNER JOIN COMPONENTS ON ISSUE_REPORTS.ISSUE_REPORTS_ID = COMPONENTS.ISSUE_REPORTS_ID " +
                     "WHERE " + GetDateRange() + " " +
                     "GROUP BY MASTER_INDEX.PLANT, MASTER_INDEX.FAMILY,MASTER_INDEX.CATEGORY " +
                     "ORDER BY PLANT, FAMILY, CATEGORY";

        gvCategory.DataSource = DB.GetData(sql);
        gvCategory.DataBind();
    }

    private string GetDataDetailsSQL()
    {
        string sql = "";

        sql = "SELECT MASTER_INDEX.SERIAL_NUMBER AS [UUT_SN], MASTER_INDEX.PART_NUMBER AS [UUT_PN], MASTER_INDEX.COST AS [UUT_COST], PLANT, FAMILY, CATEGORY, ISSUE_REPORTS.EMPLOYEE_ID, COMPONENTS.* " +
              "FROM (MASTER_INDEX INNER JOIN ISSUE_REPORTS ON MASTER_INDEX.MASTER_INDEX_ID = ISSUE_REPORTS.MASTER_INDEX_ID) " +
              "INNER JOIN COMPONENTS ON ISSUE_REPORTS.ISSUE_REPORTS_ID = COMPONENTS.ISSUE_REPORTS_ID " +
              "WHERE " + GetDateRange() + " " +
              "ORDER BY MASTER_INDEX.SERIAL_NUMBER";


        return sql;
    }
    private void DataDetails()
    {
        gvDetails.DataSource = DB.GetData( GetDataDetailsSQL() );
        gvDetails.DataBind();
    }


    private void ComponentsMissingCost()
    {

        string sql = "SELECT COMPONENTS.PART_NUMBER, COMPONENTS.DESCRIPTION " +
                     "FROM(MASTER_INDEX INNER JOIN ISSUE_REPORTS ON MASTER_INDEX.MASTER_INDEX_ID = ISSUE_REPORTS.MASTER_INDEX_ID) " +
                     "INNER JOIN COMPONENTS ON ISSUE_REPORTS.ISSUE_REPORTS_ID = COMPONENTS.ISSUE_REPORTS_ID " +
                     "WHERE " + GetDateRange() + " AND COMPONENTS.COST = 0 " +
                     "GROUP BY COMPONENTS.PART_NUMBER, COMPONENTS.DESCRIPTION " +
                     "ORDER BY COMPONENTS.PART_NUMBER";

        gvMissingCosts.DataSource = DB.GetData(sql);
        gvMissingCosts.DataBind();
    }

    protected void btnFind_Click(object sender, EventArgs e)
    {
        if (!IsValidDate(txtStartDate.Text)) return;
        if (!IsValidDate(txtEndDate.Text)) return;

        DataByPlant();
        DataByFamily();
        DataByCategory();
        //DataDetails();
        ComponentsMissingCost();
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

        DataTable dt = DB.GetData(GetDataDetailsSQL());

        Tools t = new Tools();

        t.CreateExcelFile("CONC_Details", ref dt);

    }
}