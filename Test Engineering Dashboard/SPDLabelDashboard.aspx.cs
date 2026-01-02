using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using TED;
using Newtonsoft.Json;

public partial class TED_SPDLabelDashboard : Page
{
    private readonly SpdDashboardService _service = new SpdDashboardService();
    private string CurrentPeriod
    {
        get { return ViewState["CurrentPeriod"] as string ?? "Day"; }
        set { ViewState["CurrentPeriod"] = value; }
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
        LoadDashboard();
    }

    protected void btnGoToScan_Click(object sender, EventArgs e)
    {
        Response.Redirect("~/SPDLabelVerification.aspx", false);
    }

    protected void ddlWorkcellFilter_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadDashboard();
    }

    protected void ddlStatusFilter_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadDashboard();
    }

    protected void txtPartSearch_TextChanged(object sender, EventArgs e)
    {
        LoadDashboard();
    }

    private void LoadDashboard()
    {
        var period = CurrentPeriod;
        DateTime startDate, endDate;
        string periodLabel;

        switch (period)
        {
            case "Yesterday":
                startDate = DateTime.Today.AddDays(-1);
                endDate = DateTime.Today.AddDays(-1);
                periodLabel = "Yesterday";
                break;
            case "Week":
                startDate = DateTime.Today.AddDays(-(int)DateTime.Today.DayOfWeek);
                endDate = DateTime.Today;
                periodLabel = "This Week";
                break;
            case "Month":
                startDate = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1);
                endDate = DateTime.Today;
                periodLabel = "This Month";
                break;
            default:
                startDate = DateTime.Today;
                endDate = DateTime.Today;
                periodLabel = "Today";
                period = "Day";
                break;
        }

        UpdatePeriodButtonStates(period);
        litDateRange.Text = string.Format("{0:MMM dd, yyyy} - {1:MMM dd, yyyy}", startDate, endDate);

        DashboardMetrics metrics;
        switch (period)
        {
            case "Week":
                metrics = _service.GetWeeklyMetrics(startDate, endDate);
                break;
            case "Month":
                metrics = _service.GetMonthlyMetrics(startDate, endDate);
                break;
            default:
                metrics = _service.GetDailyMetrics(startDate, endDate);
                break;
        }

        UpdateKPIs(metrics);
        UpdateChart(metrics, period);
        LoadTestedVsValidated(startDate, endDate);
        LoadSerialTracking(startDate, endDate);
    }

    private void UpdateKPIs(DashboardMetrics metrics)
    {
        litPassedCount.Text = metrics.TotalPassed.ToString("N0");
        litFailedCount.Text = metrics.TotalFailed.ToString("N0");

        var passRate = metrics.TotalValidations > 0
            ? (decimal)metrics.TotalPassed / metrics.TotalValidations * 100
            : 0;
        litPassRate.Text = passRate.ToString("F1") + "%";
    }

    private void LoadTestedVsValidated(DateTime startDate, DateTime endDate)
    {
        var testedMetrics = _service.GetTestedVsValidatedMetrics(startDate, endDate);

        // Overall metrics
        litTestedUnits.Text = testedMetrics.TotalTested.ToString("N0");
        litValidatedUnits.Text = testedMetrics.TotalValidated.ToString("N0");
        litValidationRate.Text = testedMetrics.OverallValidationRate.ToString("F1") + "%";
        ApplyValidationRateColor(valRateOverall, testedMetrics.OverallValidationRate);

        // Integrated line
        if (testedMetrics.ByWorkcell.ContainsKey("Integrated"))
        {
            var integrated = testedMetrics.ByWorkcell["Integrated"];
            litIntegratedTested.Text = integrated.TestedCount.ToString("N0");
            litIntegratedValidated.Text = integrated.ValidatedCount.ToString("N0");
            litIntegratedRate.Text = integrated.ValidationRate.ToString("F1") + "%";
            ApplyValidationRateColor(valRateIntegrated, integrated.ValidationRate);
        }
        else
        {
            litIntegratedTested.Text = "0";
            litIntegratedValidated.Text = "0";
            litIntegratedRate.Text = "0%";
            ApplyValidationRateColor(valRateIntegrated, 0);
        }

        // Sidemount line
        if (testedMetrics.ByWorkcell.ContainsKey("Sidemount"))
        {
            var sidemount = testedMetrics.ByWorkcell["Sidemount"];
            litSidemountTested.Text = sidemount.TestedCount.ToString("N0");
            litSidemountValidated.Text = sidemount.ValidatedCount.ToString("N0");
            litSidemountRate.Text = sidemount.ValidationRate.ToString("F1") + "%";
            ApplyValidationRateColor(valRateSidemount, sidemount.ValidationRate);
        }
        else
        {
            litSidemountTested.Text = "0";
            litSidemountValidated.Text = "0";
            litSidemountRate.Text = "0%";
            ApplyValidationRateColor(valRateSidemount, 0);
        }
    }

    private void ApplyValidationRateColor(System.Web.UI.HtmlControls.HtmlGenericControl control, decimal rate)
    {
        if (rate > 90)
        {
            control.Attributes["class"] = "kpi-value rate-excellent";
        }
        else if (rate >= 80)
        {
            control.Attributes["class"] = "kpi-value rate-good";
        }
        else
        {
            control.Attributes["class"] = "kpi-value rate-poor";
        }
    }

    private void UpdateChart(DashboardMetrics metrics, string period)
    {
        var chartData = new
        {
            labels = new List<string>(),
            passed = new List<int>(),
            failed = new List<int>()
        };

        try
        {
            if (period == "Day" && metrics.DailyData != null && metrics.DailyData.Count > 0)
            {
                foreach (var day in metrics.DailyData.OrderBy(d => d.Date))
                {
                    chartData.labels.Add(day.Date.ToString("MMM dd"));
                    chartData.passed.Add(day.TotalPassed);
                    chartData.failed.Add(day.TotalFailed);
                }
            }
            else if (period == "Week" && metrics.WeeklyData != null && metrics.WeeklyData.Count > 0)
            {
                foreach (var week in metrics.WeeklyData.OrderBy(w => w.Year).ThenBy(w => w.Week))
                {
                    chartData.labels.Add(string.Format("Week {0}", week.Week));
                    chartData.passed.Add(week.TotalPassed);
                    chartData.failed.Add(week.TotalFailed);
                }
            }
            else if (period == "Month" && metrics.MonthlyData != null && metrics.MonthlyData.Count > 0)
            {
                foreach (var month in metrics.MonthlyData.OrderBy(m => m.Year).ThenBy(m => m.Month))
                {
                    var monthName = new DateTime(month.Year, month.Month, 1).ToString("MMM yyyy");
                    chartData.labels.Add(monthName);
                    chartData.passed.Add(month.TotalPassed);
                    chartData.failed.Add(month.TotalFailed);
                }
            }

            // If no data, add a placeholder
            if (chartData.labels.Count == 0)
            {
                chartData.labels.Add("No Data");
                chartData.passed.Add(0);
                chartData.failed.Add(0);
            }

            hfChartData.Value = JsonConvert.SerializeObject(chartData);
        }
        catch (Exception ex)
        {
            System.Diagnostics.Trace.WriteLine("[SPD Dashboard] Chart error: " + ex.Message);
            // Fallback to empty chart data
            hfChartData.Value = JsonConvert.SerializeObject(new
            {
                labels = new[] { "No Data" },
                passed = new[] { 0 },
                failed = new[] { 0 }
            });
        }
    }

    private void LoadSerialTracking(DateTime startDate, DateTime endDate)
    {
        var timeline = _service.GetTestedUnitsTimeline(startDate, endDate);
        
        var workcellFilter = ddlWorkcellFilter.SelectedValue;
        var statusFilter = ddlStatusFilter.SelectedValue;
        var partSearch = txtPartSearch.Text.Trim();

        var filteredItems = timeline.AsEnumerable();

        if (workcellFilter != "ALL")
        {
            filteredItems = filteredItems.Where(x => 
                string.Equals(x.Workcell, workcellFilter, StringComparison.OrdinalIgnoreCase));
        }

        if (statusFilter != "ALL")
        {
            if (statusFilter == "Validated")
            {
                // Has at least one successful validation
                filteredItems = filteredItems.Where(x => 
                    x.ValidationAttempts != null && x.ValidationAttempts.Any(v => v.Result == "PASS"));
            }
            else if (statusFilter == "Failed")
            {
                // Has at least one failed validation attempt
                filteredItems = filteredItems.Where(x => 
                    x.ValidationAttempts != null && x.ValidationAttempts.Any(v => v.Result == "FAIL"));
            }
            else if (statusFilter == "Pending")
            {
                // No validation attempts yet
                filteredItems = filteredItems.Where(x => 
                    x.ValidationAttempts == null || !x.ValidationAttempts.Any());
            }
        }

        if (!string.IsNullOrWhiteSpace(partSearch))
        {
            filteredItems = filteredItems.Where(x => 
                x.SerialNumber != null && x.SerialNumber.IndexOf(partSearch, StringComparison.OrdinalIgnoreCase) >= 0);
        }

        var finalList = filteredItems.ToList();

        // Update count label
        lblTrackingCount.Text = string.Format("({0})", finalList.Count);

        if (finalList.Any())
        {
            rptSerialTracking.DataSource = finalList;
            rptSerialTracking.DataBind();
            pnlTrackingTable.Visible = true;
            pnlEmptyState.Visible = false;
        }
        else
        {
            pnlTrackingTable.Visible = false;
            pnlEmptyState.Visible = true;
        }
    }

    private void UpdatePeriodButtonStates(string activePeriod)
    {
        btnYesterday.CssClass = activePeriod == "Yesterday" ? "period-btn active" : "period-btn";
        btnDay.CssClass = activePeriod == "Day" ? "period-btn active" : "period-btn";
        btnWeek.CssClass = activePeriod == "Week" ? "period-btn active" : "period-btn";
        btnMonth.CssClass = activePeriod == "Month" ? "period-btn active" : "period-btn";
    }

    protected string RenderStatusBadge(object statusObj, object passCountObj, object failCountObj)
    {
        var status = Convert.ToString(statusObj);
        var passCount = Convert.ToInt32(passCountObj);
        var failCount = Convert.ToInt32(failCountObj);

        if (string.IsNullOrWhiteSpace(status))
        {
            return "<span class='status-badge pending'>PENDING</span>";
        }

        var normalized = status.Trim().ToUpperInvariant();
        
        if (normalized == "VALIDATED")
        {
            return "<span class='status-badge validated'>&check; VALIDATED</span>";
        }
        else if (normalized == "FAILED")
        {
            return "<span class='status-badge failed'>&times; FAILED</span>";
        }
        else
        {
            return "<span class='status-badge pending'>PENDING</span>";
        }
    }

    protected string RenderWorkcellTag(object workcellObj)
    {
        var workcell = Convert.ToString(workcellObj);
        if (string.IsNullOrWhiteSpace(workcell))
        {
            return "--";
        }

        var normalized = workcell.Trim().ToLowerInvariant();
        if (normalized == "integrated")
        {
            return "<span class='workcell-tag integrated'>Integrated</span>";
        }
        else if (normalized == "sidemount")
        {
            return "<span class='workcell-tag sidemount'>Sidemount</span>";
        }
        else
        {
            return string.Format("<span class='workcell-tag'>{0}</span>", workcell);
        }
    }

    protected string TruncateOperators(object operatorsObj)
    {
        var operators = Convert.ToString(operatorsObj);
        if (string.IsNullOrWhiteSpace(operators))
        {
            return "--";
        }

        if (operators.Length > 40)
        {
            return operators.Substring(0, 37) + "...";
        }

        return operators;
    }

    protected string RenderValidationSteps(object attemptsObj)
    {
        var attempts = attemptsObj as List<TED.ValidationAttempt>;
        if (attempts == null || !attempts.Any())
        {
            // No validation yet - show pending
            return @"
                <div class='journey-step step-pending'>
                  <div class='step-icon'>
                    <svg viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'>
                      <circle cx='12' cy='12' r='10'></circle>
                      <polyline points='12 6 12 12 16 14'></polyline>
                    </svg>
                  </div>
                  <div class='step-connector'></div>
                  <div class='step-content'>
                    <div class='step-title'>Label Validation</div>
                    <div class='step-status status-pending'>PENDING</div>
                    <div class='step-time'>Awaiting scan</div>
                  </div>
                </div>";
        }

        var sb = new System.Text.StringBuilder();
        for (int i = 0; i < attempts.Count; i++)
        {
            var attempt = attempts[i];
            var isLast = i == attempts.Count - 1;
            var stepClass = attempt.Result == "PASS" ? "step-complete" : "step-failed";
            var statusClass = attempt.Result == "PASS" ? "status-passed" : "status-failed";
            var statusText = attempt.Result == "PASS" ? "PASSED" : "FAILED";

            sb.AppendFormat(@"
                <div class='journey-step {0}'>
                  <div class='step-icon'>
                    {1}
                  </div>
                  {2}
                  <div class='step-content'>
                    <div class='step-title'>Validation #{3}</div>
                    <div class='step-status {4}'>{5}</div>
                    <div class='step-time'>{6}<br/>{7}</div>
                  </div>
                </div>",
                stepClass,
                attempt.Result == "PASS" 
                    ? "<svg viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2.5'><polyline points='20 6 9 17 4 12'></polyline></svg>"
                    : "<svg viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2.5'><line x1='18' y1='6' x2='6' y2='18'></line><line x1='6' y1='6' x2='18' y2='18'></line></svg>",
                isLast ? "" : "<div class='step-connector'></div>",
                attempt.AttemptNumber,
                statusClass,
                statusText,
                attempt.ValidationTime.ToString("MM/dd/yy HH:mm"),
                !string.IsNullOrWhiteSpace(attempt.ScannedLabel) ? attempt.ScannedLabel : "N/A"
            );
        }

        return sb.ToString();
    }
}
