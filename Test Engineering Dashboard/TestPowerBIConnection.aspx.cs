using System;
using System.Data;
using System.Net;
using System.Text;
using System.Web.UI;

public partial class TestPowerBIConnection : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            // Force TLS 1.2 globally for all HTTPS connections
            ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12 | SecurityProtocolType.Tls11 | SecurityProtocolType.Tls;
            ServicePointManager.ServerCertificateValidationCallback = delegate { return true; }; // For testing only
        }
    }

    protected async void btnTestWithToken_Click(object sender, EventArgs e)
    {
        try
        {
            var token = txtAccessToken.Text.Trim();
            
            if (string.IsNullOrEmpty(token))
            {
                ShowError("Please enter an access token");
                return;
            }
            
            ShowInfo("Connecting to Power BI dataflow...<br/>This may take a moment...");
            
            // Create the service
            var service = PowerBIDataflowFactory.CreateScrapDataService();
            service.SetAccessToken(token);
            
            // Try to query data
            var data = await service.GetScrapDataFrom2024Async();
            
            if (data != null && data.Rows.Count > 0)
            {
                ShowSuccess(string.Format("✅ Connection successful! Retrieved {0} records.", data.Rows.Count), data);
            }
            else
            {
                ShowSuccess("✅ Connection successful but no data returned. Check filter criteria.", null);
            }
        }
        catch (Exception ex)
        {
            ShowError(string.Format("Connection failed: {0}<br/><br/><strong>Details:</strong><br/>{1}", 
                ex.Message, ex.ToString()));
        }
    }

    protected void btnTestWithApp_Click(object sender, EventArgs e)
    {
        ShowError("Azure AD App authentication not yet implemented. Please use the token method for testing.");
    }

    private void ShowSuccess(string message, DataTable data)
    {
        pnlError.Visible = false;
        pnlResults.Visible = true;
        
        var sb = new StringBuilder();
        sb.Append("<div class='success-box'>");
        sb.Append(message);
        sb.Append("</div>");
        
        if (data != null && data.Rows.Count > 0)
        {
            sb.Append("<h3>Data Preview (first 100 rows)</h3>");
            sb.Append("<div style='overflow-x: auto;'>");
            sb.Append("<table>");
            
            // Header
            sb.Append("<tr>");
            foreach (DataColumn col in data.Columns)
            {
                sb.Append("<th>" + col.ColumnName + "</th>");
            }
            sb.Append("</tr>");
            
            // Rows (limit to 100 for display)
            int rowCount = Math.Min(100, data.Rows.Count);
            for (int i = 0; i < rowCount; i++)
            {
                sb.Append("<tr>");
                foreach (DataColumn col in data.Columns)
                {
                    var value = data.Rows[i][col];
                    sb.Append("<td>" + (value == DBNull.Value ? "(null)" : value.ToString()) + "</td>");
                }
                sb.Append("</tr>");
            }
            
            sb.Append("</table>");
            sb.Append("</div>");
            
            // Column info
            sb.Append("<h3>Column Information</h3>");
            sb.Append("<div class='code-block'>");
            sb.Append("Total Columns: " + data.Columns.Count + "<br/><br/>");
            foreach (DataColumn col in data.Columns)
            {
                sb.Append(col.ColumnName + " (" + col.DataType.Name + ")<br/>");
            }
            sb.Append("</div>");
        }
        
        litResults.Text = sb.ToString();
    }

    private void ShowInfo(string message)
    {
        pnlError.Visible = false;
        pnlResults.Visible = true;
        litResults.Text = "<div class='info-box'>" + message + "</div>";
    }

    private void ShowError(string message)
    {
        pnlResults.Visible = false;
        pnlError.Visible = true;
        litError.Text = message;
    }
}
