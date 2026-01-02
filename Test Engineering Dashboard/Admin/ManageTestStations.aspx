<%@ Page Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="ManageTestStations.aspx.cs" Inherits="TED_Admin_ManageTestStations" %>
<%@ Register Src="~/Admin/Controls/AdminHeader.ascx" TagPrefix="uc1" TagName="AdminHeader" %>
<%@ Register Src="~/Admin/Controls/AdminSidebar.ascx" TagPrefix="uc2" TagName="AdminSidebar" %>
<asp:Content ID="TitleC" ContentPlaceHolderID="TitleContent" runat="server">Test Station / Bay DB - Admin</asp:Content>
<asp:Content ID="HeadC" ContentPlaceHolderID="HeadContent" runat="server">
  <style>
  /* Admin shell is defined in AdminSidebar control */
  .admin-grid > div { min-width: 0; min-height:0; }
  .admin-container { background:rgba(25,29,37,.46); border:1px solid rgba(255,255,255,.08); border-radius:16px; box-shadow:0 16px 34px -12px rgba(0,0,0,.6), 0 0 0 1px rgba(255,255,255,.05); backdrop-filter:blur(24px) saturate(140%); padding:16px; flex:1; min-height:0; overflow-y:auto; overflow-x:hidden; }
    html.theme-light .admin-container, html[data-theme='light'] .admin-container { background:#ffffff; border:1px solid rgba(0,0,0,.08); box-shadow:0 16px 34px -12px rgba(0,0,0,.16), 0 0 0 1px rgba(0,0,0,.05); }
  .toolbar { display:grid; grid-template-columns: 1fr auto auto auto auto; gap:10px; align-items:end; margin-bottom:12px; }
    .toolbar .field { display:flex; flex-direction:column; }
    .toolbar label { font-size:12px; opacity:.8; margin-bottom:4px; font-weight:bold; }
    .toolbar input[type=text], .toolbar select { padding:10px 12px; border-radius:10px; border:1px solid rgba(255,255,255,.14); background:rgba(0,0,0,.15); color:inherit; min-width:220px; font-family:inherit; font-size:13px; }
    html.theme-light .toolbar input[type=text], html.theme-light .toolbar select, html[data-theme='light'] .toolbar input[type=text], html[data-theme='light'] .toolbar select { background:#fff; border:1px solid rgba(0,0,0,.14); color:#1f242b; }
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
  @media (max-width: 1200px) { .toolbar { grid-template-columns: 1fr 1fr; } }
    @media (max-width: 820px) { .toolbar { grid-template-columns: 1fr; } }
  .table-wrap { width:100%; max-width:100%; overflow-x:auto; overflow-y:auto; max-height:calc(100vh - 280px); border-radius:12px; border:1px solid rgba(255,255,255,.08); background:rgba(25,29,37,.32); box-sizing:border-box; }
    html.theme-light .table-wrap, html[data-theme='light'] .table-wrap { background:#fff; border:1px solid rgba(0,0,0,.08); }
  table.data-table { width:100%; min-width:1600px; border-collapse:separate; border-spacing:0; font-size:11.5px; }
  table.data-table th:nth-child(1), table.data-table td:nth-child(1) { min-width:80px; text-align:center; }
  table.data-table th:nth-child(2), table.data-table td:nth-child(2) { min-width:280px; text-align:center; }
  table.data-table th:nth-child(3), table.data-table td:nth-child(3) { min-width:220px; text-align:center; }
  table.data-table th:nth-child(4), table.data-table td:nth-child(4) { min-width:380px; text-align:center; }
  table.data-table th:nth-child(5), table.data-table td:nth-child(5) { min-width:160px; text-align:center; }
  table.data-table th:nth-child(6), table.data-table td:nth-child(6) { min-width:200px; text-align:center; }
  table.data-table th:nth-child(7), table.data-table td:nth-child(7) { min-width:160px; text-align:center; }
  table.data-table th:nth-child(8), table.data-table td:nth-child(8) { min-width:150px; text-align:center; }
    table.data-table thead th,
    table.data-table th { position:sticky; top:0; z-index:1; background:#0b63ce !important; color:#ffffff !important; border-bottom:1px solid rgba(0,0,0,.12) !important; text-align:center; font-size:12px; padding:16px 12px !important; font-weight:800; letter-spacing:.25px; }
    html:not(.theme-light):not([data-theme='light']) table.data-table thead th,
    html:not(.theme-light):not([data-theme='light']) table.data-table th { background:linear-gradient(180deg,#0f1628,#0a1324) !important; color:#e9eef8 !important; border-bottom:1px solid rgba(255,255,255,.18) !important; }
    table.data-table tbody td { padding:14px 16px; border-bottom:1px solid rgba(255,255,255,.07); vertical-align:middle; text-align:center; }
    html.theme-light table.data-table tbody td, html[data-theme='light'] table.data-table tbody td { border-bottom:1px solid rgba(0,0,0,.06); }
    table.data-table tbody tr:nth-child(odd) { background:rgba(255,255,255,.015); }
    html.theme-light table.data-table tbody tr:nth-child(odd) { background:#fafbfe; }
    table.data-table tbody tr:hover { background:rgba(255,255,255,.04); }
    html.theme-light table.data-table tbody tr:hover, html[data-theme='light'] table.data-table tbody tr:hover { background:#fafcff; }
    .tbl-actions { display:flex; gap:6px; justify-content:center; align-items:center; width:100%; }
    .inline-input { width:100%; padding:8px 10px; border-radius:10px; border:1px solid rgba(255,255,255,.18); background:rgba(0,0,0,.12); color:inherit; font:inherit; font-size:13px; box-sizing:border-box; }
    .inline-select { width:100%; padding:8px 10px; border-radius:10px; border:1px solid rgba(255,255,255,.18); background:rgba(0,0,0,.12); color:inherit; font:inherit; font-size:13px; box-sizing:border-box; }
  .inline-select option { background:#0f1b2e; color:#e9eef8; }
  .inline-select option:hover { background:#16223a; color:#ffffff; }
  .inline-select option:checked { background:#1e2b4a; color:#ffffff; }
  html.theme-light .inline-select option, html[data-theme='light'] .inline-select option { background:#ffffff; color:#1f2530; }
  html.theme-light .inline-select option:hover, html[data-theme='light'] .inline-select option:hover { background:#f3f7ff; color:#0b2960; }
  html.theme-light .inline-select option:checked, html[data-theme='light'] .inline-select option:checked { background:#e6f0ff; color:#0b2960; }
    html.theme-light .inline-input, html[data-theme='light'] .inline-input, html.theme-light .inline-select, html[data-theme='light'] .inline-select { background:#fff; border:1px solid rgba(0,0,0,.14); color:#1f242b; }
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
    
    .save-btn { width:34px; height:34px; display:inline-flex; align-items:center; justify-content:center; border-radius:8px; border:1px solid rgba(255,255,255,.18); background:rgba(30,180,90,.18); color:#e2ffe6; cursor:pointer; transition:all .2s ease; }
    .save-btn:hover { transform:translateY(-1px); box-shadow:0 8px 18px -10px rgba(0,0,0,.6); }
    html.theme-light .save-btn, html[data-theme='light'] .save-btn { border:1px solid rgba(0,0,0,.12); background:#e8f5ed; color:#1e7f45; }
    .save-btn svg { width:16px; height:16px; display:block; }
    .delete-btn { width:34px; height:34px; display:inline-flex; align-items:center; justify-content:center; border-radius:8px; border:1px solid rgba(255,255,255,.18); background:rgba(255,80,80,.16); color:#ffd1d1; cursor:pointer; transition:all .2s ease; }
    .delete-btn:hover { transform:translateY(-1px); box-shadow:0 8px 18px -10px rgba(0,0,0,.6); }
    html.theme-light .delete-btn, html[data-theme='light'] .delete-btn { border:1px solid rgba(0,0,0,.12); background:#fdecec; color:#a32828; }
    .delete-btn svg { width:16px; height:16px; display:block; }
  .row-msg { display:inline-flex; align-items:center; gap:6px; margin-left:8px; padding:6px 10px; border-radius:999px; font-size:11px; font-weight:700; border:1px solid transparent; }
  .row-msg.success { background:rgba(64,180,120,.16); color:#b9f7c0; border-color:rgba(64,180,120,.35); }
  .row-msg.error { background:rgba(255,80,80,.16); color:#ffb3b3; border-color:rgba(255,80,80,.35); }
  html.theme-light .row-msg.success, html[data-theme='light'] .row-msg.success { background:#e8f5ed; color:#1e7f45; border-color:#b2e2c6; }
  html.theme-light .row-msg.error, html[data-theme='light'] .row-msg.error { background:#fdecec; color:#a32828; border-color:#f5b3b3; }
  .global-toast { position:fixed; top:18px; left:50%; transform:translateX(-50%); z-index:9999; display:none; padding:10px 14px; border-radius:12px; font-weight:800; font-size:13px; border:1px solid rgba(255,255,255,.18); backdrop-filter:blur(10px) saturate(140%); box-shadow:0 14px 28px -12px rgba(0,0,0,.55), 0 0 0 1px rgba(255,255,255,.06); }
  .global-toast.success { background:rgba(25,29,37,.75); color:#c8f5d1; border-color:rgba(64,180,120,.35); }
  .global-toast.error { background:rgba(25,29,37,.75); color:#ffcccc; border-color:rgba(255,80,80,.35); }
  html.theme-light .global-toast, html[data-theme='light'] .global-toast { background:#ffffff; color:#1f242b; border:1px solid rgba(0,0,0,.12); }
  html.theme-light .global-toast.success, html[data-theme='light'] .global-toast.success { color:#1e7f45; border-color:#b2e2c6; }
  html.theme-light .global-toast.error, html[data-theme='light'] .global-toast.error { color:#a32828; border-color:#f5b3b3; }
  </style>
  <script>
    function showToast(msg, type) {
      var toast = document.getElementById('globalToast');
      if (!toast) return;
      toast.textContent = msg;
      toast.className = 'global-toast ' + type;
      toast.style.display = 'block';
      setTimeout(function() { toast.style.display = 'none'; }, 4000);
    }

    function showRowMsg(rowId, msg, type) {
      var row = document.getElementById(rowId);
      if (!row) return;
      var existing = row.querySelector('.row-msg');
      if (existing) existing.remove();
      var msgEl = document.createElement('span');
      msgEl.className = 'row-msg ' + type;
      msgEl.textContent = msg;
      var actionsCell = row.querySelector('.tbl-actions');
      if (actionsCell) actionsCell.appendChild(msgEl);
      setTimeout(function() { msgEl.remove(); }, 3000);
    }

    function confirmDelete() {
      return confirm('Are you sure you want to delete this test station?');
    }

    function updateStationName(selectEl) {
      var stationId = selectEl.getAttribute('data-stationid');
      if (!stationId) return;
      
      var subLineSelect = document.getElementById('subLine_' + stationId);
      var testTypeSelect = document.getElementById('testType_' + stationId);
      var stationNameInput = document.getElementById('stationName_' + stationId);
      
      if (!subLineSelect || !testTypeSelect || !stationNameInput) return;
      
      var selectedSubLineOption = subLineSelect.options[subLineSelect.selectedIndex];
      var subLineCode = selectedSubLineOption ? selectedSubLineOption.getAttribute('data-sublinecode') : '';
      var testType = testTypeSelect.value;
      
      if (subLineCode && testType) {
        stationNameInput.value = subLineCode + ' - ' + testType;
      } else {
        stationNameInput.value = '';
      }
    }
  </script>
</asp:Content>
<asp:Content ID="MainC" ContentPlaceHolderID="MainContent" runat="server">
  <div class="admin-grid">
    <uc2:AdminSidebar ID="AdminSidebar1" runat="server" />
    <div class="admin-container">
      <uc1:AdminHeader ID="AdminHeader1" runat="server" Title="Test Station / Bay Database" />
      <div id="globalToast" class="global-toast"></div>

      <div class="toolbar">
        <div class="field">
          <label>Search</label>
          <asp:TextBox ID="txtSearch" runat="server" placeholder="Name, Sub Line, Test Type" AutoPostBack="True" OnTextChanged="txtSearch_TextChanged" />
        </div>
        <div class="field">
          <label>Sub Line Code</label>
          <asp:DropDownList ID="ddlSubLineFilter" runat="server" AutoPostBack="True" OnSelectedIndexChanged="ddlSubLineFilter_SelectedIndexChanged">
            <asp:ListItem Value="">All Sub Lines</asp:ListItem>
          </asp:DropDownList>
        </div>
        <div class="field">
          <label>Test Type</label>
          <asp:DropDownList ID="ddlTestTypeFilter" runat="server" AutoPostBack="True" OnSelectedIndexChanged="ddlTestTypeFilter_SelectedIndexChanged">
            <asp:ListItem Value="">All Test Types</asp:ListItem>
          </asp:DropDownList>
        </div>
        <div class="field">
          <label>Sort by</label>
          <asp:DropDownList ID="ddlSort" runat="server" AutoPostBack="True" OnSelectedIndexChanged="ddlSort_SelectedIndexChanged">
            <asp:ListItem Value="id_desc" Selected="True">ID Descending</asp:ListItem>
            <asp:ListItem Value="id_asc">ID Ascending</asp:ListItem>
            <asp:ListItem Value="name">Name</asp:ListItem>
            <asp:ListItem Value="created">Created</asp:ListItem>
          </asp:DropDownList>
        </div>
        <div class="field">
          <label>Page size</label>
          <asp:DropDownList ID="ddlPageSize" runat="server" AutoPostBack="True" OnSelectedIndexChanged="ddlPageSize_SelectedIndexChanged">
            <asp:ListItem Value="10">10</asp:ListItem>
            <asp:ListItem Value="25">25</asp:ListItem>
            <asp:ListItem Value="50">50</asp:ListItem>
            <asp:ListItem Value="100">100</asp:ListItem>
          </asp:DropDownList>
        </div>
      </div>

      <div class="table-wrap">
        <asp:Repeater ID="rptStations" runat="server" OnItemCommand="rptStations_ItemCommand">
          <HeaderTemplate>
            <table class="data-table">
              <thead>
                <tr>
                  <th>Station ID</th>
                  <th>Sub Line Code</th>
                  <th>Test Type</th>
                  <th>Test Station Name</th>
                  <th>Requires Red Badge</th>
                  <th>Red Badge Level</th>
                  <th>Requires PreFlight</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
          </HeaderTemplate>
          <ItemTemplate>
            <tr id='row_<%# Eval("TestStationID") %>' data-stationid='<%# Eval("TestStationID") %>'>
              <td><input type="text" class="inline-input" value='<%# Eval("TestStationID") %>' disabled /></td>
              <td>
                <select class="inline-select" id='subLine_<%# Eval("TestStationID") %>' name='subLine_<%# Eval("TestStationID") %>' data-stationid='<%# Eval("TestStationID") %>' onchange="updateStationName(this)">
                  <option value="" data-sublinecode="" <%# string.IsNullOrEmpty(Eval("SubLineCellID") as string) || Eval("SubLineCellID").ToString() == "0" ? "selected" : "" %>></option>
                  <asp:Repeater ID="rptSubLines" runat="server" DataSource='<%# GetSubLines() %>'>
                    <ItemTemplate>
                      <option value='<%# Eval("SubLineCellID") %>' data-sublinecode='<%# Eval("SubLineCode") %>' <%# Container.Parent.Parent is RepeaterItem && Eval("SubLineCellID").ToString() == DataBinder.Eval(((RepeaterItem)Container.Parent.Parent).DataItem, "SubLineCellID").ToString() ? "selected" : "" %>><%# Eval("SubLineCode") %></option>
                    </ItemTemplate>
                  </asp:Repeater>
                </select>
              </td>
              <td>
                <select class="inline-select" id='testType_<%# Eval("TestStationID") %>' name='testType_<%# Eval("TestStationID") %>' data-stationid='<%# Eval("TestStationID") %>' onchange="updateStationName(this)">
                  <option value="" <%# string.IsNullOrEmpty(Eval("TestType") as string) ? "selected" : "" %>></option>
                  <asp:Repeater ID="rptStationTypes" runat="server" DataSource='<%# GetStationTypes() %>'>
                    <ItemTemplate>
                      <option value='<%# Eval("StationType") %>' <%# Container.Parent.Parent is RepeaterItem && Eval("StationType").ToString() == (DataBinder.Eval(((RepeaterItem)Container.Parent.Parent).DataItem, "TestType") ?? "").ToString() ? "selected" : "" %>><%# Eval("StationType") %></option>
                    </ItemTemplate>
                  </asp:Repeater>
                </select>
              </td>
              <td><input type="text" class="inline-input" id='stationName_<%# Eval("TestStationID") %>' name='stationName_<%# Eval("TestStationID") %>' value='<%# Eval("TestStationName") %>' readonly /></td>
              <td>
                <div class="toggle-wrapper">
                  <label class="toggle-switch">
                    <input type="checkbox" id='requiresBadge_<%# Eval("TestStationID") %>' name='requiresBadge_<%# Eval("TestStationID") %>' <%# Eval("RequiresRedBadge") != DBNull.Value && Convert.ToBoolean(Eval("RequiresRedBadge")) ? "checked" : "" %> />
                    <span class="toggle-slider"></span>
                  </label>
                </div>
              </td>
              <td>
                <select class="inline-select" id='badgeLevel_<%# Eval("TestStationID") %>' name='badgeLevel_<%# Eval("TestStationID") %>'>
                  <option value="" <%# string.IsNullOrEmpty(Eval("RedBadgeLevel") as string) ? "selected" : "" %>></option>
                  <option value="Level 3" <%# Eval("RedBadgeLevel") as string == "Level 3" ? "selected" : "" %>>Level 3</option>
                  <option value="Level 2 - Battery" <%# Eval("RedBadgeLevel") as string == "Level 2 - Battery" ? "selected" : "" %>>Level 2 - Battery</option>
                  <option value="Level 2 - Test" <%# Eval("RedBadgeLevel") as string == "Level 2 - Test" ? "selected" : "" %>>Level 2 - Test</option>
                </select>
              </td>
              <td>
                <div class="toggle-wrapper">
                  <label class="toggle-switch">
                    <input type="checkbox" id='requiresPreFlight_<%# Eval("TestStationID") %>' name='requiresPreFlight_<%# Eval("TestStationID") %>' <%# Eval("RequiresPreFlight") != DBNull.Value && Convert.ToBoolean(Eval("RequiresPreFlight")) ? "checked" : "" %> />
                    <span class="toggle-slider"></span>
                  </label>
                </div>
              </td>
              <td>
                <div class="tbl-actions">
                  <asp:LinkButton runat="server" CommandName="Save" CommandArgument='<%# Eval("TestStationID") %>' CssClass="save-btn" ToolTip="Save changes" OnClientClick='<%# "showRowMsg(\"row_" + Eval("TestStationID") + "\", \"Saving...\", \"success\"); return true;" %>'>
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/><polyline points="17 21 17 13 7 13 7 21"/><polyline points="7 3 7 8 15 8"/></svg>
                  </asp:LinkButton>
                  <asp:LinkButton runat="server" CommandName="Delete" CommandArgument='<%# Eval("TestStationID") %>' CssClass="delete-btn" ToolTip="Delete station" OnClientClick="return confirmDelete();">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
                  </asp:LinkButton>
                </div>
              </td>
            </tr>
          </ItemTemplate>
          <FooterTemplate>
              </tbody>
            </table>
          </FooterTemplate>
        </asp:Repeater>
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
</asp:Content>
