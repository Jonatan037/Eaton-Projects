<%@ Page Language="C#" AutoEventWireup="true" CodeFile="EquipmentGridView.aspx.cs" Inherits="TED_EquipmentGridView" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="0" />
    <!-- Version: 2025.10.16.005 - Increased toggle column width to 110px for full label visibility -->
    <title>Equipment Grid View - Test Engineering</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700;800&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="<%= ResolveUrl("~/Content/theme.css") %>" />
    <script type="text/javascript">
        (function(){
            try{
                var pref = localStorage.getItem('tedTheme') === 'light' ? 'light' : 'dark';
                var docEl = document.documentElement;
                var cls = (docEl.getAttribute('class')||'').replace(/\btheme-(light|dark)\b/g,'').trim();
                if(cls) docEl.setAttribute('class', cls);
                docEl.classList.add('theme-' + pref);
                docEl.setAttribute('data-theme', pref);
            }catch(e){}
        })();
    </script>
    <style>
    /* Grid View Specific Styles */
    html, body { max-width:100%; overflow-x:hidden; margin:0; padding:0; }
    body { min-height:100vh; }
    
    /* Container */
    .grid-view-container { 
      padding:20px 24px 40px; 
      max-width:100%; 
      box-sizing:border-box;
    }
    
    /* Page Title */
    .page-header { 
      margin-bottom:20px; 
      display:flex; 
      align-items:center; 
      justify-content:space-between;
    }
    .page-title { 
      font-size:16px; 
      font-weight:800; 
      letter-spacing:.3px; 
      margin:0;
    }
    .page-subtitle {
      font-size:10px;
      opacity:.65;
      margin-top:2px;
    }
    
    /* Filter Panel */
    .filter-panel { 
      background:rgba(25,29,37,.52); 
      border:1px solid rgba(255,255,255,.08); 
      border-radius:14px; 
      box-shadow:0 12px 28px -8px rgba(0,0,0,.5), 0 0 0 1px rgba(255,255,255,.05); 
      backdrop-filter:blur(36px) saturate(135%); 
      padding:0;
      margin-bottom:16px;
      overflow:hidden;
    }
    html.theme-light .filter-panel, html[data-theme='light'] .filter-panel { 
      background:rgba(255,255,255,.72); 
      border:1px solid rgba(0,0,0,.08); 
      box-shadow:0 10px 26px -10px rgba(0,0,0,.15), 0 0 0 1px rgba(0,0,0,.05); 
    }
    
    .filter-header {
      font-size:11px;
      font-weight:700;
      letter-spacing:.3px;
      padding:12px 18px;
      opacity:.85;
      display:flex;
      align-items:center;
      justify-content:space-between;
      cursor:pointer;
      user-select:none;
      border-bottom:1px solid rgba(255,255,255,.08);
      transition:all .2s ease;
    }
    .filter-header:hover {
      background:rgba(255,255,255,.04);
    }
    html.theme-light .filter-header, html[data-theme='light'] .filter-header {
      border-bottom:1px solid rgba(0,0,0,.08);
    }
    html.theme-light .filter-header:hover, html[data-theme='light'] .filter-header:hover {
      background:rgba(0,0,0,.02);
    }
    .filter-header-left {
      display:flex;
      align-items:center;
      gap:6px;
    }
    .filter-header-right {
      display:flex;
      align-items:center;
      gap:10px;
    }
    .btn-reset-icon {
      display:flex;
      align-items:center;
      justify-content:center;
      width:28px;
      height:28px;
      padding:0;
      border:1px solid rgba(255,255,255,.16);
      border-radius:7px;
      background:rgba(255,255,255,.06);
      color:inherit;
      cursor:pointer;
      transition:all .2s ease;
    }
    .btn-reset-icon svg {
      width:14px;
      height:14px;
    }
    .btn-reset-icon:hover {
      background:rgba(239,68,68,.2);
      border-color:rgba(239,68,68,.4);
      color:#fca5a5;
      transform:rotate(-180deg);
    }
    html.theme-light .btn-reset-icon, html[data-theme='light'] .btn-reset-icon {
      background:#f5f7fa;
      border:1px solid rgba(0,0,0,.14);
      color:#1f242b;
    }
    html.theme-light .btn-reset-icon:hover, html[data-theme='light'] .btn-reset-icon:hover {
      background:#fee;
      border-color:#ef4444;
      color:#dc2626;
    }
    .filter-count {
      display:inline-flex;
      align-items:center;
      justify-content:center;
      min-width:20px;
      height:18px;
      padding:0 6px;
      margin-left:6px;
      background:rgba(77,141,255,.25);
      color:#93c5fd;
      border-radius:9px;
      font-size:10px;
      font-weight:800;
      letter-spacing:.3px;
    }
    html.theme-light .filter-count, html[data-theme='light'] .filter-count {
      background:rgba(59,130,246,.15);
      color:#2563eb;
    }
    .filter-header svg {
      width:13px;
      height:13px;
      opacity:.7;
    }
    .filter-toggle {
      display:flex;
      align-items:center;
      gap:5px;
      font-size:9px;
      opacity:.55;
      font-weight:600;
      letter-spacing:.3px;
    }
    .filter-toggle-icon {
      width:14px;
      height:14px;
      transition:transform .3s ease;
    }
    .filter-toggle-icon.collapsed {
      transform:rotate(-90deg);
    }
    
    .filter-content {
      max-height:1000px;
      transition:max-height .35s cubic-bezier(0.4, 0, 0.2, 1), 
                 opacity .35s ease, 
                 padding .35s ease;
      opacity:1;
      padding:16px 18px;
      overflow:hidden;
    }
    .filter-content.collapsed {
      max-height:0;
      opacity:0;
      padding:0 18px;
    }
    
    .filter-section {
      margin-bottom:16px;
    }
    .filter-section:last-child {
      margin-bottom:0;
    }
    .filter-section-title {
      font-size:9px;
      font-weight:700;
      text-transform:uppercase;
      letter-spacing:.5px;
      opacity:.45;
      margin-bottom:10px;
      padding-bottom:6px;
      border-bottom:1px solid rgba(255,255,255,.06);
    }
    html.theme-light .filter-section-title, html[data-theme='light'] .filter-section-title {
      border-bottom:1px solid rgba(0,0,0,.06);
    }
    
    .filter-grid { 
      display:grid; 
      grid-template-columns:repeat(auto-fit, minmax(180px, 1fr)); 
      gap:10px; 
      align-items:end;
    }
    .filter-grid-2col {
      grid-template-columns:repeat(2, 1fr);
    }
    .filter-grid-3col {
      grid-template-columns:repeat(3, 1fr);
    }
    .filter-grid-4col {
      grid-template-columns:repeat(4, 1fr);
    }
    
    .filter-group { 
      display:flex; 
      flex-direction:column; 
      gap:4px;
    }
    
    .filter-label { 
      font-size:9px; 
      font-weight:600; 
      letter-spacing:.4px; 
      opacity:.6; 
      text-transform:uppercase;
    }
    
    .filter-input, .filter-select { 
      width:100%;
      padding:7px 10px; 
      border-radius:8px; 
      border:1px solid rgba(255,255,255,.16); 
      background:rgba(0,0,0,.12); 
      color:#e5e7eb; 
      font:inherit; 
      font-size:11px;
      transition:all .2s ease;
      height:30px;
      box-sizing:border-box;
    }
    .filter-select {
      cursor:pointer;
      -webkit-appearance:none;
      -moz-appearance:none;
      appearance:none;
      background-color:rgba(0,0,0,.12);
      background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='%23e5e7eb' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='6 9 12 15 18 9'%3E%3C/polyline%3E%3C/svg%3E");
      background-repeat:no-repeat;
      background-position:right 10px center;
      padding-right:35px;
    }
    .filter-select option {
      background:#1f242b;
      color:#e5e7eb;
      padding:8px;
    }
    .filter-input:focus, .filter-select:focus {
      outline:none;
      border-color:rgba(77,141,255,.5);
      background:rgba(0,0,0,.18);
      box-shadow:0 0 0 2px rgba(77,141,255,.08);
    }
    .filter-input::placeholder {
      opacity:.5;
      color:#9ca3af;
    }
    
    /* Active filter highlighting */
    .filter-input.filter-active, .filter-select.filter-active {
      border-color:#fbbf24 !important;
      background:rgba(251,191,36,.1) !important;
      box-shadow:0 0 0 2px rgba(251,191,36,.15) !important;
    }
    html.theme-light .filter-input.filter-active, 
    html[data-theme='light'] .filter-input.filter-active,
    html.theme-light .filter-select.filter-active, 
    html[data-theme='light'] .filter-select.filter-active {
      border-color:#f59e0b !important;
      background:rgba(245,158,11,.08) !important;
      box-shadow:0 0 0 2px rgba(245,158,11,.12) !important;
    }
    
    html.theme-light .filter-input, html[data-theme='light'] .filter-input,
    html.theme-light .filter-select, html[data-theme='light'] .filter-select { 
      background:#fff; 
      background-color:#fff;
      border:1px solid rgba(0,0,0,.12); 
      color:#1f242b;
    }
    html.theme-light .filter-select, html[data-theme='light'] .filter-select {
      background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='%231f242b' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='6 9 12 15 18 9'%3E%3C/polyline%3E%3C/svg%3E");
      background-color:#fff;
      background-repeat:no-repeat;
      background-position:right 10px center;
    }
    html.theme-light .filter-select option, html[data-theme='light'] .filter-select option {
      background:#ffffff;
      color:#1f242b;
    }
    html.theme-light .filter-input:focus, html[data-theme='light'] .filter-input:focus,
    html.theme-light .filter-select:focus, html[data-theme='light'] .filter-select:focus {
      border-color:#4d8dff;
      box-shadow:0 0 0 2px rgba(77,141,255,.08);
    }
    
    .filter-actions {
      display:flex;
      gap:8px;
      margin-top:12px;
      padding-top:12px;
      border-top:1px solid rgba(255,255,255,.06);
    }
    html.theme-light .filter-actions, html[data-theme='light'] .filter-actions {
      border-top:1px solid rgba(0,0,0,.06);
    }
    
    .btn-reset { 
      padding:7px 14px; 
      border-radius:8px; 
      border:1px solid rgba(255,255,255,.16); 
      background:rgba(255,255,255,.06);
      color:inherit; 
      font:inherit; 
      font-size:11px; 
      font-weight:600;
      cursor:pointer;
      transition:all .2s ease;
      white-space:nowrap;
      height:30px;
    }
    .btn-reset:hover { 
      background:rgba(239,68,68,.2);
      border-color:rgba(239,68,68,.4);
      color:#fca5a5;
    }
    html.theme-light .btn-reset, html[data-theme='light'] .btn-reset { 
      background:#f5f7fa;
      border:1px solid rgba(0,0,0,.14);
      color:#1f242b;
    }
    html.theme-light .btn-reset:hover, html[data-theme='light'] .btn-reset:hover { 
      background:#fee;
      border-color:#ef4444;
      color:#dc2626;
    }
    
    /* Table Container */
    .table-container { 
      background:rgba(25,29,37,.52); 
      border:1px solid rgba(255,255,255,.08); 
      border-radius:16px; 
      box-shadow:0 12px 28px -8px rgba(0,0,0,.5), 0 0 0 1px rgba(255,255,255,.05); 
      backdrop-filter:blur(36px) saturate(135%); 
      padding:0; 
      overflow:hidden;
    }
    html.theme-light .table-container, html[data-theme='light'] .table-container { 
      background:rgba(255,255,255,.72); 
      border:1px solid rgba(0,0,0,.08); 
      box-shadow:0 10px 26px -10px rgba(0,0,0,.15), 0 0 0 1px rgba(0,0,0,.05); 
    }
    
    .table-header {
      padding:18px 22px;
      border-bottom:1px solid rgba(255,255,255,.08);
      display:flex;
      justify-content:space-between;
      align-items:center;
    }
    html.theme-light .table-header, html[data-theme='light'] .table-header {
      border-bottom:1px solid rgba(0,0,0,.08);
    }
    
    .table-title {
      font-size:11px;
      font-weight:700;
      letter-spacing:.3px;
      display:flex;
      align-items:center;
      gap:6px;
    }
    .table-title svg {
      width:14px;
      height:14px;
      opacity:.7;
    }
    .record-count {
      font-size:10px;
      opacity:.55;
      font-weight:600;
      margin-left:4px;
    }
    
    .table-actions {
      display:flex;
      gap:10px;
    }
    
    .btn-icon-action { 
      padding:6px 12px; 
      border-radius:8px; 
      border:1px solid rgba(255,255,255,.18); 
      background:rgba(255,255,255,.08);
      color:inherit; 
      font:inherit; 
      font-size:10px; 
      font-weight:600;
      cursor:pointer;
      transition:all .2s ease;
      white-space:nowrap;
      display:flex;
      align-items:center;
      gap:5px;
      height:28px;
    }
    .btn-icon-action svg {
      width:12px;
      height:12px;
    }
    .btn-icon-action:hover { 
      background:rgba(77,141,255,.2);
      border-color:rgba(77,141,255,.4);
      color:#bcd4ff;
      transform:translateY(-1px);
    }
    html.theme-light .btn-icon-action, html[data-theme='light'] .btn-icon-action { 
      background:#f5f7fa;
      border:1px solid rgba(0,0,0,.14);
      color:#1f242b;
    }
    html.theme-light .btn-icon-action:hover, html[data-theme='light'] .btn-icon-action:hover { 
      background:#e8f1ff;
      border-color:#4d8dff;
      color:#1e40af;
    }
    
    /* Table Wrap with Scroll */
    .table-wrap { 
      width:100%; 
      max-width:100%; 
      overflow-x:auto; 
      overflow-y:auto;
      max-height:calc(100vh - 280px);
      border-radius:0 0 16px 16px;
      position:relative;
    }
    
    /* Modern Fancy Scrollbars */
    .table-wrap::-webkit-scrollbar { 
      width:10px; 
      height:10px; 
    }
    .table-wrap::-webkit-scrollbar-track { 
      background:rgba(0,0,0,.15); 
      border-radius:10px;
      margin:4px;
    }
    .table-wrap::-webkit-scrollbar-thumb { 
      background:linear-gradient(135deg, rgba(77,141,255,.4), rgba(139,92,246,.4)); 
      border-radius:10px; 
      border:2px solid rgba(0,0,0,.15);
      transition:all .3s ease;
    }
    .table-wrap::-webkit-scrollbar-thumb:hover { 
      background:linear-gradient(135deg, rgba(77,141,255,.6), rgba(139,92,246,.6)); 
      border-color:rgba(0,0,0,.2);
    }
    .table-wrap::-webkit-scrollbar-corner {
      background:rgba(0,0,0,.15);
      border-radius:10px;
    }
    html.theme-light .table-wrap::-webkit-scrollbar-track, 
    html[data-theme='light'] .table-wrap::-webkit-scrollbar-track { 
      background:rgba(0,0,0,.06); 
    }
    html.theme-light .table-wrap::-webkit-scrollbar-thumb, 
    html[data-theme='light'] .table-wrap::-webkit-scrollbar-thumb { 
      background:linear-gradient(135deg, rgba(59,130,246,.5), rgba(139,92,246,.5)); 
      border:2px solid rgba(255,255,255,.3);
    }
    html.theme-light .table-wrap::-webkit-scrollbar-thumb:hover, 
    html[data-theme='light'] .table-wrap::-webkit-scrollbar-thumb:hover { 
      background:linear-gradient(135deg, rgba(59,130,246,.7), rgba(139,92,246,.7)); 
    }
    html.theme-light .table-wrap::-webkit-scrollbar-corner,
    html[data-theme='light'] .table-wrap::-webkit-scrollbar-corner {
      background:rgba(0,0,0,.06);
    }
    
    /* Data Table */
    table.data-table,
    #gridEquipment,
    table[id*="gridEquipment"] { 
      width:100%; 
      min-width:3000px; 
      border-collapse:separate; 
      border-spacing:0; 
      font-size:9.5px; 
      table-layout:fixed; 
    }
    table.data-table th, table.data-table td,
    #gridEquipment th, #gridEquipment td,
    table[id*="gridEquipment"] th, table[id*="gridEquipment"] td { 
      box-sizing:border-box; 
    }
    table.data-table .grid-header-row,
    #gridEquipment .grid-header-row,
    table[id*="gridEquipment"] .grid-header-row { 
      position:sticky; 
      top:0; 
      z-index:100; 
      background:linear-gradient(180deg, #0b63ce 0%, #094fa8 100%) !important; 
    }
    table.data-table .grid-header-row th,
    #gridEquipment .grid-header-row th,
    table[id*="gridEquipment"] .grid-header-row th { 
      background:linear-gradient(180deg, #0b63ce 0%, #094fa8 100%) !important; 
      color:#ffffff !important; 
      border-bottom:2px solid rgba(0,0,0,.2) !important; 
      text-align:center !important; 
      font-size:9px !important; 
      padding:6px 8px !important; 
      height:28px !important;
      max-height:28px !important;
      min-height:28px !important;
      line-height:1.2 !important;
      font-weight:700 !important; 
      letter-spacing:.4px !important; 
      white-space:nowrap !important; 
      text-transform:uppercase !important;
      overflow:hidden !important; 
      text-overflow:ellipsis !important;
      box-shadow:0 2px 8px rgba(0,0,0,.15) !important;
    }
    html:not(.theme-light):not([data-theme='light']) table.data-table .grid-header-row th,
    html:not(.theme-light):not([data-theme='light']) #gridEquipment .grid-header-row th,
    html:not(.theme-light):not([data-theme='light']) table[id*="gridEquipment"] .grid-header-row th { 
      background:linear-gradient(180deg, #1a2942 0%, #0f1a2e 100%) !important; 
      color:#e9eef8 !important; 
      border-bottom:2px solid rgba(77,141,255,.25) !important;
      box-shadow:0 2px 12px rgba(0,0,0,.3) !important;
    }
    
    table.data-table tbody td,
    #gridEquipment tbody td,
    table[id*="gridEquipment"] tbody td { 
      padding:8px 8px; 
      border-bottom:1px solid rgba(255,255,255,.06); 
      vertical-align:middle; 
      text-align:center; 
      overflow:hidden;
      text-overflow:ellipsis;
      white-space:normal;
      word-wrap:break-word;
      font-size:9.5px;
      color:#e5e7eb;
      max-width:200px;
      cursor:default;
    }
    html.theme-light table.data-table tbody td, html[data-theme='light'] table.data-table tbody td,
    html.theme-light #gridEquipment tbody td, html[data-theme='light'] #gridEquipment tbody td,
    html.theme-light table[id*="gridEquipment"] tbody td, html[data-theme='light'] table[id*="gridEquipment"] tbody td { 
      border-bottom:1px solid rgba(0,0,0,.05);
      color:#1f242b;
    }
    
    /* Add title attribute for tooltips on hover */
    table[id*="gridEquipment"] tbody td:hover {
      position:relative;
      z-index:5;
    }
    
    /* Allow URL columns to show full text */
    table[id*="gridEquipment"] .col-folder,
    table[id*="gridEquipment"] .col-image {
      white-space:normal;
      word-break:break-all;
      min-width:200px;
      max-width:250px;
    }
    
    table.data-table tbody tr:nth-child(odd),
    #gridEquipment tbody tr:nth-child(odd),
    table[id*="gridEquipment"] tbody tr:nth-child(odd) { 
      background:rgba(255,255,255,.015); 
    }
    html.theme-light table.data-table tbody tr:nth-child(odd),
    html.theme-light #gridEquipment tbody tr:nth-child(odd),
    html.theme-light table[id*="gridEquipment"] tbody tr:nth-child(odd) { 
      background:#fafbfe; 
    }
    
    table.data-table tbody tr:hover,
    #gridEquipment tbody tr:hover,
    table[id*="gridEquipment"] tbody tr:hover { 
      background:rgba(77,141,255,.08); 
    }
    html.theme-light table.data-table tbody tr:hover, html[data-theme='light'] table.data-table tbody tr:hover,
    html.theme-light #gridEquipment tbody tr:hover, html[data-theme='light'] #gridEquipment tbody tr:hover,
    html.theme-light table[id*="gridEquipment"] tbody tr:hover, html[data-theme='light'] table[id*="gridEquipment"] tbody tr:hover { 
      background:#f0f6ff; 
    }
    
    /* Selected Row Highlighting */
    table.data-table tbody tr.row-selected,
    #gridEquipment tbody tr.row-selected,
    table[id*="gridEquipment"] tbody tr.row-selected {
      background:rgba(77,141,255,.20) !important;
      box-shadow:inset 3px 0 0 #4d8dff;
    }
    html.theme-light table.data-table tbody tr.row-selected, 
    html[data-theme='light'] table.data-table tbody tr.row-selected,
    html.theme-light #gridEquipment tbody tr.row-selected, 
    html[data-theme='light'] #gridEquipment tbody tr.row-selected,
    html.theme-light table[id*="gridEquipment"] tbody tr.row-selected, 
    html[data-theme='light'] table[id*="gridEquipment"] tbody tr.row-selected {
      background:rgba(59,130,246,.15) !important;
      box-shadow:inset 3px 0 0 #3b82f6;
    }
    table.data-table tbody tr.row-selected td,
    #gridEquipment tbody tr.row-selected td,
    table[id*="gridEquipment"] tbody tr.row-selected td {
      font-weight:600;
    }
    
    /* Status Badges */
    .status-badge {
      display:inline-flex;
      align-items:center;
      gap:4px;
      padding:4px 10px;
      border-radius:6px;
      font-size:9px;
      font-weight:500 !important;
      letter-spacing:.3px;
      white-space:normal;
      word-wrap:break-word;
      text-transform:uppercase;
      max-width:100%;
      line-height:1.4;
      text-align:center;
    }
    .status-badge::before {
      content:'';
      width:5px;
      height:5px;
      border-radius:50%;
      flex-shrink:0;
      align-self:flex-start;
      margin-top:2px;
    }
    
    /* IN USE status - Green */
    .status-in-use {
      background:rgba(16,185,129,.15);
      color:#10b981;
    }
    .status-in-use::before {
      background:#10b981;
      box-shadow:0 0 4px #10b981;
    }
    html.theme-light .status-in-use, html[data-theme='light'] .status-in-use {
      background:#d1fae5;
      color:#059669;
    }
    
    /* SPARE status - Bright Blue */
    .status-spare {
      background:rgba(59,130,246,.2);
      color:#3b82f6;
      font-weight:600 !important;
    }
    .status-spare::before {
      background:#3b82f6;
      box-shadow:0 0 6px #3b82f6;
    }
    html.theme-light .status-spare, html[data-theme='light'] .status-spare {
      background:#bfdbfe;
      color:#1d4ed8;
      font-weight:600 !important;
    }
    
    /* ALL OUT OF SERVICE variations - Orange */
    .status-out-of-service,
    .status-out-of-service---damaged,
    .status-out-of-service---under-repair,
    .status-out-of-service---in-calibration {
      background:rgba(249,115,22,.15);
      color:#f97316;
    }
    .status-out-of-service::before,
    .status-out-of-service---damaged::before,
    .status-out-of-service---under-repair::before,
    .status-out-of-service---in-calibration::before {
      background:#f97316;
      box-shadow:0 0 4px #f97316;
    }
    html.theme-light .status-out-of-service, html[data-theme='light'] .status-out-of-service,
    html.theme-light .status-out-of-service---damaged, html[data-theme='light'] .status-out-of-service---damaged,
    html.theme-light .status-out-of-service---under-repair, html[data-theme='light'] .status-out-of-service---under-repair,
    html.theme-light .status-out-of-service---in-calibration, html[data-theme='light'] .status-out-of-service---in-calibration {
      background:#fed7aa;
      color:#c2410c;
    }
    
    /* ALL SCRAPPED/SCRAPED variations - Red */
    .status-scrapped,
    .status-scraped,
    .status-scrapped---returned-to-vendor,
    .status-scraped---returned-to-vendor {
      background:rgba(239,68,68,.15);
      color:#ef4444;
    }
    .status-scrapped::before,
    .status-scraped::before,
    .status-scrapped---returned-to-vendor::before,
    .status-scraped---returned-to-vendor::before {
      background:#ef4444;
      box-shadow:0 0 4px #ef4444;
    }
    html.theme-light .status-scrapped, html[data-theme='light'] .status-scrapped,
    html.theme-light .status-scraped, html[data-theme='light'] .status-scraped,
    html.theme-light .status-scrapped---returned-to-vendor, html[data-theme='light'] .status-scrapped---returned-to-vendor,
    html.theme-light .status-scraped---returned-to-vendor, html[data-theme='light'] .status-scraped---returned-to-vendor {
      background:#fee2e2;
      color:#dc2626;
    }
    
    /* AVAILABLE status - Keep as fallback for legacy - Green */
    .status-available {
      background:rgba(16,185,129,.15);
      color:#10b981;
    }
    .status-available::before {
      background:#10b981;
      box-shadow:0 0 4px #10b981;
    }
    html.theme-light .status-available, html[data-theme='light'] .status-available {
      background:#d1fae5;
      color:#059669;
    }
    
    /* RETIRED status - Gray */
    .status-retired,
    .status-decommissioned {
      background:rgba(107,114,128,.15);
      color:#9ca3af;
    }
    .status-retired::before,
    .status-decommissioned::before {
      background:#6b7280;
      box-shadow:0 0 4px #6b7280;
    }
    html.theme-light .status-retired, html[data-theme='light'] .status-retired,
    html.theme-light .status-decommissioned, html[data-theme='light'] .status-decommissioned {
      background:#f3f4f6;
      color:#4b5563;
    }
    
    /* UNDER REPAIR / MAINTENANCE status - Orange */
    .status-under-repair,
    .status-repair,
    .status-maintenance {
      background:rgba(249,115,22,.15);
      color:#f97316;
    }
    .status-under-repair::before,
    .status-repair::before,
    .status-maintenance::before {
      background:#f97316;
      box-shadow:0 0 4px #f97316;
    }
    html.theme-light .status-under-repair, html[data-theme='light'] .status-under-repair,
    html.theme-light .status-repair, html[data-theme='light'] .status-repair,
    html.theme-light .status-maintenance, html[data-theme='light'] .status-maintenance {
      background:#fed7aa;
      color:#c2410c;
    }
    
    /* CALIBRATION DUE status - Yellow */
    .status-calibration-due,
    .status-needs-calibration {
      background:rgba(234,179,8,.15);
      color:#eab308;
    }
    .status-calibration-due::before,
    .status-needs-calibration::before {
      background:#eab308;
      box-shadow:0 0 4px #eab308;
    }
    html.theme-light .status-calibration-due, html[data-theme='light'] .status-calibration-due,
    html.theme-light .status-needs-calibration, html[data-theme='light'] .status-needs-calibration {
      background:#fef3c7;
      color:#a16207;
    }
    
    /* RESERVED status - Purple */
    .status-reserved {
      background:rgba(168,85,247,.15);
      color:#a855f7;
    }
    .status-reserved::before {
      background:#a855f7;
      box-shadow:0 0 4px #a855f7;
    }
    html.theme-light .status-reserved, html[data-theme='light'] .status-reserved {
      background:#f3e8ff;
      color:#7e22ce;
    }
    
    /* Generic fallback for any status not explicitly styled - Cyan/Teal */
    .status-badge:not([class*="status-available"]):not([class*="status-in-use"]):not([class*="status-spare"]):not([class*="status-out-of-service"]):not([class*="status-scrapped"]):not([class*="status-scraped"]):not([class*="status-returned"]):not([class*="status-retired"]):not([class*="status-decommissioned"]):not([class*="status-repair"]):not([class*="status-maintenance"]):not([class*="status-calibration"]):not([class*="status-reserved"]) {
      background:rgba(20,184,166,.15);
      color:#14b8a6;
    }
    .status-badge:not([class*="status-available"]):not([class*="status-in-use"]):not([class*="status-spare"]):not([class*="status-out-of-service"]):not([class*="status-scrapped"]):not([class*="status-scraped"]):not([class*="status-returned"]):not([class*="status-retired"]):not([class*="status-decommissioned"]):not([class*="status-repair"]):not([class*="status-maintenance"]):not([class*="status-calibration"]):not([class*="status-reserved"])::before {
      background:#14b8a6;
      box-shadow:0 0 4px #14b8a6;
    }
    html.theme-light .status-badge:not([class*="status-available"]):not([class*="status-in-use"]):not([class*="status-spare"]):not([class*="status-out-of-service"]):not([class*="status-scrapped"]):not([class*="status-scraped"]):not([class*="status-returned"]):not([class*="status-retired"]):not([class*="status-decommissioned"]):not([class*="status-repair"]):not([class*="status-maintenance"]):not([class*="status-calibration"]):not([class*="status-reserved"]),
    html[data-theme='light'] .status-badge:not([class*="status-available"]):not([class*="status-in-use"]):not([class*="status-spare"]):not([class*="status-out-of-service"]):not([class*="status-scrapped"]):not([class*="status-scraped"]):not([class*="status-returned"]):not([class*="status-retired"]):not([class*="status-decommissioned"]):not([class*="status-repair"]):not([class*="status-maintenance"]):not([class*="status-calibration"]):not([class*="status-reserved"]) {
      background:#ccfbf1;
      color:#0f766e;
    }
    
    .status-operational, .status-good, .status-active {
      background:rgba(16,185,129,.15);
      color:#6ee7b7;
    }
    .status-operational::before, .status-good::before, .status-active::before {
      background:#10b981;
      box-shadow:0 0 4px #10b981;
    }
    html.theme-light .status-operational, html[data-theme='light'] .status-operational,
    html.theme-light .status-good, html[data-theme='light'] .status-good,
    html.theme-light .status-active, html[data-theme='light'] .status-active {
      background:#d1fae5;
      color:#059669;
    }
    
    .status-maintenance, .status-warning {
      background:rgba(245,158,11,.15);
      color:#fcd34d;
    }
    .status-maintenance::before, .status-warning::before {
      background:#f59e0b;
      box-shadow:0 0 4px #f59e0b;
    }
    html.theme-light .status-maintenance, html[data-theme='light'] .status-maintenance,
    html.theme-light .status-warning, html[data-theme='light'] .status-warning {
      background:#fef3c7;
      color:#d97706;
    }
    
    .status-outofservice, .status-error, .status-out-of-service {
      background:rgba(239,68,68,.15);
      color:#fca5a5;
    }
    .status-outofservice::before, .status-error::before, .status-out-of-service::before {
      background:#ef4444;
      box-shadow:0 0 4px #ef4444;
    }
    html.theme-light .status-outofservice, html[data-theme='light'] .status-outofservice,
    html.theme-light .status-error, html[data-theme='light'] .status-error,
    html.theme-light .status-out-of-service, html[data-theme='light'] .status-out-of-service {
      background:#fee2e2;
      color:#dc2626;
    }
    
    /* Activity Badges (Last Cal, Last PM) */
    .activity-badge {
      display:inline-flex;
      align-items:center;
      gap:4px;
      padding:3px 7px;
      border-radius:5px;
      font-size:8.5px;
      font-weight:700;
      letter-spacing:.3px;
      white-space:nowrap;
    }
    .activity-badge::before {
      content:'';
      width:4px;
      height:4px;
      border-radius:50%;
      flex-shrink:0;
    }
    
    .activity-good {
      background:rgba(16,185,129,.15);
      color:#6ee7b7;
    }
    .activity-good::before {
      background:#10b981;
      box-shadow:0 0 4px #10b981;
    }
    html.theme-light .activity-good, html[data-theme='light'] .activity-good {
      background:#d1fae5;
      color:#059669;
    }
    
    .activity-warning {
      background:rgba(245,158,11,.15);
      color:#fcd34d;
    }
    .activity-warning::before {
      background:#f59e0b;
      box-shadow:0 0 4px #f59e0b;
    }
    html.theme-light .activity-warning, html[data-theme='light'] .activity-warning {
      background:#fef3c7;
      color:#d97706;
    }
    
    .activity-overdue {
      background:rgba(239,68,68,.15);
      color:#fca5a5;
    }
    .activity-overdue::before {
      background:#ef4444;
      box-shadow:0 0 4px #ef4444;
    }
    html.theme-light .activity-overdue, html[data-theme='light'] .activity-overdue {
      background:#fee2e2;
      color:#dc2626;
    }
    
    .activity-none {
      background:rgba(100,116,139,.15);
      color:#94a3b8;
      opacity:0.7;
    }
    .activity-none::before {
      background:#64748b;
    }
    html.theme-light .activity-none, html[data-theme='light'] .activity-none {
      background:#e2e8f0;
      color:#64748b;
    }
    
    /* Toggle Switches for Req. Cal and Req. PM */
    .toggle-switch {
      display:inline-flex;
      align-items:center;
      gap:6px;
      padding:5px 10px;
      border-radius:20px;
      font-size:9px;
      font-weight:600;
      letter-spacing:.3px;
      text-transform:uppercase;
      cursor:default;
      transition:all 0.3s ease;
      min-width:70px;
      white-space:nowrap;
    }
    
    /* Force width for Req. Cal (column 14) and Req. PM (column 21) columns */
    table[id*="gridEquipment"] .grid-header-row th:nth-child(14),
    table[id*="gridEquipment"] .grid-header-row th:nth-child(21) {
      min-width:110px !important;
      max-width:110px !important;
      width:110px !important;
    }
    
    .toggle-label {
      flex-shrink:0;
    }
    
    .toggle-slider {
      position:relative;
      width:32px;
      height:16px;
      border-radius:12px;
      transition:all 0.3s ease;
      flex-shrink:0;
    }
    
    .toggle-slider::before {
      content:'';
      position:absolute;
      width:12px;
      height:12px;
      border-radius:50%;
      top:2px;
      transition:all 0.3s ease;
      box-shadow:0 2px 4px rgba(0,0,0,0.2);
    }
    
    /* Toggle ON state - Green */
    .toggle-on {
      background:rgba(16,185,129,.15);
      color:#10b981;
    }
    
    .toggle-on .toggle-slider {
      background:#10b981;
    }
    
    .toggle-on .toggle-slider::before {
      background:#ffffff;
      left:16px;
    }
    
    /* Toggle OFF state - Red */
    .toggle-off {
      background:rgba(239,68,68,.15);
      color:#ef4444;
    }
    
    .toggle-off .toggle-slider {
      background:#ef4444;
    }
    
    .toggle-off .toggle-slider::before {
      background:#ffffff;
      left:4px;
    }
    
    /* Light mode adjustments */
    html.theme-light .toggle-on, html[data-theme='light'] .toggle-on {
      background:#d1fae5;
      color:#059669;
    }
    
    html.theme-light .toggle-on .toggle-slider, html[data-theme='light'] .toggle-on .toggle-slider {
      background:#059669;
    }
    
    html.theme-light .toggle-off, html[data-theme='light'] .toggle-off {
      background:#fee2e2;
      color:#dc2626;
    }
    
    html.theme-light .toggle-off .toggle-slider, html[data-theme='light'] .toggle-off .toggle-slider {
      background:#dc2626;
    }
    
    /* Type Badges */
    .type-badge {
      display:inline-flex;
      padding:3px 7px;
      border-radius:5px;
      font-size:8.5px;
      font-weight:700;
      letter-spacing:.3px;
      white-space:nowrap;
      text-transform:uppercase;
    }
    .type-ate {
      background:rgba(139,92,246,.15);
      color:#ddd6fe;
    }
    html.theme-light .type-ate, html[data-theme='light'] .type-ate {
      background:#ede9fe;
      color:#7c3aed;
    }
    .type-asset {
      background:rgba(59,130,246,.15);
      color:#93c5fd;
    }
    html.theme-light .type-asset, html[data-theme='light'] .type-asset {
      background:#dbeafe;
      color:#1e40af;
    }
    .type-fixture {
      background:rgba(249,115,22,.15);
      color:#fdba74;
    }
    html.theme-light .type-fixture, html[data-theme='light'] .type-fixture {
      background:#ffedd5;
      color:#c2410c;
    }
    .type-harness {
      background:rgba(16,185,129,.15);
      color:#6ee7b7;
    }
    html.theme-light .type-harness, html[data-theme='light'] .type-harness {
      background:#d1fae5;
      color:#059669;
    }
    
    /* Date Cells */
    .date-cell {
      font-family:'SF Mono', Monaco, 'Courier New', monospace;
      font-size:9px;
      font-weight:500;
    }
    .date-overdue {
      color:#fca5a5;
      font-weight:700;
    }
    html.theme-light .date-overdue, html[data-theme='light'] .date-overdue {
      color:#dc2626;
    }
    .date-due-soon {
      color:#fcd34d;
      font-weight:700;
    }
    html.theme-light .date-due-soon, html[data-theme='light'] .date-due-soon {
      color:#d97706;
    }
    .date-good {
      color:#6ee7b7;
    }
    html.theme-light .date-good, html[data-theme='light'] .date-good {
      color:#059669;
    }
    
    /* Empty State */
    .empty-state {
      text-align:center;
      padding:80px 20px;
      opacity:.6;
    }
    .empty-state svg {
      width:64px;
      height:64px;
      margin-bottom:16px;
      opacity:.5;
    }
    .empty-state-title {
      font-size:18px;
      font-weight:600;
      margin-bottom:8px;
    }
    .empty-state-message {
      font-size:13px;
      opacity:.8;
    }
    
    /* Column Widths */
    .col-type { width:70px; }
    .col-id { width:100px; }
    .col-model { width:120px; }
    .col-name { width:140px; }
    .col-desc { width:200px; }
    .col-ate { width:100px; }
    .col-location { width:140px; }
    .col-devtype { width:100px; }
    .col-mfg { width:120px; }
    .col-mfgsite { width:180px; }
    .col-folder { width:200px; }
    .col-image { width:200px; }
    .col-status { width:140px; }
    .col-cal { width:60px; }
    .col-calid { width:80px; }
    .col-freq { width:90px; }
    .col-date { width:90px; }
    .col-by { width:120px; }
    .col-time { width:80px; }
    .col-pm { width:60px; }
    .col-resp { width:120px; }
    .col-swap { width:70px; }
    .col-qty { width:60px; }
    .col-comments { width:220px; }
    
    table[id*="gridEquipment"] tbody td[title]:hover::before {
      content: '';
      position: absolute;
      bottom: 100%;
      left: 50%;
      transform: translateX(-50%) translateY(-1px);
      border: 6px solid transparent;
      border-top-color: #1e293b;
      z-index: 1001;
      pointer-events: none;
    }
    
    html.theme-light table[id*="gridEquipment"] tbody td[title]:hover::after,
    html[data-theme='light'] table[id*="gridEquipment"] tbody td[title]:hover::after {
      background: linear-gradient(135deg, #ffffff 0%, #f8fafc 100%);
      color: #0f172a;
      border: 1px solid rgba(15, 23, 42, 0.08);
      box-shadow: 0 10px 25px rgba(0, 0, 0, 0.12), 0 4px 10px rgba(0, 0, 0, 0.08);
    }
    
    html.theme-light table[id*="gridEquipment"] tbody td[title]:hover::before,
    html[data-theme='light'] table[id*="gridEquipment"] tbody td[title]:hover::before {
      border-top-color: #ffffff;
    }
    
    table[id*="gridEquipment"] tbody td[title] {
      position: relative;
    }
    
    @media (max-width:1200px) {
      .grid-view-container { padding:14px; }
      .filter-grid { grid-template-columns:1fr; }
    }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePartialRendering="true" />
        
        <!-- Top Bar (Same as Site.master) -->
        <header class="topbar" role="banner">
            <div class="topbar-inner">
                <div class="topbar-brand">
                    <div class="logo-icon" aria-hidden="true">
                        <svg viewBox="0 0 24 24" width="16" height="16" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
                            <path d="M13 2 3 14h9l-1 8 10-12h-9l1-8Z"/>
                        </svg>
                    </div>
                    <div class="brand-stack">
                        <div class="brand-row">
                            <span class="eaton-badge">Eaton YPO</span>
                            <span class="internal-text">INTERNAL</span>
                            <span class="brand-sub-inline">Test Engineering</span>
                        </div>
                    </div>
                </div>
                <div class="topbar-right">
                    <button type="button" class="theme-toggle theme-toggle--sm" data-theme-toggle aria-label="Toggle theme" title="Toggle theme">
                        <span class="toggle-icon" aria-hidden="true">
                            <svg class="icon-moon" viewBox="0 0 24 24" fill="none" stroke="none">
                                <path fill="currentColor" d="M12.9 2.1c.6 0 .9.7.6 1.2A8.8 8.8 0 0 0 12 7.5a8.5 8.5 0 0 0 8.5 8.5c1.6 0 3.2-.4 4.2-.8.6-.2 1.1.4.8 1A11 11 0 1 1 12.9 2.1Z"/>
                            </svg>
                            <svg class="icon-sun" viewBox="0 0 24 24" fill="none" stroke="none">
                                <circle cx="12" cy="12" r="5" fill="currentColor"/>
                                <g stroke="currentColor" stroke-width="1.8" stroke-linecap="round">
                                    <line x1="12" y1="1.6" x2="12" y2="4.2" />
                                    <line x1="12" y1="19.8" x2="12" y2="22.4" />
                                    <line x1="4.2" y1="12" x2="1.6" y2="12" />
                                    <line x1="22.4" y1="12" x2="19.8" y2="12" />
                                    <line x1="5.8" y1="5.8" x2="4" y2="4" />
                                    <line x1="20" y1="20" x2="18.2" y2="18.2" />
                                    <line x1="18.2" y1="5.8" x2="20" y2="4" />
                                    <line x1="4" y1="20" x2="5.8" y2="18.2" />
                                </g>
                            </svg>
                        </span>
                    </button>
                </div>
            </div>
        </header>
        <div class="content-spacer"></div>
        
        <!-- Main Content -->
        <div class="grid-view-container">
            <!-- Page Header -->
            <div class="page-header">
                <div>
                    <h1 class="page-title">Equipment Grid View</h1>
                    <div class="page-subtitle">Complete equipment inventory across all types</div>
                </div>
            </div>
            
            <!-- Filter Panel (Expandable/Collapsible) -->
            <div class="filter-panel">
                <div class="filter-header" onclick="toggleFilters()">
                    <div class="filter-header-left">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <polygon points="22 3 2 3 10 12.46 10 19 14 21 14 12.46 22 3"></polygon>
                        </svg>
                        Advanced Filters &amp; Search <span id="activeFilterCount" class="filter-count" style="display:none;"></span>
                    </div>
                    <div class="filter-header-right">
                        <button type="button" class="btn-reset-icon" onclick="event.stopPropagation(); resetAllFilters();" title="Reset All Filters">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M3 12a9 9 0 0 1 9-9 9.75 9.75 0 0 1 6.74 2.74L21 8"></path>
                                <path d="M21 3v5h-5"></path>
                                <path d="M21 12a9 9 0 0 1-9 9 9.75 9.75 0 0 1-6.74-2.74L3 16"></path>
                                <path d="M3 21v-5h5"></path>
                            </svg>
                        </button>
                        <div class="filter-toggle">
                            <span id="filterToggleText">COLLAPSE</span>
                            <svg class="filter-toggle-icon" id="filterToggleIcon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                                <polyline points="6 9 12 15 18 9"></polyline>
                            </svg>
                        </div>
                    </div>
                </div>
                <div class="filter-content" id="filterContent">
                    <!-- Basic Search & Type Section -->
                    <div class="filter-section">
                        <div class="filter-section-title">BASIC SEARCH</div>
                        <div class="filter-grid filter-grid-3col">
                            <div class="filter-group">
                                <label class="filter-label">Global Search</label>
                                <asp:TextBox ID="txtSearch" runat="server" CssClass="filter-input" 
                                             placeholder="ID, Name, Model, Description..." 
                                             AutoPostBack="true" OnTextChanged="ApplyFilters" />
                            </div>
                            <div class="filter-group">
                                <label class="filter-label">Equipment Type</label>
                                <asp:DropDownList ID="ddlEquipmentType" runat="server" CssClass="filter-select" 
                                                  AutoPostBack="true" OnSelectedIndexChanged="ApplyFilters">
                                    <asp:ListItem Text="All Types" Value="ALL" Selected="True" />
                                    <asp:ListItem Text="ATE" Value="ATE" />
                                    <asp:ListItem Text="Asset" Value="ASSET" />
                                    <asp:ListItem Text="Fixture" Value="FIXTURE" />
                                    <asp:ListItem Text="Harness" Value="HARNESS" />
                                </asp:DropDownList>
                            </div>
                            <div class="filter-group">
                                <label class="filter-label">Location</label>
                                <asp:DropDownList ID="ddlLocation" runat="server" CssClass="filter-select" 
                                                  AutoPostBack="true" OnSelectedIndexChanged="ApplyFilters">
                                    <asp:ListItem Text="All Locations" Value="ALL" Selected="True" />
                                </asp:DropDownList>
                            </div>
                        </div>
                    </div>

                    <!-- Equipment Details Section -->
                    <div class="filter-section">
                        <div class="filter-section-title">EQUIPMENT DETAILS</div>
                        <div class="filter-grid filter-grid-4col">
                            <div class="filter-group">
                                <label class="filter-label">Status</label>
                                <asp:DropDownList ID="ddlStatus" runat="server" CssClass="filter-select" 
                                                  AutoPostBack="true" OnSelectedIndexChanged="ApplyFilters">
                                    <asp:ListItem Text="All Status" Value="ALL" Selected="True" />
                                </asp:DropDownList>
                            </div>
                            <div class="filter-group">
                                <label class="filter-label">Manufacturer</label>
                                <asp:DropDownList ID="ddlManufacturer" runat="server" CssClass="filter-select" 
                                                  AutoPostBack="true" OnSelectedIndexChanged="ApplyFilters">
                                    <asp:ListItem Text="All Manufacturers" Value="ALL" Selected="True" />
                                </asp:DropDownList>
                            </div>
                            <div class="filter-group">
                                <label class="filter-label">Device Type</label>
                                <asp:DropDownList ID="ddlDeviceType" runat="server" CssClass="filter-select" 
                                                  AutoPostBack="true" OnSelectedIndexChanged="ApplyFilters">
                                    <asp:ListItem Text="All Device Types" Value="ALL" Selected="True" />
                                </asp:DropDownList>
                            </div>
                            <div class="filter-group">
                                <label class="filter-label">Swap Capability</label>
                                <asp:DropDownList ID="ddlSwap" runat="server" CssClass="filter-select" 
                                                  AutoPostBack="true" OnSelectedIndexChanged="ApplyFilters">
                                    <asp:ListItem Text="All" Value="ALL" Selected="True" />
                                    <asp:ListItem Text="Yes" Value="Yes" />
                                    <asp:ListItem Text="No" Value="No" />
                                </asp:DropDownList>
                            </div>
                        </div>
                    </div>

                    <!-- Calibration Section -->
                    <div class="filter-section">
                        <div class="filter-section-title">CALIBRATION FILTERS</div>
                        <div class="filter-grid filter-grid-4col">
                            <div class="filter-group">
                                <label class="filter-label">Requires Calibration</label>
                                <asp:DropDownList ID="ddlRequiresCal" runat="server" CssClass="filter-select" 
                                                  AutoPostBack="true" OnSelectedIndexChanged="ApplyFilters">
                                    <asp:ListItem Text="All" Value="ALL" Selected="True" />
                                    <asp:ListItem Text="Yes" Value="Yes" />
                                    <asp:ListItem Text="No" Value="No" />
                                </asp:DropDownList>
                            </div>
                            <div class="filter-group">
                                <label class="filter-label">Calibration Status</label>
                                <asp:DropDownList ID="ddlCalibration" runat="server" CssClass="filter-select" 
                                                  AutoPostBack="true" OnSelectedIndexChanged="ApplyFilters">
                                    <asp:ListItem Text="All" Value="ALL" Selected="True" />
                                    <asp:ListItem Text="Current" Value="CURRENT" />
                                    <asp:ListItem Text="Due Soon (includes Overdue)" Value="DUE_SOON" />
                                    <asp:ListItem Text="Overdue Only" Value="OVERDUE" />
                                </asp:DropDownList>
                            </div>
                            <div class="filter-group">
                                <label class="filter-label">Cal Frequency</label>
                                <asp:DropDownList ID="ddlCalFrequency" runat="server" CssClass="filter-select" 
                                                  AutoPostBack="true" OnSelectedIndexChanged="ApplyFilters">
                                    <asp:ListItem Text="All Frequencies" Value="ALL" Selected="True" />
                                </asp:DropDownList>
                            </div>
                            <div class="filter-group">
                                <label class="filter-label">Calibrated By</label>
                                <asp:DropDownList ID="ddlCalibratedBy" runat="server" CssClass="filter-select" 
                                                  AutoPostBack="true" OnSelectedIndexChanged="ApplyFilters">
                                    <asp:ListItem Text="All Technicians" Value="ALL" Selected="True" />
                                </asp:DropDownList>
                            </div>
                        </div>
                    </div>

                    <!-- Preventive Maintenance Section -->
                    <div class="filter-section">
                        <div class="filter-section-title">PREVENTIVE MAINTENANCE FILTERS</div>
                        <div class="filter-grid filter-grid-4col">
                            <div class="filter-group">
                                <label class="filter-label">Requires PM</label>
                                <asp:DropDownList ID="ddlRequiresPM" runat="server" CssClass="filter-select" 
                                                  AutoPostBack="true" OnSelectedIndexChanged="ApplyFilters">
                                    <asp:ListItem Text="All" Value="ALL" Selected="True" />
                                    <asp:ListItem Text="Yes" Value="Yes" />
                                    <asp:ListItem Text="No" Value="No" />
                                </asp:DropDownList>
                            </div>
                            <div class="filter-group">
                                <label class="filter-label">PM Status</label>
                                <asp:DropDownList ID="ddlPMStatus" runat="server" CssClass="filter-select" 
                                                  AutoPostBack="true" OnSelectedIndexChanged="ApplyFilters">
                                    <asp:ListItem Text="All" Value="ALL" Selected="True" />
                                    <asp:ListItem Text="Current" Value="CURRENT" />
                                    <asp:ListItem Text="Due Soon (includes Overdue)" Value="DUE_SOON" />
                                    <asp:ListItem Text="Overdue Only" Value="OVERDUE" />
                                </asp:DropDownList>
                            </div>
                            <div class="filter-group">
                                <label class="filter-label">PM Frequency</label>
                                <asp:DropDownList ID="ddlPMFrequency" runat="server" CssClass="filter-select" 
                                                  AutoPostBack="true" OnSelectedIndexChanged="ApplyFilters">
                                    <asp:ListItem Text="All Frequencies" Value="ALL" Selected="True" />
                                </asp:DropDownList>
                            </div>
                            <div class="filter-group">
                                <label class="filter-label">PM Responsible</label>
                                <asp:DropDownList ID="ddlPMResponsible" runat="server" CssClass="filter-select" 
                                                  AutoPostBack="true" OnSelectedIndexChanged="ApplyFilters">
                                    <asp:ListItem Text="All Personnel" Value="ALL" Selected="True" />
                                </asp:DropDownList>
                            </div>
                        </div>
                    </div>

                    <!-- Action Buttons -->
                    <div class="filter-actions">
                        <asp:Button ID="btnReset" runat="server" Text="Reset All Filters" 
                                    CssClass="btn-reset" OnClick="ResetFilters" />
                    </div>
                </div>
            </div>
            
            <!-- Table Container -->
            <div class="table-container">
                <div class="table-header">
                    <div class="table-title">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect>
                            <line x1="3" y1="9" x2="21" y2="9"></line>
                            <line x1="9" y1="21" x2="9" y2="9"></line>
                        </svg>
                        Equipment Inventory
                        <span class="record-count">(<asp:Literal ID="litRecordCount" runat="server" Text="0" /> records)</span>
                    </div>
                    <div class="table-actions">
                        <button type="button" class="btn-icon-action" title="Export to CSV" 
                                onclick="document.getElementById('<%=btnExportCSV.ClientID%>').click(); return false;">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path>
                                <polyline points="7 10 12 15 17 10"></polyline>
                                <line x1="12" y1="15" x2="12" y2="3"></line>
                            </svg>
                            Export CSV
                        </button>
                        <asp:Button ID="btnExportCSV" runat="server" OnClick="ExportToCSV" style="display:none;" />
                        <button type="button" class="btn-icon-action" title="Refresh" onclick="location.reload();">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <polyline points="23 4 23 10 17 10"></polyline>
                                <polyline points="1 20 1 14 7 14"></polyline>
                                <path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15"></path>
                            </svg>
                            Refresh
                        </button>
                    </div>
                </div>
                <div class="table-wrap">
                    <asp:GridView ID="gridEquipment" runat="server" CssClass="data-table" 
                                  AutoGenerateColumns="False" OnRowDataBound="gridEquipment_RowDataBound">
                    </asp:GridView>
                    <asp:Panel ID="pnlEmptyState" runat="server" Visible="false" CssClass="empty-state">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <circle cx="11" cy="11" r="8"></circle>
                            <path d="M21 21l-4.35-4.35"></path>
                        </svg>
                        <div class="empty-state-title">No Equipment Found</div>
                        <div class="empty-state-message">Try adjusting your filters or search criteria</div>
                    </asp:Panel>
                </div>
            </div>
        </div>
    </form>
    
    <script>
        // Filter toggle functionality with localStorage persistence
        function toggleFilters() {
            var content = document.getElementById('filterContent');
            var icon = document.getElementById('filterToggleIcon');
            var text = document.getElementById('filterToggleText');
            
            if (content.classList.contains('collapsed')) {
                // Expand
                content.classList.remove('collapsed');
                icon.classList.remove('collapsed');
                text.textContent = 'COLLAPSE';
                localStorage.setItem('equipmentGridFiltersExpanded', 'true');
            } else {
                // Collapse
                content.classList.add('collapsed');
                icon.classList.add('collapsed');
                text.textContent = 'EXPAND';
                localStorage.setItem('equipmentGridFiltersExpanded', 'false');
            }
        }
        
        // Reset all filters
        function resetAllFilters() {
            // Trigger the server-side reset button
            document.getElementById('<%= btnReset.ClientID %>').click();
        }
        
        // Restore filter state on page load
        window.addEventListener('DOMContentLoaded', function() {
            var content = document.getElementById('filterContent');
            var icon = document.getElementById('filterToggleIcon');
            var text = document.getElementById('filterToggleText');
            var isExpanded = localStorage.getItem('equipmentGridFiltersExpanded');
            
            // Default to COLLAPSED on first visit, then remember user preference
            if (isExpanded === 'true') {
                // User previously expanded it
                content.classList.remove('collapsed');
                icon.classList.remove('collapsed');
                text.textContent = 'COLLAPSE';
            } else {
                // Default: Start collapsed
                content.classList.add('collapsed');
                icon.classList.add('collapsed');
                text.textContent = 'EXPAND';
            }
            
            // Initialize filter count
            updateFilterCount();
            
            // Add row click handlers for table highlighting
            initializeRowHighlighting();
            
            // Initialize sticky header (CSS-based)
            initializeStickyHeader();
            
            // Debug: Log table info
            console.log('=== Equipment Grid View Initialized ===');
            var table = document.getElementById('<%= gridEquipment.ClientID %>');
            if (table && table.offsetParent !== null) { // Check if table exists and is visible
                console.log('Table found and visible:', table.tagName);
                console.log('Table ID:', table.id);
                console.log('Header rows:', table.querySelectorAll('.grid-header-row').length);
                console.log('Data rows:', table.querySelectorAll('tbody tr').length);
                console.log('Total columns:', table.querySelectorAll('.grid-header-row th').length);
            } else {
                console.log('Table not found or hidden (showing empty state)');
            }
        });
        
        // Count and display active filters
        function updateFilterCount() {
            var count = 0;
            var countBadge = document.getElementById('activeFilterCount');
            
            // Check text search
            var searchBox = document.getElementById('<%= txtSearch.ClientID %>');
            if (searchBox) {
                if (searchBox.value.trim() !== '') {
                    count++;
                    searchBox.classList.add('filter-active');
                } else {
                    searchBox.classList.remove('filter-active');
                }
            }
            
            // Check all dropdowns
            var dropdowns = [
                '<%= ddlEquipmentType.ClientID %>',
                '<%= ddlLocation.ClientID %>',
                '<%= ddlStatus.ClientID %>',
                '<%= ddlManufacturer.ClientID %>',
                '<%= ddlDeviceType.ClientID %>',
                '<%= ddlSwap.ClientID %>',
                '<%= ddlRequiresCal.ClientID %>',
                '<%= ddlCalibration.ClientID %>',
                '<%= ddlCalFrequency.ClientID %>',
                '<%= ddlCalibratedBy.ClientID %>',
                '<%= ddlRequiresPM.ClientID %>',
                '<%= ddlPMStatus.ClientID %>',
                '<%= ddlPMFrequency.ClientID %>',
                '<%= ddlPMResponsible.ClientID %>'
            ];
            
            dropdowns.forEach(function(id) {
                var dd = document.getElementById(id);
                if (dd) {
                    if (dd.value !== 'ALL') {
                        count++;
                        dd.classList.add('filter-active');
                    } else {
                        dd.classList.remove('filter-active');
                    }
                }
            });
            
            // Update badge
            if (count > 0) {
                countBadge.textContent = '(' + count + ')';
                countBadge.style.display = 'inline-flex';
            } else {
                countBadge.style.display = 'none';
            }
        }
        
        // Initialize row click highlighting
        function initializeRowHighlighting() {
            var table = document.getElementById('<%= gridEquipment.ClientID %>');
            if (!table) return;
            
            var rows = table.querySelectorAll('tbody tr');
            rows.forEach(function(row) {
                row.style.cursor = 'pointer';
                row.addEventListener('click', function() {
                    // Remove highlight from all rows
                    rows.forEach(function(r) {
                        r.classList.remove('row-selected');
                    });
                    // Add highlight to clicked row
                    this.classList.add('row-selected');
                });
            });
        }
        
        // Enhanced sticky header functionality
        function initializeStickyHeader() {
            // Sticky header is now handled purely by CSS
            // The .grid-header-row is position: sticky within the .table-wrap container
            console.log('Sticky header initialized via CSS');
        }
        
        // Load theme script dynamically to avoid linter issues
        (function() {
            var script = document.createElement('script');
            script.src = '<%= ResolveUrl("~/Scripts/theme.js") %>' + '?v=20250924-02';
            document.body.appendChild(script);
        })();
    </script>
</body>
</html>
