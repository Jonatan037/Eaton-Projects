using System;
using System.Web.UI;

public partial class TED_Analytics : Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            var fullName = (Session["TED:FullName"] as string);
            if (string.IsNullOrWhiteSpace(fullName))
                fullName = Context != null && Context.User != null ? Context.User.Identity.Name : string.Empty;
            if (string.IsNullOrEmpty(fullName)) fullName = "User";
            var initials = GetInitials(fullName);

            var litInitialsCtl = FindControl("litInitials") as System.Web.UI.WebControls.Literal;
            var litFullNameCtl = FindControl("litFullName") as System.Web.UI.WebControls.Literal;
            var litRoleCtl = FindControl("litRole") as System.Web.UI.WebControls.Literal;
            var imgAvatarCtl = FindControl("imgAvatar") as System.Web.UI.WebControls.Image;
            if (litInitialsCtl != null) litInitialsCtl.Text = initials;
            if (litFullNameCtl != null) litFullNameCtl.Text = fullName;
            if (litRoleCtl != null) litRoleCtl.Text = (Session["TED:JobRole"] as string) ?? (Session["TED:UserCategory"] as string) ?? "";

            var profileRel = Session["TED:ProfilePath"] as string;
            if (!string.IsNullOrWhiteSpace(profileRel) && imgAvatarCtl != null)
            {
                imgAvatarCtl.ImageUrl = ResolveUrl(profileRel);
                imgAvatarCtl.Visible = true;
                var fallbackDiv = FindControl("avatarFallback");
                if (fallbackDiv != null) fallbackDiv.Visible = false;
            }

            // Admin menu visibility
            var lnkAdminPortal = FindControl("lnkAdminPortal") as System.Web.UI.WebControls.HyperLink;
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
        }
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
}
