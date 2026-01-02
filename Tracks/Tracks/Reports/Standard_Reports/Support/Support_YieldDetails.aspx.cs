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

public partial class Tracks_Reports_Standard_Reports_ShowYieldDetails : System.Web.UI.Page
{
    // ViewState names
    const string vsUrl = "URL";
    const string vsDataSource = "DataSource";

    DbAccess db = new DbAccess();


    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            DataTable dt;

            // Try to get the url of the calling page.
            if (Request.UrlReferrer != null)
                ViewState[vsUrl] = Request.UrlReferrer.ToString();


            string StartDate = Request.QueryString["StartDate"];
            string EndDate = Request.QueryString["EndDate"];
            string Plant = Request.QueryString["Plant"];
            string Family = Request.QueryString["Family"];
            string Category = Request.QueryString["Category"];

            string sql;

            string date_range = " CAST(MI.[FIRST_TEST_DATE] AS Date) BETWEEN " + StartDate + " AND " + EndDate + " ";

            sql = "SELECT IR.ISSUE_REPORTS_ID, " +
                     "MI.PLANT, MI.FAMILY, MI.CATEGORY, MI.SERIAL_NUMBER, MI.PART_NUMBER, MI.FAILED, " +
                     "IR.EMPLOYEE_ID, IR.NONCONFORMANCE_CODE, " +
                     "IR.CREATION_TIMESTAMP, IR.PROBLEM_DESCRIPTION, IR.NOTES, " +
                     "' 'AS [COMPONENTS] " + 
                  "FROM MASTER_INDEX MI LEFT JOIN ISSUE_REPORTS IR ON MI.MASTER_INDEX_ID = IR.MASTER_INDEX_ID " +
                  "WHERE " + date_range + " ";

            if (Plant != null)
                sql += " AND MI.PLANT = '" + Plant + "' ";

            if (Family != null)
                sql += " AND MI.FAMILY = '" + Family + "' ";

            if (Category!= null)
                sql += " AND MI.CATEGORY = '" + Category + "' ";

            sql += " ORDER BY MI.SERIAL_NUMBER, IR.CREATION_TIMESTAMP";

            // Get the data.
            dt = db.GetData(sql);

            // Add the components to the table.
            GetComponents(ref dt);

            gvResults.DataSource = dt;
            gvResults.DataBind();

            ViewState[vsDataSource] = dt;
        }

    }

    protected void GetComponents(ref DataTable DT) 
    {  
        // Stop here if there are not any rows in the table.
        if (DT.Rows.Count == 0) return;

        string issue_report_id = "";

        Components c = new Components();

        foreach (DataRow row in DT.Rows)
        {
            issue_report_id = row["ISSUE_REPORTS_ID"].ToString();

            if (issue_report_id != "")
             row["COMPONENTS"] = c.GetList(issue_report_id);
        }
    }




    protected void btnReturn_Click(object sender, EventArgs e)
    {
        if (ViewState[vsUrl] != null)
            Response.Redirect(ViewState[vsUrl].ToString());
    }


    protected void btnDownload_Click(object sender, EventArgs e)
    {
        string value;
        DataTable dt;

        if (ViewState[vsDataSource] != null) return;

        dt = (DataTable) ViewState[vsDataSource];

        string attach = "attachment;filename=yield_details.xls";
        Response.ClearContent();
        Response.AddHeader("content-disposition", attach);
        Response.ContentType = "application/ms-excel";


        foreach (DataColumn dc in dt.Columns)
        {
            Response.Write(dc.ColumnName + "\t");
        }

        Response.Write(System.Environment.NewLine);

        foreach (DataRow dr in dt.Rows)
        {
            for (int i = 0; i < dt.Columns.Count; i++)
            {
                value = dr[i].ToString();
                value = value.Replace(System.Environment.NewLine, "");

                Response.Write(dr[i].ToString() + "\t");
            }

            Response.Write(System.Environment.NewLine);
        }

        Response.End();

    }


}