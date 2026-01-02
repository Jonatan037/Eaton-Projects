using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using System.Data;
using System.Configuration;
using System.Data.SqlClient;

using System.Drawing;   // Has the definitions for colors.

//using System.Net;
//using System.IO;

using Tracks.DAL;
using System.Activities.Expressions;
using System.Activities.Statements;


public partial class Tracks_Reports_Yields : System.Web.UI.Page
{
    #region // dtGrid Column Names
    enum CN
    {
        PLANT,
        FAMILY,
        CATEGORY,

        QDMS_TESTED,
        QDMS_PASSED,
        QDMS_FAILED,
        QDMS_FPY,

        TRACKS_TESTED,
        TRACKS_PASSED,
        TRACKS_FAILED,
        TRACKS_FPY,

        ISSUE_COUNT,
        ISSUES_PER_UNIT,

        // Issue Categories
        COMPONENT,
        WORKMANSHIP,
        TEST,
        DESIGN,
        OTHER,
        UNDETERMINED,
        TROUBLESHOOTING

    }
    #endregion

    #region [Tracks].[dbo].[View_PowerBI_MASTER_INDEX_AND_ISSUE_REPORTS_COMBINED]
    /*
    SELECT TOP 1000 
           [MASTER_INDEX_ID]
          ,[PLANT]
          ,[FAMILY]
          ,[CATEGORY]
          ,[SERIAL_NUMBER]
          ,[PART_NUMBER]
          ,[FIRST_TEST_DATE]
          ,[PROBLEM_DESCRIPTION]
          ,[NOTES]
          ,[STATION_TYPE]
          ,[NONCONFORMANCE_CODE]
          ,[CLOSED]
          ,[EMPLOYEE_ID]
          ,[ISSUE_REPORTS_ID]
          ,[ISSUE_DATE]
          ,[NC_CATEGORY]
          ,[FAILURE_TREND]
          ,[ASSEMBLY_STATION]
          ,[REWORK_INSTRUCTIONS]
          ,[ROOT_CAUSE_CODE]
          ,[INCLUDE_IN_FPY_INT]
          ,[HAS_ATE_FAILURE_REPORT_INT]
          ,[HAS_ISSUE_REPORT_INT]
          ,[HAS_TEST_COMPLETE_REPORT_INT]
          ,[FAILED]
          ,[REQUIRES_ATE_RECORD_INT]
          ,[LAST_TEST_STATUS_INT]
      FROM [Tracks].[dbo].[View_PowerBI_MASTER_INDEX_AND_ISSUE_REPORTS_COMBINED]
    */
    #endregion

    #region [Tracks].[dbo].[View_PowerBI_QDMS_INDEX_VIEW]
    /*
    SELECT TOP 1000 
           [Record Type]
          ,[INDEXID]
          ,[HAS_NCR_TEST_COMPLETE_RECORD]
          ,[DBID]
          ,[Plant]
          ,[RecordType]
          ,[PartNumber]
          ,[SerialNumber]
          ,[StartTime]
          ,[Sequence]
          ,[Results]
          ,[ProgramName]
          ,[TrackingNumber]
          ,[ProgramPath]
          ,[MfgLine]
          ,[ComputerName]
          ,[ResultsID]
          ,[ProgramID]
          ,[ElapsedTime]
          ,[Fixture]
          ,[RunMode]
          ,[TotalErrors]
          ,[TestResult]
          ,[TestType]
          ,[PreTestResult]
          ,[Temp]
          ,[FirstPass]
          ,[Info1Item]
          ,[Info2Item]
          ,[Info3Item]
          ,[Info4Item]
          ,[Info5Item]
          ,[Info6Item]
          ,[Info7Item]
          ,[Info8Item]
          ,[Info9Item]
          ,[Info10Item]
          ,[Family]
          ,[Category]
          ,[Description]
          ,[TestStep]
          ,[ResultsData]
          ,[StartDate]
          ,[EmployeeID]
      FROM [Tracks].[dbo].[View_PowerBI_QDMS_INDEX_VIEW]      
    */
    #endregion

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            txtStartDate.Text = DateTime.Now.ToShortDateString();
            txtEndDate.Text = DateTime.Now.ToShortDateString();

