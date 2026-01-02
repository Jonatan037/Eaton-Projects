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


public partial class Tracks_Reports_Standard_Reports_ShowFailedComponentsByDateRange : System.Web.UI.Page
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

        string date_range = " CAST(ISSUE_REPORTS.CREATION_TIMESTAMP AS Date) BETWEEN '" + txtStartDate.Text.ToString() + "' AND '" + txtEndDate.Text.ToString() + "' ";


        sql = "SELECT " +
                  "MASTER_INDEX.PLANT, " +
                  "MASTER_INDEX.FAMILY AS [UNIT_FAMILY], " +
                  "MASTER_INDEX.CATEGORY AS [UNIT_CATEGORY], " +
                  "MASTER_INDEX.SERIAL_NUMBER AS [UNIT_SERIAL_NUMBER], " +
                  "MASTER_INDEX.PART_NUMBER AS [UNIT_PART_NUMBER], " +
                  "ISSUE_REPORTS.CREATION_TIMESTAMP AS [ISSUE_DATE], " +
                  "ISSUE_REPORTS.EMPLOYEE_ID, " +
                  "ISSUE_REPORTS.STATION_TYPE, " +
                  "ISSUE_REPORTS.ROOT_CAUSE_CODE, " +
                  "ISSUE_REPORTS_CT_NONCONFORMANCE_CODE.DESCRIPTION AS [NC_CODE], " +
                  "ISSUE_REPORTS_CT_NONCONFORMANCE_CODE.CATEGORY AS [NC_CATEGORY], " +
                  "COMPONENTS.PART_NUMBER AS [COMPONENT_PART_NUMBER], " +
                  "COMPONENTS.SERIAL_NUMBER AS [COMPONENT_SERIAL_NUMBER], " +
                  "COMPONENTS.COST AS [COMPONENT_COST], " +
                  "COMPONENTS.REPLACEMENT_REASON_TYPE, " +
                  "COMPONENTS.DISPOSITION_TYPE, " +
                  "PART_NUMBERS.CATEGORY AS [COMPONENT_CATEGORY], " +
                  "PART_NUMBERS.MATERIAL_TYPE AS [COMPONENT_MATERIAL_TYPE], " +
                  "PART_NUMBERS.DESCRIPTION AS [COMPONENT_DESCRIPTION] " +
              "FROM " +
                  "(ISSUE_REPORTS_CT_NONCONFORMANCE_CODE INNER JOIN ((MASTER_INDEX INNER JOIN ISSUE_REPORTS ON MASTER_INDEX.MASTER_INDEX_ID = ISSUE_REPORTS.MASTER_INDEX_ID) INNER JOIN COMPONENTS ON ISSUE_REPORTS.ISSUE_REPORTS_ID = COMPONENTS.ISSUE_REPORTS_ID) ON ISSUE_REPORTS_CT_NONCONFORMANCE_CODE.DESCRIPTION = ISSUE_REPORTS.NONCONFORMANCE_CODE) LEFT JOIN PART_NUMBERS ON COMPONENTS.PART_NUMBER = PART_NUMBERS.PART_NUMBER " +
              "WHERE " + date_range + " " +
              "ORDER BY MASTER_INDEX.PLANT, MASTER_INDEX.FAMILY, MASTER_INDEX.CATEGORY, MASTER_INDEX.SERIAL_NUMBER, ISSUE_REPORTS.CREATION_TIMESTAMP";


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
        gvIssues.DataSource = dt;
        gvIssues.DataBind();

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

        t.CreateExcelFile("component_failures", ref dt);

    }
}