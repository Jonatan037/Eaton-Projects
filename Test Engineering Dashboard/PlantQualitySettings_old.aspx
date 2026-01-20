<%@ Page Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="PlantQualitySettings.aspx.cs" Inherits="TED_PlantQualitySettings" %>
<asp:Content ID="PQSettingsTitle" ContentPlaceHolderID="TitleContent" runat="server">Quality Performance Settings</asp:Content>
<asp:Content ID="PQSettingsHead" ContentPlaceHolderID="HeadContent" runat="server">
  <style>
    html, body { max-width:100%; overflow-x:hidden; overflow-y:auto !important; }
    
    .settings-page {
      display: flex;
      flex-direction: column;
      min-height: auto;
      padding: 12px 20px 24px;
      box-sizing: border-box;
      gap: 16px;
    }
    
    /* Header */
    .settings-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      flex-wrap: wrap;
      gap: 8px;
    }
    
    .settings-title-area h1 {
      font-size: 18px;
      font-weight: 600;
      margin: 0;
      color: #1b222b;
      font-family: 'Segoe UI', 'Inter', -apple-system, sans-serif;
    }
    
    html:not(.theme-light):not([data-theme='light']) .settings-title-area h1 { color: #fff; }
    
    .settings-title-area p {
      font-size: 11px;
      color: rgba(0,0,0,0.5);
      margin: 4px 0 0;
      font-family: 'Segoe UI', 'Inter', -apple-system, sans-serif;
    }
    
    html:not(.theme-light):not([data-theme='light']) .settings-title-area p { color: rgba(255,255,255,0.5); }
    
    .header-actions {
      display: flex;
      align-items: center;
      gap: 8px;
    }
    
    .btn-back {
      display: inline-flex;
      align-items: center;
      gap: 4px;
      padding: 6px 12px;
      border-radius: 6px;
      text-decoration: none;
      font-size: 11px;
      font-weight: 500;
      background: rgba(0,0,0,0.05);
      color: #1b222b;
      border: 1px solid rgba(0,0,0,0.08);
      transition: all 0.2s;
      font-family: 'Segoe UI', 'Inter', -apple-system, sans-serif;
    }
    
    html:not(.theme-light):not([data-theme='light']) .btn-back {
      background: rgba(255,255,255,0.08);
      color: #fff;
      border-color: rgba(255,255,255,0.1);
    }
    
    .btn-save {
      display: inline-flex;
      align-items: center;
      gap: 4px;
      padding: 8px 16px;
      border-radius: 6px;
      font-size: 12px;
      font-weight: 600;
      background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
      color: #fff;
      border: none;
      cursor: pointer;
      transition: all 0.2s;
      font-family: 'Segoe UI', 'Inter', -apple-system, sans-serif;
    }
    
    .btn-save:hover {
      box-shadow: 0 4px 12px rgba(59,130,246,0.4);
    }
    
    /* Year selector */
    .year-selector {
      display: flex;
      align-items: center;
      gap: 12px;
      padding: 12px 16px;
      background: rgba(0,0,0,0.02);
      border: 1px solid rgba(0,0,0,0.06);
      border-radius: 10px;
    }
    
    html:not(.theme-light):not([data-theme='light']) .year-selector {
      background: rgba(255,255,255,0.03);
      border-color: rgba(255,255,255,0.06);
    }
    
    .year-selector label {
      font-size: 11px;
      font-weight: 600;
      color: rgba(0,0,0,0.6);
      text-transform: uppercase;
      letter-spacing: 0.5px;
      font-family: 'Segoe UI', 'Inter', -apple-system, sans-serif;
    }
    
    html:not(.theme-light):not([data-theme='light']) .year-selector label { color: rgba(255,255,255,0.6); }
    
    .year-selector select {
      padding: 6px 12px;
      border-radius: 6px;
      border: 1px solid rgba(0,0,0,0.12);
      background: #fff;
      color: #1b222b;
      font-size: 12px;
      font-weight: 600;
      font-family: 'Segoe UI', 'Inter', -apple-system, sans-serif;
    }
    
    html:not(.theme-light):not([data-theme='light']) .year-selector select {
      background: rgba(255,255,255,0.08);
      border-color: rgba(255,255,255,0.12);
      color: #fff;
    }
    
    /* Goals tables container */
    .goals-container {
      display: flex;
      flex-direction: column;
      gap: 20px;
    }
    
    .goal-section {
      background: rgba(255,255,255,0.8);
      border: 1px solid rgba(0,0,0,0.05);
      border-radius: 10px;
      overflow: hidden;
    }
    
    html:not(.theme-light):not([data-theme='light']) .goal-section {
      background: rgba(255,255,255,0.03);
      border-color: rgba(255,255,255,0.05);
    }
    
    .goal-section-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 12px 16px;
      background: rgba(0,0,0,0.02);
      border-bottom: 1px solid rgba(0,0,0,0.05);
    }
    
    html:not(.theme-light):not([data-theme='light']) .goal-section-header {
      background: rgba(255,255,255,0.02);
      border-color: rgba(255,255,255,0.05);
    }
    
    .goal-section-header h2 {
      font-size: 13px;
      font-weight: 600;
      margin: 0;
      color: #1b222b;
      font-family: 'Segoe UI', 'Inter', -apple-system, sans-serif;
      display: flex;
      align-items: center;
      gap: 8px;
    }
    
    html:not(.theme-light):not([data-theme='light']) .goal-section-header h2 { color: #fff; }
    
    .goal-icon {
      width: 24px;
      height: 24px;
      border-radius: 6px;
      display: flex;
      align-items: center;
      justify-content: center;
    }
    
    .goal-icon.yield { background: rgba(16,185,129,0.15); color: #10b981; }
    .goal-icon.scrap { background: rgba(245,158,11,0.15); color: #f59e0b; }
    .goal-icon.ncm { background: rgba(239,68,68,0.15); color: #ef4444; }
    
    .goal-unit {
      font-size: 10px;
      font-weight: 500;
      color: rgba(0,0,0,0.4);
      background: rgba(0,0,0,0.05);
      padding: 3px 8px;
      border-radius: 10px;
    }
    
    html:not(.theme-light):not([data-theme='light']) .goal-unit {
      color: rgba(255,255,255,0.4);
      background: rgba(255,255,255,0.08);
    }
    
    .goal-table-wrapper {
      overflow-x: auto;
      padding: 12px;
    }
    
    .goal-table {
      width: 100%;
      border-collapse: collapse;
      font-family: 'Segoe UI', 'Inter', -apple-system, sans-serif;
      font-size: 11px;
    }
    
    .goal-table th, .goal-table td {
      padding: 8px 6px;
      text-align: center;
      border: 1px solid rgba(0,0,0,0.06);
    }
    
    html:not(.theme-light):not([data-theme='light']) .goal-table th,
    html:not(.theme-light):not([data-theme='light']) .goal-table td {
      border-color: rgba(255,255,255,0.06);
    }
    
    .goal-table th {
      background: rgba(0,0,0,0.03);
      font-weight: 600;
      color: rgba(0,0,0,0.6);
      text-transform: uppercase;
      letter-spacing: 0.3px;
      font-size: 9px;
    }
    
    html:not(.theme-light):not([data-theme='light']) .goal-table th {
      background: rgba(255,255,255,0.03);
      color: rgba(255,255,255,0.6);
    }
    
    .goal-table th:first-child {
      text-align: left;
      min-width: 120px;
    }
    
    .goal-table td:first-child {
      text-align: left;
      font-weight: 600;
      color: #1b222b;
      background: rgba(0,0,0,0.01);
    }
    
    html:not(.theme-light):not([data-theme='light']) .goal-table td:first-child {
      color: #fff;
      background: rgba(255,255,255,0.01);
    }
    
    .goal-table td:first-child.plant-row {
      color: #3b82f6;
      font-weight: 700;
    }
    
    .goal-table input {
      width: 55px;
      padding: 5px 4px;
      border: 1px solid rgba(0,0,0,0.1);
      border-radius: 4px;
      text-align: center;
      font-size: 11px;
      font-family: 'Segoe UI', 'Inter', -apple-system, sans-serif;
      background: #fff;
      color: #1b222b;
      transition: border-color 0.2s, box-shadow 0.2s;
    }
    
    .goal-table input:focus {
      outline: none;
      border-color: #3b82f6;
      box-shadow: 0 0 0 2px rgba(59,130,246,0.2);
    }
    
    html:not(.theme-light):not([data-theme='light']) .goal-table input {
      background: rgba(255,255,255,0.06);
      border-color: rgba(255,255,255,0.1);
      color: #fff;
    }
    
    html:not(.theme-light):not([data-theme='light']) .goal-table input:focus {
      border-color: #60a5fa;
      box-shadow: 0 0 0 2px rgba(96,165,250,0.2);
    }
    
    /* Status message */
    .status-message {
      padding: 10px 16px;
      border-radius: 8px;
      font-size: 12px;
      font-weight: 500;
      display: none;
    }
    
    .status-message.success {
      display: block;
      background: rgba(16,185,129,0.1);
      color: #059669;
      border: 1px solid rgba(16,185,129,0.2);
    }
    
    .status-message.error {
      display: block;
      background: rgba(239,68,68,0.1);
      color: #dc2626;
      border: 1px solid rgba(239,68,68,0.2);
    }
    
    html:not(.theme-light):not([data-theme='light']) .status-message.success {
      background: rgba(16,185,129,0.15);
      color: #34d399;
    }
    
    html:not(.theme-light):not([data-theme='light']) .status-message.error {
      background: rgba(239,68,68,0.15);
      color: #f87171;
    }
  </style>
</asp:Content>

<asp:Content ID="PQSettingsBody" ContentPlaceHolderID="MainContent" runat="server">
<div class="settings-page">
  <!-- Header -->
  <div class="settings-header">
    <div class="settings-title-area">
      <h1>Quality Performance Settings</h1>
      <p>Define monthly goals for Yield, Scrap, and NCM metrics per production line</p>
    </div>
    <div class="header-actions">
      <asp:Button ID="btnSave" runat="server" Text="Save Changes" CssClass="btn-save" OnClick="btnSave_Click" />
      <a href="PlantQualityDashboard.aspx" class="btn-back" onclick="sessionStorage.removeItem('pqd_hasAutoApplied');">
        <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M19 12H5M12 19l-7-7 7-7"/>
        </svg>
        Back to Report
      </a>
    </div>
  </div>

  <!-- Status Message -->
  <asp:Panel ID="pnlStatus" runat="server" CssClass="status-message" Visible="false">
    <asp:Literal ID="litStatus" runat="server" />
  </asp:Panel>

  <!-- Year Selector -->
  <div class="year-selector">
    <label>Select Year</label>
    <asp:DropDownList ID="ddlYear" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlYear_SelectedIndexChanged">
    </asp:DropDownList>
    <label style="margin-left:16px;">Plant</label>
    <asp:DropDownList ID="ddlPlant" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlPlant_SelectedIndexChanged">
      <asp:ListItem Text="YPO" Value="YPO" Selected="True" />
      <asp:ListItem Text="CPO" Value="CPO" />
    </asp:DropDownList>
  </div>

  <!-- Goals Tables -->
  <div class="goals-container">
    <!-- Yield Goals -->
    <div class="goal-section">
      <div class="goal-section-header">
        <h2>
          <span class="goal-icon yield">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <polyline points="23 6 13.5 15.5 8.5 10.5 1 18"/>
              <polyline points="17 6 23 6 23 12"/>
            </svg>
          </span>
          First Pass Yield Goals
        </h2>
        <span class="goal-unit">Target %</span>
      </div>
      <div class="goal-table-wrapper">
        <table class="goal-table" id="yieldGoalsTable">
          <thead>
            <tr>
              <th>Line</th>
              <th>Jan</th>
              <th>Feb</th>
              <th>Mar</th>
              <th>Apr</th>
              <th>May</th>
              <th>Jun</th>
              <th>Jul</th>
              <th>Aug</th>
              <th>Sep</th>
              <th>Oct</th>
              <th>Nov</th>
              <th>Dec</th>
            </tr>
          </thead>
          <tbody id="yieldGoalsBody">
            <asp:Literal ID="litYieldGoalsRows" runat="server" />
          </tbody>
        </table>
      </div>
    </div>

    <!-- Scrap Goals -->
    <div class="goal-section">
      <div class="goal-section-header">
        <h2>
          <span class="goal-icon scrap">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <polyline points="3 6 5 6 21 6"/>
              <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/>
            </svg>
          </span>
          Scrap Goals
        </h2>
        <span class="goal-unit">Target %</span>
      </div>
      <div class="goal-table-wrapper">
        <table class="goal-table" id="scrapGoalsTable">
          <thead>
            <tr>
              <th>Line</th>
              <th>Jan</th>
              <th>Feb</th>
              <th>Mar</th>
              <th>Apr</th>
              <th>May</th>
              <th>Jun</th>
              <th>Jul</th>
              <th>Aug</th>
              <th>Sep</th>
              <th>Oct</th>
              <th>Nov</th>
              <th>Dec</th>
            </tr>
          </thead>
          <tbody id="scrapGoalsBody">
            <asp:Literal ID="litScrapGoalsRows" runat="server" />
          </tbody>
        </table>
      </div>
    </div>

    <!-- NCM Goals -->
    <div class="goal-section">
      <div class="goal-section-header">
        <h2>
          <span class="goal-icon ncm">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/>
              <line x1="12" y1="9" x2="12" y2="13"/>
              <line x1="12" y1="17" x2="12.01" y2="17"/>
            </svg>
          </span>
          NCM (Non-Conformance Material) Goals
        </h2>
        <span class="goal-unit">Max Count</span>
      </div>
      <div class="goal-table-wrapper">
        <table class="goal-table" id="ncmGoalsTable">
          <thead>
            <tr>
              <th>Line</th>
              <th>Jan</th>
              <th>Feb</th>
              <th>Mar</th>
              <th>Apr</th>
              <th>May</th>
              <th>Jun</th>
              <th>Jul</th>
              <th>Aug</th>
              <th>Sep</th>
              <th>Oct</th>
              <th>Nov</th>
              <th>Dec</th>
            </tr>
          </thead>
          <tbody id="ncmGoalsBody">
            <asp:Literal ID="litNCMGoalsRows" runat="server" />
          </tbody>
        </table>
      </div>
    </div>
  </div>
</div>

<script>
  // Auto-fill row when plant value changes
  document.addEventListener('DOMContentLoaded', function() {
    var tables = document.querySelectorAll('.goal-table');
    tables.forEach(function(table) {
      var plantRow = table.querySelector('tr:first-child');
      if (plantRow) {
        var inputs = plantRow.querySelectorAll('input');
        inputs.forEach(function(input, idx) {
          input.addEventListener('change', function() {
            // Optionally propagate to other rows if empty
          });
        });
      }
    });
  });
</script>
</asp:Content>
