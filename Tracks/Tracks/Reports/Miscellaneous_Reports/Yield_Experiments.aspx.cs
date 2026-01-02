using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using System.Data;
using System.Configuration;
using System.Data.SqlClient;

using System.Drawing;

using Tracks.DAL;

public partial class Tracks_Reports_Yield_Experiments : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            txtStartDate.Text = DateTime.Now.ToShortDateString();
            txtEndDate.Text = DateTime.Now.ToShortDateString();

        }
    }

    
    
    private void GetYields()
    {
        #region // Initialize

        DbAccess dba = new DbAccess();

        DataTable dt; // muliple use data table.

        bool include_category = cbCategory.Checked;

        string standard_select = "SELECT Plant, Family, ' ' [Category] ";

        string group_by = " GROUP BY PLANT, FAMILY ";

        string order_by = "ORDER BY PLANT, FAMILY ";

        string plant_criteria = " AND PLANT = '" + ddlPlant.Text + "' ";

        string tracks_date_range = " CAST([FIRST_TEST_DATE] AS Date) BETWEEN '" + txtStartDate.Text.ToString() + "' AND '" + txtEndDate.Text.ToString() + "' ";

        string tracks_issues_date_range = " CAST([ISSUE_DATE] AS Date) BETWEEN '" + txtStartDate.Text.ToString() + "' AND '" + txtEndDate.Text.ToString() + "' ";

        string qdms_date_range = " CAST([StartTime] AS Date) BETWEEN '" + txtStartDate.Text.ToString() + "' AND '" + txtEndDate.Text.ToString() + "' ";

        string sql;

        string plant = "";
        string family = "";
        string category = "";


        if (include_category)
        {
            standard_select = "SELECT Plant, Family, Category ";
            group_by = " GROUP BY PLANT, FAMILY, CATEGORY ";
            order_by = "ORDER BY PLANT, FAMILY, CATEGORY ";
        }

        #endregion


        #region // Build dtGrid

        // Get all family names.
        sql = standard_select + " FROM [View_PowerBI_LINKED_QDMS_FPY] WHERE " + qdms_date_range + plant_criteria + group_by +
              "UNION " +
              standard_select + " FROM [View_PowerBI_MASTER_INDEX] WHERE " + tracks_date_range + plant_criteria + group_by +
              order_by;

        DataTable dtGrid = dba.GetData(sql);

        dtGrid.Columns.Add("QDMS_TESTED");
        dtGrid.Columns.Add("QDMS_PASSED");
        dtGrid.Columns.Add("QDMS_FAILED");
        dtGrid.Columns.Add("QDMS_FPY");

        dtGrid.Columns.Add("TRACKS_TESTED");
        dtGrid.Columns.Add("TRACKS_PASSED");
        dtGrid.Columns.Add("TRACKS_FAILED");
        dtGrid.Columns.Add("TRACKS_FPY");

        dtGrid.Columns.Add("ISSUE_COUNT");
        dtGrid.Columns.Add("ISSUES_PER_UNIT");


        #endregion

        #region // Get data from YPO QDMS View_PowerBI_LINKED_QDMS_FPY.

        sql = standard_select +
                 ", COUNT(Results) [TESTED], " +
                 "SUM(Results) [PASSED], " +
                 "COUNT(Results) - SUM([Results]) [FAILED] " +
                 "FROM [View_PowerBI_LINKED_QDMS_FPY] " +
              "WHERE " + qdms_date_range + plant_criteria + group_by + order_by;

        dt = dba.GetData(sql);

        foreach (DataRow row in dt.Rows)
        {
            plant = row["PLANT"].ToString();

            family = row["FAMILY"].ToString();

            if (include_category)
                category = " AND CATEGORY = '" + row["CATEGORY"].ToString() + "' "; 

            foreach (DataRow row_grid in dtGrid.Rows)
            {
                string _row_select = "PLANT = '" + plant + "' AND FAMILY = '" + family + "'" + category;

                // Get row from the grid.
                DataRow[] _drGrid = dtGrid.Select(_row_select);

                foreach (DataRow r in _drGrid)
                {
                    double _passed = Convert.ToDouble(row["PASSED"].ToString());
                    double _tested = Convert.ToDouble(row["TESTED"].ToString());
                    double _fpy = _passed / _tested;

                    r["QDMS_TESTED"] = row["TESTED"].ToString();
                    r["QDMS_PASSED"] = row["PASSED"].ToString();
                    r["QDMS_FAILED"] = row["FAILED"].ToString();
                    r["QDMS_FPY"] = _fpy.ToString("P");

                }
            }
        }
        #endregion


        #region // Get data from TRACKS View_PowerBI_MASTER_INDEX.

        sql = standard_select + 
                 ", COUNT([FAILED_INT]) [TESTED], " +
                 "COUNT([FAILED_INT]) - SUM([FAILED_INT]) [PASSED], " +
                 "SUM([FAILED_INT]) [FAILED], " +
                 "SUM([HAS_ATE_FAILURE_REPORT_INT]) [ATE_FAILURE] " +
                 "FROM [View_PowerBI_MASTER_INDEX] " +
              "WHERE " + tracks_date_range + plant_criteria + group_by + order_by;

        dt = dba.GetData(sql);


        foreach (DataRow row in dt.Rows)
        {
            plant = row["PLANT"].ToString();

            family = row["FAMILY"].ToString();

            if (include_category)
                category = " AND CATEGORY = '" + row["CATEGORY"].ToString() + "' "; 

            double _passed = Convert.ToDouble(row["PASSED"].ToString());
            double _tested = Convert.ToDouble(row["TESTED"].ToString());
            double _fpy = _passed / _tested;

            string _row_select = "PLANT = '" + plant + "' AND FAMILY = '" + family + "'" + category;
            
            // Get row from the grid.
            DataRow[] _drGrid = dtGrid.Select(_row_select);

            foreach (DataRow r in _drGrid)
            {
                r["TRACKS_TESTED"] = row["TESTED"].ToString();
                r["TRACKS_PASSED"] = row["PASSED"].ToString();
                r["TRACKS_FAILED"] = row["FAILED"].ToString();
                r["TRACKS_FPY"] = _fpy.ToString("P");
            }

        }

        #endregion


        #region // Get issue count from [Tracks].[dbo].[View_PowerBI_MASTER_INDEX_AND_ISSUE_REPORTS_COMBINED]

        sql = standard_select + 
                 ", COUNT([ISSUE_REPORTS_ID]) [ISSUE_COUNT] " +
                 "FROM [View_PowerBI_MASTER_INDEX_AND_ISSUE_REPORTS_COMBINED] " +
              "WHERE " + tracks_issues_date_range + plant_criteria + group_by + order_by;

        dt = dba.GetData(sql);

        foreach (DataRow row in dt.Rows)
        {
            plant = row["PLANT"].ToString();

            family = row["FAMILY"].ToString();

            if (include_category)
                category = " AND CATEGORY = '" + row["CATEGORY"].ToString() + "' ";

            string _row_select = "PLANT = '" + plant + "' AND FAMILY = '" + family + "'" + category;

            // Get row from the grid.
            DataRow[] _drGrid = dtGrid.Select(_row_select);


            foreach (DataRow r in _drGrid)
            {
                double _tested = Convert.ToDouble(r["TRACKS_TESTED"].ToString());

                double _issue_count = Convert.ToDouble( row["ISSUE_COUNT"].ToString() );

                double _ipu = (_issue_count / _tested);
               
                r["ISSUE_COUNT"] = _issue_count.ToString();
                r["ISSUES_PER_UNIT"] = _ipu.ToString("0.00");
              }

        }

        #endregion


        GridView1.DataSource = dtGrid;
        GridView1.DataBind();

    }



    protected void btnFind_Click(object sender, EventArgs e)
    {
        if (!IsValidDate(txtStartDate.Text)) return;
        if (!IsValidDate(txtEndDate.Text)) return;

        GetYields();
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



    protected void GridView1_DataBound(object sender, EventArgs e)
    {

        Color c = Color.Black;

        GridViewRow row = new GridViewRow(0, 0, DataControlRowType.Header, DataControlRowState.Normal);
        
        TableHeaderCell cell = new TableHeaderCell();

        cell.Text = "";
        cell.ColumnSpan = 3;
        row.Controls.Add(cell);

        // Spacer #1
        cell = new TableHeaderCell();
        cell.ColumnSpan = 1;
        cell.Text = "";
        cell.BackColor = c;
        row.Controls.Add(cell);

        cell = new TableHeaderCell();
        cell.ColumnSpan = 4;
        cell.Text = "QDMS";
        row.Controls.Add(cell);

        // Spacer #2
        cell = new TableHeaderCell();
        cell.ColumnSpan = 1;
        cell.Text = "";
        cell.BackColor = c;
        row.Controls.Add(cell);

        cell = new TableHeaderCell();
        cell.ColumnSpan = 4;
        cell.Text = "TRACKS";
        row.Controls.Add(cell);

        // Spacer #3
        cell = new TableHeaderCell();
        cell.ColumnSpan = 1;
        cell.Text = "";
        cell.BackColor = c;
        row.Controls.Add(cell);

        cell = new TableHeaderCell();
        cell.ColumnSpan = 3;
        cell.Text = "ISSUES";
        row.Controls.Add(cell);

        row.BackColor = Color.LightGray;
        //row.ForeColor = Color.White;

        GridView1.HeaderRow.Parent.Controls.AddAt(0, row);

    }
    
   
    
    protected void btnDownload_Click(object sender, EventArgs e)
    {
        if (!IsValidDate(txtStartDate.Text)) return;
        if (!IsValidDate(txtEndDate.Text)) return;

        string plant_criteria = " AND PLANT = '" + ddlPlant.Text + "' ";
        plant_criteria = " ";

        string tracks_date_range = " CAST([FIRST_TEST_DATE] AS Date) BETWEEN '" + txtStartDate.Text.ToString() + "' AND '" + txtEndDate.Text.ToString() + "' ";

        //string tracks_issues_date_range = " CAST([ISSUE_DATE] AS Date) BETWEEN '" + txtStartDate.Text.ToString() + "' AND '" + txtEndDate.Text.ToString() + "' ";

        string qdms_date_range = " CAST([StartTime] AS Date) BETWEEN '" + txtStartDate.Text.ToString() + "' AND '" + txtEndDate.Text.ToString() + "' ";

        string sql;

        //IIF ( boolean-expression, value-for-true, value-for-false )

        sql = "SELECT 'QDMS' [Source], Plant, Family, Category, SerialNumber, PartNumber, StartTime [Date], IIF(Results <> 0, 'Passed', 'Failed') [Status], '' [Note] " +
              "FROM [View_PowerBI_LINKED_QDMS_FPY] WHERE " + qdms_date_range + plant_criteria +
              "UNION " +
              "SELECT 'TRACKS' [Source], Plant, Family, Category, Serial_Number [SerialNumber], Part_Number [PartNumber], FIRST_TEST_DATE [Date], IIF([FAILED_INT] = 1, 'Failed', 'Passed') [Status], FIRST_TEST_DATE_NOTE [Note] " +
              "FROM [View_PowerBI_MASTER_INDEX] WHERE " + tracks_date_range + plant_criteria + 
              "ORDER BY Plant, Family, SerialNumber";

        DbAccess dba = new DbAccess();

        DataTable dt;

        dt = dba.GetData(sql);

        Tools t = new Tools();
        t.CreateExcelFile("yield_data.xls", ref dt);

        //GridView2.DataSource = dt;
        //GridView2.DataBind();
    }


}