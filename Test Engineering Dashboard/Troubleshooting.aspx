<%@ Page Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="Troubleshooting.aspx.cs" Inherits="TED_Troubleshooting" %>
<asp:Content ID="TroubleTitle" ContentPlaceHolderID="TitleContent" runat="server">Troubleshooting - Test Engineering</asp:Content>
<asp:Content ID="TroubleHead" ContentPlaceHolderID="HeadContent" runat="server">
  <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
  <style>
    /* Prevent page-level horizontal scroll and keep width constrained */
    html, body { max-width:100%; overflow-x:hidden; }
    :root { --sidebar-w: 280px; }
  .dash-shell { --col-btm-gap: 12px; display:grid; grid-template-columns: var(--sidebar-w) 1fr; gap:18px; height:calc(100dvh - var(--vh-offset)); padding:10px 18px 34px; box-sizing:border-box; }
  .dash-shell > * { min-width:0; min-height:0; }
  .dash-sidebar { position:sticky; top:12px; height:calc(100% - 12px - var(--col-btm-gap)); margin-bottom:var(--col-btm-gap); display:flex; flex-direction:column; background:rgba(25,29,37,.55); border:1px solid rgba(255,255,255,.08); border-radius:18px; box-shadow:0 16px 36px -10px rgba(0,0,0,.6), 0 0 0 1px rgba(255,255,255,.05), 0 0 10px rgba(235,235,240,.12); backdrop-filter:blur(40px) saturate(140%); padding:16px 14px; overflow:auto; }
    html.theme-light .dash-sidebar, html[data-theme='light'] .dash-sidebar { background:rgba(255,255,255,.7); border:1px solid rgba(0,0,0,.08); box-shadow:0 14px 34px -12px rgba(0,0,0,.25), 0 0 0 1px rgba(0,0,0,.05), 0 0 10px rgba(0,0,0,.12); }
    .sidebar-user { display:flex; align-items:center; gap:10px; padding:10px 8px 12px; border-bottom:1px solid rgba(255,255,255,.08); margin:0 6px 10px; }
    html.theme-light .sidebar-user, html[data-theme='light'] .sidebar-user { border-bottom:1px solid rgba(0,0,0,.08); }
    .user-meta { display:flex; flex-direction:column; line-height:1.1; font-size:11px; opacity:.85; }
    .nav { padding:8px 4px; overflow:visible; }
    .nav-title { font-size:11px; letter-spacing:.6px; opacity:.65; padding:12px 12px 6px; text-transform:uppercase; }
    .nav-list { list-style:none; margin:0; padding:0; }
    .nav-link { display:flex; align-items:center; gap:10px; padding:10px 12px; margin:2px 6px; border-radius:12px; text-decoration:none; color:inherit; border:1px solid transparent; transition:background .25s ease, color .25s ease, border-color .25s ease; font-size:13px; }
    .nav-link .icon { width:16px; height:16px; color:currentColor; opacity:.9; }
    .nav-link:hover { background:rgba(255,255,255,.08); border-color:rgba(255,255,255,.12); }
    html.theme-light .nav-link:hover, html[data-theme='light'] .nav-link:hover { background:rgba(0,0,0,.055); border-color:rgba(0,0,0,.10); }
    .nav-link.active { background:rgba(77,141,255,.13); border-color:rgba(77,141,255,.3); color:#bcd4ff; }
    html.theme-light .nav-link.active, html[data-theme='light'] .nav-link.active { background:#ffffff; border-color:rgba(77,141,255,.35); color:#1f2530; box-shadow:0 1px 0 rgba(255,255,255,.7) inset; }
    .nav-link.danger { color:#ff6b6b; border-color:transparent; }
    .nav-link.danger .icon { color:currentColor; }
    .nav-link.danger:hover { background:rgba(255,86,86,.14); border-color:rgba(255,86,86,.35); color:#ff8a8a; }
    html.theme-light .nav-link.danger, html[data-theme='light'] .nav-link.danger { color:#c62828; }
    html.theme-light .nav-link.danger:hover, html[data-theme='light'] .nav-link.danger:hover { background:rgba(198,40,40,.10); border-color:rgba(198,40,40,.35); color:#b71c1c; }
    /* Disabled-styled nav item (unbuilt features) */
    .nav-link.disabled { opacity:.45; cursor:not-allowed; pointer-events:none; color:#888; }
    .nav-link.disabled .icon { opacity:.5; }
    html.theme-light .nav-link.disabled, html[data-theme='light'] .nav-link.disabled { color:#999; opacity:.5; }
    .avatar { width:34px; height:34px; border-radius:50%; display:flex; align-items:center; justify-content:center; background:rgba(255,255,255,.1); border:1px solid rgba(255,255,255,.2); font-weight:700; }
    html.theme-light .avatar, html[data-theme='light'] .avatar { background:#f1f4f9; border:1px solid rgba(0,0,0,.12); color:#1b222b; }

  .dash-col { grid-column: 2 / 3; display:flex; flex-direction:column; gap:16px; min-width:0; height:100%; min-height:0; padding-bottom:var(--col-btm-gap); box-sizing:border-box; }
  .dash-main { background:transparent; border:none; border-radius:0; box-shadow:none; backdrop-filter:none; padding:0; overflow:hidden; display:flex; flex-direction:column; flex:1; min-height:0; }
    html.theme-light .dash-main, html[data-theme='light'] .dash-main { background:transparent; border:none; box-shadow:none; }
  .page-title-wrap { align-self:start; padding:0; }
  .page-title { font-size:22px; font-weight:800; letter-spacing:.2px; margin:0 0 6px; }

    /* Modern KPI Cards */
    .kpi-grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(240px,1fr)); gap:16px; margin-bottom:16px; }
    .kpi-card { position:relative; display:flex; flex-direction:column; padding:20px; border-radius:16px; 
      background:linear-gradient(135deg, rgba(255,255,255,.08), rgba(255,255,255,.04));
      border:1px solid rgba(255,255,255,.12);
      box-shadow:0 8px 24px -8px rgba(0,0,0,.35), 0 0 0 1px rgba(255,255,255,.05) inset;
      backdrop-filter:blur(20px) saturate(140%);
      transition:transform .2s ease, box-shadow .2s ease;
      cursor:pointer; }
    html.theme-light .kpi-card, html[data-theme='light'] .kpi-card {
      background:linear-gradient(135deg, #ffffff, #fafbfc);
      border:1px solid rgba(0,0,0,.10);
      box-shadow:0 4px 16px -4px rgba(0,0,0,.15), 0 1px 0 rgba(255,255,255,.8) inset; }
    .kpi-card:hover { transform:translateY(-2px); box-shadow:0 12px 32px -10px rgba(0,0,0,.45); }
    html.theme-light .kpi-card:hover, html[data-theme='light'] .kpi-card:hover { box-shadow:0 6px 20px -6px rgba(0,0,0,.22); }
    
    /* Status-based coloring for cards */
    .kpi-card.status-red { border-left:4px solid #ef4444; background:linear-gradient(135deg, rgba(239,68,68,.15), rgba(239,68,68,.05)); }
    .kpi-card.status-red .kpi-value { color:#fca5a5; }
    html.theme-light .kpi-card.status-red, html[data-theme='light'] .kpi-card.status-red { border-left:4px solid #ef4444; background:linear-gradient(135deg, #fff5f5, #ffffff); }
    html.theme-light .kpi-card.status-red .kpi-value, html[data-theme='light'] .kpi-card.status-red .kpi-value { color:#dc2626; }
    
    .kpi-card.status-amber { border-left:4px solid #f59e0b; background:linear-gradient(135deg, rgba(245,158,11,.15), rgba(245,158,11,.05)); }
    .kpi-card.status-amber .kpi-value { color:#fcd34d; }
    html.theme-light .kpi-card.status-amber, html[data-theme='light'] .kpi-card.status-amber { border-left:4px solid #f59e0b; background:linear-gradient(135deg, #fffbeb, #ffffff); }
    html.theme-light .kpi-card.status-amber .kpi-value, html[data-theme='light'] .kpi-card.status-amber .kpi-value { color:#d97706; }
    
    .kpi-card.status-orange { border-left:4px solid #fb923c; background:linear-gradient(135deg, rgba(251,146,60,.15), rgba(251,146,60,.05)); }
    .kpi-card.status-orange .kpi-value { color:#fdba74; }
    html.theme-light .kpi-card.status-orange, html[data-theme='light'] .kpi-card.status-orange { border-left:4px solid #fb923c; background:linear-gradient(135deg, #fff7ed, #ffffff); }
    html.theme-light .kpi-card.status-orange .kpi-value, html[data-theme='light'] .kpi-card.status-orange .kpi-value { color:#ea580c; }
    
    .kpi-card.status-green { border-left:4px solid #10b981; background:linear-gradient(135deg, rgba(16,185,129,.15), rgba(16,185,129,.05)); }
    .kpi-card.status-green .kpi-value { color:#6ee7b7; }
    html.theme-light .kpi-card.status-green, html[data-theme='light'] .kpi-card.status-green { border-left:4px solid #10b981; background:linear-gradient(135deg, #f0fdf4, #ffffff); }
    html.theme-light .kpi-card.status-green .kpi-value, html[data-theme='light'] .kpi-card.status-green .kpi-value { color:#059669; }
    
    .kpi-label { font-size:12px; font-weight:600; letter-spacing:.3px; opacity:.75; margin-bottom:8px; text-transform:uppercase; }
    .kpi-value { font-size:36px; font-weight:800; line-height:1; margin-bottom:8px; }
    .kpi-footer { display:flex; align-items:center; justify-content:space-between; font-size:11px; opacity:.7; margin-top:auto; padding-top:8px; }
    .kpi-trend { display:flex; align-items:center; gap:4px; }

    .trouble-panel { background:rgba(25,29,37,.52); border:1px solid rgba(255,255,255,.08); border-radius:18px; box-shadow:0 16px 36px -10px rgba(0,0,0,.6), 0 0 0 1px rgba(255,255,255,.05); backdrop-filter:blur(36px) saturate(135%); padding:16px 18px 20px; margin:0 8px 0 0; min-height:220px; flex:1; min-height:0; overflow:hidden; }
    html.theme-light .trouble-panel, html[data-theme='light'] .trouble-panel { background:rgba(255,255,255,.72); border:1px solid rgba(0,0,0,.08); box-shadow:0 14px 34px -12px rgba(0,0,0,.18), 0 0 0 1px rgba(0,0,0,.05); }

    /* Table styles */
    .table-wrap { width:100%; max-width:100%; overflow-x:auto; overflow-y:visible; border-radius:12px; border:1px solid rgba(255,255,255,.08); background:rgba(25,29,37,.32); box-sizing:border-box; }
    html.theme-light .table-wrap, html[data-theme='light'] .table-wrap { background:#fff; border:1px solid rgba(0,0,0,.08); }
    table.data-table { width:100%; min-width:2560px; border-collapse:separate; border-spacing:0; font-size:11.5px; table-layout:fixed; }
    table.data-table th, table.data-table td { box-sizing:border-box; }
    table.data-table thead th, table.data-table th { position:sticky; top:0; z-index:1; background:#0b63ce !important; color:#ffffff !important; border-bottom:1px solid rgba(0,0,0,.12) !important; text-align:center; font-size:12px; padding:16px 12px !important; font-weight:800; letter-spacing:.25px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
    html:not(.theme-light):not([data-theme='light']) table.data-table thead th,
    html:not(.theme-light):not([data-theme='light']) table.data-table th { background:linear-gradient(180deg,#0f1628,#0a1324) !important; color:#e9eef8 !important; border-bottom:1px solid rgba(255,255,255,.18) !important; }
    table.data-table tbody td { padding:14px 16px; border-bottom:1px solid rgba(255,255,255,.07); vertical-align:middle; text-align:center; overflow:hidden; }
    html.theme-light table.data-table tbody td, html[data-theme='light'] table.data-table tbody td { border-bottom:1px solid rgba(0,0,0,.06); }
    table.data-table tbody tr:nth-child(odd) { background:rgba(255,255,255,.015); }
    html.theme-light table.data-table tbody tr:nth-child(odd) { background:#fafbfe; }
    table.data-table tbody tr:hover { background:rgba(255,255,255,.04); }
    html.theme-light table.data-table tbody tr:hover, html[data-theme='light'] table.data-table tbody tr:hover { background:#fafcff; }

    /* Toolbar */
    .table-toolbar { display:grid; grid-template-columns: 1fr auto; gap:12px; align-items:center; margin:8px 0 12px; }
    .toolbar-left, .toolbar-right { display:flex; align-items:center; gap:8px; }
    .toolbar-right { position: relative; z-index: 9999; }
    .search-input { width:320px; max-width:30vw; padding:8px 10px; border-radius:10px; border:1px solid rgba(255,255,255,.18); background:rgba(0,0,0,.12); color:inherit; font:inherit; font-size:13px; }
    html.theme-light .search-input, html[data-theme='light'] .search-input { background:#fff; border:1px solid rgba(0,0,0,.14); color:#1f242b; }
    .ddl { padding:8px 10px; border-radius:10px; border:1px solid rgba(255,255,255,.18); background:rgba(0,0,0,.12); color:inherit; font:inherit; font-size:13px; }
    html.theme-light .ddl, html[data-theme='light'] .ddl { background:#fff; border:1px solid rgba(0,0,0,.14); color:#1f242b; }

    /* Primary Button */
    .btn-primary { 
      padding:7px 12px; 
      border-radius:8px; 
      border:1px solid rgba(77,141,255,.4); 
      background:linear-gradient(135deg, rgba(77,141,255,.25), rgba(77,141,255,.15));
      color:#bcd4ff; 
      font:inherit; 
      font-size:12px; 
      font-weight:600;
      cursor:pointer;
      transition:all .2s ease;
      box-shadow:0 2px 8px rgba(77,141,255,.2);
      white-space:nowrap;
    }
    .btn-primary:hover { 
      background:linear-gradient(135deg, rgba(77,141,255,.35), rgba(77,141,255,.25));
      border-color:rgba(77,141,255,.5);
      box-shadow:0 4px 12px rgba(77,141,255,.3);
      transform:translateY(-1px);
    }
    html.theme-light .btn-primary, html[data-theme='light'] .btn-primary { 
      background:linear-gradient(135deg, #4d8dff, #3b7eef);
      border:1px solid #2563eb;
      color:#ffffff;
      box-shadow:0 2px 8px rgba(37,99,235,.25);
    }
    html.theme-light .btn-primary:hover, html[data-theme='light'] .btn-primary:hover { 
      background:linear-gradient(135deg, #5c9aff, #4a87f5);
      box-shadow:0 4px 12px rgba(37,99,235,.35);
    }

    /* Secondary Button */
    .btn-secondary { 
      padding:7px 12px; 
      border-radius:8px; 
      border:1px solid rgba(255,255,255,.18); 
      background:rgba(255,255,255,.08);
      color:inherit; 
      font:inherit; 
      font-size:12px; 
      font-weight:600;
      cursor:pointer;
      transition:all .2s ease;
      white-space:nowrap;
    }
    .btn-secondary:hover { 
      background:rgba(255,255,255,.12);
      border-color:rgba(255,255,255,.25);
      transform:translateY(-1px);
    }
    html.theme-light .btn-secondary, html[data-theme='light'] .btn-secondary { 
      background:#f5f7fa;
      border:1px solid rgba(0,0,0,.14);
      color:#1f242b;
    }
    html.theme-light .btn-secondary:hover, html[data-theme='light'] .btn-secondary:hover { 
      background:#e8ecf1;
      border-color:rgba(0,0,0,.20);
    }

    /* Orange calendar button */
    .btn-icon-calendar {
      background: rgba(251,146,60,.25);
      border-color: rgba(251,146,60,.4);
      color: #fed7aa;
    }
    .btn-icon-calendar:hover {
      background: rgba(251,146,60,.35);
      border-color: rgba(251,146,60,.5);
      box-shadow: 0 4px 12px rgba(251,146,60,.25);
      transform: translateY(-2px);
    }
    .btn-icon:hover {
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
    .btn-icon-accent {
      background: rgba(168,85,247,.25);
      border-color: rgba(168,85,247,.4);
      color: #bcd4ff;
    }
    .btn-icon-accent:hover {
      background: rgba(168,85,247,.35);
      border-color: rgba(168,85,247,.5);
      box-shadow: 0 4px 12px rgba(168,85,247,.25);
      transform: translateY(-2px);
    }
    .btn-icon-primary {
      background: rgba(77,141,255,.25);
      border-color: rgba(77,141,255,.4);
      color: #bcd4ff;
    }
    .btn-icon-primary:hover {
      background: rgba(77,141,255,.35);
      border-color: rgba(77,141,255,.5);
      box-shadow: 0 4px 12px rgba(77,141,255,.25);
      transform: translateY(-2px);
    }
    /* Icon Button Styles */
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
    /* Purple Grid View button */
    .btn-icon-accent {
      background: rgba(168,85,247,.25);
      border-color: rgba(168,85,247,.4);
      color: #e9d5ff;
    }
    .btn-icon-accent:hover {
      background: rgba(168,85,247,.35);
      border-color: rgba(168,85,247,.5);
      box-shadow: 0 4px 12px rgba(168,85,247,.25);
      transform: translateY(-2px);
    }
    /* Blue primary button (Add New) */
    .btn-icon-primary {
      background: rgba(77,141,255,.25);
      border-color: rgba(77,141,255,.4);
      color: #bcd4ff;
    }
    .btn-icon-primary:hover {
      background: rgba(77,141,255,.35);
      border-color: rgba(77,141,255,.5);
      box-shadow: 0 4px 12px rgba(77,141,255,.25);
      transform: translateY(-2px);
    }
    /* Orange calendar button */
    .btn-icon-calendar {
      background: rgba(251,146,60,.25);
      border-color: rgba(251,146,60,.4);
      color: #fed7aa;
    }
    .btn-icon-calendar:hover {
      background: rgba(251,146,60,.35);
      border-color: rgba(251,146,60,.5);
      box-shadow: 0 4px 12px rgba(251,146,60,.25);
      transform: translateY(-2px);
    }
    /* Brown calendar button */
    .btn-icon-brown {
      background: rgba(120,53,15,.25);
      border-color: rgba(120,53,15,.4);
      color: #fed7aa;
    }
    .btn-icon-brown:hover {
      background: rgba(120,53,15,.35);
      border-color: rgba(120,53,15,.5);
      box-shadow: 0 4px 12px rgba(120,53,15,.25);
      transform: translateY(-2px);
    }
    /* Tooltip */
    .btn-icon[data-tooltip]::after {
      content: attr(data-tooltip);
      position: absolute;
      bottom: -36px;
      right: 0;
      background: rgba(0,0,0,.92);
      color: #fff;
      padding: 6px 10px;
      border-radius: 6px;
      font-size: 13px;
      font-weight: 500;
      white-space: nowrap;
      opacity: 0;
      pointer-events: none;
      transition: opacity .2s ease;
      z-index: 10000;
      box-shadow: 0 4px 12px rgba(0,0,0,.4);
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
    }
    .btn-icon[data-tooltip]::before {
      content: '';
      position: absolute;
      bottom: -8px;
      right: 12px;
      width: 0;
      height: 0;
      border-left: 5px solid transparent;
      border-right: 5px solid transparent;
      border-bottom: 6px solid rgba(0,0,0,.92);
      opacity: 0;
      pointer-events: none;
      transition: opacity .2s ease;
      z-index: 10000;
    }
    .btn-icon:hover[data-tooltip]::after,
    .btn-icon:hover[data-tooltip]::before {
      opacity: 1;
    }
    html.theme-light .btn-icon,
    html[data-theme='light'] .btn-icon {
      background: #f5f7fa;
      border-color: rgba(0,0,0,.14);
      color: #1f242b;
    }
    html.theme-light .btn-icon:hover,
    html[data-theme='light'] .btn-icon:hover {
      background: #e8ecf1;
      border-color: rgba(0,0,0,.22);
      box-shadow: 0 4px 12px rgba(0,0,0,.12);
    }
    html.theme-light .btn-icon-accent,
    html[data-theme='light'] .btn-icon-accent {
      background: #f3e8ff;
      border-color: #d8b4fe;
      color: #7c3aed;
    }
    html.theme-light .btn-icon-accent:hover,
    html[data-theme='light'] .btn-icon-accent:hover {
      background: #e9d5ff;
      border-color: #c084fc;
      box-shadow: 0 4px 12px rgba(124,58,237,.2);
    }
    /* Orange calendar button */
    .btn-icon-calendar {
      background: rgba(251,146,60,.25);
      border-color: rgba(251,146,60,.4);
      color: #fed7aa;
    }
    .btn-icon-calendar:hover {
      background: rgba(251,146,60,.35);
      border-color: rgba(251,146,60,.5);
      box-shadow: 0 4px 12px rgba(251,146,60,.25);
      transform: translateY(-2px);
    }
    html.theme-light .btn-icon-calendar,
    html[data-theme='light'] .btn-icon-calendar {
      background: #ffedd5;
      border-color: #fdba74;
      color: #c2410c;
    }
    html.theme-light .btn-icon-calendar:hover,
    html[data-theme='light'] .btn-icon-calendar:hover {
      background: #fed7aa;
      border-color: #fb923c;
      box-shadow: 0 4px 12px rgba(194,65,12,.2);
    }
    .btn-icon[data-tooltip]::after {
      content: attr(data-tooltip);
      position: absolute;
      bottom: -36px;
      right: 0;
      background: rgba(0,0,0,.92);
      color: #fff;
      padding: 6px 10px;
      border-radius: 6px;
      font-size: 13px;
      font-weight: 500;
      white-space: nowrap;
      opacity: 0;
      pointer-events: none;
      transition: opacity .2s ease;
      z-index: 10000;
      box-shadow: 0 4px 12px rgba(0,0,0,.4);
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
    }
    .btn-icon[data-tooltip]::before {
      content: '';
      position: absolute;
      bottom: -8px;
      right: 12px;
      width: 0;
      height: 0;
      border-left: 5px solid transparent;
      border-right: 5px solid transparent;
      border-bottom: 6px solid rgba(0,0,0,.92);
      opacity: 0;
      pointer-events: none;
      transition: opacity .2s ease;
      z-index: 10000;
    }
    .btn-icon:hover[data-tooltip]::after,
    .btn-icon:hover[data-tooltip]::before {
      opacity: 1;
    }

    .table-wrap {
      overflow-x: auto;
      overflow-y: auto;
      max-height: calc(100vh - 300px);
    }
    .table-wrap::-webkit-scrollbar {
      width: 8px;
      height: 8px;
    }
    .table-wrap::-webkit-scrollbar-track {
      background: transparent;
    }
    .table-wrap::-webkit-scrollbar-thumb {
      background: rgba(255,255,255,.15);
      border-radius: 4px;
    }
    .table-wrap::-webkit-scrollbar-thumb:hover {
      background: rgba(255,255,255,.25);
    }
    html.theme-light .table-wrap::-webkit-scrollbar-thumb,
    html[data-theme='light'] .table-wrap::-webkit-scrollbar-thumb {
      background: rgba(0,0,0,.15);
    }
    html.theme-light .table-wrap::-webkit-scrollbar-thumb:hover,
    html[data-theme='light'] .table-wrap::-webkit-scrollbar-thumb:hover {
      background: rgba(0,0,0,.25);
    }
    .table-wrap {
      scrollbar-width: thin;
      scrollbar-color: rgba(255,255,255,.15) transparent;
    }
    html.theme-light .table-wrap,
    html[data-theme='light'] .table-wrap {
      scrollbar-color: rgba(0,0,0,.15) transparent;
    }

    .pagination-container {
      display: flex;
      align-items: center;
      gap: 6px;
      padding: 10px 16px;
      font-size: 11px;
      color: inherit;
      opacity: 0.85;
    }
    .pagination-container .page-info {
      margin-right: 8px;
      font-weight: 500;
    }
    .pagination-container a,
    .pagination-container span {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      min-width: 22px;
      height: 22px;
      padding: 0 6px;
      border-radius: 4px;
      font-size: 11px;
      font-weight: 500;
      text-decoration: none;
      transition: all .12s ease;
      border: 1px solid transparent;
      background: transparent;
      color: inherit;
    }
    .pagination-container span.current {
      background: rgba(77,141,255,.15);
      border-color: rgba(77,141,255,.3);
      color: #bcd4ff;
      font-weight: 600;
    }
    .pagination-container a:hover {
      background: rgba(255,255,255,.08);
      border-color: rgba(255,255,255,.15);
    }
    .pagination-container a.nav-arrow {
      font-size: 14px;
      min-width: 24px;
      height: 24px;
    }
    html.theme-light .pagination-container a,
    html.theme-light .pagination-container span,
    html[data-theme='light'] .pagination-container a,
    html[data-theme='light'] .pagination-container span {
      color: #495057;
    }
    html.theme-light .pagination-container span.current,
    html[data-theme='light'] .pagination-container span.current {
      background: #4d8dff;
      border-color: #4d8dff;
      color: #ffffff;
    }
    html.theme-light .pagination-container a:hover,
    html[data-theme='light'] .pagination-container a:hover {
      background: rgba(0,0,0,.05);
      border-color: rgba(0,0,0,.1);
    }
    
    .data-table tr.pager {
      display: none !important;
    }

    /* Column widths for Troubleshooting table */
    table.data-table .col-id { width:80px; min-width:80px; max-width:80px; }
    table.data-table .col-location { width:320px; min-width:320px; max-width:320px; }
    table.data-table .col-symptom { width:500px; min-width:500px; max-width:500px; }
    table.data-table .col-reportedby { width:240px; min-width:240px; max-width:240px; }
    table.data-table .col-reporteddate { width:130px; min-width:130px; max-width:130px; }
    table.data-table .col-description { width:500px; min-width:500px; max-width:500px; }
    table.data-table .col-solution { width:500px; min-width:500px; max-width:500px; }
    table.data-table .col-status { width:150px; min-width:150px; max-width:150px; }
    table.data-table .col-actions { width:140px; min-width:140px; max-width:140px; }

    /* Center text in ID and Reported Date columns */
    table.data-table .col-id .inline-input,
    table.data-table .col-reporteddate .inline-input { text-align:center; }

    /* Multiline text styling */
    .multiline-text {
      max-height: 120px;
      overflow-y: auto;
      overflow-x: hidden;
      text-align: left;
      white-space: pre-wrap;
      word-wrap: break-word;
      word-break: break-word;
      line-height: 1.5;
      padding: 4px 6px;
    }
    .multiline-text::-webkit-scrollbar { width: 4px; }
    .multiline-text::-webkit-scrollbar-track { background: rgba(255,255,255,.05); border-radius: 2px; }
    .multiline-text::-webkit-scrollbar-thumb { background: rgba(255,255,255,.2); border-radius: 2px; }
    .multiline-text::-webkit-scrollbar-thumb:hover { background: rgba(255,255,255,.3); }
    html.theme-light .multiline-text::-webkit-scrollbar-track { background: rgba(0,0,0,.05); }
    html.theme-light .multiline-text::-webkit-scrollbar-thumb { background: rgba(0,0,0,.2); }
    html.theme-light .multiline-text::-webkit-scrollbar-thumb:hover { background: rgba(0,0,0,.3); }

    /* Inline editing inputs */
    .inline-input, .inline-textarea {
      width:100%;
      padding:6px 8px;
      border-radius:6px;
      border:1px solid rgba(255,255,255,.18);
      background:rgba(0,0,0,.12);
      color:inherit;
      font:inherit;
      font-size:11.5px;
      box-sizing:border-box;
    }
    .inline-textarea {
      min-height:80px;
      max-height:80px;
      height:80px;
      resize:none;
      overflow-y:auto;
      white-space:pre-wrap;
      word-wrap:break-word;
    }
    html.theme-light .inline-input, html.theme-light .inline-textarea,
    html[data-theme='light'] .inline-input, html[data-theme='light'] .inline-textarea {
      background:#fff;
      border:1px solid rgba(0,0,0,.14);
      color:#1f242b;
    }
    .inline-input[disabled], .inline-textarea[disabled] {
      background:rgba(0,0,0,.18) !important;
      color:rgba(255,255,255,.4) !important;
      border-color:rgba(255,255,255,.08) !important;
      cursor:not-allowed;
      opacity:.6;
    }
    html.theme-light .inline-input[disabled], html.theme-light .inline-textarea[disabled],
    html[data-theme='light'] .inline-input[disabled], html[data-theme='light'] .inline-textarea[disabled] {
      background:#f5f7fa !important;
      color:rgba(0,0,0,.4) !important;
      border-color:rgba(0,0,0,.08) !important;
    }
    .inline-dropdown {
      width:100%;
      padding:6px 8px;
      border-radius:6px;
      border:1px solid rgba(255,255,255,.18);
      background:rgba(0,0,0,.12);
      color:inherit;
      font:inherit;
      font-size:11.5px;
    }
    html.theme-light .inline-dropdown, html[data-theme='light'] .inline-dropdown {
      background:#fff;
      border:1px solid rgba(0,0,0,.14);
      color:#1f242b;
    }
    .inline-dropdown[disabled] {
      background:rgba(0,0,0,.18) !important;
      color:rgba(255,255,255,.4) !important;
      border-color:rgba(255,255,255,.08) !important;
      cursor:not-allowed;
      opacity:.6;
    }
    html.theme-light .inline-dropdown[disabled], html[data-theme='light'] .inline-dropdown[disabled] {
      background:#f5f7fa !important;
      color:rgba(0,0,0,.4) !important;
      border-color:rgba(0,0,0,.08) !important;
    }

    /* Action buttons */
    .tbl-actions { display:flex; gap:6px; justify-content:center; align-items:center; width:100%; }
    .col-actions .tbl-actions { justify-content:center; margin:0 auto; max-width:140px; }
    .save-btn, .detail-btn, .del-btn { 
      width:34px; height:34px; 
      display:inline-flex; 
      align-items:center; 
      justify-content:center; 
      border-radius:8px; 
      border:1px solid rgba(255,255,255,.18); 
      cursor:pointer; 
      transition: background .15s ease, border-color .15s ease, box-shadow .15s ease, transform .12s ease;
      text-decoration:none !important;
    }
    .del-btn { border:1px solid rgba(255,86,86,.35); background:rgba(255,86,86,.22); color:#ffc6c6; }
    .save-btn { background:rgba(30,180,90,.18); color:#e2ffe6; }
    .detail-btn { background:rgba(255,140,0,.18); color:#ffe0b3; border:1px solid rgba(255,140,0,.35); }
    /* Hover (dark theme) */
    .save-btn:hover { background:rgba(30,180,90,.28); border-color:rgba(30,180,90,.55); box-shadow:0 2px 6px rgba(0,0,0,.3); transform:translateY(-1px); }
    .detail-btn:hover { background:rgba(255,140,0,.26); border-color:rgba(255,140,0,.55); box-shadow:0 2px 6px rgba(0,0,0,.3); transform:translateY(-1px); }
    .del-btn:hover { background:rgba(255,86,86,.3); border-color:rgba(255,86,86,.65); box-shadow:0 2px 6px rgba(0,0,0,.3); transform:translateY(-1px); }
    html.theme-light .save-btn, html[data-theme='light'] .save-btn { border:1px solid rgba(0,0,0,.12); background:#e8f5ed; color:#1e7f45; }
    html.theme-light .detail-btn, html[data-theme='light'] .detail-btn { border:1px solid rgba(0,0,0,.12); background:#fff4e6; color:#cc7a00; }
    html.theme-light .del-btn, html[data-theme='light'] .del-btn { border:1px solid rgba(0,0,0,.12); background:#ffe9e9; color:#9b1c1c; }
    /* Hover (light theme) */
    html.theme-light .save-btn:hover, html[data-theme='light'] .save-btn:hover { background:#dff0e7; border-color:rgba(0,0,0,.22); box-shadow:0 2px 6px rgba(0,0,0,.15); transform:translateY(-1px); }
    html.theme-light .detail-btn:hover, html[data-theme='light'] .detail-btn:hover { background:#ffedd6; border-color:rgba(0,0,0,.22); box-shadow:0 2px 6px rgba(0,0,0,.15); transform:translateY(-1px); }
    html.theme-light .del-btn:hover, html[data-theme='light'] .del-btn:hover { background:#ffdede; border-color:rgba(198,40,40,.45); box-shadow:0 2px 6px rgba(0,0,0,.15); transform:translateY(-1px); }
    /* Disabled state styling for action buttons (works for both button and LinkButton/a tags) */
    .tbl-actions button[disabled],
    .tbl-actions a[disabled],
    .tbl-actions .save-btn[disabled],
    .tbl-actions .del-btn[disabled] { 
      background:#8a96a8 !important; 
      color:#e6ebf2 !important; 
      border-color:rgba(0,0,0,.18) !important; 
      cursor:not-allowed !important; 
      pointer-events:none !important; 
      box-shadow:none !important; 
      transform:none !important; 
      opacity:.75; 
    }
    html.theme-light .tbl-actions button[disabled], 
    html.theme-light .tbl-actions a[disabled],
    html.theme-light .tbl-actions .save-btn[disabled],
    html.theme-light .tbl-actions .del-btn[disabled],
    html[data-theme='light'] .tbl-actions button[disabled],
    html[data-theme='light'] .tbl-actions a[disabled],
    html[data-theme='light'] .tbl-actions .save-btn[disabled],
    html[data-theme='light'] .tbl-actions .del-btn[disabled] { 
      background:#e2e7ef !important; 
      color:#96a0ae !important; 
      border-color:rgba(0,0,0,.14) !important; 
    }
    .tbl-actions button[disabled]:hover,
    .tbl-actions a[disabled]:hover { background:inherit; border-color:inherit; box-shadow:none; transform:none; }
    /* Focus-visible for accessibility */
    .save-btn:focus-visible, .detail-btn:focus-visible, .del-btn:focus-visible { outline:none; box-shadow:0 0 0 2px rgba(255,255,255,.55), 0 0 0 4px rgba(80,140,255,.55); }
    html.theme-light .save-btn:focus-visible, html.theme-light .detail-btn:focus-visible, html.theme-light .del-btn:focus-visible,
    html[data-theme='light'] .save-btn:focus-visible, html[data-theme='light'] .detail-btn:focus-visible, html[data-theme='light'] .del-btn:focus-visible { box-shadow:0 0 0 2px rgba(255,255,255,.9), 0 0 0 4px rgba(30,90,200,.45); }
    .save-btn svg, .detail-btn svg, .del-btn svg { width:16px; height:16px; display:block; }

    /* Actions column as normal (non-sticky) so it stays at the far-right cell and doesn't float */
    table.data-table thead th.col-actions, table.data-table tbody td.col-actions { position:static; right:auto; box-shadow:none; }
    table.data-table thead th.col-actions, table.data-table tbody td.col-actions { text-align:center; }

    /* Toast */
    .toast { position:fixed; right:16px; bottom:16px; background:#1e293b; color:#fff; border-radius:10px; padding:12px 14px; box-shadow:0 10px 24px rgba(0,0,0,.5); z-index:9999; opacity:0; transform:translateY(16px); transition:all .25s ease; }
    .toast.show { opacity:1; transform:translateY(0); }
    .toast-success { background:#059669; border-left:4px solid #10b981; }
    .toast-error { background:#dc2626; border-left:4px solid #f87171; }
    .toast-info { background:#2563eb; border-left:4px solid #60a5fa; }
  </style>
</asp:Content>
<asp:Content ID="TroubleMain" ContentPlaceHolderID="MainContent" runat="server">
  <div class="dash-shell">
  <aside class="dash-sidebar" role="navigation" aria-label="Sidebar">
    <div class="sidebar-user">
      <div class="avatar" id="userAvatar" runat="server">JD</div>
      <div class="user-meta">
        <strong id="userFullName" runat="server">John Doe</strong>
        <span id="userRole" runat="server">Test Engineer</span>
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
        <li><a class="nav-link" href="CalibrationDashboard.aspx"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><line x1="4" y1="21" x2="4" y2="14"/><line x1="4" y1="10" x2="4" y2="3"/><line x1="12" y1="21" x2="12" y2="12"/><line x1="12" y1="8" x2="12" y2="3"/><line x1="20" y1="21" x2="20" y2="16"/><line x1="20" y1="12" x2="20" y2="3"/><line x1="1" y1="14" x2="7" y2="14"/><line x1="9" y1="8" x2="15" y2="8"/><line x1="17" y1="16" x2="23" y2="16"/></svg><span>Calibration</span></a></li>
        <li><a class="nav-link" href="PMDashboard.aspx"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/><path d="M9 16l2 2 4-4"/></svg><span>Preventive Maintenance</span></a></li>
        <li><a class="nav-link active" href="TroubleshootingDashboard.aspx"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><path d="M9.5 9a3 3 0 1 1 5 2c-.8.6-1.5 1-1.5 2"/><circle cx="12" cy="17" r="1"/></svg><span>Troubleshooting</span></a></li>
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
  <div class="dash-col">
    <section class="dash-main">
      <div class="page-title-wrap">
        <h1 class="page-title">Troubleshooting Dashboard</h1>
      </div>
      
      <!-- KPI Cards -->
      <div class="kpi-grid">
        <div class="kpi-card" id="cardOpenIssues" runat="server">
          <div class="kpi-label">Open Issues</div>
          <div style="display: flex; align-items: center; justify-content: space-between; margin-top: 4px; height: 60px;">
            <div class="kpi-value" style="margin-bottom: 0;"><asp:Literal ID="litOpenIssues" runat="server" Text="0" /></div>
            <div style="width: 120px; height: 40px; margin-right: -4px;">
              <canvas id="bulletChartOpenIssues"></canvas>
            </div>
          </div>
          <div class="kpi-footer" style="margin-top: 8px;">
            <span id="criticalText"><asp:Literal ID="litCriticalCount" runat="server" Text="0" /> critical</span>
          </div>
        </div>
        
        <div class="kpi-card" id="cardAvgResolution" runat="server">
          <div class="kpi-label">Avg Resolution Time</div>
          <div class="kpi-value"><asp:Literal ID="litAvgResolution" runat="server" Text="--" /></div>
          <div class="kpi-footer">
            <span class="kpi-trend">Hours to resolve</span>
            <span>Last 12 months</span>
          </div>
        </div>
        
        <div class="kpi-card" id="cardRepeatRate" runat="server">
          <div class="kpi-label">Repeat Issue Rate</div>
          <div class="kpi-value"><asp:Literal ID="litRepeatRate" runat="server" Text="--" /></div>
          <div class="kpi-footer">
            <span class="kpi-trend">Recurring problems</span>
            <span>Last 12 months</span>
          </div>
        </div>
        
        <div class="kpi-card status-green">
          <div class="kpi-label">High Priority Open</div>
          <div class="kpi-value"><asp:Literal ID="litHighPriority" runat="server" Text="0" /></div>
          <div class="kpi-footer">
            <span class="kpi-trend">Needs attention</span>
          </div>
        </div>
        
        <div class="kpi-card status-green">
          <div class="kpi-label">Medium/Low Priority</div>
          <div class="kpi-value"><asp:Literal ID="litMediumLowPriority" runat="server" Text="0" /></div>
          <div class="kpi-footer">
            <span class="kpi-trend">Standard queue</span>
          </div>
        </div>
      </div>

      <div class="trouble-panel">
      <div class="table-toolbar">
        <div class="toolbar-left">
          <asp:TextBox ID="txtSearch" runat="server" CssClass="search-input" placeholder="Search Issue ID, Description, Equipment..." AutoPostBack="true" OnTextChanged="txtSearch_TextChanged" />
          <span style="opacity:.75; font-size:12px;">Sort by</span>
          <asp:DropDownList ID="ddlSort" runat="server" CssClass="ddl" AutoPostBack="true" OnSelectedIndexChanged="ddlSort_SelectedIndexChanged">
            <asp:ListItem Text="Date (Newest)" Value="date_desc" />
            <asp:ListItem Text="Date (Oldest)" Value="date_asc" />
            <asp:ListItem Text="Priority" Value="priority" />
            <asp:ListItem Text="Status" Value="status" />
            <asp:ListItem Text="Equipment Type" Value="equipment" />
          </asp:DropDownList>
          <span style="opacity:.75; font-size:12px;">Location</span>
          <asp:DropDownList ID="ddlLocation" runat="server" CssClass="ddl" AutoPostBack="true" OnSelectedIndexChanged="ddlLocation_SelectedIndexChanged">
            <asp:ListItem Text="All Locations" Value="all" Selected="True" />
          </asp:DropDownList>
          <span style="opacity:.75; font-size:12px;">Page size</span>
          <asp:DropDownList ID="ddlPageSize" runat="server" CssClass="ddl" AutoPostBack="true" OnSelectedIndexChanged="ddlPageSize_SelectedIndexChanged">
            <asp:ListItem Text="10" Value="10" />
            <asp:ListItem Text="25" Value="25" Selected="True" />
            <asp:ListItem Text="50" Value="50" />
            <asp:ListItem Text="100" Value="100" />
          </asp:DropDownList>
        </div>
        <div class="toolbar-right">
          <!-- Grid View Button (Purple) -->
          <button type="button" class="btn-icon btn-icon-accent" data-tooltip="Grid View" onclick="window.open('TroubleshootingGridView.aspx', '_blank'); return false;">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round">
              <rect x="3" y="3" width="7" height="7"></rect>
              <rect x="14" y="3" width="7" height="7"></rect>
              <rect x="14" y="14" width="7" height="7"></rect>
              <rect x="3" y="14" width="7" height="7"></rect>
            </svg>
          </button>

          <!-- Download CSV Button (Gray) -->
          <button type="button" class="btn-icon" data-tooltip="Download CSV" id="btnDownloadCSV">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round">
              <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path>
              <polyline points="7 10 12 15 17 10"></polyline>
              <line x1="12" y1="15" x2="12" y2="3"></line>
            </svg>
          </button>
          <asp:Button ID="btnExportCSV" runat="server" OnClick="btnExportCSV_Click" style="display:none;" />
          <script type="text/javascript">
            document.addEventListener('DOMContentLoaded', function() {
              var btnDownload = document.getElementById('btnDownloadCSV');
              var btnHidden = document.getElementById('<%= btnExportCSV.ClientID %>');
              if (btnDownload && btnHidden) {
                btnDownload.onclick = function() { btnHidden.click(); };
              }
            });
          </script>

          <!-- View Details Button (Orange) -->
          <asp:LinkButton ID="btnViewDetails" runat="server" CssClass="btn-icon btn-icon-calendar" 
                          data-tooltip="View Details" OnClick="btnViewDetails_Click">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round">
              <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
              <circle cx="12" cy="12" r="3"></circle>
            </svg>
          </asp:LinkButton>
          
          <!-- Report Issue Button (Blue) -->
          <button type="button" class="btn-icon btn-icon-primary" data-tooltip="Report Issue" 
                  onclick="window.location='TroubleshootingDetails.aspx?mode=new'; return false;">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round">
              <line x1="12" y1="5" x2="12" y2="19"></line>
              <line x1="5" y1="12" x2="19" y2="12"></line>
            </svg>
          </button>
        </div>
      </div>
      <div class="table-wrap">
        <asp:GridView ID="gridTroubleshooting" runat="server" AutoGenerateColumns="false" CssClass="data-table" GridLines="None" CellPadding="0" 
          AllowPaging="true" PageSize="25" EnableViewState="true"
          DataKeyNames="TroubleshootingLogID" OnPageIndexChanging="gridTroubleshooting_PageIndexChanging" OnRowCommand="gridTroubleshooting_RowCommand" OnRowDataBound="gridTroubleshooting_RowDataBound">
          <PagerStyle CssClass="pager" HorizontalAlign="Center" />
          <PagerSettings Mode="NumericFirstLast" FirstPageText="First" LastPageText="Last" PageButtonCount="7" />
          <Columns>
            <asp:TemplateField HeaderText="ID" HeaderStyle-CssClass="col-id" ItemStyle-CssClass="col-id">
              <ItemTemplate>
                <asp:Literal ID="litID" runat="server" Text='<%# Eval("TroubleshootingLogID") %>' />
              </ItemTemplate>
            </asp:TemplateField>

            <asp:TemplateField HeaderText="Location" HeaderStyle-CssClass="col-location" ItemStyle-CssClass="col-location">
              <ItemTemplate>
                <asp:Literal ID="litLocation" runat="server" Text='<%# Eval("Location") %>' />
              </ItemTemplate>
            </asp:TemplateField>

            <asp:TemplateField HeaderText="Symptom" HeaderStyle-CssClass="col-symptom" ItemStyle-CssClass="col-symptom">
              <ItemTemplate>
                <div class="multiline-text">
                  <asp:Literal ID="litSymptom" runat="server" Text='<%# Eval("Symptom") %>' />
                </div>
              </ItemTemplate>
            </asp:TemplateField>

            <asp:TemplateField HeaderText="Reported By" HeaderStyle-CssClass="col-reportedby" ItemStyle-CssClass="col-reportedby">
              <ItemTemplate>
                <asp:Literal ID="litReportedBy" runat="server" Text='<%# Eval("ReportedBy") %>' />
              </ItemTemplate>
            </asp:TemplateField>

            <asp:TemplateField HeaderText="Reported Date" HeaderStyle-CssClass="col-reporteddate" ItemStyle-CssClass="col-reporteddate">
              <ItemTemplate>
                <asp:Literal ID="litReportedDate" runat="server" Text='<%# Eval("ReportedDateTime", "{0:MM/dd/yyyy}") %>' />
              </ItemTemplate>
            </asp:TemplateField>

            <asp:TemplateField HeaderText="Description" HeaderStyle-CssClass="col-description" ItemStyle-CssClass="col-description">
              <ItemTemplate>
                <div class="multiline-text">
                  <asp:Literal ID="litDescription" runat="server" Text='<%# Eval("TroubleshootingStepsDescription") %>' />
                </div>
              </ItemTemplate>
            </asp:TemplateField>

            <asp:TemplateField HeaderText="Solution" HeaderStyle-CssClass="col-solution" ItemStyle-CssClass="col-solution">
              <ItemTemplate>
                <div class="multiline-text">
                  <asp:Literal ID="litSolution" runat="server" Text='<%# Eval("SolutionApplied") %>' />
                </div>
              </ItemTemplate>
            </asp:TemplateField>

            <asp:TemplateField HeaderText="Status" HeaderStyle-CssClass="col-status" ItemStyle-CssClass="col-status">
              <ItemTemplate>
                <asp:Literal ID="litStatus" runat="server" Text='<%# Eval("Status") %>' />
              </ItemTemplate>
            </asp:TemplateField>

            <asp:TemplateField HeaderText="Actions" HeaderStyle-CssClass="col-actions" ItemStyle-CssClass="col-actions">
              <ItemTemplate>
                <asp:PlaceHolder ID="phActions" runat="server" />
              </ItemTemplate>
            </asp:TemplateField>
          </Columns>
          <EmptyDataTemplate>
            <div style="padding:24px; text-align:center; font-size:14px; opacity:.75">
              <p style="margin:0 0 8px;">No troubleshooting issues found.</p>
              <p style="margin:0; font-size:12px;">Issue logs will appear here once problems are reported.</p>
            </div>
          </EmptyDataTemplate>
        </asp:GridView>
      </div>
      <!-- Custom Minimal Pagination -->
      <div class="pagination-container" id="customPagination" runat="server">
        <!-- Pagination will be rendered from code-behind -->
      </div>
      </div>
      </div>
    </section>
  </div>
  </div>

  <div id="toast" class="toast" role="status" aria-live="polite"></div>
  <script type="text/javascript">
    window.showToast = function (msg, type) {
      try {
        var el = document.getElementById('toast');
        if (!el) return; 
        el.textContent = msg; 
        el.className = 'toast show' + (type ? ' toast-' + type : '');
        setTimeout(function(){ el.classList.remove('show'); }, 3000);
      } catch(e){}
    }

    // Initialize bullet chart for Open Issues
    document.addEventListener('DOMContentLoaded', function() {
      const isDark = document.documentElement.classList.contains('theme-dark') || 
                     document.documentElement.getAttribute('data-theme') === 'dark' ||
                     !document.documentElement.classList.contains('theme-light');
      
      const colors = {
        isDark: isDark,
        text: isDark ? '#f1f5f9' : '#0f172a',
        tooltipBg: isDark ? 'rgba(30,41,59,0.95)' : 'rgba(255,255,255,0.95)',
        tooltipBorder: isDark ? 'rgba(255,255,255,0.12)' : 'rgba(0,0,0,0.12)'
      };

      const ctxBulletChart = document.getElementById('bulletChartOpenIssues');
      if (ctxBulletChart) {
        const openIssues = <%= litOpenIssues.Text %> || 0;
        const criticalIssues = <%= litCriticalCount.Text %> || 0;
        
        new Chart(ctxBulletChart, {
          type: 'bar',
          data: {
            labels: [''],
            datasets: [
              {
                label: 'Total Open',
                data: [openIssues],
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
                label: 'Critical',
                data: [criticalIssues],
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
                order: -1
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
                padding: 10,
                titleFont: { size: 11, weight: '600' },
                bodyFont: { size: 10 },
                callbacks: {
                  label: function(context) {
                    if (context.datasetIndex === 1) {
                      return 'Critical: ' + criticalIssues + ' issues';
                    }
                    return 'Total Open: ' + openIssues + ' issues';
                  }
                }
              }
            },
            scales: {
              x: {
                stacked: false,
                display: false,
                max: openIssues > 0 ? openIssues : 10
              },
              y: {
                stacked: false,
                display: false
              }
            },
            layout: {
              padding: 0
            }
          },
          plugins: [{
            id: 'overlayBars',
            beforeDatasetsDraw(chart) {
              const meta0 = chart.getDatasetMeta(0);
              const meta1 = chart.getDatasetMeta(1);
              
              if (meta0.data.length && meta1.data.length) {
                const yCenter = (chart.chartArea.top + chart.chartArea.bottom) / 2;
                meta0.data[0].y = yCenter;
                meta1.data[0].y = yCenter;
              }
            }
          }]
        });
      }
    });
  </script>
</asp:Content>

