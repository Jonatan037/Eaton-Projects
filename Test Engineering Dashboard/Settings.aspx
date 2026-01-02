<%@ Page Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="Settings.aspx.cs" Inherits="TED_Settings" %>

<asp:Content ID="TitleContent" ContentPlaceHolderID="TitleContent" runat="server">Settings</asp:Content>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
  <style>
    :root { --sidebar-w: 280px; }
    .settings-grid { display:grid; grid-template-columns: var(--sidebar-w) 1fr; gap:18px; min-height:calc(100dvh - var(--vh-offset)); box-sizing:border-box; --col-btm-gap:12px; padding:10px 18px 34px; }
    .settings-grid > * { min-width:0; min-height:0; }
    .dash-sidebar { position:sticky; top:12px; height:calc(100% - 12px - var(--col-btm-gap)); margin-bottom:var(--col-btm-gap); display:flex; flex-direction:column; background:rgba(25,29,37,.55); border:1px solid rgba(255,255,255,.08); border-radius:18px; box-shadow:0 16px 36px -10px rgba(0,0,0,.6), 0 0 0 1px rgba(255,255,255,.05), 0 0 10px rgba(235,235,240,.12); backdrop-filter:blur(40px) saturate(140%); padding:16px 14px; overflow:auto; }
    html.theme-light .dash-sidebar, html[data-theme='light'] .dash-sidebar { background:rgba(255,255,255,.7); border:1px solid rgba(0,0,0,.08); box-shadow:0 14px 34px -12px rgba(0,0,0,.25), 0 0 0 1px rgba(0,0,0,.05), 0 0 10px rgba(0,0,0,.12); }
    .sidebar-user { display:flex; align-items:center; gap:10px; padding:10px 8px 12px; border-bottom:1px solid rgba(255,255,255,.08); margin:0 6px 10px; }
    html.theme-light .sidebar-user, html[data-theme='light'] .sidebar-user { border-bottom:1px solid rgba(0,0,0,.08); }
    .user-meta { display:flex; flex-direction:column; line-height:1.1; font-size:11px; opacity:.9; }
    .nav { padding:8px 4px; overflow:visible; }
    .nav-title { font-size:11px; letter-spacing:.6px; opacity:.65; padding:12px 12px 6px; text-transform:uppercase; }
    .nav-list { list-style:none; margin:0; padding:0; }
    .nav-link { display:flex; align-items:center; gap:10px; padding:10px 12px; margin:2px 6px; border-radius:12px; text-decoration:none; color:inherit; border:1px solid transparent; transition:background .25s ease, color .25s ease, border-color .25s ease; }
    .nav-link .icon { width:16px; height:16px; color:currentColor; opacity:.9; }
    .nav-link span { font-size:13px; }
    .nav-link:hover { background:rgba(255,255,255,.08); border-color:rgba(255,255,255,.12); }
    html.theme-light .nav-link:hover, html[data-theme='light'] .nav-link:hover { background:rgba(0,0,0,.055); border-color:rgba(0,0,0,.10); }
    .nav-link.active { background:rgba(77,141,255,.13); border-color:rgba(77,141,255,.3); color:#bcd4ff; }
    html.theme-light .nav-link.active, html[data-theme='light'] .nav-link.active { background:#ffffff; border-color:rgba(77,141,255,.35); color:#1f2530; box-shadow:0 1px 0 rgba(255,255,255,.7) inset; }
    .nav-link.danger { color:#ff6b6b; border-color:transparent; }
    .nav-link.danger .icon { color:currentColor; }
    .nav-link.danger:hover { background:rgba(255,86,86,.14); border-color:rgba(255,86,86,.35); color:#ff8a8a; }
    html.theme-light .nav-link.danger, html[data-theme='light'] .nav-link.danger { color:#c62828; }
    html.theme-light .nav-link.danger:hover, html[data-theme='light'] .nav-link.danger:hover { background:rgba(198,40,40,.10); border-color:rgba(198,40,40,.35); color:#b71c1c; }
    .nav-link.disabled { opacity:.45; cursor:not-allowed; pointer-events:none; color:#888; }
    .nav-link.disabled .icon { opacity:.5; }
    html.theme-light .nav-link.disabled, html[data-theme='light'] .nav-link.disabled { color:#999; opacity:.5; }
    .sidebar-spacer { flex:1; }
    .user-info { display:flex; align-items:center; gap:10px; padding:6px 6px 10px; }
    .avatar { width:34px; height:34px; border-radius:50%; display:flex; align-items:center; justify-content:center; background:rgba(255,255,255,.1); border:1px solid rgba(255,255,255,.2); font-weight:700; }
    html.theme-light .avatar, html[data-theme='light'] .avatar { background:#f1f4f9; border:1px solid rgba(0,0,0,.12); color:#1b222b; }
    
    .settings-main { padding: 24px; overflow-y: auto; grid-column: 2 / 3; }
    
    .settings-container { width: 100%; max-width: 100%; margin: 0; }
    
    .settings-header { margin-bottom: 32px; }
    .settings-title { font-size: 28px; font-weight: 800; letter-spacing: 0.3px; margin: 0 0 8px; }
    .settings-subtitle { font-size: 14px; opacity: 0.7; margin: 0; }
    
    .profile-section { background: rgba(25,29,37,.46); border: 1px solid rgba(255,255,255,.08); border-radius: 16px; padding: 32px; margin-bottom: 24px; box-shadow: 0 16px 34px -12px rgba(0,0,0,.6), 0 0 0 1px rgba(255,255,255,.05); backdrop-filter: blur(24px) saturate(140%); }
    html.theme-light .profile-section, html[data-theme='light'] .profile-section { background: #ffffff; border: 1px solid rgba(0,0,0,.08); box-shadow: 0 16px 34px -12px rgba(0,0,0,.16), 0 0 0 1px rgba(0,0,0,.05); }
    
    .profile-header { display: flex; align-items: center; gap: 24px; margin-bottom: 32px; padding-bottom: 24px; border-bottom: 1px solid rgba(255,255,255,.08); }
    html.theme-light .profile-header, html[data-theme='light'] .profile-header { border-bottom: 1px solid rgba(0,0,0,.08); }
    
    .profile-avatar-container { position: relative; }
    .profile-avatar { width: 120px; height: 120px; border-radius: 50%; object-fit: cover; border: 3px solid rgba(255,255,255,.12); background: rgba(0,0,0,.15); }
    html.theme-light .profile-avatar, html[data-theme='light'] .profile-avatar { border: 3px solid rgba(0,0,0,.08); background: #f1f4f7; }
    
    .profile-avatar-fallback { width: 120px; height: 120px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 800; font-size: 42px; background: linear-gradient(135deg, #243b55, #141E30); color: #cfe6ff; border: 3px solid rgba(255,255,255,.12); }
    html.theme-light .profile-avatar-fallback, html[data-theme='light'] .profile-avatar-fallback { background: linear-gradient(135deg, #e3efff, #cfe3ff); color: #214a80; border: 3px solid rgba(0,0,0,.08); }
    
    .profile-avatar-edit { position: absolute; bottom: 5px; right: 5px; width: 36px; height: 36px; border-radius: 50%; background: rgba(77,141,255,.95); border: 3px solid rgba(25,29,37,1); display: flex; align-items: center; justify-content: center; cursor: pointer; transition: all 0.2s ease; box-shadow: 0 2px 8px rgba(0,0,0,.3); }
    .profile-avatar-edit:hover { background: rgba(77,141,255,1); transform: scale(1.1); box-shadow: 0 4px 12px rgba(77,141,255,.4); }
    html.theme-light .profile-avatar-edit, html[data-theme='light'] .profile-avatar-edit { background: rgba(0,99,206,.95); border: 3px solid #ffffff; box-shadow: 0 2px 8px rgba(0,0,0,.15); }
    html.theme-light .profile-avatar-edit:hover, html[data-theme='light'] .profile-avatar-edit:hover { box-shadow: 0 4px 12px rgba(0,99,206,.3); }
    .profile-avatar-edit svg { width: 16px; height: 16px; color: white; stroke-width: 2.5; }
    
    .profile-info { flex: 1; }
    .profile-name { font-size: 24px; font-weight: 800; margin: 0 0 4px; }
    .profile-role { font-size: 14px; opacity: 0.8; margin: 0 0 12px; }
    .profile-badges { display: flex; gap: 8px; flex-wrap: wrap; }
    .badge { display: inline-flex; align-items: center; gap: 6px; padding: 6px 12px; border-radius: 999px; font-size: 12px; font-weight: 700; border: 1px solid rgba(255,255,255,.18); background: rgba(255,255,255,.06); }
    html.theme-light .badge, html[data-theme='light'] .badge { border: 1px solid rgba(0,0,0,.12); background: rgba(0,0,0,.03); }
    .badge.badge-active { background: rgba(30,180,90,.15); border-color: rgba(30,180,90,.4); color: #5cff9d; }
    html.theme-light .badge.badge-active, html[data-theme='light'] .badge.badge-active { background: rgba(30,180,90,.1); border-color: rgba(30,180,90,.35); color: #16a34a; }
    
    .info-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 24px; }
    
    .info-field { margin-bottom: 24px; position: relative; min-width: 0; overflow: hidden; }
    .info-field:last-child { margin-bottom: 0; }
    .field-label { font-size: 12px; font-weight: 700; opacity: 0.7; text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 8px; }
    .field-value { font-size: 15px; font-weight: 500; padding: 12px 16px; background: rgba(0,0,0,.08); border: 1px solid rgba(255,255,255,.06); border-radius: 10px; opacity: 0.65; cursor: not-allowed; min-height: 45px; box-sizing: border-box; }
    html.theme-light .field-value, html[data-theme='light'] .field-value { background: #f5f7fa; border: 1px solid rgba(0,0,0,.06); opacity: 0.85; color: #5a6270; }
    
    #displayFullName, #editFullName, #displayPassword, #editPassword { min-height: 45px; }
    #editPassword { min-height: 165px; }
    
    .field-value.editable { position: relative; }
    .field-input { width: 100%; box-sizing: border-box; font-size: 15px; font-weight: 500; padding: 12px 16px; background: rgba(0,0,0,.15); border: 1px solid rgba(77,141,255,.35); border-radius: 10px; color: inherit; font-family: inherit; outline: none; transition: all 0.2s ease; opacity: 1; cursor: text; }
    .field-input:focus { background: rgba(0,0,0,.2); border-color: rgba(77,141,255,.6); box-shadow: 0 0 0 3px rgba(77,141,255,.15); }
    html.theme-light .field-input, html[data-theme='light'] .field-input { background: #ffffff; border: 1px solid rgba(0,99,206,.35); color: #1f242b; }
    html.theme-light .field-input:focus, html[data-theme='light'] .field-input:focus { background: #ffffff; border-color: rgba(0,99,206,.6); box-shadow: 0 0 0 3px rgba(0,99,206,.1); }
    
    .password-field { position: relative; margin-bottom: 12px; width: 100%; box-sizing: border-box; }
    .password-field:last-child { margin-bottom: 0; }
    .password-field input { padding-right: 44px; width: 100%; box-sizing: border-box; }
    .password-toggle { position: absolute; right: 12px; top: 50%; transform: translateY(-50%); cursor: pointer; opacity: 0.6; transition: opacity 0.2s ease; }
    .password-toggle:hover { opacity: 1; }
    .password-toggle svg { width: 20px; height: 20px; }
    
    #editPassword { padding-top: 4px; width: 100%; box-sizing: border-box; }
    #editFullName { width: 100%; box-sizing: border-box; }
    
    .action-buttons { display: flex; gap: 12px; margin-top: 32px; padding-top: 24px; border-top: 1px solid rgba(255,255,255,.08); }
    html.theme-light .action-buttons, html[data-theme='light'] .action-buttons { border-top: 1px solid rgba(0,0,0,.08); }
    
    .btn { padding: 12px 24px; border-radius: 10px; font-weight: 700; font-size: 14px; border: none; cursor: pointer; transition: all 0.2s ease; display: inline-flex; align-items: center; gap: 8px; }
    .btn-primary { background: linear-gradient(135deg, #4d8dff, #0063ce); color: white; box-shadow: 0 4px 12px -2px rgba(77,141,255,.4); }
    .btn-primary:hover { transform: translateY(-2px); box-shadow: 0 8px 20px -4px rgba(77,141,255,.5); }
    .btn-primary:disabled { opacity: 0.5; cursor: not-allowed; transform: none; }
    
    .btn-secondary { background: rgba(255,255,255,.06); border: 1px solid rgba(255,255,255,.18); color: inherit; }
    .btn-secondary:hover { background: rgba(255,255,255,.12); border-color: rgba(255,255,255,.25); }
    html.theme-light .btn-secondary, html[data-theme='light'] .btn-secondary { background: #ffffff; border: 1px solid rgba(0,0,0,.12); }
    html.theme-light .btn-secondary:hover, html[data-theme='light'] .btn-secondary:hover { background: #f8fbff; border-color: rgba(0,0,0,.2); }
    
    .btn svg { width: 18px; height: 18px; }
    
    .request-change-note { margin-top: 16px; padding: 16px; background: rgba(255,200,80,.1); border: 1px solid rgba(255,200,80,.25); border-radius: 10px; font-size: 13px; line-height: 1.6; }
    html.theme-light .request-change-note, html[data-theme='light'] .request-change-note { background: #fff9e5; border: 1px solid #f0d199; color: #8a5a00; }
    
    /* Modal styles */
    .modal-overlay { position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,.7); backdrop-filter: blur(8px); z-index: 10000; display: none; align-items: center; justify-content: center; animation: fadeIn 0.2s ease; }
    .modal-overlay.show { display: flex; }
    
    .modal { background: rgba(25,29,37,.98); border: 1px solid rgba(255,255,255,.12); border-radius: 16px; padding: 24px; max-width: 480px; width: 90%; max-height: 90vh; overflow-y: auto; box-shadow: 0 24px 64px -12px rgba(0,0,0,.8); animation: slideUp 0.3s ease; box-sizing: border-box; }
    html.theme-light .modal, html[data-theme='light'] .modal { background: #ffffff; border: 1px solid rgba(0,0,0,.12); }
    
    .modal-header { margin-bottom: 20px; }
    .modal-title { font-size: 20px; font-weight: 800; margin: 0 0 6px; word-wrap: break-word; }
    .modal-subtitle { font-size: 13px; opacity: 0.7; margin: 0; word-wrap: break-word; }
    
    .modal-body { margin-bottom: 20px; overflow: hidden; }
    
    .modal-actions { display: flex; gap: 12px; justify-content: flex-end; }
    
    .file-input-wrapper { 
      position: relative; 
      width: 100%; 
      display: flex; 
      justify-content: center; 
      align-items: center;
      padding: 20px;
      background: rgba(0,0,0,.08);
      border: 2px dashed rgba(77,141,255,.35);
      border-radius: 10px;
      transition: all 0.2s ease;
    }
    .file-input-wrapper:hover {
      background: rgba(0,0,0,.12);
      border-color: rgba(77,141,255,.6);
    }
    .file-input-wrapper input[type=file] { 
      width: 100%;
      max-width: 100%;
      font-family: inherit; 
      font-size: 14px;
      cursor: pointer;
      color: inherit;
    }
    .file-input-wrapper input[type=file]::file-selector-button {
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
    .file-input-wrapper input[type=file]::file-selector-button:hover {
      background: rgba(77,141,255,.3);
      border-color: rgba(77,141,255,.6);
    }
    html.theme-light .file-input-wrapper, 
    html[data-theme='light'] .file-input-wrapper { 
      background: #f8fbff; 
      border-color: rgba(0,99,206,.35); 
    }
    html.theme-light .file-input-wrapper:hover, 
    html[data-theme='light'] .file-input-wrapper:hover { 
      background: #f0f7ff; 
      border-color: rgba(0,99,206,.6); 
    }
    html.theme-light .file-input-wrapper input[type=file]::file-selector-button, 
    html[data-theme='light'] .file-input-wrapper input[type=file]::file-selector-button { 
      background: rgba(0,99,206,.15);
      border-color: rgba(0,99,206,.4);
      color: #0063ce;
    }
    html.theme-light .file-input-wrapper input[type=file]::file-selector-button:hover, 
    html[data-theme='light'] .file-input-wrapper input[type=file]::file-selector-button:hover { 
      background: rgba(0,99,206,.25);
      border-color: rgba(0,99,206,.6);
    }
    
    @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
    @keyframes slideUp { from { transform: translateY(20px); opacity: 0; } to { transform: translateY(0); opacity: 1; } }
    
    /* Toast notification */
    .toast { position: fixed; top: 24px; right: 24px; padding: 16px 24px; border-radius: 12px; font-weight: 700; font-size: 14px; box-shadow: 0 16px 48px -8px rgba(0,0,0,.6); z-index: 10001; display: none; animation: slideInRight 0.3s ease; }
    .toast.show { display: block; }
    .toast.success { background: rgba(30,180,90,.95); color: white; border: 1px solid rgba(30,180,90,1); }
    .toast.error { background: rgba(255,80,80,.95); color: white; border: 1px solid rgba(255,80,80,1); }
    
    @keyframes slideInRight { from { transform: translateX(100%); opacity: 0; } to { transform: translateX(0); opacity: 1; } }
  </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
  <div class="settings-grid">
    <aside class="dash-sidebar" role="navigation" aria-label="Sidebar">
      <div class="sidebar-user">
        <asp:Image ID="imgSidebarAvatar" runat="server" CssClass="avatar" AlternateText="User avatar" Visible="false" />
        <div class="avatar" id="avatarSidebarFallback" runat="server"><asp:Literal ID="litSidebarInitials" runat="server" /></div>
        <div class="user-meta">
          <strong><asp:Literal ID="litSidebarFullName" runat="server" /></strong>
          <span><asp:Literal ID="litSidebarRole" runat="server" /></span>
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
          <li><a class="nav-link active" href="Settings.aspx"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="3"/><path d="M12 1v6m0 6v6m9-9h-6m-6 0H3"/><path d="M19.07 4.93l-4.24 4.24m-5.66 0L4.93 4.93m14.14 14.14l-4.24-4.24m-5.66 0l-4.24 4.24"/></svg><span>Settings</span></a></li>
          <li><a class="nav-link disabled" href="javascript:void(0)"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/><path d="M8 10h.01M12 10h.01M16 10h.01"/></svg><span>Help / Feedback</span></a></li>
          <li><asp:HyperLink ID="lnkAdminPortal" runat="server" CssClass="nav-link" NavigateUrl="~/Admin/Requests.aspx"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="8" r="3"/><path d="M4 20a8 8 0 0 1 16 0"/></svg><span>Admin portal</span></asp:HyperLink></li>
          <li><a class="nav-link danger" href="<%= ResolveUrl("~/Account/Logout.aspx") %>"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><path d="M16 17l5-5-5-5"/><path d="M21 12H9"/></svg><span>Logout</span></a></li>
        </ul>
      </nav>
    </aside>
    
    <div class="settings-main">
      <div class="settings-container">
        <div class="settings-header">
          <h1 class="settings-title">Settings</h1>
          <p class="settings-subtitle">Manage your account settings and preferences</p>
        </div>
        
        <div class="profile-section">
          <div class="profile-header">
            <div class="profile-avatar-container">
              <asp:Image ID="imgProfilePic" runat="server" CssClass="profile-avatar" AlternateText="Profile Picture" Style="display:none;" />
              <asp:Panel ID="pnlProfileFallback" runat="server" CssClass="profile-avatar-fallback" Style="display:flex;">
                <asp:Literal ID="litInitials" runat="server" />
              </asp:Panel>
              <div class="profile-avatar-edit" onclick="openChangePhotoModal()">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                  <path d="M12 20h9"></path>
                  <path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"></path>
                </svg>
              </div>
            </div>
            <div class="profile-info">
              <h2 class="profile-name"><asp:Literal ID="litFullName" runat="server" /></h2>
              <p class="profile-role"><asp:Literal ID="litJobRole" runat="server" /> &bull; <asp:Literal ID="litDepartment" runat="server" /></p>
              <div class="profile-badges">
                <span class="badge"><asp:Literal ID="litUserCategory" runat="server" /></span>
                <span class="badge badge-active">Active</span>
              </div>
            </div>
          </div>
          
          <div class="info-grid">
            <div class="info-field">
              <div class="field-label">Full Name</div>
              <div class="field-value" id="displayFullName"><asp:Literal ID="litFullNameValue" runat="server" /></div>
              <div id="editFullName" style="display:none;">
                <asp:TextBox ID="txtFullName" runat="server" CssClass="field-input" />
              </div>
            </div>
            
            <div class="info-field">
              <div class="field-label">E Number</div>
              <div class="field-value"><asp:Literal ID="litENumber" runat="server" /></div>
            </div>
            
            <div class="info-field">
              <div class="field-label">Email</div>
              <div class="field-value"><asp:Literal ID="litEmail" runat="server" /></div>
            </div>
            
            <div class="info-field">
              <div class="field-label">Department</div>
              <div class="field-value"><asp:Literal ID="litDepartmentValue" runat="server" /></div>
            </div>
            
            <div class="info-field">
              <div class="field-label">Job Role</div>
              <div class="field-value"><asp:Literal ID="litJobRoleValue" runat="server" /></div>
            </div>
            
            <div class="info-field">
              <div class="field-label">User Category</div>
              <div class="field-value"><asp:Literal ID="litUserCategoryValue" runat="server" /></div>
            </div>
            
            <div class="info-field">
              <div class="field-label">Test Lines</div>
              <div class="field-value"><asp:Literal ID="litTestLines" runat="server" /></div>
            </div>
            
            <div class="info-field">
              <div class="field-label">Password</div>
              <div class="field-value" id="displayPassword">&bull;&bull;&bull;&bull;&bull;&bull;&bull;&bull;&bull;&bull;&bull;&bull;</div>
              <div id="editPassword" style="display:none;">
                <div class="password-field">
                  <asp:TextBox ID="txtOldPassword" runat="server" TextMode="Password" CssClass="field-input" placeholder="Current password" />
                  <span class="password-toggle" onclick="togglePassword('<%= txtOldPassword.ClientID %>')">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                      <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                      <circle cx="12" cy="12" r="3"></circle>
                    </svg>
                  </span>
                </div>
                <div class="password-field">
                  <asp:TextBox ID="txtNewPassword" runat="server" TextMode="Password" CssClass="field-input" placeholder="New password" />
                  <span class="password-toggle" onclick="togglePassword('<%= txtNewPassword.ClientID %>')">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                      <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                      <circle cx="12" cy="12" r="3"></circle>
                    </svg>
                  </span>
                </div>
                <div class="password-field">
                  <asp:TextBox ID="txtConfirmPassword" runat="server" TextMode="Password" CssClass="field-input" placeholder="Confirm new password" />
                  <span class="password-toggle" onclick="togglePassword('<%= txtConfirmPassword.ClientID %>')">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                      <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                      <circle cx="12" cy="12" r="3"></circle>
                    </svg>
                  </span>
                </div>
              </div>
            </div>
          </div>
          
          <div class="request-change-note">
            <strong>Need to update Department, Job Role, User Category, or Test Lines?</strong><br>
            Contact your administrator to request changes to these fields.
          </div>
          
          <div class="action-buttons" id="viewActions">
            <button type="button" class="btn btn-primary" onclick="enableEditMode()">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M12 20h9"></path>
                <path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"></path>
              </svg>
              Edit Profile
            </button>
          </div>
          
          <div class="action-buttons" id="editActions" style="display:none;">
            <button type="button" class="btn btn-secondary" onclick="cancelEdit()">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <line x1="18" y1="6" x2="6" y2="18"></line>
                <line x1="6" y1="6" x2="18" y2="18"></line>
              </svg>
              Cancel
            </button>
            <asp:Button ID="btnSave" runat="server" Text="Save Changes" CssClass="btn btn-primary" OnClick="btnSave_Click" OnClientClick="return validateForm();" />
          </div>
        </div>
      </div>
    </div>
  </div>
  
  <!-- Change Photo Modal -->
  <div class="modal-overlay" id="photoModal">
    <div class="modal">
      <div class="modal-header">
        <h3 class="modal-title">Change Profile Picture</h3>
        <p class="modal-subtitle">Upload a new profile picture (JPG, PNG, max 5MB)</p>
      </div>
      <div class="modal-body">
        <div class="file-input-wrapper">
          <asp:FileUpload ID="fileProfilePic" runat="server" accept="image/*" onchange="previewImage(this)" />
        </div>
        <div id="imagePreview" style="margin-top: 16px; display: none;">
          <img id="previewImg" style="max-width: 100%; border-radius: 12px; border: 1px solid rgba(255,255,255,.12);" />
        </div>
      </div>
      <div class="modal-actions">
        <button type="button" class="btn btn-secondary" onclick="closePhotoModal()">Cancel</button>
        <asp:Button ID="btnUploadPhoto" runat="server" Text="Upload Photo" CssClass="btn btn-primary" OnClick="btnUploadPhoto_Click" />
      </div>
    </div>
  </div>
  
  <!-- Toast Notification -->
  <div class="toast" id="toast"></div>
  
  <script type="text/javascript">
    function enableEditMode() {
      document.getElementById('viewActions').style.display = 'none';
      document.getElementById('editActions').style.display = 'flex';
      
      document.getElementById('displayFullName').style.display = 'none';
      document.getElementById('editFullName').style.display = 'block';
      
      document.getElementById('displayPassword').style.display = 'none';
      document.getElementById('editPassword').style.display = 'block';
    }
    
    function cancelEdit() {
      document.getElementById('viewActions').style.display = 'flex';
      document.getElementById('editActions').style.display = 'none';
      
      document.getElementById('displayFullName').style.display = 'block';
      document.getElementById('editFullName').style.display = 'none';
      
      document.getElementById('displayPassword').style.display = 'block';
      document.getElementById('editPassword').style.display = 'none';
      
      document.getElementById('<%= txtOldPassword.ClientID %>').value = '';
      document.getElementById('<%= txtNewPassword.ClientID %>').value = '';
      document.getElementById('<%= txtConfirmPassword.ClientID %>').value = '';
    }
    
    function validateForm() {
      var fullName = document.getElementById('<%= txtFullName.ClientID %>').value.trim();
      if (fullName === '') {
        showToast('Please enter your full name', 'error');
        return false;
      }
      
      var oldPass = document.getElementById('<%= txtOldPassword.ClientID %>').value;
      var newPass = document.getElementById('<%= txtNewPassword.ClientID %>').value;
      var confirmPass = document.getElementById('<%= txtConfirmPassword.ClientID %>').value;
      
      if (newPass || confirmPass || oldPass) {
        if (!oldPass) {
          showToast('Please enter your current password', 'error');
          return false;
        }
        if (!newPass) {
          showToast('Please enter a new password', 'error');
          return false;
        }
        if (newPass !== confirmPass) {
          showToast('New passwords do not match', 'error');
          return false;
        }
        if (newPass.length < 6) {
          showToast('Password must be at least 6 characters', 'error');
          return false;
        }
      }
      
      return true;
    }
    
    function togglePassword(inputId) {
      var input = document.getElementById(inputId);
      if (input.type === 'password') {
        input.type = 'text';
      } else {
        input.type = 'password';
      }
    }
    
    function openChangePhotoModal() {
      document.getElementById('photoModal').classList.add('show');
    }
    
    function closePhotoModal() {
      document.getElementById('photoModal').classList.remove('show');
      document.getElementById('imagePreview').style.display = 'none';
    }
    
    function previewImage(input) {
      if (input.files && input.files[0]) {
        var reader = new FileReader();
        reader.onload = function(e) {
          document.getElementById('previewImg').src = e.target.result;
          document.getElementById('imagePreview').style.display = 'block';
        };
        reader.readAsDataURL(input.files[0]);
      }
    }
    
    function showToast(message, type) {
      var toast = document.getElementById('toast');
      toast.textContent = message;
      toast.className = 'toast ' + type + ' show';
      setTimeout(function() {
        toast.classList.remove('show');
      }, 3000);
    }
    
    // Close modal when clicking outside
    document.getElementById('photoModal').addEventListener('click', function(e) {
      if (e.target === this) {
        closePhotoModal();
      }
    });
    
    // Avatar fallback handling
    (function(){
      var img = document.getElementById('<%= imgProfilePic.ClientID %>');
      var fallback = document.getElementById('<%= pnlProfileFallback.ClientID %>');
      if (!img) return;
      img.addEventListener('error', function(){ img.style.display='none'; if(fallback) fallback.style.display='flex'; });
      if (img.complete) {
        if (img.naturalWidth && img.naturalHeight) { img.style.display='block'; if(fallback) fallback.style.display='none'; }
        else { img.style.display='none'; if(fallback) fallback.style.display='flex'; }
      } else {
        img.addEventListener('load', function(){
          if (img.naturalWidth && img.naturalHeight) { img.style.display='block'; if(fallback) fallback.style.display='none'; }
          else { img.style.display='none'; if(fallback) fallback.style.display='flex'; }
        });
      }
    })();
  </script>
</asp:Content>
