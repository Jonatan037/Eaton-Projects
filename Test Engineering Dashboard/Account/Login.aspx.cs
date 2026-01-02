using System;
using System.Web.Security;
using TED;
using System.Configuration;
using System.IO;

public partial class TED_Account_Login : System.Web.UI.Page
{
    private readonly AuthService _auth = new AuthService();

    protected void Page_Load(object sender, EventArgs e)
    {
        if (User != null && User.Identity != null && User.Identity.IsAuthenticated)
        {
            var returnUrl = Request.QueryString["ReturnUrl"];
            Response.Redirect(!string.IsNullOrEmpty(returnUrl) ? returnUrl : "~/Dashboard.aspx");
        }
        if (!IsPostBack) txtIdentifier.Focus();
    }

    protected void btnLogin_Click(object sender, EventArgs e)
    {
        lblError.Visible = false;
        var id = (txtIdentifier.Text ?? string.Empty).Trim();
        var pwd = (txtPassword.Text ?? string.Empty);

        if (string.IsNullOrEmpty(id) || string.IsNullOrEmpty(pwd))
        {
            ShowError("Please fill in all fields");
            return;
        }

        var user = _auth.ValidateCredentials(id, pwd);
        if (user == null)
        {
            ShowError("Invalid email/E-Number or password");
            return;
        }
        if (!user.IsActive)
        {
            ShowError("Your account is inactive. Contact an administrator.");
            return;
        }

    // Persist identity cookie
    FormsAuthentication.SetAuthCookie(!string.IsNullOrEmpty(user.FullName) ? user.FullName : (user.Email ?? id), false);
    // Stash useful fields for UI/role/avatars
    Session["TED:UserID"] = user.UserID;
    Session["TED:FullName"] = user.FullName ?? string.Empty;
    Session["TED:ENumber"] = user.ENumber ?? string.Empty;
    Session["TED:Email"] = user.Email ?? string.Empty;
    Session["TED:UserCategory"] = user.UserCategory ?? string.Empty;
    Session["TED:JobRole"] = user.JobRole ?? string.Empty;
    Session["TED:ProfilePath"] = ResolveProfilePath(user);
        _auth.UpdateLastLoginDate(user.UserID);

        var returnUrl = Request.QueryString["ReturnUrl"];
    Response.Redirect(!string.IsNullOrEmpty(returnUrl) ? returnUrl : "~/Dashboard.aspx");
    }

    // Guest access removed - all users must now request an account
    // protected void btnGuest_Click(object sender, EventArgs e)
    // {
    //     FormsAuthentication.SetAuthCookie("Guest", false);
    //     var returnUrl = Request.QueryString["ReturnUrl"];
    //     Response.Redirect(!string.IsNullOrEmpty(returnUrl) ? returnUrl : "~/Dashboard.aspx");
    // }

    private void ShowError(string message)
    {
        lblError.Text = message;
        lblError.Visible = true;
    }
    // Helpers
    private string ResolveProfilePath(TED.AuthService.UserRecord user)
    {
        try
        {
            // Try to locate a previously uploaded profile image for this user by ENumber or Email
            var uploadsRootSetting = ConfigurationManager.AppSettings["TED.UploadsRoot"] ?? "~/Uploads";
            var ppSubSetting = ConfigurationManager.AppSettings["TED.ProfilePicturesSubfolder"] ?? "ProfilePictures";
            var relFolder = (uploadsRootSetting.TrimEnd('/', '\\') + "/" + ppSubSetting.TrimStart('/', '\\')).Replace("//","/");
            var absFolder = Server.MapPath(relFolder);
            if (!Directory.Exists(absFolder)) return null;

            string[] candidates = new string[]
            {
                string.IsNullOrEmpty(user.ENumber) ? null : user.ENumber,
                string.IsNullOrEmpty(user.Email) ? null : user.Email
            };
            string[] exts = new [] { ".jpg", ".jpeg", ".png", ".webp", ".gif" };
            foreach (var cand in candidates)
            {
                if (string.IsNullOrEmpty(cand)) continue;
                foreach (var ext in exts)
                {
                    var abs = Path.Combine(absFolder, cand + ext);
                    if (File.Exists(abs))
                    {
                        var rel = (relFolder.TrimEnd('/', '\\') + "/" + Path.GetFileName(abs)).Replace("//","/");
                        return rel;
                    }
                }
            }
            return null;
        }
        catch { return null; }
    }
}
