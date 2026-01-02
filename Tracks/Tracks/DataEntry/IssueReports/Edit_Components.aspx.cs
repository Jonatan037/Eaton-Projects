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


public partial class Tracks_Protected_IssueReports_Components_Edit : System.Web.UI.Page
{
    // ViewState names
    const string vsUrl = "URL";
    const string vsIssueReportID = "IssueReportID";
    const string vsComponentID = "ComponentID";


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
            ViewState[vsIssueReportID] = Session[ DbAccess.SessionVariableName.ISSUE_REPORT_ID.ToString() ].ToString();

            // Get the component id number form the session variable.
            ViewState[vsComponentID] = Session[ DbAccess.SessionVariableName.COMPONENT_ID.ToString() ].ToString();

            lblDebug.Text = "Component ID = " + ViewState[vsComponentID].ToString();

            if (ViewState[vsIssueReportID] != null)
                if(ViewState[vsComponentID] != null)
                    GetData();

        }
    }

    private void GetData()
    {
        DbAccess db = new DbAccess();
        DataTable dt;
        string sql = "";

        // Drop lists
        db.PopulateDropDownList(ddlReplacementReasonType, DbAccess.DropListType.COMPONENTS_CT_REPLACEMENT_REASON_TYPE);
        db.PopulateDropDownList(ddlDispositionType, DbAccess.DropListType.COMPONENTS_CT_DISPOSITION_TYPE);

        sql = "SELECT * FROM [COMPONENTS] WHERE [COMPONENTS_ID] = " + ViewState[vsComponentID].ToString();

        dt = db.GetData(sql);

        //Stop here if this is a new record.
        if (dt.Rows.Count == 0)
        {
            // Set default values for the drop lists.
            db.DropDownList_SelectedValue(ddlDispositionType, "Send to NCM");
            //db.DropDownList_SelectedValue(ddlReplacementReasonType, "Collateral Damage");
            db.DropDownList_SelectedValue(ddlReplacementReasonType, "Primary Defective Part");     
            
            return;
        }

        txtSerialNumber.Text = dt.Rows[0]["SERIAL_NUMBER"].ToString();
        txtPartNumber.Text = dt.Rows[0]["PART_NUMBER"].ToString();
        txtNotes.Text = dt.Rows[0]["NOTES"].ToString();


        try
        {
            db.DropDownList_SelectedValue( ddlDispositionType,dt.Rows[0]["DISPOSITION_TYPE"].ToString() );
            db.DropDownList_SelectedValue( ddlReplacementReasonType, dt.Rows[0]["REPLACEMENT_REASON_TYPE"].ToString() );
        }
        catch (Exception ex)
        {
            lblDebug.Text = ex.Message;
        }



    }

    private void Save()
    {
        Components C = new Components();

        // New component
        if (ViewState[vsComponentID].ToString() == "0")
        {
            C.Add
            (
                ViewState[vsIssueReportID].ToString(), 
                txtSerialNumber.Text,
                txtPartNumber.Text,
                ddlReplacementReasonType.SelectedValue, 
                ddlDispositionType.SelectedValue,
                txtNotes.Text
            );
        }

        // Existing component
        else
        {
            C.Update
            (
                ViewState[vsComponentID].ToString(),
                txtSerialNumber.Text,
                txtPartNumber.Text,
                ddlReplacementReasonType.SelectedValue,
                ddlDispositionType.SelectedValue,
                txtNotes.Text
            );
        }


        // Return to the calling page.
        if (ViewState[vsUrl] != null)
            Response.Redirect(ViewState[vsUrl].ToString());
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        string message = "";
        PartNumbers pn = new PartNumbers();

        // Error check required fields.
        if (txtPartNumber.Text == "") return;

        // Check for valid part number.
        if (!pn.IsListed(txtPartNumber.Text))
        {
            message = "This part number is not listed in the database.\\nDo you want to continue to use it?";

            ScriptManager.RegisterStartupScript(this, typeof(Page), "confirm", "confirmation('" + message + "');", true);

            return;
        }

        Save();

    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        // Return to the calling page.
        if (ViewState[vsUrl] != null)
            Response.Redirect(ViewState[vsUrl].ToString());
    }

    protected void btnDelete_Click(object sender, EventArgs e)
    {
        Components C = new Components();

        C.Delete(ViewState[vsComponentID].ToString());

        // Return to the calling page.
        if (ViewState[vsUrl] != null)
            Response.Redirect(ViewState[vsUrl].ToString());
    }


    protected void btnDeterminePartNumber_Click(object sender, EventArgs e)
    {
        if (txtSerialNumber.Text == "") return;

        SerialNumber sn = new SerialNumber(txtSerialNumber.Text);

        txtPartNumber.Text = sn.GetPartNumber();

    }

    protected void ScriptConfirmation_Click(object sender, EventArgs e)
    {
        Save();
    }
}