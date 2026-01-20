<%@ Page Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="PlantQualitySettings.aspx.cs" Inherits="TED_PlantQualitySettings" %>
<asp:Content ID="PQSettingsTitle" ContentPlaceHolderID="TitleContent" runat="server">Quality Performance Settings</asp:Content>
<asp:Content ID="PQSettingsHead" ContentPlaceHolderID="HeadContent" runat="server">
  <style>
    html, body { max-width:100%; overflow-x:hidden; overflow-y:auto !important; }
    
    .settings-page {
      display: flex;
      flex-direction: column;
      min-height: auto;
      padding: 24px 32px 48px;
      box-sizing: border-box;
      gap: 28px;
      width: 100%;
      margin: 0;
    }
    
    /* Toast Notification */
    .toast-notification {
      position: fixed;
      top: 24px;
      right: 24px;
      z-index: 9999;
      padding: 14px 20px;
      border-radius: 10px;
      font-size: 13px;
      font-weight: 600;
      font-family: 'Segoe UI', 'Inter', -apple-system, sans-serif;
      display: flex;
      align-items: center;
      gap: 10px;
      box-shadow: 0 8px 32px rgba(0,0,0,0.15);
      transform: translateX(420px);
      opacity: 0;
      transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    }
    
    .toast-notification.show {
      transform: translateX(0);
      opacity: 1;
    }
    
    .toast-notification.success {
      background: #10b981;
      color: #fff;
    }
    
    .toast-notification.error {
      background: #ef4444;
      color: #fff;
    }
    
    .toast-icon {
      width: 24px;
      height: 24px;
      background: rgba(255,255,255,0.2);
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      flex-shrink: 0;
    }
    
    .toast-icon svg {
      width: 14px;
      height: 14px;
    }
    
    .toast-close {
      margin-left: 8px;
      background: rgba(255,255,255,0.2);
      border: none;
      border-radius: 50%;
      width: 22px;
      height: 22px;
      display: flex;
      align-items: center;
      justify-content: center;
      cursor: pointer;
      color: #fff;
      transition: background 0.2s;
    }
    
    .toast-close:hover {
      background: rgba(255,255,255,0.3);
    }
    
    /* Header */
    .settings-header {
      display: flex;
      justify-content: space-between;
      align-items: flex-start;
      flex-wrap: wrap;
      gap: 16px;
    }
    
    .settings-title-area h1 {
      font-size: 20px;
      font-weight: 600;
      margin: 0;
      color: #1b222b;
      font-family: 'Segoe UI', 'Inter', -apple-system, sans-serif;
    }
    
    html:not(.theme-light):not([data-theme='light']) .settings-title-area h1 { color: #fff; }
    
    .settings-title-area p {
      font-size: 13px;
      color: rgba(0,0,0,0.5);
      margin: 6px 0 0 0;
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
      padding: 8px 14px;
      border-radius: 6px;
      text-decoration: none;
      font-size: 12px;
      font-weight: 500;
      background: transparent;
      color: #6b7280;
      border: 1px solid rgba(0,0,0,0.12);
      transition: all 0.2s;
      font-family: 'Segoe UI', 'Inter', -apple-system, sans-serif;
    }
    
    .btn-back:hover { 
      background: rgba(0,0,0,0.04);
      color: #1b222b;
    }
    
    html:not(.theme-light):not([data-theme='light']) .btn-back {
      color: rgba(255,255,255,0.6);
      border-color: rgba(255,255,255,0.12);
    }
    
    html:not(.theme-light):not([data-theme='light']) .btn-back:hover {
      background: rgba(255,255,255,0.08);
      color: #fff;
    }
    
    .btn-save {
      display: inline-flex;
      align-items: center;
      gap: 6px;
      padding: 8px 16px;
      border-radius: 6px;
      font-size: 12px;
      font-weight: 600;
      background: #10b981;
      color: #fff;
      border: none;
      cursor: pointer;
      transition: all 0.2s;
      font-family: 'Segoe UI', 'Inter', -apple-system, sans-serif;
    }
    
    .btn-save:hover {
      background: #059669;
    }
    
    /* Controls bar */
    .controls-bar {
      display: flex;
      align-items: center;
      gap: 24px;
      flex-wrap: wrap;
    }
    
    .control-group {
      display: flex;
      align-items: center;
      gap: 8px;
    }
    
    .control-group label {
      font-size: 11px;
      font-weight: 500;
      color: rgba(0,0,0,0.5);
      text-transform: uppercase;
      letter-spacing: 0.3px;
      font-family: 'Segoe UI', 'Inter', -apple-system, sans-serif;
    }
    
    html:not(.theme-light):not([data-theme='light']) .control-group label { color: rgba(255,255,255,0.5); }
    
    .control-group select {
      padding: 7px 12px;
      border-radius: 5px;
      border: 1px solid rgba(0,0,0,0.12);
      background: #fff;
      color: #1b222b;
      font-size: 12px;
      font-weight: 600;
      font-family: 'Segoe UI', 'Inter', -apple-system, sans-serif;
      cursor: pointer;
      min-width: 80px;
    }
    
    html:not(.theme-light):not([data-theme='light']) .control-group select {
      background: rgba(255,255,255,0.08);
      border-color: rgba(255,255,255,0.12);
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
      border-radius: 8px;
      overflow: hidden;
    }
    
    html:not(.theme-light):not([data-theme='light']) .goal-section {
      background: rgba(255,255,255,0.03);
      border-color: rgba(255,255,255,0.08);
    }
    
    /* Goal Section Headers - Minimal with color accent */
    .goal-section-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 12px 16px;
      background: transparent;
      border-bottom: 1px solid rgba(0,0,0,0.06);
    }
    
    html:not(.theme-light):not([data-theme='light']) .goal-section-header {
      border-bottom-color: rgba(255,255,255,0.08);
    }
    
    .goal-section-header h2 {
      font-size: 13px;
      font-weight: 600;
      margin: 0;
      font-family: 'Segoe UI', 'Inter', -apple-system, sans-serif;
      display: flex;
      align-items: center;
      gap: 8px;
    }
    
    .goal-section-header.yield h2 { color: #059669; }
    .goal-section-header.scrap h2 { color: #d97706; }
    .goal-section-header.ncm h2 { color: #dc2626; }
    
    html:not(.theme-light):not([data-theme='light']) .goal-section-header.yield h2 { color: #34d399; }
    html:not(.theme-light):not([data-theme='light']) .goal-section-header.scrap h2 { color: #fbbf24; }
    html:not(.theme-light):not([data-theme='light']) .goal-section-header.ncm h2 { color: #f87171; }
    
    .goal-header-icon {
      width: 24px;
      height: 24px;
      border-radius: 5px;
      display: flex;
      align-items: center;
      justify-content: center;
    }
    
    .goal-section-header.yield .goal-header-icon { background: rgba(16,185,129,0.1); }
    .goal-section-header.scrap .goal-header-icon { background: rgba(245,158,11,0.1); }
    .goal-section-header.ncm .goal-header-icon { background: rgba(239,68,68,0.1); }
    
    .goal-header-icon svg {
      width: 14px;
      height: 14px;
      fill: none;
    }
    
    .goal-section-header.yield .goal-header-icon svg { stroke: #059669; }
    .goal-section-header.scrap .goal-header-icon svg { stroke: #d97706; }
    .goal-section-header.ncm .goal-header-icon svg { stroke: #dc2626; }
    
    html:not(.theme-light):not([data-theme='light']) .goal-section-header.yield .goal-header-icon svg { stroke: #34d399; }
    html:not(.theme-light):not([data-theme='light']) .goal-section-header.scrap .goal-header-icon svg { stroke: #fbbf24; }
    html:not(.theme-light):not([data-theme='light']) .goal-section-header.ncm .goal-header-icon svg { stroke: #f87171; }
    
    .goal-badges {
      display: flex;
      align-items: center;
      gap: 6px;
    }
    
    .goal-badge {
      font-size: 9px;
      font-weight: 600;
      padding: 3px 8px;
      border-radius: 3px;
      text-transform: uppercase;
      letter-spacing: 0.3px;
    }
    
    .goal-section-header.yield .goal-badge { background: rgba(16,185,129,0.1); color: #059669; }
    .goal-section-header.scrap .goal-badge { background: rgba(245,158,11,0.1); color: #d97706; }
    .goal-section-header.ncm .goal-badge { background: rgba(239,68,68,0.1); color: #dc2626; }
    
    html:not(.theme-light):not([data-theme='light']) .goal-section-header.yield .goal-badge { background: rgba(16,185,129,0.15); color: #34d399; }
    html:not(.theme-light):not([data-theme='light']) .goal-section-header.scrap .goal-badge { background: rgba(245,158,11,0.15); color: #fbbf24; }
    html:not(.theme-light):not([data-theme='light']) .goal-section-header.ncm .goal-badge { background: rgba(239,68,68,0.15); color: #f87171; }
    
    /* Ledger subsection for Scrap */
    .ledger-subsection {
      border-bottom: 1px solid rgba(0,0,0,0.05);
    }
    
    .ledger-subsection:last-child { border-bottom: none; }
    
    .ledger-title {
      padding: 10px 16px;
      background: rgba(0,0,0,0.02);
      font-size: 11px;
      font-weight: 600;
      color: rgba(0,0,0,0.6);
      text-transform: uppercase;
      letter-spacing: 0.4px;
      font-family: 'Segoe UI', 'Inter', -apple-system, sans-serif;
    }
    
    html:not(.theme-light):not([data-theme='light']) .ledger-title {
      background: rgba(255,255,255,0.03);
      color: rgba(255,255,255,0.6);
    }
    
    /* Table wrapper - ensures horizontal scroll */
    .goal-table-wrapper {
      overflow-x: auto;
      padding: 8px 12px 12px;
      width: 100%;
      box-sizing: border-box;
    }
    
    .goal-table {
      width: 100%;
      min-width: 1000px;
      border-collapse: collapse;
      font-family: 'Segoe UI', 'Inter', -apple-system, sans-serif;
      font-size: 12px;
    }
    
    .goal-table th, .goal-table td {
      padding: 8px 6px;
      text-align: center;
    }
    
    .goal-table th {
      font-weight: 600;
      color: rgba(0,0,0,0.45);
      text-transform: uppercase;
      letter-spacing: 0.2px;
      font-size: 10px;
      padding-bottom: 10px;
      border-bottom: 1px solid rgba(0,0,0,0.08);
      background: transparent;
    }
    
    html:not(.theme-light):not([data-theme='light']) .goal-table th {
      color: rgba(255,255,255,0.45);
      border-bottom-color: rgba(255,255,255,0.08);
    }
    
    .goal-table th:first-child {
      text-align: left;
      width: 110px;
      min-width: 110px;
    }
    
    .goal-table th:nth-child(2) {
      width: 80px;
      min-width: 80px;
    }
    
    .goal-table tbody tr {
      border-bottom: 1px solid rgba(0,0,0,0.04);
    }
    
    .goal-table tbody tr:last-child {
      border-bottom: none;
    }
    
    html:not(.theme-light):not([data-theme='light']) .goal-table tbody tr {
      border-bottom-color: rgba(255,255,255,0.04);
    }
    
    .goal-table td:first-child {
      text-align: left;
      font-weight: 500;
      color: #374151;
      font-size: 12px;
    }
    
    html:not(.theme-light):not([data-theme='light']) .goal-table td:first-child {
      color: rgba(255,255,255,0.85);
    }
    
    .goal-table td:first-child.plant-row {
      color: #3b82f6;
      font-weight: 600;
    }
    
    html:not(.theme-light):not([data-theme='light']) .goal-table td:first-child.plant-row {
      color: #60a5fa;
    }
    
    /* YTD cell styling */
    .ytd-cell {
      font-weight: 600 !important;
      color: #6366f1 !important;
      font-size: 11px;
    }
    
    html:not(.theme-light):not([data-theme='light']) .ytd-cell {
      color: #818cf8 !important;
    }
    
    /* Ledger total row */
    .ledger-total-row td {
      background: rgba(0,0,0,0.02) !important;
      font-weight: 600 !important;
      border-top: 1px solid rgba(0,0,0,0.08) !important;
    }
    
    .ledger-total-row td:first-child { color: #d97706 !important; }
    
    html:not(.theme-light):not([data-theme='light']) .ledger-total-row td {
      background: rgba(255,255,255,0.03) !important;
      border-top-color: rgba(255,255,255,0.08) !important;
    }
    
    html:not(.theme-light):not([data-theme='light']) .ledger-total-row td:first-child {
      color: #fbbf24 !important;
    }
    
    .goal-table tbody tr:hover td {
      background: rgba(59,130,246,0.03);
    }
    
    html:not(.theme-light):not([data-theme='light']) .goal-table tbody tr:hover td {
      background: rgba(59,130,246,0.05);
    }
    
    /* Input styling - clean and minimal */
    .goal-input {
      width: 62px;
      padding: 5px 6px;
      border: 1px solid rgba(0,0,0,0.1);
      border-radius: 4px;
      text-align: center;
      font-size: 11px;
      font-weight: 500;
      font-family: 'Segoe UI', 'Inter', -apple-system, sans-serif;
      background: #fff;
      color: #1b222b;
      transition: all 0.15s;
      box-sizing: border-box;
    }
    
    .goal-input:focus {
      outline: none;
      border-color: #3b82f6;
      box-shadow: 0 0 0 2px rgba(59,130,246,0.1);
    }
    
    html:not(.theme-light):not([data-theme='light']) .goal-input {
      background: rgba(255,255,255,0.05);
      border-color: rgba(255,255,255,0.1);
      color: #fff;
    }
    
    html:not(.theme-light):not([data-theme='light']) .goal-input:focus {
      border-color: #60a5fa;
      box-shadow: 0 0 0 2px rgba(96,165,250,0.15);
    }
    
    /* Input with prefix wrapper */
    .input-wrapper {
      display: inline-flex;
      align-items: center;
      position: relative;
    }
    
    .input-prefix {
      position: absolute;
      left: 5px;
      font-size: 10px;
      color: rgba(0,0,0,0.35);
      font-weight: 500;
      pointer-events: none;
    }
    
    html:not(.theme-light):not([data-theme='light']) .input-prefix {
      color: rgba(255,255,255,0.35);
    }
    
    .input-wrapper .goal-input.dollar-input {
      padding-left: 14px;
      width: 72px;
    }
    
    /* Responsive */
    @media (max-width: 1200px) {
      .settings-page { padding: 16px; }
      .goal-input { width: 58px; font-size: 10px; }
      .input-wrapper .goal-input.dollar-input { width: 68px; }
    }
  </style>
</asp:Content>

<asp:Content ID="PQSettingsBody" ContentPlaceHolderID="MainContent" runat="server">
<!-- Toast Notification -->
<div id="toastNotification" class="toast-notification">
  <span class="toast-icon">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3">
      <polyline points="20 6 9 17 4 12"/>
    </svg>
  </span>
  <span id="toastMessage"></span>
  <button class="toast-close" onclick="hideToast()">
    <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
      <line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>
    </svg>
  </button>
</div>

<!-- Hidden fields for toast message from server -->
<asp:HiddenField ID="hfToastMessage" runat="server" />
<asp:HiddenField ID="hfToastType" runat="server" />

<div class="settings-page">
  <!-- Header -->
  <div class="settings-header">
    <div class="settings-title-area">
      <h1>Quality Performance Settings</h1>
      <p>Configure monthly goals for Yield (%), Scrap ($), and NCM ($) metrics by production line</p>
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
      <div class="goal-section-header yield">
        <h2>
          <span class="goal-header-icon">
            <svg viewBox="0 0 24 24" stroke-width="2">
              <polyline points="23 6 13.5 15.5 8.5 10.5 1 18"/>
              <polyline points="17 6 23 6 23 12"/>
            </svg>
          </span>
          First Pass Yield Goals
        </h2>
        <div class="goal-badges">
          <span class="goal-badge">Per Line</span>
          <span class="goal-badge">Target %</span>
        </div>
      </div>
      <div class="goal-table-wrapper">
        <table class="goal-table" id="yieldGoalsTable">
          <thead>
            <tr>
              <th>Line</th>
              <th>YTD Avg</th>
              <th class="month-header" data-month="1">Jan</th>
              <th class="month-header" data-month="2">Feb</th>
              <th class="month-header" data-month="3">Mar</th>
              <th class="month-header" data-month="4">Apr</th>
              <th class="month-header" data-month="5">May</th>
              <th class="month-header" data-month="6">Jun</th>
              <th class="month-header" data-month="7">Jul</th>
              <th class="month-header" data-month="8">Aug</th>
              <th class="month-header" data-month="9">Sep</th>
              <th class="month-header" data-month="10">Oct</th>
              <th class="month-header" data-month="11">Nov</th>
              <th class="month-header" data-month="12">Dec</th>
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
      <div class="goal-section-header scrap">
        <h2>
          <span class="goal-header-icon">
            <svg viewBox="0 0 24 24" stroke-width="2">
              <path d="M12 2v20M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/>
            </svg>
          </span>
          Scrap Cost Goals
        </h2>
        <div class="goal-badges">
          <span class="goal-badge">Per Line</span>
          <span class="goal-badge">Max US$</span>
        </div>
      </div>
      
      <!-- SPD Ledger -->
      <div class="ledger-subsection" id="scrapSPDSection">
        <div class="ledger-title">SPD Ledger</div>
        <div class="goal-table-wrapper">
          <table class="goal-table" id="scrapSPDTable" data-ledger="SPD">
            <thead>
              <tr>
                <th>Line</th>
                <th>YTD Sum</th>
                <th class="month-header" data-month="1">Jan</th>
                <th class="month-header" data-month="2">Feb</th>
                <th class="month-header" data-month="3">Mar</th>
                <th class="month-header" data-month="4">Apr</th>
                <th class="month-header" data-month="5">May</th>
                <th class="month-header" data-month="6">Jun</th>
                <th class="month-header" data-month="7">Jul</th>
                <th class="month-header" data-month="8">Aug</th>
                <th class="month-header" data-month="9">Sep</th>
                <th class="month-header" data-month="10">Oct</th>
                <th class="month-header" data-month="11">Nov</th>
                <th class="month-header" data-month="12">Dec</th>
              </tr>
            </thead>
            <tbody>
              <asp:Literal ID="litScrapSPDRows" runat="server" />
            </tbody>
          </table>
        </div>
      </div>
      
      <!-- D-IT Ledger -->
      <div class="ledger-subsection" id="scrapDITSection">
        <div class="ledger-title">D-IT Ledger</div>
        <div class="goal-table-wrapper">
          <table class="goal-table" id="scrapDITTable" data-ledger="D-IT">
            <thead>
              <tr>
                <th>Line</th>
                <th>YTD Sum</th>
                <th class="month-header" data-month="1">Jan</th>
                <th class="month-header" data-month="2">Feb</th>
                <th class="month-header" data-month="3">Mar</th>
                <th class="month-header" data-month="4">Apr</th>
                <th class="month-header" data-month="5">May</th>
                <th class="month-header" data-month="6">Jun</th>
                <th class="month-header" data-month="7">Jul</th>
                <th class="month-header" data-month="8">Aug</th>
                <th class="month-header" data-month="9">Sep</th>
                <th class="month-header" data-month="10">Oct</th>
                <th class="month-header" data-month="11">Nov</th>
                <th class="month-header" data-month="12">Dec</th>
              </tr>
            </thead>
            <tbody>
              <asp:Literal ID="litScrapDITRows" runat="server" />
            </tbody>
          </table>
        </div>
      </div>
      
      <!-- Energy Transition Ledger -->
      <div class="ledger-subsection" id="scrapETSection">
        <div class="ledger-title">Energy Transition Ledger</div>
        <div class="goal-table-wrapper">
          <table class="goal-table" id="scrapETTable" data-ledger="EnergyTransition">
            <thead>
              <tr>
                <th>Line</th>
                <th>YTD Sum</th>
                <th class="month-header" data-month="1">Jan</th>
                <th class="month-header" data-month="2">Feb</th>
                <th class="month-header" data-month="3">Mar</th>
                <th class="month-header" data-month="4">Apr</th>
                <th class="month-header" data-month="5">May</th>
                <th class="month-header" data-month="6">Jun</th>
                <th class="month-header" data-month="7">Jul</th>
                <th class="month-header" data-month="8">Aug</th>
                <th class="month-header" data-month="9">Sep</th>
                <th class="month-header" data-month="10">Oct</th>
                <th class="month-header" data-month="11">Nov</th>
                <th class="month-header" data-month="12">Dec</th>
              </tr>
            </thead>
            <tbody>
              <asp:Literal ID="litScrapETRows" runat="server" />
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- NCM Goals -->
    <div class="goal-section">
      <div class="goal-section-header ncm">
        <h2>
          <span class="goal-header-icon">
            <svg viewBox="0 0 24 24" stroke-width="2">
              <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/>
              <line x1="12" y1="9" x2="12" y2="13"/>
              <line x1="12" y1="17" x2="12.01" y2="17"/>
            </svg>
          </span>
          NCM Cost Goals
        </h2>
        <div class="goal-badges">
          <span class="goal-badge">Plant Level</span>
          <span class="goal-badge">Max US$</span>
        </div>
      </div>
      <div class="goal-table-wrapper">
        <table class="goal-table" id="ncmGoalsTable">
          <thead>
            <tr>
              <th>Scope</th>
              <th>YTD Avg</th>
              <th class="month-header" data-month="1">Jan</th>
              <th class="month-header" data-month="2">Feb</th>
              <th class="month-header" data-month="3">Mar</th>
              <th class="month-header" data-month="4">Apr</th>
              <th class="month-header" data-month="5">May</th>
              <th class="month-header" data-month="6">Jun</th>
              <th class="month-header" data-month="7">Jul</th>
              <th class="month-header" data-month="8">Aug</th>
              <th class="month-header" data-month="9">Sep</th>
              <th class="month-header" data-month="10">Oct</th>
              <th class="month-header" data-month="11">Nov</th>
              <th class="month-header" data-month="12">Dec</th>
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
  // Toast notification functions
  var toastTimeout = null;
  
  // Update month headers with 2-digit year
  function updateMonthHeaders() {
    var ddlYear = document.querySelector('select[id$="ddlYear"]');
    if (!ddlYear) return;
    
    var year = ddlYear.value;
    var yearShort = year.toString().slice(-2);
    var monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    document.querySelectorAll('.month-header').forEach(function(th) {
      var monthNum = parseInt(th.dataset.month);
      if (monthNum >= 1 && monthNum <= 12) {
        th.textContent = monthNames[monthNum - 1] + ' \'' + yearShort;
      }
    });
  }
  
  function showToast(message, type) {
    var toast = document.getElementById('toastNotification');
    var toastMsg = document.getElementById('toastMessage');
    
    // Clear any existing timeout
    if (toastTimeout) { clearTimeout(toastTimeout); }
    
    toast.className = 'toast-notification ' + type;
    toastMsg.textContent = message;
    
    // Update icon for error vs success
    var iconSvg = toast.querySelector('.toast-icon svg');
    if (type === 'error') {
      iconSvg.innerHTML = '<circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/>';
    } else {
      iconSvg.innerHTML = '<polyline points="20 6 9 17 4 12"/>';
    }
    
    // Show toast with slight delay for animation
    setTimeout(function() { toast.classList.add('show'); }, 50);
    
    // Auto-hide after 4 seconds
    toastTimeout = setTimeout(function() { hideToast(); }, 4000);
  }
  
  function hideToast() {
    var toast = document.getElementById('toastNotification');
    toast.classList.remove('show');
    if (toastTimeout) { clearTimeout(toastTimeout); toastTimeout = null; }
  }
  
  // Calculate and display YTD values
  function calculateYTD() {
    // Yield tables - Average of non-zero values
    var yieldTable = document.getElementById('yieldGoalsTable');
    if (yieldTable) {
      var rows = yieldTable.querySelectorAll('tbody tr');
      rows.forEach(function(row) {
        var inputs = row.querySelectorAll('input.percent-input');
        var ytdCell = row.querySelector('.ytd-cell');
        if (ytdCell && inputs.length > 0) {
          var sum = 0, count = 0;
          inputs.forEach(function(inp) {
            var val = parseFloat(inp.value) || 0;
            if (val > 0) { sum += val; count++; }
          });
          var avg = count > 0 ? (sum / count) : 0;
          ytdCell.textContent = avg.toFixed(2) + '%';
        }
      });
    }
    
    // Scrap tables - SUM of all values
    var scrapTables = document.querySelectorAll('#scrapSPDTable, #scrapDITTable, #scrapETTable');
    scrapTables.forEach(function(table) {
      var rows = table.querySelectorAll('tbody tr:not(.ledger-total-row)');
      var ledgerTotalRow = table.querySelector('tbody tr.ledger-total-row');
      var ledgerMonthTotals = [0,0,0,0,0,0,0,0,0,0,0,0];
      
      rows.forEach(function(row) {
        var inputs = row.querySelectorAll('input.dollar-input');
        var ytdCell = row.querySelector('.ytd-cell');
        if (ytdCell && inputs.length > 0) {
          var sum = 0;
          inputs.forEach(function(inp, idx) {
            var val = parseFloat(inp.value.replace(/[^0-9.-]/g, '')) || 0;
            sum += val;
            if (idx < 12) ledgerMonthTotals[idx] += val;
          });
          ytdCell.textContent = '$' + sum.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ',');
        }
      });
      
      // Update ledger total row
      if (ledgerTotalRow) {
        var totalCells = ledgerTotalRow.querySelectorAll('td:not(:first-child):not(.ytd-cell)');
        var ytdTotalCell = ledgerTotalRow.querySelector('.ytd-cell');
        var grandTotal = 0;
        totalCells.forEach(function(cell, idx) {
          if (idx < 12) {
            cell.textContent = '$' + ledgerMonthTotals[idx].toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ',');
            grandTotal += ledgerMonthTotals[idx];
          }
        });
        if (ytdTotalCell) {
          ytdTotalCell.textContent = '$' + grandTotal.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ',');
        }
      }
    });
    
    // NCM table - AVERAGE of non-zero values
    var ncmTable = document.getElementById('ncmGoalsTable');
    if (ncmTable) {
      var rows = ncmTable.querySelectorAll('tbody tr');
      rows.forEach(function(row) {
        var inputs = row.querySelectorAll('input.dollar-input');
        var ytdCell = row.querySelector('.ytd-cell');
        if (ytdCell && inputs.length > 0) {
          var sum = 0, count = 0;
          inputs.forEach(function(inp) {
            var val = parseFloat(inp.value.replace(/[^0-9.-]/g, '')) || 0;
            if (val > 0) { sum += val; count++; }
          });
          var avg = count > 0 ? (sum / count) : 0;
          ytdCell.textContent = '$' + avg.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ',');
        }
      });
    }
  }
  
  // Initialize on page load
  document.addEventListener('DOMContentLoaded', function() {
    // Check for server-side toast message
    var hfMessage = document.getElementById('<%= hfToastMessage.ClientID %>');
    var hfType = document.getElementById('<%= hfToastType.ClientID %>');
    
    if (hfMessage && hfMessage.value) {
      showToast(hfMessage.value, hfType ? hfType.value : 'success');
      hfMessage.value = '';
    }
    
    // Calculate initial YTD values
    calculateYTD();
    
    // Update month headers with year
    updateMonthHeaders();
    
    // Add blur handlers to recalculate YTD
    var dollarInputs = document.querySelectorAll('.dollar-input');
    dollarInputs.forEach(function(input) {
      input.addEventListener('blur', function() {
        var val = parseFloat(this.value.replace(/[^0-9.-]/g, ''));
        if (!isNaN(val)) { this.value = val.toFixed(2); }
        calculateYTD();
      });
    });
    
    var percentInputs = document.querySelectorAll('.percent-input');
    percentInputs.forEach(function(input) {
      input.addEventListener('blur', function() {
        var val = parseFloat(this.value);
        if (!isNaN(val)) { this.value = val.toFixed(2); }
        calculateYTD();
      });
    });
  });
</script>
</asp:Content>
