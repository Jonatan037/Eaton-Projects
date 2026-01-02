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

public partial class Tracks_Reports_Standard_Reports_Support_Support_Yields_Test_Report : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

        string dbid = Session[DbAccess.SessionVariableName.REPORT_DBID.ToString()].ToString();
        string results_id = Session[DbAccess.SessionVariableName.REPORT_RESULTS_ID.ToString()].ToString();

        // SPD
        if (dbid == "5")
        {
            Response.Redirect("Support_Yields_Test_Report_SPD.aspx?REPORT_RESULTS_ID=" + results_id);
        }


        // TDM
        if (dbid == "40")
        {
            Response.Redirect("Support_Yields_Test_Report_TDM.aspx?REPORT_RESULTS_ID=" + results_id);
        }

        // TAA
        if (dbid == "44")
        {
            Response.Redirect("Support_Yields_Test_Report_TAA.aspx?REPORT_RESULTS_ID=" + results_id);
        }

        DataTable header = new DataTable();
        DataTable body = new DataTable();

        Reports rp = new Reports();

        rp.GetReport(dbid, results_id, ref header, ref body);

        dvReportHeader.DataSource = header;
        dvReportHeader.DataBind();

        gvReportBody.DataSource = body;
        gvReportBody.DataBind();

    }







}