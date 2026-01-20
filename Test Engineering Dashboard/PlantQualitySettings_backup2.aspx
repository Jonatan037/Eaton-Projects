<%@ Page Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="PlantQualitySettings.aspx.cs" Inherits="TED_PlantQualitySettings" %>
<asp:Content ID="PQSettingsTitle" ContentPlaceHolderID="TitleContent" runat="server">Quality Performance Settings</asp:Content>
<asp:Content ID="PQSettingsHead" ContentPlaceHolderID="HeadContent" runat="server">
  <style>
    html, body { max-width:100%; overflow-x:hidden; overflow-y:auto !important; }
    
    .settings-page {
      display: flex;
      flex-direction: column;
      min-height: auto;
      padding: 20px 24px 32px;
      box-sizing: border-box;
      gap: 20px;
      max-width: 100%;
      width: 100%;
      margin: 0;
    }
    
    /* Header */
    .settings-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      flex-wrap: wrap;
      gap: 16px;
      padding-bottom: 16px;
      border-bottom: 1px solid rgba(0,0,0,0.06);
    }
    
    html:not(.theme-light):not([data-theme='light']) .settings-header {
      border-color: rgba(255,255,255,0.08);
    }
    
    .settings-title-area h1 {
      font-size: 22px;
      font-weight: 700;
      margin: 0;
      color: #1b222b;
      font-family: 'Segoe UI', 'Inter', -apple-system, sans-serif;
      display: flex;
      align-items: center;
      gap: 12px;
    }
    
    .settings-title-area h1::before {
      content: '';
      display: inline-block;
      width: 4px;
      height: 28px;
      background: linear-gradient(135deg, #3b82f6 0%, #8b5cf6 100%);
      border-radius: 2px;
    }
    
    html:not(.theme-light):not([data-theme='light']) .settings-title-area h1 { color: #fff; }
    
    .settings-title-area p {
      font-size: 13px;
      color: rgba(0,0,0,0.5);
      margin: 6px 0 0 16px;
      font-family: 'Segoe UI', 'Inter', -apple-system, sans-serif;
    }
    
    html:not(.theme-light):not([data-theme='light']) .settings-title-area p { color: rgba(255,255,255,0.5); }
    
    .header-actions {
      display: flex;
      align-items: center;
      gap: 12px;
    }
    
    .btn-back {
      display: inline-flex;
      align-items: center;
      gap: 6px;
      padding: 10px 18px;
      border-radius: 8px;
      text-decoration: none;
      font-size: 13px;
      font-weight: 500;
      background: rgba(0,0,0,0.05);
      color: #1b222b;
      border: 1px solid rgba(0,0,0,0.08);
      transition: all 0.2s;
      font-family: 'Segoe UI', 'Inter', -apple-system, sans-serif;
    }
    
    .btn-back:hover { background: rgba(0,0,0,0.08); }
    
    html:not(.theme-light):not([data-theme='light']) .btn-back {
      background: rgba(255,255,255,0.08);
      color: #fff;
      border-color: rgba(255,255,255,0.12);
    }
    
    .btn-save {
      display: inline-flex;
      align-items: center;
      gap: 6px;
      padding: 10px 22px;
      border-radius: 8px;
      font-size: 13px;
      font-weight: 600;
      background: linear-gradient(135deg, #10b981 0%, #059669 100%);
      color: #fff;
      border: none;
      cursor: pointer;
      transition: all 0.2s;
      font-family: 'Segoe UI', 'Inter', -apple-system, sans-serif;
      box-shadow: 0 2px 8px rgba(16,185,129,0.25);
    }
    
    .btn-save:hover {
      transform: translateY(-1px);
      box-shadow: 0 4px 16px rgba(16,185,129,0.35);
    }
    
    /* Controls bar */
    .controls-bar {
      display: flex;
      align-items: center;
      gap: 28px;
      padding: 16px 24px;
      background: linear-gradient(135deg, rgba(59,130,246,0.04) 0%, rgba(139,92,246,0.04) 100%);
      border: 1px solid rgba(59,130,246,0.1);
      border-radius: 12px;
      flex-wrap: wrap;
    }
    
    html:not(.theme-light):not([data-theme='light']) .controls-bar {
      background: linear-gradient(135deg, rgba(59,130,246,0.08) 0%, rgba(139,92,246,0.08) 100%);
      border-color: rgba(59,130,246,0.15);
    }
    
    .control-group {
      display: flex;
      align-items: center;
      gap: 10px;
    }
    
    .control-group label {
      font-size: 11px;
      font-weight: 600;
      color: rgba(0,0,0,0.55);
      text-transform: uppercase;
      letter-spacing: 0.5px;
      font-family: 'Segoe UI', 'Inter', -apple-system, sans-serif;
    }
    
    html:not(.theme-light):not([data-theme='light']) .control-group label { color: rgba(255,255,255,0.55); }
    
    .control-group select {
      padding: 8px 14px;
      border-radius: 8px;
      border: 1px solid rgba(0,0,0,0.12);
      background: #fff;
      color: #1b222b;
      font-size: 13px;
      font-weight: 600;
      font-family: 'Segoe UI', 'Inter', -apple-system, sans-serif;
      cursor: pointer;
      min-width: 100px;
    }
    
    html:not(.theme-light):not([data-theme='light']) .control-group select {
      background: rgba(255,255,255,0.1);
      border-color: rgba(255,255,255,0.15);
      color: #fff;
    }
    
    /* Goals tables container */
    .goals-container {
      display: flex;
      flex-direction: column;
      gap: 24px;
    }
    
    .goal-section {
      background: #fff;
      border: 1px solid rgba(0,0,0,0.08);
      border-radius: 14px;
      overflow: hidden;
      box-shadow: 0 2px 12px rgba(0,0,0,0.04);
    }
    
    html:not(.theme-light):not([data-theme='light']) .goal-section {
      background: rgba(255,255,255,0.03);
      border-color: rgba(255,255,255,0.08);
      box-shadow: 0 2px 12px rgba(0,0,0,0.2);
    }
    
    .goal-section-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 16px 20px;
      background: rgba(0,0,0,0.02);
      border-bottom: 1px solid rgba(0,0,0,0.06);
    }
    
    html:not(.theme-light):not([data-theme='light']) .goal-section-header {
      background: rgba(255,255,255,0.02);
      border-color: rgba(255,255,255,0.06);
    }
    
    .goal-section-header h2 {
      font-size: 15px;
      font-weight: 700;
      margin: 0;
      color: #1b222b;
      font-family: 'Segoe UI', 'Inter', -apple-system, sans-serif;
      display: flex;
      align-items: center;
      gap: 12px;
    }
    
    html:not(.theme-light):not([data-theme='light']) .goal-section-header h2 { color: #fff; }
    
    .goal-icon {
      width: 36px;
      height: 36px;
      border-radius: 10px;
      display: flex;
      align-items: center;
      justify-content: center;
    }
    
    .goal-icon.yield { background: rgba(16,185,129,0.12); color: #10b981; }
    .goal-icon.scrap { background: rgba(245,158,11,0.12); color: #f59e0b; }
    .goal-icon.ncm { background: rgba(239,68,68,0.12); color: #ef4444; }
    
    .goal-badges {
      display: flex;
      align-items: center;
      gap: 10px;
    }
    
    .goal-unit {
      font-size: 11px;
      font-weight: 600;
      padding: 5px 14px;
      border-radius: 20px;
    }
    
    .goal-unit.percent {
      color: #059669;
      background: rgba(16,185,129,0.1);
      border: 1px solid rgba(16,185,129,0.2);
    }
    
    .goal-unit.dollar {
      color: #d97706;
      background: rgba(245,158,11,0.1);
      border: 1px solid rgba(245,158,11,0.2);
    }
    
    .goal-scope {
      font-size: 10px;
      font-weight: 600;
      padding: 4px 10px;
      border-radius: 12px;
      color: rgba(0,0,0,0.5);
      background: rgba(0,0,0,0.04);
      text-transform: uppercase;
      letter-spacing: 0.3px;
    }
    
    html:not(.theme-light):not([data-theme='light']) .goal-unit.percent {
      color: #34d399;
      background: rgba(16,185,129,0.15);
    }
    
    html:not(.theme-light):not([data-theme='light']) .goal-unit.dollar {
      color: #fbbf24;
      background: rgba(245,158,11,0.15);
    }
    
    html:not(.theme-light):not([data-theme='light']) .goal-scope {
      color: rgba(255,255,255,0.5);
      background: rgba(255,255,255,0.06);
    }
    
    .goal-table-wrapper {
      overflow-x: auto;
      padding: 16px 20px;
      width: 100%;
    }
    
    .goal-table {
      width: 100%;
      min-width: 100%;
      table-layout: fixed;
      border-collapse: separate;
      border-spacing: 0;
      font-family: 'Segoe UI', 'Inter', -apple-system, sans-serif;
      font-size: 12px;
    }
    
    .goal-table th, .goal-table td {
      padding: 10px 6px;
      text-align: center;
      border: 1px solid rgba(0,0,0,0.06);
    }
    
    .goal-table th:first-child,
    .goal-table td:first-child {
      width: 140px;
      min-width: 140px;
    }
    
    .goal-table th:first-child { border-top-left-radius: 8px; }
    .goal-table th:last-child { border-top-right-radius: 8px; }
    .goal-table tbody tr:last-child td:first-child { border-bottom-left-radius: 8px; }
    .goal-table tbody tr:last-child td:last-child { border-bottom-right-radius: 8px; }
    
    html:not(.theme-light):not([data-theme='light']) .goal-table th,
    html:not(.theme-light):not([data-theme='light']) .goal-table td {
      border-color: rgba(255,255,255,0.08);
    }
    
    .goal-table th {
      background: linear-gradient(135deg, rgba(59,130,246,0.06) 0%, rgba(139,92,246,0.06) 100%);
      font-weight: 700;
      color: rgba(0,0,0,0.65);
      text-transform: uppercase;
      letter-spacing: 0.5px;
      font-size: 10px;
    }
    
    html:not(.theme-light):not([data-theme='light']) .goal-table th {
      background: linear-gradient(135deg, rgba(59,130,246,0.12) 0%, rgba(139,92,246,0.12) 100%);
      color: rgba(255,255,255,0.65);
    }
    
    .goal-table th:first-child {
      text-align: left;
      min-width: 150px;
      padding-left: 16px;
    }
    
    .goal-table td:first-child {
      text-align: left;
      font-weight: 600;
      color: #1b222b;
      background: rgba(0,0,0,0.01);
      padding-left: 16px;
    }
    
    html:not(.theme-light):not([data-theme='light']) .goal-table td:first-child {
      color: #fff;
      background: rgba(255,255,255,0.01);
    }
    
    .goal-table td:first-child.plant-row {
      color: #3b82f6;
      font-weight: 700;
      background: rgba(59,130,246,0.04);
    }
    
    html:not(.theme-light):not([data-theme='light']) .goal-table td:first-child.plant-row {
      color: #60a5fa;
      background: rgba(59,130,246,0.08);
    }
    
    /* Ledger header row styling */
    .ledger-header-row {
      background: linear-gradient(135deg, rgba(245,158,11,0.08) 0%, rgba(234,88,12,0.08) 100%);
    }
    
    .ledger-header-row:hover td {
      background: transparent !important;
    }
    
    .ledger-header {
      font-weight: 700 !important;
      font-size: 12px !important;
      color: #d97706 !important;
      text-transform: uppercase;
      letter-spacing: 0.5px;
      padding: 10px 16px !important;
      border-bottom: 2px solid rgba(245,158,11,0.2) !important;
    }
    
    html:not(.theme-light):not([data-theme='light']) .ledger-header-row {
      background: linear-gradient(135deg, rgba(245,158,11,0.12) 0%, rgba(234,88,12,0.12) 100%);
    }
    
    html:not(.theme-light):not([data-theme='light']) .ledger-header {
      color: #fbbf24 !important;
      border-color: rgba(245,158,11,0.3) !important;
    }
    
    .line-under-ledger {
      padding-left: 28px !important;
      position: relative;
    }
    
    .line-under-ledger::before {
      content: '';
      position: absolute;
      left: 14px;
      top: 50%;
      transform: translateY(-50%);
      width: 6px;
      height: 6px;
      background: rgba(245,158,11,0.4);
      border-radius: 50%;
    }
    
    .goal-table tbody tr:hover td {
      background: rgba(59,130,246,0.03);
    }
    
    html:not(.theme-light):not([data-theme='light']) .goal-table tbody tr:hover td {
      background: rgba(59,130,246,0.06);
    }
    
    .goal-table tbody tr:hover td:first-child {
      background: rgba(59,130,246,0.06);
    }
    
    /* Input styling */
    .goal-input {
      width: 100%;
      max-width: 100px;
      min-width: 60px;
      padding: 7px 6px;
      border: 1px solid rgba(0,0,0,0.1);
      border-radius: 6px;
      text-align: center;
      font-size: 12px;
      font-weight: 500;
      font-family: 'Segoe UI', 'Inter', -apple-system, sans-serif;
      background: #fff;
      color: #1b222b;
      transition: all 0.2s;
      box-sizing: border-box;
    }
    
    .input-wrapper {
      display: flex;
      align-items: center;
      justify-content: center;
      width: 100%;
    }
    
    .goal-input:focus {
      outline: none;
      border-color: #3b82f6;
      box-shadow: 0 0 0 3px rgba(59,130,246,0.15);
    }
    
    html:not(.theme-light):not([data-theme='light']) .goal-input {
      background: rgba(255,255,255,0.06);
      border-color: rgba(255,255,255,0.12);
      color: #fff;
    }
    
    html:not(.theme-light):not([data-theme='light']) .goal-input:focus {
      border-color: #60a5fa;
      box-shadow: 0 0 0 3px rgba(96,165,250,0.2);
    }
    
    .goal-input.percent-input {
      width: 55px;
    }
    
    .goal-input.dollar-input {
      width: 80px;
    }
    
    /* Input with prefix/suffix wrapper */
    .input-wrapper {
      display: inline-flex;
      align-items: center;
      position: relative;
    }
    
    .input-prefix {
      position: absolute;
      left: 8px;
      font-size: 11px;
      color: rgba(0,0,0,0.4);
      font-weight: 500;
      pointer-events: none;
    }
    
    html:not(.theme-light):not([data-theme='light']) .input-prefix {
      color: rgba(255,255,255,0.4);
    }
    
    .input-wrapper .goal-input.dollar-input {
      padding-left: 18px;
    }
    
    /* Status message */
    .status-message {
      padding: 14px 20px;
      border-radius: 10px;
      font-size: 13px;
      font-weight: 500;
      display: none;
      font-family: 'Segoe UI', 'Inter', -apple-system, sans-serif;
    }
    
    .status-message.success {
      display: flex;
      align-items: center;
      gap: 10px;
      background: rgba(16,185,129,0.1);
      color: #059669;
      border: 1px solid rgba(16,185,129,0.2);
    }
    
    .status-message.success::before {
      content: '';
      display: inline-block;
      width: 18px;
      height: 18px;
      background: #059669;
      -webkit-mask: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='white' stroke-width='3'%3E%3Cpolyline points='20 6 9 17 4 12'/%3E%3C/svg%3E") center/contain no-repeat;
      mask: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='white' stroke-width='3'%3E%3Cpolyline points='20 6 9 17 4 12'/%3E%3C/svg%3E") center/contain no-repeat;
      flex-shrink: 0;
    }
    
    .status-message.error {
      display: flex;
      align-items: center;
      gap: 10px;
      background: rgba(239,68,68,0.1);
      color: #dc2626;
      border: 1px solid rgba(239,68,68,0.2);
    }
    
    .status-message.error::before {
      content: '';
      display: inline-block;
      width: 18px;
      height: 18px;
      background: #dc2626;
      -webkit-mask: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='white' stroke-width='2'%3E%3Ccircle cx='12' cy='12' r='10'/%3E%3Cline x1='12' y1='8' x2='12' y2='12'/%3E%3Cline x1='12' y1='16' x2='12.01' y2='16'/%3E%3C/svg%3E") center/contain no-repeat;
      mask: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='white' stroke-width='2'%3E%3Ccircle cx='12' cy='12' r='10'/%3E%3Cline x1='12' y1='8' x2='12' y2='12'/%3E%3Cline x1='12' y1='16' x2='12.01' y2='16'/%3E%3C/svg%3E") center/contain no-repeat;
      flex-shrink: 0;
    }
    
    html:not(.theme-light):not([data-theme='light']) .status-message.success {
      background: rgba(16,185,129,0.15);
      color: #34d399;
    }
    
    html:not(.theme-light):not([data-theme='light']) .status-message.error {
      background: rgba(239,68,68,0.15);
      color: #f87171;
    }
    
    /* Responsive adjustments */
    @media (max-width: 1200px) {
      .settings-page { padding: 12px; }
      .goal-table-wrapper { padding: 10px; }
      .goal-input { min-width: 50px; max-width: 80px; font-size: 11px; }
      .goal-table th:first-child,
      .goal-table td:first-child { width: 110px; min-width: 110px; }
    }
    
    @media (min-width: 1600px) {
      .goal-input { max-width: 120px; }
      .goal-table th, .goal-table td { padding: 12px 10px; }
    }
  </style>
</asp:Content>

<asp:Content ID="PQSettingsBody" ContentPlaceHolderID="MainContent" runat="server">
<div class="settings-page">
  <!-- Header -->
  <div class="settings-header">
    <div class="settings-title-area">
      <h1>Quality Performance Settings</h1>
      <p>Configure monthly goals for Yield (%), Scrap ($), and NCM ($) metrics</p>
    </div>
    <div class="header-actions">
      <asp:Button ID="btnSave" runat="server" Text="Save Changes" CssClass="btn-save" OnClick="btnSave_Click" />
      <a href="PlantQualityDashboard.aspx" class="btn-back" onclick="sessionStorage.removeItem('pqd_hasAutoApplied');">
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M19 12H5M12 19l-7-7 7-7"/>
        </svg>
        Back to Dashboard
      </a>
    </div>
  </div>

  <!-- Status Message -->
  <asp:Panel ID="pnlStatus" runat="server" CssClass="status-message" Visible="false">
    <asp:Literal ID="litStatus" runat="server" />
  </asp:Panel>

  <!-- Controls Bar -->
  <div class="controls-bar">
    <div class="control-group">
      <label>Select Year</label>
      <asp:DropDownList ID="ddlYear" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlYear_SelectedIndexChanged">
      </asp:DropDownList>
    </div>
    <div class="control-group">
      <label>Plant</label>
      <asp:DropDownList ID="ddlPlant" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlPlant_SelectedIndexChanged">
        <asp:ListItem Text="YPO" Value="YPO" Selected="True" />
        <asp:ListItem Text="CPO" Value="CPO" />
      </asp:DropDownList>
    </div>
  </div>

  <!-- Goals Tables -->
  <div class="goals-container">
    <!-- Yield Goals -->
    <div class="goal-section">
      <div class="goal-section-header">
        <h2>
          <span class="goal-icon yield">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <polyline points="23 6 13.5 15.5 8.5 10.5 1 18"/>
              <polyline points="17 6 23 6 23 12"/>
            </svg>
          </span>
          First Pass Yield Goals
        </h2>
        <div class="goal-badges">
          <span class="goal-scope">Per Line</span>
          <span class="goal-unit percent">Target %</span>
        </div>
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
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <polyline points="3 6 5 6 21 6"/>
              <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/>
            </svg>
          </span>
          Scrap Cost Goals
        </h2>
        <div class="goal-badges">
          <span class="goal-scope">Per Line</span>
          <span class="goal-unit dollar">Max US$</span>
        </div>
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
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/>
              <line x1="12" y1="9" x2="12" y2="13"/>
              <line x1="12" y1="17" x2="12.01" y2="17"/>
            </svg>
          </span>
          NCM (Non-Conformance Material) Cost Goals
        </h2>
        <div class="goal-badges">
          <span class="goal-scope">Plant Level</span>
          <span class="goal-unit dollar">Max US$</span>
        </div>
      </div>
      <div class="goal-table-wrapper">
        <table class="goal-table" id="ncmGoalsTable">
          <thead>
            <tr>
              <th>Scope</th>
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
  // Format inputs on blur
  document.addEventListener('DOMContentLoaded', function() {
    var dollarInputs = document.querySelectorAll('.dollar-input');
    dollarInputs.forEach(function(input) {
      input.addEventListener('blur', function() {
        var val = parseFloat(this.value.replace(/[^0-9.-]/g, ''));
        if (!isNaN(val)) {
          // Allow 2 decimal places for dollar amounts
          this.value = val.toFixed(2);
        }
      });
    });
    
    var percentInputs = document.querySelectorAll('.percent-input');
    percentInputs.forEach(function(input) {
      input.addEventListener('blur', function() {
        var val = parseFloat(this.value);
        if (!isNaN(val)) {
          // Allow 2 decimal places for percentages
          this.value = val.toFixed(2);
        }
      });
    });
  });
</script>
</asp:Content>
