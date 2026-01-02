using System;
using System.Web.UI;

public partial class TED_Admin_ManageDb : Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        var cat = (Session["TED:UserCategory"] as string ?? string.Empty).ToLowerInvariant();
        var role = (Session["TED:JobRole"] as string ?? string.Empty).ToLowerInvariant();
        if (!(cat.Contains("admin") || role.Contains("admin")))
        {
            Response.Redirect("~/UnauthorizedAccess.aspx");
            return;
        }
        var header = FindControl("AdminHeader1");
        if (header != null)
        {
            var prop = header.GetType().GetProperty("Title");
            if (prop != null) prop.SetValue(header, "Manage DB", null);
        }
        var sidebar = FindControl("AdminSidebar1");
        if (sidebar != null)
        {
            var prop = sidebar.GetType().GetProperty("Active");
            if (prop != null) prop.SetValue(sidebar, "db", null);
        }
    }
}
