<%@ Page Title="Create New Item" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="CreateNewItem.aspx.cs" Inherits="CreateNewItem" %>
<%@ Register Src="~/Admin/Controls/AdminHeader.ascx" TagPrefix="uc1" TagName="AdminHeader" %>
<%@ Register Src="~/Controls/ItemSidebar.ascx" TagPrefix="uc2" TagName="ItemSidebar" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        /* Admin shell adopted from CreateUser.aspx */
        .admin-form { background:rgba(25,29,37,.52); border:1px solid rgba(255,255,255,.08); border-radius:14px; padding:16px; box-shadow:0 16px 34px -12px rgba(0,0,0,.6), 0 0 0 1px rgba(255,255,255,.05); flex:1; min-height:0; overflow:auto; }
        html.theme-light .admin-form, html[data-theme='light'] .admin-form { background:#ffffff; border:1px solid rgba(0,0,0,.08); box-shadow:0 16px 34px -12px rgba(0,0,0,.16), 0 0 0 1px rgba(0,0,0,.05); }
    .form-grid, .form-row, .form-row-4col { display:grid; grid-template-columns: repeat(12, 1fr); gap:12px; }
    .form-grid { margin-bottom:12px; }
        .span-1 { grid-column: span 1; }
        .span-2 { grid-column: span 2; }
        .span-3 { grid-column: span 3; }
        .span-4 { grid-column: span 4; }
        .span-5 { grid-column: span 5; }
        .span-6 { grid-column: span 6; }
    .span-8 { grid-column: span 8; }
        .span-12 { grid-column: 1 / -1; }
        @media (max-width: 980px){ .span-1, .span-2, .span-3, .span-4, .span-5, .span-6, .span-12 { grid-column: 1 / -1; } }

    .form-group { display:flex; flex-direction:column; }
    .form-group label { font-size:12px; opacity:.9; margin-bottom:6px; display:block; color:inherit; font-family:inherit; font-weight:normal; }
    .form-group .form-label { font-size:12px !important; opacity:.9; margin-bottom:6px; display:block; color:inherit; font-family:inherit; font-weight:normal; }
        
        /* Inputs and selects match Admin skin (dark/light) */
        .form-group input[type="text"],
        .form-group input[type="url"],
        .form-group input[type="email"],
        .form-group input[type="password"],
        .form-group input[type="number"],
        .form-group input[type="file"],
        .form-group textarea,
        .form-group select { width:100%; padding:10px 12px; border-radius:12px; border:1px solid rgba(255,255,255,.14); background:rgba(0,0,0,.15); color:inherit; font-size:13px; font-family:inherit; box-sizing:border-box; }
        .form-group input:focus,
        .form-group textarea:focus,
        .form-group select:focus { outline:none; border-color:rgba(77,141,255,.5); box-shadow:0 0 0 3px rgba(77,141,255,.15); }
        html.theme-light .form-group input,
        html.theme-light .form-group textarea,
        html.theme-light .form-group select,
        html[data-theme='light'] .form-group input,
        html[data-theme='light'] .form-group textarea,
        html[data-theme='light'] .form-group select { background:#fff; border:1px solid rgba(0,0,0,.14); color:#1f242b; }
    /* Single-line controls uniform height */
    .admin-form .form-group input[type="text"],
    .admin-form .form-group input[type="url"],
    .admin-form .form-group input[type="email"],
    .admin-form .form-group input[type="password"],
    .admin-form .form-group input[type="file"],
    .admin-form .form-group input[type="number"],
    .admin-form .form-group select { min-height:38px; }
        select option { background:#0f1b2e; color:#e9eef8; }
        select option:hover { background:#16223a; color:#ffffff; }
        select option:checked { background:#1e2b4a; color:#ffffff; }
        html.theme-light select option, html[data-theme='light'] select option { background:#ffffff; color:#1f2530; }
        html.theme-light select option:hover, html[data-theme='light'] select option:hover { background:#f3f7ff; color:#0b2960; }
        html.theme-light select option:checked, html[data-theme='light'] select option:checked { background:#e6f0ff; color:#0b2960; }

    /* Toggle Switch Styling - EXACT COPY from ItemDetails.aspx */
    .toggle-switch { appearance:none !important; -webkit-appearance:none !important; -moz-appearance:none !important; position:relative; width:42px; height:24px; border-radius:999px; background:rgba(255,255,255,.14); border:1px solid rgba(255,255,255,.22); outline:none; cursor:pointer; transition:all .18s ease; display:inline-block; }
    .toggle-switch::before { content:""; position:absolute; top:2px; left:2px; width:20px; height:20px; border-radius:50%; background:#d0d7e2; box-shadow:0 1px 2px rgba(0,0,0,.35); transition:all .18s ease; }
    .toggle-switch:checked { background:rgba(70,180,110,.45); border-color:rgba(70,180,110,.65); }
    .toggle-switch:checked::before { left:20px; background:#e9fff0; }
    html.theme-light .toggle-switch, html[data-theme='light'] .toggle-switch { background:#e6ebf3; border:1px solid rgba(0,0,0,.14); }
    html.theme-light .toggle-switch::before, html[data-theme='light'] .toggle-switch::before { background:#ffffff; }
    html.theme-light .toggle-switch:checked, html[data-theme='light'] .toggle-switch:checked { background:#b5e6c7; border-color:#6bc28d; }
    .form-group .toggle-switch { align-self:flex-start; }
    
    /* Additional specificity for dynamically generated controls */
    input[type="checkbox"].toggle-switch,
    span > input[type="checkbox"].toggle-switch,
    .form-group span > input[type="checkbox"].toggle-switch { appearance:none !important; -webkit-appearance:none !important; -moz-appearance:none !important; }
    
    /* Hide any auto-generated label text next to checkbox */
    span.toggle-switch > label,
    input.toggle-switch + label { display:none !important; }

    /* Disabled field styling */
    .form-group input:disabled,
    .form-group select:disabled,
    .form-group textarea:disabled { opacity:0.5; cursor:not-allowed; background:rgba(128,128,128,.1) !important; }
    html.theme-light .form-group input:disabled,
    html.theme-light .form-group select:disabled,
    html.theme-light .form-group textarea:disabled { background:#f5f5f5 !important; }
    
    /* Disabled multi-select button styling */
    .admin-form .multi-select-button[aria-disabled="true"] { 
        opacity:0.5 !important; 
        cursor:not-allowed !important; 
        background:rgba(128,128,128,.1) !important;
        pointer-events:none !important;
    }
    html.theme-light .admin-form .multi-select-button[aria-disabled="true"],
    html[data-theme='light'] .admin-form .multi-select-button[aria-disabled="true"] { 
        background:#f5f5f5 !important; 
    }

    /* Buttons (same as Admin CreateUser) */
    .actions { margin-top:16px; display:flex; gap:12px; align-items:center; justify-content:flex-start; }
    .btn { padding:8px 12px; border-radius:12px; border:1px solid rgba(255,255,255,.14); text-decoration:none; cursor:pointer; transition:background .25s ease, border-color .25s ease, transform .2s ease, box-shadow .25s ease, color .2s ease; font-size:13px; display:inline-flex; align-items:center; justify-content:center; width:auto !important; gap:8px; }
    .btn .icon { width:16px; height:16px; }
    .btn.primary { background:linear-gradient(155deg,#0b4a3d,#0a3a31); color:#e6fff7; }
    .btn.primary:hover { transform:translateY(-1px); box-shadow:0 10px 20px -10px rgba(0,0,0,.65), 0 0 0 1px rgba(64,180,120,.35); }
    .btn.clean { background:rgba(255,255,255,.08); color:#d6dde4; border-color:rgba(255,255,255,.18); }
    .btn.clean:hover { background:rgba(255,255,255,.16); color:#ffffff; border-color:rgba(255,255,255,.28); transform:translateY(-1px); box-shadow:0 6px 14px -6px rgba(0,0,0,.65); }
    html.theme-light .btn { border:1px solid rgba(0,0,0,.12); }
    html.theme-light .btn.primary, html[data-theme='light'] .btn.primary { background:#1fa37e; color:#ffffff; }
    html.theme-light .btn.clean, html[data-theme='light'] .btn.clean { background:rgba(0,0,0,.045); color:#2c333b; border-color:rgba(0,0,0,.16); }
    html.theme-light .btn.clean:hover, html[data-theme='light'] .btn.clean:hover { background:rgba(0,0,0,.09); box-shadow:0 10px 20px -10px rgba(0,0,0,.24); }
    
    /* Success button styling - matching ItemDetails Save Changes button */
    .btn.success { background:linear-gradient(155deg, rgba(46,125,50,0.9), rgba(27,94,32,0.85)); color:#e6fff7; border-color:rgba(76,175,80,0.3); padding:8px 14px; font-size:13px; }
    .btn.success:hover { transform:translateY(-1px); box-shadow:0 10px 20px -10px rgba(0,0,0,.65), 0 0 0 1px rgba(76,175,80,.4); background:linear-gradient(155deg, rgba(56,142,60,0.95), rgba(27,94,32,0.9)); }
    html.theme-light .btn.success, html[data-theme='light'] .btn.success { background:#2e7d32; color:#ffffff; border-color:rgba(46,125,50,0.5); }
    html.theme-light .btn.success:hover, html[data-theme='light'] .btn.success:hover { background:#388e3c; box-shadow:0 10px 20px -10px rgba(46,125,50,.35); }
    
    /* Make button icon smaller */
    .btn.success svg { width:14px; height:14px; }
    
    /* Confirmation Modal Styling */
    .confirmation-overlay {
        position: fixed;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: rgba(0, 0, 0, 0.7);
        backdrop-filter: blur(4px);
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 10000;
        animation: fadeIn 0.2s ease;
    }
    
    .confirmation-modal {
        background: rgba(25,29,37,0.98);
        border: 1px solid rgba(255,255,255,0.12);
        border-radius: 16px;
        padding: 28px;
        max-width: 500px;
        width: 90%;
        box-shadow: 0 20px 60px -12px rgba(0,0,0,0.8), 0 0 0 1px rgba(255,255,255,0.08);
        animation: slideUp 0.25s ease;
    }
    
    html.theme-light .confirmation-modal,
    html[data-theme='light'] .confirmation-modal {
        background: #ffffff;
        border: 1px solid rgba(0,0,0,0.12);
        box-shadow: 0 20px 60px -12px rgba(0,0,0,0.25), 0 0 0 1px rgba(0,0,0,0.05);
    }
    
    .confirmation-icon {
        font-size: 48px;
        text-align: center;
        margin-bottom: 16px;
    }
    
    .confirmation-modal h3 {
        margin: 0 0 16px 0;
        font-size: 20px;
        font-weight: 600;
        text-align: center;
        color: inherit;
    }
    
    .confirmation-modal p {
        margin: 0 0 20px 0;
        font-size: 14px;
        line-height: 1.6;
        text-align: center;
        opacity: 0.9;
    }
    
    .confirmation-warning {
        background: rgba(255, 152, 0, 0.1);
        border: 1px solid rgba(255, 152, 0, 0.3);
        border-radius: 12px;
        padding: 16px;
        margin-bottom: 24px;
        font-size: 13px;
        line-height: 1.6;
    }
    
    html.theme-light .confirmation-warning,
    html[data-theme='light'] .confirmation-warning {
        background: rgba(255, 152, 0, 0.08);
        border-color: rgba(255, 152, 0, 0.25);
    }
    
    .confirmation-warning strong {
        display: block;
        margin-bottom: 8px;
        font-size: 14px;
        color: #ff9800;
    }
    
    .confirmation-warning ul {
        margin: 12px 0 12px 24px;
        padding: 0;
    }
    
    .confirmation-warning li {
        margin-bottom: 6px;
    }
    
    .confirmation-warning p:last-child {
        margin: 8px 0 0 0;
        font-size: 12px;
        opacity: 0.85;
    }
    
    .confirmation-actions {
        display: flex;
        gap: 12px;
        justify-content: center;
    }
    
    .btn-confirm-cancel,
    .btn-confirm-proceed {
        padding: 10px 20px;
        border-radius: 12px;
        border: none;
        font-size: 13px;
        font-weight: 500;
        cursor: pointer;
        transition: all 0.2s ease;
        font-family: inherit;
    }
    
    .btn-confirm-cancel {
        background: rgba(255,255,255,0.08);
        color: #d6dde4;
        border: 1px solid rgba(255,255,255,0.18);
    }
    
    .btn-confirm-cancel:hover {
        background: rgba(255,255,255,0.16);
        color: #ffffff;
        transform: translateY(-1px);
        box-shadow: 0 6px 14px -6px rgba(0,0,0,0.5);
    }
    
    html.theme-light .btn-confirm-cancel,
    html[data-theme='light'] .btn-confirm-cancel {
        background: rgba(0,0,0,0.045);
        color: #2c333b;
        border: 1px solid rgba(0,0,0,0.16);
    }
    
    html.theme-light .btn-confirm-cancel:hover,
    html[data-theme='light'] .btn-confirm-cancel:hover {
        background: rgba(0,0,0,0.09);
        box-shadow: 0 6px 14px -6px rgba(0,0,0,0.2);
    }
    
    .btn-confirm-proceed {
        background: linear-gradient(155deg, rgba(46,125,50,0.9), rgba(27,94,32,0.85));
        color: #e6fff7;
        border: 1px solid rgba(76,175,80,0.3);
    }
    
    .btn-confirm-proceed:hover {
        background: linear-gradient(155deg, rgba(56,142,60,0.95), rgba(27,94,32,0.9));
        transform: translateY(-1px);
        box-shadow: 0 10px 20px -10px rgba(0,0,0,0.65), 0 0 0 1px rgba(76,175,80,0.4);
    }
    
    html.theme-light .btn-confirm-proceed,
    html[data-theme='light'] .btn-confirm-proceed {
        background: #2e7d32;
        color: #ffffff;
        border: 1px solid rgba(46,125,50,0.5);
    }
    
    html.theme-light .btn-confirm-proceed:hover,
    html[data-theme='light'] .btn-confirm-proceed:hover {
        background: #388e3c;
        box-shadow: 0 10px 20px -10px rgba(46,125,50,0.35);
    }
    
    @keyframes fadeIn {
        from { opacity: 0; }
        to { opacity: 1; }
    }
    
    @keyframes slideUp {
        from { transform: translateY(20px); opacity: 0; }
        to { transform: translateY(0); opacity: 1; }
    }
        
        .form-group textarea {
            resize: vertical;
            min-height: 80px;
        }
        
        .toggle-container {
            display: flex;
            align-items: center;
            gap: 8px;
            margin-top: 5px;
        }
        
        /* Use native checkbox styling for consistency with Admin */
        
    .toggle-label { font-size:13px; opacity:1; cursor:pointer; font-weight:600; font-family:inherit; color:inherit; }
        
        .file-upload-container {
            position: relative;
        }
        
    /* File input skinned to match inputs (visual wrapper + native input overlay) */
    .file-upload-container { position: relative; height:38px; }
    .file-upload-visual { position:absolute; inset:0; display:flex; align-items:center; gap:10px; padding:0 12px; border-radius:12px; background:rgba(0,0,0,.15); border:1px solid rgba(255,255,255,.14); font-size:13px; color:inherit; pointer-events:none; }
    .file-upload-visual .file-btn { display:inline-flex; align-items:center; justify-content:center; padding:6px 10px; border-radius:8px; background:rgba(255,255,255,.08); border:1px solid rgba(255,255,255,.16); font-size:12px; }
    .file-upload-visual .file-name { opacity:.9; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
    html.theme-light .file-upload-visual, html[data-theme='light'] .file-upload-visual { background:#fff; border:1px solid rgba(0,0,0,.14); }
    html.theme-light .file-upload-visual .file-btn, html[data-theme='light'] .file-upload-visual .file-btn { background:#eef2f7; border:1px solid rgba(0,0,0,.12); }
    .file-upload-input { position:absolute; inset:0; opacity:0; cursor:pointer; }

    /* Checkbox sizing and alignment - EXCLUDE toggle switches */
    .admin-form input[type="checkbox"]:not(.toggle-switch) { width:16px; height:16px; vertical-align:middle; }
    .admin-form .toggle-container { align-items:center; }
        
        .form-actions {
            margin-top: 30px;
            display: flex;
            gap: 15px;
        }
        
        .btn {
            padding: 12px 24px;
            border: none;
            border-radius: 6px;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.2s;
        }
        
        .btn-primary {
            background: #007bff;
            color: white;
        }
        
        .btn-primary:hover {
            background: #0056b3;
        }
        
        .btn-secondary {
            background: #28a745;
            color: white;
        }
        
        .btn-secondary:hover {
            background: #1e7e34;
        }
        
        .item-type-selector {
            margin-bottom: 25px;
            padding: 15px;
            background: #f8f9fa;
            border-radius: 6px;
            border: 1px solid #e9ecef;
        }
        
        .item-type-selector label {
            font-weight: 600;
            margin-bottom: 8px;
            display: block;
            color: #333;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
        }
        
        .multi-select-container {
            position: relative;
        }
        
        .multi-select-dropdown {
            position: relative;
            width: 100%;
        }
        
        .admin-form .multi-select-button {
            width: 100%;
            padding: 10px 12px !important;
            border: 1px solid rgba(255,255,255,.14);
            border-radius: 12px;
            background: rgba(0,0,0,.15);
            text-align: left;
            cursor: pointer;
            font-size: 13px !important;
            font-family: inherit !important;
            display: flex;
            justify-content: space-between;
            align-items: center;
            min-height: 38px;
            box-sizing: border-box;
            color: inherit !important;
            line-height: 1.5 !important;
        }
        /* Force smaller font on all children of the button */
        .admin-form .multi-select-button * {
            font-size: 13px !important;
            font-family: inherit !important;
            font-weight: normal !important;
        }
        
        .admin-form .multi-select-button:hover { border-color: rgba(77,141,255,.5); }

        .admin-form .multi-select-button:focus {
            outline: none;
            border-color: rgba(77,141,255,.5);
            box-shadow: 0 0 0 3px rgba(77,141,255,.15);
        }

    html.theme-light .admin-form .multi-select-button, html[data-theme='light'] .admin-form .multi-select-button { background:#fff; border:1px solid rgba(0,0,0,.14); color:#1f242b !important; }
    .admin-form .multi-select-button .multi-select-text { opacity:0.6 !important; line-height:1.5 !important; color:inherit !important; font-size:13px !important; font-family:inherit !important; font-weight:normal !important; }
        
        .admin-form .multi-select-text {
            flex: 1;
            overflow: hidden;
            white-space: nowrap;
            text-overflow: ellipsis;
            color: inherit !important;
            font-size: 13px !important;
            font-family: inherit !important;
            opacity: 0.6 !important;
            font-weight: normal !important;
            line-height: 1.5 !important;
        }
        
        .admin-form .multi-select-arrow {
            margin-left: 8px;
            width: 0;
            height: 0;
            border-left: 5px solid transparent;
            border-right: 5px solid transparent;
            border-top: 6px solid currentColor; /* caret follows text color */
            transform: rotate(0deg);
            transition: transform 0.2s ease;
            opacity: .7;
        }
        
        .multi-select-dropdown.open .multi-select-arrow {
            transform: rotate(180deg);
        }

        .multi-select-dropdown.open .multi-select-button {
            border-bottom-left-radius: 0;
            border-bottom-right-radius: 0;
            border-color: #007bff;
            box-shadow: 0 0 0 2px rgba(0,123,255,0.25);
        }
        
        .admin-form .multi-select-options {
            position: absolute;
            top: 100%;
            left: 0;
            right: 0;
            margin-top: -1px; /* seam with button border */
            max-height: 200px;
            overflow-y: auto;
            border: 1px solid rgba(255,255,255,.14);
            border-top: none;
            border-radius: 0 0 4px 4px;
            background: rgba(15,23,42,.98);
            z-index: 5000; /* float above other controls */
            display: none;
            box-shadow: 0 2px 8px rgba(0,0,0,0.15);
            color: inherit !important;
            font-size: 13px !important;
        }
        html.theme-light .admin-form .multi-select-options, html[data-theme='light'] .admin-form .multi-select-options { background:#fff; border:1px solid rgba(0,0,0,.14); color:#1f242b; }
        
        .multi-select-options.show {
            display: block;
        }
        
        .admin-form .multi-select-option {
            padding: 8px 12px;
            border-bottom: 1px solid #f0f0f0;
            cursor: pointer;
            font-size: 13px !important;
            font-family: inherit !important;
            display: flex;
            align-items: center;
        }
        .admin-form .multi-select-option:hover { background-color: rgba(255,255,255,.08); }
        html.theme-light .admin-form .multi-select-option:hover, html[data-theme='light'] .admin-form .multi-select-option:hover { background:#f6f8fb; }
        
        .multi-select-option input[type="checkbox"] {
            margin-right: 8px;
        }

        .admin-form .multi-select-option-label {
            display: inline-block;
            font-size: 13px !important;
            color: inherit !important;
        }
        
        .multi-select-selected-count {
            font-size: 12px;
            color: #666;
        }
        
        @media (max-width: 768px) { .admin-form { padding:14px; } }

        /* Improve cross-browser styling for file input */
        .admin-form input[type="file"] { font-size:13px; color:inherit; }
        .admin-form input[type="file"]::file-selector-button { 
            font-size:13px; 
            font-family:inherit; 
            color:inherit; 
            background:transparent; 
            border:none; 
            margin-right:8px; 
            padding:8px 10px; 
            border-radius:8px; 
        }
        /* WebKit fallback */
        .admin-form input[type="file"]::-webkit-file-upload-button { 
            font-size:13px; 
            font-family:inherit; 
            color:inherit; 
            background:transparent; 
            border:none; 
            margin-right:8px; 
            padding:8px 10px; 
            border-radius:8px; 
        }

        /* Global fixed Message banner */
        .msg-banner { 
            position: fixed; 
            top: 12px; 
            left: 50%; 
            transform: translateX(-50%);
            z-index: 9999;
            padding: 12px 16px; 
            border-radius: 12px; 
            border: 1px solid rgba(255,255,255,.12); 
            background: rgba(9, 86, 20, 0.9); 
            color: #e7ffe7; 
            display:flex; 
            align-items:center; 
            gap:12px;
            box-shadow: 0 12px 28px rgba(0,0,0,.35);
            min-width: 280px;
            max-width: 70vw;
        }
        .msg-banner.info { background: rgba(44, 87, 160, 0.22); color:#e9f2ff; }
        .msg-banner.error { background: rgba(148, 31, 31, 0.22); color:#ffe9e9; }
        .msg-banner .close { background:none; border:none; color:inherit; cursor:pointer; font-size:16px; opacity:.75; }
        html.theme-light .msg-banner, html[data-theme='light'] .msg-banner { border: 1px solid rgba(0,0,0,.12); }
    html.theme-light .msg-banner { background:#e9f9ef; color:#0f3b1d; }
    html.theme-light .msg-banner.info, html[data-theme='light'] .msg-banner.info { background:#e9f0ff; color:#0b2960; }
    html.theme-light .msg-banner.error, html[data-theme='light'] .msg-banner.error { background:#ffe9e9; color:#5d0b0b; }
    
    /* Force multi-select text size to match other form inputs */
    .admin-form .form-group .multi-select-dropdown .multi-select-button .multi-select-text,
    .admin-form .form-group .multi-select-dropdown .multi-select-button span {
        font-size: 13px !important;
        line-height: 1.5 !important;
    }

    /* Field Validation Glow Effects */
    .form-group.field-filled input,
    .form-group.field-filled select,
    .form-group.field-filled textarea,
    .form-group.field-filled .multi-select-button {
        border-color: rgba(16, 185, 129, 0.6) !important;
        box-shadow: 0 0 0 3px rgba(16, 185, 129, 0.15) !important;
    }

    .form-group.field-empty-required input,
    .form-group.field-empty-required select,
    .form-group.field-empty-required textarea,
    .form-group.field-empty-required .multi-select-button {
        border-color: rgba(239, 68, 68, 0.6) !important;
        box-shadow: 0 0 0 3px rgba(239, 68, 68, 0.15) !important;
    }

    .form-group.field-empty-optional input,
    .form-group.field-empty-optional select,
    .form-group.field-empty-optional textarea,
    .form-group.field-empty-optional .multi-select-button {
        border-color: rgba(245, 158, 11, 0.6) !important;
        box-shadow: 0 0 0 3px rgba(245, 158, 11, 0.15) !important;
    }

    /* Disabled fields stay gray (no glow) */
    .form-group input:disabled,
    .form-group select:disabled,
    .form-group textarea:disabled {
        border-color: rgba(255,255,255,.14) !important;
        box-shadow: none !important;
    }

    html.theme-light .form-group input:disabled,
    html.theme-light .form-group select:disabled,
    html.theme-light .form-group textarea:disabled {
        border-color: rgba(0,0,0,.14) !important;
    }

    /* Fixed banner notification at top of page */
    .msg-banner-notification {
        position: fixed;
        top: 20px;
        left: 50%;
        transform: translateX(-50%);
        z-index: 9999;
        padding: 14px 20px;
        border-radius: 14px;
        border: 1px solid rgba(255,255,255,.12);
        backdrop-filter: blur(10px);
        display: flex;
        align-items: center;
        gap: 12px;
        box-shadow: 0 12px 28px rgba(0,0,0,.35);
        min-width: 320px;
        max-width: 700px;
        animation: slideDown 0.3s ease-out;
        font-size: 14px;
        font-weight: 500;
    }

    .msg-banner-error {
        background: rgba(148, 31, 31, 0.95);
        color: #ffe9e9;
        border-color: rgba(255, 68, 68, 0.3);
    }

    .msg-banner-success {
        background: rgba(9, 86, 20, 0.95);
        color: #e7ffe7;
        border-color: rgba(16, 185, 129, 0.3);
    }

    .msg-banner-info {
        background: rgba(37, 99, 235, 0.95);
        color: #dbeafe;
        border-color: rgba(59, 130, 246, 0.3);
    }

    html.theme-light .msg-banner-success,
    html[data-theme='light'] .msg-banner-success {
        background: #e9f9ef;
        color: #0f3b1d;
        border-color: rgba(16, 185, 129, 0.4);
    }

    html.theme-light .msg-banner-error,
    html[data-theme='light'] .msg-banner-error {
        background: #ffe9e9;
        color: #5d0b0b;
        border-color: rgba(239, 68, 68, 0.4);
    }

    html.theme-light .msg-banner-info,
    html[data-theme='light'] .msg-banner-info {
        background: #dbeafe;
        color: #1e3a8a;
        border-color: rgba(59, 130, 246, 0.4);
    }

    @keyframes slideDown {
        from {
            opacity: 0;
            transform: translateX(-50%) translateY(-20px);
        }
        to {
            opacity: 1;
            transform: translateX(-50%) translateY(0);
        }
    }

    @keyframes slideUp {
        from {
            opacity: 1;
            transform: translateX(-50%) translateY(0);
        }
        to {
            opacity: 0;
            transform: translateX(-50%) translateY(-20px);
        }
    }
    </style>
    
    <script type="text/javascript">
        function updateMultiSelectButton(buttonId, optionsId) {
            var button = document.getElementById(buttonId);
            var options = document.getElementById(optionsId);
            if (!button || !options) return;

            var checkboxes = options.querySelectorAll('input[type="checkbox"]:checked');
            var buttonText = button.querySelector('.multi-select-text');
            if (!buttonText) return;

            if (checkboxes.length === 0) {
                buttonText.textContent = 'Select options...';
            } else if (checkboxes.length === 1) {
                var label = checkboxes[0].getAttribute('data-label') || checkboxes[0].getAttribute('aria-label') || checkboxes[0].parentNode.textContent.replace(/^\s+/, '').trim();
                buttonText.textContent = label;
            } else {
                buttonText.textContent = checkboxes.length + ' items selected';
            }
        }

        function initializeMultiSelect(buttonId, optionsId) {
            var button = document.getElementById(buttonId);
            var options = document.getElementById(optionsId);
            var dropdown = button ? button.closest('.multi-select-dropdown') : null;

            if (!button || !options || !dropdown) return;
            if (dropdown.getAttribute('data-ms-init') === '1') return; // prevent duplicate handlers
            dropdown.setAttribute('data-ms-init', '1');

            // Make the button focusable and accessible
            button.setAttribute('tabindex', '0');
            button.setAttribute('role', 'button');
            button.setAttribute('aria-haspopup', 'listbox');
            button.setAttribute('aria-expanded', 'false');

            function openClose(toggle) {
                if (toggle) {
                    options.classList.add('show');
                    dropdown.classList.add('open');
                    button.setAttribute('aria-expanded', 'true');
                } else {
                    options.classList.remove('show');
                    dropdown.classList.remove('open');
                    button.setAttribute('aria-expanded', 'false');
                }
            }

            button.addEventListener('click', function(e) {
                e.preventDefault();
                var isOpen = options.classList.contains('show');
                // close all others first
                closeAllMultiSelects();
                openClose(!isOpen);
            });

            button.addEventListener('keydown', function(e) {
                if (e.key === 'Enter' || e.key === ' ') {
                    e.preventDefault();
                    button.click();
                } else if (e.key === 'Escape') {
                    openClose(false);
                }
            });

            // Clicking option text toggles checkbox
            var optionRows = options.querySelectorAll('.multi-select-option');
            optionRows.forEach(function(row) {
                row.addEventListener('click', function(e) {
                    if (e.target && e.target.tagName && e.target.tagName.toLowerCase() === 'input') return;
                    var cb = row.querySelector('input[type="checkbox"]');
                    if (!cb) return;
                    cb.checked = !cb.checked;
                    cb.dispatchEvent(new Event('change', { bubbles: true }));
                });
            });

            // Update button text based on selections
            var checkboxes = options.querySelectorAll('input[type="checkbox"]');
            checkboxes.forEach(function(checkbox) {
                checkbox.addEventListener('change', function() {
                    updateMultiSelectButton(buttonId, optionsId);
                });
            });

            updateMultiSelectButton(buttonId, optionsId);
        }

        function initializeAllMultiSelects() {
            var multiSelects = document.querySelectorAll('.multi-select-dropdown');
            multiSelects.forEach(function(dropdown) {
                var buttonEl = dropdown.querySelector('.multi-select-button');
                var optionsEl = dropdown.querySelector('.multi-select-options');
                if (buttonEl && optionsEl) {
                    initializeMultiSelect(buttonEl.id, optionsEl.id);
                }
            });
        }

        function closeAllMultiSelects(except) {
            var openDropdowns = document.querySelectorAll('.multi-select-dropdown.open');
            openDropdowns.forEach(function(dd) {
                if (except && dd === except) return;
                dd.classList.remove('open');
                var opts = dd.querySelector('.multi-select-options');
                if (opts) opts.classList.remove('show');
                var btn = dd.querySelector('.multi-select-button');
                if (btn) btn.setAttribute('aria-expanded', 'false');
            });
        }

        // One-time global handlers
        document.addEventListener('click', function(e) {
            var openDds = document.querySelectorAll('.multi-select-dropdown.open');
            openDds.forEach(function(dd) {
                if (!dd.contains(e.target)) {
                    dd.classList.remove('open');
                    var opts = dd.querySelector('.multi-select-options');
                    if (opts) opts.classList.remove('show');
                    var btn = dd.querySelector('.multi-select-button');
                    if (btn) btn.setAttribute('aria-expanded', 'false');
                }
            });
        });

        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') closeAllMultiSelects();
        });

        // Initialize when page loads and after postbacks
        document.addEventListener('DOMContentLoaded', initializeAllMultiSelects);

        if (typeof(Sys) !== 'undefined') {
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(initializeAllMultiSelects);
        }

        // Toggle field enable/disable logic
        function setupToggleHandlers() {
            // Force-apply toggle-switch class to calibration and PM checkboxes
            var calToggle = document.querySelector('input[id$="chkRequiresCalibration"]');
            var pmToggle = document.querySelector('input[id$="chkRequiredPM"]');
            
            console.log('Cal Toggle:', calToggle);
            console.log('PM Toggle:', pmToggle);
            
            if (calToggle) {
                console.log('Cal Toggle classes before:', calToggle.className);
                if (!calToggle.classList.contains('toggle-switch')) {
                    calToggle.classList.add('toggle-switch');
                }
                console.log('Cal Toggle classes after:', calToggle.className);
                calToggle.setAttribute('type', 'checkbox');
            }
            if (pmToggle) {
                console.log('PM Toggle classes before:', pmToggle.className);
                if (!pmToggle.classList.contains('toggle-switch')) {
                    pmToggle.classList.add('toggle-switch');
                }
                console.log('PM Toggle classes after:', pmToggle.className);
                pmToggle.setAttribute('type', 'checkbox');
            }
            
            // Requires Calibration toggle
            if (calToggle) {
                function updateCalFields() {
                    var isChecked = calToggle.checked;
                    var calIdField = document.querySelector('input[id$="txtCalibrationID"]');
                    var calFreqField = document.querySelector('select[id$="ddlCalibrationFreq"]');
                    var calEstField = document.querySelector('input[id$="txtCalEstimatedTime"]');
                    
                    if (calIdField) calIdField.disabled = !isChecked;
                    if (calFreqField) calFreqField.disabled = !isChecked;
                    if (calEstField) calEstField.disabled = !isChecked;
                }
                calToggle.addEventListener('change', updateCalFields);
                updateCalFields(); // Initial state
            }

            // Required PM toggle
            if (pmToggle) {
                function updatePMFields() {
                    var isChecked = pmToggle.checked;
                    var pmFreqField = document.querySelector('select[id$="ddlPMFreq"]');
                    var pmEstField = document.querySelector('input[id$="txtPMEstimatedTime"]');
                    // PM Responsible is a Panel with ID ending in _button
                    var pmRespButton = document.querySelector('[id$="lstPMResponsible_button"]');
                    
                    if (pmFreqField) pmFreqField.disabled = !isChecked;
                    if (pmEstField) pmEstField.disabled = !isChecked;
                    if (pmRespButton) {
                        if (!isChecked) {
                            pmRespButton.style.opacity = '0.5';
                            pmRespButton.style.cursor = 'not-allowed';
                            pmRespButton.style.pointerEvents = 'none';
                            pmRespButton.style.background = 'rgba(128,128,128,.1)';
                            pmRespButton.setAttribute('aria-disabled', 'true');
                        } else {
                            pmRespButton.style.opacity = '';
                            pmRespButton.style.cursor = '';
                            pmRespButton.style.pointerEvents = '';
                            pmRespButton.style.background = '';
                            pmRespButton.removeAttribute('aria-disabled');
                        }
                    }
                }
                pmToggle.addEventListener('change', updatePMFields);
                updatePMFields(); // Initial state
            }
        }

        document.addEventListener('DOMContentLoaded', setupToggleHandlers);
        if (typeof(Sys) !== 'undefined') {
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(setupToggleHandlers);
        }

        // Field Validation Glow
        function validateFields() {
            var itemType = getCurrentItemType();
            var mandatoryFields = getMandatoryFields(itemType);
            var allFields = document.querySelectorAll('.form-group');

            allFields.forEach(function(formGroup) {
                var input = formGroup.querySelector('input:not([type="checkbox"]):not([type="file"]), select, textarea');
                var multiSelectBtn = formGroup.querySelector('.multi-select-button');
                var fieldId = '';

                // Get field ID
                if (input) {
                    fieldId = input.id;
                } else if (multiSelectBtn) {
                    fieldId = multiSelectBtn.id.replace('_button', '');
                }

                if (!fieldId) return;

                // Skip disabled fields
                if (input && input.disabled) {
                    formGroup.classList.remove('field-filled', 'field-empty-required', 'field-empty-optional');
                    return;
                }

                // Check if field is mandatory (match by suffix since ASP.NET adds prefixes)
                var isMandatory = false;
                for (var i = 0; i < mandatoryFields.length; i++) {
                    if (fieldId.indexOf(mandatoryFields[i]) > -1) {
                        isMandatory = true;
                        break;
                    }
                }

                var isFilled = false;

                // Check if field is filled
                if (input) {
                    if (input.tagName === 'SELECT') {
                        isFilled = input.value && input.value !== '';
                    } else {
                        isFilled = input.value.trim() !== '';
                    }
                } else if (multiSelectBtn) {
                    var optionsContainer = document.getElementById(fieldId + '_options');
                    if (optionsContainer) {
                        var checkedBoxes = optionsContainer.querySelectorAll('input[type="checkbox"]:checked');
                        isFilled = checkedBoxes.length > 0;
                    }
                }

                // Apply appropriate class
                formGroup.classList.remove('field-filled', 'field-empty-required', 'field-empty-optional');
                
                if (isFilled) {
                    formGroup.classList.add('field-filled');
                } else if (isMandatory) {
                    formGroup.classList.add('field-empty-required');
                } else {
                    formGroup.classList.add('field-empty-optional');
                }
            });
        }

        function getCurrentItemType() {
            var urlParams = new URLSearchParams(window.location.search);
            return (urlParams.get('type') || 'ATE').toUpperCase();
        }

        function getMandatoryFields(itemType) {
            var fields = {
                'ATE': ['txtATEName', 'txtATEDescription', 'ddlIntendedLine', 'ddlATEStatus', 'ddlLocation'],
                'ASSET': ['txtModelNo', 'txtDeviceName', 'txtDeviceDescription', 'ddlLocation', 'ddlDeviceType', 'ddlManufacturer', 'txtManufacturerSite', 'ddlCurrentStatus'],
                'FIXTURE': ['txtFixtureModelNo', 'txtFixtureDescription', 'ddlIntendedLine', 'ddlCurrentStatus', 'ddlLocation'],
                'HARNESS': ['txtHarnessModelNo', 'txtHarnessDescription', 'ddlLocation', 'ddlCurrentStatus']
            };

            var baseFields = fields[itemType] || [];

            // Add conditional fields based on toggles
            var calToggle = document.querySelector('input[id$="chkRequiresCalibration"]');
            var pmToggle = document.querySelector('input[id$="chkRequiredPM"]');

            if (calToggle && calToggle.checked) {
                baseFields.push('txtCalEstimatedTime', 'txtCalibrationID', 'ddlCalibrationFreq');
            }

            if (pmToggle && pmToggle.checked) {
                baseFields.push('txtPMEstimatedTime', 'ddlPMFreq', 'lstPMResponsible');
            }

            return baseFields;
        }

        // Run validation on input/change
        document.addEventListener('DOMContentLoaded', function() {
            validateFields();

            // Listen to all form inputs
            document.addEventListener('input', validateFields);
            document.addEventListener('change', validateFields);
        });

        if (typeof(Sys) !== 'undefined') {
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(function() {
                validateFields();
                document.removeEventListener('input', validateFields);
                document.removeEventListener('change', validateFields);
                document.addEventListener('input', validateFields);
                document.addEventListener('change', validateFields);
            });
        }

        // Form submission validation
        function validateFormBeforeSubmit() {
            var itemType = getCurrentItemType();
            var mandatoryFields = getMandatoryFields(itemType);
            var emptyMandatoryFields = [];

            mandatoryFields.forEach(function(fieldName) {
                var input = document.querySelector('input[id*="' + fieldName + '"], select[id*="' + fieldName + '"], textarea[id*="' + fieldName + '"]');
                var multiSelectBtn = document.querySelector('[id*="' + fieldName + '_button"]');

                var isEmpty = false;

                if (input && !input.disabled) {
                    if (input.tagName === 'SELECT') {
                        isEmpty = !input.value || input.value === '';
                    } else {
                        isEmpty = !input.value || input.value.trim() === '';
                    }
                } else if (multiSelectBtn && multiSelectBtn.getAttribute('aria-disabled') !== 'true') {
                    var optionsContainer = document.querySelector('[id*="' + fieldName + '_options"]');
                    if (optionsContainer) {
                        var checkedBoxes = optionsContainer.querySelectorAll('input[type="checkbox"]:checked');
                        isEmpty = checkedBoxes.length === 0;
                    }
                }

                if (isEmpty) {
                    var label = fieldName.replace(/^txt|^ddl|^ms|^lst/, '').replace(/([A-Z])/g, ' $1').trim();
                    emptyMandatoryFields.push(label);
                }
            });

            if (emptyMandatoryFields.length > 0) {
                alert('Please fill in all mandatory fields:\n\n' + emptyMandatoryFields.join('\n'));
                return false;
            }

            return true;
        }

        // Show confirmation modal before creating item
        var confirmationPending = false;
        var storedButton = null;
        
        function showConfirmationModal(button) {
            storedButton = button;
            // Create modal overlay
            var overlay = document.createElement('div');
            overlay.className = 'confirmation-overlay';
            overlay.innerHTML = `
                <div class="confirmation-modal">
                    <div class="confirmation-icon">&#9888;&#65039;</div>
                    <h3>Confirm Item Creation</h3>
                    <p>Please verify that all information is correct before proceeding.</p>
                    <div class="confirmation-warning">
                        <strong>Important:</strong> Once created, the following cannot be changed:
                        <ul>
                            <li>Eaton ID</li>
                            <li>Device Type (for Assets)</li>
                            <li>Folder paths</li>
                        </ul>
                        <p>Items cannot be deleted, only edited or deactivated.</p>
                    </div>
                    <div class="confirmation-actions">
                        <button class="btn-confirm-cancel">Review Fields</button>
                        <button class="btn-confirm-proceed">Create Item</button>
                    </div>
                </div>
            `;
            
            document.body.appendChild(overlay);
            
            // Add event listeners
            overlay.querySelector('.btn-confirm-cancel').addEventListener('click', function() {
                document.body.removeChild(overlay);
                confirmationPending = false;
                storedButton = null;
            });
            
            overlay.querySelector('.btn-confirm-proceed').addEventListener('click', function() {
                document.body.removeChild(overlay);
                confirmationPending = true;
                // Trigger the actual button click to proceed with form submission
                if (storedButton) {
                    storedButton.click();
                }
            });
            
            // Close on overlay click
            overlay.addEventListener('click', function(e) {
                if (e.target === overlay) {
                    document.body.removeChild(overlay);
                    confirmationPending = false;
                    storedButton = null;
                }
            });
        }

        // Attach validation to Create button - aggressive approach
        function attachValidation() {
            var btnCreate = document.querySelector('[id$="btnCreate"]');
            if (btnCreate) {
                // Store original onclick
                var originalOnClick = btnCreate.onclick;
                
                // Override the onclick
                btnCreate.onclick = function(e) {
                    // If confirmation is pending, allow the postback
                    if (confirmationPending) {
                        confirmationPending = false;
                        if (originalOnClick) {
                            return originalOnClick.call(this, e);
                        }
                        return true;
                    }
                    
                    // First validate mandatory fields
                    if (!validateFormBeforeSubmit()) {
                        if (e) {
                            e.preventDefault();
                            e.stopPropagation();
                            e.stopImmediatePropagation();
                        }
                        return false;
                    }
                    
                    // If validation passes, show confirmation modal
                    if (e) {
                        e.preventDefault();
                        e.stopPropagation();
                        e.stopImmediatePropagation();
                    }
                    
                    showConfirmationModal(btnCreate);
                    
                    return false;
                };
                
                // Also add event listener as backup
                btnCreate.addEventListener('click', function(e) {
                    // Allow through if confirmation is pending
                    if (confirmationPending) {
                        return true;
                    }
                    
                    if (!validateFormBeforeSubmit()) {
                        e.preventDefault();
                        e.stopPropagation();
                        e.stopImmediatePropagation();
                        return false;
                    }
                    
                    // Stop and show confirmation modal
                    e.preventDefault();
                    e.stopPropagation();
                    e.stopImmediatePropagation();
                    
                    showConfirmationModal(btnCreate);
                    
                    return false;
                }, true);
            }
        }

        document.addEventListener('DOMContentLoaded', function() {
            attachValidation();
        });

        if (typeof(Sys) !== 'undefined') {
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(function() {
                attachValidation();
            });
        }
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
            <div class="admin-grid">
            <uc2:ItemSidebar ID="ItemSidebar1" runat="server" />
        <div>
            <uc1:AdminHeader ID="AdminHeader1" runat="server" Title="Create New Item" />
            <div class="admin-form">
                <asp:PlaceHolder ID="phMessage" runat="server" />
                <div class="form-grid">
                    <div class="span-12">
                        <asp:Panel ID="pnlForm" runat="server" Visible="false">
                            <asp:PlaceHolder ID="phFormFields" runat="server" />
                                                        <div class="actions">
                                                                <asp:LinkButton ID="btnCreate" runat="server" CssClass="btn success" OnClick="btnCreate_Click">
                                                                    <span aria-hidden="true"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" width="16" height="16"><path d="M12 5v14"/><path d="M5 12h14"/></svg></span>
                                                                    <span>Create Item</span>
                                                                </asp:LinkButton>
                                                        </div>
                        </asp:Panel>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>