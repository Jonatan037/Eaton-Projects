using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using Tracks.DAL;

public partial class Tracks_Print_PrintIssueReport : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        DbAccess db = new DbAccess();
        string issue_report_id = "";
        string sql;

        if (Session[DbAccess.SessionVariableName.ISSUE_REPORT_ID.ToString()] != null)
        {
            issue_report_id = Session[DbAccess.SessionVariableName.ISSUE_REPORT_ID.ToString()] as string;


            sql = "SELECT " +
                  "MI.SERIAL_NUMBER, MI.PART_NUMBER, MI.PLANT, MI.FAMILY, MI.CATEGORY, IR.* " + 
                  "FROM ISSUE_REPORTS AS [IR] INNER JOIN MASTER_INDEX AS [MI] " +
                  "ON IR.MASTER_INDEX_ID = MI.MASTER_INDEX_ID " +
                  "WHERE IR.ISSUE_REPORTS_ID = " + issue_report_id;


            dvIssueReport.DataSource = db.GetData(sql);
            dvIssueReport.DataBind();
        }
    }
}