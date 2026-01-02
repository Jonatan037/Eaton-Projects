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


public partial class Tracks_Protected_IssueReports_Create : System.Web.UI.Page
{
    DbAccess db = new DbAccess();
    DataTable dt = new DataTable();

    // The page to be called for editing.
    string edit_page = "Edit_IssueReports.aspx";

    enum Views
    {
        dvMasterIndex,
        gvIssueReports
    }
    protected void Page_Load(object sender, EventArgs e)
    {
        
        ucSearch.SerialNumberFound += new EventHandler(DataBind);

        if (!IsPostBack)
        {
            ShowPanels(false);

            if (Session[DbAccess.SessionVariableName.SERIAL_NUMBER.ToString()] != null)
            {   
                string serial_number = Session[DbAccess.SessionVariableName.SERIAL_NUMBER.ToString()].ToString();

                BindData();
            }
        }

    }


    private void ShowPanels(bool Show)
    {
        Panel2.Visible = Show;
        Panel3.Visible = Show;
    }

    private DataTable GetViewData(Views view)
    {
        string sql = "";
        string master_index_id = "0";

        if (dvMasterIndex.DataKey.Value != null)
            master_index_id = dvMasterIndex.DataKey.Value.ToString();


        // Determine the sql based on the fview.
        if (view == Views.dvMasterIndex)
        {
            sql = "SELECT * FROM [MASTER_INDEX] WHERE  [SERIAL_NUMBER] = '" + ucSearch.SerialNumber + "'";
        }
        else if (view == Views.gvIssueReports)
        {
            sql = "SELECT * FROM [ISSUE_REPORTS] WHERE  [MASTER_INDEX_ID] = " + master_index_id + " ORDER BY CREATION_TIMESTAMP";
        }
        else
        {
            sql = "";
        }

        return db.GetData(sql);

    }


    protected void DataBind(object sender, EventArgs e)
    {

        BindData();
    }

    protected void BindData()
    {
        if (ucSearch.SerialNumber == "")
        {
            lblTitle.Text = "No serial number selected";
            ShowPanels(false);
        }

        // -----------------------------------------------------------------------------------------
        dt = GetViewData(Views.dvMasterIndex);
        dvMasterIndex.DataSource = dt;
        dvMasterIndex.DataBind();

        if (dt.Rows.Count > 0)
        {
            ShowPanels(true);
            lblTitle.Text = "Showing data for serial number = " + ucSearch.SerialNumber;
        }


        // -----------------------------------------------------------------------------------------
        dt = GetViewData(Views.gvIssueReports);
        gvIssueReports.DataSource = dt;
        gvIssueReports.DataBind();

    }




    protected void btnNewIssueReport_Click(object sender, EventArgs e)
    {
        IssueReports ir = new IssueReports();

        string master_index_id = "0";
        int reports_id = 0;

        if (dvMasterIndex.DataKey.Value != null)
        {
            master_index_id = dvMasterIndex.DataKey.Value.ToString();

            //reports_id = tcr.Add(master_index_id, User.Identity.Name.ToUpper() );
            reports_id = ir.Add(master_index_id, User.Identity.Name.ToUpper());

            if (reports_id == 0)
                lblDebug.Text = ir.ErrorMessage;

            Session[DbAccess.SessionVariableName.ISSUE_REPORT_ID.ToString()] = reports_id;

            Response.Redirect(edit_page);

        }
    }



    protected void OnSelectedIndexChanged(object sender, EventArgs e)
    {

        string issue_reports_id;

        issue_reports_id = gvIssueReports.SelectedDataKey.Value.ToString();

        Session[DbAccess.SessionVariableName.ISSUE_REPORT_ID.ToString()] = issue_reports_id;

        Response.Redirect(edit_page);

        //lblDebug.Text = " Issue id = " + issue_reports_id;

    }

}