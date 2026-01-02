<%@ Page Title="PM Log Details" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="PMDetails.aspx.cs" Inherits="TED_PMDetails" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        /* Admin shell layout */
        .admin-grid { display:grid; grid-template-columns:240px 1fr; gap:16px; height:calc(100vh - 65px); padding:16px; box-sizing:border-box; }
        @media (max-width:980px){ .admin-grid { grid-template-columns:1fr; height:auto; } }
        
        /* Main content wrapper - make scrollable */
        .admin-main { overflow-y:auto; overflow-x:hidden; }
        
        /* Admin form container */
        .admin-form { background:rgba(25,29,37,.52); border:1px solid rgba(255,255,255,.08); border-radius:14px; padding:20px; box-shadow:0 16px 34px -12px rgba(0,0,0,.6), 0 0 0 1px rgba(255,255,255,.05); }
        html.theme-light .admin-form, html[data-theme='light'] .admin-form { background:#ffffff; border:1px solid rgba(0,0,0,.08); box-shadow:0 16px 34px -12px rgba(0,0,0,.16), 0 0 0 1px rgba(0,0,0,.05); }
        
        /* Form grid - 3 columns per row */
        .form-grid { display:grid; grid-template-columns: repeat(12, 1fr); gap:16px; margin-bottom:16px; }
        .span-4 { grid-column: span 4; }
        .span-6 { grid-column: span 6; }
        .span-8 { grid-column: span 8; }
        .span-12 { grid-column: 1 / -1; }
        @media (max-width: 980px){ .span-4, .span-6, .span-8 { grid-column: 1 / -1; } }

        .form-group { display:flex; flex-direction:column; }
        .form-group label { font-size:12px; font-weight:600; opacity:.9; margin-bottom:6px; display:block; color:inherit; }
        
        /* Inputs and selects */
        .form-group input[type="text"],
        .form-group input[type="date"],
        .form-group input[type="datetime-local"],
        .form-group input[type="number"],
        .form-group textarea,
        .form-group select { width:100%; padding:10px 12px; border-radius:12px; border:1px solid rgba(255,255,255,.14); background:rgba(0,0,0,.15); color:inherit; font-size:13px; font-family:inherit; box-sizing:border-box; min-height:38px; }
        .form-group input:focus,
        .form-group textarea:focus,
        .form-group select:focus { outline:none; border-color:rgba(77,141,255,.5); box-shadow:0 0 0 3px rgba(77,141,255,.15); }
        
        /* Dropdown options styling for dark mode */
        .form-group select option { background:#1f242b; color:#e2e8f0; padding:8px; }
        
        html.theme-light .form-group input,
        html.theme-light .form-group textarea,
        html.theme-light .form-group select,
        html[data-theme='light'] .form-group input,
        html[data-theme='light'] .form-group textarea,
        html[data-theme='light'] .form-group select { background:#fff; border:1px solid rgba(0,0,0,.14); color:#1f242b; }
        
        html.theme-light .form-group select option,
        html[data-theme='light'] .form-group select option { background:#ffffff; color:#1f242b; }
        
        /* Textarea sizing */
        .form-group textarea { resize: vertical; min-height: 100px; }
        
        /* Disabled/readonly fields */
        .form-group input:disabled,
        .form-group textarea:disabled,
        .form-group select:disabled { opacity:0.6; cursor:not-allowed; background:rgba(0,0,0,.08); }
        html.theme-light .form-group input:disabled,
        html.theme-light .form-group textarea:disabled,
        html.theme-light .form-group select:disabled { background:rgba(0,0,0,.04); }
        
        /* Section headers */
        .section-header { font-size:16px; font-weight:600; margin:24px 0 16px 0; padding-bottom:8px; border-bottom:1px solid rgba(255,255,255,.1); }
        html.theme-light .section-header, html[data-theme='light'] .section-header { border-bottom-color:rgba(0,0,0,.1); }
        
        /* Buttons */
        .actions { margin-top:24px; display:flex; gap:12px; align-items:center; justify-content:flex-start; flex-wrap:wrap; }
        .btn { padding:10px 16px; border-radius:12px; border:1px solid rgba(255,255,255,.14); text-decoration:none; cursor:pointer; transition:all .2s ease; font-size:13px; font-weight:500; display:inline-flex; align-items:center; justify-content:center; gap:8px; }
        .btn .icon { width:16px; height:16px; }
        .btn.primary { background:linear-gradient(155deg,#0b4a3d,#0a3a31); color:#e6fff7; border-color:rgba(64,180,120,.35); }
        .btn.primary:hover { transform:translateY(-1px); box-shadow:0 10px 20px -10px rgba(0,0,0,.65), 0 0 0 1px rgba(64,180,120,.35); }
        .btn.secondary { background:rgba(77,141,255,.15); color:#8eb4ff; border-color:rgba(77,141,255,.25); }
        .btn.secondary:hover { background:rgba(77,141,255,.25); color:#b3d0ff; transform:translateY(-1px); }
        .btn.clean { background:rgba(255,255,255,.08); color:#d6dde4; border-color:rgba(255,255,255,.18); }
        .btn.clean:hover { background:rgba(255,255,255,.16); color:#ffffff; border-color:rgba(255,255,255,.28); transform:translateY(-1px); }
        .btn.danger { background:rgba(220,38,38,.15); color:#fca5a5; border-color:rgba(220,38,38,.25); }
        .btn.danger:hover { background:rgba(220,38,38,.25); color:#fecaca; transform:translateY(-1px); }
        
        html.theme-light .btn, html[data-theme='light'] .btn { border:1px solid rgba(0,0,0,.12); }
        html.theme-light .btn.primary, html[data-theme='light'] .btn.primary { background:#1fa37e; color:#ffffff; }
        html.theme-light .btn.secondary, html[data-theme='light'] .btn.secondary { background:#4d8dff; color:#ffffff; }
        html.theme-light .btn.clean, html[data-theme='light'] .btn.clean { background:rgba(0,0,0,.045); color:#2c333b; border-color:rgba(0,0,0,.16); }
        html.theme-light .btn.danger, html[data-theme='light'] .btn.danger { background:#dc2626; color:#ffffff; }
        
        /* Toast notification */
        .toast { position:fixed; right:16px; bottom:16px; background:#1e293b; color:#fff; border-radius:10px; padding:12px 14px; box-shadow:0 10px 24px rgba(0,0,0,.5); z-index:9999; opacity:0; transform:translateY(16px); transition:all .25s ease; }
        .toast.show { opacity:1; transform:translateY(0); }
        .toast-success { background:#059669; border-left:4px solid #10b981; }
        .toast-error { background:#dc2626; border-left:4px solid #f87171; }
        .toast-info { background:#2563eb; border-left:4px solid #60a5fa; }
        
        /* Banner notification */
        .msg-banner { padding:12px 16px; border-radius:10px; margin-bottom:20px; position:relative; display:flex; align-items:center; justify-content:space-between; font-size:14px; font-weight:500; }
        .msg-banner button.close { background:none; border:none; color:currentColor; cursor:pointer; padding:4px; margin-left:12px; border-radius:4px; opacity:0.7; transition:opacity .2s ease; }
        .msg-banner button.close:hover { opacity:1; background:rgba(255,255,255,.1); }
        .msg-banner-success { background:rgba(34,197,94,.15); border:1px solid rgba(34,197,94,.25); color:#16a34a; }
        .msg-banner-error { background:rgba(239,68,68,.15); border:1px solid rgba(239,68,68,.25); color:#dc2626; }
        .msg-banner-info { background:rgba(59,130,246,.15); border:1px solid rgba(59,130,246,.25); color:#2563eb; }
        
        /* Sidebar styling */
        .sidebar { 
            position:sticky; 
            top:12px; 
            height:calc(100% - 12px); 
            display:flex; 
            flex-direction:column; 
            background:rgba(25,29,37,.55); 
            border:1px solid rgba(255,255,255,.08); 
            border-radius:18px; 
            box-shadow:0 16px 36px -10px rgba(0,0,0,.6), 0 0 0 1px rgba(255,255,255,.05), 0 0 10px rgba(235,235,240,.12); 
            backdrop-filter:blur(40px) saturate(140%); 
            padding:16px 14px; 
            overflow:auto; 
        }
        html.theme-light .sidebar, html[data-theme='light'] .sidebar { 
            background:rgba(255,255,255,.7); 
            border:1px solid rgba(0,0,0,.08); 
            box-shadow:0 14px 34px -12px rgba(0,0,0,.25), 0 0 0 1px rgba(0,0,0,.05), 0 0 10px rgba(0,0,0,.12); 
        }
        
        .sidebar-section { margin-bottom:0; padding:8px 4px; }
        
        .sidebar-title { 
            font-size:12px; 
            letter-spacing:.8px; 
            opacity:.9; 
            font-weight:800; 
            text-transform:uppercase; 
            padding:6px 12px 8px; 
            border-bottom:1px solid rgba(255,255,255,.08); 
            margin-bottom:8px; 
        }
        html.theme-light .sidebar-title, html[data-theme='light'] .sidebar-title { border-bottom:1px solid rgba(0,0,0,.08); }
        
        .sidebar-header { 
            font-size:11px; 
            letter-spacing:.6px; 
            opacity:.65; 
            padding:12px 12px 6px; 
            text-transform:uppercase; 
        }
        
        .sidebar-nav { list-style:none; padding:0; margin:0; }
        .sidebar-nav li { margin-bottom:0; }
        .sidebar-nav a { 
            display:flex; 
            align-items:center; 
            gap:10px; 
            padding:10px 12px; 
            margin:2px 6px; 
            border-radius:12px; 
            text-decoration:none; 
            color:inherit; 
            border:1px solid transparent; 
            transition:background .25s ease, color .25s ease, border-color .25s ease; 
            font-size:13px;
        }
        .sidebar-nav a .icon { width:16px; height:16px; color:currentColor; opacity:.9; flex-shrink:0; }
        
        .sidebar-nav a:hover { 
            background:rgba(255,255,255,.08); 
            border-color:rgba(255,255,255,.12); 
        }
        html.theme-light .sidebar-nav a:hover, html[data-theme='light'] .sidebar-nav a:hover { 
            background:rgba(0,0,0,.055); 
            border-color:rgba(0,0,0,.10); 
        }
        
        .sidebar-nav a.active { 
            background:rgba(77,141,255,.13); 
            border-color:rgba(77,141,255,.3); 
            color:#bcd4ff; 
        }
        html.theme-light .sidebar-nav a.active, html[data-theme='light'] .sidebar-nav a.active { 
            background:#ffffff; 
            border-color:rgba(77,141,255,.35); 
            color:#1f2530; 
            box-shadow:0 1px 0 rgba(255,255,255,.7) inset; 
        }
        
        /* Danger/Red style for Back link */
        .sidebar-nav a.danger { 
            color:#ff6b6b; 
            border-color:transparent; 
        }
        .sidebar-nav a.danger .icon { color:currentColor; }
        .sidebar-nav a.danger:hover { 
            background:rgba(255,86,86,.14); 
            border-color:rgba(255,86,86,.35); 
            color:#ff8a8a; 
        }
        html.theme-light .sidebar-nav a.danger { color:#c62828; }
        html.theme-light .sidebar-nav a.danger:hover { 
            background:rgba(198,40,40,.10); 
            border-color:rgba(198,40,40,.35); 
            color:#b71c1c; 
        }
        
        .sidebar-spacer { flex:1; }
        
        /* Page header */
        .page-header { margin-bottom:20px; display:flex; justify-content:space-between; align-items:flex-start; gap:16px; flex-wrap:wrap; }
        .page-header-left { flex:1; min-width:0; }
        .page-header h1 { font-size:24px; font-weight:700; margin:0 0 8px 0; }
        .page-header .subtitle { font-size:14px; opacity:.7; }
        
        /* PM selector dropdown */
        .pm-selector { min-width:240px; }
        .pm-selector select { 
            width:100%; 
            padding:10px 12px; 
            border-radius:12px; 
            border:1px solid rgba(147,51,234,.35); 
            background:linear-gradient(155deg, rgba(168,85,247,.18), rgba(147,51,234,.12)); 
            color:inherit; 
            font-size:13px; 
            font-family:inherit; 
            box-sizing:border-box;
            font-weight:600;
            box-shadow:0 2px 8px rgba(147,51,234,.15);
        }
        .pm-selector select option {
            background:#1f242b;
            color:#e2e8f0;
            padding:8px;
        }
        .pm-selector select:focus { 
            outline:none; 
            border-color:rgba(147,51,234,.6); 
            box-shadow:0 0 0 3px rgba(147,51,234,.2), 0 2px 8px rgba(147,51,234,.25); 
        }
        html.theme-light .pm-selector select, html[data-theme='light'] .pm-selector select { 
            background:linear-gradient(155deg, #f3e8ff, #e9d5ff); 
            border:1px solid rgba(147,51,234,.4); 
            color:#6b21a8; 
            box-shadow:0 2px 6px rgba(147,51,234,.2);
        }
        html.theme-light .pm-selector select option, html[data-theme='light'] .pm-selector select option {
            background:#ffffff;
            color:#333333;
        }
        html.theme-light .pm-selector select:focus, html[data-theme='light'] .pm-selector select:focus { 
            border-color:rgba(126,34,206,.6); 
            box-shadow:0 0 0 3px rgba(147,51,234,.15), 0 2px 8px rgba(147,51,234,.3); 
        }
        
        /* Field Validation Glow Effects */
        .form-group.field-filled input,
        .form-group.field-filled select,
        .form-group.field-filled textarea {
            border-color: rgba(16, 185, 129, 0.6) !important;
            box-shadow: 0 0 0 3px rgba(16, 185, 129, 0.15) !important;
        }
        .form-group.field-empty-required input,
        .form-group.field-empty-required select,
        .form-group.field-empty-required textarea {
            border-color: rgba(239, 68, 68, 0.6) !important;
            box-shadow: 0 0 0 3px rgba(239, 68, 68, 0.15) !important;
        }
        .form-group.field-empty-optional input,
        .form-group.field-empty-optional select,
        .form-group.field-empty-optional textarea {
            border-color: rgba(245, 158, 11, 0.6) !important;
            box-shadow: 0 0 0 3px rgba(245, 158, 11, 0.15) !important;
        }
        .form-group input:disabled,
        .form-group select:disabled,
        .form-group textarea:disabled {
            border-color: rgba(255,255,255,.14) !important;
            box-shadow: none !important;
        }
        
        /* File upload styling */
        .file-upload { 
            padding:12px; 
            border-radius:12px; 
            border:2px dashed rgba(255,255,255,.2); 
            background:rgba(0,0,0,.1); 
            cursor:pointer; 
            transition:all .2s ease; 
        }
        .file-upload:hover { 
            border-color:rgba(77,141,255,.4); 
            background:rgba(77,141,255,.08); 
        }
        html.theme-light .file-upload, html[data-theme='light'] .file-upload { 
            background:#f8f9fa; 
            border-color:rgba(0,0,0,.2); 
        }
        html.theme-light .file-upload:hover, html[data-theme='light'] .file-upload:hover { 
            border-color:rgba(77,141,255,.6); 
            background:rgba(77,141,255,.08); 
        }
        
        /* Attachments display */
        .attachments-list { 
            display:flex; 
            flex-wrap:wrap; 
            gap:12px; 
            margin-top:8px; 
        }
        .attachment-item-wrapper {
            display:flex;
            align-items:center;
            gap:6px;
        }
        .attachment-item { 
            display:flex; 
            align-items:center; 
            gap:8px; 
            padding:8px 12px; 
            background:rgba(0,0,0,.15); 
            border:1px solid rgba(255,255,255,.12); 
            border-radius:10px; 
            font-size:12px; 
            text-decoration:none; 
            color:inherit; 
            transition:all .2s ease; 
        }
        .attachment-item:hover { 
            background:rgba(77,141,255,.15); 
            border-color:rgba(77,141,255,.3); 
            transform:translateY(-1px); 
        }
        .attachment-item .icon { 
            width:16px; 
            height:16px; 
            opacity:.7; 
        }
        .delete-btn { 
            display:inline-flex;
            align-items:center;
            justify-content:center;
            width:22px;
            height:22px;
            padding:4px;
            background:rgba(220,38,38,.15);
            border:1px solid rgba(220,38,38,.25);
            border-radius:6px;
            color:#fca5a5; 
            cursor:pointer; 
            text-decoration:none;
            transition:all .2s ease; 
        }
        .delete-btn:hover { 
            background:rgba(220,38,38,.25);
            border-color:rgba(220,38,38,.4);
            color:#fecaca;
            transform:translateY(-1px);
        }
        .delete-btn .icon {
            width:12px;
            height:12px;
        }
        html.theme-light .attachment-item, html[data-theme='light'] .attachment-item { 
            background:#ffffff; 
            border-color:rgba(0,0,0,.12); 
        }
        html.theme-light .attachment-item:hover, html[data-theme='light'] .attachment-item:hover { 
            background:rgba(77,141,255,.08); 
            border-color:rgba(77,141,255,.4); 
        }
        html.theme-light .delete-btn, html[data-theme='light'] .delete-btn {
            background:#dc2626;
            border-color:#dc2626;
            color:#ffffff;
        }
        html.theme-light .delete-btn:hover, html[data-theme='light'] .delete-btn:hover {
            background:#b91c1c;
            border-color:#b91c1c;
        }

        /* Searchable Dropdown Styles */
        .searchable-dropdown {
            position: relative;
        }

        .searchable-input {
            width: 100%;
            padding: 10px 12px;
            border-radius: 12px;
            border: 1px solid rgba(255,255,255,.14);
            background: rgba(0,0,0,.15);
            color: inherit;
            font-size: 13px;
            font-family: inherit;
            box-sizing: border-box;
            min-height: 38px;
            cursor: text;
        }

        .searchable-input:focus {
            outline: none;
            border-color: rgba(77,141,255,.5);
            box-shadow: 0 0 0 3px rgba(77,141,255,.15);
        }

        html.theme-light .searchable-input,
        html[data-theme='light'] .searchable-input {
            background: #fff;
            border: 1px solid rgba(0,0,0,.14);
            color: #1f242b;
        }

        .searchable-list {
            position: absolute;
            top: 100%;
            left: 0;
            right: 0;
            background: rgba(25,29,37,.95);
            border: 1px solid rgba(255,255,255,.12);
            border-radius: 12px;
            max-height: 200px;
            overflow-y: auto;
            z-index: 1000;
            display: none;
            margin-top: 2px;
            box-shadow: 0 8px 24px rgba(0,0,0,.24), 0 0 0 1px rgba(255,255,255,.08);
            backdrop-filter: blur(20px);
        }

        .searchable-list.open {
            display: block;
        }

        html.theme-light .searchable-list,
        html[data-theme='light'] .searchable-list {
            background: #ffffff;
            border: 1px solid rgba(0, 0, 0, 0.14);
            box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12), 0 0 0 1px rgba(0, 0, 0, 0.05);
        }

        .searchable-item {
            padding: 10px 12px;
            cursor: pointer;
            font-size: 13px;
            transition: background 0.1s ease;
        }

        .searchable-item:hover,
        .searchable-item.highlighted {
            background: rgba(59, 130, 246, 0.15);
        }

        html.theme-light .searchable-item:hover,
        html.theme-light .searchable-item.highlighted,
        html[data-theme='light'] .searchable-item:hover,
        html[data-theme='light'] .searchable-item.highlighted {
            background: rgba(59, 130, 246, 0.08);
        }

        .searchable-item.selected {
            background: rgba(16, 185, 129, 0.15);
            font-weight: 500;
        }

        html.theme-light .searchable-item.selected,
        html[data-theme='light'] .searchable-item.selected {
            background: rgba(16, 185, 129, 0.1);
        }

        .searchable-item.placeholder {
            opacity: 0.6;
            font-style: italic;
        }

        .searchable-item.no-results {
            opacity: 0.6;
            font-style: italic;
            cursor: default;
            text-align: center;
        }

        /* PM selector searchable input styling */
        .pm-selector .searchable-input {
            width: 100% !important;
            padding: 10px 12px !important;
            border-radius: 12px !important;
            border: 1px solid rgba(59, 130, 246, .35) !important;
            background: linear-gradient(155deg, rgba(59, 130, 246, .18), rgba(37, 99, 235, .12)) !important;
            color: inherit !important;
            font-size: 13px !important;
            font-family: inherit !important;
            box-sizing: border-box !important;
            font-weight: 600 !important;
            box-shadow: 0 2px 8px rgba(59, 130, 246, .15) !important;
            min-width: 600px !important;
        }

        .pm-selector .searchable-input:focus {
            outline: none !important;
            border-color: rgba(59, 130, 246, .6) !important;
            box-shadow: 0 0 0 3px rgba(59, 130, 246, .2), 0 2px 8px rgba(59, 130, 246, .25) !important;
        }

        html.theme-light .pm-selector .searchable-input,
        html[data-theme='light'] .pm-selector .searchable-input {
            background: linear-gradient(155deg, #dbeafe, #bfdbfe) !important;
            border: 1px solid rgba(59, 130, 246, .4) !important;
            color: #1d4ed8 !important;
            box-shadow: 0 2px 6px rgba(59, 130, 246, .2) !important;
        }

        html.theme-light .pm-selector .searchable-input:focus,
        html[data-theme='light'] .pm-selector .searchable-input:focus {
            border-color: rgba(37, 99, 235, .6) !important;
            box-shadow: 0 0 0 3px rgba(59, 130, 246, .15), 0 2px 8px rgba(59, 130, 246, .3) !important;
        }
    </style>

    <script type="text/javascript">
    function initSearchableDropdowns() {
        var dropdowns = document.querySelectorAll('.searchable-dropdown');
        
        dropdowns.forEach(function(wrapper) {
            var dropdown = wrapper.querySelector('select');
            if (!dropdown || dropdown.hasAttribute('data-searchable-initialized')) return;
            
            dropdown.setAttribute('data-searchable-initialized', 'true');
            
            // Create search input
            var searchInput = document.createElement('input');
            searchInput.type = 'text';
            searchInput.className = 'searchable-input';
            searchInput.placeholder = 'Select...';
            
            // Create dropdown list
            var dropList = document.createElement('div');
            dropList.className = 'searchable-list';
            
            // Hide original dropdown
            dropdown.style.display = 'none';
            
            // Insert elements
            wrapper.appendChild(searchInput);
            wrapper.appendChild(dropList);
            
            // Store options
            var allOptions = [];
            for (var i = 0; i < dropdown.options.length; i++) {
                var opt = dropdown.options[i];
                allOptions.push({
                    value: opt.value,
                    text: opt.text,
                    selected: opt.selected
                });
            }
            
            // Set initial value
            var selectedOpt = allOptions.find(function(opt) { return opt.selected || opt.value === dropdown.value; });
            if (selectedOpt) {
                searchInput.value = selectedOpt.value ? selectedOpt.text : '';
                searchInput.placeholder = selectedOpt.value ? selectedOpt.text : 'Select...';
            }
            
            function populateList(filter) {
                dropList.innerHTML = '';
                var hasResults = false;
                
                allOptions.forEach(function(opt) {
                    if (!filter || opt.text.toLowerCase().indexOf(filter.toLowerCase()) >= 0) {
                        var item = document.createElement('div');
                        item.className = 'searchable-item';
                        if (opt.value === dropdown.value) {
                            item.classList.add('selected');
                        }
                        if (!opt.value) {
                            item.classList.add('placeholder');
                        }
                        item.textContent = opt.text;
                        
                        item.addEventListener('click', function() {
                            selectOption(opt);
                            dropList.classList.remove('open');
                        });
                        
                        dropList.appendChild(item);
                        if (opt.value) hasResults = true;
                    }
                });

                if (!hasResults && filter) {
                    var noResults = document.createElement('div');
                    noResults.className = 'searchable-item no-results';
                    noResults.textContent = 'No results found';
                    dropList.appendChild(noResults);
                }
            }

            function selectOption(opt) {
                dropdown.value = opt.value;
                searchInput.value = opt.value ? opt.text : '';
                searchInput.placeholder = opt.value ? opt.text : 'Select...';
                
                // Trigger AutoPostBack manually since programmatic change event may not work
                if (typeof(__doPostBack) !== 'undefined' && dropdown.id) {
                    __doPostBack(dropdown.id, '');
                }
            }

            // Show/hide list
            searchInput.addEventListener('focus', function() {
                populateList('');
                dropList.classList.add('open');
            });

            searchInput.addEventListener('input', function() {
                populateList(this.value);
                if (!dropList.classList.contains('open')) {
                    dropList.classList.add('open');
                }
            });

            // Close on click outside
            document.addEventListener('click', function(e) {
                if (!wrapper.contains(e.target)) {
                    dropList.classList.remove('open');
                    // Restore value if user didn't select
                    var selectedOpt = allOptions.find(function(opt) { return opt.value === dropdown.value; });
                    if (selectedOpt) {
                        searchInput.value = selectedOpt.value ? selectedOpt.text : '';
                    }
                }
            });

            // Keyboard navigation
            var currentIndex = -1;
            searchInput.addEventListener('keydown', function(e) {
                var items = dropList.querySelectorAll('.searchable-item:not(.no-results)');
                
                if (e.key === 'ArrowDown') {
                    e.preventDefault();
                    currentIndex = Math.min(currentIndex + 1, items.length - 1);
                    highlightItem(items, currentIndex);
                } else if (e.key === 'ArrowUp') {
                    e.preventDefault();
                    currentIndex = Math.max(currentIndex - 1, 0);
                    highlightItem(items, currentIndex);
                } else if (e.key === 'Enter') {
                    e.preventDefault();
                    if (currentIndex >= 0 && items[currentIndex]) {
                        items[currentIndex].click();
                    }
                } else if (e.key === 'Escape') {
                    dropList.classList.remove('open');
                }
            });

            function highlightItem(items, index) {
                items.forEach(function(item, i) {
                    if (i === index) {
                        item.classList.add('highlighted');
                        item.scrollIntoView({ block: 'nearest' });
                    } else {
                        item.classList.remove('highlighted');
                    }
                });
            }
        });
    }

    // Initialize on page load
    document.addEventListener('DOMContentLoaded', function() {
        console.log('DOM loaded, initializing searchable dropdowns...');
        initSearchableDropdowns();
    });
    
    // Also try immediate execution if DOM is already loaded
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initSearchableDropdowns);
    } else {
        console.log('DOM already loaded, initializing immediately...');
        initSearchableDropdowns();
    }
    
    if (typeof(Sys) !== 'undefined') {
        Sys.WebForms.PageRequestManager.getInstance().add_endRequest(function() {
            console.log('AJAX postback completed, re-initializing searchable dropdowns...');
            initSearchableDropdowns();
        });
    }
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <script type="text/javascript">
        function handleDetailsClick() {
            var urlParams = new URLSearchParams(window.location.search);
            var mode = urlParams.get('mode');
            var currentId = urlParams.get('id');
            
            if (currentId) {
                return false;
            }
            
            window.location.href = 'PMDetails.aspx?action=viewFirst';
            return false;
        }
    </script>
    <div class="admin-grid">
        <!-- Sidebar -->
        <aside class="sidebar" role="navigation" aria-label="PM sidebar">
            <nav>
                <div class="sidebar-title">PM LOG</div>
                
                <div class="sidebar-header">Details</div>
                <ul class="sidebar-nav">
                    <li>
                        <%
                            string detailsHref = "PMDetails.aspx?action=viewFirst";
                            if (!string.IsNullOrEmpty(Request.QueryString["id"]))
                            {
                                detailsHref = "javascript:void(0);";
                            }
                        %>
                        <a href="<%= detailsHref %>" class="<%= Request.QueryString["mode"] != "new" && !string.IsNullOrEmpty(Request.QueryString["id"]) ? "active" : "" %>">
                            <svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
                            <span>PM Log Details</span>
                        </a>
                    </li>
                </ul>
                
                <div class="sidebar-header">New Item</div>
                <ul class="sidebar-nav">
                    <li>
                        <a href="PMDetails.aspx?mode=new" class="<%= Request.QueryString["mode"] == "new" ? "active" : "" %>">
                            <svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M12 5v14"/><path d="M5 12h14"/></svg>
                            <span>New PM Log</span>
                        </a>
                    </li>
                </ul>
                
                <div class="sidebar-header">Other</div>
                <ul class="sidebar-nav">
                    <li>
                        <a href="PMDashboard.aspx" class="danger">
                            <svg class="icon" viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M15 18l-6-6 6-6"/></svg>
                            <span>Back to PM Dashboard</span>
                        </a>
                    </li>
                </ul>
            </nav>
            <div class="sidebar-spacer"></div>
        </aside>
        
        <!-- Main Content -->
        <div class="admin-main">
            <div class="admin-form">
                <div class="page-header">
                    <div class="page-header-left">
                        <h1><asp:Literal ID="litPageTitle" runat="server" Text="PM Log Details" /></h1>
                        <div class="subtitle"><asp:Literal ID="litPageSubtitle" runat="server" Text="View and edit preventive maintenance log information" /></div>
                    </div>
                    <div class="pm-selector searchable-dropdown" runat="server" id="divPMSelector" visible="false">
                        <asp:DropDownList ID="ddlPMSelector" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlPMSelector_SelectedIndexChanged" />
                    </div>
                </div>
                
                <!-- Basic Information Section -->
                <div class="section-header">Basic Information</div>
                <div class="form-grid">
                    <div class="span-4">
                        <div class="form-group">
                            <label for="txtID">PM ID</label>
                            <asp:TextBox ID="txtID" runat="server" Enabled="false" />
                        </div>
                    </div>
                    <div class="span-8">
                        <div class="form-group">
                            <label for="ddlEquipmentID">Equipment / Asset <span style="color:#f87171;">*</span></label>
                            <asp:DropDownList ID="ddlEquipmentID" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlEquipmentID_SelectedIndexChanged">
                                <asp:ListItem Value="" Text=" " />
                            </asp:DropDownList>
                        </div>
                    </div>
                    <div class="span-4">
                        <div class="form-group">
                            <label for="txtEquipmentType">Equipment Type</label>
                            <asp:TextBox ID="txtEquipmentType" runat="server" Enabled="false" />
                        </div>
                    </div>
                    <div class="span-4">
                        <div class="form-group">
                            <label for="txtPMFrequency">PM Frequency</label>
                            <asp:TextBox ID="txtPMFrequency" runat="server" Enabled="false" />
                        </div>
                    </div>
                    <div class="span-4">
                        <div class="form-group">
                            <label for="txtPMResponsible">PM Responsible</label>
                            <asp:TextBox ID="txtPMResponsible" runat="server" Enabled="false" />
                        </div>
                    </div>
                    <div class="span-4">
                        <div class="form-group">
                            <label for="txtLastPMDate">Last PM Date</label>
                            <asp:TextBox ID="txtLastPMDate" runat="server" Enabled="false" />
                        </div>
                    </div>
                    <div class="span-4">
                        <div class="form-group">
                            <label for="txtLastPMBy">Last PM By</label>
                            <asp:TextBox ID="txtLastPMBy" runat="server" Enabled="false" />
                        </div>
                    </div>
                    <div class="span-4">
                        <div class="form-group">
                            <label for="txtNextPM">Next PM</label>
                            <asp:TextBox ID="txtNextPM" runat="server" Enabled="false" />
                        </div>
                    </div>
                    <div class="span-4">
                        <div class="form-group">
                            <label for="txtPMEstimatedTime">PM Estimated Time (hours)</label>
                            <asp:TextBox ID="txtPMEstimatedTime" runat="server" Enabled="false" />
                        </div>
                    </div>
                </div>
                
                <!-- Maintenance Details Section -->
                <div class="section-header">Maintenance Details</div>
                <div class="form-grid">
                    <div class="span-4">
                        <div class="form-group">
                            <label for="txtScheduledDate">Scheduled Date</label>
                            <asp:TextBox ID="txtScheduledDate" runat="server" TextMode="Date" Enabled="false" />
                            <small style="color:#94a3b8;">Auto-populated from equipment's Next PM</small>
                        </div>
                    </div>
                    <div class="span-4">
                        <div class="form-group">
                            <label for="txtActualStartTime">Actual Start Time <span style="color:#f87171;">*</span></label>
                            <asp:TextBox ID="txtActualStartTime" runat="server" TextMode="DateTimeLocal" />
                        </div>
                    </div>
                    <div class="span-4">
                        <div class="form-group">
                            <label for="txtActualEndTime">Actual End Time <span style="color:#f87171;">*</span></label>
                            <asp:TextBox ID="txtActualEndTime" runat="server" TextMode="DateTimeLocal" />
                        </div>
                    </div>
                    <div class="span-4">
                        <div class="form-group">
                            <label for="txtDowntime">Downtime (hours) <span style="color:#f87171;">*</span></label>
                            <asp:TextBox ID="txtDowntime" runat="server" TextMode="Number" step="0.01" placeholder="0.00" />
                        </div>
                    </div>
                    <div class="span-4">
                        <div class="form-group">
                            <label for="txtPMDate">PM Date <span style="color:#f87171;">*</span></label>
                            <asp:TextBox ID="txtPMDate" runat="server" TextMode="DateTimeLocal" />
                        </div>
                    </div>
                    <div class="span-4">
                        <div class="form-group">
                            <label for="txtNextPMDate">Next PM Date <span style="color:#f87171;">*</span></label>
                            <asp:TextBox ID="txtNextPMDate" runat="server" TextMode="DateTimeLocal" />
                        </div>
                    </div>
                    <div class="span-4">
                        <div class="form-group">
                            <label for="ddlPMType">PM Type <span style="color:#f87171;">*</span></label>
                            <asp:DropDownList ID="ddlPMType" runat="server">
                                <asp:ListItem Value="" Text=" " />
                                <asp:ListItem Value="Daily" Text="Daily" />
                                <asp:ListItem Value="Weekly" Text="Weekly" />
                                <asp:ListItem Value="Monthly" Text="Monthly" />
                                <asp:ListItem Value="Quarterly" Text="Quarterly" />
                                <asp:ListItem Value="Semi-Annual" Text="Semi-Annual" />
                                <asp:ListItem Value="Annual" Text="Annual" />
                            </asp:DropDownList>
                        </div>
                    </div>
                    <div class="span-12">
                        <div class="form-group">
                            <label for="txtMaintenancePerformed">Maintenance Performed <span style="color:#f87171;">*</span></label>
                            <asp:TextBox ID="txtMaintenancePerformed" runat="server" TextMode="MultiLine" placeholder="Describe the maintenance activities performed..." />
                        </div>
                    </div>
                </div>
                
                <!-- Technician & Status Section -->
                <div class="section-header">Technician & Status</div>
                <div class="form-grid">
                    <div class="span-4">
                        <div class="form-group">
                            <label for="ddlPerformedBy">Performed By <span style="color:#f87171;">*</span></label>
                            <asp:DropDownList ID="ddlPerformedBy" runat="server">
                                <asp:ListItem Value="" Text=" " />
                            </asp:DropDownList>
                        </div>
                    </div>
                    <div class="span-4">
                        <div class="form-group">
                            <label for="ddlStatus">Status <span style="color:#f87171;">*</span></label>
                            <asp:DropDownList ID="ddlStatus" runat="server">
                                <asp:ListItem Value="" Text=" " />
                                <asp:ListItem Value="Completed" Text="Completed" />
                                <asp:ListItem Value="Partial" Text="Partial" />
                                <asp:ListItem Value="Deferred" Text="Deferred" />
                            </asp:DropDownList>
                        </div>
                    </div>
                    <div class="span-4">
                        <div class="form-group">
                            <label for="txtCreatedDate">Created Date</label>
                            <asp:TextBox ID="txtCreatedDate" runat="server" Enabled="false" />
                        </div>
                    </div>
                </div>
                
                <!-- Parts & Cost Section -->
                <div class="section-header">Parts & Cost</div>
                <div class="form-grid">
                    <div class="span-8">
                        <div class="form-group">
                            <label for="txtPartsReplaced">Parts Replaced <span style="color:#f87171;">*</span></label>
                            <asp:TextBox ID="txtPartsReplaced" runat="server" TextMode="MultiLine" placeholder="List any parts replaced during maintenance..." />
                        </div>
                    </div>
                    <div class="span-4">
                        <div class="form-group">
                            <label for="txtCost">Cost ($) <span style="color:#f87171;">*</span></label>
                            <asp:TextBox ID="txtCost" runat="server" TextMode="Number" step="0.01" placeholder="0.00" />
                        </div>
                    </div>
                </div>
                
                <!-- Comments Section -->
                <div class="section-header">Additional Information</div>
                <div class="form-grid">
                    <div class="span-12">
                        <div class="form-group" data-optional="true">
                            <label for="txtComments">Comments</label>
                            <asp:TextBox ID="txtComments" runat="server" TextMode="MultiLine" placeholder="Any additional notes or observations..." />
                        </div>
                    </div>
                </div>
                
                <!-- Attachments Section -->
                <div class="section-header">Attachments (Pictures & Files)</div>
                <div class="form-grid">
                    <div class="span-12">
                        <div class="form-group" data-optional="true">
                            <label for="fileUpload">Upload Files/Pictures</label>
                            <asp:FileUpload ID="fileUpload" runat="server" AllowMultiple="true" CssClass="file-upload" />
                            <small style="display:block; margin-top:8px; opacity:0.7;">Supported formats: Images (jpg, png, gif), Documents (pdf, docx, xlsx), Archives (zip). Max 10MB per file.</small>
                        </div>
                    </div>
                    <div class="span-12">
                        <div class="form-group">
                            <label>Existing Attachments</label>
                            <asp:Literal ID="litAttachments" runat="server" />
                        </div>
                    </div>
                </div>
                
                <!-- Action Buttons -->
                <div class="actions">
                    <asp:LinkButton ID="btnSave" runat="server" CssClass="btn primary" OnClick="btnSave_Click">
                        <span aria-hidden="true" class="icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/><polyline points="17 21 17 13 7 13 7 21"/><polyline points="7 3 7 8 15 8"/></svg></span>
                        <span class="txt">Save Changes</span>
                    </asp:LinkButton>
                    <asp:LinkButton ID="btnDelete" runat="server" CssClass="btn danger" OnClick="btnDelete_Click" OnClientClick="return confirm('Are you sure you want to delete this PM log? This action cannot be undone.');" Visible="false">
                        <span aria-hidden="true" class="icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg></span>
                        <span class="txt">Delete Log</span>
                    </asp:LinkButton>
                </div>
            </div>
        </div>
    </div>
    
    <div id="topBannerMsg" class="top-banner-msg" style="display:none;"></div>
    <div id="toast" class="toast" role="status" aria-live="polite"></div>
    <script type="text/javascript">
        // Field Validation Glow
        function validateFields() {
            // Get all form-group elements
            var formGroups = document.querySelectorAll('.form-group');
            
            formGroups.forEach(function(formGroup) {
                // Find the input, select, or textarea within this form-group
                var input = formGroup.querySelector('input, select, textarea');
                if (!input) return;
                
                // Remove existing validation classes
                formGroup.classList.remove('field-filled', 'field-empty-required', 'field-empty-optional');
                
                // Skip disabled fields
                if (input.disabled || input.readOnly) {
                    return;
                }
                
                // Check if this field is optional
                var isOptional = formGroup.hasAttribute('data-optional');
                
                // Check if filled
                var isFilled = false;
                if (input.tagName === 'SELECT') {
                    isFilled = input.value && input.value.trim() !== '';
                } else {
                    isFilled = input.value && input.value.trim() !== '';
                }
                
                // Apply appropriate class
                if (isFilled) {
                    formGroup.classList.add('field-filled');
                } else if (isOptional) {
                    formGroup.classList.add('field-empty-optional');
                } else {
                    formGroup.classList.add('field-empty-required');
                }
            });
        }
        
        function initializePage() {
            validateFields();
            document.addEventListener('input', validateFields);
            document.addEventListener('change', validateFields);
            
            // Safely initialize AJAX event handlers
            if (typeof(Sys) !== 'undefined' && Sys.WebForms && Sys.WebForms.PageRequestManager) {
                try {
                    Sys.WebForms.PageRequestManager.getInstance().add_endRequest(function() {
                        validateFields();
                        document.removeEventListener('input', validateFields);
                        document.removeEventListener('change', validateFields);
                        document.addEventListener('input', validateFields);
                        document.addEventListener('change', validateFields);
                    });
                } catch(e) {
                    // Silently handle PageRequestManager errors
                    console.log('PageRequestManager not available:', e.message);
                }
            }
        }
        
        // Initialize when DOM is ready
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', initializePage);
        } else {
            initializePage();
        }
        
        // Also try to initialize when window loads (fallback for AJAX framework)
        window.addEventListener('load', function() {
            if (typeof(Sys) !== 'undefined' && Sys.WebForms && Sys.WebForms.PageRequestManager) {
                try {
                    Sys.WebForms.PageRequestManager.getInstance().add_endRequest(function() {
                        validateFields();
                        document.removeEventListener('input', validateFields);
                        document.removeEventListener('change', validateFields);
                        document.addEventListener('input', validateFields);
                        document.addEventListener('change', validateFields);
                    });
                } catch(e) {
                    // Silently handle PageRequestManager errors
                }
            }
        });
        
        window.showToast = function (msg, type) {
            try {
                var el = document.getElementById('toast');
                if (!el) return; 
                el.textContent = msg; 
                el.className = 'toast show' + (type ? ' toast-' + type : '');
                setTimeout(function(){ el.classList.remove('show'); }, 3000);
            } catch(e){}
        }

        // Modern top banner notification
        window.showBannerMsg = function (msg, type) {
            var el = document.getElementById('topBannerMsg');
            if (!el) return;
            el.innerHTML = msg;
            el.className = 'top-banner-msg ' + (type ? ' banner-' + type : '');
            el.style.display = 'block';
            setTimeout(function () { el.style.display = 'none'; }, 7000);
        }
    </script>
    <style>
        .top-banner-msg {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            z-index: 9999;
            padding: 16px 24px;
            font-size: 16px;
            font-weight: 400;
            text-align: center;
            border-radius: 0 0 12px 12px;
            box-shadow: 0 4px 16px rgba(0,0,0,.12);
            background: #1e293b;
            color: #fff;
            opacity: 0.98;
            display: none;
            transition: all .3s;
        }
        .top-banner-msg .banner-title {
            font-weight: 700;
            margin-right: 8px;
        }
        .top-banner-msg .banner-fields {
            font-weight: 400;
        }
        .top-banner-msg.banner-success { background: #059669; color: #fff; }
        .top-banner-msg.banner-error { background: #dc2626; color: #fff; }
        .top-banner-msg.banner-info { background: #2563eb; color: #fff; }
    </style>
</asp:Content>
