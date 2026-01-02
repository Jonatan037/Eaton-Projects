using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;


using System.Data;
//using System.Configuration;
using System.Data.SqlClient;

using Tracks.DAL;

public partial class Tracks_Reports_Quality_Engineers_Workmanship_Corrective_Actions : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        
        if (!IsPostBack)
        {
            DbAccess db = new DbAccess();
            
            txtStartDate.Text = DateTime.Now.ToShortDateString();
            txtEndDate.Text = DateTime.Now.ToShortDateString();

            db.PopulateDropDownList(ddlNonconformanceType, DbAccess.DropListType.ISSUE_REPORTS_CT_NONCONFORMANCE_CATEGORY);
            ddlNonconformanceType.Items.Insert(0, "ALL");
            db.DropDownList_SelectedValue(ddlNonconformanceType, "ALL");

            GetData();
        }


    }

    private void GetData()
    {

        DbAccess db = new DbAccess();
        DataTable dt;
        DataTable dtSummary;


        // Details
        dt = db.GetData( CreateSql(1) );

        gvDetails.DataSource = dt;
        gvDetails.DataBind();

        // Issue count
        dtSummary = db.GetData(CreateSql(3));

        // Crosstab
        dt = db.GetData(CreateSql(2));

        // Add additional column names to summary
        for (int i = 3; i < dt.Columns.Count; i++)
        { 
            dtSummary.Columns.Add(dt.Columns[i].ColumnName);
        }

        // Add the crosstab values to the summary table.
        for (int row = 0; row < dt.Rows.Count; row++ )
        {
            for (int col = 3; col < dt.Columns.Count; col++)
            {
                if (dt.Rows[row][col].ToString() != "0")
                    dtSummary.Rows[row][col] = dt.Rows[row][col].ToString();
            }
        }


        dtSummary.Columns["ISSUES"].ColumnName = "ISSUES - " + ddlNonconformanceType.SelectedValue.ToString().ToUpper();

        // Show summary
        gvSummary.DataSource = dtSummary;
        gvSummary.DataBind();


    }




    private string CreateSql(int mode)
    {
        string sql = "";
        string category = ddlNonconformanceType.SelectedValue.ToString();

        string date_range = " (CAST(ISSUE_REPORTS.CREATION_TIMESTAMP AS Date) BETWEEN '" + txtStartDate.Text.ToString() + "' AND '" + txtEndDate.Text.ToString() + "') ";

        if (category == "ALL")
        {
            category = "  ";
        }
        else if (category == "Component")
        {
            category = " AND ISSUE_REPORTS.NONCONFORMANCE_CODE Like 'Defective Component%' ";
        }
        else
        {
            category = "AND ISSUE_REPORTS.NONCONFORMANCE_CODE Like '" + category + "%' ";
        }

        // Details
        if (mode == 1)
        {
            sql = "SELECT " +
                     "MASTER_INDEX.PLANT, " +
                     "MASTER_INDEX.FAMILY,  " +
                     "MASTER_INDEX.SERIAL_NUMBER,  " +
                     "MASTER_INDEX.PART_NUMBER,  " +
                     "ISSUE_REPORTS.CREATION_TIMESTAMP,  " +
                     "ISSUE_REPORTS.NONCONFORMANCE_CODE,  " +
                     "CORRECTIVE_ACTIONS.ACTION_TYPE, " +
                     "CORRECTIVE_ACTIONS.NOTES " +
                  "FROM " +
                      "(MASTER_INDEX INNER JOIN ISSUE_REPORTS ON MASTER_INDEX.MASTER_INDEX_ID = ISSUE_REPORTS.MASTER_INDEX_ID) " +
                      "LEFT JOIN CORRECTIVE_ACTIONS ON ISSUE_REPORTS.ISSUE_REPORTS_ID = CORRECTIVE_ACTIONS.ISSUE_REPORTS_ID " +
                  "WHERE " + date_range + category +
                  "ORDER BY 1,2,3,5";

        }

        // Crosstab query
        else if (mode == 2)
        {
            sql = "SELECT * FROM " +
                    "( " +
                        "SELECT  " +
                            "MASTER_INDEX.PLANT, " +
                            "MASTER_INDEX.FAMILY, " +
                            "'' AS [ISSUES], " +
                            "ISSUE_REPORTS.NONCONFORMANCE_CODE, " +
                            "CORRECTIVE_ACTIONS.ACTION_TYPE " +
                        "FROM " +
                            "(MASTER_INDEX INNER JOIN ISSUE_REPORTS ON MASTER_INDEX.MASTER_INDEX_ID = ISSUE_REPORTS.MASTER_INDEX_ID) " +
                            "LEFT JOIN CORRECTIVE_ACTIONS ON ISSUE_REPORTS.ISSUE_REPORTS_ID = CORRECTIVE_ACTIONS.ISSUE_REPORTS_ID " +
                        "WHERE " + date_range + category +
                        "GROUP BY PLANT, FAMILY,NONCONFORMANCE_CODE, ACTION_TYPE " +
                    ") t " +
                    "PIVOT " +
                        "( " +
                        "COUNT(NONCONFORMANCE_CODE) " +
                        "FOR ACTION_TYPE  IN ([CAR],[DMR],[JIRA],[QN],[Quality Alert],[Quality Coaching],[Quality Stand Down]) " +
                    ") AS pivot_table ORDER BY 1,2";
        }

        // Total number of issues for each plant/family combination.
        else if (mode == 3)
        {
            sql = "SELECT " +
                     "MASTER_INDEX.PLANT, " +
                     "MASTER_INDEX.FAMILY,  " +
                     "COUNT(ISSUE_REPORTS.NONCONFORMANCE_CODE) AS [ISSUES] " +
                  "FROM " +
                      "(MASTER_INDEX INNER JOIN ISSUE_REPORTS ON MASTER_INDEX.MASTER_INDEX_ID = ISSUE_REPORTS.MASTER_INDEX_ID) " +
                      "LEFT JOIN CORRECTIVE_ACTIONS ON ISSUE_REPORTS.ISSUE_REPORTS_ID = CORRECTIVE_ACTIONS.ISSUE_REPORTS_ID " +
                  "WHERE " + date_range + category +
                  "GROUP BY MASTER_INDEX.PLANT, MASTER_INDEX.Family " +
                  "ORDER BY 1,2";
        }

        else
            sql = "";

        //lblDebug.Text = sql;
        
        return sql;

    }


    protected void btnFind_Click(object sender, EventArgs e)
    {
        if (!IsValidDate(txtStartDate.Text)) return;
        if (!IsValidDate(txtEndDate.Text)) return;


        GetData();
    }



    public bool IsValidDate(string date)
    {

        DateTime result;    // Contains the parsed value of the string.
        bool valid_date;    // Validity state.

        // Verify that the string is formatted as a date.
        valid_date = DateTime.TryParse(date, out result);

        // Return false if the string was not a properly formatted date.
        if (!valid_date)
        {
            ClientScript.RegisterStartupScript(this.GetType(), "alert", "alert('Both dates must be in mm/dd/yyyy format.');", true);
            return false;
        }

        // Valid date.
        return true;
    }
   

}