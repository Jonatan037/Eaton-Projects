<%@ Page Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="ManageSubLines.aspx.cs" Inherits="TED_Admin_ManageSubLines" %>
<%@ Register Src="~/Admin/Controls/AdminHeader.ascx" TagPrefix="uc1" TagName="AdminHeader" %>
<%@ Register Src="~/Admin/Controls/AdminSidebar.ascx" TagPrefix="uc2" TagName="AdminSidebar" %>
<asp:Content ID="TitleC" ContentPlaceHolderID="TitleContent" runat="server">Sub-Line / Cell DB - Admin</asp:Content>
<asp:Content ID="HeadC" ContentPlaceHolderID="HeadContent" runat="server">
  <style>
  /* Admin shell is defined in AdminSidebar control */
  .admin-grid > div { min-width: 0; min-height:0; }
  .admin-container { background:rgba(25,29,37,.46); border:1px solid rgba(255,255,255,.08); border-radius:16px; box-shadow:0 16px 34px -12px rgba(0,0,0,.6), 0 0 0 1px rgba(255,255,255,.05); backdrop-filter:blur(24px) saturate(140%); padding:16px; flex:1; min-height:0; overflow-y:auto; overflow-x:hidden; }
    html.theme-light .admin-container, html[data-theme='light'] .admin-container { background:#ffffff; border:1px solid rgba(0,0,0,.08); box-shadow:0 16px 34px -12px rgba(0,0,0,.16), 0 0 0 1px rgba(0,0,0,.05); }
  .toolbar { display:grid; grid-template-columns: 1fr auto auto auto; gap:10px; align-items:end; margin-bottom:12px; }
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
  .table-wrap { width:100%; max-width:100%; overflow-x:auto; overflow-y:hidden; border-radius:12px; border:1px solid rgba(255,255,255,.08); background:rgba(25,29,37,.32); box-sizing:border-box; max-height:calc(100vh - 280px); overflow-y:auto; }
    html.theme-light .table-wrap, html[data-theme='light'] .table-wrap { background:#fff; border:1px solid rgba(0,0,0,.08); }
  table.data-table { width:100%; min-width:1200px; border-collapse:separate; border-spacing:0; font-size:11.5px; }
  table.data-table th:nth-child(1), table.data-table td:nth-child(1) { min-width:80px; text-align:center; }
  table.data-table th:nth-child(2), table.data-table td:nth-child(2) { min-width:220px; text-align:center; }
  table.data-table th:nth-child(3), table.data-table td:nth-child(3) { min-width:220px; text-align:center; }
  table.data-table th:nth-child(4), table.data-table td:nth-child(4) { min-width:300px; text-align:center; }
  table.data-table th:nth-child(5), table.data-table td:nth-child(5) { min-width:300px; text-align:center; }
  table.data-table th:nth-child(6), table.data-table td:nth-child(6) { min-width:180px; text-align:center; }
  table.data-table th:nth-child(7), table.data-table td:nth-child(7) { min-width:180px; text-align:center; }
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
      return confirm('Are you sure you want to delete this sub-line/cell?');
    }

    function updateSubLineCode(element) {
      var subLineId = element.getAttribute('data-sublineid');
      if (!subLineId) return;
      
      var prodLineSelect = document.getElementById('prodLine_' + subLineId);
      var subLineNameInput = document.getElementById('subLineName_' + subLineId);
      var subLineCodeInput = document.getElementById('subLineCode_' + subLineId);
      
      if (!prodLineSelect || !subLineNameInput || !subLineCodeInput) return;
      
      var selectedOption = prodLineSelect.options[prodLineSelect.selectedIndex];
      var prodLineName = selectedOption.getAttribute('data-linename') || '';
      var subLineName = subLineNameInput.value.trim();
      
      if (prodLineName && subLineName) {
        subLineCodeInput.value = prodLineName + ' - ' + subLineName;
      } else {
        subLineCodeInput.value = '';
      }
    }
  </script>
</asp:Content>
<asp:Content ID="MainC" ContentPlaceHolderID="MainContent" runat="server">
  <div class="admin-grid">
    <uc2:AdminSidebar ID="AdminSidebar1" runat="server" />
    <div class="admin-container">
      <uc1:AdminHeader ID="AdminHeader1" runat="server" Title="Sub-Line / Cell Database" />
      <div id="globalToast" class="global-toast"></div>

      <div class="toolbar">
        <div class="field">
          <label>Search</label>
          <asp:TextBox ID="txtSearch" runat="server" placeholder="Name, Production Line, Description" AutoPostBack="True" OnTextChanged="txtSearch_TextChanged" />
        </div>
        <div class="field">
          <label>Production Line</label>
          <asp:DropDownList ID="ddlProductionLineFilter" runat="server" AutoPostBack="True" OnSelectedIndexChanged="ddlProductionLineFilter_SelectedIndexChanged">
            <asp:ListItem Value="">All Production Lines</asp:ListItem>
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
        <asp:Repeater ID="rptSubLines" runat="server" OnItemCommand="rptSubLines_ItemCommand">
          <HeaderTemplate>
            <table class="data-table">
              <thead>
                <tr>
                  <th>Sub Line ID</th>
                  <th>Production Line</th>
                  <th>Sub Line Name</th>
                  <th>Sub Line Code</th>
                  <th>Description</th>
                  <th>Created</th>
                  <th>Created By</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
          </HeaderTemplate>
          <ItemTemplate>
            <tr id='row_<%# Eval("SubLineCellID") %>' data-sublineid='<%# Eval("SubLineCellID") %>'>
              <td><input type="text" class="inline-input" value='<%# Eval("SubLineCellID") %>' disabled /></td>
              <td>
                <select class="inline-select" id='prodLine_<%# Eval("SubLineCellID") %>' name='prodLine_<%# Eval("SubLineCellID") %>' data-sublineid='<%# Eval("SubLineCellID") %>' onchange="updateSubLineCode(this)">
                  <option value="" data-linename="">-- Select --</option>
                  <asp:Repeater ID="rptProductionLines" runat="server" DataSource='<%# GetProductionLines() %>'>
                    <ItemTemplate>
                      <option value='<%# Eval("ProductionLineID") %>' data-linename='<%# Eval("ProductionLineName") %>' <%# Container.Parent.Parent is RepeaterItem && Eval("ProductionLineID").ToString() == DataBinder.Eval(((RepeaterItem)Container.Parent.Parent).DataItem, "ProductionLineID").ToString() ? "selected" : "" %>><%# Eval("ProductionLineName") %></option>
                    </ItemTemplate>
                  </asp:Repeater>
                </select>
              </td>
              <td><input type="text" class="inline-input" id='subLineName_<%# Eval("SubLineCellID") %>' name='subLineName_<%# Eval("SubLineCellID") %>' value='<%# Eval("SubLineCellName") %>' data-sublineid='<%# Eval("SubLineCellID") %>' oninput="updateSubLineCode(this)" /></td>
              <td><input type="text" class="inline-input" id='subLineCode_<%# Eval("SubLineCellID") %>' name='subLineCode_<%# Eval("SubLineCellID") %>' value='<%# Eval("SubLineCode") %>' readonly /></td>
              <td><input type="text" class="inline-input" id='description_<%# Eval("SubLineCellID") %>' name='description_<%# Eval("SubLineCellID") %>' value='<%# Eval("Description") %>' /></td>
              <td><input type="text" class="inline-input" value='<%# Eval("CreatedDate", "{0:yyyy-MM-dd HH:mm}") %>' disabled /></td>
              <td><input type="text" class="inline-input" value='<%# Eval("CreatedBy") %>' disabled /></td>
              <td>
                <div class="tbl-actions">
                  <asp:LinkButton runat="server" CommandName="Save" CommandArgument='<%# Eval("SubLineCellID") %>' CssClass="save-btn" ToolTip="Save changes" OnClientClick='<%# "showRowMsg(\"row_" + Eval("SubLineCellID") + "\", \"Saving...\", \"success\"); return true;" %>'>
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/><polyline points="17 21 17 13 7 13 7 21"/><polyline points="7 3 7 8 15 8"/></svg>
                  </asp:LinkButton>
                  <asp:LinkButton runat="server" CommandName="Delete" CommandArgument='<%# Eval("SubLineCellID") %>' CssClass="delete-btn" ToolTip="Delete sub-line" OnClientClick="return confirmDelete();">
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
