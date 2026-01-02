using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using Tracks.DAL;

using System.Data;
using System.Configuration;
using System.Data.SqlClient;

public partial class Tracks_Print_PrintIssueReport : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        DbAccess db = new DbAccess();
        string issue_report_id = "";
        string sql;
        string rework_instructions;
        string problem_description;

        if (Session[DbAccess.SessionVariableName.ISSUE_REPORT_ID.ToString()] != null)
        {
            issue_report_id = Session[DbAccess.SessionVariableName.ISSUE_REPORT_ID.ToString()] as string;


            sql = "SELECT " +
                  "MI.SERIAL_NUMBER, MI.PART_NUMBER, MI.FAMILY, IR.REWORK_INSTRUCTIONS, IR.PROBLEM_DESCRIPTION " + 
                  "FROM ISSUE_REPORTS AS [IR] INNER JOIN MASTER_INDEX AS [MI] " +
                  "ON IR.MASTER_INDEX_ID = MI.MASTER_INDEX_ID " +
                  "WHERE IR.ISSUE_REPORTS_ID = " + issue_report_id;

            DataTable dt = db.GetData(sql);

            // -----------------------------------------------------------------------------------
            lblSerialNumber.Text = dt.Rows[0]["SERIAL_NUMBER"].ToString();

            lblPartNumber.Text = dt.Rows[0]["PART_NUMBER"].ToString();

            lblFamily.Text = dt.Rows[0]["FAMILY"].ToString();


            // -----------------------------------------------------------------------------------
            problem_description = dt.Rows[0]["PROBLEM_DESCRIPTION"].ToString();

            problem_description = problem_description.Trim();

            divProblemDescription.InnerHtml = problem_description;

            // -----------------------------------------------------------------------------------
            rework_instructions = dt.Rows[0]["REWORK_INSTRUCTIONS"].ToString();

            rework_instructions = rework_instructions.Trim();

            divReworkInstructions.InnerHtml = rework_instructions;


        }
    }
}