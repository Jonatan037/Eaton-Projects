using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Collections.Generic;
using System.Text;

public partial class TED_PlantQualitySettings : Page
{
    private string TEConnectionString
    {
        get
        {
            var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"];
            return cs != null ? cs.ConnectionString : "";
        }
    }

    private string TracksConnectionString
    {
        get
        {
            var cs = ConfigurationManager.ConnectionStrings["TracksConnectionString"];
            if (cs != null) return cs.ConnectionString;
            var tecs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"];
            return tecs != null ? tecs.ConnectionString : "";
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            InitializeYearDropdown();
            LoadGoalsTables();
        }
    }

    private void InitializeYearDropdown()
    {
        int currentYear = DateTime.Now.Year;
        ddlYear.Items.Clear();
        
        // Add years from current year - 1 to current year + 2
        for (int y = currentYear - 1; y <= currentYear + 2; y++)
        {
            ListItem item = new ListItem(y.ToString(), y.ToString());
            if (y == currentYear)
            {
                item.Selected = true;
            }
            ddlYear.Items.Add(item);
        }
    }

    protected void ddlYear_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadGoalsTables();
    }

    protected void ddlPlant_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadGoalsTables();
    }

    private void LoadGoalsTables()
    {
        int year = Convert.ToInt32(ddlYear.SelectedValue);
        string plant = ddlPlant.SelectedValue;
        
        // Get production lines
        List<string> lines = GetProductionLines(plant);
        
        // Get lines grouped by ledger for Scrap display
        Dictionary<string, List<string>> ledgerLines = GetLinesGroupedByLedger(plant);
        
        // Load existing goals from database
        Dictionary<string, Dictionary<int, decimal>> yieldGoals = LoadGoalsFromDB("Yield", year, plant);
        Dictionary<string, Dictionary<int, decimal>> scrapGoals = LoadGoalsFromDB("Scrap", year, plant);
        Dictionary<string, Dictionary<int, decimal>> ncmGoals = LoadGoalsFromDB("NCM", year, plant);
        
        // Generate table rows
        // Yield: Target % per line with YTD column (default 98.0%)
        litYieldGoalsRows.Text = GenerateYieldGoalRowsWithYTD(lines, yieldGoals, plant, 98.0m);
        
        // Scrap: US$ per line, separate tables per Ledger with totals (default $0)
        GenerateScrapLedgerTables(ledgerLines, scrapGoals, 0m);
        
        // NCM: US$ plant-level only with YTD (default $0)
        litNCMGoalsRows.Text = GenerateNCMGoalRowsWithYTD(ncmGoals, plant, 0m);
    }

    private List<string> GetProductionLines(string plant)
    {
        List<string> lines = new List<string>();
        
        try
        {
            // Get lines from MRP Controller mapping
            string mrpSql = @"
                SELECT DISTINCT LineName 
                FROM MRPControllerLineMapping 
                WHERE Plant = @Plant 
                  AND IsActive = 1
                ORDER BY LineName";

            using (var conn = new SqlConnection(TEConnectionString))
            {
                conn.Open();
                
                // Check if MRPControllerLineMapping table exists
                string checkTableSql = @"
                    IF OBJECT_ID('dbo.MRPControllerLineMapping', 'U') IS NOT NULL 
                        SELECT 1 AS TableExists
                    ELSE 
                        SELECT 0 AS TableExists";
                
                using (var checkCmd = new SqlCommand(checkTableSql, conn))
                {
                    int exists = Convert.ToInt32(checkCmd.ExecuteScalar());
                    if (exists == 1)
                    {
                        using (var cmd = new SqlCommand(mrpSql, conn))
                        {
                            cmd.Parameters.AddWithValue("@Plant", plant);
                            using (var reader = cmd.ExecuteReader())
                            {
                                while (reader.Read())
                                {
                                    string lineName = reader["LineName"].ToString();
                                    if (!string.IsNullOrWhiteSpace(lineName) && !lines.Contains(lineName))
                                    {
                                        lines.Add(lineName);
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // If no lines from MRP mapping, try the legacy method from Tracks
            if (lines.Count == 0)
            {
                string sql = @"
                    SELECT DISTINCT FAMILY 
                    FROM View_PowerBI_MASTER_INDEX 
                    WHERE PLANT LIKE @Plant + '%' 
                      AND FAMILY NOT LIKE '%Failure Analysis%'
                      AND FAMILY IS NOT NULL
                      AND FAMILY <> ''
                    ORDER BY FAMILY";

                using (var conn = new SqlConnection(TracksConnectionString))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@Plant", plant);
                    conn.Open();

                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string family = reader["FAMILY"].ToString();
                            if (!string.IsNullOrWhiteSpace(family))
                            {
                                lines.Add(family);
                            }
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error loading production lines: " + ex.Message);
        }
        
        return lines;
    }
    
    /// <summary>
    /// Get lines grouped by Ledger for Scrap Goals display
    /// Returns Dictionary where key = Ledger, value = List of lines in that ledger
    /// </summary>
    private Dictionary<string, List<string>> GetLinesGroupedByLedger(string plant)
    {
        Dictionary<string, List<string>> ledgerLines = new Dictionary<string, List<string>>();
        
        try
        {
            string sql = @"
                SELECT LineName, ISNULL(Ledger, 'Other') AS Ledger
                FROM MRPControllerLineMapping 
                WHERE Plant = @Plant 
                  AND IsActive = 1
                ORDER BY Ledger, LineName";

            using (var conn = new SqlConnection(TEConnectionString))
            {
                conn.Open();
                
                // Check if Ledger column exists
                string checkColumnSql = @"
                    SELECT COUNT(*) FROM sys.columns 
                    WHERE object_id = OBJECT_ID('dbo.MRPControllerLineMapping') 
                    AND name = 'Ledger'";
                
                using (var checkCmd = new SqlCommand(checkColumnSql, conn))
                {
                    int hasLedger = Convert.ToInt32(checkCmd.ExecuteScalar());
                    if (hasLedger == 0)
                    {
                        // Ledger column doesn't exist, return all lines under "All Lines"
                        List<string> allLines = GetProductionLines(plant);
                        ledgerLines["All Lines"] = allLines;
                        return ledgerLines;
                    }
                }
                
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@Plant", plant);
                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string lineName = reader["LineName"].ToString();
                            string ledger = reader["Ledger"].ToString();
                            
                            if (string.IsNullOrWhiteSpace(ledger)) ledger = "Other";
                            
                            if (!ledgerLines.ContainsKey(ledger))
                            {
                                ledgerLines[ledger] = new List<string>();
                            }
                            
                            if (!string.IsNullOrWhiteSpace(lineName) && !ledgerLines[ledger].Contains(lineName))
                            {
                                ledgerLines[ledger].Add(lineName);
                            }
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error loading lines by ledger: " + ex.Message);
            // Fallback to simple line list
            List<string> allLines = GetProductionLines(plant);
            ledgerLines["All Lines"] = allLines;
        }
        
        return ledgerLines;
    }

    private Dictionary<string, Dictionary<int, decimal>> LoadGoalsFromDB(string metricType, int year, string plant)
    {
        Dictionary<string, Dictionary<int, decimal>> goals = new Dictionary<string, Dictionary<int, decimal>>();
        
        try
        {
            // Check if table exists first
            string checkTableSql = @"
                IF OBJECT_ID('dbo.QualityGoals', 'U') IS NOT NULL 
                    SELECT 1 AS TableExists
                ELSE 
                    SELECT 0 AS TableExists";
            
            using (var conn = new SqlConnection(TEConnectionString))
            {
                conn.Open();
                
                using (var checkCmd = new SqlCommand(checkTableSql, conn))
                {
                    int exists = Convert.ToInt32(checkCmd.ExecuteScalar());
                    if (exists == 0)
                    {
                        // Create the table if it doesn't exist
                        CreateGoalsTable(conn);
                    }
                }
                
                string sql = @"
                    SELECT LineName, MonthNum, GoalValue 
                    FROM QualityGoals 
                    WHERE MetricType = @MetricType 
                      AND Year = @Year 
                      AND Plant = @Plant";
                
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@MetricType", metricType);
                    cmd.Parameters.AddWithValue("@Year", year);
                    cmd.Parameters.AddWithValue("@Plant", plant);
                    
                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string lineName = reader["LineName"].ToString();
                            int month = Convert.ToInt32(reader["MonthNum"]);
                            decimal value = Convert.ToDecimal(reader["GoalValue"]);
                            
                            if (!goals.ContainsKey(lineName))
                            {
                                goals[lineName] = new Dictionary<int, decimal>();
                            }
                            goals[lineName][month] = value;
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error loading goals: " + ex.Message);
        }
        
        return goals;
    }

    private void CreateGoalsTable(SqlConnection conn)
    {
        string createTableSql = @"
            CREATE TABLE QualityGoals (
                Id INT IDENTITY(1,1) PRIMARY KEY,
                Plant NVARCHAR(10) NOT NULL,
                LineName NVARCHAR(100) NOT NULL,
                MetricType NVARCHAR(20) NOT NULL,
                Year INT NOT NULL,
                MonthNum INT NOT NULL,
                GoalValue DECIMAL(18,2) NOT NULL,
                UpdatedBy NVARCHAR(100) NULL,
                UpdatedDate DATETIME DEFAULT GETDATE(),
                CONSTRAINT UQ_QualityGoals UNIQUE (Plant, LineName, MetricType, Year, MonthNum)
            )";
        
        using (var cmd = new SqlCommand(createTableSql, conn))
        {
            cmd.ExecuteNonQuery();
        }
    }

    /// <summary>
    /// Generate Yield goal rows with YTD column (Target % per line, including plant row)
    /// </summary>
    private string GenerateYieldGoalRowsWithYTD(List<string> lines, Dictionary<string, Dictionary<int, decimal>> goals, string plant, decimal defaultValue)
    {
        StringBuilder sb = new StringBuilder();
        
        // First row is always the Plant row
        sb.Append("<tr>");
        sb.Append("<td class=\"plant-row\">" + Server.HtmlEncode(plant) + " (Plant)</td>");
        sb.Append("<td class=\"ytd-cell\">--</td>"); // YTD calculated by JS
        for (int m = 1; m <= 12; m++)
        {
            decimal val = defaultValue;
            if (goals.ContainsKey(plant) && goals[plant].ContainsKey(m))
            {
                val = goals[plant][m];
            }
            sb.Append("<td><input type=\"text\" class=\"goal-input percent-input\" name=\"yield_" + Server.HtmlEncode(plant) + "_" + m + "\" value=\"" + val.ToString("0.00") + "\" /></td>");
        }
        sb.Append("</tr>");
        
        // Then each line
        foreach (string line in lines)
        {
            sb.Append("<tr>");
            sb.Append("<td>" + Server.HtmlEncode(line) + "</td>");
            sb.Append("<td class=\"ytd-cell\">--</td>"); // YTD calculated by JS
            for (int m = 1; m <= 12; m++)
            {
                decimal val = defaultValue;
                if (goals.ContainsKey(line) && goals[line].ContainsKey(m))
                {
                    val = goals[line][m];
                }
                sb.Append("<td><input type=\"text\" class=\"goal-input percent-input\" name=\"yield_" + Server.HtmlEncode(line) + "_" + m + "\" value=\"" + val.ToString("0.00") + "\" /></td>");
            }
            sb.Append("</tr>");
        }
        
        return sb.ToString();
    }
    
    /// <summary>
    /// Generate Yield goal rows (Target % per line, including plant row) - Legacy
    /// </summary>
    private string GenerateYieldGoalRows(List<string> lines, Dictionary<string, Dictionary<int, decimal>> goals, string plant, decimal defaultValue)
    {
        return GenerateYieldGoalRowsWithYTD(lines, goals, plant, defaultValue);
    }

    /// <summary>
    /// Generate Scrap goal rows (US$ per line)
    /// </summary>
    private string GenerateScrapGoalRows(List<string> lines, Dictionary<string, Dictionary<int, decimal>> goals, string plant, decimal defaultValue)
    {
        StringBuilder sb = new StringBuilder();
        
        // For Scrap, we show each line (no plant-level row since it's per-line only)
        foreach (string line in lines)
        {
            sb.Append("<tr>");
            sb.Append("<td>" + Server.HtmlEncode(line) + "</td>");
            sb.Append("<td class=\"ytd-cell\">--</td>"); // YTD calculated by JS
            for (int m = 1; m <= 12; m++)
            {
                decimal val = defaultValue;
                if (goals.ContainsKey(line) && goals[line].ContainsKey(m))
                {
                    val = goals[line][m];
                }
                sb.Append("<td><span class=\"input-wrapper\"><span class=\"input-prefix\">$</span><input type=\"text\" class=\"goal-input dollar-input\" name=\"scrap_" + Server.HtmlEncode(line) + "_" + m + "\" value=\"" + val.ToString("0.00") + "\" /></span></td>");
            }
            sb.Append("</tr>");
        }
        
        return sb.ToString();
    }
    
    /// <summary>
    /// Generate Scrap tables for each ledger with line rows, ledger totals, and YTD
    /// </summary>
    private void GenerateScrapLedgerTables(Dictionary<string, List<string>> ledgerLines, Dictionary<string, Dictionary<int, decimal>> goals, decimal defaultValue)
    {
        // SPD Ledger
        if (ledgerLines.ContainsKey("SPD") && ledgerLines["SPD"].Count > 0)
        {
            litScrapSPDRows.Text = GenerateScrapRowsForLedger(ledgerLines["SPD"], goals, defaultValue, "SPD");
        }
        else
        {
            litScrapSPDRows.Text = "<tr><td colspan=\"14\" style=\"text-align:center;color:rgba(0,0,0,0.4);padding:20px;\">No lines assigned to SPD Ledger</td></tr>";
        }
        
        // D-IT Ledger
        if (ledgerLines.ContainsKey("D-IT") && ledgerLines["D-IT"].Count > 0)
        {
            litScrapDITRows.Text = GenerateScrapRowsForLedger(ledgerLines["D-IT"], goals, defaultValue, "D-IT");
        }
        else
        {
            litScrapDITRows.Text = "<tr><td colspan=\"14\" style=\"text-align:center;color:rgba(0,0,0,0.4);padding:20px;\">No lines assigned to D-IT Ledger</td></tr>";
        }
        
        // Energy Transition Ledger
        if (ledgerLines.ContainsKey("Energy Transition") && ledgerLines["Energy Transition"].Count > 0)
        {
            litScrapETRows.Text = GenerateScrapRowsForLedger(ledgerLines["Energy Transition"], goals, defaultValue, "EnergyTransition");
        }
        else
        {
            litScrapETRows.Text = "<tr><td colspan=\"14\" style=\"text-align:center;color:rgba(0,0,0,0.4);padding:20px;\">No lines assigned to Energy Transition Ledger</td></tr>";
        }
    }
    
    /// <summary>
    /// Generate scrap rows for a specific ledger with YTD and ledger total row
    /// </summary>
    private string GenerateScrapRowsForLedger(List<string> lines, Dictionary<string, Dictionary<int, decimal>> goals, decimal defaultValue, string ledgerName)
    {
        StringBuilder sb = new StringBuilder();
        
        // Line rows with editable inputs
        foreach (string line in lines)
        {
            sb.Append("<tr>");
            sb.Append("<td>" + Server.HtmlEncode(line) + "</td>");
            sb.Append("<td class=\"ytd-cell\">--</td>"); // YTD calculated by JS
            for (int m = 1; m <= 12; m++)
            {
                decimal val = defaultValue;
                if (goals.ContainsKey(line) && goals[line].ContainsKey(m))
                {
                    val = goals[line][m];
                }
                sb.Append("<td><span class=\"input-wrapper\"><span class=\"input-prefix\">$</span><input type=\"text\" class=\"goal-input dollar-input\" name=\"scrap_" + Server.HtmlEncode(line) + "_" + m + "\" value=\"" + val.ToString("0.00") + "\" /></span></td>");
            }
            sb.Append("</tr>");
        }
        
        // Ledger total row (non-editable, calculated by JS)
        sb.Append("<tr class=\"ledger-total-row\">");
        sb.Append("<td>" + Server.HtmlEncode(ledgerName) + " Total</td>");
        sb.Append("<td class=\"ytd-cell\">--</td>"); // YTD total calculated by JS
        for (int m = 1; m <= 12; m++)
        {
            sb.Append("<td>--</td>"); // Monthly totals calculated by JS
        }
        sb.Append("</tr>");
        
        return sb.ToString();
    }
    
    /// <summary>
    /// Generate Scrap goal rows grouped by Ledger (US$ per line) - Legacy kept for reference
    /// Shows ledger header rows with lines under each ledger
    /// </summary>
    private string GenerateScrapGoalRowsWithLedger(Dictionary<string, List<string>> ledgerLines, Dictionary<string, Dictionary<int, decimal>> goals, decimal defaultValue)
    {
        // This method is no longer used - we now use separate tables per ledger
        return "";
    }

    /// <summary>
    /// Generate NCM goal rows with YTD column (US$ plant-level only - single row)
    /// </summary>
    private string GenerateNCMGoalRowsWithYTD(Dictionary<string, Dictionary<int, decimal>> goals, string plant, decimal defaultValue)
    {
        StringBuilder sb = new StringBuilder();
        
        // NCM is plant-level only - single row
        sb.Append("<tr>");
        sb.Append("<td class=\"plant-row\">" + Server.HtmlEncode(plant) + " (Plant Total)</td>");
        sb.Append("<td class=\"ytd-cell\">--</td>"); // YTD calculated by JS
        for (int m = 1; m <= 12; m++)
        {
            decimal val = defaultValue;
            if (goals.ContainsKey(plant) && goals[plant].ContainsKey(m))
            {
                val = goals[plant][m];
            }
            sb.Append("<td><span class=\"input-wrapper\"><span class=\"input-prefix\">$</span><input type=\"text\" class=\"goal-input dollar-input\" name=\"ncm_" + Server.HtmlEncode(plant) + "_" + m + "\" value=\"" + val.ToString("0.00") + "\" /></span></td>");
        }
        sb.Append("</tr>");
        
        return sb.ToString();
    }

    /// <summary>
    /// Generate NCM goal rows (US$ plant-level only - single row) - Legacy
    /// </summary>
    private string GenerateNCMGoalRows(Dictionary<string, Dictionary<int, decimal>> goals, string plant, decimal defaultValue)
    {
        return GenerateNCMGoalRowsWithYTD(goals, plant, defaultValue);
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        int year = Convert.ToInt32(ddlYear.SelectedValue);
        string plant = ddlPlant.SelectedValue;
        string username = Page.User.Identity.Name;
        if (string.IsNullOrEmpty(username)) username = "System";
        
        int savedCount = 0;
        int errorCount = 0;
        
        try
        {
            using (var conn = new SqlConnection(TEConnectionString))
            {
                conn.Open();
                
                // Process each form value
                foreach (string key in Request.Form.AllKeys)
                {
                    if (key == null) continue;
                    
                    // Parse keys like "yield_LineName_1" or "scrap_Plant_12"
                    string[] parts = key.Split('_');
                    if (parts.Length >= 3)
                    {
                        string metricType = "";
                        if (parts[0] == "yield") metricType = "Yield";
                        else if (parts[0] == "scrap") metricType = "Scrap";
                        else if (parts[0] == "ncm") metricType = "NCM";
                        else continue;
                        
                        // Line name might contain underscores, so join all middle parts
                        int monthNum = 0;
                        if (!int.TryParse(parts[parts.Length - 1], out monthNum) || monthNum < 1 || monthNum > 12)
                        {
                            continue;
                        }
                        
                        string lineName = string.Join("_", parts, 1, parts.Length - 2);
                        
                        decimal goalValue = 0;
                        // Remove any currency symbols or commas before parsing
                        string rawValue = Request.Form[key].Replace("$", "").Replace(",", "").Trim();
                        if (!decimal.TryParse(rawValue, out goalValue))
                        {
                            continue;
                        }
                        
                        // Upsert the goal
                        try
                        {
                            SaveGoal(conn, plant, lineName, metricType, year, monthNum, goalValue, username);
                            savedCount++;
                        }
                        catch
                        {
                            errorCount++;
                        }
                    }
                }
            }
            
            if (errorCount == 0)
            {
                // Use toast notification for success
                hfToastMessage.Value = "Successfully saved " + savedCount.ToString() + " goal values.";
                hfToastType.Value = "success";
            }
            else
            {
                // Use toast notification for partial success with errors
                hfToastMessage.Value = "Saved " + savedCount.ToString() + " values with " + errorCount.ToString() + " errors.";
                hfToastType.Value = "error";
            }
            
            // Reload the tables to show updated values
            LoadGoalsTables();
        }
        catch (Exception ex)
        {
            // Use toast notification for error
            hfToastMessage.Value = "Error saving goals: " + ex.Message;
            hfToastType.Value = "error";
        }
    }

    private void SaveGoal(SqlConnection conn, string plant, string lineName, string metricType, int year, int monthNum, decimal goalValue, string username)
    {
        string sql = @"
            MERGE QualityGoals AS target
            USING (SELECT @Plant AS Plant, @LineName AS LineName, @MetricType AS MetricType, @Year AS Year, @MonthNum AS MonthNum) AS source
            ON (target.Plant = source.Plant 
                AND target.LineName = source.LineName 
                AND target.MetricType = source.MetricType 
                AND target.Year = source.Year 
                AND target.MonthNum = source.MonthNum)
            WHEN MATCHED THEN
                UPDATE SET GoalValue = @GoalValue, UpdatedBy = @UpdatedBy, UpdatedDate = GETDATE()
            WHEN NOT MATCHED THEN
                INSERT (Plant, LineName, MetricType, Year, MonthNum, GoalValue, UpdatedBy, UpdatedDate)
                VALUES (@Plant, @LineName, @MetricType, @Year, @MonthNum, @GoalValue, @UpdatedBy, GETDATE());";
        
        using (var cmd = new SqlCommand(sql, conn))
        {
            cmd.Parameters.AddWithValue("@Plant", plant);
            cmd.Parameters.AddWithValue("@LineName", lineName);
            cmd.Parameters.AddWithValue("@MetricType", metricType);
            cmd.Parameters.AddWithValue("@Year", year);
            cmd.Parameters.AddWithValue("@MonthNum", monthNum);
            cmd.Parameters.AddWithValue("@GoalValue", goalValue);
            cmd.Parameters.AddWithValue("@UpdatedBy", username);
            cmd.ExecuteNonQuery();
        }
    }
}
