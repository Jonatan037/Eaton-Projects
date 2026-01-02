using System;

public partial class TED_Default : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (User != null && User.Identity != null && User.Identity.IsAuthenticated)
        {
            Response.Redirect("~/Dashboard.aspx");
        }
        else
        {
            Response.Redirect("~/Account/Login.aspx");
        }
    }
}
