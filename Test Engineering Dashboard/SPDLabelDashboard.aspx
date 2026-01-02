<%@ Page Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="SPDLabelDashboard.aspx.cs" Inherits="TED_SPDLabelDashboard" %>
<asp:Content ID="TitleContent" ContentPlaceHolderID="TitleContent" runat="server">SPD Label Dashboard</asp:Content>
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

    .btn-action { border-radius:12px; padding:10px 22px; border:none; font-size:14px; font-weight:600; font-family:inherit; cursor:pointer; transition:all .2s cubic-bezier(.4,0,.2,1); box-shadow:0 2px 8px -2px rgba(0,0,0,.25); }
    .btn-action:hover { transform:translateY(-1px); box-shadow:0 6px 16px -4px rgba(0,0,0,.35); }
    .btn-scan { background:linear-gradient(135deg, #6d28d9, #5b21b6); color:#fff; }
    .btn-scan:hover { background:linear-gradient(135deg, #5b21b6, #4c1d95); }
    html.theme-light .btn-scan, html[data-theme='light'] .btn-scan { background:linear-gradient(135deg, #a78bfa, #8b5cf6); }

    /* KPI Cards */
    .kpi-grid { display:grid; grid-template-columns:repeat(4,1fr); gap:16px; }
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
    
    /* Blue highlight for main Validation Rate card */
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
    .kpi-value.rate-neutral { background:linear-gradient(135deg, #10b981, #34d399); -webkit-background-clip:text; -webkit-text-fill-color:transparent; background-clip:text; }

    /* Chart Container */
    .chart-container { border-radius:24px; padding:28px 32px; background:rgba(17,21,30,.92); border:1px solid rgba(255,255,255,.08); box-shadow:0 14px 28px -20px rgba(0,0,0,.65); }
    html.theme-light .chart-container, html[data-theme='light'] .chart-container { background:#fff; border:1px solid rgba(0,0,0,.08); box-shadow:0 12px 24px -18px rgba(0,0,0,.18); }
    .chart-header { display:flex; justify-content:space-between; align-items:center; margin-bottom:24px; }
    .chart-header h3 { margin:0; font-size:20px; font-weight:700; }
    .chart-canvas { width:100%; height:320px; }

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
    
    /* Timeline Styles */
    .timeline-wrapper { width:100%; }
    .timeline-item { 
      background:rgba(255,255,255,.04); 
      border:1px solid rgba(255,255,255,.08); 
      border-radius:12px; 
      padding:12px 18px; 
      margin-bottom:12px;
      transition:all .2s ease;
    }
    html.theme-light .timeline-item, html[data-theme='light'] .timeline-item { 
      background:#fafbfc; 
      border:1px solid rgba(0,0,0,.08); 
    }
    .timeline-item:hover {
      background:rgba(255,255,255,.06);
      border-color:rgba(255,255,255,.12);
      transform:translateX(2px);
    }
    html.theme-light .timeline-item:hover, html[data-theme='light'] .timeline-item:hover {
      background:#f5f7fa;
      border-color:rgba(0,0,0,.12);
    }
    
    .timeline-item .timeline-header {
      display:flex;
      justify-content:space-between;
      align-items:center;
      margin-bottom:10px;
      gap:16px;
    }
    
    .timeline-serial { 
      display:flex; 
      align-items:baseline; 
      gap:10px;
    }
    .serial-label { font-size:9px; text-transform:uppercase; letter-spacing:.05em; opacity:.5; font-weight:600; }
    .serial-value { font-size:16px; font-weight:700; color:#60a5fa; letter-spacing:-.02em; }
    html.theme-light .serial-value, html[data-theme='light'] .serial-value { color:#2563eb; }
    
    .timeline-meta { display:flex; gap:10px; align-items:center; flex-wrap:wrap; }
    .workcell-tag {
      padding:4px 10px;
      border-radius:6px;
      font-size:10px;
      font-weight:700;
      text-transform:uppercase;
      letter-spacing:.05em;
    }
    .workcell-tag.workcell-integrated {
      background:rgba(59,130,246,.15);
      color:#93c5fd;
      border:1px solid rgba(59,130,246,.3);
    }
    html.theme-light .workcell-tag.workcell-integrated, html[data-theme='light'] .workcell-tag.workcell-integrated {
      background:rgba(59,130,246,.1);
      color:#2563eb;
    }
    .workcell-tag.workcell-sidemount {
      background:rgba(168,85,247,.15);
      color:#c4b5fd;
      border:1px solid rgba(168,85,247,.3);
    }
    html.theme-light .workcell-tag.workcell-sidemount, html[data-theme='light'] .workcell-tag.workcell-sidemount {
      background:rgba(168,85,247,.1);
      color:#7c3aed;
    }
    .part-number { font-size:11px; opacity:.6; font-weight:500; }
    
    /* Journey Steps - Horizontal Timeline */
    .timeline-journey { 
      display:flex;
      align-items:stretch;
      gap:0;
      overflow-x:auto;
      padding:4px 0;
    }
    .journey-step {
      display:flex;
      flex-direction:column;
      align-items:center;
      position:relative;
      flex:1;
      min-width:100px;
    }
    
    .step-icon {
      width:36px;
      height:36px;
      border-radius:50%;
      display:flex;
      align-items:center;
      justify-content:center;
      z-index:2;
      margin-bottom:6px;
      flex-shrink:0;
    }
    .step-icon svg { width:16px; height:16px; }
    
    .step-complete .step-icon {
      background:rgba(16,185,129,.2);
      border:2px solid #10b981;
      color:#34d399;
    }
    html.theme-light .step-complete .step-icon, html[data-theme='light'] .step-complete .step-icon {
      background:rgba(16,185,129,.15);
      border-color:#059669;
      color:#059669;
    }
    
    .step-failed .step-icon {
      background:rgba(239,68,68,.2);
      border:2px solid #ef4444;
      color:#f87171;
    }
    html.theme-light .step-failed .step-icon, html[data-theme='light'] .step-failed .step-icon {
      background:rgba(239,68,68,.15);
      border-color:#dc2626;
      color:#dc2626;
    }
    
    .step-pending .step-icon {
      background:rgba(148,163,184,.15);
      border:2px dashed rgba(148,163,184,.4);
      color:#94a3b8;
    }
    html.theme-light .step-pending .step-icon, html[data-theme='light'] .step-pending .step-icon {
      background:rgba(148,163,184,.1);
      border-color:rgba(100,116,139,.4);
      color:#64748b;
    }
    
    .step-connector {
      position:absolute;
      top:18px;
      left:50%;
      width:100%;
      height:2px;
      background:rgba(255,255,255,.15);
      z-index:1;
    }
    html.theme-light .step-connector, html[data-theme='light'] .step-connector {
      background:rgba(0,0,0,.12);
    }
    .journey-step:last-child .step-connector {
      display:none;
    }
    .step-pending .step-connector {
      background:repeating-linear-gradient(
        to right,
        rgba(148,163,184,.3),
        rgba(148,163,184,.3) 5px,
        transparent 5px,
        transparent 10px
      );
    }
    
    .step-content {
      text-align:center;
      display:flex;
      flex-direction:column;
      gap:2px;
    }
    
    .step-title {
      font-size:10px;
      font-weight:600;
      margin-bottom:2px;
      opacity:.7;
      white-space:nowrap;
    }
    
    .step-status {
      font-size:13px;
      font-weight:700;
      margin-bottom:2px;
    }
    .status-passed { color:#34d399; }
    html.theme-light .status-passed, html[data-theme='light'] .status-passed { color:#059669; }
    .status-failed { color:#f87171; }
    html.theme-light .status-failed, html[data-theme='light'] .status-failed { color:#dc2626; }
    .status-pending { color:#94a3b8; }
    html.theme-light .status-pending, html[data-theme='light'] .status-pending { color:#64748b; }
    
    .step-time {
      font-size:11px;
      opacity:.7;
      white-space:nowrap;
    }
    
    .empty-state { padding:48px; text-align:center; opacity:.6; }
    .empty-state-icon { font-size:64px; margin-bottom:16px; opacity:.3; }
    .empty-state-text { font-size:16px; font-weight:600; }

    /* Date Range Display */
    .info-banner { display:flex; align-items:center; justify-content:space-between; gap:16px; padding:12px 20px; border-radius:12px; background:rgba(255,255,255,.06); margin-bottom:4px; flex-wrap:wrap; }
    html.theme-light .info-banner, html[data-theme='light'] .info-banner { background:rgba(0,0,0,.04); }
    .date-range-display { display:inline-flex; align-items:center; gap:8px; font-size:14px; font-weight:500; }
    
    /* Auto-refresh Indicator */
    .refresh-indicator { display:inline-flex; align-items:center; gap:8px; font-size:13px; font-weight:500; opacity:.7; transition:opacity .2s ease; }
    .refresh-indicator.refreshing { opacity:1; }
    .refresh-indicator svg { width:16px; height:16px; animation:spin 2s linear infinite; }
    .refresh-indicator.refreshing svg { animation:spin .5s linear infinite; }
    @keyframes spin { from { transform:rotate(0deg); } to { transform:rotate(360deg); } }
    
    /* Percentage Ring */
    .percentage-ring { position:relative; width:100px; height:100px; margin:8px auto; }
    .percentage-svg { transform:rotate(-90deg); }
    .percentage-bg { fill:none; stroke:rgba(255,255,255,.1); stroke-width:10; }
    html.theme-light .percentage-bg, html[data-theme='light'] .percentage-bg { stroke:rgba(0,0,0,.08); }
    .percentage-bar { fill:none; stroke:url(#gradient-success); stroke-width:10; stroke-linecap:round; transition:stroke-dashoffset .5s ease; }
    .percentage-text { position:absolute; top:50%; left:50%; transform:translate(-50%,-50%); font-size:24px; font-weight:800; }

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
        <h1>SPD Label Verification Dashboard</h1>
        <p>Track validation metrics and serial number verification status across all workcells.</p>
      </div>
      <div class="header-actions">
        <div class="period-selector">
          <asp:Button ID="btnYesterday" runat="server" Text="Yesterday" CssClass="period-btn" OnClick="btnPeriod_Click" CommandArgument="Yesterday" />
          <asp:Button ID="btnDay" runat="server" Text="Day" CssClass="period-btn active" OnClick="btnPeriod_Click" CommandArgument="Day" />
          <asp:Button ID="btnWeek" runat="server" Text="Week" CssClass="period-btn" OnClick="btnPeriod_Click" CommandArgument="Week" />
          <asp:Button ID="btnMonth" runat="server" Text="Month" CssClass="period-btn" OnClick="btnPeriod_Click" CommandArgument="Month" />
        </div>
        <asp:Button ID="btnGoToScan" runat="server" Text="Go to Scanner" CssClass="btn-action btn-scan" OnClick="btnGoToScan_Click" CausesValidation="false" />
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
      <div class="kpi-card status-blue">
        <div class="kpi-label">Validation Rate</div>
        <div style="display: flex; align-items: center; justify-content: space-between; margin-top: 4px; height: 60px;">
          <div class="kpi-value" id="valRateOverall" runat="server" style="margin-bottom: 0;"><asp:Literal ID="litValidationRate" runat="server" Text="0%" /></div>
          <div style="width: 75px; height: 60px; position: relative; margin-right: -4px;" onclick="event.stopPropagation();">
            <canvas id="gaugeValidationRate"></canvas>
          </div>
        </div>
        <div class="kpi-footer" style="margin-top: 8px;">
          <asp:Literal ID="litTestedUnits" runat="server" Text="0" /> tested / 
          <asp:Literal ID="litValidatedUnits" runat="server" Text="0" /> validated
        </div>
      </div>
      
      <div class="kpi-card">
        <div class="kpi-label">Integrated Line</div>
        <div style="display: flex; align-items: center; justify-content: space-between; margin-top: 4px; height: 60px;">
          <div class="kpi-value" id="valRateIntegrated" runat="server" style="margin-bottom: 0;"><asp:Literal ID="litIntegratedRate" runat="server" Text="0%" /></div>
          <div style="width: 75px; height: 60px; position: relative; margin-right: -4px;" onclick="event.stopPropagation();">
            <canvas id="gaugeIntegrated"></canvas>
          </div>
        </div>
        <div class="kpi-footer" style="margin-top: 8px;">
          <asp:Literal ID="litIntegratedTested" runat="server" Text="0" /> tested / 
          <asp:Literal ID="litIntegratedValidated" runat="server" Text="0" /> validated
        </div>
      </div>
      
      <div class="kpi-card">
        <div class="kpi-label">Sidemount Line</div>
        <div style="display: flex; align-items: center; justify-content: space-between; margin-top: 4px; height: 60px;">
          <div class="kpi-value" id="valRateSidemount" runat="server" style="margin-bottom: 0;"><asp:Literal ID="litSidemountRate" runat="server" Text="0%" /></div>
          <div style="width: 75px; height: 60px; position: relative; margin-right: -4px;" onclick="event.stopPropagation();">
            <canvas id="gaugeSidemount"></canvas>
          </div>
        </div>
        <div class="kpi-footer" style="margin-top: 8px;">
          <asp:Literal ID="litSidemountTested" runat="server" Text="0" /> tested / 
          <asp:Literal ID="litSidemountValidated" runat="server" Text="0" /> validated
        </div>
      </div>
      
      <div class="kpi-card">
        <div class="kpi-label">Validation Pass Rate</div>
        <div style="display: flex; align-items: center; justify-content: space-between; margin-top: 4px; height: 60px;">
          <div class="kpi-value rate-neutral" style="margin-bottom: 0;"><asp:Literal ID="litPassRate" runat="server" Text="0%" /></div>
          <div style="width: 75px; height: 60px; position: relative; margin-right: -4px;" onclick="event.stopPropagation();">
            <canvas id="gaugePassRate"></canvas>
          </div>
        </div>
        <div class="kpi-footer" style="margin-top: 8px;">
          <asp:Literal ID="litPassedCount" runat="server" Text="0" /> passed / 
          <asp:Literal ID="litFailedCount" runat="server" Text="0" /> failed
        </div>
      </div>
    </section>

    <asp:Panel ID="pnlChart" runat="server" CssClass="chart-container" Visible="false">
      <div class="chart-header">
        <h3>Validation Trend</h3>
      </div>
      <canvas id="validationChart" class="chart-canvas"></canvas>
    </asp:Panel>

    <section class="tracking-section">
      <div class="tracking-header">
        <h3>Serial Number Tracking <asp:Label ID="lblTrackingCount" runat="server" CssClass="count" Text="" /></h3>
        <div class="tracking-filter">
          <asp:TextBox ID="txtPartSearch" runat="server" CssClass="search-input" placeholder="Search serial number..." AutoPostBack="true" OnTextChanged="txtPartSearch_TextChanged" />
          <asp:DropDownList ID="ddlStatusFilter" runat="server" CssClass="filter-dropdown" AutoPostBack="true" OnSelectedIndexChanged="ddlStatusFilter_SelectedIndexChanged">
            <asp:ListItem Value="ALL" Selected="True">All Status</asp:ListItem>
            <asp:ListItem Value="Validated">Validated</asp:ListItem>
            <asp:ListItem Value="Failed">Has Failures</asp:ListItem>
            <asp:ListItem Value="Pending">Pending</asp:ListItem>
          </asp:DropDownList>
          <asp:DropDownList ID="ddlWorkcellFilter" runat="server" CssClass="filter-dropdown" AutoPostBack="true" OnSelectedIndexChanged="ddlWorkcellFilter_SelectedIndexChanged">
            <asp:ListItem Value="ALL" Selected="True">All Workcells</asp:ListItem>
            <asp:ListItem Value="Integrated">Integrated</asp:ListItem>
            <asp:ListItem Value="Sidemount">Sidemount</asp:ListItem>
          </asp:DropDownList>
        </div>
      </div>
      <div class="timeline-wrapper">
        <asp:Panel ID="pnlTrackingTable" runat="server">
          <asp:Repeater ID="rptSerialTracking" runat="server">
            <ItemTemplate>
              <div class="timeline-item">
                <div class="timeline-header">
                  <div class="timeline-serial">
                    <span class="serial-value"><%# Eval("SerialNumber") %></span>
                    <span class="part-number"><%# Eval("PartNumber") %></span>
                  </div>
                  <div class="timeline-meta">
                    <span class="workcell-tag workcell-<%# Eval("Workcell").ToString().ToLower() %>"><%# Eval("Workcell") %></span>
                    <span class="part-number"><%# Eval("LastValidatorName") %></span>
                  </div>
                </div>
                
                <div class="timeline-journey">
                  <!-- Test Result Step -->
                  <div class="journey-step step-complete">
                    <div class="step-icon">
                      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                        <path d="M9 11l3 3L22 4"></path>
                        <path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"></path>
                      </svg>
                    </div>
                    <div class="step-connector"></div>
                    <div class="step-content">
                      <div class="step-title">Functional Test</div>
                      <div class="step-status status-passed">PASSED</div>
                      <div class="step-time"><%# Eval("TestDate", "{0:MM/dd HH:mm}") %></div>
                    </div>
                  </div>
                  
                  <!-- Validation Attempts -->
                  <%# RenderValidationSteps(Eval("ValidationAttempts")) %>
                </div>
              </div>
            </ItemTemplate>
          </asp:Repeater>
        </asp:Panel>
        <asp:Panel ID="pnlEmptyState" runat="server" CssClass="empty-state" Visible="false">
          <div class="empty-state-icon">&#128202;</div>
          <div class="empty-state-text">No test data for the selected period</div>
        </asp:Panel>
      </div>
    </section>
  </div>

  <asp:HiddenField ID="hfChartData" runat="server" />
  <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
  <script type="text/javascript">
    (function() {
      try {
        var chartDataJson = document.getElementById('<%= hfChartData.ClientID %>').value;
        if (!chartDataJson || chartDataJson === '') {
          console.log('No chart data available');
          return;
        }

        var chartData = JSON.parse(chartDataJson);
        if (!chartData || !chartData.labels || !chartData.passed || !chartData.failed) {
          console.log('Invalid chart data structure');
          return;
        }

        var ctx = document.getElementById('validationChart');
        if (!ctx) {
          console.log('Chart canvas not found');
          return;
        }

        // Prevent multiple chart instances
        if (window.spdChart) {
          window.spdChart.destroy();
        }

        var isDark = !document.documentElement.classList.contains('theme-light') && 
                     document.documentElement.getAttribute('data-theme') !== 'light';
        
        var gridColor = isDark ? 'rgba(255,255,255,0.08)' : 'rgba(0,0,0,0.08)';
        var textColor = isDark ? 'rgba(255,255,255,0.8)' : 'rgba(0,0,0,0.8)';

        window.spdChart = new Chart(ctx, {
        type: 'line',
        data: {
          labels: chartData.labels,
          datasets: [
            {
              label: 'Passed',
              data: chartData.passed,
              borderColor: '#10b981',
              backgroundColor: 'rgba(16,185,129,0.1)',
              tension: 0.4,
              fill: true,
              borderWidth: 3
            },
            {
              label: 'Failed',
              data: chartData.failed,
              borderColor: '#ef4444',
              backgroundColor: 'rgba(239,68,68,0.1)',
              tension: 0.4,
              fill: true,
              borderWidth: 3
            }
          ]
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          interaction: {
            mode: 'index',
            intersect: false
          },
          plugins: {
            legend: {
              display: true,
              position: 'top',
              labels: { color: textColor, font: { size: 13, weight: '600' } }
            },
            tooltip: {
              backgroundColor: isDark ? 'rgba(17,21,30,0.95)' : 'rgba(255,255,255,0.95)',
              titleColor: textColor,
              bodyColor: textColor,
              borderColor: gridColor,
              borderWidth: 1,
              padding: 12,
              displayColors: true
            }
          },
          scales: {
            y: {
              beginAtZero: true,
              grid: { color: gridColor },
              ticks: { color: textColor, font: { size: 12 } }
            },
            x: {
              grid: { color: gridColor },
              ticks: { color: textColor, font: { size: 12 } }
            }
          }
        }
      });
      } catch (ex) {
        console.error('Chart initialization error:', ex);
      }
    })();

    // ===== HYBRID KPI GAUGE CHARTS =====
    (function() {
      try {
        var isDark = !document.documentElement.classList.contains('theme-light') && 
                     document.documentElement.getAttribute('data-theme') !== 'light';
        
        var colors = {
          success: isDark ? '#34d399' : '#059669',
          warning: isDark ? '#fbbf24' : '#d97706',
          danger: isDark ? '#f87171' : '#dc2626',
          bgEmpty: isDark ? 'rgba(255,255,255,0.15)' : 'rgba(0,0,0,0.12)'
        };

        function createGaugeChart(canvasId, percentage, label) {
          var ctx = document.getElementById(canvasId);
          if (!ctx) return;

          var gaugeColor = percentage > 90 ? colors.success : 
                          percentage >= 80 ? colors.warning : 
                          colors.danger;

          new Chart(ctx, {
            type: 'doughnut',
            data: {
              datasets: [{
                data: [percentage, 100 - percentage],
                backgroundColor: [gaugeColor, colors.bgEmpty],
                borderWidth: 0,
                cutout: '70%'
              }]
            },
            options: {
              responsive: true,
              maintainAspectRatio: false,
              rotation: -90,
              circumference: 180,
              plugins: {
                legend: { display: false },
                tooltip: { enabled: false }
              }
            }
          });
        }

        // Get validation rates from the page
        var valRateOverall = parseFloat(document.getElementById('<%= valRateOverall.ClientID %>').textContent.replace('%', '')) || 0;
        var valRateIntegrated = parseFloat(document.getElementById('<%= valRateIntegrated.ClientID %>').textContent.replace('%', '')) || 0;
        var valRateSidemount = parseFloat(document.getElementById('<%= valRateSidemount.ClientID %>').textContent.replace('%', '')) || 0;
        var passRate = parseFloat('<%= litPassRate.Text %>'.replace('%', '')) || 0;

        // Create gauge charts
        createGaugeChart('gaugeValidationRate', valRateOverall, 'Validation Rate');
        createGaugeChart('gaugeIntegrated', valRateIntegrated, 'Integrated');
        createGaugeChart('gaugeSidemount', valRateSidemount, 'Sidemount');
        createGaugeChart('gaugePassRate', passRate, 'Pass Rate');

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

      // Exit if elements not found
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
        
        // Trigger postback to reload data
        __doPostBack('', 'AutoRefresh');
      }

      // Start countdown timer
      setInterval(updateTimer, 1000);

      // Pause refresh on user interaction
      var userInteractionElements = document.querySelectorAll('input, select, button');
      userInteractionElements.forEach(function(el) {
        el.addEventListener('focus', function() {
          countdown = refreshInterval; // Reset timer on interaction
        });
      });
    })();
  </script>
</asp:Content>
