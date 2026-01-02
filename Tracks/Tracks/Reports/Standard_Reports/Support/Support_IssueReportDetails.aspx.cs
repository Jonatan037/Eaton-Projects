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
using Tracks.BLL;

public partial class Tracks_Reports_Standard_Reports_ShowIssueReportDetails : System.Web.UI.Page
{

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            DbAccess db = new DbAccess();
            //DataTable dt = new DataTable();

            string id;
            string sql;

            if (Session[DbAccess.SessionVariableName.ISSUE_REPORT_ID.ToString()] != null)
            { 
                id = Session[DbAccess.SessionVariableName.ISSUE_REPORT_ID.ToString()] as string;

                sql = "SELECT * FROM ISSUE_REPORTS WHERE ISSUE_REPORTS_ID = " + id;

                dvIssueReport.DataSource = db.GetData(sql);
                dvIssueReport.DataBind();
            }

            // Hide/Unhide controls based on user roles.
            btnEdit.Visible = UserPermissions.CanEditQualityOptions(User);

        }

    }


    protected void btnEdit_Click(object sender, EventArgs e)
    {
        Session[DbAccess.SessionVariableName.ISSUE_REPORT_ID.ToString()] = dvIssueReport.DataKey.Value.ToString();

        Session[DbAccess.SessionVariableName.SERIAL_NUMBER.ToString()] = "";

        Response.Redirect("~/Tracks/DataEntry/IssueReports/Edit_IssueReports.aspx");
    }

    protected void btnPrint_Click(object sender, EventArgs e)
    {
        Session[DbAccess.SessionVariableName.ISSUE_REPORT_ID.ToString()] = dvIssueReport.DataKey.Value.ToString();

        Response.Redirect("~/Tracks/Print/PrintIssueReport.aspx");
    }
}