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

public partial class NCRs_Miscellaneous_Reports_CorrectiveActionTypes : System.Web.UI.Page
{
    // ViewState names   
    const string vsDataSource = "DataSource";

    protected void Page_Load(object sender, EventArgs e)
    {
        // Put in this order to prevent SYLK file error message.
        string sql = "SELECT ACTIVE, ID, DESCRIPTION FROM CORRECTIVE_ACTIONS_CT_ACTION_TYPE";

        DbAccess db = new DbAccess();
        DataTable dt;

        // Get the data.
        dt = db.GetData(sql);

        // Save the data to the view state.
        ViewState[vsDataSource] = dt;

        // Display the data in the grid.
        GridView1.DataSource = db.GetData(sql);
        GridView1.DataBind();

    }

    protected void btnDownload_Click(object sender, EventArgs e)
    {
        if (ViewState[vsDataSource] == null) return;

        string filename = "CORRECTIVE_ACTIONS_CT_ACTION_TYPE";
        DataTable dt = (DataTable)ViewState[vsDataSource];

        Tools t = new Tools();
        t.CreateExcelFile(filename, ref dt);

    }


}