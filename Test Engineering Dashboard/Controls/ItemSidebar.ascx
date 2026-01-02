<%@ Control Language="C#" AutoEventWireup="true" CodeFile="ItemSidebar.ascx.cs" Inherits="TED_Controls_ItemSidebar" %>
<style>
  /* Reuse Admin shell styles for consistent look */
  .admin-grid { display:grid; grid-template-columns: 280px 1fr; gap:18px; height:calc(100dvh - var(--vh-offset)); padding:10px 18px 34px; box-sizing:border-box; --col-btm-gap:12px; }
  .admin-grid > * { min-width:0; min-height:0; }
  .admin-grid > div { display:flex; flex-direction:column; min-height:0; padding-bottom:var(--col-btm-gap); box-sizing:border-box; }
  .admin-sidebar { position:sticky; top:12px; height:calc(100% - 12px - var(--col-btm-gap)); margin-bottom:var(--col-btm-gap); display:flex; flex-direction:column; background:rgba(25,29,37,.55); border:1px solid rgba(255,255,255,.08); border-radius:18px; box-shadow:0 16px 36px -10px rgba(0,0,0,.6), 0 0 0 1px rgba(255,255,255,.05), 0 0 10px rgba(235,235,240,.12); backdrop-filter:blur(40px) saturate(140%); padding:16px 14px; overflow:auto; }
  html.theme-light .admin-sidebar, html[data-theme='light'] .admin-sidebar { background:rgba(255,255,255,.7); border:1px solid rgba(0,0,0,.08); box-shadow:0 14px 34px -12px rgba(0,0,0,.25), 0 0 0 1px rgba(0,0,0,.05), 0 0 10px rgba(0,0,0,.12); }
  .nav { padding:8px 4px; overflow:visible; }
  .sidebar-title { font-size:12px; letter-spacing:.8px; opacity:.9; font-weight:800; text-transform:uppercase; padding:6px 12px 8px; border-bottom:1px solid rgba(255,255,255,.08); margin-bottom:8px; }
  html.theme-light .sidebar-title, html[data-theme='light'] .sidebar-title { border-bottom:1px solid rgba(0,0,0,.08); }
  .nav-title { font-size:11px; letter-spacing:.6px; opacity:.65; padding:12px 12px 6px; text-transform:uppercase; }
  .nav-list { list-style:none; margin:0; padding:0; }
  .nav-link { display:flex; align-items:center; gap:10px; padding:10px 12px; margin:2px 6px; border-radius:12px; text-decoration:none; color:inherit; border:1px solid transparent; transition:background .25s ease, color .25s ease, border-color .25s ease; font-size:13px; }
  .icon { width:16px; height:16px; color:currentColor; opacity:.9; }
  .nav-link:hover { background:rgba(255,255,255,.08); border-color:rgba(255,255,255,.12); }
  html.theme-light .nav-link:hover, html[data-theme='light'] .nav-link:hover { background:rgba(0,0,0,.055); border-color:rgba(0,0,0,.10); }
  .nav-link.active { background:rgba(77,141,255,.13); border-color:rgba(77,141,255,.3); color:#bcd4ff; }
  html.theme-light .nav-link.active, html[data-theme='light'] .nav-link.active { background:#ffffff; border-color:rgba(77,141,255,.35); color:#1f2530; box-shadow:0 1px 0 rgba(255,255,255,.7) inset; }
  .nav-link.danger { color:#ff6b6b; border-color:transparent; }
  .nav-link.danger .icon { color:currentColor; }
  .nav-link.danger:hover { background:rgba(255,86,86,.14); border-color:rgba(255,86,86,.35); color:#ff8a8a; }
  html.theme-light .nav-link.danger { color:#c62828; }
  html.theme-light .nav-link.danger:hover { background:rgba(198,40,40,.10); border-color:rgba(198,40,40,.35); color:#b71c1c; }
  .sidebar-spacer { flex:1; }
  /* Disabled state for nav links */
  .nav-link[aria-disabled="true"], .nav-link.disabled {
    opacity:.6; cursor:not-allowed; pointer-events:none; background:transparent !important; border-color:rgba(255,255,255,.08) !important; color:rgba(235,240,250,.55) !important;
  }
  html.theme-light .nav-link[aria-disabled="true"], html[data-theme='light'] .nav-link[aria-disabled="true"],
  html.theme-light .nav-link.disabled, html[data-theme='light'] .nav-link.disabled {
    background:transparent !important; border-color:rgba(0,0,0,.08) !important; color:#96a0ae !important;
  }
</style>
<aside class="admin-sidebar" role="navigation" aria-label="Item sidebar">
  <nav class="nav">
    <div class="sidebar-title">ITEM DETAILS</div>

    <div class="nav-title">Details</div>
    <ul class="nav-list">
      <li><a id="lnkDetATE" runat="server" class="nav-link" href="~/ItemDetails.aspx?type=ATE"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="16" rx="2"/><path d="M3 8h18"/></svg><span>ATE Details</span></a></li>
      <li><a id="lnkDetAsset" runat="server" class="nav-link" href="~/ItemDetails.aspx?type=Asset"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="16" rx="2"/><path d="M3 8h18"/></svg><span>Asset Details</span></a></li>
      <li><a id="lnkDetFixture" runat="server" class="nav-link" href="~/ItemDetails.aspx?type=Fixture"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="16" rx="2"/><path d="M3 8h18"/></svg><span>Fixture Details</span></a></li>
      <li><a id="lnkDetHarness" runat="server" class="nav-link" href="~/ItemDetails.aspx?type=Harness"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="16" rx="2"/><path d="M3 8h18"/></svg><span>Harness Details</span></a></li>
    </ul>

    <div class="nav-title">New Item</div>
    <ul class="nav-list">
      <li><a id="lnkNewATE" runat="server" class="nav-link" href="~/CreateNewItem.aspx?type=ATE"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M12 5v14"/><path d="M5 12h14"/></svg><span>New ATE</span></a></li>
      <li><a id="lnkNewAsset" runat="server" class="nav-link" href="~/CreateNewItem.aspx?type=Asset"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M12 5v14"/><path d="M5 12h14"/></svg><span>New Asset</span></a></li>
      <li><a id="lnkNewFixture" runat="server" class="nav-link" href="~/CreateNewItem.aspx?type=Fixture"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M12 5v14"/><path d="M5 12h14"/></svg><span>New Fixture</span></a></li>
      <li><a id="lnkNewHarness" runat="server" class="nav-link" href="~/CreateNewItem.aspx?type=Harness"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M12 5v14"/><path d="M5 12h14"/></svg><span>New Harness</span></a></li>
    </ul>

    <div class="nav-title">Other</div>
    <ul class="nav-list">
  <li><a id="lnkBack" runat="server" class="nav-link danger" href="~/EquipmentInventoryDashboard.aspx"><svg class="icon" viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M15 18l-6-6 6-6"/></svg><span>Back to Inventory Dashboard</span></a></li>
    </ul>
  </nav>
  <div class="sidebar-spacer"></div>
</aside>
