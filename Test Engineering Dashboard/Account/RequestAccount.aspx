<%@ Page Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="RequestAccount.aspx.cs" Inherits="TED_Account_RequestAccount" %>
<asp:Content ID="ReqTitle" ContentPlaceHolderID="TitleContent" runat="server">Request Account - Test Engineering Dashboard</asp:Content>
<asp:Content ID="ReqHead" ContentPlaceHolderID="HeadContent" runat="server">
  <style>
    * { box-sizing:border-box; }
  body { margin:0; min-height:100vh; display:flex; align-items:flex-start; justify-content:center; padding:44px 24px 88px; overflow-y:auto; }
    .card { width:100%; max-width:820px; background:rgba(25,30,38,.62); backdrop-filter:blur(55px) saturate(145%); border:1px solid rgba(255,255,255,.08); border-radius:30px; padding:60px 62px 66px; position:relative; box-shadow:0 26px 60px -14px rgba(0,0,0,.78),0 2px 4px rgba(0,0,0,.45),0 0 0 1px rgba(255,255,255,.06); overflow:visible; }
  /* moved to theme.css: .card light-mode */
    .card:before { content:""; position:absolute; inset:0; background:linear-gradient(140deg,rgba(255,255,255,.07),rgba(255,255,255,0) 45%); pointer-events:none; }
    h1 { margin:0 0 10px; font-size:32px; letter-spacing:-.02em; }
    p.lead { margin:0 0 34px; font-size:15px; color:#90a0b3; max-width:640px; }
  /* moved to theme.css: p.lead light-mode */
    fieldset { border:none; margin:0 0 38px; padding:0; }
    legend { font-size:16px; font-weight:600; margin:0 0 22px; color:#ffffff; letter-spacing:.5px; }
  /* moved to theme.css: legend light-mode */
    .grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(260px,1fr)); gap:28px 34px; }
    .field { display:flex; flex-direction:column; }
    label { font-size:12px; letter-spacing:.6px; font-weight:600; margin:0 0 6px; color:#aeb9c7; text-transform:uppercase; }
  /* moved to theme.css: label light-mode */
  .input, select { width:100%; padding:15px 18px 14px; background:rgba(34,40,50,.74); border:1px solid rgba(255,255,255,.12); border-radius:16px; color:#f5f7fa; font-size:14px; font-weight:500; outline:none; transition:background .2s ease,border-color .2s ease,box-shadow .25s ease; box-shadow:inset 0 1px 2px rgba(0,0,0,.55); font-family:inherit; }
    .input:focus, select:focus { background:rgba(44,50,60,.92); border-color:var(--accent-blue); box-shadow:0 0 0 3px rgba(77,141,255,.25),0 4px 14px -4px rgba(0,0,0,.6); }
  /* moved to theme.css: input/select light-mode and focus */
    .two-col { display:grid; grid-template-columns:repeat(auto-fit,minmax(260px,1fr)); gap:28px 34px; }
    .pw-wrapper { position:relative; }
    .hint { font-size:11px; margin-top:8px; color:#6c7887; }
  /* moved to theme.css: .hint light-mode */
    .actions { display:flex; flex-wrap:wrap; gap:18px; margin-top:8px; }
  /* Using shared classes from theme.css (btn-base, btn-clear) */
    .status { margin-top:26px; font-size:13px; letter-spacing:.3px; }
    .success { color:#52e5a2; }
    .error { color:#ff9d9d; }
    .req { color:#ff7f7f; margin-left:2px; }
    .avatar { display:flex; align-items:center; gap:18px; }
    .avatar input[type=file] { font-size:12px; }
    a.back { position:absolute; top:16px; left:18px; font-size:12px; text-decoration:none; color:#8ab4ff; letter-spacing:.55px; font-weight:500; display:inline-flex; align-items:center; gap:6px; padding:6px 10px 6px 8px; border-radius:10px; background:rgba(255,255,255,.06); border:1px solid rgba(255,255,255,.12); backdrop-filter:blur(6px); transition:background .35s ease,border-color .35s ease,color .35s ease,transform .25s ease; }
    a.back:hover { background:rgba(255,255,255,.12); color:#ffffff; transform:translateY(-2px); }
  /* moved to theme.css: a.back light-mode improved */
  .theme-toggle { position:absolute; top:12px; right:12px; background:rgba(40,45,54,.6); border:1px solid rgba(255,255,255,.14); width:35px; height:35px; border-radius:12px; display:flex; align-items:center; justify-content:center; cursor:pointer; transition:background .45s ease,border-color .45s ease,transform .25s ease,box-shadow .45s ease,color .45s ease; box-shadow:0 2px 6px rgba(0,0,0,.50), inset 0 1px 0 rgba(255,255,255,.07); color:#8d96a3; }
  .theme-toggle:hover { background:rgba(52,59,69,.88); transform:translateY(-2px); box-shadow:0 7px 12px -5px rgba(0,0,0,.6),0 0 0 1px rgba(77,141,255,.25); }
  /* shared in theme.css: theme-toggle light-mode */
  .toggle-icon { width:19px; height:19px; position:relative; }
    .toggle-icon svg { position:absolute; inset:0; width:100%; height:100%; transition:opacity .4s ease, transform .5s ease; }
    .toggle-icon .icon-sun { opacity:0; transform:rotate(-40deg) scale(.55); }
  /* shared in theme.css: toggle icons */
    .footer-meta { position:absolute; bottom:18px; left:0; right:0; display:flex; justify-content:center; font-size:11px; letter-spacing:.6px; opacity:.85; }
    .footer-meta span.badge-int { font-size:10px; padding:4px 6px 3px; border:1px solid rgba(255,255,255,.15); border-radius:6px; background:rgba(255,255,255,.07); font-weight:600; letter-spacing:1px; margin-right:6px; }
  /* moved to theme.css: badge-int light-mode */
    @media (max-width:860px){ 
        .card { padding:54px 38px 76px; } 
        body { padding:32px 16px 64px; }
    }
    @media (max-width:640px){ 
        .grid, .two-col { gap:22px 24px; grid-template-columns:1fr; } 
        .card { padding:40px 24px 60px; border-radius:24px; }
        h1 { font-size:26px; }
        body { padding:24px 12px 48px; }
    }
    @media (max-width:480px){ 
        .card { padding:32px 20px 52px; }
        h1 { font-size:22px; }
    }

    /* Field Validation Glow Effects */
    .field.field-valid .input,
    .field.field-valid select {
        border-color: rgba(16, 185, 129, 0.6) !important;
        box-shadow: 0 0 0 3px rgba(16, 185, 129, 0.15) !important;
    }

    .field.field-invalid .input,
    .field.field-invalid select {
        border-color: rgba(239, 68, 68, 0.6) !important;
        box-shadow: 0 0 0 3px rgba(239, 68, 68, 0.15) !important;
    }

    /* Message banner at top */
    .msg-banner {
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
        max-width: 600px;
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

    /* Hide the old status label */
    .status {
        display: none !important;
    }
  </style>
</asp:Content>
<asp:Content ID="ReqMain" ContentPlaceHolderID="MainContent" runat="server">
  <div style="width:100%;display:flex;justify-content:center;">
    <div class="card" role="main" aria-labelledby="requestTitleH">
  <button type="button" id="themeToggle" class="theme-toggle" aria-label="Toggle light/dark mode" title="Toggle light/dark mode" data-theme-toggle>
        <span class="toggle-icon" aria-hidden="true">
          <svg class="icon-moon" viewBox="0 0 24 24" fill="none" stroke="none" xmlns="http://www.w3.org/2000/svg"><path fill="currentColor" d="M12.9 2.1c.6 0 .9.7.6 1.2A8.8 8.8 0 0 0 12 7.5a8.5 8.5 0 0 0 8.5 8.5c1.6 0 3.2-.4 4.2-.8.6-.2 1.1.4.8 1A11 11 0 1 1 12.9 2.1Z"/></svg>
          <svg class="icon-sun" viewBox="0 0 24 24" fill="none" stroke="none" xmlns="http://www.w3.org/2000/svg"><circle cx="12" cy="12" r="5" fill="currentColor"/><g stroke="currentColor" stroke-width="1.8" stroke-linecap="round"><line x1="12" y1="1.6" x2="12" y2="4.2" /><line x1="12" y1="19.8" x2="12" y2="22.4" /><line x1="4.2" y1="12" x2="1.6" y2="12" /><line x1="22.4" y1="12" x2="19.8" y2="12" /><line x1="5.8" y1="5.8" x2="4" y2="4" /><line x1="20" y1="20" x2="18.2" y2="18.2" /><line x1="18.2" y1="5.8" x2="20" y2="4" /><line x1="4" y1="20" x2="5.8" y2="18.2" /></g></svg>
        </span>
      </button>
      <a href="Login.aspx" class="back" title="Back to Login" aria-label="Back to Login">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/><line x1="9" y1="12" x2="21" y2="12"/></svg>
        <span>Back to Login</span>
      </a>
  <h1 id="requestTitleH">Request an Account</h1>
      <p class="lead">Fill in the details below. Your request will be reviewed and you will be notified by email.</p>

  <fieldset>
        <legend>User Information</legend>
        <div class="grid">
          <div class="field">
            <label for="txtFullName">Full Name<span class="req">*</span></label>
            <asp:TextBox ID="txtFullName" runat="server" CssClass="input" />
          </div>
          <div class="field">
            <label for="txtENumber">E Number<span class="req">*</span></label>
            <asp:TextBox ID="txtENumber" runat="server" CssClass="input" />
            <div class="hint">Must start with 'E' or 'C' (e.g., E123456 or C123456).</div>
          </div>
          <div class="field">
            <label for="txtEmail">Email<span class="req">*</span></label>
            <asp:TextBox ID="txtEmail" runat="server" CssClass="input" />
            <div class="hint">Valid email address required (not required for C numbers).</div>
          </div>
            <div class="field">
            <label for="ddlDepartment">Department<span class="req">*</span></label>
            <asp:DropDownList ID="ddlDepartment" runat="server" CssClass="input"></asp:DropDownList>
          </div>
          <div class="field">
            <label for="ddlJobRole">Job Role<span class="req">*</span></label>
            <asp:DropDownList ID="ddlJobRole" runat="server" CssClass="input"></asp:DropDownList>
          </div>
          <div class="field">
            <label for="fuProfile">Profile Picture</label>
            <asp:FileUpload ID="fuProfile" runat="server" />
            <div class="hint">Optional. PNG/JPG up to 2 MB.</div>
          </div>
        </div>
      </fieldset>

      <fieldset>
        <legend>Security</legend>
        <div class="two-col">
          <div class="pw-wrapper field">
            <label for="txtPassword">Password<span class="req">*</span></label>
            <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" CssClass="input" />
            <div class="hint">8+ chars, mix letters & numbers recommended.</div>
          </div>
          <div class="pw-wrapper field">
            <label for="txtPassword2">Repeat Password<span class="req">*</span></label>
            <asp:TextBox ID="txtPassword2" runat="server" TextMode="Password" CssClass="input" />
          </div>
        </div>
      </fieldset>

      <div class="actions">
        <asp:Button ID="btnSubmit" runat="server" Text="Submit Request" CssClass="btn-base" OnClick="btnSubmit_Click" />
      </div>

      <div aria-live="polite" id="statusLive" class="visually-hidden"></div>
      <asp:Label ID="lblStatus" runat="server" CssClass="status" />
      <!-- Removed duplicate internal footer; global footer remains -->
    </div>
  </div>
</asp:Content>
<asp:Content ID="ReqScripts" ContentPlaceHolderID="ScriptContent" runat="server">
  <style>.visually-hidden{position:absolute!important;clip:rect(1px,1px,1px,1px);padding:0;border:0;height:1px;width:1px;overflow:hidden;}</style>
  <script type="text/javascript">
    (function(){
      var lbl = document.getElementById('<%= lblStatus.ClientID %>');
      var live = document.getElementById('statusLive');
      if(lbl && live){
        var mo = new MutationObserver(function(){ if(lbl.innerText.trim()){ live.textContent = lbl.innerText; } });
        mo.observe(lbl,{ childList:true, subtree:true, characterData:true });
      }
    })();
  </script>
  
  <script type="text/javascript">
    // Validation and Banner Notification System
    document.addEventListener('DOMContentLoaded', function() {
      // Get all form fields
      var txtFullName = document.getElementById('<%= txtFullName.ClientID %>');
      var txtENumber = document.getElementById('<%= txtENumber.ClientID %>');
      var txtEmail = document.getElementById('<%= txtEmail.ClientID %>');
      var ddlDepartment = document.getElementById('<%= ddlDepartment.ClientID %>');
      var ddlJobRole = document.getElementById('<%= ddlJobRole.ClientID %>');
      var txtPassword = document.getElementById('<%= txtPassword.ClientID %>');
      var txtPassword2 = document.getElementById('<%= txtPassword2.ClientID %>');
      var btnSubmit = document.getElementById('<%= btnSubmit.ClientID %>');
      
      // Validation rules
      function validateField(field) {
        if (!field) return;
        
        var fieldWrapper = field.closest('.field');
        if (!fieldWrapper) return;
        
        var fieldId = field.id;
        var value = field.value.trim();
        var isValid = false;
        
        // Full Name - required, non-empty
        if (fieldId.indexOf('txtFullName') !== -1) {
          isValid = value.length > 0;
        }
        
        // E Number - required, starts with 'E' or 'C' (case-insensitive)
        else if (fieldId.indexOf('txtENumber') !== -1) {
          var upperValue = value.toUpperCase();
          isValid = value.length > 0 && (upperValue.startsWith('E') || upperValue.startsWith('C'));
          
          // Disable/enable email based on E Number
          if (txtEmail) {
            if (upperValue.startsWith('C')) {
              txtEmail.disabled = true;
              txtEmail.value = '';
              txtEmail.style.backgroundColor = '#e0e0e0';
              txtEmail.style.color = '#888';
              txtEmail.style.cursor = 'not-allowed';
              txtEmail.style.opacity = '0.7';
              var emailWrapper = txtEmail.closest('.field-wrapper');
              if (emailWrapper) {
                emailWrapper.classList.remove('field-invalid', 'field-valid');
                var emailLabel = emailWrapper.querySelector('label .req');
                if (emailLabel) emailLabel.style.display = 'none';
              }
            } else if (upperValue.startsWith('E')) {
              txtEmail.disabled = false;
              txtEmail.style.backgroundColor = '';
              txtEmail.style.color = '';
              txtEmail.style.cursor = '';
              txtEmail.style.opacity = '';
              var emailWrapper = txtEmail.closest('.field-wrapper');
              if (emailWrapper) {
                var emailLabel = emailWrapper.querySelector('label .req');
                if (emailLabel) emailLabel.style.display = 'inline';
              }
              validateField(txtEmail);
            }
          }
        }
        
        // Email - required only if E Number starts with 'E', contains @
        else if (fieldId.indexOf('txtEmail') !== -1) {
          if (txtEmail.disabled) {
            isValid = true; // Always valid if disabled
          } else {
            isValid = value.length > 0 && value.indexOf('@') !== -1;
          }
        }
        
        // Department - required, not default selection
        else if (fieldId.indexOf('ddlDepartment') !== -1) {
          isValid = value !== '' && value !== '-- Select --' && value !== 'Select';
        }
        
        // Job Role - required, not default selection
        else if (fieldId.indexOf('ddlJobRole') !== -1) {
          isValid = value !== '' && value !== '-- Select --' && value !== 'Select';
        }
        
        // Password - required, 8+ characters
        else if (fieldId.indexOf('txtPassword') !== -1 && fieldId.indexOf('txtPassword2') === -1) {
          isValid = value.length >= 8;
        }
        
        // Confirm Password - required, matches password
        else if (fieldId.indexOf('txtPassword2') !== -1) {
          var password1 = txtPassword ? txtPassword.value : '';
          isValid = value.length >= 8 && value === password1;
        }
        
        // Apply validation classes
        if (isValid) {
          fieldWrapper.classList.remove('field-invalid');
          fieldWrapper.classList.add('field-valid');
        } else {
          fieldWrapper.classList.remove('field-valid');
          fieldWrapper.classList.add('field-invalid');
        }
      }
      
      // Validate all fields
      function validateAllFields() {
        if (txtFullName) validateField(txtFullName);
        if (txtENumber) validateField(txtENumber);
        if (txtEmail) validateField(txtEmail);
        if (ddlDepartment) validateField(ddlDepartment);
        if (ddlJobRole) validateField(ddlJobRole);
        if (txtPassword) validateField(txtPassword);
        if (txtPassword2) validateField(txtPassword2);
      }
      
      // Check if form is valid
      function isFormValid() {
        var fullNameValid = txtFullName && txtFullName.value.trim().length > 0;
        var eNumberUpper = txtENumber ? txtENumber.value.trim().toUpperCase() : '';
        var eNumberValid = txtENumber && txtENumber.value.trim().length > 0 && (eNumberUpper.startsWith('E') || eNumberUpper.startsWith('C'));
        var emailValid = true; // Default to valid
        if (txtEmail && !txtEmail.disabled) {
          emailValid = txtEmail.value.trim().length > 0 && txtEmail.value.indexOf('@') !== -1;
        }
        var deptValid = ddlDepartment && ddlDepartment.value !== '' && ddlDepartment.value !== '-- Select --' && ddlDepartment.value !== 'Select';
        var roleValid = ddlJobRole && ddlJobRole.value !== '' && ddlJobRole.value !== '-- Select --' && ddlJobRole.value !== 'Select';
        var passwordValid = txtPassword && txtPassword.value.length >= 8;
        var password2Valid = txtPassword2 && txtPassword2.value.length >= 8 && txtPassword2.value === txtPassword.value;
        
        return fullNameValid && eNumberValid && emailValid && deptValid && roleValid && passwordValid && password2Valid;
      }
      
      // Show banner notification
      function showBanner(message, type) {
        // Remove any existing banners
        var existingBanner = document.querySelector('.msg-banner');
        if (existingBanner) {
          existingBanner.remove();
        }
        
        // Create new banner
        var banner = document.createElement('div');
        banner.className = 'msg-banner msg-banner-' + type;
        banner.textContent = message;
        banner.setAttribute('role', 'alert');
        banner.setAttribute('aria-live', 'assertive');
        
        // Insert at top of page
        document.body.insertBefore(banner, document.body.firstChild);
        
        // Auto-dismiss and redirect on success
        if (type === 'success') {
          setTimeout(function() {
            banner.style.animation = 'slideDown 0.3s ease-out reverse';
            setTimeout(function() {
              window.location.href = 'Login.aspx';
            }, 300);
          }, 3000); // 3 second delay before redirect
        } else {
          // Auto-dismiss errors after 5 seconds
          setTimeout(function() {
            banner.style.animation = 'slideDown 0.3s ease-out reverse';
            setTimeout(function() {
              banner.remove();
            }, 300);
          }, 5000);
        }
      }
      
      // Attach event listeners
      if (txtFullName) {
        txtFullName.addEventListener('input', function() { validateField(txtFullName); });
        txtFullName.addEventListener('blur', function() { validateField(txtFullName); });
      }
      if (txtENumber) {
        txtENumber.addEventListener('input', function() { validateField(txtENumber); });
        txtENumber.addEventListener('blur', function() { validateField(txtENumber); });
      }
      if (txtEmail) {
        txtEmail.addEventListener('input', function() { validateField(txtEmail); });
        txtEmail.addEventListener('blur', function() { validateField(txtEmail); });
      }
      if (ddlDepartment) {
        ddlDepartment.addEventListener('change', function() { validateField(ddlDepartment); });
        ddlDepartment.addEventListener('blur', function() { validateField(ddlDepartment); });
      }
      if (ddlJobRole) {
        ddlJobRole.addEventListener('change', function() { validateField(ddlJobRole); });
        ddlJobRole.addEventListener('blur', function() { validateField(ddlJobRole); });
      }
      if (txtPassword) {
        txtPassword.addEventListener('input', function() { 
          validateField(txtPassword);
          if (txtPassword2 && txtPassword2.value) validateField(txtPassword2);
        });
        txtPassword.addEventListener('blur', function() { validateField(txtPassword); });
      }
      if (txtPassword2) {
        txtPassword2.addEventListener('input', function() { validateField(txtPassword2); });
        txtPassword2.addEventListener('blur', function() { validateField(txtPassword2); });
      }
      
      // Handle form submission validation
      if (btnSubmit) {
        btnSubmit.addEventListener('click', function(e) {
          validateAllFields();
          
          if (!isFormValid()) {
            e.preventDefault();
            showBanner('Please correct the highlighted fields before submitting.', 'error');
            return false;
          }
        });
      }
      
      // Check for server-side status message and show banner
      var lblStatus = document.getElementById('<%= lblStatus.ClientID %>');
      if (lblStatus && lblStatus.textContent.trim()) {
        var statusText = lblStatus.textContent.trim();
        if (statusText.toLowerCase().indexOf('success') !== -1 || statusText.toLowerCase().indexOf('submitted') !== -1) {
          showBanner(statusText, 'success');
        } else if (statusText) {
          showBanner(statusText, 'error');
        }
      }
    });
  </script>
  
</asp:Content>