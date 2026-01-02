<%@ Page Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="ManageUsers.aspx.cs" Inherits="TED_Admin_ManageUsers" %>
<%@ Register Src="~/Admin/Controls/AdminHeader.ascx" TagPrefix="uc1" TagName="AdminHeader" %>
<%@ Register Src="~/Admin/Controls/AdminSidebar.ascx" TagPrefix="uc2" TagName="AdminSidebar" %>
<asp:Content ID="TitleC" ContentPlaceHolderID="TitleContent" runat="server">Users Manager - Admin</asp:Content>
<asp:Content ID="HeadC" ContentPlaceHolderID="HeadContent" runat="server">
  <style>
  /* Admin shell is defined in AdminSidebar control; ensure children shrink and column has bottom padding */
  .admin-grid > div { min-width: 0; min-height:0; }
  .admin-container { background:rgba(25,29,37,.46); border:1px solid rgba(255,255,255,.08); border-radius:16px; box-shadow:0 16px 34px -12px rgba(0,0,0,.6), 0 0 0 1px rgba(255,255,255,.05); backdrop-filter:blur(24px) saturate(140%); padding:16px; flex:1; min-height:0; overflow:hidden; display:flex; flex-direction:column; }
    html.theme-light .admin-container, html[data-theme='light'] .admin-container { background:#ffffff; border:1px solid rgba(0,0,0,.08); box-shadow:0 16px 34px -12px rgba(0,0,0,.16), 0 0 0 1px rgba(0,0,0,.05); }
  .toolbar { display:grid; grid-template-columns: 1fr repeat(6, auto); gap:10px; align-items:end; margin-bottom:12px; }
    .toolbar .field { display:flex; flex-direction:column; }
    .toolbar label { font-size:12px; opacity:.8; margin-bottom:4px; }
    .toolbar input[type=text], .toolbar select { padding:10px 12px; border-radius:10px; border:1px solid rgba(255,255,255,.14); background:rgba(0,0,0,.15); color:inherit; min-width:220px; font-family:inherit; font-size:13px; }
    html.theme-light .toolbar input[type=text], html.theme-light .toolbar select, html[data-theme='light'] .toolbar input[type=text], html[data-theme='light'] .toolbar select { background:#fff; border:1px solid rgba(0,0,0,.14); color:#1f242b; }
  /* Improve dropdown list (options) readability */
  .toolbar select option { background:#0f1b2e; color:#e9eef8; }
  .toolbar select option:hover { background:#16223a; color:#ffffff; }
  .toolbar select option:checked { background:#1e2b4a; color:#ffffff; }
  html.theme-light .toolbar select option, html[data-theme='light'] .toolbar select option { background:#ffffff; color:#1f2530; }
  html.theme-light .toolbar select option:hover, html[data-theme='light'] .toolbar select option:hover { background:#f3f7ff; color:#0b2960; }
  html.theme-light .toolbar select option:checked, html[data-theme='light'] .toolbar select option:checked { background:#e6f0ff; color:#0b2960; }
    .toolbar .btn-apply { padding:8px 12px; border-radius:10px; border:1px solid rgba(255,255,255,.14); background:linear-gradient(155deg,#0b2743,#0f365e); color:#e7f0ff; cursor:pointer; font-size:12px; transition:background .25s ease, box-shadow .25s ease, transform .2s ease, border-color .25s ease; }
    .toolbar .btn-apply:hover { background:linear-gradient(155deg,#0c3155,#11406f); border-color:rgba(77,141,255,.45); transform:translateY(-1px); box-shadow:0 8px 18px -10px rgba(0,0,0,.65), 0 0 0 1px rgba(77,141,255,.35); }
    html.theme-light .toolbar .btn-apply, html[data-theme='light'] .toolbar .btn-apply { background:#0b63ce; color:#ffffff; border:1px solid rgba(0,0,0,.10); }
    html.theme-light .toolbar .btn-apply:hover, html[data-theme='light'] .toolbar .btn-apply:hover { background:#0a58b8; box-shadow:0 10px 22px -10px rgba(0,0,0,.24); }
    /* Pagination buttons */
    .pagination-btn { padding:10px 18px; border-radius:10px; border:1px solid rgba(255,255,255,.14); background:linear-gradient(155deg,#0b2743,#0f365e); color:#e7f0ff; cursor:pointer; font-size:13px; font-weight:500; transition:all .25s ease; display:inline-flex; align-items:center; gap:8px; text-decoration:none; }
    .pagination-btn:hover:not(.disabled) { background:linear-gradient(155deg,#0c3155,#11406f); border-color:rgba(77,141,255,.45); transform:translateY(-1px); box-shadow:0 8px 18px -10px rgba(0,0,0,.65), 0 0 0 1px rgba(77,141,255,.35); }
    .pagination-btn.disabled { opacity:.4; cursor:not-allowed; pointer-events:none; }
    .pagination-btn svg { width:16px; height:16px; fill:currentColor; }
    html.theme-light .pagination-btn, html[data-theme='light'] .pagination-btn { background:#0b63ce; color:#ffffff; border:1px solid rgba(0,0,0,.10); }
    html.theme-light .pagination-btn:hover:not(.disabled), html[data-theme='light'] .pagination-btn:hover:not(.disabled) { background:#0a58b8; box-shadow:0 10px 22px -10px rgba(0,0,0,.24); }
    /* Make the toolbar wrap on smaller screens to avoid page-wide horizontal scroll */
  @media (max-width: 1600px) { .toolbar { grid-template-columns: 1fr repeat(3, auto); } }
  @media (max-width: 1200px) { .toolbar { grid-template-columns: 1fr 1fr; } }
    @media (max-width: 820px) { .toolbar { grid-template-columns: 1fr; } }
    /* Table styles to match Pending Requests */
  .table-wrap { width:100%; max-width:100%; overflow-x:auto; overflow-y:auto; max-height:calc(100vh - 320px); border-radius:12px; border:1px solid rgba(255,255,255,.08); background:rgba(25,29,37,.32); box-sizing:border-box; }
    html.theme-light .table-wrap, html[data-theme='light'] .table-wrap { background:#fff; border:1px solid rgba(0,0,0,.08); }
  table.data-table { width:100%; min-width:1580px; border-collapse:separate; border-spacing:0; font-size:11.5px; }
  @media (max-width: 1280px){ table.data-table{ min-width:1380px; } }
  /* Per-column min-widths for better readability */
  table.data-table th:nth-child(1), table.data-table td:nth-child(1) { min-width:80px; }
  table.data-table th:nth-child(2), table.data-table td:nth-child(2) { min-width:320px; }
  table.data-table th:nth-child(3), table.data-table td:nth-child(3) { min-width:150px; }
  table.data-table th:nth-child(4), table.data-table td:nth-child(4) { min-width:280px; }
  table.data-table th:nth-child(5), table.data-table td:nth-child(5) { min-width:200px; }
  table.data-table th:nth-child(6), table.data-table td:nth-child(6) { min-width:180px; }
  table.data-table th:nth-child(7), table.data-table td:nth-child(7) { min-width:180px; }
  table.data-table th:nth-child(8), table.data-table td:nth-child(8) { min-width:180px; }
  table.data-table th:nth-child(9), table.data-table td:nth-child(9) { min-width:130px; }
  table.data-table th:nth-child(10), table.data-table td:nth-child(10) { min-width:180px; }
  table.data-table th:nth-child(11), table.data-table td:nth-child(11) { min-width:200px; }
  table.data-table th:nth-child(12), table.data-table td:nth-child(12) { min-width:150px; }
  table.data-table th:nth-child(13), table.data-table td:nth-child(13) { min-width:120px; }
    table.data-table thead th,
    table.data-table th { position:sticky; top:0; z-index:1; background:#0b63ce !important; color:#ffffff !important; border-bottom:1px solid rgba(0,0,0,.12) !important; text-align:center; font-size:12px; padding:16px 12px !important; font-weight:800; letter-spacing:.25px; }
    html:not(.theme-light):not([data-theme='light']) table.data-table thead th,
    html:not(.theme-light):not([data-theme='light']) table.data-table th { background:linear-gradient(180deg,#0f1628,#0a1324) !important; color:#e9eef8 !important; border-bottom:1px solid rgba(255,255,255,.18) !important; }
    table.data-table thead th a,
    table.data-table th a,
    table.data-table thead th a:link,
    table.data-table th a:link,
    table.data-table thead th a:visited,
    table.data-table th a:visited { color: inherit !important; text-decoration: none !important; }
    table.data-table thead th a:hover,
    table.data-table th a:hover,
    table.data-table thead th a:focus,
    table.data-table th a:focus { text-decoration: underline !important; text-underline-offset: 2px; outline: none; }
    table.data-table tbody td { padding:14px 16px; border-bottom:1px solid rgba(255,255,255,.07); vertical-align:middle; text-align:center; }
    html.theme-light table.data-table tbody td, html[data-theme='light'] table.data-table tbody td { border-bottom:1px solid rgba(0,0,0,.06); }
    table.data-table tbody tr:nth-child(odd) { background:rgba(255,255,255,.015); }
    html.theme-light table.data-table tbody tr:nth-child(odd) { background:#fafbfe; }
    table.data-table tbody tr:hover { background:rgba(255,255,255,.04); }
    html.theme-light table.data-table tbody tr:hover, html[data-theme='light'] table.data-table tbody tr:hover { background:#fafcff; }
  .avatar-wrapper { position: relative; cursor: pointer; transition: transform 0.2s ease; }
  .avatar-wrapper:hover { transform: scale(1.05); }
  .avatar-wrapper:hover .avatar-edit-overlay { opacity: 1; }
  .avatar { width:44px; height:44px; min-width:44px; min-height:44px; border-radius:50%; object-fit:cover; border:none; background:transparent; display:block; }
  .avatar-fallback { width:44px; height:44px; min-width:44px; min-height:44px; border-radius:50%; display:flex; align-items:center; justify-content:center; font-weight:800; background:linear-gradient(135deg,#243b55,#141E30); color:#cfe6ff; border:none; }
  .avatar-edit-overlay { position: absolute; top: 0; left: 0; width: 44px; height: 44px; border-radius: 50%; background: rgba(0,0,0,.7); display: flex; align-items: center; justify-content: center; opacity: 0; transition: opacity 0.2s ease; }
  .avatar-edit-overlay svg { width: 16px; height: 16px; color: white; }
  html.theme-light .avatar, html[data-theme='light'] .avatar { background:#f1f4f7; }
  html.theme-light .avatar-fallback, html[data-theme='light'] .avatar-fallback { background:linear-gradient(135deg,#e3efff,#cfe3ff); color:#214a80; }
  .profile-cell { display:flex; align-items:center; gap:12px; justify-content:center; }
    .profile-name { font-weight:800; }
    .col-user-profile { text-align:center !important; }
    .col-user-profile .profile-cell { justify-content:center; }
    .tbl-actions { display:flex; gap:6px; justify-content:center; align-items:center; width:100%; }
    .icon-btn { width:32px; height:32px; display:inline-flex; align-items:center; justify-content:center; border-radius:8px; border:1px solid rgba(255,255,255,.18); background:rgba(255,255,255,.06); cursor:pointer; transition:background .2s ease, border-color .2s ease, transform .15s ease, box-shadow .2s ease; line-height:0; vertical-align:middle; }
    .icon-btn:hover { transform:translateY(-1px); box-shadow:0 8px 18px -10px rgba(0,0,0,.6); }
    .icon-btn svg { width:16px; height:16px; display:block; }
    .icon-btn.success { color:#b9f7c0; }
    .icon-btn.success:hover { background:rgba(30,180,90,.18); border-color:rgba(30,180,90,.35); color:#e2ffe6; }
    .icon-btn.danger { color:#ffb3b3; }
    .icon-btn.danger:hover { background:rgba(255,80,80,.18); border-color:rgba(255,80,80,.35); color:#ffd1d1; }
    /* Status badges */
    .badge { display:inline-flex; align-items:center; gap:6px; padding:6px 10px; border-radius:999px; font-size:12px; font-weight:700; border:1px solid rgba(255,255,255,.18); }
    .badge::before { content:""; width:8px; height:8px; border-radius:50%; display:inline-block; }
    .badge-active { background:rgba(64,180,120,.16); color:#b9f7c0; border-color:rgba(64,180,120,.35); }
    .badge-active::before { background:#2bb673; }
    .badge-inactive { background:rgba(255,80,80,.16); color:#ffb3b3; border-color:rgba(255,80,80,.35); }
    .badge-inactive::before { background:#ff5050; }
    html.theme-light .badge, html[data-theme='light'] .badge { border:1px solid rgba(0,0,0,.12); }
    html.theme-light .badge-active, html[data-theme='light'] .badge-active { background:#e8f5ed; color:#1e7f45; border-color:#b2e2c6; }
    html.theme-light .badge-inactive, html[data-theme='light'] .badge-inactive { background:#fdecec; color:#a32828; border-color:#f5b3b3; }
    /* Inline editor controls */
    .inline-input { width:100%; padding:8px 10px; border-radius:10px; border:1px solid rgba(255,255,255,.18); background:rgba(0,0,0,.12); color:inherit; font:inherit; font-size:13px; box-sizing:border-box; }
    .inline-select { width:100%; padding:8px 10px; border-radius:10px; border:1px solid rgba(255,255,255,.18); background:rgba(0,0,0,.12); color:inherit; font:inherit; font-size:13px; box-sizing:border-box; }
    .inline-multiselect { width:100%; height:34px; padding:4px 6px; border-radius:10px; border:1px solid rgba(255,255,255,.18); background:rgba(0,0,0,.12); color:inherit; font:inherit; font-size:13px; box-sizing:border-box; overflow-y:auto; appearance:none; -webkit-appearance:none; -moz-appearance:none; }
  /* Improve dropdown option readability in dark and light modes */
  .inline-select option { background:#0f1b2e; color:#e9eef8; }
  .inline-select option:hover { background:#16223a; color:#ffffff; }
  .inline-select option:checked { background:#1e2b4a; color:#ffffff; }
  html.theme-light .inline-select option, html[data-theme='light'] .inline-select option { background:#ffffff; color:#1f2530; }
  html.theme-light .inline-select option:hover, html[data-theme='light'] .inline-select option:hover { background:#f3f7ff; color:#0b2960; }
  html.theme-light .inline-select option:checked, html[data-theme='light'] .inline-select option:checked { background:#e6f0ff; color:#0b2960; }
  
  /* Multi-select dropdown styles */
  .multi-select-dropdown { position: relative; width: 100%; }
  .multi-select-button { width: 100%; padding: 8px 12px; border: 1px solid rgba(255,255,255,.14); border-radius: 10px; background: rgba(0,0,0,.15); text-align: left; cursor: pointer; font-size: 13px; display:flex; justify-content:space-between; align-items:center; min-height:34px; box-sizing:border-box; color:inherit; }
  html.theme-light .multi-select-button { background:#fff; border:1px solid rgba(0,0,0,.14); color:#1f242b; }
  .multi-select-button .multi-select-text { flex:1; overflow:hidden; white-space:nowrap; text-overflow:ellipsis; }
  .multi-select-arrow { margin-left: 8px; width: 0; height: 0; border-left: 5px solid transparent; border-right: 5px solid transparent; border-top: 6px solid currentColor; transform: rotate(0deg); transition: transform 0.2s ease; opacity: .7; }
  .multi-select-dropdown.open .multi-select-arrow { transform: rotate(180deg); }
  .multi-select-options { position:fixed !important; max-height:200px; overflow-y:auto; border:1px solid rgba(255,255,255,.14); border-radius:8px; background: rgba(15,23,42,.98); z-index:99999 !important; display:none; box-shadow:0 16px 48px -8px rgba(0,0,0,.6), 0 0 0 1px rgba(255,255,255,.05); backdrop-filter: blur(16px) saturate(140%); color:inherit; font-size:13px; min-width:160px; top: 0; left: 0; right: auto; bottom: auto; margin: 0; transform: none; }
  html.theme-light .multi-select-options { background:rgba(255,255,255,.98); border:1px solid rgba(0,0,0,.14); color:#1f242b; box-shadow: 0 16px 48px -8px rgba(0,0,0,.2), 0 0 0 1px rgba(0,0,0,.05); }
  .multi-select-options.show { display:block; }
  .multi-select-option { padding:8px 12px; cursor:pointer; display:flex; align-items:center; }
  .multi-select-option input[type="checkbox"] { margin-right:8px; }
    html.theme-light .inline-input, html[data-theme='light'] .inline-input, html.theme-light .inline-select, html[data-theme='light'] .inline-select, html.theme-light .inline-multiselect, html[data-theme='light'] .inline-multiselect { background:#fff; border:1px solid rgba(0,0,0,.14); color:#1f242b; }
    .inline-input[disabled], .inline-input[readonly] { opacity:.8; background:rgba(255,255,255,.06); cursor:not-allowed; }
    html.theme-light .inline-input[disabled], html.theme-light .inline-input[readonly], html[data-theme='light'] .inline-input[disabled], html[data-theme='light'] .inline-input[readonly] { background:#f5f7fb; color:#6b7480; }
    
    /* Modern Toggle Switch */
    .toggle-wrapper { display:inline-flex; align-items:center; justify-content:center; }
    .toggle-switch { position:relative; width:46px; height:26px; }
    .toggle-switch input[type="checkbox"] { opacity:0; width:0; height:0; position:absolute; }
    .toggle-slider { position:absolute; cursor:pointer; top:0; left:0; right:0; bottom:0; background:rgba(255,80,80,.25); border:1px solid rgba(255,80,80,.35); transition:all .3s ease; border-radius:26px; }
    .toggle-slider:before { position:absolute; content:""; height:18px; width:18px; left:3px; bottom:3px; background:#ffd1d1; transition:all .3s ease; border-radius:50%; box-shadow:0 2px 6px rgba(0,0,0,.3); }
    .toggle-switch input:checked + .toggle-slider { background:rgba(64,180,120,.25); border-color:rgba(64,180,120,.35); }
    .toggle-switch input:checked + .toggle-slider:before { transform:translateX(20px); background:#b9f7c0; }
    html.theme-light .toggle-slider, html[data-theme='light'] .toggle-slider { background:#f5b3b3; border-color:#f5b3b3; }
    html.theme-light .toggle-slider:before, html[data-theme='light'] .toggle-slider:before { background:#a32828; }
    html.theme-light .toggle-switch input:checked + .toggle-slider, html[data-theme='light'] .toggle-switch input:checked + .toggle-slider { background:#b2e2c6; border-color:#b2e2c6; }
    html.theme-light .toggle-switch input:checked + .toggle-slider:before, html[data-theme='light'] .toggle-switch input:checked + .toggle-slider:before { background:#1e7f45; }
    .save-btn { width:34px; height:34px; display:inline-flex; align-items:center; justify-content:center; border-radius:8px; border:1px solid rgba(255,255,255,.18); background:rgba(30,180,90,.18); color:#e2ffe6; cursor:pointer; }
    html.theme-light .save-btn, html[data-theme='light'] .save-btn { border:1px solid rgba(0,0,0,.12); background:#e8f5ed; color:#1e7f45; }
    .save-btn svg { width:16px; height:16px; display:block; }
    .delete-btn { width:34px; height:34px; display:inline-flex; align-items:center; justify-content:center; border-radius:8px; border:1px solid rgba(255,255,255,.18); background:rgba(255,80,80,.16); color:#ffd1d1; cursor:pointer; }
    html.theme-light .delete-btn, html[data-theme='light'] .delete-btn { border:1px solid rgba(0,0,0,.12); background:#fdecec; color:#a32828; }
    .delete-btn svg { width:16px; height:16px; display:block; }
  /* Row message (success/error) */
  .row-msg { display:inline-flex; align-items:center; gap:6px; margin-left:8px; padding:6px 10px; border-radius:999px; font-size:11px; font-weight:700; border:1px solid transparent; }
  .row-msg.success { background:rgba(64,180,120,.16); color:#b9f7c0; border-color:rgba(64,180,120,.35); }
  .row-msg.error { background:rgba(255,80,80,.16); color:#ffb3b3; border-color:rgba(255,80,80,.35); }
  html.theme-light .row-msg.success, html[data-theme='light'] .row-msg.success { background:#e8f5ed; color:#1e7f45; border-color:#b2e2c6; }
  html.theme-light .row-msg.error, html[data-theme='light'] .row-msg.error { background:#fdecec; color:#a32828; border-color:#f5b3b3; }
  /* Password visibility toggle */
  .password-wrap { position: relative; }
  .password-wrap .inline-input.has-toggle { padding-right: 38px; }
  .pw-toggle { position:absolute; right:8px; top:50%; transform:translateY(-50%); width:28px; height:28px; display:inline-flex; align-items:center; justify-content:center; border-radius:8px; border:1px solid rgba(255,255,255,.18); background:rgba(255,255,255,.06); color:#cfe6ff; cursor:pointer; line-height:0; }
  .pw-toggle:hover { background:rgba(255,255,255,.12); }
  .pw-toggle svg { width:16px; height:16px; display:block; }
  html.theme-light .pw-toggle, html[data-theme='light'] .pw-toggle { border:1px solid rgba(0,0,0,.12); background:#f3f6fb; color:#1f242b; }
  html.theme-light .pw-toggle:hover, html[data-theme='light'] .pw-toggle:hover { background:#e9eef7; }
  /* Global toast/banner */
  .global-toast { position:fixed; top:18px; left:50%; transform:translateX(-50%); z-index:9999; display:none; padding:10px 14px; border-radius:12px; font-weight:800; font-size:13px; border:1px solid rgba(255,255,255,.18); backdrop-filter:blur(10px) saturate(140%); box-shadow:0 14px 28px -12px rgba(0,0,0,.55), 0 0 0 1px rgba(255,255,255,.06); }
  .global-toast.success { background:rgba(25,29,37,.75); color:#c8f5d1; border-color:rgba(64,180,120,.35); }
  .global-toast.error { background:rgba(25,29,37,.75); color:#ffcccc; border-color:rgba(255,80,80,.35); }
  html.theme-light .global-toast, html[data-theme='light'] .global-toast { background:#ffffff; color:#1f242b; border:1px solid rgba(0,0,0,.12); }
  html.theme-light .global-toast.success, html[data-theme='light'] .global-toast.success { color:#1e7f45; border-color:#b2e2c6; }
  html.theme-light .global-toast.error, html[data-theme='light'] .global-toast.error { color:#a32828; border-color:#f5b3b3; }
  
  /* Photo Upload Modal */
  .photo-modal-overlay { position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,.75); backdrop-filter: blur(8px); z-index: 99999; display: none; align-items: center; justify-content: center; animation: fadeIn 0.2s ease; }
  .photo-modal-overlay.show { display: flex; }
  
  .photo-modal { background: rgba(25,29,37,.98); border: 1px solid rgba(255,255,255,.12); border-radius: 16px; padding: 24px; max-width: 480px; width: 90%; max-height: 90vh; overflow-y: auto; box-shadow: 0 24px 64px -12px rgba(0,0,0,.8); animation: slideUp 0.3s ease; box-sizing: border-box; }
  html.theme-light .photo-modal, html[data-theme='light'] .photo-modal { background: #ffffff; border: 1px solid rgba(0,0,0,.12); }
  
  .photo-modal-header { margin-bottom: 20px; }
  .photo-modal-title { font-size: 20px; font-weight: 800; margin: 0 0 6px; }
  .photo-modal-subtitle { font-size: 13px; opacity: 0.7; margin: 0; }
  
  .photo-modal-body { margin-bottom: 20px; overflow: hidden; }
  
  .photo-modal-actions { display: flex; gap: 8px; justify-content: flex-end; flex-wrap: wrap; }
  
  .photo-file-wrapper { 
    position: relative; 
    width: 100%; 
    display: flex; 
    justify-content: center; 
    align-items: center;
    padding: 16px 12px;
    background: rgba(0,0,0,.08);
    border: 2px dashed rgba(77,141,255,.35);
    border-radius: 10px;
    transition: all 0.2s ease;
    overflow: hidden;
    box-sizing: border-box;
  }
  .photo-file-wrapper:hover {
    background: rgba(0,0,0,.12);
    border-color: rgba(77,141,255,.6);
  }
  .photo-file-wrapper input[type=file] { 
    width: 100%;
    max-width: 100%;
    font-family: inherit; 
    font-size: 14px;
    cursor: pointer;
    color: inherit;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
    box-sizing: border-box;
  }
  .photo-file-wrapper input[type=file]::file-selector-button {
    padding: 8px 16px;
    background: rgba(77,141,255,.2);
    border: 1px solid rgba(77,141,255,.4);
    border-radius: 8px;
    color: inherit;
    font-weight: 600;
    cursor: pointer;
    margin-right: 12px;
    transition: all 0.2s ease;
  }
  .photo-file-wrapper input[type=file]::file-selector-button:hover {
    background: rgba(77,141,255,.3);
    border-color: rgba(77,141,255,.6);
  }
  html.theme-light .photo-file-wrapper, 
  html[data-theme='light'] .photo-file-wrapper { 
    background: #f8fbff; 
    border-color: rgba(0,99,206,.35); 
  }
  html.theme-light .photo-file-wrapper:hover, 
  html[data-theme='light'] .photo-file-wrapper:hover { 
    background: #f0f7ff; 
    border-color: rgba(0,99,206,.6); 
  }
  html.theme-light .photo-file-wrapper input[type=file]::file-selector-button, 
  html[data-theme='light'] .photo-file-wrapper input[type=file]::file-selector-button { 
    background: rgba(0,99,206,.15);
    border-color: rgba(0,99,206,.4);
    color: #0063ce;
  }
  html.theme-light .photo-file-wrapper input[type=file]::file-selector-button:hover, 
  html[data-theme='light'] .photo-file-wrapper input[type=file]::file-selector-button:hover { 
    background: rgba(0,99,206,.25);
    border-color: rgba(0,99,206,.6);
  }
  
  .photo-btn { padding: 10px 18px; border-radius: 10px; font-weight: 700; font-size: 13px; border: none; cursor: pointer; transition: all 0.2s ease; display: inline-flex; align-items: center; gap: 6px; }
  .photo-btn-primary { background: linear-gradient(135deg, #4d8dff, #0063ce); color: white; box-shadow: 0 4px 12px -2px rgba(77,141,255,.4); }
  .photo-btn-primary:hover { transform: translateY(-2px); box-shadow: 0 8px 20px -4px rgba(77,141,255,.5); }
  .photo-btn-primary:disabled { opacity: 0.5; cursor: not-allowed; transform: none; }
  .photo-btn-secondary { background: rgba(255,255,255,.06); border: 1px solid rgba(255,255,255,.18); color: inherit; }
  .photo-btn-secondary:hover { background: rgba(255,255,255,.12); border-color: rgba(255,255,255,.25); }
  html.theme-light .photo-btn-secondary, html[data-theme='light'] .photo-btn-secondary { background: #ffffff; border: 1px solid rgba(0,0,0,.12); }
  html.theme-light .photo-btn-secondary:hover, html[data-theme='light'] .photo-btn-secondary:hover { background: #f8fbff; border-color: rgba(0,0,0,.2); }
  
  .photo-btn-danger { background: linear-gradient(135deg, #ff6b6b, #ee5a52); color: white; box-shadow: 0 4px 12px -2px rgba(255,107,107,.4); }
  .photo-btn-danger:hover { transform: translateY(-2px); box-shadow: 0 8px 20px -4px rgba(255,107,107,.5); }
  .photo-btn-danger:disabled { opacity: 0.5; cursor: not-allowed; transform: none; }
  
  @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
  @keyframes slideUp { from { transform: translateY(20px); opacity: 0; } to { transform: translateY(0); opacity: 1; } }
  </style>
  <script type="text/javascript">
    (function() {
      function showInitials(container){ if(!container) return; var img = container.querySelector('img.avatar'); var pnl = container.querySelector('.avatar-fallback'); if(img) img.style.display = 'none'; if(pnl) pnl.style.display = 'flex'; }
      function showImage(container){ if(!container) return; var img = container.querySelector('img.avatar'); var pnl = container.querySelector('.avatar-fallback'); if(pnl) pnl.style.display = 'none'; if(img) img.style.display = 'block'; }
      function wireAvatar(el){ if(!el) return; var img = el.querySelector('img.avatar'); if(!img){ showInitials(el); return; } if(img.complete){ if(img.naturalWidth && img.naturalHeight){ showImage(el);} else { showInitials(el);} } else { img.addEventListener('load', function(){ if(img.naturalWidth && img.naturalHeight){ showImage(el);} else { showInitials(el);} }); img.addEventListener('error', function(){ showInitials(el); }); } }
      function init(){ var rows = document.querySelectorAll('table.data-table tr'); for(var i=0;i<rows.length;i++){ var containers = rows[i].querySelectorAll('td .avatar, td .avatar-fallback'); for(var j=0;j<containers.length;j++){ var parent = containers[j].parentElement; if(parent) wireAvatar(parent); } } }
      if(document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init); else init();
    })();
  </script>
  <script type="text/javascript">
    window.showToast = function(message, type){
      try {
        var el = document.getElementById('globalToast');
        if(!el){
          el = document.createElement('div');
          el.id = 'globalToast';
          el.className = 'global-toast';
          document.body.appendChild(el);
        }
        el.textContent = message || '';
        el.className = 'global-toast ' + (type || 'success');
        el.style.display = 'block';
        el.style.opacity = '1';
        clearTimeout(window.__toastTimer);
        window.__toastTimer = setTimeout(function(){
          el.style.transition = 'opacity .35s ease';
          el.style.opacity = '0';
          setTimeout(function(){ el.style.display = 'none'; el.style.transition = ''; }, 380);
        }, 2000);
      } catch(e){}
    };
  </script>
  <script type="text/javascript">
  function togglePw(btn){
      try {
        var wrap = btn && btn.closest ? btn.closest('.password-wrap') : null;
        if(!wrap && btn && btn.parentNode){ wrap = btn.parentNode; }
        var input = wrap ? wrap.querySelector('input[type="password"], input[type="text"]') : null;
        if(!input) return false;
        if(input.type === 'password'){
          input.type = 'text';
          btn.setAttribute('aria-pressed','true');
          var off = btn.querySelector('[data-eye-off]'); var on = btn.querySelector('[data-eye-on]');
          if(off && on){ off.style.display='none'; on.style.display='block'; }
        } else {
          input.type = 'password';
          btn.setAttribute('aria-pressed','false');
          var off2 = btn.querySelector('[data-eye-off]'); var on2 = btn.querySelector('[data-eye-on]');
          if(off2 && on2){ off2.style.display='block'; on2.style.display='none'; }
        }
      } catch(e){}
      return false;
    }
  </script>
  <script type="text/javascript">
    // Debounced search postback for immediate filtering while typing
    (function(){
      var t=null;
      window.debouncedFilter = function(){
        if(t) window.clearTimeout(t);
        t = window.setTimeout(function(){
          try { __doPostBack('<%= txtSearch.UniqueID %>',''); } catch(e){}
        }, 400);
      };
    })();

    // Multi-select dropdown functions
    function updateMultiSelectButton(buttonId, optionsId) {
      var button = document.getElementById(buttonId);
      var options = document.getElementById(optionsId);
      if (!button || !options) return;
      var checkboxes = options.querySelectorAll('input[type="checkbox"]:checked');
      var buttonText = button.querySelector('.multi-select-text');
      if (!buttonText) return;
      if (checkboxes.length === 0) buttonText.textContent = '';
      else if (checkboxes.length === 1) {
        var label = checkboxes[0].getAttribute('data-label') || checkboxes[0].getAttribute('aria-label') || checkboxes[0].parentNode.textContent.replace(/^\s+/, '').trim();
        buttonText.textContent = label;
      } else { buttonText.textContent = checkboxes.length + ' items selected'; }
    }

    function initializeMultiSelect(buttonId, optionsId) {
      var button = document.getElementById(buttonId);
      var options = document.getElementById(optionsId);
      var dropdown = button ? button.closest('.multi-select-dropdown') : null;
      if (!button || !options || !dropdown) return;
      if (dropdown.getAttribute('data-ms-init') === '1') return;
      dropdown.setAttribute('data-ms-init', '1');
      
      // Move options to body to escape parent positioning contexts
      if (options.parentElement !== document.body) {
        options.setAttribute('data-button-id', buttonId);
        document.body.appendChild(options);
      }
      
      function openClose(toggle) {
        if (toggle) {
          // Position the dropdown
          var buttonRect = button.getBoundingClientRect();
          var viewportHeight = window.innerHeight || document.documentElement.clientHeight;
          var viewportWidth = window.innerWidth || document.documentElement.clientWidth;
          var dropdownHeight = 200;
          
          var spaceBelow = viewportHeight - buttonRect.bottom;
          var spaceAbove = buttonRect.top;
          
          var top, left;
          if (spaceBelow >= 100 || spaceBelow >= spaceAbove) {
            top = buttonRect.bottom + 4;
          } else {
            top = buttonRect.top - Math.min(dropdownHeight, spaceAbove - 10) - 4;
          }
          
          left = buttonRect.left;
          var dropdownWidth = buttonRect.width;
          
          if (left + dropdownWidth > viewportWidth - 10) {
            left = viewportWidth - dropdownWidth - 10;
          }
          if (left < 10) {
            left = 10;
          }
          
          options.style.top = Math.round(top) + 'px';
          options.style.left = Math.round(left) + 'px';
          options.style.width = Math.round(dropdownWidth) + 'px';
          
          options.classList.add('show');
          dropdown.classList.add('open');
          button.setAttribute('aria-expanded', 'true');
        } else {
          options.classList.remove('show');
          dropdown.classList.remove('open');
          button.setAttribute('aria-expanded', 'false');
        }
      }
      
      button.addEventListener('click', function(e){ e.preventDefault(); var isOpen = options.classList.contains('show'); closeAllMultiSelects(); openClose(!isOpen); });
      button.addEventListener('keydown', function(e){ if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); button.click(); } else if (e.key === 'Escape') { openClose(false); } });
      var optionRows = options.querySelectorAll('.multi-select-option');
      optionRows.forEach(function(row){ row.addEventListener('click', function(e){ if (e.target && e.target.tagName && e.target.tagName.toLowerCase() === 'input') return; var cb = row.querySelector('input[type="checkbox"]'); if (!cb) return; cb.checked = !cb.checked; cb.dispatchEvent(new Event('change', { bubbles: true })); }); });
      var checkboxes = options.querySelectorAll('input[type="checkbox"]');
      checkboxes.forEach(function(checkbox){ checkbox.addEventListener('change', function(){ updateMultiSelectButton(buttonId, optionsId); }); });
      updateMultiSelectButton(buttonId, optionsId);
    }

    function initializeAllMultiSelects() {
      var multiSelects = document.querySelectorAll('.multi-select-dropdown');
      multiSelects.forEach(function(dropdown){ var buttonEl = dropdown.querySelector('.multi-select-button'); var optionsEl = dropdown.querySelector('.multi-select-options'); if (buttonEl && optionsEl) { initializeMultiSelect(buttonEl.id, optionsEl.id); } });
    }

    function closeAllMultiSelects(except) {
      var openDropdowns = document.querySelectorAll('.multi-select-dropdown.open');
      openDropdowns.forEach(function(dd){ if (except && dd === except) return; dd.classList.remove('open'); var opts = dd.querySelector('.multi-select-options'); if (opts) opts.classList.remove('show'); var btn = dd.querySelector('.multi-select-button'); if (btn) btn.setAttribute('aria-expanded', 'false'); });
    }

    document.addEventListener('click', function(e) {
      var openDds = document.querySelectorAll('.multi-select-dropdown.open');
      openDds.forEach(function(dd){ if (!dd.contains(e.target)) { dd.classList.remove('open'); var opts = dd.querySelector('.multi-select-options'); if (opts) opts.classList.remove('show'); var btn = dd.querySelector('.multi-select-button'); if (btn) btn.setAttribute('aria-expanded', 'false'); } });
    });

    document.addEventListener('keydown', function(e){ if (e.key === 'Escape') closeAllMultiSelects(); });
    
    // Close dropdowns on window resize or scroll
    window.addEventListener('resize', function() {
      closeAllMultiSelects();
    });
    
    window.addEventListener('scroll', function() {
      closeAllMultiSelects();
    });

    // Populate multi-select dropdowns with production lines
    function populateTestLineDropdowns() {
      // Get production lines data (you'll need to pass this from server)
      var productionLines = window.productionLinesData || [];
      
      var rows = document.querySelectorAll('table.data-table tbody tr[data-userid]');
      rows.forEach(function(row) {
        var userId = row.getAttribute('data-userid');
        var testLines = row.getAttribute('data-testlines') || '';
        var selectedIds = testLines ? testLines.split(',').map(function(id) { return id.trim(); }) : [];
        
        var optionsContainer = row.querySelector('#msTestLine_' + userId + '_options');
        if (optionsContainer) {
          optionsContainer.innerHTML = '';
          
          productionLines.forEach(function(line) {
            var isChecked = selectedIds.indexOf(line.id) > -1;
            var optionDiv = document.createElement('div');
            optionDiv.className = 'multi-select-option';
            
            var checkbox = document.createElement('input');
            checkbox.type = 'checkbox';
            checkbox.id = 'msTestLine_' + userId + '_' + line.id;
            checkbox.name = 'msTestLine_' + userId + '_' + line.id;
            checkbox.value = line.id;
            checkbox.setAttribute('data-label', line.name);
            checkbox.checked = isChecked;
            
            var label = document.createElement('span');
            label.className = 'multi-select-option-label';
            label.textContent = line.name;
            
            optionDiv.appendChild(checkbox);
            optionDiv.appendChild(label);
            optionsContainer.appendChild(optionDiv);
          });
        }
      });
    }

    document.addEventListener('DOMContentLoaded', function(){ 
      populateTestLineDropdowns();
      initializeAllMultiSelects(); 
    });
    
    // Intercept Save button clicks to copy checkbox values to hidden inputs
    document.addEventListener('click', function(e) {
      var saveBtn = e.target.closest('.save-btn');
      if (saveBtn) {
        // Find the row
        var row = saveBtn.closest('tr');
        if (row) {
          var userId = row.getAttribute('data-userid');
          if (userId) {
            // Remove any existing hidden inputs for this user
            var existingHiddens = document.querySelectorAll('input[name^="msTestLine_' + userId + '_"]');
            existingHiddens.forEach(function(input) {
              if (input.type === 'hidden') input.remove();
            });
            
            // Find all checked checkboxes for this user
            var checkboxes = document.querySelectorAll('input[type="checkbox"][id^="msTestLine_' + userId + '_"]:checked');
            checkboxes.forEach(function(checkbox) {
              // Create a hidden input with the same name
              var hidden = document.createElement('input');
              hidden.type = 'hidden';
              hidden.name = checkbox.name;
              hidden.value = checkbox.value;
              row.appendChild(hidden);
            });
          }
        }
      }
    });
    
    // Re-initialize after postback
    if (typeof(Sys) !== 'undefined') { 
      Sys.WebForms.PageRequestManager.getInstance().add_endRequest(function(){ 
        setTimeout(function() {
          populateTestLineDropdowns();
          initializeAllMultiSelects();
        }, 100); 
      }); 
    }
  </script>
</asp:Content>
<asp:Content ID="MainC" ContentPlaceHolderID="MainContent" runat="server">
  <div class="admin-grid">
    <uc2:AdminSidebar ID="AdminSidebar1" runat="server" />
    <div class="admin-container">
      <uc1:AdminHeader ID="AdminHeader1" runat="server" Title="Users Manager" />
      <div id="globalToast" class="global-toast" style="display:none"></div>

    <div class="toolbar">
      <div class="field">
        <label>Search</label>
        <asp:TextBox ID="txtSearch" runat="server" placeholder="Name, E-Number, Email, Department, Role" AutoPostBack="True" OnTextChanged="txtSearch_TextChanged" oninput="debouncedFilter()" />
      </div>
      <div class="field">
        <label>Sort by</label>
        <asp:DropDownList ID="ddlSort" runat="server" AutoPostBack="True" OnSelectedIndexChanged="ddlSort_SelectedIndexChanged">
          <asp:ListItem Value="IDDesc">ID (Newest)</asp:ListItem>
          <asp:ListItem Value="IDAsc">ID (Oldest)</asp:ListItem>
          <asp:ListItem Value="Name">Name</asp:ListItem>
          <asp:ListItem Value="ENumber">E-Number</asp:ListItem>
          <asp:ListItem Value="Department">Department</asp:ListItem>
        </asp:DropDownList>
      </div>
      <div class="field">
        <label>Department</label>
        <asp:DropDownList ID="ddlDepartmentFilter" runat="server" AutoPostBack="True" OnSelectedIndexChanged="ddlDepartmentFilter_SelectedIndexChanged">
          <asp:ListItem Selected="True" Value="">All</asp:ListItem>
        </asp:DropDownList>
      </div>
      <div class="field">
        <label>Job Role</label>
        <asp:DropDownList ID="ddlJobRoleFilter" runat="server" AutoPostBack="True" OnSelectedIndexChanged="ddlJobRoleFilter_SelectedIndexChanged">
          <asp:ListItem Selected="True" Value="">All</asp:ListItem>
        </asp:DropDownList>
      </div>
      <div class="field">
        <label>User Category</label>
        <asp:DropDownList ID="ddlUserCategoryFilter" runat="server" AutoPostBack="True" OnSelectedIndexChanged="ddlUserCategoryFilter_SelectedIndexChanged">
          <asp:ListItem Selected="True" Value="">All</asp:ListItem>
        </asp:DropDownList>
      </div>
      <div class="field">
        <label>Status</label>
        <asp:DropDownList ID="ddlStatus" runat="server" AutoPostBack="True" OnSelectedIndexChanged="ddlStatus_SelectedIndexChanged">
          <asp:ListItem Selected="True">All</asp:ListItem>
          <asp:ListItem>Active</asp:ListItem>
          <asp:ListItem>Inactive</asp:ListItem>
        </asp:DropDownList>
      </div>
      <div class="field">
        <label>Page size</label>
        <asp:DropDownList ID="ddlPageSize" runat="server" AutoPostBack="True" OnSelectedIndexChanged="ddlPageSize_SelectedIndexChanged">
          <asp:ListItem Selected="True">10</asp:ListItem>
          <asp:ListItem>20</asp:ListItem>
          <asp:ListItem>50</asp:ListItem>
        </asp:DropDownList>
      </div>
    </div>
    <div class="table-wrap">
      <asp:GridView ID="gridUsers" runat="server" AutoGenerateColumns="False" CssClass="data-table" GridLines="None" CellPadding="0" OnRowDataBound="gridUsers_RowDataBound" OnRowCommand="gridUsers_RowCommand" DataKeyNames="UserID">
        <Columns>
          <asp:TemplateField HeaderText="ID">
            <HeaderStyle HorizontalAlign="Center" />
            <ItemStyle HorizontalAlign="Center" />
            <ItemTemplate>
              <asp:TextBox ID="txtUserIDRow" runat="server" CssClass="inline-input" Text='<%# Eval("UserID") %>' ReadOnly="true" Enabled="false" style="text-align:center;" />
            </ItemTemplate>
          </asp:TemplateField>
          <asp:TemplateField HeaderText="User Profile">
            <HeaderStyle CssClass="col-user-profile" HorizontalAlign="Center" />
            <ItemStyle CssClass="col-user-profile" />
            <ItemTemplate>
              <div class="profile-cell">
                <div class="avatar-wrapper" data-userid="<%# System.Web.HttpUtility.HtmlAttributeEncode(Eval("UserID").ToString()) %>" data-username="<%# System.Web.HttpUtility.HtmlAttributeEncode(Eval("FullName").ToString()) %>">
                  <asp:Image ID="imgAvatar" runat="server" CssClass="avatar" AlternateText="avatar" ImageUrl='<%# Eval("ProfileThumbUrl") %>' Style="display:none;" />
                  <asp:Panel ID="pnlInitials" runat="server" CssClass="avatar-fallback" Style="display:flex;">
                    <asp:Literal ID="litInitials" runat="server" />
                  </asp:Panel>
                  <div class="avatar-edit-overlay">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                      <path d="M12 20h9"></path>
                      <path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"></path>
                    </svg>
                  </div>
                </div>
                <asp:TextBox ID="txtFullNameRow" runat="server" CssClass="inline-input" Text='<%# Eval("FullName") %>' />
              </div>
            </ItemTemplate>
          </asp:TemplateField>
          <asp:TemplateField HeaderText="E Number">
            <ItemTemplate>
              <asp:TextBox ID="txtENumberRow" runat="server" CssClass="inline-input" Text='<%# Eval("ENumber") %>' ReadOnly="true" Enabled="false" />
            </ItemTemplate>
          </asp:TemplateField>
          <asp:TemplateField HeaderText="Email">
            <ItemTemplate>
              <asp:TextBox ID="txtEmailRow" runat="server" CssClass="inline-input" Text='<%# Eval("Email") %>' />
            </ItemTemplate>
          </asp:TemplateField>
          <asp:TemplateField HeaderText="Password">
            <ItemTemplate>
              <div class="password-wrap">
                <asp:TextBox ID="txtPasswordRow" runat="server" CssClass="inline-input has-toggle" TextMode="Password" />
                <button type="button" class="pw-toggle" aria-label="Toggle password visibility" aria-pressed="false" onclick="return togglePw(this)">
                  <span aria-hidden="true" data-eye-on style="display:none">
                    <!-- Eye icon -->
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                  </span>
                  <span aria-hidden="true" data-eye-off style="display:block">
                    <!-- Eye-off icon -->
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17.94 17.94A10.94 10.94 0 0 1 12 20c-7 0-11-8-11-8a20.12 20.12 0 0 1 5.06-6.94"/><path d="M1 1l22 22"/><path d="M9.9 4.24A10.94 10.94 0 0 1 12 4c7 0 11 8 11 8a20.12 20.12 0 0 1-3.87 5.17"/><path d="M14.12 14.12A3 3 0 0 1 9.88 9.88"/></svg>
                  </span>
                </button>
              </div>
            </ItemTemplate>
          </asp:TemplateField>
          <asp:TemplateField HeaderText="Department">
            <ItemTemplate>
              <asp:DropDownList ID="ddlDepartmentRow" runat="server" CssClass="inline-select">
              </asp:DropDownList>
            </ItemTemplate>
          </asp:TemplateField>
          <asp:TemplateField HeaderText="Job Role">
            <ItemTemplate>
              <asp:DropDownList ID="ddlJobRoleRow" runat="server" CssClass="inline-select">
              </asp:DropDownList>
            </ItemTemplate>
          </asp:TemplateField>
          <asp:TemplateField HeaderText="User Category">
            <ItemTemplate>
              <asp:DropDownList ID="ddlCategoryRow" runat="server" CssClass="inline-select">
              </asp:DropDownList>
            </ItemTemplate>
          </asp:TemplateField>
          <asp:TemplateField HeaderText="Status">
            <ItemTemplate>
              <div class="toggle-wrapper">
                <label class="toggle-switch">
                  <asp:CheckBox ID="chkStatusRow" runat="server" />
                  <span class="toggle-slider"></span>
                </label>
              </div>
            </ItemTemplate>
          </asp:TemplateField>
          <asp:TemplateField HeaderText="Test Line">
            <ItemTemplate>
              <div class="multi-select-dropdown">
                <div class="multi-select-button" id='<%# "msTestLine_" + Eval("UserID") + "_button" %>'>
                  <span class="multi-select-text"></span>
                  <span class="multi-select-arrow"></span>
                </div>
                <div class="multi-select-options" id='<%# "msTestLine_" + Eval("UserID") + "_options" %>'></div>
              </div>
            </ItemTemplate>
          </asp:TemplateField>
          <asp:TemplateField HeaderText="Modified">
            <ItemTemplate>
              <asp:TextBox ID="txtModifiedRow" runat="server" CssClass="inline-input" Text='<%# Eval("ModifiedAt", "{0:yyyy-MM-dd HH:mm}") %>' ReadOnly="true" Enabled="false" />
            </ItemTemplate>
          </asp:TemplateField>
          <asp:TemplateField HeaderText="Modified By">
            <ItemTemplate>
              <asp:TextBox ID="txtModifiedByRow" runat="server" CssClass="inline-input" Text='<%# Eval("ModifiedBy") %>' ReadOnly="true" Enabled="false" />
            </ItemTemplate>
          </asp:TemplateField>
          <asp:TemplateField HeaderText="Actions">
            <ItemTemplate>
              <div class="tbl-actions">
                <asp:LinkButton ID="btnSave" runat="server" CssClass="save-btn" CommandName="Save" CommandArgument='<%# Eval("UserID") %>' ToolTip="Save changes">
                  <span aria-hidden="true">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/><polyline points="17 21 17 13 7 13 7 21"/><polyline points="7 3 7 8 15 8"/></svg>
                  </span>
                </asp:LinkButton>
                <asp:LinkButton ID="btnDelete" runat="server" CssClass="delete-btn" CommandName="RemoveUser" CommandArgument='<%# Eval("UserID") %>' ToolTip="Delete user" OnClientClick="return confirm('Delete this user?');">
                  <span aria-hidden="true">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6" /><path d="M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6"/><path d="M10 11v6"/><path d="M14 11v6"/><path d="M9 6V4a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v2"/></svg>
                  </span>
                </asp:LinkButton>
                <asp:Label ID="lblRowMsg" runat="server" CssClass="row-msg" Visible="false" />
              </div>
            </ItemTemplate>
          </asp:TemplateField>
        </Columns>
      </asp:GridView>
    </div>

    <div style="margin-top:14px; display:flex; justify-content:space-between; align-items:center;">
      <div style="font-size:12px; opacity:.8;">
        <asp:Label ID="lblPagination" runat="server" />
      </div>
      <div style="display:flex; gap:10px;">
        <asp:LinkButton ID="btnPrev" runat="server" CssClass="pagination-btn" OnClick="btnPrev_Click">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M15.41 7.41L14 6l-6 6 6 6 1.41-1.41L10.83 12z"/></svg>
          Previous
        </asp:LinkButton>
        <asp:LinkButton ID="btnNext" runat="server" CssClass="pagination-btn" OnClick="btnNext_Click">
          Next
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M10 6L8.59 7.41 13.17 12l-4.58 4.59L10 18l6-6z"/></svg>
        </asp:LinkButton>
      </div>
    </div>
  </div>
  </div>
  
  <!-- Photo Upload Modal -->
  <div class="photo-modal-overlay" id="photoModal">
    <div class="photo-modal">
      <div class="photo-modal-header">
        <h3 class="photo-modal-title">Change Profile Picture</h3>
        <p class="photo-modal-subtitle" id="photoModalSubtitle">Upload a new profile picture (JPG, PNG, max 5MB)</p>
      </div>
      <div class="photo-modal-body">
        <div class="photo-file-wrapper">
          <asp:FileUpload ID="fileUserPhoto" runat="server" accept="image/*" onchange="previewPhoto(this)" />
        </div>
        <div id="photoPreview" style="margin-top: 16px; display: none;">
          <img id="photoPreviewImg" style="max-width: 100%; border-radius: 12px; border: 1px solid rgba(255,255,255,.12);" alt="Preview" />
        </div>
      </div>
      <div class="photo-modal-actions">
        <button type="button" class="photo-btn photo-btn-secondary" onclick="closePhotoModal()">Cancel</button>
        <asp:Button ID="btnRemoveUserPhoto" runat="server" Text="Remove Picture" CssClass="photo-btn photo-btn-danger" OnClick="btnRemoveUserPhoto_Click" />
        <asp:Button ID="btnUploadUserPhoto" runat="server" Text="Upload Photo" CssClass="photo-btn photo-btn-primary" OnClick="btnUploadUserPhoto_Click" />
      </div>
    </div>
  </div>
  
  <asp:HiddenField ID="hdnSelectedUserId" runat="server" />
  
  <script type="text/javascript">
    // Global variables and functions
    var currentUserId = null;
    
    function openPhotoModal(userId, userName) {
      try {
        currentUserId = userId;
        var hdnField = document.getElementById('<%= hdnSelectedUserId.ClientID %>');
        var subtitle = document.getElementById('photoModalSubtitle');
        var modal = document.getElementById('photoModal');
        var preview = document.getElementById('photoPreview');
        var previewImg = document.getElementById('photoPreviewImg');
        
        if (hdnField) hdnField.value = userId;
        if (subtitle) subtitle.textContent = 'Upload a new profile picture for ' + userName + ' (JPG, PNG, max 5MB)';
        
        // Find the current user's avatar image in the table
        var avatarWrapper = document.querySelector('.avatar-wrapper[data-userid="' + userId + '"]');
        var currentAvatar = null;
        var hasCurrentPicture = false;
        if (avatarWrapper) {
          currentAvatar = avatarWrapper.querySelector('img.avatar');
        }
        
        // Show current profile picture if it exists and show/hide remove button
        var removeBtn = document.getElementById('<%= btnRemoveUserPhoto.ClientID %>');
        if (currentAvatar && currentAvatar.src && currentAvatar.style.display !== 'none') {
          if (previewImg) previewImg.src = currentAvatar.src;
          if (preview) preview.style.display = 'block';
          hasCurrentPicture = true;
        } else {
          if (preview) preview.style.display = 'none';
          hasCurrentPicture = false;
        }
        
        // Show/hide remove button based on whether user has a current picture
        if (removeBtn) {
          removeBtn.style.display = hasCurrentPicture ? 'inline-flex' : 'none';
        }
        
        if (modal) {
          modal.style.display = ''; // Clear any inline display:none
          modal.classList.add('show');
        }
      } catch(err) {
        console.error('Error opening photo modal:', err);
      }
    }
    
    function closePhotoModal() {
      try {
        var modal = document.getElementById('photoModal');
        var preview = document.getElementById('photoPreview');
        var hdnField = document.getElementById('<%= hdnSelectedUserId.ClientID %>');
        
        if (modal) {
          modal.classList.remove('show');
          modal.style.display = 'none'; // Force hide the modal
        }
        if (preview) preview.style.display = 'none';
        if (hdnField) hdnField.value = '';
        currentUserId = null;
      } catch(err) {
        console.error('Error closing photo modal:', err);
      }
    }
    
    function previewPhoto(input) {
      try {
        if (input.files && input.files[0]) {
          var reader = new FileReader();
          reader.onload = function(e) {
            var img = document.getElementById('photoPreviewImg');
            var preview = document.getElementById('photoPreview');
            if (img) img.src = e.target.result;
            if (preview) preview.style.display = 'block';
          };
          reader.readAsDataURL(input.files[0]);
        }
      } catch(err) {
        console.error('Error previewing photo:', err);
      }
    }
    
    function attachAvatarClickHandlers() {
      var avatarWrappers = document.querySelectorAll('.avatar-wrapper');
      avatarWrappers.forEach(function(wrapper) {
        // Remove any existing listeners
        wrapper.onclick = null;
        
        // Add new click handler
        wrapper.onclick = function(e) {
          e.preventDefault();
          e.stopPropagation();
          
          var userId = this.getAttribute('data-userid');
          var userName = this.getAttribute('data-username');
          
          if (userId && userName && userId.trim() !== '' && userName.trim() !== '') {
            openPhotoModal(userId, userName);
          }
        };
      });
    }
    
    function init() {
      // Ensure modal is closed on page load
      var modal = document.getElementById('photoModal');
      if (modal) {
        modal.classList.remove('show');
        modal.style.display = 'none'; // Force hide with inline style initially
      }
      
      // Attach click handlers after a short delay
      setTimeout(function() {
        attachAvatarClickHandlers();
        
        // Close modal when clicking outside
        var photoModal = document.getElementById('photoModal');
        if (photoModal) {
          photoModal.addEventListener('click', function(e) {
            if (e.target === this) {
              closePhotoModal();
            }
          });
        }
      }, 100);
    }
      
    // Initialize after DOM is ready
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', init);
    } else {
      init();
    }
    
    // Re-attach handlers after postback
    if (typeof(Sys) !== 'undefined') {
      Sys.WebForms.PageRequestManager.getInstance().add_endRequest(function() {
        setTimeout(attachAvatarClickHandlers, 100);
      });
    }
  </script>
</asp:Content>
