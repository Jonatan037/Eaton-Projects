<%@ Page Title="Home" Language="C#" AutoEventWireup="true" CodeFile="Home.aspx.cs" Inherits="TED_Home" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>TED Home</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
</head>
<body style="margin:0;min-height:100vh;background:radial-gradient(circle at 50% 35%, #14161c 0%, #0d0f14 55%, #090b10 100%);font-family:'Poppins','Inter',sans-serif;color:#e7eaef;display:flex;align-items:center;justify-content:center;padding:40px;">
    <form id="form1" runat="server" style="width:100%;max-width:1180px;">
        <div style="display:flex;gap:40px;flex-wrap:wrap;align-items:stretch;justify-content:center;">
            <div style="flex:1 1 480px;min-width:360px;background:rgba(25,29,37,.55);backdrop-filter:blur(45px) saturate(140%);border:1px solid rgba(255,255,255,.08);border-radius:26px;padding:42px 46px;position:relative;box-shadow:0 18px 40px -8px rgba(0,0,0,.65),0 2px 4px rgba(0,0,0,.4),0 0 0 1px rgba(255,255,255,.05);">
                <h1 style="margin:0 0 10px;font-size:30px;letter-spacing:-.02em;color:#fff;">Test Engineering Dashboard</h1>
                <p style="margin:0 0 28px;font-size:15px;color:#94a0b2;">Welcome <strong><asp:LoginName ID="LoginName1" runat="server" /></strong>. This landing page will soon show KPIs, recent activity and quick links.</p>
                <div style="display:flex;gap:14px;flex-wrap:wrap;margin-bottom:10px;">
                    <a href="/WebSite/Default.asp" style="text-decoration:none;padding:12px 20px;border-radius:18px;font-size:14px;font-weight:500;background:linear-gradient(155deg,#1e232b,#181c22);color:#f5f7fa;border:1px solid rgba(255,255,255,.08);box-shadow:0 2px 4px rgba(0,0,0,.55);transition:all .25s ease;">Main Site</a>
                    <a href="/Tracks" style="text-decoration:none;padding:12px 20px;border-radius:18px;font-size:14px;font-weight:500;background:linear-gradient(155deg,#1e232b,#181c22);color:#f5f7fa;border:1px solid rgba(255,255,255,.08);box-shadow:0 2px 4px rgba(0,0,0,.55);transition:all .25s ease;">Tracks</a>
                    <asp:HyperLink ID="lnkLogout" runat="server" NavigateUrl="~/Account/Logout.aspx" Text="Sign Out" Style="text-decoration:none;padding:12px 20px;border-radius:18px;font-size:14px;font-weight:500;background:linear-gradient(155deg,#2a3039,#20262d);color:#f5f7fa;border:1px solid rgba(255,255,255,.1);box-shadow:0 2px 4px rgba(0,0,0,.55);transition:all .25s ease;" />
                </div>
                <div style="font-size:12.5px;color:#5f6b7c;margin-top:30px;">Environment: <strong>Preview / Placeholder</strong></div>
            </div>
            <div style="flex:1 1 400px;min-width:320px;display:flex;flex-direction:column;gap:22px;">
                <div style="background:rgba(25,29,37,.55);backdrop-filter:blur(45px);border:1px solid rgba(255,255,255,.06);padding:28px 30px;border-radius:24px;box-shadow:0 14px 32px -10px rgba(0,0,0,.55),0 0 0 1px rgba(255,255,255,.04);">
                    <h2 style="margin:0 0 14px;font-size:20px;color:#fff;">Next Steps</h2>
                    <ul style="margin:0;padding-left:20px;line-height:1.5;font-size:14px;color:#a5b1c2;">
                        <li>Add KPI tiles (Yield, Throughput, Open Issues)</li>
                        <li>User role-based quick links</li>
                        <li>Recent changes / activity feed</li>
                    </ul>
                </div>
                <div style="background:rgba(25,29,37,.55);backdrop-filter:blur(45px);border:1px solid rgba(255,255,255,.06);padding:24px 28px;border-radius:24px;font-size:13.5px;color:#93a2b5;line-height:1.5;box-shadow:0 14px 32px -10px rgba(0,0,0,.55),0 0 0 1px rgba(255,255,255,.04);">
                    You're currently viewing the early shell of the dashboard. Use <strong>Sign Out</strong> to return to the login screen and test authentication flows.
                </div>
            </div>
        </div>
    </form>
</body>
</html>
