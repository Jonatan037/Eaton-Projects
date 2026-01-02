using System;
using System.Web.UI;
using System.Web.UI.HtmlControls;

public partial class TED_Admin_Controls_AdminSidebar : UserControl
{
    public string Active { get; set; } // create | manage | requests | prodlines | sublines | teststations

    protected void Page_Load(object sender, EventArgs e)
    {
        ApplyActive();
    }

    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
        ApplyActive();
    }

    private void SetActive(HtmlControl link, bool active)
    {
        if (link == null) return;
        link.Attributes["class"] = active ? "nav-link active" : "nav-link";
    }

    private void ApplyActive()
    {
        var a = (Active ?? string.Empty).ToLowerInvariant();
        if (string.IsNullOrWhiteSpace(a))
        {
            a = InferActiveFromUrl();
        }
        SetActive(lnkCreate, a == "create");
        SetActive(lnkManage, a == "manage");
        SetActive(lnkRequests, a == "requests");
        SetActive(lnkProdLines, a == "prodlines");
        SetActive(lnkSubLines, a == "sublines");
        SetActive(lnkTestStations, a == "teststations");
    }

    private string InferActiveFromUrl()
    {
        try
        {
            string path = string.Empty;
            try
            {
                if (Request != null && Request.AppRelativeCurrentExecutionFilePath != null)
                {
                    path = Request.AppRelativeCurrentExecutionFilePath;
                }
            }
            catch { path = string.Empty; }
            path = (path ?? string.Empty).ToLowerInvariant();
            if (path.EndsWith("/admin/createuser.aspx")) return "create";
            if (path.EndsWith("/admin/manageusers.aspx")) return "manage";
            if (path.EndsWith("/admin/requests.aspx")) return "requests";
            if (path.EndsWith("/admin/manageproductionlines.aspx")) return "prodlines";
            if (path.EndsWith("/admin/managesublines.aspx")) return "sublines";
            if (path.EndsWith("/admin/manageteststations.aspx")) return "teststations";
        }
        catch { }
        return string.Empty;
    }
}
