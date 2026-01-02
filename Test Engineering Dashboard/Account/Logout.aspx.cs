using System;
using System.Web.Security;

public partial class TED_Account_Logout : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (User != null && User.Identity.IsAuthenticated)
        {
            FormsAuthentication.SignOut();
            Session.Abandon();
        }
        Response.AddHeader("Refresh", "0;URL=Login.aspx");
    }
}
