<%@ Page Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="EquipmentInventory.aspx.cs" Inherits="TED_EquipmentInventory" %>
<asp:Content ID="EqTitle" ContentPlaceHolderID="TitleContent" runat="server">Equipment Inventory - Test Engineering</asp:Content>
<asp:Content ID="EqHead" ContentPlaceHolderID="HeadContent" runat="server">
  <style>
    /* Prevent page-level horizontal scroll and keep width constrained */
    html, body { max-width:100%; overflow-x:hidden; }
    :root { --sidebar-w: 280px; }
  .dash-shell { --col-btm-gap: 12px; display:grid; grid-template-columns: var(--sidebar-w) 1fr; gap:18px; height:calc(100dvh - var(--vh-offset)); padding:10px 18px 34px; box-sizing:border-box; }
  /* Ensure grid children can shrink and do not force overflow */
  .dash-shell > * { min-width:0; min-height:0; }
  .dash-sidebar { position:sticky; top:12px; height:calc(100% - 12px - var(--col-btm-gap)); margin-bottom:var(--col-btm-gap); display:flex; flex-direction:column; background:rgba(25,29,37,.55); border:1px solid rgba(255,255,255,.08); border-radius:18px; box-shadow:0 16px 36px -10px rgba(0,0,0,.6), 0 0 0 1px rgba(255,255,255,.05), 0 0 10px rgba(235,235,240,.12); backdrop-filter:blur(40px) saturate(140%); padding:16px 14px; overflow:auto; }
    html.theme-light .dash-sidebar, html[data-theme='light'] .dash-sidebar { background:rgba(255,255,255,.7); border:1px solid rgba(0,0,0,.08); box-shadow:0 14px 34px -12px rgba(0,0,0,.25), 0 0 0 1px rgba(0,0,0,.05), 0 0 10px rgba(0,0,0,.12); }
    /* Sidebar user header + logout styles (match Dashboard) */
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
    /* Danger-styled nav item (Logout) */
    .nav-link.danger { color:#ff6b6b; border-color:transparent; }
    .nav-link.danger .icon { color:currentColor; }
    .nav-link.danger:hover { background:rgba(255,86,86,.14); border-color:rgba(255,86,86,.35); color:#ff8a8a; }
    html.theme-light .nav-link.danger, html[data-theme='light'] .nav-link.danger { color:#c62828; }
    html.theme-light .nav-link.danger:hover, html[data-theme='light'] .nav-link.danger:hover { background:rgba(198,40,40,.10); border-color:rgba(198,40,40,.35); color:#b71c1c; }
    /* Disabled-styled nav item (unbuilt features) */
    .nav-link.disabled { opacity:.45; cursor:not-allowed; pointer-events:none; color:#888; }
    .nav-link.disabled .icon { opacity:.5; }
    html.theme-light .nav-link.disabled, html[data-theme='light'] .nav-link.disabled { color:#999; opacity:.5; }
    .user-info { display:flex; align-items:center; gap:10px; padding:6px 6px 10px; }
    .avatar { width:34px; height:34px; border-radius:50%; display:flex; align-items:center; justify-content:center; background:rgba(255,255,255,.1); border:1px solid rgba(255,255,255,.2); font-weight:700; }
    html.theme-light .avatar, html[data-theme='light'] .avatar { background:#f1f4f9; border:1px solid rgba(0,0,0,.12); color:#1b222b; }
    .btn-logout { display:inline-flex; align-items:center; gap:8px; padding:10px 12px; border-radius:12px; text-decoration:none; border:1px solid rgba(255,255,255,.12); color:inherit; background:linear-gradient(155deg,#1a2027,#14191f); box-shadow:0 2px 4px rgba(0,0,0,.5); font-size:12px; font-weight:600; letter-spacing:.2px; }
    .btn-logout:hover { background:linear-gradient(155deg,#242c35,#1a2027); border-color:rgba(255,255,255,.22); }
    html.theme-light .btn-logout, html[data-theme='light'] .btn-logout { background:linear-gradient(165deg,#ffffff,#eef2f7); color:#1f242b; border:1px solid rgba(0,0,0,.14); box-shadow:0 3px 6px rgba(0,0,0,.18), 0 1px 2px rgba(255,255,255,.6) inset; }
    html.theme-light .btn-logout:hover, html[data-theme='light'] .btn-logout:hover { background:#ffffff; }

  .dash-col { grid-column: 2 / 3; display:flex; flex-direction:column; gap:8px; min-width:0; height:100%; min-height:0; padding-bottom:var(--col-btm-gap); box-sizing:border-box; }
  /* Make main container transparent and clamp to viewport; scroll happens inside .equip-panel */
  .dash-main { background:transparent; border:none; border-radius:0; box-shadow:none; backdrop-filter:none; padding:0; overflow:hidden; display:flex; flex-direction:column; flex:1; min-height:0; }
    html.theme-light .dash-main, html[data-theme='light'] .dash-main { background:transparent; border:none; box-shadow:none; }
  /* Page title placed above the panel, outside the dash group */
  .page-title-wrap { align-self:start; padding:0; }
  .page-title { font-size:22px; font-weight:800; letter-spacing:.2px; margin:0 0 6px; }

    .equip-shell { padding:0; }
  /* Panel now doesn't scroll; table container handles it */
  .equip-panel { background:rgba(25,29,37,.52); border:1px solid rgba(255,255,255,.08); border-radius:18px; box-shadow:0 16px 36px -10px rgba(0,0,0,.6), 0 0 0 1px rgba(255,255,255,.05); backdrop-filter:blur(36px) saturate(135%); padding:16px 18px 20px; margin:0 8px 0 0; min-height:220px; flex:1; min-height:0; display:flex; flex-direction:column; overflow:hidden; }
    html.theme-light .equip-panel, html[data-theme='light'] .equip-panel { background:rgba(255,255,255,.72); border:1px solid rgba(0,0,0,.08); box-shadow:0 14px 34px -12px rgba(0,0,0,.18), 0 0 0 1px rgba(0,0,0,.05); }
    .equip-topbar { display:flex; align-items:center; justify-content:space-between; gap:12px; margin-bottom:14px; }
    .equip-title { font-size:20px; font-weight:700; letter-spacing:.2px; }
    .cards { display:grid; grid-template-columns:repeat(auto-fill,minmax(270px,1fr)); gap:16px; margin:6px 0 16px; }
    /* Card: glassmorphism base */
    .card { position:relative; display:block; color:inherit; border-radius:16px; padding:16px 18px; cursor:pointer; text-decoration:none;
      background:linear-gradient(180deg, rgba(255,255,255,.65), rgba(255,255,255,.48));
      border:1px solid rgba(17,24,39,.08);
      box-shadow:0 18px 38px -22px rgba(10,16,28,.35), 0 1px 0 rgba(255,255,255,.65) inset;
      backdrop-filter:blur(16px) saturate(160%);
      transition:transform .18s ease, box-shadow .18s ease, border-color .18s ease, background .18s ease; }
    html:not(.theme-light):not([data-theme='light']) .card {
      background:linear-gradient(180deg, rgba(22,28,42,.52), rgba(16,21,34,.42));
      border:1px solid rgba(255,255,255,.08);
      box-shadow:0 24px 44px -28px rgba(0,0,0,.65), 0 0 0 1px rgba(255,255,255,.04) inset;
      backdrop-filter:blur(18px) saturate(140%);
    }
    .card:hover { transform:translateY(-2px); box-shadow:0 22px 46px -26px rgba(10,16,28,.4); }
    .card.active { border-color: var(--accent-border, rgba(46,144,250,.55)); 
      box-shadow:0 22px 48px -28px rgba(10,16,28,.45), 0 0 0 2px var(--accent-border, rgba(46,144,250,.45)) inset; }
    /* Dark mode active card with outer glow */
    html:not(.theme-light):not([data-theme='light']) .card.active { 
      box-shadow:0 24px 52px -30px rgba(0,0,0,.65), 0 0 0 2px var(--accent-border, rgba(46,144,250,.45)) inset,
                 0 0 24px -8px var(--accent, rgba(46,144,250,.25)); }
    /* Light mode active card with outer glow matching accent color */
    html.theme-light .card.active, html[data-theme='light'] .card.active {
      box-shadow:0 18px 38px -22px var(--accent, rgba(46,144,250,.35)), 
                 0 0 0 2px var(--accent-border, rgba(46,144,250,.55)) inset,
                 0 0 24px -6px var(--accent, rgba(46,144,250,.3));
    }
  .card-title { font-size:12.5px; letter-spacing:.2px; opacity:.78; margin-bottom:6px; font-weight:600; }
  .card-value { font-size:28px; font-weight:800; line-height:1.05; }
  .card-row { display:flex; align-items:center; justify-content:flex-start; gap:14px; }
  /* Left icon token - smooth professional design */
  .card-ico { order:-1; width:52px; height:52px; border-radius:16px; display:flex; align-items:center; justify-content:center; flex:0 0 auto;
    background:linear-gradient(145deg, #f8fafc, #e2e8f0); color:#64748b; border:none; 
    box-shadow:0 4px 12px -4px rgba(15,23,42,.08), 0 1px 0 rgba(255,255,255,.85) inset, 0 -1px 0 rgba(15,23,42,.05) inset; 
    transition:all .22s cubic-bezier(0.4, 0, 0.2, 1); }
  html:not(.theme-light):not([data-theme='light']) .card-ico { 
    background:linear-gradient(145deg, #334155, #1e293b); color:#94a3b8; 
    box-shadow:0 4px 12px -4px rgba(0,0,0,.25), 0 1px 0 rgba(255,255,255,.06) inset, 0 -1px 0 rgba(0,0,0,.15) inset; }
  .card.active .card-ico { 
    background:linear-gradient(145deg, var(--accent, #2E90FA), color-mix(in srgb, var(--accent, #2E90FA) 85%, #000)); 
    color:#ffffff; transform:scale(1.05); 
    box-shadow:0 8px 32px -8px var(--accent, #2E90FA), 0 0 0 4px color-mix(in srgb, var(--accent, #2E90FA) 25%, transparent), 
               0 2px 0 rgba(255,255,255,.2) inset, 0 -2px 0 rgba(0,0,0,.15) inset; }
  html:not(.theme-light):not([data-theme='light']) .card.active .card-ico { 
    box-shadow:0 12px 36px -10px var(--accent, #2E90FA), 0 0 0 4px color-mix(in srgb, var(--accent, #2E90FA) 20%, transparent), 
               0 2px 0 rgba(255,255,255,.15) inset, 0 -2px 0 rgba(0,0,0,.25) inset; }
  .card-ico .icon { width:24px; height:24px; display:block; }
  /* Accent palettes per card type */
  .card-ate { --accent:#2E90FA; --accent-border:rgba(46,144,250,.55); }
  .card-asset { --accent:#F59E0B; --accent-border:rgba(245,158,11,.55); }
  .card-fixture { --accent:#8E24AA; --accent-border:rgba(142,36,170,.55); }
  .card-harness { --accent:#26A69A; --accent-border:rgba(38,166,154,.55); }
  /* Type classes kept for future accents (no styles applied for now) */

  /* Table styles copied from Manage Users for exact look */
  /* Table wrapper with vertical scroll and modern scrollbar */
  .table-wrap { 
    width:100%; 
    max-width:100%; 
    max-height: calc(100vh - 380px); /* Dynamic height based on viewport */
    overflow-x:auto; 
    overflow-y:auto; 
    border-radius:12px; 
    border:1px solid rgba(255,255,255,.08); 
    background:rgba(25,29,37,.32); 
    box-sizing:border-box;
    flex: 1;
    min-height: 0;
  }
  html.theme-light .table-wrap, html[data-theme='light'] .table-wrap { background:#fff; border:1px solid rgba(0,0,0,.08); }
  
  /* Modern Custom Scrollbar - Dark Mode */
  .table-wrap::-webkit-scrollbar {
    width: 8px;
    height: 8px;
  }
  .table-wrap::-webkit-scrollbar-track {
    background: transparent;
  }
  .table-wrap::-webkit-scrollbar-thumb {
    background: rgba(255,255,255,.15);
    border-radius: 10px;
    border: 2px solid transparent;
    background-clip: padding-box;
  }
  .table-wrap::-webkit-scrollbar-thumb:hover {
    background: rgba(255,255,255,.25);
    background-clip: padding-box;
  }
  .table-wrap::-webkit-scrollbar-corner {
    background: transparent;
  }
  
  /* Modern Custom Scrollbar - Light Mode */
  html.theme-light .table-wrap::-webkit-scrollbar-thumb,
  html[data-theme='light'] .table-wrap::-webkit-scrollbar-thumb {
    background: rgba(0,0,0,.15);
    background-clip: padding-box;
  }
  html.theme-light .table-wrap::-webkit-scrollbar-thumb:hover,
  html[data-theme='light'] .table-wrap::-webkit-scrollbar-thumb:hover {
    background: rgba(0,0,0,.25);
    background-clip: padding-box;
  }
  
  /* Firefox Scrollbar */
  .table-wrap {
    scrollbar-width: thin;
    scrollbar-color: rgba(255,255,255,.15) transparent;
  }
  html.theme-light .table-wrap,
  html[data-theme='light'] .table-wrap {
    scrollbar-color: rgba(0,0,0,.15) transparent;
  }
  table.data-table { width:100%; min-width:2000px; border-collapse:separate; border-spacing:0; font-size:11.5px; table-layout:fixed; }
  /* Ensure widths include padding/border and don’t grow based on content */
  table.data-table th, table.data-table td { box-sizing:border-box; }
  /* Header styling */
  table.data-table thead th, table.data-table th { position:sticky; top:0; z-index:1; background:#0b63ce !important; color:#ffffff !important; border-bottom:1px solid rgba(0,0,0,.12) !important; text-align:center; font-size:12px; padding:16px 12px !important; font-weight:800; letter-spacing:.25px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
  html:not(.theme-light):not([data-theme='light']) table.data-table thead th,
  html:not(.theme-light):not([data-theme='light']) table.data-table th { background:linear-gradient(180deg,#0f1628,#0a1324) !important; color:#e9eef8 !important; border-bottom:1px solid rgba(255,255,255,.18) !important; }
  table.data-table thead th a, table.data-table th a { color: inherit !important; text-decoration: none !important; }
  table.data-table tbody td { padding:14px 16px; border-bottom:1px solid rgba(255,255,255,.07); vertical-align:middle; text-align:center; overflow:hidden; }
  html.theme-light table.data-table tbody td, html[data-theme='light'] table.data-table tbody td { border-bottom:1px solid rgba(0,0,0,.06); }
  table.data-table tbody tr:nth-child(odd) { background:rgba(255,255,255,.015); }
  html.theme-light table.data-table tbody tr:nth-child(odd) { background:#fafbfe; }
  table.data-table tbody tr:hover { background:rgba(255,255,255,.04); }
  html.theme-light table.data-table tbody tr:hover, html[data-theme='light'] table.data-table tbody tr:hover { background:#fafcff; }
  /* Inline editor controls */
  .inline-input { width:100%; padding:8px 10px; border-radius:10px; border:1px solid rgba(255,255,255,.18); background:rgba(0,0,0,.12); color:inherit; font:inherit; font-size:13px; box-sizing:border-box; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
  html.theme-light .inline-input, html[data-theme='light'] .inline-input { background:#fff; border:1px solid rgba(0,0,0,.14); color:#1f242b; }
  .inline-input[disabled], .inline-input[readonly] { opacity:.8; background:rgba(255,255,255,.06); cursor:not-allowed; }
  html.theme-light .inline-input[disabled], html.theme-light .inline-input[readonly], html[data-theme='light'] .inline-input[disabled], html[data-theme='light'] .inline-input[readonly] { background:#f5f7fb; color:#6b7480; }
  /* Dropdown styling */
  .inline-dropdown { width:100%; padding:8px 10px; border-radius:10px; border:1px solid rgba(255,255,255,.18); background:rgba(0,0,0,.12); color:inherit; font:inherit; font-size:13px; box-sizing:border-box; }
  html.theme-light .inline-dropdown, html[data-theme='light'] .inline-dropdown { background:#fff; border:1px solid rgba(0,0,0,.14); color:#1f242b; }
  .inline-dropdown[disabled], .inline-dropdown.readonly { opacity:.8; background:rgba(255,255,255,.06); cursor:not-allowed; }
  html.theme-light .inline-dropdown[disabled], html.theme-light .inline-dropdown.readonly, html[data-theme='light'] .inline-dropdown[disabled], html[data-theme='light'] .inline-dropdown.readonly { background:#f5f7fb; color:#6b7480; }
  /* Toggle switch styling for boolean fields */
  .toggle-switch { appearance:none; -webkit-appearance:none; position:relative; width:42px; height:24px; border-radius:999px; background:rgba(255,255,255,.14); border:1px solid rgba(255,255,255,.22); outline:none; cursor:pointer; transition:all .18s ease; display:inline-block; }
  .toggle-switch::before { content:""; position:absolute; top:2px; left:2px; width:20px; height:20px; border-radius:50%; background:#d0d7e2; box-shadow:0 1px 2px rgba(0,0,0,.35); transition:all .18s ease; }
  .toggle-switch:checked { background:rgba(70,180,110,.45); border-color:rgba(70,180,110,.65); }
  .toggle-switch:checked::before { left:20px; background:#e9fff0; }
  html.theme-light .toggle-switch, html[data-theme='light'] .toggle-switch { background:#e6ebf3; border:1px solid rgba(0,0,0,.14); }
  html.theme-light .toggle-switch::before, html[data-theme='light'] .toggle-switch::before { background:#ffffff; }
  html.theme-light .toggle-switch:checked, html[data-theme='light'] .toggle-switch:checked { background:#b5e6c7; border-color:#6bc28d; }
  /* Actions buttons */
  .tbl-actions { display:flex; gap:6px; justify-content:center; align-items:center; width:100%; }
  .col-actions .tbl-actions { justify-content:center; margin:0 auto; max-width:140px; }
  .save-btn, .detail-btn, .del-btn, .new-btn { width:34px; height:34px; display:inline-flex; align-items:center; justify-content:center; border-radius:8px; border:1px solid rgba(255,255,255,.18); cursor:pointer; transition: background .15s ease, border-color .15s ease, box-shadow .15s ease, transform .12s ease; }
  .del-btn { border:1px solid rgba(255,86,86,.35); background:rgba(255,86,86,.22); color:#ffc6c6; }
  .save-btn { background:rgba(30,180,90,.18); color:#e2ffe6; }
  .detail-btn { background:rgba(255,140,0,.18); color:#ffe0b3; border:1px solid rgba(255,140,0,.35); }
  .new-btn { background:rgba(80,140,255,.18); color:#cfe0ff; border:1px solid rgba(80,140,255,.35); }
  /* Hover (dark theme) */
  .save-btn:hover { background:rgba(30,180,90,.28); border-color:rgba(30,180,90,.55); box-shadow:0 2px 6px rgba(0,0,0,.3); transform:translateY(-1px); }
  .detail-btn:hover { background:rgba(255,140,0,.26); border-color:rgba(255,140,0,.55); box-shadow:0 2px 6px rgba(0,0,0,.3); transform:translateY(-1px); }
  .del-btn:hover { background:rgba(255,86,86,.3); border-color:rgba(255,86,86,.65); box-shadow:0 2px 6px rgba(0,0,0,.3); transform:translateY(-1px); }
  .new-btn:hover { background:rgba(80,140,255,.26); border-color:rgba(80,140,255,.55); box-shadow:0 2px 6px rgba(0,0,0,.3); transform:translateY(-1px); }
  html.theme-light .save-btn, html[data-theme='light'] .save-btn { border:1px solid rgba(0,0,0,.12); background:#e8f5ed; color:#1e7f45; }
  html.theme-light .detail-btn, html[data-theme='light'] .detail-btn { border:1px solid rgba(0,0,0,.12); background:#fff4e6; color:#cc7a00; }
  html.theme-light .del-btn, html[data-theme='light'] .del-btn { border:1px solid rgba(0,0,0,.12); background:#ffe9e9; color:#9b1c1c; }
  html.theme-light .new-btn, html[data-theme='light'] .new-btn { border:1px solid rgba(0,0,0,.12); background:#e8f0ff; color:#1b3f9b; }
  /* Hover (light theme) */
  html.theme-light .save-btn:hover, html[data-theme='light'] .save-btn:hover { background:#dff0e7; border-color:rgba(0,0,0,.22); box-shadow:0 2px 6px rgba(0,0,0,.15); transform:translateY(-1px); }
  html.theme-light .detail-btn:hover, html[data-theme='light'] .detail-btn:hover { background:#ffedd6; border-color:rgba(0,0,0,.22); box-shadow:0 2px 6px rgba(0,0,0,.15); transform:translateY(-1px); }
  html.theme-light .del-btn:hover, html[data-theme='light'] .del-btn:hover { background:#ffdede; border-color:rgba(198,40,40,.45); box-shadow:0 2px 6px rgba(0,0,0,.15); transform:translateY(-1px); }
  html.theme-light .new-btn:hover, html[data-theme='light'] .new-btn:hover { background:#dfe8ff; border-color:rgba(0,0,0,.22); box-shadow:0 2px 6px rgba(0,0,0,.15); transform:translateY(-1px); }
  /* Disabled state styling for action buttons */
  .tbl-actions button[disabled] { background:#8a96a8 !important; color:#e6ebf2 !important; border-color:rgba(0,0,0,.18) !important; cursor:not-allowed !important; pointer-events:none !important; box-shadow:none !important; transform:none !important; opacity:.75; }
  html.theme-light .tbl-actions button[disabled], html[data-theme='light'] .tbl-actions button[disabled] { background:#e2e7ef !important; color:#96a0ae !important; border-color:rgba(0,0,0,.14) !important; }
  .tbl-actions button[disabled]:hover { background:inherit; border-color:inherit; box-shadow:none; transform:none; }
  /* Focus-visible for accessibility */
  .save-btn:focus-visible, .detail-btn:focus-visible, .del-btn:focus-visible, .new-btn:focus-visible { outline:none; box-shadow:0 0 0 2px rgba(255,255,255,.55), 0 0 0 4px rgba(80,140,255,.55); }
  html.theme-light .save-btn:focus-visible, html.theme-light .detail-btn:focus-visible, html.theme-light .del-btn:focus-visible, html.theme-light .new-btn:focus-visible,
  html[data-theme='light'] .save-btn:focus-visible, html[data-theme='light'] .detail-btn:focus-visible, html[data-theme='light'] .del-btn:focus-visible, html[data-theme='light'] .new-btn:focus-visible { box-shadow:0 0 0 2px rgba(255,255,255,.9), 0 0 0 4px rgba(30,90,200,.45); }
  .save-btn svg, .detail-btn svg, .del-btn svg, .new-btn svg { width:16px; height:16px; display:block; }

  /* Actions column as normal (non-sticky) so it stays at the far-right cell and doesn’t float */
  table.data-table thead th.col-actions, table.data-table tbody td.col-actions { position:static; right:auto; box-shadow:none; }
  table.data-table thead th.col-actions, table.data-table tbody td.col-actions { text-align:center; }

  /* Toolbar */
  .table-toolbar { display:grid; grid-template-columns: 1fr auto; gap:12px; align-items:center; margin:8px 0 12px; }
  .toolbar-left, .toolbar-right { display:flex; align-items:center; gap:8px; }
  .search-input { width:320px; max-width:30vw; padding:8px 10px; border-radius:10px; border:1px solid rgba(255,255,255,.18); background:rgba(0,0,0,.12); color:inherit; font:inherit; font-size:13px; }
  html.theme-light .search-input, html[data-theme='light'] .search-input { background:#fff; border:1px solid rgba(0,0,0,.14); color:#1f242b; }
  .ddl { padding:8px 10px; border-radius:10px; border:1px solid rgba(255,255,255,.18); background:rgba(0,0,0,.12); color:inherit; font:inherit; font-size:13px; }
  html.theme-light .ddl, html[data-theme='light'] .ddl { background:#fff; border:1px solid rgba(0,0,0,.14); color:#1f242b; }
  
  /* Primary Button */
  .btn-primary { 
    padding:9px 16px; 
    border-radius:10px; 
    border:1px solid rgba(77,141,255,.4); 
    background:linear-gradient(135deg, rgba(77,141,255,.25), rgba(77,141,255,.15));
    color:#bcd4ff; 
    font:inherit; 
    font-size:13px; 
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

  /* Secondary Button (for CSV download) */
  .btn-secondary { 
    padding:9px 16px; 
    border-radius:10px; 
    border:1px solid rgba(255,255,255,.18); 
    background:rgba(255,255,255,.08);
    color:inherit; 
    font:inherit; 
    font-size:13px; 
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

  /* Icon-Only Buttons */
  .btn-icon {
    position: relative;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 40px;
    height: 40px;
    padding: 0;
    border-radius: 10px;
    border: 1px solid rgba(255,255,255,.18);
    background: rgba(255,255,255,.08);
    color: inherit;
    cursor: pointer;
    transition: all .2s ease;
    white-space: nowrap;
  }
  .btn-icon svg {
    width: 20px;
    height: 20px;
    stroke-width: 2;
  }
  .btn-icon:hover {
    background: rgba(255,255,255,.15);
    border-color: rgba(255,255,255,.3);
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(0,0,0,.2);
  }
  html.theme-light .btn-icon, html[data-theme='light'] .btn-icon {
    background: #f5f7fa;
    border: 1px solid rgba(0,0,0,.12);
    color: #1f242b;
  }
  html.theme-light .btn-icon:hover, html[data-theme='light'] .btn-icon:hover {
    background: #e8ecf1;
    border-color: rgba(0,0,0,.20);
    box-shadow: 0 4px 12px rgba(0,0,0,.12);
  }

  /* Primary Icon Button (for Add New) */
  .btn-icon.btn-icon-primary {
    border: 1px solid rgba(77,141,255,.4);
    background: linear-gradient(135deg, rgba(77,141,255,.25), rgba(77,141,255,.15));
    color: #bcd4ff;
    box-shadow: 0 2px 8px rgba(77,141,255,.2);
  }
  .btn-icon.btn-icon-primary:hover {
    background: linear-gradient(135deg, rgba(77,141,255,.35), rgba(77,141,255,.25));
    border-color: rgba(77,141,255,.5);
    box-shadow: 0 4px 12px rgba(77,141,255,.3);
  }
  html.theme-light .btn-icon.btn-icon-primary, html[data-theme='light'] .btn-icon.btn-icon-primary {
    background: linear-gradient(135deg, #4d8dff, #3b7eef);
    border: 1px solid #2563eb;
    color: #ffffff;
    box-shadow: 0 2px 8px rgba(37,99,235,.25);
  }
  html.theme-light .btn-icon.btn-icon-primary:hover, html[data-theme='light'] .btn-icon.btn-icon-primary:hover {
    background: linear-gradient(135deg, #5c9aff, #4a87f5);
    box-shadow: 0 4px 12px rgba(37,99,235,.35);
  }

  /* Modern Tooltip */
  .btn-icon[data-tooltip] {
    position: relative;
  }
  .btn-icon[data-tooltip]::before {
    content: attr(data-tooltip);
    position: absolute;
    bottom: calc(100% + 8px);
    right: 0;
    transform: translateY(-4px);
    padding: 8px 12px;
    background: rgba(15,23,42,.96);
    color: #e2e8f0;
    font-size: 13px;
    font-weight: 500;
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
    white-space: nowrap;
    border-radius: 8px;
    opacity: 0;
    pointer-events: none;
    transition: all .2s cubic-bezier(0.4, 0, 0.2, 1);
    box-shadow: 0 10px 25px -5px rgba(0,0,0,.4), 0 8px 10px -6px rgba(0,0,0,.3);
    z-index: 10000;
    letter-spacing: 0.01em;
  }
  .btn-icon[data-tooltip]::after {
    content: '';
    position: absolute;
    bottom: calc(100% + 2px);
    right: 12px;
    width: 0;
    height: 0;
    border-left: 6px solid transparent;
    border-right: 6px solid transparent;
    border-top: 6px solid rgba(15,23,42,.96);
    opacity: 0;
    pointer-events: none;
    transition: all .2s cubic-bezier(0.4, 0, 0.2, 1);
    z-index: 10000;
  }
  .btn-icon[data-tooltip]:hover::before {
    opacity: 1;
    transform: translateY(0);
  }
  .btn-icon[data-tooltip]:hover::after {
    opacity: 1;
  }
  html.theme-light .btn-icon[data-tooltip]::before, html[data-theme='light'] .btn-icon[data-tooltip]::before {
    background: rgba(30,41,59,.96);
    color: #f1f5f9;
    box-shadow: 0 10px 25px -5px rgba(0,0,0,.25), 0 8px 10px -6px rgba(0,0,0,.2);
  }
  html.theme-light .btn-icon[data-tooltip]::after, html[data-theme='light'] .btn-icon[data-tooltip]::after {
    border-top-color: rgba(30,41,59,.96);
  }

  /* Accent Button (for Grid View - Purple/Violet) */
  .btn-icon.btn-icon-accent {
    border: 1px solid rgba(139,92,246,.4);
    background: linear-gradient(135deg, rgba(139,92,246,.25), rgba(139,92,246,.15));
    color: #ddd6fe;
    box-shadow: 0 2px 8px rgba(139,92,246,.2);
  }
  .btn-icon.btn-icon-accent:hover {
    background: linear-gradient(135deg, rgba(139,92,246,.35), rgba(139,92,246,.25));
    border-color: rgba(139,92,246,.5);
    box-shadow: 0 4px 12px rgba(139,92,246,.3);
  }
  html.theme-light .btn-icon.btn-icon-accent, html[data-theme='light'] .btn-icon.btn-icon-accent {
    background: linear-gradient(135deg, #8b5cf6, #7c3aed);
    border: 1px solid #7c3aed;
    color: #ffffff;
    box-shadow: 0 2px 8px rgba(124,58,237,.25);
  }
  html.theme-light .btn-icon.btn-icon-accent:hover, html[data-theme='light'] .btn-icon.btn-icon-accent:hover {
    background: linear-gradient(135deg, #9d6dff, #8b5cf6);
    box-shadow: 0 4px 12px rgba(124,58,237,.35);
  }

  /* Orange Button (for View Details) */
  .btn-icon.btn-icon-orange {
    border: 1px solid rgba(255,140,0,.4);
    background: linear-gradient(135deg, rgba(255,140,0,.25), rgba(255,140,0,.15));
    color: #ffe0b3;
    box-shadow: 0 2px 8px rgba(255,140,0,.2);
  }
  .btn-icon.btn-icon-orange:hover {
    background: linear-gradient(135deg, rgba(255,140,0,.35), rgba(255,140,0,.25));
    border-color: rgba(255,140,0,.5);
    box-shadow: 0 4px 12px rgba(255,140,0,.3);
  }
  html.theme-light .btn-icon.btn-icon-orange, html[data-theme='light'] .btn-icon.btn-icon-orange {
    background: linear-gradient(135deg, #ff8c00, #e67e00);
    border: 1px solid #e67e00;
    color: #ffffff;
    box-shadow: 0 2px 8px rgba(255,140,0,.25);
  }
  html.theme-light .btn-icon.btn-icon-orange:hover, html[data-theme='light'] .btn-icon.btn-icon-orange:hover {
    background: linear-gradient(135deg, #ff9933, #ff8c00);
    box-shadow: 0 4px 12px rgba(255,140,0,.35);
  }

  /* Modern Pagination Styles - Minimal & Compact */
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
  /* Current page */
  .pagination-container span.current {
    background: rgba(77,141,255,.15);
    border-color: rgba(77,141,255,.3);
    color: #bcd4ff;
    font-weight: 600;
  }
  /* Hoverable links */
  .pagination-container a:hover {
    background: rgba(255,255,255,.08);
    border-color: rgba(255,255,255,.15);
  }
  /* Navigation arrows */
  .pagination-container a.nav-arrow {
    font-size: 14px;
    min-width: 24px;
    height: 24px;
  }
  /* Light mode */
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
  
  /* Hide default GridView pager */
  .data-table tr.pager {
    display: none !important;
  }
  /* Ensure only the table wrapper scrolls horizontally (handled by .table-wrap). */
  /* Main panel overflow handled above; inner .equip-panel uses overflow:auto. */

  /* Extra padding for key columns */
  table.data-table thead th.col-eatonid, table.data-table tbody td.col-eatonid { padding-left:18px !important; padding-right:18px !important; }
  table.data-table thead th.col-name, table.data-table tbody td.col-name { padding-left:20px !important; padding-right:20px !important; }
  table.data-table thead th.col-description, table.data-table tbody td.col-description { padding-left:20px !important; padding-right:20px !important; }
  table.data-table thead th.col-location, table.data-table tbody td.col-location { padding-left:18px !important; padding-right:18px !important; }
  /* Also add padding inside the inputs so it’s visible */
  table.data-table tbody td.col-eatonid .inline-input { padding-left:14px; padding-right:14px; }
  table.data-table tbody td.col-name .inline-input { padding-left:16px; padding-right:16px; }
  table.data-table tbody td.col-description .inline-input { padding-left:16px; padding-right:16px; }
  table.data-table tbody td.col-location .inline-input { padding-left:14px; padding-right:14px; }

    /* Toast */
    .toast { position:fixed; right:16px; bottom:16px; background:#1e293b; color:#fff; border-radius:10px; padding:12px 14px; box-shadow:0 10px 24px rgba(0,0,0,.5); z-index:9999; opacity:0; transform:translateY(16px); transition:all .25s ease; }
    .toast.show { opacity:1; transform:translateY(0); }
    .toast-success { background:#059669; border-left:4px solid #10b981; }
    .toast-error { background:#dc2626; border-left:4px solid #f87171; }
    .toast-info { background:#2563eb; border-left:4px solid #60a5fa; }

    /* Message Banner */
    .msg-banner { position:fixed; top:12px; left:50%; transform:translateX(-50%); z-index:9999; padding:12px 16px; border-radius:12px; border:1px solid rgba(255,255,255,.12); background:rgba(9,86,20,.9); color:#e7ffe7; display:flex; align-items:center; gap:12px; box-shadow:0 12px 28px rgba(0,0,0,.35); min-width:280px; max-width:70vw; }
    .msg-banner.info { background: rgba(44,87,160,.22); color:#e9f2ff; }
    .msg-banner.error { background: rgba(148,31,31,.22); color:#ffe9e9; }
    .msg-banner .close { background:transparent; border:none; color:inherit; font-size:20px; font-weight:bold; cursor:pointer; padding:0 4px; opacity:.7; line-height:1; }
    .msg-banner .close:hover { opacity:1; }
    html.theme-light .msg-banner, html[data-theme='light'] .msg-banner { border: 1px solid rgba(0,0,0,.12); background:#e9f9ef; color:#0f3b1d; }
    html.theme-light .msg-banner.info, html[data-theme='light'] .msg-banner.info { background:#e9f0ff; color:#0b2960; }
    html.theme-light .msg-banner.error, html[data-theme='light'] .msg-banner.error { background:#ffe9e9; color:#5d0b0b; }
  </style>
</asp:Content>
<asp:Content ID="EqMain" ContentPlaceHolderID="MainContent" runat="server">
  <div class="dash-shell">
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
    <section class="dash-col">
      <div class="page-title-wrap">
        <h1 id="hEq" class="page-title">Equipment Inventory</h1>
        <asp:PlaceHolder ID="phMessage" runat="server" />
      </div>
      <div class="dash-main" role="main" aria-labelledby="hEq">
      <div class="equip-panel">

      <div class="cards">
        <!-- ATE: House/Substation icon -->
        <a id="btnCardATE" runat="server" class="card card-ate" onserverclick="Card_ServerClick" data-type="ATE">
          <div class="card-row">
            <div>
              <div class="card-title">ATE</div>
              <div class="card-value"><asp:Literal ID="litCountATE" runat="server" Text="--"/></div>
            </div>
            <div class="card-ico" aria-hidden="true">
              <svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false">
                <rect x="3" y="4" width="18" height="14" rx="2" />
                <path d="M7 8v4M12 6v8M17 9v2" />
                <path d="M7 18v2M12 18v2M17 18v2" />
                <path d="M3 18h18" />
              </svg>
            </div>
          </div>
        </a>

        <!-- Asset: Digital multimeter icon -->
        <a id="btnCardAsset" runat="server" class="card card-asset" onserverclick="Card_ServerClick" data-type="Asset">
          <div class="card-row">
            <div>
              <div class="card-title">Asset</div>
              <div class="card-value"><asp:Literal ID="litCountAsset" runat="server" Text="--"/></div>
            </div>
            <div class="card-ico" aria-hidden="true">
              <svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false">
                <rect x="4" y="2" width="16" height="20" rx="2" />
                <circle cx="12" cy="8" r="2" />
                <path d="M8 14h8M8 17h8" />
                <path d="M10 12l4-2M10 12l4 2" />
              </svg>
            </div>
          </div>
        </a>

        <!-- Fixture: Safe box icon -->
        <a id="btnCardFixture" runat="server" class="card card-fixture" onserverclick="Card_ServerClick" data-type="Fixture">
          <div class="card-row">
            <div>
              <div class="card-title">Fixture</div>
              <div class="card-value"><asp:Literal ID="litCountFixture" runat="server" Text="--"/></div>
            </div>
            <div class="card-ico" aria-hidden="true">
              <svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false">
                <rect x="3" y="6" width="18" height="12" rx="3" />
                <path d="M7 10v4M12 8v8M17 11v2" />
                <circle cx="7" cy="15" r="1" />
                <path d="M9 2l2 4M13 2l2 4" />
              </svg>
            </div>
          </div>
        </a>

        <!-- Harness: Power plug icon -->
        <a id="btnCardHarness" runat="server" class="card card-harness" onserverclick="Card_ServerClick" data-type="Harness">
          <div class="card-row">
            <div>
              <div class="card-title">Harness</div>
              <div class="card-value"><asp:Literal ID="litCountHarness" runat="server" Text="--"/></div>
            </div>
            <div class="card-ico" aria-hidden="true">
              <svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false">
                <path d="M2 12h4l2-4 4 8 2-4h8" />
                <circle cx="7" cy="8" r="2" />
                <circle cx="17" cy="16" r="2" />
                <path d="M5 8L2 5M19 16l3 3" />
              </svg>
            </div>
          </div>
        </a>
      </div>

      <asp:HiddenField ID="hfType" runat="server" />
      <div class="table-toolbar">
        <div class="toolbar-left">
          <asp:TextBox ID="txtSearch" runat="server" CssClass="search-input" placeholder="Name, ID, Status, Location..." AutoPostBack="true" OnTextChanged="txtSearch_TextChanged" />
          <span style="opacity:.75; font-size:12px;">Sort by</span>
          <asp:DropDownList ID="ddlSort" runat="server" CssClass="ddl" AutoPostBack="true" OnSelectedIndexChanged="ddlSort_SelectedIndexChanged">
            <asp:ListItem Text="Name" Value="name" />
            <asp:ListItem Text="Location" Value="location" />
            <asp:ListItem Text="Status" Value="status" />
            <asp:ListItem Text="Eaton ID" Value="id" />
            <asp:ListItem Text="Next Calibration" Value="nextcal" />
            <asp:ListItem Text="Next PM" Value="nextpm" />
          </asp:DropDownList>
          <span style="opacity:.75; font-size:12px;">Status</span>
          <asp:DropDownList ID="ddlStatus" runat="server" CssClass="ddl" AutoPostBack="true" OnSelectedIndexChanged="ddlStatus_SelectedIndexChanged">
            <asp:ListItem Text="All" Value="all" />
            <asp:ListItem Text="Active" Value="active" />
            <asp:ListItem Text="Inactive" Value="inactive" />
          </asp:DropDownList>
          <span style="opacity:.75; font-size:12px;">Page size</span>
          <asp:DropDownList ID="ddlPageSize" runat="server" CssClass="ddl" AutoPostBack="true" OnSelectedIndexChanged="ddlPageSize_SelectedIndexChanged">
            <asp:ListItem Text="10" Value="10" />
            <asp:ListItem Text="25" Value="25" />
            <asp:ListItem Text="50" Value="50" />
            <asp:ListItem Text="100" Value="100" />
          </asp:DropDownList>
        </div>
        <div class="toolbar-right">
          <!-- Grid View Toggle Button (Purple/Violet) -->
          <button type="button" class="btn-icon btn-icon-accent" data-tooltip="Grid View" 
                  onclick="window.open('EquipmentGridView.aspx', '_blank'); return false;">
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
          <button type="button" class="btn-icon btn-icon-orange" data-tooltip="View Details" 
                  onclick="window.location='ItemDetails.aspx?type=' + (document.querySelector('.card.active')?.getAttribute('data-type') || 'ATE'); return false;">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round">
              <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
              <circle cx="12" cy="12" r="3"></circle>
            </svg>
          </button>
          
          <!-- Add New Equipment Button (Blue) -->
          <button type="button" class="btn-icon btn-icon-primary" data-tooltip="Add New Equipment" 
                  onclick="window.location='CreateNewItem.aspx?type=' + (document.querySelector('.card.active')?.getAttribute('data-type') || 'ATE'); return false;">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round">
              <line x1="12" y1="5" x2="12" y2="19"></line>
              <line x1="5" y1="12" x2="19" y2="12"></line>
            </svg>
          </button>
        </div>
      </div>
      <div class="table-wrap">
        <asp:GridView ID="gridEquip" runat="server" AutoGenerateColumns="false" CssClass="data-table" GridLines="None" CellPadding="0" 
          AllowPaging="true" PageSize="10" EnableViewState="true"
          DataKeyNames="KeyColumn" OnPageIndexChanging="gridEquip_PageIndexChanging" OnRowCommand="gridEquip_RowCommand" OnRowDataBound="gridEquip_RowDataBound">
          <PagerStyle CssClass="pager" HorizontalAlign="Center" />
          <PagerSettings Mode="NumericFirstLast" FirstPageText="First" LastPageText="Last" PageButtonCount="7" />
          <EmptyDataTemplate>
            <div style="padding:16px; text-align:center; font-size:13px; opacity:.8">No data found for this category.</div>
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
  </script>
</asp:Content>
