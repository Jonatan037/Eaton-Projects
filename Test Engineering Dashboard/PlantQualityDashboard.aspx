<%@ Page Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="PlantQualityDashboard.aspx.cs" Inherits="TED_PlantQualityDashboard" %>
<asp:Content ID="PQDashTitle" ContentPlaceHolderID="TitleContent" runat="server">Plant Quality Performance Report</asp:Content>
<asp:Content ID="PQDashHead" ContentPlaceHolderID="HeadContent" runat="server">
  <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/chartjs-plugin-datalabels@2.2.0/dist/chartjs-plugin-datalabels.min.js"></script>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Poppins:wght@500;600;700&display=swap" rel="stylesheet">
  <style>
    /* Font Scale System - CSS Custom Properties */
    :root {
      --font-scale: 1;
      --base-title: 11px;
      --base-subtitle: 9px;
      --base-table: 9px;
      --base-table-header: 9px;
      --base-chart-label: 10px;
      --base-gauge-value: 30px;
      --base-gauge-label: 9px;
    }
    
    /* Font scale levels */
    html.font-scale-small { --font-scale: 1; }
    html.font-scale-medium { --font-scale: 1.25; }
    html.font-scale-large { --font-scale: 1.5; }
    html.font-scale-xl { --font-scale: 1.85; }
    
    /* Force light mode for this report */
    html { 
      max-width:100%; 
      overflow-x:hidden; 
      overflow-y:hidden; 
    }
    html.theme-light, html[data-theme='light'], html {
      --bg-color: #f0f2f5;
      --text-color: #1b222b;
    }
    body { 
      max-width:100%; 
      overflow-x:hidden; 
      overflow-y:hidden;
      background: #f0f2f5 !important;
      color: #1b222b !important;
    }
    /* Hide the site header/nav for this page to maximize chart space */
    header, .site-header, .navbar, nav, #header, .header-container { 
      display: none !important; 
    }
    
    /* Report Header - left aligned with settings on right */
    .report-header {
      display: flex;
      justify-content: flex-start;
      align-items: center;
      gap: 16px;
      padding: 0 0 10px 0;
      flex-shrink: 0;
    }
    
    .report-header .header-filter-btn,
    .report-header .header-settings-btn {
      margin-left: 0;
    }
    
    .report-header .header-filter-btn + .header-settings-btn {
      margin-left: 6px;
    }
    
    .eaton-badge {
      display: inline-flex;
      align-items: center;
      padding: 5px 12px;
      background: linear-gradient(135deg, #0066b3 0%, #004a8f 100%);
      color: #fff;
      font-size: 11px;
      font-weight: 700;
      letter-spacing: 0.8px;
      border-radius: 4px;
      font-family: 'Segoe UI', 'Inter', -apple-system, sans-serif;
      box-shadow: 0 2px 6px rgba(0,102,179,0.25);
    }
    
    .report-title {
      font-size: 24px;
      font-weight: 700;
      color: #1b222b;
      margin: 0;
      font-family: 'Segoe UI', 'Inter', -apple-system, sans-serif;
      display: flex;
      align-items: center;
      gap: 12px;
    }
    
    .report-title::before {
      content: '';
      display: inline-block;
      width: 4px;
      height: 28px;
      background: linear-gradient(135deg, #3b82f6 0%, #8b5cf6 100%);
      border-radius: 2px;
    }
    
    .header-spacer {
      flex: 1;
    }
    
    .header-settings-btn {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      width: 32px;
      height: 32px;
      border-radius: 8px;
      background: rgba(0,0,0,0.04);
      border: 1px solid rgba(0,0,0,0.08);
      color: #6b7280;
      cursor: pointer;
      transition: all 0.15s ease;
      text-decoration: none;
    }
    
    .header-settings-btn:hover {
      background: rgba(59,130,246,0.1);
      border-color: rgba(59,130,246,0.3);
      color: #3b82f6;
    }
    
    /* Font Size Toggle Button */
    .header-fontsize-btn {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      gap: 4px;
      height: 32px;
      padding: 0 10px;
      border-radius: 8px;
      background: rgba(0,0,0,0.04);
      border: 1px solid rgba(0,0,0,0.08);
      color: #6b7280;
      cursor: pointer;
      transition: all 0.15s ease;
      font-size: 11px;
      font-weight: 600;
      font-family: 'Segoe UI', 'Inter', -apple-system, sans-serif;
    }
    
    .header-fontsize-btn:hover {
      background: rgba(59,130,246,0.1);
      border-color: rgba(59,130,246,0.3);
      color: #3b82f6;
    }
    
    .header-fontsize-btn svg {
      width: 14px;
      height: 14px;
    }
    
    .fontsize-label {
      font-size: 10px;
      font-weight: 700;
      letter-spacing: 0.3px;
    }
    
    .header-filter-btn {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      width: 32px;
      height: 32px;
      border-radius: 8px;
      background: rgba(0,0,0,0.04);
      border: 1px solid rgba(0,0,0,0.08);
      color: #6b7280;
      cursor: pointer;
      transition: all 0.15s ease;
    }
    
    .header-filter-btn:hover {
      background: rgba(59,130,246,0.1);
      border-color: rgba(59,130,246,0.3);
      color: #3b82f6;
    }
    
    .header-filter-btn.active {
      background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
      border-color: #2563eb;
      color: #fff;
      box-shadow: 0 2px 8px rgba(59,130,246,0.35);
    }
    
    .header-filter-btn.has-filters {
      border-color: #3b82f6;
      color: #3b82f6;
    }
    
    html:not(.theme-light):not([data-theme='light']) .header-filter-btn {
      background: rgba(255,255,255,0.04);
      border-color: rgba(255,255,255,0.1);
      color: rgba(255,255,255,0.6);
    }
    
    html:not(.theme-light):not([data-theme='light']) .header-filter-btn:hover {
      background: rgba(59,130,246,0.15);
      border-color: rgba(59,130,246,0.4);
      color: #60a5fa;
    }
    
    html:not(.theme-light):not([data-theme='light']) .header-filter-btn.has-filters {
      border-color: #60a5fa;
      color: #60a5fa;
    }
    
    .header-filter-btn svg {
      width: 16px;
      height: 16px;
    }
    
    .header-refresh-btn {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      width: 32px;
      height: 32px;
      border-radius: 8px;
      background: rgba(0,0,0,0.04);
      border: 1px solid rgba(0,0,0,0.08);
      color: #6b7280;
      cursor: pointer;
      transition: all 0.15s ease;
    }
    
    .header-refresh-btn:hover {
      background: rgba(16,185,129,0.1);
      border-color: rgba(16,185,129,0.3);
      color: #10b981;
    }
    
    .header-refresh-btn:active {
      transform: scale(0.95);
    }
    
    .header-refresh-btn.refreshing svg {
      animation: spin 0.8s linear infinite;
    }
    
    @keyframes spin {
      from { transform: rotate(0deg); }
      to { transform: rotate(360deg); }
    }
    
    html:not(.theme-light):not([data-theme='light']) .header-refresh-btn {
      background: rgba(255,255,255,0.04);
      border-color: rgba(255,255,255,0.1);
      color: rgba(255,255,255,0.6);
    }
    
    html:not(.theme-light):not([data-theme='light']) .header-refresh-btn:hover {
      background: rgba(16,185,129,0.15);
      border-color: rgba(16,185,129,0.4);
      color: #34d399;
    }
    
    .header-refresh-btn svg {
      width: 16px;
      height: 16px;
    }
    
    /* Auto-refresh countdown timer */
    .refresh-countdown {
      font-size: 11px;
      font-family: 'Consolas', 'Monaco', monospace;
      color: #6b7280;
      background: rgba(0,0,0,0.04);
      padding: 4px 8px;
      border-radius: 6px;
      border: 1px solid rgba(0,0,0,0.08);
    }
    
    html:not(.theme-light):not([data-theme='light']) .refresh-countdown {
      color: rgba(255,255,255,0.6);
      background: rgba(255,255,255,0.04);
      border-color: rgba(255,255,255,0.1);
    }

    /* Filter Popup Menu */
    .filter-popup-overlay {
      display: none;
      position: fixed;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      background: rgba(0,0,0,0.3);
      z-index: 999;
      animation: fadeIn 0.15s ease;
    }
    
    .filter-popup-overlay.visible {
      display: block;
    }
    
    @keyframes fadeIn {
      from { opacity: 0; }
      to { opacity: 1; }
    }
    
    .filter-popup {
      position: fixed;
      top: 60px;
      right: 20px;
      background: #fff;
      border-radius: 12px;
      box-shadow: 0 8px 32px rgba(0,0,0,0.18), 0 2px 8px rgba(0,0,0,0.08);
      width: 860px;
      max-height: calc(100vh - 100px);
      overflow-y: auto;
      z-index: 1000;
      animation: slideInPopup 0.2s ease;
    }
    
    html:not(.theme-light):not([data-theme='light']) .filter-popup {
      background: #1e2530;
      box-shadow: 0 8px 32px rgba(0,0,0,0.5);
    }
    
    @keyframes slideInPopup {
      from { opacity: 0; transform: translateY(-10px); }
      to { opacity: 1; transform: translateY(0); }
    }
    
    .filter-popup-header {
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 16px 20px 12px;
      border-bottom: 1px solid rgba(0,0,0,0.06);
    }
    
    html:not(.theme-light):not([data-theme='light']) .filter-popup-header {
      border-bottom-color: rgba(255,255,255,0.08);
    }
    
    .filter-popup-title {
      font-size: 14px;
      font-weight: 600;
      color: #1b222b;
      font-family: 'Segoe UI', 'Inter', -apple-system, sans-serif;
    }
    
    html:not(.theme-light):not([data-theme='light']) .filter-popup-title {
      color: #fff;
    }
    
    .filter-popup-close {
      width: 28px;
      height: 28px;
      border-radius: 6px;
      background: transparent;
      border: none;
      color: rgba(0,0,0,0.4);
      cursor: pointer;
      display: flex;
      align-items: center;
      justify-content: center;
      transition: all 0.15s ease;
    }
    
    .filter-popup-close:hover {
      background: rgba(0,0,0,0.06);
      color: rgba(0,0,0,0.7);
    }
    
    html:not(.theme-light):not([data-theme='light']) .filter-popup-close {
      color: rgba(255,255,255,0.4);
    }
    
    html:not(.theme-light):not([data-theme='light']) .filter-popup-close:hover {
      background: rgba(255,255,255,0.08);
      color: rgba(255,255,255,0.8);
    }
    
    .filter-popup-section {
      padding: 16px 20px;
      border-bottom: 2px solid rgba(0,0,0,0.08);
      margin-bottom: 0;
    }
    
    .filter-popup-section:last-child {
      border-bottom: none;
      padding-bottom: 10px;
    }
    
    html:not(.theme-light):not([data-theme='light']) .filter-popup-section {
      border-bottom-color: rgba(255,255,255,0.12);
    }
    
    /* Yield section - green theme */
    .filter-section-title {
      font-size: 10px;
      font-weight: 700;
      text-transform: uppercase;
      letter-spacing: 1.2px;
      margin-bottom: 12px;
      padding-bottom: 6px;
      border-bottom: 1px solid rgba(0,0,0,0.06);
      color: #6b7280;
    }
    
    .filter-section-title.yield-title {
      color: #059669;
    }
    
    .filter-section-title.scrap-title {
      color: #ea580c;
    }
    
    html:not(.theme-light):not([data-theme='light']) .filter-section-title {
      border-bottom-color: rgba(255,255,255,0.1);
      color: rgba(255,255,255,0.5);
    }
    
    html:not(.theme-light):not([data-theme='light']) .filter-section-title.yield-title {
      color: #34d399;
    }
    
    html:not(.theme-light):not([data-theme='light']) .filter-section-title.scrap-title {
      color: #fb923c;
    }
    
    /* Pill/Chip filter group */
    .filter-pill-group {
      margin-bottom: 12px;
    }
    
    .filter-pill-group:last-child {
      margin-bottom: 0;
    }
    
    .filter-pill-label {
      font-size: 9px;
      font-weight: 600;
      color: #6b7280;
      text-transform: uppercase;
      letter-spacing: 0.5px;
      margin-bottom: 6px;
      font-family: 'Segoe UI', 'Inter', -apple-system, sans-serif;
    }
    
    html:not(.theme-light):not([data-theme='light']) .filter-pill-label {
      color: rgba(255,255,255,0.5);
    }
    
    .filter-pills {
      display: flex;
      flex-wrap: wrap;
      gap: 5px;
    }
    
    .filter-pill {
      display: inline-flex;
      align-items: center;
      padding: 5px 12px;
      border-radius: 16px;
      border: 1px solid rgba(0,0,0,0.12);
      background: #fff;
      color: #4b5563;
      font-size: 11px;
      font-weight: 500;
      font-family: 'Segoe UI', 'Inter', -apple-system, sans-serif;
      cursor: pointer;
      transition: all 0.15s ease;
    }
    
    .filter-pill:hover {
      border-color: #6b7280;
      color: #374151;
      background: rgba(0,0,0,0.02);
    }
    
    /* Yield pills - green theme */
    .filter-pill.yield-pill.selected {
      background: #059669;
      border-color: #059669;
      color: #fff;
    }
    
    .filter-pill.yield-pill:hover:not(.selected) {
      border-color: #059669;
      color: #059669;
      background: rgba(5,150,105,0.04);
    }
    
    /* Scrap pills - orange theme */
    .filter-pill.scrap-pill.selected {
      background: #ea580c;
      border-color: #ea580c;
      color: #fff;
    }
    
    .filter-pill.scrap-pill:hover:not(.selected) {
      border-color: #ea580c;
      color: #ea580c;
      background: rgba(234,88,12,0.04);
    }
    
    /* Fallback for pills without specific class */
    .filter-pill.selected {
      background: #3b82f6;
      border-color: #3b82f6;
      color: #fff;
    }
    
    html:not(.theme-light):not([data-theme='light']) .filter-pill {
      background: rgba(255,255,255,0.04);
      border-color: rgba(255,255,255,0.12);
      color: rgba(255,255,255,0.7);
    }
    
    html:not(.theme-light):not([data-theme='light']) .filter-pill:hover {
      border-color: rgba(255,255,255,0.3);
      color: rgba(255,255,255,0.9);
      background: rgba(255,255,255,0.08);
    }
    
    html:not(.theme-light):not([data-theme='light']) .filter-pill.yield-pill.selected {
      background: #059669;
      border-color: #059669;
      color: #fff;
    }
    
    html:not(.theme-light):not([data-theme='light']) .filter-pill.scrap-pill.selected {
      background: #ea580c;
      border-color: #ea580c;
      color: #fff;
    }
    
    html:not(.theme-light):not([data-theme='light']) .filter-pill.selected {
      background: #3b82f6;
      border-color: #3b82f6;
      color: #fff;
    }
    
    /* Custom date row for pills */
    .filter-pill-date-row {
      display: none;
      margin-top: 8px;
    }
    
    .filter-pill-date-row.visible {
      display: flex;
      align-items: center;
      gap: 8px;
    }
    
    .filter-pill-date, .filter-pill-month {
      padding: 6px 12px;
      border-radius: 8px;
      border: 1px solid rgba(0,0,0,0.15);
      background: #fff;
      color: #374151;
      font-size: 12px;
      font-weight: 500;
      font-family: 'Segoe UI', 'Inter', -apple-system, sans-serif;
      cursor: pointer;
      transition: all 0.15s ease;
      box-shadow: 0 1px 2px rgba(0,0,0,0.05);
    }
    
    .filter-pill-month {
      min-width: 140px;
    }
    
    .filter-pill-date:hover, .filter-pill-month:hover {
      border-color: rgba(0,0,0,0.25);
      box-shadow: 0 2px 4px rgba(0,0,0,0.08);
    }
    
    html:not(.theme-light):not([data-theme='light']) .filter-pill-date,
    html:not(.theme-light):not([data-theme='light']) .filter-pill-month {
      background: rgba(255,255,255,0.08);
      border-color: rgba(255,255,255,0.15);
      color: #fff;
      box-shadow: 0 1px 2px rgba(0,0,0,0.2);
    }
    
    html:not(.theme-light):not([data-theme='light']) .filter-pill-date:hover,
    html:not(.theme-light):not([data-theme='light']) .filter-pill-month:hover {
      border-color: rgba(255,255,255,0.3);
      background: rgba(255,255,255,0.12);
    }
    
    .filter-pill-date:focus, .filter-pill-month:focus {
      outline: none;
      border-color: #3b82f6;
      box-shadow: 0 0 0 3px rgba(59,130,246,0.15);
    }
    
    /* Custom month picker styling */
    input[type="month"] {
      font-family: 'Segoe UI', 'Inter', -apple-system, sans-serif;
      appearance: none;
      -webkit-appearance: none;
    }
    
    input[type="month"]::-webkit-calendar-picker-indicator {
      cursor: pointer;
      opacity: 0.6;
      transition: opacity 0.15s ease;
    }
    
    input[type="month"]::-webkit-calendar-picker-indicator:hover {
      opacity: 1;
    }
    
    /* Style the month picker dropdown (Chrome/Edge) */
    input[type="month"]::-webkit-datetime-edit {
      font-family: 'Segoe UI', 'Inter', -apple-system, sans-serif;
      font-size: 12px;
      font-weight: 500;
      padding: 0;
    }
    
    input[type="month"]::-webkit-datetime-edit-month-field,
    input[type="month"]::-webkit-datetime-edit-year-field {
      font-family: 'Segoe UI', 'Inter', -apple-system, sans-serif;
    }
    
    .filter-pill-date-sep {
      font-size: 11px;
      color: rgba(0,0,0,0.4);
    }
    
    html:not(.theme-light):not([data-theme='light']) .filter-pill-date-sep {
      color: rgba(255,255,255,0.4);
    }
    
    /* Filter popup footer with buttons */
    .filter-popup-footer {
      display: flex;
      justify-content: flex-end;
      gap: 10px;
      padding: 12px 20px 16px;
      border-top: 1px solid rgba(0,0,0,0.06);
    }
    
    html:not(.theme-light):not([data-theme='light']) .filter-popup-footer {
      border-top-color: rgba(255,255,255,0.08);
    }
    
    .filter-btn-reset {
      padding: 8px 20px;
      border-radius: 6px;
      border: 1px solid rgba(0,0,0,0.12);
      background: #fff;
      color: #4b5563;
      font-size: 13px;
      font-weight: 500;
      font-family: 'Segoe UI', 'Inter', -apple-system, sans-serif;
      cursor: pointer;
      transition: all 0.15s ease;
    }
    
    .filter-btn-reset:hover {
      background: #f3f4f6;
      border-color: rgba(0,0,0,0.2);
    }
    
    html:not(.theme-light):not([data-theme='light']) .filter-btn-reset {
      background: rgba(255,255,255,0.06);
      border-color: rgba(255,255,255,0.12);
      color: rgba(255,255,255,0.7);
    }
    
    html:not(.theme-light):not([data-theme='light']) .filter-btn-reset:hover {
      background: rgba(255,255,255,0.1);
    }
    
    .filter-btn-apply {
      padding: 8px 24px;
      border-radius: 6px;
      border: none;
      background: #3b82f6;
      color: #fff;
      font-size: 13px;
      font-weight: 600;
      font-family: 'Segoe UI', 'Inter', -apple-system, sans-serif;
      cursor: pointer;
      transition: all 0.15s ease;
    }
    
    .filter-btn-apply:hover {
      background: #2563eb;
    }
    
    /* Filter Status Textboxes - positioned close to their respective chart groups */
    .filter-status-bar {
      display: flex;
      align-items: center;
      gap: 6px;
      margin-bottom: 8px;
      flex-wrap: wrap;
    }
    
    .filter-status-box {
      display: inline-flex;
      align-items: center;
      padding: calc(3px * var(--font-scale, 1)) calc(8px * var(--font-scale, 1));
      border-radius: 4px;
      border: 1px solid rgba(0,0,0,0.1);
      background: #f9fafb;
      font-size: calc(10px * var(--font-scale, 1));
      font-family: 'Segoe UI', 'Inter', -apple-system, sans-serif;
      color: #6b7280;
    }
    
    html:not(.theme-light):not([data-theme='light']) .filter-status-box {
      background: rgba(255,255,255,0.04);
      border-color: rgba(255,255,255,0.1);
      color: rgba(255,255,255,0.6);
    }
    
    .filter-status-box .status-label {
      font-weight: 600;
      color: #374151;
      margin-right: 3px;
    }
    
    html:not(.theme-light):not([data-theme='light']) .filter-status-box .status-label {
      color: rgba(255,255,255,0.8);
    }
    
    .filter-status-box .status-value {
      color: #6b7280;
    }
    
    html:not(.theme-light):not([data-theme='light']) .filter-status-box .status-value {
      color: rgba(255,255,255,0.5);
    }
    
    /* Animated border for non-default filters */
    .filter-status-box.active-filter {
      border-color: #3b82f6;
      background: rgba(59,130,246,0.04);
      animation: borderGlow 2s ease-in-out infinite;
    }
    
    @keyframes borderGlow {
      0%, 100% { 
        border-color: #3b82f6; 
        box-shadow: 0 0 0 1px rgba(59,130,246,0.1);
      }
      50% { 
        border-color: #60a5fa; 
        box-shadow: 0 0 8px rgba(59,130,246,0.3);
      }
    }
    
    .filter-status-box.active-filter .status-label {
      color: #3b82f6;
    }
    
    .filter-status-box.active-filter .status-value {
      color: #3b82f6;
      font-weight: 500;
    }
    
    html:not(.theme-light):not([data-theme='light']) .filter-status-box.active-filter {
      background: rgba(59,130,246,0.08);
      border-color: #60a5fa;
    }
    
    html:not(.theme-light):not([data-theme='light']) .filter-status-box.active-filter .status-label,
    html:not(.theme-light):not([data-theme='light']) .filter-status-box.active-filter .status-value {
      color: #60a5fa;
    }
    
    .header-settings-btn svg {
      width: 16px;
      height: 16px;
    }
    
    /* Filter Bars - Collapsible */
    .filters-bar {
      display: none;
      align-items: center;
      gap: 10px;
      padding: 6px 0;
      flex-shrink: 0;
      flex-wrap: wrap;
      animation: slideDown 0.2s ease;
    }
    
    .filters-bar.visible {
      display: flex;
    }
    
    @keyframes slideDown {
      from { opacity: 0; transform: translateY(-8px); }
      to { opacity: 1; transform: translateY(0); }
    }
    
    /* Filter toggle button - professional button style like chart toggle */
    .filter-toggle-btn {
      display: inline-flex;
      align-items: center;
      gap: 6px;
      padding: 6px 12px;
      background: #f3f4f6;
      border: 1px solid #e5e7eb;
      border-radius: 6px;
      color: #6b7280;
      font-size: 11px;
      font-weight: 600;
      font-family: 'Segoe UI', 'Inter', -apple-system, sans-serif;
      cursor: pointer;
      transition: all 0.2s ease;
      text-transform: uppercase;
      letter-spacing: 0.3px;
    }
    
    .filter-toggle-btn:hover {
      background: #e5e7eb;
      border-color: #d1d5db;
      color: #4b5563;
    }
    
    .filter-toggle-btn.active {
      background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
      border-color: #2563eb;
      color: #fff;
      box-shadow: 0 2px 8px rgba(59,130,246,0.35), 0 0 0 2px rgba(59,130,246,0.15);
    }
    
    .filter-toggle-btn.active svg {
      filter: drop-shadow(0 0 3px rgba(255,255,255,0.5));
    }
    
    /* When filters have non-default values - alive blue glow */
    .filter-toggle-btn.has-active-filters {
      background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
      border-color: #2563eb;
      color: #fff;
      box-shadow: 0 2px 12px rgba(59,130,246,0.5), 0 0 0 3px rgba(59,130,246,0.2);
      animation: filterPulse 2s ease-in-out infinite;
    }
    
    .filter-toggle-btn.has-active-filters svg {
      filter: drop-shadow(0 0 4px rgba(255,255,255,0.7));
    }
    
    @keyframes filterPulse {
      0%, 100% { box-shadow: 0 2px 12px rgba(59,130,246,0.5), 0 0 0 3px rgba(59,130,246,0.2); }
      50% { box-shadow: 0 2px 16px rgba(59,130,246,0.7), 0 0 0 5px rgba(59,130,246,0.15); }
    }
    
    .filter-toggle-btn svg {
      width: 12px;
      height: 12px;
      transition: all 0.2s ease;
    }
    
    /* Hide the section label inside filters bar */
    .filters-bar .filter-section-label {
      display: none;
    }
    
    .filters-bar .filter-group {
      display: flex;
      align-items: center;
      gap: 4px;
    }
    
    .filters-bar .filter-label {
      font-size: 9px;
      font-weight: 500;
      color: rgba(0,0,0,0.45);
      white-space: nowrap;
      font-family: 'Inter', -apple-system, sans-serif;
    }
    
    .filters-bar .filter-select {
      padding: 4px 24px 4px 8px;
      border-radius: 5px;
      border: 1px solid rgba(0,0,0,0.1);
      background: #fff;
      color: #374151;
      font-size: 11px;
      font-weight: 500;
      font-family: 'Inter', -apple-system, sans-serif;
      cursor: pointer;
      appearance: none;
      -webkit-appearance: none;
      -moz-appearance: none;
      background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='10' height='10' viewBox='0 0 24 24' fill='none' stroke='%23666' stroke-width='2.5'%3E%3Cpath d='M6 9l6 6 6-6'/%3E%3C/svg%3E");
      background-repeat: no-repeat;
      background-position: right 6px center;
      min-width: 90px;
      transition: all 0.15s ease;
    }
    
    .filters-bar .filter-select:hover {
      border-color: rgba(59,130,246,0.4);
    }
    
    .filters-bar .filter-select:focus {
      outline: none;
      border-color: #3b82f6;
      box-shadow: 0 0 0 2px rgba(59,130,246,0.12);
    }
    
    /* Highlight non-default filter values */
    .filters-bar .filter-select.filter-active {
      background-color: rgba(59,130,246,0.08);
      border-color: rgba(59,130,246,0.4);
      color: #2563eb;
      font-weight: 600;
    }
    
    /* Custom date inputs */
    .filters-bar .custom-date-group {
      display: none;
      align-items: center;
      gap: 4px;
    }
    
    .filters-bar .custom-date-group.active {
      display: flex;
    }
    
    .filters-bar .filter-date {
      padding: 4px 8px;
      border-radius: 5px;
      border: 1px solid rgba(0,0,0,0.1);
      background: #fff;
      color: #374151;
      font-size: 11px;
      font-weight: 500;
      font-family: 'Inter', -apple-system, sans-serif;
      transition: all 0.15s ease;
    }
    
    .filters-bar .filter-date:hover {
      border-color: rgba(59,130,246,0.4);
    }
    
    .filters-bar .filter-date:focus {
      outline: none;
      border-color: #3b82f6;
      box-shadow: 0 0 0 2px rgba(59,130,246,0.12);
    }
    
    .quality-dashboard {
      display: flex;
      flex-direction: column;
      height: calc(100vh - 20px);
      padding: 10px 20px 10px;
      box-sizing: border-box;
      gap: 6px;
      overflow-x: visible;
      overflow-y: auto;
    }
    
    /* Section with header bar + charts - takes equal space */
    .metrics-section {
      flex: 1;
      display: flex;
      flex-direction: column;
      min-height: 0;
      overflow: visible;
    }
    
    .metrics-section .charts-row {
      flex: 1;
      min-height: 0;
      overflow: visible;
    }
    
    .metrics-section .chart-panel {
      min-height: 0;
      overflow: visible;
    }
    
    /* Legacy - hide old dash-header */
    .dash-header {
      display: none;
    }
    
    /* Legacy - keep for backward compatibility */
    .header-actions {
      display: none;
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
      grid-template-columns: minmax(200px, 20%) minmax(350px, 1fr) minmax(250px, 30%);
      gap: 12px;
      overflow: visible;
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
      box-shadow: 0 2px 8px rgba(0,0,0,0.08), 0 1px 3px rgba(0,0,0,0.04);
    }
    
    html:not(.theme-light):not([data-theme='light']) .chart-panel {
      background: rgba(255,255,255,0.03);
      border-color: rgba(255,255,255,0.05);
      box-shadow: 0 2px 8px rgba(0,0,0,0.25), 0 1px 3px rgba(0,0,0,0.15);
    }
    
    .panel-header {
      display: flex;
      justify-content: space-between;
      align-items: flex-start;
      margin-bottom: 8px;
      gap: 8px;
    }
    
    .panel-header h2 {
      font-size: calc(11px * var(--font-scale, 1));
      font-weight: 600;
      font-family: 'Segoe UI', 'Inter', -apple-system, sans-serif;
      margin: 0;
      color: #1b222b;
    }
    
    html:not(.theme-light):not([data-theme='light']) .panel-header h2 { color: #fff; }
    
    .panel-header .panel-subtitle {
      font-size: calc(9px * var(--font-scale, 1));
      font-family: 'Inter', 'Segoe UI', -apple-system, BlinkMacSystemFont, sans-serif;
      color: rgba(0,0,0,0.55);
      margin-top: 1px;
      letter-spacing: 0.15px;
      font-weight: 400;
    }
    
    html:not(.theme-light):not([data-theme='light']) .panel-header .panel-subtitle { color: rgba(255,255,255,0.5); }

    /* Scrap panel header - orange accent */
    .panel-header.scrap-header h2 {
      color: #ea580c;
    }
    html:not(.theme-light):not([data-theme='light']) .panel-header.scrap-header h2 {
      color: #fb923c;
    }
    
    /* Scrap gauge value - dynamic color based on goal comparison (set via JS) */
    .scrap-value {
      transition: color 0.2s ease;
    }
    .scrap-value.under-goal {
      color: #10b981 !important;
    }
    .scrap-value.over-goal {
      color: #ef4444 !important;
    }
    html:not(.theme-light):not([data-theme='light']) .scrap-value.under-goal {
      color: #34d399 !important;
    }
    html:not(.theme-light):not([data-theme='light']) .scrap-value.over-goal {
      color: #f87171 !important;
    }
    
    /* Top items chart container within gauge panel */
    .top-items-chart-container {
      flex: 1;
      min-height: 120px;
      max-height: 160px;
      padding: 4px 8px;
      position: relative;
    }
    
    /* NCM placeholder styles */
    .ncm-placeholder {
      display: flex;
      align-items: center;
      justify-content: center;
      height: 100%;
      flex: 1;
      color: rgba(0,0,0,0.3);
      font-size: 12px;
      font-style: italic;
    }
    html:not(.theme-light):not([data-theme='light']) .ncm-placeholder {
      color: rgba(255,255,255,0.3);
    }
    
    /* NCM Panel Header */
    .panel-header.ncm-header h2 { color: #f59e0b; }
    html:not(.theme-light):not([data-theme='light']) .panel-header.ncm-header h2 { color: #fbbf24; }
    
    /* NCM uses shared .both-view-container, .gauge-container.compact, etc. */
    
    /* NCM specific value colors */
    .ncm-value.under-goal { color: #10b981 !important; }
    .ncm-value.over-goal { color: #ef4444 !important; }
    
    /* NCM Bar Chart container */
    .ncm-bar-chart-container {
      flex: 1;
      min-height: 100px;
      max-height: 150px;
      padding: 4px 8px;
      width: 100% !important;
      height: 100% !important;
    }
    
    .ncm-table td.value-cell {
      text-align: right;
      color: #dc2626;
      font-weight: 600;
    }
    
    html:not(.theme-light):not([data-theme='light']) .ncm-table td.value-cell {
      color: #f87171;
    }
    
    .ncm-table td.pct-cell {
      text-align: right;
      color: #dc2626;
      font-weight: 500;
    }
    
    html:not(.theme-light):not([data-theme='light']) .ncm-table td.pct-cell {
      color: #f87171;
    }
    
    .ncm-table th:nth-child(3),
    .ncm-table th:nth-child(4) {
      text-align: right;
    }
    
    .ncm-no-data {
      display: flex;
      align-items: center;
      justify-content: center;
      height: 100%;
      color: rgba(0,0,0,0.35);
      font-size: 11px;
      font-style: italic;
    }
    html:not(.theme-light):not([data-theme='light']) .ncm-no-data {
      color: rgba(255,255,255,0.35);
    }
    
    /* NCM Bullet Chart Summary */
    .ncm-bullet-summary {
      padding: 10px 12px;
      border-bottom: 1px solid rgba(0,0,0,0.08);
      background: linear-gradient(180deg, rgba(245,158,11,0.04) 0%, transparent 100%);
    }
    html:not(.theme-light):not([data-theme='light']) .ncm-bullet-summary {
      border-bottom-color: rgba(255,255,255,0.08);
    }
    .ncm-bullet-header {
      display: flex;
      align-items: baseline;
      gap: 8px;
      margin-bottom: 8px;
    }
    .ncm-bullet-value {
      font-size: calc(18px * var(--font-scale, 1));
      font-weight: 700;
      color: rgba(0,0,0,0.85);
    }
    .ncm-bullet-value.under-goal { color: #10b981; }
    .ncm-bullet-value.over-goal { color: #ef4444; }
    html:not(.theme-light):not([data-theme='light']) .ncm-bullet-value { color: rgba(255,255,255,0.9); }
    html:not(.theme-light):not([data-theme='light']) .ncm-bullet-value.under-goal { color: #34d399; }
    html:not(.theme-light):not([data-theme='light']) .ncm-bullet-value.over-goal { color: #f87171; }
    .ncm-bullet-label {
      font-size: calc(10px * var(--font-scale, 1));
      color: rgba(0,0,0,0.5);
      text-transform: uppercase;
      letter-spacing: 0.5px;
    }
    html:not(.theme-light):not([data-theme='light']) .ncm-bullet-label { color: rgba(255,255,255,0.5); }
    .ncm-bullet-chart {
      position: relative;
    }
    .ncm-bullet-track {
      position: relative;
      height: 16px;
      background: rgba(0,0,0,0.08);
      border-radius: 3px;
      overflow: hidden;
    }
    html:not(.theme-light):not([data-theme='light']) .ncm-bullet-track { background: rgba(255,255,255,0.1); }
    .ncm-bullet-bar {
      position: absolute;
      left: 0;
      top: 0;
      height: 100%;
      background: #10b981;
      transition: width 0.3s ease;
      border-radius: 3px 0 0 3px;
    }
    .ncm-bullet-bar.over-goal { background: #ef4444; }
    .ncm-bullet-goal {
      position: absolute;
      top: -2px;
      width: 3px;
      height: 20px;
      background: rgba(0,0,0,0.7);
      border-radius: 1px;
      z-index: 2;
    }
    html:not(.theme-light):not([data-theme='light']) .ncm-bullet-goal { background: rgba(255,255,255,0.8); }
    .ncm-bullet-scale {
      display: flex;
      justify-content: space-between;
      margin-top: 4px;
      font-size: 9px;
      color: rgba(0,0,0,0.45);
    }
    html:not(.theme-light):not([data-theme='light']) .ncm-bullet-scale { color: rgba(255,255,255,0.45); }
    
    /* NCM Table View */
    .ncm-table-view {
      flex: 1;
      overflow: auto;
      padding: 0;
      max-height: 260px;
      min-height: 0;
    }
    
    .ncm-table {
      width: 100%;
      border-collapse: collapse;
      font-size: calc(9px * var(--font-scale, 1));
      font-family: 'Segoe UI', 'Inter', -apple-system, sans-serif;
    }
    
    .ncm-table thead {
      position: sticky;
      top: 0;
      z-index: 10;
    }
    
    .ncm-table th {
      text-align: center;
      padding: calc(4px * var(--font-scale, 1)) calc(8px * var(--font-scale, 1));
      background: #f0f0f0;
      border: 1px solid rgba(0,0,0,0.12);
      font-weight: 600;
      font-size: 9px;
      color: #555;
      white-space: nowrap;
    }
    
    .ncm-table th:first-child {
      text-align: left;
    }
    
    .ncm-table td {
      padding: calc(4px * var(--font-scale, 1)) calc(8px * var(--font-scale, 1));
      border: 1px solid rgba(0,0,0,0.12);
      color: #1b222b;
      vertical-align: middle;
    }
    
    .ncm-table td:first-child {
      font-weight: 700;
      color: #1b222b;
    }
    
    .ncm-table td:nth-child(2) {
      color: #1b222b;
      max-width: 180px;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }
    
    .ncm-table td:nth-child(3) {
      text-align: right;
      font-weight: 600;
      color: #dc2626;
      white-space: nowrap;
    }
    
    .ncm-table td:nth-child(4) {
      text-align: right;
      background: rgba(239,68,68,0.15);
    }
    
    .ncm-table tbody tr:hover td {
      background: rgba(0,0,0,0.04);
    }
    
    .ncm-table tbody tr:hover td:nth-child(4) {
      background: rgba(239,68,68,0.2);
    }
    
    .ncm-table tbody tr:nth-child(even) td {
      background: rgba(0,0,0,0.02);
    }
    
    .ncm-table tbody tr:nth-child(even) td:nth-child(4) {
      background: rgba(239,68,68,0.15);
    }
    
    .ncm-table tbody tr:nth-child(even):hover td {
      background: rgba(0,0,0,0.04);
    }
    
    .ncm-table tbody tr:nth-child(even):hover td:nth-child(4) {
      background: rgba(239,68,68,0.2);
    }
    
    /* Dark mode NCM table */
    html:not(.theme-light):not([data-theme='light']) .ncm-table th {
      background: rgba(255,255,255,0.1);
      border-color: rgba(255,255,255,0.15);
      color: rgba(255,255,255,0.8);
    }
    
    html:not(.theme-light):not([data-theme='light']) .ncm-table td {
      border-color: rgba(255,255,255,0.15);
      color: #fff;
    }
    
    html:not(.theme-light):not([data-theme='light']) .ncm-table td:first-child {
      color: #fff;
    }
    
    html:not(.theme-light):not([data-theme='light']) .ncm-table td:nth-child(2) {
      color: rgba(255,255,255,0.85);
    }
    
    html:not(.theme-light):not([data-theme='light']) .ncm-table td:nth-child(3) {
      color: #f87171;
    }
    
    html:not(.theme-light):not([data-theme='light']) .ncm-table td:nth-child(4) {
      background: rgba(239,68,68,0.2);
    }
    
    html:not(.theme-light):not([data-theme='light']) .ncm-table tbody tr:nth-child(even) td {
      background: rgba(255,255,255,0.02);
    }
    
    html:not(.theme-light):not([data-theme='light']) .ncm-table tbody tr:hover td {
      background: rgba(255,255,255,0.05);
    }
    
    html:not(.theme-light):not([data-theme='light']) .ncm-table-view tr:hover td {
      background: rgba(255,255,255,0.05);
    }
    
    html:not(.theme-light):not([data-theme='light']) .ncm-table-view td.value-cell {
      color: #f87171;
    }

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
      padding: calc(4px * var(--font-scale, 1)) calc(10px * var(--font-scale, 1));
      border: none;
      background: transparent;
      color: rgba(0,0,0,0.55);
      font-size: calc(10px * var(--font-scale, 1));
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
      font-size: calc(28px * var(--font-scale, 1)) !important;
      font-weight: 800 !important;
    }
    
    .gauge-label-large {
      font-size: calc(10px * var(--font-scale, 1)) !important;
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
      font-size: calc(11px * var(--font-scale, 1));
    }
    
    .line-table-large th,
    .line-table-large td {
      padding: calc(6px * var(--font-scale, 1)) calc(10px * var(--font-scale, 1));
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
      font-size: calc(18px * var(--font-scale, 1));
      font-weight: 700;
      font-family: 'Segoe UI', 'Inter', -apple-system, sans-serif;
      color: #1b222b;
      line-height: 1;
    }
    
    html:not(.theme-light):not([data-theme='light']) .gauge-value { color: #fff; }
    
    .gauge-label {
      font-size: calc(8px * var(--font-scale, 1));
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
      font-size: calc(12px * var(--font-scale, 1));
      font-weight: 600;
      font-family: 'Segoe UI', 'Inter', -apple-system, sans-serif;
      color: #1b222b;
    }
    
    html:not(.theme-light):not([data-theme='light']) .gauge-stat-value { color: #fff; }
    
    .gauge-stat-label {
      font-size: calc(8px * var(--font-scale, 1));
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
    
    .line-table td.cell-good {
      background: rgba(16,185,129,0.15);
      color: #059669;
    }
    
    .line-table td.cell-bad {
      background: rgba(239,68,68,0.15);
      color: #dc2626;
    }
    
    /* Text-only coloring (no background) for variance columns */
    .line-table td.text-good {
      color: #059669;
      font-weight: 600;
    }
    
    .line-table td.text-bad {
      color: #dc2626;
      font-weight: 600;
    }
    
    html:not(.theme-light):not([data-theme='light']) .line-table td.cell-good {
      background: rgba(16,185,129,0.2);
      color: #34d399;
    }
    
    html:not(.theme-light):not([data-theme='light']) .line-table td.cell-bad {
      background: rgba(239,68,68,0.2);
      color: #f87171;
    }
    
    html:not(.theme-light):not([data-theme='light']) .line-table td.text-good {
      color: #34d399;
    }
    
    html:not(.theme-light):not([data-theme='light']) .line-table td.text-bad {
      color: #f87171;
    }
    
    .line-table {
      width: 100%;
      font-size: calc(9px * var(--font-scale, 1));
      font-family: 'Segoe UI', 'Inter', -apple-system, sans-serif;
      border-collapse: collapse;
    }
    
    .line-table th, .line-table td {
      padding: calc(4px * var(--font-scale, 1)) calc(8px * var(--font-scale, 1));
      text-align: right;
      border: 1px solid rgba(0,0,0,0.12);
      color: #1b222b;
    }
    
    .line-table th:first-child, .line-table td:first-child {
      text-align: left;
    }
    
    .line-table th {
      font-weight: 600;
      color: #555;
      font-size: calc(9px * var(--font-scale, 1));
      background: #f0f0f0;
      text-align: center;
    }
    
    html:not(.theme-light):not([data-theme='light']) .line-table th { 
      color: rgba(255,255,255,0.8); 
      background: rgba(255,255,255,0.1);
      border-color: rgba(255,255,255,0.15);
    }
    
    html:not(.theme-light):not([data-theme='light']) .line-table td {
      border-color: rgba(255,255,255,0.15);
    }
    
    .line-table td {
      color: #1b222b;
    }
    
    .line-table td:first-child {
      font-weight: 700;
    }
    
    html:not(.theme-light):not([data-theme='light']) .line-table td { color: #fff; }
    
    .line-table tbody tr:hover {
      background: rgba(0,0,0,0.02);
    }
    
    html:not(.theme-light):not([data-theme='light']) .line-table tbody tr:hover { background: rgba(255,255,255,0.02); }
    
    .line-table tfoot tr {
      font-weight: 600;
      border-top: 2px solid rgba(0,0,0,0.15);
    }
    
    .line-table tfoot td {
      background: #f0f0f0 !important;
    }
    
    html:not(.theme-light):not([data-theme='light']) .line-table tfoot tr { border-top-color: rgba(255,255,255,0.15); }
    
    html:not(.theme-light):not([data-theme='light']) .line-table tfoot td {
      background: rgba(255,255,255,0.1) !important;
    }
    
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
      font-size: calc(9px * var(--font-scale, 1));
    }
    
    .data-table-view th,
    .data-table-view td {
      padding: calc(4px * var(--font-scale, 1)) calc(8px * var(--font-scale, 1));
      text-align: center;
      border: 1px solid rgba(0,0,0,0.12);
      white-space: nowrap;
      color: #1b222b;
    }
    
    html:not(.theme-light):not([data-theme='light']) .data-table-view th,
    html:not(.theme-light):not([data-theme='light']) .data-table-view td {
      border-color: rgba(255,255,255,0.15);
      color: #fff;
    }
    
    .data-table-view th {
      background: #f0f0f0;
      font-weight: 600;
      color: #555;
      position: sticky;
      top: 0;
      z-index: 1;
    }
    
    html:not(.theme-light):not([data-theme='light']) .data-table-view th {
      background: rgba(255,255,255,0.1);
      color: rgba(255,255,255,0.8);
    }
    
    .data-table-view th:first-child {
      position: sticky;
      left: 0;
      z-index: 2;
    }
    
    .data-table-view td:first-child {
      position: sticky;
      left: 0;
      background: #fff;
      font-weight: 700;
      text-align: left;
      z-index: 1;
      color: #1b222b;
    }
    
    html:not(.theme-light):not([data-theme='light']) .data-table-view td:first-child {
      background: rgba(30,35,45,0.98);
      color: #fff;
    }
    
    .data-table-view td.cell-good {
      background: rgba(16,185,129,0.15);
      color: #059669;
    }
    
    .data-table-view td.cell-bad {
      background: rgba(239,68,68,0.15);
      color: #dc2626;
    }
    
    /* Text-only coloring (no background) for variance columns */
    .data-table-view td.text-good {
      color: #059669;
      font-weight: 600;
    }
    
    .data-table-view td.text-bad {
      color: #dc2626;
      font-weight: 600;
    }
    
    html:not(.theme-light):not([data-theme='light']) .data-table-view td.cell-good {
      background: rgba(16,185,129,0.2);
      color: #34d399;
    }
    
    html:not(.theme-light):not([data-theme='light']) .data-table-view td.cell-bad {
      background: rgba(239,68,68,0.2);
      color: #f87171;
    }
    
    html:not(.theme-light):not([data-theme='light']) .data-table-view td.text-good {
      color: #34d399;
    }
    
    html:not(.theme-light):not([data-theme='light']) .data-table-view td.text-bad {
      color: #f87171;
    }
    
    .data-table-view tfoot td {
      font-weight: 700;
      background: #f0f0f0 !important;
    }
    
    html:not(.theme-light):not([data-theme='light']) .data-table-view tfoot td {
      background: rgba(255,255,255,0.1) !important;
    }
    
    /* Custom tooltip for table cells */
    .cell-tooltip {
      position: fixed;
      z-index: 9999;
      pointer-events: none;
      opacity: 0;
      transition: opacity 0.15s ease;
      font-family: 'Inter', 'Segoe UI', -apple-system, sans-serif;
    }
    
    .cell-tooltip.visible {
      opacity: 1;
    }
    
    .cell-tooltip-content {
      background: rgba(255,255,255,0.98);
      border: 1px solid rgba(0,0,0,0.1);
      border-radius: 8px;
      padding: 10px 14px;
      box-shadow: 0 4px 20px rgba(0,0,0,0.15), 0 2px 8px rgba(0,0,0,0.1);
      min-width: 140px;
    }
    
    html:not(.theme-light):not([data-theme='light']) .cell-tooltip-content {
      background: rgba(30,35,45,0.98);
      border-color: rgba(255,255,255,0.15);
      box-shadow: 0 4px 20px rgba(0,0,0,0.4);
    }
    
    .cell-tooltip-title {
      font-size: 11px;
      font-weight: 600;
      color: #1b222b;
      margin-bottom: 8px;
      padding-bottom: 6px;
      border-bottom: 1px solid rgba(0,0,0,0.08);
    }
    
    html:not(.theme-light):not([data-theme='light']) .cell-tooltip-title {
      color: #fff;
      border-bottom-color: rgba(255,255,255,0.1);
    }
    
    .cell-tooltip-row {
      display: flex;
      justify-content: space-between;
      align-items: center;
      gap: 16px;
      padding: 3px 0;
      font-size: 11px;
    }
    
    .cell-tooltip-label {
      color: rgba(0,0,0,0.55);
    }
    
    html:not(.theme-light):not([data-theme='light']) .cell-tooltip-label {
      color: rgba(255,255,255,0.6);
    }
    
    .cell-tooltip-value {
      font-weight: 600;
      color: #1b222b;
    }
    
    html:not(.theme-light):not([data-theme='light']) .cell-tooltip-value {
      color: #fff;
    }
    
    .cell-tooltip-value.passed {
      color: #10b981;
    }
    
    .cell-tooltip-value.failed {
      color: #ef4444;
    }
    
    .cell-tooltip-yield {
      margin-top: 6px;
      padding-top: 6px;
      border-top: 1px solid rgba(0,0,0,0.08);
    }
    
    html:not(.theme-light):not([data-theme='light']) .cell-tooltip-yield {
      border-top-color: rgba(255,255,255,0.1);
    }
    
    /* Custom tooltip for chart (Column/Line mode) */
    .chart-tooltip {
      position: absolute;
      z-index: 9999;
      pointer-events: none;
      opacity: 0;
      transition: opacity 0.15s ease;
      font-family: 'Inter', 'Segoe UI', -apple-system, sans-serif;
    }
    
    .chart-tooltip.visible {
      opacity: 1;
    }
    
    .chart-tooltip-content {
      background: rgba(255,255,255,0.98);
      border: 1px solid rgba(0,0,0,0.1);
      border-radius: 8px;
      padding: 10px 14px;
      box-shadow: 0 4px 20px rgba(0,0,0,0.15), 0 2px 8px rgba(0,0,0,0.1);
      min-width: 160px;
    }
    
    html:not(.theme-light):not([data-theme='light']) .chart-tooltip-content {
      background: rgba(30,35,45,0.98);
      border-color: rgba(255,255,255,0.15);
      box-shadow: 0 4px 20px rgba(0,0,0,0.4);
    }
    
    .chart-tooltip-title {
      font-size: 12px;
      font-weight: 600;
      color: #1b222b;
      margin-bottom: 8px;
      padding-bottom: 6px;
      border-bottom: 1px solid rgba(0,0,0,0.08);
    }
    
    html:not(.theme-light):not([data-theme='light']) .chart-tooltip-title {
      color: #fff;
      border-bottom-color: rgba(255,255,255,0.1);
    }
    
    .chart-tooltip-row {
      display: flex;
      justify-content: space-between;
      align-items: center;
      gap: 20px;
      padding: 3px 0;
      font-size: 11px;
    }
    
    .chart-tooltip-label {
      color: rgba(0,0,0,0.55);
    }
    
    html:not(.theme-light):not([data-theme='light']) .chart-tooltip-label {
      color: rgba(255,255,255,0.6);
    }
    
    .chart-tooltip-value {
      font-weight: 600;
      color: #1b222b;
    }
    
    html:not(.theme-light):not([data-theme='light']) .chart-tooltip-value {
      color: #fff;
    }
    
    .chart-tooltip-value.passed {
      color: #10b981;
    }
    
    .chart-tooltip-value.failed {
      color: #ef4444;
    }
    
    .chart-tooltip-value.yield-value {
      color: #10b981;
      font-size: 12px;
    }
    
    .chart-tooltip-value.cumulative-value {
      color: #1e40af;
    }
    
    html:not(.theme-light):not([data-theme='light']) .chart-tooltip-value.cumulative-value {
      color: #60a5fa;
    }
    
    .chart-tooltip-value.goal-value {
      color: rgba(0,0,0,0.5);
    }
    
    html:not(.theme-light):not([data-theme='light']) .chart-tooltip-value.goal-value {
      color: rgba(255,255,255,0.5);
    }
    
    /* Scrap tooltip value colors */
    .chart-tooltip-value.scrap-value {
      color: #ea580c;
      font-size: 12px;
    }
    
    .chart-tooltip-value.scrap-cumulative {
      color: #ea580c;
    }
    
    .chart-tooltip-value.scrap-orange {
      color: #ea580c !important;
    }
    
    .chart-tooltip-value.variance-blue {
      color: #3b82f6 !important;
    }
    
    .chart-tooltip-value.under-goal {
      color: #10b981;
    }
    
    .chart-tooltip-value.over-goal {
      color: #ef4444;
    }
    
    .chart-tooltip-value.text-green { color: #10b981 !important; }
    .chart-tooltip-value.text-red { color: #ef4444 !important; }
    .chart-tooltip-value.text-blue { color: #3b82f6 !important; }
    
    .scrap-cell-hover {
      cursor: pointer;
      transition: background-color 0.15s;
    }
    
    .scrap-cell-hover:hover {
      background-color: rgba(59,130,246,0.08) !important;
    }
    
    .chart-tooltip-divider {
      margin-top: 6px;
      padding-top: 6px;
      border-top: 1px solid rgba(0,0,0,0.08);
    }
    
    html:not(.theme-light):not([data-theme='light']) .chart-tooltip-divider {
      border-top-color: rgba(255,255,255,0.1);
    }
    
    /* Custom tooltip for failures by category */
    .failure-tooltip {
      position: absolute;
      z-index: 9999;
      pointer-events: none;
      opacity: 0;
      transition: opacity 0.15s ease;
      font-family: 'Inter', 'Segoe UI', -apple-system, sans-serif;
    }
    
    .failure-tooltip.visible {
      opacity: 1;
    }
    
    .failure-tooltip-content {
      background: rgba(255,255,255,0.98);
      border: 1px solid rgba(0,0,0,0.1);
      border-radius: 8px;
      padding: 12px 14px;
      box-shadow: 0 4px 20px rgba(0,0,0,0.15), 0 2px 8px rgba(0,0,0,0.1);
      min-width: 180px;
      max-width: 280px;
      max-height: 300px;
      overflow-y: auto;
    }
    
    html:not(.theme-light):not([data-theme='light']) .failure-tooltip-content {
      background: rgba(30,35,45,0.98);
      border-color: rgba(255,255,255,0.15);
      box-shadow: 0 4px 20px rgba(0,0,0,0.4);
    }
    
    .failure-tooltip-header {
      font-size: 13px;
      font-weight: 600;
      color: #1b222b;
      margin-bottom: 10px;
      padding-bottom: 8px;
      border-bottom: 1px solid rgba(0,0,0,0.08);
      position: relative;
      padding-right: 24px;
    }
    
    html:not(.theme-light):not([data-theme='light']) .failure-tooltip-header {
      color: #fff;
      border-bottom-color: rgba(255,255,255,0.1);
    }
    
    .failure-tooltip-line {
      margin-bottom: 8px;
    }
    
    .failure-tooltip-line:last-child {
      margin-bottom: 0;
    }
    
    .failure-tooltip-line-header {
      font-size: 11px;
      font-weight: 600;
      color: #3b82f6;
      margin-bottom: 4px;
    }
    
    .failure-tooltip-serials {
      display: flex;
      flex-wrap: wrap;
      gap: 4px;
    }
    
    .failure-tooltip-serial {
      font-size: 9px;
      padding: 2px 6px;
      background: rgba(0,0,0,0.05);
      border-radius: 3px;
      color: rgba(0,0,0,0.7);
      font-family: 'Consolas', 'Monaco', monospace;
    }
    
    html:not(.theme-light):not([data-theme='light']) .failure-tooltip-serial {
      background: rgba(255,255,255,0.08);
      color: rgba(255,255,255,0.8);
    }
    
    .failure-tooltip-more {
      font-size: 9px;
      color: rgba(0,0,0,0.4);
      font-style: italic;
    }
    
    html:not(.theme-light):not([data-theme='light']) .failure-tooltip-more {
      color: rgba(255,255,255,0.4);
    }
    
    /* Clickable expand/collapse link */
    .failure-tooltip-expand {
      cursor: pointer;
      text-decoration: none;
      transition: all 0.15s ease;
      user-select: none;
    }
    
    .failure-tooltip-expand:hover {
      color: #3b82f6;
      text-decoration: underline;
    }
    
    html:not(.theme-light):not([data-theme='light']) .failure-tooltip-expand:hover {
      color: #60a5fa;
    }
    
    /* Pinned tooltip state */
    .failure-tooltip.pinned {
      pointer-events: auto;
    }
    
    .failure-tooltip.pinned .failure-tooltip-content {
      border-color: #3b82f6;
      box-shadow: 0 4px 20px rgba(59,130,246,0.25), 0 2px 8px rgba(0,0,0,0.15);
    }
    
    .tooltip-close-btn {
      position: absolute;
      top: 8px;
      right: 10px;
      width: 18px;
      height: 18px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 16px;
      font-weight: 400;
      color: rgba(0,0,0,0.4);
      cursor: pointer;
      border-radius: 50%;
      transition: all 0.15s ease;
    }
    
    .tooltip-close-btn:hover {
      background: rgba(0,0,0,0.08);
      color: rgba(0,0,0,0.7);
    }
    
    html:not(.theme-light):not([data-theme='light']) .tooltip-close-btn {
      color: rgba(255,255,255,0.5);
    }
    
    html:not(.theme-light):not([data-theme='light']) .tooltip-close-btn:hover {
      background: rgba(255,255,255,0.1);
      color: rgba(255,255,255,0.9);
    }
    
    /* Table cells with hover tooltip */
    .has-failure-tooltip {
      cursor: pointer;
      transition: all 0.15s ease;
    }
    
    .has-failure-tooltip:hover {
      box-shadow: inset 0 0 0 2px rgba(239,68,68,0.4);
    }
    
    /* Section Divider - LEGACY, hidden */
    .section-divider-wrapper {
      display: none;
    }
    
    .section-divider {
      display: flex;
      align-items: center;
      gap: 16px;
    }
    
    .section-divider::before,
    .section-divider::after {
      content: '';
      flex: 1;
      height: 1px;
    }
    
    /* Yield section - green */
    .section-divider.yield-divider::before,
    .section-divider.yield-divider::after {
      background: rgba(16, 185, 129, 0.3);
    }
    
    .section-divider.yield-divider .section-divider-text {
      color: #10b981;
    }
    
    /* Scrap section - orange */
    .section-divider.scrap-divider::before,
    .section-divider.scrap-divider::after {
      background: rgba(249, 115, 22, 0.3);
    }
    
    .section-divider.scrap-divider .section-divider-text {
      color: #f97316;
    }
    
    .section-divider-text {
      font-size: 11px;
      font-weight: 700;
      text-transform: uppercase;
      letter-spacing: 1.5px;
      white-space: nowrap;
    }
    
    /* Section Filters - row below title, left aligned */
    .section-filters {
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 6px;
      flex-wrap: wrap;
    }
    
    .filter-pill {
      display: inline-flex;
      align-items: center;
      gap: 4px;
      padding: 5px 12px;
      border-radius: 16px;
      background: rgba(0,0,0,0.03);
      border: 1px solid rgba(0,0,0,0.08);
      font-size: 12px;
      white-space: nowrap;
      transition: all 0.15s ease;
    }
    
    .filter-pill-label {
      color: rgba(0,0,0,0.45);
      font-weight: 500;
    }
    
    .filter-pill-select {
      padding: 0;
      border: none;
      background: transparent;
      color: #1b222b;
      font-size: 12px;
      font-weight: 600;
      font-family: 'Segoe UI', 'Inter', -apple-system, sans-serif;
      cursor: pointer;
      appearance: none;
      -webkit-appearance: none;
      -moz-appearance: none;
      padding-right: 16px;
      background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='10' height='10' viewBox='0 0 24 24' fill='none' stroke='%23555' stroke-width='2.5'%3E%3Cpath d='M6 9l6 6 6-6'/%3E%3C/svg%3E");
      background-repeat: no-repeat;
      background-position: right 0 center;
    }
    
    .filter-pill-select:focus {
      outline: none;
    }
    
    .filter-pill:hover {
      background: rgba(0,0,0,0.06);
      border-color: rgba(0,0,0,0.12);
    }
    
    .filter-separator {
      color: rgba(0,0,0,0.2);
      font-size: 12px;
      font-weight: 300;
    }
    
    /* Custom date picker inline */
    .custom-date-inline {
      display: none;
      align-items: center;
      gap: 6px;
    }
    
    .custom-date-inline.active {
      display: inline-flex;
    }
    
    .custom-date-inline input[type="date"] {
      padding: 4px 8px;
      border-radius: 12px;
      border: 1px solid rgba(0,0,0,0.1);
      background: #fff;
      font-size: 11px;
      font-family: 'Segoe UI', 'Inter', -apple-system, sans-serif;
      color: #1b222b;
    }
    
    .custom-date-inline input[type="date"]:focus {
      outline: none;
      border-color: rgba(59,130,246,0.5);
    }
    
    .custom-date-inline span {
      font-size: 11px;
      color: rgba(0,0,0,0.4);
    }

    /* Backward compatibility - hide old section-header-bar if still used */
    .section-header-bar {
      display: none;
    }
    
    /* Legacy support for old filter selects */
    .section-filter-select {
      padding: 6px 28px 6px 12px;
      border-radius: 6px;
      border: 1px solid rgba(0,0,0,0.12);
      background: #fff;
      color: #1b222b;
      font-size: 12px;
      font-weight: 500;
      font-family: 'Segoe UI', 'Inter', -apple-system, sans-serif;
      cursor: pointer;
      appearance: none;
      -webkit-appearance: none;
      -moz-appearance: none;
      background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='%23666' stroke-width='2'%3E%3Cpath d='M6 9l6 6 6-6'/%3E%3C/svg%3E");
      background-repeat: no-repeat;
      background-position: right 8px center;
      min-width: 120px;
      transition: all 0.15s ease;
    }
    
    html:not(.theme-light):not([data-theme='light']) .section-filter-select {
      background: rgba(255,255,255,0.06);
      border-color: rgba(255,255,255,0.12);
      color: #fff;
      background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='%23aaa' stroke-width='2'%3E%3Cpath d='M6 9l6 6 6-6'/%3E%3C/svg%3E");
    }
    
    html:not(.theme-light):not([data-theme='light']) .section-filter-select:hover {
      border-color: rgba(96,165,250,0.4);
      background-color: rgba(96,165,250,0.1);
    }
    
    html:not(.theme-light):not([data-theme='light']) .section-filter-select:focus {
      border-color: #60a5fa;
      box-shadow: 0 0 0 3px rgba(96,165,250,0.15);
    }
    
    .section-filter-select option {
      background: #fff;
      color: #1b222b;
    }
    
    html:not(.theme-light):not([data-theme='light']) .section-filter-select option {
      background: #1b222b;
      color: #fff;
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
    
    /* Focus Mode */
    .focus-overlay {
      display: none;
      position: fixed;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      background: rgba(0,0,0,0.6);
      backdrop-filter: blur(4px);
      z-index: 9998;
      opacity: 0;
      transition: opacity 0.3s ease;
    }
    .focus-overlay.active {
      display: block;
      opacity: 1;
    }
    
    .chart-panel.focused {
      position: fixed !important;
      top: 50% !important;
      left: 50% !important;
      transform: translate(-50%, -50%) !important;
      width: 85vw !important;
      max-width: 1200px !important;
      height: 80vh !important;
      max-height: 800px !important;
      z-index: 9999 !important;
      border-radius: 16px !important;
      box-shadow: 0 25px 80px rgba(0,0,0,0.4) !important;
      background: #fff !important;
      padding: 24px !important;
    }
    
    html:not(.theme-light):not([data-theme='light']) .chart-panel.focused {
      background: #1e2330 !important;
    }
    
    .chart-panel.focused .panel-header h2 {
      font-size: 28px !important;
    }
    .chart-panel.focused .panel-subtitle {
      font-size: 16px !important;
    }
    .chart-panel.focused .chart-toggle button {
      font-size: 13px !important;
      padding: 8px 16px !important;
    }
    .chart-panel.focused .chart-container,
    .chart-panel.focused .both-view-container,
    .chart-panel.focused .gauge-view-container,
    .chart-panel.focused .table-view-container {
      flex: 1;
      min-height: 0;
    }
    
    /* Focused gauge styles - larger gauges with more separation */
    .chart-panel.focused .both-view-container {
      flex-direction: column !important;
      gap: 24px !important;
    }
    .chart-panel.focused .gauge-container {
      flex: 0 0 auto !important;
      padding: 20px 0 !important;
    }
    .chart-panel.focused .gauge-wrapper {
      width: 420px !important;
      height: 210px !important;
    }
    .chart-panel.focused .gauge-wrapper-large {
      width: 500px !important;
      height: 250px !important;
    }
    .chart-panel.focused .gauge-value {
      font-size: 52px !important;
    }
    .chart-panel.focused .gauge-value-large {
      font-size: 64px !important;
    }
    .chart-panel.focused .gauge-label {
      font-size: 16px !important;
    }
    .chart-panel.focused .gauge-goal {
      font-size: 14px !important;
    }
    
    /* Focused table styles - significantly larger */
    .chart-panel.focused .line-table-container {
      flex: 1 !important;
      overflow: auto !important;
    }
    .chart-panel.focused .line-table {
      font-size: 15px !important;
    }
    .chart-panel.focused .line-table th {
      font-size: 14px !important;
      padding: 14px 18px !important;
    }
    .chart-panel.focused .line-table td {
      font-size: 15px !important;
      padding: 12px 18px !important;
    }
    .chart-panel.focused .data-table-view table {
      font-size: 14px !important;
    }
    .chart-panel.focused .data-table-view th {
      font-size: 13px !important;
      padding: 12px 16px !important;
    }
    .chart-panel.focused .data-table-view td {
      font-size: 14px !important;
      padding: 10px 16px !important;
    }
    
    /* Focused NCM styles */
    .chart-panel.focused .ncm-table-view {
      max-height: calc(100% - 100px) !important;
      overflow-y: auto !important;
    }
    .chart-panel.focused .ncm-table {
      font-size: 14px !important;
    }
    .chart-panel.focused .ncm-table th {
      font-size: 13px !important;
      padding: 12px 16px !important;
    }
    .chart-panel.focused .ncm-table td {
      font-size: 14px !important;
      padding: 10px 16px !important;
    }
    .chart-panel.focused .ncm-bullet-value {
      font-size: 36px !important;
    }
    .chart-panel.focused .ncm-bullet-label {
      font-size: 14px !important;
    }
    .chart-panel.focused .ncm-bar-chart-container {
      flex: 1 !important;
      min-height: 350px !important;
      max-height: none !important;
    }
    
    /* Focused Scrap styles */
    .chart-panel.focused .scrap-total-value {
      font-size: 48px !important;
    }
    .chart-panel.focused .scrap-total-label {
      font-size: 14px !important;
    }
    }
    
    .focus-btn {
      display: flex;
      align-items: center;
      justify-content: center;
      width: 24px;
      height: 24px;
      border: none;
      outline: none;
      background: transparent;
      border-radius: 4px;
      cursor: pointer;
      color: rgba(0,0,0,0.35);
      transition: all 0.15s;
      flex-shrink: 0;
      padding: 0;
    }
    .focus-btn:focus {
      outline: none;
      box-shadow: none;
    }
    .focus-btn svg {
      width: 14px;
      height: 14px;
    }
    .focus-btn:hover {
      background: rgba(0,0,0,0.05);
      color: rgba(0,0,0,0.6);
    }
    html:not(.theme-light):not([data-theme='light']) .focus-btn {
      color: rgba(255,255,255,0.35);
    }
    html:not(.theme-light):not([data-theme='light']) .focus-btn:hover {
      background: rgba(255,255,255,0.06);
      color: rgba(255,255,255,0.7);
    }
    .focus-btn.close-focus {
      display: none;
    }
    .chart-panel.focused .focus-btn.open-focus {
      display: none;
    }
    .chart-panel.focused .focus-btn.close-focus {
      display: flex;
    }
    
    .hf-container { display: none; }
  </style>
</asp:Content>

<asp:Content ID="PQDashBody" ContentPlaceHolderID="MainContent" runat="server">
<!-- Focus Mode Overlay -->
<div class="focus-overlay" id="focusOverlay" onclick="closeFocusMode()"></div>

<div class="quality-dashboard">
  <!-- Report Header - EATON badge first, title, spacer, filter + settings icons on right -->
  <div class="report-header">
    <div class="eaton-badge">EATON YPO</div>
    <h1 class="report-title">Plant Quality Dashboard</h1>
    <div class="header-spacer"></div>
    <div class="refresh-container" style="display:flex;align-items:center;gap:6px;">
      <span class="refresh-countdown" id="refreshCountdown" title="Auto-refresh countdown">30:00</span>
      <button type="button" class="header-refresh-btn" id="headerRefreshBtn" onclick="refreshAllData()" title="Refresh Data">
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <polyline points="23 4 23 10 17 10"></polyline>
          <polyline points="1 20 1 14 7 14"></polyline>
          <path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15"></path>
        </svg>
      </button>
    </div>
    <button type="button" class="header-filter-btn" id="headerFilterBtn" onclick="toggleFilterPopup()" title="Filters">
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
        <polygon points="22 3 2 3 10 12.46 10 19 14 21 14 12.46 22 3"></polygon>
      </svg>
    </button>
    <button type="button" class="header-fontsize-btn" id="headerFontSizeBtn" onclick="cycleFontSize()" title="Font Size (for TIER meetings)">
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
        <polyline points="4 7 4 4 20 4 20 7"></polyline>
        <line x1="9" y1="20" x2="15" y2="20"></line>
        <line x1="12" y1="4" x2="12" y2="20"></line>
      </svg>
      <span class="fontsize-label" id="fontSizeLabel">S</span>
    </button>
    <a href="PlantQualitySettings.aspx" class="header-settings-btn" title="Dashboard Settings">
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
        <circle cx="12" cy="12" r="3"></circle>
        <path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"></path>
      </svg>
    </a>
  </div>

  <!-- Filter Popup Overlay -->
  <div class="filter-popup-overlay" id="filterPopupOverlay" onclick="closeFilterPopup()"></div>
  
  <!-- Filter Popup Menu -->
  <div class="filter-popup" id="filterPopup" style="display:none;">
    <div class="filter-popup-header">
      <span class="filter-popup-title">Filters</span>
      <button type="button" class="filter-popup-close" onclick="closeFilterPopup()">
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M18 6L6 18M6 6l12 12"></path>
        </svg>
      </button>
    </div>
    
    <!-- Yield Filters Section -->
    <div class="filter-popup-section">
      <div class="filter-section-title yield-title">YIELD FILTERS</div>
      
      <div class="filter-pill-group">
        <div class="filter-pill-label">Production Line</div>
        <div class="filter-pills" id="yieldLinePills">
          <button type="button" class="filter-pill yield-pill selected" data-value="ALL" onclick="selectYieldLinePill(this)">Plantwide</button>
        </div>
      </div>
      
      <div class="filter-pill-group">
        <div class="filter-pill-label">Date Range</div>
        <div class="filter-pills" id="yieldPeriodPills">
          <button type="button" class="filter-pill yield-pill" data-value="YTD" onclick="selectYieldPeriodPill(this)">YTD</button>
          <button type="button" class="filter-pill yield-pill selected" data-value="MTD" onclick="selectYieldPeriodPill(this)">MTD</button>
          <button type="button" class="filter-pill yield-pill" data-value="WEEK" onclick="selectYieldPeriodPill(this)">Week</button>
          <button type="button" class="filter-pill yield-pill" data-value="TODAY" onclick="selectYieldPeriodPill(this)">Today</button>
          <button type="button" class="filter-pill yield-pill" data-value="YESTERDAY" onclick="selectYieldPeriodPill(this)">Yesterday</button>
          <button type="button" class="filter-pill yield-pill" data-value="LASTMONTH" onclick="selectYieldPeriodPill(this)">Last Month</button>
          <button type="button" class="filter-pill yield-pill" data-value="LASTYEAR" onclick="selectYieldPeriodPill(this)">Last Year</button>
          <button type="button" class="filter-pill yield-pill" data-value="PICKMONTH" onclick="selectYieldPeriodPill(this)">Pick a Month</button>
        </div>
        <div class="filter-pill-date-row" id="yieldCustomDates">
          <input type="month" class="filter-pill-month" id="yieldPickMonth" max="">
        </div>
      </div>
    </div>
    
    <!-- Scrap Filters Section -->
    <div class="filter-popup-section">
      <div class="filter-section-title scrap-title">SCRAP FILTERS</div>
      
      <div class="filter-pill-group">
        <div class="filter-pill-label">Scrap Ledger</div>
        <div class="filter-pills" id="scrapLedgerPills">
          <button type="button" class="filter-pill scrap-pill selected" data-value="ALL" onclick="selectScrapLedgerPill(this)">All Ledgers</button>
          <button type="button" class="filter-pill scrap-pill" data-value="SPD" onclick="selectScrapLedgerPill(this)">SPD</button>
          <button type="button" class="filter-pill scrap-pill" data-value="D-IT" onclick="selectScrapLedgerPill(this)">D-IT</button>
          <button type="button" class="filter-pill scrap-pill" data-value="Energy Transition" onclick="selectScrapLedgerPill(this)">Energy Transition</button>
        </div>
      </div>
      
      <div class="filter-pill-group">
        <div class="filter-pill-label">Production Line</div>
        <div class="filter-pills" id="scrapLinePills">
          <button type="button" class="filter-pill scrap-pill selected" data-value="ALL" onclick="selectScrapLinePill(this)">Plantwide</button>
        </div>
      </div>
      
      <div class="filter-pill-group">
        <div class="filter-pill-label">Date Range</div>
        <div class="filter-pills" id="scrapPeriodPills">
          <button type="button" class="filter-pill scrap-pill" data-value="YTD" onclick="selectScrapPeriodPill(this)">YTD</button>
          <button type="button" class="filter-pill scrap-pill selected" data-value="MTD" onclick="selectScrapPeriodPill(this)">MTD</button>
          <button type="button" class="filter-pill scrap-pill" data-value="WEEK" onclick="selectScrapPeriodPill(this)">Week</button>
          <button type="button" class="filter-pill scrap-pill" data-value="TODAY" onclick="selectScrapPeriodPill(this)">Today</button>
          <button type="button" class="filter-pill scrap-pill" data-value="YESTERDAY" onclick="selectScrapPeriodPill(this)">Yesterday</button>
          <button type="button" class="filter-pill scrap-pill" data-value="LASTMONTH" onclick="selectScrapPeriodPill(this)">Last Month</button>
          <button type="button" class="filter-pill scrap-pill" data-value="LASTYEAR" onclick="selectScrapPeriodPill(this)">Last Year</button>
          <button type="button" class="filter-pill scrap-pill" data-value="PICKMONTH" onclick="selectScrapPeriodPill(this)">Pick a Month</button>
        </div>
        <div class="filter-pill-date-row" id="scrapCustomDates">
          <input type="month" class="filter-pill-month" id="scrapPickMonth" max="">
        </div>
      </div>
    </div>
    
    <!-- Footer with Apply/Reset buttons -->
    <div class="filter-popup-footer">
      <button type="button" class="filter-btn-reset" onclick="resetFilters()">Reset</button>
      <button type="button" class="filter-btn-apply" onclick="applyFilters()">Apply Filters</button>
    </div>
  </div>

  <!-- Hidden ASP.NET controls for postback -->
  <div style="display:none;">
    <asp:DropDownList ID="ddlPlant" runat="server">
      <asp:ListItem Text="YPO" Value="YPO" Selected="True" />
      <asp:ListItem Text="CPO" Value="CPO" />
    </asp:DropDownList>
    <asp:DropDownList ID="ddlYieldLine" runat="server">
      <asp:ListItem Text="All Lines" Value="ALL" />
    </asp:DropDownList>
    <asp:DropDownList ID="ddlScrapLine" runat="server">
      <asp:ListItem Text="All Lines" Value="ALL" />
    </asp:DropDownList>
    <asp:DropDownList ID="ddlLedger" runat="server">
      <asp:ListItem Text="All Ledgers" Value="ALL" Selected="True" />
      <asp:ListItem Text="SPD" Value="SPD" />
      <asp:ListItem Text="D-IT" Value="D-IT" />
      <asp:ListItem Text="Energy Transition" Value="Energy Transition" />
    </asp:DropDownList>
    <asp:TextBox ID="txtYieldStartDate" runat="server" TextMode="Date" />
    <asp:TextBox ID="txtYieldEndDate" runat="server" TextMode="Date" />
    <asp:TextBox ID="txtScrapStartDate" runat="server" TextMode="Date" />
    <asp:TextBox ID="txtScrapEndDate" runat="server" TextMode="Date" />
    <asp:Button ID="btnRefreshYield" runat="server" Text="Apply" OnClick="btnRefreshYield_Click" />
    <asp:Button ID="btnRefreshScrap" runat="server" Text="Apply" OnClick="btnRefreshScrap_Click" />
    <asp:Button ID="btnRefreshAll" runat="server" Text="Apply All" OnClick="btnRefreshAll_Click" />
  </div>

  <!-- Yield Metrics Section -->
  <div class="metrics-section" id="yieldMetricsSection">
    <!-- Yield Filter Status Bar -->
    <div class="filter-status-bar" id="yieldFilterStatusBar">
      <div class="filter-status-box" id="yieldLineStatus">
        <span class="status-label">Line:</span>
        <span class="status-value" id="yieldLineStatusValue">Plantwide</span>
      </div>
      <div class="filter-status-box" id="yieldPeriodStatus">
        <span class="status-label">Period:</span>
        <span class="status-value" id="yieldPeriodStatusValue">MTD (Month to Date)</span>
      </div>
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
        <div style="display:flex;align-items:center;gap:8px;">
          <div class="chart-toggle" id="gaugeToggle">
            <button type="button" onclick="setGaugeViewType('gauge')">Gauge</button>
            <button type="button" onclick="setGaugeViewType('table')">Table</button>
            <button type="button" class="active" onclick="setGaugeViewType('both')">Both</button>
          </div>
          <button type="button" class="focus-btn open-focus" onclick="openFocusMode('yieldGaugePanel')" title="Focus">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M15 3h6v6M9 21H3v-6M21 3l-7 7M3 21l7-7"/></svg>
          </button>
          <button type="button" class="focus-btn close-focus" onclick="closeFocusMode()" title="Close">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M18 6L6 18M6 6l12 12"/></svg>
          </button>
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
    <div class="chart-panel" id="yieldDailyPanel">
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
        <div style="display:flex;align-items:center;gap:8px;">
          <div class="chart-toggle" id="yieldToggle">
            <button type="button" onclick="setYieldChartType('bar')">Column</button>
            <button type="button" class="active" onclick="setYieldChartType('line')">Line</button>
            <button type="button" onclick="setYieldChartType('table')">Table</button>
          </div>
          <button type="button" class="focus-btn open-focus" onclick="openFocusMode('yieldDailyPanel')" title="Focus">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M15 3h6v6M9 21H3v-6M21 3l-7 7M3 21l7-7"/></svg>
          </button>
          <button type="button" class="focus-btn close-focus" onclick="closeFocusMode()" title="Close">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M18 6L6 18M6 6l12 12"/></svg>
          </button>
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
    <div class="chart-panel" id="failuresPanel">
      <div class="panel-header">
        <div>
          <h2>Failures by Category</h2>
          <p class="panel-subtitle" id="failuresSubtitle">Plantwide | Month to date</p>
        </div>
        <div style="display:flex;align-items:center;gap:8px;">
          <div class="chart-toggle" id="failureToggle">
            <button type="button" onclick="setFailureChartType('radar')">Radar</button>
            <button type="button" onclick="setFailureChartType('bar')">Column</button>
            <button type="button" class="active" onclick="setFailureChartType('table')">Table</button>
          </div>
          <button type="button" class="focus-btn open-focus" onclick="openFocusMode('failuresPanel')" title="Focus">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M15 3h6v6M9 21H3v-6M21 3l-7 7M3 21l7-7"/></svg>
          </button>
          <button type="button" class="focus-btn close-focus" onclick="closeFocusMode()" title="Close">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M18 6L6 18M6 6l12 12"/></svg>
          </button>
        </div>
      </div>
      <div class="chart-container" id="failureChartContainer">
        <canvas id="failureCategoryChart" style="display:none;"></canvas>
        <div class="data-table-view" id="failureTableView" style="display:block;"></div>
      </div>
    </div>
  </div>
  </div>

  <!-- Scrap Metrics Section -->
  <div class="metrics-section" id="scrapMetricsSection">
    <!-- Scrap Filter Status Bar -->
    <div class="filter-status-bar" id="scrapFilterStatusBar">
      <div class="filter-status-box" id="scrapLineStatus">
        <span class="status-label">Line:</span>
        <span class="status-value" id="scrapLineStatusValue">Plantwide</span>
      </div>
      <div class="filter-status-box" id="scrapLedgerStatus">
        <span class="status-label">Ledger:</span>
        <span class="status-value" id="scrapLedgerStatusValue">All</span>
      </div>
      <div class="filter-status-box" id="scrapPeriodStatus">
        <span class="status-label">Period:</span>
        <span class="status-value" id="scrapPeriodStatusValue">MTD (Month to Date)</span>
      </div>
    </div>

  <div class="charts-row">
    <!-- Scrap Gauge (Hybrid) -->
    <div class="chart-panel" id="scrapGaugePanel">
      <div class="panel-header scrap-header">
        <div>
          <h2>Scrap Cost</h2>
          <p class="panel-subtitle" id="scrapSubtitle">Plantwide | Month to date</p>
        </div>
        <div style="display:flex;align-items:center;gap:8px;">
          <div class="chart-toggle" id="scrapGaugeToggle">
            <button type="button" class="active" onclick="setScrapGaugeViewType('byLine')">By Line</button>
            <button type="button" onclick="setScrapGaugeViewType('topItems')">Top Items</button>
          </div>
          <button type="button" class="focus-btn open-focus" onclick="openFocusMode('scrapGaugePanel')" title="Focus">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M15 3h6v6M9 21H3v-6M21 3l-7 7M3 21l7-7"/></svg>
          </button>
          <button type="button" class="focus-btn close-focus" onclick="closeFocusMode()" title="Close">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M18 6L6 18M6 6l12 12"/></svg>
          </button>
        </div>
      </div>
      <!-- By Line view (default - gauge + table) -->
      <div class="both-view-container" id="scrapByLineView">
        <div class="gauge-container compact">
          <div class="gauge-wrapper">
            <svg class="gauge-svg" id="scrapGaugeSvgSmall" viewBox="0 0 220 110"></svg>
            <div class="gauge-center">
              <div class="gauge-value scrap-value" id="scrapGaugeValueDisplaySmall">--</div>
              <div class="gauge-label">vs Goal</div>
            </div>
          </div>
        </div>
        <div class="line-table-container" id="scrapLineTableContainerSmall">
          <table class="line-table" id="scrapLineTableSmall">
            <thead>
              <tr>
                <th>Line</th>
                <th>Goal</th>
                <th>Actual</th>
                <th>Var</th>
              </tr>
            </thead>
            <tbody id="scrapLineTableBodySmall">
            </tbody>
            <tfoot id="scrapLineTableFootSmall">
            </tfoot>
          </table>
        </div>
      </div>
      <!-- Top Items view (gauge + bar chart) -->
      <div class="both-view-container" id="scrapTopItemsView" style="display:none;">
        <div class="gauge-container compact">
          <div class="gauge-wrapper">
            <svg class="gauge-svg" id="scrapGaugeSvgTopItems" viewBox="0 0 220 110"></svg>
            <div class="gauge-center">
              <div class="gauge-value scrap-value" id="scrapGaugeValueDisplayTopItems">--</div>
              <div class="gauge-label">vs Goal</div>
            </div>
          </div>
        </div>
        <div class="top-items-chart-container">
          <canvas id="topScrapChart"></canvas>
        </div>
      </div>
    </div>

    <!-- Scrap Cumulative Chart -->
    <div class="chart-panel" id="scrapDailyPanel">
      <div class="panel-header scrap-header">
        <div style="display:flex;align-items:center;gap:10px;">
          <button type="button" class="drill-btn" id="scrapDrillDownBtn" onclick="scrapDrillDown()" title="Drill Down" style="display:none;">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M6 9l6 6 6-6"/>
            </svg>
          </button>
          <div>
            <h2 id="scrapChartTitle">Scrap Daily</h2>
            <p class="panel-subtitle" id="scrapDailySubtitle">Plantwide | Month to date</p>
          </div>
          <button type="button" class="drill-btn" id="scrapDrillUpBtn" onclick="scrapDrillUp()" title="Drill Up" style="display:none;">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M18 15l-6-6-6 6"/>
            </svg>
          </button>
        </div>
        <div style="display:flex;align-items:center;gap:8px;">
          <div class="chart-toggle" id="scrapChartToggle">
            <button type="button" class="active" onclick="setScrapChartType('cumulative')">Cumulative</button>
            <button type="button" onclick="setScrapChartType('table')">Table</button>
          </div>
          <button type="button" class="focus-btn open-focus" onclick="openFocusMode('scrapDailyPanel')" title="Focus">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M15 3h6v6M9 21H3v-6M21 3l-7 7M3 21l7-7"/></svg>
          </button>
          <button type="button" class="focus-btn close-focus" onclick="closeFocusMode()" title="Close">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M18 6L6 18M6 6l12 12"/></svg>
          </button>
        </div>
      </div>
      <div class="chart-container" id="scrapChartContainer">
        <div class="chart-scroll-wrapper" id="scrapScrollWrapper">
          <div class="chart-scroll-inner" id="scrapScrollInner">
            <canvas id="scrapDailyChart"></canvas>
          </div>
        </div>
        <div class="data-table-view" id="scrapTableView" style="display:none;"></div>
      </div>
    </div>

    <!-- NCM Analysis Panel -->
    <div class="chart-panel" id="ncmPanel">
      <div class="panel-header ncm-header">
        <div>
          <h2>NCM Analysis</h2>
          <p class="panel-subtitle" id="ncmSubtitle">Data as of today</p>
        </div>
        <div style="display:flex;align-items:center;gap:8px;">
          <div class="chart-toggle" id="ncmToggle">
            <button type="button" onclick="setNCMChartType('gauge')">Gauge</button>
            <button type="button" class="active" onclick="setNCMChartType('table')">Table</button>
          </div>
          <button type="button" class="focus-btn open-focus" onclick="openFocusMode('ncmPanel')" title="Focus">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M15 3h6v6M9 21H3v-6M21 3l-7 7M3 21l7-7"/></svg>
          </button>
          <button type="button" class="focus-btn close-focus" onclick="closeFocusMode()" title="Close">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M18 6L6 18M6 6l12 12"/></svg>
          </button>
        </div>
      </div>
      <div class="chart-container" id="ncmChartContainer">
        <!-- Gauge + Bar Chart View (like Scrap Cost Top Items) -->
        <div class="both-view-container" id="ncmGaugeView" style="display:none;">
          <div class="gauge-container compact">
            <div class="gauge-wrapper">
              <svg class="gauge-svg" id="ncmGaugeSvg" viewBox="0 0 220 110"></svg>
              <div class="gauge-center">
                <div class="gauge-value ncm-value" id="ncmGaugeValueDisplay">$0</div>
                <div class="gauge-label">vs Goal</div>
              </div>
            </div>
          </div>
          <div class="ncm-bar-chart-container">
            <canvas id="ncmBarChart"></canvas>
          </div>
        </div>
        <!-- Table View -->
        <div class="ncm-table-view" id="ncmTableView" style="display:block;">
          <!-- Bullet Chart Summary -->
          <div class="ncm-bullet-summary">
            <div class="ncm-bullet-header">
              <span class="ncm-bullet-value" id="ncmBulletValue">$0</span>
              <span class="ncm-bullet-label">Total NCM Value</span>
            </div>
            <div class="ncm-bullet-chart">
              <div class="ncm-bullet-track">
                <div class="ncm-bullet-bar" id="ncmBulletBar"></div>
                <div class="ncm-bullet-goal" id="ncmBulletGoal"></div>
              </div>
              <div class="ncm-bullet-scale">
                <span>$0</span>
                <span id="ncmBulletGoalLabel">Goal: $0</span>
              </div>
            </div>
          </div>
          <table class="ncm-table">
            <thead>
              <tr>
                <th>Material Number</th>
                <th>Description</th>
                <th>Total Value</th>
                <th>% of Total</th>
              </tr>
            </thead>
            <tbody id="ncmTableBody">
            </tbody>
          </table>
        </div>
      </div>
    </div>
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
  <asp:HiddenField ID="hfMonthlyGoals" runat="server" Value="{}" />
  <asp:HiddenField ID="hfLineMonthlyGoals" runat="server" Value="{}" />
  <asp:HiddenField ID="hfYieldDailyLabels" runat="server" Value="[]" />
  <asp:HiddenField ID="hfYieldDailySortDates" runat="server" Value="[]" />
  <asp:HiddenField ID="hfYieldDailyData" runat="server" Value="[]" />
  <asp:HiddenField ID="hfYieldDailyCumulative" runat="server" Value="[]" />
  <asp:HiddenField ID="hfYieldDailyTested" runat="server" Value="[]" />
  <asp:HiddenField ID="hfYieldDailyPassed" runat="server" Value="[]" />
  <asp:HiddenField ID="hfYieldDailyFailed" runat="server" Value="[]" />
  <asp:HiddenField ID="hfYieldByLineData" runat="server" Value="[]" />
  <asp:HiddenField ID="hfYieldByLineDateData" runat="server" Value="[]" />
  <asp:HiddenField ID="hfFailureCategoryLabels" runat="server" Value="[]" />
  <asp:HiddenField ID="hfFailureCategoryData" runat="server" Value="[]" />
  <asp:HiddenField ID="hfFailureCategoryDetails" runat="server" Value="[]" />
  <asp:HiddenField ID="hfCurrentLine" runat="server" Value="ALL" />
  <asp:HiddenField ID="hfCurrentDatePreset" runat="server" Value="MTD" />
  <!-- Scrap hidden fields -->
  <asp:HiddenField ID="hfScrapTotal" runat="server" Value="0" />
  <asp:HiddenField ID="hfScrapGoal" runat="server" Value="0" />
  <asp:HiddenField ID="hfScrapPeriodType" runat="server" Value="MTD" />
  <asp:HiddenField ID="hfScrapMonthlyGoals" runat="server" Value="{}" />
  <asp:HiddenField ID="hfScrapLineMonthlyGoals" runat="server" Value="{}" />
  <asp:HiddenField ID="hfScrapByLineData" runat="server" Value="[]" />
  <asp:HiddenField ID="hfScrapByLineDateData" runat="server" Value="[]" />
  <asp:HiddenField ID="hfScrapDailyLabels" runat="server" Value="[]" />
  <asp:HiddenField ID="hfScrapDailySortDates" runat="server" Value="[]" />
  <asp:HiddenField ID="hfScrapDailyData" runat="server" Value="[]" />
  <asp:HiddenField ID="hfScrapDailyCumulative" runat="server" Value="[]" />
  <asp:HiddenField ID="hfScrapDailyGoals" runat="server" Value="[]" />
  <asp:HiddenField ID="hfTopScrapItems" runat="server" Value="[]" />
  <asp:HiddenField ID="hfCurrentLedger" runat="server" Value="ALL" />
  <!-- NCM hidden fields -->
  <asp:HiddenField ID="hfNCMTotalValue" runat="server" Value="0" />
  <asp:HiddenField ID="hfNCMGoal" runat="server" Value="75000" />
  <asp:HiddenField ID="hfNCMDataDate" runat="server" Value="" />
  <asp:HiddenField ID="hfNCMTopMaterials" runat="server" Value="[]" />
  <asp:HiddenField ID="hfNCMAllMaterials" runat="server" Value="[]" />
</div>

<!-- Custom tooltip for table cells -->
<div class="cell-tooltip" id="cellTooltip">
  <div class="cell-tooltip-content">
    <div class="cell-tooltip-title" id="cellTooltipTitle"></div>
    <div class="cell-tooltip-row">
      <span class="cell-tooltip-label">Passed</span>
      <span class="cell-tooltip-value passed" id="cellTooltipPassed"></span>
    </div>
    <div class="cell-tooltip-row">
      <span class="cell-tooltip-label">Failed</span>
      <span class="cell-tooltip-value failed" id="cellTooltipFailed"></span>
    </div>
    <div class="cell-tooltip-row">
      <span class="cell-tooltip-label">Total</span>
      <span class="cell-tooltip-value" id="cellTooltipTotal"></span>
    </div>
    <div class="cell-tooltip-row cell-tooltip-yield">
      <span class="cell-tooltip-label">Yield</span>
      <span class="cell-tooltip-value" id="cellTooltipYield"></span>
    </div>
  </div>
</div>

<!-- Custom tooltip for chart (Column/Line mode) -->
<div class="chart-tooltip" id="chartTooltip">
  <div class="chart-tooltip-content">
    <div class="chart-tooltip-title" id="chartTooltipTitle"></div>
    <div class="chart-tooltip-row">
      <span class="chart-tooltip-label">Passed</span>
      <span class="chart-tooltip-value passed" id="chartTooltipPassed"></span>
    </div>
    <div class="chart-tooltip-row">
      <span class="chart-tooltip-label">Failed</span>
      <span class="chart-tooltip-value failed" id="chartTooltipFailed"></span>
    </div>
    <div class="chart-tooltip-row">
      <span class="chart-tooltip-label">Total</span>
      <span class="chart-tooltip-value" id="chartTooltipTotal"></span>
    </div>
    <div class="chart-tooltip-row chart-tooltip-divider">
      <span class="chart-tooltip-label" id="chartTooltipYieldLabel">Yield</span>
      <span class="chart-tooltip-value yield-value" id="chartTooltipYield"></span>
    </div>
    <div class="chart-tooltip-row" id="chartTooltipCumulative">
      <span class="chart-tooltip-label">Cumulative</span>
      <span class="chart-tooltip-value cumulative-value" id="chartTooltipCumulativeValue"></span>
    </div>
    <div class="chart-tooltip-row">
      <span class="chart-tooltip-label">Goal</span>
      <span class="chart-tooltip-value goal-value" id="chartTooltipGoal"></span>
    </div>
  </div>
</div>

<!-- Custom tooltip for failures by category -->
<div class="failure-tooltip" id="failureTooltip">
  <div class="failure-tooltip-content">
    <div class="failure-tooltip-header" id="failureTooltipHeader"></div>
    <div class="failure-tooltip-body" id="failureTooltipBody"></div>
  </div>
</div>

<!-- Custom tooltip for scrap charts -->
<div class="chart-tooltip" id="scrapTooltip">
  <div class="chart-tooltip-content">
    <div class="chart-tooltip-title" id="scrapTooltipTitle"></div>
    <div class="chart-tooltip-row">
      <span class="chart-tooltip-label">Scrap</span>
      <span class="chart-tooltip-value" id="scrapTooltipValue"></span>
    </div>
    <div class="chart-tooltip-row chart-tooltip-divider">
      <span class="chart-tooltip-label">Cumulative</span>
      <span class="chart-tooltip-value" id="scrapTooltipCumulative"></span>
    </div>
    <div class="chart-tooltip-row">
      <span class="chart-tooltip-label">Cum. Goal</span>
      <span class="chart-tooltip-value goal-value" id="scrapTooltipCumulativeGoal"></span>
    </div>
    <div class="chart-tooltip-row">
      <span class="chart-tooltip-label">Cum. Var</span>
      <span class="chart-tooltip-value" id="scrapTooltipCumulativeVar"></span>
    </div>
    <div class="chart-tooltip-row">
      <span class="chart-tooltip-label">Month Goal</span>
      <span class="chart-tooltip-value goal-value" id="scrapTooltipMonthGoal"></span>
    </div>
    <div class="chart-tooltip-row">
      <span class="chart-tooltip-label">Month Var.</span>
      <span class="chart-tooltip-value" id="scrapTooltipMonthVar"></span>
    </div>
  </div>
</div>

<!-- Custom tooltip for scrap table -->
<div class="chart-tooltip" id="scrapTableTooltip">
  <div class="chart-tooltip-content">
    <div class="chart-tooltip-title" id="scrapTableTooltipTitle"></div>
    <div class="chart-tooltip-row">
      <span class="chart-tooltip-label">Scrap</span>
      <span class="chart-tooltip-value scrap-orange" id="scrapTableTooltipValue"></span>
    </div>
    <div class="chart-tooltip-row chart-tooltip-divider">
      <span class="chart-tooltip-label">Cumulative</span>
      <span class="chart-tooltip-value" id="scrapTableTooltipCumulative"></span>
    </div>
    <div class="chart-tooltip-row">
      <span class="chart-tooltip-label">Cum. Goal</span>
      <span class="chart-tooltip-value goal-value" id="scrapTableTooltipCumulativeGoal"></span>
    </div>
    <div class="chart-tooltip-row">
      <span class="chart-tooltip-label">Cum. Var</span>
      <span class="chart-tooltip-value" id="scrapTableTooltipCumulativeVar"></span>
    </div>
    <div class="chart-tooltip-row">
      <span class="chart-tooltip-label">Month Goal</span>
      <span class="chart-tooltip-value goal-value" id="scrapTableTooltipMonthGoal"></span>
    </div>
    <div class="chart-tooltip-row">
      <span class="chart-tooltip-label">Month Var.</span>
      <span class="chart-tooltip-value" id="scrapTableTooltipMonthVar"></span>
    </div>
  </div>
</div>

<script>
  // ========== SEPARATE FILTER STATE FOR YIELD AND SCRAP ==========
  var yieldLineSelection = 'ALL';
  var yieldPeriodSelection = 'MTD';
  var scrapLedgerSelection = 'ALL';
  var scrapLineSelection = 'ALL';
  var scrapPeriodSelection = 'MTD';
  
  // Temporary selections for popup (not applied until user clicks Apply)
  var tempYieldLine = 'ALL';
  var tempYieldPeriod = 'MTD';
  var tempScrapLedger = 'ALL';
  var tempScrapLine = 'ALL';
  var tempScrapPeriod = 'MTD';
  
  // Initialize line pills from server data
  function initFilterPills() {
    var yieldServerDropdown = document.getElementById('<%= ddlYieldLine.ClientID %>');
    var scrapServerDropdown = document.getElementById('<%= ddlScrapLine.ClientID %>');
    var yieldLinePills = document.getElementById('yieldLinePills');
    var scrapLinePills = document.getElementById('scrapLinePills');
    
    // Populate yield line pills from yield server dropdown
    if (yieldServerDropdown && yieldLinePills) {
      for (var i = 0; i < yieldServerDropdown.options.length; i++) {
        var opt = yieldServerDropdown.options[i];
        if (opt.value !== 'ALL') {
          var pill = document.createElement('button');
          pill.type = 'button';
          pill.className = 'filter-pill yield-pill';
          pill.dataset.value = opt.value;
          pill.textContent = opt.text;
          pill.onclick = function() { selectYieldLinePill(this); };
          yieldLinePills.appendChild(pill);
        }
      }
    }
    
    // Populate scrap line pills from scrap server dropdown
    if (scrapServerDropdown && scrapLinePills) {
      for (var i = 0; i < scrapServerDropdown.options.length; i++) {
        var opt = scrapServerDropdown.options[i];
        if (opt.value !== 'ALL') {
          var pill = document.createElement('button');
          pill.type = 'button';
          pill.className = 'filter-pill scrap-pill';
          pill.dataset.value = opt.value;
          pill.textContent = opt.text;
          pill.onclick = function() { selectScrapLinePill(this); };
          scrapLinePills.appendChild(pill);
        }
      }
    }
    
    // Restore saved state from localStorage
    var needsDataRefresh = restoreFilterState();
    
    // If filters were saved, trigger a data refresh to load matching data
    // But only if we haven't just done a refresh (to prevent infinite loop)
    var justRefreshed = sessionStorage.getItem('pqd_justRefreshed');
    if (needsDataRefresh && !justRefreshed) {
      // Set flag before refresh
      sessionStorage.setItem('pqd_justRefreshed', 'true');
      // Small delay to ensure DOM is fully ready
      setTimeout(function() {
        triggerSavedFilterRefresh();
      }, 100);
    } else if (justRefreshed) {
      // Clear the flag after we've loaded with correct data
      sessionStorage.removeItem('pqd_justRefreshed');
    }
  }
  
  function triggerSavedFilterRefresh() {
    // Set the form values based on saved filter state
    var yieldDateRange;
    if (yieldPeriodSelection === 'PICKMONTH') {
      var monthVal = document.getElementById('yieldPickMonth').value;
      if (monthVal) {
        var parts = monthVal.split('-');
        var year = parseInt(parts[0], 10);
        var month = parseInt(parts[1], 10) - 1;
        var start = new Date(year, month, 1);
        var end = new Date(year, month + 1, 0);
        yieldDateRange = { start: start, end: end };
      } else {
        yieldDateRange = getDateRangeFromPreset('MTD');
      }
    } else {
      yieldDateRange = getDateRangeFromPreset(yieldPeriodSelection);
    }
    document.getElementById('<%= txtYieldStartDate.ClientID %>').value = formatDateForInput(yieldDateRange.start);
    document.getElementById('<%= txtYieldEndDate.ClientID %>').value = formatDateForInput(yieldDateRange.end);
    document.getElementById('<%= ddlYieldLine.ClientID %>').value = yieldLineSelection;
    
    var scrapDateRange;
    if (scrapPeriodSelection === 'PICKMONTH') {
      var monthVal = document.getElementById('scrapPickMonth').value;
      if (monthVal) {
        var parts = monthVal.split('-');
        var year = parseInt(parts[0], 10);
        var month = parseInt(parts[1], 10) - 1;
        var start = new Date(year, month, 1);
        var end = new Date(year, month + 1, 0);
        scrapDateRange = { start: start, end: end };
      } else {
        scrapDateRange = getDateRangeFromPreset('MTD');
      }
    } else {
      scrapDateRange = getDateRangeFromPreset(scrapPeriodSelection);
    }
    document.getElementById('<%= txtScrapStartDate.ClientID %>').value = formatDateForInput(scrapDateRange.start);
    document.getElementById('<%= txtScrapEndDate.ClientID %>').value = formatDateForInput(scrapDateRange.end);
    document.getElementById('<%= ddlScrapLine.ClientID %>').value = scrapLineSelection;
    document.getElementById('<%= ddlLedger.ClientID %>').value = scrapLedgerSelection;
    document.getElementById('<%= hfScrapPeriodType.ClientID %>').value = scrapPeriodSelection;
    
    // Trigger combined refresh
    document.getElementById('<%= btnRefreshAll.ClientID %>').click();
  }
  
  function restoreFilterState() {
    // Yield filters
    var savedYieldLine = localStorage.getItem('pqd_yieldLine');
    var savedYieldPeriod = localStorage.getItem('pqd_yieldPeriod');
    if (savedYieldLine) {
      yieldLineSelection = savedYieldLine;
      tempYieldLine = savedYieldLine;
    }
    if (savedYieldPeriod) {
      yieldPeriodSelection = savedYieldPeriod;
      tempYieldPeriod = savedYieldPeriod;
    }
    
    // Scrap filters
    var savedScrapLedger = localStorage.getItem('pqd_scrapLedger');
    var savedScrapLine = localStorage.getItem('pqd_scrapLine');
    var savedScrapPeriod = localStorage.getItem('pqd_scrapPeriod');
    if (savedScrapLedger) {
      scrapLedgerSelection = savedScrapLedger;
      tempScrapLedger = savedScrapLedger;
    }
    if (savedScrapLine) {
      scrapLineSelection = savedScrapLine;
      tempScrapLine = savedScrapLine;
    }
    if (savedScrapPeriod) {
      scrapPeriodSelection = savedScrapPeriod;
      tempScrapPeriod = savedScrapPeriod;
    }
    
    // Restore custom dates if applicable
    if (yieldPeriodSelection === 'CUSTOM') {
      var savedStart = localStorage.getItem('pqd_yieldCustomStart');
      var savedEnd = localStorage.getItem('pqd_yieldCustomEnd');
      if (savedStart) document.getElementById('yieldCustomStartDate').value = savedStart;
      if (savedEnd) document.getElementById('yieldCustomEndDate').value = savedEnd;
    }
    if (scrapPeriodSelection === 'CUSTOM') {
      var savedStart = localStorage.getItem('pqd_scrapCustomStart');
      var savedEnd = localStorage.getItem('pqd_scrapCustomEnd');
      if (savedStart) document.getElementById('scrapCustomStartDate').value = savedStart;
      if (savedEnd) document.getElementById('scrapCustomEndDate').value = savedEnd;
    }
    
    // Restore month picker values if PICKMONTH was selected
    if (yieldPeriodSelection === 'PICKMONTH') {
      var savedYieldMonth = localStorage.getItem('pqd_yieldPickMonth');
      if (savedYieldMonth) {
        document.getElementById('yieldPickMonth').value = savedYieldMonth;
      }
    }
    if (scrapPeriodSelection === 'PICKMONTH') {
      var savedScrapMonth = localStorage.getItem('pqd_scrapPickMonth');
      if (savedScrapMonth) {
        document.getElementById('scrapPickMonth').value = savedScrapMonth;
      }
    }
    
    // Update status bars and button state
    updateFilterStatusBars();
    updateFilterButtonState();
    
    // Return true if any filters are non-default (need to trigger data refresh)
    return (yieldLineSelection !== 'ALL' || yieldPeriodSelection !== 'MTD' ||
            scrapLedgerSelection !== 'ALL' || scrapLineSelection !== 'ALL' || scrapPeriodSelection !== 'MTD');
  }
  
  // Pill Selection Functions (temporary until Apply is clicked)
  function selectYieldLinePill(pill) {
    var pills = document.querySelectorAll('#yieldLinePills .filter-pill');
    pills.forEach(function(p) { p.classList.remove('selected'); });
    pill.classList.add('selected');
    tempYieldLine = pill.dataset.value;
  }
  
  function selectYieldPeriodPill(pill) {
    var pills = document.querySelectorAll('#yieldPeriodPills .filter-pill');
    pills.forEach(function(p) { p.classList.remove('selected'); });
    pill.classList.add('selected');
    tempYieldPeriod = pill.dataset.value;
    
    // Show/hide month picker
    var customDates = document.getElementById('yieldCustomDates');
    if (tempYieldPeriod === 'PICKMONTH') {
      customDates.classList.add('visible');
      // Set max to current month and default if empty
      var today = new Date();
      var maxMonth = today.getFullYear() + '-' + String(today.getMonth() + 1).padStart(2, '0');
      var monthPicker = document.getElementById('yieldPickMonth');
      monthPicker.max = maxMonth;
      if (!monthPicker.value) {
        monthPicker.value = maxMonth;
      }
    } else {
      customDates.classList.remove('visible');
    }
  }
  
  function selectScrapLedgerPill(pill) {
    var pills = document.querySelectorAll('#scrapLedgerPills .filter-pill');
    pills.forEach(function(p) { p.classList.remove('selected'); });
    pill.classList.add('selected');
    tempScrapLedger = pill.dataset.value;
  }
  
  function selectScrapLinePill(pill) {
    var pills = document.querySelectorAll('#scrapLinePills .filter-pill');
    pills.forEach(function(p) { p.classList.remove('selected'); });
    pill.classList.add('selected');
    tempScrapLine = pill.dataset.value;
  }
  
  function selectScrapPeriodPill(pill) {
    var pills = document.querySelectorAll('#scrapPeriodPills .filter-pill');
    pills.forEach(function(p) { p.classList.remove('selected'); });
    pill.classList.add('selected');
    tempScrapPeriod = pill.dataset.value;
    
    // Show/hide month picker
    var customDates = document.getElementById('scrapCustomDates');
    if (tempScrapPeriod === 'PICKMONTH') {
      customDates.classList.add('visible');
      // Set max to current month and default if empty
      var today = new Date();
      var maxMonth = today.getFullYear() + '-' + String(today.getMonth() + 1).padStart(2, '0');
      var monthPicker = document.getElementById('scrapPickMonth');
      monthPicker.max = maxMonth;
      if (!monthPicker.value) {
        monthPicker.value = maxMonth;
      }
    } else {
      customDates.classList.remove('visible');
    }
  }
  
  // Apply Filters button
  function applyFilters() {
    var yieldChanged = false;
    var scrapChanged = false;
    
    // Check if yield filters changed
    if (tempYieldLine !== yieldLineSelection || tempYieldPeriod !== yieldPeriodSelection) {
      yieldChanged = true;
      yieldLineSelection = tempYieldLine;
      yieldPeriodSelection = tempYieldPeriod;
      localStorage.setItem('pqd_yieldLine', yieldLineSelection);
      localStorage.setItem('pqd_yieldPeriod', yieldPeriodSelection);
      if (yieldPeriodSelection === 'PICKMONTH') {
        localStorage.setItem('pqd_yieldPickMonth', document.getElementById('yieldPickMonth').value);
      }
    }
    
    // Check if scrap filters changed  
    if (tempScrapLedger !== scrapLedgerSelection || tempScrapLine !== scrapLineSelection || tempScrapPeriod !== scrapPeriodSelection) {
      scrapChanged = true;
      scrapLedgerSelection = tempScrapLedger;
      scrapLineSelection = tempScrapLine;
      scrapPeriodSelection = tempScrapPeriod;
      localStorage.setItem('pqd_scrapLedger', scrapLedgerSelection);
      localStorage.setItem('pqd_scrapLine', scrapLineSelection);
      localStorage.setItem('pqd_scrapPeriod', scrapPeriodSelection);
      if (scrapPeriodSelection === 'PICKMONTH') {
        localStorage.setItem('pqd_scrapPickMonth', document.getElementById('scrapPickMonth').value);
      }
    }
    
    closeFilterPopup();
    updateFilterStatusBars();
    updateFilterButtonState();
    
    // Trigger appropriate postbacks
    // Use a single combined postback when both changed to avoid race conditions
    if (yieldChanged && scrapChanged) {
      applyAllFilters();
    } else if (yieldChanged) {
      applyYieldFilters();
    } else if (scrapChanged) {
      applyScrapFilters();
    }
  }
  
  function applyAllFilters() {
    // Set yield filter values
    var yieldDateRange;
    if (yieldPeriodSelection === 'PICKMONTH') {
      var monthVal = document.getElementById('yieldPickMonth').value;
      var parts = monthVal.split('-');
      var year = parseInt(parts[0], 10);
      var month = parseInt(parts[1], 10) - 1;
      var start = new Date(year, month, 1);
      var end = new Date(year, month + 1, 0);
      yieldDateRange = { start: start, end: end };
    } else {
      yieldDateRange = getDateRangeFromPreset(yieldPeriodSelection);
    }
    document.getElementById('<%= txtYieldStartDate.ClientID %>').value = formatDateForInput(yieldDateRange.start);
    document.getElementById('<%= txtYieldEndDate.ClientID %>').value = formatDateForInput(yieldDateRange.end);
    document.getElementById('<%= ddlYieldLine.ClientID %>').value = yieldLineSelection;
    
    // Set scrap filter values
    var scrapDateRange;
    if (scrapPeriodSelection === 'PICKMONTH') {
      var monthVal = document.getElementById('scrapPickMonth').value;
      var parts = monthVal.split('-');
      var year = parseInt(parts[0], 10);
      var month = parseInt(parts[1], 10) - 1;
      var start = new Date(year, month, 1);
      var end = new Date(year, month + 1, 0);
      scrapDateRange = { start: start, end: end };
    } else {
      scrapDateRange = getDateRangeFromPreset(scrapPeriodSelection);
    }
    document.getElementById('<%= txtScrapStartDate.ClientID %>').value = formatDateForInput(scrapDateRange.start);
    document.getElementById('<%= txtScrapEndDate.ClientID %>').value = formatDateForInput(scrapDateRange.end);
    document.getElementById('<%= ddlScrapLine.ClientID %>').value = scrapLineSelection;
    document.getElementById('<%= ddlLedger.ClientID %>').value = scrapLedgerSelection;
    document.getElementById('<%= hfScrapPeriodType.ClientID %>').value = scrapPeriodSelection;
    
    // Update subtitles
    updateYieldSubtitles();
    updateScrapSubtitles();
    
    // Single postback for both
    document.getElementById('<%= btnRefreshAll.ClientID %>').click();
  }
  
  function applyYieldFilters() {
    var dateRange;
    if (yieldPeriodSelection === 'PICKMONTH') {
      var monthVal = document.getElementById('yieldPickMonth').value; // format: yyyy-MM
      var parts = monthVal.split('-');
      var year = parseInt(parts[0], 10);
      var month = parseInt(parts[1], 10) - 1; // JS months are 0-indexed
      var start = new Date(year, month, 1);
      var end = new Date(year, month + 1, 0); // Last day of month
      dateRange = { start: start, end: end };
    } else {
      dateRange = getDateRangeFromPreset(yieldPeriodSelection);
    }
    document.getElementById('<%= txtYieldStartDate.ClientID %>').value = formatDateForInput(dateRange.start);
    document.getElementById('<%= txtYieldEndDate.ClientID %>').value = formatDateForInput(dateRange.end);
    document.getElementById('<%= ddlYieldLine.ClientID %>').value = yieldLineSelection;
    
    updateYieldSubtitles();
    document.getElementById('<%= btnRefreshYield.ClientID %>').click();
  }
  
  function applyScrapFilters() {
    var dateRange;
    if (scrapPeriodSelection === 'PICKMONTH') {
      var monthVal = document.getElementById('scrapPickMonth').value; // format: yyyy-MM
      var parts = monthVal.split('-');
      var year = parseInt(parts[0], 10);
      var month = parseInt(parts[1], 10) - 1; // JS months are 0-indexed
      var start = new Date(year, month, 1);
      var end = new Date(year, month + 1, 0); // Last day of month
      dateRange = { start: start, end: end };
    } else {
      dateRange = getDateRangeFromPreset(scrapPeriodSelection);
    }
    document.getElementById('<%= txtScrapStartDate.ClientID %>').value = formatDateForInput(dateRange.start);
    document.getElementById('<%= txtScrapEndDate.ClientID %>').value = formatDateForInput(dateRange.end);
    document.getElementById('<%= ddlScrapLine.ClientID %>').value = scrapLineSelection;
    document.getElementById('<%= ddlLedger.ClientID %>').value = scrapLedgerSelection;
    document.getElementById('<%= hfScrapPeriodType.ClientID %>').value = scrapPeriodSelection;
    
    updateScrapSubtitles();
    document.getElementById('<%= btnRefreshScrap.ClientID %>').click();
  }
  
  // Reset Filters button
  function resetFilters() {
    // Reset to defaults
    tempYieldLine = 'ALL';
    tempYieldPeriod = 'MTD';
    tempScrapLedger = 'ALL';
    tempScrapLine = 'ALL';
    tempScrapPeriod = 'MTD';
    
    // Update pill selections
    syncPillsToTemp();
    
    // Hide custom date pickers
    document.getElementById('yieldCustomDates').classList.remove('visible');
    document.getElementById('scrapCustomDates').classList.remove('visible');
  }
  
  // Sync pill selections to temp state (used when opening popup or resetting)
  function syncPillsToTemp() {
    // Yield line pills
    document.querySelectorAll('#yieldLinePills .filter-pill').forEach(function(p) {
      p.classList.toggle('selected', p.dataset.value === tempYieldLine);
    });
    // Yield period pills
    document.querySelectorAll('#yieldPeriodPills .filter-pill').forEach(function(p) {
      p.classList.toggle('selected', p.dataset.value === tempYieldPeriod);
    });
    // Scrap ledger pills
    document.querySelectorAll('#scrapLedgerPills .filter-pill').forEach(function(p) {
      p.classList.toggle('selected', p.dataset.value === tempScrapLedger);
    });
    // Scrap line pills
    document.querySelectorAll('#scrapLinePills .filter-pill').forEach(function(p) {
      p.classList.toggle('selected', p.dataset.value === tempScrapLine);
    });
    // Scrap period pills
    document.querySelectorAll('#scrapPeriodPills .filter-pill').forEach(function(p) {
      p.classList.toggle('selected', p.dataset.value === tempScrapPeriod);
    });
    
    // Show/hide custom date pickers (for CUSTOM or PICKMONTH)
    document.getElementById('yieldCustomDates').classList.toggle('visible', tempYieldPeriod === 'CUSTOM' || tempYieldPeriod === 'PICKMONTH');
    document.getElementById('scrapCustomDates').classList.toggle('visible', tempScrapPeriod === 'CUSTOM' || tempScrapPeriod === 'PICKMONTH');
    
    // Restore month picker values from localStorage if PICKMONTH
    if (tempYieldPeriod === 'PICKMONTH') {
      var savedYieldMonth = localStorage.getItem('pqd_yieldPickMonth');
      if (savedYieldMonth) {
        document.getElementById('yieldPickMonth').value = savedYieldMonth;
      }
      // Set max to current month
      var today = new Date();
      var maxMonth = today.getFullYear() + '-' + String(today.getMonth() + 1).padStart(2, '0');
      document.getElementById('yieldPickMonth').max = maxMonth;
    }
    if (tempScrapPeriod === 'PICKMONTH') {
      var savedScrapMonth = localStorage.getItem('pqd_scrapPickMonth');
      if (savedScrapMonth) {
        document.getElementById('scrapPickMonth').value = savedScrapMonth;
      }
      // Set max to current month
      var today = new Date();
      var maxMonth = today.getFullYear() + '-' + String(today.getMonth() + 1).padStart(2, '0');
      document.getElementById('scrapPickMonth').max = maxMonth;
    }
  }
  
  // Refresh All Data function
  function refreshAllData() {
    var btn = document.getElementById('headerRefreshBtn');
    btn.classList.add('refreshing');
    
    // Reset auto-refresh timer on manual refresh
    if (typeof autoRefreshRemaining !== 'undefined') {
      autoRefreshRemaining = autoRefreshInterval;
      updateCountdownDisplay();
    }
    
    // Trigger the hidden refresh button after a small delay to show animation
    setTimeout(function() {
      document.getElementById('<%= btnRefreshAll.ClientID %>').click();
    }, 100);
  }
  
  // Filter Popup Functions
  function toggleFilterPopup() {
    var popup = document.getElementById('filterPopup');
    var overlay = document.getElementById('filterPopupOverlay');
    var btn = document.getElementById('headerFilterBtn');
    
    if (popup.style.display === 'none' || popup.style.display === '') {
      // Sync temp to current applied values when opening
      tempYieldLine = yieldLineSelection;
      tempYieldPeriod = yieldPeriodSelection;
      tempScrapLedger = scrapLedgerSelection;
      tempScrapLine = scrapLineSelection;
      tempScrapPeriod = scrapPeriodSelection;
      syncPillsToTemp();
      
      popup.style.display = 'block';
      overlay.classList.add('visible');
      btn.classList.add('active');
    } else {
      closeFilterPopup();
    }
  }
  
  function closeFilterPopup() {
    var popup = document.getElementById('filterPopup');
    var overlay = document.getElementById('filterPopupOverlay');
    var btn = document.getElementById('headerFilterBtn');
    
    popup.style.display = 'none';
    overlay.classList.remove('visible');
    btn.classList.remove('active');
  }
  
  function updateFilterButtonState() {
    var btn = document.getElementById('headerFilterBtn');
    var hasNonDefaults = false;
    
    if (yieldLineSelection !== 'ALL') hasNonDefaults = true;
    if (yieldPeriodSelection !== 'MTD') hasNonDefaults = true;
    if (scrapLedgerSelection !== 'ALL') hasNonDefaults = true;
    if (scrapLineSelection !== 'ALL') hasNonDefaults = true;
    if (scrapPeriodSelection !== 'MTD') hasNonDefaults = true;
    
    btn.classList.toggle('has-filters', hasNonDefaults);
  }
  
  // Update filter status bars with applied filters
  function updateFilterStatusBars() {
    // Yield status
    var yieldLineBox = document.getElementById('yieldLineStatus');
    var yieldPeriodBox = document.getElementById('yieldPeriodStatus');
    
    document.getElementById('yieldLineStatusValue').textContent = yieldLineSelection === 'ALL' ? 'Plantwide' : yieldLineSelection;
    document.getElementById('yieldPeriodStatusValue').textContent = getPeriodDisplayText(yieldPeriodSelection, true);
    
    yieldLineBox.classList.toggle('active-filter', yieldLineSelection !== 'ALL');
    yieldPeriodBox.classList.toggle('active-filter', yieldPeriodSelection !== 'MTD');
    
    // Scrap status
    var scrapLineBox = document.getElementById('scrapLineStatus');
    var scrapLedgerBox = document.getElementById('scrapLedgerStatus');
    var scrapPeriodBox = document.getElementById('scrapPeriodStatus');
    
    document.getElementById('scrapLineStatusValue').textContent = scrapLineSelection === 'ALL' ? 'Plantwide' : scrapLineSelection;
    document.getElementById('scrapLedgerStatusValue').textContent = scrapLedgerSelection === 'ALL' ? 'All' : scrapLedgerSelection;
    document.getElementById('scrapPeriodStatusValue').textContent = getPeriodDisplayText(scrapPeriodSelection, false);
    
    scrapLineBox.classList.toggle('active-filter', scrapLineSelection !== 'ALL');
    scrapLedgerBox.classList.toggle('active-filter', scrapLedgerSelection !== 'ALL');
    scrapPeriodBox.classList.toggle('active-filter', scrapPeriodSelection !== 'MTD');
  }
  
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
      case 'LASTMONTH':
        start = new Date(today.getFullYear(), today.getMonth() - 1, 1);
        end = new Date(today.getFullYear(), today.getMonth(), 0);
        break;
      case 'LASTYEAR':
        start = new Date(today.getFullYear() - 1, 0, 1);
        end = new Date(today.getFullYear() - 1, 11, 31);
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
  
  function parseDateStringLocal(dateStr) {
    if (!dateStr) return new Date();
    var parts = dateStr.split('-');
    if (parts.length !== 3) return new Date();
    return new Date(parseInt(parts[0]), parseInt(parts[1]) - 1, parseInt(parts[2]));
  }
  
  function getYieldSubtitleText() {
    var lineText = yieldLineSelection === 'ALL' ? 'Plantwide' : yieldLineSelection;
    var periodText = getPeriodDisplayText(yieldPeriodSelection, true);
    return lineText + '  |  ' + periodText;
  }
  
  function getScrapSubtitleText() {
    var ledgerText = scrapLedgerSelection === 'ALL' ? 'All Ledgers' : scrapLedgerSelection;
    var lineText = scrapLineSelection === 'ALL' ? 'Plantwide' : scrapLineSelection;
    var periodText = getPeriodDisplayText(scrapPeriodSelection, false);
    return ledgerText + '  |  ' + lineText + '  |  ' + periodText;
  }
  
  function getPeriodDisplayText(preset, isYield) {
    var today = new Date();
    var monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    var fullMonthNames = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    
    function formatShortDate(date) {
      return monthNames[date.getMonth()] + ' ' + date.getDate() + ', ' + date.getFullYear();
    }
    
    function formatDateRange(start, end) {
      if (start.getFullYear() === end.getFullYear() && start.getMonth() === end.getMonth() && start.getDate() === end.getDate()) {
        // Same day
        return formatShortDate(start);
      } else if (start.getFullYear() === end.getFullYear()) {
        // Same year
        return monthNames[start.getMonth()] + ' ' + start.getDate() + ' - ' + monthNames[end.getMonth()] + ' ' + end.getDate() + ', ' + end.getFullYear();
      } else {
        // Different years
        return formatShortDate(start) + ' - ' + formatShortDate(end);
      }
    }
    
    switch (preset) {
      case 'YTD':
        var ytdStart = new Date(today.getFullYear(), 0, 1);
        return 'YTD (' + formatDateRange(ytdStart, today) + ')';
      case 'MTD':
        var mtdStart = new Date(today.getFullYear(), today.getMonth(), 1);
        return 'MTD (' + formatDateRange(mtdStart, today) + ')';
      case 'WEEK':
        var weekStart = new Date(today);
        weekStart.setDate(today.getDate() - 6);
        return 'Last 7 Days (' + formatDateRange(weekStart, today) + ')';
      case 'YESTERDAY':
        var yesterday = new Date(today);
        yesterday.setDate(today.getDate() - 1);
        return 'Yesterday (' + formatShortDate(yesterday) + ')';
      case 'TODAY':
        return 'Today (' + formatShortDate(today) + ')';
      case 'LASTMONTH':
        var lastMonthStart = new Date(today.getFullYear(), today.getMonth() - 1, 1);
        var lastMonthEnd = new Date(today.getFullYear(), today.getMonth(), 0);
        return fullMonthNames[lastMonthStart.getMonth()] + ' ' + lastMonthStart.getFullYear();
      case 'LASTYEAR':
        var lastYear = today.getFullYear() - 1;
        return 'Last Year (' + lastYear + ')';
      case 'PICKMONTH':
        var monthVal;
        if (isYield) {
          monthVal = document.getElementById('yieldPickMonth').value;
        } else {
          monthVal = document.getElementById('scrapPickMonth').value;
        }
        if (monthVal) {
          var parts = monthVal.split('-');
          return fullMonthNames[parseInt(parts[1], 10) - 1] + ' ' + parts[0];
        }
        return 'Selected Month';
      default:
        var defStart = new Date(today.getFullYear(), today.getMonth(), 1);
        return 'MTD (' + formatDateRange(defStart, today) + ')';
    }
  }
  
  function updateYieldSubtitles() {
    var text = getYieldSubtitleText();
    var subtitles = ['yieldSubtitle', 'yieldDailySubtitle', 'failuresSubtitle'];
    subtitles.forEach(function(id) {
      var el = document.getElementById(id);
      if (el) el.textContent = text;
    });
  }
  
  function updateScrapSubtitles() {
    var text = getScrapSubtitleText();
    var subtitles = ['scrapSubtitle', 'scrapDailySubtitle', 'ncmSubtitle'];
    subtitles.forEach(function(id) {
      var el = document.getElementById(id);
      if (el) el.textContent = text;
    });
  }
  
  // Legacy compatibility - formatDateForDisplay
  function formatDateForDisplay(dateStr) {
    // Convert yyyy-mm-dd to M/d/yyyy (Month/Day/Year)
    if (!dateStr) return '';
    var parts = dateStr.split('-');
    if (parts.length !== 3) return dateStr;
    return parseInt(parts[1]) + '/' + parseInt(parts[2]) + '/' + parts[0];
  }
  
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
  
  // Helper to check if a panel is currently focused
  function isPanelFocused(panelId) {
    var panel = document.getElementById(panelId);
    return panel && panel.classList.contains('focused');
  }
  
  // Font Scale System
  var fontScaleLevels = ['small', 'medium', 'large', 'xl'];
  var fontScaleLabels = { small: 'S', medium: 'M', large: 'L', xl: 'XL' };
  var fontScaleMultipliers = { small: 1, medium: 1.25, large: 1.5, xl: 1.85 };
  var currentFontScale = 'small';
  
  function initFontScale() {
    var saved = localStorage.getItem('pqd_fontScale');
    if (saved && fontScaleLevels.indexOf(saved) !== -1) {
      currentFontScale = saved;
    }
    applyFontScale();
  }
  
  function cycleFontSize() {
    var idx = fontScaleLevels.indexOf(currentFontScale);
    idx = (idx + 1) % fontScaleLevels.length;
    currentFontScale = fontScaleLevels[idx];
    localStorage.setItem('pqd_fontScale', currentFontScale);
    applyFontScale();
    // Reload charts to apply new font sizes
    reloadAllCharts();
  }
  
  function applyFontScale() {
    // Remove all font scale classes
    fontScaleLevels.forEach(function(level) {
      document.documentElement.classList.remove('font-scale-' + level);
    });
    // Add current font scale class
    document.documentElement.classList.add('font-scale-' + currentFontScale);
    // Update button label
    var label = document.getElementById('fontSizeLabel');
    if (label) {
      label.textContent = fontScaleLabels[currentFontScale];
    }
  }
  
  function getFontScaleMultiplier() {
    return fontScaleMultipliers[currentFontScale] || 1;
  }
  
  // Get chart font sizes based on focus state AND font scale - larger fonts when focused or scaled
  function getChartFontSizes(panelId) {
    var focused = isPanelFocused(panelId);
    var scale = getFontScaleMultiplier();
    
    // Base sizes
    var base = {
      title: 10,
      label: 10,
      tick: 9,
      dataLabel: 11,
      legend: 10,
      tooltip: 12,
      pointLabel: 10
    };
    
    // Focused sizes (larger)
    var focusedSizes = {
      title: 16,
      label: 14,
      tick: 13,
      dataLabel: 14,
      legend: 14,
      tooltip: 14,
      pointLabel: 14
    };
    
    var sizes = focused ? focusedSizes : base;
    
    // Apply font scale multiplier
    return {
      title: Math.round(sizes.title * scale),
      label: Math.round(sizes.label * scale),
      tick: Math.round(sizes.tick * scale),
      dataLabel: Math.round(sizes.dataLabel * scale),
      legend: Math.round(sizes.legend * scale),
      tooltip: Math.round(sizes.tooltip * scale),
      pointLabel: Math.round(sizes.pointLabel * scale)
    };
  }
  
  // Global chart instances
  var yieldDailyChart = null;
  var failureCategoryChart = null;
  var scrapDailyChart = null;
  var topScrapChart = null;
  var currentYieldType = 'line';
  var currentFailureType = 'table';
  var currentScrapType = 'cumulative';
  var currentScrapGaugeView = 'byLine';
  var currentDrillLevel = 'daily'; // daily, weekly, monthly, quarterly, yearly
  var currentScrapDrillLevel = 'daily';
  
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
    
    // Reload Failures based on current view
    if (currentFailureType === 'table') {
      renderFailureTableView();
    } else {
      initFailureCategoryChart();
    }
    
    // Reload Scrap charts
    if (currentScrapGaugeView === 'byLine') {
      initScrapGaugeSmall();
      initScrapLineTableSmall();
    } else {
      initScrapGaugeTopItems();
      initTopScrapChart();
    }
    initScrapDailyChart();
    
    // Reload NCM charts
    initNCMCharts();
  }
  
  document.addEventListener('DOMContentLoaded', function() {
    // Initialize font scale setting
    initFontScale();
    
    // Initialize filter pills with server data
    initFilterPills();
    
    // Update subtitles based on current filter state
    updateYieldSubtitles();
    updateScrapSubtitles();
    
    // Default is Both view for First Pass Yield
    initGaugeSmall();
    initLineTableSmall();
    initYieldDailyChart();
    
    // Initialize Failures (default: Table view)
    if (currentFailureType === 'table') {
      renderFailureTableView();
    } else {
      initFailureCategoryChart();
    }
    
    // Initialize Scrap charts (default: By Line view)
    initScrapGaugeSmall();
    initScrapLineTableSmall();
    initScrapDailyChart();
    
    // Initialize NCM charts
    initNCMCharts();
    
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
    
    // Close filter popup when pressing Escape
    document.addEventListener('keydown', function(e) {
      if (e.key === 'Escape') {
        closeFilterPopup();
      }
    });
    
    // Start auto-refresh countdown timer (30 minutes)
    startAutoRefreshTimer();
  });
  
  // ========== AUTO-REFRESH TIMER ==========
  var autoRefreshInterval = 15 * 60; // 15 minutes in seconds
  var autoRefreshRemaining = autoRefreshInterval;
  var autoRefreshTimerId = null;
  
  function startAutoRefreshTimer() {
    autoRefreshRemaining = autoRefreshInterval;
    updateCountdownDisplay();
    
    if (autoRefreshTimerId) {
      clearInterval(autoRefreshTimerId);
    }
    
    autoRefreshTimerId = setInterval(function() {
      autoRefreshRemaining--;
      
      if (autoRefreshRemaining <= 0) {
        // Time to refresh
        refreshAllData();
        autoRefreshRemaining = autoRefreshInterval;
      }
      
      updateCountdownDisplay();
    }, 1000);
  }
  
  function updateCountdownDisplay() {
    var countdown = document.getElementById('refreshCountdown');
    if (!countdown) return;
    
    var minutes = Math.floor(autoRefreshRemaining / 60);
    var seconds = autoRefreshRemaining % 60;
    countdown.textContent = minutes.toString().padStart(2, '0') + ':' + seconds.toString().padStart(2, '0');
  }
  
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
    
    // Goal label - positioned outside the gauge arc with better alignment
    var labelOffset = 40; // Distance from center
    var labelX = cx + labelOffset * Math.cos(goalAngle);
    var labelY = cy + labelOffset * Math.sin(goalAngle);
    
    // Adjust text anchor based on position
    var textAnchor = 'middle';
    if (goalAngle < Math.PI * 1.2) {
      textAnchor = 'end';
      labelX -= 8;
    } else if (goalAngle > Math.PI * 1.8) {
      textAnchor = 'start';
      labelX += 8;
    }
    
    var goalLabel = document.createElementNS('http://www.w3.org/2000/svg', 'text');
    goalLabel.setAttribute('x', labelX);
    goalLabel.setAttribute('y', labelY);
    goalLabel.setAttribute('fill', goalLineColor);
    goalLabel.setAttribute('font-size', '10');
    goalLabel.setAttribute('font-weight', '600');
    goalLabel.setAttribute('text-anchor', textAnchor);
    goalLabel.setAttribute('dominant-baseline', 'middle');
    goalLabel.textContent = goal.toFixed(1) + '%';
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
  
  function renderYieldChart(labels, data, cumulativeData, testedArr, passedArr, failedArr, sortKeys) {
    var goal = parseFloat(document.getElementById('<%= hfYieldGoal.ClientID %>').value) || 98;
    var monthlyGoals = JSON.parse(document.getElementById('<%= hfMonthlyGoals.ClientID %>').value || '{}');
    var colors = getColors();
    var modernFont = "'Segoe UI', 'Inter', -apple-system, sans-serif";
    var dark = isDarkMode();
    
    // Get dynamic font sizes based on focus state
    var fontSizes = getChartFontSizes('yieldDailyPanel');
    
    // Build goal array based on sortKeys (which are yyyy-MM for monthly, yyyy-Wnn for weekly, etc.)
    var goalsArray = [];
    for (var i = 0; i < labels.length; i++) {
      var sortKey = sortKeys[i] || '';
      var goalForPeriod = goal; // Default
      
      if (sortKey.indexOf('-') > 0) {
        var yearPart = sortKey.substring(0, 4);
        
        if (sortKey.indexOf('W') > 0) {
          // Weekly: yyyy-Wnn - use goal from the month this week falls in
          // For simplicity, use the goal from that year-month (approximate to middle of week)
          var weekNum = parseInt(sortKey.substring(6));
          var approxMonth = Math.ceil(weekNum / 4.33); // Approximate month
          var monthKey = yearPart + '-' + (approxMonth < 10 ? '0' + approxMonth : approxMonth);
          goalForPeriod = monthlyGoals[monthKey] || goal;
        } else if (sortKey.indexOf('Q') > 0) {
          // Quarterly: yyyy-Qn - use highest goal from the 3 months in that quarter
          var quarter = parseInt(sortKey.substring(6));
          var startMonth = (quarter - 1) * 3 + 1;
          var maxGoalInQuarter = goal;
          for (var m = 0; m < 3; m++) {
            var monthNum = startMonth + m;
            var monthKey = yearPart + '-' + (monthNum < 10 ? '0' + monthNum : monthNum);
            var monthGoal = monthlyGoals[monthKey] || goal;
            if (monthGoal > maxGoalInQuarter) maxGoalInQuarter = monthGoal;
          }
          goalForPeriod = maxGoalInQuarter;
        } else if (sortKey.length === 7) {
          // Monthly: yyyy-MM - use goal for that month
          goalForPeriod = monthlyGoals[sortKey] || goal;
        }
      } else if (sortKey.length === 4) {
        // Yearly: yyyy - use highest goal from all 12 months
        var maxGoalInYear = goal;
        for (var m = 1; m <= 12; m++) {
          var monthKey = sortKey + '-' + (m < 10 ? '0' + m : m);
          var monthGoal = monthlyGoals[monthKey] || goal;
          if (monthGoal > maxGoalInYear) maxGoalInYear = monthGoal;
        }
        goalForPeriod = maxGoalInYear;
      }
      
      goalsArray.push(goalForPeriod);
    }
    
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
      backgroundColor: data.map(function(v, idx) { return v >= goalsArray[idx] ? 'rgba(16,185,129,0.15)' : 'rgba(239,68,68,0.15)'; }),
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
        backgroundColor: currentYieldType === 'line' ? mainLineBgColor : data.map(function(v, idx) { return v >= goalsArray[idx] ? 'rgba(16,185,129,0.85)' : 'rgba(239,68,68,0.85)'; }),
        borderColor: currentYieldType === 'line' ? mainLineColor : data.map(function(v, idx) { return v >= goalsArray[idx] ? '#10b981' : '#ef4444'; }),
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
        data: goalsArray,
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
            ticks: { color: colors.textSec, font: { size: fontSizes.tick, family: modernFont } }
          }
        },
        plugins: {
          legend: { display: false },
          tooltip: {
            enabled: false,
            external: function(context) {
              var tooltip = document.getElementById('chartTooltip');
              if (!tooltip) return;
              
              var tooltipModel = context.tooltip;
              
              // Hide if no tooltip
              if (tooltipModel.opacity === 0) {
                tooltip.classList.remove('visible');
                return;
              }
              
              // Get data point info
              if (tooltipModel.dataPoints && tooltipModel.dataPoints.length > 0) {
                var dataPoint = tooltipModel.dataPoints[0];
                var idx = dataPoint.dataIndex;
                var label = dataPoint.label;
                var levelLabel = currentDrillLevel.charAt(0).toUpperCase() + currentDrillLevel.slice(1);
                
                // Get current line selection for title
                var lineText = 'Plantwide';
                if (yieldLineSelection && yieldLineSelection !== 'ALL') {
                  lineText = yieldLineSelection;
                }
                
                document.getElementById('chartTooltipTitle').textContent = lineText + ' - ' + label;
                document.getElementById('chartTooltipPassed').textContent = passedArr[idx].toLocaleString() + ' units';
                document.getElementById('chartTooltipFailed').textContent = failedArr[idx].toLocaleString() + ' units';
                document.getElementById('chartTooltipTotal').textContent = testedArr[idx].toLocaleString() + ' units';
                document.getElementById('chartTooltipYieldLabel').textContent = levelLabel + ' Yield';
                document.getElementById('chartTooltipYield').textContent = data[idx].toFixed(2) + '%';
                
                // Show cumulative if available
                var cumEl = document.getElementById('chartTooltipCumulative');
                if (cumulativeData && cumulativeData[idx] !== undefined) {
                  cumEl.style.display = 'flex';
                  document.getElementById('chartTooltipCumulativeValue').textContent = cumulativeData[idx].toFixed(2) + '%';
                } else {
                  cumEl.style.display = 'none';
                }
                
                // Show goal for this specific month
                var monthGoal = goalsArray[idx] || goal;
                document.getElementById('chartTooltipGoal').textContent = monthGoal.toFixed(2) + '%';
              }
              
              tooltip.classList.add('visible');
              
              // Position tooltip
              var position = context.chart.canvas.getBoundingClientRect();
              var x = position.left + window.scrollX + tooltipModel.caretX + 12;
              var y = position.top + window.scrollY + tooltipModel.caretY + 12;
              
              // Adjust if goes off screen
              var rect = tooltip.querySelector('.chart-tooltip-content').getBoundingClientRect();
              if (x + rect.width > window.innerWidth - 10) {
                x = position.left + window.scrollX + tooltipModel.caretX - rect.width - 12;
              }
              if (y + rect.height > window.innerHeight - 10) {
                y = position.top + window.scrollY + tooltipModel.caretY - rect.height - 12;
              }
              
              tooltip.style.left = x + 'px';
              tooltip.style.top = y + 'px';
            }
          },
          datalabels: {
            display: function(ctx) { return ctx.datasetIndex === 0; },
            anchor: 'end',
            align: 'top',
            color: colors.text,
            font: { size: fontSizes.dataLabel, weight: '600', family: modernFont },
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
    var monthlyGoals = JSON.parse(document.getElementById('<%= hfMonthlyGoals.ClientID %>').value || '{}');
    var lineMonthlyGoals = JSON.parse(document.getElementById('<%= hfLineMonthlyGoals.ClientID %>').value || '{}');
    var selectedLine = document.getElementById('<%= ddlYieldLine.ClientID %>').value;
    
    var tableView = document.getElementById('yieldTableView');
    
    if (!lineDateData.length && !lineData.length) {
      tableView.innerHTML = '<div style="display:flex;align-items:center;justify-content:center;height:100%;color:rgba(0,0,0,0.4);font-size:11px;font-style:italic;">No data available</div>';
      return;
    }
    
    // Helper function to get goal for a specific line and month
    // When viewing Plantwide, use line-specific goals; otherwise use monthlyGoals
    function getGoalForLineMonth(lineName, monthKey) {
      if (selectedLine === 'ALL' && lineMonthlyGoals[lineName] && lineMonthlyGoals[lineName][monthKey]) {
        return lineMonthlyGoals[lineName][monthKey];
      }
      return monthlyGoals[monthKey] || goal;
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
      var lineGoalSum = 0, lineGoalCount = 0; // Track line-specific goals for total column
      html += '<tr><td>' + lineName + '</td>';
      
      dateCols.forEach(function(col) {
        var cellData = dateMap[col][lineName];
        if (cellData && cellData.tested > 0) {
          var yld = (cellData.passed / cellData.tested * 100);
          var failed = cellData.tested - cellData.passed;
          // Get month-specific goal for this LINE (not plant goal when in Plantwide view)
          var sortKey = dateMap[col].sortKey || '';
          var monthKey = sortKey.substring(0, 7); // yyyy-MM
          var colGoal = getGoalForLineMonth(lineName, monthKey);
          var cellClass = yld >= colGoal ? 'cell-good' : 'cell-bad';
          html += '<td class="' + cellClass + ' has-tooltip" data-tt-title="' + lineName + ' - ' + col + '" data-tt-passed="' + cellData.passed + '" data-tt-failed="' + failed + '" data-tt-total="' + cellData.tested + '" data-tt-yield="' + yld.toFixed(2) + '">' + yld.toFixed(1) + '%</td>';
          lineTested += cellData.tested;
          linePassed += cellData.passed;
          colTotals[col].tested += cellData.tested;
          colTotals[col].passed += cellData.passed;
          lineGoalSum += colGoal;
          lineGoalCount++;
        } else {
          html += '<td>-</td>';
        }
      });
      
      // Line total - use average of line's monthly goals, or first month's goal if available
      var lineFailed = lineTested - linePassed;
      var lineYield = lineTested > 0 ? (linePassed / lineTested * 100) : 0;
      // For the Total column, use the line's average goal across the period
      var lineAvgGoal = lineGoalCount > 0 ? (lineGoalSum / lineGoalCount) : goal;
      // Also check if we have line-specific goals - use first available month as fallback
      if (selectedLine === 'ALL' && lineMonthlyGoals[lineName]) {
        var lineGoalKeys = Object.keys(lineMonthlyGoals[lineName]);
        if (lineGoalKeys.length > 0 && lineGoalCount === 0) {
          lineAvgGoal = lineMonthlyGoals[lineName][lineGoalKeys[0]];
        }
      }
      var lineCellClass = lineYield >= lineAvgGoal ? 'cell-good' : 'cell-bad';
      html += '<td class="' + lineCellClass + ' has-tooltip" data-tt-title="' + lineName + ' Total" data-tt-passed="' + linePassed + '" data-tt-failed="' + lineFailed + '" data-tt-total="' + lineTested + '" data-tt-yield="' + lineYield.toFixed(2) + '"><strong>' + lineYield.toFixed(1) + '%</strong></td>';
      html += '</tr>';
      
      grandTested += lineTested;
      grandPassed += linePassed;
    });
    
    // Footer row with column totals
    html += '</tbody><tfoot><tr><td><strong>Total</strong></td>';
    dateCols.forEach(function(col) {
      var colFailed = colTotals[col].tested - colTotals[col].passed;
      var colYield = colTotals[col].tested > 0 ? (colTotals[col].passed / colTotals[col].tested * 100) : 0;
      // Get month-specific goal
      var sortKey = dateMap[col].sortKey || '';
      var monthKey = sortKey.substring(0, 7); // yyyy-MM
      var colGoal = monthlyGoals[monthKey] || goal;
      var colCellClass = colYield >= colGoal ? 'cell-good' : 'cell-bad';
      html += '<td class="' + colCellClass + ' has-tooltip" data-tt-title="All Lines - ' + col + '" data-tt-passed="' + colTotals[col].passed + '" data-tt-failed="' + colFailed + '" data-tt-total="' + colTotals[col].tested + '" data-tt-yield="' + colYield.toFixed(2) + '"><strong>' + colYield.toFixed(1) + '%</strong></td>';
    });
    
    var grandFailed = grandTested - grandPassed;
    var grandYield = grandTested > 0 ? (grandPassed / grandTested * 100) : 0;
    var grandCellClass = grandYield >= goal ? 'cell-good' : 'cell-bad';
    html += '<td class="' + grandCellClass + ' has-tooltip" data-tt-title="Grand Total" data-tt-passed="' + grandPassed + '" data-tt-failed="' + grandFailed + '" data-tt-total="' + grandTested + '" data-tt-yield="' + grandYield.toFixed(2) + '"><strong>' + grandYield.toFixed(1) + '%</strong></td>';
    html += '</tr></tfoot></table>';
    
    tableView.innerHTML = html;
    
    // Attach tooltip handlers
    attachTableTooltips(tableView);
  }
  
  function attachTableTooltips(container) {
    var tooltip = document.getElementById('cellTooltip');
    var cells = container.querySelectorAll('.has-tooltip');
    
    cells.forEach(function(cell) {
      cell.addEventListener('mouseenter', function(e) {
        var title = cell.getAttribute('data-tt-title');
        var passed = parseInt(cell.getAttribute('data-tt-passed'));
        var failed = parseInt(cell.getAttribute('data-tt-failed'));
        var total = parseInt(cell.getAttribute('data-tt-total'));
        var yieldVal = cell.getAttribute('data-tt-yield');
        
        document.getElementById('cellTooltipTitle').textContent = title;
        document.getElementById('cellTooltipPassed').textContent = passed.toLocaleString() + ' units';
        document.getElementById('cellTooltipFailed').textContent = failed.toLocaleString() + ' units';
        document.getElementById('cellTooltipTotal').textContent = total.toLocaleString() + ' units';
        document.getElementById('cellTooltipYield').textContent = yieldVal + '%';
        
        tooltip.classList.add('visible');
        positionTooltip(e, tooltip);
      });
      
      cell.addEventListener('mousemove', function(e) {
        positionTooltip(e, tooltip);
      });
      
      cell.addEventListener('mouseleave', function() {
        tooltip.classList.remove('visible');
      });
    });
  }
  
  function positionTooltip(e, tooltip) {
    var x = e.clientX + 12;
    var y = e.clientY + 12;
    
    // Adjust if tooltip goes off screen
    var rect = tooltip.querySelector('.cell-tooltip-content').getBoundingClientRect();
    if (x + rect.width > window.innerWidth - 10) {
      x = e.clientX - rect.width - 12;
    }
    if (y + rect.height > window.innerHeight - 10) {
      y = e.clientY - rect.height - 12;
    }
    
    tooltip.style.left = x + 'px';
    tooltip.style.top = y + 'px';
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
      return monthNames[date.getMonth()] + ' ' + date.getFullYear();
    } else if (level === 'quarterly') {
      var quarter = Math.floor(date.getMonth() / 3) + 1;
      return 'Q' + quarter;
    } else if (level === 'yearly') {
      return date.getFullYear().toString();
    }
    return dateLabel;
  }
  
  function getBucketKey(dateSort, level) {
    // Returns a sortable key for bucketing dates
    var parts = dateSort.split('-');
    var date = new Date(parseInt(parts[0]), parseInt(parts[1]) - 1, parseInt(parts[2]));
    
    if (level === 'daily') return dateSort;
    if (level === 'weekly') {
      var onejan = new Date(date.getFullYear(), 0, 1);
      var weekNum = Math.ceil((((date - onejan) / 86400000) + onejan.getDay() + 1) / 7);
      return date.getFullYear() + '-W' + (weekNum < 10 ? '0' + weekNum : weekNum);
    }
    if (level === 'monthly') {
      return parts[0] + '-' + parts[1];
    }
    if (level === 'quarterly') {
      // Use 0-indexed month (date.getMonth()) for correct quarter calculation
      var quarter = Math.floor(date.getMonth() / 3) + 1;
      return parts[0] + '-Q' + quarter;
    }
    if (level === 'yearly') {
      return parts[0];
    }
    return dateSort;
  }
  
  function getBucketLabel(dateSort, level) {
    var parts = dateSort.split('-');
    var date = new Date(parseInt(parts[0]), parseInt(parts[1]) - 1, parseInt(parts[2]));
    
    if (level === 'daily') {
      return date.getDate() + '/' + (date.getMonth() + 1);
    }
    if (level === 'weekly') {
      var onejan = new Date(date.getFullYear(), 0, 1);
      var weekNum = Math.ceil((((date - onejan) / 86400000) + onejan.getDay() + 1) / 7);
      return 'W' + weekNum;
    }
    if (level === 'monthly') {
      var monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return monthNames[date.getMonth()] + ' ' + date.getFullYear();
    }
    if (level === 'quarterly') {
      var quarter = Math.floor(date.getMonth() / 3) + 1;
      return 'Q' + quarter + ' ' + date.getFullYear();
    }
    if (level === 'yearly') {
      return date.getFullYear().toString();
    }
    return dateSort;
  }
  
  // ========== DRILL DOWN/UP LOGIC ==========
  var drillLevels = ['daily', 'weekly', 'monthly', 'quarterly', 'yearly'];
  
  function getDateRangeDays() {
    var startInput = document.getElementById('<%= txtYieldStartDate.ClientID %>');
    var endInput = document.getElementById('<%= txtYieldEndDate.ClientID %>');
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
  
  function aggregateDataByLevel(labels, data, testedArr, passedArr, failedArr, sortDates, level) {
    if (level === 'daily') {
      return { labels: labels, data: data, tested: testedArr, passed: passedArr, failed: failedArr, sortKeys: sortDates };
    }
    
    // Parse dates from sortDates (format: yyyy-MM-dd)
    var parsedDates = sortDates.map(function(sd) {
      var parts = sd.split('-');
      return new Date(parseInt(parts[0]), parseInt(parts[1]) - 1, parseInt(parts[2]));
    });
    
    var buckets = {};
    
    for (var i = 0; i < labels.length; i++) {
      var date = parsedDates[i];
      var bucketKey;
      var bucketLabel;
      var bucketSortKey;
      
      if (level === 'weekly') {
        // Get week number
        var onejan = new Date(date.getFullYear(), 0, 1);
        var weekNum = Math.ceil((((date - onejan) / 86400000) + onejan.getDay() + 1) / 7);
        bucketKey = date.getFullYear() + '-W' + (weekNum < 10 ? '0' + weekNum : weekNum);
        bucketLabel = date.getFullYear() + '-W' + weekNum;
        bucketSortKey = bucketKey;
      } else if (level === 'monthly') {
        var monthNum = date.getMonth() + 1;
        bucketKey = date.getFullYear() + '-' + (monthNum < 10 ? '0' : '') + monthNum;
        var monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        bucketLabel = monthNames[date.getMonth()] + ' ' + date.getFullYear();
        bucketSortKey = bucketKey;
      } else if (level === 'quarterly') {
        var quarter = Math.floor(date.getMonth() / 3) + 1;
        bucketKey = date.getFullYear() + '-Q' + quarter;
        bucketLabel = 'Q' + quarter + ' ' + date.getFullYear();
        bucketSortKey = bucketKey;
      } else if (level === 'yearly') {
        bucketKey = date.getFullYear().toString();
        bucketLabel = date.getFullYear().toString();
        bucketSortKey = bucketKey;
      }
      
      if (!buckets[bucketKey]) {
        buckets[bucketKey] = { label: bucketLabel, tested: 0, passed: 0, failed: 0, sortKey: bucketSortKey, dates: [] };
      }
      buckets[bucketKey].tested += testedArr[i];
      buckets[bucketKey].passed += passedArr[i];
      buckets[bucketKey].failed += failedArr[i];
      buckets[bucketKey].dates.push(sortDates[i]); // Track original dates for goal mapping
    }
    
    // Convert to arrays and sort
    var bucketArr = Object.keys(buckets).map(function(k) { return buckets[k]; });
    bucketArr.sort(function(a, b) { return a.sortKey.localeCompare(b.sortKey); });
    
    var newLabels = [];
    var newData = [];
    var newTested = [];
    var newPassed = [];
    var newFailed = [];
    var newSortKeys = [];
    
    bucketArr.forEach(function(b) {
      newLabels.push(b.label);
      var yld = b.tested > 0 ? (b.passed / b.tested * 100) : 0;
      newData.push(Math.round(yld * 100) / 100);
      newTested.push(b.tested);
      newPassed.push(b.passed);
      newFailed.push(b.failed);
      newSortKeys.push(b.sortKey); // Use bucket's sortKey (yyyy-MM for monthly, yyyy-Wnn for weekly, etc.)
    });
    
    return { labels: newLabels, data: newData, tested: newTested, passed: newPassed, failed: newFailed, sortKeys: newSortKeys, buckets: buckets };
  }
  
  function aggregateAndRenderYieldChart() {
    updateDrillButtons();
    
    var labels = JSON.parse(document.getElementById('<%= hfYieldDailyLabels.ClientID %>').value || '[]');
    var sortDates = JSON.parse(document.getElementById('<%= hfYieldDailySortDates.ClientID %>').value || '[]');
    var data = JSON.parse(document.getElementById('<%= hfYieldDailyData.ClientID %>').value || '[]');
    var testedArr = JSON.parse(document.getElementById('<%= hfYieldDailyTested.ClientID %>').value || '[]');
    var passedArr = JSON.parse(document.getElementById('<%= hfYieldDailyPassed.ClientID %>').value || '[]');
    var failedArr = JSON.parse(document.getElementById('<%= hfYieldDailyFailed.ClientID %>').value || '[]');
    
    var aggregated = aggregateDataByLevel(labels, data, testedArr, passedArr, failedArr, sortDates, currentDrillLevel);
    
    // If in table mode, only update the table view, don't render chart
    if (currentYieldType === 'table') {
      renderYieldTableView();
      return;
    }
    
    // Calculate cumulative yield from aggregated data
    var cumulativeData = [];
    var cumTested = 0, cumPassed = 0;
    for (var i = 0; i < aggregated.data.length; i++) {
      cumTested += aggregated.tested[i];
      cumPassed += aggregated.passed[i];
      var cumYield = cumTested > 0 ? (cumPassed / cumTested * 100) : 0;
      cumulativeData.push(Math.round(cumYield * 100) / 100);
    }
    
    renderYieldChart(aggregated.labels, aggregated.data, cumulativeData, aggregated.tested, aggregated.passed, aggregated.failed, aggregated.sortKeys);
  }
  
  // ========== FAILURES BY CATEGORY CHART ==========
  var failureCategoryDetails = [];
  
  function initFailureCategoryChart() {
    var labels = JSON.parse(document.getElementById('<%= hfFailureCategoryLabels.ClientID %>').value || '[]');
    var data = JSON.parse(document.getElementById('<%= hfFailureCategoryData.ClientID %>').value || '[]');
    failureCategoryDetails = JSON.parse(document.getElementById('<%= hfFailureCategoryDetails.ClientID %>').value || '[]');
    var colors = getColors();
    var modernFont = "'Segoe UI', 'Inter', -apple-system, sans-serif";
    
    // Get dynamic font sizes based on focus state
    var fontSizes = getChartFontSizes('failuresPanel');
    
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
                font: { size: fontSizes.pointLabel, weight: '600', family: modernFont }
              }
            }
          },
          plugins: {
            legend: { display: false },
            tooltip: {
              enabled: false,
              external: function(context) {
                showFailureTooltip(context, radarLabels);
              }
            },
            datalabels: {
              display: function(ctx) { return ctx.dataset.data[ctx.dataIndex] > 0; },
              color: isDarkMode() ? '#60a5fa' : '#1e40af',
              backgroundColor: isDarkMode() ? 'rgba(30,35,45,0.85)' : 'rgba(255,255,255,0.9)',
              borderRadius: 3,
              padding: { left: 4, right: 4, top: 2, bottom: 2 },
              font: { size: fontSizes.dataLabel, weight: '700', family: modernFont },
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
                font: { size: fontSizes.legend, family: modernFont },
                boxWidth: 12,
                padding: 8
              }
            },
            datalabels: {
              display: function(ctx) { return ctx.dataset.data[0] > 0; },
              anchor: 'center',
              align: 'center',
              color: '#fff',
              font: { size: fontSizes.dataLabel, weight: '700', family: modernFont },
              formatter: function(value) { return value; }
            },
            tooltip: {
              enabled: false,
              external: function(context) {
                showFailureTooltip(context, labels);
              }
            }
          }
        }
      });
    }
    
    // Add click handler to pin tooltip
    ctx.canvas.onclick = function(evt) {
      var tooltip = document.getElementById('failureTooltip');
      if (tooltip && tooltip.classList.contains('visible') && !failureTooltipPinned) {
        pinFailureTooltip(tooltip);
        // Update header to remove "Click to pin" hint and add close button
        var header = document.getElementById('failureTooltipHeader');
        if (lastFailureTooltipData) {
          header.innerHTML = lastFailureTooltipData.categoryName + ' (' + lastFailureTooltipData.categoryTotal + ' issues)<span class="tooltip-close-btn" onclick="event.stopPropagation();unpinFailureTooltip();">&times;</span>';
        }
      }
    };
  }
  
  // Pinnable tooltip state
  var failureTooltipPinned = false;
  var lastFailureTooltipData = null;
  var justPinned = false; // Flag to prevent immediate unpin
  
  function pinFailureTooltip(tooltip) {
    failureTooltipPinned = true;
    justPinned = true;
    tooltip.classList.add('pinned');
    tooltip.style.pointerEvents = 'auto';
    // Reset justPinned flag after a short delay
    setTimeout(function() { justPinned = false; }, 100);
  }
  
  function unpinFailureTooltip() {
    var tooltip = document.getElementById('failureTooltip');
    if (tooltip) {
      failureTooltipPinned = false;
      tooltip.classList.remove('pinned', 'visible');
      tooltip.style.pointerEvents = 'none';
      lastFailureTooltipData = null;
    }
  }
  
  function positionFailureTooltip(x, y, tooltip) {
    var offsetX = 12;
    var offsetY = 12;
    var posX = x + offsetX;
    var posY = y + offsetY;
    
    // Adjust if goes off screen
    var rect = tooltip.querySelector('.failure-tooltip-content').getBoundingClientRect();
    if (posX + rect.width > window.innerWidth - 10) {
      posX = x - rect.width - offsetX;
    }
    if (posY + rect.height > window.innerHeight - 10) {
      posY = y - rect.height - offsetY;
    }
    
    tooltip.style.left = posX + 'px';
    tooltip.style.top = posY + 'px';
  }
  
  // Close pinned tooltip when clicking outside
  document.addEventListener('click', function(e) {
    if (justPinned) return; // Don't unpin if we just pinned
    var tooltip = document.getElementById('failureTooltip');
    if (failureTooltipPinned && tooltip && !tooltip.contains(e.target)) {
      unpinFailureTooltip();
    }
  });
  
  function showFailureTooltip(context, chartLabels) {
    var tooltip = document.getElementById('failureTooltip');
    if (!tooltip) return;
    
    // Don't update if tooltip is pinned
    if (failureTooltipPinned) return;
    
    var tooltipModel = context.tooltip;
    
    // Hide if no tooltip
    if (tooltipModel.opacity === 0) {
      tooltip.classList.remove('visible');
      return;
    }
    
    // Get data point info
    if (tooltipModel.dataPoints && tooltipModel.dataPoints.length > 0) {
      var dataPoint = tooltipModel.dataPoints[0];
      var categoryName = '';
      var categoryTotal = 0;
      
      // For radar chart, use the label from radarLabels
      // For bar chart, use the dataset label
      if (context.chart.config.type === 'radar') {
        categoryName = chartLabels[dataPoint.dataIndex];
        categoryTotal = dataPoint.parsed.r;
      } else {
        categoryName = dataPoint.dataset.label;
        categoryTotal = dataPoint.parsed.y;
      }
      
      // Find details for this category
      var catDetails = null;
      for (var i = 0; i < failureCategoryDetails.length; i++) {
        if (failureCategoryDetails[i].category === categoryName) {
          catDetails = failureCategoryDetails[i];
          break;
        }
      }
      
      // Store for potential pinning
      lastFailureTooltipData = { categoryName: categoryName, categoryTotal: categoryTotal, catDetails: catDetails };
      
      // Build header with pin hint
      document.getElementById('failureTooltipHeader').innerHTML = categoryName + ' (' + categoryTotal + ' issues)<span style="font-size:9px;font-weight:normal;margin-left:10px;opacity:0.7;">Click to pin</span>';
      
      // Build body with lines and serials (expandable)
      var bodyHtml = '';
      if (catDetails && catDetails.lines && catDetails.lines.length > 0) {
        catDetails.lines.forEach(function(lineItem, lineIdx) {
          bodyHtml += '<div class="failure-tooltip-line">';
          bodyHtml += '<div class="failure-tooltip-line-header">' + lineItem.line + ' (' + lineItem.count + ')</div>';
          if (lineItem.serials && lineItem.serials.length > 0) {
            var initialShow = 10;
            var hasMore = lineItem.serials.length > initialShow;
            var uniqueId = 'chartserials_' + lineIdx + '_' + Math.random().toString(36).substr(2, 9);
            
            bodyHtml += '<div class="failure-tooltip-serials" id="' + uniqueId + '_collapsed">';
            lineItem.serials.slice(0, initialShow).forEach(function(sn) {
              bodyHtml += '<span class="failure-tooltip-serial">' + sn + '</span>';
            });
            if (hasMore) {
              bodyHtml += '<span class="failure-tooltip-more failure-tooltip-expand" onclick="event.stopPropagation();expandSerials(\'' + uniqueId + '\');">+' + (lineItem.serials.length - initialShow) + ' more</span>';
            }
            bodyHtml += '</div>';
            
            // Hidden expanded version
            if (hasMore) {
              bodyHtml += '<div class="failure-tooltip-serials" id="' + uniqueId + '_expanded" style="display:none;">';
              lineItem.serials.forEach(function(sn) {
                bodyHtml += '<span class="failure-tooltip-serial">' + sn + '</span>';
              });
              bodyHtml += '<span class="failure-tooltip-more failure-tooltip-expand" onclick="event.stopPropagation();collapseSerials(\'' + uniqueId + '\');">Show less</span>';
              bodyHtml += '</div>';
            }
          }
          bodyHtml += '</div>';
        });
      } else {
        bodyHtml = '<div style="font-size:10px;color:rgba(0,0,0,0.5);font-style:italic;">No details available</div>';
      }
      
      document.getElementById('failureTooltipBody').innerHTML = bodyHtml;
    }
    
    tooltip.classList.add('visible');
    
    // Position tooltip
    var position = context.chart.canvas.getBoundingClientRect();
    var x = position.left + window.scrollX + tooltipModel.caretX + 12;
    var y = position.top + window.scrollY + tooltipModel.caretY + 12;
    
    // Adjust if goes off screen
    var rect = tooltip.querySelector('.failure-tooltip-content').getBoundingClientRect();
    if (x + rect.width > window.innerWidth - 10) {
      x = position.left + window.scrollX + tooltipModel.caretX - rect.width - 12;
    }
    if (y + rect.height > window.innerHeight - 10) {
      y = position.top + window.scrollY + tooltipModel.caretY - rect.height - 12;
    }
    
    tooltip.style.left = x + 'px';
    tooltip.style.top = y + 'px';
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
    var details = JSON.parse(document.getElementById('<%= hfFailureCategoryDetails.ClientID %>').value || '[]');
    
    var tableView = document.getElementById('failureTableView');
    
    if (!labels.length || !details.length) {
      tableView.innerHTML = '<div style="display:flex;align-items:center;justify-content:center;height:100%;color:rgba(0,0,0,0.4);font-size:11px;font-style:italic;">No failure data available</div>';
      return;
    }
    
    // Build pivot: Lines as rows, Categories as columns
    // First, collect all unique lines and build category->line->{ count, serials } map
    var lines = [];
    var categoryMap = {}; // category -> { line -> { count, serials } }
    var categories = [];
    
    details.forEach(function(cat) {
      categories.push(cat.category);
      categoryMap[cat.category] = {};
      
      if (cat.lines) {
        cat.lines.forEach(function(lineItem) {
          if (lines.indexOf(lineItem.line) === -1) {
            lines.push(lineItem.line);
          }
          categoryMap[cat.category][lineItem.line] = {
            count: lineItem.count,
            serials: lineItem.serials || []
          };
        });
      }
    });
    
    // Sort lines alphabetically
    lines.sort();
    
    // Build table HTML
    var html = '<table><thead><tr><th>Line</th>';
    categories.forEach(function(cat) {
      html += '<th>' + cat + '</th>';
    });
    html += '<th>Total</th></tr></thead><tbody>';
    
    // Track column totals
    var colTotals = {};
    categories.forEach(function(cat) { colTotals[cat] = 0; });
    var grandTotal = 0;
    
    lines.forEach(function(lineName) {
      var lineTotal = 0;
      var lineSerials = [];
      html += '<tr><td>' + lineName + '</td>';
      
      categories.forEach(function(cat) {
        var cellData = categoryMap[cat][lineName];
        var count = cellData ? cellData.count : 0;
        var serials = cellData ? cellData.serials : [];
        var cellClass = count > 0 ? 'cell-bad has-failure-tooltip' : '';
        
        if (count > 0) {
          var serialsJson = JSON.stringify(serials).replace(/"/g, '&quot;');
          html += '<td class="' + cellClass + '" data-ft-line="' + lineName + '" data-ft-cat="' + cat + '" data-ft-count="' + count + '" data-ft-serials="' + serialsJson + '">' + count + '</td>';
          lineSerials = lineSerials.concat(serials);
        } else {
          html += '<td>-</td>';
        }
        lineTotal += count;
        colTotals[cat] += count;
      });
      
      // Line total
      var lineTotalClass = lineTotal > 0 ? 'cell-bad' : '';
      html += '<td class="' + lineTotalClass + '"><strong>' + (lineTotal > 0 ? lineTotal : '-') + '</strong></td>';
      html += '</tr>';
      
      grandTotal += lineTotal;
    });
    
    // Footer row with category totals
    html += '</tbody><tfoot><tr><td><strong>Total</strong></td>';
    categories.forEach(function(cat) {
      var colCellClass = colTotals[cat] > 0 ? 'cell-bad' : '';
      html += '<td class="' + colCellClass + '"><strong>' + colTotals[cat] + '</strong></td>';
    });
    html += '<td class="cell-bad"><strong>' + grandTotal + '</strong></td>';
    html += '</tr></tfoot></table>';
    
    tableView.innerHTML = html;
    
    // Attach tooltip handlers for cells with data
    attachFailureTableTooltips(tableView);
  }
  
  function attachFailureTableTooltips(container) {
    var tooltip = document.getElementById('failureTooltip');
    var cells = container.querySelectorAll('.has-failure-tooltip');
    
    cells.forEach(function(cell) {
      cell.addEventListener('mouseenter', function(e) {
        if (failureTooltipPinned) return; // Don't show hover tooltip if pinned
        
        var lineName = cell.getAttribute('data-ft-line');
        var category = cell.getAttribute('data-ft-cat');
        var count = cell.getAttribute('data-ft-count');
        var serials = JSON.parse(cell.getAttribute('data-ft-serials') || '[]');
        
        showFailureTableCellTooltip(lineName, category, count, serials, e, tooltip);
      });
      
      cell.addEventListener('mousemove', function(e) {
        if (failureTooltipPinned) return;
        positionFailureTooltip(e.clientX, e.clientY, tooltip);
      });
      
      cell.addEventListener('mouseleave', function() {
        if (failureTooltipPinned) return;
        tooltip.classList.remove('visible');
      });
      
      cell.addEventListener('click', function(e) {
        var lineName = cell.getAttribute('data-ft-line');
        var category = cell.getAttribute('data-ft-cat');
        var count = cell.getAttribute('data-ft-count');
        var serials = JSON.parse(cell.getAttribute('data-ft-serials') || '[]');
        
        showFailureTableCellTooltip(lineName, category, count, serials, e, tooltip, true);
        e.stopPropagation();
      });
    });
  }
  
  function showFailureTableCellTooltip(lineName, category, count, serials, e, tooltip, pinned) {
    // Build header
    var headerText = lineName + ' - ' + category + ' (' + count + ' issues)';
    if (pinned) {
      document.getElementById('failureTooltipHeader').innerHTML = headerText + '<span class="tooltip-close-btn" onclick="event.stopPropagation();unpinFailureTooltip();">&times;</span>';
    } else {
      document.getElementById('failureTooltipHeader').innerHTML = headerText + '<span style="font-size:9px;font-weight:normal;margin-left:10px;opacity:0.7;">Click to pin</span>';
    }
    
    // Build body with serials (show first 10, expandable)
    var bodyHtml = '';
    if (serials && serials.length > 0) {
      var initialShow = 10;
      var hasMore = serials.length > initialShow;
      var uniqueId = 'serials_' + Math.random().toString(36).substr(2, 9);
      
      bodyHtml += '<div class="failure-tooltip-serials" id="' + uniqueId + '_collapsed">';
      serials.slice(0, initialShow).forEach(function(sn) {
        bodyHtml += '<span class="failure-tooltip-serial">' + sn + '</span>';
      });
      if (hasMore) {
        bodyHtml += '<span class="failure-tooltip-more failure-tooltip-expand" onclick="event.stopPropagation();expandSerials(\'' + uniqueId + '\');">+' + (serials.length - initialShow) + ' more</span>';
      }
      bodyHtml += '</div>';
      
      // Hidden expanded version
      if (hasMore) {
        bodyHtml += '<div class="failure-tooltip-serials" id="' + uniqueId + '_expanded" style="display:none;">';
        serials.forEach(function(sn) {
          bodyHtml += '<span class="failure-tooltip-serial">' + sn + '</span>';
        });
        bodyHtml += '<span class="failure-tooltip-more failure-tooltip-expand" onclick="event.stopPropagation();collapseSerials(\'' + uniqueId + '\');">Show less</span>';
        bodyHtml += '</div>';
      }
    } else {
      bodyHtml = '<div style="font-size:10px;color:rgba(0,0,0,0.5);font-style:italic;">No serial numbers available</div>';
    }
    
    document.getElementById('failureTooltipBody').innerHTML = bodyHtml;
    
    tooltip.classList.add('visible');
    
    if (pinned) {
      pinFailureTooltip(tooltip);
    }
    
    positionFailureTooltip(e.clientX, e.clientY, tooltip);
  }
  
  // Expand/collapse serial numbers in tooltip
  function expandSerials(uniqueId) {
    var collapsed = document.getElementById(uniqueId + '_collapsed');
    var expanded = document.getElementById(uniqueId + '_expanded');
    if (collapsed) collapsed.style.display = 'none';
    if (expanded) expanded.style.display = 'flex';
  }
  
  function collapseSerials(uniqueId) {
    var collapsed = document.getElementById(uniqueId + '_collapsed');
    var expanded = document.getElementById(uniqueId + '_expanded');
    if (collapsed) collapsed.style.display = 'flex';
    if (expanded) expanded.style.display = 'none';
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
    var lineMonthlyGoals = JSON.parse(document.getElementById('<%= hfLineMonthlyGoals.ClientID %>').value || '{}');
    var selectedLine = document.getElementById('<%= ddlYieldLine.ClientID %>').value;
    var tbody = document.getElementById('lineTableBodyLarge');
    var tfoot = document.getElementById('lineTableFootLarge');
    
    // Helper to get first available goal for a line (used for period total)
    function getLineGoal(lineName) {
      if (selectedLine === 'ALL' && lineMonthlyGoals[lineName]) {
        var keys = Object.keys(lineMonthlyGoals[lineName]);
        if (keys.length > 0) return lineMonthlyGoals[lineName][keys[0]];
      }
      return goal;
    }
    
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
      // Use line-specific goal when in Plantwide view
      var lineGoal = getLineGoal(row.line);
      var yieldClass = lineYield >= lineGoal ? 'cell-good' : 'cell-bad';
      
      var tr = document.createElement('tr');
      tr.innerHTML = '<td>' + row.line + '</td>' +
                     '<td>' + row.tested.toLocaleString() + '</td>' +
                     '<td><span class="passed">' + row.passed.toLocaleString() + '</span> / <span class="failed">' + row.failed.toLocaleString() + '</span></td>' +
                     '<td class="' + yieldClass + '">' + lineYield.toFixed(2) + '%</td>';
      tbody.appendChild(tr);
    });
    
    // Total row uses plant goal (aggregate view)
    var totalYield = totalTested > 0 ? (totalPassed / totalTested * 100) : 0;
    var totalYieldClass = totalYield >= goal ? 'cell-good' : 'cell-bad';
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
    var lineMonthlyGoals = JSON.parse(document.getElementById('<%= hfLineMonthlyGoals.ClientID %>').value || '{}');
    var selectedLine = document.getElementById('<%= ddlYieldLine.ClientID %>').value;
    var tbody = document.getElementById('lineTableBodySmall');
    var tfoot = document.getElementById('lineTableFootSmall');
    
    tbody.innerHTML = '';
    tfoot.innerHTML = '';
    
    // Helper to get first available goal for a line (used for period total)
    function getLineGoal(lineName) {
      if (selectedLine === 'ALL' && lineMonthlyGoals[lineName]) {
        var keys = Object.keys(lineMonthlyGoals[lineName]);
        if (keys.length > 0) return lineMonthlyGoals[lineName][keys[0]];
      }
      return goal;
    }
    
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
      // Use line-specific goal when in Plantwide view
      var lineGoal = getLineGoal(row.line);
      var yieldClass = lineYield >= lineGoal ? 'cell-good' : 'cell-bad';
      
      var tr = document.createElement('tr');
      tr.innerHTML = '<td>' + row.line + '</td>' +
                     '<td>' + row.tested.toLocaleString() + '</td>' +
                     '<td><span class="passed">' + row.passed.toLocaleString() + '</span> / <span class="failed">' + row.failed.toLocaleString() + '</span></td>' +
                     '<td class="' + yieldClass + '">' + lineYield.toFixed(2) + '%</td>';
      tbody.appendChild(tr);
    });
    
    // Total row uses plant goal (aggregate view)
    var totalYield = totalTested > 0 ? (totalPassed / totalTested * 100) : 0;
    var totalYieldClass = totalYield >= goal ? 'cell-good' : 'cell-bad';
    var tfootRow = document.createElement('tr');
    tfootRow.innerHTML = '<td><strong>' + plantName + '</strong></td>' +
                         '<td><strong>' + totalTested.toLocaleString() + '</strong></td>' +
                         '<td><span class="passed"><strong>' + totalPassed.toLocaleString() + '</strong></span> / <span class="failed"><strong>' + totalFailed.toLocaleString() + '</strong></span></td>' +
                         '<td class="' + totalYieldClass + '"><strong>' + totalYield.toFixed(2) + '%</strong></td>';
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
    
    // Goal label for small gauge
    var labelOffset = 35;
    var labelX = cx + labelOffset * Math.cos(goalAngle);
    var labelY = cy + labelOffset * Math.sin(goalAngle);
    
    var textAnchor = 'middle';
    if (goalAngle < Math.PI * 1.2) {
      textAnchor = 'end';
      labelX -= 6;
    } else if (goalAngle > Math.PI * 1.8) {
      textAnchor = 'start';
      labelX += 6;
    }
    
    var goalLabel = document.createElementNS('http://www.w3.org/2000/svg', 'text');
    goalLabel.setAttribute('x', labelX);
    goalLabel.setAttribute('y', labelY);
    goalLabel.setAttribute('fill', goalLineColor);
    goalLabel.setAttribute('font-size', '9');
    goalLabel.setAttribute('font-weight', '600');
    goalLabel.setAttribute('text-anchor', textAnchor);
    goalLabel.setAttribute('dominant-baseline', 'middle');
    goalLabel.textContent = goal.toFixed(1) + '%';
    svg.appendChild(goalLabel);
  }
  
  // ========== SCRAP CHARTS ==========
  
  // Scrap Gauge View Toggle (By Line or Top Items)
  function setScrapGaugeViewType(type) {
    currentScrapGaugeView = type;
    var btns = document.querySelectorAll('#scrapGaugeToggle button');
    btns.forEach(function(b) { b.classList.remove('active'); });
    btns[type === 'byLine' ? 0 : 1].classList.add('active');
    
    document.getElementById('scrapByLineView').style.display = type === 'byLine' ? 'flex' : 'none';
    document.getElementById('scrapTopItemsView').style.display = type === 'topItems' ? 'flex' : 'none';
    
    if (type === 'byLine') {
      initScrapGaugeSmall();
      initScrapLineTableSmall();
    } else {
      initScrapGaugeTopItems();
      initTopScrapChart();
    }
  }
  
  // Format currency for display - shows 2 decimals for K/M values for precision
  function formatCurrency(value) {
    if (value >= 1000000) {
      return '$' + (value / 1000000).toFixed(2) + 'M';
    } else if (value >= 1000) {
      return '$' + (value / 1000).toFixed(2) + 'K';
    }
    return '$' + value.toFixed(1);
  }
  
  // Scrap Gauge (Large)
  function initScrapGauge() {
    var scrapTotal = parseFloat(document.getElementById('<%= hfScrapTotal.ClientID %>').value) || 0;
    var scrapGoal = parseFloat(document.getElementById('<%= hfScrapGoal.ClientID %>').value) || 1;
    var colors = getColors();
    
    // Percentage of goal (inverted - lower is better)
    var pctOfGoal = scrapGoal > 0 ? (scrapTotal / scrapGoal * 100) : 0;
    
    var valueDisplay = document.getElementById('scrapGaugeValueDisplay');
    valueDisplay.innerHTML = formatCurrency(scrapTotal);
    valueDisplay.classList.remove('under-goal', 'over-goal');
    valueDisplay.classList.add(pctOfGoal <= 100 ? 'under-goal' : 'over-goal');
    
    var svg = document.getElementById('scrapGaugeSvg');
    svg.innerHTML = '';
    
    var cx = 110, cy = 100, r = 80;
    var strokeWidth = 32;
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
    
    // Value arc (cap at 100% for visual)
    if (scrapTotal > 0) {
      var valueAngle = startAngle + (Math.min(pctOfGoal, 100) / 100) * angleRange;
      var valuePath = describeArc(cx, cy, r, startAngle, valueAngle);
      var valueArc = document.createElementNS('http://www.w3.org/2000/svg', 'path');
      valueArc.setAttribute('d', valuePath);
      valueArc.setAttribute('fill', 'none');
      // Green if under goal, red if over goal
      var gaugeColor = pctOfGoal <= 100 ? colors.success : colors.danger;
      valueArc.setAttribute('stroke', gaugeColor);
      valueArc.setAttribute('stroke-width', strokeWidth);
      valueArc.setAttribute('stroke-linecap', 'butt');
      svg.appendChild(valueArc);
    }
    
    // Goal line at 100%
    var goalLineColor = isDarkMode() ? 'rgba(180,180,180,0.9)' : 'rgba(80,80,80,0.8)';
    var goalAngle = endAngle; // 100% of gauge = at goal
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
    
    // Goal label
    var goalLabel = document.createElementNS('http://www.w3.org/2000/svg', 'text');
    goalLabel.setAttribute('x', cx + 42);
    goalLabel.setAttribute('y', cy + 8);
    goalLabel.setAttribute('fill', goalLineColor);
    goalLabel.setAttribute('font-size', '10');
    goalLabel.setAttribute('font-weight', '600');
    goalLabel.setAttribute('text-anchor', 'start');
    goalLabel.textContent = formatCurrency(scrapGoal);
    svg.appendChild(goalLabel);
  }
  
  // Scrap Gauge (Small - for Both view)
  function initScrapGaugeSmall() {
    var scrapTotal = parseFloat(document.getElementById('<%= hfScrapTotal.ClientID %>').value) || 0;
    var scrapGoal = parseFloat(document.getElementById('<%= hfScrapGoal.ClientID %>').value) || 1;
    var colors = getColors();
    
    var pctOfGoal = scrapGoal > 0 ? (scrapTotal / scrapGoal * 100) : 0;
    
    // Dynamic max: if over goal, max = value * 1.1, else max = goal * 1.1
    // This ensures the gauge never fills 100%
    var maxValue = scrapTotal > scrapGoal ? scrapTotal * 1.1 : scrapGoal * 1.1;
    var pctOfMax = maxValue > 0 ? (scrapTotal / maxValue * 100) : 0;
    var goalPctOfMax = maxValue > 0 ? (scrapGoal / maxValue * 100) : 0;
    
    var valueDisplay = document.getElementById('scrapGaugeValueDisplaySmall');
    valueDisplay.innerHTML = formatCurrency(scrapTotal);
    valueDisplay.classList.remove('under-goal', 'over-goal');
    valueDisplay.classList.add(pctOfGoal <= 100 ? 'under-goal' : 'over-goal');
    
    var svg = document.getElementById('scrapGaugeSvgSmall');
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
    
    // Value arc - use pctOfMax for dynamic scaling
    if (scrapTotal > 0) {
      var valueAngle = startAngle + (pctOfMax / 100) * angleRange;
      var valuePath = describeArc(cx, cy, r, startAngle, valueAngle);
      var valueArc = document.createElementNS('http://www.w3.org/2000/svg', 'path');
      valueArc.setAttribute('d', valuePath);
      valueArc.setAttribute('fill', 'none');
      // Green if under goal, red if over goal
      var gaugeColor = pctOfGoal <= 100 ? colors.success : colors.danger;
      valueArc.setAttribute('stroke', gaugeColor);
      valueArc.setAttribute('stroke-width', '26');
      valueArc.setAttribute('stroke-linecap', 'butt');
      svg.appendChild(valueArc);
    }
    
    // Goal indicator - positioned based on goalPctOfMax
    var goalLineColor = isDarkMode() ? 'rgba(180,180,180,0.9)' : 'rgba(80,80,80,0.8)';
    var goalAngle = startAngle + (goalPctOfMax / 100) * angleRange;
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
    
    // Goal label - positioned at the outer tip of the goal line
    // Use the outer point (gx2, gy2) and offset slightly
    var labelOffsetX = 4 * Math.cos(goalAngle);
    var labelOffsetY = -12; // Always show above the line
    var labelX = gx2 + labelOffsetX;
    var labelY = gy2 + labelOffsetY;
    // Keep label within SVG bounds
    labelX = Math.max(30, Math.min(190, labelX));
    labelY = Math.max(12, Math.min(105, labelY));
    var goalLabel = document.createElementNS('http://www.w3.org/2000/svg', 'text');
    goalLabel.setAttribute('x', labelX);
    goalLabel.setAttribute('y', labelY);
    goalLabel.setAttribute('fill', goalLineColor);
    goalLabel.setAttribute('font-size', '9');
    goalLabel.setAttribute('font-weight', '600');
    goalLabel.setAttribute('text-anchor', labelX > cx ? 'start' : 'end');
    goalLabel.textContent = formatCurrency(scrapGoal);
    svg.appendChild(goalLabel);
  }
  
  // Scrap Gauge for Top Items view
  function initScrapGaugeTopItems() {
    var scrapTotal = parseFloat(document.getElementById('<%= hfScrapTotal.ClientID %>').value) || 0;
    var scrapGoal = parseFloat(document.getElementById('<%= hfScrapGoal.ClientID %>').value) || 1;
    var colors = getColors();
    
    var pctOfGoal = scrapGoal > 0 ? (scrapTotal / scrapGoal * 100) : 0;
    
    // Dynamic max: if over goal, max = value * 1.1, else max = goal * 1.1
    // This ensures the gauge never fills 100%
    var maxValue = scrapTotal > scrapGoal ? scrapTotal * 1.1 : scrapGoal * 1.1;
    var pctOfMax = maxValue > 0 ? (scrapTotal / maxValue * 100) : 0;
    var goalPctOfMax = maxValue > 0 ? (scrapGoal / maxValue * 100) : 0;
    
    var valueDisplay = document.getElementById('scrapGaugeValueDisplayTopItems');
    valueDisplay.innerHTML = formatCurrency(scrapTotal);
    valueDisplay.classList.remove('under-goal', 'over-goal');
    valueDisplay.classList.add(pctOfGoal <= 100 ? 'under-goal' : 'over-goal');
    
    var svg = document.getElementById('scrapGaugeSvgTopItems');
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
    
    // Value arc - use pctOfMax for dynamic scaling
    if (scrapTotal > 0) {
      var valueAngle = startAngle + (pctOfMax / 100) * angleRange;
      var valuePath = describeArc(cx, cy, r, startAngle, valueAngle);
      var valueArc = document.createElementNS('http://www.w3.org/2000/svg', 'path');
      valueArc.setAttribute('d', valuePath);
      valueArc.setAttribute('fill', 'none');
      // Green if under goal, red if over goal
      var gaugeColor = pctOfGoal <= 100 ? colors.success : colors.danger;
      valueArc.setAttribute('stroke', gaugeColor);
      valueArc.setAttribute('stroke-width', '26');
      valueArc.setAttribute('stroke-linecap', 'butt');
      svg.appendChild(valueArc);
    }
    
    // Goal indicator - positioned based on goalPctOfMax
    var goalLineColor = isDarkMode() ? 'rgba(180,180,180,0.9)' : 'rgba(80,80,80,0.8)';
    var goalAngle = startAngle + (goalPctOfMax / 100) * angleRange;
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
    
    // Goal label - positioned at the outer tip of the goal line
    var labelOffsetX = 4 * Math.cos(goalAngle);
    var labelOffsetY = -12; // Always show above the line
    var labelX = gx2 + labelOffsetX;
    var labelY = gy2 + labelOffsetY;
    // Keep label within SVG bounds
    labelX = Math.max(30, Math.min(190, labelX));
    labelY = Math.max(12, Math.min(105, labelY));
    var goalLabel = document.createElementNS('http://www.w3.org/2000/svg', 'text');
    goalLabel.setAttribute('x', labelX);
    goalLabel.setAttribute('y', labelY);
    goalLabel.setAttribute('fill', goalLineColor);
    goalLabel.setAttribute('font-size', '9');
    goalLabel.setAttribute('font-weight', '600');
    goalLabel.setAttribute('text-anchor', labelX > cx ? 'start' : 'end');
    goalLabel.textContent = formatCurrency(scrapGoal);
    svg.appendChild(goalLabel);
  }
  
  // Scrap Line Table (Small - for Both view)
  function initScrapLineTableSmall() {
    var scrapByLineData = JSON.parse(document.getElementById('<%= hfScrapByLineData.ClientID %>').value || '[]');
    var tbody = document.getElementById('scrapLineTableBodySmall');
    var tfoot = document.getElementById('scrapLineTableFootSmall');
    
    tbody.innerHTML = '';
    tfoot.innerHTML = '';
    
    if (!scrapByLineData.length) {
      tbody.innerHTML = '<tr><td colspan="4" style="text-align:center;color:rgba(0,0,0,0.4);font-style:italic;">No scrap data</td></tr>';
      return;
    }
    
    var totalGoal = 0, totalActual = 0;
    
    scrapByLineData.forEach(function(row) {
      var variance = row.actual - row.goal;
      var isUnderGoal = variance <= 0;
      var actualClass = isUnderGoal ? 'cell-good' : 'cell-bad'; // Background color for ACTUAL
      var varianceTextClass = isUnderGoal ? 'text-good' : 'text-bad'; // Text color only for VAR
      var variancePrefix = isUnderGoal ? '-' : '+';
      var varianceText = variancePrefix + formatCurrency(Math.abs(variance)).replace('$', '');
      
      totalGoal += row.goal;
      totalActual += row.actual;
      
      var tr = document.createElement('tr');
      tr.innerHTML = '<td>' + row.line + '</td>' +
                     '<td>' + formatCurrency(row.goal) + '</td>' +
                     '<td class="' + actualClass + '">' + formatCurrency(row.actual) + '</td>' +
                     '<td class="' + varianceTextClass + '">' + varianceText + '</td>';
      tbody.appendChild(tr);
    });
    
    var totalVariance = totalActual - totalGoal;
    var totalIsUnderGoal = totalVariance <= 0;
    var totalActualClass = totalIsUnderGoal ? 'cell-good' : 'cell-bad';
    var totalVarianceTextClass = totalIsUnderGoal ? 'text-good' : 'text-bad';
    var totalVariancePrefix = totalIsUnderGoal ? '-' : '+';
    var totalVarianceText = totalVariancePrefix + formatCurrency(Math.abs(totalVariance)).replace('$', '');
    
    var tfootRow = document.createElement('tr');
    tfootRow.innerHTML = '<td><strong>Total</strong></td>' +
                         '<td><strong>' + formatCurrency(totalGoal) + '</strong></td>' +
                         '<td class="' + totalActualClass + '"><strong>' + formatCurrency(totalActual) + '</strong></td>' +
                         '<td class="' + totalVarianceTextClass + '"><strong>' + totalVarianceText + '</strong></td>';
    tfoot.appendChild(tfootRow);
  }
  
  // Scrap Daily Chart
  function initScrapDailyChart() {
    currentScrapDrillLevel = getDefaultDrillLevel();
    aggregateAndRenderScrapChart();
  }
  
  function aggregateAndRenderScrapChart() {
    var labels = JSON.parse(document.getElementById('<%= hfScrapDailyLabels.ClientID %>').value || '[]');
    var sortDates = JSON.parse(document.getElementById('<%= hfScrapDailySortDates.ClientID %>').value || '[]');
    var data = JSON.parse(document.getElementById('<%= hfScrapDailyData.ClientID %>').value || '[]');
    var cumulativeData = JSON.parse(document.getElementById('<%= hfScrapDailyCumulative.ClientID %>').value || '[]');
    var goalData = JSON.parse(document.getElementById('<%= hfScrapDailyGoals.ClientID %>').value || '[]');
    
    // Aggregate based on drill level if needed
    if (currentScrapDrillLevel !== 'daily' && labels.length > 0) {
      var aggregated = aggregateScrapByDrillLevel(labels, sortDates, data, goalData, currentScrapDrillLevel);
      labels = aggregated.labels;
      sortDates = aggregated.sortDates;
      data = aggregated.data;
      goalData = aggregated.goals;
      
      // Recalculate cumulative
      cumulativeData = [];
      var runningTotal = 0;
      for (var i = 0; i < data.length; i++) {
        runningTotal += data[i];
        cumulativeData.push(runningTotal);
      }
    }
    
    // Calculate cumulative goals that accumulate across the entire period
    // The approach: 
    // 1. For daily view: Sum previous months' full goals + prorate current month by day
    // 2. For weekly view: Sum daily goals for each day in the week, accumulating from previous weeks
    // 3. For monthly view: Each month adds its full goal to previous months' total
    // 4. For quarterly view: Sum the 3 months' goals, accumulating from previous quarters
    // 5. For yearly view: Sum all months for that year, accumulating from previous years
    
    var cumulativeGoals = [];
    var monthlyGoals = JSON.parse(document.getElementById('<%= hfScrapMonthlyGoals.ClientID %>').value || '{}');
    
    // Build a sorted list of months from monthly goals
    var monthKeys = Object.keys(monthlyGoals).sort();
    
    // Helper function to calculate cumulative goal up to a specific date
    function getCumulativeGoalForDate(dateStr) {
      var parts = dateStr.split('-');
      var year = parseInt(parts[0], 10);
      var month = parseInt(parts[1], 10);
      var day = parts.length >= 3 ? parseInt(parts[2], 10) : null;
      
      var targetMonth = year + '-' + (month < 10 ? '0' + month : month);
      var daysInMonth = new Date(year, month, 0).getDate();
      
      var cumGoal = 0;
      
      // Sum all previous months' full goals
      for (var j = 0; j < monthKeys.length; j++) {
        if (monthKeys[j] < targetMonth) {
          cumGoal += monthlyGoals[monthKeys[j]] || 0;
        } else if (monthKeys[j] === targetMonth) {
          // Current month - prorate by day if day is specified
          var thisMonthGoal = monthlyGoals[monthKeys[j]] || 0;
          if (day !== null) {
            cumGoal += (thisMonthGoal / daysInMonth) * day;
          } else {
            // Full month
            cumGoal += thisMonthGoal;
          }
        }
      }
      
      return cumGoal;
    }
    
    // Helper function to get days in a week bucket
    function getWeekDates(weekKey) {
      // weekKey format: "2025-W03"
      var parts = weekKey.split('-W');
      var year = parseInt(parts[0], 10);
      var weekNum = parseInt(parts[1], 10);
      
      // Get first day of the year
      var jan1 = new Date(year, 0, 1);
      var jan1Day = jan1.getDay(); // 0=Sunday
      
      // Calculate the first Thursday of the year (ISO week definition)
      var firstThursday = new Date(year, 0, 1 + ((4 - jan1Day + 7) % 7));
      
      // Calculate the Monday of week 1
      var week1Monday = new Date(firstThursday);
      week1Monday.setDate(firstThursday.getDate() - 3);
      
      // Calculate the Monday of the target week
      var targetMonday = new Date(week1Monday);
      targetMonday.setDate(week1Monday.getDate() + (weekNum - 1) * 7);
      
      // Get all 7 days of the week
      var dates = [];
      for (var d = 0; d < 7; d++) {
        var date = new Date(targetMonday);
        date.setDate(targetMonday.getDate() + d);
        dates.push(date);
      }
      return dates;
    }
    
    // Calculate cumulative goal for each data point based on the view level
    for (var i = 0; i < sortDates.length; i++) {
      var currentSortKey = sortDates[i] || '';
      var cumulativeGoal = 0;
      
      if (!currentSortKey) {
        cumulativeGoals.push(0);
        continue;
      }
      
      if (currentSortKey.indexOf('-W') > -1) {
        // Weekly bucket - calculate goal by summing daily goals for each day in the week
        var weekDates = getWeekDates(currentSortKey);
        var lastDayOfWeek = weekDates[weekDates.length - 1];
        // Use the last day of the week for cumulative calculation
        var lastDayStr = lastDayOfWeek.getFullYear() + '-' + 
                         String(lastDayOfWeek.getMonth() + 1).padStart(2, '0') + '-' +
                         String(lastDayOfWeek.getDate()).padStart(2, '0');
        cumulativeGoal = getCumulativeGoalForDate(lastDayStr);
        
      } else if (currentSortKey.indexOf('-Q') > -1) {
        // Quarterly bucket - sum goals for all months up to end of quarter
        var qParts = currentSortKey.split('-Q');
        var year = parseInt(qParts[0], 10);
        var quarter = parseInt(qParts[1], 10);
        var endMonth = quarter * 3;
        var endMonthKey = year + '-' + (endMonth < 10 ? '0' + endMonth : endMonth);
        
        for (var j = 0; j < monthKeys.length; j++) {
          if (monthKeys[j] <= endMonthKey) {
            cumulativeGoal += monthlyGoals[monthKeys[j]] || 0;
          }
        }
        
      } else if (currentSortKey.match(/^\d{4}$/)) {
        // Yearly bucket - sum all months for that year
        var year = currentSortKey;
        for (var j = 0; j < monthKeys.length; j++) {
          if (monthKeys[j].startsWith(year)) {
            cumulativeGoal += monthlyGoals[monthKeys[j]] || 0;
          }
        }
        
      } else if (currentSortKey.match(/^\d{4}-\d{2}$/)) {
        // Monthly bucket - sum all months up to and including this month
        for (var j = 0; j < monthKeys.length; j++) {
          if (monthKeys[j] <= currentSortKey) {
            cumulativeGoal += monthlyGoals[monthKeys[j]] || 0;
          }
        }
        
      } else {
        // Daily view (yyyy-MM-dd) - use helper function
        cumulativeGoal = getCumulativeGoalForDate(currentSortKey);
      }
      
      cumulativeGoals.push(cumulativeGoal);
    }
    
    renderScrapChart(labels, data, cumulativeData, goalData, cumulativeGoals, sortDates);
  }
  
  function aggregateScrapByDrillLevel(labels, sortDates, data, goals, level) {
    var buckets = {};
    
    for (var i = 0; i < labels.length; i++) {
      var date = sortDates[i] || labels[i];
      var bucketKey = getBucketKey(date, level);
      
      if (!buckets[bucketKey]) {
        buckets[bucketKey] = { label: getBucketLabel(date, level), sortKey: bucketKey, value: 0, goal: 0 };
      }
      buckets[bucketKey].value += data[i] || 0;
      buckets[bucketKey].goal += goals[i] || 0;
    }
    
    var sortedKeys = Object.keys(buckets).sort();
    var result = { labels: [], sortDates: [], data: [], goals: [] };
    
    sortedKeys.forEach(function(key) {
      result.labels.push(buckets[key].label);
      result.sortDates.push(buckets[key].sortKey);
      result.data.push(buckets[key].value);
      result.goals.push(buckets[key].goal);
    });
    
    return result;
  }
  
  function renderScrapChart(labels, data, cumulativeData, goalData, cumulativeGoals, sortDates) {
    var colors = getColors();
    var dark = isDarkMode();
    var modernFont = "'Segoe UI', 'Inter', -apple-system, sans-serif";
    
    // Get dynamic font sizes based on focus state
    var fontSizes = getChartFontSizes('scrapDailyPanel');
    
    var scrollWrapper = document.getElementById('scrapScrollWrapper');
    var scrollInner = document.getElementById('scrapScrollInner');
    var canvas = document.getElementById('scrapDailyChart');
    
    if (scrapDailyChart) scrapDailyChart.destroy();
    
    if (!labels.length) {
      scrollInner.innerHTML = '<div style="display:flex;align-items:center;justify-content:center;height:100%;color:' + colors.textSec + ';font-size:11px;font-style:italic;">No scrap data for selected period</div>';
      return;
    }
    
    if (!document.getElementById('scrapDailyChart')) {
      scrollInner.innerHTML = '<canvas id="scrapDailyChart"></canvas>';
      canvas = document.getElementById('scrapDailyChart');
    }
    
    var ctx = canvas.getContext('2d');
    
    // Calculate width based on data points
    var maxVisibleColumns = 25;
    var minColumnWidth = 35;
    
    if (labels.length > maxVisibleColumns) {
      var neededWidth = labels.length * minColumnWidth;
      scrollInner.style.width = neededWidth + 'px';
    } else {
      scrollInner.style.width = '100%';
    }
    
    Chart.register(ChartDataLabels);
    
    // Colors
    var monthGoalLineColor = '#ef4444'; // Red dotted line for whole month goal
    var cumulativeGoalLineColor = dark ? 'rgba(120,120,120,0.7)' : 'rgba(100,100,100,0.6)'; // Gray dotted line for cumulative goal
    var dailyLineColor = '#f97316'; // Orange solid line for daily values
    
    // Calculate month goal - get from hfScrapGoal (this is now the full month goal)
    var monthGoalTotal = parseFloat(document.getElementById('<%= hfScrapGoal.ClientID %>').value) || 0;
    
    // Create flat array for month goal line (same value for all points)
    var monthGoalData = labels.map(function() { return monthGoalTotal; });
    
    // Color BARS (cumulative) based on cumulative scrap vs cumulative goal comparison
    // Green if accumulated scrap is at or below accumulated goal, red if over
    var barColors = cumulativeData.map(function(cumVal, idx) {
      var accumulatedGoal = cumulativeGoals[idx] || 0;
      if (accumulatedGoal === 0) return 'rgba(16,185,129,0.7)'; // Default green if no goal
      return cumVal <= accumulatedGoal ? 'rgba(16,185,129,0.7)' : 'rgba(239,68,68,0.7)'; // green or red
    });
    
    var barBorderColors = cumulativeData.map(function(cumVal, idx) {
      var accumulatedGoal = cumulativeGoals[idx] || 0;
      if (accumulatedGoal === 0) return '#10b981';
      return cumVal <= accumulatedGoal ? '#10b981' : '#ef4444';
    });
    
    // Determine Y-axis max - use cumulative goal as baseline, but if scrap exceeds it, use scrap
    var maxCumulativeGoal = cumulativeGoals.length ? Math.max.apply(null, cumulativeGoals) : 0;
    var maxCumulative = cumulativeData.length ? Math.max.apply(null, cumulativeData) : 0;
    // Y-axis should be controlled by cumulative goal, unless cumulative scrap surpasses it
    var yMax = Math.max(maxCumulativeGoal, maxCumulative) * 1.15;
    
    // Chart shows:
    // 1. BARS for CUMULATIVE scrap values (green if under cumulative goal, red if over)
    // 2. ORANGE solid LINE for DAILY scrap values
    // 3. RED dotted horizontal line for Month Goal (whole month)
    // 4. GRAY dotted line for Cumulative Goal (grows daily)
    var datasets = [
      {
        label: 'Cumulative',
        data: cumulativeData,
        type: 'bar',
        backgroundColor: barColors,
        borderColor: barBorderColors,
        borderWidth: 0,
        borderRadius: 4,
        yAxisID: 'y',
        order: 3,
        datalabels: {
          display: true,
          anchor: 'end',
          align: 'top',
          color: function(ctx) {
            var cumVal = cumulativeData[ctx.dataIndex] || 0;
            var cumGoal = cumulativeGoals[ctx.dataIndex] || 0;
            if (cumGoal === 0) return '#10b981';
            return cumVal <= cumGoal ? '#10b981' : '#ef4444';
          },
          font: { size: fontSizes.dataLabel - 3, weight: '600', family: modernFont },
          formatter: function(value) { 
            if (value >= 1000) return '$' + (value/1000).toFixed(2) + 'K';
            return '$' + value.toFixed(1);
          }
        }
      },
      {
        label: 'Daily',
        data: data,
        type: 'line',
        borderColor: dailyLineColor,
        backgroundColor: 'rgba(249,115,22,0.1)',
        borderWidth: 2.5,
        pointRadius: 3,
        pointBackgroundColor: dailyLineColor,
        pointBorderColor: dark ? '#1a1a1a' : '#fff',
        pointBorderWidth: 1.5,
        fill: false,
        tension: 0.2,
        yAxisID: 'y',
        datalabels: { display: false },
        order: 0
      },
      {
        label: 'Cum. Goal',
        data: cumulativeGoals,
        type: 'line',
        borderColor: cumulativeGoalLineColor,
        borderDash: [5, 3],
        borderWidth: 2,
        pointRadius: 0,
        fill: false,
        yAxisID: 'y',
        datalabels: { display: false },
        order: 1
      }
    ];
    
    // Store goalData for tooltip access
    window.scrapGoalData = goalData;
    window.scrapCumulativeData = cumulativeData;
    window.scrapCumulativeGoals = cumulativeGoals;
    window.scrapDailyData = data;
    window.scrapMonthGoal = monthGoalTotal;
    
    scrapDailyChart = new Chart(ctx, {
      type: 'bar',
      data: {
        labels: labels,
        datasets: datasets
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        layout: { padding: { top: 20, right: 8 } },
        interaction: { mode: 'index', intersect: false },
        scales: {
          y: { 
            display: false,
            min: 0,
            max: yMax
          },
          x: {
            grid: { display: false },
            ticks: { color: colors.textSec, font: { size: fontSizes.tick, family: modernFont } }
          }
        },
        plugins: {
          legend: { display: false },
          tooltip: {
            enabled: false,
            external: function(context) {
              var tooltip = document.getElementById('scrapTooltip');
              if (!tooltip) return;
              
              if (context.tooltip.opacity === 0) {
                tooltip.classList.remove('visible');
                return;
              }
              
              var dataIndex = context.tooltip.dataPoints ? context.tooltip.dataPoints[0].dataIndex : 0;
              var scrapVal = window.scrapDailyData[dataIndex] || 0;
              var dailyGoal = window.scrapGoalData[dataIndex] || 0;
              var cumulative = window.scrapCumulativeData[dataIndex] || 0;
              var cumGoal = window.scrapCumulativeGoals[dataIndex] || 0;
              var monthGoal = window.scrapMonthGoal || 0;
              var cumVariance = cumGoal - cumulative; // positive = under budget (good)
              var monthVariance = monthGoal - cumulative; // positive = under budget (good)
              var isUnderGoal = cumulative <= cumGoal;
              
              document.getElementById('scrapTooltipTitle').textContent = context.tooltip.title[0] || '';
              
              // Scrap value - always orange
              var scrapValEl = document.getElementById('scrapTooltipValue');
              scrapValEl.textContent = formatCurrency(scrapVal);
              scrapValEl.className = 'chart-tooltip-value scrap-orange';
              
              // Cumulative - green if under goal, red if over
              var cumEl = document.getElementById('scrapTooltipCumulative');
              cumEl.textContent = formatCurrency(cumulative);
              cumEl.className = 'chart-tooltip-value ' + (isUnderGoal || cumGoal === 0 ? 'text-green' : 'text-red');
              
              document.getElementById('scrapTooltipCumulativeGoal').textContent = formatCurrency(cumGoal);
              
              // Cumulative Variance - green if positive (under budget), red if negative (over budget)
              var cumVarEl = document.getElementById('scrapTooltipCumulativeVar');
              cumVarEl.textContent = (cumVariance >= 0 ? '+' : '-') + formatCurrency(Math.abs(cumVariance));
              cumVarEl.className = 'chart-tooltip-value ' + (cumVariance >= 0 ? 'text-green' : 'text-red');
              
              document.getElementById('scrapTooltipMonthGoal').textContent = formatCurrency(monthGoal);
              
              // Month Variance - green if positive (under budget), red if negative (over budget)
              var monthVarEl = document.getElementById('scrapTooltipMonthVar');
              monthVarEl.textContent = (monthVariance >= 0 ? '+' : '-') + formatCurrency(Math.abs(monthVariance));
              monthVarEl.className = 'chart-tooltip-value ' + (monthVariance >= 0 ? 'text-green' : 'text-red');
              
              // Position tooltip - show above if near bottom of screen
              var position = context.chart.canvas.getBoundingClientRect();
              var tooltipContent = tooltip.querySelector('.chart-tooltip-content');
              var tooltipHeight = tooltipContent ? tooltipContent.offsetHeight : 180;
              var tooltipX = position.left + window.pageXOffset + context.tooltip.caretX;
              var tooltipY = position.top + window.pageYOffset + context.tooltip.caretY;
              
              // Check if tooltip would go below viewport
              if (tooltipY + tooltipHeight + 20 > window.innerHeight + window.pageYOffset) {
                // Position above the point
                tooltipY = tooltipY - tooltipHeight - 20;
              } else {
                tooltipY = tooltipY - 10;
              }
              
              tooltip.style.left = tooltipX + 'px';
              tooltip.style.top = tooltipY + 'px';
              tooltip.classList.add('visible');
            }
          },
          datalabels: {
            display: false // Datalabels configured per-dataset
          }
        }
      }
    });
    
    updateScrapDrillButtons();
  }
  
  function setScrapChartType(type) {
    currentScrapType = type;
    var btns = document.querySelectorAll('#scrapChartToggle button');
    btns.forEach(function(b) { b.classList.remove('active'); });
    var idx = type === 'cumulative' ? 0 : 1;
    btns[idx].classList.add('active');
    
    var scrollWrapper = document.getElementById('scrapScrollWrapper');
    var tableView = document.getElementById('scrapTableView');
    
    if (type === 'table') {
      scrollWrapper.style.display = 'none';
      tableView.style.display = 'block';
      renderScrapTableView();
    } else {
      scrollWrapper.style.display = 'block';
      tableView.style.display = 'none';
      aggregateAndRenderScrapChart();
    }
    
    // Update chart title
    var title = document.getElementById('scrapChartTitle');
    var levelLabel = currentScrapDrillLevel.charAt(0).toUpperCase() + currentScrapDrillLevel.slice(1);
    title.textContent = 'Scrap ' + levelLabel;
  }
  
  function renderScrapTableView() {
    var lineDateData = JSON.parse(document.getElementById('<%= hfScrapByLineDateData.ClientID %>').value || '[]');
    var scrapGoal = parseFloat(document.getElementById('<%= hfScrapGoal.ClientID %>').value) || 0;
    var monthlyGoals = JSON.parse(document.getElementById('<%= hfScrapMonthlyGoals.ClientID %>').value || '{}');
    var lineMonthlyGoals = JSON.parse(document.getElementById('<%= hfScrapLineMonthlyGoals.ClientID %>').value || '{}');
    var selectedLine = document.getElementById('<%= ddlScrapLine.ClientID %>').value;
    
    var tableView = document.getElementById('scrapTableView');
    
    if (!lineDateData.length) {
      tableView.innerHTML = '<div style="display:flex;align-items:center;justify-content:center;height:100%;color:rgba(0,0,0,0.4);font-size:11px;font-style:italic;">No scrap data available</div>';
      return;
    }
    
    // Helper function to get monthly goal for a specific line
    function getMonthlyGoalForLine(lineName, monthKey) {
      if (selectedLine === 'ALL' && lineMonthlyGoals[lineName] && lineMonthlyGoals[lineName][monthKey]) {
        return lineMonthlyGoals[lineName][monthKey];
      } else if (monthlyGoals[monthKey]) {
        return monthlyGoals[monthKey];
      }
      return 0;
    }
    
    // Helper to get cumulative goal up to a specific day in the month
    function getCumulativeGoalForDay(lineName, sortKey) {
      if (!sortKey) return 0;
      var monthKey = sortKey.substring(0, 7); // yyyy-MM
      var year = parseInt(sortKey.substring(0, 4));
      var month = parseInt(sortKey.substring(5, 7));
      var day = parseInt(sortKey.substring(8, 10)) || 1;
      var daysInMonth = new Date(year, month, 0).getDate();
      var monthlyGoal = getMonthlyGoalForLine(lineName, monthKey);
      var dailyGoal = daysInMonth > 0 ? monthlyGoal / daysInMonth : 0;
      return dailyGoal * day;
    }
    
    // Helper to get period goal based on drill level
    function getPeriodGoal(lineName, sortKey, drillLevel) {
      if (!sortKey) return 0;
      var monthKey = sortKey.substring(0, 7);
      var year = parseInt(sortKey.substring(0, 4));
      var month = parseInt(sortKey.substring(5, 7));
      var day = parseInt(sortKey.substring(8, 10)) || 1;
      var daysInMonth = new Date(year, month, 0).getDate();
      var monthlyGoal = getMonthlyGoalForLine(lineName, monthKey);
      
      if (drillLevel === 'daily') {
        return monthlyGoal / daysInMonth;
      } else if (drillLevel === 'weekly') {
        return (monthlyGoal / daysInMonth) * 7;
      } else if (drillLevel === 'monthly') {
        return monthlyGoal;
      } else if (drillLevel === 'quarterly') {
        return monthlyGoal * 3;
      } else if (drillLevel === 'yearly') {
        return monthlyGoal * 12;
      }
      return monthlyGoal;
    }
    
    // Build a pivot table: Lines as rows, Dates (aggregated by drill level) as columns
    var lines = [];
    var dateMap = {}; // date -> { line -> amount }
    
    lineDateData.forEach(function(row) {
      if (lines.indexOf(row.line) === -1) lines.push(row.line);
      
      // Aggregate date based on current drill level
      var bucketLabel = aggregateDateLabel(row.date, row.dateSort, currentScrapDrillLevel);
      
      if (!dateMap[bucketLabel]) {
        dateMap[bucketLabel] = { sortKey: row.dateSort };
      }
      if (!dateMap[bucketLabel][row.line]) {
        dateMap[bucketLabel][row.line] = 0;
      }
      dateMap[bucketLabel][row.line] += row.amount;
    });
    
    // Sort lines alphabetically
    lines.sort();
    
    // Get sorted date columns
    var dateCols = Object.keys(dateMap).sort(function(a, b) {
      return dateMap[a].sortKey.localeCompare(dateMap[b].sortKey);
    });
    
    if (!dateCols.length) {
      tableView.innerHTML = '<div style="display:flex;align-items:center;justify-content:center;height:100%;color:rgba(0,0,0,0.4);font-size:11px;font-style:italic;">No scrap data available</div>';
      return;
    }
    
    // Pre-calculate cumulative data per line for coloring and tooltips
    var lineCumulatives = {};
    lines.forEach(function(lineName) {
      lineCumulatives[lineName] = {};
      var cumulative = 0;
      dateCols.forEach(function(col) {
        var amount = dateMap[col][lineName] || 0;
        cumulative += amount;
        lineCumulatives[lineName][col] = cumulative;
      });
    });
    
    // Build table HTML with data attributes for tooltips
    var html = '<table><thead><tr><th>Line</th>';
    dateCols.forEach(function(col) {
      html += '<th>' + col + '</th>';
    });
    html += '<th>Total</th></tr></thead><tbody>';
    
    // Column totals for footer
    var colTotals = {};
    dateCols.forEach(function(col) { colTotals[col] = 0; });
    var grandTotal = 0;
    
    lines.forEach(function(lineName) {
      var lineTotal = 0;
      html += '<tr><td>' + lineName + '</td>';
      
      dateCols.forEach(function(col) {
        var amount = dateMap[col][lineName] || 0;
        if (amount > 0) {
          var sortKey = dateMap[col].sortKey || '';
          var cumulativeScrap = lineCumulatives[lineName][col] || 0;
          // Use getCumulativeGoalForDay to calculate cumulative goal correctly (daily goal × day of month)
          var cumulativeGoal = getCumulativeGoalForDay(lineName, sortKey);
          var cumVariance = cumulativeGoal - cumulativeScrap; // positive = under budget
          var monthKey = sortKey.substring(0, 7);
          var monthGoal = getMonthlyGoalForLine(lineName, monthKey);
          var monthVariance = monthGoal - cumulativeScrap; // positive = under budget
          
          var cellClass = cumulativeGoal > 0 ? (cumulativeScrap <= cumulativeGoal ? 'cell-good' : 'cell-bad') : '';
          
          // Add data attributes for tooltip
          html += '<td class="scrap-cell-hover ' + cellClass + '" ';
          html += 'data-line="' + lineName + '" ';
          html += 'data-col="' + col + '" ';
          html += 'data-amount="' + amount.toFixed(2) + '" ';
          html += 'data-cumulative="' + cumulativeScrap.toFixed(2) + '" ';
          html += 'data-cumgoal="' + cumulativeGoal.toFixed(2) + '" ';
          html += 'data-cumvar="' + cumVariance.toFixed(2) + '" ';
          html += 'data-monthgoal="' + monthGoal.toFixed(2) + '" ';
          html += 'data-monthvar="' + monthVariance.toFixed(2) + '">';
          html += formatCurrency(amount) + '</td>';
          
          lineTotal += amount;
          colTotals[col] += amount;
        } else {
          html += '<td>-</td>';
        }
      });
      
      // Line total - evaluate against Month Goal
      var lastSortKey = dateMap[dateCols[dateCols.length - 1]] ? dateMap[dateCols[dateCols.length - 1]].sortKey : '';
      var lastMonthKey = lastSortKey.substring(0, 7);
      var lineMonthGoal = getMonthlyGoalForLine(lineName, lastMonthKey);
      var lineTotalClass = lineMonthGoal > 0 ? (lineTotal <= lineMonthGoal ? 'cell-good' : 'cell-bad') : 'cell-bad';
      html += '<td class="' + lineTotalClass + '"><strong>' + formatCurrency(lineTotal) + '</strong></td>';
      html += '</tr>';
      
      grandTotal += lineTotal;
    });
    
    // Footer row with column totals
    html += '</tbody><tfoot><tr><td><strong>Total</strong></td>';
    dateCols.forEach(function(col) {
      html += '<td><strong>' + formatCurrency(colTotals[col]) + '</strong></td>';
    });
    html += '<td><strong>' + formatCurrency(grandTotal) + '</strong></td>';
    html += '</tr></tfoot></table>';
    
    tableView.innerHTML = html;
    
    // Attach tooltip event handlers
    attachScrapTableTooltips();
  }
  
  function attachScrapTableTooltips() {
    var tooltip = document.getElementById('scrapTableTooltip');
    var cells = document.querySelectorAll('.scrap-cell-hover');
    
    cells.forEach(function(cell) {
      cell.addEventListener('mouseenter', function(e) {
        var line = cell.dataset.line;
        var col = cell.dataset.col;
        var amount = parseFloat(cell.dataset.amount) || 0;
        var cumulative = parseFloat(cell.dataset.cumulative) || 0;
        var cumGoal = parseFloat(cell.dataset.cumgoal) || 0;
        var cumVar = parseFloat(cell.dataset.cumvar) || 0;
        var monthGoal = parseFloat(cell.dataset.monthgoal) || 0;
        var monthVar = parseFloat(cell.dataset.monthvar) || 0;
        var isUnderCumGoal = cumulative <= cumGoal;
        
        // Update tooltip content
        document.getElementById('scrapTableTooltipTitle').textContent = line + ' - ' + col;
        document.getElementById('scrapTableTooltipValue').textContent = formatCurrency(amount);
        
        // Cumulative - green if under goal, red if over
        var cumEl = document.getElementById('scrapTableTooltipCumulative');
        cumEl.textContent = formatCurrency(cumulative);
        cumEl.className = 'chart-tooltip-value ' + (isUnderCumGoal ? 'text-green' : 'text-red');
        
        document.getElementById('scrapTableTooltipCumulativeGoal').textContent = formatCurrency(cumGoal);
        
        // Cumulative Variance - green if positive (under budget), red if negative (over budget)
        var cumVarEl = document.getElementById('scrapTableTooltipCumulativeVar');
        cumVarEl.textContent = (cumVar >= 0 ? '+' : '-') + formatCurrency(Math.abs(cumVar));
        cumVarEl.className = 'chart-tooltip-value ' + (cumVar >= 0 ? 'text-green' : 'text-red');
        
        document.getElementById('scrapTableTooltipMonthGoal').textContent = formatCurrency(monthGoal);
        
        // Month Variance - green if positive (under budget), red if negative (over budget)
        var monthVarEl = document.getElementById('scrapTableTooltipMonthVar');
        monthVarEl.textContent = (monthVar >= 0 ? '+' : '-') + formatCurrency(Math.abs(monthVar));
        monthVarEl.className = 'chart-tooltip-value ' + (monthVar >= 0 ? 'text-green' : 'text-red');
        
        // Position tooltip
        var rect = cell.getBoundingClientRect();
        tooltip.style.left = (rect.left + rect.width / 2) + 'px';
        tooltip.style.top = (rect.top - 10) + 'px';
        tooltip.style.transform = 'translate(-50%, -100%)';
        tooltip.classList.add('visible');
      });
      
      cell.addEventListener('mouseleave', function() {
        tooltip.classList.remove('visible');
      });
    });
  }
  
  function scrapDrillDown() {
    var levels = ['yearly', 'quarterly', 'monthly', 'weekly', 'daily'];
    var idx = levels.indexOf(currentScrapDrillLevel);
    if (idx < levels.length - 1) {
      currentScrapDrillLevel = levels[idx + 1];
      var title = document.getElementById('scrapChartTitle');
      title.textContent = 'Scrap ' + currentScrapDrillLevel.charAt(0).toUpperCase() + currentScrapDrillLevel.slice(1);
      
      // Update both chart and table based on current view
      if (currentScrapType === 'table') {
        renderScrapTableView();
      } else {
        aggregateAndRenderScrapChart();
      }
    }
  }
  
  function scrapDrillUp() {
    var levels = ['yearly', 'quarterly', 'monthly', 'weekly', 'daily'];
    var idx = levels.indexOf(currentScrapDrillLevel);
    if (idx > 0) {
      currentScrapDrillLevel = levels[idx - 1];
      var title = document.getElementById('scrapChartTitle');
      title.textContent = 'Scrap ' + currentScrapDrillLevel.charAt(0).toUpperCase() + currentScrapDrillLevel.slice(1);
      
      // Update both chart and table based on current view
      if (currentScrapType === 'table') {
        renderScrapTableView();
      } else {
        aggregateAndRenderScrapChart();
      }
    }
  }
  
  function updateScrapDrillButtons() {
    var levels = ['yearly', 'quarterly', 'monthly', 'weekly', 'daily'];
    var idx = levels.indexOf(currentScrapDrillLevel);
    
    var downBtn = document.getElementById('scrapDrillDownBtn');
    var upBtn = document.getElementById('scrapDrillUpBtn');
    
    if (downBtn) downBtn.style.display = idx < levels.length - 1 ? 'flex' : 'none';
    if (upBtn) upBtn.style.display = idx > 0 ? 'flex' : 'none';
  }
  
  // Top Scraped Items Chart
  function initTopScrapChart() {
    var topItems = JSON.parse(document.getElementById('<%= hfTopScrapItems.ClientID %>').value || '[]');
    var colors = getColors();
    var dark = isDarkMode();
    var modernFont = "'Segoe UI', 'Inter', -apple-system, sans-serif";
    
    var canvas = document.getElementById('topScrapChart');
    if (!canvas) return; // Canvas not visible yet
    
    var container = canvas.parentElement;
    
    if (topScrapChart) topScrapChart.destroy();
    
    if (!topItems.length) {
      canvas.style.display = 'none';
      if (container && !container.querySelector('.no-data-msg')) {
        var msg = document.createElement('div');
        msg.className = 'no-data-msg';
        msg.style.cssText = 'display:flex;align-items:center;justify-content:center;height:100%;color:' + colors.textSec + ';font-size:11px;font-style:italic;position:absolute;top:0;left:0;right:0;bottom:0;';
        msg.textContent = 'No scrap data for selected period';
        container.appendChild(msg);
      }
      return;
    }
    
    // Remove any no-data message
    var noDataMsg = container ? container.querySelector('.no-data-msg') : null;
    if (noDataMsg) noDataMsg.remove();
    
    canvas.style.display = 'block';
    
    var labels = topItems.map(function(item) { 
      var desc = item.description || item.material;
      return desc.length > 20 ? desc.substring(0, 17) + '...' : desc;
    });
    var data = topItems.map(function(item) { return item.amount; });
    
    var ctx = canvas.getContext('2d');
    
    topScrapChart = new Chart(ctx, {
      type: 'bar',
      data: {
        labels: labels,
        datasets: [{
          label: 'Scrap Cost',
          data: data,
          backgroundColor: [
            'rgba(249,115,22,0.9)',
            'rgba(251,146,60,0.85)',
            'rgba(253,186,116,0.8)',
            'rgba(254,215,170,0.75)',
            'rgba(255,237,213,0.7)'
          ],
          borderColor: '#ea580c',
          borderWidth: 0,
          borderRadius: 4
        }]
      },
      options: {
        indexAxis: 'y',
        responsive: true,
        maintainAspectRatio: false,
        layout: { padding: { right: 50 } },
        scales: {
          x: {
            display: false
          },
          y: {
            grid: { display: false },
            ticks: { 
              color: colors.text, 
              font: { size: 9, family: modernFont },
              padding: 4
            }
          }
        },
        plugins: {
          legend: { display: false },
          tooltip: {
            backgroundColor: dark ? 'rgba(30,30,30,0.95)' : 'rgba(255,255,255,0.98)',
            titleColor: dark ? '#fff' : '#1b222b',
            bodyColor: dark ? 'rgba(255,255,255,0.8)' : 'rgba(0,0,0,0.7)',
            borderColor: dark ? 'rgba(255,255,255,0.1)' : 'rgba(0,0,0,0.1)',
            borderWidth: 1,
            padding: 12,
            displayColors: false,
            callbacks: {
              title: function(ctx) {
                var idx = ctx[0].dataIndex;
                return topItems[idx].description || topItems[idx].material;
              },
              label: function(ctx) {
                return 'Cost: ' + formatCurrency(ctx.parsed.x);
              },
              afterLabel: function(ctx) {
                var idx = ctx.dataIndex;
                return 'Material: ' + (topItems[idx].material || 'N/A');
              }
            }
          },
          datalabels: {
            anchor: 'end',
            align: 'right',
            color: colors.text,
            font: { size: 9, weight: '600', family: modernFont },
            formatter: function(value) { return formatCurrency(value); }
          }
        }
      }
    });
  }
  
  // ========== NCM ANALYSIS CHARTS ==========
  var ncmBarChart = null;
  var currentNCMType = 'table';
  
  function initNCMCharts() {
    var ncmValue = parseFloat(document.getElementById('<%= hfNCMTotalValue.ClientID %>').value) || 0;
    var ncmGoal = parseFloat(document.getElementById('<%= hfNCMGoal.ClientID %>').value) || 75000;
    var ncmDataDate = document.getElementById('<%= hfNCMDataDate.ClientID %>').value || '';
    var topMaterials = JSON.parse(document.getElementById('<%= hfNCMTopMaterials.ClientID %>').value || '[]');
    
    // Update subtitle with data date
    var subtitle = document.getElementById('ncmSubtitle');
    if (subtitle) {
      if (ncmDataDate) {
        subtitle.textContent = 'Data as of ' + ncmDataDate;
      } else {
        var today = new Date();
        subtitle.textContent = 'Data as of ' + today.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
      }
    }
    
    // Initialize based on current view type
    if (currentNCMType === 'table') {
      renderNCMTableView();
    } else {
      initNCMGaugeSvg(ncmValue, ncmGoal);
      initNCMBarChart(topMaterials);
    }
  }
  
  function initNCMGaugeSvg(value, goal) {
    var svg = document.getElementById('ncmGaugeSvg');
    if (!svg) return;
    
    var colors = getColors();
    var pctOfGoal = goal > 0 ? (value / goal * 100) : 0;
    
    // Dynamic max: if over goal, max = value * 1.1, else max = goal * 1.1
    // This ensures the gauge never fills 100%
    var maxValue = value > goal ? value * 1.1 : goal * 1.1;
    var pctOfMax = maxValue > 0 ? (value / maxValue * 100) : 0;
    var goalPctOfMax = maxValue > 0 ? (goal / maxValue * 100) : 0;
    
    // Update value display
    var valueDisplay = document.getElementById('ncmGaugeValueDisplay');
    if (valueDisplay) {
      valueDisplay.innerHTML = formatCurrency(value);
      valueDisplay.classList.remove('under-goal', 'over-goal');
      valueDisplay.classList.add(pctOfGoal <= 100 ? 'under-goal' : 'over-goal');
    }
    
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
    
    // Value arc - use pctOfMax for dynamic scaling
    if (value > 0) {
      var valueAngle = startAngle + (pctOfMax / 100) * angleRange;
      var valuePath = describeArc(cx, cy, r, startAngle, valueAngle);
      var valueArc = document.createElementNS('http://www.w3.org/2000/svg', 'path');
      valueArc.setAttribute('d', valuePath);
      valueArc.setAttribute('fill', 'none');
      // Green if under goal, red if over goal
      var gaugeColor = pctOfGoal <= 100 ? colors.success : colors.danger;
      valueArc.setAttribute('stroke', gaugeColor);
      valueArc.setAttribute('stroke-width', '26');
      valueArc.setAttribute('stroke-linecap', 'butt');
      svg.appendChild(valueArc);
    }
    
    // Goal indicator - positioned based on goalPctOfMax
    var goalLineColor = isDarkMode() ? 'rgba(180,180,180,0.9)' : 'rgba(80,80,80,0.8)';
    var goalAngle = startAngle + (goalPctOfMax / 100) * angleRange;
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
    
    // Goal label - positioned at the outer tip of the goal line
    var labelOffsetX = 4 * Math.cos(goalAngle);
    var labelOffsetY = -12; // Always show above the line
    var labelX = gx2 + labelOffsetX;
    var labelY = gy2 + labelOffsetY;
    // Keep label within SVG bounds
    labelX = Math.max(30, Math.min(190, labelX));
    labelY = Math.max(12, Math.min(105, labelY));
    var goalLabel = document.createElementNS('http://www.w3.org/2000/svg', 'text');
    goalLabel.setAttribute('x', labelX);
    goalLabel.setAttribute('y', labelY);
    goalLabel.setAttribute('fill', goalLineColor);
    goalLabel.setAttribute('font-size', '9');
    goalLabel.setAttribute('font-weight', '600');
    goalLabel.setAttribute('text-anchor', labelX > cx ? 'start' : 'end');
    goalLabel.textContent = formatCurrency(goal);
    svg.appendChild(goalLabel);
  }
  
  function initNCMBarChart(topMaterials, isFocusMode) {
    var canvas = document.getElementById('ncmBarChart');
    if (!canvas) return;
    
    var colors = getColors();
    var dark = isDarkMode();
    var modernFont = "'Segoe UI', 'Inter', -apple-system, sans-serif";
    
    // Determine if in focus mode and get dynamic font sizes
    var ncmPanel = document.getElementById('ncmPanel');
    var inFocus = isFocusMode || (ncmPanel && ncmPanel.classList.contains('focused'));
    var fontSizes = getChartFontSizes('ncmPanel');
    
    if (ncmBarChart) ncmBarChart.destroy();
    
    if (!topMaterials || !topMaterials.length) {
      canvas.style.display = 'none';
      var container = canvas.parentElement;
      if (container && !container.querySelector('.no-data-msg')) {
        var msg = document.createElement('div');
        msg.className = 'no-data-msg';
        msg.style.cssText = 'display:flex;align-items:center;justify-content:center;height:100%;color:' + colors.textSec + ';font-size:11px;font-style:italic;';
        msg.textContent = 'No NCM data available';
        container.appendChild(msg);
      }
      return;
    }
    
    // Remove any no-data message
    var noDataMsg = canvas.parentElement ? canvas.parentElement.querySelector('.no-data-msg') : null;
    if (noDataMsg) noDataMsg.remove();
    canvas.style.display = 'block';
    
    // In focus mode, show top 15; otherwise top 5
    var itemCount = inFocus ? 15 : 5;
    var topItems = topMaterials.slice(0, itemCount);
    
    var labels = topItems.map(function(item) {
      var mat = item.materialNumber || item.material || '';
      return mat.length > 18 ? mat.substring(0, 15) + '...' : mat;
    });
    var data = topItems.map(function(item) { return item.totalValue || item.value || 0; });
    
    // Generate gradient colors
    var barColors = topItems.map(function(_, idx) {
      var alpha = Math.max(0.5, 0.95 - (idx * 0.03));
      return 'rgba(245,158,11,' + alpha + ')';
    });
    
    // Font sizes from helper
    var labelFontSize = fontSizes.label;
    var dataLabelFontSize = fontSizes.dataLabel;
    
    var ctx = canvas.getContext('2d');
    
    ncmBarChart = new Chart(ctx, {
      type: 'bar',
      data: {
        labels: labels,
        datasets: [{
          label: 'Total Value',
          data: data,
          backgroundColor: barColors,
          borderColor: '#d97706',
          borderWidth: 0,
          borderRadius: 4
        }]
      },
      options: {
        indexAxis: 'y',
        responsive: true,
        maintainAspectRatio: false,
        layout: { padding: { right: 65 } },
        scales: {
          x: { display: false },
          y: {
            grid: { display: false },
            ticks: {
              color: colors.text,
              font: { size: labelFontSize, weight: '500', family: modernFont },
              padding: 4
            }
          }
        },
        plugins: {
          legend: { display: false },
          tooltip: {
            backgroundColor: dark ? 'rgba(30,30,30,0.95)' : 'rgba(255,255,255,0.98)',
            titleColor: dark ? '#fff' : '#1b222b',
            bodyColor: dark ? 'rgba(255,255,255,0.8)' : 'rgba(0,0,0,0.7)',
            borderColor: dark ? 'rgba(255,255,255,0.1)' : 'rgba(0,0,0,0.1)',
            borderWidth: 1,
            padding: 10,
            displayColors: false,
            callbacks: {
              title: function(ctx) {
                var idx = ctx[0].dataIndex;
                return topItems[idx].materialNumber || topItems[idx].material || 'N/A';
              },
              label: function(ctx) {
                return 'Value: ' + formatCurrency(ctx.parsed.x);
              },
              afterLabel: function(ctx) {
                var idx = ctx.dataIndex;
                var desc = topItems[idx].materialDescription || topItems[idx].description || '';
                return desc ? desc.substring(0, 40) : '';
              }
            }
          },
          datalabels: {
            anchor: 'end',
            align: 'right',
            color: colors.text,
            font: { size: dataLabelFontSize, weight: '600', family: modernFont },
            formatter: function(value) { return formatCurrency(value); }
          }
        }
      }
    });
  }
  
  function setNCMChartType(type) {
    currentNCMType = type;
    var btns = document.querySelectorAll('#ncmToggle button');
    btns.forEach(function(b) { b.classList.remove('active'); });
    var idx = type === 'gauge' ? 0 : 1;
    btns[idx].classList.add('active');
    
    var gaugeView = document.getElementById('ncmGaugeView');
    var tableView = document.getElementById('ncmTableView');
    
    if (type === 'table') {
      gaugeView.style.display = 'none';
      tableView.style.display = 'block';
      renderNCMTableView();
    } else {
      gaugeView.style.display = 'flex';
      tableView.style.display = 'none';
    }
  }
  
  function renderNCMTableView() {
    var allMaterials = JSON.parse(document.getElementById('<%= hfNCMAllMaterials.ClientID %>').value || '[]');
    var ncmGoal = parseFloat(document.getElementById('<%= hfNCMGoal.ClientID %>').value) || 75000;
    var tableBody = document.getElementById('ncmTableBody');
    
    if (!tableBody) return;
    
    // Calculate total value
    var totalValue = 0;
    allMaterials.forEach(function(item) {
      totalValue += (item.totalValue || item.value || 0);
    });
    
    // Update bullet chart
    updateNCMBulletChart(totalValue, ncmGoal);
    
    if (!allMaterials.length) {
      tableBody.innerHTML = '<tr><td colspan="4" style="text-align:center;padding:20px;color:rgba(0,0,0,0.4);font-style:italic;">No NCM data available</td></tr>';
      return;
    }
    
    // Sort by total value descending
    allMaterials.sort(function(a, b) {
      return (b.totalValue || b.value || 0) - (a.totalValue || a.value || 0);
    });
    
    var html = '';
    allMaterials.forEach(function(item) {
      var mat = item.materialNumber || item.material || '';
      var desc = item.materialDescription || item.description || '';
      var val = item.totalValue || item.value || 0;
      var pct = totalValue > 0 ? (val / totalValue * 100) : 0;
      
      html += '<tr>';
      html += '<td>' + mat + '</td>';
      html += '<td title="' + desc.replace(/"/g, '&quot;') + '">' + (desc.length > 45 ? desc.substring(0, 42) + '...' : desc) + '</td>';
      html += '<td class="value-cell">' + formatCurrency(val) + '</td>';
      html += '<td class="pct-cell">' + pct.toFixed(2) + '%</td>';
      html += '</tr>';
    });
    
    tableBody.innerHTML = html;
  }
  
  function updateNCMBulletChart(value, goal) {
    var bulletValue = document.getElementById('ncmBulletValue');
    var bulletBar = document.getElementById('ncmBulletBar');
    var bulletGoal = document.getElementById('ncmBulletGoal');
    var bulletGoalLabel = document.getElementById('ncmBulletGoalLabel');
    
    if (!bulletValue || !bulletBar || !bulletGoal) return;
    
    var isOverGoal = value > goal;
    
    // Dynamic max: if over goal, max = value * 1.1, else max = goal * 1.1
    var maxValue = isOverGoal ? value * 1.1 : goal * 1.1;
    var barPct = maxValue > 0 ? (value / maxValue * 100) : 0;
    var goalPct = maxValue > 0 ? (goal / maxValue * 100) : 0;
    
    // Update value display
    bulletValue.textContent = formatCurrency(value);
    bulletValue.classList.remove('under-goal', 'over-goal');
    bulletValue.classList.add(isOverGoal ? 'over-goal' : 'under-goal');
    
    // Update bar
    bulletBar.style.width = barPct + '%';
    bulletBar.classList.remove('over-goal');
    if (isOverGoal) bulletBar.classList.add('over-goal');
    
    // Update goal indicator position
    bulletGoal.style.left = goalPct + '%';
    
    // Update goal label
    if (bulletGoalLabel) {
      bulletGoalLabel.textContent = 'Goal: ' + formatCurrency(goal);
    }
  }
  
  // Focus Mode Functions
  var currentFocusedPanel = null;
  var originalPanelStyles = null;
  
  function openFocusMode(panelId) {
    var panel = document.getElementById(panelId);
    var overlay = document.getElementById('focusOverlay');
    
    if (!panel || !overlay) return;
    
    // Store reference to focused panel
    currentFocusedPanel = panel;
    
    // Show overlay
    overlay.classList.add('active');
    
    // Add focused class to panel
    panel.classList.add('focused');
    
    // Prevent body scroll
    document.body.style.overflow = 'hidden';
    
    // Resize charts if needed
    setTimeout(function() {
      resizeChartsInPanel(panelId);
    }, 350);
    
    // Add escape key listener
    document.addEventListener('keydown', handleFocusEscape);
  }
  
  function closeFocusMode() {
    var overlay = document.getElementById('focusOverlay');
    
    if (!overlay) return;
    
    // Hide overlay
    overlay.classList.remove('active');
    
    // Remove focused class from panel
    if (currentFocusedPanel) {
      currentFocusedPanel.classList.remove('focused');
      
      // Resize charts back
      var panelId = currentFocusedPanel.id;
      setTimeout(function() {
        resizeChartsInPanel(panelId);
      }, 350);
      
      currentFocusedPanel = null;
    }
    
    // Restore body scroll
    document.body.style.overflow = '';
    
    // Remove escape key listener
    document.removeEventListener('keydown', handleFocusEscape);
  }
  
  function handleFocusEscape(e) {
    if (e.key === 'Escape') {
      closeFocusMode();
    }
  }
  
  function resizeChartsInPanel(panelId) {
    // Trigger chart resize for Chart.js charts
    if (typeof Chart !== 'undefined') {
      Chart.helpers.each(Chart.instances, function(instance) {
        var canvas = instance.canvas;
        if (canvas && document.getElementById(panelId).contains(canvas)) {
          instance.resize();
        }
      });
    }
    
    // Re-render charts/tables with focus-aware styling
    if (panelId === 'yieldGaugePanel') {
      if (typeof initYieldGauge === 'function') initYieldGauge();
      if (typeof initYieldGaugeLarge === 'function') initYieldGaugeLarge();
    } else if (panelId === 'yieldDailyPanel') {
      if (typeof initYieldDailyChart === 'function') initYieldDailyChart();
    } else if (panelId === 'scrapGaugePanel') {
      if (typeof initScrapGaugeSmall === 'function') initScrapGaugeSmall();
      if (typeof initScrapGaugeTopItems === 'function') initScrapGaugeTopItems();
    } else if (panelId === 'scrapDailyPanel') {
      if (typeof initScrapDailyChart === 'function') initScrapDailyChart();
    } else if (panelId === 'ncmPanel') {
      if (typeof initNCMCharts === 'function') initNCMCharts();
    } else if (panelId === 'failuresPanel') {
      if (currentFailureType === 'table') {
        if (typeof renderFailureTableView === 'function') renderFailureTableView();
      } else {
        if (typeof initFailureCategoryChart === 'function') initFailureCategoryChart();
      }
    }
  }
</script>
</asp:Content>
