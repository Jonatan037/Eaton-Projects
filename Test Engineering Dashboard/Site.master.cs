using System;

public partial class TED_SiteMaster : System.Web.UI.MasterPage
{
    protected void Page_Init(object sender, EventArgs e)
    {
        // Disable AJAX for pages that need file uploads
        if (Request.Url.AbsolutePath.Contains("TroubleshootingDetails.aspx") ||
            Request.Url.AbsolutePath.Contains("CalibrationDetails.aspx") ||
            Request.Url.AbsolutePath.Contains("PMDetails.aspx"))
        {
            ScriptManager1.EnablePartialRendering = false;
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        // Ensure correct root theme classes applied by script; fallback here if JS disabled.
    string saved = null;
    var themeCookie = Request.Cookies["tedTheme"];
    if (themeCookie != null) saved = themeCookie.Value; // optional future cookie support
        if (saved == "light")
        {
            // Add theme-light class server-side if needed
            // (JS will also set on DOMContentLoaded)
        }
    }
}