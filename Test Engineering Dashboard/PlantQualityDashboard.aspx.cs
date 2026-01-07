using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Collections.Generic;
using System.Linq;
using System.Web.Script.Serialization;

public partial class TED_PlantQualityDashboard : Page
{
    // Public properties for JavaScript access
    private string _yieldPercent = "0";
    private string _yieldGoal = "98";
    
    public string YieldPercent 
    { 
        get { return _yieldPercent; } 
        set { _yieldPercent = value; } 
    }
    
    public string YieldGoal 
    { 
        get { return _yieldGoal; } 
        set { _yieldGoal = value; } 
    }

    // Connection strings
    private string TracksConnectionString
    {
        get
        {
            var cs = ConfigurationManager.ConnectionStrings["TracksConnectionString"];
            if (cs != null) return cs.ConnectionString;
            // Fallback to Test Engineering connection if Tracks not configured
            var tecs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"];
            return tecs != null ? tecs.ConnectionString : "";
        }
    }

    private string TEConnectionString
    {
        get
        {
            var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"];
            return cs != null ? cs.ConnectionString : "";
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            InitializeDates();
            LoadProductionLines();
            LoadYieldGoal();
            LoadDashboardData();
            
            // Set default filter state for display
            hfCurrentLine.Value = "ALL";
            hfCurrentDatePreset.Value = "MTD";
        }
    }

    private void InitializeDates()
    {
        // Default to Month to Date (MTD)
        DateTime endDate = DateTime.Now;
        DateTime startDate = new DateTime(endDate.Year, endDate.Month, 1);

        txtStartDate.Text = startDate.ToString("yyyy-MM-dd");
        txtEndDate.Text = endDate.ToString("yyyy-MM-dd");
    }

