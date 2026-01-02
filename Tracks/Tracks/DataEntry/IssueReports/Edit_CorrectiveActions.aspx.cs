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

public partial class Tracks_Protected_IssueReports_CorrectiveActions_Edit : System.Web.UI.Page
{
    // ViewState names
    const string vsUrl = "URL";
    //const string vsSerialNumber = "SerialNumber";
    const string vsIssueReportID = "IssueReportID";
    const string vsCorrectiveActionID = "CorrectiveActionID";


    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            // Try to get the url of the calling page.
            if (Request.UrlReferrer != null)
                ViewState[vsUrl] = Request.UrlReferrer.ToString();

            // Try to get the serial number.
            string serial_number = Session[DbAccess.SessionVariableName.SERIAL_NUMBER.ToString()] as string;

            // If the serial number is avaliable, then populate text boxes.
            if (serial_number != null)
            {
                serial_number = serial_number.Trim();
                serial_number = serial_number.ToUpper();

                lblTitle.Text = "UNIT SERIAL NUMBER = " + serial_number;

            }


            // Get the issue report id number form the session variable.
            ViewState[vsIssueReportID] = Session[DbAccess.SessionVariableName.ISSUE_REPORT_ID.ToString()].ToString();

            // Get the labor hour id number form the session variable.
            ViewState[vsCorrectiveActionID] = Session[DbAccess.SessionVariableName.CORRECTIVE_ACTION_ID.ToString()].ToString();

            lblDebug.Text = "Corrective Action ID = " + ViewState[vsCorrectiveActionID].ToString();

            if (ViewState[vsIssueReportID] != null)
                if (ViewState[vsCorrectiveActionID] != null)
                    GetData();

        }
    }

    private void GetData()
    {
        DbAccess db = new DbAccess();
        DataTable dt;
        string sql = "";

        // Drop lists
        db.PopulateDropDownList(ddlCorrectiveActionType, DbAccess.DropListType.CORRECTIVE_ACTIONS_CT_ACTION_TYPE);

        sql = "SELECT * FROM [CORRECTIVE_ACTIONS] WHERE [CORRECTIVE_ACTIONS_ID] = " + ViewState[vsCorrectiveActionID].ToString();

        dt = db.GetData(sql);


        //Stop here if this is a new record.
        if (dt.Rows.Count == 0) return;

        txtNotes.Text = dt.Rows[0]["NOTES"].ToString();


        try
        {
            db.DropDownList_SelectedValue( ddlCorrectiveActionType, dt.Rows[0]["ACTION_TYPE"].ToString() );

        }
        catch (Exception ex)
        {
            lblDebug.Text = ex.Message;
        }
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        string timestamp = "\r\nLast saved on " + DateTime.Now + " by " + User.Identity.Name.ToUpper() + "\r\n";

        string notes = txtNotes.Text + timestamp;

        CorrectiveActions CA = new CorrectiveActions();

        // New entry
        if (ViewState[vsCorrectiveActionID].ToString() == "0")
        {
            CA.Add
            (
                ViewState[vsIssueReportID].ToString(),
                ddlCorrectiveActionType.SelectedValue,
                notes
            );
        }

        // Existing component
        else
        {
            CA.Update
            (
                ViewState[vsCorrectiveActionID].ToString(),
                ddlCorrectiveActionType.SelectedValue,
                notes
            );
        }

        // Return to the calling page.
        if (ViewState[vsUrl] != null)
            Response.Redirect(ViewState[vsUrl].ToString());
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        // Return to the calling page.
        if (ViewState[vsUrl] != null)
            Response.Redirect(ViewState[vsUrl].ToString());
    }

    protected void btnDelete_Click(object sender, EventArgs e)
    {
        CorrectiveActions CA = new CorrectiveActions();

        CA.Delete(ViewState[vsCorrectiveActionID].ToString());

        // Return to the calling page.
        if (ViewState[vsUrl] != null)
            Response.Redirect(ViewState[vsUrl].ToString());
    }


}