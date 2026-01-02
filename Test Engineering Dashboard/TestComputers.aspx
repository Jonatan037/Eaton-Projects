<%@ Page Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="TestComputers.aspx.cs" Inherits="TED_TestComputers" Title="Test Computers - Test Engineering Dashboard" %>

<asp:Content ID="ComputersTitle" ContentPlaceHolderID="TitleContent" runat="server">Test Computers - Test Engineering</asp:Content>
<asp:Content ID="ComputersHead" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        /* Dark Theme (default) */
        :root {
            --bg-primary: #0a0e27;
            --bg-secondary: #13182d;
            --bg-tertiary: #1c2238;
            --text-primary: #e4e7f0;
            --text-secondary: #a8adbe;
            --text-muted: #6b7280;
            --border-color: rgba(99, 111, 145, 0.25);
            --accent-blue: #4d8dff;
            --accent-blue-hover: #3b7eef;
            --success-green: #10b981;
            --warning-amber: #f59e0b;
            --danger-red: #ef4444;
            --shadow-sm: 0 2px 8px -2px rgba(0, 0, 0, 0.3);
            --shadow-md: 0 4px 16px -4px rgba(0, 0, 0, 0.4);
            --shadow-lg: 0 12px 32px -8px rgba(0, 0, 0, 0.5);
        }

        /* Light Theme */
        body.light-theme {
            --bg-primary: #f9fafb;
            --bg-secondary: #ffffff;
            --bg-tertiary: #f3f4f6;
            --text-primary: #111827;
            --text-secondary: #4b5563;
            --text-muted: #9ca3af;
            --border-color: #e5e7eb;
            --shadow-sm: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
            --shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
            --shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            background: var(--bg-primary);
            color: var(--text-primary);
            line-height: 1.6;
            min-height: 100vh;
            transition: background-color 0.3s ease, color 0.3s ease;
        }

        .dashboard-container {
            display: flex;
            min-height: 100vh;
        }

        /* ===== SIDEBAR ===== */
        .sidebar {
            width: 280px;
            background: var(--bg-secondary);
            border-right: 1px solid var(--border-color);
            padding: 24px 0;
            position: fixed;
            left: 0;
            top: 0;
            bottom: 0;
            overflow-y: auto;
            transition: background-color 0.3s ease;
            z-index: 1000;
        }

        .sidebar-header {
            padding: 0 24px 24px;
            border-bottom: 1px solid var(--border-color);
            margin-bottom: 24px;
        }

        .logo {
            display: flex;
            align-items: center;
            gap: 12px;
            text-decoration: none;
        }

        .logo-icon {
            width: 40px;
            height: 40px;
            background: linear-gradient(135deg, #4d8dff, #3b7eef);
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
            font-weight: bold;
            color: white;
        }

        .logo-text h1 {
            font-size: 18px;
            font-weight: 700;
            color: var(--text-primary);
            line-height: 1.2;
        }

        .logo-text p {
            font-size: 12px;
            color: var(--text-muted);
        }

        .nav-section {
            padding: 0 16px;
            margin-bottom: 24px;
        }

        .nav-section-title {
            font-size: 11px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            color: var(--text-muted);
            padding: 0 12px 8px;
        }

        .nav-menu {
            list-style: none;
        }

        .nav-menu li {
            margin-bottom: 4px;
        }

        .nav-link {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 10px 12px;
            border-radius: 8px;
            text-decoration: none;
            color: var(--text-secondary);
            font-size: 14px;
            font-weight: 500;
            transition: all 0.2s ease;
        }

        .nav-link:hover {
            background: rgba(77, 141, 255, 0.1);
            color: var(--accent-blue);
        }

        .nav-link.active {
            background: linear-gradient(135deg, rgba(77, 141, 255, 0.15), rgba(59, 126, 239, 0.1));
            color: var(--accent-blue);
            font-weight: 600;
        }

        .nav-icon {
            font-size: 18px;
            width: 20px;
            text-align: center;
        }

        .sidebar-footer {
            position: absolute;
            bottom: 0;
            left: 0;
            right: 0;
            padding: 16px 24px;
            border-top: 1px solid var(--border-color);
            background: var(--bg-secondary);
        }

        .user-info {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 12px;
        }

        .user-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: linear-gradient(135deg, #4d8dff, #3b7eef);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 14px;
            font-weight: 600;
            color: white;
        }

        .user-details h4 {
            font-size: 14px;
            font-weight: 600;
            color: var(--text-primary);
        }

        .user-details p {
            font-size: 12px;
            color: var(--text-muted);
        }

        .theme-toggle {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 8px 12px;
            background: var(--bg-tertiary);
            border-radius: 8px;
            cursor: pointer;
            transition: background-color 0.2s ease;
        }

        .theme-toggle:hover {
            background: rgba(77, 141, 255, 0.1);
        }

        .theme-toggle span {
            font-size: 13px;
            color: var(--text-secondary);
        }

        /* ===== MAIN CONTENT ===== */
        .main-content {
            flex: 1;
            margin-left: 280px;
            padding: 32px 40px;
        }

        .page-header {
            margin-bottom: 32px;
        }

        .page-header h2 {
            font-size: 32px;
            font-weight: 700;
            color: var(--text-primary);
            margin-bottom: 8px;
        }

        .breadcrumb {
            font-size: 14px;
            color: var(--text-muted);
        }

        .breadcrumb a {
            color: var(--accent-blue);
            text-decoration: none;
        }

        /* ===== KPI CARDS ===== */
        .kpi-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 20px;
            margin-bottom: 32px;
        }

        .kpi-card {
            background: var(--bg-secondary);
            backdrop-filter: blur(10px);
            border: 1px solid var(--border-color);
            border-radius: 16px;
            padding: 24px;
            transition: all 0.3s ease;
            box-shadow: var(--shadow-sm);
        }

        .kpi-card:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-md);
        }

        /* Dark theme glassmorphism */
        body:not(.light-theme) .kpi-card {
            background: rgba(19, 24, 45, 0.6);
            backdrop-filter: blur(16px);
            border: 1px solid rgba(77, 141, 255, 0.15);
        }

        /* Light theme solid background */
        body.light-theme .kpi-card {
            background: white;
            border: 1px solid var(--border-color);
        }

        .kpi-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 16px;
        }

        .kpi-title {
            font-size: 13px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            color: var(--text-muted);
        }

        .kpi-icon {
            width: 36px;
            height: 36px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 18px;
        }

        .kpi-value {
            font-size: 36px;
            font-weight: 700;
            color: var(--text-primary);
            margin-bottom: 8px;
            line-height: 1;
        }

        .kpi-subtitle {
            font-size: 13px;
            color: var(--text-muted);
            margin-bottom: 12px;
        }

        .kpi-footer {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding-top: 12px;
            border-top: 1px solid var(--border-color);
        }

        .kpi-trend {
            display: flex;
            align-items: center;
            gap: 4px;
            font-size: 13px;
            font-weight: 600;
        }

        /* Status Color Variants */
        .status-green .kpi-icon {
            background: rgba(16, 185, 129, 0.15);
            color: var(--success-green);
        }

        .status-green .kpi-trend {
            color: var(--success-green);
        }

        .status-amber .kpi-icon {
            background: rgba(245, 158, 11, 0.15);
            color: var(--warning-amber);
        }

        .status-amber .kpi-trend {
            color: var(--warning-amber);
        }

        .status-red .kpi-icon {
            background: rgba(239, 68, 68, 0.15);
            color: var(--danger-red);
        }

        .status-red .kpi-trend {
            color: var(--danger-red);
        }

        /* ===== DATA TABLE SECTION ===== */
        .data-section {
            background: var(--bg-secondary);
            border: 1px solid var(--border-color);
            border-radius: 16px;
            padding: 24px;
            box-shadow: var(--shadow-sm);
        }

        body:not(.light-theme) .data-section {
            background: rgba(19, 24, 45, 0.6);
            backdrop-filter: blur(16px);
            border: 1px solid rgba(77, 141, 255, 0.15);
        }

        body.light-theme .data-section {
            background: white;
        }

        .section-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 20px;
            padding-bottom: 16px;
            border-bottom: 1px solid var(--border-color);
        }

        .section-title {
            font-size: 20px;
            font-weight: 700;
            color: var(--text-primary);
        }

        .toolbar {
            display: grid;
            grid-template-columns: 1fr auto auto;
            gap: 12px;
            margin-bottom: 20px;
        }

        .toolbar-left {
            display: flex;
            gap: 12px;
            align-items: center;
        }

        .toolbar-right {
            display: flex;
            gap: 12px;
            align-items: center;
        }

        .search-box {
            flex: 1;
            min-width: 250px;
        }

        .search-box input {
            width: 100%;
            padding: 10px 16px 10px 40px;
            background: var(--bg-tertiary);
            border: 1px solid var(--border-color);
            border-radius: 8px;
            font-size: 14px;
            color: var(--text-primary);
            transition: all 0.2s ease;
        }

        .search-box input:focus {
            outline: none;
            border-color: var(--accent-blue);
            box-shadow: 0 0 0 3px rgba(77, 141, 255, 0.1);
        }

        .search-icon {
            position: relative;
        }

        .search-icon::before {
            content: "🔍";
            position: absolute;
            left: 12px;
            top: 50%;
            transform: translateY(-50%);
            font-size: 16px;
        }

        .dropdown {
            position: relative;
        }

        .dropdown select {
            padding: 10px 36px 10px 16px;
            background: var(--bg-tertiary);
            border: 1px solid var(--border-color);
            border-radius: 8px;
            font-size: 14px;
            color: var(--text-primary);
            cursor: pointer;
            transition: all 0.2s ease;
            appearance: none;
        }

        .dropdown select:focus {
            outline: none;
            border-color: var(--accent-blue);
        }

        .dropdown::after {
            content: "▼";
            position: absolute;
            right: 12px;
            top: 50%;
            transform: translateY(-50%);
            font-size: 10px;
            color: var(--text-muted);
            pointer-events: none;
        }

        /* Button Styles */
        .btn-primary {
            padding: 10px 20px;
            font-size: 14px;
            font-weight: 600;
            color: white;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.2s ease;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }

        body:not(.light-theme) .btn-primary {
            background: linear-gradient(135deg, rgba(77, 141, 255, 0.45), rgba(59, 126, 239, 0.35));
            border: 1px solid rgba(77, 141, 255, 0.4);
            backdrop-filter: blur(10px);
        }

        body.light-theme .btn-primary {
            background: linear-gradient(135deg, #4d8dff, #3b7eef);
            border: 1px solid rgba(77, 141, 255, 0.5);
        }

        .btn-primary:hover {
            transform: translateY(-1px);
            box-shadow: 0 8px 20px -6px rgba(77, 141, 255, 0.5);
        }

        body:not(.light-theme) .btn-primary:hover {
            background: linear-gradient(135deg, rgba(77, 141, 255, 0.6), rgba(59, 126, 239, 0.5));
            border-color: rgba(77, 141, 255, 0.6);
        }

        body.light-theme .btn-primary:hover {
            background: linear-gradient(135deg, #3b7eef, #2d6fd9);
        }

        /* GridView Styles */
        .GridViewStyle {
            width: 100%;
            border-collapse: collapse;
            font-size: 14px;
        }

        .GridViewStyle th {
            background: var(--bg-tertiary);
            color: var(--text-primary);
            font-weight: 600;
            text-align: left;
            padding: 12px 16px;
            border-bottom: 2px solid var(--border-color);
            white-space: nowrap;
        }

        .GridViewStyle td {
            padding: 12px 16px;
            border-bottom: 1px solid var(--border-color);
            color: var(--text-secondary);
        }

        .GridViewStyle tr:hover td {
            background: rgba(77, 141, 255, 0.05);
        }

        .GridViewStyle .pager {
            padding: 16px;
            text-align: center;
            background: var(--bg-tertiary);
            border-top: 1px solid var(--border-color);
        }

        .GridViewStyle .pager a,
        .GridViewStyle .pager span {
            display: inline-block;
            padding: 6px 12px;
            margin: 0 2px;
            border-radius: 6px;
            text-decoration: none;
            color: var(--text-primary);
            font-size: 13px;
            transition: all 0.2s ease;
        }

        .GridViewStyle .pager a:hover {
            background: var(--accent-blue);
            color: white;
        }

        .GridViewStyle .pager span {
            background: var(--accent-blue);
            color: white;
            font-weight: 600;
        }

        /* Responsive adjustments */
        @media (max-width: 1024px) {
            .kpi-grid {
                grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
            }
        }

        @media (max-width: 768px) {
            .sidebar {
                transform: translateX(-100%);
            }

            .main-content {
                margin-left: 0;
            }

            .toolbar {
                grid-template-columns: 1fr;
            }

            .kpi-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="dashboard-container">
        <!-- Sidebar -->
        <aside class="sidebar" role="navigation" aria-label="Sidebar">
            <div class="sidebar-header">
                <img src="../Images/logo.png" alt="Logo" class="logo" onerror="this.style.display='none'">
            </div>

            <nav class="nav-section">
                <div class="nav-section-title">Dashboard</div>
                <ul class="nav-menu">
                    <li><a href="Dashboard.aspx" class="nav-link"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M3 13h8V3H3v10zM13 21h8V11h-8v10z"/><path d="M3 21h8v-6H3v6zM13 3v6h8V3h-8z"/></svg><span>Overview</span></a></li>
                    <li><a href="Analytics.aspx" class="nav-link"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M3 3v18h18"/><path d="M7 17l4-6 3 3 4-7"/></svg><span>Analytics</span></a></li>
                </ul>

                <div class="nav-section-title">Test Engineering</div>
                <ul class="nav-menu">
                    <li><a href="EquipmentInventoryDashboard.aspx" class="nav-link"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M3 10l9-6 9 6"/><path d="M5 10v10h14V10"/><path d="M9 20v-6h6v6"/></svg><span>Equipment</span></a></li>
                    <li><a href="TestComputers.aspx" class="nav-link active"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="4" y="5" width="16" height="10" rx="2"/><path d="M12 15v4"/><path d="M8 19h8"/></svg><span>Test Computers</span></a></li>
                    <li><a href="CalibrationDashboard.aspx" class="nav-link"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><line x1="4" y1="21" x2="4" y2="14"/><line x1="4" y1="10" x2="4" y2="3"/><line x1="12" y1="21" x2="12" y2="12"/><line x1="12" y1="8" x2="12" y2="3"/><line x1="20" y1="21" x2="20" y2="16"/><line x1="20" y1="12" x2="20" y2="3"/><line x1="1" y1="14" x2="7" y2="14"/><line x1="9" y1="8" x2="15" y2="8"/><line x1="17" y1="16" x2="23" y2="16"/></svg><span>Calibration</span></a></li>
                    <li><a href="PMDashboard.aspx" class="nav-link"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/><path d="M9 16l2 2 4-4"/></svg><span>Maintenance</span></a></li>
                    <li><a href="TroubleshootingDashboard.aspx" class="nav-link"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><path d="M9.5 9a3 3 0 1 1 5 2c-.8.6-1.5 1-1.5 2"/><circle cx="12" cy="17" r="1"/></svg><span>Troubleshooting</span></a></li>
                    <li><a href="#" class="nav-link"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><path d="M14 2v6h6"/><path d="M9 15h6"/><path d="M12 18v-6"/></svg><span>Test Certificates</span></a></li>
                    <li><a href="#" class="nav-link"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="7" width="20" height="14" rx="2"/><path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"/></svg><span>Test Stations</span></a></li>
                    <li><a href="#" class="nav-link"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M3 3v18h18"/><path d="M18 17V9"/><path d="M13 17V5"/><path d="M8 17v-3"/></svg><span>Metrics</span></a></li>
                </ul>

                <div class="nav-section-title">Quality</div>
                <ul class="nav-menu">
                    <li><a href="#" class="nav-link"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M22 12h-4l-3 9L9 3l-3 9H2"/></svg><span>First Pass Yield</span></a></li>
                    <li><a href="#" class="nav-link"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M3 3v18h18"/><path d="M13 17l5-5-5-5"/><path d="M8 12h10"/></svg><span>Test Yield</span></a></li>
                    <li><a href="#" class="nav-link"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg><span>Device Test History</span></a></li>
                    <li><a href="#" class="nav-link"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg><span>Failure Report</span></a></li>
                    <li><a href="#" class="nav-link"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"/><polyline points="7.5 4.21 12 6.81 16.5 4.21"/><polyline points="7.5 19.79 7.5 14.6 3 12"/><polyline points="21 12 16.5 14.6 16.5 19.79"/><polyline points="3.27 6.96 12 12.01 20.73 6.96"/><line x1="12" y1="22.08" x2="12" y2="12"/></svg><span>Quality Analytics</span></a></li>
                </ul>

                <div class="nav-section-title">Other</div>
                <ul class="nav-menu">
                    <li><a href="#" class="nav-link"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="3"/><path d="M12 1v6m0 6v6m9-9h-6m-6 0H3"/><path d="M19.07 4.93l-4.24 4.24m-5.66 0L4.93 4.93m14.14 14.14l-4.24-4.24m-5.66 0l-4.24 4.24"/></svg><span>Settings</span></a></li>
                    <li><a href="#" class="nav-link"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/><path d="M8 10h.01M12 10h.01M16 10h.01"/></svg><span>Help / Feedback</span></a></li>
                    <li id="adminPortalLink" runat="server" style="display:none;"><a href="Admin/Requests.aspx" class="nav-link"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="8" r="3"/><path d="M4 20a8 8 0 0 1 16 0"/></svg><span>Admin</span></a></li>
                </ul>
            </nav>

            <div class="sidebar-footer">
                <div class="user-info">
                    <div class="avatar" id="userAvatar" runat="server">JD</div>
                    <div>
                        <strong id="userFullName" runat="server">John Doe</strong>
                        <span id="userRole" runat="server">Test Engineer</span>
                    </div>
                </div>
                <div class="theme-toggle" onclick="toggleTheme()">
                    <span>🌙</span>
                </div>
            </div>
        </aside>

        <!-- Main Content -->
        <main class="main-content">
            <div class="page-title-wrap">
                <h1 id="hComp" class="page-title">Test Computers</h1>
            </div>
            <div role="main" aria-labelledby="hComp">

            <!-- KPI Cards -->
            <div class="kpi-grid">
                <!-- Total Computers -->
                <div class="kpi-card status-green" id="cardTotalComputers" runat="server">
                    <div class="kpi-header">
                        <div class="kpi-title">Total Active</div>
                        <div class="kpi-icon">💻</div>
                    </div>
                    <div class="kpi-value">
                        <asp:Literal ID="litTotalComputers" runat="server" Text="0"></asp:Literal>
                    </div>
                    <div class="kpi-subtitle">Computers in system</div>
                </div>

                <!-- In Use -->
                <div class="kpi-card status-green" id="cardInUse" runat="server">
                    <div class="kpi-header">
                        <div class="kpi-title">In Use</div>
                        <div class="kpi-icon">✅</div>
                    </div>
                    <div class="kpi-value">
                        <asp:Literal ID="litInUse" runat="server" Text="0"></asp:Literal>
                    </div>
                    <div class="kpi-subtitle">Currently deployed</div>
                </div>

                <!-- Available -->
                <div class="kpi-card status-green" id="cardAvailable" runat="server">
                    <div class="kpi-header">
                        <div class="kpi-title">Available</div>
                        <div class="kpi-icon">📦</div>
                    </div>
                    <div class="kpi-value">
                        <asp:Literal ID="litAvailable" runat="server" Text="0"></asp:Literal>
                    </div>
                    <div class="kpi-subtitle">Ready for deployment</div>
                </div>

                <!-- Open IT Tasks -->
                <div class="kpi-card status-green" id="cardOpenTasks" runat="server">
                    <div class="kpi-header">
                        <div class="kpi-title">Open IT Tasks</div>
                        <div class="kpi-icon">🔔</div>
                    </div>
                    <div class="kpi-value">
                        <asp:Literal ID="litOpenTasks" runat="server" Text="0"></asp:Literal>
                    </div>
                    <div class="kpi-subtitle">Pending actions</div>
                </div>

                <!-- Average Age -->
                <div class="kpi-card status-green" id="cardAvgAge" runat="server">
                    <div class="kpi-header">
                        <div class="kpi-title">Avg Age</div>
                        <div class="kpi-icon">📅</div>
                    </div>
                    <div class="kpi-value">
                        <asp:Literal ID="litAvgAge" runat="server" Text="--"></asp:Literal>
                    </div>
                    <div class="kpi-subtitle">Years in service</div>
                </div>
            </div>

            <!-- Data Table -->
            <div class="data-section">
                <div class="section-header">
                    <h3 class="section-title">Computer Inventory</h3>
                </div>

                <div class="toolbar">
                    <div class="toolbar-left">
                        <asp:Button ID="btnNewComputer" runat="server" Text="+ Add Computer" CssClass="btn-primary" 
                            OnClientClick="window.location='AddComputer.aspx'; return false;" />
                        <div class="search-box search-icon">
                            <asp:TextBox ID="txtSearch" runat="server" placeholder="Search computers..." 
                                AutoPostBack="true" OnTextChanged="txtSearch_TextChanged"></asp:TextBox>
                        </div>
                    </div>
                    <div class="toolbar-right">
                        <div class="dropdown">
                            <asp:DropDownList ID="ddlSort" runat="server" AutoPostBack="true" 
                                OnSelectedIndexChanged="ddlSort_SelectedIndexChanged">
                                <asp:ListItem Value="name_asc" Text="Name (A-Z)" Selected="True"></asp:ListItem>
                                <asp:ListItem Value="name_desc" Text="Name (Z-A)"></asp:ListItem>
                                <asp:ListItem Value="type" Text="Type"></asp:ListItem>
                                <asp:ListItem Value="status" Text="Status"></asp:ListItem>
                                <asp:ListItem Value="age_desc" Text="Oldest First"></asp:ListItem>
                            </asp:DropDownList>
                        </div>
                    </div>
                    <div class="toolbar-right">
                        <div class="dropdown">
                            <asp:DropDownList ID="ddlPageSize" runat="server" AutoPostBack="true" 
                                OnSelectedIndexChanged="ddlPageSize_SelectedIndexChanged">
                                <asp:ListItem Value="10" Text="10 per page"></asp:ListItem>
                                <asp:ListItem Value="25" Text="25 per page" Selected="True"></asp:ListItem>
                                <asp:ListItem Value="50" Text="50 per page"></asp:ListItem>
                                <asp:ListItem Value="100" Text="100 per page"></asp:ListItem>
                            </asp:DropDownList>
                        </div>
                    </div>
                </div>

                <asp:GridView ID="gridComputers" runat="server" 
                    AutoGenerateColumns="true"
                    AllowPaging="true"
                    PageSize="25"
                    CssClass="GridViewStyle"
                    PagerStyle-CssClass="pager"
                    OnPageIndexChanging="gridComputers_PageIndexChanging">
                </asp:GridView>
            </div>
        </main>
    </div>

    <script>
        function toggleTheme() {
            const body = document.body;
            const isDark = body.classList.toggle('dark-theme');
            localStorage.setItem('theme', isDark ? 'dark' : 'light');
            
            // Update toggle icon
            const toggle = document.querySelector('.theme-toggle span');
            if (toggle) {
                toggle.textContent = isDark ? '☀️' : '🌙';
            }
        }

        // Load saved theme on page load
        document.addEventListener('DOMContentLoaded', function() {
            const savedTheme = localStorage.getItem('theme');
            if (savedTheme === 'dark') {
                document.body.classList.add('dark-theme');
                const toggle = document.querySelector('.theme-toggle span');
                if (toggle) toggle.textContent = '☀️';
            }
        });
    </script>
</asp:Content>
