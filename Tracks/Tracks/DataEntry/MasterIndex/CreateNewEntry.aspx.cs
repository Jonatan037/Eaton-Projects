using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using Tracks.DAL;

// consider putting in some come so this page can be called directly to enter serial numbers.
public partial class Tracks_Protected_MasterIndex_CreateNewEntry : System.Web.UI.Page
{
    // ViewState names
    const string vsUrl = "URL";
    //const string vsSerialNumber = "SerialNumber";

    protected void Page_Load(object sender, EventArgs e)
    {

        if (!IsPostBack)
        {
            // Try to get the url of the calling page.
            if (Request.UrlReferrer != null)
            {
                ViewState[vsUrl] = Request.UrlReferrer.ToString();
                lblDebug.Text = ViewState[vsUrl].ToString();
            }

            // Try to get the serial number.
            string serial_number = Session[DbAccess.SessionVariableName.SERIAL_NUMBER.ToString()] as string;

            // If the serial number is avaliable, then populate text boxes.
            if (serial_number != null)
            {
                serial_number = serial_number.Trim();
                serial_number = serial_number.ToUpper();

                // Populate the serial number text box.
                txtSerialNumber.Text = serial_number;

                SerialNumber SN = new SerialNumber(serial_number);

                // Populate the part number field by interpreting the vendor serial number, if available.
                txtPartNumber.Text = SN.GetPartNumber();
            }

            // Set focus to the part number.
            txtPartNumber.Focus();
        }



    }

    private void Save()
    {

        // Save the new data to the MASTER_INDEX table.
        MasterIndex MI = new MasterIndex();

        // Try to add the new serial number to the MASTER_INDEX table.
        if (!MI.Add(txtSerialNumber.Text, txtPartNumber.Text, txtProductionOrderNumber.Text, txtSalesOrderNumber.Text, txtNotes.Text))
        {
            lblDebug.Text = MI.ErrorMessage;

            return;
        }

        // Return to the calling page.
        if (ViewState[vsUrl] != null)
            Response.Redirect(ViewState[vsUrl].ToString());
    }

    protected void btnOk_Click(object sender, EventArgs e)
    {
        string message = "";
        PartNumbers pn = new PartNumbers();

        // Error check required fields.
        if ((txtSerialNumber.Text == "") || (txtPartNumber.Text == "")) return;

        // Check for at least 10 characters in the serial number.
        if (txtSerialNumber.Text.Length < 10)
        {
            message = "This serial number does not have 10 characters.\\nDo you want to continue to use it?";

            ScriptManager.RegisterStartupScript(this, typeof(Page), "confirm", "confirmation('" + message + "');", true);

            return;
        }

        // Check for valid part number.
        if ( !pn.IsListed( txtPartNumber.Text ) )
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


    protected void ScriptConfirmation_Click(object sender, EventArgs e)
    {
        Save();
    }
}