    private void LoadProductionLines()
    {
        try
        {
            string plant = ddlPlant.SelectedValue;
            string sql = @"
                SELECT DISTINCT FAMILY 
                FROM View_PowerBI_MASTER_INDEX 
                WHERE PLANT LIKE @Plant + '%' 
                  AND FAMILY NOT LIKE '%Failure Analysis%'
                ORDER BY FAMILY";

            using (var conn = new SqlConnection(TracksConnectionString))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@Plant", plant == "ALL" ? "%" : plant);
                conn.Open();

                ddlLine.Items.Clear();
                ddlLine.Items.Add(new ListItem("All Lines", "ALL"));

                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string family = reader["FAMILY"].ToString();
                        if (!string.IsNullOrWhiteSpace(family))
                        {
                            ddlLine.Items.Add(new ListItem(family, family));
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("LoadProductionLines error: " + ex.Message);
        }
    }

    private void LoadYieldGoal()
    {
        try
        {
            // Set defaults first
            YieldGoal = "98";
            hfYieldGoal.Value = "98";
            
            string plant = ddlPlant.SelectedValue;
            string sql = @"
                SELECT TOP 1 GoalValue 
                FROM Quality_Goals 
                WHERE Plant = @Plant 
                  AND MetricType = 'Yield'
                  AND (ProductionLine IS NULL OR ProductionLine = @Line)
                  AND EffectiveDate <= GETDATE()
                  AND (EndDate IS NULL OR EndDate >= GETDATE())
                ORDER BY ProductionLine DESC, EffectiveDate DESC";

            using (var conn = new SqlConnection(TEConnectionString))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@Plant", plant == "ALL" ? "YPO" : plant);
                cmd.Parameters.AddWithValue("@Line", ddlLine.SelectedValue == "ALL" ? (object)DBNull.Value : ddlLine.SelectedValue);
                conn.Open();

                var result = cmd.ExecuteScalar();
                if (result != null && result != DBNull.Value)
                {
                    decimal goal = Convert.ToDecimal(result);
                    YieldGoal = (goal * 100).ToString("0.##");
                    hfYieldGoal.Value = YieldGoal;
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("LoadYieldGoal error (using defaults): " + ex.Message);
            // Keep defaults already set
        }
    }

    private void LoadDashboardData()
    {
        try
        {
            LoadYieldKPIs();
            LoadYieldByLineData();
            LoadYieldDailyData();
            LoadYieldByLineDateData();
            LoadFailureCategoryData();
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("LoadDashboardData error: " + ex.Message);
        }
    }

    private void LoadYieldKPIs()
    {
        try
        {
            string plant = ddlPlant.SelectedValue;
            string line = ddlLine.SelectedValue;
            
            // Parse dates with explicit format
            DateTime startDate;
            DateTime endDate;
            if (!DateTime.TryParseExact(txtStartDate.Text, "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out startDate))
            {
                startDate = DateTime.Now.AddDays(-7);
            }
            if (!DateTime.TryParseExact(txtEndDate.Text, "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out endDate))
            {
                endDate = DateTime.Now;
            }

            string plantCriteria = plant == "ALL" ? "" : " AND PLANT = @Plant ";
            string lineCriteria = line == "ALL" ? "" : " AND FAMILY = @Line ";
            string pcatFilter = "(SERIAL_NUMBER NOT LIKE 'P[0-9]%' OR SERIAL_NUMBER LIKE 'P[0-9]%[^0-9]') AND ";

            string sql = @"
                SELECT 
                    COUNT([FAILED]) AS Tested,
                    COUNT([FAILED]) - SUM([FAILED]) AS Passed,
                    SUM([FAILED]) AS Failed
                FROM View_PowerBI_MASTER_INDEX 
                WHERE " + pcatFilter + @"
                    CAST([FIRST_TEST_DATE] AS Date) BETWEEN @StartDate AND @EndDate
                    AND FAMILY NOT LIKE '%Failure Analysis%'
                    " + plantCriteria + @"
                    " + lineCriteria;

            using (var conn = new SqlConnection(TracksConnectionString))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@StartDate", startDate.Date);
                cmd.Parameters.AddWithValue("@EndDate", endDate.Date);
                if (plant != "ALL") cmd.Parameters.AddWithValue("@Plant", plant);
                if (line != "ALL") cmd.Parameters.AddWithValue("@Line", line);

                conn.Open();
                using (var reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        int tested = reader["Tested"] != DBNull.Value ? Convert.ToInt32(reader["Tested"]) : 0;
                        int passed = reader["Passed"] != DBNull.Value ? Convert.ToInt32(reader["Passed"]) : 0;
                        int failed = reader["Failed"] != DBNull.Value ? Convert.ToInt32(reader["Failed"]) : 0;

                        decimal yieldPct = tested > 0 ? (decimal)passed / tested * 100 : 0;

                        YieldPercent = yieldPct.ToString("0.00");
                        hfYieldPercent.Value = YieldPercent;
                        hfTested.Value = tested.ToString();
                        hfPassed.Value = passed.ToString();
                        hfFailed.Value = failed.ToString();
                    }
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("LoadYieldKPIs error: " + ex.Message);
            hfYieldPercent.Value = "0";
            hfTested.Value = "0";
            hfPassed.Value = "0";
            hfFailed.Value = "0";
        }
    }

    private void LoadYieldByLineData()
    {
        try
        {
            string plant = ddlPlant.SelectedValue;
            string line = ddlLine.SelectedValue;
            
            DateTime startDate;
            DateTime endDate;
            if (!DateTime.TryParseExact(txtStartDate.Text, "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out startDate))
            {
                startDate = DateTime.Now.AddDays(-7);
            }
            if (!DateTime.TryParseExact(txtEndDate.Text, "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out endDate))
            {
                endDate = DateTime.Now;
            }

            string plantCriteria = plant == "ALL" ? "" : " AND PLANT = @Plant ";
            string lineCriteria = line == "ALL" ? "" : " AND FAMILY = @Line ";
            string pcatFilter = "(SERIAL_NUMBER NOT LIKE 'P[0-9]%' OR SERIAL_NUMBER LIKE 'P[0-9]%[^0-9]') AND ";

            string sql = @"
                SELECT 
                    FAMILY AS LineName,
                    COUNT([FAILED]) AS Tested,
                    COUNT([FAILED]) - SUM([FAILED]) AS Passed,
                    SUM([FAILED]) AS Failed
                FROM View_PowerBI_MASTER_INDEX 
                WHERE " + pcatFilter + @"
                    CAST([FIRST_TEST_DATE] AS Date) BETWEEN @StartDate AND @EndDate
                    AND FAMILY NOT LIKE '%Failure Analysis%'
                    " + plantCriteria + @"
                    " + lineCriteria + @"
                GROUP BY FAMILY
                ORDER BY FAMILY";

            var lineDataList = new List<object>();

            using (var conn = new SqlConnection(TracksConnectionString))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@StartDate", startDate.Date);
                cmd.Parameters.AddWithValue("@EndDate", endDate.Date);
                if (plant != "ALL") cmd.Parameters.AddWithValue("@Plant", plant);
                if (line != "ALL") cmd.Parameters.AddWithValue("@Line", line);

                conn.Open();
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string lineName = reader["LineName"] != DBNull.Value ? reader["LineName"].ToString() : "Unknown";
                        int tested = reader["Tested"] != DBNull.Value ? Convert.ToInt32(reader["Tested"]) : 0;
                        int passed = reader["Passed"] != DBNull.Value ? Convert.ToInt32(reader["Passed"]) : 0;
                        int failed = reader["Failed"] != DBNull.Value ? Convert.ToInt32(reader["Failed"]) : 0;
                        
                        lineDataList.Add(new { line = lineName, tested = tested, passed = passed, failed = failed });
                    }
                }
            }

            var serializer = new JavaScriptSerializer();
            hfYieldByLineData.Value = serializer.Serialize(lineDataList);
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("LoadYieldByLineData error: " + ex.Message);
            hfYieldByLineData.Value = "[]";
        }
    }

    private void LoadYieldDailyData()
    {
        try
        {
            string plant = ddlPlant.SelectedValue;
            string line = ddlLine.SelectedValue;
            
            // Parse dates with explicit format
            DateTime startDate;
            DateTime endDate;
            if (!DateTime.TryParseExact(txtStartDate.Text, "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out startDate))
            {
                startDate = DateTime.Now.AddDays(-7);
            }
            if (!DateTime.TryParseExact(txtEndDate.Text, "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out endDate))
            {
                endDate = DateTime.Now;
            }

            string plantCriteria = plant == "ALL" ? "" : " AND PLANT = @Plant ";
            string lineCriteria = line == "ALL" ? "" : " AND FAMILY = @Line ";
            string pcatFilter = "(SERIAL_NUMBER NOT LIKE 'P[0-9]%' OR SERIAL_NUMBER LIKE 'P[0-9]%[^0-9]') AND ";

            string sql = @"
                SELECT 
                    CAST([FIRST_TEST_DATE] AS Date) AS TestDate,
                    COUNT([FAILED]) AS Tested,
                    COUNT([FAILED]) - SUM([FAILED]) AS Passed
                FROM View_PowerBI_MASTER_INDEX 
                WHERE " + pcatFilter + @"
                    CAST([FIRST_TEST_DATE] AS Date) BETWEEN @StartDate AND @EndDate
                    AND FAMILY NOT LIKE '%Failure Analysis%'
                    " + plantCriteria + @"
                    " + lineCriteria + @"
                GROUP BY CAST([FIRST_TEST_DATE] AS Date)
                ORDER BY TestDate";

            var labels = new List<string>();
            var data = new List<decimal>();
            var cumulativeData = new List<decimal>();
            var testedList = new List<int>();
            var passedList = new List<int>();
            var failedList = new List<int>();
            
            int cumulativeTested = 0;
            int cumulativePassed = 0;

            using (var conn = new SqlConnection(TracksConnectionString))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@StartDate", startDate.Date);
                cmd.Parameters.AddWithValue("@EndDate", endDate.Date);
                if (plant != "ALL") cmd.Parameters.AddWithValue("@Plant", plant);
                if (line != "ALL") cmd.Parameters.AddWithValue("@Line", line);

                conn.Open();
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        DateTime date = Convert.ToDateTime(reader["TestDate"]);
                        int tested = Convert.ToInt32(reader["Tested"]);
                        int passed = Convert.ToInt32(reader["Passed"]);
                        int failed = tested - passed;
                        decimal yield = tested > 0 ? (decimal)passed / tested * 100 : 0;
                        
                        // Calculate cumulative yield
                        cumulativeTested += tested;
                        cumulativePassed += passed;
                        decimal cumYield = cumulativeTested > 0 ? (decimal)cumulativePassed / cumulativeTested * 100 : 0;

                        labels.Add(date.ToString("M/d"));
                        data.Add(Math.Round(yield, 2));
                        cumulativeData.Add(Math.Round(cumYield, 2));
                        testedList.Add(tested);
                        passedList.Add(passed);
                        failedList.Add(failed);
                    }
                }
            }

            var serializer = new JavaScriptSerializer();
            hfYieldDailyLabels.Value = serializer.Serialize(labels);
            hfYieldDailyData.Value = serializer.Serialize(data);
            hfYieldDailyCumulative.Value = serializer.Serialize(cumulativeData);
            hfYieldDailyTested.Value = serializer.Serialize(testedList);
            hfYieldDailyPassed.Value = serializer.Serialize(passedList);
            hfYieldDailyFailed.Value = serializer.Serialize(failedList);
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("LoadYieldDailyData error: " + ex.Message);
            hfYieldDailyLabels.Value = "[]";
            hfYieldDailyData.Value = "[]";
            hfYieldDailyCumulative.Value = "[]";
            hfYieldDailyTested.Value = "[]";
            hfYieldDailyPassed.Value = "[]";
            hfYieldDailyFailed.Value = "[]";
        }
    }

    private void LoadYieldByLineDateData()
    {
        try
        {
            string plant = ddlPlant.SelectedValue;
            string line = ddlLine.SelectedValue;
            
            DateTime startDate;
            DateTime endDate;
            if (!DateTime.TryParseExact(txtStartDate.Text, "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out startDate))
            {
                startDate = DateTime.Now.AddDays(-7);
            }
            if (!DateTime.TryParseExact(txtEndDate.Text, "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out endDate))
            {
                endDate = DateTime.Now;
            }

            string plantCriteria = plant == "ALL" ? "" : " AND PLANT = @Plant ";
            string lineCriteria = line == "ALL" ? "" : " AND FAMILY = @Line ";
            string pcatFilter = "(SERIAL_NUMBER NOT LIKE 'P[0-9]%' OR SERIAL_NUMBER LIKE 'P[0-9]%[^0-9]') AND ";

            // Query to get yield data by line and date
            string sql = @"
                SELECT 
                    FAMILY AS LineName,
                    CAST([FIRST_TEST_DATE] AS Date) AS TestDate,
                    COUNT([FAILED]) AS Tested,
                    COUNT([FAILED]) - SUM([FAILED]) AS Passed
                FROM View_PowerBI_MASTER_INDEX 
                WHERE " + pcatFilter + @"
                    CAST([FIRST_TEST_DATE] AS Date) BETWEEN @StartDate AND @EndDate
                    AND FAMILY NOT LIKE '%Failure Analysis%'
                    " + plantCriteria + @"
                    " + lineCriteria + @"
                GROUP BY FAMILY, CAST([FIRST_TEST_DATE] AS Date)
                ORDER BY FAMILY, TestDate";

            var lineDateData = new List<object>();

            using (var conn = new SqlConnection(TracksConnectionString))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@StartDate", startDate.Date);
                cmd.Parameters.AddWithValue("@EndDate", endDate.Date);
                if (plant != "ALL") cmd.Parameters.AddWithValue("@Plant", plant);
                if (line != "ALL") cmd.Parameters.AddWithValue("@Line", line);

                conn.Open();
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string lineName = reader["LineName"] != DBNull.Value ? reader["LineName"].ToString() : "Unknown";
                        DateTime testDate = Convert.ToDateTime(reader["TestDate"]);
                        int tested = reader["Tested"] != DBNull.Value ? Convert.ToInt32(reader["Tested"]) : 0;
                        int passed = reader["Passed"] != DBNull.Value ? Convert.ToInt32(reader["Passed"]) : 0;
                        decimal yieldPct = tested > 0 ? Math.Round((decimal)passed / tested * 100, 2) : 0;
                        
                        lineDateData.Add(new { 
                            line = lineName, 
                            date = testDate.ToString("M/d"), 
                            dateSort = testDate.ToString("yyyy-MM-dd"),
                            tested = tested, 
                            passed = passed, 
                            yield = yieldPct 
                        });
                    }
                }
            }

            var serializer = new JavaScriptSerializer();
            hfYieldByLineDateData.Value = serializer.Serialize(lineDateData);
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("LoadYieldByLineDateData error: " + ex.Message);
            hfYieldByLineDateData.Value = "[]";
        }
    }

    private void LoadFailureCategoryData()
    {
        try
        {
            string plant = ddlPlant.SelectedValue;
            string line = ddlLine.SelectedValue;
            
            // Parse dates with explicit format
            DateTime startDate;
            DateTime endDate;
            if (!DateTime.TryParseExact(txtStartDate.Text, "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out startDate))
            {
                startDate = DateTime.Now.AddDays(-7);
            }
            if (!DateTime.TryParseExact(txtEndDate.Text, "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out endDate))
            {
                endDate = DateTime.Now;
            }

            string plantCriteria = plant == "ALL" ? "" : " AND PLANT = @Plant ";
            string lineCriteria = line == "ALL" ? "" : " AND FAMILY = @Line ";
            string pcatFilter = "(SERIAL_NUMBER NOT LIKE 'P[0-9]%' OR SERIAL_NUMBER LIKE 'P[0-9]%[^0-9]') AND ";

            // Query: Get failures by Category (aggregated)
            string sql = @"
                SELECT 
                    NC_CATEGORY,
                    COUNT(*) AS Total
                FROM View_PowerBI_MASTER_INDEX_AND_ISSUE_REPORTS_COMBINED
                WHERE " + pcatFilter + @"
                    (CAST([FIRST_TEST_DATE] AS Date) BETWEEN @StartDate AND @EndDate
                     OR CAST([ISSUE_DATE] AS Date) BETWEEN @StartDate AND @EndDate)
                    AND FAMILY NOT LIKE '%Failure Analysis%'
                    AND NC_CATEGORY IS NOT NULL
                    " + plantCriteria + @"
                    " + lineCriteria + @"
                GROUP BY NC_CATEGORY
                ORDER BY Total DESC";

            var labels = new List<string>();
            var data = new List<int>();
            string[] validCategories = { "COMPONENT", "WORKMANSHIP", "TEST", "DESIGN", "OTHER", "UNDETERMINED", "TROUBLESHOOTING" };

            using (var conn = new SqlConnection(TracksConnectionString))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@StartDate", startDate.Date);
                cmd.Parameters.AddWithValue("@EndDate", endDate.Date);
                if (plant != "ALL") cmd.Parameters.AddWithValue("@Plant", plant);
                if (line != "ALL") cmd.Parameters.AddWithValue("@Line", line);

                conn.Open();
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string category = reader["NC_CATEGORY"].ToString().ToUpper();
                        int total = Convert.ToInt32(reader["Total"]);

                        if (!validCategories.Contains(category) || total == 0)
                            continue;

                        // Format category name (capitalize first letter)
                        string catName = char.ToUpper(category[0]) + category.Substring(1).ToLower();
                        labels.Add(catName);
                        data.Add(total);
                    }
                }
            }

            var serializer = new JavaScriptSerializer();
            hfFailureCategoryLabels.Value = serializer.Serialize(labels);
            hfFailureCategoryData.Value = serializer.Serialize(data);
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("LoadFailureCategoryData error: " + ex.Message);
            hfFailureCategoryLabels.Value = "[]";
            hfFailureCategoryData.Value = "[]";
        }
    }

    protected void btnRefresh_Click(object sender, EventArgs e)
    {
        // Validate dates
        DateTime startDate, endDate;
        if (!DateTime.TryParse(txtStartDate.Text, out startDate))
        {
            txtStartDate.Text = DateTime.Now.AddDays(-7).ToString("yyyy-MM-dd");
        }
        if (!DateTime.TryParse(txtEndDate.Text, out endDate))
        {
            txtEndDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
        }

        // Preserve selected line before reloading dropdown
        string selectedLine = ddlLine.SelectedValue;
        
        LoadProductionLines();
        
        // Restore selected line if it still exists
        if (!string.IsNullOrEmpty(selectedLine))
        {
            ListItem item = ddlLine.Items.FindByValue(selectedLine);
            if (item != null)
            {
                ddlLine.SelectedValue = selectedLine;
            }
        }
        
        LoadYieldGoal();
        LoadDashboardData();
    }
}
