<%@ Page Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="TroubleshootingDashboard.aspx.cs" Inherits="TED_TroubleshootingDashboard" %>
<asp:Content ID="TSDashTitle" ContentPlaceHolderID="TitleContent" runat="server">Troubleshooting Dashboard - Test Engineering</asp:Content>
<asp:Content ID="TSDashHead" ContentPlaceHolderID="HeadContent" runat="server">
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
      gap:18px; 
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
    /* Tooltip styling */
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
      box-shadow:0 8px 24px -8px rgba(0,0,0,.24); 
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
    html.theme-light .kpi-card.status-blue, html[data-theme='light'] .kpi-card.status-blue { 
      border-left:4px solid #3b82f6; 
      background:linear-gradient(135deg, #eff6ff, #ffffff); 
    }
    html.theme-light .kpi-card.status-blue .kpi-value, html[data-theme='light'] .kpi-card.status-blue .kpi-value { 
      color:#2563eb; 
    }
    
    /* MODERN TABLE STYLES */
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
    
    html.theme-light .modern-table td, html[data-theme='light'] .modern-table td {
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
    
    /* Priority Badge Styles */
    .priority-badge {
      display: inline-block;
      padding: 4px 10px;
      border-radius: 4px;
      font-size: 10px;
      font-weight: 600;
      text-transform: uppercase;
      letter-spacing: 0.3px;
    }
    .priority-badge.priority-critical {
      background-color: #fce7f3;
      color: #be185d;
      border: 1px solid #fbcfe8;
    }
    html.theme-dark .priority-badge.priority-critical, html[data-theme='dark'] .priority-badge.priority-critical {
      background-color: rgba(190, 24, 93, 0.15);
      color: #f9a8d4;
      border: 1px solid rgba(251, 207, 232, 0.2);
    }
    .priority-badge.priority-high {
      background-color: #fee2e2;
      color: #dc2626;
      border: 1px solid #fecaca;
    }
    html.theme-dark .priority-badge.priority-high, html[data-theme='dark'] .priority-badge.priority-high {
      background-color: rgba(220, 38, 38, 0.15);
      color: #fca5a5;
      border: 1px solid rgba(254, 202, 202, 0.2);
    }
    .priority-badge.priority-medium {
      background-color: #fef3c7;
      color: #d97706;
      border: 1px solid #fde68a;
    }
    html.theme-dark .priority-badge.priority-medium, html[data-theme='dark'] .priority-badge.priority-medium {
      background-color: rgba(217, 119, 6, 0.15);
      color: #fcd34d;
      border: 1px solid rgba(253, 230, 138, 0.2);
    }
    .priority-badge.priority-low {
      background-color: #e5e7eb;
      color: #6b7280;
      border: 1px solid #d1d5db;
    }
    html.theme-dark .priority-badge.priority-low, html[data-theme='dark'] .priority-badge.priority-low {
      background-color: rgba(107, 114, 128, 0.15);
      color: #9ca3af;
      border: 1px solid rgba(209, 213, 219, 0.2);
    }
    
    /* Status Badge Styles */
    .status-badge {
      display: inline-block;
      padding: 4px 10px;
      border-radius: 4px;
      font-size: 10px;
      font-weight: 600;
      text-transform: uppercase;
      letter-spacing: 0.3px;
      font-family: 'Segoe UI', sans-serif;
    }
    .status-badge.status-open {
      background-color: #fee2e2;
      color: #dc2626;
      border: 1px solid #fecaca;
    }
    html.theme-dark .status-badge.status-open, html[data-theme='dark'] .status-badge.status-open {
      background-color: rgba(220, 38, 38, 0.15);
      color: #fca5a5;
      border: 1px solid rgba(254, 202, 202, 0.2);
    }
    .status-badge.status-in-progress {
      background-color: #fef3c7;
      color: #d97706;
      border: 1px solid #fde68a;
    }
    html.theme-dark .status-badge.status-in-progress, html[data-theme='dark'] .status-badge.status-in-progress {
      background-color: rgba(217, 119, 6, 0.15);
      color: #fcd34d;
      border: 1px solid rgba(253, 230, 138, 0.2);
    }
    .status-badge.status-resolved {
      background-color: #d1fae5;
      color: #059669;
      border: 1px solid #a7f3d0;
    }
    html.theme-dark .status-badge.status-resolved, html[data-theme='dark'] .status-badge.status-resolved {
      background-color: rgba(5, 150, 105, 0.15);
      color: #6ee7b7;
      border: 1px solid rgba(167, 243, 208, 0.2);
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

    <!-- MAIN CONTENT -->
    <section class="dash-col">
      <!-- Page Header -->
      <div class="page-header">
        <div>
          <h1 class="page-title">Troubleshooting Dashboard</h1>
          <p class="page-subtitle">Monitor and resolve equipment issues</p>
        </div>
        <div class="header-actions">
          <!-- Grid View Button (Purple) -->
          <button type="button" class="btn-icon btn-icon-accent" title="Grid View"
                  onclick="window.open('TroubleshootingGridView.aspx?collapse=true', '_blank'); return false;">
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
          <asp:LinkButton ID="btnViewDetails" runat="server" CssClass="btn-icon btn-icon-amber" 
                          title="View Details" OnClick="btnViewDetails_Click">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round">
              <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
              <circle cx="12" cy="12" r="3"></circle>
            </svg>
          </asp:LinkButton>

          <!-- Add New PM Button (Blue) -->
          <button type="button" class="btn-icon btn-icon-primary" title="New PM"
                  onclick="window.location='TroubleshootingDetails.aspx?mode=new'; return false;">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round">
              <line x1="12" y1="5" x2="12" y2="19"></line>
              <line x1="5" y1="12" x2="19" y2="12"></line>
            </svg>
          </button>
        </div>
      </div>

      <!-- KPI CARDS -->
      <div class="kpi-grid">
        <div class="kpi-card" id="cardTotalIssues" runat="server" onclick="showKPIModal('total')" style="cursor: pointer;">
          <div class="kpi-label">Total Issues</div>
          <div style="display: flex; align-items: center; justify-content: space-between; margin-top: 4px; height: 60px;">
            <div class="kpi-value" style="margin-bottom: 0; color: #2563eb;"><asp:Literal ID="litTotalIssues" runat="server" Text="0" /></div>
            <div style="width: 150px; height: 60px; margin-right: -8px;" onclick="event.stopPropagation();">
              <canvas id="miniLineTotalIssues"></canvas>
            </div>
          </div>
          <div class="kpi-footer" style="margin-top: 8px;">
            <span>All time | Last 12 months trend</span>
          </div>
        </div>
        
        <div class="kpi-card" id="cardOpenIssues" runat="server" onclick="showKPIModal('open')" style="cursor: pointer;">
          <div class="kpi-label">Open Issues</div>
          <div style="display: flex; align-items: center; justify-content: space-between; margin-top: 4px; height: 60px;">
            <div class="kpi-value" style="margin-bottom: 0;"><asp:Literal ID="litOpenIssues" runat="server" Text="0" /></div>
            <div style="width: 120px; height: 40px; margin-right: -4px;" onclick="event.stopPropagation();">
              <canvas id="bulletChartOpenIssues"></canvas>
            </div>
          </div>
          <div class="kpi-footer" style="margin-top: 8px;">
            <span><asp:Literal ID="litCriticalText" runat="server" Text="0 critical priority" /></span>
          </div>
        </div>
        
        <div class="kpi-card" id="cardResolutionTime" runat="server">
          <div class="kpi-label">Avg Resolution Time</div>
          <div style="display: flex; align-items: center; justify-content: space-between; margin-top: 4px; height: 60px;">
            <div class="kpi-value" style="margin-bottom: 0;"><asp:Literal ID="litResolutionTime" runat="server" Text="--h" /></div>
            <div style="width: 150px; height: 60px; margin-right: -8px;">
              <canvas id="miniLineResolutionTime"></canvas>
            </div>
          </div>
          <div class="kpi-footer" style="margin-top: 8px;">
            <span>Last 10 resolutions | Target: &lt;10h</span>
          </div>
        </div>
        
        <div class="kpi-card" id="cardDowntime" runat="server">
          <div class="kpi-label">Total Downtime</div>
          <div style="display: flex; align-items: center; justify-content: space-between; margin-top: 4px; height: 60px;">
            <div class="kpi-value" style="margin-bottom: 0;"><asp:Literal ID="litDowntime" runat="server" Text="--h" /></div>
            <div style="width: 75px; height: 60px; position: relative; margin-right: -4px;">
              <canvas id="gaugeDowntime"></canvas>
            </div>
          </div>
          <div class="kpi-footer" style="margin-top: 8px;">
            <span><asp:Literal ID="litDowntimeText" runat="server" Text="Last 30 days | Target: <30h" /></span>
          </div>
        </div>
        
        <div class="kpi-card" id="cardRepeatIssues" runat="server" onclick="showKPIModal('repeat')" style="cursor: pointer;">
          <div class="kpi-label">Repeat Issues</div>
          <div style="display: flex; align-items: center; justify-content: space-between; margin-top: 4px; height: 60px;">
            <div class="kpi-value" style="margin-bottom: 0; color: #2563eb;"><asp:Literal ID="litRepeatCount" runat="server" Text="--" /></div>
            <div style="width: 75px; height: 60px; margin-right: -8px;" onclick="event.stopPropagation();">
              <canvas id="gaugeRepeatIssues"></canvas>
            </div>
          </div>
          <div class="kpi-footer" style="margin-top: 8px;">
            <span><asp:Literal ID="litRepeatText" runat="server" Text="All time | Rate: X%" /></span>
          </div>
        </div>
      </div>

      <!-- OPEN ISSUES TABLE -->
      <div id="openIssuesTableSection" runat="server" class="chart-card" style="margin-bottom: 24px;">
        <div class="chart-title">Current Open Issues</div>
        <div style="overflow-x: auto; margin-top: 15px;">
          <asp:GridView ID="gvOpenIssues" runat="server" AutoGenerateColumns="False" 
            CssClass="modern-table" GridLines="Both"
            BorderStyle="None" BorderWidth="0" CellPadding="0" CellSpacing="0"
            OnRowDataBound="gvOpenIssues_RowDataBound">
            <HeaderStyle BackColor="#2563eb" ForeColor="White" Font-Bold="True" 
              Font-Size="11px" Height="40px" VerticalAlign="Middle" 
              HorizontalAlign="Center"
              Font-Names="'Segoe UI', sans-serif" />
            <RowStyle CssClass="table-row-light" Font-Size="11px" Height="36px" 
              VerticalAlign="Middle" Font-Names="'Segoe UI', sans-serif" />
            <AlternatingRowStyle CssClass="table-row-alt" />
              <Columns>
                <asp:BoundField DataField="RawID" HeaderText="RawID" Visible="false" />
                <asp:BoundField DataField="TroubleshootingID" HeaderText="ID" 
                  ItemStyle-Width="80px" ItemStyle-CssClass="table-cell-padding"
                  HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center" />
                <asp:TemplateField HeaderText="Priority" ItemStyle-Width="100px" 
                  ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                  <ItemTemplate>
                    <span class='priority-badge priority-<%# Eval("Priority").ToString().ToLower() %>'>
                      <%# Eval("Priority") %>
                    </span>
                  </ItemTemplate>
                </asp:TemplateField>
                <asp:BoundField DataField="ReportedDateTime" HeaderText="Reported Date/Time" 
                  DataFormatString="{0:MM/dd/yyyy HH:mm}" 
                  ItemStyle-Width="140px" ItemStyle-CssClass="table-cell-padding"
                  HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center" />
                <asp:BoundField DataField="Location" HeaderText="Location" 
                  ItemStyle-Width="120px" ItemStyle-CssClass="table-cell-padding"
                  HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center" />
                <asp:BoundField DataField="ReportedBy" HeaderText="Reported By" 
                  ItemStyle-Width="140px" ItemStyle-CssClass="table-cell-padding"
                  HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center" />
                <asp:BoundField DataField="SymptomDescription" HeaderText="Symptom/Issue Description" 
                  ItemStyle-CssClass="table-cell-padding-lr"
                  HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Left" />
                <asp:TemplateField HeaderText="Status" ItemStyle-Width="120px" 
                  ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                  <ItemTemplate>
                    <span class='status-badge status-<%# Eval("Status").ToString().ToLower().Replace(" ", "-") %>'>
                      <%# Eval("Status") %>
                    </span>
                  </ItemTemplate>
                </asp:TemplateField>
              </Columns>
            </asp:GridView>
          </div>
      </div>

      <!-- SANKEY DIAGRAM (Issue Flow) -->
      <div class="chart-card" style="margin-bottom: 24px;">
        <h3 class="chart-title"><strong>Issue Flow:</strong> <span style="font-weight: 400;">Total &rarr; Equipment Type &rarr; Specific Equipment &rarr; Issue Classification</span></h3>
        <div class="chart-container" style="height: 500px;">
          <svg id="sankeyDiagram" style="width: 100%; height: 100%;"></svg>
        </div>
      </div>

      <!-- CHARTS GRID -->
      <div class="chart-grid">
        <div class="chart-card">
          <h3 class="chart-title"><strong>Issue Resolution Flow:</strong> <span style="font-weight: 400;">30-Day Movement</span></h3>
          <div class="chart-container">
            <canvas id="chartWaterfall"></canvas>
          </div>
        </div>
        
        <div class="chart-card">
          <h3 class="chart-title" id="lineChartTitle">
            <span id="lineChartMainTitle">Issues by Line</span>
            <span id="lineChartBackBtn" style="display:none; float:right; cursor:pointer; color:#60a5fa; font-size:13px; font-weight:500;">
              &larr; Back to Lines
            </span>
          </h3>
          <div class="chart-container">
            <canvas id="chartLine"></canvas>
          </div>
        </div>
      </div>

      <!-- RECENT ADDITIONS TABLE -->
      <div id="recentAdditionsTableSection" runat="server" class="chart-card" style="margin-bottom: 24px;">
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
                <p style="margin: 8px 0 0 0; font-size: 11px; opacity: 0.7;">Issues reported in the last 30 days will appear here.</p>
              </div>
            </EmptyDataTemplate>
              <Columns>
                <asp:BoundField DataField="RawID" HeaderText="RawID" Visible="false" />
                <asp:BoundField DataField="TroubleshootingID" HeaderText="ID" 
                  ItemStyle-Width="80px" ItemStyle-CssClass="table-cell-padding"
                  HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center" />
                <asp:TemplateField HeaderText="Priority" ItemStyle-Width="100px" 
                  ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                  <ItemTemplate>
                    <span class='priority-badge priority-<%# Eval("Priority").ToString().ToLower() %>'>
                      <%# Eval("Priority") %>
                    </span>
                  </ItemTemplate>
                </asp:TemplateField>
                <asp:BoundField DataField="ReportedDateTime" HeaderText="Reported Date/Time" 
                  DataFormatString="{0:MM/dd/yyyy HH:mm}" 
                  ItemStyle-Width="140px" ItemStyle-CssClass="table-cell-padding"
                  HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center" />
                <asp:BoundField DataField="Location" HeaderText="Location" 
                  ItemStyle-Width="120px" ItemStyle-CssClass="table-cell-padding"
                  HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center" />
                <asp:BoundField DataField="ReportedBy" HeaderText="Reported By" 
                  ItemStyle-Width="140px" ItemStyle-CssClass="table-cell-padding"
                  HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center" />
                <asp:BoundField DataField="SymptomDescription" HeaderText="Symptom/Issue Description" 
                  ItemStyle-CssClass="table-cell-padding-lr"
                  HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Left" />
                <asp:TemplateField HeaderText="Status" ItemStyle-Width="120px" 
                  ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                  <ItemTemplate>
                    <span class='status-badge status-<%# Eval("Status").ToString().ToLower().Replace(" ", "-") %>'>
                      <%# Eval("Status") %>
                    </span>
                  </ItemTemplate>
                </asp:TemplateField>
              </Columns>
            </asp:GridView>
          </div>
      </div>

    </section>
  </div>

  <script type="text/javascript">
    // THEME-REACTIVE CHART COLORS
    let chartInstances = {};
    
    // Line chart drill-down state (global scope for theme changes)
    let currentView = 'line'; // 'line' or 'location'
    let currentLine = null;
    
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

      // ===== SANKEY DIAGRAM =====
      initializeSankeyDiagram(colors);

      // ===== MINI-LINE CHART - Total Issues (12 months trend) =====
      const ctxMiniLineTotalIssues = document.getElementById('miniLineTotalIssues');
      if (ctxMiniLineTotalIssues) {
        const monthlyLabels = <%= MonthlyLabels %> || [];
        const monthlyData = <%= MonthlyData %> || [];
        
        // Simple blue line for total issues trend
        chartInstances.miniLineTotalIssues = new Chart(ctxMiniLineTotalIssues, {
          type: 'line',
          data: {
            labels: monthlyLabels,
            datasets: [{
              label: 'Issues',
              data: monthlyData,
              borderColor: colors.primary,
              backgroundColor: colors.isDark ? 'rgba(77,141,255,0.15)' : 'rgba(77,141,255,0.1)',
              borderWidth: 2,
              fill: true,
              tension: 0.3,
              pointRadius: 2,
              pointBackgroundColor: colors.primary,
              pointBorderColor: colors.isDark ? 'rgba(15,23,42,1)' : '#ffffff',
              pointBorderWidth: 1.5,
              pointHoverRadius: 3.5
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
                titleFont: { size: 10, weight: '600' },
                bodyFont: { size: 10 },
                displayColors: true,
                callbacks: {
                  title: function(context) { return context[0].label; },
                  label: function(context) { return 'Issues: ' + context.parsed.y; }
                }
              },
              datalabels: { display: false }
            },
            scales: {
              y: { beginAtZero: true, display: false },
              x: { display: false }
            },
            layout: { padding: 0 }
          }
        });
      }

      // ===== BULLET CHART - Open Issues (Critical Priority) =====
      const ctxBulletChartOpenIssues = document.getElementById('bulletChartOpenIssues');
      if (ctxBulletChartOpenIssues) {
        const openIssues = parseInt(<%= OpenIssuesCount %> || 0);
        const criticalIssues = parseInt(<%= CriticalCount %> || 0);
        
        chartInstances.bulletChartOpenIssues = new Chart(ctxBulletChartOpenIssues, {
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
              },
              datalabels: { display: false }
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

      // ===== MINI-LINE CHART - Resolution Time (Last 10 resolutions) =====
      const ctxMiniLineResTime = document.getElementById('miniLineResolutionTime');
      if (ctxMiniLineResTime) {
        const resolutionTimes = <%= ResolutionTimesData %> || [];
        const troubleshootingIDs = <%= TroubleshootingIDs %> || [];
        const avgResTime = parseFloat(<%= AvgResolutionTime %> || 0);
        const targetTime = 10; // Target: <10h
        
        // Debug logging
        console.log('TroubleshootingIDs:', troubleshootingIDs);
        console.log('ResolutionTimes:', resolutionTimes);
        
        // Determine color based on average vs target
        const isCompliant = avgResTime < targetTime;
        const lineColor = isCompliant ? colors.success : colors.danger;
        const fillColor = isCompliant 
          ? (colors.isDark ? 'rgba(16,185,129,0.15)' : 'rgba(16,185,129,0.1)')
          : (colors.isDark ? 'rgba(239,68,68,0.15)' : 'rgba(239,68,68,0.1)');
        
        // Create labels (1, 2, 3, ..., 10)
        const labels = resolutionTimes.map((_, idx) => (idx + 1).toString());
        
        // Create average line (dashed)
        const avgLine = new Array(resolutionTimes.length).fill(avgResTime);
        
        chartInstances.miniLineResTime = new Chart(ctxMiniLineResTime, {
          type: 'line',
          data: {
            labels: labels,
            datasets: [
              {
                label: 'Resolution Time',
                data: resolutionTimes,
                borderColor: lineColor,
                backgroundColor: fillColor,
                borderWidth: 2,
                fill: true,
                tension: 0.3,
                pointRadius: 2.5,
                pointBackgroundColor: lineColor,
                pointBorderColor: colors.isDark ? 'rgba(15,23,42,1)' : '#ffffff',
                pointBorderWidth: 1.5,
                pointHoverRadius: 4
              },
              {
                label: 'Average (' + avgResTime.toFixed(2) + 'h)',
                data: avgLine,
                borderColor: colors.isDark ? 'rgba(255,255,255,0.4)' : 'rgba(0,0,0,0.3)',
                backgroundColor: 'transparent',
                borderWidth: 1,
                borderDash: [4, 4],
                fill: false,
                tension: 0,
                pointRadius: 0,
                pointHoverRadius: 0
              }
            ]
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
                titleFont: { size: 10, weight: '600' },
                bodyFont: { size: 10 },
                displayColors: true,
                callbacks: {
                  title: function(context) { 
                    const index = context[0].dataIndex;
                    const tsID = troubleshootingIDs[index];
                    return tsID || 'Resolution #' + context[0].label; 
                  },
                  label: function(context) {
                    if (context.datasetIndex === 0) {
                      const hours = context.parsed.y;
                      if (hours < 1) {
                        const minutes = Math.round(hours * 60);
                        return 'Time: ' + minutes + 'm';
                      } else {
                        const h = Math.floor(hours);
                        const m = Math.round((hours - h) * 60);
                        if (m > 0) {
                          return 'Time: ' + h + 'h ' + m + 'm';
                        } else {
                          return 'Time: ' + h + 'h';
                        }
                      }
                    } else {
                      const hours = avgResTime;
                      if (hours < 1) {
                        const minutes = Math.round(hours * 60);
                        return 'Avg: ' + minutes + 'm';
                      } else {
                        const h = Math.floor(hours);
                        const m = Math.round((hours - h) * 60);
                        if (m > 0) {
                          return 'Avg: ' + h + 'h ' + m + 'm';
                        } else {
                          return 'Avg: ' + h + 'h';
                        }
                      }
                    }
                  }
                }
              },
              datalabels: { display: false }
            },
            scales: {
              y: {
                beginAtZero: true,
                display: false
              },
              x: {
                display: false
              }
            },
            layout: {
              padding: 0
            }
          }
        });
      }

      // ===== GAUGE CHART - Total Downtime (Compact inline) =====
      const ctxGaugeDowntime = document.getElementById('gaugeDowntime');
      if (ctxGaugeDowntime) {
        const downtimeHours = parseFloat(<%= TotalDowntimeHours %> || 0);
        const maxDowntime = 60; // Max scale for gauge (60 hours = 2x target)
        const downtimePercentage = Math.min((downtimeHours / maxDowntime) * 100, 100);
        const remainingValue = 100 - downtimePercentage;
        
        // Color based on new threshold: Green (<15h), Amber (15-30h), Red (>30h)
        let gaugeColor;
        if (downtimeHours < 15) {
          gaugeColor = colors.success;
        } else if (downtimeHours < 30) {
          gaugeColor = colors.warning;
        } else {
          gaugeColor = colors.danger;
        }
        
        chartInstances.gaugeDowntime = new Chart(ctxGaugeDowntime, {
          type: 'doughnut',
          data: {
            datasets: [{
              data: [downtimePercentage, remainingValue],
              backgroundColor: [
                gaugeColor,
                colors.isDark ? 'rgba(255,255,255,0.05)' : 'rgba(0,0,0,0.05)'
              ],
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
                  // Tooltip Element
                  let tooltipEl = document.getElementById('chartjs-tooltip-downtime');
                  
                  // Create element on first render
                  if (!tooltipEl) {
                    tooltipEl = document.createElement('div');
                    tooltipEl.id = 'chartjs-tooltip-downtime';
                    tooltipEl.style.position = 'absolute';
                    tooltipEl.style.pointerEvents = 'none';
                    tooltipEl.style.transition = 'all .2s ease';
                    document.body.appendChild(tooltipEl);
                  }
                  
                  // Hide if no tooltip
                  const tooltipModel = context.tooltip;
                  if (tooltipModel.opacity === 0) {
                    tooltipEl.style.opacity = 0;
                    return;
                  }
                  
                  // Set Text
                  if (tooltipModel.body) {
                    const titleLines = ['Total Downtime'];
                    const bodyLines = [downtimeHours.toFixed(1) + 'h (Target: <30h)'];
                    
                    let innerHtml = '<div style="background:' + colors.tooltipBg + ';color:' + colors.text + ';border:1px solid ' + colors.tooltipBorder + ';border-radius:4px;padding:8px;font-size:10px;box-shadow:0 2px 8px rgba(0,0,0,0.3);">';
                    innerHtml += '<div style="font-weight:600;margin-bottom:4px;">' + titleLines[0] + '</div>';
                    innerHtml += '<div>' + bodyLines[0] + '</div>';
                    innerHtml += '</div>';
                    
                    tooltipEl.innerHTML = innerHtml;
                  }
                  
                  const position = context.chart.canvas.getBoundingClientRect();
                  
                  // Display, position, and set styles for font
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

      // ===== GAUGE CHART - Repeat Issues Percentage =====
      const ctxGaugeRepeatIssues = document.getElementById('gaugeRepeatIssues');
      if (ctxGaugeRepeatIssues) {
        const repeatRate = parseFloat(<%= RepeatIssueRate %> || 0);
        const repeatRemaining = Math.max(0, 100 - repeatRate);
        
        chartInstances.gaugeRepeatIssues = new Chart(ctxGaugeRepeatIssues, {
          type: 'doughnut',
          data: {
            labels: ['Repeat Issues', 'Non-Repeat'],
            datasets: [{
              data: [repeatRate, repeatRemaining],
              backgroundColor: [
                colors.isDark ? '#60a5fa' : '#2563eb',  // Blue for repeat (matches text)
                colors.isDark ? 'rgba(51,65,85,0.3)' : 'rgba(226,232,240,0.4)'
              ],
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
                  let tooltipEl = document.getElementById('chartjs-tooltip-repeat');
                  
                  if (!tooltipEl) {
                    tooltipEl = document.createElement('div');
                    tooltipEl.id = 'chartjs-tooltip-repeat';
                    tooltipEl.style.position = 'absolute';
                    tooltipEl.style.pointerEvents = 'none';
                    tooltipEl.style.transition = 'all .2s ease';
                    document.body.appendChild(tooltipEl);
                  }
                  
                  const tooltipModel = context.tooltip;
                  if (tooltipModel.opacity === 0) {
                    tooltipEl.style.opacity = 0;
                    return;
                  }
                  
                  if (tooltipModel.body) {
                    const dataIndex = tooltipModel.dataPoints[0].dataIndex;
                    let titleText = '';
                    let bodyText = '';
                    
                    if (dataIndex === 0) {
                      titleText = 'Repeat Issues';
                      bodyText = repeatRate.toFixed(1) + '% of total issues';
                    } else {
                      titleText = 'Non-Repeat Issues';
                      bodyText = (100 - repeatRate).toFixed(1) + '% of total issues';
                    }
                    
                    let innerHtml = '<div style="background:' + colors.tooltipBg + ';color:' + colors.text + ';border:1px solid ' + colors.tooltipBorder + ';border-radius:4px;padding:8px;font-size:10px;box-shadow:0 2px 8px rgba(0,0,0,0.3);">';
                    innerHtml += '<div style="font-weight:600;margin-bottom:4px;">' + titleText + '</div>';
                    innerHtml += '<div>' + bodyText + '</div>';
                    innerHtml += '</div>';
                    
                    tooltipEl.innerHTML = innerHtml;
                  }
                  
                  const position = context.chart.canvas.getBoundingClientRect();
                  tooltipEl.style.opacity = 1;
                  tooltipEl.style.left = position.left + window.pageXOffset + 10 + 'px';
                  tooltipEl.style.top = position.top + window.pageYOffset + position.height / 2 + 'px';
                }
              },
              datalabels: {
                display: false
              }
            }
          }
        });
      }

      // ===== WATERFALL CHART =====
      const ctxWaterfall = document.getElementById('chartWaterfall');
      if (ctxWaterfall) {
        const waterfallLabels = <%= WaterfallLabels %>;
        const waterfallData = <%= WaterfallData %>;
        const waterfallColorMap = <%= WaterfallColors %>;
        
        // Calculate deltas for display
        const deltas = [
          waterfallData[0],  // Start value (absolute)
          waterfallData[1] - waterfallData[0],  // New issues (positive)
          waterfallData[2] - waterfallData[1],  // Resolved (negative)
          waterfallData[3] - waterfallData[2],  // Closed (negative)
          waterfallData[4]   // Current (absolute)
        ];
        
        // Create floating bars for waterfall effect
        const waterfallBarData = deltas.map((delta, idx) => {
          if (idx === 0 || idx === deltas.length - 1) {
            // Start and end are from 0
            return [0, waterfallData[idx]];
          } else {
            // Middle bars float from previous cumulative to current cumulative
            return [waterfallData[idx - 1], waterfallData[idx]];
          }
        });
        
        // Assign colors based on type
        const barColors = waterfallColorMap.map(colorType => {
          if (colorType === 'increase') return colors.danger;   // Red for increases (new issues)
          if (colorType === 'decrease') return colors.success;  // Green for decreases (resolved/closed)
          if (colorType === 'danger') return colors.danger;     // Red for Current Open >5
          if (colorType === 'warning') return colors.warning;   // Orange for Current Open 1-5
          if (colorType === 'success') return colors.success;   // Green for Current Open = 0
          return colors.primary;  // Blue for neutral (start)
        });
        
        chartInstances.waterfall = new Chart(ctxWaterfall, {
          type: 'bar',
          data: {
            labels: waterfallLabels,
            datasets: [{
              label: 'Issues',
              data: waterfallBarData,
              backgroundColor: barColors,
              borderWidth: 0,
              borderRadius: 12,
              barThickness: 60
            }]
          },
          options: {
            indexAxis: 'x',
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
                  label: function(context) {
                    const idx = context.dataIndex;
                    const value = deltas[idx];
                    const absValue = Math.abs(value);
                    if (idx === 0 || idx === deltas.length - 1) {
                      return 'Total: ' + absValue + ' issues';
                    } else {
                      const sign = value > 0 ? '+' : '';
                      return sign + value + ' issues';
                    }
                  }
                }
              },
              datalabels: {
                anchor: 'end',
                align: function(context) {
                  const idx = context.dataIndex;
                  return deltas[idx] < 0 ? 'start' : 'end';
                },
                color: colors.text,
                font: { size: 11, weight: '600', family: "'Segoe UI', sans-serif" },
                formatter: function(value, context) {
                  const idx = context.dataIndex;
                  const delta = deltas[idx];
                  if (idx === 0 || idx === deltas.length - 1) {
                    return delta; // Show absolute value for start/end
                  } else {
                    return delta > 0 ? '+' + delta : delta; // Show delta with sign
                  }
                }
              }
            },
            scales: {
              y: {
                beginAtZero: true,
                ticks: { 
                  precision: 0, 
                  color: colors.textSecondary, 
                  font: { size: 11, family: "'Segoe UI', sans-serif" } 
                },
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

      // 1. Issue Classification Chart (Bar)
      const ctxClassification = document.getElementById('chartClassification');
      if (ctxClassification) {
        chartInstances.classification = new Chart(ctxClassification, {
          type: 'bar',
          data: {
            labels: <%= ClassificationLabels %>,
            datasets: [{
              label: 'Issues',
              data: <%= ClassificationData %>,
              backgroundColor: colors.primary,
              borderWidth: 0,
              borderRadius: 12
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

      // 4. Resolution Time Chart (Bar)
      const ctxResolutionTime = document.getElementById('chartResolutionTime');
      if (ctxResolutionTime) {
        chartInstances.resolutionTime = new Chart(ctxResolutionTime, {
          type: 'bar',
          data: {
            labels: <%= ResolutionTimeLabels %>,
            datasets: [{
              label: 'Avg Hours',
              data: <%= ResolutionTimeData %>,
              backgroundColor: colors.warning,
              borderWidth: 0,
              borderRadius: 12
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
                  label: function(context) {
                    return 'Avg: ' + context.parsed.y.toFixed(1) + 'h';
                  }
                }
              },
              datalabels: {
                anchor: function(context) {
                  const value = context.dataset.data[context.dataIndex];
                  const max = Math.max(...context.dataset.data);
                  return value >= max * 0.95 ? 'end' : 'end';
                },
                align: function(context) {
                  const value = context.dataset.data[context.dataIndex];
                  const max = Math.max(...context.dataset.data);
                  return value >= max * 0.95 ? 'start' : 'top';
                },
                offset: function(context) {
                  const value = context.dataset.data[context.dataIndex];
                  const max = Math.max(...context.dataset.data);
                  return value >= max * 0.95 ? -8 : 0;
                },
                color: function(context) {
                  const value = context.dataset.data[context.dataIndex];
                  const max = Math.max(...context.dataset.data);
                  // Inside labels: white in dark mode, black in light mode for visibility
                  if (value >= max * 0.95) {
                    return colors.isDark ? '#ffffff' : '#000000';
                  }
                  return colors.text;
                },
                font: { size: 11, weight: '600', family: "'Segoe UI', sans-serif" },
                formatter: function(value) { return value.toFixed(1) + 'h'; }
              }
            },
            scales: {
              y: {
                beginAtZero: true,
                ticks: { 
                  color: colors.textSecondary, 
                  font: { size: 11, family: "'Segoe UI', sans-serif" },
                  callback: function(value) { return value + 'h'; }
                },
                grid: { display: false }
              },
              x: {
                ticks: { color: colors.textSecondary, font: { size: 11, family: "'Segoe UI', sans-serif" } },
                grid: { display: false }
              }
            }
          }
        });
      }

      // 5. Equipment Type Chart (Doughnut)
      const ctxEquipment = document.getElementById('chartEquipmentType');
      if (ctxEquipment) {
        const equipmentLabels = <%= EquipmentTypeLabels %>;
        const equipmentData = <%= EquipmentTypeData %>;
        
        chartInstances.equipment = new Chart(ctxEquipment, {
          type: 'doughnut',
          data: {
            labels: equipmentLabels,
            datasets: [{
              data: equipmentData,
              backgroundColor: [colors.primary, colors.success, colors.purple, colors.orange, colors.teal, colors.danger, colors.warning],
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

      // 6. Issues by Equipment Chart (Horizontal Bar)
      const ctxIssuesByEquipment = document.getElementById('chartEquipment');
      if (ctxIssuesByEquipment) {
        const issuesEquipmentLabels = <%= EquipmentLabels %>;
        const issuesEquipmentData = <%= EquipmentData %>;
        
        chartInstances.issuesByEquipment = new Chart(ctxIssuesByEquipment, {
          type: 'bar',
          data: {
            labels: issuesEquipmentLabels,
            datasets: [{
              label: 'Issue Count',
              data: issuesEquipmentData,
              backgroundColor: colors.orange,
              borderWidth: 0,
              borderRadius: 12
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
                formatter: (value) => value
              }
            },
            scales: {
              x: {
                beginAtZero: true,
                ticks: { color: colors.text, font: { size: 11, family: "'Segoe UI', sans-serif" } },
                grid: { display: false }
              },
              y: {
                ticks: { 
                  color: colors.text, 
                  font: { size: 10, family: "'Segoe UI', sans-serif" }
                },
                grid: { display: false }
              }
            }
          }
        });
      }

      // Initialize Line chart (with drill-down)
      initializeLineChart();
    }

    // 7. Issues by Line Chart (Drill-Down with Location)
    function initializeLineChart() {
      const ctx = document.getElementById('chartLine');
      if (!ctx) return;
      
      const colors = getChartColors();
      
      // Destroy existing chart
      if (chartInstances.line) {
        chartInstances.line.destroy();
      }
        
        // Get data based on current view
        let labels, data, titleText, chartColor;
        
        if (currentView === 'line') {
          labels = <%= LineLabels %>;
          data = <%= LineData %>;
          titleText = 'Issues by Line';
          chartColor = colors.primary;
          document.getElementById('lineChartMainTitle').textContent = titleText;
          document.getElementById('lineChartBackBtn').style.display = 'none';
        } else {
          // Drill-down view
          const drillDownData = <%= DrillDownData %>;
          const locationData = drillDownData[currentLine] || [];
          labels = locationData.map(d => d.location);
          data = locationData.map(d => d.count);
          titleText = 'Issues by Location (' + currentLine + ')';
          chartColor = colors.orange;
          document.getElementById('lineChartMainTitle').textContent = titleText;
          document.getElementById('lineChartBackBtn').style.display = 'inline';
        }
        
        chartInstances.line = new Chart(ctx, {
          type: 'bar',
          data: {
            labels: labels,
            datasets: [{
              label: 'Issues',
              data: data,
              backgroundColor: chartColor,
              borderColor: chartColor,
              borderWidth: 0,
              borderRadius: 12,
              barThickness: 'flex',
              maxBarThickness: 50
            }]
          },
          options: {
            indexAxis: 'y',
            responsive: true,
            maintainAspectRatio: false,
            onClick: (event, activeElements) => {
              if (currentView === 'line' && activeElements.length > 0) {
                // Drill down into line
                const index = activeElements[0].index;
                currentLine = labels[index];
                currentView = 'location';
                initializeLineChart();
              }
            },
            onHover: (event, activeElements) => {
              if (currentView === 'line') {
                event.native.target.style.cursor = activeElements.length > 0 ? 'pointer' : 'default';
              } else {
                event.native.target.style.cursor = 'default';
              }
            },
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
                titleFont: { size: 12, weight: '600', family: "'Inter', 'Segoe UI', sans-serif" },
                bodyFont: { size: 11, family: "'Inter', 'Segoe UI', sans-serif" },
                callbacks: {
                  label: function(context) {
                    return 'Issues: ' + context.parsed.x;
                  },
                  afterLabel: function(context) {
                    if (currentView === 'line') {
                      return 'Click to drill down';
                    }
                    return '';
                  }
                }
              },
              datalabels: {
                anchor: function(context) {
                  const value = context.dataset.data[context.dataIndex];
                  const max = Math.max(...context.dataset.data);
                  // If value is at or near max (within 95%), anchor inside
                  return value >= max * 0.95 ? 'end' : 'end';
                },
                align: function(context) {
                  const value = context.dataset.data[context.dataIndex];
                  const max = Math.max(...context.dataset.data);
                  // If value is at or near max (within 95%), align inside (left)
                  return value >= max * 0.95 ? 'start' : 'end';
                },
                offset: function(context) {
                  const value = context.dataset.data[context.dataIndex];
                  const max = Math.max(...context.dataset.data);
                  // Add offset for inside labels
                  return value >= max * 0.95 ? -8 : 0;
                },
                color: function(context) {
                  const value = context.dataset.data[context.dataIndex];
                  const max = Math.max(...context.dataset.data);
                  // Inside labels: white in dark mode, black in light mode for visibility
                  if (value >= max * 0.95) {
                    return colors.isDark ? '#ffffff' : '#000000';
                  }
                  return colors.text;
                },
                font: { size: 11, weight: '600', family: "'Segoe UI', sans-serif" },
                formatter: (value) => value
              }
            },
            scales: {
              x: {
                beginAtZero: true,
                ticks: { 
                  precision: 0, 
                  color: colors.textSecondary,
                  font: { size: 11, family: "'Inter', 'Segoe UI', sans-serif" }
                },
                grid: { color: colors.grid }
              },
              y: {
                ticks: { 
                  color: colors.text,
                  font: { size: 10, family: "'Inter', 'Segoe UI', sans-serif" }
                },
                grid: { display: false }
              }
            }
          }
        });
    }

    // Back button handler for Line chart drill-down
    document.addEventListener('DOMContentLoaded', function() {
      const backBtn = document.getElementById('lineChartBackBtn');
      if (backBtn) {
        backBtn.addEventListener('click', function(e) {
          e.stopPropagation();
          currentView = 'line';
          currentLine = null;
          initializeLineChart();
        });
      }
    });

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
          .style('font-family', "'Inter', 'Segoe UI', system-ui, -apple-system, sans-serif")
          .style('font-size', '14px')
          .text('No issue data available');
        return;
      }
      
      // Define enhanced color mapping for equipment types and classifications (dark mode optimized)
      const equipmentColors = {
        'Total Issues': colors.isDark ? '#60a5fa' : colors.primary,
        'ATE': colors.isDark ? '#fb923c' : colors.orange,
        'Asset': colors.isDark ? '#34d399' : colors.success,
        'Fixture': colors.isDark ? '#c084fc' : colors.purple,
        'Harness': colors.isDark ? '#fbbf24' : colors.warning
      };
      
      // Classification colors (softer tones for last level) - enhanced for dark mode
      const classificationColors = {
        'Hardware': colors.isDark ? '#f87171' : colors.danger,
        'Software': colors.isDark ? '#60a5fa' : colors.primary,
        'Electrical': colors.isDark ? '#fbbf24' : colors.warning,
        'Mechanical': colors.isDark ? '#c084fc' : colors.purple,
        'Calibration': colors.isDark ? '#34d399' : colors.success,
        'Human Error': colors.isDark ? '#9ca3af' : colors.textSecondary,
        'Not Related to Test': colors.isDark ? '#14b8a6' : colors.teal,
        'Unclassified': colors.isDark ? '#9ca3af' : colors.textSecondary,
        'default': colors.isDark ? '#14b8a6' : colors.teal
      };
      
      function getNodeColor(node) {
        const nodeName = node.name;
        
        // Check equipment types first
        for (const key in equipmentColors) {
          if (nodeName === key) {
            return equipmentColors[key];
          }
        }
        
        // Check if it's an equipment node (has 'type' property from C#)
        if (node.type) {
          return equipmentColors[node.type] || (colors.isDark ? '#14b8a6' : colors.teal);
        }
        
        // Check classifications
        if (classificationColors[nodeName]) {
          return classificationColors[nodeName];
        }
        
        return classificationColors['default'];
      }
      
      // Create Sankey generator with better spacing
      const sankey = d3.sankey()
        .nodeWidth(18)
        .nodePadding(12)
        .extent([[60, 40], [width - 160, height - 40]])
        .nodeAlign(d3.sankeyLeft)
        .nodeSort(null);
      
      // Generate Sankey layout
      const graph = sankey({
        nodes: sankeyData.nodes.map(d => Object.assign({}, d)),
        links: sankeyData.links.map(d => Object.assign({}, d))
      });
      
      // Create gradient for links with enhanced dark mode visibility
      const defs = svg.append('defs');
      const linkOpacity = colors.isDark ? 0.5 : 0.35;
      
      graph.links.forEach((link, i) => {
        const gradient = defs.append('linearGradient')
          .attr('id', 'gradient-' + i)
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
      
      // Draw links
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
          
          // Show tooltip
          const tooltip = d3.select('body').append('div')
            .attr('class', 'sankey-tooltip')
            .style('position', 'absolute')
            .style('background', colors.tooltipBg)
            .style('border', '1px solid ' + colors.tooltipBorder)
            .style('border-radius', '8px')
            .style('padding', '10px 14px')
            .style('font-family', "'Inter', 'Segoe UI', system-ui, -apple-system, sans-serif")
            .style('font-size', '13px')
            .style('color', colors.text)
            .style('box-shadow', '0 4px 12px rgba(0,0,0,0.15)')
            .style('pointer-events', 'none')
            .style('z-index', '10000')
            .style('backdrop-filter', 'blur(10px)')
            .html('<strong>' + d.source.name + ' &rarr; ' + d.target.name + '</strong><br/>' +
                  '<span style="color:' + colors.textSecondary + '">Issues: ' + d.value + '</span>')
            .style('left', (event.pageX + 10) + 'px')
            .style('top', (event.pageY - 10) + 'px');
          
          d3.select(this).attr('data-tooltip', 'true');
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
          
          // Calculate total issues for node
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
            .style('font-family', "'Inter', 'Segoe UI', system-ui, -apple-system, sans-serif")
            .style('font-size', '13px')
            .style('color', colors.text)
            .style('box-shadow', '0 4px 12px rgba(0,0,0,0.15)')
            .style('pointer-events', 'none')
            .style('z-index', '10000')
            .style('backdrop-filter', 'blur(10px)')
            .html('<strong>' + d.name + '</strong><br/>' +
                  '<span style="color:' + colors.textSecondary + '">Total Issues: ' + total + '</span>')
            .style('left', (event.pageX + 10) + 'px')
            .style('top', (event.pageY - 10) + 'px');
        })
        .on('mouseout', function(event, d) {
          d3.select(this).attr('fill', getNodeColor(d));
          d3.selectAll('.sankey-tooltip').remove();
        });
      
      // Add node labels with modern font
      const labelGroup = svg.append('g')
        .attr('class', 'labels');
        
      labelGroup.selectAll('text')
        .data(graph.nodes)
        .join('text')
        .attr('x', d => d.x0 < width / 2 ? d.x1 + 8 : d.x0 - 8)
        .attr('y', d => (d.y1 + d.y0) / 2)
        .attr('dy', '0.35em')
        .attr('text-anchor', d => d.x0 < width / 2 ? 'start' : 'end')
        .attr('fill', colors.text)
        .style('font-family', "'Inter', 'Segoe UI', system-ui, -apple-system, sans-serif")
        .style('font-size', d => {
          // Larger font for main nodes
          if (d.name === 'Total Issues') return '14px';
          if (['ATE', 'Asset', 'Fixture', 'Harness'].includes(d.name)) return '13px';
          return '11px';
        })
        .style('font-weight', d => {
          if (d.name === 'Total Issues') return '700';
          if (['ATE', 'Asset', 'Fixture', 'Harness'].includes(d.name)) return '600';
          return '500';
        })
        .style('letter-spacing', '0.3px')
        .text(d => {
          // Shorten long equipment names
          if (d.name.length > 20) {
            return d.name.substring(0, 17) + '...';
          }
          return d.name;
        })
        .append('title')
        .text(d => d.name); // Full name on hover
    }

    // Initialize charts on page load
    document.addEventListener('DOMContentLoaded', initializeCharts);

    // Reinitialize charts on theme change
    const themeObserver = new MutationObserver(function(mutations) {
      mutations.forEach(function(mutation) {
        if (mutation.type === 'attributes' && 
            (mutation.attributeName === 'class' || mutation.attributeName === 'data-theme')) {
          setTimeout(initializeCharts, 50);
        }
      });
    });

    themeObserver.observe(document.documentElement, {
      attributes: true,
      attributeFilter: ['class', 'data-theme']
    });

    // ===== MODERN MODAL FOR ISSUE DETAILS =====
    function showIssueDetailsModal(issueId, displayId) {
      // Create modal backdrop
      const modalBackdrop = document.createElement('div');
      modalBackdrop.id = 'issueDetailsBackdrop';
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
            background: linear-gradient(135deg, #3b82f6, #2563eb);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 20px;
            box-shadow: 0 8px 24px rgba(37, 99, 235, 0.3);
          ">
            <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path>
              <polyline points="14 2 14 8 20 8"></polyline>
              <line x1="16" y1="13" x2="8" y2="13"></line>
              <line x1="16" y1="17" x2="8" y2="17"></line>
              <polyline points="10 9 9 9 8 9"></polyline>
            </svg>
          </div>
          <h3 style="
            margin: 0 0 12px 0;
            font-size: 24px;
            font-weight: 700;
            color: ${textColor};
            font-family: 'Segoe UI', sans-serif;
          ">View Issue Details?</h3>
          <p style="
            margin: 0 0 8px 0;
            font-size: 14px;
            color: ${secondaryText};
            line-height: 1.5;
          ">Would you like to view detailed information for:</p>
          <p style="
            margin: 0 0 28px 0;
            font-size: 16px;
            font-weight: 600;
            color: #3b82f6;
          ">${displayId}</p>
          <div style="display: flex; gap: 12px; justify-content: center;">
            <button onclick="navigateToDetails('${issueId}')" style="
              background: linear-gradient(135deg, #3b82f6, #2563eb);
              color: white;
              border: none;
              padding: 12px 32px;
              border-radius: 8px;
              font-size: 14px;
              font-weight: 600;
              cursor: pointer;
              transition: all 0.2s ease;
              box-shadow: 0 4px 12px rgba(37, 99, 235, 0.3);
              font-family: 'Segoe UI', sans-serif;
            " onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 6px 16px rgba(37, 99, 235, 0.4)';" 
               onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 4px 12px rgba(37, 99, 235, 0.3)';">
              Yes, View Details
            </button>
            <button onclick="closeIssueDetailsModal()" style="
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

      // Close on backdrop click
      modalBackdrop.addEventListener('click', function(e) {
        if (e.target === modalBackdrop) {
          closeIssueDetailsModal();
        }
      });

      // Close on ESC key
      document.addEventListener('keydown', handleEscKey);
    }

    function closeIssueDetailsModal() {
      const backdrop = document.getElementById('issueDetailsBackdrop');
      if (backdrop) {
        backdrop.style.animation = 'fadeOut 0.2s ease';
        setTimeout(() => backdrop.remove(), 200);
      }
      document.removeEventListener('keydown', handleEscKey);
    }

    function handleEscKey(e) {
      if (e.key === 'Escape') {
        closeIssueDetailsModal();
      }
    }

    function navigateToDetails(issueId) {
      closeIssueDetailsModal();
      window.location.href = 'TroubleshootingDetails.aspx?id=' + issueId;
    }

    // ===== KPI CARD MODAL =====
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
          title = 'View All Issues';
          description = 'Open the grid view to see all troubleshooting issues';
          color = '#2563eb';
          icon = `<svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <rect x="3" y="3" width="7" height="7"></rect>
            <rect x="14" y="3" width="7" height="7"></rect>
            <rect x="14" y="14" width="7" height="7"></rect>
            <rect x="3" y="14" width="7" height="7"></rect>
          </svg>`;
          targetUrl = 'TroubleshootingGridView.aspx?collapsed=true';
          break;
        case 'open':
          title = 'View Open Issues';
          description = 'Open the grid view filtered to show only unresolved issues';
          color = '#dc2626';
          icon = `<svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <circle cx="12" cy="12" r="10"></circle>
            <line x1="12" y1="8" x2="12" y2="12"></line>
            <line x1="12" y1="16" x2="12.01" y2="16"></line>
          </svg>`;
          targetUrl = 'TroubleshootingGridView.aspx?isResolved=No&collapsed=true';
          break;
        case 'repeat':
          title = 'View Repeat Issues';
          description = 'Open the grid view filtered to show only repeat issues';
          color = '#2563eb';
          icon = `<svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <polyline points="23 4 23 10 17 10"></polyline>
            <polyline points="1 20 1 14 7 14"></polyline>
            <path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15"></path>
          </svg>`;
          targetUrl = 'TroubleshootingGridView.aspx?isRepeat=Yes&collapsed=true';
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

      // Close on backdrop click
      modalBackdrop.addEventListener('click', function(e) {
        if (e.target === modalBackdrop) {
          closeKPIModal();
        }
      });

      // Close on ESC key
      document.addEventListener('keydown', handleKPIEscKey);
    }

    function closeKPIModal() {
      const backdrop = document.getElementById('kpiModalBackdrop');
      if (backdrop) {
        backdrop.style.animation = 'fadeOut 0.2s ease';
        setTimeout(() => backdrop.remove(), 200);
      }
      document.removeEventListener('keydown', handleKPIEscKey);
    }

    function handleKPIEscKey(e) {
      if (e.key === 'Escape') {
        closeKPIModal();
      }
    }

    function navigateToGridView(url) {
      closeKPIModal();
      window.open(url, '_blank');
    }

    function adjustColor(color, percent) {
      // Simple color adjustment for gradient
      const num = parseInt(color.replace('#',''), 16);
      const amt = Math.round(2.55 * percent);
      const R = (num >> 16) + amt;
      const G = (num >> 8 & 0x00FF) + amt;
      const B = (num & 0x0000FF) + amt;
      return '#' + (0x1000000 + (R<255?R<1?0:R:255)*0x10000 +
        (G<255?G<1?0:G:255)*0x100 + (B<255?B<1?0:B:255))
        .toString(16).slice(1);
    }

    // Add CSS animations
    const style = document.createElement('style');
    style.textContent = `
      @keyframes fadeIn {
        from { opacity: 0; }
        to { opacity: 1; }
      }
      @keyframes fadeOut {
        from { opacity: 1; }
        to { opacity: 0; }
      }
      @keyframes slideUp {
        from { 
          opacity: 0;
          transform: translateY(20px);
        }
        to { 
          opacity: 1;
          transform: translateY(0);
        }
      }
    `;
    document.head.appendChild(style);
  </script>
</asp:Content>
