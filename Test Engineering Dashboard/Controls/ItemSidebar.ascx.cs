using System;
using System.Web.UI;
using System.Web.UI.HtmlControls;

public partial class TED_Controls_ItemSidebar : UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        // Determine current type for highlighting
        string type = (Page.Request.QueryString["type"] ?? string.Empty).ToUpperInvariant();

        // Set back link to EquipmentInventoryDashboard; if a referer exists from there, prefer it
        var referer = Page.Request.UrlReferrer;
        if (referer != null && referer.AbsolutePath.IndexOf("EquipmentInventoryDashboard.aspx", StringComparison.OrdinalIgnoreCase) >= 0)
        {
            lnkBack.HRef = referer.ToString();
        }
        else
        {
            // Use app-root relative path to avoid duplicating the virtual directory segment
            lnkBack.HRef = ResolveUrl("~/EquipmentInventoryDashboard.aspx");
        }

        // Highlight active selection under NEW ITEM only on CreateNewItem page
        ResetNavClass(lnkNewATE);
        ResetNavClass(lnkNewAsset);
        ResetNavClass(lnkNewFixture);
        ResetNavClass(lnkNewHarness);
        var path = (Page.Request != null && Page.Request.Url != null) ? Page.Request.Url.AbsolutePath : string.Empty;
        bool isCreate = path.IndexOf("CreateNewItem.aspx", StringComparison.OrdinalIgnoreCase) >= 0;
        if (isCreate)
        {
            switch (type)
            {
                case "ATE": AddActive(lnkNewATE); break;
                case "ASSET": AddActive(lnkNewAsset); break;
                case "FIXTURE": AddActive(lnkNewFixture); break;
                case "HARNESS": AddActive(lnkNewHarness); break;
            }
        }

        // Highlight active selection under DETAILS only when on ItemDetails page
        var detA = FindControl("lnkDetATE") as HtmlAnchor;
        var detAs = FindControl("lnkDetAsset") as HtmlAnchor;
        var detF = FindControl("lnkDetFixture") as HtmlAnchor;
        var detH = FindControl("lnkDetHarness") as HtmlAnchor;
        ResetNavClass(detA); ResetNavClass(detAs); ResetNavClass(detF); ResetNavClass(detH);
        bool isDetails = path.IndexOf("ItemDetails.aspx", StringComparison.OrdinalIgnoreCase) >= 0;
        if (isDetails)
        {
            switch (type)
            {
                case "ATE": AddActive(detA); break;
                case "ASSET": AddActive(detAs); break;
                case "FIXTURE": AddActive(detF); break;
                case "HARNESS": AddActive(detH); break;
            }
        }

        // Role-based gating: disable New item links for non-privileged users
        var canEdit = CanEdit();
        if (!canEdit)
        {
            // Disable only NEW ITEM links for non-privileged users
            DisableLink(lnkNewATE);
            DisableLink(lnkNewAsset);
            DisableLink(lnkNewFixture);
            DisableLink(lnkNewHarness);
            // Details links remain enabled for everyone
        }
    }

    private void ResetNavClass(HtmlAnchor a)
    {
        if (a == null) return;
        a.Attributes["class"] = "nav-link";
    }

    private void AddActive(HtmlAnchor a)
    {
        if (a == null) return;
        var cls = a.Attributes["class"] ?? "nav-link";
        if (!cls.Contains("active")) a.Attributes["class"] = cls + " active";
    }

    private void DisableLink(HtmlAnchor a)
    {
        if (a == null) return;
        a.Attributes["aria-disabled"] = "true";
        a.Attributes["class"] = ((a.Attributes["class"] ?? "nav-link") + " disabled").Trim();
        a.HRef = "#"; // neutralize navigation
        a.Attributes["onclick"] = "return false;";
        a.Attributes["tabindex"] = "-1";
    }

    private bool CanEdit()
    {
        try
        {
            var cat = (Page.Session["TED:UserCategory"] as string ?? string.Empty).ToLowerInvariant();
            var role = (Page.Session["TED:JobRole"] as string ?? string.Empty).ToLowerInvariant();
            return (cat.Contains("admin") || cat.Contains("test engineering") || role.Contains("admin") || role.Contains("test engineering"));
        }
        catch { return false; }
    }
}
