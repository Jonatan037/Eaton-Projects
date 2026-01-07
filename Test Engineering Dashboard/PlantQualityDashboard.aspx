<%@ Page Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="PlantQualityDashboard.aspx.cs" Inherits="TED_PlantQualityDashboard" %>
<asp:Content ID="PQDashTitle" ContentPlaceHolderID="TitleContent" runat="server">Plant Quality Performance Report</asp:Content>
<asp:Content ID="PQDashHead" ContentPlaceHolderID="HeadContent" runat="server">
  <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/chartjs-plugin-datalabels@2.2.0/dist/chartjs-plugin-datalabels.min.js"></script>
  <style>
    html, body { max-width:100%; overflow-x:hidden; overflow-y:auto !important; }
    
    .quality-dashboard {
      display: flex;
      flex-direction: column;
      min-height: auto;
      padding: 12px 20px 24px;
      box-sizing: border-box;
      gap: 12px;
    }
    
    /* Header */
    .dash-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      flex-wrap: wrap;
      gap: 8px;
    }
    
    .dash-title-area h1 {
      font-size: 18px;
      font-weight: 600;
      margin: 0;
      color: #1b222b;
    }
    
    html:not(.theme-light):not([data-theme='light']) .dash-title-area h1 { color: #fff; }
    
    .dash-title-area .title-filter-context {
      font-size: 11px;
      font-weight: 400;
      color: rgba(0,0,0,0.55);
      margin-top: 2px;
      font-family: 'Inter', 'Segoe UI', -apple-system, BlinkMacSystemFont, sans-serif;
      letter-spacing: 0.2px;
    }
    
    html:not(.theme-light):not([data-theme='light']) .dash-title-area .title-filter-context { color: rgba(255,255,255,0.5); }
    
    .header-actions {
      display: flex;
      align-items: center;
      gap: 8px;
    }
    
    .header-icon-btn {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      width: 34px;
      height: 34px;
      border-radius: 8px;
      background: rgba(0,0,0,0.05);
      border: 1px solid rgba(0,0,0,0.08);
      color: #1b222b;
      cursor: pointer;
      transition: all 0.2s;
    }
    
    .header-icon-btn:hover {
      background: rgba(59,130,246,0.1);
      border-color: rgba(59,130,246,0.3);
      color: #3b82f6;
    }
    
    .header-icon-btn.filter-active {
      background: rgba(59,130,246,0.15);
      border-color: #3b82f6;
      color: #3b82f6;
    }
    
    html:not(.theme-light):not([data-theme='light']) .header-icon-btn {
      background: rgba(255,255,255,0.08);
      border-color: rgba(255,255,255,0.1);
      color: #fff;
    }
    
    html:not(.theme-light):not([data-theme='light']) .header-icon-btn:hover {
      background: rgba(59,130,246,0.2);
      border-color: rgba(59,130,246,0.4);
      color: #60a5fa;
    }
    
    html:not(.theme-light):not([data-theme='light']) .header-icon-btn.filter-active {
      background: rgba(59,130,246,0.25);
      border-color: #60a5fa;
      color: #60a5fa;
    }
    
    /* Filter Modal */
    .modal-overlay {
      display: none;
      position: fixed;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      background: rgba(0,0,0,0.5);
      z-index: 1000;
      align-items: center;
      justify-content: center;
      backdrop-filter: blur(2px);
    }
    
    .modal-overlay.active { display: flex; }
    
    .modal-content {
      background: #fff;
      border-radius: 12px;
      box-shadow: 0 20px 60px rgba(0,0,0,0.2);
      max-width: 480px;
      width: 90%;
      max-height: 85vh;
      overflow: auto;
    }
    
    html:not(.theme-light):not([data-theme='light']) .modal-content {
      background: #1b222b;
      box-shadow: 0 20px 60px rgba(0,0,0,0.5);
    }
    
    .modal-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 16px 20px;
      border-bottom: 1px solid rgba(0,0,0,0.08);
    }
    
    html:not(.theme-light):not([data-theme='light']) .modal-header { border-color: rgba(255,255,255,0.08); }
    
    .modal-header h3 {
      font-size: 14px;
      font-weight: 600;
      margin: 0;
      color: #1b222b;
      font-family: 'Segoe UI', 'Inter', -apple-system, sans-serif;
    }
    
    html:not(.theme-light):not([data-theme='light']) .modal-header h3 { color: #fff; }
    
    .modal-close {
      background: none;
      border: none;
      cursor: pointer;
      padding: 4px;
      color: rgba(0,0,0,0.4);
      transition: color 0.2s;
    }
    
    .modal-close:hover { color: #1b222b; }
    html:not(.theme-light):not([data-theme='light']) .modal-close { color: rgba(255,255,255,0.4); }
    html:not(.theme-light):not([data-theme='light']) .modal-close:hover { color: #fff; }
    
    .modal-body {
      padding: 20px;
    }
    
    .filter-section {
      margin-bottom: 20px;
    }
    
    .filter-section:last-child { margin-bottom: 0; }
    
    .filter-section-label {
      font-size: 10px;
      font-weight: 600;
      color: rgba(0,0,0,0.5);
      text-transform: uppercase;
      letter-spacing: 0.5px;
      margin-bottom: 10px;
      font-family: 'Segoe UI', 'Inter', -apple-system, sans-serif;
    }
    
    html:not(.theme-light):not([data-theme='light']) .filter-section-label { color: rgba(255,255,255,0.5); }
    
    /* Line selection chips */
    .line-chips {
      display: flex;
      flex-wrap: wrap;
      gap: 6px;
    }
    
    .line-chip {
      padding: 6px 12px;
      border-radius: 16px;
      border: 1px solid rgba(0,0,0,0.12);
      background: transparent;
      color: #1b222b;
      font-size: 11px;
      font-weight: 500;
      cursor: pointer;
      transition: all 0.2s;
      font-family: 'Segoe UI', 'Inter', -apple-system, sans-serif;
    }
    
    .line-chip:hover {
      border-color: rgba(59,130,246,0.4);
      background: rgba(59,130,246,0.05);
    }
    
    .line-chip.selected {
      background: #3b82f6;
      border-color: #3b82f6;
      color: #fff;
    }
    
    html:not(.theme-light):not([data-theme='light']) .line-chip {
      border-color: rgba(255,255,255,0.15);
      color: #fff;
    }
    
    html:not(.theme-light):not([data-theme='light']) .line-chip:hover {
      border-color: rgba(96,165,250,0.5);
      background: rgba(96,165,250,0.1);
    }
    
    html:not(.theme-light):not([data-theme='light']) .line-chip.selected {
      background: #3b82f6;
      border-color: #3b82f6;
    }
    
    /* Date range presets */
    .date-presets {
      display: flex;
      flex-wrap: wrap;
      gap: 6px;
      margin-bottom: 12px;
    }
    
    .date-preset {
      padding: 6px 12px;
      border-radius: 6px;
      border: 1px solid rgba(0,0,0,0.12);
      background: transparent;
      color: #1b222b;
      font-size: 11px;
      font-weight: 500;
      cursor: pointer;
      transition: all 0.2s;
      font-family: 'Segoe UI', 'Inter', -apple-system, sans-serif;
    }
    
    .date-preset:hover {
      border-color: rgba(59,130,246,0.4);
      background: rgba(59,130,246,0.05);
    }
    
    .date-preset.selected {
      background: #3b82f6;
      border-color: #3b82f6;
      color: #fff;
    }
    
    html:not(.theme-light):not([data-theme='light']) .date-preset {
      border-color: rgba(255,255,255,0.15);
      color: #fff;
    }
    
    html:not(.theme-light):not([data-theme='light']) .date-preset:hover {
      border-color: rgba(96,165,250,0.5);
      background: rgba(96,165,250,0.1);
    }
    
    html:not(.theme-light):not([data-theme='light']) .date-preset.selected {
      background: #3b82f6;
      border-color: #3b82f6;
    }
    
    .custom-date-range {
      display: none;
      gap: 12px;
      margin-top: 12px;
      flex-wrap: wrap;
    }
    
    .custom-date-range.active { display: flex; }
    
    .date-input-group {
      flex: 1;
      min-width: 140px;
    }
    
    .date-input-group label {
      display: block;
      font-size: 9px;
      font-weight: 500;
      color: rgba(0,0,0,0.5);
      text-transform: uppercase;
      margin-bottom: 4px;
    }
    
    html:not(.theme-light):not([data-theme='light']) .date-input-group label { color: rgba(255,255,255,0.5); }
    
    .date-input-group input {
      width: 100%;
      padding: 8px 10px;
      border-radius: 6px;
      border: 1px solid rgba(0,0,0,0.12);
      background: #fff;
      color: #1b222b;
      font-size: 12px;
      font-family: 'Segoe UI', 'Inter', -apple-system, sans-serif;
      box-sizing: border-box;
    }
    
    html:not(.theme-light):not([data-theme='light']) .date-input-group input {
      background: rgba(255,255,255,0.06);
      border-color: rgba(255,255,255,0.12);
      color: #fff;
    }
    
    .modal-footer {
      display: flex;
      justify-content: flex-end;
      gap: 8px;
      padding: 16px 20px;
      border-top: 1px solid rgba(0,0,0,0.08);
    }
    
    html:not(.theme-light):not([data-theme='light']) .modal-footer { border-color: rgba(255,255,255,0.08); }
    
    .btn-modal {
      padding: 8px 16px;
      border-radius: 6px;
      font-size: 12px;
      font-weight: 600;
      cursor: pointer;
      transition: all 0.2s;
      font-family: 'Segoe UI', 'Inter', -apple-system, sans-serif;
    }
    
    .btn-modal-secondary {
      background: transparent;
      border: 1px solid rgba(0,0,0,0.12);
      color: #1b222b;
    }
    
    .btn-modal-secondary:hover {
      background: rgba(0,0,0,0.05);
    }
    
    html:not(.theme-light):not([data-theme='light']) .btn-modal-secondary {
      border-color: rgba(255,255,255,0.15);
      color: #fff;
    }
    
    html:not(.theme-light):not([data-theme='light']) .btn-modal-secondary:hover {
      background: rgba(255,255,255,0.05);
    }
    
    .btn-modal-primary {
      background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
      border: none;
      color: #fff;
    }
    
    .btn-modal-primary:hover {
      box-shadow: 0 4px 12px rgba(59,130,246,0.4);
    }
    
    /* Charts row - 3 charts in one line */
    .charts-row {
      display: grid;
      grid-template-columns: 20% 50% 30%;
      gap: 12px;
    }
    
    @media (max-width: 1100px) {
      .charts-row { grid-template-columns: 1fr 1fr; }
      .charts-row .chart-panel:first-child { grid-column: 1 / -1; }
    }
    
    @media (max-width: 700px) {
      .charts-row { grid-template-columns: 1fr; }
    }
    
    /* Chart panels */
    .chart-panel {
      background: rgba(255,255,255,0.8);
      border: 1px solid rgba(0,0,0,0.05);
      border-radius: 10px;
      padding: 12px;
      display: flex;
      flex-direction: column;
      box-shadow: 0 1px 3px rgba(0,0,0,0.03);
    }
    
    html:not(.theme-light):not([data-theme='light']) .chart-panel {
      background: rgba(255,255,255,0.03);
      border-color: rgba(255,255,255,0.05);
    }
    
    .panel-header {
      display: flex;
      justify-content: space-between;
      align-items: flex-start;
      margin-bottom: 8px;
      gap: 8px;
    }
    
    .panel-header h2 {
      font-size: 11px;
      font-weight: 600;
      font-family: 'Segoe UI', 'Inter', -apple-system, sans-serif;
      margin: 0;
      color: #1b222b;
    }
    
    html:not(.theme-light):not([data-theme='light']) .panel-header h2 { color: #fff; }
    
    .panel-header .panel-subtitle {
      font-size: 9px;
      font-family: 'Inter', 'Segoe UI', -apple-system, BlinkMacSystemFont, sans-serif;
      color: rgba(0,0,0,0.55);
      margin-top: 1px;
      letter-spacing: 0.15px;
      font-weight: 400;
    }
    
    html:not(.theme-light):not([data-theme='light']) .panel-header .panel-subtitle { color: rgba(255,255,255,0.5); }
    
    /* Chart toggle selector - Modern pill style */
    .chart-toggle {
      display: flex;
      background: rgba(0,0,0,0.06);
      border-radius: 6px;
      padding: 3px;
      gap: 3px;
    }
    
    html:not(.theme-light):not([data-theme='light']) .chart-toggle { background: rgba(255,255,255,0.1); }
    
    .chart-toggle button {
      padding: 4px 10px;
      border: none;
      background: transparent;
      color: rgba(0,0,0,0.55);
      font-size: 10px;
      font-weight: 600;
      font-family: 'Segoe UI', 'Inter', -apple-system, sans-serif;
      border-radius: 4px;
      cursor: pointer;
      transition: all 0.2s ease;
      letter-spacing: 0.3px;
    }
    
    html:not(.theme-light):not([data-theme='light']) .chart-toggle button { color: rgba(255,255,255,0.55); }
    
    .chart-toggle button:hover {
      background: rgba(0,0,0,0.04);
    }
    
    html:not(.theme-light):not([data-theme='light']) .chart-toggle button:hover { background: rgba(255,255,255,0.05); }
    
    .chart-toggle button.active {
      background: #3b82f6;
      color: #fff;
      box-shadow: 0 2px 4px rgba(59,130,246,0.3);
    }
    
    html:not(.theme-light):not([data-theme='light']) .chart-toggle button.active {
      background: #3b82f6;
      color: #fff;
      box-shadow: 0 2px 4px rgba(59,130,246,0.4);
    }
    
    /* Drill up/down buttons */
    .drill-btn {
      width: 24px;
      height: 24px;
      border: none;
      background: rgba(0,0,0,0.06);
      color: rgba(0,0,0,0.6);
      border-radius: 5px;
      cursor: pointer;
      display: flex;
      align-items: center;
      justify-content: center;
      transition: all 0.2s ease;
      flex-shrink: 0;
    }
    
    .drill-btn:hover {
      background: rgba(59,130,246,0.15);
      color: #3b82f6;
    }
    
    html:not(.theme-light):not([data-theme='light']) .drill-btn {
      background: rgba(255,255,255,0.1);
      color: rgba(255,255,255,0.6);
    }
    
    html:not(.theme-light):not([data-theme='light']) .drill-btn:hover {
      background: rgba(59,130,246,0.25);
      color: #60a5fa;
    }
    
    /* Gauge container */
    .gauge-container {
      flex: 1;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      min-height: 140px;
    }
    
    /* Large gauge for Gauge-only view */
    .gauge-container.gauge-large {
      min-height: 200px;
      flex: 1;
    }
    
    .gauge-wrapper-large {
      width: 100% !important;
      max-width: 320px !important;
      height: 160px !important;
    }
    
    .gauge-wrapper-large .gauge-svg {
      width: 100%;
      height: 100%;
    }
    
    .gauge-center-large {
      bottom: 15px !important;
    }
    
    .gauge-value-large {
      font-size: 28px !important;
      font-weight: 800 !important;
    }
    
    .gauge-label-large {
      font-size: 10px !important;
    }
    
    /* Table-only view centered */
    .table-view-container {
      flex: 1;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 8px;
    }
    
    .line-table-centered {
      width: 100%;
      max-width: none;
      overflow: visible;
    }
    
    .line-table-large {
      font-size: 11px;
    }
    
    .line-table-large th,
    .line-table-large td {
      padding: 6px 10px;
    }
    
    /* Both view container */
    .both-view-container {
      display: flex;
      flex-direction: column;
      flex: 1;
    }
    
    .gauge-view-container {
      flex: 1;
      display: flex;
      align-items: center;
      justify-content: center;
    }
    
    .gauge-wrapper {
      position: relative;
      width: 220px;
      height: 110px;
    }
    
    .gauge-svg {
      width: 100%;
      height: 100%;
    }
    
    .gauge-center {
      position: absolute;
      bottom: 8px;
      left: 50%;
      transform: translateX(-50%);
      text-align: center;
    }
    
    .gauge-value {
      font-size: 18px;
      font-weight: 700;
      font-family: 'Segoe UI', 'Inter', -apple-system, sans-serif;
      color: #1b222b;
      line-height: 1;
    }
    
    html:not(.theme-light):not([data-theme='light']) .gauge-value { color: #fff; }
    
    .gauge-label {
      font-size: 8px;
      font-family: 'Segoe UI', 'Inter', -apple-system, sans-serif;
      color: rgba(0,0,0,0.5);
      margin-top: 1px;
    }
    
    html:not(.theme-light):not([data-theme='light']) .gauge-label { color: rgba(255,255,255,0.5); }
    
    .gauge-meta {
      display: flex;
      gap: 16px;
      margin-top: 8px;
      padding-top: 8px;
      border-top: 1px solid rgba(0,0,0,0.06);
    }
    
    html:not(.theme-light):not([data-theme='light']) .gauge-meta { border-color: rgba(255,255,255,0.06); }
    
    .gauge-stat {
      text-align: center;
    }
    
    .gauge-stat-value {
      font-size: 12px;
      font-weight: 600;
      font-family: 'Segoe UI', 'Inter', -apple-system, sans-serif;
      color: #1b222b;
    }
    
    html:not(.theme-light):not([data-theme='light']) .gauge-stat-value { color: #fff; }
    
    .gauge-stat-label {
      font-size: 8px;
      font-family: 'Segoe UI', 'Inter', -apple-system, sans-serif;
      color: rgba(0,0,0,0.4);
      text-transform: uppercase;
      letter-spacing: 0.3px;
    }
    
    html:not(.theme-light):not([data-theme='light']) .gauge-stat-label { color: rgba(255,255,255,0.4); }
    
    .status-good { color: #10b981 !important; }
    .status-danger { color: #ef4444 !important; }
    
    /* Compact gauge for table below */
    .gauge-container.compact {
      min-height: 100px;
      flex: 0;
    }
    
    /* Line breakdown table */
    .line-table-container {
      flex: 1;
      overflow: hidden;
      margin-top: 8px;
      border-top: 1px solid rgba(0,0,0,0.06);
      padding-top: 8px;
    }
    
    html:not(.theme-light):not([data-theme='light']) .line-table-container { border-color: rgba(255,255,255,0.06); }
    
    .line-table {
      width: 100%;
      font-size: 9px;
      font-family: 'Segoe UI', 'Inter', -apple-system, sans-serif;
      border-collapse: collapse;
    }
    
    .line-table th, .line-table td {
      padding: 3px 4px;
      text-align: right;
    }
    
    .line-table th:first-child, .line-table td:first-child {
      text-align: left;
    }
    
    .line-table th {
      font-weight: 600;
      color: rgba(0,0,0,0.5);
      text-transform: uppercase;
      letter-spacing: 0.3px;
      font-size: 8px;
      border-bottom: 1px solid rgba(0,0,0,0.08);
    }
    
    html:not(.theme-light):not([data-theme='light']) .line-table th { 
      color: rgba(255,255,255,0.5); 
      border-bottom-color: rgba(255,255,255,0.08);
    }
    
    .line-table td {
      color: #1b222b;
    }
    
    html:not(.theme-light):not([data-theme='light']) .line-table td { color: #fff; }
    
    .line-table tbody tr:hover {
      background: rgba(0,0,0,0.02);
    }
    
    html:not(.theme-light):not([data-theme='light']) .line-table tbody tr:hover { background: rgba(255,255,255,0.02); }
    
    .line-table tfoot tr {
      font-weight: 600;
      border-top: 1px solid rgba(0,0,0,0.1);
    }
    
    html:not(.theme-light):not([data-theme='light']) .line-table tfoot tr { border-top-color: rgba(255,255,255,0.1); }
    
    .line-table .passed { color: #10b981; }
    .line-table .failed { color: #ef4444; }
    
    /* Chart containers */
    .chart-container {
      flex: 1;
      min-height: 180px;
      position: relative;
    }
    
    /* Scrollable chart wrapper for many data points */
    .chart-scroll-wrapper {
      width: 100%;
      height: 100%;
      overflow-x: auto;
      overflow-y: hidden;
    }
    
    .chart-scroll-wrapper::-webkit-scrollbar {
      height: 6px;
    }
    
    .chart-scroll-wrapper::-webkit-scrollbar-track {
      background: rgba(0,0,0,0.05);
      border-radius: 3px;
    }
    
    .chart-scroll-wrapper::-webkit-scrollbar-thumb {
      background: rgba(0,0,0,0.15);
      border-radius: 3px;
    }
    
    .chart-scroll-wrapper::-webkit-scrollbar-thumb:hover {
      background: rgba(0,0,0,0.25);
    }
    
    html:not(.theme-light):not([data-theme='light']) .chart-scroll-wrapper::-webkit-scrollbar-track {
      background: rgba(255,255,255,0.05);
    }
    
    html:not(.theme-light):not([data-theme='light']) .chart-scroll-wrapper::-webkit-scrollbar-thumb {
      background: rgba(255,255,255,0.15);
    }
    
    html:not(.theme-light):not([data-theme='light']) .chart-scroll-wrapper::-webkit-scrollbar-thumb:hover {
      background: rgba(255,255,255,0.25);
    }
    
    .chart-scroll-inner {
      height: 100%;
      min-width: 100%;
    }
    
    /* Data table view for charts */
    .data-table-view {
      width: 100%;
      height: 100%;
      overflow: auto;
      font-family: 'Inter', 'Segoe UI', -apple-system, sans-serif;
    }
    
    .data-table-view table {
      width: 100%;
      border-collapse: collapse;
      font-size: 9px;
    }
    
    .data-table-view th,
    .data-table-view td {
      padding: 4px 6px;
      text-align: center;
      border: 1px solid rgba(0,0,0,0.08);
      white-space: nowrap;
    }
    
    html:not(.theme-light):not([data-theme='light']) .data-table-view th,
    html:not(.theme-light):not([data-theme='light']) .data-table-view td {
      border-color: rgba(255,255,255,0.1);
    }
    
    .data-table-view th {
      background: rgba(0,0,0,0.04);
      font-weight: 600;
      color: #1b222b;
      position: sticky;
      top: 0;
      z-index: 1;
    }
    
    html:not(.theme-light):not([data-theme='light']) .data-table-view th {
      background: rgba(255,255,255,0.08);
      color: #fff;
    }
    
    .data-table-view th:first-child {
      position: sticky;
      left: 0;
      z-index: 2;
    }
    
    .data-table-view td:first-child {
      position: sticky;
      left: 0;
      background: rgba(255,255,255,0.95);
      font-weight: 600;
      text-align: left;
      z-index: 1;
    }
    
    html:not(.theme-light):not([data-theme='light']) .data-table-view td:first-child {
      background: rgba(30,35,45,0.98);
    }
    
    .data-table-view td.cell-good {
      background: rgba(16,185,129,0.15);
      color: #059669;
    }
    
    .data-table-view td.cell-bad {
      background: rgba(239,68,68,0.15);
      color: #dc2626;
    }
    
    html:not(.theme-light):not([data-theme='light']) .data-table-view td.cell-good {
      background: rgba(16,185,129,0.2);
      color: #34d399;
    }
    
    html:not(.theme-light):not([data-theme='light']) .data-table-view td.cell-bad {
      background: rgba(239,68,68,0.2);
      color: #f87171;
    }
    
    .data-table-view tfoot td {
      font-weight: 700;
      background: rgba(0,0,0,0.03) !important;
    }
    
    html:not(.theme-light):not([data-theme='light']) .data-table-view tfoot td {
      background: rgba(255,255,255,0.05) !important;
    }
    
    /* Coming soon section */
    .section-divider {
      display: flex;
      align-items: center;
      gap: 12px;
      padding: 4px 0;
      margin-top: 8px;
    }
    
    .section-divider::before,
    .section-divider::after {
      content: '';
      flex: 1;
      height: 1px;
      background: linear-gradient(90deg, transparent, rgba(0,0,0,0.06), transparent);
    }
    
    html:not(.theme-light):not([data-theme='light']) .section-divider::before,
    html:not(.theme-light):not([data-theme='light']) .section-divider::after {
      background: linear-gradient(90deg, transparent, rgba(255,255,255,0.06), transparent);
    }
    
    .section-divider span {
      font-size: 9px;
      font-weight: 600;
      text-transform: uppercase;
      letter-spacing: 0.8px;
      color: rgba(0,0,0,0.35);
      padding: 3px 10px;
      background: rgba(0,0,0,0.03);
      border-radius: 12px;
    }
    
    html:not(.theme-light):not([data-theme='light']) .section-divider span {
      color: rgba(255,255,255,0.35);
      background: rgba(255,255,255,0.03);
    }
    
    .coming-soon-row {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 12px;
    }
    
    .coming-soon-panel {
      display: flex;
      align-items: center;
      justify-content: center;
      min-height: 100px;
      color: rgba(0,0,0,0.3);
      font-size: 11px;
      font-style: italic;
    }
    
    html:not(.theme-light):not([data-theme='light']) .coming-soon-panel { color: rgba(255,255,255,0.3); }
    
    .hf-container { display: none; }
  </style>
</asp:Content>

<asp:Content ID="PQDashBody" ContentPlaceHolderID="MainContent" runat="server">
<div class="quality-dashboard">
  <!-- Header -->
  <div class="dash-header">
    <div class="dash-title-area">
      <h1>Plant Quality Performance Report</h1>
      <div class="title-filter-context" id="titleFilterContext">Plantwide  |  MTD</div>
    </div>
    <div class="header-actions">
      <button type="button" class="header-icon-btn" id="filterIconBtn" onclick="openFilterModal()" title="Filters">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <polygon points="22 3 2 3 10 12.46 10 19 14 21 14 12.46 22 3"/>
        </svg>
      </button>
      <button type="button" class="header-icon-btn" onclick="window.location.href='PlantQualitySettings.aspx'" title="Settings">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <circle cx="12" cy="12" r="3"></circle>
          <path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"></path>
        </svg>
      </button>
    </div>
  </div>

  <!-- Filter Modal -->
  <div class="modal-overlay" id="filterModal">
    <div class="modal-content">
      <div class="modal-header">
        <h3>Filters</h3>
        <button type="button" class="modal-close" onclick="closeFilterModal()">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <line x1="18" y1="6" x2="6" y2="18"></line>
            <line x1="6" y1="6" x2="18" y2="18"></line>
          </svg>
        </button>
      </div>
      <div class="modal-body">
        <!-- Line Selection -->
        <div class="filter-section">
          <div class="filter-section-label">Production Line</div>
          <div class="line-chips" id="lineChips">
            <button type="button" class="line-chip selected" data-value="ALL">Plantwide</button>
            <!-- Lines populated dynamically -->
          </div>
        </div>
        
        <!-- Date Range -->
        <div class="filter-section">
          <div class="filter-section-label">Date Range</div>
          <div class="date-presets" id="datePresets">
            <button type="button" class="date-preset" data-value="YTD">YTD</button>
            <button type="button" class="date-preset selected" data-value="MTD">MTD</button>
            <button type="button" class="date-preset" data-value="WEEK">Week</button>
            <button type="button" class="date-preset" data-value="YESTERDAY">Yesterday</button>
            <button type="button" class="date-preset" data-value="TODAY">Today</button>
            <button type="button" class="date-preset" data-value="CUSTOM">Custom</button>
          </div>
          <div class="custom-date-range" id="customDateRange">
            <div class="date-input-group">
              <label>Start Date</label>
              <input type="date" id="modalStartDate" />
            </div>
            <div class="date-input-group">
              <label>End Date</label>
              <input type="date" id="modalEndDate" />
            </div>
          </div>
        </div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn-modal btn-modal-secondary" onclick="resetFilters()">Reset</button>
        <button type="button" class="btn-modal btn-modal-primary" onclick="applyFilters()">Apply Filters</button>
      </div>
    </div>
  </div>

  <!-- Hidden ASP.NET controls for postback -->
  <div style="display:none;">
    <asp:DropDownList ID="ddlPlant" runat="server">
      <asp:ListItem Text="YPO" Value="YPO" Selected="True" />
      <asp:ListItem Text="CPO" Value="CPO" />
    </asp:DropDownList>
    <asp:DropDownList ID="ddlLine" runat="server">
      <asp:ListItem Text="All Lines" Value="ALL" />
    </asp:DropDownList>
    <asp:TextBox ID="txtStartDate" runat="server" TextMode="Date" />
    <asp:TextBox ID="txtEndDate" runat="server" TextMode="Date" />
    <asp:Button ID="btnRefresh" runat="server" Text="Apply" OnClick="btnRefresh_Click" />
  </div>

  <!-- Main Charts Row - 3 charts in one line -->
  <div class="charts-row">
    <!-- Yield Gauge -->
    <div class="chart-panel" id="yieldGaugePanel">
      <div class="panel-header">
        <div>
          <h2>First Pass Yield</h2>
          <p class="panel-subtitle" id="yieldSubtitle">Plantwide | Month to date</p>
        </div>
        <div class="chart-toggle" id="gaugeToggle">
          <button type="button" onclick="setGaugeViewType('gauge')">Gauge</button>
          <button type="button" onclick="setGaugeViewType('table')">Table</button>
          <button type="button" class="active" onclick="setGaugeViewType('both')">Both</button>
        </div>
      </div>
      <!-- Gauge view (hidden by default) -->
      <div class="gauge-view-container" id="gaugeViewContainer" style="display:none;">
        <div class="gauge-container gauge-large" id="gaugeOnlyView">
          <div class="gauge-wrapper gauge-wrapper-large">
            <svg class="gauge-svg" id="yieldGaugeSvg" viewBox="0 0 220 110"></svg>
            <div class="gauge-center gauge-center-large">
              <div class="gauge-value gauge-value-large" id="gaugeValueDisplay">--</div>
              <div class="gauge-label gauge-label-large">Yield %</div>
            </div>
          </div>
        </div>
      </div>
      <!-- Table only view (hidden by default) -->
      <div class="table-view-container" id="tableOnlyView" style="display:none;">
        <div class="line-table-container line-table-centered">
          <table class="line-table line-table-large" id="lineTableLarge">
            <thead>
              <tr>
                <th>Line</th>
                <th>Tested</th>
                <th>Pass / Fail</th>
                <th>Yield</th>
              </tr>
            </thead>
            <tbody id="lineTableBodyLarge">
            </tbody>
            <tfoot id="lineTableFootLarge">
            </tfoot>
          </table>
        </div>
      </div>
      <!-- Both view (default - visible) -->
      <div class="both-view-container" id="bothView">
        <div class="gauge-container compact">
          <div class="gauge-wrapper">
            <svg class="gauge-svg" id="yieldGaugeSvgSmall" viewBox="0 0 220 110"></svg>
            <div class="gauge-center">
              <div class="gauge-value" id="gaugeValueDisplaySmall">--</div>
              <div class="gauge-label">Yield %</div>
            </div>
          </div>
        </div>
        <div class="line-table-container" id="lineTableContainerSmall">
          <table class="line-table" id="lineTableSmall">
            <thead>
              <tr>
                <th>Line</th>
                <th>Tested</th>
                <th>Pass / Fail</th>
                <th>Yield</th>
              </tr>
            </thead>
            <tbody id="lineTableBodySmall">
            </tbody>
            <tfoot id="lineTableFootSmall">
            </tfoot>
          </table>
        </div>
      </div>
    </div>

    <!-- Yield Daily Chart -->
    <div class="chart-panel">
      <div class="panel-header">
        <div style="display:flex;align-items:center;gap:10px;">
          <button type="button" class="drill-btn" id="drillDownBtn" onclick="drillDown()" title="Drill Down" style="display:none;">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M6 9l6 6 6-6"/>
            </svg>
          </button>
          <div>
            <h2 id="yieldChartTitle">Yield Daily</h2>
            <p class="panel-subtitle" id="yieldDailySubtitle">Plantwide | Month to date</p>
          </div>
          <button type="button" class="drill-btn" id="drillUpBtn" onclick="drillUp()" title="Drill Up" style="display:none;">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M18 15l-6-6-6 6"/>
            </svg>
          </button>
        </div>
        <div class="chart-toggle" id="yieldToggle">
          <button type="button" class="active" onclick="setYieldChartType('bar')">Column</button>
          <button type="button" onclick="setYieldChartType('line')">Line</button>
          <button type="button" onclick="setYieldChartType('table')">Table</button>
        </div>
      </div>
      <div class="chart-container" id="yieldChartContainer">
        <div class="chart-scroll-wrapper" id="yieldScrollWrapper">
          <div class="chart-scroll-inner" id="yieldScrollInner">
            <canvas id="yieldDailyChart"></canvas>
          </div>
        </div>
        <div class="data-table-view" id="yieldTableView" style="display:none;"></div>
      </div>
    </div>

    <!-- Failures by Category -->
    <div class="chart-panel">
      <div class="panel-header">
        <div>
          <h2>Failures by Category</h2>
          <p class="panel-subtitle" id="failuresSubtitle">Plantwide | Month to date</p>
        </div>
        <div class="chart-toggle" id="failureToggle">
          <button type="button" class="active" onclick="setFailureChartType('radar')">Radar</button>
          <button type="button" onclick="setFailureChartType('bar')">Column</button>
          <button type="button" onclick="setFailureChartType('table')">Table</button>
        </div>
      </div>
      <div class="chart-container" id="failureChartContainer">
        <canvas id="failureCategoryChart"></canvas>
        <div class="data-table-view" id="failureTableView" style="display:none;"></div>
      </div>
    </div>
  </div>

  <!-- Future sections -->
  <div class="section-divider">
    <span>Coming Soon</span>
  </div>

  <div class="coming-soon-row">
    <div class="chart-panel">
      <div class="panel-header"><h2>Scrap Metrics</h2></div>
      <div class="coming-soon-panel">Scrap tracking — data source pending</div>
    </div>
    <div class="chart-panel">
      <div class="panel-header"><h2>Non-Conformance Material</h2></div>
      <div class="coming-soon-panel">NCM tracking — data source pending</div>
    </div>
  </div>
</div>

<!-- Hidden fields -->
<div class="hf-container">
  <asp:HiddenField ID="hfYieldPercent" runat="server" Value="0" />
  <asp:HiddenField ID="hfTested" runat="server" Value="0" />
  <asp:HiddenField ID="hfPassed" runat="server" Value="0" />
  <asp:HiddenField ID="hfFailed" runat="server" Value="0" />
  <asp:HiddenField ID="hfYieldGoal" runat="server" Value="98" />
  <asp:HiddenField ID="hfYieldDailyLabels" runat="server" Value="[]" />
  <asp:HiddenField ID="hfYieldDailyData" runat="server" Value="[]" />
  <asp:HiddenField ID="hfYieldDailyCumulative" runat="server" Value="[]" />
  <asp:HiddenField ID="hfYieldDailyTested" runat="server" Value="[]" />
  <asp:HiddenField ID="hfYieldDailyPassed" runat="server" Value="[]" />
  <asp:HiddenField ID="hfYieldDailyFailed" runat="server" Value="[]" />
  <asp:HiddenField ID="hfYieldByLineData" runat="server" Value="[]" />
  <asp:HiddenField ID="hfYieldByLineDateData" runat="server" Value="[]" />
  <asp:HiddenField ID="hfFailureCategoryLabels" runat="server" Value="[]" />
  <asp:HiddenField ID="hfFailureCategoryData" runat="server" Value="[]" />
  <asp:HiddenField ID="hfCurrentLine" runat="server" Value="ALL" />
  <asp:HiddenField ID="hfCurrentDatePreset" runat="server" Value="MTD" />
</div>

<script>
  // ========== FILTER MODAL ==========
  var currentLineSelection = ['ALL'];
  var currentDatePreset = 'MTD';
  var currentCustomStartDate = '';
  var currentCustomEndDate = '';
  var availableLines = [];
  
  function openFilterModal() {
    document.getElementById('filterModal').classList.add('active');
    initLineChips();
    syncModalToCurrentState();
  }
  
  function closeFilterModal() {
    document.getElementById('filterModal').classList.remove('active');
  }
  
  function initLineChips() {
    // Get available lines from the hidden dropdown
    var ddl = document.getElementById('<%= ddlLine.ClientID %>');
    var chipsContainer = document.getElementById('lineChips');
    
    // Clear and rebuild
    chipsContainer.innerHTML = '<button type="button" class="line-chip" data-value="ALL" onclick="toggleLineChip(this)">Plantwide</button>';
    
    for (var i = 0; i < ddl.options.length; i++) {
      var opt = ddl.options[i];
      if (opt.value !== 'ALL') {
        var chip = document.createElement('button');
        chip.type = 'button';
        chip.className = 'line-chip';
        chip.setAttribute('data-value', opt.value);
        chip.textContent = opt.text;
        chip.onclick = function() { toggleLineChip(this); };
        chipsContainer.appendChild(chip);
        availableLines.push(opt.value);
      }
    }
  }
  
  function syncModalToCurrentState() {
    // Sync line chips
    var chips = document.querySelectorAll('#lineChips .line-chip');
    chips.forEach(function(chip) {
      var val = chip.getAttribute('data-value');
      if (currentLineSelection.indexOf(val) >= 0 || (currentLineSelection.indexOf('ALL') >= 0 && val === 'ALL')) {
        chip.classList.add('selected');
      } else {
        chip.classList.remove('selected');
      }
    });
    
    // Sync date presets
    var presets = document.querySelectorAll('#datePresets .date-preset');
    presets.forEach(function(p) {
      if (p.getAttribute('data-value') === currentDatePreset) {
        p.classList.add('selected');
      } else {
        p.classList.remove('selected');
      }
    });
    
    // Show/hide custom date range and restore values
    if (currentDatePreset === 'CUSTOM') {
      document.getElementById('customDateRange').classList.add('active');
      if (currentCustomStartDate) {
        document.getElementById('modalStartDate').value = currentCustomStartDate;
      }
      if (currentCustomEndDate) {
        document.getElementById('modalEndDate').value = currentCustomEndDate;
      }
    } else {
      document.getElementById('customDateRange').classList.remove('active');
    }
  }
  
  function toggleLineChip(chip) {
    var val = chip.getAttribute('data-value');
    var chips = document.querySelectorAll('#lineChips .line-chip');
    
    // Single selection only - deselect all others first
    chips.forEach(function(c) { c.classList.remove('selected'); });
    chip.classList.add('selected');
    currentLineSelection = [val];
  }
  
  // Date preset click handlers
  document.addEventListener('DOMContentLoaded', function() {
    var presets = document.querySelectorAll('#datePresets .date-preset');
    presets.forEach(function(p) {
      p.onclick = function() {
        presets.forEach(function(pp) { pp.classList.remove('selected'); });
        p.classList.add('selected');
        currentDatePreset = p.getAttribute('data-value');
        
        if (currentDatePreset === 'CUSTOM') {
          document.getElementById('customDateRange').classList.add('active');
        } else {
          document.getElementById('customDateRange').classList.remove('active');
        }
      };
    });
  });
  
  function getDateRangeFromPreset(preset) {
    var today = new Date();
    var start, end;
    end = new Date(today);
    
    switch (preset) {
      case 'YTD':
        start = new Date(today.getFullYear(), 0, 1);
        break;
      case 'MTD':
        start = new Date(today.getFullYear(), today.getMonth(), 1);
        break;
      case 'WEEK':
        start = new Date(today);
        start.setDate(today.getDate() - 6);
        break;
      case 'YESTERDAY':
        start = new Date(today);
        start.setDate(today.getDate() - 1);
        end = new Date(start);
        break;
      case 'TODAY':
        start = new Date(today);
        break;
      case 'CUSTOM':
        start = document.getElementById('modalStartDate').value ? new Date(document.getElementById('modalStartDate').value) : new Date(today.getFullYear(), today.getMonth(), 1);
        end = document.getElementById('modalEndDate').value ? new Date(document.getElementById('modalEndDate').value) : today;
        break;
      default:
        start = new Date(today.getFullYear(), today.getMonth(), 1);
    }
    
    return { start: start, end: end };
  }
  
  function formatDateForInput(date) {
    var y = date.getFullYear();
    var m = ('0' + (date.getMonth() + 1)).slice(-2);
    var d = ('0' + date.getDate()).slice(-2);
    return y + '-' + m + '-' + d;
  }
  
  function formatDateForDisplay(dateStr) {
    // Convert yyyy-mm-dd to d/m/yyyy
    if (!dateStr) return '';
    var parts = dateStr.split('-');
    if (parts.length !== 3) return dateStr;
    return parseInt(parts[2]) + '/' + parseInt(parts[1]) + '/' + parts[0];
  }
  
  function getFilterDisplayText() {
    var lineText = 'Plantwide';
    if (currentLineSelection.length === 1 && currentLineSelection[0] !== 'ALL') {
      lineText = currentLineSelection[0];
    } else if (currentLineSelection.length > 1) {
      lineText = currentLineSelection.length + ' Lines';
    }
    
    var dateText = '';
    switch (currentDatePreset) {
      case 'YTD': dateText = 'YTD'; break;
      case 'MTD': dateText = 'MTD'; break;
      case 'WEEK': dateText = 'Last 7 days'; break;
      case 'YESTERDAY': dateText = 'Yesterday'; break;
      case 'TODAY': dateText = 'Today'; break;
      case 'CUSTOM': 
        if (currentCustomStartDate && currentCustomEndDate) {
          dateText = formatDateForDisplay(currentCustomStartDate) + ' to ' + formatDateForDisplay(currentCustomEndDate);
        } else {
          dateText = 'Custom';
        }
        break;
      default: dateText = 'MTD';
    }
    
    return lineText + '  |  ' + dateText;
  }
  
  function isFilterActive() {
    // Returns true if any filter differs from default (Plantwide + MTD)
    if (currentDatePreset !== 'MTD') return true;
    if (currentLineSelection.length !== 1 || currentLineSelection[0] !== 'ALL') return true;
    return false;
  }
  
  function updateFilterIconState() {
    var btn = document.getElementById('filterIconBtn');
    if (btn) {
      if (isFilterActive()) {
        btn.classList.add('filter-active');
      } else {
        btn.classList.remove('filter-active');
      }
    }
  }
  
  function updateTitleSubtitle() {
    var el = document.getElementById('titleFilterContext');
    if (el) {
      el.textContent = getFilterDisplayText();
    }
  }
  
  function updateSubtitles() {
    var text = getFilterDisplayText();
    var subtitles = ['yieldSubtitle', 'yieldDailySubtitle', 'failuresSubtitle'];
    subtitles.forEach(function(id) {
      var el = document.getElementById(id);
      if (el) el.textContent = text;
    });
    updateTitleSubtitle();
    updateFilterIconState();
  }
  
  function applyFilters() {
    // Save custom dates if using custom preset
    if (currentDatePreset === 'CUSTOM') {
      currentCustomStartDate = document.getElementById('modalStartDate').value;
      currentCustomEndDate = document.getElementById('modalEndDate').value;
    }
    
    // Set the hidden form values
    var dateRange = getDateRangeFromPreset(currentDatePreset);
    document.getElementById('<%= txtStartDate.ClientID %>').value = formatDateForInput(dateRange.start);
    document.getElementById('<%= txtEndDate.ClientID %>').value = formatDateForInput(dateRange.end);
    
    // Set line (for now just use first selection or ALL)
    var lineVal = currentLineSelection.indexOf('ALL') >= 0 ? 'ALL' : currentLineSelection.join(',');
    document.getElementById('<%= ddlLine.ClientID %>').value = currentLineSelection[0] || 'ALL';
    
    // Store filter state
    localStorage.setItem('pqd_lineSelection', JSON.stringify(currentLineSelection));
    localStorage.setItem('pqd_datePreset', currentDatePreset);
    localStorage.setItem('pqd_customStartDate', currentCustomStartDate);
    localStorage.setItem('pqd_customEndDate', currentCustomEndDate);
    
    // Update subtitles before refresh
    updateSubtitles();
    
    // Close modal and trigger refresh
    closeFilterModal();
    document.getElementById('<%= btnRefresh.ClientID %>').click();
  }
  
  function resetFilters() {
    currentLineSelection = ['ALL'];
    currentDatePreset = 'MTD';
    currentCustomStartDate = '';
    currentCustomEndDate = '';
    syncModalToCurrentState();
  }
  
  // Restore filter state on load
  (function() {
    var savedLines = localStorage.getItem('pqd_lineSelection');
    var savedPreset = localStorage.getItem('pqd_datePreset');
    var savedStartDate = localStorage.getItem('pqd_customStartDate');
    var savedEndDate = localStorage.getItem('pqd_customEndDate');
    
    if (savedLines) {
      try { currentLineSelection = JSON.parse(savedLines); } catch(e) {}
    }
    if (savedPreset) {
      currentDatePreset = savedPreset;
    }
    if (savedStartDate) {
      currentCustomStartDate = savedStartDate;
    }
    if (savedEndDate) {
      currentCustomEndDate = savedEndDate;
    }
  })();
  
  // Theme detection
  function isDarkMode() {
    return !document.documentElement.classList.contains('theme-light') && 
           document.documentElement.getAttribute('data-theme') !== 'light';
  }
  
  function getColors() {
    var dark = isDarkMode();
    return {
      text: dark ? '#ffffff' : '#1b222b',
      textSec: dark ? 'rgba(255,255,255,0.5)' : 'rgba(0,0,0,0.5)',
      grid: dark ? 'rgba(255,255,255,0.05)' : 'rgba(0,0,0,0.05)',
      success: '#10b981',
      warning: '#f59e0b',
      danger: '#ef4444',
      primary: '#3b82f6',
      bg: dark ? 'rgba(255,255,255,0.03)' : 'rgba(0,0,0,0.02)'
    };
  }
  
  // Global chart instances
  var yieldDailyChart = null;
  var failureCategoryChart = null;
  var currentYieldType = 'bar';
  var currentFailureType = 'radar';
  var currentDrillLevel = 'daily'; // daily, weekly, monthly, quarterly, yearly
  
  // Reload all charts (for theme changes)
  function reloadAllCharts() {
    // Reload based on current gauge view type
    if (currentGaugeView === 'gauge') {
      initGauge();
    } else if (currentGaugeView === 'table') {
      initLineTableLarge();
    } else {
      initGaugeSmall();
      initLineTableSmall();
    }
    initYieldDailyChart();
    initFailureCategoryChart();
  }
  
  document.addEventListener('DOMContentLoaded', function() {
    updateSubtitles();
    // Default is Both view for First Pass Yield
    initGaugeSmall();
    initLineTableSmall();
    initYieldDailyChart();
    initFailureCategoryChart();
    
    // Watch for theme changes (light/dark mode toggle)
    var observer = new MutationObserver(function(mutations) {
      mutations.forEach(function(mutation) {
        if (mutation.attributeName === 'class' || mutation.attributeName === 'data-theme') {
          reloadAllCharts();
        }
      });
    });
    observer.observe(document.documentElement, { attributes: true, attributeFilter: ['class', 'data-theme'] });
    observer.observe(document.body, { attributes: true, attributeFilter: ['class', 'data-theme'] });
  });
  
  // ========== GAUGE ==========
  function initGauge() {
    var yieldPct = parseFloat(document.getElementById('<%= hfYieldPercent.ClientID %>').value) || 0;
    var goal = parseFloat(document.getElementById('<%= hfYieldGoal.ClientID %>').value) || 98;
    var colors = getColors();
    
    // Update displays with 2 decimal places for yield
    document.getElementById('gaugeValueDisplay').textContent = yieldPct > 0 ? yieldPct.toFixed(2) + '%' : '--';
    
    // Draw SVG gauge - larger for gauge-only mode
    var svg = document.getElementById('yieldGaugeSvg');
    svg.innerHTML = '';
    
    var cx = 110, cy = 100, r = 80;
    var strokeWidth = 32; // Larger stroke for gauge-only mode
    var startAngle = Math.PI;
    var endAngle = 2 * Math.PI;
    var angleRange = endAngle - startAngle;
    
    // Background arc
    var bgPath = describeArc(cx, cy, r, startAngle, endAngle);
    var bgArc = document.createElementNS('http://www.w3.org/2000/svg', 'path');
    bgArc.setAttribute('d', bgPath);
    bgArc.setAttribute('fill', 'none');
    bgArc.setAttribute('stroke', isDarkMode() ? 'rgba(255,255,255,0.12)' : 'rgba(0,0,0,0.1)');
    bgArc.setAttribute('stroke-width', strokeWidth);
    bgArc.setAttribute('stroke-linecap', 'butt');
    svg.appendChild(bgArc);
    
    // Value arc
    if (yieldPct > 0) {
      var valueAngle = startAngle + (Math.min(yieldPct, 100) / 100) * angleRange;
      var valuePath = describeArc(cx, cy, r, startAngle, valueAngle);
      var valueArc = document.createElementNS('http://www.w3.org/2000/svg', 'path');
      valueArc.setAttribute('d', valuePath);
      valueArc.setAttribute('fill', 'none');
      var gaugeColor = yieldPct >= goal ? colors.success : (yieldPct >= goal - 5 ? colors.warning : colors.danger);
      valueArc.setAttribute('stroke', gaugeColor);
      valueArc.setAttribute('stroke-width', strokeWidth);
      valueArc.setAttribute('stroke-linecap', 'butt');
      svg.appendChild(valueArc);
    }
    
    // Goal indicator line - gray color for subtle appearance
    var goalLineColor = isDarkMode() ? 'rgba(180,180,180,0.9)' : 'rgba(80,80,80,0.8)';
    var goalAngle = startAngle + (Math.min(goal, 100) / 100) * angleRange;
    var goalX1 = cx + (r - 22) * Math.cos(goalAngle);
    var goalY1 = cy + (r - 22) * Math.sin(goalAngle);
    var goalX2 = cx + (r + 22) * Math.cos(goalAngle);
    var goalY2 = cy + (r + 22) * Math.sin(goalAngle);
    
    var goalLine = document.createElementNS('http://www.w3.org/2000/svg', 'line');
    goalLine.setAttribute('x1', goalX1);
    goalLine.setAttribute('y1', goalY1);
    goalLine.setAttribute('x2', goalX2);
    goalLine.setAttribute('y2', goalY2);
    goalLine.setAttribute('stroke', goalLineColor);
    goalLine.setAttribute('stroke-width', '3');
    goalLine.setAttribute('stroke-linecap', 'round');
    svg.appendChild(goalLine);
    
    // Goal label - positioned inside the gauge for visibility
    var labelRadius = r - 30;
    var labelX = cx + labelRadius * Math.cos(goalAngle);
    var labelY = cy + labelRadius * Math.sin(goalAngle);
    var goalLabel = document.createElementNS('http://www.w3.org/2000/svg', 'text');
    goalLabel.setAttribute('x', labelX);
    goalLabel.setAttribute('y', labelY);
    goalLabel.setAttribute('fill', goalLineColor);
    goalLabel.setAttribute('font-size', '8');
    goalLabel.setAttribute('font-weight', '600');
    goalLabel.setAttribute('text-anchor', 'middle');
    goalLabel.setAttribute('dominant-baseline', 'middle');
    goalLabel.textContent = goal + '%';
    svg.appendChild(goalLabel);
  }
  
  function describeArc(cx, cy, r, startAngle, endAngle) {
    var x1 = cx + r * Math.cos(startAngle);
    var y1 = cy + r * Math.sin(startAngle);
    var x2 = cx + r * Math.cos(endAngle);
    var y2 = cy + r * Math.sin(endAngle);
    var largeArc = (endAngle - startAngle > Math.PI) ? 1 : 0;
    return 'M ' + x1 + ' ' + y1 + ' A ' + r + ' ' + r + ' 0 ' + largeArc + ' 1 ' + x2 + ' ' + y2;
  }
  
  // ========== YIELD DAILY CHART ==========
  function initYieldDailyChart() {
    // Set default drill level based on date range
    currentDrillLevel = getDefaultDrillLevel();
    aggregateAndRenderYieldChart();
  }
  
  function renderYieldChart(labels, data, cumulativeData, testedArr, passedArr, failedArr) {
    var goal = parseFloat(document.getElementById('<%= hfYieldGoal.ClientID %>').value) || 98;
    var colors = getColors();
    var modernFont = "'Segoe UI', 'Inter', -apple-system, sans-serif";
    var dark = isDarkMode();
    
    var scrollWrapper = document.getElementById('yieldScrollWrapper');
    var scrollInner = document.getElementById('yieldScrollInner');
    var canvas = document.getElementById('yieldDailyChart');
    
    if (yieldDailyChart) yieldDailyChart.destroy();
    
    if (!labels.length) {
      scrollInner.innerHTML = '<div style="display:flex;align-items:center;justify-content:center;height:100%;color:' + colors.textSec + ';font-size:11px;font-style:italic;">No data for selected period</div>';
      return;
    }
    
    // Ensure canvas exists in scrollInner
    if (!document.getElementById('yieldDailyChart')) {
      scrollInner.innerHTML = '<canvas id="yieldDailyChart"></canvas>';
      canvas = document.getElementById('yieldDailyChart');
    }
    
    var ctx = canvas.getContext('2d');
    
    // Calculate width based on data points (max 25 visible, then scroll)
    var maxVisibleColumns = 25;
    var minColumnWidth = 35; // pixels per column
    
    if (labels.length > maxVisibleColumns) {
      var neededWidth = labels.length * minColumnWidth;
      scrollInner.style.width = neededWidth + 'px';
    } else {
      scrollInner.style.width = '100%';
    }
    
    Chart.register(ChartDataLabels);
    
    // Determine Y-axis minimum: lowest value minus 10%, max at 103%
    var minVal = Math.min.apply(null, data.concat(cumulativeData));
    var yMin = Math.max(0, minVal - 10);
    var yMax = 103;
    
    // Goal line color - dark gray (light mode) / light gray (dark mode)
    var goalLineColor = dark ? 'rgba(180,180,180,0.7)' : 'rgba(80,80,80,0.6)';
    // Cumulative line color - dark blue (light mode) / light blue (dark mode)
    var cumulativeColor = dark ? '#60a5fa' : '#1e40af';
    
    // Background bars for line mode - subtle transparent columns
    var bgBarsDataset = currentYieldType === 'line' ? {
      label: 'Background',
      data: data,
      type: 'bar',
      backgroundColor: data.map(function(v) { return v >= goal ? 'rgba(16,185,129,0.15)' : 'rgba(239,68,68,0.15)'; }),
      borderColor: 'transparent',
      borderWidth: 0,
      borderRadius: 4,
      datalabels: { display: false },
      order: 4
    } : null;
    
    // Main line color - matches gauge color based on overall yield
    var overallYield = parseFloat(document.getElementById('<%= hfYieldPercent.ClientID %>').value) || 0;
    var mainLineColor = overallYield >= goal ? colors.success : (overallYield >= goal - 5 ? '#f59e0b' : colors.danger);
    var mainLineBgColor = overallYield >= goal ? 'rgba(16,185,129,0.85)' : (overallYield >= goal - 5 ? 'rgba(245,158,11,0.85)' : 'rgba(239,68,68,0.85)');
    
    // Determine label based on drill level
    var yieldLabel = currentDrillLevel.charAt(0).toUpperCase() + currentDrillLevel.slice(1) + ' Yield';
    
    var datasets = [
      {
        label: yieldLabel,
        data: data,
        backgroundColor: currentYieldType === 'line' ? mainLineBgColor : data.map(function(v) { return v >= goal ? 'rgba(16,185,129,0.85)' : 'rgba(239,68,68,0.85)'; }),
        borderColor: currentYieldType === 'line' ? mainLineColor : data.map(function(v) { return v >= goal ? '#10b981' : '#ef4444'; }),
        borderWidth: currentYieldType === 'line' ? 3.5 : 0,
        borderRadius: currentYieldType === 'bar' ? 4 : 0,
        fill: false,
        tension: 0.3,
        pointRadius: currentYieldType === 'line' ? 2.5 : 0,
        pointBackgroundColor: mainLineColor,
        order: 2
      },
      {
        label: 'Goal',
        data: labels.map(function() { return goal; }),
        type: 'line',
        borderColor: goalLineColor,
        borderDash: [5, 3],
        borderWidth: 2,
        pointRadius: 0,
        fill: false,
        datalabels: { display: false },
        order: 3
      },
      {
        label: 'Cumulative Yield',
        data: cumulativeData,
        type: 'line',
        borderColor: cumulativeColor,
        borderDash: [2, 2],
        borderWidth: 1.5,
        pointRadius: 0,
        fill: false,
        tension: 0.2,
        datalabels: { display: false },
        order: 0
      }
    ];
    
    // Add background bars for line mode
    if (bgBarsDataset) {
      datasets.push(bgBarsDataset);
    }
    
    yieldDailyChart = new Chart(ctx, {
      type: currentYieldType,
      data: {
        labels: labels,
        datasets: datasets
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        layout: { padding: { top: 12, right: 8 } },
        interaction: { mode: 'index', intersect: false },
        scales: {
          y: { 
            display: false,
            min: yMin,
            max: yMax
          },
          x: {
            grid: { display: false },
            ticks: { color: colors.textSec, font: { size: 9, family: modernFont } }
          }
        },
        plugins: {
          legend: { display: false },
          tooltip: {
            backgroundColor: dark ? 'rgba(30,35,45,0.95)' : 'rgba(255,255,255,0.98)',
            titleColor: colors.text,
            bodyColor: colors.text,
            borderColor: dark ? 'rgba(255,255,255,0.1)' : 'rgba(0,0,0,0.1)',
            borderWidth: 1,
            titleFont: { size: 11, family: modernFont, weight: '600' },
            bodyFont: { size: 10, family: modernFont },
            padding: 10,
            callbacks: {
              title: function(ctx) { return ctx[0].label; },
              label: function(ctx) {
                if (ctx.datasetIndex === 1) return 'Goal: ' + ctx.parsed.y.toFixed(2) + '%';
                if (ctx.datasetIndex === 2) return 'Cumulative: ' + ctx.parsed.y.toFixed(2) + '%';
                var idx = ctx.dataIndex;
                var levelLabel = currentDrillLevel.charAt(0).toUpperCase() + currentDrillLevel.slice(1);
                return [
                  levelLabel + ' Yield: ' + ctx.parsed.y.toFixed(2) + '%',
                  'Passed: ' + passedArr[idx] + ' units',
                  'Failed: ' + failedArr[idx] + ' units',
                  'Total: ' + testedArr[idx] + ' units'
                ];
              }
            }
          },
          datalabels: {
            display: function(ctx) { return ctx.datasetIndex === 0; },
            anchor: 'end',
            align: 'top',
            color: colors.text,
            font: { size: 9, weight: '600', family: modernFont },
            formatter: function(value) { return value.toFixed(2) + '%'; }
          }
        }
      }
    });
    
    // Update drill buttons visibility
    updateDrillButtons();
  }
  
  function setYieldChartType(type) {
    currentYieldType = type;
    var btns = document.querySelectorAll('#yieldToggle button');
    btns.forEach(function(b) { b.classList.remove('active'); });
    var idx = type === 'bar' ? 0 : (type === 'line' ? 1 : 2);
    btns[idx].classList.add('active');
    
    // Toggle visibility of chart vs table
    var scrollWrapper = document.getElementById('yieldScrollWrapper');
    var tableView = document.getElementById('yieldTableView');
    
    if (type === 'table') {
      scrollWrapper.style.display = 'none';
      tableView.style.display = 'block';
      renderYieldTableView();
    } else {
      scrollWrapper.style.display = 'block';
      tableView.style.display = 'none';
      aggregateAndRenderYieldChart();
    }
  }
  
  function renderYieldTableView() {
    var lineDateData = JSON.parse(document.getElementById('<%= hfYieldByLineDateData.ClientID %>').value || '[]');
    var lineData = JSON.parse(document.getElementById('<%= hfYieldByLineData.ClientID %>').value || '[]');
    var goal = parseFloat(document.getElementById('<%= hfYieldGoal.ClientID %>').value) || 98;
    
    var tableView = document.getElementById('yieldTableView');
    
    if (!lineDateData.length && !lineData.length) {
      tableView.innerHTML = '<div style="display:flex;align-items:center;justify-content:center;height:100%;color:rgba(0,0,0,0.4);font-size:11px;font-style:italic;">No data available</div>';
      return;
    }
    
    // Build a pivot table: Lines as rows, Dates (aggregated by drill level) as columns
    // First, get unique lines and dates
    var lines = [];
    var dateMap = {}; // date -> { line -> { tested, passed, yield } }
    
    lineDateData.forEach(function(row) {
      if (lines.indexOf(row.line) === -1) lines.push(row.line);
      
      // Aggregate date based on current drill level
      var bucketLabel = aggregateDateLabel(row.date, row.dateSort, currentDrillLevel);
      
      if (!dateMap[bucketLabel]) {
        dateMap[bucketLabel] = { sortKey: row.dateSort };
      }
      if (!dateMap[bucketLabel][row.line]) {
        dateMap[bucketLabel][row.line] = { tested: 0, passed: 0 };
      }
      dateMap[bucketLabel][row.line].tested += row.tested;
      dateMap[bucketLabel][row.line].passed += row.passed;
    });
    
    // Sort lines alphabetically
    lines.sort();
    
    // Get sorted date columns
    var dateCols = Object.keys(dateMap).sort(function(a, b) {
      return dateMap[a].sortKey.localeCompare(dateMap[b].sortKey);
    });
    
    if (!dateCols.length) {
      tableView.innerHTML = '<div style="display:flex;align-items:center;justify-content:center;height:100%;color:rgba(0,0,0,0.4);font-size:11px;font-style:italic;">No data available</div>';
      return;
    }
    
    // Build table HTML
    var html = '<table><thead><tr><th>Line</th>';
    dateCols.forEach(function(col) {
      html += '<th>' + col + '</th>';
    });
    html += '<th>Total</th></tr></thead><tbody>';
    
    // Row totals for footer
    var colTotals = {};
    dateCols.forEach(function(col) { colTotals[col] = { tested: 0, passed: 0 }; });
    var grandTested = 0, grandPassed = 0;
    
    lines.forEach(function(lineName) {
      var lineTested = 0, linePassed = 0;
      html += '<tr><td>' + lineName + '</td>';
      
      dateCols.forEach(function(col) {
        var cellData = dateMap[col][lineName];
        if (cellData && cellData.tested > 0) {
          var yld = (cellData.passed / cellData.tested * 100);
          var cellClass = yld >= goal ? 'cell-good' : 'cell-bad';
          html += '<td class="' + cellClass + '">' + yld.toFixed(1) + '%</td>';
          lineTested += cellData.tested;
          linePassed += cellData.passed;
          colTotals[col].tested += cellData.tested;
          colTotals[col].passed += cellData.passed;
        } else {
          html += '<td>-</td>';
        }
      });
      
      // Line total
      var lineYield = lineTested > 0 ? (linePassed / lineTested * 100) : 0;
      var lineCellClass = lineYield >= goal ? 'cell-good' : 'cell-bad';
      html += '<td class="' + lineCellClass + '"><strong>' + lineYield.toFixed(1) + '%</strong></td>';
      html += '</tr>';
      
      grandTested += lineTested;
      grandPassed += linePassed;
    });
    
    // Footer row with column totals
    html += '</tbody><tfoot><tr><td><strong>Total</strong></td>';
    dateCols.forEach(function(col) {
      var colYield = colTotals[col].tested > 0 ? (colTotals[col].passed / colTotals[col].tested * 100) : 0;
      var colCellClass = colYield >= goal ? 'cell-good' : 'cell-bad';
      html += '<td class="' + colCellClass + '"><strong>' + colYield.toFixed(1) + '%</strong></td>';
    });
    
    var grandYield = grandTested > 0 ? (grandPassed / grandTested * 100) : 0;
    var grandCellClass = grandYield >= goal ? 'cell-good' : 'cell-bad';
    html += '<td class="' + grandCellClass + '"><strong>' + grandYield.toFixed(1) + '%</strong></td>';
    html += '</tr></tfoot></table>';
    
    tableView.innerHTML = html;
  }
  
  function aggregateDateLabel(dateLabel, dateSort, level) {
    if (level === 'daily') return dateLabel;
    
    // Parse the date from dateSort (yyyy-MM-dd)
    var parts = dateSort.split('-');
    var date = new Date(parseInt(parts[0]), parseInt(parts[1]) - 1, parseInt(parts[2]));
    
    if (level === 'weekly') {
      var onejan = new Date(date.getFullYear(), 0, 1);
      var weekNum = Math.ceil((((date - onejan) / 86400000) + onejan.getDay() + 1) / 7);
      return 'W' + weekNum;
    } else if (level === 'monthly') {
      var monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return monthNames[date.getMonth()];
    } else if (level === 'quarterly') {
      var quarter = Math.floor(date.getMonth() / 3) + 1;
      return 'Q' + quarter;
    } else if (level === 'yearly') {
      return date.getFullYear().toString();
    }
    return dateLabel;
  }
  
  // ========== DRILL DOWN/UP LOGIC ==========
  var drillLevels = ['daily', 'weekly', 'monthly', 'quarterly', 'yearly'];
  
  function getDateRangeDays() {
    var startInput = document.getElementById('<%= txtStartDate.ClientID %>');
    var endInput = document.getElementById('<%= txtEndDate.ClientID %>');
    var start = new Date(startInput.value);
    var end = new Date(endInput.value);
    var diffTime = Math.abs(end - start);
    var diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24)) + 1;
    return diffDays;
  }
  
  function getDefaultDrillLevel() {
    var days = getDateRangeDays();
    if (days <= 31) return 'daily';
    if (days <= 62) return 'weekly';
    if (days <= 180) return 'monthly';
    return 'quarterly';
  }
  
  function getAvailableDrillLevels() {
    var days = getDateRangeDays();
    var available = ['daily']; // Daily is always available
    
    // Add more levels based on date range
    if (days > 5) available.push('weekly');
    if (days > 14) available.push('monthly');
    if (days > 60) available.push('quarterly');
    if (days > 180) available.push('yearly');
    
    return available;
  }
  
  function updateDrillButtons() {
    var available = getAvailableDrillLevels();
    var currentIdx = available.indexOf(currentDrillLevel);
    
    var drillDownBtn = document.getElementById('drillDownBtn');
    var drillUpBtn = document.getElementById('drillUpBtn');
    
    // Show drill down if we can go to more detail (lower index)
    drillDownBtn.style.display = currentIdx > 0 ? 'flex' : 'none';
    
    // Show drill up if we can go to less detail (higher index)
    drillUpBtn.style.display = currentIdx < available.length - 1 ? 'flex' : 'none';
    
    // Update chart title
    var titleMap = {
      'daily': 'Yield Daily',
      'weekly': 'Yield Weekly',
      'monthly': 'Yield Monthly',
      'quarterly': 'Yield Quarterly',
      'yearly': 'Yield Yearly'
    };
    document.getElementById('yieldChartTitle').textContent = titleMap[currentDrillLevel] || 'Yield Daily';
  }
  
  function drillDown() {
    var available = getAvailableDrillLevels();
    var currentIdx = available.indexOf(currentDrillLevel);
    if (currentIdx > 0) {
      currentDrillLevel = available[currentIdx - 1];
      aggregateAndRenderYieldChart();
    }
  }
  
  function drillUp() {
    var available = getAvailableDrillLevels();
    var currentIdx = available.indexOf(currentDrillLevel);
    if (currentIdx < available.length - 1) {
      currentDrillLevel = available[currentIdx + 1];
      aggregateAndRenderYieldChart();
    }
  }
  
  function aggregateDataByLevel(labels, data, testedArr, passedArr, failedArr, level) {
    if (level === 'daily') {
      return { labels: labels, data: data, tested: testedArr, passed: passedArr, failed: failedArr };
    }
    
    // Parse dates from labels (format: M/d)
    var currentYear = new Date().getFullYear();
    var parsedDates = labels.map(function(lbl) {
      var parts = lbl.split('/');
      return new Date(currentYear, parseInt(parts[0]) - 1, parseInt(parts[1]));
    });
    
    var buckets = {};
    
    for (var i = 0; i < labels.length; i++) {
      var date = parsedDates[i];
      var bucketKey;
      var bucketLabel;
      
      if (level === 'weekly') {
        // Get week number
        var onejan = new Date(date.getFullYear(), 0, 1);
        var weekNum = Math.ceil((((date - onejan) / 86400000) + onejan.getDay() + 1) / 7);
        bucketKey = date.getFullYear() + '-W' + weekNum;
        bucketLabel = 'W' + weekNum;
      } else if (level === 'monthly') {
        bucketKey = date.getFullYear() + '-' + (date.getMonth() + 1);
        var monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        bucketLabel = monthNames[date.getMonth()];
      } else if (level === 'quarterly') {
        var quarter = Math.floor(date.getMonth() / 3) + 1;
        bucketKey = date.getFullYear() + '-Q' + quarter;
        bucketLabel = 'Q' + quarter;
      } else if (level === 'yearly') {
        bucketKey = date.getFullYear().toString();
        bucketLabel = date.getFullYear().toString();
      }
      
      if (!buckets[bucketKey]) {
        buckets[bucketKey] = { label: bucketLabel, tested: 0, passed: 0, failed: 0, sortKey: bucketKey };
      }
      buckets[bucketKey].tested += testedArr[i];
      buckets[bucketKey].passed += passedArr[i];
      buckets[bucketKey].failed += failedArr[i];
    }
    
    // Convert to arrays and sort
    var bucketArr = Object.keys(buckets).map(function(k) { return buckets[k]; });
    bucketArr.sort(function(a, b) { return a.sortKey.localeCompare(b.sortKey); });
    
    var newLabels = [];
    var newData = [];
    var newTested = [];
    var newPassed = [];
    var newFailed = [];
    
    bucketArr.forEach(function(b) {
      newLabels.push(b.label);
      var yld = b.tested > 0 ? (b.passed / b.tested * 100) : 0;
      newData.push(Math.round(yld * 100) / 100);
      newTested.push(b.tested);
      newPassed.push(b.passed);
      newFailed.push(b.failed);
    });
    
    return { labels: newLabels, data: newData, tested: newTested, passed: newPassed, failed: newFailed };
  }
  
  function aggregateAndRenderYieldChart() {
    updateDrillButtons();
    
    var labels = JSON.parse(document.getElementById('<%= hfYieldDailyLabels.ClientID %>').value || '[]');
    var data = JSON.parse(document.getElementById('<%= hfYieldDailyData.ClientID %>').value || '[]');
    var testedArr = JSON.parse(document.getElementById('<%= hfYieldDailyTested.ClientID %>').value || '[]');
    var passedArr = JSON.parse(document.getElementById('<%= hfYieldDailyPassed.ClientID %>').value || '[]');
    var failedArr = JSON.parse(document.getElementById('<%= hfYieldDailyFailed.ClientID %>').value || '[]');
    
    var aggregated = aggregateDataByLevel(labels, data, testedArr, passedArr, failedArr, currentDrillLevel);
    
    // Calculate cumulative yield from aggregated data
    var cumulativeData = [];
    var cumTested = 0, cumPassed = 0;
    for (var i = 0; i < aggregated.data.length; i++) {
      cumTested += aggregated.tested[i];
      cumPassed += aggregated.passed[i];
      var cumYield = cumTested > 0 ? (cumPassed / cumTested * 100) : 0;
      cumulativeData.push(Math.round(cumYield * 100) / 100);
    }
    
    renderYieldChart(aggregated.labels, aggregated.data, cumulativeData, aggregated.tested, aggregated.passed, aggregated.failed);
  }
  
  // ========== FAILURES BY CATEGORY CHART ==========
  function initFailureCategoryChart() {
    var labels = JSON.parse(document.getElementById('<%= hfFailureCategoryLabels.ClientID %>').value || '[]');
    var data = JSON.parse(document.getElementById('<%= hfFailureCategoryData.ClientID %>').value || '[]');
    var colors = getColors();
    var modernFont = "'Segoe UI', 'Inter', -apple-system, sans-serif";
    
    var ctx = document.getElementById('failureCategoryChart').getContext('2d');
    
    if (failureCategoryChart) failureCategoryChart.destroy();
    
    // Base categories always shown (the main 5)
    var baseCategories = ['Component', 'Workmanship', 'Test', 'Other', 'Undetermined'];
    // Optional categories only shown if they have data
    var optionalCategories = ['Design', 'Troubleshooting'];
    var categoryColors = ['#3b82f6', '#10b981', '#ef4444', '#9ca3af', '#1e3a5f', '#8b5cf6', '#fbbf24'];
    
    // Build label to data mapping
    var dataMap = {};
    for (var i = 0; i < labels.length; i++) {
      dataMap[labels[i]] = data[i];
    }
    
    // Use provided data or show placeholder
    if (!labels.length || !data.length) {
      // For radar, show empty chart with base categories
      if (currentFailureType === 'radar') {
        labels = baseCategories;
        data = baseCategories.map(function() { return 0; });
      } else {
        ctx.canvas.parentElement.innerHTML = '<div style="display:flex;align-items:center;justify-content:center;height:100%;color:' + colors.textSec + ';font-size:11px;font-style:italic;">No failure data</div>';
        return;
      }
    }
    
    if (currentFailureType === 'radar') {
      // Build radar labels: always include base, add optional only if they have data
      var radarLabels = baseCategories.slice();
      optionalCategories.forEach(function(cat) {
        if (dataMap[cat] && dataMap[cat] > 0) {
          radarLabels.push(cat);
        }
      });
      
      var radarData = radarLabels.map(function(cat) {
        return dataMap[cat] || 0;
      });
      
      Chart.register(ChartDataLabels);
      
      // Custom plugin to draw bold outer ring
      var outerRingPlugin = {
        id: 'outerRing',
        afterDraw: function(chart) {
          var r = chart.scales.r;
          var ctx = chart.ctx;
          var centerX = r.xCenter;
          var centerY = r.yCenter;
          var radius = r.drawingArea;
          
          ctx.save();
          ctx.beginPath();
          ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI);
          ctx.strokeStyle = isDarkMode() ? 'rgba(255,255,255,0.25)' : 'rgba(0,0,0,0.2)';
          ctx.lineWidth = 2.5;
          ctx.stroke();
          ctx.restore();
        }
      };
      
      failureCategoryChart = new Chart(ctx, {
        type: 'radar',
        data: {
          labels: radarLabels,
          datasets: [{
            label: 'Issues',
            data: radarData,
            backgroundColor: 'rgba(59,130,246,0.12)',
            borderColor: '#3b82f6',
            borderWidth: 1.5,
            pointBackgroundColor: '#3b82f6',
            pointBorderColor: isDarkMode() ? '#1b222b' : '#fff',
            pointBorderWidth: 2,
            pointRadius: 4,
            pointHoverRadius: 6
          }]
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          scales: {
            r: {
              beginAtZero: true,
              ticks: { display: false },
              grid: { color: colors.grid, lineWidth: 1 },
              angleLines: { color: colors.grid, lineWidth: 1 },
              pointLabels: { 
                color: colors.text, 
                font: { size: 10, weight: '600', family: modernFont }
              }
            }
          },
          plugins: {
            legend: { display: false },
            datalabels: {
              display: function(ctx) { return ctx.dataset.data[ctx.dataIndex] > 0; },
              color: isDarkMode() ? '#60a5fa' : '#1e40af',
              backgroundColor: isDarkMode() ? 'rgba(30,35,45,0.85)' : 'rgba(255,255,255,0.9)',
              borderRadius: 3,
              padding: { left: 4, right: 4, top: 2, bottom: 2 },
              font: { size: 11, weight: '700', family: modernFont },
              anchor: function(ctx) {
                var val = ctx.dataset.data[ctx.dataIndex];
                var maxVal = Math.max.apply(null, ctx.dataset.data);
                return val >= maxVal * 0.8 ? 'center' : 'end';
              },
              align: function(ctx) {
                var val = ctx.dataset.data[ctx.dataIndex];
                var maxVal = Math.max.apply(null, ctx.dataset.data);
                return val >= maxVal * 0.8 ? 'center' : 'end';
              },
              offset: function(ctx) {
                var val = ctx.dataset.data[ctx.dataIndex];
                var maxVal = Math.max.apply(null, ctx.dataset.data);
                return val >= maxVal * 0.8 ? 0 : 6;
              },
              formatter: function(value) { return value; }
            }
          }
        },
        plugins: [outerRingPlugin]
      });
    } else {
      // Stacked column chart
      Chart.register(ChartDataLabels);
      
      // Create separate datasets for each category to enable stacking
      var datasets = labels.map(function(label, idx) {
        return {
          label: label,
          data: [data[idx]],
          backgroundColor: categoryColors[idx % categoryColors.length],
          borderRadius: 0
        };
      });
      
      failureCategoryChart = new Chart(ctx, {
        type: 'bar',
        data: {
          labels: ['Issues'],
          datasets: datasets
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          scales: {
            x: { 
              stacked: true,
              display: false
            },
            y: {
              stacked: true,
              display: false
            }
          },
          plugins: {
            legend: { 
              display: true,
              position: 'bottom',
              labels: {
                color: colors.text,
                font: { size: 9, family: modernFont },
                boxWidth: 12,
                padding: 8
              }
            },
            datalabels: {
              display: function(ctx) { return ctx.dataset.data[0] > 0; },
              anchor: 'center',
              align: 'center',
              color: '#fff',
              font: { size: 11, weight: '700', family: modernFont },
              formatter: function(value) { return value; }
            },
            tooltip: {
              backgroundColor: isDarkMode() ? 'rgba(30,35,45,0.95)' : 'rgba(255,255,255,0.98)',
              titleColor: colors.text,
              bodyColor: colors.text,
              borderColor: isDarkMode() ? 'rgba(255,255,255,0.1)' : 'rgba(0,0,0,0.1)',
              borderWidth: 1,
              titleFont: { size: 11, family: modernFont, weight: '600' },
              bodyFont: { size: 10, family: modernFont }
            }
          }
        }
      });
    }
  }
  
  function setFailureChartType(type) {
    currentFailureType = type;
    var btns = document.querySelectorAll('#failureToggle button');
    btns.forEach(function(b) { b.classList.remove('active'); });
    var idx = type === 'radar' ? 0 : (type === 'bar' ? 1 : 2);
    btns[idx].classList.add('active');
    
    // Toggle visibility of chart vs table
    var canvas = document.getElementById('failureCategoryChart');
    var tableView = document.getElementById('failureTableView');
    
    if (type === 'table') {
      canvas.style.display = 'none';
      tableView.style.display = 'block';
      renderFailureTableView();
    } else {
      canvas.style.display = 'block';
      tableView.style.display = 'none';
      initFailureCategoryChart();
    }
  }
  
  function renderFailureTableView() {
    var labels = JSON.parse(document.getElementById('<%= hfFailureCategoryLabels.ClientID %>').value || '[]');
    var data = JSON.parse(document.getElementById('<%= hfFailureCategoryData.ClientID %>').value || '[]');
    var lineData = JSON.parse(document.getElementById('<%= hfYieldByLineData.ClientID %>').value || '[]');
    
    var tableView = document.getElementById('failureTableView');
    
    if (!labels.length) {
      tableView.innerHTML = '<div style="display:flex;align-items:center;justify-content:center;height:100%;color:rgba(0,0,0,0.4);font-size:11px;font-style:italic;">No failure data available</div>';
      return;
    }
    
    // Build header with categories
    var html = '<table><thead><tr><th>Category</th><th>Count</th><th>% of Total</th></tr></thead><tbody>';
    
    var total = data.reduce(function(a, b) { return a + b; }, 0);
    
    labels.forEach(function(label, idx) {
      var count = data[idx] || 0;
      var pct = total > 0 ? (count / total * 100) : 0;
      var cellClass = count > 0 ? 'cell-bad' : '';
      
      html += '<tr>';
      html += '<td>' + label + '</td>';
      html += '<td class="' + cellClass + '">' + count.toLocaleString() + '</td>';
      html += '<td>' + pct.toFixed(1) + '%</td>';
      html += '</tr>';
    });
    
    html += '</tbody><tfoot><tr>';
    html += '<td>TOTAL</td>';
    html += '<td class="cell-bad">' + total.toLocaleString() + '</td>';
    html += '<td>100%</td>';
    html += '</tr></tfoot></table>';
    
    tableView.innerHTML = html;
  }
  
  // ========== GAUGE VIEW TYPE ==========
  var currentGaugeView = 'both'; // gauge, table, both (default: both)
  
  function setGaugeViewType(type) {
    currentGaugeView = type;
    var btns = document.querySelectorAll('#gaugeToggle button');
    btns.forEach(function(b) { b.classList.remove('active'); });
    var idx = type === 'gauge' ? 0 : (type === 'table' ? 1 : 2);
    btns[idx].classList.add('active');
    
    var gaugeView = document.getElementById('gaugeViewContainer');
    var tableView = document.getElementById('tableOnlyView');
    var bothView = document.getElementById('bothView');
    
    gaugeView.style.display = 'none';
    tableView.style.display = 'none';
    bothView.style.display = 'none';
    
    if (type === 'gauge') {
      gaugeView.style.display = 'flex';
      initGauge(); // Redraw gauge in large mode
    } else if (type === 'table') {
      tableView.style.display = 'flex';
      initLineTableLarge();
    } else {
      bothView.style.display = 'flex';
      initGaugeSmall();
      initLineTableSmall();
    }
  }
  
  function initLineTableLarge() {
    var lineData = JSON.parse(document.getElementById('<%= hfYieldByLineData.ClientID %>').value || '[]');
    var plantName = document.getElementById('<%= ddlPlant.ClientID %>').value || 'Plant';
    var goal = parseFloat(document.getElementById('<%= hfYieldGoal.ClientID %>').value) || 98;
    var tbody = document.getElementById('lineTableBodyLarge');
    var tfoot = document.getElementById('lineTableFootLarge');
    
    tbody.innerHTML = '';
    tfoot.innerHTML = '';
    
    if (!lineData.length) {
      tbody.innerHTML = '<tr><td colspan="4" style="text-align:center;color:rgba(0,0,0,0.4);font-style:italic;">No data</td></tr>';
      return;
    }
    
    var totalTested = 0, totalPassed = 0, totalFailed = 0;
    
    lineData.forEach(function(row) {
      totalTested += row.tested;
      totalPassed += row.passed;
      totalFailed += row.failed;
      var lineYield = row.tested > 0 ? (row.passed / row.tested * 100) : 0;
      var yieldClass = lineYield >= goal ? 'status-good' : 'status-danger';
      
      var tr = document.createElement('tr');
      tr.innerHTML = '<td>' + row.line + '</td>' +
                     '<td>' + row.tested.toLocaleString() + '</td>' +
                     '<td><span class="passed">' + row.passed.toLocaleString() + '</span> / <span class="failed">' + row.failed.toLocaleString() + '</span></td>' +
                     '<td class="' + yieldClass + '">' + lineYield.toFixed(2) + '%</td>';
      tbody.appendChild(tr);
    });
    
    var totalYield = totalTested > 0 ? (totalPassed / totalTested * 100) : 0;
    var totalYieldClass = totalYield >= goal ? 'status-good' : 'status-danger';
    var tfootRow = document.createElement('tr');
    tfootRow.innerHTML = '<td><strong>' + plantName + '</strong></td>' +
                         '<td><strong>' + totalTested.toLocaleString() + '</strong></td>' +
                         '<td><span class="passed"><strong>' + totalPassed.toLocaleString() + '</strong></span> / <span class="failed"><strong>' + totalFailed.toLocaleString() + '</strong></span></td>' +
                         '<td class="' + totalYieldClass + '"><strong>' + totalYield.toFixed(2) + '%</strong></td>';
    tfoot.appendChild(tfootRow);
  }
  
  function initLineTableSmall() {
    var lineData = JSON.parse(document.getElementById('<%= hfYieldByLineData.ClientID %>').value || '[]');
    var plantName = document.getElementById('<%= ddlPlant.ClientID %>').value || 'Plant';
    var goal = parseFloat(document.getElementById('<%= hfYieldGoal.ClientID %>').value) || 98;
    var tbody = document.getElementById('lineTableBodySmall');
    var tfoot = document.getElementById('lineTableFootSmall');
    
    tbody.innerHTML = '';
    tfoot.innerHTML = '';
    
    if (!lineData.length) {
      tbody.innerHTML = '<tr><td colspan="4" style="text-align:center;color:rgba(0,0,0,0.4);font-style:italic;">No data</td></tr>';
      return;
    }
    
    var totalTested = 0, totalPassed = 0, totalFailed = 0;
    
    lineData.forEach(function(row) {
      totalTested += row.tested;
      totalPassed += row.passed;
      totalFailed += row.failed;
      var lineYield = row.tested > 0 ? (row.passed / row.tested * 100) : 0;
      
      var tr = document.createElement('tr');
      tr.innerHTML = '<td>' + row.line + '</td>' +
                     '<td>' + row.tested.toLocaleString() + '</td>' +
                     '<td><span class="passed">' + row.passed.toLocaleString() + '</span> / <span class="failed">' + row.failed.toLocaleString() + '</span></td>' +
                     '<td>' + lineYield.toFixed(2) + '%</td>';
      tbody.appendChild(tr);
    });
    
    var totalYield = totalTested > 0 ? (totalPassed / totalTested * 100) : 0;
    var tfootRow = document.createElement('tr');
    tfootRow.innerHTML = '<td><strong>' + plantName + '</strong></td>' +
                         '<td><strong>' + totalTested.toLocaleString() + '</strong></td>' +
                         '<td><span class="passed"><strong>' + totalPassed.toLocaleString() + '</strong></span> / <span class="failed"><strong>' + totalFailed.toLocaleString() + '</strong></span></td>' +
                         '<td><strong>' + totalYield.toFixed(2) + '%</strong></td>';
    tfoot.appendChild(tfootRow);
  }
  
  function initGaugeSmall() {
    var yieldPct = parseFloat(document.getElementById('<%= hfYieldPercent.ClientID %>').value) || 0;
    var goal = parseFloat(document.getElementById('<%= hfYieldGoal.ClientID %>').value) || 98;
    var colors = getColors();
    
    document.getElementById('gaugeValueDisplaySmall').textContent = yieldPct > 0 ? yieldPct.toFixed(2) + '%' : '--';
    
    var svg = document.getElementById('yieldGaugeSvgSmall');
    svg.innerHTML = '';
    
    var cx = 110, cy = 100, r = 80;
    var startAngle = Math.PI;
    var endAngle = 2 * Math.PI;
    var angleRange = endAngle - startAngle;
    
    // Background arc
    var bgPath = describeArc(cx, cy, r, startAngle, endAngle);
    var bgArc = document.createElementNS('http://www.w3.org/2000/svg', 'path');
    bgArc.setAttribute('d', bgPath);
    bgArc.setAttribute('fill', 'none');
    bgArc.setAttribute('stroke', isDarkMode() ? 'rgba(255,255,255,0.12)' : 'rgba(0,0,0,0.1)');
    bgArc.setAttribute('stroke-width', '26');
    bgArc.setAttribute('stroke-linecap', 'butt');
    svg.appendChild(bgArc);
    
    // Value arc
    if (yieldPct > 0) {
      var valueAngle = startAngle + (Math.min(yieldPct, 100) / 100) * angleRange;
      var valuePath = describeArc(cx, cy, r, startAngle, valueAngle);
      var valueArc = document.createElementNS('http://www.w3.org/2000/svg', 'path');
      valueArc.setAttribute('d', valuePath);
      valueArc.setAttribute('fill', 'none');
      var gaugeColor = yieldPct >= goal ? colors.success : (yieldPct >= goal - 5 ? colors.warning : colors.danger);
      valueArc.setAttribute('stroke', gaugeColor);
      valueArc.setAttribute('stroke-width', '26');
      valueArc.setAttribute('stroke-linecap', 'butt');
      svg.appendChild(valueArc);
    }
    
    // Goal indicator
    var goalLineColor = isDarkMode() ? 'rgba(180,180,180,0.9)' : 'rgba(80,80,80,0.8)';
    var goalAngle = startAngle + (goal / 100) * angleRange;
    var goalInnerR = r - 18;
    var goalOuterR = r + 18;
    var gx1 = cx + goalInnerR * Math.cos(goalAngle);
    var gy1 = cy + goalInnerR * Math.sin(goalAngle);
    var gx2 = cx + goalOuterR * Math.cos(goalAngle);
    var gy2 = cy + goalOuterR * Math.sin(goalAngle);
    
    var goalLine = document.createElementNS('http://www.w3.org/2000/svg', 'line');
    goalLine.setAttribute('x1', gx1);
    goalLine.setAttribute('y1', gy1);
    goalLine.setAttribute('x2', gx2);
    goalLine.setAttribute('y2', gy2);
    goalLine.setAttribute('stroke', goalLineColor);
    goalLine.setAttribute('stroke-width', '2');
    svg.appendChild(goalLine);
  }
</script>
</asp:Content>
