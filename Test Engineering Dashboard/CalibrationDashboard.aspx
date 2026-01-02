<%@ Page Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="CalibrationDashboard.aspx.cs" Inherits="TED_CalibrationDashboard" %>
<asp:Content ID="CalDashTitle" ContentPlaceHolderID="TitleContent" runat="server">Calibration Dashboard - Test Engineering</asp:Content>
<asp:Content ID="CalDashHead" ContentPlaceHolderID="HeadContent" runat="server">
  <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/chartjs-plugin-datalabels@2.2.0/dist/chartjs-plugin-datalabels.min.js"></script>
  <script src="https://d3js.org/d3.v7.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/d3-sankey@0.12.3/dist/d3-sankey.min.js"></script>
  <style>
    /* Prevent page-level horizontal scroll and keep width constrained */
    html, body { max-width:100%; overflow-x:hidden; }
    :root { --sidebar-w: 280px; }
    
    .dash-shell { 
      --col-btm-gap: 12px; 
      display:grid; 
      grid-template-columns: var(--sidebar-w) 1fr; 
      gap:18px; 
      height:calc(100dvh - var(--vh-offset)); 
      padding:10px 18px 34px; 
      box-sizing:border-box; 
    }
    .dash-shell > * { min-width:0; min-height:0; }
    
    /* SIDEBAR STYLES */
    .dash-sidebar { 
      position:sticky; 
      top:12px; 
      height:calc(100% - 12px - var(--col-btm-gap)); 
      margin-bottom:var(--col-btm-gap); 
      display:flex; 
      flex-direction:column; 
      background:rgba(25,29,37,.55); 
      border:1px solid rgba(255,255,255,.08); 
      border-radius:18px; 
      box-shadow:0 16px 36px -10px rgba(0,0,0,.6), 0 0 0 1px rgba(255,255,255,.05), 0 0 10px rgba(235,235,240,.12); 
      backdrop-filter:blur(40px) saturate(140%); 
      padding:16px 14px; 
      overflow:auto; 
    }
    html.theme-light .dash-sidebar, html[data-theme='light'] .dash-sidebar { 
      background:rgba(255,255,255,.7); 
      border:1px solid rgba(0,0,0,.08); 
      box-shadow:0 14px 34px -12px rgba(0,0,0,.25), 0 0 0 1px rgba(0,0,0,.05), 0 0 10px rgba(0,0,0,.12); 
    }
    
    .sidebar-user { 
      display:flex; 
      align-items:center; 
      gap:10px; 
      padding:10px 8px 12px; 
      border-bottom:1px solid rgba(255,255,255,.08); 
      margin:0 6px 10px; 
    }
    html.theme-light .sidebar-user, html[data-theme='light'] .sidebar-user { border-bottom:1px solid rgba(0,0,0,.08); }
    
    .user-meta { display:flex; flex-direction:column; line-height:1.1; font-size:11px; opacity:.85; }
    .avatar { 
      width:34px; 
      height:34px; 
      border-radius:50%; 
      display:flex; 
      align-items:center; 
      justify-content:center; 
      background:rgba(255,255,255,.1); 
      border:1px solid rgba(255,255,255,.2); 
      font-weight:700; 
    }
    html.theme-light .avatar, html[data-theme='light'] .avatar { 
      background:#f1f4f9; 
      border:1px solid rgba(0,0,0,.12); 
      color:#1b222b; 
    }
    
    .nav { padding:8px 4px; overflow:visible; }
    .nav-title { font-size:11px; letter-spacing:.6px; opacity:.65; padding:12px 12px 6px; text-transform:uppercase; }
    .nav-list { list-style:none; margin:0; padding:0; }
    .nav-link { 
      display:flex; 
      align-items:center; 
      gap:10px; 
      padding:10px 12px; 
      margin:2px 6px; 
      border-radius:12px; 
      text-decoration:none; 
      color:inherit; 
      border:1px solid transparent; 
      transition:background .25s ease, color .25s ease, border-color .25s ease; 
      font-size:13px; 
    }
    .nav-link .icon { width:16px; height:16px; color:currentColor; opacity:.9; }
    .nav-link:hover { background:rgba(255,255,255,.08); border-color:rgba(255,255,255,.12); }
    html.theme-light .nav-link:hover, html[data-theme='light'] .nav-link:hover { 
      background:rgba(0,0,0,.055); 
      border-color:rgba(0,0,0,.10); 
    }
    .nav-link.active { 
      background:rgba(77,141,255,.13); 
      border-color:rgba(77,141,255,.3); 
      color:#bcd4ff; 
    }
    html.theme-light .nav-link.active, html[data-theme='light'] .nav-link.active { 
      background:#ffffff; 
      border-color:rgba(77,141,255,.35); 
      color:#1f2530; 
      box-shadow:0 1px 0 rgba(255,255,255,.7) inset; 
    }
    .nav-link.danger { color:#ff6b6b; border-color:transparent; }
    .nav-link.danger .icon { color:currentColor; }
    .nav-link.danger:hover { 
      background:rgba(255,86,86,.14); 
      border-color:rgba(255,86,86,.35); 
      color:#ff8a8a; 
    }
    html.theme-light .nav-link.danger, html[data-theme='light'] .nav-link.danger { color:#c62828; }
    html.theme-light .nav-link.danger:hover, html[data-theme='light'] .nav-link.danger:hover { 
      background:rgba(198,40,40,.10); 
      border-color:rgba(198,40,40,.35); 
      color:#b71c1c; 
    }
    .nav-link.disabled { opacity:.45; cursor:not-allowed; pointer-events:none; color:#888; }
    .nav-link.disabled .icon { opacity:.5; }
    html.theme-light .nav-link.disabled, html[data-theme='light'] .nav-link.disabled { color:#999; opacity:.5; }

    /* MAIN CONTENT COLUMN */
    .dash-col { 
      display:flex; 
      flex-direction:column; 
      gap:18px; 
      overflow-y:auto; 
      overflow-x:hidden; 
      padding-right:4px; 
    }
    
    .page-header { 
      display:flex; 
      justify-content:space-between; 
      align-items:center; 
      padding:0 0 14px; 
      margin-bottom:16px;
      border-bottom:1px solid rgba(255,255,255,.08);
    }
    html.theme-light .page-header, html[data-theme='light'] .page-header { 
      border-bottom:1px solid rgba(0,0,0,.08); 
    }
    
    .page-title { font-size:24px; font-weight:800; letter-spacing:.2px; margin:0; }
    .page-subtitle { font-size:12px; opacity:.7; margin:4px 0 0; font-weight:400; }
    
    .header-actions { 
      display:flex; 
      gap:8px; 
      align-items:center; 
      margin-right:12px; 
    }
    .btn-sm { 
      padding:8px 14px; 
      border-radius:8px; 
      border:1px solid rgba(255,255,255,.18); 
      background:rgba(255,255,255,.08);
      color:inherit; 
      font:inherit; 
      font-size:12px; 
      font-weight:600;
      cursor:pointer;
      transition:all .2s ease;
      text-decoration:none;
      display:inline-flex;
      align-items:center;
      gap:6px;
    }
    .btn-sm:hover { 
      background:rgba(255,255,255,.14);
      border-color:rgba(255,255,255,.28);
      transform:translateY(-1px);
    }
    .btn-sm.btn-primary {
      background:rgba(77,141,255,.25);
      border-color:rgba(77,141,255,.4);
      color:#bcd4ff;
    }
    .btn-sm.btn-primary:hover {
      background:rgba(77,141,255,.35);
      border-color:rgba(77,141,255,.5);
    }
    html.theme-light .btn-sm, html[data-theme='light'] .btn-sm { 
      background:#f5f7fa;
      border:1px solid rgba(0,0,0,.14);
      color:#1f242b;
    }
    html.theme-light .btn-sm:hover, html[data-theme='light'] .btn-sm:hover { 
      background:#e8ecf1;
      border-color:rgba(0,0,0,.20);
    }
    html.theme-light .btn-sm.btn-primary, html[data-theme='light'] .btn-sm.btn-primary { 
      background:#4d8dff;
      border-color:#4d8dff;
      color:#ffffff;
    }

    /* Icon Button Styles - Filled Design with Darker Colors */
    .btn-icon {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      width: 40px;
      height: 40px;
      border-radius: 10px;
      border: 1px solid rgba(255,255,255,.18);
      background: rgba(255,255,255,.08);
      color: inherit;
      cursor: pointer;
      transition: all .2s ease;
      position: relative;
    }
    .btn-icon:hover {
      background: rgba(255,255,255,.15);
      border-color: rgba(255,255,255,.3);
      transform: translateY(-2px);
      box-shadow: 0 4px 12px rgba(0,0,0,.2);
    }
    .btn-icon svg {
      width: 20px;
      height: 20px;
      stroke-width: 2;
    }
    /* Purple Grid View button - Darker gradient */
    .btn-icon-accent {
      border: 1px solid rgba(168,85,247,.4);
      background: linear-gradient(135deg, rgba(168,85,247,.25), rgba(168,85,247,.15));
      color: #e9d5ff;
      box-shadow: 0 2px 8px rgba(168,85,247,.2);
    }
    .btn-icon-accent:hover {
      background: linear-gradient(135deg, rgba(168,85,247,.35), rgba(168,85,247,.25));
      border-color: rgba(168,85,247,.5);
      box-shadow: 0 4px 12px rgba(168,85,247,.3);
      transform: translateY(-2px);
    }
    /* Blue primary button (Add New) - Darker gradient */
    .btn-icon-primary {
      border: 1px solid rgba(77,141,255,.4);
      background: linear-gradient(135deg, rgba(77,141,255,.25), rgba(77,141,255,.15));
      color: #bcd4ff;
      box-shadow: 0 2px 8px rgba(77,141,255,.2);
    }
    .btn-icon-primary:hover {
      background: linear-gradient(135deg, rgba(77,141,255,.35), rgba(77,141,255,.25));
      border-color: rgba(77,141,255,.5);
      box-shadow: 0 4px 12px rgba(77,141,255,.3);
      transform: translateY(-2px);
    }
    /* Orange calendar button - Darker gradient */
    .btn-icon-calendar {
      border: 1px solid rgba(251,146,60,.4);
      background: linear-gradient(135deg, rgba(251,146,60,.25), rgba(251,146,60,.15));
      color: #fed7aa;
      box-shadow: 0 2px 8px rgba(251,146,60,.2);
    }
    .btn-icon-calendar:hover {
      background: linear-gradient(135deg, rgba(251,146,60,.35), rgba(251,146,60,.25));
      border-color: rgba(251,146,60,.5);
      box-shadow: 0 4px 12px rgba(251,146,60,.3);
      transform: translateY(-2px);
    }
    /* Brown calendar button - Darker gradient */
    .btn-icon-brown {
      border: 1px solid rgba(180,83,9,.4);
      background: linear-gradient(135deg, rgba(180,83,9,.25), rgba(180,83,9,.15));
      color: #fed7aa;
      box-shadow: 0 2px 8px rgba(180,83,9,.2);
    }
    .btn-icon-brown:hover {
      background: linear-gradient(135deg, rgba(180,83,9,.35), rgba(180,83,9,.25));
      border-color: rgba(180,83,9,.5);
      box-shadow: 0 4px 12px rgba(180,83,9,.3);
      transform: translateY(-2px);
    }
    /* Eye/Preview button (Amber) - Darker gradient */
    .btn-icon-amber {
      border: 1px solid rgba(245,158,11,.4);
      background: linear-gradient(135deg, rgba(245,158,11,.25), rgba(245,158,11,.15));
      color: #fef3c7;
      box-shadow: 0 2px 8px rgba(245,158,11,.2);
    }
    .btn-icon-amber:hover {
      background: linear-gradient(135deg, rgba(245,158,11,.35), rgba(245,158,11,.25));
      border-color: rgba(245,158,11,.5);
      box-shadow: 0 4px 12px rgba(245,158,11,.3);
      transform: translateY(-2px);
    }
    /* Light mode - solid filled colors */
    html.theme-light .btn-icon,
    html[data-theme='light'] .btn-icon {
      background: #f5f7fa;
      border: 1px solid rgba(0,0,0,.12);
      color: #1f242b;
    }
    html.theme-light .btn-icon:hover,
    html[data-theme='light'] .btn-icon:hover {
      background: #e8ecf1;
      border-color: rgba(0,0,0,.20);
      box-shadow: 0 4px 12px rgba(0,0,0,.12);
    }
    html.theme-light .btn-icon-accent,
    html[data-theme='light'] .btn-icon-accent {
      background: linear-gradient(135deg, #a855f7, #9333ea);
      border: 1px solid #7c3aed;
      color: #ffffff;
      box-shadow: 0 2px 8px rgba(124,58,237,.25);
    }
    html.theme-light .btn-icon-accent:hover,
    html[data-theme='light'] .btn-icon-accent:hover {
      background: linear-gradient(135deg, #b366f9, #a855f7);
      box-shadow: 0 4px 12px rgba(124,58,237,.35);
    }
    html.theme-light .btn-icon-primary,
    html[data-theme='light'] .btn-icon-primary {
      background: linear-gradient(135deg, #4d8dff, #3b7eef);
      border: 1px solid #2563eb;
      color: #ffffff;
      box-shadow: 0 2px 8px rgba(37,99,235,.25);
    }
    html.theme-light .btn-icon-primary:hover,
    html[data-theme='light'] .btn-icon-primary:hover {
      background: linear-gradient(135deg, #5c9aff, #4a87f5);
      box-shadow: 0 4px 12px rgba(37,99,235,.35);
    }
    html.theme-light .btn-icon-calendar,
    html[data-theme='light'] .btn-icon-calendar {
      background: linear-gradient(135deg, #fb923c, #f97316);
      border: 1px solid #ea580c;
      color: #ffffff;
      box-shadow: 0 2px 8px rgba(234,88,12,.25);
    }
    html.theme-light .btn-icon-calendar:hover,
    html[data-theme='light'] .btn-icon-calendar:hover {
      background: linear-gradient(135deg, #fda64d, #fb923c);
      box-shadow: 0 4px 12px rgba(234,88,12,.35);
    }
    html.theme-light .btn-icon-brown,
    html[data-theme='light'] .btn-icon-brown {
      background: linear-gradient(135deg, #b45309, #92400e);
      border: 1px solid #78350f;
      color: #ffffff;
      box-shadow: 0 2px 8px rgba(120,53,15,.25);
    }
    html.theme-light .btn-icon-brown:hover,
    html[data-theme='light'] .btn-icon-brown:hover {
      background: linear-gradient(135deg, #c2621a, #b45309);
      box-shadow: 0 4px 12px rgba(120,53,15,.35);
    }
    html.theme-light .btn-icon-amber,
    html[data-theme='light'] .btn-icon-amber {
      background: linear-gradient(135deg, #f59e0b, #d97706);
      border: 1px solid #b45309;
      color: #ffffff;
      box-shadow: 0 2px 8px rgba(180,83,9,.25);
    }
    html.theme-light .btn-icon-amber:hover,
    html[data-theme='light'] .btn-icon-amber:hover {
      background: linear-gradient(135deg, #fbbf24, #f59e0b);
      box-shadow: 0 4px 12px rgba(180,83,9,.35);
    }
    
    /* Tooltip Styles - BELOW buttons, aligned left */
    .btn-icon[title]:hover::before {
      content: attr(title);
      position: absolute;
      top: calc(100% + 8px);
      right: 0;
      transform: translateX(0);
      padding: 6px 12px;
      background: rgba(15,23,42,0.95);
      color: #ffffff;
      font-size: 13px;
      font-weight: 500;
      font-family: 'Segoe UI', -apple-system, BlinkMacSystemFont, system-ui, sans-serif;
      letter-spacing: 0.01em;
      white-space: nowrap;
      border-radius: 6px;
      box-shadow: 0 4px 12px rgba(0,0,0,.3);
      pointer-events: none;
      z-index: 1000;
      animation: tooltipFadeIn 0.15s ease-out;
    }
    .btn-icon[title]:hover::after {
      content: '';
      position: absolute;
      top: calc(100% + 2px);
      right: 12px;
      transform: translateX(0);
      border: 6px solid transparent;
      border-bottom-color: rgba(15,23,42,0.95);
      pointer-events: none;
      z-index: 1000;
      animation: tooltipFadeIn 0.15s ease-out;
    }
    html.theme-light .btn-icon[title]:hover::before,
    html[data-theme='light'] .btn-icon[title]:hover::before {
      background: rgba(15,23,42,0.95);
      color: #ffffff;
    }
    html.theme-light .btn-icon[title]:hover::after,
    html[data-theme='light'] .btn-icon[title]:hover::after {
      border-bottom-color: rgba(15,23,42,0.95);
    }
    @keyframes tooltipFadeIn {
      from {
        opacity: 0;
        transform: translateY(-4px);
      }
      to {
        opacity: 1;
        transform: translateY(0);
      }
    }

    /* KPI CARDS */
    .kpi-grid { 
      display:grid; 
      grid-template-columns:repeat(auto-fit, minmax(240px, 1fr)); 
      gap:16px; 
      margin-bottom:16px;
      min-width:min-content;
    }
    
    @media (max-width: 1400px) {
      .kpi-grid { grid-template-columns:repeat(auto-fit, minmax(200px, 1fr)); }
    }
    
    @media (max-width: 1024px) {
      .kpi-grid { grid-template-columns:repeat(2, 1fr); }
    }
    
    @media (max-width: 640px) {
      .kpi-grid { grid-template-columns:1fr; }
    }
    
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
      overflow:visible;
    }
    html.theme-light .kpi-card, html[data-theme='light'] .kpi-card {
      background:linear-gradient(135deg, #ffffff, #fafbfc);
      border:1px solid rgba(0,0,0,.10);
      box-shadow:0 4px 16px -4px rgba(0,0,0,.15), 0 1px 0 rgba(255,255,255,.8) inset;
    }
    .kpi-card:hover { 
      transform:translateY(-2px); 
      box-shadow:0 12px 32px -10px rgba(0,0,0,.45); 
    }
    html.theme-light .kpi-card:hover, html[data-theme='light'] .kpi-card:hover { 
      box-shadow:0 6px 20px -6px rgba(0,0,0,.22); 
    }
    
    /* Status-based coloring for cards */
    .kpi-card.status-red { 
      border-left:4px solid #ef4444; 
      background:linear-gradient(135deg, rgba(239,68,68,.15), rgba(239,68,68,.05)); 
    }
    .kpi-card.status-red .kpi-value { color:#fca5a5; }
    html.theme-light .kpi-card.status-red, html[data-theme='light'] .kpi-card.status-red { 
      border-left:4px solid #ef4444; 
      background:linear-gradient(135deg, #fff5f5, #ffffff); 
    }
    html.theme-light .kpi-card.status-red .kpi-value, html[data-theme='light'] .kpi-card.status-red .kpi-value { 
      color:#dc2626; 
    }
    
    .kpi-card.status-amber { 
      border-left:4px solid #f59e0b; 
      background:linear-gradient(135deg, rgba(245,158,11,.15), rgba(245,158,11,.05)); 
    }
    .kpi-card.status-amber .kpi-value { color:#fcd34d; }
    html.theme-light .kpi-card.status-amber, html[data-theme='light'] .kpi-card.status-amber { 
      border-left:4px solid #f59e0b; 
      background:linear-gradient(135deg, #fffbeb, #ffffff); 
    }
    html.theme-light .kpi-card.status-amber .kpi-value, html[data-theme='light'] .kpi-card.status-amber .kpi-value { 
      color:#d97706; 
    }
    
    .kpi-card.status-green { 
      border-left:4px solid #10b981; 
      background:linear-gradient(135deg, rgba(16,185,129,.15), rgba(16,185,129,.05)); 
    }
    .kpi-card.status-green .kpi-value { color:#6ee7b7; }
    html.theme-light .kpi-card.status-green, html[data-theme='light'] .kpi-card.status-green { 
      border-left:4px solid #10b981; 
      background:linear-gradient(135deg, #f0fdf4, #ffffff); 
    }
    html.theme-light .kpi-card.status-green .kpi-value, html[data-theme='light'] .kpi-card.status-green .kpi-value { 
      color:#059669; 
    }
    
    .kpi-card.status-blue { border-left:4px solid #3b82f6; }
    .kpi-card.status-blue .kpi-value { color:#93c5fd; }
    html.theme-light .kpi-card.status-blue .kpi-value, html[data-theme='light'] .kpi-card.status-blue .kpi-value { 
      color:#2563eb; 
    }
    
    .kpi-label { 
      font-size:11px; 
      font-weight:600; 
      letter-spacing:.3px; 
      opacity:.75; 
      margin-bottom:6px; 
      text-transform:uppercase; 
    }
    .kpi-value { 
      font-size:36px; 
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
    .kpi-trend { display:flex; align-items:center; gap:4px; }
    .kpi-trend.up { color:#10b981; }
    .kpi-trend.down { color:#ef4444; }
    .kpi-link { font-size:11px; text-decoration:none; color:inherit; opacity:.8; }
    .kpi-link:hover { opacity:1; text-decoration:underline; }
    .kpi-trend.up { color:#10b981; }
    .kpi-trend.down { color:#ef4444; }

    /* CHARTS */
    .chart-grid { 
      display:grid; 
      grid-template-columns:repeat(2, 1fr); 
      gap:16px; 
    }
    

    .chart-card { 
      background:rgba(25,29,37,.52); 
      border:1px solid rgba(255,255,255,.08); 
      border-radius:16px; 
      box-shadow:0 8px 24px -8px rgba(0,0,0,.4); 
      backdrop-filter:blur(28px) saturate(130%); 
      padding:20px; 
    }
    html.theme-light .chart-card, html[data-theme='light'] .chart-card { 
      background:#ffffff; 
      border:1px solid rgba(0,0,0,.08); 
      box-shadow:0 4px 18px -6px rgba(0,0,0,.18); 
    }
    
    .chart-header { 
      display:flex; 
      justify-content:space-between; 
      align-items:center; 
      margin-bottom:14px; 
      padding-bottom:10px;
      border-bottom:1px solid rgba(255,255,255,.06);
    }
    html.theme-light .chart-header, html[data-theme='light'] .chart-header { 
      border-bottom:1px solid rgba(0,0,0,.06); 
    }
    
    .chart-title { 
      font-size:14px; 
      font-weight:700; 
      letter-spacing:.2px; 
      margin:0; 
    }
    .chart-subtitle { 
      font-size:10px; 
      opacity:.65; 
      margin:2px 0 0; 
    }
    
    .chart-container { 
      position:relative; 
      flex:1; 
      min-height:0;
      display:flex;
      align-items:center;
      justify-content:center;
    }
    .chart-container canvas { 
      max-height:100%; 
    }

    /* UPCOMING CALIBRATIONS & RECENT LOGS LIST */
    .upcoming-list, .recent-logs-list { 
      background:rgba(25,29,37,.52); 
      border:1px solid rgba(255,255,255,.08); 
      border-radius:16px; 
      box-shadow:0 8px 24px -8px rgba(0,0,0,.4); 
      backdrop-filter:blur(28px) saturate(130%); 
      padding:18px 20px;
      min-width:0;
      overflow:hidden;
    }
    html.theme-light .upcoming-list, html[data-theme='light'] .upcoming-list,
    html.theme-light .recent-logs-list, html[data-theme='light'] .recent-logs-list { 
      background:#ffffff; 
      border:1px solid rgba(0,0,0,.08); 
      box-shadow:0 4px 18px -6px rgba(0,0,0,.18); 
    }
    
    .upcoming-header, .recent-logs-header { 
      display:flex; 
      justify-content:space-between; 
      align-items:center; 
      margin-bottom:14px; 
      padding-bottom:10px;
      border-bottom:1px solid rgba(255,255,255,.06);
    }
    html.theme-light .upcoming-header, html[data-theme='light'] .upcoming-header,
    html.theme-light .recent-logs-header, html[data-theme='light'] .recent-logs-header { 
      border-bottom:1px solid rgba(0,0,0,.06); 
    }
    
    .upcoming-title, .recent-logs-title { 
      font-size:14px; 
      font-weight:700; 
      letter-spacing:.2px; 
      margin:0; 
    }
    
    .upcoming-items, .recent-logs-items { 
      display:flex; 
      flex-direction:column; 
      gap:8px; 
      max-height:280px;
      overflow-y:auto;
      overflow-x:auto;
      min-width:0;
      width:100%;
    }
    
    .upcoming-item { 
      display:grid;
      grid-template-columns:120px 1fr 140px 110px;
      gap:12px;
      align-items:center;
      padding:10px 12px; 
      border-radius:10px; 
      background:rgba(255,255,255,.03);
      border:1px solid rgba(255,255,255,.06);
      transition:all .2s ease;
      font-size:12px;
      min-width:550px;
    }
    .upcoming-item:hover {
      background:rgba(255,255,255,.06);
      border-color:rgba(255,255,255,.12);
    }
    html.theme-light .upcoming-item, html[data-theme='light'] .upcoming-item { 
      background:#fafbfc;
      border:1px solid rgba(0,0,0,.06);
    }
    html.theme-light .upcoming-item:hover, html[data-theme='light'] .upcoming-item:hover { 
      background:#f5f7fa;
      border-color:rgba(0,0,0,.12);
    }

    /* Recent Logs Items */
    .recent-log-item {
      display:grid;
      grid-template-columns:240px 150px 120px 100px;
      gap:24px;
      align-items:center;
      padding:18px 24px;
      border-radius:10px;
      background:rgba(255,255,255,.03);
      border:1px solid rgba(255,255,255,.06);
      transition:all .2s ease;
      font-size:13px;
      min-width:640px;
    }
    .recent-log-item:hover {
      background:rgba(255,255,255,.06);
      border-color:rgba(255,255,255,.12);
    }
    html.theme-light .recent-log-item, html[data-theme='light'] .recent-log-item {
      background:#fafbfc;
      border:1px solid rgba(0,0,0,.06);
    }
    html.theme-light .recent-log-item:hover, html[data-theme='light'] .recent-log-item:hover {
      background:#f5f7fa;
      border-color:rgba(0,0,0,.12);
    }
    
    .upcoming-id { font-weight:700; font-size:11px; font-family:monospace; opacity:.85; }
    .upcoming-name { font-weight:500; opacity:.9; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
    .upcoming-type { 
      font-size:10px; 
      opacity:.7; 
      text-transform:uppercase; 
      letter-spacing:.5px; 
      font-weight:600;
    }
    .upcoming-date { 
      font-weight:600; 
      font-size:11px;
      text-align:right;
    }
    .upcoming-date.overdue { color:#fca5a5; }
    .upcoming-date.soon { color:#fcd34d; }
    .upcoming-date.normal { color:#6ee7b7; }
    html.theme-light .upcoming-date.overdue, html[data-theme='light'] .upcoming-date.overdue { color:#dc2626; }
    html.theme-light .upcoming-date.soon, html[data-theme='light'] .upcoming-date.soon { color:#d97706; }
    html.theme-light .upcoming-date.normal, html[data-theme='light'] .upcoming-date.normal { color:#059669; }
    
    .upcoming-empty, .recent-logs-empty {
      padding:32px;
      text-align:center;
      opacity:.65;
      font-size:13px;
    }

    .log-id {
      font-weight:400;
      font-size:13px;
      font-family:'Segoe UI', -apple-system, BlinkMacSystemFont, system-ui, sans-serif;
      opacity:.85;
      white-space:nowrap;
      overflow:hidden;
      text-overflow:ellipsis;
      cursor:help;
    }
    .log-date {
      font-weight:400;
      font-size:12px;
      font-family:'Segoe UI', -apple-system, BlinkMacSystemFont, system-ui, sans-serif;
      opacity:.8;
      white-space:nowrap;
      cursor:help;
    }
    .log-status {
      font-weight:400;
      font-size:10px;
      font-family:'Segoe UI', -apple-system, BlinkMacSystemFont, system-ui, sans-serif;
      text-align:center;
      padding:5px 8px;
      border-radius:6px;
      display:block;
      width:100%;
      text-transform:capitalize;
      white-space:nowrap;
      cursor:help;
    }
    .log-status.completed {
      background:rgba(16,185,129,.12);
      color:#6ee7b7;
      border:1px solid rgba(16,185,129,.25);
    }
    .log-status.pending {
      background:rgba(245,158,11,.12);
      color:#fcd34d;
      border:1px solid rgba(245,158,11,.25);
    }
    .log-status.cancelled {
      background:rgba(107,114,128,.12);
      color:#9ca3af;
      border:1px solid rgba(107,114,128,.25);
    }
    html.theme-light .log-status.completed, html[data-theme='light'] .log-status.completed {
      background:rgba(16,185,129,.1);
      color:#059669;
      border-color:rgba(16,185,129,.3);
    }
    html.theme-light .log-status.pending, html[data-theme='light'] .log-status.pending {
      background:rgba(245,158,11,.1);
      color:#d97706;
      border-color:rgba(245,158,11,.3);
    }
    html.theme-light .log-status.cancelled, html[data-theme='light'] .log-status.cancelled {
      background:rgba(107,114,128,.1);
      color:#6b7280;
      border-color:rgba(107,114,128,.3);
    }
    .log-result {
      font-weight:500;
      font-size:10px;
      font-family:'Segoe UI', -apple-system, BlinkMacSystemFont, system-ui, sans-serif;
      text-align:center;
      padding:5px 8px;
      border-radius:6px;
      display:block;
      width:100%;
      text-transform:uppercase;
      letter-spacing:0.3px;
      white-space:nowrap;
      cursor:help;
    }
    .log-result.pass {
      background:rgba(16,185,129,.15);
      color:#6ee7b7;
      border:1px solid rgba(16,185,129,.3);
    }
    .log-result.oot {
      background:rgba(239,68,68,.15);
      color:#fca5a5;
      border:1px solid rgba(239,68,68,.3);
    }
    .log-result.other {
      background:rgba(245,158,11,.15);
      color:#fcd34d;
      border:1px solid rgba(245,158,11,.3);
    }
    html.theme-light .log-result.pass, html[data-theme='light'] .log-result.pass {
      background:rgba(16,185,129,.1);
      color:#059669;
      border-color:rgba(16,185,129,.3);
    }
    html.theme-light .log-result.oot, html[data-theme='light'] .log-result.oot {
      background:rgba(239,68,68,.1);
      color:#dc2626;
      border-color:rgba(239,68,68,.3);
    }
    html.theme-light .log-result.other, html[data-theme='light'] .log-result.other {
      background:rgba(245,158,11,.1);
      color:#d97706;
      border-color:rgba(245,158,11,.3);
    }
    .log-ontime {
      font-size:11px;
      font-family:'Segoe UI', -apple-system, BlinkMacSystemFont, system-ui, sans-serif;
      text-align:center;
      font-weight:400;
      display:flex;
      align-items:center;
      justify-content:center;
      cursor:help;
    }
    .log-ontime .toggle-indicator {
      display:inline-block;
      width:36px;
      height:20px;
      background:rgba(107,114,128,.3);
      border-radius:12px;
      position:relative;
      transition:all .2s ease;
      flex-shrink:0;
    }
    .log-ontime .toggle-indicator::after {
      content:'';
      position:absolute;
      width:16px;
      height:16px;
      background:#ffffff;
      border-radius:50%;
      top:2px;
      left:2px;
      transition:all .2s ease;
      box-shadow:0 2px 4px rgba(0,0,0,.2);
    }
    .log-ontime.on .toggle-indicator {
      background:rgba(16,185,129,.6);
    }
    .log-ontime.on .toggle-indicator::after {
      left:18px;
    }
    html.theme-light .log-ontime .toggle-indicator,
    html[data-theme='light'] .log-ontime .toggle-indicator {
      background:rgba(107,114,128,.25);
    }
    html.theme-light .log-ontime.on .toggle-indicator,
    html[data-theme='light'] .log-ontime.on .toggle-indicator {
      background:rgba(16,185,129,.5);
    }
    html.theme-light .log-ontime .toggle-indicator::after,
    html[data-theme='light'] .log-ontime .toggle-indicator::after {
      background:#ffffff;
    }

    /* Custom scrollbar */
    .upcoming-items::-webkit-scrollbar, .recent-logs-items::-webkit-scrollbar { width:6px; }
    .upcoming-items::-webkit-scrollbar-track, .recent-logs-items::-webkit-scrollbar-track { background:transparent; }
    .upcoming-items::-webkit-scrollbar-thumb, .recent-logs-items::-webkit-scrollbar-thumb { 
      background:rgba(255,255,255,.12); 
      border-radius:3px; 
    }
    .upcoming-items::-webkit-scrollbar-thumb:hover, .recent-logs-items::-webkit-scrollbar-thumb:hover { background:rgba(255,255,255,.20); }
    html.theme-light .upcoming-items::-webkit-scrollbar-thumb, 
    html[data-theme='light'] .upcoming-items::-webkit-scrollbar-thumb,
    html.theme-light .recent-logs-items::-webkit-scrollbar-thumb,
    html[data-theme='light'] .recent-logs-items::-webkit-scrollbar-thumb { 
      background:rgba(0,0,0,.12); 
    }
    html.theme-light .upcoming-items::-webkit-scrollbar-thumb:hover,
    html[data-theme='light'] .upcoming-items::-webkit-scrollbar-thumb:hover,
    html.theme-light .recent-logs-items::-webkit-scrollbar-thumb:hover,
    html[data-theme='light'] .recent-logs-items::-webkit-scrollbar-thumb:hover { 
      background:rgba(0,0,0,.20); 
    }
    
    /* Main column scrollbar */
    .dash-col::-webkit-scrollbar { width:8px; }
    .dash-col::-webkit-scrollbar-track { background:transparent; }
    .dash-col::-webkit-scrollbar-thumb { 
      background:rgba(255,255,255,.12); 
      border-radius:4px; 
    }
    .dash-col::-webkit-scrollbar-thumb:hover { background:rgba(255,255,255,.20); }
    html.theme-light .dash-col::-webkit-scrollbar-thumb,
    html[data-theme='light'] .dash-col::-webkit-scrollbar-thumb { 
      background:rgba(0,0,0,.12); 
    }
    html.theme-light .dash-col::-webkit-scrollbar-thumb:hover,
    html[data-theme='light'] .dash-col::-webkit-scrollbar-thumb:hover { 
      background:rgba(0,0,0,.20); 
    }

    /* GridView Table Styling */
    .modern-table {
      width: 100%;
      border-collapse: collapse;
      font-family: 'Segoe UI', sans-serif;
      font-size: 11px;
    }

    .modern-table td {
      border: 1px solid #e5e7eb;
      padding: 10px 12px;
      vertical-align: middle;
      text-align: center;
    }
    
    .table-cell-padding {
      padding-left: 12px !important;
    }
    
    .table-cell-padding-lr {
      padding-left: 12px !important;
      padding-right: 12px !important;
    }

    /* Table row theme support */
    .table-row-light {
      background-color: white;
      color: #1e293b;
    }
    
    html.theme-dark .table-row-light, html[data-theme='dark'] .table-row-light {
      background-color: transparent;
      color: var(--text-primary);
    }
    
    .table-row-alt {
      background-color: #f8fafc;
    }
    
    html.theme-dark .table-row-alt, html[data-theme='dark'] .table-row-alt {
      background-color: rgba(255,255,255,.02);
    }

    html.theme-light .modern-table td,
    html[data-theme='light'] .modern-table td {
      border-color: #e5e7eb;
    }
    
    html.theme-dark .modern-table td, html[data-theme='dark'] .modern-table td {
      border-color: rgba(255,255,255,.08);
    }

    .modern-table th {
      border: 1px solid #2563eb;
      padding: 12px;
      text-align: center;
    }

    .modern-table tr:hover td {
      background-color: #f1f5f9 !important;
    }
    
    html.theme-dark .modern-table tr:hover td, html[data-theme='dark'] .modern-table tr:hover td {
      background-color: rgba(255,255,255,.05) !important;
    }

    /* iOS-style Toggle Switches (PMDashboard style) */
    .completion-status {
      display: flex;
      align-items: center;
      justify-content: center;
      width: 100%;
    }
    
    .completion-status .toggle-indicator {
      width: 36px;
      height: 20px;
      background: rgba(239,68,68,.3);
      border-radius: 10px;
      position: relative;
      transition: all .2s ease;
      display: flex;
      align-items: center;
    }
    
    .completion-status .toggle-indicator::after {
      content: '';
      width: 16px;
      height: 16px;
      background: #ffffff;
      border-radius: 50%;
      position: absolute;
      left: 2px;
      transition: all .2s ease;
      box-shadow: 0 2px 4px rgba(0,0,0,.2);
    }
    
    .completion-status.on .toggle-indicator {
      background: rgba(16,185,129,.6);
    }
    
    .completion-status.on .toggle-indicator::after {
      left: 18px;
    }
    
    html.theme-light .completion-status .toggle-indicator,
    html[data-theme='light'] .completion-status .toggle-indicator {
      background: rgba(239,68,68,.25);
    }
    
    html.theme-light .completion-status.on .toggle-indicator,
    html[data-theme='light'] .completion-status.on .toggle-indicator {
      background: rgba(16,185,129,.5);
    }

    /* Calibration Status Badge Styles */
    .cal-status-badge {
      display: inline-block;
      padding: 4px 10px;
      border-radius: 4px;
      font-size: 10px;
      font-weight: 600;
      text-transform: uppercase;
      letter-spacing: 0.3px;
      font-family: 'Segoe UI', sans-serif;
    }
    
    .cal-status-badge.status-overdue {
      background-color: #fee2e2;
      color: #dc2626;
      border: 1px solid #fecaca;
    }
    
    html.theme-dark .cal-status-badge.status-overdue, html[data-theme='dark'] .cal-status-badge.status-overdue {
      background-color: rgba(220, 38, 38, 0.15);
      color: #fca5a5;
      border: 1px solid rgba(254, 202, 202, 0.2);
    }
    
    .cal-status-badge.status-due-soon {
      background-color: #fef3c7;
      color: #d97706;
      border: 1px solid #fde68a;
    }
    
    html.theme-dark .cal-status-badge.status-due-soon, html[data-theme='dark'] .cal-status-badge.status-due-soon {
      background-color: rgba(217, 119, 6, 0.15);
      color: #fcd34d;
      border: 1px solid rgba(253, 230, 138, 0.2);
    }

    /* Table Section Headers */
    .table-section {
      margin-bottom: 20px;
    }

    .table-header {
      margin-bottom: 12px;
    }

    .table-title {
      font-size: 16px;
      font-weight: 600;
      color: #e2e8f0;
      margin: 0;
    }

    html.theme-light .table-title,
    html[data-theme='light'] .table-title {
      color: #1b222b;
    }

    /* Sankey Section */
    .sankey-section {
      margin-bottom: 20px;
    }

    .sankey-header {
      margin-bottom: 12px;
    }

    .sankey-title {
      font-size: 16px;
      font-weight: 600;
      color: #e2e8f0;
      margin: 0 0 4px 0;
    }

    .sankey-subtitle {
      font-size: 12px;
      color: rgba(255, 255, 255, 0.6);
      margin: 0;
    }

    html.theme-light .sankey-title,
    html[data-theme='light'] .sankey-title {
      color: #1b222b;
    }

    html.theme-light .sankey-subtitle,
    html[data-theme='light'] .sankey-subtitle {
      color: rgba(0, 0, 0, 0.6);
    }

    .sankey-container {
      background: rgba(25, 29, 37, 0.4);
      border: 1px solid rgba(255, 255, 255, 0.08);
      border-radius: 12px;
      padding: 20px;
      min-height: 400px;
    }

    html.theme-light .sankey-container,
    html[data-theme='light'] .sankey-container {
      background: rgba(255, 255, 255, 0.7);
      border: 1px solid rgba(0, 0, 0, 0.08);
    }

    /* Clickable KPI cards */
    .kpi-card.clickable { cursor: pointer; transition: transform 0.2s ease, box-shadow 0.2s ease; }
    .kpi-card.clickable:hover { 
      transform: translateY(-2px); 
      box-shadow: 0 12px 32px -8px rgba(0,0,0,.5); 
    }
    html.theme-light .kpi-card.clickable:hover, html[data-theme='light'] .kpi-card.clickable:hover { 
      box-shadow: 0 8px 24px -6px rgba(0,0,0,.25); 
    }
    
    /* NAVIGATION CONFIRMATION MODAL */
    .nav-modal-overlay {
      position: fixed;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      background: rgba(0, 0, 0, 0.7);
      backdrop-filter: blur(8px);
      display: flex;
      align-items: center;
      justify-content: center;
      z-index: 10000;
      opacity: 0;
      pointer-events: none;
      transition: opacity 0.25s ease;
    }
    .nav-modal-overlay.show {
      opacity: 1;
      pointer-events: all;
    }
    .nav-modal {
      background: linear-gradient(145deg, #1a1f2e, #0f1419);
      border: 1px solid rgba(255,255,255,0.12);
      border-radius: 20px;
      box-shadow: 0 20px 60px -10px rgba(0,0,0,0.6), 0 0 0 1px rgba(255,255,255,0.05);
      padding: 32px;
      max-width: 480px;
      width: 90%;
      transform: scale(0.9);
      transition: transform 0.25s ease;
    }
    .nav-modal-overlay.show .nav-modal {
      transform: scale(1);
    }
    html.theme-light .nav-modal, html[data-theme='light'] .nav-modal {
      background: #ffffff;
      border: 1px solid rgba(0,0,0,0.12);
      box-shadow: 0 20px 60px -10px rgba(0,0,0,0.25);
    }
    .nav-modal-icon {
      width: 56px;
      height: 56px;
      margin: 0 auto 20px;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      background: rgba(77,141,255,0.15);
      border: 2px solid rgba(77,141,255,0.3);
    }
    .nav-modal-icon svg {
      width: 28px;
      height: 28px;
      color: #60a5fa;
    }
    html.theme-light .nav-modal-icon, html[data-theme='light'] .nav-modal-icon {
      background: rgba(37,99,235,0.1);
      border-color: rgba(37,99,235,0.2);
    }
    html.theme-light .nav-modal-icon svg, html[data-theme='light'] .nav-modal-icon svg {
      color: #2563eb;
    }
    .nav-modal-title {
      font-size: 20px;
      font-weight: 700;
      text-align: center;
      margin: 0 0 12px;
      color: #e5e7eb;
    }
    html.theme-light .nav-modal-title, html[data-theme='light'] .nav-modal-title {
      color: #1f2937;
    }
    .nav-modal-message {
      font-size: 14px;
      text-align: center;
      color: rgba(255,255,255,0.7);
      margin: 0 0 28px;
      line-height: 1.6;
    }
    html.theme-light .nav-modal-message, html[data-theme='light'] .nav-modal-message {
      color: #6b7280;
    }
    .nav-modal-actions {
      display: flex;
      gap: 12px;
      justify-content: center;
    }
    .nav-modal-btn {
      padding: 12px 28px;
      border-radius: 12px;
      border: none;
      font-size: 14px;
      font-weight: 600;
      cursor: pointer;
      transition: all 0.2s ease;
      font-family: 'Segoe UI', system-ui, sans-serif;
    }
    .nav-modal-btn-cancel {
      background: rgba(255,255,255,0.08);
      color: #e5e7eb;
      border: 1px solid rgba(255,255,255,0.15);
    }
    .nav-modal-btn-cancel:hover {
      background: rgba(255,255,255,0.12);
      transform: translateY(-1px);
    }
    html.theme-light .nav-modal-btn-cancel, html[data-theme='light'] .nav-modal-btn-cancel {
      background: #f3f4f6;
      color: #374151;
      border: 1px solid #d1d5db;
    }
    html.theme-light .nav-modal-btn-cancel:hover, html[data-theme='light'] .nav-modal-btn-cancel:hover {
      background: #e5e7eb;
    }
    .nav-modal-btn-confirm {
      background: linear-gradient(135deg, #3b82f6, #2563eb);
      color: #ffffff;
      border: 1px solid rgba(255,255,255,0.2);
      box-shadow: 0 4px 12px rgba(59,130,246,0.4);
    }
    .nav-modal-btn-confirm:hover {
      background: linear-gradient(135deg, #2563eb, #1d4ed8);
      transform: translateY(-1px);
      box-shadow: 0 6px 16px rgba(59,130,246,0.5);
    }


  </style>
</asp:Content>
<asp:Content ID="CalDashMain" ContentPlaceHolderID="MainContent" runat="server">
  <div class="dash-shell">
    <!-- SIDEBAR -->
    <aside class="dash-sidebar" role="navigation" aria-label="Sidebar">
      <div class="sidebar-user">
        <asp:Image ID="imgAvatar" runat="server" CssClass="avatar" AlternateText="User avatar" Visible="false" />
        <div class="avatar" id="avatarFallback" runat="server"><asp:Literal ID="litInitials" runat="server" /></div>
        <div class="user-meta">
          <strong><asp:Literal ID="litFullName" runat="server" /></strong>
          <span><asp:Literal ID="litRole" runat="server" /></span>
        </div>
      </div>
      <nav class="nav">
        <ul class="nav-list">
          <li><a class="nav-link" href="Dashboard.aspx"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M3 13h8V3H3v10zM13 21h8V11h-8v10z"/><path d="M3 21h8v-6H3v6zM13 3v6h8V3h-8z"/></svg><span>Dashboard</span></a></li>
          <li><a class="nav-link" href="Analytics.aspx"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M3 3v18h18"/><path d="M7 17l4-6 3 3 4-7"/></svg><span>Analytics</span></a></li>
        </ul>
        <div class="nav-title">Test Engineering</div>
        <ul class="nav-list">
          <li><a class="nav-link" href="EquipmentInventoryDashboard.aspx"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M3 10l9-6 9 6"/><path d="M5 10v10h14V10"/><path d="M9 20v-6h6v6"/></svg><span>Equipment Inventory</span></a></li>
          <li><a class="nav-link active" href="CalibrationDashboard.aspx"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><line x1="4" y1="21" x2="4" y2="14"/><line x1="4" y1="10" x2="4" y2="3"/><line x1="12" y1="21" x2="12" y2="12"/><line x1="12" y1="8" x2="12" y2="3"/><line x1="20" y1="21" x2="20" y2="16"/><line x1="20" y1="12" x2="20" y2="3"/><line x1="1" y1="14" x2="7" y2="14"/><line x1="9" y1="8" x2="15" y2="8"/><line x1="17" y1="16" x2="23" y2="16"/></svg><span>Calibration</span></a></li>
          <li><a class="nav-link" href="PMDashboard.aspx"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/><path d="M9 16l2 2 4-4"/></svg><span>Preventive Maintenance</span></a></li>
          <li><a class="nav-link" href="TroubleshootingDashboard.aspx"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><path d="M9.5 9a3 3 0 1 1 5 2c-.8.6-1.5 1-1.5 2"/><circle cx="12" cy="17" r="1"/></svg><span>Troubleshooting</span></a></li>
          <li><a class="nav-link disabled" href="javascript:void(0)"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><path d="M14 2v6h6"/><path d="M9 15h6"/><path d="M12 18v-6"/></svg><span>Test Certificates</span></a></li>
          <li><a class="nav-link disabled" href="javascript:void(0)"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="7" width="20" height="14" rx="2"/><path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"/></svg><span>Test Stations</span></a></li>
          <li><a class="nav-link disabled" href="javascript:void(0)"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M3 3v18h18"/><path d="M18 17V9"/><path d="M13 17V5"/><path d="M8 17v-3"/></svg><span>Metrics</span></a></li>
        </ul>
        <div class="nav-title">Quality</div>
        <ul class="nav-list">
          <li><a class="nav-link disabled" href="javascript:void(0)"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M22 12h-4l-3 9L9 3l-3 9H2"/></svg><span>First Pass Yield</span></a></li>
          <li><a class="nav-link disabled" href="javascript:void(0)"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M3 3v18h18"/><path d="M13 17l5-5-5-5"/><path d="M8 12h10"/></svg><span>Test Yield</span></a></li>
          <li><a class="nav-link disabled" href="javascript:void(0)"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg><span>Device Test History</span></a></li>
          <li><a class="nav-link disabled" href="javascript:void(0)"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg><span>Failure Report</span></a></li>
          <li><a class="nav-link disabled" href="javascript:void(0)"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"/><polyline points="7.5 4.21 12 6.81 16.5 4.21"/><polyline points="7.5 19.79 7.5 14.6 3 12"/><polyline points="21 12 16.5 14.6 16.5 19.79"/><polyline points="3.27 6.96 12 12.01 20.73 6.96"/><line x1="12" y1="22.08" x2="12" y2="12"/></svg><span>Quality Analytics</span></a></li>
        </ul>
        <div class="nav-title">Other</div>
        <ul class="nav-list">
          <li><a class="nav-link" href="Settings.aspx"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="3"/><path d="M12 1v6m0 6v6m9-9h-6m-6 0H3"/><path d="M19.07 4.93l-4.24 4.24m-5.66 0L4.93 4.93m14.14 14.14l-4.24-4.24m-5.66 0l-4.24 4.24"/></svg><span>Settings</span></a></li>
          <li><a class="nav-link disabled" href="javascript:void(0)"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/><path d="M8 10h.01M12 10h.01M16 10h.01"/></svg><span>Help / Feedback</span></a></li>
          <li><asp:HyperLink ID="lnkAdminPortal" runat="server" CssClass="nav-link" NavigateUrl="~/Admin/Requests.aspx"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="8" r="3"/><path d="M4 20a8 8 0 0 1 16 0"/></svg><span>Admin portal</span></asp:HyperLink></li>
          <li><a class="nav-link danger" href="<%= ResolveUrl("~/Account/Logout.aspx") %>"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><path d="M16 17l5-5-5-5"/><path d="M21 12H9"/></svg><span>Logout</span></a></li>
        </ul>
      </nav>
    </aside>

    <!-- MAIN CONTENT -->
    <section class="dash-col">
      <!-- Page Header -->
      <div class="page-header">
        <div>
          <h1 class="page-title">Calibration Dashboard</h1>
          <p class="page-subtitle">Real-time insights and upcoming calibrations</p>
        </div>
        <div class="header-actions">
          <!-- Grid View Button (Purple) -->
          <button type="button" class="btn-icon btn-icon-accent" title="Grid View"
                  onclick="window.open('CalibrationGridView.aspx?collapse=true', '_blank'); return false;">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round">
              <rect x="3" y="3" width="7" height="7"></rect>
              <rect x="14" y="3" width="7" height="7"></rect>
              <rect x="14" y="14" width="7" height="7"></rect>
              <rect x="3" y="14" width="7" height="7"></rect>
            </svg>
          </button>

          <!-- Calendar View Button (Brown) - Disabled -->
          <button type="button" class="btn-icon btn-icon-brown" title="Calendar View" disabled
                  style="opacity: 0.5; cursor: not-allowed;">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round">
              <rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect>
              <line x1="16" y1="2" x2="16" y2="6"></line>
              <line x1="8" y1="2" x2="8" y2="6"></line>
              <line x1="3" y1="10" x2="21" y2="10"></line>
            </svg>
          </button>
          
          <!-- View Details Button (Amber) -->
          <button type="button" class="btn-icon btn-icon-amber" title="View Details"
                  onclick="navigateToCalibrationDetails(); return false;">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round">
              <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
              <circle cx="12" cy="12" r="3"></circle>
            </svg>
          </button>

          <!-- Add New Calibration Button (Blue) -->
          <button type="button" class="btn-icon btn-icon-primary" title="New Calibration"
                  onclick="window.location='CalibrationDetails.aspx?mode=new'; return false;">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round">
              <line x1="12" y1="5" x2="12" y2="19"></line>
              <line x1="5" y1="12" x2="19" y2="12"></line>
            </svg>
          </button>
        </div>
      </div>

      <!-- KPI CARDS -->
      <div class="kpi-grid">
        <!-- COMPLETED CALIBRATIONS - Hybrid with mini-line chart -->
        <div class="kpi-card status-blue" id="cardCompletedCals" runat="server">
          <div class="kpi-label">Completed Calibrations</div>
          <div style="display: flex; align-items: center; justify-content: space-between; margin-top: 4px; height: 60px;">
            <div class="kpi-value" style="margin-bottom: 0;"><asp:Literal ID="litCompletedCals" runat="server" Text="0" /></div>
            <div style="width: 150px; height: 60px; margin-right: -8px;">
              <canvas id="miniLineCompletedCals"></canvas>
            </div>
          </div>
          <div class="kpi-footer" style="margin-top: 8px;">
            <span>Last 12 months | Monthly trend</span>
          </div>
        </div>
        
        <!-- DUE CALIBRATIONS - Combined Overdue + Due Soon with bullet chart -->
        <div class="kpi-card status-red" id="cardDueCals" runat="server">
          <div class="kpi-label">Due Calibrations</div>
          <div style="display: flex; align-items: center; justify-content: space-between; margin-top: 4px; height: 60px;">
            <div class="kpi-value" style="margin-bottom: 0;"><asp:Literal ID="litDueCals" runat="server" Text="0" /></div>
            <div style="width: 120px; height: 40px; margin-right: -4px;">
              <canvas id="bulletChartDueCals"></canvas>
            </div>
          </div>
          <div class="kpi-footer" style="margin-top: 8px;">
            <asp:Literal ID="litOverdueText" runat="server" Text="0 overdue" />
          </div>
        </div>
        
        <!-- ON-TIME CALIBRATION RATE - Gauge chart -->
        <div class="kpi-card status-green" id="cardOnTime" runat="server">
          <div class="kpi-label">On-Time Calibration Rate</div>
          <div style="display: flex; align-items: center; justify-content: space-between; margin-top: 4px; height: 60px;">
            <div class="kpi-value" style="margin-bottom: 0;"><asp:Literal ID="litOnTimeRate" runat="server" Text="--%" /></div>
            <div style="width: 75px; height: 60px; position: relative; margin-right: -4px;">
              <canvas id="gaugeOnTime"></canvas>
            </div>
          </div>
          <div class="kpi-footer" style="margin-top: 8px;">
            <span><asp:Literal ID="litOnTimeCount" runat="server" Text="0 of 0" /> | Target: &gt;95%</span>
          </div>
        </div>
        
        <!-- OUT OF TOLERANCE - Gauge chart -->
        <div class="kpi-card status-amber" id="cardOOT" runat="server">
          <div class="kpi-label">Out of Tolerance</div>
          <div style="display: flex; align-items: center; justify-content: space-between; margin-top: 4px; height: 60px;">
            <div class="kpi-value" style="margin-bottom: 0;"><asp:Literal ID="litOOTRate" runat="server" Text="--%" /></div>
            <div style="width: 75px; height: 60px; position: relative; margin-right: -4px;">
              <canvas id="gaugeOOT"></canvas>
            </div>
          </div>
          <div class="kpi-footer" style="margin-top: 8px;">
            <span><asp:Literal ID="litOOTCount" runat="server" Text="0 of 0" /> | Target: &lt;5%</span>
          </div>
        </div>
        
        <!-- AVG TURNAROUND DAYS - Hybrid with mini-line chart -->
        <div class="kpi-card status-blue">
          <div class="kpi-label">Avg Turnaround Days</div>
          <div style="display: flex; align-items: center; justify-content: space-between; margin-top: 4px; height: 60px;">
            <div class="kpi-value" style="margin-bottom: 0;"><asp:Literal ID="litAvgTurnaround" runat="server" Text="--" /></div>
            <div id="turnaroundChartContainer" style="width: 150px; height: 60px; margin-right: -8px;">
              <canvas id="miniLineTurnaround"></canvas>
            </div>
          </div>
          <div class="kpi-footer" style="margin-top: 8px;">
            <span id="turnaroundFooter">Last 10 calibrations | Target: &lt;14d</span>
          </div>
        </div>
      </div>

      <!-- UPCOMING CALIBRATIONS TABLE -->
      <div class="chart-card" style="margin-bottom: 24px;">
        <div class="chart-title">Upcoming Calibrations (Next 30 Days)</div>
        <div style="overflow-x: auto; margin-top: 15px;">
          <asp:GridView ID="gvUpcomingCals" runat="server" CssClass="modern-table" AutoGenerateColumns="False" 
                        GridLines="Both" BorderStyle="None" BorderWidth="0" CellPadding="0" CellSpacing="0"
                        OnRowDataBound="gvUpcomingCals_RowDataBound">
            <HeaderStyle BackColor="#2563eb" ForeColor="White" Font-Bold="True" Font-Size="11px" Height="40px" VerticalAlign="Middle" HorizontalAlign="Center" Font-Names="'Segoe UI', sans-serif" />
            <RowStyle CssClass="table-row-light" Font-Size="11px" Height="36px" VerticalAlign="Middle" Font-Names="'Segoe UI', sans-serif" />
            <AlternatingRowStyle CssClass="table-row-alt" />
            <Columns>
              <asp:BoundField DataField="EquipmentEatonID" HeaderText="Eaton ID" ItemStyle-Width="140px" ItemStyle-CssClass="table-cell-padding" HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center" />
              <asp:BoundField DataField="EquipmentName" HeaderText="Equipment Name" ItemStyle-Width="200px" ItemStyle-CssClass="table-cell-padding-lr" HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Left" />
              <asp:BoundField DataField="Location" HeaderText="Location" ItemStyle-Width="180px" ItemStyle-CssClass="table-cell-padding" HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center" />
              <asp:BoundField DataField="LastCalibration" HeaderText="Last Calibration" DataFormatString="{0:MM/dd/yyyy}" ItemStyle-Width="120px" ItemStyle-CssClass="table-cell-padding" HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center" />
              <asp:TemplateField HeaderText="Status" ItemStyle-Width="140px" HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center" ItemStyle-CssClass="table-cell-padding">
                <ItemTemplate>
                  <span class='cal-status-badge status-<%# Eval("CalibrationStatus").ToString().ToLower().Replace(" ", "-") %>'>
                    <%# Eval("CalibrationStatus") %>
                  </span>
                </ItemTemplate>
              </asp:TemplateField>
              <asp:BoundField DataField="NextCalibration" HeaderText="Next Due" DataFormatString="{0:MM/dd/yyyy}" ItemStyle-Width="120px" ItemStyle-CssClass="table-cell-padding" HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center" />
            </Columns>
            <EmptyDataTemplate>
              <div style="padding: 40px; text-align: center; color: #6b7280; font-size: 13px;">
                <p style="margin: 0;">No upcoming calibrations in the next 30 days.</p>
              </div>
            </EmptyDataTemplate>
          </asp:GridView>
        </div>
      </div>

      <!-- SANKEY DIAGRAM SECTION -->
      <div class="chart-card" style="margin-bottom: 24px;">
        <h3 class="chart-title">
          <strong>Calibration Flow Analysis:</strong> 
          <span style="font-weight: 400;">
            Total Equipment &rarr; Device Type &rarr; Calibration Status &rarr; Results
          </span>
        </h3>
        <div class="chart-container" style="height: 500px;">
          <svg id="sankeyCalibration" style="width: 100%; height: 100%;"></svg>
        </div>
      </div>

      <!-- RECENT CALIBRATION LOGS TABLE -->
      <div class="chart-card" style="margin-bottom: 24px;">
        <div class="chart-title">Recent Calibration Logs</div>
        <div style="overflow-x: auto; margin-top: 15px;">
          <asp:GridView ID="gvRecentLogs" runat="server" CssClass="modern-table" AutoGenerateColumns="False" 
                        GridLines="Both" BorderStyle="None" BorderWidth="0" CellPadding="0" CellSpacing="0"
                        OnRowDataBound="gvRecentLogs_RowDataBound">
            <HeaderStyle BackColor="#2563eb" ForeColor="White" Font-Bold="True" Font-Size="11px" Height="40px" VerticalAlign="Middle" HorizontalAlign="Center" Font-Names="'Segoe UI', sans-serif" />
            <RowStyle CssClass="table-row-light" Font-Size="11px" Height="36px" VerticalAlign="Middle" Font-Names="'Segoe UI', sans-serif" />
            <AlternatingRowStyle CssClass="table-row-alt" />
            <Columns>
              <asp:BoundField DataField="CalibrationLogID" HeaderText="Log ID" ItemStyle-Width="80px" ItemStyle-CssClass="table-cell-padding" HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center" />
              <asp:BoundField DataField="EquipmentName" HeaderText="Equipment" ItemStyle-Width="200px" ItemStyle-CssClass="table-cell-padding-lr" HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Left" />
              <asp:BoundField DataField="Method" HeaderText="Method" ItemStyle-Width="120px" ItemStyle-CssClass="table-cell-padding" HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center" />
              <asp:BoundField DataField="CalibrationDate" HeaderText="Date" DataFormatString="{0:MM/dd/yyyy}" ItemStyle-Width="100px" ItemStyle-CssClass="table-cell-padding" HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center" />
              <asp:BoundField DataField="CalibrationBy" HeaderText="Calibrated By" ItemStyle-Width="140px" ItemStyle-CssClass="table-cell-padding" HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center" />
              <asp:BoundField DataField="ResultCode" HeaderText="Result" ItemStyle-Width="100px" ItemStyle-CssClass="table-cell-padding" HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center" />
              <asp:BoundField DataField="Cost" HeaderText="Cost" DataFormatString="${0:N2}" ItemStyle-Width="100px" ItemStyle-CssClass="table-cell-padding" HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center" />
              <asp:TemplateField HeaderText="On Time" ItemStyle-Width="80px" HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center" ItemStyle-CssClass="table-cell-padding">
                <ItemTemplate>
                  <div class='completion-status <%# Convert.ToBoolean(Eval("IsOnTime")) ? "on" : "off" %>' 
                       title='<%# Convert.ToBoolean(Eval("IsOnTime")) ? "On Time" : "Late" %>'>
                    <span class="toggle-indicator"></span>
                  </div>
                </ItemTemplate>
              </asp:TemplateField>
              <asp:TemplateField HeaderText="Tolerance Result" ItemStyle-Width="120px" HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center" ItemStyle-CssClass="table-cell-padding">
                <ItemTemplate>
                  <div class='completion-status <%# Convert.ToBoolean(Eval("IsOutOfTolerance")) ? "off" : "on" %>' 
                       title='<%# Convert.ToBoolean(Eval("IsOutOfTolerance")) ? "Out of Tolerance" : "Within Tolerance" %>'>
                    <span class="toggle-indicator"></span>
                  </div>
                </ItemTemplate>
              </asp:TemplateField>
            </Columns>
            <EmptyDataTemplate>
              <div style="padding: 40px; text-align: center; color: #6b7280; font-size: 13px;">
                <p style="margin: 0;">No calibration logs found.</p>
              </div>
            </EmptyDataTemplate>
        </asp:GridView>
      </section>
    </section>
  </div>

  <!-- Chart.js Configuration -->
  <script type="text/javascript">
    // Navigation function for View Details button
    function navigateToCalibrationDetails() {
      const latestCalID = <%= LatestCalibrationID %>;
      console.log('Latest Calibration ID:', latestCalID);
      
      if (latestCalID > 0) {
        const url = 'CalibrationDetails.aspx?id=' + latestCalID;
        console.log('Navigating to:', url);
        window.location.href = url;
      } else {
        console.log('No calibration logs found, going to new mode');
        window.location.href = 'CalibrationDetails.aspx?mode=new';
      }
    }
    
    // Store chart instances globally
    let chartInstances = {
      gaugeOnTime: null,
      gaugeOOT: null,
      monthly: null,
      turnaround: null
    };

    // Function to get theme-aware colors
    function getThemeColors() {
      const isDark = !document.documentElement.classList.contains('theme-light') && 
                     document.documentElement.getAttribute('data-theme') !== 'light';
      
      return {
        isDark: isDark,
        
        // Primary colors - BRIGHTER in dark mode for visibility
        modernBlue: isDark ? '#60a5fa' : '#2563eb',
        modernGreen: isDark ? '#10b981' : '#059669',
        modernPurple: isDark ? '#c084fc' : '#7c3aed',
        modernOrange: isDark ? '#fb923c' : '#ea580c',
        modernRed: isDark ? '#ef4444' : '#dc2626',
        modernYellow: isDark ? '#fbbf24' : '#d97706',
        modernTeal: isDark ? '#2dd4bf' : '#0d9488',
        modernPink: isDark ? '#f472b6' : '#db2777',
        
        // Chart colors
        primary: isDark ? '#60a5fa' : '#2563eb',
        success: isDark ? '#10b981' : '#059669',
        warning: isDark ? '#fbbf24' : '#d97706',
        danger: isDark ? '#ef4444' : '#dc2626',
        info: isDark ? '#60a5fa' : '#2563eb',
        purple: isDark ? '#c084fc' : '#7c3aed',
        orange: isDark ? '#fb923c' : '#ea580c',
        teal: isDark ? '#2dd4bf' : '#0d9488',
        
        // UI colors - MUCH better contrast
        text: isDark ? '#f1f5f9' : 'rgba(0,0,0,0.8)',
        textSecondary: isDark ? '#cbd5e1' : 'rgba(0,0,0,0.6)',
        grid: isDark ? 'rgba(255,255,255,0.12)' : 'rgba(0,0,0,0.08)',
        border: isDark ? 'rgba(255,255,255,0.18)' : 'rgba(0,0,0,0.12)',
        tooltipBg: isDark ? 'rgba(15,23,42,0.98)' : 'rgba(255,255,255,0.98)',
        tooltipBorder: isDark ? 'rgba(255,255,255,0.2)' : 'rgba(0,0,0,0.15)'
      };
    }

    // Function to create/update all charts
    function initializeCharts() {
      if (typeof Chart === 'undefined') {
        console.error('Chart.js not loaded');
        return;
      }

      const colors = getThemeColors();

      // Update global chart defaults
      Chart.defaults.color = colors.text;
      Chart.defaults.borderColor = colors.grid;
      Chart.defaults.font.family = "'Poppins', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif";
      Chart.defaults.font.size = 11;
      Chart.defaults.plugins.legend.labels.usePointStyle = true;
      Chart.defaults.plugins.legend.labels.padding = 12;
      Chart.defaults.plugins.legend.labels.color = colors.text;

      // Destroy existing charts if they exist
      Object.keys(chartInstances).forEach(key => {
        if (chartInstances[key]) {
          chartInstances[key].destroy();
          chartInstances[key] = null;
        }
      });

      // ===== KPI CARD CHARTS =====
      
      // 1. Mini-line Chart - Completed Calibrations (12 months)
      const ctxMiniLineCompleted = document.getElementById('miniLineCompletedCals');
      if (ctxMiniLineCompleted) {
        const monthlyCalData = <%= String.IsNullOrEmpty(MonthlyCalData) ? "[]" : MonthlyCalData %>;
        const monthlyCalLabels = <%= String.IsNullOrEmpty(MonthlyCalLabels) ? "[]" : MonthlyCalLabels %>;
        
        chartInstances.miniLineCompleted = new Chart(ctxMiniLineCompleted, {
          type: 'line',
          data: {
            labels: monthlyCalLabels,
            datasets: [{
              data: monthlyCalData,
              borderColor: colors.primary,
              backgroundColor: colors.isDark ? 'rgba(96,165,250,0.2)' : 'rgba(37,99,235,0.1)',
              borderWidth: 2,
              fill: true,
              tension: 0.4,
              pointRadius: 0,
              pointHoverRadius: 4,
              pointHoverBackgroundColor: colors.primary,
              pointHoverBorderColor: '#ffffff',
              pointHoverBorderWidth: 2
            }]
          },
          options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
              legend: { display: false },
              tooltip: {
                backgroundColor: colors.tooltipBg,
                titleColor: colors.text,
                bodyColor: colors.text,
                borderColor: colors.tooltipBorder,
                borderWidth: 1,
                padding: 8,
                displayColors: false,
                callbacks: {
                  title: function(context) { return context[0].label; },
                  label: function(context) { return 'Calibrations: ' + context.parsed.y; }
                }
              },
              datalabels: { display: false }
            },
            scales: {
              x: { display: false },
              y: { display: false }
            },
            interaction: {
              intersect: false,
              mode: 'index'
            }
          }
        });
      }

      // 2. Bullet Chart - Due Calibrations (Overdue + Due Soon)
      const ctxBulletDue = document.getElementById('bulletChartDueCals');
      if (ctxBulletDue) {
        const dueCals = <%= DueCals %>;
        const overdueCals = <%= OverdueCals %>;
        const dueSoon = dueCals - overdueCals;
        
        chartInstances.bulletDue = new Chart(ctxBulletDue, {
          type: 'bar',
          data: {
            labels: [''],
            datasets: [
              {
                label: 'Due Soon',
                data: [dueSoon],
                backgroundColor: colors.isDark ? 'rgba(251,146,60,0.15)' : 'rgba(251,146,60,0.2)',
                borderWidth: 0,
                borderRadius: {
                  topLeft: 9,
                  topRight: 9,
                  bottomLeft: 9,
                  bottomRight: 9
                },
                borderSkipped: false,
                barThickness: 18
              },
              {
                label: 'Overdue',
                data: [overdueCals],
                backgroundColor: colors.isDark ? 'rgba(239,68,68,0.9)' : 'rgba(220,38,38,0.9)',
                borderWidth: 0,
                borderRadius: {
                  topLeft: 7,
                  topRight: 7,
                  bottomLeft: 7,
                  bottomRight: 7
                },
                borderSkipped: false,
                barThickness: 14,
                order: -1  // Draw on top
              }
            ]
          },
          options: {
            indexAxis: 'y',
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
              legend: { display: false },
              tooltip: {
                backgroundColor: colors.tooltipBg,
                titleColor: colors.text,
                bodyColor: colors.text,
                borderColor: colors.tooltipBorder,
                borderWidth: 1,
                padding: 8,
                displayColors: false,
                titleFont: { size: 11, weight: '600' },
                bodyFont: { size: 10 },
                callbacks: {
                  title: function() { return 'Due Calibrations'; },
                  label: function(context) {
                    return context.dataset.label + ': ' + context.parsed.x;
                  }
                }
              },
              datalabels: { display: false }
            },
            scales: {
              x: {
                stacked: true,
                display: false
              },
              y: {
                stacked: true,
                display: false
              }
            }
          }
        });
      }

      // 3. Gauge Chart - On-Time Calibration Rate
      const ctxGaugeOnTime = document.getElementById('gaugeOnTime');
      if (ctxGaugeOnTime) {
        const onTimeRate = parseFloat('<%= OnTimeRate ?? "0" %>') || 0;
        const remainingValue = 100 - onTimeRate;
        
        let gaugeColor;
        if (onTimeRate >= 95) {
          gaugeColor = colors.success;
        } else if (onTimeRate >= 90) {
          gaugeColor = colors.warning;
        } else {
          gaugeColor = colors.danger;
        }
        
        chartInstances.gaugeOnTime = new Chart(ctxGaugeOnTime, {
          type: 'doughnut',
          data: {
            datasets: [{
              data: [onTimeRate, remainingValue],
              backgroundColor: [gaugeColor, colors.isDark ? 'rgba(255,255,255,0.05)' : 'rgba(0,0,0,0.05)'],
              borderWidth: 0,
              circumference: 180,
              rotation: 270
            }]
          },
          options: {
            responsive: true,
            maintainAspectRatio: true,
            cutout: '70%',
            plugins: {
              legend: { display: false },
              tooltip: {
                enabled: false,
                external: function(context) {
                  let tooltipEl = document.getElementById('chartjs-tooltip-ontime');
                  
                  if (!tooltipEl) {
                    tooltipEl = document.createElement('div');
                    tooltipEl.id = 'chartjs-tooltip-ontime';
                    tooltipEl.style.position = 'absolute';
                    tooltipEl.style.pointerEvents = 'none';
                    tooltipEl.style.transition = 'all .2s ease';
                    tooltipEl.style.zIndex = '10000';
                    document.body.appendChild(tooltipEl);
                  }
                  
                  const tooltipModel = context.tooltip;
                  if (tooltipModel.opacity === 0) {
                    tooltipEl.style.opacity = 0;
                    return;
                  }
                  
                  if (tooltipModel.body) {
                    const titleLines = ['On-Time Rate'];
                    const bodyLines = [onTimeRate.toFixed(1) + '% (Target: >95%)'];
                    
                    let innerHtml = '<div style="background:' + colors.tooltipBg + ';color:' + colors.text + ';border:1px solid ' + colors.tooltipBorder + ';border-radius:6px;padding:8px 12px;font-size:11px;box-shadow:0 4px 12px rgba(0,0,0,0.3);font-family:\'Segoe UI\', system-ui, sans-serif;">';
                    innerHtml += '<div style="font-weight:600;margin-bottom:4px;">' + titleLines[0] + '</div>';
                    innerHtml += '<div>' + bodyLines[0] + '</div>';
                    innerHtml += '</div>';
                    
                    tooltipEl.innerHTML = innerHtml;
                  }
                  
                  const position = context.chart.canvas.getBoundingClientRect();
                  tooltipEl.style.opacity = 1;
                  tooltipEl.style.left = position.left + window.pageXOffset + 10 + 'px';
                  tooltipEl.style.top = position.top + window.pageYOffset + position.height / 2 + 'px';
                }
              },
              datalabels: { display: false }
            }
          }
        });
      }

      // 4. Gauge Chart - Out of Tolerance
      const ctxGaugeOOT = document.getElementById('gaugeOOT');
      if (ctxGaugeOOT) {
        const ootRate = parseFloat('<%= OOTRate ?? "0" %>') || 0;
        const remainingValue = 100 - ootRate;
        
        let gaugeColor;
        if (ootRate < 1) {
          gaugeColor = colors.success;
        } else if (ootRate < 5) {
          gaugeColor = colors.warning;
        } else {
          gaugeColor = colors.danger;
        }
        
        chartInstances.gaugeOOT = new Chart(ctxGaugeOOT, {
          type: 'doughnut',
          data: {
            datasets: [{
              data: [ootRate, remainingValue],
              backgroundColor: [gaugeColor, colors.isDark ? 'rgba(255,255,255,0.05)' : 'rgba(0,0,0,0.05)'],
              borderWidth: 0,
              circumference: 180,
              rotation: 270
            }]
          },
          options: {
            responsive: true,
            maintainAspectRatio: true,
            cutout: '70%',
            plugins: {
              legend: { display: false },
              tooltip: {
                enabled: false,
                external: function(context) {
                  let tooltipEl = document.getElementById('chartjs-tooltip-oot');
                  
                  if (!tooltipEl) {
                    tooltipEl = document.createElement('div');
                    tooltipEl.id = 'chartjs-tooltip-oot';
                    tooltipEl.style.position = 'absolute';
                    tooltipEl.style.pointerEvents = 'none';
                    tooltipEl.style.transition = 'all .2s ease';
                    tooltipEl.style.zIndex = '10000';
                    document.body.appendChild(tooltipEl);
                  }
                  
                  const tooltipModel = context.tooltip;
                  if (tooltipModel.opacity === 0) {
                    tooltipEl.style.opacity = 0;
                    return;
                  }
                  
                  if (tooltipModel.body) {
                    const titleLines = ['Out of Tolerance'];
                    const bodyLines = [ootRate.toFixed(1) + '% (Target: <5%)'];
                    
                    let innerHtml = '<div style="background:' + colors.tooltipBg + ';color:' + colors.text + ';border:1px solid ' + colors.tooltipBorder + ';border-radius:6px;padding:8px 12px;font-size:10px;box-shadow:0 4px 12px rgba(0,0,0,0.3);font-family:\'Segoe UI\', system-ui, sans-serif;">';
                    innerHtml += '<div style="font-weight:600;margin-bottom:4px;font-size:11px;">' + titleLines[0] + '</div>';
                    innerHtml += '<div>' + bodyLines[0] + '</div>';
                    innerHtml += '</div>';
                    
                    tooltipEl.innerHTML = innerHtml;
                  }
                  
                  const position = context.chart.canvas.getBoundingClientRect();
                  tooltipEl.style.opacity = 1;
                  tooltipEl.style.left = position.left + window.pageXOffset + 10 + 'px';
                  tooltipEl.style.top = position.top + window.pageYOffset + position.height / 2 + 'px';
                }
              },
              datalabels: { display: false }
            }
          }
        });
      }

      // 5. Mini-line Chart - Avg Turnaround Days (Last 10 calibrations)
      const ctxMiniLineTurnaround = document.getElementById('miniLineTurnaround');
      if (ctxMiniLineTurnaround) {
        const turnaroundData = <%= String.IsNullOrEmpty(TurnaroundData) ? "[]" : TurnaroundData %>;
        const turnaroundCalIDs = <%= String.IsNullOrEmpty(TurnaroundCalIDs) ? "[]" : TurnaroundCalIDs %>;
        const avgTurnaround = <%= AvgTurnaroundValue %>;
        console.log('Turnaround Data:', turnaroundData);
        console.log('Turnaround Data Length:', turnaroundData.length);
        console.log('Turnaround Cal IDs:', turnaroundCalIDs);
        
        // Check if we have real data - if array is empty OR all IDs are 0, then no data
        const hasRealData = turnaroundData.length > 0 && 
                           turnaroundCalIDs.length > 0 && 
                           turnaroundCalIDs.some(id => id !== 0 && id !== "0");
        
        console.log('Has Real Data:', hasRealData);
        
        if (!hasRealData) {
          // Hide chart and show message
          const chartContainer = document.getElementById('turnaroundChartContainer');
          const footer = document.getElementById('turnaroundFooter');
          if (chartContainer) chartContainer.style.display = 'none';
          if (footer) footer.textContent = 'No external calibrations found';
        } else {
          const targetLine = Array(turnaroundData.length).fill(14); // Target: 14 days
          
          chartInstances.miniLineTurnaround = new Chart(ctxMiniLineTurnaround, {
          type: 'line',
          data: {
            labels: Array(turnaroundData.length).fill(''),
            datasets: [
              {
                label: 'Turnaround',
                data: turnaroundData,
                borderColor: colors.primary,
                backgroundColor: colors.isDark ? 'rgba(96,165,250,0.2)' : 'rgba(37,99,235,0.1)',
                borderWidth: 2,
                fill: true,
                tension: 0.4,
                pointRadius: 2,
                pointBackgroundColor: colors.primary,
                pointBorderColor: colors.isDark ? 'rgba(15,23,42,1)' : '#ffffff',
                pointBorderWidth: 1.5,
                pointHoverRadius: 4,
                pointHoverBackgroundColor: colors.primary,
                pointHoverBorderColor: '#ffffff',
                pointHoverBorderWidth: 2
              }
            ]
          },
          options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
              legend: { display: false },
              tooltip: {
                enabled: true,
                position: 'nearest',
                xAlign: 'center',
                yAlign: 'bottom',
                backgroundColor: colors.tooltipBg,
                titleColor: colors.text,
                bodyColor: colors.text,
                borderColor: colors.tooltipBorder,
                borderWidth: 1,
                padding: 10,
                displayColors: false,
                titleFont: { size: 11, weight: '600' },
                bodyFont: { size: 10 },
                callbacks: {
                  title: function(context) { 
                    const idx = context[0].dataIndex;
                    return turnaroundCalIDs[idx] !== "0" && turnaroundCalIDs[idx] !== 0 
                      ? turnaroundCalIDs[idx] 
                      : 'No Data';
                  },
                  label: function(context) {
                    return 'Turnaround: ' + context.parsed.y + ' days';
                  },
                  afterLabel: function() {
                    return null;
                  }
                }
              },
              datalabels: { display: false }
            },
            scales: {
              x: { display: false },
              y: { display: false }
            },
            interaction: {
              intersect: false,
              mode: 'index'
            }
          }
        });
        }
      }
    }

    // === Sankey Diagram Initialization ===
    const sankeyData = <%= SankeyData ?? "{\"nodes\":[],\"links\":[]}" %>;
    
    function initializeSankey() {
      const colors = getThemeColors();
      const svg = d3.select('#sankeyCalibration');
      svg.selectAll('*').remove();
      
      const container = document.querySelector('#sankeyCalibration').parentElement;
      const width = container.clientWidth;
      const height = container.clientHeight;
      
      if (!sankeyData || !sankeyData.nodes || sankeyData.nodes.length === 0) {
        svg.append('text')
          .attr('x', width / 2)
          .attr('y', height / 2)
          .attr('text-anchor', 'middle')
          .attr('fill', colors.textSecondary)
          .style('font-family', "'Segoe UI', system-ui, sans-serif")
          .style('font-size', '14px')
          .text('No calibration data available');
        return;
      }
      
      // Define enhanced color mapping for calibration flow (dark mode optimized)
      const nodeColors = {
        'Total Equipment': colors.isDark ? '#60a5fa' : colors.primary,
        'Asset': colors.isDark ? '#34d399' : colors.success,
        'ATE': colors.isDark ? '#60a5fa' : colors.primary,
        'Fixture': colors.isDark ? '#c084fc' : colors.purple,
        'Harness': colors.isDark ? '#fbbf24' : colors.warning,
        'Pending Calibration': colors.isDark ? '#f87171' : colors.danger,
        'No Pending Calibration': colors.isDark ? '#34d399' : colors.success,
        'Pass': colors.isDark ? '#34d399' : colors.success,
        'Out of Tolerance': colors.isDark ? '#f87171' : colors.danger,
        'Other': colors.isDark ? '#fbbf24' : colors.warning
      };
      
      function getNodeColor(node) {
        return nodeColors[node.name] || (colors.isDark ? '#9ca3af' : colors.textSecondary);
      }
      
      // Create Sankey layout
      const sankey = d3.sankey()
        .nodeWidth(20)
        .nodePadding(12)
        .nodeAlign(d3.sankeyLeft)
        .extent([[50, 10], [width - 50, height - 10]]);
      
      const graph = sankey({
        nodes: sankeyData.nodes.map(d => Object.assign({}, d)),
        links: sankeyData.links.map(d => Object.assign({}, d))
      });
      
      // Create gradients for links with enhanced dark mode visibility
      const defs = svg.append('defs');
      const linkOpacity = colors.isDark ? 0.5 : 0.35;
      
      graph.links.forEach((link, i) => {
        const gradient = defs.append('linearGradient')
          .attr('id', 'gradient-cal-' + i)
          .attr('gradientUnits', 'userSpaceOnUse')
          .attr('x1', link.source.x1)
          .attr('x2', link.target.x0);
        
        gradient.append('stop')
          .attr('offset', '0%')
          .attr('stop-color', getNodeColor(link.source))
          .attr('stop-opacity', linkOpacity);
        
        gradient.append('stop')
          .attr('offset', '100%')
          .attr('stop-color', getNodeColor(link.target))
          .attr('stop-opacity', linkOpacity);
      });
      
      // Draw links with gradients
      const linkGroup = svg.append('g')
        .attr('class', 'links')
        .attr('fill', 'none');
      
      linkGroup.selectAll('path')
        .data(graph.links)
        .join('path')
        .attr('d', d3.sankeyLinkHorizontal())
        .attr('stroke', (d, i) => 'url(#gradient-cal-' + i + ')')
        .attr('stroke-width', d => Math.max(1, d.width))
        .style('mix-blend-mode', 'multiply')
        .attr('opacity', 0.5)
        .on('mouseover', function(event, d) {
          d3.select(this)
            .attr('opacity', 0.8)
            .attr('stroke-width', d => Math.max(1, d.width) + 2);
          
          d3.select('body').append('div')
            .attr('class', 'sankey-tooltip')
            .style('position', 'absolute')
            .style('background', colors.tooltipBg)
            .style('border', '1px solid ' + colors.tooltipBorder)
            .style('border-radius', '8px')
            .style('padding', '10px 14px')
            .style('font-family', "'Segoe UI', system-ui, sans-serif")
            .style('font-size', '13px')
            .style('color', colors.text)
            .style('box-shadow', '0 4px 12px rgba(0,0,0,0.15)')
            .style('pointer-events', 'none')
            .style('z-index', '10000')
            .style('backdrop-filter', 'blur(10px)')
            .html('<strong>' + d.source.name + ' &rarr; ' + d.target.name + '</strong><br/>' +
                  '<span style="color:' + colors.textSecondary + '">Equipment: ' + d.value + '</span>')
            .style('left', (event.pageX + 10) + 'px')
            .style('top', (event.pageY - 10) + 'px');
        })
        .on('mouseout', function() {
          d3.select(this)
            .attr('opacity', 0.5)
            .attr('stroke-width', d => Math.max(1, d.width));
          d3.selectAll('.sankey-tooltip').remove();
        });
      
      // Draw nodes
      const nodeGroup = svg.append('g').attr('class', 'nodes');
      
      nodeGroup.selectAll('rect')
        .data(graph.nodes)
        .join('rect')
        .attr('x', d => d.x0)
        .attr('y', d => d.y0)
        .attr('height', d => d.y1 - d.y0)
        .attr('width', d => d.x1 - d.x0)
        .attr('fill', d => getNodeColor(d))
        .attr('stroke', colors.isDark ? 'rgba(255,255,255,0.25)' : 'rgba(0,0,0,0.25)')
        .attr('stroke-width', 1.5)
        .attr('rx', 3)
        .attr('ry', 3)
        .style('cursor', 'pointer')
        .on('mouseover', function(event, d) {
          d3.select(this).attr('fill', d3.color(getNodeColor(d)).brighter(0.3));
          
          const totalIn = d3.sum(d.targetLinks, l => l.value);
          const totalOut = d3.sum(d.sourceLinks, l => l.value);
          const total = Math.max(totalIn, totalOut);
          
          d3.select('body').append('div')
            .attr('class', 'sankey-tooltip')
            .style('position', 'absolute')
            .style('background', colors.tooltipBg)
            .style('border', '1px solid ' + colors.tooltipBorder)
            .style('border-radius', '8px')
            .style('padding', '10px 14px')
            .style('font-family', "'Segoe UI', system-ui, sans-serif")
            .style('font-size', '13px')
            .style('color', colors.text)
            .style('box-shadow', '0 4px 12px rgba(0,0,0,0.15)')
            .style('pointer-events', 'none')
            .style('z-index', '10000')
            .style('backdrop-filter', 'blur(10px)')
            .html('<strong>' + d.name + '</strong><br/>' +
                  '<span style="color:' + colors.textSecondary + '">Total Equipment: ' + total + '</span>')
            .style('left', (event.pageX + 10) + 'px')
            .style('top', (event.pageY - 10) + 'px');
        })
        .on('mouseout', function(event, d) {
          d3.select(this).attr('fill', getNodeColor(d));
          d3.selectAll('.sankey-tooltip').remove();
        });
      
      // Add node labels
      const labelGroup = svg.append('g').attr('class', 'labels');
      
      labelGroup.selectAll('text')
        .data(graph.nodes)
        .join('text')
        .attr('x', d => d.x0 < width / 2 ? d.x1 + 8 : d.x0 - 8)
        .attr('y', d => (d.y1 + d.y0) / 2)
        .attr('dy', '0.35em')
        .attr('text-anchor', d => d.x0 < width / 2 ? 'start' : 'end')
        .attr('fill', colors.text)
        .style('font-family', "'Segoe UI', system-ui, sans-serif")
        .style('font-size', d => {
          if (d.name === 'Total Equipment') return '15px';
          if (['ATE', 'Asset', 'Fixture', 'Harness'].includes(d.name)) return '13px';
          return '12px';
        })
        .style('font-weight', d => {
          if (d.name === 'Total Equipment') return '600';
          return '500';
        })
        .style('letter-spacing', '0.3px')
        .text(d => d.name);
    }


    // Initialize charts on page load
    document.addEventListener('DOMContentLoaded', function() {
      initializeCharts();
      
      // Initialize Sankey diagram if data is available
      if (sankeyData && sankeyData.nodes && sankeyData.nodes.length > 0) {
        initializeSankey();
      }
      
      // Listen for theme changes
      const observer = new MutationObserver(function(mutations) {
        mutations.forEach(function(mutation) {
          if (mutation.type === 'attributes' && 
              (mutation.attributeName === 'class' || mutation.attributeName === 'data-theme')) {
            console.log('Theme changed, reinitializing charts and Sankey...');
            initializeCharts();
            initializeSankey();
          }
        });
      });
      
      // Observe the html element for class and data-theme changes
      observer.observe(document.documentElement, {
        attributes: true,
        attributeFilter: ['class', 'data-theme']
      });
      
      // ===== KPI CARD CLICK HANDLERS =====
      // COMPLETED CALIBRATIONS card click
      const completedCard = document.getElementById('<%= cardCompletedCals.ClientID %>');
      if (completedCard) {
        completedCard.classList.add('clickable');
        completedCard.addEventListener('click', function() {
          showNavigationModal(
            'View All Calibrations',
            'Open the Calibration Grid View to see all calibration records?',
            'CalibrationGridView.aspx?collapse=true'
          );
        });
      }

      // DUE CALIBRATIONS card click
      const dueCard = document.getElementById('<%= cardDueCals.ClientID %>');
      if (dueCard) {
        dueCard.classList.add('clickable');
        dueCard.addEventListener('click', function() {
          showNavigationModal(
            'View Due Equipment',
            'Open the Equipment Grid View filtered by Due Soon Calibration Status (includes Overdue)?',
            'EquipmentGridView.aspx?calibrationstatus=DUE_SOON&collapse=true'
          );
        });
      }

      // UPCOMING CALIBRATIONS table rows click
      const upcomingTable = document.getElementById('<%= gvUpcomingCals.ClientID %>');
      if (upcomingTable) {
        const rows = upcomingTable.querySelectorAll('tr[data-equipment-id]');
        rows.forEach(row => {
          row.style.cursor = 'pointer';
          row.addEventListener('click', function() {
            const equipmentId = this.getAttribute('data-equipment-id');
            const equipmentName = this.getAttribute('data-equipment-name') || 'Selected Equipment';
            showNavigationModal(
              'View Equipment Details',
              `Open Equipment Grid View filtered by ${equipmentName}?`,
              `EquipmentGridView.aspx?equipment=${encodeURIComponent(equipmentId)}&collapse=true`
            );
          });
        });
      }

      // RECENT CALIBRATION LOGS table rows click
      const recentTable = document.getElementById('<%= gvRecentLogs.ClientID %>');
      if (recentTable) {
        const rows = recentTable.querySelectorAll('tr[data-cal-id]');
        rows.forEach(row => {
          row.style.cursor = 'pointer';
          row.addEventListener('click', function() {
            const calId = this.getAttribute('data-cal-id');
            showNavigationModal(
              'View Calibration Details',
              'Open the Calibration Details page to see complete calibration information?',
              `CalibrationDetails.aspx?id=${calId}`
            );
          });
        });
      }
    });

    // ===== NAVIGATION MODAL FUNCTIONS =====
    function showNavigationModal(title, message, url) {
      // Remove any existing modal
      const existingModal = document.querySelector('.nav-modal-overlay');
      if (existingModal) {
        existingModal.remove();
      }

      // Create modal
      const modal = document.createElement('div');
      modal.className = 'nav-modal-overlay';
      modal.innerHTML = `
        <div class="nav-modal">
          <div class="nav-modal-icon">
            <svg fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" d="M13 7l5 5m0 0l-5 5m5-5H6"></path>
            </svg>
          </div>
          <h3 class="nav-modal-title">${title}</h3>
          <p class="nav-modal-message">${message}</p>
          <div class="nav-modal-actions">
            <button class="nav-modal-btn nav-modal-btn-cancel" onclick="closeNavigationModal()">Cancel</button>
            <button class="nav-modal-btn nav-modal-btn-confirm" onclick="confirmNavigation('${url}')">Open</button>
          </div>
        </div>
      `;
      
      document.body.appendChild(modal);
      
      // Trigger animation
      setTimeout(() => {
        modal.classList.add('show');
      }, 10);
      
      // Close on overlay click
      modal.addEventListener('click', function(e) {
        if (e.target === modal) {
          closeNavigationModal();
        }
      });
      
      // Close on Escape key
      function handleEscape(e) {
        if (e.key === 'Escape') {
          closeNavigationModal();
          document.removeEventListener('keydown', handleEscape);
        }
      }
      document.addEventListener('keydown', handleEscape);
    }

    function closeNavigationModal() {
      const modal = document.querySelector('.nav-modal-overlay');
      if (modal) {
        modal.classList.remove('show');
        setTimeout(() => {
          modal.remove();
        }, 250);
      }
    }

    function confirmNavigation(url) {
      window.open(url, '_blank');
      closeNavigationModal();
    }
  </script>
  
  <!-- Navigation Modal Container (will be populated by JavaScript) -->
</asp:Content>
