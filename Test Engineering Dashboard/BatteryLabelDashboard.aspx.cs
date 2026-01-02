using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class TED_BatteryLabelDashboard : Page
{
    private readonly string _connectionString;

    private string CurrentPeriod
    {
        get { return ViewState["CurrentPeriod"] as string ?? "Day"; }
        set { ViewState["CurrentPeriod"] = value; }
    }

    public TED_BatteryLabelDashboard()
    {
        var settings = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"];
        _connectionString = settings != null ? settings.ConnectionString : null;
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        // Handle auto-refresh postback
        if (IsPostBack && Request.Params["__EVENTTARGET"] == "" && Request.Params["__EVENTARGUMENT"] == "AutoRefresh")
        {
            LoadDashboard();
            return;
        }

        if (!IsPostBack)
        {
            LoadDashboard();
        }
    }

    protected void btnPeriod_Click(object sender, EventArgs e)
    {
        var btn = sender as Button;
        if (btn == null) return;

        var period = btn.CommandArgument;
        CurrentPeriod = period;
        UpdatePeriodButtonStates(period);
        
        if (period == "Custom")
        {
            // Show custom date range controls
            customDateRange.Style["display"] = "flex";
            
            // Set default dates if not already set
            if (string.IsNullOrWhiteSpace(txtStartDate.Text))
            {
                txtStartDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
            }
            if (string.IsNullOrWhiteSpace(txtEndDate.Text))
            {
                txtEndDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
            }
        }
        else
        {
            // Hide custom date range controls
            customDateRange.Style["display"] = "none";
            LoadDashboard();
        }
    }

    protected void btnApplyCustom_Click(object sender, EventArgs e)
    {
        DateTime startDate, endDate;
        
        if (DateTime.TryParse(txtStartDate.Text, out startDate) && DateTime.TryParse(txtEndDate.Text, out endDate))
        {
            if (startDate > endDate)
            {
                // Swap if start is after end
                var temp = startDate;
                startDate = endDate;
                endDate = temp;
                txtStartDate.Text = startDate.ToString("yyyy-MM-dd");
                txtEndDate.Text = endDate.ToString("yyyy-MM-dd");
            }
            
            litDateRange.Text = string.Format("{0:MMM dd, yyyy} - {1:MMM dd, yyyy}", startDate, endDate);
            
            // Store custom dates in ViewState for filter operations
            ViewState["CustomStartDate"] = startDate;
            ViewState["CustomEndDate"] = endDate;
            
            LoadMetricsAndTimeline(startDate, endDate);
        }
    }

    protected void ddlLineFilter_SelectedIndexChanged(object sender, EventArgs e)
    {
        ReloadCurrentPeriod();
    }

    protected void ddlStatusFilter_SelectedIndexChanged(object sender, EventArgs e)
    {
        ReloadCurrentPeriod();
    }

    protected void txtSerialSearch_TextChanged(object sender, EventArgs e)
    {
        ReloadCurrentPeriod();
    }

    private void ReloadCurrentPeriod()
    {
        if (CurrentPeriod == "Custom" && ViewState["CustomStartDate"] != null && ViewState["CustomEndDate"] != null)
        {
            var startDate = (DateTime)ViewState["CustomStartDate"];
            var endDate = (DateTime)ViewState["CustomEndDate"];
            LoadMetricsAndTimeline(startDate, endDate);
        }
        else
        {
            LoadDashboard();
        }
    }

    private void LoadDashboard()
    {
        var period = CurrentPeriod;
        DateTime startDate, endDate;

        switch (period)
        {
            case "Yesterday":
                startDate = DateTime.Today.AddDays(-1);
                endDate = DateTime.Today.AddDays(-1);
                customDateRange.Style["display"] = "none";
                break;
            case "Week":
                startDate = DateTime.Today.AddDays(-(int)DateTime.Today.DayOfWeek);
                endDate = DateTime.Today;
                customDateRange.Style["display"] = "none";
                break;
            case "Month":
                startDate = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1);
                endDate = DateTime.Today;
                customDateRange.Style["display"] = "none";
                break;
            case "Custom":
                // Don't load yet - wait for user to click Apply
                customDateRange.Style["display"] = "flex";
                return;
            default:
                startDate = DateTime.Today;
                endDate = DateTime.Today;
                period = "Day";
                customDateRange.Style["display"] = "none";
                break;
        }

        UpdatePeriodButtonStates(period);
        litDateRange.Text = string.Format("{0:MMM dd, yyyy} - {1:MMM dd, yyyy}", startDate, endDate);

        LoadMetricsAndTimeline(startDate, endDate);
    }

    private void LoadMetricsAndTimeline(DateTime startDate, DateTime endDate)
    {
        try
        {
            // Get tested units from SQL
            var testedUnits = GetTestedUnitsFromSQL(startDate, endDate);
            
            // Get validations from SQL
            var validations = GetValidationsFromSQL(startDate, endDate);

            // Calculate metrics per line
            var lines = new[] { "Line 1", "Line 2", "Line 3", "Line 4" };
            var lineMetrics = new Dictionary<string, LineMetrics>();

            foreach (var line in lines)
            {
                var testedInLine = testedUnits
                    .Where(t => t.LineName == line)
                    .Select(t => t.SerialNumber)
                    .Distinct(StringComparer.OrdinalIgnoreCase)
                    .ToList();

                var validatedInLine = validations
                    .Where(v => v.LineName == line && v.IsPass)
                    .Select(v => v.SerialNumber)
                    .Distinct(StringComparer.OrdinalIgnoreCase)
                    .ToList();

                var metrics = new LineMetrics
                {
                    TestedCount = testedInLine.Count,
                    ValidatedCount = validatedInLine.Count,
                    ValidationRate = testedInLine.Count > 0 
                        ? (decimal)validatedInLine.Count / testedInLine.Count * 100 
                        : 0
                };

                lineMetrics[line] = metrics;
            }

            // Update KPIs
            UpdateLineKPI(litLine1Rate, litLine1Tested, litLine1Validated, lineMetrics.ContainsKey("Line 1") ? lineMetrics["Line 1"] : new LineMetrics());
            UpdateLineKPI(litLine2Rate, litLine2Tested, litLine2Validated, lineMetrics.ContainsKey("Line 2") ? lineMetrics["Line 2"] : new LineMetrics());
            UpdateLineKPI(litLine3Rate, litLine3Tested, litLine3Validated, lineMetrics.ContainsKey("Line 3") ? lineMetrics["Line 3"] : new LineMetrics());
            UpdateLineKPI(litLine4Rate, litLine4Tested, litLine4Validated, lineMetrics.ContainsKey("Line 4") ? lineMetrics["Line 4"] : new LineMetrics());

            // Calculate and update total metrics
            var totalTested = testedUnits.Select(t => t.SerialNumber).Distinct(StringComparer.OrdinalIgnoreCase).Count();
            var totalValidated = validations.Where(v => v.IsPass).Select(v => v.SerialNumber).Distinct(StringComparer.OrdinalIgnoreCase).Count();
            var totalRate = totalTested > 0 ? (decimal)totalValidated / totalTested * 100 : 0;
            
            litTotalRate.Text = totalRate.ToString("F1") + "%";
            litTotalTested.Text = totalTested.ToString("N0");
            litTotalValidated.Text = totalValidated.ToString("N0");

            // Build timeline
            BuildTimeline(testedUnits, validations);
        }
        catch (Exception ex)
        {
            System.Diagnostics.Trace.WriteLine("[Battery Dashboard] Error: " + ex.Message);
            pnlTrackingTable.Visible = false;
            pnlEmptyState.Visible = true;
        }
    }

    private List<TestedUnit> GetTestedUnitsFromSQL(DateTime startDate, DateTime endDate)
    {
        var units = new List<TestedUnit>();

        if (string.IsNullOrWhiteSpace(_connectionString))
            return units;

        try
        {
            using (var conn = new SqlConnection(_connectionString))
            using (var cmd = new SqlCommand(@"
                SELECT DISTINCT
                    SerialNumber,
                    WorkstationName,
                    CatalogNumber,
                    TestStartTime,
                    OperatorName
                FROM [Battery].[dbo].[OverallResults]
                WHERE CAST(TestStartTime AS DATE) >= @StartDate 
                    AND CAST(TestStartTime AS DATE) <= @EndDate
                    AND OverallStatus = 'Passed'
                    AND SerialNumber IS NOT NULL
                    AND WorkstationName IS NOT NULL
                ORDER BY TestStartTime DESC", conn))
            {
                cmd.Parameters.AddWithValue("@StartDate", startDate);
                cmd.Parameters.AddWithValue("@EndDate", endDate);

                conn.Open();
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        var workstationName = reader.GetString(1);
                        var lineName = "Unknown";
                        
                        // Extract line number from WorkstationName (e.g., "BatteryLine_Line_1" -> "Line 1")
                        var match = System.Text.RegularExpressions.Regex.Match(workstationName, @"Line[_\s]*(\d+)", System.Text.RegularExpressions.RegexOptions.IgnoreCase);
                        if (match.Success)
                        {
                            lineName = "Line " + match.Groups[1].Value;
                        }
                        else
                        {
                            System.Diagnostics.Trace.WriteLine(string.Format("[Battery Dashboard] Warning: Could not parse line from WorkstationName: '{0}'", workstationName));
                        }

                        units.Add(new TestedUnit
                        {
                            SerialNumber = reader.GetString(0).Trim(),
                            LineName = lineName,
                            PartNumber = reader.IsDBNull(2) ? "" : reader.GetString(2),
                            TestDate = reader.GetDateTime(3),
                            OperatorName = reader.IsDBNull(4) ? "" : reader.GetString(4)
                        });
                    }
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Trace.WriteLine("[Battery Dashboard] SQL Error: " + ex.Message);
        }

        return units;
    }

    private List<ValidationRecord> GetValidationsFromSQL(DateTime startDate, DateTime endDate)
    {
        var records = new List<ValidationRecord>();

        if (string.IsNullOrWhiteSpace(_connectionString))
            return records;

        try
        {
            using (var conn = new SqlConnection(_connectionString))
            using (var cmd = new SqlCommand(@"
                SELECT 
                    VerificationDateTime,
                    VerifierEmployeeName,
                    SerialNumber,
                    SubLine,
                    CheckStatus
                FROM [Battery].[dbo].[Test Validation Records]
                WHERE CAST(VerificationDateTime AS DATE) >= @StartDate 
                    AND CAST(VerificationDateTime AS DATE) <= @EndDate
                    AND SerialNumber IS NOT NULL
                ORDER BY VerificationDateTime DESC", conn))
            {
                cmd.Parameters.AddWithValue("@StartDate", startDate);
                cmd.Parameters.AddWithValue("@EndDate", endDate);

                conn.Open();
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        var subLine = reader.IsDBNull(3) ? "" : reader.GetString(3);
                        var lineName = "Unknown";
                        
                        // Normalize SubLine to "Line X" format
                        if (!string.IsNullOrWhiteSpace(subLine))
                        {
                            // SubLine should be in "Battery Line 1", "Battery Line 2", etc. format
                            var match = System.Text.RegularExpressions.Regex.Match(subLine, @"(\d+)");
                            if (match.Success)
                            {
                                lineName = "Line " + match.Groups[1].Value;
                            }
                        }

                        var checkStatus = reader.IsDBNull(4) ? "" : reader.GetString(4);

                        records.Add(new ValidationRecord
                        {
                            Timestamp = reader.GetDateTime(0),
                            OperatorName = reader.IsDBNull(1) ? "" : reader.GetString(1),
                            SerialNumber = reader.GetString(2).Trim(),
                            LineName = lineName,
                            CheckResult = checkStatus,
                            IsPass = checkStatus.Equals("Pass", StringComparison.OrdinalIgnoreCase)
                        });
                    }
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Trace.WriteLine("[Battery Dashboard] SQL Validation Error: " + ex.Message);
        }

        return records;
    }

    private void BuildTimeline(List<TestedUnit> testedUnits, List<ValidationRecord> validations)
    {
        var lineFilter = ddlLineFilter.SelectedValue;
        var statusFilter = ddlStatusFilter.SelectedValue;
        var serialSearch = txtSerialSearch.Text.Trim();

        // Group validations by serial number
        var validationsBySerial = validations
            .GroupBy(v => v.SerialNumber, StringComparer.OrdinalIgnoreCase)
            .ToDictionary(g => g.Key, g => g.OrderBy(v => v.Timestamp).ToList(), StringComparer.OrdinalIgnoreCase);

        // Group tested units by serial number and keep only the most recent test
        var uniqueTestedUnits = testedUnits
            .GroupBy(u => u.SerialNumber, StringComparer.OrdinalIgnoreCase)
            .Select(g => g.OrderByDescending(u => u.TestDate).First())
            .ToList();

        var timeline = new List<TimelineItem>();

        foreach (var unit in uniqueTestedUnits)
        {
            var item = new TimelineItem
            {
                SerialNumber = unit.SerialNumber,
                PartNumber = unit.PartNumber,
                LineName = unit.LineName,
                TestDate = unit.TestDate,
                ValidationAttempts = new List<ValidationRecord>()
            };

            if (validationsBySerial.ContainsKey(unit.SerialNumber))
            {
                item.ValidationAttempts = validationsBySerial[unit.SerialNumber];
                item.LastValidatorName = item.ValidationAttempts.Last().OperatorName;
            }
            else
            {
                item.LastValidatorName = "-";
            }

            timeline.Add(item);
        }

        // Apply filters
        var filtered = timeline.AsEnumerable();

        if (lineFilter != "ALL")
        {
            filtered = filtered.Where(x => x.LineName.Equals(lineFilter, StringComparison.OrdinalIgnoreCase));
        }

        if (statusFilter != "ALL")
        {
            if (statusFilter == "Validated")
            {
                filtered = filtered.Where(x => x.ValidationAttempts.Any(v => v.IsPass));
            }
            else if (statusFilter == "Failed")
            {
                filtered = filtered.Where(x => x.ValidationAttempts.Any(v => !v.IsPass));
            }
            else if (statusFilter == "Pending")
            {
                filtered = filtered.Where(x => !x.ValidationAttempts.Any());
            }
        }

        if (!string.IsNullOrWhiteSpace(serialSearch))
        {
            filtered = filtered.Where(x => x.SerialNumber.IndexOf(serialSearch, StringComparison.OrdinalIgnoreCase) >= 0);
        }

        var finalList = filtered.ToList();

        lblTrackingCount.Text = string.Format("({0})", finalList.Count);

        if (finalList.Any())
        {
            litTimelineContent.Text = RenderTimeline(finalList);
            pnlTrackingTable.Visible = true;
            pnlEmptyState.Visible = false;
        }
        else
        {
            pnlTrackingTable.Visible = false;
            pnlEmptyState.Visible = true;
        }
    }

    private string RenderTimeline(List<TimelineItem> items)
    {
        var sb = new System.Text.StringBuilder();

        foreach (var item in items)
        {
            // Get line-specific colors
            var lineColors = GetLineColors(item.LineName);
            
            sb.AppendFormat(@"
<div style='background:rgba(255,255,255,.04); border:1px solid rgba(255,255,255,.08); border-radius:12px; padding:12px 18px; margin-bottom:12px;'>
  <div style='display:flex; justify-content:space-between; align-items:center; margin-bottom:10px; gap:16px;'>
    <div style='display:flex; align-items:baseline; gap:10px;'>
      <span style='font-size:16px; font-weight:700; color:#60a5fa; letter-spacing:-.02em;'>{0}</span>
      <span style='font-size:11px; opacity:.6; font-weight:500;'>{1}</span>
    </div>
    <div style='display:flex; gap:10px; align-items:center;'>
      <span style='padding:4px 10px; border-radius:6px; font-size:10px; font-weight:700; text-transform:uppercase; letter-spacing:.05em; background:{6}; color:{7}; border:1px solid {8};'>{2}</span>
      <span style='font-size:11px; opacity:.6; font-weight:500;'>{3}</span>
    </div>
  </div>
  <div style='display:flex; align-items:stretch; gap:0; overflow-x:auto; padding:4px 0;'>
    <div style='display:flex; flex-direction:column; align-items:center; position:relative; flex:1; min-width:100px;'>
      <div style='width:36px; height:36px; border-radius:50%; display:flex; align-items:center; justify-content:center; z-index:2; margin-bottom:6px; background:rgba(16,185,129,.2); border:2px solid #10b981; color:#34d399;'>
        <svg viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2.5' style='width:16px; height:16px;'>
          <polyline points='20 6 9 17 4 12'></polyline>
        </svg>
      </div>
      <div style='position:absolute; top:18px; left:50%; width:100%; height:2px; background:rgba(255,255,255,.15); z-index:1;'></div>
      <div style='text-align:center; display:flex; flex-direction:column; gap:2px;'>
        <div style='font-size:10px; font-weight:600; margin-bottom:2px; opacity:.7; white-space:nowrap;'>Functional Test</div>
        <div style='font-size:13px; font-weight:700; margin-bottom:2px; color:#34d399;'>PASSED</div>
        <div style='font-size:11px; opacity:.7; white-space:nowrap;'>{4:MM/dd HH:mm}</div>
      </div>
    </div>
    {5}
  </div>
</div>",
                item.SerialNumber,
                item.PartNumber,
                item.LineName,
                item.LastValidatorName,
                item.TestDate,
                RenderValidationSteps(item.ValidationAttempts),
                lineColors.Background,
                lineColors.Text,
                lineColors.Border
            );
        }

        return sb.ToString();
    }

    private LineColorScheme GetLineColors(string lineName)
    {
        switch (lineName)
        {
            case "Line 1":
                return new LineColorScheme
                {
                    Background = "rgba(59,130,246,.15)",  // Blue
                    Text = "#93c5fd",
                    Border = "rgba(59,130,246,.3)"
                };
            case "Line 2":
                return new LineColorScheme
                {
                    Background = "rgba(16,185,129,.15)",  // Green
                    Text = "#6ee7b7",
                    Border = "rgba(16,185,129,.3)"
                };
            case "Line 3":
                return new LineColorScheme
                {
                    Background = "rgba(245,158,11,.15)",  // Amber/Orange
                    Text = "#fbbf24",
                    Border = "rgba(245,158,11,.3)"
                };
            case "Line 4":
                return new LineColorScheme
                {
                    Background = "rgba(168,85,247,.15)",  // Purple
                    Text = "#c4b5fd",
                    Border = "rgba(168,85,247,.3)"
                };
            default:
                return new LineColorScheme
                {
                    Background = "rgba(148,163,184,.15)", // Gray
                    Text = "#cbd5e1",
                    Border = "rgba(148,163,184,.3)"
                };
        }
    }

    private string RenderValidationSteps(List<ValidationRecord> attempts)
    {
        if (!attempts.Any())
        {
            return @"
<div style='display:flex; flex-direction:column; align-items:center; position:relative; flex:1; min-width:100px;'>
  <div style='width:36px; height:36px; border-radius:50%; display:flex; align-items:center; justify-content:center; z-index:2; margin-bottom:6px; background:rgba(148,163,184,.15); border:2px dashed rgba(148,163,184,.4); color:#94a3b8;'>
    <svg viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2' style='width:16px; height:16px;'>
      <circle cx='12' cy='12' r='10'></circle>
      <polyline points='12 6 12 12 16 14'></polyline>
    </svg>
  </div>
  <div style='text-align:center; display:flex; flex-direction:column; gap:2px;'>
    <div style='font-size:10px; font-weight:600; margin-bottom:2px; opacity:.7; white-space:nowrap;'>Label Validation</div>
    <div style='font-size:13px; font-weight:700; margin-bottom:2px; color:#94a3b8;'>PENDING</div>
    <div style='font-size:11px; opacity:.7; white-space:nowrap;'>Awaiting scan</div>
  </div>
</div>";
        }

        var sb = new System.Text.StringBuilder();
        for (int i = 0; i < attempts.Count; i++)
        {
            var attempt = attempts[i];
            var isLast = i == attempts.Count - 1;
            var stepClass = attempt.IsPass ? "step-complete" : "step-failed";
            var iconBg = attempt.IsPass ? "rgba(16,185,129,.2)" : "rgba(239,68,68,.2)";
            var iconBorder = attempt.IsPass ? "#10b981" : "#ef4444";
            var iconColor = attempt.IsPass ? "#34d399" : "#f87171";
            var statusColor = attempt.IsPass ? "#34d399" : "#f87171";
            var statusText = attempt.IsPass ? "PASSED" : "FAILED";
            var icon = attempt.IsPass 
                ? "<svg viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2.5' style='width:16px; height:16px;'><polyline points='20 6 9 17 4 12'></polyline></svg>"
                : "<svg viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2.5' style='width:16px; height:16px;'><line x1='18' y1='6' x2='6' y2='18'></line><line x1='6' y1='6' x2='18' y2='18'></line></svg>";
            var connector = isLast ? "" : "<div style='position:absolute; top:18px; left:50%; width:100%; height:2px; background:rgba(255,255,255,.15); z-index:1;'></div>";

            sb.AppendFormat(@"
<div style='display:flex; flex-direction:column; align-items:center; position:relative; flex:1; min-width:100px;'>
  <div style='width:36px; height:36px; border-radius:50%; display:flex; align-items:center; justify-content:center; z-index:2; margin-bottom:6px; background:{0}; border:2px solid {1}; color:{2};'>
    {3}
  </div>
  {4}
  <div style='text-align:center; display:flex; flex-direction:column; gap:2px;'>
    <div style='font-size:10px; font-weight:600; margin-bottom:2px; opacity:.7; white-space:nowrap;'>Validation #{5}</div>
    <div style='font-size:13px; font-weight:700; margin-bottom:2px; color:{6};'>{7}</div>
    <div style='font-size:11px; opacity:.7; white-space:nowrap;'>{8:MM/dd HH:mm}</div>
  </div>
</div>",
                iconBg,
                iconBorder,
                iconColor,
                icon,
                connector,
                i + 1,
                statusColor,
                statusText,
                attempt.Timestamp
            );
        }

        return sb.ToString();
    }

    private void UpdateLineKPI(Literal rateText, Literal testedText, Literal validatedText, LineMetrics metrics)
    {
        rateText.Text = metrics.ValidationRate.ToString("F1") + "%";
        testedText.Text = metrics.TestedCount.ToString("N0");
        validatedText.Text = metrics.ValidatedCount.ToString("N0");
    }

    private void UpdatePeriodButtonStates(string activePeriod)
    {
        btnYesterday.CssClass = activePeriod == "Yesterday" ? "period-btn active" : "period-btn";
        btnDay.CssClass = activePeriod == "Day" ? "period-btn active" : "period-btn";
        btnWeek.CssClass = activePeriod == "Week" ? "period-btn active" : "period-btn";
        btnMonth.CssClass = activePeriod == "Month" ? "period-btn active" : "period-btn";
        btnCustom.CssClass = activePeriod == "Custom" ? "period-btn active" : "period-btn";
    }

    #region Helper Classes

    private class TestedUnit
    {
        public string SerialNumber { get; set; }
        public string LineName { get; set; }
        public string PartNumber { get; set; }
        public DateTime TestDate { get; set; }
        public string OperatorName { get; set; }
    }

    private class ValidationRecord
    {
        public DateTime Timestamp { get; set; }
        public string OperatorName { get; set; }
        public string SerialNumber { get; set; }
        public string LineName { get; set; }
        public string CheckResult { get; set; }
        public bool IsPass { get; set; }
    }

    private class TimelineItem
    {
        public string SerialNumber { get; set; }
        public string PartNumber { get; set; }
        public string LineName { get; set; }
        public DateTime TestDate { get; set; }
        public string LastValidatorName { get; set; }
        public List<ValidationRecord> ValidationAttempts { get; set; }
    }

    private class LineMetrics
    {
        public int TestedCount { get; set; }
        public int ValidatedCount { get; set; }
        public decimal ValidationRate { get; set; }
    }

    private class LineColorScheme
    {
        public string Background { get; set; }
        public string Text { get; set; }
        public string Border { get; set; }
    }

    #endregion
}
