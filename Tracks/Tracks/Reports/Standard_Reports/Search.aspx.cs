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

public partial class Tracks_Reports_Standard_Reports_Search : System.Web.UI.Page
{
    DbAccess db = new DbAccess();
    DataTable dt = new DataTable();

    //string constr = ConfigurationManager.ConnectionStrings["NCRConnectionString"].ConnectionString;

    enum Views
    {
        gvMasterIndex,
        gvIssueReports,
        gvAllComponents,
        gvLaborHours,
        gvCorrectiveActions,
        gvTestCompleteReports,
        gvFiles
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            string serial_number = Session[DbAccess.SessionVariableName.SERIAL_NUMBER.ToString()] as string;

            if (serial_number != null)
            {
                txtSearch.Text = serial_number;
                BindData();
            }
            else
            {
                ShowPanels(false);
            }

            txtSearch.Focus();
        }
    }


    private DataTable GetViewData(Views view)
    {
        string sql = "";
        string master_index_id = "0";
        string criteria = "";


        if (gvMasterIndex.SelectedDataKey != null)
            master_index_id = gvMasterIndex.SelectedDataKey.Value.ToString();

        // Determine the sql based on the view.
        if (view == Views.gvMasterIndex)
        {
            criteria = " '" + txtSearch.Text + "%' ";

            sql = "SELECT * FROM [MASTER_INDEX] " +
                  "WHERE  " +
                     "[SERIAL_NUMBER] LIKE" + criteria  + 
                     "OR [PART_NUMBER] LIKE" + criteria  +
                     "OR [NOTES] LIKE" + criteria +
                     "OR [PRODUCTION_ORDER_NUMBER] LIKE" + criteria +
                     "OR [SALES_ORDER_NUMBER] LIKE" + criteria + 
                  " ORDER BY SERIAL_NUMBER";

            sql = "SELECT * FROM [MASTER_INDEX] " +
                  "WHERE  " +
                     "[SERIAL_NUMBER] LIKE" + criteria +
                     "OR [PART_NUMBER] LIKE" + criteria +
                     "OR [SUBCATEGORY] LIKE" + criteria +
                     "OR [PRODUCTION_ORDER_NUMBER] LIKE" + criteria +
                     "OR [SALES_ORDER_NUMBER] LIKE" + criteria +
                  " " +
                  "UNION " +
                  " " +
                  "SELECT [MASTER_INDEX].* " +
                  "FROM(MASTER_INDEX INNER JOIN ISSUE_REPORTS ON MASTER_INDEX.MASTER_INDEX_ID = ISSUE_REPORTS.MASTER_INDEX_ID) INNER JOIN COMPONENTS ON ISSUE_REPORTS.ISSUE_REPORTS_ID = COMPONENTS.ISSUE_REPORTS_ID " +
                  "WHERE  " +
                     "COMPONENTS.[SERIAL_NUMBER] LIKE" + criteria +
                     "OR COMPONENTS.[PART_NUMBER] LIKE" + criteria +
                  " " +
                  "ORDER BY MASTER_INDEX.SERIAL_NUMBER ";

        }
        else if (view == Views.gvIssueReports)
        {

            sql = "SELECT * FROM [ISSUE_REPORTS] WHERE  [MASTER_INDEX_ID] = " + master_index_id + " ORDER BY CREATION_TIMESTAMP";
            //sql = "SELECT 0 AS [MASTER_INDEX_ID]";
        }

        else if (view == Views.gvAllComponents)
        {
            sql = "SELECT MASTER_INDEX.MASTER_INDEX_ID, COMPONENTS.* " +
                    "FROM(MASTER_INDEX INNER JOIN ISSUE_REPORTS ON MASTER_INDEX.MASTER_INDEX_ID = ISSUE_REPORTS.MASTER_INDEX_ID) INNER JOIN COMPONENTS ON ISSUE_REPORTS.ISSUE_REPORTS_ID = COMPONENTS.ISSUE_REPORTS_ID " +
                    "WHERE MASTER_INDEX.MASTER_INDEX_ID = " + master_index_id + " ORDER BY PART_NUMBER";


        }
        else if (view == Views.gvLaborHours)
        {
            sql = "SELECT MASTER_INDEX.MASTER_INDEX_ID, LABOR_HOURS.*, (LABOR_HOURS * HOURLY_RATE) AS [LABOR_COST] " +
                    "FROM(MASTER_INDEX INNER JOIN ISSUE_REPORTS ON MASTER_INDEX.MASTER_INDEX_ID = ISSUE_REPORTS.MASTER_INDEX_ID) INNER JOIN LABOR_HOURS ON ISSUE_REPORTS.ISSUE_REPORTS_ID = LABOR_HOURS.ISSUE_REPORTS_ID " +
                    "WHERE MASTER_INDEX.MASTER_INDEX_ID = " + master_index_id;
        }
        else if (view == Views.gvCorrectiveActions)
        {
            sql = "SELECT MASTER_INDEX.MASTER_INDEX_ID, CORRECTIVE_ACTIONS.* " +
                    "FROM(MASTER_INDEX INNER JOIN ISSUE_REPORTS ON MASTER_INDEX.MASTER_INDEX_ID = ISSUE_REPORTS.MASTER_INDEX_ID) INNER JOIN CORRECTIVE_ACTIONS ON ISSUE_REPORTS.ISSUE_REPORTS_ID = CORRECTIVE_ACTIONS.ISSUE_REPORTS_ID " +
                    "WHERE MASTER_INDEX.MASTER_INDEX_ID = " + master_index_id;
        }
        else if (view == Views.gvTestCompleteReports)
        {
            sql = "SELECT * FROM [TEST_COMPLETE_REPORTS] WHERE [MASTER_INDEX_ID] = " + master_index_id + " ORDER BY CREATION_TIMESTAMP";
        }
        else if (view == Views.gvFiles)
        {
            FileStorage FS = new FileStorage();
            sql = FS.GetSQL(master_index_id);
        }
        else
        {
            sql = "";
        }

        //lblDebug.Text = form.ID.ToString() + ".DataKey = " + form.DataKey.Value.ToString();        
        lblDebug.Text = sql;

        return db.GetData(sql);

    }

    private void ShowPanels(bool Show)
    {
        Panel1.Visible = Show;
        Panel2.Visible = Show;
        Panel3.Visible = Show;
        Panel4.Visible = Show;
        Panel5.Visible = Show;
        Panel6.Visible = Show;
        Panel7.Visible = Show;

    }


    private void BindData()
    {
        txtSearch.Text = txtSearch.Text.Trim();
        txtSearch.Text = txtSearch.Text.ToUpper();

        // Exit if no value was entered for the serial number.
        if (txtSearch.Text == "")
        {
            lblTitle.Text = "No value selected";
            ShowPanels(false);
            return;
        }


        // -----------------------------------------------------------------------------------------
        dt = GetViewData(Views.gvMasterIndex);
        gvMasterIndex.DataSource = dt;
        gvMasterIndex.DataBind();

        if (dt.Rows.Count > 0)
        {
            //gvMasterIndex.SelectedIndex = 0;
            ShowPanels(true);
            lblTitle.Text = "Showing data for values beginning with: " + txtSearch.Text;

            if (gvMasterIndex.SelectedIndex == -1) gvMasterIndex.SelectedIndex = 0;
        }

        // Hide or unhide panel depending on data availability.
        //Panel1.Visible = (dt.Rows.Count > 0);

        // -----------------------------------------------------------------------------------------
        dt = GetViewData(Views.gvIssueReports);

        foreach (DataRow row in dt.Rows)
        {
            row["PROBLEM_DESCRIPTION"] = row["PROBLEM_DESCRIPTION"].ToString().Replace(System.Environment.NewLine, "<BR>");
            row["NOTES"] = row["NOTES"].ToString().Replace(System.Environment.NewLine, "<BR>");
            row["REWORK_INSTRUCTIONS"] = row["REWORK_INSTRUCTIONS"].ToString().Replace(System.Environment.NewLine, "<BR>");
        }

        gvIssueReports.DataSource = dt;
        gvIssueReports.DataBind();

        // Hide or unhide panel depending on data availability.
        //Panel2.Visible = (dt.Rows.Count > 0);

        // -----------------------------------------------------------------------------------------
        dt = GetViewData(Views.gvAllComponents);
        gvAllComponents.DataSource = dt;
        gvAllComponents.DataBind();

        // Hide or unhide panel depending on data availability.
        //Panel3.Visible = (dt.Rows.Count > 0);

        // -----------------------------------------------------------------------------------------
        dt = GetViewData(Views.gvLaborHours);
        gvLaborHours.DataSource = dt;
        gvLaborHours.DataBind();

        // Hide or unhide panel depending on data availability.
        //Panel4.Visible = (dt.Rows.Count > 0);

        // -----------------------------------------------------------------------------------------
        dt = GetViewData(Views.gvCorrectiveActions);
        gvCorrectiveActions.DataSource = dt;
        gvCorrectiveActions.DataBind();

        // Hide or unhide panel depending on data availability.
        //Panel5.Visible = (dt.Rows.Count > 0);

        // -----------------------------------------------------------------------------------------
        dt = GetViewData(Views.gvTestCompleteReports);
        gvTestCompleteReports.DataSource = dt;
        gvTestCompleteReports.DataBind();

        // Hide or unhide panel depending on data availability.
        //Panel6.Visible = (dt.Rows.Count > 0);

        // -----------------------------------------------------------------------------------------

        dt = GetViewData(Views.gvFiles);

        foreach (DataRow row in dt.Rows)
        {
            row["NOTES"] = row["NOTES"].ToString().Replace(System.Environment.NewLine, "<BR>");
        }

        gvFiles.DataSource = dt;
        gvFiles.DataBind();



    }

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        //Session[DbAccess.SessionVariableName.SERIAL_NUMBER.ToString()] = txtSearch.Text;

        BindData();
    }


    protected void gvMasterIndex_SelectedIndexChanged(object sender, EventArgs e)
    {
        BindData();
    }

    protected void gvIssueReports_SelectedIndexChanged(object sender, EventArgs e)
    {
        string report_id = "0";

        report_id = gvIssueReports.SelectedDataKey.Value.ToString();

        Session[DbAccess.SessionVariableName.ISSUE_REPORT_ID.ToString()] = report_id;

        Response.Redirect("Support/Support_IssueReportDetails.aspx");
    }

    protected void gvTestCompleteReports_SelectedIndexChanged(object sender, EventArgs e)
    {
        string report_id = "0";

        report_id = gvTestCompleteReports.SelectedDataKey.Value.ToString();

        Session[DbAccess.SessionVariableName.TEST_COMPLETE_REPORT_ID.ToString()] = report_id;

        Response.Redirect("Support/Support_TestCompleteReportDetails.aspx");

    }

    protected void btnPrint_Click(object sender, EventArgs e)
    {
        string master_index_id = "0";

        if (gvMasterIndex.SelectedDataKey == null) return;

        master_index_id = gvMasterIndex.SelectedDataKey.Value.ToString();

        Session[DbAccess.SessionVariableName.MASTER_INDEX_ID.ToString()] = master_index_id;

        Response.Redirect("~/Tracks/Print/PrintUnitReport.aspx");
    }



    protected void gvMasterIndex_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        gvMasterIndex.PageIndex = e.NewPageIndex;

        BindData();
    }



}