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

public partial class Tracks_Print_PrintIssueReport : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        DbAccess db = new DbAccess();
        string issue_report_id = "";
        string sql;
        DataTable dt;
        string value;

        if (Session[DbAccess.SessionVariableName.ISSUE_REPORT_ID.ToString()] != null)
        {
            issue_report_id = Session[DbAccess.SessionVariableName.ISSUE_REPORT_ID.ToString()] as string;


            sql = "SELECT " +
                  "MI.SERIAL_NUMBER, MI.PART_NUMBER, MI.PLANT, MI.FAMILY, MI.CATEGORY, IR.* " + 
                  "FROM ISSUE_REPORTS AS [IR] INNER JOIN MASTER_INDEX AS [MI] " +
                  "ON IR.MASTER_INDEX_ID = MI.MASTER_INDEX_ID " +
                  "WHERE IR.ISSUE_REPORTS_ID = " + issue_report_id;


            dt = db.GetData(sql);

            foreach (DataRow row in dt.Rows)
            {
                row["PROBLEM_DESCRIPTION"] = row["PROBLEM_DESCRIPTION"].ToString().Replace(System.Environment.NewLine, "<BR>");
                row["NOTES"] = row["NOTES"].ToString().Replace(System.Environment.NewLine, "<BR>");
                row["REWORK_INSTRUCTIONS"] = row["REWORK_INSTRUCTIONS"].ToString().Replace(System.Environment.NewLine, "<BR>");
            }

            dvIssueReport.DataSource = dt;
            dvIssueReport.DataBind();


            sql = "SELECT PART_NUMBER, SERIAL_NUMBER, COST, DESCRIPTION, DISPOSITION_TYPE, NOTES " +  
                  "FROM COMPONENTS WHERE ISSUE_REPORTS_ID = " + issue_report_id;

            gvComponents.DataSource = db.GetData(sql);
            gvComponents.DataBind();

        }
    }

}