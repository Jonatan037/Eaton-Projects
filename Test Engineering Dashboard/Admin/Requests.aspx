<%@ Page Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="Requests.aspx.cs" Inherits="TED_Admin_Requests" %>
<%@ Register Src="~/Admin/Controls/AdminSidebar.ascx" TagPrefix="uc2" TagName="AdminSidebar" %>
<%@ Register Src="~/Admin/Controls/AdminHeader.ascx" TagPrefix="uc1" TagName="AdminHeader" %>
<asp:Content ID="TitleC" ContentPlaceHolderID="TitleContent" runat="server">Pending Requests - Admin</asp:Content>
<asp:Content ID="HeadC" ContentPlaceHolderID="HeadContent" runat="server">
  <style>
  .admin-container { background:rgba(25,29,37,.46); border:1px solid rgba(255,255,255,.08); border-radius:16px; box-shadow:0 16px 34px -12px rgba(0,0,0,.6), 0 0 0 1px rgba(255,255,255,.05); backdrop-filter:blur(24px) saturate(140%); padding:16px; flex:1; min-height:0; overflow:auto; }
    html.theme-light .admin-container, html[data-theme='light'] .admin-container { background:#ffffff; border:1px solid rgba(0,0,0,.08); box-shadow:0 16px 34px -12px rgba(0,0,0,.16), 0 0 0 1px rgba(0,0,0,.05); }
    .admin-header { display:flex; align-items:center; justify-content:space-between; margin:0 0 10px; }
  .admin-title { font-size:22px; font-weight:800; letter-spacing:.2px; }
  .admin-actions { display:flex; gap:8px; }
  .btn-link { display:inline-flex; align-items:center; gap:6px; padding:6px 10px; border-radius:10px; text-decoration:none; color:inherit; border:1px solid rgba(255,255,255,.14); background:rgba(255,255,255,.06); font-size:12px; transition:background .25s ease, border-color .25s ease, transform .2s ease, box-shadow .25s ease; }
  .btn-link:hover { background:rgba(255,255,255,.12); border-color:rgba(77,141,255,.35); transform:translateY(-1px); box-shadow:0 8px 18px -10px rgba(0,0,0,.6); }
    html.theme-light .btn-link, html[data-theme='light'] .btn-link { background:#fff; border:1px solid rgba(0,0,0,.12); }
  html.theme-light .btn-link:hover, html[data-theme='light'] .btn-link:hover { background:#f8fbff; border-color:rgba(77,141,255,.45); }

    .admin-nav { display:flex; gap:8px; flex-wrap:wrap; margin-bottom:12px; }
  .tab { padding:6px 10px; border-radius:10px; text-decoration:none; border:1px solid rgba(255,255,255,.12); color:inherit; background:rgba(255,255,255,.04); font-weight:600; font-size:12px; transition:background .25s ease, border-color .25s ease, transform .2s ease, box-shadow .25s ease; }
    .tab.active { background:rgba(77,141,255,.15); border-color:rgba(77,141,255,.35); }
  .tab:hover { background:rgba(255,255,255,.10); border-color:rgba(255,255,255,.25); transform:translateY(-1px); }
    html.theme-light .tab, html[data-theme='light'] .tab { background:#fff; border:1px solid rgba(0,0,0,.12); }
    html.theme-light .tab.active, html[data-theme='light'] .tab.active { background:#f3f7ff; border-color:rgba(77,141,255,.4); }
  html.theme-light .tab:hover, html[data-theme='light'] .tab:hover { background:#f9fbff; border-color:rgba(77,141,255,.35); }

  .toolbar { display:grid; grid-template-columns: 1fr auto auto auto; gap:10px; align-items:end; margin-bottom:12px; }
    .toolbar .field { display:flex; flex-direction:column; }
    .toolbar label { font-size:12px; opacity:.8; margin-bottom:4px; }
    .toolbar input[type=text], .toolbar select { padding:10px 12px; border-radius:10px; border:1px solid rgba(255,255,255,.14); background:rgba(0,0,0,.15); color:inherit; min-width:220px; }
    html.theme-light .toolbar input[type=text], html.theme-light .toolbar select, html[data-theme='light'] .toolbar input[type=text], html[data-theme='light'] .toolbar select { background:#fff; border:1px solid rgba(0,0,0,.14); color:#1f242b; }
  /* Improve dropdown list (options) readability in dark and light modes */
  .toolbar select option { background:#0f1b2e; color:#e9eef8; }
  .toolbar select option:hover { background:#16223a; color:#ffffff; }
  .toolbar select option:checked { background:#1e2b4a; color:#ffffff; }
  html.theme-light .toolbar select option, html[data-theme='light'] .toolbar select option { background:#ffffff; color:#1f2530; }
  html.theme-light .toolbar select option:hover, html[data-theme='light'] .toolbar select option:hover { background:#f3f7ff; color:#0b2960; }
  html.theme-light .toolbar select option:checked, html[data-theme='light'] .toolbar select option:checked { background:#e6f0ff; color:#0b2960; }
  

    /* Data table styles */
    .table-wrap { overflow:auto; border-radius:12px; border:1px solid rgba(255,255,255,.08); background:rgba(25,29,37,.32); }
    html.theme-light .table-wrap, html[data-theme='light'] .table-wrap { background:#fff; border:1px solid rgba(0,0,0,.08); }
    table.data-table { width:100%; border-collapse:separate; border-spacing:0; font-size:13px; }
  /* Header row: target both thead th and th directly (GridView may not emit <thead>) */
  table.data-table thead th,
  table.data-table th { position:sticky; top:0; z-index:1; background:linear-gradient(180deg,#0f1628,#0a1324) !important; color:#e9eef8 !important; border-bottom:1px solid rgba(255,255,255,.18) !important; text-align:center; font-size:12px; padding:16px 12px !important; font-weight:800; letter-spacing:.25px; }
  html.theme-light table.data-table thead th, html[data-theme='light'] table.data-table thead th,
  html.theme-light table.data-table th, html[data-theme='light'] table.data-table th { background:#0b63ce !important; color:#ffffff !important; border-bottom:1px solid rgba(0,0,0,.12) !important; }
  /* Make header links inherit text color and remove default link styling */
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
    .avatar { width:36px; height:36px; border-radius:50%; object-fit:cover; border:1px solid rgba(255,255,255,.18); background:rgba(0,0,0,.15); display:block; }
    .avatar-fallback { width:36px; height:36px; border-radius:50%; display:flex; align-items:center; justify-content:center; font-weight:800; background:linear-gradient(135deg,#243b55,#141E30); color:#cfe6ff; border:1px solid rgba(255,255,255,.18); }
    html.theme-light .avatar, html[data-theme='light'] .avatar { border:1px solid rgba(0,0,0,.12); background:#f1f4f7; }
    html.theme-light .avatar-fallback, html[data-theme='light'] .avatar-fallback { background:linear-gradient(135deg,#e3efff,#cfe3ff); color:#214a80; border:1px solid rgba(0,0,0,.12); }
    .cell-main { display:flex; flex-direction:column; gap:2px; align-items:center; }
    .cell-main .name { font-weight:800; }
    .cell-main .sub { font-size:12px; opacity:.8; }
  /* User Profile cell: avatar + name inline */
  .profile-cell { display:flex; align-items:center; gap:8px; justify-content:flex-start; }
  /* Left-align only the User Profile column */
  .col-user-profile { text-align:left !important; }
  .col-user-profile .profile-cell { justify-content:flex-start; }
  .profile-name { font-weight:800; }
    .pill-select { min-width:160px; padding:10px 12px; border-radius:999px; border:1px solid rgba(255,255,255,.18); background:rgba(255,255,255,.09); color:#e9eef8; font-family:inherit; font-size:13px; }
    html.theme-light .pill-select, html[data-theme='light'] .pill-select { background:#fff; border:1px solid rgba(0,0,0,.14); }
    .pill-select:focus { outline:none; box-shadow:0 0 0 3px rgba(77,141,255,.25); border-color:rgba(77,141,255,.5); }
    .pill-select option { background:#0f1b2e; color:#e9eef8; }
    html.theme-light .pill-select option, html[data-theme='light'] .pill-select option { background:#ffffff; color:#1f2530; }
  .tbl-actions { display:flex; gap:6px; justify-content:center; align-items:center; width:100%; }
    .icon-btn { width:32px; height:32px; display:inline-flex; align-items:center; justify-content:center; border-radius:8px; border:1px solid rgba(255,255,255,.18); background:rgba(255,255,255,.06); cursor:pointer; transition:background .2s ease, border-color .2s ease, transform .15s ease, box-shadow .2s ease; line-height:0; vertical-align:middle; }
    .icon-btn:hover { transform:translateY(-1px); box-shadow:0 8px 18px -10px rgba(0,0,0,.6); }
    .icon-btn svg { width:16px; height:16px; display:block; }
    .icon-btn.success { color:#b9f7c0; }
    .icon-btn.success:hover { background:rgba(30,180,90,.18); border-color:rgba(30,180,90,.35); color:#e2ffe6; }
    .icon-btn.danger { color:#ffb3b3; }
    .icon-btn.danger:hover { background:rgba(255,80,80,.18); border-color:rgba(255,80,80,.35); color:#ffd1d1; }
    .icon-btn.disabled { opacity:.55; cursor:not-allowed; filter:grayscale(25%); }
    .pill-select:disabled { opacity:.75; cursor:not-allowed; }
    html.theme-light .btn { border:1px solid rgba(0,0,0,.12); }
    html.theme-light .icon-btn.success, html[data-theme='light'] .icon-btn.success { background:#e8f5ed; border-color:#8fd5a5; color:#1e7f45; }
    html.theme-light .icon-btn.danger, html[data-theme='light'] .icon-btn.danger { background:#fdecec; border-color:#f5b3b3; color:#a32828; }
  /* Sort chevrons */
  table.data-table thead th.sorted-asc::after,
  table.data-table thead th.sorted-desc::after,
  table.data-table th.sorted-asc::after,
  table.data-table th.sorted-desc::after { content:""; display:inline-block; width:0; height:0; border-left:5px solid transparent; border-right:5px solid transparent; margin-left:6px; vertical-align:middle; }
  table.data-table thead th.sorted-asc::after,
  table.data-table th.sorted-asc::after { border-bottom:7px solid currentColor; }
  table.data-table thead th.sorted-desc::after,
  table.data-table th.sorted-desc::after { border-top:7px solid currentColor; }
  /* Status badges */
  .badge { display:inline-flex; align-items:center; gap:6px; padding:6px 10px; border-radius:999px; font-size:12px; font-weight:700; border:1px solid rgba(255,255,255,.18); }
  .badge::before { content:""; width:8px; height:8px; border-radius:50%; display:inline-block; }
  .badge-pending { background:rgba(255,200,80,.14); color:#ffd98a; border-color:rgba(255,200,80,.35); }
  .badge-pending::before { background:#f0b84c; }
  .badge-approved { background:rgba(64,180,120,.16); color:#b9f7c0; border-color:rgba(64,180,120,.35); }
  .badge-approved::before { background:#2bb673; }
  .badge-rejected { background:rgba(255,80,80,.16); color:#ffb3b3; border-color:rgba(255,80,80,.35); }
  .badge-rejected::before { background:#ff5050; }
  html.theme-light .badge, html[data-theme='light'] .badge { border:1px solid rgba(0,0,0,.12); }
  html.theme-light .badge-pending, html[data-theme='light'] .badge-pending { background:#fff5e5; color:#8a5a00; border-color:#f0d199; }
  html.theme-light .badge-approved, html[data-theme='light'] .badge-approved { background:#e8f5ed; color:#1e7f45; border-color:#b2e2c6; }
  html.theme-light .badge-rejected, html[data-theme='light'] .badge-rejected { background:#fdecec; color:#a32828; border-color:#f5b3b3; }

    /* Global toast/banner */
    .global-toast { position:fixed; top:18px; left:50%; transform:translateX(-50%); z-index:9999; display:none; padding:10px 14px; border-radius:12px; font-weight:800; font-size:13px; border:1px solid rgba(255,255,255,.18); backdrop-filter:blur(10px) saturate(140%); box-shadow:0 14px 28px -12px rgba(0,0,0,.55), 0 0 0 1px rgba(255,255,255,.06); }
    .global-toast.success { background:rgba(25,29,37,.75); color:#c8f5d1; border-color:rgba(64,180,120,.35); }
    .global-toast.error { background:rgba(25,29,37,.75); color:#ffcccc; border-color:rgba(255,80,80,.35); }
    html.theme-light .global-toast, html[data-theme='light'] .global-toast { background:#ffffff; color:#1f242b; border:1px solid rgba(0,0,0,.12); }
    html.theme-light .global-toast.success, html[data-theme='light'] .global-toast.success { color:#1e7f45; border-color:#b2e2c6; }
    html.theme-light .global-toast.error, html[data-theme='light'] .global-toast.error { color:#a32828; border-color:#f5b3b3; }

    .pager { display:flex; align-items:center; gap:8px; margin-top:12px; font-size:12px; }
    .pager .btn { padding:6px 10px; font-size:12px; }
    /* Inputs and selects in toolbar consistent font */
    .toolbar input[type=text], .toolbar select { font-family: inherit; font-size:13px; }

    /* Multi-select dropdown styles */
    .multiselect-container { position: relative; display: inline-block; min-width: 160px; }
    .multiselect-display { padding: 10px 12px; border-radius: 999px; border: 1px solid rgba(255,255,255,.18); background: rgba(255,255,255,.09); color: #e9eef8; font-family: inherit; font-size: 13px; cursor: pointer; display: flex; align-items: center; justify-content: space-between; transition: all 0.2s ease; }
    .multiselect-display:hover { background: rgba(255,255,255,.15); border-color: rgba(255,255,255,.25); }
    html.theme-light .multiselect-display, html[data-theme='light'] .multiselect-display { background: #fff; border: 1px solid rgba(0,0,0,.14); color: #1f242b; }
    html.theme-light .multiselect-display:hover, html[data-theme='light'] .multiselect-display:hover { background: #f8fbff; }
    .multiselect-text { flex: 1; text-overflow: ellipsis; overflow: hidden; white-space: nowrap; font-family: inherit; font-size: 13px; line-height: 1.3; min-height: 17px; }
    .multiselect-arrow { margin-left: 8px; transition: transform 0.2s ease; font-size: 12px; opacity: 0.7; width: 0; height: 0; border-left: 4px solid transparent; border-right: 4px solid transparent; border-top: 6px solid currentColor; }
    .multiselect-display.open .multiselect-arrow { transform: rotate(180deg); }
    .multiselect-dropdown { position: fixed !important; z-index: 99999 !important; background: rgba(15,27,46,.98); border: 1px solid rgba(255,255,255,.18); border-radius: 12px; box-shadow: 0 16px 48px -8px rgba(0,0,0,.6), 0 0 0 1px rgba(255,255,255,.05); max-height: 200px; overflow-y: auto; backdrop-filter: blur(16px) saturate(140%); min-width: 160px; top: 0; left: 0; right: auto; bottom: auto; margin: 0; transform: none; }
    html.theme-light .multiselect-dropdown, html[data-theme='light'] .multiselect-dropdown { background: rgba(255,255,255,.98); border: 1px solid rgba(0,0,0,.14); box-shadow: 0 16px 48px -8px rgba(0,0,0,.2), 0 0 0 1px rgba(0,0,0,.05); }
    .multiselect-options { padding: 8px 0; }
    .multiselect-option { display: flex; align-items: center; padding: 8px 12px; cursor: pointer; font-size: 13px; transition: background 0.15s ease; }
    .multiselect-option:hover { background: rgba(255,255,255,.08); }
    html.theme-light .multiselect-option:hover, html[data-theme='light'] .multiselect-option:hover { background: rgba(0,0,0,.04); }
    .multiselect-option input[type="checkbox"] { margin-right: 8px; cursor: pointer; }
    .multiselect-option label { cursor: pointer; flex: 1; font-family: inherit; font-size: 13px; line-height: 1.3; }
    .multiselect-dropdown::-webkit-scrollbar { width: 6px; }
    .multiselect-dropdown::-webkit-scrollbar-track { background: rgba(255,255,255,.05); border-radius: 3px; }
    .multiselect-dropdown::-webkit-scrollbar-thumb { background: rgba(255,255,255,.2); border-radius: 3px; }
    .multiselect-dropdown::-webkit-scrollbar-thumb:hover { background: rgba(255,255,255,.3); }
    html.theme-light .multiselect-dropdown::-webkit-scrollbar-track, html[data-theme='light'] .multiselect-dropdown::-webkit-scrollbar-track { background: rgba(0,0,0,.05); }
    html.theme-light .multiselect-dropdown::-webkit-scrollbar-thumb, html[data-theme='light'] .multiselect-dropdown::-webkit-scrollbar-thumb { background: rgba(0,0,0,.2); }
    html.theme-light .multiselect-dropdown::-webkit-scrollbar-thumb:hover, html[data-theme='light'] .multiselect-dropdown::-webkit-scrollbar-thumb:hover { background: rgba(0,0,0,.3); }
    
    /* Keep table scrolling intact but allow dropdowns to escape */
    .table-wrap { overflow: auto; border-radius: 12px; border: 1px solid rgba(255,255,255,.08); background: rgba(25,29,37,.32); }
    
    /* Multiselect container */
    .multiselect-container { position: relative; display: inline-block; min-width: 160px; }
  </style>
  <script type="text/javascript">
    // Debounced search postback similar to Manage Users
    (function(){
      var t=null;
      window.debouncedFilterReq = function(){
        if(t) window.clearTimeout(t);
        t = window.setTimeout(function(){
          try { __doPostBack('<%= txtSearch.UniqueID %>',''); } catch(e){}
        }, 400);
      };
    })();
  </script>
  <script type="text/javascript">
    // Global toast util (mirrors Manage Users)
    window.showToast = function(message, type){
      try {
        var el = document.getElementById('globalToast');
        if(!el){ el = document.createElement('div'); el.id = 'globalToast'; el.className = 'global-toast'; document.body.appendChild(el); }
        el.textContent = message || '';
        el.className = 'global-toast ' + (type || 'success');
        el.style.display = 'block'; el.style.opacity = '1';
        clearTimeout(window.__toastTimer);
        window.__toastTimer = setTimeout(function(){ el.style.transition = 'opacity .35s ease'; el.style.opacity = '0'; setTimeout(function(){ el.style.display = 'none'; el.style.transition = ''; }, 380); }, 2000);
      } catch(e){}
    };
  </script>
  <script type="text/javascript">
    (function() {
      function showInitials(container){
        if(!container) return;
        var img = container.querySelector('img.avatar');
        var pnl = container.querySelector('.avatar-fallback');
        if(img) img.style.display = 'none';
        if(pnl) pnl.style.display = 'flex';
      }
      function showImage(container){
        if(!container) return;
        var img = container.querySelector('img.avatar');
        var pnl = container.querySelector('.avatar-fallback');
        if(pnl) pnl.style.display = 'none';
        if(img) img.style.display = 'block';
      }
      function wireAvatar(el){
        if(!el) return;
        var img = el.querySelector('img.avatar');
        var pnl = el.querySelector('.avatar-fallback');
        if(!img){ showInitials(el); return; }
        img.addEventListener('error', function(){ showInitials(el); });
        if(img.complete){
          if(img.naturalWidth && img.naturalHeight){ showImage(el); }
          else { showInitials(el); }
        } else {
          img.addEventListener('load', function(){
            if(img.naturalWidth && img.naturalHeight){ showImage(el); }
            else { showInitials(el); }
          });
        }
      }
      function init(){
        var rows = document.querySelectorAll('table.data-table tr');
        for(var i=0;i<rows.length;i++){
          var cell = rows[i].querySelector('td, th');
          // Find any avatar containers in this row
          var containers = rows[i].querySelectorAll('td .avatar, td .avatar-fallback');
          for(var j=0;j<containers.length;j++){
            var parent = containers[j].parentElement;
            if(parent) wireAvatar(parent);
          }
        }
      }
      if(document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init);
      else init();
    })();
  </script>
  <script type="text/javascript">
    // Global variable to track initialization
    window.testLineDropdownsInitialized = false;
    
    // Multi-select dropdown functionality
    function initializeTestLineDropdowns() {
      console.log('Initializing test line dropdowns...');
      console.log('Production lines data:', window.productionLinesData);
      
      var containers = document.querySelectorAll('.multiselect-container');
      console.log('Found', containers.length, 'multiselect containers');
      
      containers.forEach(function(container) {
        var display = container.querySelector('.multiselect-display');
        var dropdown = container.querySelector('.multiselect-dropdown');
        var options = container.querySelector('.multiselect-options');
        var hidden = container.querySelector('.testline-hidden');
        var requestId = display ? display.getAttribute('data-request-id') : 'unknown';
        
        if (!display || !dropdown || !options) {
          console.log('Missing elements for container:', container);
          return;
        }
        
        // IMPORTANT: Move dropdown to body to escape any parent positioning contexts
        if (dropdown.parentElement !== document.body) {
          dropdown.setAttribute('data-container-id', 'container-' + requestId);
          document.body.appendChild(dropdown);
          console.log('Moved dropdown to body for request', requestId);
        }
        
        // Clear existing options
        options.innerHTML = '';
        
        // Populate options if production lines data is available
        if (window.productionLinesData && window.productionLinesData.length > 0) {
          console.log('Populating', window.productionLinesData.length, 'production lines for request', requestId);
          window.productionLinesData.forEach(function(line) {
            var option = document.createElement('div');
            option.className = 'multiselect-option';
            
            var checkbox = document.createElement('input');
            checkbox.type = 'checkbox';
            checkbox.id = 'testline_' + requestId + '_' + line.id;
            checkbox.value = line.id;
            
            var label = document.createElement('label');
            label.setAttribute('for', checkbox.id);
            label.textContent = line.name;
            
            option.appendChild(checkbox);
            option.appendChild(label);
            options.appendChild(option);
            
            // Add change event listener to checkbox
            checkbox.addEventListener('change', function() {
              updateTestLineDisplay(container);
            });
          });
        } else {
          console.log('No production lines data available for request', requestId);
          var noDataDiv = document.createElement('div');
          noDataDiv.className = 'multiselect-option';
          noDataDiv.style.fontStyle = 'italic';
          noDataDiv.style.opacity = '0.7';
          noDataDiv.textContent = 'No test lines available';
          options.appendChild(noDataDiv);
        }
        
        // Only add click handler if it doesn't already exist
        if (!display.hasAttribute('data-handler-added')) {
          display.setAttribute('data-handler-added', 'true');
          
          // Click handler for display
          display.addEventListener('click', function(e) {
            e.preventDefault();
            e.stopPropagation();
            
            // Find the dropdown (it's now in the body)
            var dropdown = document.querySelector('.multiselect-dropdown[data-container-id="container-' + requestId + '"]');
            if (!dropdown) {
              console.error('Could not find dropdown for request', requestId);
              return;
            }
            
            // Close all other dropdowns
            document.querySelectorAll('.multiselect-dropdown').forEach(function(dd) {
              if (dd !== dropdown) {
                dd.style.display = 'none';
                var otherDisplay = document.querySelector('.multiselect-display[data-request-id="' + dd.getAttribute('data-container-id').replace('container-', '') + '"]');
                if (otherDisplay) otherDisplay.classList.remove('open');
              }
            });
            
            // Toggle this dropdown
            if (dropdown.style.display === 'none' || !dropdown.style.display) {
              // Position dropdown immediately
              var displayRect = display.getBoundingClientRect();
              
              console.log('Display element getBoundingClientRect:', {
                top: displayRect.top,
                bottom: displayRect.bottom,
                left: displayRect.left,
                right: displayRect.right,
                width: displayRect.width,
                height: displayRect.height
              });
              
              var viewportHeight = window.innerHeight || document.documentElement.clientHeight;
              var viewportWidth = window.innerWidth || document.documentElement.clientWidth;
              var dropdownHeight = 200; // max-height from CSS
              
              // Calculate if dropdown should appear above or below
              var spaceBelow = viewportHeight - displayRect.bottom;
              var spaceAbove = displayRect.top;
              
              console.log('Space calculations:', {
                spaceBelow: spaceBelow,
                spaceAbove: spaceAbove,
                viewportHeight: viewportHeight,
                viewportWidth: viewportWidth
              });
              
              var top, left;
              
              if (spaceBelow >= 100 || spaceBelow >= spaceAbove) {
                // Show below
                top = displayRect.bottom + 4;
                console.log('Positioning below at', top);
              } else {
                // Show above
                top = displayRect.top - Math.min(dropdownHeight, spaceAbove - 10) - 4;
                console.log('Positioning above at', top);
              }
              
              // Position horizontally aligned with the display element
              left = displayRect.left;
              var dropdownWidth = displayRect.width;
              
              console.log('Final position before adjustments:', { top: top, left: left, width: dropdownWidth });
              
              // Ensure dropdown doesn't go off screen
              if (left + dropdownWidth > viewportWidth - 10) {
                left = viewportWidth - dropdownWidth - 10;
              }
              if (left < 10) {
                left = 10;
              }
              if (top < 10) {
                top = 10;
              }
              if (top + dropdownHeight > viewportHeight - 10) {
                top = viewportHeight - dropdownHeight - 10;
              }
              
              // Set position before showing
              dropdown.style.top = Math.round(top) + 'px';
              dropdown.style.left = Math.round(left) + 'px';
              dropdown.style.width = Math.round(dropdownWidth) + 'px';
              dropdown.style.position = 'fixed';
              dropdown.style.right = 'auto';
              dropdown.style.bottom = 'auto';
              dropdown.style.transform = 'none';
              dropdown.style.margin = '0';
              
              // Now show the dropdown
              dropdown.style.display = 'block';
              display.classList.add('open');
              
              console.log('Final applied position:', {
                top: dropdown.style.top,
                left: dropdown.style.left,
                width: dropdown.style.width,
                position: dropdown.style.position
              });
              
              // Double-check after a moment
              setTimeout(function() {
                var actualRect = dropdown.getBoundingClientRect();
                console.log('Dropdown actual position after render:', {
                  top: actualRect.top,
                  left: actualRect.left,
                  width: actualRect.width,
                  expectedTop: top,
                  expectedLeft: left
                });
                
                if (Math.abs(actualRect.top - top) > 5 || Math.abs(actualRect.left - left) > 5) {
                  console.error('POSITION MISMATCH! Dropdown moved after positioning!');
                  console.log('Computed styles:', window.getComputedStyle(dropdown));
                }
              }, 50);
            } else {
              dropdown.style.display = 'none';
              display.classList.remove('open');
            }
          });
        }
      });
      
      // Close dropdowns when clicking outside
      document.addEventListener('click', function(e) {
        if (!e.target.closest('.multiselect-container')) {
          document.querySelectorAll('.multiselect-dropdown').forEach(function(dropdown) {
            dropdown.style.display = 'none';
            var display = dropdown.parentElement.querySelector('.multiselect-display');
            if (display) display.classList.remove('open');
          });
        }
      });
      
      // Close dropdowns on window resize or scroll
      window.addEventListener('resize', function() {
        document.querySelectorAll('.multiselect-dropdown').forEach(function(dropdown) {
          dropdown.style.display = 'none';
          var display = dropdown.parentElement.querySelector('.multiselect-display');
          if (display) display.classList.remove('open');
        });
      });
      
      window.addEventListener('scroll', function() {
        document.querySelectorAll('.multiselect-dropdown').forEach(function(dropdown) {
          dropdown.style.display = 'none';
          var display = dropdown.parentElement.querySelector('.multiselect-display');
          if (display) display.classList.remove('open');
        });
      });
      
      window.testLineDropdownsInitialized = true;
      console.log('Test line dropdowns initialized successfully');
    }
    
    function updateTestLineDisplay(container) {
      var display = container.querySelector('.multiselect-display');
      var textSpan = container.querySelector('.multiselect-text');
      var hidden = container.querySelector('.testline-hidden');
      var requestId = display ? display.getAttribute('data-request-id') : null;
      
      // Find dropdown from body (it's been moved there)
      var dropdown = requestId ? document.querySelector('.multiselect-dropdown[data-container-id="container-' + requestId + '"]') : null;
      if (!dropdown) {
        console.error('Could not find dropdown in updateTestLineDisplay');
        return;
      }
      
      var checkboxes = dropdown.querySelectorAll('input[type="checkbox"]:checked');
      
      var selectedIds = [];
      var selectedNames = [];
      
      checkboxes.forEach(function(cb) {
        selectedIds.push(cb.value);
        var label = cb.nextElementSibling;
        if (label) selectedNames.push(label.textContent);
      });
      
      // Update hidden field with comma-separated IDs
      if (hidden) {
        hidden.value = selectedIds.join(',');
      }
      
      // Update display text
      if (selectedNames.length === 0) {
        textSpan.textContent = '';
      } else if (selectedNames.length <= 3) {
        textSpan.textContent = selectedNames.join(', ');
      } else {
        textSpan.textContent = selectedNames.length + ' items selected';
      }
      
      // Add tooltip for long text
      textSpan.title = selectedNames.length > 0 ? selectedNames.join(', ') : '';
      
      // Update selected state appearance
      if (selectedNames.length > 0) {
        display.style.background = 'rgba(77,141,255,.15)';
        display.style.borderColor = 'rgba(77,141,255,.35)';
      } else {
        display.style.background = '';
        display.style.borderColor = '';
      }
    }
    
    // Initialize with delay to ensure data is loaded
    function initWithDelay() {
      console.log('Attempting to initialize test line dropdowns...');
      if (!window.productionLinesData) {
        console.log('Production lines data not available, initializing empty array');
        window.productionLinesData = [];
      }
      
      // Wait a bit more if data is still loading
      if (window.productionLinesData.length === 0) {
        console.log('No production lines data found, will retry...');
        setTimeout(function() {
          if (!window.testLineDropdownsInitialized) {
            initializeTestLineDropdowns();
          }
        }, 500);
      } else {
        initializeTestLineDropdowns();
      }
    }
    
    // Initialize dropdowns when page loads
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', initWithDelay);
    } else {
      initWithDelay();
    }
    
    // Re-initialize after postbacks
    setTimeout(function() {
      try {
        if (typeof Sys !== 'undefined' && Sys.WebForms && Sys.WebForms.PageRequestManager) {
          var prm = Sys.WebForms.PageRequestManager.getInstance();
          if (prm) {
            prm.add_endRequest(function() {
              window.testLineDropdownsInitialized = false;
              setTimeout(initWithDelay, 200);
            });
          }
        }
      } catch (e) {
        console.log('ScriptManager not available for postback handling:', e);
      }
    }, 100);
  </script>
</asp:Content>
<asp:Content ID="MainC" ContentPlaceHolderID="MainContent" runat="server">
  <div class="admin-grid">
    <uc2:AdminSidebar ID="AdminSidebar1" runat="server" />
    <div>
      <uc1:AdminHeader ID="AdminHeader1" runat="server" Title="Pending Requests" />
      <!-- Toast mount point; JS will create if missing -->
      <div id="globalToast" class="global-toast" style="display:none"></div>
      <div class="admin-container">

    <div class="toolbar">
      <div class="field">
        <label>Search</label>
        <asp:TextBox ID="txtSearch" runat="server" placeholder="Name, E-Number, Email, Department, Role" AutoPostBack="True" OnTextChanged="txtSearch_TextChanged" oninput="debouncedFilterReq()" />
      </div>
      <div class="field">
        <label>Status</label>
        <asp:DropDownList ID="ddlStatus" runat="server" AutoPostBack="True" OnSelectedIndexChanged="ddlStatus_SelectedIndexChanged">
          <asp:ListItem Selected="True">Pending</asp:ListItem>
          <asp:ListItem>Approved</asp:ListItem>
          <asp:ListItem>Rejected</asp:ListItem>
          <asp:ListItem>All</asp:ListItem>
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
      <asp:GridView ID="gridRequests" runat="server" AutoGenerateColumns="False" CssClass="data-table" OnRowCommand="gridRequests_RowCommand" OnRowDataBound="gridRequests_RowDataBound" OnSorting="gridRequests_Sorting" OnRowCreated="gridRequests_RowCreated" AllowSorting="True" GridLines="None" CellPadding="0">
        <Columns>
          <asp:TemplateField HeaderText="User Profile" SortExpression="FullName">
            <HeaderStyle CssClass="col-user-profile" />
            <ItemStyle CssClass="col-user-profile" />
            <ItemTemplate>
              <div class="profile-cell">
                <asp:Image ID="imgAvatar" runat="server" CssClass="avatar" AlternateText="avatar" ImageUrl='<%# Eval("ProfileThumbUrl") %>' Style="display:none;" />
                <asp:Panel ID="pnlInitials" runat="server" CssClass="avatar-fallback" Style="display:flex;">
                  <asp:Literal ID="litInitials" runat="server" />
                </asp:Panel>
                <span class="profile-name"><%# Eval("FullName") %></span>
              </div>
            </ItemTemplate>
          </asp:TemplateField>
          <asp:BoundField HeaderText="E Number" DataField="ENumber" SortExpression="ENumber" />
          <asp:BoundField HeaderText="Email" DataField="Email" SortExpression="Email" />
          <asp:TemplateField HeaderText="Department" SortExpression="Department">
            <ItemTemplate>
              <asp:DropDownList ID="ddlDepartment" runat="server" CssClass="pill-select">
                <asp:ListItem>Test Engineering</asp:ListItem>
                <asp:ListItem>Manufacturing</asp:ListItem>
                <asp:ListItem>Quality</asp:ListItem>
                <asp:ListItem>Supply Chain</asp:ListItem>
                <asp:ListItem>IT</asp:ListItem>
                <asp:ListItem>Other</asp:ListItem>
              </asp:DropDownList>
            </ItemTemplate>
          </asp:TemplateField>
          <asp:TemplateField HeaderText="Job Role" SortExpression="JobRole">
            <ItemTemplate>
              <asp:DropDownList ID="ddlJobRole" runat="server" CssClass="pill-select">
                <asp:ListItem>Engineer</asp:ListItem>
                <asp:ListItem>Technician</asp:ListItem>
                <asp:ListItem>Tester</asp:ListItem>
                <asp:ListItem>Manager</asp:ListItem>
                <asp:ListItem>Supervisor</asp:ListItem>
                <asp:ListItem>Analyst</asp:ListItem>
                <asp:ListItem>Other</asp:ListItem>
              </asp:DropDownList>
            </ItemTemplate>
          </asp:TemplateField>
          <asp:TemplateField HeaderText="User Category">
            <ItemTemplate>
              <asp:DropDownList ID="ddlAssignRole" runat="server" CssClass="pill-select">
                <asp:ListItem>Admin</asp:ListItem>
                <asp:ListItem>Test Engineering</asp:ListItem>
                <asp:ListItem>Quality</asp:ListItem>
                <asp:ListItem>Tester</asp:ListItem>
                <asp:ListItem>Viewer</asp:ListItem>
              </asp:DropDownList>
            </ItemTemplate>
          </asp:TemplateField>
          <asp:TemplateField HeaderText="Test Line">
            <ItemTemplate>
              <div class="multiselect-container">
                <div class="multiselect-display" data-request-id='<%# Eval("RequestID") %>'>
                  <span class="multiselect-text"></span>
                  <span class="multiselect-arrow"></span>
                </div>
                <div class="multiselect-dropdown" style="display:none;">
                  <div class="multiselect-options">
                    <!-- Options populated by JavaScript -->
                  </div>
                </div>
                <input type="hidden" class="testline-hidden" name='<%# "hiddenTestLine_" + Eval("RequestID") %>' value="" />
              </div>
            </ItemTemplate>
          </asp:TemplateField>
          <asp:BoundField HeaderText="Submitted" DataField="SubmittedAt" DataFormatString="{0:yyyy-MM-dd HH:mm}" SortExpression="SubmittedAt" />
          <asp:TemplateField HeaderText="Status" SortExpression="Status">
            <ItemTemplate>
              <asp:Literal ID="litStatus" runat="server" />
            </ItemTemplate>
          </asp:TemplateField>
          <asp:TemplateField HeaderText="Actions">
            <ItemTemplate>
              <div class="tbl-actions">
                <asp:LinkButton ID="btnApprove" runat="server" CssClass="icon-btn success" CommandName="Approve" CommandArgument='<%# Eval("RequestID") %>' ToolTip="Approve &amp; Create">
                  <span aria-hidden="true">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 6L9 17l-5-5"/></svg>
                  </span>
                </asp:LinkButton>
                <asp:LinkButton ID="btnReject" runat="server" CssClass="icon-btn danger" CommandName="Reject" CommandArgument='<%# Eval("RequestID") %>' ToolTip="Reject">
                  <span aria-hidden="true">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
                  </span>
                </asp:LinkButton>
              </div>
            </ItemTemplate>
          </asp:TemplateField>
        </Columns>
      </asp:GridView>
    </div>
    <div class="pager">
      <asp:Button ID="btnPrev" runat="server" Text="Prev" CssClass="btn" OnClick="btnPrev_Click" />
      <asp:Label ID="lblPage" runat="server" />
      <asp:Button ID="btnNext" runat="server" Text="Next" CssClass="btn" OnClick="btnNext_Click" />
      <asp:Label ID="lblTotal" runat="server" />
    </div>
      </div>
    </div>
  </div>
</asp:Content>
