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


public partial class Tracks_Reports_Miscellaneous_Reports_Show_RootCauseTypes : System.Web.UI.Page
{
    // ViewState names   
    const string vsDataSource = "DataSource";

    protected void Page_Load(object sender, EventArgs e)
    {
        // Put in this order to prevent SYLK file error message.
        string sql = "SELECT ACTIVE, ID, DESCRIPTION FROM ISSUE_REPORTS_CT_ROOT_CAUSE_CODE";

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

        string filename = "ISSUE_REPORTS_CT_ROOT_CAUSE_CODE";
        DataTable dt = (DataTable)ViewState[vsDataSource];

        Tools t = new Tools();
        t.CreateExcelFile(filename, ref dt);

    }

}