<%@ Page Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="CreateUser.aspx.cs" Inherits="TED_Admin_CreateUser" %>
<%@ Register Src="~/Admin/Controls/AdminHeader.ascx" TagPrefix="uc1" TagName="AdminHeader" %>
<%@ Register Src="~/Admin/Controls/AdminSidebar.ascx" TagPrefix="uc2" TagName="AdminSidebar" %>
<asp:Content ID="TitleC" ContentPlaceHolderID="TitleContent" runat="server">Create User - Admin</asp:Content>
<asp:Content ID="HeadC" ContentPlaceHolderID="HeadContent" runat="server">
  <style>
  /* Admin shell is defined in AdminSidebar control */
  .admin-form { background:rgba(25,29,37,.52); border:1px solid rgba(255,255,255,.08); border-radius:14px; padding:16px; box-shadow:0 16px 34px -12px rgba(0,0,0,.6), 0 0 0 1px rgba(255,255,255,.05); flex:1; min-height:0; overflow:auto; }
    html.theme-light .admin-form, html[data-theme='light'] .admin-form { background:#ffffff; border:1px solid rgba(0,0,0,.08); box-shadow:0 16px 34px -12px rgba(0,0,0,.16), 0 0 0 1px rgba(0,0,0,.05); }
    /* 3-column grid */
    .form-grid { display:grid; grid-template-columns: repeat(12, 1fr); gap:12px 12px; row-gap:24px; }
    .span-4 { grid-column: span 4; }
    .span-12 { grid-column: 1 / -1; }
    @media (max-width: 980px){ .span-4 { grid-column: 1 / -1; } }
  label { font-size:12px; opacity:.85; margin-bottom:6px; display:block; font-weight:bold; }
  /* Ensure inputs and selects use the app's modern font */
  input, select { width:100%; padding:10px 12px; border-radius:12px; border:1px solid rgba(255,255,255,.14); background:rgba(0,0,0,.15); color:inherit; font-size:13px; font-family:inherit; box-sizing:border-box; }
    input:focus, select:focus { outline:none; border-color:rgba(77,141,255,.5); box-shadow:0 0 0 3px rgba(77,141,255,.15); }
    html.theme-light input, html.theme-light select, html[data-theme='light'] input, html[data-theme='light'] select { background:#fff; border:1px solid rgba(0,0,0,.14); color:#1f242b; }
  /* Improve dropdown list (option) readability in dark and light modes */
  select option { background:#0f1b2e; color:#e9eef8; }
  select option:hover { background:#16223a; color:#ffffff; }
  select option:checked { background:#1e2b4a; color:#ffffff; }
  html.theme-light select option, html[data-theme='light'] select option { background:#ffffff; color:#1f2530; }
  html.theme-light select option:hover, html[data-theme='light'] select option:hover { background:#f3f7ff; color:#0b2960; }
  html.theme-light select option:checked, html[data-theme='light'] select option:checked { background:#e6f0ff; color:#0b2960; }
    .actions { margin-top:16px; display:flex; gap:14px; align-items:center; justify-content:flex-start; }
    .btn { padding:10px 16px; border-radius:12px; border:1px solid rgba(255,255,255,.14); text-decoration:none; cursor:pointer; transition:background .25s ease, border-color .25s ease, transform .2s ease, box-shadow .25s ease, color .2s ease; font-size:14px; display:inline-flex; align-items:center; justify-content:center; width:auto !important; }
  .btn.primary { background:linear-gradient(155deg,#0f365e,#0b2743); color:#e7f0ff; }
    .btn.primary:hover { transform:translateY(-1px); box-shadow:0 10px 20px -10px rgba(0,0,0,.65), 0 0 0 1px rgba(77,141,255,.35); }
    .btn.clear { background:rgba(255,255,255,.06); color:inherit; }
    .btn.clear:hover { background:rgba(255,255,255,.12); }
    .btn.cancel { background:rgba(255,255,255,.06); color:#c9cdd4; }
    .btn.cancel:hover { background:rgba(255,86,86,.14); border-color:rgba(255,86,86,.35); color:#ff8a8a; }
    .btn.clean { background:linear-gradient(155deg,#0b4a3d,#0a3a31); color:#e6fff7; }
    .btn.clean:hover { transform:translateY(-1px); box-shadow:0 10px 20px -10px rgba(0,0,0,.65), 0 0 0 1px rgba(64,180,120,.35); }
    html.theme-light .btn { border:1px solid rgba(0,0,0,.12); }
    html.theme-light .btn.primary, html[data-theme='light'] .btn.primary { background:#0b63ce; color:#fff; }
    html.theme-light .btn.clean, html[data-theme='light'] .btn.clean { background:#1fa37e; color:#ffffff; }
    html.theme-light .btn.clean:hover, html[data-theme='light'] .btn.clean:hover { box-shadow:0 10px 20px -10px rgba(0,0,0,.24); }
    html.theme-light .btn.clear:hover, html[data-theme='light'] .btn.clear:hover { background:#f6f8fb; }
    html.theme-light .btn.cancel:hover, html[data-theme='light'] .btn.cancel:hover { background:rgba(198,40,40,.10); border-color:rgba(198,40,40,.35); color:#b71c1c; }
    .inline-check { display:flex; align-items:center; gap:10px; height:38px; padding-top:14px; }
    .btn .ico { width:16px; height:16px; display:block; line-height:0; }
    .btn .ico svg { width:16px; height:16px; display:block; }
    .btn .txt { margin-left:8px; font-weight:600; }

    /* Multi-select dropdown styles */
    .multi-select-dropdown { position: relative; width: 100%; }
    .multi-select-button { width: 100%; padding: 10px 12px; border: 1px solid rgba(255,255,255,.14); border-radius: 12px; background: rgba(0,0,0,.15); text-align: left; cursor: pointer; font-size: 13px; display:flex; justify-content:space-between; align-items:center; min-height:38px; box-sizing:border-box; color:inherit; font-family: inherit; }
    html.theme-light .multi-select-button { background:#fff; border:1px solid rgba(0,0,0,.14); color:#1f242b; }
    .multi-select-button:focus { outline:none; border-color:rgba(77,141,255,.5); box-shadow:0 0 0 3px rgba(77,141,255,.15); }
    .multi-select-button .multi-select-text { flex:1; overflow:hidden; white-space:nowrap; text-overflow:ellipsis; font-size: 13px; color: inherit; line-height: 1.4; }
    .multi-select-arrow { margin-left: 8px; width: 0; height: 0; border-left: 5px solid transparent; border-right: 5px solid transparent; border-top: 6px solid currentColor; transform: rotate(0deg); transition: transform 0.2s ease; opacity: .7; }
    .multi-select-dropdown.open .multi-select-arrow { transform: rotate(180deg); }
    .multi-select-options { position:absolute; top:100%; left:0; right:0; margin-top:-1px; max-height:200px; overflow-y:auto; border:1px solid rgba(255,255,255,.14); border-top:none; border-radius:0 0 12px 12px; background: rgba(15,23,42,.98); z-index:5000; display:none; box-shadow:0 4px 12px rgba(0,0,0,0.25); color:inherit; font-size:13px; }
    html.theme-light .multi-select-options { background:#fff; border:1px solid rgba(0,0,0,.14); color:#1f242b; box-shadow:0 4px 12px rgba(0,0,0,0.1); }
    .multi-select-options.show { display:block; }
    .multi-select-option { padding:10px 12px; cursor:pointer; display:flex; align-items:center; transition: background-color 0.15s ease; border-bottom: 1px solid rgba(255,255,255,.05); }
    .multi-select-option:last-child { border-bottom: none; }
    .multi-select-option:hover { background: rgba(255,255,255,.08); }
    html.theme-light .multi-select-option { border-bottom: 1px solid rgba(0,0,0,.03); }
    html.theme-light .multi-select-option:hover { background: rgba(0,0,0,.03); }
    .multi-select-option input[type="checkbox"] { margin-right:10px; width: 16px; height: 16px; }
    .multi-select-option-label { font-size: 13px; line-height: 1.4; color: inherit; font-weight: 400; }
  </style>
  <script type="text/javascript">
    window.showToast = function(message, type){
      try {
        var el = document.getElementById('globalToast');
        if(!el){ el = document.createElement('div'); el.id = 'globalToast'; el.className = 'global-toast'; document.body.appendChild(el); }
        el.textContent = message || '';
        el.className = 'global-toast ' + (type || 'success');
        el.style.display = 'block'; el.style.opacity = '1';
        clearTimeout(window.__toastTimer);
        window.__toastTimer = setTimeout(function(){ el.style.transition = 'opacity .35s ease'; el.style.opacity = '0'; setTimeout(function(){ el.style.display = 'none'; el.style.transition = ''; }, 380); }, 2000);
      } catch(e){}
    };
  </script>
  <script type="text/javascript">
    function cleanForm(){
      try{
        var ids = {
          name: '<%= txtFullName.ClientID %>',
          en: '<%= txtENumber.ClientID %>',
          email: '<%= txtEmail.ClientID %>',
          dept: '<%= ddlDepartment.ClientID %>',
          role: '<%= ddlJobRole.ClientID %>',
          pwd: '<%= txtTempPassword.ClientID %>',
          file: '<%= fuProfile.ClientID %>',
          cat: '<%= ddlCategory.ClientID %>',
          msg: '<%= lblMsg.ClientID %>'
        };
        var el;
        if ((el = document.getElementById(ids.name))) el.value = '';
        if ((el = document.getElementById(ids.en))) el.value = '';
        if ((el = document.getElementById(ids.email))) el.value = '';
        if ((el = document.getElementById(ids.dept))) el.selectedIndex = 0;
        if ((el = document.getElementById(ids.role))) el.selectedIndex = 0;
        if ((el = document.getElementById(ids.pwd))) el.value = '';
        if ((el = document.getElementById(ids.file))) { try { el.value = ''; } catch(e){} }
        if ((el = document.getElementById(ids.cat))) el.selectedIndex = 0;
        if ((el = document.getElementById(ids.msg))) el.textContent = '';
        
        // Clear multi-select dropdown
        var checkboxes = document.querySelectorAll('#msTestLine_options input[type="checkbox"]');
        checkboxes.forEach(function(cb) { cb.checked = false; });
        updateMultiSelectButton('msTestLine_button', 'msTestLine_options');
      }catch(e){}
      return false;
    }

    // Multi-select dropdown functions
    function updateMultiSelectButton(buttonId, optionsId) {
      var button = document.getElementById(buttonId);
      var options = document.getElementById(optionsId);
      if (!button || !options) return;
      var checkboxes = options.querySelectorAll('input[type="checkbox"]:checked');
      var buttonText = button.querySelector('.multi-select-text');
      if (!buttonText) return;
      
      if (checkboxes.length === 0) {
        buttonText.textContent = '';
      } else if (checkboxes.length === 1) {
        var label = checkboxes[0].getAttribute('data-label') || checkboxes[0].getAttribute('aria-label');
        if (!label) {
          var labelSpan = checkboxes[0].parentNode.querySelector('.multi-select-option-label');
          label = labelSpan ? labelSpan.textContent.trim() : checkboxes[0].parentNode.textContent.replace(/^\s+/, '').trim();
        }
        buttonText.textContent = label;
        buttonText.title = label; // Add tooltip for long names
      } else if (checkboxes.length <= 3) {
        // Show up to 3 items, then use count
        var labels = [];
        for (var i = 0; i < checkboxes.length; i++) {
          var label = checkboxes[i].getAttribute('data-label') || checkboxes[i].getAttribute('aria-label');
          if (!label) {
            var labelSpan = checkboxes[i].parentNode.querySelector('.multi-select-option-label');
            label = labelSpan ? labelSpan.textContent.trim() : checkboxes[i].parentNode.textContent.replace(/^\s+/, '').trim();
          }
          labels.push(label);
        }
        var displayText = labels.join(', ');
        if (displayText.length > 40) {
          buttonText.textContent = checkboxes.length + ' lines selected';
        } else {
          buttonText.textContent = displayText;
        }
        buttonText.title = labels.join(', '); // Full list in tooltip
      } else {
        buttonText.textContent = checkboxes.length + ' lines selected';
        // Create tooltip with all selected items
        var allLabels = [];
        for (var i = 0; i < checkboxes.length; i++) {
          var label = checkboxes[i].getAttribute('data-label') || checkboxes[i].getAttribute('aria-label');
          if (!label) {
            var labelSpan = checkboxes[i].parentNode.querySelector('.multi-select-option-label');
            label = labelSpan ? labelSpan.textContent.trim() : checkboxes[i].parentNode.textContent.replace(/^\s+/, '').trim();
          }
          allLabels.push(label);
        }
        buttonText.title = allLabels.join(', ');
      }
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

    function closeAllMultiSelects(except) {
      var openDropdowns = document.querySelectorAll('.multi-select-dropdown.open');
      openDropdowns.forEach(function(dd){ if (except && dd === except) return; dd.classList.remove('open'); var opts = dd.querySelector('.multi-select-options'); if (opts) opts.classList.remove('show'); var btn = dd.querySelector('.multi-select-button'); if (btn) btn.setAttribute('aria-expanded', 'false'); });
    }

    function populateTestLineDropdown() {
      var productionLines = window.productionLinesData || [];
      var optionsContainer = document.getElementById('msTestLine_options');
      if (optionsContainer) {
        optionsContainer.innerHTML = '';
        
        // Sort production lines alphabetically for better UX
        productionLines.sort(function(a, b) {
          return a.name.localeCompare(b.name, undefined, { numeric: true, sensitivity: 'base' });
        });
        
        productionLines.forEach(function(line) {
          var optionDiv = document.createElement('div');
          optionDiv.className = 'multi-select-option';
          optionDiv.setAttribute('role', 'option');
          
          var checkbox = document.createElement('input');
          checkbox.type = 'checkbox';
          checkbox.id = 'msTestLine_' + line.id;
          checkbox.name = 'msTestLine_' + line.id;
          checkbox.value = line.id;
          checkbox.setAttribute('data-label', line.name);
          checkbox.setAttribute('aria-label', 'Select ' + line.name);
          
          var label = document.createElement('span');
          label.className = 'multi-select-option-label';
          label.textContent = line.name;
          label.setAttribute('title', line.name); // Tooltip for long names
          
          optionDiv.appendChild(checkbox);
          optionDiv.appendChild(label);
          optionsContainer.appendChild(optionDiv);
        });
      }
    }

    document.addEventListener('click', function(e) {
      var openDds = document.querySelectorAll('.multi-select-dropdown.open');
      openDds.forEach(function(dd){ if (!dd.contains(e.target)) { dd.classList.remove('open'); var opts = dd.querySelector('.multi-select-options'); if (opts) opts.classList.remove('show'); var btn = dd.querySelector('.multi-select-button'); if (btn) btn.setAttribute('aria-expanded', 'false'); } });
    });

    document.addEventListener('keydown', function(e){ if (e.key === 'Escape') closeAllMultiSelects(); });

    document.addEventListener('DOMContentLoaded', function(){ 
      populateTestLineDropdown();
      initializeMultiSelect('msTestLine_button', 'msTestLine_options'); 
      
      // Add E Number validation and email disabling
      var txtENumber = document.getElementById('<%= txtENumber.ClientID %>');
      var txtEmail = document.getElementById('<%= txtEmail.ClientID %>');
      
      if (txtENumber && txtEmail) {
        txtENumber.addEventListener('input', function() {
          var value = txtENumber.value.trim().toUpperCase();
          if (value.startsWith('C')) {
            txtEmail.disabled = true;
            txtEmail.value = '';
            txtEmail.style.backgroundColor = '#e0e0e0';
            txtEmail.style.color = '#888';
            txtEmail.style.opacity = '0.7';
            txtEmail.style.cursor = 'not-allowed';
          } else if (value.startsWith('E')) {
            txtEmail.disabled = false;
            txtEmail.style.backgroundColor = '';
            txtEmail.style.color = '';
            txtEmail.style.opacity = '1';
            txtEmail.style.cursor = '';
          }
        });
        
        // Check initial value on page load
        var initialValue = txtENumber.value.trim().toUpperCase();
        if (initialValue.startsWith('C')) {
          txtEmail.disabled = true;
          txtEmail.value = '';
          txtEmail.style.backgroundColor = '#e0e0e0';
          txtEmail.style.color = '#888';
          txtEmail.style.opacity = '0.7';
          txtEmail.style.cursor = 'not-allowed';
        }
      }
      
      // Validation function for Create User button
      window.validateCreateUserForm = function() {
        // Get all form fields
        var txtFullName = document.getElementById('<%= txtFullName.ClientID %>');
        var txtENumber = document.getElementById('<%= txtENumber.ClientID %>');
        var txtEmail = document.getElementById('<%= txtEmail.ClientID %>');
        var ddlDepartment = document.getElementById('<%= ddlDepartment.ClientID %>');
        var ddlJobRole = document.getElementById('<%= ddlJobRole.ClientID %>');
        var txtTempPassword = document.getElementById('<%= txtTempPassword.ClientID %>');
        var ddlCategory = document.getElementById('<%= ddlCategory.ClientID %>');
        
        var errors = [];
        
        // Full Name is required
        if (!txtFullName || !txtFullName.value.trim()) {
          errors.push('Full Name is required');
        }
        
        // E Number is required and must start with E or C
        if (!txtENumber || !txtENumber.value.trim()) {
          errors.push('E Number is required');
        } else {
          var eNum = txtENumber.value.trim().toUpperCase();
          if (!eNum.startsWith('E') && !eNum.startsWith('C')) {
            errors.push('E Number must start with E or C');
          }
        }
        
        // Email is required if E Number starts with E
        if (txtENumber && txtENumber.value.trim().toUpperCase().startsWith('E')) {
          if (!txtEmail || !txtEmail.value.trim()) {
            errors.push('Email is required for E Numbers');
          }
        }
        
        // Department is required
        if (!ddlDepartment || !ddlDepartment.value) {
          errors.push('Department is required');
        }
        
        // Job Role is required
        if (!ddlJobRole || !ddlJobRole.value) {
          errors.push('Job Role is required');
        }
        
        // Password is required
        if (!txtTempPassword || !txtTempPassword.value.trim()) {
          errors.push('Password is required');
        }
        
        // User Category is required
        if (!ddlCategory || !ddlCategory.value) {
          errors.push('User Category is required');
        }
        
        // If there are errors, prevent submission and show alert
        if (errors.length > 0) {
          alert('Please fix the following errors:\n\n' + errors.join('\n'));
          return false;
        }
        
        // Copy checkbox values to hidden inputs for Test Line
        copyTestLineCheckboxes();
        return true;
      };
      
      // Function to copy Test Line checkboxes to hidden inputs
      function copyTestLineCheckboxes() {
        var form = document.forms[0];
        if (!form) return;
        
        // Remove any existing hidden inputs for test lines
        var existingHiddens = document.querySelectorAll('input[name^="msTestLine_"][type="hidden"]');
        existingHiddens.forEach(function(input) {
          input.remove();
        });
        
        // Find all checked checkboxes
        var checkboxes = document.querySelectorAll('#msTestLine_options input[type="checkbox"]:checked');
        checkboxes.forEach(function(checkbox) {
          // Create a hidden input with the same name and value
          var hidden = document.createElement('input');
          hidden.type = 'hidden';
          hidden.name = checkbox.name;
          hidden.value = checkbox.value;
          form.appendChild(hidden);
        });
      }
    });
  </script>
  <style>
    .global-toast { position:fixed; top:18px; left:50%; transform:translateX(-50%); z-index:9999; display:none; padding:10px 14px; border-radius:12px; font-weight:800; font-size:13px; border:1px solid rgba(255,255,255,.18); backdrop-filter:blur(10px) saturate(140%); box-shadow:0 14px 28px -12px rgba(0,0,0,.55), 0 0 0 1px rgba(255,255,255,.06); }
    .global-toast.success { background:rgba(25,29,37,.75); color:#c8f5d1; border-color:rgba(64,180,120,.35); }
    .global-toast.error { background:rgba(25,29,37,.75); color:#ffcccc; border-color:rgba(255,80,80,.35); }
    html.theme-light .global-toast, html[data-theme='light'] .global-toast { background:#ffffff; color:#1f242b; border:1px solid rgba(0,0,0,.12); }
    html.theme-light .global-toast.success, html[data-theme='light'] .global-toast.success { color:#1e7f45; border-color:#b2e2c6; }
    html.theme-light .global-toast.error, html[data-theme='light'] .global-toast.error { color:#a32828; border-color:#f5b3b3; }
  </style>
</asp:Content>
<asp:Content ID="MainC" ContentPlaceHolderID="MainContent" runat="server">
  <div class="admin-grid">
    <uc2:AdminSidebar ID="AdminSidebar1" runat="server" />
    <div>
  <uc1:AdminHeader ID="AdminHeader1" runat="server" Title="Create User Form" />
      <div id="globalToast" class="global-toast" style="display:none"></div>
      <asp:Panel ID="pnlEditing" runat="server" Visible="false" style="margin:6px 0 10px;">
    <div style="padding:10px 14px;border-radius:10px;background:rgba(255,255,255,.06);border:1px solid rgba(255,255,255,.14);">
      <span style="font-weight:700;">Editing user…</span> Any changes will be saved to the selected user.
    </div>
  </asp:Panel>
  <div class="admin-form">
    <div class="form-grid">
      <!-- Row 1: Full name | E number | Email -->
      <div class="span-4"><label>Full Name</label><asp:TextBox ID="txtFullName" runat="server" /></div>
      <div class="span-4">
        <label>E Number</label>
        <asp:TextBox ID="txtENumber" runat="server" />
        <small style="display:block; margin-top:4px; font-size:11px; opacity:0.7; font-style:italic;">Must start with E or C</small>
      </div>
      <div class="span-4">
        <label>Email</label>
        <asp:TextBox ID="txtEmail" TextMode="Email" runat="server" />
        <small style="display:block; margin-top:4px; font-size:11px; opacity:0.7; font-style:italic;">Not required for C numbers</small>
      </div>

      <!-- Row 2: Department | Job Role | Test Line -->
      <div class="span-4"><label>Department</label>
        <asp:DropDownList ID="ddlDepartment" runat="server">
          <asp:ListItem Value="" Selected="True"></asp:ListItem>
        </asp:DropDownList>
      </div>
      <div class="span-4"><label>Job Role</label>
        <asp:DropDownList ID="ddlJobRole" runat="server">
          <asp:ListItem Value="" Selected="True"></asp:ListItem>
        </asp:DropDownList>
      </div>
      <div class="span-4">
        <label>Test Line</label>
        <div class="multi-select-dropdown">
          <div class="multi-select-button" id="msTestLine_button">
            <span class="multi-select-text"></span>
            <span class="multi-select-arrow"></span>
          </div>
          <div class="multi-select-options" id="msTestLine_options"></div>
        </div>
      </div>

      <!-- Row 3: Password | Picture | User Category -->
      <div class="span-4"><label>Password</label><asp:TextBox ID="txtTempPassword" runat="server" TextMode="Password" /></div>
      <div class="span-4"><label>Picture</label><asp:FileUpload ID="fuProfile" runat="server" /></div>
      <div class="span-4"><label>User Category</label>
        <asp:DropDownList ID="ddlCategory" runat="server">
          <asp:ListItem Value="" Selected="True"></asp:ListItem>
        </asp:DropDownList>
      </div>
      </div>

      <!-- Legacy/optional fields, hidden but kept for code-behind compatibility -->
      <asp:TextBox ID="txtPhone" runat="server" Style="display:none;" />
      <asp:TextBox ID="txtSite" runat="server" Style="display:none;" />
      <asp:TextBox ID="txtManager" runat="server" Style="display:none;" />

      <div class="span-12 actions">
        <asp:LinkButton ID="btnCreate" runat="server" CssClass="btn primary" OnClick="btnCreate_Click" OnClientClick="return validateCreateUserForm();">
          <span aria-hidden="true" class="ico">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 5v14"/><path d="M5 12h14"/></svg>
          </span>
          <span class="txt">Create User</span>
        </asp:LinkButton>
        <asp:LinkButton ID="btnClean" runat="server" CssClass="btn clean" OnClientClick="return cleanForm();" CausesValidation="False">
          <span aria-hidden="true" class="ico">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 19l6-6"/><path d="M9 13l9-9 3 3-9 9"/><path d="M5 21l4-1-3-3-1 4z"/></svg>
          </span>
          <span class="txt">Clean</span>
        </asp:LinkButton>
        <asp:Label ID="lblMsg" runat="server" />
      </div>
    </div>
  </div>
    </div>
  </div>
</asp:Content>
