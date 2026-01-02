using System;
using System.Web.UI;
using System.Configuration;
using System.Data.SqlClient;

public partial class TED_Dashboard : Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        // Prefer full name from session; fallback to identity name
        var fullName = (Session["TED:FullName"] as string);
        if (string.IsNullOrWhiteSpace(fullName))
            fullName = Context != null && Context.User != null ? Context.User.Identity.Name : string.Empty;
        if (string.IsNullOrEmpty(fullName)) fullName = "User";
        var initials = GetInitials(fullName);

    var cph = Master != null ? Master.FindControl("MainContent") as System.Web.UI.WebControls.ContentPlaceHolder : null;
    var litInitialsCtl = cph != null ? cph.FindControl("litInitials") as System.Web.UI.WebControls.Literal : null;
    var litFullNameCtl = cph != null ? cph.FindControl("litFullName") as System.Web.UI.WebControls.Literal : null;
    var litRoleCtl = cph != null ? cph.FindControl("litRole") as System.Web.UI.WebControls.Literal : null;
    var imgAvatarCtl = cph != null ? cph.FindControl("imgAvatar") as System.Web.UI.WebControls.Image : null;
        if (litInitialsCtl != null) litInitialsCtl.Text = initials;
        if (litFullNameCtl != null) litFullNameCtl.Text = fullName;
        if (litRoleCtl != null) litRoleCtl.Text = (Session["TED:JobRole"] as string) ?? (Session["TED:UserCategory"] as string) ?? "";

    var fallbackDiv = cph != null ? cph.FindControl("avatarFallback") as System.Web.UI.HtmlControls.HtmlGenericControl : null;
        var profileRel = Session["TED:ProfilePath"] as string;
        bool hasAvatar = !string.IsNullOrWhiteSpace(profileRel);
        if (hasAvatar && imgAvatarCtl != null)
        {
            imgAvatarCtl.ImageUrl = ResolveUrl(profileRel);
            imgAvatarCtl.Visible = true;
            if (fallbackDiv != null) fallbackDiv.Visible = false;
        }
        else
        {
            if (imgAvatarCtl != null) imgAvatarCtl.Visible = false;
            if (fallbackDiv != null) fallbackDiv.Visible = true;
        }

        // Admin menu visibility - changed from visible/hidden to enabled/disabled
        var lnkAdminPortal = cph != null ? cph.FindControl("lnkAdminPortal") as System.Web.UI.WebControls.HyperLink : null;
        if (lnkAdminPortal != null)
        {
            var cat = (Session["TED:UserCategory"] as string ?? string.Empty).ToLowerInvariant();
            var role = (Session["TED:JobRole"] as string ?? string.Empty).ToLowerInvariant();
            bool isAdmin = cat.Contains("admin") || role.Contains("admin");
            
            if (!isAdmin)
            {
                lnkAdminPortal.CssClass += " disabled";
                lnkAdminPortal.NavigateUrl = "#";
                lnkAdminPortal.Attributes["onclick"] = "return false;";
            }
        }
        BindKpis();
    }

    private string GetInitials(string input)
    {
        try
        {
            var parts = input.Split(new[] { ' ', '.', '_' }, StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length == 0) return "U";
            if (parts.Length == 1) return parts[0].Substring(0, Math.Min(2, parts[0].Length)).ToUpperInvariant();
            return (parts[0].Substring(0, 1) + parts[parts.Length - 1].Substring(0, 1)).ToUpperInvariant();
        }
        catch { return "U"; }
    }

    private void BindKpis()
    {
        try
        {
            var pending = TryScalar("SELECT COUNT(1) FROM dbo.AccountRequests WHERE Status = 'Pending'", 0);
            var new7 = TryScalar("SELECT COUNT(1) FROM dbo.AccountRequests WHERE SubmittedAt >= DATEADD(DAY,-7,SYSUTCDATETIME())", 0);
            // Active users: users marked active
            var activeUsers = TryScalar("SELECT COUNT(1) FROM dbo.Users WHERE IsActive = 1", 0);
            // Logins today (if column exists). Best effort; fallback to 0 on error.
            var loginsToday = TryScalar("SELECT COUNT(1) FROM dbo.Users WHERE CONVERT(date, LastLoginDate) = CONVERT(date, GETDATE())", 0);

            var l1 = FindControl("kpiPendingRequests") as System.Web.UI.WebControls.Literal;
            var l2 = FindControl("kpiNewRequests7d") as System.Web.UI.WebControls.Literal;
            var l3 = FindControl("kpiActiveUsers") as System.Web.UI.WebControls.Literal;
            var l4 = FindControl("kpiLoginsToday") as System.Web.UI.WebControls.Literal;
            if (l1 != null) l1.Text = pending.ToString("N0");
            if (l2 != null) l2.Text = new7.ToString("N0");
            if (l3 != null) l3.Text = activeUsers.ToString("N0");
            if (l4 != null) l4.Text = loginsToday.ToString("N0");
        }
        catch { /* ignore */ }
    }

    private int TryScalar(string sql, int fallback)
    {
        try
        {
            var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand(sql, conn))
            {
                conn.Open();
                var result = cmd.ExecuteScalar();
                if (result == null || result == DBNull.Value) return fallback;
                return Convert.ToInt32(result);
            }
        }
        catch { return fallback; }
    }
}
