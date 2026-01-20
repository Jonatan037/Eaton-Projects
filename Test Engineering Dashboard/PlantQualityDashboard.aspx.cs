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

        // Initialize both yield and scrap date ranges
        txtYieldStartDate.Text = startDate.ToString("yyyy-MM-dd");
        txtYieldEndDate.Text = endDate.ToString("yyyy-MM-dd");
        txtScrapStartDate.Text = startDate.ToString("yyyy-MM-dd");
        txtScrapEndDate.Text = endDate.ToString("yyyy-MM-dd");
    }

    private void LoadProductionLines()
    {
        LoadYieldLines();
        LoadScrapLines();
    }
    
    private void LoadYieldLines()
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

                // Clear and populate yield line dropdown
                ddlYieldLine.Items.Clear();
                ddlYieldLine.Items.Add(new ListItem("Plantwide", "ALL"));
                
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string family = reader["FAMILY"].ToString();
                        if (!string.IsNullOrWhiteSpace(family))
                        {
                            ddlYieldLine.Items.Add(new ListItem(family, family));
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("LoadYieldLines error: " + ex.Message);
        }
    }
    
    private void LoadScrapLines()
    {
        try
        {
            // Load scrap lines from TestEngineering's MRPControllerLineMapping table
            string sql = @"
                SELECT DISTINCT LineName 
                FROM MRPControllerLineMapping 
                WHERE LineName IS NOT NULL AND LineName <> ''
                ORDER BY LineName";

            using (var conn = new SqlConnection(TEConnectionString))
            using (var cmd = new SqlCommand(sql, conn))
            {
                conn.Open();

                // Clear and populate scrap line dropdown
                ddlScrapLine.Items.Clear();
                ddlScrapLine.Items.Add(new ListItem("Plantwide", "ALL"));
                
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string lineName = reader["LineName"].ToString();
                        if (!string.IsNullOrWhiteSpace(lineName))
                        {
                            ddlScrapLine.Items.Add(new ListItem(lineName, lineName));
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("LoadScrapLines error: " + ex.Message);
        }
    }

    private void LoadYieldGoal()
    {
        try
        {
            // Set defaults first
            YieldGoal = "98";
            hfYieldGoal.Value = "98";
            hfMonthlyGoals.Value = "{}";
            hfLineMonthlyGoals.Value = "{}";
            
            string plant = ddlPlant.SelectedValue;
            string line = ddlYieldLine.SelectedValue;
            
            // Get date range for monthly goals
            DateTime startDate;
            DateTime endDate;
            if (!DateTime.TryParseExact(txtYieldStartDate.Text, "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out startDate))
            {
                startDate = DateTime.Now.AddDays(-7);
            }
            if (!DateTime.TryParseExact(txtYieldEndDate.Text, "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out endDate))
            {
                endDate = DateTime.Now;
            }
            
            // Load current goal (for gauge - use latest applicable goal within the selected date range)
            // Check if QualityGoals table exists (new per-line monthly system)
            string checkTableSql = @"
                IF OBJECT_ID('dbo.QualityGoals', 'U') IS NOT NULL 
                    SELECT 1 AS TableExists
                ELSE 
                    SELECT 0 AS TableExists";

            using (var conn = new SqlConnection(TEConnectionString))
            {
                conn.Open();
                
                bool useNewSystem = false;
                using (var checkCmd = new SqlCommand(checkTableSql, conn))
                {
                    int exists = Convert.ToInt32(checkCmd.ExecuteScalar());
                    useNewSystem = (exists == 1);
                }
                
                decimal? maxGoal = null; // Initialize as nullable to track first goal found
                var monthlyGoalsDict = new Dictionary<string, decimal>();
                // Line-specific goals: { "LineName": { "yyyy-MM": goalValue, ... }, ... }
                var lineMonthlyGoalsDict = new Dictionary<string, Dictionary<string, decimal>>();
                
                if (useNewSystem)
                {
                    // First, try to map the selected line (FAMILY value) to LineName via MRPControllerLineMapping
                    // Some FAMILY values like "BatteryLine" need to map to "Battery" in QualityGoals
                    string mappedLine = line;
                    if (line != "ALL")
                    {
                        string mapSql = @"
                            SELECT TOP 1 LineName 
                            FROM MRPControllerLineMapping 
                            WHERE Plant = @Plant 
                              AND IsActive = 1
                              AND (@Line LIKE LineName + '%' OR LineName LIKE @Line + '%' OR @Line = LineName)
                            ORDER BY LEN(LineName) DESC";
                        
                        using (var mapCmd = new SqlCommand(mapSql, conn))
                        {
                            mapCmd.Parameters.AddWithValue("@Plant", plant == "ALL" ? "YPO" : plant);
                            mapCmd.Parameters.AddWithValue("@Line", line);
                            var result = mapCmd.ExecuteScalar();
                            if (result != null && result != DBNull.Value)
                            {
                                mappedLine = result.ToString();
                            }
                        }
                    }
                    
                    // Use new QualityGoals table (per-line, per-month)
                    // For Plantwide (mappedLine = ALL), look for LineName = 'YPO (Plant)'
                    string plantLineGoalName = (plant == "ALL" ? "YPO" : plant) + " (Plant)";
                    string lineToSearch = mappedLine == "ALL" ? plantLineGoalName : mappedLine;
                    
                    string monthlySQL = @"
                        WITH MonthSeries AS (
                            SELECT 
                                YEAR(DATEADD(MONTH, number, @StartDate)) AS YearNum,
                                MONTH(DATEADD(MONTH, number, @StartDate)) AS MonthNum,
                                FORMAT(DATEADD(MONTH, number, @StartDate), 'yyyy-MM') AS MonthKey
                            FROM master.dbo.spt_values
                            WHERE type = 'P'
                              AND DATEADD(MONTH, number, @StartDate) <= @EndDate
                              AND number < DATEDIFF(MONTH, @StartDate, @EndDate) + 1
                        )
                        SELECT 
                            m.MonthKey,
                            ISNULL((SELECT TOP 1 GoalValue 
                                    FROM QualityGoals g 
                                    WHERE g.Plant = @Plant 
                                      AND g.MetricType = 'Yield'
                                      AND g.Year = m.YearNum
                                      AND g.MonthNum = m.MonthNum
                                      AND g.LineName = @LineToSearch
                                   ), 98.0) AS GoalValue
                        FROM MonthSeries m";
                    
                    using (var cmd = new SqlCommand(monthlySQL, conn))
                    {
                        cmd.Parameters.AddWithValue("@Plant", plant == "ALL" ? "YPO" : plant);
                        cmd.Parameters.AddWithValue("@LineToSearch", lineToSearch);
                        cmd.Parameters.AddWithValue("@StartDate", new DateTime(startDate.Year, startDate.Month, 1));
                        cmd.Parameters.AddWithValue("@EndDate", new DateTime(endDate.Year, endDate.Month, 1));
                        
                        using (var reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                string monthKey = reader["MonthKey"].ToString();
                                decimal goalValue = Convert.ToDecimal(reader["GoalValue"]);
                                monthlyGoalsDict[monthKey] = goalValue;
                                
                                // Track the max goal for gauge
                                if (!maxGoal.HasValue || goalValue > maxGoal.Value)
                                {
                                    maxGoal = goalValue;
                                }
                            }
                        }
                    }
                    
                    // If viewing Plantwide, also load goals for each individual line (for table cell coloring)
                    // We need to create a mapping between FAMILY names (from Tracks) and LineName (from QualityGoals)
                    if (line == "ALL")
                    {
                        // First, get the mapping between FAMILY and LineName
                        var familyToLineMap = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
                        
                        // Load FAMILY names from Tracks and try to map to LineName
                        try
                        {
                            using (var tracksConn = new SqlConnection(TracksConnectionString))
                            {
                                tracksConn.Open();
                                string familySql = @"
                                    SELECT DISTINCT FAMILY 
                                    FROM View_PowerBI_MASTER_INDEX 
                                    WHERE PLANT LIKE @Plant + '%' 
                                      AND FAMILY NOT LIKE '%Failure Analysis%'
                                      AND FAMILY IS NOT NULL AND FAMILY <> ''";
                                
                                using (var famCmd = new SqlCommand(familySql, tracksConn))
                                {
                                    famCmd.Parameters.AddWithValue("@Plant", plant == "ALL" ? "%" : plant);
                                    using (var famReader = famCmd.ExecuteReader())
                                    {
                                        while (famReader.Read())
                                        {
                                            string family = famReader["FAMILY"].ToString();
                                            familyToLineMap[family] = family; // default: same name
                                        }
                                    }
                                }
                            }
                        }
                        catch { /* Ignore mapping errors, use direct names */ }
                        
                        // Now try to map FAMILY to LineName using MRPControllerLineMapping
                        string mapSql = @"
                            SELECT LineName 
                            FROM MRPControllerLineMapping 
                            WHERE Plant = @Plant AND IsActive = 1";
                        
                        var lineNames = new List<string>();
                        using (var mapCmd = new SqlCommand(mapSql, conn))
                        {
                            mapCmd.Parameters.AddWithValue("@Plant", plant == "ALL" ? "YPO" : plant);
                            using (var mapReader = mapCmd.ExecuteReader())
                            {
                                while (mapReader.Read())
                                {
                                    string ln = mapReader["LineName"].ToString();
                                    if (!lineNames.Contains(ln)) lineNames.Add(ln);
                                }
                            }
                        }
                        
                        // Update mapping: if FAMILY contains or is contained by a LineName, map it
                        foreach (var family in familyToLineMap.Keys.ToList())
                        {
                            foreach (var ln in lineNames)
                            {
                                // Match if family contains lineName or lineName contains family (case-insensitive)
                                if (family.IndexOf(ln, StringComparison.OrdinalIgnoreCase) >= 0 ||
                                    ln.IndexOf(family, StringComparison.OrdinalIgnoreCase) >= 0)
                                {
                                    familyToLineMap[family] = ln;
                                    break;
                                }
                            }
                        }
                        
                        string lineGoalsSQL = @"
                            WITH MonthSeries AS (
                                SELECT 
                                    YEAR(DATEADD(MONTH, number, @StartDate)) AS YearNum,
                                    MONTH(DATEADD(MONTH, number, @StartDate)) AS MonthNum,
                                    FORMAT(DATEADD(MONTH, number, @StartDate), 'yyyy-MM') AS MonthKey
                                FROM master.dbo.spt_values
                                WHERE type = 'P'
                                  AND DATEADD(MONTH, number, @StartDate) <= @EndDate
                                  AND number < DATEDIFF(MONTH, @StartDate, @EndDate) + 1
                            )
                            SELECT 
                                g.LineName,
                                m.MonthKey,
                                ISNULL(g.GoalValue, 98.0) AS GoalValue
                            FROM MonthSeries m
                            CROSS APPLY (
                                SELECT DISTINCT LineName 
                                FROM QualityGoals 
                                WHERE Plant = @Plant 
                                  AND MetricType = 'Yield'
                                  AND LineName NOT LIKE '%Plant%'
                            ) AS lines
                            LEFT JOIN QualityGoals g ON g.Plant = @Plant 
                                AND g.MetricType = 'Yield'
                                AND g.LineName = lines.LineName
                                AND g.Year = m.YearNum
                                AND g.MonthNum = m.MonthNum
                            WHERE lines.LineName IS NOT NULL";
                        
                        using (var cmd = new SqlCommand(lineGoalsSQL, conn))
                        {
                            cmd.Parameters.AddWithValue("@Plant", plant == "ALL" ? "YPO" : plant);
                            cmd.Parameters.AddWithValue("@StartDate", new DateTime(startDate.Year, startDate.Month, 1));
                            cmd.Parameters.AddWithValue("@EndDate", new DateTime(endDate.Year, endDate.Month, 1));
                            
                            using (var reader = cmd.ExecuteReader())
                            {
                                while (reader.Read())
                                {
                                    string lineName = reader["LineName"].ToString();
                                    string monthKey = reader["MonthKey"].ToString();
                                    decimal goalValue = Convert.ToDecimal(reader["GoalValue"]);
                                    
                                    // Add goal with LineName key
                                    if (!lineMonthlyGoalsDict.ContainsKey(lineName))
                                    {
                                        lineMonthlyGoalsDict[lineName] = new Dictionary<string, decimal>();
                                    }
                                    lineMonthlyGoalsDict[lineName][monthKey] = goalValue;
                                    
                                    // Also add with any FAMILY names that map to this LineName
                                    foreach (var kvp in familyToLineMap)
                                    {
                                        if (kvp.Value == lineName && kvp.Key != lineName)
                                        {
                                            if (!lineMonthlyGoalsDict.ContainsKey(kvp.Key))
                                            {
                                                lineMonthlyGoalsDict[kvp.Key] = new Dictionary<string, decimal>();
                                            }
                                            lineMonthlyGoalsDict[kvp.Key][monthKey] = goalValue;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                else
                {
                    // Fall back to old Quality_Goals table (plant-wide only)
                    string sql = @"
                        SELECT TOP 1 GoalValue 
                        FROM Quality_Goals 
                        WHERE Plant = @Plant 
                          AND MetricType = 'Yield'
                          AND (ProductionLine IS NULL OR ProductionLine = @Line)
                          AND EffectiveDate <= @EndDate
                          AND (EndDate IS NULL OR EndDate >= @StartDate)
                        ORDER BY ProductionLine DESC, EffectiveDate DESC";

                    using (var cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@Plant", plant == "ALL" ? "YPO" : plant);
                        cmd.Parameters.AddWithValue("@Line", line == "ALL" ? (object)DBNull.Value : line);
                        cmd.Parameters.AddWithValue("@StartDate", startDate);
                        cmd.Parameters.AddWithValue("@EndDate", endDate);

                        var result = cmd.ExecuteScalar();
                        if (result != null && result != DBNull.Value)
                        {
                            maxGoal = Convert.ToDecimal(result) * 100;
                        }
                    }
                    
                    // If using old system and no goal found, use the single goal for all months
                    if (maxGoal.HasValue)
                    {
                        var currentMonth = new DateTime(startDate.Year, startDate.Month, 1);
                        var endMonth = new DateTime(endDate.Year, endDate.Month, 1);
                        while (currentMonth <= endMonth)
                        {
                            string monthKey = currentMonth.ToString("yyyy-MM");
                            monthlyGoalsDict[monthKey] = maxGoal.Value;
                            currentMonth = currentMonth.AddMonths(1);
                        }
                    }
                }
                
                // Set the gauge goal to the highest monthly goal (or default to 98 if none found)
                YieldGoal = (maxGoal ?? 98m).ToString("0.##");
                hfYieldGoal.Value = YieldGoal;
                
                // Serialize monthly goals as JSON
                var serializer = new JavaScriptSerializer();
                hfMonthlyGoals.Value = serializer.Serialize(monthlyGoalsDict);
                hfLineMonthlyGoals.Value = serializer.Serialize(lineMonthlyGoalsDict);
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
            // Load all data on initial page load
            LoadYieldData();
            LoadScrapData();
            LoadNCMData();
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
            string line = ddlYieldLine.SelectedValue;
            
            // Parse dates with explicit format
            DateTime startDate;
            DateTime endDate;
            if (!DateTime.TryParseExact(txtYieldStartDate.Text, "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out startDate))
            {
                startDate = DateTime.Now.AddDays(-7);
            }
            if (!DateTime.TryParseExact(txtYieldEndDate.Text, "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out endDate))
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
            string line = ddlYieldLine.SelectedValue;
            
            DateTime startDate;
            DateTime endDate;
            if (!DateTime.TryParseExact(txtYieldStartDate.Text, "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out startDate))
            {
                startDate = DateTime.Now.AddDays(-7);
            }
            if (!DateTime.TryParseExact(txtYieldEndDate.Text, "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out endDate))
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
            string line = ddlYieldLine.SelectedValue;
            
            // Parse dates with explicit format
            DateTime startDate;
            DateTime endDate;
            if (!DateTime.TryParseExact(txtYieldStartDate.Text, "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out startDate))
            {
                startDate = DateTime.Now.AddDays(-7);
            }
            if (!DateTime.TryParseExact(txtYieldEndDate.Text, "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out endDate))
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
            var sortDates = new List<string>();
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
                        sortDates.Add(date.ToString("yyyy-MM-dd"));
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
            hfYieldDailySortDates.Value = serializer.Serialize(sortDates);
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
            hfYieldDailySortDates.Value = "[]";
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
            string line = ddlYieldLine.SelectedValue;
            
            DateTime startDate;
            DateTime endDate;
            if (!DateTime.TryParseExact(txtYieldStartDate.Text, "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out startDate))
            {
                startDate = DateTime.Now.AddDays(-7);
            }
            if (!DateTime.TryParseExact(txtYieldEndDate.Text, "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out endDate))
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
            string line = ddlYieldLine.SelectedValue;
            
            // Parse dates with explicit format
            DateTime startDate;
            DateTime endDate;
            if (!DateTime.TryParseExact(txtYieldStartDate.Text, "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out startDate))
            {
                startDate = DateTime.Now.AddDays(-7);
            }
            if (!DateTime.TryParseExact(txtYieldEndDate.Text, "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out endDate))
            {
                endDate = DateTime.Now;
            }

            string plantCriteria = plant == "ALL" ? "" : " AND PLANT = @Plant ";
            string lineCriteria = line == "ALL" ? "" : " AND FAMILY = @Line ";
            string pcatFilter = "(SERIAL_NUMBER NOT LIKE 'P[0-9]%' OR SERIAL_NUMBER LIKE 'P[0-9]%[^0-9]') AND ";

            // Query: Get failures with category, line, and serial number details
            string sql = @"
                SELECT 
                    NC_CATEGORY,
                    FAMILY AS Line,
                    SERIAL_NUMBER
                FROM View_PowerBI_MASTER_INDEX_AND_ISSUE_REPORTS_COMBINED
                WHERE " + pcatFilter + @"
                    (CAST([FIRST_TEST_DATE] AS Date) BETWEEN @StartDate AND @EndDate
                     OR CAST([ISSUE_DATE] AS Date) BETWEEN @StartDate AND @EndDate)
                    AND FAMILY NOT LIKE '%Failure Analysis%'
                    AND NC_CATEGORY IS NOT NULL
                    " + plantCriteria + @"
                    " + lineCriteria + @"
                ORDER BY NC_CATEGORY, FAMILY, SERIAL_NUMBER";

            var labels = new List<string>();
            var data = new List<int>();
            string[] validCategories = { "COMPONENT", "WORKMANSHIP", "TEST", "DESIGN", "OTHER", "UNDETERMINED", "TROUBLESHOOTING" };
            
            // Detailed data structure: Category -> Line -> Serial Numbers
            var categoryDetails = new Dictionary<string, Dictionary<string, List<string>>>();

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
                        string lineName = reader["Line"] != DBNull.Value ? reader["Line"].ToString() : "Unknown";
                        string serialNumber = reader["SERIAL_NUMBER"] != DBNull.Value ? reader["SERIAL_NUMBER"].ToString() : "";

                        if (!validCategories.Contains(category))
                            continue;

                        // Format category name (capitalize first letter)
                        string catName = char.ToUpper(category[0]) + category.Substring(1).ToLower();
                        
                        if (!categoryDetails.ContainsKey(catName))
                        {
                            categoryDetails[catName] = new Dictionary<string, List<string>>();
                        }
                        
                        if (!categoryDetails[catName].ContainsKey(lineName))
                        {
                            categoryDetails[catName][lineName] = new List<string>();
                        }
                        
                        if (!string.IsNullOrEmpty(serialNumber))
                        {
                            categoryDetails[catName][lineName].Add(serialNumber);
                        }
                    }
                }
            }
            
            // Build summary labels and data
            foreach (var cat in categoryDetails.OrderByDescending(c => c.Value.Sum(l => l.Value.Count)))
            {
                int total = cat.Value.Sum(l => l.Value.Count);
                if (total > 0)
                {
                    labels.Add(cat.Key);
                    data.Add(total);
                }
            }
            
            // Convert detailed data to JSON-friendly format
            var detailsList = new List<object>();
            foreach (var cat in categoryDetails)
            {
                var linesList = new List<object>();
                foreach (var lineItem in cat.Value.OrderByDescending(l => l.Value.Count))
                {
                    linesList.Add(new { 
                        line = lineItem.Key, 
                        count = lineItem.Value.Count, 
                        serials = lineItem.Value // Send all serials for expandable tooltip
                    });
                }
                detailsList.Add(new { 
                    category = cat.Key, 
                    total = cat.Value.Sum(l => l.Value.Count),
                    lines = linesList 
                });
            }

            var serializer = new JavaScriptSerializer();
            hfFailureCategoryLabels.Value = serializer.Serialize(labels);
            hfFailureCategoryData.Value = serializer.Serialize(data);
            hfFailureCategoryDetails.Value = serializer.Serialize(detailsList);
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("LoadFailureCategoryData error: " + ex.Message);
            hfFailureCategoryLabels.Value = "[]";
            hfFailureCategoryData.Value = "[]";
            hfFailureCategoryDetails.Value = "[]";
        }
    }

    protected void btnRefreshYield_Click(object sender, EventArgs e)
    {
        // Validate yield dates
        DateTime startDate, endDate;
        if (!DateTime.TryParse(txtYieldStartDate.Text, out startDate))
        {
            txtYieldStartDate.Text = DateTime.Now.AddDays(-7).ToString("yyyy-MM-dd");
        }
        if (!DateTime.TryParse(txtYieldEndDate.Text, out endDate))
        {
            txtYieldEndDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
        }

        // Preserve selected line before reloading dropdown
        string selectedLine = ddlYieldLine.SelectedValue;
        
        LoadProductionLines();
        
        // Restore selected line if it still exists
        if (!string.IsNullOrEmpty(selectedLine))
        {
            ListItem item = ddlYieldLine.Items.FindByValue(selectedLine);
            if (item != null)
            {
                ddlYieldLine.SelectedValue = selectedLine;
            }
        }
        
        LoadYieldGoal();
        LoadYieldData();
    }
    
    protected void btnRefreshScrap_Click(object sender, EventArgs e)
    {
        // Validate scrap dates
        DateTime startDate, endDate;
        if (!DateTime.TryParse(txtScrapStartDate.Text, out startDate))
        {
            txtScrapStartDate.Text = DateTime.Now.AddDays(-7).ToString("yyyy-MM-dd");
        }
        if (!DateTime.TryParse(txtScrapEndDate.Text, out endDate))
        {
            txtScrapEndDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
        }

        // Preserve selected scrap line
        string selectedLine = ddlScrapLine.SelectedValue;
        
        LoadProductionLines();
        
        // Restore selected line if it still exists
        if (!string.IsNullOrEmpty(selectedLine))
        {
            ListItem item = ddlScrapLine.Items.FindByValue(selectedLine);
            if (item != null)
            {
                ddlScrapLine.SelectedValue = selectedLine;
            }
        }
        
        LoadScrapData();
    }
    
    protected void btnRefreshAll_Click(object sender, EventArgs e)
    {
        // Refresh both Yield and Scrap data in a single postback
        
        // Validate yield dates
        DateTime yieldStartDate, yieldEndDate;
        if (!DateTime.TryParse(txtYieldStartDate.Text, out yieldStartDate))
        {
            txtYieldStartDate.Text = DateTime.Now.AddDays(-7).ToString("yyyy-MM-dd");
        }
        if (!DateTime.TryParse(txtYieldEndDate.Text, out yieldEndDate))
        {
            txtYieldEndDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
        }

        // Validate scrap dates
        DateTime scrapStartDate, scrapEndDate;
        if (!DateTime.TryParse(txtScrapStartDate.Text, out scrapStartDate))
        {
            txtScrapStartDate.Text = DateTime.Now.AddDays(-7).ToString("yyyy-MM-dd");
        }
        if (!DateTime.TryParse(txtScrapEndDate.Text, out scrapEndDate))
        {
            txtScrapEndDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
        }

        // Preserve selected lines
        string selectedYieldLine = ddlYieldLine.SelectedValue;
        string selectedScrapLine = ddlScrapLine.SelectedValue;
        
        LoadProductionLines();
        
        // Restore selected yield line
        if (!string.IsNullOrEmpty(selectedYieldLine))
        {
            ListItem item = ddlYieldLine.Items.FindByValue(selectedYieldLine);
            if (item != null)
            {
                ddlYieldLine.SelectedValue = selectedYieldLine;
            }
        }
        
        // Restore selected scrap line
        if (!string.IsNullOrEmpty(selectedScrapLine))
        {
            ListItem item = ddlScrapLine.Items.FindByValue(selectedScrapLine);
            if (item != null)
            {
                ddlScrapLine.SelectedValue = selectedScrapLine;
            }
        }
        
        // Load all data
        LoadYieldGoal();
        LoadYieldData();
        LoadScrapData();
    }
    
    private void LoadYieldData()
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
            System.Diagnostics.Debug.WriteLine("LoadYieldData error: " + ex.Message);
        }
    }
    
    private void LoadScrapData()
    {
        try
        {
            LoadScrapKPIs();
            LoadScrapByLineData();
            LoadScrapDailyData();
            LoadScrapByLineDateData();
            LoadTopScrapItems();
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("LoadScrapData error: " + ex.Message);
        }
    }

    // ========== SCRAP DATA LOADING METHODS ==========
    
    // Map production line names to scrap goal line names
    // Yield uses: Plantwide, 9PXM, BatteryLine, BLADEUPS, ePDU, SPD, TAA, Bypass Module, Ferrups, Phoenix
    // Scrap uses: Plant, 9PXM/Switch, Battery, BladeUPS, ePDU, SPD, TAA, Shazam, Ferrups, Phoenix
    private string MapLineNameToScrapGoalLine(string lineName)
    {
        if (string.IsNullOrEmpty(lineName) || lineName == "ALL") return "Plant";
        
        switch (lineName.ToUpper())
        {
            case "PLANTWIDE":
            case "PLANT":
                return "Plant";
            case "9PXM":
            case "9PXM/SWITCH":
                return "9PXM/Switch";
            case "BATTERYLINE":
            case "BATTERY":
                return "Battery";
            case "BLADEUPS":
                return "BladeUPS";
            case "EPDU":
                return "ePDU";
            case "SPD":
                return "SPD";
            case "TAA":
                return "TAA";
            case "SHAZAM":
                return "Shazam";
            case "FERRUPS":
                return "Ferrups";
            case "PHOENIX":
                return "Phoenix";
            case "BYPASS MODULE":
                return "Bypass Module";
            default:
                return lineName; // Return as-is if not mapped
        }
    }
    
    private void LoadScrapKPIs()
    {
        try
        {
            string ledger = ddlLedger.SelectedValue;
            string line = ddlScrapLine.SelectedValue;
            
            DateTime startDate, endDate;
            DateTime.TryParseExact(txtScrapStartDate.Text, "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out startDate);
            DateTime.TryParseExact(txtScrapEndDate.Text, "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out endDate);
            
            if (startDate == DateTime.MinValue) startDate = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1);
            if (endDate == DateTime.MinValue) endDate = DateTime.Now;
            
            // Build dynamic criteria - use MRPControllerCode if available, otherwise MRPControllerDesc
            string ledgerCriteria = ledger == "ALL" ? "" : " AND m.Ledger = @Ledger ";
            string lineCriteria = line == "ALL" ? "" : " AND m.LineName = @Line ";
            
            // Query uses LEFT(MRPControllerCode, 1) if the column exists, otherwise parse from MRPControllerDesc
            // Use ABS() because scrap amounts are stored as negative values but we want to display positive
            string sql = @"
                SELECT 
                    ABS(ISNULL(SUM(CASE WHEN s.MovementType = 551 THEN s.Amount ELSE -s.Amount END), 0)) AS NetScrap
                FROM ZMMR_ScrapData s
                LEFT JOIN MRPControllerLineMapping m ON 
                    CASE 
                        WHEN s.MRPControllerCode IS NOT NULL THEN LEFT(s.MRPControllerCode, 1)
                        ELSE LEFT(s.MRPControllerDesc, 1)
                    END = m.CodePrefix
                WHERE s.PostingDate BETWEEN @StartDate AND @EndDate
                    AND s.MovementType IN (551, 552)
                    " + ledgerCriteria + lineCriteria;
            
            decimal totalScrap = 0;
            
            using (var conn = new SqlConnection(TEConnectionString))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@StartDate", startDate.Date);
                cmd.Parameters.AddWithValue("@EndDate", endDate.Date);
                if (ledger != "ALL") cmd.Parameters.AddWithValue("@Ledger", ledger);
                if (line != "ALL") cmd.Parameters.AddWithValue("@Line", MapLineNameToScrapGoalLine(line));
                
                conn.Open();
                var result = cmd.ExecuteScalar();
                if (result != null && result != DBNull.Value)
                {
                    totalScrap = Convert.ToDecimal(result);
                }
            }
            
            hfScrapTotal.Value = totalScrap.ToString("0.00");
            
            // Load scrap goal from QualityGoals
            LoadScrapGoal(startDate, endDate, ledger, line);
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("LoadScrapKPIs error: " + ex.Message);
            hfScrapTotal.Value = "0";
            hfScrapGoal.Value = "0";
        }
    }
    
    private void LoadScrapGoal(DateTime startDate, DateTime endDate, string ledger, string line)
    {
        try
        {
            // Get period type to determine goal calculation method
            string periodType = hfScrapPeriodType.Value;
            if (string.IsNullOrEmpty(periodType)) periodType = "MTD";
            
            // Get the scrap goal - sum up daily goals based on monthly goal
            // For scrap, the goal is a maximum target (lower is better)
            decimal totalGoal = 0;
            var monthlyGoalsDict = new Dictionary<string, decimal>();
            
            string sql;
            if (line == "ALL")
            {
                // For Plantwide, SUM all line scrap goals (excluding Plant/Plantwide entries)
                sql = @"
                    SELECT 
                        Year, MonthNum, SUM(GoalValue) as GoalValue
                    FROM QualityGoals 
                    WHERE Plant = 'YPO'
                        AND MetricType = 'Scrap'
                        AND LineName NOT IN ('Plant', 'Plantwide', 'YPO')
                        AND ((Year = @StartYear AND MonthNum >= @StartMonth) OR (Year > @StartYear))
                        AND ((Year = @EndYear AND MonthNum <= @EndMonth) OR (Year < @EndYear))
                    GROUP BY Year, MonthNum
                    ORDER BY Year, MonthNum";
            }
            else
            {
                // For specific line, get the mapped line goal
                string lineName = MapLineNameToScrapGoalLine(line);
                sql = @"
                    SELECT 
                        Year, MonthNum, GoalValue
                    FROM QualityGoals 
                    WHERE Plant = 'YPO'
                        AND MetricType = 'Scrap'
                        AND LineName = @LineName
                        AND ((Year = @StartYear AND MonthNum >= @StartMonth) OR (Year > @StartYear))
                        AND ((Year = @EndYear AND MonthNum <= @EndMonth) OR (Year < @EndYear))
                    ORDER BY Year, MonthNum";
            }
            
            using (var conn = new SqlConnection(TEConnectionString))
            using (var cmd = new SqlCommand(sql, conn))
            {
                if (line != "ALL")
                {
                    string lineName = MapLineNameToScrapGoalLine(line);
                    cmd.Parameters.AddWithValue("@LineName", lineName);
                }
                cmd.Parameters.AddWithValue("@StartYear", startDate.Year);
                cmd.Parameters.AddWithValue("@StartMonth", startDate.Month);
                cmd.Parameters.AddWithValue("@EndYear", endDate.Year);
                cmd.Parameters.AddWithValue("@EndMonth", endDate.Month);
                
                conn.Open();
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        int year = Convert.ToInt32(reader["Year"]);
                        int month = Convert.ToInt32(reader["MonthNum"]);
                        decimal goalValue = Convert.ToDecimal(reader["GoalValue"]);
                        
                        string monthKey = year.ToString("0000") + "-" + month.ToString("00");
                        monthlyGoalsDict[monthKey] = goalValue;
                        
                        // Always use full month goal - no proration
                        // MTD = full month goal, YTD = sum of all month goals, etc.
                        totalGoal += goalValue;
                    }
                }
            }
            
            hfScrapGoal.Value = totalGoal.ToString("0.00");
            
            var serializer = new JavaScriptSerializer();
            hfScrapMonthlyGoals.Value = serializer.Serialize(monthlyGoalsDict);
            
            // Also load line-specific monthly goals for all lines
            LoadScrapLineMonthlyGoals(startDate, endDate);
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("LoadScrapGoal error: " + ex.Message);
            hfScrapGoal.Value = "0";
            hfScrapMonthlyGoals.Value = "{}";
            hfScrapLineMonthlyGoals.Value = "{}";
        }
    }
    
    private void LoadScrapLineMonthlyGoals(DateTime startDate, DateTime endDate)
    {
        try
        {
            string sql = @"
                SELECT LineName, Year, MonthNum, GoalValue
                FROM QualityGoals 
                WHERE Plant = 'YPO'
                    AND MetricType = 'Scrap'
                    AND ((Year = @StartYear AND MonthNum >= @StartMonth) OR (Year > @StartYear))
                    AND ((Year = @EndYear AND MonthNum <= @EndMonth) OR (Year < @EndYear))
                ORDER BY LineName, Year, MonthNum";
            
            var lineMonthlyGoalsDict = new Dictionary<string, Dictionary<string, decimal>>();
            
            using (var conn = new SqlConnection(TEConnectionString))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@StartYear", startDate.Year);
                cmd.Parameters.AddWithValue("@StartMonth", startDate.Month);
                cmd.Parameters.AddWithValue("@EndYear", endDate.Year);
                cmd.Parameters.AddWithValue("@EndMonth", endDate.Month);
                
                conn.Open();
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string lineName = reader["LineName"].ToString();
                        int year = Convert.ToInt32(reader["Year"]);
                        int month = Convert.ToInt32(reader["MonthNum"]);
                        decimal goalValue = Convert.ToDecimal(reader["GoalValue"]);
                        
                        string monthKey = year.ToString("0000") + "-" + month.ToString("00");
                        
                        if (!lineMonthlyGoalsDict.ContainsKey(lineName))
                        {
                            lineMonthlyGoalsDict[lineName] = new Dictionary<string, decimal>();
                        }
                        lineMonthlyGoalsDict[lineName][monthKey] = goalValue;
                    }
                }
            }
            
            var serializer = new JavaScriptSerializer();
            hfScrapLineMonthlyGoals.Value = serializer.Serialize(lineMonthlyGoalsDict);
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("LoadScrapLineMonthlyGoals error: " + ex.Message);
            hfScrapLineMonthlyGoals.Value = "{}";
        }
    }
    
    private void LoadScrapByLineData()
    {
        try
        {
            string ledger = ddlLedger.SelectedValue;
            string line = ddlScrapLine.SelectedValue;
            
            DateTime startDate, endDate;
            DateTime.TryParseExact(txtScrapStartDate.Text, "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out startDate);
            DateTime.TryParseExact(txtScrapEndDate.Text, "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out endDate);
            
            if (startDate == DateTime.MinValue) startDate = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1);
            if (endDate == DateTime.MinValue) endDate = DateTime.Now;
            
            string ledgerCriteria = ledger == "ALL" ? "" : " AND m.Ledger = @Ledger ";
            string lineCriteria = line == "ALL" ? "" : " AND m.LineName = @Line ";
            
            string sql = @"
                SELECT 
                    ISNULL(m.LineName, 'Unknown') AS LineName,
                    ABS(ISNULL(SUM(CASE WHEN s.MovementType = 551 THEN s.Amount ELSE -s.Amount END), 0)) AS NetScrap
                FROM ZMMR_ScrapData s
                LEFT JOIN MRPControllerLineMapping m ON 
                    CASE 
                        WHEN s.MRPControllerCode IS NOT NULL THEN LEFT(s.MRPControllerCode, 1)
                        ELSE LEFT(s.MRPControllerDesc, 1)
                    END = m.CodePrefix
                WHERE s.PostingDate BETWEEN @StartDate AND @EndDate
                    AND s.MovementType IN (551, 552)
                    " + ledgerCriteria + lineCriteria + @"
                GROUP BY m.LineName
                HAVING ABS(SUM(CASE WHEN s.MovementType = 551 THEN s.Amount ELSE -s.Amount END)) > 0
                ORDER BY NetScrap DESC";
            
            var lineData = new List<object>();
            
            using (var conn = new SqlConnection(TEConnectionString))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@StartDate", startDate.Date);
                cmd.Parameters.AddWithValue("@EndDate", endDate.Date);
                if (ledger != "ALL") cmd.Parameters.AddWithValue("@Ledger", ledger);
                if (line != "ALL") cmd.Parameters.AddWithValue("@Line", MapLineNameToScrapGoalLine(line));
                
                conn.Open();
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string lineName = reader["LineName"].ToString();
                        decimal actual = Convert.ToDecimal(reader["NetScrap"]);
                        
                        // Get goal for this line (simplified - use a proportional goal)
                        decimal lineGoal = GetLineScrapGoal(lineName, startDate, endDate);
                        
                        lineData.Add(new { 
                            line = lineName, 
                            goal = lineGoal, 
                            actual = actual 
                        });
                    }
                }
            }
            
            var serializer = new JavaScriptSerializer();
            hfScrapByLineData.Value = serializer.Serialize(lineData);
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("LoadScrapByLineData error: " + ex.Message);
            hfScrapByLineData.Value = "[]";
        }
    }
    
    private decimal GetLineScrapGoal(string lineName, DateTime startDate, DateTime endDate)
    {
        try
        {
            // Map the line name to the scrap goal line name format
            string mappedLineName = MapLineNameToScrapGoalLine(lineName);
            
            string sql = @"
                SELECT 
                    Year, MonthNum, GoalValue
                FROM QualityGoals 
                WHERE Plant = 'YPO'
                    AND MetricType = 'Scrap'
                    AND LineName = @LineName
                    AND ((Year = @StartYear AND MonthNum >= @StartMonth) OR (Year > @StartYear))
                    AND ((Year = @EndYear AND MonthNum <= @EndMonth) OR (Year < @EndYear))";
            
            decimal totalGoal = 0;
            
            using (var conn = new SqlConnection(TEConnectionString))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@LineName", mappedLineName);
                cmd.Parameters.AddWithValue("@StartYear", startDate.Year);
                cmd.Parameters.AddWithValue("@StartMonth", startDate.Month);
                cmd.Parameters.AddWithValue("@EndYear", endDate.Year);
                cmd.Parameters.AddWithValue("@EndMonth", endDate.Month);
                
                conn.Open();
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        int year = Convert.ToInt32(reader["Year"]);
                        int month = Convert.ToInt32(reader["MonthNum"]);
                        decimal goalValue = Convert.ToDecimal(reader["GoalValue"]);
                        
                        // Always use full month goal - no proration
                        // MTD = full month goal, YTD = sum of all month goals, etc.
                        totalGoal += goalValue;
                    }
                }
            }
            
            return totalGoal;
        }
        catch
        {
            return 0;
        }
    }
    
    private void LoadScrapDailyData()
    {
        try
        {
            string ledger = ddlLedger.SelectedValue;
            string line = ddlScrapLine.SelectedValue;
            
            DateTime startDate, endDate;
            DateTime.TryParseExact(txtScrapStartDate.Text, "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out startDate);
            DateTime.TryParseExact(txtScrapEndDate.Text, "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out endDate);
            
            if (startDate == DateTime.MinValue) startDate = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1);
            if (endDate == DateTime.MinValue) endDate = DateTime.Now;
            
            string ledgerCriteria = ledger == "ALL" ? "" : " AND m.Ledger = @Ledger ";
            string lineCriteria = line == "ALL" ? "" : " AND m.LineName = @Line ";
            
            string sql = @"
                SELECT 
                    CAST(s.PostingDate AS DATE) AS ScrapDate,
                    ABS(ISNULL(SUM(CASE WHEN s.MovementType = 551 THEN s.Amount ELSE -s.Amount END), 0)) AS NetScrap
                FROM ZMMR_ScrapData s
                LEFT JOIN MRPControllerLineMapping m ON 
                    CASE 
                        WHEN s.MRPControllerCode IS NOT NULL THEN LEFT(s.MRPControllerCode, 1)
                        ELSE LEFT(s.MRPControllerDesc, 1)
                    END = m.CodePrefix
                WHERE s.PostingDate BETWEEN @StartDate AND @EndDate
                    AND s.MovementType IN (551, 552)
                    " + ledgerCriteria + lineCriteria + @"
                GROUP BY CAST(s.PostingDate AS DATE)
                HAVING ABS(SUM(CASE WHEN s.MovementType = 551 THEN s.Amount ELSE -s.Amount END)) > 0
                ORDER BY ScrapDate";
            
            var labels = new List<string>();
            var sortDates = new List<string>();
            var data = new List<decimal>();
            var cumulative = new List<decimal>();
            var dailyGoals = new List<decimal>();
            
            // Get monthly goals for calculating daily targets
            // When Plantwide is selected, SUM all line scrap goals
            var monthlyGoals = new Dictionary<string, decimal>();
            
            string goalSql;
            if (line == "ALL")
            {
                // Sum all line goals for plantwide
                goalSql = @"
                    SELECT Year, MonthNum, SUM(GoalValue) AS GoalValue
                    FROM QualityGoals 
                    WHERE Plant = 'YPO' AND MetricType = 'Scrap' 
                      AND LineName NOT IN ('Plant', 'Plantwide', 'YPO', 'YPO (Plant)')
                    GROUP BY Year, MonthNum";
                
                using (var conn = new SqlConnection(TEConnectionString))
                using (var cmd = new SqlCommand(goalSql, conn))
                {
                    conn.Open();
                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string monthKey = reader["Year"].ToString() + "-" + Convert.ToInt32(reader["MonthNum"]).ToString("00");
                            monthlyGoals[monthKey] = Convert.ToDecimal(reader["GoalValue"]);
                        }
                    }
                }
            }
            else
            {
                // Get goal for specific line
                string mappedLineName = MapLineNameToScrapGoalLine(line);
                goalSql = @"
                    SELECT Year, MonthNum, GoalValue
                    FROM QualityGoals 
                    WHERE Plant = 'YPO' AND MetricType = 'Scrap' AND LineName = @LineName";
                
                using (var conn = new SqlConnection(TEConnectionString))
                using (var cmd = new SqlCommand(goalSql, conn))
                {
                    cmd.Parameters.AddWithValue("@LineName", mappedLineName);
                    conn.Open();
                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string monthKey = reader["Year"].ToString() + "-" + Convert.ToInt32(reader["MonthNum"]).ToString("00");
                            monthlyGoals[monthKey] = Convert.ToDecimal(reader["GoalValue"]);
                        }
                    }
                }
            }
            
            using (var conn = new SqlConnection(TEConnectionString))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@StartDate", startDate.Date);
                cmd.Parameters.AddWithValue("@EndDate", endDate.Date);
                if (ledger != "ALL") cmd.Parameters.AddWithValue("@Ledger", ledger);
                if (line != "ALL") cmd.Parameters.AddWithValue("@Line", line);
                
                conn.Open();
                decimal runningTotal = 0;
                
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        DateTime scrapDate = Convert.ToDateTime(reader["ScrapDate"]);
                        decimal netScrap = Convert.ToDecimal(reader["NetScrap"]);
                        
                        // Use M/d format (Month/Day) to match Yield charts
                        labels.Add(scrapDate.ToString("M/d"));
                        sortDates.Add(scrapDate.ToString("yyyy-MM-dd"));
                        data.Add(netScrap);
                        
                        runningTotal += netScrap;
                        cumulative.Add(runningTotal);
                        
                        // Calculate daily goal from monthly goal
                        string monthKey = scrapDate.ToString("yyyy-MM");
                        decimal monthlyGoal = monthlyGoals.ContainsKey(monthKey) ? monthlyGoals[monthKey] : 0;
                        int daysInMonth = DateTime.DaysInMonth(scrapDate.Year, scrapDate.Month);
                        decimal dailyGoal = monthlyGoal / daysInMonth;
                        dailyGoals.Add(dailyGoal);
                    }
                }
            }
            
            var serializer = new JavaScriptSerializer();
            hfScrapDailyLabels.Value = serializer.Serialize(labels);
            hfScrapDailySortDates.Value = serializer.Serialize(sortDates);
            hfScrapDailyData.Value = serializer.Serialize(data);
            hfScrapDailyCumulative.Value = serializer.Serialize(cumulative);
            hfScrapDailyGoals.Value = serializer.Serialize(dailyGoals);
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("LoadScrapDailyData error: " + ex.Message);
            hfScrapDailyLabels.Value = "[]";
            hfScrapDailySortDates.Value = "[]";
            hfScrapDailyData.Value = "[]";
            hfScrapDailyCumulative.Value = "[]";
            hfScrapDailyGoals.Value = "[]";
        }
    }
    
    private void LoadTopScrapItems()
    {
        try
        {
            string ledger = ddlLedger.SelectedValue;
            string line = ddlScrapLine.SelectedValue;
            
            DateTime startDate, endDate;
            DateTime.TryParseExact(txtScrapStartDate.Text, "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out startDate);
            DateTime.TryParseExact(txtScrapEndDate.Text, "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out endDate);
            
            if (startDate == DateTime.MinValue) startDate = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1);
            if (endDate == DateTime.MinValue) endDate = DateTime.Now;
            
            string ledgerCriteria = ledger == "ALL" ? "" : " AND m.Ledger = @Ledger ";
            string lineCriteria = line == "ALL" ? "" : " AND m.LineName = @Line ";
            
            string sql = @"
                SELECT TOP 5
                    s.MaterialNumber,
                    MAX(s.MaterialDescription) AS MaterialDescription,
                    ABS(ISNULL(SUM(CASE WHEN s.MovementType = 551 THEN s.Amount ELSE -s.Amount END), 0)) AS NetScrap
                FROM ZMMR_ScrapData s
                LEFT JOIN MRPControllerLineMapping m ON 
                    CASE 
                        WHEN s.MRPControllerCode IS NOT NULL THEN LEFT(s.MRPControllerCode, 1)
                        ELSE LEFT(s.MRPControllerDesc, 1)
                    END = m.CodePrefix
                WHERE s.PostingDate BETWEEN @StartDate AND @EndDate
                    AND s.MovementType IN (551, 552)
                    " + ledgerCriteria + lineCriteria + @"
                GROUP BY s.MaterialNumber
                HAVING ABS(SUM(CASE WHEN s.MovementType = 551 THEN s.Amount ELSE -s.Amount END)) > 0
                ORDER BY NetScrap DESC";
            
            var topItems = new List<object>();
            
            using (var conn = new SqlConnection(TEConnectionString))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@StartDate", startDate.Date);
                cmd.Parameters.AddWithValue("@EndDate", endDate.Date);
                if (ledger != "ALL") cmd.Parameters.AddWithValue("@Ledger", ledger);
                if (line != "ALL") cmd.Parameters.AddWithValue("@Line", MapLineNameToScrapGoalLine(line));
                
                conn.Open();
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        topItems.Add(new {
                            material = reader["MaterialNumber"].ToString(),
                            description = reader["MaterialDescription"].ToString(),
                            amount = Convert.ToDecimal(reader["NetScrap"])
                        });
                    }
                }
            }
            
            var serializer = new JavaScriptSerializer();
            hfTopScrapItems.Value = serializer.Serialize(topItems);
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("LoadTopScrapItems error: " + ex.Message);
            hfTopScrapItems.Value = "[]";
        }
    }
    
    private void LoadScrapByLineDateData()
    {
        try
        {
            string ledger = ddlLedger.SelectedValue;
            string line = ddlScrapLine.SelectedValue;
            
            DateTime startDate, endDate;
            DateTime.TryParseExact(txtScrapStartDate.Text, "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out startDate);
            DateTime.TryParseExact(txtScrapEndDate.Text, "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out endDate);
            
            if (startDate == DateTime.MinValue) startDate = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1);
            if (endDate == DateTime.MinValue) endDate = DateTime.Now;
            
            string ledgerCriteria = ledger == "ALL" ? "" : " AND m.Ledger = @Ledger ";
            string lineCriteria = line == "ALL" ? "" : " AND m.LineName = @Line ";
            
            string sql = @"
                SELECT 
                    ISNULL(m.LineName, 'Unknown') AS LineName,
                    CAST(s.PostingDate AS DATE) AS ScrapDate,
                    ABS(ISNULL(SUM(CASE WHEN s.MovementType = 551 THEN s.Amount ELSE -s.Amount END), 0)) AS NetScrap
                FROM ZMMR_ScrapData s
                LEFT JOIN MRPControllerLineMapping m ON 
                    CASE 
                        WHEN s.MRPControllerCode IS NOT NULL THEN LEFT(s.MRPControllerCode, 1)
                        ELSE LEFT(s.MRPControllerDesc, 1)
                    END = m.CodePrefix
                WHERE s.PostingDate BETWEEN @StartDate AND @EndDate
                    AND s.MovementType IN (551, 552)
                    " + ledgerCriteria + lineCriteria + @"
                GROUP BY m.LineName, CAST(s.PostingDate AS DATE)
                HAVING ABS(SUM(CASE WHEN s.MovementType = 551 THEN s.Amount ELSE -s.Amount END)) > 0
                ORDER BY m.LineName, ScrapDate";
            
            var lineDateData = new List<object>();
            
            using (var conn = new SqlConnection(TEConnectionString))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@StartDate", startDate.Date);
                cmd.Parameters.AddWithValue("@EndDate", endDate.Date);
                if (ledger != "ALL") cmd.Parameters.AddWithValue("@Ledger", ledger);
                if (line != "ALL") cmd.Parameters.AddWithValue("@Line", MapLineNameToScrapGoalLine(line));
                
                conn.Open();
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        DateTime scrapDate = Convert.ToDateTime(reader["ScrapDate"]);
                        lineDateData.Add(new {
                            line = reader["LineName"].ToString(),
                            date = scrapDate.ToString("M/d"),  // Use M/d format (Month/Day) to match Yield charts
                            dateSort = scrapDate.ToString("yyyy-MM-dd"),
                            amount = Convert.ToDecimal(reader["NetScrap"])
                        });
                    }
                }
            }
            
            var serializer = new JavaScriptSerializer();
            hfScrapByLineDateData.Value = serializer.Serialize(lineDateData);
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("LoadScrapByLineDateData error: " + ex.Message);
            hfScrapByLineDateData.Value = "[]";
        }
    }

    #region NCM Data Loading
    
    private void LoadNCMData()
    {
        try
        {
            LoadNCMGoal();
            LoadNCMInventoryData();
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("LoadNCMData error: " + ex.Message);
        }
    }
    
    private void LoadNCMGoal()
    {
        try
        {
            // Load NCM goal from PlantQuality_NCMGoals table for current month
            string sql = @"
                SELECT TOP 1 MonthlyGoal
                FROM PlantQuality_NCMGoals
                WHERE Scope = 'YPO' 
                  AND Year = @Year 
                  AND Month = @Month
                ORDER BY ID DESC";
            
            using (var conn = new SqlConnection(TEConnectionString))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@Year", DateTime.Now.Year);
                cmd.Parameters.AddWithValue("@Month", DateTime.Now.Month);
                
                conn.Open();
                var result = cmd.ExecuteScalar();
                if (result != null && result != DBNull.Value)
                {
                    hfNCMGoal.Value = Convert.ToDecimal(result).ToString("0.00");
                }
                else
                {
                    hfNCMGoal.Value = "75000"; // Default goal
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("LoadNCMGoal error: " + ex.Message);
            hfNCMGoal.Value = "75000";
        }
    }
    
    private void LoadNCMInventoryData()
    {
        try
        {
            // Get the most recent load date (data is pre-filtered on import for Plant/SLoc)
            string sqlLatestDate = @"SELECT MAX(LoadDate) FROM NCM_Warehouse_Inventory";
            
            DateTime? latestLoadDate = null;
            
            using (var conn = new SqlConnection(TEConnectionString))
            using (var cmd = new SqlCommand(sqlLatestDate, conn))
            {
                conn.Open();
                var result = cmd.ExecuteScalar();
                if (result != null && result != DBNull.Value)
                {
                    latestLoadDate = Convert.ToDateTime(result);
                }
            }
            
            if (!latestLoadDate.HasValue)
            {
                // No data available
                hfNCMTotalValue.Value = "0";
                hfNCMDataDate.Value = "";
                hfNCMTopMaterials.Value = "[]";
                hfNCMAllMaterials.Value = "[]";
                return;
            }
            
            // Set data date for display
            hfNCMDataDate.Value = latestLoadDate.Value.ToString("MMM d, yyyy");
            
            // Get aggregated material data for the latest load date only
            string sqlMaterials = @"
                SELECT 
                    MaterialNumber,
                    MAX(MaterialDescription) AS MaterialDescription,
                    SUM(TotalValue) AS TotalValue
                FROM NCM_Warehouse_Inventory
                WHERE CAST(LoadDate AS DATE) = CAST(@LoadDate AS DATE)
                GROUP BY MaterialNumber
                HAVING SUM(TotalValue) > 0
                ORDER BY SUM(TotalValue) DESC";
            
            var allMaterials = new List<object>();
            decimal totalNCMValue = 0;
            
            using (var conn = new SqlConnection(TEConnectionString))
            using (var cmd = new SqlCommand(sqlMaterials, conn))
            {
                cmd.Parameters.AddWithValue("@LoadDate", latestLoadDate.Value);
                
                conn.Open();
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        var materialNumber = reader["MaterialNumber"] != DBNull.Value ? reader["MaterialNumber"].ToString() : "";
                        var materialDescription = reader["MaterialDescription"] != DBNull.Value ? reader["MaterialDescription"].ToString() : "";
                        var value = Convert.ToDecimal(reader["TotalValue"]);
                        
                        totalNCMValue += value;
                        
                        allMaterials.Add(new
                        {
                            materialNumber = materialNumber,
                            materialDescription = materialDescription,
                            totalValue = value
                        });
                    }
                }
            }
            
            var serializer = new JavaScriptSerializer();
            
            hfNCMTotalValue.Value = totalNCMValue.ToString("0.00");
            hfNCMAllMaterials.Value = serializer.Serialize(allMaterials);
            
            // Top 5 for bar chart
            var top5 = allMaterials.Take(5).ToList();
            hfNCMTopMaterials.Value = serializer.Serialize(top5);
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("LoadNCMInventoryData error: " + ex.Message);
            hfNCMTotalValue.Value = "0";
            hfNCMDataDate.Value = "";
            hfNCMTopMaterials.Value = "[]";
            hfNCMAllMaterials.Value = "[]";
        }
    }
    
    #endregion
}
