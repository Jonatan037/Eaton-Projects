<%@ Page Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="Analytics.aspx.cs" Inherits="TED_Analytics" %>
<asp:Content ID="AnTitle" ContentPlaceHolderID="TitleContent" runat="server">Analytics - Test Engineering</asp:Content>
<asp:Content ID="AnHead" ContentPlaceHolderID="HeadContent" runat="server">
  <style>
    :root { --sidebar-w: 280px; }
  .dash-shell { display:grid; grid-template-columns: var(--sidebar-w) 1fr; gap:18px; min-height:calc(100vh - 28px); padding:10px 18px 34px; }
    .dash-sidebar { position:sticky; top:12px; height:calc(100vh - 30px); display:flex; flex-direction:column; background:rgba(25,29,37,.55); border:1px solid rgba(255,255,255,.08); border-radius:18px; box-shadow:0 16px 36px -10px rgba(0,0,0,.6), 0 0 0 1px rgba(255,255,255,.05); backdrop-filter:blur(40px) saturate(140%); padding:16px 14px; }
    html.theme-light .dash-sidebar, html[data-theme='light'] .dash-sidebar { background:rgba(255,255,255,.7); border:1px solid rgba(0,0,0,.08); box-shadow:0 14px 34px -12px rgba(0,0,0,.18), 0 0 0 1px rgba(0,0,0,.05); }
    .sidebar-user { display:flex; align-items:center; gap:10px; padding:10px 8px 12px; border-bottom:1px solid rgba(255,255,255,.08); margin:0 6px 10px; }
    html.theme-light .sidebar-user, html[data-theme='light'] .sidebar-user { border-bottom:1px solid rgba(0,0,0,.08); }
    .avatar { width:34px; height:34px; border-radius:50%; display:flex; align-items:center; justify-content:center; background:rgba(255,255,255,.1); border:1px solid rgba(255,255,255,.2); font-weight:700; }
    html.theme-light .avatar, html[data-theme='light'] .avatar { background:#f1f4f9; border:1px solid rgba(0,0,0,.12); color:#1b222b; }
    .user-meta { display:flex; flex-direction:column; line-height:1.1; font-size:11px; opacity:.9; }
    .nav { padding:8px 4px; overflow:auto; }
    .nav-title { font-size:11px; letter-spacing:.6px; opacity:.65; padding:12px 12px 6px; text-transform:uppercase; }
    .nav-list { list-style:none; margin:0; padding:0; }
    .nav-link { display:flex; align-items:center; gap:10px; padding:10px 12px; margin:2px 6px; border-radius:12px; text-decoration:none; color:inherit; border:1px solid transparent; transition:background .25s ease, color .25s ease, border-color .25s ease; }
    .nav-link .icon { width:16px; height:16px; color:currentColor; opacity:.9; }
    .nav-link span { font-size:13px; }
    .nav-link:hover { background:rgba(255,255,255,.08); border-color:rgba(255,255,255,.12); }
    html.theme-light .nav-link:hover, html[data-theme='light'] .nav-link:hover { background:rgba(0,0,0,.055); border-color:rgba(0,0,0,.10); }
    .nav-link.active { background:rgba(77,141,255,.13); border-color:rgba(77,141,255,.3); color:#bcd4ff; }
    html.theme-light .nav-link.active, html[data-theme='light'] .nav-link.active { background:#ffffff; border-color:rgba(77,141,255,.35); color:#1f2530; box-shadow:0 1px 0 rgba(255,255,255,.7) inset; }
    /* Disabled-styled nav item (unbuilt features) */
    .nav-link.disabled { opacity:.45; cursor:not-allowed; pointer-events:none; color:#888; }
    .nav-link.disabled .icon { opacity:.5; }
    html.theme-light .nav-link.disabled, html[data-theme='light'] .nav-link.disabled { color:#999; opacity:.5; }
    .sidebar-spacer { flex:1; }
    .sidebar-bottom { padding:10px 8px 6px; border-top:1px solid rgba(255,255,255,.08); margin:10px 6px 0; }
    html.theme-light .sidebar-bottom, html[data-theme='light'] .sidebar-bottom { border-top:1px solid rgba(0,0,0,.08); }
    .user-info { display:flex; align-items:center; gap:10px; padding:6px 6px 10px; }
    .avatar { width:34px; height:34px; border-radius:50%; display:flex; align-items:center; justify-content:center; background:rgba(255,255,255,.1); border:1px solid rgba(255,255,255,.2); font-weight:700; }
    html.theme-light .avatar, html[data-theme='light'] .avatar { background:#f1f4f9; border:1px solid rgba(0,0,0,.12); color:#1b222b; }
    .user-meta { display:flex; flex-direction:column; line-height:1.1; font-size:11px; opacity:.85; }
    .btn-logout { display:inline-flex; align-items:center; gap:8px; padding:10px 12px; border-radius:12px; text-decoration:none; border:1px solid rgba(255,255,255,.12); color:inherit; background:linear-gradient(155deg,#1a2027,#14191f); box-shadow:0 2px 4px rgba(0,0,0,.5); font-size:12px; font-weight:600; letter-spacing:.2px; }
    .btn-logout:hover { background:linear-gradient(155deg,#242c35,#1a2027); border-color:rgba(255,255,255,.22); }
    html.theme-light .btn-logout, html[data-theme='light'] .btn-logout { background:linear-gradient(165deg,#ffffff,#eef2f7); color:#1f242b; border:1px solid rgba(0,0,0,.14); box-shadow:0 3px 6px rgba(0,0,0,.18), 0 1px 2px rgba(255,255,255,.6) inset; }
    html.theme-light .btn-logout:hover, html[data-theme='light'] .btn-logout:hover { background:#ffffff; }
    .dash-main { min-height:100%; background:rgba(25,29,37,.52); border:1px solid rgba(255,255,255,.08); border-radius:18px; box-shadow:0 16px 36px -10px rgba(0,0,0,.6), 0 0 0 1px rgba(255,255,255,.05); backdrop-filter:blur(36px) saturate(135%); padding:18px 20px 24px; overflow:auto; }
    html.theme-light .dash-main, html[data-theme='light'] .dash-main { background:rgba(255,255,255,.72); border:1px solid rgba(0,0,0,.08); box-shadow:0 14px 34px -12px rgba(0,0,0,.18), 0 0 0 1px rgba(0,0,0,.05); }
  .dash-topbar { display:flex; align-items:center; justify-content:flex-start; gap:12px; margin-bottom:14px; }
    @keyframes pulseGlow { 0% { transform:scale(1); box-shadow:0 6px 14px rgba(0,0,0,.45),0 0 0 4px rgba(77,141,255,0);} 50% { transform:scale(1.045); box-shadow:0 10px 22px rgba(0,0,0,.55),0 0 0 10px rgba(77,141,255,.10);} 100% { transform:scale(1); box-shadow:0 6px 14px rgba(0,0,0,.45),0 0 0 4px rgba(77,141,255,0);} }
  </style>
</asp:Content>
<asp:Content ID="AnMain" ContentPlaceHolderID="MainContent" runat="server">
  <!-- Reuse the same sidebar by server-side include using the Dashboard markup pattern -->
  <!-- For simplicity, we link back to Dashboard sidebar for now -->
  <div class="dash-shell">
    <!-- Sidebar clone: we navigate back to Dashboard when clicking Dashboard link, and set Analytics active -->
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
          <li><a class="nav-link active" href="Analytics.aspx"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M3 3v18h18"/><path d="M7 17l4-6 3 3 4-7"/></svg><span>Analytics</span></a></li>
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
          <li><a class="nav-link" href="Settings.aspx"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="3"/><path d="M12 1v6m0 6v6m9-9h-6m-6 0H3"/><path d="M19.07 4.93l-4.24 4.24m-5.66 0L4.93 4.93m14.14 14.14l-4.24-4.24m-5.66 0l-4.24 4.24"/></svg><span>Settings</span></a></li>
          <li><a class="nav-link disabled" href="javascript:void(0)"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/><path d="M8 10h.01M12 10h.01M16 10h.01"/></svg><span>Help / Feedback</span></a></li>
          <li><asp:HyperLink ID="lnkAdminPortal" runat="server" CssClass="nav-link" NavigateUrl="~/Admin/Requests.aspx"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="8" r="3"/><path d="M4 20a8 8 0 0 1 16 0"/></svg><span>Admin portal</span></asp:HyperLink></li>
        </ul>
      </nav>
      <div class="sidebar-spacer"></div>
      <div class="sidebar-bottom" style="display:flex; justify-content:center;">
        <a class="btn-logout" href="<%= ResolveUrl("~/Account/Logout.aspx") %>"><span>Logout</span></a>
      </div>
    </aside>

    <main class="dash-main" role="main" aria-labelledby="hAn">
      <div class="dash-topbar">
        <h1 id="hAn" class="dash-title">Analytics</h1>
      </div>
      <div style="color:var(--text-light-low);">Analytics content coming soon…</div>
    </main>
  </div>
</asp:Content>
