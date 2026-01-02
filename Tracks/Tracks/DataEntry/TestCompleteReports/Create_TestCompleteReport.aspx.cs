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

public partial class Tracks_Protected_TestCompleteReports_Create : System.Web.UI.Page
{
    DbAccess db = new DbAccess();
    DataTable dt = new DataTable();

    // The page to be called for editing.
    string edit_page = "Edit_TestCompleteReport.aspx";

    enum Views
    {
        dvMasterIndex,
        gvReports
    }
    protected void Page_Load(object sender, EventArgs e)
    {

        ucSearch.SerialNumberFound += new EventHandler(DataBind);

        if (!IsPostBack)
        {
            ShowPanels(false);

            if (Session[DbAccess.SessionVariableName.SERIAL_NUMBER.ToString()] != null)
            { 
                string serial_number = Session[DbAccess.SessionVariableName.SERIAL_NUMBER.ToString()] as string;

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
        else if (view == Views.gvReports)
        {
            sql = "SELECT * FROM [TEST_COMPLETE_REPORTS] WHERE  [MASTER_INDEX_ID] = " + master_index_id + " ORDER BY CREATION_TIMESTAMP";
        }
        else
        {
            sql = "";
        }

        //lblDebug.Text = form.ID.ToString() + ".DataKey = " + form.DataKey.Value.ToString();        
        //lblDebug.Text = sql;

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


        dt = GetViewData(Views.dvMasterIndex);
        dvMasterIndex.DataSource = dt;
        dvMasterIndex.DataBind();

        // ----------------------------------------------------------------------------------------------------------------------------

        MasterIndex mi = new MasterIndex();
        bool last_test_status = mi.GetFlagBySerialNumber(ucSearch.SerialNumber, MasterIndex.FlagName.LAST_TEST_STATUS);
        bool requires_ate_record = mi.GetFlagBySerialNumber(ucSearch.SerialNumber, MasterIndex.FlagName.REQUIRES_ATE_RECORD);

        //string url = "http://youncwhp5013525/Production_Queries/ypo/show_empower_test_logs.asp?SearchCriteria=";
        //string url = "http://usyouwhp6140713/Production_Queries/ypo/show_empower_test_logs.asp?SearchCriteria=";
        //http://usra2whp6080193/Tracks/Tracks/Reports/DeviceHistory/Device_History
        string url = "http://usyouwhp6140713/Production_Queries/ypo/show_empower_test_logs.asp?SearchCriteria=";

        // Need to include link to device history page for this serial number.

        if (last_test_status == false && requires_ate_record == true)
        {
            Panel2.Visible = true;
            Panel3.Visible = false;

            lblTitle.Text = "Serial number = " + ucSearch.SerialNumber;

            lblDebug.Text = "Unable to create a test complete report for this unit.<br>This unit requires a passing production test record.";

            url += ucSearch.SerialNumber;

            HyperLink1.NavigateUrl = url;

            // Refresh automatically, time in seconds
            Response.AppendHeader("Refresh", "30");

            return;
        }

        lblDebug.Text = "";
        HyperLink1.Visible = false;

        // -----------------------------------------------------------------------------------------



        if (dt.Rows.Count > 0)
        {
            ShowPanels(true);
            lblTitle.Text = "Showing data for serial number = " + ucSearch.SerialNumber;
        }

        // -----------------------------------------------------------------------------------------
        dt = GetViewData(Views.gvReports);
        gvReports.DataSource = dt;
        gvReports.DataBind();


    }


    protected void btnNewReport_Click(object sender, EventArgs e)
    {
        //TestCompleteReports tcr = new TestCompleteReports();


        string master_index_id = "0";
        string reports_id = "0";

        if (dvMasterIndex.DataKey.Value != null)
        {
            master_index_id = dvMasterIndex.DataKey.Value.ToString();

            Session[ DbAccess.SessionVariableName.MASTER_INDEX_ID.ToString() ] = master_index_id;

            Session[ DbAccess.SessionVariableName.TEST_COMPLETE_REPORT_ID.ToString() ] = reports_id;

            Response.Redirect(edit_page);
        }
    }



    protected void OnSelectedIndexChanged(object sender, EventArgs e)
    {
        string master_index_id = "0";
        string reports_id = "0";

        master_index_id = dvMasterIndex.DataKey.Value.ToString();
        reports_id = gvReports.SelectedDataKey.Value.ToString();

        Session[ DbAccess.SessionVariableName.MASTER_INDEX_ID.ToString() ] = master_index_id;

        Session[ DbAccess.SessionVariableName.TEST_COMPLETE_REPORT_ID.ToString() ] = reports_id;

        Response.Redirect(edit_page);

    }

}