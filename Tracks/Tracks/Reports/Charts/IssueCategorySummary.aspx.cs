using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using System.Data;
using System.Configuration;
using System.Data.SqlClient;

using System.Web.UI.DataVisualization.Charting;

using Tracks.DAL;

public partial class Tracks_Reports_Charts_IssueCategorySummary : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {


        if (!IsPostBack)
        {

            DateTime now = DateTime.Now;

            txtStartDate.Text = now.AddDays(-30).ToShortDateString();
            txtEndDate.Text = now.ToShortDateString();


            GetLineNames();

            // Get station types.
            DbAccess DB = new DbAccess();
            DB.PopulateDropDownList(ddlStationType, DbAccess.DropListType.ISSUE_REPORTS_CT_STATION_TYPE);
            ListItem item = new ListItem("ALL", "ALL");
            ddlStationType.Items.Insert(0, item);
        }

        PopulateChart();
    }

    private void GetLineNames()
    {

        string sql;

        sql = "SELECT FAMILY FROM MASTER_INDEX " +
              "WHERE " +
                 "PLANT LIKE '" + ddlPlants.SelectedItem + "%' " +
                 "AND FAMILY NOT LIKE '%Failure Analysis%' " +
              "GROUP BY FAMILY ORDER BY FAMILY";

        DbAccess DB = new DbAccess();

        ddlLineName.DataSource = DB.GetData(sql);
        ddlLineName.DataTextField = "FAMILY";

        ddlLineName.DataValueField = "FAMILY";

        ddlLineName.DataBind();
        
        ListItem item = new ListItem("ALL", "ALL");
        ddlLineName.Items.Insert(0, item);


    }
    

    private string GetDateRange(ref string Title)
    {
        string date_range = "";


        // Start of title
        Title = ddlPlants.SelectedItem + " Issue Category Summary From ";

        if (txtStartDate.Text == txtEndDate.Text)
            Title += txtStartDate.Text;
        else
            Title += txtStartDate.Text + " To " + txtEndDate.Text;

        date_range = " (CAST(ISSUE_REPORTS.CREATION_TIMESTAMP AS Date) BETWEEN '" + txtStartDate.Text.ToString() + "' AND '" + txtEndDate.Text.ToString() + "') ";

        //lblDebug.Text = date_range;
        return date_range;
    }




    private DataTable GetData(ref string Title)
    {
        DbAccess db = new DbAccess();
        DataTable dt;
        string sql = "";
        string crosstab = "";
        DateTime date_start = DateTime.Now;
        DateTime date_end = DateTime.Now;

        string station_type = ddlStationType.SelectedItem.ToString();
        string station_type_criteria = " ";

        string line_name = ddlLineName.SelectedItem.ToString();
        string line_name_criteria = " ";

        string date_range = GetDateRange(ref Title);

        string pcatKitting_Filter = "(SERIAL_NUMBER NOT LIKE 'P[0-9]%' OR SERIAL_NUMBER LIKE 'P[0-9]%[^0-9]') AND ";

        if (station_type != "ALL")
        {
            station_type_criteria = " AND STATION_TYPE = '" + station_type + "' ";
        }


        if (line_name != "ALL")
        {
            line_name_criteria = " AND MASTER_INDEX.FAMILY = '" + line_name + "' ";
        }

        sql = "SELECT " +
                        "MASTER_INDEX.PLANT, " +
                        "MASTER_INDEX.FAMILY, " +
                        "ISSUE_REPORTS_CT_NONCONFORMANCE_CODE.CATEGORY, " +
                        "COUNT(ISSUE_REPORTS_CT_NONCONFORMANCE_CODE.CATEGORY) AS [TOTAL] " +
                        "FROM " +
                            "MASTER_INDEX INNER JOIN " +
                            "(ISSUE_REPORTS INNER JOIN ISSUE_REPORTS_CT_NONCONFORMANCE_CODE ON ISSUE_REPORTS.NONCONFORMANCE_CODE = ISSUE_REPORTS_CT_NONCONFORMANCE_CODE.DESCRIPTION) " +
                            "ON MASTER_INDEX.MASTER_INDEX_ID = ISSUE_REPORTS.MASTER_INDEX_ID " +
                        "WHERE MASTER_INDEX.PLANT LIKE '" + ddlPlants.SelectedItem + "%'  AND " + pcatKitting_Filter + date_range + station_type_criteria + line_name_criteria + " AND FAMILY NOT LIKE '%Failure Analysis%' " +
                        "GROUP BY MASTER_INDEX.PLANT, MASTER_INDEX.FAMILY, ISSUE_REPORTS_CT_NONCONFORMANCE_CODE.CATEGORY ";



        crosstab = "SELECT FAMILY, [COMPONENT], [WORKMANSHIP], [TEST], [DESIGN], [OTHER], [UNDETERMINED], [TROUBLESHOOTING], [XTOTAL] " +
                    "FROM (" + sql +") ps " +
                    "PIVOT " + 
                    "( " +
                       "SUM (TOTAL) " +
                       "FOR CATEGORY IN ([COMPONENT], [WORKMANSHIP], [TEST], [DESIGN], [OTHER], [UNDETERMINED], [TROUBLESHOOTING], [XTOTAL]) " +
                    ") AS pvt";



        //lblDebug.Text = crosstab;

        dt = db.GetData(crosstab);

        // Need zeros instead of blank spaces.
        foreach (DataRow row in dt.Rows)
        {
            foreach (DataColumn col in dt.Columns)
            {
                if (row[col].ToString() == "") row[col] = "0";
            }
        }

        // Calculate totals.
        int total;
        foreach (DataRow row in dt.Rows)
        {
            total = 0;

            foreach (DataColumn col in dt.Columns)
            {
                if ( (col.ColumnName != "XTOTAL") && (col.ColumnName != "FAMILY") )
                    total +=  int.Parse(row[col].ToString());
         
            }

            row["XTOTAL"] = total.ToString();
        }

        return dt;
        //return db.GetData(sql);
    }



    protected void PopulateChart()
    {
        //string[] categories = new string[] {"COMPONENT", "WORKMANSHIP", "TEST", "DESIGN", "OTHER", "XTOTAL"};
        string[] categories = new string[] { "COMPONENT", "WORKMANSHIP", "TEST", "DESIGN", "OTHER", "UNDETERMINED",  "TROUBLESHOOTING" };

        DataTable dt;
        string title = "";

        dt = GetData(ref title);

        int result = 0;

        int i = 0;

        if (dt.Rows.Count == 0) return;

        // Show data in grid for troubleshooting.
        GridView1.DataSource = dt;
        GridView1.DataBind();


        Chart1.Titles["Title1"].Text = title;

        foreach (string category in categories)
        {
            Chart1.Series.Add(new Series(category));
            Chart1.Series[category].ChartType = SeriesChartType.StackedColumn;

            i = 0;

            foreach (DataRow row in dt.Rows)
            {
                i++;

                result = Int32.Parse(row[category].ToString().Trim());


                //Chart1.Series[category].Points.Add(new DataPoint(i, result));
                Chart1.Series[category].Points.Add( new DataPoint( i, result ) );
                //Chart1.Series[category].Points.Add(new DataPoint(result, row["FAMILY"].ToString() ));

                Chart1.Series[category].IsValueShownAsLabel = true;

                // causes all labels to be the last family
                //Chart1.Series[category].AxisLabel = row["FAMILY"].ToString();          


                if (category == "XTOTAL")
                {
                    Chart1.Series[category].Color = System.Drawing.Color.Transparent;
                    Chart1.Series[category].IsVisibleInLegend = false;

                }

            }

        }

        // Hide label value if zero
        foreach (Series series in Chart1.Series)
        {
            foreach (DataPoint point in series.Points)
            {
                if (point.YValues.Length > 0 && (double)point.YValues.GetValue(0) == 0)
                {
                    point.IsValueShownAsLabel = false;
                }
                else
                {
                    point.IsValueShownAsLabel = true;
                }
            }
        }

        // --------------------------------------------------------------------------------------
        // Show x-axis labels.
        i = 0;
        foreach (DataPoint point in Chart1.Series[0].Points)
        {
            //point.AxisLabel = dt.Rows[i]["FAMILY"].ToString();
            point.AxisLabel = dt.Rows[i]["FAMILY"].ToString() + " (" + dt.Rows[i]["XTOTAL"].ToString() + ")";
             i++;
        }

        // --------------------------------------------------------------------------------------
        // Create a summary title.
        title = "";
        int overall_total = 0;

        foreach (string category in categories)
        {
            int total = 0;

            foreach (DataRow row in dt.Rows)
            {
                result = Int32.Parse(row[category].ToString().Trim());
                total += result;
            }

            overall_total += total;

            title += category + " (" + total.ToString() + ")  ";
        }
        
        Chart1.Titles["Title2"].Text = title;

        Chart1.Titles["Title3"].Text = "OVERALL TOTAL (" + overall_total.ToString() + ")";


        // --------------------------------------------------------------------------------------
        // Turn off the x-axis grid line.
        Chart1.ChartAreas["ChartArea1"].AxisX.MajorGrid.Enabled = false;
        Chart1.ChartAreas["ChartArea1"].AxisX.MinorGrid.Enabled = false;

        Chart1.ChartAreas["ChartArea1"].AxisY.MajorGrid.Enabled = false;

    }



    protected void btnFind_Click(object sender, EventArgs e)
    {
        if (!IsValidDate(txtStartDate.Text)) return;
        if (!IsValidDate(txtEndDate.Text)) return;
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

        DataTable dt;
        string sql = "";
        string title = "";

        string date_range = GetDateRange(ref title);

        string pcatKitting_Filter = "(SERIAL_NUMBER NOT LIKE 'P[0-9]%' OR SERIAL_NUMBER LIKE 'P[0-9]%[^0-9]') AND ";

        sql = "SELECT " +
                        "MASTER_INDEX.PLANT, " +
                        "MASTER_INDEX.FAMILY, " +
                        "MASTER_INDEX.CATEGORY, " +
                        "MASTER_INDEX.SERIAL_NUMBER, " +
                        "MASTER_INDEX.PART_NUMBER, " +
                        "MASTER_INDEX.DESCRIPTION, " +
                        "ISSUE_REPORTS_CT_NONCONFORMANCE_CODE.CATEGORY AS [NC_CATEGORY], " +
                        "ISSUE_REPORTS.CREATION_TIMESTAMP " +
                        "FROM " +
                            "MASTER_INDEX INNER JOIN " +
                            "(ISSUE_REPORTS INNER JOIN ISSUE_REPORTS_CT_NONCONFORMANCE_CODE ON ISSUE_REPORTS.NONCONFORMANCE_CODE = ISSUE_REPORTS_CT_NONCONFORMANCE_CODE.DESCRIPTION) " +
                            "ON MASTER_INDEX.MASTER_INDEX_ID = ISSUE_REPORTS.MASTER_INDEX_ID " +
                        "WHERE " + pcatKitting_Filter + date_range +
                        "ORDER BY  PLANT, FAMILY, CATEGORY, SERIAL_NUMBER";




        DbAccess db = new DbAccess();
        dt = db.GetData(sql);

        Tools t = new Tools();
        t.CreateExcelFile("chart_data", ref dt);

    }

    protected void ddlPlants_SelectedIndexChanged(object sender, EventArgs e)
    {
        GetLineNames();
    }
}