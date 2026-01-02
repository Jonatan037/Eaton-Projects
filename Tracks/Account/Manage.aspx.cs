using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using System.Web.Security;

public partial class Account_Manage : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    protected string GetEmailAddress()
    {
        MembershipUser currUser = null;
        if (HttpContext.Current.User != null)
        {
            currUser = Membership.GetUser(true);
            return currUser.Email;
        }
        return "Unknown email address";
    }

}