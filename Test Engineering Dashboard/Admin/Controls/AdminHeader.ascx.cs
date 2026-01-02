using System;
using System.Web.UI;

public partial class TED_Admin_Controls_AdminHeader : UserControl
{
    public string Title { get; set; }

    protected void Page_Load(object sender, EventArgs e)
    {
        // Set in Page_Load for initial render; may be overridden in OnPreRender
        ApplyTitle();
    }

    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
        ApplyTitle();
    }

    private void ApplyTitle()
    {
        var title = Title;
        if (string.IsNullOrWhiteSpace(title)) title = "Admin Portal";
        litTitle.Text = title;
    }
}
