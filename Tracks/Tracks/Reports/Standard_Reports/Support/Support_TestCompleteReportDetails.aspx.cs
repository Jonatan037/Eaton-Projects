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

public partial class Tracks_Reports_Standard_Reports_Support_Support_TestCompleteReportDetails : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
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

            // Hide/Unhide controls based on user roles.
            btnEdit.Visible = UserPermissions.CanEditQualityOptions(User);

        }

    }

    protected void btnEdit_Click(object sender, EventArgs e)
    {
        Session[DbAccess.SessionVariableName.TEST_COMPLETE_REPORT_ID.ToString()] = dvTestCompleteReport.DataKey.Value.ToString();

        Session[DbAccess.SessionVariableName.SERIAL_NUMBER.ToString()] = "";

        Response.Redirect("~/Tracks/DataEntry/TestCompleteReports/Edit_TestCompleteReport.aspx");
    }


    protected void btnPrint_Click(object sender, EventArgs e)
    {
        Session[DbAccess.SessionVariableName.TEST_COMPLETE_REPORT_ID.ToString()] = dvTestCompleteReport.DataKey.Value.ToString();

        Response.Redirect("~/Tracks/Print/PrintTestCompleteReport.aspx");
    }
}