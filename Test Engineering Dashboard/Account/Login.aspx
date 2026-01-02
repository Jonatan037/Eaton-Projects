<%@ Page Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="Login.aspx.cs" Inherits="TED_Account_Login" %>
<asp:Content ID="LoginTitle" ContentPlaceHolderID="TitleContent" runat="server">Login - Test Engineering Dashboard</asp:Content>
<asp:Content ID="LoginHead" ContentPlaceHolderID="HeadContent" runat="server">
  <style>
    .visually-hidden{position:absolute!important;clip:rect(1px,1px,1px,1px);padding:0;border:0;height:1px;width:1px;overflow:hidden;}
    /* Restore legacy login visual design */
    :root {
      --color-bg-dark: radial-gradient(circle at 50% 35%, #14161c 0%, #0d0f14 55%, #090b10 100%);
      --color-bg-light: radial-gradient(circle at 50% 35%, #f2f4f8 0%, #e3e7ed 55%, #d9dde3 100%);
      --accent-blue: #4d8dff; --accent-green:#2bd693;
      --text-light-high:#ffffff; --text-light-low:rgba(255,255,255,.68);
      --text-dark-high:#1f242b; --text-dark-low:#4c5763;
    }
    body { background:var(--color-bg-dark); }
  html.theme-light body, html[data-theme='light'] body { background:var(--color-bg-light); }
  .login-container { background:rgba(20,23,30,.55); border-radius:26px; padding:54px 50px 74px; width:100%; max-width:440px; backdrop-filter:blur(55px) saturate(145%); border:1px solid rgba(255,255,255,.10); box-shadow:0 26px 56px -12px rgba(0,0,0,.82), 0 6px 12px -6px rgba(0,0,0,.55), 0 0 0 1px rgba(255,255,255,.06); position:relative; overflow:hidden; }
  /* moved to theme.css: .login-container light-mode */
    .login-container:before { content:""; position:absolute; inset:0; background:linear-gradient(140deg,rgba(255,255,255,.06),rgba(255,255,255,0) 45%); pointer-events:none; }
    .logo-section { text-align:center; margin-bottom:36px; }
    .logo-icon { width:58px; height:58px; background:linear-gradient(165deg,#263140,#1b2129); border-radius:50%; margin:0 auto 20px; display:flex; align-items:center; justify-content:center; border:1px solid rgba(255,255,255,.12); box-shadow:0 6px 16px rgba(0,0,0,.6),0 0 0 6px rgba(120,140,255,.04), inset 0 1px 2px rgba(255,255,255,.08); position:relative; animation:pulseGlow 3.2s ease-in-out infinite; color:#ffffff; }
  /* moved to theme.css: .logo-icon light-mode */
    .logo-title { font-size:26px; font-weight:700; margin:0 0 4px; letter-spacing:-.01em; color:var(--text-light-high); }
    .logo-subtitle { font-size:14.5px; color:var(--text-light-low); }
  /* moved to theme.css: .logo-title/.logo-subtitle light-mode */
  .form-group { margin-bottom:16px; }
  .form-control { width:100%; padding:14px 18px 13px; background:rgba(32,37,45,.72); border:1px solid rgba(255,255,255,.10); border-radius:16px; color:#f4f6f9; font-size:15px; font-weight:500; outline:none; letter-spacing:.25px; transition:background .18s ease,border-color .18s ease,box-shadow .25s ease; box-shadow:inset 0 1px 2px rgba(0,0,0,.55); font-family: inherit; }
    .form-control:focus { background:rgba(40,46,56,.88); border-color:var(--accent-blue); box-shadow:0 0 0 3px rgba(77,141,255,.28), 0 5px 14px -3px rgba(0,0,0,.55); }
  /* moved to theme.css: .form-control light-mode */
    .btn-primary, .btn-secondary { width:100%; padding:15px 20px 14px; border-radius:24px; font-size:15px; cursor:pointer; transition:background .28s ease,box-shadow .32s ease,transform .20s ease,border-color .28s ease,color .28s ease; margin-bottom:14px; border:1px solid rgba(255,255,255,.10); font-weight:600; position:relative; overflow:hidden; letter-spacing:.25px; }
    .btn-primary { background:linear-gradient(155deg,#1f2630,#161c23); color:#f5f7fa; box-shadow:0 2px 4px rgba(0,0,0,.55); }
    .btn-secondary { background:linear-gradient(155deg,#1a2027,#14191f); color:rgba(255,255,255,.9); box-shadow:0 2px 4px rgba(0,0,0,.5); }
    .btn-primary:hover { background:linear-gradient(155deg,#254056,#1b242d); border-color:var(--accent-blue); box-shadow:0 8px 20px -6px rgba(0,0,0,.75),0 0 0 1px rgba(77,141,255,.35),0 6px 26px -10px rgba(77,141,255,.55); transform:translateY(-2px); }
    .btn-secondary:hover { background:linear-gradient(155deg,#163226,#13231c); border-color:var(--accent-green); box-shadow:0 8px 20px -6px rgba(0,0,0,.7),0 0 0 1px rgba(43,214,147,.4),0 6px 24px -10px rgba(43,214,147,.5); color:#fff; transform:translateY(-2px); }
    .btn-primary:active, .btn-secondary:active { transform:translateY(0); box-shadow:0 2px 6px -2px rgba(0,0,0,.65); }
  html.theme-light .btn-primary, html[data-theme='light'] .btn-primary { background:linear-gradient(160deg,#ffffff,#eef2f7); color:#1f242b; border:1px solid rgba(0,0,0,.12); box-shadow:0 2px 4px rgba(0,0,0,.18); }
  html.theme-light .btn-secondary, html[data-theme='light'] .btn-secondary { background:linear-gradient(160deg,#f2f5f9,#e6eaef); color:#2a3139; border:1px solid rgba(0,0,0,.12); }
  html.theme-light .btn-primary:hover, html[data-theme='light'] .btn-primary:hover { background:linear-gradient(160deg,#ecf5ff,#e4eef9); border-color:var(--accent-blue); box-shadow:0 8px 18px -6px rgba(0,0,0,.25),0 0 0 1px rgba(77,141,255,.45); color:#132031; }
  html.theme-light .btn-secondary:hover, html[data-theme='light'] .btn-secondary:hover { background:linear-gradient(160deg,#effdf7,#e7f5ef); border-color:var(--accent-green); box-shadow:0 8px 18px -6px rgba(0,0,0,.22),0 0 0 1px rgba(43,214,147,.4); color:#132d23; }
    .password-wrapper { position:relative; }
  .pw-toggle { position:absolute; top:50%; transform:translateY(-50%); right:10px; background:rgba(255,255,255,.06); border:1px solid rgba(255,255,255,.18); color:#9da6b0; cursor:pointer; width:28px; height:26px; border-radius:8px; display:flex; align-items:center; justify-content:center; padding:0; transition:background .25s ease,border-color .25s ease,color .25s ease; }
  .pw-toggle:hover { background:rgba(255,255,255,.13); color:#d7dde3; box-shadow:0 3px 8px -3px rgba(0,0,0,.55); }
  /* moved to theme.css: .pw-toggle light-mode */
  .pw-toggle svg { width:12px; height:12px; }
    .pw-toggle .icon-eye { display:none; }
    .pw-toggle[data-state='visible'] .icon-eye { display:block; }
    .pw-toggle[data-state='visible'] .icon-eye-off { display:none; }
    .error-message { color:#ff9d9d; font-size:13px; margin-bottom:18px; text-align:center; font-weight:500; letter-spacing:.25px; }
    .footer-text { text-align:center; margin-top:18px; font-size:13px; color:rgba(255,255,255,.60); letter-spacing:.25px; }
    .footer-link { color:rgba(255,255,255,.78); text-decoration:underline; cursor:pointer; transition:color .2s ease; }
    .footer-link:hover { color:#fff; }
  /* moved to theme.css: footer text/link light-mode */
    .theme-toggle { position:absolute; top:12px; right:12px; background:rgba(40,45,54,.6); border:1px solid rgba(255,255,255,.14); width:35px; height:35px; border-radius:12px; display:flex; align-items:center; justify-content:center; cursor:pointer; transition:background .45s ease,border-color .45s ease,transform .25s ease,box-shadow .45s ease,color .45s ease; box-shadow:0 2px 6px rgba(0,0,0,.50), inset 0 1px 0 rgba(255,255,255,.07); overflow:hidden; color:#8d96a3; }
    .theme-toggle:hover { background:rgba(52,59,69,.88); transform:translateY(-2px); box-shadow:0 7px 12px -5px rgba(0,0,0,.6),0 0 0 1px rgba(77,141,255,.25); }
  /* shared in theme.css: theme-toggle light-mode */
    .toggle-icon { width:19px; height:19px; position:relative; }
    .toggle-icon svg { position:absolute; inset:0; width:100%; height:100%; transition:opacity .4s ease, transform .5s ease; }
    .toggle-icon .icon-sun { opacity:0; transform:rotate(-40deg) scale(.6); }
  /* shared in theme.css: toggle icons */
    .internal-footer { position:absolute; bottom:18px; left:0; right:0; display:flex; justify-content:center; gap:6px; }
    @keyframes pulseGlow { 0% { transform:scale(1); box-shadow:0 6px 14px rgba(0,0,0,.55),0 0 0 4px rgba(77,141,255,0);} 50% { transform:scale(1.055); box-shadow:0 10px 24px rgba(0,0,0,.6),0 0 0 12px rgba(77,141,255,.12);} 100% { transform:scale(1); box-shadow:0 6px 14px rgba(0,0,0,.55),0 0 0 4px rgba(77,141,255,0);} }
    /* SSO disabled button state */
  .btn-sso[disabled], .btn-sso[disabled]:hover { background:linear-gradient(155deg,#1f2630,#161c23)!important; border-color:rgba(255,255,255,.10)!important; box-shadow:0 2px 4px rgba(0,0,0,.55)!important; transform:none!important; cursor:default!important; }
  /* light-mode variant in theme.css */
  </style>
</asp:Content>
<asp:Content ID="LoginMain" ContentPlaceHolderID="MainContent" runat="server">

  <div class="page-wrapper">
  <style type="text/css">
    * { margin:0; padding:0; box-sizing:border-box; }
    body { min-height:100vh; display:flex; align-items:center; justify-content:center; padding:20px; }
  .login-container { background:rgba(20,23,30,.55); border-radius:28px; padding:56px 50px 86px; width:100%; max-width:460px; backdrop-filter:blur(55px) saturate(145%); border:1px solid rgba(255,255,255,.08); box-shadow:0 22px 48px -10px rgba(0,0,0,.7), 0 2px 4px rgba(0,0,0,.4), 0 0 0 1px rgba(255,255,255,.05), 0 0 16px rgba(235,235,240,.12); position:relative; overflow:hidden; }
    .login-container:before { content:""; position:absolute; inset:0; background:linear-gradient(140deg,rgba(255,255,255,.06),rgba(255,255,255,0) 45%); pointer-events:none; }
  html.theme-light .login-container, html[data-theme='light'] .login-container { background:rgba(255,255,255,.66); border:1px solid rgba(0,0,0,.06); box-shadow:0 18px 42px -12px rgba(0,0,0,.25),0 0 0 1px rgba(0,0,0,.06), 0 0 16px rgba(0,0,0,.12); }
    .logo-section { text-align:center; margin-bottom:36px; position:relative; }
  .logo-icon { width:60px; height:60px; background:linear-gradient(165deg,#263140,#1b2129); border-radius:50%; margin:0 auto 20px; display:flex; align-items:center; justify-content:center; border:1px solid rgba(255,255,255,.14); box-shadow:0 8px 18px rgba(0,0,0,.62),0 0 0 6px rgba(120,140,255,.05), inset 0 1px 2px rgba(255,255,255,.1); position:relative; animation:pulseGlow 3.2s ease-in-out infinite; color:#f1f4f7; }
  html.theme-light .logo-icon, html[data-theme='light'] .logo-icon { background:linear-gradient(165deg,#ffffff,#e7ecf1); color:var(--brand-eaton-blue-dark, #084d9e); border:1px solid rgba(0,0,0,.06); box-shadow:0 6px 16px rgba(0,0,0,.18),0 0 0 6px rgba(120,140,255,.05), inset 0 1px 2px rgba(255,255,255,.6); }
    .logo-icon svg { width:26px; height:26px; }
    .logo-title { font-size:26px; font-weight:700; margin:0 0 4px; letter-spacing:-.01em; }
  html.theme-light .logo-title, html[data-theme='light'] .logo-title { color: var(--brand-eaton-blue, #0b63ce); }
    .logo-subtitle { font-size:14px; opacity:.75; }
  html.theme-light .logo-subtitle, html[data-theme='light'] .logo-subtitle { opacity:.65; }
    .form-group { margin-bottom:18px; }
    .form-control { width:100%; padding:14px 18px 13px; background:rgba(32,37,45,.72); border:1px solid rgba(255,255,255,.10); border-radius:16px; color:#f4f6f9; font-size:15px; font-weight:500; outline:none; letter-spacing:.25px; transition:background .18s ease,border-color .18s ease,box-shadow .25s ease; box-shadow:inset 0 1px 2px rgba(0,0,0,.55); }
    .form-control:focus { background:rgba(40,46,56,.88); border-color:var(--accent-blue); box-shadow:0 0 0 3px rgba(77,141,255,.28); }
  html.theme-light .form-control, html[data-theme='light'] .form-control { background:rgba(255,255,255,.86); color:#20252b; border:1px solid rgba(0,0,0,.12); }
  html.theme-light .form-control:focus, html[data-theme='light'] .form-control:focus { background:#ffffff; border-color:var(--accent-blue); box-shadow:0 0 0 3px rgba(77,141,255,.25); }
  .password-wrapper { position:relative; }
  /* Hide native password reveal/clear icons (Edge/IE) since we provide our own */
  input[type="password"]::-ms-reveal,
  input[type="password"]::-ms-clear { display: none; }
  .pw-toggle { position:absolute; top:50%; transform:translateY(-50%); right:10px; background:rgba(255,255,255,.06); border:1px solid rgba(255,255,255,.18); color:#9da6b0; cursor:pointer; width:28px; height:26px; border-radius:8px; display:flex; align-items:center; justify-content:center; padding:0; transition:background .25s ease,border-color .25s ease,color .25s ease; }
  .pw-toggle:hover { background:rgba(255,255,255,.13); color:#d7dde3; }
  html.theme-light .pw-toggle { background:rgba(0,0,0,.04); border:1px solid rgba(0,0,0,.16); color:#5d6570; }
  html.theme-light .pw-toggle:hover { background:rgba(0,0,0,.08); color:#232a32; }
  .pw-toggle svg { width:12px; height:12px; }
    .pw-toggle .icon-eye { display:none; }
    .pw-toggle[data-state='visible'] .icon-eye { display:block; }
    .pw-toggle[data-state='visible'] .icon-eye-off { display:none; }
    .error-message { color:#ff9d9d; font-size:13px; margin-bottom:18px; text-align:center; font-weight:500; letter-spacing:.25px; }
    .footer-text { text-align:center; margin-top:18px; font-size:13px; opacity:.8; }
    .footer-link { text-decoration:underline; cursor:pointer; }
    .theme-toggle { position:absolute; top:12px; right:12px; }
    .internal-footer { position:absolute; bottom:20px; left:0; right:0; display:flex; justify-content:center; }
    .internal-footer .footer-meta { gap:6px; }
    @keyframes pulseGlow { 0% { transform:scale(1); box-shadow:0 6px 14px rgba(0,0,0,.55),0 0 0 4px rgba(77,141,255,0);} 50% { transform:scale(1.055); box-shadow:0 10px 24px rgba(0,0,0,.6),0 0 0 12px rgba(77,141,255,.12);} 100% { transform:scale(1); box-shadow:0 6px 14px rgba(0,0,0,.55),0 0 0 4px rgba(77,141,255,0);} }
  </style>
  <div class="login-container" role="main" aria-labelledby="loginTitleH">
            <button type="button" id="themeToggle" data-theme-toggle class="theme-toggle" aria-label="Toggle light/dark mode" title="Toggle light/dark mode">
              <span class="toggle-icon" aria-hidden="true">
                <!-- Moon (dark mode default) -->
                <svg class="icon-moon" viewBox="0 0 24 24" fill="none" stroke="none" xmlns="http://www.w3.org/2000/svg"><path fill="currentColor" d="M12.9 2.1c.6 0 .9.7.6 1.2A8.8 8.8 0 0 0 12 7.5a8.5 8.5 0 0 0 8.5 8.5c1.6 0 3.2-.4 4.2-.8.6-.2 1.1.4.8 1A11 11 0 1 1 12.9 2.1Z"/></svg>
                <!-- Sun -->
                <svg class="icon-sun" viewBox="0 0 24 24" fill="none" stroke="none" xmlns="http://www.w3.org/2000/svg"><circle cx="12" cy="12" r="5" fill="currentColor"/><g stroke="currentColor" stroke-width="1.8" stroke-linecap="round"><line x1="12" y1="1.6" x2="12" y2="4.2" /><line x1="12" y1="19.8" x2="12" y2="22.4" /><line x1="4.2" y1="12" x2="1.6" y2="12" /><line x1="22.4" y1="12" x2="19.8" y2="12" /><line x1="5.8" y1="5.8" x2="4" y2="4" /><line x1="20" y1="20" x2="18.2" y2="18.2" /><line x1="18.2" y1="5.8" x2="20" y2="4" /><line x1="4" y1="20" x2="5.8" y2="18.2" /></g></svg>
              </span>
            </button>
            <div class="logo-section">
                <div class="logo-icon" aria-hidden="true">
          <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
            <path fill="currentColor" d="M13 2L3 14H12L11 22L21 10H12L13 2Z" />
                    </svg>
                </div>
                <h1 id="loginTitleH" class="logo-title">YPO Test Engineering</h1>
                <p class="logo-subtitle">Dashboard</p>
            </div>

            <div class="form-group">
                <asp:TextBox ID="txtIdentifier" runat="server" CssClass="form-control" placeholder="Email or E-Number"></asp:TextBox>
            </div>
      <div class="form-group password-wrapper">
        <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" CssClass="form-control password-field" placeholder="Password"></asp:TextBox>
        <button type="button" id="togglePassword" aria-label="Show password" title="Show password" class="pw-toggle" data-state="hidden">
          <svg class="icon-eye" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8S1 12 1 12Z"/><circle cx="12" cy="12" r="3"/></svg>
          <svg class="icon-eye-off" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M17.94 17.94A10.94 10.94 0 0 1 12 20c-7 0-11-8-11-8a21.8 21.8 0 0 1 5.06-6.94M9.9 4.24A10.73 10.73 0 0 1 12 4c7 0 11 8 11 8a21.82 21.82 0 0 1-2.16 3.19"/><path d="M14.12 14.12a3 3 0 1 1-4.24-4.24"/><path d="m1 1 22 22"/></svg>
        </button>
      </div>

            <div aria-live="polite" class="visually-hidden" id="liveRegion"></div>
            <asp:Label ID="lblError" runat="server" CssClass="error-message" Visible="false"></asp:Label>

  <asp:Button ID="btnLogin" runat="server" Text="Sign In" CssClass="btn-primary" OnClick="btnLogin_Click" />

      <button type="button" disabled class="btn-primary btn-sso" style="margin-top:4px;opacity:.55;cursor:default;position:relative;">
        <span style="font-size:13px;display:inline-flex;align-items:center;gap:8px;">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><path d="M12 3v3"/><path d="M12 18v3"/><path d="M21 12h-3"/><path d="M6 12H3"/><path d="M17.657 6.343L15.536 8.464"/><path d="M8.464 15.536l-2.121 2.121"/><path d="M17.657 17.657l-2.121-2.121"/><path d="M8.464 8.464L6.343 6.343"/><circle cx="12" cy="12" r="4"/></svg>
          Eaton SSO (Coming Soon)
        </span>
      </button>

            <div class="footer-text" style="margin-top:24px;">Don't have an account? <a class="footer-link" href="RequestAccount.aspx">Request one</a></div>
            <!-- Removed duplicate internal footer (global footer already present) -->
        </div>
    
    <script type="text/javascript">
      (function(){
        var pwBtn = document.getElementById('togglePassword');
        var pwField = document.getElementById('<%= txtPassword.ClientID %>');
        if(pwBtn && pwField){
          pwBtn.dataset.state = pwField.getAttribute('type') === 'text' ? 'visible' : 'hidden';
          pwBtn.addEventListener('click', function(){
            var isText = pwField.getAttribute('type') === 'text';
            pwField.setAttribute('type', isText ? 'password' : 'text');
            var vis = !isText; pwBtn.dataset.state = vis ? 'visible' : 'hidden';
            pwBtn.setAttribute('aria-label', vis ? 'Hide password' : 'Show password');
            pwBtn.title = vis ? 'Hide password' : 'Show password';
          });
        }
        // Live region mirror for screen readers
        var err = document.getElementById('<%= lblError.ClientID %>');
        var live = document.getElementById('liveRegion');
        if(err && live){
          var mo = new MutationObserver(function(){ if(err.innerText.trim()){ live.textContent = err.innerText; } });
          mo.observe(err, { childList:true, subtree:true, characterData:true });
        }
      })();
    </script>
    
  </div>
</asp:Content>
