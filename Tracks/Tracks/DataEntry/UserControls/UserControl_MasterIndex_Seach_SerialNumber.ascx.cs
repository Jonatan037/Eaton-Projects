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

public partial class UserControl_MasterIndex_Seach_SerialNumber : System.Web.UI.UserControl
{
    DbAccess db = new DbAccess();
    DataTable dt = new DataTable();

    public event EventHandler SerialNumberFound;

    public string SerialNumber
    {
        get { return Session[DbAccess.SessionVariableName.SERIAL_NUMBER.ToString()].ToString(); }
 
    }

    protected void Page_Load(object sender, EventArgs e)
    {

        if (!IsPostBack)
        {
            string serial_number = Session[DbAccess.SessionVariableName.SERIAL_NUMBER.ToString()] as string;

            if (serial_number != null)
            {
                txtSerialNumber.Text = serial_number;
                SerialNumberexists();
            }

            txtSerialNumber.Focus();

        }
    }


    private bool SerialNumberexists()
    {
        string serial_number = txtSerialNumber.Text;

        if (serial_number == "") return false;

        // Save the serial number to the session variable.
        Session[DbAccess.SessionVariableName.SERIAL_NUMBER.ToString()] = serial_number;

        SerialNumber sn = new SerialNumber(serial_number);


        if (sn.Exists())
            return true;
        else
            return false;

    }

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        txtSerialNumber.Text = txtSerialNumber.Text.Trim();
        txtSerialNumber.Text = txtSerialNumber.Text.ToUpper();

        Session[DbAccess.SessionVariableName.SERIAL_NUMBER.ToString()] = txtSerialNumber.Text;

        if (txtSerialNumber.Text == "")
        {
            //return;
        }
        // Stop here if the serial number already exists.
        if (SerialNumberexists() | txtSerialNumber.Text == "")
        {
            // raise sn found event
            if (SerialNumberFound != null)
                SerialNumberFound(this, EventArgs.Empty);

            return;
        }

        // Call page to add the new serial number.
        Response.Redirect("../MasterIndex/CreateNewEntry.aspx");
    }

}