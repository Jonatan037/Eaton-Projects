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


public partial class Tracks_DataEntry_IssueReports_Edit_Files : System.Web.UI.Page
{

    // ViewState names
    const string vsUrl = "URL";
    const string vsIssueReportID = "IssueReportID";
    const string vsFileID = "FileID";



    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            // Try to get the url of the calling page.
            if (Request.UrlReferrer != null)
                ViewState[vsUrl] = Request.UrlReferrer.ToString();


            // Get the issue report id number form the session variable.
            ViewState[vsIssueReportID] = Session[DbAccess.SessionVariableName.ISSUE_REPORT_ID.ToString()].ToString();

            // Get the component id number form the session variable.
            ViewState[vsFileID] = Session[DbAccess.SessionVariableName.FILE_ID.ToString()].ToString();

            lblDebug.Text = "File ID = " + ViewState[vsFileID].ToString();

            if (ViewState[vsIssueReportID] != null)
                if (ViewState[vsFileID] != null)
                    GetData();

        }
    }

    private void GetData()
    {
        DbAccess db = new DbAccess();
        DataTable dt;
        string sql = "";


        sql = "SELECT * FROM [FILE_STORAGE] WHERE [FILE_STORAGE_ID] = " + ViewState[vsFileID].ToString();

        dt = db.GetData(sql);


        //Stop here if this is a new record.
        if (dt.Rows.Count == 0)
        {
            Panel1.Visible = true;
            return;
        }

        Panel1.Visible = false;
        txtNotes.Text = dt.Rows[0]["NOTES"].ToString();

    }



    protected void btnSave_Click(object sender, EventArgs e)
    {
        string timestamp = "\r\nSaved on " + DateTime.Now + " by " + User.Identity.Name.ToUpper() + "\r\n";

        string notes = txtNotes.Text + timestamp;

        FileStorage FS = new FileStorage();

        // New entry
        if (ViewState[vsFileID].ToString() == "0")
        {
            if (FileUpload1.HasFile )
            {
                FS.UploadFile(FileUpload1, ViewState[vsIssueReportID].ToString(), notes);
            }

        }

        // Existing component
        else
        {
            FS.Update(ViewState[vsFileID].ToString(), notes );
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
        FileStorage FS = new FileStorage();

        FS.Delete(ViewState[vsFileID].ToString());

        // Return to the calling page.
        if (ViewState[vsUrl] != null)
            Response.Redirect(ViewState[vsUrl].ToString());
    }


}