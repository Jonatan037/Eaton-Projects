<%@ Page Language="C#" AutoEventWireup="true" CodeFile="UnauthorizedAccess.aspx.cs" Inherits="TED_UnauthorizedAccess" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Access Denied - Test Engineering Dashboard</title>
  <style>
    .visually-hidden{position:absolute!important;clip:rect(1px,1px,1px,1px);padding:0;border:0;height:1px;width:1px;overflow:hidden;}
    /* Modern unauthorized page styling */
    :root {
      --color-bg-dark: radial-gradient(circle at 50% 35%, #14161c 0%, #0d0f14 55%, #090b10 100%);
      --color-bg-light: radial-gradient(circle at 50% 35%, #f2f4f8 0%, #e3e7ed 55%, #d9dde3 100%);
      --accent-red: #ff6b6b; --accent-blue: #4d8dff;
      --text-light-high:#ffffff; --text-light-low:rgba(255,255,255,.68);
      --text-dark-high:#1f242b; --text-dark-low:#4c5763;
    }
    body { 
      background:var(--color-bg-dark); 
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
      margin: 0;
      padding: 0;
    }
    html.theme-light body, html[data-theme='light'] body { 
      background:var(--color-bg-light); 
    }
    
    .unauthorized-container {
      display: flex;
      align-items: center;
      justify-content: center;
      min-height: calc(100vh - var(--vh-offset, 80px));
      padding: 20px;
    }
    
    .unauthorized-card {
      background: rgba(20,23,30,.55);
      border-radius: 26px;
      padding: 54px 50px 64px;
      width: 100%;
      max-width: 480px;
      backdrop-filter: blur(55px) saturate(145%);
      border: 1px solid rgba(255,255,255,.10);
      box-shadow: 0 26px 56px -12px rgba(0,0,0,.82), 0 6px 12px -6px rgba(0,0,0,.55), 0 0 0 1px rgba(255,255,255,.06);
      position: relative;
      overflow: hidden;
      text-align: center;
    }
    
    html.theme-light .unauthorized-card, html[data-theme='light'] .unauthorized-card {
      background: rgba(255,255,255,.85);
      border: 1px solid rgba(0,0,0,.08);
      box-shadow: 0 26px 56px -12px rgba(0,0,0,.15), 0 6px 12px -6px rgba(0,0,0,.08);
    }
    
    .unauthorized-card:before {
      content: "";
      position: absolute;
      inset: 0;
      background: linear-gradient(140deg, rgba(255,255,255,.06), rgba(255,255,255,0) 45%);
      pointer-events: none;
    }
    
    .error-icon {
      width: 72px;
      height: 72px;
      background: linear-gradient(165deg, #4a2c2c, #3d2222);
      border-radius: 50%;
      margin: 0 auto 24px;
      display: flex;
      align-items: center;
      justify-content: center;
      border: 1px solid rgba(255,107,107,.25);
      box-shadow: 0 6px 16px rgba(255,107,107,.15), 0 0 0 6px rgba(255,107,107,.04);
      color: #ff9d9d;
    }
    
    html.theme-light .error-icon, html[data-theme='light'] .error-icon {
      background: linear-gradient(165deg, #ffeaea, #ffe0e0);
      border: 1px solid rgba(198,40,40,.25);
      box-shadow: 0 6px 16px rgba(198,40,40,.08), 0 0 0 6px rgba(198,40,40,.03);
      color: #c62828;
    }
    
    .error-title {
      font-size: 28px;
      font-weight: 800;
      margin: 0 0 12px;
      letter-spacing: -.01em;
      color: var(--text-light-high);
    }
    
    html.theme-light .error-title, html[data-theme='light'] .error-title {
      color: var(--text-dark-high);
    }
    
    .error-subtitle {
      font-size: 16px;
      color: var(--text-light-low);
      margin: 0 0 8px;
      line-height: 1.5;
    }
    
    html.theme-light .error-subtitle, html[data-theme='light'] .error-subtitle {
      color: var(--text-dark-low);
    }
    
    .error-description {
      font-size: 14px;
      color: var(--text-light-low);
      margin: 0 0 36px;
      line-height: 1.6;
      opacity: .85;
    }
    
    html.theme-light .error-description, html[data-theme='light'] .error-description {
      color: var(--text-dark-low);
    }
    
    .action-buttons {
      display: flex;
      justify-content: center;
    }
    
    .btn {
      padding: 14px 28px;
      border-radius: 24px;
      font-size: 15px;
      cursor: pointer;
      transition: all .25s ease;
      border: 1px solid rgba(255,255,255,.10);
      font-weight: 600;
      position: relative;
      overflow: hidden;
      letter-spacing: .25px;
      text-decoration: none;
      display: inline-flex;
      align-items: center;
      gap: 8px;
    }
    
    .btn-primary {
      background: linear-gradient(155deg, #4d8dff, #0063ce);
      color: #ffffff;
      box-shadow: 0 4px 12px -2px rgba(77,141,255,.4);
    }
    
    .btn-primary:hover {
      transform: translateY(-2px);
      box-shadow: 0 8px 20px -4px rgba(77,141,255,.5);
      border-color: rgba(77,141,255,.6);
    }
    
    .btn-secondary {
      background: rgba(255,255,255,.06);
      color: var(--text-light-high);
      border: 1px solid rgba(255,255,255,.18);
    }
    
    .btn-secondary:hover {
      background: rgba(255,255,255,.12);
      border-color: rgba(255,255,255,.25);
      transform: translateY(-1px);
    }
    
    html.theme-light .btn-secondary, html[data-theme='light'] .btn-secondary {
      background: #ffffff;
      color: var(--text-dark-high);
      border: 1px solid rgba(0,0,0,.12);
    }
    
    html.theme-light .btn-secondary:hover, html[data-theme='light'] .btn-secondary:hover {
      background: #f8fbff;
      border-color: rgba(0,0,0,.2);
    }
    
    .btn svg {
      width: 18px;
      height: 18px;
    }
    
    @media (max-width: 640px) {
      .unauthorized-card {
        padding: 40px 30px 50px;
        margin: 10px;
      }
      
      .error-title {
        font-size: 24px;
      }
      
      .btn {
        min-width: 140px;
        justify-content: center;
      }
    }
  </style>
</head>
<body>
  <div class="unauthorized-container">
    <div class="unauthorized-card">
      <div class="error-icon">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <circle cx="12" cy="12" r="10"></circle>
          <line x1="15" y1="9" x2="9" y2="15"></line>
          <line x1="9" y1="9" x2="15" y2="15"></line>
        </svg>
      </div>
      
      <h1 class="error-title">Access Denied</h1>
      <p class="error-subtitle">You don't have permission to access this page</p>
      <p class="error-description">
        This page requires administrator privileges. Please contact your system administrator if you believe you should have access to this resource.
      </p>
      
      <div class="action-buttons">
        <a href="http://usyouwhp6205605/Test%20Engineering%20Dashboard/Account/Logout.aspx" class="btn btn-primary">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M15 3h4a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2h-4"></path>
            <polyline points="10 17 15 12 10 7"></polyline>
            <line x1="15" y1="12" x2="3" y2="12"></line>
          </svg>
          Login
        </a>
      </div>
    </div>
  </div>
</body>
</html>