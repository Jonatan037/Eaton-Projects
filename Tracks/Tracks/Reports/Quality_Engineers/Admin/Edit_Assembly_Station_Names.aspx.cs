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
        string station_name = txtNewName.Text.Trim();

        // Reset text field.
        txtNewName.Text = "";

        if (station_name == "") return;

        string sql = "INSERT INTO [ISSUE_REPORTS_CT_ASSEMBLY_STATION_NAMES] (STATION_NAME) VALUES(@STATION_NAME)";

        DbAccess db = new DbAccess();

        SqlCommand cmd = new SqlCommand(sql);
        cmd.Parameters.AddWithValue("@STATION_NAME", station_name);
        
        db.ExecuteNonQuery(cmd);
        lblDebug.Text = db.ErrorMessage;

        gvStationNames.DataBind();

        //SqlDataSource1.DataBind();
    }
}