<%@ Page Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="SPDLabelVerification.aspx.cs" Inherits="TED_SPDLabelVerification" %>
<asp:Content ID="TitleContent" ContentPlaceHolderID="TitleContent" runat="server">SPD Label Verification</asp:Content>
<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
  <style>
    html, body { min-height:100%; }
    body { overflow-y:auto; }

    .spd-shell { width:100%; max-width:1600px; margin:0 auto; padding:36px clamp(20px,4vw,72px) 56px; display:flex; flex-direction:column; gap:32px; }
    .compact-header { display:flex; justify-content:space-between; align-items:flex-start; gap:24px; flex-wrap:wrap; }
    .header-copy h1 { margin:0; font-size:34px; font-weight:700; }
    .header-copy p { margin:8px 0 0; font-size:15px; opacity:.72; }
    .header-actions { display:flex; gap:16px; align-items:center; flex-wrap:wrap; }

    .user-pill { display:flex; align-items:center; gap:12px; padding:10px 20px; border-radius:999px; border:1px solid rgba(255,255,255,.12); background:rgba(255,255,255,.04); }
    html.theme-light .user-pill, html[data-theme='light'] .user-pill { border:1px solid rgba(0,0,0,.08); background:rgba(0,0,0,.03); }
    .user-initials { width:38px; height:38px; border-radius:50%; background:#4d7cfe; color:#fff; font-weight:700; display:flex; align-items:center; justify-content:center; }
    .user-meta { display:flex; flex-direction:column; font-size:13px; line-height:1.2; }
    .user-meta strong { font-size:15px; }
    .user-meta span { opacity:.8; font-weight:600; letter-spacing:.04em; }
    .user-actions { display:flex; gap:12px; align-items:center; }
    .btn-action { border-radius:12px; padding:8px 18px; border:none; font-size:13px; font-weight:600; font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Oxygen,Ubuntu,Cantarell,sans-serif; text-transform:none; cursor:pointer; transition:all .2s cubic-bezier(.4,0,.2,1); box-shadow:0 2px 8px -2px rgba(0,0,0,.25); }
    .btn-action:hover { transform:translateY(-1px); box-shadow:0 6px 16px -4px rgba(0,0,0,.35); }
    .btn-action:active { transform:translateY(0); }
    .btn-logout { background:linear-gradient(135deg, #991b1b, #7f1d1d); color:#fff; }
    .btn-logout:hover { background:linear-gradient(135deg, #7f1d1d, #651919); }
    html.theme-light .btn-logout, html[data-theme='light'] .btn-logout { background:linear-gradient(135deg, #fb7185, #f87171); color:#fff; }
    html.theme-light .btn-logout:hover, html[data-theme='light'] .btn-logout:hover { background:linear-gradient(135deg, #f43f5e, #ef4444); }
    .btn-report { background:linear-gradient(135deg, #6d28d9, #5b21b6); color:#fff; }
    .btn-report:hover { background:linear-gradient(135deg, #5b21b6, #4c1d95); }
    html.theme-light .btn-report, html[data-theme='light'] .btn-report { background:linear-gradient(135deg, #a78bfa, #8b5cf6); color:#fff; }
    html.theme-light .btn-report:hover, html[data-theme='light'] .btn-report:hover { background:linear-gradient(135deg, #8b5cf6, #7c3aed); }

    .scan-grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(320px,1fr)); gap:28px; width:100%; }
    .scan-card { border-radius:22px; padding:24px 28px; background:rgba(17,21,30,.92); border:1px solid rgba(255,255,255,.08); box-shadow:0 18px 28px -20px rgba(0,0,0,.75); display:flex; flex-direction:column; gap:16px; min-height:240px; }
    .step-card { position:relative; overflow:hidden; }
    html.theme-light .scan-card, html[data-theme='light'] .scan-card { background:#fff; border:1px solid rgba(0,0,0,.08); box-shadow:0 16px 24px -18px rgba(0,0,0,.18); }
    .scan-card h2 { margin:0; font-size:20px; }
    .scan-card p { margin:0; font-size:14px; opacity:.72; }
    .card-head { display:flex; justify-content:space-between; align-items:center; gap:12px; }
    .step-label { font-weight:700; font-size:12px; letter-spacing:.12em; text-transform:uppercase; padding:6px 12px; border-radius:999px; background:rgba(255,255,255,.09); }
    html.theme-light .step-label, html[data-theme='light'] .step-label { background:rgba(0,0,0,.05); }
    .input-control { width:100%; box-sizing:border-box; border-radius:16px; border:1px solid rgba(255,255,255,.15); padding:18px 20px; font-size:18px; letter-spacing:.02em; text-transform:none; background:rgba(0,0,0,.2); color:inherit; display:block; }
    .input-control:focus { outline:none; border-color:var(--accent-blue,#6ea8fe); box-shadow:0 0 0 3px rgba(110,168,254,.35); }
    html.theme-light .input-control, html[data-theme='light'] .input-control { background:#f3f5fa; border:1px solid rgba(0,0,0,.12); color:#101623; }
    .input-control[disabled] { opacity:.45; cursor:not-allowed; }
    .card-disabled { opacity:.6; }

    .history-section { width:100%; }
    .history-card { border-radius:26px; padding:26px 30px; background:rgba(17,21,30,.08); border:1px solid rgba(255,255,255,.08); box-shadow:0 14px 28px -20px rgba(0,0,0,.35); display:flex; flex-direction:column; gap:20px; backdrop-filter:blur(4px); }
    html.theme-light .history-card, html[data-theme='light'] .history-card { background:rgba(255,255,255,.7); border:1px solid rgba(0,0,0,.05); box-shadow:0 10px 20px -18px rgba(0,0,0,.2); }
    .history-head { display:flex; justify-content:space-between; align-items:center; gap:16px; }
    .history-head h3 { margin:0; font-size:20px; }
    .history-date { font-size:14px; opacity:.65; font-weight:400; margin-left:8px; }
    .history-table-wrapper { width:100%; overflow-x:auto; }
    .history-table { width:100%; min-width:960px; border-collapse:separate; border-spacing:0; }
    .history-table thead th { text-align:center; font-size:12px; letter-spacing:.08em; text-transform:uppercase; padding:10px 12px; border-bottom:1px solid rgba(255,255,255,.12); opacity:.65; }
    html.theme-light .history-table thead th { border-color:rgba(0,0,0,.1); }
    .history-table tbody td { padding:14px 12px; border-bottom:1px solid rgba(255,255,255,.06); font-size:14px; opacity:.8; text-align:center; }
    html.theme-light .history-table tbody td { border-color:rgba(0,0,0,.05); }
    .history-table tbody tr:last-child td { border-bottom:none; }
    .table-meta { font-size:12px; opacity:.7; }
    .result-toggle { position:relative; display:inline-flex; align-items:center; justify-content:center; min-width:56px; height:28px; border-radius:14px; font-size:11px; font-weight:700; text-transform:uppercase; letter-spacing:.08em; }
    .result-toggle.pass { background:linear-gradient(135deg, #0f5132, #1ed78f); color:#f8fff7; box-shadow:0 2px 8px -4px rgba(30,215,143,.5); }
    .result-toggle.fail { background:linear-gradient(135deg, #641220, #ff6b8a); color:#fff5f7; box-shadow:0 2px 8px -4px rgba(255,99,132,.5); }
    .workcell-chip { display:inline-block; padding:5px 12px; border-radius:8px; font-size:13px; font-weight:600; }
    .workcell-chip.integrated { background:rgba(255,193,7,.2); color:#f59e0b; }
    .workcell-chip.sidemount { background:rgba(59,130,246,.2); color:#3b82f6; }
    html.theme-light .workcell-chip.integrated { background:rgba(255,193,7,.25); color:#d97706; }
    html.theme-light .workcell-chip.sidemount { background:rgba(59,130,246,.25); color:#2563eb; }
    .material-primary { font-weight:700; font-size:14px; }
    .material-expected { font-size:12px; opacity:.65; margin-top:2px; }
    .history-empty { padding:18px; text-align:center; font-size:14px; opacity:.7; }

    .btn-link { background:none; border:none; color:var(--accent-blue,#6ea8fe); font-weight:600; cursor:pointer; padding:6px 0; font-size:13px; }
    .btn-link:hover { text-decoration:underline; }
    .btn-ghost { border-radius:14px; padding:8px 14px; border:1px solid rgba(255,255,255,.2); background:transparent; color:inherit; font-size:13px; font-weight:600; }
    .btn-ghost:hover { border-color:var(--accent-blue,#6ea8fe); }

    .toast { position:fixed; top:110px; left:50%; transform:translate(-50%,-20px) scale(.95); min-width:260px; max-width:520px; padding:18px 22px; border-radius:20px; border:1px solid transparent; background:#101826; color:#f5f7fa; font-size:15px; font-weight:600; box-shadow:0 24px 40px -20px rgba(0,0,0,.7); opacity:0; pointer-events:none; transition:opacity .25s ease, transform .25s ease; z-index:2000; display:none; }
    .toast.show { opacity:1; transform:translate(-50%,0) scale(1); display:block; }
    .toast-success { border-color:rgba(43,214,147,.4); background:rgba(18,46,36,.95); }
    .toast-error { border-color:rgba(255,99,132,.45); background:rgba(58,18,27,.95); }

    .result-overlay { position:fixed; inset:0; background:rgba(5,8,15,.78); display:flex; align-items:center; justify-content:center; backdrop-filter:blur(6px); opacity:0; pointer-events:none; transition:opacity .25s ease; z-index:2500; }
    .result-overlay.show { opacity:1; pointer-events:auto; }
    .overlay-panel { border-radius:32px; padding:48px 72px; text-align:center; box-shadow:0 30px 60px -35px rgba(0,0,0,.8); border:1px solid rgba(255,255,255,.08); }
    .overlay-panel.pass { background:linear-gradient(135deg, #0f5132, #1ed78f); color:#f8fff7; }
    .overlay-panel.fail { background:linear-gradient(135deg, #641220, #ff6b8a); color:#fff5f7; }
    .overlay-title { display:block; font-size:56px; font-weight:800; letter-spacing:.1em; text-transform:uppercase; }
    .overlay-message { margin:18px 0 0; font-size:20px; font-weight:600; }
  </style>
  <script type="text/javascript">
    function spdFocusField(id){
      setTimeout(function(){
        var el = document.getElementById(id);
        if(el){ el.focus(); if(el.select){ el.select(); } }
      }, 80);
    }
  </script>
</asp:Content>
<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
  <asp:Panel ID="pnlToast" runat="server" CssClass="toast" Visible="false">
    <asp:Literal ID="litToast" runat="server" />
  </asp:Panel>
  <asp:Panel ID="pnlResultOverlay" runat="server" CssClass="result-overlay" Visible="false">
    <asp:Panel ID="pnlOverlayCard" runat="server" CssClass="overlay-panel">
      <span class="overlay-title"><asp:Literal ID="litOverlayTitle" runat="server" /></span>
      <p class="overlay-message"><asp:Literal ID="litOverlayMessage" runat="server" /></p>
    </asp:Panel>
  </asp:Panel>
  <div class="spd-shell">
    <div class="compact-header">
      <div class="header-copy">
        <h1>SPD Label Verification</h1>
        <p>Scan the serial number, then scan the material number.</p>
      </div>
      <div class="header-actions">
        <div class="user-actions">
          <asp:Button ID="btnReport" runat="server" Text="Report" CssClass="btn-action btn-report" OnClick="btnReport_Click" CausesValidation="false" />
          <asp:Button ID="btnLogout" runat="server" Text="Logout" CssClass="btn-action btn-logout" OnClick="btnLogout_Click" CausesValidation="false" />
        </div>
        <div class="user-pill">
          <span class="user-initials"><asp:Literal ID="litUserInitials" runat="server" /></span>
          <div class="user-meta">
            <strong><asp:Literal ID="litUserName" runat="server" /></strong>
            <span><asp:Literal ID="litUserBadge" runat="server" /></span>
          </div>
        </div>
      </div>
    </div>

    <section class="scan-grid">
      <div class="scan-card step-card">
          <div class="card-head">
            <span class="step-label">Step 1</span>
          </div>
          <h2>Scan Serial Number</h2>
          <p>Scanner should send Enter/Return to auto-submit.</p>
          <asp:TextBox ID="txtSerial" runat="server" CssClass="input-control" placeholder="Scan serial" AutoPostBack="true" OnTextChanged="txtSerial_TextChanged" autocomplete="off" />
        </div>
      <asp:Panel ID="pnlMaterialCard" runat="server" CssClass="scan-card step-card card-disabled">
        <div class="card-head">
          <span class="step-label">Step 2</span>
        </div>
        <h2>Scan Material Number</h2>
        <p>Instantly compares against the label master file.</p>
        <asp:TextBox ID="txtMaterial" runat="server" CssClass="input-control" placeholder="Scan material" AutoPostBack="true" OnTextChanged="txtMaterial_TextChanged" autocomplete="off" Enabled="false" />
      </asp:Panel>
    </section>

    <section class="history-section">
      <div class="history-card">
        <div class="history-head">
          <h3>Today Validations<span class="history-date"><asp:Literal ID="litHistoryDate" runat="server" /></span></h3>
        </div>
        <div class="history-table-wrapper">
          <table class="history-table">
            <thead>
              <tr>
                <th>Time</th>
                <th>Operator</th>
                <th>Serial &amp; Catalog</th>
                <th>Scanned Material</th>
                <th>Workcell</th>
                <th>Result</th>
              </tr>
            </thead>
            <tbody>
              <asp:Repeater ID="rptHistory" runat="server">
                <ItemTemplate>
                  <tr>
                    <td><strong><%# Eval("Timestamp", "{0:HH:mm}") %></strong></td>
                    <td>
                      <div><strong><%# Eval("Operator") %></strong></div>
                      <div class="table-meta"><%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("Badge"))) ? "--" : Eval("Badge") %></div>
                    </td>
                    <td>
                      <div><strong><%# Eval("Serial") %></strong></div>
                      <div class="table-meta">Catalog <%# Eval("Catalog") %></div>
                    </td>
                    <td>
                      <div class="material-primary"><%# Eval("MaterialScanned") %></div>
                      <%# (bool)Eval("IsMatch") ? "" : "<div class='material-expected'>(Expected: " + Eval("MaterialExpected") + ")</div>" %>
                    </td>
                    <td><%# RenderWorkcellChip(Eval("Workcell")) %></td>
                    <td><span class='<%# (bool)Eval("IsMatch") ? "result-toggle pass" : "result-toggle fail" %>'><%# (bool)Eval("IsMatch") ? "PASS" : "FAIL" %></span></td>
                  </tr>
                </ItemTemplate>
              </asp:Repeater>
            </tbody>
          </table>
          <asp:Panel ID="pnlHistoryEmpty" runat="server" CssClass="history-empty" Visible="false">No scans yet this session.</asp:Panel>
        </div>
      </div>
    </section>
  </div>
</asp:Content>
