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

public partial class Tracks_Protected_IssueReports_LaborHours_Edit : System.Web.UI.Page
{
    // ViewState names
    const string vsUrl = "URL";
    const string vsIssueReportID = "IssueReportID";
    const string vsLaborHourID = "LaborHourID";


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
            ViewState[vsLaborHourID] = Session[DbAccess.SessionVariableName.LABOR_HOUR_ID.ToString()].ToString();

            lblDebug.Text = "Labor Hour ID = " + ViewState[vsLaborHourID].ToString();

            if (ViewState[vsIssueReportID] != null)
                if (ViewState[vsLaborHourID] != null)
                    GetData();

        }
    }

    private void GetData()
    {
        DbAccess db = new DbAccess();
        DataTable dt;
        string sql = "";

        // Drop lists
        db.PopulateDropDownList(ddlLaborHourType, DbAccess.DropListType.LABOR_HOURS_CT_LABOR_TYPE);

        sql = "SELECT * FROM [LABOR_HOURS] WHERE [LABOR_HOURS_ID] = " + ViewState[vsLaborHourID].ToString();

        dt = db.GetData(sql);

        //Stop here if this is a new record.
        if (dt.Rows.Count == 0)
        {
            txtEmployeeID.Text = User.Identity.Name.ToUpper();
            db.DropDownList_SelectedValue(ddlLaborHourType, "Troubleshooting");
            return;
        }

        txtEmployeeID.Text = dt.Rows[0]["EMPLOYEE_ID"].ToString();
        txtLaborHours.Text = dt.Rows[0]["LABOR_HOURS"].ToString();
        txtNotes.Text = dt.Rows[0]["NOTES"].ToString();


        try
        {
            db.DropDownList_SelectedValue( ddlLaborHourType, dt.Rows[0]["LABOR_TYPE"].ToString() );

        }
        catch (Exception ex)
        {
            lblDebug.Text = ex.Message;
        }



    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        LaborHours LH = new LaborHours();
        
        Double result;    // Contains the parsed value of the string.
        bool valid_value;    // Validity state.

        // Try to parse the text as a number.
        valid_value = Double.TryParse(txtLaborHours.Text, out result);

        //Error check labor hours for a valid number >= 0.
        if ( !valid_value | result < 0)
        {
            this.Page.ClientScript.RegisterStartupScript(this.GetType(), "alert", "alert('Labor hours must be >= 0')", true);
            return;
        }


        // Put employee id in upper case
        txtEmployeeID.Text = txtEmployeeID.Text.Trim();
        txtEmployeeID.Text = txtEmployeeID.Text.ToUpper();

        // New entry
        if (ViewState[vsLaborHourID].ToString() == "0")
        {
            LH.Add
            (
                ViewState[vsIssueReportID].ToString(),
                txtEmployeeID.Text,
                txtLaborHours.Text,
                ddlLaborHourType.SelectedValue,
                txtNotes.Text
            );
        }

        // Existing component
        else
        {
            LH.Update
            (
                ViewState[vsLaborHourID].ToString(),
                txtEmployeeID.Text,
                txtLaborHours.Text,
                ddlLaborHourType.SelectedValue,
                txtNotes.Text
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

        LaborHours LH = new LaborHours();

        LH.Delete(ViewState[vsLaborHourID].ToString());

        // Return to the calling page.
        if (ViewState[vsUrl] != null)
            Response.Redirect(ViewState[vsUrl].ToString());
    }

}