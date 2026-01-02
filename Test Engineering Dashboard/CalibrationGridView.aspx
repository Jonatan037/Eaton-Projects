<%@ Page Language="C#" AutoEventWireup="true" CodeFile="CalibrationGridView.aspx.cs" Inherits="TED_CalibrationGridView" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="0" />
    <!-- Version: 2025.10.23.001 - Calibration Logs Grid View -->
    <title>Calibration Logs Grid View - Test Engineering</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700;800&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="<%= ResolveUrl("~/Content/theme.css") %>" />
    <script type="text/javascript">
        (function(){
            try{
                var pref = localStorage.getItem('tedTheme') === 'light' ? 'light' : 'dark';
                var docEl = document.documentElement;
                var cls = (docEl.getAttribute('class')||'').replace(/\btheme-(light|dark)\b/g,'').trim();
                if(cls) docEl.setAttribute('class', cls);
                docEl.classList.add('theme-' + pref);
                docEl.setAttribute('data-theme', pref);
            }catch(e){}
        })();

        // JavaScript functions for grid view functionality
        function initializeRowHighlighting() {
            try {
                var table = document.getElementById('<%=gridCalibration.ClientID%>');
                if (!table) {
                    setTimeout(initializeRowHighlighting, 100);
                    return;
                }

                var rows = table.querySelectorAll('tbody tr');
                rows.forEach(function(row) {
                    row.addEventListener('click', function() {
                        // Remove previous selection
                        var selectedRows = table.querySelectorAll('tbody tr.row-selected');
                        selectedRows.forEach(function(selectedRow) {
                            selectedRow.classList.remove('row-selected');
                        });

                        // Add selection to clicked row
                        this.classList.add('row-selected');
                    });
                });
            } catch (e) {
                console.error('Error initializing row highlighting:', e);
            }
        }

        function updateFilterCount() {
            try {
                var activeCount = 0;
                var filterInputs = document.querySelectorAll('.filter-input, .filter-select');

                filterInputs.forEach(function(input) {
                    if (input.value && input.value !== 'ALL' && input.value !== '') {
                        activeCount++;
                        input.classList.add('filter-active');
                    } else {
                        input.classList.remove('filter-active');
                    }
                });

                var countElement = document.getElementById('activeFilterCount');
                if (countElement) {
                    if (activeCount > 0) {
                        countElement.textContent = activeCount;
                        countElement.style.display = 'inline-flex';
                    } else {
                        countElement.style.display = 'none';
                    }
                }
            } catch (e) {
                console.error('Error updating filter count:', e);
            }
        }

        function toggleFilters() {
            try {
                var content = document.getElementById('filterContent');
                var icon = document.getElementById('filterToggleIcon');
                var text = document.getElementById('filterToggleText');

                if (content && icon && text) {
                    var isCollapsed = content.classList.contains('collapsed');

                    if (isCollapsed) {
                        content.classList.remove('collapsed');
                        icon.classList.remove('collapsed');
                        text.textContent = 'COLLAPSE';
                        localStorage.setItem('calibrationGridFiltersExpanded', 'true');
                    } else {
                        content.classList.add('collapsed');
                        icon.classList.add('collapsed');
                        text.textContent = 'EXPAND';
                        localStorage.setItem('calibrationGridFiltersExpanded', 'false');
                    }
                }
            } catch (e) {
                console.error('Error toggling filters:', e);
            }
        }

        function resetAllFilters() {
            try {
                var filterInputs = document.querySelectorAll('.filter-input, .filter-select');
                filterInputs.forEach(function(input) {
                    if (input.tagName === 'SELECT') {
                        input.selectedIndex = 0;
                    } else {
                        input.value = '';
                    }
                });
                updateFilterCount();

                // Trigger postback to reset server-side filters
                __doPostBack('<%=btnReset.ClientID%>', '');
            } catch (e) {
                console.error('Error resetting filters:', e);
            }
        }

        // Initialize when DOM is ready
        document.addEventListener('DOMContentLoaded', function() {
            try {
                // Add event listener to filter header for toggling
                var filterHeader = document.querySelector('.filter-header');
                if (filterHeader) {
                    filterHeader.addEventListener('click', toggleFilters);
                }

                // Initialize row highlighting
                initializeRowHighlighting();

                // Update filter count on page load
                updateFilterCount();

                // Add input event listeners for filter count updates
                var filterInputs = document.querySelectorAll('.filter-input, .filter-select');
                filterInputs.forEach(function(input) {
                    input.addEventListener('input', updateFilterCount);
                    input.addEventListener('change', updateFilterCount);
                });

                // Initialize filter panel state - default to collapsed
                var content = document.getElementById('filterContent');
                var icon = document.getElementById('filterToggleIcon');
                var text = document.getElementById('filterToggleText');
                var isExpanded = localStorage.getItem('calibrationGridFiltersExpanded');

                if (content && icon && text) {
                    if (isExpanded === 'true') {
                        // User previously expanded it, so expand it
                        content.classList.remove('collapsed');
                        icon.classList.remove('collapsed');
                        text.textContent = 'COLLAPSE';
                    } else {
                        // Default: Start collapsed
                        content.classList.add('collapsed');
                        icon.classList.add('collapsed');
                        text.textContent = 'EXPAND';
                    }
                }
            } catch (e) {
                console.error('Error during DOM initialization:', e);
            }
        });
    </script>
    <style>
    /* Grid View Specific Styles */
    html, body { max-width:100%; overflow-x:hidden; margin:0; padding:0; }
    body { min-height:100vh; }

    /* Container */
    .grid-view-container {
      padding:20px 24px 40px;
      max-width:100%;
      box-sizing:border-box;
    }

    /* Page Title */
    .page-header {
      margin-bottom:20px;
      display:flex;
      align-items:center;
      justify-content:space-between;
    }
    .page-title {
      font-size:16px;
      font-weight:800;
      letter-spacing:.3px;
      margin:0;
    }
    .page-subtitle {
      font-size:10px;
      opacity:.65;
      margin-top:2px;
    }

    /* Filter Panel */
    .filter-panel {
      background:rgba(25,29,37,.52);
      border:1px solid rgba(255,255,255,.08);
      border-radius:14px;
      box-shadow:0 12px 28px -8px rgba(0,0,0,.5), 0 0 0 1px rgba(255,255,255,.05);
      backdrop-filter:blur(36px) saturate(135%);
      padding:0;
      margin-bottom:16px;
      overflow:hidden;
    }
    html.theme-light .filter-panel, html[data-theme='light'] .filter-panel {
      background:rgba(255,255,255,.72);
      border:1px solid rgba(0,0,0,.08);
      box-shadow:0 10px 26px -10px rgba(0,0,0,.15), 0 0 0 1px rgba(0,0,0,.05);
    }

    .filter-header {
      font-size:11px;
      font-weight:700;
      letter-spacing:.3px;
      padding:12px 18px;
      opacity:.85;
      display:flex;
      align-items:center;
      justify-content:space-between;
      cursor:pointer;
      user-select:none;
      border-bottom:1px solid rgba(255,255,255,.08);
      transition:all .2s ease;
    }
    .filter-header:hover {
      background:rgba(255,255,255,.04);
    }
    html.theme-light .filter-header, html[data-theme='light'] .filter-header {
      border-bottom:1px solid rgba(0,0,0,.08);
    }
    html.theme-light .filter-header:hover, html[data-theme='light'] .filter-header:hover {
      background:rgba(0,0,0,.02);
    }
    .filter-header-left {
      display:flex;
      align-items:center;
      gap:6px;
    }
    .filter-header-right {
      display:flex;
      align-items:center;
      gap:10px;
    }
    .btn-reset-icon {
      display:flex;
      align-items:center;
      justify-content:center;
      width:28px;
      height:28px;
      padding:0;
      border:1px solid rgba(255,255,255,.16);
      border-radius:7px;
      background:rgba(255,255,255,.06);
      color:inherit;
      cursor:pointer;
      transition:all .2s ease;
    }
    .btn-reset-icon svg {
      width:14px;
      height:14px;
    }
    .btn-reset-icon:hover {
      background:rgba(239,68,68,.2);
      border-color:rgba(239,68,68,.4);
      color:#fca5a5;
      transform:rotate(-180deg);
    }
    html.theme-light .btn-reset-icon, html[data-theme='light'] .btn-reset-icon {
      background:#f5f7fa;
      border:1px solid rgba(0,0,0,.14);
      color:#1f242b;
    }
    html.theme-light .btn-reset-icon:hover, html[data-theme='light'] .btn-reset-icon:hover {
      background:#fee;
      border-color:#ef4444;
      color:#dc2626;
    }
    .filter-count {
      display:inline-flex;
      align-items:center;
      justify-content:center;
      min-width:20px;
      height:18px;
      padding:0 6px;
      margin-left:6px;
      background:rgba(77,141,255,.25);
      color:#93c5fd;
      border-radius:9px;
      font-size:10px;
      font-weight:800;
      letter-spacing:.3px;
    }
    html.theme-light .filter-count, html[data-theme='light'] .filter-count {
      background:rgba(59,130,246,.15);
      color:#2563eb;
    }
    .filter-header svg {
      width:13px;
      height:13px;
      opacity:.7;
    }
    .filter-toggle {
      display:flex;
      align-items:center;
      gap:5px;
      font-size:9px;
      opacity:.55;
      font-weight:600;
      letter-spacing:.3px;
    }
    .filter-toggle-icon {
      width:14px;
      height:14px;
      transition:transform .3s ease;
    }
    .filter-toggle-icon.collapsed {
      transform:rotate(-90deg);
    }

    .filter-content {
      max-height:1000px;
      transition:max-height .35s cubic-bezier(0.4, 0, 0.2, 1),
                 opacity .35s ease,
                 padding .35s ease;
      opacity:1;
      padding:16px 18px;
      overflow:hidden;
    }
    .filter-content.collapsed {
      max-height:0;
      opacity:0;
      padding:0 18px;
    }

    .filter-section {
      margin-bottom:16px;
    }
    .filter-section:last-child {
      margin-bottom:0;
    }
    .filter-section-title {
      font-size:9px;
      font-weight:700;
      text-transform:uppercase;
      letter-spacing:.5px;
      opacity:.45;
      margin-bottom:10px;
      padding-bottom:6px;
      border-bottom:1px solid rgba(255,255,255,.06);
    }
    html.theme-light .filter-section-title, html[data-theme='light'] .filter-section-title {
      border-bottom:1px solid rgba(0,0,0,.06);
    }

    .filter-grid {
      display:grid;
      grid-template-columns:repeat(auto-fit, minmax(180px, 1fr));
      gap:10px;
      align-items:end;
    }
    .filter-grid-2col {
      grid-template-columns:repeat(2, 1fr);
    }
    .filter-grid-3col {
      grid-template-columns:repeat(3, 1fr);
    }
    .filter-grid-4col {
      grid-template-columns:repeat(4, 1fr);
    }

    .filter-group {
      display:flex;
      flex-direction:column;
      gap:4px;
    }

    .filter-label {
      font-size:9px;
      font-weight:600;
      letter-spacing:.4px;
      opacity:.6;
      text-transform:uppercase;
    }

    .filter-input, .filter-select {
      width:100%;
      padding:7px 10px;
      border-radius:8px;
      border:1px solid rgba(255,255,255,.16);
      background:rgba(0,0,0,.12);
      color:#e5e7eb;
      font:inherit;
      font-size:11px;
      transition:all .2s ease;
      height:30px;
      box-sizing:border-box;
    }
    .filter-select {
      cursor:pointer;
      -webkit-appearance:none;
      -moz-appearance:none;
      appearance:none;
      background-color:rgba(0,0,0,.12);
      background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='%23e5e7eb' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='6 9 12 15 18 9'%3E%3C/polyline%3E%3C/svg%3E");
      background-repeat:no-repeat;
      background-position:right 10px center;
      padding-right:35px;
    }
    .filter-select option {
      background:#1f242b;
      color:#e5e7eb;
      padding:8px;
    }
    .filter-input:focus, .filter-select:focus {
      outline:none;
      border-color:rgba(77,141,255,.5);
      background:rgba(0,0,0,.18);
      box-shadow:0 0 0 2px rgba(77,141,255,.08);
    }
    .filter-input::placeholder {
      opacity:.5;
      color:#9ca3af;
    }

    /* Active filter highlighting */
    .filter-input.filter-active, .filter-select.filter-active {
      border-color:#fbbf24 !important;
      background:rgba(251,191,36,.1) !important;
      box-shadow:0 0 0 2px rgba(251,191,36,.15) !important;
    }
    html.theme-light .filter-input.filter-active,
    html[data-theme='light'] .filter-input.filter-active,
    html.theme-light .filter-select.filter-active,
    html[data-theme='light'] .filter-select.filter-active {
      border-color:#f59e0b !important;
      background:rgba(245,158,11,.08) !important;
      box-shadow:0 0 0 2px rgba(245,158,11,.12) !important;
    }

    html.theme-light .filter-input, html[data-theme='light'] .filter-input,
    html.theme-light .filter-select, html[data-theme='light'] .filter-select {
      background:#fff;
      background-color:#fff;
      border:1px solid rgba(0,0,0,.12);
      color:#1f242b;
    }
    html.theme-light .filter-select, html[data-theme='light'] .filter-select {
      background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='%231f242b' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='6 9 12 15 18 9'%3E%3C/polyline%3E%3C/svg%3E");
      background-color:#fff;
      background-repeat:no-repeat;
      background-position:right 10px center;
    }
    html.theme-light .filter-select option, html[data-theme='light'] .filter-select option {
      background:#ffffff;
      color:#1f242b;
    }
    html.theme-light .filter-input:focus, html[data-theme='light'] .filter-input:focus,
    html.theme-light .filter-select:focus, html[data-theme='light'] .filter-select:focus {
      border-color:#4d8dff;
      box-shadow:0 0 0 2px rgba(77,141,255,.08);
    }

    .filter-actions {
      display:flex;
      gap:8px;
      margin-top:12px;
      padding-top:12px;
      border-top:1px solid rgba(255,255,255,.06);
    }
    html.theme-light .filter-actions, html[data-theme='light'] .filter-actions {
      border-top:1px solid rgba(0,0,0,.06);
    }

    .btn-reset {
      padding:7px 14px;
      border-radius:8px;
      border:1px solid rgba(255,255,255,.16);
      background:rgba(255,255,255,.06);
      color:inherit;
      font:inherit;
      font-size:11px;
      font-weight:600;
      cursor:pointer;
      transition:all .2s ease;
      white-space:nowrap;
      height:30px;
    }
    .btn-reset:hover {
      background:rgba(239,68,68,.2);
      border-color:rgba(239,68,68,.4);
      color:#fca5a5;
    }
    html.theme-light .btn-reset, html[data-theme='light'] .btn-reset {
      background:#f5f7fa;
      border:1px solid rgba(0,0,0,.14);
      color:#1f242b;
    }
    html.theme-light .btn-reset:hover, html[data-theme='light'] .btn-reset:hover {
      background:#fee;
      border-color:#ef4444;
      color:#dc2626;
    }

    /* Table Container */
    .table-container {
      background:rgba(25,29,37,.52);
      border:1px solid rgba(255,255,255,.08);
      border-radius:16px;
      box-shadow:0 12px 28px -8px rgba(0,0,0,.5), 0 0 0 1px rgba(255,255,255,.05);
      backdrop-filter:blur(36px) saturate(135%);
      padding:0;
      overflow:hidden;
    }
    html.theme-light .table-container, html[data-theme='light'] .table-container {
      background:rgba(255,255,255,.72);
      border:1px solid rgba(0,0,0,.08);
      box-shadow:0 10px 26px -10px rgba(0,0,0,.15), 0 0 0 1px rgba(0,0,0,.05);
    }

    .table-header {
      padding:18px 22px;
      border-bottom:1px solid rgba(255,255,255,.08);
      display:flex;
      justify-content:space-between;
      align-items:center;
    }
    html.theme-light .table-header, html[data-theme='light'] .table-header {
      border-bottom:1px solid rgba(0,0,0,.08);
    }

    .table-title {
      font-size:11px;
      font-weight:700;
      letter-spacing:.3px;
      display:flex;
      align-items:center;
      gap:6px;
    }
    .table-title svg {
      width:14px;
      height:14px;
      opacity:.7;
    }
    .record-count {
      font-size:10px;
      opacity:.55;
      font-weight:600;
      margin-left:4px;
    }

    .table-actions {
      display:flex;
      gap:10px;
    }

    .btn-icon-action {
      padding:6px 12px;
      border-radius:8px;
      border:1px solid rgba(255,255,255,.18);
      background:rgba(255,255,255,.08);
      color:inherit;
      font:inherit;
      font-size:10px;
      font-weight:600;
      cursor:pointer;
      transition:all .2s ease;
      white-space:nowrap;
      display:flex;
      align-items:center;
      gap:5px;
      height:28px;
    }
    .btn-icon-action svg {
      width:12px;
      height:12px;
    }
    .btn-icon-action:hover {
      background:rgba(77,141,255,.2);
      border-color:rgba(77,141,255,.4);
      color:#bcd4ff;
      transform:translateY(-1px);
    }
    html.theme-light .btn-icon-action, html[data-theme='light'] .btn-icon-action {
      background:#f5f7fa;
      border:1px solid rgba(0,0,0,.14);
      color:#1f242b;
    }
    html.theme-light .btn-icon-action:hover, html[data-theme='light'] .btn-icon-action:hover {
      background:#e8f1ff;
      border-color:#4d8dff;
      color:#1e40af;
    }

    /* Table Wrap with Scroll */
    .table-wrap {
      width:100%;
      max-width:100%;
      overflow-x:auto;
      overflow-y:auto;
      max-height:calc(100vh - 280px);
      border-radius:0 0 16px 16px;
      position:relative;
    }

    /* Modern Fancy Scrollbars */
    .table-wrap::-webkit-scrollbar {
      width:10px;
      height:10px;
    }
    .table-wrap::-webkit-scrollbar-track {
      background:rgba(0,0,0,.15);
      border-radius:10px;
      margin:4px;
    }
    .table-wrap::-webkit-scrollbar-thumb {
      background:linear-gradient(135deg, rgba(77,141,255,.4), rgba(139,92,246,.4));
      border-radius:10px;
      border:2px solid rgba(0,0,0,.15);
      transition:all .3s ease;
    }
    .table-wrap::-webkit-scrollbar-thumb:hover {
      background:linear-gradient(135deg, rgba(77,141,255,.6), rgba(139,92,246,.6));
      border-color:rgba(0,0,0,.2);
    }
    .table-wrap::-webkit-scrollbar-corner {
      background:rgba(0,0,0,.15);
      border-radius:10px;
    }
    html.theme-light .table-wrap::-webkit-scrollbar-track,
    html[data-theme='light'] .table-wrap::-webkit-scrollbar-track {
      background:rgba(0,0,0,.06);
    }
    html.theme-light .table-wrap::-webkit-scrollbar-thumb,
    html[data-theme='light'] .table-wrap::-webkit-scrollbar-thumb {
      background:linear-gradient(135deg, rgba(59,130,246,.5), rgba(139,92,246,.5));
      border:2px solid rgba(255,255,255,.3);
    }
    html.theme-light .table-wrap::-webkit-scrollbar-thumb:hover,
    html[data-theme='light'] .table-wrap::-webkit-scrollbar-thumb:hover {
      background:linear-gradient(135deg, rgba(59,130,246,.7), rgba(139,92,246,.7));
    }
    html.theme-light .table-wrap::-webkit-scrollbar-corner,
    html[data-theme='light'] .table-wrap::-webkit-scrollbar-corner {
      background:rgba(0,0,0,.06);
    }

    /* Data Table */
    table.data-table,
    #gridCalibration,
    table[id*="gridCalibration"] {
      width:100%;
      min-width:4000px;
      border-collapse:separate;
      border-spacing:0;
      font-size:9.5px;
      table-layout:fixed;
    }
    table.data-table th, table.data-table td,
    #gridCalibration th, #gridCalibration td,
    table[id*="gridCalibration"] th, table[id*="gridCalibration"] td {
      box-sizing:border-box;
    }
    table.data-table .grid-header-row,
    #gridCalibration .grid-header-row,
    table[id*="gridCalibration"] .grid-header-row {
      position:sticky;
      top:0;
      z-index:100;
      background:linear-gradient(180deg, #0b63ce 0%, #094fa8 100%) !important;
    }
    table.data-table .grid-header-row th,
    #gridCalibration .grid-header-row th,
    table[id*="gridCalibration"] .grid-header-row th {
      background:linear-gradient(180deg, #0b63ce 0%, #094fa8 100%) !important;
      color:#ffffff !important;
      border-bottom:2px solid rgba(0,0,0,.2) !important;
      text-align:center !important;
      font-size:9px !important;
      padding:6px 8px !important;
      height:28px !important;
      max-height:28px !important;
      min-height:28px !important;
      line-height:1.2 !important;
      font-weight:700 !important;
      letter-spacing:.4px !important;
      white-space:nowrap !important;
      text-overflow:ellipsis !important;
      overflow:hidden !important;
      box-shadow:0 2px 8px rgba(0,0,0,.15) !important;
    }
    html:not(.theme-light):not([data-theme='light']) table.data-table .grid-header-row th,
    html:not(.theme-light):not([data-theme='light']) #gridCalibration .grid-header-row th,
    html:not(.theme-light):not([data-theme='light']) table[id*="gridCalibration"] .grid-header-row th {
      background:linear-gradient(180deg, #1a2942 0%, #0f1a2e 100%) !important;
      color:#e9eef8 !important;
      border-bottom:2px solid rgba(77,141,255,.25) !important;
      box-shadow:0 2px 12px rgba(0,0,0,.3) !important;
    }

    table.data-table tbody td,
    #gridCalibration tbody td,
    table[id*="gridCalibration"] tbody td {
      padding:8px 8px;
      border-bottom:1px solid rgba(255,255,255,.06);
      vertical-align:middle;
      text-align:center;
      overflow:hidden;
      text-overflow:ellipsis;
      white-space:normal;
      word-wrap:break-word;
      font-size:9.5px;
      color:#e5e7eb;
      max-width:200px;
      cursor:default;
    }
    html.theme-light table.data-table tbody td, html[data-theme='light'] table.data-table tbody td,
    html.theme-light #gridCalibration tbody td, html[data-theme='light'] #gridCalibration tbody td,
    html.theme-light table[id*="gridCalibration"] tbody td, html[data-theme='light'] table[id*="gridCalibration"] tbody td {
      border-bottom:1px solid rgba(0,0,0,.05);
      color:#1f242b;
    }

    /* Add title attribute for tooltips on hover */
    table[id*="gridCalibration"] tbody td:hover {
      position:relative;
      z-index:5;
    }

    /* Allow URL columns to show full text */
    table[id*="gridCalibration"] .col-folder,
    table[id*="gridCalibration"] .col-image {
      white-space:normal;
      word-break:break-all;
      min-width:200px;
      max-width:250px;
    }

    table.data-table tbody tr:nth-child(odd),
    #gridCalibration tbody tr:nth-child(odd),
    table[id*="gridCalibration"] tbody tr:nth-child(odd) {
      background:rgba(255,255,255,.015);
    }
    html.theme-light table.data-table tbody tr:nth-child(odd),
    html.theme-light #gridCalibration tbody tr:nth-child(odd),
    html.theme-light table[id*="gridCalibration"] tbody tr:nth-child(odd) {
      background:#fafbfe;
    }

    table.data-table tbody tr:hover,
    #gridCalibration tbody tr:hover,
    table[id*="gridCalibration"] tbody tr:hover {
      background:rgba(77,141,255,.08);
    }
    html.theme-light table.data-table tbody tr:hover, html[data-theme='light'] table.data-table tbody tr:hover,
    html.theme-light #gridCalibration tbody tr:hover, html[data-theme='light'] #gridCalibration tbody tr:hover,
    html.theme-light table[id*="gridCalibration"] tbody tr:hover, html[data-theme='light'] table[id*="gridCalibration"] tbody tr:hover {
      background:#f0f6ff;
    }

    /* Selected Row Highlighting */
    table.data-table tbody tr.row-selected,
    #gridCalibration tbody tr.row-selected,
    table[id*="gridCalibration"] tbody tr.row-selected {
      background:rgba(77,141,255,.20) !important;
      box-shadow:inset 3px 0 0 #4d8dff;
    }
    html.theme-light table.data-table tbody tr.row-selected,
    html[data-theme='light'] table.data-table tbody tr.row-selected,
    html.theme-light #gridCalibration tbody tr.row-selected,
    html[data-theme='light'] #gridCalibration tbody tr.row-selected,
    html.theme-light table[id*="gridCalibration"] tbody tr.row-selected,
    html[data-theme='light'] table[id*="gridCalibration"] tbody tr.row-selected {
      background:rgba(59,130,246,.15) !important;
      box-shadow:inset 3px 0 0 #3b82f6;
    }
    table.data-table tbody tr.row-selected td,
    #gridCalibration tbody tr.row-selected td,
    table[id*="gridCalibration"] tbody tr.row-selected td {
      font-weight:600;
    }

    /* Status Badges */
    .status-badge {
      display:inline-flex;
      align-items:center;
      gap:4px;
      padding:4px 10px;
      border-radius:6px;
      font-size:9px;
      font-weight:500 !important;
      letter-spacing:.3px;
      white-space:normal;
      word-wrap:break-word;
      text-transform:uppercase;
      max-width:100%;
      line-height:1.4;
      text-align:center;
    }
    .status-badge::before {
      content:'';
      width:5px;
      height:5px;
      border-radius:50%;
      flex-shrink:0;
      align-self:flex-start;
      margin-top:2px;
    }

    /* Priority Badges */
    .priority-badge {
      display:inline-flex;
      align-items:center;
      gap:4px;
      padding:4px 10px;
      border-radius:6px;
      font-size:9px;
      font-weight:500 !important;
      letter-spacing:.3px;
      white-space:normal;
      word-wrap:break-word;
      text-transform:uppercase;
      max-width:100%;
      line-height:1.4;
      text-align:center;
    }
    .priority-badge::before {
      content:'';
      width:5px;
      height:5px;
      border-radius:50%;
      flex-shrink:0;
      align-self:flex-start;
      margin-top:2px;
    }

    /* Impact Level Badges */
    .impact-badge {
      display:inline-flex;
      align-items:center;
      gap:4px;
      padding:4px 10px;
      border-radius:6px;
      font-size:9px;
      font-weight:500 !important;
      letter-spacing:.3px;
      white-space:normal;
      word-wrap:break-word;
      text-transform:uppercase;
      max-width:100%;
      line-height:1.4;
      text-align:center;
    }
    .impact-badge::before {
      content:'';
      width:5px;
      height:5px;
      border-radius:50%;
      flex-shrink:0;
      align-self:flex-start;
      margin-top:2px;
    }

    /* Status colors - Equipment Grid View style */
    .status-in-use, .status-active, .status-calibrated, .status-passed, .status-completed {
      background:rgba(16,185,129,.15);
      color:#10b981;
    }
    .status-in-use::before, .status-active::before, .status-calibrated::before, .status-passed::before, .status-completed::before {
      background:#10b981;
      box-shadow:0 0 4px #10b981;
    }
    html.theme-light .status-in-use, html[data-theme='light'] .status-in-use,
    html.theme-light .status-active, html[data-theme='light'] .status-active,
    html.theme-light .status-calibrated, html[data-theme='light'] .status-calibrated,
    html.theme-light .status-passed, html[data-theme='light'] .status-passed,
    html.theme-light .status-completed, html[data-theme='light'] .status-completed {
      background:#d1fae5;
      color:#059669;
    }

    .status-spare, .status-available, .status-pending {
      background:rgba(59,130,246,.15);
      color:#3b82f6;
    }
    .status-spare::before, .status-available::before, .status-pending::before {
      background:#3b82f6;
      box-shadow:0 0 4px #3b82f6;
    }
    html.theme-light .status-spare, html[data-theme='light'] .status-spare,
    html.theme-light .status-available, html[data-theme='light'] .status-available,
    html.theme-light .status-pending, html[data-theme='light'] .status-pending {
      background:#dbeafe;
      color:#1d4ed8;
    }

    .status-out-of-service, .status-overdue, .status-due-soon, .status-in-progress {
      background:rgba(249,115,22,.15);
      color:#f97316;
    }
    .status-out-of-service::before, .status-overdue::before, .status-due-soon::before, .status-in-progress::before {
      background:#f97316;
      box-shadow:0 0 4px #f97316;
    }
    html.theme-light .status-out-of-service, html[data-theme='light'] .status-out-of-service,
    html.theme-light .status-overdue, html[data-theme='light'] .status-overdue,
    html.theme-light .status-due-soon, html[data-theme='light'] .status-due-soon,
    html.theme-light .status-in-progress, html[data-theme='light'] .status-in-progress {
      background:#fed7aa;
      color:#c2410c;
    }

    .status-scrapped, .status-failed, .status-critical {
      background:rgba(239,68,68,.15);
      color:#ef4444;
    }
    .status-scrapped::before, .status-failed::before, .status-critical::before {
      background:#ef4444;
      box-shadow:0 0 4px #ef4444;
    }
    html.theme-light .status-scrapped, html[data-theme='light'] .status-scrapped,
    html.theme-light .status-failed, html[data-theme='light'] .status-failed,
    html.theme-light .status-critical, html[data-theme='light'] .status-critical {
      background:#fee2e2;
      color:#dc2626;
    }

    /* Additional status variations from EquipmentGridView */
    .status-out-of-service---damaged,
    .status-out-of-service---under-repair,
    .status-out-of-service---in-calibration {
      background:rgba(249,115,22,.15);
      color:#f97316;
    }
    .status-out-of-service---damaged::before,
    .status-out-of-service---under-repair::before,
    .status-out-of-service---in-calibration::before {
      background:#f97316;
      box-shadow:0 0 4px #f97316;
    }
    html.theme-light .status-out-of-service---damaged, html[data-theme='light'] .status-out-of-service---damaged,
    html.theme-light .status-out-of-service---under-repair, html[data-theme='light'] .status-out-of-service---under-repair,
    html.theme-light .status-out-of-service---in-calibration, html[data-theme='light'] .status-out-of-service---in-calibration {
      background:#fed7aa;
      color:#c2410c;
    }

    .status-scrapped---returned-to-vendor,
    .status-scraped---returned-to-vendor {
      background:rgba(239,68,68,.15);
      color:#ef4444;
    }
    .status-scrapped---returned-to-vendor::before,
    .status-scraped---returned-to-vendor::before {
      background:#ef4444;
      box-shadow:0 0 4px #ef4444;
    }
    html.theme-light .status-scrapped---returned-to-vendor, html[data-theme='light'] .status-scrapped---returned-to-vendor,
    html.theme-light .status-scraped---returned-to-vendor, html[data-theme='light'] .status-scraped---returned-to-vendor {
      background:#fee2e2;
      color:#dc2626;
    }

    .status-retired,
    .status-decommissioned {
      background:rgba(107,114,128,.15);
      color:#9ca3af;
    }
    .status-retired::before,
    .status-decommissioned::before {
      background:#6b7280;
      box-shadow:0 0 4px #6b7280;
    }
    html.theme-light .status-retired, html[data-theme='light'] .status-retired,
    html.theme-light .status-decommissioned, html[data-theme='light'] .status-decommissioned {
      background:#f3f4f6;
      color:#4b5563;
    }

    .status-under-repair,
    .status-repair,
    .status-maintenance {
      background:rgba(249,115,22,.15);
      color:#f97316;
    }
    .status-under-repair::before,
    .status-repair::before,
    .status-maintenance::before {
      background:#f97316;
      box-shadow:0 0 4px #f97316;
    }
    html.theme-light .status-under-repair, html[data-theme='light'] .status-under-repair,
    html.theme-light .status-repair, html[data-theme='light'] .status-repair,
    html.theme-light .status-maintenance, html[data-theme='light'] .status-maintenance {
      background:#fed7aa;
      color:#c2410c;
    }

    .status-calibration-due,
    .status-needs-calibration {
      background:rgba(234,179,8,.15);
      color:#eab308;
    }
    .status-calibration-due::before,
    .status-needs-calibration::before {
      background:#eab308;
      box-shadow:0 0 4px #eab308;
    }
    html.theme-light .status-calibration-due, html[data-theme='light'] .status-calibration-due,
    html.theme-light .status-needs-calibration, html[data-theme='light'] .status-needs-calibration {
      background:#fef3c7;
      color:#a16207;
    }

    .status-reserved {
      background:rgba(168,85,247,.15);
      color:#a855f7;
    }
    .status-reserved::before {
      background:#a855f7;
      box-shadow:0 0 4px #a855f7;
    }
    html.theme-light .status-reserved, html[data-theme='light'] .status-reserved {
      background:#f3e8ff;
      color:#7e22ce;
    }

    /* Status variations from TroubleshootingGridView */
    .status-open, .status-new {
      background:rgba(59,130,246,.15);
      color:#3b82f6;
    }
    .status-open::before, .status-new::before {
      background:#3b82f6;
      box-shadow:0 0 4px #3b82f6;
    }
    html.theme-light .status-open, html[data-theme='light'] .status-open,
    html.theme-light .status-new, html[data-theme='light'] .status-new {
      background:#dbeafe;
      color:#1d4ed8;
    }

    .status-investigating {
      background:rgba(249,115,22,.15);
      color:#f97316;
    }
    .status-investigating::before {
      background:#f97316;
      box-shadow:0 0 4px #f97316;
    }
    html.theme-light .status-investigating, html[data-theme='light'] .status-investigating {
      background:#fed7aa;
      color:#c2410c;
    }

    .status-resolved, .status-closed, .status-fixed {
      background:rgba(16,185,129,.15);
      color:#10b981;
    }
    .status-resolved::before, .status-closed::before, .status-fixed::before {
      background:#10b981;
      box-shadow:0 0 4px #10b981;
    }
    html.theme-light .status-resolved, html[data-theme='light'] .status-resolved,
    html.theme-light .status-closed, html[data-theme='light'] .status-closed,
    html.theme-light .status-fixed, html[data-theme='light'] .status-fixed {
      background:#d1fae5;
      color:#059669;
    }

    .status-escalated {
      background:rgba(239,68,68,.15);
      color:#ef4444;
    }
    .status-escalated::before {
      background:#ef4444;
      box-shadow:0 0 4px #ef4444;
    }
    html.theme-light .status-escalated, html[data-theme='light'] .status-escalated {
      background:#fee2e2;
      color:#dc2626;
    }

    /* Priority colors from TroubleshootingGridView */
    .priority-low {
      background:rgba(107,114,128,.15);
      color:#6b7280;
    }
    .priority-low::before {
      background:#6b7280;
      box-shadow:0 0 4px #6b7280;
    }
    html.theme-light .priority-low, html[data-theme='light'] .priority-low {
      background:#f3f4f6;
      color:#374151;
    }

    .priority-medium, .priority-normal {
      background:rgba(245,158,11,.15);
      color:#f59e0b;
    }
    .priority-medium::before, .priority-normal::before {
      background:#f59e0b;
      box-shadow:0 0 4px #f59e0b;
    }
    html.theme-light .priority-medium, html[data-theme='light'] .priority-medium,
    html.theme-light .priority-normal, html[data-theme='light'] .priority-normal {
      background:#fef3c7;
      color:#d97706;
    }

    .priority-high {
      background:rgba(239,68,68,.15);
      color:#ef4444;
    }
    .priority-high::before {
      background:#ef4444;
      box-shadow:0 0 4px #ef4444;
    }
    html.theme-light .priority-high, html[data-theme='light'] .priority-high {
      background:#fee2e2;
      color:#dc2626;
    }

    .priority-urgent, .priority-critical {
      background:rgba(168,85,247,.15);
      color:#a855f7;
    }
    .priority-urgent::before, .priority-critical::before {
      background:#a855f7;
      box-shadow:0 0 4px #a855f7;
    }
    html.theme-light .priority-urgent, html[data-theme='light'] .priority-urgent,
    html.theme-light .priority-critical, html[data-theme='light'] .priority-critical {
      background:#f3e8ff;
      color:#7e22ce;
    }

    /* Impact level colors from TroubleshootingGridView */
    .impact-low, .impact-minor {
      background:rgba(107,114,128,.15);
      color:#6b7280;
    }
    .impact-low::before, .impact-minor::before {
      background:#6b7280;
      box-shadow:0 0 4px #6b7280;
    }
    html.theme-light .impact-low, html[data-theme='light'] .impact-low,
    html.theme-light .impact-minor, html[data-theme='light'] .impact-minor {
      background:#f3f4f6;
      color:#374151;
    }

    .impact-medium, .impact-moderate {
      background:rgba(245,158,11,.15);
      color:#f59e0b;
    }
    .impact-medium::before, .impact-moderate::before {
      background:#f59e0b;
      box-shadow:0 0 4px #f59e0b;
    }
    html.theme-light .impact-medium, html[data-theme='light'] .impact-medium,
    html.theme-light .impact-moderate, html[data-theme='light'] .impact-moderate {
      background:#fef3c7;
      color:#d97706;
    }

    .impact-high, .impact-major {
      background:rgba(239,68,68,.15);
      color:#ef4444;
    }
    .impact-high::before, .impact-major::before {
      background:#ef4444;
      box-shadow:0 0 4px #ef4444;
    }
    html.theme-light .impact-high, html[data-theme='light'] .impact-high,
    html.theme-light .impact-major, html[data-theme='light'] .impact-major {
      background:#fee2e2;
      color:#dc2626;
    }

    .impact-critical, .impact-severe {
      background:rgba(168,85,247,.15);
      color:#a855f7;
    }
    .impact-critical::before, .impact-severe::before {
      background:#a855f7;
      box-shadow:0 0 4px #a855f7;
    }
    html.theme-light .impact-critical, html[data-theme='light'] .impact-critical,
    html.theme-light .impact-severe, html[data-theme='light'] .impact-severe {
      background:#f3e8ff;
      color:#7e22ce;
    }

    /* Generic fallback for any status not explicitly styled */
    .status-badge:not([class*="status-available"]):not([class*="status-in-use"]):not([class*="status-spare"]):not([class*="status-out-of-service"]):not([class*="status-scrapped"]):not([class*="status-scraped"]):not([class*="status-returned"]):not([class*="status-retired"]):not([class*="status-decommissioned"]):not([class*="status-repair"]):not([class*="status-maintenance"]):not([class*="status-calibration"]):not([class*="status-reserved"]):not([class*="status-open"]):not([class*="status-new"]):not([class*="status-investigating"]):not([class*="status-resolved"]):not([class*="status-closed"]):not([class*="status-fixed"]):not([class*="status-escalated"]):not([class*="status-active"]):not([class*="status-passed"]):not([class*="status-completed"]):not([class*="status-pending"]):not([class*="status-overdue"]):not([class*="status-due-soon"]):not([class*="status-in-progress"]):not([class*="status-failed"]):not([class*="status-critical"]) {
      background:rgba(20,184,166,.15);
      color:#14b8a6;
    }
    .status-badge:not([class*="status-available"]):not([class*="status-in-use"]):not([class*="status-spare"]):not([class*="status-out-of-service"]):not([class*="status-scrapped"]):not([class*="status-scraped"]):not([class*="status-returned"]):not([class*="status-retired"]):not([class*="status-decommissioned"]):not([class*="status-repair"]):not([class*="status-maintenance"]):not([class*="status-calibration"]):not([class*="status-reserved"]):not([class*="status-open"]):not([class*="status-new"]):not([class*="status-investigating"]):not([class*="status-resolved"]):not([class*="status-closed"]):not([class*="status-fixed"]):not([class*="status-escalated"]):not([class*="status-active"]):not([class*="status-passed"]):not([class*="status-completed"]):not([class*="status-pending"]):not([class*="status-overdue"]):not([class*="status-due-soon"]):not([class*="status-in-progress"]):not([class*="status-failed"]):not([class*="status-critical"])::before {
      background:#14b8a6;
      box-shadow:0 0 4px #14b8a6;
    }
    html.theme-light .status-badge:not([class*="status-available"]):not([class*="status-in-use"]):not([class*="status-spare"]):not([class*="status-out-of-service"]):not([class*="status-scrapped"]):not([class*="status-scraped"]):not([class*="status-returned"]):not([class*="status-retired"]):not([class*="status-decommissioned"]):not([class*="status-repair"]):not([class*="status-maintenance"]):not([class*="status-calibration"]):not([class*="status-reserved"]):not([class*="status-open"]):not([class*="status-new"]):not([class*="status-investigating"]):not([class*="status-resolved"]):not([class*="status-closed"]):not([class*="status-fixed"]):not([class*="status-escalated"]):not([class*="status-active"]):not([class*="status-passed"]):not([class*="status-completed"]):not([class*="status-pending"]):not([class*="status-overdue"]):not([class*="status-due-soon"]):not([class*="status-in-progress"]):not([class*="status-failed"]):not([class*="status-critical"]),
    html[data-theme='light'] .status-badge:not([class*="status-available"]):not([class*="status-in-use"]):not([class*="status-spare"]):not([class*="status-out-of-service"]):not([class*="status-scrapped"]):not([class*="status-scraped"]):not([class*="status-returned"]):not([class*="status-retired"]):not([class*="status-decommissioned"]):not([class*="status-repair"]):not([class*="status-maintenance"]):not([class*="status-calibration"]):not([class*="status-reserved"]):not([class*="status-open"]):not([class*="status-new"]):not([class*="status-investigating"]):not([class*="status-resolved"]):not([class*="status-closed"]):not([class*="status-fixed"]):not([class*="status-escalated"]):not([class*="status-active"]):not([class*="status-passed"]):not([class*="status-completed"]):not([class*="status-pending"]):not([class*="status-overdue"]):not([class*="status-due-soon"]):not([class*="status-in-progress"]):not([class*="status-failed"]):not([class*="status-critical"]) {
      background:#ccfbf1;
      color:#0f766e;
    }

    /* Equipment Type colors */
    .type-ate, .equipment-ate {
      background:rgba(59,130,246,.15);
      color:#3b82f6;
    }
    .type-ate::before, .equipment-ate::before {
      background:#3b82f6;
      box-shadow:0 0 4px #3b82f6;
    }
    html.theme-light .type-ate, html[data-theme='light'] .type-ate,
    html.theme-light .equipment-ate, html[data-theme='light'] .equipment-ate {
      background:#dbeafe;
      color:#1d4ed8;
    }

    .type-asset, .equipment-asset {
      background:rgba(16,185,129,.15);
      color:#10b981;
    }
    .type-asset::before, .equipment-asset::before {
      background:#10b981;
      box-shadow:0 0 4px #10b981;
    }
    html.theme-light .type-asset, html[data-theme='light'] .type-asset,
    html.theme-light .equipment-asset, html[data-theme='light'] .equipment-asset {
      background:#d1fae5;
      color:#059669;
    }

    .type-fixture, .equipment-fixture {
      background:rgba(249,115,22,.15);
      color:#f97316;
    }
    .type-fixture::before, .equipment-fixture::before {
      background:#f97316;
      box-shadow:0 0 4px #f97316;
    }
    html.theme-light .type-fixture, html[data-theme='light'] .type-fixture,
    html.theme-light .equipment-fixture, html[data-theme='light'] .equipment-fixture {
      background:#fed7aa;
      color:#c2410c;
    }

    .type-harness, .equipment-harness {
      background:rgba(168,85,247,.15);
      color:#a855f7;
    }
    .type-harness::before, .equipment-harness::before {
      background:#a855f7;
      box-shadow:0 0 4px #a855f7;
    }
    html.theme-light .type-harness, html[data-theme='light'] .type-harness,
    html.theme-light .equipment-harness, html[data-theme='light'] .equipment-harness {
      background:#f3e8ff;
      color:#7e22ce;
    }

    /* Method colors */
    .method-internal {
      background:rgba(16,185,129,.15);
      color:#10b981;
    }
    .method-internal::before {
      background:#10b981;
      box-shadow:0 0 4px #10b981;
    }
    html.theme-light .method-internal, html[data-theme='light'] .method-internal {
      background:#d1fae5;
      color:#059669;
    }

    .method-external, .method-vendor {
      background:rgba(59,130,246,.15);
      color:#3b82f6;
    }
    .method-external::before, .method-vendor::before {
      background:#3b82f6;
      box-shadow:0 0 4px #3b82f6;
    }
    html.theme-light .method-external, html[data-theme='light'] .method-external,
    html.theme-light .method-vendor, html[data-theme='light'] .method-vendor {
      background:#dbeafe;
      color:#1d4ed8;
    }

    /* Attachment Links */
    .attachment-link {
      color:#4d8dff;
      text-decoration:none;
      font-weight:500;
      transition:all .2s ease;
    }
    .attachment-link:hover {
      color:#2563eb;
      text-decoration:underline;
    }
    html.theme-light .attachment-link, html[data-theme='light'] .attachment-link {
      color:#2563eb;
    }
    html.theme-light .attachment-link:hover, html[data-theme='light'] .attachment-link:hover {
      color:#1d4ed8;
    }

    /* Toggle Switches */
    .toggle-switch {
      display:inline-flex;
      align-items:center;
      gap:6px;
      padding:5px 10px;
      border-radius:20px;
      font-size:9px;
      font-weight:600;
      letter-spacing:.3px;
      text-transform:uppercase;
      cursor:default;
      transition:all 0.3s ease;
      min-width:70px;
      white-space:nowrap;
    }

    .toggle-label {
      flex-shrink:0;
    }

    .toggle-slider {
      position:relative;
      width:32px;
      height:16px;
      border-radius:12px;
      transition:all 0.3s ease;
      flex-shrink:0;
    }

    .toggle-slider::before {
      content:'';
      position:absolute;
      width:12px;
      height:12px;
      border-radius:50%;
      top:2px;
      transition:all 0.3s ease;
      box-shadow:0 2px 4px rgba(0,0,0,0.2);
    }

    /* Toggle ON state */
    .toggle-on {
      color:#10b981;
    }

    .toggle-on .toggle-slider {
      background:#10b981;
    }

    .toggle-on .toggle-slider::before {
      background:#ffffff;
      left:16px;
    }

    /* Toggle OFF state */
    .toggle-off {
      color:#ef4444;
    }

    .toggle-off .toggle-slider {
      background:#ef4444;
    }

    .toggle-off .toggle-slider::before {
      background:#ffffff;
      left:4px;
    }

    /* Light mode adjustments */
    html.theme-light .toggle-on, html[data-theme='light'] .toggle-on {
      color:#059669;
    }

    html.theme-light .toggle-on .toggle-slider, html[data-theme='light'] .toggle-on .toggle-slider {
      background:#059669;
    }

    html.theme-light .toggle-off, html[data-theme='light'] .toggle-off {
      color:#dc2626;
    }

    html.theme-light .toggle-off .toggle-slider, html[data-theme='light'] .toggle-off .toggle-slider {
      background:#dc2626;
    }

    /* Center toggle switches */
    table[id*="gridCalibration"] .toggle-switch {
      display: flex;
      justify-content: center;
      align-items: center;
    }

    /* Empty State */
    .empty-state {
      text-align:center;
      padding:80px 20px;
      opacity:.6;
    }
    .empty-state svg {
      width:64px;
      height:64px;
      margin-bottom:16px;
      opacity:.5;
    }
    .empty-state-title {
      font-size:18px;
      font-weight:600;
      margin-bottom:8px;
    }
    .empty-state-message {
      font-size:13px;
      opacity:.8;
    }

    /* Column Widths */
    .col-calibration-log-id { width:140px; }
    .col-equipment-type { width:100px; }
    .col-equipment-name { width:200px; }
    .col-equipment-eaton-id { width:120px; }
    .col-method { width:100px; }
    .col-prev-due-date { width:120px; }
    .col-calibration-date { width:120px; }
    .col-status { width:100px; }
    .col-calibration-by { width:120px; }
    .col-vendor-name { width:150px; }
    .col-calibration-certificate { width:180px; }
    .col-calibration-standard { width:180px; }
    .col-cost { width:100px; }
    .col-result-code { width:100px; }
    .col-calibration-results { width:250px; }
    .col-start-date { width:120px; }
    .col-sent-out-date { width:120px; }
    .col-received-date { width:120px; }
    .col-next-due-date { width:120px; }
    .col-is-on-time { width:80px; }
    .col-is-out-of-tolerance { width:130px; }
    .col-turnaround-days { width:80px; }
    .col-vendor-lead-days { width:80px; }
    .col-comments { width:250px; }
    .col-attachments-path { width:200px; }

    table[id*="gridCalibration"] tbody td[title]:hover::before {
      content: '';
      position: absolute;
      bottom: 100%;
      left: 50%;
      transform: translateX(-50%) translateY(-1px);
      border: 6px solid transparent;
      border-top-color: #1e293b;
      z-index: 1001;
      pointer-events: none;
    }

    html.theme-light table[id*="gridCalibration"] tbody td[title]:hover::after,
    html[data-theme='light'] table[id*="gridCalibration"] tbody td[title]:hover::after {
      background: linear-gradient(135deg, #ffffff 0%, #f8fafc 100%);
      color: #0f172a;
      border: 1px solid rgba(15, 23, 42, 0.08);
      box-shadow: 0 10px 25px rgba(0, 0, 0, 0.12), 0 4px 10px rgba(0, 0, 0, 0.08);
    }

    html.theme-light table[id*="gridCalibration"] tbody td[title]:hover::before,
    html[data-theme='light'] table[id*="gridCalibration"] tbody td[title]:hover::before {
      border-top-color: #ffffff;
    }

    table[id*="gridCalibration"] tbody td[title] {
      position: relative;
    }

    @media (max-width:1200px) {
      .grid-view-container { padding:14px; }
      .filter-grid { grid-template-columns:1fr; }
    }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePartialRendering="true" />

        <!-- Top Bar (Same as Site.master) -->
        <header class="topbar" role="banner">
            <div class="topbar-inner">
                <div class="topbar-brand">
                    <div class="logo-icon" aria-hidden="true">
                        <svg viewBox="0 0 24 24" width="16" height="16" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
                            <path d="M13 2 3 14h9l-1 8 10-12h-9l1-8Z"/>
                        </svg>
                    </div>
                    <div class="brand-stack">
                        <div class="brand-row">
                            <span class="eaton-badge">Eaton YPO</span>
                            <span class="internal-text">INTERNAL</span>
                            <span class="brand-sub-inline">Test Engineering</span>
                        </div>
                    </div>
                </div>
                <div class="topbar-right">
                    <button type="button" class="theme-toggle theme-toggle--sm" data-theme-toggle aria-label="Toggle theme" title="Toggle theme">
                        <span class="toggle-icon" aria-hidden="true">
                            <svg class="icon-moon" viewBox="0 0 24 24" fill="none" stroke="none">
                                <path fill="currentColor" d="M12.9 2.1c.6 0 .9.7.6 1.2A8.8 8.8 0 0 0 12 7.5a8.5 8.5 0 0 0 8.5 8.5c1.6 0 3.2-.4 4.2-.8.6-.2 1.1.4.8 1A11 11 0 1 1 12.9 2.1Z"/>
                            </svg>
                            <svg class="icon-sun" viewBox="0 0 24 24" fill="none" stroke="none">
                                <circle cx="12" cy="12" r="5" fill="currentColor"/>
                                <g stroke="currentColor" stroke-width="1.8" stroke-linecap="round">
                                    <line x1="12" y1="1.6" x2="12" y2="4.2" />
                                    <line x1="12" y1="19.8" x2="12" y2="22.4" />
                                    <line x1="4.2" y1="12" x2="1.6" y2="12" />
                                    <line x1="22.4" y1="12" x2="19.8" y2="12" />
                                    <line x1="5.8" y1="5.8" x2="4" y2="4" />
                                    <line x1="20" y1="20" x2="18.2" y2="18.2" />
                                    <line x1="18.2" y1="5.8" x2="20" y2="4" />
                                    <line x1="4" y1="20" x2="5.8" y2="18.2" />
                                </g>
                            </svg>
                        </span>
                    </button>
                </div>
            </div>
        </header>
        <div class="content-spacer"></div>

        <!-- Main Content -->
        <div class="grid-view-container">
            <!-- Page Header -->
            <div class="page-header">
                <div>
                    <h1 class="page-title">Calibration Logs Grid View</h1>
                    <div class="page-subtitle">Complete calibration logs across all equipment types</div>
                </div>
            </div>

            <!-- Filter Panel (Expandable/Collapsible) -->
            <div class="filter-panel">
                <div class="filter-header">
                    <div class="filter-header-left">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <polygon points="22 3 2 3 10 12.46 10 19 14 21 14 12.46 22 3"></polygon>
                        </svg>
                        Advanced Filters &amp; Search <span id="activeFilterCount" class="filter-count" style="display:none;"></span>
                    </div>
                    <div class="filter-header-right">
                        <button type="button" class="btn-reset-icon" onclick="event.stopPropagation(); resetAllFilters();" title="Reset All Filters">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M3 12a9 9 0 0 1 9-9 9.75 9.75 0 0 1 6.74 2.74L21 8"></path>
                                <path d="M21 3v5h-5"></path>
                                <path d="M21 12a9 9 0 0 1-9 9 9.75 9.75 0 0 1-6.74-2.74L3 16"></path>
                                <path d="M3 21v-5h5"></path>
                            </svg>
                        </button>
                        <div class="filter-toggle">
                            <span id="filterToggleText">COLLAPSE</span>
                            <svg class="filter-toggle-icon" id="filterToggleIcon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                                <polyline points="6 9 12 15 18 9"></polyline>
                            </svg>
                        </div>
                    </div>
                </div>
                <div class="filter-content" id="filterContent">
                    <!-- Basic Search & Status Section -->
                    <div class="filter-section">
                        <div class="filter-section-title">BASIC SEARCH</div>
                        <div class="filter-grid filter-grid-4col">
                            <div class="filter-group">
                                <label class="filter-label">Global Search</label>
                                <asp:TextBox ID="txtSearch" runat="server" CssClass="filter-input"
                                             placeholder="CalibrationLogID, Equipment Name, Vendor..."
                                             AutoPostBack="true" OnTextChanged="ApplyFilters" />
                            </div>
                            <div class="filter-group">
                                <label class="filter-label">Status</label>
                                <asp:DropDownList ID="ddlStatus" runat="server" CssClass="filter-select"
                                                  AutoPostBack="true" OnSelectedIndexChanged="ApplyFilters">
                                    <asp:ListItem Text="All Status" Value="ALL" Selected="True" />
                                </asp:DropDownList>
                            </div>
                            <div class="filter-group">
                                <label class="filter-label">Result Code</label>
                                <asp:DropDownList ID="ddlResultCode" runat="server" CssClass="filter-select"
                                                  AutoPostBack="true" OnSelectedIndexChanged="ApplyFilters">
                                    <asp:ListItem Text="All Results" Value="ALL" Selected="True" />
                                </asp:DropDownList>
                            </div>
                            <div class="filter-group">
                                <label class="filter-label">Method</label>
                                <asp:DropDownList ID="ddlMethod" runat="server" CssClass="filter-select"
                                                  AutoPostBack="true" OnSelectedIndexChanged="ApplyFilters">
                                    <asp:ListItem Text="All Methods" Value="ALL" Selected="True" />
                                </asp:DropDownList>
                            </div>
                        </div>
                    </div>

                    <!-- Equipment Section -->
                    <div class="filter-section">
                        <div class="filter-section-title">EQUIPMENT FILTERS</div>
                        <div class="filter-grid filter-grid-4col">
                            <div class="filter-group">
                                <label class="filter-label">Equipment Type</label>
                                <asp:DropDownList ID="ddlEquipmentType" runat="server" CssClass="filter-select"
                                                  AutoPostBack="true" OnSelectedIndexChanged="ApplyFilters">
                                    <asp:ListItem Text="All Types" Value="ALL" Selected="True" />
                                </asp:DropDownList>
                            </div>
                            <div class="filter-group">
                                <label class="filter-label">Equipment Name</label>
                                <asp:DropDownList ID="ddlEquipmentName" runat="server" CssClass="filter-select"
                                                  AutoPostBack="true" OnSelectedIndexChanged="ApplyFilters">
                                    <asp:ListItem Text="All Equipment" Value="ALL" Selected="True" />
                                </asp:DropDownList>
                            </div>
                            <div class="filter-group">
                                <label class="filter-label">Eaton ID</label>
                                <asp:DropDownList ID="ddlEquipmentEatonID" runat="server" CssClass="filter-select"
                                                  AutoPostBack="true" OnSelectedIndexChanged="ApplyFilters">
                                    <asp:ListItem Text="All Eaton IDs" Value="ALL" Selected="True" />
                                </asp:DropDownList>
                            </div>
                            <div class="filter-group">
                                <label class="filter-label">Vendor Name</label>
                                <asp:DropDownList ID="ddlVendorName" runat="server" CssClass="filter-select"
                                                  AutoPostBack="true" OnSelectedIndexChanged="ApplyFilters">
                                    <asp:ListItem Text="All Vendors" Value="ALL" Selected="True" />
                                </asp:DropDownList>
                            </div>
                        </div>
                    </div>

                    <!-- Action Buttons -->
                    <div class="filter-actions">
                        <asp:Button ID="btnReset" runat="server" Text="Reset All Filters"
                                    CssClass="btn-reset" OnClick="ResetFilters" />
                    </div>
                </div>
            </div>

            <!-- Table Container -->
            <div class="table-container">
                <div class="table-header">
                    <div class="table-title">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect>
                            <line x1="3" y1="9" x2="21" y2="9"></line>
                            <line x1="9" y1="21" x2="9" y2="9"></line>
                        </svg>
                        Calibration Logs
                        <span class="record-count">(<asp:Literal ID="litRecordCount" runat="server" Text="0" /> records)</span>
                    </div>
                    <div class="table-actions">
                        <button type="button" class="btn-icon-action" title="Export to CSV"
                                onclick="document.getElementById('<%=btnExportCSV.ClientID%>').click(); return false;">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path>
                                <polyline points="7 10 12 15 17 10"></polyline>
                                <line x1="12" y1="15" x2="12" y2="3"></line>
                            </svg>
                            Export CSV
                        </button>
                        <asp:Button ID="btnExportCSV" runat="server" OnClick="ExportToCSV" style="display:none;" />
                        <button type="button" class="btn-icon-action" title="Refresh" onclick="location.reload();">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <polyline points="23 4 23 10 17 10"></polyline>
                                <polyline points="1 20 1 14 7 14"></polyline>
                                <path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15"></path>
                            </svg>
                            Refresh
                        </button>
                    </div>
                </div>
                <div class="table-wrap">
                    <asp:GridView ID="gridCalibration" runat="server" CssClass="data-table"
                                  AutoGenerateColumns="False" OnRowDataBound="gridCalibration_RowDataBound">
                    </asp:GridView>
                    <asp:Panel ID="pnlEmptyState" runat="server" Visible="false" CssClass="empty-state">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <circle cx="11" cy="11" r="8"></circle>
                            <path d="M21 21l-4.35-4.35"></path>
                        </svg>
                        <div class="empty-state-title">No Calibration Logs Found</div>
                        <div class="empty-state-message">Try adjusting your filters or search criteria</div>
                    </asp:Panel>
                </div>
            </div>
        </div>
    </form>

    <script>
        // Filter toggle functionality with localStorage persistence
        function toggleFilters() {
            var content = document.getElementById('filterContent');
            var icon = document.getElementById('filterToggleIcon');
            var text = document.getElementById('filterToggleText');

            if (content.classList.contains('collapsed')) {
                // Expand
                content.classList.remove('collapsed');
                icon.classList.remove('collapsed');
                text.textContent = 'COLLAPSE';
                localStorage.setItem('calibrationGridFiltersExpanded', 'true');
            } else {
                // Collapse
                content.classList.add('collapsed');
                icon.classList.add('collapsed');
                text.textContent = 'EXPAND';
                localStorage.setItem('calibrationGridFiltersExpanded', 'false');
            }
        }

        // Reset all filters
        function resetAllFilters() {
            // Trigger the server-side reset button
            document.getElementById('<%= btnReset.ClientID %>').click();
        }

        // Restore filter state on page load
        window.addEventListener('DOMContentLoaded', function() {
            var content = document.getElementById('filterContent');
            var icon = document.getElementById('filterToggleIcon');
            var text = document.getElementById('filterToggleText');
            var isExpanded = localStorage.getItem('calibrationGridFiltersExpanded');

            // Default to COLLAPSED on first visit, then remember user preference
            if (isExpanded === 'true') {
                // User previously expanded it
                content.classList.remove('collapsed');
                icon.classList.remove('collapsed');
                text.textContent = 'COLLAPSE';
            } else {
                // Default: Start collapsed
                content.classList.add('collapsed');
                icon.classList.add('collapsed');
                text.textContent = 'EXPAND';
            }

            // Initialize filter count
            updateFilterCount();

            // Add row click handlers for table highlighting
            initializeRowHighlighting();

            // Initialize sticky header (CSS-based)
            initializeStickyHeader();

            // Debug: Log table info
            console.log('=== Calibration Grid View Initialized ===');
            var table = document.getElementById('<%= gridCalibration.ClientID %>');
            if (table) {
                console.log('Table found:', table.tagName);
                console.log('Table ID:', table.id);
                console.log('Header rows:', table.querySelectorAll('.grid-header-row').length);
                console.log('Data rows:', table.querySelectorAll('tbody tr').length);
                console.log('Total columns:', table.querySelectorAll('.grid-header-row th').length);
            } else {
                console.error('Table not found!');
            }
        });

        // Count and display active filters
        function updateFilterCount() {
            var count = 0;
            var countBadge = document.getElementById('activeFilterCount');

            // Check text search
            var searchBox = document.getElementById('<%= txtSearch.ClientID %>');
            if (searchBox) {
                if (searchBox.value.trim() !== '') {
                    count++;
                    searchBox.classList.add('filter-active');
                } else {
                    searchBox.classList.remove('filter-active');
                }
            }

            // Check all dropdowns
            var dropdowns = [
                '<%= ddlStatus.ClientID %>',
                '<%= ddlResultCode.ClientID %>',
                '<%= ddlMethod.ClientID %>',
                '<%= ddlEquipmentType.ClientID %>',
                '<%= ddlEquipmentName.ClientID %>',
                '<%= ddlEquipmentEatonID.ClientID %>',
                '<%= ddlVendorName.ClientID %>'
            ];

            dropdowns.forEach(function(id) {
                var dd = document.getElementById(id);
                if (dd) {
                    if (dd.value !== 'ALL') {
                        count++;
                        dd.classList.add('filter-active');
                    } else {
                        dd.classList.remove('filter-active');
                    }
                }
            });

            // Update badge
            if (count > 0) {
                countBadge.textContent = '(' + count + ')';
                countBadge.style.display = 'inline-flex';
            } else {
                countBadge.style.display = 'none';
            }
        }

        // Initialize row click highlighting
        function initializeRowHighlighting() {
            var table = document.getElementById('<%= gridCalibration.ClientID %>');
            if (!table) return;

            var rows = table.querySelectorAll('tbody tr');
            rows.forEach(function(row) {
                row.style.cursor = 'pointer';
                row.addEventListener('click', function() {
                    // Remove highlight from all rows
                    rows.forEach(function(r) {
                        r.classList.remove('row-selected');
                    });
                    // Add highlight to clicked row
                    this.classList.add('row-selected');
                });
            });
        }

        // Enhanced sticky header functionality
        function initializeStickyHeader() {
            // Sticky header is now handled purely by CSS
            // The .grid-header-row is position: sticky within the .table-wrap container
            console.log('Sticky header initialized via CSS');
        }

        // Load theme script dynamically to avoid linter issues
        (function() {
            var script = document.createElement('script');
            script.src = '<%= ResolveUrl("~/Scripts/theme.js") %>' + '?v=20250924-02';
            document.body.appendChild(script);
        })();
    </script>
</body>
</html>