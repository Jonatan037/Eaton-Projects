using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using Tracks.DAL;

public partial class Tracks_Print_PrintUnitReport : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        string sql;

        if (Session[DbAccess.SessionVariableName.MASTER_INDEX_ID.ToString()] == null) return;

        string master_index_id = Session[DbAccess.SessionVariableName.MASTER_INDEX_ID.ToString()].ToString();

        DbAccess db = new DbAccess();

        // --------------------------------------------------------------------------------
        sql = "SELECT * FROM MASTER_INDEX WHERE MASTER_INDEX_ID = " + master_index_id;
        dvMasterIndex.DataSource = db.GetData(sql);
        dvMasterIndex.DataBind();

        // --------------------------------------------------------------------------------
        sql = "SELECT CREATION_TIMESTAMP, PROBLEM_DESCRIPTION, NOTES FROM ISSUE_REPORTS WHERE MASTER_INDEX_ID = " + master_index_id;
        gvIssueReports.DataSource = db.GetData(sql);
        gvIssueReports.DataBind();




    }
}