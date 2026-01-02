<%@ Page Title="Item Details" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="ItemDetails.aspx.cs" Inherits="ItemDetails" %>
<%@ Register Src="~/Admin/Controls/AdminHeader.ascx" TagPrefix="uc1" TagName="AdminHeader" %>
<%@ Register Src="~/Controls/ItemSidebar.ascx" TagPrefix="uc2" TagName="ItemSidebar" %>

<asp:Content ID="Head" ContentPlaceHolderID="HeadContent" runat="server">
  <style>
    .header-row { display:flex; align-items:center; justify-content:space-between; gap:12px; margin-bottom:8px; }
  .header-actions { display:flex; gap:10px; align-items:center; }
  .header-actions select { font-family: inherit; font-size: 13px; padding: 9px 12px; height: 38px; border-radius: 12px; border:1px solid rgba(255,255,255,.14); background: rgba(0,0,0,.15); color: inherit; min-width: 280px; }
  html.theme-light .header-actions select { background:#fff; border:1px solid rgba(0,0,0,.14); color:#1f242b; }
  /* Eaton ID dropdown highlight - modern blue/teal accent */
  .header-actions select.ddl-eatonid { 
    background: linear-gradient(135deg, rgba(59, 130, 246, 0.15), rgba(16, 185, 129, 0.12)); 
    color: inherit; 
    border-color: rgba(59, 130, 246, 0.35); 
    box-shadow: 0 0 0 1px rgba(59, 130, 246, 0.1) inset, 0 2px 8px rgba(59, 130, 246, 0.2); 
    font-weight: 500; 
    font-size: 13px;
  }
  .header-actions select.ddl-eatonid:focus { 
    outline: none; 
    border-color: rgba(59, 130, 246, 0.5); 
    box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.2); 
  }
  html.theme-light .header-actions select.ddl-eatonid, 
  html[data-theme='light'] .header-actions select.ddl-eatonid { 
    background: linear-gradient(135deg, rgba(59, 130, 246, 0.08), rgba(16, 185, 129, 0.06)); 
    color: #1f242b; 
    border-color: rgba(59, 130, 246, 0.3); 
    box-shadow: 0 0 0 1px rgba(59, 130, 246, 0.08) inset, 0 2px 6px rgba(59, 130, 246, 0.15);
  }
  html.theme-light .header-actions select.ddl-eatonid:focus { 
    border-color: rgba(59, 130, 246, 0.5); 
    box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.15); 
  }

  /* Searchable Dropdown / Combobox Styles */
  .searchable-dropdown {
    position: relative;
    display: inline-block;
    min-width: 450px;
  }

  .searchable-input {
    width: 100%;
    padding: 9px 12px;
    height: 38px;
    border-radius: 12px;
    border: 1px solid rgba(255,255,255,.14);
    background: rgba(0,0,0,.15);
    color: inherit;
    font-size: 13px;
    font-family: inherit;
    box-sizing: border-box;
    cursor: pointer;
  }

  .searchable-input.ddl-eatonid {
    background: linear-gradient(135deg, rgba(59, 130, 246, 0.15), rgba(16, 185, 129, 0.12));
    border-color: rgba(59, 130, 246, 0.35);
    box-shadow: 0 0 0 1px rgba(59, 130, 246, 0.1) inset, 0 2px 8px rgba(59, 130, 246, 0.2);
    font-weight: 500;
  }

  .searchable-input:focus {
    outline: none;
    border-color: rgba(59, 130, 246, 0.5);
    box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.2);
  }

  html.theme-light .searchable-input,
  html[data-theme='light'] .searchable-input {
    background: #fff;
    border: 1px solid rgba(0,0,0,.14);
    color: #1f242b;
  }

  html.theme-light .searchable-input.ddl-eatonid,
  html[data-theme='light'] .searchable-input.ddl-eatonid {
    background: linear-gradient(135deg, rgba(59, 130, 246, 0.08), rgba(16, 185, 129, 0.06));
    border-color: rgba(59, 130, 246, 0.3);
    box-shadow: 0 0 0 1px rgba(59, 130, 246, 0.08) inset, 0 2px 6px rgba(59, 130, 246, 0.15);
  }

  .searchable-list {
    position: absolute;
    top: 100%;
    left: 0;
    right: 0;
    margin-top: 4px;
    max-height: 400px;
    overflow-y: auto;
    background: rgba(15, 23, 42, 0.98);
    border: 1px solid rgba(255, 255, 255, 0.14);
    border-radius: 12px;
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.4), 0 0 0 1px rgba(255, 255, 255, 0.05);
    z-index: 10000;
    display: none;
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
    padding: 16px 12px;
  }

  /* Scrollbar styling for dropdown list */
  .searchable-list::-webkit-scrollbar {
    width: 8px;
  }

  .searchable-list::-webkit-scrollbar-track {
    background: rgba(0, 0, 0, 0.1);
    border-radius: 0 12px 12px 0;
  }

  .searchable-list::-webkit-scrollbar-thumb {
    background: rgba(255, 255, 255, 0.2);
    border-radius: 4px;
  }

  .searchable-list::-webkit-scrollbar-thumb:hover {
    background: rgba(255, 255, 255, 0.3);
  }

  html.theme-light .searchable-list::-webkit-scrollbar-track,
  html[data-theme='light'] .searchable-list::-webkit-scrollbar-track {
    background: rgba(0, 0, 0, 0.05);
  }

  html.theme-light .searchable-list::-webkit-scrollbar-thumb,
  html[data-theme='light'] .searchable-list::-webkit-scrollbar-thumb {
    background: rgba(0, 0, 0, 0.2);
  }

  html.theme-light .searchable-list::-webkit-scrollbar-thumb:hover,
  html[data-theme='light'] .searchable-list::-webkit-scrollbar-thumb:hover {
    background: rgba(0, 0, 0, 0.3);
  }
  .btn { padding:8px 12px; border-radius:12px; border:1px solid rgba(255,255,255,.14); cursor:pointer; text-decoration:none; display:inline-flex; align-items:center; gap:8px; font-size:13px; }
    .btn.success { background:linear-gradient(155deg,#0b4a3d,#0a3a31); color:#e6fff7; }
    .btn.success:hover { transform:translateY(-1px); box-shadow:0 10px 20px -10px rgba(0,0,0,.65), 0 0 0 1px rgba(64,180,120,.35); }
    .btn.danger { background:rgba(255,86,86,.18); color:#ffbdbd; border-color:rgba(255,86,86,.35); }
    .btn.danger:hover { transform:translateY(-1px); box-shadow:0 10px 20px -10px rgba(0,0,0,.65), 0 0 0 1px rgba(255,86,86,.35); }
    html.theme-light .btn { border:1px solid rgba(0,0,0,.12); }
    html.theme-light .btn.danger { background:#ffe9e9; color:#9b1c1c; }
    html.theme-light .btn.success { background:#1fa37e; color:#ffffff; }
    /* Disabled state for buttons */
    .btn[aria-disabled="true"], .btn.disabled { background:#8a96a8 !important; color:#e6ebf2 !important; border-color:rgba(0,0,0,.18) !important; cursor:not-allowed !important; pointer-events:none !important; box-shadow:none !important; transform:none !important; opacity:.75; }
    html.theme-light .btn[aria-disabled="true"], html.theme-light .btn.disabled, html[data-theme='light'] .btn[aria-disabled="true"], html[data-theme='light'] .btn.disabled { background:#e2e7ef !important; color:#96a0ae !important; border-color:rgba(0,0,0,.14) !important; }

    .admin-form { background:rgba(25,29,37,.52); border:1px solid rgba(255,255,255,.08); border-radius:14px; padding:16px; box-shadow:0 16px 34px -12px rgba(0,0,0,.6), 0 0 0 1px rgba(255,255,255,.05); flex:1; min-height:0; overflow:auto; }
    html.theme-light .admin-form, html[data-theme='light'] .admin-form { background:#ffffff; border:1px solid rgba(0,0,0,.08); box-shadow:0 16px 34px -12px rgba(0,0,0,.16), 0 0 0 1px rgba(0,0,0,.05); }
    .form-grid { display:grid; grid-template-columns: repeat(12, 1fr); gap:12px; }
    .span-2 { grid-column: span 2; }
    .span-4 { grid-column: span 4; }
    .span-6 { grid-column: span 6; }
    .span-8 { grid-column: span 8; }
    .span-12 { grid-column: 1 / -1; }
    @media (max-width: 980px){ .span-2, .span-4, .span-6, .span-12 { grid-column: 1 / -1; } }

    .form-group { display:flex; flex-direction:column; }
    .form-group label { font-size:12px; opacity:.9; margin-bottom:6px; display:block; }
  .form-actions { margin-top:16px; display:flex; gap:12px; }

    /* Inputs/selects styling to match Admin skin */
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
  .admin-form .form-group input[type="text"],
    .admin-form .form-group input[type="url"],
    .admin-form .form-group input[type="email"],
    .admin-form .form-group input[type="password"],
    .admin-form .form-group input[type="number"],
    .admin-form .form-group input[type="file"],
    .admin-form .form-group select { min-height:38px; }
  /* Disabled field visual differentiation */
  .admin-form input[disabled], .admin-form textarea[disabled], .admin-form select[disabled], .admin-form .readonly input, .admin-form .readonly textarea, .admin-form .readonly select { background:rgba(255,255,255,.06)!important; color:rgba(255,255,255,.7)!important; border-color:rgba(255,255,255,.12)!important; cursor:not-allowed; }
  html.theme-light .admin-form input[disabled], html.theme-light .admin-form textarea[disabled], html.theme-light .admin-form select[disabled], html[data-theme='light'] .admin-form input[disabled], html[data-theme='light'] .admin-form textarea[disabled], html[data-theme='light'] .admin-form select[disabled] { background:#f4f6f9!important; color:#7a8593!important; border-color:rgba(0,0,0,.1)!important; }

  /* Improve option contrast in dark mode select dropdowns */
  select option { background:#0f1b2e; color:#e9eef8; }
  select option:hover { background:#16223a; color:#ffffff; }
  select option:checked { background:#1e2b4a; color:#ffffff; }
  html.theme-light select option, html[data-theme='light'] select option { background:#ffffff; color:#1f2530; }
  html.theme-light select option:hover, html[data-theme='light'] select option:hover { background:#f3f7ff; color:#0b2960; }
  html.theme-light select option:checked, html[data-theme='light'] select option:checked { background:#e6f0ff; color:#0b2960; }

    /* File input skin */
    .file-upload-container { position: relative; height:38px; }
    .file-upload-visual { position:absolute; inset:0; display:flex; align-items:center; gap:10px; padding:0 12px; border-radius:12px; background:rgba(0,0,0,.15); border:1px solid rgba(255,255,255,.14); font-size:13px; color:inherit; pointer-events:none; }
    .file-upload-visual .file-btn { display:inline-flex; align-items:center; justify-content:center; padding:6px 10px; border-radius:8px; background:rgba(255,255,255,.08); border:1px solid rgba(255,255,255,.16); font-size:12px; }
    .file-upload-visual .file-name { opacity:.9; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
    html.theme-light .file-upload-visual, html[data-theme='light'] .file-upload-visual { background:#fff; border:1px solid rgba(0,0,0,.14); }
    html.theme-light .file-upload-visual .file-btn, html[data-theme='light'] .file-upload-visual .file-btn { background:#eef2f7; border:1px solid rgba(0,0,0,.12); }
    .file-upload-input { position:absolute; inset:0; opacity:0; cursor:pointer; }

  /* Image preview styles for file pickers */
  .img-picker { display:flex; flex-direction:column; gap:8px; position:relative; }
  .image-preview { display:none; width:100%; max-height:180px; object-fit:contain; border-radius:10px; border:1px solid rgba(255,255,255,.14); background:rgba(0,0,0,.15); box-shadow:inset 0 1px 2px rgba(0,0,0,.25); }
  html.theme-light .image-preview, html[data-theme='light'] .image-preview { background:#f7f9fc; border:1px solid rgba(0,0,0,.12); }
  .image-delete-btn { position:absolute; top:36px; right:12px; display:none; align-items:center; justify-content:center; width:28px; height:28px; border-radius:999px; background:rgba(0,0,0,.5); color:#fff; border:1px solid rgba(255,255,255,.35); cursor:pointer; text-decoration:none; line-height:0; font-size:0; z-index:10; transition:transform .12s ease, background .12s ease; }
  .image-delete-btn:hover { transform:scale(1.06); background:rgba(0,0,0,.65); }
  .image-delete-btn svg{ width:14px; height:14px; display:block; }
  .img-picker.has-image .image-delete-btn { display:flex; }
  html.theme-light .image-delete-btn, html[data-theme='light'] .image-delete-btn { background:#ffffff; color:#9b1c1c; border-color:rgba(0,0,0,.2); }
  html.theme-light .image-delete-btn:hover, html[data-theme='light'] .image-delete-btn:hover { background:#ffe9e9; }

    /* Multi-select dropdown styles */
    .multi-select-dropdown { position: relative; width: 100%; }
    .multi-select-button { width: 100%; padding: 8px 12px; border: 1px solid rgba(255,255,255,.14); border-radius: 12px; background: rgba(0,0,0,.15); text-align: left; cursor: pointer; font-size: 13px; display:flex; justify-content:space-between; align-items:center; min-height:38px; box-sizing:border-box; color:inherit; }
    html.theme-light .multi-select-button { background:#fff; border:1px solid rgba(0,0,0,.14); color:#1f242b; }
    .multi-select-button .multi-select-text { flex:1; overflow:hidden; white-space:nowrap; text-overflow:ellipsis; }
    .multi-select-arrow { margin-left: 8px; width: 0; height: 0; border-left: 5px solid transparent; border-right: 5px solid transparent; border-top: 6px solid currentColor; transform: rotate(0deg); transition: transform 0.2s ease; opacity: .7; }
    .multi-select-dropdown.open .multi-select-arrow { transform: rotate(180deg); }
    .multi-select-options { position:absolute; top:100%; left:0; right:0; margin-top:-1px; max-height:200px; overflow-y:auto; border:1px solid rgba(255,255,255,.14); border-top:none; border-radius:0 0 4px 4px; background: rgba(15,23,42,.98); z-index:5000; display:none; box-shadow:0 2px 8px rgba(0,0,0,0.15); color:inherit; font-size:13px; }
    html.theme-light .multi-select-options { background:#fff; border:1px solid rgba(0,0,0,.14); color:#1f242b; }
    .multi-select-options.show { display:block; }
    .multi-select-option { padding:8px 12px; cursor:pointer; display:flex; align-items:center; }
    .multi-select-option input[type="checkbox"] { margin-right:8px; }

  /* Toggle switch styling to match Equipment Inventory */
  .toggle-switch { appearance:none; -webkit-appearance:none; position:relative; width:42px; height:24px; border-radius:999px; background:rgba(255,255,255,.14); border:1px solid rgba(255,255,255,.22); outline:none; cursor:pointer; transition:all .18s ease; display:inline-block; }
  .toggle-switch::before { content:""; position:absolute; top:2px; left:2px; width:20px; height:20px; border-radius:50%; background:#d0d7e2; box-shadow:0 1px 2px rgba(0,0,0,.35); transition:all .18s ease; }
  .toggle-switch:checked { background:rgba(70,180,110,.45); border-color:rgba(70,180,110,.65); }
  .toggle-switch:checked::before { left:20px; background:#e9fff0; }
  html.theme-light .toggle-switch, html[data-theme='light'] .toggle-switch { background:#e6ebf3; border:1px solid rgba(0,0,0,.14); }
  html.theme-light .toggle-switch::before, html[data-theme='light'] .toggle-switch::before { background:#ffffff; }
  html.theme-light .toggle-switch:checked, html[data-theme='light'] .toggle-switch:checked { background:#b5e6c7; border-color:#6bc28d; }
  /* Align toggles to the left within form groups */
  .form-group .toggle-switch { align-self:flex-start; }
  /* Align action buttons to right under the form */
  .form-actions { justify-content:flex-end; }

    /* Message banner reused */
    .msg-banner{ position:fixed; top:12px; left:50%; transform:translateX(-50%); z-index:9999; padding:12px 16px; border-radius:12px; border:1px solid rgba(255,255,255,.12); background:rgba(9,86,20,.9); color:#e7ffe7; display:flex; align-items:center; gap:12px; box-shadow:0 12px 28px rgba(0,0,0,.35); min-width:280px; max-width:70vw; }
    .msg-banner.info{ background: rgba(44,87,160,.22); color:#e9f2ff; }
    .msg-banner.error{ background: rgba(148,31,31,.22); color:#ffe9e9; }
    html.theme-light .msg-banner, html[data-theme='light'] .msg-banner { border: 1px solid rgba(0,0,0,.12); }
    html.theme-light .msg-banner { background:#e9f9ef; color:#0f3b1d; }
    html.theme-light .msg-banner.info, html[data-theme='light'] .msg-banner.info { background:#e9f0ff; color:#0b2960; }
    html.theme-light .msg-banner.error, html[data-theme='light'] .msg-banner.error { background:#ffe9e9; color:#5d0b0b; }

    /* Field Validation Glow Effects */
    .form-group.field-filled input:not(:disabled),
    .form-group.field-filled select:not(:disabled),
    .form-group.field-filled textarea:not(:disabled),
    .form-group.field-filled .multi-select-button {
        border-color: rgba(16, 185, 129, 0.6) !important;
        box-shadow: 0 0 0 3px rgba(16, 185, 129, 0.15) !important;
    }

    .form-group.field-empty-required input:not(:disabled),
    .form-group.field-empty-required select:not(:disabled),
    .form-group.field-empty-required textarea:not(:disabled),
    .form-group.field-empty-required .multi-select-button:not([aria-disabled="true"]) {
        border-color: rgba(239, 68, 68, 0.6) !important;
        box-shadow: 0 0 0 3px rgba(239, 68, 68, 0.15) !important;
    }

    .form-group.field-empty-optional input:not(:disabled),
    .form-group.field-empty-optional select:not(:disabled),
    .form-group.field-empty-optional textarea:not(:disabled),
    .form-group.field-empty-optional .multi-select-button:not([aria-disabled="true"]) {
        border-color: rgba(245, 158, 11, 0.6) !important;
        box-shadow: 0 0 0 3px rgba(245, 158, 11, 0.15) !important;
    }

    /* Disabled fields stay gray (no glow) */
    .form-group input:disabled,
    .form-group select:disabled,
    .form-group textarea:disabled,
    .form-group .multi-select-button[aria-disabled="true"] {
        border-color: rgba(255,255,255,.14) !important;
        box-shadow: none !important;
        opacity: 0.5 !important;
        cursor: not-allowed !important;
        pointer-events: none !important;
    }

    html.theme-light .form-group input:disabled,
    html.theme-light .form-group select:disabled,
    html.theme-light .form-group textarea:disabled,
    html.theme-light .form-group .multi-select-button[aria-disabled="true"] {
        border-color: rgba(0,0,0,.14) !important;
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
      if (checkboxes.length === 0) buttonText.textContent = '';
      else if (checkboxes.length === 1) {
        var label = checkboxes[0].getAttribute('data-label') || checkboxes[0].getAttribute('aria-label') || checkboxes[0].parentNode.textContent.replace(/^\s+/, '').trim();
        buttonText.textContent = label;
      } else { buttonText.textContent = checkboxes.length + ' items selected'; }
    }
    function initializeMultiSelect(buttonId, optionsId) {
      var button = document.getElementById(buttonId);
      var options = document.getElementById(optionsId);
      var dropdown = button ? button.closest('.multi-select-dropdown') : null;
      if (!button || !options || !dropdown) return;
      if (dropdown.getAttribute('data-ms-init') === '1') return;
      dropdown.setAttribute('data-ms-init', '1');
      function openClose(toggle) {
        if (toggle) { options.classList.add('show'); dropdown.classList.add('open'); button.setAttribute('aria-expanded', 'true'); }
        else { options.classList.remove('show'); dropdown.classList.remove('open'); button.setAttribute('aria-expanded', 'false'); }
      }
      button.addEventListener('click', function(e){ e.preventDefault(); var isOpen = options.classList.contains('show'); closeAllMultiSelects(); openClose(!isOpen); });
      button.addEventListener('keydown', function(e){ if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); button.click(); } else if (e.key === 'Escape') { openClose(false); } });
      var optionRows = options.querySelectorAll('.multi-select-option');
      optionRows.forEach(function(row){ row.addEventListener('click', function(e){ if (e.target && e.target.tagName && e.target.tagName.toLowerCase() === 'input') return; var cb = row.querySelector('input[type="checkbox"]'); if (!cb) return; cb.checked = !cb.checked; cb.dispatchEvent(new Event('change', { bubbles: true })); }); });
      var checkboxes = options.querySelectorAll('input[type="checkbox"]');
      checkboxes.forEach(function(checkbox){ checkbox.addEventListener('change', function(){ updateMultiSelectButton(buttonId, optionsId); }); });
      updateMultiSelectButton(buttonId, optionsId);
    }
    function initializeAllMultiSelects() {
      var multiSelects = document.querySelectorAll('.multi-select-dropdown');
      multiSelects.forEach(function(dropdown){ var buttonEl = dropdown.querySelector('.multi-select-button'); var optionsEl = dropdown.querySelector('.multi-select-options'); if (buttonEl && optionsEl) { initializeMultiSelect(buttonEl.id, optionsEl.id); } });
    }
    function initializeImagePreviews(){
      var inputs = document.querySelectorAll('.img-picker input[type="file"]');
      inputs.forEach(function(input){
        if (input.getAttribute('data-img-init')==='1') return;
        input.setAttribute('data-img-init','1');
        input.addEventListener('change', function(){
          var file = input.files && input.files[0];
          var img = input.closest('.img-picker').querySelector('img.image-preview');
          var wrap = input.closest('.img-picker');
          if (!img) return;
          if (file){
            var url = URL.createObjectURL(file);
            img.src = url; img.style.display = 'block';
            img.onload = function(){ try{ URL.revokeObjectURL(url); }catch(e){} };
            if (wrap) wrap.classList.add('has-image');
          }
          else { if (wrap) wrap.classList.remove('has-image'); img.style.display = 'none'; img.removeAttribute('src'); }
        });
      });
    }
    function closeAllMultiSelects(except) {
      var openDropdowns = document.querySelectorAll('.multi-select-dropdown.open');
      openDropdowns.forEach(function(dd){ if (except && dd === except) return; dd.classList.remove('open'); var opts = dd.querySelector('.multi-select-options'); if (opts) opts.classList.remove('show'); var btn = dd.querySelector('.multi-select-button'); if (btn) btn.setAttribute('aria-expanded', 'false'); });
    }
    document.addEventListener('click', function(e) {
      var openDds = document.querySelectorAll('.multi-select-dropdown.open');
      openDds.forEach(function(dd){ if (!dd.contains(e.target)) { dd.classList.remove('open'); var opts = dd.querySelector('.multi-select-options'); if (opts) opts.classList.remove('show'); var btn = dd.querySelector('.multi-select-button'); if (btn) btn.setAttribute('aria-expanded', 'false'); } });
    });
    document.addEventListener('keydown', function(e){ if (e.key === 'Escape') closeAllMultiSelects(); });
    document.addEventListener('DOMContentLoaded', function(){ initializeAllMultiSelects(); initializeImagePreviews(); validateFields(); });
    if (typeof(Sys) !== 'undefined') { Sys.WebForms.PageRequestManager.getInstance().add_endRequest(function(){ initializeAllMultiSelects(); initializeImagePreviews(); validateFields(); }); }

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

            // Check if field is mandatory (match by suffix)
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
            'ATE': ['txtATEName', 'txtATEDescription', 'ddlLocation', 'ddlATEStatus'],
            'ASSET': ['txtModelNo', 'txtDeviceName', 'txtDeviceDescription', 'ddlLocation', 'ddlDeviceType', 'ddlManufacturer', 'txtManufacturerSite', 'ddlCurrentStatus'],
            'FIXTURE': ['txtFixtureModel', 'txtFixtureDescription', 'ddlLocation', 'ddlCurrentStatus'],
            'HARNESS': ['txtHarnessModel', 'txtHarnessDescription', 'ddlLocation', 'ddlCurrentStatus']
        };

        var baseFields = fields[itemType] || [];

        // Add conditional fields based on toggles
        var calToggle = document.querySelector('input[id$="chkRequiresCalibration"]');
        var pmToggle = document.querySelector('input[id$="chkRequiredPM"]');

        if (calToggle && calToggle.checked) {
            baseFields.push('txtCalibrationID', 'ddlCalFreq', 'txtCalEstimatedTime');
        }

        if (pmToggle && pmToggle.checked) {
            baseFields.push('ddlPMFreq', 'msPMResponsible', 'txtPMEstimatedTime');
        }

        return baseFields;
    }

    // Run validation on input/change
    document.addEventListener('input', validateFields);
    document.addEventListener('change', validateFields);

    // Toggle field enable/disable logic
    function setupToggleHandlers() {
        var calToggle = document.querySelector('input[id$="chkRequiresCalibration"]');
        var pmToggle = document.querySelector('input[id$="chkRequiredPM"]');
        
        // Requires Calibration toggle
        if (calToggle) {
            function updateCalFields() {
                var isChecked = calToggle.checked;
                var calIdField = document.querySelector('input[id$="txtCalibrationID"]');
                var calFreqField = document.querySelector('select[id$="ddlCalFreq"]');
                var calEstField = document.querySelector('input[id$="txtCalEstimatedTime"]');
                
                if (calIdField) calIdField.disabled = !isChecked;
                if (calFreqField) calFreqField.disabled = !isChecked;
                if (calEstField) calEstField.disabled = !isChecked;
                
                // Re-run validation after toggling
                setTimeout(validateFields, 10);
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
                var pmRespButton = document.querySelector('[id$="msPMResponsible_button"]');
                
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
                
                // Re-run validation after toggling
                setTimeout(validateFields, 10);
            }
            pmToggle.addEventListener('change', updatePMFields);
            updatePMFields(); // Initial state
        }
    }

    document.addEventListener('DOMContentLoaded', setupToggleHandlers);
    if (typeof(Sys) !== 'undefined') {
        Sys.WebForms.PageRequestManager.getInstance().add_endRequest(setupToggleHandlers);
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

    // Attach validation to Save button - more aggressive approach
    function attachValidation() {
        var btnSave = document.querySelector('[id$="btnSave"]');
        if (btnSave) {
            // Store original onclick
            var originalOnClick = btnSave.onclick;
            
            // Override the onclick
            btnSave.onclick = function(e) {
                if (!validateFormBeforeSubmit()) {
                    if (e) {
                        e.preventDefault();
                        e.stopPropagation();
                        e.stopImmediatePropagation();
                    }
                    return false;
                }
                // If validation passes, call original onclick if it exists
                if (originalOnClick) {
                    return originalOnClick.call(this, e);
                }
                return true;
            };
            
            // Also add event listener as backup
            btnSave.addEventListener('click', function(e) {
                if (!validateFormBeforeSubmit()) {
                    e.preventDefault();
                    e.stopPropagation();
                    e.stopImmediatePropagation();
                    return false;
                }
            }, true);
        }
    }

    document.addEventListener('DOMContentLoaded', function() {
        attachValidation();
        setupToggleHandlers();
        validateFields();
    });

    if (typeof(Sys) !== 'undefined') {
        Sys.WebForms.PageRequestManager.getInstance().add_endRequest(function() {
            attachValidation();
            initSearchableDropdown();
            setupToggleHandlers();
            validateFields();
        });
    }

    // Convert dropdown to searchable combobox
    function initSearchableDropdown() {
        var dropdown = document.querySelector('select[id$="ddlItemSelect"]');
        if (!dropdown || dropdown.dataset.searchable) return;
        
        dropdown.dataset.searchable = 'true';

        // Store all options
        var allOptions = Array.from(dropdown.options).map(function(opt) {
            return {
                value: opt.value,
                text: opt.text,
                selected: opt.selected
            };
        });

        // Create wrapper
        var wrapper = document.createElement('div');
        wrapper.className = 'searchable-dropdown';
        dropdown.parentNode.insertBefore(wrapper, dropdown);
        wrapper.appendChild(dropdown);

        // Create search input (styled like the dropdown)
        var searchInput = document.createElement('input');
        searchInput.type = 'text';
        searchInput.className = 'searchable-input ddl-eatonid';
        searchInput.placeholder = 'Select Eaton ID...';
        searchInput.autocomplete = 'off';

        // Create dropdown list
        var dropList = document.createElement('div');
        dropList.className = 'searchable-list';

        // Hide original dropdown, show our custom UI
        dropdown.style.display = 'none';
        wrapper.appendChild(searchInput);
        wrapper.appendChild(dropList);

        // Set initial value from current dropdown selection
        function setInitialValue() {
            var currentValue = dropdown.value;
            var selectedOpt = allOptions.find(function(opt) { return opt.value === currentValue; });
            if (selectedOpt && selectedOpt.value) {
                searchInput.value = selectedOpt.text;
                searchInput.placeholder = selectedOpt.text;
            } else {
                searchInput.value = '';
                searchInput.placeholder = 'Select Eaton ID...';
            }
        }

        // Call this initially
        setInitialValue();

        // Populate list
        function populateList(filter) {
            dropList.innerHTML = '';
            var hasResults = false;
            
            allOptions.forEach(function(opt) {
                if (filter && opt.value && opt.text.toLowerCase().indexOf(filter.toLowerCase()) === -1) {
                    return;
                }
                
                var item = document.createElement('div');
                item.className = 'searchable-item';
                item.textContent = opt.text;
                item.dataset.value = opt.value;
                
                if (opt.value === dropdown.value) {
                    item.classList.add('selected');
                }
                
                if (opt.value === '') {
                    item.classList.add('placeholder');
                }
                
                item.addEventListener('click', function(e) {
                    e.stopPropagation();
                    selectOption(opt);
                    dropList.classList.remove('open');
                });
                
                dropList.appendChild(item);
                if (opt.value) hasResults = true;
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
            searchInput.placeholder = opt.value ? opt.text : 'Select Eaton ID...';
            
            // Trigger AutoPostBack manually since programmatic change event may not work
            if (typeof(__doPostBack) !== 'undefined') {
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
    }

    // Initialize on page load
    document.addEventListener('DOMContentLoaded', initSearchableDropdown);
    if (typeof(Sys) !== 'undefined') {
        Sys.WebForms.PageRequestManager.getInstance().add_endRequest(function() {
            initSearchableDropdown();
        });
    }
  </script>
</asp:Content>

<asp:Content ID="Main" ContentPlaceHolderID="MainContent" runat="server">
  <div class="admin-grid">
    <uc2:ItemSidebar ID="ItemSidebar1" runat="server" />
    <div>
      <div class="header-row">
        <uc1:AdminHeader ID="AdminHeader1" runat="server" Title="Item Details" />
        <div class="header-actions">
          <asp:DropDownList ID="ddlItemSelect" runat="server" CssClass="ddl-eatonid" AutoPostBack="false" />
        </div>
      </div>
      <div class="admin-form">
        <asp:PlaceHolder ID="phMessage" runat="server" />
        <asp:HiddenField ID="hfType" runat="server" />
        <asp:HiddenField ID="hfKey" runat="server" />
        <asp:PlaceHolder ID="phFormFields" runat="server" />
        <div class="form-actions">
          <asp:LinkButton ID="btnSave" runat="server" CssClass="btn success" OnClick="btnSave_Click">
            <span aria-hidden="true"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" width="16" height="16"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/><polyline points="17 21 17 13 7 13 7 21"/><polyline points="7 3 7 8 15 8"/></svg></span>
            <span>Save changes</span>
          </asp:LinkButton>
        </div>
      </div>
    </div>
  </div>
</asp:Content>
