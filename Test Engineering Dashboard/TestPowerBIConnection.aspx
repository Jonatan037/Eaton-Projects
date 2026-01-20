<%@ Page Language="C#" AutoEventWireup="true" CodeFile="TestPowerBIConnection.aspx.cs" Inherits="TestPowerBIConnection" Async="true" %>

<!DOCTYPE html>
<html>
<head>
    <title>Test Power BI Dataflow Connection</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            max-width: 1200px;
            margin: 40px auto;
            padding: 20px;
            background: #f5f5f5;
        }
        .container {
            background: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        h1 {
            color: #333;
            border-bottom: 3px solid #0078d4;
            padding-bottom: 10px;
        }
        .section {
            margin: 20px 0;
            padding: 20px;
            background: #f9f9f9;
            border-left: 4px solid #0078d4;
        }
        .info-box {
            background: #fff3cd;
            border: 1px solid #ffc107;
            padding: 15px;
            border-radius: 4px;
            margin: 15px 0;
        }
        .success-box {
            background: #d4edda;
            border: 1px solid #28a745;
            padding: 15px;
            border-radius: 4px;
            margin: 15px 0;
        }
        .error-box {
            background: #f8d7da;
            border: 1px solid #dc3545;
            padding: 15px;
            border-radius: 4px;
            margin: 15px 0;
        }
        .btn {
            background: #0078d4;
            color: white;
            padding: 12px 24px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
            margin: 5px;
        }
        .btn:hover {
            background: #106ebe;
        }
        .btn-secondary {
            background: #6c757d;
        }
        .btn-secondary:hover {
            background: #5a6268;
        }
        input[type="text"] {
            width: 100%;
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
            margin: 5px 0;
        }
        label {
            font-weight: 600;
            display: block;
            margin-top: 10px;
            color: #555;
        }
        .code-block {
            background: #f4f4f4;
            border: 1px solid #ddd;
            padding: 15px;
            border-radius: 4px;
            font-family: 'Courier New', monospace;
            font-size: 12px;
            overflow-x: auto;
            margin: 10px 0;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 15px 0;
        }
        th, td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        th {
            background-color: #0078d4;
            color: white;
            font-weight: 600;
        }
        tr:hover {
            background-color: #f5f5f5;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container">
            <h1>🔌 Power BI Dataflow Connection Test</h1>
            
            <div class="info-box">
                <strong>⚠️ Important Setup Required</strong><br/>
                To connect to Power BI dataflows, you need to set up Azure AD authentication first.
                This test page will guide you through the process.
            </div>

            <div class="section">
                <h2>📋 Connection Details</h2>
                <div class="code-block">
                    Workspace ID: ce0ff094-0f63-43e9-909a-c5bc60e3be4f<br/>
                    Dataflow ID: c4631e90-aeed-400f-bba3-25b5f8b5ba2e<br/>
                    Entity Name: zmmr<br/>
                    Filter: posting_date >= 2024-01-01
                </div>
            </div>

            <div class="section">
                <h2>🔐 Authentication Setup (Choose One Method)</h2>
                
                <h3>Method 1: Get Access Token from Power BI (Quick Test)</h3>
                <div class="info-box">
                    <strong>Steps to get a token:</strong><br/>
                    1. Go to <a href="https://app.powerbi.com" target="_blank">Power BI Service</a><br/>
                    2. Open Browser Developer Tools (F12)<br/>
                    3. Go to Network tab and refresh<br/>
                    4. Look for any API call to api.powerbi.com<br/>
                    5. In Request Headers, copy the "Authorization: Bearer &lt;token&gt;" value<br/>
                    6. Paste just the token part (after "Bearer ") below
                </div>
                
                <label>Access Token (for testing):</label>
                <asp:TextBox ID="txtAccessToken" runat="server" TextMode="MultiLine" Rows="4" CssClass="form-control"></asp:TextBox>
                
                <asp:Button ID="btnTestWithToken" runat="server" Text="Test Connection with Token" CssClass="btn" OnClick="btnTestWithToken_Click" />
                
                <hr style="margin: 30px 0;"/>
                
                <h3>Method 2: Azure AD App Registration (Recommended for Production)</h3>
                <div class="info-box">
                    <strong>Steps:</strong><br/>
                    1. Go to <a href="https://portal.azure.com" target="_blank">Azure Portal</a><br/>
                    2. Navigate to Azure Active Directory → App registrations<br/>
                    3. Create a new registration<br/>
                    4. Add Power BI Service API permissions<br/>
                    5. Create a client secret<br/>
                    6. Enter the details below
                </div>
                
                <label>Client ID:</label>
                <asp:TextBox ID="txtClientId" runat="server" CssClass="form-control"></asp:TextBox>
                
                <label>Client Secret:</label>
                <asp:TextBox ID="txtClientSecret" runat="server" TextMode="Password" CssClass="form-control"></asp:TextBox>
                
                <label>Tenant ID:</label>
                <asp:TextBox ID="txtTenantId" runat="server" CssClass="form-control" placeholder="e.g., eaton.onmicrosoft.com or GUID"></asp:TextBox>
                
                <asp:Button ID="btnTestWithApp" runat="server" Text="Test Connection with App" CssClass="btn" OnClick="btnTestWithApp_Click" Enabled="false" />
                <span style="color: #999; margin-left: 10px;">(Requires MSAL library - not yet implemented)</span>
            </div>

            <div class="section">
                <h2>📊 Test Results</h2>
                <asp:Panel ID="pnlResults" runat="server" Visible="false">
                    <asp:Literal ID="litResults" runat="server"></asp:Literal>
                </asp:Panel>
                
                <asp:Panel ID="pnlError" runat="server" Visible="false" CssClass="error-box">
                    <strong>❌ Error:</strong><br/>
                    <asp:Literal ID="litError" runat="server"></asp:Literal>
                </asp:Panel>
            </div>

            <div class="section">
                <h2>📖 Next Steps</h2>
                <ol>
                    <li>Test the connection using Method 1 (manual token)</li>
                    <li>If successful, we'll see the data structure</li>
                    <li>Then we can implement proper authentication</li>
                    <li>Finally, create the Scrap dashboard</li>
                </ol>
            </div>
        </div>
    </form>
</body>
</html>
