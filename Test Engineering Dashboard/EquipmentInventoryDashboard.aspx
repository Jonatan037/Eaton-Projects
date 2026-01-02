<%@ Page Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="EquipmentInventoryDashboard.aspx.cs" Inherits="TED_EquipmentInventoryDashboard" %>
<asp:Content ID="EIDashTitle" ContentPlaceHolderID="TitleContent" runat="server">Equipment Inventory Dashboard - Test Engineering</asp:Content>
<asp:Content ID="EIDashHead" ContentPlaceHolderID="HeadContent" runat="server">
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
    }
    .nav-link.disabled { opacity:.45; cursor:not-allowed; pointer-events:none; color:#888; }
    .nav-link.disabled .icon { opacity:.5; }
    html.theme-light .nav-link.disabled, html[data-theme='light'] .nav-link.disabled { color:#999; opacity:.5; }
    .nav-link.danger { color:#ff6b6b; border-color:transparent; }
    .nav-link.danger .icon { color:currentColor; }
    .nav-link.danger:hover { background:rgba(255,86,86,.14); border-color:rgba(255,86,86,.35); color:#ff8a8a; }
    html.theme-light .nav-link.danger, html[data-theme='light'] .nav-link.danger { color:#c62828; }
    html.theme-light .nav-link.danger:hover, html[data-theme='light'] .nav-link.danger:hover { background:rgba(198,40,40,.10); border-color:rgba(198,40,40,.35); color:#b71c1c; }
    
    /* MAIN CONTENT COLUMN */
    .dash-col { 
      display:flex; 
      flex-direction:column; 
      gap:0; 
      overflow-y:auto; 
      overflow-x:hidden; 
      padding-right:4px; 
    }
    
    /* PAGE HEADER */
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
    
    .page-title { 
      font-size:24px; 
      font-weight:800; 
      letter-spacing:.2px; 
      margin:0; 
    }
    .page-subtitle { 
      font-size:12px; 
      opacity:.7; 
      margin:4px 0 0; 
      font-weight:400; 
    }
    .header-actions { 
      display:flex; 
      gap:8px; 
      align-items:center; 
      margin-right:12px; 
    }
    
    /* ICON BUTTONS */
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
    .btn-icon:hover:not(:disabled) {
      background: rgba(255,255,255,.14);
      border-color: rgba(255,255,255,.28);
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
    
    /* Tooltip Styles - BELOW buttons, aligned right */
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
      margin-bottom:24px;
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
    .kpi-trend { display:flex; align-items:center; gap:4px; }
    .kpi-trend.up { color:#10b981; }
    .kpi-trend.down { color:#ef4444; }
    
    /* STATUS COLORS WITH BACKGROUNDS */
    .kpi-card.status-red { 
      border-left:4px solid #ef4444; 
      background:linear-gradient(135deg, rgba(239,68,68,.15), rgba(239,68,68,.05)); 
    }
    .kpi-card.status-red .kpi-value { color:#fca5a5; }
    html.theme-light .kpi-card.status-red, html[data-theme='light'] .kpi-card.status-red { 
      border-left:4px solid #ef4444; 
      background:linear-gradient(135deg, #fef2f2, #ffffff); 
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
    .chart-title { 
      font-size:14px; 
      font-weight:700; 
      letter-spacing:.2px; 
      margin:0 0 16px;
      color: #f1f5f9;  /* Light for dark mode */
    }
    html.theme-light .chart-title, 
    html[data-theme='light'] .chart-title,
    body.theme-light .chart-title {
      color: #0f172a !important;  /* Black for light mode */
    }
    .chart-container { 
      position:relative; 
      height:280px; 
    }
    .chart-full { grid-column:1 / -1; }
    
    /* TABLES GRID */
    .tables-grid { 
      display:grid; 
      grid-template-columns:repeat(auto-fit, minmax(480px, 1fr)); 
      gap:16px; 
    }
    
    /* UPCOMING PMS & RECENT COMPLETIONS LIST */
    .upcoming-list, .recent-completions-list { 
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
    html.theme-light .recent-completions-list, html[data-theme='light'] .recent-completions-list { 
      background:#ffffff; 
      border:1px solid rgba(0,0,0,.08); 
      box-shadow:0 4px 18px -6px rgba(0,0,0,.18); 
    }
    
    .upcoming-header, .recent-completions-header { 
      display:flex; 
      justify-content:space-between; 
      align-items:center; 
      margin-bottom:14px; 
      padding-bottom:10px;
      border-bottom:1px solid rgba(255,255,255,.06);
    }
    html.theme-light .upcoming-header, html[data-theme='light'] .upcoming-header,
    html.theme-light .recent-completions-header, html[data-theme='light'] .recent-completions-header { 
      border-bottom:1px solid rgba(0,0,0,.06); 
    }
    
    .upcoming-title, .recent-completions-title { 
      font-size:14px; 
      font-weight:700; 
      letter-spacing:.2px; 
      margin:0; 
    }
    
    .upcoming-items, .recent-completions-items { 
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
      grid-template-columns:180px 1fr 120px 100px; 
      gap:16px; 
      padding:12px 14px; 
      background:rgba(255,255,255,.03); 
      border:1px solid rgba(255,255,255,.06); 
      border-radius:10px; 
      transition:all .2s ease;
      align-items:center;
      min-width:520px;
    }
    .upcoming-item:hover { 
      background:rgba(255,255,255,.06); 
      border-color:rgba(255,255,255,.12); 
      transform:translateX(4px); 
    }
    html.theme-light .upcoming-item, html[data-theme='light'] .upcoming-item { 
      background:rgba(0,0,0,.02); 
      border:1px solid rgba(0,0,0,.06); 
    }
    html.theme-light .upcoming-item:hover, html[data-theme='light'] .upcoming-item:hover { 
      background:rgba(0,0,0,.04); 
      border-color:rgba(0,0,0,.12); 
    }
    
    .upcoming-id { font-size:13px; font-weight:600; color:#60a5fa; }
    html.theme-light .upcoming-id, html[data-theme='light'] .upcoming-id { color:#2563eb; }
    .upcoming-name { font-size:13px; font-weight:500; }
    .upcoming-type { font-size:12px; opacity:.7; }
    .upcoming-date { 
      font-size:12px; 
      font-weight:600; 
      padding:4px 10px; 
      border-radius:6px; 
      text-align:center;
      white-space:nowrap;
    }
    .upcoming-date.soon { background:rgba(239,68,68,.15); color:#fca5a5; border:1px solid rgba(239,68,68,.3); }
    .upcoming-date.upcoming { background:rgba(245,158,11,.15); color:#fcd34d; border:1px solid rgba(245,158,11,.3); }
    .upcoming-date.future { background:rgba(16,185,129,.15); color:#6ee7b7; border:1px solid rgba(16,185,129,.3); }
    
    html.theme-light .upcoming-date.soon, html[data-theme='light'] .upcoming-date.soon { 
      background:rgba(239,68,68,.1); color:#dc2626; border:1px solid rgba(239,68,68,.25); 
    }
    html.theme-light .upcoming-date.upcoming, html[data-theme='light'] .upcoming-date.upcoming { 
      background:rgba(245,158,11,.1); color:#d97706; border:1px solid rgba(245,158,11,.25); 
    }
    html.theme-light .upcoming-date.future, html[data-theme='light'] .upcoming-date.future { 
      background:rgba(16,185,129,.1); color:#059669; border:1px solid rgba(16,185,129,.25); 
    }
    

    
    /* RECENT COMPLETIONS ITEM */
    .recent-completion-item {
      display:grid;
      grid-template-columns:180px 120px 100px 100px 80px;
      gap:18px;
      padding:12px 14px;
      background:rgba(255,255,255,.03);
      border:1px solid rgba(255,255,255,.06);
      border-radius:10px;
      transition:all .2s ease;
      align-items:center;
      min-width:600px;
    }
    .recent-completion-item:hover {
      background:rgba(255,255,255,.06);
      border-color:rgba(255,255,255,.12);
      transform:translateX(4px);
    }
    html.theme-light .recent-completion-item, html[data-theme='light'] .recent-completion-item {
      background:rgba(0,0,0,.02);
      border:1px solid rgba(0,0,0,.06);
    }
    html.theme-light .recent-completion-item:hover, html[data-theme='light'] .recent-completion-item:hover {
      background:rgba(0,0,0,.04);
      border-color:rgba(0,0,0,.12);
    }
    
    .completion-id { font-size:13px; font-weight:600; color:#60a5fa; }
    html.theme-light .completion-id, html[data-theme='light'] .completion-id { color:#2563eb; }
    .completion-date { font-size:13px; font-weight:500; }
    .completion-duration { font-size:12px; opacity:.75; }
    .completion-cost { font-size:13px; font-weight:600; color:#10b981; }
    html.theme-light .completion-cost, html[data-theme='light'] .completion-cost { color:#059669; }
    .completion-status {
      display:flex;
      align-items:center;
      justify-content:center;
      width:100%;
    }
    .completion-status .toggle-indicator {
      width:36px;
      height:20px;
      background:rgba(239,68,68,.3);
      border-radius:10px;
      position:relative;
      transition:all .2s ease;
      display:flex;
      align-items:center;
    }
    .completion-status .toggle-indicator::after {
      content:'';
      width:16px;
      height:16px;
      background:#ffffff;
      border-radius:50%;
      position:absolute;
      left:2px;
      transition:all .2s ease;
      box-shadow:0 2px 4px rgba(0,0,0,.2);
    }
    .completion-status.on .toggle-indicator {
      background:rgba(16,185,129,.6);
    }
    .completion-status.on .toggle-indicator::after {
      left:18px;
    }
    html.theme-light .completion-status .toggle-indicator,
    html[data-theme='light'] .completion-status .toggle-indicator {
      background:rgba(239,68,68,.25);
    }
    html.theme-light .completion-status.on .toggle-indicator,
    html[data-theme='light'] .completion-status.on .toggle-indicator {
      background:rgba(16,185,129,.5);
    }

    /* MODERN TABLE STYLES - From PM Dashboard Standard */
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
      color: #1e293b !important;
    }
    html.theme-dark .table-row-light, html[data-theme='dark'] .table-row-light {
      background-color: transparent;
      color: #f1f5f9 !important;
    }
    .table-row-alt {
      background-color: #f8fafc;
      color: #1e293b;
    }
    html.theme-dark .table-row-alt, html[data-theme='dark'] .table-row-alt {
      background-color: rgba(255,255,255,.05);
      color: #f1f5f9 !important;
    }
    
    html.theme-light .modern-table td, html[data-theme='light'] .modern-table td {
      border-color: #e5e7eb;
    }
    html.theme-dark .modern-table td, html[data-theme='dark'] .modern-table td {
      border-color: rgba(255,255,255,.08);
      color: #f1f5f9;
    }
    .modern-table th {
      border: 1px solid #2563eb;
      padding: 12px;
      text-align: center;
    }
    .modern-table tr:hover td {
      background-color: #f1f5f9 !important;
      transition: background-color 0.2s ease;
    }
    html.theme-dark .modern-table tr:hover td, html[data-theme='dark'] .modern-table tr:hover td {
      background-color: rgba(255,255,255,.05) !important;
      transition: background-color 0.2s ease;
    }
    
    /* Clickable row styling */
    .modern-table tr[onclick] {
      cursor: pointer;
    }
    .modern-table tr[onclick]:hover {
      transform: translateY(-1px);
      box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    }
    html.theme-dark .modern-table tr[onclick]:hover, html[data-theme='dark'] .modern-table tr[onclick]:hover {
      box-shadow: 0 2px 8px rgba(255,255,255,0.1);
    }
    
    /* Completion Status Toggle (From PM Dashboard) */
    .completion-status {
      display:flex;
      align-items:center;
      justify-content:center;
      width:100%;
    }
    .completion-status .toggle-indicator {
      width:36px;
      height:20px;
      background:rgba(239,68,68,.3);
      border-radius:10px;
      position:relative;
      transition:all .2s ease;
      display:flex;
      align-items:center;
    }
    .completion-status .toggle-indicator::after {
      content:'';
      width:16px;
      height:16px;
      background:#ffffff;
      border-radius:50%;
      position:absolute;
      left:2px;
      transition:all .2s ease;
      box-shadow:0 2px 4px rgba(0,0,0,.2);
    }
    .completion-status.on .toggle-indicator {
      background:rgba(16,185,129,.6);
    }
    .completion-status.on .toggle-indicator::after {
      left:18px;
    }
    html.theme-light .completion-status .toggle-indicator,
    html[data-theme='light'] .completion-status .toggle-indicator {
      background:rgba(239,68,68,.25);
    }
    html.theme-light .completion-status.on .toggle-indicator,
    html[data-theme='light'] .completion-status.on .toggle-indicator {
      background:rgba(16,185,129,.5);
    }

    /* Badge Styles for Equipment Type and Status */
    .type-badge, .status-badge {
      display: inline-flex;
      align-items: center;
      padding: 4px 10px;
      border-radius: 6px;
      font-size: 11px;
      font-weight: 700;
      font-family: 'Segoe UI', -apple-system, BlinkMacSystemFont, system-ui, sans-serif;
      letter-spacing: 0.3px;
      text-transform: uppercase;
      white-space: nowrap;
    }
    
    /* Equipment Type Badges - Light Mode */
    .type-badge.type-ate {
      background: rgba(37,99,235,.1);
      color: #2563eb;
      border: 1px solid rgba(37,99,235,.25);
    }
    .type-badge.type-asset {
      background: rgba(5,150,105,.1);
      color: #059669;
      border: 1px solid rgba(5,150,105,.25);
    }
    .type-badge.type-fixture {
      background: rgba(124,58,237,.1);
      color: #7c3aed;
      border: 1px solid rgba(124,58,237,.25);
    }
    .type-badge.type-harness {
      background: rgba(234,88,12,.1);
      color: #ea580c;
      border: 1px solid rgba(234,88,12,.25);
    }
    
    /* Equipment Type Badges - Dark Mode */
    html.theme-dark .type-badge.type-ate,
    html[data-theme='dark'] .type-badge.type-ate {
      background: rgba(96,165,250,.15);
      color: #93c5fd;
      border: 1px solid rgba(96,165,250,.3);
    }
    html.theme-dark .type-badge.type-asset,
    html[data-theme='dark'] .type-badge.type-asset {
      background: rgba(34,197,94,.15);
      color: #86efac;
      border: 1px solid rgba(34,197,94,.3);
    }
    html.theme-dark .type-badge.type-fixture,
    html[data-theme='dark'] .type-badge.type-fixture {
      background: rgba(168,85,247,.15);
      color: #c4b5fd;
      border: 1px solid rgba(168,85,247,.3);
    }
    html.theme-dark .type-badge.type-harness,
    html[data-theme='dark'] .type-badge.type-harness {
      background: rgba(251,146,60,.15);
      color: #fdba74;
      border: 1px solid rgba(251,146,60,.3);
    }
    
    /* Status Badges - Light Mode */
    .status-badge.status-active {
      background: rgba(5,150,105,.1);
      color: #059669;
      border: 1px solid rgba(5,150,105,.25);
    }
    .status-badge.status-inactive {
      background: rgba(100,116,139,.1);
      color: #64748b;
      border: 1px solid rgba(100,116,139,.25);
    }
    .status-badge.status-maintenance {
      background: rgba(217,119,6,.1);
      color: #d97706;
      border: 1px solid rgba(217,119,6,.25);
    }
    .status-badge.status-spare {
      background: rgba(37,99,235,.1);
      color: #2563eb;
      border: 1px solid rgba(37,99,235,.25);
    }
    .status-badge.status-other {
      background: rgba(124,58,237,.1);
      color: #7c3aed;
      border: 1px solid rgba(124,58,237,.25);
    }
    
    /* Status Badges - Dark Mode */
    html.theme-dark .status-badge.status-active,
    html[data-theme='dark'] .status-badge.status-active {
      background: rgba(34,197,94,.15);
      color: #86efac;
      border: 1px solid rgba(34,197,94,.3);
    }
    html.theme-dark .status-badge.status-inactive,
    html[data-theme='dark'] .status-badge.status-inactive {
      background: rgba(148,163,184,.15);
      color: #cbd5e1;
      border: 1px solid rgba(148,163,184,.3);
    }
    html.theme-dark .status-badge.status-maintenance,
    html[data-theme='dark'] .status-badge.status-maintenance {
      background: rgba(245,158,11,.15);
      color: #fcd34d;
      border: 1px solid rgba(245,158,11,.3);
    }
    html.theme-dark .status-badge.status-spare,
    html[data-theme='dark'] .status-badge.status-spare {
      background: rgba(96,165,250,.15);
      color: #93c5fd;
      border: 1px solid rgba(96,165,250,.3);
    }
    html.theme-dark .status-badge.status-other,
    html[data-theme='dark'] .status-badge.status-other {
      background: rgba(168,85,247,.15);
      color: #c4b5fd;
      border: 1px solid rgba(168,85,247,.3);
    }

    /* Custom scrollbar */
    .dash-col::-webkit-scrollbar, 
    .upcoming-items::-webkit-scrollbar, 
    .recent-completions-items::-webkit-scrollbar { 
      width:6px; 
      height:6px;
    }
    .dash-col::-webkit-scrollbar-track,
    .upcoming-items::-webkit-scrollbar-track, 
    .recent-completions-items::-webkit-scrollbar-track { 
      background:transparent; 
    }
    .dash-col::-webkit-scrollbar-thumb,
    .upcoming-items::-webkit-scrollbar-thumb, 
    .recent-completions-items::-webkit-scrollbar-thumb { 
      background:rgba(255,255,255,.12); 
      border-radius:3px; 
    }
    .dash-col::-webkit-scrollbar-thumb:hover,
    .upcoming-items::-webkit-scrollbar-thumb:hover, 
    .recent-completions-items::-webkit-scrollbar-thumb:hover { 
      background:rgba(255,255,255,.20); 
    }
    html.theme-light .dash-col::-webkit-scrollbar-thumb,
    html.theme-light .upcoming-items::-webkit-scrollbar-thumb,
    html.theme-light .recent-completions-items::-webkit-scrollbar-thumb,
    html[data-theme='light'] .dash-col::-webkit-scrollbar-thumb,
    html[data-theme='light'] .upcoming-items::-webkit-scrollbar-thumb,
    html[data-theme='light'] .recent-completions-items::-webkit-scrollbar-thumb { 
      background:rgba(0,0,0,.12); 
    }
    html.theme-light .dash-col::-webkit-scrollbar-thumb:hover,
    html.theme-light .upcoming-items::-webkit-scrollbar-thumb:hover,
    html.theme-light .recent-completions-items::-webkit-scrollbar-thumb:hover,
    html[data-theme='light'] .dash-col::-webkit-scrollbar-thumb:hover,
    html[data-theme='light'] .upcoming-items::-webkit-scrollbar-thumb:hover,
    html[data-theme='light'] .recent-completions-items::-webkit-scrollbar-thumb:hover { 
      background:rgba(0,0,0,.20); 
    }

    /* Responsive */
    @media (max-width: 1400px) {
      .kpi-grid { grid-template-columns:repeat(3, 1fr); }
    }
    @media (max-width: 1024px) {
      .kpi-grid { grid-template-columns:repeat(2, 1fr); }
      .chart-grid { grid-template-columns:1fr; }
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
<asp:Content ID="PMDashMain" ContentPlaceHolderID="MainContent" runat="server">
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
          <li><a class="nav-link active" href="EquipmentInventoryDashboard.aspx"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M3 10l9-6 9 6"/><path d="M5 10v10h14V10"/><path d="M9 20v-6h6v6"/></svg><span>Equipment Inventory</span></a></li>
          <li><a class="nav-link" href="CalibrationDashboard.aspx"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><line x1="4" y1="21" x2="4" y2="14"/><line x1="4" y1="10" x2="4" y2="3"/><line x1="12" y1="21" x2="12" y2="12"/><line x1="12" y1="8" x2="12" y2="3"/><line x1="20" y1="21" x2="20" y2="16"/><line x1="20" y1="12" x2="20" y2="3"/><line x1="1" y1="14" x2="7" y2="14"/><line x1="9" y1="8" x2="15" y2="8"/><line x1="17" y1="16" x2="23" y2="16"/></svg><span>Calibration</span></a></li>
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
          <h1 class="page-title">Equipment Inventory Dashboard</h1>
          <p class="page-subtitle">Track and manage all equipment assets</p>
        </div>
        <div class="header-actions">
          <!-- Grid View Button (Purple) -->
          <button type="button" class="btn-icon btn-icon-accent" 
                  title="Grid View"
                  onclick="window.open('EquipmentGridView.aspx?collapse=true', '_blank'); return false;">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round">
              <rect x="3" y="3" width="7" height="7"></rect>
              <rect x="14" y="3" width="7" height="7"></rect>
              <rect x="14" y="14" width="7" height="7"></rect>
              <rect x="3" y="14" width="7" height="7"></rect>
            </svg>
          </button>
          
          <!-- View Details Button (Amber) -->
          <button type="button" class="btn-icon btn-icon-amber" 
                  title="View Details"
                  onclick="window.location='ItemDetails.aspx?type=ATE'; return false;">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round">
              <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
              <circle cx="12" cy="12" r="3"></circle>
            </svg>
          </button>

          <!-- New Equipment Button (Blue) -->
          <button type="button" class="btn-icon btn-icon-primary" 
                  title="New Equipment"
                  onclick="window.location='CreateNewItem.aspx?type=ATE'; return false;">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round">
              <line x1="12" y1="5" x2="12" y2="19"></line>
              <line x1="5" y1="12" x2="19" y2="12"></line>
            </svg>
          </button>
        </div>
      </div>

      <!-- KPI CARDS -->
      <div class="kpi-grid">
        <!-- TOTAL EQUIPMENT - Hybrid with bar chart by equipment types -->
        <div class="kpi-card status-blue" id="cardTotalEquipment" runat="server" onclick="showNavigationModal('View All Equipment', 'Open the Equipment Grid View to see all equipment?', 'http://usyouwhp6205605/Test%20Engineering%20Dashboard/EquipmentGridView.aspx?collapse=true')" style="cursor: pointer;">
          <div class="kpi-label">Total Equipment</div>
          <div style="display: flex; align-items: center; justify-content: space-between; margin-top: 4px; height: 60px;">
            <div class="kpi-value" style="margin-bottom: 0;"><asp:Literal ID="litTotalEquipment" runat="server" Text="0" /></div>
            <div style="width: 120px; height: 50px; margin-right: -4px;" onclick="event.stopPropagation();">
              <canvas id="miniBarTotalEquipment"></canvas>
            </div>
          </div>
          <div class="kpi-footer" style="margin-top: 8px;">
            <span>All equipment types</span>
          </div>
        </div>
        
        <!-- ACTIVE EQUIPMENT - Hybrid with utilization gauge -->
        <div class="kpi-card" id="cardActiveEquipment" runat="server" onclick="showNavigationModal('View Active Equipment', 'Open the Equipment Grid View filtered by In Use status?', 'http://usyouwhp6205605/Test%20Engineering%20Dashboard/EquipmentGridView.aspx?status=In%20Use&collapse=true')" style="cursor: pointer;">
          <div class="kpi-label">Active Equipment</div>
          <div style="display: flex; align-items: center; justify-content: space-between; margin-top: 4px; height: 60px;">
            <div class="kpi-value" style="margin-bottom: 0;"><asp:Literal ID="litActiveEquipment" runat="server" Text="0" /></div>
            <div style="width: 75px; height: 60px; position: relative; margin-right: -4px;" onclick="event.stopPropagation();">
              <canvas id="gaugeUtilization"></canvas>
            </div>
          </div>
          <div class="kpi-footer" style="margin-top: 8px;">
            <asp:Literal ID="litOutOfService" runat="server" Text="0 out of service" />
          </div>
        </div>
        
        <!-- CALIBRATION DUE - Hybrid with bullet chart -->
        <div class="kpi-card" id="cardCalibrationDue" runat="server" onclick="showNavigationModal('View Due Equipment', 'Open the Equipment Grid View filtered by Due Soon Calibration Status (includes Overdue)?', 'http://usyouwhp6205605/Test%20Engineering%20Dashboard/EquipmentGridView.aspx?calibrationstatus=DUE_SOON&collapse=true')" style="cursor: pointer;">
          <div class="kpi-label">Calibration Due</div>
          <div style="display: flex; align-items: center; justify-content: space-between; margin-top: 4px; height: 60px;">
            <div class="kpi-value" style="margin-bottom: 0;"><asp:Literal ID="litCalibrationDue" runat="server" Text="0" /></div>
            <div style="width: 120px; height: 40px; margin-right: -4px;" onclick="event.stopPropagation();">
              <canvas id="bulletChartCalibrationDue"></canvas>
            </div>
          </div>
          <div class="kpi-footer" style="margin-top: 8px;">
            <asp:Literal ID="litCalibrationText" runat="server" Text="0 overdue" />
          </div>
        </div>
        
        <!-- PM DUE - Hybrid with bullet chart -->
        <div class="kpi-card" id="cardPMDue" runat="server" onclick="showNavigationModal('View Due Equipment', 'Open the Equipment Grid View filtered by Due Soon PM Status (includes Overdue)?', 'http://usyouwhp6205605/Test%20Engineering%20Dashboard/EquipmentGridView.aspx?pmstatus=duesoon&collapse=true')" style="cursor: pointer;">
          <div class="kpi-label">PM Due</div>
          <div style="display: flex; align-items: center; justify-content: space-between; margin-top: 4px; height: 60px;">
            <div class="kpi-value" style="margin-bottom: 0;"><asp:Literal ID="litPMDue" runat="server" Text="0" /></div>
            <div style="width: 120px; height: 40px; margin-right: -4px;" onclick="event.stopPropagation();">
              <canvas id="bulletChartPMDue"></canvas>
            </div>
          </div>
          <div class="kpi-footer" style="margin-top: 8px;">
            <asp:Literal ID="litPMText" runat="server" Text="0 overdue" />
          </div>
        </div>
        
        <!-- SPARES - Hybrid with bar chart by equipment types -->
        <div class="kpi-card status-blue" id="cardSpares" runat="server" onclick="showNavigationModal('View Spare Equipment', 'Open the Equipment Grid View filtered by Spare status?', 'http://usyouwhp6205605/Test%20Engineering%20Dashboard/EquipmentGridView.aspx?status=Spare&collapse=true')" style="cursor: pointer;">
          <div class="kpi-label">Spares</div>
          <div style="display: flex; align-items: center; justify-content: space-between; margin-top: 4px; height: 60px;">
            <div class="kpi-value" style="margin-bottom: 0;"><asp:Literal ID="litSpares" runat="server" Text="0" /></div>
            <div style="width: 120px; height: 50px; margin-right: -4px;">
              <canvas id="miniBarSpares"></canvas>
            </div>
          </div>
          <div class="kpi-footer" style="margin-top: 8px;">
            <span><asp:Literal ID="litSparesText" runat="server" Text="Available spares" /></span>
          </div>
        </div>
      </div>

      <!-- SANKEY DIAGRAM (Full Width) -->
      <div class="chart-card" style="margin-bottom: 24px;">
        <h3 class="chart-title">
          <strong>Equipment Flow:</strong> 
          <span style="font-weight: 400;">
            Total Equipment &rarr; Equipment Status &rarr; Equipment Type &rarr; Line
          </span>
        </h3>
        <div class="chart-container" style="height: 500px;">
          <svg id="sankeyDiagram" style="width: 100%; height: 100%;"></svg>
        </div>
      </div>

      <!-- CHARTS GRID -->
      <div class="chart-grid" style="margin-bottom: 24px;">
        <!-- Equipment Drill-Down Chart - Full Width (Line → Location → Equipment IDs) -->
        <div class="chart-card" style="grid-column: 1 / -1;">
          <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 16px;">
            <h3 class="chart-title" style="margin: 0;">Equipment by Line</h3>
            <div id="breadcrumbNav" style="display: flex; align-items: center; gap: 6px; font-size: 12px;">
              <!-- Breadcrumb navigation will be inserted here -->
            </div>
          </div>
          <div class="chart-container" style="height: 500px;">
            <canvas id="chartEquipmentDrillDown"></canvas>
          </div>
        </div>
      </div>

      <!-- RECENT ADDITIONS TABLE -->
      <div id="recentAdditionsTableSection" runat="server" class="chart-card" style="grid-column: span 2; margin-bottom: 24px;">
        <div class="chart-title">Recent Additions (Last 30 Days)</div>
        <div style="overflow-x: auto; margin-top: 15px;">
          <asp:GridView ID="gvRecentAdditions" runat="server" AutoGenerateColumns="False" 
            CssClass="modern-table" GridLines="Both"
            BorderStyle="None" BorderWidth="0" CellPadding="0" CellSpacing="0"
            OnRowDataBound="gvRecentAdditions_RowDataBound">
            <HeaderStyle BackColor="#2563eb" ForeColor="White" Font-Bold="True" 
              Font-Size="11px" Height="40px" VerticalAlign="Middle" 
              HorizontalAlign="Center"
              Font-Names="'Segoe UI', sans-serif" />
            <RowStyle CssClass="table-row-light" Font-Size="11px" Height="36px" 
              VerticalAlign="Middle" Font-Names="'Segoe UI', sans-serif" />
            <AlternatingRowStyle CssClass="table-row-alt" />
            <EmptyDataTemplate>
              <div style="padding: 40px; text-align: center; color: #6b7280; font-size: 13px;">
                <p style="margin: 0;">No recent additions found.</p>
                <p style="margin: 8px 0 0 0; font-size: 11px; opacity: 0.7;">Equipment added in the last 30 days will appear here.</p>
              </div>
            </EmptyDataTemplate>
              <Columns>
                <asp:BoundField DataField="EquipmentType" HeaderText="Equipment Type" 
                  ItemStyle-Width="120px" ItemStyle-CssClass="table-cell-padding"
                  HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center" />
                <asp:BoundField DataField="EatonID" HeaderText="Equipment ID" 
                  ItemStyle-Width="140px" ItemStyle-CssClass="table-cell-padding"
                  HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center" />
                <asp:BoundField DataField="Name" HeaderText="Equipment Name" 
                  ItemStyle-Width="200px" ItemStyle-CssClass="table-cell-padding-lr"
                  HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Left" />
                <asp:BoundField DataField="Location" HeaderText="Equipment Location" 
                  ItemStyle-Width="140px" ItemStyle-CssClass="table-cell-padding"
                  HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center" />
                <asp:BoundField DataField="Status" HeaderText="Status" 
                  ItemStyle-Width="100px" ItemStyle-CssClass="table-cell-padding"
                  HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center" />
                <asp:TemplateField HeaderText="Req PM" ItemStyle-Width="80px" 
                  ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                  <ItemTemplate>
                    <div class='completion-status <%# Convert.ToBoolean(Eval("RequiresPM")) ? "on" : "off" %>' 
                         title='<%# Convert.ToBoolean(Eval("RequiresPM")) ? "PM Required" : "No PM Required" %>'>
                      <span class="toggle-indicator"></span>
                    </div>
                  </ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Req Cal" ItemStyle-Width="80px" 
                  ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                  <ItemTemplate>
                    <div class='completion-status <%# Convert.ToBoolean(Eval("RequiresCalibration")) ? "on" : "off" %>' 
                         title='<%# Convert.ToBoolean(Eval("RequiresCalibration")) ? "Calibration Required" : "No Calibration Required" %>'>
                      <span class="toggle-indicator"></span>
                    </div>
                  </ItemTemplate>
                </asp:TemplateField>
                <asp:BoundField DataField="CreatedDate" HeaderText="Created Date" 
                  DataFormatString="{0:MM/dd/yyyy}" 
                  ItemStyle-Width="100px" ItemStyle-CssClass="table-cell-padding"
                  HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center" />
              </Columns>
            </asp:GridView>
          </div>
      </div>
            </asp:Literal>
          </div>
        </div>
      </div>
    </section>
  </div>

  <script type="text/javascript">
    // THEME-REACTIVE CHART COLORS
    let chartInstances = {};
    
    // Wait for plugins to load, then register datalabels
    if (typeof ChartDataLabels !== 'undefined') {
      Chart.register(ChartDataLabels);
    }
    
    // Set global Chart.js font defaults
    Chart.defaults.font.family = "'Segoe UI', -apple-system, BlinkMacSystemFont, system-ui, sans-serif";
    Chart.defaults.font.size = 11;
    Chart.defaults.plugins.legend.labels.usePointStyle = true;
    Chart.defaults.plugins.legend.labels.padding = 12;
    Chart.defaults.plugins.legend.labels.font = {
      family: "'Segoe UI', sans-serif",
      size: 11
    };
    
    // Set color for legend labels
    Chart.defaults.color = '#94a3b8';
    
    function getChartColors() {
      const isDark = document.documentElement.classList.contains('theme-dark') || 
                     document.documentElement.getAttribute('data-theme') === 'dark' ||
                     !document.documentElement.classList.contains('theme-light');
      
      return {
        isDark: isDark,
        primary: isDark ? '#60a5fa' : '#2563eb',
        success: isDark ? '#34d399' : '#059669',
        danger: isDark ? '#f87171' : '#dc2626',
        warning: isDark ? '#fbbf24' : '#d97706',
        purple: isDark ? '#a78bfa' : '#7c3aed',
        orange: isDark ? '#fb923c' : '#ea580c',
        teal: isDark ? '#2dd4bf' : '#0d9488',
        text: isDark ? '#f1f5f9' : '#0f172a',
        textSecondary: isDark ? '#94a3b8' : '#64748b',
        grid: isDark ? 'rgba(255,255,255,0.06)' : 'rgba(0,0,0,0.08)',
        tooltipBg: isDark ? 'rgba(30,41,59,0.95)' : 'rgba(255,255,255,0.95)',
        tooltipBorder: isDark ? 'rgba(255,255,255,0.12)' : 'rgba(0,0,0,0.12)'
      };
    }

    function destroyAllCharts() {
      Object.values(chartInstances).forEach(chart => {
        if (chart) chart.destroy();
      });
      chartInstances = {};
    }

    function initializeCharts() {
      destroyAllCharts();
      const colors = getChartColors();
      
      // Update chart defaults for current theme
      Chart.defaults.color = colors.text;
      Chart.defaults.borderColor = colors.grid;

      // 1. Sankey Diagram
      initializeSankeyDiagram(colors);

      /* REMOVED - Equipment by Type Chart
      // 2. Equipment by Type Chart (Column/Bar)
      const ctxType = document.getElementById('chartType');
      if (ctxType) {
        const typeLabels = <%= TypeLabels %>;
        const typeData = <%= TypeData %>;
        console.log('Type Labels:', typeLabels);
        console.log('Type Data:', typeData);
        
        if (!typeLabels || typeLabels.length === 0 || (typeLabels.length === 1 && typeLabels[0] === 'No Data')) {
          console.warn('No data available for Equipment by Type chart');
        }
        
        chartInstances.type = new Chart(ctxType, {
          type: 'bar',
          data: {
            labels: typeLabels,
            datasets: [{
              label: 'Equipment Count',
              data: typeData,
              backgroundColor: [colors.success, colors.primary, colors.purple, colors.warning],  // Asset, ATE, Fixture, Harness
              borderWidth: 0,
              borderRadius: 6
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
                padding: 12,
                boxPadding: 6,
                titleFont: { size: 12, weight: '600', family: "'Segoe UI', sans-serif" },
                bodyFont: { size: 11, family: "'Segoe UI', sans-serif" },
                callbacks: {
                  title: (items) => items[0].label,
                  label: (context) => 'Count: ' + context.parsed.y
                }
              },
              datalabels: {
                anchor: 'end',
                align: 'top',
                color: colors.text,
                font: { size: 11, weight: '600', family: "'Segoe UI', sans-serif" },
                formatter: (value) => value
              }
            },
            scales: {
              y: {
                beginAtZero: true,
                ticks: { color: colors.text, font: { size: 11, family: "'Segoe UI', sans-serif" } },
                grid: { display: false }
              },
              x: {
                ticks: { color: colors.text, font: { size: 11, family: "'Segoe UI', sans-serif" } },
                grid: { display: false }
              }
            }
          }
        });
      }
      END REMOVED */

      /* REMOVED - Equipment by Line Chart
      // 3. Equipment by Line Chart (Stacked Column)
      const ctxLine = document.getElementById('chartLine');
      if (ctxLine) {
        const lineLabels = <%= LineLabels %>;
        const lineDatasets = <%= LineDatasets %>;
        console.log('Line Labels:', lineLabels);
        console.log('Line Datasets:', lineDatasets);
        
        chartInstances.line = new Chart(ctxLine, {
          type: 'bar',
          data: {
            labels: lineLabels,
            datasets: lineDatasets
          },
          options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
              legend: { 
                display: false  // Hide legend like Location chart
              },
              tooltip: {
                backgroundColor: colors.tooltipBg,
                titleColor: colors.text,
                bodyColor: colors.text,
                borderColor: colors.tooltipBorder,
                borderWidth: 1,
                padding: 12,
                boxPadding: 6,
                titleFont: { size: 12, weight: '600', family: "'Segoe UI', sans-serif" },
                bodyFont: { size: 11, family: "'Segoe UI', sans-serif" }
              },
              datalabels: {
                display: false  // Hide individual equipment type counts
              }
            },
            scales: {
              x: {
                stacked: true,
                ticks: { 
                  color: colors.text, 
                  font: { size: 11, family: "'Segoe UI', sans-serif" },
                  maxRotation: 45,
                  minRotation: 45
                },
                grid: { display: false }
              },
              y: {
                stacked: true,
                beginAtZero: true,
                ticks: { color: colors.text, font: { size: 11, family: "'Segoe UI', sans-serif" } },
                grid: { display: false }
              }
            }
          },
          plugins: [{
            afterDatasetsDraw: function(chart) {
              // Draw total count on top of each stacked bar
              const ctx = chart.ctx;
              chart.data.datasets.forEach(function(dataset, i) {
                const meta = chart.getDatasetMeta(i);
                if (!meta.hidden) {
                  meta.data.forEach(function(element, index) {
                    // Only draw on the last (top) dataset
                    if (i === chart.data.datasets.length - 1) {
                      // Calculate total for this bar
                      let total = 0;
                      chart.data.datasets.forEach(function(ds) {
                        if (!chart.getDatasetMeta(chart.data.datasets.indexOf(ds)).hidden) {
                          total += ds.data[index] || 0;
                        }
                      });
                      
                      // Draw total above the bar
                      if (total > 0) {
                        ctx.fillStyle = colors.text;
                        ctx.font = "bold 11px 'Segoe UI', sans-serif";
                        ctx.textAlign = 'center';
                        ctx.textBaseline = 'bottom';
                        ctx.fillText(total, element.x, element.y - 5);
                      }
                    }
                  });
                }
              });
            }
          }]
        });
      }
      END REMOVED */

      /* REMOVED - Equipment by Status Chart
      // 4. Equipment by Status Chart (Horizontal Bar)
      const ctxStatus = document.getElementById('chartStatus');
      if (ctxStatus) {
        const statusLabels = <%= StatusLabels %>;
        const statusData = <%= StatusData %>;
        console.log('Status Labels:', statusLabels);
        console.log('Status Data:', statusData);
        
        chartInstances.status = new Chart(ctxStatus, {
          type: 'bar',
          data: {
            labels: statusLabels,
            datasets: [{
              label: 'Equipment Count',
              data: statusData,
              backgroundColor: function(context) {
                const label = context.chart.data.labels[context.dataIndex];
                if (label === 'Active' || label === 'In Use' || label === 'Available') return colors.success;
                if (label === 'Inactive' || label === 'Out of Service' || label === 'Retired') return colors.danger;
                return colors.primary;
              },
              borderWidth: 0,
              borderRadius: 6
            }]
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
                padding: 12,
                boxPadding: 6,
                titleFont: { size: 12, weight: '600', family: "'Segoe UI', sans-serif" },
                bodyFont: { size: 11, family: "'Segoe UI', sans-serif" }
              },
              datalabels: {
                anchor: 'end',
                align: 'right',
                color: colors.text,
                font: { size: 11, weight: '600', family: "'Segoe UI', sans-serif" },
                formatter: function(value) { return value; }
              }
            },
            scales: {
              x: {
                beginAtZero: true,
                ticks: { precision: 0, color: colors.textSecondary, font: { size: 11, family: "'Segoe UI', sans-serif" } },
                grid: { display: false }
              },
              y: {
                ticks: { color: colors.textSecondary, font: { size: 10, family: "'Segoe UI', sans-serif" } },
                grid: { display: false }
              }
            }
          }
        });
      }
      END REMOVED */

      /* REMOVED - Equipment by Location Chart (replaced with 3-level drill-down)
      // 1. Equipment by Location Chart (Large Stacked Horizontal Bar - NO LEGEND, TOTALS OUTSIDE - WITH DRILL-DOWN)
      const ctxLocation = document.getElementById('chartLocation');
      let isLocationDrillDown = false;  // Track if we're in drill-down mode
      let currentLocation = '';  // Track which location we drilled into
      
      if (ctxLocation) {
        const locationLabels = <%= LocationLabels %>;
        const locationDatasets = <%= LocationDatasets %>;
        console.log('Location Labels:', locationLabels);
        console.log('Location Datasets:', locationDatasets);
        
        // Store original data for returning from drill-down
        const originalLocationLabels = [...locationLabels];
        const originalLocationDatasets = JSON.parse(JSON.stringify(locationDatasets));
        
        // Function to render location chart
        function renderLocationChart(labels, datasets, clickable = true) {
          // Check if we have real data
          if (labels.length > 0 && labels[0] !== 'No Data' && datasets.length > 0) {
            // Calculate totals for each location/equipment
            const totals = labels.map((label, idx) => {
              return datasets.reduce((sum, dataset) => sum + (dataset.data[idx] || 0), 0);
            });
            
            if (chartInstances.location) {
              chartInstances.location.destroy();
            }
            
            chartInstances.location = new Chart(ctxLocation, {
              type: 'bar',
              data: {
                labels: labels,
                datasets: datasets
              },
              options: {
                indexAxis: 'y',
                responsive: true,
                maintainAspectRatio: false,
                onClick: clickable ? function(event, activeElements) {
                  if (activeElements && activeElements.length > 0 && !isLocationDrillDown) {
                    const index = activeElements[0].index;
                    const locationName = labels[index];
                    currentLocation = locationName;
                    
                    // Show loading indicator
                    document.getElementById('locationChartTitle').innerHTML = 
                      'Equipment by Location <span style="color:#f59e0b;">(Loading...)</span>';
                    
                    // Fetch equipment details for this location
                    fetch('EquipmentInventoryDashboard.aspx/GetEquipmentByLocation', {
                      method: 'POST',
                      headers: {
                        'Content-Type': 'application/json'
                      },
                      body: JSON.stringify({ location: locationName })
                    })
                    .then(response => response.json())
                    .then(data => {
                      const result = JSON.parse(data.d);
                      
                      // Update chart with equipment IDs
                      isLocationDrillDown = true;
                      document.getElementById('locationChartTitle').textContent = 
                        `Equipment in ${locationName}`;
                      document.getElementById('btnBackToLocations').style.display = 'inline-block';
                      
                      // Render drill-down chart
                      renderLocationChart(result.labels, result.datasets, false);
                    })
                    .catch(error => {
                      console.error('Error fetching equipment details:', error);
                      document.getElementById('locationChartTitle').innerHTML = 
                        'Equipment by Location <span style="color:#ef4444;">(Error loading data)</span>';
                    });
                  }
                } : null,
                plugins: {
                  legend: { 
                    display: false  // Hide legend as requested
                  },
                  tooltip: {
                    backgroundColor: colors.tooltipBg,
                    titleColor: colors.text,
                    bodyColor: colors.text,
                    borderColor: colors.tooltipBorder,
                    borderWidth: 1,
                    padding: 12,
                    boxPadding: 6,
                    titleFont: { size: 12, weight: '600', family: "'Segoe UI', sans-serif" },
                    bodyFont: { size: 11, family: "'Segoe UI', sans-serif" }
                  },
                  datalabels: {
                    display: false  // Hide internal data labels
                  }
                },
                scales: {
                  x: {
                    stacked: true,
                    beginAtZero: true,
                    ticks: { precision: 0, color: colors.textSecondary, font: { size: 11, family: "'Segoe UI', sans-serif" } },
                    grid: { display: false }
                  },
                  y: {
                    stacked: true,
                    ticks: { color: colors.textSecondary, font: { size: 11, family: "'Segoe UI', sans-serif" } },
                    grid: { display: false }
                  }
                },
                layout: {
                  padding: {
                    right: 40  // Add space for external total labels
                  }
                },
                animation: {
                  onComplete: function() {
                    // Draw total labels outside the bars
                    const chart = this;
                    const ctx = chart.ctx;
                    ctx.font = Chart.helpers.fontString(12, '700', "'Segoe UI'");
                    ctx.fillStyle = colors.text;
                    ctx.textAlign = 'left';
                    ctx.textBaseline = 'middle';
                    
                    chart.data.labels.forEach((label, index) => {
                      const meta = chart.getDatasetMeta(0);
                      const bar = meta.data[index];
                      const total = totals[index];
                      
                      // Calculate x position (end of stacked bar)
                      let xPos = chart.scales.x.left;
                      chart.data.datasets.forEach(dataset => {
                        xPos += chart.scales.x.getPixelForValue(dataset.data[index] || 0) - chart.scales.x.left;
                      });
                      
                      // Draw total outside the bar
                      ctx.fillText(total.toString(), xPos + 5, bar.y);
                    });
                  }
                }
              }
            });
          } else {
            console.log('No data available for Equipment by Location chart');
          }
        }
        
        // Initial render
        renderLocationChart(locationLabels, locationDatasets, true);
        
        // Back button handler
        document.getElementById('btnBackToLocations').addEventListener('click', function(e) {
          e.stopPropagation();
          isLocationDrillDown = false;
          currentLocation = '';
          document.getElementById('locationChartTitle').textContent = 'Equipment by Location';
          document.getElementById('btnBackToLocations').style.display = 'none';
          renderLocationChart(originalLocationLabels, originalLocationDatasets, true);
        });
      }
      END REMOVED */

      /* REMOVED - Assets by Type Chart
      // 2. Equipment by Type Chart (Column/Bar)
      const ctxAssetType = document.getElementById('chartAssetType');
      if (ctxAssetType) {
        const assetTypeLabels = <%= AssetTypeLabels %>;
        const assetTypeData = <%= AssetTypeData %>;
        console.log('Asset Type Labels:', assetTypeLabels);
        console.log('Asset Type Data:', assetTypeData);
        
        chartInstances.assetType = new Chart(ctxAssetType, {
          type: 'bar',
          data: {
            labels: assetTypeLabels,
            datasets: [{
              label: 'Asset Count',
              data: assetTypeData,
              backgroundColor: colors.purple,
              borderWidth: 0,
              borderRadius: 6
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
                padding: 12,
                boxPadding: 6,
                titleFont: { size: 12, weight: '600', family: "'Segoe UI', sans-serif" },
                bodyFont: { size: 11, family: "'Segoe UI', sans-serif" },
                callbacks: {
                  title: (items) => items[0].label,
                  label: (context) => 'Count: ' + context.parsed.y
                }
              },
              datalabels: {
                anchor: 'end',
                align: 'top',
                color: colors.text,
                font: { size: 11, weight: '600', family: "'Segoe UI', sans-serif" },
                formatter: (value) => value
              }
            },
            scales: {
              y: {
                beginAtZero: true,
                ticks: { color: colors.text, font: { size: 11, family: "'Segoe UI', sans-serif" } },
                grid: { display: false }
              },
              x: {
                ticks: { color: colors.text, font: { size: 11, family: "'Segoe UI', sans-serif" } },
                grid: { display: false }
              }
            }
          }
        });
      }
      END REMOVED */

      /* REMOVED - Calibration Status Chart
      // 5. Calibration Status Chart (Doughnut)
      const ctxCalibration = document.getElementById('chartCalibration');
      if (ctxCalibration) {
        const calibrationLabels = <%= CalibrationLabels %>;
        const calibrationData = <%= CalibrationData %>;
        console.log('Calibration Labels:', calibrationLabels);
        console.log('Calibration Data:', calibrationData);
        
        const calibrationColors = calibrationLabels.map(label => {
          if (label === 'Overdue') return colors.danger;
          if (label === 'Due Soon') return colors.warning;
          if (label === 'Current') return colors.success;
          return colors.textSecondary;
        });
        
        chartInstances.calibration = new Chart(ctxCalibration, {
          type: 'doughnut',
          data: {
            labels: calibrationLabels,
            datasets: [{
              data: calibrationData,
              backgroundColor: calibrationColors,
              borderWidth: 3,
              borderColor: colors.isDark ? 'rgba(15,23,42,1)' : '#ffffff',
              hoverOffset: 12,
              spacing: 2
            }]
          },
          options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
              legend: {
                position: 'right',
                labels: { color: colors.text, font: { size: 11, family: "'Segoe UI', sans-serif" }, padding: 12, boxWidth: 12, boxHeight: 12, usePointStyle: true }
              },
              tooltip: {
                backgroundColor: colors.tooltipBg,
                titleColor: colors.text,
                bodyColor: colors.text,
                borderColor: colors.tooltipBorder,
                borderWidth: 1,
                padding: 12,
                boxPadding: 6,
                titleFont: { size: 12, weight: '600', family: "'Segoe UI', sans-serif" },
                bodyFont: { size: 11, family: "'Segoe UI', sans-serif" }
              },
              datalabels: {
                color: '#ffffff',
                font: { size: 12, weight: '700', family: "'Segoe UI', sans-serif" },
                formatter: (value, context) => {
                  const total = context.dataset.data.reduce((a, b) => a + b, 0);
                  const percentage = ((value / total) * 100).toFixed(1);
                  return value > 0 ? percentage + '%' : '';
                }
              }
            }
          }
        });
      }
      END REMOVED */

      /* REMOVED - PM Status Chart
      // 6. PM Status Chart (Doughnut)
      const ctxPM = document.getElementById('chartPM');
      if (ctxPM) {
        const pmLabels = <%= PMLabels %>;
        const pmData = <%= PMData %>;
        console.log('PM Labels:', pmLabels);
        console.log('PM Data:', pmData);
        
        const pmColors = pmLabels.map(label => {
          if (label === 'Overdue') return colors.danger;
          if (label === 'Due Soon') return colors.warning;
          if (label === 'Current') return colors.success;
          return colors.textSecondary;
        });
        
        chartInstances.pm = new Chart(ctxPM, {
          type: 'doughnut',
          data: {
            labels: pmLabels,
            datasets: [{
              data: pmData,
              backgroundColor: pmColors,
              borderWidth: 3,
              borderColor: colors.isDark ? 'rgba(15,23,42,1)' : '#ffffff',
              hoverOffset: 12,
              spacing: 2
            }]
          },
          options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
              legend: {
                position: 'right',
                labels: { color: colors.text, font: { size: 11, family: "'Segoe UI', sans-serif" }, padding: 12, boxWidth: 12, boxHeight: 12, usePointStyle: true }
              },
              tooltip: {
                backgroundColor: colors.tooltipBg,
                titleColor: colors.text,
                bodyColor: colors.text,
                borderColor: colors.tooltipBorder,
                borderWidth: 1,
                padding: 12,
                boxPadding: 6,
                titleFont: { size: 12, weight: '600', family: "'Segoe UI', sans-serif" },
                bodyFont: { size: 11, family: "'Segoe UI', sans-serif" }
              },
              datalabels: {
                color: '#ffffff',
                font: { size: 12, weight: '700', family: "'Segoe UI', sans-serif" },
                formatter: (value, context) => {
                  const total = context.dataset.data.reduce((a, b) => a + b, 0);
                  const percentage = ((value / total) * 100).toFixed(1);
                  return value > 0 ? percentage + '%' : '';
                }
              }
            }
          }
        });
      }
      END REMOVED */

      // ===== NEW 3-LEVEL DRILL-DOWN CHART =====
      // Global state management (outside initializeCharts to persist across theme changes)
      if (typeof window.drillDownState === 'undefined') {
        window.drillDownState = {
          level: 1,
          currentLine: '',
          currentLocation: '',
          chart: null
        };
      }
      
      const ctxDrillDown = document.getElementById('chartEquipmentDrillDown');
      if (ctxDrillDown) {
        
        // Function to update breadcrumb navigation
        function updateBreadcrumb() {
          const breadcrumb = document.getElementById('breadcrumbNav');
          const isDark = document.documentElement.classList.contains('theme-dark') || 
                         document.documentElement.getAttribute('data-theme') === 'dark' ||
                         !document.documentElement.classList.contains('theme-light');
          const linkColor = isDark ? '#e2e8f0' : '#6b7280';  // Very light in dark mode for better visibility
          const linkHoverColor = isDark ? '#ffffff' : '#374151';  // White on hover in dark mode
          const activeColor = isDark ? '#ffffff' : '#1f2937';  // White for active item in dark mode
          const separatorColor = isDark ? '#94a3b8' : '#9ca3b8';  // Lighter separator in dark mode
          
          let html = '';
          
          // Using Unicode character directly instead of HTML entity
          const separator = '\u203A';  // RIGHT-POINTING ANGLE QUOTATION MARK (›)
          
          if (window.drillDownState.level === 1) {
            html = `<span style="color: ${activeColor}; font-weight: 600; font-size: 12px;">Equipment by Line</span>`;
          } else if (window.drillDownState.level === 2) {
            html = `
              <a href="#" onclick="navigateToLevel(1); return false;" 
                 style="color: ${linkColor}; text-decoration: none; font-weight: 500; font-size: 12px; transition: color 0.2s ease;"
                 onmouseover="this.style.color='${linkHoverColor}'; this.style.textDecoration='underline';" 
                 onmouseout="this.style.color='${linkColor}'; this.style.textDecoration='none';">Lines</a>
              <span style="color: ${separatorColor}; margin: 0 6px; font-size: 12px;">${separator}</span>
              <span style="color: ${activeColor}; font-weight: 600; font-size: 12px;">${window.drillDownState.currentLine}</span>
            `;
          } else if (window.drillDownState.level === 3) {
            html = `
              <a href="#" onclick="navigateToLevel(1); return false;" 
                 style="color: ${linkColor}; text-decoration: none; font-weight: 500; font-size: 12px; transition: color 0.2s ease;"
                 onmouseover="this.style.color='${linkHoverColor}'; this.style.textDecoration='underline';" 
                 onmouseout="this.style.color='${linkColor}'; this.style.textDecoration='none';">Lines</a>
              <span style="color: ${separatorColor}; margin: 0 6px; font-size: 12px;">${separator}</span>
              <a href="#" onclick="navigateToLevel(2); return false;" 
                 style="color: ${linkColor}; text-decoration: none; font-weight: 500; font-size: 12px; transition: color 0.2s ease;"
                 onmouseover="this.style.color='${linkHoverColor}'; this.style.textDecoration='underline';" 
                 onmouseout="this.style.color='${linkColor}'; this.style.textDecoration='none';">${window.drillDownState.currentLine}</a>
              <span style="color: ${separatorColor}; margin: 0 6px; font-size: 12px;">${separator}</span>
              <span style="color: ${activeColor}; font-weight: 600; font-size: 12px;">${window.drillDownState.currentLocation}</span>
            `;
          }
          
          breadcrumb.innerHTML = html;
        }
        
        // Function to render chart
        function renderDrillDownChart(labels, datasets, clickable = true) {
          console.log('renderDrillDownChart called with clickable:', clickable, 'level:', window.drillDownState.level);
          
          // Destroy existing chart first
          if (window.drillDownState.chart) {
            try {
              window.drillDownState.chart.destroy();
              window.drillDownState.chart = null;
            } catch (e) {
              console.error('Error destroying chart:', e);
            }
          }
          
          // Validate data
          if (!labels || labels.length === 0 || !datasets || datasets.length === 0) {
            console.warn('No data to render');
            return;
          }
          
          console.log('Creating chart with', labels.length, 'labels');
          
          // Calculate totals
          const totals = labels.map((label, idx) => {
            return datasets.reduce((sum, dataset) => sum + (dataset.data[idx] || 0), 0);
          });
          
          window.drillDownState.chart = new Chart(ctxDrillDown, {
            type: 'bar',
            data: {
              labels: labels,
              datasets: datasets
            },
            options: {
              indexAxis: 'y',
              responsive: true,
              maintainAspectRatio: false,
              onClick: clickable ? function(event, activeElements) {
                console.log('Chart onClick fired! activeElements:', activeElements, 'level:', window.drillDownState.level);
                if (activeElements && activeElements.length > 0) {
                  const index = activeElements[0].index;
                  const clickedLabel = labels[index];
                  console.log('Clicked on:', clickedLabel, 'at index:', index);
                  
                  if (window.drillDownState.level === 1) {
                    // Drill into line → show locations
                    console.log('Drilling into line:', clickedLabel);
                    window.drillDownState.currentLine = clickedLabel;
                    window.drillDownState.level = 2;
                    updateBreadcrumb();
                    fetchLocationsByLine(clickedLabel);
                  } else if (window.drillDownState.level === 2) {
                    // Drill into location → show equipment IDs
                    console.log('Drilling into location:', clickedLabel);
                    window.drillDownState.currentLocation = clickedLabel;
                    window.drillDownState.level = 3;
                    updateBreadcrumb();
                    fetchEquipmentByLineAndLocation(window.drillDownState.currentLine, clickedLabel);
                  }
                } else {
                  console.log('No active elements or wrong level');
                }
              } : null,
              plugins: {
                legend: { 
                  display: true,
                  position: 'top',
                  labels: { 
                    color: colors.text, 
                    font: { size: 11, family: "'Segoe UI', sans-serif" }, 
                    padding: 12, 
                    boxWidth: 12, 
                    boxHeight: 12, 
                    usePointStyle: true 
                  }
                },
                tooltip: {
                  backgroundColor: colors.tooltipBg,
                  titleColor: colors.text,
                  bodyColor: colors.text,
                  borderColor: colors.tooltipBorder,
                  borderWidth: 1,
                  padding: 12,
                  boxPadding: 6,
                  titleFont: { size: 12, weight: '600', family: "'Segoe UI', sans-serif" },
                  bodyFont: { size: 11, family: "'Segoe UI', sans-serif" }
                },
                datalabels: {
                  display: false
                }
              },
              scales: {
                x: {
                  stacked: true,
                  beginAtZero: true,
                  ticks: { 
                    precision: 0, 
                    color: colors.textSecondary, 
                    font: { size: 11, family: "'Segoe UI', sans-serif" } 
                  },
                  grid: { 
                    display: true,
                    color: colors.isDark ? 'rgba(255, 255, 255, 0.05)' : 'rgba(0, 0, 0, 0.05)',
                    drawBorder: false
                  },
                  border: {
                    display: false
                  }
                },
                y: {
                  stacked: true,
                  ticks: { 
                    color: colors.isDark ? '#e2e8f0' : '#1e293b',  // Brighter in dark mode for better visibility
                    font: { size: 11, family: "'Segoe UI', sans-serif" } 
                  },
                  grid: { 
                    display: false 
                  },
                  border: {
                    display: false
                  }
                }
              },
              layout: {
                padding: {
                  right: 40
                }
              },
              animation: {
                onComplete: function() {
                  const chart = this;
                  const ctx = chart.ctx;
                  
                  // Check if chart has been destroyed or data is invalid
                  if (!chart || !chart.data || !chart.data.labels || chart.data.labels.length === 0) {
                    return;
                  }
                  
                  // Smaller, non-bold font for data labels
                  ctx.font = "11px 'Segoe UI', sans-serif";
                  ctx.fillStyle = colors.textSecondary;
                  ctx.textAlign = 'left';
                  ctx.textBaseline = 'middle';
                  
                  chart.data.labels.forEach((label, index) => {
                    const meta = chart.getDatasetMeta(0);
                    if (!meta || !meta.data || !meta.data[index]) {
                      return; // Skip if metadata not ready
                    }
                    
                    const bar = meta.data[index];
                    const total = totals[index];
                    
                    let xPos = chart.scales.x.left;
                    chart.data.datasets.forEach(dataset => {
                      xPos += chart.scales.x.getPixelForValue(dataset.data[index] || 0) - chart.scales.x.left;
                    });
                    
                    ctx.fillText(total.toString(), xPos + 5, bar.y);
                  });
                }
              }
            }
          });
        }
        
        // Fetch functions
        function fetchEquipmentByLine() {
          fetch('EquipmentInventoryDashboard.aspx/GetEquipmentByLine', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' }
          })
          .then(response => response.json())
          .then(data => {
            console.log('GetEquipmentByLine response:', data);
            const result = JSON.parse(data.d);
            console.log('Parsed result:', result);
            console.log('Labels:', result.labels);
            console.log('Datasets:', result.datasets);
            renderDrillDownChart(result.labels, result.datasets, true);
          })
          .catch(error => {
            console.error('Error fetching equipment by line:', error);
          });
        }
        
        function fetchLocationsByLine(line) {
          console.log('fetchLocationsByLine called with line:', line);
          fetch('EquipmentInventoryDashboard.aspx/GetLocationsByLine', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ line: line })
          })
          .then(response => response.json())
          .then(data => {
            console.log('GetLocationsByLine response:', data);
            const result = JSON.parse(data.d);
            console.log('Parsed result:', result);
            console.log('Labels:', result.labels);
            console.log('Datasets:', result.datasets);
            renderDrillDownChart(result.labels, result.datasets, true);
          })
          .catch(error => {
            console.error('Error fetching locations by line:', error);
          });
        }
        
        function fetchEquipmentByLineAndLocation(line, location) {
          console.log('fetchEquipmentByLineAndLocation called with line:', line, 'location:', location);
          fetch('EquipmentInventoryDashboard.aspx/GetEquipmentByLineAndLocation', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ line: line, location: location })
          })
          .then(response => response.json())
          .then(data => {
            console.log('GetEquipmentByLineAndLocation response:', data);
            const result = JSON.parse(data.d);
            console.log('Parsed result:', result);
            console.log('Labels:', result.labels);
            console.log('Datasets:', result.datasets);
            if (result.error) {
              console.error('Server error:', result.error);
            }
            renderDrillDownChart(result.labels, result.datasets, false);  // No more drilling
          })
          .catch(error => {
            console.error('Error fetching equipment by line and location:', error);
          });
        }
        
        // Navigation function (global scope for breadcrumb clicks)
        window.navigateToLevel = function(level) {
          window.drillDownState.level = level;
          
          if (level === 1) {
            window.drillDownState.currentLine = '';
            window.drillDownState.currentLocation = '';
            updateBreadcrumb();
            fetchEquipmentByLine();
          } else if (level === 2) {
            window.drillDownState.currentLocation = '';
            updateBreadcrumb();
            fetchLocationsByLine(window.drillDownState.currentLine);
          }
        };
        
        // Initialize chart only if not already initialized
        if (!window.drillDownState.chart) {
          updateBreadcrumb();
          fetchEquipmentByLine();
        } else {
          // On theme change, update breadcrumb and re-render the current chart with new colors
          updateBreadcrumb();
          
          // Re-fetch data to re-render chart with new theme colors
          if (window.drillDownState.level === 1) {
            fetchEquipmentByLine();
          } else if (window.drillDownState.level === 2) {
            fetchLocationsByLine(window.drillDownState.currentLine);
          } else if (window.drillDownState.level === 3) {
            fetchEquipmentByLineAndLocation(window.drillDownState.currentLine, window.drillDownState.currentLocation);
          }
        }
      }

    // ===== SANKEY DIAGRAM FUNCTION =====
    function initializeSankeyDiagram(colors) {
      const svg = d3.select('#sankeyDiagram');
      svg.selectAll('*').remove(); // Clear previous render
      
      const container = document.querySelector('#sankeyDiagram').parentElement;
      const width = container.clientWidth;
      const height = container.clientHeight;
      
      // Parse data from server
      const sankeyData = <%= SankeyData %>;
      
      if (!sankeyData || !sankeyData.nodes || sankeyData.nodes.length === 0) {
        svg.append('text')
          .attr('x', width / 2)
          .attr('y', height / 2)
          .attr('text-anchor', 'middle')
          .attr('fill', colors.textSecondary)
          .style('font-family', "'Segoe UI', system-ui, sans-serif")
          .style('font-size', '14px')
          .text('No equipment data available');
        return;
      }
      
      // Define enhanced color mapping for equipment types and statuses (dark mode optimized)
      const equipmentColors = {
        'Total Equipment': colors.isDark ? '#60a5fa' : colors.primary,  // Brighter blue in dark mode
        'ATE': colors.isDark ? '#60a5fa' : colors.primary,               // Brighter blue
        'Asset': colors.isDark ? '#34d399' : colors.success,             // Brighter green
        'Fixture': colors.isDark ? '#c084fc' : colors.purple,            // Brighter purple
        'Harness': colors.isDark ? '#fbbf24' : colors.warning,           // Brighter orange/yellow
        'In Use': colors.isDark ? '#34d399' : colors.success,            // Brighter green for In Use
        'Spare': colors.isDark ? '#60a5fa' : colors.primary,             // Brighter blue for Spare
        'Out of Service - Under Repair': colors.isDark ? '#f87171' : colors.danger,  // Brighter red
        'Out of Service - Damaged': colors.isDark ? '#f87171' : colors.danger,
        'Out of Service - In Calibration': colors.isDark ? '#f87171' : colors.danger,
        'Inactive': colors.isDark ? '#9ca3af' : colors.textSecondary,    // Lighter gray
        'Scraped': colors.isDark ? '#9ca3af' : colors.textSecondary,
        'Scraped / Returned to vendor': colors.isDark ? '#9ca3af' : colors.textSecondary
      };
      
      // Custom sort order for nodes
      const nodeOrder = {
        'Total Equipment': 0,
        'In Use': 1,
        'Spare': 2,
        'Out of Service - Under Repair': 3,
        'Out of Service - Damaged': 4,
        'Out of Service - In Calibration': 5,
        'Inactive': 6,
        'Asset': 10,
        'ATE': 11,
        'Fixture': 12,
        'Harness': 13
      };
      
      // Get node color based on type
      function getNodeColor(node) {
        // Check if it's a named equipment type or status
        if (equipmentColors[node.name]) {
          return equipmentColors[node.name];
        }
        // Lines (last level) use gray
        return colors.textSecondary;
      }
      
      // Create Sankey layout with left alignment and custom sort
      const sankey = d3.sankey()
        .nodeWidth(20)
        .nodePadding(12)
        .nodeAlign(d3.sankeyLeft)
        .nodeSort((a, b) => {
          // Sort by custom order if defined, otherwise alphabetically
          const orderA = nodeOrder[a.name] !== undefined ? nodeOrder[a.name] : 999;
          const orderB = nodeOrder[b.name] !== undefined ? nodeOrder[b.name] : 999;
          return orderA - orderB;
        })
        .extent([[50, 10], [width - 50, height - 10]]);
      
      const graph = sankey({
        nodes: sankeyData.nodes.map(d => Object.assign({}, d)),
        links: sankeyData.links.map(d => Object.assign({}, d))
      });
      
      // Create gradients for each link
      const defs = svg.append('defs');
      
      graph.links.forEach((link, i) => {
        const gradient = defs.append('linearGradient')
          .attr('id', 'gradient-' + i)
          .attr('gradientUnits', 'userSpaceOnUse')
          .attr('x1', link.source.x1)
          .attr('x2', link.target.x0);
        
        // Check if source is Equipment Type (ATE, Asset, Fixture, Harness) and target is Line
        const isEquipmentToLine = ['ATE', 'Asset', 'Fixture', 'Harness'].includes(link.source.name);
        
        // Higher opacity in dark mode for better visibility
        const startOpacity = colors.isDark ? 0.5 : 0.35;
        const endOpacity = colors.isDark ? (isEquipmentToLine ? 0.45 : 0.5) : (isEquipmentToLine ? 0.32 : 0.35);
        
        gradient.append('stop')
          .attr('offset', '0%')
          .attr('stop-color', getNodeColor(link.source))
          .attr('stop-opacity', startOpacity);
        
        gradient.append('stop')
          .attr('offset', '100%')
          .attr('stop-color', isEquipmentToLine ? getNodeColor(link.source) : getNodeColor(link.target))
          .attr('stop-opacity', endOpacity);
      });
      
      // Draw links with gradient colors
      const linkGroup = svg.append('g')
        .attr('class', 'links')
        .attr('fill', 'none');
        
      linkGroup.selectAll('path')
        .data(graph.links)
        .join('path')
        .attr('d', d3.sankeyLinkHorizontal())
        .attr('stroke', (d, i) => 'url(#gradient-' + i + ')')
        .attr('stroke-width', d => Math.max(1, d.width))
        .style('mix-blend-mode', 'multiply')
        .attr('opacity', 0.5)
        .on('mouseover', function(event, d) {
          d3.select(this)
            .attr('opacity', 0.8)
            .attr('stroke-width', d => Math.max(1, d.width) + 2);
          
          const tooltip = d3.select('body').append('div')
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
      const nodeGroup = svg.append('g')
        .attr('class', 'nodes');
        
      const nodes = nodeGroup.selectAll('rect')
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
          d3.select(this)
            .attr('fill', d3.color(getNodeColor(d)).brighter(0.3));
          
          // Calculate total equipment for node
          const totalIn = d3.sum(d.targetLinks, l => l.value);
          const totalOut = d3.sum(d.sourceLinks, l => l.value);
          const total = Math.max(totalIn, totalOut);
          
          const tooltip = d3.select('body').append('div')
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
      const labelGroup = svg.append('g')
        .attr('class', 'labels');
        
      labelGroup.selectAll('text')
        .data(graph.nodes)
        .join('text')
        .attr('x', d => d.x0 < width / 2 ? d.x1 + 8 : d.x0 - 8)
        .attr('y', d => (d.y1 + d.y0) / 2)
        .attr('dy', '0.35em')
        .attr('text-anchor', d => d.x0 < width / 2 ? 'start' : 'end')
        .attr('fill', colors.isDark ? '#e5e7eb' : colors.text)  // Brighter in dark mode
        .style('font-family', "'Segoe UI', system-ui, sans-serif")
        .style('font-size', d => {
          // Smaller fonts for better readability
          if (d.name === 'Total Equipment') return '11px';
          if (['ATE', 'Asset', 'Fixture', 'Harness'].includes(d.name)) return '10px';
          if (['In Use', 'Spare', 'Out of Service - Under Repair', 'Out of Service - Damaged', 
               'Out of Service - In Calibration', 'Inactive', 'Scraped'].includes(d.name)) return '10px';
          return '9px';  // Lines and other nodes
        })
        .style('font-weight', d => {
          if (d.name === 'Total Equipment') return '600';  // Semibold for top level
          if (['ATE', 'Asset', 'Fixture', 'Harness'].includes(d.name)) return '500';  // Medium for types
          return '400';  // Normal weight for Sublines and Lines (more readable)
        })
        .style('letter-spacing', '0.3px')
        .text(d => {
          // Don't truncate important nodes, show full names for better clarity
          if (d.name === 'Total Equipment' || 
              ['ATE', 'Asset', 'Fixture', 'Harness'].includes(d.name)) {
            return d.name;
          }
          // For sublines and lines, allow longer text (25 chars instead of 20)
          if (d.name.length > 25) {
            return d.name.substring(0, 22) + '...';
          }
          return d.name;
        })
        .append('title')
        .text(d => d.name); // Full name on hover
      }

      // ===== HYBRID KPI MINI CHARTS =====
      
      // 1. Mini Bar Chart for Total Equipment (by equipment types)
      const ctxTotalEquipment = document.getElementById('miniBarTotalEquipment');
      if (ctxTotalEquipment) {
        const equipmentTypeLabels = <%= TypeLabels %>;
        const equipmentTypeData = <%= TypeData %>;
        
        chartInstances.miniBarTotalEquipment = new Chart(ctxTotalEquipment, {
          type: 'bar',
          data: {
            labels: equipmentTypeLabels,
            datasets: [{
              data: equipmentTypeData,
              backgroundColor: function(context) {
                const label = context.chart.data.labels[context.dataIndex];
                if (label === 'Asset') return colors.success;
                if (label === 'ATE') return colors.primary;
                if (label === 'Fixture') return colors.purple;
                if (label === 'Harness') return colors.warning;
                return colors.textSecondary;
              },
              borderWidth: 0,
              borderRadius: 8,
              maxBarThickness: 20
            }]
          },
          options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
              legend: { display: false },
              tooltip: {
                enabled: true,
                backgroundColor: colors.tooltipBg,
                titleColor: colors.text,
                bodyColor: colors.text,
                borderColor: colors.tooltipBorder,
                borderWidth: 1,
                padding: 8,
                displayColors: false,
                titleFont: { size: 11, weight: '600', family: "'Segoe UI', sans-serif" },
                bodyFont: { size: 10, family: "'Segoe UI', sans-serif" },
                callbacks: {
                  title: function(context) {
                    return context[0].label + ' Equipment';
                  },
                  label: function(context) {
                    return 'Count: ' + context.parsed.y;
                  }
                }
              },
              datalabels: { display: false }
            },
            scales: {
              x: { display: false },
              y: { 
                display: false,
                max: Math.max(...equipmentTypeData) * 1.05
              }
            },
            layout: { padding: 0 }
          }
        });
      }
      
      // 2. Utilization Gauge for Active Equipment
      const ctxUtilization = document.getElementById('gaugeUtilization');
      if (ctxUtilization) {
        const utilizationPercent = parseFloat('<%= UtilizationPercent %>') || 0;
        
        chartInstances.gaugeUtilization = new Chart(ctxUtilization, {
          type: 'doughnut',
          data: {
            datasets: [{
              data: [utilizationPercent, 100 - utilizationPercent],
              backgroundColor: [
                utilizationPercent > 80 ? colors.danger : utilizationPercent > 60 ? colors.warning : colors.success,
                colors.isDark ? 'rgba(255,255,255,0.15)' : 'rgba(0,0,0,0.12)'
              ],
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
              tooltip: {
                enabled: false,
                external: function(context) {
                  let tooltipEl = document.getElementById('chartjs-tooltip-utilization');
                  
                  if (!tooltipEl) {
                    tooltipEl = document.createElement('div');
                    tooltipEl.id = 'chartjs-tooltip-utilization';
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
                  
                  if (tooltipModel.body && tooltipModel.dataPoints && tooltipModel.dataPoints[0].dataIndex === 0) {
                    const titleLines = ['Utilization Rate'];
                    const bodyLines = ['Active: ' + utilizationPercent.toFixed(1) + '%'];
                    
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
      
      // 3. Bullet Chart for Calibration Due
      const ctxCalibrationDue = document.getElementById('bulletChartCalibrationDue');
      if (ctxCalibrationDue) {
        const calOverdue = parseInt('<%= CalibrationOverdue %>') || 0;
        const calDueSoon = parseInt('<%= CalibrationDueSoon %>') || 0;
        const totalCalDue = calOverdue + calDueSoon;
        
        chartInstances.bulletChartCalibrationDue = new Chart(ctxCalibrationDue, {
          type: 'bar',
          data: {
            labels: [''],
            datasets: [
              {
                label: 'Total Due',
                data: [totalCalDue],
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
                data: [calOverdue],
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
                enabled: true,
                backgroundColor: colors.tooltipBg,
                titleColor: colors.text,
                bodyColor: colors.text,
                borderColor: colors.tooltipBorder,
                borderWidth: 1,
                padding: 8,
                displayColors: false,
                titleFont: { size: 11, weight: '600', family: "'Segoe UI', sans-serif" },
                bodyFont: { size: 10, family: "'Segoe UI', sans-serif" },
                callbacks: {
                  title: function() {
                    return 'Calibration Due';
                  },
                  label: function(context) {
                    if (context.datasetIndex === 1) {
                      return 'Overdue: ' + calOverdue;
                    }
                    return 'Total Due: ' + totalCalDue;
                  }
                }
              },
              datalabels: { display: false }
            },
            scales: {
              x: { 
                stacked: false,
                display: false,
                max: totalCalDue > 0 ? totalCalDue : 10
              },
              y: { 
                stacked: false,
                display: false 
              }
            },
            layout: { padding: 0 }
          },
          plugins: [{
            id: 'overlayBars',
            beforeDatasetsDraw(chart) {
              const meta0 = chart.getDatasetMeta(0);
              const meta1 = chart.getDatasetMeta(1);
              
              if (meta0.data.length && meta1.data.length) {
                // Force both bars to the same Y position (centered)
                const yCenter = (chart.chartArea.top + chart.chartArea.bottom) / 2;
                meta0.data[0].y = yCenter;
                meta1.data[0].y = yCenter;
              }
            }
          }]
        });
      }
      
      // 4. Bullet Chart for PM Due
      const ctxPMDue = document.getElementById('bulletChartPMDue');
      if (ctxPMDue) {
        const pmOverdue = parseInt('<%= PMOverdue %>') || 0;
        const pmDueSoon = parseInt('<%= PMDueSoon %>') || 0;
        const totalPMDue = pmOverdue + pmDueSoon;
        
        chartInstances.bulletChartPMDue = new Chart(ctxPMDue, {
          type: 'bar',
          data: {
            labels: [''],
            datasets: [
              {
                label: 'Total Due',
                data: [totalPMDue],
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
                data: [pmOverdue],
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
                enabled: true,
                backgroundColor: colors.tooltipBg,
                titleColor: colors.text,
                bodyColor: colors.text,
                borderColor: colors.tooltipBorder,
                borderWidth: 1,
                padding: 8,
                displayColors: false,
                titleFont: { size: 11, weight: '600', family: "'Segoe UI', sans-serif" },
                bodyFont: { size: 10, family: "'Segoe UI', sans-serif" },
                callbacks: {
                  title: function() {
                    return 'PM Due';
                  },
                  label: function(context) {
                    if (context.datasetIndex === 1) {
                      return 'Overdue: ' + pmOverdue;
                    }
                    return 'Total Due: ' + totalPMDue;
                  }
                }
              },
              datalabels: { display: false }
            },
            scales: {
              x: { 
                stacked: false,
                display: false,
                max: totalPMDue > 0 ? totalPMDue : 10
              },
              y: { 
                stacked: false,
                display: false 
              }
            },
            layout: { padding: 0 }
          },
          plugins: [{
            id: 'overlayBars',
            beforeDatasetsDraw(chart) {
              const meta0 = chart.getDatasetMeta(0);
              const meta1 = chart.getDatasetMeta(1);
              
              if (meta0.data.length && meta1.data.length) {
                // Force both bars to the same Y position (centered)
                const yCenter = (chart.chartArea.top + chart.chartArea.bottom) / 2;
                meta0.data[0].y = yCenter;
                meta1.data[0].y = yCenter;
              }
            }
          }]
        });
      }
      
      // 5. Mini Bar Chart for Spares (by equipment types)
      const ctxSpares = document.getElementById('miniBarSpares');
      if (ctxSpares) {
        const sparesTypeLabels = <%= SparesTypeLabels %>;
        const sparesTypeData = <%= SparesTypeData %>;
        
        chartInstances.miniBarSpares = new Chart(ctxSpares, {
          type: 'bar',
          data: {
            labels: sparesTypeLabels,
            datasets: [{
              data: sparesTypeData,
              backgroundColor: function(context) {
                const label = context.chart.data.labels[context.dataIndex];
                if (label === 'Asset') return colors.success;
                if (label === 'ATE') return colors.primary;
                if (label === 'Fixture') return colors.purple;
                if (label === 'Harness') return colors.warning;
                return colors.textSecondary;
              },
              borderWidth: 0,
              borderRadius: 8,
              maxBarThickness: 20
            }]
          },
          options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
              legend: { display: false },
              tooltip: {
                enabled: true,
                backgroundColor: colors.tooltipBg,
                titleColor: colors.text,
                bodyColor: colors.text,
                borderColor: colors.tooltipBorder,
                borderWidth: 1,
                padding: 8,
                displayColors: false,
                titleFont: { size: 11, weight: '600', family: "'Segoe UI', sans-serif" },
                bodyFont: { size: 10, family: "'Segoe UI', sans-serif" },
                callbacks: {
                  title: function(context) {
                    return context[0].label + ' Spares';
                  },
                  label: function(context) {
                    return 'Count: ' + context.parsed.y;
                  }
                }
              },
              datalabels: { display: false }
            },
            scales: {
              x: { display: false },
              y: { 
                display: false,
                max: Math.max(...sparesTypeData) * 1.05
              }
            },
            layout: { padding: 0 }
          }
        });
      }
    }

    // Initialize charts on page load
    document.addEventListener('DOMContentLoaded', function() {
      updateChartTitleColors();
      initializeCharts();
    });

    // Function to update chart title colors immediately
    function updateChartTitleColors() {
      const isDark = document.documentElement.classList.contains('theme-dark') || 
                     document.documentElement.getAttribute('data-theme') === 'dark' ||
                     !document.documentElement.classList.contains('theme-light');
      
      const chartTitles = document.querySelectorAll('.chart-title');
      chartTitles.forEach(title => {
        title.style.color = isDark ? '#f1f5f9' : '#0f172a';
      });
    }

    // Reinitialize charts on theme change
    const themeObserver = new MutationObserver(function(mutations) {
      mutations.forEach(function(mutation) {
        if (mutation.type === 'attributes' && 
            (mutation.attributeName === 'class' || mutation.attributeName === 'data-theme')) {
          updateChartTitleColors();
          setTimeout(initializeCharts, 50);
        }
      });
    });

    themeObserver.observe(document.documentElement, {
      attributes: true,
      attributeFilter: ['class', 'data-theme']
    });

    // Navigation Modal Functions (matching PM Dashboard style)
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

    // KPI Modal Functions
    function showKPIModal(cardType) {
      // Prevent event bubbling to child elements (canvas clicks)
      event.stopPropagation();
      
      let title = '';
      let description = '';
      let icon = '';
      let color = '';
      let targetUrl = '';

      switch(cardType) {
        case 'total':
          title = 'Total Equipment Details';
          description = 'View comprehensive breakdown of all equipment inventory across all types: Assets, ATE, Fixtures, and Harnesses.';
          color = '#2563eb';
          icon = `<svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <rect x="3" y="3" width="7" height="7"></rect>
            <rect x="14" y="3" width="7" height="7"></rect>
            <rect x="14" y="14" width="7" height="7"></rect>
            <rect x="3" y="14" width="7" height="7"></rect>
          </svg>`;
          targetUrl = 'EquipmentGridView.aspx?collapsed=true';
          break;
        case 'active':
          title = 'Active Equipment Details';
          description = 'View all active equipment currently in use. The gauge shows utilization rate (Active/Total). Track equipment operational status.';
          color = '#10b981';
          icon = `<svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <polyline points="22 12 18 12 15 21 9 3 6 12 2 12"></polyline>
          </svg>`;
          targetUrl = 'EquipmentGridView.aspx?status=In%20Use&collapsed=true';
          break;
        case 'calibration':
          title = 'Calibration Due Details';
          description = 'View equipment requiring calibration attention. Red indicates overdue, yellow indicates due within 30 days.';
          color = '#f59e0b';
          icon = `<svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <line x1="4" y1="21" x2="4" y2="14"></line>
            <line x1="4" y1="10" x2="4" y2="3"></line>
            <line x1="12" y1="21" x2="12" y2="12"></line>
            <line x1="12" y1="8" x2="12" y2="3"></line>
            <line x1="20" y1="21" x2="20" y2="16"></line>
            <line x1="20" y1="12" x2="20" y2="3"></line>
            <line x1="1" y1="14" x2="7" y2="14"></line>
            <line x1="9" y1="8" x2="15" y2="8"></line>
            <line x1="17" y1="16" x2="23" y2="16"></line>
          </svg>`;
          targetUrl = 'CalibrationGridView.aspx?collapsed=true';
          break;
        case 'pm':
          title = 'PM Due Details';
          description = 'View equipment requiring preventive maintenance. Red indicates overdue PMs, yellow indicates PMs due within 30 days.';
          color = '#8b5cf6';
          icon = `<svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <rect x="3" y="4" width="18" height="18" rx="2"></rect>
            <line x1="16" y1="2" x2="16" y2="6"></line>
            <line x1="8" y1="2" x2="8" y2="6"></line>
            <line x1="3" y1="10" x2="21" y2="10"></line>
            <path d="M9 16l2 2 4-4"></path>
          </svg>`;
          targetUrl = 'PMGridView.aspx?collapsed=true';
          break;
        case 'spares':
          title = 'Spare Equipment Details';
          description = 'View available spare equipment inventory. Spares are backup units ready for deployment when primary equipment fails.';
          color = '#2563eb';
          icon = `<svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M3 10l9-6 9 6"></path>
            <path d="M5 10v10h14V10"></path>
            <path d="M9 20v-6h6v6"></path>
          </svg>`;
          targetUrl = 'EquipmentGridView.aspx?status=Spare&collapsed=true';
          break;
      }

      // Create modal backdrop
      const modalBackdrop = document.createElement('div');
      modalBackdrop.id = 'kpiModalBackdrop';
      modalBackdrop.style.cssText = `
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(0, 0, 0, 0.5);
        backdrop-filter: blur(4px);
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 10000;
        animation: fadeIn 0.2s ease;
      `;

      // Get theme colors
      const isDark = document.documentElement.classList.contains('theme-dark') || 
                     document.documentElement.getAttribute('data-theme') === 'dark';
      const bgColor = isDark ? '#1e293b' : '#ffffff';
      const textColor = isDark ? '#f1f5f9' : '#1e293b';
      const borderColor = isDark ? 'rgba(255,255,255,0.1)' : 'rgba(0,0,0,0.1)';
      const secondaryText = isDark ? '#94a3b8' : '#64748b';

      // Create modal content
      const modalContent = document.createElement('div');
      modalContent.style.cssText = `
        background: ${bgColor};
        border-radius: 12px;
        padding: 32px;
        max-width: 480px;
        width: 90%;
        box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
        border: 1px solid ${borderColor};
        animation: slideUp 0.3s ease;
        position: relative;
      `;

      modalContent.innerHTML = `
        <div style="text-align: center;">
          <div style="
            width: 64px;
            height: 64px;
            background: linear-gradient(135deg, ${color}, ${adjustColor(color, -20)});
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 20px;
            box-shadow: 0 8px 24px ${color}40;
          ">
            ${icon}
          </div>
          <h3 style="
            margin: 0 0 12px 0;
            font-size: 24px;
            font-weight: 700;
            color: ${textColor};
            font-family: 'Segoe UI', sans-serif;
          ">${title}</h3>
          <p style="
            margin: 0 0 28px 0;
            font-size: 14px;
            color: ${secondaryText};
            line-height: 1.5;
          ">${description}</p>
          <div style="display: flex; gap: 12px; justify-content: center;">
            <button onclick="navigateToGridView('${targetUrl}')" style="
              background: linear-gradient(135deg, ${color}, ${adjustColor(color, -20)});
              color: white;
              border: none;
              padding: 12px 32px;
              border-radius: 8px;
              font-size: 14px;
              font-weight: 600;
              cursor: pointer;
              transition: all 0.2s ease;
              box-shadow: 0 4px 12px ${color}40;
              font-family: 'Segoe UI', sans-serif;
            " onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 6px 16px ${color}50';" 
               onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 4px 12px ${color}40';">
              Yes, Open Grid View
            </button>
            <button onclick="closeKPIModal()" style="
              background: ${isDark ? 'rgba(255,255,255,0.08)' : 'rgba(0,0,0,0.05)'};
              color: ${textColor};
              border: 1px solid ${borderColor};
              padding: 12px 32px;
              border-radius: 8px;
              font-size: 14px;
              font-weight: 600;
              cursor: pointer;
              transition: all 0.2s ease;
              font-family: 'Segoe UI', sans-serif;
            " onmouseover="this.style.background='${isDark ? 'rgba(255,255,255,0.12)' : 'rgba(0,0,0,0.08)'}';" 
               onmouseout="this.style.background='${isDark ? 'rgba(255,255,255,0.08)' : 'rgba(0,0,0,0.05)'}';">
              Cancel
            </button>
          </div>
        </div>
      `;

      modalBackdrop.appendChild(modalContent);
      document.body.appendChild(modalBackdrop);

      // Add CSS animations if not already present
      if (!document.getElementById('kpiModalStyles')) {
        const style = document.createElement('style');
        style.id = 'kpiModalStyles';
        style.textContent = `
          @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
          }
          @keyframes slideUp {
            from { transform: translateY(20px); opacity: 0; }
            to { transform: translateY(0); opacity: 1; }
          }
        `;
        document.head.appendChild(style);
      }

      // Close on backdrop click
      modalBackdrop.addEventListener('click', function(e) {
        if (e.target === modalBackdrop) {
          closeKPIModal();
        }
      });

      // Close on Escape key
      document.addEventListener('keydown', function escHandler(e) {
        if (e.key === 'Escape') {
          closeKPIModal();
          document.removeEventListener('keydown', escHandler);
        }
      });
    }

    function closeKPIModal() {
      const modal = document.getElementById('kpiModalBackdrop');
      if (modal) {
        modal.style.animation = 'fadeOut 0.2s ease';
        setTimeout(() => modal.remove(), 200);
      }
    }

    function navigateToGridView(url) {
      window.location.href = url;
    }

    function adjustColor(color, amount) {
      const clamp = (val) => Math.min(Math.max(val, 0), 255);
      const num = parseInt(color.replace('#', ''), 16);
      const r = clamp((num >> 16) + amount);
      const g = clamp(((num >> 8) & 0x00FF) + amount);
      const b = clamp((num & 0x0000FF) + amount);
      return '#' + ((r << 16) | (g << 8) | b).toString(16).padStart(6, '0');
    }
  </script>
</asp:Content>
