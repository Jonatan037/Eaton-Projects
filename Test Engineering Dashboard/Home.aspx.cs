using System;

public partial class TED_Home : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        var isAuth = User != null && User.Identity != null && User.Identity.IsAuthenticated;
        if (isAuth)
        {
            Response.Redirect("~/Dashboard.aspx");
            return;
        }
        Response.Redirect("~/Account/Login.aspx?ReturnUrl=" + Server.UrlEncode(Request.RawUrl));
    }
}
