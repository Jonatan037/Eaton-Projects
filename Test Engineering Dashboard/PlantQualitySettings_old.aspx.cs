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
        
        // Load existing goals from database
        Dictionary<string, Dictionary<int, decimal>> yieldGoals = LoadGoalsFromDB("Yield", year, plant);
        Dictionary<string, Dictionary<int, decimal>> scrapGoals = LoadGoalsFromDB("Scrap", year, plant);
        Dictionary<string, Dictionary<int, decimal>> ncmGoals = LoadGoalsFromDB("NCM", year, plant);
        
        // Generate table rows
        litYieldGoalsRows.Text = GenerateGoalRows(lines, yieldGoals, "yield", plant, 98.0m);
        litScrapGoalsRows.Text = GenerateGoalRows(lines, scrapGoals, "scrap", plant, 2.0m);
        litNCMGoalsRows.Text = GenerateGoalRows(lines, ncmGoals, "ncm", plant, 5.0m);
    }

    private List<string> GetProductionLines(string plant)
    {
        List<string> lines = new List<string>();
        
        try
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
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error loading production lines: " + ex.Message);
        }
        
        return lines;
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
                GoalValue DECIMAL(10,2) NOT NULL,
                UpdatedBy NVARCHAR(100) NULL,
                UpdatedDate DATETIME DEFAULT GETDATE(),
                CONSTRAINT UQ_QualityGoals UNIQUE (Plant, LineName, MetricType, Year, MonthNum)
            )";
        
        using (var cmd = new SqlCommand(createTableSql, conn))
        {
            cmd.ExecuteNonQuery();
        }
    }

    private string GenerateGoalRows(List<string> lines, Dictionary<string, Dictionary<int, decimal>> goals, string metricPrefix, string plant, decimal defaultValue)
    {
        StringBuilder sb = new StringBuilder();
        
        // First row is always the Plant row
        sb.Append("<tr>");
        sb.Append("<td class=\"plant-row\">" + plant + " (Plant)</td>");
        for (int m = 1; m <= 12; m++)
        {
            decimal val = defaultValue;
            if (goals.ContainsKey(plant) && goals[plant].ContainsKey(m))
            {
                val = goals[plant][m];
            }
            sb.Append("<td><input type=\"text\" name=\"" + metricPrefix + "_" + plant + "_" + m + "\" value=\"" + val.ToString("0.##") + "\" /></td>");
        }
        sb.Append("</tr>");
        
        // Then each line
        foreach (string line in lines)
        {
            sb.Append("<tr>");
            sb.Append("<td>" + Server.HtmlEncode(line) + "</td>");
            for (int m = 1; m <= 12; m++)
            {
                decimal val = defaultValue;
                if (goals.ContainsKey(line) && goals[line].ContainsKey(m))
                {
                    val = goals[line][m];
                }
                sb.Append("<td><input type=\"text\" name=\"" + metricPrefix + "_" + Server.HtmlEncode(line) + "_" + m + "\" value=\"" + val.ToString("0.##") + "\" /></td>");
            }
            sb.Append("</tr>");
        }
        
        return sb.ToString();
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
                        if (!decimal.TryParse(Request.Form[key], out goalValue))
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
            
            pnlStatus.Visible = true;
            if (errorCount == 0)
            {
                pnlStatus.CssClass = "status-message success";
                litStatus.Text = "✓ Successfully saved " + savedCount.ToString() + " goal values.";
            }
            else
            {
                pnlStatus.CssClass = "status-message error";
                litStatus.Text = "⚠ Saved " + savedCount.ToString() + " values with " + errorCount.ToString() + " errors.";
            }
        }
        catch (Exception ex)
        {
            pnlStatus.Visible = true;
            pnlStatus.CssClass = "status-message error";
            litStatus.Text = "Error saving goals: " + ex.Message;
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
