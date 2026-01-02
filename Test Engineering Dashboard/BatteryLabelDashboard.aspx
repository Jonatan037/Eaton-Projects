<%@ Page Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="BatteryLabelDashboard.aspx.cs" Inherits="TED_BatteryLabelDashboard" %>
<asp:Content ID="TitleContent" ContentPlaceHolderID="TitleContent" runat="server">Battery Label Dashboard</asp:Content>
<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
  <style>
    html, body { min-height:100%; }
    body { overflow-y:auto; }

    .dashboard-shell { width:100%; max-width:1800px; margin:0 auto; padding:24px clamp(20px,4vw,60px) 40px; display:flex; flex-direction:column; gap:20px; }
    
    /* Header */
    .dashboard-header { display:flex; justify-content:space-between; align-items:flex-start; gap:24px; flex-wrap:wrap; }
    .header-content h1 { margin:0; font-size:28px; font-weight:700; letter-spacing:-.02em; }
    .header-content p { margin:8px 0 0; font-size:14px; opacity:.7; }
    .header-actions { display:flex; gap:12px; align-items:center; flex-wrap:wrap; }

    /* Period Selector */
    .period-selector { display:flex; gap:8px; padding:6px; border-radius:16px; background:rgba(255,255,255,.06); border:1px solid rgba(255,255,255,.08); }
    html.theme-light .period-selector, html[data-theme='light'] .period-selector { background:rgba(0,0,0,.04); border:1px solid rgba(0,0,0,.08); }
    .period-btn { padding:10px 20px; border-radius:12px; border:none; background:transparent; color:inherit; font-size:14px; font-weight:600; cursor:pointer; transition:all .2s ease; font-family:inherit; }
    .period-btn:hover { background:rgba(255,255,255,.08); }
    html.theme-light .period-btn:hover, html[data-theme='light'] .period-btn:hover { background:rgba(0,0,0,.06); }
    .period-btn.active { background:linear-gradient(135deg, #4d7cfe, #6ea8fe); color:#fff; box-shadow:0 4px 12px -4px rgba(77,124,254,.5); }
    html.theme-light .period-btn.active, html[data-theme='light'] .period-btn.active { background:linear-gradient(135deg, #3b82f6, #60a5fa); }

    .custom-date-range { display:flex; align-items:center; gap:8px; }
    .date-input { padding:8px 12px; border-radius:8px; border:1px solid rgba(255,255,255,.12); background:rgba(0,0,0,.2); color:inherit; font-size:13px; font-family:inherit; outline:none; transition:all .2s; }
    .date-input:focus { border-color:rgba(59,130,246,.6); background:rgba(0,0,0,.3); }
    html.theme-light .date-input, html[data-theme='light'] .date-input { background:rgba(255,255,255,.9); border-color:rgba(0,0,0,.12); }
    html.theme-light .date-input:focus, html[data-theme='light'] .date-input:focus { border-color:#1976d2; background:#fff; }
    .btn-apply-custom { padding:8px 16px; border-radius:8px; border:none; background:rgba(59,130,246,.15); color:#60a5fa; font-size:13px; font-weight:600; cursor:pointer; transition:all .2s; }
    .btn-apply-custom:hover { background:rgba(59,130,246,.25); }
    html.theme-light .btn-apply-custom, html[data-theme='light'] .btn-apply-custom { background:#1976d2; color:#fff; }
    html.theme-light .btn-apply-custom:hover, html[data-theme='light'] .btn-apply-custom:hover { background:#1565c0; }

    /* Info Banner */
    .info-banner { display:flex; align-items:center; justify-content:space-between; gap:16px; padding:12px 20px; border-radius:12px; background:rgba(255,255,255,.06); margin-bottom:4px; flex-wrap:wrap; }
    html.theme-light .info-banner, html[data-theme='light'] .info-banner { background:rgba(0,0,0,.04); }
    .date-range-display { display:inline-flex; align-items:center; gap:8px; font-size:14px; font-weight:500; }
    
    /* Auto-refresh Indicator */
    .refresh-indicator { display:inline-flex; align-items:center; gap:8px; font-size:13px; font-weight:500; opacity:.7; transition:opacity .2s ease; }
    .refresh-indicator.refreshing { opacity:1; }
    .refresh-indicator svg { width:16px; height:16px; animation:spin 2s linear infinite; }
    .refresh-indicator.refreshing svg { animation:spin .5s linear infinite; }
    @keyframes spin { from { transform:rotate(0deg); } to { transform:rotate(360deg); } }

    /* KPI Cards */
    .kpi-grid { display:grid; grid-template-columns:repeat(5,1fr); gap:12px; }
    .kpi-card { 
      position:relative; 
      display:flex; 
      flex-direction:column; 
      padding:16px 20px; 
      border-radius:16px; 
      background:linear-gradient(135deg, rgba(255,255,255,.08), rgba(255,255,255,.04));
      border:1px solid rgba(255,255,255,.12);
      box-shadow:0 8px 24px -8px rgba(0,0,0,.35), 0 0 0 1px rgba(255,255,255,.05) inset;
      backdrop-filter:blur(20px) saturate(140%);
      transition:transform .2s ease, box-shadow .2s ease;
      cursor:pointer;
    }
    html.theme-light .kpi-card, html[data-theme='light'] .kpi-card {
      background:linear-gradient(135deg, #ffffff, #fafbfc);
      border:1px solid rgba(0,0,0,.10);
      box-shadow:0 4px 16px -4px rgba(0,0,0,.15), 0 1px 0 rgba(255,255,255,.8) inset;
    }
    .kpi-card:hover { 
      transform:translateY(-2px) scale(1.01); 
      box-shadow:0 12px 32px -10px rgba(0,0,0,.45); 
      border-color: rgba(255,255,255,0.20);
    }
    html.theme-light .kpi-card:hover, html[data-theme='light'] .kpi-card:hover { 
      box-shadow:0 6px 20px -6px rgba(0,0,0,.22); 
      border-color: rgba(0,0,0,0.15);
    }
    
    .kpi-label { 
      font-size:11px; 
      font-weight:600; 
      text-transform:uppercase; 
      letter-spacing:.3px; 
      opacity:.75; 
      margin-bottom:6px; 
    }
    .kpi-value { 
      font-size:30px; 
      font-weight:800; 
      line-height:1; 
      margin-bottom:2px; 
    }
    .kpi-footer { 
      display:flex; 
      align-items:center; 
      justify-content:space-between; 
      font-size:10px; 
      opacity:.6; 
      margin-top:auto; 
      padding-top:2px; 
      color: #9ca3af;
    }
    html.theme-light .kpi-footer, html[data-theme='light'] .kpi-footer {
      color: #6b7280;
    }
    
    /* Blue highlight for All Lines card */
    .kpi-card.status-blue { 
      border-left:4px solid #3b82f6; 
      background:linear-gradient(135deg, rgba(59,130,246,.15), rgba(59,130,246,.05)); 
    }
    .kpi-card.status-blue .kpi-value { color:#93c5fd; }
    .kpi-card.status-blue .kpi-label { color:#bfdbfe; opacity:.9; }
    .kpi-card.status-blue .kpi-footer { color:#93c5fd; opacity:.8; }
    html.theme-light .kpi-card.status-blue, html[data-theme='light'] .kpi-card.status-blue { 
      border-left:4px solid #3b82f6; 
      background:linear-gradient(135deg, #dbeafe, #ffffff); 
    }
    html.theme-light .kpi-card.status-blue .kpi-value, html[data-theme='light'] .kpi-card.status-blue .kpi-value { 
      color:#2563eb; 
    }
    html.theme-light .kpi-card.status-blue .kpi-label, html[data-theme='light'] .kpi-card.status-blue .kpi-label { 
      color:#1e40af; opacity:.9; 
    }
    html.theme-light .kpi-card.status-blue .kpi-footer, html[data-theme='light'] .kpi-card.status-blue .kpi-footer { 
      color:#3b82f6; opacity:.8; 
    }

    /* Dynamic validation rate colors */
    .kpi-value.rate-excellent { background:linear-gradient(135deg, #10b981, #34d399); -webkit-background-clip:text; -webkit-text-fill-color:transparent; background-clip:text; }
    .kpi-value.rate-good { background:linear-gradient(135deg, #f59e0b, #fbbf24); -webkit-background-clip:text; -webkit-text-fill-color:transparent; background-clip:text; }
    .kpi-value.rate-poor { background:linear-gradient(135deg, #ef4444, #f87171); -webkit-background-clip:text; -webkit-text-fill-color:transparent; background-clip:text; }

    /* Serial Tracking Timeline */
    .tracking-section { border-radius:20px; padding:20px 24px; background:rgba(17,21,30,.92); border:1px solid rgba(255,255,255,.08); box-shadow:0 14px 28px -20px rgba(0,0,0,.65); }
    html.theme-light .tracking-section, html[data-theme='light'] .tracking-section { background:#fff; border:1px solid rgba(0,0,0,.08); box-shadow:0 12px 24px -18px rgba(0,0,0,.18); }
    .tracking-header { display:flex; justify-content:space-between; align-items:center; margin-bottom:18px; flex-wrap:wrap; gap:12px; }
    .tracking-header h3 { margin:0; font-size:17px; font-weight:700; letter-spacing:-.01em; }
    .tracking-header h3 .count { opacity:.6; font-weight:500; margin-left:4px; }
    .tracking-filter { display:flex; gap:10px; align-items:center; flex-wrap:wrap; }
    .filter-dropdown { padding:8px 14px; border-radius:10px; border:1px solid rgba(255,255,255,.15); background:rgba(255,255,255,.08); color:inherit; font-size:13px; font-weight:500; font-family:inherit; }
    .filter-dropdown option { background:#1f2937; color:#fff; }
    html.theme-light .filter-dropdown, html[data-theme='light'] .filter-dropdown { background:#f3f5fa; border:1px solid rgba(0,0,0,.12); }
    html.theme-light .filter-dropdown option, html[data-theme='light'] .filter-dropdown option { background:#fff; color:#000; }
    .search-input { padding:8px 14px; border-radius:10px; border:1px solid rgba(255,255,255,.15); background:rgba(255,255,255,.08); color:inherit; font-size:13px; font-weight:500; font-family:inherit; min-width:200px; }
    .search-input::placeholder { opacity:.5; }
    html.theme-light .search-input, html[data-theme='light'] .search-input { background:#f3f5fa; border:1px solid rgba(0,0,0,.12); }

    .empty-state { padding:48px; text-align:center; opacity:.6; }
    .empty-state-text { font-size:16px; font-weight:600; }

    @media (max-width: 768px) {
      .dashboard-header { flex-direction:column; align-items:stretch; }
      .kpi-grid { grid-template-columns:1fr; }
    }
  </style>
</asp:Content>
<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
  <div class="dashboard-shell">
    <div class="dashboard-header">
      <div class="header-content">
        <h1>Battery Label Verification Dashboard</h1>
        <p>Track validation metrics and serial number verification status across all battery lines.</p>
      </div>
      <div class="header-actions">
        <div class="period-selector">
          <asp:Button ID="btnYesterday" runat="server" Text="Yesterday" CssClass="period-btn" OnClick="btnPeriod_Click" CommandArgument="Yesterday" />
          <asp:Button ID="btnDay" runat="server" Text="Day" CssClass="period-btn active" OnClick="btnPeriod_Click" CommandArgument="Day" />
          <asp:Button ID="btnWeek" runat="server" Text="Week" CssClass="period-btn" OnClick="btnPeriod_Click" CommandArgument="Week" />
          <asp:Button ID="btnMonth" runat="server" Text="Month" CssClass="period-btn" OnClick="btnPeriod_Click" CommandArgument="Month" />
          <asp:Button ID="btnCustom" runat="server" Text="Custom" CssClass="period-btn" OnClick="btnPeriod_Click" CommandArgument="Custom" />
        </div>
        <div class="custom-date-range" id="customDateRange" runat="server" style="display:none; margin-top:8px; gap:8px;">
          <asp:TextBox ID="txtStartDate" runat="server" TextMode="Date" CssClass="date-input" />
          <span style="opacity:0.6;">to</span>
          <asp:TextBox ID="txtEndDate" runat="server" TextMode="Date" CssClass="date-input" />
          <asp:Button ID="btnApplyCustom" runat="server" Text="Apply" CssClass="btn-apply-custom" OnClick="btnApplyCustom_Click" />
        </div>
      </div>
    </div>

    <div class="info-banner">
      <div class="date-range-display">
        <span>&#128197;</span>
        <asp:Literal ID="litDateRange" runat="server" />
      </div>
      
      <div class="refresh-indicator" id="refreshIndicator">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <polyline points="23 4 23 10 17 10"></polyline>
          <polyline points="1 20 1 14 7 14"></polyline>
          <path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15"></path>
        </svg>
        <span id="refreshTimer">Next refresh in 2m</span>
      </div>
    </div>

    <section class="kpi-grid">
      <!-- Total Validation Rate Card -->
      <div class="kpi-card status-blue">
        <div class="kpi-label">All Lines</div>
        <div style="display: flex; align-items: center; justify-content: space-between; margin-top: 4px; height: 60px;">
          <div class="kpi-value" id="valRateTotal" style="margin-bottom: 0;"><asp:Literal ID="litTotalRate" runat="server" Text="0%" /></div>
          <div style="width: 75px; height: 60px; position: relative; margin-right: -4px;" onclick="event.stopPropagation();">
            <canvas id="gaugeTotal"></canvas>
          </div>
        </div>
        <div class="kpi-footer" style="margin-top: 8px;">
          <asp:Literal ID="litTotalTested" runat="server" Text="0" /> tested / 
          <asp:Literal ID="litTotalValidated" runat="server" Text="0" /> validated
        </div>
      </div>
      
      <!-- Line 1 Card -->
      <div class="kpi-card">
        <div class="kpi-label">Line 1</div>
        <div style="display: flex; align-items: center; justify-content: space-between; margin-top: 4px; height: 60px;">
          <div class="kpi-value" id="valRateLine1" style="margin-bottom: 0;"><asp:Literal ID="litLine1Rate" runat="server" Text="0%" /></div>
          <div style="width: 75px; height: 60px; position: relative; margin-right: -4px;" onclick="event.stopPropagation();">
            <canvas id="gaugeLine1"></canvas>
          </div>
        </div>
        <div class="kpi-footer" style="margin-top: 8px;">
          <asp:Literal ID="litLine1Tested" runat="server" Text="0" /> tested / 
          <asp:Literal ID="litLine1Validated" runat="server" Text="0" /> validated
        </div>
      </div>
      
      <!-- Line 2 Card -->
      <div class="kpi-card">
        <div class="kpi-label">Line 2</div>
        <div style="display: flex; align-items: center; justify-content: space-between; margin-top: 4px; height: 60px;">
          <div class="kpi-value" id="valRateLine2" style="margin-bottom: 0;"><asp:Literal ID="litLine2Rate" runat="server" Text="0%" /></div>
          <div style="width: 75px; height: 60px; position: relative; margin-right: -4px;" onclick="event.stopPropagation();">
            <canvas id="gaugeLine2"></canvas>
          </div>
        </div>
        <div class="kpi-footer" style="margin-top: 8px;">
          <asp:Literal ID="litLine2Tested" runat="server" Text="0" /> tested / 
          <asp:Literal ID="litLine2Validated" runat="server" Text="0" /> validated
        </div>
      </div>

      <!-- Line 3 Card -->
      <div class="kpi-card">
        <div class="kpi-label">Line 3</div>
        <div style="display: flex; align-items: center; justify-content: space-between; margin-top: 4px; height: 60px;">
          <div class="kpi-value" id="valRateLine3" style="margin-bottom: 0;"><asp:Literal ID="litLine3Rate" runat="server" Text="0%" /></div>
          <div style="width: 75px; height: 60px; position: relative; margin-right: -4px;" onclick="event.stopPropagation();">
            <canvas id="gaugeLine3"></canvas>
          </div>
        </div>
        <div class="kpi-footer" style="margin-top: 8px;">
          <asp:Literal ID="litLine3Tested" runat="server" Text="0" /> tested / 
          <asp:Literal ID="litLine3Validated" runat="server" Text="0" /> validated
        </div>
      </div>

      <!-- Line 4 Card -->
      <div class="kpi-card">
        <div class="kpi-label">Line 4</div>
        <div style="display: flex; align-items: center; justify-content: space-between; margin-top: 4px; height: 60px;">
          <div class="kpi-value" id="valRateLine4" style="margin-bottom: 0;"><asp:Literal ID="litLine4Rate" runat="server" Text="0%" /></div>
          <div style="width: 75px; height: 60px; position: relative; margin-right: -4px;" onclick="event.stopPropagation();">
            <canvas id="gaugeLine4"></canvas>
          </div>
        </div>
        <div class="kpi-footer" style="margin-top: 8px;">
          <asp:Literal ID="litLine4Tested" runat="server" Text="0" /> tested / 
          <asp:Literal ID="litLine4Validated" runat="server" Text="0" /> validated
        </div>
      </div>
    </section>

    <section class="tracking-section">
      <div class="tracking-header">
        <h3>Serial Number Tracking <asp:Label ID="lblTrackingCount" runat="server" CssClass="count" Text="" /></h3>
        <div class="tracking-filter">
          <asp:TextBox ID="txtSerialSearch" runat="server" CssClass="search-input" placeholder="Search serial number..." AutoPostBack="true" OnTextChanged="txtSerialSearch_TextChanged" />
          <asp:DropDownList ID="ddlStatusFilter" runat="server" CssClass="filter-dropdown" AutoPostBack="true" OnSelectedIndexChanged="ddlStatusFilter_SelectedIndexChanged">
            <asp:ListItem Value="ALL" Selected="True">All Status</asp:ListItem>
            <asp:ListItem Value="Validated">Validated</asp:ListItem>
            <asp:ListItem Value="Failed">Has Failures</asp:ListItem>
            <asp:ListItem Value="Pending">Pending</asp:ListItem>
          </asp:DropDownList>
          <asp:DropDownList ID="ddlLineFilter" runat="server" CssClass="filter-dropdown" AutoPostBack="true" OnSelectedIndexChanged="ddlLineFilter_SelectedIndexChanged">
            <asp:ListItem Value="ALL" Selected="True">All Lines</asp:ListItem>
            <asp:ListItem Value="Line 1">Line 1</asp:ListItem>
            <asp:ListItem Value="Line 2">Line 2</asp:ListItem>
            <asp:ListItem Value="Line 3">Line 3</asp:ListItem>
            <asp:ListItem Value="Line 4">Line 4</asp:ListItem>
          </asp:DropDownList>
        </div>
      </div>
      <div class="timeline-wrapper">
        <asp:Panel ID="pnlTrackingTable" runat="server">
          <asp:Literal ID="litTimelineContent" runat="server" />
        </asp:Panel>
        <asp:Panel ID="pnlEmptyState" runat="server" CssClass="empty-state" Visible="false">
          <div class="empty-state-text">No test data for the selected period</div>
        </asp:Panel>
      </div>
    </section>
  </div>

  <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
  <script type="text/javascript">
    // ===== GAUGE CHART CREATION =====
    (function() {
      try {
        function createGaugeChart(canvasId, value, label) {
          var canvas = document.getElementById(canvasId);
          if (!canvas) {
            console.warn('Canvas not found:', canvasId);
            return;
          }
          
          var rate = parseFloat(value);
          if (isNaN(rate)) rate = 0;
          
          console.log('Creating gauge:', canvasId, 'Value:', rate);
          
          var color = rate > 90 ? '#10b981' : (rate >= 80 ? '#f59e0b' : '#ef4444');
          
          new Chart(canvas, {
            type: 'doughnut',
            data: {
              datasets: [{
                data: [rate, 100 - rate],
                backgroundColor: [color, 'rgba(255,255,255,0.08)'],
                borderWidth: 0,
                circumference: 180,
                rotation: 270
              }]
            },
            options: {
              responsive: true,
              maintainAspectRatio: true,
              cutout: '75%',
              plugins: {
                legend: { display: false },
                tooltip: { enabled: false }
              }
            }
          });
        }

        // Wait for DOM to be ready
        window.addEventListener('DOMContentLoaded', function() {
          console.log('DOM loaded, creating gauges...');
          
          // Get validation rates from the Literal controls (read the actual text content)
          var valRateTotalEl = document.getElementById('valRateTotal');
          var valRateLine1El = document.getElementById('valRateLine1');
          var valRateLine2El = document.getElementById('valRateLine2');
          var valRateLine3El = document.getElementById('valRateLine3');
          var valRateLine4El = document.getElementById('valRateLine4');
          
          var valRateTotal = valRateTotalEl ? parseFloat(valRateTotalEl.innerText.replace('%', '')) || 0 : 0;
          var valRateLine1 = valRateLine1El ? parseFloat(valRateLine1El.innerText.replace('%', '')) || 0 : 0;
          var valRateLine2 = valRateLine2El ? parseFloat(valRateLine2El.innerText.replace('%', '')) || 0 : 0;
          var valRateLine3 = valRateLine3El ? parseFloat(valRateLine3El.innerText.replace('%', '')) || 0 : 0;
          var valRateLine4 = valRateLine4El ? parseFloat(valRateLine4El.innerText.replace('%', '')) || 0 : 0;

          console.log('Values:', valRateTotal, valRateLine1, valRateLine2, valRateLine3, valRateLine4);

          // Create gauge charts
          createGaugeChart('gaugeTotal', valRateTotal, 'All Lines');
          createGaugeChart('gaugeLine1', valRateLine1, 'Line 1');
          createGaugeChart('gaugeLine2', valRateLine2, 'Line 2');
          createGaugeChart('gaugeLine3', valRateLine3, 'Line 3');
          createGaugeChart('gaugeLine4', valRateLine4, 'Line 4');

          // Apply color classes to values
          ['Total', 'Line1', 'Line2', 'Line3', 'Line4'].forEach(function(line) {
            var element = document.getElementById('valRate' + line);
            if (element) {
              var text = element.textContent;
              var rate = parseFloat(text.replace('%', ''));
              if (!isNaN(rate)) {
                if (rate > 90) {
                  element.classList.add('rate-excellent');
                } else if (rate >= 80) {
                  element.classList.add('rate-good');
                } else {
                  element.classList.add('rate-poor');
                }
              }
            }
          });
        });
      } catch (ex) {
        console.error('Gauge chart error:', ex);
      }
    })();

    // ===== AUTO-REFRESH FUNCTIONALITY =====
    (function() {
      var refreshInterval = 120; // seconds (2 minutes)
      var countdown = refreshInterval;
      var timerElement = document.getElementById('refreshTimer');
      var indicatorElement = document.getElementById('refreshIndicator');
      var isRefreshing = false;

      if (!timerElement || !indicatorElement) {
        console.log('Auto-refresh disabled: indicator elements not found');
        return;
      }

      function formatTime(seconds) {
        if (seconds >= 60) {
          var minutes = Math.floor(seconds / 60);
          var secs = seconds % 60;
          return minutes + 'm' + (secs > 0 ? ' ' + secs + 's' : '');
        }
        return seconds + 's';
      }

      function updateTimer() {
        if (isRefreshing || !timerElement) return;
        
        countdown--;
        if (countdown <= 0) {
          refreshPage();
        } else {
          timerElement.textContent = 'Next refresh in ' + formatTime(countdown);
        }
      }

      function refreshPage() {
        if (!indicatorElement || !timerElement) return;
        
        isRefreshing = true;
        indicatorElement.classList.add('refreshing');
        timerElement.textContent = 'Refreshing...';
        
        __doPostBack('', 'AutoRefresh');
      }

      setInterval(updateTimer, 1000);

      var userInteractionElements = document.querySelectorAll('input, select, button');
      userInteractionElements.forEach(function(el) {
        el.addEventListener('focus', function() {
          countdown = refreshInterval;
        });
      });
    })();
  </script>
</asp:Content>
