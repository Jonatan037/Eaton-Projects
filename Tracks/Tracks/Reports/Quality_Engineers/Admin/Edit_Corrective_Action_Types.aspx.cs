using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;


//using System.Data;
//using System.Configuration;
using System.Data.SqlClient;

using Tracks.DAL;

public partial class Tracks_Reports_Quality_Engineers_Edit_Assembly_Station_Names : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    protected void btnAddNewName_Click(object sender, EventArgs e)
    {
        string new_value = txtNewName.Text.Trim();

        // Reset text field.
        txtNewName.Text = "";

        if (new_value == "") return;

        string sql = "INSERT INTO [CORRECTIVE_ACTIONS_CT_ACTION_TYPES] (ACTION_TYPE) VALUES(@ACTION_TYPE)";

        DbAccess db = new DbAccess();

        SqlCommand cmd = new SqlCommand(sql);
        cmd.Parameters.AddWithValue("@ACTION_TYPE", new_value);
        
        db.ExecuteNonQuery(cmd);
        lblDebug.Text = db.ErrorMessage;

        gvCorrectiveActionTypes.DataBind();

        //SqlDataSource1.DataBind();
    }
}