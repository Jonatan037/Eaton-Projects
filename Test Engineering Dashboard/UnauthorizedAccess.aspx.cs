using System;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class TED_UnauthorizedAccess : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {
            // Clear any existing session alerts or error messages
            if (Session["AlertMessage"] != null)
            {
                Session.Remove("AlertMessage");
            }
            if (Session["AlertType"] != null)
            {
                Session.Remove("AlertType");
            }

            // Optional: Log unauthorized access attempts for security monitoring
            LogUnauthorizedAccess();

            // Don't set 403 status initially to test if page loads
            // Response.StatusCode = 403;
            // Response.StatusDescription = "Forbidden";

            // Add security headers
            Response.Headers.Add("X-Frame-Options", "DENY");
            Response.Headers.Add("X-Content-Type-Options", "nosniff");
        }
        catch (Exception ex)
        {
            // Handle any errors gracefully - don't expose system details
            System.Diagnostics.Debug.WriteLine("UnauthorizedAccess Page_Load Error: " + ex.Message);
        }
    }

    private void LogUnauthorizedAccess()
    {
        try
        {
            // Get request information for logging
            string userIP = GetUserIP();
            string userAgent = Request.UserAgent != null ? Request.UserAgent : "Unknown";
            string referrer = Request.UrlReferrer != null ? Request.UrlReferrer.ToString() : "Direct Access";
            string requestedUrl = Request.Url != null ? Request.Url.ToString() : "Unknown";
            
            // Get session info if available
            string sessionUser = Session["TED:Username"] != null ? Session["TED:Username"].ToString() : "Anonymous";
            string userCategory = Session["TED:UserCategory"] != null ? Session["TED:UserCategory"].ToString() : "None";
            string jobRole = Session["TED:JobRole"] != null ? Session["TED:JobRole"].ToString() : "None";

            // Log to System Event Log or Debug (adjust as needed for your logging system)
            string logMessage = "Unauthorized Access Attempt - " +
                              "User: " + sessionUser + ", " +
                              "Category: " + userCategory + ", " +
                              "Role: " + jobRole + ", " +
                              "IP: " + userIP + ", " +
                              "Requested: " + requestedUrl + ", " +
                              "Referrer: " + referrer + ", " +
                              "UserAgent: " + userAgent;

            System.Diagnostics.Debug.WriteLine(logMessage);
            
            // Optional: Add to database logging if you have a security log table
            // LogSecurityEvent("UNAUTHORIZED_ACCESS", logMessage);
        }
        catch (Exception ex)
        {
            // Don't let logging errors affect the page display
            System.Diagnostics.Debug.WriteLine("UnauthorizedAccess Logging Error: " + ex.Message);
        }
    }

    private string GetUserIP()
    {
        try
        {
            // Check for forwarded IP addresses (useful behind load balancers/proxies)
            string ipAddress = Request.Headers["X-Forwarded-For"];
            
            if (string.IsNullOrEmpty(ipAddress) || ipAddress.ToLower() == "unknown")
            {
                ipAddress = Request.Headers["X-Real-IP"];
            }
            
            if (string.IsNullOrEmpty(ipAddress) || ipAddress.ToLower() == "unknown")
            {
                ipAddress = Request.ServerVariables["HTTP_X_FORWARDED_FOR"];
            }
            
            if (string.IsNullOrEmpty(ipAddress) || ipAddress.ToLower() == "unknown")
            {
                ipAddress = Request.ServerVariables["REMOTE_ADDR"];
            }
            
            // Handle multiple IPs (take the first one)
            if (!string.IsNullOrEmpty(ipAddress) && ipAddress.Contains(","))
            {
                ipAddress = ipAddress.Split(',')[0].Trim();
            }
            
            return ipAddress != null ? ipAddress : "Unknown";
        }
        catch
        {
            return "Unknown";
        }
    }

    protected override void OnPreRender(EventArgs e)
    {
        try
        {
            base.OnPreRender(e);
            
            // Add any additional client-side behavior if needed
            // For example, auto-redirect after a certain time
            // string redirectScript = @"
            //     setTimeout(function() {
            //         window.location.href = '" + ResolveUrl("~/Account/Login.aspx") + @"';
            //     }, 10000); // Redirect to login after 10 seconds
            // ";
            // ClientScript.RegisterStartupScript(this.GetType(), "AutoRedirect", redirectScript, true);
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("UnauthorizedAccess OnPreRender Error: " + ex.Message);
        }
    }
}