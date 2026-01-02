using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using Tracks.DAL;

public partial class Tracks_Print_PrintTestCompleteReport : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        DbAccess db = new DbAccess();

        string id;
        string sql;

        if (Session[DbAccess.SessionVariableName.TEST_COMPLETE_REPORT_ID.ToString()] != null)
        {
            id = Session[DbAccess.SessionVariableName.TEST_COMPLETE_REPORT_ID.ToString()] as string;

            sql = "SELECT * FROM TEST_COMPLETE_REPORTS WHERE TEST_COMPLETE_REPORTS_ID = " + id;

            dvTestCompleteReport.DataSource = db.GetData(sql);
            dvTestCompleteReport.DataBind();
        }
    }
}