            GetYields();


        }
    }

    
    
    private void GetYields()
    {
        #region // Initialize

        DbAccess dba = new DbAccess();

        DataTable dt; // muliple use data table.

        bool include_category = cbCategory.Checked;

        bool include_qdms = cbQDMS.Checked;

        bool include_failure_analysis = cbFailureAnalysis.Checked;

        string standard_select = "SELECT Plant, Family, ' ' [Category] ";

        string group_by = " GROUP BY PLANT, FAMILY ";

        string order_by = "ORDER BY PLANT, FAMILY ";

        string plant_criteria = " AND PLANT = '" + ddlPlant.Text + "' ";

        string tracks_date_range = " CAST([FIRST_TEST_DATE] AS Date) BETWEEN '" + txtStartDate.Text.ToString() + "' AND '" + txtEndDate.Text.ToString() + "' ";

        string tracks_issues_date_range = " CAST([ISSUE_DATE] AS Date) BETWEEN '" + txtStartDate.Text.ToString() + "' AND '" + txtEndDate.Text.ToString() + "' ";

        string qdms_date_range = " CAST([StartTime] AS Date) BETWEEN '" + txtStartDate.Text.ToString() + "' AND '" + txtEndDate.Text.ToString() + "' ";

        string pcatKitting_Filter = "(SERIAL_NUMBER NOT LIKE 'P[0-9]%' OR SERIAL_NUMBER LIKE 'P[0-9]%[^0-9]') AND ";

        string sql = "";

        string plant = "";
        string family = "";
        string category = "";


        if (ddlPlant.Text == "ALL") plant_criteria = " ";


        // Should failure analysis families be excluded?
        if (!include_failure_analysis)
        {
            plant_criteria += " AND ( FAMILY NOT LIKE '%Failure Analysis' ) ";
        }



        if (include_category)
        {
            standard_select = "SELECT Plant, Family, Category ";
            group_by = " GROUP BY PLANT, FAMILY, CATEGORY ";
            order_by = "ORDER BY PLANT, FAMILY, CATEGORY ";
        }

        #endregion


        #region // Build dtGrid

        /*
        // Get all family names.
        // No longer used.
        sql = standard_select + " FROM [View_PowerBI_LINKED_QDMS_FPY] WHERE " + qdms_date_range + plant_criteria + group_by +
              "UNION " +
              standard_select + " FROM [View_PowerBI_MASTER_INDEX] WHERE " + tracks_date_range + plant_criteria + group_by +
              order_by;
        */


        sql = standard_select + " FROM [View_PowerBI_MASTER_INDEX] WHERE " + pcatKitting_Filter + tracks_date_range + plant_criteria + group_by + order_by;

        /*
        //No longer used.
        if (include_qdms)
        {
            sql = standard_select + " FROM [View_PowerBI_LINKED_QDMS_FPY] WHERE " + qdms_date_range + plant_criteria + group_by + " UNION " + sql;
        }
        */

        DataTable dtGrid = dba.GetData(sql);




        /*
        // delete kitting data or rows

        // Define the criteria for deletion using regex
        string pattern = @"^P[1-5]+$";

        // Loop through the rows and delete the ones that match the criteria
        for (int i = dtGrid.Rows.Count - 1; i >= 0; i--)
        {
            DataRow row = dtGrid.Rows[i];
            if (System.Text.RegularExpressions.Regex.IsMatch(row["Serial_Number"].ToString(), pattern))
            {
                dtGrid.Rows.Remove(row);
            }
        }
       */





        dtGrid.Columns.Add( CN.QDMS_TESTED.ToString() );
        dtGrid.Columns.Add( CN.QDMS_PASSED.ToString() );
        dtGrid.Columns.Add( CN.QDMS_FAILED.ToString() );
        dtGrid.Columns.Add(CN.QDMS_FPY.ToString() );

        dtGrid.Columns.Add(CN.TRACKS_TESTED.ToString() );
        dtGrid.Columns.Add(CN.TRACKS_PASSED.ToString() );
        dtGrid.Columns.Add(CN.TRACKS_FAILED.ToString() );
        dtGrid.Columns.Add(CN.TRACKS_FPY.ToString() );

        dtGrid.Columns.Add(CN.ISSUE_COUNT.ToString() );
        dtGrid.Columns.Add(CN.ISSUES_PER_UNIT.ToString() );

        dtGrid.Columns.Add(CN.COMPONENT.ToString() );
        dtGrid.Columns.Add(CN.WORKMANSHIP.ToString() );
        dtGrid.Columns.Add(CN.TEST.ToString() );
        dtGrid.Columns.Add(CN.DESIGN.ToString() );
        dtGrid.Columns.Add(CN.OTHER.ToString() );
        dtGrid.Columns.Add(CN.UNDETERMINED.ToString() );
        dtGrid.Columns.Add(CN.TROUBLESHOOTING.ToString() );


        #endregion


        #region // Get data from YPO QDMS View_PowerBI_LINKED_QDMS_FPY.

        if (include_qdms)
        {


            sql = standard_select +
                     ", COUNT(Results) [TESTED], " +
                     "SUM( ABS(Results) ) [PASSED], " +
                     "COUNT(Results) - SUM( ABS(Results) ) [FAILED] " +
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

                        r[ CN.QDMS_TESTED.ToString() ] = row["TESTED"].ToString();
                        r[ CN.QDMS_PASSED.ToString() ] = row["PASSED"].ToString();
                        r[ CN.QDMS_FAILED.ToString() ] = row["FAILED"].ToString();
                        r[ CN.QDMS_FPY.ToString() ] = _fpy.ToString("P");

                    }
                }
            }
        } //if (INCLUDE_QDMS)

        #endregion


        #region // Get data from TRACKS View_PowerBI_MASTER_INDEX.

        sql = standard_select + 
                 ", COUNT([FAILED]) [TESTED], " +
                 "COUNT([FAILED]) - SUM([FAILED]) [PASSED], " +
                 "SUM([FAILED]) [FAILED] " +
                 //"SUM([HAS_ATE_FAILURE_REPORT_INT]) [ATE_FAILURE] " +
                 "FROM [View_PowerBI_MASTER_INDEX] " +
              "WHERE " + pcatKitting_Filter + tracks_date_range + plant_criteria + group_by + order_by;

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
                r[ CN.TRACKS_TESTED.ToString() ] = row["TESTED"].ToString();
                r[ CN.TRACKS_PASSED.ToString() ] = row["PASSED"].ToString();
                r[ CN.TRACKS_FAILED.ToString() ] = row["FAILED"].ToString();
                r[CN.TRACKS_FPY.ToString()] = _fpy.ToString("P");
            }

        }

        #endregion


        #region // Get issue count from [Tracks].[dbo].[View_PowerBI_MASTER_INDEX_AND_ISSUE_REPORTS_COMBINED]
        /*
        sql = standard_select + 
                 ", [NC_CATEGORY], COUNT(NC_CATEGORY) AS [TOTAL] " +
                 "FROM View_PowerBI_MASTER_INDEX_AND_ISSUE_REPORTS_COMBINED " +
                 "WHERE " + tracks_date_range + plant_criteria +
                 group_by + " ,NC_CATEGORY ";
        */

        sql = standard_select +
                 ", [NC_CATEGORY], COUNT(NC_CATEGORY) AS [TOTAL] " +
                 "FROM View_PowerBI_MASTER_INDEX_AND_ISSUE_REPORTS_COMBINED " +
                 "WHERE " + pcatKitting_Filter + "(" + tracks_date_range + " OR " + tracks_issues_date_range + ") "+ plant_criteria +
                 group_by + " ,NC_CATEGORY ";



        string crosstab = "";

        crosstab = standard_select + " , [COMPONENT], [WORKMANSHIP], [TEST], [DESIGN], [OTHER], [UNDETERMINED], [Troubleshooting] " +
                    "FROM (" + sql + ") ps " +
                    "PIVOT " +
                    "( " +
                       "SUM (TOTAL) " +
                       "FOR NC_CATEGORY IN ([COMPONENT], [WORKMANSHIP], [TEST], [DESIGN], [OTHER], [UNDETERMINED], [Troubleshooting]) " +
                    ") AS pvt";

        dt = dba.GetData(crosstab);
        
        
        foreach (DataRow row in dt.Rows)
        {
            plant = "PLANT = '" + row["PLANT"].ToString() + "'";
            //plant = row["PLANT"].ToString();


            //family = row["FAMILY"].ToString();
            family = " AND FAMILY = '" + row["FAMILY"].ToString() + "' ";

            if (include_category)
                category = " AND CATEGORY = '" + row["CATEGORY"].ToString() + "' ";

            string _row_select = plant +  family  + category;

            // Get row from the grid.
            DataRow[] _drGrid = dtGrid.Select(_row_select);

            // Get the range of columns that contain the issue data.
            int col_first_issue = dt.Columns["Component"].Ordinal;
            int col_last_issue = dt.Columns.Count - 1;

            foreach (DataRow r in _drGrid)
            {
                double _tested = ConvertToDouble(r[ CN.TRACKS_TESTED.ToString() ].ToString());

                double _issue_count = 0;

                for (int ctr = col_first_issue; ctr <= col_last_issue; ctr++ )
                {
                    _issue_count += ConvertToDouble( row[ctr].ToString() );
                }

                double _ipu = 0;
                if (_tested != 0) _ipu = (_issue_count / _tested);

                if (_issue_count != 0)
                {
                    r[ CN.ISSUE_COUNT.ToString() ] = _issue_count.ToString();
                    
                    if (_ipu != 0)
                        r[ CN.ISSUES_PER_UNIT.ToString() ] = _ipu.ToString("0.00");
                }

                // Put the issue count data in the proper grid row.
                for (CN i = CN.COMPONENT; i <= CN.TROUBLESHOOTING; i++ )
                {
                    r[ i.ToString() ] = row[ i.ToString() ].ToString();
                }

            }

        }

        #endregion


        #region // Calculate column totals.
        if (ddlPlant.SelectedValue != "ALL")
        {
            // Blank row
            DataRow new_row = dtGrid.NewRow();
            dtGrid.Rows.Add(new_row);

            new_row = dtGrid.NewRow();
            
            new_row[ CN.PLANT.ToString() ] = ddlPlant.SelectedValue;

            GetColumnTotal(ref new_row, dtGrid, CN.QDMS_TESTED );
            GetColumnTotal(ref new_row, dtGrid, CN.QDMS_PASSED );
            GetColumnTotal(ref new_row, dtGrid, CN.QDMS_FAILED );
            Divide(ref new_row, CN.QDMS_PASSED, CN.QDMS_TESTED, CN.QDMS_FPY, "P");

            GetColumnTotal(ref new_row, dtGrid, CN.TRACKS_TESTED );
            GetColumnTotal(ref new_row, dtGrid, CN.TRACKS_PASSED );
            GetColumnTotal(ref new_row, dtGrid, CN.TRACKS_FAILED );
            Divide(ref new_row, CN.TRACKS_PASSED, CN.TRACKS_TESTED, CN.TRACKS_FPY, "P");

            GetColumnTotal(ref new_row, dtGrid, CN.COMPONENT );
            GetColumnTotal(ref new_row, dtGrid, CN.WORKMANSHIP );
            GetColumnTotal(ref new_row, dtGrid, CN.TEST );
            GetColumnTotal(ref new_row, dtGrid, CN.DESIGN );
            GetColumnTotal(ref new_row, dtGrid, CN.OTHER );
            GetColumnTotal(ref new_row, dtGrid, CN.UNDETERMINED );
            GetColumnTotal(ref new_row, dtGrid, CN.TROUBLESHOOTING );

            GetColumnTotal(ref new_row, dtGrid, CN.ISSUE_COUNT );
            Divide(ref new_row, CN.ISSUE_COUNT, CN.TRACKS_TESTED, CN.ISSUES_PER_UNIT, "0.00");

            dtGrid.Rows.Add(new_row);

        }
        #endregion


        #region // Configure gvYields
        gvYields.DataSource = dtGrid;

        // Show/Hide QDMS columns if necessary
        for (int ctr = 3; ctr <= 8; ctr++ )
            gvYields.Columns[ctr].Visible = include_qdms;

        // Hide QDMS yields
        //gvYields.Columns[5].Visible = false;
        //gvYields.Columns[6].Visible = false;
        //gvYields.Columns[7].Visible = false;

        // category
        gvYields.Columns[2].Visible = include_category;

        gvYields.DataBind();

        gvIssues.DataSource = null;
        gvIssues.DataBind();
        lnkIssues.Text = "";

        gvHistory.DataSource = null;
        gvHistory.DataBind();
        lnkHistory.Text = "";
        #endregion
        
    }


    
    private void Divide(ref DataRow Row, CN Numerator, CN Denominator, CN Destination, string FormatSpecifier)
    {
        double result = 0;

        double n = ConvertToDouble( Row[ Numerator.ToString() ].ToString());
        double d = ConvertToDouble( Row[ Denominator.ToString() ].ToString());

        if (d != 0) 
            result = n / d;

        if (result != 0) 
            Row[ Destination.ToString() ] = result.ToString(FormatSpecifier);

    }

    
    
    private void GetColumnTotal(ref DataRow Row, DataTable Table, CN Column)
    {
        double total = 0;

        foreach (DataRow row in Table.Rows)
        {
            total += ConvertToDouble( row[ Column.ToString() ].ToString() );
        }

        if (total != 0)
            Row[ Column.ToString() ] = total.ToString();
    }

    
    
    private double ConvertToDouble(string value)
    {
        if (value != "")
            return Convert.ToDouble(value);
        else
            return 0;
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



   
    
    protected void btnDownload_Click(object sender, EventArgs e)
    {
        if (!IsValidDate(txtStartDate.Text)) return;
        if (!IsValidDate(txtEndDate.Text)) return;

        string plant_criteria = " AND PLANT = '" + ddlPlant.Text + "' ";
        plant_criteria = " ";

        string tracks_date_range = " CAST([FIRST_TEST_DATE] AS Date) BETWEEN '" + txtStartDate.Text.ToString() + "' AND '" + txtEndDate.Text.ToString() + "' ";

        //string tracks_issues_date_range = " CAST([ISSUE_DATE] AS Date) BETWEEN '" + txtStartDate.Text.ToString() + "' AND '" + txtEndDate.Text.ToString() + "' ";

        string qdms_date_range = " CAST([StartTime] AS Date) BETWEEN '" + txtStartDate.Text.ToString() + "' AND '" + txtEndDate.Text.ToString() + "' ";

        string pcatKitting_Filter = "(SERIAL_NUMBER NOT LIKE 'P[0-9]%' OR SERIAL_NUMBER LIKE 'P[0-9]%[^0-9]') AND ";

        string sql;

        //IIF ( boolean-expression, value-for-true, value-for-false )

        /*
        sql = "SELECT 'QDMS' [Source], Plant, Family, Category, SerialNumber, PartNumber, StartTime [Date], IIF(Results <> 0, 'Passed', 'Failed') [Status], '' [Note], Description " +
              "FROM [View_PowerBI_LINKED_QDMS_FPY] WHERE " + qdms_date_range + plant_criteria +
              "UNION " +
              "SELECT 'TRACKS' [Source], Plant, Family, Category, Serial_Number [SerialNumber], Part_Number [PartNumber], FIRST_TEST_DATE [Date], IIF([FAILED] = 1, 'Failed', 'Passed') [Status], FIRST_TEST_DATE_NOTE [Note], Description " +
              "FROM [View_PowerBI_MASTER_INDEX] WHERE " + tracks_date_range + plant_criteria + 
              "ORDER BY Plant, Family, SerialNumber";
        */

        sql = "SELECT 'TRACKS' [Source], Plant, Family, Category, Serial_Number [SerialNumber], Part_Number [PartNumber], FIRST_TEST_DATE [Date], IIF([FAILED] = 1, 'Failed', 'Passed') [Status], FIRST_TEST_DATE_NOTE [Note], Description " +
              "FROM [View_PowerBI_MASTER_INDEX] WHERE " + pcatKitting_Filter + tracks_date_range + plant_criteria +
              "ORDER BY Plant, Family, SerialNumber";

        DbAccess dba = new DbAccess();

        DataTable dt;

        dt = dba.GetData(sql);

        Tools t = new Tools();
        t.CreateExcelFile("yield_data.xls", ref dt);

        //GridView2.DataSource = dt;
        //GridView2.DataBind();
    }



    protected void gvYields_RowCommand(object sender, GridViewCommandEventArgs e)
    {            
        DbAccess dba = new DbAccess();

        string qdms_date_range = " CAST([StartTime] AS Date) BETWEEN '" + txtStartDate.Text.ToString() + "' AND '" + txtEndDate.Text.ToString() + "' ";

        string tracks_date_range = " CAST([FIRST_TEST_DATE] AS Date) BETWEEN '" + txtStartDate.Text.ToString() + "' AND '" + txtEndDate.Text.ToString() + "' ";
        
        string tracks_issues_date_range = " CAST([ISSUE_DATE] AS Date) BETWEEN '" + txtStartDate.Text.ToString() + "' AND '" + txtEndDate.Text.ToString() + "' ";

        string date_range = " (" + tracks_date_range + " OR " + tracks_issues_date_range + ") ";

        string pcatKitting_Filter = "(SERIAL_NUMBER NOT LIKE 'P[0-9]%' OR SERIAL_NUMBER LIKE 'P[0-9]%[^0-9]') AND ";

        string sql = "";
        string criteria = "";

        // Get the index number of the row on which the button was located.
        int index = Convert.ToInt32(e.CommandArgument);
        gvYields.SelectedIndex = index;

        // Get the data key values.
        string plant = gvYields.DataKeys[index].Values["PLANT"].ToString();
        string family = gvYields.DataKeys[index].Values["FAMILY"].ToString();
        string category = gvYields.DataKeys[index].Values["CATEGORY"].ToString();

        category = category.Trim();


        #region Issue commands
        if (e.CommandName.Substring(0, 6) == "Issues")
        {
            // Always include plant.
            criteria = " AND ( PLANT = '" + plant + "' ) ";

            // Default statement.
            sql = "SELECT " +
                      "SERIAL_NUMBER, " +
                      "PART_NUMBER, " +
                      "ISSUE_DATE, " +
                      "PROBLEM_DESCRIPTION, " +
                      "NOTES, " +
                      "NONCONFORMANCE_CODE, " +
                      "NC_CATEGORY, " +
                      "STATION_TYPE, " +
                      "EMPLOYEE_ID " +
                "FROM View_PowerBI_MASTER_INDEX_AND_ISSUE_REPORTS_COMBINED " +
                 "WHERE " + pcatKitting_Filter + date_range;


            switch (e.CommandName)
            {
                case "Issues_Family":
                    criteria += " AND ( FAMILY = '" + family + "' ) ";
                    break;

                case "Issues_Category":
                    criteria += " AND ( FAMILY = '" + family + "' ) AND ( CATEGORY = '" + category + "' ) ";
                    break;

                default:
                    break;
            }


            if (e.CommandName.Substring(0, 9) == "Issues_NC")
            {
                if ( (category == "") && (family == "") )
                { }
                else if (category == "")
                    criteria += " AND ( FAMILY = '" + family + "' ) ";
                else
                    criteria += " AND ( FAMILY = '" + family + "' ) AND ( CATEGORY = '" + category + "' ) ";

                if (e.CommandName != "Issues_NC_Total")
                {
                    criteria += " AND ( NC_CATEGORY = '" + e.CommandName.Substring(10) + "' ) ";
                }
            }

            sql += criteria + "ORDER BY 1,2,3";


            gvIssues.DataSource = dba.GetData(sql);
            gvIssues.DataBind();

            lnkIssues.Text = "SHOWING ISSUES FOR ( DATE BETWEEN " + txtStartDate.Text + " AND " + txtEndDate.Text + " )" + criteria;
            lnkIssues.Focus();
        }
        #endregion

        #region HISTORY commands
        if (e.CommandName == "History")
        {
            // Always include plant.
            criteria = " AND ( PLANT = '" + plant + "' ) ";

            if (family != "")
                criteria = " AND ( PLANT = '" + plant + "' ) AND ( FAMILY = '" + family + "' ) ";

            if (category != "")
            {
                criteria += "  AND ( CATEGORY = '" + category + "' ) ";
            }

            /*
                        sql = "" +
                            "SELECT " +
                                "SERIAL_NUMBER [SerialNumber], " +
                                "FIRST_TEST_DATE [Date], " +
                                "'TRACKS' [Source], " +
                                "PLANT [Plant], " +
                                "FAMILY [Family], " +
                                "CATEGORY [Category], " +
                                "PART_NUMBER [PartNumber], " +
                                "IIF( [FAILED] = 1, 'Failed', 'Passed') [Status], " +
                                "'Tracks' [RecordType], " +
                                "REPLACE(FIRST_TEST_DATE_NOTE, 'FIRST_TEST_DATE is from ', 'Date from ') [Note], " +
                                "0 [DBID], " +
                                "MASTER_INDEX_ID [IndexID], " +
                                "0[ResultsID] " +
                            "FROM View_PowerBI_MASTER_INDEX WHERE " + tracks_date_range + criteria +
                            "UNION " +
                            "SELECT " +
                                "SerialNumber [SerialNumber], " +
                                "StartDate [Date], " +
                                "'QDMS' [Source], " +
                                "PLANT [Plant], " +
                                "FAMILY [Family], " +
                                "CATEGORY [Category], " +
                                "PartNumber [PartNumber], " +
                                "[TestResult] [Status], " +
                                "[Record Type] [RecordType], " +
                                "'' [Note], " +
                                "DBID [DBID], " +
                                "INDEXID[IndexID], " +
                                "ResultsID [ResultsID] " +
                            "FROM [View_PowerBI_QDMS_INDEX_VIEW] WHERE " + qdms_date_range + criteria ;
            */

            // Default statement.
            sql = "" +
                "SELECT " +
                    "SERIAL_NUMBER [SerialNumber], " +
                    "FIRST_TEST_DATE [Date], " +
                    "'TRACKS' [Source], " +
                    "PLANT [Plant], " +
                    "FAMILY [Family], " +
                    "CATEGORY [Category], " +
                    "PART_NUMBER [PartNumber], " +
                    "IIF( [FAILED] = 1, 'Failed', 'Passed') [Status], " +
                    "'Tracks' [RecordType], " +
                    "REPLACE(FIRST_TEST_DATE_NOTE, 'FIRST_TEST_DATE is from ', 'Date from ') [Note], " +
                    "0 [DBID], " +
                    "MASTER_INDEX_ID [IndexID], " +
                    "0[ResultsID] " +
                "FROM View_PowerBI_MASTER_INDEX WHERE " + pcatKitting_Filter + tracks_date_range + criteria;


                sql += "ORDER BY [SerialNumber], [Date]";


            gvHistory.DataSource = dba.GetData(sql);
            gvHistory.DataBind();

            lnkHistory.Text = "SHOWING TEST HISTORY FOR ( DATE BETWEEN " + txtStartDate.Text + " AND " + txtEndDate.Text + " )" + criteria;
            lnkHistory.Focus();
        }
        #endregion

    }
    
    
    
    protected void btnResetDates_Click(object sender, EventArgs e)
    {
        txtStartDate.Text = DateTime.Now.ToShortDateString();
        txtEndDate.Text = DateTime.Now.ToShortDateString();

        GetYields();
    }


   
    
    protected void gvHistory_RowCommand(object sender, GridViewCommandEventArgs e)
    {

        // Get the index number of the row on which the button was located.
        int index = Convert.ToInt32(e.CommandArgument);

        string redirect = "";

        // Reset the grid rows to default background colors.
        for (int ctr = 0; ctr < gvHistory.Rows.Count; ctr ++ )
        {
            if (ctr % 2 == 0)
                gvHistory.Rows[ctr].BackColor = Color.White;
            else
                gvHistory.Rows[ctr].BackColor = Color.LightGray;
        }

        // Set the selected row background.
        gvHistory.Rows[index].BackColor = Color.Yellow;

        // Get the data key values.
        string serial_number = gvHistory.DataKeys[index].Values["SerialNumber"].ToString();
        string dbid = gvHistory.DataKeys[index].Values["DBID"].ToString();
        string index_id = gvHistory.DataKeys[index].Values["IndexID"].ToString();
        string results_id = gvHistory.DataKeys[index].Values["ResultsID"].ToString();
        string record_type = gvHistory.DataKeys[index].Values["RecordType"].ToString();


        if (dbid == "0")
        {
            Session[DbAccess.SessionVariableName.SERIAL_NUMBER.ToString()] = serial_number;

            redirect = "<script>window.open('Search');</script>";
            Response.Write(redirect);

        }
        else
        {
            Session[DbAccess.SessionVariableName.REPORT_DBID.ToString()] = dbid;
            Session[DbAccess.SessionVariableName.REPORT_RESULTS_ID.ToString()] = results_id;

            redirect = "<script>window.open('Support/Support_Yields_Test_Report');</script>";
            Response.Write(redirect);

        }


    }
    
    
    
    protected void gvIssues_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        // Get the index number of the row on which the button was located.
        int index = Convert.ToInt32(e.CommandArgument);

        string redirect = "";

        // Reset the grid rows to default background colors.
        for (int ctr = 0; ctr < gvIssues.Rows.Count; ctr++)
        {
            if (ctr % 2 == 0)
                gvIssues.Rows[ctr].BackColor = Color.White;
            else
                gvIssues.Rows[ctr].BackColor = Color.LightGray;
        }

        // Set the selected row background.
        gvIssues.Rows[index].BackColor = Color.Yellow;

        // Get the data key values.
        string serial_number = gvIssues.DataKeys[index].Values["SERIAL_NUMBER"].ToString();

        Session[DbAccess.SessionVariableName.SERIAL_NUMBER.ToString()] = serial_number;

        redirect = "<script>window.open('Search');</script>";
        Response.Write(redirect);

    }
}